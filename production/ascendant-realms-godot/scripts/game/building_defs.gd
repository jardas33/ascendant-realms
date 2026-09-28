class_name BuildingDefs
## Data definitions for every building. Pure data.
## kind: main | house | barracks | arcane | economy | tower | research | landmark
## produces: list of unit ids this building can train
## grants_pop: population capacity added
## tier_unlock: sets the player's tech tier to this when built (main/research)

static func _b(id: String) -> String:
	return "res://assets/environment/buildings/%s.glb" % id

static func get_all() -> Dictionary:
	var defs := {
	# ---------------- BARROSAN ----------------
	"barrosan_clanhold": {
		"race": "barrosan", "name": "Clanhold", "kind": "main", "model": "res://assets/environment/buildings/barrosan_civic_keep_a01.glb",
		"hp": 2200, "armor_class": "fortified", "armor": 10, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 200}, "build_time": 60, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["barrosan_worker"], "drop_off": true, "is_hq": true,
		"desc": "The clan's heart. Trains workers, stores resources, and fortifies nearby structures.",
	},
	"barrosan_clan_croft": {
		"race": "barrosan", "name": "Clan Croft", "kind": "house", "model": _b("barrosan_houses_a03"),
		"hp": 550, "armor_class": "medium", "armor": 2, "footprint": 3.6,
		"cost": {"timber": 55, "stone": 20}, "build_time": 16, "grants_pop": 8,
		"produces": [], "desc": "Highland homestead. Raises your population capacity.",
	},
	"barrosan_war_hall": {
		"race": "barrosan", "name": "War Hall", "kind": "barracks", "model": "res://assets/environment/buildings/barrosan_war_hall_a02.glb",
		"hp": 950, "armor_class": "fortified", "armor": 5, "footprint": 5.0,
		"cost": {"timber": 145, "stone": 50}, "build_time": 28, "grants_pop": 0,
		"produces": ["barrosan_clan_levy", "barrosan_spear_guard", "barrosan_crag_archer",
			"barrosan_outrider", "barrosan_anvil_breaker", "barrosan_ballista"],
		"desc": "Trains the clan's soldiers, archers, elites and siege.",
	},
	"barrosan_iron_forge": {
		"race": "barrosan", "name": "Iron Forge", "kind": "economy", "model": "res://assets/environment/buildings/barrosan_iron_forge_b01_r2.glb",
		"hp": 700, "armor_class": "medium", "armor": 3, "footprint": 4.0,
		"cost": {"timber": 100, "stone": 80}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Smiths weapon and armor upgrades for your whole army.",
	},
	"barrosan_watchtower": {
		"race": "barrosan", "name": "Watchtower", "kind": "tower", "model": "res://assets/environment/visual_convergence/barrosan_settlement/barrosan_guard_tower_lod1.glb",
		"hp": 800, "armor_class": "fortified", "armor": 6, "footprint": 3.2,
		"cost": {"timber": 60, "stone": 80}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 22, "tower_range": 20.0, "tower_cd": 1.1, "tower_type": "pierce", "projectile": "bolt",
		"produces": [], "desc": "Defensive tower that shoots enemies on sight. Barrosan specialty.",
	},

	# ---------------- LIORAEN ----------------
	"lioraen_groveheart": {
		"race": "lioraen", "name": "Groveheart", "kind": "main", "model": _b("lioraen_groveheart_ancient_bough_r1"),
		"hp": 2000, "armor_class": "fortified", "armor": 8, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 200}, "build_time": 60, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["lioraen_worker"], "drop_off": true, "is_hq": true,
		"heal_aura": 6.0, "heal_aura_range": 16.0,
		"desc": "Living heart of the grove. Trains Seedkeepers and heals nearby allies.",
	},
	"lioraen_lifewell": {
		"race": "lioraen", "name": "Lifewell", "kind": "house", "model": _b("lioraen_lifewell"),
		"hp": 500, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 55, "stone": 20}, "build_time": 16, "grants_pop": 8,
		"produces": [], "desc": "Glowing spring that sustains more of your people.",
	},
	"lioraen_thornhall": {
		"race": "lioraen", "name": "Thornhall", "kind": "barracks", "model": _b("lioraen_thornhall"),
		"hp": 850, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 145, "stone": 50}, "build_time": 28, "grants_pop": 0,
		"produces": ["lioraen_bloomdancer", "lioraen_rootwarden_guard", "lioraen_thorn_ranger", "lioraen_windstrider"],
		"desc": "Grown war-grove that trains dancers, wardens, rangers and lancers.",
	},
	"lioraen_lifewell_forge": {
		"race": "lioraen", "name": "Grove Forge", "kind": "economy", "model": _b("lioraen_lifewell"),
		"hp": 650, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 110, "stone": 70}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Cultivates hardened thorn-weapons and bark-armor upgrades.",
	},
	"lioraen_spirit_glade": {
		"race": "lioraen", "name": "Spirit Glade", "kind": "arcane", "model": _b("lioraen_spirit_glade"),
		"hp": 700, "armor_class": "light", "armor": 1, "footprint": 4.2,
		"cost": {"timber": 120, "gold": 80}, "build_time": 34, "grants_pop": 0,
		"produces": ["lioraen_canopy_mender", "lioraen_thornthrower"],
		"desc": "Mystic seed-cradle. Grows healers and living siege.",
	},
	"lioraen_bloom_spire": {
		"race": "lioraen", "name": "Bloom Spire", "kind": "tower", "model": _b("lioraen_bloom_spire"),
		"hp": 700, "armor_class": "medium", "armor": 3, "footprint": 3.2,
		"cost": {"timber": 60, "stone": 80}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 20, "tower_range": 19.0, "tower_cd": 1.0, "tower_type": "pierce", "projectile": "thorn",
		"produces": [], "desc": "Living tower that fires thorn volleys at intruders.",
	},

	# ---------------- VORTHAK ----------------
	"vorthak_nighthold": {
		"race": "vorthak", "name": "Nighthold", "kind": "main", "model": _b("vorthak_nighthold"),
		"command_art": "res://assets/ui/construction_art/vorthak_r1/nighthold.png",
		"hp": 1900, "armor_class": "fortified", "armor": 7, "footprint": 7.0,
		"cost": {"timber": 330, "stone": 190}, "build_time": 56, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["vorthak_worker"], "drop_off": true, "is_hq": true,
		"desc": "Jagged citadel of the Cabal. Trains Bondservants and hoards spoils.",
	},
	"vorthak_ash_forge": {
		"race": "vorthak", "name": "Ash Forge", "kind": "economy", "model": _b("vorthak_ash_forge"),
		"command_art": "res://assets/ui/construction_art/vorthak_r1/ash_forge.png",
		"hp": 620, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 100, "stone": 70}, "build_time": 26, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Black furnace that forges cruel weapon and armor upgrades.",
	},
	"vorthak_thrall_pit": {
		"race": "vorthak", "name": "Thrall Pit", "kind": "house", "model": _b("vorthak_ash_forge"),
		"hp": 480, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 50, "stone": 20}, "build_time": 16, "grants_pop": 8,
		"produces": [], "desc": "Cramped warrens that pack in more thralls.",
	},
	"vorthak_bone_barracks": {
		"race": "vorthak", "name": "Bone Barracks", "kind": "barracks", "model": _b("vorthak_bone_barracks"),
		"command_art": "res://assets/ui/construction_art/vorthak_r1/bone_barracks.png",
		"hp": 800, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 140, "stone": 40}, "build_time": 28, "grants_pop": 0,
		"produces": ["vorthak_ash_thrall", "vorthak_cinder_spitter", "vorthak_gloom_hound", "vorthak_rift_blade"],
		"desc": "Grim hall that raises thralls, spitters, hounds and rift blades.",
	},
	"vorthak_warlock_spire": {
		"race": "vorthak", "name": "Warlock Spire", "kind": "arcane", "model": _b("vorthak_warlock_spire"),
		"command_art": "res://assets/ui/construction_art/vorthak_r1/warlock_spire.png",
		"hp": 680, "armor_class": "light", "armor": 1, "footprint": 4.0,
		"cost": {"timber": 110, "gold": 90}, "build_time": 34, "grants_pop": 0,
		"produces": ["vorthak_veil_warlock", "vorthak_fracture_engine"],
		"desc": "Occult spire that binds warlocks and unstable siege engines.",
	},
	"vorthak_rift_obelisk": {
		"race": "vorthak", "name": "Rift Obelisk", "kind": "tower", "model": _b("vorthak_rift_obelisk"),
		"command_art": "res://assets/ui/construction_art/vorthak_r1/rift_obelisk.png",
		"hp": 650, "armor_class": "medium", "armor": 3, "footprint": 3.0,
		"cost": {"timber": 60, "stone": 80}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 26, "tower_range": 19.0, "tower_cd": 1.3, "tower_type": "arcane", "projectile": "void_bolt",
		"produces": [], "desc": "Dark obelisk that blasts foes with raw Lume energy.",
	},

	# ---------------- GRIMTUSK HORDE ----------------
	"grimtusk_stronghold": {
		"race": "grimtusk", "name": "Ironmaw Pithold", "kind": "main", "model": _b("grimtusk_stronghold"),
		"hp": 2000, "armor_class": "fortified", "armor": 8, "footprint": 7.0,
		"cost": {"timber": 340, "stone": 190}, "build_time": 58, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["grimtusk_peon"], "drop_off": true, "is_hq": true,
		"desc": "The overseers' pithead, taken in the uprising and never given back. Trains freed diggers and holds the Horde together.",
	},
	"grimtusk_warren": {
		"race": "grimtusk", "name": "Freed Barracks", "kind": "house", "model": _b("vorthak_ash_forge"),
		"hp": 480, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 50, "stone": 20}, "build_time": 16, "grants_pop": 9,
		"produces": [], "desc": "The old slave barracks, their doors torn off. Room for more of the freed.",
	},
	"grimtusk_warcamp": {
		"race": "grimtusk", "name": "Revolt Camp", "kind": "barracks", "model": _b("vorthak_bone_barracks"),
		"hp": 820, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 140, "stone": 45}, "build_time": 28, "grants_pop": 0,
		"produces": ["grimtusk_grunt", "grimtusk_bowcrusha", "grimtusk_wolfrider", "grimtusk_berserker", "grimtusk_ogre"],
		"desc": "Where the revolt drills with picks turned into weapons. Musters the Horde's fighters and chain-breakers.",
	},
	"grimtusk_bonesmith": {
		"race": "grimtusk", "name": "Chain Forge", "kind": "economy", "model": _b("vorthak_ash_forge"),
		"hp": 620, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 100, "stone": 70}, "build_time": 26, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Melts down the chains of the Lume-iron mines into blades and plate for the whole Horde.",
	},
	"grimtusk_spike_tower": {
		"race": "grimtusk", "name": "Taken Overseer Tower", "kind": "tower", "model": _b("vorthak_rift_obelisk"),
		"hp": 660, "armor_class": "medium", "armor": 3, "footprint": 3.0,
		"cost": {"timber": 60, "stone": 80}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 22, "tower_range": 19.0, "tower_cd": 1.2, "tower_type": "pierce", "projectile": "bolt",
		"produces": [], "desc": "An overseer's tower turned around. It now fires on anyone who comes back for the Horde.",
	},

	# ---------------- SYLVAN COURT ----------------
	"sylvan_court": {
		"race": "sylvan", "name": "Moura Court", "kind": "main", "model": _b("sylvan_court"),
		"hp": 2000, "armor_class": "fortified", "armor": 8, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 200}, "build_time": 60, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["sylvan_acolyte"], "drop_off": true, "is_hq": true,
		"desc": "The hidden court under the fountain, where the Mouras keep their gold and their bargains. Trains acolytes.",
	},
	"sylvan_haven": {
		"race": "sylvan", "name": "Silver Grotto", "kind": "house", "model": _b("lioraen_lifewell"),
		"hp": 500, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 60, "stone": 20}, "build_time": 18, "grants_pop": 8,
		"produces": [], "desc": "A grotto of silver water and old gold. Shelters more of the Court.",
	},
	"sylvan_bladehall": {
		"race": "sylvan", "name": "Mirror Hall", "kind": "barracks", "model": _b("lioraen_thornhall"),
		"hp": 860, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 150, "stone": 55}, "build_time": 30, "grants_pop": 0,
		"produces": ["sylvan_bladesinger", "sylvan_warden", "sylvan_longbow", "sylvan_windrunner", "sylvan_silver_colossus"],
		"desc": "A hall of still mirrors where the Court's duellists, wardens, archers and fountain riders are enchanted for war.",
	},
	"sylvan_loreforge": {
		"race": "sylvan", "name": "Coal-Gold Forge", "kind": "economy", "model": _b("lioraen_lifewell"),
		"hp": 650, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 110, "stone": 70}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Where coal is spun into gold, as in the tales. Pays for the Court's weapon and armour upgrades.",
	},
	"sylvan_star_spire": {
		"race": "sylvan", "name": "Frozen Fountain", "kind": "tower", "model": _b("lioraen_bloom_spire"),
		"hp": 710, "armor_class": "medium", "armor": 3, "footprint": 3.2,
		"cost": {"timber": 90, "stone": 60}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 22, "tower_range": 21.0, "tower_cd": 1.0, "tower_type": "pierce", "projectile": "thorn",
		"produces": [], "desc": "A fountain frozen mid-leap that looses shards of cold light at intruders, from further than any bow.",
	},
	"sylvan_arcanum": {
		"race": "sylvan", "name": "Bargain Hall", "kind": "arcane", "model": _b("lioraen_spirit_glade"),
		"hp": 700, "armor_class": "light", "armor": 1, "footprint": 4.2,
		"cost": {"timber": 120, "gold": 80}, "build_time": 34, "grants_pop": 0,
		"produces": ["sylvan_lightweaver"],
		"desc": "Every Moura's gift has a price. Here the Court's healers learn what to ask for in return.",
	},

	# ---------------- KARAK DWARVES ----------------
	"karak_hold": {
		"race": "karak", "name": "Castro Hold", "kind": "main", "model": _b("karak_hold"),
		"hp": 2400, "armor_class": "fortified", "armor": 11, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 220}, "build_time": 65, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["karak_miner"], "drop_off": true, "is_hq": true,
		"desc": "A walled castro on the hilltop, older than the Dominion and harder than it. Trains quarrymen and anchors the hillfort.",
	},
	"karak_longhouse": {
		"race": "karak", "name": "Roundhouse", "kind": "house", "model": _b("barrosan_clan_croft"),
		"hp": 560, "armor_class": "medium", "armor": 2, "footprint": 3.6,
		"cost": {"timber": 55, "stone": 20}, "build_time": 16, "grants_pop": 8,
		"produces": [], "desc": "A round stone house of the castro, roofed in thatch. Houses more of the Granitborn.",
	},
	"karak_warforge": {
		"race": "karak", "name": "Castro Forge", "kind": "barracks", "model": _b("barrosan_war_hall"),
		"hp": 980, "armor_class": "fortified", "armor": 6, "footprint": 5.0,
		"cost": {"timber": 145, "stone": 50}, "build_time": 28, "grants_pop": 0,
		"produces": ["karak_warrior", "karak_ironbreaker", "karak_quarreler", "karak_castro_rider", "karak_hammerer", "karak_cannon"],
		"desc": "The hillfort's forge, where the Granitborn's warriors, ironbreakers, quarrelers, riders, hammerers and mortars are readied.",
	},
	"karak_anvil": {
		"race": "karak", "name": "Ledger Stone", "kind": "economy", "model": _b("barrosan_iron_forge"),
		"hp": 720, "armor_class": "medium", "armor": 3, "footprint": 4.0,
		"cost": {"timber": 100, "stone": 90}, "build_time": 30, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "A carved stone that remembers every oath and debt. The Granitborn's upgrades are cut into it.",
	},
	"karak_gun_tower": {
		"race": "karak", "name": "Castro Rampart", "kind": "tower", "model": _b("barrosan_watchtower"),
		"hp": 850, "armor_class": "fortified", "armor": 7, "footprint": 3.2,
		"cost": {"timber": 60, "stone": 80}, "build_time": 26, "grants_pop": 0,
		"tower_dmg": 24, "tower_range": 20.0, "tower_cd": 1.2, "tower_type": "pierce", "projectile": "bolt",
		"produces": [], "desc": "A thick stretch of castro wall with a crossbow platform. Reliable, durable, lethal.",
	},

	# ---------------- SUNSPEAR DOMINION ----------------
	"sunspear_palace": {
		"race": "sunspear", "name": "Regent's Palace", "kind": "main", "model": _b("sunspear_palace"),
		"hp": 2200, "armor_class": "fortified", "armor": 10, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 200}, "build_time": 60, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["sunspear_laborer"], "drop_off": true, "is_hq": true,
		"desc": "The regent's seat in the conquered north, bronze and whitewash on highland stone. Trains labourers.",
	},
	"sunspear_dwelling": {
		"race": "sunspear", "name": "Settler Housing", "kind": "house", "model": _b("barrosan_clan_croft"),
		"hp": 550, "armor_class": "medium", "armor": 2, "footprint": 3.6,
		"cost": {"timber": 55, "stone": 20}, "build_time": 16, "grants_pop": 8,
		"produces": [], "desc": "Tidy settler housing the Dominion builds wherever it means to stay. Supports more of its people.",
	},
	"sunspear_legion_hall": {
		"race": "sunspear", "name": "Legion Hall", "kind": "barracks", "model": _b("barrosan_war_hall"),
		"hp": 950, "armor_class": "fortified", "armor": 5, "footprint": 5.0,
		"cost": {"timber": 145, "stone": 50}, "build_time": 28, "grants_pop": 0,
		"produces": ["sunspear_legion", "sunspear_phalanx", "sunspear_bowman", "sunspear_charioteer", "sunspear_scorpion"],
		"desc": "The Dominion's drill hall: legionaries, phalanx, archers and charioteers train to its bronze trumpets.",
	},
	"sunspear_bazaar": {
		"race": "sunspear", "name": "Dominion Treasury", "kind": "economy", "model": _b("barrosan_iron_forge"),
		"hp": 700, "armor_class": "medium", "armor": 3, "footprint": 4.0,
		"cost": {"timber": 100, "stone": 80}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "The treasury that taxes the valleys it floods. Pays for weapon and armour upgrades for the whole army.",
	},
	"sunspear_obelisk_tower": {
		"race": "sunspear", "name": "Survey Obelisk", "kind": "tower", "model": _b("barrosan_watchtower"),
		"hp": 800, "armor_class": "fortified", "armor": 6, "footprint": 3.2,
		"cost": {"timber": 60, "stone": 80}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 24, "tower_range": 20.0, "tower_cd": 1.1, "tower_type": "arcane", "projectile": "bolt",
		"produces": [], "desc": "A surveyor's obelisk marking land for the reservoirs. It turns the sun on anyone who pulls up the stakes.",
	},
	"sunspear_temple": {
		"race": "sunspear", "name": "Temple of the Still Water", "kind": "arcane", "model": _b("barrosan_iron_forge"),
		"hp": 720, "armor_class": "light", "armor": 2, "footprint": 4.2,
		"cost": {"timber": 120, "gold": 80}, "build_time": 34, "grants_pop": 0,
		"produces": ["sunspear_sunpriest"],
		"desc": "A cold temple over a drowned church. Trains the priests who mend the Dominion's wounded.",
	},

	# ---------------- WYLDKIN ----------------
	"wyldkin_denhold": {
		"race": "wyldkin", "name": "Wolfveil Den", "kind": "main", "model": _b("wyldkin_denhold"),
		"hp": 1950, "armor_class": "fortified", "armor": 8, "footprint": 7.0,
		"cost": {"timber": 340, "stone": 190}, "build_time": 58, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["wyldkin_forager"], "drop_off": true, "is_hq": true,
		"desc": "A den under the old oak where the seventh sons meet on full-moon nights. Trains foragers and marks the pack's ground.",
	},
	"wyldkin_burrow": {
		"race": "wyldkin", "name": "Moon Burrow", "kind": "house", "model": _b("lioraen_lifewell"),
		"hp": 500, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 60, "stone": 20}, "build_time": 18, "grants_pop": 8,
		"produces": [], "desc": "Hollows under the roots where the pack sleeps by day. Shelters more of the Wolfveil.",
	},
	"wyldkin_hunt_lodge": {
		"race": "wyldkin", "name": "Hunt Lodge", "kind": "barracks", "model": _b("lioraen_thornhall"),
		"hp": 850, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 150, "stone": 50}, "build_time": 30, "grants_pop": 0,
		"produces": ["wyldkin_clawwarrior", "wyldkin_packguard", "wyldkin_spinethrower", "wyldkin_direwolf", "wyldkin_moon_bear"],
		"desc": "A lodge of pelts and claw-marks where the pack's moonclaws, guardians, trap-breakers, direwolves and moon bears gather.",
	},
	"wyldkin_totem_forge": {
		"race": "wyldkin", "name": "Trap-Breaker Forge", "kind": "economy", "model": _b("lioraen_lifewell"),
		"hp": 640, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 110, "stone": 70}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Takes apart the wolf-traps of the fojos and forges them into the pack's claws and hides.",
	},
	"wyldkin_spirit_totem": {
		"race": "wyldkin", "name": "Howling Stone", "kind": "tower", "model": _b("lioraen_bloom_spire"),
		"hp": 700, "armor_class": "medium", "armor": 3, "footprint": 3.2,
		"cost": {"timber": 90, "stone": 60}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 20, "tower_range": 19.0, "tower_cd": 1.0, "tower_type": "pierce", "projectile": "thorn",
		"produces": [], "desc": "A standing stone the pack howls from. It hurls barbed quills at anyone who crosses into wolf country.",
	},
	"wyldkin_shaman_grove": {
		"race": "wyldkin", "name": "Moon Grove", "kind": "arcane", "model": _b("lioraen_spirit_glade"),
		"hp": 690, "armor_class": "light", "armor": 1, "footprint": 4.2,
		"cost": {"timber": 120, "gold": 80}, "build_time": 34, "grants_pop": 0,
		"produces": ["wyldkin_shaman"],
		"desc": "A moonlit grove where the pack's healers learn to close wounds before the change comes.",
	},

	# ---------------- HOLLOW LEGION ----------------
	"hollow_necropolis": {
		"race": "hollow", "name": "Candle Chapel", "kind": "main", "model": _b("hollow_necropolis"),
		"hp": 1950, "armor_class": "fortified", "armor": 8, "footprint": 7.0,
		"cost": {"timber": 330, "stone": 185}, "build_time": 56, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["hollow_gravedigger"], "drop_off": true, "is_hq": true,
		"desc": "A roadside chapel where the Compaña lights its candles. Raises gravediggers and leads the procession.",
	},
	"hollow_crypt": {
		"race": "hollow", "name": "Wayside Grave", "kind": "house", "model": _b("vorthak_ash_forge"),
		"hp": 480, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 50, "stone": 20}, "build_time": 16, "grants_pop": 9,
		"produces": [], "desc": "A grave at the crossroads, left open. Makes room for more of the procession.",
	},
	"hollow_ossuary": {
		"race": "hollow", "name": "Ossuary", "kind": "barracks", "model": _b("vorthak_bone_barracks"),
		"hp": 800, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 140, "stone": 40}, "build_time": 28, "grants_pop": 0,
		"produces": ["hollow_skeleton", "hollow_boneguard", "hollow_bonearcher", "hollow_wraith"],
		"desc": "Where the procession gathers its bones: the forgotten dead, procession guards, grave archers and drowned wraiths join here.",
	},
	"hollow_darkforge": {
		"race": "hollow", "name": "Coffin-Wood Forge", "kind": "economy", "model": _b("vorthak_ash_forge"),
		"hp": 620, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 100, "stone": 70}, "build_time": 26, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Coffin-wood and candle-iron worked into the procession's weapons and bone armour.",
	},
	"hollow_bone_spire": {
		"race": "hollow", "name": "Procession Cross", "kind": "arcane", "model": _b("vorthak_warlock_spire"),
		"hp": 680, "armor_class": "light", "armor": 1, "footprint": 4.0,
		"cost": {"timber": 110, "gold": 90}, "build_time": 34, "grants_pop": 0,
		"produces": ["hollow_necromancer"],
		"desc": "The cross the Compaña carries at its head. Trains the procession's necromancers.",
	},
	"hollow_curse_obelisk": {
		"race": "hollow", "name": "Forgotten Cairn", "kind": "tower", "model": _b("vorthak_rift_obelisk"),
		"hp": 650, "armor_class": "medium", "armor": 3, "footprint": 3.0,
		"cost": {"timber": 60, "stone": 80}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 26, "tower_range": 19.0, "tower_cd": 1.3, "tower_type": "arcane", "projectile": "void_bolt",
		"produces": [], "desc": "A pile of stones where someone died on the road. It drains the life of anyone who lingers.",
	},

	# ---------------- FROSTBORN JARLS ----------------
	"frostborn_mead_hall": {
		"race": "frostborn", "name": "Careto Hall", "kind": "main", "model": _b("frostborn_mead_hall"),
		"hp": 2200, "armor_class": "fortified", "armor": 10, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 200}, "build_time": 60, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["frostborn_thrall"], "drop_off": true, "is_hq": true,
		"desc": "The old hall of the Larouco villages, hung with masks and bells. Pages learn the steps here, and the winter's spoils are counted.",
	},
	"frostborn_longhouse": {
		"race": "frostborn", "name": "Mask House", "kind": "house", "model": _b("barrosan_clan_croft"),
		"hp": 560, "armor_class": "medium", "armor": 2, "footprint": 3.6,
		"cost": {"timber": 55, "stone": 20}, "build_time": 16, "grants_pop": 8,
		"produces": [], "desc": "A stone house where the masks are kept between Entrudos. Shelters more of the Host through the long highland winter.",
	},
	"frostborn_war_hall": {
		"race": "frostborn", "name": "Entrudo Hall", "kind": "barracks", "model": _b("barrosan_war_hall"),
		"hp": 960, "armor_class": "fortified", "armor": 5, "footprint": 5.0,
		"cost": {"timber": 145, "stone": 50}, "build_time": 28, "grants_pop": 0,
		"produces": ["frostborn_reaver", "frostborn_shieldmaiden", "frostborn_hunter", "frostborn_berserker", "frostborn_jotun"],
		"desc": "Where the Entrudo is rehearsed: runners, shields, snow hunters, wild caretos and the winter giants are readied for the chase.",
	},
	"frostborn_runeforge": {
		"race": "frostborn", "name": "Bell Forge", "kind": "economy", "model": _b("barrosan_iron_forge"),
		"hp": 710, "armor_class": "medium", "armor": 3, "footprint": 4.0,
		"cost": {"timber": 100, "stone": 80}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Casts the iron cowbells of the dance and tempers the Host's blades and shields.",
	},
	"frostborn_watchtower": {
		"race": "frostborn", "name": "Larouco Lookout", "kind": "tower", "model": _b("barrosan_watchtower"),
		"hp": 820, "armor_class": "fortified", "armor": 6, "footprint": 3.2,
		"cost": {"timber": 60, "stone": 80}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 22, "tower_range": 20.0, "tower_cd": 1.1, "tower_type": "pierce", "projectile": "bolt",
		"produces": [], "desc": "A lookout on the Larouco crags that fires heavy bolts at anything approaching the Careto Hall.",
	},
	}
	_add_outposts(defs)
	return defs

## Vein outposts (docs/claude/RESOURCE_DESIGN.md): every faction can raise one
## on a vein between the bases. Workers sent inside gather in safety; the
## outpost upgrades twice (more slots, more output, a watch-fire at the top).
const OUTPOST_NAMES := {
	"barrosan": "Clan Mine", "lioraen": "Spring Terrace", "vorthak": "Rift Pit", "grimtusk": "Freed Mine",
	"sylvan": "Moura Grotto", "karak": "Castro Quarry-Works", "sunspear": "Dominion Works", "wyldkin": "Hunters' Camp",
	"hollow": "Candle Diggings", "frostborn": "Careto Camp",
}

static func _add_outposts(defs: Dictionary) -> void:
	for race in OUTPOST_NAMES:
		var model := ""
		for id in defs:
			if String(defs[id].get("race", "")) == race and String(defs[id].get("kind", "")) == "tower":
				model = String(defs[id].get("model", ""))
		defs["%s_outpost" % race] = {
			"race": race, "name": String(OUTPOST_NAMES[race]), "kind": "outpost", "model": model,
			"hp": 480, "armor_class": "fortified", "armor": 5, "footprint": 2.6,
			"cost": {"timber": 80, "stone": 40}, "build_time": 16, "grants_pop": 0,
			"produces": [], "vein_outpost": true,
			"desc": "Raised on a vein between the bases. Send workers inside: they gather safely, with no walking. Expand it for more workers, more output and, at the top, a watch-fire.",
		}
