extends Node3D

const VIEWPORT_SIZE := Vector2i(1600, 900)
const CANDIDATE_NAMES := ["MATERIAL 1", "MATERIAL 2", "MATERIAL 3"]
const CANDIDATE_KEYS := ["candidate_a", "candidate_b", "candidate_c"]
const CAPTURE_FRAMES := 120

var capture_root := ""
var screenshot_root := ""
var continuous_root := ""
var camera: Camera3D
var candidate_roots: Array[Node3D] = []
var original_materials: Dictionary = {}
var captures: Array[Dictionary] = []
var errors: Array[String] = []


func _ready() -> void:
	call_deferred("start")


func start() -> void:
	capture_root = OS.get_environment("V0335_ARTIFACT_ROOT")
	if capture_root.is_empty():
		get_tree().quit(0)
		return
	screenshot_root = capture_root.path_join("screenshots")
	continuous_root = capture_root.path_join("continuous")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	DirAccess.make_dir_recursive_absolute(continuous_root)
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	_build_environment()
	_build_ground()
	for index in range(3):
		candidate_roots.append(_build_structure(index, Vector3(-7.0 + float(index) * 7.0, 0.0, 0.0)))
	await _settle(24)
	await _capture_study()
	await _capture_continuous()
	_write_runtime_manifest()
	get_tree().quit(0 if errors.is_empty() else 1)


func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#697264")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d1d0bd")
	environment.ambient_light_energy = 0.68
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = false
	var world := WorldEnvironment.new()
	world.name = "V0335NeutralOvercastWorld"
	world.environment = environment
	add_child(world)
	var key := DirectionalLight3D.new()
	key.name = "V0335ConsistentWarmDirectionalKey"
	key.rotation_degrees = Vector3(-52.0, -34.0, 0.0)
	key.light_color = Color("#efd4a6")
	key.light_energy = 0.92
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 80.0
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0335HighlandAmbientFill"
	fill.rotation_degrees = Vector3(-24.0, 146.0, 0.0)
	fill.light_color = Color("#a9bec0")
	fill.light_energy = 0.24
	add_child(fill)
	camera = Camera3D.new()
	camera.name = "V0335ObliqueGameplayCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.05
	camera.far = 160.0
	camera.size = 15.0
	camera.current = true
	add_child(camera)
	camera.position = Vector3(11.5, 8.8, 15.0)
	camera.look_at(Vector3(0.0, 1.4, 0.0), Vector3.UP)


func _mat(color: Color, roughness := 0.86) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = 0.0
	return material


func _textured_mat(candidate: int) -> StandardMaterial3D:
	var key: String = CANDIDATE_KEYS[candidate]
	var material := _mat(Color.WHITE, 0.9)
	material.albedo_texture = load("res://assets/v0335/materials/%s/albedo.%s" % [key, "jpg" if candidate == 0 else "png"])
	material.normal_enabled = true
	material.normal_texture = load("res://assets/v0335/materials/%s/normal.png" % key)
	material.normal_scale = 0.72
	material.roughness_texture = load("res://assets/v0335/materials/%s/roughness.%s" % [key, "jpg" if candidate == 0 else "png"])
	return material


func _box(parent: Node3D, name: String, position: Vector3, size: Vector3, material: Material, rotation := Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.rotation = rotation
	parent.add_child(instance)
	original_materials[instance] = material
	return instance


func _build_ground() -> void:
	var ground := _box(self, "SharedStudyGround", Vector3(0.0, -0.22, -0.7), Vector3(24.0, 0.36, 11.5), _mat(Color("#5d654f"), 0.98))
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_box(self, "MetricScaleBar_2m", Vector3(-10.0, 0.04, 4.2), Vector3(2.0, 0.08, 0.12), _mat(Color("#e5d9a4"), 0.7))
	_box(self, "MetricScaleBar_1m", Vector3(-10.5, 0.04, 4.42), Vector3(0.06, 0.09, 0.12), _mat(Color("#e5d9a4"), 0.7))
	_box(self, "MetricScaleBar_2m_End", Vector3(-9.5, 0.04, 4.42), Vector3(0.06, 0.09, 0.12), _mat(Color("#e5d9a4"), 0.7))


func _build_structure(candidate: int, origin: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = "V0335_%s_TestStructure" % CANDIDATE_NAMES[candidate].replace(" ", "_")
	root.position = origin
	add_child(root)
	var wall := _textured_mat(candidate)
	var foundation := _mat(Color("#4b4c45"), 0.96)
	var wood := _mat(Color("#55402d"), 0.91)
	var roof := _mat(Color("#33383a"), 0.95)
	var dark := _mat(Color("#252a29"), 0.98)
	# Principal wall is a 4m x 3m wall with a real recessed opening, not a flat card.
	_box(root, "PrincipalWall_Left", Vector3(-1.45, 1.50, 0.0), Vector3(1.10, 3.0, 0.42), wall)
	_box(root, "PrincipalWall_Right", Vector3(1.45, 1.50, 0.0), Vector3(1.10, 3.0, 0.42), wall)
	_box(root, "PrincipalWall_SillBand", Vector3(0.0, 0.52, 0.0), Vector3(1.80, 0.86, 0.42), wall)
	_box(root, "PrincipalWall_HeadBand", Vector3(0.0, 2.57, 0.0), Vector3(1.80, 0.86, 0.42), wall)
	_box(root, "Window_Recess_Dark", Vector3(0.0, 1.50, -0.10), Vector3(1.76, 1.20, 0.06), dark)
	_box(root, "Window_Lintel", Vector3(0.0, 2.20, 0.26), Vector3(2.05, 0.26, 0.28), foundation)
	_box(root, "Window_Sill", Vector3(0.0, 0.80, 0.28), Vector3(2.05, 0.22, 0.32), foundation)
	# External 90-degree corner and side wall expose depth and ground contact.
	_box(root, "Corner_Pier", Vector3(2.02, 1.50, 0.0), Vector3(0.45, 3.0, 0.48), foundation)
	_box(root, "SideWall_Back", Vector3(2.02, 1.50, -0.92), Vector3(0.42, 3.0, 1.42), wall)
	_box(root, "SideWall_CornerReturn", Vector3(1.30, 1.50, -1.60), Vector3(1.46, 3.0, 0.40), wall)
	for index in range(5):
		_box(root, "Foundation_Stone_%02d" % index, Vector3(-1.7 + float(index) * 0.82, 0.18, 0.31), Vector3(0.72, 0.34, 0.54), foundation, Vector3(0.0, float(index) * 0.13, 0.0))
	# Two roof planes, eaves and fascia provide a clear roof/side/base hierarchy.
	_box(root, "Roof_Front_Slope", Vector3(0.0, 3.42, 0.62), Vector3(4.65, 0.18, 1.62), roof, Vector3(0.38, 0.0, 0.0))
	_box(root, "Roof_Back_Slope", Vector3(0.0, 3.42, -0.62), Vector3(4.65, 0.18, 1.62), roof, Vector3(-0.38, 0.0, 0.0))
	_box(root, "Roof_Front_Fascia", Vector3(0.0, 2.98, 1.18), Vector3(4.72, 0.20, 0.18), wood)
	_box(root, "Roof_Ridge", Vector3(0.0, 3.91, 0.0), Vector3(4.75, 0.22, 0.22), roof)
	# Secondary support building in the same language, visibly subordinate.
	var shed_origin := Vector3(-0.45, 0.0, -3.25)
	_box(root, "SupportShed_Walls", shed_origin + Vector3(0.0, 0.60, 0.0), Vector3(2.0, 1.20, 1.55), wall)
	_box(root, "SupportShed_Roof", shed_origin + Vector3(0.0, 1.36, 0.0), Vector3(2.26, 0.16, 1.80), roof, Vector3(0.16, 0.0, 0.0))
	_box(root, "SupportShed_Door", shed_origin + Vector3(0.0, 0.57, 0.80), Vector3(0.48, 0.78, 0.08), wood)
	# One 1.75m human-scale figure with a restrained contact shadow.
	var person := Node3D.new()
	person.name = "HumanScale_1_75m"
	person.position = Vector3(-2.85, 0.0, 0.85)
	root.add_child(person)
	var person_body := CapsuleMesh.new()
	person_body.radius = 0.22
	person_body.height = 1.32
	var body := MeshInstance3D.new()
	body.name = "HumanScale_Body"
	body.mesh = person_body
	body.material_override = _mat(Color("#485e56"), 0.88)
	body.position.y = 0.78
	person.add_child(body)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.20
	head_mesh.height = 0.40
	head.mesh = head_mesh
	head.material_override = _mat(Color("#bd956e"), 0.9)
	head.position.y = 1.59
	person.add_child(head)
	_box(root, "HumanScale_ContactShadow", Vector3(-2.85, 0.035, 0.85), Vector3(0.80, 0.025, 0.42), _mat(Color(0.12, 0.10, 0.08, 0.32), 1.0), Vector3.ZERO)
	if candidate == 2:
		_add_hybrid_relief(root, foundation)
	return root


func _add_hybrid_relief(root: Node3D, material: Material) -> void:
	# One merged relief mesh: a few protruding stones, quoins, lintel and sill.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_material(material)
	_append_surface_box(surface, Vector3(-1.94, 2.42, 0.28), Vector3(0.32, 0.42, 0.18))
	_append_surface_box(surface, Vector3(-1.94, 1.68, 0.29), Vector3(0.30, 0.44, 0.18))
	_append_surface_box(surface, Vector3(1.94, 2.38, 0.29), Vector3(0.34, 0.45, 0.18))
	_append_surface_box(surface, Vector3(1.94, 1.12, 0.29), Vector3(0.30, 0.38, 0.18))
	_append_surface_box(surface, Vector3(-0.92, 2.20, 0.32), Vector3(0.44, 0.18, 0.20))
	_append_surface_box(surface, Vector3(0.82, 0.80, 0.34), Vector3(0.40, 0.16, 0.20))
	_append_surface_box(surface, Vector3(-1.20, 0.34, 0.36), Vector3(0.42, 0.22, 0.22))
	surface.generate_normals()
	var mesh := surface.commit()
	var relief := MeshInstance3D.new()
	relief.name = "HybridMergedLimitedRelief"
	relief.mesh = mesh
	root.add_child(relief)


func _append_surface_box(surface: SurfaceTool, center: Vector3, size: Vector3) -> void:
	var h := size * 0.5
	var v := [center + Vector3(-h.x, -h.y, -h.z), center + Vector3(h.x, -h.y, -h.z), center + Vector3(h.x, h.y, -h.z), center + Vector3(-h.x, h.y, -h.z), center + Vector3(-h.x, -h.y, h.z), center + Vector3(h.x, -h.y, h.z), center + Vector3(h.x, h.y, h.z), center + Vector3(-h.x, h.y, h.z)]
	var faces := [[0, 2, 1], [0, 3, 2], [4, 5, 6], [4, 6, 7], [0, 1, 5], [0, 5, 4], [1, 2, 6], [1, 6, 5], [2, 3, 7], [2, 7, 6], [3, 0, 4], [3, 4, 7]]
	for face in faces:
		for index in face:
			surface.set_uv(Vector2(0.5, 0.5))
			surface.add_vertex(v[index])


func _set_visible(index: int) -> void:
	for candidate in candidate_roots:
		candidate.visible = false
	if index >= 0:
		candidate_roots[index].visible = true
	else:
		for candidate in candidate_roots:
			candidate.visible = true


func _override_all(candidate: int, material: Material) -> void:
	for node in candidate_roots[candidate].find_children("*", "MeshInstance3D", true, false):
		original_materials[node] = node.material_override
		node.material_override = material


func _restore_all() -> void:
	for node in original_materials:
		if is_instance_valid(node):
			node.material_override = original_materials[node]


func _diagnostic_material(candidate: int, mode: String) -> StandardMaterial3D:
	var key: String = CANDIDATE_KEYS[candidate]
	var material := _mat(Color("#b7b6a7"), 0.9)
	if mode == "albedo":
		material.albedo_texture = load("res://assets/v0335/materials/%s/albedo.%s" % [key, "jpg" if candidate == 0 else "png"])
	if mode == "normal":
		material.normal_enabled = true
		material.normal_texture = load("res://assets/v0335/materials/%s/normal.png" % key)
		material.normal_scale = 1.2
	if mode == "roughness":
		material.albedo_color = Color("#96958c")
		material.roughness_texture = load("res://assets/v0335/materials/%s/roughness.%s" % [key, "jpg" if candidate == 0 else "png"])
	return material


func _capture_study() -> void:
	_set_visible(0)
	await _capture("candidate_1_complete.png", Vector3(7.8, 5.7, 10.0), Vector3(-7.0, 1.5, 0.0), 7.4, "oblique_rts")
	_set_visible(1)
	await _capture("candidate_2_complete.png", Vector3(7.8, 5.7, 10.0), Vector3(0.0, 1.5, 0.0), 7.4, "oblique_rts")
	_set_visible(2)
	await _capture("candidate_3_complete.png", Vector3(7.8, 5.7, 10.0), Vector3(7.0, 1.5, 0.0), 7.4, "oblique_rts")
	_set_visible(-1)
	await _capture("blind_three_materials.png", Vector3(15.2, 10.8, 20.0), Vector3(0.0, 1.3, 0.0), 18.8, "oblique_rts")
	await _capture("normal_rts.png", Vector3(13.0, 8.8, 15.0), Vector3(0.0, 1.2, 0.0), 15.0, "oblique_rts")
	await _capture("near_corner_window.png", Vector3(5.4, 4.3, 8.2), Vector3(0.0, 1.6, 0.0), 5.5, "near_corner_window")
	await _capture("far_rts.png", Vector3(18.5, 13.0, 23.0), Vector3(0.0, 1.0, 0.0), 23.0, "far_rts")
	await _capture("direct_top_down.png", Vector3(0.0, 24.0, 0.0), Vector3(0.0, 0.0, 0.0), 18.0, "direct_top_down")
	_set_visible(1)
	_override_all(1, _diagnostic_material(1, "normal"))
	await _capture("normal_only.png", Vector3(7.8, 5.7, 10.0), Vector3(0.0, 1.5, 0.0), 7.4, "normal_only")
	_restore_all()
	await _capture("neutral_overcast.png", Vector3(12.5, 9.0, 16.0), Vector3(0.0, 1.3, 0.0), 16.0, "neutral_overcast")
	await _capture("warm_directional.png", Vector3(8.5, 6.0, 11.0), Vector3(7.0, 1.5, 0.0), 7.5, "warm_directional")
	_set_visible(0)
	_override_all(0, _diagnostic_material(0, "albedo"))
	await _capture("albedo_only.png", Vector3(7.8, 5.7, 10.0), Vector3(-7.0, 1.5, 0.0), 7.4, "albedo_only")
	_restore_all()
	_set_visible(2)
	_override_all(2, _diagnostic_material(2, "roughness"))
	await _capture("roughness_isolation.png", Vector3(7.8, 5.7, 10.0), Vector3(7.0, 1.5, 0.0), 7.4, "roughness_isolation")
	_restore_all()
	_set_visible(-1)


func _capture(file_name: String, position: Vector3, target: Vector3, size: float, mode: String) -> void:
	camera.position = position
	camera.size = size
	camera.look_at(target, Vector3.UP)
	await _settle(7)
	var image := get_viewport().get_texture().get_image()
	if image == null:
		errors.append("viewport unavailable: %s" % file_name)
		return
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var path := screenshot_root.path_join(file_name)
	if image.save_png(path) != OK:
		errors.append("capture failed: %s" % file_name)
	else:
		captures.append({"fileName": file_name, "width": image.get_width(), "height": image.get_height(), "cameraMode": mode, "projection": "orthographic"})


func _capture_continuous() -> void:
	_set_visible(2)
	for index in range(CAPTURE_FRAMES):
		var phase := float(index) / float(CAPTURE_FRAMES)
		var angle := -0.32 + phase * 0.62
		camera.position = Vector3(10.0 + sin(angle) * 2.8, 7.0 + cos(angle) * 0.7, 13.0 + cos(angle) * 2.8)
		camera.size = 8.5
		camera.look_at(Vector3(7.0, 1.45, 0.0), Vector3.UP)
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null:
			image.save_png(continuous_root.path_join("frame_%04d.png" % index))


func _settle(frames: int) -> void:
	for _index in range(frames):
		await get_tree().process_frame


func _write_runtime_manifest() -> void:
	var file := FileAccess.open(capture_root.path_join("v0335-granite-source-proof-runtime.json"), FileAccess.WRITE)
	if file == null:
		errors.append("runtime manifest could not be written")
		return
	file.store_string(JSON.stringify({
		"checkpoint": "v0.335",
		"status": "PASS_V0335_ISOLATED_GRANITE_SOURCE_PROOF" if errors.is_empty() else "FAIL_V0335_ISOLATED_GRANITE_SOURCE_PROOF",
		"outcome": "READY FOR HUMAN GRANITE SOURCE SELECTION" if errors.is_empty() else "REJECTED INTERNALLY — CANDIDATE CAPTURE FAILED",
		"prototypeOptIn": true,
		"scenePath": "res://scenes/review/V0335GraniteSourceProof.tscn",
		"testStructure": {"principalWallWidthM": 4.0, "principalWallHeightM": 3.0, "sideWallLengthM": 1.8, "openingRecessed": true, "lintel": true, "sill": true, "foundation": true, "humanHeightM": 1.75, "metricScaleBarM": 2.0},
		"candidateCount": 3,
		"noCompleteHouseExport": true,
		"noGameplay": true,
		"noMovement": true,
		"noPathfinding": true,
		"noCombat": true,
		"noEconomy": true,
		"noResources": true,
		"captures": captures,
		"errors": errors
	}, "  "))
