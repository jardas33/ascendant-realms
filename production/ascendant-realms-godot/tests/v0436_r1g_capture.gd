extends Node
## v0.436-R1G natural-conquest predicate/result/replay evidence.
## This runner is opt-in capture tooling. It observes the production scene and
## uses public RTS, build, queue, and Button input paths only.

const OUT := "res://../../artifacts/manual-review/v0436-r1g-natural-conquest-predicate-truth/"
const ASSAULT_TIMEOUT_SECONDS := 120.0

var root_node: Node
var world
var rts
var session := "A"
var out_path := OUT
var started := false
var replay_captured := false
var frame_names: Array[String] = []
var command_log: Array = []
var target_lifecycles: Array = []
var predicate_sequence: Array = []
var last_valid_frame := ""

func _ready() -> void:
	session = OS.get_environment("ASCENDANT_V0436_R1G_SESSION")
	if session != "A" and session != "B":
		session = "A"
	out_path = OUT + "session-%s/" % session.to_lower()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path))
	var start_resources := OS.get_environment("ASCENDANT_E1_START_RESOURCES")
	if start_resources.is_empty(): start_resources = "standard"
	Match.set_config({"player_race":"barrosan", "opponents":[{"race":"lioraen", "difficulty":"easy"}], "map":"hollowspan", "start_resources":start_resources, "victory":"conquest", "mode":"skirmish", "game_speed":2.0})

func _vec(v: Vector3) -> Dictionary:
	return {"x":v.x, "y":v.y, "z":v.z}

func _provenance(label: String) -> Dictionary:
	return {"schema":"v0436-r1g-live-evidence-v1", "session":session, "attempt":label, "source_sha":OS.get_environment("ASCENDANT_V0436_R1G_SOURCE_SHA"), "branch":OS.get_environment("ASCENDANT_V0436_R1G_BRANCH"), "production_scene":"scenes/main.tscn -> scenes/game_world.tscn", "timestamp_ms":Time.get_ticks_msec()}

func _wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _wait_until(check: Callable, timeout: float) -> bool:
	var deadline := Time.get_ticks_msec() + int(timeout * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if check.call():
			return true
		await get_tree().process_frame
	return bool(check.call())

func _save(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(out_path + name))
	frame_names.append(name)
	last_valid_frame = name

func _save_json(name: String, value) -> void:
	var file := FileAccess.open(ProjectSettings.globalize_path(out_path + name), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
		file.store_line("")

func _focus(position: Vector3, zoom := 34.0) -> void:
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts._zoom = zoom
	rts.cam_arm.spring_length = zoom
	rts.focus_on(position)
	for _i in range(4):
		await get_tree().process_frame

func _live_unit(unit) -> bool:
	return is_instance_valid(unit) and not bool(unit.is_dead)

func _live_building(building) -> bool:
	return is_instance_valid(building) and not bool(building.is_dead)

func _unit_record(unit) -> Dictionary:
	return {"definition_id":String(unit.unit_id), "runtime_id":str(unit.get_instance_id()), "team":int(unit.team), "hp":float(unit.hp), "max_hp":float(unit.max_hp) if "max_hp" in unit else null, "dead":bool(unit.is_dead), "position":_vec(unit.global_position), "state":int(unit.state), "navigation_command":String(unit.get("_navigation_command_type"))}

func _building_record(building) -> Dictionary:
	return {"definition_id":String(building.building_id), "runtime_id":str(building.get_instance_id()), "team":int(building.team), "hp":float(building.hp), "max_hp":float(building.max_hp) if "max_hp" in building else null, "dead":bool(building.is_dead), "built":bool(building.is_built), "position":_vec(building.global_position), "is_hq":bool(building.def.get("is_hq", false)), "state":str(building.get("state"))}

func _commander_record(cmd) -> Dictionary:
	var units: Array = []
	for unit in cmd.units:
		if is_instance_valid(unit):
			units.append(_unit_record(unit))
	var buildings: Array = []
	for building in cmd.buildings:
		if is_instance_valid(building):
			buildings.append(_building_record(building))
	var live_workers := units.filter(func(v): return not bool(v.get("dead", true)) and String(v.get("definition_id", "")).contains("worker"))
	var live_buildings := buildings.filter(func(v): return not bool(v.get("dead", true)))
	var live_hq := live_buildings.filter(func(v): return bool(v.get("is_hq", false)))
	return {"team":int(cmd.team), "race":String(cmd.race), "defeated":bool(cmd.defeated), "defeat_reason":String(cmd.defeat_reason), "units":units, "buildings":buildings, "live_workers":live_workers, "live_buildings":live_buildings, "live_hq":live_hq, "has_hq":cmd.has_hq(), "alive_buildings":cmd.alive_buildings(), "no_hq":live_hq.is_empty(), "no_buildings":live_buildings.is_empty(), "no_workers":live_workers.is_empty(), "resources":cmd.resources.duplicate(true)}

func _predicate_snapshot(label: String) -> Dictionary:
	var commanders: Array = []
	for cmd in world.commanders:
		commanders.append(_commander_record(cmd))
	var sole_survivors: Array = []
	for cmd in world.commanders:
		if not cmd.defeated:
			sole_survivors.append(int(cmd.team))
	var snapshot := {"label":label, "timestamp_ms":Time.get_ticks_msec(), "physics_frame":Engine.get_physics_frames(), "process_frame":Engine.get_process_frames(), "commanders":commanders, "game_running":bool(world.game_running), "match_ended":bool(world.match_ended), "game_over_count":int(world.game_over_count), "profile_record_count":int(world.profile_record_count), "result":world.result_snapshot.duplicate(true), "match_result":Match.last_result.duplicate(true), "sole_non_defeated_commanders":sole_survivors, "victory_check_observation":"read-only state snapshot; no capture-only victory counter was added"}
	predicate_sequence.append(snapshot)
	return snapshot

func _player_combatants() -> Array:
	return world.commanders[0].units.filter(func(u): return _live_unit(u) and not bool(u.is_worker))

func _enemy_combatants() -> Array:
	return world.commanders[1].units.filter(func(u): return _live_unit(u) and not bool(u.is_worker))

func _enemy_workers() -> Array:
	return world.commanders[1].units.filter(func(u): return _live_unit(u) and bool(u.is_worker))

func _enemy_buildings() -> Array:
	return world.commanders[1].buildings.filter(func(b): return _live_building(b))

func _select_many(nodes: Array) -> void:
	rts._clear_selection()
	for node in nodes:
		if is_instance_valid(node) and not bool(node.is_dead):
			rts._add_to_selection(node)
	rts.emit_signal("selection_changed", rts.selected)
	await get_tree().process_frame

func _find_build_position() -> Vector3:
	var anchor: Vector3 = world.player_commander.buildings[0].global_position
	for radius in [24.0, 30.0, 36.0]:
		for i in range(12):
			var p: Vector3 = anchor + Vector3(cos(TAU * i / 12.0), 0, sin(TAU * i / 12.0)) * radius
			if world.can_place_building("barrosan_war_hall", 0, p, true):
				return p
	return Vector3.INF

func _normal_production_setup() -> bool:
	var hall = world.place_building("barrosan_war_hall", 0, _find_build_position())
	if not is_instance_valid(hall):
		return false
	for worker in world.commanders[0].units:
		if is_instance_valid(worker) and bool(worker.is_worker):
			worker.command_build(hall)
	if not await _wait_until(func(): return is_instance_valid(hall) and bool(hall.is_built), 75.0):
		return false
	var queue_results: Array = []
	for _i in range(4):
		queue_results.append(hall.queue_unit("barrosan_crag_archer"))
		await get_tree().process_frame
	_save_json("production-audit.json", {"provenance":_provenance("production"), "queue_results":queue_results, "resource_transactions":world.resource_transactions.duplicate(true), "source":"normal placement, worker construction, and real-cost Building.queue_unit"})
	return await _wait_until(func(): return world.commanders[0].units.filter(func(u): return _live_unit(u) and String(u.unit_id) == "barrosan_crag_archer").size() >= 4, 90.0)

func _target_key(target, category: String) -> Dictionary:
	return {"category":category, "definition_id":String(target.get("building_id") if category == "building" else target.get("unit_id")), "runtime_id":str(target.get_instance_id())}

func _assault(target, category: String, label: String) -> Dictionary:
	var audit := _target_key(target, category)
	audit["initial_hp"] = float(target.hp) if is_instance_valid(target) and "hp" in target else null
	audit["maximum_hp"] = float(target.max_hp) if is_instance_valid(target) and "max_hp" in target else null
	audit["initial_position"] = _vec(target.global_position) if is_instance_valid(target) else null
	audit["player_assault_force"] = _player_combatants().map(func(u): return _unit_record(u))
	audit["commands"] = []
	audit["hp_samples"] = []
	audit["position_samples"] = []
	audit["damage_event_count_before"] = world.combat_damage_events.size() + world.building_damage_events.size()
	audit["reissues"] = []
	var army := _player_combatants()
	if army.is_empty():
		audit["terminal_disposition"] = "BLOCKED_R1G_PLAYER_ASSAULT_FORCE_ELIMINATED"
		target_lifecycles.append(audit)
		return audit
	await _select_many(army)
	var issued_move: bool = rts.issue_attack_move_destination(target.global_position)
	var issued_target: bool = rts.issue_attack_target(target)
	audit.commands.append({"timestamp_ms":Time.get_ticks_msec(), "kind":"initial", "attack_move_return":issued_move, "attack_target_return":issued_target, "target_position":_vec(target.global_position)})
	var started_ms := Time.get_ticks_msec()
	var next_reissue_ms := started_ms + 8000
	while Time.get_ticks_msec() - started_ms < int(ASSAULT_TIMEOUT_SECONDS * 1000.0):
		if not is_instance_valid(target) or bool(target.is_dead):
			audit["terminal_disposition"] = "DESTROYED"
			audit["destruction_timestamp_ms"] = Time.get_ticks_msec()
			break
		if _player_combatants().is_empty():
			audit["terminal_disposition"] = "BLOCKED_R1G_PLAYER_ASSAULT_FORCE_ELIMINATED"
			break
		var hp := float(target.hp)
		audit.hp_samples.append({"timestamp_ms":Time.get_ticks_msec(), "hp":hp, "dead":bool(target.is_dead)})
		audit.position_samples.append({"timestamp_ms":Time.get_ticks_msec(), "position":_vec(target.global_position), "state":int(target.state) if "state" in target else null})
		if Time.get_ticks_msec() >= next_reissue_ms:
			var idle_count := _player_combatants().filter(func(u): return int(u.state) == Unit.State.IDLE or String(u.get("_navigation_command_type")) == "").size()
			if idle_count > 0:
				await _select_many(_player_combatants())
				var retry_move: bool = rts.issue_attack_move_destination(target.global_position)
				var retry_target: bool = rts.issue_attack_target(target)
				audit.reissues.append({"timestamp_ms":Time.get_ticks_msec(), "idle_count":idle_count, "attack_move_return":retry_move, "attack_target_return":retry_target})
			next_reissue_ms += 8000
		await _wait_seconds(0.5)
	if not audit.has("terminal_disposition"):
		var damage_count: int = world.combat_damage_events.size() + world.building_damage_events.size()
		if _player_combatants().is_empty():
			audit["terminal_disposition"] = "BLOCKED_R1G_PLAYER_ASSAULT_FORCE_ELIMINATED"
		elif damage_count == int(audit.get("damage_event_count_before", 0)):
			audit["terminal_disposition"] = "BLOCKED_R1G_TARGET_NOT_TAKING_DAMAGE"
		else:
			audit["terminal_disposition"] = "BLOCKED_R1G_CAPTURE_TIME_BUDGET_EXHAUSTED_%s" % category.to_upper()
	audit["final_valid"] = is_instance_valid(target)
	audit["final_hp"] = float(target.hp) if is_instance_valid(target) and "hp" in target else null
	audit["final_position"] = _vec(target.global_position) if is_instance_valid(target) else null
	audit["damage_event_count_after"] = world.combat_damage_events.size() + world.building_damage_events.size()
	audit["elapsed_wall_seconds"] = float(Time.get_ticks_msec() - started_ms) / 1000.0
	audit["navigation_snapshot"] = world.navigation_runtime_snapshot()
	target_lifecycles.append(audit)
	return audit

func _click_button(button: Button) -> Dictionary:
	var rect := button.get_global_rect()
	var record := {"path":String(button.get_path()), "text":String(button.text), "visible":button.visible, "enabled":not button.disabled, "rect":{"x":rect.position.x,"y":rect.position.y,"w":rect.size.x,"h":rect.size.y}, "input_route":"InputEventMouseButton at actual Button global rect center"}
	var press := InputEventMouseButton.new()
	press.position = rect.get_center()
	press.global_position = rect.get_center()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := InputEventMouseButton.new()
	release.position = rect.get_center()
	release.global_position = rect.get_center()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	Input.parse_input_event(release)
	return record

func _find_button(node: Node, text: String) -> Button:
	if node is Button and String(node.text) == text:
		return node
	for child in node.get_children():
		var found := _find_button(child, text)
		if is_instance_valid(found):
			return found
	return null

func _labels(node: Node) -> Array:
	var values: Array = []
	if node is Label:
		values.append(String(node.text))
	for child in node.get_children():
		values.append_array(_labels(child))
	return values

func _contact_sheet() -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.03,0.04,0.05))
	var thumb := Vector2i(384,216)
	for i in range(min(frame_names.size(), 25)):
		var source := Image.load_from_file(ProjectSettings.globalize_path(out_path + frame_names[i]))
		if source.is_empty():
			continue
		source.convert(Image.FORMAT_RGBA8)
		source.resize(thumb.x, thumb.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(source, Rect2i(0,0,thumb.x,thumb.y), Vector2i((i % 5) * thumb.x, (i / 5) * thumb.y))
	sheet.save_png(ProjectSettings.globalize_path(out_path + "21_R1G_%sCONTACT_SHEET.png" % ("BLOCKER_" if not world.match_ended else "")))

func _fail(status: String, reason: String) -> void:
	var final_state := _predicate_snapshot("blocker")
	var blocker := {"schema":"v0436-r1g-blocker-v1", "status":status, "reason":reason, "provenance":_provenance("blocker"), "complete_current_predicate":final_state, "surviving_entity_inventory":final_state.get("commanders", []), "player_force_inventory":_player_combatants().map(func(u): return _unit_record(u)), "last_commands":command_log, "target_lifecycles":target_lifecycles, "last_valid_frame":last_valid_frame, "why_later_phases_were_not_run":"Natural terminal fact was not proven; success-only result/replay phases were not executed."}
	_save_json("r1g-blocker.json", blocker)
	_save_json("r1g-final-state.json", {"provenance":_provenance("final"), "status":status, "predicate":final_state, "predicate_sequence":predicate_sequence, "target_lifecycles":target_lifecycles, "commands":command_log, "frames":frame_names})
	await _contact_sheet()
	push_error(status + ": " + reason)
	get_tree().quit(0)

func _capture_match() -> void:
	if not await _wait_until(func(): return is_instance_valid(world) and bool(world.game_running), 30.0):
		await _fail("BLOCKED_R1G_CAPTURE_TIME_BUDGET_EXHAUSTED_STARTUP", "production match did not start")
		return
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("01_R1G_MATCH_CONFIGURATION.png")
	_save_json("match-configuration.json", {"provenance":_provenance("configuration"), "observed":Match.get_config().duplicate(true), "expected":{"player_race":"barrosan","opponent_race":"lioraen","difficulty":"easy","opponent_count":1,"start_resources":"standard","map":"hollowspan","mode":"skirmish","victory":"conquest","game_speed":2.0}})
	await _save("02_R1G_INITIAL_PRODUCTION_MATCH.png")
	if not await _wait_until(func(): return world.is_navigation_ready(), 30.0):
		await _fail("BLOCKED_R1G_TARGET_UNREACHABLE", "navigation did not become ready")
		return
	await _save("03_R1G_NAVIGATION_READY.png")
	if not await _normal_production_setup():
		await _fail("BLOCKED_R1G_PLAYER_PRODUCTION_CANNOT_RECOVER", "normal player construction or production did not complete")
		return
	await _save("04_R1G_PLAYER_PRODUCTION_READY.png")
	var combatants := _enemy_combatants()
	if combatants.is_empty():
		await _fail("BLOCKED_R1G_TARGET_UNREACHABLE", "no live enemy combatant target was present")
		return
	await _focus(combatants[0].global_position, 30.0)
	await _save("05_R1G_ASSAULT_COMMAND.png")
	var first := await _assault(combatants[0], "combatant", "opening_enemy_contact")
	_save_json("target-lifecycle-opening.json", first)
	await _save("06_R1G_REAL_COMBAT_CONTACT.png")
	if String(first.get("terminal_disposition", "")) != "DESTROYED":
		await _save("07_R1G_REAL_DAMAGE.png")
		await _fail(String(first.get("terminal_disposition", "BLOCKED_R1G_TARGET_NOT_TAKING_DAMAGE")), "opening combatant assault did not reach a truthful destroyed terminal state")
		return
	await _save("07_R1G_REAL_DAMAGE.png")
	var hqs := _enemy_buildings().filter(func(b): return bool(b.def.get("is_hq", false)))
	if hqs.is_empty():
		await _fail("BLOCKED_R1G_ENEMY_HQ_SURVIVED", "enemy HQ inventory was absent before the HQ assault")
		return
	await _focus(hqs[0].global_position, 30.0)
	var hq_result := await _assault(hqs[0], "building", "enemy_hq")
	_save_json("target-lifecycle-hq.json", hq_result)
	await _save("08_R1G_ENEMY_HQ_ACTUAL_STATE.png")
	if String(hq_result.get("terminal_disposition", "")) != "DESTROYED":
		await _fail(String(hq_result.get("terminal_disposition", "BLOCKED_R1G_ENEMY_HQ_SURVIVED")), "enemy HQ assault did not reach a truthful destroyed terminal state")
		return
	var remaining := _enemy_buildings()
	await _save("09_R1G_REMAINING_BUILDING_INVENTORY.png")
	for building in remaining:
		var building_result := await _assault(building, "building", "remaining_building")
		_save_json("target-lifecycle-building-%s.json" % String(building.building_id), building_result)
		if String(building_result.get("terminal_disposition", "")) != "DESTROYED":
			await _fail(String(building_result.get("terminal_disposition", "BLOCKED_R1G_ENEMY_BUILDING_SURVIVED")), "a live enemy building remained after a bounded normal assault")
			return
	var workers := _enemy_workers()
	await _save("10_R1G_REBUILD_CAPABILITY_INVENTORY.png")
	for worker in workers:
		var worker_result := await _assault(worker, "worker", "rebuild_worker")
		_save_json("target-lifecycle-worker-%s.json" % String(worker.unit_id), worker_result)
		if String(worker_result.get("terminal_disposition", "")) != "DESTROYED":
			await _fail(String(worker_result.get("terminal_disposition", "BLOCKED_R1G_ENEMY_REBUILD_WORKER_SURVIVED")), "a rebuild-capable enemy worker remained live")
			return
	var final_predicate := _predicate_snapshot("final_conquest_predicate")
	await _save("11_R1G_FINAL_CONQUEST_PREDICATE.png")
	var enemy_state: Dictionary = final_predicate.get("commanders", [])[1]
	if not bool(enemy_state.get("no_hq", false)) or not bool(enemy_state.get("no_buildings", false)) or not bool(enemy_state.get("no_workers", false)):
		await _fail("BLOCKED_R1G_OTHER_REBUILD_CAPABILITY_SURVIVED", "final production commander predicate remained false")
		return
	if not await _wait_until(func(): return bool(world.match_ended), 120.0):
		await _fail("BLOCKED_R1G_CAPTURE_TIME_BUDGET_EXHAUSTED_MATCH_END", "predicate was true but a natural match end was not observed")
		return
	if not bool(world.result_snapshot.get("victory", false)) or String(world.result_snapshot.get("reason", "")) != "Conquest":
		await _fail("BLOCKED_R1G_RESULT_REASON_INCORRECT", "natural match end did not produce a Conquest victory")
		return
	await _save("12_R1G_GENUINE_VICTORY.png")
	var layer = root_node.hud.get("_gameover_layer")
	var continue_button := _find_button(layer, "Continue") if is_instance_valid(layer) else null
	var replay_button := _find_button(layer, "Play Again") if is_instance_valid(layer) else null
	var labels := _labels(layer) if is_instance_valid(layer) else []
	_save_json("result-state-audit.json", {"provenance":_provenance("result"), "observed":{"match_ended":world.match_ended,"game_running":world.game_running,"result":world.result_snapshot.duplicate(true),"labels":labels,"victory_visible":labels.has("VICTORY"),"reason_visible":labels.any(func(v): return String(v).contains("Conquest")),"continue_exists":is_instance_valid(continue_button),"replay_exists":is_instance_valid(replay_button)}})
	await _save("13_R1G_RESULT_UI_AND_CONQUEST_REASON.png")
	var freeze_before := _predicate_snapshot("freeze_before")
	await _wait_seconds(3.0)
	var freeze_after := _predicate_snapshot("freeze_after")
	_save_json("freeze-audit.json", {"provenance":_provenance("freeze"), "before":freeze_before, "after":freeze_after, "combat_damage_count":world.combat_damage_events.size(), "resource_transaction_count":world.resource_transactions.size()})
	await _save("14_R1G_FROZEN_MATCH_STATE.png")
	if not is_instance_valid(continue_button) or continue_button.disabled:
		await _fail("BLOCKED_R1G_CONTINUE_ACTION_FAILED", "visible enabled Continue button was not found")
		return
	if not is_instance_valid(replay_button) or replay_button.disabled:
		await _fail("BLOCKED_R1G_PLAY_AGAIN_ACTION_FAILED", "visible enabled Play Again button was not found")
		return
	if session == "A":
		await _save("15_R1G_CONTINUE_BUTTON_BEFORE_INPUT.png")
		var continue_audit := await _click_button(continue_button)
		await _wait_seconds(3.0)
		continue_audit["destination_scene"] = get_tree().current_scene.scene_file_path if is_instance_valid(get_tree().current_scene) else ""
		_save_json("continue-action-audit.json", {"provenance":_provenance("continue"), "observed":continue_audit})
		await _save("16_R1G_CONTINUE_DESTINATION.png")
		await _contact_sheet()
		get_tree().quit(0)
		return
	await _save("15_R1G_SESSION_B_GENUINE_VICTORY.png")
	await _save("18_R1G_PLAY_AGAIN_BUTTON_BEFORE_INPUT.png")
	var replay_audit := await _click_button(replay_button)
	_save_json("play-again-action-audit.json", {"provenance":_provenance("play_again"), "observed":replay_audit})
	await _wait_until(func(): return replay_captured, 45.0)
	if not replay_captured:
		await _fail("BLOCKED_R1G_REPLAY_NOT_FRESH", "Play Again input did not produce a fresh captured scene")
		return

func _capture_fresh_replay(new_root: Node) -> void:
	root_node = new_root
	world = root_node.get_node_or_null("GameWorld")
	rts = root_node.get_node_or_null("RTS")
	if not is_instance_valid(world) or not is_instance_valid(rts):
		await _fail("BLOCKED_R1G_REPLAY_NOT_FRESH", "fresh scene lacked GameWorld or RTS")
		return
	await _wait_until(func(): return bool(world.game_running), 30.0)
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("19_R1G_FRESH_REPLAY_SCENE.png")
	await _save("20_R1G_FRESH_REPLAY_CONFIGURATION.png")
	_save_json("fresh-replay-audit.json", {"provenance":_provenance("fresh_replay"), "observed":{"new_root_runtime_id":str(new_root.get_instance_id()),"new_world_runtime_id":str(world.get_instance_id()),"match_ended":world.match_ended,"game_running":world.game_running,"result":Match.last_result.duplicate(true),"resources":world.commanders[0].resources.duplicate(true),"units":world.all_units().map(func(u): return _unit_record(u))}, "source":"fresh production scene after actual Play Again Button input"})
	replay_captured = true
	await _contact_sheet()
	get_tree().quit(0)

func _capture_entry(p_root: Node) -> void:
	if not started:
		started = true
		root_node = p_root
		world = root_node.get_node("GameWorld")
		rts = root_node.get_node("RTS")
		await _capture_match()
	elif session == "B" and not replay_captured:
		await _capture_fresh_replay(p_root)

func capture_gameplay(p_root: Node) -> void:
	_capture_entry(p_root)
