extends Node
## ProfileManager — persistent hero, progression, settings and campaign state.
## Versioned save with migration. This is the RPG spine that survives between battles.

const SAVE_PATH := "user://ascendant_save.json"
const SAVE_TEMP_PATH := "user://ascendant_save.json.tmp"
const SAVE_VERSION := 1

signal profile_changed
signal hero_created

# Attribute base values
const ATTRIBUTES := ["might", "endurance", "agility", "intellect", "willpower", "command", "fortune"]

var data := {}

func _ready() -> void:
	load_game()

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
		"colorblind": false, "ui_scale": 1.0, "game_speed": 1.0,
	}

func has_hero() -> bool:
	return data.has("hero") and not data["hero"].is_empty() and data["hero"].has("name")

func create_hero(hero_name: String, race: String, archetype: String,
		appearance: int, strength: String, weakness: String, attrs: Dictionary) -> void:
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
		"attr_points": 0,
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
	# Node 0 is ALWAYS unlocked — heal old saves silently
	if not (0 in c["unlocked"]):
		c["unlocked"].append(0)
		save_game()
	return c

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
	var beyond_tree := _tree_size()
	while true:
		var lvl = int(h["level"])
		var need = xp_for_level(lvl)
		if h["xp"] >= need:
			h["xp"] -= need
			h["level"] = lvl + 1
			gained += 1
			# Before finishing the tree: skill points. After: mastery points.
			if int(h.get("skills", []).size()) < beyond_tree and _potential_points(h) < beyond_tree_points():
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

func _tree_size() -> int:
	return SkillDefs.get_tree().size()

func beyond_tree_points() -> int:
	var total := 0
	for n in SkillDefs.get_tree():
		total += int(n.get("cost", 1))
	return total

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

func _find_node(node_id: String) -> Dictionary:
	for n in SkillDefs.get_tree():
		if n["id"] == node_id:
			return n
	return {}

# --- items ----------------------------------------------------------------
func add_item(item: Dictionary) -> void:
	if not has_hero():
		return
	data["hero"]["inventory"].append(item)
	emit_signal("profile_changed")
	save_game()

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
	if typeof(parsed) != TYPE_DICTIONARY:
		data = _default_data()
		return
	data = _migrate(parsed)
	emit_signal("profile_changed")

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
		elif not (0 in c["unlocked"]):
			c["unlocked"].append(0)
	d["version"] = SAVE_VERSION
	return d

func wipe_hero() -> void:
	data["hero"] = {}
	emit_signal("profile_changed")
	save_game()

func update_setting(key: String, value) -> void:
	data["settings"][key] = value
	save_game()
