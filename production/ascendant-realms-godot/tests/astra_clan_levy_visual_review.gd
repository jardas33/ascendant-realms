extends SceneTree
## Local visual proof for the real Clan Levy model and production animation path.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var width := int(OS.get_environment("ASTRA_CHARACTER_WIDTH"))
	var height := int(OS.get_environment("ASTRA_CHARACTER_HEIGHT"))
	if width <= 0: width = 1920
	if height <= 0: height = 1080
	var output := OS.get_environment("ASTRA_CHARACTER_OUTPUT")
	if output.is_empty(): output = "user://astra-clan-levy"
	DirAccess.make_dir_recursive_absolute(output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(width, height))
	root.get_node("/root/Match").set_config({
		"player_race":"barrosan", "opponents":[{"race":"vorthak", "difficulty":"easy"}],
		"map":"hollowspan", "start_resources":"standard", "victory":"conquest", "mode":"skirmish", "game_speed":1.0
	})
	var scene := load("res://scenes/game_world.tscn") as PackedScene
	var game = scene.instantiate()
	root.add_child(game)
	var deadline := Time.get_ticks_msec() + 30000
	while Time.get_ticks_msec() < deadline and not game.world.game_running:
		await process_frame
	if not game.world.game_running:
		push_error("Character review world did not start")
		quit(2)
		return
	var hq_position: Vector3 = game.rts._player_hq_pos()
	var soldier = game.world.spawn_unit("barrosan_clan_levy", 0, hq_position + Vector3(17, 0, 12))
	if not is_instance_valid(soldier) or soldier.model_root.get_child_count() == 0 or not is_instance_valid(soldier.anim):
		push_error("Clan Levy model or animation missing")
		quit(3)
		return
	game.rts.edge_scroll = false
	game.rts._clear_selection()
	game.rts._add_to_selection(soldier)
	game.rts.selection_changed.emit(game.rts.selected)
	game.rts.focus_on(soldier.global_position)
	for _i in 18: await process_frame
	await _capture(output.path_join("clan_levy_%d_idle.png" % width))
	game.rts._zoom = game.rts.get_camera_zoom_min()
	game.rts.focus_on(soldier.global_position)
	for _i in 18: await process_frame
	await _capture(output.path_join("clan_levy_%d_near.png" % width))
	var before: Vector3 = soldier.global_position
	soldier.command_move(before + Vector3(10, 0, 0))
	for _i in 20: await process_frame
	var moved := before.distance_to(soldier.global_position)
	var walking_animation := String(soldier.anim.current_animation)
	await _capture(output.path_join("clan_levy_%d_walk.png" % width))
	paused = true
	var attack_animation := "ual1_Sword_Attack_Standing"
	if soldier.anim.has_animation(attack_animation):
		soldier.anim.play(attack_animation)
		soldier.anim.seek(0.4, true)
		await _capture(output.path_join("clan_levy_%d_attack.png" % width))
	print("ASTRA_CHARACTER_REVIEW model=", soldier.def.get("model"), " animations=", soldier.anim.get_animation_list(), " active=", walking_animation, " moved=", moved, " resolution=", width, "x", height)
	quit(0 if moved > 0.2 and walking_animation.to_lower().contains("walk") and soldier.anim.has_animation(attack_animation) else 4)

func _capture(path: String) -> void:
	await RenderingServer.frame_post_draw
	var screenshot := root.get_viewport().get_texture().get_image()
	if screenshot == null or screenshot.is_empty():
		push_error("Empty character review frame: " + path)
		return
	screenshot.save_png(path)
	print("ASTRA_CHARACTER_CAPTURE ", path, " ", screenshot.get_width(), "x", screenshot.get_height())
