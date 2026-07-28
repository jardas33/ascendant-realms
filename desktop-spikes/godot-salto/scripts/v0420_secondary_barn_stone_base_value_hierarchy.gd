extends "res://scripts/v0419_secondary_barn_front_gable_value_integration.gd"

## v0.420 calibrates only the existing secondary-barn stone base/plinth surface.
## v0.417 walls, v0.418 openings and v0.419 front gable remain inherited.

const V0420_CHECKPOINT := "v0.420"
const V0420_CAPTURE_ROOT := "artifacts/runtime/v0420"
const V0420_LIMITATION := "ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_STONE_BASE"
const V0420_BASELINE := "50d8879dd12e1800bbd0835421483194f6103f1c"
const V0420_BARN_ROOT := "V0399_Barn_Structural_Readability"
const V0420_TARGET := "V0399_Barn_Stone_Base"
const V0420_CONTACT_SHADOW := "V0399_Barn_Contact_Shadow"

var v0420_capture_mode := false
var v0420_smoke_mode := false
var v0420_nodes: Array[MeshInstance3D] = []
var v0420_contact_shadow: MeshInstance3D
var v0420_classes: Dictionary = {}
var v0420_inventory: Array = []
var v0420_excluded_inventory: Array = []
var v0420_before_materials: Dictionary = {}
var v0420_after_materials: Dictionary = {}
var v0420_before_snapshots: Dictionary = {}
var v0420_after_snapshots: Dictionary = {}
var v0420_audit: Dictionary = {}

func _read_v0409_args() -> void:
	v0420_capture_mode = false
	v0420_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0420-secondary-barn-stone-base-capture":
			v0420_capture_mode = true
		if arg == "--v0420-secondary-barn-stone-base-smoke":
			v0420_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root:
		v0388_capture_root = V0420_CAPTURE_ROOT
	v0409_capture_mode = v0420_capture_mode
	v0409_smoke_mode = v0420_smoke_mode
	v0410_capture_mode = false
	v0410_smoke_mode = false
	v0411_capture_mode = v0420_capture_mode
	v0411_smoke_mode = v0420_smoke_mode
	v0415_capture_mode = false
	v0415_smoke_mode = false
	v0416_capture_mode = false
	v0416_smoke_mode = false
	v0417_capture_mode = false
	v0417_smoke_mode = false
	v0418_capture_mode = false
	v0418_smoke_mode = false
	v0419_capture_mode = false
	v0419_smoke_mode = false

func _v0409_apply_existing_material_treatment() -> void:
	_v0418_apply_existing_material_treatment()
	_v0419_apply_existing_material_treatment()
	_v0420_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0420_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0420_write_audit(root)
	var file := FileAccess.open(root.path_join("v0420-secondary-barn-stone-base-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0420_CHECKPOINT, "status": v0420_audit.get("status", V0420_LIMITATION), "candidateRetained": v0420_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "surfacesChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0420_apply_existing_material_treatment() -> void:
	v0420_nodes.clear()
	v0420_contact_shadow = null
	v0420_classes.clear()
	v0420_inventory.clear()
	v0420_excluded_inventory.clear()
	v0420_before_materials.clear()
	v0420_after_materials.clear()
	v0420_before_snapshots.clear()
	v0420_after_snapshots.clear()
	var barn := v0383_world.find_child(V0420_BARN_ROOT, true, false) as Node3D if v0383_world else null
	if barn == null:
		_v0420_fail_closed("accepted secondary-barn root missing")
		return
	var visible_base_names: Array[String] = []
	for candidate in barn.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var material_name := _v0414_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var key := str(node.name)
		var value := (key + " " + material_name + " " + mesh_name).to_lower()
		var entry := {"name": key, "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else ""}
		v0420_inventory.append(entry)
		var is_contact_shadow := key == V0420_CONTACT_SHADOW or value.contains("contact_shadow")
		if is_contact_shadow:
			if node.visible and node.mesh != null:
				v0420_contact_shadow = node
			v0420_excluded_inventory.append(entry)
			continue
		var is_base_surface := value.contains("base") or value.contains("foundation") or value.contains("footing") or value.contains("plinth") or value.contains("sill")
		if is_base_surface and node.visible and node.mesh != null:
			visible_base_names.append(key)
		if not node.visible or node.mesh == null:
			v0420_excluded_inventory.append(entry)
		elif key == V0420_TARGET:
			v0420_nodes.append(node)
			v0420_classes[key] = "BARN_STONE_BASE"
		else:
			v0420_excluded_inventory.append(entry)
	var unexpected := visible_base_names.filter(func(name): return name != V0420_TARGET)
	if v0420_nodes.size() != 1 or not v0420_classes.has(V0420_TARGET) or not visible_base_names.has(V0420_TARGET) or not unexpected.is_empty() or v0420_contact_shadow == null:
		_v0420_fail_closed("stone-base inventory mismatch; expected one isolated base and one excluded contact shadow")
		return
	var before_hashes := _v0414_house_hashes(barn)
	var mesh_count := _v0406_mesh_node_count()
	for node in v0420_nodes:
		v0420_before_materials[node.name] = node.material_override
		v0420_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var base := _v0420_material("V0420_Secondary_Barn_Stone_Base", Color("#514c45"), 0.98, 0.06)
	for node in v0420_nodes:
		node.material_override = base
		v0420_after_materials[node.name] = base
		v0420_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(barn)
	v0420_audit = {"baselineCommit": V0420_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0420_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_secondary_barn_stone_base_material_only", "affectedNodeCount": v0420_nodes.size(), "affectedNodeNames": v0420_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0420_inventory.filter(func(item): return str(item.name) == V0420_TARGET), "functionalClassification": v0420_classes, "excludedAdjacentInventory": v0420_excluded_inventory, "expectedInventory": [V0420_TARGET], "excludedContactShadow": V0420_CONTACT_SHADOW, "unexpectedVisibleBaseNames": unexpected, "originalMaterials": _v0414_material_inventory(v0420_before_materials), "finalMaterials": _v0414_material_inventory(v0420_after_materials), "finalMaterialParameters": ["stone base albedo=#514c45 roughness=0.98 specular=0.06"], "originalSnapshots": v0420_before_snapshots, "finalSnapshots": v0420_after_snapshots, "uvCountEveryAffectedMesh": _v0420_uv_inventory(), "worldHashesBefore": before_hashes, "worldHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "v0419Gable": "preserved", "v0418Openings": "preserved", "v0417WallBody": "preserved", "contactShadow": "preserved", "terrain": "preserved", "route": "preserved", "bridge": "preserved", "landings": "preserved", "mainHouse": "preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0419Audit": v0419_audit}

func _v0420_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = colour
	material.roughness = roughness
	material.specular = specular_value
	material.vertex_color_use_as_albedo = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _v0420_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0420_nodes:
		result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0420_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node:
			node.material_override = materials[key]

func _v0420_restore_before_materials() -> void:
	_v0419_restore_before_materials()
	_v0420_set_materials(v0420_before_materials)

func _v0420_restore_after_materials() -> void:
	_v0419_restore_after_materials()
	_v0420_set_materials(v0420_after_materials)

func _v0420_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_SECONDARY_BARN_STONE_BASE_CLOSE_COLOUR.png", Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_SECONDARY_BARN_STONE_BASE_CLOSE_GRAYSCALE.png"))
	_v0420_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2)
	_v0420_restore_after_materials()
	await _v0420_capture_diagnostic(root)
	_v0420_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0420_write_audit(root)
	get_tree().quit(0)

func _v0420_capture_diagnostic(root: String) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#17140f"))
	var node: MeshInstance3D = v0420_nodes[0] if not v0420_nodes.is_empty() else null
	if node == null:
		sheet.save_png(root.path_join("05_TEMPORARY_BARN_STONE_BASE_NODE_ID.png"))
		return
	var original_base := node.material_override
	var original_shadow := v0420_contact_shadow.material_override if v0420_contact_shadow else null
	var diagnostic_base := _v0420_material("V0420_Diagnostic_Base", Color("#d2b24b"), 1.0, 0.0)
	diagnostic_base.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var diagnostic_shadow := _v0420_material("V0420_Diagnostic_Contact_Shadow", Color("#456b78"), 1.0, 0.0)
	diagnostic_shadow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	node.material_override = diagnostic_base
	if v0420_contact_shadow:
		v0420_contact_shadow.material_override = diagnostic_shadow
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.color = Color(0.03, 0.025, 0.02, 0.92)
	panel.position = Vector2(12.0, 12.0)
	panel.size = Vector2(1250.0, 100.0)
	var label := Label.new()
	label.position = Vector2(10.0, 8.0)
	label.add_theme_font_size_override("font_size", 18)
	label.text = "v0.420 TEMPORARY BARN STONE BASE NODE ID\nBARN_STONE_BASE | " + V0420_TARGET + " | CONTACT SHADOW EXCLUDED: " + V0420_CONTACT_SHADOW
	panel.add_child(label)
	layer.add_child(panel)
	add_child(layer)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.convert(Image.FORMAT_RGBA8)
	if image.get_width() != 1920 or image.get_height() != 1080:
		image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	sheet.blit_rect(image, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
	layer.free()
	node.material_override = original_base
	if v0420_contact_shadow:
		v0420_contact_shadow.material_override = original_shadow
	sheet.save_png(root.path_join("05_TEMPORARY_BARN_STONE_BASE_NODE_ID.png"))

func _v0420_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_primary.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0419_V0420_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0419_V0420_BARN_BASE_CLOSE_COMPARISON.png"))

func _v0420_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0420-preservation-audit.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(v0420_audit, "  "))

func _v0420_fail_closed(reason: String) -> void:
	v0420_audit = {"baselineCommit": V0420_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0420_CHECKPOINT, "status": V0420_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0420_nodes.size(), "affectedNodeNames": v0420_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0420_inventory, "functionalClassification": v0420_classes, "excludedAdjacentInventory": v0420_excluded_inventory, "expectedInventory": [V0420_TARGET], "excludedContactShadow": V0420_CONTACT_SHADOW, "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0419Audit": v0419_audit}
