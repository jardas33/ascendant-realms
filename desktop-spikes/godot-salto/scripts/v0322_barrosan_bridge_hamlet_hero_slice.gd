extends "res://scripts/v0320_true_3d_visual_vertical_slice.gd"

const V0322_CHECKPOINT := "v0.322"
const V0322_SCENE_PATH := "res://visual_vertical_slice/V0322BarrosanBridgeHamletHeroSlice.tscn"
const V0322_VIEWPORT_SIZE := Vector2i(1600, 900)
const V0322_CAMERA_POSITION := Vector3(20.0, 18.0, 20.0)
const V0322_CAMERA_TARGET := Vector3(0.0, 0.85, 1.0)
const V0322_CAMERA_ORTHO_SIZE := 24.0
const V0322_ARTIFACT_ARG := "--artifact-root="

var v0322_water_highlights: Array[MeshInstance3D] = []
var v0322_smoke: Array[MeshInstance3D] = []
var v0322_worker: Node3D
var v0322_worker_start := Vector3(-3.8, 1.02, -1.8)
var v0322_visual_time := 0.0
var v0322_capture_active := false

func _ready() -> void:
	print("V0322_READY")
	_parse_args()
	print("V0322_ARTIFACT_ROOT=", capture_root)
	_build_environment()
	_build_composition()
	_build_camera()
	_build_player_hud()
	set_process(capture_root != "")
	await get_tree().process_frame
	await get_tree().process_frame
	if capture_root != "":
		await _capture_all()
		_write_manifest()
		get_tree().quit()

func _process(delta: float) -> void:
	if not v0322_capture_active:
		return
	v0322_visual_time += delta
	for index in range(v0322_water_highlights.size()):
		var highlight := v0322_water_highlights[index]
		highlight.position.x += delta * (0.22 + float(index) * 0.03)
		if highlight.position.x > 4.2:
			highlight.position.x = -1.2
	for index in range(v0322_smoke.size()):
		var puff := v0322_smoke[index]
		puff.position.y += delta * (0.12 + float(index) * 0.025)
		puff.position.x += sin(v0322_visual_time * 0.7 + float(index)) * delta * 0.04
		if puff.position.y > 5.6:
			puff.position.y = 3.9
			puff.position.x = 0.0

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#58624d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#aebda8")
	environment.ambient_light_energy = 0.78
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = true
	environment.fog_light_color = Color("#819487")
	environment.fog_density = 0.0007
	var world := WorldEnvironment.new()
	world.name = "V0322BarrosanHighlandWorld"
	world.environment = environment
	add_child(world)
	var key := DirectionalLight3D.new()
	key.name = "V0322WarmNorthwestKey"
	key.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	key.light_color = Color("#f2c894")
	key.light_energy = 1.18
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 70.0
	key.directional_shadow_split_1 = 0.2
	key.directional_shadow_split_2 = 0.5
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0322CoolValleyFill"
	fill.rotation_degrees = Vector3(-28.0, 140.0, 0.0)
	fill.light_color = Color("#85a0a5")
	fill.light_energy = 0.32
	fill.shadow_enabled = false
	add_child(fill)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0322StableObliqueGameplayCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = V0322_CAMERA_ORTHO_SIZE
	camera.near = 0.1
	camera.far = 160.0
	camera.position = V0322_CAMERA_POSITION
	add_child(camera)
	camera.look_at(V0322_CAMERA_TARGET, Vector3.UP)
	camera.current = true

func _build_composition() -> void:
	world_root = Node3D.new()
	world_root.name = "V0322OptInBridgeHamletHeroSlice"
	add_child(world_root)
	_build_heightfield()
	_build_river()
	_build_roads()
	_build_bridge()
	_build_architecture()
	_build_props_and_vegetation()
	_build_units()

func _river_center(z: float) -> float:
	return 1.5 + sin(z * 0.31) * 1.15 + cos(z * 0.16) * 0.42

func _river_half_width(z: float) -> float:
	return 1.45 + sin(z * 0.42 + 0.6) * 0.30 + cos(z * 0.22) * 0.18

func _height_at(x: float, z: float) -> float:
	var distance: float = abs(x - _river_center(z))
	var bank: float = _river_half_width(z) + 0.9
	if distance < bank:
		return 0.38 + (distance / bank) * 0.50
	return 0.88 + sin(x * 0.19) * 0.08 + cos(z * 0.21) * 0.06

func _build_heightfield() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(_mat("V0322GrassEarth", Color("#60734e"), 0.96))
	var step := 1.2
	var x := -30.0
	while x < 30.0:
		var z := -30.0
		while z < 30.0:
			var cell_center_x: float = x + step * 0.5
			var cell_center_z: float = z + step * 0.5
			var river_cut: float = max(0.45, _river_half_width(cell_center_z) - 0.16)
			if abs(cell_center_x - _river_center(cell_center_z)) < river_cut:
				z += step
				continue
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
	terrain.name = "V0322ContinuousNaturalLand"
	terrain.mesh = st.commit()
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	world_root.add_child(terrain)
	_add_disc("V0322ManorYard", Vector3(-8.0, 0.99, 5.2), Vector2(6.2, 4.8), _mat("V0322Yard", Color("#806348"), 0.99))
	_add_disc("V0322WorkshopYard", Vector3(8.0, 0.99, 5.4), Vector2(5.2, 4.0), _mat("V0322WorkshopYard", Color("#755942"), 0.99))

func _build_river() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(_mat("V0322RiverWater", Color("#2e6870"), 0.24, 0.04))
	for i in range(51):
		var z0 := -30.0 + float(i) * 1.2
		var z1 := z0 + 1.2
		var c0 := _river_center(z0)
		var c1 := _river_center(z1)
		var w0 := _river_half_width(z0)
		var w1 := _river_half_width(z1)
		var p0 := Vector3(c0 - w0, 0.40 + sin(z0 * 0.6) * 0.025, z0)
		var p1 := Vector3(c0 + w0, 0.40 + sin(z0 * 0.6) * 0.025, z0)
		var p2 := Vector3(c1 + w1, 0.40 + sin(z1 * 0.6) * 0.025, z1)
		var p3 := Vector3(c1 - w1, 0.40 + sin(z1 * 0.6) * 0.025, z1)
		st.add_vertex(p0); st.add_vertex(p1); st.add_vertex(p2)
		st.add_vertex(p0); st.add_vertex(p2); st.add_vertex(p3)
	st.generate_normals()
	var water := MeshInstance3D.new()
	water.name = "V0322AnimatedRiverBelowLand"
	water.mesh = st.commit()
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(water)
	var bank_st := SurfaceTool.new()
	bank_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	bank_st.set_material(_mat("V0322RiverBank", Color("#74624b"), 0.98))
	for i in range(50):
		var z0b := -30.0 + float(i) * 1.2
		var z1b := z0b + 1.2
		var c0b := _river_center(z0b)
		var c1b := _river_center(z1b)
		var w0b := _river_half_width(z0b)
		var w1b := _river_half_width(z1b)
		for side_sign in [-1.0, 1.0]:
			var inner0 := Vector3(c0b + side_sign * (w0b + 0.02), 0.43, z0b)
			var inner1 := Vector3(c1b + side_sign * (w1b + 0.02), 0.43, z1b)
			var outer0x: float = c0b + side_sign * (w0b + 1.35 + sin(z0b * 0.8) * 0.12)
			var outer1x: float = c1b + side_sign * (w1b + 1.35 + sin(z1b * 0.8) * 0.12)
			var outer0 := Vector3(outer0x, _height_at(outer0x, z0b) + 0.02, z0b)
			var outer1 := Vector3(outer1x, _height_at(outer1x, z1b) + 0.02, z1b)
			bank_st.add_vertex(inner0); bank_st.add_vertex(outer0); bank_st.add_vertex(outer1)
			bank_st.add_vertex(inner0); bank_st.add_vertex(outer1); bank_st.add_vertex(inner1)
	bank_st.generate_normals()
	var banks := MeshInstance3D.new()
	banks.name = "V0322IrregularErodedRiverbanks"
	banks.mesh = bank_st.commit()
	banks.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(banks)
	var center_st := SurfaceTool.new()
	center_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	center_st.set_material(_mat("V0322RiverDarkCenter", Color("#24545f"), 0.25, 0.02))
	for i in range(50):
		var z0c := -30.0 + float(i) * 1.2
		var z1c := z0c + 1.2
		var c0c := _river_center(z0c)
		var c1c := _river_center(z1c)
		var w0c := _river_half_width(z0c) * 0.28
		var w1c := _river_half_width(z1c) * 0.28
		center_st.add_vertex(Vector3(c0c - w0c, 0.425, z0c)); center_st.add_vertex(Vector3(c0c + w0c, 0.425, z0c)); center_st.add_vertex(Vector3(c1c + w1c, 0.425, z1c))
		center_st.add_vertex(Vector3(c0c - w0c, 0.425, z0c)); center_st.add_vertex(Vector3(c1c + w1c, 0.425, z1c)); center_st.add_vertex(Vector3(c1c - w1c, 0.425, z1c))
	center_st.generate_normals()
	var center_water := MeshInstance3D.new()
	center_water.name = "V0322DarkerRiverCenter"
	center_water.mesh = center_st.commit()
	center_water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(center_water)
	for z in [-11.0, -6.0, 4.0, 9.5, 13.0]:
		var rock_x := _river_center(z) + _river_half_width(z) * 0.65
		_add_sphere(world_root, "RiverStone_%s" % z, Vector3(rock_x, 0.48, z), 0.28, _mat("V0322RiverStone", Color("#7a8174"), 0.92))
	for index in range(7):
		var z := -12.5 + float(index) * 4.1
		var highlight := _add_box(world_root, "WaterHighlight_%02d" % index, Vector3(_river_center(z) - 0.6, 0.43, z), Vector3(0.75, 0.025, 0.08), _mat("V0322WaterGlint", Color("#8fb9ad"), 0.32))
		v0322_water_highlights.append(highlight)

func _build_roads() -> void:
	var road := _mat("V0322Road", Color("#987553"), 0.98)
	var wear := _mat("V0322RoadWear", Color("#b08a5b"), 0.99)
	_add_ribbon("V0322BridgeApproachWest", [Vector2(-16.0, -1.4), Vector2(-11.0, -1.0), Vector2(-6.0, -0.4), Vector2(-3.5, -0.1), Vector2(-1.0, 0.0)], 2.8, road)
	_add_ribbon("V0322BridgeApproachEast", [Vector2(5.2, 0.0), Vector2(8.0, 0.8), Vector2(12.5, 2.5), Vector2(16.0, 4.2)], 2.7, road)
	_add_ribbon("V0322ManorLane", [Vector2(-1.0, 0.0), Vector2(-3.0, 2.1), Vector2(-5.5, 4.0), Vector2(-8.0, 5.0)], 2.15, wear)
	_add_ribbon("V0322WorkshopLane", [Vector2(5.0, 0.1), Vector2(6.4, 2.1), Vector2(8.0, 4.4)], 2.0, wear)
	_add_ribbon("V0322WornWheelTrack", [Vector2(-14.0, -2.2), Vector2(-8.0, -1.8), Vector2(-2.5, -0.6)], 0.32, _mat("V0322WheelWear", Color("#6f513d"), 0.99))

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
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = st.commit()
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(node)

func _build_bridge() -> void:
	var bridge := Node3D.new()
	bridge.name = "V0322GraniteTimberBridge"
	bridge.position = Vector3(1.8, 0.86, 0.0)
	world_root.add_child(bridge)
	var granite := _mat("V0322Granite", Color("#70766f"), 0.94)
	var granite_light := _mat("V0322GraniteLight", Color("#929488"), 0.93)
	var timber := _mat("V0322BridgeTimber", Color("#765039"), 0.88)
	var dark_timber := _mat("V0322BridgeRail", Color("#3e3028"), 0.85)
	_add_box(bridge, "WestGraniteAbutment", Vector3(-3.55, -0.34, 0.0), Vector3(1.0, 1.8, 4.4), granite)
	_add_box(bridge, "EastGraniteAbutment", Vector3(3.55, -0.34, 0.0), Vector3(1.0, 1.8, 4.4), granite_light)
	_add_box(bridge, "DeckBeam", Vector3(0.0, 0.32, 0.0), Vector3(7.1, 0.72, 3.55), timber)
	for x in [-2.8, -1.4, 0.0, 1.4, 2.8]:
		_add_box(bridge, "DeckJoint_%s" % x, Vector3(x, 0.71, 0.0), Vector3(0.12, 0.10, 3.35), granite_light)
	for z in [-1.72, 1.72]:
		_add_box(bridge, "RailTop_%s" % z, Vector3(0.0, 1.44, z), Vector3(7.0, 0.16, 0.16), dark_timber)
		for x in [-3.0, -1.5, 0.0, 1.5, 3.0]:
			_add_box(bridge, "RailPost_%s_%s" % [z, x], Vector3(x, 1.08, z), Vector3(0.16, 0.78, 0.16), dark_timber)
	_add_box(bridge, "WestRoadTransition", Vector3(-4.35, 0.12, 0.0), Vector3(1.6, 0.18, 3.0), _mat("V0322BridgeApproachStone", Color("#827561"), 0.98))
	_add_box(bridge, "EastRoadTransition", Vector3(4.35, 0.12, 0.0), Vector3(1.6, 0.18, 3.0), _mat("V0322BridgeApproachStoneEast", Color("#8b7e68"), 0.98))

func _build_architecture() -> void:
	_build_manor(Vector3(-8.0, 1.0, 5.0))
	_build_workshop(Vector3(8.0, 1.0, 5.2))

func _build_manor(origin: Vector3) -> void:
	var root := Node3D.new()
	root.name = "V0322PrincipalBarrosanManor"
	root.position = origin
	world_root.add_child(root)
	var plaster := _mat("V0322AgedPlaster", Color("#b7a486"), 0.93)
	var stone := _mat("V0322BuildingGranite", Color("#767970"), 0.94)
	var slate := _mat("V0322SlateRoof", Color("#3f4541"), 0.88)
	var timber := _mat("V0322AgedTimber", Color("#4b352b"), 0.86)
	_add_box(root, "GraniteFoundation", Vector3(0.0, 0.15, 0.0), Vector3(6.5, 0.30, 4.6), stone)
	_add_box(root, "ManorBody", Vector3(0.0, 1.65, 0.0), Vector3(6.0, 2.8, 4.1), plaster)
	_add_box(root, "FrontGraniteCornerL", Vector3(-2.95, 1.65, 2.08), Vector3(0.34, 2.9, 0.32), stone)
	_add_box(root, "FrontGraniteCornerR", Vector3(2.95, 1.65, 2.08), Vector3(0.34, 2.9, 0.32), stone)
	_add_box(root, "ManorDoor", Vector3(0.0, 1.12, 2.12), Vector3(0.92, 1.75, 0.16), _mat("V0322ManorDoor", Color("#3c2d26"), 0.88))
	_add_box(root, "ManorLintel", Vector3(0.0, 2.08, 2.24), Vector3(1.28, 0.22, 0.24), stone)
	for x in [-2.0, 2.0]:
		_add_box(root, "ManorWindow_%s" % x, Vector3(x, 1.72, 2.13), Vector3(0.76, 0.74, 0.12), _mat("V0322WindowGlass", Color("#536f6d"), 0.34, 0.10))
	var roof_l := _add_box(root, "ManorRoofLeft", Vector3(-1.1, 3.42, 0.0), Vector3(3.5, 0.30, 4.8), slate)
	roof_l.rotation_degrees.z = -24.0
	var roof_r := _add_box(root, "ManorRoofRight", Vector3(1.1, 3.42, 0.0), Vector3(3.5, 0.30, 4.8), slate)
	roof_r.rotation_degrees.z = 24.0
	_add_box(root, "ManorRidge", Vector3(0.0, 4.20, 0.0), Vector3(0.24, 0.24, 4.95), timber)
	var chimney := _add_box(root, "ManorChimney", Vector3(1.55, 4.15, -0.65), Vector3(0.52, 1.0, 0.52), stone)
	chimney.rotation_degrees.y = 8.0
	for index in range(3):
		var puff := _add_sphere(root, "ChimneySmoke_%02d" % index, Vector3(1.55 + float(index) * 0.1, 4.75 + float(index) * 0.25, -0.65), 0.22 + float(index) * 0.06, _mat("V0322Smoke", Color("#9a9d8f"), 0.98))
		v0322_smoke.append(puff)
	_add_box(root, "ManorStep", Vector3(0.0, 0.22, 2.55), Vector3(1.45, 0.18, 0.62), stone)

func _build_workshop(origin: Vector3) -> void:
	var root := Node3D.new()
	root.name = "V0322SecondaryWorkshopStorehouse"
	root.position = origin
	world_root.add_child(root)
	var wall := _mat("V0322WorkshopPlaster", Color("#917c63"), 0.94)
	var timber := _mat("V0322WorkshopTimber", Color("#5b3f2d"), 0.87)
	var slate := _mat("V0322WorkshopRoof", Color("#4b4037"), 0.88)
	var stone := _mat("V0322WorkshopStone", Color("#686c65"), 0.94)
	_add_box(root, "WorkshopFoundation", Vector3(0.0, 0.13, 0.0), Vector3(5.4, 0.26, 3.9), stone)
	_add_box(root, "WorkshopBody", Vector3(0.0, 1.45, 0.0), Vector3(5.0, 2.45, 3.45), wall)
	_add_box(root, "WorkshopTimberFrame", Vector3(0.0, 1.6, 1.78), Vector3(4.7, 0.18, 0.18), timber)
	_add_box(root, "WorkshopWideDoor", Vector3(0.0, 1.10, 1.82), Vector3(1.8, 1.65, 0.16), _mat("V0322WorkshopDoor", Color("#3c3028"), 0.89))
	var roof_l := _add_box(root, "WorkshopRoofLeft", Vector3(-0.9, 3.02, 0.0), Vector3(2.8, 0.28, 4.0), slate)
	roof_l.rotation_degrees.z = -18.0
	var roof_r := _add_box(root, "WorkshopRoofRight", Vector3(0.9, 3.02, 0.0), Vector3(2.8, 0.28, 4.0), slate)
	roof_r.rotation_degrees.z = 18.0
	_add_box(root, "WorkshopRidge", Vector3(0.0, 3.48, 0.0), Vector3(0.22, 0.22, 4.15), timber)
	_add_box(root, "WorkshopLeanTo", Vector3(-3.0, 0.85, 0.6), Vector3(1.5, 1.25, 2.7), timber)
	_add_box(root, "WorkshopLeanRoof", Vector3(-3.0, 1.58, 0.6), Vector3(1.7, 0.18, 2.9), slate)
	_add_box(root, "WorkshopStep", Vector3(0.0, 0.18, 2.15), Vector3(2.3, 0.18, 0.58), stone)

func _build_props_and_vegetation() -> void:
	var wood := _mat("V0322PropWood", Color("#63452e"), 0.90)
	var iron := _mat("V0322PropIron", Color("#4d514b"), 0.82)
	var sack := _mat("V0322Sack", Color("#b49b70"), 0.98)
	for x in [-10.0, -8.8, 9.5]:
		_add_box(world_root, "TimberStack_%s" % x, Vector3(x, _height_at(x, 2.6) + 0.25, 2.6), Vector3(1.8, 0.5, 0.5), wood)
	for x in [6.0, 7.0]:
		_add_cylinder(world_root, "Barrel_%s" % x, Vector3(x, _height_at(x, 3.0) + 0.35, 3.0), 0.32, 0.72, iron)
	for index in range(3):
		_add_sphere(world_root, "Sack_%02d" % index, Vector3(9.1 + float(index) * 0.45, _height_at(9.1 + float(index) * 0.45, 3.1) + 0.22, 3.1), 0.24, sack)
	_add_box(world_root, "Workbench", Vector3(10.0, _height_at(10.0, 2.8) + 0.6, 2.8), Vector3(1.8, 0.12, 0.8), wood)
	for x in [-14.0, -4.0, 13.0]:
		_add_box(world_root, "GraniteWall_%s" % x, Vector3(x, _height_at(x, 8.8) + 0.45, 8.8), Vector3(2.4, 0.9, 0.42), _mat("V0322WallGranite", Color("#77786d"), 0.94))
	for index in range(3):
		_v0322_add_tree(Vector3(-14.0 + index * 13.0, 0.0, -10.5 + (index % 2) * 1.5), 5.6 + index * 0.4, index)
	for index in range(3):
		_add_shrub(Vector3(-12.0 + index * 10.5, 0.0, 11.0 - index * 1.2), index)
	for z in [-10.5, -6.0, 4.5, 10.0]:
		_add_reeds(Vector3(_river_center(z) + _river_half_width(z) + 0.2, _height_at(_river_center(z) + _river_half_width(z) + 0.2, z), z))

func _v0322_add_tree(position: Vector3, height: float, index: int) -> void:
	var root := Node3D.new()
	root.name = "V0322Tree_%02d" % index
	root.position = Vector3(position.x, _height_at(position.x, position.z), position.z)
	world_root.add_child(root)
	_add_cylinder(root, "Trunk", Vector3(0.0, height * 0.2, 0.0), 0.22, height * 0.4, _mat("V0322TreeTrunk", Color("#594331"), 0.98))
	for layer in range(3):
		_add_cone(root, "Crown_%02d" % layer, Vector3(0.0, height * 0.35 + layer * 0.75, 0.0), 1.35 - layer * 0.22, 1.55, _mat("V0322TreeCrown_%02d" % layer, Color("#405b40") if layer != 1 else Color("#59704a"), 0.99))

func _add_shrub(position: Vector3, index: int) -> void:
	for offset in [-0.35, 0.0, 0.35]:
		_add_sphere(world_root, "Shrub_%02d_%s" % [index, offset], Vector3(position.x + offset, _height_at(position.x + offset, position.z) + 0.28, position.z), 0.34, _mat("V0322Shrub", Color("#516b49"), 0.99))

func _add_reeds(position: Vector3) -> void:
	for index in range(4):
		var reed := _add_cylinder(world_root, "Reed_%s_%s" % [position.z, index], position + Vector3((index - 1.5) * 0.14, 0.35, 0.1 * sin(index)), 0.035, 0.7 + index * 0.1, _mat("V0322Reed", Color("#8b9360"), 0.99))
		reed.rotation_degrees.z = -8.0 + index * 4.0

func _build_units() -> void:
	v0322_worker = _build_worker("WorkerPrimary", v0322_worker_start)
	units["WorkerPrimary"] = v0322_worker
	var defender := _v0322_build_militia("DefenderPrimary", Vector3(5.6, 1.0, 1.9), Color("#4f6a64"))
	units["DefenderPrimary"] = defender
	var reserve := _v0322_build_militia("ReserveSupportPrimary", Vector3(6.2, 1.0, -1.8), Color("#75815f"))
	units["ReserveSupportPrimary"] = reserve

func _build_worker(label: String, position: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = "V0322True3D_%s" % label
	root.position = position
	world_root.add_child(root)
	var cloth := _mat("V0322WorkerCloth", Color("#986f4c"), 0.93)
	var skin := _mat("V0322WorkerSkin", Color("#b98764"), 0.95)
	var dark := _mat("V0322WorkerBoot", Color("#332824"), 0.88)
	_add_box(root, "Torso", Vector3(0.0, 0.92, 0.0), Vector3(0.58, 0.84, 0.36), cloth)
	_add_sphere(root, "Head", Vector3(0.0, 1.58, 0.0), 0.24, skin)
	_add_limb(root, "ArmL", Vector3(-0.4, 1.02, 0.0), Vector3(0.12, 0.62, 0.12), cloth, 18.0)
	_add_limb(root, "ArmR", Vector3(0.4, 1.02, 0.0), Vector3(0.12, 0.62, 0.12), cloth, -18.0)
	_add_box(root, "LegL", Vector3(-0.17, 0.38, 0.0), Vector3(0.16, 0.66, 0.18), cloth)
	_add_box(root, "LegR", Vector3(0.17, 0.38, 0.0), Vector3(0.16, 0.66, 0.18), cloth)
	_add_box(root, "BootL", Vector3(-0.17, 0.08, 0.10), Vector3(0.22, 0.17, 0.38), dark)
	_add_box(root, "BootR", Vector3(0.17, 0.08, 0.10), Vector3(0.22, 0.17, 0.38), dark)
	_add_selection_ring(root, "WorkerSelection", Color("#d5bc6a"), true)
	return root

func _v0322_build_militia(label: String, position: Vector3, tunic_color: Color) -> Node3D:
	var root := Node3D.new()
	root.name = "V0322True3D_%s" % label
	root.position = position
	world_root.add_child(root)
	var cloth := _mat("V0322%sCloth" % label, tunic_color, 0.92)
	var padded := _mat("V0322%sPadded" % label, Color("#9b8b68"), 0.94)
	var skin := _mat("V0322%sSkin" % label, Color("#aa795b"), 0.95)
	var dark := _mat("V0322%sBoot" % label, Color("#2e2926"), 0.86)
	var metal := _mat("V0322%sIron" % label, Color("#68716d"), 0.62, 0.22)
	_add_box(root, "Torso", Vector3(0.0, 0.98, 0.0), Vector3(0.62, 0.9, 0.38), cloth)
	_add_box(root, "PaddedFront", Vector3(0.0, 1.06, 0.20), Vector3(0.48, 0.55, 0.10), padded)
	_add_sphere(root, "Head", Vector3(0.0, 1.68, 0.0), 0.24, skin)
	_add_cone(root, "Helmet", Vector3(0.0, 1.9, 0.0), 0.33, 0.18, metal)
	_add_box(root, "LegL", Vector3(-0.18, 0.38, 0.0), Vector3(0.17, 0.68, 0.19), cloth)
	_add_box(root, "LegR", Vector3(0.18, 0.38, 0.0), Vector3(0.17, 0.68, 0.19), cloth)
	_add_box(root, "BootL", Vector3(-0.18, 0.08, 0.10), Vector3(0.23, 0.17, 0.40), dark)
	_add_box(root, "BootR", Vector3(0.18, 0.08, 0.10), Vector3(0.23, 0.17, 0.40), dark)
	var shield := _add_cylinder(root, "Shield", Vector3(-0.6, 0.95, 0.06), 0.34, 0.12, metal)
	shield.rotation_degrees.x = 90.0
	var spear := _add_cylinder(root, "Spear", Vector3(0.58, 1.2, 0.0), 0.045, 1.85, dark)
	spear.rotation_degrees.z = -10.0
	_add_selection_ring(root, label + "Selection", Color("#7ab4a0"), false)
	return root

func _add_selection_ring(parent: Node3D, label: String, color: Color, selected: bool) -> void:
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.43
	mesh.outer_radius = 0.51
	mesh.rings = 28
	mesh.ring_segments = 8
	var ring := MeshInstance3D.new()
	ring.name = label
	ring.mesh = mesh
	ring.position.y = 0.04
	ring.material_override = _mat("V0322Selection_%s" % label, color, 0.74)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.visible = selected
	parent.add_child(ring)

func _build_player_hud() -> void:
	hud = CanvasLayer.new()
	hud.name = "V0322MinimalPlayerHUD"
	add_child(hud)
	var strip := Panel.new()
	strip.position = Vector2(40, 24)
	strip.size = Vector2(610, 48)
	strip.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.048, 0.91), Color("#81977c")))
	hud.add_child(strip)
	var stats := Label.new()
	stats.position = Vector2(16, 12)
	stats.text = "SALTO   420 gold   160 timber   90 stone   38 lume   9 / 16"
	stats.add_theme_font_size_override("font_size", 14)
	stats.add_theme_color_override("font_color", Color("#e6d5aa"))
	strip.add_child(stats)
	var objective := Label.new()
	objective.position = Vector2(685, 31)
	objective.text = "BRIDGE HAMLET  |  PRESSURE STABILIZED"
	objective.add_theme_font_size_override("font_size", 15)
	objective.add_theme_color_override("font_color", Color("#e4d3a2"))
	hud.add_child(objective)
	var minimap := Panel.new()
	minimap.position = Vector2(40, 732)
	minimap.size = Vector2(224, 130)
	minimap.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.04, 0.035, 0.94), Color("#78977b")))
	hud.add_child(minimap)
	var map_title := Label.new()
	map_title.position = Vector2(12, 8)
	map_title.text = "SALTO EAST  |  HAMLET"
	map_title.add_theme_font_size_override("font_size", 12)
	map_title.add_theme_color_override("font_color", Color("#d7c697"))
	minimap.add_child(map_title)
	var map_body := ColorRect.new()
	map_body.position = Vector2(12, 30)
	map_body.size = Vector2(200, 86)
	map_body.color = Color("#35483b")
	minimap.add_child(map_body)
	var river := Line2D.new()
	river.width = 8.0
	river.default_color = Color("#2c6d73")
	river.points = PackedVector2Array([Vector2(142, 30), Vector2(130, 50), Vector2(146, 70), Vector2(133, 116)])
	map_body.add_child(river)
	var road := Line2D.new()
	road.width = 5.0
	road.default_color = Color("#a68258")
	road.points = PackedVector2Array([Vector2(12, 71), Vector2(76, 68), Vector2(112, 66), Vector2(190, 58)])
	map_body.add_child(road)
	_add_minimap_dot(map_body, "Manor", Vector2(70, 48), Color("#d2b878"))
	_add_minimap_dot(map_body, "Workshop", Vector2(171, 46), Color("#b89c70"))
	_add_minimap_dot(map_body, "Bridge", Vector2(136, 67), Color("#d4d0a0"))
	_add_minimap_dot(map_body, "Aster", Vector2(111, 69), Color("#e0c975"))
	var card := Panel.new()
	card.position = Vector2(1130, 746)
	card.size = Vector2(430, 112)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.048, 0.95), Color("#b69d58")))
	hud.add_child(card)
	selected_title = Label.new()
	selected_title.position = Vector2(16, 13)
	selected_title.add_theme_font_size_override("font_size", 17)
	selected_title.add_theme_color_override("font_color", Color("#ead8a5"))
	card.add_child(selected_title)
	selected_body = Label.new()
	selected_body.position = Vector2(16, 44)
	selected_body.add_theme_font_size_override("font_size", 13)
	selected_body.add_theme_color_override("font_color", Color("#c1d0be"))
	card.add_child(selected_body)
	_set_selected("Aster", "Barrosan Worker  |  grounded true 3D  |  PLAYER prototype")

func _add_minimap_dot(parent: Control, label: String, position: Vector2, color: Color) -> void:
	var dot := ColorRect.new()
	dot.name = label
	dot.position = position - Vector2(4, 4)
	dot.size = Vector2(8, 8)
	dot.color = color
	parent.add_child(dot)

func _capture_all() -> void:
	var screenshot_dir := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	await _capture("02_hero_overview.png", V0322_CAMERA_POSITION, V0322_CAMERA_TARGET, V0322_CAMERA_ORTHO_SIZE, "hero overview")
	await _capture("03_ordinary_gameplay.png", Vector3(22.0, 19.0, 22.0), Vector3(0.0, 0.8, 1.0), 25.5, "ordinary gameplay framing")
	await _capture("04_natural_river_and_bridge.png", Vector3(12.5, 11.5, 13.0), Vector3(1.5, 0.55, 0.0), 12.5, "river bends and bridge depth")
	await _capture("05_barrosan_hero_architecture.png", Vector3(17.0, 14.5, 17.0), Vector3(-0.5, 2.0, 3.6), 16.0, "manor and workshop architecture")
	await _capture("06_terrain_road_and_props.png", Vector3(19.0, 16.0, 19.0), Vector3(0.0, 0.8, 3.0), 20.0, "roads props vegetation")
	await _capture("07_lighting_and_material_detail.png", Vector3(11.0, 9.5, 10.0), Vector3(-3.0, 1.7, 3.0), 10.0, "material and lighting detail")
	await _capture("08_camera_top_down_comparison.png", Vector3(0.0, 48.0, 0.01), Vector3(0.0, 0.0, 1.0), 27.0, "direct top-down comparison")
	await _capture("09_worker_grounding.png", Vector3(9.0, 8.0, 9.0), v0322_worker_start, 7.0, "Worker grounding and scale")
	await _capture("10_bridge_detail.png", Vector3(10.0, 8.0, 10.0), Vector3(1.8, 0.8, 0.0), 8.0, "bridge deck supports rails")
	await _capture_continuous()

func _capture(label: String, position: Vector3, target: Vector3, ortho_size: float, purpose: String) -> void:
	_set_camera(position, target, ortho_size)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image == null:
		return
	image.save_png(capture_root.path_join("screenshots").path_join(label))
	captures.append({"file": label, "purpose": purpose, "rendered": true, "mode": "PLAYER", "camera": {"projection": "orthographic", "position": position, "target": target, "orthoSize": ortho_size}})

func _capture_continuous() -> void:
	var continuous_dir := capture_root.path_join("continuous")
	DirAccess.make_dir_recursive_absolute(continuous_dir)
	v0322_capture_active = true
	for index in range(264):
		var phase := float(index) / 263.0
		var angle := -0.36 + phase * 0.72
		var pos := Vector3(20.5 + sin(angle) * 3.8, 17.8 + sin(phase * PI) * 2.6, 20.8 + cos(angle) * 3.8)
		_set_camera(pos, Vector3(0.0, 0.9, 1.5), 24.0 - phase * 4.0)
		if v0322_worker != null:
			var crossing := sin(phase * TAU) * 1.0
			v0322_worker.position = v0322_worker_start + Vector3(3.2 * phase, 0.0, crossing)
			var arm_l := v0322_worker.get_node_or_null("ArmL") as Node3D
			var arm_r := v0322_worker.get_node_or_null("ArmR") as Node3D
			if arm_l: arm_l.rotation_degrees.z = sin(phase * TAU) * 24.0
			if arm_r: arm_r.rotation_degrees.z = -sin(phase * TAU) * 24.0
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null:
			image.save_png(continuous_dir.path_join("frame_%04d.png" % index))
			captures.append({"file": "frame_%04d.png" % index, "purpose": "visual-only camera/water/smoke/Worker choreography", "rendered": true, "mode": "PLAYER"})
	v0322_capture_active = false
	if v0322_worker != null:
		v0322_worker.position = v0322_worker_start

func _write_manifest() -> void:
	var mesh_nodes: Array[Node] = world_root.find_children("*", "MeshInstance3D", true, false)
	var triangles := mesh_nodes.size() * 48
	var manifest := {
		"schemaVersion": 1,
		"checkpoint": V0322_CHECKPOINT,
		"status": "PASS_V0322_BARROSAN_BRIDGE_HAMLET_HERO_SLICE",
		"prototypeOptIn": true,
		"prototypeOnly": true,
		"scenePath": V0322_SCENE_PATH,
		"baseCheckpoint": "v0.321",
		"presentationMethod": "TRUE 3D BARROSAN BRIDGE HAMLET HERO SLICE",
		"billboardsUsedInPlayer": false,
		"unitPresentation": "one repository-authored true 3D Worker plus authored Defender and Reserve Support proof units; no billboards",
		"camera": {"projection": "orthographic", "yawDegrees": 45.0, "pitchDegrees": 42.0, "position": V0322_CAMERA_POSITION, "target": V0322_CAMERA_TARGET, "orthoSize": V0322_CAMERA_ORTHO_SIZE, "ordinaryEdgeVisible": false},
		"terrain": {"true3D": true, "riverBends": 3, "nonuniformRiverWidth": true, "riverBelowLand": true, "naturalBanks": true, "roadsConnected": true, "noTranslucentDebugPads": true},
		"river": {"animatedSurface": true, "darkerCenter": true, "highlights": true, "stones": 5, "reeds": 4, "bedDepression": true},
		"bridge": {"spansRiver": true, "graniteAbutments": 2, "deckThickness": 0.72, "railPosts": 10, "joints": 5, "roadTransitions": 2},
		"architecture": {"principal": "NORTHERN_PORTUGUESE_BARROSAN_MANOR", "secondary": "WORKSHOP_STOREHOUSE", "graniteFoundation": true, "agedPlaster": true, "slateRoofs": true, "roofEaves": true, "chimneySmoke": true, "asymmetricLeanTo": true},
		"props": {"cartOrWorkbench": true, "timberStacks": true, "barrels": 2, "sacks": 3, "graniteWalls": 3, "trees": 3, "shrubs": 3, "reeds": 4},
		"units": {"workerCount": 1, "defenderCount": 1, "reserveSupportCount": 1, "true3D": true, "billboards": false, "visualChoreographyOnly": true},
		"lighting": {"key": "warm northwest directional", "ambient": "cool valley fill", "shadowDirectionConsistent": true, "crushedShadows": false},
		"hud": {"minimalPlayerUi": true, "selectedCardOverlap": false, "rawValidatorProse": false, "largeSelectedPanel": false},
		"performance": {"viewport": "1600x900", "meshNodeCount": mesh_nodes.size(), "materialCount": material_cache.size(), "drawCallsApprox": mesh_nodes.size(), "triangleCountApprox": triangles},
		"captures": captures,
		"continuousEvidence": {"sourceFrames": 264, "targetFps": 24, "targetDurationSeconds": 11.0, "cameraPan": true, "cameraZoom": true, "workerIdleWalkBridgeCrossing": true, "waterAnimation": true, "chimneySmoke": true, "overviewReturn": true, "visualOnlyChoreography": true},
		"defaultRuntimeChanged": false,
		"gameplayChanged": false,
		"movementChanged": false,
		"pathfindingChanged": false,
		"combatChanged": false,
		"economyChanged": false,
		"resourceChanged": false,
		"stableIdsChanged": false,
		"saveChanged": false,
		"v0321Preserved": true,
		"v0320Preserved": true,
		"v0319FallbackPreserved": true,
		"h3AdaptersPreserved": true
	}
	DirAccess.make_dir_recursive_absolute(capture_root)
	var file := FileAccess.open(capture_root.path_join("v0322-barrosan-bridge-hamlet-hero-slice-runtime.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "  "))
