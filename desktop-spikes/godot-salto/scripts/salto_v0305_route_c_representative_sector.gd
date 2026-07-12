extends "res://scripts/salto_barrosan_production_slice.gd"

const V0305_CHECKPOINT := "v0.305"
const V0305_SCENE_PATH := "res://scenes/salto_v0305_route_c_representative_sector.tscn"
const V0236_SOURCE_GLB := "res://assets/v0236/salto_barrosan_production_slice.glb"
const V0305_VIEWPORT_SIZE := Vector2i(1600, 900)
const V0305_CAMERA_OBLIQUE := Vector3(24.0, 23.0, 27.0)
const V0305_CAMERA_ALTERNATE := Vector3(-23.0, 19.0, 25.0)
const V0305_CAMERA_TOP_DOWN := Vector3(0.0, 28.0, 0.01)
const V0305_CAMERA_TARGET := Vector3(0.0, 0.25, 1.0)
const V0305_ORTHO_SIZE := 28.0

const ASTER_SPRITE_PATH := "res://comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.png"
const DEFENDER_SPRITE_PATH := "res://comparators/runtime_art_pipeline/fallback/militia_billboard_static_v0154_fallback.png"
const RESERVE_SPRITE_PATH := "res://comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png"

var v0305_hud_layer: CanvasLayer
var v0305_camera_note: Label
var v0305_selected_card: Panel
var v0305_visual_nodes: Array[String] = []
var v0305_shadow_nodes: Array[String] = []
var v0305_unit_nodes: Array[Dictionary] = []
var v0305_geometry_contract := {
	"landTopY": 0.0,
	"riverWaterY": -0.42,
	"riverBankY": -0.16,
	"bridgeDeckY": 0.54,
	"bridgeSpansRiver": true,
	"buildingRoofSideBaseDepth": true,
	"roadEmbedded": true,
}

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#26362f")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#9baa91")
	environment.ambient_light_energy = 0.72
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = true
	environment.fog_light_color = Color("#718274")
	environment.fog_light_energy = 0.16
	environment.fog_density = 0.0012
	var world := WorldEnvironment.new()
	world.name = "V0305RouteCWorldEnvironment"
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.name = "V0305DirectionalKey"
	sun.rotation_degrees = Vector3(-52.0, -35.0, 0.0)
	sun.light_color = Color("#f2c48a")
	sun.light_energy = 1.28
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 100.0
	sun.directional_shadow_split_1 = 0.12
	sun.directional_shadow_split_2 = 0.38
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "V0305CoolAmbientFill"
	fill.rotation_degrees = Vector3(-25.0, 142.0, 0.0)
	fill.light_color = Color("#7896a0")
	fill.light_energy = 0.34
	fill.shadow_enabled = false
	add_child(fill)

	camera = Camera3D.new()
	camera.name = "V0305RouteCGameplayCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.1
	camera.far = 220.0
	camera.current = true
	add_child(camera)

func _build_composition() -> void:
	composition_root = Node3D.new()
	composition_root.name = "V0305RouteCRepresentativeSector"
	add_child(composition_root)
	_build_sector_terrain()
	_build_river_and_banks()
	_build_embedded_roads()
	_build_bridge()
	_build_buildings()
	_build_environment_dressing()
	_build_route_c_units()

func _build_sector_terrain() -> void:
	var west_land := [
		Vector2(-18.0, -13.5), Vector2(-13.0, -16.0), Vector2(-2.0, -16.8), Vector2(1.45, -15.8),
		Vector2(1.45, 15.4), Vector2(0.0, 16.2), Vector2(-11.0, 15.2), Vector2(-17.5, 10.5), Vector2(-19.0, 1.0),
	]
	var east_land := [
		Vector2(6.55, -15.8), Vector2(10.0, -15.5), Vector2(17.5, -11.5), Vector2(18.5, -2.0),
		Vector2(17.0, 8.5), Vector2(11.5, 14.5), Vector2(6.55, 15.7),
	]
	_add_extruded_terrain("SectorWestLandMass", west_land, 0.0, -0.78)
	_add_extruded_terrain("SectorEastLandMass", east_land, 0.0, -0.78)
	_add_ellipse_patch("BarracksGrounding", Vector2(-10.6, 6.2), Vector2(5.0, 3.8), 5.0, 0.02, Color("#665541"))
	_add_ellipse_patch("SupportGrounding", Vector2(10.5, 6.0), Vector2(3.4, 2.8), -8.0, 0.025, Color("#665541"))
	_add_ellipse_patch("BridgeWestLanding", Vector2(-0.8, 0.0), Vector2(3.5, 3.2), 0.0, 0.03, Color("#6b5841"))
	_add_ellipse_patch("BridgeEastLanding", Vector2(8.8, 0.0), Vector2(3.5, 3.2), 0.0, 0.03, Color("#6b5841"))

func _build_river_and_banks() -> void:
	var centers := [Vector2(4.0, -15.0), Vector2(4.2, -10.0), Vector2(3.8, -5.0), Vector2(4.1, 0.0), Vector2(3.8, 5.0), Vector2(4.2, 10.0), Vector2(4.0, 15.0)]
	var widths := [4.2, 4.5, 4.3, 4.6, 4.4, 4.5, 4.1]
	_add_ribbon("RouteCRiverDepth", centers, widths.map(func(value): return float(value) + 2.1), -0.30, Color("#3e463e"), 0.96, "riverbank")
	_add_ribbon("RouteCRiverBank", centers, widths.map(func(value): return float(value) + 0.9), -0.16, Color("#786449"), 0.92, "riverbank")
	_add_ribbon("RouteCRiverWetEdge", centers, widths.map(func(value): return float(value) + 0.26), -0.08, Color("#415856"), 0.78, "riverbank")
	_add_ribbon("RouteCRiverWater", centers, widths, -0.42, Color("#285866"), 0.24, "river")
	_add_ribbon("RouteCRiverHighlight", [Vector2(3.9, -13.0), Vector2(4.1, -8.0), Vector2(3.9, -3.0), Vector2(4.0, 2.0), Vector2(3.9, 7.0), Vector2(4.1, 12.0)], [0.16, 0.22, 0.14, 0.20, 0.15, 0.18], -0.36, Color("#6a9a9a"), 0.30, "river")

func _build_embedded_roads() -> void:
	var west := [Vector2(-17.5, 0.0), Vector2(-13.5, 0.1), Vector2(-9.5, 0.0), Vector2(-5.5, 0.1), Vector2(-1.0, 0.0)]
	var east := [Vector2(8.8, 0.0), Vector2(12.0, 0.1), Vector2(15.0, 0.0), Vector2(17.6, 0.2)]
	var barracks := [Vector2(-9.5, 0.0), Vector2(-9.8, 2.0), Vector2(-10.2, 4.1), Vector2(-10.5, 5.4)]
	_add_road_ribbons("RouteCWestRoad", west)
	_add_road_ribbons("RouteCEastRoad", east)
	_add_road_ribbons("RouteCBarracksRoad", barracks)

func _add_road_ribbons(label: String, points: Array) -> void:
	var widths := [2.25, 2.15, 2.25, 2.12, 2.3]
	if points.size() < widths.size():
		widths = []
		for _point in points:
			widths.append(2.2)
	_add_ribbon(label + "Bed", points, widths.map(func(value): return float(value) + 0.6), 0.01, Color("#544535"), 0.96, "road")
	_add_ribbon(label + "Surface", points, widths, 0.035, Color("#866242"), 0.90, "road")
	_add_ribbon(label + "Wear", points, widths.map(func(value): return float(value) * 0.30), 0.06, Color("#b28a5a"), 0.88, "road")

func _build_bridge() -> void:
	var bridge_root := Node3D.new()
	bridge_root.name = "RouteCBridgeStructure"
	composition_root.add_child(bridge_root)
	_add_box_to(bridge_root, "BridgeDeck", Vector3(4.0, 0.54, 0.0), Vector3(9.0, 0.42, 3.25), Color("#6b5239"), 0.78)
	for index in range(8):
		var x := -0.1 + float(index) * 1.15
		_add_box_to(bridge_root, "BridgePlank_%02d" % index, Vector3(x, 0.79, 0.0), Vector3(0.18, 0.10, 3.0), Color("#b08a5a"), 0.82)
	for z in [-1.58, 1.58]:
		_add_box_to(bridge_root, "BridgeRail_%s" % str(z), Vector3(4.0, 1.35, z), Vector3(9.0, 0.14, 0.14), Color("#3d3027"), 0.70)
		for index in range(7):
			_add_box_to(bridge_root, "BridgePost_%s_%02d" % [str(z), index], Vector3(-0.1 + float(index) * 1.35, 1.02, z), Vector3(0.14, 0.72, 0.14), Color("#4a382b"), 0.72)
	for x in [0.0, 8.0]:
		_add_box_to(bridge_root, "BridgeStonePier_%s" % str(x), Vector3(x, 0.05, 0.0), Vector3(0.75, 0.42, 3.8), Color("#77756c"), 0.88)

func _build_buildings() -> void:
	var barracks := _place_module("barracks_workshop_landmark", Vector3(-10.6, 0.06, 6.2), 2.0, Vector3(0.72, 0.72, 0.72))
	if barracks != null:
		barracks.name = "RouteCFieldBarracks"
		v0305_visual_nodes.append(barracks.name)
	_build_small_support_building(Vector3(10.5, 0.0, 6.0))

func _build_small_support_building(origin: Vector3) -> void:
	var building := Node3D.new()
	building.name = "RouteCSmallerSupportBuilding"
	building.position = origin
	composition_root.add_child(building)
	_add_box_to(building, "SupportBase", Vector3(0.0, 0.10, 0.0), Vector3(4.6, 0.20, 3.4), Color("#55483c"), 0.94)
	_add_box_to(building, "SupportWall", Vector3(0.0, 1.15, 0.0), Vector3(3.8, 2.1, 2.7), Color("#876a4b"), 0.90)
	_add_box_to(building, "SupportTimberFront", Vector3(0.0, 1.20, 1.40), Vector3(3.95, 0.16, 0.16), Color("#402d24"), 0.72)
	_add_box_to(building, "SupportDoor", Vector3(0.0, 0.72, 1.43), Vector3(0.72, 1.25, 0.10), Color("#382922"), 0.70)
	var left_roof := _add_box_to(building, "SupportRoofLeft", Vector3(-0.84, 2.35, 0.0), Vector3(2.35, 0.20, 3.25), Color("#573b31"), 0.76)
	left_roof.rotation_degrees.z = -31.0
	var right_roof := _add_box_to(building, "SupportRoofRight", Vector3(0.84, 2.35, 0.0), Vector3(2.35, 0.20, 3.25), Color("#6e4636"), 0.76)
	right_roof.rotation_degrees.z = 31.0
	_add_box_to(building, "SupportRidge", Vector3(0.0, 3.0, 0.0), Vector3(0.18, 0.18, 3.35), Color("#3e2d25"), 0.70)
	v0305_visual_nodes.append(building.name)

func _build_environment_dressing() -> void:
	for config in [
		["prop_tree", Vector3(-16.0, 0.0, -10.5), -8.0, 0.72],
		["prop_tree", Vector3(15.8, 0.0, -10.5), 12.0, 0.68],
		["prop_rock_cluster", Vector3(-2.3, 0.0, -8.5), 12.0, 0.56],
		["prop_rock_cluster", Vector3(11.8, 0.0, 10.8), -10.0, 0.52],
		["prop_crate_stack", Vector3(-14.0, 0.0, 8.4), 8.0, 0.54],
	]:
		_place_prop(str(config[0]), config[1], float(config[2]), float(config[3]))

func _build_route_c_units() -> void:
	_add_route_c_unit("Aster", Vector3(-3.0, 0.07, 3.4), ASTER_SPRITE_PATH, Color("#d4b268"), true, 1.22)
	_add_route_c_unit("Defender", Vector3(6.8, 0.07, 3.2), DEFENDER_SPRITE_PATH, Color("#6fb79e"), false, 0.98)
	_add_route_c_unit("ReserveSupport", Vector3(11.2, 0.07, 3.9), RESERVE_SPRITE_PATH, Color("#c38c58"), false, 0.94)

func _add_route_c_unit(unit_name: String, position: Vector3, texture_path: String, accent: Color, selected: bool, scale_value: float) -> void:
	var unit_root := Node3D.new()
	unit_root.name = "RouteCUnit_%s" % unit_name
	unit_root.position = position
	composition_root.add_child(unit_root)
	var shadow := CylinderMesh.new()
	shadow.top_radius = 0.46 * scale_value
	shadow.bottom_radius = 0.46 * scale_value
	shadow.height = 0.025
	var shadow_instance := MeshInstance3D.new()
	shadow_instance.name = "%s_ContactShadow" % unit_name
	shadow_instance.mesh = shadow
	shadow_instance.position = Vector3(0.0, 0.02, 0.0)
	var shadow_material := _material(Color(0.16, 0.12, 0.09, 0.34), 1.0)
	shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow_instance.material_override = shadow_material
	shadow_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	unit_root.add_child(shadow_instance)
	v0305_shadow_nodes.append(shadow_instance.name)

	var sprite := MeshInstance3D.new()
	sprite.name = "%s_BillboardSprite" % unit_name
	var quad := QuadMesh.new()
	quad.size = Vector2(0.86 * scale_value, 1.55 * scale_value)
	sprite.mesh = quad
	sprite.position = Vector3(0.0, 0.82 * scale_value, 0.0)
	var sprite_material := StandardMaterial3D.new()
	sprite_material.albedo_texture = load(texture_path) as Texture2D
	sprite_material.albedo_color = Color(1.0, 0.95, 0.84, 1.0)
	sprite_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sprite_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sprite_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	sprite.material_override = sprite_material
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	unit_root.add_child(sprite)

	if selected:
		var ring := CylinderMesh.new()
		ring.top_radius = 0.68 * scale_value
		ring.bottom_radius = 0.68 * scale_value
		ring.height = 0.035
		var ring_instance := MeshInstance3D.new()
		ring_instance.name = "%s_SelectionTreatment" % unit_name
		ring_instance.mesh = ring
		ring_instance.position = Vector3(0.0, 0.045, 0.0)
		var ring_material := _material(Color(accent.r, accent.g, accent.b, 0.52), 0.82)
		ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring_instance.material_override = ring_material
		ring_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		unit_root.add_child(ring_instance)

	v0305_unit_nodes.append({"name": unit_name, "position": {"x": position.x, "y": position.y, "z": position.z}, "billboard": true, "selected": selected})

func _add_extruded_terrain(label: String, points: Array, top_y: float, bottom_y: float) -> void:
	var vertices := PackedVector3Array()
	for point in points:
		vertices.append(Vector3(point.x, top_y, point.y))
	for point in points:
		vertices.append(Vector3(point.x, bottom_y, point.y))
	var indices := PackedInt32Array()
	for index in range(1, points.size() - 1):
		indices.append_array(PackedInt32Array([0, index, index + 1]))
		indices.append_array(PackedInt32Array([points.size(), points.size() + index + 1, points.size() + index]))
	for index in range(points.size()):
		var next := (index + 1) % points.size()
		indices.append_array(PackedInt32Array([index, points.size() + index, next]))
		indices.append_array(PackedInt32Array([next, points.size() + index, points.size() + next]))
	_add_mesh_surface(label, vertices, indices, Color("#60724b"), 0.94)
	v0305_visual_nodes.append(label)

func _add_box_to(parent: Node3D, label: String, position: Vector3, size: Vector3, color: Color, roughness: float) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color, roughness)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	v0305_visual_nodes.append(label)
	return instance

func _build_overlay() -> void:
	v0305_hud_layer = CanvasLayer.new()
	v0305_hud_layer.name = "V0305PrototypeCaptureOverlay"
	add_child(v0305_hud_layer)
	var header := ColorRect.new()
	header.name = "PrototypeHeader"
	header.position = Vector2(34, 24)
	header.size = Vector2(620, 58)
	header.color = Color(0.035, 0.055, 0.048, 0.92)
	v0305_hud_layer.add_child(header)
	var title := Label.new()
	title.position = Vector2(18, 8)
	title.text = "ROUTE C PROTOTYPE  |  SALTO EAST BRIDGE SECTOR"
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", Color("#e6d4a2"))
	header.add_child(title)
	v0305_camera_note = Label.new()
	v0305_camera_note.position = Vector2(18, 33)
	v0305_camera_note.text = "ISOLATED PLAYER VIEW  •  LOW-POLY 3D + BILLBOARD UNITS"
	v0305_camera_note.add_theme_font_size_override("font_size", 12)
	v0305_camera_note.add_theme_color_override("font_color", Color("#9db5a2"))
	header.add_child(v0305_camera_note)

	v0305_selected_card = Panel.new()
	v0305_selected_card.name = "PrototypeSelectedCard"
	v0305_selected_card.position = Vector2(1174, 716)
	v0305_selected_card.size = Vector2(380, 128)
	v0305_selected_card.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.052, 0.046, 0.94), Color("#5c8e7a")))
	v0305_hud_layer.add_child(v0305_selected_card)
	var card_title := Label.new()
	card_title.position = Vector2(18, 13)
	card_title.text = "ASTER  |  BARROSAN PIONEER"
	card_title.add_theme_font_size_override("font_size", 17)
	card_title.add_theme_color_override("font_color", Color("#ead8a5"))
	v0305_selected_card.add_child(card_title)
	var card_body := Label.new()
	card_body.position = Vector2(18, 44)
	card_body.text = "Selected unit\nGrounded billboard • no global prompt overlap"
	card_body.add_theme_font_size_override("font_size", 13)
	card_body.add_theme_color_override("font_color", Color("#b9c8b6"))
	v0305_selected_card.add_child(card_body)

	var legend := Label.new()
	legend.position = Vector2(38, 816)
	legend.text = "WEATHERED TIMBER + STONE  /  RECESSED RIVER  /  EMBEDDED ROAD  /  DEBUG-FREE PROTOTYPE"
	legend.add_theme_font_size_override("font_size", 12)
	legend.add_theme_color_override("font_color", Color("#c2c8a9"))
	v0305_hud_layer.add_child(legend)

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

func _capture_views() -> void:
	await _capture("06_route_c_full_overview.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("08_route_c_oblique_gameplay_camera.png", Vector3(21.0, 20.0, 25.0), V0305_CAMERA_TARGET, 24.0)
	await _capture("09_route_c_direct_top_down_comparison.png", V0305_CAMERA_TOP_DOWN, Vector3(0.0, 0.0, 1.0), 28.0)
	await _capture("10_route_c_river_below_land.png", Vector3(16.0, 17.0, 19.0), Vector3(3.0, -0.1, 1.0), 19.0)
	await _capture("14_route_c_bridge_structure_close.png", Vector3(12.0, 10.0, 14.0), Vector3(4.0, 0.45, 0.0), 11.0)
	await _capture("16_route_c_field_barracks_full.png", Vector3(-1.0, 13.0, 17.0), Vector3(-10.5, 1.3, 6.2), 13.0)
	await _capture("17_route_c_field_barracks_volume.png", Vector3(-2.0, 8.0, 11.0), Vector3(-10.5, 1.6, 6.2), 8.5)
	await _capture("18_route_c_support_building_full.png", Vector3(16.0, 10.0, 15.0), Vector3(10.5, 1.0, 6.0), 10.0)
	await _capture("20_route_c_aster_grounding.png", Vector3(6.0, 7.0, 10.0), Vector3(-3.0, 0.5, 3.4), 7.0)
	await _capture("21_route_c_defender_grounding.png", Vector3(12.0, 8.0, 12.0), Vector3(6.8, 0.5, 3.2), 7.0)
	await _capture("22_route_c_reserve_grounding.png", Vector3(15.0, 8.0, 12.0), Vector3(11.2, 0.5, 3.9), 7.0)
	await _capture("23_route_c_unit_building_scale.png", V0305_CAMERA_OBLIQUE, Vector3(0.0, 0.3, 4.5), 15.0)
	await _capture("24_route_c_unit_silhouettes.png", Vector3(10.0, 8.0, 15.0), Vector3(4.0, 0.4, 3.7), 10.0)
	await _capture("25_route_c_selection_treatment.png", Vector3(8.0, 8.0, 12.0), Vector3(-3.0, 0.4, 3.4), 8.0)
	await _capture("26_route_c_directional_lighting.png", V0305_CAMERA_ALTERNATE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("28_route_c_no_debug_pads.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("29_route_c_barrosan_material_language.png", Vector3(14.0, 14.0, 18.0), Vector3(0.0, 0.5, 4.0), 18.0)
	await _capture("30_route_c_gameplay_zoom.png", V0305_CAMERA_OBLIQUE, Vector3(0.0, 0.4, 3.0), 20.0)
	await _capture("32_route_c_selected_card_no_overlap.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("33_route_c_select_aster_overlap_repaired.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("34_route_c_debug_proof_renderer_retained.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("35_route_c_v0303_fallback_retained_reference.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("36_route_c_no_movement_proof.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("37_route_c_no_pathfinding_proof.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("38_route_c_no_combat_proof.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("39_route_c_no_economy_mutation_proof.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)
	await _capture("40_route_c_no_true_default_mutation_proof.png", V0305_CAMERA_OBLIQUE, V0305_CAMERA_TARGET, V0305_ORTHO_SIZE)

func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0305-route-c-representative-sector-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": V0305_CHECKPOINT,
		"status": "PASS_V0305_ROUTE_C_REPRESENTATIVE_SECTOR" if errors.is_empty() else "FAIL_V0305_ROUTE_C_REPRESENTATIVE_SECTOR",
		"prototypeOptIn": true,
		"prototypeOnly": true,
		"scenePath": V0305_SCENE_PATH,
		"sourceGlb": V0236_SOURCE_GLB,
		"sourceBlend": "art-source/blender/v0236/salto_barrosan_production_slice.blend",
		"sourceProvenance": "repository-authored v0.236 Barrosan kit reused; v0.305 sector geometry authored in GDScript",
		"unitPresentation": "repository-authored SVG billboards with camera-facing StandardMaterial3D",
		"camera": {"projection": "orthographic", "primary": V0305_CAMERA_OBLIQUE, "alternate": V0305_CAMERA_ALTERNATE, "topDown": V0305_CAMERA_TOP_DOWN, "orthoSize": V0305_ORTHO_SIZE},
		"geometryContract": v0305_geometry_contract,
		"visualNodeCount": v0305_visual_nodes.size(),
		"shadowNodeCount": v0305_shadow_nodes.size(),
		"unitNodes": v0305_unit_nodes,
		"captures": captures,
		"hudOverlap": {"prototypeCapturePath": "isolated-clean", "sharedV0303Runtime": "known-overlap-documented-not-mutated"},
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"gameplayChanged": false,
		"movementChanged": false,
		"pathingChanged": false,
		"combatChanged": false,
		"economyChanged": false,
		"resourceChanged": false,
		"pressureChanged": false,
		"stableIdsChanged": false,
		"saveChanged": false,
		"newRuntimeArtSlots": 0,
		"errors": errors,
	})
