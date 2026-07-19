extends Node3D

const CHECKPOINT := "v0.347"
const SCENE_PATH := "res://scenes/review/V0347BarnRenderedGeometryTruth.tscn"
const HOUSE_GLB := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const BARN_GLB := "res://assets/v0347/barn_rendered_geometry_truth.glb"
const READY_OUTCOME := "READY FOR HUMAN V0347 BARN RENDERED-GEOMETRY REVIEW"

var capture_root := ""
var captures: Array[Dictionary] = []
var errors: Array[String] = []
var camera: Camera3D
var barn: Node3D
var house: Node3D
var worker_barn: Node3D
var worker_house: Node3D
var world: Node3D

func _ready() -> void:
	print("V0347_READY")
	capture_root = OS.get_environment("V0347_ARTIFACT_ROOT")
	_build_world(); _load_assets(); _build_workers(); _build_camera()
	if capture_root != "":
		await get_tree().process_frame; await get_tree().process_frame
		await _capture_raw_source_set(); _write_manifest(); get_tree().quit()

func _build_world() -> void:
	world = Node3D.new(); world.name = "V0347_OptIn_Rendered_Geometry_Truth_World"; add_child(world)
	var environment := WorldEnvironment.new(); environment.name = "V0347_Neutral_Highland_Environment"; environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR; environment.environment.background_color = Color("#7e877b")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; environment.environment.ambient_light_color = Color("#b9c1b7")
	environment.environment.ambient_light_energy = 0.82; environment.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC; add_child(environment)
	var key := DirectionalLight3D.new(); key.name = "V0347_Northern_Directional_Key"; key.light_color = Color("#e0d7c4"); key.light_energy = 1.1; key.shadow_enabled = true; key.directional_shadow_max_distance = 70.0; key.rotation_degrees = Vector3(-48.0, -34.0, 0.0); add_child(key)
	var fill := DirectionalLight3D.new(); fill.name = "V0347_Soft_Valley_Fill"; fill.light_color = Color("#b4c5c6"); fill.light_energy = 0.28; fill.rotation_degrees = Vector3(-28.0, 145.0, 0.0); add_child(fill)
	var material := StandardMaterial3D.new(); material.resource_name = "V0347_Natural_Ground"; material.albedo_color = Color("#68745f"); material.roughness = 0.98
	var vertices := PackedVector3Array([Vector3(-19,0,-17),Vector3(-8,0.22,-19),Vector3(4,0.05,-18),Vector3(18,0.16,-16),Vector3(19,0.28,-4),Vector3(18,0.06,13),Vector3(8,0.24,17),Vector3(-9,0.15,18),Vector3(-19,0.04,13)])
	var indices := PackedInt32Array(); for i in range(1, vertices.size() - 1): indices.append_array([0,i,i+1])
	var arrays := []; arrays.resize(Mesh.ARRAY_MAX); arrays[Mesh.ARRAY_VERTEX] = vertices; arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays); mesh.surface_set_material(0, material)
	var ground := MeshInstance3D.new(); ground.name = "V0347_Natural_Ground_No_Pedestal"; ground.mesh = mesh; world.add_child(ground)

func _load_assets() -> void:
	var house_scene := load(HOUSE_GLB) as PackedScene
	if house_scene == null: errors.append("frozen House02 could not load")
	else:
		house = house_scene.instantiate() as Node3D; house.name = "V0347_Frozen_House02_Unmodified_Anchor"; world.add_child(house); _hide_non_lod_house_nodes(house); house.visible = false
	var barn_scene := load(BARN_GLB) as PackedScene
	if barn_scene == null: errors.append("v0.347 barn could not load")
	else:
		barn = barn_scene.instantiate() as Node3D; barn.name = "V0347_Barn_Rendered_Geometry_Truth_Candidate"; barn.position = Vector3(0,0.18,0); world.add_child(barn)
		if barn.find_children("*", "MeshInstance3D", true, false).is_empty(): errors.append("v0.347 barn has no visible meshes")

func _hide_non_lod_house_nodes(root: Node3D) -> void:
	for node in root.find_children("*", "Node3D", true, false):
		var label := String(node.name).to_lower()
		if label.contains("lod1") or label.contains("lod2") or label.contains("collision"): node.visible = false

func _build_workers() -> void:
	worker_barn = _add_worker("V0347_Worker_1p75m_Beside_Barn", Vector3(-6.0,0,-6.0))
	worker_house = _add_worker("V0347_Worker_1p75m_Beside_House02", Vector3(-3.5,0,-5.1)); worker_house.visible = false

func _add_worker(name: String, position: Vector3) -> Node3D:
	var root := Node3D.new(); root.name = name; root.position = position; world.add_child(root)
	var body := CapsuleMesh.new(); body.radius = 0.20; body.height = 1.05; body.material = _mat("V0347_Worker_Cloth", Color("#303b38"), 0.91)
	var body_instance := MeshInstance3D.new(); body_instance.name = "WorkerBody_1p75m"; body_instance.position.y = 0.68; body_instance.mesh = body; root.add_child(body_instance)
	var head := SphereMesh.new(); head.radius = 0.16; head.height = 0.32; head.material = _mat("V0347_Worker_Hood", Color("#6e5941"), 0.96)
	var head_instance := MeshInstance3D.new(); head_instance.name = "WorkerHead"; head_instance.position.y = 1.34; head_instance.mesh = head; root.add_child(head_instance)
	var shadow := CylinderMesh.new(); shadow.top_radius = 0.28; shadow.bottom_radius = 0.32; shadow.height = 0.018; shadow.material = _mat("V0347_Worker_Contact_Shadow", Color(0.08,0.09,0.08,0.30), 1.0)
	var shadow_instance := MeshInstance3D.new(); shadow_instance.name = "WorkerContactShadow"; shadow_instance.position.y = 0.025; shadow_instance.mesh = shadow; root.add_child(shadow_instance); return root

func _mat(name: String, color: Color, roughness := 0.92) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.resource_name = name; material.albedo_color = color; material.roughness = roughness; return material

func _build_camera() -> void:
	camera = Camera3D.new(); camera.name = "V0347_Stable_Orthographic_Truth_Camera"; camera.projection = Camera3D.PROJECTION_ORTHOGONAL; camera.current = true; add_child(camera)

func _set_camera(position: Vector3, target: Vector3, size: float) -> void:
	camera.position = position; camera.size = size; camera.look_at(target, Vector3.UP)

func _frame(filename: String, position: Vector3, target: Vector3, size: float, purpose: String) -> void:
	_set_camera(position,target,size); await get_tree().process_frame; await get_tree().process_frame
	var image := get_viewport().get_texture().get_image(); if image == null: errors.append("capture unavailable: %s" % filename); return
	var path := capture_root.path_join("screenshots").path_join(filename); DirAccess.make_dir_recursive_absolute(path.get_base_dir()); image.save_png(path)
	captures.append({"fileName":filename,"purpose":purpose,"rendered":true,"unlabelled":true,"technicalOverlay":false,"size":{"width":image.get_width(),"height":image.get_height()},"camera":{"projection":"orthographic","position":position,"target":target,"size":size}})

func _square_panel(image: Image) -> Image:
	var side := mini(image.get_width(),image.get_height()); var crop := image.get_region(Rect2i((image.get_width()-side)/2,(image.get_height()-side)/2,side,side)); crop.resize(256,256,Image.INTERPOLATE_LANCZOS); return crop

func _capture_matched_front() -> void:
	var comparison_camera := Vector3(-15.0,8.4,15.0); var target := Vector3(0,2.65,0); var output := capture_root.path_join("screenshots").path_join("05_true_matched_front_512x256.png")
	house.visible = true; barn.visible = false; worker_house.visible = true; worker_barn.visible = false; _set_camera(comparison_camera,target,13.2); await get_tree().process_frame; await get_tree().process_frame; var left := _square_panel(get_viewport().get_texture().get_image())
	house.visible = false; barn.visible = true; worker_house.visible = false; worker_barn.visible = true; _set_camera(comparison_camera,target,13.2); await get_tree().process_frame; await get_tree().process_frame; var right := _square_panel(get_viewport().get_texture().get_image())
	var combined := Image.create(512,256,false,Image.FORMAT_RGBA8); combined.blit_rect(left,Rect2i(0,0,256,256),Vector2i(0,0)); combined.blit_rect(right,Rect2i(0,0,256,256),Vector2i(256,0)); combined.save_png(output)
	captures.append({"fileName":"05_true_matched_front_512x256.png","purpose":"true frozen House02 front-left and v0.347 barn front-right comparison","rendered":true,"unlabelled":true,"technicalOverlay":false,"size":{"width":512,"height":256},"leftPanel":{"width":256,"height":256,"source":"frozen House02 rendered directly"},"rightPanel":{"width":256,"height":256,"source":"v0.347 barn rendered directly"},"camera":{"projection":"orthographic","position":comparison_camera,"target":target,"size":13.2}})
	house.visible = false; barn.visible = true; worker_house.visible = false; worker_barn.visible = true

func _capture_raw_source_set() -> void:
	await _frame("01_front_three_quarter.png",Vector3(-15,8.4,15),Vector3(0,2.65,0),16.5,"front three-quarter: lower agricultural double door, upper loading opening, granite band")
	await _frame("02_direct_front_orthographic.png",Vector3(0,7.0,18),Vector3(0,2.55,0),15.0,"direct front orthographic: compact broad facade and openings")
	await _frame("03_direct_side_gable.png",Vector3(-18.0,6.4,0),Vector3(0,2.7,0),13.0,"direct side/gable: complete granite triangle and measured roof silhouette")
	await _frame("04_roof_close_up.png",Vector3(-10.5,5.7,12.0),Vector3(0,4.0,0),10.5,"roof close-up: House02 slate tile scale, UV rows, ridge and granite gable")
	await _capture_matched_front()

func _mesh_bounds(root: Node3D) -> Dictionary:
	var first := true; var low := Vector3.ZERO; var high := Vector3.ZERO
	for node in root.find_children("*","MeshInstance3D",true,false):
		var box: AABB = node.get_aabb(); var transform: Transform3D = node.global_transform
		for corner in [Vector3(box.position.x,box.position.y,box.position.z),Vector3(box.end.x,box.position.y,box.position.z),Vector3(box.position.x,box.end.y,box.position.z),Vector3(box.position.x,box.position.y,box.end.z),Vector3(box.end.x,box.end.y,box.position.z),Vector3(box.end.x,box.position.y,box.end.z),Vector3(box.position.x,box.end.y,box.end.z),Vector3(box.end.x,box.end.y,box.end.z)]:
			var point: Vector3 = transform * corner
			if first: low = point; high = point; first = false
			else: low = low.min(point); high = high.max(point)
	return {"minX":low.x,"maxX":high.x,"minY":low.y,"maxY":high.y,"minZ":low.z,"maxZ":high.z}

func _write_manifest() -> void:
	var outcome := OS.get_environment("V0347_INTERNAL_OUTCOME"); if outcome == "": outcome = READY_OUTCOME
	var file := FileAccess.open(capture_root.path_join("v0347-barn-rendered-geometry-truth-runtime.json"),FileAccess.WRITE); if file == null: return
	var manifest := {"schemaVersion":1,"checkpoint":CHECKPOINT,"status":"PASS_V0347_BARN_RENDERED_GEOMETRY_TRUTH" if errors.is_empty() else "FAIL_V0347_BARN_RENDERED_GEOMETRY_TRUTH","outcome":outcome,"humanReviewRequired":true,"automatedVisualApproval":false,"prototypeOptIn":true,"prototypeOnly":true,"defaultRuntimeIntegrated":false,"scenePath":SCENE_PATH,"sourceBlend":"art-source/blender/v0347/barn_rendered_geometry_truth.blend","sourceGLB":BARN_GLB,"godotImportedBounds":_mesh_bounds(barn) if barn != null else {},"rawCaptureCount":captures.size(),"captures":captures,"house02RenderedDirectlyInCapture5":true,"frontCaptureShowsAgriculturalOpenings":true,"noLabels":true,"noOverlays":true,"noVideo":true,"noGameplay":true,"noMovement":true,"noPathfinding":true,"noCombat":true,"noEconomy":true,"noResources":true,"noRuntimeIntegration":true,"errors":errors}
	file.store_string(JSON.stringify(manifest,"  "))
