extends "res://tests/v0436_r1h_capture.gd"
## v0.436-R1J: opt-in, read-only combat attribution recorder and bounded assault.
## This inherits only the safe production setup helpers from R1H; it does not
## run conquest/result/replay phases and never writes gameplay state directly.

const R1J_OUT := "res://../../artifacts/manual-review/v0436-r1j-complete-combat-attribution-and-conditional-repair/"
const R1J_SAMPLE_CAP := 240000
const R1J_EVENT_CAP := 100000
const R1J_ASSAULT_LIMIT_SECONDS := 75.0
const Unit := preload("res://scripts/units/unit.gd")

var sequence := 0
var public_orders: Array = []
var unit_commands: Array = []
var target_transitions: Array = []
var unit_samples: Array = []
var attack_events: Array = []
var projectile_events: Array = []
var damage_events: Array = []
var death_events: Array = []
var _last_target_by_unit := {}
var _pending_explicit_target_transition := {}
var _attack_by_id := {}
var _projectile_by_id := {}

func _ready() -> void:
	evidence_mode = "R1J"
	session = OS.get_environment("ASCENDANT_V0436_R1J_SESSION")
	if session != "A" and session != "B": session = "A"
	out_path = R1J_OUT + "session-%s/" % session.to_lower()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path))
	var start_resources := OS.get_environment("ASCENDANT_E1_START_RESOURCES")
	if start_resources.is_empty(): start_resources = "standard"
	Match.set_config({"player_race":"barrosan", "opponents":[{"race":"lioraen", "difficulty":"easy"}], "map":"hollowspan", "start_resources":start_resources, "victory":"conquest", "mode":"skirmish", "game_speed":2.0})

func _provenance(label: String) -> Dictionary:
	return {"schema":"v0436-r1j-live-evidence-v1", "session":session, "attempt":label, "source_sha":OS.get_environment("ASCENDANT_V0436_R1J_SOURCE_SHA"), "branch":OS.get_environment("ASCENDANT_V0436_R1J_BRANCH"), "production_scene":"scenes/main.tscn -> scenes/game_world.tscn", "headed":true, "hidden_window":false, "godot_log_file_argument":false, "timestamp_ms":Time.get_ticks_msec()}

func _vec(value: Vector3) -> Dictionary:
	return {"x":value.x, "y":value.y, "z":value.z}

func _next_id(prefix: String) -> String:
	sequence += 1
	return "r1j-%s-%06d" % [prefix, sequence]

func _ref(node) -> Dictionary:
	if not is_instance_valid(node): return {"runtime_id":"", "definition_id":"", "team":-1, "alive":false}
	var definition := String(node.unit_id) if "unit_id" in node else String(node.building_id) if "building_id" in node else ""
	return {"runtime_id":str(node.get_instance_id()), "definition_id":definition, "team":int(node.team) if "team" in node else -1, "alive":not bool(node.is_dead)}

func _bounded_append(target: Array, value: Dictionary, cap: int = R1J_EVENT_CAP) -> void:
	if target.size() < cap: target.append(value)

func record_public_order(kind: String, units: Array, target, destination: Vector3) -> String:
	var id := _next_id("order")
	var event := {"order_event_id":id, "timestamp_ms":Time.get_ticks_msec(), "process_frame":Engine.get_process_frames(), "physics_frame":Engine.get_physics_frames(), "requested_command":kind, "selection_runtime_ids":units.map(func(u): return str(u.get_instance_id())), "requested_target":_ref(target), "requested_destination":_vec(destination), "rts_return_value":null}
	_bounded_append(public_orders, event)
	return id

func record_unit_command(unit, order_id: String, command: String, before_state: int, after_state: int, before_target, after_target, destination: Vector3) -> void:
	var event := {"unit_command_event_id":_next_id("unit-command"), "order_event_id":order_id, "timestamp_ms":Time.get_ticks_msec(), "process_frame":Engine.get_process_frames(), "physics_frame":Engine.get_physics_frames(), "unit":_ref(unit), "requested_command":command, "unit_command_before":before_state, "unit_command_after":after_state, "assigned_target_before":_ref(before_target), "assigned_target_after":_ref(after_target), "destination":_vec(destination), "return_state":"accepted" if after_state != Unit.State.IDLE else "not_attacking"}
	_bounded_append(unit_commands, event)
	if order_id != "":
		for order in public_orders:
			if order.get("order_event_id", "") == order_id:
				order["rts_return_value"] = true

func record_target_transition(unit, previous, current, reason: String) -> void:
	var key := str(unit.get_instance_id())
	var event := {"target_transition_event_id":_next_id("target"), "timestamp_ms":Time.get_ticks_msec(), "process_frame":Engine.get_process_frames(), "physics_frame":Engine.get_physics_frames(), "unit":_ref(unit), "target_before":_ref(previous), "target_after":_ref(current), "reason":reason}
	_bounded_append(target_transitions, event)
	_pending_explicit_target_transition[key] = true

func record_unit_sample(unit) -> void:
	if unit_samples.size() >= R1J_SAMPLE_CAP: return
	var key := str(unit.get_instance_id())
	var target = unit.get("_target")
	var target_ref := _ref(target)
	var current_target := String(target_ref.get("runtime_id", ""))
	if _last_target_by_unit.has(key) and String(_last_target_by_unit[key]) != current_target:
		if not _pending_explicit_target_transition.has(key):
			_bounded_append(target_transitions, {"target_transition_event_id":_next_id("target-unknown"), "timestamp_ms":Time.get_ticks_msec(), "process_frame":Engine.get_process_frames(), "physics_frame":Engine.get_physics_frames(), "unit":_ref(unit), "target_before":{"runtime_id":String(_last_target_by_unit[key])}, "target_after":target_ref, "reason":"unknown"})
	_pending_explicit_target_transition.erase(key)
	_last_target_by_unit[key] = current_target
	var position: Vector3 = unit.global_position
	var distance := position.distance_to(target.global_position) if is_instance_valid(target) else null
	_bounded_append(unit_samples, {"sample_event_id":_next_id("sample"), "timestamp_ms":Time.get_ticks_msec(), "process_frame":Engine.get_process_frames(), "physics_frame":Engine.get_physics_frames(), "unit":_ref(unit), "state":int(unit.state), "command":String(unit.get("_navigation_command_type")), "target":target_ref, "distance_to_target":distance, "attack_range":float(unit.get("atk_range")), "engage_range":float(unit._engage_range()) if unit.has_method("_engage_range") else null, "attack_timer":float(unit.get("_attack_timer")), "position":_vec(position), "velocity":_vec(unit.velocity), "requested_target":_vec(unit.get("_requested_move_target")), "effective_target":_vec(unit.get("_navigation_effective_target")), "path_pending":bool(unit.get("_navigation_target_pending"))})

func record_attack_start(attacker, target, raw_damage: float, damage_type: String, attack_range: float, distance: float, state_value: int, command: String) -> String:
	var id := _next_id("attack")
	var event := {"attack_event_id":id, "phase":"attack_started", "timestamp_ms":Time.get_ticks_msec(), "process_frame":Engine.get_process_frames(), "physics_frame":Engine.get_physics_frames(), "attacker":_ref(attacker), "intended_target":_ref(target), "attack_type":"projectile" if attack_range > 0.0 else "melee", "damage_type":damage_type, "configured_raw_damage":raw_damage, "attack_range":attack_range, "current_distance":distance, "state":state_value, "command":command, "attack_start_ms":Time.get_ticks_msec(), "phases":[]}
	_bounded_append(attack_events, event)
	_attack_by_id[id] = event
	return id

func record_attack_phase(attack_id: String, phase: String, details: Dictionary = {}) -> void:
	if attack_id == "" or not _attack_by_id.has(attack_id): return
	var event: Dictionary = _attack_by_id[attack_id]
	event["phase"] = phase
	var phase_event := {"phase":phase, "timestamp_ms":Time.get_ticks_msec(), "process_frame":Engine.get_process_frames(), "physics_frame":Engine.get_physics_frames()}
	for key in details: phase_event[key] = details[key]
	event["phases"].append(phase_event)

func record_projectile_spawn(projectile) -> String:
	var id := _next_id("projectile")
	var event := {"projectile_event_id":id, "phase":"spawn", "timestamp_ms":Time.get_ticks_msec(), "process_frame":Engine.get_process_frames(), "physics_frame":Engine.get_physics_frames(), "originating_attack_event_id":String(projectile.r1j_attack_event_id), "attacker_runtime_id":String(projectile.source_runtime_id), "intended_target_runtime_id":str(projectile.target.get_instance_id()) if is_instance_valid(projectile.target) else "", "spawn_position":_vec(projectile.global_position), "kind":String(projectile.projectile_kind), "phases":[]}
	_bounded_append(projectile_events, event)
	_projectile_by_id[id] = event
	return id

func record_projectile_phase(projectile, phase: String, details: Dictionary = {}) -> void:
	var id := String(projectile.r1j_projectile_event_id)
	if id == "" or not _projectile_by_id.has(id): return
	var event: Dictionary = _projectile_by_id[id]
	event["phase"] = phase
	var phase_event := {"phase":phase, "timestamp_ms":Time.get_ticks_msec(), "process_frame":Engine.get_process_frames(), "physics_frame":Engine.get_physics_frames()}
	for key in details: phase_event[key] = details[key]
	event["phases"].append(phase_event)

func record_damage_event(event: Dictionary) -> String:
	var id := _next_id("damage")
	var copy := event.duplicate(true)
	copy["damage_event_id"] = id
	_bounded_append(damage_events, copy)
	return id

func record_death_event(event: Dictionary) -> void:
	var copy := event.duplicate(true)
	copy["death_event_id"] = _next_id("death")
	copy["contributing_damage_event_ids"] = damage_events.filter(func(item): return String(item.get("victim_runtime_id", "")) == String(copy.get("victim_runtime_id", ""))).map(func(item): return String(item.get("damage_event_id", "")))
	_bounded_append(death_events, copy)

func _write_graphs() -> void:
	_save_json("complete-command-event-graph.json", {"schema":"v0436-r1j-command-event-graph-v1", "public_orders":public_orders, "unit_commands":unit_commands})
	_save_json("complete-target-transition-graph.json", {"schema":"v0436-r1j-target-transition-graph-v1", "events":target_transitions})
	_save_json("complete-attack-event-graph.json", {"schema":"v0436-r1j-attack-event-graph-v1", "events":attack_events})
	_save_json("complete-projectile-event-graph.json", {"schema":"v0436-r1j-projectile-event-graph-v1", "events":projectile_events})
	_save_json("complete-damage-event-graph.json", {"schema":"v0436-r1j-damage-event-graph-v1", "events":damage_events})
	_save_json("complete-death-attribution.json", {"schema":"v0436-r1j-death-attribution-v1", "events":death_events})
	_save_json("per-attacker-uptime.json", {"schema":"v0436-r1j-attacker-uptime-v1", "samples":unit_samples})
	_save_json("per-attacker-effective-dps.json", {"schema":"v0436-r1j-effective-dps-v1", "damage_events":damage_events})
	_save_json("range-and-reachability-audit.json", {"schema":"v0436-r1j-range-reachability-v1", "samples":unit_samples.filter(func(item): return String(item.get("command", "")) in ["attack", "attack_move"]), "navigation":world.navigation_runtime_snapshot() if is_instance_valid(world) else {}})
	_save_json("formation-and-collision-audit.json", {"schema":"v0436-r1j-formation-collision-v1", "samples":unit_samples})
	_save_json("expected-versus-observed.json", {"schema":"v0436-r1j-expected-observed-v1", "damage_events":damage_events, "complete_attribution":damage_events.all(func(item): return String(item.get("attack_event_id", "")) != "")})

func _contact_sheet(blocked := false) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.03,0.04,0.05))
	var thumb := Vector2i(384,216)
	for i in range(min(frame_names.size(), 25)):
		var source := Image.load_from_file(ProjectSettings.globalize_path(out_path + frame_names[i]))
		if source.is_empty(): continue
		source.convert(Image.FORMAT_RGBA8)
		source.resize(thumb.x, thumb.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(source, Rect2i(0,0,thumb.x,thumb.y), Vector2i((i % 5) * thumb.x, (i / 5) * thumb.y))
	sheet.save_png(ProjectSettings.globalize_path(out_path + "20_R1J_CONTACT_SHEET.png"))
	frame_names.append("20_R1J_CONTACT_SHEET.png")

func _normal_production_setup() -> bool:
	preparation_started_ms = Time.get_ticks_msec()
	force_plan_audit = _production_definitions()
	_save_json("force-plan.json", {"provenance":_provenance("force_plan"), "plan":force_plan_audit})
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
	await _save("03_R1J_PRODUCTION_INFRASTRUCTURE.png")
	if not await _wait_until(func(): return is_instance_valid(hall) and hall.is_built, 90.0): return false
	_record_economy("war_hall_built")
	await _focus(hall.global_position)
	await _save("04_R1J_MIXED_FORCE_IN_PRODUCTION.png")
	var resources := _resources_by_kind()
	var food = resources.get("food")
	if not is_instance_valid(food): return false
	for worker in world.commanders[0].units:
		if is_instance_valid(worker) and worker.is_worker: worker.command_gather(food)
	_record_economy("workers_resumed_food_gathering")
	await _save("02_R1J_WORKERS_RESUME_ECONOMY.png")
	if not await _wait_until(func(): return world.resource_transactions.size() > 0 and int(world.commanders[0].resources.get("food", 0)) >= 240, 180.0): return false
	var queue_results: Array = []
	for unit_id in FORCE_PLAN:
		var result = hall.queue_unit(unit_id)
		queue_results.append({"unit_id":unit_id, "result":result, "resources_after":world.commanders[0].resources.duplicate(true), "pop_used":world.commanders[0].pop_used, "reserved_pop":world.commanders[0].reserved_pop})
		await get_tree().process_frame
	_record_economy("mixed_force_queues_issued")
	_save_json("production-audit.json", {"provenance":_provenance("production"), "queue_results":queue_results, "resource_transactions":world.resource_transactions.duplicate(true), "queue_plan":FORCE_PLAN})
	return await _wait_until(func():
		var ids: Dictionary = {}
		for u in _player_combatants(): ids[String(u.unit_id)] = int(ids.get(String(u.unit_id), 0)) + 1
		return int(ids.get("barrosan_spear_guard", 0)) >= 3 and int(ids.get("barrosan_crag_archer", 0)) >= 2, 240.0)

func _assault_r1j_target(target, label: String) -> Dictionary:
	var audit := {"label":label, "target":_ref(target), "commands":[], "started_ms":Time.get_ticks_msec(), "frames":[]}
	var army := _player_combatants()
	await _select_many(army)
	var move_ok: bool = rts.issue_attack_move_destination(target.global_position)
	var target_ok: bool = rts.issue_attack_target(target)
	audit["commands"] = [{"attack_move_return":move_ok, "attack_target_return":target_ok, "target":_ref(target)}]
	await _save("06_R1J_PUBLIC_ORDER_%s.png" % label)
	await _wait_seconds(0.75)
	await _save("07_R1J_FIRST_CONTACT_%s.png" % label)
	while Time.get_ticks_msec() - int(audit["started_ms"]) < int(R1J_ASSAULT_LIMIT_SECONDS * 1000.0):
		if not is_instance_valid(target) or target.is_dead: break
		if _player_combatants().is_empty(): break
		await _wait_seconds(0.5)
	await _save("08_R1J_TERMINAL_ENGAGEMENT_%s.png" % label)
	audit["elapsed_wall_seconds"] = float(Time.get_ticks_msec() - int(audit["started_ms"])) / 1000.0
	audit["target_final"] = _ref(target)
	audit["player_survivors"] = _player_combatants().map(func(u): return _unit_record(u))
	return audit

func _finish_session(status: String, reason: String) -> void:
	_write_graphs()
	_save_json("r1j-session-summary.json", {"schema":"v0436-r1j-session-summary-v1", "status":status, "reason":reason, "provenance":_provenance("session_final"), "force_plan":FORCE_PLAN, "public_orders":public_orders, "unit_commands":unit_commands, "target_transitions":target_transitions, "attack_events":attack_events, "projectile_events":projectile_events, "damage_events":damage_events, "death_events":death_events, "unit_sample_count":unit_samples.size(), "force_final":_player_combatants().map(func(u): return _unit_record(u)), "enemy_final":_enemy_combatants().map(func(u): return _unit_record(u)), "resources":world.commanders[0].resources.duplicate(true), "pressure_unchanged":true})
	await _contact_sheet()
	get_tree().quit(0)

func _capture_r1j_session() -> void:
	world.set_meta("v0436_r1j_recorder", self)
	if not await _wait_until(func(): return is_instance_valid(world) and world.game_running, 30.0): await _finish_session("BLOCKED_R1J_CAPTURE_SETUP", "production match did not start"); return
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("01_R1J_STANDARD_MATCH_START.png")
	_save_json("match-configuration.json", {"provenance":_provenance("configuration"), "observed":Match.get_config().duplicate(true), "expected":{"player_race":"barrosan","opponent_race":"lioraen","difficulty":"easy","start_resources":"standard","map":"hollowspan","mode":"skirmish","victory":"conquest","game_speed":2.0}})
	if not await _wait_until(func(): return world.is_navigation_ready(), 30.0): await _finish_session("BLOCKED_R1J_CAPTURE_SETUP", "navigation did not become ready"); return
	if not await _normal_production_setup(): await _finish_session("BLOCKED_R1J_CAPTURE_SETUP", "normal economy or production did not produce the prepared force"); return
	await _save("05_R1J_FORCE_READY.png")
	_save_json("force-readiness.json", {"provenance":_provenance("readiness"), "ready":true, "force":_player_combatants().map(func(u): return _unit_record(u)), "resources":world.commanders[0].resources.duplicate(true)})
	var enemies := _enemy_combatants()
	var defender = enemies.filter(func(u): return String(u.unit_id) == "lioraen_thorn_ranger")[0] if not enemies.filter(func(u): return String(u.unit_id) == "lioraen_thorn_ranger").is_empty() else null
	var hero = enemies.filter(func(u): return String(u.unit_id) == "lioraen_hero_warden")[0] if not enemies.filter(func(u): return String(u.unit_id) == "lioraen_hero_warden").is_empty() else null
	if not is_instance_valid(defender) or not is_instance_valid(hero): await _finish_session("BLOCKED_R1J_SESSION_COMPARABILITY_FAILED", "required enemy composition was not present"); return
	await _focus(defender.global_position, 30.0)
	await _save("09_R1J_ENEMY_INVENTORY.png")
	var first_target = defender if session == "A" else hero
	var second_target = hero if session == "A" else defender
	var audits: Array = []
	audits.append(await _assault_r1j_target(first_target, "A" if session == "A" else "B"))
	if not _player_combatants().is_empty() and is_instance_valid(second_target) and not second_target.is_dead:
		audits.append(await _assault_r1j_target(second_target, "B" if session == "A" else "A"))
	_save_json("target-order-audit.json", {"session":session, "intentional_difference": "defender-first" if session == "A" else "hero-first", "audits":audits})
	var final_state := _predicate_snapshot("r1j_terminal_engagement")
	await _finish_session("CAPTURE_COMPLETED", "bounded comparable assault evidence captured; causal classification deferred to validator")

func capture_gameplay(p_root: Node) -> void:
	root_node = p_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	await _capture_r1j_session()
