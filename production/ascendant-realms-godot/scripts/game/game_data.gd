extends Node
## GameData — the data-driven registry for Ascendant Realms.
## Every race, unit, building, tech, resource, damage rule, skill and item
## lives here (or in the def files it aggregates). Gameplay scripts read from
## this singleton; they never hardcode race/unit specifics.

# ---------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------
const RESOURCES := ["food", "timber", "stone", "gold"]

# Team colors (color-blind-safe distinct hues; also differ in shape via banners)
const TEAM_COLORS := {
	0: Color(0.30, 0.55, 0.95),   # Player - blue
	1: Color(0.90, 0.30, 0.25),   # Enemy 1 - red
	2: Color(0.45, 0.80, 0.35),   # Enemy 2 - green
	3: Color(0.85, 0.70, 0.20),   # Enemy 3 - gold
}

# ---------------------------------------------------------------------------
# Races
# ---------------------------------------------------------------------------
const RACES := {
	"barrosan": {
		"name": "Barrosan Clans",
		"blurb": "Granite villages of the Terras Frias, bound by the shared oven, the common pasture and the village bull. Slow to anger, impossible to move: stout infantry, mighty walls, a patient economy. What the village carries, no king can take.",
		"color": Color(0.72, 0.66, 0.52),
		"hero": "barrosan_hero_thane",
		"hero_name": "Jardas",
		"mechanic": "Fortify: buildings and units near your Clanhold gain bonus armor.",
		"main_building": "barrosan_clanhold",
		"worker": "barrosan_worker",
		"start_units": ["barrosan_worker", "barrosan_worker", "barrosan_worker", "barrosan_spears"],
	},
	"lioraen": {
		"name": "Lioraen Concord",
		"blurb": "The living groves of the highland springs, whom village legend calls the Mouras Encantadas. They swore to guard the Lume if the villages would remember them. The villages forgot, and they are fading into trees. Fast skirmishers, healing groves, ground that mends your army.",
		"color": Color(0.35, 0.72, 0.55),
		"hero": "lioraen_hero_warden",
		"hero_name": "Grove Warden",
		"mechanic": "Bloomfields: your Groveheart slowly heals nearby friendly units.",
		"main_building": "lioraen_groveheart",
		"worker": "lioraen_worker",
		"start_units": ["lioraen_worker", "lioraen_worker", "lioraen_worker", "lioraen_thorns"],
	},
	"vorthak": {
		"name": "Vorthak Cabal",
		"blurb": "What is left of Furna, the village the Dominion drowned seventy-seven years ago. Their drowned Lume rotted into violet ash-glass, and it rotted them too. Cheap swarms, dangerous magic, relentless aggression. They learned to burn underwater.",
		"color": Color(0.62, 0.35, 0.72),
		"hero": "vorthak_hero_binder",
		"hero_name": "Rift Binder",
		"mechanic": "Rift Toll: thralls are cheap and fast, so pressure the enemy early and often.",
		"main_building": "vorthak_nighthold",
		"worker": "vorthak_worker",
		"start_units": ["vorthak_worker", "vorthak_worker", "vorthak_worker", "vorthak_thrall"],
	},
	"grimtusk": {
		"name": "Ironmaw Horde",
		"blurb": "Slaves of the Dominion's Lume-iron mines who broke their chains and took the iron into their own flesh: tusked, huge and furious. A slave revolt that became a nation, answering every master with more bodies and louder drums.",
		"color": Color(0.45, 0.6, 0.25),
		"hero": "grimtusk_hero_warlord",
		"hero_name": "Warboss",
		"mechanic": "Bloodfury: cheap, fast warriors. Bury the enemy under an iron tide.",
		"main_building": "grimtusk_stronghold",
		"worker": "grimtusk_peon",
		"start_units": ["grimtusk_peon", "grimtusk_peon", "grimtusk_peon", "grimtusk_grunt"],
	},
	"sylvan": {
		"name": "Moura Court",
		"blurb": "The Mouras who refused to fade. They sold their Lume to the Dominion for eternity and became silver-eyed, perfect and cold. Precise magic and longbows that never miss twice. Every bargain has a price in gold that turns to coal.",
		"color": Color(0.55, 0.85, 0.75),
		"hero": "sylvan_hero_archon",
		"hero_name": "High Moura",
		"mechanic": "Precision: elite archers and mages with superior range and vision.",
		"main_building": "sylvan_court",
		"worker": "sylvan_acolyte",
		"start_units": ["sylvan_acolyte", "sylvan_acolyte", "sylvan_acolyte", "sylvan_bladesinger"],
	},
	"karak": {
		"name": "Granitborn",
		"blurb": "The people of the castros, the old hillforts, who let the Lume turn them slowly to stone so they could remember every Ascension. Slow, unbreakable, and they forget nothing. Stone keeps the ledger of the dead.",
		"color": Color(0.85, 0.6, 0.3),
		"hero": "karak_hero_thanelord",
		"hero_name": "Thane-Lord",
		"mechanic": "Stone Resolve: slow but incredibly durable warriors, mighty siege, castro walls a fifth tougher than anyone else's, and stone-skinned quarriers.",
		"main_building": "karak_hold",
		"worker": "karak_miner",
		"start_units": ["karak_miner", "karak_miner", "karak_miner", "karak_warrior"],
	},
	"sunspear": {
		"name": "Aurean Dominion",
		"blurb": "The southern empire of bronze and sun that won the seventy-fifth Ascension and never gave it back. Its engineers drown the highland springs behind great dams to end the Ascension wars forever. Disciplined legions whose morale never breaks, and who are not entirely wrong.",
		"color": Color(0.9, 0.75, 0.35),
		"hero": "sunspear_hero_pharaoh",
		"hero_name": "Sun Legate",
		"mechanic": "Sunfire: disciplined, balanced legions with resilient morale.",
		"main_building": "sunspear_palace",
		"worker": "sunspear_laborer",
		"start_units": ["sunspear_laborer", "sunspear_laborer", "sunspear_laborer", "sunspear_legion"],
	},
	"wyldkin": {
		"name": "Wolfveil Clans",
		"blurb": "The seventh sons of highland families, who run with the wolves under the full moon. Hunted for centuries and driven into the stone wolf-traps, loyal only to the pack. The fastest army in the realm.",
		"color": Color(0.6, 0.45, 0.3),
		"hero": "wyldkin_hero_alpha",
		"hero_name": "Sétimo, the Seventh",
		"mechanic": "Pack Hunt: the fastest army in the realm, deadly in a coordinated swarm.",
		"main_building": "wyldkin_denhold",
		"worker": "wyldkin_forager",
		"start_units": ["wyldkin_forager", "wyldkin_forager", "wyldkin_forager", "wyldkin_clawwarrior"],
	},
	"hollow": {
		"name": "The Compaña",
		"blurb": "The procession of the dead that walks the highland roads by candlelight, a living soul forced to carry the cross at the front. They walk until someone remembers their names. Endless ranks and sorrowful magic; attrition is their ally.",
		"color": Color(0.55, 0.6, 0.7),
		"hero": "hollow_hero_lich",
		"hero_name": "Candle-King",
		"mechanic": "Undying: endless cheap dead and potent grave magic. Attrition is your ally.",
		"main_building": "hollow_necropolis",
		"worker": "hollow_gravedigger",
		"start_units": ["hollow_gravedigger", "hollow_gravedigger", "hollow_gravedigger", "hollow_skeleton"],
	},
	"frostborn": {
		"name": "Careto Host",
		"blurb": "Masked winter revelers of the Larouco in red-and-green fringes and iron cowbells. They look like chaos, but they are the oldest wardens of the border between the living and the dead, and they chase both winter and the dead back into the ground.",
		"color": Color(0.6, 0.8, 0.95),
		"hero": "frostborn_hero_jarl",
		"hero_name": "Eldest Mask",
		"mechanic": "Winter's Wrath: towering, hard-hitting warriors who thrive in brutal frontal assaults.",
		"main_building": "frostborn_mead_hall",
		"worker": "frostborn_thrall",
		"start_units": ["frostborn_thrall", "frostborn_thrall", "frostborn_thrall", "frostborn_reaver"],
	},
}

# ---------------------------------------------------------------------------
# Damage / armor interaction table
# damage_type -> armor_class -> multiplier
# ---------------------------------------------------------------------------
const ARMOR_CLASSES := ["unarmored", "light", "medium", "heavy", "fortified"]
const DAMAGE_TABLE := {
	"slash":  {"unarmored": 1.25, "light": 1.15, "medium": 1.0,  "heavy": 0.75, "fortified": 0.5},
	"pierce": {"unarmored": 1.0,  "light": 1.3,  "medium": 1.0,  "heavy": 0.7,  "fortified": 0.4},
	"blunt":  {"unarmored": 0.9,  "light": 0.9,  "medium": 1.15, "heavy": 1.3,  "fortified": 0.85},
	"arcane": {"unarmored": 1.1,  "light": 1.1,  "medium": 1.15, "heavy": 1.15, "fortified": 0.6},
	"siege":  {"unarmored": 0.6,  "light": 0.6,  "medium": 0.9,  "heavy": 1.0,  "fortified": 2.0},
}

var _units := {}
var _buildings := {}
var _tech := {}

func _ready() -> void:
	_units = UnitDefs.get_all()
	_buildings = BuildingDefs.get_all()
	_tech = TechDefs.get_all()

# --- accessors -------------------------------------------------------------
func get_race(id: String) -> Dictionary:
	return RACES.get(id, {})

func get_unit(id: String) -> Dictionary:
	return _units.get(id, {})

func get_building(id: String) -> Dictionary:
	return _buildings.get(id, {})

func get_tech(id: String) -> Dictionary:
	return _tech.get(id, {})

## "Spells: A, B, C  ·  Landmark: L" for a people, for the faction pages.
func people_summary(race: String) -> String:
	var ab: Dictionary = SkillDefs.get_abilities()
	var names: Array = []
	var sig := String(SkillDefs.SIGNATURE.get(race, ""))
	if sig != "":
		names.append(String(ab.get(sig, {}).get("name", sig)))
	for pid in SkillDefs.PEOPLE_SPELLS.get(race, []):
		names.append(String(ab.get(String(pid), {}).get("name", pid)))
	var landmark := ""
	for bid in buildings_for_race(race):
		if String(get_building(bid).get("kind", "")) == "landmark":
			landmark = String(get_building(bid).get("name", bid))
	var bits: Array = []
	if not names.is_empty():
		bits.append("Spells: " + ", ".join(names))
	if landmark != "":
		bits.append("Landmark: " + landmark)
	return "  ·  ".join(bits)

## Everything a building of this people can research: its authored list,
## plus the ranked army upgrades and this people's own upgrades at the forge,
## and the economy upgrades at the main hall. Tier advances are listed apart.
func research_for(bdef: Dictionary, race: String) -> Array:
	var out: Array = Array(bdef.get("research", [])).duplicate()
	var is_main := bool(bdef.get("is_hq", false)) or String(bdef.get("kind", "")) == "main"
	var at := "main" if is_main else ("economy" if out.has("tech_weapons") else "")
	if at == "":
		return out
	for tid in _tech:
		var t: Dictionary = _tech[tid]
		if String(t.get("kind", "")) == "tier" or String(t.get("at", "")) != at or out.has(tid):
			continue
		if t.has("race") and String(t["race"]) != race:
			continue
		out.append(tid)
	return out

func units_for_race(race: String) -> Array:
	var out := []
	for id in _units:
		if _units[id].get("race", "") == race:
			out.append(id)
	return out

func buildings_for_race(race: String) -> Array:
	var out := []
	for id in _buildings:
		if _buildings[id].get("race", "") == race:
			out.append(id)
	return out

func damage_multiplier(dmg_type: String, armor_class: String) -> float:
	if DAMAGE_TABLE.has(dmg_type):
		return DAMAGE_TABLE[dmg_type].get(armor_class, 1.0)
	return 1.0

## Effective damage after armor-class table and flat armor reduction.
const ARMOR_MIN_DAMAGE_SHARE := 0.25

func compute_damage(raw: float, dmg_type: String, armor_class: String, flat_armor: float) -> float:
	var mult: float = damage_multiplier(dmg_type, armor_class)
	var hit: float = raw * mult
	var dmg: float = hit - maxf(0.0, flat_armor) * 0.5
	# Armor never blocks more than three quarters of a hit. Without this
	# floor a geared high-level hero (66 armor) took 1 damage from every
	# ordinary soldier and could not be killed by an army. Ordinary units
	# never reach the floor: their armor blocks at most a few points.
	return maxf(1.0, maxf(dmg, hit * ARMOR_MIN_DAMAGE_SHARE))
