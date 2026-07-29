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
		"max_mana": 100.0, "mana_regen": 5.0, "heal_power": 0.0,
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

	# --- Mastery (endless, diminishing) ---
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
	# Diminishing returns: each rank slightly weaker (soft cap feel).
	var eff := 0.0
	for i in ranks:
		eff += 1.0 / (1.0 + float(i) * 0.15)
	match con:
		"warfare": out["bonus_dmg"] += eff * 2.0
		"fortitude": out["bonus_hp"] += eff * 20.0
		"celerity": out["bonus_speed"] += eff * 0.05; out["attack_speed"] += eff * 0.01
		"dominion": out["aura_dmg"] += eff * 0.5; out["aura_range"] += eff * 0.5
		"attunement": out["max_mana"] += eff * 10.0; out["mana_regen"] += eff * 0.3
		_: out["bonus_hp"] += eff * 8.0

static func _find(nid: String) -> Dictionary:
	for n in SkillDefs.get_tree():
		if n["id"] == nid:
			return n
	return {}

static func mastery_constellations() -> Array:
	return [
		{"id": "warfare", "name": "Warfare", "desc": "+damage per rank (diminishing)."},
		{"id": "fortitude", "name": "Fortitude", "desc": "+health per rank (diminishing)."},
		{"id": "celerity", "name": "Celerity", "desc": "+speed & attack speed per rank."},
		{"id": "dominion", "name": "Dominion", "desc": "+command aura per rank."},
		{"id": "attunement", "name": "Attunement", "desc": "+mana & regen per rank."},
	]
