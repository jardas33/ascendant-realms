extends SceneTree
## Headless reload of a byte-preserved snapshot of the real UI-created profile.
## Run only in the independent R59_QA project/profile, never against live data.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var failures: Array = []
	var user_dir := OS.get_user_data_dir().replace("\\", "/")
	if not user_dir.ends_with("/AscendantRealms_Emanuel_Playable_R59_QA"):
		push_error("R59 reload test requires its independent QA profile")
		quit(1)
		return
	var text := FileAccess.get_file_as_string("user://r59_reload_expected.json")
	var expected = JSON.parse_string(text)
	if not (expected is Dictionary) or not expected.has("hero"):
		push_error("Missing private QA profile snapshot")
		quit(1)
		return
	var manager := root.get_node("ProfileManager")
	var actual: Dictionary = manager.data
	var checks := 0
	for field in ["name", "race", "archetype", "level", "xp", "skill_points", "attr_points", "attributes", "skills", "loadouts"]:
		if not expected.hero.has(field): continue
		checks += 1
		if actual.get("hero", {}).get(field) != expected.hero[field]: failures.append("hero." + field)
	checks += 3
	if int(actual.get("version", 0)) != int(expected.get("version", 0)): failures.append("save version")
	if actual.get("settings", {}).get("last_skirmish") != expected.get("settings", {}).get("last_skirmish"): failures.append("last Skirmish setup")
	if not manager.has_hero(): failures.append("native has_hero after reload")
	var report := {"checks": checks, "failures": failures, "hero": actual.get("hero", {}).get("name"), "race": actual.get("hero", {}).get("race"), "save_version": actual.get("version"), "last_skirmish": actual.get("settings", {}).get("last_skirmish"), "user_dir": user_dir, "public_GUI_relaunch": false}
	var out := FileAccess.open("user://r59_reload_result.json", FileAccess.WRITE)
	out.store_string(JSON.stringify(report, "  "))
	out.close()
	print("R59_PROFILE_RELOAD checks=", checks, " failures=", failures)
	quit(0 if failures.is_empty() else 1)
