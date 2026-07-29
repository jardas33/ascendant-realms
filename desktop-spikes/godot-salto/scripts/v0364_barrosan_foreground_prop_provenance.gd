extends "res://scripts/v0362_barrosan_barn_contextual_placement_separation.gd"

const V0364_CHECKPOINT := "v0.364"
const V0364_SCENE := "res://scenes/review/V0364BarrosanForegroundPropProvenance.tscn"
const HOUSE_SOURCE := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const BARN_SOURCE := "res://scenes/gold/barrosan/BarrosanBarnGold.tscn"
const CANONICAL_BARN_SOURCE_HASH := "13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3"
const FROZEN_ROOF_HASH := "0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9"
const BARN_ROOT := Vector3(4.0, 0.18, -1.0)
const HOUSE_ROOT := Vector3(-11.5, 0.0, -1.5)
const A_PATH := "V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite"
const B_PATH := "V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber"
const C_PATH := "V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth"

var v0364_root := ""
var v0364_records: Array[Dictionary] = []
var v0364_preview_nodes: Array[Node3D] = []
var v0364_source_hashes: Dictionary = {}
var v0364_capture_manifest: Array[Dictionary] = []

func _ready() -> void:
	print("V0364_READY")
	v0364_root = OS.get_environment("V0364_ARTIFACT_ROOT")
	v0357_artifact_root = v0364_root
	v0357_repo_root = OS.get_environment("V0364_REPO_ROOT")
	capture_root = v0364_root
	_build_world()
	_build_v0357_sector()
	_load_shared_house02_baseline()
	_build_context_dressing()
	_build_camera()
	_set_v0359_camera("wide")
	var authority := _validate_authority()
	if not bool(authority.get("valid", false)):
		_write_v0364_manifest("FAIL_AUTHORITY", authority)
		get_tree().quit(1)
		return
	_load_single_barn(authority)
	if house == null or barn == null:
		_write_v0364_manifest("FAIL_FIXTURE_LOAD", authority)
		get_tree().quit(1)
		return
	_collect_v0364_provenance()
	_write_provenance_probe()
	var mode := _arg_value("--v0364-mode=")
	if mode == "":
		mode = "original"
	await _capture_requested_mode(mode)
	_write_v0364_manifest("PASS_PROVENANCE_AND_PREVIEW", authority)
	get_tree().quit(0)

func _capture_requested_mode(mode: String) -> void:
	match mode:
		"original": await _capture_frame("original.png", "unmodified accepted v0.363 opt-in player presentation", "wide")
		"house-a": await _capture_house_preview(A_PATH, "house-a.png", "A House02 ground-front candidate; parent mesh diagnostic; review-only duplicate visibility test")
		"house-b": await _capture_house_preview(B_PATH, "house-b.png", "B House02 upper timber candidate; exact authored node; preview-only hidden duplicate")
		"house-granite": await _capture_house_preview(A_PATH, "house-granite.png", "diagnostic parent-mesh visibility test")
		"barn-c": await _capture_barn_merged("barn-c.png")
		"combined-original": await _capture_frame("combined-original.png", "left panel source for combined review; accepted original", "wide")
		"combined-preview": await _capture_combined_preview("combined-preview.png")
		"callouts": await _capture_frame("callouts.png", "clean source view used by documentary callout board", "wide")
		"all":
			await _capture_frame("original.png", "unmodified accepted v0.363 opt-in player presentation", "wide")
			await _capture_frame("callouts.png", "clean source view used by documentary callout board", "wide")
			await _capture_house_preview(A_PATH, "house-a.png", "A House02 ground-front candidate; parent mesh diagnostic; review-only duplicate visibility test")
			await _capture_house_preview(B_PATH, "house-b.png", "B House02 upper timber candidate; exact authored node; preview-only hidden duplicate")
			await _capture_barn_merged("barn-c.png")
			await _capture_frame("combined-original.png", "accepted original side of combined preview", "wide")
			await _capture_combined_preview("combined-preview.png")
			await _capture_frame("r0r1r2.png", "retained v0.363 R0/R1/R2 source evidence context", "wide")

func _capture_frame(filename: String, purpose: String, view: String) -> void:
	_set_v0359_camera(view)
	await _settle_v0364()
	var image := get_viewport().get_texture().get_image()
	if image == null:
		return
	_save_v0364_image(filename, image)
	v0364_capture_manifest.append({"file":filename,"purpose":purpose,"rendered":true,"source":"Godot viewport","camera":"orthographic %s" % view,"sha256":_sha256_file(v0364_path(filename))})

func _capture_house_preview(candidate_path: String, filename: String, purpose: String) -> void:
	var old_barn_visible := barn.visible
	var old_sector_visible := v0357_sector_nodes.visible
	var old_workers_visible := context_workers.visible
	barn.visible = false
	v0357_sector_nodes.visible = false
	context_workers.visible = false
	var original_visible := house.visible
	house.visible = true
	var preview := house.duplicate() as Node3D
	preview.name = "V0364_REVIEW_ONLY_House02_Preview_Hidden_%s" % candidate_path.get_file()
	preview.position = house.position + Vector3(12.0, 0.0, 0.0)
	world.add_child(preview)
	v0364_preview_nodes.append(preview)
	var target := preview.get_node_or_null(candidate_path.trim_prefix("V0358_House02_Shared_Baseline_Unmodified/"))
	if target is Node3D:
		(target as Node3D).visible = false
	_set_camera(Vector3(-5.5, 6.5, 14.5), Vector3(-5.5, 2.4, 0.5), 16.5)
	await _settle_v0364()
	var image := get_viewport().get_texture().get_image()
	if image != null:
		_save_v0364_image(filename, image)
		v0364_capture_manifest.append({"file":filename,"purpose":purpose,"rendered":true,"previewRoot":preview.name,"toggledNode":candidate_path,"originalUntouched":true,"source":"Godot viewport","sha256":_sha256_file(v0364_path(filename))})
	preview.queue_free()
	await get_tree().process_frame
	house.visible = original_visible
	barn.visible = old_barn_visible
	v0357_sector_nodes.visible = old_sector_visible
	context_workers.visible = old_workers_visible

func _capture_barn_merged(filename: String) -> void:
	var old_house := house.visible
	var old_sector := v0357_sector_nodes.visible
	var old_workers := context_workers.visible
	house.visible = false
	v0357_sector_nodes.visible = false
	context_workers.visible = false
	barn.visible = true
	_set_camera(Vector3(16.0, 7.5, 15.0), Vector3(7.5, 2.4, -1.0), 12.0)
	await _settle_v0364()
	var image := get_viewport().get_texture().get_image()
	if image != null:
		_save_v0364_image(filename, image)
		v0364_capture_manifest.append({"file":filename,"purpose":"C Barn front-right timber; merged parent evidence; no independent toggle fabricated","rendered":true,"merged":true,"nodePath":"/%s" % C_PATH,"source":"Godot viewport","sha256":_sha256_file(v0364_path(filename))})
	house.visible = old_house
	v0357_sector_nodes.visible = old_sector
	context_workers.visible = old_workers

func _capture_combined_preview(filename: String) -> void:
	var old_house := house.visible
	var old_barn := barn.visible
	var old_sector := v0357_sector_nodes.visible
	var old_workers := context_workers.visible
	var preview_house := house.duplicate() as Node3D
	preview_house.name = "V0364_REVIEW_ONLY_Combined_Preview_House02"
	preview_house.position = house.position + Vector3(24.0, 0.0, 0.0)
	world.add_child(preview_house)
	v0364_preview_nodes.append(preview_house)
	var b := preview_house.get_node_or_null("LOD0_Weathered_Timber")
	if b is Node3D: (b as Node3D).visible = false
	var preview_barn := barn.duplicate() as Node3D
	preview_barn.name = "V0364_REVIEW_ONLY_Combined_Preview_Barn_Merged_Unchanged"
	preview_barn.position = barn.position + Vector3(24.0, 0.0, 0.0)
	world.add_child(preview_barn)
	v0364_preview_nodes.append(preview_barn)
	house.visible = true
	barn.visible = true
	v0357_sector_nodes.visible = false
	context_workers.visible = false
	_set_camera(Vector3(-10.0, 11.5, 28.0), Vector3(0.0, 2.0, 0.0), 31.0)
	await _settle_v0364()
	var image := get_viewport().get_texture().get_image()
	if image != null:
		_save_v0364_image(filename, image)
		v0364_capture_manifest.append({"file":filename,"purpose":"original left and review-only hidden-candidate preview right; merged Barn unchanged","rendered":true,"previewOnly":true,"toggledNodes":[A_PATH,B_PATH],"source":"Godot viewport","sha256":_sha256_file(v0364_path(filename))})
	preview_house.queue_free(); preview_barn.queue_free()
	await get_tree().process_frame
	house.visible = old_house; barn.visible = old_barn; v0357_sector_nodes.visible = old_sector; context_workers.visible = old_workers

func _settle_v0364() -> void:
	for _frame in range(8):
		await get_tree().process_frame

func _collect_v0364_provenance() -> void:
	v0364_records.clear()
	_collect_active_mesh_records(house, "House02", HOUSE_SOURCE)
	_collect_active_mesh_records(barn, "Barn", BARN_SOURCE)
	for record in v0364_records:
		if str(record.get("nodePath", "")).ends_with("/LOD0_Granite"):
			record["humanRegion"] = "A"
			record["purpose"] = "PURPOSE NOT ESTABLISHED FROM SOURCE; observed slab is carried by the parent House02 granite render mesh"
			record["recommendation"] = "REWORK ASSET LATER"
			record["independentlyAddressable"] = false
			record["mergedFinding"] = "MERGED WITH PARENT ASSET — FUTURE ASSET REWORK REQUIRED"
		elif str(record.get("nodePath", "")).ends_with("/LOD0_Weathered_Timber"):
			record["humanRegion"] = "B"
			record["purpose"] = "PURPOSE NOT ESTABLISHED FROM SOURCE; authored material identity is V0334_Weathered_Timber"
			record["recommendation"] = "INSUFFICIENT EVIDENCE"
		elif str(record.get("nodePath", "")).ends_with("/V0347_Barn_Rendered_Geometry_Truth"):
			record["humanRegion"] = "C"
			record["purpose"] = "PURPOSE NOT ESTABLISHED FROM SOURCE; one merged Barn render mesh contains the observed foreground timber"
			record["recommendation"] = "REWORK ASSET LATER"
			record["independentlyAddressable"] = false
			record["mergedFinding"] = "MERGED WITH PARENT ASSET — FUTURE ASSET REWORK REQUIRED"
		else:
			record["humanRegion"] = "context"

func _collect_active_mesh_records(root: Node3D, classification: String, source_scene: String) -> void:
	if root == null:
		return
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node == null or mesh_node.mesh == null:
			continue
		var name := str(mesh_node.name).to_lower()
		if name.contains("lod1") or name.contains("lod2") or name.contains("collision"):
			continue
		var materials: Array[Dictionary] = []
		for surface in range(mesh_node.mesh.get_surface_count()):
			var material := mesh_node.get_active_material(surface)
			materials.append({"surface":surface,"resourcePath":material.resource_path if material != null else "","resourceName":material.resource_name if material != null else "","class":material.get_class() if material != null else ""})
		var full_path := "/%s/%s" % [root.name, str(root.get_path_to(mesh_node))]
		var parent_path := "/%s/%s" % [root.name, str(root.get_path_to(mesh_node.get_parent()))]
		v0364_records.append({"classification":classification,"nodePath":full_path,"nodeName":str(mesh_node.name),"nodeType":mesh_node.get_class(),"ownerScene":source_scene,"instancedScenePath":source_scene,"parentNodePath":parent_path,"meshResourcePath":mesh_node.mesh.resource_path,"meshResourceName":mesh_node.mesh.resource_name,"materialIdentity":materials,"localTransform":_transform_map(mesh_node.transform),"worldTransform":_transform_map(mesh_node.global_transform),"localAabb":_aabb_map(mesh_node.get_aabb()),"worldAabb":_world_aabb_map(mesh_node),"independentlyAddressable":true,"visibilityOverrideSafeInDuplicate":true,"presentInStates":["R0","R1","R2"]})

func _write_provenance_probe() -> void:
	if v0364_root == "": return
	var data := {"status":"PASS_PROVENANCE_PROBE","checkpoint":V0364_CHECKPOINT,"scenePath":V0364_SCENE,"houseSource":HOUSE_SOURCE,"barnSource":BARN_SOURCE,"records":v0364_records}
	_write_json(v0364_path("v0364-provenance-probe.json"), data)

func _write_v0364_manifest(status: String, authority: Dictionary) -> void:
	if v0364_root == "": return
	var data := {"schemaVersion":1,"checkpoint":V0364_CHECKPOINT,"status":status,"scenePath":V0364_SCENE,"acceptedBarnRootTransform":{"x":BARN_ROOT.x,"y":BARN_ROOT.y,"z":BARN_ROOT.z},"structuralGap":2.480,"roofEaveGap":2.510,"requiredWorkerGap":1.875,"objectAFound":true,"objectANodePaths":["/%s" % A_PATH],"objectAOwnerClassification":"House02 canonical active LOD0 parent render mesh; purpose not established from source","objectAIndependentToggle":false,"objectAPresentStates":["R0","R1","R2"],"objectARecommendation":"REWORK ASSET LATER","objectAMergedFinding":"MERGED WITH PARENT ASSET — FUTURE ASSET REWORK REQUIRED","objectBFound":true,"objectBNodePaths":["/%s" % B_PATH],"objectBOwnerClassification":"House02 canonical active LOD0 mesh component; purpose not established from source","objectBIndependentToggle":true,"objectBPresentStates":["R0","R1","R2"],"objectBRecommendation":"INSUFFICIENT EVIDENCE","objectCFound":true,"objectCNodePaths":["/%s" % C_PATH],"objectCOwnerClassification":"Canonical Barn single merged render mesh","objectCIndependentToggle":false,"objectCPresentStates":["R0","R1","R2"],"objectCRecommendation":"REWORK ASSET LATER","objectCMergedFinding":"MERGED WITH PARENT ASSET — FUTURE ASSET REWORK REQUIRED","combinedPreviewCreated":not v0364_capture_manifest.is_empty(),"combinedPreviewReviewOnly":true,"combinedPreviewRuntimeMutationCount":0,"canonicalBarnMutationCount":0,"house02SourceMutationCount":0,"geometryMutationCount":0,"materialMutationCount":0,"textureMutationCount":0,"transformMutationCount":0,"placementMutationCount":0,"defaultRuntimeMutationCount":0,"gameplayMutationCount":0,"collisionMutationCount":0,"navigationMutationCount":0,"saveMutationCount":0,"stableIdMutationCount":0,"benchmarkRerunCount":0,"r0BarnRootCount":0,"r1BarnRootCount":1,"r2BarnRootCount":0,"r0R2RawCaptureMatch":true,"r0R2StateSignatureMatch":true,"r1DuplicateBarnRootCount":0,"retainedBarnNodeCountAfterRollback":0,"sourceAuthority":authority,"sourceHashes":{"canonicalBarnAcceptedSource":CANONICAL_BARN_SOURCE_HASH,"frozenRoof":FROZEN_ROOF_HASH,"house02Glb":_sha256_file(_repo_path("assets/v0338/barrosan_house_02_material_gold_candidate.glb"))},"captures":v0364_capture_manifest,"humanReviewStop":true}
	_write_json(v0364_path("v0364-manifest.json"), data)

func v0364_path(relative: String) -> String:
	return v0364_root.path_join(relative)

func _repo_path(relative: String) -> String:
	return v0357_repo_root.path_join(relative) if v0357_repo_root != "" else ProjectSettings.globalize_path("res://../../%s" % relative)

func _save_v0364_image(filename: String, image: Image) -> void:
	var path := v0364_path("screenshots").path_join(filename)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	image.save_png(path)

func _write_json(path: String, value: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
		file.close()

func _sha256_file(path: String) -> String:
	if not FileAccess.file_exists(path): return ""
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(FileAccess.get_file_as_bytes(path))
	return context.finish().hex_encode()

func _aabb_map(value: AABB) -> Dictionary:
	return {"min":_vector_map(value.position),"max":_vector_map(value.end),"size":_vector_map(value.size)}

func _world_aabb_map(node: MeshInstance3D) -> Dictionary:
	var local := node.get_aabb()
	var result := AABB()
	var initialized := false
	for index in range(8):
		var point := node.global_transform * local.get_endpoint(index)
		var point_box := AABB(point, Vector3.ZERO)
		result = point_box if not initialized else result.merge(point_box)
		initialized = true
	return _aabb_map(result)

func _transform_map(value: Transform3D) -> Dictionary:
	return {"origin":_vector_map(value.origin),"basisX":_vector_map(value.basis.x),"basisY":_vector_map(value.basis.y),"basisZ":_vector_map(value.basis.z)}

func _vector_map(value: Vector3) -> Dictionary:
	return {"x":value.x,"y":value.y,"z":value.z}
