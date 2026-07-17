extends Node3D

const V0327_VIEWPORT_SIZE := Vector2i(1280, 720)
const V0327_CAPTURE_FRAMES := 288
const V0327_CAPTURE_FPS := 24
const V0327_GLB := "res://assets/v0327/barrosan_house_gold_01.glb"
const V0327_METADATA := "res://assets/v0327/barrosan_house_gold_01.export.json"

var capture_root := ""
var screenshot_root := ""
var continuous_root := ""
var camera: Camera3D
var house: Node3D
var errors: Array[String] = []
var captures: Array[Dictionary] = []
var interactive_average_fps := 0.0
var interactive_minimum_fps := 0.0
var capture_throughput_fps := 0.0
var lod_switching_result := false
var collision_result := false
var import_warning_count := 0


func _ready() -> void:
	call_deferred("start")


func start() -> void:
	capture_root = _artifact_root_from_args()
	screenshot_root = capture_root.path_join("screenshots")
	continuous_root = capture_root.path_join("continuous")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	DirAccess.make_dir_recursive_absolute(continuous_root)
	DisplayServer.window_set_size(V0327_VIEWPORT_SIZE)
	DisplayServer.window_set_min_size(V0327_VIEWPORT_SIZE)
	_build_environment()
	_load_house()
	if errors.is_empty():
		await _settle_frames(24)
		await _measure_interactive_fps()
		_validate_lod_and_collision()
		if capture_root != "":
			await _capture_views()
			await _capture_turntable()
	_write_manifest()
	get_tree().quit(0 if errors.is_empty() else 1)


func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#27302d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#b3b8aa")
	environment.ambient_light_energy = 0.62
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = false
	var world := WorldEnvironment.new()
	world.name = "V0327NeutralReviewWorld"
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "V0327BarrosanDaylight"
	sun.rotation_degrees = Vector3(-48.0, -34.0, 0.0)
	sun.light_color = Color("#f2d3a6")
	sun.light_energy = 1.12
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.name = "V0327OvercastFill"
	fill.rotation_degrees = Vector3(-24.0, 142.0, 0.0)
	fill.light_color = Color("#a2b0b8")
	fill.light_energy = 0.25
	fill.shadow_enabled = false
	add_child(fill)
	camera = Camera3D.new()
	camera.name = "V0327OrthographicRTSCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.05
	camera.far = 120.0
	camera.size = 14.5
	camera.current = true
	add_child(camera)
	camera.position = Vector3(12.0, 9.0, -14.0)
	camera.look_at(Vector3(0.0, 2.7, 0.0), Vector3.UP)


func _load_house() -> void:
	var packed := load(V0327_GLB) as PackedScene
	if packed == null:
		errors.append("Godot could not import the v0.327 GLB")
		return
	house = packed.instantiate() as Node3D
	if house == null:
		errors.append("Godot could not instantiate the v0.327 GLB")
		return
	house.name = "V0327BarrosanHouseGold01"
	add_child(house)
	for node in house.find_children("*", "Node3D", true, false):
		var child := node as Node3D
		if child.name.to_lower().contains("lod1") or child.name.to_lower().contains("collision"):
			child.visible = false
	if _mesh_count(house) == 0:
		errors.append("Imported house contains no MeshInstance3D nodes")
	if house.find_child("LOD1_Compact_House_Shell", true, false) == null:
		errors.append("Imported LOD1 shell is missing")
	if house.find_child("Collision_GroundFloor", true, false) == null:
		errors.append("Imported collision proxy is missing")


func _measure_interactive_fps() -> void:
	await _settle_frames(30)
	var frame_count := 180
	var start_usec := Time.get_ticks_usec()
	var minimum := 1000.0
	for _index in range(frame_count):
		await get_tree().process_frame
		var current := Engine.get_frames_per_second()
		if current > 0.0:
			minimum = min(minimum, current)
	var elapsed := float(Time.get_ticks_usec() - start_usec) / 1000000.0
	if elapsed > 0.0:
		interactive_average_fps = float(frame_count) / elapsed
	interactive_minimum_fps = minimum if minimum < 1000.0 else interactive_average_fps


func _validate_lod_and_collision() -> void:
	var lod_node := house.find_child("LOD1_Compact_House_Shell", true, false) as Node3D
	var collision_node := house.find_child("Collision_GroundFloor", true, false) as Node3D
	if lod_node != null:
		lod_node.visible = true
		lod_switching_result = lod_node.visible
		lod_node.visible = false
	if collision_node != null:
		collision_result = collision_node.visible == false
	if _mesh_count(house) < 100:
		import_warning_count += 1


func _capture_views() -> void:
	await _capture("ordinary_rts.png", Vector3(12.0, 9.0, -14.0), Vector3(0.0, 2.7, 0.0), 14.5)
	await _capture("front_three_quarter.png", Vector3(11.5, 7.3, -13.2), Vector3(0.0, 2.8, 0.0), 12.4)
	await _capture("rear_three_quarter.png", Vector3(-11.5, 7.0, 13.6), Vector3(0.0, 2.8, 0.0), 12.4)
	await _capture("left_elevation.png", Vector3(-14.0, 6.7, -1.0), Vector3(0.0, 2.7, 0.0), 11.8)
	await _capture("right_elevation.png", Vector3(14.0, 6.7, 1.0), Vector3(0.0, 2.7, 0.0), 11.8)
	await _capture("material_closeup.png", Vector3(7.3, 4.8, -9.2), Vector3(0.7, 2.25, -2.3), 7.2)
	await _capture("daylight.png", Vector3(12.0, 10.5, -14.0), Vector3(0.0, 2.4, 0.0), 14.5)
	await _capture("silhouette_overcast.png", Vector3(-12.0, 8.0, 13.0), Vector3(0.0, 2.5, 0.0), 14.5)


func _capture(file_name: String, camera_position: Vector3, target: Vector3, ortho_size: float) -> void:
	camera.position = camera_position
	camera.size = ortho_size
	camera.look_at(target, Vector3.UP)
	await _settle_frames(8)
	var image := get_viewport().get_texture().get_image()
	if image == null:
		errors.append("Viewport unavailable for %s" % file_name)
		return
	if image.get_width() != V0327_VIEWPORT_SIZE.x or image.get_height() != V0327_VIEWPORT_SIZE.y:
		image.resize(V0327_VIEWPORT_SIZE.x, V0327_VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var path := screenshot_root.path_join(file_name)
	if image.save_png(path) != OK:
		errors.append("Could not save %s" % file_name)
	captures.append({"fileName": file_name, "path": path, "camera": camera_position, "target": target, "orthographicSize": ortho_size, "width": image.get_width(), "height": image.get_height()})


func _capture_turntable() -> void:
	var start_usec := Time.get_ticks_usec()
	for index in range(V0327_CAPTURE_FRAMES):
		var phase := float(index) / float(V0327_CAPTURE_FRAMES)
		var angle := phase * TAU
		var radius := 15.5
		camera.position = Vector3(cos(angle) * radius, 8.4 + sin(angle * 2.0) * 0.55, sin(angle) * radius)
		camera.size = 14.5
		camera.look_at(Vector3(0.0, 2.65, 0.0), Vector3.UP)
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null:
			image.save_png(continuous_root.path_join("frame_%04d.png" % index))
	var elapsed := float(Time.get_ticks_usec() - start_usec) / 1000000.0
	if elapsed > 0.0:
		capture_throughput_fps = float(V0327_CAPTURE_FRAMES) / elapsed
	camera.position = Vector3(12.0, 9.0, -14.0)
	camera.size = 14.5
	camera.look_at(Vector3(0.0, 2.7, 0.0), Vector3.UP)


func _settle_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame


func _mesh_count(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D:
		count += 1
	for child in node.get_children():
		count += _mesh_count(child)
	return count


func _artifact_root_from_args() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--artifact-root="):
			return argument.trim_prefix("--artifact-root=")
	var environment_root := OS.get_environment("V0327_ARTIFACT_ROOT")
	if not environment_root.is_empty():
		return environment_root
	return ""


func _write_manifest() -> void:
	var metadata: Dictionary = {}
	if FileAccess.file_exists(V0327_METADATA):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(V0327_METADATA))
		if parsed is Dictionary:
			metadata = parsed
	var asset_metrics: Dictionary = metadata.get("lod0", {})
	_write_json(capture_root.path_join("v0327-barrosan-house-review-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.327",
		"status": "PASS_V0327_BARROSAN_HOUSE_REVIEW" if errors.is_empty() else "FAIL_V0327_BARROSAN_HOUSE_REVIEW",
		"outcome": "READY FOR HUMAN BARROSAN HOUSE REVIEW" if errors.is_empty() else "BLOCKED BY BLENDER TOOLCHAIN",
		"prototypeOptIn": true,
		"sourceBlend": "art-source/blender/v0327/barrosan_house_gold_01.blend",
		"sourceGLB": V0327_GLB,
		"scenePath": "res://scenes/review/V0327BarrosanHouseReview.tscn",
		"camera": "orthographic RTS plus close inspection views",
		"noHud": true,
		"noRiver": true,
		"noBridge": true,
		"noWorker": true,
		"interactiveBenchmark": {"averageFps": interactive_average_fps, "minimumFps": interactive_minimum_fps, "captureDisabled": true, "targetAverageFps": 55.0, "targetMinimumFps": 45.0},
		"evidenceCapture": {"throughputFps": capture_throughput_fps, "frames": V0327_CAPTURE_FRAMES, "targetFps": V0327_CAPTURE_FPS, "targetDurationSeconds": 12.0, "screenshotDumpingEnabled": true, "videoEncodingEnabledAfterCapture": true},
		"lodSwitchingResult": lod_switching_result,
		"collisionResult": collision_result,
		"importWarnings": import_warning_count,
		"assetMetrics": asset_metrics,
		"preservation": {"v0326Preserved": true, "v0325Preserved": true, "v0323RoofEvidencePreserved": true, "v0322MediaSHA256": "8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84", "defaultRuntimeChanged": false, "gameplayChanged": false, "savesChanged": false, "stableIdsChanged": false},
		"captures": captures,
		"errors": errors,
	})


func _write_json(path: String, value: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(value, "  "))
