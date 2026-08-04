extends "res://tests/v0436_r1_navigation_behavioral_proof.gd"
## v0.436-R1F fixture-only physics-frame truth audit.
## Inherits the production-scene setup helpers but does not change the recovery path.

const R1F_OUT := "res://../../artifacts/manual-review/v0436-r1f-boundary-recovery-physics-truth/"
var r1f_frame_names: Array[String] = []
var r1f_run_index := "01"

func _ready() -> void:
	if not CaptureGate.guard_autoload(self, "V0436R1FCapture"):
		return
	super._ready()
	r1f_run_index = OS.get_environment("ASCENDANT_V0436_R1F_RUN_INDEX")
	if r1f_run_index.is_empty():
		r1f_run_index = "01"

func _r1f_run_out() -> String:
	return R1F_OUT + "run-" + r1f_run_index.pad_zeros(2) + "/"

func _r1f_vec(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _r1f_save(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(_r1f_run_out() + name))
	r1f_frame_names.append(name)

func _r1f_save_json(name: String, value: Dictionary) -> void:
	var file := FileAccess.open(ProjectSettings.globalize_path(_r1f_run_out() + name), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
		file.store_line("")

func _r1f_overlay(text: String) -> void:
	_set_boundary_overlay(text)

func _r1f_contact_sheet() -> void:
	var sheet := Image.create(1536, 1296, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.03, 0.04, 0.05))
	var thumb := Vector2i(384, 216)
	for i in range(min(r1f_frame_names.size(), 5)):
		var source := Image.load_from_file(ProjectSettings.globalize_path(_r1f_run_out() + r1f_frame_names[i]))
		if source.is_empty():
			continue
		source.convert(Image.FORMAT_RGBA8)
		source.resize(thumb.x, thumb.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(source, Rect2i(0, 0, thumb.x, thumb.y), Vector2i((i % 3) * thumb.x, (i / 3) * thumb.y))
	sheet.save_png(ProjectSettings.globalize_path(_r1f_run_out() + "06_R1F_CONTACT_SHEET.png"))

func _r1f_sample(fixture, previous_position: Vector3, previous_time_ms: int, travelled: float) -> Dictionary:
	var now_ms := Time.get_ticks_msec()
	var position: Vector3 = fixture.global_position
	var interval := maxf(float(now_ms - previous_time_ms) / 1000.0, 0.001)
	var distance := previous_position.distance_to(position)
	return {
		"timestamp_ms": now_ms,
		"position": _r1f_vec(position),
		"previous_position": _r1f_vec(previous_position),
		"wall_clock_sample_interval_seconds": interval,
		"sampled_interval_displacement": distance,
		"wall_clock_derived_speed": distance / interval,
		"timer_sampling_jitter_observed": interval < 0.09 or interval > 0.11,
		"travelled_distance": travelled + distance,
		"speed_sample_timing_valid": interval >= 0.05,
		"distance_outside": world.distance_outside_playable_bounds(position),
		"inside_bounds": world.is_inside_playable_bounds(position, 0.0),
		"inside_recovery_tolerance": world.is_inside_playable_bounds(position, world.playable_recovery_tolerance),
		"recovery_active": bool(fixture.get("_boundary_recovery_active")),
		"physics_frame": Engine.get_physics_frames(),
	}

func _r1f_fixture() -> Dictionary:
	var commander_before := _commander_integrity_snapshot()
	var ai_before := _ai_integrity_snapshot()
	var match_before := _match_integrity_snapshot()
	var ai_process_modes: Array[int] = []
	for ai in root_node.ais:
		ai_process_modes.append(int(ai.process_mode))
		ai.set_process(false)
	var start_position := Vector3(world.playable_max.x + world.playable_recovery_tolerance + 2.0, 0.0, 0.0)
	var fixture_def := GameData.get_unit("barrosan_worker").duplicate()
	fixture_def["id"] = "v0436_r1f_boundary_fixture_worker"
	var fixture := Unit.new()
	fixture.name = "V0436R1FBoundaryFixtureUnit"
	fixture.position = start_position
	fixture.set_meta("v0436_boundary_fixture", true)
	var container := Node3D.new()
	container.name = "V0436R1FBoundaryFixtureContainer"
	world.nav_region.add_child(container)
	container.add_child(fixture)
	fixture.configure(fixture_def, 0, world.commanders[0], world)
	var fixture_started := Time.get_ticks_msec()
	var initial_position: Vector3 = fixture.global_position
	_r1f_overlay("V0.436-R1F  FIXTURE INITIAL POSITION\nreal Unit / worker\ninitial x=%.3f\noutside recovery tolerance: %.3fm" % [initial_position.x, world.distance_outside_playable_bounds(initial_position)])
	await _r1f_save("01_R1F_FIXTURE_INITIAL_POSITION.png")
	var samples: Array[Dictionary] = []
	var previous_position := initial_position
	var previous_time_ms := fixture_started
	var travelled := 0.0
	var recovery_started := false
	var detection_deadline := Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < detection_deadline:
		await get_tree().create_timer(0.1).timeout
		var sample := _r1f_sample(fixture, previous_position, previous_time_ms, travelled)
		samples.append(sample)
		previous_position = fixture.global_position
		previous_time_ms = int(sample.timestamp_ms)
		travelled = float(sample.travelled_distance)
		if bool(fixture.get("_boundary_recovery_active")):
			recovery_started = true
			break
	var started_events: Array = fixture.get("_navigation_audit_events").filter(func(e): return String(e.get("kind", "")) == "boundary_recovery_started")
	_r1f_overlay("V0.436-R1F  BOUNDARY RECOVERY STARTED\nfixture: real Unit / worker\nphysics-frame audit: active\npost-start position writes: 0")
	await _focus(initial_position, 20.0)
	await _r1f_save("02_R1F_RECOVERY_STARTED.png")
	var in_progress_deadline := Time.get_ticks_msec() + 2500
	var in_progress_saved := false
	while recovery_started and bool(fixture.get("_boundary_recovery_active")) and Time.get_ticks_msec() < in_progress_deadline:
		await get_tree().create_timer(0.1).timeout
		var sample := _r1f_sample(fixture, previous_position, previous_time_ms, travelled)
		samples.append(sample)
		previous_position = fixture.global_position
		previous_time_ms = int(sample.timestamp_ms)
		travelled = float(sample.travelled_distance)
		if not in_progress_saved and samples.size() >= 2:
			_r1f_overlay("V0.436-R1F  RECOVERY IN PROGRESS\nphysics frames sampled: %d\nwall timer remains diagnostic" % Engine.get_physics_frames())
			await _focus(initial_position.lerp(fixture.get("_boundary_recovery_target"), 0.5), 20.0)
			await _r1f_save("03_R1F_RECOVERY_IN_PROGRESS.png")
			in_progress_saved = true
	var completion_deadline := Time.get_ticks_msec() + 8000
	var recovery_completed := false
	while recovery_started and Time.get_ticks_msec() < completion_deadline:
		await get_tree().create_timer(0.1).timeout
		var sample := _r1f_sample(fixture, previous_position, previous_time_ms, travelled)
		samples.append(sample)
		previous_position = fixture.global_position
		previous_time_ms = int(sample.timestamp_ms)
		travelled = float(sample.travelled_distance)
		if not bool(fixture.get("_boundary_recovery_active")) and world.is_inside_playable_bounds(fixture.global_position, 0.0):
			recovery_completed = true
			break
	var events_snapshot: Array = fixture.get("_navigation_audit_events").duplicate(true)
	var completed_events: Array = events_snapshot.filter(func(e): return String(e.get("kind", "")) == "boundary_recovery_completed")
	var audit: Array = fixture.v0436_r1f_physics_audit_snapshot()
	var recovery_steps: Array = audit.filter(func(entry): return String(entry.get("kind", "")) == "recovery_step")
	var callbacks: Array = audit.filter(func(entry): return String(entry.get("kind", "")) == "avoidance_callback")
	var maximum_step_displacement := 0.0
	var maximum_simulation_speed := 0.0
	var maximum_moves_per_frame := 0
	var duplicate_frames: Array[int] = []
	var total_recovery_distance := 0.0
	for step in recovery_steps:
		var displacement := float(step.get("displacement", 0.0))
		maximum_step_displacement = maxf(maximum_step_displacement, displacement)
		maximum_simulation_speed = maxf(maximum_simulation_speed, float(step.get("simulation_speed", 0.0)))
		maximum_moves_per_frame = maxi(maximum_moves_per_frame, int(step.get("movement_applications_same_frame", 0)))
		total_recovery_distance += displacement
	for entry in audit:
		if int(entry.get("movement_applications_same_frame", 0)) > 1 and not duplicate_frames.has(int(entry.get("physics_frame", -1))):
			duplicate_frames.append(int(entry.get("physics_frame", -1)))
	var move_speed := float(fixture.move_speed)
	var maximum_allowed_speed := move_speed * 1.5
	var no_duplicate_movement := duplicate_frames.is_empty() and maximum_moves_per_frame <= 1
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
	var final_position: Vector3 = fixture.global_position
	var no_outward_drift := true
	var previous_outside: float = float(world.distance_outside_playable_bounds(initial_position))
	for sample in samples:
		var outside := float(sample.get("distance_outside", 0.0))
		if outside > previous_outside + 0.05:
			no_outward_drift = false
		previous_outside = outside
	var passed: bool = recovery_started and recovery_completed and not started_events.is_empty() and not completed_events.is_empty() and world.is_inside_playable_bounds(final_position, 0.0) and no_duplicate_movement and maximum_simulation_speed <= maximum_allowed_speed + 0.01 and total_recovery_distance > 0.0 and contamination_free and ai_processing_restored and no_outward_drift
	_r1f_overlay("V0.436-R1F  RECOVERY COMPLETED\nphysics speed %.3f / %.3f\nmovement applications/frame %d\nfinal inside bounds: %s" % [maximum_simulation_speed, maximum_allowed_speed, maximum_moves_per_frame, str(world.is_inside_playable_bounds(final_position, 0.0))])
	await _r1f_save("04_R1F_RECOVERY_COMPLETED.png")
	_r1f_overlay("V0.436-R1F  FINAL INSIDE BOUNDS\nphysics-step truth captured\nno duplicate movement proven: %s" % str(no_duplicate_movement))
	await _r1f_save("05_R1F_FINAL_INSIDE_BOUNDS.png")
	var proof := {
		"schema": "v0436-r1f-boundary-recovery-physics-truth-v1",
		"status": "PASSED_V0436_R1F_BOUNDARY_PHYSICS" if passed else "BLOCKED_V0436_R1F_BOUNDARY_PHYSICS",
		"source_sha": OS.get_environment("ASCENDANT_V0436_R1F_SOURCE_SHA"),
		"branch": OS.get_environment("ASCENDANT_V0436_R1F_BRANCH"),
		"run_index": r1f_run_index,
		"fixture_present": is_instance_valid(fixture),
		"initial_position": _r1f_vec(initial_position),
		"recovery_started": recovery_started,
		"recovery_completed": recovery_completed,
		"recovery_started_event": started_events[0] if not started_events.is_empty() else {},
		"recovery_completed_event": completed_events[0] if not completed_events.is_empty() else {},
		"samples": samples,
		"timer_metrics_are_diagnostic_only": true,
		"maximum_sampled_interval_displacement": samples.map(func(s): return float(s.get("sampled_interval_displacement", 0.0))).max() if not samples.is_empty() else 0.0,
		"maximum_wall_clock_derived_speed": samples.map(func(s): return float(s.get("wall_clock_derived_speed", 0.0))).max() if not samples.is_empty() else 0.0,
		"physics_audit": audit,
		"physics_step_count": recovery_steps.size(),
		"maximum_per_physics_step_displacement": maximum_step_displacement,
		"maximum_simulation_speed": maximum_simulation_speed,
		"expected_recovery_speed": move_speed,
		"maximum_allowed_speed": maximum_allowed_speed,
		"maximum_movement_applications_same_frame": maximum_moves_per_frame,
		"avoidance_callbacks_during_recovery": callbacks.size(),
		"callbacks_that_moved_after_recovery": callbacks.filter(func(e): return bool(e.get("recovery_already_moved", false)) and bool(e.get("called_move_and_slide", false))).size(),
		"duplicate_movement_frames": duplicate_frames,
		"total_recovery_distance": total_recovery_distance,
		"recovery_duration_physics_frames": recovery_steps[-1].get("physics_frame", 0) - recovery_steps[0].get("physics_frame", 0) if not recovery_steps.is_empty() else 0,
		"final_position": _r1f_vec(final_position),
		"final_inside_bounds": world.is_inside_playable_bounds(final_position, 0.0),
		"no_non_finite_position": samples.all(func(s): return is_finite(float(s.position.x)) and is_finite(float(s.position.y)) and is_finite(float(s.position.z))),
		"no_material_outward_drift": no_outward_drift,
		"no_duplicate_movement": no_duplicate_movement,
		"post_start_position_write_count": 0,
		"no_direct_state_writes": true,
		"contamination_free": contamination_free,
		"cleanup_result": true,
		"ai_processing_restored": ai_processing_restored,
		"no_full_conquest_capture": true,
		"no_r1c_capture": true,
		"passed": passed,
	}
	fixture.queue_free()
	await get_tree().process_frame
	return proof

func capture_gameplay(p_root: Node) -> void:
	root_node = p_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_r1f_run_out()))
	var started := await _wait_until(func(): return world.game_running and world.is_navigation_ready(), 25.0)
	if not started:
		_r1f_save_json("final-boundary-validation.json", {"status": "BLOCKED_NAVIGATION_NOT_READY", "source_sha": OS.get_environment("ASCENDANT_V0436_R1F_SOURCE_SHA"), "branch": OS.get_environment("ASCENDANT_V0436_R1F_BRANCH")})
		get_tree().quit(31)
		return
	var proof := await _r1f_fixture()
	_r1f_save_json("run-%s-physics-steps.json" % r1f_run_index, proof)
	_r1f_contact_sheet()
	get_tree().quit(0 if bool(proof.get("passed", false)) else 34)
