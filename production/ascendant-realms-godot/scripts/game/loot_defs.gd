extends RefCounted
## Battle loot. Every battle rolls gear for the hero: more and better on
## harder fights and victories, improved by the Fortune attribute. Item power
## grows with item level forever. Rolls come from a seed, so the same battle
## result always gives the same loot (fair for online play later).

const RARITIES := ["common", "uncommon", "rare", "epic", "legendary"]
const RARITY_WEIGHT := [50.0, 30.0, 14.0, 5.0, 1.0]
const RARITY_POWER := {"common": 1.0, "uncommon": 1.3, "rare": 1.7, "epic": 2.2, "legendary": 3.0}
const RARITY_AFFIXES := {"common": 1, "uncommon": 2, "rare": 2, "epic": 3, "legendary": 4}

const SLOT_BASES := {
	"main_hand": [["Spear", "dmg"], ["Axe", "dmg"], ["Blade", "dmg"], ["Staff", "mana"]],
	"off_hand": [["Shield", "armor"], ["Buckler", "armor"], ["Lantern", "mana"]],
	"head": [["Helm", "hp"], ["Hood", "mana"], ["Cap", "armor"]],
	"body": [["Mail", "armor"], ["Coat", "hp"], ["Jerkin", "hp"]],
	"hands": [["Gauntlets", "dmg"], ["Bracers", "armor"]],
	"feet": [["Boots", "speed"], ["Clogs", "hp"]],
	"amulet": [["Torc", "mana"], ["Amulet", "hp"]],
	"ring1": [["Ring", "dmg"], ["Band", "mana_regen"]],
	"cloak": [["Capa", "armor"], ["Cloak", "hp"]],
	"relic": [["Charm", "mana_regen"], ["Relic", "heal_power"]],
}
const PREFIXES := ["Oxhide", "Granite", "Wolfbone", "Lume-touched", "Sunbronze", "Candlewax", "Ashglass",
	"Chestnut", "Rye-straw", "Slate", "Moura-silver", "Castro", "Ember", "Frostbitten", "Oathbound"]
const SUFFIXES := ["of Salto", "of the Larouco", "of the Chega", "of Tourém", "of the Drowned Bells",
	"of the Seventh Son", "of the Communal Oven", "of the Rabagão", "of Furna", "of Montalegre",
	"of the Wolf Moon", "of the Masked Winter"]

## Stat value per point of item budget.
const STAT_SCALE := {"dmg": 0.55, "hp": 5.0, "armor": 0.18, "speed": 0.02, "attack_speed": 0.006,
	"mana": 3.5, "mana_regen": 0.12, "heal_power": 0.8, "aura_dmg": 0.12}
## [flag, value, description] - powers the hero already understands.
const LEGENDARY_POWERS := [
	["cleave", true, "Power: every blow also strikes the enemies around the target."],
	["lifesteal", 0.08, "Power: heals the hero for 8% of all damage dealt."],
	["execute", true, "Power: +50% damage to enemies below 30% health."],
	["last_stand", true, "Power: survives one lethal blow each battle."],
]
const AFFIX_POOL := ["dmg", "hp", "armor", "speed", "attack_speed", "mana", "mana_regen", "heal_power", "aura_dmg"]

## Items for one finished battle.
static func roll(seed_value: int, item_level: int, fortune: int, victory: bool, difficulty: String) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var count := 0
	if victory:
		count = 1
		if difficulty in ["hard", "brutal"] and rng.randf() < (0.6 if difficulty == "brutal" else 0.35):
			count += 1
		if rng.randf() < float(fortune) * 0.04:
			count += 1
	elif rng.randf() < 0.3 + float(fortune) * 0.02:
		count = 1
	var shift: float = float(fortune) * 0.03 + float({"easy": 0.0, "normal": 0.05, "hard": 0.12, "brutal": 0.2}.get(difficulty, 0.05))
	var out: Array = []
	for i in count:
		out.append(make_item(rng, item_level, shift))
	return out

static func make_item(rng: RandomNumberGenerator, item_level: int, shift: float) -> Dictionary:
	# Rarity: shift moves weight from common toward the top tiers.
	var weights: Array = RARITY_WEIGHT.duplicate()
	weights[0] = maxf(5.0, weights[0] * (1.0 - shift * 1.5))
	for k in range(1, weights.size()):
		weights[k] = weights[k] * (1.0 + shift * float(k) * 1.2)
	var total := 0.0
	for w in weights: total += w
	var pick := rng.randf() * total
	var rarity := "common"
	for k in weights.size():
		pick -= weights[k]
		if pick <= 0.0:
			rarity = RARITIES[k]
			break
	var slot: String = SLOT_BASES.keys()[rng.randi() % SLOT_BASES.size()]
	var base: Array = SLOT_BASES[slot][rng.randi() % SLOT_BASES[slot].size()]
	var budget := (4.0 + float(item_level) * 1.5) * float(RARITY_POWER[rarity])
	var stats := {}
	# The base stat takes half the budget; affixes share the rest.
	_add_stat(stats, String(base[1]), budget * 0.5)
	var affixes := int(RARITY_AFFIXES[rarity])
	for a in affixes:
		_add_stat(stats, String(AFFIX_POOL[rng.randi() % AFFIX_POOL.size()]), budget * 0.5 / float(affixes))
	# Legendary gear carries a power as well as stats.
	var flags := {}
	var power_desc := ""
	if rarity == "legendary":
		var power: Array = LEGENDARY_POWERS[rng.randi() % LEGENDARY_POWERS.size()]
		flags[power[0]] = power[1]
		power_desc = " " + String(power[2])
	var name := "%s %s" % [PREFIXES[rng.randi() % PREFIXES.size()], base[0]]
	if rarity in ["rare", "epic", "legendary"]:
		name += " " + String(SUFFIXES[rng.randi() % SUFFIXES.size()])
	return {"name": name, "slot": slot, "rarity": rarity, "stats": stats, "flags": flags,
		"item_level": item_level, "desc": "Taken from the field. Item level %d.%s" % [item_level, power_desc]}

static func _add_stat(stats: Dictionary, key: String, points: float) -> void:
	var v := points * float(STAT_SCALE.get(key, 1.0))
	# Speeds grow forever too, but along a square root so a hero never
	# outruns the camera.
	if key in ["speed", "attack_speed"]:
		v = float(STAT_SCALE[key]) * sqrt(points) * 2.0
	if key in ["speed", "attack_speed", "mana_regen", "aura_dmg"]:
		stats[key] = snappedf(float(stats.get(key, 0.0)) + v, 0.01)
	else:
		stats[key] = int(stats.get(key, 0)) + maxi(1, roundi(v))

## Hero experience for melting an item down: grows with its level and rarity.
static func salvage_xp(item: Dictionary) -> float:
	return (10.0 + float(item.get("item_level", 1)) * 4.0) * float(RARITY_POWER.get(String(item.get("rarity", "common")), 1.0))
