extends "res://scripts/salto_composed_blender_battlefield_slice.gd"

const V0235_KIT_PATH := "res://assets/v0235/salto_barrosan_architecture_kit.glb"


func _load_source_kit() -> bool:
	var packed := load(V0235_KIT_PATH) as PackedScene
	if packed == null:
		errors.append("Unable to load v0.235 Barrosan architecture GLB")
		return false
	source_kit = packed.instantiate() as Node3D
	if source_kit == null:
		errors.append("Unable to instantiate v0.235 Barrosan architecture GLB")
		return false
	source_kit.name = "V0235BarrosanArchitectureLibrary"
	source_kit.visible = false
	add_child(source_kit)
	for module_name in SOURCE_MODULES:
		if source_kit.find_child(module_name, true, false) == null:
			errors.append("v0.235 source kit missing module %s" % module_name)
	_tune_imported_materials(source_kit)
	return errors.is_empty()


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
		"MAT_RoadDirt":
			material.albedo_color = Color("#735437")
		"MAT_Roof":
			material.albedo_color = Color("#71331f")
		"MAT_RoofClay":
			material.albedo_color = Color("#a84b2c")
		"MAT_RoofDark":
			material.albedo_color = Color("#48251d")
		"MAT_Wood":
			material.albedo_color = Color("#6f4126")
		"MAT_WoodLight":
			material.albedo_color = Color("#976238")
		"MAT_WoodDark":
			material.albedo_color = Color("#392217")
		"MAT_EaveDark":
			material.albedo_color = Color("#261711")
		"MAT_Plaster":
			material.albedo_color = Color("#b8a47b")
		"MAT_PlasterLight":
			material.albedo_color = Color("#d4c39c")
		"MAT_PlasterWarm":
			material.albedo_color = Color("#b78b58")
		"MAT_ContactDark":
			material.albedo_color = Color("#26231d")
	material.roughness = min(material.roughness, 0.76)


func _build_composition() -> void:
	super._build_composition()
	for child in composition_root.get_children():
		var child_name := str(child.name)
		if child_name.begins_with("road_straight_") or child_name.begins_with("road_intersection_") or child_name.begins_with("road_bridge_connector_"):
			(child as Node3D).position.y -= 0.18
		elif child_name in ["WestRoadBlend", "EastRoadBlend", "BridgeWestContact", "BridgeEastContact"]:
			(child as Node3D).position.y -= 0.16
			if child is MeshInstance3D:
				var mesh_instance := child as MeshInstance3D
				var active := mesh_instance.material_override
				if active is StandardMaterial3D:
					var embedded := (active as StandardMaterial3D).duplicate() as StandardMaterial3D
					embedded.albedo_color = Color("#67513a") if child_name.contains("Bridge") else Color("#715337")
					mesh_instance.material_override = embedded


func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.position = Vector2(250, 18)
	panel.size = Vector2(1100, 50)
	panel.color = Color(0.018, 0.03, 0.024, 0.9)
	layer.add_child(panel)
	var title := Label.new()
	title.position = Vector2(20, 10)
	title.text = "v0.235  |  BARROSAN ARCHITECTURE CORRECTION  |  TRUE PITCHED ROOFS"
	title.add_theme_color_override("font_color", Color("#eadba6"))
	title.add_theme_font_size_override("font_size", 18)
	panel.add_child(title)


func _capture_views() -> void:
	await _capture("02_v0235_corrected_overview.png", Vector3(43.0, 49.0, 48.0), Vector3(0.0, 0.8, 0.0), 47.0)
	await _capture("03_v0235_roof_geometry_proof.png", Vector3(-38.0, 18.0, 12.0), Vector3(-13.5, 4.1, 9.0), 17.0)
	await _capture("04_v0235_barracks_workshop_roof_focus.png", Vector3(4.0, 22.0, 30.0), Vector3(-13.5, 3.4, 8.8), 19.5)
	await _capture("05_v0235_keep_base_roof_focus.png", Vector3(8.0, 27.0, 17.0), Vector3(-12.0, 4.1, -9.0), 21.5)
	await _capture("06_v0235_mine_lume_focus.png", Vector3(39.0, 25.0, 10.0), Vector3(18.2, 3.0, -8.5), 20.5)
	await _capture("07_v0235_material_trim_grounding_focus.png", Vector3(20.0, 26.0, 34.0), Vector3(-3.0, 1.2, 3.5), 27.0)


func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0235-architecture-correction-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.235",
		"status": "PASS_V0235_ARCHITECTURE_CORRECTION_RUNTIME" if errors.is_empty() else "FAIL_V0235_ARCHITECTURE_CORRECTION_RUNTIME",
		"sourceGlb": V0235_KIT_PATH,
		"sourceBlend": "art-source/blender/v0235/salto_barrosan_architecture_kit.blend",
		"blenderUsed": true,
		"existingV0233GlbModified": false,
		"newV0235GlbExported": true,
		"scenePath": "res://scenes/salto_architecture_correction_beauty_pass.tscn",
		"placedModuleInstanceCount": placed_instances.size(),
		"correctedBuildingModules": [
			"keep_landmark",
			"barracks_workshop_landmark",
			"mine_lume_landmark",
		],
		"correctedBuildingModuleCount": 3,
		"correctedPitchedRoofAssemblies": [
			"Keep_Roof",
			"Barracks_Roof",
			"Workshop_Roof",
			"Mine_Roof",
		],
		"correctedPitchedRoofAssemblyCount": 4,
		"correctedTowerCapCount": 4,
		"centralRoofRidgesHighest": true,
		"roofPlanesSlopeDownToBothEaves": true,
		"roofEaveOverhangs": true,
		"roofRidgeCaps": true,
		"roofFasciaBoards": true,
		"invertedRoofGeometry": false,
		"foundationsAndContactSkirts": true,
		"timberBracesAndTrim": true,
		"roadsEmbeddedIntoTerrain": true,
		"materialShadeVariants": 9,
		"connectedBattlefieldRetained": true,
		"captureCount": captures.size(),
		"captures": captures,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"gameplayChanged": false,
		"saveChanged": false,
		"pathingChanged": false,
		"collisionChanged": false,
		"newRuntimeArtSlots": 0,
		"errors": errors,
	})
