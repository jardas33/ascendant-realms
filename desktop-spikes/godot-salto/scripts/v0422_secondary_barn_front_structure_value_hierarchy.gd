extends "res://scripts/v0421_secondary_barn_entrance_frame_value_hierarchy.gd"

## v0.422 calibrates only the existing secondary-barn front beam and two outer posts.
## The accepted v0.421 entrance frame remains inherited and excluded.

const V0422_CHECKPOINT := "v0.422"
const V0422_CAPTURE_ROOT := "artifacts/runtime/v0422"
const V0422_LIMITATION := "ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_FRONT_STRUCTURE"
const V0422_BASELINE := "a99345e18816a298d8a004f9fea78b247dafb1af"
const V0422_BARN_ROOT := "V0399_Barn_Structural_Readability"
const V0422_BEAM := "V0399_Barn_Front_Beam"
const V0422_POST_LEFT := "V0399_Barn_Front_Post_-2_25"
const V0422_POST_RIGHT := "V0399_Barn_Front_Post_2_25"
const V0422_FRAME_LEFT := "V0399_Barn_Door_Left_Post"
const V0422_FRAME_RIGHT := "V0399_Barn_Door_Right_Post"
const V0422_FRAME_LINTEL := "V0399_Barn_Door_Lintel"

var v0422_capture_mode := false
var v0422_smoke_mode := false
var v0422_nodes: Array[MeshInstance3D] = []
var v0422_excluded_frame: Array[MeshInstance3D] = []
var v0422_classes: Dictionary = {}
var v0422_inventory: Array = []
var v0422_excluded_inventory: Array = []
var v0422_unexpected: Array[String] = []
var v0422_before_materials: Dictionary = {}
var v0422_after_materials: Dictionary = {}
var v0422_before_snapshots: Dictionary = {}
var v0422_after_snapshots: Dictionary = {}
var v0422_audit: Dictionary = {}

func _read_v0409_args() -> void:
	super._read_v0409_args()
	v0422_capture_mode = false
	v0422_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0422-secondary-barn-front-structure-capture":
			v0422_capture_mode = true
		if arg == "--v0422-secondary-barn-front-structure-smoke":
			v0422_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root:
		v0388_capture_root = V0422_CAPTURE_ROOT
	v0409_capture_mode = v0422_capture_mode
	v0409_smoke_mode = v0422_smoke_mode
	v0410_capture_mode = false
	v0410_smoke_mode = false
	v0411_capture_mode = false
	v0411_smoke_mode = false
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
	v0420_capture_mode = false
	v0420_smoke_mode = false
	v0421_capture_mode = false
	v0421_smoke_mode = false

func _v0409_apply_existing_material_treatment() -> void:
	_v0421_apply_existing_material_treatment()
	_v0422_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0422_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0422_write_audit(root)
	var file := FileAccess.open(root.path_join("v0422-secondary-barn-front-structure-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0422_CHECKPOINT, "status": v0422_audit.get("status", V0422_LIMITATION), "candidateRetained": v0422_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "surfacesChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0422_apply_existing_material_treatment() -> void:
	v0422_nodes.clear()
	v0422_excluded_frame.clear()
	v0422_classes.clear()
	v0422_inventory.clear()
	v0422_excluded_inventory.clear()
	v0422_unexpected.clear()
	v0422_before_materials.clear()
	v0422_after_materials.clear()
	v0422_before_snapshots.clear()
	v0422_after_snapshots.clear()
	var barn := v0383_world.find_child(V0422_BARN_ROOT, true, false) as Node3D if v0383_world else null
	if barn == null:
		_v0422_fail_closed("accepted secondary-barn root missing")
		return
	var expected := {V0422_BEAM: "BARN_FRONT_STRUCTURAL_BEAM", V0422_POST_LEFT: "BARN_FRONT_STRUCTURAL_POST", V0422_POST_RIGHT: "BARN_FRONT_STRUCTURAL_POST"}
	var excluded_frame := {V0422_FRAME_LEFT: true, V0422_FRAME_RIGHT: true, V0422_FRAME_LINTEL: true}
	for candidate in barn.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var key := str(node.name)
		var material_name := _v0414_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var value := (key + " " + material_name + " " + mesh_name).to_lower()
		var entry := {"name": key, "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else ""}
		v0422_inventory.append(entry)
		if excluded_frame.has(key):
			if node.visible and node.mesh != null:
				v0422_excluded_frame.append(node)
			v0422_excluded_inventory.append(entry)
			continue
		if expected.has(key):
			if node.visible and node.mesh != null:
				v0422_nodes.append(node)
				v0422_classes[key] = expected[key]
			else:
				_v0422_fail_closed("expected front-structure node is hidden or has no mesh: " + key)
				return
			continue
		var possible_front_structure := value.contains("front") and (value.contains("beam") or value.contains("post") or value.contains("brace") or value.contains("header") or value.contains("crossbeam"))
		if possible_front_structure and node.visible and node.mesh != null:
			v0422_unexpected.append(key)
			v0422_excluded_inventory.append(entry)
		else:
			v0422_excluded_inventory.append(entry)
	if v0422_nodes.size() != 3 or v0422_excluded_frame.size() != 3 or not v0422_unexpected.is_empty() or v0422_classes.size() != 3:
		_v0422_fail_closed("front-structure inventory mismatch; expected one beam, two outer posts and three excluded entrance-frame nodes")
		return
	var before_hashes := _v0414_house_hashes(barn)
	var mesh_count := _v0406_mesh_node_count()
	for node in v0422_nodes:
		v0422_before_materials[node.name] = node.material_override
		v0422_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var structure := _v0422_material("V0422_Secondary_Barn_Front_Structural_Timber", Color("#594636"), 0.97, 0.07)
	for node in v0422_nodes:
		node.material_override = structure
		v0422_after_materials[node.name] = structure
		v0422_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(barn)
	v0422_audit = {"baselineCommit": V0422_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0422_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_secondary_barn_front_structural_timber_material_only", "affectedNodeCount": v0422_nodes.size(), "affectedNodeNames": v0422_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0422_inventory.filter(func(item): return expected.has(str(item.name))), "functionalClassification": v0422_classes, "excludedAdjacentInventory": v0422_excluded_inventory, "expectedInventory": [V0422_BEAM, V0422_POST_LEFT, V0422_POST_RIGHT], "excludedEntranceFrameInventory": [V0422_FRAME_LEFT, V0422_FRAME_RIGHT, V0422_FRAME_LINTEL], "unexpectedVisibleFrontStructureNames": v0422_unexpected, "originalMaterials": _v0414_material_inventory(v0422_before_materials), "finalMaterials": _v0414_material_inventory(v0422_after_materials), "finalMaterialParameters": ["front structure albedo=#594636 roughness=0.97 specular=0.07"], "originalSnapshots": v0422_before_snapshots, "finalSnapshots": v0422_after_snapshots, "uvCountEveryAffectedMesh": _v0422_uv_inventory(), "worldHashesBefore": before_hashes, "worldHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "v0421EntranceFrame": "preserved", "v0420StoneBase": "preserved", "v0419Gable": "preserved", "v0418Openings": "preserved", "v0417WallBody": "preserved", "door": "preserved", "terrain": "preserved", "route": "preserved", "bridge": "preserved", "landings": "preserved", "mainHouse": "preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0421Audit": v0421_audit}

func _v0422_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = colour
	material.roughness = roughness
	material.specular = specular_value
	material.vertex_color_use_as_albedo = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _v0422_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0422_nodes:
		result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0422_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node:
			node.material_override = materials[key]

func _v0422_restore_before_materials() -> void:
	_v0421_restore_before_materials()
	_v0422_set_materials(v0422_before_materials)

func _v0422_restore_after_materials() -> void:
	_v0421_restore_after_materials()
	_v0422_set_materials(v0422_after_materials)

func _v0422_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_SECONDARY_BARN_FRONT_STRUCTURE_CLOSE_COLOUR.png", Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_SECONDARY_BARN_FRONT_STRUCTURE_CLOSE_GRAYSCALE.png"))
	_v0422_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2)
	_v0422_restore_after_materials()
	await _v0422_capture_diagnostic(root)
	_v0422_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0422_write_audit(root)
	get_tree().quit(0)

func _v0422_capture_diagnostic(root: String) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#17140f"))
	var original: Dictionary = {}
	var structure_material := _v0422_material("V0422_Diagnostic_Front_Structure", Color("#d2b24b"), 1.0, 0.0)
	structure_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var frame_material := _v0422_material("V0422_Diagnostic_Entrance_Frame", Color("#456b78"), 1.0, 0.0)
	frame_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for node in v0422_nodes:
		original[node.name] = node.material_override
		node.material_override = structure_material
	for node in v0422_excluded_frame:
		original[node.name] = node.material_override
		node.material_override = frame_material
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.color = Color(0.03, 0.025, 0.02, 0.92)
	panel.position = Vector2(12.0, 12.0)
	panel.size = Vector2(1500.0, 140.0)
	var label := Label.new()
	label.position = Vector2(10.0, 8.0)
	label.add_theme_font_size_override("font_size", 18)
	label.text = "v0.422 TEMPORARY BARN FRONT STRUCTURE NODE ID\nBEAM: " + V0422_BEAM + "\nPOSTS: " + V0422_POST_LEFT + " + " + V0422_POST_RIGHT + "\nENTRANCE FRAME EXCLUDED: " + V0422_FRAME_LEFT + " + " + V0422_FRAME_RIGHT + " + " + V0422_FRAME_LINTEL
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
	for node in v0422_nodes:
		node.material_override = original.get(node.name)
	for node in v0422_excluded_frame:
		node.material_override = original.get(node.name)
	sheet.save_png(root.path_join("05_TEMPORARY_BARN_FRONT_STRUCTURE_NODE_ID.png"))

func _v0422_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_primary.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0421_V0422_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0421_V0422_FRONT_STRUCTURE_CLOSE_COMPARISON.png"))

func _v0422_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0422-preservation-audit.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(v0422_audit, "  "))

func _v0422_fail_closed(reason: String) -> void:
	v0422_audit = {"baselineCommit": V0422_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0422_CHECKPOINT, "status": V0422_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0422_nodes.size(), "affectedNodeNames": v0422_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0422_inventory, "functionalClassification": v0422_classes, "excludedAdjacentInventory": v0422_excluded_inventory, "expectedInventory": [V0422_BEAM, V0422_POST_LEFT, V0422_POST_RIGHT], "excludedEntranceFrameInventory": [V0422_FRAME_LEFT, V0422_FRAME_RIGHT, V0422_FRAME_LINTEL], "unexpectedVisibleFrontStructureNames": v0422_unexpected, "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0421Audit": v0421_audit}
