extends SceneTree
## Plan 489: close-up review of every scenery model and prop the Map Editor
## offers (environment and props, not buildings or characters, which
## claude_assetreview covers). One picture each in CLAUDE_MOOD light, framed
## by the model's own size. Output D:/ClaudeWork/tmp/review/scenery/.
const CM := preload("res://scripts/world/custom_maps.gd")
var out_dir := "D:/ClaudeWork/tmp/review/scenery"

func _initialize() -> void:
	call_deferred("_run")

func _paths() -> Array:
	var found := {}
	var stack: Array = ["res://assets/environment", "res://assets/props"]
	while not stack.is_empty():
		var d: String = stack.pop_back()
		if d.contains("/buildings"):
			continue
		var dir := DirAccess.open(d)
		if dir == null:
			continue
		for sub in dir.get_directories():
			stack.append(d + "/" + sub)
		for f in dir.get_files():
			var f2: String = f.trim_suffix(".import").trim_suffix(".remap")
			if (f2.ends_with(".glb") or f2.ends_with(".gltf")) and not d.ends_with("/weapons") and not f2.begins_with("hero_relic"):
				found[d + "/" + f2] = true
	found.erase("res://assets/environment/vegetation/broadleaf_oak.glb")
	for tree in ["res://assets/environment/vegetation/broadleaf_oak_crown.scn", "res://assets/environment/vegetation/desert_palm.scn", "res://assets/environment/vegetation/desert_palm_b.scn"]:
		found[tree] = true
	var out: Array = found.keys()
	out.sort()
	return out

func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(out_dir)
	var paths := _paths()
	var doc := CM.new_doc("Claude Scenery Review")
	doc["mood"] = OS.get_environment("CLAUDE_MOOD")
	doc["sites"] = []
	var spots := []
	for i in paths.size():
		var p := Vector2(-150 + (i % 12) * 26, -150 + (i / 12) * 26)
		doc["showcase"].append({"kind": "scenery", "id": paths[i], "x": p.x, "z": p.y, "yaw": 0.0, "scale": 1.0, "team": 0, "g": 900 + i})
		spots.append(p)
	doc["starts"] = [{"x": 170.0, "z": 170.0, "g": 1}, {"x": 170.0, "z": -170.0, "g": 1}]
	var id := CM.save_doc(doc)
	var cfg: Dictionary = root.get_node("Match").default_config()
	cfg["map"] = id
	cfg["opponents"] = [{"race": "vorthak", "difficulty": "easy"}]
	cfg["no_fog"] = true
	cfg["sandbox"] = true
	root.get_node("Match").set_config(cfg)
	change_scene_to_file("res://scenes/game_world.tscn")
	await create_timer(12.0).timeout
	var gw = current_scene
	var world = gw.get("world")
	var rts = gw.get("rts")
	var hud = gw.get("hud")
	if hud: hud.visible = false
	var holder: Node3D = world.get_node("Showcase")
	var manifest: Array = []
	var n := 0
	for inst in holder.get_children():
		var lo := Vector3(INF, INF, INF)
		var hi := -lo
		for mi in inst.find_children("*", "MeshInstance3D", true, false):
			var box: AABB = mi.get_aabb()
			for c in 8:
				var q: Vector3 = mi.global_transform * box.get_endpoint(c)
				lo = lo.min(q)
				hi = hi.max(q)
		if lo.x == INF:
			continue
		var size := hi - lo
		var fname := String(inst.scene_file_path).get_file().get_basename()
		manifest.append("%s\t%.1f x %.1f x %.1f\t%s" % [fname, size.x, size.y, size.z, inst.scene_file_path])
		rts._cam_yaw = 0.35
		rts.focus_on(Vector3((lo.x + hi.x) * 0.5, 0, (lo.z + hi.z) * 0.5))
		rts._zoom = clampf(maxf(size.y, maxf(size.x, size.z)) * 1.8 + 4.0, 6.0, 40.0)
		rts.cam_arm.spring_length = rts._zoom
		await create_timer(0.6).timeout
		await RenderingServer.frame_post_draw
		root.get_viewport().get_texture().get_image().save_png("%s/%03d_%s.png" % [out_dir, n, fname])
		n += 1
	var f := FileAccess.open(out_dir + "/manifest.tsv", FileAccess.WRITE)
	f.store_string("\n".join(PackedStringArray(manifest)))
	f.close()
	CM.delete_doc(id)
	print("SCENEREVIEW models=%d shots=%d" % [paths.size(), n])
	quit(0)
