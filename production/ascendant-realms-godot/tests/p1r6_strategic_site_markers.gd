extends Node
## P1-R6 headed proof: strategic-site presentation stays readable without
## changing capture ownership or benefit semantics. State variants are frozen
## review fixtures applied only inside this capture process.

var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _failures: Array = []

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R6_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1R6_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1R6_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1-remediation-a/p1r6/default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	await get_tree().process_frame
	await get_tree().process_frame
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
		_write_manifest()
		get_tree().quit(1)
		return
	for _i in 12: await get_tree().process_frame
	var points := get_tree().get_nodes_in_group("capture_points")
	if points.is_empty():
		_failures.append("missing_capture_point")
		_write_manifest()
		get_tree().quit(1)
		return
	var point = points[0]
	await _focus_and_capture(rts, point, "neutral")
	point.set_process(false)
	point.owner_team = -1
	point._progress = 0.45
	point._contesting_team = 0
	point._tint(GameData.TEAM_COLORS.get(0, Color.WHITE), 0.45)
	await _focus_and_capture(rts, point, "contested")
	point.owner_team = 0
	point._progress = 1.0
	point._contesting_team = -1
	point._tint(GameData.TEAM_COLORS.get(0, Color.WHITE), 1.0)
	await _focus_and_capture(rts, point, "owned")
	point.owner_team = -1
	point._progress = 0.0
	point._contesting_team = -1
	point._tint(Color(0.8, 0.8, 0.8), 0.0)
	rts._zoom = 20.0
	rts.cam_arm.spring_length = rts._zoom
	await _focus_and_capture(rts, point, "near")
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _focus_and_capture(rts, point, key: String) -> void:
	rts.edge_scroll = false
	rts._clear_selection()
	rts.focus_on(point.global_position)
	for _i in 12: await get_tree().process_frame
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
	var manifest := {"schema": "ascendant-realms-p1r6-strategic-site-markers-v1", "source_sha": OS.get_environment("ASCENDANT_P1R6_SOURCE_SHA"), "resolution": {"width": _width, "height": _height}, "frames": _frames, "capture_semantics": "visual fixtures only; ownership and benefit logic are not changed", "pass": _failures.is_empty(), "failures": _failures}
	FileAccess.open(_output.path_join("strategic-site-markers-manifest.json"), FileAccess.WRITE).store_string(JSON.stringify(manifest, "  "))
