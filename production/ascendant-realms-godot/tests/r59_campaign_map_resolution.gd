extends SceneTree
## The historic saga checker uses the skirmish-only picker list. Saga return
## maps are intentionally hidden there. Keep that checker unchanged and verify
## the real map resolver independently, including its unknown-ID fallback.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var maps = load("res://scripts/world/map_defs.gd")
	var campaign = load("res://scripts/game/campaign_defs.gd")
	var failures: Array = []
	var resolved: Array = []
	var picker_ids: Array = []
	for info in maps.list_infos(): picker_ids.append(String(info.id))
	var hidden: Array = []
	for chapter in campaign.CHAPTERS:
		var id := String(chapter.map)
		var field: Dictionary = maps.get_map(id)
		if String(field.get("id", "")) != id:
			failures.append(String(chapter.id) + ":" + id)
		resolved.append({"chapter": chapter.id, "requested": id, "actual": field.get("id")})
		if not picker_ids.has(id): hidden.append(String(chapter.id) + ":" + id)
	var unknown: Dictionary = maps.get_map("r59_intentionally_unknown_map")
	if String(unknown.get("id", "")) == "r59_intentionally_unknown_map": failures.append("unknown-ID control did not fall back")
	var report := {"chapters_checked": resolved.size(), "failures": failures, "hidden_from_skirmish_picker": hidden, "resolved": resolved, "unknown_control_actual": unknown.get("id"), "scope": "map data resolution, not full campaign gameplay"}
	var out := FileAccess.open("user://r59_campaign_map_resolution.json", FileAccess.WRITE)
	out.store_string(JSON.stringify(report, "  "))
	out.close()
	print("R59_CAMPAIGN_MAP_RESOLUTION chapters=", resolved.size(), " hidden=", hidden.size(), " failures=", failures)
	quit(0 if failures.is_empty() else 1)
