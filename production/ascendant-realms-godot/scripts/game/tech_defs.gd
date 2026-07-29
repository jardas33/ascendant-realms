class_name TechDefs
## Technology definitions: tier advances and army upgrades.
## Researched at a building; applied globally to the researching player.

static func get_all() -> Dictionary:
	return {
	"advance_tier_2": {
		"name": "Advance to Age of Iron", "kind": "tier", "tier": 2,
		"cost": {"food": 200, "gold": 150}, "time": 40, "at": "main",
		"desc": "Unlock Tier 2 units, elite troops and advanced buildings.",
	},
	"advance_tier_3": {
		"name": "Advance to Age of Lume", "kind": "tier", "tier": 3,
		"cost": {"food": 400, "gold": 300, "stone": 150}, "time": 60, "at": "main",
		"desc": "Unlock Tier 3 elites, casters and siege engines.",
	},
	"tech_weapons": {
		"name": "Forged Weapons", "kind": "upgrade", "stat": "dmg", "add": 4,
		"cost": {"gold": 120, "stone": 60}, "time": 35, "at": "economy",
		"desc": "+4 attack damage to all your combat units.",
	},
	"tech_armor": {
		"name": "Tempered Armor", "kind": "upgrade", "stat": "armor", "add": 2,
		"cost": {"gold": 120, "timber": 80}, "time": 35, "at": "economy",
		"desc": "+2 armor to all your combat units.",
	},
	}
