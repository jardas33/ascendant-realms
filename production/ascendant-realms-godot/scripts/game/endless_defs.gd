extends RefCounted
## The Endless Road: after (and alongside) the saga, an escalating chain of
## battles with no last stage. Every stage is generated from its number alone
## (a seeded generator, no hidden state), so the same stage is the same battle
## for every player - ready for shared leaderboards and online play later.

const RACE_IDS := ["vorthak", "sunspear", "hollow", "frostborn", "wyldkin", "karak", "grimtusk", "sylvan", "lioraen", "barrosan"]
## Every tenth stage is one of Barroso's feasts, fought the old way.
const FESTIVALS := [
	{"title": "Entrudo", "race": "frostborn", "mood": "dusk", "text": "Carnival. The Caretos come down from the hills in red and green fringes, cowbells ringing, and they do not come to dance alone."},
	{"title": "The Chega de Bois", "race": "barrosan", "mood": "", "text": "The villages set their bulls against each other, and this year the rival clans want more than a bull fight."},
	{"title": "The Night of the Witches", "race": "hollow", "mood": "night", "text": "Friday the thirteenth in Montalegre. The queimada burns blue, and the candles on the road are not all held by the living."},
	{"title": "Magusto", "race": "wyldkin", "mood": "dusk", "text": "Chestnuts roast in the ash and the new wine is opened. The wolves smell the feast from the Larouco."},
	{"title": "The Fires of São João", "race": "vorthak", "mood": "ember", "text": "Midsummer bonfires on every hill. Across the valley, drowned Furna lights fires of its own."},
]
const TWISTS := ["night", "storm", "ember", "dusk", "champions", "warband", "spoils", "blood_moon", "lean", "fortified", "veterans", "allies", "gloom"]
const TWIST_TEXT := {"night": "Night battle", "storm": "Storm", "ember": "Fire on the road", "dusk": "Dusk",
	"champions": "Champions: enemy heroes far tougher", "warband": "Warband: enemy reinforcements at 3 minutes",
	"spoils": "Rich spoils: extra loot and +25% experience",
	"blood_moon": "Blood Moon: every blow lands 25% harder, on both sides",
	"lean": "Lean Season: both sides start with half their stores",
	"fortified": "Fortified: the enemy starts with two towers raised",
	"veterans": "Veteran foes: enemy soldiers arrive already ranked",
	"allies": "Allies: four of your own soldiers join at the start",
	"gloom": "Gloom: the fog closes in, your soldiers see 40% less far"}
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
	# Stage twists from stage 3: 1 or 2, seeded like everything else.
	var twists: Array = []
	var mood := ""
	if depth >= 3:
		var twist_pool := TWISTS.duplicate()
		var n := 1 + rng.randi() % 2
		for k in n:
			var t: String = twist_pool[rng.randi() % twist_pool.size()]
			twist_pool.erase(t)
			if t in ["night", "storm", "ember", "dusk"]:
				if mood != "":
					continue
				mood = t
			twists.append(t)
	var festival := {}
	if depth % 10 == 0:
		festival = FESTIVALS[(depth / 10 - 1) % FESTIVALS.size()]
		for o in opponents:
			o["race"] = festival["race"]
		twists = ["spoils"]
		mood = String(festival["mood"])
		if mood != "":
			twists.append(mood)
	# Past the ladder, the enemy's Lume swells: bonus income that keeps rising.
	var might := maxf(0.0, float(depth - 12)) * 0.35
	var title := "%s %s" % [PLACES[rng.randi() % PLACES.size()], EPITHETS[rng.randi() % EPITHETS.size()]]
	var mutations := mutations_for(depth)
	if not festival.is_empty():
		title = String(festival["title"])
	return {
		"depth": depth,
		"festival": String(festival.get("text", "")),
		"title": title,
		"map": String(map_info["id"]),
		"opponents": opponents,
		"might": might,
		"xp_mult": 1.0 + float(depth) * 0.08,
		"twists": twists,
		"mood": mood,
		"mutations": mutations,
	}

## Deep on the road the enemy itself changes. From stage 30 every enemy
## soldier carries mutations: one more every 30 stages, forever, and a
## mutation drawn twice stacks. Seeded by the stage, like everything else.
const MUTATIONS := {
	"ironhide": "Ironhide: +2 armour per rank",
	"frenzy": "Frenzy: +12% attack speed per rank",
	"leeching": "Leeching: heal 5% of damage dealt per rank",
	"titan": "Titan: +25% health per rank",
	"swift": "Swift: +10% speed per rank",
}

static func mutations_for(depth: int) -> Dictionary:
	var out := {}
	if depth < 30:
		return out
	var rng := RandomNumberGenerator.new()
	rng.seed = 3_141_593 + depth * 6_607
	var keys: Array = MUTATIONS.keys()
	for i in depth / 30:
		var k: String = keys[rng.randi() % keys.size()]
		out[k] = int(out.get(k, 0)) + 1
	return out

## Every 25th stage a Road Tyrant holds the enemy stronghold: a named giant
## with a mechanic of its own. They return, stronger, every hundred stages.
const BOSSES := [
	{"id": "tarasca", "name": "The Tarasca of the Cávado", "kind": "pulse",
		"text": "The river-dragon of the old tales. Every few seconds it breathes fire in a ring around itself: fight it from range, or step back when it rears."},
	{"id": "old_wolf", "name": "The Old Wolf of Larouco", "kind": "summon",
		"text": "Grey as the mountain and older than the villages. It howls, and the pack answers: kill the wolves or be buried in them."},
	{"id": "iron_abbot", "name": "The Iron Abbot of Pitões", "kind": "regen",
		"text": "The monastery's last guardian, bound in iron and prayer. It heals quickly whenever it is left alone for a breath: never stop striking."},
	{"id": "moura_queen", "name": "The Moura Queen", "kind": "ward",
		"text": "Queen of the enchanted Mouras, beautiful and terrible. While her court stands around her, she takes half damage: break the court first."},
]

static func boss(depth: int) -> Dictionary:
	if depth <= 0 or depth % 25 != 0:
		return {}
	return BOSSES[(depth / 25 - 1) % BOSSES.size()]

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
		"main_hand": stats = {"dmg": roundi(3 + tier * 2.5), "attack_speed": snappedf(0.02 + sqrt(tier) * 0.01, 0.001)}
		"off_hand", "body": stats = {"armor": roundi(1 + tier * 0.9), "hp": roundi(30 + tier * 25)}
		"head", "hands": stats = {"hp": roundi(20 + tier * 18), "dmg": roundi(1 + tier * 1.2)}
		"feet": stats = {"speed": snappedf(0.15 + sqrt(tier) * 0.08, 0.01), "armor": roundi(tier * 0.5)}
		"amulet", "relic": stats = {"mana": roundi(20 + tier * 15), "mana_regen": snappedf(0.5 + tier * 0.3, 0.1)}
		_: stats = {"dmg": roundi(2 + tier * 1.5), "hp": roundi(15 + tier * 12)}
	var rarity := "rare" if depth < 15 else ("epic" if depth < 35 else "legendary")
	var place: String = String(PLACES[rng.randi() % PLACES.size()]).replace("The ", "the ")
	return {"name": "Lume-forged %s of %s" % [RELIC_NOUNS[slot], place], "slot": slot, "rarity": rarity,
		"stats": stats, "flags": {}, "desc": "Won on the Endless Road, stage %d. It is warm, and it remembers the battle." % depth}
