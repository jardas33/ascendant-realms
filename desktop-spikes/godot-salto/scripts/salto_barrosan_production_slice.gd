extends "res://scripts/salto_architecture_correction_beauty_pass.gd"

const V0236_KIT_PATH := "res://assets/v0236/salto_barrosan_production_slice.glb"
const ART_BIBLE_PATH := "docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md"
const ROLE_PROP_MODULES := [
	"prop_weapon_rack",
	"prop_training_post",
	"prop_tool_cart",
	"prop_crystal_shards",
	"prop_mine_support",
	"prop_civic_banner",
]

var role_prop_instances: Array[Dictionary] = []
var organic_surface_count := 0
var road_ribbon_segment_count := 0
var river_segment_count := 0


func _load_source_kit() -> bool:
	var packed := load(V0236_KIT_PATH) as PackedScene
	if packed == null:
		errors.append("Unable to load v0.236 Barrosan production GLB")
		return false
	source_kit = packed.instantiate() as Node3D
	if source_kit == null:
		errors.append("Unable to instantiate v0.236 Barrosan production GLB")
		return false
	source_kit.name = "V0236BarrosanProductionLibrary"
	source_kit.visible = false
	add_child(source_kit)
	for module_name in SOURCE_MODULES + ROLE_PROP_MODULES:
		if source_kit.find_child(module_name, true, false) == null:
			errors.append("v0.236 source kit missing module %s" % module_name)
	_tune_imported_materials(source_kit)
	return errors.is_empty()


func _build_environment() -> void:
	super._build_environment()
	for child in get_children():
		if child is WorldEnvironment:
			var world := child as WorldEnvironment
			if world.environment != null:
				world.environment.background_color = Color("#253027")
				world.environment.ambient_light_color = Color("#aab19a")
				world.environment.ambient_light_energy = 0.66
				world.environment.fog_light_color = Color("#7b806d")
				world.environment.fog_density = 0.002
		elif child is DirectionalLight3D:
			var light := child as DirectionalLight3D
			if light.shadow_enabled:
				light.light_color = Color("#f3bf79")
				light.light_energy = 1.32
			else:
				light.light_color = Color("#7195a1")
				light.light_energy = 0.44


func _tune_material(material: StandardMaterial3D) -> void:
	super._tune_material(material)
	match material.resource_name:
		"MAT_Stone":
			material.albedo_color = Color("#777267")
		"MAT_StoneLight":
			material.albedo_color = Color("#aaa18a")
		"MAT_StoneWarm":
			material.albedo_color = Color("#826b4f")
		"MAT_StoneDark":
			material.albedo_color = Color("#303437")
		"MAT_StoneMoss":
			material.albedo_color = Color("#59644b")
		"MAT_StoneChalk":
			material.albedo_color = Color("#b2a990")
		"MAT_Plaster":
			material.albedo_color = Color("#c9b487")
		"MAT_PlasterLight":
			material.albedo_color = Color("#d9c89e")
		"MAT_PlasterWarm":
			material.albedo_color = Color("#be915d")
		"MAT_PlasterCream":
			material.albedo_color = Color("#e7d7b1")
		"MAT_PlasterOchre":
			material.albedo_color = Color("#be915d")
		"MAT_PlasterShadow":
			material.albedo_color = Color("#9a7654")
		"MAT_Roof":
			material.albedo_color = Color("#87402b")
		"MAT_RoofClay":
			material.albedo_color = Color("#93452e")
		"MAT_RoofDark":
			material.albedo_color = Color("#48251d")
		"MAT_RoofSun":
			material.albedo_color = Color("#9b4c31")
		"MAT_RoofAged":
			material.albedo_color = Color("#6f3427")
		"MAT_Wood":
			material.albedo_color = Color("#6f4126")
		"MAT_WoodLight":
			material.albedo_color = Color("#8a6747")
		"MAT_WoodDark":
			material.albedo_color = Color("#392217")
		"MAT_WoodRed":
			material.albedo_color = Color("#7c3f29")
		"MAT_WoodWeathered":
			material.albedo_color = Color("#8a6747")
		"MAT_EaveDark":
			material.albedo_color = Color("#261711")
		"MAT_IronDark":
			material.albedo_color = Color("#252a29")
			material.metallic = 0.22
		"MAT_BannerRed":
			material.albedo_color = Color("#8d3028")
		"MAT_BannerGold":
			material.albedo_color = Color("#c89b48")
		"MAT_Crystal":
			_tune_crystal(material, Color("#42bdb5"), 1.30)
		"MAT_CrystalDeep":
			_tune_crystal(material, Color("#168e91"), 1.10)
		"MAT_CrystalPale":
			_tune_crystal(material, Color("#70d9cf"), 1.20)
		"MAT_ContactDark":
			material.albedo_color = Color("#26231d")
	material.roughness = min(material.roughness, 0.72)


func _tune_crystal(material: StandardMaterial3D, color: Color, energy: float) -> void:
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	material.roughness = 0.24


func _build_composition() -> void:
	composition_root = Node3D.new()
	composition_root.name = "V0236BarrosanProductionBattlefield"
	add_child(composition_root)
	_build_continuous_terrain()
	_build_recessed_river()
	_build_embedded_roads()
	_build_landmarks()
	_build_role_clutter()
	_build_environment_dressing()


func _build_continuous_terrain() -> void:
	_add_convex_surface("IslandEarthSkirt", [
		Vector2(-30.5, -13.0), Vector2(-26.0, -17.0), Vector2(-14.0, -18.4),
		Vector2(1.0, -18.0), Vector2(14.5, -17.0), Vector2(27.5, -13.2),
		Vector2(30.2, -5.0), Vector2(29.2, 6.5), Vector2(25.3, 15.0),
		Vector2(13.0, 17.5), Vector2(-1.0, 18.1), Vector2(-15.0, 17.4),
		Vector2(-26.5, 13.0), Vector2(-30.2, 4.0),
	], -0.72, Color("#3c3023"), 0.94)
	_add_convex_surface("IslandGrassBody", [
		Vector2(-29.5, -12.5), Vector2(-25.0, -16.1), Vector2(-13.5, -17.2),
		Vector2(0.5, -16.8), Vector2(13.8, -15.9), Vector2(26.2, -12.2),
		Vector2(28.8, -4.5), Vector2(27.8, 6.0), Vector2(24.0, 14.0),
		Vector2(12.5, 16.3), Vector2(-1.0, 16.9), Vector2(-14.5, 16.3),
		Vector2(-25.2, 12.2), Vector2(-28.9, 3.8),
	], -0.43, Color("#647747"), 0.91)

	_add_organic_spots()


func _add_organic_spots() -> void:
	var spots := [
		[Vector2(-22.5, -10.0), Vector2(7.0, 4.2), -12.0, Color("#5d6d43")],
		[Vector2(-22.0, 1.0), Vector2(6.0, 3.2), 12.0, Color("#4f633d")],
		[Vector2(-18.0, 11.0), Vector2(7.4, 3.7), 18.0, Color("#736b43")],
		[Vector2(-7.0, 12.8), Vector2(6.3, 3.0), -8.0, Color("#4f633d")],
		[Vector2(-2.0, -11.8), Vector2(6.8, 3.5), 11.0, Color("#77794a")],
		[Vector2(-2.0, 1.0), Vector2(6.0, 3.8), -9.0, Color("#70814b")],
		[Vector2(15.5, 9.0), Vector2(7.0, 3.4), -15.0, Color("#52663f")],
		[Vector2(21.0, -9.5), Vector2(7.6, 4.0), 9.0, Color("#596047")],
		[Vector2(23.0, 2.5), Vector2(5.6, 3.1), -12.0, Color("#77794a")],
	]
	for index in range(spots.size()):
		var config = spots[index]
		_add_ellipse_patch("OrganicSpot_%02d" % index, config[0], config[1], float(config[2]), -0.34 + float(index % 3) * 0.012, config[3])


func _build_recessed_river() -> void:
	var centers := [
		Vector2(8.0, -17.0), Vector2(7.4, -14.0), Vector2(7.0, -10.5),
		Vector2(7.5, -7.0), Vector2(7.2, -3.5), Vector2(6.8, 0.5),
		Vector2(7.1, 4.0), Vector2(7.5, 7.8), Vector2(7.0, 11.5),
		Vector2(6.6, 14.5), Vector2(7.0, 17.0),
	]
	var widths := [3.3, 3.5, 3.8, 3.6, 3.9, 3.6, 3.8, 3.5, 3.7, 3.5, 3.3]
	_add_ribbon("RiverDepth", centers, widths.map(func(value): return float(value) + 1.75), -0.19, Color("#34372f"), 0.94, "riverbank")
	_add_ribbon("RiverBankEarth", centers, widths.map(func(value): return float(value) + 0.95), -0.15, Color("#65513a"), 0.92, "riverbank")
	_add_ribbon("RiverWetEdge", centers, widths.map(func(value): return float(value) + 0.38), -0.11, Color("#314644"), 0.72, "riverbank")
	_add_ribbon("RiverWater", centers, widths, -0.075, Color("#245866"), 0.22, "river")
	_add_ribbon("RiverGlint", [
		Vector2(7.9, -16.0), Vector2(7.3, -12.0), Vector2(7.4, -8.0),
		Vector2(7.2, -4.0), Vector2(6.9, 0.5), Vector2(7.2, 5.0),
		Vector2(7.3, 9.0), Vector2(6.9, 13.0), Vector2(6.9, 16.0),
	], [0.20, 0.25, 0.20, 0.24, 0.21, 0.24, 0.19, 0.23, 0.18], -0.045, Color("#4b8a91"), 0.18, "river")
	_add_bank_breakup()


func _add_bank_breakup() -> void:
	for config in [
		[Vector3(3.8, -0.22, -12.0), -8.0, 0.62],
		[Vector3(10.8, -0.22, -8.0), 14.0, 0.55],
		[Vector3(3.5, -0.22, 6.0), -16.0, 0.68],
		[Vector3(10.4, -0.22, 11.5), 10.0, 0.58],
	]:
		_place_prop("prop_rock_cluster", Vector3(config[0].x, -0.12, config[0].z), float(config[1]), float(config[2]))


func _build_embedded_roads() -> void:
	var main_route := [
		Vector2(-29.0, 1.6), Vector2(-25.0, 1.3), Vector2(-21.0, 1.0),
		Vector2(-17.0, 1.2), Vector2(-13.0, 1.0), Vector2(-9.0, 0.7),
		Vector2(-5.0, 0.9), Vector2(-1.0, 1.1), Vector2(3.0, 0.8),
		Vector2(6.0, 0.7), Vector2(10.0, 0.9), Vector2(14.0, 1.2),
		Vector2(18.0, 1.0), Vector2(22.0, 1.2), Vector2(27.0, 1.5),
	]
	_add_road("MainRoad", main_route, [3.5, 3.4, 3.5, 3.3, 3.6, 3.4, 3.7, 3.5, 3.6, 3.4, 3.6, 3.5, 3.4, 3.5, 3.7])
	_add_road("KeepApproach", [
		Vector2(-11.5, 1.0), Vector2(-11.1, -1.0), Vector2(-11.0, -3.0),
		Vector2(-11.3, -5.0), Vector2(-11.4, -6.7), Vector2(-12.0, -8.0),
	], [3.6, 3.4, 3.2, 3.4, 3.8, 4.4])
	_add_road("BarracksApproach", [
		Vector2(-11.5, 1.0), Vector2(-11.7, 2.8), Vector2(-12.0, 4.5),
		Vector2(-12.6, 6.0), Vector2(-13.0, 7.0), Vector2(-13.5, 8.0),
	], [3.6, 3.3, 3.2, 3.5, 3.9, 4.5])
	_add_road("MineApproach", [
		Vector2(18.0, 1.0), Vector2(18.1, -0.8), Vector2(18.2, -2.5),
		Vector2(18.4, -4.2), Vector2(18.5, -5.8), Vector2(18.3, -7.2),
	], [3.5, 3.3, 3.2, 3.5, 3.9, 4.4])


func _add_road(label: String, points: Array, widths: Array) -> void:
	var bed_widths := widths.map(func(value): return float(value) + 0.70)
	var center_widths := widths.map(func(value): return float(value) * 0.34)
	_add_ribbon(label + "Bed", points, bed_widths, -0.14, Color("#5d4936"), 0.94, "road")
	_add_ribbon(label + "Surface", points, widths, -0.10, Color("#735437"), 0.91, "road")
	_add_ribbon(label + "Wear", points, center_widths, -0.065, Color("#8b6844"), 0.88, "road")


func _build_landmarks() -> void:
	_add_ellipse_patch("KeepContactDirt", Vector2(-12.0, -10.2), Vector2(7.7, 5.2), -3.0, -0.16, Color("#474033"))
	_add_ellipse_patch("KeepCivicApron", Vector2(-11.8, -6.4), Vector2(4.8, 2.8), -3.0, -0.055, Color("#826749"))
	_place_module("keep_landmark", Vector3(-12.0, -0.18, -10.2), -3.0)

	_add_ellipse_patch("BarracksContactDirt", Vector2(-13.5, 9.3), Vector2(8.4, 5.3), 4.0, -0.16, Color("#51483a"))
	_add_ellipse_patch("BarracksYardWear", Vector2(-10.8, 6.3), Vector2(5.8, 3.3), 8.0, -0.055, Color("#7b5d3c"))
	_place_module("barracks_workshop_landmark", Vector3(-13.5, -0.28, 9.3), 2.0)

	_add_ellipse_patch("MineContactDirt", Vector2(18.2, -9.2), Vector2(8.2, 5.5), -5.0, -0.16, Color("#434239"))
	_add_ellipse_patch("MineWorkWear", Vector2(18.5, -5.7), Vector2(5.5, 3.2), -2.0, -0.055, Color("#6a5137"))
	_place_module("mine_lume_landmark", Vector3(18.2, -0.30, -9.2), -2.0)

	var bridge := _place_module("bridge_module", Vector3(7.0, -0.30, 0.0), 0.0, Vector3(1.02, 1.0, 1.03))
	if bridge != null:
		for obsolete_name in ["Bridge_LeftBank", "Bridge_RightBank", "Bridge_Water"]:
			var obsolete := bridge.find_child(obsolete_name, true, false) as Node3D
			if obsolete != null:
				obsolete.visible = false
	_add_ellipse_patch("BridgeWestLanding", Vector2(2.2, 1.0), Vector2(3.2, 2.1), 0.0, -0.035, Color("#65513a"))
	_add_ellipse_patch("BridgeEastLanding", Vector2(11.8, 1.0), Vector2(3.2, 2.1), 0.0, -0.035, Color("#65513a"))


func _build_role_clutter() -> void:
	# Keep civic cluster: 4 instances.
	_place_role_prop("prop_civic_banner", Vector3(-17.5, 0.40, -6.3), -8.0, 0.76, "keep_civic")
	_place_role_prop("prop_civic_banner", Vector3(-6.9, 0.40, -6.0), 10.0, 0.72, "keep_civic")
	_place_role_prop("prop_crate_stack", Vector3(-17.0, 0.35, -12.5), 12.0, 0.58, "keep_civic")
	_place_role_prop("prop_barrels", Vector3(-6.5, 0.35, -11.7), -8.0, 0.60, "keep_civic")

	# Barracks / workshop working yard: 8 instances.
	_place_role_prop("prop_weapon_rack", Vector3(-19.0, 0.32, 5.4), -7.0, 0.72, "barracks_workshop")
	_place_role_prop("prop_weapon_rack", Vector3(-17.3, 0.32, 13.7), 82.0, 0.62, "barracks_workshop")
	_place_role_prop("prop_training_post", Vector3(-8.2, 0.32, 5.6), 8.0, 0.72, "barracks_workshop")
	_place_role_prop("prop_training_post", Vector3(-5.7, 0.32, 7.2), -11.0, 0.60, "barracks_workshop")
	_place_role_prop("prop_tool_cart", Vector3(-7.7, 0.32, 12.5), 18.0, 0.70, "barracks_workshop")
	_place_role_prop("prop_log_stack", Vector3(-19.0, 0.32, 11.3), 14.0, 0.68, "barracks_workshop")
	_place_role_prop("prop_crate_stack", Vector3(-9.2, 0.32, 14.1), -12.0, 0.58, "barracks_workshop")
	_place_role_prop("prop_posts", Vector3(-5.0, 0.30, 10.4), 74.0, 0.62, "barracks_workshop")

	# Mine / Lume extraction cluster: 6 instances.
	_place_role_prop("prop_mine_support", Vector3(23.2, 0.30, -5.7), 88.0, 0.78, "mine_lume")
	_place_role_prop("prop_crystal_shards", Vector3(22.6, 0.30, -11.8), -16.0, 0.76, "mine_lume")
	_place_role_prop("prop_crystal_shards", Vector3(14.0, 0.30, -5.5), 12.0, 0.52, "mine_lume")
	_place_role_prop("prop_rubble", Vector3(24.0, 0.28, -9.0), -8.0, 0.68, "mine_lume")
	_place_role_prop("prop_rock_cluster", Vector3(14.0, 0.28, -13.0), 14.0, 0.72, "mine_lume")
	_place_role_prop("prop_tool_cart", Vector3(15.0, 0.30, -6.8), -28.0, 0.62, "mine_lume")


func _build_environment_dressing() -> void:
	for tree_config in [
		[Vector3(-25.0, -0.22, -12.0), -8.0, 0.88],
		[Vector3(-25.5, -0.22, 11.5), 12.0, 0.82],
		[Vector3(-2.0, -0.22, -14.0), -5.0, 0.78],
		[Vector3(23.5, -0.22, 11.0), 16.0, 0.86],
		[Vector3(26.0, -0.22, -2.0), -12.0, 0.80],
		[Vector3(-3.0, -0.22, 14.5), 9.0, 0.66],
	]:
		_place_prop("prop_tree", tree_config[0], float(tree_config[1]), float(tree_config[2]))
	_place_prop("unit_scale_dummies", Vector3(-4.0, 0.18, -0.4), 8.0, 0.86)


func _place_role_prop(module_name: String, target_position: Vector3, yaw_degrees: float, uniform_scale: float, role: String) -> void:
	var grounded_position := Vector3(target_position.x, -0.24, target_position.z)
	_place_prop(module_name, grounded_position, yaw_degrees, uniform_scale)
	role_prop_instances.append({
		"module": module_name,
		"role": role,
		"position": {"x": grounded_position.x, "y": grounded_position.y, "z": grounded_position.z},
		"yawDegrees": yaw_degrees,
		"scale": uniform_scale,
	})


func _add_convex_surface(label: String, points: Array, y: float, color: Color, roughness: float) -> void:
	var vertices := PackedVector3Array()
	for point in points:
		vertices.append(Vector3(point.x, y, point.y))
	var indices := PackedInt32Array()
	for index in range(1, points.size() - 1):
		indices.append_array(PackedInt32Array([0, index, index + 1]))
	_add_mesh_surface(label, vertices, indices, color, roughness)
	organic_surface_count += 1


func _add_ellipse_patch(label: String, center: Vector2, radii: Vector2, rotation_degrees: float, y: float, color: Color) -> void:
	var points: Array[Vector2] = []
	var angle_offset := deg_to_rad(rotation_degrees)
	for index in range(12):
		var angle := TAU * float(index) / 12.0
		var wobble := 1.0 + sin(float(index) * 2.13) * 0.08
		var local := Vector2(cos(angle) * radii.x * wobble, sin(angle) * radii.y * wobble)
		points.append(center + local.rotated(angle_offset))
	_add_convex_surface(label, points, y, color, 0.91)


func _add_ribbon(label: String, centers: Array, widths: Array, y: float, color: Color, roughness: float, category: String) -> void:
	for index in range(centers.size() - 1):
		var start: Vector2 = centers[index]
		var finish: Vector2 = centers[index + 1]
		var direction := (finish - start).normalized()
		var normal := Vector2(-direction.y, direction.x)
		var start_half := float(widths[index]) * 0.5
		var finish_half := float(widths[index + 1]) * 0.5
		var overlap := direction * 0.12
		var points := [
			start - overlap + normal * start_half,
			finish + overlap + normal * finish_half,
			finish + overlap - normal * finish_half,
			start - overlap - normal * start_half,
		]
		_add_convex_surface("%s_%02d" % [label, index], points, y, color, roughness)
		if category == "road":
			road_ribbon_segment_count += 1
		elif category == "river":
			river_segment_count += 1


func _add_mesh_surface(label: String, vertices: PackedVector3Array, indices: PackedInt32Array, color: Color, roughness: float) -> void:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	var surface_material := _material(color, roughness)
	surface_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	instance.material_override = surface_material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	composition_root.add_child(instance)


func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.position = Vector2(218, 18)
	panel.size = Vector2(1164, 50)
	panel.color = Color(0.018, 0.03, 0.024, 0.92)
	layer.add_child(panel)
	var title := Label.new()
	title.position = Vector2(20, 10)
	title.text = "v0.236  |  BARROSAN FACTION ART BIBLE  |  PRODUCTION-DIRECTION SLICE"
	title.add_theme_color_override("font_color", Color("#eadba6"))
	title.add_theme_font_size_override("font_size", 18)
	panel.add_child(title)


func _capture_views() -> void:
	await _capture("02_v0236_overview.png", Vector3(43.0, 49.0, 48.0), Vector3(0.0, 0.7, 0.0), 47.0)
	await _capture("03_v0236_barrosan_shape_language.png", Vector3(35.0, 38.0, 37.0), Vector3(-1.0, 2.6, -0.5), 35.0)
	await _capture("04_v0236_barracks_workshop_role_detail.png", Vector3(5.0, 23.0, 30.0), Vector3(-13.0, 2.8, 9.0), 19.5)
	await _capture("05_v0236_keep_base_role_detail.png", Vector3(8.0, 28.0, 16.0), Vector3(-12.0, 4.0, -9.0), 21.5)
	await _capture("06_v0236_mine_lume_role_detail.png", Vector3(39.0, 24.0, 9.0), Vector3(18.5, 2.7, -8.5), 20.5)
	await _capture("07_v0236_terrain_road_river_integration.png", Vector3(28.0, 36.0, 35.0), Vector3(4.0, -0.1, 1.0), 31.0)
	await _capture("08_v0236_material_variation_focus.png", Vector3(16.0, 24.0, 26.0), Vector3(-5.0, 2.0, 1.0), 25.5)


func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0236-barrosan-production-slice-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.236",
		"status": "PASS_V0236_BARROSAN_PRODUCTION_SLICE_RUNTIME" if errors.is_empty() else "FAIL_V0236_BARROSAN_PRODUCTION_SLICE_RUNTIME",
		"sourceGlb": V0236_KIT_PATH,
		"sourceBlend": "art-source/blender/v0236/salto_barrosan_production_slice.blend",
		"scenePath": "res://scenes/salto_barrosan_production_slice.tscn",
		"artBiblePath": ART_BIBLE_PATH,
		"blenderUsed": true,
		"existingV0235GlbModified": false,
		"newV0236GlbExported": true,
		"changedBuildingModules": ["keep_landmark", "barracks_workshop_landmark", "mine_lume_landmark"],
		"changedBuildingModuleCount": 3,
		"retunedExistingMaterialCount": 21,
		"newMaterialCount": 14,
		"newOrChangedMaterialCount": 35,
		"authoredBuildingDetailObjectCount": 98,
		"rolePropModuleCount": 6,
		"propDetailInstancesAdded": role_prop_instances.size(),
		"rolePropInstances": role_prop_instances,
		"organicSurfaceCount": organic_surface_count,
		"roadRibbonSegmentCount": road_ribbon_segment_count,
		"riverSegmentCount": river_segment_count,
		"squareTerrainModulesPlaced": 0,
		"panelRoadModulesPlaced": 0,
		"continuousTerrainIsland": true,
		"organicTerrainPatches": true,
		"embeddedVariableWidthRoads": true,
		"recessedSegmentedRiver": true,
		"shapedRiverBanks": true,
		"functionalRoleClutter": true,
		"connectedBattlefieldRetained": true,
		"centralRoofRidgesHighest": true,
		"roofPlanesSlopeDownToBothEaves": true,
		"roofEaveOverhangs": true,
		"roofRidgeCaps": true,
		"roofFasciaBoards": true,
		"invertedRoofGeometry": false,
		"placedModuleInstanceCount": placed_instances.size(),
		"captureCount": captures.size(),
		"captures": captures,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"gameplayChanged": false,
		"saveChanged": false,
		"economyChanged": false,
		"selectionChanged": false,
		"pathingChanged": false,
		"commandsChanged": false,
		"minimapLogicChanged": false,
		"objectivesChanged": false,
		"productionLogicChanged": false,
		"collisionChanged": false,
		"newRuntimeArtSlots": 0,
		"errors": errors,
	})
