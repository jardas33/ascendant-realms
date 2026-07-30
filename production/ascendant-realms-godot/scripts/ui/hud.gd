extends Control
## In-battle HUD for Ascendant Realms. Built entirely in code inside setup().
## Owns the resource top bar, minimap, selection panel, context command card,
## alert feed and the game-over screen. Reads from GameWorld / RTSController /
## Commander and connects to their signals; guards every handler against freed
## nodes because units and buildings free themselves on death.

signal pause_requested
signal return_to_menu
signal replay

const FONT_PATH := "res://assets/fonts/cinzel.ttf"
const THEME_PATH := "res://assets/ui/theme.tres"
const FRAME_PORTRAIT := "res://assets/ui/frame_portrait.png"
const MAP_HALF := 140.0                # MapDefs.MAP_SIZE — world spans -140..140
const MINIMAP_SIZE := 200.0
const FONT_COLOR := Color(0.95, 0.9, 0.8)
const RES_ICONS := {
	"food": "res://assets/ui/icon_food.png",
	"timber": "res://assets/ui/icon_timber.png",
	"stone": "res://assets/ui/icon_stone.png",
	"gold": "res://assets/ui/icon_gold.png",
}
const RES_ORDER := ["food", "timber", "stone", "gold"]
const TIER_NAMES := {1: "Age I", 2: "Age II", 3: "Age III"}

# --- refs ---
var world = null
var rts = null
var _commander = null                  # player_commander shortcut
var _font: FontFile = null

# --- top bar labels ---
var _res_labels := {}                  # kind -> Label
var _pop_label: Label = null
var _tier_label: Label = null

# --- minimap ---
var _minimap: Control = null

# --- selection / command panels (rebuilt on selection change) ---
var _sel_panel: PanelContainer = null
var _sel_body: Control = null
var _cmd_panel: PanelContainer = null
var _cmd_body: Control = null

# live-tracked selection widgets (refreshed in _process)
var _tracked_single = null             # currently shown single Unit/Building
var _single_hp_bar: ProgressBar = null
var _single_hp_text: Label = null
var _single_mana_bar: ProgressBar = null
var _single_stat_label: Label = null
var _single_economy_label: Label = null
var _ability_widgets := []             # [{id, button, cd_overlay}]
var _multi_bars := []                  # [{unit, bar}]
var _queue_container: HBoxContainer = null
var _watched_building = null           # building whose production we listen to

# --- alerts ---
var _alert_box: VBoxContainer = null

# --- game over ---
var _gameover_layer: Control = null

# --- refresh cadence ---
var _slow_accum := 0.0
var _map_accum := 0.0


func setup(p_world, p_rts) -> void:
	world = p_world
	rts = p_rts
	_commander = world.player_commander if world else null
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(THEME_PATH):
		theme = load(THEME_PATH)
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)

	_build_top_bar()
	_build_minimap()
	_build_selection_panel()
	_build_command_panel()
	_build_alert_feed()

	_connect_signals()
	# prime displays
	if _commander:
		_on_resources_changed(_commander.resources)
		_on_pop_changed(_commander.pop_used, _commander.pop_cap)
		_on_tier_changed(_commander.tier)
	_rebuild_selection([])


func _connect_signals() -> void:
	if _commander:
		_commander.resources_changed.connect(_on_resources_changed)
		_commander.pop_changed.connect(_on_pop_changed)
		_commander.tier_changed.connect(_on_tier_changed)
	if rts:
		rts.selection_changed.connect(_on_selection_changed)
	if world:
		world.alert.connect(_on_alert)
		world.hero_leveled.connect(_on_hero_leveled)
		world.game_over.connect(_on_game_over)


# ---------------------------------------------------------------------------
# Small builder helpers
# ---------------------------------------------------------------------------
func _mk_label(text: String, size: int = 16, col: Color = FONT_COLOR) -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _font:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 4)
	return l


func _mk_button(text: String, size: int = 15) -> Button:
	var b := Button.new()
	b.text = text
	b.clip_text = true
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	if _font:
		b.add_theme_font_override("font", _font)
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", FONT_COLOR)
	b.add_theme_color_override("font_hover_color", Color(1, 1, 0.9))
	b.add_theme_color_override("font_pressed_color", Color(1, 0.95, 0.8))
	b.add_theme_color_override("font_disabled_color", Color(0.6, 0.55, 0.5))
	b.add_theme_color_override("font_focus_color", FONT_COLOR)
	b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	b.add_theme_constant_override("outline_size", 3)
	return b


func _mk_hud_panel() -> PanelContainer:
	# Clean, predictable HUD surface. The ornate 9-slice frame reserves 30px of
	# content margin on every side, which starved these dense panels and made
	# text overflow — a flat box with a thin border gives reliable interior space.
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.add_theme_stylebox_override("panel", _hud_stylebox())
	return p


func _hud_stylebox() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.06, 0.085, 0.94)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.62, 0.5, 0.28, 0.95)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(12)
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 5
	return sb


func _mk_icon(path: String, px: float) -> TextureRect:
	var t := TextureRect.new()
	if ResourceLoader.exists(path):
		t.texture = load(path)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(px, px)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


func _cost_string(cost: Dictionary) -> String:
	var parts := []
	for k in RES_ORDER:
		if cost.has(k):
			parts.append("%d %s" % [int(cost[k]), k])
	return "  (" + ", ".join(parts) + ")" if not parts.is_empty() else ""


# ---------------------------------------------------------------------------
# 1. TOP BAR
# ---------------------------------------------------------------------------
func _build_top_bar() -> void:
	var panel := _mk_hud_panel()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_bottom = 66.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(0, 66)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 118)  # keep clear of the Menu button
	margin.add_theme_constant_override("margin_top", 0)
	margin.add_theme_constant_override("margin_bottom", 0)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 26)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(row)

	for k in RES_ORDER:
		var cell := HBoxContainer.new()
		cell.add_theme_constant_override("separation", 7)
		cell.add_child(_mk_icon(RES_ICONS[k], 30))
		var l := _mk_label("0", 22)
		l.custom_minimum_size = Vector2(58, 0)
		_res_labels[k] = l
		cell.add_child(l)
		row.add_child(cell)

	var sep := VSeparator.new()
	sep.custom_minimum_size = Vector2(2, 0)
	row.add_child(sep)

	# population
	var pop_cell := HBoxContainer.new()
	pop_cell.add_theme_constant_override("separation", 6)
	pop_cell.add_child(_mk_label("Pop", 17, Color(0.85, 0.83, 0.75)))
	_pop_label = _mk_label("0/0", 22)
	pop_cell.add_child(_pop_label)
	row.add_child(pop_cell)

	# age / tier
	_tier_label = _mk_label("Age I", 22, Color(0.98, 0.88, 0.55))
	row.add_child(_tier_label)

	# menu button (top-right corner)
	var menu_btn := _mk_button("Menu", 16)
	menu_btn.custom_minimum_size = Vector2(88, 36)
	menu_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	menu_btn.offset_left = -104.0
	menu_btn.offset_right = -14.0
	menu_btn.offset_top = 15.0
	menu_btn.offset_bottom = 51.0
	menu_btn.pressed.connect(func(): emit_signal("pause_requested"))
	add_child(menu_btn)


func _on_resources_changed(res: Dictionary) -> void:
	for k in RES_ORDER:
		if _res_labels.has(k) and is_instance_valid(_res_labels[k]):
			_res_labels[k].text = str(int(res.get(k, 0)))


func _on_pop_changed(used: int, cap: int) -> void:
	if is_instance_valid(_pop_label):
		_pop_label.text = "%d/%d" % [used, cap]
		_pop_label.add_theme_color_override("font_color",
			Color(0.95, 0.5, 0.45) if used >= cap and cap > 0 else FONT_COLOR)


func _on_tier_changed(tier: int) -> void:
	if is_instance_valid(_tier_label):
		_tier_label.text = TIER_NAMES.get(tier, "Age %d" % tier)


# ---------------------------------------------------------------------------
# 2. MINIMAP
# ---------------------------------------------------------------------------
func _build_minimap() -> void:
	var panel := _mk_hud_panel()
	# panel = minimap (200) + 12px stylebox content margin on each side = 224
	var box := MINIMAP_SIZE + 24.0
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.grow_horizontal = Control.GROW_DIRECTION_END
	panel.offset_left = 12.0
	panel.offset_right = 12.0 + box
	panel.offset_top = -12.0 - box
	panel.offset_bottom = -12.0
	panel.custom_minimum_size = Vector2(box, box)
	add_child(panel)

	_minimap = Control.new()
	_minimap.custom_minimum_size = Vector2(MINIMAP_SIZE, MINIMAP_SIZE)
	_minimap.mouse_filter = Control.MOUSE_FILTER_STOP
	_minimap.draw.connect(_draw_minimap)
	_minimap.gui_input.connect(_on_minimap_input)
	panel.add_child(_minimap)


func _on_minimap_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_focus_from_minimap(event.position)
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		_focus_from_minimap(event.position)


func _focus_from_minimap(local_pos: Vector2) -> void:
	if not is_instance_valid(rts):
		return
	var size := _minimap.size
	if size.x <= 0 or size.y <= 0:
		return
	var wx := (local_pos.x / size.x) * (MAP_HALF * 2.0) - MAP_HALF
	var wz := (local_pos.y / size.y) * (MAP_HALF * 2.0) - MAP_HALF
	if rts.has_method("focus_on"):
		rts.focus_on(Vector3(wx, 0.0, wz))


func _world_to_map(pos: Vector3) -> Vector2:
	var size := _minimap.size
	var mx := (pos.x + MAP_HALF) / (MAP_HALF * 2.0) * size.x
	var my := (pos.z + MAP_HALF) / (MAP_HALF * 2.0) * size.y
	return Vector2(mx, my)


func _draw_minimap() -> void:
	if not is_instance_valid(_minimap):
		return
	var size := _minimap.size
	# background
	_minimap.draw_rect(Rect2(Vector2.ZERO, size), Color(0.06, 0.08, 0.09, 0.95), true)
	_minimap.draw_rect(Rect2(Vector2.ZERO, size), Color(0.35, 0.32, 0.25, 0.9), false, 2.0)

	if not is_instance_valid(world):
		return

	# capture points as diamonds
	for cp in world.get_tree().get_nodes_in_group("capture_points"):
		if not is_instance_valid(cp):
			continue
		var p := _world_to_map(cp.global_position)
		var team_owner := int(cp.owner_team) if "owner_team" in cp else -1
		var col: Color = GameData.TEAM_COLORS.get(team_owner, Color(0.85, 0.85, 0.85)) if team_owner >= 0 else Color(0.85, 0.85, 0.85)
		var r := 5.0
		var diamond := PackedVector2Array([
			p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r), p + Vector2(-r, 0)])
		_minimap.draw_colored_polygon(diamond, col)
		_minimap.draw_polyline(PackedVector2Array([
			p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r),
			p + Vector2(-r, 0), p + Vector2(0, -r)]), Color(0, 0, 0, 0.8), 1.0)

	# buildings (larger squares)
	for b in world.all_buildings():
		if not is_instance_valid(b) or b.is_dead:
			continue
		var col: Color = GameData.TEAM_COLORS.get(b.team, Color.WHITE)
		var p := _world_to_map(b.global_position)
		_minimap.draw_rect(Rect2(p - Vector2(2.5, 2.5), Vector2(5, 5)), col, true)

	# units (dots)
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead:
			continue
		var col: Color = GameData.TEAM_COLORS.get(u.team, Color.WHITE)
		var p := _world_to_map(u.global_position)
		_minimap.draw_rect(Rect2(p - Vector2(1.5, 1.5), Vector2(3, 3)), col, true)

	# camera view marker
	if is_instance_valid(rts) and "cam_pivot" in rts and is_instance_valid(rts.cam_pivot):
		var cp := _world_to_map(rts.cam_pivot.global_position)
		var vr := 18.0
		_minimap.draw_rect(Rect2(cp - Vector2(vr, vr), Vector2(vr * 2, vr * 2)),
			Color(1, 1, 1, 0.9), false, 1.5)


# ---------------------------------------------------------------------------
# Process — low-rate polling + minimap redraw
# ---------------------------------------------------------------------------
func _process(delta: float) -> void:
	_map_accum += delta
	if _map_accum >= 0.15:
		_map_accum = 0.0
		if is_instance_valid(_minimap):
			_minimap.queue_redraw()

	_slow_accum += delta
	if _slow_accum >= 0.25:
		_slow_accum = 0.0
		_poll_top_bar()
		_refresh_single_live()
		_refresh_multi_live()


func _poll_top_bar() -> void:
	if not is_instance_valid(_commander):
		return
	_on_resources_changed(_commander.resources)
	_on_pop_changed(_commander.pop_used + _commander.reserved_pop, _commander.pop_cap)
	_on_tier_changed(_commander.tier)


# ---------------------------------------------------------------------------
# 3. SELECTION PANEL
# ---------------------------------------------------------------------------
func _build_selection_panel() -> void:
	_sel_panel = _mk_hud_panel()
	_sel_panel.custom_minimum_size = Vector2(480, 156)
	_sel_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_sel_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	# center it: anchor middle-bottom
	_sel_panel.anchor_left = 0.5
	_sel_panel.anchor_right = 0.5
	_sel_panel.anchor_top = 1.0
	_sel_panel.anchor_bottom = 1.0
	_sel_panel.offset_left = -240
	_sel_panel.offset_right = 240
	_sel_panel.offset_top = -168
	_sel_panel.offset_bottom = -12
	add_child(_sel_panel)

	_sel_body = Control.new()
	_sel_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sel_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sel_panel.add_child(_sel_body)
	_sel_panel.visible = false


func _clear_children(node: Node) -> void:
	if not is_instance_valid(node):
		return
	for c in node.get_children():
		c.queue_free()


func _reset_selection_widgets() -> void:
	_tracked_single = null
	_single_hp_bar = null
	_single_hp_text = null
	_single_mana_bar = null
	_single_stat_label = null
	_single_economy_label = null
	_ability_widgets.clear()
	_multi_bars.clear()
	_queue_container = null
	if is_instance_valid(_watched_building) and _watched_building.production_updated.is_connected(_on_production_updated):
		_watched_building.production_updated.disconnect(_on_production_updated)
	_watched_building = null


func _on_selection_changed(units: Array) -> void:
	_rebuild_selection(units)


func _rebuild_selection(sel: Array) -> void:
	_reset_selection_widgets()
	_clear_children(_sel_body)

	# filter to valid
	var valid := []
	for s in sel:
		if is_instance_valid(s) and not (("is_dead" in s) and s.is_dead):
			valid.append(s)

	if valid.is_empty():
		_sel_panel.visible = false
		_rebuild_command_card(null, valid)
		return

	_sel_panel.visible = true

	if valid.size() == 1:
		var one = valid[0]
		if one is Building:
			_build_single_building(one)
		else:
			_build_single_unit(one)
		_rebuild_command_card(one, valid)
	else:
		_build_multi(valid)
		_rebuild_command_card(null, valid)


func _mk_bar(col: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.custom_minimum_size = Vector2(0, 16)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.08, 0.08, 0.08, 0.9)
	bg.set_corner_radius_all(3)
	var fg := StyleBoxFlat.new()
	fg.bg_color = col
	fg.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fg)
	return bar


func _build_single_unit(u) -> void:
	_tracked_single = u
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.add_child(row)

	# portrait frame
	var portrait := _mk_icon(FRAME_PORTRAIT, 96)
	row.add_child(portrait)

	# info column
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(info)

	var uname: String = u.def.get("name", "Unit")
	info.add_child(_mk_label(uname, 18, Color(0.95, 0.85, 0.55)))

	# hp bar + text
	_single_hp_bar = _mk_bar(Color(0.35, 0.8, 0.35))
	info.add_child(_single_hp_bar)
	_single_hp_text = _mk_label("", 15)
	info.add_child(_single_hp_text)

	if u.is_hero and u.max_mana > 0.0:
		_single_mana_bar = _mk_bar(Color(0.35, 0.55, 0.95))
		info.add_child(_single_mana_bar)

	_single_stat_label = _mk_label("", 15, Color(0.88, 0.85, 0.75))
	info.add_child(_single_stat_label)
	if u.is_worker and u.has_method("get_economy_text"):
		_single_economy_label = _mk_label("", 14, Color(0.78, 0.9, 0.72))
		_single_economy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(_single_economy_label)

	# ability buttons for hero
	if u.is_hero and not u.abilities.is_empty():
		var ab_row := HBoxContainer.new()
		ab_row.add_theme_constant_override("separation", 6)
		info.add_child(ab_row)
		var abilities: Dictionary = SkillDefs.get_abilities()
		for id in u.abilities:
			var ab: Dictionary = abilities.get(id, {})
			var btn := _mk_button(str(ab.get("name", id)).left(1), 15)
			btn.custom_minimum_size = Vector2(34, 30)
			btn.tooltip_text = "%s\n%s\nMana: %d" % [ab.get("name", id), ab.get("desc", ""), int(ab.get("mana", 0))]
			var cap_id := String(id)
			var cap_u = u
			btn.pressed.connect(func():
				if is_instance_valid(cap_u) and not cap_u.is_dead and cap_u.has_method("cast_ability"):
					cap_u.cast_ability(cap_id, cap_u.global_position))
			ab_row.add_child(btn)
			# cooldown overlay label
			var cd_overlay := _mk_label("", 13, Color(1, 1, 1))
			cd_overlay.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			cd_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cd_overlay.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			btn.add_child(cd_overlay)
			_ability_widgets.append({"id": cap_id, "button": btn, "overlay": cd_overlay})

	_refresh_single_live()


func _refresh_single_live() -> void:
	var u = _tracked_single
	if not is_instance_valid(u) or (("is_dead" in u) and u.is_dead):
		return
	if is_instance_valid(_single_hp_bar):
		_single_hp_bar.value = clamp(u.get_hp_ratio(), 0.0, 1.0)
	if is_instance_valid(_single_hp_text):
		_single_hp_text.text = "HP %d / %d" % [int(max(0.0, u.hp)), int(u.max_hp)]
	if is_instance_valid(_single_mana_bar) and "max_mana" in u and u.max_mana > 0.0:
		_single_mana_bar.value = clamp(u.mana / u.max_mana, 0.0, 1.0)
	if is_instance_valid(_single_stat_label):
		if u is Building:
			pass
		elif u.has_method("cur_dmg"):
			var role: String = u.def.get("role", "")
			_single_stat_label.text = "DMG %d   ARM %d   %s" % [
				int(u.cur_dmg()), int(u.cur_armor()), role.capitalize()]
	if is_instance_valid(_single_economy_label) and u.has_method("get_economy_text"):
		_single_economy_label.text = u.get_economy_text()
	# ability cooldown / affordability visuals
	for w in _ability_widgets:
		var btn: Button = w["button"]
		if not is_instance_valid(btn):
			continue
		var id: String = w["id"]
		var cd: float = float(u.ability_cd.get(id, 0.0)) if "ability_cd" in u else 0.0
		var ab: Dictionary = SkillDefs.get_abilities().get(id, {})
		var mana_ok: bool = ("mana" in u) and u.mana >= float(ab.get("mana", 0))
		var overlay: Label = w["overlay"]
		if cd > 0.05:
			btn.disabled = true
			if is_instance_valid(overlay):
				overlay.text = str(int(ceil(cd)))
		else:
			btn.disabled = not mana_ok
			if is_instance_valid(overlay):
				overlay.text = ""


func _build_multi(units: Array) -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	_sel_body.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 8
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	var shown := 0
	for u in units:
		if shown >= 24:
			break
		if not is_instance_valid(u):
			continue
		var cell := VBoxContainer.new()
		cell.custom_minimum_size = Vector2(46, 54)
		cell.add_theme_constant_override("separation", 1)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var nm := _mk_label(str(u.def.get("name", "?")).left(6), 11)
		nm.clip_text = true
		cell.add_child(nm)
		var bar := _mk_bar(Color(0.35, 0.8, 0.35))
		bar.custom_minimum_size = Vector2(44, 10)
		cell.add_child(bar)
		grid.add_child(cell)
		_multi_bars.append({"unit": u, "bar": bar})
		shown += 1

	if units.size() > 24:
		_sel_body.add_child(_mk_label("+%d more" % (units.size() - 24), 12))


func _refresh_multi_live() -> void:
	for entry in _multi_bars:
		var u = entry["unit"]
		var bar: ProgressBar = entry["bar"]
		if not is_instance_valid(bar):
			continue
		if is_instance_valid(u) and not (("is_dead" in u) and u.is_dead) and u.has_method("get_hp_ratio"):
			bar.value = clamp(u.get_hp_ratio(), 0.0, 1.0)
		else:
			bar.value = 0.0


func _build_single_building(b) -> void:
	_tracked_single = b
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 3)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.add_child(col)

	col.add_child(_mk_label(b.def.get("name", "Building"), 18, Color(0.95, 0.85, 0.55)))

	_single_hp_bar = _mk_bar(Color(0.35, 0.8, 0.35))
	col.add_child(_single_hp_bar)
	_single_hp_text = _mk_label("", 15)
	col.add_child(_single_hp_text)

	if not b.is_built:
		var pb := _mk_bar(Color(0.85, 0.7, 0.3))
		pb.value = clamp(b.build_progress, 0.0, 1.0)
		col.add_child(_mk_label("Under construction", 12, Color(0.85, 0.8, 0.6)))
		col.add_child(pb)
		var cap_b = b
		var cap_pb = pb
		# tick construction bar off the slow poll via a lambda-friendly approach:
		# store it on the building bar reference reused each poll is overkill; use a timer.
		var t := Timer.new()
		t.wait_time = 0.2
		t.autostart = true
		cap_pb.add_child(t)
		t.timeout.connect(func():
			if is_instance_valid(cap_b) and is_instance_valid(cap_pb):
				cap_pb.value = clamp(cap_b.build_progress, 0.0, 1.0))

	# production queue row (only meaningful when it produces)
	if not b.def.get("produces", []).is_empty() or not b.def.get("research", []).is_empty() \
			or b.def.get("is_hq", false) or b.def.get("kind", "") == "main":
		_queue_container = HBoxContainer.new()
		_queue_container.add_theme_constant_override("separation", 4)
		_queue_container.mouse_filter = Control.MOUSE_FILTER_STOP
		col.add_child(_mk_label("Queue", 12, Color(0.8, 0.78, 0.7)))
		col.add_child(_queue_container)
		# watch production updates
		if b.production_updated.is_connected(_on_production_updated):
			b.production_updated.disconnect(_on_production_updated)
		b.production_updated.connect(_on_production_updated)
		_watched_building = b
		_refresh_queue()

	_refresh_single_live()


func _on_production_updated() -> void:
	_refresh_queue()


func _refresh_queue() -> void:
	if not is_instance_valid(_queue_container):
		return
	_clear_children(_queue_container)
	var b = _watched_building
	if not is_instance_valid(b):
		return
	var idx := 0
	for item in b.queue:
		var slot := _mk_button("", 12)
		slot.custom_minimum_size = Vector2(38, 38)
		var kind: String = item.get("kind", "unit")
		var iid: String = item.get("id", "")
		var disp_name := ""
		if kind == "unit":
			disp_name = GameData.get_unit(iid).get("name", iid)
		else:
			disp_name = GameData.get_tech(iid).get("name", iid)
		slot.text = disp_name.left(2)
		var total: float = float(item.get("total", 1.0))
		var left: float = float(item.get("time_left", 0.0))
		var prog: float = 1.0 - clampf(left / maxf(0.01, total), 0.0, 1.0)
		slot.tooltip_text = "%s\nClick to cancel (%d%%)" % [disp_name, int(prog * 100.0)]
		var cap_b = b
		var cap_idx := idx
		slot.pressed.connect(func():
			if is_instance_valid(cap_b) and cap_b.has_method("cancel_queue_item"):
				cap_b.cancel_queue_item(cap_idx))
		# progress mini-bar under text
		var pbar := _mk_bar(Color(0.85, 0.7, 0.3))
		pbar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		pbar.custom_minimum_size = Vector2(34, 6)
		pbar.value = prog
		pbar.position = Vector2(2, 30)
		pbar.size = Vector2(34, 6)
		slot.add_child(pbar)
		_queue_container.add_child(slot)
		idx += 1


# ---------------------------------------------------------------------------
# 4. COMMAND CARD (bottom-right)
# ---------------------------------------------------------------------------
func _build_command_panel() -> void:
	_cmd_panel = _mk_hud_panel()
	_cmd_panel.anchor_left = 1.0
	_cmd_panel.anchor_right = 1.0
	_cmd_panel.anchor_top = 1.0
	_cmd_panel.anchor_bottom = 1.0
	_cmd_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_cmd_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_cmd_panel.offset_left = -334
	_cmd_panel.offset_right = -12
	_cmd_panel.offset_top = -372
	_cmd_panel.offset_bottom = -12
	add_child(_cmd_panel)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cmd_panel.add_child(scroll)

	_cmd_body = VBoxContainer.new()
	_cmd_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cmd_body.add_theme_constant_override("separation", 5)
	scroll.add_child(_cmd_body)
	_cmd_panel.visible = false


func _rebuild_command_card(single, selection: Array) -> void:
	_clear_children(_cmd_body)
	if not is_instance_valid(_commander):
		_cmd_panel.visible = false
		return

	# WORKER -> build menu
	if single != null and single is Unit and single.is_worker:
		_build_worker_card()
		_cmd_panel.visible = _cmd_body.get_child_count() > 0
		return

	# BUILDING -> production / research
	if single != null and single is Building:
		_build_building_card(single)
		_cmd_panel.visible = _cmd_body.get_child_count() > 0
		return

	_cmd_panel.visible = false


func _build_worker_card() -> void:
	_cmd_body.add_child(_mk_label("Build", 15, Color(0.95, 0.85, 0.55)))
	for bid in GameData.buildings_for_race(_commander.race):
		var bdef := GameData.get_building(bid)
		if bdef.is_empty():
			continue
		var cost: Dictionary = bdef.get("cost", {})
		var btn := _mk_button(bdef.get("name", bid) + _cost_string(cost), 16)
		btn.custom_minimum_size = Vector2(0, 38)
		btn.tooltip_text = bdef.get("desc", "")
		var affordable: bool = _commander.can_afford(cost)
		btn.disabled = not affordable
		var cap_id := String(bid)
		btn.pressed.connect(func():
			if is_instance_valid(rts) and rts.has_method("enter_build_mode"):
				rts.enter_build_mode(cap_id))
		_cmd_body.add_child(btn)


func _build_building_card(b) -> void:
	if not b.is_built:
		_cmd_body.add_child(_mk_label("Constructing...", 14, Color(0.85, 0.8, 0.6)))
		return
	var def: Dictionary = b.def
	var produces: Array = def.get("produces", [])
	var research: Array = def.get("research", [])
	var is_hq: bool = def.get("is_hq", false) or def.get("kind", "") == "main"

	# production units
	if not produces.is_empty():
		_cmd_body.add_child(_mk_label("Train", 15, Color(0.95, 0.85, 0.55)))
		for uid in produces:
			var udef := GameData.get_unit(uid)
			if udef.is_empty():
				continue
			var cost: Dictionary = udef.get("cost", {})
			var label := "%s  (T%d)%s" % [udef.get("name", uid), int(udef.get("tier", 1)), _cost_string(cost)]
			var btn := _mk_button(label, 16)
			btn.custom_minimum_size = Vector2(0, 38)
			var tier := int(udef.get("tier", 1))
			var affordable: bool = _commander.can_afford(cost)
			var housed: bool = _commander.has_pop_for(udef)
			btn.disabled = tier > _commander.tier or not affordable or not housed
			btn.tooltip_text = "Requires Age %d" % tier if tier > _commander.tier else ("Need more housing" if not housed else ("Need " + _commander.missing_resource(cost) if not affordable else udef.get("desc", "")))
			var cap_b = b
			var cap_uid := String(uid)
			btn.pressed.connect(func(): _try_queue_unit(cap_b, cap_uid))
			_cmd_body.add_child(btn)

	# research + tier advance
	var tech_ids := []
	if is_hq:
		tech_ids.append("advance_tier_2")
		tech_ids.append("advance_tier_3")
	if not research.is_empty() or def.get("is_research", false):
		for tid in research:
			tech_ids.append(tid)

	if not tech_ids.is_empty():
		_cmd_body.add_child(_mk_label("Research", 15, Color(0.95, 0.85, 0.55)))
		for tid in tech_ids:
			var tdef := GameData.get_tech(tid)
			if tdef.is_empty():
				continue
			var cost: Dictionary = tdef.get("cost", {})
			var btn := _mk_button(tdef.get("name", tid) + _cost_string(cost), 16)
			btn.custom_minimum_size = Vector2(0, 38)
			btn.tooltip_text = tdef.get("desc", "")
			# grey when unavailable (already done / wrong tier / researching)
			if _commander.has_method("can_research"):
				btn.disabled = not _commander.can_research(tid)
			var cap_b = b
			var cap_tid := String(tid)
			btn.pressed.connect(func(): _try_queue_tech(cap_b, cap_tid))
			_cmd_body.add_child(btn)


func _try_queue_unit(b, uid: String) -> void:
	if not is_instance_valid(b) or not b.has_method("queue_unit"):
		return
	var res: Dictionary = b.queue_unit(uid)
	if res.get("ok", false):
		var nm: String = GameData.get_unit(uid).get("name", "Unit")
		_flash_notice("Training %s..." % nm, Color(0.6, 0.95, 0.6))
		Sfx.play("select", -8.0)
	else:
		_flash_notice(str(res.get("reason", "Cannot train")), Color(1, 0.55, 0.45))


func _try_queue_tech(b, tid: String) -> void:
	if not is_instance_valid(b) or not b.has_method("queue_tech"):
		return
	var res: Dictionary = b.queue_tech(tid)
	if res.get("ok", false):
		# tier advance / research done — refresh card so buttons grey out
		_rebuild_command_card(b, [b])
	else:
		_flash_notice(str(res.get("reason", "Cannot research")))


func _flash_notice(msg: String, col: Color = Color(1, 0.6, 0.5)) -> void:
	# Toast anchored just above the command card so the player always sees the
	# result of a train/build/research click.
	var box := PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.z_index = 60
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.04, 0.05, 0.92)
	sb.set_border_width_all(2)
	sb.border_color = col
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(12)
	box.add_theme_stylebox_override("panel", sb)
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 1.0
	box.anchor_bottom = 1.0
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.offset_top = -232
	box.offset_bottom = -190
	add_child(box)
	var l := _mk_label(msg, 20, col)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l)
	var tw := box.create_tween()
	tw.tween_interval(1.4)
	tw.tween_property(box, "modulate:a", 0.0, 0.6)
	tw.tween_callback(box.queue_free)


# ---------------------------------------------------------------------------
# 5. ALERT / OBJECTIVE FEED (top-right)
# ---------------------------------------------------------------------------
func _build_alert_feed() -> void:
	_alert_box = VBoxContainer.new()
	_alert_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_alert_box.offset_left = -360
	_alert_box.offset_right = -14
	_alert_box.offset_top = 74
	_alert_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_alert_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	_alert_box.add_theme_constant_override("separation", 4)
	_alert_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_alert_box)


func _on_alert(message: String, _pos: Vector3) -> void:
	_push_alert(message, Color(0.95, 0.9, 0.75))


func _on_hero_leveled(level: int) -> void:
	_push_alert("Hero reached level %d!" % level, Color(0.95, 0.85, 0.4))
	Sfx.play("levelup", -4.0)


func _push_alert(message: String, col: Color) -> void:
	if not is_instance_valid(_alert_box):
		return
	# cap the feed
	while _alert_box.get_child_count() >= 4:
		var oldest := _alert_box.get_child(0)
		_alert_box.remove_child(oldest)
		oldest.queue_free()
	var l := _mk_label(message, 15, col)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(340, 0)
	_alert_box.add_child(l)
	var tw := l.create_tween()
	tw.tween_interval(3.2)
	tw.tween_property(l, "modulate:a", 0.0, 0.8)
	tw.tween_callback(func():
		if is_instance_valid(l):
			l.queue_free())


# ---------------------------------------------------------------------------
# 7. GAME OVER
# ---------------------------------------------------------------------------
func _on_game_over(victory: bool) -> void:
	if is_instance_valid(_gameover_layer):
		return
	_gameover_layer = Control.new()
	_gameover_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gameover_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_gameover_layer)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.0)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_gameover_layer.add_child(dim)
	var dim_tw := dim.create_tween()
	dim_tw.tween_property(dim, "color:a", 0.78, 0.6)

	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	_gameover_layer.add_child(box)

	var heading := _mk_label("VICTORY" if victory else "DEFEAT", 64,
		Color(0.98, 0.85, 0.4) if victory else Color(0.9, 0.35, 0.3))
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(heading)

	var result: Dictionary = Match.last_result if Match else {}
	var kills := int(result.get("kills", 0))
	var xp := int(result.get("xp", 0))
	var t := int(result.get("time", 0))
	var mins := int(t) / 60
	var secs := int(t) % 60
	var summary := "Enemies defeated: %d     Experience gained: %d     Time: %d:%02d" % [kills, xp, mins, secs]
	var sum_label := _mk_label(summary, 20, Color(0.9, 0.87, 0.78))
	sum_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sum_label)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 24)
	box.add_child(btn_row)

	var continue_btn := _mk_button("Continue", 22)
	continue_btn.custom_minimum_size = Vector2(180, 56)
	continue_btn.pressed.connect(func(): emit_signal("return_to_menu"))
	btn_row.add_child(continue_btn)

	var replay_btn := _mk_button("Play Again", 22)
	replay_btn.custom_minimum_size = Vector2(180, 56)
	replay_btn.pressed.connect(func(): emit_signal("replay"))
	btn_row.add_child(replay_btn)
