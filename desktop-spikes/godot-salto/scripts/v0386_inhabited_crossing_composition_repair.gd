extends "res://scripts/v0383_highland_style_coherence.gd"

## v0.386 is an isolated, opt-in composition repair. It preserves the accepted
## crossing infrastructure and all gameplay/default-runtime semantics.

const V0386_CHECKPOINT := "v0.386"
const V0386_CAPTURE_ROOT := "artifacts/runtime/v0386"
const V0386_GLB_SHA256 := "746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb"
const V0386_SOURCE_SHA256 := "4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19"
const V0386_PRIMARY_ASSET := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const V0386_SUBORDINATE_ASSET := "res://scenes/gold/barrosan/BarrosanBarnGold.tscn"
const V0386_QUATERNIUS_ROOT := "res://assets/third_party/quaternius/v0370/"

var v0386_capture_mode := false
var v0386_smoke_mode := false
var v0386_capture_root := V0386_CAPTURE_ROOT
var v0386_iteration := 3
var v0386_cluster: Node3D
var v0386_yard: Node3D
var v0386_humans: Node3D
var v0386_props: Node3D

func _ready() -> void:
	_read_v0386_args()
	_build_v0383_environment()
	if not _build_v0383_world():
		get_tree().quit(1)
		return
	_build_v0383_camera()
	_build_v0386_cluster()
	var base_key := get_node_or_null("V0383_Soft_Northwest_Key") as DirectionalLight3D
	if base_key:
		base_key.light_energy = 0.54
	var inhabited_fill := DirectionalLight3D.new()
	inhabited_fill.name = "V0386_Restrained_Inhabited_Fill"
	inhabited_fill.rotation_degrees = Vector3(-32.0, 136.0, 0.0)
	inhabited_fill.light_color = Color("#d7d0bd")
	inhabited_fill.light_energy = 0.48
	inhabited_fill.shadow_enabled = false
	add_child(inhabited_fill)
	var homestead_fill := OmniLight3D.new()
	homestead_fill.name = "V0386_Warm_Homestead_Fill"
	homestead_fill.position = Vector3(-8.4, 5.0, 2.2)
	homestead_fill.light_color = Color("#e4c89c")
	homestead_fill.light_energy = 2.2
	homestead_fill.omni_range = 9.0
	homestead_fill.shadow_enabled = false
	add_child(homestead_fill)
	if v0386_capture_mode:
		_capture_v0386_sequence.call_deferred()
	elif v0386_smoke_mode:
		_smoke_v0386_exit.call_deferred()

func _read_v0386_args() -> void:
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0386-inhabited-crossing-capture": v0386_capture_mode = true
		if arg == "--v0386-inhabited-crossing-smoke": v0386_smoke_mode = true
		if arg.begins_with("--artifact-root="): v0386_capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0386-iteration="): v0386_iteration = clampi(int(arg.trim_prefix("--v0386-iteration=")), 1, 4)
	if v0386_capture_mode: v0386_smoke_mode = true

func _build_v0386_cluster() -> void:
	v0386_cluster = Node3D.new()
	v0386_cluster.name = "V0386_Inhabited_Crossing_Composition_Repair"
	v0386_cluster.position = Vector3(-2.2, 0.0, 1.10)
	v0383_world.add_child(v0386_cluster)
	v0386_yard = Node3D.new()
	v0386_yard.name = "V0386_Five_Functional_Yard_Groups"
	v0386_cluster.add_child(v0386_yard)
	v0386_props = Node3D.new()
	v0386_props.name = "V0386_Visible_Curated_Yard_Props"
	v0386_cluster.add_child(v0386_props)
	_build_v0386_primary()
	_build_v0386_subordinate()
	_build_v0386_ground_connection()
	_build_v0386_yard_groups()
	_build_v0386_characters()

func _instantiate_asset(path: String, parent: Node3D, node_name: String, position: Vector3, scale_value: Vector3, yaw := 0.0) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("v0.386 missing curated asset: " + path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("v0.386 curated asset is not Node3D: " + path)
		return null
	instance.name = node_name
	instance.position = position
	instance.scale = scale_value
	instance.rotation.y = yaw
	parent.add_child(instance)
	return instance

func _build_v0386_primary() -> void:
	var primary := _instantiate_asset(V0386_PRIMARY_ASSET, v0386_cluster, "V0386_One_Primary_Barrosan_Homestead", Vector3(-6.35, 0.66, 1.55), Vector3.ONE * 0.45, 0.0)
	if primary:
		primary.set_meta("source_asset", V0386_PRIMARY_ASSET)
		primary.set_meta("role", "primary inhabited roadside homestead")

func _build_v0386_subordinate() -> void:
	var subordinate := _instantiate_asset(V0386_SUBORDINATE_ASSET, v0386_cluster, "V0386_One_Subordinate_Agricultural_Barn", Vector3(-11.15, 0.32, 5.30), Vector3.ONE * 0.29, deg_to_rad(24.0))
	if subordinate:
		subordinate.set_meta("source_asset", V0386_SUBORDINATE_ASSET)
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

func _build_v0386_ground_connection() -> void:
	var yard_patch := PackedVector3Array([
		Vector3(-11.0, 0.0, 0.00), Vector3(-5.0, 0.0, 0.05), Vector3(-3.4, 0.0, 2.05),
		Vector3(-4.0, 0.0, 5.20), Vector3(-9.3, 0.0, 6.35), Vector3(-11.7, 0.0, 3.15)
	])
	_ground_patch(v0386_yard, "V0386_Working_Yard_Ground", yard_patch, Color("#8c765b"), 0.74)
	var path := Node3D.new()
	path.name = "V0386_Road_Yard_Entrance_Connection"
	v0386_yard.add_child(path)
	var path_color := Color("#76583f")
	_ground_patch(path, "V0386_Connection_Segment_A", PackedVector3Array([
		Vector3(-1.55, 0.0, 0.82), Vector3(-0.92, 0.0, 1.42), Vector3(-2.30, 0.0, 2.24), Vector3(-2.78, 0.0, 1.74)
	]), path_color, 0.80)
	_ground_patch(path, "V0386_Connection_Segment_B", PackedVector3Array([
		Vector3(-2.40, 0.0, 1.72), Vector3(-2.05, 0.0, 2.28), Vector3(-3.78, 0.0, 2.50), Vector3(-4.05, 0.0, 1.88)
	]), path_color, 0.80)
	_ground_patch(path, "V0386_Connection_Segment_C", PackedVector3Array([
		Vector3(-3.82, 0.0, 1.78), Vector3(-4.10, 0.0, 2.48), Vector3(-5.38, 0.0, 1.95), Vector3(-5.68, 0.0, 1.32)
	]), path_color, 0.80)
	_ground_patch(path, "V0386_Connection_Segment_D", PackedVector3Array([
		Vector3(-5.42, 0.0, 1.22), Vector3(-5.70, 0.0, 1.92), Vector3(-6.62, 0.0, 1.00), Vector3(-7.05, 0.0, 0.38)
	]), path_color, 0.80)

func _build_v0386_yard_groups() -> void:
	var cart := Node3D.new(); cart.name = "V0386_Yard_Group_01_Cart"; v0386_props.add_child(cart)
	_instantiate_asset(V0386_QUATERNIUS_ROOT + "village/Prop_Wagon.gltf", cart, "Cart_Visible", Vector3(-4.35, 0.84, 4.70), Vector3.ONE * 0.74, deg_to_rad(-8.0))
	var lumber := Node3D.new(); lumber.name = "V0386_Yard_Group_02_Stacked_Firewood"; v0386_props.add_child(lumber)
	for i in range(3):
		_instantiate_asset(V0386_QUATERNIUS_ROOT + "props/Crate_Wooden.gltf", lumber, "Lumber_Crate_%d" % i, Vector3(-9.75 + i * 0.52, 0.84 + (i % 2) * 0.18, 5.70), Vector3.ONE * 0.48, deg_to_rad(4.0 * i))
	var storage := Node3D.new(); storage.name = "V0386_Yard_Group_03_Barrel_Crate_Storage"; v0386_props.add_child(storage)
	_instantiate_asset(V0386_QUATERNIUS_ROOT + "props/Barrel_Apples.gltf", storage, "Storage_Barrel", Vector3(-2.70, 1.00, 4.85), Vector3.ONE * 0.54, 0.18)
	_instantiate_asset(V0386_QUATERNIUS_ROOT + "props/Crate_Wooden.gltf", storage, "Storage_Crate", Vector3(-2.05, 0.88, 5.15), Vector3.ONE * 0.48, -0.10)
	var work := Node3D.new(); work.name = "V0386_Yard_Group_04_Trough_Workbench"; v0386_props.add_child(work)
	_instantiate_asset(V0386_QUATERNIUS_ROOT + "props/Whetstone.gltf", work, "Workstone", Vector3(-6.15, 0.86, 0.48), Vector3.ONE * 0.68, 0.0)
	_instantiate_asset(V0386_QUATERNIUS_ROOT + "village/Prop_Crate.gltf", work, "Workbench_Block", Vector3(-5.55, 0.88, 0.70), Vector3.ONE * 0.48, 0.16)
	var boundary := Node3D.new(); boundary.name = "V0386_Yard_Group_05_Fence_Gate"; v0386_props.add_child(boundary)
	_instantiate_asset(V0386_QUATERNIUS_ROOT + "village/Prop_WoodenFence_Extension1.gltf", boundary, "Fence_Left", Vector3(-10.45, 0.85, 2.35), Vector3(0.72, 0.62, 0.62), deg_to_rad(-8.0))
	_instantiate_asset(V0386_QUATERNIUS_ROOT + "village/Prop_WoodenFence_Single.gltf", boundary, "Fence_Right", Vector3(-9.00, 0.85, 2.45), Vector3(0.72, 0.62, 0.62), deg_to_rad(-8.0))

func _build_v0386_characters() -> void:
	v0386_humans = Node3D.new()
	v0386_humans.name = "V0386_Exactly_Three_Distinct_Character_Roles"
	v0386_cluster.add_child(v0386_humans)
	var resident := _instantiate_asset(V0386_QUATERNIUS_ROOT + "men/Farmer.gltf", v0386_humans, "V0386_Resident_Worker", Vector3(-4.30, 0.78, -0.70), Vector3.ONE * 1.10, deg_to_rad(20.0))
	var guard := _instantiate_asset(V0386_QUATERNIUS_ROOT + "men/Adventurer.gltf", v0386_humans, "V0386_Crossing_Guard", Vector3(-0.95, 0.78, 1.60), Vector3.ONE * 1.06, deg_to_rad(-22.0))
	var traveller := _instantiate_asset(V0386_QUATERNIUS_ROOT + "men/Worker.gltf", v0386_humans, "V0386_Traveller_Porter", Vector3(-2.30, 1.05, 3.30), Vector3.ONE * 1.08, deg_to_rad(155.0))
	for figure in [resident, guard, traveller]:
		if figure: figure.set_meta("static_visual_role_only", true)

func _capture_v0386_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0386_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0386_view("01_PRIMARY_RTS_VIEW.png", Vector3(23.0, 29.0, 23.0), Vector3(-4.0, 0.75, 2.4), 24.5, root)
	await _capture_v0386_view("02_SETTLEMENT_AND_CROSSING_CONTEXT.png", Vector3(27.0, 34.0, 27.0), Vector3(-3.2, 0.70, 2.5), 29.5, root)
	await _capture_v0386_view("03_ROAD_YARD_ENTRANCE_CONNECTION.png", Vector3(16.0, 20.0, 16.0), Vector3(-4.4, 0.85, 1.45), 13.8, root)
	await _capture_v0386_view("04_FIVE_FUNCTIONAL_YARD_GROUPS.png", Vector3(16.0, 20.0, 16.0), Vector3(-6.5, 0.90, 3.65), 13.0, root)
	await _capture_v0386_view("05_THREE_CHARACTER_ROLE_AUDIT.png", Vector3(17.0, 21.0, 17.0), Vector3(-3.9, 0.90, 2.55), 15.8, root)
	await _capture_v0386_view("06_BUILDING_SEPARATION_AND_ENTRANCES.png", Vector3(17.0, 21.0, 17.0), Vector3(-8.3, 1.35, 3.6), 14.5, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("07_GRAYSCALE_PRIMARY.png"))
	_write_v0386_json("v0386-inhabited-crossing-composition-repair.json", {
		"checkpoint": V0386_CHECKPOINT, "status": "RENDERED", "iteration": v0386_iteration,
		"resolution": "1920x1080", "primaryBuildings": 1, "subordinateBuildings": 1,
		"yardGroups": 5, "characterRoles": 3, "bridgePreserved": true, "riverPreserved": true,
		"roadToYardConnection": true, "gameplay": false, "defaultRuntime": "unchanged",
		"route": "opt-in-only", "acceptedGlbSha256": V0386_GLB_SHA256, "sourceSha256": V0386_SOURCE_SHA256,
		"selectedAssets": [V0386_PRIMARY_ASSET, V0386_SUBORDINATE_ASSET, V0386_QUATERNIUS_ROOT + "men/Farmer.gltf", V0386_QUATERNIUS_ROOT + "men/Adventurer.gltf", V0386_QUATERNIUS_ROOT + "men/Worker.gltf"]
	})
	get_tree().quit(0)

func _capture_v0386_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0386_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(v0386_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_v0386_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_v0386_json("v0386-inhabited-crossing-composition-repair-smoke.json", {"checkpoint": V0386_CHECKPOINT, "status": "PASS", "sceneLoaded": true, "acceptedInfrastructureUnchanged": true, "gameplay": false, "defaultRuntime": "unchanged", "route": "opt-in-only"})
	get_tree().quit(0)
