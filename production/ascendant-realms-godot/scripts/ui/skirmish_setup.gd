extends Control
## Skirmish Setup — configure a custom battle: races, opponents, resources,
## victory type and speed, then march into game_world.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const PRESENTATION_THEME := "res://assets/ui/theme.tres"

const DIFFICULTIES := ["easy", "normal", "hard", "brutal"]
const DIFF_LABELS := ["Easy", "Normal", "Hard", "Brutal"]
const RES_KINDS := ["standard", "quick", "rich"]
const RES_LABELS := ["Standard", "Quick", "Rich"]
const VICTORY_KINDS := ["conquest"]
const VICTORY_LABELS := ["Conquest"]

var _player_race := "barrosan"
var _player_opt: OptionButton
var _identity_note: Label
var _num_opponents := 1
var _opp_rows := []          # array of {race_opt, diff_opt}
var _opp_container: VBoxContainer
var _res_kind := "standard"
var _victory := "conquest"
var _game_speed := 1.0
var _speed_label: Label
var _map_id := "__random__"
var _map_infos := []

func _race_ids() -> Array:
	return GameData.RACES.keys()

func _ready() -> void:
	if ResourceLoader.exists(PRESENTATION_THEME):
		theme = load(PRESENTATION_THEME)
	var h := ProfileManager.hero()
	if h.has("race"):
		_player_race = str(h.get("race", "barrosan"))
	# Ensure default is a valid race
	var ids := _race_ids()
	if not ids.has(_player_race) and not ids.is_empty():
		_player_race = str(ids[0])
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
	scrim.color = Color(0.02, 0.03, 0.05, 0.75)
	add_child(scrim)

	var title := Label.new()
	title.text = "Skirmish"
	title.add_theme_font_override("font", _title_font())
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.96, 0.9, 0.7))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 20.0
	title.offset_bottom = 70.0
	add_child(title)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 84.0
	scroll.offset_bottom = -80.0
	scroll.offset_left = 60.0
	scroll.offset_right = -60.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 16)
	scroll.add_child(v)

	# Player race
	v.add_child(_heading("Your Race"))
	_player_opt = OptionButton.new()
	_player_opt.custom_minimum_size = Vector2(300, 40)
	var race_ids := _race_ids()
	for i in race_ids.size():
		var rid: String = str(race_ids[i])
		_player_opt.add_item(GameData.RACES[rid].get("name", rid), i)
	var player_idx: int = race_ids.find(_player_race)
	_player_opt.select(max(0, player_idx))
	_player_opt.item_selected.connect(_on_player_race_selected.bind(race_ids))
	v.add_child(_player_opt)
	_identity_note = Label.new()
	_identity_note.add_theme_font_override("font", _body_font())
	_identity_note.add_theme_color_override("font_color", Color(0.8, 0.8, 0.72))
	_identity_note.add_theme_font_size_override("font_size", 16)
	_identity_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_identity_note.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	v.add_child(_identity_note)
	_update_identity_note()

	# Opponent count
	v.add_child(_heading("Opponents"))
	var count_row := HBoxContainer.new()
	count_row.add_theme_constant_override("separation", 10)
	v.add_child(count_row)
	for n in [1, 2, 3]:
		var b := Button.new()
		b.toggle_mode = true
		b.custom_minimum_size = Vector2(70, 40)
		b.focus_mode = Control.FOCUS_NONE
		b.button_pressed = (n == _num_opponents)
		_label_button(b, str(n), Color.WHITE)
		b.pressed.connect(_set_opponents.bind(n))
		count_row.add_child(b)
		b.set_meta("count", n)
	# store count buttons for toggle sync
	_count_row = count_row

	_opp_container = VBoxContainer.new()
	_opp_container.add_theme_constant_override("separation", 8)
	v.add_child(_opp_container)
	_rebuild_opponents()

	# Starting resources
	v.add_child(_heading("Starting Resources"))
	v.add_child(_choice_row(RES_LABELS, RES_KINDS, func(k): _res_kind = k, _res_kind))

	# Battlefield
	v.add_child(_heading("Battlefield"))
	var map_opt := OptionButton.new()
	map_opt.custom_minimum_size = Vector2(420, 40)
	_map_infos = MapDefs.list_infos()
	map_opt.add_item("Random Battlefield", 0)
	for i in _map_infos.size():
		map_opt.add_item("%s  ·  %s" % [_map_infos[i]["name"], _map_infos[i]["desc"]], i + 1)
	map_opt.select(0)
	map_opt.item_selected.connect(func(idx):
		Sfx.play("select")
		_map_id = "__random__" if idx == 0 else str(_map_infos[idx - 1]["id"]))
	v.add_child(map_opt)

	# Victory
	v.add_child(_heading("Victory Condition"))
	v.add_child(_choice_row(VICTORY_LABELS, VICTORY_KINDS, func(k): _victory = k, _victory))

	# Game speed
	v.add_child(_heading("Game Speed"))
	_speed_label = Label.new()
	_speed_label.add_theme_font_override("font", _body_font())
	_speed_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	v.add_child(_speed_label)
	var slider := HSlider.new()
	slider.min_value = 0.5
	slider.max_value = 2.0
	slider.step = 0.1
	slider.value = _game_speed
	slider.custom_minimum_size = Vector2(360, 30)
	slider.value_changed.connect(func(val): _game_speed = val; _update_speed())
	v.add_child(slider)
	_update_speed()

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
	footer.add_child(_button("Back", Vector2(200, 50), func(): _goto("res://scenes/ui/main_menu.tscn")))
	footer.add_child(_button("Begin Battle", Vector2(260, 50), _on_begin))

var _count_row: HBoxContainer

func _set_opponents(n: int) -> void:
	Sfx.play("select")
	_num_opponents = n
	for b in _count_row.get_children():
		if b is Button:
			b.button_pressed = (b.get_meta("count", 0) == n)
	_rebuild_opponents()

func _on_player_race_selected(idx: int, race_ids: Array) -> void:
	if idx >= 0 and idx < race_ids.size():
		_player_race = str(race_ids[idx])
	_update_identity_note()
	Sfx.play("select")

func _update_identity_note() -> void:
	if not is_instance_valid(_identity_note):
		return
	var profile := ProfileManager.hero()
	var faction_name: String = str(GameData.RACES.get(_player_race, {}).get("name", _player_race))
	if profile.is_empty():
		_identity_note.text = "Profile hero: none. Skirmish faction: %s." % faction_name
		return
	var profile_race := str(profile.get("race", "unknown"))
	var profile_race_name: String = str(GameData.RACES.get(profile_race, {}).get("name", profile_race))
	_identity_note.text = "Profile hero: %s — %s. Skirmish faction: %s. Persistent hero progression will be applied to this battle." % [str(profile.get("name", "Unnamed hero")), profile_race_name, faction_name]

func _rebuild_opponents() -> void:
	for c in _opp_container.get_children():
		c.queue_free()
	_opp_rows.clear()
	var opp_race_ids := _race_ids()
	# Preferred defaults — fall back to first available race
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
		row.add_theme_constant_override("separation", 12)
		var lbl := Label.new()
		lbl.text = "Opponent %d" % (i + 1)
		lbl.add_theme_font_override("font", _body_font())
		lbl.custom_minimum_size = Vector2(140, 40)
		lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
		lbl.add_theme_font_size_override("font_size", 16)
		row.add_child(lbl)
		var race_opt := OptionButton.new()
		race_opt.custom_minimum_size = Vector2(220, 40)
		for j in opp_race_ids.size():
			var rid: String = str(opp_race_ids[j])
			race_opt.add_item(GameData.RACES[rid].get("name", rid), j)
		var def_idx: int = opp_race_ids.find(defaults[i]) if i < defaults.size() else -1
		race_opt.select(max(0, def_idx))
		race_opt.item_selected.connect(func(_idx): Sfx.play("select"))
		row.add_child(race_opt)
		var diff_opt := OptionButton.new()
		diff_opt.custom_minimum_size = Vector2(160, 40)
		for j in DIFF_LABELS.size():
			diff_opt.add_item(DIFF_LABELS[j], j)
		diff_opt.select(1)
		diff_opt.item_selected.connect(func(_idx): Sfx.play("select"))
		row.add_child(diff_opt)
		_opp_container.add_child(row)
		_opp_rows.append({"race": race_opt, "diff": diff_opt})

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

# --- helpers --------------------------------------------------------------
func _heading(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _title_font())
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color(0.9, 0.78, 0.5))
	l.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	l.add_theme_constant_override("outline_size", 4)
	return l

func _choice_row(labels: Array, keys: Array, setter: Callable, current: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var buttons := []
	for i in labels.size():
		var b := Button.new()
		b.toggle_mode = true
		b.custom_minimum_size = Vector2(150, 42)
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
	b.pressed.connect(cb)
	return b

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)
