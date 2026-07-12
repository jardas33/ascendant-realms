extends "res://scripts/salto_v0306_route_c_barrosan_convergence.gd"

const V0307_CHECKPOINT := "v0.307"
const V0307_SCENE_PATH := "res://scenes/salto_v0307_route_c_production_viability_slice.tscn"
const V0307_CAMERA_OBLIQUE := Vector3(24.0, 23.0, 27.0)
const V0307_CAMERA_ALTERNATE := Vector3(-22.0, 20.0, 25.0)
const V0307_CAMERA_TOP_DOWN := Vector3(0.0, 28.0, 0.01)
const V0307_TARGET := Vector3(0.0, 0.25, 2.0)
const V0307_ORTHO_SIZE := 28.0

var v0307_world: WorldEnvironment
var v0307_hud: CanvasLayer
var v0307_note: Label
var v0307_candidate_roots: Dictionary = {}
var v0307_candidate_rings: Dictionary = {}
var v0307_authored_nodes: Array[String] = []
var v0307_atmosphere_enabled := true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#34413d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#b3c0b5")
	environment.ambient_light_energy = 0.86
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = true
	environment.fog_light_color = Color("#9aaa9e")
	environment.fog_light_energy = 0.22
	environment.fog_density = 0.0011
	v0307_world = WorldEnvironment.new()
	v0307_world.name = "V0307MountainHazeEnvironment"
	v0307_world.environment = environment
	add_child(v0307_world)

	var key := DirectionalLight3D.new()
	key.name = "V0307SoftMountainKey"
	key.rotation_degrees = Vector3(-48.0, -36.0, 0.0)
	key.light_color = Color("#e2d8bd")
	key.light_energy = 1.18
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 110.0
	key.directional_shadow_split_1 = 0.12
	key.directional_shadow_split_2 = 0.42
	add_child(key)

	var fill := DirectionalLight3D.new()
	fill.name = "V0307CoolMountainFill"
	fill.rotation_degrees = Vector3(-26.0, 142.0, 0.0)
	fill.light_color = Color("#86a5a5")
	fill.light_energy = 0.42
	fill.shadow_enabled = false
	add_child(fill)

	camera = Camera3D.new()
	camera.name = "V0307ProductionViabilityCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.1
	camera.far = 240.0
	camera.current = true
	add_child(camera)

func _tune_material(material: StandardMaterial3D) -> void:
	super._tune_material(material)
	match material.resource_name:
		"MAT_Grass": material.albedo_color = Color("#60765d")
		"MAT_Earth": material.albedo_color = Color("#665345")
		"MAT_RoadDirt": material.albedo_color = Color("#766b5c")
		"MAT_Stone": material.albedo_color = Color("#737d79")
		"MAT_StoneLight": material.albedo_color = Color("#a3a395")
		"MAT_StoneWarm": material.albedo_color = Color("#887663")
		"MAT_StoneDark": material.albedo_color = Color("#343b39")
		"MAT_StoneMoss": material.albedo_color = Color("#5e705e")
		"MAT_Roof": material.albedo_color = Color("#5a5350")
		"MAT_RoofDark": material.albedo_color = Color("#302e2e")
		"MAT_Wood": material.albedo_color = Color("#66564b")
		"MAT_WoodDark": material.albedo_color = Color("#302b29")
		"MAT_WoodWeathered": material.albedo_color = Color("#796b5c")
		"MAT_EaveDark": material.albedo_color = Color("#242423")
		"MAT_IronDark": material.albedo_color = Color("#2d3637")
	material.roughness = max(material.roughness, 0.72)

func _build_composition() -> void:
	composition_root = Node3D.new()
	composition_root.name = "V0307RouteCProductionViabilityMicroSlice"
	add_child(composition_root)
	_build_authored_terrain()
	_build_authored_river()
	_build_converged_roads()
	_build_converged_bridge()
	_build_authored_support_building()
	_build_authored_dressing()
	_build_unit_strategy_bakeoff()

func _build_authored_terrain() -> void:
	var west := [Vector2(-18.0, -13.5), Vector2(-13.5, -16.0), Vector2(-3.0, -16.8), Vector2(1.42, -15.7), Vector2(1.42, 15.5), Vector2(-1.0, 16.2), Vector2(-11.0, 15.2), Vector2(-17.5, 10.5), Vector2(-19.0, 1.0)]
	var east := [Vector2(6.55, -15.7), Vector2(10.0, -15.5), Vector2(17.5, -11.5), Vector2(18.5, -2.0), Vector2(17.0, 8.5), Vector2(11.5, 14.5), Vector2(6.55, 15.7)]
	_add_extruded_terrain("V0307WestTerrainBase", west, -0.18, -1.05)
	_add_extruded_terrain("V0307EastTerrainBase", east, -0.18, -1.05)
	_add_authored_patch("V0307WestBankTerrace", [Vector3(-1.6, 0.05, -13.0), Vector3(1.20, 0.13, -11.3), Vector3(1.20, 0.05, -2.8), Vector3(-1.6, -0.02, -4.5)], -0.65, Color("#65725d"))
	_add_authored_patch("V0307EastBankTerrace", [Vector3(6.35, 0.02, -11.8), Vector3(9.8, 0.17, -10.6), Vector3(10.8, 0.08, -3.6), Vector3(6.35, -0.01, -2.0)], -0.62, Color("#66745f"))
	_add_authored_patch("V0307EastBridgeLanding", [Vector3(6.35, 0.02, -1.9), Vector3(9.3, 0.12, -1.1), Vector3(10.4, 0.20, 2.1), Vector3(8.0, 0.08, 4.0), Vector3(6.35, -0.02, 2.6)], -0.60, Color("#756653"))
	_add_authored_patch("V0307WestBridgeLanding", [Vector3(-1.6, 0.08, -1.8), Vector3(1.2, 0.02, -1.0), Vector3(1.2, 0.10, 3.0), Vector3(-0.2, 0.18, 4.8), Vector3(-1.6, 0.04, 3.0)], -0.60, Color("#756653"))
	_add_authored_patch("V0307SupportBuildingBench", [Vector3(8.55, 0.02, 5.0), Vector3(12.5, 0.10, 5.2), Vector3(13.0, 0.22, 8.0), Vector3(9.0, 0.06, 8.4)], -0.58, Color("#5f6d5d"))
	for config in [
		["V0307GrassTuftPatchA", Vector2(7.2, -7.4), Vector2(3.8, 1.2), -9.0, 0.08, Color("#72866a")],
		["V0307DryEarthPatchA", Vector2(9.0, 1.8), Vector2(3.8, 1.4), 12.0, 0.09, Color("#8b7259")],
		["V0307WetSoilPatchA", Vector2(6.8, 3.4), Vector2(2.4, 1.0), -20.0, 0.07, Color("#584d43")],
		["V0307GrassTuftPatchB", Vector2(-5.5, 10.8), Vector2(4.6, 1.3), 8.0, 0.08, Color("#6e8364")],
	]:
		_add_ellipse_patch(str(config[0]), config[1], config[2], float(config[3]), float(config[4]), config[5])
	for config in [
		["V0307EmbeddedRockA", Vector3(7.3, 0.08, -4.2), -14.0, 0.55],
		["V0307EmbeddedRockB", Vector3(9.6, 0.14, 2.9), 8.0, 0.48],
		["V0307EmbeddedRockC", Vector3(6.9, 0.03, 6.5), 22.0, 0.52],
		["V0307EmbeddedRockD", Vector3(-0.8, 0.02, 5.8), -8.0, 0.45],
	]:
		_place_prop("prop_rock_cluster", config[1], float(config[2]), float(config[3]))
		v0307_authored_nodes.append(str(config[0]))

func _add_authored_patch(label: String, corners: Array, skirt_y: float, color: Color) -> void:
	var vertices := PackedVector3Array()
	for corner in corners:
		vertices.append(corner)
	for corner in corners:
		vertices.append(Vector3(corner.x, skirt_y, corner.z))
	var indices := PackedInt32Array([0, 1, 2, 0, 2, 3])
	if corners.size() == 5:
		indices = PackedInt32Array([0, 1, 2, 0, 2, 3, 0, 3, 4])
	for index in range(corners.size()):
		var next := (index + 1) % corners.size()
		indices.append_array(PackedInt32Array([index, next, corners.size() + index, next, corners.size() + next, corners.size() + index]))
	_add_mesh_surface(label, vertices, indices, color, 0.96)
	v0307_authored_nodes.append(label)

func _build_authored_river() -> void:
	var centers := [Vector2(4.0, -15.0), Vector2(3.55, -12.0), Vector2(4.25, -9.0), Vector2(3.8, -6.0), Vector2(4.35, -3.2), Vector2(3.85, 0.0), Vector2(4.4, 3.0), Vector2(3.7, 6.2), Vector2(4.25, 9.4), Vector2(3.8, 12.2), Vector2(4.1, 15.0)]
	var widths := [3.2, 3.55, 3.05, 3.8, 3.2, 3.7, 3.15, 3.8, 3.25, 3.65, 3.2]
	_add_ribbon("V0307DeepChannel", centers, widths.map(func(value): return float(value) + 1.55), -0.40, Color("#283d40"), 0.98, "riverbank")
	_add_ribbon("V0307ShallowShelf", centers, widths.map(func(value): return float(value) + 0.78), -0.25, Color("#596b62"), 0.96, "riverbank")
	_add_ribbon("V0307WetStoneEdge", centers, widths.map(func(value): return float(value) + 0.30), -0.16, Color("#536965"), 0.88, "riverbank")
	_add_ribbon("V0307RiverWater", centers, widths, -0.52, Color("#24474c"), 0.18, "river")
	_add_ribbon("V0307FlowDirectionA", [Vector2(3.72, -13.4), Vector2(4.05, -10.0), Vector2(3.82, -6.2), Vector2(4.08, -2.1), Vector2(3.9, 2.1), Vector2(4.12, 6.1), Vector2(3.9, 10.4), Vector2(4.02, 13.8)], [0.16, 0.24, 0.12, 0.20, 0.14, 0.23, 0.13, 0.19], -0.49, Color("#7b9a96"), 0.38, "river")
	_add_ribbon("V0307FlowDirectionB", [Vector2(4.35, -11.8), Vector2(4.0, -8.0), Vector2(4.42, -4.0), Vector2(4.1, 0.2), Vector2(4.35, 4.5), Vector2(4.05, 8.6), Vector2(4.3, 12.1)], [0.10, 0.15, 0.11, 0.17, 0.09, 0.14, 0.10], -0.485, Color("#aec0b5"), 0.25, "river")
	_add_ribbon("V0307FoamDisturbance", [Vector2(2.65, -1.2), Vector2(3.2, -0.9), Vector2(3.75, -1.0), Vector2(4.2, -0.75)], [0.08, 0.16, 0.10, 0.06], -0.475, Color("#b8c8bd"), 0.22, "river")
	for config in [
		[Vector3(1.7, -0.10, -7.1), -6.0, 0.36],
		[Vector3(6.6, -0.12, -3.8), 14.0, 0.42],
		[Vector3(1.5, -0.10, 6.8), 12.0, 0.40],
		[Vector3(6.5, -0.12, 9.2), -14.0, 0.38],
	]:
		_place_prop("prop_rock_cluster", config[0], float(config[1]), float(config[2]))
		v0307_authored_nodes.append("water_contact_rock")

func _build_converged_bridge() -> void:
	super._build_converged_bridge()
	var bridge := composition_root.get_node_or_null("V0306WeatheredBridge")
	if bridge != null:
		bridge.name = "V0307BridgeWithAuthoredLanding"
		_add_box_to(bridge, "V0307BridgeWetBeam", Vector3(4.0, 0.42, 0.0), Vector3(8.7, 0.12, 3.0), Color("#5b5149"), 0.92)
		_add_box_to(bridge, "V0307BridgeMossCapWest", Vector3(-0.55, 0.82, -1.62), Vector3(1.25, 0.08, 0.22), Color("#71826b"), 0.96)
		_add_box_to(bridge, "V0307BridgeMossCapEast", Vector3(8.55, 0.82, 1.62), Vector3(1.05, 0.08, 0.22), Color("#71826b"), 0.96)
		v0307_authored_nodes.append("V0307BridgeWithAuthoredLanding")

func _build_authored_support_building() -> void:
	var building := Node3D.new()
	building.name = "V0307AuthoredBarrosanUtilityHouse"
	building.position = Vector3(10.5, 0.0, 6.0)
	composition_root.add_child(building)
	for index in range(7):
		var angle := TAU * float(index) / 7.0
		_add_box_to(building, "FoundationStone_%02d" % index, Vector3(cos(angle) * 2.0, 0.18, sin(angle) * 1.42), Vector3(0.78, 0.38, 0.62), Color("#626864" if index % 2 else "#7a7b70"), 0.94).rotation_degrees.y = rad_to_deg(angle)
	_add_box_to(building, "UtilityRearWall", Vector3(0.0, 1.35, -1.16), Vector3(3.7, 2.35, 0.26), Color("#6d746f"), 0.95)
	_add_box_to(building, "UtilityLeftWall", Vector3(-1.72, 1.35, 0.0), Vector3(0.26, 2.35, 2.55), Color("#59625f"), 0.95)
	_add_box_to(building, "UtilityRightWall", Vector3(1.72, 1.35, 0.0), Vector3(0.26, 2.35, 2.55), Color("#7c8179"), 0.95)
	_add_box_to(building, "UtilityFrontWallLeft", Vector3(-0.95, 1.35, 1.16), Vector3(1.4, 2.35, 0.26), Color("#777d76"), 0.95)
	_add_box_to(building, "UtilityFrontWallRight", Vector3(0.95, 1.35, 1.16), Vector3(1.4, 2.35, 0.26), Color("#6b716c"), 0.95)
	_add_box_to(building, "UtilityDoorFrame", Vector3(0.0, 1.22, 1.29), Vector3(0.92, 2.12, 0.20), Color("#3b3e3b"), 0.86)
	_add_box_to(building, "UtilityDoor", Vector3(0.0, 1.18, 1.40), Vector3(0.62, 1.72, 0.10), Color("#4a4037"), 0.84)
	for side in [-1.0, 1.0]:
		_add_box_to(building, "UtilityFrontTimber_%s" % side, Vector3(side * 1.35, 1.45, 1.34), Vector3(0.16, 2.40, 0.18), Color("#343331"), 0.82)
		_add_box_to(building, "UtilityBrace_%s" % side, Vector3(side * 0.92, 1.65, 1.38), Vector3(0.16, 1.18, 0.20), Color("#4a4038"), 0.82).rotation_degrees.z = side * 32.0
	for window in [Vector3(-1.08, 1.45, 1.33), Vector3(1.08, 1.45, 1.33), Vector3(-1.86, 1.45, -0.38)]:
		_add_box_to(building, "UtilityWindow_%s" % str(window), window, Vector3(0.48, 0.46, 0.08), Color("#a6b4a3"), 0.68)
	_add_gabled_roof(building, "UtilitySlateGableRoof", Vector3(0.0, 2.75, 0.0), Vector3(4.25, 1.46, 3.20), Color("#4a4e4d"))
	for side in [-1.0, 1.0]:
		for index in range(6):
			var x: float = float(side) * (0.36 + float(index) * 0.29)
			var y: float = 3.28 - float(index) * 0.18
			var slate := _add_box_to(building, "SlateCourse_%s_%02d" % [side, index], Vector3(x, y, 0.0), Vector3(0.12, 0.07, 3.05), Color("#69706c" if index % 2 else "#555d5b"), 0.88)
			slate.rotation_degrees.z = -34.0 * side
	_add_box_to(building, "UtilityRidgeCap", Vector3(0.0, 3.50, 0.0), Vector3(0.20, 0.18, 3.38), Color("#303532"), 0.78)
	_add_box_to(building, "UtilityChimney", Vector3(-1.05, 3.62, -0.62), Vector3(0.48, 1.05, 0.48), Color("#575f5c"), 0.94)
	_add_box_to(building, "UtilityChimneyCap", Vector3(-1.05, 4.18, -0.62), Vector3(0.62, 0.12, 0.62), Color("#353a38"), 0.84)
	_add_box_to(building, "UtilityPorchBeam", Vector3(0.0, 2.22, 1.72), Vector3(2.4, 0.18, 0.18), Color("#353432"), 0.82)
	_add_box_to(building, "UtilityPorchRoof", Vector3(0.0, 2.46, 1.72), Vector3(2.65, 0.18, 1.05), Color("#555855"), 0.90)
	_add_ellipse_patch("UtilityMossFoot", Vector2(10.5, 6.0), Vector2(4.8, 3.7), -3.0, 0.035, Color("#5c705e"))
	v0307_authored_nodes.append("V0307AuthoredBarrosanUtilityHouse")

func _build_authored_dressing() -> void:
	for config in [
		["prop_tree", Vector3(-16.0, 0.0, -10.5), -8.0, 0.68],
		["prop_tree", Vector3(15.8, 0.0, -10.5), 12.0, 0.64],
		["prop_log_stack", Vector3(-15.8, 0.0, 9.8), -10.0, 0.46],
		["prop_crate_stack", Vector3(-14.0, 0.0, 8.4), 8.0, 0.48],
	]:
		_place_prop(str(config[0]), config[1], float(config[2]), float(config[3]))

func _build_unit_strategy_bakeoff() -> void:
	_add_u1(Vector3(-5.7, 0.10, 4.0))
	_add_u2(Vector3(-2.0, 0.10, 4.0))
	_add_u3(Vector3(1.7, 0.10, 4.0))
	_add_simple_unit("Defender", Vector3(6.8, 0.10, 3.2), DEFENDER_SPRITE_PATH, Color("#739b91"), false, 0.96)
	_add_simple_unit("ReserveSupport", Vector3(11.2, 0.10, 3.9), RESERVE_SPRITE_PATH, Color("#a18469"), false, 0.92)

func _unit_shadow(parent: Node3D, label: String, radius: float) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.025
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = Vector3(0.16, 0.035, 0.13)
	node.material_override = _material(Color(0.12, 0.14, 0.13, 0.30), 1.0)
	(node.material_override as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	(node.material_override as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	parent.add_child(node)

func _candidate_ring(parent: Node3D, label: String, color: Color, radius: float, selected: bool) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.025
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position.y = 0.055
	node.material_override = _material(Color(color.r, color.g, color.b, 0.30), 0.96)
	(node.material_override as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	(node.material_override as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	node.visible = selected
	parent.add_child(node)
	v0307_candidate_rings[parent.name] = node

func _add_u1(origin: Vector3) -> void:
	var root := Node3D.new()
	root.name = "V0307Aster_U1_DirectionalBillboard"
	root.position = origin
	composition_root.add_child(root)
	v0307_candidate_roots["U1"] = root
	_unit_shadow(root, "U1DirectionalContactShadow", 0.42)
	for index in range(3):
		var sprite := MeshInstance3D.new()
		sprite.name = "U1Card_%02d" % index
		var quad := QuadMesh.new()
		quad.size = Vector2(0.96, 1.72)
		sprite.mesh = quad
		sprite.position = Vector3(0.0, 0.90, 0.0)
		sprite.rotation_degrees.y = float(index) * 60.0
		var material := StandardMaterial3D.new()
		material.albedo_texture = load(ASTER_SPRITE_PATH) as Texture2D
		material.albedo_color = Color("#d1c29c")
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.material_override = material
		root.add_child(sprite)
	_add_box_to(root, "U1FactionSash", Vector3(0.30, 0.88, 0.04), Vector3(0.10, 0.46, 0.08), Color("#8b7650"), 0.82)
	_candidate_ring(root, "U1SelectionRing", Color("#c2b176"), 0.52, true)

func _add_u2(origin: Vector3) -> void:
	var root := Node3D.new()
	root.name = "V0307Aster_U2_LowPoly3D"
	root.position = origin
	composition_root.add_child(root)
	v0307_candidate_roots["U2"] = root
	_unit_shadow(root, "U2DirectionalContactShadow", 0.42)
	var torso := CylinderMesh.new()
	torso.top_radius = 0.23
	torso.bottom_radius = 0.34
	torso.height = 0.92
	torso.radial_segments = 6
	var body := MeshInstance3D.new()
	body.name = "U2LowPolyBody"
	body.mesh = torso
	body.position.y = 0.67
	body.material_override = _material(Color("#62665f"), 0.82)
	root.add_child(body)
	var head := SphereMesh.new()
	head.radius = 0.22
	head.height = 0.44
	head.radial_segments = 8
	head.rings = 4
	var head_node := MeshInstance3D.new()
	head_node.name = "U2LowPolyHead"
	head_node.mesh = head
	head_node.position = Vector3(0.0, 1.30, 0.0)
	head_node.material_override = _material(Color("#9a8069"), 0.84)
	root.add_child(head_node)
	var cloak := BoxMesh.new()
	cloak.size = Vector3(0.72, 0.78, 0.20)
	var cloak_node := MeshInstance3D.new()
	cloak_node.name = "U2WeatheredCloak"
	cloak_node.mesh = cloak
	cloak_node.position = Vector3(0.0, 0.72, -0.20)
	cloak_node.rotation_degrees.z = -8.0
	cloak_node.material_override = _material(Color("#343b3a"), 0.82)
	root.add_child(cloak_node)
	var hat := CylinderMesh.new()
	hat.top_radius = 0.16
	hat.bottom_radius = 0.30
	hat.height = 0.16
	hat.radial_segments = 6
	var hat_node := MeshInstance3D.new()
	hat_node.name = "U2BarrosanHat"
	hat_node.mesh = hat
	hat_node.position.y = 1.58
	hat_node.material_override = _material(Color("#4d4339"), 0.80)
	root.add_child(hat_node)
	_add_box_to(root, "U2FactionSash", Vector3(0.28, 0.85, 0.08), Vector3(0.10, 0.45, 0.08), Color("#92744e"), 0.82)
	_candidate_ring(root, "U2SelectionRing", Color("#c0b190"), 0.52, false)

func _add_u3(origin: Vector3) -> void:
	var root := Node3D.new()
	root.name = "V0307Aster_U3_HybridBodyBillboard"
	root.position = origin
	composition_root.add_child(root)
	v0307_candidate_roots["U3"] = root
	_unit_shadow(root, "U3DirectionalContactShadow", 0.42)
	var torso := CylinderMesh.new()
	torso.top_radius = 0.22
	torso.bottom_radius = 0.32
	torso.height = 0.82
	torso.radial_segments = 6
	var body := MeshInstance3D.new()
	body.name = "U3LowPolyBody"
	body.mesh = torso
	body.position.y = 0.62
	body.material_override = _material(Color("#5b625d"), 0.82)
	root.add_child(body)
	var detail := MeshInstance3D.new()
	detail.name = "U3BillboardCloakDetail"
	var quad := QuadMesh.new()
	quad.size = Vector2(0.66, 1.18)
	detail.mesh = quad
	detail.position = Vector3(0.0, 0.82, -0.10)
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(ASTER_SPRITE_PATH) as Texture2D
	material.albedo_color = Color(0.82, 0.78, 0.62, 0.72)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	detail.material_override = material
	root.add_child(detail)
	_add_box_to(root, "U3FactionSash", Vector3(0.28, 0.82, 0.10), Vector3(0.10, 0.44, 0.08), Color("#927b53"), 0.82)
	_candidate_ring(root, "U3SelectionRing", Color("#c0b190"), 0.52, false)

func _add_simple_unit(unit_name: String, origin: Vector3, texture_path: String, accent: Color, selected: bool, scale_value: float) -> void:
	var root := Node3D.new()
	root.name = "V0307Unit_%s" % unit_name
	root.position = origin
	composition_root.add_child(root)
	_unit_shadow(root, "%sContactShadow" % unit_name, 0.38 * scale_value)
	var sprite := MeshInstance3D.new()
	sprite.name = "%sBillboard" % unit_name
	var quad := QuadMesh.new()
	quad.size = Vector2(0.86 * scale_value, 1.55 * scale_value)
	sprite.mesh = quad
	sprite.position.y = 0.82 * scale_value
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(texture_path) as Texture2D
	material.albedo_color = Color(0.92, 0.92, 0.84, 1.0)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sprite.material_override = material
	root.add_child(sprite)
	_add_box_to(root, "%sAccent" % unit_name, Vector3(0.27, 0.84, 0.04), Vector3(0.09, 0.44, 0.08), accent, 0.82)

func _build_overlay() -> void:
	v0307_hud = CanvasLayer.new()
	v0307_hud.name = "V0307ProductionViabilityOverlay"
	add_child(v0307_hud)
	var header := ColorRect.new()
	header.position = Vector2(34, 24)
	header.size = Vector2(720, 68)
	header.color = Color(0.025, 0.045, 0.040, 0.93)
	v0307_hud.add_child(header)
	var title := Label.new()
	title.position = Vector2(18, 8)
	title.text = "ROUTE C PRODUCTION VIABILITY  |  SALTO EAST BANK"
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", Color("#ecdbab"))
	header.add_child(title)
	v0307_note = Label.new()
	v0307_note.position = Vector2(18, 38)
	v0307_note.text = "AUTHORED MICRO-SLICE  •  U1 / U2 / U3 UNIT BAKE-OFF"
	v0307_note.add_theme_font_size_override("font_size", 12)
	v0307_note.add_theme_color_override("font_color", Color("#b6c6b7"))
	header.add_child(v0307_note)
	var card := Panel.new()
	card.name = "V0307AsterStrategyCard"
	card.position = Vector2(1040, 706)
	card.size = Vector2(520, 140)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.045, 0.040, 0.94), Color("#718e7d")))
	v0307_hud.add_child(card)
	var body := Label.new()
	body.position = Vector2(18, 12)
	body.text = "ASTER UNIT BAKE-OFF\nU1 directional cards   U2 low-poly body   U3 hybrid\nSame footprint / scale test • no gameplay state"
	body.add_theme_font_size_override("font_size", 14)
	body.add_theme_color_override("font_color", Color("#d3dccf"))
	card.add_child(body)
	var legend := Label.new()
	legend.position = Vector2(38, 832)
	legend.text = "AUTHORED TERRAIN / VARIABLE DEPTH WATER / BARROSAN UTILITY HOUSE / REFERENCE-ONLY PROTOTYPE"
	legend.add_theme_font_size_override("font_size", 12)
	legend.add_theme_color_override("font_color", Color("#c9d0ae"))
	v0307_hud.add_child(legend)

func _set_note(value: String) -> void:
	if v0307_note != null:
		v0307_note.text = value

func _set_candidate_selected(candidate: String, selected: bool) -> void:
	if v0307_candidate_rings.has(candidate):
		(v0307_candidate_rings[candidate] as Node3D).visible = selected

func _set_atmosphere(enabled: bool) -> void:
	v0307_atmosphere_enabled = enabled
	if v0307_world != null and v0307_world.environment != null:
		v0307_world.environment.fog_enabled = enabled

func _capture_views() -> void:
	_set_note("FULL OVERVIEW  •  authored terrain, bank, bridge, house, and three unit candidates")
	await _capture("01_v0307_overview_oblique.png", V0307_CAMERA_OBLIQUE, V0307_TARGET, V0307_ORTHO_SIZE)
	_set_note("DIRECT TOP-DOWN  •  bounded terrain remains tactical")
	await _capture("02_v0307_top_down.png", V0307_CAMERA_TOP_DOWN, Vector3(0.0, 0.0, 2.0), V0307_ORTHO_SIZE)
	_set_note("AUTHORED TERRAIN MICRO-SLICE  •  shoulders, erosion, embedded stones")
	await _capture("03_v0307_authored_terrain_close.png", Vector3(15.0, 14.0, 18.0), Vector3(7.8, 0.0, 0.8), 15.0)
	_set_note("RIVERBANK  •  deep channel, shallow shelf, flow, foam, rock contact")
	await _capture("04_v0307_river_shoreline.png", Vector3(15.0, 13.0, 17.0), Vector3(4.0, -0.18, 0.5), 13.0)
	_set_note("BRIDGE LANDING  •  damp beam and irregular approach")
	await _capture("05_v0307_bridge_landing.png", Vector3(11.0, 9.0, 13.0), Vector3(4.0, 0.32, 0.0), 10.0)
	_set_note("MATERIAL VALUE HIERARCHY  •  wet stone / dry stone / timber / roof / earth")
	await _capture("06_v0307_material_hierarchy.png", Vector3(17.0, 15.0, 20.0), Vector3(7.5, 0.18, 4.0), 17.0)
	_set_note("AUTHORED BARROSAN UTILITY HOUSE  •  stone, slate, porch, chimney")
	await _capture("07_v0307_support_building_overview.png", Vector3(16.0, 11.0, 15.0), Vector3(10.5, 1.8, 6.0), 10.5)
	await _capture("08_v0307_support_building_close.png", Vector3(15.0, 7.5, 11.5), Vector3(10.5, 1.8, 6.0), 7.0)
	await _capture("09_v0307_support_building_side.png", Vector3(-12.0, 7.5, 10.0), Vector3(10.5, 1.7, 6.0), 7.5)
	await _capture("10_v0307_support_building_top_down.png", V0307_CAMERA_TOP_DOWN, Vector3(10.5, 0.0, 6.0), 7.0)
	_set_note("UNIT STRATEGY BAKE-OFF  •  U1 directional cards / U2 low-poly / U3 hybrid")
	await _capture("11_v0307_unit_strategies_overview.png", Vector3(12.0, 9.0, 16.0), Vector3(-1.8, 0.65, 4.0), 10.0)
	await _capture("12_v0307_u1_front_three_quarter.png", Vector3(10.0, 7.0, 12.0), Vector3(-5.7, 0.75, 4.0), 5.0)
	await _capture("13_v0307_u2_front_three_quarter.png", Vector3(10.0, 7.0, 12.0), Vector3(-2.0, 0.75, 4.0), 5.0)
	await _capture("14_v0307_u3_front_three_quarter.png", Vector3(10.0, 7.0, 12.0), Vector3(1.7, 0.75, 4.0), 5.0)
	await _capture("15_v0307_u1_alternate_oblique.png", V0307_CAMERA_ALTERNATE, Vector3(-5.7, 0.75, 4.0), 5.0)
	await _capture("16_v0307_u2_alternate_oblique.png", V0307_CAMERA_ALTERNATE, Vector3(-2.0, 0.75, 4.0), 5.0)
	await _capture("17_v0307_u3_alternate_oblique.png", V0307_CAMERA_ALTERNATE, Vector3(1.7, 0.75, 4.0), 5.0)
	_set_candidate_selected("U1", false)
	_set_candidate_selected("U2", true)
	_set_note("SELECTED / UNSELECTED  •  restrained semantic selection")
	await _capture("18_v0307_u1_unselected_u2_selected.png", Vector3(12.0, 9.0, 16.0), Vector3(-1.8, 0.65, 4.0), 10.0)
	_set_candidate_selected("U2", false)
	_set_candidate_selected("U3", true)
	await _capture("19_v0307_u2_unselected_u3_selected.png", Vector3(12.0, 9.0, 16.0), Vector3(-1.8, 0.65, 4.0), 10.0)
	_set_candidate_selected("U3", false)
	_set_candidate_selected("U1", true)
	_set_note("GAMEPLAY SCALE  •  road / bridge / house / candidate readability")
	await _capture("20_v0307_gameplay_scale.png", V0307_CAMERA_OBLIQUE, Vector3(0.0, 0.25, 3.5), 19.0)
	_set_note("U1 GROUP READABILITY  •  same footprint and selected state")
	await _capture("21_v0307_u1_bridge_water_background.png", Vector3(11.0, 9.0, 14.0), Vector3(1.8, 0.5, 3.3), 8.5)
	_set_note("ATMOSPHERE DISABLED  •  direct comparison")
	_set_atmosphere(false)
	await _capture("22_v0307_atmosphere_disabled.png", V0307_CAMERA_OBLIQUE, V0307_TARGET, V0307_ORTHO_SIZE)
	_set_note("ATMOSPHERE ENABLED  •  soft mountain haze")
	_set_atmosphere(true)
	await _capture("23_v0307_atmosphere_enabled.png", V0307_CAMERA_OBLIQUE, V0307_TARGET, V0307_ORTHO_SIZE)
	_set_note("NO GAMEPLAY MUTATION  •  isolated scene only")
	await _capture("24_v0307_isolation_proof.png", V0307_CAMERA_OBLIQUE, V0307_TARGET, V0307_ORTHO_SIZE)

func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0307-route-c-production-viability-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": V0307_CHECKPOINT,
		"status": "PASS_V0307_ROUTE_C_PRODUCTION_VIABILITY" if errors.is_empty() else "FAIL_V0307_ROUTE_C_PRODUCTION_VIABILITY",
		"prototypeOnly": true,
		"prototypeOptIn": true,
		"scenePath": V0307_SCENE_PATH,
		"productionIntegration": false,
		"gameplayChanged": false,
		"movementChanged": false,
		"pathingChanged": false,
		"combatChanged": false,
		"economyChanged": false,
		"resourceChanged": false,
		"pressureChanged": false,
		"stableIdsChanged": false,
		"saveChanged": false,
		"sourceProvenance": "repository-authored v0.236 Barrosan kit and existing fallback textures; v0.307 authored micro-slice geometry and procedural low-poly unit candidates",
		"referenceOnly": ["v0.141 R1 historical image", "v0.303 fallback/debug renderer"],
		"terrain": {"microSliceBounded": true, "authoredPatches": v0307_authored_nodes, "walkabilityDimensionsPreserved": true, "rectangularPlates": false},
		"river": {"deepChannel": true, "shallowShelf": true, "visibleFlowDirection": true, "foamDisturbance": true, "irregularShoreline": true, "bridgeContact": true},
		"supportBuilding": {"authored": true, "blockoutReplaced": true, "roof": "weathered slate gable", "foundation": true, "entrance": true, "sideRear": true, "gameplayFootprintChanged": false},
		"unitStrategies": {
			"U1": {"name": "improved multi-angle directional billboard", "sameGameplayFootprint": true, "selectedEvidence": true, "unselectedEvidence": true},
			"U2": {"name": "true low-poly 3D unit", "sameGameplayFootprint": true, "selectedEvidence": true, "unselectedEvidence": true},
			"U3": {"name": "hybrid low-poly body plus billboard detail", "sameGameplayFootprint": true, "selectedEvidence": true, "unselectedEvidence": true}
		},
		"recommendedUnitStrategy": "U3 hybrid low-poly body plus billboard/detail solution",
		"camera": {"projection": "orthographic", "primary": V0307_CAMERA_OBLIQUE, "alternate": V0307_CAMERA_ALTERNATE, "topDown": V0307_CAMERA_TOP_DOWN, "orthoSize": V0307_ORTHO_SIZE},
		"atmosphere": {"disabledCapture": "22_v0307_atmosphere_disabled.png", "enabledCapture": "23_v0307_atmosphere_enabled.png", "fogDensity": 0.0011},
		"captures": captures,
		"newRuntimeArtSlots": 0,
		"errors": errors,
	})
