extends Node
## P1-S2 camera-only stress harness. It drives the real RTSController and never
## writes gameplay entity state, navigation, terrain, economy, or match results.

var _root: Node
var _world: Node
var _rts: Node
var _output := ""
var _mode := "candidate"
var _width := 1920
var _height := 1080
var _frames: Array = []
var _failures: Array = []
var _before_entities := {}

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1S2_OUTPUT")
	_mode = OS.get_environment("ASCENDANT_P1S2_MODE")
	if _mode == "": _mode = "candidate"
	_width = int(OS.get_environment("ASCENDANT_P1S2_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1S2_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output == "": _output = "D:/CodexData/evidence/ascendant-realms-p1s2-camera-bounds/default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	get_node("/root/Match").set_config({
		"player_race": "barrosan",
		"opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": "hollowspan",
		"start_resources": "standard",
		"victory": "conquest",
		"mode": "skirmish",
		"game_speed": 1.0
	})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	await get_tree().process_frame
	await _wait_for_runtime()
	get_tree().paused = true
	await get_tree().process_frame
	_before_entities = _entity_snapshot()
	await _run_stress()
	_write_manifest()
	get_tree().quit()

func _wait_for_runtime() -> void:
	var deadline := Time.get_ticks_msec() + 15000
	while Time.get_ticks_msec() < deadline:
		_root = get_node_or_null("GameRoot")
		if not _root: _root = get_node_or_null("/root/GameRoot")
		if _root and _root.get_node_or_null("RTS") and _root.get_node_or_null("GameWorld"):
			_rts = _root.get_node("RTS")
			_world = _root.get_node("GameWorld")
			if _world.game_running:
				for _i in range(12): await get_tree().process_frame
				return
		await get_tree().process_frame
	_failures.append("runtime_timeout")

func _run_stress() -> void:
	await _capture_case("01_START_DEFAULT_CAMERA", false, Vector3.ZERO, 55.0, 0.0)
	await _capture_case("02_NORTH_BOUND_DEFAULT_ZOOM", true, Vector3(0, 0, -140), 55.0, 0.0)
	await _capture_case("03_SOUTH_BOUND_DEFAULT_ZOOM", true, Vector3(0, 0, 140), 55.0, 0.0)
	await _capture_case("04_EAST_BOUND_DEFAULT_ZOOM", true, Vector3(140, 0, 0), 55.0, 0.0)
	await _capture_case("05_WEST_BOUND_DEFAULT_ZOOM", true, Vector3(-140, 0, 0), 55.0, 0.0)
	await _capture_case("06_NEAR_ZOOM_STRESS", true, Vector3.ZERO, 25.0, 0.0)
	await _capture_case("07_FAR_ZOOM_STRESS", true, Vector3.ZERO, 95.0, 0.0)
	await _capture_case("08_ROTATED_BOUND_STRESS", true, Vector3(120, 0, -120), 55.0, PI * 0.5)
	await _capture_case("09_MINIMAP_EDGE_FOCUS", true, Vector3(-140, 0, 140), 55.0, 0.0)
	var hero = _world.commanders[0].hero_ref if _world.commanders.size() > 0 else null
	var hero_pos: Vector3 = hero.global_position if is_instance_valid(hero) else Vector3.ZERO
	await _capture_case("10_HERO_OR_BASE_RECENTER", true, hero_pos, 55.0, 0.0)

func _capture_case(name: String, apply_focus: bool, focus: Vector3, zoom: float, yaw: float) -> void:
	if not _rts:
		_failures.append(name + ":missing_rts")
		return
	_rts.edge_scroll = false
	_rts._cam_yaw = yaw
	_rts._zoom = zoom
	_rts.cam_arm.spring_length = zoom
	if apply_focus:
		_rts.focus_on(focus)
	for _i in range(8): await get_tree().process_frame
	var state := _camera_state()
	var entities_after := _entity_snapshot()
	if _mode == "candidate":
		if state.get("inside_safe_bounds", false) != true:
			_failures.append(name + ":outside_safe_bounds")
		if float(state.get("zoom", zoom)) < float(state.get("zoom_min", zoom)) - 0.01:
			_failures.append(name + ":zoom_below_min")
		if float(state.get("zoom", zoom)) > float(state.get("zoom_max", zoom)) + 0.01:
			_failures.append(name + ":zoom_above_max")
	if entities_after != _before_entities:
		_failures.append(name + ":gameplay_entity_position_changed")
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var png_path := _output.path_join(name + ".png")
	image.save_png(png_path)
	_frames.append({
		"name": name,
		"png": png_path,
		"width": image.get_width(),
		"height": image.get_height(),
		"requested_width": _width,
		"requested_height": _height,
		"mode": _mode,
		"state": state,
		"entities_unchanged": entities_after == _before_entities
	})

func _camera_state() -> Dictionary:
	var pivot: Vector3 = _rts.cam_pivot.global_position if is_instance_valid(_rts.cam_pivot) else Vector3.ZERO
	var camera_pos: Vector3 = _rts.camera.global_position if is_instance_valid(_rts.camera) else Vector3.ZERO
	var zoom := float(_rts._zoom)
	var state := {
		"pivot": _vec(pivot),
		"camera_position": _vec(camera_pos),
		"zoom": zoom,
		"yaw": float(_rts._cam_yaw),
		"viewport": {"width": get_viewport().get_visible_rect().size.x, "height": get_viewport().get_visible_rect().size.y},
		"window_size": {"width": DisplayServer.window_get_size().x, "height": DisplayServer.window_get_size().y},
		"zoom_min": float(_rts.get_camera_zoom_min()) if _rts.has_method("get_camera_zoom_min") else 25.0,
		"zoom_max": float(_rts.get_camera_zoom_max()) if _rts.has_method("get_camera_zoom_max") else 95.0,
		"inside_safe_bounds": bool(_rts.is_camera_focus_within_safe_bounds()) if _rts.has_method("is_camera_focus_within_safe_bounds") else true,
		"safe_bounds": _rts.get_camera_safe_bounds() if _rts.has_method("get_camera_safe_bounds") else {},
		"foreground_probe": _foreground_probe(camera_pos, pivot)
	}
	return state

func _foreground_probe(from: Vector3, to: Vector3) -> Dictionary:
	if not _world or not _world.get_world_3d(): return {"available": false}
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	var hit: Dictionary = _world.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty(): return {"available": true, "blocked": false}
	var hit_pos: Vector3 = hit.get("position", to)
	return {"available": true, "blocked": true, "distance": from.distance_to(hit_pos), "target_distance": from.distance_to(to), "collider": str(hit.get("collider", ""))}

func _entity_snapshot() -> Dictionary:
	var out := {}
	if not _world: return out
	for commander in _world.commanders:
		for unit in commander.units:
			if is_instance_valid(unit): out["unit_" + str(unit.get_instance_id())] = _vec(unit.global_position)
		for building in commander.buildings:
			if is_instance_valid(building): out["building_" + str(building.get_instance_id())] = _vec(building.global_position)
	return out

func _vec(v: Vector3) -> Dictionary:
	return {"x": snappedf(v.x, 0.001), "y": snappedf(v.y, 0.001), "z": snappedf(v.z, 0.001)}

func _write_manifest() -> void:
	var manifest := {
		"tool": "p1s2CameraBoundsTool",
		"mode": _mode,
		"capture_mode": "non-headless Godot runtime",
		"paused_for_camera_stress": true,
		"source_sha": OS.get_environment("ASCENDANT_P1S2_SOURCE_SHA"),
		"map": "hollowspan",
		"resolution": {"width": _width, "height": _height},
		"frames": _frames,
		"failures": _failures,
		"pass": _mode == "baseline" or _failures.is_empty()
	}
	var file := FileAccess.open(_output.path_join("camera-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(manifest, "  "))
		file.store_line("")
