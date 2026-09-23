extends Control
## Settings — audio, camera, accessibility, UI scale and game speed,
## plus a read-only controls reference and a Delete Hero option.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const PRESENTATION_THEME := "res://assets/ui/theme.tres"
const MENU_PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")

const CONTROLS := [
	["SELECTION", "Left-click selects. Drag selects a group. Hold Shift to add to selection."],
	["CONTEXT ORDER", "Right-click moves, attacks, gathers, rallies, or repairs."],
	["UNIT ORDERS", "J attack-move  ·  K stop  ·  H hold  ·  P patrol"],
	["HERO POWERS", "Q / T / E / R cast hero abilities."],
	["CONTROL GROUPS", "Ctrl+1–5 assign a group. 1–5 recall it. Tab selects the army."],
	["QUICK SELECT", "F selects an idle worker. Space focuses the hero."],
	["CONSTRUCTION", "Left-click places a building. Right-click cancels."],
	["CAMERA", "Arrows or screen edge move. Z / C rotate. Mouse wheel zooms."],
	["SYSTEM", "F3 toggles debug information. Esc pauses the battle."],
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
	scrim.color = Color(0.02, 0.03, 0.05, 0.67)
	add_child(scrim)

	var title := Label.new()
	title.text = "SETTINGS"
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
	scroll.offset_top = 100.0
	scroll.offset_bottom = -130.0
	scroll.offset_left = 64.0
	scroll.offset_right = -64.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var columns := HBoxContainer.new()
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 18)
	scroll.add_child(columns)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 16)
	columns.add_child(left)

	var s := ProfileManager.settings()

	var audio := _group(left, "AUDIO")
	audio.add_child(_slider_row("Music Volume", 0.0, 1.0, 0.05, float(s.get("music_vol", 0.7)),
		func(val):
			ProfileManager.update_setting("music_vol", val)
			AudioManager.set_bus_volume("Music", val)))
	audio.add_child(_slider_row("Sound Effects", 0.0, 1.0, 0.05, float(s.get("sfx_vol", 0.8)),
		func(val):
			ProfileManager.update_setting("sfx_vol", val)
			AudioManager.set_bus_volume("SFX", val)))

	var display := _group(left, "DISPLAY")
	display.add_child(_option_row("Window Mode", ["Windowed", "Fullscreen"], _display_mode_index(s.get("display_mode", "windowed")), func(index):
		var fullscreen: bool = index == 1
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		ProfileManager.update_setting("display_mode", "fullscreen" if fullscreen else "windowed")))
	display.add_child(_toggle_row("VSync", bool(s.get("vsync", true)), func(on):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if on else DisplayServer.VSYNC_DISABLED)
		ProfileManager.update_setting("vsync", on)))

	var camera := _group(left, "CAMERA")
	camera.add_child(_toggle_row("Edge Scrolling", bool(s.get("edge_scroll", true)),
		func(on): ProfileManager.update_setting("edge_scroll", on)))
	camera.add_child(_slider_row("Camera Speed", 0.5, 2.0, 0.1, float(s.get("camera_speed", 1.0)),
		func(val): ProfileManager.update_setting("camera_speed", val)))
	camera.add_child(_slider_row("Zoom Sensitivity", 0.5, 2.0, 0.1, float(s.get("zoom_sens", 1.0)),
		func(val): ProfileManager.update_setting("zoom_sens", val)))

	var accessibility := _group(left, "ACCESSIBILITY")
	accessibility.add_child(_toggle_row("Reduce Flashing", bool(s.get("reduce_flash", false)),
		func(on): ProfileManager.update_setting("reduce_flash", on)))

	var manual_plate := _plate()
	manual_plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(manual_plate)
	var manual := VBoxContainer.new()
	manual.add_theme_constant_override("separation", 10)
	manual_plate.add_child(manual)
	manual.add_child(_heading("FIELD MANUAL"))
	for entry in CONTROLS:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 60)
		row.add_theme_constant_override("separation", 18)
		manual.add_child(row)
		var key := Label.new()
		key.text = entry[0]
		key.custom_minimum_size = Vector2(176, 0)
		key.add_theme_font_override("font", _body_font())
		key.add_theme_font_size_override("font_size", 17)
		key.add_theme_color_override("font_color", Color(0.94, 0.78, 0.46))
		row.add_child(key)
		var explanation := Label.new()
		explanation.text = entry[1]
		explanation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		explanation.add_theme_font_override("font", _body_font())
		explanation.add_theme_font_size_override("font_size", 18)
		explanation.add_theme_color_override("font_color", Color(0.89, 0.89, 0.83))
		explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(explanation)
		var rule := ColorRect.new()
		rule.custom_minimum_size = Vector2(0, 1)
		rule.color = Color(0.78, 0.68, 0.48, 0.17)
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		manual.add_child(rule)

	# Footer
	var footer_back := ColorRect.new()
	footer_back.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer_back.offset_top = -112.0
	footer_back.color = Color(0.015, 0.022, 0.032, 0.91)
	footer_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(footer_back)
	var footer_rule := ColorRect.new()
	footer_rule.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer_rule.offset_top = -112.0
	footer_rule.offset_bottom = -110.0
	footer_rule.color = Color(0.79, 0.64, 0.38, 0.65)
	footer_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(footer_rule)
	var footer := HBoxContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -91.0
	footer.offset_bottom = -20.0
	footer.offset_left = 60.0
	footer.offset_right = -60.0
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 30)
	add_child(footer)
	footer.add_child(_button("Back", Color(0.96, 0.92, 0.8), func(): _goto("res://scenes/ui/main_menu.tscn")))
	if ProfileManager.has_hero():
		footer.add_child(_button("Delete Hero", Color(1.0, 0.6, 0.55), _on_delete))

# --- rows -----------------------------------------------------------------
func _plate() -> PanelContainer:
	var panel: PanelContainer = MENU_PLATE_SCRIPT.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 23.0
	style.content_margin_bottom = 23.0
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _group(parent: VBoxContainer, title_text: String) -> VBoxContainer:
	var panel := _plate()
	parent.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)
	content.add_child(_heading(title_text))
	return content

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
	row.custom_minimum_size = Vector2(0, 48)
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
	val_lbl.add_theme_font_size_override("font_size", 18)
	val_lbl.text = "%.2f" % val
	row.add_child(val_lbl)
	slider.value_changed.connect(func(v):
		val_lbl.text = "%.2f" % v
		cb.call(v))
	return row

func _toggle_row(name: String, on: bool, cb: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 48)
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
	row.custom_minimum_size = Vector2(0, 48)
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
