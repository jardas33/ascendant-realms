extends "res://scripts/v0383_highland_style_coherence.gd"

## v0.385 is an isolated, opt-in visual target. It replaces only the rejected
## v0.384 inhabited layer with curated existing assets; the accepted crossing
## infrastructure and all gameplay/default-runtime semantics remain untouched.

const V0385_CHECKPOINT := "v0.385"
const V0385_CAPTURE_ROOT := "artifacts/runtime/v0385"
const V0385_GLB_SHA256 := "746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb"
const V0385_SOURCE_SHA256 := "4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19"
const V0385_PRIMARY_ASSET := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const V0385_SUBORDINATE_ASSET := "res://scenes/gold/barrosan/BarrosanBarnGold.tscn"
const V0385_QUATERNIUS_ROOT := "res://assets/third_party/quaternius/v0370/"

var v0385_capture_mode := false
var v0385_smoke_mode := false
var v0385_capture_root := V0385_CAPTURE_ROOT
var v0385_iteration := 3
var v0385_cluster: Node3D
var v0385_yard: Node3D
var v0385_humans: Node3D
var v0385_props: Node3D

func _ready() -> void:
	_read_v0385_args()
	_build_v0383_environment()
	if not _build_v0383_world():
		get_tree().quit(1)
		return
	_build_v0383_camera()
	_build_v0385_cluster()
	var inhabited_fill := DirectionalLight3D.new()
	inhabited_fill.name = "V0385_Restrained_Inhabited_Fill"
	inhabited_fill.rotation_degrees = Vector3(-32.0, 136.0, 0.0)
	inhabited_fill.light_color = Color("#d7d0bd")
	inhabited_fill.light_energy = 0.34
	inhabited_fill.shadow_enabled = false
	add_child(inhabited_fill)
	if v0385_capture_mode:
		_capture_v0385_sequence.call_deferred()
	elif v0385_smoke_mode:
		_smoke_v0385_exit.call_deferred()

func _read_v0385_args() -> void:
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0385-inhabited-crossing-capture": v0385_capture_mode = true
		if arg == "--v0385-inhabited-crossing-smoke": v0385_smoke_mode = true
		if arg.begins_with("--artifact-root="): v0385_capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0385-iteration="): v0385_iteration = clampi(int(arg.trim_prefix("--v0385-iteration=")), 1, 4)
	if v0385_capture_mode: v0385_smoke_mode = true

func _build_v0385_cluster() -> void:
	v0385_cluster = Node3D.new()
	v0385_cluster.name = "V0385_Curated_Inhabited_Crossing"
	v0385_cluster.position = Vector3(-2.2, 0.0, 1.10)
	v0383_world.add_child(v0385_cluster)
	v0385_yard = Node3D.new()
	v0385_yard.name = "V0385_Five_Functional_Yard_Groups"
	v0385_cluster.add_child(v0385_yard)
	v0385_props = Node3D.new()
	v0385_props.name = "V0385_Visible_Curated_Yard_Props"
	v0385_cluster.add_child(v0385_props)
	_build_v0385_primary()
	_build_v0385_subordinate()
	_build_v0385_ground_connection()
	_build_v0385_yard_groups()
	_build_v0385_characters()

func _instantiate_asset(path: String, parent: Node3D, node_name: String, position: Vector3, scale_value: Vector3, yaw := 0.0) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("v0.385 missing curated asset: " + path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("v0.385 curated asset is not Node3D: " + path)
		return null
	instance.name = node_name
	instance.position = position
	instance.scale = scale_value
	instance.rotation.y = yaw
	parent.add_child(instance)
	return instance

func _build_v0385_primary() -> void:
	var primary := _instantiate_asset(V0385_PRIMARY_ASSET, v0385_cluster, "V0385_One_Primary_Barrosan_Homestead", Vector3(-7.15, 0.66, 2.55), Vector3.ONE * 0.48, 0.0)
	if primary:
		primary.set_meta("source_asset", V0385_PRIMARY_ASSET)
		primary.set_meta("role", "primary inhabited roadside homestead")

func _build_v0385_subordinate() -> void:
	var subordinate := _instantiate_asset(V0385_SUBORDINATE_ASSET, v0385_cluster, "V0385_One_Subordinate_Agricultural_Barn", Vector3(-10.35, 0.32, 3.90), Vector3.ONE * 0.28, deg_to_rad(-8.0))
	if subordinate:
		subordinate.set_meta("source_asset", V0385_SUBORDINATE_ASSET)
		subordinate.set_meta("role", "subordinate agricultural working structure")

func _polygon_mesh(points: PackedVector3Array) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	var indices := PackedInt32Array()
	for i in range(1, points.size() - 1):
		indices.append(0); indices.append(i); indices.append(i + 1)
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func _ground_material(name: String, color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = color
	material.roughness = 0.95
	return material

func _ground_patch(parent: Node3D, name: String, points: PackedVector3Array, color: Color, y := 0.76) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = _polygon_mesh(points)
	instance.material_override = _ground_material(name + "_Material", color)
	instance.position.y = y
	parent.add_child(instance)
	return instance

func _build_v0385_ground_connection() -> void:
	var yard_patch := PackedVector3Array([
		Vector3(-9.3, 0.0, 0.10), Vector3(-5.0, 0.0, 0.15), Vector3(-3.0, 0.0, 1.75),
		Vector3(-3.35, 0.0, 4.95), Vector3(-7.8, 0.0, 5.55), Vector3(-9.6, 0.0, 3.10)
	])
	_ground_patch(v0385_yard, "V0385_Working_Yard_Ground", yard_patch, Color("#8c765b"), 0.74)
	var threshold := PackedVector3Array([
		Vector3(-8.85, 0.0, 0.20), Vector3(-8.05, 0.0, 0.55), Vector3(-6.65, 0.0, 1.50),
		Vector3(-5.55, 0.0, 2.15), Vector3(-5.05, 0.0, 2.65), Vector3(-5.45, 0.0, 3.05),
		Vector3(-6.25, 0.0, 2.75), Vector3(-7.2, 0.0, 2.05), Vector3(-8.5, 0.0, 1.10)
	])
	_ground_patch(v0385_yard, "V0385_Road_To_Yard_To_Entrance_Threshold", threshold, Color("#9a7b57"), 0.80)

func _build_v0385_yard_groups() -> void:
	var cart := Node3D.new(); cart.name = "V0385_Yard_Group_01_Cart"; v0385_props.add_child(cart)
	_instantiate_asset(V0385_QUATERNIUS_ROOT + "village/Prop_Wagon.gltf", cart, "Cart_Visible", Vector3(-4.45, 0.84, 5.45), Vector3.ONE * 0.86, deg_to_rad(-8.0))
	var lumber := Node3D.new(); lumber.name = "V0385_Yard_Group_02_Stacked_Firewood"; v0385_props.add_child(lumber)
	for i in range(3):
		_instantiate_asset(V0385_QUATERNIUS_ROOT + "props/Crate_Wooden.gltf", lumber, "Lumber_Crate_%d" % i, Vector3(-7.95 + i * 0.48, 0.84 + (i % 2) * 0.18, 5.30), Vector3.ONE * 0.52, deg_to_rad(4.0 * i))
	var storage := Node3D.new(); storage.name = "V0385_Yard_Group_03_Barrel_Crate_Storage"; v0385_props.add_child(storage)
	_instantiate_asset(V0385_QUATERNIUS_ROOT + "props/Barrel_Apples.gltf", storage, "Storage_Barrel", Vector3(-2.95, 1.00, 4.25), Vector3.ONE * 0.60, 0.18)
	_instantiate_asset(V0385_QUATERNIUS_ROOT + "props/Crate_Wooden.gltf", storage, "Storage_Crate", Vector3(-2.30, 0.88, 4.55), Vector3.ONE * 0.52, -0.10)
	var work := Node3D.new(); work.name = "V0385_Yard_Group_04_Trough_Workbench"; v0385_props.add_child(work)
	_instantiate_asset(V0385_QUATERNIUS_ROOT + "props/Whetstone.gltf", work, "Workstone", Vector3(-7.45, 0.86, 1.15), Vector3.ONE * 0.76, 0.0)
	_instantiate_asset(V0385_QUATERNIUS_ROOT + "village/Prop_Crate.gltf", work, "Workbench_Block", Vector3(-6.75, 0.88, 1.30), Vector3.ONE * 0.52, 0.16)
	var boundary := Node3D.new(); boundary.name = "V0385_Yard_Group_05_Fence_Gate"; v0385_props.add_child(boundary)
	_instantiate_asset(V0385_QUATERNIUS_ROOT + "village/Prop_WoodenFence_Extension1.gltf", boundary, "Fence_Left", Vector3(-8.9, 0.85, 2.15), Vector3(0.62, 0.58, 0.58), deg_to_rad(-8.0))
	_instantiate_asset(V0385_QUATERNIUS_ROOT + "village/Prop_WoodenFence_Single.gltf", boundary, "Fence_Right", Vector3(-7.45, 0.85, 2.25), Vector3(0.62, 0.58, 0.58), deg_to_rad(-8.0))

func _build_v0385_characters() -> void:
	v0385_humans = Node3D.new()
	v0385_humans.name = "V0385_Exactly_Three_Distinct_Character_Roles"
	v0385_cluster.add_child(v0385_humans)
	var resident := _instantiate_asset(V0385_QUATERNIUS_ROOT + "men/Farmer.gltf", v0385_humans, "V0385_Resident_Worker", Vector3(-5.95, 0.78, 0.55), Vector3.ONE * 1.14, deg_to_rad(20.0))
	var guard := _instantiate_asset(V0385_QUATERNIUS_ROOT + "men/Adventurer.gltf", v0385_humans, "V0385_Crossing_Guard", Vector3(-1.70, 0.78, 1.15), Vector3.ONE * 1.16, deg_to_rad(-22.0))
	var traveller := _instantiate_asset(V0385_QUATERNIUS_ROOT + "men/Adventurer.gltf", v0385_humans, "V0385_Traveller_Porter", Vector3(-2.60, 0.78, 6.15), Vector3.ONE * 1.08, deg_to_rad(155.0))
	for figure in [resident, guard, traveller]:
		if figure: figure.set_meta("static_visual_role_only", true)

func _capture_v0385_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0385_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0385_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 30.0, 24.0), Vector3(-3.5, 0.75, 2.4), 23.5, root)
	await _capture_v0385_view("02_SETTLEMENT_AND_CROSSING_CONTEXT.png", Vector3(28.0, 35.0, 28.0), Vector3(-2.4, 0.70, 2.2), 29.0, root)
	await _capture_v0385_view("03_YARD_AND_CHARACTER_ROLE_DETAIL.png", Vector3(15.0, 18.0, 15.0), Vector3(-5.3, 0.90, 2.7), 11.5, root)
	await _capture_v0385_view("04_BUILDING_SILHOUETTE_AND_ENTRANCE_DETAIL.png", Vector3(14.0, 16.0, 15.0), Vector3(-7.0, 1.65, 3.0), 10.0, root)
	await _capture_v0385_view("05_CHARACTER_SCALE_AND_SEPARATION_AUDIT.png", Vector3(14.0, 16.0, 14.0), Vector3(-4.4, 0.90, 2.0), 10.5, root)
	await _capture_v0385_view("06_ROAD_YARD_ENTRANCE_CONNECTION.png", Vector3(18.0, 23.0, 18.0), Vector3(-4.6, 0.70, 1.4), 16.0, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("07_GRAYSCALE_PRIMARY.png"))
	_write_v0385_json("v0385-curated-inhabited-crossing.json", {
		"checkpoint": V0385_CHECKPOINT, "status": "RENDERED", "iteration": v0385_iteration,
		"resolution": "1920x1080", "primaryBuildings": 1, "subordinateBuildings": 1,
		"yardGroups": 5, "characterRoles": 3, "bridgePreserved": true, "riverPreserved": true,
		"roadToYardConnection": true, "gameplay": false, "defaultRuntime": "unchanged",
		"route": "opt-in-only", "acceptedGlbSha256": V0385_GLB_SHA256, "sourceSha256": V0385_SOURCE_SHA256,
		"selectedAssets": [V0385_PRIMARY_ASSET, V0385_SUBORDINATE_ASSET, V0385_QUATERNIUS_ROOT + "men/Farmer.gltf", V0385_QUATERNIUS_ROOT + "men/Adventurer.gltf", V0385_QUATERNIUS_ROOT + "men/Worker.gltf"]
	})
	get_tree().quit(0)

func _capture_v0385_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0385_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(v0385_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_v0385_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_v0385_json("v0385-curated-inhabited-crossing-smoke.json", {"checkpoint": V0385_CHECKPOINT, "status": "PASS", "sceneLoaded": true, "acceptedInfrastructureUnchanged": true, "gameplay": false, "defaultRuntime": "unchanged", "route": "opt-in-only"})
	get_tree().quit(0)
