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

func add_resources(kind: String, amount: int) -> void:
	resources[kind] = int(resources.get(kind, 0)) + amount
	emit_signal("resources_changed", resources)

func recompute_pop() -> void:
	var used := 0
	var cap := 0
	for u in units:
		if is_instance_valid(u) and not u.is_dead:
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
