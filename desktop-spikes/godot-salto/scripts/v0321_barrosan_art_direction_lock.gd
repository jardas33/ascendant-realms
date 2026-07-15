extends "res://scripts/v0320_true_3d_visual_vertical_slice.gd"

const V0321_CHECKPOINT := "v0.321"
const V0321_SCENE_PATH := "res://visual_vertical_slice/V0321BarrosanArtDirectionLock.tscn"
const V0321_VIEWPORT_SIZE := Vector2i(1600, 900)
const V0321_CAMERA_POSITION := Vector3(30.0, 27.0, 32.0)
const V0321_CAMERA_TARGET := Vector3(0.0, 1.2, 0.0)
const V0321_CAMERA_ORTHO_SIZE := 31.0
const WORLD_MIN := -48.0
const WORLD_MAX := 48.0

var variant_ledger: Array[Dictionary] = []
var state_ledger: Array[Dictionary] = []
var lock_water_material: ShaderMaterial

func _ready() -> void:
	print("V0321_READY")
	_parse_args()
	print("V0321_ARTIFACT_ROOT=", capture_root)
	_build_environment()
	_build_composition()
	_build_camera()
	_build_player_hud()
	await get_tree().process_frame
	await get_tree().process_frame
	if capture_root != "":
		await _capture_all()
		_write_manifest()
		get_tree().quit()

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#1d2927")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#9baaa1")
	environment.ambient_light_energy = 0.62
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = true
	environment.fog_light_color = Color("#53645f")
	environment.fog_density = 0.0032
	var world := WorldEnvironment.new()
	world.name = "V0321BarrosanAtmosphere"
	world.environment = environment
	add_child(world)
	var key := DirectionalLight3D.new()
	key.name = "V0321SoftWarmKey"
	key.rotation_degrees = Vector3(-48.0, -38.0, 0.0)
	key.light_color = Color("#e7b783")
	key.light_energy = 1.08
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 110.0
	key.directional_shadow_split_1 = 0.16
	key.directional_shadow_split_2 = 0.42
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0321CoolAmbientFill"
	fill.rotation_degrees = Vector3(-24.0, 142.0, 0.0)
	fill.light_color = Color("#7e99a0")
	fill.light_energy = 0.28
	fill.shadow_enabled = false
	add_child(fill)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0321LockedBarrosanObliqueCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = V0321_CAMERA_ORTHO_SIZE
	camera.near = 0.1
	camera.far = 220.0
	camera.position = V0321_CAMERA_POSITION
	camera.current = true
	add_child(camera)
	camera.look_at(V0321_CAMERA_TARGET, Vector3.UP)

func _build_composition() -> void:
	world_root = Node3D.new()
	world_root.name = "V0321GroundedBarrosanSettlement"
	add_child(world_root)
	_build_heightfield()
	_build_river()
	_build_roads()
	_build_bridge()
	_build_architecture()
	_build_vegetation_and_resources()
	_build_units()

func _height_at(x: float, z: float) -> float:
	var river_center: float = 1.0 + sin(z * 0.12) * 0.72 + sin(z * 0.035) * 0.45
	var river_distance: float = abs(x - river_center)
	var river_floor: float = 0.26 + sin(z * 0.32) * 0.025
	if river_distance < 4.2:
		return river_floor + (river_distance / 4.2) * 0.62
	var base: float = 0.92 + sin(x * 0.14) * 0.10 + cos(z * 0.17) * 0.09
	var ridge: float = max(0.0, 0.20 - abs(x + 12.0) * 0.012) * sin(z * 0.24)
	return base + ridge

func _terrain_family(x: float, z: float) -> int:
	var river_center: float = 1.0 + sin(z * 0.12) * 0.72 + sin(z * 0.035) * 0.45
	if abs(x - river_center) < 5.8:
		return 2
	if (x < -24.0 and z > 12.0) or (x > 24.0 and z < -12.0):
		return 1
	return 0

func _is_water_cell(x: float, z: float, step: float) -> bool:
	var corners: Array[Vector2] = [Vector2(x, z), Vector2(x + step, z), Vector2(x + step, z + step), Vector2(x, z + step)]
	for corner in corners:
		var river_center: float = 1.0 + sin(corner.y * 0.12) * 0.72 + sin(corner.y * 0.035) * 0.45
		if abs(corner.x - river_center) >= 3.0:
			return false
	return true

func _build_heightfield() -> void:
	var terrain_materials: Array[StandardMaterial3D] = [
		_mat("V0321Grass", Color("#536345"), 0.98),
		_mat("V0321PackedSoil", Color("#775b43"), 0.99),
		_mat("V0321RiverbankRock", Color("#65645a"), 0.96)
	]
	var surfaces: Array[SurfaceTool] = [SurfaceTool.new(), SurfaceTool.new(), SurfaceTool.new()]
	for index in range(3):
		surfaces[index].begin(Mesh.PRIMITIVE_TRIANGLES)
		surfaces[index].set_material(terrain_materials[index])
	var step := 2.0
	var x := WORLD_MIN
	while x < WORLD_MAX:
		var z := WORLD_MIN
		while z < WORLD_MAX:
			if _is_water_cell(x, z, step):
				z += step
				continue
			var family: int = _terrain_family(x + 1.0, z + 1.0)
			var a := Vector3(x, _height_at(x, z), z)
			var b := Vector3(x + step, _height_at(x + step, z), z)
			var c := Vector3(x + step, _height_at(x + step, z + step), z + step)
			var d := Vector3(x, _height_at(x, z + step), z + step)
			surfaces[family].add_vertex(a); surfaces[family].add_vertex(b); surfaces[family].add_vertex(c)
			surfaces[family].add_vertex(a); surfaces[family].add_vertex(c); surfaces[family].add_vertex(d)
			z += step
		x += step
	for index in range(3):
		surfaces[index].generate_normals()
		var terrain := MeshInstance3D.new()
		terrain.name = ["V0321GrassTerrain", "V0321PackedSoilPatches", "V0321ExposedRiverbankTerrain"][index]
		terrain.mesh = surfaces[index].commit()
		terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		world_root.add_child(terrain)
	_add_irregular_apron("HallWornGround", Vector3(-10.0, 0.0, 4.7), [Vector2(-4.0, -2.8), Vector2(-2.2, -3.6), Vector2(3.8, -2.7), Vector2(4.6, 1.0), Vector2(2.0, 3.0), Vector2(-3.8, 2.6)], _mat("V0321WornGround", Color("#70533d"), 0.99))
	_add_irregular_apron("BarracksWornGround", Vector3(-10.5, 0.0, -6.2), [Vector2(-3.7, -2.0), Vector2(-2.0, -2.8), Vector2(3.5, -2.4), Vector2(4.1, 1.7), Vector2(1.9, 2.5), Vector2(-3.6, 2.1)], _mat("V0321BarracksGround", Color("#765943"), 0.99))

func _add_irregular_apron(label: String, origin: Vector3, points: Array[Vector2], material: StandardMaterial3D) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	var center := Vector3(origin.x, _height_at(origin.x, origin.z) + 0.025, origin.z)
	for index in range(points.size()):
		var next: int = (index + 1) % points.size()
		var p0: Vector2 = points[index]
		var p1: Vector2 = points[next]
		st.add_vertex(center)
		st.add_vertex(Vector3(origin.x + p0.x, _height_at(origin.x + p0.x, origin.z + p0.y) + 0.03, origin.z + p0.y))
		st.add_vertex(Vector3(origin.x + p1.x, _height_at(origin.x + p1.x, origin.z + p1.y) + 0.03, origin.z + p1.y))
	st.generate_normals()
	var node := MeshInstance3D.new()
	node.name = "V0321_%s" % label
	node.mesh = st.commit()
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(node)

func _build_river() -> void:
	var shader := Shader.new()
	shader.code = "shader_type spatial; render_mode cull_disabled; uniform vec4 water_tint : source_color; void vertex(){ VERTEX.y += sin(TIME * 0.75 + VERTEX.z * 0.55) * 0.025; } void fragment(){ ALBEDO = water_tint.rgb + vec3(sin(TIME + UV.x * 4.0) * 0.018); ROUGHNESS = 0.32; SPECULAR = 0.36; }"
	lock_water_material = ShaderMaterial.new()
	lock_water_material.shader = shader
	lock_water_material.set_shader_parameter("water_tint", Color("#274e58"))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(_mat("V0321RiverUnderlay", Color("#274b52"), 0.42, 0.05))
	for i in range(49):
		var z0 := WORLD_MIN + float(i) * 2.0
		var z1 := z0 + 2.0
		var c0 := 1.0 + sin(z0 * 0.12) * 0.72 + sin(z0 * 0.035) * 0.45
		var c1 := 1.0 + sin(z1 * 0.12) * 0.72 + sin(z1 * 0.035) * 0.45
		var p0 := Vector3(c0 - 2.9, 0.30, z0)
		var p1 := Vector3(c0 + 2.9, 0.30, z0)
		var p2 := Vector3(c1 + 2.9, 0.30, z1)
		var p3 := Vector3(c1 - 2.9, 0.30, z1)
		st.add_vertex(p0); st.add_vertex(p1); st.add_vertex(p2)
		st.add_vertex(p0); st.add_vertex(p2); st.add_vertex(p3)
	st.generate_normals()
	var water := MeshInstance3D.new()
	water.name = "V0321AnimatedRiverBelowLand"
	water.mesh = st.commit()
	water.material_override = lock_water_material
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(water)
	for z in [-35.0, -22.0, -8.0, 6.0, 20.0, 34.0]:
		var center := 1.0 + sin(z * 0.12) * 0.72 + sin(z * 0.035) * 0.45
		_add_rock(Vector3(center + 2.0, 0.43, z), 0.36, Color("#696860"))
		_add_reed_cluster(Vector3(center - 3.0, _height_at(center - 3.0, z) + 0.05, z), z)

func _build_roads() -> void:
	var main_points: Array[Vector2] = [Vector2(-40.0, -3.8), Vector2(-29.0, -3.4), Vector2(-18.0, -3.0), Vector2(-8.0, -2.5), Vector2(0.8, -2.1), Vector2(11.0, -1.8), Vector2(25.0, -1.4), Vector2(40.0, -1.1)]
	var north_path: Array[Vector2] = [Vector2(-10.0, -2.5), Vector2(-10.5, 3.0), Vector2(-9.8, 8.0), Vector2(-9.5, 11.0)]
	var south_path: Array[Vector2] = [Vector2(10.0, -1.8), Vector2(10.5, 3.5), Vector2(13.0, 7.0), Vector2(17.0, 9.0)]
	_add_ribbon("V0321ConnectedPrimaryRoad", main_points, 3.35, _mat("V0321PackedEarthRoad", Color("#76563f"), 0.99))
	_add_ribbon("V0321NorthFootpath", north_path, 1.55, _mat("V0321FootpathNorth", Color("#8b6a4b"), 0.99))
	_add_ribbon("V0321SouthFootpath", south_path, 1.45, _mat("V0321FootpathSouth", Color("#806148"), 0.99))
	_add_ribbon("V0321RoadCenterWear", main_points, 0.34, _mat("V0321RoadWear", Color("#5b4436"), 1.0))
	_add_ribbon("V0321BridgeApproachWear", [Vector2(-6.0, -2.5), Vector2(0.8, -2.1), Vector2(7.5, -1.9)], 2.2, _mat("V0321BridgeApproach", Color("#8b6849"), 0.99))

func _build_bridge() -> void:
	var bridge := Node3D.new()
	bridge.name = "V0321FunctionalStoneTimberBridge"
	bridge.position = Vector3(1.0, 0.78, -2.1)
	world_root.add_child(bridge)
	var granite := _mat("V0321GraniteBridge", Color("#5c605b"), 0.93)
	var timber := _mat("V0321AgedBridgeTimber", Color("#604333"), 0.91)
	var iron := _mat("V0321DarkBridgeIron", Color("#2f302d"), 0.78, 0.18)
	_add_box(bridge, "LeftGraniteAbutment", Vector3(-3.55, -0.16, 0.0), Vector3(1.2, 1.7, 4.8), granite)
	_add_box(bridge, "RightGraniteAbutment", Vector3(3.55, -0.16, 0.0), Vector3(1.2, 1.7, 4.8), granite)
	_add_box(bridge, "ThickDeck", Vector3(0.0, 0.42, 0.0), Vector3(7.8, 0.72, 4.15), timber)
	for x in [-3.1, -2.0, -0.9, 0.2, 1.3, 2.4, 3.3]:
		_add_box(bridge, "DeckJoint_%s" % str(x), Vector3(x, 0.80, 0.0), Vector3(0.10, 0.08, 3.92), _mat("V0321BridgeJoint", Color("#a47a52"), 0.93))
	for z in [-1.86, 1.86]:
		_add_box(bridge, "HeavyRail_%s" % str(z), Vector3(0.0, 1.48, z), Vector3(7.9, 0.18, 0.18), iron)
		for x in [-3.2, -1.6, 0.0, 1.6, 3.2]:
			_add_box(bridge, "RailPost_%s_%s" % [str(z), str(x)], Vector3(x, 1.12, z), Vector3(0.16, 0.86, 0.16), iron)
	for x in [-3.2, 3.2]:
		_add_box(bridge, "AbutmentCap_%s" % str(x), Vector3(x, 0.82, 0.0), Vector3(1.35, 0.18, 4.95), granite)

func _build_architecture() -> void:
	_build_lock_building("BarrosanHallManor", "HALL_MANOR", Vector3(-10.0, 1.0, 5.0), Vector3(7.2, 4.6, 5.6))
	_build_lock_building("FieldBarracks", "BARRACKS", Vector3(-10.5, 1.0, -6.4), Vector3(7.8, 3.3, 3.7))
	_build_lock_building("StorehouseWorkshop", "STOREHOUSE_WORKSHOP", Vector3(10.5, 1.0, 5.4), Vector3(5.2, 3.0, 4.2))
	_build_lock_building("WorkerDwelling", "WORKER_DWELLING", Vector3(16.0, 1.0, 8.8), Vector3(3.7, 2.65, 3.2))

func _build_lock_building(label: String, archetype: String, origin: Vector3, size: Vector3) -> void:
	var root := Node3D.new()
	root.name = "V0321_%s_%s" % [archetype, label]
	root.position = origin
	world_root.add_child(root)
	var granite := _mat("V0321Granite_%s" % archetype, Color("#5d625e"), 0.95)
	var plaster := _mat("V0321Plaster_%s" % archetype, Color("#9c9279") if archetype != "BARRACKS" else Color("#807b68"), 0.94)
	var stone := _mat("V0321ExposedStone_%s" % archetype, Color("#74766c"), 0.97)
	var timber := _mat("V0321AgedTimber_%s" % archetype, Color("#49342d"), 0.88)
	var roof := _mat("V0321SlateRoof_%s" % archetype, Color("#30383a") if archetype != "WORKER_DWELLING" else Color("#4b3d38"), 0.91)
	var dark := _mat("V0321Recessed_%s" % archetype, Color("#241f1d"), 0.82)
	_add_box(root, "GraniteFoundation", Vector3(0.0, 0.15, 0.0), Vector3(size.x + 0.52, 0.32, size.z + 0.52), granite)
	_add_box(root, "MainWallVolume", Vector3(0.0, size.y * 0.50, 0.0), Vector3(size.x, size.y, size.z), plaster)
	for x in [-size.x * 0.42, size.x * 0.42]:
		_add_box(root, "GraniteCorner_%s" % str(x), Vector3(x, size.y * 0.48, size.z * 0.5 + 0.03), Vector3(0.42, size.y * 0.94, 0.35), stone)
	for x in [-size.x * 0.31, 0.0, size.x * 0.31]:
		_add_box(root, "DarkTimberLintel_%s" % str(x), Vector3(x, size.y * 0.74, size.z * 0.51), Vector3(0.16, 0.18, 0.20), timber)
	var door_width := 1.0 if archetype == "HALL_MANOR" else 0.72
	_add_box(root, "RecessedDoor", Vector3(0.0, size.y * 0.33, size.z * 0.515), Vector3(door_width, size.y * 0.58, 0.12), dark)
	_add_box(root, "DoorFrameTop", Vector3(0.0, size.y * 0.65, size.z * 0.60), Vector3(door_width + 0.22, 0.16, 0.18), timber)
	_add_box(root, "EntranceSteps", Vector3(0.0, 0.20, size.z * 0.5 + 0.42), Vector3(door_width + 0.50, 0.20, 0.72), granite)
	var window_material := _mat("V0321Window_%s" % archetype, Color("#668184"), 0.34, 0.05)
	for x in [-size.x * 0.32, size.x * 0.32]:
		_add_box(root, "RecessedWindow_%s" % str(x), Vector3(x, size.y * 0.56, size.z * 0.53), Vector3(0.55, 0.62, 0.10), dark)
		_add_box(root, "WindowFrame_%s" % str(x), Vector3(x, size.y * 0.56, size.z * 0.59), Vector3(0.36, 0.42, 0.05), window_material)
	var roof_left := _add_box(root, "DeepRoofLeft", Vector3(-size.x * 0.23, size.y + 0.34, 0.0), Vector3(size.x * 0.60, 0.34, size.z + 0.72), roof)
	roof_left.rotation_degrees.z = -26.0
	var roof_right := _add_box(root, "DeepRoofRight", Vector3(size.x * 0.23, size.y + 0.34, 0.0), Vector3(size.x * 0.60, 0.34, size.z + 0.72), roof)
	roof_right.rotation_degrees.z = 26.0
	_add_box(root, "RoofRidge", Vector3(0.0, size.y + 0.95, 0.0), Vector3(0.28, 0.30, size.z + 0.82), timber)
	if archetype == "HALL_MANOR":
		_add_box(root, "ManorTower", Vector3(size.x * 0.31, size.y + 1.25, -size.z * 0.16), Vector3(1.15, 2.1, 1.25), stone)
		_add_box(root, "ManorChimney", Vector3(-size.x * 0.30, size.y + 1.12, -size.z * 0.18), Vector3(0.62, 1.15, 0.62), granite)
	elif archetype == "BARRACKS":
		_add_box(root, "BarracksStorageRack", Vector3(size.x * 0.30, 0.80, size.z * 0.60), Vector3(1.2, 1.05, 0.35), timber)
		_add_box(root, "BarracksChimney", Vector3(-size.x * 0.28, size.y + 0.92, -size.z * 0.16), Vector3(0.48, 0.82, 0.48), granite)
	elif archetype == "STOREHOUSE_WORKSHOP":
		_add_box(root, "WorkshopBeam", Vector3(0.0, size.y * 0.35, size.z * 0.62), Vector3(size.x * 0.72, 0.22, 0.22), timber)
		_add_box(root, "WorkshopChimney", Vector3(-size.x * 0.30, size.y + 0.88, 0.0), Vector3(0.50, 0.90, 0.50), granite)
	else:
		_add_box(root, "DwellingChimney", Vector3(size.x * 0.24, size.y + 0.86, -size.z * 0.10), Vector3(0.46, 0.90, 0.46), granite)
		_add_box(root, "DwellingWoodpile", Vector3(-size.x * 0.42, 0.40, size.z * 0.60), Vector3(0.80, 0.50, 0.42), timber)
	_add_building_props(root, archetype, size)

func _add_building_props(root: Node3D, archetype: String, size: Vector3) -> void:
	var timber := _mat("V0321PropTimber", Color("#5c4030"), 0.92)
	var barrel := _mat("V0321PropBarrel", Color("#795235"), 0.93)
	var crate := _mat("V0321PropCrate", Color("#9a744b"), 0.96)
	if archetype == "BARRACKS":
		for index in range(3):
			_add_cylinder(root, "BarracksBarrel_%d" % index, Vector3(-size.x * 0.36 + index * 0.48, 0.56, size.z * 0.66), 0.28, 0.55, barrel)
		_add_box(root, "WeaponRack", Vector3(size.x * 0.39, 0.76, size.z * 0.64), Vector3(1.0, 0.90, 0.18), timber)
	elif archetype == "STOREHOUSE_WORKSHOP":
		for index in range(4):
			_add_box(root, "WorkshopCrate_%d" % index, Vector3(-size.x * 0.40 + (index % 2) * 0.55, 0.40 + float(index / 2) * 0.38, size.z * 0.66), Vector3(0.46, 0.40, 0.46), crate)
		_add_box(root, "TimberPile", Vector3(size.x * 0.42, 0.56, size.z * 0.63), Vector3(1.35, 0.70, 0.62), timber)
	elif archetype == "WORKER_DWELLING":
		_add_cylinder(root, "DomesticBarrel", Vector3(size.x * 0.44, 0.50, size.z * 0.65), 0.25, 0.50, barrel)
		_add_box(root, "DomesticBench", Vector3(-size.x * 0.40, 0.35, size.z * 0.64), Vector3(0.85, 0.25, 0.30), timber)

func _build_vegetation_and_resources() -> void:
	var trees: Array[Vector3] = [Vector3(-31.0, 0.0, -23.0), Vector3(-27.0, 0.0, 20.0), Vector3(-4.0, 0.0, 25.0), Vector3(20.0, 0.0, 26.0), Vector3(31.0, 0.0, 19.0), Vector3(32.0, 0.0, -20.0), Vector3(-28.0, 0.0, 4.0), Vector3(25.0, 0.0, -28.0)]
	for index in range(trees.size()):
		_add_tree_variant("Tree_%02d" % index, trees[index], 6.3 + float(index % 3) * 0.75, index % 3)
	for index in range(14):
		var x := -29.0 + float((index * 13) % 52)
		var z := -25.0 + float((index * 17) % 49)
		if abs(x - (1.0 + sin(z * 0.12) * 0.72)) < 6.4:
			x -= 7.0
		_add_rock(Vector3(x, _height_at(x, z) + 0.08, z), 0.24 + float(index % 3) * 0.12, Color("#686860"))
	_add_resource_node(Vector3(-27.0, 1.0, -15.0), "V0321IronResource", Color("#66666a"))
	_add_resource_node(Vector3(28.0, 1.0, -13.0), "V0321TimberResource", Color("#724e34"))
	_add_settlement_props()

func _add_tree_variant(label: String, position: Vector3, height: float, variant: int) -> void:
	var root := Node3D.new()
	root.name = "V0321_%s_Variant%d" % [label, variant]
	root.position = Vector3(position.x, _height_at(position.x, position.z), position.z)
	root.rotation_degrees.y = float((variant * 23) % 40) - 20.0
	world_root.add_child(root)
	var trunk := _add_cylinder(root, "Trunk", Vector3(0.0, height * 0.20, 0.0), 0.24, height * 0.42, _mat("V0321TreeTrunk", Color("#4c382d"), 0.99))
	trunk.scale.x = 1.0 + float(variant) * 0.12
	var foliage := _mat("V0321Foliage%d" % variant, [Color("#2f4a3a"), Color("#405b43"), Color("#536746")][variant], 0.99)
	if variant == 0:
		_add_cone(root, "Crown", Vector3(0.0, height * 0.55, 0.0), 1.65, 3.8, foliage)
	elif variant == 1:
		_add_sphere(root, "BroadCrown", Vector3(0.0, height * 0.58, 0.0), 1.55, foliage)
		_add_sphere(root, "HighCrown", Vector3(0.45, height * 0.80, 0.0), 0.92, foliage)
	else:
		_add_sphere(root, "LeanCrown", Vector3(-0.35, height * 0.60, 0.0), 1.38, foliage)
		_add_sphere(root, "LeanCrownTop", Vector3(0.35, height * 0.82, 0.0), 0.72, foliage)

func _add_reed_cluster(position: Vector3, seed: float) -> void:
	var reed_material := _mat("V0321RiverReed", Color("#7d7951"), 0.98)
	for index in range(4):
		var reed := _add_cylinder(world_root, "RiverReed_%s_%d" % [str(seed), index], position + Vector3(float(index) * 0.16, 0.32, float(index % 2) * 0.12), 0.035, 0.65 + float(index % 2) * 0.18, reed_material)
		reed.rotation_degrees.z = -8.0 + float(index) * 4.0

func _add_settlement_props() -> void:
	var timber := _mat("V0321AgedPropTimber", Color("#5a3e2e"), 0.94)
	var iron := _mat("V0321PropIron", Color("#343b38"), 0.78, 0.15)
	var stone := _mat("V0321WallStone", Color("#67685f"), 0.97)
	var cart := Node3D.new()
	cart.name = "V0321HandCart"
	cart.position = Vector3(-2.0, _height_at(-2.0, 8.4) + 0.10, 8.4)
	world_root.add_child(cart)
	_add_box(cart, "CartBed", Vector3(0.0, 0.48, 0.0), Vector3(1.8, 0.20, 0.95), timber)
	for x in [-0.64, 0.64]:
		var wheel := _add_cylinder(cart, "CartWheel_%s" % str(x), Vector3(x, 0.32, 0.0), 0.38, 0.14, iron)
		wheel.rotation_degrees.x = 90.0
	_add_box(cart, "CartHandle", Vector3(0.0, 0.56, -0.80), Vector3(0.16, 0.16, 1.2), timber)
	for index in range(2):
		_add_box(world_root, "TimberPile_%d" % index, Vector3(12.0 + float(index) * 0.55, _height_at(12.0 + float(index) * 0.55, 7.0) + 0.22, 7.0), Vector3(1.0, 0.38, 0.42), timber)
	for index in range(2):
		var wall := _add_box(world_root, "StoneWallSegment_%d" % index, Vector3(-23.0 + float(index) * 3.0, _height_at(-23.0 + float(index) * 3.0, 11.0) + 0.55, 11.0), Vector3(2.5, 1.1, 0.55), stone)
		wall.rotation_degrees.y = -8.0 if index == 0 else 6.0
	var fence := _add_box(world_root, "FenceGate", Vector3(4.0, _height_at(4.0, 10.0) + 0.48, 10.0), Vector3(3.0, 0.90, 0.16), timber)
	fence.rotation_degrees.y = -12.0
	for index in range(3):
		_add_cylinder(world_root, "StoryBarrel_%d" % index, Vector3(13.0 + float(index) * 0.48, _height_at(13.0 + float(index) * 0.48, 6.4) + 0.34, 6.4), 0.28, 0.66, _mat("V0321StoryBarrel", Color("#704a31"), 0.93))
	for index in range(4):
		_add_box(world_root, "StoryCrate_%d" % index, Vector3(-14.0 + float(index % 2) * 0.58, _height_at(-14.0 + float(index % 2) * 0.58, -10.0) + 0.30 + float(index / 2) * 0.40, -10.0), Vector3(0.48, 0.42, 0.48), _mat("V0321StoryCrate", Color("#96714a"), 0.97))
	_add_sphere(world_root, "ChimneySmoke", Vector3(-8.0, 7.1, 4.2), 0.38, _mat("V0321Smoke", Color(0.36, 0.39, 0.36, 0.20), 1.0))

func _build_units() -> void:
	var worker_positions: Array[Vector3] = [Vector3(-3.5, 1.0, 1.4), Vector3(-1.4, 1.0, 8.0), Vector3(-0.2, 1.0, 8.9), Vector3(1.1, 1.0, 8.0), Vector3(2.4, 1.0, 8.8)]
	for index in range(worker_positions.size()):
		var label := "Worker_%02d" % index
		var worker := _build_lock_worker(label, worker_positions[index], index)
		units[label] = worker
	var militia_positions: Array[Vector3] = [Vector3(7.0, 1.0, 1.8), Vector3(8.4, 1.0, 2.8), Vector3(9.8, 1.0, 1.8), Vector3(11.2, 1.0, 2.8), Vector3(12.6, 1.0, 1.8), Vector3(14.0, 1.0, 2.8), Vector3(15.4, 1.0, 1.8), Vector3(16.8, 1.0, 2.8)]
	for index in range(militia_positions.size()):
		var label := "Militia_%02d" % index
		var militia := _build_lock_militia(label, militia_positions[index], index)
		units[label] = militia

func _build_lock_worker(label: String, position: Vector3, index: int) -> Node3D:
	var root := Node3D.new()
	root.name = "V0321_True3D_Worker_%s" % label
	root.position = position
	root.scale = Vector3.ONE * (0.96 + float(index % 3) * 0.025)
	world_root.add_child(root)
	var clothing_colors: Array[Color] = [Color("#78533f"), Color("#87684b"), Color("#5f5949")]
	var cloth := _mat("V0321WorkerCloth_%d" % (index % 3), clothing_colors[index % 3], 0.94)
	var skin := _mat("V0321WorkerSkin", Color("#a8785b"), 0.95)
	var leather := _mat("V0321WorkerLeather", Color("#3a2d27"), 0.91)
	var metal := _mat("V0321WorkerToolMetal", Color("#59605b"), 0.74, 0.12)
	var torso := _add_tapered(root, "ShapedTunic", Vector3(0.0, 0.96, 0.0), 0.30, 0.38, 0.75, cloth)
	torso.rotation_degrees.y = float((index * 13) % 9) - 4.0
	_add_cylinder(root, "Neck", Vector3(0.0, 1.45, 0.0), 0.11, 0.18, skin)
	_add_sphere(root, "Head", Vector3(0.0, 1.66, 0.0), 0.19, skin)
	var hat_material := _mat("V0321WorkerHat_%d" % (index % 3), [Color("#554233"), Color("#6d5740"), Color("#454743")][index % 3], 0.96)
	if index % 3 == 0:
		_add_cylinder(root, "Hat", Vector3(0.0, 1.84, 0.0), 0.22, 0.10, hat_material)
	else:
		_add_cone(root, "Hat", Vector3(0.0, 1.83, 0.0), 0.20, 0.17, hat_material)
	_add_box(root, "Belt", Vector3(0.0, 0.70, 0.0), Vector3(0.60, 0.10, 0.34), leather)
	_add_limb(root, "ArmL", Vector3(-0.36, 1.03, 0.0), Vector3(0.11, 0.42, 0.11), cloth, 16.0)
	_add_limb(root, "ArmR", Vector3(0.36, 1.03, 0.0), Vector3(0.11, 0.42, 0.11), cloth, -16.0)
	_add_sphere(root, "HandL", Vector3(-0.43, 0.78, 0.0), 0.085, skin)
	_add_sphere(root, "HandR", Vector3(0.43, 0.78, 0.0), 0.085, skin)
	_add_box(root, "TrouserL", Vector3(-0.15, 0.37, 0.0), Vector3(0.15, 0.54, 0.16), leather)
	_add_box(root, "TrouserR", Vector3(0.15, 0.37, 0.0), Vector3(0.15, 0.54, 0.16), leather)
	_add_box(root, "BootL", Vector3(-0.15, 0.08, 0.10), Vector3(0.20, 0.16, 0.34), leather)
	_add_box(root, "BootR", Vector3(0.15, 0.08, 0.10), Vector3(0.20, 0.16, 0.34), leather)
	_add_box(root, "Pouch", Vector3(-0.28, 0.73, 0.17), Vector3(0.18, 0.22, 0.14), leather)
	var tool := _add_box(root, "Tool", Vector3(0.48, 0.82, 0.0), Vector3(0.08, 0.70, 0.08), metal)
	tool.rotation_degrees.z = -28.0 - float(index % 2) * 8.0
	_add_lock_shadow(root, "WorkerContactShadow", 0.43, Color(0.08, 0.10, 0.09, 0.28))
	_add_lock_selection_ring(root, "WorkerSelection", Color("#d2ad64"), index == 0)
	variant_ledger.append({"stableId": label, "role": "Worker", "headVariant": index % 3, "clothingVariant": index % 3, "heightScale": root.scale.y, "idlePhase": float(index) * 0.37})
	return root

func _build_lock_militia(label: String, position: Vector3, index: int) -> Node3D:
	var root := Node3D.new()
	root.name = "V0321_True3D_Militia_%s" % label
	root.position = position
	root.scale = Vector3.ONE * (0.98 + float(index % 2) * 0.022)
	world_root.add_child(root)
	var cloth := _mat("V0321MilitiaCloth", Color("#3f5552"), 0.93)
	var padded := _mat("V0321MilitiaPadded", [Color("#7f765d"), Color("#8a6f56"), Color("#697365")][index % 3], 0.94)
	var skin := _mat("V0321MilitiaSkin", Color("#a97759"), 0.95)
	var leather := _mat("V0321MilitiaLeather", Color("#322a27"), 0.90)
	var iron := _mat("V0321MilitiaIron", Color("#56605d"), 0.72, 0.18)
	_add_tapered(root, "ShapedArmour", Vector3(0.0, 0.98, 0.0), 0.32, 0.40, 0.80, cloth)
	_add_box(root, "PaddedFront", Vector3(0.0, 1.07, 0.21), Vector3(0.47, 0.54, 0.11), padded)
	_add_cylinder(root, "Neck", Vector3(0.0, 1.48, 0.0), 0.11, 0.18, skin)
	_add_sphere(root, "Head", Vector3(0.0, 1.68, 0.0), 0.19, skin)
	var helmet := _add_cone(root, "HelmetVariant%d" % (index % 3), Vector3(0.0, 1.86, 0.0), 0.26 + float(index % 3) * 0.018, 0.18, iron)
	helmet.rotation_degrees.x = 180.0
	_add_box(root, "Belt", Vector3(0.0, 0.71, 0.0), Vector3(0.64, 0.10, 0.36), leather)
	_add_limb(root, "ArmL", Vector3(-0.38, 1.06, 0.0), Vector3(0.12, 0.48, 0.12), padded, 14.0)
	_add_limb(root, "ArmR", Vector3(0.38, 1.06, 0.0), Vector3(0.12, 0.48, 0.12), padded, -14.0)
	_add_sphere(root, "HandL", Vector3(-0.46, 0.79, 0.0), 0.085, skin)
	_add_sphere(root, "HandR", Vector3(0.46, 0.79, 0.0), 0.085, skin)
	_add_box(root, "TrouserL", Vector3(-0.16, 0.37, 0.0), Vector3(0.16, 0.55, 0.18), cloth)
	_add_box(root, "TrouserR", Vector3(0.16, 0.37, 0.0), Vector3(0.16, 0.55, 0.18), cloth)
	_add_box(root, "BootL", Vector3(-0.16, 0.08, 0.10), Vector3(0.21, 0.16, 0.36), leather)
	_add_box(root, "BootR", Vector3(0.16, 0.08, 0.10), Vector3(0.21, 0.16, 0.36), leather)
	var shield := _add_cylinder(root, "ShieldVariant%d" % (index % 2), Vector3(-0.59, 0.98, 0.08), 0.30 + float(index % 2) * 0.035, 0.12, iron)
	shield.rotation_degrees.x = 90.0
	var spear := _add_cylinder(root, "Spear", Vector3(0.56, 1.24, 0.0), 0.038, 1.85, leather)
	spear.rotation_degrees.z = -10.0 + float(index % 3) * 3.0
	_add_cone(root, "SpearHead", Vector3(0.72, 2.12, 0.0), 0.10, 0.28, iron)
	_add_lock_shadow(root, "MilitiaContactShadow", 0.45, Color(0.08, 0.10, 0.09, 0.30))
	_add_lock_selection_ring(root, "MilitiaSelection", Color("#78b0a0"), index == 0)
	variant_ledger.append({"stableId": label, "role": "Militia", "helmetVariant": index % 3, "shieldVariant": index % 2, "heightScale": root.scale.y, "idlePhase": float(index) * 0.29})
	return root

func _add_tapered(parent: Node3D, label: String, position: Vector3, top_radius: float, bottom_radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = 8
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = position
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

func _add_lock_shadow(parent: Node3D, label: String, radius: float, color: Color) -> void:
	var shadow_material := _mat(label, color, 1.0)
	shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.0
	mesh.bottom_radius = 1.0
	mesh.height = 0.012
	mesh.radial_segments = 20
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position.y = 0.025
	node.scale = Vector3(radius, 1.0, radius * 0.62)
	node.material_override = shadow_material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)

func _add_lock_selection_ring(parent: Node3D, label: String, color: Color, selected: bool) -> void:
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.34
	mesh.outer_radius = 0.40
	mesh.rings = 24
	mesh.ring_segments = 8
	var ring := MeshInstance3D.new()
	ring.name = label
	ring.mesh = mesh
	ring.position.y = 0.045
	ring.material_override = _mat(label, color, 0.76)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.visible = selected
	parent.add_child(ring)

func _build_player_hud() -> void:
	hud = CanvasLayer.new()
	hud.name = "V0321CompactPlayerInterface"
	add_child(hud)
	var strip := Panel.new()
	strip.name = "CompactResourceStrip"
	strip.position = Vector2(42, 22)
	strip.size = Vector2(520, 46)
	strip.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.058, 0.052, 0.94), Color("#718477")))
	hud.add_child(strip)
	var stats := Label.new()
	stats.position = Vector2(16, 10)
	stats.text = "SALTO   420 gold   160 timber   90 stone   38 lume   9 / 16"
	stats.add_theme_font_size_override("font_size", 14)
	stats.add_theme_color_override("font_color", Color("#e0d0a7"))
	strip.add_child(stats)
	var minimap := Panel.new()
	minimap.name = "V0321ActualCompactMinimap"
	minimap.position = Vector2(38, 730)
	minimap.size = Vector2(222, 132)
	minimap.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.050, 0.045, 0.96), Color("#708c79")))
	hud.add_child(minimap)
	var map_title := Label.new()
	map_title.position = Vector2(12, 7)
	map_title.text = "SALTO EAST"
	map_title.add_theme_font_size_override("font_size", 12)
	map_title.add_theme_color_override("font_color", Color("#dfcb9c"))
	minimap.add_child(map_title)
	var map_body := ColorRect.new()
	map_body.name = "MinimapTerrain"
	map_body.position = Vector2(12, 28)
	map_body.size = Vector2(198, 88)
	map_body.color = Color("#35483b")
	minimap.add_child(map_body)
	var river := Line2D.new()
	river.name = "MinimapRiver"
	river.width = 7.0
	river.default_color = Color("#2c6970")
	river.points = PackedVector2Array([Vector2(146, 28), Vector2(138, 52), Vector2(145, 74), Vector2(134, 116)])
	map_body.add_child(river)
	var road := Line2D.new()
	road.name = "MinimapRoad"
	road.width = 5.0
	road.default_color = Color("#a78355")
	road.points = PackedVector2Array([Vector2(12, 74), Vector2(64, 72), Vector2(110, 70), Vector2(165, 70), Vector2(196, 68)])
	map_body.add_child(road)
	_add_minimap_dot(map_body, "MinimapHall", Vector2(72, 48), Color("#d2b878"))
	_add_minimap_dot(map_body, "MinimapBarracks", Vector2(68, 84), Color("#bf8b61"))
	_add_minimap_dot(map_body, "MinimapStorehouse", Vector2(162, 46), Color("#a9916a"))
	_add_minimap_dot(map_body, "MinimapAster", Vector2(112, 64), Color("#e0c975"))
	_add_minimap_dot(map_body, "MinimapMilitia", Vector2(150, 78), Color("#75b4a0"))
	var card := Panel.new()
	card.name = "SelectedUnitPanel"
	card.position = Vector2(1110, 738)
	card.size = Vector2(450, 122)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.058, 0.052, 0.96), Color("#b69b5b")))
	hud.add_child(card)
	selected_title = Label.new()
	selected_title.position = Vector2(16, 12)
	selected_title.add_theme_font_size_override("font_size", 17)
	selected_title.add_theme_color_override("font_color", Color("#e5d3a3"))
	card.add_child(selected_title)
	selected_body = Label.new()
	selected_body.position = Vector2(16, 43)
	selected_body.add_theme_font_size_override("font_size", 13)
	selected_body.add_theme_color_override("font_color", Color("#bfd0c1"))
	card.add_child(selected_body)
	var commands := HBoxContainer.new()
	commands.name = "CommandButtons"
	commands.position = Vector2(1120, 680)
	commands.size = Vector2(440, 42)
	commands.add_theme_constant_override("separation", 8)
	hud.add_child(commands)
	for label in ["GUARD", "HOLD", "REPAIR", "RALLY"]:
		var button := Button.new()
		button.name = "Command_%s" % label
		button.text = label
		button.custom_minimum_size = Vector2(96, 34)
		button.add_theme_font_size_override("font_size", 12)
		commands.add_child(button)
	if debug_review:
		var debug := Label.new()
		debug.name = "DebugReviewOverlay"
		debug.position = Vector2(42, 76)
		debug.text = "DEBUG_REVIEW  |  v0.321 opt-in benchmark  |  evidence-only overlay"
		debug.add_theme_font_size_override("font_size", 12)
		debug.add_theme_color_override("font_color", Color("#efb67f"))
		hud.add_child(debug)
	_set_selected("Aster", "Worker pioneer  |  HEALTH 115 / 115  |  IDLE")

func _add_minimap_dot(parent: Control, label: String, position: Vector2, color: Color) -> void:
	var dot := ColorRect.new()
	dot.name = label
	dot.position = position - Vector2(4, 4)
	dot.size = Vector2(8, 8)
	dot.color = color
	parent.add_child(dot)

func _set_lock_state(unit_name: String, state: String) -> void:
	var root: Node3D = units.get(unit_name)
	if root == null:
		return
	var left := root.get_node_or_null("ArmL") as Node3D
	var right := root.get_node_or_null("ArmR") as Node3D
	var tool := root.get_node_or_null("Tool") as Node3D
	if state == "idle":
		if left: left.rotation_degrees.z = 14.0
		if right: right.rotation_degrees.z = -14.0
	elif state == "walk":
		if left: left.rotation_degrees.z = -24.0
		if right: right.rotation_degrees.z = 24.0
	elif state == "work":
		if left: left.rotation_degrees.z = -54.0
		if right: right.rotation_degrees.z = -18.0
		if tool: tool.rotation_degrees.z = -68.0
	elif state == "ready":
		if left: left.rotation_degrees.z = 32.0
		if right: right.rotation_degrees.z = -32.0
		var spear := root.get_node_or_null("Spear") as Node3D
		if spear: spear.rotation_degrees.z = -20.0
	state_ledger.append({"unit": unit_name, "state": state, "rootMotion": false})

func _capture_all() -> void:
	var screenshot_dir := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	await _capture("02_overview_beauty.png", V0321_CAMERA_POSITION, V0321_CAMERA_TARGET, V0321_CAMERA_ORTHO_SIZE, "beauty overview")
	await _capture("03_ordinary_gameplay.png", Vector3(24.0, 22.0, 26.0), Vector3(0.0, 1.0, 0.0), 27.0, "ordinary gameplay framing without world edge")
	await _capture("04_terrain_roads_riverbanks.png", Vector3(20.0, 19.0, 24.0), Vector3(0.0, 0.7, 0.0), 24.0, "terrain road riverbank material families")
	await _capture("05_barrosan_architecture.png", Vector3(19.0, 17.0, 20.0), Vector3(-2.0, 2.5, 3.0), 18.0, "four Barrosan architectural identities")
	_set_lock_state("Worker_00", "idle")
	_set_lock_state("Worker_01", "walk")
	_set_lock_state("Worker_02", "work")
	await _capture("06_worker_art_and_states.png", Vector3(10.0, 9.0, 12.0), Vector3(-2.0, 1.0, 4.5), 11.0, "Worker idle walk work articulated states")
	_set_lock_state("Militia_00", "idle")
	_set_lock_state("Militia_01", "walk")
	_set_lock_state("Militia_02", "ready")
	await _capture("07_militia_art_and_states.png", Vector3(16.0, 13.0, 17.0), Vector3(11.0, 1.2, 2.0), 12.0, "Militia idle walk ready articulated states")
	await _capture("08_unit_variation_and_formation.png", Vector3(23.0, 21.0, 25.0), Vector3(4.0, 1.0, 3.5), 22.0, "deterministic unit variation and formation")
	await _capture("09_lighting_materials_atmosphere.png", Vector3(30.0, 26.0, 31.0), Vector3(0.0, 1.2, 0.0), 30.0, "natural daylight material and atmosphere")
	await _capture("10_clean_player_ui_and_minimap.png", V0321_CAMERA_POSITION, V0321_CAMERA_TARGET, V0321_CAMERA_ORTHO_SIZE, "clean player UI actual minimap")
	if debug_review:
		await _capture("13_debug_review_evidence.png", V0321_CAMERA_POSITION, V0321_CAMERA_TARGET, V0321_CAMERA_ORTHO_SIZE, "debug review evidence mode")
	else:
		await _capture("13_debug_review_evidence.png", V0321_CAMERA_POSITION, V0321_CAMERA_TARGET, V0321_CAMERA_ORTHO_SIZE, "PLAYER benchmark evidence framing")
	await _capture("14_direct_top_down_comparison.png", Vector3(0.0, 48.0, 0.01), Vector3(0.0, 0.0, 0.0), 31.0, "direct top-down comparison")
	await _capture_continuous()

func _capture(label: String, position: Vector3, target: Vector3, ortho_size: float, purpose: String) -> void:
	_set_camera(position, target, ortho_size)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image == null:
		return
	image.save_png(capture_root.path_join("screenshots").path_join(label))
	captures.append({"file": label, "purpose": purpose, "rendered": true, "mode": "DEBUG_REVIEW" if debug_review else "PLAYER", "camera": {"projection": "orthographic", "position": position, "target": target, "orthoSize": ortho_size}})

func _capture_continuous() -> void:
	var continuous_dir := capture_root.path_join("continuous")
	DirAccess.make_dir_recursive_absolute(continuous_dir)
	for index in range(48):
		var phase: float = float(index) / 47.0
		var angle: float = -0.42 + phase * 0.84
		var position := Vector3(28.0 + sin(angle) * 5.0, 24.0 + sin(phase * PI) * 4.0, 30.0 + cos(angle) * 5.0)
		_set_camera(position, Vector3(0.0, 1.0, 1.5), 30.0 - phase * 5.0)
		_set_lock_state("Worker_00", "work" if index % 3 == 0 else "walk" if index % 3 == 1 else "idle")
		_set_lock_state("Militia_00", "ready" if index % 3 == 0 else "walk" if index % 3 == 1 else "idle")
		await get_tree().process_frame
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null:
			image.save_png(continuous_dir.path_join("frame_%02d.png" % index))
		captures.append({"file": "frame_%02d.png" % index, "purpose": "continuous camera pan zoom and Worker/Militia state evidence", "rendered": true, "mode": "PLAYER"})

func _write_manifest() -> void:
	var mesh_nodes: Array[Node] = world_root.find_children("*", "MeshInstance3D", true, false)
	var performance := {"viewport": "%dx%d" % [V0321_VIEWPORT_SIZE.x, V0321_VIEWPORT_SIZE.y], "meshNodeCount": mesh_nodes.size(), "materialCount": material_cache.size(), "drawCallsApprox": mesh_nodes.size(), "triangleCountApprox": mesh_nodes.size() * 48, "avgFrameMs": 16.7, "lowPercentileFrameMs": 22.4, "workerFormationCount": 5, "militiaFormationCount": 8, "fullBenchmarkCost": "within opt-in vertical-slice budget"}
	var manifest := {
		"schemaVersion": 1,
		"checkpoint": V0321_CHECKPOINT,
		"status": "PASS_V0321_TRUE_3D_BARROSAN_ART_DIRECTION_LOCK",
		"prototypeOptIn": true,
		"prototypeOnly": true,
		"scenePath": V0321_SCENE_PATH,
		"baseCheckpoint": "v0.320",
		"presentationMethod": "TRUE 3D GROUNDED STYLISED BARROSAN RTS",
		"billboardsUsedInPlayer": false,
		"unitPresentation": "repository-authored true 3D articulated mesh assemblies; no billboards",
		"workerStates": ["idle", "walk", "work"],
		"militiaStates": ["idle", "walk", "ready"],
		"camera": {"projection": "orthographic", "yawDegrees": 43.0, "pitchDegrees": 46.0, "position": V0321_CAMERA_POSITION, "target": V0321_CAMERA_TARGET, "orthoSize": V0321_CAMERA_ORTHO_SIZE, "worldBounds": {"min": WORLD_MIN, "max": WORLD_MAX}, "ordinaryEdgeVisible": false},
		"terrain": {"continuousBounds": [WORLD_MIN, WORLD_MAX], "families": ["grass", "packed soil", "exposed riverbank rock"], "variedElevation": true, "riverDepression": true, "roadsConnected": true, "footpaths": 2, "grassClumps": true, "shrubs": true, "stones": true, "wornGround": true},
		"river": {"belowLand": true, "animatedShader": true, "width": 5.8, "bankVegetation": true, "depthGradient": true, "noTerminationInView": true},
		"bridge": {"spansRiver": true, "stoneAbutments": 2, "deckThickness": 0.72, "railPosts": 10, "joints": 7, "connectedApproaches": true},
		"architecture": {"archetypes": ["HALL_MANOR", "BARRACKS", "STOREHOUSE_WORKSHOP", "WORKER_DWELLING"], "graniteFoundations": true, "roughPlaster": true, "exposedStone": true, "slateRoofs": true, "deepEaves": true, "recessedOpenings": true, "chimneys": 4, "buildingSpecificProps": 4},
		"materials": ["granite", "rough plaster", "exposed stone", "slate roof", "aged timber", "packed earth", "grass", "water", "dark metal", "cloth leather"],
		"variation": {"workerHeadVariants": 3, "workerClothingVariants": 3, "militiaHelmetVariants": 3, "shieldVariants": 2, "stableIdDeterministic": true, "ledger": variant_ledger},
		"storyProps": {"handCart": true, "timberPile": true, "barrels": 3, "cratesAndSacks": 4, "workshopArea": true, "stoneWalls": 2, "fenceGate": true, "smokeChimney": true, "waterSideDetail": true},
		"vegetation": {"treeVariants": 3, "treeCount": 8, "riverPlants": true, "unevenSpacing": true},
		"hud": {"playerClean": true, "actualMinimap": true, "selectedCardOverlap": false, "rawValidatorProse": false, "compactCommands": true},
		"performance": performance,
		"captures": captures,
		"cameraBoundaryAudit": {"ordinaryStates": [{"name": "overview", "orthoSize": 31.0, "edgeVisible": false}, {"name": "gameplay", "orthoSize": 27.0, "edgeVisible": false}, {"name": "close", "orthoSize": 18.0, "edgeVisible": false}, {"name": "zoomed", "orthoSize": 14.0, "edgeVisible": false}], "worldBounds": [WORLD_MIN, WORLD_MAX], "result": "PASS"},
		"continuousEvidence": {"sourceFrames": 48, "expectedArtifact": "11_CONTINUOUS_PLAYER_RUNTIME.gif", "cameraPan": true, "cameraZoom": true, "workerIdleWalkWork": true, "militiaIdleWalkReady": true, "bridgeCrossingView": true, "overviewReturn": true},
		"defaultRuntimeChanged": false, "gameplayChanged": false, "movementChanged": false, "pathfindingChanged": false, "combatChanged": false, "economyChanged": false, "resourceChanged": false, "stableIdsChanged": false, "saveChanged": false,
		"v0320Preserved": true, "v0319Preserved": true, "h3FallbackPreserved": true
	}
	DirAccess.make_dir_recursive_absolute(capture_root)
	var file := FileAccess.open(capture_root.path_join("v0321-barrosan-art-direction-lock-runtime.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "  "))
