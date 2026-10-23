extends Control
## Map Editor (plan 478): paint a battlefield on a top-down board and play it.
##
## The board is the skirmish map preview, redrawn from the draft after every
## change, so what you paint is what the game will build. Everything placed
## can be mirrored (turned half round the middle by default), which keeps a
## map fair for both sides. Maps are saved as JSON in user://maps and appear
## in the skirmish map list.

const MapPreviewScript := preload("res://scripts/ui/map_preview.gd")
const CM := preload("res://scripts/world/custom_maps.gd")
const PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")
const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"

const GOLD := Color(0.86, 0.70, 0.40)
const GOLD_BRIGHT := Color(1.0, 0.86, 0.52)
const PARCHMENT := Color(0.93, 0.88, 0.76)
const MUTED := Color(0.76, 0.72, 0.64)
const BAD := Color(1.0, 0.58, 0.48)
const CAMP_COLORS := [Color(0.95, 0.80, 0.40), Color(0.85, 0.28, 0.24), Color(0.36, 0.52, 0.90), Color(0.62, 0.40, 0.82)]

## id, label, hint. Groups are separated by "" entries.
const TOOLS := [
	["move", "Move", "Drag a camp, site, resource, wood, hill or lake."],
	["erase", "Erase", "Click anything to remove it (and its mirror twin)."],
	["", "", ""],
	["start", "Camp", "Click to place a camp. Two to four camps."],
	["lume", "Lume Site", "A Lume site: holds pay income."],
	["ruin", "Shrine", "A shrine site: heals units near it."],
	["watch", "Watchtower", "A watch site: gives sight around it."],
	["vein", "Vein", "A vein: an outpost can be built on it."],
	["deposit", "Deposit", "A loose deposit workers gather from."],
	["", "", ""],
	["wood", "Wood", "Drag out a wood. Woods block marching."],
	["hill", "Hill", "Drag out a hill. Hills block marching."],
	["lake", "Lake", "Drag out a lake."],
	["ridge", "Rock Ridge", "Click points, right-click to finish."],
	["wall", "Stone Wall", "Click points, right-click to finish."],
	["river", "River", "Click points, right-click to finish."],
	["ford", "Ford", "Click on a river to make a crossing."],
	["road", "Road", "Click points, right-click to finish."],
	["", "", ""],
	["asset", "Assets", "Pick a building, unit or model below, then click the map to place it. Test in 3D to see it in the game's light."],
]
const ASSET_KINDS := ["building", "unit", "scenery"]
const ASSET_KIND_NAMES := ["Buildings", "Units", "Scenery and models"]
const SCENERY_DIRS := ["res://assets/environment", "res://assets/props", "res://assets/characters"]
const LINE_TOOLS := ["ridge", "wall", "river", "road"]
const BLOB_TOOLS := ["wood", "hill", "lake"]
const MIRRORS := ["point", "flip_x", "flip_z", "none"]
const MIRROR_NAMES := ["Turned (fair)", "Left / right", "Top / bottom", "Off"]

var doc: Dictionary = {}
var tool := "start"
var kind := "gold"
var mirror := "point"
var brush := 18.0
var line_width := 10.0

var _board: Control
var _overlay: Control
var _name_edit: LineEdit
var _theme_opt: OptionButton
var _size_opt: OptionButton
var _mood_opt: OptionButton
var _mirror_opt: OptionButton
var _brush_slider: HSlider
var _width_slider: HSlider
var _brush_label: Label
var _width_label: Label
var _kind_row: HBoxContainer
var _kind_buttons := {}
var _tool_buttons := {}
var _hint: Label
var _status: Label
var _problems: Label
var _list: ItemList
var _delete_button: Button
var _asset_box: VBoxContainer
var _asset_kind_opt: OptionButton
var _asset_race_opt: OptionButton
var _asset_list: ItemList
var _asset_team := 0
var _asset_yaw := 0.0
var _asset_scale := 1.0
var _asset_turn_label: Label
var _asset_size_label: Label
var _asset_size_slider: HSlider
var _race_ids: Array = []
var _scenery_cache: Array = []
var _delete_armed := false

var _draft: Array = []           # points of the line being drawn, [x, z]
var _drag := {}                  # what is being dragged or dragged out
var _hover := Vector2.INF        # cursor in world metres
var _undo: Array = []
var _next_group := 100


func _ready() -> void:
	doc = CM.new_doc()
	# Back from Test in 3D: carry on with the same map.
	var cfg: Dictionary = Match.get_config()
	if bool(cfg.get("sandbox", false)):
		var back := CM.load_doc(CM.path_for(String(cfg.get("map", ""))))
		if not back.is_empty():
			doc = back
			for list_name in ["starts", "sites", "veins", "deposits", "woods", "hills", "lakes", "ridges", "rivers", "roads", "showcase"]:
				for item in doc[list_name]:
					_next_group = maxi(_next_group, int(item.get("g", 0)))
		Match.set_config(Match.default_config())
	_build()
	_refresh_all()


# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------
func _title_font() -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font


func _label(text: String, size: int, col: Color, title := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 3)
	if title:
		l.add_theme_font_override("font", _title_font())
	return l


func _plate(pos: Vector2, size_px: Vector2) -> PanelContainer:
	var p: PanelContainer = PLATE_SCRIPT.new()
	p.set("forged", true)
	var st := StyleBoxFlat.new()
	st.bg_color = Color.TRANSPARENT
	st.set_content_margin_all(18)
	p.add_theme_stylebox_override("panel", st)
	p.position = pos
	p.size = size_px
	add_child(p)
	return p


func _button(text: String, cb: Callable, w := 0.0) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(w, 38)
	b.add_theme_font_size_override("font_size", 17)
	b.pressed.connect(cb)
	return b


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
	scrim.color = Color(0.02, 0.025, 0.04, 0.80)
	add_child(scrim)

	var vp := get_viewport_rect().size
	var title := _label("MAP EDITOR", 34, GOLD_BRIGHT, true)
	title.position = Vector2(40, 22)
	add_child(title)
	var sub := _label("Paint a battlefield, then play it in Skirmish.", 18, MUTED)
	sub.position = Vector2(42, 70)
	add_child(sub)

	# Tools, on the left.
	var left := _plate(Vector2(30, 110), Vector2(300, vp.y - 140))
	var tools := VBoxContainer.new()
	tools.add_theme_constant_override("separation", 4)
	left.add_child(tools)
	tools.add_child(_label("TOOLS", 18, GOLD, true))
	var group := ButtonGroup.new()
	# Two columns, so the asset list below has room.
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	tools.add_child(grid)
	for t in TOOLS:
		if String(t[0]).is_empty():
			continue
		var b := _button(String(t[1]), _set_tool.bind(String(t[0])))
		b.toggle_mode = true
		b.button_group = group
		b.custom_minimum_size = Vector2(128, 34)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 16)
		b.clip_text = true
		b.tooltip_text = String(t[2])
		grid.add_child(b)
		_tool_buttons[String(t[0])] = b
	_kind_row = HBoxContainer.new()
	_kind_row.add_theme_constant_override("separation", 4)
	var kgroup := ButtonGroup.new()
	for k in CM.KINDS:
		var kb := _button(String(k).capitalize(), _set_kind.bind(String(k)))
		kb.toggle_mode = true
		kb.button_group = kgroup
		kb.custom_minimum_size = Vector2(62, 34)
		kb.add_theme_font_size_override("font_size", 15)
		kb.add_theme_color_override("font_color", MapPreviewScript.KIND_COLORS[k].lightened(0.2))
		_kind_row.add_child(kb)
		_kind_buttons[k] = kb
	tools.add_child(_kind_row)
	_hint = _label("", 16, PARCHMENT)
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.custom_minimum_size = Vector2(250, 0)
	tools.add_child(_hint)
	_build_asset_box(tools)

	# The board, in the middle.
	var right_w := 360.0
	var side := minf(vp.y - 140.0, vp.x - 300.0 - right_w - 120.0)
	var board_x := 330.0 + (vp.x - 330.0 - right_w - 30.0 - side) * 0.5
	_board = MapPreviewScript.new()
	_board.position = Vector2(board_x, 110)
	_board.size = Vector2(side, side)
	_board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_board)
	_overlay = Control.new()
	_overlay.position = _board.position
	_overlay.size = _board.size
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.draw.connect(_draw_overlay)
	_overlay.gui_input.connect(_board_input)
	_overlay.mouse_exited.connect(func():
		_hover = Vector2.INF
		_overlay.queue_redraw())
	add_child(_overlay)

	# Settings and files, on the right.
	var right := _plate(Vector2(vp.x - right_w - 30.0, 110), Vector2(right_w, vp.y - 140))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	right.add_child(col)
	col.add_child(_label("BATTLEFIELD", 18, GOLD, true))
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Name"
	_name_edit.max_length = 40
	_name_edit.add_theme_font_size_override("font_size", 18)
	_name_edit.text_changed.connect(func(t: String):
		doc["name"] = t
		_refresh_problems())
	col.add_child(_name_edit)
	_theme_opt = _option(col, "Land", [])
	for t in CM.THEMES:
		_theme_opt.add_item(String(t).capitalize())
	_theme_opt.item_selected.connect(func(i: int):
		_push_undo()
		doc["theme"] = CM.THEMES[i]
		_refresh_all())
	_mood_opt = _option(col, "Light", CM.MOOD_NAMES)
	_mood_opt.tooltip_text = "The hour and weather of this battlefield, in Skirmish and in Test in 3D."
	_mood_opt.item_selected.connect(func(i: int):
		doc["mood"] = CM.MOODS[i])
	_size_opt = _option(col, "Size", CM.SIZE_NAMES)
	_size_opt.item_selected.connect(_on_size)
	_mirror_opt = _option(col, "Mirror", MIRROR_NAMES)
	_mirror_opt.tooltip_text = "Everything you place gets a twin. Turned half round the middle is the fairest for two to four camps."
	_mirror_opt.item_selected.connect(func(i: int):
		mirror = MIRRORS[i]
		_overlay.queue_redraw())
	_brush_label = _label("", 16, PARCHMENT)
	col.add_child(_brush_label)
	_brush_slider = _slider(col, 6.0, 60.0, brush, func(v: float):
		brush = v
		_refresh_sliders())
	_width_label = _label("", 16, PARCHMENT)
	col.add_child(_width_label)
	_width_slider = _slider(col, 4.0, 40.0, line_width, func(v: float):
		line_width = v
		_refresh_sliders())

	var file_row := HBoxContainer.new()
	file_row.add_theme_constant_override("separation", 6)
	file_row.add_child(_button("New", _on_new, 100))
	file_row.add_child(_button("Undo", _on_undo, 100))
	file_row.add_child(_button("Save", _on_save, 100))
	col.add_child(file_row)
	col.add_child(_label("SAVED MAPS", 18, GOLD, true))
	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(0, 130)
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.add_theme_font_size_override("font_size", 17)
	_list.item_activated.connect(func(_i: int): _on_load())
	col.add_child(_list)
	var list_row := HBoxContainer.new()
	list_row.add_theme_constant_override("separation", 6)
	list_row.add_child(_button("Load", _on_load, 150))
	_delete_button = _button("Delete", _on_delete, 150)
	list_row.add_child(_delete_button)
	col.add_child(list_row)
	_problems = _label("", 16, BAD)
	_problems.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_problems)
	_status = _label("", 16, GOLD_BRIGHT)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_status)
	var play_row := HBoxContainer.new()
	play_row.add_theme_constant_override("separation", 6)
	var play := _button("Play in Skirmish", _on_play)
	play.custom_minimum_size = Vector2(0, 46)
	play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play.add_theme_font_size_override("font_size", 18)
	play_row.add_child(play)
	var test := _button("Test in 3D", _on_test)
	test.custom_minimum_size = Vector2(0, 46)
	test.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	test.add_theme_font_size_override("font_size", 18)
	test.tooltip_text = "Opens this map with no fog and the enemy staying home, to look at what you placed. Nothing is won or recorded."
	play_row.add_child(test)
	col.add_child(play_row)
	col.add_child(_button("Back to Menu", _on_back))

	_tool_buttons[tool].button_pressed = true
	_kind_buttons[kind].button_pressed = true


func _build_asset_box(parent: Control) -> void:
	_asset_box = VBoxContainer.new()
	_asset_box.add_theme_constant_override("separation", 4)
	_asset_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(_asset_box)
	_asset_kind_opt = OptionButton.new()
	_asset_kind_opt.focus_mode = Control.FOCUS_NONE
	_asset_kind_opt.add_theme_font_size_override("font_size", 16)
	for n in ASSET_KIND_NAMES:
		_asset_kind_opt.add_item(n)
	_asset_kind_opt.item_selected.connect(func(_i: int): _refresh_assets())
	_asset_box.add_child(_asset_kind_opt)
	_asset_race_opt = OptionButton.new()
	_asset_race_opt.focus_mode = Control.FOCUS_NONE
	_asset_race_opt.add_theme_font_size_override("font_size", 16)
	for rid in GameData.RACES:
		if GameData.buildings_for_race(rid).is_empty() and GameData.units_for_race(rid).is_empty():
			continue
		_race_ids.append(rid)
		_asset_race_opt.add_item(String(GameData.RACES[rid].get("name", rid)))
	_asset_race_opt.item_selected.connect(func(_i: int): _refresh_assets())
	_asset_box.add_child(_asset_race_opt)
	_asset_list = ItemList.new()
	_asset_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_asset_list.custom_minimum_size = Vector2(0, 120)
	_asset_list.add_theme_font_size_override("font_size", 16)
	_asset_box.add_child(_asset_list)
	var team_row := HBoxContainer.new()
	team_row.add_theme_constant_override("separation", 4)
	var tgroup := ButtonGroup.new()
	for i in 2:
		var tb := _button(["Your side", "Enemy side"][i], func(): _asset_team = i)
		tb.toggle_mode = true
		tb.button_group = tgroup
		tb.button_pressed = i == 0
		tb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tb.add_theme_font_size_override("font_size", 15)
		tb.custom_minimum_size = Vector2(0, 32)
		team_row.add_child(tb)
	_asset_box.add_child(team_row)
	_asset_turn_label = _label("", 15, PARCHMENT)
	_asset_box.add_child(_asset_turn_label)
	_slider(_asset_box, 0.0, 345.0, 0.0, func(v: float):
		_asset_yaw = v
		_refresh_asset_labels()).step = 15.0
	_asset_size_label = _label("", 15, PARCHMENT)
	_asset_box.add_child(_asset_size_label)
	_asset_size_slider = _slider(_asset_box, 0.25, 4.0, 1.0, func(v: float):
		_asset_scale = v
		_refresh_asset_labels())
	_asset_size_slider.step = 0.25
	_refresh_assets()
	_refresh_asset_labels()


func _refresh_asset_labels() -> void:
	_asset_turn_label.text = "Turn: %d degrees (units and models)" % int(_asset_yaw)
	_asset_size_label.text = "Size: %.2fx (models only)" % _asset_scale


func _asset_kind() -> String:
	return ASSET_KINDS[maxi(0, _asset_kind_opt.selected)]


func _refresh_assets() -> void:
	_asset_list.clear()
	var kind := _asset_kind()
	_asset_race_opt.visible = kind != "scenery"
	_asset_size_label.visible = kind == "scenery"
	_asset_size_slider.visible = kind == "scenery"
	var rows: Array = []
	if kind == "scenery":
		for path in _scenery_paths():
			rows.append([_model_name(path), path])
	else:
		var race: String = _race_ids[maxi(0, _asset_race_opt.selected)] if not _race_ids.is_empty() else "barrosan"
		var ids: Array = GameData.buildings_for_race(race) if kind == "building" else GameData.units_for_race(race)
		for id in ids:
			var d: Dictionary = GameData.get_building(id) if kind == "building" else GameData.get_unit(id)
			rows.append([String(d.get("name", id)), String(id)])
	rows.sort_custom(func(a, b): return String(a[0]) < String(b[0]))
	for r in rows:
		_asset_list.add_item(String(r[0]))
		_asset_list.set_item_metadata(_asset_list.item_count - 1, String(r[1]))
		_asset_list.set_item_tooltip(_asset_list.item_count - 1, String(r[1]))
	if _asset_list.item_count > 0:
		_asset_list.select(0)


## Every model file in the art folders (an exported game lists .import files).
func _scenery_paths() -> Array:
	if not _scenery_cache.is_empty():
		return _scenery_cache
	var found := {}
	var stack: Array = SCENERY_DIRS.duplicate()
	while not stack.is_empty():
		var d: String = stack.pop_back()
		var dir := DirAccess.open(d)
		if dir == null:
			continue
		for sub in dir.get_directories():
			stack.append(d + "/" + sub)
		for f in dir.get_files():
			var f2: String = f.trim_suffix(".import").trim_suffix(".remap")
			if f2.ends_with(".glb") or f2.ends_with(".gltf"):
				found[d + "/" + f2] = true
	_scenery_cache = found.keys()
	_scenery_cache.sort()
	return _scenery_cache


func _model_name(path: String) -> String:
	var folder := path.get_base_dir().get_file()
	return "%s  (%s)" % [path.get_file().get_basename().replace("_", " ").capitalize(), folder.replace("_", " ")]


func _option(parent: Control, caption: String, items: Array) -> OptionButton:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var l := _label(caption, 17, PARCHMENT)
	l.custom_minimum_size = Vector2(70, 0)
	row.add_child(l)
	var o := OptionButton.new()
	o.focus_mode = Control.FOCUS_NONE
	o.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	o.add_theme_font_size_override("font_size", 17)
	for it in items:
		o.add_item(String(it))
	row.add_child(o)
	parent.add_child(row)
	return o


func _slider(parent: Control, lo: float, hi: float, value: float, cb: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = 1.0
	s.value = value
	s.focus_mode = Control.FOCUS_NONE
	s.custom_minimum_size = Vector2(0, 24)
	s.value_changed.connect(cb)
	parent.add_child(s)
	return s


# ---------------------------------------------------------------------------
# Refresh
# ---------------------------------------------------------------------------
func _refresh_all() -> void:
	_name_edit.text = String(doc.get("name", ""))
	_theme_opt.select(maxi(0, CM.THEMES.find(String(doc.get("theme", "highland")))))
	_size_opt.select(maxi(0, CM.SIZES.find(float(doc.get("size", 220.0)))))
	_mood_opt.select(maxi(0, CM.MOODS.find(String(doc.get("mood", "")))))
	_refresh_board()
	_refresh_list()
	_refresh_tool()
	_refresh_sliders()


func _assembled() -> Dictionary:
	return MapDefs.assemble_spec({"id": "draft", "name": String(doc.get("name", "")), "theme": String(doc.get("theme", "highland")),
		"authored": "custom", "data": CM.to_authored(doc)})


func _refresh_board() -> void:
	var colors: Array = CAMP_COLORS.slice(1)
	_board.show_map(_assembled(), CAMP_COLORS[0], colors)
	_overlay.queue_redraw()
	_refresh_problems()


func _refresh_problems() -> void:
	var p: Array = CM.problems(doc)
	if String(doc.get("name", "")).strip_edges().is_empty():
		p.push_front("Give the battlefield a name.")
	_problems.text = "\n".join(PackedStringArray(p))


func _refresh_list() -> void:
	_list.clear()
	for d in CM.list_docs():
		_list.add_item(String(d["name"]))
		_list.set_item_metadata(_list.item_count - 1, String(d["id"]))
	_delete_armed = false
	_delete_button.text = "Delete"


func _refresh_tool() -> void:
	for t in TOOLS:
		if String(t[0]) == tool:
			_hint.text = String(t[2])
	_kind_row.visible = tool in ["vein", "deposit"]
	_asset_box.visible = tool == "asset"
	_draft.clear()
	_overlay.queue_redraw()


func _refresh_sliders() -> void:
	_brush_label.text = "Brush: %d m (woods, hills, lakes, fords)" % int(brush)
	_width_label.text = "Width: %d m (ridges, walls, rivers)" % int(line_width)


# ---------------------------------------------------------------------------
# Board geometry
# ---------------------------------------------------------------------------
func _half() -> float:
	return float(doc.get("size", 220.0))


func _side() -> float:
	return minf(_overlay.size.x, _overlay.size.y)


func _to_px(w: Vector2) -> Vector2:
	var side := _side()
	var origin := (_overlay.size - Vector2(side, side)) * 0.5
	var h := _half()
	return origin + Vector2((w.x + h) / (h * 2.0), (w.y + h) / (h * 2.0)) * side


func _to_world(px: Vector2) -> Vector2:
	var side := _side()
	var origin := (_overlay.size - Vector2(side, side)) * 0.5
	var h := _half()
	var t := (px - origin) / side
	return Vector2(t.x * h * 2.0 - h, t.y * h * 2.0 - h)


func _m_to_px(m: float) -> float:
	return m / (_half() * 2.0) * _side()


func _twin(p: Vector2) -> Vector2:
	match mirror:
		"point": return -p
		"flip_x": return Vector2(-p.x, p.y)
		"flip_z": return Vector2(p.x, -p.y)
	return p


func _has_twin(p: Vector2) -> bool:
	return mirror != "none" and _twin(p).distance_to(p) > 6.0


func _clamp_world(p: Vector2) -> Vector2:
	var h := _half() - 4.0
	return Vector2(clampf(p.x, -h, h), clampf(p.y, -h, h))


func _new_group() -> int:
	_next_group += 1
	return _next_group


# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------
func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed:
		return
	if k.keycode == KEY_Z and k.ctrl_pressed:
		_on_undo()
	elif k.keycode == KEY_ESCAPE:
		if not _draft.is_empty():
			_draft.clear()
			_overlay.queue_redraw()
	elif k.keycode == KEY_ENTER or k.keycode == KEY_KP_ENTER:
		_finish_line()


func _board_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_hover = _clamp_world(_to_world(event.position))
		if not _drag.is_empty():
			_drag_to(_hover)
		_overlay.queue_redraw()
		return
	var mb := event as InputEventMouseButton
	if mb == null:
		return
	var w := _clamp_world(_to_world(mb.position))
	if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
		if tool in LINE_TOOLS:
			_finish_line()
		return
	if mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if mb.pressed:
		if mb.double_click and tool in LINE_TOOLS:
			_finish_line()
			return
		_press(w)
	else:
		_release(w)


func _press(w: Vector2) -> void:
	match tool:
		"move":
			var hit := _pick(w)
			if not hit.is_empty():
				_push_undo()
				_drag = hit
				_drag["mode"] = "move"
				_drag["start"] = w
		"erase":
			var hit := _pick(w)
			if hit.is_empty():
				hit = _pick_line(w)
			if not hit.is_empty():
				_push_undo()
				if hit["list"] == "fords":
					_remove_ford(hit["item"])
				else:
					_remove_group(String(hit["list"]), int(hit["g"]))
				_refresh_board()
		"start":
			var n: int = (doc["starts"] as Array).size()
			var add := 2 if _has_twin(w) else 1
			if n + add > 4:
				_status.text = "A battlefield holds at most four camps."
				return
			_push_undo()
			var g := _new_group()
			doc["starts"].append({"x": w.x, "z": w.y, "g": g})
			if _has_twin(w):
				var t := _twin(w)
				doc["starts"].append({"x": t.x, "z": t.y, "g": g})
			_refresh_board()
		"lume", "ruin", "watch":
			_push_undo()
			var names := {"lume": "Lume Site", "ruin": "Healing Shrine", "watch": "Watchtower"}
			var count := 1
			for s in doc["sites"]:
				if String(s.get("type", "")) == tool:
					count += 1
			_place_points("sites", w, {"type": tool, "name": "%s %d" % [names[tool], count]})
		"vein", "deposit":
			_push_undo()
			_place_points("veins" if tool == "vein" else "deposits", w, {"kind": kind})
		"wood", "hill", "lake":
			_push_undo()
			var g := _new_group()
			var item := {"x": w.x, "z": w.y, "rx": brush, "rz": brush, "seed": snappedf(randf() * 9.0, 0.01), "g": g}
			if tool == "hill":
				item["height"] = 10.0
			var list: Array = doc[tool + "s"]
			list.append(item)
			var twin := {}
			if _has_twin(w):
				twin = item.duplicate()
				var t := _twin(w)
				twin["x"] = t.x
				twin["z"] = t.y
				twin["seed"] = float(item["seed"]) + PI
				list.append(twin)
			_drag = {"mode": "blob", "list": tool + "s", "item": item, "twin": twin, "start": w}
			_refresh_board()
		"ridge", "wall", "river", "road":
			_draft.append([snappedf(w.x, 0.1), snappedf(w.y, 0.1)])
			_overlay.queue_redraw()
		"ford":
			_add_ford(w)
		"asset":
			var sel := _asset_list.get_selected_items()
			if sel.is_empty():
				_status.text = "Pick something from the list first."
				return
			_push_undo()
			var kind := _asset_kind()
			doc["showcase"].append({"kind": kind, "id": String(_asset_list.get_item_metadata(sel[0])),
				"name": _asset_list.get_item_text(sel[0]), "x": w.x, "z": w.y, "yaw": _asset_yaw,
				"scale": _asset_scale if kind == "scenery" else 1.0, "team": _asset_team, "g": _new_group()})
			_overlay.queue_redraw()


func _release(_w: Vector2) -> void:
	if _drag.is_empty():
		return
	_drag = {}
	_refresh_board()


func _drag_to(w: Vector2) -> void:
	match String(_drag.get("mode", "")):
		"move":
			var item: Dictionary = _drag["item"]
			item["x"] = w.x
			item["z"] = w.y
			var twin = _drag.get("twin", {})
			if twin is Dictionary and not twin.is_empty():
				var t := _twin(w)
				twin["x"] = t.x
				twin["z"] = t.y
			_refresh_board()
		"blob":
			var item: Dictionary = _drag["item"]
			var d: Vector2 = (w - Vector2(float(item["x"]), float(item["z"]))).abs()
			item["rx"] = clampf(maxf(d.x, 6.0), 6.0, 80.0)
			item["rz"] = clampf(maxf(d.y, 6.0), 6.0, 80.0)
			var twin: Dictionary = _drag.get("twin", {})
			if not twin.is_empty():
				twin["rx"] = item["rx"]
				twin["rz"] = item["rz"]
			_refresh_board()


func _place_points(list_name: String, w: Vector2, fields: Dictionary) -> void:
	var g := _new_group()
	var item := fields.duplicate()
	item["x"] = w.x
	item["z"] = w.y
	item["g"] = g
	doc[list_name].append(item)
	if _has_twin(w):
		var twin := fields.duplicate()
		var t := _twin(w)
		twin["x"] = t.x
		twin["z"] = t.y
		twin["g"] = g
		if twin.has("name"):
			twin["name"] = String(twin["name"]) + " (far)"
		doc[list_name].append(twin)
	_refresh_board()


func _finish_line() -> void:
	if _draft.size() < 2:
		_draft.clear()
		_overlay.queue_redraw()
		return
	_push_undo()
	var g := _new_group()
	var line := {"points": _draft.duplicate(), "g": g}
	var list_name := "roads"
	match tool:
		"ridge":
			list_name = "ridges"
			line["thickness"] = line_width
		"wall":
			list_name = "ridges"
			line["thickness"] = line_width
			line["style"] = "masonry"
			line["height"] = 6.0
		"river":
			list_name = "rivers"
			line["width"] = maxf(line_width, 6.0)
			line["fords"] = []
	doc[list_name].append(line)
	var first := Vector2(float(_draft[0][0]), float(_draft[0][1]))
	if _has_twin(first) or (mirror != "none" and _draft.size() > 1):
		var twin := line.duplicate(true)
		var pts: Array = []
		for p in _draft:
			var t := _twin(Vector2(float(p[0]), float(p[1])))
			pts.append([snappedf(t.x, 0.1), snappedf(t.y, 0.1)])
		twin["points"] = pts
		if not _same_line(line["points"], pts):
			doc[list_name].append(twin)
	_draft.clear()
	_refresh_board()


func _same_line(a: Array, b: Array) -> bool:
	# A line drawn through the middle can be its own twin (a river across the
	# field turned half round runs the same way): keep just one.
	var total := 0.0
	for p in b:
		var best := INF
		for q in a:
			best = minf(best, Vector2(float(p[0]), float(p[1])).distance_to(Vector2(float(q[0]), float(q[1]))))
		total += best
	return total / maxf(1.0, b.size()) < 4.0


func _add_ford(w: Vector2) -> void:
	var best := -1
	var best_d := INF
	for i in (doc["rivers"] as Array).size():
		var d := _line_distance(doc["rivers"][i], w)
		if d < best_d:
			best_d = d
			best = i
	if best < 0 or best_d > float(doc["rivers"][best].get("width", 12.0)) + 10.0:
		_status.text = "Click on a river to place a ford."
		return
	_push_undo()
	doc["rivers"][best]["fords"].append({"x": w.x, "z": w.y, "half": brush})
	if _has_twin(w):
		var t := _twin(w)
		var tb := -1
		var td := INF
		for i in (doc["rivers"] as Array).size():
			var d := _line_distance(doc["rivers"][i], t)
			if d < td:
				td = d
				tb = i
		if tb >= 0 and td <= float(doc["rivers"][tb].get("width", 12.0)) + 10.0:
			doc["rivers"][tb]["fords"].append({"x": t.x, "z": t.y, "half": brush})
	_refresh_board()


func _line_distance(line: Dictionary, w: Vector2) -> float:
	var pts: Array = line.get("points", [])
	var best := INF
	for i in pts.size() - 1:
		var a := Vector2(float(pts[i][0]), float(pts[i][1]))
		var b := Vector2(float(pts[i + 1][0]), float(pts[i + 1][1]))
		best = minf(best, w.distance_to(Geometry2D.get_closest_point_to_segment(w, a, b)))
	return best


## The nearest point-like item under the cursor: {"list", "g", "item", "twin"}.
func _pick(w: Vector2) -> Dictionary:
	var reach := maxf(8.0, _half() * 0.05)
	var best := {}
	var best_d := INF
	for list_name in ["starts", "sites", "veins", "deposits", "woods", "hills", "lakes", "showcase"]:
		for item in doc[list_name]:
			var p := Vector2(float(item.get("x", 0.0)), float(item.get("z", 0.0)))
			var r := reach
			if list_name in ["woods", "hills", "lakes"]:
				r = maxf(reach, minf(float(item.get("rx", 10.0)), float(item.get("rz", 10.0))))
			var d := p.distance_to(w)
			if d < r and d < best_d:
				best_d = d
				best = {"list": list_name, "g": int(item.get("g", -1)), "item": item}
	if best.is_empty():
		return best
	for item in doc[best["list"]]:
		if item != best["item"] and int(item.get("g", -2)) == int(best["g"]):
			best["twin"] = item
	return best


func _pick_line(w: Vector2) -> Dictionary:
	var best := {}
	var best_d := maxf(6.0, _half() * 0.03)
	for list_name in ["ridges", "rivers", "roads"]:
		for line in doc[list_name]:
			var d := _line_distance(line, w) - float(line.get("thickness", line.get("width", 0.0))) * 0.5
			if d < best_d:
				best_d = d
				best = {"list": list_name, "g": int(line.get("g", -1)), "item": line}
	# A ford goes before its river.
	for river in doc["rivers"]:
		for f in river.get("fords", []):
			if Vector2(float(f["x"]), float(f["z"])).distance_to(w) < float(f.get("half", 10.0)):
				return {"list": "fords", "g": -1, "item": f, "river": river}
	return best


## Removes a ford and, when mirroring, the ford nearest its twin spot.
func _remove_ford(f: Dictionary) -> void:
	var p := Vector2(float(f["x"]), float(f["z"]))
	for river in doc["rivers"]:
		river["fords"].erase(f)
	if not _has_twin(p):
		return
	var t := _twin(p)
	for river in doc["rivers"]:
		for g in river["fords"]:
			if Vector2(float(g["x"]), float(g["z"])).distance_to(t) < 6.0:
				river["fords"].erase(g)
				return


func _remove_group(list_name: String, g: int) -> void:
	if list_name == "fords":
		return
	var keep: Array = []
	for item in doc[list_name]:
		if int(item.get("g", -1)) != g or g < 0:
			keep.append(item)
	doc[list_name] = keep


# ---------------------------------------------------------------------------
# Overlay
# ---------------------------------------------------------------------------
func _draw_overlay() -> void:
	var side := _side()
	var origin := (_overlay.size - Vector2(side, side)) * 0.5
	var font := _title_font()
	# Mirror guide.
	var mid := origin + Vector2(side, side) * 0.5
	var guide := Color(1, 1, 1, 0.10)
	match mirror:
		"point":
			_overlay.draw_circle(mid, 4.0, Color(1, 1, 1, 0.25))
		"flip_x":
			_overlay.draw_dashed_line(Vector2(mid.x, origin.y), Vector2(mid.x, origin.y + side), guide, 1.5, 8.0)
		"flip_z":
			_overlay.draw_dashed_line(Vector2(origin.x, mid.y), Vector2(origin.x + side, mid.y), guide, 1.5, 8.0)
	# Camp numbers.
	var starts: Array = doc["starts"]
	for i in starts.size():
		var p := _to_px(Vector2(float(starts[i]["x"]), float(starts[i]["z"])))
		_overlay.draw_string(font, p + Vector2(14, -10), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, CAMP_COLORS[i % 4])
	# Site rings by kind, so a shrine and a watch can be told apart.
	for s in doc["sites"]:
		var p := _to_px(Vector2(float(s["x"]), float(s["z"])))
		var col := Color(0.75, 0.6, 1.0) if s.get("type") == "lume" else (Color(0.5, 1.0, 0.6) if s.get("type") == "ruin" else Color(0.6, 0.85, 1.0))
		_overlay.draw_arc(p, 11.0, 0.0, TAU, 20, col, 2.0, true)
	# Assets placed for testing: a square for a building, a dot for a unit, a
	# diamond for a model, with a tick for the way it faces and its name.
	var labelled: Array = []
	for s in doc.get("showcase", []):
		var p := _to_px(Vector2(float(s["x"]), float(s["z"])))
		var kind := String(s.get("kind", ""))
		var col: Color = CAMP_COLORS[clampi(int(s.get("team", 0)), 0, 3)] if kind != "scenery" else Color(0.55, 0.9, 0.6)
		match kind:
			"building":
				_overlay.draw_rect(Rect2(p - Vector2(8, 8), Vector2(16, 16)), col)
				_overlay.draw_rect(Rect2(p - Vector2(8, 8), Vector2(16, 16)), Color(0, 0, 0, 0.8), false, 2.0)
			"unit":
				_overlay.draw_circle(p, 6.5, Color(0, 0, 0, 0.8))
				_overlay.draw_circle(p, 5.0, col)
			_:
				_overlay.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -8), p + Vector2(8, 0), p + Vector2(0, 8), p + Vector2(-8, 0)]), col)
		var yaw := deg_to_rad(float(s.get("yaw", 0.0)))
		_overlay.draw_line(p, p + Vector2(sin(yaw), cos(yaw)) * 14.0, Color.WHITE, 2.0, true)
		var nm := String(s.get("name", "")).get_slice("  (", 0)
		# A group of the same piece is named once.
		var crowded := false
		for q in labelled:
			if q[0] == nm and (q[1] as Vector2).distance_to(p) < 60.0:
				crowded = true
		if crowded:
			continue
		labelled.append([nm, p])
		_overlay.draw_string(get_theme_default_font(), p + Vector2(11, 5), nm, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 1, 1, 0.92))
	# Line being drawn.
	if not _draft.is_empty():
		var pts := PackedVector2Array()
		for q in _draft:
			pts.append(_to_px(Vector2(float(q[0]), float(q[1]))))
		if _hover != Vector2.INF:
			pts.append(_to_px(_hover))
		var col := Color(0.4, 0.7, 1.0, 0.9) if tool == "river" else (Color(0.85, 0.7, 0.45, 0.9) if tool == "road" else Color(0.85, 0.85, 0.85, 0.9))
		var wpx := maxf(2.0, _m_to_px(line_width if tool != "road" else 4.0))
		if pts.size() >= 2:
			_overlay.draw_polyline(pts, col, wpx, true)
			if mirror != "none":
				var tw := PackedVector2Array()
				for q in _draft:
					tw.append(_to_px(_twin(Vector2(float(q[0]), float(q[1])))))
				if _hover != Vector2.INF:
					tw.append(_to_px(_twin(_hover)))
				_overlay.draw_polyline(tw, Color(col, 0.4), wpx, true)
		for p in pts:
			_overlay.draw_circle(p, 3.5, Color.WHITE)
	# What Move or Erase would take, and its mirror twin.
	if _hover != Vector2.INF and _drag.is_empty() and tool in ["move", "erase"]:
		var hit := _pick(_hover)
		if hit.is_empty() and tool == "erase":
			hit = _pick_line(_hover)
		var mark := Color(1.0, 0.42, 0.32, 0.95) if tool == "erase" else Color(1.0, 0.86, 0.45, 0.95)
		for it in [hit.get("item"), hit.get("twin")]:
			if not (it is Dictionary):
				continue
			if it.has("points"):
				var pts := PackedVector2Array()
				for q in it["points"]:
					pts.append(_to_px(Vector2(float(q[0]), float(q[1]))))
				_overlay.draw_polyline(pts, mark, 3.0, true)
			else:
				var r := 14.0
				if it.has("rx"):
					r = _m_to_px(maxf(float(it["rx"]), float(it["rz"]))) + 4.0
				_overlay.draw_arc(_to_px(Vector2(float(it["x"]), float(it["z"]))), r, 0.0, TAU, 36, mark, 2.5, true)
		if hit.get("list") == "rivers" or hit.get("list") == "ridges" or hit.get("list") == "roads":
			# A drawn line's twin shares its group.
			for line in doc[hit["list"]]:
				if line != hit["item"] and int(line.get("g", -2)) == int(hit["g"]):
					var pts := PackedVector2Array()
					for q in line["points"]:
						pts.append(_to_px(Vector2(float(q[0]), float(q[1]))))
					_overlay.draw_polyline(pts, mark, 3.0, true)
	# Cursor ghost.
	if _hover != Vector2.INF and _drag.is_empty():
		var hp := _to_px(_hover)
		var r := 9.0
		if tool in BLOB_TOOLS or tool == "ford":
			r = _m_to_px(brush)
		elif tool in ["ridge", "wall", "river"]:
			r = maxf(3.0, _m_to_px(line_width) * 0.5)
		_overlay.draw_arc(hp, r, 0.0, TAU, 32, Color(1, 1, 1, 0.55), 1.5, true)
		if _has_twin(_hover) and tool not in ["move", "erase"]:
			_overlay.draw_arc(_to_px(_twin(_hover)), r, 0.0, TAU, 32, Color(1, 1, 1, 0.22), 1.5, true)
		var mx := _hover
		_overlay.draw_string(get_theme_default_font(), origin + Vector2(10, side - 10), "%d, %d m" % [int(mx.x), int(mx.y)], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 1, 1, 0.7))


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------
func _set_tool(t: String) -> void:
	tool = t
	_refresh_tool()


func _set_kind(k: String) -> void:
	kind = k


func _on_size(i: int) -> void:
	_push_undo()
	var old := _half()
	var new_half: float = CM.SIZES[i]
	var k := new_half / old
	# Everything keeps its place relative to the field.
	for list_name in ["starts", "sites", "veins", "deposits", "woods", "hills", "lakes", "showcase"]:
		for item in doc[list_name]:
			item["x"] = float(item["x"]) * k
			item["z"] = float(item["z"]) * k
	for list_name in ["ridges", "rivers", "roads"]:
		for line in doc[list_name]:
			for p in line["points"]:
				p[0] = float(p[0]) * k
				p[1] = float(p[1]) * k
			for f in line.get("fords", []):
				f["x"] = float(f["x"]) * k
				f["z"] = float(f["z"]) * k
	doc["size"] = new_half
	_refresh_board()


func _push_undo() -> void:
	_undo.append(JSON.stringify(doc))
	if _undo.size() > 60:
		_undo.pop_front()


func _on_undo() -> void:
	if _undo.is_empty():
		return
	var parsed = JSON.parse_string(_undo.pop_back())
	if parsed is Dictionary:
		doc = parsed
		_draft.clear()
		_refresh_all()


func _on_new() -> void:
	_push_undo()
	doc = CM.new_doc()
	_status.text = "A new battlefield."
	_refresh_all()


func _on_save() -> bool:
	var map_name := String(doc.get("name", "")).strip_edges()
	if map_name.is_empty():
		_status.text = "Give the battlefield a name first."
		return false
	doc["name"] = map_name
	doc["id"] = CM.id_for_name(map_name)
	var id := CM.save_doc(doc)
	if id.is_empty():
		_status.text = "Could not save the map."
		return false
	_status.text = "Saved \"%s\"." % map_name
	_refresh_list()
	return true


func _selected_id() -> String:
	var sel := _list.get_selected_items()
	if sel.is_empty():
		return ""
	return String(_list.get_item_metadata(sel[0]))


func _on_load() -> void:
	var id := _selected_id()
	if id.is_empty():
		_status.text = "Pick a saved map first."
		return
	var loaded := CM.load_doc(CM.path_for(id))
	if loaded.is_empty():
		_status.text = "That map could not be read."
		return
	_push_undo()
	doc = loaded
	# Groups in the file continue from the highest one used.
	for list_name in ["starts", "sites", "veins", "deposits", "woods", "hills", "lakes", "ridges", "rivers", "roads", "showcase"]:
		for item in doc[list_name]:
			_next_group = maxi(_next_group, int(item.get("g", 0)))
	_status.text = "Loaded \"%s\"." % String(doc.get("name", id))
	_refresh_all()


func _on_delete() -> void:
	var id := _selected_id()
	if id.is_empty():
		_status.text = "Pick a saved map first."
		return
	if not _delete_armed:
		_delete_armed = true
		_delete_button.text = "Really delete?"
		return
	CM.delete_doc(id)
	_status.text = "Deleted."
	_refresh_list()


func _on_play() -> void:
	var p: Array = CM.problems(doc)
	if not p.is_empty():
		_status.text = "Fix the problems above first."
		return
	if not _on_save():
		return
	var last: Dictionary = ProfileManager.settings().get("last_skirmish", {})
	last = last.duplicate()
	last["map"] = String(doc["id"])
	ProfileManager.update_setting("last_skirmish", last)
	Sfx.play("select")
	if not ProfileManager.has_hero():
		Match.set_pending_hero_origin("skirmish")
		get_tree().change_scene_to_file("res://scenes/ui/hero_creation.tscn")
		return
	get_tree().change_scene_to_file("res://scenes/ui/skirmish_setup.tscn")


## The map as a quiet test ground: no fog, the enemy idle at home, plenty of
## resources, and nothing paid or recorded. Leaving the match comes back here.
func _on_test() -> void:
	var p: Array = CM.problems(doc)
	if not p.is_empty():
		_status.text = "Fix the problems above first."
		return
	if not _on_save():
		return
	var cfg: Dictionary = Match.default_config()
	cfg["map"] = String(doc["id"])
	cfg["player_race"] = String(ProfileManager.hero().get("race", "barrosan")) if ProfileManager.has_hero() else "barrosan"
	cfg["opponents"] = [{"race": "vorthak", "difficulty": "easy"}]
	cfg["start_resources"] = "rich"
	cfg["no_fog"] = true
	cfg["sandbox"] = true
	Match.set_config(cfg)
	Sfx.play("select")
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")


func _on_back() -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
