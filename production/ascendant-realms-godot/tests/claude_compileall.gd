extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var bad := []
	for dir in ["res://scripts/ui", "res://scripts/world", "res://scripts/game", "res://scripts/ai", "res://scripts/units", "res://scripts/buildings", "res://scripts/autoloads"]:
		for f in DirAccess.get_files_at(dir):
			if not f.ends_with(".gd"): continue
			var scr = load(dir + "/" + f)
			if scr == null or not scr.can_instantiate():
				bad.append(f)
	for sc in ["res://scenes/ui/campaign_map.tscn", "res://scenes/ui/hero_sheet.tscn", "res://scenes/ui/inventory.tscn", "res://scenes/ui/main_menu.tscn", "res://scenes/ui/settings.tscn", "res://scenes/ui/skirmish_setup.tscn", "res://scenes/ui/hero_creation.tscn", "res://scenes/ui/skill_tree.tscn"]:
		if ResourceLoader.exists(sc):
			var inst = load(sc).instantiate()
			if inst == null: bad.append(sc)
			else: inst.free()
	print("COMPILEALL bad=", bad)
	quit(0)
