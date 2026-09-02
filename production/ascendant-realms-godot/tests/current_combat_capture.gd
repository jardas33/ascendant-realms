extends Node
## Task761: bounded public combat proof through genuine enemy HP loss.

const OUT := "res://../../artifacts/current-combat-capture/"
var phase_file: FileAccess
var player_unit: Node
var enemy_unit: Node
var hp_before := 0.0
var started_at := 0.0

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	phase_file = FileAccess.open(ProjectSettings.globalize_path(OUT + "phases.jsonl"), FileAccess.WRITE)
	_phase("DRIVER_ENTRY", {"task":"761", "scope":"bounded_public_combat_hp_loss"})
	if OS.get_environment("ASCENDANT_CURRENT_COMBAT_CAPTURE") != "1":
		_finish("capture_flag_not_enabled", 0)
		return
	_phase("ARTIFACT_ROOT_READY", {"artifact_root":ProjectSettings.globalize_path(OUT)})

func _phase(name: String, fields: Dictionary = {}) -> void:
	if phase_file == null: return
	var row := {"phase":name, "timestamp":Time.get_datetime_string_from_system(true)}
	row.merge(fields); phase_file.store_line(JSON.stringify(row)); phase_file.flush()

func _capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	_phase(name, {"frame_path":ProjectSettings.globalize_path(OUT + name + ".png")})

func _finish(reason: String, code: int) -> void:
	_phase("TERMINAL", {"terminal_reason":reason, "intended_exit_code":code})
	if phase_file: phase_file.close()
	get_tree().quit(code)

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _unit_payload(u: Node) -> Dictionary:
	return {"unit_id":String(u.unit_id), "team":int(u.team), "hp":float(u.hp), "max_hp":float(u.max_hp), "is_dead":bool(u.is_dead), "state":int(u.state), "position":{"x":u.global_position.x,"y":u.global_position.y,"z":u.global_position.z}}

func capture_gameplay(root: Node) -> void:
	var world := root.get_node_or_null("GameWorld")
	var rts := root.get_node_or_null("RTS")
	_phase("PUBLIC_BOOTSTRAP", {"root":"/root/GameRoot"})
	if world == null or world.commanders.size() < 2:
		await _finish("gameworld_or_opponent_missing", 10); return
	_phase("GAMEWORLD", {"commanders":world.commanders.size()})
	var player_candidates: Array = []
	for u in world.all_units():
		if is_instance_valid(u) and not u.is_dead and int(u.team) == int(world.player_team) and not bool(u.is_worker): player_candidates.append(u)
	var enemy_candidates: Array = []
	for u in world.all_units():
		if is_instance_valid(u) and not u.is_dead and int(u.team) != int(world.player_team) and not bool(u.is_worker): enemy_candidates.append(u)
	if player_candidates.is_empty() or enemy_candidates.is_empty():
		await _finish("live_military_units_missing", 11); return
	player_unit = player_candidates[0]
	enemy_unit = enemy_candidates[0]
	_phase("PLAYER_COMBATANT_DISCOVERED", {"unit":_unit_payload(player_unit), "present_at_start":true, "acquisition_route":"normal_gameworld_start_units"})
	_phase("ENEMY_TARGET_DISCOVERED", {"unit":_unit_payload(enemy_unit), "selection":"first live opposing military unit from world.all_units"})
	_phase("COMBATANT_STATS", {"attacker_reach":float(player_unit.get("atk_range")) if float(player_unit.get("atk_range")) > 0.0 else 1.6, "attacker_move_speed":float(player_unit.get("move_speed")), "attacker_attack_interval":float(player_unit.get("attack_cd")), "attacker_damage":float(player_unit.cur_dmg()), "attacker_type":String(player_unit.get("dmg_type")), "target_move_speed":float(enemy_unit.get("move_speed")), "target_state":int(enemy_unit.state)})
	var target_audit: Array = []
	for candidate in enemy_candidates:
		target_audit.append({"enemy_id":String(candidate.unit_id), "type":String(candidate.get("dmg_type")), "straight_line_distance":player_unit.global_position.distance_to(candidate.global_position), "alive":not candidate.is_dead, "valid_attack_target":player_unit._can_attack_target(candidate)})
	target_audit.sort_custom(func(a: Dictionary, b: Dictionary): return float(a["straight_line_distance"]) < float(b["straight_line_distance"]))
	_phase("TARGET_SELECTION_AUDIT", {"targets":target_audit.slice(0, 5), "selected_rank_by_distance":target_audit.find_custom(func(a: Dictionary): return a["enemy_id"] == String(enemy_unit.unit_id)) + 1})
	if rts:
		rts._clear_selection(); rts._add_to_selection(player_unit); rts.emit_signal("selection_changed", rts.selected)
	_phase("PLAYER_UNIT_SELECTED", {"selected_unit":_unit_payload(player_unit)})
	hp_before = float(enemy_unit.hp)
	await _capture("01_ATTACKER_SELECTED_BEFORE_ATTACK")
	player_unit.command_attack(enemy_unit)
	_phase("PUBLIC_ATTACK_COMMAND_ISSUED", {"attacker":String(player_unit.unit_id), "target":String(enemy_unit.unit_id), "target_hp_before":hp_before})
	started_at = Time.get_ticks_msec() / 1000.0
	var previous_position: Vector3 = player_unit.global_position
	var previous_target_position: Vector3 = enemy_unit.global_position
	var last_sample_at := -5.0
	var range_reached := false
	while is_instance_valid(enemy_unit) and not enemy_unit.is_dead and float(enemy_unit.hp) >= hp_before and Time.get_ticks_msec() / 1000.0 - started_at < 90.0:
		await _wait(0.5)
		var elapsed: float = Time.get_ticks_msec() / 1000.0 - started_at
		var distance: float = player_unit.global_position.distance_to(enemy_unit.global_position)
		var engage_range := float(player_unit.get("atk_range")) if float(player_unit.get("atk_range")) > 0.0 else 1.6
		if distance <= engage_range + 0.15 and not range_reached:
			range_reached = true
			_phase("IN_ATTACK_RANGE", {"elapsed_seconds":elapsed, "distance":distance, "engage_range":engage_range})
		if elapsed - last_sample_at >= 5.0:
			last_sample_at = elapsed
			var nav_target: Vector3 = player_unit.get("_requested_move_target")
			var next_path: Vector3 = player_unit.agent.get_next_path_position() if is_instance_valid(player_unit.agent) else Vector3.ZERO
			_phase("APPROACH_DISTANCE_SAMPLE", {"elapsed_seconds":elapsed, "distance":distance, "attacker_position":_unit_payload(player_unit).get("position"), "target_position":_unit_payload(enemy_unit).get("position"), "attacker_displacement_since_prior":player_unit.global_position.distance_to(previous_position), "target_displacement_since_prior":enemy_unit.global_position.distance_to(previous_target_position), "distance_delta":distance - previous_position.distance_to(previous_target_position), "attacker_state":int(player_unit.state), "target_state":int(enemy_unit.state), "nav_target_position":{"x":nav_target.x,"y":nav_target.y,"z":nav_target.z}, "next_path_position":{"x":next_path.x,"y":next_path.y,"z":next_path.z}, "navigation_finished":player_unit.agent.is_navigation_finished() if is_instance_valid(player_unit.agent) else false, "attack_settled":bool(player_unit.get("_attack_settled")), "attack_timer":float(player_unit.get("_attack_timer")), "attack_command":String(player_unit.get("_navigation_command_type"))})
			previous_position = player_unit.global_position
			previous_target_position = enemy_unit.global_position
	if not is_instance_valid(enemy_unit) or enemy_unit.is_dead:
		await _finish("target_died_before_bounded_observation", 12); return
	var hp_after := float(enemy_unit.hp)
	_phase("COMBAT_ENGAGED", {"attacker_state":int(player_unit.state), "attacker_command":String(player_unit.get("_navigation_command_type")), "target":_unit_payload(enemy_unit)})
	_phase("TARGET_HP_LOSS_PROVEN", {"target_hp_before":hp_before, "target_hp_after":hp_after, "damage_delta":hp_after-hp_before, "attacker_controllable":not player_unit.is_dead})
	await _capture("02_COMBAT_ENGAGED_HP_LOSS")
	if hp_after >= hp_before:
		await _finish("target_hp_did_not_decrease", 13); return
	await _finish("qualified_bounded_combat_hp_loss", 0)
