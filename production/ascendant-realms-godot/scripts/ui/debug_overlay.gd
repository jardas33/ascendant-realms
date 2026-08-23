extends Control
## Debug overlay — hidden by default, toggled with F3. Shows dev diagnostics
## WITHOUT contaminating the clean Player Mode presentation.

var world = null
var rts = null
var _active := false
var _label: Label
var _accum := 0.0
var _draw_layer: Control

func setup(p_world, p_rts) -> void:
	world = p_world
	rts = p_rts
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	var panel := PanelContainer.new()
	panel.position = Vector2(20, 120)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.7)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.2, 1.0, 0.4, 0.8)
	panel.add_theme_stylebox_override("panel", sb)

	_label = Label.new()
	_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	_label.add_theme_font_size_override("font_size", 14)
	_label.custom_minimum_size = Vector2(360, 0)
	panel.add_child(_label)

	# world-space diagnostic drawing (unit states/paths)
	_draw_layer = Control.new()
	_draw_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_draw_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_draw_layer.draw.connect(_draw_world_diag)
	add_child(_draw_layer)

func toggle() -> void:
	_active = not _active
	visible = _active

func _process(delta: float) -> void:
	if not _active:
		return
	_accum += delta
	if _accum >= 0.25:
		_accum = 0.0
		_update_text()
		_draw_layer.queue_redraw()

func _update_text() -> void:
	if not is_instance_valid(world):
		return
	var lines := []
	lines.append("=== DEBUG (F3) ===")
	lines.append("FPS: %d" % Engine.get_frames_per_second())
	lines.append("Match time: %.1fs" % world.match_time)
	lines.append("Units: %d  Buildings: %d" % [world.all_units().size(), world.all_buildings().size()])
	lines.append("Player kills: %d" % world.kills_by_player)
	for cmd in world.commanders:
		var r = cmd.resources
		lines.append("T%d %s | tier %d | pop %d/%d | F%d W%d S%d G%d | U:%d B:%d %s" % [
			cmd.team, cmd.race.substr(0, 3), cmd.tier, cmd.pop_used, cmd.pop_cap,
			int(r.get("food",0)), int(r.get("timber",0)), int(r.get("stone",0)), int(r.get("gold",0)),
			cmd.units.size(), cmd.buildings.size(), "(DEFEATED)" if cmd.defeated else ""])
	# hero mana
	var hero = world.player_commander.hero_ref if world.player_commander else null
	if is_instance_valid(hero):
		lines.append("Hero: hp %.0f/%.0f mana %.0f/%.0f dmg %.0f arm %.0f" % [
			hero.hp, hero.max_hp, hero.mana, hero.max_mana, hero.cur_dmg(), hero.cur_armor()])
	_label.text = "\n".join(lines)

func _draw_world_diag() -> void:
	if not _active or not is_instance_valid(world) or not is_instance_valid(rts):
		return
	var cam = rts.camera
	if not is_instance_valid(cam):
		return
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead:
			continue
		if cam.is_position_behind(u.global_position):
			continue
		var sp: Vector2 = cam.unproject_position(u.global_position + Vector3.UP * 2.2)
		var col: Color = GameData.TEAM_COLORS.get(u.team, Color.WHITE)
		var state_name := _state_name(u.state)
		_draw_layer.draw_string(ThemeDB.fallback_font, sp, "%s#%d %s" % [u.unit_id.substr(0,4), u.get_instance_id() % 1000, state_name],
			HORIZONTAL_ALIGNMENT_CENTER, -1, 11, col)

func _state_name(s: int) -> String:
	var names := ["IDLE","MOVE","AMOVE","ATK","GATH","RET","BUILD","HOLD","PATROL","FOLLOW","DEAD"]
	if s >= 0 and s < names.size():
		return names[s]
	return "?"
