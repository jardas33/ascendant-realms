extends Control
## Settings — audio, camera, accessibility, UI scale and game speed,
## plus a read-only controls reference and a Delete Hero option.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const PRESENTATION_THEME := "res://assets/ui/theme.tres"
const MENU_PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")

const KeyBinds := preload("res://scripts/game/key_binds.gd")

const CONTROLS := [
	["SELECTION", "Left-click selects. Drag selects a group. Hold Shift to add to selection."],
	["CONTEXT ORDER", "Right-click moves, attacks, gathers, rallies, or repairs. Right-click the minimap to send the selection across the map. Hold Shift to add a move or attack-move after the orders already given."],
	["UNIT ORDERS", "{cmd_attack} attack-move  ·  {cmd_stop} stop  ·  {cmd_hold} hold  ·  {cmd_patrol} patrol"],
	["HERO POWERS", "{ability_1} Rally  ·  {ability_2} Slam  ·  {ability_3} Charge  ·  {ability_4} Bolt  ·  {ability_5} Heal  ·  {ability_6} Roots  ·  {ability_7} Avatar (once learned). {ability_sig} is your people's signature spell; {ability_p1} and {ability_p2} are its spells learned at levels 10 and 25. Aim at the cursor."],
	["CONTROL GROUPS", "Ctrl+0–9 assign a group. 0–9 recall it; press twice to bring the camera to it. Shift adds it to the selection. {select_army} selects the army."],
	["QUICK SELECT", "{idle_worker} selects an idle worker. {cycle_hero} focuses the hero. Backspace jumps to the latest alert."],
	["CONSTRUCTION", "Left-click places a building; hold Shift to place several. Right-click cancels."],
	["VEINS", "Right-click a ringed vein with workers: they raise an outpost and go inside to work it. Right-click the outpost with more workers to send them in too. Expand it for more room and output."],
	["LUME JARS", "A violet diamond on the minimap is a buried jar. Keep your troops over it, alone, for six seconds to dig it up."],
	["CARAVAN", "Select your main hall to buy food, timber or stone with gold, or sell a surplus for gold. Buying raises the price; it eases back over time."],
	["LANDMARKS", "In the Age of Iron each people can raise one landmark with a power of its own: an oven that feeds, a gate that summons, a dial that strikes. Look for it in your workers' build list."],
	["UPGRADES", "The forge researches three ranks of weapons and armor and your people's own upgrades; the main hall researches economy and defense."],
	["YOUR HERO", "Kills made near your hero raise its battle level, up to five in a battle: a tenth more health and 8% more damage each. If it falls, the Lume raises it at your hall after 45 seconds or more, with half of that experience. Without a hall it cannot return."],
	["SIEGE", "From the Age of Lume most peoples can build an engine that outranges towers. Keep it behind your line: it is helpless up close."],
	["HEALERS", "Four peoples train a healer in their arcane hall. It mends the most wounded ally within reach while it stands, while it marches on attack-move and in a fight, and throws its own weak bolt only when nobody near it is hurt."],
	["HOLD-OUTS", "Some battles are won on the clock. The banner at the top right counts down: keep your hall standing until it runs out. You need not destroy anyone."],
	["REACH RINGS", "Select a Barrosan Clanhold, a healing grove or your hero to see its reach on the ground: gold Fortify, green healing, blue command aura."],
	["CAMERA","Arrows, W A S D or the screen edge move; hold the middle mouse button to drag. {cam_rot_l} / {cam_rot_r} rotate. Mouse wheel zooms."],
	["SYSTEM", "F1 shows this manual in battle. F3 toggles debug information. Esc pauses the battle."],
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
	# The painting breathes: a slow drift in and out, so the page never feels frozen.
	bg.resized.connect(func(): bg.pivot_offset = bg.size * 0.5)
	var drift := bg.create_tween().set_loops()
	drift.tween_property(bg, "scale", Vector2.ONE * 1.04, 30.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(bg, "scale", Vector2.ONE, 30.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
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
	# Keep the plates clear of the scroll bar so it never sits on a frame edge.
	var gutter := MarginContainer.new()
	gutter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gutter.add_theme_constant_override("margin_right", 16)
	gutter.add_theme_constant_override("margin_bottom", 8)
	scroll.add_child(gutter)
	gutter.add_child(columns)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 8)
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
	# Low drops shadows, ambient occlusion, grass and weather for weaker PCs;
	# Medium halves the grass and shortens shadows. Applies from the next match.
	var quality_names := ["low", "medium", "high"]
	display.add_child(_option_row("Graphics Quality", ["Low", "Medium", "High"], maxi(0, quality_names.find(String(s.get("graphics", "high")))), func(index):
		ProfileManager.update_setting("graphics", quality_names[index])))
	# Two settings about the battle, not the screen, had lived under Display.
	var battle := _group(left, "BATTLE")
	# Loot piles up over a long campaign; melt low tiers into experience on drop.
	var salvage_names := ["none", "common", "uncommon", "rare"]
	battle.add_child(_option_row("Auto-salvage Loot", ["Off", "Common", "Up to Uncommon", "Up to Rare"], maxi(0, salvage_names.find(String(s.get("auto_salvage", "none")))), func(index):
		ProfileManager.update_setting("auto_salvage", salvage_names[index])))
	# Floating damage numbers can crowd a big melee; some players prefer them off.
	battle.add_child(_toggle_row("Show Damage Numbers", bool(s.get("damage_numbers", true)), func(on):
		ProfileManager.update_setting("damage_numbers", on)))

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
	accessibility.add_child(_toggle_row("Reduce Screen Shake", bool(s.get("reduce_shake", false)),
		func(on): ProfileManager.update_setting("reduce_shake", on)))

	# Battle keys: click one, then press the key it should use.
	var keys := _group(left, "KEYS")
	KeyBinds.ensure_actions()
	_key_note = Label.new()
	_key_note.text = KEY_NOTE
	_key_note.add_theme_font_override("font", _body_font())
	_key_note.add_theme_font_size_override("font_size", 15)
	_key_note.add_theme_color_override("font_color", Color(0.78, 0.76, 0.68))
	_key_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	keys.add_child(_key_note)
	for key_group in KeyBinds.ACTIONS:
		for key_entry in key_group[1]:
			keys.add_child(_key_row(String(key_entry[0]), String(key_entry[1])))
	var reset_keys := Button.new()
	reset_keys.text = "Restore the Default Keys"
	reset_keys.custom_minimum_size = Vector2(0, 40)
	reset_keys.focus_mode = Control.FOCUS_NONE
	reset_keys.pressed.connect(func():
		Sfx.play("select")
		KeyBinds.reset()
		ProfileManager.update_setting("keybinds", {})
		_awaiting_action = ""
		_key_note.text = KEY_NOTE
		_refresh_key_buttons())
	keys.add_child(reset_keys)

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
		explanation.text = KeyBinds.fill(String(entry[1]))
		explanation.set_meta("raw", String(entry[1]))
		_manual_labels.append(explanation)
		explanation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		explanation.add_theme_font_override("font", _body_font())
		explanation.add_theme_font_size_override("font_size", 18)
		explanation.add_theme_color_override("font_color", Color(0.89, 0.89, 0.83))
		explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(explanation)
		var rule := ColorRect.new()
		rule.custom_minimum_size = Vector2(0, 2)
		rule.color = Color(0.78, 0.68, 0.48, 0.17)
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		manual.add_child(rule)

	# Footer
	# The scrolling page fades out above the footer instead of ending on a
	# hard cut through a panel.
	var fade := TextureRect.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(0.015, 0.022, 0.032, 0.0))
	grad.set_color(1, Color(0.015, 0.022, 0.032, 0.92))
	var gtex := GradientTexture2D.new()
	gtex.gradient = grad
	gtex.fill_from = Vector2(0, 0)
	gtex.fill_to = Vector2(0, 1)
	gtex.width = 4
	gtex.height = 64
	fade.texture = gtex
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	fade.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	fade.offset_top = -194.0
	fade.offset_bottom = -112.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade)
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
	content.add_theme_constant_override("separation", 2)
	panel.add_child(content)
	# Heading with a small drawn emblem for the section.
	var head_row := HBoxContainer.new()
	head_row.add_theme_constant_override("separation", 10)
	var icon := Control.new()
	icon.custom_minimum_size = Vector2(30, 30)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var kind := title_text
	icon.draw.connect(func(): _draw_section_emblem(icon, kind))
	head_row.add_child(icon)
	head_row.add_child(_heading(title_text))
	content.add_child(head_row)
	return content

func _draw_section_emblem(ci: Control, kind: String) -> void:
	var c := ci.size * 0.5
	var gold := Color(0.93, 0.76, 0.42)
	ci.draw_circle(c, 14.0, Color(0.05, 0.05, 0.06, 0.9))
	ci.draw_arc(c, 14.0, 0.0, TAU, 28, Color(gold, 0.8), 1.4, true)
	match kind:
		"AUDIO":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-7, -3), c + Vector2(-3, -3), c + Vector2(2, -7), c + Vector2(2, 7), c + Vector2(-3, 3), c + Vector2(-7, 3)]), gold)
			ci.draw_arc(c + Vector2(2, 0), 5.0, -0.8, 0.8, 8, gold, 1.4, true)
			ci.draw_arc(c + Vector2(2, 0), 8.5, -0.8, 0.8, 10, gold, 1.4, true)
		"DISPLAY":
			ci.draw_rect(Rect2(c + Vector2(-8, -6), Vector2(16, 11)), gold, false, 1.6)
			ci.draw_line(c + Vector2(-4, 8), c + Vector2(4, 8), gold, 1.6, true)
		"BATTLE":
			# Crossed swords.
			ci.draw_line(c + Vector2(-7, 7), c + Vector2(7, -7), gold, 1.8, true)
			ci.draw_line(c + Vector2(7, 7), c + Vector2(-7, -7), gold, 1.8, true)
			ci.draw_line(c + Vector2(-8, 3), c + Vector2(-3, 8), gold, 1.6, true)
			ci.draw_line(c + Vector2(8, 3), c + Vector2(3, 8), gold, 1.6, true)
		"CAMERA":
			ci.draw_arc(c, 6.0, 0.0, TAU, 20, gold, 1.6, true)
			ci.draw_circle(c, 2.4, gold)
			ci.draw_arc(c, 9.5, -2.6, -0.6, 12, gold, 1.4, true)
		_:
			ci.draw_circle(c + Vector2(0, -6), 2.4, gold)
			ci.draw_line(c + Vector2(-7, -2), c + Vector2(7, -2), gold, 1.6, true)
			ci.draw_line(c + Vector2(0, -2), c + Vector2(0, 4), gold, 1.6, true)
			ci.draw_line(c + Vector2(0, 4), c + Vector2(-4, 9), gold, 1.6, true)
			ci.draw_line(c + Vector2(0, 4), c + Vector2(4, 9), gold, 1.6, true)

const KEY_NOTE := "Click a key, then press the new one. Esc cancels. A key already in use swaps with the one you replace."
var _key_buttons := {}
var _awaiting_action := ""
var _key_note: Label
var _manual_labels: Array = []

func _key_row(action: String, title: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 42)
	row.add_theme_constant_override("separation", 14)
	var lbl := Label.new()
	lbl.text = title
	lbl.custom_minimum_size = Vector2(240, 32)
	lbl.add_theme_font_override("font", _body_font())
	lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	lbl.add_theme_font_size_override("font_size", 16)
	row.add_child(lbl)
	var b := Button.new()
	b.custom_minimum_size = Vector2(170, 36)
	b.focus_mode = Control.FOCUS_NONE
	b.text = KeyBinds.label(action)
	b.pressed.connect(func():
		Sfx.play("select")
		_awaiting_action = action
		_refresh_key_buttons())
	row.add_child(b)
	_key_buttons[action] = b
	return row

func _refresh_key_buttons() -> void:
	for action in _key_buttons:
		var b: Button = _key_buttons[action]
		b.text = "Press a key..." if action == _awaiting_action else KeyBinds.label(action)
	# The manual beside the list names the same keys.
	for l in _manual_labels:
		if is_instance_valid(l):
			l.text = KeyBinds.fill(String(l.get_meta("raw", l.text)))

func _input(event: InputEvent) -> void:
	if _awaiting_action == "" or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	get_viewport().set_input_as_handled()
	var code := int(event.physical_keycode) if int(event.physical_keycode) != 0 else int(event.keycode)
	if code == KEY_ESCAPE:
		_awaiting_action = ""
		_key_note.text = KEY_NOTE
	elif KeyBinds.is_reserved(code):
		_key_note.text = "%s has a fixed job in battle. Choose another key." % OS.get_keycode_string(code)
		Sfx.play_limited("refuse", -10.0, 250)
		return
	else:
		var swapped: String = KeyBinds.rebind(_awaiting_action, code)
		_key_note.text = ("%s now uses %s." % [KeyBinds.name_of(swapped), KeyBinds.label(swapped)]) if swapped != "" else KEY_NOTE
		ProfileManager.update_setting("keybinds", KeyBinds.saved())
		Sfx.play("select")
		_awaiting_action = ""
	_refresh_key_buttons()

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
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(slider)
	var val_lbl := Label.new()
	val_lbl.custom_minimum_size = Vector2(70, 32)
	val_lbl.add_theme_font_override("font", _body_font())
	val_lbl.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	val_lbl.add_theme_font_size_override("font_size", 18)
	# Volumes read as percentages, speeds as multipliers.
	var fmt := func(x: float) -> String: return ("%d%%" % roundi(x * 100.0)) if mx <= 1.0 else ("%.1f×" % x)
	val_lbl.text = fmt.call(val)
	row.add_child(val_lbl)
	slider.value_changed.connect(func(v):
		val_lbl.text = fmt.call(v)
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
	b.add_theme_font_override("font", _title_font())
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
	var dlg: Control = load("res://scripts/ui/gilt_confirm.gd").ask(self, "Delete Hero", "Permanently delete your hero and all progression? This cannot be undone.", "Delete Forever", true)
	dlg.confirmed.connect(func():
		ProfileManager.wipe_hero()
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)
