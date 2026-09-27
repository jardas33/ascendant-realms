extends RefCounted
## The Endless Road: after (and alongside) the saga, an escalating chain of
## battles with no last stage. Every stage is generated from its number alone
## (a seeded generator, no hidden state), so the same stage is the same battle
## for every player - ready for shared leaderboards and online play later.

const RACE_IDS := ["vorthak", "sunspear", "hollow", "frostborn", "wyldkin", "karak", "grimtusk", "sylvan", "lioraen", "barrosan"]
const DIFFICULTY_STEPS := ["easy", "normal", "normal", "hard", "hard", "brutal"]
const PLACES := [
	"Pitões das Júnias", "Tourém Ford", "Cabril Gorge", "Paredes do Rio", "Sirvozelo",
	"Vilarinho Seco", "Covelães", "Fervidelas", "Cela Pass", "Meixedo Heights",
	"Travassos Barrows", "Solveira Stones", "Gralhas Crossing", "Pardieiros", "Padornelos",
	"The Larouco Shoulder", "Negrões Road", "Viade Moor", "Sezelhe Fold", "Outeiro Watch",
]
const EPITHETS := ["of Ash", "of Candles", "of the Wolf Moon", "of Bronze", "of Broken Oaths",
	"of Seven Springs", "of the Drowned Bells", "of Masks", "of Iron", "of Silver Tears"]

## A stage's full description. Depth starts at 1 and never ends.
static func stage(depth: int, player_race: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77_000_077 + depth * 7_919
	var maps: Array = []
	for info in MapDefs.list_infos():
		maps.append(info)
	var foes_wanted := 1 + mini(2, (depth - 1) / 4)
	var pool: Array = maps.filter(func(m): return int(m.get("players", 4)) >= foes_wanted + 1)
	if pool.is_empty():
		pool = maps
	var map_info: Dictionary = pool[rng.randi() % pool.size()]
	var foes := mini(foes_wanted, int(map_info.get("players", 2)) - 1)
	# Difficulty climbs a step every two stages and stays at Brutal after.
	var step := mini(DIFFICULTY_STEPS.size() - 1, (depth - 1) / 2)
	var races: Array = RACE_IDS.filter(func(r): return r != player_race)
	var opponents: Array = []
	for i in foes:
		var diff: String = DIFFICULTY_STEPS[maxi(0, step - i)]
		# Deep on the road every enemy fights at full strength.
		if depth > 12 + i * 6:
			diff = "brutal"
		opponents.append({"race": races[rng.randi() % races.size()], "difficulty": diff})
	# Past the ladder, the enemy's Lume swells: bonus income that keeps rising.
	var might := maxf(0.0, float(depth - 12)) * 0.35
	return {
		"depth": depth,
		"title": "%s %s" % [PLACES[rng.randi() % PLACES.size()], EPITHETS[rng.randi() % EPITHETS.size()]],
		"map": String(map_info["id"]),
		"opponents": opponents,
		"might": might,
		"xp_mult": 1.0 + float(depth) * 0.08,
	}

const RELIC_SLOTS := ["main_hand", "body", "head", "amulet", "ring1", "cloak", "off_hand", "feet", "hands", "ring2", "relic"]
const RELIC_NOUNS := {"main_hand": "Blade", "body": "Mail", "head": "Helm", "amulet": "Amulet", "ring1": "Ring",
	"cloak": "Cloak", "off_hand": "Shield", "feet": "Boots", "hands": "Gauntlets", "ring2": "Signet", "relic": "Reliquary"}

## Every fifth stage forges a relic. Its power grows with the stage forever,
## so the road always has something better further on.
static func relic(depth: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5_550_555 + depth * 104_729
	var slot: String = RELIC_SLOTS[(depth / 5 - 1) % RELIC_SLOTS.size()]
	var tier := float(depth) / 5.0
	var stats := {}
	match slot:
		"main_hand": stats = {"dmg": roundi(3 + tier * 2.5), "attack_speed": snappedf(0.02 + tier * 0.005, 0.001)}
		"off_hand", "body": stats = {"armor": roundi(1 + tier * 0.9), "hp": roundi(30 + tier * 25)}
		"head", "hands": stats = {"hp": roundi(20 + tier * 18), "dmg": roundi(1 + tier * 1.2)}
		"feet": stats = {"speed": snappedf(0.15 + tier * 0.05, 0.01), "armor": roundi(tier * 0.5)}
		"amulet", "relic": stats = {"mana": roundi(20 + tier * 15), "mana_regen": snappedf(0.5 + tier * 0.3, 0.1)}
		_: stats = {"dmg": roundi(2 + tier * 1.5), "hp": roundi(15 + tier * 12)}
	var rarity := "rare" if depth < 15 else ("epic" if depth < 35 else "legendary")
	var place: String = String(PLACES[rng.randi() % PLACES.size()]).replace("The ", "the ")
	return {"name": "Lume-forged %s of %s" % [RELIC_NOUNS[slot], place], "slot": slot, "rarity": rarity,
		"stats": stats, "flags": {}, "desc": "Won on the Endless Road, stage %d. It is warm, and it remembers the battle." % depth}
