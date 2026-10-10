extends "res://scripts/ui/hud.gd"
## Reliquary battle HUD (art direction A, docs/claude/UI_ART_PILLARS_R1.md).
##
## Every behaviour, signal and data handler stays in hud.gd. This subclass only
## replaces how the HUD is built and laid out: one forged deck across the
## bottom with the portrait medallion breaking out of it, a ribbon hung from
## the top edge around the Age medallion, quiet text on dark matter, and light
## that means state. Peoples and Ages are token skins from RqKit.

const RQ_TILE := preload("res://scripts/ui/reliquary/rq_tile.gd")
const RQ_DECK := preload("res://scripts/ui/reliquary/rq_deck.gd")
const RQ_RIBBON := preload("res://scripts/ui/reliquary/rq_ribbon.gd")
const RQ_MEDALLION := preload("res://scripts/ui/reliquary/rq_medallion.gd")
const RQ_BAR := preload("res://scripts/ui/reliquary/rq_bar.gd")
const RQ_TOOLTIP := preload("res://scripts/ui/reliquary/rq_tooltip.gd")
const RQ_SITE := preload("res://scripts/ui/reliquary/rq_site.gd")

var _rq_tooltip_title := ""

# Layout at the 1920x1080 reference canvas.
const RQ_DECK_HEIGHT := 172.0
const RQ_DECK_WIDTH := 1210.0
const RQ_SELECTION_SPAN := 640.0
const RQ_MEDALLION_SIZE := 206.0
const RQ_RIBBON_HEIGHT := 54.0
const RQ_RIBBON_LEFT := 700.0
const RQ_RIBBON_RIGHT := 540.0
const RQ_MEDAL_RADIUS := 50.0
const RQ_MINIMAP_SCALE := 1.12
## Smallest on-screen size of the HUD relative to its 1080p design. Godot
## shrinks the canvas to 71% at 1366x768, which took 15 px labels near 10 px.
const RQ_MIN_UI_SCALE := 0.85
const RQ_RESOURCE_TINTS := {
	"food": Color("e9c46a"), "timber": Color("c08a5a"), "stone": Color("b9bec4"), "gold": Color("f2c14e"),
}
const RQ_KIND_NAMES := {"ABILITY": "Spell", "ORDER": "Order", "BUILD": "Structure", "TRAIN": "Recruit", "RESEARCH": "Research"}

var _rq_deck: Control = null
var _rq_ribbon: Control = null
var _rq_clock: Label = null
var _rq_age_title: Label = null
var _rq_compact_orders := false
var _rq_unit_view := false
var _rq_objective_title: Label = null


## "CONQUEST · Raze every enemy building" reads as a title over its line.
func _rq_split_objective() -> void:
	if not is_instance_valid(_survival_label) or not is_instance_valid(_rq_objective_title):
		return
	var text := _survival_label.text
	var cut := text.find(" · ")
	if cut <= 0:
		return
	_rq_objective_title.text = text.substr(0, cut).to_upper()
	_survival_label.text = text.substr(cut + 3)


func _update_survival_label() -> void:
	super._update_survival_label()
	_rq_split_objective()


func setup(p_world, p_rts) -> void:
	var commander = p_world.player_commander if p_world else null
	RqKit.people = String(commander.race) if commander else "barrosan"
	RqKit.age = int(commander.tier) if commander else 1
	# Glyphs are imported large with mipmaps; sample them smoothly at any size.
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	super.setup(p_world, p_rts)


# ---------------------------------------------------------------------------
# Text and surfaces
# ---------------------------------------------------------------------------
func _mk_label(text: String, size: int = 16, col: Color = FONT_COLOR) -> Label:
	# Alegreya Sans sets narrower and smaller on the eye than the fallback
	# face these sizes were authored for; one point restores the reading size.
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_override("font", RqKit.body_medium() if size <= 15 else RqKit.body())
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.add_theme_font_size_override("font_size", size + 1)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", 1)
	l.add_theme_constant_override("shadow_outline_size", 3)
	return l


func _mk_title_label(text: String, size: int, col: Color) -> Label:
	var l := _mk_label(text, size, col)
	l.add_theme_font_override("font", RqKit.display())
	l.add_theme_font_size_override("font_size", size)
	return l


## Labels that sit inline in a row must keep their natural width; hud.gd's
## default ellipsis trimming lets a row squeeze them to nothing.
func _rq_inline(l: Label) -> Label:
	l.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	return l


## Text that sits directly on the battlefield needs an outline as well.
func _rq_world_label(text: String, size: int, col: Color, face: Font = null) -> Label:
	var l := _mk_label(text, size - 1, col)
	if face:
		l.add_theme_font_override("font", face)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.72))
	l.add_theme_constant_override("outline_size", 4)
	return l


func _mk_hud_panel(_kind: String = "selection", _accent: Color = HUD_BRONZE) -> PanelContainer:
	# The deck and ribbon paint the chassis; panels are only layout.
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	var sb := StyleBoxEmpty.new()
	sb.set_content_margin_all(8)
	p.add_theme_stylebox_override("panel", sb)
	return p


func _mk_bar(col: Color) -> ProgressBar:
	var bar: ProgressBar = RQ_BAR.new()
	bar.kind = "hp" if (col.g > col.r and col.g > col.b) else ("mp" if (col.b > col.r and col.b > col.g) else "other")
	bar.fill_color = col
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.custom_minimum_size = Vector2(0, 12)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for style_name in ["background", "fill"]:
		bar.add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
	return bar


func _set_top_metric_text(label: Label, value: String, base_size: int) -> void:
	# hud.gd asks for its 27-28 px numerals; the ribbon reads at 23.
	super._set_top_metric_text(label, value, int(round(base_size * 0.82)))


# ---------------------------------------------------------------------------
# Top ribbon
# ---------------------------------------------------------------------------
func _rq_metric(row: HBoxContainer, plate_name: String, glyph: String, tint: Color, value_width: float, tooltip: String, boxed: bool = false) -> Dictionary:
	var surface := PanelContainer.new()
	surface.name = plate_name
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	surface.tooltip_text = tooltip
	var sb: StyleBox
	if boxed:
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(0, 0, 0, 0.35)
		var edge: Color = RqKit.mat("edge_mid")
		flat.border_color = Color(edge.r, edge.g, edge.b, 0.45)
		flat.set_border_width_all(1)
		flat.content_margin_left = 7
		flat.content_margin_right = 8
		flat.content_margin_top = 3
		flat.content_margin_bottom = 3
		sb = flat
	else:
		sb = StyleBoxEmpty.new()
		sb.content_margin_left = 2
		sb.content_margin_right = 2
	surface.add_theme_stylebox_override("panel", sb)
	var cell := HBoxContainer.new()
	cell.add_theme_constant_override("separation", 6)
	cell.alignment = BoxContainer.ALIGNMENT_CENTER
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surface.add_child(cell)
	var icon := RqKit.glyph_rect(glyph, 26.0, tint)
	icon.name = plate_name + "Glyph"
	cell.add_child(icon)
	var value := _mk_label("0", 22, RqKit.TEXT)
	value.add_theme_font_override("font", RqKit.body_medium())
	value.custom_minimum_size = Vector2(value_width, 0)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	cell.add_child(value)
	row.add_child(surface)
	return {"surface": surface, "cell": cell, "value": value}


func _build_top_bar() -> void:
	_top_panel = _mk_hud_panel()
	_top_panel.name = "TopResourceBar"
	_top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_top_panel)
	var economy := HBoxContainer.new()
	economy.add_theme_constant_override("separation", 14)
	economy.alignment = BoxContainer.ALIGNMENT_CENTER
	economy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_panel.add_child(economy)
	for k in RES_ORDER:
		var m := _rq_metric(economy, "Metric" + k.capitalize(), k, RQ_RESOURCE_TINTS[k], 52.0, "%s resource" % k.capitalize())
		_res_labels[k] = m["value"]
		var rate := _rq_inline(_mk_label("", 11, RqKit.POSITIVE))
		rate.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		rate.custom_minimum_size = Vector2(34, 0)
		rate.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		_res_rate_labels[k] = rate
		(m["cell"] as HBoxContainer).add_child(rate)

	_force_panel = _mk_hud_panel()
	_force_panel.name = "ForceInstrument"
	_force_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_force_panel)
	var force := HBoxContainer.new()
	force.add_theme_constant_override("separation", 12)
	force.alignment = BoxContainer.ALIGNMENT_CENTER
	force.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_force_panel.add_child(force)
	var pop := _rq_metric(force, "MetricPopulation", "pop", Color("d9cfb8"), 58.0, "Population: current units / population cap")
	_pop_label = pop["value"]
	var workers := _rq_metric(force, "MetricIdleWorkers", "worker", RqKit.mat("edge_hi"), 26.0, "", true)
	_idle_worker_label = workers["value"]
	_make_metric_clickable(workers["surface"], "_select_idle_worker", KeyBinds.fill("Workers without an active order. Click (or press {idle_worker}) to find the next one."))
	var army := _rq_metric(force, "MetricIdleArmy", "army", RqKit.mat("edge_hi"), 26.0, "", true)
	_idle_military_label = army["value"]
	_make_metric_clickable(army["surface"], "select_idle_army", "Military units without an active order. Click to select them all.")
	var foes := _rq_metric(force, "MetricOpponents", "objective", Color("e07a5f"), 22.0, "Living opposing commanders")
	_opponent_count_label = foes["value"]
	_opponent_count_label.name = "OpponentCountLabel"
	_rq_clock = _rq_inline(_mk_label("0:00", 18, RqKit.TEXT_MUTED))
	_rq_clock.name = "MatchClock"
	_rq_clock.custom_minimum_size = Vector2(52, 0)
	_rq_clock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	force.add_child(_rq_clock)

	# The Age medallion carries the people's crest; the plaque names the Age.
	var identity := Match.get_identity_snapshot() if Match else {}
	var player_race := str(identity.get("player_race", RqKit.people))
	_age_panel = _mk_hud_panel()
	_age_panel.name = "AgeMedallion"
	_age_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	_age_panel.tooltip_text = "The Age of your people. Each Age wakes more Lume in the relic."
	add_child(_age_panel)
	var age_stack := Control.new()
	age_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_age_panel.add_child(age_stack)
	var crest_path := String(COMMAND_CRESTS.get(player_race, ""))
	var crest: Control
	if not crest_path.is_empty() and ResourceLoader.exists(crest_path):
		var painted := TextureRect.new()
		painted.texture = load(crest_path)
		painted.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		painted.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		painted.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		crest = painted
	else:
		crest = _drawn_faction_crest(player_race, Vector2(64, 72))
	crest.name = "MatchFactionCrest"
	crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	age_stack.add_child(crest)
	_faction_crest = crest as TextureRect
	var plaque_row := HBoxContainer.new()
	plaque_row.name = "AgePlaque"
	plaque_row.alignment = BoxContainer.ALIGNMENT_CENTER
	plaque_row.add_theme_constant_override("separation", 7)
	plaque_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	age_stack.add_child(plaque_row)
	_tier_label = _rq_inline(_mk_title_label("AGE I", 15, RqKit.TEXT_GILT))
	_tier_label.add_theme_font_override("font", RqKit.font(RqKit.FONT_DISPLAY_BOLD))
	_tier_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	plaque_row.add_child(_tier_label)
	_rq_age_title = _rq_inline(_mk_title_label("FOUNDING", 11, RqKit.TEXT_MUTED))
	_rq_age_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	plaque_row.add_child(_rq_age_title)

	var menu_btn: Button = RQ_TILE.new()
	menu_btn.text = ""
	menu_btn.is_menu = true
	menu_btn.focus_mode = Control.FOCUS_NONE
	menu_btn.tooltip_text = "Menu"
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		menu_btn.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	_menu_button = menu_btn
	_menu_button.name = "MenuButton"
	menu_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	menu_btn.pressed.connect(func(): emit_signal("pause_requested"))
	add_child(menu_btn)

	_build_rq_objective(identity, player_race)


func _build_rq_objective(identity: Dictionary, player_race: String) -> void:
	var opponent_race := ""
	var opponents: Array = identity.get("opponents", [])
	if not opponents.is_empty():
		opponent_race = str(opponents[0].get("race", ""))
	var player_name := str(GameData.RACES.get(player_race, {}).get("name", player_race)).strip_edges()
	var opponent_name := str(GameData.RACES.get(opponent_race, {}).get("name", opponent_race)).strip_edges()
	var map_id := str(identity.get("map", "hollowspan"))
	var map_name := str(MapDefs.get_map(map_id).get("name", map_id)).strip_edges()
	var short_opponent := _short_people_name(opponent_name)
	if opponents.size() > 1:
		var all_names: Array = []
		for o in opponents:
			var o_race := str(o.get("race", ""))
			all_names.append(str(GameData.RACES.get(o_race, {}).get("name", o_race)).strip_edges())
		opponent_name = ", ".join(all_names)
		short_opponent = "%d Hosts" % opponents.size()
	var mode_name := str(identity.get("mode", "skirmish")).capitalize()
	var full_identity := "%s  vs  %s  •  %s  •  %s" % [player_name, opponent_name, mode_name, map_name]
	var saga_chapter := CampaignDefs.find(String(Match.get_config().get("campaign_chapter", "")))
	var place := String(saga_chapter.get("title", "")) if not saga_chapter.is_empty() else map_name

	_objective_panel = _mk_hud_panel()
	_objective_panel.name = "MatchObjectiveInstrument"
	_objective_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_objective_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	add_child(_objective_panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 0)
	stack.alignment = BoxContainer.ALIGNMENT_BEGIN
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_objective_panel.add_child(stack)
	var victory_kind := str(identity.get("victory", "conquest")).to_lower()
	var objective_text := "CONQUEST · Raze every enemy building" if victory_kind == "conquest" else ("DOMINATION · Hold every Lume site" if victory_kind == "domination" else victory_kind.capitalize())
	_rq_objective_title = _rq_world_label("", 19, RqKit.TEXT_GILT, RqKit.display())
	_rq_objective_title.name = "MatchObjectiveTitle"
	_rq_objective_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stack.add_child(_rq_objective_title)
	var objective_label := _rq_world_label(objective_text, 17, RqKit.TEXT_BRIGHT)
	objective_label.name = "MatchObjectiveLabel"
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	objective_label.mouse_filter = Control.MOUSE_FILTER_STOP
	objective_label.tooltip_text = "Destroy every enemy building and worker to win." if victory_kind == "conquest" else ("Hold every Lume site at once for two and a half minutes (the count begins five minutes in), or destroy every enemy building and worker. The enemy can win the same way." if victory_kind == "domination" else objective_text)
	_survival_label = objective_label
	stack.add_child(objective_label)
	_rq_split_objective()
	_bounty_label = _rq_world_label("", 15, Color(0.95, 0.82, 0.5))
	_bounty_label.name = "MatchBountyLabel"
	_bounty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_bounty_label.mouse_filter = Control.MOUSE_FILTER_STOP
	_bounty_label.tooltip_text = "Meet the bounty and win for extra spoils and +20% experience."
	stack.add_child(_bounty_label)
	var where := _rq_world_label("%s  ·  %s vs %s" % [place, _short_people_name(player_name), short_opponent], 14, RqKit.TEXT_MUTED)
	where.name = "MatchIdentityLabel"
	where.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	where.tooltip_text = full_identity
	where.mouse_filter = Control.MOUSE_FILTER_STOP
	stack.add_child(where)
	# Kept for callers that look the battlefield name up by node name.
	var battlefield := Label.new()
	battlefield.name = "MatchBattlefieldLabel"
	battlefield.text = place.to_upper()
	battlefield.visible = false
	stack.add_child(battlefield)


func _on_tier_changed(tier: int) -> void:
	super._on_tier_changed(tier)
	var roman := ["I", "II", "III"]
	if is_instance_valid(_tier_label):
		_tier_label.text = "AGE " + (roman[clampi(tier, 1, 3) - 1] if tier >= 1 and tier <= 3 else str(tier))
	if is_instance_valid(_rq_age_title):
		_rq_age_title.text = String(RqKit.AGE_TITLES.get(tier, "")).to_upper()
	if RqKit.age != tier:
		RqKit.age = tier
		for painter in [_rq_deck, _rq_ribbon]:
			if is_instance_valid(painter):
				painter.queue_redraw()


func _on_pop_changed(used: int, cap: int) -> void:
	super._on_pop_changed(used, cap)
	if is_instance_valid(_pop_label) and not (used >= cap and cap > 0):
		_pop_label.add_theme_color_override("font_color", RqKit.TEXT)


func _poll_top_bar() -> void:
	super._poll_top_bar()
	if is_instance_valid(_rq_clock) and is_instance_valid(world) and "match_time" in world:
		var t := int(world.match_time)
		_rq_clock.text = "%d:%02d" % [t / 60, t % 60] if t < 3600 else "%d:%02d:%02d" % [t / 3600, (t / 60) % 60, t % 60]


# ---------------------------------------------------------------------------
# Minimap, selection and command surfaces
# ---------------------------------------------------------------------------
func _build_minimap() -> void:
	super._build_minimap()
	var column := _minimap_panel.get_child(0) as VBoxContainer
	if column:
		for child in column.get_children():
			if child is Label:
				var text := (child as Label).text
				child.queue_free()
				if text.contains("CLICK TO PAN"):
					continue
				var title := _mk_title_label(text, 14, RqKit.TEXT_GILT)
				title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
				title.custom_minimum_size = Vector2(0, 22)
				column.add_child(title)
				column.move_child(title, 0)
	_minimap_panel.tooltip_text = "Click or drag to move the view."


func _draw_minimap_frame(size: Vector2) -> void:
	# The housing is the frame; the map only carries a fine inner line.
	var edge: Color = RqKit.mat("edge_mid")
	_minimap.draw_rect(Rect2(Vector2.ZERO, size).grow(-0.5), Color(edge.r, edge.g, edge.b, 0.35), false, 1.0)
	var compass := Vector2(size.x - 17.0, 17.0)
	_minimap.draw_circle(compass, 11.0, Color(0.02, 0.02, 0.02, 0.72))
	_minimap.draw_arc(compass, 10.0, 0.0, TAU, 24, Color(edge.r, edge.g, edge.b, 0.7), 1.0, true)
	_minimap.draw_colored_polygon(PackedVector2Array([
		compass + Vector2(0.0, -7.5), compass + Vector2(3.0, 3.6),
		compass, compass + Vector2(-3.0, 3.6)]), RqKit.mat("edge_hi"))


func _build_selection_panel() -> void:
	_sel_panel = _mk_hud_panel()
	_sel_panel.name = "SelectionPanel"
	_sel_panel.custom_minimum_size = Vector2(SELECTION_PANEL_WIDTH, 120)
	_sel_panel.anchor_left = 0.0
	_sel_panel.anchor_right = 0.0
	_sel_panel.anchor_top = 0.0
	_sel_panel.anchor_bottom = 0.0
	add_child(_sel_panel)
	# hud.gd toggles this spacer; it has no visual role here.
	_sel_header_spacer = Control.new()
	_sel_header_spacer.visible = false
	_sel_header_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var stack := VBoxContainer.new()
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(_sel_header_spacer)
	_sel_panel.add_child(stack)
	_sel_body = Control.new()
	_sel_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sel_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sel_body.custom_minimum_size = Vector2(0, 1)
	_sel_body.clip_contents = true
	stack.add_child(_sel_body)
	_sel_panel.visible = false


func _build_command_panel() -> void:
	super._build_command_panel()
	_cmd_panel.anchor_left = 0.0
	_cmd_panel.anchor_right = 0.0
	_cmd_panel.anchor_top = 0.0
	_cmd_panel.anchor_bottom = 0.0
	if is_instance_valid(_command_tooltip):
		_command_tooltip.queue_free()
	_command_tooltip = RQ_TOOLTIP.new()
	_command_tooltip.name = "CommandTooltip"
	_command_tooltip.visible = false
	_command_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_command_tooltip.custom_minimum_size = Vector2(380, 0)
	var sb := StyleBoxEmpty.new()
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	_command_tooltip.add_theme_stylebox_override("panel", sb)
	add_child(_command_tooltip)


func _build_command_chassis() -> void:
	_rq_deck = RQ_DECK.new()
	_rq_deck.name = "ReliquaryDeck"
	add_child(_rq_deck)
	_rq_deck.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(_rq_deck, 0)
	_rq_ribbon = RQ_RIBBON.new()
	_rq_ribbon.name = "ReliquaryRibbon"
	add_child(_rq_ribbon)
	_rq_ribbon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(_rq_ribbon, 1)


func _add_command_context(_single, _selection: Array) -> void:
	# The selection already names what is selected; the deck needs no header.
	pass


func _add_context_hints(hints: Array[String]) -> void:
	var plain := {
		"RMB  RALLY": "Right-click sets the rally point", "CLICK  TRAIN / RESEARCH": "click a card to train or research",
		"BUILD SITE": "Build site", "AWAIT COMPLETION": "workers are raising it",
		"RMB WORKERS  SEND IN": "Right-click workers to send them in", "EXPAND  MORE OUTPUT": "expand for more output",
	}
	var parts: Array[String] = []
	for h in hints:
		parts.append(String(plain.get(h, h.capitalize())))
	var line := _mk_label("  ·  ".join(parts), 13, RqKit.TEXT_DIM)
	line.custom_minimum_size = Vector2(0, 18)
	line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_cmd_fixed.add_child(line)


func _add_command_section(title: String, hint: String = "", pinned: bool = false) -> void:
	var row := HBoxContainer.new()
	if pinned:
		row.name = "PinnedCommandSection"
	row.custom_minimum_size = Vector2(0, 24)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title_label := _rq_inline(_mk_title_label(title.to_upper(), 13, RqKit.TEXT_GILT))
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(title_label)
	var rule := ColorRect.new()
	var edge: Color = RqKit.mat("edge_mid")
	rule.color = Color(edge.r, edge.g, edge.b, 0.28)
	rule.custom_minimum_size = Vector2(0, 1)
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(rule)
	if not hint.is_empty():
		var hint_label := _rq_inline(_mk_label(hint, 13, RqKit.TEXT_DIM))
		hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(hint_label)
	if pinned:
		_cmd_fixed.add_child(row)
	else:
		_cmd_body.add_child(row)


# ---------------------------------------------------------------------------
# Selected unit: medallion and dossier
# ---------------------------------------------------------------------------
func _rq_role_word(u) -> String:
	var role_word := "Worker" if u.is_worker else String(UNIT_ROLE_FOOTERS.get(String(u.def.get("role", "")), "Warrior")).capitalize()
	if String(u.unit_id) == "lioraen_thorn_ranger":
		role_word = "Ranger"
	if u.is_hero:
		var hero_race := String(u.def.get("race", ""))
		role_word = "Thane" if hero_race == "barrosan" else ("Warden" if hero_race == "lioraen" else ("Binder" if hero_race == "vorthak" else "Hero"))
	return role_word


func _rq_stat(row: HBoxContainer, caption: String, value: String, kind: String) -> void:
	var cap := _rq_inline(_mk_label(caption, 12, RqKit.TEXT_DIM))
	cap.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	row.add_child(cap)
	var val := _mk_label(value, 16, RqKit.TEXT)
	val.add_theme_font_override("font", RqKit.body_medium())
	val.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	val.custom_minimum_size = Vector2(34, 0)
	val.tooltip_text = "%s: %s" % [caption, value]
	row.add_child(val)
	_single_stat_cards.append({"kind": kind, "label": val, "caption": caption})


func _rq_vital_row(info: VBoxContainer, bar: ProgressBar, text: Label) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(bar)
	text.custom_minimum_size = Vector2(76, 0)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	text.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	row.add_child(text)
	info.add_child(row)


func _build_single_unit(u, read_only: bool = false) -> void:
	_tracked_single = u
	_single_read_only = read_only
	_rq_unit_view = true

	var medallion = RQ_MEDALLION.new()
	medallion.name = "PortraitMedallion"
	medallion.hostile = read_only
	medallion.size = Vector2(RQ_MEDALLION_SIZE, RQ_MEDALLION_SIZE)
	medallion.custom_minimum_size = medallion.size
	_selection_portrait = medallion
	add_child(medallion)
	if ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
		var portrait: Control = load(ENTITY_PORTRAIT_SCRIPT).new()
		portrait.custom_minimum_size = Vector2(180, 180)
		medallion.hold(portrait)
		portrait.configure_entity(u)
		medallion.strip_portrait_frame(portrait)
		medallion.call_deferred("strip_portrait_frame", portrait)

	var info := VBoxContainer.new()
	info.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	info.add_theme_constant_override("separation", 3)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.add_child(info)

	var uname: String = u.def.get("name", "Unit")
	var name_label := _mk_title_label(uname, 30 if uname.length() <= 14 else 24, Color(1.0, 0.6, 0.5) if read_only else RqKit.TEXT_BRIGHT)
	name_label.name = "SelectedName"
	name_label.custom_minimum_size = Vector2(0, 38)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	info.add_child(name_label)

	var people := str(GameData.RACES.get(String(u.def.get("race", "")), {}).get("name", "")).strip_edges()
	var role_row := HBoxContainer.new()
	role_row.add_theme_constant_override("separation", 0)
	role_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var role_word := _rq_role_word(u)
	var role_label := _rq_inline(_mk_label("Hostile" if read_only else role_word, 14, Color(1.0, 0.6, 0.5) if read_only else RqKit.mat("edge_hi")))
	role_label.name = "SelectedRole"
	role_row.add_child(role_label)
	var rest := ""
	if read_only:
		rest = "  ·  " + _role_name(String(u.def.get("role", "unit")))
	elif u.is_hero:
		rest = (" of the %s" % people if not people.is_empty() else "") + "  ·  Hero"
	else:
		rest = ("  ·  " + people) if not people.is_empty() else ""
	var rank := int(u.get("_veterancy")) if u.get("_veterancy") != null else 0
	if rank > 0 and not u.is_worker and not u.is_hero:
		var vet_name := String(u.get("veteran_name")) if u.get("veteran_name") != null else ""
		rest += "  ·  " + "★".repeat(mini(rank, 5)) + (" %d" % rank if rank > 5 else "") + ("  “%s”" % vet_name if vet_name != "" else "")
	var rest_label := _mk_label(rest, 14, RqKit.TEXT_MUTED)
	rest_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	role_row.add_child(rest_label)
	info.add_child(role_row)
	if not read_only:
		# The current target shares the identity line, right-aligned.
		_single_target_label = _rq_inline(_mk_label("", 13, Color(1.0, 0.74, 0.38)))
		_single_target_label.name = "CombatTargetLabel"
		_single_target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_single_target_label.visible = false
		role_row.add_child(_single_target_label)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 4)
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(gap)
	_single_hp_bar = _mk_bar(Color(0.35, 0.8, 0.35))
	_single_hp_text = _mk_label("", 14, RqKit.TEXT)
	_rq_vital_row(info, _single_hp_bar, _single_hp_text)
	if not read_only and u.is_hero and u.max_mana > 0.0:
		_single_mana_bar = _mk_bar(Color(0.35, 0.55, 0.95))
		_single_mana_text = _mk_label("", 14, Color("b9d0ff"))
		_rq_vital_row(info, _single_mana_bar, _single_mana_text)

	if not read_only and not u.is_worker and u.has_method("cur_dmg"):
		var stat_row := HBoxContainer.new()
		stat_row.add_theme_constant_override("separation", 6)
		stat_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_rq_stat(stat_row, "DMG", _compact_combat_stat(u.cur_dmg()), "dmg")
		_rq_stat(stat_row, "ARM", _compact_combat_stat(u.cur_armor()), "armor")
		_rq_stat(stat_row, "RNG", "%.1f" % u.cur_range(), "range")
		_rq_stat(stat_row, "SPD", "%.1f" % float(u.move_speed), "speed")
		info.add_child(stat_row)
		if not read_only:
			_single_activity_label = _mk_label("", 13, RqKit.TEXT_DIM)
			_single_activity_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_single_activity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			_single_activity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			stat_row.add_child(_single_activity_label)

	if not read_only and u.is_worker and u.has_method("get_economy_snapshot"):
		_single_economy_label = _mk_label("", 14, Color(0.80, 0.9, 0.74))
		_single_economy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_single_economy_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		info.add_child(_single_economy_label)

	if read_only:
		_single_stat_label = _rq_inline(_mk_label("Hostile · %s" % _role_name(String(u.def.get("role", "unit"))), 13, RqKit.TEXT_MUTED))
		info.add_child(_single_stat_label)
	elif not is_instance_valid(_single_activity_label):
		_single_activity_label = _rq_inline(_mk_label("", 13, RqKit.TEXT_DIM))
		info.add_child(_single_activity_label)
	call_deferred("_fit_to_viewport")
	_refresh_single_live()


func _build_single_building(b, read_only: bool = false) -> void:
	_tracked_single = b
	_single_read_only = read_only
	_rq_unit_view = true
	if not read_only and b.has_signal("construction_completed"):
		b.construction_completed.connect(_on_tracked_building_construction_completed)
		_watched_construction_building = b

	var medallion = RQ_MEDALLION.new()
	medallion.name = "PortraitMedallion"
	medallion.hostile = read_only
	medallion.size = Vector2(RQ_MEDALLION_SIZE, RQ_MEDALLION_SIZE)
	medallion.custom_minimum_size = medallion.size
	_selection_portrait = medallion
	add_child(medallion)
	if ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
		var portrait: Control = load(ENTITY_PORTRAIT_SCRIPT).new()
		portrait.custom_minimum_size = Vector2(180, 180)
		medallion.hold(portrait)
		if b.is_built:
			portrait.configure_definition(_building_portrait_definition(b.def, String(b.building_id)))
		else:
			portrait.configure_entity(b)
		# Structures keep their whole silhouette; only people are cropped close.
		medallion.strip_portrait_frame(portrait, false)
		medallion.call_deferred("strip_portrait_frame", portrait, false)

	var info := VBoxContainer.new()
	info.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	info.add_theme_constant_override("separation", 3)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.add_child(info)
	var bname := String(b.def.get("name", "Building"))
	var name_label := _mk_title_label(bname, 28 if bname.length() <= 16 else 22, Color(1.0, 0.6, 0.5) if read_only else RqKit.TEXT_BRIGHT)
	name_label.name = "SelectedName"
	name_label.custom_minimum_size = Vector2(0, 36)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	info.add_child(name_label)
	var people := str(GameData.RACES.get(String(b.def.get("race", "")), {}).get("name", "")).strip_edges()
	var role_row := HBoxContainer.new()
	role_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var role_label := _rq_inline(_mk_label("Hostile" if read_only else ("Building" if b.is_built else "Build site"), 14, Color(1.0, 0.6, 0.5) if read_only else RqKit.mat("edge_hi")))
	role_label.name = "SelectedRole"
	role_row.add_child(role_label)
	var rest_label := _mk_label(("  ·  " + people) if not people.is_empty() else "", 14, RqKit.TEXT_MUTED)
	rest_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	role_row.add_child(rest_label)
	info.add_child(role_row)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 3)
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(gap)
	_single_hp_bar = _mk_bar(Color(0.35, 0.8, 0.35))
	_single_hp_text = _mk_label("", 14, RqKit.TEXT)
	_rq_vital_row(info, _single_hp_bar, _single_hp_text)

	if not read_only and not b.is_built:
		var pb := _mk_bar(Color(0.85, 0.7, 0.3))
		pb.kind = "build"
		pb.value = clamp(b.build_progress, 0.0, 1.0)
		var progress_label := _mk_label("Raising  %d%%" % roundi(clampf(b.build_progress, 0.0, 1.0) * 100.0), 13, RqKit.TEXT_MUTED)
		_rq_vital_row(info, pb, progress_label)
		var t := Timer.new()
		t.wait_time = 0.2
		t.autostart = true
		pb.add_child(t)
		var cap_b_id: int = b.get_instance_id()
		var cap_pb = pb
		var cap_label = progress_label
		var cap_medal = medallion
		t.timeout.connect(func():
			var cb = instance_from_id(cap_b_id)
			if is_instance_valid(cb) and is_instance_valid(cap_pb):
				var prog := clampf(cb.build_progress, 0.0, 1.0)
				cap_pb.value = prog
				if is_instance_valid(cap_label):
					cap_label.text = "Raising  %d%%" % roundi(prog * 100.0)
				if is_instance_valid(cap_medal):
					cap_medal.ring_progress = prog)
		medallion.ring_progress = clampf(b.build_progress, 0.0, 1.0)

	if read_only:
		_single_stat_label = _mk_label("Hostile · Built structure", 13, RqKit.TEXT_MUTED)
		info.add_child(_single_stat_label)
	elif b.is_built:
		_single_activity_label = _mk_label("", 13, RqKit.TEXT_DIM)
		_single_activity_label.visible = false
		info.add_child(_single_activity_label)

	if not read_only and (not b.def.get("produces", []).is_empty() or not b.def.get("research", []).is_empty() \
			or b.def.get("is_hq", false) or b.def.get("kind", "") == "main"):
		var queue_row := HBoxContainer.new()
		queue_row.add_theme_constant_override("separation", 8)
		queue_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_production_status_label = _mk_label("Idle", 13, RqKit.TEXT_MUTED)
		_production_status_label.custom_minimum_size = Vector2(120, 26)
		_production_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_production_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		queue_row.add_child(_production_status_label)
		_queue_container = HBoxContainer.new()
		_queue_container.add_theme_constant_override("separation", 4)
		_queue_container.mouse_filter = Control.MOUSE_FILTER_STOP
		queue_row.add_child(_queue_container)
		info.add_child(queue_row)
		_production_progress_bar = _mk_bar(Color(0.9, 0.66, 0.28))
		_production_progress_bar.kind = "build"
		_production_progress_bar.custom_minimum_size = Vector2(0, 16)
		_production_progress_bar.visible = false
		info.add_child(_production_progress_bar)
		if b.production_updated.is_connected(_on_production_updated):
			b.production_updated.disconnect(_on_production_updated)
		b.production_updated.connect(_on_production_updated)
		_watched_building = b
		_refresh_queue()
	call_deferred("_fit_to_viewport")
	_refresh_single_live()


func _refresh_queue() -> void:
	var b = _watched_building
	if _rq_unit_view and is_instance_valid(_sel_panel) and is_instance_valid(b):
		# hud.gd grows the old dossier for a queue; the medallion dossier keeps
		# the deck height, so satisfy its check and restore our size after.
		_sel_panel.custom_minimum_size.y = 220.0 if not b.queue.is_empty() else 176.0
	super._refresh_queue()
	if _rq_unit_view and is_instance_valid(_sel_panel):
		_sel_panel.custom_minimum_size.y = 0.0
	if not is_instance_valid(_queue_container):
		return
	for slot in _queue_container.get_children():
		if slot is Button:
			_rq_style_slot(slot)
		elif slot is Label:
			(slot as Label).add_theme_color_override("font_color", RqKit.TEXT_GILT)


func _rq_style_slot(slot: Button) -> void:
	var edge: Color = RqKit.mat("edge_mid")
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.02, 0.02, 0.022, 0.85) if state_name != "hover" else Color(0.08, 0.06, 0.04, 0.95)
		sb.border_color = Color(edge.r, edge.g, edge.b, 0.75 if state_name == "hover" else 0.4)
		sb.set_border_width_all(1)
		sb.content_margin_left = 4
		sb.content_margin_right = 4
		sb.content_margin_bottom = 6
		slot.add_theme_stylebox_override(state_name, sb)
	slot.add_theme_font_override("font", RqKit.body_medium())
	slot.add_theme_font_size_override("font_size", 12)
	slot.add_theme_color_override("font_color", RqKit.TEXT)
	slot.add_theme_color_override("font_hover_color", RqKit.TEXT_BRIGHT)


func _build_multi(units: Array) -> void:
	_rq_unit_view = false
	super._build_multi(units)


func _refresh_single_live() -> void:
	super._refresh_single_live()
	var u = _tracked_single
	if not is_instance_valid(u):
		return
	if is_instance_valid(_single_hp_text) and "hp" in u:
		_single_hp_text.text = "%d / %d" % [int(maxf(0.0, u.hp)), int(u.max_hp)]
	if not (u is Unit):
		return
	if is_instance_valid(_single_mana_text) and "max_mana" in u:
		_single_mana_text.text = "%d / %d" % [int(maxf(0.0, u.mana)), int(maxf(0.0, u.max_mana))]
	if is_instance_valid(_single_activity_label):
		_single_activity_label.text = _unit_activity_label(u)
	for stat in _single_stat_cards:
		if String(stat["kind"]) == "speed" and is_instance_valid(stat["label"]):
			(stat["label"] as Label).text = "%.1f" % float(u.move_speed)
	var medallion := _selection_portrait
	if is_instance_valid(medallion) and "ring_progress" in medallion:
		if u.is_hero and not _single_read_only:
			var steps: Array = Unit.FIELD_LEVEL_XP
			var lvl := int(u.field_level)
			var frac := 1.0
			if lvl < steps.size():
				var lo := float(steps[lvl - 1])
				frac = clampf((float(u.field_xp) - lo) / maxf(1.0, float(steps[lvl]) - lo), 0.0, 1.0)
			medallion.ring_progress = frac
			var level := lvl
			if ProfileManager.has_hero() and is_instance_valid(_commander) and u.get("commander") == _commander:
				level = int(ProfileManager.hero().get("level", lvl))
			medallion.level_text = str(level)
		else:
			medallion.ring_progress = 0.0
			var rank := int(u.get("_veterancy")) if u.get("_veterancy") != null else 0
			medallion.level_text = str(rank) if rank > 0 else ""


# ---------------------------------------------------------------------------
# Command tiles
# ---------------------------------------------------------------------------
func _rq_finish_tile(btn: Button, title: String, kind: String, hotkey: String, tooltip: String, disabled_reason: String, state: String) -> void:
	btn.text = ""
	btn.focus_mode = Control.FOCUS_NONE
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		btn.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	var status := _mk_label(state, 12, RqKit.TEXT_DIM)
	status.visible = false
	btn.add_child(status)
	btn.set_meta("command_status_label", status)
	btn.set_meta("command_kind", kind)
	var full := (title + "\n" if not tooltip.begins_with(title) else "") + tooltip + ("\nHotkey: " + hotkey if not hotkey.is_empty() else "")
	if not disabled_reason.is_empty():
		full += "\nUnavailable: " + disabled_reason
	btn.tooltip_text = ""
	btn.set_meta("command_tooltip_text", full)
	btn.set_meta("command_title", title)
	var accent: Color = RqKit.mat("lume")
	btn.mouse_entered.connect(func(): _show_command_tooltip(title, kind, hotkey, tooltip, disabled_reason, accent))
	btn.mouse_exited.connect(_hide_command_tooltip)


func _rq_caption(btn: Button, text: String, wide: bool) -> Label:
	var l := _mk_label(text, 14 if not wide else 16, RqKit.TEXT_MUTED if not wide else RqKit.TEXT)
	l.name = "TileCaption"
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if wide:
		l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		l.offset_left = 48
		l.offset_right = -26
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	else:
		l.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		l.offset_top = -22
		l.offset_bottom = 0
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.add_child(l)
	return l


func _rq_order_tile(title: String, tooltip: String, state: String, compact: bool) -> Button:
	var btn: Button = RQ_TILE.new()
	btn.command_kind = "ORDER"
	btn.command_state = state
	btn.glyph_name = String(RqKit.ORDER_GLYPHS.get(title.to_lower(), ""))
	btn.hotkey = _command_hotkey(title)
	if compact:
		btn.custom_minimum_size = Vector2(50, 46)
	else:
		btn.custom_minimum_size = Vector2(0, 50)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_rq_caption(btn, title, true)
	_rq_finish_tile(btn, title, "ORDER", btn.hotkey, tooltip, "", state)
	return btn


func _mk_command_button(title: String, detail: String, tooltip: String, disabled_reason: String = "", state: String = "READY", preview_definition: Dictionary = {}, visible_effect: String = "", visible_effect_prefix: String = "Effect", hotkey_override: String = "", command_kind_override: String = "", emblem_id: String = "", unit_art_definition: Dictionary = {}) -> Button:
	if command_kind_override.is_empty() and preview_definition.is_empty() and RqKit.ORDER_GLYPHS.has(title.to_lower()):
		return _rq_order_tile(title, tooltip, state, _rq_compact_orders)
	# Build, train, research and outpost entries keep their authored copy and
	# art; the Reliquary tile repaints the surface beneath them.
	var btn: Button = super._mk_command_button(title, detail, tooltip, disabled_reason, state, preview_definition, visible_effect, visible_effect_prefix, hotkey_override, command_kind_override, emblem_id, unit_art_definition)
	var kind: String = btn.command_kind
	var kept_state: String = btn.command_state
	var kept_accent: Color = btn.accent
	btn.set_script(RQ_TILE)
	btn.command_kind = kind
	btn.command_state = kept_state
	btn.accent = kept_accent
	if kind == "ABILITY":
		# Stray ability cards outside the hero deck still paint as cards.
		btn.command_kind = "CARD"
	return btn


func _build_hero_command_card(u) -> void:
	var row := HBoxContainer.new()
	row.name = "HeroDeck"
	row.add_theme_constant_override("separation", 16)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cmd_body.add_child(row)
	if not u.abilities.is_empty():
		var grid := GridContainer.new()
		grid.name = "AbilityRow"
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(grid)
		var abilities: Dictionary = SkillDefs.get_abilities()
		for id in u.abilities:
			var cap_id := String(id)
			var ab: Dictionary = abilities.get(cap_id, {})
			if ab.is_empty():
				continue
			var key_label := _ability_key_label(cap_id)
			var mana_cost := int(ab.get("mana", 0))
			var cooldown := float(ab.get("cd", 0.0))
			var remaining := float(u.ability_cd.get(cap_id, 0.0)) if "ability_cd" in u else 0.0
			var mana_ready: bool = "mana" in u and u.mana >= mana_cost
			var ready: bool = remaining <= 0.05 and mana_ready
			var state := "READY" if ready else ("COOLDOWN" if remaining > 0.05 else "LOCKED")
			var reason := "Cooldown: %.1fs remaining" % remaining if remaining > 0.05 else ("Need %d mana" % mana_cost if not mana_ready else "")
			var title := String(ab.get("name", cap_id))
			var btn: Button = RQ_TILE.new()
			btn.command_kind = "ABILITY"
			btn.command_state = state
			btn.caster = u
			btn.ability_id = cap_id
			btn.cooldown_total = cooldown
			btn.mana_cost = mana_cost
			btn.glyph_name = RqKit.ability_glyph(cap_id)
			btn.hotkey = key_label
			btn.custom_minimum_size = Vector2(96, 114)
			btn.disabled = not ready
			_rq_caption(btn, title, false)
			_rq_finish_tile(btn, title, "ABILITY", key_label, "%s\n%s\nMana: %d\nCooldown: %.0fs" % [title, ab.get("desc", ""), mana_cost, cooldown], reason, state)
			var cap_u = u
			var aimed: bool = cap_id in ["root", "bolt", "charge"] or (float(ab.get("range", 0.0)) > 0.0 and String(ab.get("use", "enemy")) == "enemy" and (ab.has("fx") or bool(ab.get("sig", false))) and not cap_id in ["sig_chains", "sig_stoneskin", "sig_entrudo"])
			btn.pressed.connect(func():
				if is_instance_valid(cap_u) and not cap_u.is_dead and cap_u.has_method("cast_ability"):
					var aim: Vector3 = cap_u.global_position
					if aimed and world and world.has_method("_nearest_enemy_to"):
						var foe = world._nearest_enemy_to(cap_u.global_position, cap_u.team, [])
						if is_instance_valid(foe):
							aim = foe.global_position
					cap_u.cast_ability(cap_id, aim))
			grid.add_child(btn)
			_ability_widgets.append({"id": cap_id, "button": btn, "overlay": btn.get_meta("command_status_label")})
	_rq_add_sockets(row, u)

	var orders := VBoxContainer.new()
	orders.name = "OrderCluster"
	orders.size_flags_horizontal = Control.SIZE_SHRINK_END
	orders.add_theme_constant_override("separation", 4)
	orders.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(orders)
	var order_grid := GridContainer.new()
	order_grid.columns = 2
	order_grid.add_theme_constant_override("h_separation", 6)
	order_grid.add_theme_constant_override("v_separation", 6)
	orders.add_child(order_grid)
	_rq_compact_orders = true
	_add_military_command_button(order_grid, "Attack Move", "Move and engage enemies encountered.", "Attack-move: march to a point and fight anything met on the way.", "attack_move")
	_add_military_command_button(order_grid, "Stop", "Stop current orders.", "Stop: drop every order and stand.", "stop")
	_add_military_command_button(order_grid, "Hold", "Hold this position.", "Hold: stand on this spot and fight what comes within reach, without giving chase.", "hold")
	_add_military_command_button(order_grid, "Patrol", "Move between chosen points.", "Patrol: walk back and forth between here and a chosen point, fighting what you meet.", "patrol")
	_rq_compact_orders = false
	var caption := _mk_label("Orders", 14, RqKit.TEXT_MUTED)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	orders.add_child(caption)


## Unlearned spell sockets fill the row to four, so a young hero's deck reads
## as a relic waiting to be filled rather than a bare shelf.
func _rq_add_sockets(row: HBoxContainer, u) -> void:
	var grid := row.get_node_or_null("AbilityRow") as GridContainer
	var learned := grid.get_child_count() if grid else 0
	if learned >= 4:
		return
	if grid == null:
		grid = GridContainer.new()
		grid.name = "AbilityRow"
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(grid)
		row.move_child(grid, 0)
	for i in 4 - learned:
		var socket := Control.new()
		socket.name = "SpellSocket%d" % i
		socket.custom_minimum_size = Vector2(96, 114)
		socket.mouse_filter = Control.MOUSE_FILTER_PASS
		socket.tooltip_text = "An unlearned spell. %s learns spells on the skill tree between battles." % String(u.def.get("name", "Your hero"))
		socket.draw.connect(_rq_draw_socket.bind(socket))
		var cap := _mk_label("Unlearned", 13, RqKit.TEXT_DIM)
		cap.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		cap.offset_top = -22
		cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		socket.add_child(cap)
		grid.add_child(socket)


func _rq_draw_socket(socket: Control) -> void:
	var tile := Rect2(Vector2((socket.size.x - RQ_TILE.TILE) * 0.5, 0.0), Vector2(RQ_TILE.TILE, RQ_TILE.TILE))
	var rim := RqKit.chamfer(tile, 10, 10, 0, 0)
	var edge: Color = RqKit.mat("edge_lo")
	socket.draw_colored_polygon(rim, Color(edge.r, edge.g, edge.b, 0.55))
	var well := RqKit.inset_polygon(rim, 2.0)
	socket.draw_colored_polygon(well, Color(0.012, 0.011, 0.01, 0.82))
	var lume: Color = RqKit.mat("lume")
	var g := RqKit.glyph("lume")
	if g:
		var px := 30.0
		socket.draw_texture_rect(g, Rect2(tile.get_center() - Vector2(px, px) * 0.5, Vector2(px, px)), false, Color(lume.r, lume.g, lume.b, 0.16 + 0.05 * RqKit.age))


func _rebuild_command_card(single, selection: Array) -> void:
	# A card rebuilt under the pointer (costs became affordable, a new Age)
	# keeps the open tooltip on the same command instead of dropping it.
	var open_title := ""
	if is_instance_valid(_command_tooltip) and _command_tooltip.visible:
		open_title = String(_rq_tooltip_title)
	super._rebuild_command_card(single, selection)
	if open_title.is_empty() or not is_instance_valid(_cmd_panel):
		return
	for btn in _cmd_panel.find_children("*", "Button", true, false):
		if not btn.is_queued_for_deletion() and String(btn.get_meta("command_title", "")) == open_title:
			btn.mouse_entered.emit()
			return


func _clear_children(node: Node) -> void:
	# Children are freed at the end of the frame. Rename them first so a card
	# rebuilt in the same frame keeps its node names (ConstructionProgress,
	# HeroDeck...) instead of getting auto-numbered ones.
	if not is_instance_valid(node):
		return
	for c in node.get_children():
		c.name = "Freed_%d" % c.get_instance_id()
		c.queue_free()


func _build_building_card(b) -> void:
	if b.is_built:
		super._build_building_card(b)
		return
	# A build site: the dossier already names it and shows its HP, so the card
	# shows the stages of the work and who is doing it.
	_add_context_hints(["BUILD SITE", "AWAIT COMPLETION"])
	_add_command_section("Construction", "Raising the %s" % String(b.def.get("name", "building")).to_lower())
	var site = RQ_SITE.new()
	site.name = "ConstructionProgress"
	site.custom_minimum_size = Vector2(400, 112)
	site.set_progress(float(b.build_progress))
	site.set_builders(_rq_site_builders(b))
	_cmd_body.add_child(site)
	var t := Timer.new()
	t.wait_time = 0.2
	t.autostart = true
	site.add_child(t)
	var site_b_id: int = b.get_instance_id()
	t.timeout.connect(func():
		var cb = instance_from_id(site_b_id)
		if is_instance_valid(cb) and is_instance_valid(site):
			site.set_progress(float(cb.build_progress))
			site.set_builders(_rq_site_builders(cb))
	)


func _rq_site_builders(b) -> int:
	var count := 0
	for u in get_tree().get_nodes_in_group("units"):
		if is_instance_valid(u) and u.get("is_worker") and not u.get("is_dead") and u.get("_build_target") == b:
			count += 1
	return count


func _build_military_card() -> void:
	var grid := GridContainer.new()
	grid.name = "FieldOrders"
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cmd_body.add_child(grid)
	_add_military_command_button(grid, "Attack Move", "Move and engage enemies encountered.", "Attack-move: march to a point and fight anything met on the way.", "attack_move")
	_add_military_command_button(grid, "Stop", "Stop current orders.", "Stop: drop every order and stand.", "stop")
	_add_military_command_button(grid, "Hold", "Hold this position.", "Hold: stand on this spot and fight what comes within reach, without giving chase.", "hold")
	_add_military_command_button(grid, "Patrol", "Move between chosen points.", "Patrol: walk back and forth between here and a chosen point, fighting what you meet.", "patrol")


func _show_command_tooltip(title: String, kind: String, hotkey: String, tooltip: String, disabled_reason: String, accent: Color) -> void:
	if not is_instance_valid(_command_tooltip) or not is_instance_valid(_cmd_panel):
		return
	_rq_tooltip_title = title
	_clear_children(_command_tooltip)
	_command_tooltip.set("accent", accent)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title_label := _mk_title_label(title, 21, RqKit.TEXT_BRIGHT)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	header.add_child(title_label)
	var kind_text := String(RQ_KIND_NAMES.get(kind, kind.capitalize())).to_upper() + ("  ·  " + hotkey if not hotkey.is_empty() else "")
	var kind_label := _rq_inline(_mk_label(kind_text, 12, RqKit.TEXT_MUTED))
	kind_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(kind_label)
	stack.add_child(header)
	# Numbers the player compares (mana, cooldown, cost) get their own line.
	var facts: Array[String] = []
	var prose: Array[String] = []
	for raw in tooltip.strip_edges().split("\n"):
		var line := String(raw).strip_edges()
		if line.is_empty() or line.to_lower() == title.to_lower():
			continue
		var head := line.get_slice(":", 0)
		if line.contains(":") and head in ["Mana", "Cooldown", "Cost", "Population", "Tier", "Radius"]:
			facts.append("%s %s" % [head, line.substr(head.length() + 1).strip_edges()])
		elif not line.begins_with("Hotkey:"):
			prose.append(line)
	if not facts.is_empty():
		var fact_label := _mk_label("    ".join(facts), 14, RqKit.TEXT_MUTED)
		fact_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		stack.add_child(fact_label)
	if not prose.is_empty():
		var body := _mk_label("\n".join(prose), 16, RqKit.TEXT)
		body.add_theme_font_override("font", RqKit.body())
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		body.custom_minimum_size = Vector2(344, 0)
		body.add_theme_constant_override("line_spacing", 2)
		stack.add_child(body)
	if not disabled_reason.is_empty():
		var why := _mk_label(disabled_reason, 14, RqKit.NEGATIVE)
		why.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		why.custom_minimum_size = Vector2(344, 0)
		stack.add_child(why)
	_command_tooltip.add_child(stack)
	_command_tooltip.reset_size()
	var anchor_rect := Rect2(_cmd_panel.position, _cmd_panel.size * _cmd_panel.scale)
	var viewport_size := size
	var top := minf(anchor_rect.position.y, viewport_size.y - RQ_DECK_HEIGHT)
	var tooltip_size := _command_tooltip.size
	var pos := Vector2(anchor_rect.position.x, top - tooltip_size.y - 14.0)
	if pos.y < 8.0:
		pos.y = anchor_rect.end.y + 8.0
	_command_tooltip.position = Vector2(
		clampf(pos.x, 8.0, maxf(8.0, viewport_size.x - tooltip_size.x - 8.0)),
		clampf(pos.y, 8.0, maxf(8.0, viewport_size.y - tooltip_size.y - 8.0)))
	_command_tooltip.visible = true


# ---------------------------------------------------------------------------
# World hover and heralds
# ---------------------------------------------------------------------------
func _build_resource_tooltip() -> void:
	_resource_tooltip = RQ_TOOLTIP.new()
	_resource_tooltip.name = "ResourceHoverTooltip"
	_resource_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resource_tooltip.visible = false
	var sb := StyleBoxEmpty.new()
	sb.content_margin_left = 12
	sb.content_margin_right = 14
	sb.content_margin_top = 7
	sb.content_margin_bottom = 8
	_resource_tooltip.add_theme_stylebox_override("panel", sb)
	_resource_tooltip_label = _mk_label("", 15, RqKit.TEXT)
	_resource_tooltip_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	_resource_tooltip.add_child(_resource_tooltip_label)
	add_child(_resource_tooltip)


func _place_resource_tooltip(pointer: Vector2) -> void:
	# The pointer arrives in canvas space; the HUD may be scaled up.
	_resource_tooltip.reset_size()
	var local := pointer / maxf(0.01, scale.x)
	var bounds := size
	var tip := _resource_tooltip.size
	var pos := local + Vector2(16.0, 18.0)
	if pos.x + tip.x > bounds.x - 8.0:
		pos.x = local.x - tip.x - 16.0
	if pos.y + tip.y > bounds.y - 8.0:
		pos.y = local.y - tip.y - 18.0
	_resource_tooltip.position = Vector2(clampf(pos.x, 8.0, maxf(8.0, bounds.x - tip.x - 8.0)), clampf(pos.y, 8.0, maxf(8.0, bounds.y - tip.y - 8.0)))
	_resource_tooltip.visible = true


func _build_alert_feed() -> void:
	# Heralds speak from beneath the Age medallion, centred on the field.
	_alert_box = VBoxContainer.new()
	_alert_box.name = "HeraldFeed"
	_alert_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_alert_box.offset_left = -300
	_alert_box.offset_right = 300
	_alert_box.offset_top = 140
	_alert_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_alert_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	_alert_box.add_theme_constant_override("separation", 6)
	_alert_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_alert_box)


func _push_alert(message: String, col: Color) -> void:
	if not is_instance_valid(_alert_box):
		return
	var alert_limit := DEBUG_REVIEW_ALERT_LIMIT if _debug_review_presentation() else PLAYER_ALERT_LIMIT
	while _alert_box.get_child_count() >= alert_limit:
		var oldest := _alert_box.get_child(0)
		_alert_box.remove_child(oldest)
		oldest.queue_free()
	var herald: PanelContainer = RQ_TOOLTIP.new()
	herald.mouse_filter = Control.MOUSE_FILTER_IGNORE
	herald.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxEmpty.new()
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 9
	sb.content_margin_bottom = 10
	herald.add_theme_stylebox_override("panel", sb)
	var l := _mk_label(message, 17, col.lerp(RqKit.TEXT_BRIGHT, 0.25) if col.v > 0.3 else RqKit.TEXT_BRIGHT)
	l.add_theme_font_override("font", RqKit.body_medium())
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	var width := minf(556.0, RqKit.body_medium().get_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x + 8.0)
	l.custom_minimum_size = Vector2(maxf(160.0, width), 0)
	herald.add_child(l)
	_alert_box.add_child(herald)
	herald.modulate.a = 0.0
	var arrive := herald.create_tween()
	arrive.tween_property(herald, "modulate:a", 1.0, 0.2)
	var tw := herald.create_tween()
	tw.tween_interval(3.4)
	tw.tween_property(herald, "modulate:a", 0.0, 0.8)
	tw.tween_callback(func():
		if is_instance_valid(herald):
			herald.queue_free())


## A short-lived notice above the deck, on the same smoked glass as tooltips.
func _rq_toast(message: String, col: Color, bottom_gap: float, hold: float, fade: float, font_size: int) -> PanelContainer:
	var box: PanelContainer = RQ_TOOLTIP.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.z_index = 60
	var sb := StyleBoxEmpty.new()
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 7
	sb.content_margin_bottom = 8
	box.add_theme_stylebox_override("panel", sb)
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 1.0
	box.anchor_bottom = 1.0
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.offset_top = -bottom_gap - 38.0
	box.offset_bottom = -bottom_gap
	add_child(box)
	var l := _mk_label(message, font_size, col.lerp(RqKit.TEXT_BRIGHT, 0.2))
	l.add_theme_font_override("font", RqKit.body_medium())
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	box.add_child(l)
	var tw := box.create_tween()
	tw.tween_interval(hold)
	tw.tween_property(box, "modulate:a", 0.0, fade)
	tw.tween_callback(box.queue_free)
	return box


func _flash_notice(msg: String, col: Color = Color(1, 0.6, 0.5)) -> void:
	if col.g < 0.9 or col.r > 0.9:
		Sfx.play_limited("refuse", -10.0, 250)
	_rq_toast(msg, col, RQ_DECK_HEIGHT + 60.0, 1.4, 0.6, 18)


func _show_command_feedback(message: String, col: Color) -> void:
	if is_instance_valid(_command_feedback_box):
		_command_feedback_box.queue_free()
	_command_feedback_box = _rq_toast(message, col, RQ_DECK_HEIGHT + 104.0, 0.9, 0.35, 15)


# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------
## Scales the whole HUD up on small windows and returns the HUD's own layout
## size. Everything below lays out in that local space.
func _rq_apply_min_scale() -> Vector2:
	var vp := get_viewport_rect().size
	var window_h := float(get_window().size.y) if get_window() else vp.y
	var canvas_scale := window_h / maxf(1.0, vp.y)
	var s := maxf(1.0, RQ_MIN_UI_SCALE / maxf(0.01, canvas_scale))
	if OS.get_environment("ASCENDANT_UI_MIN_SCALE") == "0":
		s = 1.0
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	scale = Vector2.ONE * s
	position = Vector2.ZERO
	size = vp / s
	return size


func _fit_to_viewport() -> void:
	var vp := _rq_apply_min_scale()
	if vp.x <= 0.0 or vp.y <= 0.0:
		return
	var cx := vp.x * 0.5

	# Ribbon, Age medallion and plaque.
	var band := Rect2(cx - RQ_RIBBON_LEFT, 0.0, RQ_RIBBON_LEFT + RQ_RIBBON_RIGHT, RQ_RIBBON_HEIGHT)
	band.position.x = maxf(band.position.x, 8.0)
	var medal_c := Vector2(cx, 46.0)
	var plaque := Rect2(cx - 70.0, 98.0, 140.0, 26.0)
	if is_instance_valid(_rq_ribbon):
		_rq_ribbon.configure(band, medal_c, RQ_MEDAL_RADIUS, plaque)
	var slant := RQ_RIBBON_HEIGHT * 0.9
	if is_instance_valid(_top_panel):
		_top_panel.position = Vector2(band.position.x + slant + 6.0, 2.0)
		_top_panel.size = Vector2(cx - RQ_MEDAL_RADIUS - 30.0 - _top_panel.position.x, RQ_RIBBON_HEIGHT - 6.0)
	if is_instance_valid(_force_panel):
		_force_panel.position = Vector2(cx + RQ_MEDAL_RADIUS + 30.0, 2.0)
		_force_panel.size = Vector2(band.end.x - slant - 6.0 - _force_panel.position.x, RQ_RIBBON_HEIGHT - 6.0)
	if is_instance_valid(_age_panel):
		_age_panel.position = Vector2(cx - 74.0, 0.0)
		_age_panel.size = Vector2(148.0, plaque.end.y + 2.0)
		var stack := _age_panel.get_child(0) as Control
		if stack:
			var crest := stack.get_node_or_null("MatchFactionCrest") as Control
			if crest:
				crest.position = medal_c - _age_panel.position - Vector2(34, 38) - Vector2(8, 8)
				crest.size = Vector2(68, 76)
			var plaque_row := stack.get_node_or_null("AgePlaque") as Control
			if plaque_row:
				plaque_row.position = plaque.position - _age_panel.position - Vector2(8, 8)
				plaque_row.size = plaque.size
	if is_instance_valid(_menu_button):
		_menu_button.offset_left = -66.0
		_menu_button.offset_right = -14.0
		_menu_button.offset_top = 10.0
		_menu_button.offset_bottom = 56.0
	if is_instance_valid(_objective_panel):
		_objective_panel.offset_right = -78.0
		_objective_panel.offset_left = -78.0 - 330.0
		var objective_left := vp.x - 78.0 - 330.0
		var clear_of_band := objective_left >= band.end.x - 4.0
		_objective_panel.offset_top = 6.0 if clear_of_band else 64.0
		_objective_panel.offset_bottom = _objective_panel.offset_top + 96.0

	# Minimap housing, flush with the bottom-left corner.
	var map_rect := Rect2()
	if is_instance_valid(_minimap_panel):
		var map_min := _minimap_panel.get_combined_minimum_size()
		_minimap_panel.scale = Vector2.ONE * RQ_MINIMAP_SCALE
		_minimap_panel.offset_left = 10.0
		_minimap_panel.offset_right = 10.0 + map_min.x
		_minimap_panel.offset_top = -8.0 - map_min.y * RQ_MINIMAP_SCALE
		_minimap_panel.offset_bottom = _minimap_panel.offset_top + map_min.y
		var visual := Vector2(map_min.x, map_min.y) * RQ_MINIMAP_SCALE
		map_rect = Rect2(0.0, vp.y - visual.y - 18.0, visual.x + 24.0, visual.y + 18.0)

	# The deck.
	var deck_left := map_rect.end.x + 14.0
	var deck_width := minf(RQ_DECK_WIDTH, vp.x - deck_left - 16.0)
	var deck := Rect2(deck_left, vp.y - RQ_DECK_HEIGHT, deck_width, RQ_DECK_HEIGHT)
	var inner_top := deck.position.y + 16.0
	var inner_bottom := vp.y - 12.0
	var sel_right := deck.position.x + minf(RQ_SELECTION_SPAN, deck_width * 0.53)
	var wings: Array = []
	var socket := Rect2()

	if is_instance_valid(_sel_panel):
		var unit_view := _rq_unit_view and is_instance_valid(_selection_portrait)
		if unit_view:
			var medal := Rect2(deck.position.x + 14.0, vp.y - RQ_MEDALLION_SIZE - 20.0, RQ_MEDALLION_SIZE, RQ_MEDALLION_SIZE)
			_selection_portrait.scale = Vector2.ONE
			_selection_portrait.position = medal.position
			_selection_portrait.size = medal.size
			socket = medal
			_sel_panel.scale = Vector2.ONE
			var left := medal.end.x + 14.0
			_sel_panel.position = Vector2(left, inner_top - 4.0)
			_sel_panel.size = Vector2(sel_right - left - 10.0, inner_bottom - inner_top + 4.0)
			_sel_panel.custom_minimum_size = Vector2(0, 0)
		else:
			var sel_scale := INTERACTION_PANEL_SCALE
			_sel_panel.scale = Vector2.ONE * sel_scale
			var requested := SELECTION_PANEL_HEIGHT
			if _sel_panel.has_meta("multi_selection_height"):
				requested = float(_sel_panel.get_meta("multi_selection_height"))
			if is_instance_valid(_tracked_single) and _tracked_single is Building:
				requested = 196.0 if not _tracked_single.is_built else 176.0
			var width := (sel_right - deck.position.x - 28.0) / sel_scale
			var height := maxf(requested, _sel_panel.get_combined_minimum_size().y)
			height = minf(height, (vp.y * 0.42) / sel_scale)
			_sel_panel.size = Vector2(width, height)
			_sel_panel.position = Vector2(deck.position.x + 18.0, inner_bottom - height * sel_scale)
		var sel_rect := Rect2(_sel_panel.position, _sel_panel.size * _sel_panel.scale)
		if _sel_panel.visible and sel_rect.position.y < inner_top - 4.0:
			wings.append(sel_rect.grow(12.0))

	if is_instance_valid(_cmd_panel):
		var hero_deck := is_instance_valid(_cmd_body) and _cmd_body.get_child_count() > 0 and (_cmd_body.get_child(0).name in ["HeroDeck", "FieldOrders"])
		var cmd_scale := 1.0 if hero_deck else INTERACTION_PANEL_SCALE
		var cmd_left := sel_right + 18.0
		var cmd_width := (deck.end.x - 14.0 - cmd_left) / cmd_scale
		var fixed_height := _cmd_fixed.get_combined_minimum_size().y if is_instance_valid(_cmd_fixed) else 0.0
		var content := _cmd_body.get_combined_minimum_size().y + fixed_height + 22.0
		# Screen-space ceiling: the deck never climbs past ~45% of the screen; longer lists scroll.
		var ceiling := clampf(vp.y * 0.45, 430.0, 500.0) / cmd_scale
		var floor_h := (inner_bottom - inner_top) / cmd_scale
		var height := clampf(content, floor_h, ceiling)
		_cmd_panel.scale = Vector2.ONE * cmd_scale
		_cmd_panel.size = Vector2(cmd_width, height)
		_cmd_panel.position = Vector2(cmd_left, inner_bottom - height * cmd_scale)
		var cmd_rect := Rect2(_cmd_panel.position, _cmd_panel.size * cmd_scale)
		if _cmd_panel.visible and cmd_rect.position.y < inner_top - 4.0:
			wings.append(cmd_rect.grow(12.0))

	var deck_visible := (is_instance_valid(_sel_panel) and _sel_panel.visible) or (is_instance_valid(_cmd_panel) and _cmd_panel.visible)
	if is_instance_valid(_rq_deck):
		_rq_deck.configure(deck if deck_visible else Rect2(), wings, [sel_right + 4.0] if deck_visible else [], map_rect, socket if deck_visible else Rect2())
	queue_redraw()
