extends SceneTree
## Plan 520: hit the player's hero and photograph the damage number against
## its name plate at the normal and a close zoom.
func _initialize() -> void:
	call_deferred("_run")

func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("D:/ClaudeWork/tmp/herodmg_%s.png" % name)

func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	var cfg: Dictionary = root.get_node("Match").default_config()
	cfg["map"] = "garrano_pass"
	cfg["player_race"] = OS.get_environment("CLAUDE_RACE") if OS.get_environment("CLAUDE_RACE") != "" else "karak"
	cfg["opponents"] = [{"race": "vorthak", "difficulty": "easy"}]
	root.get_node("Match").set_config(cfg)
	change_scene_to_file("res://scenes/game_world.tscn")
	await create_timer(9.0).timeout
	var gw = current_scene
	var world = gw.get("world")
	var rts = gw.get("rts")
	var hero = world.commanders[0].hero_ref
	print("HERODMG hero=%s plate=%s" % [hero.name, hero.has_node("HeroTitle")])
	for z in [[24.0, "normal"], [11.0, "close"]]:
		rts.focus_on(hero.global_position)
		rts._zoom = z[0]
		rts.cam_arm.spring_length = z[0]
		await create_timer(0.8).timeout
		hero.take_damage(14.0)
		await create_timer(0.12).timeout
		await _shot(z[1])
	quit(0)
