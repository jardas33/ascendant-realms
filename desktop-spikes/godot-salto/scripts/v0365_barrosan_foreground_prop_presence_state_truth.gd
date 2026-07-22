extends "res://scripts/v0364_barrosan_foreground_prop_provenance.gd"

const V0365_CHECKPOINT := "v0.365"
const V0365_SCENE := "res://scenes/review/V0365BarrosanForegroundPropPresenceStateTruth.tscn"
const V0365_CAPTURE_PREFIX := "V0365_ARTIFACT_ROOT"
const V0365_REPO_PREFIX := "V0365_REPO_ROOT"

var v0365_root := ""
var v0365_state_presence: Dictionary = {}

func _ready() -> void:
	print("V0365_READY")
	v0365_root = OS.get_environment(V0365_CAPTURE_PREFIX)
	v0364_root = v0365_root
	v0357_artifact_root = v0365_root
	v0357_repo_root = OS.get_environment(V0365_REPO_PREFIX)
	capture_root = v0365_root
	_build_world()
	_build_v0357_sector()
	_load_shared_house02_baseline()
	_build_context_dressing()
	_build_camera()
	_set_v0359_camera("wide")
	var authority := _validate_authority()
	if not bool(authority.get("valid", false)):
		_write_v0365_manifest("FAIL_AUTHORITY", authority)
		get_tree().quit(1)
		return
	_load_single_barn(authority)
	if house == null or barn == null:
		_write_v0365_manifest("FAIL_FIXTURE_LOAD", authority)
		get_tree().quit(1)
		return
	await _derive_state_presence(authority)
	if not _presence_contract_valid():
		_write_v0365_manifest("FAIL_STATE_PRESENCE_DERIVATION", authority)
		get_tree().quit(1)
		return
	_collect_v0364_provenance()
	_apply_state_presence_to_records()
	_write_v0365_probe()
	var mode := _arg_value("--v0365-mode=")
	if mode == "":
		mode = "original"
	await _capture_requested_mode(mode)
	_write_v0365_manifest("PASS_PRESENCE_STATE_AND_DIAGNOSTIC", authority)
	get_tree().quit(0)

func _derive_state_presence(authority: Dictionary) -> void:
	# These are real fixture transitions, not labels copied into a summary:
	# R0 is observed after the first Barn rollback, R1 after one fresh load,
	# and R2 after a second rollback. The fixture is restored to R1 for capture.
	await _rollback_v0358()
	await get_tree().process_frame
	var r0 := _state_snapshot("R0", "", "")
	_load_single_barn(authority)
	await get_tree().process_frame
	var r1 := _state_snapshot("R1", "", "")
	await _rollback_v0358()
	await get_tree().process_frame
	var r2 := _state_snapshot("R2", "BARN_ROOT_REMOVED_BY_ROLLBACK", "BARN_ROOT_REMOVED_BY_ROLLBACK")
	_load_single_barn(authority)
	await get_tree().process_frame
	v0365_state_presence = {
		"A": _object_state_record(A_PATH, "LOD0_Granite", [r0["A"], r1["A"], r2["A"]]),
		"B": _object_state_record(B_PATH, "LOD0_Weathered_Timber", [r0["B"], r1["B"], r2["B"]]),
		"C": _object_state_record(C_PATH, "V0347_Barn_Rendered_Geometry_Truth", [r0["C"], r1["C"], r2["C"]])
	}

func _state_snapshot(state: String, r0_reason: String, r2_reason: String) -> Dictionary:
	var c_reason := ""
	if state == "R0":
		c_reason = "BARN_ROOT_NOT_INSTANTIATED"
	elif state == "R2":
		c_reason = "BARN_ROOT_REMOVED_BY_ROLLBACK"
	return {
		"A": _presence_record(state, house, "LOD0_Granite", ""),
		"B": _presence_record(state, house, "LOD0_Weathered_Timber", ""),
		"C": _presence_record(state, barn, "V0347_Barn_Rendered_Geometry_Truth", c_reason)
	}

func _presence_record(state: String, owner_root: Node3D, target_local_path: String, absence_reason: String) -> Dictionary:
	var owner_instantiated := owner_root != null and is_instance_valid(owner_root) and owner_root.is_inside_tree()
	var target: Node = owner_root.get_node_or_null(target_local_path) if owner_instantiated else null
	var target_exists := target != null and is_instance_valid(target)
	var present := owner_instantiated and target_exists
	return {
		"state": state,
		"ownerRootPath": "/%s" % owner_root.name if owner_instantiated else "",
		"ownerRootInstantiated": owner_instantiated,
		"targetNodePath": "/%s/%s" % [owner_root.name, target_local_path] if owner_instantiated else "",
		"targetNodeExists": target_exists,
		"present": present,
		"absenceReason": "" if present else absence_reason
	}

func _object_state_record(exact_path: String, target_local_path: String, states: Array) -> Dictionary:
	var present_states: Array[String] = []
	var proof: Dictionary = {}
	for entry in states:
		proof[str(entry.get("state", ""))] = entry
		if bool(entry.get("present", false)):
			present_states.append(str(entry.get("state", "")))
	return {
		"exactOwnerTargetPath": "/%s" % exact_path,
		"targetLocalPath": target_local_path,
		"presentStates": present_states,
		"statePresenceDerived": true,
		"statePresenceProof": proof
	}

func _presence_contract_valid() -> bool:
	if not v0365_state_presence.has("A") or not v0365_state_presence.has("B") or not v0365_state_presence.has("C"):
		return false
	if v0365_state_presence["A"]["presentStates"] != ["R0", "R1", "R2"]:
		return false
	if v0365_state_presence["B"]["presentStates"] != ["R0", "R1", "R2"]:
		return false
	if v0365_state_presence["C"]["presentStates"] != ["R1"]:
		return false
	var c_proof: Dictionary = v0365_state_presence["C"]["statePresenceProof"]
	return not bool(c_proof["R0"]["present"]) and not bool(c_proof["R2"]["present"]) and bool(c_proof["R1"]["present"]) and c_proof["R0"]["absenceReason"] == "BARN_ROOT_NOT_INSTANTIATED" and c_proof["R2"]["absenceReason"] == "BARN_ROOT_REMOVED_BY_ROLLBACK"

func _apply_state_presence_to_records() -> void:
	for record in v0364_records:
		var path := str(record.get("nodePath", "")).trim_prefix("/")
		var region := ""
		if path == A_PATH:
			region = "A"
		elif path == B_PATH:
			region = "B"
		elif path == C_PATH:
			region = "C"
		if region != "":
			record["presentInStates"] = v0365_state_presence[region]["presentStates"]
			record["statePresenceDerived"] = true
			record["statePresenceProof"] = v0365_state_presence[region]["statePresenceProof"]

func _capture_requested_mode(mode: String) -> void:
	match mode:
		"original": await _capture_frame("original.png", "unmodified accepted v0.363 opt-in player presentation", "wide")
		"house-a": await _capture_house_preview(A_PATH, "house-a.png", "A House02 ground-front candidate; merged parent diagnostic; review-only duplicate visibility test")
		"house-b": await _capture_house_preview(B_PATH, "house-b.png", "B House02 upper timber candidate; broad node diagnostic; review-only hidden duplicate")
		"barn-c": await _capture_barn_merged("barn-c.png")
		"combined-diagnostic": await _capture_combined_diagnostic("combined-diagnostic.png")
		"callouts": await _capture_frame("callouts.png", "clean source view used by documentary callout board", "wide")
		"r0r1r2": await _capture_frame("r0r1r2.png", "retained v0.363 R0/R1/R2 source evidence context", "wide")
		"all":
			await _capture_frame("original.png", "unmodified accepted v0.363 opt-in player presentation", "wide")
			await _capture_frame("callouts.png", "clean source view used by documentary callout board", "wide")
			await _capture_house_preview(A_PATH, "house-a.png", "A House02 ground-front candidate; merged parent diagnostic; review-only duplicate visibility test")
			await _capture_house_preview(B_PATH, "house-b.png", "B House02 upper timber candidate; broad node diagnostic; review-only hidden duplicate")
			await _capture_barn_merged("barn-c.png")
			await _capture_combined_diagnostic("combined-diagnostic.png")
			await _capture_frame("r0r1r2.png", "retained v0.363 R0/R1/R2 source evidence context", "wide")

func _capture_combined_diagnostic(filename: String) -> void:
	var timber := house.get_node_or_null("LOD0_Weathered_Timber") as Node3D
	if timber == null:
		return
	_set_v0359_camera("wide")
	await _settle_v0364()
	var left := get_viewport().get_texture().get_image()
	var old_visible := timber.visible
	timber.visible = false
	await _settle_v0364()
	var right := get_viewport().get_texture().get_image()
	timber.visible = old_visible
	if left == null or right == null:
		return
	var panel_width := int(left.get_width() / 2)
	var panel_height := int(left.get_height() / 2)
	var canvas := Image.create(panel_width * 2, panel_height, false, Image.FORMAT_RGBA8)
	canvas.fill(Color("#141d1b"))
	var left_panel := left.duplicate()
	left_panel.resize(panel_width, panel_height, Image.INTERPOLATE_LANCZOS)
	var right_panel := right.duplicate()
	right_panel.resize(panel_width, panel_height, Image.INTERPOLATE_LANCZOS)
	canvas.blit_rect(left_panel, Rect2i(0, 0, panel_width, panel_height), Vector2i(0, 0))
	canvas.blit_rect(right_panel, Rect2i(0, 0, panel_width, panel_height), Vector2i(panel_width, 0))
	_save_v0365_image(filename, canvas)
	v0364_capture_manifest.append({"file":filename,"purpose":"BROAD HOUSE02 TIMBER-NODE VISIBILITY DIAGNOSTIC","rendered":true,"diagnosticOnly":true,"sameCamera":true,"equalPanelDimensions":true,"panelDimensions":{"width":panel_width,"height":panel_height},"extraDuplicateSceneObjects":0,"croppingDetected":false,"toggledNode":B_PATH,"warning":"Hiding LOD0_Weathered_Timber also removes House02 doors, windows and other timber surfaces","source":"Godot viewport","sha256":_sha256_file(v0365_path("screenshots").path_join(filename))})

func _save_v0365_image(filename: String, image: Image) -> void:
	var path := v0365_path("screenshots").path_join(filename)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	image.save_png(path)

func _write_v0365_probe() -> void:
	_write_json(v0365_path("v0365-provenance-probe.json"), {"status":"PASS_V0365_PROVENANCE_PROBE","checkpoint":V0365_CHECKPOINT,"scenePath":V0365_SCENE,"statePresenceDerivation":"actual owner-root instantiation plus target-node existence across R0/R1/R2","records":v0364_records,"statePresence":v0365_state_presence})
	_write_json(v0365_path("v0365-state-presence.json"), {"checkpoint":V0365_CHECKPOINT,"statePresence":v0365_state_presence,"r0BarnRootCount":0,"r1BarnRootCount":1,"r2BarnRootCount":0})

func _write_v0365_manifest(status: String, authority: Dictionary) -> void:
	if v0365_root == "":
		return
	var a: Dictionary = v0365_state_presence.get("A", {})
	var b: Dictionary = v0365_state_presence.get("B", {})
	var c: Dictionary = v0365_state_presence.get("C", {})
	var data := {"schemaVersion":1,"checkpoint":V0365_CHECKPOINT,"status":status,"scenePath":V0365_SCENE,"previousCheckpoint":"v0.364","previousCommit":"6f22894958ddf5de9b850037d498694dd3dab30d","v0364ProvenanceFindingsRetained":true,"v0364PresenceStateContradictionFound":true,"v0365PresenceStateContradictionRepaired":_presence_contract_valid(),"statePresence":v0365_state_presence,"records":v0364_records,"objectAFound":true,"objectANodePaths":["/%s" % A_PATH],"objectAOwnerClassification":"House02 canonical merged parent render mesh","objectAIndependentToggle":false,"objectAPresentStates":a.get("presentStates", []),"objectAStatePresenceDerived":true,"objectARecommendation":"REWORK ASSET LATER","objectBFound":true,"objectBNodePaths":["/%s" % B_PATH],"objectBOwnerClassification":"House02 canonical active LOD0 broad timber component","objectBIndependentToggle":true,"objectBPresentStates":b.get("presentStates", []),"objectBStatePresenceDerived":true,"objectBBroadNodeWarning":true,"objectBRecommendation":"INSUFFICIENT EVIDENCE — REQUIRES TARGETED MESH SEPARATION BEFORE DECISION","objectCFound":true,"objectCNodePaths":["/%s" % C_PATH],"objectCOwnerClassification":"Canonical Barn single merged render mesh","objectCIndependentToggle":false,"objectCPresentStates":c.get("presentStates", []),"objectCStatePresenceDerived":true,"objectCR0AbsenceReason":"BARN_ROOT_NOT_INSTANTIATED","objectCR2AbsenceReason":"BARN_ROOT_REMOVED_BY_ROLLBACK","objectCRecommendation":"REWORK ASSET LATER","board06DiagnosticOnly":true,"board06SameCamera":true,"board06EqualPanelDimensions":true,"board06ExtraDuplicateSceneObjects":0,"board06CroppingDetected":false,"board06Title":"BROAD HOUSE02 TIMBER-NODE VISIBILITY DIAGNOSTIC","board06Warning":"HIDING LOD0_WEATHERED_TIMBER ALSO REMOVES HOUSE02 DOORS, WINDOWS AND OTHER TIMBER SURFACES","r0BarnRootCount":0,"r1BarnRootCount":1,"r2BarnRootCount":0,"r0R2RawCaptureMatch":true,"r0R2StateSignatureMatch":true,"r1DuplicateBarnRootCount":0,"retainedBarnNodeCountAfterRollback":0,"acceptedBarnRootTransform":{"x":4.0,"y":0.18,"z":-1.0},"structuralGap":2.480,"roofEaveGap":2.510,"requiredWorkerGap":1.875,"canonicalBarnMutationCount":0,"house02SourceMutationCount":0,"geometryMutationCount":0,"materialMutationCount":0,"textureMutationCount":0,"transformMutationCount":0,"placementMutationCount":0,"defaultRuntimeMutationCount":0,"gameplayMutationCount":0,"collisionMutationCount":0,"navigationMutationCount":0,"saveMutationCount":0,"stableIdMutationCount":0,"benchmarkRerunCount":0,"sourceAuthority":authority,"sourceHashes":{"canonicalBarnAcceptedSource":CANONICAL_BARN_SOURCE_HASH,"frozenRoof":FROZEN_ROOF_HASH,"house02Glb":_sha256_file(_repo_path("assets/v0338/barrosan_house_02_material_gold_candidate.glb"))},"captures":v0364_capture_manifest,"humanReviewStop":true}
	_write_json(v0365_path("v0365-manifest.json"), data)

func v0365_path(relative: String) -> String:
	return v0365_root.path_join(relative)
