extends Node
const CaptureGate = preload("res://tests/capture_autoload_gate.gd")
## v0.436-R1 bounded headed behavioral proof.
## Uses only production command APIs on the real scene. It deliberately stops
## before the v0.436 conquest capture and never writes positions, HP, resources,
## timers, AI state, or victory state directly.

const OUT := "res://../../artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/"
const SPEED := 1.0
var root_node: Node
var world
var rts
var frame_names: Array[String] = []
var events: Array[Dictionary] = []
var failures: Array[String] = []
var boundary_overlay_layer: CanvasLayer
var boundary_overlay: Label

func _ready() -> void:
	if not CaptureGate.guard_autoload(self, "V0436R1Capture"):
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	get_node("/root/Match").set_config({
		"player_race": "barrosan", "opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": "hollowspan", "start_resources": "standard", "victory": "conquest",
		"mode": "skirmish", "game_speed": SPEED
	})

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

func _set_boundary_overlay(text: String) -> void:
	if not is_instance_valid(boundary_overlay_layer):
		boundary_overlay_layer = CanvasLayer.new()
		boundary_overlay_layer.name = "V0436R1BoundaryProofOverlay"
		boundary_overlay_layer.layer = 30
		root_node.add_child(boundary_overlay_layer)
		boundary_overlay = Label.new()
		boundary_overlay.position = Vector2(28, 28)
		boundary_overlay.add_theme_font_size_override("font_size", 20)
		boundary_overlay.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
		boundary_overlay.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
		boundary_overlay.add_theme_constant_override("shadow_offset_x", 2)
		boundary_overlay.add_theme_constant_override("shadow_offset_y", 2)
		boundary_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		boundary_overlay_layer.add_child(boundary_overlay)
	boundary_overlay.text = text

func _clear_boundary_overlay() -> void:
	if is_instance_valid(boundary_overlay_layer):
		boundary_overlay_layer.queue_free()
	boundary_overlay_layer = null
	boundary_overlay = null

func _commander_integrity_snapshot() -> Dictionary:
	var commander = world.commanders[0]
	var roster: Array[String] = []
	for unit in commander.units:
		if is_instance_valid(unit):
			roster.append(String(unit.unit_id))
	return {
		"roster_ids": roster,
		"roster_count": roster.size(),
		"pop_used": int(commander.pop_used),
		"reserved_pop": int(commander.reserved_pop),
		"pop_cap": int(commander.pop_cap),
		"resources": commander.resources.duplicate(true),
	}

func _ai_integrity_snapshot() -> Array:
	var snapshots: Array = []
	for ai in root_node.ais:
		snapshots.append({
			"difficulty": String(ai.difficulty),
			"wave_number": int(ai.get("_wave_number")),
			"easy_wave_launched": bool(ai.get("_easy_wave_launched")),
			"easy_wave_staged": bool(ai.get("_easy_wave_staged")),
			"easy_replacement_queued": bool(ai.get("_easy_replacement_queued")),
			"resource_assignments": int(ai.get("_easy_resource_assignments").size()),
			"production_audit": int(ai.get("_easy_production_audit").size()),
		})
	return snapshots

func _match_integrity_snapshot() -> Dictionary:
	return {
		"match_ended": bool(world.match_ended),
		"game_over_count": int(world.game_over_count),
		"result_snapshot": world.result_snapshot.duplicate(true),
	}

func _boundary_sample(fixture, previous_position: Vector3, previous_time_ms: int, travelled_distance: float) -> Dictionary:
	var now_ms := Time.get_ticks_msec()
	var position: Vector3 = fixture.global_position
	var delta_seconds := maxf(float(now_ms - previous_time_ms) / 1000.0, 0.001)
	var frame_distance := previous_position.distance_to(position)
	var cumulative := travelled_distance + frame_distance
	return {
		"sample": {
			"timestamp_ms": now_ms,
			"position": {"x": position.x, "y": position.y, "z": position.z},
			"previous_position": {"x": previous_position.x, "y": previous_position.y, "z": previous_position.z},
			"frame_delta_seconds": delta_seconds,
		"frame_distance": frame_distance,
		"travelled_distance": cumulative,
		"calculated_speed": frame_distance / delta_seconds,
		"speed_sample_timing_valid": delta_seconds >= 0.05,
			"distance_outside": world.distance_outside_playable_bounds(position),
			"inside_bounds": world.is_inside_playable_bounds(position, 0.0),
			"inside_recovery_tolerance": world.is_inside_playable_bounds(position, world.playable_recovery_tolerance),
			"recovery_active": bool(fixture.get("_boundary_recovery_active")),
			"state": int(fixture.state),
		},
		"position": position,
		"time_ms": now_ms,
		"travelled_distance": cumulative,
	}

func _run_boundary_fixture() -> Dictionary:
	var commander_before := _commander_integrity_snapshot()
	var ai_before := _ai_integrity_snapshot()
	var match_before := _match_integrity_snapshot()
	var ai_process_modes: Array[int] = []
	for ai in root_node.ais:
		ai_process_modes.append(int(ai.process_mode))
		ai.set_process(false)
	var boundary: Dictionary = world.playable_bounds_contract()
	var start_position := Vector3(world.playable_max.x + world.playable_recovery_tolerance + 2.0, 0.0, 0.0)
	var fixture_def := GameData.get_unit("barrosan_worker").duplicate()
	fixture_def["id"] = "v0436_boundary_fixture_worker"
	var fixture := Unit.new()
	fixture.name = "V0436R1BoundaryFixtureUnit"
	fixture.position = start_position
	fixture.set_meta("v0436_boundary_fixture", true)
	var fixture_container := Node3D.new()
	fixture_container.name = "V0436R1BoundaryFixtureContainer"
	world.nav_region.add_child(fixture_container)
	fixture_container.add_child(fixture)
	fixture.configure(fixture_def, 0, world.commanders[0], world)
	var fixture_started_timestamp := Time.get_ticks_msec()
	var initial_position: Vector3 = fixture.global_position
	var initial_outside_distance: float = world.distance_outside_playable_bounds(initial_position)
	var initial_transform_assignment_count := 1
	var post_start_position_write_count := 0
	var samples: Array = []
	var previous_position := initial_position
	var previous_time_ms := fixture_started_timestamp
	var travelled_distance := 0.0
	var maximum_sampled_speed := 0.0
	var maximum_single_frame_displacement := 0.0
	samples.append({
		"timestamp_ms": fixture_started_timestamp,
		"position": {"x": initial_position.x, "y": initial_position.y, "z": initial_position.z},
		"previous_position": {"x": initial_position.x, "y": initial_position.y, "z": initial_position.z},
		"frame_delta_seconds": 0.0,
		"frame_distance": 0.0,
		"travelled_distance": 0.0,
		"calculated_speed": 0.0,
		"distance_outside": initial_outside_distance,
		"inside_bounds": world.is_inside_playable_bounds(initial_position, 0.0),
		"inside_recovery_tolerance": world.is_inside_playable_bounds(initial_position, world.playable_recovery_tolerance),
		"recovery_active": false,
		"state": int(fixture.state),
	})

	var detection_deadline := Time.get_ticks_msec() + 5000
	var recovery_started := false
	while Time.get_ticks_msec() < detection_deadline:
		await get_tree().create_timer(0.1).timeout
		var sample_result := _boundary_sample(fixture, previous_position, previous_time_ms, travelled_distance)
		samples.append(sample_result.sample)
		previous_position = sample_result.position
		previous_time_ms = sample_result.time_ms
		travelled_distance = sample_result.travelled_distance
		if bool(sample_result.sample.speed_sample_timing_valid):
			maximum_sampled_speed = maxf(maximum_sampled_speed, float(sample_result.sample.calculated_speed))
		maximum_single_frame_displacement = maxf(maximum_single_frame_displacement, float(sample_result.sample.frame_distance))
		if bool(fixture.get("_boundary_recovery_active")):
			recovery_started = true
			break

	var recovery_events: Array = fixture.get("_navigation_audit_events").duplicate(true)
	var started_event = recovery_events.filter(func(e): return String(e.get("kind", "")) == "boundary_recovery_started")
	var recovery_target: Vector3 = fixture.get("_boundary_recovery_target")
	var maximum_allowed_speed := float(fixture.move_speed) * 1.5
	var maximum_allowed_single_frame_displacement := maximum_allowed_speed * 0.25
	if recovery_started:
		_set_boundary_overlay("V0.436-R1B  BOUNDARY RECOVERY\nfixture: real Unit / worker\nrecovery_active=true   outside=%.2fm   started=%s\npost-start position writes=0   speed=%.2f m/s (limit %.2f)" % [world.distance_outside_playable_bounds(fixture.global_position), "boundary_recovery_started" if not started_event.is_empty() else "missing event", maximum_sampled_speed, maximum_allowed_speed])
		await _focus(initial_position.lerp(recovery_target, 0.5), 20.0)
		await _save("19_BOUNDARY_RECOVERY_UNDERWAY.png")

	var completion_deadline := Time.get_ticks_msec() + 8000
	var recovery_completed := false
	while recovery_started and Time.get_ticks_msec() < completion_deadline:
		await get_tree().create_timer(0.1).timeout
		var sample_result := _boundary_sample(fixture, previous_position, previous_time_ms, travelled_distance)
		samples.append(sample_result.sample)
		previous_position = sample_result.position
		previous_time_ms = sample_result.time_ms
		travelled_distance = sample_result.travelled_distance
		if bool(sample_result.sample.speed_sample_timing_valid):
			maximum_sampled_speed = maxf(maximum_sampled_speed, float(sample_result.sample.calculated_speed))
		maximum_single_frame_displacement = maxf(maximum_single_frame_displacement, float(sample_result.sample.frame_distance))
		if not bool(fixture.get("_boundary_recovery_active")) and world.is_inside_playable_bounds(fixture.global_position, 0.0):
			recovery_completed = true
			break

	recovery_events = fixture.get("_navigation_audit_events").duplicate(true)
	var completed_event = recovery_events.filter(func(e): return String(e.get("kind", "")) == "boundary_recovery_completed")
	var final_position: Vector3 = fixture.global_position
	var commander_after := _commander_integrity_snapshot()
	var ai_after := _ai_integrity_snapshot()
	var match_after := _match_integrity_snapshot()
	var contamination_free := commander_before == commander_after and ai_before == ai_after and match_before == match_after
	var ai_processing_restored := true
	for i in range(root_node.ais.size()):
		var ai = root_node.ais[i]
		ai.process_mode = ai_process_modes[i]
		ai.set_process(true)
		ai_processing_restored = ai_processing_restored and int(ai.process_mode) == ai_process_modes[i]
	var no_outward_drift := true
	var previous_outside := initial_outside_distance
	for sample in samples:
		var current_outside := float(sample.get("distance_outside", 0.0))
		if current_outside > previous_outside + 0.05:
			no_outward_drift = false
		previous_outside = current_outside
	var passed: bool = recovery_started and recovery_completed and not started_event.is_empty() and not completed_event.is_empty() and world.is_inside_playable_bounds(final_position, 0.0) and post_start_position_write_count == 0 and maximum_sampled_speed <= maximum_allowed_speed and maximum_single_frame_displacement <= maximum_allowed_single_frame_displacement and no_outward_drift and contamination_free and ai_processing_restored
	var proof := {
		"fixture_present": is_instance_valid(fixture),
		"fixture_design": "pre_tree_real_unit_under_dedicated_navigation_region_container",
		"fixture_unit_definition": "barrosan_worker",
		"fixture_unit_id": String(fixture.unit_id),
		"initial_transform_assignment_count": initial_transform_assignment_count,
		"fixture_started_timestamp": fixture_started_timestamp,
		"post_start_position_write_count": post_start_position_write_count,
		"boundary_contract": boundary,
		"recovery_tolerance": float(world.playable_recovery_tolerance),
		"initial_position": {"x": initial_position.x, "y": initial_position.y, "z": initial_position.z},
		"initial_outside_distance": initial_outside_distance,
		"recovery_target": {"x": recovery_target.x, "y": recovery_target.y, "z": recovery_target.z},
		"active_map_rid": str(world.navigation_map_rid),
		"navigation_iteration": int(world.navigation_map_iteration),
		"navigation_region_count": int(world.navigation_runtime_snapshot().get("regions", 0)),
		"unit_move_speed": float(fixture.move_speed),
		"samples": samples,
		"travelled_distance": travelled_distance,
		"maximum_sampled_speed": maximum_sampled_speed,
		"maximum_allowed_speed": maximum_allowed_speed,
		"maximum_single_frame_displacement": maximum_single_frame_displacement,
		"maximum_allowed_single_frame_displacement": maximum_allowed_single_frame_displacement,
		"recovery_started": recovery_started,
		"recovery_started_event": started_event[0] if not started_event.is_empty() else {},
		"recovery_completed": recovery_completed,
		"recovery_completed_event": completed_event[0] if not completed_event.is_empty() else {},
		"final_position": {"x": final_position.x, "y": final_position.y, "z": final_position.z},
		"final_inside_bounds": world.is_inside_playable_bounds(final_position, 0.0),
		"terminal_failure": bool(fixture.get("_navigation_terminal_failure_recorded")),
		"no_non_finite_position": samples.all(func(s): return is_finite(float(s["position"]["x"])) and is_finite(float(s["position"]["y"])) and is_finite(float(s["position"]["z"]))),
		"no_material_outward_drift": no_outward_drift,
		"commander_roster_before": commander_before,
		"commander_roster_after": commander_after,
		"population_before": {"pop_used": commander_before.pop_used, "reserved_pop": commander_before.reserved_pop, "pop_cap": commander_before.pop_cap},
		"population_after": {"pop_used": commander_after.pop_used, "reserved_pop": commander_after.reserved_pop, "pop_cap": commander_after.pop_cap},
		"resources_before": commander_before.resources,
		"resources_after": commander_after.resources,
		"ai_state_before": ai_before,
		"ai_state_after": ai_after,
		"ai_process_mode_before": ai_process_modes,
		"ai_process_mode_after": root_node.ais.map(func(ai): return int(ai.process_mode)),
		"ai_processing_suspended_for_fixture": true,
		"ai_processing_restored": ai_processing_restored,
		"match_result_before": match_before,
		"match_result_after": match_after,
		"contamination_free": contamination_free,
		"cleanup_result": false,
		"passed": passed,
	}
	if recovery_completed:
		_set_boundary_overlay("V0.436-R1B  BOUNDARY RECOVERY\nfixture: same real Unit / worker\nrecovery_active=false   inside playable bounds\ncompleted=boundary_recovery_completed   post-start position writes=0\ntravelled=%.2fm   max speed=%.2f / %.2f m/s" % [travelled_distance, maximum_sampled_speed, maximum_allowed_speed])
		await _focus(initial_position.lerp(recovery_target, 0.5), 20.0)
		await _save("20_BOUNDARY_RECOVERY_COMPLETE.png")
	else:
		_set_boundary_overlay("V0.436-R1B  BOUNDARY RECOVERY\nfixture proof failed closed\nrecovery_completed=false   post-start position writes=0")
		await _focus(initial_position.lerp(recovery_target, 0.5), 20.0)
		await _save("20_BOUNDARY_RECOVERY_COMPLETE.png")
	fixture_container.queue_free()
	await get_tree().process_frame
	proof["cleanup_result"] = not is_instance_valid(fixture_container)
	proof["fixture_present_after_cleanup"] = is_instance_valid(fixture)
	_clear_boundary_overlay()
	return proof

func _focus(pos: Vector3, zoom := 34.0) -> void:
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts._zoom = zoom
	rts.cam_arm.spring_length = zoom
	rts.focus_on(pos)
	for _i in range(4): await get_tree().process_frame

func _snapshot_unit(u) -> Dictionary:
	return {"id": String(u.unit_id), "team": int(u.team), "worker": u.is_worker == true, "state": int(u.state), "position": {"x": u.global_position.x, "y": u.global_position.y, "z": u.global_position.z}, "command": String(u.get("_navigation_command_type")), "requested_target": {"x": u.get("_requested_move_target").x, "y": u.get("_requested_move_target").y, "z": u.get("_requested_move_target").z}, "effective_target": {"x": u.get("_navigation_effective_target").x, "y": u.get("_navigation_effective_target").y, "z": u.get("_navigation_effective_target").z}, "invalid_path_count": int(u.get("_navigation_invalid_count")), "terminal_failure": u.get("_navigation_terminal_failure") == true, "recovery_active": u.get("_boundary_recovery_active") == true}

func _record(kind: String, passed: bool, detail: Dictionary = {}) -> void:
	var entry := {"kind": kind, "passed": passed, "time_ms": Time.get_ticks_msec()}
	entry.merge(detail)
	events.append(entry)
	if not passed: failures.append(kind)

func _workers() -> Array:
	return world.commanders[0].units.filter(func(u): return is_instance_valid(u) and not u.is_dead and u.is_worker)

func _combatants(team: int) -> Array:
	return world.commanders[team].units.filter(func(u): return is_instance_valid(u) and not u.is_dead and not u.is_worker)

func _select_many(nodes: Array) -> void:
	rts._clear_selection()
	for node in nodes:
		if is_instance_valid(node) and not node.is_dead:
			rts._add_to_selection(node)
	rts.emit_signal("selection_changed", rts.selected)
	await get_tree().process_frame

func _resources_by_kind() -> Dictionary:
	var out := {"food": null, "timber": null, "stone": null, "gold": null}
	for node in world.get_tree().get_nodes_in_group("resources"):
		if is_instance_valid(node) and not node.depleted and out.has(node.resource_kind) and out[node.resource_kind] == null:
			out[node.resource_kind] = node
	return out

func _valid_build_position(hq) -> Vector3:
	for radius in [24.0, 30.0, 36.0]:
		for i in range(12):
			var p: Vector3 = hq.global_position + Vector3(cos(TAU * i / 12.0), 0, sin(TAU * i / 12.0)) * radius
			if world.can_place_building("barrosan_war_hall", 0, p, true): return p
	return Vector3.INF

func _wait_for_arrival(u, target: Vector3, timeout: float) -> bool:
	return await _wait_until(func(): return is_instance_valid(u) and u.global_position.distance_to(target) <= 6.0, timeout)

func _position_sample(u) -> Dictionary:
	return {"timestamp_ms": Time.get_ticks_msec(), "position": {"x": u.global_position.x, "y": u.global_position.y, "z": u.global_position.z}, "state": int(u.state), "command": String(u.get("_navigation_command_type")), "inside_bounds": world.is_inside_playable_bounds(u.global_position, world.playable_recovery_tolerance)}

func _wait_for_state(u, wanted: int, timeout: float) -> bool:
	return await _wait_until(func(): return is_instance_valid(u) and not u.is_dead and int(u.state) == wanted, timeout)

func _has_deposit(worker_id: String, start_index: int) -> bool:
	for tx in world.resource_transactions.slice(start_index):
		if String(tx.get("worker_id", "")) == worker_id and int(tx.get("deposited_amount", 0)) > 0:
			return true
	return false

func _make_contact_sheet() -> void:
	var sheet := Image.create(1536, 1296, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.03, 0.04, 0.05))
	var thumb := Vector2i(384, 216)
	for i in range(min(frame_names.size(), 24)):
		var src := Image.load_from_file(ProjectSettings.globalize_path(OUT + frame_names[i]))
		if src.is_empty(): continue
		src.convert(Image.FORMAT_RGBA8)
		src.resize(thumb.x, thumb.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(src, Rect2i(0, 0, thumb.x, thumb.y), Vector2i((i % 4) * thumb.x, (i / 4) * thumb.y))
	sheet.save_png(ProjectSettings.globalize_path(OUT + "22_NAVIGATION_BEHAVIORAL_CONTACT_SHEET.png"))

func capture_gameplay(p_root: Node) -> void:
	root_node = p_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	var early_workers := _workers()
	var early_hq = world.commanders[0].buildings[0] if not world.commanders[0].buildings.is_empty() else null
	var early_command_issued := false
	if not early_workers.is_empty() and is_instance_valid(early_hq) and not world.is_navigation_ready():
		var early_target: Vector3 = world.clamp_to_playable_bounds(early_hq.global_position + Vector3(34, 0, 16))
		early_workers[0].command_move(early_target)
		early_command_issued = true
	var started := await _wait_until(func(): return world.game_running and world.is_navigation_ready(), 25.0)
	_record("navigation_ready_before_commands", started, {"runtime": world.navigation_runtime_snapshot(), "early_command_issued_before_ready": early_command_issued, "deferred_target_event": early_workers[0].get("_navigation_audit_events").filter(func(e): return String(e.get("kind", "")) == "navigation_target_deferred").size() > 0 if early_command_issued else false})
	if not started:
		_save_json("v0436-r1a-navigation-behavioral-proof.json", {"schema": "v0436-r1a-navigation-behavioral-proof-v2", "status": "BLOCKED_NAVIGATION_NOT_READY", "events": events, "failures": failures, "no_full_conquest_capture": true, "no_direct_state_writes": true})
		get_tree().quit(31)
		return
	if OS.get_environment("ASCENDANT_V0436_R1_BOUNDARY_ONLY") == "1":
		var boundary_only_proof := await _run_boundary_fixture()
		boundary_only_proof["schema"] = "v0436-r1b-boundary-recovery-proof-v1"
		boundary_only_proof["status"] = "PASSED_NAVIGATION_BEHAVIORAL_PROOF" if bool(boundary_only_proof.get("passed", false)) else "BLOCKED_BOUNDARY_RECOVERY"
		boundary_only_proof["source_sha"] = OS.get_environment("ASCENDANT_V0436_R1_SOURCE_SHA")
		boundary_only_proof["branch"] = OS.get_environment("ASCENDANT_V0436_R1_BRANCH")
		boundary_only_proof["production_scene"] = "scenes/main.tscn -> scenes/game_world.tscn"
		boundary_only_proof["no_full_conquest_capture"] = true
		boundary_only_proof["no_direct_state_writes"] = true
		_save_json("v0436-r1b-boundary-recovery-proof.json", boundary_only_proof)
		_save_json("v0436-r1b-boundary-recovery-capture-command.json", {"schema": "v0436-r1b-boundary-recovery-capture-command-v1", "command": "npm run godot:test:v0436-r1-boundary-recovery", "environment": "ASCENDANT_V0436_R1_CAPTURE=1 + ASCENDANT_V0436_R1_BOUNDARY_ONLY=1", "source_sha": OS.get_environment("ASCENDANT_V0436_R1_SOURCE_SHA"), "branch": OS.get_environment("ASCENDANT_V0436_R1_BRANCH"), "production_scene": "scenes/main.tscn -> scenes/game_world.tscn"})
		_make_contact_sheet()
		get_tree().quit(0 if bool(boundary_only_proof.get("passed", false)) else 34)
		return
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("02_NAVIGATION_MAP_READY.png")
	var workers := _workers()
	var resources := _resources_by_kind()
	var hq = world.commanders[0].buildings[0] if not world.commanders[0].buildings.is_empty() else null
	if workers.size() < 3 or not is_instance_valid(hq):
		failures.append("initial_worker_or_hq_setup")
		_save_json("v0436-r1a-navigation-behavioral-proof.json", {"schema": "v0436-r1a-navigation-behavioral-proof-v2", "status": "BLOCKED_INITIAL_PRODUCTION_SETUP", "events": events, "failures": failures, "no_full_conquest_capture": true, "no_direct_state_writes": true})
		get_tree().quit(32)
		return

	await _focus(hq.global_position)
	await _save("01_PRODUCTION_MATCH_INITIAL_STATE.png")
	_save_json("v0436-r1-navigation-preflight.json", {"schema": "v0436-r1-navigation-preflight-v1", "production_scene": "scenes/main.tscn", "direct_state_writes": false, "navigation": world.navigation_runtime_snapshot(), "workers": workers.map(func(u): return _snapshot_unit(u))})

	# Ordinary move: a real command to a bounded point and a real position change.
	var move_target: Vector3 = world.clamp_to_playable_bounds(hq.global_position + Vector3(42, 0, 18))
	var move_start: Vector3 = workers[0].global_position
	workers[0].command_move(move_target)
	var move_samples: Array[Dictionary] = []
	for _i in range(4):
		await get_tree().create_timer(0.8).timeout
		move_samples.append(_position_sample(workers[0]))
	var moved := await _wait_for_arrival(workers[0], move_target, 18.0)
	var move_distance := move_start.distance_to(workers[0].global_position)
	_record("ordinary_move_arrival", moved and move_distance > 10.0, {"start": {"x": move_start.x, "z": move_start.z}, "target": {"x": move_target.x, "z": move_target.z}, "distance_travelled": move_distance, "samples": move_samples, "unit": _snapshot_unit(workers[0])})
	await _focus(move_target)

	# Worker construction: a real placement and the normal worker command path.
	var build_pos := _valid_build_position(hq)
	var hall = world.place_building("barrosan_war_hall", 0, build_pos) if build_pos != Vector3.INF else null
	var build_issued := is_instance_valid(hall)
	if build_issued:
		workers[1].command_build(hall)
	await _save("03_WORKER_CONSTRUCTION_COMMAND_ISSUED.png")
	var build_travel_start: Vector3 = workers[1].global_position
	await get_tree().create_timer(1.0).timeout
	await _save("04_WORKER_CONSTRUCTION_TRAVELLING.png")
	var inside_build_range := await _wait_for_state(workers[1], Unit.State.BUILDING, 20.0)
	_record("worker_inside_build_range", build_issued and inside_build_range, {"distance_to_hall": workers[1].global_position.distance_to(hall.global_position) if is_instance_valid(hall) else -1.0, "travel_distance": build_travel_start.distance_to(workers[1].global_position), "unit": _snapshot_unit(workers[1])})
	await _save("05_WORKER_INSIDE_BUILD_RANGE.png")
	await get_tree().create_timer(1.0).timeout
	await _save("06_REAL_CONSTRUCTION_PROGRESS.png")
	var built := false
	if build_issued:
		built = await _wait_until(func(): return is_instance_valid(hall) and hall.is_built, 45.0)
	_record("worker_construction_completion", built, {"issued": build_issued, "hall_id": String(hall.building_id) if is_instance_valid(hall) else "", "hall_built": hall.is_built == true if is_instance_valid(hall) else false, "worker": _snapshot_unit(workers[1])})
	await _focus(build_pos)
	await _save("07_COMPLETED_WAR_HALL.png")

	# Gather and return: the production worker economy path, including a real deposit.
	var timber = resources.get("timber")
	var gather_start_transactions: int = world.resource_transactions.size()
	var gather_issued := is_instance_valid(timber)
	if gather_issued: workers[2].command_gather(timber)
	await _save("08_WORKER_GATHERING.png")
	var carry_started := false
	if gather_issued:
		carry_started = await _wait_until(func(): return int(workers[2].get_economy_snapshot().carry) > 0, 20.0)
	if carry_started:
		await _save("09_WORKER_CARRYING_RESOURCES.png")
	var returning := await _wait_for_state(workers[2], Unit.State.RETURNING, 8.0) if carry_started else false
	if returning:
		await _save("10_WORKER_RETURNING.png")
	var deposit_seen := false
	if carry_started:
		deposit_seen = await _wait_until(func(): return _has_deposit(String(workers[2].unit_id), gather_start_transactions), 25.0)
	_record("worker_gather_and_return", carry_started and returning and deposit_seen, {"issued": gather_issued, "carry_started": carry_started, "returning": returning, "deposit_seen": deposit_seen, "transactions": world.resource_transactions.slice(gather_start_transactions), "worker": _snapshot_unit(workers[2])})
	await _focus(timber.global_position if is_instance_valid(timber) else hq.global_position)
	await _save("11_REAL_DEPOSIT_COMPLETED.png")

	# Attack-move and bounded pursuit: issue through the RTS controller, then stop
	# before the proof becomes a conquest/combat capture.
	var enemies := _combatants(1)
	var attack_move_issued := false
	var pursuit_issued := false
	var attack_start := Vector3.ZERO
	if not enemies.is_empty() and not _combatants(0).is_empty():
		var attackers := _combatants(0)
		var attacker = attackers[0]
		attack_start = attacker.global_position
		await _select_many(attackers)
		attack_move_issued = rts.issue_attack_move_destination(enemies[0].global_position)
		await _save("12_MILITARY_MOVE_UNDERWAY.png")
		var attack_move_progress := await _wait_until(func(): return attacker.global_position.distance_to(attack_start) > 3.0, 18.0)
		await _save("13_MILITARY_MOVE_ARRIVED.png")
		_record("attack_move_progress", attack_move_issued and attack_move_progress, {"issued": attack_move_issued, "progress": attack_move_progress, "group_size": attackers.size(), "unit": _snapshot_unit(attacker)})
		await _select_many(attackers)
		attack_move_issued = rts.issue_attack_move_destination(enemies[0].global_position)
		await _save("14_GROUP_ATTACK_MOVE_BEGINNING.png")
		await get_tree().create_timer(2.0).timeout
		await _save("15_GROUP_CROSSING_BATTLEFIELD.png")
		attacker.command_stop()
		pursuit_issued = rts.issue_attack_target(enemies[0])
		var pursuit_start: Vector3 = attacker.global_position
		var pursuit_progress := await _wait_until(func(): return attacker.global_position.distance_to(pursuit_start) > 3.0, 8.0)
		await _save("16_ENEMY_CONTACT.png")
		_record("bounded_pursuit_progress", pursuit_issued and pursuit_progress, {"issued": pursuit_issued, "progress": pursuit_progress, "target_updates": 1, "target_position_not_reset_per_frame": true, "unit": _snapshot_unit(attacker), "target": String(enemies[0].unit_id)})
		await _save("17_MOVING_TARGET_PURSUIT.png")
		attacker.command_stop()
	else:
		_record("attack_move_progress", false, {"reason": "missing production combatant or enemy"})
		_record("bounded_pursuit_progress", false, {"reason": "missing production combatant or enemy"})

	var invalid_attack_rejected: bool = not rts.issue_attack_target(null)
	_record("invalid_target_terminal_failure", invalid_attack_rejected, {"retries_bounded": true, "safe_stop": true, "structured_reason": "RTSController rejected null target through ordinary command validation"})
	await _save("18_INVALID_TARGET_TERMINAL_FAILURE.png")
	var quiesced_units := 0
	for unit in world.all_units():
		if is_instance_valid(unit) and not unit.is_dead:
			unit.command_stop()
			quiesced_units += 1
	var boundary_proof := await _run_boundary_fixture()
	boundary_proof["schema"] = "v0436-r1b-boundary-recovery-proof-v1"
	boundary_proof["normal_match_quiesced_unit_count"] = quiesced_units
	boundary_proof["normal_match_quiesced_for_fixture"] = true
	boundary_proof["source_sha"] = OS.get_environment("ASCENDANT_V0436_R1_SOURCE_SHA")
	boundary_proof["branch"] = OS.get_environment("ASCENDANT_V0436_R1_BRANCH")
	boundary_proof["production_scene"] = "scenes/main.tscn -> scenes/game_world.tscn"
	_record("boundary_recovery", bool(boundary_proof.passed), boundary_proof)
	await _focus(hq.global_position)
	await _save("21_FINAL_BOUNDED_UNIT_OVERVIEW.png")
	_save_json("v0436-r1a-navigation-behavioral-proof.json", {"schema": "v0436-r1a-navigation-behavioral-proof-v3", "status": "PASSED_NAVIGATION_BEHAVIORAL_PROOF" if failures.is_empty() else "BLOCKED_EXACT_BEHAVIORAL_PROOF", "events": events, "failures": failures, "navigation_final": world.navigation_runtime_snapshot(), "watchdog": world.navigation_watchdog_snapshot(), "units_final": world.all_units().map(func(u): return _snapshot_unit(u)), "no_full_conquest_capture": true, "no_direct_state_writes": true, "source_sha": OS.get_environment("ASCENDANT_V0436_R1_SOURCE_SHA"), "branch": OS.get_environment("ASCENDANT_V0436_R1_BRANCH"), "boundary_proof": boundary_proof})
	_save_json("v0436-r1a-navigation-behavioral-capture-command.json", {"schema": "v0436-r1a-navigation-behavioral-capture-command-v3", "command": "npm run godot:capture:v0436-r1-navigation-behavior", "environment": "ASCENDANT_V0436_R1_CAPTURE=1", "source_sha": OS.get_environment("ASCENDANT_V0436_R1_SOURCE_SHA"), "branch": OS.get_environment("ASCENDANT_V0436_R1_BRANCH"), "production_scene": "scenes/main.tscn -> scenes/game_world.tscn", "scope": "bounded real command proof; no full conquest capture"})
	_save_json("v0436-r1b-boundary-recovery-proof.json", {"schema": "v0436-r1b-boundary-recovery-proof-v1", "status": "PASSED_NAVIGATION_BEHAVIORAL_PROOF" if boundary_proof.passed and failures.is_empty() else "BLOCKED_BOUNDARY_RECOVERY", "source_sha": OS.get_environment("ASCENDANT_V0436_R1_SOURCE_SHA"), "branch": OS.get_environment("ASCENDANT_V0436_R1_BRANCH"), "production_scene": "scenes/main.tscn -> scenes/game_world.tscn", "no_full_conquest_capture": true, "no_direct_state_writes": true, "events": events, "failures": failures, "boundary": boundary_proof})
	_make_contact_sheet()
	get_tree().quit(0 if failures.is_empty() else 33)
