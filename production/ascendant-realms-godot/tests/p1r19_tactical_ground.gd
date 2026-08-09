extends Node
## P1-R19 headed proof: calm tactical ground improves unit/route separation.
## This harness only pauses and frames the existing match; it does not issue
## gameplay commands or change navigation, map geometry, or resources.

var _output := ""
var _width := 1920
var _height := 1080
var _map := "hollowspan"
var _view := "army"
var _world: Node
var _rts: Node
var _frames: Array = []
var _failures: Array = []

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R19_OUTPUT")
	_width = maxi(1, int(OS.get_environment("ASCENDANT_P1R19_WIDTH")))
	_height = maxi(1, int(OS.get_environment("ASCENDANT_P1R19_HEIGHT")))
	_map = OS.get_environment("ASCENDANT_P1R19_MAP")
	_view = OS.get_environment("ASCENDANT_P1R19_VIEW")
	if _map.is_empty(): _map = "hollowspan"
	if _view.is_empty(): _view = "army"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	get_node("/root/Match").set_config({
		"player_race": "barrosan", "opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": _map, "start_resources": "standard", "victory": "conquest", "mode": "skirmish", "game_speed": 1.0
	})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	var deadline := Time.get_ticks_msec() + 30000
	while Time.get_ticks_msec() < deadline:
		var root := get_node_or_null("/root/GameRoot")
		_world = root.get_node_or_null("GameWorld") if root else null
		_rts = root.get_node_or_null("RTS") if root else null
		if _world and _rts and _world.game_running: break
		await get_tree().process_frame
	if not _world or not _rts or not _world.game_running:
		_failures.append("runtime_timeout")
		_write_manifest()
		get_tree().quit(1)
		return
	for _i in 12: await get_tree().process_frame
	get_tree().paused = true
	_rts.edge_scroll = false
	_rts._zoom = _rts.get_camera_default_zoom()
	var focus := _focus_for_view()
	_rts.focus_on(focus)
	for _i in 14: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		_failures.append("empty_frame")
	else:
		var sampled := {}
		for sx in range(0, image.get_width(), maxi(1, image.get_width() / 12)):
			for sy in range(0, image.get_height(), maxi(1, image.get_height() / 8)):
				var c := image.get_pixel(sx, sy)
				sampled["%d,%d,%d" % [int(c.r * 12.0), int(c.g * 12.0), int(c.b * 12.0)]] = true
		if sampled.size() < 8: _failures.append("blank_or_low_variance_frame")
		var png := _output.path_join("%s.png" % OS.get_environment("ASCENDANT_P1R19_NAME"))
		image.save_png(png)
		_frames.append({"name": OS.get_environment("ASCENDANT_P1R19_NAME"), "map": _map, "view": _view, "png": png, "width": image.get_width(), "height": image.get_height(), "camera_pitch_degrees": float(_rts.get_camera_pitch_degrees()), "camera_zoom": _rts.get_camera_default_zoom(), "focus": {"x": focus.x, "y": focus.y, "z": focus.z}})
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _focus_for_view() -> Vector3:
	var units := get_tree().get_nodes_in_group("units")
	if _view == "combat" and units.size() >= 2:
		return (units[0].global_position + units[1].global_position) * 0.5
	if _view == "resource":
		var resources := get_tree().get_nodes_in_group("resources")
		if not resources.is_empty(): return resources[0].global_position
	if not units.is_empty(): return units[0].global_position
	if _world and _world.commanders.size() > 0: return _world.commanders[0].position
	return Vector3.ZERO

func _write_manifest() -> void:
	var file := FileAccess.open(_output.path_join("tactical-ground-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"schema":"ascendant-realms-p1r19-tactical-ground-v1", "source_sha":OS.get_environment("ASCENDANT_P1R19_SOURCE_SHA"), "map":_map, "view":_view, "resolution":{"width":_width,"height":_height}, "frames":_frames, "failures":_failures, "pass":_failures.is_empty()}, "  "))
		file.store_line("")
