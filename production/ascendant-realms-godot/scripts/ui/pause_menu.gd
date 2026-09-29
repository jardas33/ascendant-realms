extends Control
## In-battle pause menu.

signal resume_requested
signal quit_requested

var _panel: PanelContainer
var _resume_button: Button
var _music_button: Button
var _quit_button: Button

func setup() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	var theme_res := load("res://assets/ui/theme.tres")
	if theme_res:
		theme = theme_res

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP

	# The forged vellum plate shared with the hero screens and the result
	# ledger, so the pause screen belongs to the same kit as the battle HUD.
	_panel = load("res://scripts/ui/hero_sheet_plate.gd").new()
	add_child(_panel)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color.TRANSPARENT
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -370.0
	_panel.offset_right = 370.0
	_panel.offset_top = -300.0
	_panel.offset_bottom = 300.0

	# Your faction's shield hangs over the top edge of the plate.
	var race_id := String(Match.get_config().get("player_race", "barrosan"))
	var crest := Control.new()
	crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# A sibling of the plate, not its child: a container would stretch it.
	crest.anchor_left = 0.5
	crest.anchor_right = 0.5
	crest.anchor_top = 0.5
	crest.anchor_bottom = 0.5
	crest.offset_left = -32.0
	crest.offset_right = 32.0
	crest.offset_top = -348.0
	crest.offset_bottom = -274.0
	add_child(crest)

	var col: Color = GameData.RACES.get(race_id, {}).get("color", Color(0.7, 0.6, 0.4))
	crest.draw.connect(func():
		var w := crest.size.x
		var h := crest.size.y
		var shield := PackedVector2Array([Vector2(2, 2), Vector2(w - 2, 2), Vector2(w - 2, h * 0.55), Vector2(w * 0.5, h - 2), Vector2(2, h * 0.55)])
		crest.draw_colored_polygon(shield, Color(0.05, 0.04, 0.03, 0.97))
		var c := Vector2(w * 0.5, h * 0.45)
		var inner := PackedVector2Array()
		for p in shield:
			inner.append(c + (p - c) * 0.84)
		crest.draw_colored_polygon(inner, col.darkened(0.2))
		shield.append(shield[0])
		crest.draw_polyline(shield, Color(0.95, 0.78, 0.42), 2.2, true)
		load("res://scripts/ui/faction_sigils.gd").draw(crest, race_id, Vector2(w * 0.5, h * 0.47), w * 0.3, Color(0.99, 0.93, 0.75)))

	var margin := MarginContainer.new()
	_panel.add_child(margin)
	margin.add_theme_constant_override("margin_left", 46)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_right", 46)
	margin.add_theme_constant_override("margin_bottom", 32)
	var vb := VBoxContainer.new()
	margin.add_child(vb)
	vb.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font := load("res://assets/fonts/cinzel.ttf")
	if font:
		title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.98, 0.84, 0.46))
	title.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.01, 0.9))
	title.add_theme_constant_override("outline_size", 4)
	vb.add_child(title)

	var subtitle := Label.new()
	_subtitle = subtitle
	subtitle.text = "The battle is paused"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color(0.78, 0.72, 0.60))
	vb.add_child(subtitle)

	_resume_button = _make_btn("Resume", func(): emit_signal("resume_requested"))
	vb.add_child(_resume_button)
	# Real volume sliders (the old button cycled the music in blind steps).
	for spec in [["Music", "music_vol", "Music", 0.3], ["Sound", "sfx_vol", "SFX", 0.8]]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var lab := Label.new()
		lab.text = String(spec[0])
		lab.custom_minimum_size = Vector2(90, 0)
		lab.add_theme_color_override("font_color", Color(0.9, 0.86, 0.76))
		row.add_child(lab)
		var sl := HSlider.new()
		sl.min_value = 0.0
		sl.max_value = 1.0
		sl.step = 0.05
		sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sl.custom_minimum_size = Vector2(260, 24)
		sl.focus_mode = Control.FOCUS_NONE
		sl.value = float(ProfileManager.settings().get(String(spec[1]), float(spec[3])))
		var key := String(spec[1])
		var bus := String(spec[2])
		sl.value_changed.connect(func(v):
			ProfileManager.update_setting(key, v)
			AudioManager.set_bus_volume(bus, v))
		row.add_child(sl)
		vb.add_child(row)

	vb.add_child(_make_section_header("CONTROLS"))
	var controls_panel := PanelContainer.new()
	var controls_style := StyleBoxFlat.new()
	controls_style.bg_color = Color(0.03, 0.035, 0.045, 0.72)
	controls_style.set_border_width_all(1)
	controls_style.border_color = Color(0.55, 0.44, 0.26, 0.55)
	controls_style.set_corner_radius_all(8)
	controls_panel.add_theme_stylebox_override("panel", controls_style)
	controls_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	controls_panel.custom_minimum_size = Vector2(0, 212)
	vb.add_child(controls_panel)

	var controls_margin := MarginContainer.new()
	controls_panel.add_child(controls_margin)
	controls_margin.add_theme_constant_override("margin_left", 18)
	controls_margin.add_theme_constant_override("margin_top", 14)
	controls_margin.add_theme_constant_override("margin_right", 18)
	controls_margin.add_theme_constant_override("margin_bottom", 14)
	var columns := HBoxContainer.new()
	controls_margin.add_child(columns)
	columns.add_theme_constant_override("separation", 26)
	var movement := VBoxContainer.new()
	var system := VBoxContainer.new()
	movement.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	system.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(movement)
	columns.add_child(system)
	_maybe_add_group_label(movement, "SELECTION & ORDERS", font)
	_maybe_add_group_label(system, "GROUPS & CAMERA", font)
	_add_key_row(movement, "LMB", "Select / box-select", font)
	_add_key_row(movement, "SHIFT + LMB", "Add to selection", font)
	_add_key_row(movement, "TAB", "Select army", font)
	_add_key_row(movement, "RMB", "Move / attack / gather", font)
	_add_key_row(movement, "J", "Attack-move", font)
	_add_key_row(movement, "K", "Stop", font)
	_add_key_row(movement, "H  /  P", "Hold / patrol", font)
	_add_key_row(movement, "RMB VEIN", "Workers claim / work it", font)
	_add_key_row(system, "CTRL + 1–5", "Set control group", font)
	_add_key_row(system, "1–5", "Select control group", font)
	_add_key_row(system, "F", "Select idle worker", font)
	_add_key_row(system, "SPACE", "Focus hero", font)
	_add_key_row(system, "BACKSPACE", "Jump to latest alert", font)
	_add_key_row(system, "Q T E R  ·  Y U V", "Hero abilities", font)
	_add_key_row(system, "ESC", "Pause / resume", font)
	_add_key_row(system, "F1", "Every hotkey (field manual)", font)
	_add_key_row(system, "WHEEL / Z C", "Zoom / rotate camera", font)

	_quit_button = _make_btn("Quit to Menu", func(): emit_signal("quit_requested"))
	vb.add_child(_quit_button)

func _make_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 50)
	b.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	b.add_theme_color_override("font_hover_color", Color(1, 1, 0.9))
	b.add_theme_font_size_override("font_size", 19)
	b.pressed.connect(func():
		Sfx.play("select", -8.0)
		cb.call())
	return b

func _make_section_header(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(0.93, 0.76, 0.4))
	return label

func _maybe_add_group_label(parent: VBoxContainer, text: String, font: Font) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.72, 0.64, 0.48))
	if font:
		label.add_theme_font_override("font", font)
	parent.add_child(label)

func _add_key_row(parent: VBoxContainer, key: String, description: String, font: Font) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 24)
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var key_label := Label.new()
	key_label.text = key
	key_label.custom_minimum_size = Vector2(104, 0)
	key_label.add_theme_font_size_override("font_size", 14)
	key_label.add_theme_color_override("font_color", Color(0.98, 0.87, 0.56))
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if font:
		key_label.add_theme_font_override("font", font)
	row.add_child(key_label)
	var action_label := Label.new()
	action_label.text = description
	action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Descriptions use the plain body face; small Cinzel capitals were hard to read.
	action_label.add_theme_font_size_override("font_size", 15)
	action_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.80))
	action_label.add_theme_font_override("font", ThemeDB.fallback_font)
	action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(action_label)

var _music_step := 3
func _cycle_music() -> void:
	_music_step = (_music_step + 1) % 5
	var v := float(_music_step) / 4.0
	AudioManager.set_bus_volume("Music", v)
	ProfileManager.update_setting("music_vol", v)

func set_shown(s: bool) -> void:
	visible = s
	_update_chapter_line()
	_update_battle_so_far()

var _subtitle: Label

## The battle so far, under the title: time, foes slain, soldiers standing.
func _update_battle_so_far() -> void:
	if not is_instance_valid(_subtitle):
		return
	var scene := get_tree().current_scene
	var world = scene.get("world") if scene else null
	if world == null or not is_instance_valid(world):
		_subtitle.text = "The battle is paused"
		return
	var t := int(world.match_time)
	var soldiers := 0
	if is_instance_valid(world.player_commander):
		for u in world.player_commander.units:
			if is_instance_valid(u) and not u.is_dead and not u.is_worker:
				soldiers += 1
	var slain := int(world.kills_by_player)
	_subtitle.text = "The battle is paused  ·  %d:%02d  ·  %d %s slain  ·  %d %s standing" % [t / 60, t % 60, slain, "foe" if slain == 1 else "foes", soldiers, "soldier" if soldiers == 1 else "soldiers"]

var _chapter_line: Label

## In a campaign battle the pause menu names the chapter and its goal.
func _update_chapter_line() -> void:
	var defs = load("res://scripts/game/campaign_defs.gd")
	var chapter: Dictionary = defs.find(String(Match.get_config().get("campaign_chapter", "")))
	# Endless Road stages name their stage and title the same way.
	if chapter.is_empty() and String(Match.get_config().get("mode", "")) == "endless":
		chapter = {"title": ("Endless Road, stage %d" % int(Match.get_config().get("endless_depth", 1))) + ((": " + String(Match.get_config().get("endless_title", ""))) if String(Match.get_config().get("endless_title", "")) != "" else ""), "survive": 0}
	if chapter.is_empty():
		if is_instance_valid(_chapter_line):
			_chapter_line.visible = false
		return
	if not is_instance_valid(_chapter_line):
		_chapter_line = Label.new()
		_chapter_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_chapter_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_chapter_line.add_theme_font_size_override("font_size", 15)
		_chapter_line.add_theme_color_override("font_color", Color(0.93, 0.80, 0.52))
		var subtitle_parent: Node = _resume_button.get_parent()
		subtitle_parent.add_child(_chapter_line)
		subtitle_parent.move_child(_chapter_line, _resume_button.get_index())
	var goal := "Hold out for %d minutes." % (int(chapter.get("survive", 0)) / 60) if int(chapter.get("survive", 0)) > 0 else "Destroy the enemy's ability to rebuild."
	_chapter_line.text = "%s  ·  %s" % [String(chapter["title"]), goal]
	_chapter_line.visible = true
