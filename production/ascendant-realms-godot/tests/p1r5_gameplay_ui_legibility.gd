extends Node
## P1-R5 headed proof: dense player-facing UI remains legible at both target sizes.
## The driver changes scenes and selection only; it does not mutate gameplay data.

var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _failures: Array = []

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R5_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1R5_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1R5_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1-remediation-a/p1r5/default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	await get_tree().process_frame
	await get_tree().process_frame

	for item in [
		{"name": "setup", "scene": "res://scenes/ui/skirmish_setup.tscn"},
		{"name": "hero_profile", "scene": "res://scenes/ui/hero_sheet.tscn"},
		{"name": "settings", "scene": "res://scenes/ui/settings.tscn"}
	]:
		await _capture_scene(str(item["scene"]), str(item["name"]))

	await _capture_game_views()
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _capture_scene(scene_path: String, key: String) -> void:
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.75).timeout
	await _capture(key)

func _capture_game_views() -> void:
	get_node("/root/Match").set_config({
		"player_race": "lioraen",
		"opponents": [{"race": "barrosan", "difficulty": "easy"}],
		"map": "hollowspan", "start_resources": "standard", "victory": "conquest",
		"mode": "skirmish", "game_speed": 1.0
	})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	var root = null
	var world = null
	var rts = null
	var deadline := Time.get_ticks_msec() + 20000
	while Time.get_ticks_msec() < deadline:
		root = get_node_or_null("/root/GameRoot")
		world = root.get_node_or_null("GameWorld") if root else null
		rts = root.get_node_or_null("RTS") if root else null
		if root and world and rts and world.game_running: break
		await get_tree().process_frame
	if world == null or rts == null or not world.game_running:
		_failures.append("runtime_timeout")
		return
	for _i in 12: await get_tree().process_frame
	var entities := _collect_entities(world)
	for key in ["worker", "hero", "building"]:
		if not entities.has(key):
			_failures.append("missing_" + key)
			continue
		var entity = entities[key]
		rts._clear_selection()
		rts._add_to_selection(entity)
		rts.selection_changed.emit(rts.selected)
		rts.edge_scroll = false
		rts.focus_on(entity.global_position)
		for _i in 12: await get_tree().process_frame
		await _capture(key)

func _collect_entities(world) -> Dictionary:
	var out := {}
	for u in world.player_commander.units:
		if not is_instance_valid(u) or u.is_dead: continue
		if u.is_hero and not out.has("hero"): out["hero"] = u
		elif u.is_worker and not out.has("worker"): out["worker"] = u
	var buildings := []
	for b in world.player_commander.buildings:
		if is_instance_valid(b) and not b.is_dead and b.is_built: buildings.append(b)
	if buildings.is_empty():
		for b in world.all_buildings():
			if is_instance_valid(b) and not b.is_dead and b.is_built: buildings.append(b)
	if not buildings.is_empty(): out["building"] = buildings[0]
	return out

func _capture(key: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		_failures.append(key + ":empty_frame")
		return
	var path := _output.path_join(key + ".png")
	image.save_png(path)
	var probe := _probe(image)
	_frames.append({"name": key, "png": path, "width": image.get_width(), "height": image.get_height(), "probe": probe})
	if probe["lit_pixels"] < 300: _failures.append(key + ":black_or_blank_frame")

func _probe(image: Image) -> Dictionary:
	var lit := 0
	var step_x := maxi(1, image.get_width() / 64)
	var step_y := maxi(1, image.get_height() / 64)
	for y in range(0, image.get_height(), step_y):
		for x in range(0, image.get_width(), step_x):
			var c := image.get_pixel(x, y)
			if c.r + c.g + c.b > 0.18: lit += 1
	return {"lit_pixels": lit, "sampled_pixels": ceili(float(image.get_width()) / step_x) * ceili(float(image.get_height()) / step_y)}

func _write_manifest() -> void:
	var manifest := {"schema": "ascendant-realms-p1r5-gameplay-ui-legibility-v1", "source_sha": OS.get_environment("ASCENDANT_P1R5_SOURCE_SHA"), "resolution": {"width": _width, "height": _height}, "frames": _frames, "pass": _failures.is_empty(), "failures": _failures}
	FileAccess.open(_output.path_join("gameplay-ui-legibility-manifest.json"), FileAccess.WRITE).store_string(JSON.stringify(manifest, "  "))
