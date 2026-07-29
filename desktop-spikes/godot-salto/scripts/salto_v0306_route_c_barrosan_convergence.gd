extends "res://scripts/salto_v0305_route_c_representative_sector.gd"

const V0306_CHECKPOINT := "v0.306"
const V0306_SCENE_PATH := "res://scenes/salto_v0306_route_c_barrosan_convergence.tscn"
const V0306_CAMERA_OBLIQUE := Vector3(24.0, 23.0, 27.0)
const V0306_CAMERA_ALT := Vector3(-22.0, 20.0, 25.0)
const V0306_CAMERA_TOP := Vector3(0.0, 28.0, 0.01)
const V0306_TARGET := Vector3(0.0, 0.20, 1.0)
const V0306_ORTHO_SIZE := 28.0

var v0306_capture_note: Label
var v0306_selection_rings: Dictionary = {}
var v0306_revision_nodes: Array[String] = []
var v0306_flow_nodes: Array[String] = []

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#303d3b")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#a3b0a9")
	environment.ambient_light_energy = 0.78
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = true
	environment.fog_light_color = Color("#7f918d")
	environment.fog_light_energy = 0.18
	environment.fog_density = 0.0015
	var world := WorldEnvironment.new()
	world.name = "V0306BarrosanOvercastEnvironment"
	world.environment = environment
	add_child(world)

	var key := DirectionalLight3D.new()
	key.name = "V0306FilteredMountainKey"
	key.rotation_degrees = Vector3(-50.0, -38.0, 0.0)
	key.light_color = Color("#d8d9ca")
	key.light_energy = 1.08
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 100.0
	key.directional_shadow_split_1 = 0.12
	key.directional_shadow_split_2 = 0.40
	add_child(key)

	var fill := DirectionalLight3D.new()
	fill.name = "V0306ColdSkyFill"
	fill.rotation_degrees = Vector3(-24.0, 142.0, 0.0)
	fill.light_color = Color("#75909a")
	fill.light_energy = 0.38
	fill.shadow_enabled = false
	add_child(fill)

	camera = Camera3D.new()
	camera.name = "V0306RouteCConvergenceCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.1
	camera.far = 220.0
	camera.current = true
	add_child(camera)

func _tune_material(material: StandardMaterial3D) -> void:
	super._tune_material(material)
	match material.resource_name:
		"MAT_Grass": material.albedo_color = Color("#4c5f52")
		"MAT_Earth": material.albedo_color = Color("#51493f")
		"MAT_RoadDirt": material.albedo_color = Color("#665c50")
		"MAT_Stone": material.albedo_color = Color("#686f6d")
		"MAT_StoneLight": material.albedo_color = Color("#8d9289")
		"MAT_StoneWarm": material.albedo_color = Color("#71695c")
		"MAT_StoneDark": material.albedo_color = Color("#292e2d")
		"MAT_StoneMoss": material.albedo_color = Color("#536358")
		"MAT_Roof": material.albedo_color = Color("#554943")
		"MAT_RoofClay": material.albedo_color = Color("#665047")
		"MAT_RoofDark": material.albedo_color = Color("#332d2b")
		"MAT_RoofAged": material.albedo_color = Color("#4c413d")
		"MAT_Wood": material.albedo_color = Color("#594d43")
		"MAT_WoodLight": material.albedo_color = Color("#74695b")
		"MAT_WoodDark": material.albedo_color = Color("#292523")
		"MAT_WoodWeathered": material.albedo_color = Color("#62584e")
		"MAT_EaveDark": material.albedo_color = Color("#222221")
		"MAT_Plaster": material.albedo_color = Color("#8c8b7d")
		"MAT_PlasterLight": material.albedo_color = Color("#aaa896")
		"MAT_PlasterWarm": material.albedo_color = Color("#7c776b")
		"MAT_PlasterShadow": material.albedo_color = Color("#66655e")
		"MAT_IronDark": material.albedo_color = Color("#242a2b")
		"MAT_BannerRed": material.albedo_color = Color("#713a36")
		"MAT_BannerGold": material.albedo_color = Color("#a38d5e")
	material.roughness = max(material.roughness, 0.68)

func _build_composition() -> void:
	composition_root = Node3D.new()
	composition_root.name = "V0306RouteCBarrosanConvergenceSector"
	add_child(composition_root)
	_build_converged_terrain()
	_build_converged_river()
	_build_converged_roads()
	_build_converged_bridge()
	_build_converged_buildings()
	_build_converged_dressing()
	_build_converged_units()

func _build_converged_terrain() -> void:
	var west := [Vector2(-18.0, -13.5), Vector2(-13.5, -16.0), Vector2(-3.0, -16.8), Vector2(1.42, -15.7), Vector2(1.42, 15.5), Vector2(-1.0, 16.2), Vector2(-11.0, 15.2), Vector2(-17.5, 10.5), Vector2(-19.0, 1.0)]
	var east := [Vector2(6.55, -15.7), Vector2(10.0, -15.5), Vector2(17.5, -11.5), Vector2(18.5, -2.0), Vector2(17.0, 8.5), Vector2(11.5, 14.5), Vector2(6.55, 15.7)]
	_add_extruded_terrain("ConvergedWestLandMass", west, 0.0, -0.88)
	_add_extruded_terrain("ConvergedEastLandMass", east, 0.0, -0.88)
	_add_slope_surface("WestUpperTerrace", Vector3(-11.5, 0.12, -8.5), Vector2(10.5, 7.0), 0.42, Color("#536455"))
	_add_slope_surface("EastUpperTerrace", Vector3(12.4, 0.10, -8.8), Vector2(8.0, 6.4), 0.34, Color("#536255"))
	_add_slope_surface("WestBankShoulder", Vector3(0.65, 0.08, 6.0), Vector2(2.2, 9.0), 0.25, Color("#5a6256"))
	_add_slope_surface("EastBankShoulder", Vector3(7.35, 0.08, -5.7), Vector2(2.0, 8.5), 0.22, Color("#596157"))
	for config in [
		["MossPatch_West", Vector2(-14.0, -3.5), Vector2(4.0, 1.6), -12.0, 0.09, Color("#506551")],
		["MossPatch_South", Vector2(-6.0, 12.2), Vector2(4.8, 1.5), 9.0, 0.08, Color("#536953")],
		["MossPatch_East", Vector2(13.6, 10.5), Vector2(3.7, 1.3), -8.0, 0.08, Color("#4a5f50")],
		["DampEarth_West", Vector2(-4.0, -12.5), Vector2(4.6, 1.8), 4.0, 0.07, Color("#5d5548")],
	]:
		_add_ellipse_patch(str(config[0]), config[1], config[2], float(config[3]), float(config[4]), config[5])
	for config in [
		["prop_rock_cluster", Vector3(-15.8, 0.0, -10.7), -12.0, 0.70],
		["prop_rock_cluster", Vector3(-2.2, 0.0, -8.4), 14.0, 0.62],
		["prop_rock_cluster", Vector3(12.3, 0.0, 10.7), -9.0, 0.58],
		["prop_rock_cluster", Vector3(-15.0, 0.0, 11.8), 11.0, 0.54],
	]:
		_place_prop(str(config[0]), config[1], float(config[2]), float(config[3]))
		v0306_revision_nodes.append("embedded_%s" % str(config[0]))

func _build_converged_river() -> void:
	var centers := [Vector2(4.0, -15.0), Vector2(4.3, -11.5), Vector2(3.7, -8.0), Vector2(4.15, -4.0), Vector2(3.95, 0.0), Vector2(4.35, 4.0), Vector2(3.8, 8.0), Vector2(4.2, 11.8), Vector2(4.0, 15.0)]
	var widths := [4.0, 4.35, 4.15, 4.45, 4.2, 4.5, 4.2, 4.3, 4.0]
	_add_ribbon("ConvergedRiverDepth", centers, widths.map(func(value): return float(value) + 2.0), -0.34, Color("#303c3b"), 0.98, "riverbank")
	_add_ribbon("ConvergedRiverSoilBank", centers, widths.map(func(value): return float(value) + 0.92), -0.18, Color("#5e584c"), 0.94, "riverbank")
	_add_ribbon("ConvergedRiverMossEdge", centers, widths.map(func(value): return float(value) + 0.30), -0.10, Color("#465e54"), 0.80, "riverbank")
	_add_ribbon("ConvergedRiverWater", centers, widths, -0.48, Color("#29474c"), 0.18, "river")
	var flow_a := [Vector2(3.85, -13.8), Vector2(4.1, -9.5), Vector2(3.8, -5.3), Vector2(4.0, -1.0), Vector2(4.15, 3.5), Vector2(3.9, 7.8), Vector2(4.1, 12.8)]
	_add_ribbon("RiverFlowMutedA", flow_a, [0.18, 0.24, 0.16, 0.22, 0.17, 0.23, 0.16], -0.455, Color("#6e8985"), 0.32, "river")
	var flow_b := [Vector2(4.45, -12.0), Vector2(4.2, -7.3), Vector2(4.5, -2.7), Vector2(4.3, 2.0), Vector2(4.5, 6.4), Vector2(4.25, 10.7)]
	_add_ribbon("RiverFlowMutedB", flow_b, [0.11, 0.16, 0.12, 0.15, 0.10, 0.14], -0.448, Color("#89a09a"), 0.30, "river")
	for config in [
		["prop_rock_cluster", Vector3(1.65, -0.05, -7.2), 8.0, 0.40],
		["prop_rock_cluster", Vector3(6.45, -0.05, 8.0), -11.0, 0.38],
		["prop_rock_cluster", Vector3(1.45, -0.05, 11.5), 16.0, 0.34],
	]:
		_place_prop(str(config[0]), config[1], float(config[2]), float(config[3]))
		v0306_flow_nodes.append("shoreline_%s" % str(config[0]))

func _build_converged_roads() -> void:
	_add_converged_road("ConvergedWestRoad", [Vector2(-17.5, 0.0), Vector2(-13.5, 0.1), Vector2(-9.5, 0.0), Vector2(-5.5, 0.1), Vector2(-1.0, 0.0)])
	_add_converged_road("ConvergedEastRoad", [Vector2(8.8, 0.0), Vector2(12.0, 0.1), Vector2(15.0, 0.0), Vector2(17.6, 0.2)])
	_add_converged_road("ConvergedBarracksRoad", [Vector2(-9.5, 0.0), Vector2(-9.8, 2.0), Vector2(-10.2, 4.1), Vector2(-10.5, 5.4)])

func _add_converged_road(label: String, points: Array) -> void:
	var widths := []
	for _point in points:
		widths.append(2.18)
	_add_ribbon(label + "Shoulder", points, widths.map(func(value): return float(value) + 0.72), 0.015, Color("#4c4b45"), 0.98, "road")
	_add_ribbon(label + "Surface", points, widths, 0.045, Color("#69635a"), 0.92, "road")
	_add_ribbon(label + "Wear", points, widths.map(func(value): return float(value) * 0.26), 0.07, Color("#858074"), 0.90, "road")

func _build_converged_bridge() -> void:
	var bridge_root := Node3D.new()
	bridge_root.name = "V0306WeatheredBridge"
	composition_root.add_child(bridge_root)
	_add_box_to(bridge_root, "WeatheredBridgeDeck", Vector3(4.0, 0.54, 0.0), Vector3(9.0, 0.42, 3.25), Color("#4e4942"), 0.92)
	for index in range(8):
		var x := -0.1 + float(index) * 1.15
		_add_box_to(bridge_root, "WeatheredBridgePlank_%02d" % index, Vector3(x, 0.79, 0.0), Vector3(0.18, 0.10, 3.0), Color("#81776a" if index % 3 else "#625c55"), 0.94)
	for z in [-1.58, 1.58]:
		_add_box_to(bridge_root, "DarkBridgeRail_%s" % str(z), Vector3(4.0, 1.35, z), Vector3(9.0, 0.14, 0.14), Color("#292a29"), 0.78)
		for index in range(7):
			_add_box_to(bridge_root, "DarkBridgePost_%s_%02d" % [str(z), index], Vector3(-0.1 + float(index) * 1.35, 1.02, z), Vector3(0.14, 0.72, 0.14), Color("#3a3936"), 0.80)
	for x in [0.0, 8.0]:
		_add_box_to(bridge_root, "DampStonePier_%s" % str(x), Vector3(x, 0.05, 0.0), Vector3(0.75, 0.42, 3.8), Color("#646b69"), 0.94)
	_add_ellipse_patch("BridgeWestMossContact", Vector2(-0.7, 0.0), Vector2(3.3, 2.9), 0.0, 0.06, Color("#536055"))
	_add_ellipse_patch("BridgeEastMossContact", Vector2(8.7, 0.0), Vector2(3.3, 2.9), 0.0, 0.06, Color("#536055"))

func _build_converged_buildings() -> void:
	var barracks := _place_module("barracks_workshop_landmark", Vector3(-10.6, 0.07, 6.2), 2.0, Vector3(0.72, 0.72, 0.72))
	if barracks != null:
		barracks.name = "V0306FieldBarracks"
		v0306_revision_nodes.append("V0306FieldBarracks")
	_build_converged_support_building(Vector3(10.5, 0.0, 6.0))

func _build_converged_support_building(origin: Vector3) -> void:
	var building := Node3D.new()
	building.name = "V0306SupportUtilityBuilding"
	building.position = origin
	composition_root.add_child(building)
	_add_box_to(building, "SupportFoundation", Vector3(0.0, 0.12, 0.0), Vector3(4.5, 0.24, 3.35), Color("#4b504b"), 0.96)
	_add_box_to(building, "SupportStoneWall", Vector3(0.0, 1.12, 0.0), Vector3(3.65, 1.95, 2.65), Color("#6d7169"), 0.94)
	_add_box_to(building, "SupportDarkTimberFront", Vector3(0.0, 1.18, 1.38), Vector3(3.82, 0.16, 0.16), Color("#302f2c"), 0.82)
	_add_box_to(building, "SupportDoor", Vector3(0.0, 0.72, 1.42), Vector3(0.70, 1.18, 0.11), Color("#292a28"), 0.80)
	_add_gabled_roof(building, "SupportCoherentGabledRoof", Vector3(0.0, 2.05, 0.0), Vector3(4.25, 1.25, 3.05), Color("#4d4845"))
	_add_box_to(building, "SupportRidgeCap", Vector3(0.0, 2.92, 0.0), Vector3(0.18, 0.18, 3.20), Color("#292a29"), 0.78)
	_add_box_to(building, "SupportMossLedge", Vector3(-1.75, 0.30, 1.38), Vector3(0.45, 0.12, 0.14), Color("#526356"), 0.92)
	v0306_revision_nodes.append("V0306SupportUtilityBuilding")

func _build_converged_dressing() -> void:
	for config in [
		["prop_tree", Vector3(-16.0, 0.0, -10.5), -8.0, 0.70],
		["prop_tree", Vector3(15.8, 0.0, -10.5), 12.0, 0.66],
		["prop_tree", Vector3(-17.0, 0.0, 5.5), 5.0, 0.62],
		["prop_crate_stack", Vector3(-14.0, 0.0, 8.4), 8.0, 0.50],
		["prop_log_stack", Vector3(-15.6, 0.0, 9.8), -10.0, 0.48],
	]:
		_place_prop(str(config[0]), config[1], float(config[2]), float(config[3]))

func _build_converged_units() -> void:
	_add_converged_unit("Aster", Vector3(-3.0, 0.07, 3.4), ASTER_SPRITE_PATH, Color("#b6a87c"), true, 1.24)
	_add_converged_unit("Defender", Vector3(6.8, 0.07, 3.2), DEFENDER_SPRITE_PATH, Color("#71998f"), false, 1.02)
	_add_converged_unit("ReserveSupport", Vector3(11.2, 0.07, 3.9), RESERVE_SPRITE_PATH, Color("#9b876e"), false, 0.98)

func _add_converged_unit(unit_name: String, position: Vector3, texture_path: String, accent: Color, selected: bool, scale_value: float) -> void:
	var root := Node3D.new()
	root.name = "V0306Unit_%s" % unit_name
	root.position = position
	composition_root.add_child(root)
	var shadow := CylinderMesh.new()
	shadow.top_radius = 0.34 * scale_value
	shadow.bottom_radius = 0.34 * scale_value
	shadow.height = 0.022
	var shadow_node := MeshInstance3D.new()
	shadow_node.name = "%s_DirectionalGrounding" % unit_name
	shadow_node.mesh = shadow
	shadow_node.position = Vector3(0.18, 0.025, 0.14)
	var shadow_material := _material(Color(0.12, 0.15, 0.14, 0.30), 1.0)
	shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow_node.material_override = shadow_material
	shadow_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(shadow_node)

	var sprite := MeshInstance3D.new()
	sprite.name = "%s_HybridBillboard" % unit_name
	var quad := QuadMesh.new()
	quad.size = Vector2(0.92 * scale_value, 1.62 * scale_value)
	sprite.mesh = quad
	sprite.position = Vector3(0.0, 0.86 * scale_value, 0.0)
	var sprite_material := StandardMaterial3D.new()
	sprite_material.albedo_texture = load(texture_path) as Texture2D
	sprite_material.albedo_color = Color(0.90, 0.92, 0.86, 1.0)
	sprite_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sprite_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sprite_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	sprite.material_override = sprite_material
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(sprite)

	var role_accent := _add_box_to(root, "%s_RoleAccent" % unit_name, Vector3(0.30, 0.88, 0.02), Vector3(0.10, 0.48, 0.08), accent, 0.82)
	role_accent.rotation_degrees.z = -22.0 if unit_name != "Defender" else 18.0
	if selected:
		var ring := CylinderMesh.new()
		ring.top_radius = 0.43 * scale_value
		ring.bottom_radius = 0.43 * scale_value
		ring.height = 0.025
		var ring_node := MeshInstance3D.new()
		ring_node.name = "%s_SelectionTreatment" % unit_name
		ring_node.mesh = ring
		ring_node.position = Vector3(0.0, 0.045, 0.0)
		var ring_material := _material(Color(accent.r, accent.g, accent.b, 0.34), 0.94)
		ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring_node.material_override = ring_material
		ring_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(ring_node)
		v0306_selection_rings[unit_name] = ring_node
	v0305_unit_nodes.append({"name": unit_name, "position": {"x": position.x, "y": position.y, "z": position.z}, "billboard": true, "hybridRoleAccent": true, "selected": selected})

func _add_slope_surface(label: String, center: Vector3, size: Vector2, height: float, color: Color) -> void:
	var half_x := size.x * 0.5
	var half_z := size.y * 0.5
	var vertices := PackedVector3Array([
		Vector3(center.x - half_x, center.y, center.z - half_z), Vector3(center.x + half_x, center.y + height * 0.18, center.z - half_z),
		Vector3(center.x + half_x, center.y + height * 0.35, center.z + half_z), Vector3(center.x - half_x, center.y + height * 0.12, center.z + half_z),
		Vector3(center.x - half_x, center.y - 0.55, center.z - half_z), Vector3(center.x + half_x, center.y - 0.55, center.z - half_z),
		Vector3(center.x + half_x, center.y - 0.55, center.z + half_z), Vector3(center.x - half_x, center.y - 0.55, center.z + half_z),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6, 0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2, 2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0])
	_add_mesh_surface(label, vertices, indices, color, 0.96)
	v0306_revision_nodes.append(label)

func _add_gabled_roof(parent: Node3D, label: String, center: Vector3, size: Vector3, color: Color) -> void:
	var half_w := size.x * 0.5
	var half_d := size.z * 0.5
	var base_y := -size.y * 0.5
	var ridge_y := size.y * 0.5
	var vertices := PackedVector3Array([
		Vector3(-half_w, base_y, -half_d), Vector3(0.0, ridge_y, -half_d), Vector3(half_w, base_y, -half_d),
		Vector3(-half_w, base_y, half_d), Vector3(0.0, ridge_y, half_d), Vector3(half_w, base_y, half_d),
	])
	var indices := PackedInt32Array([0, 1, 2, 3, 5, 4, 0, 3, 4, 0, 4, 1, 1, 4, 5, 1, 5, 2, 2, 5, 3, 2, 3, 0])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.position = center
	instance.material_override = _material(color, 0.88)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	v0306_revision_nodes.append(label)

func _build_overlay() -> void:
	super._build_overlay()
	v0306_capture_note = Label.new()
	v0306_capture_note.position = Vector2(52, 89)
	v0306_capture_note.text = "v0.306 convergence revision"
	v0306_capture_note.add_theme_font_size_override("font_size", 13)
	v0306_capture_note.add_theme_color_override("font_color", Color("#a8b9ad"))
	v0305_hud_layer.add_child(v0306_capture_note)

func _set_capture_note(text: String) -> void:
	if v0306_capture_note != null:
		v0306_capture_note.text = text

func _set_selection(unit_name: String, visible: bool) -> void:
	if v0306_selection_rings.has(unit_name):
		(v0306_selection_rings[unit_name] as Node3D).visible = visible

func _capture_views() -> void:
	_set_capture_note("OBLIQUE GAMEPLAY OVERVIEW  •  damp highland palette")
	await _capture("01_v0306_overview_oblique.png", V0306_CAMERA_OBLIQUE, V0306_TARGET, V0306_ORTHO_SIZE)
	_set_capture_note("TOP-DOWN COMPARISON  •  terrain breakup remains tactical")
	await _capture("02_v0306_top_down_comparison.png", V0306_CAMERA_TOP, Vector3(0.0, 0.0, 1.0), V0306_ORTHO_SIZE)
	_set_capture_note("TERRAIN SHOULDERS + EMBEDDED ROAD")
	await _capture("03_v0306_terrain_road_integration.png", Vector3(16.0, 16.0, 20.0), Vector3(0.0, 0.15, 2.0), 20.0)
	_set_capture_note("RIVER FLOW + SHORELINE CONTACT")
	await _capture("04_v0306_river_shoreline.png", Vector3(15.0, 14.0, 18.0), Vector3(4.0, -0.10, 1.0), 16.0)
	_set_capture_note("BRIDGE WEATHERING + WATER CONTACT")
	await _capture("05_v0306_bridge_close.png", Vector3(12.0, 10.0, 14.0), Vector3(4.0, 0.42, 0.0), 11.0)
	_set_capture_note("FIELD BARRACKS — DARK STONE + WEATHERED TIMBER")
	await _capture("06_v0306_field_barracks_overview.png", Vector3(-1.0, 13.0, 17.0), Vector3(-10.5, 1.3, 6.2), 13.0)
	await _capture("07_v0306_field_barracks_close.png", Vector3(-2.0, 8.0, 11.0), Vector3(-10.5, 1.6, 6.2), 8.5)
	_set_capture_note("SUPPORT UTILITY BUILDING — COHERENT GABLE")
	await _capture("08_v0306_support_building_overview.png", Vector3(16.0, 10.0, 15.0), Vector3(10.5, 1.0, 6.0), 10.0)
	await _capture("09_v0306_support_building_close.png", Vector3(15.0, 8.0, 12.0), Vector3(10.5, 1.1, 6.0), 7.5)
	_set_capture_note("BOTH BUILDINGS — ONE BARROSAN MATERIAL FAMILY")
	await _capture("10_v0306_both_buildings_gameplay_frame.png", V0306_CAMERA_OBLIQUE, Vector3(0.0, 0.3, 4.5), 19.0)
	_set_capture_note("ASTER SELECTED — COMPACT SELECTION")
	await _capture("11_v0306_aster_selected.png", Vector3(6.0, 7.0, 10.0), Vector3(-3.0, 0.5, 3.4), 7.0)
	_set_selection("Aster", false)
	_set_capture_note("ASTER UNSELECTED — SILHOUETTE ONLY")
	await _capture("12_v0306_aster_unselected.png", Vector3(6.0, 7.0, 10.0), Vector3(-3.0, 0.5, 3.4), 7.0)
	_set_selection("Defender", true)
	_set_capture_note("DEFENDER SELECTED — ROLE ACCENT")
	await _capture("13_v0306_defender_selected.png", Vector3(12.0, 8.0, 12.0), Vector3(6.8, 0.5, 3.2), 7.0)
	_set_selection("Defender", false)
	_set_capture_note("DEFENDER UNSELECTED")
	await _capture("14_v0306_defender_unselected.png", Vector3(12.0, 8.0, 12.0), Vector3(6.8, 0.5, 3.2), 7.0)
	_set_selection("ReserveSupport", true)
	_set_capture_note("RESERVE SUPPORT SELECTED — ROLE ACCENT")
	await _capture("15_v0306_reserve_selected.png", Vector3(15.0, 8.0, 12.0), Vector3(11.2, 0.5, 3.9), 7.0)
	_set_selection("ReserveSupport", false)
	_set_capture_note("RESERVE SUPPORT UNSELECTED")
	await _capture("16_v0306_reserve_unselected.png", Vector3(15.0, 8.0, 12.0), Vector3(11.2, 0.5, 3.9), 7.0)
	_set_capture_note("ALL THREE — GRASS / ROAD / WATER SILHOUETTES")
	await _capture("17_v0306_all_units_together.png", V0306_CAMERA_OBLIQUE, Vector3(4.0, 0.25, 3.7), 15.0)
	_set_capture_note("UNITS AGAINST ROAD + BRIDGE")
	await _capture("18_v0306_units_near_bridge.png", Vector3(10.0, 8.0, 15.0), Vector3(4.0, 0.4, 3.7), 10.0)
	_set_capture_note("ALTERNATE OBLIQUE — BILLBOARD FACING CHECK")
	await _capture("19_v0306_alternate_oblique_billboard_check.png", V0306_CAMERA_ALT, V0306_TARGET, V0306_ORTHO_SIZE)
	_set_capture_note("NO SELECTION OVERVIEW")
	await _capture("20_v0306_no_selection_overview.png", V0306_CAMERA_OBLIQUE, V0306_TARGET, V0306_ORTHO_SIZE)
	_set_capture_note("PALETTE + MATERIAL COMPARISON FRAME")
	await _capture("21_v0306_palette_material_gameplay.png", Vector3(18.0, 16.0, 22.0), Vector3(0.0, 0.2, 2.0), 22.0)
	_set_capture_note("GAMEPLAY ZOOM — READABLE, NOT TOY-LIKE")
	await _capture("22_v0306_gameplay_zoom.png", V0306_CAMERA_OBLIQUE, Vector3(0.0, 0.3, 3.0), 20.0)
	_set_capture_note("STONE / MOSS / SHORE DETAIL")
	await _capture("23_v0306_terrain_material_close.png", Vector3(10.0, 9.0, 15.0), Vector3(2.0, 0.0, 7.0), 9.0)
	_set_capture_note("BRIDGE LANDING NATURAL TRANSITION")
	await _capture("24_v0306_bridge_landing_transition.png", Vector3(9.0, 8.0, 13.0), Vector3(8.4, 0.15, 0.0), 9.0)
	_set_capture_note("NO DEBUG PADS / NO PRODUCTION INTEGRATION")
	await _capture("25_v0306_isolated_clean_prototype.png", V0306_CAMERA_OBLIQUE, V0306_TARGET, V0306_ORTHO_SIZE)

func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0306-route-c-barrosan-convergence-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": V0306_CHECKPOINT,
		"status": "PASS_V0306_ROUTE_C_BARROSAN_CONVERGENCE" if errors.is_empty() else "FAIL_V0306_ROUTE_C_BARROSAN_CONVERGENCE",
		"prototypeOptIn": true,
		"prototypeOnly": true,
		"scenePath": V0306_SCENE_PATH,
		"sourceGlb": V0236_SOURCE_GLB,
		"sourceBlend": "art-source/blender/v0236/salto_barrosan_production_slice.blend",
		"sourceProvenance": "repository-authored v0.236 Barrosan kit reused; v0.306 terrain, bridge, support building, materials, and unit accents authored in GDScript",
		"unitPresentation": "hybrid repository billboard PNGs with authored role accents and directional grounding shadows",
		"camera": {"projection": "orthographic", "primary": V0306_CAMERA_OBLIQUE, "alternate": V0306_CAMERA_ALT, "topDown": V0306_CAMERA_TOP, "orthoSize": V0306_ORTHO_SIZE},
		"terrain": {"landTopY": 0.0, "riverWaterY": -0.48, "terracedShoulders": true, "slopeSurfaces": v0306_revision_nodes},
		"water": {"flowBands": v0306_flow_nodes, "shorelineContact": true, "bridgeContact": true, "productionShader": false},
		"architecture": {"fieldBarracksRevisedMaterials": true, "supportBuildingCoherentGable": true, "supportBuildingGameplayFootprintChanged": false},
		"selection": {"radius": 0.43, "reducedFromV0305": true},
		"captures": captures,
		"hudOverlap": {"prototypeCapturePath": "isolated-clean", "sharedV0303Runtime": "known-overlap-documented-not-mutated"},
		"defaultLauncherChanged": false,
		"gameplayChanged": false,
		"movementChanged": false,
		"pathingChanged": false,
		"combatChanged": false,
		"economyChanged": false,
		"resourceChanged": false,
		"pressureChanged": false,
		"stableIdsChanged": false,
		"saveChanged": false,
		"productionIntegration": false,
		"newRuntimeArtSlots": 0,
		"errors": errors,
	})
