extends Control
## Skirmish Setup: pick a faction from illustrated banner cards, survey the
## battlefield on a tactical preview, set opponents and pace, then march into
## game_world. The Match config contract is unchanged.

const FACTION_SIGILS := preload("res://scripts/ui/faction_sigils.gd")
const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const PRESENTATION_THEME := "res://assets/ui/theme.tres"
const MapPreviewScript := preload("res://scripts/ui/map_preview.gd")

const DIFFICULTIES := ["easy", "normal", "hard", "brutal"]
const DIFF_LABELS := ["Easy", "Normal", "Hard", "Brutal"]
const RES_KINDS := ["standard", "quick", "rich"]
const RES_LABELS := ["Standard", "Quick", "Rich"]
const VICTORY_KINDS := ["conquest"]
const VICTORY_LABELS := ["Conquest"]

const GOLD := Color(0.86, 0.70, 0.40)
const GOLD_BRIGHT := Color(1.0, 0.86, 0.52)
const PARCHMENT := Color(0.93, 0.88, 0.76)
const MUTED := Color(0.72, 0.68, 0.60)
const INK := Color(0.055, 0.055, 0.065, 0.92)
const OPPONENT_COLORS := [Color(0.85, 0.28, 0.24), Color(0.36, 0.52, 0.90), Color(0.62, 0.40, 0.82)]

var _player_race := "barrosan"
var _identity_note: Label
var _race_cards := {}
var _race_detail_name: Label
var _race_detail_body: Label
var _race_detail_mechanic: Label
var _race_detail_swatch: ColorRect
var _num_opponents := 1
var _opp_rows := []          # array of {race, diff}
var _opp_container: VBoxContainer
var _count_row: HBoxContainer
var _res_kind := "standard"
var _victory := "conquest"
var _game_speed := 1.0
var _speed_label: Label
var _map_id := "hollowspan"
var _map_infos := []
var _map_preview: Control
var _map_caption: Label

func _race_ids() -> Array:
	return GameData.RACES.keys()

func _ready() -> void:
	if ResourceLoader.exists(PRESENTATION_THEME):
		theme = load(PRESENTATION_THEME)
	var h := ProfileManager.hero()
	if h.has("race"):
		_player_race = str(h.get("race", "barrosan"))
	var ids := _race_ids()
	if not ids.has(_player_race) and not ids.is_empty():
		_player_race = str(ids[0])
	_build()

func _title_font() -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font

func _body_font() -> Font:
	return ThemeDB.fallback_font

# --------------------------------------------------------------------------
# Layout
# --------------------------------------------------------------------------
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
	scrim.color = Color(0.02, 0.025, 0.04, 0.72)
	add_child(scrim)

	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		root.add_theme_constant_override("margin_" + side, 40)
	root.add_theme_constant_override("margin_top", 18)
	root.add_theme_constant_override("margin_bottom", 18)
	add_child(root)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	root.add_child(column)

	column.add_child(_title_block("Skirmish", "Muster your host and choose the field of battle"))

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	column.add_child(body)
	body.add_child(_build_faction_panel())
	body.add_child(_build_battle_panel())

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 24)
	column.add_child(footer)
	footer.add_child(_button("Back", Vector2(200, 50), func(): _goto("res://scenes/ui/main_menu.tscn")))
	var begin := _button("Begin Battle", Vector2(300, 54), _on_begin)
	_style_primary(begin)
	footer.add_child(begin)

	_select_race(_player_race, false)
	_refresh_map_preview()

func _title_block(title_text: String, subtitle_text: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	var title := Label.new()
	title.text = title_text
	title.add_theme_font_override("font", _title_font())
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", GOLD_BRIGHT)
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override("outline_size", 6)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sub := Label.new()
	sub.text = subtitle_text.to_upper()
	sub.add_theme_font_override("font", _title_font())
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	box.add_child(_rule())
	return box

func _panel(ratio: float) -> Array:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = ratio
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 22)
	panel.add_child(margin)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	margin.add_child(v)
	return [panel, v]

func _build_faction_panel() -> Control:
	var parts := _panel(1.35)
	var v: VBoxContainer = parts[1]
	v.add_child(_heading("Choose Your Faction"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_stretch_ratio = 3.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	# The cards grow to fill the panel on tall windows instead of leaving an
	# empty band between the list and the faction dossier.
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	for rid in _race_ids():
		var card := _race_card(str(rid))
		grid.add_child(card)
		_race_cards[str(rid)] = card

	# Selected faction dossier.
	var dossier := HBoxContainer.new()
	dossier.add_theme_constant_override("separation", 14)
	v.add_child(_rule())
	v.add_child(dossier)
	_race_detail_swatch = ColorRect.new()
	_race_detail_swatch.custom_minimum_size = Vector2(6, 0)
	dossier.add_child(_race_detail_swatch)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 4)
	dossier.add_child(text)
	_race_detail_name = Label.new()
	_race_detail_name.add_theme_font_override("font", _title_font())
	_race_detail_name.add_theme_font_size_override("font_size", 22)
	_race_detail_name.add_theme_color_override("font_color", GOLD_BRIGHT)
	text.add_child(_race_detail_name)
	_race_detail_body = _body_label(15, PARCHMENT)
	text.add_child(_race_detail_body)
	_race_detail_mechanic = _body_label(15, Color(0.95, 0.80, 0.48))
	text.add_child(_race_detail_mechanic)
	_identity_note = _body_label(13, MUTED)
	text.add_child(_identity_note)
	return parts[0]

func _race_card(rid: String) -> Button:
	var race: Dictionary = GameData.RACES.get(rid, {})
	var col: Color = race.get("color", Color(0.6, 0.6, 0.6))
	var card := Button.new()
	card.toggle_mode = true
	card.focus_mode = Control.FOCUS_NONE
	card.custom_minimum_size = Vector2(0, 76)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.clip_contents = true
	for state in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
		card.add_theme_stylebox_override(state, _card_style(col, state))
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 16
	row.offset_right = -12
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)
	var crest := _crest(race, col)
	row.add_child(crest)
	var text := VBoxContainer.new()
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.add_theme_constant_override("separation", 0)
	row.add_child(text)
	var name_label := Label.new()
	name_label.text = str(race.get("name", rid))
	name_label.add_theme_font_override("font", _title_font())
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", PARCHMENT)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.add_child(name_label)
	var tag := Label.new()
	tag.text = str(race.get("blurb", "")).get_slice(".", 0)
	tag.add_theme_font_override("font", _body_font())
	tag.add_theme_font_size_override("font_size", 13)
	tag.add_theme_color_override("font_color", MUTED)
	# Wraps to up to three lines, so taller cards show the faction's line in
	# full instead of a one-line fragment in an empty card.
	tag.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tag.max_lines_visible = 3
	tag.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.add_child(tag)
	card.pressed.connect(_select_race.bind(rid, true))
	# The shield leans in when hovered.
	card.mouse_entered.connect(func():
		crest.pivot_offset = crest.size * 0.5
		crest.create_tween().tween_property(crest, "scale", Vector2.ONE * 1.15, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))
	card.mouse_exited.connect(func():
		crest.create_tween().tween_property(crest, "scale", Vector2.ONE, 0.16))
	return card

func _crest(race: Dictionary, col: Color) -> Control:
	# A heraldic shield in the faction colour: gilt rim, a lighter chief and
	# the faction's initial, until each faction has painted crest art.
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(46, 54)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var race_id := ""
	for k in GameData.RACES:
		if GameData.RACES[k] == race:
			race_id = String(k)
	holder.draw.connect(func():
		var w := holder.size.x
		var h := holder.size.y
		var m := 2.0
		var shield := PackedVector2Array([Vector2(m, m), Vector2(w - m, m), Vector2(w - m, h * 0.55), Vector2(w * 0.5, h - m), Vector2(m, h * 0.55)])
		holder.draw_colored_polygon(shield, Color(0.05, 0.04, 0.03, 0.95))
		var c := Vector2(w * 0.5, h * 0.45)
		var inner := PackedVector2Array()
		for p in shield:
			inner.append(c + (p - c) * 0.84)
		holder.draw_colored_polygon(inner, col.darkened(0.2))
		holder.draw_rect(Rect2(inner[0], Vector2(inner[1].x - inner[0].x, h * 0.16)), Color(col.lightened(0.2), 0.55))
		shield.append(shield[0])
		holder.draw_polyline(shield, GOLD, 1.8, true)
		FACTION_SIGILS.draw(holder, race_id, Vector2(w * 0.5, h * 0.47), w * 0.3, Color(0.99, 0.93, 0.75)))
	return holder

func _card_style(col: Color, state: String) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	var selected := state == "pressed" or state == "hover_pressed"
	var hover := state == "hover" or state == "hover_pressed"
	sb.bg_color = Color(0.07, 0.07, 0.08, 0.92).lerp(col.darkened(0.55), 0.35 if selected else (0.18 if hover else 0.0))
	sb.border_color = GOLD_BRIGHT if selected else (GOLD.darkened(0.2) if hover else Color(0.30, 0.26, 0.20))
	sb.set_border_width_all(2 if selected else 1)
	sb.border_width_left = 5
	if not selected:
		sb.border_color = sb.border_color
	sb.set_corner_radius_all(3)
	sb.shadow_color = Color(col, 0.35) if selected else Color(0, 0, 0, 0)
	sb.shadow_size = 8 if selected else 0
	if state == "focus":
		sb.draw_center = false
		sb.set_border_width_all(0)
	return sb

func _build_battle_panel() -> Control:
	var parts := _panel(1.0)
	var v: VBoxContainer = parts[1]
	v.add_child(_heading("Battlefield"))
	var map_opt := OptionButton.new()
	map_opt.custom_minimum_size = Vector2(0, 38)
	_map_infos = MapDefs.list_infos()
	map_opt.add_item("Random Battlefield", 0)
	for i in _map_infos.size():
		map_opt.add_item(str(_map_infos[i]["name"]), i + 1)
	var default_index := 0
	for i in _map_infos.size():
		if str(_map_infos[i]["id"]) == _map_id:
			default_index = i + 1
	map_opt.select(default_index)
	map_opt.item_selected.connect(func(idx):
		Sfx.play("select")
		_map_id = "__random__" if idx == 0 else str(_map_infos[idx - 1]["id"])
		_refresh_map_preview())
	v.add_child(map_opt)
	var preview_row := HBoxContainer.new()
	preview_row.add_theme_constant_override("separation", 14)
	preview_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(preview_row)
	_map_preview = MapPreviewScript.new()
	_map_preview.custom_minimum_size = Vector2(190, 190)
	_map_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_row.add_child(_map_preview)
	_map_caption = _body_label(13, MUTED)
	_map_caption.custom_minimum_size = Vector2(150, 0)
	_map_caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	preview_row.add_child(_map_caption)

	v.add_child(_rule())
	var opp_head := HBoxContainer.new()
	opp_head.add_theme_constant_override("separation", 8)
	v.add_child(opp_head)
	var opp_label := _heading("Opponents")
	opp_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opp_head.add_child(opp_label)
	_count_row = HBoxContainer.new()
	_count_row.add_theme_constant_override("separation", 6)
	opp_head.add_child(_count_row)
	for n in [1, 2, 3]:
		var b := Button.new()
		b.toggle_mode = true
		b.custom_minimum_size = Vector2(44, 34)
		b.focus_mode = Control.FOCUS_NONE
		b.button_pressed = (n == _num_opponents)
		_label_button(b, str(n), Color.WHITE)
		b.pressed.connect(_set_opponents.bind(n))
		b.set_meta("count", n)
		_count_row.add_child(b)
	_opp_container = VBoxContainer.new()
	_opp_container.add_theme_constant_override("separation", 6)
	v.add_child(_opp_container)
	_rebuild_opponents()

	var settings := GridContainer.new()
	settings.columns = 2
	settings.add_theme_constant_override("h_separation", 14)
	settings.add_theme_constant_override("v_separation", 8)
	v.add_child(settings)
	settings.add_child(_setting_label("Resources"))
	settings.add_child(_choice_row(RES_LABELS, RES_KINDS, func(k): _res_kind = k, _res_kind))
	settings.add_child(_setting_label("Victory"))
	settings.add_child(_choice_row(VICTORY_LABELS, VICTORY_KINDS, func(k): _victory = k, _victory))
	settings.add_child(_setting_label("Game Speed"))
	var speed_row := HBoxContainer.new()
	speed_row.add_theme_constant_override("separation", 10)
	speed_row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var slider := HSlider.new()
	slider.min_value = 0.5
	slider.max_value = 2.0
	slider.step = 0.1
	slider.value = _game_speed
	slider.custom_minimum_size = Vector2(170, 28)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(func(val): _game_speed = val; _update_speed())
	speed_row.add_child(slider)
	_speed_label = _body_label(15, GOLD_BRIGHT)
	_speed_label.custom_minimum_size = Vector2(44, 0)
	speed_row.add_child(_speed_label)
	settings.add_child(speed_row)
	_update_speed()
	return parts[0]

# --------------------------------------------------------------------------
# State
# --------------------------------------------------------------------------
func _select_race(rid: String, play_sound: bool) -> void:
	_player_race = rid
	for key in _race_cards:
		_race_cards[key].button_pressed = key == rid
	var race: Dictionary = GameData.RACES.get(rid, {})
	_race_detail_name.text = str(race.get("name", rid))
	_race_detail_body.text = str(race.get("blurb", ""))
	_race_detail_mechanic.text = str(race.get("mechanic", ""))
	_race_detail_swatch.color = race.get("color", GOLD)
	_update_identity_note()
	_refresh_map_preview()
	if play_sound:
		Sfx.play("select")

func _set_opponents(n: int) -> void:
	Sfx.play("select")
	_num_opponents = n
	for b in _count_row.get_children():
		if b is Button:
			b.button_pressed = (b.get_meta("count", 0) == n)
	_rebuild_opponents()
	_refresh_map_preview()

func _update_identity_note() -> void:
	if not is_instance_valid(_identity_note):
		return
	var profile := ProfileManager.hero()
	if profile.is_empty():
		_identity_note.text = "No profile hero yet. Forge one from the main menu to carry progression into battle."
		return
	var profile_race := str(profile.get("race", "unknown"))
	var profile_race_name: String = str(GameData.RACES.get(profile_race, {}).get("name", profile_race))
	_identity_note.text = "Your hero %s of the %s leads this host. Persistent progression applies." % [str(profile.get("name", "Unnamed hero")), profile_race_name]

func _rebuild_opponents() -> void:
	for c in _opp_container.get_children():
		c.queue_free()
	_opp_rows.clear()
	var opp_race_ids := _race_ids()
	var preferred_defaults := ["vorthak", "lioraen", "vorthak"]
	var defaults: Array = []
	for pd in preferred_defaults:
		if opp_race_ids.has(pd):
			defaults.append(pd)
		elif not opp_race_ids.is_empty():
			defaults.append(str(opp_race_ids[0]))
		else:
			defaults.append("")
	for i in _num_opponents:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var marker := ColorRect.new()
		marker.color = OPPONENT_COLORS[i % OPPONENT_COLORS.size()]
		marker.custom_minimum_size = Vector2(6, 34)
		row.add_child(marker)
		# The rival's shield, redrawn as the chosen faction changes.
		var opp_shield := Control.new()
		opp_shield.custom_minimum_size = Vector2(30, 34)
		opp_shield.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(opp_shield)
		var race_opt := OptionButton.new()
		race_opt.custom_minimum_size = Vector2(0, 34)
		race_opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for j in opp_race_ids.size():
			var rid: String = str(opp_race_ids[j])
			race_opt.add_item(GameData.RACES[rid].get("name", rid), j)
		var def_idx: int = opp_race_ids.find(defaults[i]) if i < defaults.size() else -1
		race_opt.select(max(0, def_idx))
		var ids_ref: Array = opp_race_ids
		opp_shield.draw.connect(func():
			var rid2 := String(ids_ref[clampi(race_opt.selected, 0, ids_ref.size() - 1)])
			var col: Color = GameData.RACES.get(rid2, {}).get("color", Color(0.6, 0.6, 0.6))
			var w := opp_shield.size.x
			var h := opp_shield.size.y
			var shield := PackedVector2Array([Vector2(1, 1), Vector2(w - 1, 1), Vector2(w - 1, h * 0.55), Vector2(w * 0.5, h - 1), Vector2(1, h * 0.55)])
			opp_shield.draw_colored_polygon(shield, Color(0.05, 0.04, 0.03, 0.95))
			var c := Vector2(w * 0.5, h * 0.45)
			var inner := PackedVector2Array()
			for pnt in shield:
				inner.append(c + (pnt - c) * 0.84)
			opp_shield.draw_colored_polygon(inner, col.darkened(0.2))
			shield.append(shield[0])
			opp_shield.draw_polyline(shield, GOLD, 1.4, true)
			FACTION_SIGILS.draw(opp_shield, rid2, Vector2(w * 0.5, h * 0.47), w * 0.3, Color(0.99, 0.93, 0.75)))
		race_opt.item_selected.connect(func(_idx):
			Sfx.play("select")
			opp_shield.queue_redraw())
		row.add_child(race_opt)
		var diff_opt := OptionButton.new()
		diff_opt.custom_minimum_size = Vector2(118, 34)
		for j in DIFF_LABELS.size():
			diff_opt.add_item(DIFF_LABELS[j], j)
		diff_opt.select(1)
		diff_opt.item_selected.connect(func(_idx): Sfx.play("select"))
		row.add_child(diff_opt)
		_opp_container.add_child(row)
		_opp_rows.append({"race": race_opt, "diff": diff_opt})

func _refresh_map_preview() -> void:
	if not is_instance_valid(_map_preview):
		return
	var player_col: Color = GameData.RACES.get(_player_race, {}).get("color", GOLD)
	var opp_cols: Array = []
	for i in _num_opponents:
		opp_cols.append(OPPONENT_COLORS[i % OPPONENT_COLORS.size()])
	if _map_id == "__random__":
		_map_preview.show_map({}, player_col, opp_cols)
		_map_caption.text = "A battlefield is drawn at random when the host marches."
		return
	var data := MapDefs.get_map(_map_id)
	_map_preview.show_map(data, player_col, opp_cols)
	var info := {}
	for m in _map_infos:
		if str(m["id"]) == _map_id:
			info = m
	_map_caption.text = "%s\n\nYour banner is ringed in gold. Violet marks are shrines; coloured dots are gold, stone, timber and food. Ringed marks are veins, where a worker can raise an outpost for steady income." % str(info.get("desc", ""))

func _pick_map() -> String:
	if _map_id == "__random__":
		if _map_infos.is_empty():
			return "hollowspan"
		return str(_map_infos[randi() % _map_infos.size()]["id"])
	return _map_id

func _update_speed() -> void:
	_speed_label.text = "%.1fx" % _game_speed

func _on_begin() -> void:
	Sfx.play("select")
	var opp_race_ids := _race_ids()
	var opponents := []
	for r in _opp_rows:
		var sel_idx: int = r["race"].get_selected_id()
		var race: String = str(opp_race_ids[sel_idx]) if sel_idx >= 0 and sel_idx < opp_race_ids.size() else "barrosan"
		var diff: String = DIFFICULTIES[r["diff"].get_selected_id()]
		opponents.append({"race": race, "difficulty": diff})
	var cfg := Match.default_config()
	cfg["player_race"] = _player_race
	cfg["opponents"] = opponents
	cfg["start_resources"] = _res_kind
	cfg["victory"] = _victory
	cfg["mode"] = "skirmish"
	cfg["game_speed"] = _game_speed
	cfg["map"] = _pick_map()
	Match.set_config(cfg)
	LoadingScreen.preload_and_change_scene("res://scenes/game_world.tscn", 1.5)

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
func _heading(text: String) -> Label:
	var l := Label.new()
	l.text = text.to_upper()
	l.add_theme_font_override("font", _title_font())
	l.add_theme_font_size_override("font_size", 17)
	l.add_theme_color_override("font_color", GOLD)
	l.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	l.add_theme_constant_override("outline_size", 3)
	return l

func _setting_label(text: String) -> Label:
	var l := _body_label(14, MUTED)
	l.text = text.to_upper()
	l.add_theme_font_override("font", _title_font())
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.custom_minimum_size = Vector2(120, 0)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l

func _body_label(font_size: int, col: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", _body_font())
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", col)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _rule() -> Control:
	var line := ColorRect.new()
	line.color = Color(GOLD, 0.35)
	line.custom_minimum_size = Vector2(0, 2)
	return line

func _choice_row(labels: Array, keys: Array, setter: Callable, current: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var buttons := []
	for i in labels.size():
		var b := Button.new()
		b.toggle_mode = true
		b.custom_minimum_size = Vector2(104, 34)
		b.focus_mode = Control.FOCUS_NONE
		b.button_pressed = (keys[i] == current)
		_label_button(b, labels[i], Color.WHITE)
		b.set_meta("key", keys[i])
		buttons.append(b)
		b.pressed.connect(func():
			Sfx.play("select")
			setter.call(keys[i])
			for other in buttons:
				other.button_pressed = (other == b))
		row.add_child(b)
	return row

func _label_button(b: Button, text: String, col: Color) -> void:
	b.text = text
	b.clip_text = false
	b.add_theme_font_override("font", _body_font())
	b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	b.add_theme_color_override("font_color", col)
	b.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))

func _button(text: String, size: Vector2, cb: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = size
	b.focus_mode = Control.FOCUS_NONE
	_label_button(b, text, Color(0.96, 0.92, 0.8))
	b.add_theme_font_override("font", _title_font())
	b.pressed.connect(cb)
	return b

func _style_primary(b: Button) -> void:
	for state in ["normal", "hover", "pressed"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.36, 0.22, 0.08) if state == "normal" else (Color(0.50, 0.32, 0.12) if state == "hover" else Color(0.28, 0.17, 0.06))
		sb.border_color = GOLD_BRIGHT
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(3)
		sb.shadow_color = Color(0.95, 0.65, 0.25, 0.35)
		sb.shadow_size = 10 if state == "hover" else 6
		b.add_theme_stylebox_override(state, sb)
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", Color(1.0, 0.93, 0.74))

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)
