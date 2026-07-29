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

func setup(p_world, p_commander, p_difficulty: String) -> void:
	world = p_world
	commander = p_commander
	difficulty = p_difficulty
	_apply_difficulty()
	_base_pos = _find_hq_pos()
	_rally = _base_pos.lerp(Vector3.ZERO, 0.35)

func _apply_difficulty() -> void:
	match difficulty:
		"easy":
			_think_interval = 2.0; _worker_target = 7; _army_attack_size = 6
			_eco_efficiency = 0.7; _tech_aggression = 0.6
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
	_assign_idle_workers()
	_manage_economy()
	_manage_tech()
	_manage_production()
	_manage_defense()
	_manage_offense()
	_manage_capture()

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
	# attack nearest enemy building; fallback to player start
	var best := Vector3.ZERO
	var best_d := INF
	for b in world.all_buildings():
		if not is_instance_valid(b) or b.is_dead or b.team == commander.team:
			continue
		var d = _base_pos.distance_squared_to(b.global_position)
		if d < best_d:
			best_d = d
			best = b.global_position
	return best

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
