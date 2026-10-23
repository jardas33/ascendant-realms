extends SceneTree
## Pause menu over a battle. Saves D:/ClaudeWork/tmp/b424/pause_<size>.png.
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var wh := (OS.get_environment("CLAUDE_SIZE") if OS.get_environment("CLAUDE_SIZE") != "" else "1920x1080").split("x")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(int(wh[0]), int(wh[1])))
	var cfg: Dictionary = root.get_node("Match").default_config()
	cfg["map"] = "hollowspan"
	root.get_node("Match").set_config(cfg)
	change_scene_to_file("res://scenes/game_world.tscn")
	await create_timer(7.0).timeout
	var pm = null
	for n in current_scene.find_children("*", "", true, false):
		if n.has_method("set_shown") and n.has_method("_cycle_music"): pm = n; break
	if pm == null:
		print("PAUSESHOT no pause menu"); quit(1); return
	pm.set_shown(true)
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("D:/ClaudeWork/tmp/b424/pause_%s.png" % "x".join(wh))
	quit(0)
