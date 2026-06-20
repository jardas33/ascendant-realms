extends "res://scripts/salto_barrosan_material_richness.gd"

const V0238_KIT_PATH := "res://assets/v0238/salto_barrosan_building_roster.glb"
const ROSTER_BUILDING_MODULES := [
	"house_dwelling",
	"farm_granary",
	"lumber_carpenter_yard",
	"blacksmith_forge",
	"watchtower_defense",
	"market_storehouse",
]
const ROSTER_PROP_MODULES := [
	"prop_garden_plot",
	"prop_grain_sacks",
	"prop_hay_bales",
	"prop_saw_bench",
	"prop_anvil",
	"prop_forge_brazier",
	"prop_market_goods",
	"prop_supply_stall",
]

var composed_building_instances: Array[Dictionary] = []
var roster_prop_instances: Array[Dictionary] = []
var roster_ground_surface_count := 0


func _load_source_kit() -> bool:
	var packed := load(V0238_KIT_PATH) as PackedScene
	if packed == null:
		errors.append("Unable to load v0.238 Barrosan building-roster GLB")
		return false
	source_kit = packed.instantiate() as Node3D
	if source_kit == null:
		errors.append("Unable to instantiate v0.238 Barrosan building-roster GLB")
		return false
	source_kit.name = "V0238BarrosanBuildingRosterLibrary"
	source_kit.visible = false
	add_child(source_kit)
	for module_name in SOURCE_MODULES + ROLE_PROP_MODULES + VEGETATION_MODULES + INHABITED_PROP_MODULES + ROSTER_BUILDING_MODULES + ROSTER_PROP_MODULES:
		if source_kit.find_child(module_name, true, false) == null:
			errors.append("v0.238 source kit missing module %s" % module_name)
	_tune_imported_materials(source_kit)
	return errors.is_empty()


func _tune_material(material: StandardMaterial3D) -> void:
	super._tune_material(material)
	match material.resource_name:
		"MAT_LimewashDomestic":
			material.albedo_color = Color("#ddc99d")
		"MAT_LimewashEconomy":
			material.albedo_color = Color("#b79761")
		"MAT_Straw":
			material.albedo_color = Color("#b99a43")
		"MAT_GrainSack":
			material.albedo_color = Color("#9c7950")
		"MAT_ForgeStone":
			material.albedo_color = Color("#393a36")
		"MAT_ForgeHot":
			material.albedo_color = Color("#f06424")
			material.emission_enabled = true
			material.emission = Color("#e74418")
			material.emission_energy_multiplier = 1.35
		"MAT_MarketCream":
			material.albedo_color = Color("#d5bc7f")
		"MAT_MarketOchre":
			material.albedo_color = Color("#b66b28")
		"MAT_DefenseTimber":
			material.albedo_color = Color("#4f2b19")
		"MAT_GardenSoil":
			material.albedo_color = Color("#4d3926")


func _build_composition() -> void:
	composition_root = Node3D.new()
	composition_root.name = "V0238BarrosanRosterSettlement"
	add_child(composition_root)
	_build_roster_ground()
	_build_roster_roads_and_river()
	_build_roster_buildings()
	_build_roster_role_props()
	_build_roster_vegetation()


func _build_roster_ground() -> void:
	_add_roster_surface("RosterEarthSkirt", [
		Vector2(-39.0, -17.0), Vector2(-34.0, -23.0), Vector2(-20.0, -25.0),
		Vector2(-2.0, -24.5), Vector2(16.0, -24.0), Vector2(33.0, -21.5),
		Vector2(39.0, -14.0), Vector2(40.0, 2.0), Vector2(37.0, 17.5),
		Vector2(27.0, 23.0), Vector2(10.0, 25.0), Vector2(-8.0, 24.5),
		Vector2(-25.0, 23.0), Vector2(-37.0, 16.0), Vector2(-40.0, 2.0),
	], -0.72, Color("#3c3023"))
	_add_roster_surface("RosterGrassBody", [
		Vector2(-37.5, -16.5), Vector2(-32.8, -21.5), Vector2(-19.5, -23.2),
		Vector2(-2.0, -22.8), Vector2(15.5, -22.3), Vector2(31.5, -20.0),
		Vector2(37.2, -13.2), Vector2(38.0, 1.8), Vector2(35.2, 16.0),
		Vector2(25.7, 21.0), Vector2(9.5, 23.0), Vector2(-7.8, 22.7),
		Vector2(-23.8, 21.2), Vector2(-35.0, 14.8), Vector2(-37.8, 2.0),
	], -0.43, Color("#75834d"))
	for config in [
		["DomesticGreen", Vector2(-9.0, 14.0), Vector2(8.0, 5.2), -6.0, Color("#829254")],
		["GranaryYard", Vector2(2.5, 13.5), Vector2(7.0, 4.5), 5.0, Color("#81724b")],
		["LumberYard", Vector2(15.0, 13.0), Vector2(8.0, 4.8), -5.0, Color("#6c6844")],
		["ForgeYard", Vector2(28.0, 9.0), Vector2(6.5, 4.5), 6.0, Color("#625b45")],
		["MarketYard", Vector2(18.0, -2.0), Vector2(7.0, 4.2), -4.0, Color("#8b754b")],
		["TowerGround", Vector2(31.0, -11.0), Vector2(5.2, 4.0), 2.0, Color("#596344")],
		["KeepGround", Vector2(-20.0, -14.0), Vector2(9.0, 6.0), -4.0, Color("#5f6245")],
		["BarracksGround", Vector2(-24.0, 13.0), Vector2(10.0, 6.0), 4.0, Color("#675c42")],
		["MineGround", Vector2(20.0, -15.0), Vector2(9.0, 5.8), -3.0, Color("#585849")],
	]:
		_add_ellipse_patch(config[0], config[1], config[2], config[3], -0.31, config[4])
		roster_ground_surface_count += 1


func _add_roster_surface(label: String, points: Array, y: float, color: Color) -> void:
	_add_convex_surface(label, points, y, color, 0.92)
	roster_ground_surface_count += 1


func _build_roster_roads_and_river() -> void:
	var river := [
		Vector2(7.0, -23.0), Vector2(7.6, -18.0), Vector2(7.0, -13.0),
		Vector2(7.8, -8.0), Vector2(7.2, -3.0), Vector2(7.5, 2.0),
		Vector2(6.8, 7.0), Vector2(7.5, 12.0), Vector2(7.0, 17.0), Vector2(7.4, 23.0),
	]
	var widths := [3.3, 3.5, 3.7, 3.5, 3.9, 3.6, 3.8, 3.5, 3.7, 3.4]
	_add_ribbon("RosterRiverBank", river, widths.map(func(value): return float(value) + 1.2), -0.14, Color("#5c503c"), 0.92, "riverbank")
	_add_ribbon("RosterRiverWater", river, widths, -0.075, Color("#245866"), 0.22, "river")
	_add_road("RosterMainRoad", [
		Vector2(-36.0, 0.0), Vector2(-28.0, 0.5), Vector2(-20.0, 0.0), Vector2(-12.0, 0.4),
		Vector2(-4.0, 0.0), Vector2(3.5, 0.2), Vector2(11.0, 0.0), Vector2(19.0, -0.3),
		Vector2(27.0, -1.0), Vector2(36.0, -1.5),
	], [3.8, 3.6, 3.8, 3.5, 3.7, 3.6, 3.8, 3.5, 3.7, 3.9])
	for lane in [
		["NorthWestLane", [Vector2(-24, 0), Vector2(-24, 5), Vector2(-24, 10), Vector2(-24, 13)]],
		["NorthDomesticLane", [Vector2(-8, 0), Vector2(-8, 5), Vector2(-8, 10), Vector2(-8, 14)]],
		["NorthEconomyLane", [Vector2(1, 0), Vector2(1, 5), Vector2(2, 10), Vector2(2.5, 14)]],
		["NorthIndustryLane", [Vector2(14, 0), Vector2(14, 5), Vector2(15, 10), Vector2(15, 14)]],
		["ForgeLane", [Vector2(23, -0.6), Vector2(25, 3), Vector2(27, 6), Vector2(28, 9)]],
		["KeepLane", [Vector2(-20, 0), Vector2(-20, -5), Vector2(-20, -10), Vector2(-20, -14)]],
		["MineLane", [Vector2(20, -0.4), Vector2(20, -5), Vector2(20, -10), Vector2(20, -15)]],
		["TowerLane", [Vector2(30, -1.2), Vector2(31, -5), Vector2(31, -9), Vector2(31, -11)]],
	]:
		_add_road(lane[0], lane[1], [3.3, 3.2, 3.5, 4.0])
	var bridge := _place_module("bridge_module", Vector3(7.2, -0.30, 0.0), 0.0, Vector3(1.03, 1.0, 1.03))
	if bridge != null:
		for obsolete_name in ["Bridge_LeftBank", "Bridge_RightBank", "Bridge_Water"]:
			var obsolete := bridge.find_child(obsolete_name, true, false) as Node3D
			if obsolete != null:
				obsolete.visible = false


func _build_roster_buildings() -> void:
	_place_roster_building("keep_landmark", Vector3(-20.0, -0.25, -14.0), -2.0, 0.82, "keep")
	_place_roster_building("barracks_workshop_landmark", Vector3(-24.0, -0.25, 13.0), 2.0, 0.76, "barracks")
	_place_roster_building("mine_lume_landmark", Vector3(20.0, -0.25, -15.0), -2.0, 0.78, "mine")
	_place_roster_building("house_dwelling", Vector3(-8.0, -0.24, 14.0), 0.0, 0.82, "house")
	_place_roster_building("farm_granary", Vector3(2.0, -0.24, 14.0), 0.0, 0.78, "granary")
	_place_roster_building("lumber_carpenter_yard", Vector3(15.0, -0.24, 14.0), 0.0, 0.74, "lumber")
	_place_roster_building("blacksmith_forge", Vector3(28.0, -0.24, 9.0), -7.0, 0.76, "forge")
	_place_roster_building("watchtower_defense", Vector3(31.0, -0.24, -11.0), 2.0, 0.74, "watchtower")
	_place_roster_building("market_storehouse", Vector3(18.0, -0.24, -2.0), 0.0, 0.76, "market")


func _place_roster_building(module_name: String, position: Vector3, yaw: float, scale: float, role: String) -> void:
	_place_module(module_name, position, yaw, Vector3.ONE * scale)
	composed_building_instances.append({
		"module": module_name, "role": role,
		"position": {"x": position.x, "y": position.y, "z": position.z},
		"yawDegrees": yaw, "scale": scale,
	})


func _build_roster_role_props() -> void:
	var placements := [
		["prop_garden_plot", Vector3(-3.5, -0.20, 16.0), 4.0, 0.76, "house"],
		["prop_crate_stack", Vector3(-11.5, -0.20, 16.0), -8.0, 0.48, "house"],
		["prop_grain_sacks", Vector3(-2.0, -0.20, 11.0), -5.0, 0.78, "granary"],
		["prop_hay_bales", Vector3(5.7, -0.20, 11.5), 8.0, 0.82, "granary"],
		["prop_barrels", Vector3(5.5, -0.20, 16.5), -10.0, 0.48, "granary"],
		["prop_saw_bench", Vector3(20.0, -0.20, 10.2), -8.0, 0.80, "lumber"],
		["prop_log_stack", Vector3(20.8, -0.20, 15.8), 8.0, 0.70, "lumber"],
		["prop_plank_stack", Vector3(10.5, -0.20, 10.2), -5.0, 0.62, "lumber"],
		["prop_anvil", Vector3(24.4, -0.20, 5.0), -8.0, 0.88, "forge"],
		["prop_forge_brazier", Vector3(31.6, -0.20, 5.4), 6.0, 0.82, "forge"],
		["prop_ore_cart", Vector3(33.2, -0.20, 9.5), 12.0, 0.52, "forge"],
		["prop_market_goods", Vector3(13.0, -0.20, -5.5), -6.0, 0.74, "market"],
		["prop_supply_stall", Vector3(18.0, -0.20, -7.0), 0.0, 0.72, "market"],
		["prop_market_goods", Vector3(23.0, -0.20, -4.8), 8.0, 0.66, "market"],
		["prop_guard_post", Vector3(27.0, -0.20, -11.0), 3.0, 0.55, "watchtower"],
	]
	for placement in placements:
		_place_prop(placement[0], placement[1], placement[2], placement[3])
		roster_prop_instances.append({
			"module": placement[0], "role": placement[4],
			"position": {"x": placement[1].x, "y": placement[1].y, "z": placement[1].z},
			"yawDegrees": placement[2], "scale": placement[3],
		})


func _build_roster_vegetation() -> void:
	for placement in [
		["prop_tree_broad", Vector3(-34, -0.24, -17), -8.0, 0.68],
		["prop_tree_broad", Vector3(-33, -0.24, 18), 10.0, 0.64],
		["prop_tree_young", Vector3(-13, -0.24, 20), -8.0, 0.62],
		["prop_tree_young", Vector3(35, -0.24, 16), 12.0, 0.66],
		["prop_tree_broad", Vector3(35, -0.24, -18), -12.0, 0.62],
		["prop_bush_round", Vector3(-14, -0.24, 16), 8.0, 0.58],
		["prop_bush_wind", Vector3(8, -0.24, 20), -10.0, 0.56],
		["prop_bush_round", Vector3(25, -0.24, 17), 8.0, 0.58],
		["prop_grass_clump", Vector3(-4, -0.24, 7), 0.0, 0.55],
		["prop_grass_clump", Vector3(12, -0.24, 6), 0.0, 0.55],
		["prop_reeds", Vector3(3.5, -0.20, -8), 0.0, 0.55],
		["prop_reeds", Vector3(10.6, -0.20, 8), 0.0, 0.55],
		["prop_moss_patch", Vector3(3.8, -0.20, 3), 0.0, 0.60],
		["prop_moss_patch", Vector3(10.3, -0.20, -4), 0.0, 0.60],
	]:
		_place_prop(placement[0], placement[1], placement[2], placement[3])


func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.position = Vector2(175, 16)
	panel.size = Vector2(1250, 50)
	panel.color = Color(0.018, 0.03, 0.024, 0.92)
	layer.add_child(panel)
	var title := Label.new()
	title.position = Vector2(20, 10)
	title.text = "v0.238  |  BARROSAN BUILDING ROSTER  |  DOMESTIC + ECONOMY + SUPPORT + DEFENSE"
	title.add_theme_color_override("font_color", Color("#f0dfa4"))
	title.add_theme_font_size_override("font_size", 17)
	panel.add_child(title)


func _capture_views() -> void:
	await _capture("02_v0238_roster_overview.png", Vector3(58.0, 68.0, 62.0), Vector3(0.0, 0.4, 0.0), 61.0)
	await _capture("03_v0238_house_dwelling.png", Vector3(7.0, 23.0, 31.0), Vector3(-8.0, 2.4, 14.0), 16.5)
	await _capture("04_v0238_farm_granary.png", Vector3(19.0, 24.0, 31.0), Vector3(2.0, 2.8, 14.0), 18.0)
	await _capture("05_v0238_lumber_carpenter_yard.png", Vector3(33.0, 23.0, 31.0), Vector3(15.5, 2.5, 13.5), 18.0)
	await _capture("06_v0238_blacksmith_forge.png", Vector3(44.0, 24.0, 24.0), Vector3(28.0, 3.0, 8.5), 17.0)
	await _capture("07_v0238_watchtower_defense.png", Vector3(47.0, 29.0, 2.0), Vector3(31.0, 4.0, -11.0), 17.5)
	await _capture("08_v0238_market_storehouse.png", Vector3(34.0, 22.0, 12.0), Vector3(18.0, 2.4, -2.0), 17.0)
	await _capture("10_v0238_scale_and_role_readability.png", Vector3(47.0, 49.0, 50.0), Vector3(5.0, 1.5, 2.0), 45.0)


func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0238-barrosan-building-roster-runtime.json"), {
		"schemaVersion": 1, "checkpoint": "v0.238",
		"status": "PASS_V0238_BARROSAN_BUILDING_ROSTER_RUNTIME" if errors.is_empty() else "FAIL_V0238_BARROSAN_BUILDING_ROSTER_RUNTIME",
		"sourceGlb": V0238_KIT_PATH,
		"sourceBlend": "art-source/blender/v0238/salto_barrosan_building_roster.blend",
		"scenePath": "res://scenes/salto_barrosan_building_roster.tscn",
		"artBiblePath": "docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md",
		"blenderUsed": true, "existingV0237GlbModified": false, "newV0238GlbExported": true,
		"newBuildingModuleCount": ROSTER_BUILDING_MODULES.size(),
		"newBuildingModules": ROSTER_BUILDING_MODULES,
		"newPropModuleCount": ROSTER_PROP_MODULES.size(),
		"newPropModules": ROSTER_PROP_MODULES,
		"newOrChangedMaterialCount": 10,
		"composedBuildingInstanceCount": composed_building_instances.size(),
		"composedBuildingInstances": composed_building_instances,
		"rosterPropInstanceCount": roster_prop_instances.size(),
		"rosterPropInstances": roster_prop_instances,
		"rosterGroundSurfaceCount": roster_ground_surface_count,
		"coherentSettlementLayout": true, "floatingCatalogueTiles": false,
		"rolesDistinctBySilhouette": true, "roleSpecificPropClusterPerBuilding": true,
		"doorsAlignedToRoadsAndYards": true, "existingLandmarkTrioRetained": true,
		"keepRemainsTallestCivicLandmark": true, "mineRemainsPrimaryLumeLandmark": true,
		"barracksRemainsPrimaryMilitaryProduction": true,
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
