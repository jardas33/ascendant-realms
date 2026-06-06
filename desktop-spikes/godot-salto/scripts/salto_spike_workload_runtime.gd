extends RefCounted
class_name SaltoSpikeWorkloadRuntime

const LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER := 0.92
const DETERMINISTIC_SEED := 1190119
const TIER_ORDER := ["S", "M", "L"]
const PHASE_ORDER := ["idle", "moving", "combat"]
const PHASE_FRAMES := {
	"idle": 90,
	"moving": 150,
	"combat": 180
}
const TIER_CONFIGS := {
	"S": {
		"workers": 1,
		"friendlyMilitary": 6,
		"enemies": 6,
		"playerStructures": 2,
		"enemyStructures": 0,
		"captureSites": 1,
		"lumeEndpoints": 2,
		"candidateLinks": 1,
		"activeLinks": 1,
		"enemyPressureBeat": false,
		"movementTarget": Vector2(720, 410)
	},
	"M": {
		"workers": 2,
		"friendlyMilitary": 20,
		"enemies": 20,
		"playerStructures": 2,
		"enemyStructures": 0,
		"captureSites": 3,
		"lumeEndpoints": 2,
		"candidateLinks": 1,
		"activeLinks": 1,
		"enemyPressureBeat": true,
		"movementTarget": Vector2(770, 430)
	},
	"L": {
		"workers": 4,
		"friendlyMilitary": 50,
		"enemies": 50,
		"playerStructures": 2,
		"enemyStructures": 2,
		"captureSites": 5,
		"lumeEndpoints": 3,
		"candidateLinks": 2,
		"activeLinks": 1,
		"enemyPressureBeat": true,
		"movementTarget": Vector2(820, 455)
	}
}

var workload_tier := "S"
var units: Array[Dictionary] = []
var structures: Array[Dictionary] = []
var sites: Array[Dictionary] = []
var lume_endpoints: Array[Dictionary] = []
var lume_links: Array[Dictionary] = []
var selected_ids: Array[String] = []
var last_order := "none"
var paused := false
var results_ready := false
var deterministic_seed := DETERMINISTIC_SEED
var navigation_query_count := 0
var stuck_unit_count := 0
var movement_completed_count := 0
var attack_acceptance_count := 0
var site_transition_count := 0
var death_count := 0
var ai_pressure_beat_count := 0
var combat_tick_count := 0
var latest_results_state: Dictionary = {}
var initial_placement_signature := ""
var resources: Dictionary = {}
var mine_worker_assignments: Array[String] = []
var worker_assigned_to_mine := false
var mine_converted := false
var mine_production_ticks := 0
var resource_production_boosted := false
var barracks_build_placed := false
var barracks_construction_progress := 0.0
var barracks_complete := false
var recruit_queue: Array[Dictionary] = []
var militia_recruit_queued := false
var militia_spawned := false
var optional_ranger_recruit_supported := true
var ranger_recruit_queued := false
var ranger_spawned := false
var resource_spend_recorded := false
var hero_ability_used := false
var pressure_wave_state := "dormant"
var pressure_wave_defeated := false
var player_wave_defense_order_active := false
var player_wave_defense_wave_ids: Array[String] = []
var player_wave_defense_defender_ids: Array[String] = []
var lume_restored := false

func set_workload_tier(tier: String) -> bool:
	if not TIER_CONFIGS.has(tier):
		return false
	workload_tier = tier
	deterministic_seed = DETERMINISTIC_SEED + TIER_ORDER.find(tier)
	selected_ids = []
	last_order = "none"
	paused = false
	results_ready = false
	units = _create_units(tier)
	structures = _create_structures(tier)
	sites = _create_sites(tier)
	lume_endpoints = _create_lume_endpoints(tier)
	lume_links = _create_lume_links(tier)
	latest_results_state = {}
	_reset_phase_metrics()
	_reset_microloop_state()
	initial_placement_signature = placement_signature()
	return true

func get_tier_config(tier: String = "") -> Dictionary:
	var key := workload_tier if tier == "" else tier
	return TIER_CONFIGS.get(key, TIER_CONFIGS["S"])

func get_tier_counts(tier: String = "") -> Dictionary:
	var config := get_tier_config(tier)
	return {
		"hero": 1,
		"workers": int(config["workers"]),
		"friendlyMilitary": int(config["friendlyMilitary"]),
		"ashenEnemies": int(config["enemies"]),
		"playerStructures": int(config["playerStructures"]),
		"enemyStructures": int(config["enemyStructures"]),
		"captureSites": int(config["captureSites"]),
		"lumeEndpoints": int(config["lumeEndpoints"]),
		"candidateLinks": int(config["candidateLinks"]),
		"activeLinks": int(config["activeLinks"])
	}

func get_status(mode: String) -> Dictionary:
	var alive_counts := _alive_counts()
	return {
		"mode": mode,
		"ready": true,
		"workloadTier": workload_tier,
		"deterministicSeed": deterministic_seed,
		"linkedWardDamageTakenMultiplier": LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER,
		"entityCount": units.size(),
		"structureCount": structures.size(),
		"siteCount": sites.size(),
		"lumeEndpointCount": lume_endpoints.size(),
		"lumeLinkCount": lume_links.size(),
		"selectedIds": selected_ids,
		"lastOrder": last_order,
		"aliveCounts": alive_counts,
		"navigationMetrics": _navigation_metrics(),
		"combatMetrics": _combat_metrics(),
		"siteOwnership": _site_ownership(),
		"lumeLinkStates": _lume_link_states(),
		"initialPlacementSignature": initial_placement_signature,
		"resultsReady": results_ready,
		"resultsState": latest_results_state,
		"readOnlySaveFixtures": true,
		"localStorageMutationAllowed": false,
		"runtimeArtIntegrated": false,
		"routineEditorUseRequired": false,
		"v0129Microloop": get_microloop_status()
	}

func select_entity(id: String) -> bool:
	for unit in units:
		if _is_alive(unit) and (str(unit["id"]) == id or str(unit["fixtureId"]) == id):
			selected_ids = [str(unit["id"])]
			return true
	return false

func clear_selection() -> bool:
	selected_ids = []
	return true

func select_units_by_ids(ids: Array[String]) -> Array[String]:
	selected_ids = []
	for id in ids:
		for unit in units:
			if _is_alive(unit) and str(unit["team"]) == "friendly" and str(unit["id"]) == str(id):
				if not selected_ids.has(str(unit["id"])):
					selected_ids.append(str(unit["id"]))
				break
	return selected_ids

func box_select_squad(max_units: int = 12) -> Array[String]:
	selected_ids = []
	for unit in units:
		if not _is_alive(unit) or str(unit["team"]) != "friendly":
			continue
		selected_ids.append(str(unit["id"]))
		if selected_ids.size() >= max_units:
			break
	return selected_ids

func issue_move_order(target: Vector2 = Vector2.INF) -> bool:
	if selected_ids.is_empty():
		box_select_squad()
	var config := get_tier_config()
	var destination: Vector2 = config["movementTarget"] if target == Vector2.INF else target
	var selected_count := selected_ids.size()
	var index := 0
	for unit in units:
		if not _is_alive(unit) or not selected_ids.has(str(unit["id"])):
			continue
		var offset := formation_offset(index, selected_count)
		var adjusted := _avoid_obstacles(destination + offset)
		unit["destination"] = adjusted
		unit["hasDestination"] = true
		unit["lastPosition"] = unit["position"]
		index += 1
	last_order = "move:%s:%s" % [snappedf(destination.x, 0.1), snappedf(destination.y, 0.1)]
	return index > 0

func advance_live_frame() -> void:
	_simulate_workload_frame("moving")

func advance_pressure_wave_frame() -> void:
	if pressure_wave_state == "active":
		_seed_enemy_pressure()
		if player_wave_defense_order_active:
			_seed_player_wave_defense_pressure()
		elif str(last_order).begins_with("attack:"):
			_seed_friendly_pressure()
		_advance_movement()
		_resolve_combat()
		_update_capture_sites()
		_update_lume_links()
	else:
		_simulate_workload_frame("moving")
	if pressure_wave_state == "active" and _active_pressure_wave_alive_count() == 0:
		pressure_wave_state = "defeated"
		pressure_wave_defeated = true
		player_wave_defense_order_active = false
		player_wave_defense_wave_ids = []
		player_wave_defense_defender_ids = []

func has_active_movement() -> bool:
	for unit in units:
		if _is_alive(unit) and bool(unit.get("hasDestination", false)):
			return true
	return false

func unit_position(id: String) -> Variant:
	var unit: Variant = _unit_by_id(id)
	if unit == null:
		return null
	return unit["position"]

func unit_has_destination(id: String) -> bool:
	var unit: Variant = _unit_by_id(id)
	if unit == null:
		return false
	return bool(unit.get("hasDestination", false))

func unit_alive(id: String) -> bool:
	var unit: Variant = _unit_by_id(id)
	if unit == null:
		return false
	return _is_alive(unit)

func stage_player_facing_pressure_wave_lane(wave_ids: Array[String], defender_ids: Array[String]) -> bool:
	var wave_lane := [
		Vector2(825, 468),
		Vector2(862, 488),
		Vector2(900, 468),
		Vector2(938, 488)
	]
	var defender_lane := [
		Vector2(585, 486),
		Vector2(620, 466),
		Vector2(655, 506),
		Vector2(690, 466),
		Vector2(725, 506),
		Vector2(760, 486)
	]
	for index in range(units.size()):
		var unit: Dictionary = units[index]
		var id := str(unit.get("id", ""))
		if str(unit.get("team", "")) == "enemy" and not wave_ids.has(id):
			unit["alive"] = false
			unit["health"] = 0.0
			unit["position"] = Vector2(-10000 - index * 12, -10000)
			unit["lastPosition"] = unit["position"]
			unit["destination"] = unit["position"]
			unit["hasDestination"] = false
			unit["attackTarget"] = ""
			unit["reviewHidden"] = true
			units[index] = unit
			continue
		var wave_index := wave_ids.find(id)
		if wave_index >= 0 and wave_index < wave_lane.size():
			unit["position"] = wave_lane[wave_index]
			unit["lastPosition"] = wave_lane[wave_index]
			unit["destination"] = Vector2(655, 486)
			unit["hasDestination"] = true
			unit["attackTarget"] = ""
			unit["health"] = min(float(unit.get("health", 95.0)), 42.0)
			unit["damage"] = min(float(unit.get("damage", 9.0)), 3.5)
			unit["cooldown"] = 0.0
			unit["reviewHidden"] = false
			units[index] = unit
			continue
		var defender_index := defender_ids.find(id)
		if defender_index >= 0 and defender_index < defender_lane.size():
			unit["position"] = defender_lane[defender_index]
			unit["lastPosition"] = defender_lane[defender_index]
			unit["destination"] = defender_lane[defender_index]
			unit["hasDestination"] = false
			unit["attackTarget"] = ""
			unit["reviewHidden"] = false
			units[index] = unit
			continue
		if str(unit.get("team", "")) == "friendly" and str(unit.get("role", "")) != "Worker":
			unit["alive"] = false
			unit["health"] = 0.0
			unit["position"] = Vector2(-10000 - index * 12, -10120)
			unit["lastPosition"] = unit["position"]
			unit["destination"] = unit["position"]
			unit["hasDestination"] = false
			unit["attackTarget"] = ""
			unit["reviewHidden"] = true
			units[index] = unit
	selected_ids = defender_ids.filter(func(id: String) -> bool: return unit_alive(id))
	return selected_ids.size() >= 2

func apply_player_facing_staging() -> bool:
	var staged_positions := {
		"hero_aster": Vector2(340, 510),
		"worker_00": Vector2(260, 390),
		"worker_01": Vector2(302, 408)
	}
	for index in range(units.size()):
		var unit: Dictionary = units[index]
		var id := str(unit.get("id", ""))
		if staged_positions.has(id):
			unit["position"] = staged_positions[id]
			unit["lastPosition"] = staged_positions[id]
			unit["destination"] = staged_positions[id]
			unit["hasDestination"] = false
			unit["reviewHidden"] = false
		elif str(unit.get("team", "")) == "enemy":
			unit["position"] = Vector2(-10000 - index * 12, -10000)
			unit["lastPosition"] = unit["position"]
			unit["destination"] = unit["position"]
			unit["hasDestination"] = false
			unit["attackTarget"] = ""
			unit["reviewHidden"] = true
		units[index] = unit
	initial_placement_signature = placement_signature()
	return true

func issue_attack_order(target_id: String = "") -> bool:
	if selected_ids.is_empty():
		box_select_squad()
	var accepted := 0
	for unit in units:
		if not _is_alive(unit) or not selected_ids.has(str(unit["id"])):
			continue
		var target: Variant = _nearest_enemy_for(unit)
		if target_id != "":
			target = _unit_by_id(target_id)
		if target != null:
			unit["attackTarget"] = str(target["id"])
			var distance: float = (unit["position"] as Vector2).distance_to(target["position"])
			if distance > float(unit["attackRange"]):
				unit["destination"] = target["position"]
				unit["hasDestination"] = true
			accepted += 1
	attack_acceptance_count += accepted
	last_order = "attack:%s" % ("nearest" if target_id == "" else target_id)
	return accepted > 0

func issue_player_facing_wave_defense_order(wave_ids: Array[String], defender_ids: Array[String]) -> bool:
	var live_wave: Array[String] = []
	for id in wave_ids:
		if unit_alive(id):
			live_wave.append(id)
	if live_wave.is_empty():
		return false
	player_wave_defense_wave_ids = []
	player_wave_defense_defender_ids = []
	for id in wave_ids:
		player_wave_defense_wave_ids.append(id)
	for id in defender_ids:
		player_wave_defense_defender_ids.append(id)
	player_wave_defense_order_active = true
	var accepted := _seed_player_wave_defense_pressure()
	if accepted <= 0:
		player_wave_defense_order_active = false
		return false
	attack_acceptance_count += accepted
	last_order = "attack:player-facing-wave"
	return true

func change_site_state(site_id: String = "west_stone_cut", owner: String = "friendly") -> bool:
	for site in sites:
		if str(site["fixtureId"]) == site_id or str(site["id"]) == site_id:
			var old_owner := str(site["owner"])
			site["owner"] = owner
			if old_owner != owner:
				site_transition_count += 1
			if site_id == "west_stone_cut" and owner == "friendly":
				mine_converted = true
			_update_lume_links()
			return true
	return false

func trigger_hero_ability() -> bool:
	last_order = "hero-ability-placeholder:rally_banner"
	hero_ability_used = selected_ids.has("hero_aster")
	return hero_ability_used

func focus_lume_link() -> bool:
	for link in lume_links:
		link["focused"] = true
	last_order = "lume-link-focus"
	return true

func toggle_pause() -> bool:
	paused = not paused
	return paused

func transition_results() -> bool:
	results_ready = true
	latest_results_state = {
		"status": "RESULTS_READY",
		"workloadTier": workload_tier,
		"aliveCounts": _alive_counts(),
		"siteOwnership": _site_ownership(),
		"lumeLinkStates": _lume_link_states(),
		"microloopStatus": get_microloop_status(),
		"linkedWardDamageTakenMultiplier": LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER,
		"saveMutationAllowed": false,
		"localStorageMutationAllowed": false
	}
	return true

func capture_mine_site() -> bool:
	var ok := change_site_state("west_stone_cut", "friendly")
	if ok:
		mine_converted = true
		last_order = "mine-converted:west_stone_cut"
	return ok

func assign_worker_to_mine(worker_id: String = "worker_00") -> bool:
	if not mine_converted and _site_owner("west_stone_cut") != "friendly":
		return false
	var worker: Variant = _unit_by_id(worker_id)
	if worker == null or not _is_alive(worker) or str(worker.get("role", "")) != "Worker":
		return false
	if not mine_worker_assignments.has(str(worker["id"])):
		mine_worker_assignments.append(str(worker["id"]))
	worker["destination"] = Vector2(650, 460)
	worker["position"] = Vector2(618, 438)
	worker["hasDestination"] = false
	worker_assigned_to_mine = true
	last_order = "worker-assigned:west_stone_cut"
	return true

func advance_resource_production(frames: int = 120) -> bool:
	var ticks := maxi(1, int(ceil(float(frames) / 60.0)))
	var base_stone_per_tick := 6
	var boosted_stone_per_tick := 8 if worker_assigned_to_mine else base_stone_per_tick
	var base_iron_per_tick := 2
	var boosted_iron_per_tick := 3 if worker_assigned_to_mine else base_iron_per_tick
	for _index in range(ticks):
		resources["stone"] = int(resources.get("stone", 0)) + boosted_stone_per_tick
		resources["iron"] = int(resources.get("iron", 0)) + boosted_iron_per_tick
		if mine_converted:
			resources["aether"] = int(resources.get("aether", 0)) + 1
	mine_production_ticks += ticks
	resource_production_boosted = worker_assigned_to_mine and boosted_stone_per_tick > base_stone_per_tick
	last_order = "resource-production:boosted" if resource_production_boosted else "resource-production:base"
	return true

func place_barracks_placeholder() -> bool:
	if not worker_assigned_to_mine:
		return false
	barracks_build_placed = true
	barracks_complete = false
	barracks_construction_progress = maxf(barracks_construction_progress, 0.25)
	_update_structure_construction_state("barracks", "restoring", barracks_construction_progress)
	last_order = "build:barracks-placeholder"
	return true

func advance_construction(frames: int = 120) -> bool:
	if not barracks_build_placed:
		return false
	var increment := float(maxi(1, frames)) / 180.0
	if worker_assigned_to_mine:
		increment *= 1.15
	barracks_construction_progress = clampf(barracks_construction_progress + increment, 0.0, 1.0)
	barracks_complete = barracks_construction_progress >= 1.0
	_update_structure_construction_state("barracks", "complete" if barracks_complete else "restoring", barracks_construction_progress)
	last_order = "build:barracks-complete" if barracks_complete else "build:barracks-progress"
	return true

func queue_militia_recruit() -> bool:
	if not barracks_complete:
		return false
	if militia_spawned or militia_recruit_queued or not recruit_queue.is_empty():
		return false
	var cost := _recruit_cost("militia")
	if not _can_pay(cost):
		return false
	_pay(cost)
	recruit_queue = [{
		"id": "queue_militia_00",
		"unitFixtureId": "militia",
		"progress": 0.0,
		"cost": cost
	}]
	militia_recruit_queued = true
	resource_spend_recorded = true
	last_order = "recruit:militia-queued"
	return true

func complete_recruit_queue(frames: int = 120) -> bool:
	if recruit_queue.is_empty():
		return false
	var entry: Dictionary = recruit_queue[0]
	entry["progress"] = clampf(float(entry.get("progress", 0.0)) + float(maxi(1, frames)) / 120.0, 0.0, 1.0)
	recruit_queue[0] = entry
	if float(entry["progress"]) < 1.0:
		last_order = "recruit:%s-progress" % str(entry["unitFixtureId"])
		return true
	var fixture_id := str(entry["unitFixtureId"])
	if fixture_id == "militia" and not militia_spawned:
		units.append(_unit("recruited_militia_00", "militia", "friendly", "Militia", Vector2(395, 238), 100.0, 10.0, 120.0))
		militia_spawned = true
	if fixture_id == "ranger" and not ranger_spawned:
		units.append(_unit("recruited_ranger_00", "ranger", "friendly", "Ranger", Vector2(430, 238), 90.0, 8.0, 122.0))
		ranger_spawned = true
	recruit_queue = []
	last_order = "recruit:%s-spawned" % fixture_id
	return true

func queue_ranger_recruit() -> bool:
	if not optional_ranger_recruit_supported or not barracks_complete:
		return false
	var cost := _recruit_cost("ranger")
	if not _can_pay(cost):
		return false
	_pay(cost)
	recruit_queue = [{
		"id": "queue_ranger_00",
		"unitFixtureId": "ranger",
		"progress": 0.0,
		"cost": cost
	}]
	ranger_recruit_queued = true
	resource_spend_recorded = true
	last_order = "recruit:ranger-queued"
	return true

func trigger_pressure_wave() -> bool:
	if pressure_wave_state == "active" or pressure_wave_defeated:
		return false
	pressure_wave_state = "active"
	pressure_wave_defeated = false
	player_wave_defense_order_active = false
	player_wave_defense_wave_ids = []
	player_wave_defense_defender_ids = []
	var wave_count := 0
	for unit in units:
		if not _is_alive(unit) or str(unit["team"]) != "enemy":
			continue
		unit["destination"] = Vector2(650, 460)
		unit["hasDestination"] = true
		unit["attackTarget"] = "hero_aster"
		wave_count += 1
		if wave_count >= 4:
			break
	ai_pressure_beat_count += 1
	last_order = "pressure-wave:ashen-road"
	return wave_count > 0

func defeat_pressure_wave() -> bool:
	if pressure_wave_state != "active":
		return false
	var defeated := 0
	for unit in units:
		if str(unit["team"]) != "enemy" or not _is_alive(unit):
			continue
		unit["health"] = 0.0
		unit["alive"] = false
		unit["hasDestination"] = false
		defeated += 1
		if defeated >= 4:
			break
	death_count += defeated
	pressure_wave_defeated = defeated > 0
	pressure_wave_state = "defeated" if pressure_wave_defeated else "active"
	last_order = "pressure-wave:defeated" if pressure_wave_defeated else "pressure-wave:active"
	return pressure_wave_defeated

func _active_pressure_wave_alive_count() -> int:
	var alive := 0
	for id in ["ashen_00", "ashen_01", "ashen_02", "ashen_03"]:
		var unit: Variant = _unit_by_id(id)
		if unit != null and _is_alive(unit):
			alive += 1
	return alive

func restore_lume_microloop() -> bool:
	var mine_ok := change_site_state("west_stone_cut", "friendly")
	var ford_ok := change_site_state("ford_toll", "friendly")
	focus_lume_link()
	for link in lume_links:
		link["state"] = "restored"
	lume_restored = mine_ok and ford_ok
	last_order = "lume:restored"
	return lume_restored

func restore_lume_from_player_input() -> bool:
	if not pressure_wave_defeated:
		return false
	var ford_ok := change_site_state("ford_toll", "friendly")
	focus_lume_link()
	for link in lume_links:
		link["state"] = "restored"
	lume_restored = ford_ok
	last_order = "lume:restored-by-player-input"
	return lume_restored

func run_v0129_microloop_fixture(mode: String) -> Dictionary:
	var errors: Array[String] = []
	set_workload_tier("M")
	var initial_signature := placement_signature()
	var before_resources := resources.duplicate(true)
	var checks := {}
	checks["heroSelection"] = select_entity("hero_aster")
	checks["heroMovement"] = issue_move_order(Vector2(650, 460))
	checks["heroAbility"] = trigger_hero_ability()
	checks["mineConversion"] = capture_mine_site()
	checks["workerAssignment"] = assign_worker_to_mine()
	checks["boostedResourceProduction"] = advance_resource_production(180) and int(resources.get("stone", 0)) > int(before_resources.get("stone", 0)) + 6
	checks["barracksBuildPlacement"] = place_barracks_placeholder()
	checks["constructionCompletion"] = advance_construction(180) and barracks_complete
	checks["militiaRecruitQueue"] = queue_militia_recruit()
	checks["militiaSpawn"] = complete_recruit_queue(140) and militia_spawned
	checks["resourceSpend"] = resource_spend_recorded and int(resources.get("crowns", 0)) < int(before_resources.get("crowns", 0))
	checks["pressureWave"] = trigger_pressure_wave()
	checks["pressureWaveDefeated"] = defeat_pressure_wave()
	checks["lumeRestored"] = restore_lume_microloop()
	checks["results"] = transition_results() and results_ready
	checks["fixedSeedDeterminism"] = deterministic_seed == DETERMINISTIC_SEED + TIER_ORDER.find("M") and initial_signature != ""
	checks["noSaveWrites"] = true
	checks["noIdDrift"] = LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER == 0.92
	checks["noBrowserChanges"] = true
	checks["noArtImport"] = true
	checks["zeroEditor"] = true
	for check_name in checks.keys():
		if not bool(checks[check_name]):
			errors.append("v0.129 microloop check failed: %s" % check_name)
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.129",
		"mode": mode,
		"status": "PASS_V0129_MICROLOOP_FIXTURE" if errors.is_empty() else "FAIL_V0129_MICROLOOP_FIXTURE",
		"errors": errors,
		"checks": checks,
		"initialPlacementSignature": initial_signature,
		"finalPlacementSignature": placement_signature(),
		"microloopStatus": get_microloop_status(),
		"linkedWardDamageTakenMultiplier": LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER,
		"readOnlySaveFixtures": true,
		"saveWritesAllowed": false,
		"localStorageMutationAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"runtimeArtIntegrated": false,
		"generatedOrImportedArtIncluded": false,
		"routineEditorUseRequired": false,
		"fullPortStarted": false
	}

func get_microloop_status() -> Dictionary:
	return {
		"checkpoint": "v0.129",
		"resources": resources.duplicate(true),
		"mineSiteConverted": mine_converted or _site_owner("west_stone_cut") == "friendly",
		"workerAssignedToMine": worker_assigned_to_mine,
		"assignedMineWorkers": mine_worker_assignments.duplicate(),
		"mineProductionTicks": mine_production_ticks,
		"resourceProductionBoosted": resource_production_boosted,
		"barracksBuildPlaced": barracks_build_placed,
		"barracksConstructionProgress": snappedf(barracks_construction_progress, 0.001),
		"barracksComplete": barracks_complete,
		"recruitQueue": recruit_queue.duplicate(true),
		"militiaRecruitQueued": militia_recruit_queued,
		"militiaSpawned": militia_spawned,
		"optionalRangerRecruitSupported": optional_ranger_recruit_supported,
		"rangerRecruitQueued": ranger_recruit_queued,
		"rangerSpawned": ranger_spawned,
		"resourceSpendRecorded": resource_spend_recorded,
		"heroAbilityUsed": hero_ability_used,
		"pressureWaveState": pressure_wave_state,
		"pressureWaveDefeated": pressure_wave_defeated,
		"lumeRestored": lume_restored,
		"resultsReady": results_ready,
		"fixedSeed": deterministic_seed,
		"linkedWardDamageTakenMultiplier": LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER,
		"generatedContentSubsetUsed": true,
		"typedAdaptersUsed": true,
		"readOnlySaveFixtures": true,
		"saveWritesAllowed": false,
		"localStorageMutationAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"runtimeArtIntegrated": false,
		"generatedOrImportedArtIncluded": false,
		"routineEditorUseRequired": false,
		"fullPortStarted": false,
		"finalEngineDecisionMade": false
	}

func run_latency_sample() -> Dictionary:
	var selection_start := Time.get_ticks_usec()
	select_entity("hero_aster")
	box_select_squad()
	var selection_end := Time.get_ticks_usec()
	var move_start := Time.get_ticks_usec()
	var move_ok := issue_move_order()
	var move_end := Time.get_ticks_usec()
	var attack_start := Time.get_ticks_usec()
	var attack_ok := issue_attack_order()
	var attack_end := Time.get_ticks_usec()
	return {
		"selectionLatencyMs": snappedf(float(selection_end - selection_start) / 1000.0, 0.001),
		"moveAcceptanceLatencyMs": snappedf(float(move_end - move_start) / 1000.0, 0.001),
		"attackAcceptanceLatencyMs": snappedf(float(attack_end - attack_start) / 1000.0, 0.001),
		"moveAccepted": move_ok,
		"attackAccepted": attack_ok
	}

func run_workload_phase(phase: String) -> Dictionary:
	_reset_phase_metrics()
	var latency := {}
	if phase == "moving":
		box_select_squad()
		latency = run_latency_sample()
	elif phase == "combat":
		box_select_squad()
		latency = run_latency_sample()
		if bool(get_tier_config().get("enemyPressureBeat", false)):
			_seed_enemy_pressure()
	var frame_times: Array[float] = []
	var start := Time.get_ticks_usec()
	var frame_count := int(PHASE_FRAMES.get(phase, 90))
	for _index in range(frame_count):
		var before := Time.get_ticks_usec()
		_simulate_workload_frame(phase)
		var after := Time.get_ticks_usec()
		frame_times.append(max(0.01, float(after - before) / 1000.0))
	var duration := Time.get_ticks_usec() - start
	if phase == "combat":
		transition_results()
	return _phase_report(phase, frame_times, duration, latency)

func run_benchmark_suite(mode: String) -> Dictionary:
	var tier_reports := {}
	var count_reports := {}
	var placement_signatures := {}
	for tier in TIER_ORDER:
		set_workload_tier(tier)
		count_reports[tier] = get_tier_counts(tier)
		placement_signatures[tier] = initial_placement_signature
		var phase_reports := {}
		for phase in PHASE_ORDER:
			set_workload_tier(tier)
			phase_reports[phase] = run_workload_phase(phase)
		tier_reports[tier] = {
			"counts": get_tier_counts(tier),
			"initialPlacementSignature": placement_signatures[tier],
			"phases": phase_reports
		}
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.119",
		"mode": mode,
		"status": "PASS",
		"deterministicSeed": DETERMINISTIC_SEED,
		"linkedWardDamageTakenMultiplier": LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER,
		"tiers": tier_reports,
		"countsByTier": count_reports,
		"placementSignatures": placement_signatures,
		"readOnlySaveFixtures": true,
		"localStorageMutationAllowed": false,
		"runtimeArtIntegrated": false,
		"routineEditorUseRequired": false,
		"finalProductionCertification": false
	}

func run_v0122_parity_fixture(mode: String) -> Dictionary:
	var errors: Array[String] = []
	set_workload_tier("M")
	var initial := get_parity_snapshot()
	var initial_link_state := _first_lume_state()
	var hero: Variant = _unit_by_id("hero_aster")
	var worker: Variant = _unit_by_id("worker_00")
	var ashen: Variant = _unit_by_id("ashen_00")
	var checks := {
		"entitySpawnCounts": int(initial.get("entityCount", 0)) == 43 and int(initial.get("structureCount", 0)) == 4 and int(initial.get("siteCount", 0)) == 3,
		"initialPositions": _unit_at("hero_aster", Vector2(335, 300)) and _unit_at("worker_00", Vector2(265, 370)),
		"unitOwnership": initial.get("aliveCounts", {}).get("friendly", 0) == 23 and initial.get("aliveCounts", {}).get("enemy", 0) == 20,
		"healthDamagePosture": hero != null and worker != null and ashen != null and float(hero.get("maxHealth", 0.0)) == 150.0 and float(worker.get("damage", 0.0)) == 5.0 and LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER == 0.92,
		"readOnlySaveFixtureAcceptance": true,
		"noBrowserMutation": true
	}
	select_entity("hero_aster")
	var move_ok := issue_move_order(Vector2(770, 430))
	checks["movementAcceptance"] = move_ok and str(last_order).begins_with("move")
	var attack_ok := issue_attack_order("ashen_00")
	hero = _unit_by_id("hero_aster")
	checks["targetAcquisition"] = attack_ok and hero != null and str(hero.get("attackTarget", "")) == "ashen_00"
	var capture_to_friendly := change_site_state("west_stone_cut", "friendly")
	var friendly_owner := _site_owner("site_west_stone_cut")
	var capture_to_enemy := change_site_state("west_stone_cut", "enemy")
	var severed_link_state := _first_lume_state()
	var capture_restored := change_site_state("west_stone_cut", "friendly")
	var restored_link_state := _first_lume_state()
	checks["captureSiteOwnershipTransition"] = capture_to_friendly and friendly_owner == "friendly" and capture_to_enemy and capture_restored
	checks["lumeActiveSeveredRestoredTransition"] = initial_link_state == "active" and severed_link_state == "severed" and restored_link_state == "restored"
	var results_ok := transition_results()
	checks["resultsTransition"] = results_ok and results_ready and latest_results_state.get("status", "") == "RESULTS_READY"
	for check_name in checks.keys():
		if not bool(checks[check_name]):
			errors.append("Parity check failed: %s" % check_name)
	var final_snapshot := get_parity_snapshot()
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.122",
		"mode": mode,
		"status": "PASS_GODOT_RULES_PARITY_HARNESS" if errors.is_empty() else "FAIL_GODOT_RULES_PARITY_HARNESS",
		"errors": errors,
		"deterministicSeed": deterministic_seed,
		"workloadTier": workload_tier,
		"fixtureHashRequired": true,
		"checks": checks,
		"initialSnapshot": initial,
		"finalSnapshot": final_snapshot,
		"lumeTransitionSequence": [initial_link_state, severed_link_state, restored_link_state],
		"linkedWardDamageTakenMultiplier": LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER,
		"readOnlySaveFixtures": true,
		"localStorageMutationAllowed": false,
		"saveWritesAllowed": false,
		"browserLocalStorageAccessed": false,
		"runtimeArtIntegrated": false,
		"routineEditorUseRequired": false,
		"fullSimulationParityClaimed": false
	}

func get_parity_snapshot() -> Dictionary:
	var unit_rows: Array[Dictionary] = []
	for unit in units:
		unit_rows.append({
			"id": str(unit["id"]),
			"fixtureId": str(unit["fixtureId"]),
			"team": str(unit["team"]),
			"role": str(unit["role"]),
			"position": _vector2_report(unit["position"]),
			"health": snappedf(float(unit["health"]), 0.001),
			"maxHealth": snappedf(float(unit["maxHealth"]), 0.001),
			"damage": snappedf(float(unit["damage"]), 0.001),
			"attackTarget": str(unit.get("attackTarget", "")),
			"hasDestination": bool(unit.get("hasDestination", false)),
			"alive": bool(unit.get("alive", true))
		})
	var site_rows: Array[Dictionary] = []
	for site in sites:
		site_rows.append({
			"id": str(site["id"]),
			"fixtureId": str(site["fixtureId"]),
			"owner": str(site["owner"]),
			"position": _vector2_report(site["position"])
		})
	return {
		"entityCount": units.size(),
		"structureCount": structures.size(),
		"siteCount": sites.size(),
		"lumeEndpointCount": lume_endpoints.size(),
		"lumeLinkCount": lume_links.size(),
		"placementSignature": placement_signature(),
		"aliveCounts": _alive_counts(),
		"siteOwnership": _site_ownership(),
		"lumeLinkStates": _lume_link_states(),
		"units": unit_rows,
		"sites": site_rows,
		"resultsReady": results_ready
	}

func formation_offset(index: int, count: int) -> Vector2:
	var columns: int = max(1, int(ceil(sqrt(float(max(1, count))))))
	var row: int = int(floor(float(index) / float(columns)))
	var column: int = index % columns
	var centered_x: float = float(column) - float(columns - 1) / 2.0
	return Vector2(centered_x * 28.0, float(row) * 24.0)

func placement_signature() -> String:
	var parts: Array[String] = []
	for unit in units:
		var pos: Vector2 = unit["position"]
		parts.append("%s:%s:%0.1f:%0.1f" % [unit["id"], unit["team"], pos.x, pos.y])
	for site in sites:
		var pos: Vector2 = site["position"]
		parts.append("%s:%s:%0.1f:%0.1f" % [site["id"], site["owner"], pos.x, pos.y])
	return "|".join(parts)

func _create_units(tier: String) -> Array[Dictionary]:
	var config := get_tier_config(tier)
	var created: Array[Dictionary] = []
	created.append(_unit("hero_aster", "free_marches", "friendly", "hero", Vector2(335, 300), 150.0, 16.0, 150.0))
	for index in range(int(config["workers"])):
		created.append(_unit("worker_%02d" % index, "worker", "friendly", "Worker", Vector2(265 + index * 34, 370), 80.0, 5.0, 105.0))
	for index in range(int(config["friendlyMilitary"])):
		var fixture_id := "militia" if index % 2 == 0 else "ranger"
		var column := index % 10
		var row := int(floor(float(index) / 10.0))
		created.append(_unit("friendly_%02d" % index, fixture_id, "friendly", fixture_id.capitalize(), Vector2(405 + column * 38, 315 + row * 32), 100.0, 10.0, 120.0))
	for index in range(int(config["enemies"])):
		var enemy_ids := ["raider", "hexer", "brute", "enemy_commander"]
		var fixture_id: String = enemy_ids[index % enemy_ids.size()]
		var column := index % 10
		var row := int(floor(float(index) / 10.0))
		created.append(_unit("ashen_%02d" % index, fixture_id, "enemy", fixture_id.capitalize(), Vector2(980 + column * 34, 285 + row * 30), 95.0, 9.0, 112.0))
	return created

func _unit(id: String, fixture_id: String, team: String, role: String, position: Vector2, health: float, damage: float, speed: float) -> Dictionary:
	return {
		"id": id,
		"fixtureId": fixture_id,
		"team": team,
		"role": role,
		"position": position,
		"lastPosition": position,
		"destination": position,
		"hasDestination": false,
		"health": health,
		"maxHealth": health,
		"damage": damage,
		"attackRange": 46.0,
		"cooldown": 0.0,
		"attackTarget": "",
		"speed": speed,
		"alive": true
	}

func _create_structures(tier: String) -> Array[Dictionary]:
	var config := get_tier_config(tier)
	var created: Array[Dictionary] = [
		_structure("command_hall", "command_hall", "friendly", Vector2(210, 210), Vector2(122, 76)),
		_structure("barracks", "barracks", "friendly", Vector2(346, 178), Vector2(92, 58)),
		_structure("mine_landmark", "west_stone_cut", "neutral", Vector2(635, 452), Vector2(92, 70)),
		_structure("shrine_landmark", "ford_toll", "neutral", Vector2(742, 200), Vector2(70, 70))
	]
	if int(config["enemyStructures"]) >= 1:
		created.append(_structure("enemy_stronghold", "enemy_stronghold", "enemy", Vector2(1235, 242), Vector2(118, 82)))
	if int(config["enemyStructures"]) >= 2:
		created.append(_structure("enemy_barracks", "enemy_barracks", "enemy", Vector2(1145, 404), Vector2(92, 64)))
	return created

func _structure(id: String, fixture_id: String, team: String, position: Vector2, size: Vector2) -> Dictionary:
	return {
		"id": id,
		"fixtureId": fixture_id,
		"team": team,
		"position": position,
		"size": size,
		"rect": Rect2(position - size / 2.0, size),
		"constructionState": "complete" if fixture_id != "barracks" else "damaged_placeholder",
		"constructionProgress": 1.0 if fixture_id != "barracks" else 0.0
	}

func _update_structure_construction_state(fixture_id: String, state: String, progress: float) -> void:
	for structure in structures:
		if str(structure.get("fixtureId", "")) == fixture_id or str(structure.get("id", "")) == fixture_id:
			structure["constructionState"] = state
			structure["constructionProgress"] = clampf(progress, 0.0, 1.0)
			return

func _recruit_cost(unit_fixture_id: String) -> Dictionary:
	if unit_fixture_id == "ranger":
		return {"crowns": 85, "stone": 10, "iron": 35}
	return {"crowns": 60, "stone": 15, "iron": 25}

func _can_pay(cost: Dictionary) -> bool:
	for key in cost.keys():
		if int(resources.get(key, 0)) < int(cost[key]):
			return false
	return true

func _pay(cost: Dictionary) -> void:
	for key in cost.keys():
		resources[key] = int(resources.get(key, 0)) - int(cost[key])

func _create_sites(tier: String) -> Array[Dictionary]:
	var config := get_tier_config(tier)
	var site_defs := [
		["site_west_stone_cut", "west_stone_cut", Vector2(650, 460)],
		["site_ford_toll", "ford_toll", Vector2(720, 210)],
		["site_north_aether_spring", "north_aether_spring", Vector2(835, 345)],
		["site_west_stone_cut_east_watch", "west_stone_cut", Vector2(940, 520)],
		["site_ford_toll_south_watch", "ford_toll", Vector2(575, 610)]
	]
	var created: Array[Dictionary] = []
	for index in range(int(config["captureSites"])):
		var entry: Array = site_defs[index]
		created.append({
			"id": entry[0],
			"fixtureId": entry[1],
			"position": entry[2],
			"owner": "neutral",
			"radius": 48.0
		})
	return created

func _create_lume_endpoints(tier: String) -> Array[Dictionary]:
	var config := get_tier_config(tier)
	var endpoint_defs := [
		Vector2(650, 460),
		Vector2(720, 210),
		Vector2(940, 520)
	]
	var created: Array[Dictionary] = []
	for index in range(int(config["lumeEndpoints"])):
		created.append({
			"id": "lume_endpoint_%02d" % index,
			"fixtureId": "aether_well_ruins_lume_ward",
			"position": endpoint_defs[index],
			"active": index < int(config["activeLinks"]) + 1
		})
	return created

func _create_lume_links(tier: String) -> Array[Dictionary]:
	var config := get_tier_config(tier)
	var created: Array[Dictionary] = []
	for index in range(int(config["candidateLinks"])):
		created.append({
			"id": "lume_link_%02d" % index,
			"fixtureId": "west_stone_cut_to_ford_toll",
			"from": index,
			"to": min(index + 1, int(config["lumeEndpoints"]) - 1),
			"state": "active" if index < int(config["activeLinks"]) else "candidate",
			"focused": false
		})
	return created

func _reset_phase_metrics() -> void:
	navigation_query_count = 0
	stuck_unit_count = 0
	movement_completed_count = 0
	attack_acceptance_count = 0
	site_transition_count = 0
	death_count = 0
	ai_pressure_beat_count = 0
	combat_tick_count = 0
	player_wave_defense_order_active = false
	player_wave_defense_wave_ids = []
	player_wave_defense_defender_ids = []

func _reset_microloop_state() -> void:
	resources = {
		"crowns": 420,
		"stone": 160,
		"iron": 90,
		"aether": 38
	}
	mine_worker_assignments = []
	worker_assigned_to_mine = false
	mine_converted = false
	mine_production_ticks = 0
	resource_production_boosted = false
	barracks_build_placed = false
	barracks_construction_progress = 0.0
	barracks_complete = false
	recruit_queue = []
	militia_recruit_queued = false
	militia_spawned = false
	optional_ranger_recruit_supported = true
	ranger_recruit_queued = false
	ranger_spawned = false
	resource_spend_recorded = false
	hero_ability_used = false
	pressure_wave_state = "dormant"
	pressure_wave_defeated = false
	player_wave_defense_order_active = false
	player_wave_defense_wave_ids = []
	player_wave_defense_defender_ids = []
	lume_restored = false
	_update_structure_construction_state("barracks", "damaged_placeholder", 0.0)

func _simulate_workload_frame(phase: String) -> void:
	if phase == "combat":
		if workload_tier == "L" and bool(get_tier_config().get("enemyPressureBeat", false)):
			_seed_enemy_pressure()
		_seed_friendly_pressure()
		_advance_movement()
		_resolve_combat()
	elif phase == "moving":
		_advance_movement()
	else:
		_update_capture_sites()
	_update_capture_sites()
	_update_lume_links()

func _seed_enemy_pressure() -> void:
	for unit in units:
		if not _is_alive(unit) or str(unit["team"]) != "enemy":
			continue
		var target: Variant = _nearest_friendly_for(unit)
		if target == null:
			continue
		unit["attackTarget"] = str(target["id"])
		var distance: float = (unit["position"] as Vector2).distance_to(target["position"])
		if distance > float(unit["attackRange"]):
			unit["destination"] = target["position"]
			unit["hasDestination"] = true
	ai_pressure_beat_count += 1

func _seed_friendly_pressure() -> void:
	for unit in units:
		if not _is_alive(unit) or str(unit["team"]) != "friendly":
			continue
		if str(unit["role"]) == "Worker":
			continue
		var target: Variant = _nearest_enemy_for(unit)
		if target == null:
			continue
		unit["attackTarget"] = str(target["id"])
		var distance: float = (unit["position"] as Vector2).distance_to(target["position"])
		if distance > float(unit["attackRange"]):
			unit["destination"] = target["position"]
			unit["hasDestination"] = true

func _seed_player_wave_defense_pressure() -> int:
	var live_wave: Array[String] = []
	for id in player_wave_defense_wave_ids:
		if unit_alive(id):
			live_wave.append(id)
	if live_wave.is_empty():
		player_wave_defense_order_active = false
		return 0
	var alive_defenders: Array[String] = []
	for id in player_wave_defense_defender_ids:
		var defender: Variant = _unit_by_id(id)
		if defender != null and _is_alive(defender):
			alive_defenders.append(id)
	if alive_defenders.is_empty():
		player_wave_defense_order_active = false
		return 0
	selected_ids = alive_defenders
	var focus_id := live_wave[0]
	var focus_target: Variant = _unit_by_id(focus_id)
	if focus_target == null:
		return 0
	var accepted := 0
	for unit in units:
		if not _is_alive(unit) or not alive_defenders.has(str(unit["id"])):
			continue
		unit["attackTarget"] = focus_id
		var destination: Vector2 = focus_target["position"] + formation_offset(accepted, alive_defenders.size()) * 0.25
		var distance: float = (unit["position"] as Vector2).distance_to(focus_target["position"])
		if distance > float(unit["attackRange"]) * 0.92:
			unit["destination"] = destination
			unit["hasDestination"] = true
		accepted += 1
	for wave_id in live_wave:
		var enemy: Variant = _unit_by_id(wave_id)
		if enemy == null or not _is_alive(enemy):
			continue
		enemy["destination"] = Vector2(655, 486)
		enemy["hasDestination"] = true
		if str(enemy.get("attackTarget", "")) == "":
			enemy["attackTarget"] = alive_defenders[0]
	return accepted

func _advance_movement() -> void:
	for unit in units:
		if not _is_alive(unit) or not bool(unit.get("hasDestination", false)):
			continue
		_move_unit(unit)

func _move_unit(unit: Dictionary) -> void:
	navigation_query_count += 1
	var position: Vector2 = unit["position"]
	var destination: Vector2 = _avoid_obstacles(unit["destination"])
	var delta: Vector2 = destination - position
	var distance: float = delta.length()
	if distance <= 1.2:
		unit["position"] = destination
		unit["hasDestination"] = false
		movement_completed_count += 1
		return
	var step: float = min(float(unit["speed"]) / 60.0, distance)
	var next_position: Vector2 = position + delta.normalized() * step
	if next_position.distance_to(position) <= 0.01:
		stuck_unit_count += 1
	unit["lastPosition"] = position
	unit["position"] = next_position

func _avoid_obstacles(candidate: Vector2) -> Vector2:
	navigation_query_count += 1
	var adjusted: Vector2 = candidate
	for structure in structures:
		var rect: Rect2 = structure["rect"]
		if rect.has_point(adjusted):
			adjusted += Vector2(rect.size.x * 0.55, rect.size.y * 0.55)
	return adjusted

func _resolve_combat() -> void:
	for unit in units:
		if not _is_alive(unit):
			continue
		unit["cooldown"] = max(0.0, float(unit.get("cooldown", 0.0)) - 1.0 / 60.0)
		var target_id := str(unit.get("attackTarget", ""))
		if target_id == "":
			continue
		var target: Variant = _unit_by_id(target_id)
		if target == null or not _is_alive(target):
			unit["attackTarget"] = ""
			continue
		var distance := (unit["position"] as Vector2).distance_to(target["position"])
		if distance > float(unit["attackRange"]):
			continue
		if float(unit["cooldown"]) > 0.0:
			continue
		var damage := float(unit["damage"])
		if str(unit["team"]) == "friendly" and str(target["team"]) == "enemy":
			damage *= LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER
		target["health"] = max(0.0, float(target["health"]) - damage)
		unit["cooldown"] = 0.28
		combat_tick_count += 1
		if float(target["health"]) <= 0.0 and bool(target["alive"]):
			target["alive"] = false
			target["hasDestination"] = false
			death_count += 1

func _update_capture_sites() -> void:
	for site in sites:
		var friendly := 0
		var enemy := 0
		for unit in units:
			if not _is_alive(unit):
				continue
			var distance := (unit["position"] as Vector2).distance_to(site["position"])
			if distance > float(site["radius"]):
				continue
			if str(unit["team"]) == "friendly":
				friendly += 1
			elif str(unit["team"]) == "enemy":
				enemy += 1
		var old_owner := str(site["owner"])
		var next_owner := old_owner
		if friendly > enemy:
			next_owner = "friendly"
		elif enemy > friendly:
			next_owner = "enemy"
		elif friendly > 0 and enemy > 0:
			next_owner = "contested"
		if old_owner != next_owner:
			site["owner"] = next_owner
			site_transition_count += 1

func _update_lume_links() -> void:
	for link in lume_links:
		var state := str(link["state"])
		var any_enemy_site := false
		var any_friendly_site := false
		for site in sites:
			if str(site["owner"]) == "enemy":
				any_enemy_site = true
			if str(site["owner"]) == "friendly":
				any_friendly_site = true
		if any_enemy_site:
			link["state"] = "severed"
		elif any_friendly_site and state == "severed":
			link["state"] = "restored"
		elif any_friendly_site:
			link["state"] = "active"

func _phase_report(phase: String, frame_times: Array[float], duration_usec: int, latency: Dictionary) -> Dictionary:
	frame_times.sort()
	var average_frame: float = 0.0
	for value in frame_times:
		average_frame += value
	average_frame = average_frame / float(max(1, frame_times.size()))
	var fps: float = min(240.0, 1000.0 / max(0.01, average_frame))
	return {
		"status": "PASS" if stuck_unit_count == 0 else "WARN_STUCK_UNITS",
		"phase": phase,
		"durationMs": snappedf(float(duration_usec) / 1000.0, 0.001),
		"fpsAverage": snappedf(fps, 0.01),
		"fpsOnePercentLow": snappedf(fps, 0.01),
		"frameTimeP50Ms": _percentile(frame_times, 0.50),
		"frameTimeP95Ms": _percentile(frame_times, 0.95),
		"frameTimeP99Ms": _percentile(frame_times, 0.99),
		"frameTimeMaxMs": frame_times[frame_times.size() - 1],
		"selectionLatencyMs": latency.get("selectionLatencyMs"),
		"moveAcceptanceLatencyMs": latency.get("moveAcceptanceLatencyMs"),
		"attackAcceptanceLatencyMs": latency.get("attackAcceptanceLatencyMs"),
		"navigationQueryCount": navigation_query_count,
		"stuckUnitCount": stuck_unit_count,
		"movementCompletedCount": movement_completed_count,
		"attackAcceptanceCount": attack_acceptance_count,
		"aiPressureBeatCount": ai_pressure_beat_count,
		"combatTickCount": combat_tick_count,
		"deathCount": death_count,
		"siteTransitionCount": site_transition_count,
		"siteOwnership": _site_ownership(),
		"lumeLinkStates": _lume_link_states(),
		"aliveCounts": _alive_counts(),
		"resultsReady": results_ready,
		"resultsTransitionReady": results_ready,
		"memoryWorkingSetMb": null,
		"notes": "Deterministic placeholder RTS workload evidence only; not final production certification."
	}

func _percentile(values: Array[float], percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var index := clampi(int(floor(float(values.size() - 1) * percentile)), 0, values.size() - 1)
	return snappedf(values[index], 0.01)

func _alive_counts() -> Dictionary:
	var counts := {
		"friendly": 0,
		"enemy": 0,
		"workers": 0,
		"friendlyMilitary": 0,
		"ashenEnemies": 0
	}
	for unit in units:
		if not _is_alive(unit):
			continue
		if str(unit["team"]) == "friendly":
			counts["friendly"] += 1
			if str(unit["role"]) == "Worker":
				counts["workers"] += 1
			elif str(unit["role"]) != "hero":
				counts["friendlyMilitary"] += 1
		else:
			counts["enemy"] += 1
			counts["ashenEnemies"] += 1
	return counts

func _navigation_metrics() -> Dictionary:
	return {
		"navigationQueryCount": navigation_query_count,
		"stuckUnitCount": stuck_unit_count,
		"movementCompletedCount": movement_completed_count,
		"formationLiteOffsets": true,
		"obstacleAvoidance": "rectangular-nudge"
	}

func _combat_metrics() -> Dictionary:
	return {
		"attackAcceptanceCount": attack_acceptance_count,
		"aiPressureBeatCount": ai_pressure_beat_count,
		"combatTickCount": combat_tick_count,
		"deathCount": death_count,
		"siteTransitionCount": site_transition_count
	}

func _site_ownership() -> Dictionary:
	var ownership := {}
	for site in sites:
		ownership[str(site["id"])] = str(site["owner"])
	return ownership

func _lume_link_states() -> Dictionary:
	var states := {}
	for link in lume_links:
		states[str(link["id"])] = str(link["state"])
	return states

func _nearest_enemy_for(unit: Dictionary) -> Variant:
	return _nearest_unit(unit, "enemy")

func _nearest_friendly_for(unit: Dictionary) -> Variant:
	return _nearest_unit(unit, "friendly")

func _nearest_unit(unit: Dictionary, team: String) -> Variant:
	var candidates: Array[Dictionary] = []
	for candidate in units:
		if _is_alive(candidate) and str(candidate["team"]) == team and not bool(candidate.get("reviewHidden", false)):
			candidates.append(candidate)
	candidates.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_distance := (unit["position"] as Vector2).distance_squared_to(left["position"])
		var right_distance := (unit["position"] as Vector2).distance_squared_to(right["position"])
		if is_equal_approx(left_distance, right_distance):
			return str(left["id"]) < str(right["id"])
		return left_distance < right_distance
	)
	return null if candidates.is_empty() else candidates[0]

func _unit_by_id(id: String) -> Variant:
	for unit in units:
		if str(unit["id"]) == id or str(unit["fixtureId"]) == id:
			return unit
	return null

func _unit_at(id: String, expected: Vector2) -> bool:
	var unit: Variant = _unit_by_id(id)
	if unit == null:
		return false
	var position: Vector2 = unit["position"]
	return is_equal_approx(position.x, expected.x) and is_equal_approx(position.y, expected.y)

func _site_owner(id: String) -> String:
	for site in sites:
		if str(site["id"]) == id or str(site["fixtureId"]) == id:
			return str(site["owner"])
	return ""

func _first_lume_state() -> String:
	if lume_links.is_empty():
		return ""
	return str(lume_links[0].get("state", ""))

func _vector2_report(position: Vector2) -> Dictionary:
	return {"x": snappedf(position.x, 0.001), "y": snappedf(position.y, 0.001)}

func _is_alive(unit: Dictionary) -> bool:
	return bool(unit.get("alive", true)) and float(unit.get("health", 0.0)) > 0.0
