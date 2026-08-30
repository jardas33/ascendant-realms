extends Control
## Hero Skill Constellation presentation layer.
## This file owns only the Skill Tree screen presentation and input routing.
## SkillDefs and ProfileManager remain the semantic authorities.

const FONT := "res://assets/fonts/cinzel.ttf"
const SPACING := Vector2(174.0, 86.0)
const FOCUSED_SPACING := Vector2(220.0, 86.0)
const MARGIN := Vector2(34.0, 48.0)
const NODE_SIZE := Vector2(160.0, 72.0)
const GRAPH_ZOOM := 0.82
const GRAPH_ORIGIN := Vector2(18.0, 18.0)

const INK := Color("#0b1020")
const PANEL := Color("#11182a")
const PAPER := Color("#e8dfca")
const MUTED := Color("#9ba9bb")
const GOLD := Color("#d8a951")
const GOLD_BRIGHT := Color("#f3cf78")
const MINT := Color("#76d3a4")
const ACTIVE := Color("#a889ed")
const LOCKED := Color("#637087")

const BRANCH_COLORS := {
	"combat": Color("#e16b5e"),
	"defense": Color("#70b5c9"),
	"mobility": Color("#d4a252"),
	"active": Color("#b08ae9"),
	"magic": Color("#72a6ec"),
	"command": Color("#d589a9"),
	"economy": Color("#79c68e"),
	"race": Color("#c59b62")
}

const GLYPH_TEXTURES := {
	"cmb_2": "res://assets/ui/skill_glyphs/task613_r1/a08_b1_battle_fury.png",
	"act_1": "res://assets/ui/skill_glyphs/task613_r1/a08_b1_rallying_cry.png",
	"act_2": "res://assets/ui/skill_glyphs/task613_r1/a08_b1_ground_slam.png",
	"act_3": "res://assets/ui/skill_glyphs/task613_r1/a08_b1_deepened_reserves.png"
}

class Glyph extends Control:
	var kind := "passive"
	var accent := Color.WHITE
	var locked := false
	var texture: Texture2D

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()

	func _draw() -> void:
		var c := LOCKED if locked else accent
		if texture:
			var tint := Color(0.68, 0.72, 0.78, 0.78) if locked else Color.WHITE
			draw_texture_rect(texture, Rect2(Vector2.ZERO, Vector2(50.0, 50.0)), false, tint)
			draw_arc(Vector2(25.0, 25.0), 24.0, 0.0, TAU, 32, Color(c, 0.82), 1.6, true)
			if locked:
				draw_circle(Vector2(39.0, 39.0), 8.0, Color(INK, 0.92))
				draw_rect(Rect2(35.0, 39.0, 8.0, 7.0), LOCKED, false, 1.5)
				draw_arc(Vector2(39.0, 39.0), 3.5, PI, TAU, 10, LOCKED, 1.5, true)
			return
		var center := Vector2(22.0, 28.0)
		draw_circle(center, 17.0, Color(c, 0.12))
		draw_arc(center, 17.0, 0.0, TAU, 20, Color(c, 0.7), 1.5, true)
		if locked:
			draw_rect(Rect2(16.0, 25.0, 12.0, 10.0), c, false, 2.0)
			draw_arc(Vector2(22.0, 25.0), 5.0, PI, TAU, 12, c, 2.0, true)
		elif kind == "active":
			draw_circle(center, 6.0, Color(c, 0.82))
			draw_line(Vector2(22, 10), Vector2(22, 18), c, 2.0, true)
			draw_line(Vector2(22, 38), Vector2(22, 46), c, 2.0, true)
			draw_line(Vector2(4, 28), Vector2(12, 28), c, 2.0, true)
			draw_line(Vector2(32, 28), Vector2(40, 28), c, 2.0, true)
		elif kind == "keystone":
			var points := PackedVector2Array([Vector2(22, 9), Vector2(35, 21), Vector2(22, 47), Vector2(9, 21)])
			draw_colored_polygon(points, Color(c, 0.7))
			draw_polyline(points + PackedVector2Array([points[0]]), c, 2.0, true)
			draw_circle(center, 4.0, INK)
		else:
			draw_circle(center, 6.0, Color(c, 0.75))
			draw_arc(center, 11.0, -0.6, 2.4, 12, c, 2.0, true)

class ConstellationCanvas extends Control:
	var presenter: Object

	func _draw() -> void:
		if is_instance_valid(presenter):
			presenter._draw_constellation(self)

var _canvas: ConstellationCanvas
var _viewport: Control
var _points_label: Label
var _points_subtitle: Label
var _detail_title: Label
var _detail_type: Label
var _detail_glyph: Glyph
var _detail_meta: Label
var _detail_body: Label
var _detail_requirements: Label
var _detail_action: Label
var _status_label: Label
var _path_filter: OptionButton
var _legend_panel: PanelContainer
var _node_buttons := {}
var _layout_positions := {}
var _glyph_texture_cache := {}
var _nodes: Array = []
var _selected_id := ""
var _hovered_id := ""
var _branch_filter := ""
var _zoom := GRAPH_ZOOM
var _pan := Vector2.ZERO
var _dragging := false

func _ready() -> void:
	_nodes = SkillDefs.get_tree()
	_build()
	ProfileManager.profile_changed.connect(_refresh_nodes)
	_refresh_nodes()
	call_deferred("_fit_default_zoom")

func _title_font() -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font

func _hero_race() -> String:
	return str(ProfileManager.hero().get("race", ""))

func _branch_color(branch: String) -> Color:
	return BRANCH_COLORS.get(branch, GOLD)

func _build() -> void:
	draw.connect(_draw_background)
	var header := MarginContainer.new()
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 28.0
	header.offset_right = -28.0
	header.offset_top = 18.0
	header.offset_bottom = 106.0
	add_child(header)
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 18)
	header.add_child(header_row)
	var title_col := VBoxContainer.new()
	title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(title_col)
	title_col.add_child(_label("HERO CONSTELLATION", 30, GOLD_BRIGHT))
	title_col.add_child(_label("Barrosan Warrior  •  Shape the legend you carry into battle", 15, MUTED))
	var point_card := PanelContainer.new()
	point_card.custom_minimum_size = Vector2(270.0, 70.0)
	point_card.add_theme_stylebox_override("panel", _panel_style(Color("#211b2b"), GOLD, 12, 1))
	header_row.add_child(point_card)
	var point_box := VBoxContainer.new()
	point_box.alignment = BoxContainer.ALIGNMENT_CENTER
	point_card.add_child(point_box)
	_points_label = _label("SKILL POINTS  0", 22, GOLD_BRIGHT)
	_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	point_box.add_child(_points_label)
	_points_subtitle = _label("AVAILABLE TO SPEND", 11, MUTED)
	_points_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	point_box.add_child(_points_subtitle)

	var detail_bg := PanelContainer.new()
	detail_bg.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	detail_bg.offset_left = 24.0
	detail_bg.offset_top = 128.0
	detail_bg.offset_right = 330.0
	detail_bg.offset_bottom = -116.0
	detail_bg.add_theme_stylebox_override("panel", _panel_style(PANEL, Color("#34445d"), 14, 1))
	add_child(detail_bg)
	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 20)
	detail_margin.add_theme_constant_override("margin_right", 20)
	detail_margin.add_theme_constant_override("margin_top", 19)
	detail_margin.add_theme_constant_override("margin_bottom", 17)
	detail_bg.add_child(detail_margin)
	var detail_box := VBoxContainer.new()
	detail_box.add_theme_constant_override("separation", 10)
	detail_margin.add_child(detail_box)
	detail_box.add_child(_label("SELECTED STAR", 11, MUTED))
	var detail_header := HBoxContainer.new()
	detail_header.add_theme_constant_override("separation", 12)
	_detail_glyph = Glyph.new()
	_detail_glyph.custom_minimum_size = Vector2(50.0, 50.0)
	_detail_glyph.size = Vector2(50.0, 50.0)
	_detail_glyph.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	detail_header.add_child(_detail_glyph)
	var detail_title_col := VBoxContainer.new()
	detail_title_col.add_theme_constant_override("separation", 4)
	detail_header.add_child(detail_title_col)
	_detail_title = _label("Choose a skill", 23, PAPER)
	_detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_type = _label("A path waits in the dark", 14, GOLD)
	detail_title_col.add_child(_detail_title)
	detail_title_col.add_child(_detail_type)
	detail_box.add_child(detail_header)
	var rule := HSeparator.new()
	rule.modulate = Color(0.5, 0.58, 0.7, 0.45)
	detail_box.add_child(rule)
	_detail_meta = _label("", 15, PAPER)
	_detail_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(_detail_meta)
	_detail_body = _label("Hover a star to reveal its power, then click to inspect its place in your build.", 15, MUTED)
	_detail_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(_detail_body)
	_detail_requirements = _label("", 13, Color("#c6a9e8"))
	_detail_requirements.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(_detail_requirements)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_box.add_child(spacer)
	_detail_action = _label("", 13, GOLD_BRIGHT)
	_detail_action.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(_detail_action)
	_status_label = _label("158 authored stars  •  Follow the links to plan ahead", 11, MUTED)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(_status_label)

	_viewport = Control.new()
	_viewport.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_viewport.offset_left = 346.0
	_viewport.offset_top = 124.0
	_viewport.offset_right = -24.0
	_viewport.offset_bottom = -116.0
	_viewport.clip_contents = true
	_viewport.gui_input.connect(_on_viewport_input)
	add_child(_viewport)
	_canvas = ConstellationCanvas.new()
	_canvas.presenter = self
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_viewport.add_child(_canvas)

	_rebuild_layout()
	for n in _nodes:
		var race: String = str(n.get("race", ""))
		if race != "" and race != _hero_race():
			continue
		_add_node_button(n)
	if _node_buttons.has("act_1"):
		_selected_id = "act_1"

	var legend := PanelContainer.new()
	legend.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	legend.offset_left = 430.0
	legend.offset_right = 850.0
	legend.offset_top = -116.0
	legend.offset_bottom = -24.0
	_legend_panel = legend
	legend.add_theme_stylebox_override("panel", _panel_style(Color("#101729"), Color("#283850"), 12, 1))
	add_child(legend)
	var legend_margin := MarginContainer.new()
	legend_margin.add_theme_constant_override("margin_left", 15)
	legend_margin.add_theme_constant_override("margin_right", 15)
	legend_margin.add_theme_constant_override("margin_top", 11)
	legend_margin.add_theme_constant_override("margin_bottom", 10)
	legend.add_child(legend_margin)
	var legend_box := VBoxContainer.new()
	legend_box.add_theme_constant_override("separation", 7)
	legend_margin.add_child(legend_box)
	legend_box.add_child(_label("READ THE CONSTELLATION", 11, MUTED))
	legend_box.add_child(_label("PATH FOCUS", 10, Color("#73839b")))
	_path_filter = OptionButton.new()
	_path_filter.custom_minimum_size = Vector2(390.0, 30.0)
	_path_filter.focus_mode = Control.FOCUS_NONE
	_path_filter.add_theme_font_override("font", _title_font())
	_path_filter.add_theme_font_size_override("font_size", 11)
	_path_filter.add_theme_color_override("font_color", PAPER)
	_path_filter.add_theme_stylebox_override("normal", _panel_style(Color("#182238"), Color("#52657e"), 7, 1))
	_path_filter.add_theme_stylebox_override("hover", _panel_style(Color("#26334d"), GOLD, 7, 1))
	_path_filter.add_theme_stylebox_override("pressed", _panel_style(Color("#332b1d"), GOLD_BRIGHT, 7, 1))
	_path_filter.add_item("ALL PATHS")
	for branch in BRANCH_COLORS.keys():
		_path_filter.add_item(str(branch).to_upper())
	_path_filter.item_selected.connect(_on_path_filter_selected)
	legend_box.add_child(_path_filter)
	var legend_row := HBoxContainer.new()
	legend_row.add_theme_constant_override("separation", 12)
	legend_box.add_child(legend_row)
	legend_row.add_child(_legend_item("UNLOCKED", MINT))
	legend_row.add_child(_legend_item("PURCHASABLE", GOLD_BRIGHT))
	legend_row.add_child(_legend_item("BLOCKED", LOCKED))
	legend_row.add_child(_legend_item("ACTIVE", ACTIVE))

	var footer := HBoxContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 346.0
	footer.offset_right = -24.0
	footer.offset_top = -92.0
	footer.offset_bottom = -24.0
	footer.add_theme_constant_override("separation", 10)
	add_child(footer)
	footer.add_child(_tool_button("BACK TO HERO", func(): _goto("res://scenes/ui/hero_sheet.tscn")))
	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)
	footer.add_child(_tool_button("− ZOOM", func(): _set_zoom(_zoom - 0.08)))
	footer.add_child(_tool_button("+ ZOOM", func(): _set_zoom(_zoom + 0.08)))
	footer.add_child(_tool_button("RECENTER", _recenter_view))
	footer.add_child(_tool_button("RESPEC", _on_respec))
	_update_canvas_size()

func _add_node_button(n: Dictionary) -> void:
	var id := str(n.get("id", ""))
	var b := Button.new()
	b.name = "Skill_%s" % id
	b.toggle_mode = false
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size = NODE_SIZE
	b.size = NODE_SIZE
	b.position = _node_pos(n)
	# The selected-star panel is the authoritative detail surface. Avoid the
	# engine's delayed one-line tooltip obscuring neighboring constellation nodes.
	b.tooltip_text = ""
	b.add_theme_font_size_override("font_size", 1)
	var glyph := Glyph.new()
	glyph.position = Vector2(6.0, 11.0)
	glyph.size = Vector2(50.0, 50.0)
	glyph.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	glyph.kind = "active" if n.get("effect", {}).has("ability") else "passive"
	glyph.kind = "keystone" if n.get("keystone", false) else glyph.kind
	glyph.accent = _branch_color(str(n.get("branch", "")))
	glyph.texture = _skill_glyph_texture(n)
	b.add_child(glyph)
	var name_label := _label(str(n.get("name", "")), 14, PAPER)
	name_label.position = Vector2(60.0, 6.0)
	name_label.size = Vector2(94.0, 42.0)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(name_label)
	var cost_label := _label("%d SP" % int(n.get("cost", 1)), 11, MUTED)
	cost_label.position = Vector2(60.0, 54.0)
	cost_label.size = Vector2(94.0, 16.0)
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(cost_label)
	b.pressed.connect(_on_node_pressed.bind(n))
	b.mouse_entered.connect(_on_node_hovered.bind(n))
	b.mouse_exited.connect(_on_node_exited.bind(n))
	_canvas.add_child(b)
	_node_buttons[id] = b

func _node_pos(n: Dictionary) -> Vector2:
	var p := _display_grid_pos(n)
	return MARGIN + Vector2(p.x, p.y) * _layout_spacing()

func _layout_spacing() -> Vector2:
	return FOCUSED_SPACING if _branch_filter != "" else SPACING

func _display_grid_pos(n: Dictionary) -> Vector2:
	var id := str(n.get("id", ""))
	if _layout_positions.has(id):
		return _layout_positions[id]
	var p: Vector2 = n.get("pos", Vector2.ZERO)
	return p

func _rebuild_layout() -> void:
	_layout_positions.clear()
	var visible: Array = []
	var columns: Array = []
	for n in _nodes:
		if not _is_visible_node(n):
			continue
		visible.append(n)
		var x := float((n.get("pos", Vector2.ZERO) as Vector2).x)
		if not columns.has(x):
			columns.append(x)
	columns.sort()
	var column_map := {}
	for i in range(columns.size()):
		column_map[columns[i]] = i
	visible.sort_custom(func(a, b):
		var ap: Vector2 = a.get("pos", Vector2.ZERO)
		var bp: Vector2 = b.get("pos", Vector2.ZERO)
		if ap.y == bp.y:
			return ap.x < bp.x
		return ap.y < bp.y
	)
	var occupied := {}
	var branch_map := {}
	for n in visible:
		var branch := str(n.get("branch", ""))
		if not branch_map.has(branch):
			branch_map[branch] = branch_map.size()
	var focused_sequence := [1, 0, 2, 3, 1, 2, 0, 3]
	for i in range(visible.size()):
		var n: Dictionary = visible[i]
		var id := str(n.get("id", ""))
		var authored: Vector2 = n.get("pos", Vector2.ZERO)
		var column := int(branch_map[str(n.get("branch", ""))])
		if _branch_filter != "":
			# Focused paths use a restrained four-column constellation pattern.
			# This changes presentation only; prerequisite links remain authored.
			column = focused_sequence[i % focused_sequence.size()]
		var row := maxi(0, int(round(authored.y)))
		var key := "%d:%d" % [column, row]
		while occupied.has(key):
			row += 1
			key = "%d:%d" % [column, row]
		occupied[key] = id
		_layout_positions[id] = Vector2(column, row)

func _is_visible_node(n: Dictionary) -> bool:
	if n.is_empty():
		return false
	var race: String = str(n.get("race", ""))
	if race != "" and race != _hero_race():
		return false
	return _branch_filter == "" or str(n.get("branch", "")) == _branch_filter

func _update_canvas_size() -> void:
	_rebuild_layout()
	var max_x := 0.0
	var max_y := 0.0
	for n in _nodes:
		if not _is_visible_node(n):
			continue
		var p := _display_grid_pos(n)
		max_x = maxf(max_x, p.x)
		max_y = maxf(max_y, p.y)
	_canvas.custom_minimum_size = MARGIN * 2.0 + Vector2(max_x, max_y) * _layout_spacing() + NODE_SIZE
	_canvas.size = _canvas.custom_minimum_size
	_apply_transform()

func _fit_default_zoom() -> void:
	if not is_instance_valid(_viewport) or _viewport.size.x <= 0.0:
		return
	if is_instance_valid(_legend_panel):
		var guide_left := 430.0 if size.x < 1500.0 else 600.0
		_legend_panel.offset_left = guide_left
		_legend_panel.offset_right = guide_left + 420.0
	var target := GRAPH_ZOOM
	if _branch_filter == "":
		target = minf(target, maxf(0.62, (_viewport.size.x - 36.0) / maxf(1.0, _canvas.size.x)))
	_zoom = clampf(target, 0.52, 1.16)
	_apply_transform()

func _apply_transform() -> void:
	_canvas.scale = Vector2(_zoom, _zoom)
	var view_size := _viewport.size
	var scaled_size := _canvas.size * _zoom
	var centered := Vector2(GRAPH_ORIGIN.x, GRAPH_ORIGIN.y)
	if view_size.x > 0.0:
		centered.x = maxf(GRAPH_ORIGIN.x, (view_size.x - scaled_size.x) * 0.5)
		centered.y = maxf(GRAPH_ORIGIN.y, (view_size.y - scaled_size.y) * 0.5)
	_canvas.position = centered + _pan
	_canvas.queue_redraw()

func _set_zoom(z: float) -> void:
	Sfx.play("select")
	_zoom = clampf(z, 0.52, 1.16)
	_apply_transform()

func _recenter_view() -> void:
	_pan = Vector2.ZERO
	_fit_default_zoom()

func _on_viewport_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_set_zoom(_zoom + 0.08)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_set_zoom(_zoom - 0.08)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
	elif event is InputEventMouseMotion and _dragging:
		_pan += event.relative
		_apply_transform()

func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), INK)
	for i in range(8):
		var x := float(i) * size.x / 7.0
		draw_line(Vector2(x, 0), Vector2(x + 160.0, size.y), Color(0.18, 0.25, 0.38, 0.08), 1.0)
	for i in range(6):
		var y := 120.0 + float(i) * maxf(1.0, (size.y - 170.0) / 5.0)
		draw_line(Vector2(346.0, y), Vector2(size.x - 24.0, y), Color(0.35, 0.42, 0.54, 0.07), 1.0)
	for p in [Vector2(size.x * 0.48, 130), Vector2(size.x * 0.82, 760), Vector2(size.x * 0.2, 860)]:
		draw_circle(p, 120.0, Color(0.14, 0.2, 0.34, 0.12))
		draw_arc(p, 120.0, 0.0, TAU, 40, Color(GOLD, 0.08), 1.0, true)
	draw_line(Vector2(24, 108), Vector2(size.x - 24, 108), Color(GOLD, 0.35), 1.0)
	draw_line(Vector2(24, size.y - 105), Vector2(size.x - 24, size.y - 105), Color(GOLD, 0.22), 1.0)

func _draw_constellation(canvas: CanvasItem) -> void:
	var branch_seen := {}
	for n in _nodes:
		var id := str(n.get("id", ""))
		if not _node_buttons.has(id) or not _is_visible_node(n):
			continue
		var branch := str(n.get("branch", ""))
		var anchor := _node_pos(n)
		if not branch_seen.has(branch):
			branch_seen[branch] = anchor.x
			canvas.draw_string(_title_font(), Vector2(anchor.x, 25.0), branch.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color(_branch_color(branch), 0.82))
		for req in n.get("req", []):
			var required := _find_node(str(req))
			if not _node_buttons.has(req) or not _is_visible_node(required):
				continue
			var from_node := required
			if from_node.is_empty():
				continue
			var from := _node_pos(from_node) + Vector2(NODE_SIZE.x * 0.5, NODE_SIZE.y)
			var to := anchor + Vector2(NODE_SIZE.x * 0.5, 0.0)
			var complete := _is_unlocked(id) and _is_unlocked(req)
			var available := _prereqs_met(n) and not _is_unlocked(id)
			var col := MINT if complete else GOLD if available else Color(0.35, 0.42, 0.54, 0.52)
			canvas.draw_line(from, to, Color(col, 0.16), 8.0, true)
			canvas.draw_line(from, to, Color(col, 0.8), 2.2 if complete else 1.5, true)
			canvas.draw_circle(to, 3.0, col)

func _find_node(id: String) -> Dictionary:
	for n in _nodes:
		if str(n.get("id", "")) == id:
			return n
	return {}

func _is_unlocked(id: String) -> bool:
	return id in ProfileManager.hero().get("skills", [])

func _prereqs_met(n: Dictionary) -> bool:
	var owned: Array = ProfileManager.hero().get("skills", [])
	for req in n.get("req", []):
		if not (req in owned):
			return false
	return true

func _node_state(n: Dictionary) -> String:
	var id := str(n.get("id", ""))
	if _is_unlocked(id):
		return "UNLOCKED"
	if not _prereqs_met(n):
		return "PREREQUISITE_BLOCKED"
	if int(ProfileManager.hero().get("skill_points", 0)) >= int(n.get("cost", 1)):
		return "PURCHASABLE"
	return "INSUFFICIENT_POINTS"

func _node_tag(n: Dictionary) -> String:
	match _node_state(n):
		"UNLOCKED":
			return "UNLOCKED"
		"PURCHASABLE":
			return "CLAIM"
		"INSUFFICIENT_POINTS":
			return "OPEN"
		_:
			return "LOCKED"

func _node_style(n: Dictionary, selected: bool, hovered: bool) -> StyleBoxFlat:
	var state := _node_state(n)
	var bg := Color("#172238")
	var border := Color(0.27, 0.34, 0.47, 0.9)
	if state == "UNLOCKED":
		bg = Color("#14352f")
		border = MINT
	elif state == "PURCHASABLE":
		bg = Color("#3a2d18")
		border = GOLD_BRIGHT
	elif state == "INSUFFICIENT_POINTS":
		bg = Color("#272638")
		border = Color(GOLD, 0.75)
	elif state == "PREREQUISITE_BLOCKED":
		bg = Color("#131a29")
		border = Color(LOCKED, 0.7)
	if n.get("keystone", false):
		border = GOLD_BRIGHT if state != "UNLOCKED" else MINT
	if hovered:
		bg = bg.lightened(0.14)
		border = PAPER
	if selected:
		border = GOLD_BRIGHT
	var box := _panel_style(bg, border, 11, 2 if selected else 1)
	box.shadow_color = Color(0, 0, 0, 0.28)
	box.shadow_size = 5 if selected or hovered else 2
	return box

func _refresh_nodes() -> void:
	if not ProfileManager.has_hero():
		return
	var h := ProfileManager.hero()
	var sp := int(h.get("skill_points", 0))
	_points_label.text = "SKILL POINTS  %d" % sp
	for n in _nodes:
		var id := str(n.get("id", ""))
		if not _node_buttons.has(id):
			continue
		var b: Button = _node_buttons[id]
		b.visible = _is_visible_node(n)
		b.position = _node_pos(n)
		var state := _node_state(n)
		var cost_label: Label = b.get_child(2) as Label
		cost_label.text = "%d SP  •  %s" % [int(n.get("cost", 1)), _node_tag(n)]
		cost_label.modulate = GOLD_BRIGHT if state == "PURCHASABLE" else MINT if state == "UNLOCKED" else MUTED
		b.add_theme_stylebox_override("normal", _node_style(n, id == _selected_id, id == _hovered_id))
		b.add_theme_stylebox_override("hover", _node_style(n, id == _selected_id, true))
		b.add_theme_stylebox_override("pressed", _node_style(n, true, true))
		var glyph: Glyph = b.get_child(0) as Glyph
		glyph.locked = state == "PREREQUISITE_BLOCKED"
		glyph.accent = _branch_color(str(n.get("branch", "")))
		glyph.queue_redraw()
	var edge_count := 0
	for n in _nodes:
		edge_count += (n.get("req", []) as Array).size()
	var focus_text := "ALL PATHS" if _branch_filter == "" else _branch_filter.to_upper()
	_status_label.text = "%d authored stars  •  %d prerequisite links  •  %s  •  FOCUS: %s" % [_nodes.size(), edge_count, _hero_race().to_upper(), focus_text]
	_canvas.queue_redraw()
	if _selected_id != "":
		var selected := _find_node(_selected_id)
		if not selected.is_empty():
			_update_detail(selected)

func _on_node_hovered(n: Dictionary) -> void:
	_hovered_id = str(n.get("id", ""))
	_update_detail(n)
	_refresh_nodes()

func _on_node_exited(n: Dictionary) -> void:
	if _hovered_id == str(n.get("id", "")):
		_hovered_id = ""
		if _selected_id != "":
			var selected := _find_node(_selected_id)
			if not selected.is_empty():
				_update_detail(selected)
	_refresh_nodes()

func _on_path_filter_selected(index: int) -> void:
	_branch_filter = "" if index == 0 else str(BRANCH_COLORS.keys()[index - 1])
	if _selected_id != "" and not _is_visible_node(_find_node(_selected_id)):
		_selected_id = ""
		for n in _nodes:
			if _is_visible_node(n):
				_selected_id = str(n.get("id", ""))
				break
	_update_canvas_size()
	_refresh_nodes()

func _skill_glyph_texture(n: Dictionary) -> Texture2D:
	var id := str(n.get("id", ""))
	if _glyph_texture_cache.has(id):
		return _glyph_texture_cache[id]
	var path := str(GLYPH_TEXTURES.get(id, ""))
	var texture: Texture2D = load(path) if path != "" and ResourceLoader.exists(path) else null
	_glyph_texture_cache[id] = texture
	return texture

func _on_node_pressed(n: Dictionary) -> void:
	_selected_id = str(n.get("id", ""))
	_update_detail(n)
	var id := _selected_id
	if _is_unlocked(id):
		Sfx.play("select")
		_refresh_nodes()
		return
	if _prereqs_met(n) and int(ProfileManager.hero().get("skill_points", 0)) >= int(n.get("cost", 1)):
		if ProfileManager.unlock_skill(id):
			Sfx.play("levelup")
			_status_label.text = "%s joined your constellation." % str(n.get("name", ""))
		else:
			Sfx.play("select")
	else:
		Sfx.play("select")
		_detail_action.text = "NOT READY  •  See the requirement above"
	_refresh_nodes()

func _update_detail(n: Dictionary) -> void:
	var state := _node_state(n)
	var has_ability: bool = bool(n.get("effect", {}).has("ability"))
	if is_instance_valid(_detail_glyph):
		_detail_glyph.kind = "active" if has_ability else "passive"
		_detail_glyph.kind = "keystone" if n.get("keystone", false) else _detail_glyph.kind
		_detail_glyph.accent = _branch_color(str(n.get("branch", "")))
		_detail_glyph.locked = state == "PREREQUISITE_BLOCKED"
		_detail_glyph.texture = _skill_glyph_texture(n)
		_detail_glyph.queue_redraw()
	_detail_title.text = str(n.get("name", ""))
	_detail_type.text = ("ACTIVE ABILITY" if has_ability else "PASSIVE AUGMENT") + ("  •  KEYSTONE" if n.get("keystone", false) else "")
	_detail_type.modulate = ACTIVE if has_ability else GOLD
	_detail_meta.text = "COST  %d SKILL POINT%s\nSTATE  %s" % [int(n.get("cost", 1)), "" if int(n.get("cost", 1)) == 1 else "S", state.replace("_", " ")]
	_detail_body.text = str(n.get("desc", ""))
	var req_names: Array[String] = []
	for req in n.get("req", []):
		var parent := _find_node(str(req))
		req_names.append(str(parent.get("name", req)))
	if req_names.is_empty():
		_detail_requirements.text = "ROOT STAR  •  No prerequisite"
	else:
		_detail_requirements.text = ("REQUIRES  " + "  +  ".join(req_names)) if state == "PREREQUISITE_BLOCKED" else ("PATH FROM  " + "  +  ".join(req_names))
	if state == "UNLOCKED":
		_detail_action.text = "UNLOCKED  •  This power is active in your build"
	elif state == "PURCHASABLE":
		_detail_action.text = "READY TO CLAIM  •  Click to spend %d point%s" % [int(n.get("cost", 1)), "" if int(n.get("cost", 1)) == 1 else "s"]
	elif state == "INSUFFICIENT_POINTS":
		_detail_action.text = "AVAILABLE  •  INSUFFICIENT POINTS to claim it"
	else:
		_detail_action.text = "PREREQUISITE BLOCKED  •  Follow the parent path"

func _legend_item(text: String, color: Color) -> Label:
	var label := _label("●  " + text, 10, color)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", _title_font())
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _tool_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(132.0, 48.0)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_override("font", _title_font())
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", PAPER)
	b.add_theme_stylebox_override("normal", _panel_style(Color("#182238"), Color("#52657e"), 9, 1))
	b.add_theme_stylebox_override("hover", _panel_style(Color("#26334d"), GOLD, 9, 1))
	b.add_theme_stylebox_override("pressed", _panel_style(Color("#332b1d"), GOLD_BRIGHT, 9, 2))
	b.pressed.connect(cb)
	return b

func _panel_style(bg: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 8.0
	box.content_margin_right = 8.0
	box.content_margin_top = 6.0
	box.content_margin_bottom = 6.0
	return box

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

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)
