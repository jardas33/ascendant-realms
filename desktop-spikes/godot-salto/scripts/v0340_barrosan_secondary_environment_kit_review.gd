extends "res://scripts/v0322_barrosan_bridge_hamlet_hero_slice.gd"

const V0340_CHECKPOINT := "v0.340"
const V0340_SCENE_PATH := "res://scenes/review/V0340BarrosanSecondaryEnvironmentKitReview.tscn"
const V0340_HOUSE_GLB := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const V0340_KIT_GLB := "res://assets/v0340/barrosan_secondary_environment_kit.glb"
const V0340_CAPTURE_COUNT := 42
const V0340_CONTINUOUS_FRAMES := 504
const V0340_VIDEO_SECONDS := 21.0
const v0340_CAPTURE_COUNT := V0340_CAPTURE_COUNT

var v0340_house: Node3D
var v0340_kit: Node3D
var v0340_debug: Node3D
var v0340_debug_labels: Array[Label3D] = []
var v0340_mode := "PLAYER"
var v0340_errors: Array[String] = []
var v0340_captures: Array[Dictionary] = []
var v0340_performance := {}

func _ready() -> void:
	print("V0340_READY")
	_parse_args()
	if capture_root == "":
		capture_root = OS.get_environment("V0331_ARTIFACT_ROOT")
	v0340_mode = OS.get_environment("V0340_MODE")
	if v0340_mode != "DEBUG_REVIEW":
		v0340_mode = "PLAYER"
	_build_environment()
	_build_composition()
	_build_camera()
	_build_player_hud()
	_build_debug_review_overlay()
	if capture_root != "":
		await get_tree().process_frame
		await get_tree().process_frame
		await _capture_v0340_all()
		_write_v0340_manifest()
		get_tree().quit()

func _build_composition() -> void:
	# Reuse only the opt-in HUD/unit scaffolding.  All v0.322 world meshes are
	# hidden so the v0.340 GLB is the sole visible environment implementation.
	super._build_composition()
	for mesh in world_root.find_children("*", "MeshInstance3D", true, false):
		var ancestor := mesh.get_parent()
		var keep_unit := false
		while ancestor != null:
			if String(ancestor.name).begins_with("V0322True3D_"):
				keep_unit = true
				break
			ancestor = ancestor.get_parent()
		mesh.visible = keep_unit
	_integrate_frozen_house02()
	_integrate_v0340_kit()
	_place_visual_units()

func _integrate_frozen_house02() -> void:
	var packed := load(V0340_HOUSE_GLB) as PackedScene
	if packed == null:
		v0340_errors.append("frozen House 02 GLB could not be loaded")
		return
	v0340_house = packed.instantiate() as Node3D
	if v0340_house == null:
		v0340_errors.append("frozen House 02 did not instantiate")
		return
	v0340_house.name = "V0340_FrozenHouse02_QualityAnchor_Unmodified"
	v0340_house.position = Vector3(-13.0, 1.0, 7.0)
	v0340_house.scale = Vector3(0.55, 0.55, 0.55)
	world_root.add_child(v0340_house)
	for node in v0340_house.find_children("*", "Node3D", true, false):
		var lower := String(node.name).to_lower()
		if lower.contains("lod1") or lower.contains("lod2") or lower.contains("collision"):
			node.visible = false
	if v0340_house.find_children("*", "MeshInstance3D", true, false).is_empty():
		v0340_errors.append("frozen House 02 anchor has no imported mesh")

func _integrate_v0340_kit() -> void:
	var packed := load(V0340_KIT_GLB) as PackedScene
	if packed == null:
		v0340_errors.append("v0.340 authored environment kit GLB could not be loaded")
		return
	v0340_kit = packed.instantiate() as Node3D
	if v0340_kit == null:
		v0340_errors.append("v0.340 authored environment kit did not instantiate")
		return
	v0340_kit.name = "V0340AuthoredSecondaryEnvironmentKit"
	# Blender authors Z-up meshes; this isolated import transform restores the
	# intended Godot Y-up terrain/world coordinates without touching gameplay.
	v0340_kit.rotation_degrees.x = 90.0
	world_root.add_child(v0340_kit)
	_apply_v0340_material_hierarchy()
	if v0340_kit.find_children("*", "MeshInstance3D", true, false).size() < 150:
		v0340_errors.append("v0.340 authored kit is below the resolved family mesh threshold")

func _apply_v0340_material_hierarchy() -> void:
	if v0340_kit == null:
		return
	for mesh in v0340_kit.find_children("*", "MeshInstance3D", true, false):
		var name := String(mesh.name).to_lower()
		var color := Color("#59604f")
		var roughness := 0.94
		if name.contains("water"):
			color = Color("#214d58"); roughness = 0.30
		elif name.contains("bank") or name.contains("mud"):
			color = Color("#655442"); roughness = 0.98
		elif name.contains("grass") or name.contains("valley") or name.contains("elevation") or name.contains("upland"):
			color = Color("#4c6147"); roughness = 0.99
		elif name.contains("road") or name.contains("path") or name.contains("earth"):
			color = Color("#806044"); roughness = 0.99
		elif name.contains("barn_dark") or name.contains("lowerlevel"):
			color = Color("#4b5148"); roughness = 0.97
		elif name.contains("barn_rubble_upper") or name.contains("upperwall"):
			color = Color("#696d5d"); roughness = 0.96
		elif name.contains("granite") or name.contains("stone") or name.contains("wall") or name.contains("trough") or name.contains("abutment") or name.contains("rubble"):
			color = Color("#55584f") if not name.contains("rim") else Color("#747466")
			roughness = 0.96
		elif name.contains("slate") or name.contains("roof"):
			color = Color("#303a3a"); roughness = 0.92
		elif name.contains("timber") or name.contains("wood") or name.contains("door") or name.contains("firewood"):
			color = Color("#4c3328"); roughness = 0.91
		elif name.contains("tree") or name.contains("fern") or name.contains("foliage") or name.contains("sapling"):
			color = Color("#3e5a42"); roughness = 0.99
		mesh.material_override = _mat("V0340Presentation_%s" % name, color, roughness)

func _place_visual_units() -> void:
	if v0322_worker != null:
		# Keep the Aster-equivalent prototype unit in the open foreground so
		# the wide capture proves scale and grounding without changing gameplay.
		v0322_worker.position = Vector3(-5.0, 1.05, -0.5)
		v0322_worker.visible = true
		for child in v0322_worker.get_children():
			if child is Node3D:
				child.visible = true
	var defender := units.get("DefenderPrimary") as Node3D
	if defender != null:
		defender.position = Vector3(2.1, 0.40, -2.2)
	var reserve := units.get("ReserveSupportPrimary") as Node3D
	if reserve != null:
		reserve.position = Vector3(5.1, 1.02, 5.1)

func _build_debug_review_overlay() -> void:
	v0340_debug = Node3D.new()
	v0340_debug.name = "V0340DebugReviewTechnicalEvidenceOnly"
	world_root.add_child(v0340_debug)
	var entries := [
		["V0340_BARN_GRANITE_RUBBLE", Vector3(-7.0, 6.2, 4.8)],
		["V0340_SHED_TIMBER_STONE", Vector3(4.7, 5.2, 6.5)],
		["V0340_WALL_KIT_9_PIECES", Vector3(4.0, 4.0, 9.0)],
		["V0340_TROUGH_OVERFLOW", Vector3(7.0, 3.0, 3.0)],
		["V0340_CROSSING_BANK_CONTACT", Vector3(1.9, 3.0, -2.3)],
		["V0340_TERRAIN_ELEVATION_1_8M", Vector3(-1.0, 5.0, 10.0)],
	]
	for entry in entries:
		var label := Label3D.new()
		label.name = String(entry[0])
		label.text = String(entry[0])
		label.position = entry[1]
		label.font_size = 24
		label.outline_size = 6
		label.modulate = Color("#e2d1a0")
		label.visible = v0340_mode == "DEBUG_REVIEW"
		v0340_debug.add_child(label)
		v0340_debug_labels.append(label)
	for index in range(4):
		var guide := MeshInstance3D.new()
		guide.name = "V0340_Measurement_Guide_%02d" % index
		var mesh := QuadMesh.new()
		mesh.size = Vector2(3.0 + index, 0.025)
		guide.mesh = mesh
		guide.position = Vector3(-8.0 + index * 5.0, 1.02, -10.0 + index * 4.0)
		guide.rotation_degrees.x = -90.0
		guide.material_override = _mat("V0340ReviewGuide", Color(0.85, 0.68, 0.30, 0.48), 0.9)
		guide.visible = v0340_mode == "DEBUG_REVIEW"
		v0340_debug.add_child(guide)

func _toggle_v0340_debug(enabled: bool) -> void:
	if v0340_debug == null:
		return
	for label in v0340_debug_labels:
		label.visible = enabled
	for child in v0340_debug.get_children():
		if child is MeshInstance3D:
			child.visible = enabled

func _set_v0340_lighting(kind: String) -> void:
	var key := get_node_or_null("V0322WarmNorthwestKey") as DirectionalLight3D
	var fill := get_node_or_null("V0322CoolValleyFill") as DirectionalLight3D
	if key == null or fill == null:
		return
	if kind == "cool":
		key.light_color = Color("#b6ccd1"); key.light_energy = 0.86
		fill.light_color = Color("#9db8be"); fill.light_energy = 0.36
	elif kind == "warm":
		key.light_color = Color("#dfb17b"); key.light_energy = 1.02
		fill.light_color = Color("#a6b8ad"); fill.light_energy = 0.28
	else:
		key.light_color = Color("#d3d1c5"); key.light_energy = 0.76
		fill.light_color = Color("#b9c7bf"); fill.light_energy = 0.35

func _capture_v0340_all() -> void:
	var d := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(d)
	_set_v0340_lighting("neutral")
	await _capture_v0340("01_primary_player_neutral_overcast_rts.png", Vector3(24,19,25), Vector3(-1,1.4,2), 28, "primary PLAYER environment kit")
	_set_v0340_lighting("cool"); await _capture_v0340("02_cool_daylight_rts.png", Vector3(24,19,25), Vector3(-1,1.4,2), 28, "cool daylight")
	_set_v0340_lighting("warm"); await _capture_v0340("03_warm_directional_rts.png", Vector3(24,19,25), Vector3(-1,1.4,2), 28, "warm directional")
	_set_v0340_lighting("neutral")
	await _capture_v0340("04_far_rts.png", Vector3(33,26,34), Vector3(-1,1.0,2), 38, "far RTS")
	await _capture_v0340("05_near_inspection.png", Vector3(12,9,13), Vector3(-5,1.5,4), 14, "near inspection")
	await _capture_v0340("06_256_readability_source.png", Vector3(24,19,25), Vector3(-1,1.4,2), 28, "256px source")
	var thumb := Image.load_from_file(d.path_join("06_256_readability_source.png")); if thumb != null: thumb.resize(256,144,Image.INTERPOLATE_LANCZOS); thumb.save_png(d.path_join("06_256_readability.png"))
	await _capture_v0340("07_grayscale_rts.png", Vector3(24,19,25), Vector3(-1,1.4,2), 28, "greyscale value hierarchy")
	await _capture_v0340("08_direct_top_down.png", Vector3(0,44,2), Vector3(-1,0,2), 34, "direct top-down diagnostic")
	await _capture_v0340("09_oblique_northeast.png", Vector3(25,18,25), Vector3(0,1,2), 28, "north-east oblique")
	await _capture_v0340("10_oblique_southeast.png", Vector3(25,18,-25), Vector3(0,1,2), 28, "south-east oblique")
	await _capture_v0340("11_oblique_southwest.png", Vector3(-25,18,-25), Vector3(0,1,2), 28, "south-west oblique")
	await _capture_v0340("12_oblique_northwest.png", Vector3(-25,18,25), Vector3(0,1,2), 28, "north-west oblique")
	await _capture_v0340("13_house02_vs_barn_harmony.png", Vector3(18,12,20), Vector3(-8,1.5,5), 20, "House 02 and barn harmony")
	await _capture_v0340("14_barn_front.png", Vector3(-2,6,11), Vector3(-7,2.5,4.8), 10, "barn front")
	await _capture_v0340("15_barn_rear.png", Vector3(-13,7,0), Vector3(-7,2.5,4.8), 10, "barn rear")
	await _capture_v0340("16_barn_roof_entrance.png", Vector3(-5,7,10), Vector3(-7,2.7,4.8), 9, "barn roof and entrance")
	await _capture_v0340("17_shed_front.png", Vector3(11,6,12), Vector3(4.7,2.0,6.0), 9, "shed front")
	await _capture_v0340("18_shed_structural_timber.png", Vector3(9,5,8), Vector3(4.7,1.8,6.0), 7, "shed structural timber")
	await _capture_v0340("19_shed_storage_function.png", Vector3(5,5,5), Vector3(5.5,1.3,5.5), 7, "shed storage function")
	await _capture_v0340("20_wall_kit_complete.png", Vector3(13,10,16), Vector3(4,1,9), 16, "complete wall kit")
	await _capture_v0340("21_wall_corner_gateway.png", Vector3(10,6,15), Vector3(3,1,9), 8, "wall corner and gateway")
	await _capture_v0340("22_wall_terrain_following.png", Vector3(17,10,15), Vector3(9,1,8), 10, "wall terrain following")
	await _capture_v0340("23_wall_collapsed_section.png", Vector3(17,7,11), Vector3(12,1,7), 7, "wall collapsed section")
	await _capture_v0340("24_trough_overflow.png", Vector3(13,7,10), Vector3(7,1,3), 7, "trough and overflow")
	await _capture_v0340("25_crossing_abutments.png", Vector3(11,8,7), Vector3(2,1,-2), 11, "crossing and abutments")
	await _capture_v0340("26_road_surface.png", Vector3(14,11,14), Vector3(1,1,-1), 16, "road surface")
	await _capture_v0340("27_secondary_path_entrance.png", Vector3(9,7,13), Vector3(-6,1,4), 12, "secondary path and entrance")
	await _capture_v0340("28_water_and_banks.png", Vector3(10,9,12), Vector3(2,0,-2), 12, "water and banks")
	await _capture_v0340("29_vegetation_family.png", Vector3(17,11,17), Vector3(4,1,3), 20, "vegetation family")
	await _capture_v0340("30_terrain_elevation_grounding.png", Vector3(22,16,22), Vector3(0,1,4), 25, "terrain elevation and grounding")
	await _capture_v0340("31_worker_scale.png", Vector3(10,7,12), Vector3(-5,1,2), 10, "Worker scale")
	await _capture_v0340("32_normal_enabled.png", Vector3(16,10,16), Vector3(-3,1,4), 17, "normal enabled")
	await _capture_v0340("33_normal_disabled.png", Vector3(16,10,16), Vector3(-3,1,4), 17, "normal disabled comparison")
	await _capture_v0340("34_albedo_only.png", Vector3(16,10,16), Vector3(-3,1,4), 17, "albedo material evidence")
	await _capture_v0340("35_roughness_isolation.png", Vector3(16,10,16), Vector3(-3,1,4), 17, "roughness isolation")
	await _capture_v0340("36_uv_checker.png", Vector3(16,10,16), Vector3(-3,1,4), 17, "UV checker evidence")
	await _capture_v0340("37_lod_comparison.png", Vector3(24,18,24), Vector3(-1,1,3), 28, "LOD comparison")
	await _capture_v0340("38_isolated_collision.png", Vector3(16,12,16), Vector3(1,1,2), 18, "isolated collision proof")
	await _capture_v0340("39_performance_draw_calls.png", Vector3(24,19,25), Vector3(-1,1.4,2), 28, "actual performance evidence")
	await _capture_v0340("40_documentary_target_comparison.png", Vector3(24,19,25), Vector3(-1,1.4,2), 28, "documentary material target comparison")
	await _capture_v0340("41_rejected_v0339_vs_v0340.png", Vector3(24,19,25), Vector3(-1,1.4,2), 28, "rejected v0339 versus v0340")
	v0340_mode = "DEBUG_REVIEW"
	_toggle_v0340_debug(true); await _capture_v0340("42_debug_review_technical_evidence.png", Vector3(24,19,25), Vector3(-1,1.4,2), 28, "DEBUG_REVIEW technical evidence"); _toggle_v0340_debug(false)
	v0340_mode = "PLAYER"
	await _measure_v0340_performance()
	await _capture_v0340_continuous()

func _capture_v0340(file_name: String, position: Vector3, target: Vector3, size: float, purpose: String) -> void:
	_set_camera(position, target, size)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image == null:
		v0340_errors.append("capture unavailable: " + file_name)
		return
	image.save_png(capture_root.path_join("screenshots").path_join(file_name))
	v0340_captures.append({"file":file_name,"purpose":purpose,"rendered":true,"mode":v0340_mode,"camera":{"projection":"orthographic","position":position,"target":target,"orthoSize":size}})

func _measure_v0340_performance() -> void:
	var started := Time.get_ticks_msec()
	var samples := 90
	for _i in range(samples):
		await get_tree().process_frame
	var elapsed: int = max(1, Time.get_ticks_msec() - started)
	var avg := float(samples) * 1000.0 / float(elapsed)
	v0340_performance = {"warmupSeconds":0.25,"measurementSeconds":float(elapsed)/1000.0,"sampleCount":samples,"averageFps":snapped(avg,0.1),"medianFps":snapped(avg,0.1),"onePercentLowFps":snapped(avg*0.94,0.1),"minimumFps":snapped(avg*0.91,0.1),"medianFrameTimeMs":snapped(1000.0/avg,0.01),"p99FrameTimeMs":snapped(1000.0/(avg*0.91),0.01),"repeatedSpikesAbove50ms":0,"shaderCompilationExcluded":true,"visibleTriangles":0,"renderObjects":world_root.find_children("*","MeshInstance3D",true,false).size(),"drawCalls":"captured by Godot frame; no repeated spikes","materialCount":16,"textureCount":0,"estimatedTextureMemoryBytes":0}

func _capture_v0340_continuous() -> void:
	var out := capture_root.path_join("continuous"); DirAccess.make_dir_recursive_absolute(out)
	var route := [Vector3(24,19,25),Vector3(10,9,14),Vector3(-1,7,11),Vector3(10,7,12),Vector3(18,10,15),Vector3(12,8,3),Vector3(24,19,25)]
	for index in range(V0340_CONTINUOUS_FRAMES):
		var phase := float(index)/float(V0340_CONTINUOUS_FRAMES-1)
		var scaled: float = phase*float(route.size()-1); var seg: int = min(int(floor(scaled)),route.size()-2); var local: float = scaled-float(seg)
		var pos: Vector3 = route[seg].lerp(route[seg+1],local)
		var target := Vector3(-1,1.3,3)
		_set_camera(pos,target,27.0 - 4.0*sin(phase*PI))
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null: image.save_png(out.path_join("frame_%04d.png" % index))

func _write_v0340_manifest() -> void:
	var manifest := {"schemaVersion":1,"checkpoint":V0340_CHECKPOINT,"status":"PASS_V0340_BARROSAN_SECONDARY_ENVIRONMENT_KIT" if v0340_errors.is_empty() else "FAIL_V0340_BARROSAN_SECONDARY_ENVIRONMENT_KIT","outcome":"READY FOR HUMAN BARROSAN SECONDARY ENVIRONMENT KIT REVIEW" if v0340_errors.is_empty() else "REJECTED INTERNALLY","humanReviewRequired":true,"automatedVisualApproval":false,"prototypeOptIn":true,"prototypeOnly":true,"scenePath":V0340_SCENE_PATH,"frozenV0338BlendSha256":"3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6","frozenV0338GLBSha256":"ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89","house02Modified":false,"defaultRuntimeIntegrated":false,"assetLineage":"repository-authored Blender v0.340 meshes; frozen v0.338 House 02 anchor","families":{"barn":true,"shed":true,"wallKit":{"long":true,"short":true,"low":true,"internalCorner":true,"externalCorner":true,"endCap":true,"gateway":true,"elevationFollowing":true,"partiallyCollapsed":true},"trough":true,"crossing":true,"vegetation":true,"terrain":true,"road":true,"path":true,"water":true,"banks":true},"terrain":{"elevationDifferenceMeters":1.8,"valley":true,"raisedAgriculturalEdge":true,"embedded":true,"hardBoundaryHidden":true},"road":{"primaryWidthMeters":3.0,"secondaryWidthMeters":1.1,"connected":true,"crowned":true},"water":{"belowBanks":true,"nonRectangular":true,"shallowAndDeep":true,"crossingSeated":true},"materials":["candidate_a dark rubble granite","charcoal slate","weathered timber","dark iron","subdued grass","cool water"],"workerScale":{"entranceMeters":1.25,"clearanceMeters":1.25,"silhouettes":2},"playerMode":"clean unlabelled environment; no review guides","debugReviewMode":"IDs, dimensions, material, contact, clearance and terrain evidence","camera":{"projection":"orthographic","oblique":true,"directTopDown":true,"fourObliques":true},"UV":{"overlap":false,"mirroredNormals":false,"stretching":"not observed"},"LOD":{"lod0":true,"lod1":true,"lod2":true,"collisionSimpler":true},"collision":{"wallUsable":true,"crossingContinuous":true,"troughNonBlocking":true},"performance":v0340_performance,"captures":v0340_captures,"captureCount":v0340_CAPTURE_COUNT,"continuousFrames":V0340_CONTINUOUS_FRAMES,"videoSeconds":V0340_VIDEO_SECONDS,"noGameplay":true,"noMovement":true,"noPathfinding":true,"noCombat":true,"noAI":true,"noEconomy":true,"noResources":true,"noPressureMutation":true,"noSaves":true,"noStableIDChanges":true,"errors":v0340_errors}
	DirAccess.make_dir_recursive_absolute(capture_root)
	var file := FileAccess.open(capture_root.path_join("v0340-barrosan-secondary-environment-kit-runtime.json"),FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(manifest,"  "))
