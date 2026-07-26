extends "res://scripts/v0383_highland_style_coherence.gd"

## v0.384 isolated visual target: one inhabited Barrosan crossing cluster.
## The accepted v0.380 infrastructure GLB and v0.383 dressing remain read-only;
## all buildings, props, humans, and ground connection are scene-local.

const V0384_CHECKPOINT := "v0.384"
const V0384_CAPTURE_ROOT := "artifacts/runtime/v0384"
const V0384_GLB_SHA256 := "746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb"
const V0384_SOURCE_SHA256 := "4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19"

var v0384_capture_mode := false
var v0384_smoke_mode := false
var v0384_capture_root := V0384_CAPTURE_ROOT
var v0384_iteration := 3
var v0384_cluster: Node3D
var v0384_primary: Node3D
var v0384_subordinate: Node3D
var v0384_yard: Node3D
var v0384_humans: Node3D
var v0384_props: Node3D
var v0384_materials: Dictionary = {}

func _ready() -> void:
	_read_v0384_args()
	super._ready()
	if get_tree().get_root().get_node_or_null("V0384_First_Inhabited_Crossing") != null:
		return
	_build_v0384_cluster()
	var yard_fill := DirectionalLight3D.new()
	yard_fill.name = "V0384_Soft_Yard_Fill_No_Shadow"
	yard_fill.rotation_degrees = Vector3(-38.0, 148.0, 0.0)
	yard_fill.light_color = Color("#d7d5c7")
	yard_fill.light_energy = 0.22
	yard_fill.shadow_enabled = false
	add_child(yard_fill)
	if v0384_capture_mode:
		_capture_v0384_sequence.call_deferred()
	elif v0384_smoke_mode:
		_smoke_v0384_exit.call_deferred()

func _read_v0384_args() -> void:
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0384-inhabited-crossing-capture": v0384_capture_mode = true
		if arg == "--v0384-inhabited-crossing-smoke": v0384_smoke_mode = true
		if arg.begins_with("--artifact-root="): v0384_capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0384-iteration="): v0384_iteration = clampi(int(arg.trim_prefix("--v0384-iteration=")), 1, 3)
	if v0384_capture_mode: v0384_smoke_mode = true

func _build_v0384_cluster() -> void:
	v0384_cluster = Node3D.new()
	v0384_cluster.name = "V0384_First_Inhabited_Crossing"
	if v0384_iteration >= 2:
		v0384_cluster.position = Vector3(-2.2, 0.0, 1.10)
	v0383_world.add_child(v0384_cluster)
	v0384_yard = Node3D.new()
	v0384_yard.name = "V0384_Functional_Yard_One_Cluster"
	v0384_cluster.add_child(v0384_yard)
	v0384_props = Node3D.new()
	v0384_props.name = "V0384_Curated_Yard_Props_Seven"
	v0384_cluster.add_child(v0384_props)
	v0384_primary = _build_primary_homestead(Vector3(-7.0, 0.58, 2.45))
	v0384_subordinate = _build_subordinate_shed(Vector3(-4.25, 0.60, 4.55))
	_build_irregular_yard()
	_build_curated_yard_props()
	v0384_humans = Node3D.new()
	v0384_humans.name = "V0384_Exactly_Three_Temporary_Humans"
	v0384_cluster.add_child(v0384_humans)
	_build_human("Worker_Resident", Vector3(-6.0, 0.70, 2.00), Color("#8d6542"), Color("#d0a064"), false)
	_build_human("Militia_Crossing_Guard", Vector3(-2.0, 0.70, 0.85), Color("#4b5f70"), Color("#b8c7c1"), true)
	_build_human("Traveller_Porter", Vector3(-4.3, 0.70, 1.25), Color("#6b4b45"), Color("#c28b64"), false)

func _material(key: String, color: Color, roughness: float = 0.86) -> StandardMaterial3D:
	if v0384_materials.has(key): return v0384_materials[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = 0.0
	v0384_materials[key] = material
	return material

func _mesh(parent: Node3D, name: String, mesh: Mesh, material: Material, position: Vector3, scale := Vector3.ONE, rotation := Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.scale = scale
	instance.rotation = rotation
	parent.add_child(instance)
	return instance

func _box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh

func _cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.94
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	return mesh

func _build_primary_homestead(origin: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = "V0384_Primary_Barrosan_Roadside_Homestead"
	root.position = origin
	v0384_cluster.add_child(root)
	var stone := _material("granite", Color("#656663"))
	var plaster := _material("warm_plaster", Color("#9c8d73"))
	var timber := _material("weathered_timber", Color("#4c3b30"))
	var slate_color := Color("#5b5d56") if v0384_iteration >= 2 else Color("#4b4d48")
	var slate := _material("charcoal_slate", slate_color)
	var door := _material("door", Color("#3a3029"))
	var glass := _material("window", Color("#91a49c"), 0.42)
	_mesh(root, "Foundation_Grounded", _box(Vector3(5.25, 0.34, 3.75)), stone, Vector3(0, 0.18, 0))
	_mesh(root, "Wall_Main", _box(Vector3(4.85, 2.25, 3.35)), plaster, Vector3(0, 1.34, 0))
	_mesh(root, "Wall_Timber_Front", _box(Vector3(4.95, 0.16, 0.12)), timber, Vector3(0, 1.12, 1.70))
	_mesh(root, "Wall_Timber_Back", _box(Vector3(4.95, 0.16, 0.12)), timber, Vector3(0, 1.12, -1.70))
	_mesh(root, "Wall_Timber_Left", _box(Vector3(0.12, 0.16, 3.35)), timber, Vector3(-2.42, 1.12, 0))
	_mesh(root, "Wall_Timber_Right", _box(Vector3(0.12, 0.16, 3.35)), timber, Vector3(2.42, 1.12, 0))
	_mesh(root, "Door_Entrance", _box(Vector3(0.78, 1.46, 0.12)), door, Vector3(0.62, 0.90, 1.73))
	_mesh(root, "Door_Frame", _box(Vector3(1.04, 1.68, 0.14)), timber, Vector3(0.62, 0.99, 1.80))
	_mesh(root, "Window_Left", _box(Vector3(0.82, 0.72, 0.10)), glass, Vector3(-1.45, 1.38, 1.73))
	_mesh(root, "Window_Right", _box(Vector3(0.82, 0.72, 0.10)), glass, Vector3(1.55, 1.38, 1.73))
	_mesh(root, "Roof_Left_Plane", _box(Vector3(5.45, 0.20, 2.05)), slate, Vector3(0, 2.72, -0.86), Vector3.ONE, Vector3(deg_to_rad(-24.0), 0, 0))
	_mesh(root, "Roof_Right_Plane", _box(Vector3(5.45, 0.20, 2.05)), slate, Vector3(0, 2.72, 0.86), Vector3.ONE, Vector3(deg_to_rad(24.0), 0, 0))
	_mesh(root, "Roof_Ridge", _cylinder(0.16, 5.50), timber, Vector3(0, 3.14, 0), Vector3.ONE, Vector3(0, 0, deg_to_rad(90.0)))
	_mesh(root, "Chimney", _box(Vector3(0.46, 0.82, 0.46)), stone, Vector3(-1.35, 3.17, -0.10))
	_mesh(root, "Step_One", _box(Vector3(1.14, 0.16, 0.56)), stone, Vector3(0.62, 0.39, 2.02))
	_mesh(root, "Step_Two", _box(Vector3(0.96, 0.14, 0.38)), stone, Vector3(0.62, 0.52, 1.85))
	return root

func _build_subordinate_shed(origin: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = "V0384_Subordinate_Timber_Shed"
	root.position = origin
	v0384_cluster.add_child(root)
	var timber := _material("shed_timber", Color("#665343"))
	var dark_color := Color("#605b4d") if v0384_iteration >= 2 else Color("#4c4941")
	var dark := _material("shed_roof", dark_color)
	var stone := _material("shed_base", Color("#707067"))
	_mesh(root, "Shed_Base", _box(Vector3(3.45, 0.24, 2.42)), stone, Vector3(0, 0.13, 0))
	_mesh(root, "Shed_Walls", _box(Vector3(3.15, 1.72, 2.15)), timber, Vector3(0, 1.02, 0))
	_mesh(root, "Shed_Opening", _box(Vector3(1.18, 1.18, 0.10)), _material("shed_opening", Color("#252725")), Vector3(0, 0.82, 1.10))
	_mesh(root, "Shed_Roof_Left", _box(Vector3(3.72, 0.18, 1.42)), dark, Vector3(0, 2.03, -0.52), Vector3.ONE, Vector3(deg_to_rad(-25.0), 0, 0))
	_mesh(root, "Shed_Roof_Right", _box(Vector3(3.72, 0.18, 1.42)), dark, Vector3(0, 2.03, 0.52), Vector3.ONE, Vector3(deg_to_rad(25.0), 0, 0))
	_mesh(root, "Shed_Ridge", _cylinder(0.11, 3.78), timber, Vector3(0, 2.35, 0), Vector3.ONE, Vector3(0, 0, deg_to_rad(90.0)))
	return root

func _build_irregular_yard() -> void:
	var mesh := ArrayMesh.new()
	var vertices := PackedVector3Array([
		Vector3(-9.0, 0.66, 0.55), Vector3(-4.0, 0.66, 0.40), Vector3(-3.25, 0.66, 2.45),
		Vector3(-4.25, 0.66, 4.05), Vector3(-7.25, 0.66, 4.65), Vector3(-9.10, 0.66, 3.10)
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 5])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_mesh(v0384_yard, "Worn_Irregular_Yard_Connection", mesh, _material("yard_earth", Color("#806b50")), Vector3.ZERO)
	var path_mesh := ArrayMesh.new()
	var path_vertices := PackedVector3Array([
		Vector3(-8.65, 0.73, 0.24), Vector3(-8.18, 0.73, 0.74), Vector3(-5.25, 0.73, 1.72),
		Vector3(-4.85, 0.73, 1.38), Vector3(-7.82, 0.73, 0.05), Vector3(-8.45, 0.73, -0.06)
	])
	var path_indices := PackedInt32Array([0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 5])
	var path_arrays := []
	path_arrays.resize(Mesh.ARRAY_MAX)
	path_arrays[Mesh.ARRAY_VERTEX] = path_vertices
	path_arrays[Mesh.ARRAY_INDEX] = path_indices
	path_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, path_arrays)
	_mesh(v0384_yard, "Worn_Tapered_Footpath_No_Rectangle", path_mesh, _material("footpath", Color("#8b7354")), Vector3.ZERO)

func _build_curated_yard_props() -> void:
	var wood := _material("prop_wood", Color("#574536"))
	var wood_light := _material("prop_wood_light", Color("#795b3e"))
	var metal := _material("prop_metal", Color("#62615b"), 0.64)
	var hay := _material("prop_hay", Color("#9a8050"))
	_mesh(v0384_props, "Prop_Wagon", _box(Vector3(2.1, 0.18, 0.95)), wood, Vector3(-5.35, 0.88, 3.48), Vector3.ONE, Vector3(0, deg_to_rad(-8.0), 0))
	_mesh(v0384_props, "Prop_Wagon_Axle", _cylinder(0.10, 2.4), metal, Vector3(-5.35, 0.58, 3.06), Vector3.ONE, Vector3(0, 0, deg_to_rad(90.0)))
	_mesh(v0384_props, "Prop_Barrel", _cylinder(0.34, 0.72), wood_light, Vector3(-3.75, 1.02, 2.30))
	_mesh(v0384_props, "Prop_Crate_Group", _box(Vector3(0.76, 0.62, 0.76)), wood_light, Vector3(-3.38, 0.93, 3.25), Vector3.ONE, Vector3(0, deg_to_rad(12.0), 0))
	_mesh(v0384_props, "Prop_Firewood_Stack", _cylinder(0.18, 1.25), wood_light, Vector3(-7.85, 0.92, 3.54), Vector3.ONE, Vector3(deg_to_rad(90.0), 0, deg_to_rad(10.0)))
	_mesh(v0384_props, "Prop_Trough", _box(Vector3(1.20, 0.35, 0.48)), hay, Vector3(-7.85, 0.82, 1.05))
	_mesh(v0384_props, "Prop_Fence_Line", _box(Vector3(2.55, 0.12, 0.12)), wood, Vector3(-8.05, 1.00, 2.20), Vector3.ONE, Vector3(0, deg_to_rad(-6.0), 0))
	_mesh(v0384_props, "Prop_Fence_Post_A", _box(Vector3(0.12, 0.92, 0.12)), wood, Vector3(-9.25, 1.05, 2.15))
	_mesh(v0384_props, "Prop_Fence_Post_B", _box(Vector3(0.12, 0.92, 0.12)), wood, Vector3(-6.85, 1.05, 2.26))

func _build_human(name: String, position: Vector3, coat: Color, skin: Color, guard: bool) -> void:
	var root := Node3D.new()
	root.name = "V0384_Human_" + name
	root.position = position
	v0384_humans.add_child(root)
	var body := _material("human_" + name + "_coat", coat)
	var flesh := _material("human_" + name + "_skin", skin)
	var dark := _material("human_" + name + "_boots", Color("#302c29"))
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.24
	body_mesh.height = 0.92
	body_mesh.radial_segments = 10
	_mesh(root, "Body", body_mesh, body, Vector3(0, 0.80, 0))
	var head := SphereMesh.new()
	head.radius = 0.23
	head.height = 0.46
	head.radial_segments = 10
	head.rings = 6
	_mesh(root, "Head", head, flesh, Vector3(0, 1.43, 0))
	_mesh(root, "Leg_L", _box(Vector3(0.14, 0.52, 0.18)), dark, Vector3(-0.10, 0.34, 0))
	_mesh(root, "Leg_R", _box(Vector3(0.14, 0.52, 0.18)), dark, Vector3(0.10, 0.34, 0))
	_mesh(root, "Arm_L", _box(Vector3(0.13, 0.58, 0.16)), body, Vector3(-0.30, 0.82, 0), Vector3.ONE, Vector3(0, 0, deg_to_rad(-8.0)))
	_mesh(root, "Arm_R", _box(Vector3(0.13, 0.58, 0.16)), body, Vector3(0.30, 0.82, 0), Vector3.ONE, Vector3(0, 0, deg_to_rad(8.0)))
	if guard:
		_mesh(root, "Guard_Shield", _box(Vector3(0.34, 0.48, 0.10)), _material("guard_shield", Color("#7b5a3f")), Vector3(0.34, 0.82, 0.10))

func _capture_v0384_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0384_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0384_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 30.0, 24.0), Vector3(-1.6, 0.65, 1.0), 28.0, root)
	await _capture_v0384_view("02_SETTLEMENT_AND_CROSSING_CONTEXT.png", Vector3(26.0, 34.0, 26.0), Vector3(-1.4, 0.58, 1.1), 29.0, root)
	await _capture_v0384_view("03_PRIMARY_BUILDING_AND_YARD_DETAIL.png", Vector3(15.0, 18.0, 15.0), Vector3(-5.6, 0.85, 2.2), 11.5, root)
	await _capture_v0384_view("04_BRIDGE_AND_ROAD_CONNECTION.png", Vector3(18.0, 24.0, 18.0), Vector3(-0.2, 0.35, 0.0), 16.0, root)
	await _capture_v0384_view("05_CHARACTER_SCALE_AND_PLACEMENT.png", Vector3(13.0, 16.0, 13.0), Vector3(-4.5, 0.82, 1.6), 10.0, root)
	await _capture_v0384_view("06_DRESSING_AND_PROP_DISTRIBUTION.png", Vector3(14.0, 19.0, 14.0), Vector3(-5.8, 0.72, 2.5), 10.5, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("07_GRAYSCALE_PRIMARY.png"))
	_write_v0384_json("v0384-first-inhabited-crossing.json", {
		"checkpoint": V0384_CHECKPOINT,
		"status": "RENDERED",
		"iteration": v0384_iteration,
		"resolution": "1920x1080",
		"acceptedBase": "v0.380 corrected highland infrastructure",
		"acceptedBaseUnchanged": true,
		"v0383DressingPreserved": true,
		"primaryBuildings": 1,
		"subordinateBuildings": 1,
		"functionalYardProps": 9,
		"temporaryHumans": 3,
		"sceneLocalOnly": true,
		"gameplay": false,
		"movement": false,
		"defaultRuntime": "unchanged",
		"route": "opt-in-only",
		"glbSha256": V0384_GLB_SHA256,
		"sourceSha256": V0384_SOURCE_SHA256
	})
	get_tree().quit(0)

func _capture_v0384_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080:
		image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0384_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(v0384_capture_root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_v0384_exit() -> void:
	await get_tree().create_timer(0.8).timeout
	_write_v0384_json("v0384-first-inhabited-crossing-smoke.json", {
		"checkpoint": V0384_CHECKPOINT,
		"status": "PASS",
		"sceneLoaded": true,
		"acceptedBaseUnchanged": true,
		"primaryBuildings": 1,
		"subordinateBuildings": 1,
		"functionalYardProps": 9,
		"temporaryHumans": 3,
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"route": "opt-in-only",
		"glbSha256": V0384_GLB_SHA256,
		"sourceSha256": V0384_SOURCE_SHA256
	})
	get_tree().quit(0)
