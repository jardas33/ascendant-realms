class_name SkillDefs
## The Constellation — Ascendant Realms' hero skill tree.
## 160+ nodes across 8 branches. Each node has a real gameplay effect applied
## by HeroProgression. Nodes reference prerequisites by id and cost skill points.
##
## effect keys (read by HeroProgression.apply_effect):
##   stat: {hp, dmg, armor, speed, attack_speed, vision, range, mana, mana_regen,
##          heal_power, aura_range, aura_dmg, aura_armor}  -> add value
##   ability: unlocks/upgrades an active ability id
##   flag: sets a boolean build flag (economy/command modifiers)
##
## pos is a 2D grid coordinate for the tree UI (x, y).
## branch: combat|defense|mobility|active|magic|command|economy|race

static func get_tree() -> Array:
	var nodes: Array = []

	# ============ COMBAT (offense) — column x=0 ============
	nodes += [
		{"id": "cmb_1", "branch": "combat", "name": "Keen Edge", "cost": 1, "pos": Vector2(0, 0),
			"req": [], "effect": {"stat": {"dmg": 4}}, "desc": "+4 hero attack damage."},
		{"id": "cmb_2", "branch": "combat", "name": "Battle Fury", "cost": 1, "pos": Vector2(0, 1),
			"req": ["cmb_1"], "effect": {"stat": {"attack_speed": 0.12}}, "desc": "+12% hero attack speed."},
		{"id": "cmb_3", "branch": "combat", "name": "Crushing Blows", "cost": 1, "pos": Vector2(0, 2),
			"req": ["cmb_2"], "effect": {"stat": {"dmg": 6}}, "desc": "+6 hero attack damage."},
		{"id": "cmb_4", "branch": "combat", "name": "Executioner", "cost": 2, "pos": Vector2(0, 3),
			"req": ["cmb_3"], "effect": {"flag": {"execute": true}}, "desc": "Hero deals +50% damage to enemies below 30% health."},
		{"id": "cmb_5", "branch": "combat", "name": "Cleaving Strikes", "cost": 2, "pos": Vector2(0, 4),
			"req": ["cmb_3"], "effect": {"flag": {"cleave": true}}, "desc": "Hero attacks splash to nearby enemies."},
		{"id": "cmb_6", "branch": "combat", "name": "Warlord's Might", "cost": 3, "pos": Vector2(0, 5),
			"req": ["cmb_4", "cmb_5"], "keystone": true, "effect": {"stat": {"dmg": 12, "attack_speed": 0.15}},
			"desc": "KEYSTONE: +12 damage and +15% attack speed. A true engine of war."},
		# New combat nodes
		{"id": "cmb_7", "branch": "combat", "name": "Tempered Steel", "cost": 1, "pos": Vector2(0, 6),
			"req": ["cmb_6"], "effect": {"stat": {"dmg": 8}}, "desc": "+8 hero attack damage."},
		{"id": "cmb_8", "branch": "combat", "name": "Relentless Assault", "cost": 2, "pos": Vector2(0, 7),
			"req": ["cmb_7"], "effect": {"stat": {"attack_speed": 0.18}}, "desc": "+18% hero attack speed."},
		{"id": "cmb_9", "branch": "combat", "name": "Bloodlust", "cost": 2, "pos": Vector2(0, 8),
			"req": ["cmb_7"], "effect": {"flag": {"lifesteal": 0.10}}, "desc": "Hero heals for 10% of all damage dealt."},
		{"id": "cmb_10", "branch": "combat", "name": "Iron Will", "cost": 1, "pos": Vector2(0.5, 6),
			"req": ["cmb_6"], "effect": {"stat": {"dmg": 5, "hp": 50}}, "desc": "+5 damage, +50 health."},
		{"id": "cmb_11", "branch": "combat", "name": "Rending Strike", "cost": 2, "pos": Vector2(0.5, 7),
			"req": ["cmb_10"], "effect": {"stat": {"dmg": 10, "armor": -1}}, "desc": "+10 damage. Slightly reduces armor (trade offense for offense)."},
		{"id": "cmb_12", "branch": "combat", "name": "Blade Mastery", "cost": 2, "pos": Vector2(0, 9),
			"req": ["cmb_8", "cmb_9"], "effect": {"stat": {"dmg": 10, "attack_speed": 0.10}}, "desc": "+10 damage and +10% attack speed."},
		{"id": "cmb_13", "branch": "combat", "name": "Avatar's Edge", "cost": 3, "pos": Vector2(0, 10),
			"req": ["cmb_12"], "keystone": true, "effect": {"stat": {"dmg": 18, "attack_speed": 0.20}},
			"desc": "KEYSTONE: +18 damage, +20% attack speed — a relentless war machine."},
		{"id": "cmb_14", "branch": "combat", "name": "Devastating Blow", "cost": 2, "pos": Vector2(0.5, 9),
			"req": ["cmb_11"], "effect": {"stat": {"dmg": 14}}, "desc": "+14 hero attack damage."},
	]

	# ============ DEFENSE (survival) — column x=1 ============
	nodes += [
		{"id": "def_1", "branch": "defense", "name": "Iron Hide", "cost": 1, "pos": Vector2(1, 0),
			"req": [], "effect": {"stat": {"hp": 80}}, "desc": "+80 hero max health."},
		{"id": "def_2", "branch": "defense", "name": "Plated Guard", "cost": 1, "pos": Vector2(1, 1),
			"req": ["def_1"], "effect": {"stat": {"armor": 3}}, "desc": "+3 hero armor."},
		{"id": "def_3", "branch": "defense", "name": "Second Wind", "cost": 1, "pos": Vector2(1, 2),
			"req": ["def_2"], "effect": {"flag": {"regen": 3.0}}, "desc": "Hero regenerates 3 health per second."},
		{"id": "def_4", "branch": "defense", "name": "Bulwark", "cost": 2, "pos": Vector2(1, 3),
			"req": ["def_3"], "effect": {"stat": {"hp": 150, "armor": 3}}, "desc": "+150 health and +3 armor."},
		{"id": "def_5", "branch": "defense", "name": "Unyielding", "cost": 2, "pos": Vector2(1, 4),
			"req": ["def_4"], "effect": {"flag": {"last_stand": true}}, "desc": "The hero survives a lethal blow once per battle at 1 health."},
		{"id": "def_6", "branch": "defense", "name": "Immortal Aegis", "cost": 3, "pos": Vector2(1, 5),
			"req": ["def_5"], "keystone": true, "effect": {"stat": {"hp": 300, "armor": 5}, "flag": {"regen": 8.0}},
			"desc": "KEYSTONE: +300 health, +5 armor, and 8 health/sec regen."},
		# New defense nodes
		{"id": "def_7", "branch": "defense", "name": "Stalwart Body", "cost": 1, "pos": Vector2(1, 6),
			"req": ["def_6"], "effect": {"stat": {"hp": 120}}, "desc": "+120 hero max health."},
		{"id": "def_8", "branch": "defense", "name": "Layered Plate", "cost": 2, "pos": Vector2(1, 7),
			"req": ["def_7"], "effect": {"stat": {"armor": 4}}, "desc": "+4 hero armor."},
		{"id": "def_9", "branch": "defense", "name": "Steadfast Resolve", "cost": 2, "pos": Vector2(1, 8),
			"req": ["def_7"], "effect": {"flag": {"regen": 5.0}}, "desc": "Hero regenerates 5 more health per second."},
		{"id": "def_10", "branch": "defense", "name": "Fortified Spirit", "cost": 1, "pos": Vector2(1.5, 6),
			"req": ["def_6"], "effect": {"stat": {"hp": 80, "armor": 2}}, "desc": "+80 health and +2 armor."},
		{"id": "def_11", "branch": "defense", "name": "Enduring Might", "cost": 2, "pos": Vector2(1.5, 7),
			"req": ["def_10"], "effect": {"stat": {"hp": 100, "armor": 3}}, "desc": "+100 health and +3 armor."},
		{"id": "def_12", "branch": "defense", "name": "Titan's Frame", "cost": 2, "pos": Vector2(1, 9),
			"req": ["def_8", "def_9"], "effect": {"stat": {"hp": 200, "armor": 4}}, "desc": "+200 health and +4 armor."},
		{"id": "def_13", "branch": "defense", "name": "Unbreakable", "cost": 3, "pos": Vector2(1, 10),
			"req": ["def_12"], "keystone": true, "effect": {"stat": {"hp": 350, "armor": 6}, "flag": {"regen": 10.0}},
			"desc": "KEYSTONE: +350 health, +6 armor, 10 health/sec regen — a walking fortress."},
		{"id": "def_14", "branch": "defense", "name": "Shield of Ages", "cost": 2, "pos": Vector2(1.5, 9),
			"req": ["def_11"], "effect": {"stat": {"armor": 6, "hp": 80}}, "desc": "+6 armor and +80 health."},
	]

	# ============ MOBILITY — column x=2 ============
	nodes += [
		{"id": "mob_1", "branch": "mobility", "name": "Fleet Step", "cost": 1, "pos": Vector2(2, 0),
			"req": [], "effect": {"stat": {"speed": 0.6}}, "desc": "+0.6 hero movement speed."},
		{"id": "mob_2", "branch": "mobility", "name": "Eagle Eyes", "cost": 1, "pos": Vector2(2, 1),
			"req": ["mob_1"], "effect": {"stat": {"vision": 6}}, "desc": "+6 hero vision range."},
		{"id": "mob_3", "branch": "mobility", "name": "Surefoot", "cost": 1, "pos": Vector2(2, 2),
			"req": ["mob_1"], "effect": {"stat": {"speed": 0.6}}, "desc": "+0.6 more movement speed."},
		{"id": "mob_4", "branch": "mobility", "name": "War Charge", "cost": 2, "pos": Vector2(2, 3),
			"req": ["mob_3"], "effect": {"ability": {"id": "charge", "level": 1}}, "desc": "Unlocks CHARGE: dash to a point, damaging enemies in the path."},
		{"id": "mob_5", "branch": "mobility", "name": "Relentless", "cost": 2, "pos": Vector2(2, 4),
			"req": ["mob_4"], "effect": {"flag": {"unstoppable": true}}, "desc": "Hero cannot be slowed or rooted."},
		{"id": "mob_6", "branch": "mobility", "name": "Storm Rider", "cost": 3, "pos": Vector2(2, 5),
			"req": ["mob_5"], "keystone": true, "effect": {"stat": {"speed": 1.5, "attack_speed": 0.1}, "ability": {"id": "charge", "level": 2}},
			"desc": "KEYSTONE: +1.5 speed, upgraded Charge, and mounted momentum."},
		# New mobility nodes
		{"id": "mob_7", "branch": "mobility", "name": "Far Sight", "cost": 1, "pos": Vector2(2, 6),
			"req": ["mob_6"], "effect": {"stat": {"vision": 8}}, "desc": "+8 hero vision range."},
		{"id": "mob_8", "branch": "mobility", "name": "Phantom Step", "cost": 2, "pos": Vector2(2, 7),
			"req": ["mob_7"], "effect": {"stat": {"speed": 0.8, "vision": 4}}, "desc": "+0.8 speed and +4 vision."},
		{"id": "mob_9", "branch": "mobility", "name": "Lightning Reflexes", "cost": 2, "pos": Vector2(2, 8),
			"req": ["mob_7"], "effect": {"stat": {"attack_speed": 0.15, "speed": 0.5}}, "desc": "+15% attack speed and +0.5 movement speed."},
		{"id": "mob_10", "branch": "mobility", "name": "Sprinter", "cost": 1, "pos": Vector2(2.5, 6),
			"req": ["mob_6"], "effect": {"stat": {"speed": 1.0}}, "desc": "+1.0 movement speed."},
		{"id": "mob_11", "branch": "mobility", "name": "Swift Predator", "cost": 2, "pos": Vector2(2.5, 7),
			"req": ["mob_10"], "effect": {"stat": {"speed": 0.8, "attack_speed": 0.10}}, "desc": "+0.8 speed and +10% attack speed."},
		{"id": "mob_12", "branch": "mobility", "name": "Blurring Speed", "cost": 2, "pos": Vector2(2, 9),
			"req": ["mob_8", "mob_9"], "effect": {"stat": {"speed": 1.2, "vision": 5}}, "desc": "+1.2 movement speed and +5 vision."},
		{"id": "mob_13", "branch": "mobility", "name": "Gale Surge", "cost": 3, "pos": Vector2(2, 10),
			"req": ["mob_12"], "keystone": true, "effect": {"stat": {"speed": 2.0, "attack_speed": 0.20}, "ability": {"id": "charge", "level": 3}},
			"desc": "KEYSTONE: +2.0 speed, +20% attack speed, and max-level Charge."},
		{"id": "mob_14", "branch": "mobility", "name": "Hawk's Gaze", "cost": 2, "pos": Vector2(2.5, 9),
			"req": ["mob_11"], "effect": {"stat": {"vision": 12, "range": 4}}, "desc": "+12 vision and +4 attack range."},
	]

	# ============ ACTIVE ABILITIES — column x=3 ============
	nodes += [
		{"id": "act_1", "branch": "active", "name": "Rallying Cry", "cost": 1, "pos": Vector2(3, 0),
			"req": [], "effect": {"ability": {"id": "rally", "level": 1}}, "desc": "Unlocks RALLY: heal and speed-boost nearby allies."},
		{"id": "act_2", "branch": "active", "name": "Ground Slam", "cost": 1, "pos": Vector2(3, 1),
			"req": ["act_1"], "effect": {"ability": {"id": "slam", "level": 1}}, "desc": "Unlocks SLAM: area damage and stun around the hero."},
		{"id": "act_3", "branch": "active", "name": "Deepened Reserves", "cost": 1, "pos": Vector2(3, 2),
			"req": ["act_1"], "effect": {"stat": {"mana": 40, "mana_regen": 1.5}}, "desc": "+40 max mana and +1.5 mana regen."},
		{"id": "act_4", "branch": "active", "name": "Empowered Cry", "cost": 2, "pos": Vector2(3, 3),
			"req": ["act_3"], "effect": {"ability": {"id": "rally", "level": 2}}, "desc": "Rally also grants allies bonus armor."},
		{"id": "act_5", "branch": "active", "name": "Seismic Force", "cost": 2, "pos": Vector2(3, 4),
			"req": ["act_2"], "effect": {"ability": {"id": "slam", "level": 2}}, "desc": "Slam hits a wider area and damages buildings."},
		{"id": "act_6", "branch": "active", "name": "Avatar of War", "cost": 3, "pos": Vector2(3, 5),
			"req": ["act_4", "act_5"], "keystone": true, "effect": {"ability": {"id": "avatar", "level": 1}, "stat": {"mana": 60}},
			"desc": "KEYSTONE: Unlocks AVATAR — become a towering champion for 12 seconds."},
		# New active nodes
		{"id": "act_7", "branch": "active", "name": "Surge of Will", "cost": 1, "pos": Vector2(3, 6),
			"req": ["act_6"], "effect": {"stat": {"mana": 50, "mana_regen": 2.0}}, "desc": "+50 mana and +2 mana regen."},
		{"id": "act_8", "branch": "active", "name": "Thunderous Slam", "cost": 2, "pos": Vector2(3, 7),
			"req": ["act_7"], "effect": {"ability": {"id": "slam", "level": 3}}, "desc": "Slam ascends to maximum power — massive stun radius and damage."},
		{"id": "act_9", "branch": "active", "name": "Battle Anthem", "cost": 2, "pos": Vector2(3, 8),
			"req": ["act_7"], "effect": {"ability": {"id": "rally", "level": 3}}, "desc": "Rally becomes a powerful anthem — huge area, huge buff."},
		{"id": "act_10", "branch": "active", "name": "Mana Conduit", "cost": 1, "pos": Vector2(3.5, 6),
			"req": ["act_6"], "effect": {"stat": {"mana": 60}}, "desc": "+60 maximum mana."},
		{"id": "act_11", "branch": "active", "name": "Deep Wellspring", "cost": 2, "pos": Vector2(3.5, 7),
			"req": ["act_10"], "effect": {"stat": {"mana": 80, "mana_regen": 3.0}}, "desc": "+80 mana and +3 mana regen."},
		{"id": "act_12", "branch": "active", "name": "God's Voice", "cost": 2, "pos": Vector2(3, 9),
			"req": ["act_8", "act_9"], "effect": {"ability": {"id": "avatar", "level": 2}, "stat": {"mana": 80}},
			"desc": "Avatar level 2: longer duration and increased champion stats."},
		{"id": "act_13", "branch": "active", "name": "Eternal Champion", "cost": 3, "pos": Vector2(3, 10),
			"req": ["act_12"], "keystone": true, "effect": {"ability": {"id": "avatar", "level": 3}, "stat": {"mana": 100, "mana_regen": 4.0}},
			"desc": "KEYSTONE: Avatar reaches maximum power — near-immortal form."},
		{"id": "act_14", "branch": "active", "name": "Reservoir of Power", "cost": 2, "pos": Vector2(3.5, 9),
			"req": ["act_11"], "effect": {"stat": {"mana": 120, "mana_regen": 2.5}}, "desc": "+120 mana and +2.5 mana regen."},
	]

	# ============ MAGIC / LUME — column x=4 ============
	nodes += [
		{"id": "mag_1", "branch": "magic", "name": "Lume Spark", "cost": 1, "pos": Vector2(4, 0),
			"req": [], "effect": {"ability": {"id": "bolt", "level": 1}}, "desc": "Unlocks LUME BOLT: a ranged magic blast."},
		{"id": "mag_2", "branch": "magic", "name": "Arcane Focus", "cost": 1, "pos": Vector2(4, 1),
			"req": ["mag_1"], "effect": {"stat": {"mana_regen": 2.0}}, "desc": "+2 mana regeneration."},
		{"id": "mag_3", "branch": "magic", "name": "Chain Lume", "cost": 2, "pos": Vector2(4, 2),
			"req": ["mag_2"], "effect": {"ability": {"id": "bolt", "level": 2}}, "desc": "Lume Bolt arcs to a second target."},
		{"id": "mag_4", "branch": "magic", "name": "Mending Light", "cost": 2, "pos": Vector2(4, 3),
			"req": ["mag_2"], "effect": {"ability": {"id": "heal", "level": 1}, "stat": {"heal_power": 20}}, "desc": "Unlocks HEAL WAVE: restore health to your army."},
		{"id": "mag_5", "branch": "magic", "name": "Entangling Roots", "cost": 2, "pos": Vector2(4, 4),
			"req": ["mag_3"], "effect": {"ability": {"id": "root", "level": 1}}, "desc": "Unlocks ROOT: hold enemies in place in an area."},
		{"id": "mag_6", "branch": "magic", "name": "Archmage Ascendant", "cost": 3, "pos": Vector2(4, 5),
			"req": ["mag_4", "mag_5"], "keystone": true, "effect": {"stat": {"mana": 80, "mana_regen": 3.0}, "ability": {"id": "bolt", "level": 3}},
			"desc": "KEYSTONE: Vast mana, roaring regen, and a triple-arc Lume Bolt."},
		# New magic nodes
		{"id": "mag_7", "branch": "magic", "name": "Ancient Lore", "cost": 1, "pos": Vector2(4, 6),
			"req": ["mag_6"], "effect": {"stat": {"mana": 60, "mana_regen": 1.5}}, "desc": "+60 mana and +1.5 mana regen."},
		{"id": "mag_8", "branch": "magic", "name": "Empowered Roots", "cost": 2, "pos": Vector2(4, 7),
			"req": ["mag_7"], "effect": {"ability": {"id": "root", "level": 2}}, "desc": "Roots hold longer and affect more enemies."},
		{"id": "mag_9", "branch": "magic", "name": "Greater Heal", "cost": 2, "pos": Vector2(4, 8),
			"req": ["mag_7"], "effect": {"ability": {"id": "heal", "level": 2}, "stat": {"heal_power": 30}}, "desc": "Heal Wave covers a wider area and restores more health."},
		{"id": "mag_10", "branch": "magic", "name": "Lume Mastery", "cost": 1, "pos": Vector2(4.5, 6),
			"req": ["mag_6"], "effect": {"stat": {"mana_regen": 2.5, "range": 3}}, "desc": "+2.5 mana regen and +3 ability range."},
		{"id": "mag_11", "branch": "magic", "name": "Spellweaver", "cost": 2, "pos": Vector2(4.5, 7),
			"req": ["mag_10"], "effect": {"stat": {"mana": 80, "mana_regen": 2.0, "heal_power": 20}}, "desc": "+80 mana, +2 regen, +20 heal power."},
		{"id": "mag_12", "branch": "magic", "name": "Grand Weaving", "cost": 2, "pos": Vector2(4, 9),
			"req": ["mag_8", "mag_9"], "effect": {"ability": {"id": "root", "level": 3}, "stat": {"heal_power": 40}},
			"desc": "Max-level Roots and empowered Heal Wave."},
		{"id": "mag_13", "branch": "magic", "name": "Lume Transcendence", "cost": 3, "pos": Vector2(4, 10),
			"req": ["mag_12"], "keystone": true, "effect": {"stat": {"mana": 120, "mana_regen": 5.0, "heal_power": 50}},
			"desc": "KEYSTONE: Vast magical power — huge mana pool and regeneration."},
		{"id": "mag_14", "branch": "magic", "name": "Radiant Surge", "cost": 2, "pos": Vector2(4.5, 9),
			"req": ["mag_11"], "effect": {"stat": {"mana_regen": 4.0, "heal_power": 35}}, "desc": "+4 mana regen and +35 heal power."},
	]

	# ============ COMMAND (army leadership) — column x=5 ============
	nodes += [
		{"id": "cmd_1", "branch": "command", "name": "Inspiring Presence", "cost": 1, "pos": Vector2(5, 0),
			"req": [], "effect": {"stat": {"aura_dmg": 2, "aura_range": 12}}, "desc": "Nearby allies gain +2 attack damage."},
		{"id": "cmd_2", "branch": "command", "name": "Disciplined Ranks", "cost": 1, "pos": Vector2(5, 1),
			"req": ["cmd_1"], "effect": {"stat": {"aura_armor": 2}}, "desc": "Nearby allies gain +2 armor."},
		{"id": "cmd_3", "branch": "command", "name": "Wide Banner", "cost": 1, "pos": Vector2(5, 2),
			"req": ["cmd_1"], "effect": {"stat": {"aura_range": 8}}, "desc": "+8 range on all command auras."},
		{"id": "cmd_4", "branch": "command", "name": "Veteran Drills", "cost": 2, "pos": Vector2(5, 3),
			"req": ["cmd_2"], "effect": {"stat": {"aura_dmg": 3, "aura_armor": 1}}, "desc": "Command aura: +3 more damage and +1 more armor."},
		{"id": "cmd_5", "branch": "command", "name": "Siege Doctrine", "cost": 2, "pos": Vector2(5, 4),
			"req": ["cmd_4"], "effect": {"flag": {"aura_siege": true}}, "desc": "Command auras also empower your siege engines."},
		{"id": "cmd_6", "branch": "command", "name": "Legendary Commander", "cost": 3, "pos": Vector2(5, 5),
			"req": ["cmd_5"], "keystone": true, "effect": {"stat": {"aura_dmg": 5, "aura_armor": 3, "aura_range": 12}},
			"desc": "KEYSTONE: Command aura empowers a huge radius of your entire army."},
		# New command nodes
		{"id": "cmd_7", "branch": "command", "name": "Iron Standard", "cost": 1, "pos": Vector2(5, 6),
			"req": ["cmd_6"], "effect": {"stat": {"aura_armor": 3, "aura_range": 6}}, "desc": "+3 aura armor and +6 aura range."},
		{"id": "cmd_8", "branch": "command", "name": "War Council", "cost": 2, "pos": Vector2(5, 7),
			"req": ["cmd_7"], "effect": {"stat": {"aura_dmg": 4, "aura_armor": 2}}, "desc": "+4 aura damage and +2 aura armor."},
		{"id": "cmd_9", "branch": "command", "name": "Rallied Front", "cost": 2, "pos": Vector2(5, 8),
			"req": ["cmd_7"], "effect": {"stat": {"aura_range": 14, "aura_dmg": 3}}, "desc": "+14 aura range and +3 aura damage."},
		{"id": "cmd_10", "branch": "command", "name": "Grand Strategy", "cost": 1, "pos": Vector2(5.5, 6),
			"req": ["cmd_6"], "effect": {"stat": {"aura_dmg": 3, "aura_range": 8}}, "desc": "+3 aura damage and +8 aura range."},
		{"id": "cmd_11", "branch": "command", "name": "Tactical Genius", "cost": 2, "pos": Vector2(5.5, 7),
			"req": ["cmd_10"], "effect": {"stat": {"aura_dmg": 5, "aura_armor": 3}}, "desc": "+5 aura damage and +3 aura armor."},
		{"id": "cmd_12", "branch": "command", "name": "Warlord's Mandate", "cost": 2, "pos": Vector2(5, 9),
			"req": ["cmd_8", "cmd_9"], "effect": {"stat": {"aura_dmg": 6, "aura_armor": 4, "aura_range": 10}},
			"desc": "+6 aura damage, +4 aura armor, +10 aura range."},
		{"id": "cmd_13", "branch": "command", "name": "Supreme Overlord", "cost": 3, "pos": Vector2(5, 10),
			"req": ["cmd_12"], "keystone": true, "effect": {"stat": {"aura_dmg": 10, "aura_armor": 6, "aura_range": 20}},
			"desc": "KEYSTONE: Overwhelming command aura — your army fights like champions."},
		{"id": "cmd_14", "branch": "command", "name": "Undying Banner", "cost": 2, "pos": Vector2(5.5, 9),
			"req": ["cmd_11"], "effect": {"stat": {"aura_armor": 5, "aura_range": 12}}, "desc": "+5 aura armor and +12 aura range."},
	]

	# ============ ECONOMY & CONSTRUCTION — column x=6 ============
	nodes += [
		{"id": "eco_1", "branch": "economy", "name": "Foreman", "cost": 1, "pos": Vector2(6, 0),
			"req": [], "effect": {"flag": {"gather_bonus": 0.10}}, "desc": "Workers gather 10% faster."},
		{"id": "eco_2", "branch": "economy", "name": "Master Builders", "cost": 1, "pos": Vector2(6, 1),
			"req": ["eco_1"], "effect": {"flag": {"build_speed": 0.20}}, "desc": "Buildings are constructed 20% faster."},
		{"id": "eco_3", "branch": "economy", "name": "Warchest", "cost": 1, "pos": Vector2(6, 2),
			"req": ["eco_1"], "effect": {"flag": {"start_gold": 150}}, "desc": "Begin each battle with +150 gold."},
		{"id": "eco_4", "branch": "economy", "name": "Efficient Training", "cost": 2, "pos": Vector2(6, 3),
			"req": ["eco_2"], "effect": {"flag": {"train_speed": 0.15}}, "desc": "Units train 15% faster."},
		{"id": "eco_5", "branch": "economy", "name": "Spoils of War", "cost": 2, "pos": Vector2(6, 4),
			"req": ["eco_3"], "effect": {"flag": {"bounty": true}}, "desc": "Killing enemy units returns a little gold."},
		{"id": "eco_6", "branch": "economy", "name": "Industrial Might", "cost": 3, "pos": Vector2(6, 5),
			"req": ["eco_4", "eco_5"], "keystone": true, "effect": {"flag": {"gather_bonus": 0.25, "train_speed": 0.15, "build_speed": 0.20}},
			"desc": "KEYSTONE: Sweeping bonuses to gathering, training and construction."},
		# New economy nodes
		{"id": "eco_7", "branch": "economy", "name": "Enriched Veins", "cost": 1, "pos": Vector2(6, 6),
			"req": ["eco_6"], "effect": {"flag": {"gather_bonus": 0.15}}, "desc": "Workers gather an additional 15% faster."},
		{"id": "eco_8", "branch": "economy", "name": "Grand Treasury", "cost": 2, "pos": Vector2(6, 7),
			"req": ["eco_7"], "effect": {"flag": {"start_gold": 250}}, "desc": "Begin each battle with +250 additional gold."},
		{"id": "eco_9", "branch": "economy", "name": "Rapid Assembly", "cost": 2, "pos": Vector2(6, 8),
			"req": ["eco_7"], "effect": {"flag": {"build_speed": 0.25, "train_speed": 0.20}}, "desc": "+25% build speed and +20% train speed."},
		{"id": "eco_10", "branch": "economy", "name": "Merchant Prince", "cost": 1, "pos": Vector2(6.5, 6),
			"req": ["eco_6"], "effect": {"flag": {"bounty": true, "start_gold": 100}}, "desc": "Kill bounties and +100 starting gold."},
		{"id": "eco_11", "branch": "economy", "name": "War Economy", "cost": 2, "pos": Vector2(6.5, 7),
			"req": ["eco_10"], "effect": {"flag": {"gather_bonus": 0.20, "train_speed": 0.15}}, "desc": "+20% gather rate and +15% training speed."},
		{"id": "eco_12", "branch": "economy", "name": "Empire's Engine", "cost": 2, "pos": Vector2(6, 9),
			"req": ["eco_8", "eco_9"], "effect": {"flag": {"gather_bonus": 0.30, "build_speed": 0.25}}, "desc": "+30% gather and +25% build speed."},
		{"id": "eco_13", "branch": "economy", "name": "Golden Age", "cost": 3, "pos": Vector2(6, 10),
			"req": ["eco_12"], "keystone": true, "effect": {"flag": {"gather_bonus": 0.40, "train_speed": 0.30, "build_speed": 0.30, "start_gold": 300}},
			"desc": "KEYSTONE: Golden Age — a vast economic empire fuels unstoppable armies."},
		{"id": "eco_14", "branch": "economy", "name": "Plunder",  "cost": 2, "pos": Vector2(6.5, 9),
			"req": ["eco_11"], "effect": {"flag": {"bounty": true, "start_gold": 200}}, "desc": "Kill bounties plus +200 starting gold each battle."},
	]

	# ============ RACE-SPECIFIC — columns x=7 and x=8 ============
	nodes += [
		# --- Barrosan (existing) ---
		{"id": "race_bar_1", "branch": "race", "name": "Highland Endurance", "cost": 2, "pos": Vector2(7, 0),
			"req": [], "race": "barrosan", "effect": {"stat": {"hp": 120, "armor": 2}}, "desc": "Barrosan: +120 health, +2 armor to the hero."},
		{"id": "race_bar_2", "branch": "race", "name": "Fortress Lord", "cost": 3, "pos": Vector2(7, 1),
			"req": ["race_bar_1"], "race": "barrosan", "keystone": true, "effect": {"flag": {"fortify_boost": true}},
			"desc": "Barrosan KEYSTONE: Your Fortify bonus is doubled and reaches farther."},
		# Barrosan new
		{"id": "race_bar_3", "branch": "race", "name": "Mountain Blood", "cost": 1, "pos": Vector2(8, 0),
			"req": [], "race": "barrosan", "effect": {"stat": {"hp": 80, "armor": 1}}, "desc": "Barrosan: +80 health, +1 armor."},
		{"id": "race_bar_4", "branch": "race", "name": "Stonewarden", "cost": 2, "pos": Vector2(8, 1),
			"req": ["race_bar_3"], "race": "barrosan", "effect": {"stat": {"hp": 150, "armor": 3}}, "desc": "Barrosan: +150 health, +3 armor."},

		# --- Lioraen (existing) ---
		{"id": "race_lio_1", "branch": "race", "name": "Verdant Bond", "cost": 2, "pos": Vector2(7, 2),
			"req": [], "race": "lioraen", "effect": {"stat": {"heal_power": 25, "speed": 0.8}}, "desc": "Lioraen: +25 heal power and +0.8 speed."},
		{"id": "race_lio_2", "branch": "race", "name": "Worldtree Warden", "cost": 3, "pos": Vector2(7, 3),
			"req": ["race_lio_1"], "race": "lioraen", "keystone": true, "effect": {"flag": {"bloom_boost": true}},
			"desc": "Lioraen KEYSTONE: Your Groveheart's healing aura is far stronger and wider."},
		# Lioraen new
		{"id": "race_lio_3", "branch": "race", "name": "Nature's Grace", "cost": 1, "pos": Vector2(8, 2),
			"req": [], "race": "lioraen", "effect": {"stat": {"speed": 0.6, "vision": 4}}, "desc": "Lioraen: +0.6 speed, +4 vision."},
		{"id": "race_lio_4", "branch": "race", "name": "Forest Walker", "cost": 2, "pos": Vector2(8, 3),
			"req": ["race_lio_3"], "race": "lioraen", "effect": {"stat": {"heal_power": 30, "speed": 0.6}}, "desc": "Lioraen: +30 heal power, +0.6 speed."},

		# --- Vorthak (existing) ---
		{"id": "race_vor_1", "branch": "race", "name": "Blood Price", "cost": 2, "pos": Vector2(7, 4),
			"req": [], "race": "vorthak", "effect": {"stat": {"dmg": 15, "hp": -40}}, "desc": "Vorthak: +15 damage but -40 health. Power at a cost."},
		{"id": "race_vor_2", "branch": "race", "name": "Rift Sovereign", "cost": 3, "pos": Vector2(7, 5),
			"req": ["race_vor_1"], "race": "vorthak", "keystone": true, "effect": {"flag": {"lifesteal": 0.25}},
			"desc": "Vorthak KEYSTONE: The hero heals for 25% of all damage dealt."},
		# Vorthak new
		{"id": "race_vor_3", "branch": "race", "name": "Void Touch", "cost": 1, "pos": Vector2(8, 4),
			"req": [], "race": "vorthak", "effect": {"stat": {"dmg": 10}}, "desc": "Vorthak: +10 attack damage from rift-touched power."},
		{"id": "race_vor_4", "branch": "race", "name": "Rift Channeler", "cost": 2, "pos": Vector2(8, 5),
			"req": ["race_vor_3"], "race": "vorthak", "effect": {"stat": {"dmg": 12, "mana": 40}}, "desc": "Vorthak: +12 damage and +40 mana."},

		# --- Grimtusk (orc — high damage, raw power) ---
		{"id": "race_gri_1", "branch": "race", "name": "Warchanter's Roar", "cost": 1, "pos": Vector2(7, 6),
			"req": [], "race": "grimtusk", "effect": {"stat": {"dmg": 8, "hp": 60}}, "desc": "Grimtusk: +8 damage, +60 health — the warchant fills your blood."},
		{"id": "race_gri_2", "branch": "race", "name": "Tusk Breaker", "cost": 2, "pos": Vector2(7, 7),
			"req": ["race_gri_1"], "race": "grimtusk", "effect": {"stat": {"dmg": 14, "attack_speed": 0.12}}, "desc": "Grimtusk: +14 damage, +12% attack speed."},
		{"id": "race_gri_3", "branch": "race", "name": "Grimtusk Warlord", "cost": 3, "pos": Vector2(7, 8),
			"req": ["race_gri_2"], "race": "grimtusk", "keystone": true, "effect": {"stat": {"dmg": 20, "hp": 100}, "flag": {"cleave": true}},
			"desc": "Grimtusk KEYSTONE: +20 damage, +100 health, and cleaving strikes."},
		{"id": "race_gri_4", "branch": "race", "name": "Iron Fury", "cost": 2, "pos": Vector2(8, 6),
			"req": ["race_gri_1"], "race": "grimtusk", "effect": {"stat": {"dmg": 10, "armor": 2}}, "desc": "Grimtusk: +10 damage, +2 armor."},

		# --- Sylvan (elf — range, vision, speed) ---
		{"id": "race_syl_1", "branch": "race", "name": "Canopy Swift", "cost": 1, "pos": Vector2(7, 9),
			"req": [], "race": "sylvan", "effect": {"stat": {"speed": 0.8, "vision": 6}}, "desc": "Sylvan: +0.8 speed, +6 vision — the forest is your home."},
		{"id": "race_syl_2", "branch": "race", "name": "Elven Archery", "cost": 2, "pos": Vector2(7, 10),
			"req": ["race_syl_1"], "race": "sylvan", "effect": {"stat": {"range": 5, "attack_speed": 0.15}}, "desc": "Sylvan: +5 attack range, +15% attack speed."},
		{"id": "race_syl_3", "branch": "race", "name": "Ancient Sentinel", "cost": 3, "pos": Vector2(7, 11),
			"req": ["race_syl_2"], "race": "sylvan", "keystone": true, "effect": {"stat": {"range": 6, "vision": 10, "speed": 0.8}},
			"desc": "Sylvan KEYSTONE: +6 range, +10 vision, +0.8 speed — a peerless hunter."},
		{"id": "race_syl_4", "branch": "race", "name": "Moonlit Shot", "cost": 2, "pos": Vector2(8, 9),
			"req": ["race_syl_1"], "race": "sylvan", "effect": {"stat": {"range": 4, "dmg": 8}}, "desc": "Sylvan: +4 range, +8 damage under the moon's blessing."},

		# --- Karak (dwarf — armor, hp, build speed) ---
		{"id": "race_kar_1", "branch": "race", "name": "Stonecraft", "cost": 1, "pos": Vector2(7, 12),
			"req": [], "race": "karak", "effect": {"stat": {"hp": 100, "armor": 3}}, "desc": "Karak: +100 health, +3 armor — born of stone and iron."},
		{"id": "race_kar_2", "branch": "race", "name": "Rune-forged Plate", "cost": 2, "pos": Vector2(7, 13),
			"req": ["race_kar_1"], "race": "karak", "effect": {"stat": {"hp": 140, "armor": 4}}, "desc": "Karak: +140 health, +4 armor."},
		{"id": "race_kar_3", "branch": "race", "name": "Deepforge Master", "cost": 3, "pos": Vector2(7, 14),
			"req": ["race_kar_2"], "race": "karak", "keystone": true, "effect": {"stat": {"hp": 200, "armor": 6}, "flag": {"build_speed": 0.30}},
			"desc": "Karak KEYSTONE: +200 health, +6 armor, +30% build speed — master of the forge."},
		{"id": "race_kar_4", "branch": "race", "name": "Runekeeper", "cost": 2, "pos": Vector2(8, 12),
			"req": ["race_kar_1"], "race": "karak", "effect": {"stat": {"armor": 5}}, "desc": "Karak: +5 armor from runic wards."},

		# --- Sunspear (balanced — dmg, speed, vision) ---
		{"id": "race_sun_1", "branch": "race", "name": "Solar Warrior", "cost": 1, "pos": Vector2(7, 15),
			"req": [], "race": "sunspear", "effect": {"stat": {"dmg": 6, "speed": 0.5}}, "desc": "Sunspear: +6 damage, +0.5 speed — the sun empowers you."},
		{"id": "race_sun_2", "branch": "race", "name": "Sunbrand", "cost": 2, "pos": Vector2(7, 16),
			"req": ["race_sun_1"], "race": "sunspear", "effect": {"stat": {"dmg": 10, "vision": 6, "attack_speed": 0.10}}, "desc": "Sunspear: +10 damage, +6 vision, +10% attack speed."},
		{"id": "race_sun_3", "branch": "race", "name": "Radiant Champion", "cost": 3, "pos": Vector2(7, 17),
			"req": ["race_sun_2"], "race": "sunspear", "keystone": true, "effect": {"stat": {"dmg": 14, "speed": 0.8, "hp": 100, "vision": 8}},
			"desc": "Sunspear KEYSTONE: A radiant champion of the sun — balanced and powerful."},
		{"id": "race_sun_4", "branch": "race", "name": "Blazing Aura", "cost": 2, "pos": Vector2(8, 15),
			"req": ["race_sun_1"], "race": "sunspear", "effect": {"stat": {"aura_dmg": 4, "aura_range": 8}}, "desc": "Sunspear: +4 aura damage, +8 aura range."},

		# --- Wyldkin (beast — speed, attack speed, hp) ---
		{"id": "race_wyl_1", "branch": "race", "name": "Feral Grace", "cost": 1, "pos": Vector2(7, 18),
			"req": [], "race": "wyldkin", "effect": {"stat": {"speed": 1.0, "attack_speed": 0.10}}, "desc": "Wyldkin: +1.0 speed, +10% attack speed — the beast runs free."},
		{"id": "race_wyl_2", "branch": "race", "name": "Pack Hunter", "cost": 2, "pos": Vector2(7, 19),
			"req": ["race_wyl_1"], "race": "wyldkin", "effect": {"stat": {"speed": 0.8, "dmg": 8, "attack_speed": 0.12}}, "desc": "Wyldkin: +0.8 speed, +8 damage, +12% attack speed."},
		{"id": "race_wyl_3", "branch": "race", "name": "Alpha Predator", "cost": 3, "pos": Vector2(7, 20),
			"req": ["race_wyl_2"], "race": "wyldkin", "keystone": true, "effect": {"stat": {"speed": 1.5, "attack_speed": 0.20, "hp": 80, "dmg": 12}},
			"desc": "Wyldkin KEYSTONE: +1.5 speed, +20% attack speed, +80 health, +12 damage."},
		{"id": "race_wyl_4", "branch": "race", "name": "Wild Sprint", "cost": 2, "pos": Vector2(8, 18),
			"req": ["race_wyl_1"], "race": "wyldkin", "effect": {"stat": {"speed": 1.2}}, "desc": "Wyldkin: +1.2 movement speed — the wind is slow compared to you."},

		# --- Hollow (undead — lifesteal, hp, dmg) ---
		{"id": "race_hol_1", "branch": "race", "name": "Grave Hunger", "cost": 1, "pos": Vector2(7, 21),
			"req": [], "race": "hollow", "effect": {"stat": {"hp": 60, "dmg": 5}}, "desc": "Hollow: +60 health, +5 damage — the hunger drives you."},
		{"id": "race_hol_2", "branch": "race", "name": "Deathly Drain", "cost": 2, "pos": Vector2(7, 22),
			"req": ["race_hol_1"], "race": "hollow", "effect": {"flag": {"lifesteal": 0.15}, "stat": {"dmg": 8}}, "desc": "Hollow: 15% lifesteal and +8 damage from undying hunger."},
		{"id": "race_hol_3", "branch": "race", "name": "Undying Sovereign", "cost": 3, "pos": Vector2(7, 23),
			"req": ["race_hol_2"], "race": "hollow", "keystone": true, "effect": {"flag": {"lifesteal": 0.20, "last_stand": true}, "stat": {"hp": 120}},
			"desc": "Hollow KEYSTONE: 20% lifesteal, last-stand survival, +120 health."},
		{"id": "race_hol_4", "branch": "race", "name": "Soul Siphon", "cost": 2, "pos": Vector2(8, 21),
			"req": ["race_hol_1"], "race": "hollow", "effect": {"stat": {"hp": 80, "mana_regen": 2.0}}, "desc": "Hollow: +80 health, +2 mana regen from stolen life."},

		# --- Frostborn (frost — hp, dmg, regen) ---
		{"id": "race_fro_1", "branch": "race", "name": "Glacier Born", "cost": 1, "pos": Vector2(7, 24),
			"req": [], "race": "frostborn", "effect": {"stat": {"hp": 90, "armor": 2}}, "desc": "Frostborn: +90 health, +2 armor — the cold forges you."},
		{"id": "race_fro_2", "branch": "race", "name": "Permafrost Shield", "cost": 2, "pos": Vector2(7, 25),
			"req": ["race_fro_1"], "race": "frostborn", "effect": {"stat": {"hp": 120, "armor": 4}, "flag": {"regen": 4.0}}, "desc": "Frostborn: +120 health, +4 armor, +4 health regen."},
		{"id": "race_fro_3", "branch": "race", "name": "Blizzard Sovereign", "cost": 3, "pos": Vector2(7, 26),
			"req": ["race_fro_2"], "race": "frostborn", "keystone": true, "effect": {"stat": {"hp": 200, "dmg": 15, "armor": 5}, "flag": {"regen": 6.0}},
			"desc": "Frostborn KEYSTONE: +200 health, +15 damage, +5 armor, 6 regen/sec."},
		{"id": "race_fro_4", "branch": "race", "name": "Glacial Fury", "cost": 2, "pos": Vector2(8, 24),
			"req": ["race_fro_1"], "race": "frostborn", "effect": {"stat": {"dmg": 12, "attack_speed": 0.10}}, "desc": "Frostborn: +12 damage, +10% attack speed from frozen rage."},
	]

	return nodes

## Active ability data (referenced by ability id from nodes).
static func get_abilities() -> Dictionary:
	return {
		"rally":  {"name": "Rallying Cry", "mana": 40, "cd": 18.0, "range": 14.0, "desc": "Heal and hasten nearby allies."},
		"slam":   {"name": "Ground Slam", "mana": 45, "cd": 14.0, "range": 8.0, "dmg": 60, "desc": "Area damage and stun."},
		"charge": {"name": "War Charge", "mana": 30, "cd": 10.0, "range": 18.0, "dmg": 50, "desc": "Dash forward, damaging enemies hit."},
		"bolt":   {"name": "Lume Bolt", "mana": 25, "cd": 3.0, "range": 20.0, "dmg": 70, "desc": "Blast a target with Lume energy."},
		"heal":   {"name": "Heal Wave", "mana": 50, "cd": 16.0, "range": 14.0, "heal": 120, "desc": "Restore health to nearby allies."},
		"root":   {"name": "Entangling Roots", "mana": 40, "cd": 15.0, "range": 16.0, "desc": "Root enemies in an area."},
		"avatar": {"name": "Avatar of War", "mana": 100, "cd": 60.0, "range": 0.0, "desc": "Transform into an unstoppable champion."},
	}
