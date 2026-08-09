extends Node
## v0.436-R1H natural player-assault viability and conditional result proof.
## Opt-in evidence only: real production scene, real workers, real queues, and
## public RTS commands. This script never writes gameplay state directly.

const R1H_OUT := "res://../../artifacts/manual-review/v0436-r1h-natural-player-assault-viability/"
const R1I_OUT := "res://../../artifacts/manual-review/v0436-r1i-prepared-assault-combat-causality/"
const E1R_OUT := "res://../../artifacts/manual-review/v0436-e1r-competent-natural-conquest/"
const E3_OUT := "res://../../artifacts/manual-review/v0436-e3-tutorial-golden-path/"
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
var competent_mode := OS.get_environment("ASCENDANT_V0436_E1R_CAPTURE") == "1"
var tutorial_mode := OS.get_environment("ASCENDANT_V0436_E3_CAPTURE") == "1"
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

func _ready() -> void:
	session = OS.get_environment("ASCENDANT_V0436_R1H_SESSION")
	if session != "A" and session != "B": session = "A"
	if competent_mode:
		evidence_mode = "E1R"
		out_path = E1R_OUT + "session-%s/" % session.to_lower()
	elif tutorial_mode:
		evidence_mode = "E3"
		out_path = E3_OUT + "session-%s/" % session.to_lower()
	else:
		out_path = (R1I_OUT if evidence_mode == "R1I" else R1H_OUT) + "session-%s/" % session.to_lower()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path))
	Match.set_config({"player_race":"barrosan", "opponents":[{"race":"lioraen", "difficulty":"easy"}], "map":"hollowspan", "start_resources":"rich" if competent_mode or tutorial_mode else "standard", "victory":"conquest", "mode":"tutorial" if tutorial_mode else "skirmish", "game_speed":2.0})

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

func _evidence_name(name: String) -> String:
	if competent_mode: return name.replace("R1H", "E1R").replace("r1h-", "e1r-")
	if tutorial_mode: return name.replace("R1H", "E3").replace("r1h-", "e3-")
	if evidence_mode == "R1I": return name.replace("R1H", "R1I").replace("r1h-", "r1i-")
	return name

func _save(name: String) -> void:
	name = _evidence_name(name)
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(out_path + name))
	frame_names.append(name)
	last_valid_frame = name

func _save_json(name: String, value) -> void:
	name = _evidence_name(name)
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
		var source := Image.load_from_file(ProjectSettings.globalize_path(out_path + frame_names[i]))
		if source.is_empty(): continue
		source.convert(Image.FORMAT_RGBA8)
		source.resize(thumb.x, thumb.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(source, Rect2i(0,0,thumb.x,thumb.y), Vector2i((i % 5) * thumb.x, (i / 5) * thumb.y))
	sheet.save_png(ProjectSettings.globalize_path(out_path + _evidence_name("26_R1H_BLOCKER_CONTACT_SHEET.png" if blocked else "26_R1H_CONTACT_SHEET.png")))

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
	if competent_mode:
		await _capture_competent_match()
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
	var press := InputEventMouseButton.new(); press.position = rect.get_center(); press.global_position = rect.get_center(); press.button_index = MOUSE_BUTTON_LEFT; press.pressed = true; Input.parse_input_event(press); await get_tree().process_frame
	var release := InputEventMouseButton.new(); release.position = rect.get_center(); release.global_position = rect.get_center(); release.button_index = MOUSE_BUTTON_LEFT; release.pressed = false; Input.parse_input_event(release)
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
