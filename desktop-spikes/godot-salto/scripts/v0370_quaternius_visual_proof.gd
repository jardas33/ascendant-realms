extends Node3D

## Isolated v0.370 non-gameplay visual target. The accepted runtime never
## enters this scene unless the explicit v0.370 command-line flag is present.

const CHECKPOINT := "v0.370"
const CAPTURE_ROOT := "artifacts/runtime/v0370"
const ASSET_ROOT := "res://assets/third_party/quaternius/v0370/"

var capture_mode := false
var smoke_mode := false
var capture_root := CAPTURE_ROOT
var camera: Camera3D
var world: Node3D
var materials: Dictionary = {}

func _ready() -> void:
	seed(370)
	_read_args()
	_build_environment()
	_build_world()
	_build_camera()
	if capture_mode:
		_capture_sequence.call_deferred()
	elif smoke_mode:
		_smoke_exit.call_deferred()

func _read_args() -> void:
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0370-quaternius-capture": capture_mode = true
		if arg == "--v0370-quaternius-smoke": smoke_mode = true
		if arg.begins_with("--artifact-root="): capture_root = arg.trim_prefix("--artifact-root=")
	if capture_mode: smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#a8b2a5")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#eadfbe")
	environment.ambient_light_energy = 0.60
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0370_Quaternius_Warm_Daylight"
	world_environment.environment = environment
	add_child(world_environment)
	var key := DirectionalLight3D.new()
	key.name = "V0370_Soft_Warm_Key"
	key.rotation_degrees = Vector3(-52.0, -34.0, 0.0)
	key.light_color = Color("#ffe3b5")
	key.light_energy = 0.92
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 80.0
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0370_Restrained_Fill"
	fill.rotation_degrees = Vector3(-32.0, 146.0, 0.0)
	fill.light_color = Color("#adc5bc")
	fill.light_energy = 0.18
	fill.shadow_enabled = false
	add_child(fill)

func _build_world() -> void:
	world = Node3D.new()
	world.name = "V0370_Composed_Quaternius_Sector"
	add_child(world)
	_build_terrain()
	_build_bridge()
	_build_main_hall(Vector3(-8.0, 0.0, -4.0))
	_build_barracks(Vector3(-2.4, 0.0, -5.2))
	_build_resource_site(Vector3(-11.0, 0.0, 1.6))
	_build_camp(Vector3(9.0, 0.0, 5.1))
	_build_nature()
	_build_characters()

func _build_terrain() -> void:
	var left := [Vector3(-16.0, 0.35, -11.0), Vector3(-10.0, 0.22, -11.8), Vector3(-2.0, 0.45, -10.8), Vector3(1.75, 0.28, -8.6), Vector3(1.58, 0.20, -4.6), Vector3(1.76, 0.30, -0.5), Vector3(1.55, 0.16, 3.8), Vector3(1.82, 0.33, 7.4), Vector3(1.42, 0.23, 10.5), Vector3(-3.5, 0.42, 11.8), Vector3(-10.0, 0.18, 10.9), Vector3(-16.0, 0.38, 9.6)]
	var right := [Vector3(4.35, 0.30, -8.6), Vector3(7.5, 0.42, -10.8), Vector3(13.0, 0.18, -10.3), Vector3(16.0, 0.34, -8.1), Vector3(15.6, 0.26, -1.5), Vector3(16.2, 0.46, 4.6), Vector3(14.1, 0.21, 10.8), Vector3(8.2, 0.38, 11.4), Vector3(4.5, 0.28, 10.4), Vector3(4.2, 0.18, 6.5), Vector3(4.45, 0.29, 2.4), Vector3(4.22, 0.20, -1.7), Vector3(4.5, 0.32, -5.2)]
	var continuous_bed := [Vector3(-21.5, -0.92, -15.0), Vector3(-14.0, -0.88, -16.2), Vector3(-4.0, -0.95, -15.4), Vector3(5.0, -0.90, -15.7), Vector3(14.5, -0.84, -13.9), Vector3(22.0, -0.90, -9.0), Vector3(22.5, -0.94, -1.0), Vector3(23.0, -0.88, 8.4), Vector3(16.0, -0.92, 14.2), Vector3(7.0, -0.86, 15.8), Vector3(-2.5, -0.93, 15.5), Vector3(-12.0, -0.87, 15.1), Vector3(-21.0, -0.96, 11.0), Vector3(-23.0, -0.90, 2.0), Vector3(-22.2, -0.95, -7.0)]
	_add_polygon("Continuous_Terrain_Bed", continuous_bed, _mat("terrain_bed", Color("#4f5b48")), world)
	_add_polygon("Grassland_West", left, _mat("grass", Color("#627055")), world)
	_add_polygon("Grassland_East", right, _mat("grass_alt", Color("#6c7b54")), world)
	var water_path := [Vector3(2.72, -0.62, -9.0), Vector3(2.82, -0.68, -6.0), Vector3(2.64, -0.76, -2.5), Vector3(2.78, -0.70, 0.8), Vector3(2.60, -0.78, 4.2), Vector3(2.82, -0.64, 7.3), Vector3(2.65, -0.58, 10.5)]
	_add_ribbon("Stream_Bed", water_path, 2.45, _mat("stream_bed", Color("#4e5146")), world, -0.12)
	var water_surface := [Vector3(1.86, -0.12, -9.0), Vector3(1.96, -0.18, -6.0), Vector3(1.80, -0.25, -2.5), Vector3(1.94, -0.20, 0.8), Vector3(1.78, -0.27, 4.2), Vector3(2.00, -0.14, 7.3), Vector3(1.90, -0.10, 10.5), Vector3(3.48, -0.10, 10.5), Vector3(3.60, -0.14, 7.3), Vector3(3.42, -0.27, 4.2), Vector3(3.60, -0.20, 0.8), Vector3(3.46, -0.25, -2.5), Vector3(3.58, -0.18, -6.0), Vector3(3.50, -0.12, -9.0)]
	for i in range(water_surface.size()): water_surface[i].y = 0.04
	_add_polygon("Recessed_Stream", water_surface, _mat("water", Color("#356872")), world)
	_add_ribbon("Stream_Glint", water_path, 0.18, _mat("water_glint", Color("#79a9a0")), world, 0.04)
	var bank_left := [Vector3(1.66, -0.12, -9.0), Vector3(1.75, -0.18, -6.0), Vector3(1.55, -0.26, -2.5), Vector3(1.70, -0.20, 0.8), Vector3(1.52, -0.28, 4.2), Vector3(1.74, -0.14, 7.3), Vector3(1.62, -0.08, 10.5)]
	var bank_right := [Vector3(4.05, -0.12, -9.0), Vector3(4.04, -0.18, -6.0), Vector3(3.86, -0.26, -2.5), Vector3(4.00, -0.20, 0.8), Vector3(3.84, -0.28, 4.2), Vector3(4.06, -0.14, 7.3), Vector3(4.0, -0.08, 10.5)]
	_add_ribbon("Riverbank_West", bank_left, 0.65, _mat("bank", Color("#a08361")), world, 0.04)
	_add_ribbon("Riverbank_East", bank_right, 0.65, _mat("bank", Color("#997b5c")), world, 0.04)
	var road := [Vector3(-14.0, 0.55, -6.7), Vector3(-11.0, 0.42, -6.0), Vector3(-7.5, 0.48, -5.2), Vector3(-4.5, 0.48, -3.2), Vector3(-0.8, 0.38, -2.0), Vector3(1.15, 0.30, -1.9), Vector3(4.9, 0.40, -1.8), Vector3(7.2, 0.48, 0.1), Vector3(9.8, 0.42, 3.7)]
	_add_ribbon("Organic_Dirt_Route", road, 0.95, _mat("road", Color("#9a704e")), world, 0.08)
	for point in [Vector3(-13.0, 0.55, -6.45), Vector3(-6.8, 0.50, -4.8), Vector3(-3.5, 0.47, -2.9), Vector3(6.8, 0.44, -0.1), Vector3(9.1, 0.44, 2.6)]:
		_place("nature/RockPath_Round_Wide.gltf", world, point + Vector3(0, 0.05, 0), Vector3(0.55, 0.24, 0.55), randf_range(-0.3, 0.3))
	for point in [Vector3(2.1, 0.02, -5.6), Vector3(3.9, 0.02, -4.2), Vector3(2.0, 0.02, 1.8), Vector3(3.9, 0.02, 5.2)]:
		_place("nature/Rock_Medium_2.gltf", world, point, Vector3(0.42, 0.30, 0.42), randf_range(-0.4, 0.4))

func _build_bridge() -> void:
	var bridge := Node3D.new()
	bridge.name = "Composed_Timber_Bridge"
	bridge.position = Vector3(3.0, 0.12, -1.8)
	world.add_child(bridge)
	for index in range(4):
		_place("village/Floor_WoodDark.gltf", bridge, Vector3(-1.65 + index * 1.1, 0.55, 0.0), Vector3(0.55, 0.30, 0.82), 0.0)
	for z in [-0.72, 0.72]:
		for index in range(3):
			_place("village/Prop_WoodenFence_Single.gltf", bridge, Vector3(-1.2 + index * 1.25, 1.02, z), Vector3(0.58, 0.64, 0.48), 0.0)
	for x in [-1.35, 0.0, 1.35]:
		_place("village/Prop_WoodenFence_Extension1.gltf", bridge, Vector3(x, 0.17, -0.76), Vector3(0.25, 0.42, 0.32), 0.0)
		_place("village/Prop_WoodenFence_Extension1.gltf", bridge, Vector3(x, 0.17, 0.76), Vector3(0.25, 0.42, 0.32), 0.0)
	for x in [-1.75, 1.75]:
		_place("village/Stairs_Exterior_Straight.gltf", bridge, Vector3(x, 0.13, 0.0), Vector3(0.42, 0.34, 0.52), 0.0)

func _build_main_hall(origin: Vector3) -> void:
	var hall := Node3D.new(); hall.name = "Main_Hall_Composed"; hall.position = origin; world.add_child(hall)
	_place("village/Floor_WoodDark.gltf", hall, Vector3.ZERO, Vector3(1.25, 0.85, 1.25), 0.0)
	for x in [-1.25, 1.25]: _place("village/Wall_Plaster_Straight.gltf", hall, Vector3(x, 1.2, 0.0), Vector3(0.95, 1.05, 1.0), PI / 2.0)
	_place("village/Wall_Plaster_Door_Round.gltf", hall, Vector3(0.0, 1.2, 1.25), Vector3(1.0, 1.05, 1.0), 0.0)
	_place("village/Wall_Plaster_Straight.gltf", hall, Vector3(0.0, 1.2, -1.25), Vector3(1.0, 1.05, 1.0), 0.0)
	_place("village/Wall_Plaster_Window_Wide_Round.gltf", hall, Vector3(-0.92, 1.22, 1.27), Vector3(0.42, 0.95, 0.85), 0.0)
	_place("village/Roof_RoundTiles_6x10.gltf", hall, Vector3(0.0, 2.7, -0.55), Vector3(0.46, 0.46, 0.42), 0.0)
	_place("village/Roof_RoundTiles_6x10.gltf", hall, Vector3(0.0, 2.7, 0.55), Vector3(0.46, 0.46, 0.42), PI)
	_place("village/Roof_FrontSupports.gltf", hall, Vector3(0.0, 2.15, 1.4), Vector3(0.7, 0.7, 0.7), 0.0)
	_place("props/Stall_Cart_Empty.gltf", hall, Vector3(-2.2, 0.1, 1.7), Vector3(0.7, 0.7, 0.7), 0.1)
	_place("props/Barrel_Apples.gltf", hall, Vector3(2.0, 0.45, 0.6), Vector3(0.45, 0.45, 0.45), 0.2)

func _build_barracks(origin: Vector3) -> void:
	var barracks := Node3D.new(); barracks.name = "Field_Barracks_Composed"; barracks.position = origin; world.add_child(barracks)
	_place("village/Floor_Brick.gltf", barracks, Vector3.ZERO, Vector3(1.10, 0.65, 1.05), 0.0)
	_place("village/Wall_Plaster_Straight.gltf", barracks, Vector3(-1.05, 1.0, 0.0), Vector3(0.80, 0.90, 0.88), PI / 2.0)
	_place("village/Wall_Plaster_Straight.gltf", barracks, Vector3(1.05, 1.0, 0.0), Vector3(0.80, 0.90, 0.88), PI / 2.0)
	_place("village/Wall_Plaster_Door_Round.gltf", barracks, Vector3(0.0, 1.0, 1.05), Vector3(0.82, 0.90, 0.88), 0.0)
	_place("village/Wall_Plaster_Straight.gltf", barracks, Vector3(0.0, 1.0, -1.05), Vector3(0.88, 0.90, 0.88), 0.0)
	_place("village/Roof_RoundTiles_4x6.gltf", barracks, Vector3(0.0, 2.25, 0.0), Vector3(0.50, 0.50, 0.45), 0.0)
	_place("village/Prop_Crate.gltf", barracks, Vector3(1.8, 0.4, 1.0), Vector3(0.42, 0.42, 0.42), 0.0)
	_place("village/Prop_WoodenFence_Single.gltf", barracks, Vector3(-1.7, 0.4, 1.2), Vector3(0.55, 0.50, 0.45), 0.0)

func _build_resource_site(origin: Vector3) -> void:
	var site := Node3D.new(); site.name = "Authored_Resource_Site"; site.position = origin; world.add_child(site)
	for item in [["nature/Rock_Medium_1.gltf", Vector3(-0.7, 0.32, 0.0), Vector3(0.85, 0.62, 0.85)], ["nature/Rock_Medium_2.gltf", Vector3(0.2, 0.24, 0.55), Vector3(0.65, 0.55, 0.65)], ["nature/Rock_Medium_3.gltf", Vector3(0.95, 0.3, -0.25), Vector3(0.72, 0.62, 0.72)]]:
		_place(str(item[0]), site, item[1], item[2], randf_range(-0.5, 0.5))
	_place("props/Whetstone.gltf", site, Vector3(0.0, 0.18, -0.85), Vector3(0.6, 0.6, 0.6), 0.2)
	_place("props/Crate_Wooden.gltf", site, Vector3(-1.35, 0.38, -0.6), Vector3(0.5, 0.5, 0.5), 0.15)
	_place("village/Prop_Wagon.gltf", site, Vector3(0.1, 0.0, 1.8), Vector3(0.65, 0.65, 0.65), 0.2)

func _build_camp(origin: Vector3) -> void:
	var camp := Node3D.new(); camp.name = "Authored_Hostile_Camp"; camp.position = origin; world.add_child(camp)
	for point in [Vector3(-1.8, 0.5, -1.0), Vector3(-1.0, 0.5, -1.4), Vector3(0.0, 0.5, -1.6), Vector3(1.0, 0.5, -1.4), Vector3(1.8, 0.5, -0.8), Vector3(1.9, 0.5, 0.3)]: _place("village/Prop_WoodenFence_Single.gltf", camp, point, Vector3(0.62, 0.55, 0.5), 0.0)
	_place("props/Stall_Cart_Empty.gltf", camp, Vector3(0.0, 0.0, 0.9), Vector3(0.7, 0.7, 0.7), PI)
	_place("props/Barrel.gltf", camp, Vector3(-1.2, 0.45, 0.9), Vector3(0.45, 0.45, 0.45), 0.1)
	_place("props/Barrel_Apples.gltf", camp, Vector3(1.1, 0.45, 0.7), Vector3(0.45, 0.45, 0.45), -0.2)
	_place("village/Prop_Crate.gltf", camp, Vector3(1.4, 0.35, 1.15), Vector3(0.45, 0.45, 0.45), 0.2)

func _build_nature() -> void:
	var placements := [["nature/CommonTree_1.gltf", Vector3(-13.4, 0.5, -8.5), Vector3(1.15, 1.15, 1.15)], ["nature/CommonTree_3.gltf", Vector3(-10.8, 0.4, 7.8), Vector3(1.0, 1.0, 1.0)], ["nature/Pine_2.gltf", Vector3(12.8, 0.45, -7.7), Vector3(1.0, 1.0, 1.0)], ["nature/Bush_Common.gltf", Vector3(-5.8, 0.35, -7.4), Vector3(0.85, 0.85, 0.85)], ["nature/Bush_Common_Flowers.gltf", Vector3(6.5, 0.35, 7.8), Vector3(0.82, 0.82, 0.82)], ["nature/Grass_Common_Tall.gltf", Vector3(-4.8, 0.35, 5.9), Vector3(0.8, 0.8, 0.8)], ["nature/Grass_Wispy_Short.gltf", Vector3(0.6, 0.2, 6.0), Vector3(0.7, 0.7, 0.7)], ["nature/Flower_3_Group.gltf", Vector3(-8.9, 0.22, -7.0), Vector3(0.7, 0.7, 0.7)]]
	for item in placements: _place(str(item[0]), world, item[1], item[2], randf_range(-0.7, 0.7))
	for item in [[Vector3(-14.5, 0.4, -4.6), "nature/Rock_Medium_1.gltf"], [Vector3(-7.2, 0.3, 7.0), "nature/Rock_Medium_2.gltf"], [Vector3(5.8, 0.3, -7.8), "nature/Rock_Medium_3.gltf"], [Vector3(6.2, 0.25, 7.0), "nature/Rock_Medium_1.gltf"]]: _place(str(item[1]), world, item[0], Vector3(0.55, 0.55, 0.55), randf_range(-0.7, 0.7))

func _build_characters() -> void:
	_place("men/Worker.gltf", world, Vector3(-7.0, 0.5, -1.4), Vector3(0.85, 0.85, 0.85), 0.15)
	_place("men/Farmer.gltf", world, Vector3(-5.5, 0.5, -2.2), Vector3(0.85, 0.85, 0.85), -0.1)
	_place("men/Adventurer.gltf", world, Vector3(8.0, 0.5, 4.3), Vector3(0.85, 0.85, 0.85), 2.4)
	_place("men/Adventurer.gltf", world, Vector3(9.8, 0.5, 5.8), Vector3(0.82, 0.82, 0.82), 2.6)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0370_Oblique_RTS_Camera"
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = 38.0
	camera.current = true
	camera.position = Vector3(18.0, 17.0, 21.0)
	add_child(camera)
	camera.look_at(Vector3(0.0, 0.5, 0.0), Vector3.UP)

func _place(relative_path: String, parent: Node3D, position: Vector3, scale: Vector3, yaw: float) -> Node3D:
	var packed := load(ASSET_ROOT + relative_path) as PackedScene
	if packed == null:
		push_error("v0.370 missing imported asset: " + relative_path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("v0.370 asset is not Node3D: " + relative_path)
		return null
	instance.name = relative_path.get_file().get_basename()
	instance.position = position
	instance.scale = scale
	instance.rotation.y = yaw
	parent.add_child(instance)
	return instance

func _mat(key: String, color: Color) -> StandardMaterial3D:
	if materials.has(key): return materials[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if key == "water":
		material.roughness = 0.32
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	materials[key] = material
	return material

func _add_polygon(label: String, points: Array, material: Material, parent: Node3D) -> MeshInstance3D:
	var vertices := PackedVector3Array([Vector3.ZERO])
	var indices := PackedInt32Array()
	var center := Vector3.ZERO
	for point in points: center += point
	center /= points.size()
	vertices[0] = center
	for point in points: vertices.append(point)
	for index in range(points.size()): indices.append_array([0, index + 1, ((index + 1) % points.size()) + 1])
	var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX); arrays[Mesh.ARRAY_VERTEX] = vertices; arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays); mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new(); instance.name = label; instance.mesh = mesh; parent.add_child(instance); return instance

func _add_ribbon(label: String, points: Array, width: float, material: Material, parent: Node3D, y_offset: float) -> MeshInstance3D:
	var vertices := PackedVector3Array(); var indices := PackedInt32Array()
	for index in range(points.size()):
		var current: Vector3 = points[index]
		var previous: Vector3 = points[max(0, index - 1)]
		var next: Vector3 = points[min(points.size() - 1, index + 1)]
		var direction := (next - previous).normalized(); var side := Vector3(-direction.z, 0.0, direction.x) * width * 0.5
		vertices.append(current - side + Vector3(0.0, y_offset, 0.0)); vertices.append(current + side + Vector3(0.0, y_offset, 0.0))
	for index in range(points.size() - 1):
		var base := index * 2; indices.append_array([base, base + 1, base + 3, base, base + 3, base + 2])
	var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX); arrays[Mesh.ARRAY_VERTEX] = vertices; arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays); mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new(); instance.name = label; instance.mesh = mesh; parent.add_child(instance); return instance

func _capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	await _capture_view("01_QUATERNIUS_WIDE.png", Vector3(18.0, 17.0, 21.0), Vector3(0.0, 0.5, 0.0), root)
	await _capture_view("02_QUATERNIUS_RTS_CAMERA.png", Vector3(17.0, 14.0, 19.0), Vector3(-0.5, 0.7, -0.5), root)
	await _capture_view("03_QUATERNIUS_CLOSE_DETAIL.png", Vector3(7.5, 8.0, 11.0), Vector3(-5.5, 1.0, -3.0), root)
	await _capture_view("04_QUATERNIUS_BRIDGE_CONTACT.png", Vector3(10.5, 7.5, 10.5), Vector3(3.0, 0.2, -1.8), root)
	await _capture_view("05_QUATERNIUS_HOSTILE_CAMP.png", Vector3(11.0, 7.5, 13.0), Vector3(8.8, 0.8, 5.1), root)
	get_tree().quit(0)

func _capture_view(file_name: String, position: Vector3, target: Vector3, root: String) -> void:
	camera.position = position; camera.look_at(target, Vector3.UP)
	await get_tree().process_frame; await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png(root.path_join(file_name))

func _smoke_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	get_tree().quit(0)
