extends SceneTree
## Claude look-at probe: frames given world points at two zooms. Review-only.
## CLAUDE_POINTS="x,z;x,z", CLAUDE_TOUR_MAP optional.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var out := OS.get_environment("CLAUDE_TOUR_OUT")
	DirAccess.make_dir_recursive_absolute(out)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1600, 900))
	var cfg: Dictionary = root.get_node("Match").default_config()
	if OS.get_environment("CLAUDE_TOUR_MAP") != "":
		cfg["map"] = OS.get_environment("CLAUDE_TOUR_MAP")
	root.get_node("Match").set_config(cfg)
	change_scene_to_file("res://scenes/game_world.tscn")
	await create_timer(8.0).timeout
	var world = current_scene.get("world")
	var rts = current_scene.get("rts")
	rts.cam_speed = 0.0
	# Reveal the whole map for review shots.
	for i in world._visibility_states.size():
		world._visibility_states[i] = 2
	world._refresh_player_visibility_overlay()
	world.set_physics_process(false)
	var k := 0
	for pt in OS.get_environment("CLAUDE_POINTS").split(";"):
		if pt == "wood":
			# The first planted wood on the map.
			var wood = world.find_child("Wood", true, false)
			if wood == null:
				print("LOOKAT no wood"); continue
			rts.focus_on(wood.global_position)
		else:
			var xz := pt.split(",")
			rts.focus_on(Vector3(float(xz[0]), 0, float(xz[1])))
		for z in [rts.get_camera_zoom_min(), rts.get_camera_default_zoom()]:
			rts._zoom = z
			await create_timer(1.2).timeout
			await RenderingServer.frame_post_draw
			root.get_viewport().get_texture().get_image().save_png("%s/pt%d_z%d.png" % [out, k, int(z)])
		k += 1
	quit(0)
