extends Node3D

const VIEWPORT_SIZE := Vector2i(1280, 720)
const LABELS := ["MATERIAL 1", "MATERIAL 2", "MATERIAL 3"]
const CANDIDATE_KEYS := ["candidate_c", "candidate_b", "candidate_a"]
const MATERIAL_PATHS := ["res://assets/v0336/materials/material_1.tres", "res://assets/v0336/materials/material_2.tres", "res://assets/v0336/materials/material_3.tres"]
const CANDIDATE_ROOTS := ["art-source/materials/v0335/candidates/candidate_c", "art-source/materials/v0335/candidates/candidate_b", "art-source/materials/v0335/candidates/candidate_a"]
const CAPTURE_NAMES := ["01_near_corner_window.png", "02_front_material_inspection.png", "03_normal_rts.png", "04_far_rts.png", "05_greyscale_normal_rts.png", "06_thumbnail_256.png", "07_neutral_overcast.png", "08_warm_directional.png", "09_albedo_only.png", "10_normal_only.png", "11_normal_disabled.png", "12_roughness_isolation.png", "13_top_down.png", "14_side_view.png"]
const VIDEO_FRAMES := 432

var artifact_root := ""
var candidate_roots: Array[Node3D] = []
var camera: Camera3D
var key_light: DirectionalLight3D
var fill_light: DirectionalLight3D
var capture_records: Array[Dictionary] = []
var binding_records: Array[Dictionary] = []

func _ready() -> void:
	call_deferred("start")

func start() -> void:
	artifact_root = OS.get_environment("V0336_ARTIFACT_ROOT")
	if artifact_root.is_empty():
		get_tree().quit(0)
		return
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	_build_environment()
	_build_ground()
	for index in range(3):
		candidate_roots.append(_build_structure(index))
	_write_binding_ledger()
	_write_matched_camera_ledger()
	await _settle(20)
	for index in range(3):
		await _capture_candidate_set(index)
	await _capture_video_frames()
	_write_runtime_manifest()
	get_tree().quit(0)

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#687268")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d0d1c4")
	environment.ambient_light_energy = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = false
	var world := WorldEnvironment.new()
	world.name = "V0336NeutralComparisonWorld"
	world.environment = environment
	add_child(world)
	key_light = DirectionalLight3D.new()
	key_light.name = "V0336MatchedWarmDirectionalKey"
	key_light.rotation_degrees = Vector3(-52.0, -34.0, 0.0)
	key_light.light_color = Color("#efd4a6")
	key_light.light_energy = 0.9
	key_light.shadow_enabled = true
	key_light.directional_shadow_max_distance = 80.0
	add_child(key_light)
	fill_light = DirectionalLight3D.new()
	fill_light.name = "V0336MatchedHighlandFill"
	fill_light.rotation_degrees = Vector3(-24.0, 146.0, 0.0)
	fill_light.light_color = Color("#a9bec0")
	fill_light.light_energy = 0.24
	add_child(fill_light)
	camera = Camera3D.new()
	camera.name = "V0336MatchedOrthographicCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.05
	camera.far = 160.0
	camera.size = 10.0
	camera.current = true
	add_child(camera)

func _build_ground() -> void:
	var ground := _box(self, "SharedStudyGround", Vector3(0.0, -0.22, -0.7), Vector3(15.0, 0.36, 11.5), _flat(Color("#5d654f"), 0.98))
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _flat(color: Color, roughness := 0.9) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

func _box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, material: Material, rotation := Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.rotation = rotation
	parent.add_child(instance)
	return instance

func _build_structure(index: int) -> Node3D:
	var root := Node3D.new()
	root.name = "%s_RuntimeStructure" % LABELS[index].replace(" ", "_")
	root.visible = index == 0
	add_child(root)
	var wall: Material = load(MATERIAL_PATHS[index])
	var foundation := _flat(Color("#4b4c45"), 0.96)
	var wood := _flat(Color("#55402d"), 0.91)
	var roof := _flat(Color("#33383a"), 0.95)
	var dark := _flat(Color("#252a29"), 0.98)
	_box(root, "PrincipalWall_Left", Vector3(-1.45, 1.50, 0.0), Vector3(1.10, 3.0, 0.42), wall)
	_box(root, "PrincipalWall_Right", Vector3(1.45, 1.50, 0.0), Vector3(1.10, 3.0, 0.42), wall)
	_box(root, "PrincipalWall_SillBand", Vector3(0.0, 0.52, 0.0), Vector3(1.80, 0.86, 0.42), wall)
	_box(root, "PrincipalWall_HeadBand", Vector3(0.0, 2.57, 0.0), Vector3(1.80, 0.86, 0.42), wall)
	_box(root, "Window_Recess_Dark", Vector3(0.0, 1.50, -0.10), Vector3(1.76, 1.20, 0.06), dark)
	_box(root, "Window_Lintel", Vector3(0.0, 2.20, 0.26), Vector3(2.05, 0.26, 0.28), foundation)
	_box(root, "Window_Sill", Vector3(0.0, 0.80, 0.28), Vector3(2.05, 0.22, 0.32), foundation)
	_box(root, "Corner_Pier", Vector3(2.02, 1.50, 0.0), Vector3(0.45, 3.0, 0.48), foundation)
	_box(root, "SideWall_Back", Vector3(2.02, 1.50, -0.92), Vector3(0.42, 3.0, 1.42), wall)
	_box(root, "SideWall_CornerReturn", Vector3(1.30, 1.50, -1.60), Vector3(1.46, 3.0, 0.40), wall)
	for stone_index in range(5):
		_box(root, "Foundation_Stone_%02d" % stone_index, Vector3(-1.7 + float(stone_index) * 0.82, 0.18, 0.31), Vector3(0.72, 0.34, 0.54), foundation, Vector3(0.0, float(stone_index) * 0.13, 0.0))
	_box(root, "Roof_Front_Slope", Vector3(0.0, 3.42, 0.62), Vector3(4.65, 0.18, 1.62), roof, Vector3(0.38, 0.0, 0.0))
	_box(root, "Roof_Back_Slope", Vector3(0.0, 3.42, -0.62), Vector3(4.65, 0.18, 1.62), roof, Vector3(-0.38, 0.0, 0.0))
	_box(root, "Roof_Front_Fascia", Vector3(0.0, 2.98, 1.18), Vector3(4.72, 0.20, 0.18), wood)
	_box(root, "Roof_Ridge", Vector3(0.0, 3.91, 0.0), Vector3(4.75, 0.22, 0.22), roof)
	var shed_origin := Vector3(-0.45, 0.0, -3.25)
	_box(root, "SupportShed_Walls", shed_origin + Vector3(0.0, 0.60, 0.0), Vector3(2.0, 1.20, 1.55), wall)
	_box(root, "SupportShed_Roof", shed_origin + Vector3(0.0, 1.36, 0.0), Vector3(2.26, 0.16, 1.80), roof, Vector3(0.16, 0.0, 0.0))
	_box(root, "SupportShed_Door", shed_origin + Vector3(0.0, 0.57, 0.80), Vector3(0.48, 0.78, 0.08), wood)
	if index == 0:
		_add_hybrid_relief(root, foundation)
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
	body.material_override = _flat(Color("#485e56"), 0.88)
	body.position.y = 0.78
	person.add_child(body)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.20
	head_mesh.height = 0.40
	head.mesh = head_mesh
	head.material_override = _flat(Color("#bd956e"), 0.9)
	head.position.y = 1.59
	person.add_child(head)
	_box(root, "HumanScale_ContactShadow", Vector3(-2.85, 0.035, 0.85), Vector3(0.80, 0.025, 0.42), _flat(Color(0.12, 0.10, 0.08, 0.32), 1.0))
	var watermark := Label3D.new()
	watermark.name = "RuntimeMaterialWatermark"
	watermark.text = LABELS[index]
	watermark.font_size = 48
	watermark.outline_size = 12
	watermark.modulate = Color("#f0dfaa")
	watermark.outline_modulate = Color("#1b211d")
	watermark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	watermark.no_depth_test = true
	watermark.position = Vector3(0.0, 5.1, 0.5)
	root.add_child(watermark)
	var footer := Label3D.new()
	footer.name = "RuntimeMaterialHashFooter"
	footer.text = "RESOURCE %s | %s" % [MATERIAL_PATHS[index].get_file(), _resource_hash(MATERIAL_PATHS[index]).substr(0, 12)]
	footer.font_size = 20
	footer.outline_size = 7
	footer.modulate = Color("#e3e0d2")
	footer.outline_modulate = Color("#1b211d")
	footer.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	footer.no_depth_test = true
	footer.position = Vector3(0.0, 4.62, 0.5)
	root.add_child(footer)
	return root

func _add_hybrid_relief(root: Node3D, material: Material) -> void:
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
	var relief := MeshInstance3D.new()
	relief.name = "HybridMergedLimitedRelief"
	relief.mesh = surface.commit()
	root.add_child(relief)

func _append_surface_box(surface: SurfaceTool, center: Vector3, size: Vector3) -> void:
	var h := size * 0.5
	var vertices := [center + Vector3(-h.x, -h.y, -h.z), center + Vector3(h.x, -h.y, -h.z), center + Vector3(h.x, h.y, -h.z), center + Vector3(-h.x, h.y, -h.z), center + Vector3(-h.x, -h.y, h.z), center + Vector3(h.x, -h.y, h.z), center + Vector3(h.x, h.y, h.z), center + Vector3(-h.x, h.y, h.z)]
	var faces := [[0, 2, 1], [0, 3, 2], [4, 5, 6], [4, 6, 7], [0, 1, 5], [0, 5, 4], [1, 2, 6], [1, 6, 5], [2, 3, 7], [2, 7, 6], [3, 0, 4], [3, 4, 7]]
	for face in faces:
		for vertex_index in face:
			surface.set_uv(Vector2(0.5, 0.5))
			surface.add_vertex(vertices[vertex_index])

func _resource_hash(resource_path: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(FileAccess.get_file_as_bytes(resource_path))
	return context.finish().hex_encode()

func _texture_hash(resource_path: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(FileAccess.get_file_as_bytes(resource_path))
	return context.finish().hex_encode()

func _write_binding_ledger() -> void:
	var ledger: Array[Dictionary] = []
	for index in range(3):
		var root: Node3D = candidate_roots[index]
		var wall: MeshInstance3D = root.get_node("PrincipalWall_Left")
		var key: String = CANDIDATE_KEYS[index]
		var extension_albedo := "jpg" if key == "candidate_a" else "png"
		var extension_roughness := "jpg" if key == "candidate_a" else "png"
		var textures := {"albedo": "art-source/materials/v0335/candidates/%s/albedo.%s" % [key, extension_albedo], "height": "art-source/materials/v0335/candidates/%s/height.png" % key, "normal": "art-source/materials/v0335/candidates/%s/normal.png" % key, "roughness": "art-source/materials/v0335/candidates/%s/roughness.%s" % [key, extension_roughness]}
		var runtime_textures := {"albedo": "res://assets/v0335/materials/%s/albedo.%s" % [key, extension_albedo], "height": "res://assets/v0335/materials/%s/height.png" % key, "normal": "res://assets/v0335/materials/%s/normal.png" % key, "roughness": "res://assets/v0335/materials/%s/roughness.%s" % [key, extension_roughness]}
		var texture_hashes := {}
		for texture_name in textures:
			texture_hashes[texture_name] = _texture_hash(runtime_textures[texture_name])
		ledger.append({"displayedLabel": LABELS[index], "meshInstanceNodePath": str(root.get_path()).path_join("PrincipalWall_Left"), "meshResource": "BoxMesh(1.10m x 3.00m x 0.42m)", "materialOverrideResource": MATERIAL_PATHS[index], "materialResourceSha256": _resource_hash(MATERIAL_PATHS[index]), "albedoTexturePath": textures.albedo, "heightTexturePath": textures.height, "normalTexturePath": textures.normal, "roughnessTexturePath": textures.roughness, "textureSha256": texture_hashes, "sourceCandidateDirectory": CANDIDATE_ROOTS[index], "candidateKey": key, "runtimeVisible": root.visible})
		binding_records = ledger
	var file := FileAccess.open(artifact_root.path_join("candidate-binding-ledger.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"checkpoint": "v0.336", "generatedBy": "instantiated Godot scene", "records": ledger}, "  "))

func _write_matched_camera_ledger() -> void:
	var file := FileAccess.open(artifact_root.path_join("matched-camera-ledger.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"checkpoint": "v0.336", "camera": {"projection": "orthographic", "near": 0.05, "far": 160.0, "viewportWidth": VIEWPORT_SIZE.x, "viewportHeight": VIEWPORT_SIZE.y, "normalPosition": [9.5, 6.8, 12.0], "normalTarget": [0.0, 1.5, 0.0], "normalSize": 11.5}, "keyLight": {"rotationDegrees": [-52.0, -34.0, 0.0], "color": "#efd4a6", "energy": 0.9, "shadowEnabled": true}, "fillLight": {"rotationDegrees": [-24.0, 146.0, 0.0], "color": "#a9bec0", "energy": 0.24}, "environment": {"background": "#687268", "ambient": "#d0d1c4", "ambientEnergy": 0.72, "toneMapper": "filmic", "fog": false}, "matchedAcrossMaterials": true}, "  "))

func _set_visible(index: int) -> void:
	for candidate in candidate_roots:
		candidate.visible = false
	if index >= 0:
		candidate_roots[index].visible = true

func _configure_camera(mode: String) -> void:
	match mode:
		"near":
			camera.position = Vector3(6.8, 4.8, 8.8); camera.size = 6.8
		"front":
			camera.position = Vector3(0.0, 3.4, 10.5); camera.size = 7.2
		"normal":
			camera.position = Vector3(9.5, 6.8, 12.0); camera.size = 11.5
		"far":
			camera.position = Vector3(15.5, 10.8, 19.0); camera.size = 18.0
		"top":
			camera.position = Vector3(0.0, 24.0, 0.0); camera.size = 13.5
		"side":
			camera.position = Vector3(12.0, 3.8, 0.0); camera.size = 8.0
		_:
			camera.position = Vector3(9.5, 6.8, 12.0); camera.size = 11.5
	camera.look_at(Vector3(0.0, 1.5, 0.0), Vector3.UP)

func _capture_candidate_set(index: int) -> void:
	_set_visible(index)
	var directory := artifact_root.path_join("material-%d" % (index + 1))
	DirAccess.make_dir_recursive_absolute(directory)
	var modes := ["near", "front", "normal", "far", "normal", "thumbnail", "neutral", "warm", "albedo", "normal_only", "normal_disabled", "roughness", "top", "side"]
	for capture_index in range(CAPTURE_NAMES.size()):
		_apply_diagnostic(index, modes[capture_index])
		_configure_camera(modes[capture_index])
		await _settle(5)
		var image := get_viewport().get_texture().get_image()
		if image == null:
			continue
		if capture_index == 4:
			image = _greyscale(image)
		if capture_index == 5:
			image.resize(256, 144, Image.INTERPOLATE_LANCZOS)
		image.save_png(directory.path_join(CAPTURE_NAMES[capture_index]))
		capture_records.append({"material": index + 1, "fileName": CAPTURE_NAMES[capture_index], "mode": modes[capture_index], "width": image.get_width(), "height": image.get_height(), "displayedLabel": LABELS[index]})
		_restore_material(index)

func _diagnostic_material(index: int, mode: String) -> StandardMaterial3D:
	var key: String = CANDIDATE_KEYS[index]
	var material := _flat(Color("#b7b6a7"), 0.9)
	var albedo_extension := "jpg" if key == "candidate_a" else "png"
	var roughness_extension := "jpg" if key == "candidate_a" else "png"
	if mode == "albedo":
		material.albedo_texture = load("res://assets/v0335/materials/%s/albedo.%s" % [key, albedo_extension])
	if mode == "normal_only":
		material.normal_enabled = true
		material.normal_texture = load("res://assets/v0335/materials/%s/normal.png" % key)
		material.normal_scale = 1.2
	if mode == "roughness":
		material.albedo_color = Color("#96958c")
		material.roughness_texture = load("res://assets/v0335/materials/%s/roughness.%s" % [key, roughness_extension])
	if mode == "normal_disabled":
		material.albedo_color = Color("#9b9a91")
		material.normal_enabled = false
	return material

func _apply_diagnostic(index: int, mode: String) -> void:
	if mode not in ["albedo", "normal_only", "normal_disabled", "roughness"]:
		return
	var root: Node3D = candidate_roots[index]
	var actual: Material = load(MATERIAL_PATHS[index])
	var diagnostic := _diagnostic_material(index, mode)
	for node in root.find_children("*", "MeshInstance3D", true, false):
		if node.material_override == actual:
			node.material_override = diagnostic

func _restore_material(index: int) -> void:
	var root: Node3D = candidate_roots[index]
	var actual: Material = load(MATERIAL_PATHS[index])
	var key: String = CANDIDATE_KEYS[index]
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var material: Material = node.material_override
		if material is StandardMaterial3D and material.resource_path.is_empty() and node.name in ["PrincipalWall_Left", "PrincipalWall_Right", "PrincipalWall_SillBand", "PrincipalWall_HeadBand", "SideWall_Back", "SideWall_CornerReturn", "SupportShed_Walls"]:
			node.material_override = actual

func _greyscale(image: Image) -> Image:
	var copy := image.duplicate()
	copy.convert(Image.FORMAT_RGBA8)
	for y in range(copy.get_height()):
		for x in range(copy.get_width()):
			var c: Color = copy.get_pixel(x, y)
			var l: float = c.r * 0.299 + c.g * 0.587 + c.b * 0.114
			copy.set_pixel(x, y, Color(l, l, l, c.a))
	return copy

func _capture_video_frames() -> void:
	var directory := artifact_root.path_join("continuous")
	DirAccess.make_dir_recursive_absolute(directory)
	for frame_index in range(VIDEO_FRAMES):
		var candidate := mini(frame_index / 144, 2)
		_set_visible(candidate)
		var phase := float(frame_index % 144) / 143.0
		var angle := -0.34 + phase * 0.68
		camera.position = Vector3(9.0 + sin(angle) * 2.2, 6.5 + cos(angle) * 0.35, 12.5 + cos(angle) * 2.2)
		camera.size = 10.5
		camera.look_at(Vector3(0.0, 1.45, 0.0), Vector3.UP)
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null:
			image.save_png(directory.path_join("frame_%04d.png" % frame_index))

func _write_runtime_manifest() -> void:
	var file := FileAccess.open(artifact_root.path_join("v0336-granite-evidence-runtime.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"checkpoint": "v0.336", "status": "PASS_V0336_RUNTIME_EVIDENCE_CAPTURE", "outcome": "READY FOR HUMAN FINAL GRANITE CANDIDATE SELECTION", "prototypeOptIn": true, "scenePath": "res://scenes/review/V0336GraniteEvidenceRepair.tscn", "candidateBindingLedger": "artifacts/runtime/v0336/candidate-binding-ledger.json", "candidateSets": 3, "captureCountPerCandidate": CAPTURE_NAMES.size(), "videoFrames": VIDEO_FRAMES, "viewport": {"width": VIEWPORT_SIZE.x, "height": VIEWPORT_SIZE.y}, "noHouse02Application": true, "noGameplay": true, "noMovement": true, "noPathfinding": true, "noCombat": true, "noEconomy": true, "noResources": true, "captures": capture_records}, "  "))

func _settle(frames: int) -> void:
	for _index in range(frames):
		await get_tree().process_frame
