extends SceneTree
## Plan 527: every people's landmark, built, and its selection portrait.
## Output D:/ClaudeWork/tmp/bport/landmarks.png
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	var cfg: Dictionary = root.get_node("Match").default_config()
	cfg["map"] = "garrano_pass"
	cfg["player_race"] = "barrosan"
	cfg["opponents"] = [{"race": "vorthak", "difficulty": "easy"}]
	cfg["no_fog"] = true
	root.get_node("Match").set_config(cfg)
	change_scene_to_file("res://scenes/game_world.tscn")
	var waited := 0
	while waited < 1500 and (current_scene == null or current_scene.get("world") == null or not bool(current_scene.get("world").game_running)):
		await process_frame
		waited += 1
	var world = current_scene.get("world")
	var start: Vector3 = world.map["start_positions"][0]
	var dir := (-start).normalized()
	var centre := start + dir * 40.0
	var gd = root.get_node("GameData")
	var ids: Array = []
	var bd: Dictionary = load("res://scripts/game/building_defs.gd").new().get("BUILDINGS") if false else {}
	for id in ["barrosan_village_oven", "lioraen_moura_fountain", "vorthak_rift_gate", "grimtusk_war_drum", "sylvan_golden_loom", "karak_standing_stones", "sunspear_sun_dial", "wyldkin_howling_stone", "hollow_ossuary_bell", "frostborn_entrudo_bonfire"]:
		ids.append(id)
	var layer := CanvasLayer.new()
	layer.layer = 50
	root.add_child(layer)
	var bg := ColorRect.new(); bg.color = Color(0.1, 0.1, 0.1); bg.size = Vector2(1920, 420); layer.add_child(bg)
	var i := 0
	for id in ids:
		var bdef: Dictionary = gd.get_building(String(id)).duplicate()
		bdef["id"] = String(id)
		var b = world._create_building(bdef, 0, centre + Vector3((i - 5) * 18.0, 0, 0), true)
		for f in 30:
			await process_frame
		var p = load("res://scripts/ui/entity_portrait_view.gd").new()
		p.custom_minimum_size = Vector2(170, 170)
		p.size = Vector2(170, 170)
		p.position = Vector2(10 + (i % 10) * 190, 20)
		layer.add_child(p)
		var l := Label.new(); l.text = String(id).split("_", true, 1)[1]; l.position = p.position + Vector2(0, 178); layer.add_child(l)
		for f in 3:
			await process_frame
		p.configure_entity(b)
		i += 1
	for f in 30:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().get_region(Rect2i(0, 0, 1920, 230)).save_png("D:/ClaudeWork/tmp/bport/landmarks.png")
	quit(0)
