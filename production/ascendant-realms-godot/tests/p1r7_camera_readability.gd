extends Node
## P1-R7 headed proof: the real RTS camera presents readable default-scale units
## without changing safe bounds, unit positions, or gameplay state.

var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _failures: Array = []
var _world: Node
var _rts: Node
var _before_entities := {}

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R7_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1R7_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1R7_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1-remediation-b/p1r7/default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	get_node("/root/Match").set_config({
		"player_race": "lioraen", "opponents": [{"race": "barrosan", "difficulty": "easy"}],
		"map": "hollowspan", "start_resources": "standard", "victory": "conquest",
		"mode": "skirmish", "game_speed": 1.0
	})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	var deadline := Time.get_ticks_msec() + 20000
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
	_before_entities = _entity_snapshot()
	if abs(float(_rts._zoom) - float(_rts.get_camera_default_zoom())) > 0.01:
		_failures.append("initial_zoom_not_default")
	if float(_rts.get_camera_pitch_degrees()) != -55.0:
		_failures.append("pitch_contract_changed")
	var base_focus: Vector3 = _world.commanders[0].buildings[0].global_position if _world.commanders.size() > 0 and _world.commanders[0].buildings.size() > 0 else Vector3.ZERO
	if _width == 1366:
		await _capture_case("07_1366_DEFAULT_ARMY", base_focus, _rts.get_camera_default_zoom())
	else:
		await _capture_case("01_DEFAULT_LIORAEN_BASE", base_focus, _rts.get_camera_default_zoom())
		await _capture_case("02_DEFAULT_LIORAEN_MIXED_ARMY", base_focus, _rts.get_camera_default_zoom())
		var worker = _find_role("worker")
		var military = _find_military()
		var hero = _find_hero()
		await _capture_case("03_NEAR_WORKER", worker.global_position if worker else Vector3.ZERO, 25.0)
		await _capture_case("04_NEAR_MILITARY", military.global_position if military else Vector3.ZERO, 25.0)
		await _capture_case("05_NEAR_HERO", hero.global_position if hero else Vector3.ZERO, 25.0)
		await _capture_case("06_FAR_ARMY", base_focus, 95.0)
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _capture_case(name: String, focus: Vector3, zoom: float) -> void:
	_rts.edge_scroll = false
	_rts._zoom = zoom
	_rts.cam_arm.spring_length = zoom
	_rts.focus_on(focus)
	for _i in 12: await get_tree().process_frame
	var state := _camera_state()
	var after := _entity_snapshot()
	if after != _before_entities: _failures.append(name + ":entity_positions_changed")
	if not state.get("inside_safe_bounds", false): _failures.append(name + ":outside_safe_bounds")
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		_failures.append(name + ":empty_frame")
		return
	var png := _output.path_join(name + ".png")
	image.save_png(png)
	_frames.append({"name": name, "png": png, "width": image.get_width(), "height": image.get_height(), "state": state, "entity_positions_unchanged": after == _before_entities})

func _camera_state() -> Dictionary:
	var worker = _find_role("worker")
	var military = _find_military()
	var hero = _find_hero()
	return {
		"zoom": float(_rts._zoom), "default_zoom": float(_rts.get_camera_default_zoom()),
		"pitch_degrees": float(_rts.get_camera_pitch_degrees()),
		"zoom_min": float(_rts.get_camera_zoom_min()), "zoom_max": float(_rts.get_camera_zoom_max()),
		"inside_safe_bounds": bool(_rts.is_camera_focus_within_safe_bounds()),
		"safe_bounds": _rts.get_camera_safe_bounds(),
		"screen_heights": {"worker": _screen_height(worker), "military": _screen_height(military), "hero": _screen_height(hero)}
	}

func _screen_height(unit) -> float:
	if not is_instance_valid(unit): return 0.0
	var h := maxf(1.0, float(unit.get("_visual_height")))
	var top: Vector2 = _rts.camera.unproject_position(unit.global_position + Vector3.UP * h)
	var bottom: Vector2 = _rts.camera.unproject_position(unit.global_position)
	return abs(top.y - bottom.y)

func _find_role(role: String):
	for u in _world.commanders[0].units:
		if is_instance_valid(u) and not u.is_dead and String(u.def.get("role", "")) == role: return u
	return null

func _find_military():
	for u in _world.commanders[0].units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero: return u
	return null

func _find_hero():
	return _world.commanders[0].hero_ref if _world.commanders.size() > 0 else null

func _entity_snapshot() -> Dictionary:
	var out := {}
	for c in _world.commanders:
		for u in c.units:
			if is_instance_valid(u): out["u_" + str(u.get_instance_id())] = _vec(u.global_position)
		for b in c.buildings:
			if is_instance_valid(b): out["b_" + str(b.get_instance_id())] = _vec(b.global_position)
	return out

func _vec(v: Vector3) -> Dictionary:
	return {"x": snappedf(v.x, 0.001), "y": snappedf(v.y, 0.001), "z": snappedf(v.z, 0.001)}

func _write_manifest() -> void:
	var file := FileAccess.open(_output.path_join("camera-readability-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"schema": "ascendant-realms-p1r7-camera-readability-v1", "source_sha": OS.get_environment("ASCENDANT_P1R7_SOURCE_SHA"), "resolution": {"width": _width, "height": _height}, "frames": _frames, "failures": _failures, "pass": _failures.is_empty()}, "  "))
		file.store_line("")
