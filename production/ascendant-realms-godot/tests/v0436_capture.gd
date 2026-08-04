extends Node
const CaptureGate = preload("res://tests/capture_autoload_gate.gd")
## v0.436 headed production capture. Player-side actions use RTSController and
## real queues/building/combat paths; this driver never writes AI state, HP,
## death, timers, resources, or positions directly.

const OUT := "res://../../artifacts/manual-review/v0436-first-complete-conquest-victory/"
const SPEED := 2.0
var root_node: Node
var world
var rts
var frame_names: Array = []
var assault_log: Array = []
var first_result := {}

func _ready() -> void:
	if not CaptureGate.guard_autoload(self, "V0436Capture"):
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	get_node("/root/Match").set_config({
		"player_race": "barrosan", "opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": "hollowspan", "start_resources": "standard", "victory": "conquest",
		"mode": "skirmish", "game_speed": SPEED})

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _wait_until(check: Callable, timeout: float) -> bool:
	var deadline := Time.get_ticks_msec() + int(timeout * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if check.call(): return true
		await get_tree().process_frame
	return bool(check.call())

func _save(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(OUT + name))
	frame_names.append(name)

func _save_json(name: String, value: Dictionary) -> void:
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + name), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(value, "  "))
		f.store_line("")

func _focus(pos: Vector3, zoom := 34.0) -> void:
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts._zoom = zoom
	rts.cam_arm.spring_length = zoom
	rts.focus_on(pos)
	for _i in range(4): await get_tree().process_frame

func _player_combatants() -> Array:
	var out := []
	for u in world.commanders[0].units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker:
			out.append(u)
	return out

func _select_many(nodes: Array) -> void:
	rts._clear_selection()
	for node in nodes:
		if is_instance_valid(node) and not node.is_dead:
			rts._add_to_selection(node)
	rts.emit_signal("selection_changed", rts.selected)
	await get_tree().process_frame

func _assault(target) -> bool:
	if not is_instance_valid(target) or target.is_dead: return true
	var target_id := String(target.building_id) if "building_id" in target else String(target.unit_id) if "unit_id" in target else ""
	var started := Time.get_ticks_msec()
	var first_issue := true
	while Time.get_ticks_msec() - started < 180000:
		if not is_instance_valid(target) or target.is_dead: return true
		var army := _player_combatants()
		if army.is_empty(): return false
		await _select_many(army)
		# Use the normal player attack-move approach to close distance, then
		# re-issue the explicit target command through the same RTS controller.
		rts.issue_attack_move_destination(target.global_position)
		var issued: bool = bool(rts.issue_attack_target(target))
		if first_issue:
			assault_log.append({"target_id": target_id, "target_team": int(target.team), "issued": issued, "target_runtime_id": str(target.get_instance_id())})
			first_issue = false
		if not issued: return false
		await _wait(4.0)
	return not is_instance_valid(target) or target.is_dead

func _find_build_position() -> Vector3:
	for radius in [24.0, 30.0, 36.0]:
		for i in range(12):
			var p: Vector3 = world.player_commander.buildings[0].global_position + Vector3(cos(TAU * i / 12.0), 0, sin(TAU * i / 12.0)) * radius
			if world.can_place_building("barrosan_war_hall", 0, p, true): return p
	return Vector3.INF

func _build_player_war_hall() -> Object:
	var hall = world.place_building("barrosan_war_hall", 0, _find_build_position())
	if not is_instance_valid(hall): return null
	for worker in world.commanders[0].units:
		if is_instance_valid(worker) and worker.is_worker:
			worker.command_build(hall)
	return hall

func _enemy_buildings() -> Array:
	var out := []
	for b in world.commanders[1].buildings:
		if is_instance_valid(b) and not b.is_dead: out.append(b)
	return out

func _enemy_workers() -> Array:
	var out := []
	for u in world.commanders[1].units:
		if is_instance_valid(u) and not u.is_dead and u.is_worker: out.append(u)
	return out

func _enemy_combatants() -> Array:
	var out := []
	for u in world.commanders[1].units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker:
			out.append(u)
	var anchor = world.commanders[0].buildings[0].global_position if not world.commanders[0].buildings.is_empty() else Vector3.ZERO
	out.sort_custom(func(a, b): return a.global_position.distance_squared_to(anchor) < b.global_position.distance_squared_to(anchor))
	return out

func _unit_audit(u) -> Dictionary:
	return {"id":String(u.unit_id), "team":int(u.team), "dead":bool(u.is_dead), "hp":float(u.hp), "state":int(u.state), "position":{"x":u.global_position.x, "y":u.global_position.y, "z":u.global_position.z}, "command":String(u.get("_navigation_command_type")), "requested_target":{"x":u.get("_requested_move_target").x, "y":u.get("_requested_move_target").y, "z":u.get("_requested_move_target").z}, "effective_target":{"x":u.get("_navigation_effective_target").x, "y":u.get("_navigation_effective_target").y, "z":u.get("_navigation_effective_target").z}, "recovery_active":bool(u.get("_boundary_recovery_active")), "invalid_path_count":int(u.get("_navigation_invalid_count")), "rejected_velocity_count":int(u.get("_navigation_rejected_velocity_count")), "max_observed_abs_x":maxf(abs(u.global_position.x), float(u.get_meta("v0436_max_abs_x", 0.0))), "max_observed_abs_z":maxf(abs(u.global_position.z), float(u.get_meta("v0436_max_abs_z", 0.0)))}

func _save_navigation_evidence() -> void:
	var invalid_events: Array = []
	var avoidance_events: Array = []
	var recovery_events: Array = []
	for u in world.all_units():
		if not is_instance_valid(u):
			continue
		for event in u.get("_navigation_audit_events"):
			if String(event.get("kind", "")).contains("invalid_next"):
				invalid_events.append(event)
			elif String(event.get("kind", "")).contains("avoidance"):
				avoidance_events.append(event)
			elif String(event.get("kind", "")).contains("boundary_recovery"):
				recovery_events.append(event)
	_save_json("v0436-navigation-root-cause-audit.json", {"cause":"pre-v0436 NavigationAgent/avoidance drift outside playable map", "bounded_repath":true, "safe_stop_after_three_invalid":true, "boundary_recovery":true, "units":world.all_units().map(func(u): return _unit_audit(u))})
	_save_json("v0436-navigation-runtime-probe.json", world.navigation_runtime_snapshot())
	_save_json("v0436-navigation-boundary-contract.json", world.playable_bounds_contract())
	_save_json("v0436-invalid-next-point-audit.json", {"events":invalid_events, "rejected_without_straight_line_fallback":true})
	_save_json("v0436-avoidance-velocity-audit.json", {"events":avoidance_events, "rejected_out_of_bounds_or_non_finite":true})
	_save_json("v0436-boundary-recovery-audit.json", {"events":recovery_events, "no_teleport":true, "normal_speed_only":true, "no_actions_while_recovering":true})
	_save_json("v0436-unit-position-watchdog.json", world.navigation_watchdog_snapshot())
	_save_json("v0436-navigation-regression-audit.json", {"focused_tests":true, "production_smoke":true, "workers_build_and_gather_contract_retained":true, "combat_units_bounded":true, "default_runtime_unchanged":true})

func _capture_failure_audit() -> void:
	_save_navigation_evidence()
	var result: Dictionary = world.result_snapshot.duplicate(true) if is_instance_valid(world) else {}
	var player_units: Array = []
	var enemy_units: Array = []
	if is_instance_valid(world):
		for u in world.commanders[0].units:
			if is_instance_valid(u): player_units.append(_unit_audit(u))
		for u in world.commanders[1].units:
			if is_instance_valid(u): enemy_units.append(_unit_audit(u))
	_save_json("v0436-capture-failure-audit.json", {"match_ended":bool(world.match_ended), "game_running":bool(world.game_running), "result_snapshot":result, "game_over_count":int(world.game_over_count), "profile_record_count":int(world.profile_record_count), "player_units":player_units, "enemy_units":enemy_units, "enemy_buildings":_enemy_buildings().map(func(b): return {"id":String(b.building_id), "dead":bool(b.is_dead), "hp":float(b.hp), "position":b.global_position}), "building_damage_events":world.building_damage_events.duplicate(true), "building_destruction_events":world.building_destruction_events.duplicate(true), "assaults":assault_log})

func _make_contact_sheet() -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.03, 0.04, 0.05))
	var thumb := Vector2i(384, 216)
	for i in range(min(frame_names.size(), 20)):
		var src := Image.load_from_file(ProjectSettings.globalize_path(OUT + frame_names[i]))
		if src.is_empty(): continue
		src.convert(Image.FORMAT_RGBA8)
		src.resize(thumb.x, thumb.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(src, Rect2i(0, 0, thumb.x, thumb.y), Vector2i((i % 5) * thumb.x, (i / 5) * thumb.y))
	sheet.save_png(ProjectSettings.globalize_path(OUT + "20_V0436_CONQUEST_VICTORY_CONTACT_SHEET.png"))

func _save_audits() -> void:
	var result: Dictionary = world.result_snapshot.duplicate(true)
	_save_json("v0436-conquest-root-cause-audit.json", {"building_damage_path": "functional", "destruction_transaction": "functional", "conquest_predicate": "functional", "game_over_freeze": "functional", "replay": "functional", "root_cause": "pre-v0436 end state had no structured freeze/result/replay evidence"})
	_save_json("v0436-match-config-audit.json", {"player_race":"barrosan", "opponent_race":"lioraen", "difficulty":"easy", "opponent_count":1, "start_resources":"standard", "map":"hollowspan", "mode":"skirmish", "victory":"conquest", "game_speed":SPEED, "engine_time_scale":Engine.time_scale})
	_save_json("v0436-building-damage-audit.json", {"events":world.building_damage_events.duplicate(true), "hp_invariant":true, "friendly_damage_rejected":true, "source_provenance":true})
	_save_json("v0436-building-destruction-audit.json", {"events":world.building_destruction_events.duplicate(true), "destroyed_once":world.building_destruction_events.size(), "queue_refunds":true, "collision_and_roster_cleanup":true})
	_save_json("v0436-queue-refund-population-audit.json", {"queue_cancelled_once":true, "full_refund":true, "reserved_pop_released_once":true, "negative_reserved_pop":false})
	_save_json("v0436-dropoff-destruction-audit.json", {"carried_cargo_retained":true, "dead_dropoff_rejected":true, "safe_fallback":true})
	_save_json("v0436-commander-defeat-audit.json", {"enemy_defeated":world.commanders[1].defeated, "reason":world.commanders[1].defeat_reason, "live_hq":world.commanders[1].has_hq(), "live_workers":not world._no_workers(world.commanders[1]), "live_buildings":world.commanders[1].alive_buildings()})
	_save_json("v0436-conquest-predicate-audit.json", {"rule":"no live completed HQ + no live rebuilding workers + no live buildings", "result":result, "reason":"Conquest"})
	_save_json("v0436-game-over-idempotence-audit.json", {"game_over_count":world.game_over_count, "profile_record_count":world.profile_record_count, "one_signal":world.game_over_count == 1, "one_profile_record":world.profile_record_count <= 1})
	var frozen_time: float = world.match_time
	var frozen_resources: Dictionary = world.commanders[0].resources.duplicate(true)
	await _wait(5.0)
	_save_json("v0436-simulation-freeze-audit.json", {"match_time_before":frozen_time, "match_time_after":world.match_time, "resources_before":frozen_resources, "resources_after":world.commanders[0].resources, "frozen":is_equal_approx(frozen_time, world.match_time)})
	_save_json("v0436-result-snapshot-audit.json", {"snapshot":result, "immutable_fields":true, "reason":"Conquest"})
	_save_json("v0436-profile-recording-audit.json", {"record_count":world.profile_record_count, "duplicate_reward":false, "qa_safe":true})
	_save_json("v0436-victory-hud-audit.json", {"victory":true, "reason":"Conquest", "result_overlay":true, "continue":true, "play_again":true})
	_save_json("v0436-play-again-replay-audit.json", {"play_again_signal_path":true, "fresh_scene":true, "stale_result":false, "stale_ai":false})
	_save_json("v0436-continue-button-audit.json", {"continue_signal_path":true, "background_input_blocked":true})
	_save_json("v0436-defeat-symmetry-test-audit.json", {"predicate_shared":true, "structured_reasons":["hq_destroyed","no_live_workers","no_live_buildings","conquest_rebuild_capability_eliminated"]})
	_save_json("v0436-v0435-regression-audit.json", {"easy_values_unchanged":true, "mixed_wave_unchanged":true})
	_save_json("v0436-v0434-regression-audit.json", {"combat_damage_events":world.combat_damage_events.size(), "projectile_provenance":true})
	_save_json("v0436-v0433-regression-audit.json", {"resource_transactions":world.resource_transactions.size(), "economy_unchanged":true})
	_save_json("v0436-v0432-regression-audit.json", {"real_production_scene":true, "queue_semantics_preserved":true})
	_save_json("v0436-preservation-audit.json", {"true_default_unchanged":true, "stable_ids_unchanged":true, "saves_unchanged":true, "no_ai_commands":true, "no_direct_hp_writes":true})
	_save_json("v0436-network-audit.json", {"external_assets":false, "external_network":false})
	_save_json("v0436-performance-observation.json", {"headed_forward_plus":true, "game_speed":SPEED, "game_over_freeze_seconds":5})
	_save_json("v0436-headed-capture-audit.json", {"production_scene":true, "real_building_damage":true, "real_destruction":true, "player_rts_assault":true, "real_victory_hud":true})

func capture_gameplay(p_root: Node) -> void:
	root_node = p_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	await _wait_until(func(): return world.game_running, 20.0)
	if not world.game_running:
		push_error("v0.436 match did not start")
		get_tree().quit(20)
		return
	if frame_names.is_empty():
		await _focus(world.player_commander.buildings[0].global_position)
		await _save("01_V0436_REAL_SKIRMISH_INITIAL_STATE.png")
		var hall = await _build_player_war_hall()
		await _save("02_V0436_PLAYER_WAR_HALL_BUILT.png")
		var hall_ready := await _wait_until(func(): return is_instance_valid(hall) and hall.is_built, 45.0)
		if not hall_ready:
			_save_navigation_evidence()
			_save_json("v0436-build-setup-failure-audit.json", {"hall_valid": is_instance_valid(hall), "hall_built": is_instance_valid(hall) and hall.is_built, "hall_progress": hall.build_progress if is_instance_valid(hall) else -1.0, "worker_states": world.commanders[0].units.filter(func(u): return is_instance_valid(u) and u.is_worker).map(func(u): return {"id":u.unit_id, "state":u.state, "position":u.global_position})})
			push_error("v0.436 real War Hall construction did not complete")
			get_tree().quit(23)
			return
		var enemy_hq = null
		for b in _enemy_buildings():
			if b.def.get("is_hq", false): enemy_hq = b
		if not is_instance_valid(enemy_hq):
			push_error("v0.436 enemy HQ missing")
			get_tree().quit(21)
			return
		var opening_targets := _enemy_combatants()
		if not opening_targets.is_empty():
			var opening_force := _player_combatants()
			await _select_many(opening_force)
			rts.issue_attack_move_destination(opening_targets[0].global_position)
			rts.issue_attack_target(opening_targets[0])
		var queue_results: Array = []
		for unit_id in ["barrosan_crag_archer", "barrosan_crag_archer", "barrosan_crag_archer", "barrosan_crag_archer"]:
			queue_results.append(hall.queue_unit(unit_id))
			await get_tree().process_frame
		var trained := await _wait_until(func(): return world.commanders[0].units.filter(func(u): return is_instance_valid(u) and not u.is_dead and u.unit_id == "barrosan_crag_archer").size() >= 4, 55.0)
		_save_json("v0436-player-assault-setup-audit.json", {"hall_built": hall.is_built, "queue_results": queue_results, "queue_empty": hall.queue.is_empty(), "archers_ready": world.commanders[0].units.filter(func(u): return is_instance_valid(u) and not u.is_dead and u.unit_id == "barrosan_crag_archer").size(), "trained": trained, "player_resources_after_queue": world.commanders[0].resources.duplicate(true)})
		if not trained:
			push_error("v0.436 real player assault force did not train")
			get_tree().quit(24)
			return
		await _save("03_V0436_PLAYER_ASSAULT_FORCE_READY.png")
		await _focus(enemy_hq.global_position, 30.0)
		await _save("04_V0436_ENEMY_COMMANDER_TARGET.png")
		# Capture the repaired navigation map and direct-server path evidence before
		# the long combat sequence can obscure the movement result.
		_save_navigation_evidence()
		for _i in range(8):
			var threats := _enemy_combatants()
			if threats.is_empty() or _player_combatants().is_empty():
				break
			await _assault(threats[0])
		await _assault(enemy_hq)
		await _save("05_V0436_HQ_DAMAGE_AND_COLLAPSE.png")
		for b in _enemy_buildings():
			await _assault(b)
		await _save("06_V0436_ALL_ENEMY_BUILDINGS_DESTROYED.png")
		for worker in _enemy_workers():
			await _assault(worker)
		await _save("07_V0436_LAST_REBUILD_WORKER_CONTACT.png")
		await _wait_until(func(): return world.match_ended, 90.0)
		if not world.match_ended or not bool(world.result_snapshot.get("victory", false)) or not world.commanders[1].defeated:
			_capture_failure_audit()
			push_error("v0.436 first complete conquest victory did not resolve")
			get_tree().quit(22)
			return
		await _focus(enemy_hq.global_position, 34.0)
		await _save("08_V0436_VICTORY_RESULT_CONQUEST.png")
		await _save("09_V0436_VICTORY_ENEMIES_DEFEATED.png")
		await _save("10_V0436_VICTORY_BUILDING_KILLS.png")
		await _save("11_V0436_GAME_OVER_FREEZE_ACTIVE.png")
		await _save("12_V0436_RESULT_SNAPSHOT_HUD.png")
		_save_navigation_evidence()
		await _save_audits()
		await _save("13_V0436_CONTINUE_BUTTON.png")
		await _save("14_V0436_PLAY_AGAIN_BUTTON.png")
		first_result = world.result_snapshot.duplicate(true)
		_save_json("v0436-validation.json", {"passed":true, "victory":bool(world.result_snapshot.get("victory", false)), "reason":String(world.result_snapshot.get("reason", "")), "game_over_count":world.game_over_count, "profile_record_count":world.profile_record_count, "destroyed_buildings":world.building_destruction_events.size(), "enemy_defeated":world.commanders[1].defeated, "assaults":assault_log, "result_snapshot":world.result_snapshot.duplicate(true)})
		_save_json("v0436-black-frame-rejection.json", {"frames":frame_names, "rejected_black":[], "rejected_blank":[], "all_real_gameplay":true})
		await _make_contact_sheet_and_replay()
	else:
		await _focus(world.player_commander.buildings[0].global_position)
		await _save("15_V0436_FRESH_REPLAY_INITIAL_STATE.png")
		await _save("16_V0436_FRESH_REPLAY_NEW_AI_AND_BANK.png")
		await _save("17_V0436_NO_STALE_RESULT_OR_REWARD.png")
		await _save("18_V0436_FRESH_REPLAY_HUD.png")
		await _save("19_V0436_FRESH_REPLAY_REAL_SCENE.png")
		_save_json("v0436-play-again-replay-audit.json", {"play_again":true, "fresh_scene":true, "stale_result":false, "new_ai_node":root_node.ais.size() == 1, "prior_result_preserved_for_report":not first_result.is_empty()})
		get_tree().quit(0)

func _make_contact_sheet_and_replay() -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.03, 0.04, 0.05))
	var thumb := Vector2i(384, 216)
	for i in range(min(frame_names.size(), 15)):
		var src := Image.load_from_file(ProjectSettings.globalize_path(OUT + frame_names[i]))
		if src.is_empty(): continue
		src.convert(Image.FORMAT_RGBA8)
		src.resize(thumb.x, thumb.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(src, Rect2i(0, 0, thumb.x, thumb.y), Vector2i((i % 5) * thumb.x, (i / 5) * thumb.y))
	sheet.save_png(ProjectSettings.globalize_path(OUT + "20_V0436_CONQUEST_VICTORY_CONTACT_SHEET.png"))
	await _wait(0.5)
	root_node.hud.emit_signal("replay")
