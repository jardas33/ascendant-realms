extends SceneTree
## R730-A focused runtime proof for melee sword-hit cue causality.
## This driver is test-only: it uses normal GameRoot/GameWorld/unit commands and
## observes the existing AudioManager pool without changing production state.

const OBSERVATION_FRAMES := 240
const AUDIO_TAIL_FRAMES := 45
const ATTACKER_ID := "barrosan_spear_guard"
const TARGET_ID := "vorthak_ash_thrall"
const ATTACKER_POSITION := Vector3(-60.0, 0.0, -35.0)
const TARGET_POSITION := Vector3(-54.0, 0.0, -35.0)

var output_root := ""
var phase_file: FileAccess
var previous_sword_playing: Dictionary = {}
var sword_events: Array[Dictionary] = []
var source_damage_events: Array[Dictionary] = []
var damage_observed_engine_frame := -1
var attacker: Node
var target: Node
var attacker_runtime_id := ""
var target_runtime_id := ""

func _init() -> void:
	output_root = OS.get_environment("R730A_TEST_OUT")
	if output_root == "":
		output_root = ProjectSettings.globalize_path("res://../../artifacts/r730a-combat-hit-audio-sync/")
	DirAccess.make_dir_recursive_absolute(output_root)
	phase_file = FileAccess.open(output_root.path_join("phases.jsonl"), FileAccess.WRITE)
	call_deferred("_run")

func _phase(name: String, fields: Dictionary = {}) -> void:
	var row := {"phase":name, "timestamp":Time.get_datetime_string_from_system(true), "monotonic_seconds":Time.get_ticks_msec() / 1000.0, "engine_frame":Engine.get_process_frames()}
	row.merge(fields)
	if phase_file:
		phase_file.store_line(JSON.stringify(row))
		phase_file.flush()
	print(JSON.stringify(row))

func _write_json(name: String, value: Dictionary) -> void:
	var file := FileAccess.open(output_root.path_join(name), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
		file.close()

func _wait_until(predicate: Callable, timeout_seconds: float) -> bool:
	var started := Time.get_ticks_msec() / 1000.0
	while Time.get_ticks_msec() / 1000.0 - started < timeout_seconds:
		if predicate.call():
			return true
		await process_frame
	return bool(predicate.call())

func _unit_payload(unit: Node) -> Dictionary:
	return {
		"unit_id":String(unit.unit_id),
		"runtime_id":str(unit.get_instance_id()),
		"team":int(unit.team),
		"hp":float(unit.hp),
		"max_hp":float(unit.max_hp),
		"position":{"x":unit.global_position.x, "y":unit.global_position.y, "z":unit.global_position.z},
		"alive":not bool(unit.is_dead),
		"attack_range":float(unit.get("atk_range")),
		"attack_cd":float(unit.get("attack_cd")),
		"base_damage":float(unit.get("base_dmg")),
		"damage_type":String(unit.get("dmg_type")),
	}

func _sample_sword_audio(elapsed_seconds: float) -> void:
	var manager: Node = get_root().get_node_or_null("AudioManager")
	if manager == null:
		return
	var current: Dictionary = {}
	for player in manager.sfx_players:
		if not is_instance_valid(player):
			continue
		var player_id := str(player.get_instance_id())
		var stream: AudioStream = player.stream
		var stream_path := String(stream.resource_path) if stream else ""
		var is_sword := bool(player.playing) and stream_path.contains("combat_sword_hit.mp3")
		current[player_id] = is_sword
		if is_sword and not bool(previous_sword_playing.get(player_id, false)):
			var event := {"elapsed_seconds":elapsed_seconds, "engine_frame":Engine.get_process_frames(), "player_id":player_id, "stream_path":stream_path}
			sword_events.append(event)
			_phase("SWORD_AUDIO_REQUEST_OBSERVED", event)
	previous_sword_playing = current

func _record_source_damage(baseline_event_count: int, elapsed_seconds: float) -> void:
	if world_is_missing():
		return
	if not source_damage_events.is_empty():
		return
	var events: Array = current_world().combat_damage_events
	if events.size() <= baseline_event_count:
		return
	for event in events.slice(baseline_event_count):
		if String(event.get("source_id", "")) != ATTACKER_ID or String(event.get("victim_id", "")) != TARGET_ID:
			continue
		if attacker_runtime_id != "" and String(event.get("source_runtime_id", "")) != attacker_runtime_id:
			continue
		if target_runtime_id != "" and String(event.get("victim_runtime_id", "")) != target_runtime_id:
			continue
		var copy: Dictionary = event.duplicate(true)
		copy["observed_elapsed_seconds"] = elapsed_seconds
		copy["observed_engine_frame"] = Engine.get_process_frames()
		source_damage_events.append(copy)
		damage_observed_engine_frame = Engine.get_process_frames()
		_phase("LANDED_MELEE_DAMAGE_OBSERVED", copy)

func current_world() -> Node:
	return current_scene.get_node_or_null("GameWorld") if current_scene != null else null

func world_is_missing() -> bool:
	return current_scene == null or current_world() == null

func _spawn_fixture() -> bool:
	var world := current_world()
	if world == null:
		return false
	# Keep the production scene and unit implementation intact while isolating
	# this causal check from the normal match's starting army. Those units can
	# otherwise produce independent sword cues during the observation window.
	for existing in world.all_units():
		if is_instance_valid(existing):
			existing.free()
	attacker = world.spawn_unit(ATTACKER_ID, 0, ATTACKER_POSITION)
	target = world.spawn_unit(TARGET_ID, 1, TARGET_POSITION)
	if not is_instance_valid(attacker) or not is_instance_valid(target):
		return false
	attacker_runtime_id = str(attacker.get_instance_id())
	target_runtime_id = str(target.get_instance_id())
	# Freeze the defender's unit AI so the fixture measures the attacker's cue
	# without a simultaneous retaliatory sword playback from the target.
	target.set_process(false)
	target.set_physics_process(false)
	# Spawned test targets are subject to the real match's fog visibility gate.
	# Reveal only the fixture point through the existing visibility contract.
	world._mark_visibility_radius(attacker.global_position, 22.0)
	world._update_player_visibility()
	# Wait for an explicit command below before the attacker can auto-acquire.
	attacker.set_process(false)
	attacker.set_physics_process(false)
	return true

func _run() -> void:
	_phase("DRIVER_ENTRY", {"task":"R730-A", "mode":OS.get_environment("R730A_TEST_MODE"), "source_sha":OS.get_environment("R730A_SOURCE_SHA")})
	var match_config: Node = get_root().get_node_or_null("Match")
	if match_config == null:
		_write_result("BLOCKED_MATCH_CONFIG_MISSING", false, false, -1.0, -1.0)
		return
	match_config.set_config({"player_race":"barrosan", "opponents":[{"race":"vorthak", "difficulty":"easy"}], "map":"hollowspan", "start_resources":"rich", "victory":"conquest", "mode":"skirmish", "game_speed":1.0})
	change_scene_to_file("res://scenes/game_world.tscn")
	var ready := await _wait_until(func(): return current_scene != null and current_world() != null and bool(current_world().game_running) and current_world().commanders.size() >= 2, 35.0)
	if not ready:
		_write_result("BLOCKED_RUNTIME_NOT_READY", false, false, -1.0, -1.0)
		return
	_phase("PRODUCTION_READY", {"scene":"res://scenes/game_world.tscn", "world_unit_count":current_world().all_units().size(), "commanders":current_world().commanders.size()})
	var mode := OS.get_environment("R730A_TEST_MODE").to_lower()
	if mode == "nonlanded":
		await _run_nonlanded()
	else:
		await _run_success()

func _run_success() -> void:
	if not _spawn_fixture():
		_write_result("BLOCKED_FIXTURE_SPAWN", false, false, -1.0, -1.0)
		return
	var world := current_world()
	if not attacker._can_attack_target(target):
		_write_result("BLOCKED_FIXTURE_TARGET_NOT_VALID", false, false, -1.0, -1.0)
		return
	var hp_before := float(target.hp)
	var event_baseline: int = world.combat_damage_events.size()
	var command_time := Time.get_ticks_msec() / 1000.0
	var command_engine_frame := Engine.get_process_frames()
	_phase("FIXTURE_READY", {"attacker":_unit_payload(attacker), "target":_unit_payload(target), "attack_valid":attacker._can_attack_target(target), "target_hp_before":hp_before})
	attacker.command_attack(target)
	attacker.set_process(true)
	attacker.set_physics_process(true)
	_phase("NORMAL_ATTACK_COMMAND_ISSUED", {"attacker_id":ATTACKER_ID, "target_id":TARGET_ID, "command_time":command_time, "target_hp_before":hp_before})
	var damage_time := -1.0
	var previous_hp := hp_before
	var started := Time.get_ticks_msec() / 1000.0
	var started_frame := Engine.get_process_frames()
	while Engine.get_process_frames() - started_frame < OBSERVATION_FRAMES:
		await process_frame
		var elapsed := Time.get_ticks_msec() / 1000.0 - started
		_sample_sword_audio(elapsed)
		_record_source_damage(event_baseline, elapsed)
		if damage_time < 0.0 and is_instance_valid(target) and float(target.hp) < previous_hp - 0.001:
			damage_time = Time.get_ticks_msec() / 1000.0
			previous_hp = float(target.hp)
		else:
			previous_hp = float(target.hp) if is_instance_valid(target) else previous_hp
		if damage_time >= 0.0 and not sword_events.is_empty():
			break
	var sword_after_damage: bool = not sword_events.is_empty() and int(sword_events[0].get("engine_frame", -1)) == damage_observed_engine_frame
	var damage_observed := not source_damage_events.is_empty() and damage_time >= 0.0
	var passed := damage_observed and sword_after_damage and sword_events.size() == 1
	if passed:
		# Hold the fixture at the hit pose while Movie Maker records the audible
		# tail, preventing a later cooldown cycle from adding another sword cue.
		attacker.set_process(false)
		attacker.set_physics_process(false)
		for _frame in AUDIO_TAIL_FRAMES:
			await process_frame
	var result := {
		"terminal_reason":"success_case_complete" if passed else "SUCCESS_CASE_ASSERTION_FAILED",
		"pass":passed,
		"damage_observed":damage_observed,
		"damage_time_since_command":damage_time - command_time if damage_time >= 0.0 else -1.0,
		"damage_engine_frames_since_command":damage_observed_engine_frame - command_engine_frame,
		"damage_observed_engine_frame":damage_observed_engine_frame,
		"sword_request_count":sword_events.size(),
		"sword_events":sword_events,
		"source_damage_events":source_damage_events,
		"target_hp_before":hp_before,
		"target_hp_after":float(target.hp) if is_instance_valid(target) else -1.0,
	}
	_write_json("result.json", result)
	_phase("TERMINAL", result)
	if phase_file:
		phase_file.close()
	quit(0 if bool(result["pass"]) else 13)

func _run_nonlanded() -> void:
	if not _spawn_fixture():
		_write_result("BLOCKED_FIXTURE_SPAWN", false, false, -1.0, -1.0)
		return
	var world := current_world()
	if not attacker._can_attack_target(target):
		_write_result("BLOCKED_FIXTURE_TARGET_NOT_VALID", false, false, -1.0, -1.0)
		return
	var event_baseline: int = world.combat_damage_events.size()
	var command_time := Time.get_ticks_msec() / 1000.0
	_phase("FIXTURE_READY", {"attacker":_unit_payload(attacker), "target":_unit_payload(target), "attack_valid":attacker._can_attack_target(target), "case":"target_invalidated_after_attack_start"})
	attacker.command_attack(target)
	target.queue_free()
	attacker.set_process(true)
	attacker.set_physics_process(true)
	_phase("NORMAL_ATTACK_COMMAND_ISSUED_THEN_TARGET_INVALIDATED", {"attacker_id":ATTACKER_ID, "target_id":TARGET_ID, "command_time":command_time})
	var started := Time.get_ticks_msec() / 1000.0
	var started_frame := Engine.get_process_frames()
	while Engine.get_process_frames() - started_frame < OBSERVATION_FRAMES:
		await process_frame
		var elapsed := Time.get_ticks_msec() / 1000.0 - started
		_sample_sword_audio(elapsed)
		_record_source_damage(event_baseline, elapsed)
	var passed := source_damage_events.is_empty() and sword_events.is_empty()
	var result := {"terminal_reason":"non_landed_case_complete" if passed else "NON_LANDED_CASE_ASSERTION_FAILED", "pass":passed, "source_damage_event_count":source_damage_events.size(), "sword_request_count":sword_events.size(), "sword_events":sword_events, "source_damage_events":source_damage_events}
	_write_json("result.json", result)
	_phase("TERMINAL", result)
	if phase_file:
		phase_file.close()
	quit(0 if passed else 13)

func _write_result(reason: String, passed: bool, damage: bool, damage_time: float, cue_time: float) -> void:
	var result := {"terminal_reason":reason, "pass":passed, "damage_observed":damage, "damage_time":damage_time, "sword_request_time":cue_time}
	_write_json("result.json", result)
	_phase("TERMINAL", result)
	if phase_file:
		phase_file.close()
	quit(13)
