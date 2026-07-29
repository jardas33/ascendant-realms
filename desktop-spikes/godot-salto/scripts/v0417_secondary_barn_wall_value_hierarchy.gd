extends "res://scripts/v0416_main_house_chimney_material_hierarchy.gd"

## v0.417 is an opt-in, material-only calibration of existing secondary-barn
## wall-body surfaces. The accepted roof, gable, doorway, and foundation remain unchanged.

const V0417_CHECKPOINT := "v0.417"
const V0417_CAPTURE_ROOT := "artifacts/runtime/v0417"
const V0417_LIMITATION := "ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_WALLS"
const V0417_BASELINE := "ca50f2a4ab547d0f9210cd59e378cbf0670a991d"
const V0417_BARN_ROOT := "V0399_Barn_Structural_Readability"

var v0417_capture_mode := false
var v0417_smoke_mode := false
var v0417_nodes: Array[MeshInstance3D] = []
var v0417_classes: Dictionary = {}
var v0417_excluded_inventory: Array = []
var v0417_before_materials: Dictionary = {}
var v0417_after_materials: Dictionary = {}
var v0417_before_snapshots: Dictionary = {}
var v0417_after_snapshots: Dictionary = {}
var v0417_audit: Dictionary = {}
var v0417_candidate_debug: Array = []

func _read_v0409_args() -> void:
	v0417_capture_mode = false; v0417_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0417-secondary-barn-walls-capture": v0417_capture_mode = true
		if arg == "--v0417-secondary-barn-walls-smoke": v0417_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true; v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0417_CAPTURE_ROOT
	v0409_capture_mode = v0417_capture_mode; v0409_smoke_mode = v0417_smoke_mode
	v0410_capture_mode = false; v0410_smoke_mode = false
	v0411_capture_mode = v0417_capture_mode; v0411_smoke_mode = v0417_smoke_mode
	v0415_capture_mode = false; v0415_smoke_mode = false
	v0416_capture_mode = false; v0416_smoke_mode = false

func _v0409_apply_existing_material_treatment() -> void:
	_v0414_apply_existing_material_treatment()
	_v0415_apply_existing_material_treatment()
	_v0416_apply_existing_material_treatment()
	_v0417_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame; await _v0417_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root); DirAccess.make_dir_recursive_absolute(root)
	_v0417_write_audit(root)
	var file := FileAccess.open(root.path_join("v0417-secondary-barn-walls-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0417_CHECKPOINT, "status": v0417_audit.get("status", V0417_LIMITATION), "candidateRetained": v0417_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "surfacesChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0417_apply_existing_material_treatment() -> void:
	v0417_nodes.clear(); v0417_classes.clear(); v0417_excluded_inventory.clear(); v0417_before_materials.clear(); v0417_after_materials.clear(); v0417_before_snapshots.clear(); v0417_after_snapshots.clear(); v0417_candidate_debug.clear()
	var barn := v0383_world.find_child(V0417_BARN_ROOT, true, false) as Node3D if v0383_world else null
	if barn == null:
		_v0417_fail_closed("accepted secondary-barn root missing"); return
	var inventory: Array = []
	for candidate in barn.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var material_name := _v0414_material_name(node.material_override); var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var entry := {"name": str(node.name), "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else ""}
		inventory.append(entry)
		var value := (str(node.name) + " " + material_name + " " + mesh_name).to_lower()
		if value.contains("barn") or str(node.name).to_lower().contains("wall"): v0417_candidate_debug.append(str(node.name))
		if node.mesh == null or not node.visible:
			v0417_excluded_inventory.append(entry); continue
		var role := _v0417_classify(value)
		if role == "BARN_WALL_BODY":
			v0417_nodes.append(node); v0417_classes[node.name] = role
		else: v0417_excluded_inventory.append(entry)
	if v0417_nodes.is_empty():
		_v0417_fail_closed("incomplete visible BARN_WALL_BODY inventory"); return
	var before_hashes := _v0414_house_hashes(barn); var mesh_count := _v0406_mesh_node_count()
	for node in v0417_nodes:
		v0417_before_materials[node.name] = node.material_override; v0417_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var wall := _v0417_material("V0417_Secondary_Barn_Wall_Body", Color("#5b5147"), 0.96, 0.08)
	for node in v0417_nodes:
		node.material_override = wall; v0417_after_materials[node.name] = wall; v0417_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(barn)
	v0417_audit = {"baselineCommit": V0417_BASELINE, "checkpoint": V0417_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_secondary_barn_wall_body_materials_only", "affectedNodeCount": v0417_nodes.size(), "affectedNodeNames": v0417_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": inventory.filter(func(item): return str(item.name) in v0417_classes), "functionalClassification": v0417_classes, "excludedAdjacentInventory": v0417_excluded_inventory, "candidateDebugNames": v0417_candidate_debug, "originalMaterials": _v0414_material_inventory(v0417_before_materials), "finalMaterials": _v0414_material_inventory(v0417_after_materials), "finalMaterialParameters": ["barn wall body albedo=#5b5147 roughness=0.96 specular=0.08"], "originalSnapshots": v0417_before_snapshots, "finalSnapshots": v0417_after_snapshots, "uvCountEveryAffectedMesh": _v0417_uv_inventory(), "worldHashesBefore": before_hashes, "worldHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "mainHouse": "preserved", "roofGableDoorFoundation": "preserved", "bridge": "v0412-preserved", "terrain": "preserved", "route": "preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0416Audit": v0416_audit}

func _v0417_classify(value: String) -> String:
	if value.contains("gable") or value.contains("roof") or value.contains("eave") or value.contains("door") or value.contains("window") or value.contains("post") or value.contains("beam") or value.contains("base") or value.contains("foundation") or value.contains("shadow"):
		return "EXCLUDED"
	if value.contains("v0399_barn_main_walls") or value.contains("barn_main_walls") or (value.contains("barn") and value.contains("wall") and not value.contains("gable")):
		return "BARN_WALL_BODY"
	return "EXCLUDED"

func _v0417_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.resource_name = name; material.albedo_color = colour; material.roughness = roughness; material.specular = specular_value; material.vertex_color_use_as_albedo = false; material.cull_mode = BaseMaterial3D.CULL_DISABLED; return material

func _v0417_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0417_nodes:
		result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0417_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node: node.material_override = materials[key]

func _v0417_restore_before_materials() -> void:
	_v0415_restore_before_materials(); _v0416_set_materials(v0416_before_materials); _v0417_set_materials(v0417_before_materials)

func _v0417_restore_after_materials() -> void:
	_v0415_restore_after_materials(); _v0416_set_materials(v0416_after_materials); _v0417_set_materials(v0417_after_materials)

func _v0417_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root); DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_SECONDARY_BARN_WALLS_CLOSE_COLOUR.png", Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2, root)
	var primary_gray := primary.duplicate(); primary_gray.convert(Image.FORMAT_L8); primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate(); close_gray.convert(Image.FORMAT_L8); close_gray.save_png(root.path_join("04_SECONDARY_BARN_WALLS_CLOSE_GRAYSCALE.png"))
	_v0417_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2)
	_v0417_restore_after_materials(); await _v0417_capture_diagnostic(root); _v0417_write_comparisons(primary, close, baseline_primary, baseline_close, root); _v0417_write_audit(root); get_tree().quit(0)

func _v0417_capture_diagnostic(root: String) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8); sheet.fill(Color("#17140f")); var colours := [Color("#d2b24b"), Color("#4b86d5"), Color("#6fbf67"), Color("#c65b3c")]; var columns := 2; var rows := maxi(1, ceili(float(v0417_nodes.size()) / float(columns))); var tile_width := 1920 / columns; var tile_height := 1080 / rows
	if v0417_nodes.is_empty():
		await RenderingServer.frame_post_draw; var evidence := get_viewport().get_texture().get_image(); evidence.convert(Image.FORMAT_RGBA8); if evidence.get_width() != 1920 or evidence.get_height() != 1080: evidence.resize(1920, 1080, Image.INTERPOLATE_LANCZOS); sheet.blit_rect(evidence, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); sheet.save_png(root.path_join("05_TEMPORARY_BARN_WALL_NODE_ID.png")); return
	for index in v0417_nodes.size():
		var node: MeshInstance3D = v0417_nodes[index]; var original := node.material_override; var diagnostic_material := StandardMaterial3D.new(); diagnostic_material.albedo_color = colours[index % colours.size()]; diagnostic_material.vertex_color_use_as_albedo = false; diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; node.material_override = diagnostic_material
		var layer := CanvasLayer.new(); var panel := ColorRect.new(); panel.color = Color(0.03, 0.025, 0.02, 0.92); panel.position = Vector2(12.0, 12.0); panel.size = Vector2(900.0, 84.0); var label := Label.new(); label.position = Vector2(10.0, 8.0); label.add_theme_font_size_override("font_size", 18); label.text = "v0.417 TEMPORARY BARN WALL NODE ID\nBARN_WALL_BODY | " + str(node.name) + " | existing node only"; panel.add_child(label); layer.add_child(panel); add_child(layer)
		await get_tree().process_frame; await RenderingServer.frame_post_draw; var image := get_viewport().get_texture().get_image(); image.convert(Image.FORMAT_RGBA8); image.resize(tile_width, tile_height, Image.INTERPOLATE_LANCZOS); sheet.blit_rect(image, Rect2i(0, 0, tile_width, tile_height), Vector2i((index % columns) * tile_width, (index / columns) * tile_height)); layer.free(); node.material_override = original
	sheet.save_png(root.path_join("05_TEMPORARY_BARN_WALL_NODE_ID.png"))

func _v0417_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_primary.convert(Image.FORMAT_RGBA8); primary.convert(Image.FORMAT_RGBA8); wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); wide.save_png(root.path_join("06_V0416_V0417_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_close.convert(Image.FORMAT_RGBA8); close.convert(Image.FORMAT_RGBA8); near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); near.save_png(root.path_join("07_V0416_V0417_BARN_CLOSE_COMPARISON.png"))

func _v0417_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0417-preservation-audit.json"), FileAccess.WRITE); if file: file.store_string(JSON.stringify(v0417_audit, "  "))

func _v0417_fail_closed(reason: String) -> void:
	v0417_audit = {"baselineCommit": V0417_BASELINE, "checkpoint": V0417_CHECKPOINT, "status": V0417_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0417_nodes.size(), "affectedNodeNames": v0417_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0417_excluded_inventory, "functionalClassification": v0417_classes, "excludedAdjacentInventory": v0417_excluded_inventory, "candidateDebugNames": v0417_candidate_debug, "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0416Audit": v0416_audit}
