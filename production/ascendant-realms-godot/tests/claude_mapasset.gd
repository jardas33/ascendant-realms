extends SceneTree
## Plan 479 probe: the editor's Assets tool and Test in 3D.
const OUT := "D:/ClaudeWork/tmp/b479"
var fails := 0
func _initialize() -> void:
	call_deferred("_run")
func _check(ok: bool, what: String) -> void:
	print(("OK   " if ok else "FAIL ") + what)
	if not ok: fails += 1
func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [OUT, name])
func _pick(ed, kind_index: int, race_index: int, match_text: String) -> bool:
	ed._asset_kind_opt.select(kind_index)
	if race_index >= 0:
		ed._asset_race_opt.select(race_index)
	ed._refresh_assets()
	for i in ed._asset_list.item_count:
		if match_text.to_lower() in ed._asset_list.get_item_text(i).to_lower() or match_text in String(ed._asset_list.get_item_metadata(i)):
			ed._asset_list.select(i)
			return true
	return false
func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DirAccess.make_dir_recursive_absolute(OUT)
	change_scene_to_file("res://scenes/ui/map_editor.tscn")
	await create_timer(1.0).timeout
	var ed = current_scene
	ed.doc["name"] = "Probe Asset Yard"
	ed.doc["theme"] = "highland"
	ed._set_tool("asset")
	var bi: int = ed._race_ids.find("barrosan")
	_check(ed._asset_list.item_count > 0, "asset list filled (%d)" % ed._asset_list.item_count)
	_check(_pick(ed, 0, bi, "War Hall"), "found War Hall")
	ed._asset_team = 0
	ed._press(Vector2(-110, -60))
	_check(_pick(ed, 0, ed._race_ids.find("vorthak"), "Bone Barracks"), "found Bone Barracks")
	ed._asset_team = 1
	ed._press(Vector2(-60, -110))
	_check(_pick(ed, 1, bi, "Clan Levy"), "found Clan Levy")
	ed._asset_team = 0
	ed._asset_yaw = 90.0
	for k in 3:
		ed._press(Vector2(-95 + k * 7, -95))
	_check(_pick(ed, 2, -1, "highland_pine"), "found the pine model (%d models)" % ed._scenery_paths().size())
	ed._asset_scale = 2.0
	ed._press(Vector2(-125, -100))
	_check((ed.doc["showcase"] as Array).size() == 6, "six pieces placed")
	ed._refresh_board()
	await create_timer(0.5).timeout
	await _shot("editor")
	ed._mood_opt.select(1)
	ed._mood_opt.item_selected.emit(1)
	_check(String(ed.doc.get("mood", "")) == "dusk", "light set to dusk")
	ed._on_test()
	await create_timer(10.0).timeout
	var gw = current_scene
	var world = gw.get("world")
	_check(world != null and world.has_node("Showcase"), "match built the showcase")
	_check(world != null and world.battle_mood() == "dusk", "the test plays at dusk")
	_check(world != null and world.get_node("Showcase").get_child_count() == 1, "one model placed")
	var ais := 0
	for c in gw.get_children():
		if c.get_script() == load("res://scripts/ai/enemy_ai.gd"):
			ais += 1
	_check(ais == 0, "no enemy brain in a test")
	var levies := 0
	var foe_barracks := false
	for u in world.all_units():
		if String(u.unit_id) == "barrosan_clan_levy" and int(u.team) == 0 and Vector2(u.global_position.x, u.global_position.z).distance_to(Vector2(-88, -95)) < 15.0:
			levies += 1
	for b in world.all_buildings():
		if String(b.building_id) == "vorthak_bone_barracks" and int(b.team) == 1:
			foe_barracks = true
	_check(levies == 3, "three levies stand where placed (%d)" % levies)
	_check(foe_barracks, "enemy-side barracks placed")
	gw.get("rts").focus_on(Vector3(-90, 0, -90))
	await create_timer(1.5).timeout
	await _shot("test3d")
	var rts = gw.get("rts")
	_check(float(rts._zoom_min) < 10.0, "test camera can zoom in close")
	for target in [[Vector3(-88, 0, -95), "closeup_units"], [Vector3(-110, 0, -60), "closeup_hall"]]:
		rts.focus_on(target[0])
		rts._zoom = 9.0 if target[1] == "closeup_units" else 16.0
		await create_timer(2.0).timeout
		await _shot(target[1])
	gw._return_to_menu()
	await create_timer(1.5).timeout
	_check(String(current_scene.doc.get("name", "")) == "Probe Asset Yard", "came back to the same map in the editor")
	_check(not bool(root.get_node("Match").get_config().get("sandbox", false)), "test flag cleared")
	load("res://scripts/world/custom_maps.gd").delete_doc("custom_probe_asset_yard")
	_check(not FileAccess.file_exists("user://maps/custom_probe_asset_yard.json"), "test map deleted")
	print("MAPASSET fails=%d" % fails)
	quit(1 if fails > 0 else 0)
