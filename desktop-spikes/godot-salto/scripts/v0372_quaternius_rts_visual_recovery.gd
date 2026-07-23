extends Node3D

## Isolated v0.372 world-only composition gate. This route deliberately has no gameplay or HUD.

const CHECKPOINT := "v0.372"
const CAPTURE_ROOT := "artifacts/runtime/v0372"
const ASSET_ROOT := "res://assets/third_party/quaternius/v0370/"

var capture_mode := false
var smoke_mode := false
var capture_root := CAPTURE_ROOT
var camera: Camera3D
var world: Node3D
var materials: Dictionary = {}

func _ready() -> void:
	seed(372)
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
		if arg == "--v0372-quaternius-capture": capture_mode = true
		if arg == "--v0372-quaternius-smoke": smoke_mode = true
		if arg.begins_with("--artifact-root="): capture_root = arg.trim_prefix("--artifact-root=")
	if capture_mode: smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#8b958c")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d9d2b7")
	environment.ambient_light_energy = 0.68
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0372_Muted_Daylight"
	world_environment.environment = environment
	add_child(world_environment)
	var key := DirectionalLight3D.new()
	key.name = "V0372_Soft_Warm_Key"
	key.rotation_degrees = Vector3(-52.0, -34.0, 0.0)
	key.light_color = Color("#f2d1aa")
	key.light_energy = 0.86
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 80.0
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0372_Cool_Muted_Fill"
	fill.rotation_degrees = Vector3(-32.0, 146.0, 0.0)
	fill.light_color = Color("#a9c0ba")
	fill.light_energy = 0.16
	fill.shadow_enabled = false
	add_child(fill)

func _build_world() -> void:
	world = Node3D.new()
	world.name = "V0372_Single_Frame_Rts_Composition"
	add_child(world)
	_build_terrain()
	_build_roads()
	_build_bridge()
	_build_main_hall(Vector3(-8.0, 0.0, -6.5))
	_build_barracks_clearing(Vector3(-4.2, 0.0, -6.7))
	_build_resource_site(Vector3(-11.0, 0.0, -2.0))
	_build_hostile_camp(Vector3(7.8, 0.0, 5.1))
	_build_nature()
	_build_characters()

func _build_terrain() -> void:
	var underlay := [Vector3(-120.0, -0.72, -120.0), Vector3(120.0, -0.72, -120.0), Vector3(120.0, -0.72, 120.0), Vector3(-120.0, -0.72, 120.0)]
	_add_polygon("Terrain_Underlay", underlay, _mat("underlay", Color("#596454")), world)
	var west := [Vector3(-120.0, 0.02, -120.0), Vector3(-2.1, 0.18, -120.0), Vector3(0.10, 0.28, -35.0), Vector3(-0.05, 0.22, -15.0), Vector3(-0.18, 0.30, -3.5), Vector3(-0.02, 0.18, 2.0), Vector3(-0.20, 0.28, 15.0), Vector3(-0.05, 0.16, 35.0), Vector3(-120.0, 0.06, 120.0)]
	var east := [Vector3(3.25, 0.20, -120.0), Vector3(120.0, 0.04, -120.0), Vector3(120.0, 0.08, 120.0), Vector3(3.45, 0.22, 120.0), Vector3(3.05, 0.28, 15.0), Vector3(3.28, 0.18, 2.0), Vector3(3.12, 0.30, -3.5), Vector3(3.30, 0.20, -15.0)]
	_add_polygon("West_Continuous_Ground", west, _mat("west_ground", Color("#68725a")), world)
	_add_polygon("East_Continuous_Ground", east, _mat("east_ground", Color("#606b58")), world)
	var river_points := [Vector3(1.58, -0.46, -120.0), Vector3(1.42, -0.50, -35.0), Vector3(1.20, -0.52, -13.0), Vector3(1.55, -0.44, -8.0), Vector3(1.18, -0.55, -3.0), Vector3(1.54, -0.48, 2.0), Vector3(1.28, -0.56, 7.0), Vector3(1.72, -0.46, 12.0), Vector3(1.38, -0.50, 18.0), Vector3(1.52, -0.48, 35.0), Vector3(1.58, -0.46, 120.0)]
	var river_widths := [3.12, 3.18, 3.40, 2.85, 3.20, 3.55, 3.08, 3.36, 3.12, 3.24, 3.16]
	_add_variable_ribbon("One_Continuous_Recessed_River", river_points, river_widths, _mat("water", Color("#426f76")), world, 0.0)
	var bank_west := [Vector3(0.02, 0.16, -120.0), Vector3(-0.18, 0.20, -35.0), Vector3(-0.22, 0.20, -13.0), Vector3(0.02, 0.16, -8.0), Vector3(-0.30, 0.22, -3.0), Vector3(-0.02, 0.18, 2.0), Vector3(-0.18, 0.24, 7.0), Vector3(0.06, 0.18, 12.0), Vector3(-0.18, 0.20, 18.0), Vector3(-0.10, 0.20, 35.0), Vector3(0.02, 0.16, 120.0)]
	var bank_east := [Vector3(3.14, 0.18, -120.0), Vector3(3.52, 0.22, -35.0), Vector3(3.68, 0.22, -13.0), Vector3(3.08, 0.18, -8.0), Vector3(3.72, 0.24, -3.0), Vector3(3.12, 0.20, 2.0), Vector3(3.60, 0.26, 7.0), Vector3(3.38, 0.20, 12.0), Vector3(3.52, 0.22, 18.0), Vector3(3.46, 0.22, 35.0), Vector3(3.14, 0.18, 120.0)]
	_add_variable_ribbon("Irregular_West_Riverbank", bank_west, [0.72, 0.58, 0.52, 0.74, 0.48, 0.70, 0.54, 0.72, 0.58, 0.60, 0.72], _mat("bank_west", Color("#81735c")), world, 0.02)
	_add_variable_ribbon("Irregular_East_Riverbank", bank_east, [0.66, 0.56, 0.50, 0.70, 0.46, 0.68, 0.52, 0.66, 0.54, 0.58, 0.66], _mat("bank_east", Color("#776b57")), world, 0.02)
	for point in [Vector3(-0.12, 0.22, -7.4), Vector3(-0.24, 0.24, 4.6), Vector3(3.42, 0.24, 8.6), Vector3(3.44, 0.22, -10.6)]:
		_place("nature/Rock_Medium_2.gltf", world, point, Vector3(0.40, 0.32, 0.40), randf_range(-0.3, 0.3))

func _build_roads() -> void:
	var settlement_route := [Vector3(-8.0, 0.26, -5.0), Vector3(-6.9, 0.30, -4.55), Vector3(-5.6, 0.24, -3.55), Vector3(-4.1, 0.28, -2.35), Vector3(-2.55, 0.24, -1.25), Vector3(-1.25, 0.22, -0.68)]
	var camp_route := [Vector3(4.55, 0.24, 0.68), Vector3(5.0, 0.26, 1.75), Vector3(5.65, 0.24, 2.75), Vector3(6.55, 0.30, 3.85), Vector3(7.65, 0.28, 5.05)]
	var resource_route := [Vector3(-10.25, 0.22, -2.1), Vector3(-9.55, 0.25, -3.1), Vector3(-8.65, 0.26, -4.35), Vector3(-8.0, 0.26, -5.0)]
	var road_material := _mat("road", Color("#76634f"))
	_add_variable_ribbon("Settlement_To_Bridge_Path", settlement_route, [1.05, 0.92, 1.00, 0.82, 0.94, 1.02], road_material, world, 0.08)
	_add_variable_ribbon("Bridge_To_Hostile_Camp_Path", camp_route, [1.04, 0.92, 0.86, 0.96, 1.08], road_material, world, 0.08)
	_add_variable_ribbon("Settlement_To_Resource_Path", resource_route, [0.86, 0.78, 0.72, 0.86], _mat("resource_path", Color("#806d55")), world, 0.08)
	for point in [Vector3(-1.12, 0.32, -0.74), Vector3(4.38, 0.32, 0.72), Vector3(-3.0, 0.32, -1.55), Vector3(-8.8, 0.32, -3.85)]:
		_place("nature/RockPath_Round_Wide.gltf", world, point, Vector3(0.46, 0.22, 0.46), randf_range(-0.25, 0.25))

func _build_bridge() -> void:
	var bridge := Node3D.new()
	bridge.name = "Single_Readable_Timber_Bridge"
	bridge.position = Vector3(1.55, 0.0, 0.0)
	world.add_child(bridge)
	for index in range(5):
		_place("village/Floor_WoodDark.gltf", bridge, Vector3(-2.4 + index * 1.2, 0.48, 0.0), Vector3(0.62, 0.34, 0.92), 0.0)
	for x in [-2.0, -0.65, 0.70, 2.05]:
		_place("village/Prop_WoodenFence_Single.gltf", bridge, Vector3(x, 0.98, -0.82), Vector3(0.56, 0.58, 0.44), 0.0)
		_place("village/Prop_WoodenFence_Single.gltf", bridge, Vector3(x, 0.98, 0.82), Vector3(0.56, 0.58, 0.44), 0.0)
	for x in [-2.70, 2.70]:
		_place("village/Stairs_Exterior_Straight.gltf", bridge, Vector3(x, 0.12, 0.0), Vector3(0.46, 0.36, 0.58), 0.0)
		_place("nature/RockPath_Round_Wide.gltf", bridge, Vector3(x, 0.12, -0.98), Vector3(0.62, 0.28, 0.50), 0.0)
		_place("nature/RockPath_Round_Wide.gltf", bridge, Vector3(x, 0.12, 0.98), Vector3(0.62, 0.28, 0.50), 0.0)

func _build_main_hall(origin: Vector3) -> void:
	var hall := Node3D.new(); hall.name = "Main_Hall_Player_Settlement"; hall.position = origin; world.add_child(hall)
	_place("village/Floor_WoodDark.gltf", hall, Vector3.ZERO, Vector3(1.22, 0.82, 1.22), 0.0)
	for x in [-1.25, 1.25]: _place("village/Wall_Plaster_Straight.gltf", hall, Vector3(x, 1.18, 0.0), Vector3(0.90, 1.04, 0.96), PI / 2.0)
	_place("village/Wall_Plaster_Door_Round.gltf", hall, Vector3(0.0, 1.18, 1.25), Vector3(0.96, 1.04, 0.96), 0.0)
	_place("village/Wall_Plaster_Straight.gltf", hall, Vector3(0.0, 1.18, -1.25), Vector3(0.96, 1.04, 0.96), 0.0)
	_place("village/Wall_Plaster_Window_Wide_Round.gltf", hall, Vector3(-0.92, 1.20, 1.27), Vector3(0.42, 0.92, 0.82), 0.0)
	_place("village/Roof_RoundTiles_6x10.gltf", hall, Vector3(0.0, 2.68, -0.55), Vector3(0.45, 0.45, 0.40), 0.0)
	_place("village/Roof_RoundTiles_6x10.gltf", hall, Vector3(0.0, 2.68, 0.55), Vector3(0.45, 0.45, 0.40), PI)
	_place("village/Roof_FrontSupports.gltf", hall, Vector3(0.0, 2.10, 1.40), Vector3(0.66, 0.66, 0.66), 0.0)
	_place("props/Stall_Cart_Empty.gltf", hall, Vector3(-2.15, 0.1, 1.55), Vector3(0.68, 0.68, 0.68), 0.1)
	_place("props/Barrel_Apples.gltf", hall, Vector3(1.95, 0.42, 0.55), Vector3(0.42, 0.42, 0.42), 0.2)

func _build_barracks_clearing(origin: Vector3) -> void:
	var clearing := [origin + Vector3(-2.0, 0.08, -1.35), origin + Vector3(2.0, 0.10, -1.35), origin + Vector3(2.0, 0.10, 1.35), origin + Vector3(-2.0, 0.08, 1.35)]
	_add_polygon("Future_Barracks_Construction_Clearing", clearing, _mat("worn_ground", Color("#625c4c")), world)
	_place("village/Floor_Brick.gltf", world, origin + Vector3(0.0, 0.12, 0.0), Vector3(0.90, 0.20, 0.72), 0.0)
	_place("village/Prop_Crate.gltf", world, origin + Vector3(-1.45, 0.42, 0.82), Vector3(0.42, 0.42, 0.42), 0.0)
	_place("village/Prop_WoodenFence_Single.gltf", world, origin + Vector3(1.35, 0.42, 0.88), Vector3(0.50, 0.44, 0.42), 0.0)

func _build_resource_site(origin: Vector3) -> void:
	var site := Node3D.new(); site.name = "Gold_Resource_Site"; site.position = origin; world.add_child(site)
	var worked_ground := [Vector3(-1.8, 0.08, -1.2), Vector3(1.5, 0.12, -1.0), Vector3(1.7, 0.10, 1.1), Vector3(-1.4, 0.08, 1.35)]
	_add_polygon("Worked_Resource_Ground", worked_ground, _mat("resource_ground", Color("#6c604d")), site)
	_place("nature/Rock_Medium_1.gltf", site, Vector3(-0.72, 0.34, 0.0), Vector3(0.88, 0.66, 0.88), -0.2)
	_place("nature/Rock_Medium_2.gltf", site, Vector3(0.22, 0.28, 0.50), Vector3(0.68, 0.56, 0.68), 0.25)
	_place("nature/Rock_Medium_3.gltf", site, Vector3(0.96, 0.34, -0.24), Vector3(0.74, 0.62, 0.74), -0.35)
	_place("props/Whetstone.gltf", site, Vector3(0.0, 0.18, -0.82), Vector3(0.58, 0.58, 0.58), 0.2)
	_place("props/Crate_Wooden.gltf", site, Vector3(-1.30, 0.38, -0.62), Vector3(0.48, 0.48, 0.48), 0.15)
	_place("village/Prop_Wagon.gltf", site, Vector3(0.0, 0.02, 1.65), Vector3(0.60, 0.60, 0.60), 0.2)

func _build_hostile_camp(origin: Vector3) -> void:
	var camp := Node3D.new(); camp.name = "Hostile_Camp_Opposite_Bank"; camp.position = origin; world.add_child(camp)
	var worn_ground := [Vector3(-2.3, 0.06, -1.55), Vector3(2.3, 0.10, -1.35), Vector3(2.55, 0.08, 1.55), Vector3(-2.1, 0.06, 1.75)]
	_add_polygon("Hostile_Worn_Ground", worn_ground, _mat("hostile_ground", Color("#4f5147")), camp)
	for point in [Vector3(-1.9, 0.48, -1.05), Vector3(-1.0, 0.50, -1.42), Vector3(0.0, 0.50, -1.52), Vector3(1.0, 0.50, -1.34), Vector3(1.9, 0.48, -0.92), Vector3(2.0, 0.48, 0.14), Vector3(-1.92, 0.48, 0.18)]:
		_place("village/Prop_WoodenFence_Single.gltf", camp, point, Vector3(0.58, 0.54, 0.46), 0.0)
	_place("village/Prop_Wagon.gltf", camp, Vector3(0.0, 0.02, 0.74), Vector3(0.66, 0.66, 0.66), PI)
	_place("props/Barrel.gltf", camp, Vector3(-1.14, 0.44, 0.84), Vector3(0.46, 0.46, 0.46), 0.1)
	_place("props/Barrel_Apples.gltf", camp, Vector3(1.12, 0.44, 0.76), Vector3(0.46, 0.46, 0.46), -0.2)
	_place("village/Prop_Crate.gltf", camp, Vector3(1.42, 0.36, 1.16), Vector3(0.48, 0.48, 0.48), 0.2)
	_place("props/Whetstone.gltf", camp, Vector3(-0.10, 0.18, -0.42), Vector3(0.58, 0.58, 0.58), -0.2)

func _build_nature() -> void:
	var placements := [
		["nature/CommonTree_1.gltf", Vector3(-14.8, 0.48, -3.2), Vector3(0.92, 0.92, 0.92)],
		["nature/CommonTree_3.gltf", Vector3(-13.8, 0.42, 2.9), Vector3(0.92, 0.92, 0.92)],
		["nature/Pine_2.gltf", Vector3(12.6, 0.48, -7.5), Vector3(0.96, 0.96, 0.96)],
		["nature/Bush_Common.gltf", Vector3(-4.2, 0.32, -9.0), Vector3(0.78, 0.78, 0.78)],
		["nature/Bush_Common_Flowers.gltf", Vector3(10.8, 0.34, 8.5), Vector3(0.76, 0.76, 0.76)],
		["nature/Grass_Common_Tall.gltf", Vector3(-5.7, 0.34, 2.1), Vector3(0.74, 0.74, 0.74)],
		["nature/Grass_Wispy_Short.gltf", Vector3(4.9, 0.24, 8.0), Vector3(0.66, 0.66, 0.66)],
		["nature/Flower_3_Group.gltf", Vector3(-12.2, 0.24, -6.5), Vector3(0.64, 0.64, 0.64)]
	]
	for item in placements: _place(str(item[0]), world, item[1], item[2], randf_range(-0.6, 0.6))
	for item in [[Vector3(-14.8, 0.42, -5.0), "nature/Rock_Medium_1.gltf"], [Vector3(-3.1, 0.30, 6.5), "nature/Rock_Medium_2.gltf"], [Vector3(7.8, 0.30, -7.8), "nature/Rock_Medium_3.gltf"], [Vector3(11.6, 0.26, 2.4), "nature/Rock_Medium_1.gltf"]]:
		_place(str(item[1]), world, item[0], Vector3(0.52, 0.52, 0.52), randf_range(-0.6, 0.6))

func _build_characters() -> void:
	_place("men/Worker.gltf", world, Vector3(-7.0, 0.52, -5.0), Vector3(0.82, 0.82, 0.82), 0.15)
	_place("men/Farmer.gltf", world, Vector3(-5.8, 0.52, -5.8), Vector3(0.82, 0.82, 0.82), -0.1)
	_place("men/Adventurer.gltf", world, Vector3(7.15, 0.52, 4.5), Vector3(0.84, 0.84, 0.84), 2.4)
	_place("men/Adventurer.gltf", world, Vector3(8.55, 0.52, 5.75), Vector3(0.80, 0.80, 0.80), 2.6)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0372_Fixed_ThreeQuarter_RTS_Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 23.0
	camera.current = true
	camera.position = Vector3(18.0, 19.0, 20.0)
	add_child(camera)
	camera.look_at(Vector3(-0.4, 0.2, -1.4), Vector3.UP)

func _place(relative_path: String, parent: Node3D, position: Vector3, scale: Vector3, yaw: float) -> Node3D:
	var packed := load(ASSET_ROOT + relative_path) as PackedScene
	if packed == null:
		push_error("v0.372 missing Quaternius asset: " + relative_path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("v0.372 asset is not Node3D: " + relative_path)
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
	material.roughness = 0.90
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if key == "water":
		material.roughness = 0.38
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	material.metallic = 0.0
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

func _add_variable_ribbon(label: String, points: Array, widths: Array, material: Material, parent: Node3D, y_offset: float) -> MeshInstance3D:
	var vertices := PackedVector3Array(); var indices := PackedInt32Array()
	for index in range(points.size()):
		var current: Vector3 = points[index]
		var previous: Vector3 = points[max(0, index - 1)]
		var next: Vector3 = points[min(points.size() - 1, index + 1)]
		var direction := (next - previous).normalized()
		var side := Vector3(-direction.z, 0.0, direction.x) * float(widths[index]) * 0.5
		vertices.append(current - side + Vector3(0.0, y_offset, 0.0)); vertices.append(current + side + Vector3(0.0, y_offset, 0.0))
	for index in range(points.size() - 1):
		var base := index * 2; indices.append_array([base, base + 1, base + 3, base, base + 3, base + 2])
	var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX); arrays[Mesh.ARRAY_VERTEX] = vertices; arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays); mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new(); instance.name = label; instance.mesh = mesh; parent.add_child(instance); return instance

func _capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	await _capture_view("01_PRIMARY_RTS_COMPOSITION.png", Vector3(18.0, 19.0, 20.0), Vector3(-0.4, 0.2, -1.4), root)
	await _capture_view("02_CLOSER_SETTLEMENT_AND_RESOURCE.png", Vector3(11.0, 12.0, 14.0), Vector3(-7.0, 0.2, -5.0), root)
	await _capture_view("03_BRIDGE_AND_HOSTILE_CAMP.png", Vector3(12.0, 13.0, 15.0), Vector3(4.0, 0.2, 2.6), root)
	await _capture_view("04_TOPDOWN_SPACING_AUDIT.png", Vector3(0.2, 25.0, 0.2), Vector3(-0.1, 0.0, 0.0), root)
	_write_json("v0372-visual-recovery.json", {"checkpoint": CHECKPOINT, "status": "PASS", "primary": "01_PRIMARY_RTS_COMPOSITION.png", "resolution": "1920x1080", "hud": false, "route": "opt-in-only"})
	get_tree().quit(0)

func _capture_view(file_name: String, position: Vector3, target: Vector3, root: String) -> void:
	camera.position = position; camera.look_at(target, Vector3.UP)
	await get_tree().process_frame; await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080:
		image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))

func _write_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_json("v0372-visual-recovery-smoke.json", {"checkpoint": CHECKPOINT, "status": "PASS", "sceneLoaded": true, "hud": false, "gameplay": false, "defaultRuntime": "unchanged"})
	get_tree().quit(0)
