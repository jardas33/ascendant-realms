extends Control
## Settings — audio, camera, accessibility, UI scale and game speed,
## plus a read-only controls reference and a Delete Hero option.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const PRESENTATION_THEME := "res://assets/ui/theme.tres"

const CONTROLS := [
	"Left-click: select    Drag box: multi-select    Shift+click/drag: add to selection",
	"Right-click: contextual move / attack / gather / rally / repair",
	"J: attack-move at cursor    K: stop    H: hold    P: patrol",
	"Q / T / E / R: hero abilities",
	"Ctrl+1-5: set control group    1-5: select group    Tab: select army",
	"F: select an idle worker    Space: focus hero",
	"Build mode: left-click to place    Right-click: cancel",
	"Arrow keys / screen edge: move camera    Z / C: rotate    Mouse wheel: zoom",
	"F3: debug overlay    Esc: pause",
]

func _ready() -> void:
	if ResourceLoader.exists(PRESENTATION_THEME):
		theme = load(PRESENTATION_THEME)
	_build()

func _title_font() -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font

func _body_font() -> Font:
	return ThemeDB.fallback_font

func _build() -> void:
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if ResourceLoader.exists(BG):
		bg.texture = load(BG)
	add_child(bg)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.05, 0.8)
	add_child(scrim)

	var title := Label.new()
	title.text = "Settings"
	title.add_theme_font_override("font", _title_font())
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.96, 0.9, 0.7))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 20.0
	title.offset_bottom = 68.0
	add_child(title)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 82.0
	scroll.offset_bottom = -80.0
	scroll.offset_left = 60.0
	scroll.offset_right = -60.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 12)
	scroll.add_child(v)

	var s := ProfileManager.settings()

	v.add_child(_heading("Audio"))
	v.add_child(_slider_row("Music Volume", 0.0, 1.0, 0.05, float(s.get("music_vol", 0.7)),
		func(val):
			ProfileManager.update_setting("music_vol", val)
			AudioManager.set_bus_volume("Music", val)))
	v.add_child(_slider_row("Sound Effects", 0.0, 1.0, 0.05, float(s.get("sfx_vol", 0.8)),
		func(val):
			ProfileManager.update_setting("sfx_vol", val)
			AudioManager.set_bus_volume("SFX", val)))

	v.add_child(_heading("Display"))
	v.add_child(_option_row("Window Mode", ["Windowed", "Fullscreen"], _display_mode_index(s.get("display_mode", "windowed")), func(index):
		var fullscreen: bool = index == 1
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		ProfileManager.update_setting("display_mode", "fullscreen" if fullscreen else "windowed")))
	v.add_child(_toggle_row("VSync", bool(s.get("vsync", true)), func(on):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if on else DisplayServer.VSYNC_DISABLED)
		ProfileManager.update_setting("vsync", on)))

	v.add_child(_heading("Camera"))
	v.add_child(_toggle_row("Edge Scrolling", bool(s.get("edge_scroll", true)),
		func(on): ProfileManager.update_setting("edge_scroll", on)))
	v.add_child(_slider_row("Camera Speed", 0.5, 2.0, 0.1, float(s.get("camera_speed", 1.0)),
		func(val): ProfileManager.update_setting("camera_speed", val)))
	v.add_child(_slider_row("Zoom Sensitivity", 0.5, 2.0, 0.1, float(s.get("zoom_sens", 1.0)),
		func(val): ProfileManager.update_setting("zoom_sens", val)))

	v.add_child(_heading("Accessibility"))
	v.add_child(_toggle_row("Reduce Flashing", bool(s.get("reduce_flash", false)),
		func(on): ProfileManager.update_setting("reduce_flash", on)))

	v.add_child(_heading("Gameplay"))

	# Controls reference
	v.add_child(_heading("Controls"))
	for line in CONTROLS:
		var l := Label.new()
		l.text = line
		l.add_theme_font_override("font", _body_font())
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82))
		l.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
		l.add_theme_constant_override("outline_size", 3)
		l.add_theme_font_size_override("font_size", 16)
		l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		v.add_child(l)

	# Footer
	var footer := HBoxContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -66.0
	footer.offset_bottom = -16.0
	footer.offset_left = 60.0
	footer.offset_right = -60.0
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 30)
	add_child(footer)
	footer.add_child(_button("Back", Color(0.96, 0.92, 0.8), func(): _goto("res://scenes/ui/main_menu.tscn")))
	if ProfileManager.has_hero():
		footer.add_child(_button("Delete Hero", Color(1.0, 0.6, 0.55), _on_delete))

# --- rows -----------------------------------------------------------------
func _heading(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _title_font())
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color(0.9, 0.78, 0.5))
	l.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	l.add_theme_constant_override("outline_size", 4)
	return l

func _slider_row(name: String, mn: float, mx: float, step: float, val: float, cb: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var lbl := Label.new()
	lbl.text = name
	lbl.custom_minimum_size = Vector2(240, 32)
	lbl.add_theme_font_override("font", _body_font())
	lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	lbl.add_theme_font_size_override("font_size", 16)
	row.add_child(lbl)
	var slider := HSlider.new()
	slider.min_value = mn
	slider.max_value = mx
	slider.step = step
	slider.value = val
	slider.custom_minimum_size = Vector2(320, 30)
	row.add_child(slider)
	var val_lbl := Label.new()
	val_lbl.custom_minimum_size = Vector2(70, 32)
	val_lbl.add_theme_font_override("font", _body_font())
	val_lbl.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	val_lbl.text = "%.2f" % val
	row.add_child(val_lbl)
	slider.value_changed.connect(func(v):
		val_lbl.text = "%.2f" % v
		cb.call(v))
	return row

func _toggle_row(name: String, on: bool, cb: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var lbl := Label.new()
	lbl.text = name
	lbl.custom_minimum_size = Vector2(240, 32)
	lbl.add_theme_font_override("font", _body_font())
	lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	lbl.add_theme_font_size_override("font_size", 16)
	row.add_child(lbl)
	var check := CheckButton.new()
	check.button_pressed = on
	check.add_theme_color_override("font_color", Color.WHITE)
	check.toggled.connect(func(pressed): Sfx.play("select"); cb.call(pressed))
	row.add_child(check)
	return row

func _option_row(name: String, options: Array[String], selected: int, cb: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var lbl := Label.new()
	lbl.text = name
	lbl.custom_minimum_size = Vector2(240, 32)
	lbl.add_theme_font_override("font", _body_font())
	lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	lbl.add_theme_font_size_override("font_size", 16)
	row.add_child(lbl)
	var menu := OptionButton.new()
	menu.custom_minimum_size = Vector2(320, 38)
	for option in options:
		menu.add_item(option)
	menu.select(clampi(selected, 0, options.size() - 1))
	menu.item_selected.connect(func(index): Sfx.play("select"); cb.call(index))
	row.add_child(menu)
	return row

func _display_mode_index(value: Variant) -> int:
	return 1 if String(value) == "fullscreen" else 0

func _button(text: String, col: Color, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.clip_text = false
	b.add_theme_font_override("font", _body_font())
	b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	b.custom_minimum_size = Vector2(220, 50)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", col)
	b.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
	b.pressed.connect(cb)
	return b

func _on_delete() -> void:
	Sfx.play("select")
	var dlg := ConfirmationDialog.new()
	dlg.title = "Delete Hero"
	dlg.dialog_text = "Permanently delete your hero and all progression? This cannot be undone."
	add_child(dlg)
	dlg.confirmed.connect(func():
		ProfileManager.wipe_hero()
		dlg.queue_free()
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))
	dlg.canceled.connect(func(): dlg.queue_free())
	dlg.popup_centered()

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)
