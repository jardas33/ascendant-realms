class_name BuildingDefs
## Data definitions for every building. Pure data.
## kind: main | house | barracks | arcane | economy | tower | research | landmark
## produces: list of unit ids this building can train
## grants_pop: population capacity added
## tier_unlock: sets the player's tech tier to this when built (main/research)

static func _b(id: String) -> String:
	return "res://assets/environment/buildings/%s.glb" % id

static func get_all() -> Dictionary:
	return {
	# ---------------- BARROSAN ----------------
	"barrosan_clanhold": {
		"race": "barrosan", "name": "Clanhold", "kind": "main", "model": _b("barrosan_clanhold"),
		"visual_scale": 1.18,
		"hp": 2200, "armor_class": "fortified", "armor": 10, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 200}, "build_time": 60, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["barrosan_worker"], "drop_off": true, "is_hq": true,
		"desc": "The clan's heart. Trains workers, stores resources, and fortifies nearby structures.",
	},
	"barrosan_clan_croft": {
		"race": "barrosan", "name": "Clan Croft", "kind": "house", "model": _b("barrosan_clan_croft"),
		"visual_scale": 0.90,
		"hp": 550, "armor_class": "medium", "armor": 2, "footprint": 3.6,
		"cost": {"timber": 60, "stone": 20}, "build_time": 18, "grants_pop": 8,
		"produces": [], "desc": "Highland homestead. Raises your population capacity.",
	},
	"barrosan_war_hall": {
		"race": "barrosan", "name": "War Hall", "kind": "barracks", "model": _b("barrosan_war_hall"),
		"visual_scale": 1.00,
		"hp": 950, "armor_class": "fortified", "armor": 5, "footprint": 5.0,
		"cost": {"timber": 150, "stone": 60}, "build_time": 30, "grants_pop": 0,
		"produces": ["barrosan_clan_levy", "barrosan_spear_guard", "barrosan_crag_archer",
			"barrosan_outrider", "barrosan_anvil_breaker", "barrosan_ballista"],
		"desc": "Trains the clan's soldiers, archers, elites and siege.",
	},
	"barrosan_iron_forge": {
		"race": "barrosan", "name": "Iron Forge", "kind": "economy", "model": _b("barrosan_iron_forge"),
		"hp": 700, "armor_class": "medium", "armor": 3, "footprint": 4.0,
		"cost": {"timber": 100, "stone": 80}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Smiths weapon and armor upgrades for your whole army.",
	},
	"barrosan_watchtower": {
		"race": "barrosan", "name": "Watchtower", "kind": "tower", "model": _b("barrosan_watchtower"),
		"hp": 800, "armor_class": "fortified", "armor": 6, "footprint": 3.2,
		"cost": {"timber": 40, "stone": 100}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 22, "tower_range": 20.0, "tower_cd": 1.1, "tower_type": "pierce", "projectile": "bolt",
		"produces": [], "desc": "Defensive tower that shoots enemies on sight. Barrosan specialty.",
	},

	# ---------------- LIORAEN ----------------
	"lioraen_groveheart": {
		"race": "lioraen", "name": "Groveheart", "kind": "main", "model": _b("lioraen_groveheart"),
		"hp": 2000, "armor_class": "fortified", "armor": 8, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 200}, "build_time": 60, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["lioraen_worker"], "drop_off": true, "is_hq": true,
		"heal_aura": 6.0, "heal_aura_range": 16.0,
		"desc": "Living heart of the grove. Trains Seedkeepers and heals nearby allies.",
	},
	"lioraen_lifewell": {
		"race": "lioraen", "name": "Lifewell", "kind": "house", "model": _b("lioraen_lifewell"),
		"hp": 500, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 60, "stone": 20}, "build_time": 18, "grants_pop": 8,
		"produces": [], "desc": "Glowing spring that sustains more of your people.",
	},
	"lioraen_thornhall": {
		"race": "lioraen", "name": "Thornhall", "kind": "barracks", "model": _b("lioraen_thornhall"),
		"hp": 850, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 150, "stone": 50}, "build_time": 30, "grants_pop": 0,
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
		"cost": {"timber": 90, "stone": 60}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 20, "tower_range": 19.0, "tower_cd": 1.0, "tower_type": "pierce", "projectile": "thorn",
		"produces": [], "desc": "Living tower that fires thorn volleys at intruders.",
	},

	# ---------------- VORTHAK ----------------
	"vorthak_nighthold": {
		"race": "vorthak", "name": "Nighthold", "kind": "main", "model": _b("vorthak_nighthold"),
		"hp": 1900, "armor_class": "fortified", "armor": 7, "footprint": 7.0,
		"cost": {"timber": 330, "stone": 190}, "build_time": 56, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["vorthak_worker"], "drop_off": true, "is_hq": true,
		"desc": "Jagged citadel of the Cabal. Trains Bondservants and hoards spoils.",
	},
	"vorthak_ash_forge": {
		"race": "vorthak", "name": "Ash Forge", "kind": "economy", "model": _b("vorthak_ash_forge"),
		"hp": 620, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 100, "stone": 70}, "build_time": 26, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Black furnace that forges cruel weapon and armor upgrades.",
	},
	"vorthak_thrall_pit": {
		"race": "vorthak", "name": "Thrall Pit", "kind": "house", "model": _b("vorthak_ash_forge"),
		"hp": 480, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 50, "stone": 20}, "build_time": 16, "grants_pop": 9,
		"produces": [], "desc": "Cramped warrens that pack in more thralls.",
	},
	"vorthak_bone_barracks": {
		"race": "vorthak", "name": "Bone Barracks", "kind": "barracks", "model": _b("vorthak_bone_barracks"),
		"hp": 800, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 140, "stone": 40}, "build_time": 28, "grants_pop": 0,
		"produces": ["vorthak_ash_thrall", "vorthak_cinder_spitter", "vorthak_gloom_hound", "vorthak_rift_blade"],
		"desc": "Grim hall that raises thralls, spitters, hounds and rift blades.",
	},
	"vorthak_warlock_spire": {
		"race": "vorthak", "name": "Warlock Spire", "kind": "arcane", "model": _b("vorthak_warlock_spire"),
		"hp": 680, "armor_class": "light", "armor": 1, "footprint": 4.0,
		"cost": {"timber": 110, "gold": 90}, "build_time": 34, "grants_pop": 0,
		"produces": ["vorthak_veil_warlock", "vorthak_fracture_engine"],
		"desc": "Occult spire that binds warlocks and unstable siege engines.",
	},
	"vorthak_rift_obelisk": {
		"race": "vorthak", "name": "Rift Obelisk", "kind": "tower", "model": _b("vorthak_rift_obelisk"),
		"hp": 650, "armor_class": "medium", "armor": 3, "footprint": 3.0,
		"cost": {"timber": 60, "stone": 80}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 26, "tower_range": 19.0, "tower_cd": 1.3, "tower_type": "arcane", "projectile": "void_bolt",
		"produces": [], "desc": "Dark obelisk that blasts foes with raw Lume energy.",
	},

	# ---------------- GRIMTUSK HORDE ----------------
	"grimtusk_stronghold": {
		"race": "grimtusk", "name": "Grimtusk Stronghold", "kind": "main", "model": _b("grimtusk_stronghold"),
		"hp": 2000, "armor_class": "fortified", "armor": 8, "footprint": 7.0,
		"cost": {"timber": 340, "stone": 190}, "build_time": 58, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["grimtusk_peon"], "drop_off": true, "is_hq": true,
		"desc": "Crude but massive orc fortress. Trains peons and serves as the Horde's beating heart.",
	},
	"grimtusk_warren": {
		"race": "grimtusk", "name": "Grimtusk Warren", "kind": "house", "model": _b("vorthak_ash_forge"),
		"hp": 480, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 50, "stone": 20}, "build_time": 16, "grants_pop": 9,
		"produces": [], "desc": "Packed mud warrens that squeeze in even more greenskins.",
	},
	"grimtusk_warcamp": {
		"race": "grimtusk", "name": "Warcamp", "kind": "barracks", "model": _b("vorthak_bone_barracks"),
		"hp": 820, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 140, "stone": 45}, "build_time": 28, "grants_pop": 0,
		"produces": ["grimtusk_grunt", "grimtusk_bowcrusha", "grimtusk_wolfrider", "grimtusk_berserker", "grimtusk_ogre"],
		"desc": "Smoke-wreathed war camp where the Horde's warriors are mustered and sharpened.",
	},
	"grimtusk_bonesmith": {
		"race": "grimtusk", "name": "Bonesmith", "kind": "economy", "model": _b("vorthak_ash_forge"),
		"hp": 620, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 100, "stone": 70}, "build_time": 26, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Brutal orc smithy that hammers bones and scrap iron into cruder-but-deadlier weapons and armor.",
	},
	"grimtusk_spike_tower": {
		"race": "grimtusk", "name": "Spike Tower", "kind": "tower", "model": _b("vorthak_rift_obelisk"),
		"hp": 660, "armor_class": "medium", "armor": 3, "footprint": 3.0,
		"cost": {"timber": 60, "stone": 80}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 22, "tower_range": 19.0, "tower_cd": 1.2, "tower_type": "pierce", "projectile": "bolt",
		"produces": [], "desc": "Cruelly spiked orcish tower that fires bone bolts at anything that trespasses.",
	},

	# ---------------- SYLVAN COURT ----------------
	"sylvan_court": {
		"race": "sylvan", "name": "Sylvan Court", "kind": "main", "model": _b("sylvan_court"),
		"hp": 2000, "armor_class": "fortified", "armor": 8, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 200}, "build_time": 60, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["sylvan_acolyte"], "drop_off": true, "is_hq": true,
		"desc": "Ancient court-tree of the elves. Trains acolytes and radiates a quiet, silver light of power.",
	},
	"sylvan_haven": {
		"race": "sylvan", "name": "Sylvan Haven", "kind": "house", "model": _b("lioraen_lifewell"),
		"hp": 500, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 60, "stone": 20}, "build_time": 18, "grants_pop": 8,
		"produces": [], "desc": "Shimmering elven dwelling that shelters more of your court's people.",
	},
	"sylvan_bladehall": {
		"race": "sylvan", "name": "Bladehall", "kind": "barracks", "model": _b("lioraen_thornhall"),
		"hp": 860, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 150, "stone": 55}, "build_time": 30, "grants_pop": 0,
		"produces": ["sylvan_bladesinger", "sylvan_warden", "sylvan_longbow", "sylvan_windrunner"],
		"desc": "Gleaming war-hall where the Court's singers, wardens, archers and lancers are honed.",
	},
	"sylvan_loreforge": {
		"race": "sylvan", "name": "Loreforge", "kind": "economy", "model": _b("lioraen_lifewell"),
		"hp": 650, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 110, "stone": 70}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Elven lore-repository that refines starwood weapons and enchants armor with ancient sigils.",
	},
	"sylvan_star_spire": {
		"race": "sylvan", "name": "Star Spire", "kind": "tower", "model": _b("lioraen_bloom_spire"),
		"hp": 710, "armor_class": "medium", "armor": 3, "footprint": 3.2,
		"cost": {"timber": 90, "stone": 60}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 22, "tower_range": 21.0, "tower_cd": 1.0, "tower_type": "pierce", "projectile": "thorn",
		"produces": [], "desc": "Crystal spire that fires concentrated starlight arrows with superior range.",
	},
	"sylvan_arcanum": {
		"race": "sylvan", "name": "Arcanum", "kind": "arcane", "model": _b("lioraen_spirit_glade"),
		"hp": 700, "armor_class": "light", "armor": 1, "footprint": 4.2,
		"cost": {"timber": 120, "gold": 80}, "build_time": 34, "grants_pop": 0,
		"produces": ["sylvan_lightweaver"],
		"desc": "Sanctum of elven light-magic that trains the Court's healers.",
	},

	# ---------------- KARAK DWARVES ----------------
	"karak_hold": {
		"race": "karak", "name": "Karak Hold", "kind": "main", "model": _b("karak_hold"),
		"hp": 2400, "armor_class": "fortified", "armor": 11, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 220}, "build_time": 65, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["karak_miner"], "drop_off": true, "is_hq": true,
		"desc": "Impregnable dwarven fortress carved from the living mountain. Trains miners and anchors the Hold.",
	},
	"karak_longhouse": {
		"race": "karak", "name": "Karak Longhouse", "kind": "house", "model": _b("barrosan_clan_croft"),
		"hp": 560, "armor_class": "medium", "armor": 2, "footprint": 3.6,
		"cost": {"timber": 60, "stone": 25}, "build_time": 18, "grants_pop": 8,
		"produces": [], "desc": "Sturdy stone longhouse that houses more of your dwarven kin.",
	},
	"karak_warforge": {
		"race": "karak", "name": "Warforge", "kind": "barracks", "model": _b("barrosan_war_hall"),
		"hp": 980, "armor_class": "fortified", "armor": 6, "footprint": 5.0,
		"cost": {"timber": 150, "stone": 70}, "build_time": 32, "grants_pop": 0,
		"produces": ["karak_warrior", "karak_ironbreaker", "karak_quarreler", "karak_hammerer", "karak_cannon"],
		"desc": "Deep forge-hall that produces Karak's warriors, ironbreakers, quarrelers, hammerers, and cannon.",
	},
	"karak_anvil": {
		"race": "karak", "name": "Rune Anvil", "kind": "economy", "model": _b("barrosan_iron_forge"),
		"hp": 720, "armor_class": "medium", "armor": 3, "footprint": 4.0,
		"cost": {"timber": 100, "stone": 90}, "build_time": 30, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Ancient rune-carved anvil that inscribes weapon and armor upgrades into the army's very essence.",
	},
	"karak_gun_tower": {
		"race": "karak", "name": "Gun Tower", "kind": "tower", "model": _b("barrosan_watchtower"),
		"hp": 850, "armor_class": "fortified", "armor": 7, "footprint": 3.2,
		"cost": {"timber": 45, "stone": 110}, "build_time": 26, "grants_pop": 0,
		"tower_dmg": 24, "tower_range": 20.0, "tower_cd": 1.2, "tower_type": "pierce", "projectile": "bolt",
		"produces": [], "desc": "Stubby stone tower fitted with a repeating crossbow. Reliable, durable, lethal.",
	},

	# ---------------- SUNSPEAR DOMINION ----------------
	"sunspear_palace": {
		"race": "sunspear", "name": "Sunspear Palace", "kind": "main", "model": _b("sunspear_palace"),
		"hp": 2200, "armor_class": "fortified", "armor": 10, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 200}, "build_time": 60, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["sunspear_laborer"], "drop_off": true, "is_hq": true,
		"desc": "Sun-baked palace of the Dominion. Trains laborers and serves as the realm's golden seat of power.",
	},
	"sunspear_dwelling": {
		"race": "sunspear", "name": "Sunspear Dwelling", "kind": "house", "model": _b("barrosan_clan_croft"),
		"hp": 550, "armor_class": "medium", "armor": 2, "footprint": 3.6,
		"cost": {"timber": 60, "stone": 20}, "build_time": 18, "grants_pop": 8,
		"produces": [], "desc": "Whitewashed desert dwelling that supports more of the Dominion's growing population.",
	},
	"sunspear_legion_hall": {
		"race": "sunspear", "name": "Legion Hall", "kind": "barracks", "model": _b("barrosan_war_hall"),
		"hp": 950, "armor_class": "fortified", "armor": 5, "footprint": 5.0,
		"cost": {"timber": 150, "stone": 60}, "build_time": 30, "grants_pop": 0,
		"produces": ["sunspear_legion", "sunspear_phalanx", "sunspear_bowman", "sunspear_charioteer"],
		"desc": "Grand martial hall where the Dominion's legionaries, phalanx, archers and charioteers train.",
	},
	"sunspear_bazaar": {
		"race": "sunspear", "name": "Desert Bazaar", "kind": "economy", "model": _b("barrosan_iron_forge"),
		"hp": 700, "armor_class": "medium", "armor": 3, "footprint": 4.0,
		"cost": {"timber": 100, "stone": 80}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Bustling desert market that finances weapon and armor improvements for the entire army.",
	},
	"sunspear_obelisk_tower": {
		"race": "sunspear", "name": "Sun Obelisk", "kind": "tower", "model": _b("barrosan_watchtower"),
		"hp": 800, "armor_class": "fortified", "armor": 6, "footprint": 3.2,
		"cost": {"timber": 40, "stone": 100}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 24, "tower_range": 20.0, "tower_cd": 1.1, "tower_type": "arcane", "projectile": "bolt",
		"produces": [], "desc": "Tall golden obelisk that channels solar fire against intruders.",
	},
	"sunspear_temple": {
		"race": "sunspear", "name": "Sun Temple", "kind": "arcane", "model": _b("barrosan_iron_forge"),
		"hp": 720, "armor_class": "light", "armor": 2, "footprint": 4.2,
		"cost": {"timber": 120, "gold": 80}, "build_time": 34, "grants_pop": 0,
		"produces": ["sunspear_sunpriest"],
		"desc": "Radiant temple to the desert sun-god. Trains priests who mend the Dominion's wounds.",
	},

	# ---------------- WYLDKIN ----------------
	"wyldkin_denhold": {
		"race": "wyldkin", "name": "Wyldkin Denhold", "kind": "main", "model": _b("wyldkin_denhold"),
		"hp": 1950, "armor_class": "fortified", "armor": 8, "footprint": 7.0,
		"cost": {"timber": 340, "stone": 190}, "build_time": 58, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["wyldkin_forager"], "drop_off": true, "is_hq": true,
		"desc": "Great den-tree that serves as the pack's hub. Trains foragers and anchors pack territory.",
	},
	"wyldkin_burrow": {
		"race": "wyldkin", "name": "Wyldkin Burrow", "kind": "house", "model": _b("lioraen_lifewell"),
		"hp": 500, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 60, "stone": 20}, "build_time": 18, "grants_pop": 8,
		"produces": [], "desc": "Earthy burrow complex that shelters more of your growing pack.",
	},
	"wyldkin_hunt_lodge": {
		"race": "wyldkin", "name": "Hunt Lodge", "kind": "barracks", "model": _b("lioraen_thornhall"),
		"hp": 850, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 150, "stone": 50}, "build_time": 30, "grants_pop": 0,
		"produces": ["wyldkin_clawwarrior", "wyldkin_packguard", "wyldkin_spinethrower", "wyldkin_direwolf"],
		"desc": "Claw-marked lodge where the pack's warriors, guards, spinethrowers and direwolves gather.",
	},
	"wyldkin_totem_forge": {
		"race": "wyldkin", "name": "Totem Forge", "kind": "economy", "model": _b("lioraen_lifewell"),
		"hp": 640, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 110, "stone": 70}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Totem-carvers who inscribe beast-spirit blessings into claws, hides and weapons.",
	},
	"wyldkin_spirit_totem": {
		"race": "wyldkin", "name": "Spirit Totem", "kind": "tower", "model": _b("lioraen_bloom_spire"),
		"hp": 700, "armor_class": "medium", "armor": 3, "footprint": 3.2,
		"cost": {"timber": 90, "stone": 60}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 20, "tower_range": 19.0, "tower_cd": 1.0, "tower_type": "pierce", "projectile": "thorn",
		"produces": [], "desc": "Carved spirit totem that flings barbed quills at enemies who enter pack territory.",
	},
	"wyldkin_shaman_grove": {
		"race": "wyldkin", "name": "Shaman Grove", "kind": "arcane", "model": _b("lioraen_spirit_glade"),
		"hp": 690, "armor_class": "light", "armor": 1, "footprint": 4.2,
		"cost": {"timber": 120, "gold": 80}, "build_time": 34, "grants_pop": 0,
		"produces": ["wyldkin_shaman"],
		"desc": "Sacred grove where the pack's shamans commune with beast-spirits and learn to mend flesh.",
	},

	# ---------------- HOLLOW LEGION ----------------
	"hollow_necropolis": {
		"race": "hollow", "name": "Hollow Necropolis", "kind": "main", "model": _b("hollow_necropolis"),
		"hp": 1950, "armor_class": "fortified", "armor": 8, "footprint": 7.0,
		"cost": {"timber": 330, "stone": 185}, "build_time": 56, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["hollow_gravedigger"], "drop_off": true, "is_hq": true,
		"desc": "Vast bone-tower at the heart of the Legion. Raises gravediggers and commands the undead tide.",
	},
	"hollow_crypt": {
		"race": "hollow", "name": "Hollow Crypt", "kind": "house", "model": _b("vorthak_ash_forge"),
		"hp": 480, "armor_class": "medium", "armor": 1, "footprint": 3.4,
		"cost": {"timber": 50, "stone": 20}, "build_time": 16, "grants_pop": 9,
		"produces": [], "desc": "Sealed crypt that makes room for even more hollow ranks.",
	},
	"hollow_ossuary": {
		"race": "hollow", "name": "Ossuary", "kind": "barracks", "model": _b("vorthak_bone_barracks"),
		"hp": 800, "armor_class": "medium", "armor": 3, "footprint": 5.0,
		"cost": {"timber": 140, "stone": 40}, "build_time": 28, "grants_pop": 0,
		"produces": ["hollow_skeleton", "hollow_boneguard", "hollow_bonearcher", "hollow_wraith"],
		"desc": "Charnel hall where skeletons, boneguards, archers, and wraiths are assembled from death's raw material.",
	},
	"hollow_darkforge": {
		"race": "hollow", "name": "Dark Forge", "kind": "economy", "model": _b("vorthak_ash_forge"),
		"hp": 620, "armor_class": "medium", "armor": 2, "footprint": 3.8,
		"cost": {"timber": 100, "stone": 70}, "build_time": 26, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Sorcerous forge that inscribes dark runes into weapons and hardens bone with death-energy.",
	},
	"hollow_bone_spire": {
		"race": "hollow", "name": "Bone Spire", "kind": "arcane", "model": _b("vorthak_warlock_spire"),
		"hp": 680, "armor_class": "light", "armor": 1, "footprint": 4.0,
		"cost": {"timber": 110, "gold": 90}, "build_time": 34, "grants_pop": 0,
		"produces": ["hollow_necromancer"],
		"desc": "Towering pillar of fused bone that trains the Legion's necromancers in the dark arts.",
	},
	"hollow_curse_obelisk": {
		"race": "hollow", "name": "Curse Obelisk", "kind": "tower", "model": _b("vorthak_rift_obelisk"),
		"hp": 650, "armor_class": "medium", "armor": 3, "footprint": 3.0,
		"cost": {"timber": 60, "stone": 80}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 26, "tower_range": 19.0, "tower_cd": 1.3, "tower_type": "arcane", "projectile": "void_bolt",
		"produces": [], "desc": "Cursed obelisk that drains life from enemies who stray too close.",
	},

	# ---------------- FROSTBORN JARLS ----------------
	"frostborn_mead_hall": {
		"race": "frostborn", "name": "Frostborn Mead Hall", "kind": "main", "model": _b("frostborn_mead_hall"),
		"hp": 2200, "armor_class": "fortified", "armor": 10, "footprint": 7.0,
		"cost": {"timber": 350, "stone": 200}, "build_time": 60, "grants_pop": 12, "tier_unlock": 1,
		"produces": ["frostborn_thrall"], "drop_off": true, "is_hq": true,
		"desc": "Great longhouse of the northern Jarls. Thralls are trained here and spoils of war are counted.",
	},
	"frostborn_longhouse": {
		"race": "frostborn", "name": "Frostborn Longhouse", "kind": "house", "model": _b("barrosan_clan_croft"),
		"hp": 560, "armor_class": "medium", "armor": 2, "footprint": 3.6,
		"cost": {"timber": 60, "stone": 20}, "build_time": 18, "grants_pop": 8,
		"produces": [], "desc": "Long timber-and-stone hall that shelters more of the clan through the endless winter.",
	},
	"frostborn_war_hall": {
		"race": "frostborn", "name": "Frostborn War Hall", "kind": "barracks", "model": _b("barrosan_war_hall"),
		"hp": 960, "armor_class": "fortified", "armor": 5, "footprint": 5.0,
		"cost": {"timber": 150, "stone": 60}, "build_time": 30, "grants_pop": 0,
		"produces": ["frostborn_reaver", "frostborn_shieldmaiden", "frostborn_hunter", "frostborn_berserker", "frostborn_jotun"],
		"desc": "Frost-rimed war hall where reavers, shield maidens, hunters, berserkers and jotun are readied.",
	},
	"frostborn_runeforge": {
		"race": "frostborn", "name": "Runeforge", "kind": "economy", "model": _b("barrosan_iron_forge"),
		"hp": 710, "armor_class": "medium", "armor": 3, "footprint": 4.0,
		"cost": {"timber": 100, "stone": 80}, "build_time": 28, "grants_pop": 0, "is_research": true,
		"produces": [], "research": ["tech_weapons", "tech_armor"],
		"desc": "Frost-rune forge that tempers axe-blades and hardens shields against any weapon.",
	},
	"frostborn_watchtower": {
		"race": "frostborn", "name": "Frostborn Watchtower", "kind": "tower", "model": _b("barrosan_watchtower"),
		"hp": 820, "armor_class": "fortified", "armor": 6, "footprint": 3.2,
		"cost": {"timber": 40, "stone": 100}, "build_time": 24, "grants_pop": 0,
		"tower_dmg": 22, "tower_range": 20.0, "tower_cd": 1.1, "tower_type": "pierce", "projectile": "bolt",
		"produces": [], "desc": "Ice-crusted watchtower that fires heavy bolts at anything approaching the mead hall.",
	},
	}
