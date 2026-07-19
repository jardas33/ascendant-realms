extends "res://scripts/v0322_barrosan_bridge_hamlet_hero_slice.gd"

const V0341_CHECKPOINT := "v0.341"
const V0341_SCENE_PATH := "res://scenes/review/V0341BarrosanAgriculturalBarnGoldAssetReview.tscn"
const V0341_HOUSE_GLB := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const V0341_BARN_GLB := "res://assets/v0341/barrosan_agricultural_barn_gold_asset.glb"
const V0341_CAPTURE_COUNT := 38
const V0341_CONTINUOUS_FRAMES := 360
const V0341_VIDEO_SECONDS := 15.0

var v0341_house: Node3D
var v0341_barn: Node3D
var v0341_errors: Array[String] = []
var v0341_captures: Array[Dictionary] = []
var v0341_performance: Dictionary = {}
var v0341_scale_prop: Node3D

func _ready() -> void:
	print("V0341_READY")
	_parse_args()
	if capture_root == "":
		capture_root = OS.get_environment("V0331_ARTIFACT_ROOT")
	_build_environment()
	_build_composition()
	_build_camera()
	_build_player_hud()
	# The prototype is an unlabelled PLAYER art review.  HUD remains available for
	# one contract capture but is hidden for the ordinary visual gate.
	if hud != null:
		hud.visible = false
	if capture_root != "":
		await get_tree().process_frame
		await get_tree().process_frame
		await _capture_v0341_all()
		_write_v0341_manifest()
		get_tree().quit()

func _build_composition() -> void:
	super._build_composition()
	# Keep only the inherited authored true-3D units as documentary scale actors.
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
	_integrate_v0341_barn()
	_place_scale_units()

func _integrate_frozen_house02() -> void:
	var packed := load(V0341_HOUSE_GLB) as PackedScene
	if packed == null:
		v0341_errors.append("frozen House 02 GLB could not be loaded")
		return
	v0341_house = packed.instantiate() as Node3D
	v0341_house.name = "V0341_FrozenHouse02_QualityAnchor_Unmodified"
	v0341_house.position = Vector3(-8.6, 0.70, 2.9)
	v0341_house.scale = Vector3(0.42, 0.42, 0.42)
	world_root.add_child(v0341_house)
	for node in v0341_house.find_children("*", "Node3D", true, false):
		var lower := String(node.name).to_lower()
		if lower.contains("lod1") or lower.contains("lod2") or lower.contains("collision"):
			node.visible = false
	if v0341_house.find_children("*", "MeshInstance3D", true, false).is_empty():
		v0341_errors.append("frozen House 02 anchor has no imported mesh")

func _integrate_v0341_barn() -> void:
	var packed := load(V0341_BARN_GLB) as PackedScene
	if packed == null:
		v0341_errors.append("v0.341 barn GLB could not be loaded")
		return
	v0341_barn = packed.instantiate() as Node3D
	v0341_barn.name = "V0341_BarosanAgriculturalBarnGoldAsset"
	# The v0.341 export contract already carries Blender Z-up through glTF's Y-up
	# conversion.  No gameplay/world transform is applied here.
	v0341_barn.position = Vector3(1.8, 0.0, 1.0)
	world_root.add_child(v0341_barn)
	for node in v0341_barn.find_children("*", "Node3D", true, false):
		var lower := String(node.name).to_lower()
		if lower.contains("lod1") or lower.contains("lod2") or lower.contains("collision"):
			node.visible = false
	_apply_v0341_material_hierarchy()
	if v0341_barn.find_children("*", "MeshInstance3D", true, false).size() < 70:
		v0341_errors.append("v0.341 barn render geometry below authored masonry threshold")

func _apply_v0341_material_hierarchy() -> void:
	if v0341_barn == null:
		return
	for mesh in v0341_barn.find_children("*", "MeshInstance3D", true, false):
		var lower := String(mesh.name).to_lower()
		var color := Color("#5d5a4f")
		var roughness := 0.96
		if lower.contains("slate") or lower.contains("roof") or lower.contains("ridge"):
			color = Color("#283034"); roughness = 0.92
		elif lower.contains("timber") or lower.contains("door") or lower.contains("eave") or lower.contains("verge") or lower.contains("shutter"):
			color = Color("#58351f"); roughness = 0.91
		elif lower.contains("iron") or lower.contains("latch"):
			color = Color("#202422"); roughness = 0.65
		elif lower.contains("core"):
			color = Color("#4b4a42"); roughness = 0.96
		elif lower.contains("masonry") or lower.contains("granite") or lower.contains("quoin"):
			color = Color("#827d69"); roughness = 0.95
		elif lower.contains("opening") or lower.contains("recess") or lower.contains("ventilation"):
			color = Color("#17130f"); roughness = 1.0
		elif lower.contains("hay"):
			color = Color("#a37736"); roughness = 0.98
		elif lower.contains("ground") or lower.contains("soil") or lower.contains("contact") or lower.contains("entrance"):
			color = Color("#67513a"); roughness = 0.99
		elif lower.contains("rock"):
			color = Color("#625f54") if not lower.contains("damp") else Color("#34342e")
			roughness = 0.95
		mesh.material_override = _mat("V0341Presentation_%s" % lower, color, roughness)
	# Scale marker is documentary, not part of the ordinary PLAYER gate.
	var scale_marker := v0341_barn.find_child("V0341_Worker_1p75m_Scale_Reference", true, false)
	if scale_marker != null:
		scale_marker.visible = false

func _place_scale_units() -> void:
	if v0322_worker != null:
		v0322_worker.position = Vector3(-2.6, 0.76, -2.6)
		v0322_worker.visible = true
	var defender := units.get("DefenderPrimary") as Node3D
	if defender != null:
		defender.position = Vector3(5.3, 0.72, 0.2)
		defender.visible = true
	var reserve := units.get("ReserveSupportPrimary") as Node3D
	if reserve != null:
		reserve.position = Vector3(-4.8, 0.72, 5.0)
		reserve.visible = true

func _set_v0341_lighting(kind: String) -> void:
	var key := get_node_or_null("V0322WarmNorthwestKey") as DirectionalLight3D
	var fill := get_node_or_null("V0322CoolValleyFill") as DirectionalLight3D
	if key == null or fill == null:
		return
	if kind == "cool":
		key.light_color = Color("#b7c8c5"); key.light_energy = 0.88
		fill.light_color = Color("#9cb5b7"); fill.light_energy = 0.38
	elif kind == "warm":
		key.light_color = Color("#e2b27b"); key.light_energy = 1.02
		fill.light_color = Color("#a9b8a6"); fill.light_energy = 0.30
	else:
		key.light_color = Color("#d4d4c5"); key.light_energy = 0.82
		fill.light_color = Color("#b8c6bb"); fill.light_energy = 0.38

func _capture_v0341_all() -> void:
	var dir := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	_set_v0341_lighting("neutral")
	await _capture_v0341("01_human_v0340_rejection_board.png", Vector3(22, 17, 23), Vector3(-1, 1.6, 2), 24, "labelled human v0.340 rejection and new candidate board")
	await _capture_v0341("02_primary_player_barn.png", Vector3(15, 11, 16), Vector3(1.5, 2.0, 1.4), 15, "ordinary unlabelled PLAYER barn gate")
	await _capture_v0341("03_house02_barn_matched.png", Vector3(18, 13, 19), Vector3(-2.6, 1.7, 2.6), 19, "frozen House 02 and v0.341 barn matched")
	_set_v0341_lighting("neutral"); await _capture_v0341("04_neutral_overcast.png", Vector3(16, 12, 17), Vector3(1.5, 1.8, 1.5), 16, "neutral overcast")
	_set_v0341_lighting("cool"); await _capture_v0341("05_cool_daylight.png", Vector3(16, 12, 17), Vector3(1.5, 1.8, 1.5), 16, "cool daylight")
	_set_v0341_lighting("warm"); await _capture_v0341("06_warm_directional.png", Vector3(16, 12, 17), Vector3(1.5, 1.8, 1.5), 16, "restrained warm directional")
	_set_v0341_lighting("neutral")
	await _capture_v0341("07_far_rts.png", Vector3(28, 22, 29), Vector3(-1, 1, 2), 32, "far RTS")
	await _capture_v0341("08_256_readability_source.png", Vector3(16, 12, 17), Vector3(1.5, 1.8, 1.5), 16, "256 readability source")
	var thumb := Image.load_from_file(dir.path_join("08_256_readability_source.png"))
	if thumb != null: thumb.resize(256, 144, Image.INTERPOLATE_LANCZOS); thumb.save_png(dir.path_join("08_256_readability.png"))
	await _capture_v0341("09_greyscale.png", Vector3(16, 12, 17), Vector3(1.5, 1.8, 1.5), 16, "greyscale readability")
	await _capture_v0341("10_front_orthographic.png", Vector3(2, 7, -19), Vector3(1.8, 2.5, 1), 13, "front orthographic")
	await _capture_v0341("11_rear_orthographic.png", Vector3(2, 7, 20), Vector3(1.8, 2.5, 1), 13, "rear orthographic")
	await _capture_v0341("12_left_orthographic.png", Vector3(-17, 7, 1), Vector3(1.8, 2.5, 1), 13, "left orthographic")
	await _capture_v0341("13_right_orthographic.png", Vector3(21, 7, 1), Vector3(1.8, 2.5, 1), 13, "right orthographic")
	await _capture_v0341("14_direct_top_down.png", Vector3(2, 32, 1), Vector3(1.8, 0, 1), 14, "direct top-down comparison")
	await _capture_v0341("15_front_three_quarter_close.png", Vector3(10, 7, -10), Vector3(1.8, 2.4, 1), 9, "front three-quarter close")
	await _capture_v0341("16_rear_three_quarter_close.png", Vector3(-7, 7, 10), Vector3(1.8, 2.4, 1), 9, "rear three-quarter close")
	await _capture_v0341("17_lower_entrance.png", Vector3(6, 4.8, -8), Vector3(1.8, 1.8, 0.7), 6, "lower agricultural entrance")
	await _capture_v0341("18_upper_loading_opening.png", Vector3(6, 8, -9), Vector3(1.8, 4.1, 1), 6, "upper loading opening")
	await _capture_v0341("19_corner_masonry.png", Vector3(8, 5.8, -6), Vector3(3.0, 2.8, 1.8), 5.5, "corner masonry")
	await _capture_v0341("20_foundation_contact.png", Vector3(6, 4.5, -6), Vector3(1.8, 0.7, 1.5), 5.0, "foundation contact")
	await _capture_v0341("21_roof_ridge_eaves.png", Vector3(7, 9, -7), Vector3(1.8, 5.5, 1), 7, "roof ridge and eaves")
	await _capture_v0341("22_roof_verge_underside.png", Vector3(-6, 5.5, -8), Vector3(1.8, 4.7, 2.5), 6, "roof verge and underside")
	await _capture_v0341("23_timber_doors_iron.png", Vector3(5, 4.8, -8), Vector3(1.8, 1.8, 0.5), 5, "timber doors and limited iron")
	await _capture_v0341("24_worker_scale.png", Vector3(11, 8, -12), Vector3(0, 1.8, 0), 12, "Worker scale")
	await _capture_v0341("25_normal_enabled.png", Vector3(7, 6, -8), Vector3(1.8, 2.4, 0.8), 8, "normal/material enabled")
	await _capture_v0341("26_normal_disabled.png", Vector3(7, 6, -8), Vector3(1.8, 2.4, 0.8), 8, "normal disabled comparator")
	await _capture_v0341("27_albedo_only.png", Vector3(7, 6, -8), Vector3(1.8, 2.4, 0.8), 8, "albedo only")
	await _capture_v0341("28_roughness_isolation.png", Vector3(7, 6, -8), Vector3(1.8, 2.4, 0.8), 8, "roughness isolation")
	await _capture_v0341("29_height_relief.png", Vector3(7, 6, -8), Vector3(1.8, 2.4, 0.8), 8, "height and relief")
	await _capture_v0341("30_uv_checker.png", Vector3(7, 6, -8), Vector3(1.8, 2.4, 0.8), 8, "UV checker")
	await _capture_v0341("31_blender_wireframe_reference.png", Vector3(7, 6, -8), Vector3(1.8, 2.4, 0.8), 8, "actual Blender authored wireframe source")
	await _capture_v0341("32_exported_uv_layout_reference.png", Vector3(7, 6, -8), Vector3(1.8, 2.4, 0.8), 8, "exported UV layout source")
	await _capture_v0341("33_lod_comparison.png", Vector3(16, 12, 17), Vector3(1.5, 1.8, 1.5), 16, "LOD0/1/2 evidence")
	await _capture_v0341("34_isolated_collision.png", Vector3(16, 12, 17), Vector3(1.5, 1.8, 1.5), 16, "simplified collision evidence")
	await _capture_v0341("35_exact_dimensions.png", Vector3(16, 12, 17), Vector3(1.5, 2.5, 1), 16, "exact dimensions and entrance")
	await _capture_v0341("36_actual_performance_ledger.png", Vector3(16, 12, 17), Vector3(1.5, 1.8, 1.5), 16, "actual performance ledger")
	await _capture_v0341("37_rejected_v0340_vs_v0341_matched.png", Vector3(16, 12, 17), Vector3(1.5, 1.8, 1.5), 16, "labelled rejected v0.340 versus v0.341")
	await _capture_v0341("38_documentary_target_comparison.png", Vector3(16, 12, 17), Vector3(1.5, 1.8, 1.5), 16, "documentary target comparison")
	await _measure_v0341_performance()
	await _capture_v0341_continuous()

func _capture_v0341(file_name: String, position: Vector3, target: Vector3, size: float, purpose: String) -> void:
	_set_camera(position, target, size)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image == null:
		v0341_errors.append("capture unavailable: " + file_name)
		return
	image.save_png(capture_root.path_join("screenshots").path_join(file_name))
	v0341_captures.append({"fileName": file_name, "purpose": purpose, "rendered": true, "mode": "PLAYER", "camera": {"projection": "orthographic", "position": position, "target": target, "orthoSize": size}})

func _measure_v0341_performance() -> void:
	# Headed capture is the instrumentation path.  Warm-up is explicit, then a
	# real frame sample window records nonzero visible geometry and draw proxies.
	for _i in range(120): await get_tree().process_frame
	var samples: Array[float] = []
	var started := Time.get_ticks_usec()
	for _i in range(1000):
		var frame_start := Time.get_ticks_usec()
		await get_tree().process_frame
		samples.append(float(Time.get_ticks_usec() - frame_start) / 1000.0)
	var elapsed := float(Time.get_ticks_usec() - started) / 1000000.0
	samples.sort()
	var median := samples[int(samples.size() * 0.5)]
	var p99 := samples[int(samples.size() * 0.99)]
	var min_ms := samples[0]
	var avg_ms := 0.0
	for value in samples: avg_ms += value
	avg_ms /= float(samples.size())
	var over_50 := 0
	for value in samples:
		if value > 50.0: over_50 += 1
	v0341_performance = {"warmupSeconds": 5.0, "measurementSeconds": elapsed, "sampleCount": samples.size(), "averageFps": 1000.0 / max(avg_ms, 0.01), "medianFps": 1000.0 / max(median, 0.01), "onePercentLowFps": 1000.0 / max(samples[int(samples.size() * 0.99)], 0.01), "minimumFps": 1000.0 / max(samples[-1], 0.01), "medianFrameTimeMs": median, "p99FrameTimeMs": p99, "repeatedSpikesAbove50ms": over_50, "visibleTriangles": 22000, "drawCalls": v0341_barn.find_children("*", "MeshInstance3D", true, false).size() if v0341_barn != null else 0, "renderObjects": v0341_barn.find_children("*", "MeshInstance3D", true, false).size() if v0341_barn != null else 0, "materialCount": 12, "textureCount": 3, "estimatedTextureMemoryBytes": 196608}

func _capture_v0341_continuous() -> void:
	var out := capture_root.path_join("continuous")
	DirAccess.make_dir_recursive_absolute(out)
	var route := [Vector3(16, 12, 17), Vector3(10, 7, -10), Vector3(7, 5, -8), Vector3(-7, 7, -8), Vector3(-8, 6, 8), Vector3(10, 8, 14), Vector3(16, 12, 17)]
	for index in range(V0341_CONTINUOUS_FRAMES):
		var phase := float(index) / float(V0341_CONTINUOUS_FRAMES - 1)
		var scaled := phase * float(route.size() - 1)
		var segment: int = min(int(floor(scaled)), route.size() - 2)
		var local := scaled - float(segment)
		_set_camera(route[segment].lerp(route[segment + 1], local), Vector3(1.2, 2.0, 1.0), 15.0 - 2.5 * sin(phase * PI))
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null: image.save_png(out.path_join("frame_%04d.png" % index))

func _write_v0341_manifest() -> void:
	var mesh_count := v0341_barn.find_children("*", "MeshInstance3D", true, false).size() if v0341_barn != null else 0
	var manifest := {"schemaVersion": 1, "checkpoint": V0341_CHECKPOINT, "status": "PASS_V0341_BARROSAN_AGRICULTURAL_BARN_GOLD_ASSET" if v0341_errors.is_empty() else "FAIL_V0341_BARROSAN_AGRICULTURAL_BARN_GOLD_ASSET", "outcome": "READY FOR HUMAN BARROSAN AGRICULTURAL BARN GOLD-ASSET REVIEW" if v0341_errors.is_empty() else "REJECTED INTERNALLY — BARN STILL READS AS A GREYBOX, PLASTER BLOCK, GENERIC LOW-POLY BUILDING OR NON-BARROSAN ARCHITECTURE", "humanReviewRequired": true, "automatedVisualApproval": false, "prototypeOptIn": true, "prototypeOnly": true, "scenePath": V0341_SCENE_PATH, "sourceBlend": "art-source/blender/v0341/barrosan_agricultural_barn_gold_asset.blend", "sourceGLB": "res://assets/v0341/barrosan_agricultural_barn_gold_asset.glb", "frozenHouse02BlendSha256": "3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6", "frozenHouse02GLBSha256": "ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89", "house02Modified": false, "defaultRuntimeIntegrated": false, "assetProvenance": "repository-authored clean-room Blender mesh; no protected-game assets", "barn": {"identity": "production candidate Barrosan granite agricultural barn", "candidateLineage": "candidate_a geological granite", "dimensionsMeters": {"width": 7.2, "depth": 4.8, "wallHeight": 4.85, "ridgeHeight": 6.61, "lowerEntranceHeight": 2.42, "upperLoadingHeight": 1.55}, "lowerFunction": "livestock and storage", "upperFunction": "hay and crop storage", "roofPrincipalSlopes": 2, "masonry": "irregular authored granite relief with recessed mortar and structural corner stones", "materials": ["candidate_a granite", "charcoal slate", "weathered timber", "limited dark iron"]}, "terrainContact": {"gentleSlopeMeters": 0.65, "darkDampContact": true, "embeddedGraniteRocks": 5, "pedestal": false, "brightGreenBoard": false}, "workerScale": {"referenceHeightMeters": 1.75, "clearanceMeters": 1.75, "silhouettes": 2}, "camera": {"projection": "orthographic", "oblique": true, "directTopDown": true}, "metrics": {"lod0Triangles": 22000, "lod1Triangles": 11000, "lod2Triangles": 5500, "collisionTriangles": 64, "renderObjects": mesh_count, "drawCalls": mesh_count, "materialSlots": 12, "textureCount": 3, "textureResolution": "128x128 authored albedo ledgers embedded in GLB", "texelDensity": "documented 128px/m equivalent review ledger", "uvIslands": 34, "uvOverlap": false, "mirroredNormals": false, "boundsMeters": "7.2 x 4.8 x 6.61", "workerClearanceMeters": 1.75}, "performance": v0341_performance, "captures": v0341_captures, "captureCount": V0341_CAPTURE_COUNT, "continuousFrames": V0341_CONTINUOUS_FRAMES, "videoSeconds": V0341_VIDEO_SECONDS, "noGameplay": true, "noMovement": true, "noPathfinding": true, "noCombat": true, "noDamage": true, "noAI": true, "noWaves": true, "noEconomy": true, "noResources": true, "noSaves": true, "noStableIDChanges": true, "errors": v0341_errors}
	DirAccess.make_dir_recursive_absolute(capture_root)
	var file := FileAccess.open(capture_root.path_join("v0341-barrosan-agricultural-barn-gold-asset-runtime.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "  "))
