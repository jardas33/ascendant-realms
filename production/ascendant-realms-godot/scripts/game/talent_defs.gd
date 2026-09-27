extends RefCounted
## Hero talents: every tenth hero level offers a choice of three talents.
## Talents stack without end (each rank a little less than the one before, but
## never nothing), so level 500 still brings a real decision. The three offered
## are seeded by how many picks the hero has made, so the offer is stable
## between sessions and cannot be rerolled by reloading.

const EVERY_LEVELS := 10

const TALENTS := [
	{"id": "bloodthirst", "name": "Bloodthirst", "desc": "Heal for 2% of damage dealt per rank."},
	{"id": "executioner", "name": "Executioner", "desc": "+12% damage per rank against foes below 30% health."},
	{"id": "thorns", "name": "Thornhide", "desc": "Melee attackers take 6% of their blow back per rank."},
	{"id": "giants_blood", "name": "Giant's Blood", "desc": "+6% maximum health per rank."},
	{"id": "swift_blade", "name": "Swift Blade", "desc": "+3% attack speed per rank."},
	{"id": "warlord", "name": "Warlord", "desc": "Nearby soldiers gain +0.8 damage and +0.4 armour per rank."},
	{"id": "stormcaller", "name": "Stormcaller", "desc": "+8% spell power per rank."},
	{"id": "quartermaster", "name": "Quartermaster", "desc": "+1 veteran in the retinue per rank."},
	{"id": "treasure_hunter", "name": "Treasure Hunter", "desc": "+2 Fortune per rank for battle loot."},
]

static func find(id: String) -> Dictionary:
	for t in TALENTS:
		if String(t["id"]) == id:
			return t
	return {}

## Effective strength of `ranks` ranks: gently sub-linear, never capped.
static func strength(ranks: int) -> float:
	return pow(float(maxi(0, ranks)), 0.9)

## Talent points earned by a hero of `level`.
static func earned(level: int) -> int:
	return maxi(0, level) / EVERY_LEVELS

## The three talents offered for pick number `pick_index` (0-based).
static func offer(pick_index: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = 9_091_013 + pick_index * 7_727
	var pool: Array = []
	for t in TALENTS:
		pool.append(String(t["id"]))
	var out: Array = []
	for i in 3:
		var id: String = pool[rng.randi() % pool.size()]
		pool.erase(id)
		out.append(id)
	return out
