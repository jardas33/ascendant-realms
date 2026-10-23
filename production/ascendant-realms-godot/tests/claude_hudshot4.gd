extends SceneTree
## Plan 432: a unit group, the hall, then the hall research tab (tmp/b432).
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var wh := (OS.get_environment("CLAUDE_SIZE") if OS.get_environment("CLAUDE_SIZE") != "" else "1920x1080").split("x")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(int(wh[0]), int(wh[1])))
	var cfg: Dictionary = root.get_node("Match").default_config()
	cfg["map"] = "hollowspan"
	if OS.get_environment("CLAUDE_RACE") != "": cfg["player_race"] = OS.get_environment("CLAUDE_RACE")
	root.get_node("Match").set_config(cfg)
	change_scene_to_file("res://scenes/game_world.tscn")
	await create_timer(7.0).timeout
	var gr = current_scene
	var world = gr.get("world")
	var rts = null
	for n in gr.find_children("*", "", true, false):
		if n.has_method("issue_stop"): rts = n; break
	var units: Array = []
	for u in world.player_commander.units:
		if is_instance_valid(u): units.append(u)
	rts.selected = units
	if rts.has_method("_on_selection_changed"): rts._on_selection_changed()
	if rts.has_signal("selection_changed"): rts.emit_signal("selection_changed", units)
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("D:/ClaudeWork/tmp/b432/units_%s.png" % OS.get_environment("CLAUDE_SIZE") + "")
	var hq = null
	for b in world.player_commander.buildings:
		if is_instance_valid(b) and b.def.get("is_hq", false): hq = b
	rts.selected = [hq]
	if rts.has_signal("selection_changed"): rts.emit_signal("selection_changed", [hq])
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("D:/ClaudeWork/tmp/b432/hall_%s.png" % OS.get_environment("CLAUDE_SIZE") + "")

	# Plan 432: the hall's research workspace.
	var hud = gr.get("hud")
	for btn in hud.find_children("*", "Button", true, false):
		if btn.is_visible_in_tree() and String(btn.text).begins_with("Research"):
			btn.emit_signal("pressed")
			break
	await create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("D:/ClaudeWork/tmp/b432/hallres_%s.png" % OS.get_environment("CLAUDE_SIZE"))
	quit(0)
