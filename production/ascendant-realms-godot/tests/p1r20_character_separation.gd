extends Node
## P1-R20 headed proof: authored model silhouettes separate from the ground.
## Frames are intentionally unlabeled in-world; role truth is carried by the
## manifest job and the underlying unit IDs, not debug prose.

var _output := ""
var _width := 1920
var _height := 1080
var _race := "lioraen"
var _view := "default"
var _world: Node
var _rts: Node
var _frames: Array = []
var _failures: Array = []

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R20_OUTPUT")
	_width = maxi(1, int(OS.get_environment("ASCENDANT_P1R20_WIDTH")))
	_height = maxi(1, int(OS.get_environment("ASCENDANT_P1R20_HEIGHT")))
	_race = OS.get_environment("ASCENDANT_P1R20_RACE")
	_view = OS.get_environment("ASCENDANT_P1R20_VIEW")
	if _race.is_empty(): _race = "lioraen"
	if _view.is_empty(): _view = "default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	get_node("/root/Match").set_config({
		"player_race": _race, "opponents": [{"race": "barrosan" if _race != "barrosan" else "lioraen", "difficulty": "easy"}],
		"map": "hollowspan", "start_resources": "standard", "victory": "conquest", "mode": "skirmish", "game_speed": 1.0
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
	if _view == "near": _rts._zoom = maxf(28.0, _rts.get_camera_default_zoom() * 0.58)
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
		var png := _output.path_join("%s.png" % OS.get_environment("ASCENDANT_P1R20_NAME"))
		image.save_png(png)
		_frames.append({"name": OS.get_environment("ASCENDANT_P1R20_NAME"), "race": _race, "view": _view, "png": png, "width": image.get_width(), "height": image.get_height(), "camera_pitch_degrees": float(_rts.get_camera_pitch_degrees()), "camera_zoom": _rts._zoom, "focus": {"x": focus.x, "y": focus.y, "z": focus.z}, "unit_ids": _unit_ids()})
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _focus_for_view() -> Vector3:
	var units := get_tree().get_nodes_in_group("units")
	if _view == "hero" or _view == "near":
		for u in units:
			if bool(u.is_hero): return u.global_position
	if _view == "worker":
		for u in units:
			if bool(u.is_worker): return u.global_position
	if not units.is_empty(): return units[0].global_position
	return Vector3.ZERO

func _unit_ids() -> Array:
	var ids: Array = []
	for u in get_tree().get_nodes_in_group("units"):
		ids.append({"unit_id": String(u.unit_id), "is_hero": bool(u.is_hero), "is_worker": bool(u.is_worker), "team": int(u.team)})
	return ids

func _write_manifest() -> void:
	var file := FileAccess.open(_output.path_join("character-separation-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"schema":"ascendant-realms-p1r20-character-separation-v1", "source_sha":OS.get_environment("ASCENDANT_P1R20_SOURCE_SHA"), "race":_race, "view":_view, "resolution":{"width":_width,"height":_height}, "frames":_frames, "failures":_failures, "pass":_failures.is_empty()}, "  "))
		file.store_line("")
