extends Node
## P1-S4 deterministic command-intent and accepted-order acknowledgement harness.
## It exercises the existing RTSController dispatch with explicit hit/ground
## context so no OS-pointer warping or gameplay command semantics are added.

var _root: Node
var _world: Node
var _rts: Node
var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _intent_cases: Array = []
var _ack_cases: Array = []
var _failures: Array = []
var _entities: Dictionary = {}
var _fixture_building = null
var _fixture_metadata: Dictionary = {}
var _extended_feedback: Dictionary = {}
var _extended_valid_build_position := Vector3.INF

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1S4_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1S4_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1S4_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1s4-command-feedback/default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	get_node("/root/Match").set_config({
		"player_race": "barrosan",
		"opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": "hollowspan",
		"start_resources": "standard",
		"victory": "conquest",
		"mode": "skirmish",
		"game_speed": 1.0
	})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	await get_tree().process_frame
	await _wait_for_runtime()
	if _world == null or _rts == null:
		_failures.append("runtime_missing")
		_write_manifest()
		get_tree().quit(1)
		return
	get_tree().paused = true
	await get_tree().process_frame
	_entities = _find_entities()
	_create_review_fixture()
	await _wait_fixture_physics()
	_run_intent_cases()
	await _run_extended_command_cases()
	if _width == 1920:
		await _capture_command("01_MOVE_ACK", "worker", null, _move_destination(), "MOVE", "MOVE", _move_destination())
		await _capture_command("02_ATTACK_ACK", "military", _entities.get("enemy"), _entities.get("enemy").global_position if is_instance_valid(_entities.get("enemy")) else Vector3.ZERO, "ATTACK", "ATTACK", _entities.get("enemy").global_position if is_instance_valid(_entities.get("enemy")) else Vector3.ZERO)
		await _capture_command("03_GATHER_ACK", "worker", _entities.get("resource"), _entities.get("resource").global_position if is_instance_valid(_entities.get("resource")) else Vector3.ZERO, "GATHER", "GATHER", _entities.get("resource").global_position if is_instance_valid(_entities.get("resource")) else Vector3.ZERO)
		await _capture_command("04_BUILD_CONTINUE_ACK", "worker", _fixture_building, _fixture_building.global_position if is_instance_valid(_fixture_building) else Vector3.ZERO, "BUILD_OR_REPAIR", "BUILD/CONTINUE", _fixture_building.global_position if is_instance_valid(_fixture_building) else Vector3.ZERO)
		await _capture_command("05_RALLY_ACK", "hq", null, _rally_destination(), "RALLY", "RALLY", _entities.get("hq").global_position if is_instance_valid(_entities.get("hq")) else Vector3.ZERO)
		await _capture_command("06_ATTACK_MOVE_ACK", "military", null, _attack_move_destination(), "ATTACK_MOVE", "ATTACK-MOVE", _attack_move_destination())
		await _capture_build_context("07_BUILD_VALID_CURSOR_CONTEXT", true)
		await _capture_build_context("08_BUILD_INVALID_CURSOR_CONTEXT", false)
		await _capture_ui_hover("09_UI_HOVER_SAFE")
		await _capture_extended_command_frames()
	else:
		await _capture_command("10_1366_MOVE_ACK", "worker", null, _move_destination(), "MOVE", "MOVE", _move_destination())
		await _capture_command("11_1366_ATTACK_ACK", "military", _entities.get("enemy"), _entities.get("enemy").global_position if is_instance_valid(_entities.get("enemy")) else Vector3.ZERO, "ATTACK", "ATTACK", _entities.get("enemy").global_position if is_instance_valid(_entities.get("enemy")) else Vector3.ZERO)
		await _capture_command("12_1366_GATHER_OR_BUILD_ACK", "worker", _entities.get("resource"), _entities.get("resource").global_position if is_instance_valid(_entities.get("resource")) else Vector3.ZERO, "GATHER", "GATHER", _entities.get("resource").global_position if is_instance_valid(_entities.get("resource")) else Vector3.ZERO)
	_clear_selection()
	_remove_fixture()
	await get_tree().process_frame
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _run_extended_command_cases() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/world/rts_controller.gd")
	for mapping in [
		'cmd_stop"): _cmd_stop()',
		'cmd_hold"): _cmd_hold()',
		'cmd_patrol"): _cmd_patrol_prompt()',
		'cmd_guard"): _cmd_guard()'
	]:
		if not source.contains(mapping):
			_failures.append("missing_input_mapping_" + mapping.get_slice('"', 0))
	if source.contains('cmd_guard"): pass') or source.contains("command_guard("):
		_failures.append("guard_issued_gameplay_command")

	_select("worker")
	var worker = _entities.get("worker")
	if not is_instance_valid(worker):
		return
	_rts.issue_stop()
	var stop_feedback: Dictionary = _rts.get_command_feedback_snapshot()
	_record_extended_ack("STOP", "STOP", stop_feedback, bool(stop_feedback.get("accepted", false)) and worker.state == Unit.State.IDLE)

	_rts.issue_hold()
	var hold_feedback: Dictionary = _rts.get_command_feedback_snapshot()
	_record_extended_ack("HOLD", "HOLD", hold_feedback, bool(hold_feedback.get("accepted", false)) and worker.state == Unit.State.HOLD)

	var patrol_destination: Vector3 = worker.global_position + Vector3(9.0, 0.0, 1.0)
	_rts.issue_patrol(patrol_destination)
	var patrol_feedback: Dictionary = _rts.get_command_feedback_snapshot()
	_record_extended_ack("PATROL", "PATROL", patrol_feedback, bool(patrol_feedback.get("accepted", false)) and worker.state == Unit.State.PATROL and _feedback_matches_position(patrol_feedback, patrol_destination))

	var state_before_guard: int = worker.state
	_rts._cmd_guard()
	var guard_feedback: Dictionary = _rts.get_command_feedback_snapshot()
	_record_extended_ack("GUARD_UNAVAILABLE", "UNAVAILABLE", guard_feedback, not bool(guard_feedback.get("accepted", true)) and String(guard_feedback.get("intent", "")) == "GUARD" and worker.state == state_before_guard)

	var hq = _entities.get("hq")
	if not is_instance_valid(hq):
		return
	_rts.enter_build_mode("barrosan_clan_croft")
	var building_count_before: int = _world.commanders[0].buildings.size()
	var resources_before: Dictionary = _world.commanders[0].resources.duplicate(true)
	var invalid_result: bool = _rts._try_place_building_at(hq.global_position)
	var invalid_feedback: Dictionary = _rts.get_command_feedback_snapshot()
	_record_extended_ack("BUILD_REJECTED", "REJECTED", invalid_feedback, not invalid_result and not bool(invalid_feedback.get("accepted", true)) and String(invalid_feedback.get("intent", "")) == "BUILD_OR_REPAIR" and _world.commanders[0].buildings.size() == building_count_before and _world.commanders[0].resources == resources_before)
	_rts.cancel_build_mode()

	var valid_position := _find_valid_build_position()
	if valid_position == Vector3.INF:
		_failures.append("missing_valid_build_position")
		return
	_extended_valid_build_position = valid_position
	var valid_result: bool = _rts._try_place_building_at(valid_position)
	var valid_feedback: Dictionary = _rts.get_command_feedback_snapshot()
	_record_extended_ack("BUILD_VALID", "BUILD PLACEMENT", valid_feedback, valid_result and bool(valid_feedback.get("accepted", false)) and String(valid_feedback.get("intent", "")) == "BUILD_OR_REPAIR")

func _record_extended_ack(name: String, expected_feedback_type: String, feedback: Dictionary, passed: bool) -> void:
	_extended_feedback[name] = feedback.duplicate(true)
	_ack_cases.append({"name": name, "command": name, "accepted": bool(feedback.get("accepted", false)), "feedback": feedback, "pass": passed})
	if String(feedback.get("feedback_type", "")) != expected_feedback_type or not passed:
		_failures.append("ack_" + name.to_lower())

func _capture_extended_command_frames() -> void:
	var worker = _entities.get("worker")
	var hq = _entities.get("hq")
	if not is_instance_valid(worker) or not is_instance_valid(hq):
		return
	_select("worker")
	_clear_fx()
	_rts.issue_stop()
	var stop_feedback: Dictionary = _rts.get_command_feedback_snapshot()
	await _render_frame("10_STOP_ACK", worker, "STOP", "STOP", null, stop_feedback, worker.global_position)
	_clear_fx()
	_rts.issue_hold()
	var hold_feedback: Dictionary = _rts.get_command_feedback_snapshot()
	await _render_frame("11_HOLD_ACK", worker, "HOLD", "HOLD", null, hold_feedback, worker.global_position)
	var patrol_destination: Vector3 = worker.global_position + Vector3(9.0, 0.0, 1.0)
	_clear_fx()
	_rts.issue_patrol(patrol_destination)
	var patrol_feedback: Dictionary = _rts.get_command_feedback_snapshot()
	await _render_frame("12_PATROL_ACK", worker, "PATROL", "PATROL", null, patrol_feedback, patrol_destination)
	_clear_fx()
	_rts._cmd_guard()
	var guard_feedback: Dictionary = _rts.get_command_feedback_snapshot()
	await _render_frame("13_GUARD_UNAVAILABLE", worker, "DEFAULT", "GUARD (G)", null, guard_feedback, worker.global_position)
	_clear_fx()
	var rejected_feedback: Dictionary = _extended_feedback.get("BUILD_REJECTED", {"accepted": false, "feedback_type": "REJECTED"})
	_rts._record_command_feedback(false, "BUILD_OR_REPAIR", "REJECTED", null, hq.global_position, String(rejected_feedback.get("reason", "invalid_placement")))
	rejected_feedback = _rts.get_command_feedback_snapshot()
	await _render_frame("14_BUILD_REJECTED_ACK", worker, "INVALID", "BUILD REJECTED", null, rejected_feedback, hq.global_position)
	if _extended_valid_build_position != Vector3.INF:
		var valid_feedback: Dictionary = _extended_feedback.get("BUILD_VALID", {"accepted": false, "feedback_type": "BUILD PLACEMENT"})
		_rts._record_command_feedback(true, "BUILD_OR_REPAIR", "BUILD PLACEMENT", null, _extended_valid_build_position)
		valid_feedback = _rts.get_command_feedback_snapshot()
		await _render_frame("15_BUILD_VALID_ACK", worker, "BUILD_VALID", "BUILD PLACEMENT", null, valid_feedback, _extended_valid_build_position)

func _find_valid_build_position() -> Vector3:
	var hq = _entities.get("hq")
	if not is_instance_valid(hq):
		return Vector3.INF
	_rts.enter_build_mode("barrosan_clan_croft")
	for radius in [24.0, 30.0, 36.0]:
		for i in range(16):
			var candidate: Vector3 = hq.global_position + Vector3(cos(TAU * i / 16.0), 0.0, sin(TAU * i / 16.0)) * radius
			if _rts._is_build_spot_valid(candidate):
				return candidate
	return Vector3.INF

func _feedback_matches_position(feedback: Dictionary, expected: Vector3) -> bool:
	var position: Dictionary = feedback.get("position", {})
	return is_equal_approx(float(position.get("x", INF)), expected.x) and is_equal_approx(float(position.get("z", INF)), expected.z)

func _wait_for_runtime() -> void:
	var deadline := Time.get_ticks_msec() + 20000
	while Time.get_ticks_msec() < deadline:
		_root = get_node_or_null("/root/GameRoot")
		if _root:
			_rts = _root.get_node_or_null("RTS")
			_world = _root.get_node_or_null("GameWorld")
		if _root and _rts and _world and _world.game_running:
			for _i in range(12): await get_tree().process_frame
			return
		await get_tree().process_frame
	_failures.append("runtime_timeout")

func _find_entities() -> Dictionary:
	var result := {}
	for commander in _world.commanders:
		if commander.team == 0:
			for unit in commander.units:
				if not is_instance_valid(unit) or unit.is_dead: continue
				if unit.is_worker and not result.has("worker"): result["worker"] = unit
				elif not unit.is_worker and not unit.is_hero and not result.has("military"): result["military"] = unit
				if unit.is_hero and not result.has("hero"): result["hero"] = unit
			for building in commander.buildings:
				if is_instance_valid(building) and not building.is_dead and bool(building.def.get("is_hq", false)):
					result["hq"] = building
		elif commander.team != 0 and not result.has("enemy"):
			for unit in commander.units:
				if is_instance_valid(unit) and not unit.is_dead:
					result["enemy"] = unit
		for resource in get_tree().get_nodes_in_group("resources"):
			if is_instance_valid(resource) and not resource.depleted and not result.has("resource"):
				result["resource"] = resource
	for key in ["worker", "military", "hq", "enemy", "resource"]:
		if not is_instance_valid(result.get(key)):
			_failures.append("missing_" + key)
	return result

func _create_review_fixture() -> void:
	var commander = _world.commanders[0] if _world.commanders.size() > 0 else null
	if commander == null: return
	var def: Dictionary = get_node("/root/GameData").get_building("barrosan_clan_croft").duplicate()
	def["id"] = "barrosan_clan_croft"
	var building_script = load("res://scripts/buildings/building.gd")
	_fixture_building = building_script.new()
	_world.add_child(_fixture_building)
	var worker = _entities.get("worker")
	_fixture_building.global_position = worker.global_position + Vector3(6.0, 0.0, 3.0) if is_instance_valid(worker) else Vector3(-70, 0, -70)
	_fixture_building.configure(def, 0, commander, _world, false)
	_fixture_metadata = {
		"review_fixture": true,
		"class": "Building",
		"definition_id": "barrosan_clan_croft",
		"definition_name": def.get("name", ""),
		"is_hq": def.get("is_hq", false),
		"footprint": def.get("footprint", 0.0),
		"model": def.get("model", ""),
		"commander_roster_membership": false,
		"position": _vec(_fixture_building.global_position)
	}

func _wait_fixture_physics() -> void:
	var old_paused := get_tree().paused
	get_tree().paused = false
	await get_tree().process_frame
	await get_tree().physics_frame
	get_tree().paused = old_paused

func _run_intent_cases() -> void:
	_case("nothing_selected_ground", "DEFAULT", null, Vector3.ZERO, false)
	_select("worker")
	_case("movable_unit_ground", "MOVE", null, _move_destination(), false)
	_select("military")
	_case("combat_unit_enemy", "ATTACK", _entities.get("enemy"), _entities.get("enemy").global_position, false)
	_select("worker")
	_case("worker_resource", "GATHER", _entities.get("resource"), _entities.get("resource").global_position, false)
	_select("worker")
	_case("worker_unfinished_building", "BUILD_OR_REPAIR", _fixture_building, _fixture_building.global_position, false)
	_select("hq")
	_case("building_ground", "RALLY", null, _rally_destination(), false)
	_rts.enter_build_mode("barrosan_clan_croft")
	_rts._build_valid = true
	_case("build_valid", "BUILD_VALID", null, _move_destination(), false)
	_rts._build_valid = false
	_case("build_invalid", "INVALID", null, _move_destination(), false)
	_rts.cancel_build_mode()
	_select("worker")
	_case("interactive_hud", "DEFAULT", null, _move_destination(), true)
	_case("dead_or_invalid_target", "INVALID", null, null, false)
	_clear_selection()

func _case(label: String, expected: String, target, ground, ui_surface: bool) -> void:
	var actual: String = String(_rts.classify_command_intent(target, ground, ui_surface))
	_rts._apply_cursor_intent(actual)
	var shape: int = int(_rts.get_command_intent_snapshot().get("cursor_shape", -1))
	var pass_case: bool = actual == expected
	_intent_cases.append({"case": label, "expected": expected, "actual": actual, "cursor_shape": shape, "pass": pass_case})
	if not pass_case: _failures.append("intent_" + label)

func _capture_command(name: String, selection_key: String, target, ground: Vector3, expected_intent: String, command_label: String, focus: Vector3) -> void:
	if selection_key == "worker" and not is_instance_valid(_entities.get("worker")): return
	var selected_entity = _entities.get(selection_key)
	if not is_instance_valid(selected_entity):
		_failures.append(name + ":missing_selection")
		return
	_clear_fx()
	_select(selection_key)
	var intent: String = String(_rts.classify_command_intent(target, ground, false))
	_rts._apply_cursor_intent(intent)
	var command_accepted := false
	if command_label == "ATTACK-MOVE":
		# Current semantics resolve attack-move immediately from its hotkey; there
		# is no persistent target-picking ATTACK_MOVE cursor state to advertise.
		command_accepted = bool(_rts.issue_attack_move_destination(ground))
	else:
		_rts._issue_context_command_from_context(false, target, ground)
	var feedback: Dictionary = _rts.get_command_feedback_snapshot()
	var accepted: bool = command_accepted if command_label == "ATTACK-MOVE" else bool(feedback.get("accepted", false))
	_ack_cases.append({"name": name, "intent": intent, "command": command_label, "accepted": accepted, "feedback": feedback})
	var expected_cursor_intent := "MOVE" if command_label == "ATTACK-MOVE" else expected_intent
	if intent != expected_cursor_intent: _failures.append(name + ":intent_mismatch")
	if not accepted: _failures.append(name + ":command_not_accepted")
	await _render_frame(name, selected_entity, intent, command_label, target, feedback, focus)

func _capture_build_context(name: String, valid: bool) -> void:
	var focus := _move_destination()
	_clear_fx()
	_select("worker")
	_rts.enter_build_mode("barrosan_clan_croft")
	if is_instance_valid(_rts._build_ghost): _rts._build_ghost.global_position = focus
	_rts._build_valid = valid
	var intent: String = String(_rts.classify_command_intent(null, focus, false))
	_rts._apply_cursor_intent(intent)
	if intent != ("BUILD_VALID" if valid else "INVALID"): _failures.append(name + ":intent_mismatch")
	await _render_frame(name, _entities.get("worker"), intent, "BUILD_CONTEXT", null, {"accepted": false}, focus)
	_rts.cancel_build_mode()

func _capture_ui_hover(name: String) -> void:
	_clear_fx()
	_select("worker")
	var focus := _move_destination()
	var intent: String = String(_rts.classify_command_intent(null, focus, true))
	_rts._apply_cursor_intent(intent)
	if intent != "DEFAULT": _failures.append(name + ":intent_not_default")
	await _render_frame(name, _entities.get("worker"), intent, "UI_HOVER_CONTEXT", null, {"accepted": false}, focus)

func _render_frame(name: String, focus_entity, intent: String, command_label: String, target, feedback: Dictionary, focus: Vector3) -> void:
	_rts.edge_scroll = false
	_rts._cam_yaw = 0.0
	_rts._zoom = 48.0
	_rts.cam_arm.spring_length = 48.0
	_rts.focus_on(focus)
	get_tree().paused = false
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_tree().paused = true
	_rts._apply_cursor_intent(intent)
	var image := get_viewport().get_texture().get_image()
	var png_path := _output.path_join(name + ".png")
	image.save_png(png_path)
	_frames.append({
		"name": name,
		"png": png_path,
		"source_sha": OS.get_environment("ASCENDANT_P1S4_SOURCE_SHA"),
		"width": image.get_width(),
		"height": image.get_height(),
		"map": "hollowspan",
		"match": "Barrosan vs Lioraen Easy",
		"selected_entity": _entity_label(focus_entity),
		"hovered_target": _entity_label(target),
		"cursor_intent": intent,
		"cursor_shape": _rts.get_command_intent_snapshot().get("cursor_shape", -1),
		"command_invoked": command_label,
		"command_accepted": bool(feedback.get("accepted", false)),
		"feedback_type": feedback.get("feedback_type", ""),
		"feedback_position": feedback.get("position", null),
		"feedback_target_id": feedback.get("target_id", ""),
		"review_fixture": target == _fixture_building,
		"fixture_metadata": _fixture_metadata if target == _fixture_building else {},
		"nonblank_bytes": image.get_data_size(),
		"timestamp_unix_ms": Time.get_unix_time_from_system() * 1000.0
	})

func _select(key: String) -> void:
	_clear_selection()
	var entity = _entities.get(key)
	if is_instance_valid(entity): _rts._add_to_selection(entity)

func _clear_selection() -> void:
	if is_instance_valid(_rts): _rts._clear_selection()

func _clear_fx() -> void:
	if not is_instance_valid(_world) or not is_instance_valid(_world._fx_container): return
	for child in _world._fx_container.get_children(): child.queue_free()

func _remove_fixture() -> void:
	if is_instance_valid(_fixture_building): _fixture_building.queue_free()

func _move_destination() -> Vector3:
	var worker = _entities.get("worker")
	return worker.global_position + Vector3(7.0, 0.0, 2.0) if is_instance_valid(worker) else Vector3.ZERO

func _rally_destination() -> Vector3:
	var hq = _entities.get("hq")
	return hq.global_position + Vector3(6.0, 0.0, 4.0) if is_instance_valid(hq) else Vector3.ZERO

func _attack_move_destination() -> Vector3:
	var military = _entities.get("military")
	return military.global_position + Vector3(8.0, 0.0, -3.0) if is_instance_valid(military) else Vector3.ZERO

func _entity_label(entity) -> String:
	if not is_instance_valid(entity): return "ground_or_none"
	if entity.get("unit_id") != null: return "unit:" + str(entity.get("unit_id"))
	if entity.get("building_id") != null: return "building:" + str(entity.get("building_id"))
	if entity.get("resource_kind") != null: return "resource:" + str(entity.get_instance_id())
	return str(entity.get_instance_id())

func _vec(v: Vector3) -> Dictionary:
	return {"x": snappedf(v.x, 0.001), "y": snappedf(v.y, 0.001), "z": snappedf(v.z, 0.001)}

func _write_manifest() -> void:
	var manifest := {
		"tool": "p1s4CommandFeedback",
		"schema": "ascendant-realms-p1s4-command-feedback-v1",
		"source_sha": OS.get_environment("ASCENDANT_P1S4_SOURCE_SHA"),
		"capture_mode": "non-headless Godot runtime",
		"map": "hollowspan",
		"match": "Barrosan vs Lioraen Easy",
		"resolution": {"width": _width, "height": _height},
		"review_fixture": true,
		"review_fixture_metadata": _fixture_metadata,
		"frames": _frames,
		"intent_cases": _intent_cases,
		"acknowledgement_cases": _ack_cases,
		"native_cursor_visible_in_capture": false,
		"native_cursor_note": "Structured Godot cursor-shape proof is recorded; OS cursor pixels are not required by P1-S4.",
		"failures": _failures,
		"pass": _failures.is_empty()
	}
	var file := FileAccess.open(_output.path_join("command-feedback-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(manifest, "  "))
		file.store_line("")
	else:
		_failures.append("manifest_open_failed")
