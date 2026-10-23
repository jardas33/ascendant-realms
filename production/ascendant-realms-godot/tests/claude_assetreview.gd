extends SceneTree
## Plan 483: asset review through the Map Editor's Test in 3D. Every building
## and unit of one people (CLAUDE_RACE) is placed on a quiet test map and
## photographed up close from two sides, HUD hidden, in CLAUDE_MOOD light
## ("" for daylight). Pictures go to D:/ClaudeWork/tmp/review/<race>/ with a
## manifest of model paths. The test map is deleted after.
const CM := preload("res://scripts/world/custom_maps.gd")
var out_dir := ""

func _initialize() -> void:
	call_deferred("_run")

func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out_dir, name])

func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var race := OS.get_environment("CLAUDE_RACE") if OS.get_environment("CLAUDE_RACE") != "" else "barrosan"
	var mood := OS.get_environment("CLAUDE_MOOD")
	out_dir = "D:/ClaudeWork/tmp/review/%s%s" % [race, ("_" + mood) if mood != "" else ""]
	DirAccess.make_dir_recursive_absolute(out_dir)
	var gd = root.get_node("GameData")
	var doc := CM.new_doc("Claude Asset Review")
	doc["mood"] = mood
	doc["sites"] = []
	var buildings: Array = gd.buildings_for_race(race)
	buildings.sort()
	var units: Array = gd.units_for_race(race)
	units.sort()
	var spots := {}
	var i := 0
	for bid in buildings:
		var p := Vector2(-110 + (i % 5) * 50, -60 + (i / 5) * 50)
		doc["showcase"].append({"kind": "building", "id": bid, "x": p.x, "z": p.y, "yaw": 0.0, "scale": 1.0, "team": 0, "g": 500 + i})
		spots[bid] = p
		i += 1
	var j := 0
	for uid in units:
		var p := Vector2(-110 + (j % 12) * 18, 100 + (j / 12) * 18)
		doc["showcase"].append({"kind": "unit", "id": uid, "x": p.x, "z": p.y, "yaw": 0.0, "scale": 1.0, "team": 0, "g": 800 + j})
		spots[uid] = p
		j += 1
	doc["starts"] = [{"x": -170.0, "z": -170.0, "g": 1}, {"x": 170.0, "z": -170.0, "g": 1}]
	var id := CM.save_doc(doc)
	var cfg: Dictionary = root.get_node("Match").default_config()
	cfg["map"] = id
	cfg["player_race"] = race
	cfg["opponents"] = [{"race": "vorthak" if race != "vorthak" else "barrosan", "difficulty": "easy"}]
	cfg["no_fog"] = true
	cfg["sandbox"] = true
	root.get_node("Match").set_config(cfg)
	change_scene_to_file("res://scenes/game_world.tscn")
	await create_timer(10.0).timeout
	var gw = current_scene
	var world = gw.get("world")
	var rts = gw.get("rts")
	var hud = gw.get("hud")
	if hud: hud.visible = false
	# Units stand still for their pictures.
	for u in world.all_units():
		if u.has_method("stop"):
			u.stop()
	var manifest: Array = []
	for bid in buildings:
		var p: Vector2 = spots[bid]
		var fp := float(gd.get_building(bid).get("footprint", 5.0))
		manifest.append("%s\tbuilding\t%s" % [bid, String(gd.get_building(bid).get("model", ""))])
		for a in [[0.35, "a"], [2.6, "b"]]:
			rts._cam_yaw = a[0]
			rts.focus_on(Vector3(p.x, 0, p.y))
			rts._zoom = clampf(fp * 2.4 + 6.0, 10.0, 34.0)
			rts.cam_arm.spring_length = rts._zoom
			await create_timer(0.8).timeout
			await _shot("%s_%s" % [bid, a[1]])
	for uid in units:
		var p: Vector2 = spots[uid]
		manifest.append("%s\tunit\t%s" % [uid, String(gd.get_unit(uid).get("model", ""))])
		for a in [[0.0, "a"], [2.4, "b"]]:
			rts._cam_yaw = a[0]
			rts.focus_on(Vector3(p.x, 0, p.y))
			rts._zoom = 7.0
			rts.cam_arm.spring_length = 7.0
			await create_timer(0.7).timeout
			await _shot("%s_%s" % [uid, a[1]])
	var f := FileAccess.open(out_dir + "/manifest.tsv", FileAccess.WRITE)
	f.store_string("\n".join(PackedStringArray(manifest)))
	f.close()
	CM.delete_doc(id)
	print("ASSETREVIEW %s buildings=%d units=%d" % [race, buildings.size(), units.size()])
	quit(0)
