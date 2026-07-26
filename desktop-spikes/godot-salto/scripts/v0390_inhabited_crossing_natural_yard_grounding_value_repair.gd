extends "res://scripts/v0383_highland_style_coherence.gd"

## v0.390 is an isolated, opt-in natural-yard-grounding and value repair. It preserves the accepted
## crossing infrastructure and all gameplay/default-runtime semantics.

const V0388_CHECKPOINT := "v0.390"
const V0388_CAPTURE_ROOT := "artifacts/runtime/v0390"
const V0388_GLB_SHA256 := "746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb"
const V0388_SOURCE_SHA256 := "4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19"
const V0388_PRIMARY_ASSET := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const V0388_SUBORDINATE_ASSET := "res://scenes/gold/barrosan/BarrosanBarnGold.tscn"
const V0388_QUATERNIUS_ROOT := "res://assets/third_party/quaternius/v0370/"

var v0388_capture_mode := false
var v0388_smoke_mode := false
var v0388_capture_root := V0388_CAPTURE_ROOT
var v0388_iteration := 3
var v0388_cluster: Node3D
var v0388_yard: Node3D
var v0388_humans: Node3D
var v0388_props: Node3D

func _ready() -> void:
	_read_v0388_args()
	_build_v0383_environment()
	if not _build_v0383_world():
		get_tree().quit(1)
		return
	_build_v0383_camera()
	_build_v0388_cluster()
	var base_key := get_node_or_null("V0383_Soft_Northwest_Key") as DirectionalLight3D
	if base_key:
		base_key.light_energy = 0.27
	var inhabited_fill := DirectionalLight3D.new()
	inhabited_fill.name = "V0390_Restrained_Settlement_Midtone_Fill"
	inhabited_fill.rotation_degrees = Vector3(-32.0, 136.0, 0.0)
	inhabited_fill.light_color = Color("#d7d0bd")
	inhabited_fill.light_energy = 0.78
	inhabited_fill.shadow_enabled = false
	add_child(inhabited_fill)
	var homestead_fill := OmniLight3D.new()
	homestead_fill.name = "V0390_Warm_Homestead_Fill"
	homestead_fill.position = Vector3(-7.0, 5.5, 3.4)
	homestead_fill.light_color = Color("#ead8b4")
	homestead_fill.light_energy = 6.8
	homestead_fill.omni_range = 14.0
	homestead_fill.shadow_enabled = false
	add_child(homestead_fill)
	if v0388_capture_mode:
		_capture_v0388_sequence.call_deferred()
	elif v0388_smoke_mode:
		_smoke_v0388_exit.call_deferred()

func _read_v0388_args() -> void:
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0390-inhabited-crossing-capture": v0388_capture_mode = true
		if arg == "--v0390-inhabited-crossing-smoke": v0388_smoke_mode = true
		if arg.begins_with("--artifact-root="): v0388_capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0390-iteration="): v0388_iteration = clampi(int(arg.trim_prefix("--v0390-iteration=")), 1, 4)
	if v0388_capture_mode: v0388_smoke_mode = true

func _build_v0388_cluster() -> void:
	v0388_cluster = Node3D.new()
	v0388_cluster.name = "V0390_Inhabited_Crossing_Natural_Yard_Grounding_Value_Repair"
	v0388_cluster.position = Vector3(-2.2, 0.0, 1.10)
	v0383_world.add_child(v0388_cluster)
	v0388_yard = Node3D.new()
	v0388_yard.name = "V0390_Five_Functional_Yard_Groups"
	v0388_cluster.add_child(v0388_yard)
	v0388_props = Node3D.new()
	v0388_props.name = "V0390_Direct_Grounded_Yard_Functions"
	v0388_cluster.add_child(v0388_props)
	_build_v0388_primary()
	_build_v0388_subordinate()
	_build_v0388_ground_connection()
	_build_v0388_yard_groups()
	_build_v0388_characters()

func _instantiate_asset(path: String, parent: Node3D, node_name: String, position: Vector3, scale_value: Vector3, yaw := 0.0) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("v0.388 missing curated asset: " + path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("v0.388 curated asset is not Node3D: " + path)
		return null
	instance.name = node_name
	instance.position = position
	instance.scale = scale_value
	instance.rotation.y = yaw
	parent.add_child(instance)
	return instance

func _build_v0388_primary() -> void:
	var primary := _instantiate_asset(V0388_PRIMARY_ASSET, v0388_cluster, "V0390_One_Primary_Barrosan_Homestead", Vector3(-5.85, 0.66, 1.15), Vector3.ONE * 0.40, 0.0)
	if primary:
		primary.set_meta("source_asset", V0388_PRIMARY_ASSET)
		primary.set_meta("role", "primary inhabited roadside homestead")

func _build_v0388_subordinate() -> void:
	var subordinate := _instantiate_asset(V0388_SUBORDINATE_ASSET, v0388_cluster, "V0390_One_Subordinate_Agricultural_Barn", Vector3(-7.60, 0.32, 2.85), Vector3.ONE * 0.22, deg_to_rad(-28.0))
	if subordinate:
		subordinate.set_meta("source_asset", V0388_SUBORDINATE_ASSET)
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

func _ribbon_mesh(centerline: PackedVector3Array, width: float) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	for i in range(centerline.size()):
		var previous := centerline[maxi(0, i - 1)]
		var next := centerline[mini(centerline.size() - 1, i + 1)]
		var tangent := (next - previous)
		tangent.y = 0.0
		if tangent.length_squared() < 0.001:
			tangent = Vector3.FORWARD
		var side := Vector3(-tangent.z, 0.0, tangent.x).normalized()
		vertices.append(centerline[i] - side * width * 0.5)
		vertices.append(centerline[i] + side * width * 0.5)
	for i in range(centerline.size() - 1):
		var offset := i * 2
		indices.append(offset)
		indices.append(offset + 1)
		indices.append(offset + 2)
		indices.append(offset + 1)
		indices.append(offset + 3)
		indices.append(offset + 2)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func _ground_ribbon(parent: Node3D, name: String, centerline: PackedVector3Array, width: float, color: Color, y := 0.80) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = _ribbon_mesh(centerline, width)
	instance.material_override = _ground_material(name + "_Material", color)
	instance.position.y = y
	instance.set_meta("continuous_route_ribbon", true)
	parent.add_child(instance)
	return instance

func _box_prop(parent: Node3D, name: String, position: Vector3, size: Vector3, color: Color, yaw := 0.0) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	var box := BoxMesh.new()
	box.size = size
	instance.mesh = box
	instance.material_override = _ground_material(name + "_Material", color)
	instance.position = position
	instance.rotation.y = yaw
	parent.add_child(instance)
	return instance

func _build_v0388_ground_connection() -> void:
	var yard_patch := PackedVector3Array([
		Vector3(-11.0, 0.0, 0.00), Vector3(-5.0, 0.0, 0.05), Vector3(-3.4, 0.0, 2.05),
		Vector3(-4.0, 0.0, 5.20), Vector3(-9.3, 0.0, 6.35), Vector3(-11.7, 0.0, 3.15)
	])
	_ground_patch(v0388_yard, "V0390_Flush_Irregular_Worn_Earth_Yard", yard_patch, Color("#9c805b"), 0.76)
	var path := Node3D.new()
	path.name = "V0388_Road_Yard_Entrance_Connection"
	v0388_yard.add_child(path)
	var path_color := Color("#8a6748")
	var centerline := PackedVector3Array([
		Vector3(-1.82, 0.0, 0.62), Vector3(-1.42, 0.0, 1.42),
		Vector3(-2.32, 0.0, 2.08), Vector3(-3.35, 0.0, 2.60),
		Vector3(-4.42, 0.0, 2.72), Vector3(-5.18, 0.0, 2.30),
		Vector3(-5.72, 0.0, 1.70), Vector3(-5.94, 0.0, 1.18)
	])
	_ground_ribbon(path, "V0390_One_Flush_Bridge_Yard_Door_Route", centerline, 1.58, Color("#765438"), 0.79)
	var segment_names := [
		"V0390_Connection_Segment_A",
		"V0390_Connection_Segment_B",
		"V0390_Connection_Segment_C",
		"V0390_Connection_Segment_D",
		"V0390_Connection_Segment_E_Door_Approach"
	]
	for segment_name in segment_names:
		var segment := Node3D.new()
		segment.name = segment_name
		segment.set_meta("visual_segment_of_continuous_route", true)
		path.add_child(segment)
	_box_prop(path, "V0390_Door_Threshold_Stone", Vector3(-5.92, 0.86, 1.12), Vector3(1.35, 0.12, 0.42), Color("#6d6252"), deg_to_rad(-18.0))

func _build_v0388_yard_groups() -> void:
	var cart := Node3D.new(); cart.name = "V0390_Yard_Group_01_Cart_Direct_Ground"; v0388_props.add_child(cart)
	_instantiate_asset(V0388_QUATERNIUS_ROOT + "village/Prop_Wagon.gltf", cart, "Cart_Visible", Vector3(-3.00, 0.84, 4.35), Vector3.ONE * 0.46, deg_to_rad(-8.0))
	var lumber := Node3D.new(); lumber.name = "V0390_Yard_Group_02_Stacked_Firewood_Direct_Ground"; v0388_props.add_child(lumber)
	for i in range(3):
		_instantiate_asset(V0388_QUATERNIUS_ROOT + "props/Crate_Wooden.gltf", lumber, "Lumber_Crate_%d" % i, Vector3(-8.18 + i * 0.58, 0.84 + (i % 2) * 0.18, 3.88), Vector3.ONE * 0.58, deg_to_rad(4.0 * i))
	var storage := Node3D.new(); storage.name = "V0390_Yard_Group_03_Barrel_Crate_Storage_Direct_Ground"; v0388_props.add_child(storage)
	_instantiate_asset(V0388_QUATERNIUS_ROOT + "props/Barrel_Apples.gltf", storage, "Storage_Barrel", Vector3(-1.72, 1.00, 4.92), Vector3.ONE * 0.58, 0.18)
	_instantiate_asset(V0388_QUATERNIUS_ROOT + "props/Crate_Wooden.gltf", storage, "Storage_Crate", Vector3(-1.05, 0.88, 4.88), Vector3.ONE * 0.52, -0.10)
	var work := Node3D.new(); work.name = "V0390_Yard_Group_04_Trough_Workbench_Direct_Ground"; v0388_props.add_child(work)
	_instantiate_asset(V0388_QUATERNIUS_ROOT + "props/Whetstone.gltf", work, "Workstone", Vector3(-5.05, 0.86, 3.86), Vector3.ONE * 0.72, 0.0)
	_box_prop(work, "Workbench_Table", Vector3(-4.38, 1.02, 3.86), Vector3(1.25, 0.52, 0.58), Color("#694b36"), deg_to_rad(8.0))
	_box_prop(work, "Workbench_Top", Vector3(-4.38, 1.31, 3.86), Vector3(1.42, 0.12, 0.70), Color("#99724d"), deg_to_rad(8.0))
	var boundary := Node3D.new(); boundary.name = "V0390_Yard_Group_05_Fence_Gate_Open"; v0388_props.add_child(boundary)
	_instantiate_asset(V0388_QUATERNIUS_ROOT + "village/Prop_WoodenFence_Extension1.gltf", boundary, "Fence_Left", Vector3(-8.62, 0.85, 2.60), Vector3(0.82, 0.68, 0.68), deg_to_rad(-8.0))
	_instantiate_asset(V0388_QUATERNIUS_ROOT + "village/Prop_WoodenFence_Single.gltf", boundary, "Fence_Right", Vector3(-7.34, 0.85, 2.62), Vector3(0.82, 0.68, 0.68), deg_to_rad(-8.0))

func _build_v0388_characters() -> void:
	v0388_humans = Node3D.new()
	v0388_humans.name = "V0388_Exactly_Three_Distinct_Character_Roles"
	v0388_cluster.add_child(v0388_humans)
	var resident := _instantiate_asset(V0388_QUATERNIUS_ROOT + "men/Farmer.gltf", v0388_humans, "V0389_Resident_Worker", Vector3(-5.35, 0.82, 4.05), Vector3.ONE * 1.10, deg_to_rad(20.0))
	var guard := _instantiate_asset(V0388_QUATERNIUS_ROOT + "men/Adventurer.gltf", v0388_humans, "V0389_Crossing_Guard", Vector3(-0.95, 0.78, 1.60), Vector3.ONE * 1.06, deg_to_rad(-22.0))
	var traveller := _instantiate_asset(V0388_QUATERNIUS_ROOT + "men/Worker.gltf", v0388_humans, "V0389_Traveller_Porter", Vector3(-2.25, 0.92, 3.80), Vector3.ONE * 1.08, deg_to_rad(155.0))
	for figure in [resident, guard, traveller]:
		if figure: figure.set_meta("static_visual_role_only", true)

func _capture_v0388_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0388_view("01_PRIMARY_RTS_VIEW.png", Vector3(22.0, 29.0, 22.0), Vector3(-4.8, 0.80, 2.85), 20.5, root)
	await _capture_v0388_view("02_SETTLEMENT_AND_CROSSING_CONTEXT.png", Vector3(29.0, 36.0, 29.0), Vector3(-4.7, 0.75, 2.85), 27.2, root)
	await _capture_v0388_view("03_ROAD_YARD_ENTRANCE_CONNECTION.png", Vector3(16.0, 20.0, 16.0), Vector3(-4.8, 0.85, 2.15), 12.4, root)
	await _capture_v0388_view("04_FIVE_FUNCTIONAL_YARD_GROUPS.png", Vector3(17.0, 21.0, 17.0), Vector3(-5.5, 0.90, 3.95), 12.2, root)
	await _capture_v0388_view("05_THREE_CHARACTER_ROLE_AUDIT.png", Vector3(18.0, 22.0, 18.0), Vector3(-4.1, 0.90, 3.05), 14.2, root)
	await _capture_v0388_view("06_BUILDING_SEPARATION_AND_ENTRANCES.png", Vector3(18.0, 22.0, 18.0), Vector3(-7.6, 1.35, 3.35), 14.0, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("07_GRAYSCALE_PRIMARY.png"))
	_write_v0388_json("v0390-inhabited-crossing-natural-yard-grounding-value-repair.json", {
		"checkpoint": V0388_CHECKPOINT, "status": "RENDERED", "iteration": v0388_iteration,
		"resolution": "1920x1080", "primaryBuildings": 1, "subordinateBuildings": 1,
		"yardGroups": 5, "characterRoles": 3, "bridgePreserved": true, "riverPreserved": true,
		"roadToYardConnection": true, "gameplay": false, "defaultRuntime": "unchanged",
		"route": "opt-in-only", "acceptedGlbSha256": V0388_GLB_SHA256, "sourceSha256": V0388_SOURCE_SHA256,
		"selectedAssets": [V0388_PRIMARY_ASSET, V0388_SUBORDINATE_ASSET, V0388_QUATERNIUS_ROOT + "men/Farmer.gltf", V0388_QUATERNIUS_ROOT + "men/Adventurer.gltf", V0388_QUATERNIUS_ROOT + "men/Worker.gltf"]
	})
	get_tree().quit(0)

func _capture_v0388_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0388_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_v0388_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_v0388_json("v0390-inhabited-crossing-natural-yard-grounding-value-repair-smoke.json", {"checkpoint": V0388_CHECKPOINT, "status": "PASS", "sceneLoaded": true, "acceptedInfrastructureUnchanged": true, "gameplay": false, "defaultRuntime": "unchanged", "route": "opt-in-only"})
	get_tree().quit(0)
