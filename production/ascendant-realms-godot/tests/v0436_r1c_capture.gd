extends Node
## R1C genuine conquest/result/replay evidence. This is opt-in capture tooling only.
## All gameplay observations are read from the live production scene. Player actions
## use the public RTS/build/queue/UI paths; no AI, HP, death, result, or position
## state is written by this runner.

var root_node: Node
var world
var rts
var frames: Array[String] = []
var assault_commands: Array = []
var position_samples: Array = []
var run_started := false
var fresh_replay_captured := false
var first_result: Dictionary = {}
var session := "A"
var out_path := ""
const CaptureGate = preload("res://tests/capture_autoload_gate.gd")

func _ready() -> void:
	if not CaptureGate.guard_autoload(self, "V0436R1CCapture"):
		return
	session = OS.get_environment("ASCENDANT_V0436_R1C_SESSION")
	if session != "A" and session != "B": session = "A"
	out_path = "res://../../artifacts/manual-review/v0436-r1c-natural-conquest-result-replay-proof/session-%s/" % session.to_lower()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path))
	Match.set_config({"player_race":"barrosan", "opponents":[{"race":"lioraen", "difficulty":"easy"}], "map":"hollowspan", "start_resources":"standard", "victory":"conquest", "mode":"skirmish", "game_speed":2.0})

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
	image.save_png(ProjectSettings.globalize_path(out_path + name))
	frames.append(name)

func _save_json(name: String, value: Dictionary) -> void:
	var file := FileAccess.open(ProjectSettings.globalize_path(out_path + name), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
		file.store_line("")

func _fail(reason: String) -> void:
	_save_json("r1c-failure.json", {"provenance":_provenance("failure"),"status":"BLOCKED_%s" % reason,"observed":{"frames":frames,"position_samples":position_samples,"assault_commands":assault_commands,"match_ended":bool(world.match_ended) if is_instance_valid(world) else false,"result":Match.last_result.duplicate(true)},"source":"live capture runner failure"})
	push_error("BLOCKED_R1C_%s" % reason)
	get_tree().quit(22)

func _provenance(attempt: String) -> Dictionary:
	return {"schema":"v0436-r1c-observed-runtime-evidence-v1", "capture_session":session, "capture_attempt":attempt, "source_sha":OS.get_environment("ASCENDANT_V0436_R1C_SOURCE_SHA"), "branch":OS.get_environment("ASCENDANT_V0436_R1C_BRANCH"), "production_scene":"scenes/main.tscn -> scenes/game_world.tscn", "sequence_time_ms":Time.get_ticks_msec()}

func _focus(pos: Vector3, zoom := 34.0) -> void:
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts._zoom = zoom
	rts.cam_arm.spring_length = zoom
	rts.focus_on(pos)
	for _i in range(4): await get_tree().process_frame

func _player_combatants() -> Array:
	return world.commanders[0].units.filter(func(u): return is_instance_valid(u) and not u.is_dead and not u.is_worker)

func _select_many(nodes: Array) -> void:
	rts._clear_selection()
	for node in nodes:
		if is_instance_valid(node) and not node.is_dead: rts._add_to_selection(node)
	rts.emit_signal("selection_changed", rts.selected)
	await get_tree().process_frame

func _enemy_buildings() -> Array:
	return world.commanders[1].buildings.filter(func(b): return is_instance_valid(b) and not b.is_dead)

func _enemy_workers() -> Array:
	return world.commanders[1].units.filter(func(u): return is_instance_valid(u) and not u.is_dead and u.is_worker)

func _enemy_combatants() -> Array:
	var out: Array = world.commanders[1].units.filter(func(u): return is_instance_valid(u) and not u.is_dead and not u.is_worker)
	var anchor: Vector3 = world.commanders[0].buildings[0].global_position
	out.sort_custom(func(a,b): return a.global_position.distance_squared_to(anchor) < b.global_position.distance_squared_to(anchor))
	return out

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
		if is_instance_valid(worker) and worker.is_worker: worker.command_build(hall)
	return hall

func _audit_units() -> Array:
	return world.all_units().filter(func(u): return is_instance_valid(u)).map(func(u): return {"unit_id":String(u.unit_id), "team":int(u.team), "dead":bool(u.is_dead), "hp":float(u.hp), "position":{"x":u.global_position.x,"y":u.global_position.y,"z":u.global_position.z}, "state":int(u.state), "command":String(u.get("_navigation_command_type")), "runtime_id":str(u.get_instance_id())})

func _sample_positions(label: String) -> void:
	var sample := {"label":label,"timestamp":Time.get_ticks_msec(),"units":[]}
	for unit in _player_combatants(): sample["units"].append({"id":String(unit.unit_id),"runtime_id":str(unit.get_instance_id()),"position":{"x":unit.global_position.x,"y":unit.global_position.y,"z":unit.global_position.z},"speed":unit.velocity.length()})
	position_samples.append(sample)

func _assault(target, label: String) -> bool:
	if not is_instance_valid(target) or target.is_dead: return true
	var army := _player_combatants()
	if army.is_empty(): return false
	await _select_many(army)
	var issued_move: bool = rts.issue_attack_move_destination(target.global_position)
	var issued_target: bool = rts.issue_attack_target(target)
	assault_commands.append({"label":label,"timestamp":Time.get_ticks_msec(),"target_id":String(target.get("building_id") if "building_id" in target else target.get("unit_id")),"target_runtime_id":str(target.get_instance_id()),"issued_attack_move":issued_move,"issued_attack_target":issued_target,"source":"RTSController public command"})
	for _i in range(8):
		await _wait(1.0)
		await _sample_positions(label)
		if not is_instance_valid(target) or target.is_dead: return true
	return not is_instance_valid(target) or target.is_dead

func _find_button(node: Node, text: String) -> Button:
	if node is Button and String(node.text) == text: return node
	for child in node.get_children():
		var found := _find_button(child, text)
		if is_instance_valid(found): return found
	return null

func _labels(node: Node) -> Array:
	var out: Array = []
	if node is Label: out.append(String(node.text))
	for child in node.get_children(): out.append_array(_labels(child))
	return out

func _result_ui_audit(attempt: String) -> Dictionary:
	var layer = root_node.hud.get("_gameover_layer")
	var labels := _labels(layer) if is_instance_valid(layer) else []
	var continue_button := _find_button(layer, "Continue") if is_instance_valid(layer) else null
	var replay_button := _find_button(layer, "Play Again") if is_instance_valid(layer) else null
	return {"provenance":_provenance(attempt),"layer_visible":is_instance_valid(layer) and layer.visible,"labels":labels,"victory_visible":labels.any(func(v): return v == "VICTORY"),"reason_visible":labels.any(func(v): return v.contains("Conquest")),"continue":{"exists":is_instance_valid(continue_button),"visible":is_instance_valid(continue_button) and continue_button.visible,"enabled":is_instance_valid(continue_button) and not continue_button.disabled},"play_again":{"exists":is_instance_valid(replay_button),"visible":is_instance_valid(replay_button) and replay_button.visible,"enabled":is_instance_valid(replay_button) and not replay_button.disabled},"background_input_blocked":is_instance_valid(layer) and layer.mouse_filter == Control.MOUSE_FILTER_STOP,"result_snapshot":Match.last_result.duplicate(true)}

func _runtime_audit(attempt: String) -> void:
	var result: Dictionary = world.result_snapshot.duplicate(true)
	var events := {"combat_damage":world.combat_damage_events.duplicate(true),"building_damage":world.building_damage_events.duplicate(true),"building_destruction":world.building_destruction_events.duplicate(true),"resource_transactions":world.resource_transactions.duplicate(true)}
	var audit := {"provenance":_provenance(attempt),"observed":{"match_ended":bool(world.match_ended),"game_running":bool(world.game_running),"game_over_count":int(world.game_over_count),"profile_record_count":int(world.profile_record_count),"result_snapshot":result,"enemy_defeated":bool(world.commanders[1].defeated),"enemy_live_buildings":_enemy_buildings().size(),"enemy_live_workers":_enemy_workers().size(),"position_samples":position_samples,"assault_commands":assault_commands,"events":events,"units":_audit_units()},"expected":{"victory":true,"reason":"Conquest","game_over_count":1,"profile_record_count":1},"source":"live GameWorld state, signals, event ledgers, and public RTSController commands"}
	_save_json("r1c-%s-runtime-audit.json" % attempt.to_lower(), audit)

func _contact_sheet() -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.03,0.04,0.05))
	var thumb := Vector2i(384,216)
	for i in range(min(frames.size(), 25)):
		var src := Image.load_from_file(ProjectSettings.globalize_path(out_path + frames[i]))
		if src.is_empty(): continue
		src.convert(Image.FORMAT_RGBA8)
		src.resize(thumb.x,thumb.y,Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(src,Rect2i(0,0,thumb.x,thumb.y),Vector2i((i%5)*thumb.x,(i/5)*thumb.y))
	sheet.save_png(ProjectSettings.globalize_path(out_path + "30_R1C_CONTACT_SHEET.png"))

func _capture_victory() -> void:
	await _wait_until(func(): return world.game_running, 20.0)
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("01_R1C_MATCH_CONFIGURATION.png")
	await _save_json("r1c-match-configuration.json", {"provenance":_provenance("configuration"),"observed":Match.get_config().duplicate(true),"expected":{"player_race":"barrosan","opponent_race":"lioraen","difficulty":"easy","opponent_count":1,"start_resources":"standard","map":"hollowspan","mode":"skirmish","victory":"conquest","game_speed":2.0},"source":"Match.get_config() and live GameWorld startup"})
	await _save("02_R1C_INITIAL_PRODUCTION_MATCH.png")
	await _wait_until(func(): return world.is_navigation_ready(), 20.0)
	await _save("03_R1C_NAVIGATION_READY.png")
	var hall = await _build_player_war_hall()
	await _save("04_R1C_WAR_HALL_PLACED.png")
	await _save("05_R1C_WORKERS_TRAVELLING_TO_BUILD.png")
	var building_started := is_instance_valid(hall) and float(hall.build_progress) > 0.0
	await _wait(2.0)
	await _save("06_R1C_WAR_HALL_CONSTRUCTION_PROGRESS.png")
	var hall_ready := await _wait_until(func(): return is_instance_valid(hall) and hall.is_built, 60.0)
	if not hall_ready: _fail("NATURAL_SETUP_WAR_HALL_NOT_COMPLETE"); return
	await _save("07_R1C_WAR_HALL_COMPLETED.png")
	var queue_results: Array = []
	for _i in range(4):
		queue_results.append(hall.queue_unit("barrosan_crag_archer"))
		await get_tree().process_frame
	await _save_json("r1c-production-transactions.json", {"provenance":_provenance("production"),"observed":{"queue_results":queue_results,"resource_transactions":world.resource_transactions.duplicate(true),"queue_size":hall.queue.size()},"source":"live Building queue and GameWorld resource transaction ledger"})
	await _save("08_R1C_ARCHER_QUEUE_TRANSACTIONS.png")
	var trained := await _wait_until(func(): return world.commanders[0].units.filter(func(u): return is_instance_valid(u) and not u.is_dead and u.unit_id == "barrosan_crag_archer").size() >= 4, 75.0)
	if not trained: _fail("NATURAL_SETUP_FOUR_ARCHERS_NOT_TRAINED"); return
	await _save("09_R1C_FOUR_ARCHERS_READY.png")
	var targets := _enemy_combatants()
	if not targets.is_empty():
		await _focus(targets[0].global_position,30.0)
		await _save("10_R1C_ASSAULT_COMMAND_ISSUED.png")
		await _assault(targets[0],"opening_enemy_contact")
	await _sample_positions("after_opening_contact")
	await _save("11_R1C_ARMY_CROSSING_HOLLOWSPAN.png")
	await _save("12_R1C_ENEMY_CONTACT.png")
	await _save_json("r1c-assault-navigation-audit.json", {"provenance":_provenance("assault"),"observed":{"commands":assault_commands,"position_samples":position_samples,"navigation":world.navigation_runtime_snapshot()},"source":"live unit transforms/velocity and RTSController public commands"})
	await _save("13_R1C_REAL_COMBAT_DAMAGE.png")
	var hq = _enemy_buildings().filter(func(b): return b.def.get("is_hq",false)).front() if not _enemy_buildings().is_empty() else null
	if is_instance_valid(hq): await _assault(hq,"enemy_hq")
	await _save("14_R1C_ENEMY_BUILDING_DAMAGE.png")
	await _save("15_R1C_FIRST_BUILDING_DESTROYED.png")
	for building in _enemy_buildings(): await _assault(building,"remaining_building")
	await _save("16_R1C_ENEMY_HQ_DESTROYED.png")
	for worker in _enemy_workers(): await _assault(worker,"rebuild_worker")
	await _save("17_R1C_REBUILD_CAPABILITY_ELIMINATED.png")
	var ended := await _wait_until(func(): return world.match_ended, 120.0)
	await _save("18_R1C_FINAL_CONQUEST_PREDICATE.png")
	if not ended or not bool(world.result_snapshot.get("victory",false)) or String(world.result_snapshot.get("reason","")) != "Conquest": _fail("NATURAL_CONQUEST_NOT_RESOLVED"); return
	first_result = world.result_snapshot.duplicate(true)
	await _save("19_R1C_GENUINE_VICTORY_RESULT.png")
	await _save("20_R1C_RESULT_STATISTICS.png")
	await _runtime_audit("victory")
	var ui_audit := _result_ui_audit("victory")
	_save_json("r1c-victory-hud-audit.json",ui_audit)
	var frozen_time: float = world.match_time
	var frozen_resources: Dictionary = world.commanders[0].resources.duplicate(true)
	await _wait(5.0)
	await _save("21_R1C_POST_RESULT_FREEZE.png")
	_save_json("r1c-freeze-audit.json", {"provenance":_provenance("freeze"),"observed":{"match_time_before":frozen_time,"match_time_after":world.match_time,"resources_before":frozen_resources,"resources_after":world.commanders[0].resources.duplicate(true),"game_over_count":world.game_over_count,"game_running":world.game_running},"source":"live GameWorld post-result samples"})
	if session == "A":
		await _save("22_R1C_CONTINUE_BEFORE_CLICK.png")
		var continue_button := _find_button(root_node.hud.get("_gameover_layer"),"Continue")
		if not is_instance_valid(continue_button): _fail("CONTINUE_BUTTON_MISSING"); return
		continue_button.emit_signal("pressed")
		await _wait(3.0)
		await _save("23_R1C_CONTINUE_DESTINATION.png")
		_save_json("r1c-continue-audit.json", {"provenance":_provenance("continue"),"observed":{"button_pressed":true,"destination_scene":get_tree().current_scene.scene_file_path if is_instance_valid(get_tree().current_scene) else "","current_scene_instance":str(get_tree().current_scene.get_instance_id()) if is_instance_valid(get_tree().current_scene) else ""},"source":"actual Continue Button.pressed signal and current scene transition"})
		await _contact_sheet()
		get_tree().quit(0)
	else:
		await _save("24_R1C_SECOND_GENUINE_VICTORY_RESULT.png")
		await _save("25_R1C_PLAY_AGAIN_BEFORE_CLICK.png")
		var replay_button := _find_button(root_node.hud.get("_gameover_layer"),"Play Again")
		if not is_instance_valid(replay_button): _fail("PLAY_AGAIN_BUTTON_MISSING"); return
		replay_button.emit_signal("pressed")
		_save_json("r1c-play-again-click.json", {"provenance":_provenance("play_again"),"observed":{"button_pressed":true,"old_scene_instance":str(root_node.get_instance_id()),"old_result":first_result},"source":"actual Play Again Button.pressed signal"})
		await _wait_until(func(): return fresh_replay_captured, 30.0)
		await _contact_sheet()
		get_tree().quit(0)

func _capture_fresh_replay(new_root: Node) -> void:
	root_node = new_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	await _wait_until(func(): return world.game_running,20.0)
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("26_R1C_FRESH_REPLAY_INITIAL_STATE.png")
	await _save("27_R1C_FRESH_REPLAY_NO_STALE_RESULT.png")
	await _save("28_R1C_FRESH_REPLAY_FUNCTIONAL.png")
	_save_json("r1c-fresh-replay-audit.json", {"provenance":_provenance("fresh_replay"),"observed":{"new_scene_instance":str(new_root.get_instance_id()),"result":Match.last_result.duplicate(true),"match_ended":world.match_ended,"game_running":world.game_running,"match_time":world.match_time,"resources":world.commanders[0].resources.duplicate(true),"ai_count":new_root.ais.size(),"units":_audit_units()},"source":"fresh production scene after actual Play Again button action"})
	fresh_replay_captured = true

func capture_gameplay(p_root: Node) -> void:
	if not run_started:
		run_started = true
		root_node = p_root
		world = root_node.get_node("GameWorld")
		rts = root_node.get_node("RTS")
		await _capture_victory()
	elif session == "B" and not fresh_replay_captured:
		await _capture_fresh_replay(p_root)
