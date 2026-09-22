extends SceneTree
## R730-B1 causal proof for a physical projectile impact cue.

const ATTACKER_ID := "barrosan_crag_archer"
const TARGET_ID := "vorthak_ash_thrall"
const ATTACKER_POSITION := Vector3(-60.0, 0.0, -35.0)
const TARGET_POSITION := Vector3(-54.0, 0.0, -35.0)
const OBSERVATION_FRAMES := 240
const AUDIO_TAIL_FRAMES := 45

var output_root := ""
var phase_file: FileAccess
var prior_stream_by_player: Dictionary = {}
var launch_events: Array[Dictionary] = []
var impact_events: Array[Dictionary] = []
var damage_events: Array[Dictionary] = []
var damage_observed_engine_frame := -1
var impact_observed_engine_frame := -1
var damage_cursor := 0
var attacker: Node
var target: Node
var attacker_runtime_id := ""
var target_runtime_id := ""
var projectile_runtime_id := ""


func _init() -> void:
	output_root = OS.get_environment("R730B1_TEST_OUT")
	if output_root == "":
		output_root = ProjectSettings.globalize_path("res://../../artifacts/r730b1-projectile-impact/")
	DirAccess.make_dir_recursive_absolute(output_root)
	phase_file = FileAccess.open(output_root.path_join("phases.jsonl"), FileAccess.WRITE)
	call_deferred("_run")


func _phase(name: String, fields: Dictionary = {}) -> void:
	var row := {"phase":name, "timestamp":Time.get_datetime_string_from_system(true), "monotonic_ms":Time.get_ticks_msec(), "engine_frame":Engine.get_process_frames()}
	row.merge(fields)
	if phase_file:
		phase_file.store_line(JSON.stringify(row))
		phase_file.flush()
	print(JSON.stringify(row))


func _write_result(result: Dictionary) -> void:
	var file := FileAccess.open(output_root.path_join("result.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(result, "  "))
		file.close()
	_phase("TERMINAL", result)
	if phase_file:
		phase_file.close()
	quit(0 if bool(result.get("pass", false)) else 13)


func _world() -> Node:
	return current_scene.get_node_or_null("GameWorld") if current_scene != null else null


func _spawn_fixture() -> bool:
	var world := _world()
	if world == null:
		return false
	for existing in world.all_units():
		if is_instance_valid(existing):
			existing.free()
	attacker = world.spawn_unit(ATTACKER_ID, 0, ATTACKER_POSITION)
	target = world.spawn_unit(TARGET_ID, 1, TARGET_POSITION)
	if not is_instance_valid(attacker) or not is_instance_valid(target):
		return false
	attacker_runtime_id = str(attacker.get_instance_id())
	target_runtime_id = str(target.get_instance_id())
	target.set_process(false)
	target.set_physics_process(false)
	world._mark_visibility_radius(attacker.global_position, 22.0)
	world._update_player_visibility()
	attacker.set_process(false)
	attacker.set_physics_process(false)
	return true


func _sample_audio(elapsed_seconds: float) -> void:
	var manager := get_root().get_node_or_null("AudioManager")
	if manager == null:
		return
	var current: Dictionary = {}
	for player in manager.sfx_players:
		if not is_instance_valid(player) or not player.playing:
			continue
		var player_id := str(player.get_instance_id())
		var stream: AudioStream = player.stream
		var path := String(stream.resource_path) if stream else ""
		current[player_id] = path
		if String(prior_stream_by_player.get(player_id, "")) == path:
			continue
		var event := {"elapsed_seconds":elapsed_seconds, "engine_frame":Engine.get_process_frames(), "player_id":player_id, "stream_path":path}
		if path.ends_with("combat_arrow_shot.mp3"):
			launch_events.append(event)
			_phase("PROJECTILE_LAUNCH_AUDIO_REQUEST_OBSERVED", event)
		elif path.ends_with("combat_projectile_impact.wav"):
			impact_events.append(event)
			impact_observed_engine_frame = Engine.get_process_frames()
			_phase("PROJECTILE_IMPACT_AUDIO_REQUEST_OBSERVED", event)
	prior_stream_by_player = current


func _sample_projectile(world: Node) -> void:
	if projectile_runtime_id != "":
		return
	for projectile in world._projectile_container.get_children():
		if is_instance_valid(projectile) and String(projectile.source_runtime_id) == attacker_runtime_id:
			projectile_runtime_id = str(projectile.get_instance_id())
			_phase("PHYSICAL_PROJECTILE_OBSERVED", {"projectile_id":projectile_runtime_id, "kind":String(projectile.projectile_kind), "attacker_runtime_id":attacker_runtime_id, "target_runtime_id":target_runtime_id})
			return


func _record_damage(world: Node, baseline: int, elapsed_seconds: float) -> void:
	var events: Array = world.combat_damage_events
	damage_cursor = maxi(damage_cursor, baseline)
	if events.size() <= damage_cursor:
		return
	for event in events.slice(damage_cursor):
		if String(event.get("source_runtime_id", "")) != attacker_runtime_id:
			continue
		if String(event.get("victim_runtime_id", "")) != target_runtime_id:
			continue
		var copy: Dictionary = event.duplicate(true)
		copy["observed_elapsed_seconds"] = elapsed_seconds
		copy["observed_engine_frame"] = Engine.get_process_frames()
		damage_events.append(copy)
		if damage_observed_engine_frame < 0 and float(copy.get("observed_hp_delta", 0.0)) > 0.0:
			damage_observed_engine_frame = Engine.get_process_frames()
		_phase("LANDED_PROJECTILE_DAMAGE_OBSERVED", copy)
	damage_cursor = events.size()


func _run() -> void:
	_phase("DRIVER_ENTRY", {"task":"R730-B1", "mode":OS.get_environment("R730B1_TEST_MODE"), "source_sha":OS.get_environment("R730B1_SOURCE_SHA")})
	var match_config := get_root().get_node_or_null("Match")
	if match_config == null:
		_write_result({"terminal_reason":"BLOCKED_MATCH_CONFIG_MISSING", "pass":false})
		return
	match_config.set_config({"player_race":"barrosan", "opponents":[{"race":"vorthak", "difficulty":"easy"}], "map":"hollowspan", "start_resources":"rich", "victory":"conquest", "mode":"skirmish", "game_speed":1.0})
	change_scene_to_file("res://scenes/game_world.tscn")
	var ready := await _wait_until(func(): return _world() != null and bool(_world().game_running) and _world().commanders.size() >= 2, 35.0)
	if not ready or not _spawn_fixture():
		_write_result({"terminal_reason":"BLOCKED_RUNTIME_OR_FIXTURE", "pass":false})
		return
	var world := _world()
	if not attacker._can_attack_target(target):
		_write_result({"terminal_reason":"BLOCKED_FIXTURE_TARGET_NOT_VALID", "pass":false})
		return
	var mode := OS.get_environment("R730B1_TEST_MODE").to_lower()
	if mode == "nonlanded":
		await _run_nonlanded(world)
	else:
		await _run_landed(world)


func _wait_until(predicate: Callable, timeout_seconds: float) -> bool:
	var started := Time.get_ticks_msec()
	while float(Time.get_ticks_msec() - started) / 1000.0 < timeout_seconds:
		if predicate.call():
			return true
		await process_frame
	return bool(predicate.call())


func _run_landed(world: Node) -> void:
	var hp_before := float(target.hp)
	var damage_baseline: int = world.combat_damage_events.size()
	damage_cursor = damage_baseline
	var command_time := Time.get_ticks_msec()
	var command_frame := Engine.get_process_frames()
	_phase("FIXTURE_READY", {"attacker_id":ATTACKER_ID, "attacker_runtime_id":attacker_runtime_id, "target_id":TARGET_ID, "target_runtime_id":target_runtime_id, "target_hp_before":hp_before, "projectile_kind":"arrow", "damage_type":"pierce"})
	attacker.command_attack(target)
	attacker.set_process(true)
	attacker.set_physics_process(true)
	_phase("NORMAL_ATTACK_COMMAND_ISSUED", {"command_time_ms":command_time, "command_engine_frame":command_frame})
	var started := Time.get_ticks_msec()
	var damage_time_ms := -1
	var damage_frame := -1
	for _frame in OBSERVATION_FRAMES:
		await process_frame
		var elapsed := float(Time.get_ticks_msec() - started) / 1000.0
		_sample_audio(elapsed)
		_sample_projectile(world)
		_record_damage(world, damage_baseline, elapsed)
		if not damage_events.is_empty() and damage_time_ms < 0:
			damage_time_ms = int(damage_events[0].get("timestamp", Time.get_ticks_msec()))
			damage_frame = int(damage_events[0].get("observed_engine_frame", Engine.get_process_frames()))
		if not damage_events.is_empty() and not impact_events.is_empty():
			attacker.set_process(false)
			attacker.set_physics_process(false)
			for _tail in AUDIO_TAIL_FRAMES:
				await process_frame
				_sample_audio(float(Time.get_ticks_msec() - started) / 1000.0)
			break
	var hp_after := float(target.hp) if is_instance_valid(target) else -1.0
	var positive_damage := not damage_events.is_empty() and float(damage_events[0].get("observed_hp_delta", 0.0)) > 0.0 and hp_after < hp_before
	var frame_aligned: bool = damage_frame >= 0 and impact_observed_engine_frame >= 0 and abs(impact_observed_engine_frame - damage_frame) <= 1
	var passed: bool = positive_damage and launch_events.size() == 1 and impact_events.size() == 1 and projectile_runtime_id != "" and frame_aligned
	_write_result({"terminal_reason":"landed_case_complete" if passed else "LANDED_CASE_ASSERTION_FAILED", "pass":passed, "attacker_id":ATTACKER_ID, "attacker_runtime_id":attacker_runtime_id, "target_id":TARGET_ID, "target_runtime_id":target_runtime_id, "projectile_id":projectile_runtime_id, "command_time_ms":command_time, "command_engine_frame":command_frame, "launch_events":launch_events, "damage_events":damage_events, "impact_events":impact_events, "target_hp_before":hp_before, "target_hp_after":hp_after, "damage_time_ms":damage_time_ms, "damage_engine_frame":damage_frame, "impact_engine_frame":impact_observed_engine_frame, "impact_frame_delta":impact_observed_engine_frame - damage_frame, "positive_hp_reduction":positive_damage})


func _run_nonlanded(world: Node) -> void:
	var damage_baseline: int = world.combat_damage_events.size()
	damage_cursor = damage_baseline
	var command_time := Time.get_ticks_msec()
	var command_frame := Engine.get_process_frames()
	_phase("NON_LANDED_FIXTURE_READY", {"attacker_runtime_id":attacker_runtime_id, "target_runtime_id":target_runtime_id, "target_hp_before":float(target.hp)})
	attacker.command_attack(target)
	attacker.set_process(true)
	attacker.set_physics_process(true)
	var started := Time.get_ticks_msec()
	for _frame in 120:
		await process_frame
		var elapsed := float(Time.get_ticks_msec() - started) / 1000.0
		_sample_audio(elapsed)
		_sample_projectile(world)
		if not launch_events.is_empty():
			attacker.set_process(false)
			attacker.set_physics_process(false)
			target.queue_free()
			_phase("TARGET_INVALIDATED_AFTER_LAUNCH", {"projectile_id":projectile_runtime_id, "launch_event":launch_events[0]})
			break
	if not launch_events.is_empty():
		for _frame in 75:
			await process_frame
			var elapsed := float(Time.get_ticks_msec() - started) / 1000.0
			_sample_audio(elapsed)
			_sample_projectile(world)
			_record_damage(world, damage_baseline, elapsed)
	var passed := launch_events.size() == 1 and impact_events.is_empty() and damage_events.is_empty() and projectile_runtime_id != ""
	_write_result({"terminal_reason":"non_landed_case_complete" if passed else "NON_LANDED_CASE_ASSERTION_FAILED", "pass":passed, "attacker_id":ATTACKER_ID, "attacker_runtime_id":attacker_runtime_id, "target_id":TARGET_ID, "target_runtime_id":target_runtime_id, "projectile_id":projectile_runtime_id, "command_time_ms":command_time, "command_engine_frame":command_frame, "launch_events":launch_events, "damage_events":damage_events, "impact_events":impact_events})
