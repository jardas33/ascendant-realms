extends SceneTree
## Captures any menu scene: ASCENDANT_UI_SCENE, ASCENDANT_UI_SIZE, ASCENDANT_UI_OUTPUT.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var size_text := OS.get_environment("ASCENDANT_UI_SIZE")
	var parts := size_text.split("x")
	if parts.size() == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(int(parts[0]), int(parts[1])))
	if OS.get_environment("ASCENDANT_UI_REVIEW_HERO") == "1":
		# Review fixture (memory only, never saved): a mid-campaign hero.
		var pm = root.get_node("ProfileManager")
		pm.data["hero"] = {"name": "Jardas", "race": "barrosan", "archetype": "warlord", "appearance": 0,
			"strength": "", "weakness": "", "level": 12, "xp": 0.0, "skill_points": 3, "attr_points": 0,
			"attributes": {}, "skills": ["cmb_1", "cmb_2", "cmb_3", "act_1", "act_2", "act_3", "def_1", "def_2", "eco_1", "race_bar_1"],
			"mastery": 0, "mastery_points": 0, "mastery_spent": {}, "inventory": [], "equipment": {}, "loadouts": [], "history": []}
	var scene := load(OS.get_environment("ASCENDANT_UI_SCENE")) as PackedScene
	if scene == null:
		quit(2)
		return
	root.add_child(scene.instantiate())
	for i in maxi(10, int(OS.get_environment("ASCENDANT_UI_FRAMES"))):
		await process_frame
	var click := OS.get_environment("ASCENDANT_UI_SELECT_STAR")
	if not click.is_empty():
		var screen = root.get_child(root.get_child_count() - 1)
		if screen.has_method("_show_page"):
			screen._selected_id = click
			screen._show_page()
		for i in 6:
			await process_frame
	var fly := OS.get_environment("ASCENDANT_UI_FLY_PATH")
	if not fly.is_empty():
		var chart = root.get_child(root.get_child_count() - 1)
		if chart.has_method("_fly_to_path"):
			chart._fly_to_path(fly)
		for i in 60:
			await process_frame
	await RenderingServer.frame_post_draw
	var out := OS.get_environment("ASCENDANT_UI_OUTPUT")
	root.get_viewport().get_texture().get_image().save_png(out)
	print("SCREEN_CAPTURE ", out)
	quit(0)
