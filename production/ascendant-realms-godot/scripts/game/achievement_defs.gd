extends RefCounted
## Deeds of the Jardas. Every track has tiers that never run out: after the
## named tiers the goal keeps doubling and the title gains a numeral. Each tier
## earned grants a mastery point, so long play always pays.

const TRACKS := [
	{"id": "victories", "name": "Victories", "stat": "victories", "first": [1, 5, 10, 25, 50, 100],
		"titles": ["the Blooded", "Warband Leader", "Captain of Salto", "Warlord of the Terras Frias", "Hammer of the Ascension", "Legend of the Larouco"]},
	{"id": "slain", "name": "Foes slain", "stat": "units_killed", "first": [25, 100, 300, 1000, 3000],
		"titles": ["Wolf-tooth", "Reaper of the Fojos", "Bane of Furna", "Thousand-Slayer", "Death of Armies"]},
	{"id": "road", "name": "Endless Road", "stat": "endless_best", "first": [5, 10, 20, 35, 50, 75, 100],
		"titles": ["Roadwalker", "Far-strider", "Warden of the Long Road", "Pilgrim of the Lume", "Lord of No Last Stage", "Keeper of the Endless", "The Road Itself"]},
	{"id": "saga", "name": "Saga chapters", "stat": "saga_cleared", "first": [6, 17, 26, 34, 44],
		"titles": ["Ember of Salto", "Diver of the Drowned Villages", "Reader of the Ledger", "Breaker of the Bronze", "Oath-keeper"]},
	{"id": "laurels", "name": "Heroic laurels", "stat": "heroic_laurels", "first": [1, 5, 15, 30, 44],
		"titles": ["Laurelled", "Twice-tested", "Hard as Granite", "Heroic Jardas", "Crown of Laurels"]},
	{"id": "legendary", "name": "Legendary finds", "stat": "legendary_found", "first": [1, 5, 15, 40],
		"titles": ["Lucky", "Gold-finder", "Moura's Favourite", "Treasure of the Highlands"]},
	{"id": "tyrants", "name": "Road Tyrants slain", "stat": "tyrants_slain", "first": [1, 4, 10, 25],
		"titles": ["Tyrant-breaker", "Bane of the Tarasca", "Wolf-slayer of Larouco", "Ender of Tyrants"]},
	{"id": "elites", "name": "Elites and champions slain", "stat": "elites_slain", "first": [5, 25, 100, 400],
		"titles": ["Giant-feller", "Champion's Doom", "Scourge of Elites", "Hunter of the Great"]},
]

static func track(id: String) -> Dictionary:
	for t in TRACKS:
		if String(t["id"]) == id:
			return t
	return {}

## Goal for tier `tier` (1-based). After the named tiers, the goal doubles.
static func goal(t: Dictionary, tier: int) -> int:
	var first: Array = t["first"]
	if tier <= first.size():
		return int(first[tier - 1])
	return int(first[first.size() - 1]) * int(pow(2.0, float(tier - first.size())))

static func title(t: Dictionary, tier: int) -> String:
	var titles: Array = t["titles"]
	if tier <= titles.size():
		return String(titles[tier - 1])
	return "%s %s" % [titles[titles.size() - 1], _roman(tier - titles.size() + 1)]

static func _roman(n: int) -> String:
	var vals := [[1000, "M"], [900, "CM"], [500, "D"], [400, "CD"], [100, "C"], [90, "XC"], [50, "L"], [40, "XL"], [10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]]
	var out := ""
	for v in vals:
		while n >= int(v[0]):
			out += String(v[1])
			n -= int(v[0])
	return out
