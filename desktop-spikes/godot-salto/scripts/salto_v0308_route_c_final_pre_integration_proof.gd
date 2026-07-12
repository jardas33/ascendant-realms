extends "res://scripts/salto_v0307_route_c_production_viability_slice.gd"

const V0308_CHECKPOINT := "v0.308"
const V0308_SCENE_PATH := "res://scenes/salto_v0308_route_c_final_pre_integration_proof.tscn"
const V0308_CAMERA_OBLIQUE := Vector3(24.0, 23.0, 27.0)
const V0308_CAMERA_ALTERNATE := Vector3(-22.0, 20.0, 25.0)
const V0308_CAMERA_TOP_DOWN := Vector3(0.0, 28.0, 0.01)
const V0308_TARGET := Vector3(0.0, 0.25, 2.0)
const V0308_ORTHO_SIZE := 28.0

var v0308_world: WorldEnvironment
var v0308_hud: CanvasLayer
var v0308_note: Label
var v0308_flow_nodes: Array[Node] = []
var v0308_atmosphere_nodes: Array[Node] = []
var v0308_capture_state := {
	"waterMotion": true,
	"atmosphere": true,
	"selected": "worker",
}
var v0308_authored_nodes: Array[String] = []
var v0308_unit_contracts: Array[Dictionary] = []

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#35423d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#b7c2b5")
	environment.ambient_light_energy = 0.88
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = true
	environment.fog_light_color = Color("#9baa9f")
	environment.fog_light_energy = 0.20
	environment.fog_density = 0.0010
	v0308_world = WorldEnvironment.new()
	v0308_world.name = "V0308BarrosanHighlandAtmosphere"
	v0308_world.environment = environment
	add_child(v0308_world)

	var key := DirectionalLight3D.new()
	key.name = "V0308ConsistentNorthwestKey"
	key.rotation_degrees = Vector3(-48.0, -36.0, 0.0)
	key.light_color = Color("#e3d8bd")
	key.light_energy = 1.20
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 110.0
	key.directional_shadow_split_1 = 0.12
	key.directional_shadow_split_2 = 0.42
	add_child(key)

	var fill := DirectionalLight3D.new()
	fill.name = "V0308CoolHighlandFill"
	fill.rotation_degrees = Vector3(-26.0, 142.0, 0.0)
	fill.light_color = Color("#8da8aa")
	fill.light_energy = 0.38
	fill.shadow_enabled = false
	add_child(fill)

	camera = Camera3D.new()
	camera.name = "V0308GameplayObliqueCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.1
	camera.far = 240.0
	camera.current = true
	add_child(camera)

func _tune_material(material: StandardMaterial3D) -> void:
	super._tune_material(material)
	match material.resource_name:
		"MAT_Grass": material.albedo_color = Color("#66795f")
		"MAT_Earth": material.albedo_color = Color("#6f5b49")
		"MAT_RoadDirt": material.albedo_color = Color("#80705b")
		"MAT_Stone": material.albedo_color = Color("#78827e")
		"MAT_StoneLight": material.albedo_color = Color("#a9aa9c")
		"MAT_StoneWarm": material.albedo_color = Color("#8b7865")
		"MAT_StoneDark": material.albedo_color = Color("#343b39")
		"MAT_StoneMoss": material.albedo_color = Color("#64765f")
		"MAT_Roof": material.albedo_color = Color("#5b5650")
		"MAT_RoofDark": material.albedo_color = Color("#302f2c")
		"MAT_Wood": material.albedo_color = Color("#6b5a4d")
		"MAT_WoodDark": material.albedo_color = Color("#302d2a")
		"MAT_WoodWeathered": material.albedo_color = Color("#806e5c")
		"MAT_EaveDark": material.albedo_color = Color("#252624")
		"MAT_IronDark": material.albedo_color = Color("#303938")
	material.roughness = max(material.roughness, 0.74)

func _build_composition() -> void:
	composition_root = Node3D.new()
	composition_root.name = "V0308RouteCFinalPreIntegrationMicroSlice"
	add_child(composition_root)
	_build_v0308_terrain_edges()
	_build_v0308_river()
	_build_converged_roads()
	_build_converged_bridge()
	_build_v0308_utility_building()
	_build_v0308_dressing()
	_build_v0308_units()

func _build_v0308_terrain_edges() -> void:
	var west := [Vector2(-18.0, -13.5), Vector2(-14.0, -16.0), Vector2(-8.0, -16.7), Vector2(-2.0, -15.8), Vector2(1.35, -13.5), Vector2(1.40, 12.0), Vector2(-1.0, 15.8), Vector2(-6.5, 16.2), Vector2(-12.0, 15.0), Vector2(-17.0, 11.5), Vector2(-19.0, 4.0), Vector2(-18.3, -3.0)]
	var east := [Vector2(6.65, -14.2), Vector2(10.8, -15.7), Vector2(16.7, -12.0), Vector2(18.5, -6.0), Vector2(17.4, 1.0), Vector2(18.0, 7.7), Vector2(14.0, 13.5), Vector2(8.0, 16.0), Vector2(6.6, 12.0)]
	_add_extruded_terrain("V0308NaturalWestLandform", west, -0.02, -1.08)
	_add_extruded_terrain("V0308NaturalEastLandform", east, -0.02, -1.08)
	for config in [
		["V0308WestBankCut", [Vector3(-1.55, 0.12, -12.5), Vector3(1.28, 0.28, -10.8), Vector3(1.25, 0.06, -5.0), Vector3(-1.55, -0.02, -3.0)], -0.66, Color("#625449")],
		["V0308EastBankCut", [Vector3(6.45, 0.06, -12.0), Vector3(9.2, 0.25, -10.4), Vector3(10.5, 0.12, -4.0), Vector3(6.45, -0.02, -2.7)], -0.64, Color("#65564a")],
		["V0308WestBridgeShoulder", [Vector3(-1.55, 0.02, -2.1), Vector3(1.22, 0.12, -1.0), Vector3(1.25, 0.20, 3.6), Vector3(-0.3, 0.24, 4.7), Vector3(-1.55, 0.04, 3.0)], -0.60, Color("#7d6953")],
		["V0308EastBridgeShoulder", [Vector3(6.45, 0.04, -2.2), Vector3(9.0, 0.18, -1.0), Vector3(10.6, 0.24, 2.4), Vector3(8.2, 0.12, 4.2), Vector3(6.45, 0.03, 3.0)], -0.60, Color("#806c55")],
	]:
		_add_authored_patch(str(config[0]), config[1], float(config[2]), config[3])
		v0308_authored_nodes.append(str(config[0]))
	for config in [
		["V0308WetSoilBreakA", Vector2(2.0, -5.4), Vector2(2.4, 1.0), -10.0, 0.04, Color("#554941")],
		["V0308WetSoilBreakB", Vector2(9.0, 4.2), Vector2(2.5, 1.15), 15.0, 0.05, Color("#594b42")],
		["V0308GrassBreakA", Vector2(-7.0, 11.2), Vector2(4.8, 1.25), 8.0, 0.04, Color("#748568")],
		["V0308GrassBreakB", Vector2(13.0, -8.7), Vector2(3.8, 1.2), -12.0, 0.04, Color("#718267")],
	]:
		_add_ellipse_patch(str(config[0]), config[1], config[2], float(config[3]), float(config[4]), config[5])
		v0308_authored_nodes.append(str(config[0]))
	for config in [
		["V0308EmbeddedStoneA", Vector3(0.75, 0.10, -7.0), -12.0, 0.42],
		["V0308EmbeddedStoneB", Vector3(7.2, 0.16, -4.7), 16.0, 0.48],
		["V0308EmbeddedStoneC", Vector3(9.6, 0.14, 3.0), 8.0, 0.46],
		["V0308EmbeddedStoneD", Vector3(-0.6, 0.10, 6.4), -9.0, 0.42],
	]:
		_place_prop("prop_rock_cluster", config[1], float(config[2]), float(config[3]))
		v0308_authored_nodes.append(str(config[0]))

func _build_v0308_river() -> void:
	var centers := [Vector2(4.0, -15.0), Vector2(3.62, -12.0), Vector2(4.30, -9.0), Vector2(3.72, -6.0), Vector2(4.22, -3.0), Vector2(3.82, 0.0), Vector2(4.38, 3.2), Vector2(3.70, 6.4), Vector2(4.20, 9.4), Vector2(3.78, 12.4), Vector2(4.10, 15.0)]
	var widths := [3.15, 3.60, 3.05, 3.78, 3.18, 3.68, 3.10, 3.72, 3.25, 3.60, 3.18]
	_add_ribbon("V0308DeepWaterChannel", centers, widths.map(func(value): return float(value) + 1.52), -0.43, Color("#263d40"), 0.98, "riverbank")
	_add_ribbon("V0308ShallowWaterShelf", centers, widths.map(func(value): return float(value) + 0.76), -0.27, Color("#546a64"), 0.94, "riverbank")
	_add_ribbon("V0308WetBankTransition", centers, widths.map(func(value): return float(value) + 0.28), -0.17, Color("#53685f"), 0.86, "riverbank")
	_add_ribbon("V0308FlowingRiver", centers, widths, -0.52, Color("#24474c"), 0.16, "river")
	for config in [
		["V0308WaterFlowBandA", [Vector2(3.75, -13.7), Vector2(4.04, -10.0), Vector2(3.82, -6.3), Vector2(4.08, -2.1), Vector2(3.88, 2.0), Vector2(4.12, 6.1), Vector2(3.90, 10.2), Vector2(4.02, 13.8)], [0.15, 0.23, 0.12, 0.20, 0.14, 0.22, 0.13, 0.18], -0.49, Color("#789a95"), 0.34],
		["V0308WaterFlowBandB", [Vector2(4.34, -11.8), Vector2(4.02, -8.0), Vector2(4.42, -4.0), Vector2(4.10, 0.2), Vector2(4.34, 4.6), Vector2(4.06, 8.6), Vector2(4.30, 12.1)], [0.09, 0.14, 0.10, 0.16, 0.09, 0.14, 0.10], -0.485, Color("#b0c2b6"), 0.22],
		["V0308BridgeContactFoam", [Vector2(2.55, -1.10), Vector2(3.15, -0.82), Vector2(3.75, -0.92), Vector2(4.28, -0.70)], [0.08, 0.15, 0.10, 0.06], -0.47, Color("#afc7bd"), 0.22],
	]:
		_add_ribbon(str(config[0]), config[1], config[2], float(config[3]), config[4], float(config[5]), "river")
		var node := composition_root.get_node_or_null(str(config[0]) + "_00")
		if node != null:
			v0308_flow_nodes.append(node)
		v0308_authored_nodes.append(str(config[0]))
	for config in [[Vector3(1.65, -0.11, -7.2), -8.0, 0.38], [Vector3(6.6, -0.12, -3.8), 14.0, 0.42], [Vector3(1.5, -0.10, 6.8), 12.0, 0.40], [Vector3(6.5, -0.12, 9.2), -14.0, 0.38]]:
		_place_prop("prop_rock_cluster", config[0], float(config[1]), float(config[2]))
		v0308_authored_nodes.append("water_contact_rock")

func _build_v0308_utility_building() -> void:
	var building := Node3D.new()
	building.name = "V0308CompletedBarrosanUtilityStorehouse"
	building.position = Vector3(10.5, 0.0, 6.0)
	composition_root.add_child(building)
	for index in range(8):
		var angle := TAU * float(index) / 8.0
		var stone := _add_box_to(building, "StorehouseFoundationCourse_%02d" % index, Vector3(cos(angle) * 2.0, 0.18, sin(angle) * 1.48), Vector3(0.72, 0.36, 0.58), Color("#777a70" if index % 2 else "#626a66"), 0.95)
		stone.rotation_degrees.y = rad_to_deg(angle)
	_add_box_to(building, "StorehouseRearLimeWall", Vector3(0.0, 1.38, -1.18), Vector3(3.72, 2.42, 0.28), Color("#898d82"), 0.96)
	_add_box_to(building, "StorehouseLeftWall", Vector3(-1.72, 1.38, 0.0), Vector3(0.28, 2.42, 2.56), Color("#707970"), 0.96)
	_add_box_to(building, "StorehouseRightWall", Vector3(1.72, 1.38, 0.0), Vector3(0.28, 2.42, 2.56), Color("#979587"), 0.96)
	_add_box_to(building, "StorehouseFrontWallLeft", Vector3(-0.98, 1.38, 1.18), Vector3(1.34, 2.42, 0.28), Color("#8f9083"), 0.96)
	_add_box_to(building, "StorehouseFrontWallRight", Vector3(0.98, 1.38, 1.18), Vector3(1.34, 2.42, 0.28), Color("#7a8178"), 0.96)
	_add_box_to(building, "StorehouseEntranceFrame", Vector3(0.0, 1.24, 1.33), Vector3(0.94, 2.16, 0.20), Color("#3b3d38"), 0.84)
	_add_box_to(building, "StorehousePlankDoor", Vector3(0.0, 1.16, 1.45), Vector3(0.64, 1.75, 0.10), Color("#59493c"), 0.86)
	for side in [-1.0, 1.0]:
		_add_box_to(building, "StorehouseTimberPost_%s" % side, Vector3(side * 1.36, 1.45, 1.38), Vector3(0.18, 2.48, 0.18), Color("#3b3631"), 0.82)
		var brace := _add_box_to(building, "StorehouseDiagonalBrace_%s" % side, Vector3(side * 0.95, 1.66, 1.42), Vector3(0.16, 1.20, 0.20), Color("#51443a"), 0.82)
		brace.rotation_degrees.z = side * 31.0
	for window in [Vector3(-1.08, 1.48, 1.36), Vector3(1.08, 1.48, 1.36), Vector3(-1.86, 1.48, -0.42)]:
		_add_box_to(building, "StorehouseWindow_%s" % str(window), window, Vector3(0.48, 0.46, 0.08), Color("#a5b7aa"), 0.70)
	_add_box_to(building, "StorehouseFinishedSlateRoofDeck", Vector3(0.0, 2.72, 0.0), Vector3(4.02, 0.20, 3.16), Color("#555f5b"), 0.92)
	_add_box_to(building, "StorehouseSlateRidgeCap", Vector3(0.0, 2.91, 0.0), Vector3(0.24, 0.16, 3.38), Color("#303634"), 0.80)
	_add_box_to(building, "StorehouseSlateBandLeft", Vector3(-0.94, 2.84, 0.0), Vector3(0.10, 0.05, 3.02), Color("#707a73"), 0.90)
	_add_box_to(building, "StorehouseSlateBandRight", Vector3(0.94, 2.84, 0.0), Vector3(0.10, 0.05, 3.02), Color("#646e68"), 0.90)
	_add_box_to(building, "StorehouseDeepEaveFront", Vector3(0.0, 2.42, 1.66), Vector3(4.45, 0.16, 0.20), Color("#292b29"), 0.80)
	_add_box_to(building, "StorehouseGutter", Vector3(2.12, 2.54, 0.88), Vector3(0.12, 0.12, 2.25), Color("#37403d"), 0.82)
	_add_box_to(building, "StorehouseDrainPipe", Vector3(2.12, 1.30, 1.82), Vector3(0.10, 2.40, 0.10), Color("#3b423e"), 0.82)
	_add_box_to(building, "StorehouseChimney", Vector3(-1.05, 3.68, -0.62), Vector3(0.48, 1.06, 0.48), Color("#626963"), 0.94)
	_add_box_to(building, "StorehouseChimneyCap", Vector3(-1.05, 4.24, -0.62), Vector3(0.64, 0.12, 0.64), Color("#343a37"), 0.82)
	_add_box_to(building, "StorehousePorchBeam", Vector3(0.0, 2.24, 1.74), Vector3(2.45, 0.18, 0.18), Color("#343532"), 0.82)
	_add_box_to(building, "StorehousePorchRoof", Vector3(0.0, 2.48, 1.74), Vector3(2.70, 0.18, 1.08), Color("#5c625d"), 0.90)
	_add_ellipse_patch("StorehouseMossAndDampFoot", Vector2(10.5, 6.0), Vector2(4.8, 3.7), -3.0, 0.035, Color("#5c705e"))
	v0308_authored_nodes.append("V0308CompletedBarrosanUtilityStorehouse")

func _build_v0308_dressing() -> void:
	for config in [["prop_tree", Vector3(-16.0, 0.0, -10.5), -8.0, 0.68], ["prop_tree", Vector3(15.8, 0.0, -10.5), 12.0, 0.64], ["prop_log_stack", Vector3(-15.8, 0.0, 9.8), -10.0, 0.46], ["prop_crate_stack", Vector3(-14.0, 0.0, 8.4), 8.0, 0.48], ["prop_rubble", Vector3(13.2, 0.0, 8.8), -7.0, 0.42]]:
		_place_prop(str(config[0]), config[1], float(config[2]), float(config[3]))
	for config in [[Vector3(2.0, -0.02, -6.2), -5.0, 0.40], [Vector3(6.2, -0.02, 5.6), 13.0, 0.36], [Vector3(1.2, -0.02, 8.0), 24.0, 0.34]]:
		_place_prop("prop_posts", config[0], float(config[1]), float(config[2]))

func _build_v0308_units() -> void:
	_add_v0308_worker("V0308U3WBarrosanWorker", Vector3(-7.2, 0.08, 4.0), true, "worker")
	_add_v0308_militia("V0308U3MBarrosanMilitia", Vector3(-3.9, 0.08, 4.0), false, "militia")
	_add_v0308_worker("V0308WorkerRoad", Vector3(-9.0, 0.08, 0.5), false, "worker")
	_add_v0308_militia("V0308MilitiaBridge", Vector3(1.0, 0.08, 3.7), true, "militia")
	_add_v0308_worker("V0308WorkerShore", Vector3(7.3, 0.08, -4.7), false, "worker")
	_add_v0308_militia("V0308MilitiaShore", Vector3(8.2, 0.08, -5.8), false, "militia")
	for index in range(4):
		_add_v0308_worker("V0308GroupWorker_%02d" % index, Vector3(-11.0 + float(index) * 0.95, 0.08, 8.8 + sin(float(index)) * 0.35), false, "worker")
	for index in range(3):
		_add_v0308_militia("V0308GroupMilitia_%02d" % index, Vector3(-5.2 + float(index) * 0.95, 0.08, 9.5 + cos(float(index)) * 0.30), false, "militia")
	# Kept as a visible comparison token so the v0.307 strategy remains recoverable in this proof.
	_add_v0308_comparison("V0308V0307U3Comparison", Vector3(-0.2, 0.08, 8.0))

func _unit_shadow(parent: Node3D, label: String, radius: float) -> void:
	super._unit_shadow(parent, label, radius)
	var shadow := parent.get_node_or_null(label)
	if shadow != null:
		(shadow as MeshInstance3D).material_override = _material(Color(0.10, 0.12, 0.11, 0.24), 1.0)

func _add_v0308_worker(unit_name: String, origin: Vector3, selected: bool, role: String) -> void:
	var root := Node3D.new()
	root.name = unit_name
	root.position = origin
	composition_root.add_child(root)
	_unit_shadow(root, unit_name + "ContactShadow", 0.40)
	var torso := CylinderMesh.new()
	torso.top_radius = 0.24
	torso.bottom_radius = 0.34
	torso.height = 0.78
	torso.radial_segments = 6
	var body := MeshInstance3D.new()
	body.name = unit_name + "RuggedWorkerTorso"
	body.mesh = torso
	body.position.y = 0.62
	body.material_override = _material(Color("#6e6252"), 0.86)
	root.add_child(body)
	_add_unit_box(root, unit_name + "WorkerApron", Vector3(0.0, 0.66, 0.22), Vector3(0.48, 0.58, 0.14), Color("#4d514a"), 0.84)
	_add_unit_box(root, unit_name + "WorkerPack", Vector3(0.0, 0.80, -0.30), Vector3(0.44, 0.58, 0.22), Color("#493f35"), 0.86)
	_add_unit_limb(root, unit_name + "WorkerArmL", Vector3(-0.34, 0.72, 0.02), Vector3(0.14, 0.64, 0.14), -12.0, Color("#756957"))
	_add_unit_limb(root, unit_name + "WorkerArmR", Vector3(0.34, 0.72, 0.02), Vector3(0.14, 0.64, 0.14), 12.0, Color("#756957"))
	_add_unit_limb(root, unit_name + "WorkerLegL", Vector3(-0.16, 0.20, 0.02), Vector3(0.16, 0.46, 0.16), -3.0, Color("#4b4a43"))
	_add_unit_limb(root, unit_name + "WorkerLegR", Vector3(0.16, 0.20, 0.02), Vector3(0.16, 0.46, 0.16), 3.0, Color("#454740"))
	_add_unit_box(root, unit_name + "WorkerBootL", Vector3(-0.18, 0.04, 0.12), Vector3(0.22, 0.12, 0.34), Color("#302d29"), 0.82)
	_add_unit_box(root, unit_name + "WorkerBootR", Vector3(0.18, 0.04, 0.12), Vector3(0.22, 0.12, 0.34), Color("#302d29"), 0.82)
	var head := SphereMesh.new()
	head.radius = 0.22
	head.height = 0.44
	head.radial_segments = 8
	head.rings = 4
	var head_node := MeshInstance3D.new()
	head_node.name = unit_name + "WorkerHead"
	head_node.mesh = head
	head_node.position = Vector3(0.0, 1.24, 0.0)
	head_node.material_override = _material(Color("#9b8068"), 0.88)
	root.add_child(head_node)
	_add_unit_box(root, unit_name + "WorkerCap", Vector3(0.0, 1.48, 0.0), Vector3(0.48, 0.13, 0.48), Color("#4c4338"), 0.82)
	_add_unit_limb(root, unit_name + "WorkerPickaxe", Vector3(0.54, 0.78, 0.02), Vector3(0.10, 1.16, 0.10), -17.0, Color("#3c342b"))
	_add_unit_box(root, unit_name + "WorkerPickHead", Vector3(0.70, 1.30, 0.02), Vector3(0.50, 0.10, 0.12), Color("#7d8178"), 0.78)
	_add_unit_box(root, unit_name + "WorkerFactionAccent", Vector3(0.28, 0.88, 0.20), Vector3(0.10, 0.36, 0.08), Color("#b08d55"), 0.80)
	_add_selection(root, unit_name + "SelectionRing", Color("#c4af78"), selected)
	v0308_unit_contracts.append({"id": unit_name, "role": role, "selected": selected, "sameGameplayFootprint": true, "presentation": "authored low-poly 3D"})

func _add_v0308_militia(unit_name: String, origin: Vector3, selected: bool, role: String) -> void:
	var root := Node3D.new()
	root.name = unit_name
	root.position = origin
	composition_root.add_child(root)
	_unit_shadow(root, unit_name + "ContactShadow", 0.40)
	var torso := CylinderMesh.new()
	torso.top_radius = 0.26
	torso.bottom_radius = 0.36
	torso.height = 0.86
	torso.radial_segments = 6
	var body := MeshInstance3D.new()
	body.name = unit_name + "MilitiaTorso"
	body.mesh = torso
	body.position.y = 0.66
	body.material_override = _material(Color("#4c5a58"), 0.84)
	root.add_child(body)
	_add_unit_box(root, unit_name + "MilitiaShoulder", Vector3(0.0, 0.98, 0.0), Vector3(0.78, 0.18, 0.30), Color("#566b68"), 0.82)
	_add_unit_limb(root, unit_name + "MilitiaArmL", Vector3(-0.38, 0.72, 0.02), Vector3(0.15, 0.68, 0.15), -10.0, Color("#52635d"))
	_add_unit_limb(root, unit_name + "MilitiaArmR", Vector3(0.38, 0.72, 0.02), Vector3(0.15, 0.68, 0.15), 10.0, Color("#52635d"))
	_add_unit_limb(root, unit_name + "MilitiaLegL", Vector3(-0.17, 0.20, 0.02), Vector3(0.17, 0.48, 0.17), -2.0, Color("#363f3d"))
	_add_unit_limb(root, unit_name + "MilitiaLegR", Vector3(0.17, 0.20, 0.02), Vector3(0.17, 0.48, 0.17), 2.0, Color("#323a39"))
	_add_unit_box(root, unit_name + "MilitiaBootL", Vector3(-0.18, 0.04, 0.12), Vector3(0.23, 0.12, 0.34), Color("#292e2d"), 0.80)
	_add_unit_box(root, unit_name + "MilitiaBootR", Vector3(0.18, 0.04, 0.12), Vector3(0.23, 0.12, 0.34), Color("#292e2d"), 0.80)
	var head := SphereMesh.new()
	head.radius = 0.22
	head.height = 0.44
	head.radial_segments = 8
	head.rings = 4
	var head_node := MeshInstance3D.new()
	head_node.name = unit_name + "MilitiaHead"
	head_node.mesh = head
	head_node.position = Vector3(0.0, 1.32, 0.0)
	head_node.material_override = _material(Color("#9b8068"), 0.88)
	root.add_child(head_node)
	_add_unit_box(root, unit_name + "MilitiaHelm", Vector3(0.0, 1.55, 0.0), Vector3(0.52, 0.14, 0.52), Color("#46504e"), 0.80)
	_add_unit_box(root, unit_name + "MilitiaShield", Vector3(-0.54, 0.72, 0.08), Vector3(0.14, 0.86, 0.64), Color("#765946"), 0.86)
	_add_unit_box(root, unit_name + "MilitiaShieldBoss", Vector3(-0.64, 0.72, 0.08), Vector3(0.08, 0.18, 0.18), Color("#b08d55"), 0.78)
	_add_unit_limb(root, unit_name + "MilitiaSpear", Vector3(0.56, 0.86, 0.02), Vector3(0.09, 1.54, 0.09), -14.0, Color("#3c342b"))
	_add_unit_box(root, unit_name + "MilitiaSpearHead", Vector3(0.75, 1.66, 0.02), Vector3(0.20, 0.18, 0.12), Color("#8d958c"), 0.74)
	_add_unit_box(root, unit_name + "MilitiaFactionAccent", Vector3(0.28, 0.94, 0.20), Vector3(0.11, 0.40, 0.08), Color("#708f86"), 0.80)
	_add_selection(root, unit_name + "SelectionRing", Color("#78a99d"), selected)
	v0308_unit_contracts.append({"id": unit_name, "role": role, "selected": selected, "sameGameplayFootprint": true, "presentation": "authored low-poly 3D"})

func _add_v0308_comparison(unit_name: String, origin: Vector3) -> void:
	var root := Node3D.new()
	root.name = unit_name
	root.position = origin
	composition_root.add_child(root)
	_unit_shadow(root, unit_name + "ContactShadow", 0.38)
	_add_unit_box(root, unit_name + "HybridBody", Vector3(0.0, 0.64, 0.0), Vector3(0.55, 0.92, 0.25), Color("#5a625d"), 0.82)
	_add_unit_box(root, unit_name + "BillboardDetail", Vector3(0.0, 0.92, -0.12), Vector3(0.62, 1.18, 0.05), Color("#806f59"), 0.82)
	v0308_unit_contracts.append({"id": unit_name, "role": "v0307 U3 comparison", "selected": false, "sameGameplayFootprint": true, "presentation": "retained hybrid comparison"})

func _add_unit_box(parent: Node3D, label: String, position: Vector3, size: Vector3, color: Color, roughness: float) -> MeshInstance3D:
	return _add_box_to(parent, label, position, size, color, roughness)

func _add_unit_limb(parent: Node3D, label: String, position: Vector3, size: Vector3, rotation_z: float, color: Color) -> MeshInstance3D:
	var limb := _add_box_to(parent, label, position, size, color, 0.86)
	limb.rotation_degrees.z = rotation_z
	return limb

func _add_selection(parent: Node3D, label: String, color: Color, selected: bool) -> void:
	var ring := CylinderMesh.new()
	ring.top_radius = 0.54
	ring.bottom_radius = 0.54
	ring.height = 0.025
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = ring
	node.position.y = 0.055
	node.visible = selected
	node.material_override = _material(Color(color.r, color.g, color.b, 0.34), 0.96)
	(node.material_override as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	(node.material_override as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	parent.add_child(node)

func _build_overlay() -> void:
	v0308_hud = CanvasLayer.new()
	v0308_hud.name = "V0308FinalPreIntegrationOverlay"
	add_child(v0308_hud)
	var header := ColorRect.new()
	header.position = Vector2(34, 24)
	header.size = Vector2(760, 68)
	header.color = Color(0.025, 0.045, 0.040, 0.93)
	v0308_hud.add_child(header)
	var title := Label.new()
	title.position = Vector2(18, 8)
	title.text = "ROUTE C FINAL PROOF  |  SALTO EAST BRIDGE"
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", Color("#eddbad"))
	header.add_child(title)
	v0308_note = Label.new()
	v0308_note.position = Vector2(18, 39)
	v0308_note.text = "AUTHORED U3-W / U3-M  •  NATURAL BANKS  •  FINISHED BARROSAN STOREHOUSE"
	v0308_note.add_theme_font_size_override("font_size", 12)
	v0308_note.add_theme_color_override("font_color", Color("#b9c8b7"))
	header.add_child(v0308_note)
	var card := Panel.new()
	card.name = "V0308SelectedProofCard"
	card.position = Vector2(1115, 716)
	card.size = Vector2(440, 128)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.045, 0.040, 0.94), Color("#718e7d")))
	v0308_hud.add_child(card)
	var body := Label.new()
	body.position = Vector2(18, 12)
	body.text = "SELECTED PROOF UNIT\nAuthored low-poly body • same footprint semantics\nNo gameplay state • no global instruction overlap"
	body.add_theme_font_size_override("font_size", 13)
	body.add_theme_color_override("font_color", Color("#d3dccf"))
	card.add_child(body)
	var legend := Label.new()
	legend.position = Vector2(38, 834)
	legend.text = "REFERENCE-ONLY PROTOTYPE  /  WATER FLOW + TERRAIN CONTACT  /  U3-W WORKER + U3-M MILITIA"
	legend.add_theme_font_size_override("font_size", 12)
	legend.add_theme_color_override("font_color", Color("#c9d0ae"))
	v0308_hud.add_child(legend)

func _set_note(value: String) -> void:
	if v0308_note != null:
		v0308_note.text = value

func _set_atmosphere(enabled: bool) -> void:
	v0308_capture_state["atmosphere"] = enabled
	if v0308_world != null and v0308_world.environment != null:
		v0308_world.environment.fog_enabled = enabled

func _set_water_motion(enabled: bool) -> void:
	v0308_capture_state["waterMotion"] = enabled
	for node in v0308_flow_nodes:
		if is_instance_valid(node):
			node.visible = enabled

func _capture_views() -> void:
	_set_note("PRIMARY GAMEPLAY OVERVIEW  •  authored terrain, bridge, river, storehouse, U3 units")
	await _capture("01_v0308_gameplay_overview.png", V0308_CAMERA_OBLIQUE, V0308_TARGET, V0308_ORTHO_SIZE)
	_set_note("DIRECT TOP-DOWN COMPARISON  •  tactical footprint remains legible")
	await _capture("02_v0308_top_down.png", V0308_CAMERA_TOP_DOWN, Vector3(0.0, 0.0, 2.0), V0308_ORTHO_SIZE)
	_set_note("WORKER SELECTED  •  clear head, body, limbs, boots, pack, pickaxe")
	await _capture("03_v0308_worker_selected_gameplay.png", V0308_CAMERA_OBLIQUE, Vector3(-7.2, 0.65, 4.0), 8.0)
	_set_note("WORKER UNSELECTED  •  grounded silhouette")
	await _capture("04_v0308_worker_unselected_gameplay.png", V0308_CAMERA_ALTERNATE, Vector3(-9.0, 0.65, 0.5), 7.0)
	_set_note("MILITIA SELECTED  •  shield, spear, helm, faction accent")
	await _capture("05_v0308_militia_selected_gameplay.png", V0308_CAMERA_OBLIQUE, Vector3(1.0, 0.70, 3.7), 7.0)
	_set_note("MILITIA UNSELECTED  •  distinct military silhouette")
	await _capture("06_v0308_militia_unselected_gameplay.png", V0308_CAMERA_ALTERNATE, Vector3(8.2, 0.65, -5.8), 7.0)
	_set_note("WORKER + MILITIA TOGETHER  •  role differentiation")
	await _capture("07_v0308_worker_militia_together.png", V0308_CAMERA_OBLIQUE, Vector3(-5.4, 0.6, 4.0), 10.0)
	_set_note("U3 GROUP 8 UNITS  •  gameplay-scale density test")
	await _capture("08_v0308_u3_group_8_units.png", V0308_CAMERA_OBLIQUE, Vector3(-7.3, 0.5, 7.7), 12.0)
	await _capture("09_v0308_u3_road_background.png", V0308_CAMERA_OBLIQUE, Vector3(-7.4, 0.5, 1.0), 9.0)
	await _capture("10_v0308_u3_bridge_background.png", V0308_CAMERA_OBLIQUE, Vector3(3.5, 0.5, 1.8), 10.0)
	await _capture("11_v0308_u3_shoreline_background.png", V0308_CAMERA_ALTERNATE, Vector3(6.3, 0.5, -4.0), 9.0)
	_set_note("ALTERNATE OBLIQUE  •  front/side/rear authored geometry read")
	await _capture("12_v0308_u3_alternate_oblique.png", V0308_CAMERA_ALTERNATE, V0308_TARGET, V0308_ORTHO_SIZE)
	await _capture("13_v0308_u3_top_down.png", V0308_CAMERA_TOP_DOWN, Vector3(0.0, 0.0, 3.0), 19.0)
	_set_note("NATURAL EDGE TEST  •  broken shoulders, wet soil, embedded stones")
	await _capture("14_v0308_terrain_edge_gameplay.png", V0308_CAMERA_OBLIQUE, Vector3(1.0, 0.0, -5.0), 15.0)
	await _capture("15_v0308_terrain_edge_close.png", V0308_CAMERA_ALTERNATE, Vector3(1.8, -0.05, -6.2), 9.0)
	_set_note("FLOW ON  •  directional bands, shallow/deep shelves, contact foam")
	_set_water_motion(true)
	await _capture("16_v0308_river_flow_on.png", V0308_CAMERA_OBLIQUE, Vector3(4.0, -0.15, 1.0), 18.0)
	_set_note("FLOW OFF  •  deterministic readability comparison")
	_set_water_motion(false)
	await _capture("17_v0308_river_flow_off.png", V0308_CAMERA_OBLIQUE, Vector3(4.0, -0.15, 1.0), 18.0)
	_set_water_motion(true)
	await _capture("18_v0308_river_contact_close.png", V0308_CAMERA_ALTERNATE, Vector3(4.0, -0.25, -0.8), 10.0)
	await _capture("19_v0308_bridge_contact_gameplay.png", V0308_CAMERA_OBLIQUE, Vector3(4.0, 0.45, 0.0), 11.0)
	_set_note("COMPLETED BARROSAN STOREHOUSE  •  roof, ridge, eaves, gutter, drain, entrance")
	await _capture("20_v0308_utility_building_gameplay.png", V0308_CAMERA_OBLIQUE, Vector3(10.5, 1.0, 6.0), 11.0)
	await _capture("21_v0308_utility_building_close.png", V0308_CAMERA_ALTERNATE, Vector3(10.5, 1.8, 6.0), 7.5)
	await _capture("22_v0308_utility_building_side_rear.png", Vector3(-14.0, 8.0, 13.0), Vector3(10.5, 1.8, 6.0), 8.5)
	await _capture("23_v0308_utility_building_top_down.png", V0308_CAMERA_TOP_DOWN, Vector3(10.5, 0.0, 6.0), 8.0)
	_set_note("MATERIAL HIERARCHY  •  damp grass, earth, road, wet stone, timber, slate, deep water")
	await _capture("24_v0308_material_hierarchy.png", V0308_CAMERA_OBLIQUE, Vector3(7.0, 0.3, 4.0), 19.0)
	_set_note("ATMOSPHERE OFF")
	_set_atmosphere(false)
	await _capture("25_v0308_atmosphere_off.png", V0308_CAMERA_OBLIQUE, V0308_TARGET, V0308_ORTHO_SIZE)
	_set_note("ATMOSPHERE ON  •  restrained highland haze")
	_set_atmosphere(true)
	await _capture("26_v0308_atmosphere_on.png", V0308_CAMERA_OBLIQUE, V0308_TARGET, V0308_ORTHO_SIZE)
	_set_note("NO-SELECTION CLEAN VIEW  •  no proof overlay beyond capture title")
	await _capture("27_v0308_no_selection_clean.png", V0308_CAMERA_OBLIQUE, V0308_TARGET, V0308_ORTHO_SIZE)
	_set_note("OVERLAP / OCCLUSION TEST  •  readable group and building separation")
	await _capture("28_v0308_overlap_occlusion_test.png", V0308_CAMERA_OBLIQUE, Vector3(-1.0, 0.4, 5.8), 14.0)
	_set_note("ISOLATION PROOF  •  prototype only, no gameplay/state mutation")
	await _capture("29_v0308_isolation_proof.png", V0308_CAMERA_OBLIQUE, V0308_TARGET, V0308_ORTHO_SIZE)

func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0308-route-c-final-pre-integration-proof-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": V0308_CHECKPOINT,
		"status": "PASS_V0308_ROUTE_C_FINAL_PRE_INTEGRATION_PROOF" if errors.is_empty() else "FAIL_V0308_ROUTE_C_FINAL_PRE_INTEGRATION_PROOF",
		"prototypeOnly": true,
		"prototypeOptIn": true,
		"scenePath": V0308_SCENE_PATH,
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
		"sourceProvenance": "repository-authored Godot low-poly geometry; existing repository-authored v0.236 kit and v0.307 proof assets remain reference/support only",
		"referenceOnly": ["v0.141 R1 historical image", "v0.303 fallback/debug renderer", "v0.307 U3 comparison"],
		"terrain": {"microSliceBounded": true, "naturalEdges": true, "bankCuts": true, "wetSoilTransition": true, "rectangularPlates": false, "floatingPlates": false, "walkabilityDimensionsPreserved": true, "authoredNodes": v0308_authored_nodes},
		"river": {"deepChannel": true, "shallowShelf": true, "flowMotionToggle": true, "visibleFlowDirection": true, "foamDisturbance": true, "rockContact": true, "bridgeContact": true, "irregularShoreline": true, "waterBelowLand": true},
		"utilityBuilding": {"role": "finished Barrosan utility storehouse", "completedRoof": true, "ridge": true, "eaves": true, "drainage": true, "entrance": true, "foundation": true, "sideRear": true, "gameplayFootprintChanged": false},
		"unitContracts": v0308_unit_contracts,
		"unitStrategies": {"U3W": {"name": "authored Barrosan worker/pioneer", "selectedEvidence": true, "unselectedEvidence": true, "sameGameplayFootprint": true}, "U3M": {"name": "authored Barrosan militia/defender", "selectedEvidence": true, "unselectedEvidence": true, "sameGameplayFootprint": true}, "V0307U3Comparison": {"present": true, "referenceOnly": true}},
		"camera": {"projection": "orthographic", "primary": V0308_CAMERA_OBLIQUE, "alternate": V0308_CAMERA_ALTERNATE, "topDown": V0308_CAMERA_TOP_DOWN, "orthoSize": V0308_ORTHO_SIZE, "gameplayFraming": true},
		"atmosphere": {"offCapture": "25_v0308_atmosphere_off.png", "onCapture": "26_v0308_atmosphere_on.png", "fogDensity": 0.0010},
		"waterMotion": {"onCapture": "16_v0308_river_flow_on.png", "offCapture": "17_v0308_river_flow_off.png", "deterministic": true},
		"captures": captures,
		"newRuntimeArtSlots": 0,
		"integrationDecision": "REVISE_ONCE_MORE",
		"recommendedV0309": "v0.309 — Route C final authored silhouette and terrain-edge correction before integration gate",
		"errors": errors,
	})
