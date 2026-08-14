extends Node
## P1 RESOURCES-01 headed proof: resource identity at normal RTS scale.

var _output := ""
var _width := 1920
var _height := 1080
var _world: Node
var _rts: Node
var _frames: Array = []
var _failures: Array = []

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1_RESOURCES_OUTPUT")
	_width = maxi(1, int(OS.get_environment("ASCENDANT_P1_RESOURCES_WIDTH")))
	_height = maxi(1, int(OS.get_environment("ASCENDANT_P1_RESOURCES_HEIGHT")))
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
	for _i in 18: await get_tree().process_frame
	get_tree().paused = true
	_rts.edge_scroll = false
	var resources: Array = get_tree().get_nodes_in_group("resources")
	var by_kind := {}
	for resource in resources:
		var kind := String(resource.get("resource_kind"))
		if not by_kind.has(kind): by_kind[kind] = resource
	if by_kind.size() < 4:
		_failures.append("missing_resource_kinds:%d" % by_kind.size())
	for kind in ["stone", "timber", "gold", "food"]:
		if not by_kind.has(kind): continue
		await _capture_resource(kind, by_kind[kind], 48.0)
	var mixed: Array = []
	for resource in resources:
		if mixed.is_empty() or mixed[0].global_position.distance_to(resource.global_position) < 38.0:
			mixed.append(resource)
	if mixed.size() >= 2:
		var center := Vector3.ZERO
		for resource in mixed: center += resource.global_position
		center /= float(mixed.size())
		await _capture_position("mixed_resource_area", center, 56.0, {"resource_count": mixed.size()})
	else:
		_failures.append("missing_mixed_resource_area")
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _capture_resource(kind: String, resource: Node, zoom: float) -> void:
	await _capture_position("resource_%s" % kind, resource.global_position, zoom, {
		"resource_kind": kind,
		"resource_position": _vec(resource.global_position),
		"amount": int(resource.get("amount")),
		"model_root": String(resource.get("model_root").name) if resource.get("model_root") else ""
	})

func _capture_position(label: String, position: Vector3, zoom: float, metadata: Dictionary) -> void:
	_rts._zoom = zoom
	_rts.focus_on(position)
	for _i in 18: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		_failures.append("empty_frame:%s" % label)
		return
	var sampled := {}
	for sx in range(0, image.get_width(), maxi(1, image.get_width() / 16)):
		for sy in range(0, image.get_height(), maxi(1, image.get_height() / 10)):
			var c := image.get_pixel(sx, sy)
			sampled["%d,%d,%d" % [int(c.r * 12.0), int(c.g * 12.0), int(c.b * 12.0)]] = true
	if sampled.size() < 8:
		_failures.append("blank_or_low_variance_frame:%s" % label)
	var png := _output.path_join("%02d_R01_%s.png" % [_frames.size() + 1, label.to_upper()])
	image.save_png(png)
	_frames.append({"label": label, "png": png, "width": image.get_width(), "height": image.get_height(), "zoom": zoom, "focus": _vec(position), "metadata": metadata})

func _vec(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _write_manifest() -> void:
	var file := FileAccess.open(_output.path_join("resource-readability-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"schema": "ascendant-realms-p1-resources-01-readability-v1",
			"source_sha": OS.get_environment("ASCENDANT_P1_RESOURCES_SOURCE_SHA"),
			"resolution": {"width": _width, "height": _height},
			"frames": _frames,
			"failures": _failures,
			"pass": _failures.is_empty()
		}, "  "))
		file.store_line("")
