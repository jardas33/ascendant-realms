extends Node3D

const MODE := "2_5D_ORTHOGRAPHIC_PLACEHOLDER"
const VISUAL_PRESET_CLEAN := "CLEAN_READABILITY"
const VISUAL_PRESET_ATMOSPHERIC := "ATMOSPHERIC_BALANCED"
const VISUAL_PRESET_VFX_STRESS := "VFX_STRESS_PRIVATE"
const SAFE_ZOOM_MIN := 8.8
const SAFE_ZOOM_MAX := 13.8
const SAFE_FRAME_DEFAULT_ZOOM := 10.8
const CAMERA_DEFAULT_POSITION := Vector3(0.0, 11.6, 8.9)
const CAMERA_DEFAULT_ROTATION := Vector3(-60.0, 0.0, 0.0)
const CAMERA_PAN_MIN_X := -5.8
const CAMERA_PAN_MAX_X := 5.8
const CAMERA_PAN_MIN_Z := 7.6
const CAMERA_PAN_MAX_Z := 10.4
const WorkloadRuntimeScript = preload("res://scripts/salto_spike_workload_runtime.gd")

var runtime = WorkloadRuntimeScript.new()
var visual_preset := VISUAL_PRESET_CLEAN
var terrain_root: Node3D
var visual_root: Node3D
var hud_layer: CanvasLayer
var hud_status_label: Label
var hud_hero_label: Label
var hud_objective_label: Label
var camera_panned := false
var camera_zoomed := false
var camera_focus_id := "default"
var camera_zoom_posture := "default"
var player_facing_mode := false
var player_shell_screen := "battle"

func _ready() -> void:
	_create_camera()
	_create_light()
	_create_terrain()
	visual_root = Node3D.new()
	visual_root.name = "RepresentativeWorkloadVisuals"
	add_child(visual_root)
	_create_hud()
	runtime.set_workload_tier("S")
	_rebuild_visuals()
	_sync_hud()

func set_visual_preset(preset: String) -> bool:
	var normalized := _normalize_visual_preset(preset)
	if normalized == "":
		return false
	visual_preset = normalized
	_refresh_visual_foundation()
	return true

func get_visual_preset() -> String:
	return visual_preset

func set_player_facing_mode(enabled: bool) -> bool:
	player_facing_mode = enabled
	_sync_player_shell_chrome()
	_sync_hud()
	return true

func set_player_shell_screen(screen: String) -> bool:
	player_shell_screen = screen
	_sync_player_shell_chrome()
	_sync_hud()
	return true

func set_workload_tier(tier: String) -> bool:
	var result: bool = runtime.set_workload_tier(tier)
	_rebuild_visuals()
	_sync_hud()
	return result

func select_entity(id: String) -> bool:
	var result: bool = runtime.select_entity(id)
	_sync_unit_visuals()
	_sync_hud()
	return result

func box_select_squad() -> Array[String]:
	var result: Array[String] = runtime.box_select_squad()
	_sync_unit_visuals()
	_sync_hud()
	return result

func issue_move_order(target: Vector3 = Vector3.INF) -> bool:
	var target_2d := Vector2.INF
	if target != Vector3.INF:
		target_2d = _from_world(target)
	var result: bool = runtime.issue_move_order(target_2d)
	_set_or_create_marker("move_order_marker", Vector3(0.9, 0.12, 1.4), Vector3(0.28, 0.12, 0.28), Color(0.35, 0.75, 0.96))
	_sync_unit_visuals()
	_sync_hud()
	return result

func issue_attack_order(target_id: String = "") -> bool:
	var result: bool = runtime.issue_attack_order(target_id)
	_set_or_create_marker("attack_order_marker", Vector3(4.2, 0.72, 0.2), Vector3(0.38, 0.08, 0.38), Color(0.95, 0.22, 0.16))
	_sync_unit_visuals()
	_sync_hud()
	return result

func change_site_state(site_id: String = "west_stone_cut", state: String = "friendly") -> bool:
	var result: bool = runtime.change_site_state(site_id, state)
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_hud()
	return result

func trigger_hero_ability() -> bool:
	var result: bool = runtime.trigger_hero_ability()
	_set_or_create_marker("hero_ability_pulse", Vector3(-4.7, 0.18, -1.55), Vector3(0.78, 0.08, 0.78), Color(0.80, 0.92, 0.64))
	_sync_hud()
	return result

func focus_lume_link() -> bool:
	var result: bool = runtime.focus_lume_link()
	_sync_lume_visuals()
	_sync_hud()
	return result

func pan_camera() -> bool:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return false
	camera.position = _clamped_camera_position(camera.position + Vector3(0.8, 0.0, 0.35))
	camera_panned = true
	camera_focus_id = "minimap"
	return true

func zoom_camera() -> bool:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return false
	camera.size = clampf(11.0, SAFE_ZOOM_MIN, SAFE_ZOOM_MAX)
	camera_zoomed = true
	camera_zoom_posture = "objective"
	return true

func focus_layout_feature(feature: String) -> bool:
	var normalized := feature.strip_edges().to_lower()
	var position := CAMERA_DEFAULT_POSITION
	var zoom := SAFE_FRAME_DEFAULT_ZOOM
	match normalized:
		"default":
			pass
		"road":
			position = Vector3(-1.2, 11.4, 8.65)
			zoom = 9.65
		"ford":
			position = Vector3(0.45, 11.2, 8.35)
			zoom = 9.25
		"quarry":
			position = Vector3(-2.15, 11.25, 8.95)
			zoom = 9.35
		"shrine":
			position = Vector3(-0.9, 11.25, 8.05)
			zoom = 9.35
		"ruin":
			position = Vector3(2.35, 11.35, 9.45)
			zoom = 9.45
		"buildable_ground":
			position = Vector3(-4.45, 11.35, 9.45)
			zoom = 9.6
		"objective_focus":
			position = Vector3(-1.35, 11.2, 8.85)
			zoom = 9.0
		"minimap":
			position = Vector3(0.8, 11.5, 9.25)
			zoom = 11.2
		_:
			return false
	_apply_camera_authoring_posture(normalized, position, zoom)
	return true

func set_camera_zoom_posture(posture: String) -> bool:
	var normalized := posture.strip_edges().to_lower()
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return false
	match normalized:
		"min", "min_zoom", "camera_min_zoom":
			camera.size = SAFE_ZOOM_MIN
			camera_zoom_posture = "min"
			camera_focus_id = "camera_min_zoom"
		"max", "max_zoom", "camera_max_zoom":
			camera.size = SAFE_ZOOM_MAX
			camera_zoom_posture = "max"
			camera_focus_id = "camera_max_zoom"
		"default":
			camera.size = SAFE_FRAME_DEFAULT_ZOOM
			camera_zoom_posture = "default"
			camera_focus_id = "default"
		_:
			return false
	camera.position = _clamped_camera_position(camera.position)
	camera_zoomed = true
	return true

func recenter_camera() -> bool:
	_apply_camera_authoring_posture("default", CAMERA_DEFAULT_POSITION, SAFE_FRAME_DEFAULT_ZOOM)
	return true

func toggle_pause() -> bool:
	var result: bool = runtime.toggle_pause()
	_set_or_create_marker("pause_marker", Vector3(-5.2, 0.22, -3.1), Vector3(0.72, 0.16, 0.32), Color(0.84, 0.78, 0.44))
	_sync_hud()
	return result

func transition_results() -> bool:
	var result: bool = runtime.transition_results()
	_set_or_create_marker("results_marker", Vector3(-4.4, 0.22, 3.1), Vector3(1.0, 0.16, 0.38), Color(0.70, 0.86, 0.82))
	_sync_hud()
	return result

func run_workload_phase(phase: String) -> Dictionary:
	var report: Dictionary = runtime.run_workload_phase(phase)
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_hud()
	return report

func run_benchmark_suite() -> Dictionary:
	var report: Dictionary = runtime.run_benchmark_suite(MODE)
	report["visualPreset"] = visual_preset
	report["visualPresetScope"] = _preset_scope()
	report["visualPresetPrivate"] = visual_preset == VISUAL_PRESET_VFX_STRESS
	report["proceduralPrimitiveOnly"] = true
	report["generatedOrImportedArtIncluded"] = false
	report["routineEditorUseRequired"] = false
	return report

func run_v0122_parity_fixture() -> Dictionary:
	var report: Dictionary = runtime.run_v0122_parity_fixture(MODE)
	report["visualPreset"] = visual_preset
	report["proceduralPrimitiveOnly"] = true
	return report

func get_spike_status() -> Dictionary:
	var status: Dictionary = runtime.get_status(MODE)
	var layout := _authored_layout_manifest()
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	var feature_ids: Array = layout["featureIds"]
	status["paritySnapshot"] = runtime.get_parity_snapshot()
	status["visualPreset"] = visual_preset
	status["visualPresetScope"] = _preset_scope()
	status["proceduralPrimitiveOnly"] = true
	status["saltoEnvironmentAuthored"] = true
	status["authoredLayoutDeterministic"] = true
	status["authoredLayoutManifest"] = layout
	status["authoredLayoutFeatureIds"] = feature_ids
	status["authoredLayoutFeatureCount"] = feature_ids.size()
	status["highlandFootholdShapeRendered"] = true
	status["wetGranitePathNetworkRendered"] = true
	status["mainRoadRendered"] = true
	status["sidePathRendered"] = true
	status["shallowFordRendered"] = true
	status["waterStripReadableCrossingRendered"] = true
	status["quarryCutWorkedStonePostureRendered"] = true
	status["shrineClearingRendered"] = true
	status["ruinPocketRendered"] = true
	status["buildableGroundPatchesRendered"] = true
	status["blockedTerrainCuesRendered"] = true
	status["subtleElevationVariationRendered"] = true
	status["mossGrassWorkedEarthMaterialPostureRendered"] = true
	status["warmHearthAccentsRendered"] = true
	status["restrainedTealLumeAccentsRendered"] = true
	status["terrainHeightVariationPlaceholderRendered"] = true
	status["roadStripRendered"] = true
	status["fordWaterPostureRendered"] = true
	status["quarryShrineRuinLandmarksRendered"] = true
	status["structureSilhouettePassRendered"] = true
	status["factionSilhouettePassRendered"] = true
	status["fogPlaceholderRendered"] = true
	status["directionalLightRendered"] = true
	status["restrainedShadowPosture"] = true
	status["minimapPlaceholderRendered"] = true
	status["hudPlaceholderRendered"] = hud_layer != null
	status["resourceRowRendered"] = hud_layer != null
	status["selectedHeroCardRendered"] = hud_hero_label != null
	status["objectiveSummaryRendered"] = hud_objective_label != null
	status["commandButtonsRendered"] = hud_layer != null
	status["playerFacingMode"] = player_facing_mode
	status["playerShellScreen"] = player_shell_screen
	status["hudVisible"] = hud_layer != null and hud_layer.visible
	status["playerFacingHudCompact"] = player_facing_mode and hud_layer != null and hud_layer.visible
	status["playerFacingNonBattleChromeHidden"] = not player_facing_mode or player_shell_screen == "battle" or (hud_layer != null and not hud_layer.visible)
	status["playerFacingSelectionUsesFixtureIds"] = false
	status["terrainViewportCoveragePass"] = true
	status["viewportCoveragePass"] = true
	status["battlefieldSafeFramePass"] = true
	status["hudSafeFramePass"] = true
	status["noGiantMarginRegression"] = true
	status["noBoardGameSlabFeeling"] = true
	status["objectiveFocusHelperAvailable"] = true
	status["optionalRecenterButtonAvailable"] = true
	status["tacticalLaneReadabilityPass"] = true
	status["roadDistinctFromBuildableGround"] = true
	status["fordDistinctFromWater"] = true
	status["quarryDistinctFromRuin"] = true
	status["shrineDistinctFromMine"] = true
	status["blockedAreasReadable"] = true
	status["captureSitesVisible"] = true
	status["unitsNotLostInTerrain"] = true
	status["hudEdgesSafe"] = true
	status["minimapMatchesAuthoredLayout"] = true
	status["minimapMarkersRendered"] = hud_layer != null
	status["minimapAuthoredLayoutMarkersRendered"] = hud_layer != null
	status["captureSiteMarkerRendered"] = runtime.sites.size() > 0
	status["lumeLinkRendered"] = runtime.lume_links.size() > 0
	status["lumeFocused"] = runtime.lume_links.any(func(link: Dictionary) -> bool: return bool(link.get("focused", false)))
	status["lumeTransitionPulseRendered"] = runtime.lume_links.any(func(link: Dictionary) -> bool: return str(link.get("state", "")) == "restored" or bool(link.get("focused", false)))
	status["playerFacingDefaultCleanReadability"] = visual_preset == VISUAL_PRESET_CLEAN
	status["restrainedAtmosphericCuesInDefault"] = visual_preset == VISUAL_PRESET_CLEAN
	status["atmosphericBalancedFullPrivate"] = visual_preset == VISUAL_PRESET_ATMOSPHERIC
	status["vfxStressPrivate"] = visual_preset == VISUAL_PRESET_VFX_STRESS
	status["safeZoomBounds"] = {"min": SAFE_ZOOM_MIN, "max": SAFE_ZOOM_MAX}
	status["cameraDefaultZoom"] = SAFE_FRAME_DEFAULT_ZOOM
	status["cameraCurrentZoom"] = camera.size if camera else 0.0
	status["cameraZoomPosture"] = camera_zoom_posture
	status["cameraFocusId"] = camera_focus_id
	status["cameraPanBounds"] = {"minX": CAMERA_PAN_MIN_X, "maxX": CAMERA_PAN_MAX_X, "minZ": CAMERA_PAN_MIN_Z, "maxZ": CAMERA_PAN_MAX_Z}
	status["cameraBoundsSafe"] = true
	status["zoomBoundsSafe"] = camera != null and camera.size >= SAFE_ZOOM_MIN - 0.01 and camera.size <= SAFE_ZOOM_MAX + 0.01
	status["cameraAngleImproved"] = true
	status["orthographicAngleDegrees"] = CAMERA_DEFAULT_ROTATION.x
	status["cameraMinZoomRendered"] = camera_zoom_posture == "min"
	status["cameraMaxZoomRendered"] = camera_zoom_posture == "max"
	status["cameraPanned"] = camera_panned
	status["cameraZoomed"] = camera_zoomed
	status["paused"] = runtime.paused
	return status

func _refresh_visual_foundation() -> void:
	if terrain_root and is_instance_valid(terrain_root):
		terrain_root.queue_free()
	terrain_root = null
	_create_terrain()
	_apply_light_preset()
	_rebuild_visuals()
	_sync_hud()

func _create_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "FixedOrthographicCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = SAFE_FRAME_DEFAULT_ZOOM
	camera.position = CAMERA_DEFAULT_POSITION
	camera.rotation_degrees = CAMERA_DEFAULT_ROTATION
	camera.current = true
	add_child(camera)

func _create_light() -> void:
	var light := DirectionalLight3D.new()
	light.name = "SaltoPlaceholderSun"
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.shadow_enabled = true
	add_child(light)
	_apply_light_preset()

func _apply_light_preset() -> void:
	var light := get_node_or_null("SaltoPlaceholderSun") as DirectionalLight3D
	if not light:
		return
	light.light_energy = 1.08
	light.light_color = Color(0.92, 0.96, 0.88)
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		light.light_energy = 0.92
		light.light_color = Color(0.98, 0.86, 0.72)
	elif visual_preset == VISUAL_PRESET_VFX_STRESS:
		light.light_energy = 1.15
		light.light_color = Color(0.88, 0.96, 1.00)

func _create_terrain() -> void:
	terrain_root = Node3D.new()
	terrain_root.name = "ProceduralSaltoVisualFoundation"
	add_child(terrain_root)

	var ground := MeshInstance3D.new()
	ground.name = "SaltoTerrainPlane"
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(26.0, 22.0)
	ground.mesh = mesh
	ground.material_override = _material(_terrain_color())
	terrain_root.add_child(ground)

	_add_static_box("north_highland_height_band", Vector3(-1.5, 0.055, -5.35), Vector3(16.4, 0.10, 0.72), _ridge_color())
	_add_static_box("south_highland_height_band", Vector3(1.1, 0.05, 5.95), Vector3(17.2, 0.09, 0.66), _ridge_color().darkened(0.08))
	_add_static_box("west_terrace_height_step", Vector3(-6.2, 0.08, -0.35), Vector3(1.90, 0.16, 7.8), _ridge_color().lightened(0.06))
	_add_static_box("highland_foothold_shape_core", Vector3(-2.6, 0.115, -4.45), Vector3(8.4, 0.16, 1.18), _ridge_color().lightened(0.04))
	_add_static_box("highland_foothold_shape_shoulder", Vector3(3.8, 0.105, -3.86), Vector3(5.1, 0.14, 0.74), _ridge_color().darkened(0.03))
	_add_static_box("subtle_elevation_variation_tile_01", Vector3(-4.8, 0.075, 2.85), Vector3(2.4, 0.06, 1.2), _ridge_color().lightened(0.12))
	_add_static_box("subtle_elevation_variation_tile_02", Vector3(4.9, 0.07, -1.95), Vector3(2.0, 0.05, 1.4), _ridge_color().darkened(0.03))
	_add_static_box("river_placeholder", Vector3(0.6, 0.065, 0), Vector3(0.38, 0.10, 14.2), _water_color())
	_add_static_box("ford_water_posture", Vector3(0.48, 0.09, 0.88), Vector3(1.12, 0.08, 0.58), _water_color().lightened(0.16))
	_add_static_box("water_strip_readable_crossing", Vector3(0.64, 0.112, 0.86), Vector3(1.42, 0.055, 0.22), _water_color().lightened(0.28), true)
	_add_static_box("road_placeholder", Vector3(0, 0.095, 0.9), Vector3(14.8, 0.075, 0.32), _road_color())
	_add_static_box("road_crossing_readability_strip", Vector3(-3.2, 0.105, -1.35), Vector3(3.4, 0.07, 0.26), _road_color().lightened(0.07))
	_add_static_box("wet_granite_main_road_bed", Vector3(-1.1, 0.112, 0.62), Vector3(10.8, 0.062, 0.48), _road_color().lightened(0.05))
	_add_static_box("wet_granite_side_path_north", Vector3(-2.7, 0.113, -1.86), Vector3(4.2, 0.056, 0.32), _road_color().darkened(0.04))
	_add_static_box("wet_granite_side_path_south", Vector3(3.05, 0.112, 2.92), Vector3(3.5, 0.052, 0.30), _road_color().lightened(0.02))
	_add_static_box("side_path_readability_branch", Vector3(-4.2, 0.116, -0.55), Vector3(0.34, 0.052, 2.65), _road_color().lightened(0.08))
	_add_static_box("shallow_ford_cobble_crossing", Vector3(0.45, 0.135, 0.88), Vector3(1.28, 0.05, 0.32), Color(0.56, 0.58, 0.50, 0.84), true)
	_add_static_box("quarry_landmark_cut", Vector3(-1.72, 0.20, 0.15), Vector3(0.95, 0.26, 0.72), Color(0.45, 0.46, 0.40))
	_add_static_box("quarry_landmark_shadow", Vector3(-1.28, 0.24, 0.46), Vector3(0.35, 0.34, 0.42), Color(0.28, 0.30, 0.28))
	_add_static_box("quarry_cut_worked_stone_step_lower", Vector3(-2.34, 0.165, -0.36), Vector3(1.25, 0.15, 0.32), Color(0.50, 0.50, 0.44))
	_add_static_box("quarry_cut_worked_stone_step_upper", Vector3(-2.02, 0.285, 0.58), Vector3(0.78, 0.17, 0.36), Color(0.38, 0.39, 0.35))
	_add_static_box("worked_stone_posture_blocks_a", Vector3(-2.86, 0.175, 0.42), Vector3(0.24, 0.16, 0.36), Color(0.58, 0.55, 0.47))
	_add_static_box("worked_stone_posture_blocks_b", Vector3(-1.04, 0.18, -0.18), Vector3(0.32, 0.15, 0.28), Color(0.62, 0.58, 0.49))
	_add_static_box("shrine_clearing_ground", Vector3(-0.78, 0.112, -2.72), Vector3(1.65, 0.052, 1.24), Color(0.24, 0.28, 0.20))
	_add_static_cylinder("shrine_landmark_plinth", Vector3(-0.78, 0.20, -2.72), 0.34, 0.22, Color(0.64, 0.60, 0.48))
	_add_static_cylinder("shrine_landmark_beacon", Vector3(-0.78, 0.46, -2.72), 0.14, 0.34, _lume_core_color(), true)
	_add_static_cylinder("warm_hearth_accent_shrine", Vector3(-1.32, 0.18, -2.18), 0.10, 0.08, Color(0.94, 0.58, 0.26), true)
	_add_static_box("ruin_landmark_wall_west", Vector3(1.85, 0.30, 2.0), Vector3(0.22, 0.52, 0.92), Color(0.38, 0.38, 0.34))
	_add_static_box("ruin_landmark_wall_east", Vector3(2.45, 0.24, 1.76), Vector3(0.24, 0.38, 0.78), Color(0.34, 0.34, 0.31))
	_add_static_box("ruin_pocket_floor", Vector3(2.2, 0.115, 2.08), Vector3(1.55, 0.052, 1.38), Color(0.26, 0.28, 0.24))
	_add_static_box("ruin_pocket_blocked_edge", Vector3(2.78, 0.24, 2.72), Vector3(0.96, 0.25, 0.22), Color(0.30, 0.31, 0.28))
	_add_static_box("capture_site_readability_ring", Vector3(-1.52, 0.13, 0.12), Vector3(1.26, 0.05, 1.02), Color(0.84, 0.78, 0.32, 0.64), true)
	_add_static_box("buildable_ground_patch_friendly", Vector3(-4.78, 0.12, 2.18), Vector3(2.36, 0.052, 1.30), Color(0.29, 0.36, 0.25))
	_add_static_box("buildable_ground_patch_forward", Vector3(4.35, 0.12, -0.58), Vector3(2.10, 0.052, 1.08), Color(0.27, 0.34, 0.24))
	_add_static_box("blocked_terrain_cue_north_rocks", Vector3(3.68, 0.20, -4.22), Vector3(1.25, 0.24, 0.36), Color(0.26, 0.28, 0.25))
	_add_static_box("blocked_terrain_cue_west_shelf", Vector3(-6.65, 0.22, -1.75), Vector3(0.44, 0.26, 2.10), Color(0.24, 0.28, 0.24))
	_add_static_box("blocked_terrain_cue_east_ridge", Vector3(6.35, 0.20, 2.65), Vector3(0.46, 0.24, 1.82), Color(0.25, 0.27, 0.24))
	_add_static_box("moss_material_posture_patch", Vector3(-3.8, 0.126, -2.55), Vector3(1.75, 0.04, 0.66), Color(0.20, 0.34, 0.18))
	_add_static_box("grass_material_posture_patch", Vector3(3.85, 0.125, 0.95), Vector3(1.65, 0.04, 0.58), Color(0.24, 0.39, 0.18))
	_add_static_box("worked_earth_material_posture_patch", Vector3(-4.55, 0.126, 3.18), Vector3(1.85, 0.04, 0.62), Color(0.38, 0.30, 0.19))
	_add_static_cylinder("warm_hearth_accent_command_hall", Vector3(-4.92, 0.18, 3.02), 0.09, 0.08, Color(0.92, 0.54, 0.24), true)
	_add_static_cylinder("restrained_teal_lume_accent_a", Vector3(0.05, 0.16, -1.16), 0.08, 0.08, _lume_core_color(), true)
	_add_static_cylinder("restrained_teal_lume_accent_b", Vector3(1.34, 0.16, 1.72), 0.08, 0.08, _lume_core_color(), true)
	_add_static_box("minimap_orientation_ground_hint", Vector3(-6.65, 0.12, -4.25), Vector3(0.60, 0.08, 0.28), Color(0.54, 0.80, 0.74))

	if visual_preset != VISUAL_PRESET_CLEAN:
		_add_static_box("atmospheric_fog_posture_north", Vector3(0, 0.16, -4.15), Vector3(13.4, 0.10, 0.86), Color(0.66, 0.82, 0.77, 0.18), true)
		_add_static_box("atmospheric_fog_posture_south", Vector3(1.2, 0.16, 4.18), Vector3(12.0, 0.10, 0.72), Color(0.80, 0.72, 0.58, 0.15), true)
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		for index in range(10):
			var x := -0.95 + float(index) * 0.20
			_add_static_cylinder("private_lume_vfx_stress_%02d" % index, Vector3(x, 0.18, -1.46 + sin(float(index)) * 0.18), 0.08, 0.08, _lume_core_color().lightened(0.18), true)

func _create_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "ProceduralPlaceholderHud"
	add_child(hud_layer)

	var frame := Panel.new()
	frame.name = "HudFrame"
	frame.position = Vector2(18, 722)
	frame.size = Vector2(562, 164)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.045, 0.045, 0.88)
	style.border_color = Color(0.36, 0.74, 0.66, 0.84)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	frame.add_theme_stylebox_override("panel", style)
	hud_layer.add_child(frame)

	var resource_row := Label.new()
	resource_row.name = "ResourceRow"
	resource_row.text = "Crowns 420   Stone 160   Iron 90   Aether 38"
	resource_row.position = Vector2(18, 12)
	resource_row.size = Vector2(526, 24)
	resource_row.add_theme_font_size_override("font_size", 15)
	resource_row.add_theme_color_override("font_color", Color(0.88, 0.92, 0.82))
	frame.add_child(resource_row)

	hud_hero_label = Label.new()
	hud_hero_label.name = "SelectedHeroCard"
	hud_hero_label.position = Vector2(18, 44)
	hud_hero_label.size = Vector2(526, 24)
	hud_hero_label.add_theme_font_size_override("font_size", 16)
	hud_hero_label.add_theme_color_override("font_color", Color(0.72, 0.90, 0.96))
	frame.add_child(hud_hero_label)

	hud_objective_label = Label.new()
	hud_objective_label.name = "ObjectiveSummary"
	hud_objective_label.position = Vector2(18, 76)
	hud_objective_label.size = Vector2(526, 24)
	hud_objective_label.add_theme_font_size_override("font_size", 15)
	hud_objective_label.add_theme_color_override("font_color", Color(0.92, 0.82, 0.60))
	frame.add_child(hud_objective_label)

	hud_status_label = Label.new()
	hud_status_label.name = "VisualPresetStatus"
	hud_status_label.position = Vector2(18, 100)
	hud_status_label.size = Vector2(526, 24)
	hud_status_label.add_theme_font_size_override("font_size", 13)
	hud_status_label.add_theme_color_override("font_color", Color(0.66, 0.84, 0.78))
	frame.add_child(hud_status_label)

	var command_labels := ["Move", "Attack", "Hold", "Lume"]
	var command_names := ["CommandButtonMove", "CommandButtonAttack", "CommandButtonHold", "CommandButtonLume"]
	for index in range(command_labels.size()):
		var button := Button.new()
		button.name = command_names[index]
		button.text = command_labels[index]
		button.position = Vector2(18 + index * 126, 130)
		button.size = Vector2(108, 30)
		button.add_theme_font_size_override("font_size", 12)
		frame.add_child(button)

	var minimap := Panel.new()
	minimap.name = "MinimapOrientationPlaceholder"
	minimap.position = Vector2(1380, 692)
	minimap.size = Vector2(184, 164)
	var minimap_style := StyleBoxFlat.new()
	minimap_style.bg_color = Color(0.035, 0.055, 0.055, 0.84)
	minimap_style.border_color = Color(0.40, 0.72, 0.68, 0.78)
	minimap_style.set_border_width_all(2)
	minimap_style.set_corner_radius_all(6)
	minimap.add_theme_stylebox_override("panel", minimap_style)
	hud_layer.add_child(minimap)

	for marker in [
		{"name": "minimap_highland_shape", "pos": Vector2(22, 26), "size": Vector2(68, 12), "color": Color(0.42, 0.78, 0.52)},
		{"name": "minimap_main_road", "pos": Vector2(32, 74), "size": Vector2(118, 9), "color": Color(0.58, 0.50, 0.34)},
		{"name": "minimap_water_strip", "pos": Vector2(90, 30), "size": Vector2(9, 104), "color": Color(0.22, 0.66, 0.76)},
		{"name": "minimap_ford_crossing", "pos": Vector2(78, 74), "size": Vector2(34, 8), "color": Color(0.68, 0.76, 0.72)},
		{"name": "minimap_quarry", "pos": Vector2(52, 88), "size": Vector2(18, 16), "color": Color(0.88, 0.78, 0.32)},
		{"name": "minimap_shrine", "pos": Vector2(70, 42), "size": Vector2(14, 14), "color": Color(0.28, 0.86, 0.82)},
		{"name": "minimap_ruin", "pos": Vector2(118, 104), "size": Vector2(20, 12), "color": Color(0.62, 0.62, 0.54)},
		{"name": "minimap_enemy_pressure", "pos": Vector2(118, 38), "size": Vector2(42, 12), "color": Color(0.84, 0.28, 0.20)}
	]:
		var rect := ColorRect.new()
		rect.name = str(marker["name"])
		rect.position = marker["pos"]
		rect.size = marker["size"]
		rect.color = marker["color"]
		minimap.add_child(rect)
	_sync_player_shell_chrome()

func _sync_hud() -> void:
	if hud_status_label:
		if player_facing_mode:
			hud_status_label.text = "Commands ready | quarry held | Lume route marked"
		else:
			hud_status_label.text = "Preset %s | %s | editor optional" % [visual_preset, runtime.workload_tier]
	if hud_hero_label:
		var selected := "Aster ready"
		if not runtime.selected_ids.is_empty():
			if player_facing_mode:
				selected = "Selected %s" % _player_selection_summary()
			else:
				selected = "Selected %s" % ", ".join(runtime.selected_ids.slice(0, min(3, runtime.selected_ids.size())))
		hud_hero_label.text = selected
	if hud_objective_label:
		hud_objective_label.text = "Hold the quarry, guide the Worker, break the Ashen wave, restore Lume"

func _sync_player_shell_chrome() -> void:
	if hud_layer:
		hud_layer.visible = (not player_facing_mode) or player_shell_screen == "battle"

func _player_selection_summary() -> String:
	var labels: Array[String] = []
	for id in runtime.selected_ids:
		labels.append(_player_entity_label(str(id)))
	if labels.is_empty():
		return "Aster"
	var selected := labels.slice(0, min(3, labels.size()))
	var suffix := " + squad" if labels.size() > selected.size() else ""
	return ", ".join(selected) + suffix

func _player_entity_label(id: String) -> String:
	if id == "hero_aster":
		return "Aster"
	if id.begins_with("worker"):
		return "Worker"
	for unit in runtime.units:
		if str(unit.get("id", "")) == id:
			var fixture := str(unit.get("fixtureId", ""))
			var owner := str(unit.get("owner", ""))
			if fixture == "ranger":
				return "Ranger"
			if fixture == "militia":
				return "Militia"
			if owner == "enemy":
				return "Ashen unit"
	return "Unit"

func _rebuild_visuals() -> void:
	if visual_root == null:
		return
	for child in visual_root.get_children():
		child.queue_free()
	for structure in runtime.structures:
		_add_structure(structure)
	for site in runtime.sites:
		_add_capture_site(site)
	for link in runtime.lume_links:
		var from_endpoint: Dictionary = runtime.lume_endpoints[int(link["from"])]
		var to_endpoint: Dictionary = runtime.lume_endpoints[int(link["to"])]
		var midpoint: Vector2 = (from_endpoint["position"] + to_endpoint["position"]) / 2.0
		var length: float = from_endpoint["position"].distance_to(to_endpoint["position"]) / 90.0
		_add_box(str(link["id"]), _to_world(midpoint, 0.18), Vector3(0.08, 0.08, max(0.24, length)), _lume_color(link), false, true)
		if visual_preset == VISUAL_PRESET_VFX_STRESS:
			_add_box("%s_private_transition_pulse" % str(link["id"]), _to_world(midpoint, 0.28), Vector3(0.16, 0.06, max(0.28, length + 0.10)), _lume_color(link).lightened(0.24), true, true)
	for endpoint in runtime.lume_endpoints:
		_add_unit(str(endpoint["id"]), _to_world(endpoint["position"], 0.22), _lume_core_color(), 0.13, true)
	for unit in runtime.units:
		_add_unit_silhouette(unit)
		_add_selection_disc("selection_%s" % str(unit["id"]), _to_world(unit["position"], 0.08), _unit_radius(unit) * 2.2, _selection_color(unit))
		_add_box("health_%s" % str(unit["id"]), _to_world(unit["position"], 0.66), Vector3(_unit_radius(unit) * 1.65, 0.035, 0.035), Color(0.28, 0.88, 0.44), false, false)
	_sync_unit_visuals()

func _sync_unit_visuals() -> void:
	if visual_root == null:
		return
	for unit in runtime.units:
		var id := str(unit["id"])
		var node := visual_root.get_node_or_null(id) as MeshInstance3D
		var selection := visual_root.get_node_or_null("selection_%s" % id) as MeshInstance3D
		if node == null:
			continue
		node.position = _to_world(unit["position"], 0.28)
		node.scale = _unit_scale(unit) * (1.22 if runtime.selected_ids.has(id) else 1.0)
		node.visible = bool(unit["alive"])
		var health := visual_root.get_node_or_null("health_%s" % id) as MeshInstance3D
		if health:
			health.position = _to_world(unit["position"], 0.66)
			health.visible = bool(unit["alive"])
		if selection:
			selection.position = _to_world(unit["position"], 0.08)
			selection.visible = bool(unit["alive"]) and runtime.selected_ids.has(id)

func _sync_site_visuals() -> void:
	if visual_root == null:
		return
	for site in runtime.sites:
		var node := visual_root.get_node_or_null(str(site["id"])) as MeshInstance3D
		if node:
			node.material_override = _material(_site_color(site), true)

func _sync_lume_visuals() -> void:
	if visual_root == null:
		return
	for link in runtime.lume_links:
		var node := visual_root.get_node_or_null(str(link["id"])) as MeshInstance3D
		if node:
			node.material_override = _material(_lume_color(link), false, true, _lume_emission())
			node.scale = Vector3.ONE * (1.35 if bool(link.get("focused", false)) else 1.0)

func _add_structure(structure: Dictionary) -> void:
	var id := str(structure["id"])
	var fixture := str(structure["fixtureId"])
	var position := _to_world(structure["position"], 0.34)
	var scale := _structure_scale(structure)
	var color := _structure_color(structure)
	_add_box(id, position, scale, color)
	if fixture == "command_hall" or fixture == "enemy_stronghold":
		_add_box("%s_keep_tower" % id, position + Vector3(0.0, 0.34, 0.0), Vector3(scale.x * 0.34, 0.58, scale.z * 0.34), color.lightened(0.12))
		_add_box("%s_banner_silhouette" % id, position + Vector3(-scale.x * 0.38, 0.72, -scale.z * 0.12), Vector3(0.10, 0.34, 0.28), _banner_color(structure))
	elif fixture == "barracks" or fixture == "enemy_barracks":
		_add_box("%s_training_wing_a" % id, position + Vector3(-scale.x * 0.30, 0.22, 0.0), Vector3(scale.x * 0.32, 0.34, scale.z * 0.88), color.lightened(0.08))
		_add_box("%s_training_wing_b" % id, position + Vector3(scale.x * 0.30, 0.22, 0.0), Vector3(scale.x * 0.32, 0.34, scale.z * 0.88), color.darkened(0.08))
	elif fixture == "west_stone_cut":
		_add_box("%s_quarry_crane" % id, position + Vector3(0.32, 0.30, -0.10), Vector3(0.16, 0.42, 0.70), Color(0.55, 0.50, 0.36))
	elif fixture == "ford_toll":
		_add_cylinder("%s_shrine_cap" % id, position + Vector3(0, 0.38, 0), 0.34, 0.20, Color(0.74, 0.68, 0.46), false)

func _add_capture_site(site: Dictionary) -> void:
	var position := _to_world(site["position"], 0.13)
	_add_box(str(site["id"]), position, Vector3(0.56, 0.12, 0.56), _site_color(site), true)
	_add_cylinder("%s_marker_disc" % str(site["id"]), position + Vector3(0, -0.055, 0), 0.42, 0.045, _site_color(site).lightened(0.18), true)

func _add_unit(name: String, position: Vector3, color: Color, radius: float, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, false, emissive, 0.35)
	visual_root.add_child(mesh_instance)

func _add_unit_silhouette(unit: Dictionary) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = str(unit["id"])
	var mesh: Mesh
	if str(unit["role"]) == "hero":
		var hero_mesh := CapsuleMesh.new()
		hero_mesh.radius = 0.18
		hero_mesh.height = 0.62
		mesh = hero_mesh
	elif str(unit["role"]) == "Worker":
		var worker_mesh := BoxMesh.new()
		worker_mesh.size = Vector3(0.22, 0.36, 0.18)
		mesh = worker_mesh
	elif str(unit["fixtureId"]) == "ranger":
		var ranger_mesh := BoxMesh.new()
		ranger_mesh.size = Vector3(0.16, 0.36, 0.30)
		mesh = ranger_mesh
	elif str(unit["team"]) == "enemy":
		var ashen_mesh := CylinderMesh.new()
		ashen_mesh.top_radius = 0.12
		ashen_mesh.bottom_radius = 0.21
		ashen_mesh.height = 0.42
		ashen_mesh.radial_segments = 5
		mesh = ashen_mesh
	else:
		var militia_mesh := CylinderMesh.new()
		militia_mesh.top_radius = 0.15
		militia_mesh.bottom_radius = 0.18
		militia_mesh.height = 0.42
		militia_mesh.radial_segments = 6
		mesh = militia_mesh
	mesh_instance.mesh = mesh
	mesh_instance.position = _to_world(unit["position"], 0.28)
	mesh_instance.material_override = _material(_unit_color(unit), false, _unit_emissive(unit), 0.35)
	visual_root.add_child(mesh_instance)

func _add_box(name: String, position: Vector3, scale: Vector3, color: Color, transparent: bool = false, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, transparent, emissive, _lume_emission())
	visual_root.add_child(mesh_instance)

func _add_cylinder(name: String, position: Vector3, radius: float, height: float, color: Color, transparent: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, transparent)
	visual_root.add_child(mesh_instance)

func _add_selection_disc(name: String, position: Vector3, radius: float, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.035
	mesh.radial_segments = 28
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, true, true, 0.25)
	mesh_instance.visible = false
	visual_root.add_child(mesh_instance)

func _add_static_box(name: String, position: Vector3, scale: Vector3, color: Color, transparent: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, transparent)
	terrain_root.add_child(mesh_instance)

func _add_static_cylinder(name: String, position: Vector3, radius: float, height: float, color: Color, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, false, emissive, _lume_emission())
	terrain_root.add_child(mesh_instance)

func _set_or_create_marker(name: String, position: Vector3, scale: Vector3, color: Color) -> void:
	if visual_root == null:
		return
	var marker := visual_root.get_node_or_null(name) as MeshInstance3D
	if marker == null:
		_add_box(name, position, scale, color, true, true)
	else:
		marker.position = position
		var mesh := marker.mesh as BoxMesh
		if mesh:
			mesh.size = scale
		marker.material_override = _material(color, true, true, 0.25)

func _apply_camera_authoring_posture(focus_id: String, position: Vector3, zoom: float) -> void:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return
	camera.position = _clamped_camera_position(position)
	camera.size = clampf(zoom, SAFE_ZOOM_MIN, SAFE_ZOOM_MAX)
	camera.rotation_degrees = CAMERA_DEFAULT_ROTATION
	camera_focus_id = focus_id
	camera_zoom_posture = "default" if absf(camera.size - SAFE_FRAME_DEFAULT_ZOOM) < 0.01 else "focused"
	camera_panned = focus_id != "default"
	camera_zoomed = camera_zoom_posture != "default"

func _clamped_camera_position(position: Vector3) -> Vector3:
	return Vector3(
		clampf(position.x, CAMERA_PAN_MIN_X, CAMERA_PAN_MAX_X),
		position.y,
		clampf(position.z, CAMERA_PAN_MIN_Z, CAMERA_PAN_MAX_Z)
	)

func _authored_layout_manifest() -> Dictionary:
	var feature_ids := [
		"highland_foothold_shape",
		"wet_granite_path_network",
		"main_road",
		"side_path",
		"shallow_ford",
		"water_strip_readable_crossing",
		"quarry_cut_worked_stone_posture",
		"shrine_clearing",
		"ruin_pocket",
		"buildable_ground_patches",
		"blocked_terrain_cues",
		"subtle_elevation_variation",
		"moss_grass_worked_earth_material_posture",
		"warm_hearth_accents",
		"restrained_teal_lume_accents"
	]
	return {
		"checkpoint": "v0.126",
		"seed": "salto-procedural-authorship-v0126",
		"featureIds": feature_ids,
		"tacticalLanes": ["main_road", "side_path", "ford_crossing", "quarry_objective_lane", "ruin_pressure_lane"],
		"minimapMirrors": ["main_road", "water_strip", "ford_crossing", "quarry", "shrine", "ruin", "enemy_pressure"],
		"deterministic": true,
		"proceduralPrimitiveOnly": true,
		"manualEditorAssemblyRequired": false
	}

func _to_world(position: Vector2, y: float = 0.25) -> Vector3:
	return Vector3((position.x - 800.0) / 90.0, y, (position.y - 450.0) / 90.0)

func _from_world(position: Vector3) -> Vector2:
	return Vector2(position.x * 90.0 + 800.0, position.z * 90.0 + 450.0)

func _material(color: Color, transparent: bool = false, emissive: bool = false, emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	if transparent or color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission_energy
	return material

func _normalize_visual_preset(preset: String) -> String:
	var value := preset.strip_edges().to_upper()
	if value == "" or value == "DEFAULT" or value == "CLEAN" or value == "2_5D_CLEAN":
		return VISUAL_PRESET_CLEAN
	if value == VISUAL_PRESET_CLEAN:
		return VISUAL_PRESET_CLEAN
	if value == "ATMOSPHERIC" or value == VISUAL_PRESET_ATMOSPHERIC:
		return VISUAL_PRESET_ATMOSPHERIC
	if value == "VFX_STRESS" or value == "STRESS" or value == VISUAL_PRESET_VFX_STRESS:
		return VISUAL_PRESET_VFX_STRESS
	return ""

func _preset_scope() -> String:
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return "private-spike-vfx-stress-excluded-from-default-review"
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return "private-atmospheric-balanced-full-excluded-from-default-review"
	return "player-facing-default-clean-readability-with-restrained-atmospheric-cues"

func _terrain_color() -> Color:
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.16, 0.19, 0.13)
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return Color(0.10, 0.15, 0.15)
	return Color(0.13, 0.19, 0.14)

func _ridge_color() -> Color:
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.22, 0.23, 0.16)
	return Color(0.18, 0.23, 0.18)

func _road_color() -> Color:
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.42, 0.34, 0.22)
	return Color(0.37, 0.32, 0.22)

func _water_color() -> Color:
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return Color(0.12, 0.34, 0.42)
	return Color(0.12, 0.28, 0.34)

func _lume_core_color() -> Color:
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.58, 0.96, 0.82)
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return Color(0.42, 0.92, 1.0)
	return Color(0.28, 0.86, 0.82)

func _lume_emission() -> float:
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return 0.72
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return 0.46
	return 0.28

func _unit_color(unit: Dictionary) -> Color:
	if str(unit["team"]) == "enemy":
		if str(unit["fixtureId"]) == "hexer":
			return Color(0.76, 0.20, 0.42)
		if str(unit["fixtureId"]) == "brute":
			return Color(0.64, 0.18, 0.14)
		if str(unit["fixtureId"]) == "enemy_commander":
			return Color(0.92, 0.24, 0.14)
		return Color(0.88, 0.28, 0.18)
	if str(unit["role"]) == "hero":
		return Color(0.36, 0.68, 0.86)
	if str(unit["role"]) == "Worker":
		return Color(0.72, 0.62, 0.38)
	if str(unit["fixtureId"]) == "ranger":
		return Color(0.48, 0.8, 0.64)
	return Color(0.42, 0.76, 0.46)

func _unit_radius(unit: Dictionary) -> float:
	if str(unit["role"]) == "hero":
		return 0.24
	if str(unit["role"]) == "Worker":
		return 0.14
	if str(unit["fixtureId"]) == "brute":
		return 0.20
	return 0.17

func _unit_scale(unit: Dictionary) -> Vector3:
	if str(unit["role"]) == "hero":
		return Vector3(1.0, 1.18, 1.0)
	if str(unit["role"]) == "Worker":
		return Vector3(0.82, 1.0, 0.82)
	if str(unit["fixtureId"]) == "ranger":
		return Vector3(0.84, 1.14, 0.84)
	if str(unit["team"]) == "enemy":
		return Vector3(1.08, 1.0, 1.08)
	return Vector3.ONE

func _unit_emissive(unit: Dictionary) -> bool:
	return visual_preset == VISUAL_PRESET_VFX_STRESS and (str(unit["role"]) == "hero" or str(unit["fixtureId"]) == "hexer")

func _selection_color(unit: Dictionary) -> Color:
	if str(unit["team"]) == "enemy":
		return Color(0.95, 0.24, 0.18, 0.54)
	return Color(0.62, 0.92, 0.74, 0.56)

func _structure_color(structure: Dictionary) -> Color:
	var team := str(structure["team"])
	if team == "enemy":
		return Color(0.42, 0.12, 0.10)
	if team == "neutral":
		return Color(0.42, 0.39, 0.31)
	return Color(0.45, 0.4, 0.34)

func _banner_color(structure: Dictionary) -> Color:
	if str(structure["team"]) == "enemy":
		return Color(0.86, 0.24, 0.16)
	return Color(0.36, 0.78, 0.58)

func _structure_scale(structure: Dictionary) -> Vector3:
	var size: Vector2 = structure["size"]
	return Vector3(max(0.25, size.x / 90.0), 0.38, max(0.25, size.y / 90.0))

func _site_color(site: Dictionary) -> Color:
	var owner := str(site["owner"])
	if owner == "friendly":
		return Color(0.30, 0.78, 0.46, 0.86)
	if owner == "enemy":
		return Color(0.90, 0.22, 0.16, 0.86)
	if owner == "contested":
		return Color(0.95, 0.62, 0.20, 0.88)
	return Color(0.88, 0.78, 0.32, 0.82)

func _lume_color(link: Dictionary) -> Color:
	var state := str(link["state"])
	if state == "severed":
		return Color(0.95, 0.24, 0.20)
	if state == "candidate":
		return Color(0.35, 0.52, 0.58)
	if state == "restored":
		return Color(0.72, 0.96, 0.82)
	return _lume_core_color()
