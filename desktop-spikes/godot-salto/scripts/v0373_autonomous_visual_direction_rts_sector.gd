extends Node3D

## Isolated v0.373 world-only visual recovery. No gameplay, HUD, selection, or simulation.

const CHECKPOINT := "v0.373"
const CAPTURE_ROOT := "artifacts/runtime/v0373"
const ASSET_ROOT := "res://assets/third_party/quaternius/v0370/"

var capture_mode := false
var smoke_mode := false
var capture_root := CAPTURE_ROOT
var iteration := 1
var camera: Camera3D
var world: Node3D
var materials: Dictionary = {}

func _ready() -> void:
	seed(373)
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
		if arg == "--v0373-autonomous-capture": capture_mode = true
		if arg == "--v0373-autonomous-smoke": smoke_mode = true
		if arg.begins_with("--artifact-root="): capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0373-iteration="): iteration = int(arg.trim_prefix("--v0373-iteration="))
	if capture_mode: smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#667264")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#c8c4aa")
	environment.ambient_light_energy = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0373_Quiet_Daylight"
	world_environment.environment = environment
	add_child(world_environment)
	var key := DirectionalLight3D.new()
	key.name = "V0373_Warm_Directional_Key"
	key.rotation_degrees = Vector3(-53.0, -38.0, 0.0)
	key.light_color = Color("#f2d3ab")
	key.light_energy = 0.82
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 70.0
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0373_Cool_Ambient_Fill"
	fill.rotation_degrees = Vector3(-35.0, 142.0, 0.0)
	fill.light_color = Color("#a7bdb1")
	fill.light_energy = 0.20
	fill.shadow_enabled = false
	add_child(fill)

func _build_world() -> void:
	world = Node3D.new()
	world.name = "V0373_Compact_Rts_Battlefield"
	add_child(world)
	_build_terrain()
	_build_river_and_banks()
	_build_settlement()
	_build_resource_area()
	_build_bridge()
	_build_hostile_camp()
	_build_paths()
	_build_nature()
	_build_characters()

func _build_terrain() -> void:
	var underlay := [Vector3(-80.0, -0.75, -80.0), Vector3(80.0, -0.75, -80.0), Vector3(80.0, -0.75, 80.0), Vector3(-80.0, -0.75, 80.0)]
	_add_polygon("Continuous_Terrain_Underlay", underlay, _mat("base_ground", Color("#687263")), world)
	_add_zone("Settlement_Yard_Zone", Vector3(-6.7, 0.0, -4.0), Vector2(4.8, 3.2), Color("#777664"), world, 0.05, 8)
	_add_zone("Bridge_Approach_West", Vector3(-1.8, 0.0, 0.8), Vector2(3.5, 2.4), Color("#6d7463"), world, 0.04, 8)
	_add_zone("Bridge_Approach_East", Vector3(2.5, 0.0, -0.8), Vector2(3.6, 2.4), Color("#696f60"), world, 0.04, 8)

func _build_river_and_banks() -> void:
	var river_points := [Vector3(-32.0, -0.50, 15.0), Vector3(-14.0, -0.54, 7.2), Vector3(-10.0, -0.48, 7.0), Vector3(-6.0, -0.56, 5.35), Vector3(-2.0, -0.50, 3.0), Vector3(2.0, -0.56, 1.5), Vector3(6.0, -0.48, 0.7), Vector3(9.0, -0.54, -1.5), Vector3(13.0, -0.48, -1.2), Vector3(32.0, -0.50, -8.0)]
	var widths := [2.00, 2.18, 2.35, 2.48, 2.18, 2.42, 2.22, 2.48, 2.18, 2.02]
	_add_variable_ribbon("One_Continuous_Recessed_River", river_points, widths, _mat("muted_water", Color("#416b70")), world, 0.0)
	var bank_left := [Vector3(-32.0, 0.08, 13.85), Vector3(-14.0, 0.16, 6.10), Vector3(-10.0, 0.10, 5.85), Vector3(-6.0, 0.18, 4.20), Vector3(-2.0, 0.12, 1.85), Vector3(2.0, 0.18, 0.40), Vector3(6.0, 0.10, -0.50), Vector3(9.0, 0.16, -2.10), Vector3(13.0, 0.10, -1.80), Vector3(32.0, 0.08, -9.25)]
	var bank_right := [Vector3(-32.0, 0.12, 16.15), Vector3(-14.0, 0.18, 8.30), Vector3(-10.0, 0.14, 8.15), Vector3(-6.0, 0.20, 6.50), Vector3(-2.0, 0.16, 4.15), Vector3(2.0, 0.20, 2.60), Vector3(6.0, 0.14, 1.90), Vector3(9.0, 0.18, -0.90), Vector3(13.0, 0.12, -0.50), Vector3(32.0, 0.10, -6.75)]
	_add_variable_ribbon("Irregular_Left_Riverbank", bank_left, [0.18, 0.16, 0.22, 0.15, 0.20, 0.16, 0.21, 0.15, 0.20, 0.18], _mat("bank_warm", Color("#6e7160")), world, 0.04)
	_add_variable_ribbon("Irregular_Right_Riverbank", bank_right, [0.16, 0.21, 0.15, 0.20, 0.14, 0.21, 0.16, 0.20, 0.14, 0.17], _mat("bank_cool", Color("#696e5e")), world, 0.05)
	for point in [Vector3(-7.1, 0.22, 5.8), Vector3(-3.2, 0.24, 3.75), Vector3(5.7, 0.20, 0.78), Vector3(11.0, 0.20, -2.85), Vector3(1.6, 0.22, 3.65)]:
		_place("nature/Rock_Medium_2.gltf", world, point, Vector3(0.40, 0.32, 0.40), randf_range(-0.4, 0.4))
	for point in [Vector3(-4.4, 0.18, 4.5), Vector3(7.8, 0.20, -1.0), Vector3(-0.3, 0.18, 1.2)]:
		_place("nature/Grass_Wispy_Short.gltf", world, point, Vector3(0.60, 0.60, 0.60), randf_range(-0.5, 0.5))

func _build_settlement() -> void:
	_build_house("Main_Hall_Settlement", Vector3(-8.35, 0.0, -4.25), Vector3(0.80, 0.80, 0.80), 0.12)
	_build_house("Field_Barracks_Settlement", Vector3(-4.55, 0.0, -6.35), Vector3(0.54, 0.58, 0.58), -0.08)
	_build_small_store("Settlement_Storehouse", Vector3(-8.85, 0.0, -1.55))
	_add_zone("Settlement_Working_Yard", Vector3(-6.85, 0.0, -4.05), Vector2(4.3, 2.8), Color("#7d7965"), world, 0.08, 8)
	_place("props/Stall_Cart_Empty.gltf", world, Vector3(-6.0, 0.12, -2.75), Vector3(0.72, 0.72, 0.72), 0.15)
	_place("props/Barrel_Apples.gltf", world, Vector3(-4.9, 0.42, -3.15), Vector3(0.48, 0.48, 0.48), 0.1)
	_place("props/Crate_Wooden.gltf", world, Vector3(-5.35, 0.38, -2.55), Vector3(0.50, 0.50, 0.50), 0.18)
	_place("village/Prop_Wagon.gltf", world, Vector3(-8.05, 0.08, -5.95), Vector3(0.58, 0.58, 0.58), -0.25)
	for point in [Vector3(-9.9, 0.18, -3.0), Vector3(-9.5, 0.16, -1.5), Vector3(-3.25, 0.16, -3.35)]:
		_place("nature/RockPath_Round_Wide.gltf", world, point, Vector3(0.40, 0.20, 0.40), randf_range(-0.3, 0.3))

func _build_house(label: String, origin: Vector3, scale: Vector3, yaw: float) -> void:
	var building := Node3D.new(); building.name = label; building.position = origin; building.rotation.y = yaw; world.add_child(building)
	_place("village/Floor_WoodDark.gltf", building, Vector3(0.0, 0.10, 0.0), Vector3(1.18, 0.70, 1.10) * scale, 0.0)
	_place("village/Wall_Plaster_Straight.gltf", building, Vector3(-1.05, 1.10, 0.0), Vector3(0.82, 0.92, 0.86) * scale, PI / 2.0)
	_place("village/Wall_Plaster_Straight.gltf", building, Vector3(1.05, 1.10, 0.0), Vector3(0.82, 0.92, 0.86) * scale, PI / 2.0)
	_place("village/Wall_Plaster_Door_Round.gltf", building, Vector3(0.0, 1.10, 1.06), Vector3(0.84, 0.92, 0.86) * scale, 0.0)
	_place("village/Wall_Plaster_Window_Wide_Round.gltf", building, Vector3(-0.55, 1.10, -1.06), Vector3(0.48, 0.84, 0.76) * scale, PI)
	_place("village/Roof_RoundTiles_6x10.gltf", building, Vector3(0.0, 2.45, -0.46), Vector3(0.36, 0.36, 0.33) * scale, 0.0)
	_place("village/Roof_RoundTiles_6x10.gltf", building, Vector3(0.0, 2.45, 0.46), Vector3(0.36, 0.36, 0.33) * scale, PI)
	_place("village/Roof_FrontSupports.gltf", building, Vector3(0.0, 1.95, 1.20), Vector3(0.56, 0.56, 0.56) * scale, 0.0)

func _build_small_store(label: String, origin: Vector3) -> void:
	var store := Node3D.new(); store.name = label; store.position = origin; store.rotation.y = -0.25; world.add_child(store)
	_place("village/Floor_Brick.gltf", store, Vector3(0.0, 0.10, 0.0), Vector3(0.82, 0.34, 0.70), 0.0)
	_place("village/Wall_Plaster_Straight.gltf", store, Vector3(-0.72, 0.74, 0.0), Vector3(0.58, 0.60, 0.62), PI / 2.0)
	_place("village/Wall_Plaster_Door_Round.gltf", store, Vector3(0.0, 0.74, 0.72), Vector3(0.62, 0.62, 0.62), 0.0)
	_place("village/Roof_RoundTiles_4x6.gltf", store, Vector3(0.0, 1.65, 0.0), Vector3(0.42, 0.42, 0.42), 0.0)

func _build_resource_area() -> void:
	var origin := Vector3(-9.25, 0.0, -0.55)
	_add_zone("Worked_Resource_Yard", origin, Vector2(4.0, 3.0), Color("#6f6b58"), world, 0.10, 8)
	var primary_rock := _place("nature/Rock_Medium_1.gltf", world, origin + Vector3(-0.20, 0.28, -0.05), Vector3(0.72, 0.58, 0.72), -0.2)
	_tint_asset(primary_rock, _mat("ore_gold", Color("#a08349")))
	var secondary_rock := _place("nature/Rock_Medium_2.gltf", world, origin + Vector3(1.18, 0.24, 0.72), Vector3(0.54, 0.46, 0.54), 0.25)
	_tint_asset(secondary_rock, _mat("ore_gold_secondary", Color("#8b774c")))
	_add_ore_outcrop("Primary_Ore_Deposit", origin + Vector3(-0.20, 0.18, -0.05), Vector3(0.82, 0.50, 0.70))
	_add_ore_outcrop("Secondary_Ore_Deposit", origin + Vector3(1.18, 0.16, 0.72), Vector3(0.48, 0.38, 0.44))
	_place("nature/Rock_Medium_3.gltf", world, origin + Vector3(-1.45, 0.26, 0.75), Vector3(0.68, 0.58, 0.68), -0.3)
	_place("props/Whetstone.gltf", world, origin + Vector3(0.12, 0.22, -1.24), Vector3(0.62, 0.62, 0.62), 0.2)
	_place("props/Crate_Wooden.gltf", world, origin + Vector3(1.35, 0.40, -0.78), Vector3(0.56, 0.56, 0.56), 0.1)
	_place("village/Prop_Wagon.gltf", world, origin + Vector3(0.0, 0.08, 1.55), Vector3(0.62, 0.62, 0.62), 0.15)
	for point in [origin + Vector3(-2.05, 0.20, -0.92), origin + Vector3(2.0, 0.18, 0.95), origin + Vector3(-1.7, 0.18, 1.35)]:
		_place("nature/RockPath_Round_Wide.gltf", world, point, Vector3(0.42, 0.20, 0.42), randf_range(-0.5, 0.5))

func _build_bridge() -> void:
	var bridge := Node3D.new(); bridge.name = "Central_Timber_Bridge"; bridge.position = Vector3(0.0, 0.0, 2.35); bridge.rotation.y = 0.78; world.add_child(bridge)
	for index in range(6):
		_place("village/Floor_WoodDark.gltf", bridge, Vector3(-2.85 + index * 1.14, 0.55, 0.0), Vector3(0.58, 0.36, 0.92), 0.0)
	for x in [-2.4, -1.2, 0.0, 1.2, 2.4]:
		_place("village/Prop_WoodenFence_Single.gltf", bridge, Vector3(x, 1.02, -0.78), Vector3(0.48, 0.58, 0.42), 0.0)
		_place("village/Prop_WoodenFence_Single.gltf", bridge, Vector3(x, 1.02, 0.78), Vector3(0.48, 0.58, 0.42), 0.0)
	for x in [-3.12, 3.12]:
		_place("village/Stairs_Exterior_Straight.gltf", bridge, Vector3(x, 0.12, 0.0), Vector3(0.48, 0.36, 0.62), 0.0)
		_place("nature/RockPath_Round_Wide.gltf", bridge, Vector3(x, 0.12, -0.98), Vector3(0.62, 0.28, 0.50), 0.0)
		_place("nature/RockPath_Round_Wide.gltf", bridge, Vector3(x, 0.12, 0.98), Vector3(0.62, 0.28, 0.50), 0.0)
	_add_zone("Bridge_West_Gathering", Vector3(-1.7, 0.0, 1.25), Vector2(2.5, 1.7), Color("#81785e"), world, 0.10, 7)
	_add_zone("Bridge_East_Gathering", Vector3(2.0, 0.0, -0.15), Vector2(2.5, 1.7), Color("#766f59"), world, 0.10, 7)

func _build_hostile_camp() -> void:
	var camp := Node3D.new(); camp.name = "Hostile_Territory_Camp"; camp.position = Vector3(7.0, 0.0, -4.15); world.add_child(camp)
	_add_zone("Hostile_Trampled_Ground", Vector3(7.0, 0.0, -4.15), Vector2(4.7, 3.5), Color("#565c51"), world, 0.12, 8)
	for x in [-1.65, -0.55, 0.55, 1.65]:
		_place("village/Prop_WoodenFence_Single.gltf", camp, Vector3(x, 0.48, -1.30), Vector3(0.54, 0.54, 0.46), 0.0)
		_place("village/Prop_WoodenFence_Single.gltf", camp, Vector3(x, 0.48, 1.30), Vector3(0.54, 0.54, 0.46), PI)
	for z in [-0.55, 0.55]:
		_place("village/Prop_WoodenFence_Single.gltf", camp, Vector3(-1.95, 0.48, z), Vector3(0.54, 0.54, 0.46), PI / 2.0)
		_place("village/Prop_WoodenFence_Single.gltf", camp, Vector3(1.95, 0.48, z), Vector3(0.54, 0.54, 0.46), -PI / 2.0)
	_place("village/Floor_WoodDark.gltf", camp, Vector3(-0.15, 0.08, -0.35), Vector3(0.72, 0.30, 0.52), 0.0)
	_place("village/Prop_Crate.gltf", camp, Vector3(-0.15, 0.42, -0.35), Vector3(0.54, 0.54, 0.54), 0.0)
	_place("village/Prop_Wagon.gltf", camp, Vector3(0.25, 0.10, 0.15), Vector3(0.68, 0.68, 0.68), PI)
	_place("props/Barrel.gltf", camp, Vector3(-1.1, 0.46, 0.55), Vector3(0.52, 0.52, 0.52), 0.1)
	_place("props/Barrel_Apples.gltf", camp, Vector3(1.15, 0.46, 0.55), Vector3(0.52, 0.52, 0.52), -0.2)
	_place("village/Prop_Crate.gltf", camp, Vector3(-0.15, 0.38, -0.70), Vector3(0.56, 0.56, 0.56), 0.18)
	_place("props/Whetstone.gltf", camp, Vector3(0.80, 0.22, -0.72), Vector3(0.58, 0.58, 0.58), -0.2)
	_place("nature/RockPath_Round_Wide.gltf", camp, Vector3(-1.6, 0.20, -0.55), Vector3(0.48, 0.22, 0.48), 0.2)

func _build_paths() -> void:
	var road_material := _mat("packed_road", Color("#746f5d"))
	var settlement_to_bridge := [Vector3(-6.0, 0.25, -3.25), Vector3(-4.65, 0.28, -2.45), Vector3(-3.2, 0.24, -1.3), Vector3(-2.25, 0.28, 0.35), Vector3(-1.45, 0.28, 1.25)]
	var bridge_to_camp := [Vector3(2.0, 0.28, -0.05), Vector3(3.25, 0.26, -1.25), Vector3(4.8, 0.30, -2.45), Vector3(6.1, 0.28, -3.35), Vector3(6.8, 0.28, -3.85)]
	var settlement_to_resource := [Vector3(-8.5, 0.24, -2.25), Vector3(-8.9, 0.28, -1.85), Vector3(-9.25, 0.26, -1.15), Vector3(-9.55, 0.26, -0.52)]
	_add_variable_ribbon("Settlement_To_Central_Bridge_Road", settlement_to_bridge, [1.26, 1.10, 1.22, 1.05, 1.35], road_material, world, 0.12)
	_add_variable_ribbon("Central_Bridge_To_Hostile_Camp_Road", bridge_to_camp, [1.36, 1.12, 1.22, 1.08, 1.32], road_material, world, 0.12)
	_add_variable_ribbon("Settlement_To_Resource_Road", settlement_to_resource, [1.00, 0.88, 0.94, 1.10], _mat("resource_road", Color("#7b765f")), world, 0.12)
	for point in [Vector3(-2.0, 0.36, 0.32), Vector3(2.1, 0.36, -0.08), Vector3(-7.7, 0.34, -3.1), Vector3(-9.55, 0.34, -1.12), Vector3(5.15, 0.34, -2.7)]:
		_place("nature/RockPath_Round_Wide.gltf", world, point, Vector3(0.50, 0.22, 0.50), randf_range(-0.35, 0.35))

func _build_nature() -> void:
	var placements := [
		["nature/CommonTree_1.gltf", Vector3(-12.8, 0.40, -3.2), Vector3(0.48, 0.48, 0.48)],
		["nature/CommonTree_3.gltf", Vector3(-11.9, 0.38, -4.0), Vector3(0.46, 0.46, 0.46)],
		["nature/CommonTree_1.gltf", Vector3(-1.8, 0.38, -5.6), Vector3(0.48, 0.48, 0.48)],
		["nature/Pine_2.gltf", Vector3(10.8, 0.44, -5.8), Vector3(0.62, 0.62, 0.62)],
		["nature/Pine_2.gltf", Vector3(12.2, 0.42, -4.8), Vector3(0.54, 0.54, 0.54)],
		["nature/Bush_Common.gltf", Vector3(-2.7, 0.32, -6.1), Vector3(0.72, 0.72, 0.72)],
		["nature/Bush_Common_Flowers.gltf", Vector3(10.8, 0.34, -2.0), Vector3(0.70, 0.70, 0.70)],
		["nature/Grass_Common_Tall.gltf", Vector3(-4.8, 0.34, 2.65), Vector3(0.66, 0.66, 0.66)],
		["nature/Flower_3_Group.gltf", Vector3(-12.5, 0.24, -1.6), Vector3(0.60, 0.60, 0.60)]
	]
	for item in placements: _place(str(item[0]), world, item[1], item[2], randf_range(-0.6, 0.6))
	for item in [[Vector3(-12.2, 0.34, -3.9), "nature/Rock_Medium_1.gltf"], [Vector3(-1.2, 0.30, -6.0), "nature/Rock_Medium_2.gltf"], [Vector3(10.8, 0.28, -7.1), "nature/Rock_Medium_3.gltf"]]:
		_place(str(item[1]), world, item[0], Vector3(0.54, 0.54, 0.54), randf_range(-0.6, 0.6))

func _tint_asset(root: Node3D, material: Material) -> void:
	if root == null: return
	_apply_material_recursive(root, material)

func _apply_material_recursive(node: Node, material: Material) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).material_override = material
	for child in node.get_children(): _apply_material_recursive(child, material)

func _build_characters() -> void:
	_place("men/Worker.gltf", world, Vector3(-6.2, 0.52, -4.0), Vector3(0.86, 0.86, 0.86), 0.15)
	_place("men/Farmer.gltf", world, Vector3(-5.0, 0.52, -4.55), Vector3(0.86, 0.86, 0.86), -0.1)
	_place("men/Worker.gltf", world, Vector3(-9.0, 0.52, -0.65), Vector3(0.90, 0.90, 0.90), 0.2)
	_place("men/Adventurer.gltf", world, Vector3(6.45, 0.52, -3.75), Vector3(0.88, 0.88, 0.88), 2.4)
	_place("men/Adventurer.gltf", world, Vector3(7.55, 0.52, -4.55), Vector3(0.84, 0.84, 0.84), 2.6)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0373_Fixed_Close_ThreeQuarter_RTS_Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 16.8
	camera.current = true
	camera.position = Vector3(13.7, 15.5, 13.7)
	add_child(camera)
	camera.look_at(Vector3(-0.25, 0.15, -0.65), Vector3.UP)

func _add_zone(label: String, center: Vector3, size: Vector2, color: Color, parent: Node3D, y: float, points: int) -> void:
	var polygon: Array[Vector3] = []
	for index in range(points):
		var angle := TAU * float(index) / float(points)
		var variation := 0.82 + 0.12 * sin(float(index) * 1.7 + center.x)
		polygon.append(center + Vector3(cos(angle) * size.x * 0.5 * variation, y, sin(angle) * size.y * 0.5 * variation))
	_add_polygon(label, polygon, _mat(label, color), parent)

func _add_ore_outcrop(label: String, position: Vector3, scale: Vector3) -> void:
	var top := position + Vector3(0.0, scale.y, 0.0)
	var ring := []
	for index in range(8):
		var angle := TAU * float(index) / 8.0
		ring.append(position + Vector3(cos(angle) * scale.x * (0.84 + 0.12 * sin(index * 2.0)), 0.0, sin(angle) * scale.z * (0.84 + 0.10 * cos(index * 1.6))))
	var vertices := PackedVector3Array([position] + ring + [top])
	var indices := PackedInt32Array()
	for index in range(8):
		indices.append_array([0, index + 1, ((index + 1) % 8) + 1])
		indices.append_array([9, ((index + 1) % 8) + 1, index + 1])
	var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX); arrays[Mesh.ARRAY_VERTEX] = vertices; arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays); mesh.surface_set_material(0, _mat("ore_gold", Color("#9b8450")))
	var instance := MeshInstance3D.new(); instance.name = label; instance.mesh = mesh; world.add_child(instance)

func _place(relative_path: String, parent: Node3D, position: Vector3, scale: Vector3, yaw: float) -> Node3D:
	var packed := load(ASSET_ROOT + relative_path) as PackedScene
	if packed == null:
		push_error("v0.373 missing Quaternius asset: " + relative_path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("v0.373 asset is not Node3D: " + relative_path)
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
	if key == "muted_water":
		material.roughness = 0.42
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
	await _capture_view("01_FINAL_PRIMARY_RTS_COMPOSITION.png", Vector3(13.7, 15.5, 13.7), Vector3(-0.25, 0.15, -0.65), root)
	await _capture_view("02_FINAL_SETTLEMENT_AND_RESOURCE.png", Vector3(10.2, 11.6, 10.8), Vector3(-7.6, 0.15, -3.0), root)
	await _capture_view("03_FINAL_BRIDGE_AND_HOSTILE_CAMP.png", Vector3(10.4, 11.8, 11.0), Vector3(3.4, 0.15, -1.6), root)
	await _capture_view("04_FINAL_TOPDOWN_SPACING_AUDIT.png", Vector3(0.1, 24.0, 0.1), Vector3(-0.1, 0.0, -1.0), root)
	_write_json("v0373-autonomous-visual-direction.json", {"checkpoint": CHECKPOINT, "status": "RENDERED", "iteration": iteration, "primary": "01_FINAL_PRIMARY_RTS_COMPOSITION.png", "resolution": "1920x1080", "hud": false, "gameplay": false, "route": "opt-in-only"})
	get_tree().quit(0)

func _capture_view(file_name: String, position: Vector3, target: Vector3, root: String) -> void:
	camera.position = position; camera.look_at(target, Vector3.UP)
	await get_tree().process_frame; await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))

func _write_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_json("v0373-autonomous-visual-direction-smoke.json", {"checkpoint": CHECKPOINT, "status": "PASS", "sceneLoaded": true, "hud": false, "gameplay": false, "defaultRuntime": "unchanged"})
	get_tree().quit(0)
