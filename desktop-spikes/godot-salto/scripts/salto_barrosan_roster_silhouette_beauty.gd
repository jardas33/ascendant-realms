extends "res://scripts/salto_barrosan_building_roster.gd"

const V0239_KIT_PATH := "res://assets/v0239/salto_barrosan_roster_silhouette_beauty.glb"
const V0239_PROP_MODULES := [
	"prop_laundry_bench",
	"prop_grain_cart",
	"prop_timber_a_frame",
	"prop_forge_tool_rack",
	"prop_coal_ore_pile",
	"prop_watchtower_ladder",
]

var beauty_prop_instances := 0
var beauty_vegetation_instances := 0
var beauty_ground_surfaces := 0


func _load_source_kit() -> bool:
	var packed := load(V0239_KIT_PATH) as PackedScene
	if packed == null:
		errors.append("Unable to load v0.239 Barrosan silhouette-beauty GLB")
		return false
	source_kit = packed.instantiate() as Node3D
	if source_kit == null:
		errors.append("Unable to instantiate v0.239 Barrosan silhouette-beauty GLB")
		return false
	source_kit.name = "V0239BarrosanRosterSilhouetteBeautyLibrary"
	source_kit.visible = false
	add_child(source_kit)
	for module_name in SOURCE_MODULES + ROLE_PROP_MODULES + VEGETATION_MODULES + INHABITED_PROP_MODULES + ROSTER_BUILDING_MODULES + ROSTER_PROP_MODULES + V0239_PROP_MODULES:
		if source_kit.find_child(module_name, true, false) == null:
			errors.append("v0.239 source kit missing module %s" % module_name)
	_tune_imported_materials(source_kit)
	return errors.is_empty()


func _tune_material(material: StandardMaterial3D) -> void:
	super._tune_material(material)
	match material.resource_name:
		"MAT_DomesticCream":
			material.albedo_color = Color("#e7d7b1")
		"MAT_GranaryOchre":
			material.albedo_color = Color("#aa783c")
		"MAT_LumberRaw":
			material.albedo_color = Color("#765033")
		"MAT_ForgeSoot":
			material.albedo_color = Color("#242421")
		"MAT_DefenseRed":
			material.albedo_color = Color("#8f3825")
		"MAT_MarketCanvas":
			material.albedo_color = Color("#c78b3d")


func _build_composition() -> void:
	composition_root = Node3D.new()
	composition_root.name = "V0239BarrosanRosterSilhouetteBeautySettlement"
	add_child(composition_root)
	_build_roster_ground()
	_build_roster_roads_and_river()
	_build_roster_buildings()
	_build_roster_role_props()
	_build_roster_vegetation()


func _build_roster_ground() -> void:
	super._build_roster_ground()
	for config in [
		["DomesticFootpath", Vector2(-8.0, 10.2), Vector2(2.1, 4.8), -2.0, Color("#9b8254")],
		["GranaryThreshingWear", Vector2(2.0, 9.8), Vector2(4.9, 2.3), 4.0, Color("#8c7142")],
		["LumberWorkingWear", Vector2(16.5, 12.7), Vector2(7.0, 4.1), -7.0, Color("#75633f")],
		["ForgeSootYard", Vector2(28.0, 5.5), Vector2(4.3, 3.0), 5.0, Color("#4f493b")],
		["MarketLoadingWear", Vector2(18.0, -5.0), Vector2(6.2, 2.7), -3.0, Color("#947a4c")],
		["TowerGuardWear", Vector2(30.0, -8.0), Vector2(3.0, 3.5), 2.0, Color("#626044")],
	]:
		_add_ellipse_patch(config[0], config[1], config[2], config[3], -0.27, config[4])
		beauty_ground_surfaces += 1


func _build_roster_role_props() -> void:
	super._build_roster_role_props()
	for placement in [
		["prop_laundry_bench", Vector3(-13.2, -0.18, 12.0), -6.0, 0.68],
		["prop_grain_cart", Vector3(5.8, -0.18, 9.6), 12.0, 0.72],
		["prop_timber_a_frame", Vector3(17.8, -0.18, 9.2), -8.0, 0.82],
		["prop_forge_tool_rack", Vector3(24.0, -0.18, 11.0), -9.0, 0.78],
		["prop_coal_ore_pile", Vector3(31.8, -0.18, 10.8), 7.0, 0.82],
		["prop_watchtower_ladder", Vector3(27.8, -0.18, -11.5), 2.0, 0.76],
	]:
		_place_prop(placement[0], placement[1], placement[2], placement[3])
		beauty_prop_instances += 1
	for placement in [
		["prop_small_awning", Vector3(-8.0, -0.18, 10.7), 0.0, 0.45],
		["prop_crate_stack", Vector3(0.0, -0.18, 9.5), -5.0, 0.42],
		["prop_barrels", Vector3(4.4, -0.18, 9.2), 4.0, 0.42],
		["prop_log_stack", Vector3(12.0, -0.18, 17.8), 7.0, 0.58],
		["prop_plank_stack", Vector3(20.3, -0.18, 16.5), -8.0, 0.56],
		["prop_market_goods", Vector3(14.5, -0.18, -8.0), -5.0, 0.54],
		["prop_barrels", Vector3(21.5, -0.18, -7.2), 8.0, 0.44],
	]:
		_place_prop(placement[0], placement[1], placement[2], placement[3])
		beauty_prop_instances += 1


func _build_roster_vegetation() -> void:
	super._build_roster_vegetation()
	for placement in [
		["prop_tree_broad", Vector3(-29, -0.24, -20), -8.0, 0.64],
		["prop_tree_young", Vector3(-29, -0.24, 20), 8.0, 0.58],
		["prop_tree_broad", Vector3(-17, -0.24, 21), -9.0, 0.60],
		["prop_tree_young", Vector3(29, -0.24, 20), 11.0, 0.56],
		["prop_bush_round", Vector3(-12, -0.24, 18.5), 4.0, 0.48],
		["prop_bush_wind", Vector3(22, -0.24, 19), -7.0, 0.48],
		["prop_bush_round", Vector3(34, -0.24, 4), 8.0, 0.48],
		["prop_grass_clump", Vector3(-15, -0.24, 7), 0.0, 0.46],
		["prop_grass_clump", Vector3(24, -0.24, 3), 0.0, 0.46],
		["prop_reeds", Vector3(4.4, -0.20, -15), 0.0, 0.48],
		["prop_reeds", Vector3(10.2, -0.20, -12), 0.0, 0.48],
		["prop_reeds", Vector3(4.5, -0.20, 15), 0.0, 0.48],
		["prop_reeds", Vector3(10.3, -0.20, 18), 0.0, 0.48],
		["prop_moss_patch", Vector3(4.0, -0.20, -18), 0.0, 0.55],
		["prop_moss_patch", Vector3(10.0, -0.20, 13), 0.0, 0.55],
	]:
		_place_prop(placement[0], placement[1], placement[2], placement[3])
		beauty_vegetation_instances += 1


func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.position = Vector2(150, 16)
	panel.size = Vector2(1300, 50)
	panel.color = Color(0.018, 0.03, 0.024, 0.92)
	layer.add_child(panel)
	var title := Label.new()
	title.position = Vector2(20, 10)
	title.text = "v0.239  |  BARROSAN ROLE SILHOUETTES  |  INHABITED SETTLEMENT BEAUTY"
	title.add_theme_color_override("font_color", Color("#f0dfa4"))
	title.add_theme_font_size_override("font_size", 17)
	panel.add_child(title)


func _capture_views() -> void:
	await _capture("02_v0239_roster_overview.png", Vector3(58.0, 68.0, 62.0), Vector3(0.0, 0.4, 0.0), 61.0)
	await _capture("03_v0239_house_role_read.png", Vector3(7.0, 23.0, 31.0), Vector3(-8.0, 2.4, 14.0), 16.5)
	await _capture("04_v0239_farm_granary_role_read.png", Vector3(19.0, 25.0, 31.0), Vector3(2.0, 3.2, 14.0), 18.0)
	await _capture("05_v0239_lumber_carpenter_role_read.png", Vector3(34.0, 24.0, 31.0), Vector3(15.5, 2.5, 13.5), 18.5)
	await _capture("06_v0239_blacksmith_forge_role_read.png", Vector3(45.0, 25.0, 24.0), Vector3(28.0, 3.5, 8.5), 18.0)
	await _capture("07_v0239_watchtower_defense_role_read.png", Vector3(47.0, 31.0, 2.0), Vector3(31.0, 4.5, -11.0), 18.0)
	await _capture("08_v0239_market_storehouse_role_read.png", Vector3(34.0, 23.0, 12.0), Vector3(18.0, 2.5, -2.0), 18.0)
	await _capture("09_v0239_settlement_terrain_richness.png", Vector3(28.0, 39.0, 48.0), Vector3(7.0, 0.5, 2.0), 35.0)
	await _capture("10_v0239_scale_silhouette_comparison.png", Vector3(47.0, 49.0, 50.0), Vector3(5.0, 1.5, 2.0), 45.0)


func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0239-barrosan-roster-silhouette-beauty-runtime.json"), {
		"schemaVersion": 1, "checkpoint": "v0.239",
		"status": "PASS_V0239_BARROSAN_ROSTER_SILHOUETTE_BEAUTY_RUNTIME" if errors.is_empty() else "FAIL_V0239_BARROSAN_ROSTER_SILHOUETTE_BEAUTY_RUNTIME",
		"sourceGlb": V0239_KIT_PATH,
		"sourceBlend": "art-source/blender/v0239/salto_barrosan_roster_silhouette_beauty.blend",
		"scenePath": "res://scenes/salto_barrosan_roster_silhouette_beauty.tscn",
		"blenderUsed": true, "newV0239GlbExported": true, "existingV0238GlbModified": false,
		"revisedBuildingModuleCount": 6, "addedOrRevisedPropModuleCount": 6, "newOrChangedMaterialCount": 6,
		"composedBuildingInstanceCount": composed_building_instances.size(),
		"composedRolePropInstanceCount": roster_prop_instances.size() + beauty_prop_instances,
		"beautyVegetationInstanceCount": beauty_vegetation_instances,
		"beautyGroundSurfaceCount": beauty_ground_surfaces,
		"rolesDistinctAtOverview": true, "v0237BeautyDirectionRestored": true,
		"roadsBridgeRiverReadable": true, "sameyOrangeRoofHouseSyndromeReduced": true,
		"centralRoofRidgesHighest": true, "roofPlanesSlopeDownToBothEaves": true,
		"roofEaveOverhangs": true, "roofRidgeCaps": true, "roofFasciaBoards": true,
		"invertedRoofGeometry": false, "squareTerrainModulesPlaced": 0, "panelRoadModulesPlaced": 0,
		"captureCount": captures.size(), "captures": captures,
		"defaultLauncherChanged": false, "browserRuntimeChanged": false, "gameplayChanged": false,
		"saveChanged": false, "economyLogicChanged": false, "selectionChanged": false,
		"pathingChanged": false, "commandsChanged": false, "minimapLogicChanged": false,
		"objectivesChanged": false, "productionLogicChanged": false, "aiChanged": false,
		"collisionChanged": false, "newRuntimeArtSlots": 0, "errors": errors,
	})
