extends Control
## Hero Sheet — the hero's home. Attributes, level/XP, build summary,
## mastery panel, and gateways to the constellation, inventory and battle.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const PRESENTATION_THEME := "res://assets/ui/theme.tres"
const HERO_PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")

var _body: VBoxContainer

func _ready() -> void:
	if ResourceLoader.exists(PRESENTATION_THEME):
		theme = load(PRESENTATION_THEME)
	_build_static()
	ProfileManager.profile_changed.connect(_refresh)
	_refresh()

func _title_font() -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font

func _body_font() -> Font:
	return ThemeDB.fallback_font

func _build_static() -> void:
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if ResourceLoader.exists(BG):
		bg.texture = load(BG)
	add_child(bg)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.05, 0.65)
	add_child(scrim)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 64.0
	scroll.offset_right = -64.0
	scroll.offset_top = 30.0
	scroll.offset_bottom = -126.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 18)
	scroll.add_child(_body)

	var footer_back := ColorRect.new()
	footer_back.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer_back.offset_top = -112.0
	footer_back.offset_bottom = 0.0
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
	var nav := HBoxContainer.new()
	nav.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	nav.offset_top = -91.0
	nav.offset_bottom = -20.0
	nav.add_theme_constant_override("separation", 20)
	nav.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(nav)
	nav.add_child(_nav_button("Inventory", func(): _goto("res://scenes/ui/inventory.tscn")))
	nav.add_child(_nav_button("Battle!", func(): _goto("res://scenes/ui/skirmish_setup.tscn")))
	nav.add_child(_nav_button("Back", func(): _goto("res://scenes/ui/main_menu.tscn")))

func _refresh() -> void:
	if not is_instance_valid(_body):
		return
	for c in _body.get_children():
		c.queue_free()

	if not ProfileManager.has_hero():
		get_tree().change_scene_to_file("res://scenes/ui/hero_creation.tscn")
		return

	var h := ProfileManager.hero()
	var rd: Dictionary = GameData.get_race(str(h.get("race", "")))
	var hero_unit_id := str(rd.get("hero", ""))
	var hero_definition: Dictionary = GameData.get_unit(hero_unit_id) if not hero_unit_id.is_empty() else {}
	var hero_portrait_path := str(hero_definition.get("portrait", ""))
	var has_exact_hero_portrait := not hero_unit_id.is_empty() and not hero_portrait_path.is_empty() and ResourceLoader.exists(hero_portrait_path)

	# Character dossier. The exact race portrait remains the focal point while
	# XP and spendable points stay visible beside it.
	var identity_plate := _plate()
	_body.add_child(identity_plate)
	var identity_row := HBoxContainer.new()
	identity_row.add_theme_constant_override("separation", 26)
	identity_plate.add_child(identity_row)
	if has_exact_hero_portrait:
		var portrait := EntityPortraitView.new()
		portrait.name = "HeroPortrait"
		portrait.custom_minimum_size = Vector2(196, 196)
		portrait.configure_definition(hero_definition, false)
		identity_row.add_child(portrait)
	var identity := VBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.add_theme_constant_override("separation", 8)
	var header := Label.new()
	header.text = str(h.get("name", "Hero")).to_upper()
	header.add_theme_font_override("font", _title_font())
	header.add_theme_font_size_override("font_size", 44)
	header.add_theme_color_override("font_color", Color(0.96, 0.9, 0.7))
	identity.add_child(header)
	var sub := Label.new()
	sub.text = "%s  /  %s  /  LEVEL %d" % [str(rd.get("name", h.get("race", ""))).to_upper(), str(h.get("archetype", "")).to_upper(), int(h.get("level", 1))]
	sub.add_theme_font_override("font", _body_font())
	sub.add_theme_color_override("font_color", Color(0.85, 0.85, 0.78))
	sub.add_theme_font_size_override("font_size", 20)
	identity.add_child(sub)
	identity_row.add_child(identity)

	var lvl := int(h.get("level", 1))
	var need := ProfileManager.xp_for_level(lvl)
	var xp := float(h.get("xp", 0.0))
	var xp_lbl := Label.new()
	xp_lbl.text = "EXPERIENCE   %d / %d" % [int(xp), int(need)]
	xp_lbl.add_theme_font_override("font", _body_font())
	xp_lbl.add_theme_color_override("font_color", Color(0.91, 0.84, 0.65))
	xp_lbl.add_theme_font_size_override("font_size", 16)
	identity.add_child(xp_lbl)
	var xp_bar := ProgressBar.new()
	xp_bar.min_value = 0.0
	xp_bar.max_value = max(1.0, need)
	xp_bar.value = clamp(xp, 0.0, need)
	xp_bar.custom_minimum_size = Vector2(0, 19)
	xp_bar.show_percentage = false
	identity.add_child(xp_bar)

	var pts := Label.new()
	pts.text = "%d SKILL POINTS    ·    %d ATTRIBUTE POINTS    ·    MASTERY %d (%d POINTS)" % [
		int(h.get("skill_points", 0)), int(h.get("attr_points", 0)),
		int(h.get("mastery", 0)), int(h.get("mastery_points", 0))]
	pts.add_theme_font_override("font", _body_font())
	pts.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	pts.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	pts.add_theme_constant_override("outline_size", 3)
	pts.add_theme_font_size_override("font_size", 17)
	var progression_row := HBoxContainer.new()
	progression_row.add_theme_constant_override("separation", 18)
	progression_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progression_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	progression_row.add_child(pts)
	var constellation_button := _nav_button("Skill Constellation", func(): _goto("res://scenes/ui/skill_tree.tscn"))
	constellation_button.custom_minimum_size = Vector2(250, 46)
	progression_row.add_child(constellation_button)
	identity.add_child(progression_row)

	# Two progression leaves: spend attributes on the left, inspect the
	# resulting build and mastery constellations on the right.
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 18)
	cols.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_child(cols)

	var attr_plate := _plate()
	attr_plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols.add_child(attr_plate)
	var attr_panel := VBoxContainer.new()
	attr_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attr_panel.add_theme_constant_override("separation", 13)
	attr_plate.add_child(attr_panel)
	attr_panel.add_child(_heading("ATTRIBUTES"))
	var attr_pts := int(h.get("attr_points", 0))
	var attrs: Dictionary = h.get("attributes", {})
	var attr_list := VBoxContainer.new()
	attr_list.add_theme_constant_override("separation", 0)
	attr_panel.add_child(attr_list)
	for a in ProfileManager.ATTRIBUTES:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 57)
		row.add_theme_constant_override("separation", 18)
		attr_list.add_child(row)
		var nl := Label.new()
		nl.text = a.capitalize().to_upper()
		nl.add_theme_font_override("font", _body_font())
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
		nl.add_theme_font_size_override("font_size", 19)
		row.add_child(nl)
		var vl := Label.new()
		vl.text = str(int(attrs.get(a, 0)))
		vl.add_theme_font_override("font", _body_font())
		vl.custom_minimum_size = Vector2(60, 40)
		vl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vl.add_theme_color_override("font_color", Color(0.96, 0.84, 0.57))
		vl.add_theme_font_size_override("font_size", 20)
		row.add_child(vl)
		if attr_pts > 0:
			var plus := Button.new()
			_label_button(plus, "+", Color(0.7, 1.0, 0.7))
			plus.custom_minimum_size = Vector2(46, 40)
			plus.focus_mode = Control.FOCUS_NONE
			plus.pressed.connect(func(): Sfx.play("select"); ProfileManager.spend_attribute(a))
			row.add_child(plus)
		else:
			var blank := Control.new()
			blank.custom_minimum_size = Vector2(46, 40)
			row.add_child(blank)
		var rule := ColorRect.new()
		rule.custom_minimum_size = Vector2(0, 1)
		rule.color = Color(0.78, 0.68, 0.48, 0.22)
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		attr_list.add_child(rule)

	var right_plate := _plate()
	right_plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols.add_child(right_plate)
	var right_panel := VBoxContainer.new()
	right_panel.add_theme_constant_override("separation", 12)
	right_plate.add_child(right_panel)

	var build_panel := VBoxContainer.new()
	build_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	build_panel.add_theme_constant_override("separation", 6)
	right_panel.add_child(build_panel)
	build_panel.add_child(_heading("CURRENT BUILD"))
	var b := HeroProgression.compute(h)
	build_panel.add_child(_stat_line("Bonus Health", "+%d" % int(b.get("bonus_hp", 0))))
	build_panel.add_child(_stat_line("Bonus Damage", "+%d" % int(b.get("bonus_dmg", 0))))
	build_panel.add_child(_stat_line("Bonus Armor", "+%d" % int(b.get("bonus_armor", 0))))
	build_panel.add_child(_stat_line("Attack Speed", "+%d%%" % int(round(float(b.get("attack_speed", 0)) * 100.0))))
	build_panel.add_child(_stat_line("Max Mana", "%d" % int(b.get("max_mana", 0))))
	build_panel.add_child(_stat_line("Abilities Unlocked", str((b.get("abilities", {}) as Dictionary).size())))

	right_panel.add_child(_hsep())

	# Mastery panel
	right_panel.add_child(_heading("MASTERY CONSTELLATIONS"))
	var m_pts := int(h.get("mastery_points", 0))
	var spent: Dictionary = h.get("mastery_spent", {})
	for con in HeroProgression.mastery_constellations():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var lbl := Label.new()
		lbl.text = "%s  /  RANK %d   ·   %s" % [str(con.get("name", "")).to_upper(), int(spent.get(con.get("id", ""), 0)), con.get("desc", "")]
		lbl.add_theme_font_override("font", _body_font())
		lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		lbl.custom_minimum_size = Vector2(560, 40)
		lbl.add_theme_color_override("font_color", Color(0.88, 0.88, 0.8))
		lbl.add_theme_font_size_override("font_size", 17)
		row.add_child(lbl)
		if m_pts > 0:
			var plus := Button.new()
			_label_button(plus, "+", Color(0.7, 1.0, 0.7))
			plus.custom_minimum_size = Vector2(46, 40)
			plus.focus_mode = Control.FOCUS_NONE
			plus.pressed.connect(func(): Sfx.play("select"); ProfileManager.spend_mastery(con.get("id", "")))
			row.add_child(plus)
		right_panel.add_child(row)

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)

func _plate() -> PanelContainer:
	var panel: PanelContainer = HERO_PLATE_SCRIPT.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 24.0
	style.content_margin_bottom = 24.0
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _heading(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _title_font())
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color(0.9, 0.78, 0.5))
	l.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	l.add_theme_constant_override("outline_size", 4)
	return l

func _stat_line(name: String, val: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	var a := Label.new()
	a.text = name
	a.add_theme_font_override("font", _body_font())
	a.custom_minimum_size = Vector2(230, 30)
	a.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
	a.add_theme_font_size_override("font_size", 18)
	row.add_child(a)
	var b := Label.new()
	b.text = val
	b.add_theme_font_override("font", _body_font())
	b.add_theme_color_override("font_color", Color(0.6, 0.95, 0.7))
	b.add_theme_font_size_override("font_size", 19)
	row.add_child(b)
	return row

func _hsep() -> HSeparator:
	return HSeparator.new()

func _label_button(b: Button, text: String, col: Color) -> void:
	b.text = text
	b.clip_text = false
	b.add_theme_font_override("font", _body_font())
	b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	b.add_theme_color_override("font_color", col)
	b.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))

func _nav_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(230, 50)
	b.focus_mode = Control.FOCUS_NONE
	_label_button(b, text, Color(0.96, 0.92, 0.8))
	b.pressed.connect(cb)
	return b
