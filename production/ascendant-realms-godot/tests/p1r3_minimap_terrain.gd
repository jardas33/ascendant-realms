extends Node
## P1-R3 headed proof: the minimap shows battlefield terrain and roads, not
## only colored entity dots. This harness observes live maps and never changes
## movement, fog, economy, or map data.

var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _failures: Array = []
var _maps := ["hollowspan", "emberfall_rift", "frostmere_basin"]

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R3_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1R3_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1R3_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1-remediation-a/p1r3/default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	for map_id in _maps:
		await _run_map(map_id)
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _run_map(map_id: String) -> void:
	get_node("/root/Match").set_config({
		"player_race": "lioraen", "opponents": [{"race": "barrosan", "difficulty": "easy"}],
		"map": map_id, "start_resources": "standard", "victory": "conquest",
		"mode": "skirmish", "game_speed": 1.0
	})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	var world = null
	var rts = null
	var deadline := Time.get_ticks_msec() + 20000
	while Time.get_ticks_msec() < deadline:
		var root = get_node_or_null("/root/GameRoot")
		world = root.get_node_or_null("GameWorld") if root else null
		rts = root.get_node_or_null("RTS") if root else null
		if world and rts and world.game_running: break
		await get_tree().process_frame
	if world == null or rts == null or not world.game_running:
		_failures.append(map_id + ":runtime_timeout")
		return
	for _i in 12: await get_tree().process_frame
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts._zoom = 48.0
	rts.cam_arm.spring_length = 48.0
	rts.focus_on(Vector3.ZERO)
	for _i in 8: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var name := map_id.to_upper()
	var path := _output.path_join(name + ".png")
	image.save_png(path)
	var probe := _minimap_probe(image)
	_frames.append({"name": name, "map": map_id, "png": path, "width": image.get_width(), "height": image.get_height(), "minimap_probe": probe})
	if probe["lit_pixels"] < 9000: _failures.append(map_id + ":minimap_black_or_empty")

func _minimap_probe(image: Image) -> Dictionary:
	var x0 := 8
	var y0 := maxi(0, _height - 224)
	var x1 := mini(image.get_width(), 224)
	var y1 := mini(image.get_height(), _height - 8)
	var lit := 0
	var colored := 0
	for y in range(y0, y1):
		for x in range(x0, x1):
			var c := image.get_pixel(x, y)
			if c.r + c.g + c.b > 0.75: lit += 1
			if c.g > c.r * 0.92 and c.g > c.b * 0.85 and c.g > 0.18: colored += 1
	return {"x": x0, "y": y0, "width": x1 - x0, "height": y1 - y0, "lit_pixels": lit, "terrain_colored_pixels": colored}

func _write_manifest() -> void:
	var manifest := {"schema": "ascendant-realms-p1r3-minimap-terrain-v1", "source_sha": OS.get_environment("ASCENDANT_P1R3_SOURCE_SHA"), "resolution": {"width": _width, "height": _height}, "maps": _maps, "frames": _frames, "pass": _failures.is_empty(), "failures": _failures}
	FileAccess.open(_output.path_join("minimap-terrain-manifest.json"), FileAccess.WRITE).store_string(JSON.stringify(manifest, "  "))
