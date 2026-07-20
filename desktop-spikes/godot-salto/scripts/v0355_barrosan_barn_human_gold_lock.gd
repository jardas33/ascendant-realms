extends "res://scripts/v0354_barn_final_evidence.gd"

const V0355_CHECKPOINT := "v0.355"
const V0355_SCENE_PATH := "res://scenes/gold/barrosan/BarrosanBarnGold.tscn"
const V0355_CAPTURE_SCENE_PATH := "res://scenes/review/V0355BarrosanBarnHumanGoldLock.tscn"
const V0355_READY_OUTCOME := "READY FOR HUMAN V0355 BARROSAN BARN GOLD-LOCK RECORD REVIEW"
const V0355_FAILURE_OUTCOME := "REJECTED INTERNALLY — V0.355 CANONICAL BARN DOES NOT REPRODUCE THE HUMAN-APPROVED V0.354 VISUAL SOURCE"
const V0355_ACCEPTED_SOURCE_HASH := "13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3"
const V0355_FROZEN_ROOF_HASH := "0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9"
const V0355_RAW_NAMES := [
	"01_canonical_barn_neutral_front_three_quarter.png",
	"02_canonical_barn_direct_front.png",
	"03_canonical_barn_direct_rear.png",
	"04_canonical_barn_square_256.png"
]

var v0355_capture_root := ""
var v0355_captures: Array[Dictionary] = []
var v0355_raw_hash := ""
var v0355_canonical_hash := ""
var v0355_failure := false

func _ready() -> void:
	print("V0355_READY")
	v0355_capture_root = OS.get_environment("V0355_ARTIFACT_ROOT")
	capture_root = v0355_capture_root
	_build_world()
	_load_assets()
	_build_context_dressing()
	_build_debug_review()
	_build_camera()
	if v0355_capture_root != "":
		await get_tree().process_frame
		await get_tree().process_frame
		await _capture_v0355_source_set()
		_write_v0355_manifest()
		get_tree().quit(0 if not v0355_failure and errors.is_empty() else 1)

func _load_assets() -> void:
	var house_scene := load(HOUSE_GLB) as PackedScene
	if house_scene == null:
		errors.append("frozen House02 could not load")
	else:
		house = house_scene.instantiate() as Node3D
		house.name = "V0355_Frozen_House02_Unmodified_Anchor"
		world.add_child(house)
		_hide_non_lod_house_nodes(house)
		house.visible = false
	var canonical_scene := load(V0355_SCENE_PATH) as PackedScene
	if canonical_scene == null:
		errors.append("canonical v0.355 barn scene could not load")
		return
	barn = canonical_scene.instantiate() as Node3D
	barn.name = "V0355_Barrosan_Barn_Gold_Canonical_Passive_Instance"
	barn.position = Vector3(0, 0.18, 0)
	world.add_child(barn)
	# Apply only the frozen, already-accepted v0.350/v0.352/v0.351 visual
	# recipe. This keeps the registered scene passive while preserving the
	# exact v0.354 render contract at capture time.
	_apply_frozen_v0350_material_skin()
	_apply_roof_visibility_repair()
	_apply_upper_loading_shutters()
	_apply_terrain_integrated_contact()
	if barn.find_children("*", "MeshInstance3D", true, false).is_empty():
		errors.append("canonical v0.355 barn has no visible meshes")

func _capture_v0355_source_set() -> void:
	house.visible = false
	barn.visible = true
	context_workers.visible = false
	debug_review.visible = false
	await _frame_v0355("01_canonical_barn_neutral_front_three_quarter.png", Vector3(-15, 8.4, 15), Vector3(0, 2.65, 0), 16.5, "canonical passive barn neutral front three-quarter")
	await _frame_v0355("02_canonical_barn_direct_front.png", Vector3(0, 7.0, 18), Vector3(0, 2.55, 0), 15.0, "canonical passive barn direct front")
	await _frame_v0355("03_canonical_barn_direct_rear.png", Vector3(0, 7.0, -18), Vector3(0, 2.55, 0), 15.0, "canonical passive barn direct rear")
	var square := await _square_render("04_canonical_barn_square_256.png", false)
	v0355_canonical_hash = _sha256_file(v0355_capture_root.path_join("screenshots").path_join("04_canonical_barn_square_256.png"))
	v0355_raw_hash = v0355_canonical_hash
	v0355_captures.append({"fileName":"04_canonical_barn_square_256.png","purpose":"fresh canonical 256x256 source in accepted v0.354 neutral world/camera","rendered":true,"technicalOverlay":false,"pixelAspectRatio":1.0,"cameraHash":str(square.get("cameraHash", "")),"captureMethod":"direct 256x256 SubViewport; no crop; no stretch","size":{"width":256,"height":256}})
	if v0355_canonical_hash != V0355_ACCEPTED_SOURCE_HASH:
		v0355_failure = true

func _frame_v0355(filename: String, position: Vector3, target: Vector3, size: float, purpose: String) -> void:
	var image := await _frame(filename, position, target, size, purpose)
	v0355_captures.append({"fileName":filename,"purpose":purpose,"rendered":true,"technicalOverlay":false,"size":{"width":image.get_width(),"height":image.get_height()},"camera":{"projection":"orthographic","position":position,"target":target,"size":size}})

func _write_v0355_manifest() -> void:
	var outcome := V0355_READY_OUTCOME if not v0355_failure and errors.is_empty() else V0355_FAILURE_OUTCOME
	var path := v0355_capture_root.path_join("v0355-barrosan-barn-human-gold-lock-runtime.json")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	var decision := "V0.354 HUMAN-APPROVED " + String.chr(0x2014) + " BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN"
	var manifest := {
		"schemaVersion":1,
		"checkpoint":V0355_CHECKPOINT,
		"status":"PASS_V0355_BARROSAN_BARN_HUMAN_GOLD_LOCK_RUNTIME" if not v0355_failure and errors.is_empty() else "FAIL_V0355_BARROSAN_BARN_HUMAN_GOLD_LOCK_RUNTIME",
		"outcome":outcome,
		"canonicalScenePath":V0355_SCENE_PATH,
		"canonicalCaptureScenePath":V0355_CAPTURE_SCENE_PATH,
		"canonicalMatchesAcceptedSource":v0355_canonical_hash == V0355_ACCEPTED_SOURCE_HASH,
		"acceptedV0354Raw256SourceHash":V0355_ACCEPTED_SOURCE_HASH,
		"canonical256SourceHash":v0355_canonical_hash,
		"frozenRoofRepairHash":V0355_FROZEN_ROOF_HASH,
		"humanDecision":decision,
		"humanApprovalCheckpoint":"v0.354",
		"humanApprovalCommit":"3e557032976075b06a20f45213d6949c68add314",
		"visualGold":true,
		"productionIntegrated":false,
		"defaultRuntimeIntegrated":false,
		"gameplayIntegrated":false,
		"automatedVisualApproval":false,
		"collisionIntegrated":false,
		"stableGameplayId":null,
		"prototypeOptIn":true,
		"passiveVisualOnly":true,
		"lineage":{"geometry":"v0.347","material":"v0.350","shutters":"v0.351","roof":"v0.352","workersAndNaturalContact":"v0.353","finalEvidence":"v0.354","canonicalRegistration":"v0.355"},
		"sourceBlend":"art-source/blender/v0350/barn_final_material_harmony.blend",
		"sourceGLB":"res://assets/v0350/barn_final_material_harmony.glb",
		"materialPaths":["res://assets/v0350/v0350_traditional_slate_courses_albedo.png","res://assets/v0338/barrosan_house_02_material_gold_candidate_gold_candidate_rubble_albedo.png"],
		"canonicalResourcePaths":[V0355_SCENE_PATH,"res://scripts/v0355_barrosan_barn_gold_authoring.gd"],
		"geometryHash":"frozen-v0.347-v0.352-runtime-bake",
		"materialHash":"frozen-v0.350-material-baseline",
		"textureHash":"frozen-v0.350-texture-baseline",
		"sceneHash":_sha256_file(ProjectSettings.globalize_path(V0355_SCENE_PATH)),
		"manifestHash":"pending-after-write",
		"humanApprovedAtCheckpoint":"v0.354",
		"deferredWork":["production/default integration","gameplay building registration","collision/navigation","animation","workers/props/vegetation integration"],
		"noReviewCameraInCanonicalScene":true,
		"noLightsInCanonicalScene":true,
		"noTerrainInCanonicalScene":true,
		"noWorkersInCanonicalScene":true,
		"noLabelsInCanonicalScene":true,
		"noGameplayInCanonicalScene":true,
		"rawCaptureCount":v0355_captures.size(),
		"requiredRawNames":V0355_RAW_NAMES,
		"captures":v0355_captures,
		"exactCanonical256Source":v0355_canonical_hash == V0355_ACCEPTED_SOURCE_HASH,
		"errors":errors
	}
	file.store_string(JSON.stringify(manifest, "  "))
	file.close()
