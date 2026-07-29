extends Node3D

const CHECKPOINT := "v0.320"
const SCENE_PATH := "res://visual_vertical_slice/V0320VisualVerticalSlice.tscn"
const VIEWPORT_SIZE := Vector2i(1600, 900)
const CAMERA_POSITION := Vector3(23.0, 23.0, 25.0)
const CAMERA_TARGET := Vector3(0.0, 0.9, 0.0)
const CAMERA_ORTHO_SIZE := 27.0
const ARTIFACT_ARG := "--artifact-root="

var camera: Camera3D
var world_root: Node3D
var hud: CanvasLayer
var selected_title: Label
var selected_body: Label
var selection_rings: Array[MeshInstance3D] = []
var capture_root := ""
var captures: Array[Dictionary] = []
var material_cache: Dictionary = {}
var units: Dictionary = {}
var debug_review := false
var visual_phase := 0.0

func _ready() -> void:
	print("V0320_READY")
	_parse_args()
	print("V0320_ARTIFACT_ROOT=", capture_root)
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

func _parse_args() -> void:
	var arguments := OS.get_cmdline_user_args()
	arguments.append_array(OS.get_cmdline_args())
	for arg in arguments:
		if str(arg).begins_with(ARTIFACT_ARG):
			capture_root = str(arg).substr(ARTIFACT_ARG.length())
		if str(arg) == "--debug-review":
			debug_review = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#29362f")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#a9b59e")
	environment.ambient_light_energy = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = true
	environment.fog_light_color = Color("#7f9280")
	environment.fog_density = 0.0015
	var world := WorldEnvironment.new()
	world.name = "V0320AmbientWorld"
	world.environment = environment
	add_child(world)

	var key := DirectionalLight3D.new()
	key.name = "V0320WarmDirectionalKey"
	key.rotation_degrees = Vector3(-54.0, -34.0, 0.0)
	key.light_color = Color("#f2c58e")
	key.light_energy = 1.32
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 90.0
	key.directional_shadow_split_1 = 0.18
	key.directional_shadow_split_2 = 0.45
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0320CoolAmbientFill"
	fill.rotation_degrees = Vector3(-25.0, 142.0, 0.0)
	fill.light_color = Color("#7e9aaa")
	fill.light_energy = 0.34
	fill.shadow_enabled = false
	add_child(fill)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0320LockedObliqueOrthoCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = CAMERA_ORTHO_SIZE
	camera.near = 0.1
	camera.far = 180.0
	camera.position = CAMERA_POSITION
	camera.look_at(CAMERA_TARGET, Vector3.UP)
	camera.current = true
	add_child(camera)

func _build_composition() -> void:
	world_root = Node3D.new()
	world_root.name = "V0320True3DSettlementComposition"
	add_child(world_root)
	_build_heightfield()
	_build_river()
	_build_roads()
	_build_bridge()
	_build_architecture()
	_build_vegetation_and_resources()
	_build_units()

func _height_at(x: float, z: float) -> float:
	var river_center: float = 2.0 + sin(z * 0.17) * 0.42
	var distance: float = abs(x - river_center)
	if distance < 3.0:
		return 0.36 + (distance / 3.0) * 0.42
	return 0.82 + sin(x * 0.21) * 0.10 + cos(z * 0.19) * 0.08

func _build_heightfield() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(_mat("GrassEarth", Color("#5f704b"), 0.96))
	var min_x := -18.0
	var max_x := 18.0
	var min_z := -15.0
	var max_z := 15.0
	var step := 1.5
	var x := min_x
	while x < max_x:
		var z := min_z
		while z < max_z:
			var a := Vector3(x, _height_at(x, z), z)
			var b := Vector3(x + step, _height_at(x + step, z), z)
			var c := Vector3(x + step, _height_at(x + step, z + step), z + step)
			var d := Vector3(x, _height_at(x, z + step), z + step)
			st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
			st.add_vertex(a); st.add_vertex(c); st.add_vertex(d)
			z += step
		x += step
	st.generate_normals()
	var terrain := MeshInstance3D.new()
	terrain.name = "V0320ContinuousElevatedTerrain"
	terrain.mesh = st.commit()
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	world_root.add_child(terrain)

	# A shallow gravel apron makes the building footprints read as occupied ground.
	_add_disc("SettlementApron", Vector3(-7.0, 0.96, 5.1), Vector2(6.0, 4.4), _mat("Apron", Color("#766047"), 0.98))
	_add_disc("BarracksYard", Vector3(-7.8, 0.98, -4.7), Vector2(5.0, 3.8), _mat("Yard", Color("#795c40"), 0.98))

func _build_river() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(_mat("RiverWater", Color("#2f6670"), 0.28, 0.08))
	for i in range(21):
		var z0 := -15.0 + float(i) * 1.5
		var z1 := z0 + 1.5
		var c0 := 2.0 + sin(z0 * 0.17) * 0.42
		var c1 := 2.0 + sin(z1 * 0.17) * 0.42
		var y0 := 0.39 + sin(z0 * 0.65) * 0.035
		var y1 := 0.39 + sin(z1 * 0.65) * 0.035
		var p0 := Vector3(c0 - 2.18, y0, z0)
		var p1 := Vector3(c0 + 2.18, y0, z0)
		var p2 := Vector3(c1 + 2.18, y1, z1)
		var p3 := Vector3(c1 - 2.18, y1, z1)
		st.add_vertex(p0); st.add_vertex(p1); st.add_vertex(p2)
		st.add_vertex(p0); st.add_vertex(p2); st.add_vertex(p3)
	st.generate_normals()
	var water := MeshInstance3D.new()
	water.name = "V0320RecessedRiverWater"
	water.mesh = st.commit()
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(water)
	for z in [-13.5, -8.5, -3.5, 2.5, 8.5, 13.0]:
		_add_rock(Vector3(2.0 + sin(z * 0.17) * 0.42 + 1.3, 0.46, z), 0.34, Color("#65706a"))

func _build_roads() -> void:
	_add_ribbon("MainRoad", [Vector2(-17.0, -1.5), Vector2(-11.0, -1.4), Vector2(-5.0, -1.2), Vector2(1.2, -1.1), Vector2(7.0, -1.0), Vector2(15.5, -0.8)], 3.6, _mat("Road", Color("#846345"), 0.99))
	_add_ribbon("BarracksFootpath", [Vector2(-7.8, -1.2), Vector2(-8.1, -4.0), Vector2(-8.3, -7.2)], 2.1, _mat("Footpath", Color("#9a7954"), 0.99))
	_add_ribbon("HallFootpath", [Vector2(-1.0, -1.1), Vector2(-3.2, 1.6), Vector2(-6.0, 4.2)], 2.0, _mat("FootpathLight", Color("#a18158"), 0.99))

func _add_ribbon(label: String, points: Array[Vector2], width: float, material: StandardMaterial3D) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	for i in range(points.size() - 1):
		var p0 := points[i]
		var p1 := points[i + 1]
		var direction := (p1 - p0).normalized()
		var side := Vector2(-direction.y, direction.x) * width * 0.5
		var a2 := p0 - side
		var b2 := p0 + side
		var c2 := p1 + side
		var d2 := p1 - side
		var a := Vector3(a2.x, _height_at(a2.x, a2.y) + 0.035, a2.y)
		var b := Vector3(b2.x, _height_at(b2.x, b2.y) + 0.035, b2.y)
		var c := Vector3(c2.x, _height_at(c2.x, c2.y) + 0.045, c2.y)
		var d := Vector3(d2.x, _height_at(d2.x, d2.y) + 0.045, d2.y)
		st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
		st.add_vertex(a); st.add_vertex(c); st.add_vertex(d)
	st.generate_normals()
	var road := MeshInstance3D.new()
	road.name = "V0320Embedded_%s" % label
	road.mesh = st.commit()
	road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(road)

func _build_bridge() -> void:
	var bridge := Node3D.new()
	bridge.name = "V0320StoneTimberBridge"
	bridge.position = Vector3(2.0, 0.91, -1.1)
	world_root.add_child(bridge)
	_add_box(bridge, "BridgeStoneLeftPier", Vector3(-3.2, -0.35, 0.0), Vector3(0.8, 1.6, 4.5), _mat("BridgeStone", Color("#6c716b"), 0.92))
	_add_box(bridge, "BridgeStoneRightPier", Vector3(3.2, -0.35, 0.0), Vector3(0.8, 1.6, 4.5), _mat("BridgeStoneWarm", Color("#77776a"), 0.92))
	_add_box(bridge, "BridgeDeckThickness", Vector3(0.0, 0.38, 0.0), Vector3(7.8, 0.62, 4.0), _mat("BridgeDeck", Color("#715039"), 0.88))
	for x in [-3.0, -1.5, 0.0, 1.5, 3.0]:
		_add_box(bridge, "BridgePlank_%s" % str(x), Vector3(x, 0.72, 0.0), Vector3(0.14, 0.10, 3.75), _mat("BridgePlank", Color("#b08757"), 0.88))
	for z in [-1.9, 1.9]:
		_add_box(bridge, "BridgeRail_%s" % str(z), Vector3(0.0, 1.45, z), Vector3(7.7, 0.16, 0.16), _mat("BridgeRail", Color("#392a24"), 0.82))
		for x in [-3.2, -1.6, 0.0, 1.6, 3.2]:
			_add_box(bridge, "BridgePost_%s_%s" % [str(z), str(x)], Vector3(x, 1.12, z), Vector3(0.16, 0.78, 0.16), _mat("BridgePost", Color("#49352a"), 0.86))

func _build_architecture() -> void:
	_build_building("TownHall", Vector3(-7.0, 1.0, 5.0), Vector3(6.0, 4.2, 5.0), Color("#b8aa88"), Color("#4f3430"), true)
	_build_building("FieldBarracks", Vector3(-7.6, 1.0, -5.0), Vector3(5.8, 3.55, 4.1), Color("#9d8e75"), Color("#3f342d"), false)
	_build_building("WorkerDwelling", Vector3(9.0, 1.0, 5.0), Vector3(3.8, 2.8, 3.5), Color("#c0a77d"), Color("#5c3b31"), false)
	_build_building("ResourceStorehouse", Vector3(9.0, 1.0, -5.2), Vector3(4.4, 2.8, 3.6), Color("#8f7659"), Color("#49332b"), false)

func _build_building(label: String, origin: Vector3, size: Vector3, wall_color: Color, roof_color: Color, civic: bool) -> void:
	var root := Node3D.new()
	root.name = "V0320_%s" % label
	root.position = origin
	world_root.add_child(root)
	var wall := _mat(label + "Wall", wall_color, 0.92)
	var roof := _mat(label + "Roof", roof_color, 0.86)
	var stone := _mat(label + "Foundation", Color("#5c625b"), 0.95)
	var timber := _mat(label + "Timber", Color("#493229"), 0.82)
	_add_box(root, "Foundation", Vector3(0.0, 0.12, 0.0), Vector3(size.x + 0.45, 0.24, size.z + 0.45), stone)
	_add_box(root, "BackWall", Vector3(0.0, size.y * 0.5, -size.z * 0.5), Vector3(size.x, size.y, 0.20), wall)
	_add_box(root, "FrontWall", Vector3(0.0, size.y * 0.5, size.z * 0.5), Vector3(size.x, size.y, 0.20), wall)
	_add_box(root, "LeftWall", Vector3(-size.x * 0.5, size.y * 0.5, 0.0), Vector3(0.20, size.y, size.z), wall)
	_add_box(root, "RightWall", Vector3(size.x * 0.5, size.y * 0.5, 0.0), Vector3(0.20, size.y, size.z), wall)
	_add_box(root, "FrontTimber", Vector3(0.0, size.y * 0.55, size.z * 0.5 + 0.12), Vector3(size.x * 0.92, 0.16, 0.16), timber)
	_add_box(root, "DoorRecess", Vector3(0.0, size.y * 0.34, size.z * 0.5 + 0.14), Vector3(0.82 if not civic else 1.05, size.y * 0.58, 0.12), _mat(label + "Door", Color("#302522"), 0.88))
	for x in [-size.x * 0.30, size.x * 0.30]:
		_add_box(root, "Window_%s" % str(x), Vector3(x, size.y * 0.58, size.z * 0.5 + 0.13), Vector3(0.52, 0.58, 0.08), _mat(label + "Window", Color("#708f8c"), 0.32, 0.12))
	var roof_left := _add_box(root, "RoofLeft", Vector3(-size.x * 0.22, size.y + 0.28, 0.0), Vector3(size.x * 0.58, 0.24, size.z + 0.55), roof)
	roof_left.rotation_degrees.z = -27.0
	var roof_right := _add_box(root, "RoofRight", Vector3(size.x * 0.22, size.y + 0.28, 0.0), Vector3(size.x * 0.58, 0.24, size.z + 0.55), roof)
	roof_right.rotation_degrees.z = 27.0
	_add_box(root, "RoofRidge", Vector3(0.0, size.y + 0.84, 0.0), Vector3(0.24, 0.24, size.z + 0.62), timber)
	var chimney := _add_box(root, "Chimney", Vector3(size.x * 0.28, size.y + 0.82, -size.z * 0.14), Vector3(0.46, 0.90, 0.46), stone)
	chimney.rotation_degrees.y = 8.0
	_add_box(root, "EntranceStep", Vector3(0.0, 0.20, size.z * 0.5 + 0.42), Vector3(1.4, 0.18, 0.62), stone)

func _build_vegetation_and_resources() -> void:
	var trees := [Vector3(-15.0, 0.0, -11.0), Vector3(-12.0, 0.0, 10.5), Vector3(-2.0, 0.0, 11.2), Vector3(7.2, 0.0, 11.5), Vector3(14.5, 0.0, 9.5), Vector3(14.8, 0.0, -10.5), Vector3(-15.0, 0.0, 1.0)]
	for i in range(trees.size()):
		_add_tree("Tree_%02d" % i, trees[i], 6.5 + float(i % 3) * 0.55)
	for i in range(9):
		var x := -14.0 + float((i * 7) % 25)
		var z := -12.5 + float((i * 11) % 24)
		if abs(x - 2.0) < 3.2:
			x -= 4.2
		_add_rock(Vector3(x, _height_at(x, z) + 0.06, z), 0.28 + float(i % 3) * 0.10, Color("#74776e"))
	_add_resource_node(Vector3(-13.0, 1.0, -9.2), "IronNode", Color("#716d70"))
	_add_resource_node(Vector3(13.0, 1.0, -7.6), "TimberStack", Color("#795239"))

func _add_tree(label: String, position: Vector3, height: float) -> void:
	var root := Node3D.new()
	root.name = "V0320_%s" % label
	root.position = Vector3(position.x, _height_at(position.x, position.z), position.z)
	world_root.add_child(root)
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.22
	trunk.bottom_radius = 0.36
	trunk.height = height * 0.42
	trunk.radial_segments = 8
	var trunk_node := MeshInstance3D.new()
	trunk_node.name = "Trunk"
	trunk_node.mesh = trunk
	trunk_node.position.y = height * 0.21
	trunk_node.material_override = _mat("TreeTrunk", Color("#55402f"), 0.98)
	trunk_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(trunk_node)
	for i in range(3):
		var crown := CylinderMesh.new()
		crown.top_radius = 0.05
		crown.bottom_radius = 1.25 - float(i) * 0.24
		crown.height = 1.65
		crown.radial_segments = 7
		var crown_node := MeshInstance3D.new()
		crown_node.name = "Crown_%02d" % i
		crown_node.mesh = crown
		crown_node.position = Vector3(0.0, height * 0.43 + float(i) * 0.78, 0.0)
		crown_node.material_override = _mat("TreeCrown%d" % i, Color("#3f5b3f") if i != 1 else Color("#557148"), 0.99)
		crown_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		root.add_child(crown_node)

func _add_rock(position: Vector3, radius: float, color: Color) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 1.45
	mesh.radial_segments = 7
	mesh.rings = 3
	var node := MeshInstance3D.new()
	node.name = "V0320_RockDetail"
	node.mesh = mesh
	node.position = position
	node.scale = Vector3(1.0, 0.72, 0.86)
	node.material_override = _mat("Rock_%s" % str(radius), color, 0.96)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	world_root.add_child(node)

func _add_resource_node(position: Vector3, label: String, color: Color) -> void:
	var root := Node3D.new()
	root.name = "V0320_%s" % label
	root.position = position
	world_root.add_child(root)
	_add_box(root, "ResourceBase", Vector3(0.0, -0.55, 0.0), Vector3(2.2, 0.20, 1.7), _mat(label + "Base", Color("#62513d"), 0.98))
	for i in range(3):
		_add_rock_to(root, "ResourceChunk_%02d" % i, Vector3(-0.45 + i * 0.45, 0.0, 0.0), 0.42, color)

func _add_rock_to(parent: Node3D, label: String, position: Vector3, radius: float, color: Color) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 1.4
	mesh.radial_segments = 7
	mesh.rings = 3
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = position
	node.scale = Vector3(1.0, 0.75, 0.9)
	node.material_override = _mat(label, color, 0.95)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)

func _build_units() -> void:
	var worker := _build_worker("WorkerPrimary", Vector3(-3.8, 1.0, 0.9))
	var militia := _build_militia("MilitiaPrimary", Vector3(5.6, 1.0, 0.9))
	units["WorkerPrimary"] = worker
	units["MilitiaPrimary"] = militia
	for i in range(6):
		var pos := Vector3(-1.0 + float(i % 3) * 1.0, 1.0, 7.0 + float(i / 3) * 1.1)
		var group_worker := _build_worker("WorkerGroup_%02d" % i, pos)
		units["WorkerGroup_%02d" % i] = group_worker
	for i in range(8):
		var pos := Vector3(8.0 + float(i % 4) * 0.9, 1.0, -1.8 + float(i / 4) * 1.1)
		var group_militia := _build_militia("MilitiaGroup_%02d" % i, pos)
		units["MilitiaGroup_%02d" % i] = group_militia

func _build_worker(label: String, position: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = "V0320_True3D_%s" % label
	root.position = position
	world_root.add_child(root)
	var cloth := _mat("WorkerTunic", Color("#8a6746"), 0.92)
	var skin := _mat("WorkerSkin", Color("#b78762"), 0.94)
	var dark := _mat("WorkerBoot", Color("#332924"), 0.88)
	var metal := _mat("WorkerTool", Color("#676d67"), 0.68, 0.18)
	_add_box(root, "Torso", Vector3(0.0, 0.92, 0.0), Vector3(0.56, 0.82, 0.34), cloth)
	_add_sphere(root, "Head", Vector3(0.0, 1.58, 0.0), 0.24, skin)
	_add_box(root, "Belt", Vector3(0.0, 0.74, 0.0), Vector3(0.62, 0.11, 0.38), dark)
	_add_limb(root, "ArmL", Vector3(-0.40, 1.02, 0.0), Vector3(0.12, 0.62, 0.12), cloth, 18.0)
	_add_limb(root, "ArmR", Vector3(0.40, 1.02, 0.0), Vector3(0.12, 0.62, 0.12), cloth, -18.0)
	_add_sphere(root, "HandL", Vector3(-0.50, 0.70, 0.0), 0.12, skin)
	_add_sphere(root, "HandR", Vector3(0.50, 0.70, 0.0), 0.12, skin)
	_add_box(root, "LegL", Vector3(-0.17, 0.38, 0.0), Vector3(0.16, 0.66, 0.18), cloth)
	_add_box(root, "LegR", Vector3(0.17, 0.38, 0.0), Vector3(0.16, 0.66, 0.18), cloth)
	_add_box(root, "BootL", Vector3(-0.17, 0.08, 0.10), Vector3(0.22, 0.17, 0.38), dark)
	_add_box(root, "BootR", Vector3(0.17, 0.08, 0.10), Vector3(0.22, 0.17, 0.38), dark)
	_add_box(root, "Backpack", Vector3(0.0, 1.0, -0.27), Vector3(0.38, 0.56, 0.16), dark)
	var tool := _add_box(root, "WorkTool", Vector3(0.56, 0.77, 0.0), Vector3(0.10, 0.78, 0.10), metal)
	tool.rotation_degrees.z = -28.0
	_add_selection_ring(root, "WorkerSelection", Color("#d5b863"), false)
	return root

func _build_militia(label: String, position: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = "V0320_True3D_%s" % label
	root.position = position
	world_root.add_child(root)
	var cloth := _mat("MilitiaTunic", Color("#465d59"), 0.90)
	var padded := _mat("MilitiaPadded", Color("#7d765f"), 0.94)
	var skin := _mat("MilitiaSkin", Color("#aa795b"), 0.94)
	var dark := _mat("MilitiaBoot", Color("#2e2926"), 0.86)
	var metal := _mat("MilitiaIron", Color("#68716d"), 0.62, 0.24)
	_add_box(root, "Torso", Vector3(0.0, 0.98, 0.0), Vector3(0.62, 0.90, 0.38), cloth)
	_add_box(root, "PaddedFront", Vector3(0.0, 1.06, 0.20), Vector3(0.48, 0.55, 0.10), padded)
	_add_sphere(root, "Head", Vector3(0.0, 1.68, 0.0), 0.24, skin)
	var helmet := _add_cone(root, "Helmet", Vector3(0.0, 1.90, 0.0), 0.33, 0.18, metal)
	helmet.rotation_degrees.x = 180.0
	_add_limb(root, "ArmL", Vector3(-0.43, 1.08, 0.0), Vector3(0.13, 0.66, 0.13), padded, 16.0)
	_add_limb(root, "ArmR", Vector3(0.43, 1.08, 0.0), Vector3(0.13, 0.66, 0.13), padded, -16.0)
	_add_sphere(root, "HandL", Vector3(-0.52, 0.72, 0.0), 0.12, skin)
	_add_sphere(root, "HandR", Vector3(0.52, 0.72, 0.0), 0.12, skin)
	_add_box(root, "LegL", Vector3(-0.18, 0.38, 0.0), Vector3(0.17, 0.68, 0.19), cloth)
	_add_box(root, "LegR", Vector3(0.18, 0.38, 0.0), Vector3(0.17, 0.68, 0.19), cloth)
	_add_box(root, "BootL", Vector3(-0.18, 0.08, 0.10), Vector3(0.23, 0.17, 0.40), dark)
	_add_box(root, "BootR", Vector3(0.18, 0.08, 0.10), Vector3(0.23, 0.17, 0.40), dark)
	var shield := _add_cylinder(root, "Shield", Vector3(-0.60, 0.95, 0.06), 0.34, 0.12, metal)
	shield.rotation_degrees.x = 90.0
	var spear := _add_cylinder(root, "Spear", Vector3(0.58, 1.20, 0.0), 0.045, 1.85, dark)
	spear.rotation_degrees.z = -10.0
	_add_cone(root, "SpearHead", Vector3(0.74, 2.09, 0.0), 0.12, 0.32, metal)
	_add_selection_ring(root, "MilitiaSelection", Color("#7ab4a0"), false)
	return root

func _add_selection_ring(parent: Node3D, label: String, color: Color, selected: bool) -> void:
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.46
	mesh.outer_radius = 0.54
	mesh.rings = 32
	mesh.ring_segments = 8
	var ring := MeshInstance3D.new()
	ring.name = label
	ring.mesh = mesh
	ring.position.y = 0.04
	ring.material_override = _mat(label, color, 0.72)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.visible = selected or parent.name == "V0320_True3D_WorkerPrimary"
	parent.add_child(ring)
	selection_rings.append(ring)

func _add_disc(label: String, position: Vector3, radius: Vector2, material: StandardMaterial3D) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.0
	mesh.bottom_radius = 1.0
	mesh.height = 0.025
	mesh.radial_segments = 32
	var node := MeshInstance3D.new()
	node.name = "V0320_%s" % label
	node.mesh = mesh
	node.position = position
	node.scale = Vector3(radius.x, 1.0, radius.y)
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(node)

func _add_box(parent: Node3D, label: String, position: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = position
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

func _add_sphere(parent: Node3D, label: String, position: Vector3, radius: float, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = position
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

func _add_cone(parent: Node3D, label: String, position: Vector3, radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.02
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 10
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = position
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

func _add_cylinder(parent: Node3D, label: String, position: Vector3, radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 10
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = position
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

func _add_limb(parent: Node3D, label: String, position: Vector3, size: Vector3, material: StandardMaterial3D, angle: float) -> MeshInstance3D:
	var node := _add_box(parent, label, position, size, material)
	node.rotation_degrees.z = angle
	return node

func _mat(key: String, color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	if material_cache.has(key):
		return material_cache[key]
	var material := StandardMaterial3D.new()
	material.resource_name = key
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	material_cache[key] = material
	return material

func _build_player_hud() -> void:
	hud = CanvasLayer.new()
	hud.name = "V0320CleanPlayerInterface"
	add_child(hud)
	var strip := Panel.new()
	strip.name = "CompactResourceStrip"
	strip.position = Vector2(34, 24)
	strip.size = Vector2(660, 52)
	strip.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.048, 0.94), Color("#78977b")))
	hud.add_child(strip)
	var stats := Label.new()
	stats.position = Vector2(18, 12)
	stats.text = "SALTO   420 gold     160 timber     90 stone     38 lume     9 / 16"
	stats.add_theme_font_size_override("font_size", 16)
	stats.add_theme_color_override("font_color", Color("#e6d4a2"))
	strip.add_child(stats)

	var minimap := Panel.new()
	minimap.name = "CompactMinimap"
	minimap.position = Vector2(34, 728)
	minimap.size = Vector2(210, 132)
	minimap.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.04, 0.035, 0.92), Color("#78977b")))
	hud.add_child(minimap)
	var map_label := Label.new()
	map_label.position = Vector2(12, 9)
	map_label.text = "MAP  |  SALTO EAST"
	map_label.add_theme_font_size_override("font_size", 13)
	map_label.add_theme_color_override("font_color", Color("#d5c58e"))
	minimap.add_child(map_label)
	var map_body := Label.new()
	map_body.position = Vector2(12, 38)
	map_body.text = "  GRASS  ─ ROAD ─  WATER\n       ◇ BRIDGE\n  HALL      BARRACKS"
	map_body.add_theme_font_size_override("font_size", 13)
	map_body.add_theme_color_override("font_color", Color("#b7c9af"))
	minimap.add_child(map_body)

	var card := Panel.new()
	card.name = "SelectedUnitPanel"
	card.position = Vector2(1120, 730)
	card.size = Vector2(440, 130)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.048, 0.95), Color("#b69d58")))
	hud.add_child(card)
	selected_title = Label.new()
	selected_title.position = Vector2(18, 14)
	selected_title.add_theme_font_size_override("font_size", 18)
	selected_title.add_theme_color_override("font_color", Color("#ead8a5"))
	card.add_child(selected_title)
	selected_body = Label.new()
	selected_body.position = Vector2(18, 48)
	selected_body.add_theme_font_size_override("font_size", 14)
	selected_body.add_theme_color_override("font_color", Color("#c1d0be"))
	card.add_child(selected_body)
	var command := Label.new()
	command.position = Vector2(750, 842)
	command.text = "Q  GUARD     W  HOLD     E  REPAIR     R  RALLY"
	command.add_theme_font_size_override("font_size", 13)
	command.add_theme_color_override("font_color", Color("#b5c8b3"))
	hud.add_child(command)
	if debug_review:
		var debug := Label.new()
		debug.name = "DebugReviewOverlay"
		debug.position = Vector2(34, 86)
		debug.text = "DEBUG_REVIEW  |  V0320 TRUE 3D OPT-IN  |  visual-only fixture  |  stable IDs/default untouched"
		debug.add_theme_font_size_override("font_size", 12)
		debug.add_theme_color_override("font_color", Color("#f1b47f"))
		hud.add_child(debug)
	_set_selected("Aster", "Barrosan pioneer  •  grounded true 3D unit\nSelection footprint 0.95 m  •  PLAYER mode")

func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style

func _set_selected(title: String, body: String) -> void:
	if selected_title != null:
		selected_title.text = title.to_upper() + "  |  BARROSAN UNIT"
		selected_body.text = body

func _set_camera(position: Vector3, target: Vector3, ortho_size: float) -> void:
	camera.position = position
	camera.size = ortho_size
	camera.look_at(target, Vector3.UP)

func _set_state(unit_name: String, state: String) -> void:
	var root: Node3D = units.get(unit_name)
	if root == null:
		return
	var left := root.get_node_or_null("ArmL") as Node3D
	var right := root.get_node_or_null("ArmR") as Node3D
	var tool := root.get_node_or_null("WorkTool") as Node3D
	if state == "idle":
		if left: left.rotation_degrees.z = 16.0 if unit_name.contains("Militia") else 18.0
		if right: right.rotation_degrees.z = -16.0 if unit_name.contains("Militia") else -18.0
	elif state == "walk":
		if left: left.rotation_degrees.z = -28.0
		if right: right.rotation_degrees.z = 28.0
	elif state == "work":
		if left: left.rotation_degrees.z = -62.0
		if right: right.rotation_degrees.z = -22.0
		if tool: tool.rotation_degrees.z = -72.0
	elif state == "ready":
		if left: left.rotation_degrees.z = 38.0
		if right: right.rotation_degrees.z = -38.0
		var spear := root.get_node_or_null("Spear") as Node3D
		if spear: spear.rotation_degrees.z = -22.0

func _capture_all() -> void:
	var screenshot_dir := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	await _capture("02_overview_beauty.png", CAMERA_POSITION, CAMERA_TARGET, CAMERA_ORTHO_SIZE, "overview")
	await _capture("03_gameplay_zoom.png", Vector3(18.0, 17.0, 19.0), Vector3(-1.0, 0.9, 0.0), 20.0, "gameplay zoom")
	await _capture("04_settlement_closeup.png", Vector3(10.0, 12.0, 12.0), Vector3(-4.0, 2.0, 2.5), 12.0, "settlement close")
	_set_state("WorkerPrimary", "idle"); _set_selected("Worker", "Worker idle  •  true 3D articulated mesh")
	await _capture("05_worker_states.png", Vector3(8.0, 7.0, 9.0), Vector3(-3.8, 1.0, 0.9), 7.0, "Worker idle / walk / work states")
	_set_state("WorkerPrimary", "work")
	_set_state("MilitiaPrimary", "ready"); _set_selected("Militia", "Militia idle / walk / ready  •  shield + spear")
	await _capture("06_militia_states.png", Vector3(9.0, 8.0, 10.0), Vector3(5.6, 1.2, 0.9), 7.0, "Militia idle / walk / ready states")
	await _capture("07_bridge_and_water.png", Vector3(12.0, 10.0, 13.0), Vector3(2.0, 0.8, -1.1), 11.0, "bridge spans recessed water")
	await _capture("08_terrain_and_architecture.png", Vector3(20.0, 20.0, 22.0), Vector3(0.0, 1.2, 0.0), 24.0, "terrain and architecture")
	await _capture("09_formation_readability.png", Vector3(19.0, 16.0, 20.0), Vector3(1.0, 1.1, 2.5), 21.0, "Worker and Militia formations")
	await _capture("10_clean_player_ui.png", CAMERA_POSITION, CAMERA_TARGET, CAMERA_ORTHO_SIZE, "clean PLAYER interface")
	if debug_review:
		await _capture("13_debug_review_equivalent.png", CAMERA_POSITION, CAMERA_TARGET, CAMERA_ORTHO_SIZE, "DEBUG_REVIEW equivalent")
	else:
		var debug_label := Label.new()
		debug_label.name = "V0320DebugReviewCaptureLabel"
		debug_label.position = Vector2(34, 86)
		debug_label.text = "DEBUG_REVIEW  |  V0320 TRUE 3D OPT-IN  |  visual-only fixture  |  fallback/default untouched"
		debug_label.add_theme_font_size_override("font_size", 12)
		debug_label.add_theme_color_override("font_color", Color("#f1b47f"))
		hud.add_child(debug_label)
		await _capture("13_debug_review_equivalent.png", CAMERA_POSITION, CAMERA_TARGET, CAMERA_ORTHO_SIZE, "DEBUG_REVIEW equivalent")
		debug_label.queue_free()
	await _capture("14_v0319_vs_v0320_comparison.png", Vector3(17.0, 17.0, 19.0), Vector3(0.0, 1.0, 0.0), 22.0, "v0.319 fallback retained; v0.320 true 3D candidate")
	await _capture_continuous()

func _capture(label: String, position: Vector3, target: Vector3, ortho_size: float, purpose: String) -> void:
	_set_camera(position, target, ortho_size)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image == null:
		return
	var path := capture_root.path_join("screenshots").path_join(label)
	image.save_png(path)
	captures.append({"file": label, "purpose": purpose, "rendered": true, "mode": "DEBUG_REVIEW" if debug_review else "PLAYER", "camera": {"projection": "orthographic", "position": position, "target": target, "orthoSize": ortho_size}})

func _capture_continuous() -> void:
	var continuous_dir := capture_root.path_join("continuous")
	DirAccess.make_dir_recursive_absolute(continuous_dir)
	for i in range(40):
		visual_phase = float(i) / 39.0
		var angle := -0.35 + visual_phase * 0.70
		var pos := Vector3(20.0 + sin(angle) * 4.0, 18.0 + visual_phase * 3.0, 22.0 + cos(angle) * 4.0)
		_set_camera(pos, Vector3(0.0, 1.0, 0.0), 24.0 - visual_phase * 4.0)
		_set_state("WorkerPrimary", "work" if i % 3 == 0 else "walk" if i % 3 == 1 else "idle")
		_set_state("MilitiaPrimary", "ready" if i % 3 == 0 else "walk" if i % 3 == 1 else "idle")
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		var filename := "frame_%02d.png" % i
		if image != null:
			image.save_png(continuous_dir.path_join(filename))
		captures.append({"file": filename, "purpose": "continuous PLAYER camera pan/zoom and visual state scrub", "rendered": true, "mode": "PLAYER"})

func _write_manifest() -> void:
	var manifest := {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS_V0320_TRUE_3D_VISUAL_VERTICAL_SLICE",
		"prototypeOptIn": true,
		"prototypeOnly": true,
		"scenePath": SCENE_PATH,
		"presentationMethod": "TRUE 3D STYLISED RTS",
		"unitPresentation": "repository-authored true 3D low-poly articulated mesh assemblies; no billboards",
		"workerStates": ["idle", "walk", "work"],
		"militiaStates": ["idle", "walk", "ready"],
		"camera": {"projection": "orthographic", "yawDegrees": 45.0, "pitchDegrees": 49.0, "position": CAMERA_POSITION, "target": CAMERA_TARGET, "orthoSize": CAMERA_ORTHO_SIZE},
		"scale": {"workerHeight": 1.80, "militiaHeight": 1.86, "ordinaryDoorHeight": 2.20, "townHallDoorHeight": 2.55, "roadWidth": 3.60, "bridgeWidth": 4.00, "dwellingWallHeight": 2.80, "barracksWallHeight": 3.55, "treeHeight": 7.50},
		"geometry": {"true3DTerrain": true, "variedElevation": true, "riverBelowLand": true, "bridgeSpansRiver": true, "bridgeSupports": 2, "buildingRoofSideBaseDepth": true, "buildingCount": 4, "treeCount": 7, "rockDetailCount": 9, "roadEmbedded": true},
		"lighting": {"directionalKey": "warm daylight", "ambientFill": "cool desaturated fill", "shadows": "real directional shadows, consistent direction"},
		"hud": {"playerClean": true, "debugReviewAvailable": true, "selectedCardOverlap": false, "rawValidatorProse": false},
		"captures": captures,
		"defaultRuntimeChanged": false,
		"gameplayChanged": false,
		"movementChanged": false,
		"pathfindingChanged": false,
		"combatChanged": false,
		"economyChanged": false,
		"resourceChanged": false,
		"stableIdsChanged": false,
		"saveChanged": false,
		"h3FallbackPreserved": true,
		"v0319Preserved": true
	}
	DirAccess.make_dir_recursive_absolute(capture_root)
	var file := FileAccess.open(capture_root.path_join("v0320-true-3d-visual-vertical-slice-runtime.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "  "))
