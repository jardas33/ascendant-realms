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
		"blurb": "Rugged highland stone. Durable infantry, mighty defenses, patient economy. Hold the high ground and counter-punch.",
		"color": Color(0.72, 0.66, 0.52),
		"hero": "barrosan_hero_thane",
		"hero_name": "War-Thane",
		"mechanic": "Fortify: buildings and units near your Clanhold gain bonus armor.",
		"main_building": "barrosan_clanhold",
		"worker": "barrosan_worker",
		"start_units": ["barrosan_worker", "barrosan_worker", "barrosan_worker", "barrosan_spears"],
	},
	"lioraen": {
		"name": "Lioraen Concord",
		"blurb": "Living nature and mobility. Fast skirmishers, healing groves, ground that mends your army. Flow around the enemy.",
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
		"blurb": "Volatile ash-glass power. Cheap swarms, dangerous magic, aggressive expansion. Overwhelm before your fire burns out.",
		"color": Color(0.62, 0.35, 0.72),
		"hero": "vorthak_hero_binder",
		"hero_name": "Rift Binder",
		"mechanic": "Rift Toll: thralls are cheap and fast, so pressure the enemy early and often.",
		"main_building": "vorthak_nighthold",
		"worker": "vorthak_worker",
		"start_units": ["vorthak_worker", "vorthak_worker", "vorthak_worker", "vorthak_thrall"],
	},
	"grimtusk": {
		"name": "Grimtusk Horde",
		"blurb": "A thundering wave of green muscle and sharpened steel. The Grimtusk answer every problem with more bodies and louder war drums.",
		"color": Color(0.45, 0.6, 0.25),
		"hero": "grimtusk_hero_warlord",
		"hero_name": "Warboss",
		"mechanic": "Bloodfury: cheap, fast warriors — bury the enemy under a green tide.",
		"main_building": "grimtusk_stronghold",
		"worker": "grimtusk_peon",
		"start_units": ["grimtusk_peon", "grimtusk_peon", "grimtusk_peon", "grimtusk_grunt"],
	},
	"sylvan": {
		"name": "Sylvan Court",
		"blurb": "Ancient elves of silver and starlight, wielding precision magic and longbows that never miss twice. Quality over quantity, always.",
		"color": Color(0.55, 0.85, 0.75),
		"hero": "sylvan_hero_archon",
		"hero_name": "High Archon",
		"mechanic": "Precision: elite archers and mages with superior range and vision.",
		"main_building": "sylvan_court",
		"worker": "sylvan_acolyte",
		"start_units": ["sylvan_acolyte", "sylvan_acolyte", "sylvan_acolyte", "sylvan_bladesinger"],
	},
	"karak": {
		"name": "Karak Dwarves",
		"blurb": "Bred in the deep stone, hammered by centuries of war. No army hits harder or survives longer than a Karak battle line.",
		"color": Color(0.85, 0.6, 0.3),
		"hero": "karak_hero_thanelord",
		"hero_name": "Thane-Lord",
		"mechanic": "Stone Resolve: slow but incredibly durable warriors and mighty siege.",
		"main_building": "karak_hold",
		"worker": "karak_miner",
		"start_units": ["karak_miner", "karak_miner", "karak_miner", "karak_warrior"],
	},
	"sunspear": {
		"name": "Sunspear Dominion",
		"blurb": "Legions forged under a burning sun, disciplined to the last man. Their bronze blades flash and their morale never breaks.",
		"color": Color(0.9, 0.75, 0.35),
		"hero": "sunspear_hero_pharaoh",
		"hero_name": "Sun Pharaoh",
		"mechanic": "Sunfire: disciplined, balanced legions with resilient morale.",
		"main_building": "sunspear_palace",
		"worker": "sunspear_laborer",
		"start_units": ["sunspear_laborer", "sunspear_laborer", "sunspear_laborer", "sunspear_legion"],
	},
	"wyldkin": {
		"name": "Wyldkin",
		"blurb": "Furred and feathered beastfolk who run with the wind and hunt as one. Their packs swarm from every direction before you can draw a breath.",
		"color": Color(0.6, 0.45, 0.3),
		"hero": "wyldkin_hero_alpha",
		"hero_name": "Pack Alpha",
		"mechanic": "Pack Hunt: the fastest army in the realm, deadly in a coordinated swarm.",
		"main_building": "wyldkin_denhold",
		"worker": "wyldkin_forager",
		"start_units": ["wyldkin_forager", "wyldkin_forager", "wyldkin_forager", "wyldkin_clawwarrior"],
	},
	"hollow": {
		"name": "Hollow Legion",
		"blurb": "Death is merely a setback for the Hollow. Their endless skeletal ranks rise again and again while dark necromancers unravel the living.",
		"color": Color(0.55, 0.6, 0.7),
		"hero": "hollow_hero_lich",
		"hero_name": "Lich King",
		"mechanic": "Undying: endless cheap skeletons and potent dark magic — attrition is your ally.",
		"main_building": "hollow_necropolis",
		"worker": "hollow_gravedigger",
		"start_units": ["hollow_gravedigger", "hollow_gravedigger", "hollow_gravedigger", "hollow_skeleton"],
	},
	"frostborn": {
		"name": "Frostborn Jarls",
		"blurb": "Towering warriors from the frozen north, who greet blizzards like old friends. Their axes split shields and skulls with equal enthusiasm.",
		"color": Color(0.6, 0.8, 0.95),
		"hero": "frostborn_hero_jarl",
		"hero_name": "Frost Jarl",
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
func compute_damage(raw: float, dmg_type: String, armor_class: String, flat_armor: float) -> float:
	var mult: float = damage_multiplier(dmg_type, armor_class)
	var dmg: float = raw * mult - maxf(0.0, flat_armor) * 0.5
	return maxf(1.0, dmg)
