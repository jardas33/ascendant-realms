extends Control
## In-battle pause menu.

signal resume_requested
signal quit_requested

var _panel: Panel

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

	_panel = Panel.new()
	add_child(_panel)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.07, 0.09, 0.97)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.62, 0.5, 0.28, 0.95)
	sb.set_corner_radius_all(10)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 10
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -300.0
	_panel.offset_right = 300.0
	_panel.offset_top = -240.0
	_panel.offset_bottom = 240.0

	var vb := VBoxContainer.new()
	_panel.add_child(vb)
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.add_theme_constant_override("separation", 18)
	vb.offset_left = 32
	vb.offset_right = -32
	vb.offset_top = 28
	vb.offset_bottom = -28

	var title := Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font := load("res://assets/fonts/cinzel.ttf")
	if font:
		title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.55))
	vb.add_child(title)

	vb.add_child(_make_btn("Resume", func(): emit_signal("resume_requested")))
	vb.add_child(_make_btn("Music +/-", func(): _cycle_music()))
	var hint := Label.new()
	hint.text = "Controls: A attack-move · S stop · H hold · P patrol · Q/W/E/R hero abilities · Ctrl+1-5 control groups · F idle worker · Space jump to hero · F12 debug · wheel zoom · Z/C rotate camera"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hint.add_theme_color_override("font_color", Color(0.82, 0.82, 0.76))
	hint.add_theme_font_size_override("font_size", 16)
	if font:
		hint.add_theme_font_override("font", font)
	vb.add_child(hint)
	vb.add_child(_make_btn("Quit to Menu", func(): emit_signal("quit_requested")))

func _make_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 54)
	b.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	b.add_theme_color_override("font_hover_color", Color(1, 1, 0.9))
	b.add_theme_font_size_override("font_size", 22)
	b.pressed.connect(func():
		Sfx.play("select", -8.0)
		cb.call())
	return b

var _music_step := 3
func _cycle_music() -> void:
	_music_step = (_music_step + 1) % 5
	var v := float(_music_step) / 4.0
	AudioManager.set_bus_volume("Music", v)
	ProfileManager.update_setting("music_vol", v)

func set_shown(s: bool) -> void:
	visible = s
