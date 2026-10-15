extends RefCounted
## Hero talents: every tenth hero level offers a choice of three talents.
## Talents stack without end (each rank a little less than the one before, but
## never nothing), so level 500 still brings a real decision. The three offered
## are seeded by how many picks the hero has made, so the offer is stable
## between sessions and cannot be rerolled by reloading.

const EVERY_LEVELS := 10

const TALENTS := [
	{"id": "bloodthirst", "name": "Bloodthirst", "desc": "Heal for 2% of damage dealt. Later ranks add a little less.", "per": 2.0, "unit": "% lifesteal"},
	{"id": "executioner", "name": "Headhunter", "desc": "+12% damage against foes below 30% health. Later ranks add a little less.", "per": 12.0, "unit": "% vs wounded"},
	{"id": "thorns", "name": "Thornhide", "desc": "Melee attackers take 6% of each blow back. Later ranks add a little less.", "per": 6.0, "unit": "% thorns"},
	{"id": "giants_blood", "name": "Giant's Blood", "desc": "+6% maximum health. Later ranks add a little less.", "per": 6.0, "unit": "% health"},
	{"id": "swift_blade", "name": "Swift Blade", "desc": "+3% attack speed. Later ranks add a little less.", "per": 3.0, "unit": "% attack speed"},
	{"id": "warlord", "name": "Warlord", "desc": "Nearby soldiers gain +0.8 damage and +0.4 armor. Later ranks add a little less.", "per": 0.8, "unit": " aura damage"},
	{"id": "stormcaller", "name": "Stormcaller", "desc": "+8% spell power. Later ranks add a little less.", "per": 8.0, "unit": "% spell power"},
	{"id": "quartermaster", "name": "Quartermaster", "desc": "+1 veteran in the retinue per rank."},
	{"id": "treasure_hunter", "name": "Treasure Hunter", "desc": "+2 Fortune per rank for battle loot."},
	{"id": "iron_will", "name": "Granite Skin", "desc": "+1 armor. Later ranks add a little less.", "per": 1.0, "unit": " armor"},
	{"id": "lume_well", "name": "Lume Well", "desc": "+20 mana and +0.5 mana regeneration. Later ranks add a little less.", "per": 20.0, "unit": " mana"},
	{"id": "rallying_cry", "name": "Salto's Horn", "desc": "+2 meters of command aura reach. Later ranks add a little less.", "per": 2.0, "unit": " m reach"},
	{"id": "second_wind", "name": "Hearthblood", "desc": "The hero regenerates 1.5 health a second. Later ranks add a little less.", "per": 1.5, "unit": " health/s"},
	{"id": "keen_eye", "name": "Keen Eye", "desc": "+3 sight: see raiders coming. Later ranks add a little less.", "per": 3.0, "unit": " sight"},
	{"id": "mentor", "name": "Mentor", "desc": "+5% battle experience per rank."},
]

## Synergies: when both talents of a pair reach rank 3, a bonus wakes.
const SYNERGIES := [
	{"id": "undying", "name": "Undying Jardas", "needs": ["bloodthirst", "giants_blood"], "desc": "+5% more life drained from every blow."},
	{"id": "headsman", "name": "Headsman", "needs": ["executioner", "swift_blade"], "desc": "+10% damage."},
	{"id": "warband", "name": "Warband of Salto", "needs": ["warlord", "rallying_cry"], "desc": "+1 command aura damage and armor."},
	{"id": "lume_tide", "name": "Lume Tide", "needs": ["stormcaller", "lume_well"], "desc": "+10% spell power."},
	{"id": "watchful", "name": "Watchful Hunter", "needs": ["keen_eye", "treasure_hunter"], "desc": "+3 Fortune for battle loot."},
]

static func active_synergies(talents: Dictionary) -> Array:
	var out: Array = []
	for syn in SYNERGIES:
		var ok := true
		for need in syn["needs"]:
			if int(talents.get(need, 0)) < 3:
				ok = false
		if ok:
			out.append(syn)
	return out

static func find(id: String) -> Dictionary:
	for t in TALENTS:
		if String(t["id"]) == id:
			return t
	return {}

## What `ranks` ranks of a talent with a "per" value give in all, as the
## talent card shows it ("+15.9% health"). Empty for talents that grow by
## the same amount every rank.
static func total_text(id: String, ranks: int) -> String:
	var t := find(id)
	if not t.has("per") or ranks <= 0:
		return ""
	var v := float(t["per"]) * strength(ranks)
	var num := ("%.1f" % v) if absf(v - roundf(v)) > 0.05 else str(int(roundf(v)))
	return "+%s%s" % [num, String(t.get("unit", ""))]

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
