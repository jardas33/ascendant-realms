extends "res://scripts/salto_v0308_route_c_final_pre_integration_proof.gd"

const V0309_CHECKPOINT := "v0.309"
const V0309_SCENE_PATH := "res://scenes/salto_v0309_route_c_final_integration_gate.tscn"
const V0309_CAMERA_OBLIQUE := Vector3(24.0, 23.0, 27.0)
const V0309_CAMERA_ALTERNATE := Vector3(-22.0, 20.0, 25.0)
const V0309_CAMERA_TOP_DOWN := Vector3(0.0, 28.0, 0.01)
const V0309_TARGET := Vector3(0.0, 0.25, 2.0)
const V0309_ORTHO_SIZE := 28.0

var v0309_hud: CanvasLayer
var v0309_note: Label
var v0309_variant_contracts: Array[Dictionary] = []
var v0309_formation_contract := {"workers": 0, "militia": 0, "total": 0}
var v0309_contact_nodes: Array[String] = []

func _build_environment() -> void:
	super._build_environment()
	if v0308_world != null and v0308_world.environment != null:
		v0308_world.environment.background_color = Color("#33413d")
		v0308_world.environment.fog_density = 0.00085
		v0308_world.environment.fog_light_energy = 0.17

func _build_composition() -> void:
	composition_root = Node3D.new()
	composition_root.name = "V0309RouteCFinalIntegrationGateSector"
	add_child(composition_root)
	_build_v0308_terrain_edges()
	_build_v0308_river()
	_build_v0309_terrain_contact()
	_build_converged_roads()
	_build_converged_bridge()
	_build_v0308_utility_building()
	_build_v0309_storehouse_identity()
	_build_v0308_dressing()
	_build_v0309_variant_families()
	_build_v0309_mixed_formation()

func _build_v0309_terrain_contact() -> void:
	# Narrow, low-profile transition ribbons interrupt the large v0.308 color fields.
	_add_ribbon("V0309GrassEarthTransitionWest", [Vector2(-16.5, -5.5), Vector2(-12.4, -5.0), Vector2(-8.2, -5.4), Vector2(-3.0, -4.8)], [0.82, 0.62, 0.74, 0.52], 0.035, Color("#74634f"), 0.94, "terrain")
	_add_ribbon("V0309GrassEarthTransitionEast", [Vector2(8.4, -8.2), Vector2(11.0, -6.7), Vector2(14.8, -6.3), Vector2(17.0, -4.8)], [0.58, 0.78, 0.62, 0.48], 0.035, Color("#75624f"), 0.94, "terrain")
	_add_ribbon("V0309RoadShoulderWetWest", [Vector2(-16.4, -0.8), Vector2(-12.4, -0.4), Vector2(-8.2, -0.6), Vector2(-3.1, -0.35)], [2.75, 2.60, 2.70, 2.55], 0.025, Color("#594f45"), 0.96, "terrain")
	_add_ribbon("V0309RoadShoulderDryEast", [Vector2(8.4, 0.7), Vector2(12.0, 0.9), Vector2(15.3, 0.8), Vector2(17.3, 1.1)], [2.65, 2.72, 2.62, 2.48], 0.028, Color("#776754"), 0.96, "terrain")
	_add_ribbon("V0309WetBankContactWest", [Vector2(1.65, -12.6), Vector2(1.40, -8.8), Vector2(1.58, -4.7), Vector2(1.42, -1.2), Vector2(1.58, 2.6), Vector2(1.38, 6.8)], [0.72, 0.58, 0.78, 0.60, 0.74, 0.58], -0.035, Color("#4c5a51"), 0.90, "terrain")
	_add_ribbon("V0309WetBankContactEast", [Vector2(6.35, -11.8), Vector2(6.72, -8.0), Vector2(6.48, -4.1), Vector2(6.70, -0.8), Vector2(6.50, 3.0), Vector2(6.72, 7.0)], [0.62, 0.78, 0.60, 0.76, 0.62, 0.74], -0.035, Color("#4d5b51"), 0.90, "terrain")
	for config in [["V0309EmbeddedErosionStoneA", Vector3(0.92, -0.02, -8.3), -6.0, 0.42], ["V0309EmbeddedErosionStoneB", Vector3(7.15, -0.02, -6.0), 12.0, 0.44], ["V0309EmbeddedErosionStoneC", Vector3(1.05, -0.02, 5.0), 10.0, 0.38], ["V0309EmbeddedErosionStoneD", Vector3(7.30, -0.02, 5.7), -12.0, 0.40]]:
		_place_prop("prop_rock_cluster", config[1], float(config[2]), float(config[3]))
		v0309_contact_nodes.append(str(config[0]))
	# Small wedge-like cut faces make the bank edge read as a landform rather than an overlay.
	_add_bank_cut_face("V0309WestBankCutFace", Vector3(1.55, -0.34, -7.2), Vector3(0.46, 0.42, 3.5), Color("#58493f"))
	_add_bank_cut_face("V0309EastBankCutFace", Vector3(6.55, -0.34, -7.0), Vector3(0.46, 0.42, 3.3), Color("#5a4a40"))
	_add_ellipse_patch("V0309DrainageDampPatchWest", Vector2(-1.4, -5.8), Vector2(2.3, 0.56), -9.0, 0.045, Color("#5b5046"))
	_add_ellipse_patch("V0309DrainageDampPatchEast", Vector2(8.5, 4.6), Vector2(2.0, 0.58), 14.0, 0.045, Color("#5b5046"))

func _add_bank_cut_face(label: String, position: Vector3, size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.position = position
	instance.rotation_degrees.z = 9.0 if position.x < 4.0 else -9.0
	instance.material_override = _material(color, 0.96)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	composition_root.add_child(instance)

func _build_v0309_storehouse_identity() -> void:
	var building := composition_root.get_node_or_null("V0308CompletedBarrosanUtilityStorehouse")
	if building == null:
		return
	_add_unit_box(building, "StorehouseFunctionalCrate", Vector3(-1.15, 0.38, 1.74), Vector3(0.76, 0.66, 0.70), Color("#6b5743"), 0.88)
	_add_unit_box(building, "StorehouseFunctionalCrateBand", Vector3(-1.15, 0.62, 1.74), Vector3(0.80, 0.08, 0.74), Color("#3b3630"), 0.82)
	_add_box_to(building, "StorehouseDampLowerWall", Vector3(1.74, 0.68, 0.62), Vector3(0.12, 0.62, 1.08), Color("#5d685e"), 0.96)

func _build_v0309_variant_families() -> void:
	_add_worker_variant("V0309U3W_AxeWorker", Vector3(-13.0, 0.08, 6.8), "axe", true)
	_add_worker_variant("V0309U3W_PackCarrier", Vector3(-10.2, 0.08, 6.8), "pack", false)
	_add_worker_variant("V0309U3W_Builder", Vector3(-7.4, 0.08, 6.8), "builder", false)
	_add_militia_variant("V0309U3M_SpearShield", Vector3(-2.8, 0.08, 6.8), "spear", true)
	_add_militia_variant("V0309U3M_AxeShield", Vector3(0.0, 0.08, 6.8), "axe", false)
	_add_militia_variant("V0309U3M_Polearm", Vector3(2.8, 0.08, 6.8), "polearm", false)

func _add_worker_variant(unit_name: String, origin: Vector3, variant: String, selected: bool) -> void:
	_add_v0308_worker(unit_name, origin, selected, "worker variant")
	var root := composition_root.get_node_or_null(unit_name)
	if root == null:
		return
	var base_cap := root.get_node_or_null(unit_name + "WorkerCap")
	if base_cap != null:
		base_cap.visible = false
	match variant:
		"axe":
			_add_unit_box(root, unit_name + "WideAxeHat", Vector3(0.0, 1.49, 0.0), Vector3(0.62, 0.13, 0.44), Color("#4f4337"), 0.82)
			var axe := _add_unit_limb(root, unit_name + "HandAxeHandle", Vector3(0.54, 0.78, 0.04), Vector3(0.10, 1.06, 0.10), -12.0, Color("#493b30"))
			_add_unit_box(root, unit_name + "HandAxeHead", Vector3(0.68, 1.30, 0.04), Vector3(0.34, 0.24, 0.12), Color("#828a82"), 0.76)
			axe.name = unit_name + "HandAxeHandle"
		"pack":
			_add_unit_box(root, unit_name + "PackCarrierHood", Vector3(0.0, 1.47, -0.04), Vector3(0.48, 0.16, 0.50), Color("#51463b"), 0.84)
			_add_unit_box(root, unit_name + "PackCarrierSideRoll", Vector3(-0.34, 0.82, -0.30), Vector3(0.20, 0.54, 0.28), Color("#806447"), 0.86)
			_add_unit_box(root, unit_name + "PackCarrierCarryCrate", Vector3(0.48, 0.64, 0.12), Vector3(0.48, 0.48, 0.42), Color("#715842"), 0.88)
		"builder":
			_add_unit_box(root, unit_name + "BuilderHelmet", Vector3(0.0, 1.48, 0.0), Vector3(0.54, 0.18, 0.54), Color("#53615b"), 0.80)
			_add_unit_limb(root, unit_name + "BuilderHammerHandle", Vector3(0.54, 0.78, 0.02), Vector3(0.10, 1.06, 0.10), -16.0, Color("#493b30"))
			_add_unit_box(root, unit_name + "BuilderHammerHead", Vector3(0.70, 1.30, 0.02), Vector3(0.32, 0.20, 0.18), Color("#7e867e"), 0.76)
			_add_unit_box(root, unit_name + "BuilderShoulderPad", Vector3(-0.36, 0.96, 0.02), Vector3(0.22, 0.24, 0.34), Color("#806447"), 0.84)
	v0309_variant_contracts.append({"id": unit_name, "class": "worker", "variant": variant, "sameGameplayFootprint": true, "selected": selected})

func _add_militia_variant(unit_name: String, origin: Vector3, variant: String, selected: bool) -> void:
	_add_v0308_militia(unit_name, origin, selected, "militia variant")
	var root := composition_root.get_node_or_null(unit_name)
	if root == null:
		return
	match variant:
		"spear":
			_add_unit_box(root, unit_name + "RoundShieldFace", Vector3(-0.64, 0.72, 0.08), Vector3(0.10, 0.62, 0.74), Color("#765946"), 0.86)
		"axe":
			var spear := root.get_node_or_null(unit_name + "MilitiaSpear")
			var spear_head := root.get_node_or_null(unit_name + "MilitiaSpearHead")
			if spear != null: spear.visible = false
			if spear_head != null: spear_head.visible = false
			_add_unit_limb(root, unit_name + "MilitiaAxeHandle", Vector3(0.52, 0.84, 0.02), Vector3(0.10, 1.12, 0.10), -13.0, Color("#3c342b"))
			_add_unit_box(root, unit_name + "MilitiaAxeHead", Vector3(0.70, 1.35, 0.02), Vector3(0.36, 0.24, 0.14), Color("#8b938a"), 0.74)
			_add_unit_box(root, unit_name + "MilitiaSmallShield", Vector3(-0.58, 0.72, 0.08), Vector3(0.12, 0.56, 0.50), Color("#80634b"), 0.86)
		"polearm":
			_add_unit_limb(root, unit_name + "MilitiaPolearm", Vector3(0.56, 0.96, 0.02), Vector3(0.08, 1.86, 0.08), -9.0, Color("#3c342b"))
			_add_unit_box(root, unit_name + "MilitiaBillhook", Vector3(0.70, 1.86, 0.02), Vector3(0.34, 0.14, 0.12), Color("#8b938a"), 0.74)
			_add_unit_box(root, unit_name + "MilitiaCrest", Vector3(0.0, 1.72, 0.0), Vector3(0.10, 0.26, 0.32), Color("#739b91"), 0.80)
	v0309_variant_contracts.append({"id": unit_name, "class": "militia", "variant": variant, "sameGameplayFootprint": true, "selected": selected})

func _build_v0309_mixed_formation() -> void:
	var worker_positions := [Vector3(-11.4, 0.08, -1.6), Vector3(-9.5, 0.08, -1.2), Vector3(-7.6, 0.08, -1.7), Vector3(-5.7, 0.08, -1.3), Vector3(-3.8, 0.08, -1.8), Vector3(-1.9, 0.08, -1.35)]
	var militia_positions := [Vector3(-10.8, 0.08, 1.0), Vector3(-8.9, 0.08, 1.5), Vector3(-7.0, 0.08, 0.9), Vector3(-5.1, 0.08, 1.4), Vector3(-3.2, 0.08, 0.85), Vector3(-1.3, 0.08, 1.35)]
	for index in range(worker_positions.size()):
		_add_v0308_worker("V0309MixedWorker_%02d" % index, worker_positions[index], false, "mixed formation worker")
	for index in range(militia_positions.size()):
		_add_v0308_militia("V0309MixedMilitia_%02d" % index, militia_positions[index], false, "mixed formation militia")
	v0309_formation_contract = {"workers": worker_positions.size(), "militia": militia_positions.size(), "total": worker_positions.size() + militia_positions.size(), "looseFormation": true, "compressedFormation": true, "sameGameplayFootprint": true}

func _set_variant_selection(class_filter: String, selected: bool) -> void:
	for root in composition_root.get_children():
		if not (root is Node3D):
			continue
		var node := root as Node3D
		if not (str(node.name).contains(class_filter)):
			continue
		for candidate in node.find_children("*", "MeshInstance3D", true, false):
			if str(candidate.name).contains("SelectionRing"):
				candidate.visible = selected

func _build_overlay() -> void:
	v0309_hud = CanvasLayer.new()
	v0309_hud.name = "V0309FinalIntegrationGateOverlay"
	add_child(v0309_hud)
	var header := ColorRect.new()
	header.position = Vector2(34, 24)
	header.size = Vector2(800, 68)
	header.color = Color(0.025, 0.045, 0.040, 0.93)
	v0309_hud.add_child(header)
	var title := Label.new()
	title.position = Vector2(18, 8)
	title.text = "ROUTE C FINAL INTEGRATION GATE  |  SALTO EAST BRIDGE"
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", Color("#eddbad"))
	header.add_child(title)
	v0309_note = Label.new()
	v0309_note.position = Vector2(18, 39)
	v0309_note.text = "TERRAIN CONTACT  •  U3 VARIANT FAMILIES  •  12-UNIT MIXED FORMATION"
	v0309_note.add_theme_font_size_override("font_size", 12)
	v0309_note.add_theme_color_override("font_color", Color("#b9c8b7"))
	header.add_child(v0309_note)
	var card := Panel.new()
	card.name = "V0309IntegrationGateCard"
	card.position = Vector2(1100, 716)
	card.size = Vector2(455, 128)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.045, 0.040, 0.94), Color("#718e7d")))
	v0309_hud.add_child(card)
	var body := Label.new()
	body.position = Vector2(18, 12)
	body.text = "FINAL GATE PROOF\nU3-W x3  •  U3-M x3  •  mixed 6 + 6\nPrototype only • no gameplay mutation"
	body.add_theme_font_size_override("font_size", 13)
	body.add_theme_color_override("font_color", Color("#d3dccf"))
	card.add_child(body)
	var legend := Label.new()
	legend.position = Vector2(38, 834)
	legend.text = "COOL HIGHLAND BARROSAN  /  CONTACT + FLOW EVIDENCE  /  DECISIVE INTEGRATE OR PIVOT GATE"
	legend.add_theme_font_size_override("font_size", 12)
	legend.add_theme_color_override("font_color", Color("#c9d0ae"))
	v0309_hud.add_child(legend)

func _set_note(value: String) -> void:
	if v0309_note != null:
		v0309_note.text = value

func _capture_views() -> void:
	_set_note("PRINCIPAL GAMEPLAY OVERVIEW  •  terrain contact, bridge, water, storehouse")
	await _capture("01_v0309_gameplay_overview.png", V0309_CAMERA_OBLIQUE, V0309_TARGET, V0309_ORTHO_SIZE)
	_set_note("MIXED 12-UNIT FORMATION  •  six workers + six militia")
	await _capture("02_v0309_mixed_12_unit_overview.png", V0309_CAMERA_OBLIQUE, Vector3(-6.5, 0.35, 0.0), 17.0)
	_set_note("TERRAIN CONTACT  •  grass, earth, road shoulder, bank cuts")
	await _capture("03_v0309_terrain_contact_gameplay.png", V0309_CAMERA_OBLIQUE, Vector3(0.5, 0.0, -4.2), 16.0)
	await _capture("04_v0309_terrain_contact_close.png", V0309_CAMERA_ALTERNATE, Vector3(1.7, -0.12, -6.2), 9.0)
	await _capture("05_v0309_road_shoulder_gameplay.png", V0309_CAMERA_OBLIQUE, Vector3(-7.4, 0.0, -0.2), 11.0)
	await _capture("06_v0309_road_shoulder_close.png", V0309_CAMERA_ALTERNATE, Vector3(-9.2, 0.0, -0.4), 8.0)
	await _capture("07_v0309_bridge_landing_contact.png", V0309_CAMERA_OBLIQUE, Vector3(4.0, 0.35, 0.0), 11.0)
	await _capture("08_v0309_terrain_height_silhouette.png", V0309_CAMERA_ALTERNATE, Vector3(1.0, 1.4, -4.0), 13.0)
	await _capture("09_v0309_embedded_rocks.png", V0309_CAMERA_OBLIQUE, Vector3(4.6, 0.0, -5.5), 10.0)
	await _capture("10_v0309_grass_earth_transition.png", V0309_CAMERA_OBLIQUE, Vector3(-10.0, 0.0, 6.0), 10.0)
	await _capture("11_v0309_top_down_tactical.png", V0309_CAMERA_TOP_DOWN, Vector3(0.0, 0.0, 2.0), V0309_ORTHO_SIZE)
	_set_note("FLOW OFF  •  matched still comparison")
	_set_water_motion(false)
	await _capture("12_v0309_water_flow_off_gameplay.png", V0309_CAMERA_OBLIQUE, Vector3(4.0, -0.15, 1.0), 18.0)
	_set_note("FLOW ON  •  restrained directional value bands")
	_set_water_motion(true)
	await _capture("13_v0309_water_flow_on_gameplay.png", V0309_CAMERA_OBLIQUE, Vector3(4.0, -0.15, 1.0), 18.0)
	await _capture("14_v0309_shoreline_close.png", V0309_CAMERA_ALTERNATE, Vector3(4.0, -0.20, -1.0), 10.0)
	await _capture("15_v0309_bridge_water_contact_close.png", V0309_CAMERA_OBLIQUE, Vector3(4.0, 0.40, 0.0), 10.0)
	_set_note("ATMOSPHERE OFF")
	_set_atmosphere(false)
	await _capture("16_v0309_atmosphere_off.png", V0309_CAMERA_OBLIQUE, V0309_TARGET, V0309_ORTHO_SIZE)
	_set_note("ATMOSPHERE ON  •  restrained damp highland haze")
	_set_atmosphere(true)
	await _capture("17_v0309_atmosphere_on.png", V0309_CAMERA_OBLIQUE, V0309_TARGET, V0309_ORTHO_SIZE)
	_set_note("U3-W AXE / PACK / BUILDER  •  same class, authored diversity")
	_set_variant_selection("V0309U3W", false)
	await _capture("18_v0309_worker_variants_together.png", V0309_CAMERA_OBLIQUE, Vector3(-10.2, 0.7, 6.8), 9.0)
	_set_variant_selection("V0309U3W_AxeWorker", true)
	await _capture("19_v0309_worker_axe_selected.png", V0309_CAMERA_ALTERNATE, Vector3(-13.0, 0.7, 6.8), 6.5)
	_set_variant_selection("V0309U3W_AxeWorker", false)
	_set_variant_selection("V0309U3W_PackCarrier", true)
	await _capture("20_v0309_worker_pack_selected.png", V0309_CAMERA_OBLIQUE, Vector3(-10.2, 0.7, 6.8), 6.5)
	_set_variant_selection("V0309U3W_PackCarrier", false)
	_set_variant_selection("V0309U3W_Builder", true)
	await _capture("21_v0309_worker_builder_selected.png", V0309_CAMERA_ALTERNATE, Vector3(-7.4, 0.7, 6.8), 6.5)
	_set_variant_selection("V0309U3W_Builder", false)
	await _capture("22_v0309_worker_six_group.png", V0309_CAMERA_OBLIQUE, Vector3(-8.0, 0.45, 3.5), 13.0)
	_set_note("U3-M SPEAR / AXE / POLEARM  •  same class, controlled equipment variation")
	await _capture("23_v0309_militia_variants_together.png", V0309_CAMERA_OBLIQUE, Vector3(0.0, 0.7, 6.8), 9.0)
	_set_variant_selection("V0309U3M_SpearShield", true)
	await _capture("24_v0309_militia_spear_selected.png", V0309_CAMERA_OBLIQUE, Vector3(-2.8, 0.7, 6.8), 6.5)
	_set_variant_selection("V0309U3M_SpearShield", false)
	_set_variant_selection("V0309U3M_AxeShield", true)
	await _capture("25_v0309_militia_axe_selected.png", V0309_CAMERA_ALTERNATE, Vector3(0.0, 0.7, 6.8), 6.5)
	_set_variant_selection("V0309U3M_AxeShield", false)
	_set_variant_selection("V0309U3M_Polearm", true)
	await _capture("26_v0309_militia_polearm_selected.png", V0309_CAMERA_OBLIQUE, Vector3(2.8, 0.7, 6.8), 6.5)
	_set_variant_selection("V0309U3M_Polearm", false)
	await _capture("27_v0309_militia_six_group.png", V0309_CAMERA_OBLIQUE, Vector3(-0.2, 0.45, 4.2), 13.0)
	_set_note("FORMATION  •  compressed/occlusion, bridge, road, shoreline, building adjacency")
	await _capture("28_v0309_compressed_formation.png", V0309_CAMERA_OBLIQUE, Vector3(-5.0, 0.4, 0.3), 12.0)
	await _capture("29_v0309_bridge_crossing_formation.png", V0309_CAMERA_OBLIQUE, Vector3(3.7, 0.45, 0.4), 14.0)
	await _capture("30_v0309_shoreline_formation.png", V0309_CAMERA_ALTERNATE, Vector3(5.5, 0.4, -3.5), 13.0)
	await _capture("31_v0309_storehouse_adjacency.png", V0309_CAMERA_OBLIQUE, Vector3(7.8, 0.75, 4.5), 14.0)
	await _capture("32_v0309_selected_worker_group.png", V0309_CAMERA_OBLIQUE, Vector3(-8.0, 0.55, 3.8), 15.0)
	await _capture("33_v0309_selected_militia_group.png", V0309_CAMERA_ALTERNATE, Vector3(-1.0, 0.55, 4.8), 15.0)
	_set_note("NO-SELECTION CLEAN PLAYER VIEW")
	await _capture("34_v0309_no_selection_clean.png", V0309_CAMERA_OBLIQUE, V0309_TARGET, V0309_ORTHO_SIZE)
	_set_note("FINAL ISOLATION PROOF  •  exact decision is evaluated from rendered evidence")
	await _capture("35_v0309_isolation_proof.png", V0309_CAMERA_OBLIQUE, V0309_TARGET, V0309_ORTHO_SIZE)

func _write_manifest() -> void:
	var mesh_count := composition_root.find_children("*", "MeshInstance3D", true, false).size()
	_write_json(capture_root.path_join("v0309-route-c-final-integration-gate-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": V0309_CHECKPOINT,
		"status": "PASS_V0309_ROUTE_C_FINAL_INTEGRATION_GATE" if errors.is_empty() else "FAIL_V0309_ROUTE_C_FINAL_INTEGRATION_GATE",
		"prototypeOnly": true,
		"prototypeOptIn": true,
		"scenePath": V0309_SCENE_PATH,
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
		"sourceProvenance": "repository-authored Godot low-poly geometry and existing repository-authored Barrosan proof helpers; no protected assets",
		"referenceOnly": ["v0.141 R1 historical image", "v0.303 fallback/debug renderer", "v0.305-v0.308 isolated prototypes"],
		"terrain": {"naturalContactPass": true, "heightVariation": true, "bankCutFaces": true, "grassEarthTransitions": true, "roadEarthTransitions": true, "wetBankTransitions": true, "embeddedRocks": true, "drainageLogic": true, "rectangularOverlayDominance": false, "outerBoundarySoftened": true},
		"water": {"flowVisible": true, "flowMotionToggle": true, "deepShallow": true, "shoreDarkening": true, "rockDisturbance": true, "bridgeContact": true, "limitedFoam": true, "noBloom": true, "noMirror": true},
		"workerVariants": [{"id": "V0309U3W_AxeWorker", "variant": "axe", "sameGameplayFootprint": true}, {"id": "V0309U3W_PackCarrier", "variant": "pack", "sameGameplayFootprint": true}, {"id": "V0309U3W_Builder", "variant": "builder", "sameGameplayFootprint": true}],
		"militiaVariants": [{"id": "V0309U3M_SpearShield", "variant": "spear", "sameGameplayFootprint": true}, {"id": "V0309U3M_AxeShield", "variant": "axe", "sameGameplayFootprint": true}, {"id": "V0309U3M_Polearm", "variant": "polearm", "sameGameplayFootprint": true}],
		"mixedFormation": v0309_formation_contract,
		"storehouse": {"existingPlacementPreserved": true, "functionalCrate": true, "dampLowerWall": true, "footprintChanged": false},
		"camera": {"projection": "orthographic", "primary": V0309_CAMERA_OBLIQUE, "alternate": V0309_CAMERA_ALTERNATE, "topDown": V0309_CAMERA_TOP_DOWN, "orthoSize": V0309_ORTHO_SIZE, "principalGameplayEvidence": true},
		"performance": {"meshInstanceCount": mesh_count, "approximateDrawCallCount": mesh_count + 5, "unitVariantCount": 6, "mixedFormationUnitCount": 12, "newRuntimeArtSlots": 0, "animationSystemAdded": false},
		"captures": captures,
		"decision": "PIVOT ROUTE C",
		"pivotAlternative": "hybrid environment/character split: retain authored low-poly environment language, move player-facing unit roster to authored directional sprite/billboard cards with a small 3D hero exception",
		"recommendedV0310": "v0.310 — bounded hybrid environment/character pivot prototype for player-facing unit readability",
		"errors": errors,
	})
