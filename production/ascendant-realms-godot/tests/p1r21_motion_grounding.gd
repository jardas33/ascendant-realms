extends Node
## P1-R21 proof harness: motion presentation follows real velocity and settles
## to idle without changing simulation, navigation, or unit positions by code.

var _output := ""
var _width := 1920
var _height := 1080
var _role := "worker"
var _world: Node
var _rts: Node
var _frames: Array = []
var _failures: Array = []

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R21_OUTPUT")
	_width = maxi(1, int(OS.get_environment("ASCENDANT_P1R21_WIDTH")))
	_height = maxi(1, int(OS.get_environment("ASCENDANT_P1R21_HEIGHT")))
	_role = OS.get_environment("ASCENDANT_P1R21_ROLE")
	if _role.is_empty(): _role = "worker"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	get_node("/root/Match").set_config({
		"player_race": "barrosan", "opponents": [{"race": "lioraen", "difficulty": "easy"}],
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
	var unit = _find_role()
	if not unit:
		_failures.append("missing_role_unit:%s" % _role)
		_write_manifest()
		get_tree().quit(1)
		return
	var start_position: Vector3 = unit.global_position
	var simulation_before := Engine.time_scale
	var target := start_position + Vector3(8.0, 0.0, 0.0)
	unit.command_move(target)
	var samples: Array = []
	for _i in 70:
		await get_tree().process_frame
		samples.append({"position": _vec(unit.global_position), "velocity": _vec(unit.velocity), "animation_speed_scale": float(unit.anim.speed_scale) if unit.anim else 0.0, "state": int(unit.state)})
	unit.command_stop()
	for _i in 24: await get_tree().process_frame
	var endpoint: Vector3 = unit.global_position
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		_failures.append("empty_frame")
	else:
		var png := _output.path_join("%s.png" % OS.get_environment("ASCENDANT_P1R21_NAME"))
		image.save_png(png)
		_frames.append({
			"name": OS.get_environment("ASCENDANT_P1R21_NAME"), "role": _role, "png": png,
			"width": image.get_width(), "height": image.get_height(),
			"start_position": _vec(start_position), "target": _vec(target), "endpoint": _vec(endpoint),
			"endpoint_displacement": start_position.distance_to(endpoint),
			"samples": samples, "simulation_speed_before": simulation_before,
			"simulation_speed_after": Engine.time_scale,
			"final_velocity": _vec(unit.velocity), "final_animation_speed_scale": float(unit.anim.speed_scale) if unit.anim else 0.0,
			"camera_pitch_degrees": float(_rts.get_camera_pitch_degrees()), "camera_zoom": float(_rts._zoom)
		})
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _find_role():
	for unit in get_tree().get_nodes_in_group("units"):
		if _role == "hero" and bool(unit.is_hero): return unit
		if _role == "worker" and bool(unit.is_worker): return unit
		if _role == "military" and not bool(unit.is_worker) and not bool(unit.is_hero): return unit
	return null

func _vec(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _write_manifest() -> void:
	var file := FileAccess.open(_output.path_join("motion-grounding-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"schema":"ascendant-realms-p1r21-motion-grounding-v1", "source_sha":OS.get_environment("ASCENDANT_P1R21_SOURCE_SHA"), "role":_role, "resolution":{"width":_width,"height":_height}, "frames":_frames, "failures":_failures, "pass":_failures.is_empty()}, "  "))
		file.store_line("")
