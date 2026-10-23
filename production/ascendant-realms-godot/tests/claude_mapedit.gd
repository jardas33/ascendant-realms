extends SceneTree
## Plan 478 probe: paints a map with the editor's own tools, saves it, checks
## the skirmish list has it, then plays a match on it. Deletes the file after.
const OUT := "D:/ClaudeWork/tmp/b478"
var fails := 0
func _initialize() -> void:
	call_deferred("_run")
func _check(ok: bool, what: String) -> void:
	print(("OK   " if ok else "FAIL ") + what)
	if not ok: fails += 1
func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [OUT, name])
func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DirAccess.make_dir_recursive_absolute(OUT)
	change_scene_to_file("res://scenes/ui/main_menu.tscn")
	await create_timer(2.5).timeout
	await _shot("menu")
	change_scene_to_file("res://scenes/ui/map_editor.tscn")
	await create_timer(1.0).timeout
	var ed = current_scene
	ed.doc["name"] = "Probe Twin Fords"
	ed.doc["theme"] = "autumn"
	ed.mirror = "point"
	# A river across the middle, with two fords.
	ed.tool = "river"; ed.line_width = 14.0
	for p in [Vector2(-215, 60), Vector2(-90, 20), Vector2(0, 0), Vector2(90, -20), Vector2(215, -60)]:
		ed._press(p)
	ed._finish_line()
	_check((ed.doc["rivers"] as Array).size() == 1, "river through the middle kept as one (its own twin)")
	ed.tool = "ford"; ed.brush = 14.0
	ed._press(Vector2(-90, 20))
	_check((ed.doc["rivers"][0]["fords"] as Array).size() == 2, "ford and its twin")
	ed.tool = "erase"; ed._press(Vector2(-90, 20))
	_check((ed.doc["rivers"][0]["fords"] as Array).size() == 0, "erase removed both fords")
	ed._on_undo()
	_check((ed.doc["rivers"][0]["fords"] as Array).size() == 2, "undo brought the fords back")
	# Woods, hills, a lake, ridges, a road, sites and veins.
	ed.tool = "wood"; ed.brush = 22.0
	ed._press(Vector2(-60, -120)); ed._drag_to(Vector2(-30, -100)); ed._release(Vector2.ZERO)
	ed._press(Vector2(-170, 20)); ed._drag_to(Vector2(-150, 50)); ed._release(Vector2.ZERO)
	ed.tool = "hill"
	ed._press(Vector2(80, -150)); ed._drag_to(Vector2(105, -130)); ed._release(Vector2.ZERO)
	ed.tool = "lake"
	ed._press(Vector2(-150, 140)); ed._drag_to(Vector2(-125, 160)); ed._release(Vector2.ZERO)
	ed.tool = "ridge"; ed.line_width = 10.0
	for p in [Vector2(-20, -190), Vector2(40, -80)]:
		ed._press(p)
	ed._finish_line()
	ed.tool = "wall"
	for p in [Vector2(-120, -60), Vector2(-60, -40)]:
		ed._press(p)
	ed._finish_line()
	ed.tool = "road"
	for p in [Vector2(-150, -150), Vector2(-90, 20), Vector2(0, 0)]:
		ed._press(p)
	ed._finish_line()
	ed.tool = "watch"; ed._press(Vector2(-100, 100))
	ed.tool = "ruin"; ed._press(Vector2(100, 100))
	ed.tool = "vein"; ed.kind = "gold"; ed._press(Vector2(-110, -175))
	ed.kind = "stone"; ed._press(Vector2(-180, -95))
	ed.tool = "deposit"; ed.kind = "timber"; ed._press(Vector2(-125, -120))
	ed.kind = "food"; ed._press(Vector2(-170, -150))
	_check((ed.doc["woods"] as Array).size() == 4, "woods mirrored")
	_check((ed.doc["sites"] as Array).size() == 5, "sites mirrored (5)")
	# Erase removes a twin pair, undo brings it back.
	var before: int = (ed.doc["veins"] as Array).size()
	ed.tool = "erase"; ed._press(Vector2(-180, -95))
	_check((ed.doc["veins"] as Array).size() == before - 2, "erase removed the pair")
	ed._on_undo()
	_check((ed.doc["veins"] as Array).size() == before, "undo restored it")
	ed.tool = "move"
	ed._refresh_all()
	_check(load("res://scripts/world/custom_maps.gd").problems(ed.doc).is_empty(), "no problems: %s" % str(load("res://scripts/world/custom_maps.gd").problems(ed.doc)))
	_check(ed._on_save(), "saved")
	ed._refresh_list()
	ed.tool = "wood"
	ed._refresh_tool()
	ed._hover = Vector2(60, 120)
	ed._overlay.queue_redraw()
	await create_timer(0.6).timeout
	await _shot("editor")
	var id := "custom_probe_twin_fords"
	var found := false
	for info in MapDefs.list_infos():
		if String(info.get("id", "")) == id:
			found = true
	_check(found, "skirmish list has the map")
	change_scene_to_file("res://scenes/ui/skirmish_setup.tscn")
	await create_timer(1.5).timeout
	var sk = current_scene
	sk._set_opponents(3)
	sk._map_id = id
	sk._refresh_map_preview()
	await create_timer(0.3).timeout
	_check(int(sk._num_opponents) == 1, "two-camp map caps opponents at one (got %d)" % int(sk._num_opponents))
	await _shot("skirmish")
	var cfg: Dictionary = root.get_node("Match").default_config()
	cfg["map"] = id
	cfg["player_race"] = "barrosan"
	root.get_node("Match").set_config(cfg)
	change_scene_to_file("res://scenes/game_world.tscn")
	await create_timer(9.0).timeout
	var world = current_scene.get("world")
	_check(world != null and String(world.map.get("id", "")) == id, "match loaded the custom map")
	await _shot("match")
	var hud = current_scene.get("hud")
	if hud: hud.visible = false
	var cam := Camera3D.new()
	current_scene.add_child(cam)
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 460.0
	cam.far = 900.0
	cam.global_position = Vector3(0, 400, 0)
	cam.rotation = Vector3(-PI / 2.0, 0, 0)
	cam.make_current()
	await create_timer(1.0).timeout
	await _shot("top")
	load("res://scripts/world/custom_maps.gd").delete_doc(id)
	_check(not FileAccess.file_exists("user://maps/%s.json" % id), "test map deleted")
	print("MAPEDIT fails=%d" % fails)
	quit(1 if fails > 0 else 0)
