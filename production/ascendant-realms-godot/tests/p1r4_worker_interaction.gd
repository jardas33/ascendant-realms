extends Node
## P1-R4 headed proof: workers travel to, settle at, face, and work on a
## resource/build target without visible correction oscillation. The harness
## records position/velocity; it does not change worker rates or production
## rules and does not issue combat commands.

var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _failures: Array = []
var _samples := {"gather": [], "build": []}
var _worker = null
var _world = null
var _rts = null

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R4_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1R4_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1R4_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1-remediation-a/p1r4/default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	get_node("/root/Match").set_config({
		"player_race": "barrosan", "opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": "hollowspan", "start_resources": "standard", "victory": "conquest",
		"mode": "skirmish", "game_speed": 1.0
	})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	var deadline := Time.get_ticks_msec() + 20000
	while Time.get_ticks_msec() < deadline:
		var root = get_node_or_null("/root/GameRoot")
		_world = root.get_node_or_null("GameWorld") if root else null
		_rts = root.get_node_or_null("RTS") if root else null
		if _world and _rts and _world.game_running: break
		await get_tree().process_frame
	if _world == null or _rts == null or not _world.game_running:
		_failures.append("runtime_timeout")
		_write_manifest()
		get_tree().quit(1)
		return
	for _i in 12: await get_tree().process_frame
	_worker = _find_worker()
	var resource = _find_resource()
	if not is_instance_valid(_worker): _failures.append("missing_worker")
	if not is_instance_valid(resource): _failures.append("missing_resource")
	if not _failures.is_empty():
		_write_manifest(); get_tree().quit(1); return
	_worker.command_gather(resource)
	await _sample_phase("gather", 3.0)
	await _capture("gather")

	# Create an isolated, unfinished construction target through the existing
	# world factory. This is a review fixture; no cost is spent and no gameplay
	# definition or build transaction is changed.
	var bdef := GameData.get_building("barrosan_clan_croft").duplicate()
	bdef["id"] = "barrosan_clan_croft"
	var build_pos: Vector3 = _worker.global_position + Vector3(8.0, 0.0, 0.0)
	var build_target = _world.call("_create_building", bdef, _worker.team, build_pos, false)
	if not is_instance_valid(build_target):
		_failures.append("missing_build_target")
	else:
		_worker.command_build(build_target)
		await _sample_phase("build", 3.0)
		await _capture("build")
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _find_worker():
	for u in _world.player_commander.units:
		if is_instance_valid(u) and not u.is_dead and u.is_worker: return u
	return null

func _find_resource():
	var fallback = null
	for n in get_tree().get_nodes_in_group("resources"):
		if not is_instance_valid(n) or n.depleted: continue
		if fallback == null: fallback = n
		if n.resource_kind == "food": return n
	return fallback

func _sample_phase(kind: String, seconds: float) -> void:
	var end := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < end:
		if is_instance_valid(_worker):
			_samples[kind].append({"t": Time.get_ticks_msec(), "position": _vec(_worker.global_position), "velocity": _vec(_worker.velocity), "speed": _worker.velocity.length(), "state": int(_worker.state)})
		await get_tree().process_frame

func _capture(kind: String) -> void:
	if not is_instance_valid(_worker): return
	_rts.edge_scroll = false
	_rts._cam_yaw = 0.0
	_rts._zoom = 32.0
	_rts.cam_arm.spring_length = 32.0
	_rts.focus_on(_worker.global_position)
	for _i in 8: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := _output.path_join(kind + ".png")
	image.save_png(path)
	_frames.append({"name": kind, "png": path, "width": image.get_width(), "height": image.get_height(), "sample_count": _samples[kind].size(), "final_state": int(_worker.state), "final_position": _vec(_worker.global_position)})

func _vec(p: Vector3) -> Dictionary:
	return {"x": p.x, "y": p.y, "z": p.z}

func _write_manifest() -> void:
	var metrics := {}
	for kind in _samples:
		var values: Array = _samples[kind]
		var max_speed := 0.0
		var tail_speed := 0.0
		for s in values: max_speed = maxf(max_speed, float(s["speed"]))
		var tail_start := maxi(0, values.size() - 30)
		for i in range(tail_start, values.size()): tail_speed = maxf(tail_speed, float(values[i]["speed"]))
		metrics[kind] = {"sample_count": values.size(), "max_speed": max_speed, "tail_max_speed": tail_speed, "first": values[0] if not values.is_empty() else {}, "last": values[-1] if not values.is_empty() else {}}
	var manifest := {"schema": "ascendant-realms-p1r4-worker-interaction-v1", "source_sha": OS.get_environment("ASCENDANT_P1R4_SOURCE_SHA"), "resolution": {"width": _width, "height": _height}, "frames": _frames, "samples": _samples, "metrics": metrics, "pass": _failures.is_empty(), "failures": _failures}
	FileAccess.open(_output.path_join("worker-interaction-manifest.json"), FileAccess.WRITE).store_string(JSON.stringify(manifest, "  "))
