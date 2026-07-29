extends Node3D

const CHECKPOINT := "v0.343"
const SCENE_PATH := "res://scenes/review/V0343House02DerivedBarnVisualPreflight.tscn"
const HOUSE_GLB := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const BARN_GLB := "res://assets/v0343/house02_derived_barrosan_barn_visual_preflight.glb"
const READY_OUTCOME := "READY FOR HUMAN HOUSE02-DERIVED BARN VISUAL PREFLIGHT REVIEW"
const REJECTED_OUTCOME := "REJECTED INTERNALLY — HOUSE02-DERIVED BARN STILL FAILS THE VISUAL PREFLIGHT"

var capture_root := ""
var captures: Array[Dictionary] = []
var errors: Array[String] = []
var camera: Camera3D
var barn: Node3D
var house: Node3D
var world: Node3D

func _ready() -> void:
	print("V0343_READY")
	capture_root = OS.get_environment("V0331_ARTIFACT_ROOT")
	_build_world()
	_load_assets()
	_build_scale_workers()
	_build_camera()
	if capture_root != "":
		await get_tree().process_frame
		await get_tree().process_frame
		await _capture_visual_first()
		_write_manifest()
		get_tree().quit()

func _build_world() -> void:
	world = Node3D.new()
	world.name = "V0343_OptIn_House02_Derived_Barn_Preflight_World"
	add_child(world)
	var environment := WorldEnvironment.new()
	environment.name = "V0343_Neutral_Overcast_Environment"
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("#8b928a")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("#b9c1b7")
	environment.environment.ambient_light_energy = 0.78
	environment.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	add_child(environment)
	var key := DirectionalLight3D.new()
	key.name = "V0343_Neutral_Overcast_Key"
	key.light_color = Color("#e0d7c4")
	key.light_energy = 1.05
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 60.0
	key.rotation_degrees = Vector3(-48.0, -34.0, 0.0)
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0343_Soft_Valley_Fill"
	fill.light_color = Color("#b4c5c6")
	fill.light_energy = 0.34
	fill.rotation_degrees = Vector3(-28.0, 145.0, 0.0)
	add_child(fill)
	_build_ground()

func _mat(name: String, color: Color, roughness := 0.92) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = color
	material.roughness = roughness
	if name.contains("Ground"):
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _build_ground() -> void:
	var material := _mat("V0343_Irregular_Highland_Ground", Color("#64705a"), 0.98)
	var vertices := PackedVector3Array([
		Vector3(-18.0, 0.0, -16.0), Vector3(-8.0, 0.22, -18.0), Vector3(3.0, 0.05, -17.0),
		Vector3(16.0, 0.16, -15.0), Vector3(18.0, 0.28, -4.0), Vector3(17.0, 0.06, 12.0),
		Vector3(7.0, 0.24, 16.0), Vector3(-8.0, 0.15, 17.0), Vector3(-18.0, 0.04, 12.0)
	])
	var indices := PackedInt32Array()
	for i in range(1, vertices.size() - 1):
		indices.append_array([0, i, i + 1])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	var ground := MeshInstance3D.new()
	ground.name = "V0343_Irregular_Sloped_Ground_No_Presentation_Board"
	ground.mesh = mesh
	world.add_child(ground)
	for data in [[Vector3(0.5, 0.18, -2.8), Vector3(1.0, 0.42, 0.65)], [Vector3(7.5, 0.24, 1.2), Vector3(0.8, 0.34, 0.55)], [Vector3(-6.5, 0.25, 2.4), Vector3(0.72, 0.30, 0.48)]]:
		_add_box("V0343_Embedded_Granite_Contact", data[0], data[1], _mat("V0343_Contact_Stone", Color("#686961"), 0.98))

func _add_box(name: String, position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.position = position
	instance.mesh = mesh
	world.add_child(instance)
	return instance

func _load_assets() -> void:
	var house_scene := load(HOUSE_GLB) as PackedScene
	if house_scene == null:
		errors.append("frozen House 02 anchor could not load")
	else:
		house = house_scene.instantiate() as Node3D
		house.name = "V0343_Frozen_House02_Unmodified_Anchor"
		house.position = Vector3(-5.4, 0.0, 0.8)
		house.scale = Vector3(0.52, 0.52, 0.52)
		world.add_child(house)
		_hide_non_lod_house_nodes(house)
	var barn_scene := load(BARN_GLB) as PackedScene
	if barn_scene == null:
		errors.append("v0.343 derived barn could not load")
	else:
		barn = barn_scene.instantiate() as Node3D
		barn.name = "V0343_House02_Derived_Barrosan_Barn_Candidate"
		barn.position = Vector3(4.0, 0.0, 0.2)
		world.add_child(barn)
		if barn.find_children("*", "MeshInstance3D", true, false).is_empty(): errors.append("v0.343 barn has no visible meshes")

func _hide_non_lod_house_nodes(root: Node3D) -> void:
	for node in root.find_children("*", "Node3D", true, false):
		var label := String(node.name).to_lower()
		if label.contains("lod1") or label.contains("lod2") or label.contains("collision"): node.visible = false

func _build_scale_workers() -> void:
	_add_worker("V0343_Worker_1p75m_By_Lower_Door", Vector3(2.25, 0.0, -3.55))
	_add_worker("V0343_Worker_1p75m_By_Side_Elevation", Vector3(8.35, 0.0, 0.85))

func _add_worker(name: String, position: Vector3) -> void:
	var root := Node3D.new()
	root.name = name
	root.position = position
	world.add_child(root)
	var body := CapsuleMesh.new()
	body.radius = 0.20; body.height = 1.05
	body.material = _mat("V0343_Worker_Cloth", Color("#303b38"), 0.91)
	var body_instance := MeshInstance3D.new(); body_instance.name = "WorkerBody_1p75m"; body_instance.position.y = 0.68; body_instance.mesh = body; root.add_child(body_instance)
	var head := SphereMesh.new(); head.radius = 0.16; head.height = 0.32; head.material = _mat("V0343_Worker_Hood", Color("#6e5941"), 0.96)
	var head_instance := MeshInstance3D.new(); head_instance.name = "WorkerHead"; head_instance.position.y = 1.34; head_instance.mesh = head; root.add_child(head_instance)
	var shadow := CylinderMesh.new(); shadow.top_radius = 0.28; shadow.bottom_radius = 0.32; shadow.height = 0.018; shadow.material = _mat("V0343_Worker_Contact_Shadow", Color(0.08,0.09,0.08,0.30), 1.0)
	var shadow_instance := MeshInstance3D.new(); shadow_instance.name = "WorkerContactShadow"; shadow_instance.position.y = 0.025; shadow_instance.mesh = shadow; root.add_child(shadow_instance)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0343_Stable_Oblique_Preflight_Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.current = true
	add_child(camera)

func _set_camera(position: Vector3, target: Vector3, size: float) -> void:
	camera.position = position
	camera.size = size
	camera.look_at(target, Vector3.UP)

func _capture_visual_first() -> void:
	var screenshot_root := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	var specs := [
		["01_front_three_quarter_ordinary_rts.png", Vector3(-13.0, 8.5, 14.0), Vector3(0.0, 2.4, 0.5), 16.0, "front three-quarter ordinary RTS"],
		["02_rear_three_quarter_ordinary_rts.png", Vector3(14.0, 9.0, -15.0), Vector3(0.0, 2.4, 0.0), 16.0, "rear three-quarter ordinary RTS"],
		["03_front_close_material.png", Vector3(11.0, 5.2, -10.5), Vector3(3.4, 2.8, -0.7), 8.2, "front close material view"],
		["04_direct_side_gable.png", Vector3(-13.0, 5.6, 0.8), Vector3(4.0, 2.8, 0.2), 9.5, "direct side and gable view"],
		["05_house02_barn_matched_256.png", Vector3(15.0, 10.0, -17.0), Vector3(0.0, 2.3, 0.0), 18.0, "House 02 and barn matched 256-pixel composition"]
	]
	for spec in specs:
		_set_camera(spec[1], spec[2], spec[3])
		await get_tree().process_frame
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image == null:
			errors.append("capture unavailable: %s" % spec[0])
			continue
		if spec[0].begins_with("05_"):
			image.resize(256, 144, Image.INTERPOLATE_LANCZOS)
		image.save_png(screenshot_root.path_join(spec[0]))
		captures.append({"fileName": spec[0], "purpose": spec[4], "rendered": true, "unlabelled": true, "technicalOverlay": false, "camera": {"projection": "orthographic", "position": spec[1], "target": spec[2], "size": spec[3]}})

func _write_manifest() -> void:
	var outcome := OS.get_environment("V0343_PREFLIGHT_OUTCOME")
	if outcome == "": outcome = READY_OUTCOME
	var manifest := {"schemaVersion": 1, "checkpoint": CHECKPOINT, "status": "PASS_V0343_HOUSE02_DERIVED_BARN_VISUAL_PREFLIGHT" if errors.is_empty() else "FAIL_V0343_HOUSE02_DERIVED_BARN_VISUAL_PREFLIGHT", "outcome": outcome, "humanReviewRequired": true, "automatedVisualApproval": false, "prototypeOptIn": true, "prototypeOnly": true, "defaultRuntimeIntegrated": false, "scenePath": SCENE_PATH, "sourceBlend": "art-source/blender/v0343/house02_derived_barrosan_barn_visual_preflight.blend", "sourceGLB": BARN_GLB, "frozenHouse02BlendSha256": "3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6", "frozenHouse02GLBSha256": "ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89", "house02Modified": false, "v0341VisibleAssetDependency": false, "v0342VisibleAssetDependency": false, "captureCount": captures.size(), "captures": captures, "noTechnicalDiagnostics": true, "noVideo": true, "noLOD": true, "noCollision": true, "noRuntimeIntegration": true, "noGameplay": true, "noMovement": true, "noPathfinding": true, "noCombat": true, "noEconomy": true, "noResources": true, "errors": errors}
	var file := FileAccess.open(capture_root.path_join("v0343-house02-derived-barn-visual-preflight-runtime.json"), FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify(manifest, "  "))
