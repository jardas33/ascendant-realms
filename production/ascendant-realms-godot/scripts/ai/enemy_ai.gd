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
# int(income * delta) was 0 every frame, so the trickle never paid; the
# fractions now accumulate.
var _brutal_gold_acc := 0.0
var _brutal_food_acc := 0.0

var _think_timer := 0.0
## Endless Road stages past the difficulty ladder feed the enemy extra Lume.
var endless_might := 0.0
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

## Seeded per AI from the match seed (see GameWorld.sim_seed_for).
var _rng := RandomNumberGenerator.new()

func setup(p_world, p_commander, p_difficulty: String) -> void:
	world = p_world
	commander = p_commander
	_rng.seed = world.sim_seed_for(1000 + int(commander.team)) if world.has_method("sim_seed_for") else 1000
	difficulty = p_difficulty
	_apply_difficulty()
	_apply_personality()
	_easy_mode = difficulty == "easy"
	_easy_rng.seed = _easy_seed + int(commander.team) * 101
	_base_pos = _find_hq_pos()
	_gather_share = _race_gather_share()
	_rally = _base_pos.lerp(Vector3.ZERO, 0.35)

## Faction personalities on top of difficulty: swarm factions attack early
## with smaller waves; the disciplined ones mass a bigger army first.
var _second_barracks_army := 6

func _apply_personality() -> void:
	match String(commander.race):
		"vorthak", "hollow", "wyldkin":
			_army_attack_size = maxi(4, _army_attack_size - 3)
		"grimtusk":
			# Early swarms win AI wars (the swarm factions took 42 of 72 pooled
			# games); Ironmaw, with the cheapest army, led every run (13-17 wins).
			# It now masses one soldier more before marching.
			_army_attack_size = maxi(4, _army_attack_size - 2)
		"sunspear", "karak", "sylvan":
			# Massing four extra soldiers lost the first fights to swarm
			# factions before the big army ever marched (1-7 records).
			# The Granitborn hold their walls and march at the usual size: massing
			# two extra soldiers left them 1-15 against early rushes.
			if String(commander.race) != "karak":
				_army_attack_size += 2
			# Extra mouths hurt once the home food runs dry (Karak 4-12-2 over
			# 90 matches); the Granitborn keep a standard workforce.
			if String(commander.race) != "karak":
				_worker_target += 2
		"frostborn":
			# The Careto chase winter out of the villages: they strike early too
			# (3-11-4 over 90 matches while waiting to mass).
			_army_attack_size = maxi(4, _army_attack_size - 2)
		"barrosan":
			# The clans strike early with cheap levies before the enemy masses.
			_army_attack_size = maxi(5, _army_attack_size - 2)
			# Their soldiers train slowly: a single War Hall fielded 4 men by
			# minute two against 8 to 12 from swarm factions. Raise a second
			# hall as soon as a few levies are out.
			_second_barracks_army = 2

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
	if endless_might > 0.0:
		_brutal_gold_acc += endless_might * delta
		_brutal_food_acc += endless_might * 0.6 * delta
		if _brutal_income <= 0.0:
			if _brutal_gold_acc >= 1.0:
				commander.add_resources("gold", int(_brutal_gold_acc))
				_brutal_gold_acc -= float(int(_brutal_gold_acc))
			if _brutal_food_acc >= 1.0:
				commander.add_resources("food", int(_brutal_food_acc))
				_brutal_food_acc -= float(int(_brutal_food_acc))
	# brutal passive trickle (labeled advantage)
	if _brutal_income > 0.0:
		_brutal_gold_acc += _brutal_income * delta
		_brutal_food_acc += _brutal_income * delta * 0.5
		if _brutal_gold_acc >= 1.0:
			commander.add_resources("gold", int(_brutal_gold_acc))
			_brutal_gold_acc -= float(int(_brutal_gold_acc))
		if _brutal_food_acc >= 1.0:
			commander.add_resources("food", int(_brutal_food_acc))
			_brutal_food_acc -= float(int(_brutal_food_acc))
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
	_rebalance_gatherers()
	_finish_abandoned_construction()
	_cancel_dead_sites()
	_manage_economy()
	_manage_tech()
	_manage_production()
	_manage_defense()
	_manage_offense()
	_cast_hero_spells()
	_manage_capture()
	_manage_veins()
	_send_vein_raid()
	_go_for_jars()

## Buried Lume jars: send the nearest idle soldiers to dig up a jar nobody of
## ours is working yet (only while at least six soldiers stand idle).
var _jar_timer := 0.0

func _go_for_jars() -> void:
	_jar_timer += _think_interval
	if _jar_timer < 5.0:
		return
	_jar_timer = 0.0
	var jars: Array = get_tree().get_nodes_in_group("lume_jars")
	if jars.is_empty():
		return
	var idle: Array = []
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero and u.state == u.State.IDLE:
			idle.append(u)
	if idle.size() < 6:
		return
	for jar in jars:
		if not is_instance_valid(jar):
			continue
		var jp: Vector3 = jar.global_position
		# Already on it?
		var near := 0
		for u in commander.units:
			if is_instance_valid(u) and not u.is_dead and not u.is_worker and u.global_position.distance_to(jp) < 12.0:
				near += 1
		if near >= 3:
			continue
		idle.sort_custom(func(a, b): return a.global_position.distance_squared_to(jp) < b.global_position.distance_squared_to(jp))
		for u in idle.slice(0, 4):
			u.command_move(jp + Vector3(_rng.randf_range(-2.0, 2.0), 0, _rng.randf_range(-2.0, 2.0)), true)
		return

## Raids: from minute five, every 90 s a handful of the fastest idle soldiers
## hits the nearest enemy outpost, so veins have to be defended.
var _raid_timer := 0.0

func _send_vein_raid() -> void:
	_raid_timer += _think_interval
	if _raid_timer < 90.0 or float(world.get("match_time")) < 300.0:
		return
	_raid_timer = 0.0
	var target = null
	var best_d := INF
	for b in world.all_buildings():
		if is_instance_valid(b) and not b.is_dead and b.team != commander.team and bool(b.def.get("vein_outpost", false)):
			var d: float = b.global_position.distance_to(_base_pos)
			if d < best_d:
				best_d = d
				target = b
	if target == null:
		return
	var soldiers: Array = []
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero and u.state == u.State.IDLE:
			soldiers.append(u)
	if soldiers.size() < 6:
		return
	soldiers.sort_custom(func(a, b): return float(a.move_speed) > float(b.move_speed))
	for u in soldiers.slice(0, 3 + int(float(world.get("match_time")) / 600.0)):
		u.command_attack(target)

## Veins (docs/claude/RESOURCE_DESIGN.md): from minute two and a half the AI
## claims the free veins on its side of the map, staffs its outposts from the
## gatherers it can spare (always keeping six at home), and expands them when
## stores pile up. Enemy outposts are buildings, so its waves raid them too.
var _vein_timer := 0.0

func _manage_veins() -> void:
	_vein_timer += _think_interval
	if _vein_timer < 3.0:
		return
	_vein_timer = 0.0
	if float(world.get("match_time")) < 150.0 or not world.has_method("vein_near"):
		return
	_caravan_trade()
	var oid := "%s_outpost" % String(commander.race)
	if GameData.get_building(oid).is_empty():
		return
	var outposts: Array = []
	var building_one := false
	for b in commander.buildings:
		if is_instance_valid(b) and not b.is_dead and bool(b.def.get("vein_outpost", false)):
			if b.is_built:
				outposts.append(b)
			else:
				building_one = true
	# Claim: the nearest free vein that is closer to us than to any enemy start.
	var home_workers := _worker_count()
	var max_outposts := 1 + int(float(world.get("match_time")) / 300.0)
	# Only open another outpost once the last ones are mostly staffed.
	var empty_slots := 0
	for ob in outposts:
		empty_slots += ob.outpost_slots() - ob.garrison.size()
	if not building_one and empty_slots <= 1 and outposts.size() < max_outposts and home_workers >= 8 and commander.can_afford(GameData.get_building(oid).get("cost", {})):
		var best = null
		var best_d := INF
		for v in get_tree().get_nodes_in_group("veins"):
			if not v.is_free() or int(v.amount) <= 0:
				continue
			var d: float = v.global_position.distance_to(_base_pos)
			var nearer_enemy := false
			for i in world.commanders.size():
				if i == commander.team:
					continue
				var es: Vector3 = world.map.get("start_positions", [])[i] if i < world.map.get("start_positions", []).size() else Vector3.INF
				if v.global_position.distance_to(es) < d:
					nearer_enemy = true
			# Prefer the vein of whatever the stores are shortest of (a
			# Barrosan AI claimed stone and gold while starving on food).
			# Weight by what the faction spends too: every army eats food, and
			# a Frostborn AI claimed stone and gold veins while food sat at 12.
			var score := d - (60.0 if String(v.kind) == _needed_resource() else 0.0) - 140.0 * float(_gather_share.get(String(v.kind), 0.2)) - (90.0 if String(v.kind) == "food" else 0.0)
			if not nearer_enemy and score < best_d:
				best_d = score
				best = v
		var w = _free_worker()
		if best and w:
			var ob = world.place_building(oid, commander.team, best.global_position)
			if ob:
				w.command_build(ob)
	# Staff: fill outposts from spare gatherers, keeping six at home.
	var starving := false
	for k in commander.resources:
		if int(commander.resources[k]) < 80:
			starving = true
	for ob in outposts:
		# A Frostborn AI starved on 2 food with 1,900 stone banked: its stone
		# outpost kept four workers busy on a glut. While some store is empty,
		# a glutted vein's workers come home to gather what is short.
		var ob_vein = ob.get_meta("vein") if ob.has_meta("vein") else null
		var glut: bool = ob_vein != null and is_instance_valid(ob_vein) and int(commander.resources.get(String(ob_vein.kind), 0)) > 700
		if glut:
			if starving and not ob.garrison.is_empty():
				ob.release_garrison()
			continue
		# Expand once it is full and the stores allow it.
		if ob.garrison.size() >= ob.outpost_slots() and ob.outpost_level < ob.OUTPOST_MAX_LEVEL and commander.can_afford(ob.outpost_expand_cost()):
			ob.expand_outpost()
		var free_slots: int = ob.outpost_slots() - ob.garrison.size()
		var heading := 0
		for u in commander.units:
			if is_instance_valid(u) and (u.get_meta("garrison_target") if u.has_meta("garrison_target") else null) == ob:
				heading += 1
		free_slots -= heading
		if free_slots <= 0:
			continue
		var spare: Array = []
		var gatherers := 0
		for u in commander.units:
			if is_instance_valid(u) and not u.is_dead and u.is_worker and u.state != u.State.BUILDING and (u.get_meta("garrison_target") if u.has_meta("garrison_target") else null) == null:
				gatherers += 1
				spare.append(u)
		var can_send := mini(free_slots, gatherers - 6)
		if can_send <= 0:
			continue
		spare.sort_custom(func(a, b): return a.global_position.distance_squared_to(ob.global_position) < b.global_position.distance_squared_to(ob.global_position))
		world.command_bus.execute({"type": "garrison", "units": spare.slice(0, can_send), "target": ob})

## Spend a gold hoard at the caravan on whatever store is running dry. A
## Karak AI won the early war, then stalled on 1 stone and 20 timber with
## 4,400 gold banked.
func _caravan_trade() -> void:
	if not commander.has_method("trade_gold_for"):
		return
	var hq = null
	for b in commander.buildings:
		if is_instance_valid(b) and not b.is_dead and b.is_built and bool(b.def.get("is_hq", false)):
			hq = b
			break
	if hq == null:
		return
	# Short on gold but sitting on a pile of something else: sell the pile.
	if int(commander.resources.get("gold", 0)) < 120:
		for k in ["stone", "timber", "food"]:
			if int(commander.resources.get(k, 0)) > 900:
				world.command_bus.execute({"type": "trade", "target": hq, "id": "sell_" + k})
				return
	for i in 2:
		var price: int = commander.trade_price()
		if int(commander.resources.get("gold", 0)) < price + 250:
			return
		var low := ""
		var low_amt := 150
		for k in ["food", "timber", "stone"]:
			if int(commander.resources.get(k, 0)) < low_amt:
				low = k
				low_amt = int(commander.resources.get(k, 0))
		if low == "":
			return
		world.command_bus.execute({"type": "trade", "target": hq, "id": low})

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
	_manage_easy_followup_waves()

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

var _easy_stage_started := -1.0
var _easy_next_wave := -1.0

## Easy only ever sent its first wave; after it broke, the army idled at the
## rally point for the rest of the match. Every 150 s it now attacks again
## with the whole idle army once that army reaches wave size.
func _manage_easy_followup_waves() -> void:
	if not _easy_wave_launched:
		return
	if _easy_next_wave < 0.0:
		_easy_next_wave = _easy_elapsed + 150.0
		return
	if _easy_elapsed < _easy_next_wave:
		return
	var idle: Array = []
	for u in _easy_army():
		if is_instance_valid(u) and not u.is_dead and u.state == u.State.IDLE:
			idle.append(u)
	if idle.size() < _army_attack_size:
		return
	var target := _find_player_target()
	if target == Vector3.ZERO:
		return
	for u in idle:
		u.command_move(target, true)
	_easy_next_wave = _easy_elapsed + 150.0

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
		# One soldier that could not reach the rally point held the Easy wave
		# back forever: a new player saw no attack in fifteen minutes. After
		# 40 s of staging the wave goes with whoever is there.
		if _easy_stage_started < 0.0:
			_easy_stage_started = _easy_elapsed
		if not staged and _easy_elapsed - _easy_stage_started < 40.0:
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
	var player_commander = null
	if world.commanders.size() > 0:
		player_commander = world.commanders[0]
	if is_instance_valid(player_commander) and not player_commander.defeated:
		var fallback := Vector3.ZERO
		for b in player_commander.buildings:
			if not is_instance_valid(b) or b.is_dead or not b.is_built:
				continue
			if fallback == Vector3.ZERO:
				fallback = b.global_position
			if b.def.get("is_hq", false) or b.def.get("kind", "") == "main":
				return b.global_position
		if fallback != Vector3.ZERO:
			return fallback
	# Easy keeps its current building/HQ priority, but must still be able to
	# deliberately hunt a live hostile Worker after buildings are exhausted.
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead or not u.is_worker or u.team == commander.team:
			continue
		var worker_commander = world.commander_for_team(u.team)
		if not is_instance_valid(worker_commander) or worker_commander.defeated:
			continue
		return u.global_position
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
			# A refused order (a node out of reach or out of sight) left the
			# worker idle, and the next think chose the same node again: a
			# Barrosan AI had 7 of 15 workers standing by an unusable quarry.
			# Try the needed resource first, then the others, nearest first.
			var kinds: Array = [_needed_resource()]
			for k in ["food", "timber", "gold", "stone"]:
				if not kinds.has(k):
					kinds.append(k)
			for kind in kinds:
				var node = world.find_nearest_resource_exact(u.global_position, kind)
				if node:
					u.command_gather(node)
					if u.state != u.State.IDLE:
						break

# Workers only took new jobs when idle, and a gathering worker never goes
# idle, so the first assignment stuck forever. Fixed thresholds were not
# enough either: a Barrosan AI sat on 180 gold (above "short") all game and
# could not afford soldiers. Each think now moves at most one gatherer toward
# a target share per resource, scaled by how full each stockpile is.
const GATHER_SHARE := {"food": 0.35, "timber": 0.25, "gold": 0.25, "stone": 0.15}

## Gather shares shaped by what this faction actually spends. One fixed split
## sent a quarter of the Barrosan workers to gold its soldiers barely use: it
## sat on 700 gold with 30 food while its army starved.
var _gather_share: Dictionary = {}

func _race_gather_share() -> Dictionary:
	var need := {"food": 0.0, "timber": 0.0, "stone": 0.0, "gold": 0.0}
	var race_def: Dictionary = GameData.get_race(commander.race)
	var worker: Dictionary = GameData.get_unit(String(race_def.get("worker", "")))
	for k in worker.get("cost", {}):
		need[k] = float(need.get(k, 0.0)) + float(worker["cost"][k]) * 2.0
	for bid in GameData.buildings_for_race(commander.race):
		var bd: Dictionary = GameData.get_building(bid)
		if String(bd.get("kind", "")) == "barracks":
			for uid in bd.get("produces", []):
				var ud: Dictionary = GameData.get_unit(String(uid))
				var weight := 2.0 if int(ud.get("tier", 1)) == 1 else 1.0
				for k in ud.get("cost", {}):
					need[k] = float(need.get(k, 0.0)) + float(ud["cost"][k]) * weight
		if String(bd.get("kind", "")) == "house":
			for k in bd.get("cost", {}):
				need[k] = float(need.get(k, 0.0)) + float(bd["cost"][k]) * 1.5
		elif String(bd.get("kind", "")) != "main":
			# Every other building counts too. Barrosan soldiers cost no stone, so
			# the old unit-only split sent almost nobody to the quarry; their halls,
			# towers and upgrades then stalled (stone near zero 24% of the time,
			# half the army of other factions over 16 logged matches).
			for k in bd.get("cost", {}):
				need[k] = float(need.get(k, 0.0)) + float(bd["cost"][k]) * 0.5
	var total := 0.0
	for k in need:
		total += float(need[k])
	var out := {}
	for k in GATHER_SHARE:
		var spent: float = float(need.get(k, 0.0)) / maxf(1.0, total)
		out[k] = maxf(0.08, 0.5 * float(GATHER_SHARE[k]) + 0.5 * spent)
	return out

func _rebalance_gatherers() -> void:
	var crews := {"food": [], "timber": [], "stone": [], "gold": []}
	var total := 0
	for u in commander.units:
		if not is_instance_valid(u) or u.is_dead or not u.is_worker:
			continue
		if u.state != u.State.GATHERING and u.state != u.State.RETURNING:
			continue
		var kind := String(u.get("_desired_gather_kind"))
		if crews.has(kind):
			crews[kind].append(u)
			total += 1
	if total < 3:
		return
	var r = commander.resources
	var short := ""
	var short_gap := 0.99
	var donor := ""
	var donor_gap := -0.99
	for k in crews:
		var stock := int(r.get(k, 0))
		# A Karak AI starved on 0 food and 10 timber while 900 gold sat
		# unspent: a big stockpile now releases its gatherers much sooner.
		var pressure := 1.7 if stock < 150 else (1.2 if stock < 350 else (0.6 if stock < 600 else 0.15))
		var gap: float = float(_gather_share.get(k, GATHER_SHARE[k])) * float(total) * pressure - float(crews[k].size())
		if gap > short_gap:
			short = k
			short_gap = gap
		if gap < donor_gap and crews[k].size() >= 1:
			donor = k
			donor_gap = gap
	if short == "" or donor == "" or short == donor:
		return
	# Move two at once when one stock is starving and another is piled high.
	var moves := 2 if int(r.get(short, 0)) < 100 and int(r.get(donor, 0)) > 500 else 1
	for u in crews[donor]:
		var node = world.find_nearest_resource(u.global_position, short)
		if node:
			u.command_gather(node)
			moves -= 1
			if moves <= 0:
				return

# A worker pulled off a construction site (or killed) left the site unbuilt
# for the rest of the match. Send the nearest free worker back to finish it.
func _finish_abandoned_construction() -> void:
	for b in commander.buildings:
		if not is_instance_valid(b) or b.is_dead or b.is_built:
			continue
		var staffed := false
		for u in commander.units:
			if is_instance_valid(u) and not u.is_dead and u.is_worker and u.state == u.State.BUILDING and u.get("_build_target") == b:
				staffed = true
				break
		if staffed:
			continue
		var best = null
		var best_d := INF
		for u in commander.units:
			if is_instance_valid(u) and not u.is_dead and u.is_worker and u.state != u.State.BUILDING:
				var d: float = u.global_position.distance_squared_to(b.global_position)
				if d < best_d:
					best_d = d
					best = u
		if best:
			best.command_build(b)
		return

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
	# Workers inside vein outposts do not count against the home crew.
	var inside := 0
	for b in commander.buildings:
		if is_instance_valid(b) and not b.is_dead and bool(b.def.get("vein_outpost", false)):
			inside += b.garrison.size()
	if hq and _worker_count() < _worker_target + inside:
		if hq.queue.size() < 2:
			var wid = GameData.get_race(commander.race).get("worker", "")
			hq.queue_unit(wid)
	# build houses when near pop cap
	# Plan housing early: factions whose soldiers take 2 population (Barrosan
	# Spear Guard, Outrider) hit the cap long before a late house went up.
	if commander.pop_used >= commander.pop_cap - 6 and commander.pop_cap < commander.POP_HARD_CAP:
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
	# ...and for anyone whose resources pile up faster than one barracks can
	# spend them (a Barrosan AI sat on 400+ food with 3 soldiers).
	var piling: bool = int(commander.resources.get("food", 0)) > 350 and int(commander.resources.get("timber", 0)) > 250
	if _count_building_kind("barracks") < 2 and ((_tech_aggression >= 1.4 and _army_size() > _second_barracks_army) or piling):
		_try_build("barracks")

	# A side reduced to a handful of workers spent every scrap of food on
	# replacement soldiers and never rebuilt its economy: matches deadlocked
	# with 0 workers and thousands of unspent gold. Workers come first.
	if _worker_count() < mini(6, _worker_target) and _get_building_of_kind("main") != null:
		return
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
	# Counter the enemy: favour damage types that hit the most common armour in
	# the opposing army hardest (slash into Vorthak's unarmoured swarm, pierce
	# into light troops), still leaning toward higher tiers, with some variety.
	var dominant := _dominant_enemy_armor()
	legal.sort_custom(func(a, b):
		var da := GameData.get_unit(a)
		var db := GameData.get_unit(b)
		var sa := GameData.damage_multiplier(String(da.get("dmg_type", "slash")), dominant) * (1.0 + 0.15 * float(da.get("tier", 1)))
		var sb := GameData.damage_multiplier(String(db.get("dmg_type", "slash")), dominant) * (1.0 + 0.15 * float(db.get("tier", 1)))
		return sa > sb)
	# Keep about a third of the army at range. All-melee armies (Barrosan,
	# Karak, Frostborn picks) could not answer archers raiding their workers.
	var ranged_now := 0
	var army_now := 0
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
			army_now += 1
			if float(u.atk_range) > 0.0:
				ranged_now += 1
	if army_now >= 3 and float(ranged_now) / float(army_now) < 0.35:
		var ranged_picks := legal.filter(func(c): return float(GameData.get_unit(c).get("range", 0.0)) > 0.0)
		if not ranged_picks.is_empty() and _rng.randf() < 0.75:
			return ranged_picks[0]
	# Bring a couple of siege engines once the war drags on. A Barrosan AI
	# out-numbered Vorthak three to one from minute 8 but kept breaking its
	# army on towers and never finished the match (6-12-9 over 135 matches).
	if float(world.get("match_time")) > 480.0:
		var siege_now := 0
		for u in commander.units:
			if is_instance_valid(u) and not u.is_dead and String(u.def.get("role", "")) == "siege":
				siege_now += 1
		if siege_now < 2:
			var siege_picks := legal.filter(func(c): return String(GameData.get_unit(c).get("role", "")) == "siege")
			if not siege_picks.is_empty() and _rng.randf() < 0.5:
				return siege_picks[0]
	if _rng.randf() < 0.6:
		return legal[0]
	return legal[_rng.randi() % legal.size()]

func _dominant_enemy_armor() -> String:
	var counts := {}
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead or u.team == commander.team or u.is_worker:
			continue
		var ac := String(u.armor_class)
		counts[ac] = int(counts.get(ac, 0)) + 1
	var best := "light"
	var best_n := -1
	for k in counts:
		if int(counts[k]) > best_n:
			best = k
			best_n = int(counts[k])
	return best

# --- defense --------------------------------------------------------------
func _manage_defense() -> void:
	# build a tower or two near base early-mid
	# Housing comes first: towers built while capped at population starved
	# the army (a Barrosan AI sat at 20/20 with two new towers).
	if _count_building_kind("tower") < (2 if _tech_aggression >= 1.0 else 1) and _worker_count() >= 5 and commander.pop_used < commander.pop_cap - 3:
		if _rng.randf() < 0.4:
			_try_build("tower")
	# Recall the army to defend. Raiders used to kill the workers at outlying
	# fields and houses unanswered: only enemies within 30 m of the main hall
	# counted, and only soldiers within 45 m answered, which left out the army
	# waiting at its rally point about 50 m out. Now any enemy near a building
	# of ours, or near a worker that was just hit, is a threat, and every
	# soldier not already away on an attack answers.
	var threat = world.find_enemy_near(_base_pos, 34.0, commander.team)
	if threat == null:
		for b in commander.buildings:
			if is_instance_valid(b) and not b.is_dead and b.global_position.distance_to(_base_pos) < 70.0:
				threat = world.find_enemy_near(b.global_position, 14.0, commander.team)
				if threat:
					break
	# Workers under fire run home instead of dying at the field: raiders
	# killed 36 of one Barrosan AI's workers in a single match.
	var now := Time.get_ticks_msec()
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and u.is_worker and u.state != u.State.BUILDING and now - int(u.get("_last_damaged_msec")) < int(2500.0 / maxf(0.01, Engine.time_scale)):
			var raider = world.find_enemy_near(u.global_position, 14.0, commander.team)
			# Archers shoot from beyond 14 m: answer whoever actually hit the worker.
			var hitter = u.get("last_attacker")
			if raider == null and hitter != null and is_instance_valid(hitter) and not bool(hitter.get("is_dead")) and hitter.global_position.distance_to(u.global_position) < 40.0:
				raider = hitter
			if raider:
				if threat == null:
					threat = raider
				if u.global_position.distance_to(_base_pos) > 12.0:
					u.command_move(_base_pos + (u.global_position - _base_pos).normalized() * 6.0)
	if threat:
		for u in commander.units:
			if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
				if u.global_position.distance_to(threat.global_position) < 80.0 and u.global_position.distance_to(_base_pos) < 85.0:
					u.command_attack(threat)

# --- offense --------------------------------------------------------------
func _army_size() -> int:
	var n := 0
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
			n += 1
	return n

func _manage_offense() -> void:
	_press_the_siege()
	var size := _army_size()
	# Waves grow a little, but not without bound: the old +2 per wave soon
	# asked for more troops than the AI could keep alive, so it stopped attacking.
	var needed := _army_attack_size + mini(_wave_number, 3) * 2
	# Evenly matched sides could trade waves for half an hour. After fifteen
	# minutes every AI commits whatever army it has.
	if float(world.get("match_time")) > 900.0:
		needed = mini(needed, 8)
	# Past twenty minutes, any four soldiers march: vein economies made both
	# sides defend so well that a quarter of AI matches never ended.
	if float(world.get("match_time")) > 1200.0:
		needed = mini(needed, 4)
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

## Soldiers that attack-moved to an enemy base went idle on arrival and
## stood beside buildings without hitting them, so matches never ended.
## Idle soldiers near a hostile building now attack the nearest one.
func _press_the_siege() -> void:
	var buildings: Array = []
	for b in world.all_buildings():
		# Unbuilt sites count too: a lone construction site kept a beaten
		# opponent alive under conquest while the attackers ignored it.
		if is_instance_valid(b) and not b.is_dead and b.team != commander.team:
			buildings.append(b)
	if buildings.is_empty():
		return
	for u in commander.units:
		if not is_instance_valid(u) or u.is_dead or u.is_worker or u.state != u.State.IDLE:
			continue
		if u.global_position.distance_to(_base_pos) < 35.0:
			continue
		var best = null
		var best_d := 30.0
		for b in buildings:
			var d: float = u.global_position.distance_to(b.global_position)
			if d < best_d:
				best_d = d
				best = b
		if best:
			u.command_attack(best)

func _launch_attack() -> void:
	var target := _pick_attack_target()
	if target == Vector3.ZERO:
		return
	# multi-prong on hard+: split army
	var soldiers := []
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker:
			soldiers.append(u)
	# A home guard stays behind: raiders killed 30 or more workers a match
	# while every soldier marched off. The ranged soldiers nearest home (a
	# fifth of the army, at least two once it is big enough) hold the fields.
	var guard_n := 0 if soldiers.size() < 6 else maxi(2, soldiers.size() / 5)
	# After fifteen minutes every AI commits everything (evenly matched sides
	# otherwise traded waves until the clock ran out).
	if float(world.get("match_time")) > 900.0:
		guard_n = 0
	soldiers.sort_custom(func(a, b):
		var ra: int = 0 if float(a.atk_range) > 0.0 else 1
		var rb: int = 0 if float(b.atk_range) > 0.0 else 1
		if ra != rb:
			return ra < rb
		return a.global_position.distance_squared_to(_base_pos) < b.global_position.distance_squared_to(_base_pos))
	var guard_post := _base_pos.lerp(Vector3.ZERO, 0.12)
	for i in soldiers.size():
		var u = soldiers[i]
		if i < guard_n:
			u.set_meta("ai_home_guard", true)
			if u.global_position.distance_to(guard_post) > 10.0:
				u.command_move(guard_post, true)
		else:
			u.set_meta("ai_home_guard", false)
			u.command_move(target, true)
	# hero joins the push
	if is_instance_valid(commander.hero_ref) and not commander.hero_ref.is_dead:
		commander.hero_ref.command_move(target, true)

func _pick_attack_target() -> Vector3:
	# Preserve the existing nearest built hostile Building priority.
	var best := Vector3.ZERO
	var best_d := INF
	for b in world.all_buildings():
		if not is_instance_valid(b) or b.is_dead or b.team == commander.team:
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
	if _army_size() < 4 or _rng.randf() > 0.15:
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
			# Stand inside the 7.5 m capture ring on the near side, not on the
			# landmark itself: the centre is solid, so squads sent there pushed
			# against it in attack-move forever and were lost to the AI.
			var side: Vector3 = (_base_pos - p.global_position)
			side.y = 0.0
			var spot: Vector3 = p.global_position + (side.normalized() if side.length() > 0.1 else Vector3.RIGHT) * 4.5
			for u in squad:
				u.command_move(spot, true)
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
	# Finish what is already laid out before starting more sites.
	# ...except a house when the population is capped: a Barrosan AI sat at
	# 12/12 for minutes with 650 food, its house queued behind slow sites.
	var needs_house: bool = commander.pop_used >= commander.pop_cap - 6 and commander.pop_cap < commander.POP_HARD_CAP
	# Houses first: nothing else is started while the army needs room.
	if needs_house and kind != "house" and kind != "barracks":
		return
	var housing_crisis: bool = kind == "house" and needs_house and _unbuilt_count() < 4
	if _unbuilt_count() >= 2 and not housing_crisis:
		return
	var worker = _free_worker()
	if not worker:
		return
	# Barrosan bases are ringed by hamlet dressing, and one blocked spot cost a
	# 2 s pause: its houses lagged and the army sat population-capped. Try
	# several spots before pausing.
	var pos := Vector3.ZERO
	var placed_ok := false
	for _try in 4:
		pos = _find_build_spot(float(bdef.get("footprint", 4.0)))
		if world.can_place_building(bid, commander.team, pos, true, worker) and _reachable(worker.global_position, pos, float(bdef.get("footprint", 4.0))):
			placed_ok = true
			break
	if not placed_ok:
		_build_cooldown = 2.0
		return
	var b = world.place_building(bid, commander.team, pos)
	if b:
		b.set_meta("ai_placed_msec", Time.get_ticks_msec())
		worker.command_build(b)
		# Houses are the bottleneck when the population is capped: send a second
		# builder (the Barrosan AI sat capped for minutes waiting on one).
		if kind == "house" and commander.pop_used >= commander.pop_cap - 4:
			for u in commander.units:
				if is_instance_valid(u) and not u.is_dead and u.is_worker and u != worker and u.state != u.State.BUILDING:
					u.command_build(b)
					break
		_build_cooldown = 3.0
	else:
		# A refused placement (a race to the same spot, or a guard in the
		# world) was retried every think with no pause.
		_build_cooldown = 2.0

func _unbuilt_count() -> int:
	var n := 0
	for b in commander.buildings:
		if is_instance_valid(b) and not b.is_dead and not b.is_built:
			n += 1
	return n

# A site nobody has managed to start after 90 s of game time is unreachable:
# cancel it and take the materials back so the economy is not locked up.
func _cancel_dead_sites() -> void:
	for b in commander.buildings.duplicate():
		if not is_instance_valid(b) or b.is_dead or b.is_built or not b.has_meta("ai_placed_msec"):
			continue
		# A site a builder touched once and then could not reach again sat at a
		# sliver of progress forever, and the AI counted it as a working
		# barracks. Cancel any site whose progress has not moved for 75 s.
		var now := Time.get_ticks_msec()
		if b.build_progress > float(b.get_meta("ai_last_progress", -1.0)) + 0.001:
			b.set_meta("ai_last_progress", b.build_progress)
			b.set_meta("ai_progress_msec", now)
		var stalled := float(now - int(b.get_meta("ai_progress_msec", b.get_meta("ai_placed_msec")))) / 1000.0 * Engine.time_scale
		if stalled > 75.0:
			commander.refund(b.def.get("cost", {}), clampf(1.0 - b.build_progress, 0.0, 1.0))
			b._destroy(null)
			return

## Sites across the Barrosan settlement dressing could be placed but never
## reached: the builder stalled half way and the base sat at its population
## cap. Only accept spots with a real, reasonably direct path.
func _reachable(from: Vector3, to: Vector3, footprint: float) -> bool:
	var rid = world.get("navigation_map_rid")
	if rid == null or not rid.is_valid():
		return true
	var path := NavigationServer3D.map_get_path(rid, from, to, true)
	if path.is_empty():
		return false
	if Vector3(path[path.size() - 1].x, 0.0, path[path.size() - 1].z).distance_to(Vector3(to.x, 0.0, to.z)) > footprint + 2.5:
		return false
	var length := 0.0
	for i in range(1, path.size()):
		length += path[i - 1].distance_to(path[i])
	return length <= from.distance_to(to) * 1.8 + 6.0

var _spot_resources: Array = []
var _spot_blockers: Array = []
const SPOT_WALK_GAP := 4.5

func _find_build_spot(footprint: float = 4.0) -> Vector3:
	# One resource list per search (it was fetched for every candidate spot,
	# which made AI build decisions spike to hundreds of milliseconds).
	_spot_resources = get_tree().get_nodes_in_group("resources")
	_spot_blockers = world._navigation_blocker_snapshots() if world.has_method("_navigation_blocker_snapshots") else []
	# spiral out from base, avoid overlapping existing buildings
	# Build on the side of the base that faces the battlefield. The rear of
	# each start holds the settlement dressing (hamlet, holdfast, grove), and
	# sites placed there could be walled off so the builder never arrived.
	var toward := atan2(-_base_pos.z, -_base_pos.x)
	# Later attempts reach further out, so a crowded base grows outward
	# instead of cramming buildings together.
	for attempt in 24:
		var ang := toward + _rng.randf_range(-1.0, 1.0) * (0.9 + attempt * 0.03)
		var dist := 12.0 + attempt * 1.05 + _rng.randf() * 14.0
		var p := _base_pos + Vector3(cos(ang) * dist, 0, sin(ang) * dist)
		p.x = clamp(p.x, -MapDefs.MAP_SIZE + 8, MapDefs.MAP_SIZE - 8)
		p.z = clamp(p.z, -MapDefs.MAP_SIZE + 8, MapDefs.MAP_SIZE - 8)
		if _spot_clear(p, footprint):
			return p
	return _base_pos + Vector3(cos(toward), 0, sin(toward)) * 16.0 + Vector3(_rng.randf_range(-6, 6), 0, _rng.randf_range(-6, 6))

## Units wedged between tightly packed buildings in their own base. Keep a
## walking lane between both footprints, and stay off resource nodes.
func _spot_clear(p: Vector3, footprint: float = 4.0) -> bool:
	# Units route around buildings as rectangles (visual size included), so a
	# round spacing check still let corners overlap diagonally and sealed the
	# army inside its own base for the rest of the match. Keep a real walking
	# gap between rectangles against every building and settlement blocker.
	var half := footprint * 1.15
	for blocker in _spot_blockers:
		var node = blocker.get("node")
		if not is_instance_valid(node) or node.is_in_group("resources"):
			continue
		var c: Vector3 = blocker.get("center", node.global_position)
		var he: Vector2 = blocker.get("half_extents", Vector2(4.0, 4.0))
		var gap := maxf(absf(p.x - c.x) - half - he.x, absf(p.z - c.z) - half - he.y)
		if gap < SPOT_WALK_GAP:
			return false
	for r in _spot_resources:
		if not is_instance_valid(r):
			continue
		if p.distance_to(r.global_position) < footprint + 4.0:
			return false
		# Keep the gathering lanes open: a house dropped between the stronghold
		# and its food or gold walled the workers off for the whole match.
		if r.global_position.distance_to(_base_pos) < 45.0 and _segment_distance_xz(p, _base_pos, r.global_position) < footprint + 3.0:
			return false
	# Keep the army's road out open: buildings dropped between the stronghold
	# and the battlefield trapped a Barrosan army circling inside its own base.
	var exit_end := _base_pos + (Vector3.ZERO - _base_pos).normalized() * 45.0
	if _segment_distance_xz(p, _base_pos, exit_end) < footprint + 6.0:
		return false
	return true

static func _segment_distance_xz(p: Vector3, a: Vector3, b: Vector3) -> float:
	var pa := Vector2(p.x - a.x, p.z - a.z)
	var ba := Vector2(b.x - a.x, b.z - a.z)
	var h := clampf(pa.dot(ba) / maxf(ba.length_squared(), 0.0001), 0.0, 1.0)
	return (pa - ba * h).length()

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

# --- hero spells ------------------------------------------------------------
## Enemy heroes fight like the player's: spend mana on their kit whenever a
## fight is on. One cast per think, most useful first.
func _cast_hero_spells() -> void:
	var hero = commander.hero_ref
	if not is_instance_valid(hero) or hero.is_dead:
		return
	# A badly hurt hero falls back to the stronghold to recover instead of
	# dying for nothing; the next wave takes them along again.
	if hero.hp < hero.max_hp * 0.3 and hero.global_position.distance_to(_base_pos) > 25.0 and not hero.can_cast("heal"):
		if not bool(hero.get_meta("ai_retreating", false)):
			hero.set_meta("ai_retreating", true)
			hero.command_move(_base_pos, false)
		return
	if hero.hp > hero.max_hp * 0.8:
		hero.set_meta("ai_retreating", false)
	if hero.abilities.is_empty():
		return
	var near_enemies: Array = []
	var near_allies := 0
	for u in get_tree().get_nodes_in_group("units"):
		if not is_instance_valid(u) or u.is_dead or u == hero:
			continue
		var d: float = u.global_position.distance_to(hero.global_position)
		if d > 18.0:
			continue
		if int(u.team) == int(commander.team):
			near_allies += 1
		else:
			near_enemies.append(u)
	if near_enemies.is_empty():
		return
	var close := near_enemies.filter(func(e): return e.global_position.distance_to(hero.global_position) <= 7.0)
	# Spells go at soldiers first: an AI hero that bolted the nearest target
	# spent the match one-shotting workers (25 of one side's in a single game).
	var soldiers := near_enemies.filter(func(e): return not bool(e.get("is_worker")))
	var pool: Array = soldiers if not soldiers.is_empty() else near_enemies
	var nearest = pool[0]
	for e in pool:
		if e.global_position.distance_to(hero.global_position) < nearest.global_position.distance_to(hero.global_position):
			nearest = e
	var hurt: bool = hero.hp < hero.max_hp * 0.6
	for id in ["heal", "slam", "root", "charge", "rally", "bolt"]:
		if not hero.can_cast(id):
			continue
		var ok := false
		var at: Vector3 = hero.global_position
		match id:
			"heal":
				ok = hurt or near_allies >= 5
			"rally":
				ok = near_allies >= 3
			"slam":
				ok = close.size() >= 3
			"root":
				ok = near_enemies.size() >= 3
				at = nearest.global_position
			"charge", "bolt":
				ok = true
				at = nearest.global_position
		if ok and hero.cast_ability(id, at):
			return
