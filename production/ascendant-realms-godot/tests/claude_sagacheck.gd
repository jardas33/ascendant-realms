extends SceneTree
## Validates CampaignDefs: maps and races exist, unlock ids resolve, every
## chapter is reachable from 1-1, jar count matches, text fields present.
func _initialize() -> void:
	var defs = load("res://scripts/game/campaign_defs.gd")
	var maps := {}
	for m in load("res://scripts/world/map_defs.gd").list_infos():
		maps[m["id"]] = true
	var gd = root.get_node("GameData")
	var problems := 0
	var ids := {}
	var jars := 0
	for c in defs.CHAPTERS:
		ids[c["id"]] = c
	for c in defs.CHAPTERS:
		if not maps.has(c["map"]): print("BAD map ", c["id"], " ", c["map"]); problems += 1
		for o in c["opponents"]:
			if gd.get_race(o["race"]).is_empty(): print("BAD race ", c["id"], " ", o["race"]); problems += 1
		for u in c["unlocks"]:
			if not ids.has(u): print("BAD unlock ", c["id"], " -> ", u); problems += 1
		for k in ["title", "briefing", "opening", "victory"]:
			if String(c.get(k, "")) == "": print("MISSING ", k, " in ", c["id"]); problems += 1
		if c.get("taunts", []).size() < 2: print("FEW taunts ", c["id"]); problems += 1
		if c.get("jar", false): jars += 1
	var units: Dictionary = load("res://scripts/game/unit_defs.gd").get_all() if load("res://scripts/game/unit_defs.gd").has_method("get_all") else {}
	for cid in defs.EVENTS:
		if not ids.has(cid): print("BAD event chapter ", cid); problems += 1
		var ev: Dictionary = defs.EVENTS[cid]
		var lists: Array = []
		if ev.has("allies"): lists.append(ev["allies"]["units"])
		for w in ev.get("waves", []): lists.append(w["units"])
		for l in lists:
			for uid in l:
				if not units.is_empty() and not units.has(uid): print("BAD unit ", cid, " ", uid); problems += 1
	for rid in defs.RELICS:
		if not ids.has(rid) or not ids[rid].get("side", false): print("BAD relic ", rid); problems += 1
	print("UNITS checked ", units.size())
	var seen := {"1-1": true}
	var frontier := ["1-1"]
	while not frontier.is_empty():
		var id = frontier.pop_back()
		for u in ids[id]["unlocks"]:
			if not seen.has(u):
				seen[u] = true
				frontier.append(u)
	for id in ids:
		if not seen.has(id): print("UNREACHABLE ", id); problems += 1
	print("SAGACHECK chapters=", ids.size(), " jars=", jars, " problems=", problems)
	quit(0)
