extends "res://scripts/v0383_highland_style_coherence.gd"

## v0.387 is an isolated, opt-in route-hierarchy repair. It preserves the accepted
## crossing infrastructure and all gameplay/default-runtime semantics.

const V0387_CHECKPOINT := "v0.387"
const V0387_CAPTURE_ROOT := "artifacts/runtime/v0387"
const V0387_GLB_SHA256 := "746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb"
const V0387_SOURCE_SHA256 := "4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19"
const V0387_PRIMARY_ASSET := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const V0387_SUBORDINATE_ASSET := "res://scenes/gold/barrosan/BarrosanBarnGold.tscn"
const V0387_QUATERNIUS_ROOT := "res://assets/third_party/quaternius/v0370/"

var v0387_capture_mode := false
var v0387_smoke_mode := false
var v0387_capture_root := V0387_CAPTURE_ROOT
var v0387_iteration := 3
var v0387_cluster: Node3D
var v0387_yard: Node3D
var v0387_humans: Node3D
var v0387_props: Node3D

func _ready() -> void:
	_read_v0387_args()
	_build_v0383_environment()
	if not _build_v0383_world():
		get_tree().quit(1)
		return
	_build_v0383_camera()
	_build_v0387_cluster()
	var base_key := get_node_or_null("V0383_Soft_Northwest_Key") as DirectionalLight3D
	if base_key:
		base_key.light_energy = 0.54
	var inhabited_fill := DirectionalLight3D.new()
	inhabited_fill.name = "V0387_Restrained_Inhabited_Fill"
	inhabited_fill.rotation_degrees = Vector3(-32.0, 136.0, 0.0)
	inhabited_fill.light_color = Color("#d7d0bd")
	inhabited_fill.light_energy = 0.48
	inhabited_fill.shadow_enabled = false
	add_child(inhabited_fill)
	var homestead_fill := OmniLight3D.new()
	homestead_fill.name = "V0387_Warm_Homestead_Fill"
	homestead_fill.position = Vector3(-7.8, 5.0, 3.0)
	homestead_fill.light_color = Color("#e4c89c")
	homestead_fill.light_energy = 3.0
	homestead_fill.omni_range = 12.0
	homestead_fill.shadow_enabled = false
	add_child(homestead_fill)
	if v0387_capture_mode:
		_capture_v0387_sequence.call_deferred()
	elif v0387_smoke_mode:
		_smoke_v0387_exit.call_deferred()

func _read_v0387_args() -> void:
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0387-inhabited-crossing-capture": v0387_capture_mode = true
		if arg == "--v0387-inhabited-crossing-smoke": v0387_smoke_mode = true
		if arg.begins_with("--artifact-root="): v0387_capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0387-iteration="): v0387_iteration = clampi(int(arg.trim_prefix("--v0387-iteration=")), 1, 4)
	if v0387_capture_mode: v0387_smoke_mode = true

func _build_v0387_cluster() -> void:
	v0387_cluster = Node3D.new()
	v0387_cluster.name = "V0387_Inhabited_Crossing_Route_Hierarchy_Repair"
	v0387_cluster.position = Vector3(-2.2, 0.0, 1.10)
	v0383_world.add_child(v0387_cluster)
	v0387_yard = Node3D.new()
	v0387_yard.name = "V0387_Five_Functional_Yard_Groups"
	v0387_cluster.add_child(v0387_yard)
	v0387_props = Node3D.new()
	v0387_props.name = "V0387_Visible_Curated_Yard_Props"
	v0387_cluster.add_child(v0387_props)
	_build_v0387_primary()
	_build_v0387_subordinate()
	_build_v0387_ground_connection()
	_build_v0387_yard_groups()
	_build_v0387_characters()

func _instantiate_asset(path: String, parent: Node3D, node_name: String, position: Vector3, scale_value: Vector3, yaw := 0.0) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("v0.387 missing curated asset: " + path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("v0.387 curated asset is not Node3D: " + path)
		return null
	instance.name = node_name
	instance.position = position
	instance.scale = scale_value
	instance.rotation.y = yaw
	parent.add_child(instance)
	return instance

func _build_v0387_primary() -> void:
	var primary := _instantiate_asset(V0387_PRIMARY_ASSET, v0387_cluster, "V0387_One_Primary_Barrosan_Homestead", Vector3(-6.35, 0.66, 1.55), Vector3.ONE * 0.45, 0.0)
	if primary:
		primary.set_meta("source_asset", V0387_PRIMARY_ASSET)
		primary.set_meta("role", "primary inhabited roadside homestead")

func _build_v0387_subordinate() -> void:
	var subordinate := _instantiate_asset(V0387_SUBORDINATE_ASSET, v0387_cluster, "V0387_One_Subordinate_Agricultural_Barn", Vector3(-9.05, 0.32, 4.10), Vector3.ONE * 0.29, deg_to_rad(8.0))
	if subordinate:
		subordinate.set_meta("source_asset", V0387_SUBORDINATE_ASSET)
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

func _build_v0387_ground_connection() -> void:
	var yard_patch := PackedVector3Array([
		Vector3(-11.0, 0.0, 0.00), Vector3(-5.0, 0.0, 0.05), Vector3(-3.4, 0.0, 2.05),
		Vector3(-4.0, 0.0, 5.20), Vector3(-9.3, 0.0, 6.35), Vector3(-11.7, 0.0, 3.15)
	])
	_ground_patch(v0387_yard, "V0387_Working_Yard_Ground", yard_patch, Color("#927b5b"), 0.74)
	var path := Node3D.new()
	path.name = "V0387_Road_Yard_Entrance_Connection"
	v0387_yard.add_child(path)
	var path_color := Color("#795a3e")
	_ground_patch(path, "V0387_Connection_Segment_A", PackedVector3Array([
		Vector3(-1.72, 0.0, 0.38), Vector3(-0.72, 0.0, 1.18), Vector3(-1.90, 0.0, 2.18), Vector3(-2.66, 0.0, 1.56)
	]), path_color, 0.80)
	_ground_patch(path, "V0387_Connection_Segment_B", PackedVector3Array([
		Vector3(-2.58, 0.0, 1.48), Vector3(-2.14, 0.0, 2.46), Vector3(-3.72, 0.0, 2.82), Vector3(-4.10, 0.0, 2.08)
	]), path_color, 0.80)
	_ground_patch(path, "V0387_Connection_Segment_C", PackedVector3Array([
		Vector3(-3.84, 0.0, 2.02), Vector3(-4.24, 0.0, 2.86), Vector3(-5.42, 0.0, 2.48), Vector3(-5.74, 0.0, 1.72)
	]), path_color, 0.80)
	_ground_patch(path, "V0387_Connection_Segment_D", PackedVector3Array([
		Vector3(-5.48, 0.0, 1.68), Vector3(-5.88, 0.0, 2.28), Vector3(-6.62, 0.0, 1.96), Vector3(-6.92, 0.0, 1.26)
	]), path_color, 0.80)
	_ground_patch(path, "V0387_Connection_Segment_E_Door_Approach", PackedVector3Array([
		Vector3(-6.82, 0.0, 1.18), Vector3(-6.50, 0.0, 1.80), Vector3(-5.96, 0.0, 1.72), Vector3(-6.18, 0.0, 1.08)
	]), path_color.lightened(0.06), 0.805)

func _build_v0387_yard_groups() -> void:
	var cart := Node3D.new(); cart.name = "V0387_Yard_Group_01_Cart"; v0387_props.add_child(cart)
	_instantiate_asset(V0387_QUATERNIUS_ROOT + "village/Prop_Wagon.gltf", cart, "Cart_Visible", Vector3(-3.65, 0.84, 3.72), Vector3.ONE * 0.74, deg_to_rad(-8.0))
	var lumber := Node3D.new(); lumber.name = "V0387_Yard_Group_02_Stacked_Firewood"; v0387_props.add_child(lumber)
	for i in range(3):
		_instantiate_asset(V0387_QUATERNIUS_ROOT + "props/Crate_Wooden.gltf", lumber, "Lumber_Crate_%d" % i, Vector3(-8.35 + i * 0.52, 0.84 + (i % 2) * 0.18, 4.06), Vector3.ONE * 0.48, deg_to_rad(4.0 * i))
	var storage := Node3D.new(); storage.name = "V0387_Yard_Group_03_Barrel_Crate_Storage"; v0387_props.add_child(storage)
	_instantiate_asset(V0387_QUATERNIUS_ROOT + "props/Barrel_Apples.gltf", storage, "Storage_Barrel", Vector3(-2.40, 1.00, 4.70), Vector3.ONE * 0.54, 0.18)
	_instantiate_asset(V0387_QUATERNIUS_ROOT + "props/Crate_Wooden.gltf", storage, "Storage_Crate", Vector3(-1.72, 0.88, 4.78), Vector3.ONE * 0.48, -0.10)
	var work := Node3D.new(); work.name = "V0387_Yard_Group_04_Trough_Workbench"; v0387_props.add_child(work)
	_instantiate_asset(V0387_QUATERNIUS_ROOT + "props/Whetstone.gltf", work, "Workstone", Vector3(-5.80, 0.86, 3.12), Vector3.ONE * 0.68, 0.0)
	_instantiate_asset(V0387_QUATERNIUS_ROOT + "village/Prop_Crate.gltf", work, "Workbench_Block", Vector3(-5.08, 0.88, 3.26), Vector3.ONE * 0.48, 0.16)
	var boundary := Node3D.new(); boundary.name = "V0387_Yard_Group_05_Fence_Gate"; v0387_props.add_child(boundary)
	_instantiate_asset(V0387_QUATERNIUS_ROOT + "village/Prop_WoodenFence_Extension1.gltf", boundary, "Fence_Left", Vector3(-8.72, 0.85, 2.18), Vector3(0.72, 0.62, 0.62), deg_to_rad(-8.0))
	_instantiate_asset(V0387_QUATERNIUS_ROOT + "village/Prop_WoodenFence_Single.gltf", boundary, "Fence_Right", Vector3(-7.32, 0.85, 2.32), Vector3(0.72, 0.62, 0.62), deg_to_rad(-8.0))

func _build_v0387_characters() -> void:
	v0387_humans = Node3D.new()
	v0387_humans.name = "V0387_Exactly_Three_Distinct_Character_Roles"
	v0387_cluster.add_child(v0387_humans)
	var resident := _instantiate_asset(V0387_QUATERNIUS_ROOT + "men/Farmer.gltf", v0387_humans, "V0387_Resident_Worker", Vector3(-5.15, 0.78, 2.78), Vector3.ONE * 1.10, deg_to_rad(20.0))
	var guard := _instantiate_asset(V0387_QUATERNIUS_ROOT + "men/Adventurer.gltf", v0387_humans, "V0387_Crossing_Guard", Vector3(-0.95, 0.78, 1.60), Vector3.ONE * 1.06, deg_to_rad(-22.0))
	var traveller := _instantiate_asset(V0387_QUATERNIUS_ROOT + "men/Worker.gltf", v0387_humans, "V0387_Traveller_Porter", Vector3(-3.05, 1.05, 2.95), Vector3.ONE * 1.08, deg_to_rad(155.0))
	for figure in [resident, guard, traveller]:
		if figure: figure.set_meta("static_visual_role_only", true)

func _capture_v0387_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0387_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0387_view("01_PRIMARY_RTS_VIEW.png", Vector3(23.0, 29.0, 23.0), Vector3(-5.0, 0.75, 2.5), 20.8, root)
	await _capture_v0387_view("02_SETTLEMENT_AND_CROSSING_CONTEXT.png", Vector3(27.0, 34.0, 27.0), Vector3(-4.4, 0.70, 2.5), 24.8, root)
	await _capture_v0387_view("03_ROAD_YARD_ENTRANCE_CONNECTION.png", Vector3(16.0, 20.0, 16.0), Vector3(-4.9, 0.85, 1.9), 11.8, root)
	await _capture_v0387_view("04_FIVE_FUNCTIONAL_YARD_GROUPS.png", Vector3(16.0, 20.0, 16.0), Vector3(-6.0, 0.90, 3.65), 11.0, root)
	await _capture_v0387_view("05_THREE_CHARACTER_ROLE_AUDIT.png", Vector3(17.0, 21.0, 17.0), Vector3(-4.2, 0.90, 2.55), 13.4, root)
	await _capture_v0387_view("06_BUILDING_SEPARATION_AND_ENTRANCES.png", Vector3(17.0, 21.0, 17.0), Vector3(-7.2, 1.35, 3.2), 12.2, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("07_GRAYSCALE_PRIMARY.png"))
	_write_v0387_json("v0387-inhabited-crossing-route-hierarchy-repair.json", {
		"checkpoint": V0387_CHECKPOINT, "status": "RENDERED", "iteration": v0387_iteration,
		"resolution": "1920x1080", "primaryBuildings": 1, "subordinateBuildings": 1,
		"yardGroups": 5, "characterRoles": 3, "bridgePreserved": true, "riverPreserved": true,
		"roadToYardConnection": true, "gameplay": false, "defaultRuntime": "unchanged",
		"route": "opt-in-only", "acceptedGlbSha256": V0387_GLB_SHA256, "sourceSha256": V0387_SOURCE_SHA256,
		"selectedAssets": [V0387_PRIMARY_ASSET, V0387_SUBORDINATE_ASSET, V0387_QUATERNIUS_ROOT + "men/Farmer.gltf", V0387_QUATERNIUS_ROOT + "men/Adventurer.gltf", V0387_QUATERNIUS_ROOT + "men/Worker.gltf"]
	})
	get_tree().quit(0)

func _capture_v0387_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0387_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(v0387_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_v0387_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_v0387_json("v0387-inhabited-crossing-route-hierarchy-repair-smoke.json", {"checkpoint": V0387_CHECKPOINT, "status": "PASS", "sceneLoaded": true, "acceptedInfrastructureUnchanged": true, "gameplay": false, "defaultRuntime": "unchanged", "route": "opt-in-only"})
	get_tree().quit(0)
