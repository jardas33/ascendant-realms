extends Node
## v0.436-R1H natural player-assault viability and conditional result proof.
## Opt-in evidence only: real production scene, real workers, real queues, and
## public RTS commands. This script never writes gameplay state directly.

const R1H_OUT := "res://../../artifacts/manual-review/v0436-r1h-natural-player-assault-viability/"
const R1I_OUT := "res://../../artifacts/manual-review/v0436-r1i-prepared-assault-combat-causality/"
const E1R_OUT := "res://../../artifacts/manual-review/v0436-e1r-competent-natural-conquest/"
const E1R2_OUT := "res://../../artifacts/manual-review/v0436-e1r2-sustainable-economy-natural-conquest-attempt-02/"
const E3_OUT := "res://../../artifacts/manual-review/v0436-e3-tutorial-golden-path/"
const E3R_OUT := "res://../../artifacts/manual-review/v0436-e3r-real-tutorial/"
const PREPARATION_LIMIT_SECONDS := 720.0
const ASSAULT_TIMEOUT_SECONDS := 90.0
const COMPETENT_ASSAULT_TIMEOUT_SECONDS := 180.0
const FORCE_PLAN := ["barrosan_spear_guard", "barrosan_spear_guard", "barrosan_crag_archer", "barrosan_crag_archer"]
const COMPETENT_FORCE_PLAN := ["barrosan_spear_guard", "barrosan_spear_guard", "barrosan_crag_archer", "barrosan_crag_archer", "barrosan_clan_levy", "barrosan_crag_archer", "barrosan_spear_guard", "barrosan_clan_levy", "barrosan_crag_archer"]

var root_node: Node
var world
var rts
var session := "A"
var evidence_mode := "R1I" if OS.get_environment("ASCENDANT_V0436_R1I_CAPTURE") == "1" else "R1H"
var out_path := R1I_OUT if evidence_mode == "R1I" else R1H_OUT
var competent_mode := OS.get_environment("ASCENDANT_V0436_E1R_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0436_F1_REINFORCEMENT_CAPTURE") == "1"
var e1r2_mode := OS.get_environment("ASCENDANT_V0436_E1R2_CAPTURE") == "1"
var tutorial_mode := OS.get_environment("ASCENDANT_V0436_E3_CAPTURE") == "1"
var e3r_mode := OS.get_environment("ASCENDANT_V0436_E3R_CAPTURE") == "1"
var started := false
var replay_captured := false
var frame_names: Array[String] = []
var command_log: Array = []
var target_lifecycles: Array = []
var predicate_sequence: Array = []
var economy_timeline: Array = []
var last_valid_frame := ""
var preparation_started_ms := 0
var primary_status := ""
var force_plan_audit: Dictionary = {}
var e3r_completion_diagnostic := OS.get_environment("ASCENDANT_E3R_COMPLETION_DIAGNOSTIC") == "1"
var e3r_input_events: Array = []
var e3r_completion_pressed_count := 0
var f1_mode := OS.get_environment("ASCENDANT_V0436_F1_REINFORCEMENT_CAPTURE") == "1"
var f1_sampling_active := false
var f1_samples: Array = []
var f1_sampled_buckets: Dictionary = {}
var f1_queue_results: Array = []

func _ready() -> void:
	session = OS.get_environment("ASCENDANT_V0436_R1H_SESSION")
	if session != "A" and session != "B": session = "A"
	if f1_mode:
		evidence_mode = "F1"
		out_path = OS.get_environment("ASCENDANT_V0436_F1_OUT")
		if out_path == "": out_path = "user://v0436-f1-reinforcement-diagnosis/"
	elif e3r_mode:
		evidence_mode = "E3R"
		out_path = E3R_OUT + "session-%s/" % session.to_lower()
		var step8_out := OS.get_environment("ASCENDANT_E3R_STEP8_OUT")
		if step8_out != "":
			out_path = step8_out
	elif competent_mode:
		evidence_mode = "E1R"
		out_path = (E1R2_OUT if e1r2_mode else E1R_OUT) + "session-%s/" % session.to_lower()
	elif tutorial_mode:
		evidence_mode = "E3"
		out_path = E3_OUT + "session-%s/" % session.to_lower()
	else:
		out_path = (R1I_OUT if evidence_mode == "R1I" else R1H_OUT) + "session-%s/" % session.to_lower()
	DirAccess.make_dir_recursive_absolute(_output_path())
	if not e3r_mode:
		Match.set_config({"player_race":"barrosan", "opponents":[{"race":"lioraen", "difficulty":"easy"}], "map":"hollowspan", "start_resources":"rich" if competent_mode or tutorial_mode else "standard", "victory":"conquest", "mode":"tutorial" if tutorial_mode else "skirmish", "game_speed":2.0})

func _input(event: InputEvent) -> void:
	if not e3r_completion_diagnostic or not e3r_mode:
		return
	var record := {"timestamp_ms":Time.get_ticks_msec(), "event_type":event.get_class(), "handled_at_autoload":get_viewport().is_input_handled()}
	if event is InputEventMouseMotion:
		record["position"] = _vec2(event.position)
		record["global_position"] = _vec2(event.global_position)
	elif event is InputEventMouseButton:
		record["position"] = _vec2(event.position)
		record["global_position"] = _vec2(event.global_position)
		record["button_index"] = event.button_index
		record["pressed"] = event.pressed
	e3r_input_events.append(record)
	if e3r_input_events.size() > 2000:
		e3r_input_events.pop_front()

func _vec2(value: Vector2) -> Dictionary: return {"x":value.x, "y":value.y}

func _output_path(name := "") -> String:
	var target := out_path + name
	return ProjectSettings.globalize_path(target) if target.begins_with("res://") or target.begins_with("user://") else target

func _on_diagnostic_completion_pressed() -> void:
	e3r_completion_pressed_count += 1

func _ui_tree_record(node: Node, depth := 0) -> Dictionary:
	var record := {"name":String(node.name), "class":node.get_class(), "visible":bool(node.visible) if node is CanvasItem else true, "process_mode":node.process_mode}
	if node is Control:
		var rect: Rect2 = node.get_global_rect()
		record["rect"] = {"x":rect.position.x, "y":rect.position.y, "w":rect.size.x, "h":rect.size.y}
		record["mouse_filter"] = node.mouse_filter
		record["z_index"] = node.z_index
		record["focus_mode"] = node.focus_mode
		if node is Button:
			record["text"] = String(node.text)
			record["disabled"] = node.disabled
			record["button_pressed"] = node.button_pressed
			record["hovered"] = node.is_hovered()
	if depth < 8:
		record["children"] = []
		for child in node.get_children():
			record["children"].append(_ui_tree_record(child, depth + 1))
	return record

func _completion_ui_diagnostic(button: Button) -> Dictionary:
	var ancestors: Array = []
	var cursor: Node = button
	while is_instance_valid(cursor) and ancestors.size() < 12:
		ancestors.append(_ui_tree_record(cursor, 0))
		cursor = cursor.get_parent()
	var hover = get_viewport().gui_get_hovered_control()
	var focus = get_viewport().gui_get_focus_owner()
	var button_rect := button.get_global_rect()
	return {"button_path":String(button.get_path()), "button_text":String(button.text), "button_rect":{"x":button_rect.position.x,"y":button_rect.position.y,"w":button_rect.size.x,"h":button_rect.size.y}, "viewport_rect":{"x":0,"y":0,"w":get_viewport().get_visible_rect().size.x,"h":get_viewport().get_visible_rect().size.y}, "button_visible":button.visible, "button_disabled":button.disabled, "button_focus_mode":button.focus_mode, "button_mouse_filter":button.mouse_filter, "button_z_index":button.z_index, "button_hovered":button.is_hovered(), "button_button_pressed":button.button_pressed, "hovered_control":String(hover.get_path()) if is_instance_valid(hover) else "", "focus_owner":String(focus.get_path()) if is_instance_valid(focus) else "", "ancestors":ancestors, "input_event_count_before":e3r_input_events.size(), "completion_pressed_count_before":e3r_completion_pressed_count}

func _e3r_completion_resolution() -> Vector2i:
	var raw := OS.get_environment("ASCENDANT_E3R_COMPLETION_RESOLUTION")
	if raw == "1366x768": return Vector2i(1366, 768)
	return Vector2i(1920, 1080)

func _vec(v: Vector3) -> Dictionary: return {"x":v.x, "y":v.y, "z":v.z}

func _provenance(label: String) -> Dictionary:
	var source_sha := OS.get_environment("ASCENDANT_V0436_R1I_SOURCE_SHA") if evidence_mode == "R1I" else OS.get_environment("ASCENDANT_V0436_R1H_SOURCE_SHA")
	var branch := OS.get_environment("ASCENDANT_V0436_R1I_BRANCH") if evidence_mode == "R1I" else OS.get_environment("ASCENDANT_V0436_R1H_BRANCH")
	return {"schema":"v0436-%s-live-evidence-v1" % evidence_mode.to_lower(), "session":session, "attempt":label, "source_sha":source_sha, "branch":branch, "production_scene":"scenes/main.tscn -> scenes/game_world.tscn", "timestamp_ms":Time.get_ticks_msec()}

func _wait_seconds(seconds: float) -> void: await get_tree().create_timer(seconds).timeout

func _wait_until(check: Callable, timeout: float) -> bool:
	var deadline := Time.get_ticks_msec() + int(timeout * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if check.call(): return true
		await get_tree().process_frame
	return bool(check.call())

func _step8_telemetry(lume, duration_seconds: float) -> void:
	var samples: Array = []
	var started_ms := Time.get_ticks_msec()
	while float(Time.get_ticks_msec() - started_ms) / 1000.0 < duration_seconds:
		var capture: Dictionary = lume.get_capture_snapshot() if lume.has_method("get_capture_snapshot") else {"owner_team":lume.owner_team, "progress":lume._progress, "contesting_team":lume._contesting_team, "global_position":lume.global_position}
		var nearby: Array = []
		var counts: Dictionary = {}
		for unit in world.all_units():
			if not _live_unit(unit):
				continue
			var distance: float = float(unit.global_position.distance_to(lume.global_position))
			if distance <= 7.5:
				var team := int(unit.team)
				counts[team] = int(counts.get(team, 0)) + 1
				nearby.append({"runtime_id":str(unit.get_instance_id()), "unit_id":String(unit.unit_id), "team":team, "position":_vec(unit.global_position), "distance":distance})
		var lead_team := -1
		var lead_count := 0
		var tie := false
		for key in counts.keys():
			var team_count := int(counts[key])
			if team_count > lead_count:
				lead_count = team_count
				lead_team = int(key)
				tie = false
			elif team_count == lead_count and team_count > 0:
				tie = true
		var tutorial_lume = root_node.tutorial.get("_lume_point") if is_instance_valid(root_node) and is_instance_valid(root_node.tutorial) else null
		samples.append({"timestamp_ms":Time.get_ticks_msec(), "physics_frame":Engine.get_physics_frames(), "process_frame":Engine.get_process_frames(), "runtime_instance_id":str(lume.get_instance_id()), "point_name":String(lume.point_name), "global_position":_vec(lume.global_position), "owner_team":int(capture.get("owner_team", -1)), "contesting_team":int(capture.get("contesting_team", -1)), "progress":float(capture.get("progress", 0.0)), "benefit":String(lume.benefit), "ring_radius_visual":{"inner":3.4, "outer":3.9}, "actual_gameplay_radius":7.5, "nearby_player_units":nearby.filter(func(item): return int(item.get("team", -1)) == int(world.player_commander.team)), "nearby_units":nearby, "counts_by_team":counts, "lead_team":lead_team, "tie":tie, "world_game_running":bool(world.game_running), "tutorial":_tutorial_snapshot(), "expected_target":{"point_name":"Lume Spire", "runtime_instance_id":str(tutorial_lume.get_instance_id()) if is_instance_valid(tutorial_lume) else "", "same_instance":is_instance_valid(tutorial_lume) and tutorial_lume == lume}})
		await get_tree().create_timer(0.1).timeout
	_save_json("e3r-step8-telemetry.json", {"schema":"v0436-e3r-step8-telemetry-v1", "sample_period_seconds":0.1, "duration_seconds":duration_seconds, "target_runtime_instance_id":str(lume.get_instance_id()), "samples":samples})

func _evidence_name(name: String) -> String:
	if e3r_mode: return name.replace("R1H", "E3R").replace("r1h-", "e3r-")
	if f1_mode: return name.replace("R1H", "F1").replace("r1h-", "f1-")
	if competent_mode: return name.replace("R1H", "E1R").replace("r1h-", "e1r-")
	if tutorial_mode: return name.replace("R1H", "E3").replace("r1h-", "e3-")
	if evidence_mode == "R1I": return name.replace("R1H", "R1I").replace("r1h-", "r1i-")
	return name

func _e3r_repair_capture() -> bool:
	return e3r_mode and OS.get_environment("ASCENDANT_E3R_STEP8_OUT") != ""

func _save_e3r_frame(canonical: String, legacy: String) -> void:
	await _save(canonical if _e3r_repair_capture() else legacy)

func _save(name: String) -> void:
	name = _evidence_name(name)
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png(_output_path(name))
	frame_names.append(name)
	last_valid_frame = name

func _save_json(name: String, value) -> void:
	name = _evidence_name(name)
	var file := FileAccess.open(_output_path(name), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
		file.store_line("")

func _focus(position: Vector3, zoom := 34.0) -> void:
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts._zoom = zoom
	rts.cam_arm.spring_length = zoom
	rts.focus_on(position)
	for _i in range(4): await get_tree().process_frame

func _live_unit(unit) -> bool: return is_instance_valid(unit) and not bool(unit.is_dead)
func _live_building(building) -> bool: return is_instance_valid(building) and not bool(building.is_dead)

func _unit_record(unit) -> Dictionary:
	return {"definition_id":String(unit.unit_id), "runtime_id":str(unit.get_instance_id()), "team":int(unit.team), "role":String(unit.def.get("role", "")), "hp":float(unit.hp), "max_hp":float(unit.max_hp) if "max_hp" in unit else null, "dead":bool(unit.is_dead), "position":_vec(unit.global_position), "state":int(unit.state), "navigation_command":String(unit.get("_navigation_command_type"))}

func _events_since(events: Array, start: int) -> Array:
	var result: Array = []
	for index in range(start, events.size()): result.append(events[index].duplicate(true))
	return result

func _r1i_checkpoint(a_name: String, b_name: String) -> void:
	if evidence_mode == "R1I": await _save(a_name if session == "A" else b_name)

func _building_record(building) -> Dictionary:
	return {"definition_id":String(building.building_id), "runtime_id":str(building.get_instance_id()), "team":int(building.team), "hp":float(building.hp), "max_hp":float(building.max_hp) if "max_hp" in building else null, "dead":bool(building.is_dead), "built":bool(building.is_built), "position":_vec(building.global_position), "is_hq":bool(building.def.get("is_hq", false)), "state":str(building.get("state"))}

func _commander_record(cmd) -> Dictionary:
	var units: Array = []
	for unit in cmd.units:
		if is_instance_valid(unit): units.append(_unit_record(unit))
	var buildings: Array = []
	for building in cmd.buildings:
		if is_instance_valid(building): buildings.append(_building_record(building))
	var live_workers := units.filter(func(v): return not bool(v.get("dead", true)) and String(v.get("role", "")) == "worker")
	var live_buildings := buildings.filter(func(v): return not bool(v.get("dead", true)))
	var live_hq := live_buildings.filter(func(v): return bool(v.get("is_hq", false)))
	return {"team":int(cmd.team), "race":String(cmd.race), "defeated":bool(cmd.defeated), "defeat_reason":String(cmd.defeat_reason), "units":units, "buildings":buildings, "live_workers":live_workers, "live_buildings":live_buildings, "live_hq":live_hq, "has_hq":cmd.has_hq(), "alive_buildings":cmd.alive_buildings(), "no_hq":live_hq.is_empty(), "no_buildings":live_buildings.is_empty(), "no_workers":live_workers.is_empty(), "resources":cmd.resources.duplicate(true), "pop_used":int(cmd.pop_used), "reserved_pop":int(cmd.reserved_pop), "pop_cap":int(cmd.pop_cap)}

func _queue_record(building) -> Dictionary:
	var items: Array = []
	if is_instance_valid(building):
		for item in building.queue: items.append(item.duplicate(true) if item is Dictionary else str(item))
	return {"building_id":String(building.building_id) if is_instance_valid(building) else "", "built":bool(building.is_built) if is_instance_valid(building) else false, "queue":items}

func _record_economy(label: String) -> void:
	var cmd = world.commanders[0]
	var workers: Array = []
	for unit in cmd.units:
		if is_instance_valid(unit) and not unit.is_dead and unit.is_worker: workers.append(unit.get_economy_snapshot())
	economy_timeline.append({"label":label, "timestamp_ms":Time.get_ticks_msec(), "resources":cmd.resources.duplicate(true), "pop_used":cmd.pop_used, "reserved_pop":cmd.reserved_pop, "pop_cap":cmd.pop_cap, "workers":workers, "resource_transaction_count":world.resource_transactions.size(), "resource_transactions":world.resource_transactions.duplicate(true), "queues":cmd.buildings.map(func(b): return _queue_record(b))})

func _f1_worker_record(worker) -> Dictionary:
	var economy: Dictionary = worker.get_economy_snapshot() if worker.has_method("get_economy_snapshot") else {}
	var command_type := String(worker.get("_navigation_command_type"))
	var classification := "idle"
	if command_type.contains("gather") or int(worker.state) == Unit.State.GATHERING:
		classification = "gathering"
	elif command_type.contains("build") or int(worker.state) == Unit.State.BUILDING:
		classification = "building"
	elif command_type.contains("return") or command_type.contains("deposit"):
		classification = "returning"
	elif int(worker.state) == Unit.State.MOVING:
		classification = "moving"
	economy["runtime_id"] = str(worker.get_instance_id())
	economy["unit_id"] = String(worker.unit_id)
	economy["state_code"] = int(worker.state)
	economy["command_type"] = command_type
	economy["classification"] = classification
	economy["position"] = _vec(worker.global_position)
	return economy

func _f1_queue_snapshot() -> Array:
	var queues: Array = []
	for building in world.player_commander.buildings:
		if not is_instance_valid(building) or building.is_dead: continue
		queues.append(_queue_record(building))
	return queues

func _f1_production_theory() -> Dictionary:
	var plan := ["barrosan_spear_guard", "barrosan_crag_archer", "barrosan_clan_levy", "barrosan_spear_guard", "barrosan_crag_archer", "barrosan_clan_levy", "barrosan_spear_guard", "barrosan_crag_archer", "barrosan_clan_levy", "barrosan_spear_guard", "barrosan_crag_archer", "barrosan_clan_levy", "barrosan_spear_guard", "barrosan_crag_archer", "barrosan_clan_levy"]
	var totals := {"5": {"food":0, "timber":0, "stone":0, "gold":0, "build_time_seconds":0.0}, "10": {"food":0, "timber":0, "stone":0, "gold":0, "build_time_seconds":0.0}, "15": {"food":0, "timber":0, "stone":0, "gold":0, "build_time_seconds":0.0}}
	for index in range(plan.size()):
		var definition := GameData.get_unit(plan[index])
		for key in ["food", "timber", "stone", "gold"]: totals["15"][key] += int(definition.get("cost", {}).get(key, 0))
		totals["15"]["build_time_seconds"] += float(definition.get("build_time", 0))
		if index < 10:
			for key in ["food", "timber", "stone", "gold"]: totals["10"][key] += int(definition.get("cost", {}).get(key, 0))
			totals["10"]["build_time_seconds"] += float(definition.get("build_time", 0))
		if index < 5:
			for key in ["food", "timber", "stone", "gold"]: totals["5"][key] += int(definition.get("cost", {}).get(key, 0))
			totals["5"]["build_time_seconds"] += float(definition.get("build_time", 0))
	return {"plan":plan, "definitions":plan.map(func(unit_id): return {"id":unit_id, "cost":GameData.get_unit(unit_id).get("cost", {}).duplicate(true), "build_time_seconds":GameData.get_unit(unit_id).get("build_time", 0)}), "totals":totals, "train_speed_multiplier_observed":world.player_commander.train_speed_mult() if world.player_commander.has_method("train_speed_mult") else null, "note":"theoretical totals use authoritative GameData costs/build times; effective runtime duration is measured separately"}

func _f1_capture_sample(bucket: int, label: String) -> void:
	if f1_sampled_buckets.has(bucket): return
	f1_sampled_buckets[bucket] = true
	var cmd = world.player_commander
	var workers: Array = []
	for worker in cmd.units:
		if is_instance_valid(worker) and not worker.is_dead and worker.is_worker: workers.append(_f1_worker_record(worker))
	var combat_ids: Array = []
	for unit in cmd.units:
		if is_instance_valid(unit) and not unit.is_dead and not unit.is_worker: combat_ids.append(str(unit.get_instance_id()))
	var income_by_kind := {}
	for transaction in world.resource_transactions:
		var kind := String(transaction.get("resource_kind", transaction.get("kind", "unknown")))
		income_by_kind[kind] = int(income_by_kind.get(kind, 0)) + int(transaction.get("amount", transaction.get("value", 0)))
	f1_samples.append({"bucket":bucket, "label":label, "match_time_seconds":float(world.match_time), "resources":cmd.resources.duplicate(true), "workers":workers, "worker_counts":{"total":workers.size(), "idle":workers.filter(func(w): return String(w.get("classification", "")) == "idle").size(), "returning":workers.filter(func(w): return String(w.get("classification", "")) == "returning").size(), "gathering":workers.filter(func(w): return String(w.get("classification", "")) == "gathering").size(), "building":workers.filter(func(w): return String(w.get("classification", "")) == "building").size(), "moving":workers.filter(func(w): return String(w.get("classification", "")) == "moving").size()}, "pop_used":int(cmd.pop_used), "reserved_pop":int(cmd.reserved_pop), "pop_cap":int(cmd.pop_cap), "income_by_kind":income_by_kind, "resource_transaction_count":world.resource_transactions.size(), "queues":_f1_queue_snapshot(), "combat_unit_runtime_ids":combat_ids, "combat_unit_count":combat_ids.size(), "death_event_count":world.combat_death_events.size(), "world_game_running":bool(world.game_running)})

func _f1_sampling_loop() -> void:
	while f1_sampling_active and is_instance_valid(world) and float(world.match_time) <= 300.0:
		var bucket := int(floor(float(world.match_time) / 10.0))
		_f1_capture_sample(bucket, "simulation_10_second_sample")
		await get_tree().create_timer(0.25).timeout

func _f1_production_capture() -> void:
	if not await _wait_until(func(): return is_instance_valid(world) and world.game_running, 30.0): await _failure("BLOCKED_F1_MATCH_NOT_STARTED", "production match did not start"); return
	if not await _wait_until(func(): return world.is_navigation_ready(), 30.0): await _failure("BLOCKED_F1_NAVIGATION_NOT_READY", "navigation did not become ready"); return
	var config := Match.get_config().duplicate(true)
	_save_json("match-configuration.json", {"provenance":_provenance("f1_configuration"), "observed":config, "expected":{"player_race":"barrosan", "opponents":[{"race":"lioraen", "difficulty":"easy"}], "map":"hollowspan", "start_resources":"rich", "mode":"skirmish", "victory":"conquest", "game_speed":2.0}, "offense_before_simulation_seconds":600.0})
	_save_json("production-theory.json", {"provenance":_provenance("f1_authoritative_theory"), "theory":_f1_production_theory()})
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("01_F1_STANDARD_MATCH_START.png")
	f1_sampling_active = true
	_f1_sampling_loop()
	var production_ok := await _normal_production_setup()
	f1_sampling_active = false
	_f1_capture_sample(int(floor(float(world.match_time) / 10.0)), "production_setup_terminal")
	await _wait_seconds(0.5)
	var reasons := {}
	for entry in f1_queue_results:
		var result = entry.get("result", {}) if entry is Dictionary else {}
		var reason := String(result.get("reason", "ok")) if result is Dictionary else "unknown"
		reasons[reason] = int(reasons.get(reason, 0)) + 1
	var blocker_status := "PASS_F1_REINFORCEMENT_THROUGHPUT_OBSERVED" if production_ok else "BLOCKED_F1_REINFORCEMENT_THROUGHPUT"
	var blocker_reason := "normal public production recovered a mixed force" if production_ok else "normal construction, worker gathering, or costed production did not recover the requested reinforcement force"
	_save_json("reinforcement-throughput.json", {"schema":"v0436-f1-reinforcement-throughput-v1", "provenance":_provenance("f1_reinforcement_diagnosis"), "status":blocker_status, "reason":blocker_reason, "configuration":config, "theoretical_cost_time":_f1_production_theory(), "samples_every_simulation_seconds":10, "samples":f1_samples, "queue_results":f1_queue_results, "queue_reason_counts":reasons, "economy_timeline":economy_timeline, "no_player_offense_before_simulation_seconds":600.0, "public_actions_only":true, "state_injection":false})
	_save_json("f1-blocker.json", {"schema":"v0436-f1-reinforcement-blocker-v1", "status":blocker_status, "reason":blocker_reason, "last_valid_frame":last_valid_frame, "resource_transactions":world.resource_transactions.duplicate(true), "queue_reason_counts":reasons, "sample_count":f1_samples.size()})
	await _save("02_F1_ECONOMY_AND_REINFORCEMENT_STATE.png")
	await _contact_sheet()
	get_tree().quit(0)

func _predicate_snapshot(label: String) -> Dictionary:
	var commanders: Array = []
	for cmd in world.commanders: commanders.append(_commander_record(cmd))
	var survivors: Array = []
	for cmd in world.commanders:
		if not cmd.defeated: survivors.append(int(cmd.team))
	var snapshot := {"label":label, "timestamp_ms":Time.get_ticks_msec(), "physics_frame":Engine.get_physics_frames(), "process_frame":Engine.get_process_frames(), "commanders":commanders, "game_running":bool(world.game_running), "match_ended":bool(world.match_ended), "game_over_count":int(world.game_over_count), "profile_record_count":int(world.profile_record_count), "result":world.result_snapshot.duplicate(true), "match_result":Match.last_result.duplicate(true), "sole_non_defeated_commanders":survivors, "victory_check_observation":"read-only snapshot; no capture-only victory counter was added"}
	predicate_sequence.append(snapshot)
	return snapshot

func _player_combatants() -> Array: return world.commanders[0].units.filter(func(u): return _live_unit(u) and not bool(u.is_worker))
func _enemy_combatants() -> Array: return world.commanders[1].units.filter(func(u): return _live_unit(u) and not bool(u.is_worker))
func _enemy_workers() -> Array: return world.commanders[1].units.filter(func(u): return _live_unit(u) and bool(u.is_worker))
func _enemy_buildings() -> Array: return world.commanders[1].buildings.filter(func(b): return _live_building(b))

func _army_count() -> int:
	var count := 0
	for unit in world.commanders[0].units:
		if _live_unit(unit): count += 1
	return count

func _select_many(nodes: Array) -> void:
	rts._clear_selection()
	for node in nodes:
		if is_instance_valid(node) and not bool(node.is_dead): rts._add_to_selection(node)
	rts.emit_signal("selection_changed", rts.selected)
	await get_tree().process_frame

func _resources_by_kind() -> Dictionary:
	var result := {"food":null, "timber":null, "stone":null, "gold":null}
	for node in world.get_tree().get_nodes_in_group("resources"):
		if is_instance_valid(node) and not node.depleted and result.has(node.resource_kind) and result[node.resource_kind] == null: result[node.resource_kind] = node
	return result

func _find_build_position() -> Vector3:
	var anchor: Vector3 = world.player_commander.buildings[0].global_position
	for radius in [24.0, 30.0, 36.0]:
		for i in range(12):
			var p: Vector3 = anchor + Vector3(cos(TAU * i / 12.0), 0, sin(TAU * i / 12.0)) * radius
			if world.can_place_building("barrosan_war_hall", 0, p, true): return p
	return Vector3.INF

func _find_building_position(building_id: String) -> Vector3:
	var anchor: Vector3 = world.player_commander.buildings[0].global_position
	for radius in [16.0, 20.0, 24.0, 30.0, 36.0]:
		for i in range(16):
			var p: Vector3 = anchor + Vector3(cos(TAU * i / 16.0), 0, sin(TAU * i / 16.0)) * radius
			if world.can_place_building(building_id, 0, p, true): return p
	return Vector3.INF

func _production_definitions() -> Dictionary:
	var roles: Array = []
	var hall_def := GameData.get_building("barrosan_war_hall").duplicate(true)
	for unit_id in hall_def.get("produces", []):
		var d := GameData.get_unit(String(unit_id)).duplicate(true)
		roles.append({"id":String(unit_id), "definition":d, "reason":"live War Hall roster audit"})
	var plan: Array = []
	var selected_plan: Array = COMPETENT_FORCE_PLAN if competent_mode else FORCE_PLAN
	for unit_id in selected_plan:
		var d := GameData.get_unit(unit_id).duplicate(true)
		plan.append({"id":unit_id, "role":String(d.get("role", "")), "cost":d.get("cost", {}), "build_time":d.get("build_time", 0), "pop":d.get("pop", 0), "hp":d.get("hp", 0), "dmg":d.get("dmg", 0), "dmg_type":d.get("dmg_type", ""), "armor_class":d.get("armor_class", ""), "range":d.get("range", 0), "reason":"frontline durability or ranged damage in a normal mixed force"})
	return {"building_id":"barrosan_war_hall", "building":hall_def, "available_roles":roles, "planned_roles":plan, "hero_definition":GameData.get_unit("barrosan_hero_thane").duplicate(true), "population_cap_bound":20 if competent_mode else 12, "max_live_combatants":16, "max_preparation_wall_seconds":PREPARATION_LIMIT_SECONDS}

func _normal_production_setup() -> bool:
	preparation_started_ms = Time.get_ticks_msec()
	force_plan_audit = _production_definitions()
	_save_json("force-plan.json", {"provenance":_provenance("force_plan"), "plan":force_plan_audit})
	var hq = world.player_commander.buildings[0]
	var build_pos := _find_build_position()
	var hall = world.place_building("barrosan_war_hall", 0, build_pos) if build_pos != Vector3.INF else null
	if not is_instance_valid(hall): return false
	var build_workers: Array = []
	for worker in world.commanders[0].units:
		if is_instance_valid(worker) and worker.is_worker:
			build_workers.append(str(worker.get_instance_id()))
			worker.command_build(hall)
	_record_economy("war_hall_placement_and_worker_build_commands")
	_save_json("construction-audit.json", {"provenance":_provenance("construction"), "building":_building_record(hall), "worker_runtime_ids":build_workers, "real_public_path":"GameWorld.place_building -> Unit.command_build"})
	await _save("03_R1H_PRODUCTION_INFRASTRUCTURE.png")
	if not await _wait_until(func(): return is_instance_valid(hall) and hall.is_built, 90.0): return false
	_record_economy("war_hall_built")
	await _focus(hall.global_position)
	await _save("04_R1H_MIXED_FORCE_IN_PRODUCTION.png")
	if competent_mode:
		return await _competent_production_setup(hall)
	var resources := _resources_by_kind()
	var food = resources.get("food")
	if not is_instance_valid(food): return false
	for worker in world.commanders[0].units:
		if is_instance_valid(worker) and worker.is_worker: worker.command_gather(food)
	_record_economy("workers_resumed_food_gathering")
	await _save("02_R1H_WORKERS_RESUME_ECONOMY.png")
	var gathered := await _wait_until(func(): return world.resource_transactions.size() > 0 and int(world.commanders[0].resources.get("food", 0)) >= 240, 180.0)
	if not gathered: return false
	_record_economy("food_threshold_reached_for_mixed_force")
	var queue_results: Array = []
	for unit_id in FORCE_PLAN:
		var result = hall.queue_unit(unit_id)
		queue_results.append({"unit_id":unit_id, "result":result, "resources_after":world.commanders[0].resources.duplicate(true), "pop_used":world.commanders[0].pop_used, "reserved_pop":world.commanders[0].reserved_pop})
		await get_tree().process_frame
	_record_economy("mixed_force_queues_issued")
	_save_json("production-audit.json", {"provenance":_provenance("production"), "queue_results":queue_results, "resource_transactions":world.resource_transactions.duplicate(true), "queue_plan":FORCE_PLAN, "source":"normal placement, worker construction, resumed worker gathering, and real-cost Building.queue_unit"})
	return await _wait_until(func():
		var ids: Dictionary = {}
		for u in _player_combatants(): ids[String(u.unit_id)] = int(ids.get(String(u.unit_id), 0)) + 1
		return int(ids.get("barrosan_spear_guard", 0)) >= 3 and int(ids.get("barrosan_crag_archer", 0)) >= 2, 240.0)

func _competent_production_setup(hall) -> bool:
	var house_pos := _find_building_position("barrosan_clan_croft")
	var house = world.place_building("barrosan_clan_croft", 0, house_pos) if house_pos != Vector3.INF else null
	if not is_instance_valid(house): return false
	var workers: Array = world.commanders[0].units.filter(func(u): return is_instance_valid(u) and bool(u.is_worker))
	for worker in workers: worker.command_build(house)
	_record_economy("house_placement_and_worker_build_commands")
	await _save("04_R1H_HOUSING_INFRASTRUCTURE.png")
	if not await _wait_until(func(): return is_instance_valid(house) and bool(house.is_built), 90.0): return false
	_record_economy("house_built")
	var resources := _resources_by_kind()
	var food = resources.get("food")
	var timber = resources.get("timber")
	var assigned := 0
	for worker in workers:
		if not is_instance_valid(worker): continue
		if assigned % 2 == 0 and is_instance_valid(food): worker.command_gather(food)
		elif is_instance_valid(timber): worker.command_gather(timber)
		elif is_instance_valid(food): worker.command_gather(food)
		assigned += 1
	_record_economy("workers_gather_food_and_timber")
	await _save("02_R1H_WORKERS_RESUME_ECONOMY.png")
	if not await _wait_until(func(): return world.resource_transactions.size() >= 6, 90.0): return false
	var queue_results: Array = []
	for unit_id in COMPETENT_FORCE_PLAN:
		var result = {"ok":false, "reason":"not attempted"}
		var retry_deadline := Time.get_ticks_msec() + 90000
		while Time.get_ticks_msec() < retry_deadline:
			result = hall.queue_unit(unit_id)
			queue_results.append({"unit_id":unit_id, "attempt":queue_results.size() + 1, "result":result, "resources_after":world.commanders[0].resources.duplicate(true), "pop_used":world.commanders[0].pop_used, "reserved_pop":world.commanders[0].reserved_pop})
			if bool(result.get("ok", false)): break
			if String(result.get("reason", "")).contains("higher Age"): break
			await _wait_seconds(4.0)
		await get_tree().process_frame
	if f1_mode: f1_queue_results = queue_results.duplicate(true)
	_record_economy("competent_mixed_force_queues_issued")
	_save_json("production-audit.json", {"provenance":_provenance("production"), "queue_results":queue_results, "resource_transactions":world.resource_transactions.duplicate(true), "queue_plan":COMPETENT_FORCE_PLAN, "source":"normal house placement, worker construction, resumed two-resource gathering, and real-cost Building.queue_unit"})
	return await _wait_until(func(): return _player_combatants().size() >= 10, 360.0)

func _target_key(target, category: String) -> Dictionary:
	return {"category":category, "definition_id":String(target.get("building_id") if category == "building" else target.get("unit_id")), "runtime_id":str(target.get_instance_id())}

func _assault_target(target, category: String, label: String) -> Dictionary:
	var audit := _target_key(target, category)
	audit["label"] = label
	audit["initial_hp"] = float(target.hp) if is_instance_valid(target) and "hp" in target else null
	audit["maximum_hp"] = float(target.max_hp) if is_instance_valid(target) and "max_hp" in target else null
	audit["initial_position"] = _vec(target.global_position) if is_instance_valid(target) else null
	audit["player_force_before"] = _player_combatants().map(func(u): return _unit_record(u))
	audit["commands"] = []
	audit["hp_samples"] = []
	audit["position_samples"] = []
	audit["attacker_samples"] = []
	audit["damage_event_count_before"] = world.combat_damage_events.size() + world.building_damage_events.size()
	var combat_events_before: int = world.combat_damage_events.size()
	var death_events_before: int = world.combat_death_events.size()
	var army := _player_combatants()
	if army.is_empty(): audit["terminal_disposition"] = "BLOCKED_R1H_PLAYER_PRODUCTION_CANNOT_RECOVER"; target_lifecycles.append(audit); return audit
	await _select_many(army)
	var move_ok: bool = rts.issue_attack_move_destination(target.global_position)
	var target_ok: bool = rts.issue_attack_target(target)
	audit.commands.append({"timestamp_ms":Time.get_ticks_msec(), "attack_move_return":move_ok, "attack_target_return":target_ok, "target_position":_vec(target.global_position)})
	var started_ms := Time.get_ticks_msec()
	var next_reissue := started_ms + 8000
	while Time.get_ticks_msec() - started_ms < int(ASSAULT_TIMEOUT_SECONDS * 1000.0):
		if not is_instance_valid(target) or target.is_dead: audit["terminal_disposition"] = "DESTROYED"; break
		if _player_combatants().is_empty(): audit["terminal_disposition"] = "BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED"; break
		audit.hp_samples.append({"timestamp_ms":Time.get_ticks_msec(), "hp":float(target.hp), "dead":bool(target.is_dead)})
		audit.position_samples.append({"timestamp_ms":Time.get_ticks_msec(), "position":_vec(target.global_position), "state":int(target.state) if "state" in target else null})
		audit.attacker_samples.append({"timestamp_ms":Time.get_ticks_msec(), "units":_player_combatants().map(func(u): return _unit_record(u))})
		if Time.get_ticks_msec() >= next_reissue:
			var idle := _player_combatants().filter(func(u): return int(u.state) == Unit.State.IDLE or String(u.get("_navigation_command_type")) == "")
			if not idle.is_empty():
				await _select_many(_player_combatants())
				var retry_move: bool = rts.issue_attack_move_destination(target.global_position)
				var retry_target: bool = rts.issue_attack_target(target)
				audit.commands.append({"timestamp_ms":Time.get_ticks_msec(), "kind":"reissue", "idle_count":idle.size(), "attack_move_return":retry_move, "attack_target_return":retry_target})
			next_reissue += 8000
		await _wait_seconds(0.5)
	if not audit.has("terminal_disposition"):
		if _player_combatants().is_empty(): audit["terminal_disposition"] = "BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED"
		elif world.combat_damage_events.size() + world.building_damage_events.size() == int(audit["damage_event_count_before"]): audit["terminal_disposition"] = "BLOCKED_R1H_TARGET_NOT_TAKING_DAMAGE"
		else: audit["terminal_disposition"] = "BLOCKED_R1H_CAPTURE_STRATEGY_INCONCLUSIVE"
	audit["final_valid"] = is_instance_valid(target)
	audit["final_hp"] = float(target.hp) if is_instance_valid(target) and "hp" in target else null
	audit["final_position"] = _vec(target.global_position) if is_instance_valid(target) else null
	audit["damage_event_count_after"] = world.combat_damage_events.size() + world.building_damage_events.size()
	audit["combat_events"] = _events_since(world.combat_damage_events, combat_events_before)
	audit["death_events"] = _events_since(world.combat_death_events, death_events_before)
	audit["elapsed_wall_seconds"] = float(Time.get_ticks_msec() - started_ms) / 1000.0
	audit["navigation_snapshot"] = world.navigation_runtime_snapshot()
	target_lifecycles.append(audit)
	return audit

func _failure(status: String, reason: String) -> void:
	primary_status = status
	var final_state := _predicate_snapshot("blocker")
	var blocker := {"schema":"v0436-r1h-blocker-v1", "status":status, "reason":reason, "provenance":_provenance("blocker"), "force_plan":force_plan_audit, "economy_timeline":economy_timeline, "completed_production":_player_combatants().map(func(u): return _unit_record(u)), "player_inventory":final_state.get("commanders", [])[0] if final_state.get("commanders", []).size() > 0 else {}, "enemy_inventory":final_state.get("commanders", [])[1] if final_state.get("commanders", []).size() > 1 else {}, "target_lifecycles":target_lifecycles, "surviving_entities":final_state.get("commanders", []), "resource_transactions":world.resource_transactions.duplicate(true), "navigation_state":world.navigation_runtime_snapshot(), "match_state":final_state, "last_valid_frame":last_valid_frame, "later_phases_not_run":reason}
	_save_json("r1h-blocker.json", blocker)
	_save_json("r1h-final-state.json", {"provenance":_provenance("final"), "status":status, "predicate":final_state, "predicate_sequence":predicate_sequence, "target_lifecycles":target_lifecycles, "economy_timeline":economy_timeline, "frames":frame_names})
	await _contact_sheet(true)
	push_error(status + ": " + reason)
	get_tree().quit(0)

func _contact_sheet(blocked := false) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.03,0.04,0.05))
	var thumb := Vector2i(384,216)
	for i in range(min(frame_names.size(), 25)):
		var source := Image.load_from_file(_output_path(frame_names[i]))
		if source.is_empty(): continue
		source.convert(Image.FORMAT_RGBA8)
		source.resize(thumb.x, thumb.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(source, Rect2i(0,0,thumb.x,thumb.y), Vector2i((i % 5) * thumb.x, (i / 5) * thumb.y))
	sheet.save_png(_output_path(_evidence_name("26_R1H_BLOCKER_CONTACT_SHEET.png" if blocked else "26_R1H_CONTACT_SHEET.png")))

func _competent_assault_target(target, category: String, label: String) -> Dictionary:
	var audit := _target_key(target, category)
	audit["label"] = label
	audit["initial_hp"] = float(target.hp) if is_instance_valid(target) and "hp" in target else null
	audit["maximum_hp"] = float(target.max_hp) if is_instance_valid(target) and "max_hp" in target else null
	audit["initial_position"] = _vec(target.global_position) if is_instance_valid(target) else null
	audit["force_before"] = _player_combatants().map(func(u): return _unit_record(u))
	audit["commands"] = []
	audit["reissues"] = []
	audit["retreats"] = []
	audit["hp_samples"] = []
	audit["damage_event_count_before"] = world.combat_damage_events.size() + world.building_damage_events.size()
	var army := _player_combatants()
	if army.is_empty():
		audit["terminal_disposition"] = "FAILED_E1R_NATURAL_PLAYER_DEFEAT"
		target_lifecycles.append(audit)
		return audit
	await _select_many(army)
	var move_ok: bool = rts.issue_attack_move_destination(target.global_position)
	var target_ok: bool = rts.issue_attack_target(target)
	audit.commands.append({"kind":"attack_priority", "attack_move_return":move_ok, "attack_target_return":target_ok, "target_position":_vec(target.global_position), "timestamp_ms":Time.get_ticks_msec()})
	var started_ms := Time.get_ticks_msec()
	var next_reissue := started_ms + 8000
	while Time.get_ticks_msec() - started_ms < int(COMPETENT_ASSAULT_TIMEOUT_SECONDS * 1000.0):
		if not is_instance_valid(target) or bool(target.is_dead):
			audit["terminal_disposition"] = "DESTROYED"
			break
		if not is_instance_valid(world.player_commander) or bool(world.player_commander.defeated):
			audit["terminal_disposition"] = "FAILED_E1R_NATURAL_PLAYER_DEFEAT"
			break
		var live_army := _player_combatants()
		if live_army.size() <= 3 and Time.get_ticks_msec() - started_ms > 15000:
			var hq = world.player_commander.buildings[0] if not world.player_commander.buildings.is_empty() else null
			if is_instance_valid(hq):
				await _select_many(live_army)
				for unit in live_army: unit.command_move(hq.global_position)
				audit["retreats"].append({"timestamp_ms":Time.get_ticks_msec(), "reason":"useful_fighting_strength_low", "survivors":live_army.map(func(u): return _unit_record(u))})
				audit["terminal_disposition"] = "WITHDREW_REGROUP"
				break
		audit["hp_samples"].append({"timestamp_ms":Time.get_ticks_msec(), "hp":float(target.hp), "dead":bool(target.is_dead), "force_size":live_army.size()})
		if Time.get_ticks_msec() >= next_reissue:
			var idle := live_army.filter(func(u): return int(u.state) == Unit.State.IDLE or String(u.get("_navigation_command_type")) == "")
			if not idle.is_empty():
				await _select_many(live_army)
				var retry_move: bool = rts.issue_attack_move_destination(target.global_position)
				var retry_target: bool = rts.issue_attack_target(target)
				audit["reissues"].append({"timestamp_ms":Time.get_ticks_msec(), "idle_count":idle.size(), "attack_move_return":retry_move, "attack_target_return":retry_target})
			next_reissue += 8000
		await _wait_seconds(0.5)
	if not audit.has("terminal_disposition"):
		audit["terminal_disposition"] = "INCONCLUSIVE_E1R_TIME_LIMIT"
	audit["final_valid"] = is_instance_valid(target)
	audit["final_hp"] = float(target.hp) if is_instance_valid(target) and "hp" in target else null
	audit["final_position"] = _vec(target.global_position) if is_instance_valid(target) else null
	audit["damage_event_count_after"] = world.combat_damage_events.size() + world.building_damage_events.size()
	audit["elapsed_wall_seconds"] = float(Time.get_ticks_msec() - started_ms) / 1000.0
	audit["navigation_snapshot"] = world.navigation_runtime_snapshot()
	target_lifecycles.append(audit)
	return audit

func _competent_reinforcements() -> bool:
	var hall = null
	for building in world.player_commander.buildings:
		if is_instance_valid(building) and not building.is_dead and String(building.building_id) == "barrosan_war_hall":
			hall = building
			break
	if not is_instance_valid(hall): return false
	var queue_results: Array = []
	for unit_id in ["barrosan_spear_guard", "barrosan_crag_archer", "barrosan_clan_levy", "barrosan_spear_guard", "barrosan_crag_archer", "barrosan_clan_levy"]:
		var result = {"ok":false, "reason":"not attempted"}
		var retry_deadline := Time.get_ticks_msec() + 90000
		while Time.get_ticks_msec() < retry_deadline:
			result = hall.queue_unit(unit_id)
			queue_results.append({"unit_id":unit_id, "attempt":queue_results.size() + 1, "result":result, "resources_after":world.player_commander.resources.duplicate(true), "pop_used":world.player_commander.pop_used, "reserved_pop":world.player_commander.reserved_pop})
			if bool(result.get("ok", false)): break
			await _wait_seconds(4.0)
		await get_tree().process_frame
	_save_json("reinforcement-queue-%d.json" % target_lifecycles.size(), {"provenance":_provenance("reinforcements"), "queue_results":queue_results, "source":"normal real-cost queue after a combat retreat"})
	return await _wait_until(func(): return _player_combatants().size() >= 8, 240.0)

func _capture_competent_match() -> void:
	if not await _wait_until(func(): return is_instance_valid(world) and world.game_running, 30.0): await _failure("BLOCKED_E1R_MATCH_NOT_STARTED", "production match did not start"); return
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("01_R1H_STANDARD_MATCH_START.png")
	_save_json("match-configuration.json", {"provenance":_provenance("configuration"), "observed":Match.get_config().duplicate(true), "expected":{"player_race":"barrosan", "opponent_race":"lioraen", "difficulty":"easy", "start_resources":"rich", "map":"hollowspan", "mode":"skirmish", "victory":"conquest", "game_speed":2.0}})
	if not await _wait_until(func(): return world.is_navigation_ready(), 30.0): await _failure("BLOCKED_E1R_NAVIGATION_NOT_READY", "navigation did not become ready"); return
	await _save("02_R1H_WORKERS_RESUME_ECONOMY.png")
	if not await _normal_production_setup(): await _failure("BLOCKED_E1R_ECONOMY_OR_PRODUCTION_STALLED", "normal construction, two-resource gathering, housing, or mixed production could not progress"); return
	await _save("05_R1H_FORCE_READINESS_TRUE.png")
	_record_economy("force_readiness")
	_save_json("force-readiness.json", {"provenance":_provenance("readiness"), "ready":true, "hero_included":is_instance_valid(world.player_commander.hero_ref) and not world.player_commander.hero_ref.is_dead, "force":_player_combatants().map(func(u): return _unit_record(u)), "total_hp":_player_combatants().reduce(func(sum, u): return sum + float(u.hp), 0.0), "population":_commander_record(world.player_commander), "queue_capability":_queue_record(world.player_commander.buildings.filter(func(b): return b.building_id == "barrosan_war_hall")[0])})
	var cycle_audits: Array = []
	var won := false
	for cycle in range(3):
		var cycle_audit := {"cycle":cycle + 1, "started_force":_player_combatants().map(func(u): return _unit_record(u)), "targets":[]}
		var enemy_units := _enemy_combatants().duplicate()
		for target in enemy_units:
			if not is_instance_valid(target) or target.is_dead: continue
			var audit := await _competent_assault_target(target, "combatant", "cycle_%d_enemy_unit" % (cycle + 1))
			cycle_audit["targets"].append(audit)
			if String(audit.get("terminal_disposition", "")) in ["WITHDREW_REGROUP", "FAILED_E1R_NATURAL_PLAYER_DEFEAT"]: break
		if is_instance_valid(world.player_commander) and bool(world.player_commander.defeated): await _failure("FAILED_E1R_NATURAL_PLAYER_DEFEAT", "player HQ or rebuild capability was naturally eliminated"); return
		if _enemy_combatants().is_empty():
			var hqs := _enemy_buildings().filter(func(b): return bool(b.def.get("is_hq", false)))
			if not hqs.is_empty() and _player_combatants().size() >= 4:
				var hq_audit := await _competent_assault_target(hqs[0], "building", "cycle_%d_enemy_hq" % (cycle + 1))
				cycle_audit["targets"].append(hq_audit)
				if String(hq_audit.get("terminal_disposition", "")) == "DESTROYED":
					for building in _enemy_buildings():
						if not is_instance_valid(building) or building.is_dead: continue
						var building_audit := await _competent_assault_target(building, "building", "cycle_%d_remaining_building" % (cycle + 1))
						cycle_audit["targets"].append(building_audit)
						if String(building_audit.get("terminal_disposition", "")) != "DESTROYED": break
					for worker in _enemy_workers():
						if not is_instance_valid(worker) or worker.is_dead: continue
						var worker_audit := await _competent_assault_target(worker, "worker", "cycle_%d_rebuild_worker" % (cycle + 1))
						cycle_audit["targets"].append(worker_audit)
						if String(worker_audit.get("terminal_disposition", "")) != "DESTROYED": break
					var final_snapshot := _predicate_snapshot("cycle_%d_predicate" % (cycle + 1))
					var enemy_state: Dictionary = final_snapshot.get("commanders", [])[1]
					if bool(enemy_state.get("no_hq", false)) and bool(enemy_state.get("no_buildings", false)) and bool(enemy_state.get("no_workers", false)):
						won = true
						break
		cycle_audit["ended_force"] = _player_combatants().map(func(u): return _unit_record(u))
		cycle_audits.append(cycle_audit)
		_save_json("e1r-assault-cycles.json", {"provenance":_provenance("assault_cycles"), "cycles":cycle_audits, "strategy":"competent public-action play: clear threats, regroup after losses, rebuild, then pressure structures and workers"})
		if won: break
		if cycle < 2:
			if not await _competent_reinforcements(): await _failure("INCONCLUSIVE_E1R_TIME_LIMIT", "normal production could not rebuild a useful fighting force after losses"); return
	if not won: await _failure("INCONCLUSIVE_E1R_TIME_LIMIT", "competent natural player strategy made real progress but did not reach conquest within three bounded offensive cycles"); return
	var final_predicate := _predicate_snapshot("final_conquest_predicate")
	await _save("17_R1H_FINAL_CONQUEST_PREDICATE.png")
	if not await _wait_until(func(): return world.match_ended, 120.0): await _failure("BLOCKED_E1R_VICTORY_TERMINAL", "natural conquest predicate did not end the match"); return
	if not bool(world.result_snapshot.get("victory", false)) or String(world.result_snapshot.get("reason", "")) != "Conquest": await _failure("BLOCKED_E1R_RESULT_REASON", "natural end did not produce Conquest victory"); return
	await _save("18_R1H_GENUINE_VICTORY.png")
	var layer = root_node.hud.get("_gameover_layer")
	var continue_button := _find_button(layer, "Continue") if is_instance_valid(layer) else null
	var replay_button := _find_button(layer, "Play Again") if is_instance_valid(layer) else null
	_save_json("result-state-audit.json", {"provenance":_provenance("result"), "observed":{"match_ended":world.match_ended, "game_running":world.game_running, "result":world.result_snapshot.duplicate(true), "labels":_labels(layer) if is_instance_valid(layer) else [], "continue_exists":is_instance_valid(continue_button), "replay_exists":is_instance_valid(replay_button)}})
	await _save("19_R1H_RESULT_UI.png")
	if session == "A" and is_instance_valid(continue_button) and not continue_button.disabled:
		_save_json("continue-action-audit.json", {"provenance":_provenance("continue"), "observed":await _click_button(continue_button)})
		await _wait_seconds(3.0)
		await _save("22_R1H_CONTINUE_DESTINATION.png")
		await _contact_sheet()
		get_tree().quit(0)
		return
	if session == "B" and is_instance_valid(replay_button) and not replay_button.disabled:
		_save_json("play-again-action-audit.json", {"provenance":_provenance("play_again"), "observed":await _click_button(replay_button)})
		if not await _wait_until(func(): return replay_captured, 45.0): await _failure("BLOCKED_E1R_REPLAY_NOT_FRESH", "Play Again did not produce a fresh captured scene"); return
	await _contact_sheet()
	get_tree().quit(0)

func _tutorial_snapshot() -> Dictionary:
	if is_instance_valid(root_node) and is_instance_valid(root_node.tutorial) and root_node.tutorial.has_method("get_state_snapshot"):
		return root_node.tutorial.get_state_snapshot()
	return {}

func _wait_tutorial_step(expected_index: int, timeout: float = 90.0) -> bool:
	return await _wait_until(func(): return int(_tutorial_snapshot().get("step_index", 0)) == expected_index, timeout)

func _capture_e3r_match() -> void:
	if not await _wait_until(func(): return is_instance_valid(world) and world.game_running, 30.0): await _failure("BLOCKED_E3R_TUTORIAL_NOT_STARTED", "normal menu tutorial entry did not reach a live production scene"); return
	if not await _wait_until(func(): return world.is_navigation_ready(), 30.0): await _failure("BLOCKED_E3R_TUTORIAL_NAVIGATION", "tutorial navigation did not become ready"); return
	var timeline: Array = []
	var config := Match.get_config().duplicate(true)
	_save_json("e3r-tutorial-manifest.json", {"schema":"v0436-e3r-real-tutorial-v1", "provenance":_provenance("normal_menu_tutorial_entry"), "menu_entry":"How to Play button pressed through the normal main menu", "configuration":config, "timeline":timeline})
	var tutorial_before := _tutorial_snapshot()
	# Step 1: real camera input, not elapsed time.
	Input.action_press("cam_right")
	await _wait_seconds(0.75)
	Input.action_release("cam_right")
	if not await _wait_tutorial_step(2, 30.0): await _failure("BLOCKED_E3R_STEP_1_REAL_EVENT_NOT_OBSERVED", "camera focus did not move from the normal camera input"); return
	await _save_e3r_frame("02_STEP1_CAMERA.png", "02_STEP1_CAMERA.png")
	timeline.append({"step":1, "before":tutorial_before, "after":_tutorial_snapshot(), "real_action":"cam_right input", "camera_after":_vec(rts.cam_pivot.global_position)})
	# Step 2: actual RTS selection signal.
	var hero = world.player_commander.hero_ref
	var workers: Array = world.player_commander.units.filter(func(u): return is_instance_valid(u) and not u.is_dead and bool(u.is_worker))
	var worker = workers.front() if not workers.is_empty() else null
	var selectable = hero if is_instance_valid(hero) and not hero.is_dead else worker
	if not is_instance_valid(selectable): await _failure("BLOCKED_E3R_STEP_2_REAL_EVENT_NOT_OBSERVED", "no player-owned unit was available"); return
	await _select_many([selectable])
	if not await _wait_tutorial_step(3, 30.0): await _failure("BLOCKED_E3R_STEP_2_REAL_EVENT_NOT_OBSERVED", "selection did not advance the tutorial"); return
	await _save_e3r_frame("03_STEP2_SELECT.png", "03_STEP2_SELECT.png")
	timeline.append({"step":2, "before":tutorial_before, "after":_tutorial_snapshot(), "real_action":"select player unit", "runtime_id":str(selectable.get_instance_id()), "unit_id":selectable.unit_id, "team":selectable.team})
	# Step 3: real gather order plus a real extraction event.
	var food = _resources_by_kind().get("food")
	if not is_instance_valid(worker) or not is_instance_valid(food): await _failure("BLOCKED_E3R_STEP_3_REAL_EVENT_NOT_OBSERVED", "worker or food node unavailable"); return
	var extraction_before: int = world.resource_extractions.size()
	await _select_many([worker])
	worker.command_gather(food)
	if not await _wait_until(func(): return world.resource_extractions.size() > extraction_before, 60.0): await _failure("BLOCKED_E3R_STEP_3_REAL_EVENT_NOT_OBSERVED", "worker entered no truthful extraction event"); return
	if not await _wait_tutorial_step(4, 30.0): await _failure("BLOCKED_E3R_STEP_3_REAL_EVENT_NOT_OBSERVED", "real extraction did not advance the tutorial"); return
	await _save_e3r_frame("04_STEP3_EXTRACTION.png", "04_STEP3_GATHER_EXTRACTION.png")
	timeline.append({"step":3, "before":tutorial_before, "after":_tutorial_snapshot(), "real_action":"worker.command_gather(food)", "real_event":world.resource_extractions.back()})
	# Step 4: normal placement API, real cost, worker construction, foundation then completion.
	var croft_pos := _find_building_position("barrosan_clan_croft")
	var croft = world.place_building("barrosan_clan_croft", 0, croft_pos) if croft_pos != Vector3.INF else null
	if not is_instance_valid(croft): await _failure("BLOCKED_E3R_STEP_4_REAL_EVENT_NOT_OBSERVED", "normal Croft placement was rejected"); return
	worker.command_build(croft)
	if not _e3r_repair_capture(): await _save("05_STEP4_FOUNDATION.png")
	if not await _wait_until(func(): return bool(croft.is_built), 90.0): await _failure("BLOCKED_E3R_STEP_4_REAL_EVENT_NOT_OBSERVED", "placed Croft did not complete construction"); return
	if not await _wait_tutorial_step(5, 30.0): await _failure("BLOCKED_E3R_STEP_4_REAL_EVENT_NOT_OBSERVED", "completed construction did not advance the tutorial"); return
	await _save_e3r_frame("05_STEP4_BUILDING_COMPLETE.png", "06_STEP4_BUILD_COMPLETE.png")
	timeline.append({"step":4, "before":tutorial_before, "after":_tutorial_snapshot(), "real_action":"place Croft and worker.command_build", "real_event":world.get_v0431_construction_audit().get("construction_events", []).back(), "building_id":croft.building_id, "is_built":croft.is_built})
	# Step 5: complete a War Hall, queue through the real production API, then wait for a new unit.
	var hall_pos := _find_building_position("barrosan_war_hall")
	var hall = world.place_building("barrosan_war_hall", 0, hall_pos) if hall_pos != Vector3.INF else null
	if not is_instance_valid(hall): await _failure("BLOCKED_E3R_STEP_5_REAL_EVENT_NOT_OBSERVED", "normal War Hall placement was rejected"); return
	for unit in world.player_commander.units:
		if is_instance_valid(unit) and bool(unit.is_worker): unit.command_build(hall)
	if not await _wait_until(func(): return bool(hall.is_built), 120.0): await _failure("BLOCKED_E3R_STEP_5_REAL_EVENT_NOT_OBSERVED", "War Hall did not complete construction"); return
	var army_before: int = _army_count()
	var queue_result = hall.queue_unit("barrosan_crag_archer")
	if not _e3r_repair_capture(): await _save("07_STEP5_TRAINING.png")
	if not await _wait_until(func(): return _army_count() > army_before, 120.0): await _failure("BLOCKED_E3R_STEP_5_REAL_EVENT_NOT_OBSERVED", "queued military unit did not complete training"); return
	if not await _wait_tutorial_step(6, 30.0): await _failure("BLOCKED_E3R_STEP_5_REAL_EVENT_NOT_OBSERVED", "newly trained unit did not advance the tutorial"); return
	await _save_e3r_frame("06_STEP5_UNIT_COMPLETE.png", "08_STEP5_UNIT_COMPLETE.png")
	timeline.append({"step":5, "before":tutorial_before, "after":_tutorial_snapshot(), "real_action":"War Hall queue_unit", "queue_result":queue_result, "new_army_count":_army_count()})
	# Step 6: a real hero move order with measurable position change.
	if not is_instance_valid(hero) or hero.is_dead: await _failure("BLOCKED_E3R_STEP_6_REAL_EVENT_NOT_OBSERVED", "hero unavailable"); return
	await _select_many([hero])
	var hero_before: Vector3 = hero.global_position
	hero.command_move(hero_before + Vector3(10.0, 0.0, 0.0))
	if not await _wait_tutorial_step(7, 90.0): await _failure("BLOCKED_E3R_STEP_6_REAL_EVENT_NOT_OBSERVED", "hero did not move through a real command"); return
	await _save_e3r_frame("07_STEP6_HERO_COMMAND.png", "09_STEP6_HERO_COMMAND.png")
	timeline.append({"step":6, "before":tutorial_before, "after":_tutorial_snapshot(), "real_action":"hero.command_move", "position_before":_vec(hero_before), "position_after":_vec(hero.global_position)})
	# Step 7: real attack orders, one frame before damage, then real damage evidence.
	var enemies := _enemy_combatants()
	var own := _player_combatants()
	if enemies.is_empty() or own.is_empty(): await _failure("BLOCKED_E3R_STEP_7_REAL_EVENT_NOT_OBSERVED", "combat inventory unavailable"); return
	var damage_before: int = world.combat_damage_events.size()
	await _select_many(own)
	var attack_move_ok: bool = rts.issue_attack_move_destination(enemies[0].global_position)
	var attack_target_ok: bool = rts.issue_attack_target(enemies[0])
	if not _e3r_repair_capture(): await _save("10_STEP7_ATTACK.png")
	if not await _wait_until(func(): return world.combat_damage_events.size() > damage_before, 120.0): await _failure("BLOCKED_E3R_STEP_7_REAL_EVENT_NOT_OBSERVED", "real attack orders produced no damage event"); return
	if not await _wait_tutorial_step(8, 30.0): await _failure("BLOCKED_E3R_STEP_7_REAL_EVENT_NOT_OBSERVED", "real combat damage did not advance the tutorial"); return
	await _save_e3r_frame("08_STEP7_REAL_DAMAGE.png", "11_STEP7_REAL_DAMAGE.png")
	timeline.append({"step":7, "before":tutorial_before, "after":_tutorial_snapshot(), "real_action":"attack-move and attack-target", "attack_move_return":attack_move_ok, "attack_target_return":attack_target_ok, "real_event":world.combat_damage_events.back()})
	# Step 8: normal movement into the actual Lume capture zone and natural ownership.
	var points: Array = world.get_tree().get_nodes_in_group("capture_points")
	var lume = points.front() if not points.is_empty() else null
	if not is_instance_valid(lume): await _failure("BLOCKED_E3R_LUME_UNREACHABLE", "no live Lume capture point exists"); return
	await _save_e3r_frame("09_STEP8_TARGET_LUME.png", "12_STEP8_LUME_TARGET.png")
	var lume_before: Dictionary = lume.get_capture_snapshot() if lume.has_method("get_capture_snapshot") else {"owner_team":lume.owner_team, "progress":lume._progress}
	for unit in _player_combatants():
		unit.command_move(lume.global_position)
	if not await _wait_until(func(): return _player_combatants().filter(func(u): return is_instance_valid(u) and u.global_position.distance_to(lume.global_position) <= 7.5).size() > 0, 120.0): await _failure("BLOCKED_E3R_LUME_UNREACHABLE", "player units did not reach the Lume capture zone"); return
	await _save_e3r_frame("10_STEP8_UNITS_ENTER_RADIUS.png", "13_STEP8_UNITS_IN_CAPTURE_ZONE.png")
	if not _e3r_repair_capture():
		await _step8_telemetry(lume, 15.0)
		if not await _wait_until(func(): return float(lume._progress) > 0.05, 30.0): await _failure("BLOCKED_E3R_LUME_OWNERSHIP_NOT_RECOGNIZED", "Lume capture progress never began"); return
		await _save("14_STEP8_CAPTURE_PROGRESS.png")
	else:
		if not await _wait_until(func(): return float(lume._progress) > 0.05, 30.0): await _failure("BLOCKED_E3R_STEP8_PROGRESS_NOT_STARTED", "real Lume progress did not begin"); return
		await _save("11_STEP8_PROGRESS_LOW.png")
		await _step8_telemetry(lume, 15.0)
		if not await _wait_until(func(): return float(lume._progress) >= 0.5 or int(lume.owner_team) == int(world.player_commander.team), 30.0): await _failure("BLOCKED_E3R_STEP8_PROGRESS_NOT_RECORDED", "real Lume progress did not reach the high-progress checkpoint"); return
		await _save("12_STEP8_PROGRESS_HIGH.png")
	DisplayServer.window_set_size(Vector2i(1366, 768))
	await _wait_seconds(1.0)
	await _save_e3r_frame("17_1366_STEP8.png", "18_1366_TUTORIAL_ACTIVE.png")
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	await _wait_seconds(1.0)
	if not await _wait_until(func(): return int(lume.owner_team) == int(world.player_commander.team), 120.0): await _failure("BLOCKED_E3R_LUME_OWNERSHIP_NOT_RECOGNIZED", "Lume ownership did not transition through normal CapturePoint physics"); return
	if not await _wait_tutorial_step(9, 30.0): await _failure("BLOCKED_E3R_LUME_OWNERSHIP_NOT_RECOGNIZED", "tutorial did not observe the natural Lume ownership event"); return
	if _e3r_repair_capture():
		await _save("13_STEP8_OWNER_TRANSITION.png")
		await _save("14_STEP8_LUME_OWNED.png")
		await _save("15_TUTORIAL_COMPLETE.png")
	else:
		await _save("15_STEP8_LUME_OWNED.png")
		await _save("16_TUTORIAL_COMPLETE.png")
	DisplayServer.window_set_size(_e3r_completion_resolution())
	await _wait_seconds(1.0)
	await _save_e3r_frame("18_1366_TUTORIAL_COMPLETE.png", "19_1366_TUTORIAL_COMPLETE.png")
	var lume_after_snapshot: Dictionary = lume.get_capture_snapshot() if lume.has_method("get_capture_snapshot") else {"owner_team":lume.owner_team, "progress":lume._progress}
	await _wait_seconds(0.5)
	var completion_button = root_node.tutorial.get_completion_button() if root_node.tutorial.has_method("get_completion_button") else null
	if not is_instance_valid(completion_button): await _failure("BLOCKED_E3R_COMPLETION_FLOW_BROADER_THAN_SCOPE", "completed tutorial did not expose a return action"); return
	if e3r_completion_diagnostic:
		completion_button.pressed.connect(_on_diagnostic_completion_pressed)
		var ui_before_click := _completion_ui_diagnostic(completion_button)
		_save_json("e3r-completion-ui-before-click.json", ui_before_click)
		_save_json("e3r-completion-native-click-ready.json", {"status":"READY_FOR_NATIVE_CLICK", "ui":ui_before_click, "source_sha":OS.get_environment("ASCENDANT_V0436_R1H_SOURCE_SHA")})
	var return_record: Dictionary = {}
	if e3r_completion_diagnostic:
		return_record = {"input_route":"native OS mouse click at actual Return to Main Menu global rect center", "button_path":String(completion_button.get_path()), "button_rect":_completion_ui_diagnostic(completion_button).get("button_rect", {})}
		await _wait_seconds(3.0)
	else:
		return_record = await _click_button(completion_button)
	if not await _wait_until(func(): return is_instance_valid(get_tree().current_scene) and get_tree().current_scene.name == "MainMenu", 2.0):
		if e3r_completion_diagnostic:
			var failed_ui := _completion_ui_diagnostic(completion_button)
			failed_ui["return_record"] = return_record
			failed_ui["input_events"] = e3r_input_events.duplicate(true)
			failed_ui["completion_pressed_count_after"] = e3r_completion_pressed_count
			_save_json("e3r-completion-input-diagnostic.json", failed_ui)
			await _failure("BLOCKED_E3R_COMPLETION_INPUT_OBSERVABILITY", "player-equivalent routed click did not reach the normal menu; diagnostic evidence written"); return
		return_record["input_fallback"] = "actual completion Button pressed signal after both routed mouse paths produced no transition"
		completion_button.pressed.emit()
		await get_tree().process_frame
	if not await _wait_until(func(): return is_instance_valid(get_tree().current_scene) and get_tree().current_scene.name == "MainMenu", 30.0): await _failure("BLOCKED_E3R_COMPLETION_FLOW_BROADER_THAN_SCOPE", "tutorial return action did not reach the main menu"); return
	await _save_e3r_frame("16_RETURN_TO_MAIN_MENU.png", "17_TUTORIAL_RETURN_MENU.png")
	if e3r_completion_diagnostic:
		_save_json("e3r-completion-success.json", {"status":"NATIVE_COMPLETION_RETURNED_TO_MAIN_MENU", "completion_pressed_count":e3r_completion_pressed_count, "input_events":e3r_input_events.duplicate(true), "scene_after":String(get_tree().current_scene.name), "resolution":_e3r_completion_resolution()})
	_save_json("e3r-tutorial-manifest.json", {"schema":"v0436-e3r-real-tutorial-v1", "provenance":_provenance("real_golden_path"), "configuration":config, "tutorial_entry":"normal MainMenu How to Play button", "timeline":timeline, "lume_before":lume_before, "lume_after":lume_after_snapshot, "return_action":return_record, "tutorial_state_before_return":_tutorial_snapshot(), "public_actions_only":true, "state_injection":false})
	await _contact_sheet()
	get_tree().quit(0)

func _capture_tutorial_match() -> void:
	if not await _wait_until(func(): return is_instance_valid(world) and world.game_running, 30.0): await _failure("BLOCKED_E3_TUTORIAL_NOT_STARTED", "tutorial production scene did not start"); return
	if not await _wait_until(func(): return world.is_navigation_ready(), 30.0): await _failure("BLOCKED_E3_TUTORIAL_NAVIGATION", "tutorial navigation did not become ready"); return
	var audit: Array = []
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("01_R1H_TUTORIAL_START.png")
	await _wait_until(func(): return world.match_time > 4.0, 15.0)
	await _save("02_R1H_TUTORIAL_CAMERA.png")
	audit.append({"step":1, "name":"camera", "condition":"match_time > 4", "observed_match_time":world.match_time, "frame":last_valid_frame})
	var hero = world.player_commander.hero_ref
	var worker = world.player_commander.units.filter(func(u): return is_instance_valid(u) and bool(u.is_worker)).front() if not world.player_commander.units.filter(func(u): return is_instance_valid(u) and bool(u.is_worker)).is_empty() else null
	var selectable = hero if is_instance_valid(hero) and not hero.is_dead else worker
	if not is_instance_valid(selectable): await _failure("BLOCKED_E3_TUTORIAL_SELECTION", "no player unit was available for tutorial selection"); return
	await _select_many([selectable])
	await _wait_until(func(): return rts.selected.size() > 0, 10.0)
	await _save("03_R1H_TUTORIAL_SELECT.png")
	audit.append({"step":2, "name":"select", "selected_count":rts.selected.size(), "frame":last_valid_frame})
	var resources := _resources_by_kind()
	var gather_node = resources.get("food") if is_instance_valid(resources.get("food")) else resources.get("timber")
	if not is_instance_valid(worker) or not is_instance_valid(gather_node): await _failure("BLOCKED_E3_TUTORIAL_GATHER", "worker or resource node was unavailable"); return
	await _select_many([worker])
	worker.command_gather(gather_node)
	await _wait_until(func(): return int(worker.state) == Unit.State.GATHERING, 20.0)
	await _save("04_R1H_TUTORIAL_GATHER.png")
	audit.append({"step":3, "name":"gather", "worker_state":int(worker.state), "resource_kind":String(gather_node.resource_kind), "frame":last_valid_frame})
	var croft_pos := _find_building_position("barrosan_clan_croft")
	var croft = world.place_building("barrosan_clan_croft", 0, croft_pos) if croft_pos != Vector3.INF else null
	if not is_instance_valid(croft): await _failure("BLOCKED_E3_TUTORIAL_BUILD", "tutorial building placement was rejected"); return
	worker.command_build(croft)
	await _wait_until(func(): return is_instance_valid(croft), 15.0)
	await _save("05_R1H_TUTORIAL_BUILD.png")
	audit.append({"step":4, "name":"build", "building_id":String(croft.building_id), "built":bool(croft.is_built), "frame":last_valid_frame})
	var hall_pos := _find_building_position("barrosan_war_hall")
	var hall = world.place_building("barrosan_war_hall", 0, hall_pos) if hall_pos != Vector3.INF else null
	if not is_instance_valid(hall): await _failure("BLOCKED_E3_TUTORIAL_TRAIN", "tutorial military building placement was rejected"); return
	for unit in world.player_commander.units:
		if is_instance_valid(unit) and bool(unit.is_worker): unit.command_build(hall)
	if not await _wait_until(func(): return is_instance_valid(hall) and bool(hall.is_built), 90.0): await _failure("BLOCKED_E3_TUTORIAL_TRAIN", "tutorial military building did not complete"); return
	var queue_result = hall.queue_unit("barrosan_crag_archer")
	await _save("06_R1H_TUTORIAL_TRAIN.png")
	audit.append({"step":5, "name":"train", "queue_result":queue_result, "queue_size":hall.queue.size(), "frame":last_valid_frame})
	if is_instance_valid(hero) and not hero.is_dead:
		await _select_many([hero])
		await _wait_until(func(): return rts.selected.has(hero), 10.0)
	await _save("07_R1H_TUTORIAL_HERO.png")
	audit.append({"step":6, "name":"hero", "selected":is_instance_valid(hero) and rts.selected.has(hero), "frame":last_valid_frame})
	var enemy_units := _enemy_combatants()
	var own_combatants := _player_combatants()
	if enemy_units.is_empty() or own_combatants.is_empty(): await _failure("BLOCKED_E3_TUTORIAL_COMBAT", "tutorial combat inventory was unavailable"); return
	await _select_many(own_combatants)
	var attack_move_ok: bool = rts.issue_attack_move_destination(enemy_units[0].global_position)
	var attack_target_ok: bool = rts.issue_attack_target(enemy_units[0])
	await _wait_until(func(): return int(world.kills_by_player) > 0, 120.0)
	await _save("08_R1H_TUTORIAL_COMBAT.png")
	audit.append({"step":7, "name":"combat", "attack_move_return":attack_move_ok, "attack_target_return":attack_target_ok, "kills_by_player":world.kills_by_player, "frame":last_valid_frame})
	await _wait_seconds(4.0)
	await _save("09_R1H_TUTORIAL_LUME.png")
	audit.append({"step":8, "name":"final_lume", "match_time":world.match_time, "kills_by_player":world.kills_by_player, "frame":last_valid_frame})
	_save_json("e3-tutorial-audit.json", {"provenance":_provenance("tutorial"), "steps":audit, "tutorial_step":int(root_node.tutorial.get("_step")) if is_instance_valid(root_node.tutorial) else null, "world":_predicate_snapshot("tutorial_complete"), "public_actions_only":true, "state_injection":false})
	await _contact_sheet()
	get_tree().quit(0)

func _capture_match() -> void:
	if f1_mode:
		await _f1_production_capture()
		return
	if competent_mode:
		await _capture_competent_match()
		return
	if e3r_mode:
		await _capture_e3r_match()
		return
	if tutorial_mode:
		await _capture_tutorial_match()
		return
	if not await _wait_until(func(): return is_instance_valid(world) and world.game_running, 30.0): await _failure("BLOCKED_R1H_CAPTURE_STRATEGY_INCONCLUSIVE", "production match did not start"); return
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("01_R1H_STANDARD_MATCH_START.png")
	_save_json("match-configuration.json", {"provenance":_provenance("configuration"), "observed":Match.get_config().duplicate(true), "expected":{"player_race":"barrosan","opponent_race":"lioraen","difficulty":"easy","start_resources":"standard","map":"hollowspan","mode":"skirmish","victory":"conquest","game_speed":2.0}})
	if not await _wait_until(func(): return world.is_navigation_ready(), 30.0): await _failure("BLOCKED_R1H_TARGET_UNREACHABLE", "navigation did not become ready"); return
	await _save("02_R1H_WORKERS_RESUME_ECONOMY.png")
	if not await _normal_production_setup(): await _failure("BLOCKED_R1H_STANDARD_ECONOMY_STALLED", "normal construction, worker resume, or mixed production could not progress"); return
	await _save("05_R1H_FORCE_READINESS_TRUE.png")
	await _r1i_checkpoint("01_R1I_SESSION_A_FORCE_READY.png", "06_R1I_SESSION_B_FORCE_READY.png")
	_record_economy("force_readiness")
	_save_json("force-readiness.json", {"provenance":_provenance("readiness"), "ready":true, "hero_included":is_instance_valid(world.player_commander.hero_ref) and not world.player_commander.hero_ref.is_dead, "force":_player_combatants().map(func(u): return _unit_record(u)), "total_hp":_player_combatants().reduce(func(sum, u): return sum + float(u.hp), 0.0), "population":_commander_record(world.player_commander), "resources":world.player_commander.resources.duplicate(true), "queue_capability":_queue_record(world.player_commander.buildings.filter(func(b): return b.building_id == "barrosan_war_hall")[0])})
	var enemies := _enemy_combatants()
	await _focus(enemies[0].global_position if not enemies.is_empty() else world.commanders[1].buildings[0].global_position, 30.0)
	await _save("06_R1H_ENEMY_DEFENDER_INVENTORY.png")
	_save_json("enemy-defender-inventory.json", {"provenance":_provenance("enemy_inventory"), "units":_enemy_combatants().map(func(u): return _unit_record(u)), "buildings":_enemy_buildings().map(func(b): return _building_record(b))})
	if enemies.is_empty(): await _failure("BLOCKED_R1H_TARGET_UNREACHABLE", "enemy defender inventory was empty"); return
	await _save("07_R1H_WAVE_ONE_COMMAND.png")
	await _r1i_checkpoint("02_R1I_SESSION_A_TARGET_ORDER.png", "07_R1I_SESSION_B_HERO_FOCUS_COMMAND.png")
	var wave_one: Array = []
	for target in enemies:
		if not is_instance_valid(target) or target.is_dead: continue
		var audit := await _assault_target(target, "combatant", "wave_one_defender")
		wave_one.append(audit)
		if wave_one.size() == 1: await _r1i_checkpoint("04_R1I_SESSION_A_CASUALTY_STATE.png", "09_R1I_SESSION_B_CASUALTY_STATE.png")
		elif wave_one.size() == 2: await _r1i_checkpoint("03_R1I_SESSION_A_HERO_CONTACT.png", "08_R1I_SESSION_B_HERO_FOCUS_CONTACT.png")
		if String(audit.get("terminal_disposition", "")).begins_with("BLOCKED_R1H_"): break
	await _save("08_R1H_WAVE_ONE_COMBAT.png")
	_save_json("wave-one-audit.json", {"provenance":_provenance("wave_one"), "strategy":"eliminate active enemy combatants before buildings", "targets":wave_one, "remaining_enemy_combatants":_enemy_combatants().map(func(u): return _unit_record(u)), "player_force":_player_combatants().map(func(u): return _unit_record(u))})
	await _save("09_R1H_WAVE_ONE_TERMINAL_STATE.png")
	await _r1i_checkpoint("05_R1I_SESSION_A_TERMINAL.png", "10_R1I_SESSION_B_TERMINAL.png")
	if _player_combatants().is_empty(): await _failure("BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED", "prepared normal mixed force was eliminated in wave one"); return
	if not _enemy_combatants().is_empty(): await _failure("BLOCKED_R1H_CAPTURE_STRATEGY_INCONCLUSIVE", "wave one did not clear the live defender inventory within the bounded assault budget"); return
	var hqs := _enemy_buildings().filter(func(b): return bool(b.def.get("is_hq", false)))
	if hqs.is_empty(): await _failure("BLOCKED_R1H_TARGET_UNREACHABLE", "enemy HQ inventory was absent after defender phase"); return
	var hq_audit := await _assault_target(hqs[0], "building", "wave_one_enemy_hq")
	_save_json("enemy-hq-lifecycle.json", hq_audit)
	if String(hq_audit.get("terminal_disposition", "")) != "DESTROYED": await _failure(String(hq_audit.get("terminal_disposition", "BLOCKED_R1H_CAPTURE_STRATEGY_INCONCLUSIVE")), "enemy HQ survived the prepared bounded assault"); return
	var buildings := _enemy_buildings()
	for building in buildings:
		if not is_instance_valid(building) or building.is_dead: continue
		var building_audit := await _assault_target(building, "building", "wave_one_remaining_building")
		_save_json("building-lifecycle-%s.json" % String(building.building_id), building_audit)
		if String(building_audit.get("terminal_disposition", "")) != "DESTROYED": await _failure(String(building_audit.get("terminal_disposition", "BLOCKED_R1H_CAPTURE_STRATEGY_INCONCLUSIVE")), "remaining enemy building survived"); return
	var workers := _enemy_workers()
	for worker in workers:
		if not is_instance_valid(worker) or worker.is_dead: continue
		var worker_audit := await _assault_target(worker, "worker", "wave_one_rebuild_worker")
		_save_json("worker-lifecycle-%s.json" % String(worker.unit_id), worker_audit)
		if String(worker_audit.get("terminal_disposition", "")) != "DESTROYED": await _failure(String(worker_audit.get("terminal_disposition", "BLOCKED_R1H_CAPTURE_STRATEGY_INCONCLUSIVE")), "rebuild-capable enemy worker survived"); return
	var final_predicate := _predicate_snapshot("final_conquest_predicate")
	await _save("17_R1H_FINAL_CONQUEST_PREDICATE.png")
	var enemy_state: Dictionary = final_predicate.get("commanders", [])[1]
	if not bool(enemy_state.get("no_hq", false)) or not bool(enemy_state.get("no_buildings", false)) or not bool(enemy_state.get("no_workers", false)): await _failure("BLOCKED_R1H_PREDICATE_TRUE_COMMANDER_NOT_DEFEATED", "final natural conquest predicate remained false"); return
	if not await _wait_until(func(): return world.match_ended, 120.0): await _failure("BLOCKED_R1H_DEFEATED_TEAM_NOT_TRIGGERING_END_GAME", "natural terminal predicate did not end the match"); return
	if not bool(world.result_snapshot.get("victory", false)) or String(world.result_snapshot.get("reason", "")) != "Conquest": await _failure("BLOCKED_R1H_RESULT_REASON_INCORRECT", "natural end did not produce Conquest victory"); return
	await _save("18_R1H_GENUINE_VICTORY.png")
	var layer = root_node.hud.get("_gameover_layer")
	var continue_button := _find_button(layer, "Continue") if is_instance_valid(layer) else null
	var replay_button := _find_button(layer, "Play Again") if is_instance_valid(layer) else null
	_save_json("result-state-audit.json", {"provenance":_provenance("result"), "observed":{"match_ended":world.match_ended,"game_running":world.game_running,"result":world.result_snapshot.duplicate(true),"labels":_labels(layer) if is_instance_valid(layer) else [],"continue_exists":is_instance_valid(continue_button),"replay_exists":is_instance_valid(replay_button)}})
	await _save("19_R1H_RESULT_UI.png")
	var freeze_before := _predicate_snapshot("freeze_before"); await _wait_seconds(3.0); var freeze_after := _predicate_snapshot("freeze_after")
	_save_json("freeze-audit.json", {"provenance":_provenance("freeze"), "before":freeze_before, "after":freeze_after, "combat_damage_count":world.combat_damage_events.size(), "resource_transaction_count":world.resource_transactions.size()})
	await _save("20_R1H_MATCH_FROZEN.png")
	if session == "A":
		if not is_instance_valid(continue_button) or continue_button.disabled: await _failure("BLOCKED_R1H_CONTINUE_ACTION_FAILED", "enabled Continue button absent"); return
		await _save("21_R1H_CONTINUE_BUTTON.png")
		var audit := await _click_button(continue_button); await _wait_seconds(3.0); audit["destination_scene"] = get_tree().current_scene.scene_file_path if is_instance_valid(get_tree().current_scene) else ""
		_save_json("continue-action-audit.json", {"provenance":_provenance("continue"), "observed":audit}); await _save("22_R1H_CONTINUE_DESTINATION.png"); await _contact_sheet(); get_tree().quit(0); return
	if not is_instance_valid(replay_button) or replay_button.disabled: await _failure("BLOCKED_R1H_PLAY_AGAIN_ACTION_FAILED", "enabled Play Again button absent"); return
	await _save("24_R1H_PLAY_AGAIN_BUTTON.png")
	_save_json("play-again-action-audit.json", {"provenance":_provenance("play_again"), "observed":await _click_button(replay_button)})
	if not await _wait_until(func(): return replay_captured, 45.0): await _failure("BLOCKED_R1H_REPLAY_NOT_FRESH", "Play Again did not produce a fresh captured scene"); return

func _find_button(node: Node, text: String) -> Button:
	if node is Button and String(node.text) == text: return node
	for child in node.get_children():
		var found := _find_button(child, text)
		if is_instance_valid(found): return found
	return null

func _labels(node: Node) -> Array:
	var values: Array = []
	if node is Label: values.append(String(node.text))
	for child in node.get_children(): values.append_array(_labels(child))
	return values

func _click_button(button: Button) -> Dictionary:
	var rect := button.get_global_rect()
	var record := {"path":String(button.get_path()), "text":String(button.text), "visible":button.visible, "enabled":not button.disabled, "rect":{"x":rect.position.x,"y":rect.position.y,"w":rect.size.x,"h":rect.size.y}, "input_route":"InputEventMouseButton at actual Button global rect center"}
	var press := InputEventMouseButton.new(); press.position = rect.get_center(); press.global_position = rect.get_center(); press.button_index = MOUSE_BUTTON_LEFT; press.pressed = true; get_viewport().push_input(press); await get_tree().process_frame
	var release := InputEventMouseButton.new(); release.position = rect.get_center(); release.global_position = rect.get_center(); release.button_index = MOUSE_BUTTON_LEFT; release.pressed = false; get_viewport().push_input(release)
	await get_tree().process_frame
	return record

func _capture_fresh_replay(new_root: Node) -> void:
	root_node = new_root; world = root_node.get_node_or_null("GameWorld"); rts = root_node.get_node_or_null("RTS")
	if not is_instance_valid(world) or not is_instance_valid(rts): await _failure("BLOCKED_R1H_REPLAY_NOT_FRESH", "fresh scene lacked GameWorld or RTS"); return
	await _wait_until(func(): return world.game_running, 30.0)
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("25_R1H_FRESH_REPLAY.png")
	_save_json("fresh-replay-audit.json", {"provenance":_provenance("fresh_replay"), "observed":{"new_root_runtime_id":str(new_root.get_instance_id()),"new_world_runtime_id":str(world.get_instance_id()),"match_ended":world.match_ended,"game_running":world.game_running,"result":Match.last_result.duplicate(true),"resources":world.commanders[0].resources.duplicate(true)}})
	replay_captured = true
	await _contact_sheet(); get_tree().quit(0)

func _capture_entry(p_root: Node) -> void:
	if not started:
		started = true; root_node = p_root; world = root_node.get_node("GameWorld"); rts = root_node.get_node("RTS"); await _capture_match()
	elif session == "B" and not replay_captured: await _capture_fresh_replay(p_root)

func capture_gameplay(p_root: Node) -> void: _capture_entry(p_root)
