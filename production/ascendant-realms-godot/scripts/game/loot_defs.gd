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
## Gear sets: 2 pieces give a stat that grows with the set's item level,
## 4 pieces add a power.
const SETS := {
	"salto_oath": {"name": "Oath of Salto", "two": "health", "four": ["last_stand", true, "survive one lethal blow"]},
	"furna_ashglass": {"name": "Furna's Ashglass", "two": "damage", "four": ["lifesteal", 0.1, "10% lifesteal"]},
	"moura_silver": {"name": "Moura Silver", "two": "mana", "four": ["execute", true, "execute wounded foes"]},
	"careto_masks": {"name": "Careto Masks", "two": "speed", "four": ["cleave", true, "cleave"]},
	# Road Tyrant sets: they only drop when a Tyrant falls (never from ordinary battles).
	"tarasca_scale": {"name": "Tarasca Scale", "two": "armour", "four": ["thornmail", 0.25, "25% thorns"]},
	"old_wolf_pelt": {"name": "Pelt of the Old Wolf", "two": "speed and damage", "four": ["haste_on_kill", true, "quicker blows after each kill"]},
	"iron_abbot": {"name": "Iron of the Abbot", "two": "health regeneration", "four": ["last_stand", true, "survive one lethal blow"]},
	"moura_crown": {"name": "Crown of the Moura Queen", "two": "spell power", "four": ["chain_lightning", true, "every fourth blow arcs lightning"]},
	"lobisomem_hide": {"name": "Hide of the Lobisomem", "two": "damage and attack speed", "four": ["lifesteal", 0.12, "12% lifesteal"]},
	"bruxa_charms": {"name": "Charms of the Bruxa", "two": "mana and regeneration", "four": ["quickcast", true, "spells recharge 25% faster"]},
}
const TYRANT_SETS := {"tarasca": "tarasca_scale", "old_wolf": "old_wolf_pelt", "iron_abbot": "iron_abbot", "moura_queen": "moura_crown", "lobisomem": "lobisomem_hide", "bruxa": "bruxa_charms"}

const SET_PREFIX := {"salto_oath": "Oathsworn", "furna_ashglass": "Ashglass", "moura_silver": "Moura-silver", "careto_masks": "Careto",
	"tarasca_scale": "Tarasca-scale", "old_wolf_pelt": "Old Wolf's", "iron_abbot": "Abbot's Iron", "moura_crown": "Moura Queen's", "lobisomem_hide": "Lobisomem's", "bruxa_charms": "Bruxa's"}

## [flag, value, description] - powers the hero already understands.
const LEGENDARY_POWERS := [
	["cleave", true, "Power: every blow also strikes the enemies around the target."],
	["lifesteal", 0.08, "Power: heals the hero for 8% of all damage dealt."],
	["execute", true, "Power: +50% damage to enemies below 30% health."],
	["last_stand", true, "Power: survives one lethal blow each battle."],
	["thornmail", 0.15, "Power: melee attackers take 15% of their blow back."],
	["chain_lightning", true, "Power: every fourth blow arcs lightning into the enemies around the target."],
	["haste_on_kill", true, "Power: each kill quickens the hero's attacks by 40% for 4 seconds."],
	["quickcast", true, "Power: every spell recharges 25% faster."],
	["mana_font", true, "Power: mana returns half again as fast."],
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
	var set_id := ""
	if rarity in ["epic", "legendary"] and rng.randf() < 0.5:
		var common_sets: Array = SETS.keys().filter(func(k): return not TYRANT_SETS.values().has(k))
		set_id = String(common_sets[rng.randi() % common_sets.size()])
		var st: Dictionary = SETS[set_id]
		power_desc += " Set: %s (2 pieces: +%s, 4 pieces: %s)." % [st["name"], st["two"], st["four"][2]]
	var name := "%s %s" % [PREFIXES[rng.randi() % PREFIXES.size()], base[0]]
	if rarity in ["rare", "epic", "legendary"]:
		name += " " + String(SUFFIXES[rng.randi() % SUFFIXES.size()])
	if set_id != "":
		name = "%s %s" % [SET_PREFIX[set_id], base[0]]
	return {"name": name, "slot": slot, "rarity": rarity, "stats": stats, "flags": flags, "set": set_id,
		"item_level": item_level, "desc": "Taken from the field. Item level %d.%s" % [item_level, power_desc]}

## A piece of a Road Tyrant's set: epic or better, always part of the set.
static func tyrant_piece(seed_value: int, item_level: int, boss_id: String) -> Dictionary:
	var sid := String(TYRANT_SETS.get(boss_id, ""))
	if sid == "":
		return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var it: Dictionary = {}
	for attempt in 40:
		it = make_item(rng, item_level + 5, 3.0)
		if String(it["rarity"]) in ["epic", "legendary"]:
			break
	if not (String(it["rarity"]) in ["epic", "legendary"]):
		it["rarity"] = "epic"
	var st: Dictionary = SETS[sid]
	var nouns := {"main_hand": "Blade", "body": "Mail", "head": "Helm", "amulet": "Amulet", "ring1": "Ring",
		"cloak": "Cloak", "off_hand": "Shield", "feet": "Boots", "hands": "Gauntlets", "ring2": "Signet", "relic": "Reliquary"}
	it["set"] = sid
	it["name"] = "%s %s" % [SET_PREFIX[sid], String(nouns.get(String(it["slot"]), "Relic"))]
	it["desc"] = "Torn from a Road Tyrant. Item level %d. Set: %s (2 pieces: +%s, 4 pieces: %s)." % [int(it["item_level"]), st["name"], st["two"], st["four"][2]]
	return it

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
