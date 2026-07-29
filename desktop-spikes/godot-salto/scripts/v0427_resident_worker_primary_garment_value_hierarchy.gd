extends "res://scripts/v0426_secondary_barn_contact_shadow_restraint_hierarchy.gd"

## v0.427 is a material-only, opt-in hierarchy pass for the resident worker.
## The imported Farmer scene, surface geometry, transform, grounding and pose stay frozen.

const V0427_CHECKPOINT := "v0.427"
const V0427_CAPTURE_ROOT := "artifacts/runtime/v0427"
const V0427_LIMITATION := "ASSET_MATERIAL_LIMITATION_RESIDENT_WORKER_PRIMARY_GARMENT"
const V0427_BASELINE := "a3c89a9677437ca39c613d946fb0bc0610b46b49"
const V0427_WORKER_ROOT := "V0389_Resident_Worker"
const V0427_WORKER_ASSET := "res://assets/third_party/quaternius/v0370/men/Farmer.gltf"
const V0427_ADMITTED_MATERIAL := "LightBlue"
const V0427_CLASSIFICATION := "RESIDENT_WORKER_PRIMARY_GARMENT"

var v0427_capture_mode := false
var v0427_smoke_mode := false
var v0427_admitted: Array = []
var v0427_excluded: Array = []
var v0427_before_overrides: Array = []
var v0427_after_overrides: Array = []
var v0427_audit: Dictionary = {}
var v0427_candidate_materials: Array[StandardMaterial3D] = []

func _read_v0409_args() -> void:
	super._read_v0409_args()
	v0426_capture_mode = false
	v0426_smoke_mode = false
	v0427_capture_mode = false
	v0427_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0427-resident-worker-primary-garment-capture": v0427_capture_mode = true
		if arg == "--v0427-resident-worker-primary-garment-smoke": v0427_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0427_CAPTURE_ROOT
	v0425_capture_mode = false
	v0425_smoke_mode = false
	v0424_capture_mode = false
	v0424_smoke_mode = false
	v0409_capture_mode = v0427_capture_mode
	v0409_smoke_mode = v0427_smoke_mode

func _v0409_apply_existing_material_treatment() -> void:
	super._v0409_apply_existing_material_treatment()
	_v0427_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0427_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0427_write_audit(root)
	var file := FileAccess.open(root.path_join("v0427-resident-worker-primary-garment-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0427_CHECKPOINT, "status": v0427_audit.get("status", V0427_LIMITATION), "candidateRetained": v0427_audit.get("candidateRetained", false), "materialOnly": true, "sourceAssetChanged": false, "geometryChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0427_apply_existing_material_treatment() -> void:
	v0427_admitted.clear()
	v0427_excluded.clear()
	v0427_before_overrides.clear()
	v0427_after_overrides.clear()
	v0427_candidate_materials.clear()
	v0427_audit.clear()
	var worker := v0383_world.find_child(V0427_WORKER_ROOT, true, false) as Node3D if v0383_world else null
	if worker == null:
		_v0427_fail_closed("resident-worker root missing")
		return
	var guard := v0383_world.find_child("V0389_Crossing_Guard", true, false) as Node3D
	var traveller := v0383_world.find_child("V0389_Traveller_Porter", true, false) as Node3D
	var worker_mesh_count := 0
	for candidate in worker.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		if node == null or not node.visible or node.mesh == null: continue
		worker_mesh_count += 1
		var surface_count := node.mesh.get_surface_count()
		for surface_index in range(surface_count):
			var original := _v0427_surface_material(node, surface_index)
			var name := _v0427_material_name(original)
			var entry := _v0427_surface_entry(node, surface_index, name, original)
			if name == V0427_ADMITTED_MATERIAL:
				if not original is StandardMaterial3D:
					_v0427_fail_closed("LightBlue surface is not a StandardMaterial3D: " + str(entry["path"]))
					return
				v0427_admitted.append(entry)
				var before := node.get_surface_override_material(surface_index)
				v0427_before_overrides.append({"node": node, "surface": surface_index, "material": before})
				var candidate_material := (original as StandardMaterial3D).duplicate() as StandardMaterial3D
				candidate_material.resource_name = "V0427_Resident_Worker_Primary_Garment"
				var original_albedo: Color = (original as StandardMaterial3D).albedo_color
				candidate_material.albedo_color = Color(0.310, 0.404, 0.439, original_albedo.a)
				candidate_material.roughness = 0.96
				candidate_material.specular = 0.08
				candidate_material.metallic = 0.00
				node.set_surface_override_material(surface_index, candidate_material)
				v0427_candidate_materials.append(candidate_material)
				v0427_after_overrides.append({"node": node, "surface": surface_index, "material": candidate_material})
			else:
				v0427_excluded.append(entry)
	if v0427_admitted.is_empty():
		_v0427_fail_closed("no visible LightBlue primary-garment surface exists")
		return
	v0427_audit = _v0427_build_audit(worker, guard, traveller, worker_mesh_count)

func _v0427_surface_material(node: MeshInstance3D, surface_index: int) -> Material:
	var override := node.get_surface_override_material(surface_index)
	if override != null: return override
	return node.mesh.surface_get_material(surface_index)

func _v0427_material_name(material: Material) -> String:
	if material == null: return ""
	return str(material.resource_name)

func _v0427_surface_entry(node: MeshInstance3D, surface_index: int, material_name: String, material: Material) -> Dictionary:
	var mesh := node.mesh
	return {"path": str(node.get_path()), "mesh": str(mesh.resource_name), "surfaceIndex": surface_index, "originalMaterial": material_name, "visible": node.visible, "meshType": str(mesh.get_class()), "surfaceCount": mesh.get_surface_count(), "uvCount": _v0414_uv_count(node), "vertexCount": _v0427_vertex_count(mesh), "indexCount": _v0427_index_count(mesh), "triangleCount": _v0427_triangle_count(mesh), "transform": str(node.transform), "aabb": str(node.get_aabb())}

func _v0427_vertex_count(mesh: Mesh) -> int:
	var count := 0
	for surface_index in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(surface_index)
		if arrays.size() > Mesh.ARRAY_VERTEX and arrays[Mesh.ARRAY_VERTEX] != null: count += arrays[Mesh.ARRAY_VERTEX].size()
	return count

func _v0427_index_count(mesh: Mesh) -> int:
	var count := 0
	for surface_index in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(surface_index)
		if arrays.size() > Mesh.ARRAY_INDEX and arrays[Mesh.ARRAY_INDEX] != null: count += arrays[Mesh.ARRAY_INDEX].size()
	return count

func _v0427_triangle_count(mesh: Mesh) -> int:
	return _v0427_index_count(mesh) / 3

func _v0427_material_state(material: Material) -> Dictionary:
	if material == null: return {"name": "", "missing": true}
	var state := {"name": _v0427_material_name(material)}
	for key in ["albedo_color", "albedo_texture", "transparency", "blend_mode", "shading_mode", "cull_mode", "roughness", "metallic", "specular", "vertex_color_use_as_albedo"]:
		state[key] = material.get(key)
	return state

func _v0427_build_audit(worker: Node3D, guard: Node3D, traveller: Node3D, worker_mesh_count: int) -> Dictionary:
	var excluded_names: Array[String] = []
	for entry in v0427_excluded:
		var name := str(entry["originalMaterial"])
		if not excluded_names.has(name): excluded_names.append(name)
	return {"baselineCommit": V0427_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0427_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "resident_worker_lightblue_primary_garment_surface_override_only", "workerRoot": V0427_WORKER_ROOT, "sourceAsset": V0427_WORKER_ASSET, "functionalClassification": V0427_CLASSIFICATION, "admittedSurfaceCount": v0427_admitted.size(), "admittedSurfaces": v0427_admitted, "excludedSurfaceCount": v0427_excluded.size(), "excludedAuthoredMaterials": excluded_names, "expectedExcludedMaterials": ["Skin", "Brown", "Beige", "Brown2", "Eyebrows", "Red", "Eye"], "guardExcluded": guard != null, "travellerExcluded": traveller != null, "workerMeshCount": worker_mesh_count, "workerTransform": str(worker.transform) if worker else "", "workerScale": str(worker.scale) if worker else "", "guardTransform": str(guard.transform) if guard else "", "travellerTransform": str(traveller.transform) if traveller else "", "originalMaterialStates": v0427_admitted.map(func(entry): return {"path": entry["path"], "surfaceIndex": entry["surfaceIndex"], "material": entry["originalMaterial"]}), "finalMaterial": "V0427_Resident_Worker_Primary_Garment", "candidateParameters": {"albedo": "#4f6770", "roughness": 0.96, "specular": 0.08, "metallic": 0.0, "alphaPreserved": true, "transparencyPreserved": true, "blendPreserved": true, "cullPreserved": true, "shadingPreserved": true, "vertexColourPreserved": true}, "materialOnly": true, "sourceAssetChanged": false, "geometryChanged": false, "topologyChanged": false, "verticesChanged": false, "indicesChanged": false, "normalsChanged": false, "tangentsChanged": false, "surfacesChanged": false, "uvArraysChanged": false, "skeletonChanged": false, "skinBindingChanged": false, "poseChanged": false, "animationChanged": false, "transformChanged": false, "groundingChanged": false, "otherCharactersChanged": false, "lightingChanged": false, "overlays": false, "decals": false, "emission": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "captureOnlyRestoration": "surface overrides restored before comparisons, audit completion and exit", "v0401Scale": 0.90, "v0401GroundingCorrection": -0.03}

func _v0427_restore_before_materials() -> void:
	for item in v0427_before_overrides:
		var node: MeshInstance3D = item["node"]
		node.set_surface_override_material(int(item["surface"]), item["material"] as Material)

func _v0427_restore_after_materials() -> void:
	for item in v0427_after_overrides:
		var node: MeshInstance3D = item["node"]
		node.set_surface_override_material(int(item["surface"]), item["material"] as Material)

func _v0427_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_RESIDENT_WORKER_GARMENT_CLOSE_COLOUR.png", Vector3(15.0, 16.0, 15.0), Vector3(-4.1, 1.00, 3.05), 8.6, root)
	var context := await _v0409_capture_view("03_THREE_CHARACTER_CONTEXT_COLOUR.png", Vector3(18.0, 22.0, 18.0), Vector3(-4.1, 0.90, 3.05), 12.0, root)
	var close_gray := close.duplicate(); close_gray.convert(Image.FORMAT_L8); close_gray.save_png(root.path_join("04_RESIDENT_WORKER_GARMENT_CLOSE_GRAYSCALE.png"))
	_v0427_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(15.0, 16.0, 15.0), Vector3(-4.1, 1.00, 3.05), 8.6)
	_v0427_restore_after_materials()
	await _v0427_capture_diagnostic(root)
	_v0427_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0427_write_audit(root)
	get_tree().quit(0)

func _v0427_capture_diagnostic(root: String) -> void:
	var original: Array = []
	var diagnostic := StandardMaterial3D.new()
	diagnostic.resource_name = "V0427_Diagnostic_Primary_Garment"
	diagnostic.albedo_color = Color("#d2b24b")
	diagnostic.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for item in v0427_admitted:
		var node := get_node_or_null(str(item["path"])) as MeshInstance3D
		if node == null: continue
		var surface_index := int(item["surfaceIndex"])
		original.append({"node": node, "surface": surface_index, "material": node.get_surface_override_material(surface_index)})
		node.set_surface_override_material(surface_index, diagnostic)
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.color = Color(0.03, 0.025, 0.02, 0.92)
	panel.position = Vector2(12.0, 12.0)
	panel.size = Vector2(1720.0, 210.0)
	var label := Label.new()
	label.position = Vector2(10.0, 8.0)
	label.add_theme_font_size_override("font_size", 18)
	var lines: Array[String] = ["v0.427 TEMPORARY RESIDENT WORKER GARMENT NODE ID", "ROOT: " + V0427_WORKER_ROOT, "SOURCE: " + V0427_WORKER_ASSET, "CLASSIFICATION: " + V0427_CLASSIFICATION, "ADMITTED MATERIAL: " + V0427_ADMITTED_MATERIAL, "EXCLUDED: Skin / Brown / Beige / Brown2 / Eyebrows / Red / Eye", "GUARD + TRAVELLER EXCLUDED; SCALE / GROUNDING / POSE / SOURCE PRESERVED"]
	label.text = "\n".join(lines)
	panel.add_child(label); layer.add_child(panel); add_child(layer)
	await get_tree().process_frame; await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image(); image.convert(Image.FORMAT_RGBA8)
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	layer.free()
	for item in original:
		var node: MeshInstance3D = item["node"]
		node.set_surface_override_material(int(item["surface"]), item["material"] as Material)
	image.save_png(root.path_join("05_TEMPORARY_RESIDENT_WORKER_GARMENT_NODE_ID.png"))

func _v0427_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_primary.convert(Image.FORMAT_RGBA8); primary.convert(Image.FORMAT_RGBA8)
		wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0426_V0427_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_close.convert(Image.FORMAT_RGBA8); close.convert(Image.FORMAT_RGBA8)
		near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0426_V0427_WORKER_CLOSE_COMPARISON.png"))

func _v0427_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0427-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0427_audit, "  "))

func _v0427_fail_closed(reason: String) -> void:
	v0427_audit = {"baselineCommit": V0427_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0427_CHECKPOINT, "status": V0427_LIMITATION, "candidateRetained": false, "reason": reason, "workerRoot": V0427_WORKER_ROOT, "sourceAsset": V0427_WORKER_ASSET, "functionalClassification": V0427_CLASSIFICATION, "admittedSurfaceCount": v0427_admitted.size(), "excludedSurfaceCount": v0427_excluded.size(), "materialOnly": true, "sourceAssetChanged": false, "geometryChanged": false, "topologyChanged": false, "verticesChanged": false, "indicesChanged": false, "normalsChanged": false, "tangentsChanged": false, "surfacesChanged": false, "uvArraysChanged": false, "skeletonChanged": false, "skinBindingChanged": false, "poseChanged": false, "animationChanged": false, "transformChanged": false, "groundingChanged": false, "otherCharactersChanged": false, "lightingChanged": false, "overlays": false, "decals": false, "emission": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}
