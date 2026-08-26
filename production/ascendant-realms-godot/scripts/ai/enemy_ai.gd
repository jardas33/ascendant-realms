class_name EnemyAI
extends Node
## Base-building RTS AI. Plays the same game as the player: gathers, builds,
## techs up, trains a mixed army, defends, expands, captures, and attacks in
## waves. Difficulty scales decision quality, cadence, and economy discipline —
## NOT hidden vision (AI obeys its own unit vision except optional Brutal edge).

var world = null
var commander = null
var difficulty := "normal"

# tuning by difficulty
var _think_interval := 1.2
var _worker_target := 10
var _army_attack_size := 8
var _eco_efficiency := 1.0
var _tech_aggression := 1.0
var _brutal_income := 0.0

var _think_timer := 0.0
var _build_cooldown := 0.0
var _attack_timer := 0.0
var _wave_number := 0
var _rally := Vector3.ZERO
var _base_pos := Vector3.ZERO
var _staged_attack := false

# v0.435 bounded Easy opponent lane. It deliberately lives beside the existing
# difficulty ladder: normal/hard/brutal retain their historical behavior while
# Easy gets one deterministic, auditable economy-to-first-wave contract.
var _easy_mode := false
var _easy_elapsed := 0.0
var _easy_tick_timer := 0.0
var _easy_wave_launched := false
var _easy_wave_target := Vector3.ZERO
var _easy_wave_staged := false
var _easy_replacement_queued := false
var _easy_resource_cursor := 0
var _easy_unit_cursor := 0
var _easy_seed := 4351
var _easy_rng := RandomNumberGenerator.new()
var _easy_resource_assignments: Array = []
var _easy_resource_shortages: Array = []
var _easy_bank_ledger: Array = []
var _easy_building_audit: Array = []
var _easy_production_audit: Array = []
var _easy_staging_audit: Array = []
var _easy_wave_audit: Array = []
var _easy_replacement_audit: Array = []
var _easy_last_deposit_index := 0

func setup(p_world, p_commander, p_difficulty: String) -> void:
	world = p_world
	commander = p_commander
	difficulty = p_difficulty
	_apply_difficulty()
	_easy_mode = difficulty == "easy"
	_easy_rng.seed = _easy_seed + int(commander.team) * 101
	_base_pos = _find_hq_pos()
	_rally = _base_pos.lerp(Vector3.ZERO, 0.35)

func _apply_difficulty() -> void:
	match difficulty:
		"easy":
			# Preserve the accepted v0.434 Easy tuning. The bounded v0.435 lane
			# adds observability and real production, not a second difficulty model.
			_think_interval = 2.0; _worker_target = 7; _army_attack_size = 6
			_eco_efficiency = 0.7; _tech_aggression = 0.6; _brutal_income = 0.0
		"normal":
			_think_interval = 1.3; _worker_target = 10; _army_attack_size = 9
			_eco_efficiency = 1.0; _tech_aggression = 1.0
		"hard":
			_think_interval = 0.9; _worker_target = 14; _army_attack_size = 12
			_eco_efficiency = 1.25; _tech_aggression = 1.4
		"brutal":
			_think_interval = 0.7; _worker_target = 18; _army_attack_size = 14
			_eco_efficiency = 1.5; _tech_aggression = 1.8; _brutal_income = 3.0

func _find_hq_pos() -> Vector3:
	for b in commander.buildings:
		if is_instance_valid(b) and b.def.get("is_hq", false):
			return b.global_position
	return Vector3.ZERO

func _process(delta: float) -> void:
	if not world or not world.game_running or commander.defeated:
		return
	if _easy_mode:
		_process_easy(delta)
		return
	if _build_cooldown > 0.0:
		_build_cooldown -= delta
	# brutal passive trickle (labeled advantage)
	if _brutal_income > 0.0:
		commander.add_resources("gold", int(_brutal_income * delta))
		commander.add_resources("food", int(_brutal_income * delta * 0.5))
	_think_timer += delta
	if _think_timer >= _think_interval:
		_think_timer = 0.0
		_think()
	_attack_timer += delta

func _think() -> void:
	if _easy_mode:
		_think_easy()
		return
	_assign_idle_workers()
	_manage_economy()
	_manage_tech()
	_manage_production()
	_manage_defense()
	_manage_offense()
	_manage_capture()

# --------------------------------------------------------------------------
# v0.435 bounded Easy opponent
# --------------------------------------------------------------------------
func _process_easy(delta: float) -> void:
	_easy_elapsed += delta
	if _build_cooldown > 0.0:
		_build_cooldown -= delta
	_easy_tick_timer += delta
	if _easy_tick_timer < _think_interval:
		return
	_easy_tick_timer = 0.0
	_think_easy()

func _think_easy() -> void:
	_sync_easy_deposits()
	_assign_easy_idle_workers()
	_manage_easy_worker_production()
	_manage_easy_housing()
	_manage_easy_buildings()
	_manage_easy_staging_and_wave()
	_manage_easy_hq_pressure()
	_manage_easy_replacement()
	_manage_easy_mixed_production()

func _sync_easy_deposits() -> void:
	if not world:
		return
	var entries: Array = world.resource_transactions
	while _easy_last_deposit_index < entries.size():
		var entry: Dictionary = entries[_easy_last_deposit_index]
		_easy_last_deposit_index += 1
		if int(entry.get("dropoff_team", -1)) == commander.team:
			_easy_bank_ledger.append({"event": "deposit", "resource": entry.get("kind", ""),
				"amount": int(entry.get("deposited_amount", 0)),
				"before": entry.get("bank_before", {}).duplicate(),
				"after": entry.get("bank_after", {}).duplicate(),
				"worker_id": entry.get("worker_id", ""),
				"dropoff_id": entry.get("dropoff_building_id", ""),
				"timestamp_msec": entry.get("timestamp_msec", 0)})

func _assign_easy_idle_workers() -> void:
	var workers: Array = []
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and u.is_worker:
			workers.append(u)
	workers.sort_custom(func(a, b): return str(a.get_instance_id()) < str(b.get_instance_id()))
	var plan := _easy_resource_plan()
	for i in workers.size():
		var worker = workers[i]
		if worker.state != worker.State.IDLE:
			continue
		var desired := String(plan[i % plan.size()])
		var node = world.find_nearest_resource_exact(worker.global_position, desired)
		var assigned := desired
		if not node:
			_easy_resource_shortages.append({"worker_id": worker.unit_id,
				"worker_runtime_id": str(worker.get_instance_id()), "requested": desired,
				"time": _easy_elapsed, "reason": "desired_kind_absent_or_depleted"})
			for fallback in _available_easy_resource_kinds():
				if fallback == desired:
					continue
				node = world.find_nearest_resource_exact(worker.global_position, fallback)
				if node:
					assigned = fallback
					break
		if node:
			worker.command_gather(node)
			_easy_resource_assignments.append({"worker_id": worker.unit_id,
				"worker_runtime_id": str(worker.get_instance_id()), "requested": desired,
				"assigned": assigned, "node_id": str(node.get_instance_id()),
				"time": _easy_elapsed, "explicit_fallback": assigned != desired})

func _easy_resource_plan() -> Array:
	# First pass funds construction with all four real resource kinds represented;
	# later passes favor food/gold for the mixed army. No worker carries mixed cargo.
	if not _has_building_kind("barracks"):
		return ["food", "timber", "stone", "timber", "food", "stone", "timber"]
	return ["food", "food", "gold", "food", "timber", "gold", "food"]

func _available_easy_resource_kinds() -> Array:
	var kinds: Array = []
	for r in world.get_tree().get_nodes_in_group("resources"):
		if is_instance_valid(r) and not r.depleted and r.resource_kind not in kinds:
			kinds.append(r.resource_kind)
	return kinds

func _manage_easy_worker_production() -> void:
	var hq = _get_building_of_kind("main")
	if not hq or _worker_count() >= _worker_target:
		return
	if hq.queue.size() >= 1:
		return
	var worker_id := String(GameData.get_race(commander.race).get("worker", ""))
	if worker_id == "":
		return
	var before: Dictionary = commander.resources.duplicate()
	var result: Dictionary = hq.queue_unit(worker_id)
	if result.get("ok", false):
		_easy_production_audit.append({"event": "worker_queue", "unit_id": worker_id,
			"building_id": hq.building_id, "queue_count": hq.queue.size(),
			"resources_before": before, "resources_after": commander.resources.duplicate(),
			"time": _easy_elapsed})
		_record_easy_bank_event("worker_queue", worker_id, before, commander.resources)

func _manage_easy_housing() -> void:
	if commander.pop_cap >= commander.POP_HARD_CAP:
		return
	# The first real worker is enough to start housing. Waiting for five
	# workers deadlocks the bounded lane because the initial population is
	# already below the normal pressure threshold; the house itself is the
	# legitimate capacity increase that lets the worker queue continue.
	if _worker_count() < 4 and commander.pop_used + commander.reserved_pop < commander.pop_cap - 2:
		return
	if _has_building_kind("house"):
		return
	_try_easy_build("house")

func _manage_easy_buildings() -> void:
	if _has_building_kind("barracks"):
		return
	# Three starting workers are sufficient to commission the first military
	# building once the housing transaction has completed.
	if _worker_count() < 3:
		return
	_try_easy_build("barracks")

func _manage_easy_mixed_production() -> void:
	var barracks = _get_building_of_kind("barracks")
	if not barracks or barracks.queue.size() >= 1 or _army_size() + _queued_easy_combat_count(barracks) >= _army_attack_size:
		return
	var pick := _choose_easy_mixed_unit(barracks.def.get("produces", []))
	if pick == "":
		return
	var before: Dictionary = commander.resources.duplicate()
	var result: Dictionary = barracks.queue_unit(pick)
	if result.get("ok", false):
		_easy_production_audit.append({"event": "mixed_unit_queue", "unit_id": pick,
			"role": GameData.get_unit(pick).get("role", ""), "building_id": barracks.building_id,
			"resources_before": before, "resources_after": commander.resources.duplicate(),
			"queue_count": barracks.queue.size(), "time": _easy_elapsed})
		_record_easy_bank_event("mixed_unit_queue", pick, before, commander.resources)

func _choose_easy_mixed_unit(choices: Array) -> String:
	var legal: Array = []
	for c in choices:
		var id := String(c)
		var d := GameData.get_unit(id)
		if d.is_empty() or String(d.get("race", "")) != commander.race:
			continue
		if String(d.get("role", "")) in ["worker", "hero"] or bool(d.get("is_hero", false)):
			continue
		if int(d.get("tier", 1)) > commander.tier:
			continue
		if commander.can_afford(d.get("cost", {})) and commander.has_pop_for(d):
			legal.append(id)
	if legal.is_empty():
		return ""
	var role_counts := _easy_combat_role_counts()
	# Cover a missing legal Age-I role before adding a duplicate role. This is
	# derived from the live/queued roster, never from a faction-specific ID.
	var preferred_roles := ["melee", "defender", "ranged", "flanker"]
	for role in preferred_roles:
		if int(role_counts.get(role, 0)) > 0:
			continue
		for id in legal:
			if String(GameData.get_unit(id).get("role", "")) == role:
				return id
	# Once role coverage exists, rotate through legal choices deterministically.
	for offset in legal.size():
		var id := String(legal[(_easy_unit_cursor + offset) % legal.size()])
		_easy_unit_cursor = (_easy_unit_cursor + offset + 1) % legal.size()
		return id
	return ""

func _easy_combat_role_counts() -> Dictionary:
	var counts := {}
	for u in _easy_army():
		var role := String(u.def.get("role", ""))
		if role != "":
			counts[role] = int(counts.get(role, 0)) + 1
	var barracks = _get_building_of_kind("barracks")
	if barracks:
		for item in barracks.queue:
			if item.get("kind", "") != "unit":
				continue
			var role := String(GameData.get_unit(String(item.get("id", ""))).get("role", ""))
			if role != "":
				counts[role] = int(counts.get(role, 0)) + 1
	return counts

func _queued_easy_combat_count(barracks) -> int:
	var count := 0
	for item in barracks.queue:
		if item.get("kind", "") != "unit":
			continue
		var d := GameData.get_unit(String(item.get("id", "")))
		if not d.is_empty() and String(d.get("race", "")) == commander.race and String(d.get("role", "")) not in ["worker", "hero"]:
			count += 1
	return count

func _manage_easy_staging_and_wave() -> void:
	if _easy_wave_launched:
		return
	if _army_size() < _army_attack_size:
		return
	if _easy_wave_target == Vector3.ZERO:
		_easy_wave_target = _find_player_target()
		var toward := (_easy_wave_target - _base_pos)
		toward.y = 0.0
		_rally = _base_pos + toward.normalized() * 32.0
		_easy_staging_audit.append({"event": "rally_point", "position": _vec_payload(_rally), "time": _easy_elapsed})
	var army := _easy_army()
	if not _easy_wave_staged:
		for u in army:
			if u.state == u.State.IDLE or u.state == u.State.GATHERING:
				u.command_move(_rally)
		var staged := true
		for u in army:
			if u.global_position.distance_to(_rally) > 8.0:
				staged = false
		if not staged:
			return
		_easy_wave_staged = true
		_easy_staging_audit.append({"event": "army_staged", "count": army.size(),
			"position": _vec_payload(_rally), "time": _easy_elapsed})
	for u in army:
		if is_instance_valid(u) and not u.is_dead:
			u.command_move(_easy_wave_target, true)
	_easy_wave_launched = true
	var participant_ids: Array = []
	var participant_runtime_ids: Array = []
	var participant_roles: Array = []
	for u in army:
		participant_ids.append(u.unit_id)
		participant_runtime_ids.append(str(u.get_instance_id()))
		participant_roles.append(String(u.def.get("role", "")))
	_easy_wave_audit.append({"event": "first_wave_launched", "count": army.size(),
		"threshold": _army_attack_size, "opponent_race": commander.race,
		"difficulty": difficulty, "wave_participant_ids": participant_ids,
		"wave_participant_runtime_ids": participant_runtime_ids,
		"wave_participant_roles": participant_roles,
		"distinct_roles": _distinct_strings(participant_roles),
		"target": _vec_payload(_easy_wave_target), "attack_move": true, "time": _easy_elapsed})

func _manage_easy_hq_pressure() -> void:
	# The first wave is launched with the real attack-move command above. Once
	# it reaches the known player HQ, hand off only units that are no longer
	# resolving a nearby unit target to the real building target. This keeps the
	# contact consequence authoritative without letting the capture driver issue
	# AI commands or writing HP directly.
	if not _easy_wave_launched or world.commanders.is_empty():
		return
	var hq = null
	for b in world.commanders[0].buildings:
		if is_instance_valid(b) and not b.is_dead and (b.def.get("is_hq", false) or b.def.get("kind", "") == "main"):
			hq = b
			break
	if not is_instance_valid(hq):
		return
	for u in _easy_army():
		if not is_instance_valid(u) or u.is_dead:
			continue
		if u.global_position.distance_to(hq.global_position) > 16.0:
			continue
		# Once the bounded wave reaches the HQ radius, the building is the
		# authoritative pressure target. Re-issuing the real unit command is
		# intentional here: it hands off from incidental contact targets to
		# the player's actual HQ without writing HP or bypassing combat.
		u.command_attack(hq)

func _manage_easy_replacement() -> void:
	if not _easy_wave_launched or _easy_replacement_queued:
		return
	var enemy_losses := 0
	for e in world.combat_death_events:
		if int(e.get("victim_team", -1)) == commander.team:
			enemy_losses += 1
	if enemy_losses < 1 or _army_size() >= _army_attack_size:
		return
	var barracks = _get_building_of_kind("barracks")
	if not barracks or not barracks.queue.is_empty():
		return
	var pick := _choose_easy_mixed_unit(barracks.def.get("produces", []))
	if pick == "":
		return
	var before: Dictionary = commander.resources.duplicate()
	var reserved_before: int = commander.reserved_pop
	var result: Dictionary = barracks.queue_unit(pick)
	if result.get("ok", false):
		_easy_replacement_queued = true
		_easy_replacement_audit.append({"event": "replacement_queue_after_casualty", "unit_id": pick,
			"opponent_race": commander.race, "building_id": barracks.building_id,
			"role": String(GameData.get_unit(pick).get("role", "")),
			"losses_before_queue": enemy_losses, "resources_before": before,
			"resources_after": commander.resources.duplicate(),
			"reserved_population_before": reserved_before,
			"reserved_population_after": commander.reserved_pop, "time": _easy_elapsed})
		_record_easy_bank_event("replacement_queue", pick, before, commander.resources)

func _easy_army() -> Array:
	var out: Array = []
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero and String(u.def.get("race", "")) == commander.race:
			out.append(u)
	return out

func _find_player_target() -> Vector3:
	if world.commanders.size() > 0:
		var fallback := Vector3.ZERO
		for b in world.commanders[0].buildings:
			if not is_instance_valid(b) or b.is_dead:
				continue
			if fallback == Vector3.ZERO:
				fallback = b.global_position
			if b.def.get("is_hq", false) or b.def.get("kind", "") == "main":
				return b.global_position
		if fallback != Vector3.ZERO:
			return fallback
	return Vector3.ZERO

func _vec_payload(pos: Vector3) -> Dictionary:
	return {"x": pos.x, "y": pos.y, "z": pos.z}

func _distinct_strings(values: Array) -> Array:
	var out: Array = []
	for value in values:
		var text := String(value)
		if text != "" and text not in out:
			out.append(text)
	return out

func _record_easy_bank_event(event: String, subject: String, before: Dictionary, after: Dictionary) -> void:
	_easy_bank_ledger.append({"event": event, "subject": subject,
		"before": before.duplicate(), "after": after.duplicate(), "time": _easy_elapsed})

func _try_easy_build(kind: String) -> bool:
	if _build_cooldown > 0.0:
		return false
	var bid := _building_id_for_kind(kind)
	if bid == "":
		return false
	var bdef := GameData.get_building(bid)
	if not commander.can_afford(bdef.get("cost", {})):
		return false
	var worker = _free_worker()
	if not worker:
		return false
	var pos := _find_easy_build_spot(kind, worker)
	if pos == Vector3.INF:
		_easy_building_audit.append({"event": "placement_failed", "kind": kind,
			"reason": "no_valid_site", "attempts": 24, "time": _easy_elapsed})
		_build_cooldown = 2.0
		return false
	var before: Dictionary = commander.resources.duplicate()
	var b = world.place_building(bid, commander.team, pos)
	if not is_instance_valid(b):
		_easy_building_audit.append({"event": "placement_failed", "kind": kind,
			"reason": "transaction_rejected", "time": _easy_elapsed})
		_build_cooldown = 2.0
		return false
	worker.command_build(b)
	_easy_building_audit.append({"event": "placed", "kind": kind, "building_id": bid,
		"position": _vec_payload(pos), "worker_id": worker.unit_id,
		"resources_before": before, "resources_after": commander.resources.duplicate(),
		"is_built": b.is_built, "time": _easy_elapsed})
	_record_easy_bank_event("building_placed", bid, before, commander.resources)
	_build_cooldown = 2.0
	return true

func _find_easy_build_spot(kind: String, worker) -> Vector3:
	var toward := (Vector3.ZERO - _base_pos)
	toward.y = 0.0
	toward = toward.normalized()
	var side := Vector3(-toward.z, 0, toward.x)
	var offsets := []
	if kind == "house":
		offsets = [side * 14.0, -side * 14.0, side * 20.0, -side * 20.0]
	else:
		offsets = [toward * 18.0 + side * 10.0, toward * 22.0 - side * 10.0,
			toward * 28.0 + side * 14.0, toward * 28.0 - side * 14.0]
	for ring in range(6):
		for off in offsets:
			var p: Vector3 = _base_pos + off + side * float(ring * 4) + toward * float((ring % 2) * 4)
			p.y = 0.0
			if world.can_place_building(_building_id_for_kind(kind), commander.team, p, true, worker):
				return p
	return Vector3.INF

func get_v0435_audit() -> Dictionary:
	_sync_easy_deposits()
	return {"difficulty": difficulty, "easy_mode": _easy_mode, "think_interval": _think_interval,
		"brutal_income": _brutal_income, "worker_count": _worker_count(),
		"resource_assignments": _easy_resource_assignments.duplicate(true),
		"resource_shortages": _easy_resource_shortages.duplicate(true),
		"bank_ledger": _easy_bank_ledger.duplicate(true),
		"building_audit": _easy_building_audit.duplicate(true),
		"production_audit": _easy_production_audit.duplicate(true),
		"staging_audit": _easy_staging_audit.duplicate(true),
		"wave_audit": _easy_wave_audit.duplicate(true),
		"replacement_audit": _easy_replacement_audit.duplicate(true),
		"wave_launched": _easy_wave_launched, "wave_staged": _easy_wave_staged,
		"wave_target": _vec_payload(_easy_wave_target), "army_size": _army_size(),
		"opponent_race": commander.race, "wave_threshold": _army_attack_size,
		"wave_role_counts": _easy_combat_role_counts()}

# --- economy --------------------------------------------------------------
func _assign_idle_workers() -> void:
	for u in commander.units:
		if not is_instance_valid(u) or u.is_dead or not u.is_worker:
			continue
		if u.state == u.State.IDLE:
			var kind := _needed_resource()
			var node = world.find_nearest_resource(u.global_position, kind)
			if node:
				u.command_gather(node)

func _needed_resource() -> String:
	# pick the lowest stockpile among the ones we consume
	var r = commander.resources
	var lowest := "gold"
	var lowest_v := INF
	for k in ["food", "timber", "stone", "gold"]:
		var v = int(r.get(k, 0))
		if v < lowest_v:
			lowest_v = v
			lowest = k
	return lowest

func _worker_count() -> int:
	var n := 0
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and u.is_worker:
			n += 1
	return n

func _manage_economy() -> void:
	# train workers from HQ up to target
	var hq = _get_building_of_kind("main")
	if hq and _worker_count() < _worker_target:
		if hq.queue.size() < 2:
			var wid = GameData.get_race(commander.race).get("worker", "")
			hq.queue_unit(wid)
	# build houses when near pop cap
	if commander.pop_used >= commander.pop_cap - 3 and commander.pop_cap < commander.POP_HARD_CAP:
		_try_build("house")

# --- tech -----------------------------------------------------------------
func _manage_tech() -> void:
	var hq = _get_building_of_kind("main")
	if not hq:
		return
	# advance tiers when economy allows
	if commander.tier == 1 and _worker_count() >= int(6 * _eco_efficiency):
		if commander.can_research("advance_tier_2") and hq.queue.is_empty():
			hq.queue_tech("advance_tier_2")
	elif commander.tier == 2 and _army_size() >= 6:
		if commander.can_research("advance_tier_3") and hq.queue.is_empty():
			hq.queue_tech("advance_tier_3")
	# army upgrades at economy building
	var eco = _get_building_of_kind("economy")
	if eco and eco.queue.is_empty():
		for t in ["tech_weapons", "tech_armor"]:
			if commander.can_research(t) and commander.can_afford(GameData.get_tech(t).get("cost", {})):
				eco.queue_tech(t)
				break

# --- production / construction --------------------------------------------
func _manage_production() -> void:
	# ensure core buildings exist
	if not _has_building_kind("barracks"):
		_try_build("barracks")
		return
	if commander.tier >= 2 and not _has_building_kind("economy"):
		_try_build("economy")
	if commander.tier >= 2 and not _has_building_kind("arcane") and _tech_aggression >= 1.0:
		_try_build("arcane")
	# second barracks for hard/brutal
	if _tech_aggression >= 1.4 and _count_building_kind("barracks") < 2 and _army_size() > 6:
		_try_build("barracks")

	# train army from military buildings
	for b in commander.buildings:
		if not is_instance_valid(b) or b.is_dead or not b.is_built:
			continue
		var kind = b.def.get("kind", "")
		if kind in ["barracks", "arcane"] and b.queue.size() < 2:
			var choices: Array = b.def.get("produces", [])
			var pick := _choose_unit(choices)
			if pick != "":
				b.queue_unit(pick)

func _choose_unit(choices: Array) -> String:
	# weighted pick favoring affordable, tier-legal units; some composition variety
	var legal := []
	for c in choices:
		var d := GameData.get_unit(c)
		if int(d.get("tier", 1)) <= commander.tier and commander.can_afford(d.get("cost", {})) and commander.has_pop_for(d):
			legal.append(c)
	if legal.is_empty():
		return ""
	# prefer a mix: bias toward higher tier when available
	legal.sort_custom(func(a, b): return int(GameData.get_unit(a).get("tier",1)) > int(GameData.get_unit(b).get("tier",1)))
	if randf() < 0.55:
		return legal[0]
	return legal[randi() % legal.size()]

# --- defense --------------------------------------------------------------
func _manage_defense() -> void:
	# build a tower or two near base early-mid
	if _count_building_kind("tower") < (2 if _tech_aggression >= 1.0 else 1) and _worker_count() >= 5:
		if randf() < 0.4:
			_try_build("tower")
	# recall army to defend if base attacked
	var threat = world.find_enemy_near(_base_pos, 30.0, commander.team)
	if threat:
		for u in commander.units:
			if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
				if u.global_position.distance_to(_base_pos) < 45.0:
					u.command_attack(threat)

# --- offense --------------------------------------------------------------
func _army_size() -> int:
	var n := 0
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
			n += 1
	return n

func _manage_offense() -> void:
	var size := _army_size()
	var needed := _army_attack_size + _wave_number * 2
	if size >= needed and _attack_timer > 8.0:
		_attack_timer = 0.0
		_wave_number += 1
		_launch_attack()
	elif not _staged_attack and size < needed:
		# stage army at rally
		for u in commander.units:
			if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
				if u.state == u.State.IDLE and u.global_position.distance_to(_rally) > 12.0:
					u.command_move(_rally)

func _launch_attack() -> void:
	var target := _pick_attack_target()
	if target == Vector3.ZERO:
		return
	# multi-prong on hard+: split army
	var soldiers := []
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker:
			soldiers.append(u)
	for u in soldiers:
		u.command_move(target, true)
	# hero joins the push
	if is_instance_valid(commander.hero_ref) and not commander.hero_ref.is_dead:
		commander.hero_ref.command_move(target, true)

func _pick_attack_target() -> Vector3:
	# Preserve the existing nearest built hostile Building priority.
	var best := Vector3.ZERO
	var best_d := INF
	for b in world.all_buildings():
		if not is_instance_valid(b) or b.is_dead or not b.is_built or b.team == commander.team:
			continue
		var d = _base_pos.distance_squared_to(b.global_position)
		if d < best_d:
			best_d = d
			best = b.global_position
	if best != Vector3.ZERO:
		return best
	# Conquest still requires live Workers after the last hostile Building falls.
	# Use the existing world unit query, Worker role flag, team hostility, and
	# Commander defeat authority; no strategic military fallback is intended.
	var worker_target := Vector3.ZERO
	var worker_d := INF
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead or not u.is_worker or u.team == commander.team:
			continue
		var worker_commander = world.commander_for_team(u.team)
		if not is_instance_valid(worker_commander) or worker_commander.defeated:
			continue
		var d = _base_pos.distance_squared_to(u.global_position)
		if d < worker_d:
			worker_d = d
			worker_target = u.global_position
	return worker_target

# --- capture --------------------------------------------------------------
func _manage_capture() -> void:
	# occasionally send a small squad to a neutral/enemy capture point
	if _army_size() < 4 or randf() > 0.15:
		return
	var points = world.get_tree().get_nodes_in_group("capture_points")
	for p in points:
		if is_instance_valid(p) and p.owner_team != commander.team:
			var squad := []
			for u in commander.units:
				if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero and u.state == u.State.IDLE:
					squad.append(u)
					if squad.size() >= 3:
						break
			for u in squad:
				u.command_move(p.global_position, true)
			return

# --- building placement ---------------------------------------------------
func _try_build(kind: String) -> void:
	if _build_cooldown > 0.0:
		return
	var bid := _building_id_for_kind(kind)
	if bid == "":
		return
	var bdef := GameData.get_building(bid)
	if not commander.can_afford(bdef.get("cost", {})):
		return
	var worker = _free_worker()
	if not worker:
		return
	var pos := _find_build_spot()
	if not world.can_place_building(bid, commander.team, pos, true, worker):
		_build_cooldown = 2.0
		return
	var b = world.place_building(bid, commander.team, pos)
	if b:
		worker.command_build(b)
		_build_cooldown = 3.0

func _find_build_spot() -> Vector3:
	# spiral out from base, avoid overlapping existing buildings
	for attempt in 20:
		var ang := randf() * TAU
		var dist := 12.0 + randf() * 22.0
		var p := _base_pos + Vector3(cos(ang) * dist, 0, sin(ang) * dist)
		p.x = clamp(p.x, -MapDefs.MAP_SIZE + 8, MapDefs.MAP_SIZE - 8)
		p.z = clamp(p.z, -MapDefs.MAP_SIZE + 8, MapDefs.MAP_SIZE - 8)
		if _spot_clear(p):
			return p
	return _base_pos + Vector3(randf_range(-15, 15), 0, randf_range(-15, 15))

func _spot_clear(p: Vector3) -> bool:
	for b in commander.buildings:
		if is_instance_valid(b) and not b.is_dead:
			if p.distance_to(b.global_position) < (float(b.def.get("footprint", 4.0)) + 5.0):
				return false
	return true

func _free_worker():
	# prefer an idle/gathering worker
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and u.is_worker and u.state != u.State.BUILDING:
			return u
	return null

# --- building lookup helpers ----------------------------------------------
func _building_id_for_kind(kind: String) -> String:
	for bid in GameData.buildings_for_race(commander.race):
		if GameData.get_building(bid).get("kind", "") == kind:
			return bid
	return ""

func _get_building_of_kind(kind: String):
	for b in commander.buildings:
		if is_instance_valid(b) and not b.is_dead and b.is_built and b.def.get("kind", "") == kind:
			return b
	return null

func _has_building_kind(kind: String) -> bool:
	for b in commander.buildings:
		if is_instance_valid(b) and not b.is_dead and b.def.get("kind", "") == kind:
			return true
	return false

func _count_building_kind(kind: String) -> int:
	var n := 0
	for b in commander.buildings:
		if is_instance_valid(b) and not b.is_dead and b.def.get("kind", "") == kind:
			n += 1
	return n
