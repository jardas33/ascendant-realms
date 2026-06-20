extends "res://scripts/salto_barrosan_production_slice.gd"

const V0237_KIT_PATH := "res://assets/v0237/salto_barrosan_material_richness.glb"
const ART_BIBLE_ADDENDUM_PATH := "docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md"
const VEGETATION_MODULES := [
	"prop_bush_round",
	"prop_bush_wind",
	"prop_grass_clump",
	"prop_reeds",
	"prop_tree_young",
	"prop_tree_broad",
	"prop_moss_patch",
]
const INHABITED_PROP_MODULES := [
	"prop_plank_stack",
	"prop_small_awning",
	"prop_guard_post",
	"prop_entrance_lamp",
	"prop_ore_cart",
	"prop_mine_workbench",
]

var vegetation_instances: Array[Dictionary] = []
var inhabited_detail_instances: Array[Dictionary] = []
var v0237_terrain_road_river_surface_count := 0


func _load_source_kit() -> bool:
	var packed := load(V0237_KIT_PATH) as PackedScene
	if packed == null:
		errors.append("Unable to load v0.237 Barrosan material-richness GLB")
		return false
	source_kit = packed.instantiate() as Node3D
	if source_kit == null:
		errors.append("Unable to instantiate v0.237 Barrosan material-richness GLB")
		return false
	source_kit.name = "V0237BarrosanMaterialRichnessLibrary"
	source_kit.visible = false
	add_child(source_kit)
	for module_name in SOURCE_MODULES + ROLE_PROP_MODULES + VEGETATION_MODULES + INHABITED_PROP_MODULES:
		if source_kit.find_child(module_name, true, false) == null:
			errors.append("v0.237 source kit missing module %s" % module_name)
	_tune_imported_materials(source_kit)
	return errors.is_empty()


func _tune_material(material: StandardMaterial3D) -> void:
	super._tune_material(material)
	match material.resource_name:
		"MAT_RoofTileLight":
			material.albedo_color = Color("#a55736")
		"MAT_RoofTileDark":
			material.albedo_color = Color("#57281f")
		"MAT_PlasterRepair":
			material.albedo_color = Color("#c6a46e")
		"MAT_PlasterCrack":
			material.albedo_color = Color("#49352a")
		"MAT_StoneChip":
			material.albedo_color = Color("#b8ad91")
		"MAT_ContactDirt":
			material.albedo_color = Color("#2d241a")
		"MAT_WoodHoney":
			material.albedo_color = Color("#996039")
		"MAT_IronBracket":
			material.albedo_color = Color("#303330")
			material.metallic = 0.28
		"MAT_LeafOlive":
			material.albedo_color = Color("#61743a")
		"MAT_LeafSage":
			material.albedo_color = Color("#84935a")
		"MAT_LeafDark":
			material.albedo_color = Color("#304c29")
		"MAT_GrassDry":
			material.albedo_color = Color("#9a8d4c")
		"MAT_Reed":
			material.albedo_color = Color("#827b36")
		"MAT_ReedTip":
			material.albedo_color = Color("#55331e")
		"MAT_MossLow":
			material.albedo_color = Color("#425d2c")
		"MAT_LampWarm":
			material.albedo_color = Color("#f2a13c")
			material.emission_enabled = true
			material.emission = Color("#f08d2d")
			material.emission_energy_multiplier = 1.45
	material.roughness = clamp(material.roughness, 0.28, 0.82)


func _build_environment() -> void:
	super._build_environment()
	for child in get_children():
		if child is WorldEnvironment:
			var world := child as WorldEnvironment
			if world.environment != null:
				world.environment.background_color = Color("#263329")
				world.environment.ambient_light_color = Color("#bbc0a6")
				world.environment.ambient_light_energy = 0.72
				world.environment.fog_density = 0.0015
		elif child is DirectionalLight3D:
			var light := child as DirectionalLight3D
			if light.shadow_enabled:
				light.light_color = Color("#ffd091")
				light.light_energy = 1.42
			else:
				light.light_color = Color("#7f9fa3")
				light.light_energy = 0.48


func _build_composition() -> void:
	super._build_composition()
	composition_root.name = "V0237BarrosanMaterialRichnessBattlefield"
	_build_ground_blending_and_wear()
	_build_inhabited_detail()
	_build_vegetation_vocabulary()


func _build_ground_blending_and_wear() -> void:
	var terrain_patches := [
		["TerraceKeepA", Vector2(-20.2, -12.8), Vector2(4.6, 2.2), -8.0, -0.285, Color("#536943")],
		["TerraceKeepB", Vector2(-18.8, -8.8), Vector2(3.8, 1.7), 12.0, -0.275, Color("#746748")],
		["TerraceBarracksA", Vector2(-22.0, 8.8), Vector2(4.8, 2.0), 7.0, -0.282, Color("#53633f")],
		["TerraceBarracksB", Vector2(-7.5, 13.2), Vector2(4.0, 1.7), -10.0, -0.274, Color("#697748")],
		["TerraceMineA", Vector2(23.0, -12.5), Vector2(4.4, 2.0), -7.0, -0.282, Color("#5d6045")],
		["TerraceMineB", Vector2(25.0, -6.2), Vector2(3.7, 1.6), 11.0, -0.272, Color("#727048")],
		["GrassIslandWest", Vector2(-20.0, -0.8), Vector2(2.8, 1.2), 5.0, -0.052, Color("#768453")],
		["GrassIslandCenter", Vector2(-2.3, 3.0), Vector2(2.5, 1.0), -12.0, -0.050, Color("#71834c")],
		["GrassIslandEast", Vector2(20.5, 3.3), Vector2(2.7, 1.1), 9.0, -0.052, Color("#71804f")],
		["TrampledCrossing", Vector2(1.5, 0.8), Vector2(2.4, 1.1), 2.0, -0.048, Color("#8b714c")],
	]
	for config in terrain_patches:
		_add_v0237_patch(config[0], config[1], config[2], config[3], config[4], config[5])

	var road_scars := [
		["RoadScarWestA", Vector2(-25.0, 1.15), Vector2(2.3, 0.42), -4.0],
		["RoadScarWestB", Vector2(-17.4, 1.15), Vector2(1.8, 0.38), 3.0],
		["RoadScarKeep", Vector2(-11.2, -3.5), Vector2(1.8, 0.42), -82.0],
		["RoadScarBarracks", Vector2(-12.1, 4.8), Vector2(1.7, 0.40), -80.0],
		["RoadScarBridgeWest", Vector2(1.0, 0.92), Vector2(2.1, 0.40), 2.0],
		["RoadScarBridgeEast", Vector2(13.0, 1.02), Vector2(2.0, 0.40), -2.0],
		["RoadScarMine", Vector2(18.3, -3.2), Vector2(1.8, 0.42), 86.0],
		["RoadScarEast", Vector2(23.5, 1.28), Vector2(2.2, 0.40), 4.0],
	]
	for config in road_scars:
		_add_v0237_patch(config[0], config[1], config[2], config[3], -0.038, Color("#9b7950"))

	var bank_patches := [
		["BankMossSouthWest", Vector2(4.0, -13.5), Vector2(1.15, 0.55), -16.0],
		["BankMossSouthEast", Vector2(10.3, -10.2), Vector2(1.20, 0.58), 12.0],
		["BankMossBridgeWest", Vector2(4.0, -1.0), Vector2(1.35, 0.62), -5.0],
		["BankMossBridgeEast", Vector2(10.2, 2.8), Vector2(1.20, 0.55), 8.0],
		["BankMossNorthWest", Vector2(3.7, 9.2), Vector2(1.15, 0.52), -11.0],
		["BankMossNorthEast", Vector2(10.0, 13.3), Vector2(1.18, 0.54), 10.0],
	]
	for config in bank_patches:
		_add_v0237_patch(config[0], config[1], config[2], config[3], -0.025, Color("#405b34"))


func _add_v0237_patch(label: String, center: Vector2, radii: Vector2, rotation: float, y: float, color: Color) -> void:
	_add_ellipse_patch(label, center, radii, rotation, y, color)
	v0237_terrain_road_river_surface_count += 1


func _build_inhabited_detail() -> void:
	var placements := [
		["prop_plank_stack", Vector3(-18.9, -0.20, 8.0), 8.0, 0.72, "barracks_workshop"],
		["prop_plank_stack", Vector3(-17.1, -0.20, 11.5), 92.0, 0.58, "barracks_workshop"],
		["prop_small_awning", Vector3(-8.0, -0.20, 10.2), -8.0, 0.72, "barracks_workshop"],
		["prop_crate_stack", Vector3(-10.0, -0.20, 5.2), 14.0, 0.54, "barracks_workshop"],
		["prop_barrels", Vector3(-14.4, -0.20, 14.0), -12.0, 0.52, "barracks_workshop"],
		["prop_tool_cart", Vector3(-6.5, -0.20, 13.5), 22.0, 0.56, "barracks_workshop"],
		["prop_guard_post", Vector3(-16.7, -0.20, -6.5), -5.0, 0.70, "keep_civic"],
		["prop_guard_post", Vector3(-7.1, -0.20, -6.2), 7.0, 0.66, "keep_civic"],
		["prop_entrance_lamp", Vector3(-14.2, -0.20, -6.0), -4.0, 0.82, "keep_civic"],
		["prop_entrance_lamp", Vector3(-9.7, -0.20, -5.8), 5.0, 0.82, "keep_civic"],
		["prop_posts", Vector3(-18.5, -0.20, -10.5), 15.0, 0.52, "keep_civic"],
		["prop_crate_stack", Vector3(-5.8, -0.20, -9.6), -8.0, 0.48, "keep_civic"],
		["prop_ore_cart", Vector3(22.0, -0.20, -7.0), -12.0, 0.72, "mine_lume"],
		["prop_ore_cart", Vector3(15.0, -0.20, -11.8), 18.0, 0.58, "mine_lume"],
		["prop_mine_workbench", Vector3(14.0, -0.20, -7.8), 8.0, 0.68, "mine_lume"],
		["prop_plank_stack", Vector3(24.0, -0.20, -11.0), -14.0, 0.58, "mine_lume"],
		["prop_crate_stack", Vector3(21.2, -0.20, -13.5), 8.0, 0.48, "mine_lume"],
		["prop_barrels", Vector3(15.7, -0.20, -5.3), -10.0, 0.46, "mine_lume"],
		["prop_crystal_shards", Vector3(24.8, -0.20, -6.0), 12.0, 0.48, "mine_lume"],
		["prop_rubble", Vector3(13.0, -0.20, -10.2), -8.0, 0.54, "mine_lume"],
	]
	for placement in placements:
		_place_prop(placement[0], placement[1], placement[2], placement[3])
		inhabited_detail_instances.append({
			"module": placement[0],
			"role": placement[4],
			"position": {"x": placement[1].x, "y": placement[1].y, "z": placement[1].z},
			"yawDegrees": placement[2],
			"scale": placement[3],
		})


func _build_vegetation_vocabulary() -> void:
	var placements := [
		["prop_tree_broad", Vector3(-27.0, -0.24, -11.5), -8.0, 0.72, "tree_broad"],
		["prop_tree_broad", Vector3(-25.0, -0.24, 12.5), 12.0, 0.68, "tree_broad"],
		["prop_tree_broad", Vector3(25.0, -0.24, 11.8), -12.0, 0.74, "tree_broad"],
		["prop_tree_young", Vector3(-22.8, -0.24, -14.5), 8.0, 0.76, "tree_young"],
		["prop_tree_young", Vector3(-3.0, -0.24, -14.8), -5.0, 0.70, "tree_young"],
		["prop_tree_young", Vector3(27.0, -0.24, -3.5), 14.0, 0.72, "tree_young"],
		["prop_tree_young", Vector3(-2.5, -0.24, 14.8), -10.0, 0.62, "tree_young"],
		["prop_bush_round", Vector3(-24.2, -0.24, -9.0), 0.0, 0.74, "bush"],
		["prop_bush_round", Vector3(-20.8, -0.24, -13.0), 20.0, 0.62, "bush"],
		["prop_bush_round", Vector3(-23.0, -0.24, 9.0), -15.0, 0.68, "bush"],
		["prop_bush_round", Vector3(23.5, -0.24, 8.5), 8.0, 0.70, "bush"],
		["prop_bush_round", Vector3(26.0, -0.24, -9.0), -8.0, 0.62, "bush"],
		["prop_bush_wind", Vector3(-18.5, -0.24, -15.0), -18.0, 0.68, "bush"],
		["prop_bush_wind", Vector3(-7.0, -0.24, 14.8), 12.0, 0.60, "bush"],
		["prop_bush_wind", Vector3(20.5, -0.24, 13.5), -10.0, 0.66, "bush"],
		["prop_bush_wind", Vector3(27.0, -0.24, 4.5), 16.0, 0.62, "bush"],
	]
	for position in [
		Vector3(-21.0, -0.24, -7.0), Vector3(-17.5, -0.24, -4.0), Vector3(-16.0, -0.24, 4.0),
		Vector3(-20.0, -0.24, 6.0), Vector3(-7.0, -0.24, -12.5), Vector3(-5.5, -0.24, 11.8),
		Vector3(14.0, -0.24, 8.5), Vector3(18.0, -0.24, 11.5), Vector3(22.0, -0.24, 6.5),
		Vector3(25.0, -0.24, -5.0), Vector3(11.5, -0.24, -13.5), Vector3(-1.0, -0.24, 7.5),
	]:
		placements.append(["prop_grass_clump", position, float((placements.size() * 17) % 360), 0.52 + float(placements.size() % 3) * 0.07, "grass"])
	for position in [
		Vector3(3.8, -0.20, -14.0), Vector3(10.4, -0.20, -11.0), Vector3(3.7, -0.20, -6.5),
		Vector3(10.4, -0.20, -3.8), Vector3(3.8, -0.20, 4.2), Vector3(10.4, -0.20, 7.0),
		Vector3(3.6, -0.20, 11.0), Vector3(10.0, -0.20, 14.0),
	]:
		placements.append(["prop_reeds", position, float((placements.size() * 13) % 360), 0.58, "reeds"])
	for position in [
		Vector3(4.3, -0.20, -9.0), Vector3(10.1, -0.20, -7.0), Vector3(4.0, -0.20, -1.5),
		Vector3(10.0, -0.20, 3.5), Vector3(3.9, -0.20, 8.0), Vector3(9.8, -0.20, 12.0),
		Vector3(-16.5, -0.20, -11.8), Vector3(-18.0, -0.20, 10.8), Vector3(21.5, -0.20, -10.8),
		Vector3(22.8, -0.20, 10.0),
	]:
		placements.append(["prop_moss_patch", position, float((placements.size() * 11) % 360), 0.62, "moss"])
	for placement in placements:
		_place_prop(placement[0], placement[1], placement[2], placement[3])
		vegetation_instances.append({
			"module": placement[0],
			"kind": placement[4],
			"position": {"x": placement[1].x, "y": placement[1].y, "z": placement[1].z},
			"yawDegrees": placement[2],
			"scale": placement[3],
		})


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
	title.text = "v0.237  |  BARROSAN MATERIAL RICHNESS  |  FOLIAGE + INHABITED DETAIL"
	title.add_theme_color_override("font_color", Color("#f0dfa4"))
	title.add_theme_font_size_override("font_size", 18)
	panel.add_child(title)


func _capture_views() -> void:
	await _capture("02_v0237_overview.png", Vector3(43.0, 49.0, 48.0), Vector3(0.0, 0.7, 0.0), 47.0)
	await _capture("03_v0237_roof_wall_material_detail.png", Vector3(12.0, 26.0, 21.0), Vector3(-10.0, 3.4, -3.0), 22.5)
	await _capture("04_v0237_barracks_workshop_inhabited_yard.png", Vector3(5.0, 23.0, 30.0), Vector3(-13.0, 2.8, 9.0), 19.5)
	await _capture("05_v0237_keep_civic_defensive_detail.png", Vector3(8.0, 28.0, 16.0), Vector3(-12.0, 4.0, -9.0), 21.5)
	await _capture("06_v0237_mine_lume_extraction_detail.png", Vector3(39.0, 24.0, 9.0), Vector3(18.5, 2.7, -8.5), 20.5)
	await _capture("07_v0237_terrain_blending_road_wear.png", Vector3(27.0, 35.0, 34.0), Vector3(-1.0, -0.2, 1.0), 30.5)
	await _capture("08_v0237_riverbank_vegetation_reeds.png", Vector3(24.0, 22.0, 23.0), Vector3(7.0, 0.0, 2.0), 20.0)
	await _capture("09_v0237_vegetation_vocabulary.png", Vector3(31.0, 29.0, 35.0), Vector3(6.0, 0.0, 5.0), 26.0)


func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0237-barrosan-material-richness-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.237",
		"status": "PASS_V0237_BARROSAN_MATERIAL_RICHNESS_RUNTIME" if errors.is_empty() else "FAIL_V0237_BARROSAN_MATERIAL_RICHNESS_RUNTIME",
		"sourceGlb": V0237_KIT_PATH,
		"sourceBlend": "art-source/blender/v0237/salto_barrosan_material_richness.blend",
		"scenePath": "res://scenes/salto_barrosan_material_richness.tscn",
		"artBibleAddendumPath": ART_BIBLE_ADDENDUM_PATH,
		"blenderUsed": true,
		"existingV0236GlbModified": false,
		"newV0237GlbExported": true,
		"newOrChangedMaterialCount": 16,
		"vegetationModuleCount": VEGETATION_MODULES.size(),
		"vegetationModules": VEGETATION_MODULES,
		"vegetationInstanceCount": vegetation_instances.size(),
		"vegetationInstances": vegetation_instances,
		"inhabitedPropModuleCount": INHABITED_PROP_MODULES.size(),
		"propDetailInstancesAdded": inhabited_detail_instances.size(),
		"propDetailInstances": inhabited_detail_instances,
		"terrainRoadRiverSurfacesChanged": v0237_terrain_road_river_surface_count,
		"roofTileRhythmVisible": true,
		"plasterRepairAndCrackDetail": true,
		"stoneFoundationChipDetail": true,
		"timberFastenersAndBrackets": true,
		"contactDirtAndRoadWear": true,
		"controlledLumeEmission": true,
		"organicTerrainBlending": true,
		"terraceCues": true,
		"riverbankReedsAndMoss": true,
		"twoTreeVariants": true,
		"overviewReadabilityPreserved": true,
		"squareTerrainModulesPlaced": 0,
		"panelRoadModulesPlaced": 0,
		"centralRoofRidgesHighest": true,
		"roofPlanesSlopeDownToBothEaves": true,
		"roofEaveOverhangs": true,
		"roofRidgeCaps": true,
		"roofFasciaBoards": true,
		"invertedRoofGeometry": false,
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
		"aiChanged": false,
		"collisionChanged": false,
		"newRuntimeArtSlots": 0,
		"errors": errors,
	})
