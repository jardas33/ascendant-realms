class_name TechDefs
## Technology definitions: tier advances, army and economy upgrades, and the
## two upgrades unique to each people. Researched at a building; applied
## globally to the researching player.
##
## An upgrade's "effects" list is applied to the units whose role matches
## "who" (all, melee, ranged, defender, flanker, siege, caster, worker, hero):
## dmg and armor add, hp_mult and speed_mult add a fraction, range and vision
## add meters, lifesteal adds a fraction of damage dealt. "flags" add to the
## commander's build flags (gather_bonus, train_speed, carry_bonus,
## building_hp, tower_dmg, bloom_boost). "req" lists techs needed first and
## "min_tier" the Age needed. A "race" entry shows only for that people.

static func get_all() -> Dictionary:
	return {
	"advance_tier_2": {
		"name": "Advance to Age of Iron", "kind": "tier", "tier": 2,
		"cost": {"food": 200, "gold": 150}, "time": 40, "at": "main",
		"desc": "Opens the Age of Iron: new units, elite troops and advanced buildings.",
	},
	"advance_tier_3": {
		"name": "Advance to Age of Lume", "kind": "tier", "tier": 3,
		"cost": {"food": 400, "gold": 300, "stone": 150}, "time": 60, "at": "main",
		"desc": "Opens the Age of Lume: elites, casters and siege engines.",
	},
	# --- Army: three ranks of weapons and of armor --------------------------
	"tech_weapons": {
		"name": "Forged Weapons", "kind": "upgrade", "stat": "dmg", "add": 4,
		"cost": {"gold": 120, "stone": 60}, "time": 35, "at": "economy",
		"desc": "+4 attack damage to all your combat units.",
	},
	"tech_weapons_2": {
		"name": "Lume-tempered Steel", "kind": "upgrade", "effects": [{"who": "all", "dmg": 4}],
		"req": ["tech_weapons"], "min_tier": 2,
		"cost": {"gold": 200, "stone": 120}, "time": 45, "at": "economy",
		"desc": "+4 more attack damage to all your combat units.",
	},
	"tech_weapons_3": {
		"name": "Ascendant Arms", "kind": "upgrade", "effects": [{"who": "all", "dmg": 5}],
		"req": ["tech_weapons_2"], "min_tier": 3,
		"cost": {"gold": 320, "stone": 200}, "time": 55, "at": "economy",
		"desc": "+5 more attack damage to all your combat units.",
	},
	"tech_armor": {
		"name": "Tempered Armor", "kind": "upgrade", "stat": "armor", "add": 2,
		"cost": {"gold": 120, "timber": 80}, "time": 35, "at": "economy",
		"desc": "+2 armor to all your combat units.",
	},
	"tech_armor_2": {
		"name": "Riveted Plate", "kind": "upgrade", "effects": [{"who": "all", "armor": 2}],
		"req": ["tech_armor"], "min_tier": 2,
		"cost": {"gold": 200, "timber": 140}, "time": 45, "at": "economy",
		"desc": "+2 more armor to all your combat units.",
	},
	"tech_armor_3": {
		"name": "Lume-warded Plate", "kind": "upgrade", "effects": [{"who": "all", "armor": 3}],
		"req": ["tech_armor_2"], "min_tier": 3,
		"cost": {"gold": 320, "timber": 220}, "time": 55, "at": "economy",
		"desc": "+3 more armor to all your combat units.",
	},
	# --- Economy and defense, at the main hall -------------------------------
	"tech_tools": {
		"name": "Sharpened Tools", "kind": "upgrade", "flags": {"gather_bonus": 0.15},
		"cost": {"timber": 100, "gold": 60}, "time": 30, "at": "main",
		"desc": "Workers gather 15% faster.",
	},
	"tech_carts": {
		"name": "Wider Baskets", "kind": "upgrade", "flags": {"carry_bonus": 4},
		"req": ["tech_tools"], "min_tier": 2,
		"cost": {"timber": 160, "gold": 100}, "time": 40, "at": "main",
		"desc": "Workers carry 4 more with every trip.",
	},
	"tech_masonry": {
		"name": "Granite Masonry", "kind": "upgrade", "flags": {"building_hp": 0.25},
		"min_tier": 2,
		"cost": {"stone": 200, "gold": 80}, "time": 45, "at": "main",
		"desc": "All your buildings have 25% more health.",
	},
	"tech_braziers": {
		"name": "Watch-fire Braziers", "kind": "upgrade", "flags": {"tower_dmg": 0.30},
		"cost": {"timber": 120, "stone": 80}, "time": 35, "at": "main",
		"desc": "Your towers and watch-fires strike 30% harder.",
	},
	# --- Barrosan Clans -------------------------------------------------------
	"bar_horns": {
		"name": "Horns of the Chega", "kind": "upgrade", "race": "barrosan",
		"effects": [{"who": "melee", "dmg": 3, "hp_mult": 0.10}, {"who": "defender", "dmg": 3, "hp_mult": 0.10}],
		"cost": {"food": 150, "gold": 120}, "time": 40, "at": "economy",
		"desc": "Like the bulls at the Chega, your foot soldiers never give ground: melee and spear units +3 damage and +10% health.",
	},
	"bar_oven": {
		"name": "The Shared Oven", "kind": "upgrade", "race": "barrosan",
		"effects": [{"who": "worker", "hp_mult": 0.25}], "flags": {"gather_bonus": 0.12},
		"cost": {"food": 120, "timber": 100}, "time": 35, "at": "main",
		"desc": "What the village bakes together feeds everyone: workers gather 12% faster and have 25% more health.",
	},
	# --- Lioraen Concord -----------------------------------------------------
	"lio_arrows": {
		"name": "Moura-sung Arrows", "kind": "upgrade", "race": "lioraen",
		"effects": [{"who": "ranged", "dmg": 2, "range": 2.0}],
		"cost": {"timber": 140, "gold": 120}, "time": 40, "at": "economy",
		"desc": "Arrows fletched with a Moura's song: ranged units +2 damage and +2 range.",
	},
	"lio_roots": {
		"name": "Deep Roots", "kind": "upgrade", "race": "lioraen",
		"flags": {"bloom_boost": true, "building_hp": 0.15}, "min_tier": 2,
		"cost": {"timber": 160, "stone": 80}, "time": 45, "at": "main",
		"desc": "The groves drink from the springs: healing auras are stronger and buildings have 15% more health.",
	},
	# --- Vorthak Cabal -------------------------------------------------------
	"vor_ashglass": {
		"name": "Ash-glass Blades", "kind": "upgrade", "race": "vorthak",
		"effects": [{"who": "melee", "dmg": 4}, {"who": "flanker", "dmg": 4}],
		"cost": {"gold": 140, "stone": 100}, "time": 40, "at": "economy",
		"desc": "Blades knapped from what the fire left of Furna: melee and raiding units +4 damage.",
	},
	"vor_toll": {
		"name": "The Rift Toll", "kind": "upgrade", "race": "vorthak",
		"flags": {"train_speed": 0.20},
		"cost": {"food": 150, "gold": 100}, "time": 35, "at": "main",
		"desc": "The rift takes its toll and gives soldiers back faster: units train 20% faster.",
	},
	# --- Ironmaw Horde -------------------------------------------------------
	"grim_iron": {
		"name": "Iron in the Flesh", "kind": "upgrade", "race": "grimtusk",
		"effects": [{"who": "all", "hp_mult": 0.08, "armor": 1}],
		"cost": {"stone": 140, "gold": 120}, "time": 40, "at": "economy",
		"desc": "The iron they were chained with is now part of them: all soldiers +8% health and +1 armor.",
	},
	"grim_stampede": {
		"name": "Stampede", "kind": "upgrade", "race": "grimtusk",
		"effects": [{"who": "all", "speed_mult": 0.08}], "min_tier": 2,
		"cost": {"food": 180, "gold": 100}, "time": 40, "at": "economy",
		"desc": "Nobody stands in front of a freed horde: all soldiers move 8% faster.",
	},
	# --- Moura Court ---------------------------------------------------------
	"syl_thread": {
		"name": "Golden Thread", "kind": "upgrade", "race": "sylvan",
		"effects": [{"who": "ranged", "range": 2.0, "vision": 4.0}, {"who": "healer", "range": 2.0, "vision": 4.0}],
		"cost": {"gold": 160, "timber": 100}, "time": 40, "at": "economy",
		"desc": "The Mouras spin their sight into gold: archers and choristers +2 range and see further.",
	},
	"syl_mist": {
		"name": "Mist-veiled Ranks", "kind": "upgrade", "race": "sylvan",
		"effects": [{"who": "all", "armor": 2}], "min_tier": 2,
		"cost": {"gold": 180, "stone": 100}, "time": 45, "at": "economy",
		"desc": "The morning mist walks with the Court: all soldiers +2 armor.",
	},
	# --- Granitborn ----------------------------------------------------------
	"kar_walls": {
		"name": "Castro Stonework", "kind": "upgrade", "race": "karak",
		"flags": {"building_hp": 0.20, "tower_dmg": 0.30},
		"cost": {"stone": 200, "gold": 80}, "time": 45, "at": "main",
		"desc": "Walls laid the way the old hillforts were: buildings +20% health, towers strike 30% harder.",
	},
	"kar_ranks": {
		"name": "Stone-skinned Ranks", "kind": "upgrade", "race": "karak",
		"effects": [{"who": "defender", "armor": 4}, {"who": "melee", "armor": 2}], "min_tier": 2,
		"cost": {"stone": 180, "gold": 120}, "time": 45, "at": "economy",
		"desc": "The Lume turns their skin slowly to stone: spear units +4 armor, other foot soldiers +2.",
	},
	# --- Aurean Dominion -----------------------------------------------------
	"sun_drill": {
		"name": "Legion Drill", "kind": "upgrade", "race": "sunspear",
		"effects": [{"who": "melee", "dmg": 2, "armor": 2}, {"who": "defender", "dmg": 2, "armor": 2}],
		"cost": {"gold": 160, "food": 120}, "time": 40, "at": "economy",
		"desc": "A hundred years of drill: melee and phalanx units +2 damage and +2 armor.",
	},
	"sun_scorpions": {
		"name": "Bronze Scorpions", "kind": "upgrade", "race": "sunspear",
		"effects": [{"who": "siege", "dmg": 12, "range": 3.0}], "min_tier": 3,
		"cost": {"gold": 220, "timber": 160}, "time": 50, "at": "economy",
		"desc": "Imperial engineering: siege engines +12 damage and +3 range.",
	},
	# --- Wolfveil Clans ------------------------------------------------------
	"wyl_pack": {
		"name": "Pack Tactics", "kind": "upgrade", "race": "wyldkin",
		"effects": [{"who": "flanker", "dmg": 4}, {"who": "melee", "dmg": 2}],
		"cost": {"food": 150, "gold": 120}, "time": 40, "at": "economy",
		"desc": "They hunt as one: riders and wolves +4 damage, other foot soldiers +2.",
	},
	"wyl_moon": {
		"name": "Moonlit Hunt", "kind": "upgrade", "race": "wyldkin",
		"effects": [{"who": "all", "speed_mult": 0.06, "vision": 3.0}], "min_tier": 2,
		"cost": {"food": 180, "gold": 100}, "time": 40, "at": "economy",
		"desc": "The full moon shows them the way: all soldiers move 6% faster and see further.",
	},
	# --- The Compaña ---------------------------------------------------------
	"hol_hunger": {
		"name": "Grave Hunger", "kind": "upgrade", "race": "hollow",
		"effects": [{"who": "all", "lifesteal": 0.05}], "min_tier": 2,
		"cost": {"gold": 180, "stone": 100}, "time": 45, "at": "economy",
		"desc": "The dead are always hungry: all soldiers heal for 5% more of the damage they deal.",
	},
	"hol_procession": {
		"name": "The Endless Procession", "kind": "upgrade", "race": "hollow",
		"flags": {"train_speed": 0.25},
		"cost": {"food": 160, "gold": 100}, "time": 35, "at": "main",
		"desc": "There is always another candle on the road: units train 25% faster.",
	},
	# --- Careto Host ---------------------------------------------------------
	"fro_fury": {
		"name": "Caretos' Fury", "kind": "upgrade", "race": "frostborn",
		"effects": [{"who": "melee", "dmg": 3, "armor": 1}],
		"cost": {"food": 150, "gold": 120}, "time": 40, "at": "economy",
		"desc": "Masks on, bells ringing, and no mercy: every melee fighter, the Winter Giant included, +3 damage and +1 armor.",
	},
	"fro_bells": {
		"name": "Winter Bells", "kind": "upgrade", "race": "frostborn",
		"effects": [{"who": "all", "hp_mult": 0.10}], "min_tier": 2,
		"cost": {"food": 200, "stone": 100}, "time": 45, "at": "economy",
		"desc": "The cowbells drive winter out of the village and into the enemy: all soldiers +10% health.",
	},
	# --- Capstones: one per people, in the Age of Lume --------------------
	"bar_cap": {"name": "The Bull of Barroso", "kind": "upgrade", "race": "barrosan", "min_tier": 3,
		"effects": [{"who": "all", "hp_mult": 0.12, "dmg": 3}],
		"cost": {"food": 300, "gold": 300, "stone": 150}, "time": 60, "at": "economy",
		"desc": "The village bull walks before the host: all soldiers +12% health and +3 damage."},
	"lio_cap": {"name": "The Seven Mouths Open", "kind": "upgrade", "race": "lioraen", "min_tier": 3,
		"effects": [{"who": "ranged", "dmg": 4, "range": 2.0}, {"who": "all", "hp_mult": 0.08}], "flags": {"bloom_boost": true},
		"cost": {"timber": 300, "gold": 300, "stone": 150}, "time": 60, "at": "economy",
		"desc": "All seven springs flow at once: ranged units +4 damage and +2 range, all soldiers +8% health, and healing groves grow stronger."},
	"vor_cap": {"name": "Furna Remembered", "kind": "upgrade", "race": "vorthak", "min_tier": 3,
		"effects": [{"who": "all", "dmg": 5, "lifesteal": 0.04}],
		"cost": {"gold": 320, "stone": 200}, "time": 60, "at": "economy",
		"desc": "The drowned village is never forgotten: all soldiers +5 damage and heal for 4% of what they deal."},
	"grim_cap": {"name": "No More Chains", "kind": "upgrade", "race": "grimtusk", "min_tier": 3,
		"effects": [{"who": "all", "hp_mult": 0.10, "armor": 2}],
		"cost": {"food": 300, "stone": 250}, "time": 60, "at": "economy",
		"desc": "Every one of them has broken iron: all soldiers +10% health and +2 armor."},
	"syl_cap": {"name": "The Court Assembled", "kind": "upgrade", "race": "sylvan", "min_tier": 3,
		"effects": [{"who": "all", "dmg": 3, "armor": 2, "vision": 3.0}],
		"cost": {"gold": 350, "timber": 200}, "time": 60, "at": "economy",
		"desc": "The whole Moura Court rides to war: all soldiers +3 damage, +2 armor and see further."},
	"kar_cap": {"name": "The Living Castro", "kind": "upgrade", "race": "karak", "min_tier": 3,
		"effects": [{"who": "all", "armor": 3, "hp_mult": 0.08}], "flags": {"building_hp": 0.15, "tower_dmg": 0.25},
		"cost": {"stone": 350, "gold": 200}, "time": 60, "at": "economy",
		"desc": "The hillfort itself marches: all soldiers +3 armor and +8% health, buildings +15% health and towers strike harder."},
	"sun_cap": {"name": "The Seventy-Fifth Triumph", "kind": "upgrade", "race": "sunspear", "min_tier": 3,
		"effects": [{"who": "all", "dmg": 4, "armor": 2}], "flags": {"train_speed": 0.15},
		"cost": {"gold": 380, "food": 250}, "time": 60, "at": "economy",
		"desc": "The empire remembers its last victory: all soldiers +4 damage and +2 armor, and units train 15% faster."},
	"wyl_cap": {"name": "The Seventh Son", "kind": "upgrade", "race": "wyldkin", "min_tier": 3,
		"effects": [{"who": "all", "dmg": 3, "speed_mult": 0.08, "lifesteal": 0.03}],
		"cost": {"food": 320, "gold": 250}, "time": 60, "at": "economy",
		"desc": "The moon's own child leads the pack: all soldiers +3 damage, 8% faster, and heal for 3% of what they deal."},
	"hol_cap": {"name": "The Procession Without End", "kind": "upgrade", "race": "hollow", "min_tier": 3,
		"effects": [{"who": "all", "hp_mult": 0.12, "lifesteal": 0.04}],
		"cost": {"gold": 320, "stone": 200}, "time": 60, "at": "economy",
		"desc": "The dead never stop walking: all soldiers +12% health and heal for 4% of what they deal."},
	"fro_cap": {"name": "Carnival Unending", "kind": "upgrade", "race": "frostborn", "min_tier": 3,
		"effects": [{"who": "all", "dmg": 4, "hp_mult": 0.08}],
		"cost": {"food": 320, "gold": 280}, "time": 60, "at": "economy",
		"desc": "Entrudo never ends for the Careto Host: all soldiers +4 damage and +8% health."},
	}
