extends Node
## ProfileManager — persistent hero, progression, settings and campaign state.
## Versioned save with migration. This is the RPG spine that survives between battles.
const CampaignDefs := preload("res://scripts/game/campaign_defs.gd")

const SAVE_PATH := "user://ascendant_save.json"
const SAVE_TEMP_PATH := "user://ascendant_save.json.tmp"
## A rolling copy of the last good save. A corrupted save used to fall back
## to a blank profile and overwrite the file, losing the hero for good.
const SAVE_BACKUP_PATH := "user://ascendant_save.backup.json"
var _last_backup_msec := -1000000
## 2: talents, Endless Road records, Tyrant sets (2026-09-28).
const SAVE_VERSION := 2

signal profile_changed
signal hero_created

# Attribute base values
const ATTRIBUTES := ["might", "endurance", "agility", "intellect", "willpower", "command", "fortune"]

var data := {}

func _ready() -> void:
	load_game()
	# The player's own battle keys (Settings) over the shipped ones.
	var saved_keys = settings().get("keybinds", {})
	load("res://scripts/game/key_binds.gd").apply(saved_keys if saved_keys is Dictionary else {})

# --------------------------------------------------------------------------
func _default_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"hero": {},                      # empty until created
		"settings": _default_settings(),
		"campaign": {"node": 0, "wins": 0, "unlocked": [0]},
		"stats": {"battles": 0, "victories": 0, "units_killed": 0},
	}

func _default_settings() -> Dictionary:
	return {
		"music_vol": 0.7, "sfx_vol": 0.8,
		"edge_scroll": true, "camera_speed": 1.0, "zoom_sens": 1.0,
		"reduce_shake": false, "reduce_flash": false,
		"display_mode": "windowed", "vsync": true, "graphics": "high",
		"colorblind": false,
	}

func has_hero() -> bool:
	return data.has("hero") and not data["hero"].is_empty() and data["hero"].has("name")

func create_hero(hero_name: String, race: String, archetype: String,
		appearance: int, strength: String, weakness: String, attrs: Dictionary, unspent_points: int = 0) -> void:
	data["hero"] = {
		"name": hero_name,
		"race": race,
		"archetype": archetype,
		"appearance": appearance,
		"strength": strength,
		"weakness": weakness,
		"level": 1,
		"xp": 0.0,
		"skill_points": 1,
		# Points left unspent at the forge are kept for the hero sheet
		# (they used to be thrown away without a word).
		"attr_points": maxi(0, unspent_points),
		"attributes": attrs.duplicate(),
		"skills": [],                    # unlocked skill node ids
		"mastery": 0,                    # endless mastery level
		"mastery_points": 0,
		"mastery_spent": {},             # mastery constellation id -> ranks
		"inventory": [],                 # item dicts
		"equipment": {},                 # slot -> item dict
		"loadouts": [],                  # saved skill/gear presets
		"history": [],
	}
	emit_signal("hero_created")
	emit_signal("profile_changed")
	save_game()

func hero() -> Dictionary:
	return data.get("hero", {})

func settings() -> Dictionary:
	return data.get("settings", _default_settings())

func campaign() -> Dictionary:
	# Self-healing: ensure "campaign" key exists with all required inner keys,
	# and that node 0 is always in the unlocked array.
	if not data.has("campaign") or typeof(data["campaign"]) != TYPE_DICTIONARY:
		data["campaign"] = {"node": 0, "wins": 0, "unlocked": [0]}
		save_game()
	var c: Dictionary = data["campaign"]
	# Ensure all inner keys exist
	if not c.has("node"):
		c["node"] = 0
	if not c.has("wins"):
		c["wins"] = 0
	if not c.has("unlocked") or typeof(c["unlocked"]) != TYPE_ARRAY:
		c["unlocked"] = [0]
	# Node 0 is ALWAYS unlocked — heal old saves silently. JSON reads numbers
	# back as floats, and 0 is not "in" [0.0], so every load appended another
	# 0 (one save had grown to 445 entries). Keep the list as unique ints.
	var clean: Array = []
	for v in c["unlocked"]:
		if typeof(v) in [TYPE_INT, TYPE_FLOAT] and not clean.has(int(v)):
			clean.append(int(v))
	if not clean.has(0):
		clean.append(0)
	if clean.size() != (c["unlocked"] as Array).size():
		c["unlocked"] = clean
		save_game()
	else:
		c["unlocked"] = clean
	return c

## Saga progress (CampaignDefs chapters by id): unlocked and cleared
## chapters, jars of Wine of the Dead found, and the Rabagão Wall choice.
func saga() -> Dictionary:
	var c := campaign()
	if not c.has("saga") or typeof(c["saga"]) != TYPE_DICTIONARY:
		c["saga"] = {"unlocked": ["1-1"], "cleared": [], "jars": [], "choice": ""}
		# Carry old Border Marches progress over: each battle won there clears
		# the matching main-road chapter of Act I.
		var migrated: Dictionary = c["saga"]
		var main_road := ["1-1", "1-2", "1-3", "1-4", "1-5", "1-6"]
		for i in mini(int(c.get("node", 0)), main_road.size()):
			var id: String = main_road[i]
			migrated["cleared"].append(id)
			for next in CampaignDefs.find(id).get("unlocks", []):
				if not (String(next) in migrated["unlocked"]):
					migrated["unlocked"].append(String(next))
	var s: Dictionary = c["saga"]
	for key in ["unlocked", "cleared", "jars"]:
		if not s.has(key) or typeof(s[key]) != TYPE_ARRAY:
			s[key] = []
	if not s.has("choice"):
		s["choice"] = ""
	if not s.has("heroic") or typeof(s["heroic"]) != TYPE_ARRAY:
		s["heroic"] = []
	if not s.has("retinue") or typeof(s["retinue"]) != TYPE_ARRAY:
		s["retinue"] = []
	if not ("1-1" in s["unlocked"]):
		s["unlocked"].append("1-1")
	return s

func complete_chapter(id: String) -> void:
	var s := saga()
	var chapter := CampaignDefs.find(id)
	if chapter.is_empty():
		return
	if not (id in s["cleared"]):
		s["cleared"].append(id)
		# The campaign map stamps this seal when it next opens (not saved).
		Match.set_meta("fresh_seal", id)
	# A Heroic Replay win earns the chapter its laurel.
	if bool(Match.get_config().get("campaign_heroic", false)) and String(Match.get_config().get("campaign_chapter", "")) == id and not (id in s["heroic"]):
		s["heroic"].append(id)
	if bool(chapter.get("jar", false)) and not (id in s["jars"]):
		s["jars"].append(id)
	if chapter.has("branch"):
		s["choice"] = String(chapter["branch"])
	# A side road's relic, once.
	if not s.has("relics"):
		s["relics"] = []
	if CampaignDefs.RELICS.has(id) and not (id in s["relics"]) and has_hero():
		s["relics"].append(id)
		add_item(CampaignDefs.RELICS[id].duplicate(true))
		s["last_relic"] = String(CampaignDefs.RELICS[id]["name"])
	else:
		s["last_relic"] = ""
	for next in chapter.get("unlocks", []):
		if not (String(next) in s["unlocked"]):
			s["unlocked"].append(String(next))
	# The campaign map opens the next chronicle straight away after a win.
	s["auto_brief"] = true
	var c := campaign()
	c["wins"] = int(c.get("wins", 0)) + 1
	emit_signal("profile_changed")
	save_game()

## A chapter can be played if it is unlocked and not sealed by the choice.
func chapter_available(id: String) -> bool:
	var s := saga()
	if not (id in s["unlocked"]):
		return false
	var chapter := CampaignDefs.find(id)
	if chapter.has("branch") and String(s["choice"]) != "" and String(s["choice"]) != String(chapter["branch"]):
		return false
	return true

# --- XP / leveling (endless) ----------------------------------------------
func xp_for_level(level: int) -> float:
	# Smooth escalating curve; never caps.
	return 100.0 + float(level - 1) * 60.0 + pow(float(level), 1.7) * 4.0

func add_xp(amount: float) -> Dictionary:
	if not has_hero():
		return {"levels": 0}
	var h = data["hero"]
	h["xp"] = float(h.get("xp", 0.0)) + amount
	var gained := 0
	var learnable := learnable_points(h)
	while true:
		var lvl = int(h["level"])
		var need = xp_for_level(lvl)
		if h["xp"] >= need:
			h["xp"] -= need
			h["level"] = lvl + 1
			gained += 1
			# Before finishing the tree: skill points. After: mastery points.
			if _potential_points(h) < learnable:
				h["skill_points"] = int(h.get("skill_points", 0)) + 1
			else:
				h["mastery"] = int(h.get("mastery", 0)) + 1
				h["mastery_points"] = int(h.get("mastery_points", 0)) + 1
			# Attribute point every 2 levels
			if (lvl + 1) % 2 == 0:
				h["attr_points"] = int(h.get("attr_points", 0)) + 1
		else:
			break
	if gained > 0:
		emit_signal("profile_changed")
		save_game()
	return {"levels": gained}

## The skill points this hero can ever spend: every node of the tree except
## the other peoples' own. The whole tree used to be counted, but a hero can
## never learn another people's nodes, so dozens of levels paid a skill point
## with nothing to buy and no mastery either.
func learnable_points(h: Dictionary) -> int:
	var total := 0
	var race := String(h.get("race", ""))
	for n in SkillDefs.get_tree():
		if n.has("race") and String(n["race"]) != race:
			continue
		total += int(n.get("cost", 1))
	return total

## Skill points beyond what the tree can take become mastery (heroes saved
## before the fix above may hold some).
func _settle_surplus_skill_points(h: Dictionary) -> void:
	var surplus := mini(_potential_points(h) - learnable_points(h), int(h.get("skill_points", 0)))
	if surplus <= 0:
		return
	h["skill_points"] = int(h["skill_points"]) - surplus
	h["mastery"] = int(h.get("mastery", 0)) + surplus
	h["mastery_points"] = int(h.get("mastery_points", 0)) + surplus

func _potential_points(h: Dictionary) -> int:
	# total points a hero could have earned == spent + available (skill only)
	var spent := 0
	for nid in h.get("skills", []):
		for n in SkillDefs.get_tree():
			if n["id"] == nid:
				spent += int(n.get("cost", 1))
	return spent + int(h.get("skill_points", 0))

# --- skills ---------------------------------------------------------------
func unlock_skill(node_id: String) -> bool:
	if not has_hero():
		return false
	var h = data["hero"]
	if node_id in h.get("skills", []):
		return false
	var node := _find_node(node_id)
	if node.is_empty():
		return false
	# race gate
	if node.has("race") and node["race"] != h.get("race", ""):
		return false
	# prereqs
	for r in node.get("req", []):
		if not (r in h["skills"]):
			return false
	var cost := int(node.get("cost", 1))
	if int(h.get("skill_points", 0)) < cost:
		return false
	h["skill_points"] = int(h["skill_points"]) - cost
	h["skills"].append(node_id)
	emit_signal("profile_changed")
	save_game()
	return true

## Free mastery respec: every spent mastery point comes back to spend again.
func respec_mastery() -> void:
	if not has_hero():
		return
	var h = data["hero"]
	var back := 0
	for k in h.get("mastery_spent", {}):
		back += int(h["mastery_spent"][k])
	h["mastery_spent"] = {}
	h["mastery_points"] = int(h.get("mastery_points", 0)) + back
	emit_signal("profile_changed")
	save_game()

func respec_skills() -> void:
	if not has_hero():
		return
	var h = data["hero"]
	var refunded := 0
	for nid in h.get("skills", []):
		var node := _find_node(nid)
		refunded += int(node.get("cost", 1))
	h["skills"] = []
	h["skill_points"] = int(h.get("skill_points", 0)) + refunded
	emit_signal("profile_changed")
	save_game()

func spend_attribute(attr: String) -> bool:
	if not has_hero():
		return false
	var h = data["hero"]
	if int(h.get("attr_points", 0)) <= 0:
		return false
	if not (attr in ATTRIBUTES):
		return false
	h["attr_points"] = int(h["attr_points"]) - 1
	h["attributes"][attr] = int(h["attributes"].get(attr, 0)) + 1
	emit_signal("profile_changed")
	save_game()
	return true

func spend_mastery(constellation: String) -> bool:
	if not has_hero():
		return false
	var h = data["hero"]
	if int(h.get("mastery_points", 0)) <= 0:
		return false
	h["mastery_points"] = int(h["mastery_points"]) - 1
	var ms = h.get("mastery_spent", {})
	ms[constellation] = int(ms.get(constellation, 0)) + 1
	h["mastery_spent"] = ms
	emit_signal("profile_changed")
	save_game()
	return true

# --- talents (TalentDefs): a choice of three every tenth level, forever ---
const TalentDefs := preload("res://scripts/game/talent_defs.gd")

func talents_taken() -> int:
	if not has_hero():
		return 0
	var n := 0
	var t = hero().get("talents", {})
	if t is Dictionary:
		for k in t:
			n += int(t[k])
	return n

## Unspent talent picks. Derived from the level, so old saves get theirs.
func talent_points() -> int:
	if not has_hero():
		return 0
	return maxi(0, TalentDefs.earned(int(hero().get("level", 1))) - talents_taken())

func talent_offer() -> Array:
	return TalentDefs.offer(talents_taken())

## Free talent reset: picks are derived from the level, so they all return.
## The offers start again from the first pick.
func respec_talents() -> void:
	if not has_hero():
		return
	data["hero"]["talents"] = {}
	emit_signal("profile_changed")
	save_game()

func pick_talent(id: String) -> bool:
	if talent_points() <= 0 or not (id in talent_offer()):
		return false
	var h = data["hero"]
	var t = h.get("talents", {})
	if not t is Dictionary:
		t = {}
	t[id] = int(t.get(id, 0)) + 1
	h["talents"] = t
	emit_signal("profile_changed")
	save_game()
	return true

func _find_node(node_id: String) -> Dictionary:
	for n in SkillDefs.get_tree():
		if n["id"] == node_id:
			return n
	return {}

# --- items ----------------------------------------------------------------
func add_item(item: Dictionary) -> void:
	if not has_hero():
		return
	if String(item.get("rarity", "")) == "legendary":
		data["stats"]["legendary_found"] = int(data["stats"].get("legendary_found", 0)) + 1
	data["hero"]["inventory"].append(item)
	emit_signal("profile_changed")
	save_game()

## Melt an item from the chest into hero experience (LootDefs.salvage_xp).
func salvage_item(item: Dictionary) -> float:
	if not has_hero():
		return 0.0
	var inv: Array = data["hero"]["inventory"]
	var idx := inv.find(item)
	if idx < 0:
		return 0.0
	inv.remove_at(idx)
	var xp: float = load("res://scripts/game/loot_defs.gd").salvage_xp(item)
	add_xp(xp)
	emit_signal("profile_changed")
	save_game()
	return xp

## Salvage every chest item of the given rarities in one go.
func salvage_rarities(rarities: Array) -> Dictionary:
	if not has_hero():
		return {"count": 0, "xp": 0.0}
	var inv: Array = data["hero"]["inventory"]
	var keep: Array = []
	var xp := 0.0
	var n := 0
	var loot = load("res://scripts/game/loot_defs.gd")
	for it in inv:
		if String(it.get("rarity", "common")) in rarities and not bool(it.get("locked", false)):
			xp += loot.salvage_xp(it)
			n += 1
		else:
			keep.append(it)
	data["hero"]["inventory"] = keep
	if xp > 0.0:
		add_xp(xp)
	emit_signal("profile_changed")
	save_game()
	return {"count": n, "xp": xp}

## Gear score for "Equip Best": item level times rarity power, plus a
## legendary power or set piece counts a little extra.
func item_score(item: Dictionary) -> float:
	var power := {"common": 1.0, "uncommon": 1.3, "rare": 1.7, "epic": 2.2, "legendary": 3.0}
	var lvl := float(item.get("item_level", 0))
	if lvl <= 0.0:
		lvl = 0.0
		for k in item.get("stats", {}):
			lvl += absf(float(item["stats"][k]))
		lvl = lvl / 10.0
	return lvl * float(power.get(String(item.get("rarity", "common")), 1.0)) * (1.15 if not (item.get("flags", {}) as Dictionary).is_empty() else 1.0)

func equip_best() -> void:
	if not has_hero():
		return
	var h = data["hero"]
	var best := {}
	for it in h.get("inventory", []):
		var slot := String(it.get("slot", ""))
		if slot == "":
			continue
		var cur = h.get("equipment", {}).get(slot, null)
		var bar: float = item_score(cur) if cur != null else -1.0
		if best.has(slot):
			bar = maxf(bar, item_score(best[slot]))
		if item_score(it) > bar:
			best[slot] = it
	for slot in best:
		equip_item(best[slot])

func equip_item(item: Dictionary) -> void:
	if not has_hero():
		return
	var h = data["hero"]
	var slot: String = item.get("slot", "")
	if slot == "":
		return
	# move currently equipped back to inventory
	if h["equipment"].has(slot):
		h["inventory"].append(h["equipment"][slot])
	h["equipment"][slot] = item
	h["inventory"].erase(item)
	emit_signal("profile_changed")
	save_game()

func unequip_slot(slot: String) -> void:
	if not has_hero():
		return
	var h = data["hero"]
	if h["equipment"].has(slot):
		h["inventory"].append(h["equipment"][slot])
		h["equipment"].erase(slot)
		emit_signal("profile_changed")
		save_game()

# --- campaign / stats -----------------------------------------------------
## Deeds (AchievementDefs): checks every track, grants new tiers (a mastery
## point each) and returns them for the result ledger.
func check_achievements() -> Array:
	if not has_hero():
		return []
	var h: Dictionary = data["hero"]
	if not h.has("deeds") or typeof(h["deeds"]) != TYPE_DICTIONARY:
		h["deeds"] = {}
	var st: Dictionary = data.get("stats", {})
	var sg := saga()
	var values := {
		"victories": int(st.get("victories", 0)), "units_killed": int(st.get("units_killed", 0)),
		"endless_best": int(sg.get("endless_best", 0)), "saga_cleared": sg["cleared"].size(),
		"heroic_laurels": sg.get("heroic", []).size(), "legendary_found": int(st.get("legendary_found", 0)),
		"tyrants_slain": int(st.get("tyrants_slain", 0)), "elites_slain": int(st.get("elites_slain", 0)), "jars_dug": int(st.get("jars_dug", 0)),
	}
	var defs = load("res://scripts/game/achievement_defs.gd")
	var earned: Array = []
	for t in defs.TRACKS:
		var tier := int(h["deeds"].get(t["id"], 0))
		while int(values.get(t["stat"], 0)) >= defs.goal(t, tier + 1):
			tier += 1
			h["mastery"] = int(h.get("mastery", 0)) + 1
			h["mastery_points"] = int(h.get("mastery_points", 0)) + 1
			earned.append({"track": String(t["name"]), "title": defs.title(t, tier)})
		h["deeds"][t["id"]] = tier
	if not earned.is_empty():
		h["title"] = String(earned[earned.size() - 1]["title"])
		emit_signal("profile_changed")
		save_game()
	return earned

func record_battle(won: bool, kills: int, xp: float) -> void:
	data["stats"]["battles"] = int(data["stats"].get("battles", 0)) + 1
	data["stats"]["units_killed"] = int(data["stats"].get("units_killed", 0)) + kills
	if won:
		data["stats"]["victories"] = int(data["stats"].get("victories", 0)) + 1
	add_xp(xp)
	save_game()

func advance_campaign(node_index: int) -> void:
	var c = data["campaign"]
	c["wins"] = int(c.get("wins", 0)) + 1
	var nxt = node_index + 1
	if not (nxt in c.get("unlocked", [])):
		c["unlocked"].append(nxt)
	c["node"] = nxt
	emit_signal("profile_changed")
	save_game()

# --- persistence ----------------------------------------------------------
func save_game() -> void:
	var serialized := JSON.stringify(data, "  ")
	var f := FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
	if not f:
		push_error("SAVE_TEMP_OPEN_FAILED: %s" % error_string(FileAccess.get_open_error()))
		return
	f.store_string(serialized)
	f.flush()
	var write_error := f.get_error()
	f.close()
	if write_error != OK:
		push_error("SAVE_TEMP_WRITE_FAILED: %s" % error_string(write_error))
		return
	if FileAccess.file_exists(SAVE_PATH) and Time.get_ticks_msec() - _last_backup_msec > 120000:
		_last_backup_msec = Time.get_ticks_msec()
		DirAccess.copy_absolute(ProjectSettings.globalize_path(SAVE_PATH), ProjectSettings.globalize_path(SAVE_BACKUP_PATH))
	var replace_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(SAVE_TEMP_PATH),
		ProjectSettings.globalize_path(SAVE_PATH))
	if replace_error != OK:
		push_error("SAVE_REPLACE_FAILED: %s" % error_string(replace_error))
		return

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		data = _default_data()
		save_game()
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		data = _default_data()
		return
	var txt := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY and FileAccess.file_exists(SAVE_BACKUP_PATH):
		push_warning("SAVE_CORRUPT_RESTORING_BACKUP")
		parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_BACKUP_PATH))
		if typeof(parsed) == TYPE_DICTIONARY:
			data = _normalize_profile(_migrate(parsed))
			save_game()
			emit_signal("profile_changed")
			return
	if typeof(parsed) != TYPE_DICTIONARY:
		data = _default_data()
		# Recover through the existing atomic save path so a valid default is not
		# left only in memory after a usable-but-wrong JSON root is encountered.
		save_game()
		return
	# Before a save written by an older version is migrated, keep a copy of
	# it exactly as it was, so an upgrade can never cost a hero.
	var old_version := int(parsed.get("version", 0))
	if old_version < SAVE_VERSION:
		var keep := "user://ascendant_save.v%d.backup.json" % old_version
		if not FileAccess.file_exists(keep):
			DirAccess.copy_absolute(ProjectSettings.globalize_path(SAVE_PATH), ProjectSettings.globalize_path(keep))
	data = _normalize_profile(_migrate(parsed))
	emit_signal("profile_changed")

func _normalize_profile(d: Dictionary) -> Dictionary:
	var defaults := _default_data()
	for key in ["settings", "campaign", "stats"]:
		if typeof(d.get(key)) != TYPE_DICTIONARY:
			d[key] = defaults[key].duplicate(true)
	if typeof(d.get("hero")) != TYPE_DICTIONARY:
		d["hero"] = {}
	var h: Dictionary = d["hero"]
	if not h.is_empty():
		var hero_defaults := {"name":"Hero", "race":"barrosan", "archetype":"Warrior", "appearance":0,
			"strength":"", "weakness":"", "level":1, "xp":0.0, "skill_points":0, "attr_points":0,
			"attributes":{}, "skills":[], "mastery":0, "mastery_points":0, "mastery_spent":{},
			"inventory":[], "equipment":{}, "loadouts":[], "history":[]}
		for key in hero_defaults:
			if not h.has(key): h[key] = hero_defaults[key]
		if typeof(h.get("attributes")) != TYPE_DICTIONARY: h["attributes"] = {}
		if typeof(h.get("skills")) != TYPE_ARRAY: h["skills"] = []
		if typeof(h.get("mastery_spent")) != TYPE_DICTIONARY: h["mastery_spent"] = {}
		if typeof(h.get("inventory")) != TYPE_ARRAY: h["inventory"] = []
		if typeof(h.get("equipment")) != TYPE_DICTIONARY: h["equipment"] = {}
		if typeof(h.get("loadouts")) != TYPE_ARRAY: h["loadouts"] = []
		if typeof(h.get("history")) != TYPE_ARRAY: h["history"] = []
		if h.has("talents") and typeof(h.get("talents")) != TYPE_DICTIONARY: h["talents"] = {}
		if typeof(h.get("name")) != TYPE_STRING or String(h["name"]).strip_edges() == "": h["name"] = "Hero"
		if typeof(h.get("race")) != TYPE_STRING or not GameData.RACES.has(String(h["race"])): h["race"] = "barrosan"
		if typeof(h.get("archetype")) != TYPE_STRING or not ["Warrior", "Commander", "Ranger", "Mage", "Summoner"].has(String(h["archetype"])): h["archetype"] = "Warrior"
		for key in ["level", "skill_points", "attr_points", "mastery", "mastery_points"]:
			if typeof(h.get(key)) not in [TYPE_INT, TYPE_FLOAT] or int(h[key]) < 0: h[key] = hero_defaults[key]
		for key in ["xp"]:
			if typeof(h.get(key)) not in [TYPE_INT, TYPE_FLOAT] or float(h[key]) < 0.0: h[key] = hero_defaults[key]
		for key in ATTRIBUTES:
			if typeof(h["attributes"].get(key, 0)) not in [TYPE_INT, TYPE_FLOAT] or int(h["attributes"].get(key, 0)) < 0: h["attributes"][key] = 0
		_settle_surplus_skill_points(h)
	if typeof(d["stats"].get("battles", 0)) not in [TYPE_INT, TYPE_FLOAT] or int(d["stats"].get("battles", 0)) < 0: d["stats"]["battles"] = 0
	if typeof(d["stats"].get("victories", 0)) not in [TYPE_INT, TYPE_FLOAT] or int(d["stats"].get("victories", 0)) < 0: d["stats"]["victories"] = 0
	if typeof(d["stats"].get("units_killed", 0)) not in [TYPE_INT, TYPE_FLOAT] or int(d["stats"].get("units_killed", 0)) < 0: d["stats"]["units_killed"] = 0
	var settings_defaults := _default_settings()
	for key in settings_defaults:
		var value = d["settings"].get(key, settings_defaults[key])
		if typeof(value) != typeof(settings_defaults[key]):
			d["settings"][key] = settings_defaults[key]
	if not ["windowed", "fullscreen"].has(String(d["settings"].get("display_mode", "windowed"))):
		d["settings"]["display_mode"] = settings_defaults["display_mode"]
	for key in ["music_vol", "sfx_vol", "camera_speed", "zoom_sens"]:
		var numeric = float(d["settings"].get(key, settings_defaults[key]))
		if numeric < 0.0: d["settings"][key] = settings_defaults[key]
	for key in ["node", "wins"]:
		if typeof(d["campaign"].get(key, 0)) not in [TYPE_INT, TYPE_FLOAT] or int(d["campaign"].get(key, 0)) < 0:
			d["campaign"][key] = 0
	return d

func _migrate(d: Dictionary) -> Dictionary:
	# Fill in any missing top-level keys against defaults; never wipe existing hero.
	var base := _default_data()
	for k in base:
		if not d.has(k):
			d[k] = base[k]
	if not d.has("version"):
		d["version"] = SAVE_VERSION
	# Ensure settings completeness
	var ds := _default_settings()
	if typeof(d.get("settings")) != TYPE_DICTIONARY:
		d["settings"] = ds.duplicate(true)
	for k in ds:
		if not d["settings"].has(k):
			d["settings"][k] = ds[k]
	# Ensure campaign inner keys are complete (heals old saves missing them)
	if typeof(d.get("campaign")) != TYPE_DICTIONARY:
		d["campaign"] = {"node": 0, "wins": 0, "unlocked": [0]}
	else:
		var c: Dictionary = d["campaign"]
		if not c.has("node"):
			c["node"] = 0
		if not c.has("wins"):
			c["wins"] = 0
		if not c.has("unlocked") or typeof(c["unlocked"]) != TYPE_ARRAY:
			c["unlocked"] = [0]
		else:
			# Unique ints: JSON floats never matched 0 and the list grew each load.
			var clean: Array = []
			for v in c["unlocked"]:
				if typeof(v) in [TYPE_INT, TYPE_FLOAT] and not clean.has(int(v)):
					clean.append(int(v))
			if not clean.has(0):
				clean.append(0)
			c["unlocked"] = clean
	d["version"] = SAVE_VERSION
	return d

func wipe_hero() -> void:
	data["hero"] = {}
	emit_signal("profile_changed")
	save_game()

func update_setting(key: String, value) -> void:
	data["settings"][key] = value
	save_game()

## The Endless Road: the deepest stage won (0 before the first).
func endless_best() -> int:
	return int(saga().get("endless_best", 0))

## Endless Road records: the deepest stage won with each faction, and the
## fastest clear of every stage (in game seconds). Kept for later online boards.
func endless_fastest_key(key: String) -> float:
	var rec = saga().get("endless_records", {})
	return float((rec.get("fastest", {}) as Dictionary).get(key, 0.0)) if rec is Dictionary else 0.0

func endless_record(depth: int, race: String, seconds: float, key_override: String = "") -> Dictionary:
	var s := saga()
	var rec = s.get("endless_records", {})
	if not rec is Dictionary:
		rec = {}
	var best_by_race = rec.get("best_by_race", {})
	var fastest = rec.get("fastest", {})
	var out := {"new_race_best": false, "new_fastest": false}
	if key_override == "" and depth > int(best_by_race.get(race, 0)):
		best_by_race[race] = depth
		out["new_race_best"] = true
	var key := str(depth) if key_override == "" else key_override
	if seconds > 0.0 and (not fastest.has(key) or seconds < float(fastest[key])):
		fastest[key] = snappedf(seconds, 0.1)
		out["new_fastest"] = true
	rec["best_by_race"] = best_by_race
	rec["fastest"] = fastest
	s["endless_records"] = rec
	return out

func endless_best_for(race: String) -> int:
	var rec = saga().get("endless_records", {})
	return int((rec.get("best_by_race", {}) as Dictionary).get(race, 0)) if rec is Dictionary else 0

func endless_fastest(depth: int) -> float:
	var rec = saga().get("endless_records", {})
	return float((rec.get("fastest", {}) as Dictionary).get(str(depth), 0.0)) if rec is Dictionary else 0.0

func endless_won(depth: int) -> void:
	var s := saga()
	s["last_relic"] = ""
	if depth > int(s.get("endless_best", 0)):
		s["endless_best"] = depth
		# Every fifth stage forges a relic, the first time it is won.
		if depth % 5 == 0 and has_hero():
			var item: Dictionary = load("res://scripts/game/endless_defs.gd").relic(depth)
			add_item(item)
			s["last_relic"] = String(item["name"])
		# Every 25th stage: a guaranteed legendary, forged at the stage's depth.
		if depth % 25 == 0 and has_hero():
			var rng := RandomNumberGenerator.new()
			rng.seed = depth * 2654435
			var legend: Dictionary = {}
			for attempt in 50:
				legend = load("res://scripts/game/loot_defs.gd").make_item(rng, int(hero().get("level", 1)) + depth, 3.0)
				if String(legend["rarity"]) == "legendary":
					break
			legend["rarity"] = "legendary"
			add_item(legend)
			s["last_relic"] = String(s.get("last_relic", "")) + ("  ·  " if String(s.get("last_relic", "")) != "" else "") + String(legend["name"]) + " (milestone)"
	save_game()

## How many veterans may march with the Jardas: 2, plus one every 6 hero
## levels, with no ceiling.
func retinue_cap() -> int:
	if not has_hero():
		return 0
	return 2 + int(hero().get("level", 1)) / 6 + int((hero().get("talents", {}) as Dictionary).get("quartermaster", 0))
