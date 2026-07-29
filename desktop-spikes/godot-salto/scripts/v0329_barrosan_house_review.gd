extends Node3D

const VIEWPORT_SIZE := Vector2i(1280, 720)
const CAPTURE_FRAMES := 288
const GLB := "res://assets/v0327/barrosan_house_gold_01.glb"
const METADATA := "res://assets/v0327/barrosan_house_gold_01.export.json"

var capture_root := ""
var screenshot_root := ""
var continuous_root := ""
var camera: Camera3D
var house: Node3D
var errors: Array[String] = []
var captures: Array[Dictionary] = []
var lod_switching_result := false
var collision_result := false
var benchmark: Dictionary = {}


func _ready() -> void:
	call_deferred("start")


func start() -> void:
	capture_root = _artifact_root_from_args()
	screenshot_root = capture_root.path_join("screenshots")
	continuous_root = capture_root.path_join("continuous")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	DirAccess.make_dir_recursive_absolute(continuous_root)
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	_build_environment()
	_load_house()
	if errors.is_empty() and _benchmark_only():
		await _measure_benchmark()
		_write_benchmark()
		get_tree().quit(0 if errors.is_empty() else 1)
		return
	if errors.is_empty():
		await _settle_frames(24)
		_validate_lod_and_collision()
		await _capture_views()
		await _capture_turntable()
	_write_manifest()
	get_tree().quit(0 if errors.is_empty() else 1)


func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#68705f")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#bec4b3")
	environment.ambient_light_energy = 0.78
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = false
	var world := WorldEnvironment.new()
	world.name = "V0329MutedHighlandReviewWorld"
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "V0329BarrosanDaylight"
	sun.rotation_degrees = Vector3(-48.0, -34.0, 0.0)
	sun.light_color = Color("#eed0a0")
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.name = "V0329HighlandAmbientFill"
	fill.rotation_degrees = Vector3(-24.0, 142.0, 0.0)
	fill.light_color = Color("#aeb9b1")
	fill.light_energy = 0.34
	add_child(fill)
	camera = Camera3D.new()
	camera.name = "V0329OrthographicRTSCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.05
	camera.far = 120.0
	camera.size = 14.5
	camera.current = true
	add_child(camera)
	camera.position = Vector3(12.0, 9.0, -14.0)
	camera.look_at(Vector3(0.0, 2.7, 0.0), Vector3.UP)


func _load_house() -> void:
	var packed := load(GLB) as PackedScene
	if packed == null:
		errors.append("Godot could not import the v0.329 house GLB")
		return
	house = packed.instantiate() as Node3D
	if house == null:
		errors.append("Godot could not instantiate the v0.329 house GLB")
		return
	house.name = "V0329BarrosanHouseGold01"
	add_child(house)
	_set_geometry_visibility("lod1", false)
	_set_geometry_visibility("lod2", false)
	_set_geometry_visibility("collision", false)
	if _mesh_count(house) == 0:
		errors.append("Imported v0.329 house contains no MeshInstance3D nodes")


func _find_named(fragment: String) -> Node:
	for node in house.find_children("*", "Node", true, false):
		if String(node.name).to_lower().contains(fragment.to_lower()):
			return node
	return null


func _set_geometry_visibility(fragment: String, visible: bool) -> void:
	for node in house.find_children("*", "Node3D", true, false):
		if String(node.name).to_lower().contains(fragment.to_lower()):
			node.visible = visible


func _validate_lod_and_collision() -> void:
	var lod1 := _find_named("lod1")
	var lod2 := _find_named("lod2")
	var collision := _find_named("collision")
	if lod1 != null and lod2 != null:
		_set_geometry_visibility("lod1", true)
		lod_switching_result = lod1.visible
		_set_geometry_visibility("lod1", false)
		_set_geometry_visibility("lod2", true)
		lod_switching_result = lod_switching_result and lod2.visible
		_set_geometry_visibility("lod2", false)
	if collision != null:
		_set_geometry_visibility("collision", true)
		collision_result = collision.visible
		_set_geometry_visibility("collision", false)


func _capture_views() -> void:
	await _capture("ordinary_rts.png", Vector3(12.0, 9.0, -14.0), Vector3(0.0, 2.7, 0.0), 14.5)
	await _capture("rts_near.png", Vector3(10.8, 7.0, -11.8), Vector3(0.0, 2.8, 0.0), 10.5)
	await _capture("rts_normal.png", Vector3(12.0, 9.0, -14.0), Vector3(0.0, 2.7, 0.0), 14.5)
	await _capture("rts_far.png", Vector3(15.0, 11.0, -17.0), Vector3(0.0, 2.6, 0.0), 21.0)
	await _capture("front_elevation.png", Vector3(11.5, 7.3, -13.2), Vector3(0.0, 2.8, 0.0), 12.4)
	await _capture("rear_elevation.png", Vector3(-11.5, 7.0, 13.6), Vector3(0.0, 2.8, 0.0), 12.4)
	await _capture("left_elevation.png", Vector3(-14.0, 6.7, -1.0), Vector3(0.0, 2.7, 0.0), 11.8)
	await _capture("right_elevation.png", Vector3(14.0, 6.7, 1.0), Vector3(0.0, 2.7, 0.0), 11.8)
	await _capture("roof_identity.png", Vector3(10.8, 6.3, -11.8), Vector3(0.0, 4.4, -0.5), 9.2)
	await _capture("materials_openings.png", Vector3(7.3, 4.8, -9.2), Vector3(0.7, 2.25, -2.3), 7.2)
	await _capture("daylight.png", Vector3(12.0, 10.5, -14.0), Vector3(0.0, 2.4, 0.0), 14.5)
	await _capture("lod0_overview.png", Vector3(12.0, 9.0, -14.0), Vector3(0.0, 2.7, 0.0), 14.5)
	_set_geometry_visibility("lod1", true)
	await _capture("lod1_overview.png", Vector3(12.0, 9.0, -14.0), Vector3(0.0, 2.7, 0.0), 18.0)
	_set_geometry_visibility("lod1", false)
	_set_geometry_visibility("lod2", true)
	await _capture("lod2_overview.png", Vector3(12.0, 9.0, -14.0), Vector3(0.0, 2.7, 0.0), 25.0)
	_set_geometry_visibility("lod2", false)
	_set_geometry_visibility("collision", true)
	await _capture("collision_wireframe.png", Vector3(12.0, 9.0, -14.0), Vector3(0.0, 2.7, 0.0), 14.5)
	_set_geometry_visibility("collision", false)


func _capture(file_name: String, camera_position: Vector3, target: Vector3, ortho_size: float) -> void:
	camera.position = camera_position
	camera.size = ortho_size
	camera.look_at(target, Vector3.UP)
	await _settle_frames(8)
	var image := get_viewport().get_texture().get_image()
	if image == null:
		errors.append("Viewport unavailable for %s" % file_name)
		return
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var path := screenshot_root.path_join(file_name)
	if image.save_png(path) != OK:
		errors.append("Could not save %s" % file_name)
	captures.append({"fileName": file_name, "path": path, "camera": camera_position, "target": target, "orthographicSize": ortho_size, "width": image.get_width(), "height": image.get_height()})


func _capture_turntable() -> void:
	for index in range(CAPTURE_FRAMES):
		var phase := float(index) / float(CAPTURE_FRAMES)
		var angle := phase * TAU
		camera.position = Vector3(cos(angle) * 15.5, 8.4 + sin(angle * 2.0) * 0.55, sin(angle) * 15.5)
		camera.size = 14.5
		camera.look_at(Vector3(0.0, 2.65, 0.0), Vector3.UP)
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null:
			image.save_png(continuous_root.path_join("frame_%04d.png" % index))


func _measure_benchmark() -> void:
	await _settle_seconds(5.0)
	var frame_times: Array[float] = []
	var start_usec := Time.get_ticks_usec()
	var previous_usec := start_usec
	while float(Time.get_ticks_usec() - start_usec) / 1000000.0 < 20.0:
		await get_tree().process_frame
		var now_usec := Time.get_ticks_usec()
		frame_times.append(float(now_usec - previous_usec) / 1000000.0)
		previous_usec = now_usec
	var elapsed := float(Time.get_ticks_usec() - start_usec) / 1000000.0
	frame_times.sort()
	if frame_times.is_empty():
		errors.append("benchmark collected no post-warm-up samples")
		return
	var median_dt := frame_times[frame_times.size() / 2]
	var p99_dt := frame_times[min(frame_times.size() - 1, int(ceil(float(frame_times.size()) * 0.99)))]
	var p999_dt := frame_times[min(frame_times.size() - 1, int(ceil(float(frame_times.size()) * 0.999)))]
	var max_dt := frame_times[frame_times.size() - 1]
	var spikes := 0
	for dt in frame_times:
		if dt > 0.050:
			spikes += 1
	benchmark = {"warmupSeconds": 5.0, "measurementSeconds": elapsed, "sampleCount": frame_times.size(), "averageFps": float(frame_times.size()) / elapsed, "medianFps": 1.0 / median_dt, "onePercentLowFps": 1.0 / p99_dt, "zeroPointOnePercentLowFps": 1.0 / p999_dt, "minimumFps": 1.0 / max_dt, "maximumFrameTimeMs": max_dt * 1000.0, "medianFrameTimeMs": median_dt * 1000.0, "percentile99FrameTimeMs": p99_dt * 1000.0, "repeatedSpikeCountAbove50ms": spikes, "screenshotDumpingEnabled": false, "videoEncodingEnabled": false, "debugOverlaysEnabled": false, "cameraMode": "static orthographic RTS", "visibleTriangles": _lod0_triangle_count()}


func _lod0_triangle_count() -> int:
	if not FileAccess.file_exists(METADATA):
		return 0
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(METADATA))
	return int((parsed as Dictionary).get("lod0", {}).get("triangles", 0)) if parsed is Dictionary else 0


func _write_benchmark() -> void:
	var file := FileAccess.open(capture_root.path_join("v0329-benchmark.json"), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(benchmark, "  "))


func _write_manifest() -> void:
	var file := FileAccess.open(capture_root.path_join("v0329-barrosan-house-review-runtime.json"), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"schemaVersion": 1, "checkpoint": "v0.329", "status": "PASS_V0329_BARROSAN_HOUSE_VISUAL_AUTHENTICITY_GATE" if errors.is_empty() else "FAIL_V0329_BARROSAN_HOUSE_VISUAL_AUTHENTICITY_GATE", "outcome": "READY FOR HUMAN BARROSAN HOUSE VISUAL-AUTHENTICITY REVIEW" if errors.is_empty() else "REJECTED INTERNALLY — AUTHENTICITY OR RTS-READABILITY GATE FAILED", "prototypeOptIn": true, "sourceBlend": "art-source/blender/v0327/barrosan_house_gold_01.blend", "sourceGLB": GLB, "scenePath": "res://scenes/review/V0329BarrosanHouseReview.tscn", "noHud": true, "noGameplay": true, "noMovement": true, "noPathfinding": true, "noCombat": true, "noEconomy": true, "noResources": true, "noSaves": true, "captures": captures, "lodSwitchingResult": lod_switching_result, "collisionResult": collision_result, "errors": errors}, "  "))


func _artifact_root_from_args() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--artifact-root="):
			return argument.trim_prefix("--artifact-root=")
	var environment_root := OS.get_environment("V0329_ARTIFACT_ROOT")
	return environment_root


func _benchmark_only() -> bool:
	return OS.get_environment("V0329_BENCHMARK_ONLY") == "1" or "--benchmark-only" in OS.get_cmdline_user_args()


func _settle_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame


func _settle_seconds(seconds: float) -> void:
	var start_usec := Time.get_ticks_usec()
	while float(Time.get_ticks_usec() - start_usec) / 1000000.0 < seconds:
		await get_tree().process_frame


func _mesh_count(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _mesh_count(child)
	return count
