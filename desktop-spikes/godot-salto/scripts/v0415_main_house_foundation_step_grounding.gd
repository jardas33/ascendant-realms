extends "res://scripts/v0414_main_house_openings_trim_value_hierarchy.gd"

## v0.415 is an opt-in, material-only grounding calibration for existing main-house
## foundation/plinth and entry-step/threshold nodes. v0.414 openings/trim and all
## accepted adjacent visual/runtime contracts remain authoritative.

const V0415_CHECKPOINT := "v0.415"
const V0415_CAPTURE_ROOT := "artifacts/runtime/v0415"
const V0415_LIMITATION := "ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_FOUNDATION_STEPS"
const V0415_BASELINE := "25990fcc63513cacb08dc7b1310b418f58d92bf2"
const V0415_HOUSE_NAME := "V0394_One_Primary_Barrosan_Homestead"

var v0415_capture_mode := false
var v0415_smoke_mode := false
var v0415_nodes: Array[MeshInstance3D] = []
var v0415_classes: Dictionary = {}
var v0415_excluded_inventory: Array = []
var v0415_before_materials: Dictionary = {}
var v0415_after_materials: Dictionary = {}
var v0415_before_snapshots: Dictionary = {}
var v0415_after_snapshots: Dictionary = {}
var v0415_audit: Dictionary = {}
var v0415_candidate_debug: Array = []

func _read_v0409_args() -> void:

	v0415_capture_mode = false
	v0415_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0415-main-house-foundation-step-capture": v0415_capture_mode = true
		if arg == "--v0415-main-house-foundation-step-smoke": v0415_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0415_CAPTURE_ROOT
	v0409_capture_mode = v0415_capture_mode
	v0409_smoke_mode = v0415_smoke_mode
	v0410_capture_mode = false
	v0410_smoke_mode = false
	v0411_capture_mode = v0415_capture_mode
	v0411_smoke_mode = v0415_smoke_mode

func _v0409_apply_existing_material_treatment() -> void:
	super._v0409_apply_existing_material_treatment()
	_v0415_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0415_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0415_write_audit(root)
	var file := FileAccess.open(root.path_join("v0415-main-house-foundation-step-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0415_CHECKPOINT, "status": v0415_audit.get("status", V0415_LIMITATION), "candidateRetained": v0415_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "surfacesChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0415_apply_existing_material_treatment() -> void:
	v0415_nodes.clear(); v0415_classes.clear(); v0415_excluded_inventory.clear(); v0415_before_materials.clear(); v0415_after_materials.clear(); v0415_before_snapshots.clear(); v0415_after_snapshots.clear(); v0415_candidate_debug.clear()
	var house := v0383_world.find_child(V0415_HOUSE_NAME, true, false) as Node3D if v0383_world else null
	if house == null:
		_v0415_fail_closed("accepted main-house root missing")
		return
	v0400_house = house
	var inventory: Array = []
	var candidates: Array = []
	_v0415_collect_meshes(house, candidates)
	_v0415_collect_meshes(v0383_world, candidates)
	for entry in v0414_excluded_inventory:
		var entry_name := str(entry.get("name", ""))
		if entry_name.to_lower().contains("foundation"):
			var recovered := house.find_child(entry_name, true, false) as MeshInstance3D
			if recovered and not candidates.has(recovered): candidates.append(recovered)
	for candidate in candidates:
		var node := candidate as MeshInstance3D
		var candidate_lower := str(node.name).to_lower()
		if candidate_lower.contains("foundation") or candidate_lower.contains("threshold") or candidate_lower.contains("step") or candidate_lower.contains("stair"): v0415_candidate_debug.append(str(node.name))
		var material_name := _v0414_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var entry := {"name": str(node.name), "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else ""}
		inventory.append(entry)
		if node.mesh == null or not node.visible:
			v0415_excluded_inventory.append(entry)
			continue
		var role := _v0415_classify(node, house, material_name, mesh_name)
		if role == "FOUNDATION_OR_PLINTH" or role == "ENTRY_STEP_OR_THRESHOLD":
			v0415_nodes.append(node); v0415_classes[node.name] = role
		else:
			v0415_excluded_inventory.append(entry)
	if v0415_nodes.is_empty() or not _v0415_has_all_roles():
		_v0415_fail_closed("incomplete visible FOUNDATION_OR_PLINTH/ENTRY_STEP_OR_THRESHOLD inventory")
		return
	var before_hashes := _v0414_house_hashes(v0383_world)
	var mesh_count := _v0406_mesh_node_count()
	for node in v0415_nodes:
		v0415_before_materials[node.name] = node.material_override
		v0415_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var foundation := _v0415_material("V0415_Main_House_Foundation", Color("#69645b"), 0.98, 0.08)
	var steps := _v0415_material("V0415_Main_House_Entry_Steps", Color("#77766c"), 0.98, 0.10)
	for node in v0415_nodes:
		var material: StandardMaterial3D = foundation if v0415_classes[node.name] == "FOUNDATION_OR_PLINTH" else steps
		node.material_override = material
		v0415_after_materials[node.name] = material
		v0415_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(v0383_world)
	v0415_audit = {"baselineCommit": V0415_BASELINE, "checkpoint": V0415_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_main_house_foundation_plinth_and_entry_step_threshold_materials_only", "affectedNodeCount": v0415_nodes.size(), "affectedNodeNames": v0415_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": inventory.filter(func(item): return str(item.name) in v0415_classes), "functionalClassification": v0415_classes, "excludedAdjacentInventory": v0415_excluded_inventory, "originalMaterials": _v0414_material_inventory(v0415_before_materials), "finalMaterials": _v0414_material_inventory(v0415_after_materials), "finalMaterialParameters": ["foundation albedo=#69645b roughness=0.98 specular=0.08", "entry steps albedo=#77766c roughness=0.98 specular=0.10"], "originalSnapshots": v0415_before_snapshots, "finalSnapshots": v0415_after_snapshots, "uvCountEveryAffectedMesh": _v0415_uv_inventory(), "inheritedVertexColourBeforeAfter": "unchanged", "worldHashesBefore": before_hashes, "worldHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "masonry": "v0413-preserved", "roof": "v0408-preserved", "doorsWindowsTimber": "v0414-preserved", "terrain": "preserved", "route": "preserved", "bridge": "v0412-preserved", "landings": "preserved", "barn": "v0409-preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0414Audit": v0414_audit}

func _v0415_classify(node: MeshInstance3D, house: Node3D, material_name: String, mesh_name: String) -> String:
	var value := (str(node.name) + " " + material_name + " " + mesh_name).to_lower()
	var house_node := house.is_ancestor_of(node)
	if value.contains("collision") or value.contains("roof") or value.contains("ridge") or value.contains("eave") or value.contains("chimney") or value.contains("granite") or value.contains("door") or value.contains("window") or value.contains("timber") or value.contains("iron"):
		return "EXCLUDED"
	if (house_node or value.contains("lod")) and (value.contains("foundation") or value.contains("plinth")):
		return "FOUNDATION_OR_PLINTH"
	if not value.contains("barn") and not value.contains("bridge") and not value.contains("terrain") and not value.contains("ground") and (value.contains("threshold") or value.contains("entry_step") or value.contains("entrance_step") or value.contains("stair") or value.contains("step")):
		return "ENTRY_STEP_OR_THRESHOLD"
	return "EXCLUDED"

func _v0415_collect_meshes(root: Node, result: Array) -> void:
	for child in root.get_children():
		if child is MeshInstance3D and not result.has(child): result.append(child)
		_v0415_collect_meshes(child, result)

func _v0415_has_all_roles() -> bool:
	return v0415_classes.values().has("FOUNDATION_OR_PLINTH") and v0415_classes.values().has("ENTRY_STEP_OR_THRESHOLD")

func _v0415_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.resource_name = name; material.albedo_color = colour; material.roughness = roughness; material.specular = specular_value; material.vertex_color_use_as_albedo = false; material.cull_mode = BaseMaterial3D.CULL_DISABLED; return material

func _v0415_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0415_nodes: result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0415_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node: node.material_override = materials[key]

func _v0415_restore_before_materials() -> void:
	_v0414_set_materials(v0414_before_materials)
	_v0415_set_materials(v0415_before_materials)

func _v0415_restore_after_materials() -> void:
	_v0414_set_materials(v0414_after_materials)
	_v0415_set_materials(v0415_after_materials)

func _v0415_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root); DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_MAIN_HOUSE_FOUNDATION_STEPS_CLOSE_COLOUR.png", Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5, root)
	var primary_gray := primary.duplicate(); primary_gray.convert(Image.FORMAT_L8); primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate(); close_gray.convert(Image.FORMAT_L8); close_gray.save_png(root.path_join("04_MAIN_HOUSE_FOUNDATION_STEPS_CLOSE_GRAYSCALE.png"))
	_v0415_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5)
	_v0415_restore_after_materials()
	await _v0415_capture_diagnostic(root)
	_v0415_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0415_write_audit(root); get_tree().quit(0)

func _v0415_capture_diagnostic(root: String) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8); sheet.fill(Color("#17140f")); var colours := [Color("#d2b24b"), Color("#4b86d5"), Color("#6fbf67"), Color("#c65b3c")]; var columns := 2; var rows := maxi(1, ceili(float(v0415_nodes.size()) / float(columns))); var tile_width := 1920 / columns; var tile_height := 1080 / rows
	if v0415_nodes.is_empty():
		await RenderingServer.frame_post_draw
		var evidence := get_viewport().get_texture().get_image()
		evidence.convert(Image.FORMAT_RGBA8)
		if evidence.get_width() != 1920 or evidence.get_height() != 1080: evidence.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(evidence, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		sheet.save_png(root.path_join("05_TEMPORARY_FOUNDATION_STEP_NODE_ID.png"))
		return
	for index in v0415_nodes.size():
		var node: MeshInstance3D = v0415_nodes[index]; var original := node.material_override; var diagnostic_material := StandardMaterial3D.new(); diagnostic_material.albedo_color = colours[index % colours.size()]; diagnostic_material.vertex_color_use_as_albedo = false; diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; node.material_override = diagnostic_material
		var layer := CanvasLayer.new(); var panel := ColorRect.new(); panel.color = Color(0.03, 0.025, 0.02, 0.92); panel.position = Vector2(12.0, 12.0); panel.size = Vector2(900.0, 84.0); var label := Label.new(); label.position = Vector2(10.0, 8.0); label.add_theme_font_size_override("font_size", 18); label.text = "v0.415 TEMPORARY FOUNDATION/STEP NODE ID\n" + str(v0415_classes[node.name]) + " | " + str(node.name) + " | existing node only"; panel.add_child(label); layer.add_child(panel); add_child(layer)
		await get_tree().process_frame; await RenderingServer.frame_post_draw; var image := get_viewport().get_texture().get_image(); image.convert(Image.FORMAT_RGBA8); image.resize(tile_width, tile_height, Image.INTERPOLATE_LANCZOS); sheet.blit_rect(image, Rect2i(0, 0, tile_width, tile_height), Vector2i((index % columns) * tile_width, (index / columns) * tile_height)); layer.free(); node.material_override = original
	sheet.save_png(root.path_join("05_TEMPORARY_FOUNDATION_STEP_NODE_ID.png"))

func _v0415_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_primary.convert(Image.FORMAT_RGBA8); primary.convert(Image.FORMAT_RGBA8); wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); wide.save_png(root.path_join("06_V0414_V0415_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_close.convert(Image.FORMAT_RGBA8); close.convert(Image.FORMAT_RGBA8); near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); near.save_png(root.path_join("07_V0414_V0415_FOUNDATION_CLOSE_COMPARISON.png"))

func _v0415_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0415-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0415_audit, "  "))

func _v0415_fail_closed(reason: String) -> void:
	var partial_inventory: Array = []
	for node in v0415_nodes:
		partial_inventory.append({"name": str(node.name), "visible": node.visible, "material": _v0414_material_name(node.material_override), "mesh": str(node.mesh.resource_name) if node.mesh else "", "uvCount": _v0414_uv_count(node)})
	v0415_audit = {"baselineCommit": V0415_BASELINE, "checkpoint": V0415_CHECKPOINT, "status": V0415_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0415_nodes.size(), "affectedNodeNames": v0415_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": partial_inventory, "functionalClassification": v0415_classes, "excludedAdjacentInventory": v0415_excluded_inventory, "parentFoundationInventory": v0414_excluded_inventory.filter(func(item): return str(item.get("name", "")).to_lower().contains("foundation")), "candidateDebugNames": v0415_candidate_debug, "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "inheritedVertexColourChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}
