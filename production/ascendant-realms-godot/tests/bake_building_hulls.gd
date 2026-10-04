extends SceneTree
## Writes assets/cache/building_hulls.res: the collision hulls of every
## building model, prepared exactly as a match prepares them. Run after a
## building model changes:
##   godot --headless --path . -s res://tests/bake_building_hulls.gd
## CLAUDE_BAKE_CHECK=1 only reports how many hulls the current file misses.
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var check_only := OS.get_environment("CLAUDE_BAKE_CHECK") == "1"
	var utils = load("res://scripts/utils/model_utils.gd")
	if not check_only:
		# Bake from the meshes, never from the previous file.
		utils._baked_hulls_loaded = true
		utils._baked_hulls = {}
	var building_script = load("res://scripts/buildings/building.gd")
	var defs: Dictionary = load("res://scripts/game/building_defs.gd").get_all()
	var models := 0
	for bdef in defs.values():
		var path := String(bdef.get("model", ""))
		if path == "" or not ResourceLoader.exists(path):
			continue
		models += 1
		utils.prewarm_building_collision(path)
		var warm = building_script.new()
		root.add_child(warm)
		warm.prewarm_model(bdef)
		warm.free()
	if check_only:
		print("BAKEHULLS check: %d building models, %d hulls missing from the baked file: %s" % [models, int(utils.hulls_generated), "OK" if int(utils.hulls_generated) == 0 else "FAIL"])
		quit(0 if int(utils.hulls_generated) == 0 else 1)
		return
	var cache = load("res://scripts/utils/hull_cache.gd").new()
	cache.entries = utils.hulls_for_baking()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/cache"))
	var err := ResourceSaver.save(cache, utils.BAKED_HULLS_PATH)
	print("BAKEHULLS wrote %d hulls from %d building models (%d generated), save result %d" % [cache.entries.size(), models, int(utils.hulls_generated), err])
	quit(0 if err == OK else 1)
