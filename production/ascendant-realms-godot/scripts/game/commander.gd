class_name Commander
extends Node
## One faction in a battle (human player or AI). Owns economy, population,
## tech tier, global upgrades, and the roster of that faction's units/buildings.

signal resources_changed(res: Dictionary)
signal pop_changed(used: int, cap: int)
signal tier_changed(tier: int)

var team: int = 0
var race: String = "barrosan"
var is_human: bool = false
var color: Color = Color.WHITE

var resources := {"food": 0, "timber": 0, "stone": 0, "gold": 0}
var pop_used: int = 0
var pop_cap: int = 0
var reserved_pop: int = 0
const POP_HARD_CAP := 80

var tier: int = 1
var researching := {}          # tech_id -> time_left
var completed_tech := {}       # tech_id -> true
## Upgrade bonuses by unit role ("all", "melee", ...): stat -> total.
var role_bonus := {}

## What every upgrade gives a unit of this role, summed over "all" and the role.
func upgrade_bonus_for(role: String, is_worker: bool, is_hero: bool) -> Dictionary:
	var out := {}
	var keys: Array = []
	if is_worker:
		keys = ["worker"]
	elif is_hero:
		keys = ["hero"]
	else:
		keys = ["all", role]
		if role == "healer":
			keys.append("caster")
		if role == "antiarmor":
			keys.append("melee")
	for k in keys:
		for s in role_bonus.get(k, {}):
			out[s] = float(out.get(s, 0.0)) + float(role_bonus[k][s])
	return out

# Global army stat bonuses from upgrades
var dmg_bonus: float = 0.0
var armor_bonus: float = 0.0

# Hero progression (computed once at battle start for this commander)
var hero_stats := {}
var build_flags := {}          # convenience: hero_stats.flags

var units: Array = []          # Unit nodes
var buildings: Array = []      # Building nodes
var hero_ref = null            # the hero Unit
var defeated: bool = false
var defeat_reason := ""

func setup(p_team: int, p_race: String, p_human: bool, start_bank: Dictionary, p_hero_stats: Dictionary) -> void:
	team = p_team
	race = p_race
	is_human = p_human
	color = GameData.TEAM_COLORS.get(team, Color.WHITE)
	resources = start_bank.duplicate()
	hero_stats = p_hero_stats
	build_flags = p_hero_stats.get("flags", {})
	# Warchest flag
	if build_flags.has("start_gold"):
		resources["gold"] = int(resources.get("gold", 0)) + int(build_flags["start_gold"])

func can_afford(cost: Dictionary) -> bool:
	for k in cost:
		if int(resources.get(k, 0)) < int(cost[k]):
			return false
	return true

func missing_resource(cost: Dictionary) -> String:
	for k in cost:
		if int(resources.get(k, 0)) < int(cost[k]):
			return k
	return ""

func missing_resource_summary(cost: Dictionary) -> String:
	var shortages: Array[String] = []
	for k in cost:
		var missing := int(cost[k]) - int(resources.get(k, 0))
		if missing > 0:
			shortages.append("%d %s" % [missing, k])
	return "Missing: " + ", ".join(shortages)

func spend(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for k in cost:
		resources[k] = int(resources.get(k, 0)) - int(cost[k])
	emit_signal("resources_changed", resources)
	return true

func refund(cost: Dictionary, ratio: float = 1.0) -> void:
	for k in cost:
		resources[k] = int(resources.get(k, 0)) + int(round(float(cost[k]) * ratio))
	emit_signal("resources_changed", resources)

## Caravan trade at the main hall: gold buys a batch of food, timber or stone.
## Every trade raises the price a little; it eases back to the base over time.
## Late matches banked thousands of gold while armies starved on empty food
## and stone nodes; this turns a hoard into an army.
const TRADE_BATCH := 50
const TRADE_BASE_PRICE := 100.0
const TRADE_PRICE_STEP := 6.0
var _trade_price := TRADE_BASE_PRICE
var _trade_stamp := 0.0

func trade_price() -> int:
	var now := float(Engine.get_physics_frames()) / float(Engine.physics_ticks_per_second)
	# The market cools by one gold every four seconds.
	_trade_price = maxf(TRADE_BASE_PRICE, _trade_price - (now - _trade_stamp) / 4.0)
	_trade_stamp = now
	return int(round(_trade_price))

## The caravan also buys surplus: 100 food, timber or stone for 30 gold, at
## a flat rate (buying back costs far more, so there is no loop to exploit).
const SELL_BATCH := 100
const SELL_GOLD := 30

func sell_for_gold(kind: String) -> Dictionary:
	if not ["food", "timber", "stone"].has(kind):
		return {"ok": false, "reason": "Nothing to sell"}
	if int(resources.get(kind, 0)) < SELL_BATCH:
		return {"ok": false, "reason": "Need %d %s" % [SELL_BATCH, kind]}
	resources[kind] = int(resources[kind]) - SELL_BATCH
	resources["gold"] = int(resources.get("gold", 0)) + SELL_GOLD
	emit_signal("resources_changed", resources)
	return {"ok": true}

func trade_gold_for(kind: String) -> Dictionary:
	if kind.begins_with("sell_"):
		return sell_for_gold(kind.trim_prefix("sell_"))
	if not ["food", "timber", "stone"].has(kind):
		return {"ok": false, "reason": "Nothing to trade for"}
	var price := trade_price()
	if int(resources.get("gold", 0)) < price:
		return {"ok": false, "reason": "Need %d gold" % price}
	resources["gold"] = int(resources["gold"]) - price
	# Not income: kept out of the per-minute rate on the top bar.
	resources[kind] = int(resources.get(kind, 0)) + TRADE_BATCH
	emit_signal("resources_changed", resources)
	_trade_price += TRADE_PRICE_STEP
	return {"ok": true, "price": price}

## Income over the last minute of simulation time, for the top bar.
var _income_log: Array = []

func income_per_minute(kind: String) -> int:
	var now := float(Engine.get_physics_frames()) / float(Engine.physics_ticks_per_second)
	var total := 0
	for e in _income_log:
		if now - float(e[0]) <= 60.0 and String(e[1]) == kind:
			total += int(e[2])
	return total

func add_resources(kind: String, amount: int) -> void:
	if amount > 0:
		var now := float(Engine.get_physics_frames()) / float(Engine.physics_ticks_per_second)
		_income_log.append([now, kind, amount])
		while not _income_log.is_empty() and now - float(_income_log[0][0]) > 60.0:
			_income_log.pop_front()
	resources[kind] = int(resources.get(kind, 0)) + amount
	emit_signal("resources_changed", resources)

func recompute_pop() -> void:
	var used := 0
	var cap := 0
	for u in units:
		# Saga allies fight for you but do not take up your population.
		# Workers inside a vein outpost live at the mine: they free their
		# population, so expanding across the map also grows the army.
		if is_instance_valid(u) and not u.is_dead and not u.has_meta("saga_ally") and not u.has_meta("retinue") and not u.has_meta("garrisoned_in"):
			used += int(u.def.get("pop", 1))
	for b in buildings:
		if is_instance_valid(b) and b.is_built:
			cap += int(b.def.get("grants_pop", 0))
	pop_used = used
	pop_cap = min(cap, POP_HARD_CAP)
	emit_signal("pop_changed", pop_used + reserved_pop, pop_cap)

func has_pop_for(def: Dictionary) -> bool:
	return pop_used + reserved_pop + int(def.get("pop", 1)) <= pop_cap

func reserve_pop(def: Dictionary) -> bool:
	var amount := int(def.get("pop", 1))
	if amount < 1 or not has_pop_for(def):
		return false
	reserved_pop += amount
	emit_signal("pop_changed", pop_used + reserved_pop, pop_cap)
	return true

func release_reserved_pop(def: Dictionary) -> void:
	var amount := int(def.get("pop", 1))
	reserved_pop = max(0, reserved_pop - amount)
	emit_signal("pop_changed", pop_used + reserved_pop, pop_cap)

func train_speed_mult() -> float:
	return 1.0 - float(build_flags.get("train_speed", 0.0))

func build_speed_mult() -> float:
	return 1.0 - float(build_flags.get("build_speed", 0.0))

func gather_mult() -> float:
	return 1.0 + float(build_flags.get("gather_bonus", 0.0))

func apply_tech(tech_id: String) -> void:
	var t := GameData.get_tech(tech_id)
	if t.is_empty():
		return
	# Completion is a one-time Commander-wide state transition. A stale queue
	# callback or duplicate completion path must not stack the authored effect.
	if completed_tech.has(tech_id):
		return
	completed_tech[tech_id] = true
	match t.get("kind", ""):
		"tier":
			tier = int(t.get("tier", tier))
			emit_signal("tier_changed", tier)
		"upgrade":
			if t.get("stat") == "dmg":
				dmg_bonus += float(t.get("add", 0))
			elif t.get("stat") == "armor":
				armor_bonus += float(t.get("add", 0))
			for e in t.get("effects", []):
				var who := String(e.get("who", "all"))
				var bucket: Dictionary = role_bonus.get(who, {})
				for k in e:
					if k != "who":
						bucket[k] = float(bucket.get(k, 0.0)) + float(e[k])
				role_bonus[who] = bucket
			var flags: Dictionary = t.get("flags", {})
			for k in flags:
				var v = flags[k]
				if v is bool:
					build_flags[k] = v
				else:
					build_flags[k] = float(build_flags.get(k, 0.0)) + float(v)
			if flags.has("building_hp"):
				for b in buildings:
					if is_instance_valid(b) and not b.is_dead and b.has_method("apply_hp_upgrade"):
						b.apply_hp_upgrade(1.0 + float(flags["building_hp"]))
			_refresh_unit_stats()

func _refresh_unit_stats() -> void:
	for u in units:
		if is_instance_valid(u):
			u.refresh_upgrade_bonuses()

func can_research(tech_id: String) -> bool:
	if completed_tech.has(tech_id) or researching.has(tech_id):
		return false
	var t := GameData.get_tech(tech_id)
	if t.is_empty():
		return false
	if t.has("race") and String(t["race"]) != String(race):
		return false
	if tier < int(t.get("min_tier", 1)):
		return false
	for r in t.get("req", []):
		if not completed_tech.has(r):
			return false
	if t.get("kind") == "tier":
		var need_tier := int(t.get("tier", 2)) - 1
		if tier != need_tier:
			return false
	return true

func alive_buildings() -> int:
	var n := 0
	for b in buildings:
		if is_instance_valid(b) and not b.is_dead:
			n += 1
	return n

func has_hq() -> bool:
	for b in buildings:
		if is_instance_valid(b) and not b.is_dead and b.def.get("is_hq", false):
			return true
	return false
