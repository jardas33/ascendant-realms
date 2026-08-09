extends Node
## P1-R13 headed proof: role silhouettes are readable without changing gameplay geometry.

var _output := ""
var _width := 1920
var _height := 1080
var _label := "LIORAEN_DEFAULT"
var _world: Node
var _rts: Node
var _frames: Array = []
var _failures: Array = []
var _before_entities := {}

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R13_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1R13_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1R13_HEIGHT"))
	_label = OS.get_environment("ASCENDANT_P1R13_LABEL")
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _label.is_empty(): _label = "LIORAEN_DEFAULT"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	var race := OS.get_environment("ASCENDANT_P1R13_RACE")
	if race.is_empty(): race = "lioraen"
	get_node("/root/Match").set_config({
		"player_race": race, "opponents": [{"race": "barrosan" if race != "barrosan" else "lioraen", "difficulty": "easy"}],
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
	_before_entities = _entity_snapshot()
	await _capture_case("01_R13_%s" % _label, _world.commanders[0].buildings[0].global_position, _rts.get_camera_default_zoom())
	if _label == "LIORAEN_DEFAULT":
		var hero = _find_hero()
		await _capture_case("02_R13_LIORAEN_NEAR", hero.global_position if hero else Vector3.ZERO, 25.0)
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _capture_case(name: String, focus: Vector3, zoom: float) -> void:
	_rts.edge_scroll = false
	_rts._zoom = zoom
	_rts.cam_arm.spring_length = zoom
	_rts.focus_on(focus)
	for _i in 14: await get_tree().process_frame
	var after := _entity_snapshot()
	if after != _before_entities: _failures.append(name + ":entity_positions_changed")
	var measurements := _measure_units()
	if measurements.get("worker", 0.0) < (50.0 if zoom < 30.0 else 28.0): _failures.append(name + ":worker_below_target")
	if measurements.get("military", 0.0) < (55.0 if zoom < 30.0 else 30.0): _failures.append(name + ":military_below_target")
	if measurements.get("hero", 0.0) < (65.0 if zoom < 30.0 else 36.0): _failures.append(name + ":hero_below_target")
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		_failures.append(name + ":empty_frame")
		return
	var sampled := {}
	for sx in range(0, image.get_width(), max(1, image.get_width() / 12)):
		for sy in range(0, image.get_height(), max(1, image.get_height() / 8)):
			var c := image.get_pixel(sx, sy)
			sampled["%d,%d,%d" % [int(c.r * 12.0), int(c.g * 12.0), int(c.b * 12.0)]] = true
	if sampled.size() < 8:
		_failures.append(name + ":blank_or_low_variance_frame")
		return
	var png := _output.path_join(name + ".png")
	image.save_png(png)
	_frames.append({"name": name, "png": png, "width": image.get_width(), "height": image.get_height(), "zoom": zoom, "pitch_degrees": float(_rts.get_camera_pitch_degrees()), "measurements": measurements, "entity_positions_unchanged": after == _before_entities})

func _measure_units() -> Dictionary:
	var result := {"worker": 0.0, "military": 0.0, "hero": 0.0}
	for c in _world.commanders:
		for u in c.units:
			if not is_instance_valid(u) or u.is_dead: continue
			var h := maxf(1.0, float(u.get("_visual_height")))
			var top: Vector2 = _rts.camera.unproject_position(u.global_position + Vector3.UP * h)
			var bottom: Vector2 = _rts.camera.unproject_position(u.global_position)
			var pixels := abs(top.y - bottom.y)
			var role := "hero" if u.is_hero else ("worker" if u.is_worker else "military")
			result[role] = maxf(float(result[role]), pixels)
	return result

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
	var file := FileAccess.open(_output.path_join("unit-readability-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"schema":"ascendant-realms-p1r13-unit-readability-v1", "source_sha":OS.get_environment("ASCENDANT_P1R13_SOURCE_SHA"), "race":OS.get_environment("ASCENDANT_P1R13_RACE"), "resolution":{"width":_width,"height":_height}, "frames":_frames, "failures":_failures, "pass":_failures.is_empty()}, "  "))
		file.store_line("")
