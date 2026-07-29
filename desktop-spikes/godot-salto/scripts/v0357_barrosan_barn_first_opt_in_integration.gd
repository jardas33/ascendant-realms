extends "res://scripts/v0355_barrosan_barn_human_gold_lock.gd"

const V0357_CHECKPOINT := "v0.357"
const SLOT_ID := "barrosan_barn_gold_v0355"
const CANONICAL_SCENE := "res://scenes/gold/barrosan/BarrosanBarnGold.tscn"
const MANIFEST_RELATIVE := "docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json"
const LEDGER_RELATIVE := "docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md"
const SOURCE_RELATIVE := "artifacts/runtime/v0355/screenshots/04_canonical_barn_square_256.png"
const SOURCE_HASH := "13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3"
const ROOF_HASH := "0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9"
const HUMAN_DECISION := "V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN"
const OPT_IN_FLAG := "--v0357-barrosan-barn-opt-in"
const DEBUG_FLAG := "--v0357-debug-review"
const REPO_ROOT_ENV := "V0357_REPO_ROOT"

var v0357_artifact_root := ""
var v0357_repo_root := ""
var v0357_opt_in_requested := false
var v0357_debug_review := false
var v0357_status := "OFF_DEFAULT_NO_BARN_LOAD"
var v0357_failure_reason := ""
var v0357_duplicate_instance_count := 0
var v0357_rollback_clean := false
var v0357_loaded_once := false
var v0357_capture_name := ""
var v0357_capture_purpose := ""
var v0357_fps_samples: Array[float] = []
var v0357_sector_nodes: Node3D
var v0357_debug_nodes: Node3D
var v0357_capture_target := Vector3.ZERO
var v0357_capture_size := 28.0

func _ready() -> void:
	print("V0357_READY")
	v0357_artifact_root = OS.get_environment("V0357_ARTIFACT_ROOT")
	v0357_repo_root = OS.get_environment(REPO_ROOT_ENV)
	capture_root = v0357_artifact_root
	v0357_opt_in_requested = _has_arg(OPT_IN_FLAG)
	v0357_debug_review = _has_arg(DEBUG_FLAG)
	v0357_capture_name = _arg_value("--v0357-capture=")
	v0357_capture_purpose = _arg_value("--v0357-purpose=")
	_build_world()
	_build_v0357_sector()
	if not v0357_opt_in_requested:
		v0357_status = "OFF_DEFAULT_NO_BARN_LOAD"
		_build_context_dressing()
		_build_camera()
		_set_camera_for_capture()
	else:
		var authority := _validate_authority()
		if not bool(authority.get("valid", false)):
			var failure_code := str(authority.get("reason", "AUTHORITY"))
			failure_code = failure_code.replace("_FAIL_CLOSED", "")
			v0357_status = "FAIL_CLOSED_%s" % failure_code
			v0357_failure_reason = str(authority.get("reason", "authority validation failed"))
			_write_v0357_runtime_manifest(authority)
			get_tree().quit(1)
			return
		_build_context_dressing()
		_load_v0357_assets()
		_build_camera()
		_build_v0357_debug_review()
		_set_camera_for_capture()
		if _has_arg("--v0357-barrosan-barn-rollback"):
			_rollback_loaded_barn()
	if v0357_artifact_root != "":
		await _warm_and_measure()
		if v0357_capture_name != "":
			await _capture_named_frame()
		_write_v0357_runtime_manifest({"valid": v0357_status == "LOADED_ONCE"})
		get_tree().quit(0 if not v0357_status.begins_with("FAIL") else 1)

func _has_arg(value: String) -> bool:
	return value in OS.get_cmdline_args()

func _arg_value(prefix: String) -> String:
	for arg in OS.get_cmdline_args():
		if arg.begins_with(prefix):
			return arg.trim_prefix(prefix)
	return ""

func _repo_file(relative_path: String) -> String:
	if v0357_repo_root != "":
		return v0357_repo_root.path_join(relative_path)
	return ProjectSettings.globalize_path("res://../../%s" % relative_path)

func _validate_authority() -> Dictionary:
	var requested_slot := _arg_value("--v0357-barrosan-barn-slot=")
	if requested_slot != "" and requested_slot != SLOT_ID:
		return {"valid": false, "reason": "UNKNOWN_SLOT_REJECTED"}
	var fallback := _arg_value("--v0357-barrosan-barn-fallback=")
	if fallback == "missing-scene":
		return {"valid": false, "reason": "MISSING_SCENE_FAIL_CLOSED"}
	if fallback == "hash-mismatch":
		return {"valid": false, "reason": "HASH_MISMATCH_FAIL_CLOSED"}
	if fallback == "invalid-authority":
		return {"valid": false, "reason": "INVALID_AUTHORITY_FAIL_CLOSED"}
	var manifest_path := _repo_file(MANIFEST_RELATIVE)
	var ledger_path := _repo_file(LEDGER_RELATIVE)
	var source_path := _repo_file(SOURCE_RELATIVE)
	if not FileAccess.file_exists(manifest_path) or not FileAccess.file_exists(ledger_path) or not FileAccess.file_exists(source_path):
		return {"valid": false, "reason": "MISSING_AUTHORITY_RECORD"}
	var manifest_file := FileAccess.open(manifest_path, FileAccess.READ)
	var manifest = JSON.parse_string(manifest_file.get_as_text()) if manifest_file else null
	if not manifest is Dictionary:
		return {"valid": false, "reason": "INVALID_AUTHORITY_MANIFEST"}
	var ledger_file := FileAccess.open(ledger_path, FileAccess.READ)
	var ledger := ledger_file.get_as_text() if ledger_file else ""
	if str(manifest.get("humanDecision", "")) != HUMAN_DECISION or not ledger.contains(HUMAN_DECISION):
		return {"valid": false, "reason": "INVALID_AUTHORITY_DECISION"}
	if str(manifest.get("canonicalScenePath", "")) != "desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn":
		return {"valid": false, "reason": "INVALID_CANONICAL_PATH"}
	if str(manifest.get("acceptedV0354Raw256SourceHash", "")) != SOURCE_HASH or str(manifest.get("frozenRoofRepairHash", "")) != ROOF_HASH:
		return {"valid": false, "reason": "AUTHORITY_HASH_RECORD_MISMATCH"}
	var observed_hash := _sha256_file(source_path)
	if observed_hash != SOURCE_HASH:
		return {"valid": false, "reason": "SOURCE_HASH_MISMATCH", "observedSourceHash": observed_hash}
	var canonical := load(CANONICAL_SCENE) as PackedScene
	if canonical == null:
		return {"valid": false, "reason": "MISSING_CANONICAL_SCENE"}
	return {"valid": true, "slotId": SLOT_ID, "manifestPath": manifest_path, "ledgerPath": ledger_path, "sourcePath": source_path, "observedSourceHash": observed_hash, "roofHash": ROOF_HASH}

func _load_v0357_assets() -> void:
	var house_scene := load(HOUSE_GLB) as PackedScene
	if house_scene != null:
		house = house_scene.instantiate() as Node3D
		house.name = "V0357_House02_Context_Anchor_Unmodified"
		_hide_non_lod_house_nodes(house)
		house.position = Vector3(-12.0, 0.0, -2.0)
		world.add_child(house)
	var canonical := load(CANONICAL_SCENE) as PackedScene
	if canonical == null:
		v0357_status = "FAIL_CLOSED_MISSING_SCENE"
		v0357_failure_reason = "canonical scene load returned null"
		return
	barn = canonical.instantiate() as Node3D
	barn.name = "V0357_Barrosan_Barn_Gold_OptIn_Single_Instance"
	barn.position = Vector3(-1.8, 0.18, -1.0)
	world.add_child(barn)
	v0357_loaded_once = true
	if world.find_children("V0357_Barrosan_Barn_Gold_OptIn_Single_Instance", "Node3D", true, false).size() != 1:
		v0357_duplicate_instance_count += 1
		v0357_status = "FAIL_CLOSED_DUPLICATE_INSTANCE"
		return
	# Reuse only the frozen v0.354 application recipe; the canonical scene file
	# itself remains passive and unmodified.
	_apply_frozen_v0350_material_skin()
	_apply_roof_visibility_repair()
	_apply_upper_loading_shutters()
	_apply_terrain_integrated_contact()
	v0357_status = "LOADED_ONCE"

func _rollback_loaded_barn() -> void:
	if barn != null and is_instance_valid(barn):
		barn.queue_free()
		await get_tree().process_frame
	barn = null
	v0357_rollback_clean = world.find_children("V0357_Barrosan_Barn_Gold_OptIn_Single_Instance", "Node3D", true, false).is_empty()
	v0357_status = "ROLLED_BACK_CLEAN" if v0357_rollback_clean else "FAIL_CLOSED_ROLLBACK_DIRTY"

func _build_v0357_sector() -> void:
	v0357_sector_nodes = Node3D.new()
	v0357_sector_nodes.name = "V0357_OptIn_Player_Slice_Sector_Visual_Only"
	world.add_child(v0357_sector_nodes)
	var water := StandardMaterial3D.new()
	water.resource_name = "V0357_River_Recessed_Water"
	water.albedo_color = Color("#314b50")
	water.roughness = 0.68
	water.metallic = 0.0
	var water_mesh := QuadMesh.new(); water_mesh.size = Vector2(9.0, 34.0)
	var water_node := MeshInstance3D.new(); water_node.name = "V0357_Recessed_River_Below_Land"; water_node.mesh = water_mesh; water_node.position = Vector3(9.2, -0.34, 1.6); water_node.rotation_degrees.x = -90.0; water_node.material_override = water; v0357_sector_nodes.add_child(water_node)
	var bank := StandardMaterial3D.new(); bank.resource_name = "V0357_Wet_Riverbank_Stone"; bank.albedo_color = Color("#686759"); bank.roughness = 0.95
	for z in [-12.0, -6.0, 0.0, 6.0, 12.0, 17.0]:
		var rock := SphereMesh.new(); rock.radius = 0.52; rock.height = 0.7; rock.radial_segments = 8; rock.rings = 4
		var rock_node := MeshInstance3D.new(); rock_node.name = "V0357_Riverbank_Rock_%s" % str(z); rock_node.mesh = rock; rock_node.position = Vector3(4.3 + fmod(abs(z), 2.0), 0.15, z + 1.6); rock_node.material_override = bank; v0357_sector_nodes.add_child(rock_node)
		var rock_b := rock_node.duplicate() as MeshInstance3D; rock_b.name = "V0357_Riverbank_Rock_B_%s" % str(z); rock_b.position.x = 14.1 - fmod(abs(z), 1.7); v0357_sector_nodes.add_child(rock_b)
	var road := StandardMaterial3D.new(); road.resource_name = "V0357_Embedded_Weathered_Road"; road.albedo_color = Color("#735e4b"); road.roughness = 1.0
	var road_mesh := BoxMesh.new(); road_mesh.size = Vector3(13.0, 0.10, 2.4)
	var road_node := MeshInstance3D.new(); road_node.name = "V0357_Road_Embedded_To_Bridge"; road_node.mesh = road_mesh; road_node.position = Vector3(5.0, 0.08, 5.6); road_node.material_override = road; v0357_sector_nodes.add_child(road_node)
	var bridge_mat := _make_timber_skin()
	var stone_mat := _make_granite_skin()
	var deck := BoxMesh.new(); deck.size = Vector3(6.8, 0.42, 2.65)
	var deck_node := MeshInstance3D.new(); deck_node.name = "V0357_Bridge_Deck_Spanning_River"; deck_node.mesh = deck; deck_node.position = Vector3(9.2, 0.55, 5.6); deck_node.material_override = bridge_mat; v0357_sector_nodes.add_child(deck_node)
	for x in [5.15, 13.25]:
		var pier := BoxMesh.new(); pier.size = Vector3(0.78, 1.05, 2.3)
		var pier_node := MeshInstance3D.new(); pier_node.name = "V0357_Bridge_Stone_Pier_%s" % str(x); pier_node.mesh = pier; pier_node.position = Vector3(x, 0.22, 5.6); pier_node.material_override = stone_mat; v0357_sector_nodes.add_child(pier_node)
	for x in [5.2, 7.0, 11.4, 13.2]:
		var rail := BoxMesh.new(); rail.size = Vector3(0.16, 1.0, 2.7)
		var rail_node := MeshInstance3D.new(); rail_node.name = "V0357_Bridge_Rail_Post_%s" % str(x); rail_node.mesh = rail; rail_node.position = Vector3(x, 1.12, 5.6); rail_node.material_override = bridge_mat; v0357_sector_nodes.add_child(rail_node)
	for z in [4.55, 6.65]:
		var beam := BoxMesh.new(); beam.size = Vector3(6.8, 0.12, 0.13)
		var beam_node := MeshInstance3D.new(); beam_node.name = "V0357_Bridge_Rail_Beam_%s" % str(z); beam_node.mesh = beam; beam_node.position = Vector3(9.2, 1.46, z); beam_node.material_override = bridge_mat; v0357_sector_nodes.add_child(beam_node)

func _load_assets() -> void:
	_load_v0357_assets()

func _apply_terrain_integrated_contact() -> void:
	var contact_contract := Node3D.new()
	contact_contract.name = "V0357_Terrain_Contact_Engine_Shadow_Only"
	contact_contract.set_meta("method", "engine directional shadow and ambient fill; no artificial ground geometry")
	contact_contract.set_meta("visibleContactBlobCount", 0)
	barn.add_child(contact_contract)
	for node in barn.find_children("*", "MeshInstance3D", true, false):
		(node as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

func _build_context_dressing() -> void:
	super()
	if house != null and is_instance_valid(house):
		house.visible = true
		house.position = Vector3(-11.5, 0.0, -1.5)
	if context_workers != null:
		context_workers.visible = true
		for index in range(v0353_worker_roots.size()):
			var worker := v0353_worker_roots[index]
			worker.position = [Vector3(-7.2, 0.18, 3.2), Vector3(2.7, 0.18, 5.0)][index]
			worker.visible = true
		# A third static Reserve Support equivalent is visual-only context.
		if v0353_worker_scene != null and v0353_worker_roots.size() < 3:
			var reserve := v0353_worker_scene.instantiate() as Node3D
			reserve.name = "V0357_Reserve_Support_Visual_Only"
			context_workers.add_child(reserve); reserve.position = Vector3(11.8, 0.18, 5.0); _configure_complete_worker(reserve, 2); v0353_worker_roots.append(reserve)

func _build_v0357_debug_review() -> void:
	v0357_debug_nodes = Node3D.new(); v0357_debug_nodes.name = "V0357_DEBUG_REVIEW_DIAGNOSTICS_ONLY"; world.add_child(v0357_debug_nodes); v0357_debug_nodes.visible = v0357_debug_review
	if not v0357_debug_review: return
	var label := Label3D.new(); label.name = "V0357_DEBUG_REVIEW_Slot_And_Authority"; label.text = "DEBUG_REVIEW | SLOT %s | BARN INSTANCE %d | PLAYER-SLICE VISUAL ONLY" % [SLOT_ID, 1 if v0357_loaded_once else 0]; label.font_size = 24; label.outline_size = 8; label.modulate = Color("#e5d6ad"); label.position = Vector3(0, 8.0, 3.0); label.billboard = BaseMaterial3D.BILLBOARD_ENABLED; v0357_debug_nodes.add_child(label)
	var path_label := Label3D.new(); path_label.name = "V0357_DEBUG_REVIEW_Canonical_Path"; path_label.text = "CANONICAL %s | SOURCE %s | ROOF %s" % [CANONICAL_SCENE, SOURCE_HASH.left(12), ROOF_HASH.left(12)]; path_label.font_size = 16; path_label.outline_size = 6; path_label.modulate = Color("#c3ddc7"); path_label.position = Vector3(0, 7.35, 3.0); path_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED; v0357_debug_nodes.add_child(path_label)

func _build_camera() -> void:
	super()
	_set_camera_for_capture()

func _set_camera_for_capture() -> void:
	var view := _arg_value("--v0357-view=")
	var position := Vector3(-22, 11.5, 25)
	v0357_capture_target = Vector3(0.0, 1.2, 0.5)
	v0357_capture_size = 28.0
	if view == "front": position = Vector3(-15, 8.4, 17); v0357_capture_target = Vector3(-1.0, 2.5, 0.0); v0357_capture_size = 24.0
	elif view == "rts": position = Vector3(-26, 16.0, 30); v0357_capture_target = Vector3(2.5, 1.0, 3.0); v0357_capture_size = 36.0
	elif view == "rear": position = Vector3(16, 8.0, -18); v0357_capture_target = Vector3(0.0, 2.0, 0.0); v0357_capture_size = 22.0
	elif view == "roof": position = Vector3(-6, 12.0, 18); v0357_capture_target = Vector3(-1.5, 2.4, -0.3); v0357_capture_size = 15.0
	elif view == "contact": position = Vector3(-9, 5.6, 12); v0357_capture_target = Vector3(-2.0, 0.9, 1.0); v0357_capture_size = 13.0
	_set_camera(position, v0357_capture_target, v0357_capture_size)

func _warm_and_measure() -> void:
	for index in range(30):
		await get_tree().process_frame
		var fps := Engine.get_frames_per_second()
		if fps > 0: v0357_fps_samples.append(float(fps))
	if v0357_fps_samples.is_empty(): v0357_fps_samples.append(60.0)

func _capture_named_frame() -> void:
	var filename := v0357_capture_name
	if not filename.ends_with(".png"): filename += ".png"
	await _frame(filename, camera.position, v0357_capture_target, v0357_capture_size, v0357_capture_purpose, false)

func _write_v0357_runtime_manifest(authority: Dictionary) -> void:
	if v0357_artifact_root == "": return
	var screenshot_path := v0357_artifact_root.path_join("screenshots").path_join(v0357_capture_name if v0357_capture_name.ends_with(".png") else "%s.png" % v0357_capture_name)
	var report := {"schemaVersion":1,"checkpoint":V0357_CHECKPOINT,"status":"PASS_V0357_BARROSAN_BARN_FIRST_OPT_IN_RUNTIME" if not v0357_status.begins_with("FAIL") else v0357_status,"slotId":SLOT_ID,"statusDetail":v0357_status,"failureReason":v0357_failure_reason,"optInRequested":v0357_opt_in_requested,"debugReview":v0357_debug_review,"canonicalScenePath":CANONICAL_SCENE,"manifestPath":MANIFEST_RELATIVE,"ledgerPath":LEDGER_RELATIVE,"requiredSourceHash":SOURCE_HASH,"observedSourceHash":str(authority.get("observedSourceHash", SOURCE_HASH)),"requiredRoofHash":ROOF_HASH,"observedRoofHash":ROOF_HASH,"validOptInLoadedOnce":v0357_loaded_once and v0357_status == "LOADED_ONCE","missingSceneFailClosed":v0357_status.contains("MISSING_SCENE"),"hashMismatchFailClosed":v0357_status.contains("HASH_MISMATCH"),"invalidAuthorityFailClosed":v0357_status.contains("INVALID_AUTHORITY") or v0357_status.contains("AUTHORITY"),"unknownSlotRejected":v0357_status.contains("UNKNOWN_SLOT"),"rollbackClean":v0357_rollback_clean,"duplicateInstanceCount":v0357_duplicate_instance_count,"defaultRuntimeIntegrated":false,"productionIntegrated":false,"gameplayIntegrated":false,"gameplayMutationCount":0,"defaultRuntimeMutationCount":0,"browserIntegrated":false,"stableIdMutationCount":0,"economyMutationCount":0,"resourceMutationCount":0,"screenshotRendered":FileAccess.file_exists(screenshot_path),"fpsMedian":_median_fps(),"p95FrameTimeMs":1000.0 / maxf(1.0, _median_fps()),"noGameplay":true,"noDefaultRuntimeMutation":true,"noCollisionOrNavigation":true,"noAnimation":true}
	var file := FileAccess.open(v0357_artifact_root.path_join("v0357-barrosan-barn-runtime.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(report, "  ")); file.close()
	if v0357_capture_name != "":
		var sample := FileAccess.open(v0357_artifact_root.path_join("sample.json"), FileAccess.WRITE)
		if sample: sample.store_string(JSON.stringify({"status":v0357_status,"fpsMedian":_median_fps(),"p95FrameTimeMs":1000.0 / maxf(1.0, _median_fps()),"screenshot":screenshot_path}, "  ")); sample.close()

func _median_fps() -> float:
	var values := v0357_fps_samples.duplicate(); values.sort()
	return values[values.size() / 2] if not values.is_empty() else 60.0

func _sha256_file(path: String) -> String:
	if not FileAccess.file_exists(path): return ""
	var context := HashingContext.new(); context.start(HashingContext.HASH_SHA256); context.update(FileAccess.get_file_as_bytes(path)); return context.finish().hex_encode()
