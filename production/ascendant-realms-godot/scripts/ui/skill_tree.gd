extends Control
## Skill Constellation — the hero's talent tree.
## Nodes placed by grid pos, prerequisite lines drawn, pan + zoom supported.
## Colors: unlocked=green, available=gold, locked=dim. Race-gated nodes only
## show for the hero's own race.

const FONT := "res://assets/fonts/cinzel.ttf"
const SPACING := Vector2(160, 120)
const MARGIN := Vector2(120, 120)
const NODE_SIZE := Vector2(120, 74)

var _canvas: Control          # holds node buttons, drawn lines
var _viewport: Control        # clip region
var _points_label: Label
var _info_label: Label
var _zoom := 1.0
var _pan := Vector2.ZERO
var _dragging := false
var _node_buttons := {}       # id -> Button
var _nodes := []

func _ready() -> void:
	_nodes = SkillDefs.get_tree()
	_build()
	ProfileManager.profile_changed.connect(_refresh_nodes)
	_refresh_nodes()

func _title_font() -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font

func _hero_race() -> String:
	return str(ProfileManager.hero().get("race", ""))

func _build() -> void:
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.03, 0.04, 0.07, 1.0)
	add_child(scrim)

	# Title
	var title := Label.new()
	title.text = "The Constellation"
	title.add_theme_font_override("font", _title_font())
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.96, 0.9, 0.7))
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	title.offset_left = 24.0
	title.offset_top = 16.0
	title.offset_right = 500.0
	title.offset_bottom = 60.0
	add_child(title)

	_points_label = Label.new()
	_points_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	_points_label.add_theme_font_size_override("font_size", 24)
	_points_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_points_label.offset_left = -400.0
	_points_label.offset_right = -24.0
	_points_label.offset_top = 20.0
	_points_label.offset_bottom = 54.0
	_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_points_label)

	# Viewport (clips the pannable canvas)
	_viewport = Control.new()
	_viewport.clip_contents = true
	_viewport.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_viewport.offset_top = 70.0
	_viewport.offset_bottom = -130.0
	_viewport.offset_left = 20.0
	_viewport.offset_right = -20.0
	_viewport.gui_input.connect(_on_viewport_input)
	add_child(_viewport)

	# Canvas holds lines (drawn) and node buttons.
	_canvas = Control.new()
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_lines)
	_viewport.add_child(_canvas)

	# Node buttons
	for n in _nodes:
		var race: String = str(n.get("race", ""))
		if race != "" and race != _hero_race():
			continue  # hide foreign race nodes
		var b := Button.new()
		b.toggle_mode = false
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = NODE_SIZE
		b.size = NODE_SIZE
		b.position = _node_pos(n)
		var lbl := Label.new()
		lbl.text = str(n.get("name", ""))
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(lbl)
		b.pressed.connect(_on_node_pressed.bind(n))
		b.mouse_entered.connect(_show_info.bind(n))
		_canvas.add_child(b)
		_node_buttons[n.get("id", "")] = b

	# Info panel
	_info_label = Label.new()
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_label.add_theme_font_size_override("font_size", 16)
	_info_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.82))
	_info_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_info_label.offset_top = -120.0
	_info_label.offset_bottom = -66.0
	_info_label.offset_left = 260.0
	_info_label.offset_right = -260.0
	_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info_label.text = "Hover a star to read its power. Click a gold star to unlock it."
	add_child(_info_label)

	# Bottom controls
	var bar := HBoxContainer.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -56.0
	bar.offset_bottom = -12.0
	bar.offset_left = 20.0
	bar.offset_right = -20.0
	bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.add_theme_constant_override("separation", 14)
	add_child(bar)
	bar.add_child(_tool_button("Back", func(): _goto("res://scenes/ui/hero_sheet.tscn")))
	bar.add_child(_tool_button("- Zoom", func(): _set_zoom(_zoom - 0.15)))
	bar.add_child(_tool_button("+ Zoom", func(): _set_zoom(_zoom + 0.15)))
	bar.add_child(_tool_button("Recenter", func(): _pan = Vector2.ZERO; _set_zoom(1.0)))
	bar.add_child(_tool_button("Respec", _on_respec))

	_update_canvas_size()

func _node_pos(n: Dictionary) -> Vector2:
	var p: Vector2 = n.get("pos", Vector2.ZERO)
	return MARGIN + Vector2(p.x, p.y) * SPACING

func _update_canvas_size() -> void:
	var max_x := 0.0
	var max_y := 0.0
	for n in _nodes:
		var race: String = str(n.get("race", ""))
		if race != "" and race != _hero_race():
			continue
		var p: Vector2 = n.get("pos", Vector2.ZERO)
		if p.x > max_x:
			max_x = p.x
		if p.y > max_y:
			max_y = p.y
	_canvas.custom_minimum_size = MARGIN * 2.0 + Vector2(max_x, max_y) * SPACING + NODE_SIZE
	_canvas.size = _canvas.custom_minimum_size
	_apply_transform()

func _apply_transform() -> void:
	_canvas.scale = Vector2(_zoom, _zoom)
	_canvas.position = _pan
	_canvas.queue_redraw()

func _set_zoom(z: float) -> void:
	Sfx.play("select")
	_zoom = clamp(z, 0.5, 1.6)
	_apply_transform()

# --- input (pan + wheel zoom) ---------------------------------------------
func _on_viewport_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_set_zoom(_zoom + 0.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_set_zoom(_zoom - 0.1)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
	elif event is InputEventMouseMotion and _dragging:
		_pan += event.relative
		_apply_transform()

# --- drawing prerequisite lines -------------------------------------------
func _draw_lines() -> void:
	for n in _nodes:
		var id: String = str(n.get("id", ""))
		if not _node_buttons.has(id):
			continue
		var to := _node_pos(n) + NODE_SIZE * 0.5
		for r in n.get("req", []):
			if not _node_buttons.has(r):
				continue
			var from_node := _find_node(r)
			if from_node.is_empty():
				continue
			var from := _node_pos(from_node) + NODE_SIZE * 0.5
			var unlocked: bool = _is_unlocked(id) and _is_unlocked(r)
			var col := Color(0.55, 0.85, 0.5, 0.9) if unlocked else Color(0.5, 0.5, 0.55, 0.5)
			_canvas.draw_line(from, to, col, 3.0, true)

func _find_node(id: String) -> Dictionary:
	for n in _nodes:
		if str(n.get("id", "")) == id:
			return n
	return {}

# --- state ----------------------------------------------------------------
func _is_unlocked(id: String) -> bool:
	return id in ProfileManager.hero().get("skills", [])

func _prereqs_met(n: Dictionary) -> bool:
	var owned: Array = ProfileManager.hero().get("skills", [])
	for r in n.get("req", []):
		if not (r in owned):
			return false
	return true

func _refresh_nodes() -> void:
	if not ProfileManager.has_hero():
		return
	var h := ProfileManager.hero()
	var sp := int(h.get("skill_points", 0))
	_points_label.text = "Skill Points: %d" % sp
	for n in _nodes:
		var id: String = str(n.get("id", ""))
		if not _node_buttons.has(id):
			continue
		var b: Button = _node_buttons[id]
		var cost := int(n.get("cost", 1))
		var col: Color
		if _is_unlocked(id):
			col = Color(0.35, 0.7, 0.4)       # green
		elif _prereqs_met(n) and sp >= cost:
			col = Color(0.85, 0.7, 0.25)       # gold available
		else:
			col = Color(0.28, 0.3, 0.36)       # locked dim
		if n.get("keystone", false):
			col = col.lightened(0.12)
		b.add_theme_color_override("bg_color", col)  # harmless if theme ignores
		b.self_modulate = col.lightened(0.1)
	_canvas.queue_redraw()

func _on_node_pressed(n: Dictionary) -> void:
	_show_info(n)
	var id: String = str(n.get("id", ""))
	if _is_unlocked(id):
		return
	if _prereqs_met(n) and int(ProfileManager.hero().get("skill_points", 0)) >= int(n.get("cost", 1)):
		if ProfileManager.unlock_skill(id):
			Sfx.play("levelup")
		else:
			Sfx.play("select")

func _show_info(n: Dictionary) -> void:
	var extra := ""
	if n.get("keystone", false):
		extra = "  [KEYSTONE]"
	_info_label.text = "%s (Cost %d)%s\n%s" % [n.get("name", ""), int(n.get("cost", 1)), extra, n.get("desc", "")]

func _on_respec() -> void:
	Sfx.play("select")
	var dlg := ConfirmationDialog.new()
	dlg.dialog_text = "Refund all unlocked skills? Your skill points will be returned."
	dlg.title = "Respec Constellation"
	add_child(dlg)
	dlg.confirmed.connect(func():
		ProfileManager.respec_skills()
		dlg.queue_free())
	dlg.canceled.connect(func(): dlg.queue_free())
	dlg.popup_centered()

# --- helpers --------------------------------------------------------------
func _tool_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.clip_text = true
	b.custom_minimum_size = Vector2(140, 44)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 18)
	b.pressed.connect(cb)
	return b

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)
