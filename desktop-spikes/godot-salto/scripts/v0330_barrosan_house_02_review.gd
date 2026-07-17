extends Node3D

const VIEWPORT_SIZE := Vector2i(1280, 720)
const CAPTURE_FRAMES := 120
const GLB := "res://assets/v0330/barrosan_house_gold_02.glb"
const METRICS := "res://assets/v0330/barrosan_house_gold_02.export.json"

var capture_root := ""
var screenshot_root := ""
var continuous_root := ""
var camera: Camera3D
var house: Node3D
var errors: Array[String] = []
var captures: Array[Dictionary] = []


func _ready() -> void:
	call_deferred("start")


func start() -> void:
	capture_root = _artifact_root_from_args()
	if capture_root.is_empty():
		get_tree().quit(0)
		return
	screenshot_root = capture_root.path_join("screenshots")
	continuous_root = capture_root.path_join("continuous")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	DirAccess.make_dir_recursive_absolute(continuous_root)
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	_build_environment()
	_build_sector()
	_load_house()
	if OS.get_environment("V0330_BENCHMARK_ONLY") == "1":
		await _measure_benchmark()
		get_tree().quit(0 if errors.is_empty() else 1)
		return
	if errors.is_empty():
		await _settle_frames(24)
		await _capture_views()
		await _capture_turntable()
	_write_manifest()
	get_tree().quit(0 if errors.is_empty() else 1)


func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#505947")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#c4c4ad")
	environment.ambient_light_energy = 0.58
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = false
	var world := WorldEnvironment.new()
	world.name = "V0330HighlandDocumentaryWorld"
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "V0330ConsistentWarmKey"
	sun.rotation_degrees = Vector3(-50.0, -34.0, 0.0)
	sun.light_color = Color("#f0cf9d")
	sun.light_energy = 0.88
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.name = "V0330HighlandFill"
	fill.rotation_degrees = Vector3(-24.0, 142.0, 0.0)
	fill.light_color = Color("#aabdbb")
	fill.light_energy = 0.22
	add_child(fill)
	camera = Camera3D.new()
	camera.name = "V0330ObliqueRTSCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.05
	camera.far = 160.0
	camera.size = 17.0
	camera.current = true
	add_child(camera)
	camera.position = Vector3(16.0, 12.0, -18.0)
	camera.look_at(Vector3(0.5, 2.0, 0.0), Vector3.UP)


func _mat(color: Color, roughness := 0.86, metallic := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material


func _box(name: String, position: Vector3, size: Vector3, material: Material, rotation := Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.rotation = rotation
	add_child(instance)
	return instance


func _cylinder(name: String, position: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 1.08
	mesh.height = height
	mesh.radial_segments = 16
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	add_child(instance)
	return instance


func _build_sector() -> void:
	var grass := _mat(Color("#59654c"), 0.96)
	var earth := _mat(Color("#776047"), 0.98)
	var water := _mat(Color("#294d55"), 0.28)
	var stone := _mat(Color("#77776a"), 0.95)
	var timber := _mat(Color("#4a3222"), 0.90)
	var roof := _mat(Color("#30383a"), 0.92)
	# Split land slabs leave the river visibly recessed below the banks.
	_box("West_Grass_Terrace", Vector3(-1.65, -0.18, 0.0), Vector3(9.1, 0.55, 18.0), grass)
	_box("East_Grass_Terrace", Vector3(9.10, -0.18, 0.0), Vector3(7.8, 0.55, 18.0), grass)
	_box("Recessed_River", Vector3(4.55, -0.52, 0.0), Vector3(3.0, 0.16, 18.0), water)
	# Believable road surfaces terminate at the bridge rather than floating over it.
	_box("West_Road_Embedded", Vector3(-2.0, 0.18, -2.0), Vector3(6.8, 0.18, 2.2), earth, Vector3(0.0, 0.0, -0.03))
	_box("East_Road_Embedded", Vector3(8.4, 0.18, -2.0), Vector3(5.8, 0.18, 2.2), earth, Vector3(0.0, 0.0, 0.03))
	# Timber bridge deck, stone abutments, supports, and rails.
	_box("Bridge_Deck", Vector3(4.55, 0.62, -2.0), Vector3(4.5, 0.42, 3.0), timber)
	_box("Bridge_Stone_Abutment_W", Vector3(2.45, 0.34, -2.0), Vector3(0.55, 0.82, 3.5), stone)
	_box("Bridge_Stone_Abutment_E", Vector3(6.65, 0.34, -2.0), Vector3(0.55, 0.82, 3.5), stone)
	for z in [-3.25, -0.75]:
		_box("Bridge_Rail", Vector3(4.55, 1.03, z), Vector3(4.5, 0.18, 0.18), timber)
		_box("Bridge_Rail_Post_L", Vector3(3.45, 0.92, z), Vector3(0.16, 0.75, 0.16), timber)
		_box("Bridge_Rail_Post_R", Vector3(5.65, 0.92, z), Vector3(0.16, 0.75, 0.16), timber)
	# Quiet bank stones create a natural transition without a debug pad.
	for index in range(8):
		var z := -7.0 + float(index) * 2.0
		_box("West_Bank_Stone_%02d" % index, Vector3(2.85 + sin(float(index)) * 0.14, 0.28, z), Vector3(0.55, 0.5, 1.1), stone, Vector3(0.0, float(index) * 0.22, 0.08))
		_box("East_Bank_Stone_%02d" % index, Vector3(6.25 + cos(float(index)) * 0.14, 0.28, z + 0.35), Vector3(0.55, 0.5, 1.0), stone, Vector3(0.0, float(index) * 0.19, -0.08))
	# Small authored support building: same material vocabulary, secondary scale.
	_box("Support_Shed_Walls", Vector3(-5.2, 0.62, 3.8), Vector3(2.5, 1.45, 2.5), stone)
	_box("Support_Shed_Door", Vector3(-5.2, 0.72, 2.52), Vector3(0.75, 1.0, 0.10), timber)
	_box("Support_Shed_Roof", Vector3(-5.2, 1.48, 3.8), Vector3(2.9, 0.18, 2.9), roof, Vector3(0.12, 0.0, 0.0))
	# Three static units; no animation, input, movement, or gameplay semantics.
	_unit("Aster_Review_Unit", Vector3(-4.2, 0.25, -0.4), Color("#d1ad72"), Color("#273b36"))
	_unit("Defender_Review_Unit", Vector3(7.65, 0.25, -3.2), Color("#7ca38c"), Color("#26343b"))
	_unit("Reserve_Support_Review_Unit", Vector3(7.35, 0.25, -0.6), Color("#a8b6a0"), Color("#343a31"))


func _unit(name: String, position: Vector3, accent: Color, body: Color) -> void:
	var root := Node3D.new()
	root.name = name
	root.position = position
	add_child(root)
	var ring := CylinderMesh.new()
	ring.top_radius = 0.62
	ring.bottom_radius = 0.62
	ring.height = 0.035
	ring.radial_segments = 24
	var ring_instance := MeshInstance3D.new()
	ring_instance.name = name + "_SelectionGrounding"
	ring_instance.mesh = ring
	ring_instance.material_override = _mat(Color(accent, 0.32), 0.92)
	root.add_child(ring_instance)
	var body_instance := MeshInstance3D.new()
	body_instance.name = name + "_BillboardBody"
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.28
	body_mesh.height = 1.05
	body_mesh.radial_segments = 12
	body_mesh.rings = 4
	body_instance.mesh = body_mesh
	body_instance.material_override = _mat(body)
	body_instance.position.y = 0.66
	root.add_child(body_instance)
	var head := MeshInstance3D.new()
	head.name = name + "_Head"
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.22
	head_mesh.height = 0.44
	head.mesh = head_mesh
	head.material_override = _mat(accent)
	head.position.y = 1.42
	root.add_child(head)


func _load_house() -> void:
	var packed := load(GLB) as PackedScene
	if packed == null:
		errors.append("Godot could not import v0.330 House 02 GLB")
		return
	house = packed.instantiate() as Node3D
	if house == null:
		errors.append("Godot could not instantiate v0.330 House 02 GLB")
		return
	house.name = "BarrosanHouse02ReferenceGrounded"
	house.position = Vector3(-2.6, 0.18, -1.5)
	add_child(house)
	_apply_house_material_language()
	_set_fragment_visible("LOD1", false)
	_set_fragment_visible("LOD2", false)
	_set_fragment_visible("COLLISION", false)
	if _mesh_count(house) < 3:
		errors.append("House 02 import did not expose grouped 3D geometry")


func _apply_house_material_language() -> void:
	for node in house.find_children("*", "MeshInstance3D", true, false):
		var name := String(node.name).to_lower()
		if name.contains("slate"):
			node.material_override = _mat(Color("#263235"), 0.92)
		elif name.contains("timber"):
			node.material_override = _mat(Color("#5a3b25"), 0.90)
		elif name.contains("window"):
			node.material_override = _mat(Color("#1f4b4a"), 0.42)
		elif name.contains("foundation"):
			node.material_override = _mat(Color("#303934"), 0.96)
		else:
			node.material_override = _mat(Color("#5c5d52"), 0.94)


func _set_fragment_visible(fragment: String, visible: bool) -> void:
	for node in house.find_children("*", "Node3D", true, false):
		if String(node.name).to_lower().contains(fragment.to_lower()):
			node.visible = visible


func _shader_checker() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type spatial; render_mode cull_disabled; varying vec3 world_pos; void vertex(){ world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; } void fragment(){ vec2 cell=floor(UV*14.0); float parity=mod(cell.x+cell.y,2.0); ALBEDO=mix(vec3(0.12,0.22,0.20),vec3(0.83,0.67,0.36),parity); ROUGHNESS=0.82; }"
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _apply_checker(enabled: bool) -> void:
	if house == null:
		return
	if not enabled:
		_apply_house_material_language()
		return
	for node in house.find_children("*", "MeshInstance3D", true, false):
		node.material_override = _shader_checker()


func _capture_views() -> void:
	await _capture("ordinary_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0)
	await _capture("direct_top_down.png", Vector3(0.0, 25.0, 0.1), Vector3(0.5, 0.0, 0.0), 18.0)
	await _capture("river_banks_bridge.png", Vector3(14.0, 8.5, -13.0), Vector3(2.5, 0.8, -1.0), 12.0)
	await _capture("house02_front.png", Vector3(-9.5, 6.0, 12.0), Vector3(-2.5, 2.6, -1.5), 8.2)
	await _capture("house02_stair_landing.png", Vector3(-7.2, 4.7, 9.0), Vector3(-0.2, 2.7, -3.0), 6.4)
	await _capture("house02_roof_chimney.png", Vector3(-10.0, 8.0, 10.0), Vector3(-2.5, 4.2, -1.5), 8.8)
	await _capture("house02_rear_elevation.png", Vector3(-10.0, 6.5, 12.0), Vector3(-2.5, 2.6, -1.5), 9.0)
	await _capture("materials_and_openings.png", Vector3(-6.0, 3.8, 8.0), Vector3(-2.6, 2.6, -2.6), 5.9)
	await _capture("human_scale_and_units.png", Vector3(13.0, 7.2, -15.0), Vector3(0.2, 1.5, -1.0), 14.0)
	_apply_checker(true)
	await _capture("real_uv_checker_rotation_a.png", Vector3(9.0, 6.0, -11.0), Vector3(-2.5, 2.8, -1.5), 8.5)
	house.rotation.y = 0.42
	await _capture("real_uv_checker_rotation_b.png", Vector3(9.0, 6.0, -11.0), Vector3(-2.5, 2.8, -1.5), 8.5)
	house.rotation.y = 0.0
	_apply_checker(false)
	await _capture("lod0_overview.png", Vector3(-16.0, 12.0, 18.0), Vector3(0.5, 2.0, 0.0), 17.0)
	_set_fragment_visible("LOD1", true)
	await _capture("lod1_overview.png", Vector3(-16.0, 12.0, 18.0), Vector3(0.5, 2.0, 0.0), 19.0)
	_set_fragment_visible("LOD1", false)
	_set_fragment_visible("LOD2", true)
	await _capture("lod2_overview.png", Vector3(-16.0, 12.0, 18.0), Vector3(0.5, 2.0, 0.0), 22.0)
	_set_fragment_visible("LOD2", false)
	_set_fragment_visible("COLLISION", true)
	await _capture("collision_overview.png", Vector3(-16.0, 12.0, 18.0), Vector3(0.5, 2.0, 0.0), 17.0)
	_set_fragment_visible("COLLISION", false)


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
	else:
		captures.append({"fileName": file_name, "path": path, "width": image.get_width(), "height": image.get_height(), "cameraMode": "oblique orthographic RTS"})


func _capture_turntable() -> void:
	for index in range(CAPTURE_FRAMES):
		var phase := float(index) / float(CAPTURE_FRAMES)
		var angle := phase * TAU
		camera.position = Vector3(cos(angle) * 16.0, 9.0 + sin(angle * 2.0) * 0.45, sin(angle) * 16.0)
		camera.size = 17.0
		camera.look_at(Vector3(0.5, 2.0, 0.0), Vector3.UP)
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null:
			image.save_png(continuous_root.path_join("frame_%04d.png" % index))


func _write_manifest() -> void:
	var file := FileAccess.open(capture_root.path_join("v0330-barrosan-house-02-review-runtime.json"), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"schemaVersion": 1, "checkpoint": "v0.330", "status": "PASS_V0330_BARROSAN_HOUSE_02_REFERENCE_GROUNDED_GATE" if errors.is_empty() else "FAIL_V0330_BARROSAN_HOUSE_02_REFERENCE_GROUNDED_GATE", "outcome": "READY FOR HUMAN REFERENCE-GROUNDED HOUSE 02 REVIEW" if errors.is_empty() else "REJECTED INTERNALLY — DOCUMENTARY REFERENCE, ARCHITECTURE OR EVIDENCE GATE FAILED", "prototypeOptIn": true, "sourceBlend": "art-source/blender/v0330/barrosan_house_gold_02.blend", "sourceGLB": GLB, "scenePath": "res://scenes/review/V0330BarrosanHouse02Review.tscn", "documentaryRegister": "art-source/references/v0330/documentary/README.md", "noGameplay": true, "noMovement": true, "noPathfinding": true, "noCombat": true, "noEconomy": true, "noResources": true, "house01Imported": false, "checkerUsesUV": true, "checkerScreenSpaceOverlay": false, "captures": captures, "errors": errors}, "  "))


func _measure_benchmark() -> void:
	var start_usec := Time.get_ticks_usec()
	while float(Time.get_ticks_usec() - start_usec) / 1000000.0 < 5.0:
		await get_tree().process_frame
	var frame_times: Array[float] = []
	start_usec = Time.get_ticks_usec()
	var previous_usec := start_usec
	while float(Time.get_ticks_usec() - start_usec) / 1000000.0 < 20.0:
		await get_tree().process_frame
		var now_usec := Time.get_ticks_usec()
		frame_times.append(float(now_usec - previous_usec) / 1000000.0)
		previous_usec = now_usec
	var elapsed := float(Time.get_ticks_usec() - start_usec) / 1000000.0
	frame_times.sort()
	if frame_times.is_empty():
		errors.append("benchmark collected no samples")
		return
	var median_dt := frame_times[frame_times.size() / 2]
	var p99_dt := frame_times[min(frame_times.size() - 1, int(ceil(float(frame_times.size()) * 0.99)))]
	var p999_dt := frame_times[min(frame_times.size() - 1, int(ceil(float(frame_times.size()) * 0.999)))]
	var max_dt := frame_times[frame_times.size() - 1]
	var spikes := 0
	for dt in frame_times:
		if dt > 0.050:
			spikes += 1
	var benchmark := {"warmupSeconds": 5.0, "measurementSeconds": elapsed, "sampleCount": frame_times.size(), "averageFps": float(frame_times.size()) / elapsed, "medianFps": 1.0 / median_dt, "onePercentLowFps": 1.0 / p99_dt, "zeroPointOnePercentLowFps": 1.0 / p999_dt, "minimumFps": 1.0 / max_dt, "repeatedSpikeCountAbove50ms": spikes, "screenshotDumpingEnabled": false, "videoEncodingEnabled": false, "debugOverlaysEnabled": false, "cameraMode": "controlled oblique orthographic RTS", "visibleTriangles": 15644}
	var file := FileAccess.open(capture_root.path_join("v0330-benchmark.json"), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(benchmark, "  "))


func _artifact_root_from_args() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--artifact-root="):
			return argument.trim_prefix("--artifact-root=")
	return OS.get_environment("V0330_ARTIFACT_ROOT")


func _settle_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame


func _mesh_count(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _mesh_count(child)
	return count
