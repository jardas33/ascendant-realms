extends SceneTree
## Battle HUD with single selections: the hero, one worker, one enemy building.
## Saves D:/ClaudeWork/tmp/b422/sel_<what>_<size>.png.
func _initialize() -> void:
	call_deferred("_run")
func _shot(rts, picks: Array, what: String) -> void:
	rts.selected = picks
	if rts.has_signal("selection_changed"): rts.emit_signal("selection_changed", picks)
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("D:/ClaudeWork/tmp/b422/sel_%s_%s.png" % [what, OS.get_environment("CLAUDE_SIZE")])
func _run() -> void:
	var wh := (OS.get_environment("CLAUDE_SIZE") if OS.get_environment("CLAUDE_SIZE") != "" else "1920x1080").split("x")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(int(wh[0]), int(wh[1])))
	var cfg: Dictionary = root.get_node("Match").default_config()
	cfg["map"] = "hollowspan"
	root.get_node("Match").set_config(cfg)
	change_scene_to_file("res://scenes/game_world.tscn")
	await create_timer(7.0).timeout
	var world = current_scene.get("world")
	var rts = null
	for n in current_scene.find_children("*", "", true, false):
		if n.has_method("issue_stop"): rts = n; break
	var hero = null
	var worker = null
	for u in world.player_commander.units:
		if not is_instance_valid(u): continue
		if u.is_hero and hero == null: hero = u
		if u.is_worker and worker == null: worker = u
	if hero: await _shot(rts, [hero], "hero")
	if worker: await _shot(rts, [worker], "worker")
	for c in world.commanders:
		if c != world.player_commander and is_instance_valid(c):
			for b in c.buildings:
				if is_instance_valid(b):
					await _shot(rts, [b], "enemyb")
					break
			break
	quit(0)
