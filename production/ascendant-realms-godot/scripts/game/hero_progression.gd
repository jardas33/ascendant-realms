class_name HeroProgression
## Turns a persistent hero profile (attributes + skills + equipment + mastery)
## into a concrete set of live combat stats and build flags for a battle.
## Pure calculation — no scene-tree state.

## Returns a dict:
##   base stats overrides + bonuses + flags + abilities{id:level} + auras
static func compute(hero: Dictionary) -> Dictionary:
	var out := {
		"bonus_hp": 0.0, "bonus_dmg": 0.0, "bonus_armor": 0.0, "bonus_speed": 0.0,
		"attack_speed": 0.0, "bonus_vision": 0.0, "bonus_range": 0.0,
		"max_mana": 100.0, "mana_regen": 5.0, "heal_power": 0.0, "spell_power": 0.0,
		"aura_dmg": 0.0, "aura_armor": 0.0, "aura_range": 0.0,
		"regen": 0.0,
		"flags": {}, "abilities": {},
	}
	if hero.is_empty():
		return out

	# --- Attributes ---
	var a: Dictionary = hero.get("attributes", {})
	out["bonus_hp"] += int(a.get("endurance", 0)) * 25.0
	out["bonus_hp"] += int(a.get("might", 0)) * 6.0
	out["bonus_dmg"] += int(a.get("might", 0)) * 3.0
	out["attack_speed"] += int(a.get("agility", 0)) * 0.03
	out["bonus_speed"] += int(a.get("agility", 0)) * 0.10
	out["max_mana"] += int(a.get("intellect", 0)) * 15.0
	out["bonus_dmg"] += int(a.get("intellect", 0)) * 2.0
	out["mana_regen"] += int(a.get("willpower", 0)) * 0.6
	out["bonus_armor"] += int(a.get("willpower", 0)) * 0.5
	out["aura_dmg"] += int(a.get("command", 0)) * 0.6
	out["aura_range"] += int(a.get("command", 0)) * 1.0
	# fortune -> handled as a flag bonus to loot/bounty

	# --- Skills ---
	for nid in hero.get("skills", []):
		var node := _find(nid)
		if node.is_empty():
			continue
		_apply_effect(out, node.get("effect", {}))

	# --- Equipment ---
	for slot in hero.get("equipment", {}):
		var item = hero["equipment"][slot]
		_apply_item(out, item)

	# --- Gear sets (LootDefs.SETS): 2 and 4 matching pieces ---
	var set_count := {}
	var set_level := {}
	for slot in hero.get("equipment", {}):
		var it: Dictionary = hero["equipment"][slot]
		var sid := String(it.get("set", ""))
		if sid == "":
			continue
		set_count[sid] = int(set_count.get(sid, 0)) + 1
		set_level[sid] = mini(int(set_level.get(sid, 99999)), int(it.get("item_level", 1)))
	for sid in set_count:
		var lvl := float(set_level[sid])
		if int(set_count[sid]) >= 2:
			match sid:
				"salto_oath": out["bonus_hp"] += 40.0 + lvl * 6.0
				"furna_ashglass": out["bonus_dmg"] += 3.0 + lvl * 0.6
				"moura_silver": out["max_mana"] += 30.0 + lvl * 4.0; out["mana_regen"] += 1.0 + lvl * 0.05
				"careto_masks": out["bonus_speed"] += 0.2 + sqrt(lvl) * 0.03; out["attack_speed"] += 0.03 + sqrt(lvl) * 0.004
				"tarasca_scale": out["bonus_armor"] += 2.0 + lvl * 0.08
				"old_wolf_pelt": out["bonus_speed"] += 0.2 + sqrt(lvl) * 0.03; out["bonus_dmg"] += 2.0 + lvl * 0.4
				"iron_abbot": out["regen"] += 2.0 + lvl * 0.1
				"moura_crown": out["spell_power"] += 0.1 + lvl * 0.004
		if int(set_count[sid]) >= 4:
			var four: Array = load("res://scripts/game/loot_defs.gd").SETS[sid]["four"]
			out["flags"][four[0]] = four[1]

	# Mana Font (legendary power): mana returns half again as fast.
	if out["flags"].has("mana_font"):
		out["mana_regen"] *= 1.5
	# Thornmail (legendary power) feeds the same reflection as Thornhide.
	if out["flags"].has("thornmail"):
		out["thorns"] = float(out.get("thorns", 0.0)) + float(out["flags"]["thornmail"])

	# --- Talents (TalentDefs): picked every tenth level, stacking forever ---
	var tal = hero.get("talents", {})
	if tal is Dictionary:
		for tid in tal:
			_apply_talent(out, String(tid), int(tal[tid]))

	# --- Mastery (endless, no ceiling) ---
	var ms: Dictionary = hero.get("mastery_spent", {})
	for con in ms:
		var ranks := int(ms[con])
		_apply_mastery(out, con, ranks)

	return out

static func _apply_effect(out: Dictionary, eff: Dictionary) -> void:
	if eff.has("stat"):
		for k in eff["stat"]:
			var v = eff["stat"][k]
			match k:
				"hp": out["bonus_hp"] += v
				"dmg": out["bonus_dmg"] += v
				"armor": out["bonus_armor"] += v
				"speed": out["bonus_speed"] += v
				"attack_speed": out["attack_speed"] += v
				"vision": out["bonus_vision"] += v
				"range": out["bonus_range"] += v
				"mana": out["max_mana"] += v
				"mana_regen": out["mana_regen"] += v
				"heal_power": out["heal_power"] += v
				"aura_dmg": out["aura_dmg"] += v
				"aura_armor": out["aura_armor"] += v
				"aura_range": out["aura_range"] += v
	if eff.has("flag"):
		for k in eff["flag"]:
			out["flags"][k] = eff["flag"][k]
			if k == "regen":
				out["regen"] += float(eff["flag"][k])
	if eff.has("ability"):
		var ab = eff["ability"]
		var id: String = ab["id"]
		var lvl := int(ab.get("level", 1))
		out["abilities"][id] = max(int(out["abilities"].get(id, 0)), lvl)

static func _apply_item(out: Dictionary, item: Dictionary) -> void:
	for k in item.get("stats", {}):
		var v = item["stats"][k]
		match k:
			"hp": out["bonus_hp"] += v
			"dmg": out["bonus_dmg"] += v
			"armor": out["bonus_armor"] += v
			"speed": out["bonus_speed"] += v
			"attack_speed": out["attack_speed"] += v
			"mana": out["max_mana"] += v
			"mana_regen": out["mana_regen"] += v
			"heal_power": out["heal_power"] += v
			"aura_dmg": out["aura_dmg"] += v
	for f in item.get("flags", {}):
		out["flags"][f] = item["flags"][f]

static func _apply_mastery(out: Dictionary, con: String, ranks: int) -> void:
	# Mastery never stops paying: gently sub-linear, but unbounded (the old
	# curve flattened into a soft cap, 100 ranks were worth about 13).
	var eff := pow(float(ranks), 0.9)
	match con:
		"warfare": out["bonus_dmg"] += eff * 2.0
		"fortitude": out["bonus_hp"] += eff * 20.0
		"celerity": out["bonus_speed"] += eff * 0.05; out["attack_speed"] += eff * 0.01
		"dominion": out["aura_dmg"] += eff * 0.5; out["aura_range"] += eff * 0.5
		"attunement": out["max_mana"] += eff * 10.0; out["mana_regen"] += eff * 0.3
		"lorecraft": out["spell_power"] += eff * 0.06
		_: out["bonus_hp"] += eff * 8.0

static func _apply_talent(out: Dictionary, id: String, ranks: int) -> void:
	var eff := pow(float(maxi(0, ranks)), 0.9)
	match id:
		"bloodthirst": out["flags"]["lifesteal"] = float(out["flags"].get("lifesteal", 0.0)) + eff * 0.02
		"executioner": out["execute_bonus"] = float(out.get("execute_bonus", 0.0)) + eff * 0.12
		"thorns": out["thorns"] = float(out.get("thorns", 0.0)) + eff * 0.06
		"giants_blood": out["hp_mult"] = float(out.get("hp_mult", 0.0)) + eff * 0.06
		"swift_blade": out["attack_speed"] += eff * 0.03
		"warlord": out["aura_dmg"] += eff * 0.8; out["aura_armor"] += eff * 0.4
		"stormcaller": out["spell_power"] += eff * 0.08
		"iron_will": out["bonus_armor"] += eff * 1.0
		"lume_well": out["max_mana"] += eff * 20.0; out["mana_regen"] += eff * 0.5
		"rallying_cry": out["aura_range"] += eff * 2.0
		"second_wind": out["regen"] += eff * 1.5
		"keen_eye": out["bonus_vision"] += eff * 3.0
		# quartermaster (retinue) and treasure_hunter (loot) are read where
		# those systems live.

## One number to watch grow: damage output times survivability.
static func power(hero: Dictionary) -> int:
	var b := compute(hero)
	var hero_def: Dictionary = GameData.get_unit(String(GameData.get_race(String(hero.get("race", "barrosan"))).get("hero", "")))
	var dmg := float(hero_def.get("dmg", 30)) + float(b.get("bonus_dmg", 0))
	var hp := (float(hero_def.get("hp", 400)) + float(b.get("bonus_hp", 0))) * (1.0 + float(b.get("hp_mult", 0.0)))
	var armor := float(hero_def.get("armor", 3)) + float(b.get("bonus_armor", 0))
	var dps := dmg * (1.0 + float(b.get("attack_speed", 0))) / maxf(0.35, float(hero_def.get("attack_cd", 1.1)))
	return int(sqrt(dps * hp * (1.0 + armor * 0.06)))

static func _find(nid: String) -> Dictionary:
	for n in SkillDefs.get_tree():
		if n["id"] == nid:
			return n
	return {}

static func mastery_constellations() -> Array:
	return [
		{"id": "warfare", "name": "Warfare", "desc": "+damage per rank, forever."},
		{"id": "fortitude", "name": "Fortitude", "desc": "+health per rank, forever."},
		{"id": "celerity", "name": "Celerity", "desc": "+speed & attack speed per rank."},
		{"id": "dominion", "name": "Dominion", "desc": "+command aura per rank."},
		{"id": "attunement", "name": "Attunement", "desc": "+mana & regen per rank."},
		{"id": "lorecraft", "name": "Lorecraft", "desc": "+spell power per rank, forever."},
	]
