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
	# Deeds: the hero's title and every track's tier (AchievementDefs).
	var deeds: Dictionary = h.get("deeds", {})
	var ach = load("res://scripts/game/achievement_defs.gd")
	var parts: Array = []
	var next_goals: Array = []
	for t in ach.TRACKS:
		var tier := int(deeds.get(t["id"], 0))
		var nxt: int = ach.goal(t, tier + 1)
		parts.append("%s %d" % [String(t["name"]).to_upper(), tier])
		next_goals.append("%s: next tier at %d" % [String(t["name"]), nxt])
	var deeds_line := Label.new()
	deeds_line.text = ("%s    ·    " % String(h.get("title", "")).to_upper() if String(h.get("title", "")) != "" else "") + "DEEDS  " + "  ·  ".join(parts)
	deeds_line.add_theme_font_override("font", _body_font())
	deeds_line.add_theme_color_override("font_color", Color(1.0, 0.86, 0.5))
	deeds_line.add_theme_font_size_override("font_size", 14)
	deeds_line.tooltip_text = "
".join(next_goals)
	deeds_line.mouse_filter = Control.MOUSE_FILTER_PASS
	deeds_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	deeds_line.custom_minimum_size = Vector2(1000, 0)
	identity.add_child(deeds_line)
	var saga_state: Dictionary = ProfileManager.saga()
	var saga_line := Label.new()
	saga_line.text = "THE SAGA   %d / %d CHAPTERS    ·    WINE OF THE DEAD %d / 7    ·    HEROIC LAURELS %d    ·    RETINUE %d / %d" % [saga_state["cleared"].size(), load("res://scripts/game/campaign_defs.gd").CHAPTERS.size(), saga_state["jars"].size(), saga_state["heroic"].size(), saga_state["retinue"].size(), ProfileManager.retinue_cap()]
	var ret_names: Array = []
	for entry in saga_state.get("retinue", []):
		var label_name := String(entry.get("name", ""))
		if label_name == "":
			label_name = String(GameData.get_unit(String(entry.get("id", ""))).get("name", entry.get("id", "")))
		ret_names.append("%s (rank %d)" % [label_name, int(entry.get("vet", 1))])
	if not ret_names.is_empty():
		var ret_line := Label.new()
		ret_line.text = "RETINUE  " + "  ·  ".join(ret_names)
		ret_line.add_theme_font_override("font", _body_font())
		ret_line.add_theme_color_override("font_color", Color(0.78, 0.86, 0.66))
		ret_line.add_theme_font_size_override("font_size", 14)
		ret_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ret_line.custom_minimum_size = Vector2(1000, 0)
		identity.add_child(ret_line)
	var st: Dictionary = ProfileManager.data.get("stats", {})
	var record_line := Label.new()
	record_line.text = "ENDLESS ROAD  STAGE %d    ·    BATTLES %d    ·    VICTORIES %d    ·    FOES SLAIN %d    ·    ELITES %d    ·    TYRANTS %d" % [ProfileManager.endless_best(), int(st.get("battles", 0)), int(st.get("victories", 0)), int(st.get("units_killed", 0)), int(st.get("elites_slain", 0)), int(st.get("tyrants_slain", 0))]
	var wk_best := ProfileManager.endless_fastest_key("w%d" % load("res://scripts/game/endless_defs.gd").week_number())
	if wk_best > 0.0:
		record_line.text += "    ·    ROAD OF THE WEEK %d:%02d" % [int(wk_best) / 60, int(wk_best) % 60]
	record_line.add_theme_font_override("font", _body_font())
	record_line.add_theme_color_override("font_color", Color(0.98, 0.80, 0.45))
	record_line.add_theme_font_size_override("font_size", 16)
	identity.add_child(record_line)
	saga_line.add_theme_font_override("font", _body_font())
	saga_line.add_theme_color_override("font_color", Color(0.86, 0.72, 0.95))
	saga_line.add_theme_font_size_override("font_size", 16)
	identity.add_child(saga_line)
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
	# One number to watch grow: damage output times survivability.
	var power := HeroProgression.power(h)
	build_panel.add_child(_stat_line("Hero Power", str(power)))
	# Talent and power effects that have no stat line of their own.
	var extras: Array = []
	if float(b.get("hp_mult", 0.0)) > 0.0:
		extras.append("+%d%% health" % int(float(b["hp_mult"]) * 100.0))
	if float(b.get("execute_bonus", 0.0)) > 0.0:
		extras.append("+%d%% vs wounded" % int(float(b["execute_bonus"]) * 100.0))
	if float(b.get("thorns", 0.0)) > 0.0:
		extras.append("%d%% thorns" % int(float(b["thorns"]) * 100.0))
	if float(b.get("spell_power", 0.0)) > 0.0:
		extras.append("+%d%% spell power" % int(float(b["spell_power"]) * 100.0))
	if not extras.is_empty():
		build_panel.add_child(_stat_line("Talents", ", ".join(extras)))
	var syns: Array = load("res://scripts/game/talent_defs.gd").active_synergies(h.get("talents", {}))
	if not syns.is_empty():
		build_panel.add_child(_stat_line("Synergies", ", ".join(syns.map(func(x): return String(x["name"])))))
	var flag_names := {"cleave": "Cleave", "lifesteal": "Lifesteal", "execute": "Execute", "last_stand": "Last Stand", "unstoppable": "Unstoppable", "thornmail": "Thornmail", "chain_lightning": "Stormcall", "haste_on_kill": "Bloodrush", "quickcast": "Quickcast", "mana_font": "Mana Font"}
	var powers: Array = []
	for f in b.get("flags", {}):
		if flag_names.has(f):
			var v = b["flags"][f]
			powers.append("%s %d%%" % [flag_names[f], int(float(v) * 100.0)] if f == "lifesteal" else String(flag_names[f]))
	if not powers.is_empty():
		build_panel.add_child(_stat_line("Powers", ", ".join(powers)))

	right_panel.add_child(_hsep())

	# Talents: a choice of three every tenth level, stacking forever.
	var TalentDefs = load("res://scripts/game/talent_defs.gd")
	var t_pts: int = ProfileManager.talent_points()
	var owned: Array = []
	var tal = h.get("talents", {})
	if tal is Dictionary:
		for tid in tal:
			owned.append("%s %d" % [String(TalentDefs.find(String(tid)).get("name", tid)), int(tal[tid])])
	right_panel.add_child(_heading("TALENTS"))
	if not owned.is_empty():
		var t_reset := Button.new()
		_label_button(t_reset, "Reset Talents (free)", Color(0.9, 0.85, 0.7))
		t_reset.custom_minimum_size = Vector2(220, 36)
		t_reset.focus_mode = Control.FOCUS_NONE
		t_reset.pressed.connect(func(): Sfx.play("select"); ProfileManager.respec_talents())
		right_panel.add_child(t_reset)
	var next_at: int = (int(h.get("level", 1)) / TalentDefs.EVERY_LEVELS + 1) * TalentDefs.EVERY_LEVELS
	right_panel.add_child(_stat_line("Taken", ", ".join(owned) if not owned.is_empty() else "None yet. A choice every %d levels." % TalentDefs.EVERY_LEVELS))
	# Synergies within reach: pairs where one of the two talents is at rank 1+.
	var near_syn: Array = []
	var tl: Dictionary = tal if tal is Dictionary else {}
	for syn in TalentDefs.SYNERGIES:
		var a := int(tl.get(syn["needs"][0], 0))
		var b2 := int(tl.get(syn["needs"][1], 0))
		if (a >= 3 and b2 >= 3) or (a == 0 and b2 == 0):
			continue
		near_syn.append("%s (%s %d/3, %s %d/3)" % [String(syn["name"]), String(TalentDefs.find(syn["needs"][0]).get("name", "")), mini(a, 3), String(TalentDefs.find(syn["needs"][1]).get("name", "")), mini(b2, 3)])
	if not near_syn.is_empty():
		var ns := _stat_line("Synergies ahead", ", ".join(near_syn.slice(0, 2)))
		ns.tooltip_text = "
".join(TalentDefs.SYNERGIES.map(func(x): return "%s: %s + %s at rank 3. %s" % [x["name"], TalentDefs.find(x["needs"][0]).get("name", ""), TalentDefs.find(x["needs"][1]).get("name", ""), x["desc"]]))
		right_panel.add_child(ns)
	if t_pts > 0:
		right_panel.add_child(_stat_line("Choose one", "%d pick%s waiting" % [t_pts, "" if t_pts == 1 else "s"]))
		var trow := HBoxContainer.new()
		trow.add_theme_constant_override("separation", 10)
		for tid in ProfileManager.talent_offer():
			var td: Dictionary = TalentDefs.find(String(tid))
			var tb := Button.new()
			_label_button(tb, String(td.get("name", tid)), Color(1.0, 0.86, 0.5))
			tb.tooltip_text = String(td.get("desc", ""))
			tb.custom_minimum_size = Vector2(190, 40)
			tb.focus_mode = Control.FOCUS_NONE
			tb.pressed.connect(func(): Sfx.play("levelup"); ProfileManager.pick_talent(String(tid)))
			trow.add_child(tb)
		right_panel.add_child(trow)
		var descs: Array = []
		for tid in ProfileManager.talent_offer():
			var td2: Dictionary = TalentDefs.find(String(tid))
			descs.append("%s: %s" % [String(td2.get("name", tid)), String(td2.get("desc", ""))])
		var dl := Label.new()
		dl.text = "
".join(descs)
		dl.add_theme_font_override("font", _body_font())
		dl.add_theme_font_size_override("font_size", 15)
		dl.add_theme_color_override("font_color", Color(0.8, 0.78, 0.7))
		right_panel.add_child(dl)
	else:
		right_panel.add_child(_stat_line("Next choice", "Level %d" % next_at))
	right_panel.add_child(_hsep())

	# Mastery panel
	right_panel.add_child(_heading("MASTERY CONSTELLATIONS"))
	if not (h.get("mastery_spent", {}) as Dictionary).is_empty():
		var reset := Button.new()
		_label_button(reset, "Reset Mastery (free)", Color(0.9, 0.85, 0.7))
		reset.custom_minimum_size = Vector2(220, 36)
		reset.focus_mode = Control.FOCUS_NONE
		reset.pressed.connect(func(): Sfx.play("select"); ProfileManager.respec_mastery())
		right_panel.add_child(reset)
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
			if m_pts >= 5:
				var plus5 := Button.new()
				_label_button(plus5, "+5", Color(0.7, 1.0, 0.7))
				plus5.custom_minimum_size = Vector2(56, 40)
				plus5.focus_mode = Control.FOCUS_NONE
				plus5.pressed.connect(func():
					Sfx.play("select")
					for i in 5:
						ProfileManager.spend_mastery(con.get("id", "")))
				row.add_child(plus5)
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
	# Every number explains itself on hover.
	if STAT_HELP.has(name):
		row.tooltip_text = String(STAT_HELP[name])
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		a.mouse_filter = Control.MOUSE_FILTER_PASS
		a.tooltip_text = row.tooltip_text
	return row

const STAT_HELP := {
	"Bonus Health": "Extra health from Endurance, Might, gear, sets, Fortitude mastery and talents.",
	"Bonus Damage": "Extra damage per blow from Might, Intellect, gear, sets and Warfare mastery. Spells scale with it too.",
	"Bonus Armor": "Flat armour from Willpower, gear and Iron Will. Each point blunts every blow.",
	"Attack Speed": "Faster attacks from Agility, gear, Celerity mastery and Swift Blade.",
	"Max Mana": "Mana for spells: Intellect, gear, Attunement mastery and Lume Well.",
	"Abilities Unlocked": "Spells learned on the skill constellation. Cast them with Y, U and V in battle.",
	"Hero Power": "One number to watch grow: damage output times survivability, with every bonus counted.",
	"Talents": "Effects from talents picked every tenth level. They stack without end.",
	"Powers": "Legendary powers from equipped items.",
	"Taken": "Talents already picked, with their ranks.",
}

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
