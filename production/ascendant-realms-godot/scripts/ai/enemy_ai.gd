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
		"hollow":
			_army_attack_size = maxi(4, _army_attack_size - 3)
		"vorthak":
			# First or second in five checks running on the AI of plans 95 to
			# 99 (61-29): its first wave waits for one soldier more.
			_army_attack_size = maxi(4, _army_attack_size - 2)
		"wyldkin":
			# The pack still strikes first, but with one soldier fewer than the
			# usual wave, not three: an early wave led by a hero that has to
			# walk into the towers lost its army and its hero (6-12 once the AI
			# of plans 95 to 97 played everyone properly).
			_army_attack_size = maxi(4, _army_attack_size - 1)
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
			# The Moura Court too: 2-15-1 over 90 clean matches, capped at 28
			# people by its 16 workers while swarms of 17 arrived at minute four.
			# The Aurean Dominion as well, since plan 96: massing two more and
			# feeding two more workers left it 7-27-2 over 180 matches. All three
			# march at the usual size with the usual workforce.
			pass
		"frostborn":
			# The Careto chase winter out of the villages: they strike early too
			# (3-11-4 over 90 matches while waiting to mass).
			# That was measured on the old AI. On the AI of plans 95 to 97 the
			# early wave is what loses: last in six checks running, 5-13 even
			# with 15% more damage and 20% more health. They march at the usual
			# size now.
			pass
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
	# Who can go: soldiers with nothing to do, the home guard, and anyone who
	# is already close by. (Only idle soldiers used to be asked, six at least,
	# and an army that is always on the march has none: no AI dug up a single
	# jar in most matches.)
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
		var pool: Array = []
		for u in commander.units:
			if not is_instance_valid(u) or u.is_dead or u.is_worker or u.is_hero:
				continue
			var d: float = u.global_position.distance_to(jp)
			if d < 45.0 or (d < 130.0 and (u.state == u.State.IDLE or (u.has_meta("ai_home_guard") and bool(u.get_meta("ai_home_guard"))))):
				pool.append(u)
		if pool.size() < 3:
			continue
		pool.sort_custom(func(a, b): return a.global_position.distance_squared_to(jp) < b.global_position.distance_squared_to(jp))
		for u in pool.slice(0, 4):
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
	# The deposits round a hall last about four and a half minutes with a full
	# crew. The AI used to allow itself one outpost until minute five and two
	# until minute ten, and kept six workers "at home" whatever was left
	# there: from minute five it had two workers in a vein and thirteen
	# standing idle, for the rest of the match. It now opens an outpost for
	# every kind that has run dry at home, on top of one every four minutes.
	var dry_kinds: Array = []
	for k in ["food", "timber", "stone", "gold"]:
		if not _home_has(k):
			dry_kinds.append(k)
	var max_outposts := clampi(1 + int(float(world.get("match_time")) / 240.0) + dry_kinds.size(), 1, 6)
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
				# Well on our side of the field, not merely nearer to us: an
				# outpost at the halfway line was a march through the fighting
				# for every worker sent to raise or staff it.
				if v.global_position.distance_to(es) < d * 1.6:
					nearer_enemy = true
			# Prefer the vein of whatever the stores are shortest of (a
			# Barrosan AI claimed stone and gold while starving on food).
			# Weight by what the faction spends too: every army eats food, and
			# a Frostborn AI claimed stone and gold veins while food sat at 12.
			var score := d - (60.0 if String(v.kind) == _needed_resource() else 0.0) - 140.0 * float(_gather_share.get(String(v.kind), 0.2)) - (90.0 if String(v.kind) == "food" else 0.0) - (120.0 if dry_kinds.has(String(v.kind)) else 0.0)
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
		# Six stay at the home deposits while there is something left there
		# to gather; workers with nothing to do all go.
		var idle_spare := 0
		for sp in spare:
			if sp.state == sp.State.IDLE:
				idle_spare += 1
		var can_send := mini(free_slots, maxi(gatherers - 6, idle_spare))
		if can_send <= 0:
			continue
		# Not into an outpost the enemy is standing at.
		var besieged := false
		for cmd in world.commanders:
			if cmd == commander or cmd.defeated:
				continue
			for foe in cmd.units:
				if is_instance_valid(foe) and not foe.is_dead and not foe.is_worker and foe.global_position.distance_to(ob.global_position) < 40.0:
					besieged = true
					break
		if besieged:
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
	var low := ""
	var low_amt := 150
	for k in ["food", "timber", "stone"]:
		if int(commander.resources.get(k, 0)) < low_amt:
			low = k
			low_amt = int(commander.resources.get(k, 0))
	# Sell a pile when gold is short, or when a store has run low and there is
	# not the gold to buy it: a pile is the biggest store over 500 (over 350
	# when the gold is nearly gone) that is not itself the one running low.
	# (The AI only ever sold with under 120 gold and over 900 of something,
	# and so sat on a thousand food and stone with no timber to build with.)
	var gold_now := int(commander.resources.get("gold", 0))
	if gold_now < 120 or (low != "" and gold_now < commander.trade_price() + 30):
		var pile := ""
		var pile_amt := 350 if gold_now < 40 else 500
		for k in ["stone", "timber", "food"]:
			if k != low and int(commander.resources.get(k, 0)) > pile_amt:
				pile = k
				pile_amt = int(commander.resources.get(k, 0))
		if pile != "":
			world.command_bus.execute({"type": "trade", "target": hq, "id": "sell_" + pile})
			if pile_amt > 900:
				world.command_bus.execute({"type": "trade", "target": hq, "id": "sell_" + pile})
	# The store this people spends most on is the one that limits its army.
	# A Compaña AI (its dead cost food and little else) sat at minute twelve on
	# 300 food, 1,450 stone, 1,080 timber and 880 gold with eleven soldiers:
	# no store was under 150, so the caravan never traded. With gold to spare
	# it now buys that store below 400, and a dead pile of another store is
	# sold to pay for it.
	var main_kind := ""
	var main_share := 0.0
	for k in ["food", "timber", "stone"]:
		if float(_gather_share.get(k, 0.0)) > main_share:
			main_share = float(_gather_share.get(k, 0.0))
			main_kind = k
	var main_short: bool = main_kind != "" and int(commander.resources.get(main_kind, 0)) < 400
	if main_short and int(commander.resources.get("gold", 0)) < 450:
		for k in ["stone", "timber", "food"]:
			if k != main_kind and int(commander.resources.get(k, 0)) > 900:
				world.command_bus.execute({"type": "trade", "target": hq, "id": "sell_" + k})
				break
	for i in 2:
		var price: int = commander.trade_price()
		low = ""
		low_amt = 150
		for k in ["food", "timber", "stone"]:
			if int(commander.resources.get(k, 0)) < low_amt:
				low = k
				low_amt = int(commander.resources.get(k, 0))
		if low == "" and main_kind != "" and int(commander.resources.get(main_kind, 0)) < 400 and int(commander.resources.get("gold", 0)) >= price + 300:
			low = main_kind
			low_amt = int(commander.resources.get(main_kind, 0))
		if low == "":
			return
		# An empty store is worth the gold at once; otherwise keep a little
		# gold back for soldiers and research.
		var reserve := 150 if low_amt >= 40 else 30
		if int(commander.resources.get("gold", 0)) < price + reserve:
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
	_manage_easy_outposts()
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
		# The nearest node of the kind anywhere on the map used to be taken:
		# once the deposits round its hall ran dry, an Easy opponent's workers
		# walked to the player's own trees. Home nodes and safe ones only.
		var node = _easy_node(desired, worker.global_position)
		var assigned := desired
		if not node:
			_easy_resource_shortages.append({"worker_id": worker.unit_id,
				"worker_runtime_id": str(worker.get_instance_id()), "requested": desired,
				"time": _easy_elapsed, "reason": "desired_kind_absent_or_depleted"})
			for fallback in _available_easy_resource_kinds():
				if fallback == desired:
					continue
				node = _easy_node(String(fallback), worker.global_position)
				if node:
					assigned = fallback
					break
		if node:
			worker.command_gather(node)
			_easy_resource_assignments.append({"worker_id": worker.unit_id,
				"worker_runtime_id": str(worker.get_instance_id()), "requested": desired,
				"assigned": assigned, "node_id": str(node.get_instance_id()),
				"time": _easy_elapsed, "explicit_fallback": assigned != desired})

## The exact-kind node nearest the worker while it lies round the hall; past
## the home deposits, only a node the full AI would also call safe.
func _easy_node(kind: String, from: Vector3):
	var node = world.find_nearest_resource_exact(from, kind)
	if node and node.global_position.distance_to(_base_pos) <= HOME_NODE_RADIUS:
		return node
	return _pick_node(kind, from)

## When a kind has run dry round the hall, an Easy opponent opens one outpost
## on a vein of that kind well on its own side (two at most) and sends its
## idle workers in. Without this its economy simply ended after the home
## deposits: seven workers stood idle for the rest of the match.
func _manage_easy_outposts() -> void:
	if float(world.get("match_time")) < 150.0:
		return
	var oid := "%s_outpost" % String(commander.race)
	var odef: Dictionary = GameData.get_building(oid)
	if odef.is_empty():
		return
	var outposts: Array = []
	var building_one := false
	for b in commander.buildings:
		if is_instance_valid(b) and not b.is_dead and bool(b.def.get("vein_outpost", false)):
			if b.is_built:
				outposts.append(b)
			else:
				building_one = true
	for ob in outposts:
		var free_slots: int = ob.outpost_slots() - ob.garrison.size()
		var idle: Array = []
		for u in commander.units:
			if is_instance_valid(u) and not u.is_dead and u.is_worker and u.state == u.State.IDLE:
				if (u.get_meta("garrison_target") if u.has_meta("garrison_target") else null) == ob:
					free_slots -= 1
				else:
					idle.append(u)
		if free_slots > 0 and not idle.is_empty():
			world.command_bus.execute({"type": "garrison", "units": idle.slice(0, free_slots), "target": ob})
	var dry_kinds: Array = []
	for k in ["food", "timber", "stone", "gold"]:
		if not _home_has(k):
			dry_kinds.append(k)
	if building_one or dry_kinds.is_empty() or outposts.size() >= mini(2, dry_kinds.size()) or not commander.can_afford(odef.get("cost", {})):
		return
	var held: Array = []
	for ob in outposts:
		var ov = ob.get_meta("vein") if ob.has_meta("vein") else null
		if ov != null and is_instance_valid(ov):
			held.append(String(ov.kind))
	var best = null
	var best_d := INF
	var starts: Array = world.map.get("start_positions", [])
	for v in get_tree().get_nodes_in_group("veins"):
		if not v.is_free() or int(v.amount) <= 0 or not dry_kinds.has(String(v.kind)) or held.has(String(v.kind)):
			continue
		var d: float = v.global_position.distance_to(_base_pos)
		var ours := true
		for i in world.commanders.size():
			if i != commander.team and i < starts.size() and v.global_position.distance_to(starts[i]) < d * 1.6:
				ours = false
		if ours and d < best_d:
			best_d = d
			best = v
	var w = _free_worker()
	if best and w:
		var ob = world.place_building(oid, commander.team, best.global_position)
		if ob:
			w.command_build(ob)

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

## An Easy opponent leaves the player alone for the first four and a half
## minutes. Its first wave used to leave as soon as four to six soldiers were
## out: at 1:17 for the Vorthak, standing at the player's hall at 2:12, in the
## very first chapter of the campaign and earlier than a Normal opponent.
const EASY_FIRST_WAVE_AFTER := 270.0

func _manage_easy_staging_and_wave() -> void:
	if _easy_wave_launched:
		return
	if _army_size() < _army_attack_size:
		return
	if float(world.get("match_time")) < EASY_FIRST_WAVE_AFTER:
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
				var node = _pick_node(kind, u.global_position)
				if node:
					u.command_gather(node)
					if u.state != u.State.IDLE:
						break

## The node of `kind` to send a gatherer to: the nearest one round the base,
## and failing that the one nearest the base that stands beside one of our
## own buildings with no enemy soldier or tower near it. Only when the store
## of that kind is nearly empty is an unguarded node taken, and then only one
## well on our side of the field with no enemy in sight of it. (The nearest node
## of the kind anywhere used to be taken, which marched workers through the
## fighting to the far side of the map as soon as the home deposit ran dry.)
const HOME_NODE_RADIUS := 60.0

func _pick_node(kind: String, from: Vector3):
	var best = null
	var best_score := INF
	for r in get_tree().get_nodes_in_group("resources"):
		if not is_instance_valid(r) or r.depleted or String(r.resource_kind) != kind:
			continue
		var home: float = r.global_position.distance_to(_base_pos)
		var score: float = from.distance_to(r.global_position)
		if home > HOME_NODE_RADIUS:
			if not _node_is_safe(r, int(commander.resources.get(kind, 0)) < 60):
				continue
			score = 1000.0 + home
		if score < best_score:
			best_score = score
			best = r
	return best

## Is there still a live deposit of `kind` round the hall?
func _home_has(kind: String) -> bool:
	for r in get_tree().get_nodes_in_group("resources"):
		if is_instance_valid(r) and not r.depleted and String(r.resource_kind) == kind and r.global_position.distance_to(_base_pos) <= HOME_NODE_RADIUS:
			return true
	return false

func _node_is_safe(node, desperate: bool = false) -> bool:
	var at: Vector3 = node.global_position
	var home: float = at.distance_to(_base_pos)
	var guarded := false
	for own in commander.buildings:
		if is_instance_valid(own) and not own.is_dead and own.is_built and own.global_position.distance_to(at) < 35.0:
			guarded = true
			break
	if not guarded and not desperate:
		return false
	var keep_off := 40.0 if guarded else 55.0
	for cmd in world.commanders:
		if cmd == commander or cmd.defeated:
			continue
		var their_hall: Vector3 = world.map.get("start_positions", [])[cmd.team] if cmd.team < world.map.get("start_positions", []).size() else Vector3.INF
		if their_hall != Vector3.INF and at.distance_to(their_hall) < home * (1.0 if guarded else 1.3):
			return false
		for u in cmd.units:
			if is_instance_valid(u) and not u.is_dead and not u.is_worker and u.global_position.distance_to(at) < keep_off:
				return false
		for b in cmd.buildings:
			if is_instance_valid(b) and not b.is_dead and b.def.has("tower_dmg") and b.global_position.distance_to(at) < 30.0:
				return false
	return true

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
				# An army holds two siege engines at most. Counted like any
				# other soldier, a new engine in the Ironmaw and Careto
				# barracks (timber and gold) pulled their workers off the food
				# they were already short of: both fell from a third of their
				# matches to a fifth.
				if String(ud.get("role", "")) == "siege":
					weight = 0.2
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
	var lowest_stock := 1000000
	for k in crews:
		lowest_stock = mini(lowest_stock, int(r.get(k, 0)))
	for k in crews:
		var stock := int(r.get(k, 0))
		# A Karak AI starved on 0 food and 10 timber while 900 gold sat
		# unspent: a big stockpile now releases its gatherers much sooner.
		var pressure := 1.7 if stock < 150 else (1.2 if stock < 350 else (0.6 if stock < 600 else 0.15))
		# Stocks of 150 to 350 never gave up a worker, so a Moura Court sat on
		# 300 stone and 300 gold with 40 food and half its rival's army. A
		# stock three times the scarcest one now counts as piled up.
		if lowest_stock < 100 and stock > 200 and stock > 3 * (lowest_stock + 30):
			pressure = minf(pressure, 0.6)
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
		var node = _pick_node(short, u.global_position)
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
	# Once nothing is left to gather round the hall the home crew is only
	# builders: four are enough. (The full crew was kept whatever was left,
	# so an AI on its veins fed ten idle mouths out of its army's room.)
	var home_crew := _worker_target
	if not (_home_has("food") or _home_has("timber") or _home_has("stone") or _home_has("gold")):
		home_crew = 4
	if hq and _worker_count() < home_crew + inside:
		if hq.queue.size() < 2:
			var wid = GameData.get_race(commander.race).get("worker", "")
			hq.queue_unit(wid)
	# build houses when near pop cap
	# Plan housing early: factions whose soldiers take 2 population (Barrosan
	# Spear Guard, Outrider) hit the cap long before a late house went up.
	if commander.pop_used >= _planned_pop_cap() - 6 and commander.pop_cap < commander.POP_HARD_CAP:
		_try_build("house")
	# Out of food with no safe food left to gather: every house keeps a
	# garden, so another house is the food supply (as the game tells the
	# player when the deposit by the hall runs dry).
	elif int(commander.resources.get("food", 0)) < 80 and _count_building_kind("house") < 12 and _unbuilt_count() < 2 and _pick_node("food", _base_pos) == null:
		_try_build("house")

## The population cap once the houses already under construction finish. The
## AI used to look at the built cap only, so near the cap it laid a new house
## every few seconds: a Moura Court had six by minute four (room for 60, 27
## used) and half the army of its opponent.
func _planned_pop_cap() -> int:
	var cap := int(commander.pop_cap)
	for b in commander.buildings:
		if is_instance_valid(b) and not b.is_dead and not b.is_built:
			cap += int(b.def.get("grants_pop", 0))
	return cap

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
	# army upgrades at the economy building, economy ones at the hall, the
	# people's own among them; one at a time, and only with money to spare
	# beyond the army's needs.
	var eco = _get_building_of_kind("economy")
	if eco and eco.queue.is_empty():
		for t in GameData.research_for(eco.def, String(commander.race)):
			if commander.can_research(t) and commander.can_afford(GameData.get_tech(t).get("cost", {})):
				eco.queue_tech(t)
				break
	if hq.queue.is_empty() and _army_size() >= 4:
		for t in GameData.research_for(hq.def, String(commander.race)):
			if String(GameData.get_tech(t).get("kind", "")) == "tier":
				continue
			if commander.can_research(t) and commander.can_afford(GameData.get_tech(t).get("cost", {})):
				hq.queue_tech(t)
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
	# Its people's landmark, once the army is on its feet.
	if commander.tier >= 2 and not _has_building_kind("landmark") and _army_size() >= 6 and difficulty != "easy":
		_try_build("landmark")
	# second barracks for hard/brutal
	# ...and for anyone whose resources pile up faster than one barracks can
	# spend them (a Barrosan AI sat on 400+ food with 3 soldiers).
	var piling: bool = int(commander.resources.get("food", 0)) > 350 and int(commander.resources.get("timber", 0)) > 250
	if _count_building_kind("barracks") < 2 and ((_tech_aggression >= 1.4 and _army_size() > _second_barracks_army) or piling):
		_try_build("barracks")
	# A winning AI sat on 10,000 gold with 18 soldiers and two barracks, losing
	# troops at the enemy's towers as fast as it trained them, and the match
	# ran out the clock. Wealth it cannot spend becomes more barracks.
	var food_now := int(commander.resources.get("food", 0))
	var timber_now := int(commander.resources.get("timber", 0))
	# A bank of every kind counts too: a Compaña AI held 4,400 of all four at
	# minute twelve with 700 food and two barracks, never "flush" because its
	# food stayed under 900.
	var bank_total: int = food_now + timber_now + int(commander.resources.get("stone", 0)) + int(commander.resources.get("gold", 0))
	var flush: bool = (food_now > 900 and timber_now > 500) or (bank_total > 2500 and food_now > 400)
	var want_barracks := 2
	# Six peoples train from two kinds of hall (a barracks and a spire or
	# grove); the other four have the barracks alone and so trained a third
	# fewer soldiers at a time from the Age of Bronze on. They raise a third
	# barracks where the others raise their spire.
	if commander.tier >= 2 and _building_id_for_kind("arcane") == "":
		want_barracks = 3
	if flush:
		want_barracks = 4 if (food_now > 2200 and timber_now > 900) else 3
	if difficulty != "easy" and _count_building_kind("barracks") >= 2 and _count_building_kind("barracks") < want_barracks:
		_try_build("barracks")

	# A side reduced to a handful of workers spent every scrap of food on
	# replacement soldiers and never rebuilt its economy: matches deadlocked
	# with 0 workers and thousands of unspent gold. Workers come first.
	if _worker_count() < mini(6, _worker_target) and _get_building_of_kind("main") != null:
		return
	# Saving for the third age. The age costs 400 food, and an AI whose
	# barracks swallowed every scrap of food as it came in never had it: an
	# Ironmaw AI was still in the second age at minute twelve, without its
	# giant or its siege engine, in match after match. From minute six, with
	# an army two over its wave size and nobody at its gates, it stops
	# training until the age is paid for.
	if commander.tier == 2 and float(world.get("match_time")) > 360.0 and commander.can_research("advance_tier_3") and _army_size() >= _army_attack_size + 2:
		if not commander.can_afford(GameData.get_tech("advance_tier_3").get("cost", {})) and world.find_enemy_near(_base_pos, 60.0, commander.team) == null:
			return
	# train army from military buildings
	for b in commander.buildings:
		if not is_instance_valid(b) or b.is_dead or not b.is_built:
			continue
		var kind = b.def.get("kind", "")
		if kind in ["barracks", "arcane"] and b.queue.size() < (3 if flush else 2):
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
				# Shelter beside the hall, not inside it: the old spot (6 m from
				# the centre of a hall 7 m across) lay within its walls, so
				# fleeing workers pushed against the hall for the rest of the
				# match and never went back to work.
				var hall = _get_building_of_kind("main")
				var shelter := (float(hall.footprint) if is_instance_valid(hall) else 7.0) + 3.5
				if u.global_position.distance_to(_base_pos) > shelter + 4.0:
					u.command_move(_base_pos + (u.global_position - _base_pos).normalized() * shelter)
	if threat:
		for u in commander.units:
			if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
				if u.global_position.distance_to(threat.global_position) < 80.0 and u.global_position.distance_to(_base_pos) < 85.0:
					u.command_attack(threat)
		# The hero defends its own base too. It was left out of the recall:
		# an AI's hero stood at full health by its hall, still at level one
		# five minutes in, while its soldiers fell seventy metres away and
		# the attacking hero grew three levels on them.
		var hero = commander.hero_ref
		if is_instance_valid(hero) and not hero.is_dead and hero.hp >= hero.max_hp * 0.5 and not bool(hero.get_meta("ai_retreating", false)):
			var to_threat: float = hero.global_position.distance_to(threat.global_position)
			# Not alone against a whole wave, though: with the rule above and
			# nothing else, a sword-carrying hero met every raid by itself and
			# fell nearly six times a match (its people won 4 of 18). It goes
			# when the raid is a handful, or when its own soldiers who answer
			# the call are at least half as many as the raiders.
			var raiders := 0
			for cmd in world.commanders:
				if cmd == commander or cmd.defeated:
					continue
				for foe in cmd.units:
					if is_instance_valid(foe) and not foe.is_dead and not foe.is_worker and foe.global_position.distance_to(threat.global_position) < 25.0:
						raiders += 1
			var defenders := 0
			for u in commander.units:
				if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero and u.global_position.distance_to(threat.global_position) < 80.0 and u.global_position.distance_to(_base_pos) < 85.0:
					defenders += 1
			var backed: bool = raiders <= 2 or defenders * 2 >= raiders
			if backed and hero.global_position.distance_to(_base_pos) < 85.0 and to_threat < 90.0 and (hero.state == hero.State.IDLE or (to_threat > 16.0 and hero.state == hero.State.MOVING)):
				hero.command_move(threat.global_position, true)

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
	# Normal attacks in waves with a pause between them, and not in the first
	# three and a half minutes. It used to march the moment it had six to nine
	# soldiers (from 2:20) and then send every new soldier after them within
	# eight seconds, twenty "waves" in seven minutes: that unbroken stream beat
	# the Hard AI, which waits to mass, as often as it lost to it. Hard and
	# Brutal keep the stream.
	var wave_gap := 8.0
	var grace := 0.0
	if difficulty == "normal":
		wave_gap = 40.0
		grace = 210.0
	if size >= needed and _attack_timer > wave_gap and float(world.get("match_time")) >= grace:
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
		if u.is_hero and bool(u.get_meta("ai_retreating", false)):
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
	# The hero is not one of them: a hero that fights at range (the Candle-King,
	# the Binder, the Warden, the Archon) sorted to the front of the home guard
	# below, was sent to the guard post and never left it. Those four peoples
	# fought every battle without their hero and filled the bottom of every
	# balance check; the Compaña won 1 match in 18.
	var soldiers := []
	for u in commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
			soldiers.append(u)
	# A home guard stays behind: raiders killed 30 or more workers a match
	# while every soldier marched off. The ranged soldiers nearest home (a
	# fifth of the army, at least two once it is big enough) hold the fields.
	var guard_n := 0 if soldiers.size() < 6 else maxi(2, soldiers.size() / 5)
	# After fifteen minutes every AI commits everything (evenly matched sides
	# otherwise traded waves until the clock ran out).
	# Normal sends a wave of the size it was waiting for (and two more), not
	# everything it has: after its quiet opening it had eleven to sixteen
	# soldiers, and all of them arrived together at minute four. The rest
	# stay to guard its base until the next wave.
	if difficulty == "normal":
		var wave_size := _army_attack_size + mini(maxi(_wave_number - 1, 0), 3) * 2 + 2
		guard_n = maxi(guard_n, soldiers.size() - wave_size)
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
				# Each guard has its own place around the post: sent to one
				# point they jostled for it without end.
				var place: Vector3 = guard_post + Vector3(cos(float(i) * 2.4), 0.0, sin(float(i) * 2.4)) * (1.6 + 0.7 * float(i))
				u.command_move(place, true)
		else:
			u.set_meta("ai_home_guard", false)
			u.command_move(target, true)
	# The hero joins the push, but not while it is falling back hurt (this
	# order used to turn it round again within eight seconds) and not alone:
	# a hero just back from the dead walked across the map by itself and died
	# again. A sword-carrying hero fell four times in ten minutes that way,
	# each fall worth as much to the enemy hero as five soldiers, while a hero
	# that fights from behind the line never fell at all: the four peoples
	# with such heroes led every balance check.
	var hero = commander.hero_ref
	if is_instance_valid(hero) and not hero.is_dead:
		var hurt: bool = (hero.has_meta("ai_retreating") and bool(hero.get_meta("ai_retreating"))) or hero.hp < hero.max_hp * 0.6
		var escort := 0
		for u in soldiers:
			if u.global_position.distance_to(hero.global_position) < 60.0:
				escort += 1
		if not hurt and escort >= 3:
			hero.command_move(target, true)
		elif not hurt and hero.state == hero.State.IDLE and hero.global_position.distance_to(_base_pos) < 70.0 and hero.global_position.distance_to(_rally) > 12.0:
			# Wait where the army musters and leave with the next soldiers.
			hero.command_move(_rally, true)

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
	# (in a Domination battle the sites decide the war: go far more often,
	# in greater strength, and at once when a rival holds them all)
	var dom: Dictionary = world.domination_status() if world.has_method("domination_status") else {}
	var domination := not dom.is_empty()
	var rival_holds_all: bool = domination and int(dom.get("team", -1)) >= 0 and int(dom.get("team", -1)) != commander.team
	if _army_size() < 4 and not rival_holds_all:
		return
	if not rival_holds_all and _rng.randf() > (0.5 if domination else 0.15):
		return
	var squad_size := 99 if rival_holds_all else (5 if domination else 3)
	var points = world.get_tree().get_nodes_in_group("capture_points")
	for p in points:
		if is_instance_valid(p) and p.owner_team != commander.team:
			var squad := []
			for u in commander.units:
				if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero and u.state == u.State.IDLE:
					squad.append(u)
					if squad.size() >= squad_size:
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
	var needs_house: bool = commander.pop_used >= _planned_pop_cap() - 6 and commander.pop_cap < commander.POP_HARD_CAP
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
	# A crowded base: look in a wider arc and further out, still by the rules.
	# (The old fallback dropped the building 16 m in front of the hall with no
	# check at all, on the very road _spot_clear keeps open: three houses and a
	# war hall walled a Clanhold in, and its workers could no longer deliver.)
	for attempt in 30:
		var ang2 := toward + _rng.randf_range(-2.2, 2.2)
		var dist2 := 22.0 + _rng.randf() * 50.0
		var p2 := _base_pos + Vector3(cos(ang2) * dist2, 0, sin(ang2) * dist2)
		p2.x = clamp(p2.x, -MapDefs.MAP_SIZE + 8, MapDefs.MAP_SIZE - 8)
		p2.z = clamp(p2.z, -MapDefs.MAP_SIZE + 8, MapDefs.MAP_SIZE - 8)
		if _spot_clear(p2, footprint):
			return p2
	# Nowhere legal this time: a point no placement accepts, so the caller
	# waits and tries again later.
	return Vector3(99999.0, 0.0, 99999.0)

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
	# Deep in enemy ground the walk home is long and the chasers are many: a
	# hero that turned back at 40% there was cut down on the way (a Barrosan
	# Thane at 2% was still in the enemy base half a minute later) and came
	# back at level one against a level-five enemy hero. Far from home it
	# turns back at half health.
	var home_d: float = hero.global_position.distance_to(_base_pos)
	var turn_back: float = 0.5 if home_d > 110.0 else 0.4
	if hero.hp < hero.max_hp * turn_back and home_d > 25.0 and not hero.can_cast("heal"):
		if not bool(hero.get_meta("ai_retreating", false)):
			hero.set_meta("ai_retreating", true)
			hero.command_move(_base_pos, false)
		elif hero.state != hero.State.MOVING:
			# Something turned it round on the way (a blow it answered, a
			# siege order): home again.
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
	# The people's signature spell comes first when the moment is right.
	for sid in hero.abilities:
		if not String(sid).begins_with("sig_") or not hero.can_cast(String(sid)):
			continue
		var sok := false
		var sat: Vector3 = hero.global_position
		match String(sid):
			"sig_spring":
				sok = hurt or near_allies >= 4
			"sig_chains", "sig_stoneskin":
				sok = near_allies >= 3 and near_enemies.size() >= 2
			"sig_pack", "sig_candles":
				sok = near_enemies.size() >= 2
				sat = nearest.global_position
			"sig_entrudo":
				sok = close.size() >= 3
			_:
				sok = near_enemies.size() >= 3
				sat = nearest.global_position
		if sok and hero.cast_ability(String(sid), sat):
			return
	# People spells: helping ones when allies stand close, hurting ones on a crowd.
	for pid in hero.abilities:
		var pdef: Dictionary = SkillDefs.get_abilities().get(String(pid), {})
		if not pdef.has("fx") or not hero.can_cast(String(pid)):
			continue
		var pok: bool = (near_allies >= 3 and near_enemies.size() >= 2) if String(pdef.get("use", "enemy")) == "ally" else near_enemies.size() >= 3
		if pok and hero.cast_ability(String(pid), nearest.global_position):
			return
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
