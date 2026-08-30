extends Control
## Hero Sheet — the hero's home. Attributes, level/XP, build summary,
## mastery panel, and gateways to the constellation, inventory and battle.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const PRESENTATION_THEME := "res://assets/ui/theme.tres"

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
	scrim.color = Color(0.02, 0.03, 0.05, 0.72)
	add_child(scrim)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 48.0
	scroll.offset_right = -48.0
	scroll.offset_top = 24.0
	scroll.offset_bottom = -24.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 14)
	scroll.add_child(_body)

func _refresh() -> void:
	if not is_instance_valid(_body):
		return
	for c in _body.get_children():
		c.queue_free()

	if not ProfileManager.has_hero():
		get_tree().change_scene_to_file("res://scenes/ui/hero_creation.tscn")
		return

	var h := ProfileManager.hero()

	# Header
	var header := Label.new()
	header.text = str(h.get("name", "Hero"))
	header.add_theme_font_override("font", _title_font())
	header.add_theme_font_size_override("font_size", 40)
	header.add_theme_color_override("font_color", Color(0.96, 0.9, 0.7))
	_body.add_child(header)

	var rd: Dictionary = GameData.get_race(str(h.get("race", "")))
	var sub := Label.new()
	sub.text = "%s  -  %s  -  Level %d" % [rd.get("name", h.get("race", "")), h.get("archetype", ""), int(h.get("level", 1))]
	sub.add_theme_font_override("font", _body_font())
	sub.add_theme_color_override("font_color", Color(0.85, 0.85, 0.78))
	sub.add_theme_font_size_override("font_size", 18)
	_body.add_child(sub)

	# XP bar
	var lvl := int(h.get("level", 1))
	var need := ProfileManager.xp_for_level(lvl)
	var xp := float(h.get("xp", 0.0))
	var xp_bar := ProgressBar.new()
	xp_bar.min_value = 0.0
	xp_bar.max_value = max(1.0, need)
	xp_bar.value = clamp(xp, 0.0, need)
	xp_bar.custom_minimum_size = Vector2(0, 24)
	xp_bar.show_percentage = false
	var xp_lbl := Label.new()
	xp_lbl.text = "XP: %d / %d" % [int(xp), int(need)]
	xp_lbl.add_theme_font_override("font", _body_font())
	xp_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.8))
	xp_lbl.add_theme_font_size_override("font_size", 16)
	_body.add_child(xp_lbl)
	_body.add_child(xp_bar)

	# Points banner
	var pts := Label.new()
	pts.text = "Skill Points: %d    Attribute Points: %d    Mastery: %d (%d pts)" % [
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
	progression_row.add_child(pts)
	var constellation_button := _nav_button("Skill Constellation", func(): _goto("res://scenes/ui/skill_tree.tscn"))
	constellation_button.custom_minimum_size = Vector2(250, 50)
	progression_row.add_child(constellation_button)
	_body.add_child(progression_row)

	_body.add_child(_hsep())

	# Two-column: attributes | build summary
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 30)
	cols.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_child(cols)

	# Attributes
	var attr_panel := VBoxContainer.new()
	attr_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attr_panel.add_theme_constant_override("separation", 6)
	cols.add_child(attr_panel)
	attr_panel.add_child(_heading("Attributes"))
	var attr_pts := int(h.get("attr_points", 0))
	var attrs: Dictionary = h.get("attributes", {})
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 6)
	attr_panel.add_child(grid)
	for a in ProfileManager.ATTRIBUTES:
		var nl := Label.new()
		nl.text = a.capitalize()
		nl.add_theme_font_override("font", _body_font())
		nl.custom_minimum_size = Vector2(150, 30)
		nl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
		grid.add_child(nl)
		var vl := Label.new()
		vl.text = str(int(attrs.get(a, 0)))
		vl.add_theme_font_override("font", _body_font())
		vl.custom_minimum_size = Vector2(50, 30)
		vl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vl.add_theme_color_override("font_color", Color.WHITE)
		grid.add_child(vl)
		if attr_pts > 0:
			var plus := Button.new()
			_label_button(plus, "+", Color(0.7, 1.0, 0.7))
			plus.custom_minimum_size = Vector2(40, 30)
			plus.focus_mode = Control.FOCUS_NONE
			plus.pressed.connect(func(): Sfx.play("select"); ProfileManager.spend_attribute(a))
			grid.add_child(plus)
		else:
			grid.add_child(Control.new())

	# Build summary
	var build_panel := VBoxContainer.new()
	build_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	build_panel.add_theme_constant_override("separation", 6)
	cols.add_child(build_panel)
	build_panel.add_child(_heading("Current Build"))
	var b := HeroProgression.compute(h)
	build_panel.add_child(_stat_line("Bonus Health", "+%d" % int(b.get("bonus_hp", 0))))
	build_panel.add_child(_stat_line("Bonus Damage", "+%d" % int(b.get("bonus_dmg", 0))))
	build_panel.add_child(_stat_line("Bonus Armor", "+%d" % int(b.get("bonus_armor", 0))))
	build_panel.add_child(_stat_line("Attack Speed", "+%d%%" % int(round(float(b.get("attack_speed", 0)) * 100.0))))
	build_panel.add_child(_stat_line("Max Mana", "%d" % int(b.get("max_mana", 0))))
	build_panel.add_child(_stat_line("Abilities Unlocked", str((b.get("abilities", {}) as Dictionary).size())))

	_body.add_child(_hsep())

	# Mastery panel
	_body.add_child(_heading("Mastery Constellations"))
	var m_pts := int(h.get("mastery_points", 0))
	var spent: Dictionary = h.get("mastery_spent", {})
	for con in HeroProgression.mastery_constellations():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var lbl := Label.new()
		lbl.text = "%s (Rank %d)  -  %s" % [con.get("name", ""), int(spent.get(con.get("id", ""), 0)), con.get("desc", "")]
		lbl.add_theme_font_override("font", _body_font())
		lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		lbl.custom_minimum_size = Vector2(560, 30)
		lbl.add_theme_color_override("font_color", Color(0.88, 0.88, 0.8))
		row.add_child(lbl)
		if m_pts > 0:
			var plus := Button.new()
			_label_button(plus, "+", Color(0.7, 1.0, 0.7))
			plus.custom_minimum_size = Vector2(40, 30)
			plus.focus_mode = Control.FOCUS_NONE
			plus.pressed.connect(func(): Sfx.play("select"); ProfileManager.spend_mastery(con.get("id", "")))
			row.add_child(plus)
		_body.add_child(row)

	_body.add_child(_hsep())

	# Navigation buttons
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 16)
	nav.alignment = BoxContainer.ALIGNMENT_CENTER
	_body.add_child(nav)
	nav.add_child(_nav_button("Inventory", func(): _goto("res://scenes/ui/inventory.tscn")))
	nav.add_child(_nav_button("Battle!", func(): _goto("res://scenes/ui/skirmish_setup.tscn")))
	nav.add_child(_nav_button("Back", func(): _goto("res://scenes/ui/main_menu.tscn")))

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)

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
	a.custom_minimum_size = Vector2(200, 26)
	a.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
	a.add_theme_font_size_override("font_size", 16)
	row.add_child(a)
	var b := Label.new()
	b.text = val
	b.add_theme_font_override("font", _body_font())
	b.add_theme_color_override("font_color", Color(0.6, 0.95, 0.7))
	b.add_theme_font_size_override("font_size", 16)
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
