extends "res://scripts/v0418_secondary_barn_openings_value_hierarchy.gd"

## v0.419 calibrates only the existing secondary-barn front-gable surface.
## v0.417 wall and v0.418 opening materials remain applied and unchanged.

const V0419_CHECKPOINT := "v0.419"
const V0419_CAPTURE_ROOT := "artifacts/runtime/v0419"
const V0419_LIMITATION := "ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_FRONT_GABLE"
const V0419_BASELINE := "99f8ca689b8eac75e4f80c3c2e3c7b729e78da42"
const V0419_BARN_ROOT := "V0399_Barn_Structural_Readability"
const V0419_TARGET := "V0399_Barn_Front_Gable"

var v0419_capture_mode := false
var v0419_smoke_mode := false
var v0419_nodes: Array[MeshInstance3D] = []
var v0419_classes: Dictionary = {}
var v0419_inventory: Array = []
var v0419_excluded_inventory: Array = []
var v0419_before_materials: Dictionary = {}
var v0419_after_materials: Dictionary = {}
var v0419_before_snapshots: Dictionary = {}
var v0419_after_snapshots: Dictionary = {}
var v0419_audit: Dictionary = {}

func _read_v0409_args() -> void:
	v0419_capture_mode = false; v0419_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0419-secondary-barn-front-gable-capture": v0419_capture_mode = true
		if arg == "--v0419-secondary-barn-front-gable-smoke": v0419_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true; v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0419_CAPTURE_ROOT
	v0409_capture_mode = v0419_capture_mode; v0409_smoke_mode = v0419_smoke_mode
	v0410_capture_mode = false; v0410_smoke_mode = false
	v0411_capture_mode = v0419_capture_mode; v0411_smoke_mode = v0419_smoke_mode
	v0415_capture_mode = false; v0415_smoke_mode = false
	v0416_capture_mode = false; v0416_smoke_mode = false
	v0417_capture_mode = false; v0417_smoke_mode = false
	v0418_capture_mode = false; v0418_smoke_mode = false

func _v0409_apply_existing_material_treatment() -> void:
	_v0418_apply_existing_material_treatment()
	_v0419_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame; await _v0419_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root); DirAccess.make_dir_recursive_absolute(root)
	_v0419_write_audit(root)
	var file := FileAccess.open(root.path_join("v0419-secondary-barn-front-gable-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0419_CHECKPOINT, "status": v0419_audit.get("status", V0419_LIMITATION), "candidateRetained": v0419_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "surfacesChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0419_apply_existing_material_treatment() -> void:
	v0419_nodes.clear(); v0419_classes.clear(); v0419_inventory.clear(); v0419_excluded_inventory.clear(); v0419_before_materials.clear(); v0419_after_materials.clear(); v0419_before_snapshots.clear(); v0419_after_snapshots.clear()
	var barn := v0383_world.find_child(V0419_BARN_ROOT, true, false) as Node3D if v0383_world else null
	if barn == null: _v0419_fail_closed("accepted secondary-barn root missing"); return
	var visible_gable_names: Array[String] = []
	for candidate in barn.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var material_name := _v0414_material_name(node.material_override); var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var entry := {"name": str(node.name), "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else ""}
		v0419_inventory.append(entry)
		var key := str(node.name); var value := (key + " " + material_name + " " + mesh_name).to_lower()
		var is_gable_surface := value.contains("gable") or value.contains("pediment") or value.contains("triangle")
		if is_gable_surface: visible_gable_names.append(key)
		if not node.visible or node.mesh == null: v0419_excluded_inventory.append(entry); continue
		if key == V0419_TARGET:
			v0419_nodes.append(node); v0419_classes[key] = "BARN_FRONT_GABLE"
		else: v0419_excluded_inventory.append(entry)
	var unexpected := visible_gable_names.filter(func(name): return name != V0419_TARGET)
	if v0419_nodes.size() != 1 or not v0419_classes.has(V0419_TARGET) or not visible_gable_names.has(V0419_TARGET) or not unexpected.is_empty():
		_v0419_fail_closed("front-gable inventory mismatch; expected one isolated visible gable surface")
		return
	var before_hashes := _v0414_house_hashes(barn); var mesh_count := _v0406_mesh_node_count()
	for node in v0419_nodes:
		v0419_before_materials[node.name] = node.material_override; v0419_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var gable := _v0419_material("V0419_Secondary_Barn_Front_Gable", Color("#675d52"), 0.97, 0.07)
	for node in v0419_nodes:
		node.material_override = gable; v0419_after_materials[node.name] = gable; v0419_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(barn)
	v0419_audit = {"baselineCommit": V0419_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0419_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_secondary_barn_front_gable_material_only", "affectedNodeCount": v0419_nodes.size(), "affectedNodeNames": v0419_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0419_inventory.filter(func(item): return str(item.name) == V0419_TARGET), "functionalClassification": v0419_classes, "excludedAdjacentInventory": v0419_excluded_inventory, "expectedInventory": [V0419_TARGET], "unexpectedVisibleGableNames": unexpected, "originalMaterials": _v0414_material_inventory(v0419_before_materials), "finalMaterials": _v0414_material_inventory(v0419_after_materials), "finalMaterialParameters": ["front gable albedo=#675d52 roughness=0.97 specular=0.07"], "originalSnapshots": v0419_before_snapshots, "finalSnapshots": v0419_after_snapshots, "uvCountEveryAffectedMesh": _v0419_uv_inventory(), "worldHashesBefore": before_hashes, "worldHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "v0418Openings": "preserved", "v0417WallBody": "preserved", "roof": "preserved", "ridge": "preserved", "eaves": "preserved", "frames": "preserved", "foundation": "preserved", "terrain": "preserved", "route": "preserved", "bridge": "preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0418Audit": v0418_audit}

func _v0419_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.resource_name = name; material.albedo_color = colour; material.roughness = roughness; material.specular = specular_value; material.vertex_color_use_as_albedo = false; material.cull_mode = BaseMaterial3D.CULL_DISABLED; return material

func _v0419_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0419_nodes:
		result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0419_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node: node.material_override = materials[key]

func _v0419_restore_before_materials() -> void:
	_v0418_restore_before_materials(); _v0419_set_materials(v0419_before_materials)

func _v0419_restore_after_materials() -> void:
	_v0418_restore_after_materials(); _v0419_set_materials(v0419_after_materials)

func _v0419_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root); DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_SECONDARY_BARN_FRONT_GABLE_CLOSE_COLOUR.png", Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2, root)
	var primary_gray := primary.duplicate(); primary_gray.convert(Image.FORMAT_L8); primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate(); close_gray.convert(Image.FORMAT_L8); close_gray.save_png(root.path_join("04_SECONDARY_BARN_FRONT_GABLE_CLOSE_GRAYSCALE.png"))
	_v0419_restore_before_materials(); var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0); var baseline_close := await _v0409_capture_image(Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2); _v0419_restore_after_materials()
	await _v0419_capture_diagnostic(root); _v0419_write_comparisons(primary, close, baseline_primary, baseline_close, root); _v0419_write_audit(root); get_tree().quit(0)

func _v0419_capture_diagnostic(root: String) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8); sheet.fill(Color("#17140f")); var node: MeshInstance3D = v0419_nodes[0] if not v0419_nodes.is_empty() else null
	if node == null: sheet.save_png(root.path_join("05_TEMPORARY_BARN_FRONT_GABLE_NODE_ID.png")); return
	var original := node.material_override; var diagnostic_material := StandardMaterial3D.new(); diagnostic_material.albedo_color = Color("#d2b24b"); diagnostic_material.vertex_color_use_as_albedo = false; diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; node.material_override = diagnostic_material
	var layer := CanvasLayer.new(); var panel := ColorRect.new(); panel.color = Color(0.03, 0.025, 0.02, 0.92); panel.position = Vector2(12.0, 12.0); panel.size = Vector2(1150.0, 92.0); var label := Label.new(); label.position = Vector2(10.0, 8.0); label.add_theme_font_size_override("font_size", 18); label.text = "v0.419 TEMPORARY BARN FRONT GABLE NODE ID\nBARN_FRONT_GABLE | " + V0419_TARGET + " | existing surface only"; panel.add_child(label); layer.add_child(panel); add_child(layer)
	await get_tree().process_frame; await RenderingServer.frame_post_draw; var image := get_viewport().get_texture().get_image(); image.convert(Image.FORMAT_RGBA8); if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS); sheet.blit_rect(image, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); layer.free(); node.material_override = original; sheet.save_png(root.path_join("05_TEMPORARY_BARN_FRONT_GABLE_NODE_ID.png"))

func _v0419_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920: var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_primary.convert(Image.FORMAT_RGBA8); primary.convert(Image.FORMAT_RGBA8); wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); wide.save_png(root.path_join("06_V0418_V0419_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920: var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_close.convert(Image.FORMAT_RGBA8); close.convert(Image.FORMAT_RGBA8); near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); near.save_png(root.path_join("07_V0418_V0419_BARN_CLOSE_COMPARISON.png"))

func _v0419_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0419-preservation-audit.json"), FileAccess.WRITE); if file: file.store_string(JSON.stringify(v0419_audit, "  "))

func _v0419_fail_closed(reason: String) -> void:
	v0419_audit = {"baselineCommit": V0419_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0419_CHECKPOINT, "status": V0419_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0419_nodes.size(), "affectedNodeNames": v0419_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0419_inventory, "functionalClassification": v0419_classes, "excludedAdjacentInventory": v0419_excluded_inventory, "expectedInventory": [V0419_TARGET], "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0418Audit": v0418_audit}
