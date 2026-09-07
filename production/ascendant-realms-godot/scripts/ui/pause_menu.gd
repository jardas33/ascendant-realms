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

	_panel = PanelContainer.new()
	add_child(_panel)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.045, 0.055, 0.08, 0.985)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.68, 0.54, 0.3, 0.98)
	sb.set_corner_radius_all(14)
	sb.shadow_color = Color(0, 0, 0, 0.62)
	sb.shadow_size = 18
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -370.0
	_panel.offset_right = 370.0
	_panel.offset_top = -300.0
	_panel.offset_bottom = 300.0

	var margin := MarginContainer.new()
	_panel.add_child(margin)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 26)
	var vb := VBoxContainer.new()
	margin.add_child(vb)
	vb.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font := load("res://assets/fonts/cinzel.ttf")
	if font:
		title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color(0.98, 0.86, 0.52))
	vb.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "The battle is paused"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color(0.68, 0.7, 0.76))
	vb.add_child(subtitle)

	_resume_button = _make_btn("Resume", func(): emit_signal("resume_requested"))
	vb.add_child(_resume_button)
	_music_button = _make_btn("Music  ·  + / -", func(): _cycle_music())
	vb.add_child(_music_button)

	vb.add_child(_make_section_header("CONTROLS"))
	var controls_panel := PanelContainer.new()
	var controls_style := StyleBoxFlat.new()
	controls_style.bg_color = Color(0.075, 0.085, 0.12, 0.94)
	controls_style.set_border_width_all(1)
	controls_style.border_color = Color(0.31, 0.3, 0.28, 0.9)
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
	_add_key_row(system, "CTRL + 1–5", "Set control group", font)
	_add_key_row(system, "1–5", "Select control group", font)
	_add_key_row(system, "F", "Select idle worker", font)
	_add_key_row(system, "SPACE", "Focus hero", font)
	_add_key_row(system, "Q / T / E / R", "Hero abilities", font)
	_add_key_row(system, "ESC", "Pause / resume", font)
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
	key_label.add_theme_font_size_override("font_size", 13)
	key_label.add_theme_color_override("font_color", Color(0.98, 0.87, 0.56))
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if font:
		key_label.add_theme_font_override("font", font)
	row.add_child(key_label)
	var action_label := Label.new()
	action_label.text = description
	action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_label.add_theme_font_size_override("font_size", 14)
	action_label.add_theme_color_override("font_color", Color(0.88, 0.89, 0.9))
	action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if font:
		action_label.add_theme_font_override("font", font)
	row.add_child(action_label)

var _music_step := 3
func _cycle_music() -> void:
	_music_step = (_music_step + 1) % 5
	var v := float(_music_step) / 4.0
	AudioManager.set_bus_volume("Music", v)
	ProfileManager.update_setting("music_vol", v)

func set_shown(s: bool) -> void:
	visible = s
