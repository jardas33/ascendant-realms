extends "res://scripts/v0420_secondary_barn_stone_base_value_hierarchy.gd"

## v0.421 calibrates only the existing three-piece secondary-barn entrance frame.
## The accepted v0.418 door leaf and v0.420 stone base remain unchanged.

const V0421_CHECKPOINT := "v0.421"
const V0421_CAPTURE_ROOT := "artifacts/runtime/v0421"
const V0421_LIMITATION := "ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_ENTRANCE_FRAME"
const V0421_BASELINE := "de4e5c25d9e42d5d4cf2c7358741a961ffd3f468"
const V0421_BARN_ROOT := "V0399_Barn_Structural_Readability"
const V0421_DOOR := "V0399_Barn_Entrance_Door"
const V0421_POST_LEFT := "V0399_Barn_Door_Left_Post"
const V0421_POST_RIGHT := "V0399_Barn_Door_Right_Post"
const V0421_LINTEL := "V0399_Barn_Door_Lintel"

var v0421_capture_mode := false
var v0421_smoke_mode := false
var v0421_nodes: Array[MeshInstance3D] = []
var v0421_door: MeshInstance3D
var v0421_classes: Dictionary = {}
var v0421_inventory: Array = []
var v0421_excluded_inventory: Array = []
var v0421_unexpected: Array[String] = []
var v0421_before_materials: Dictionary = {}
var v0421_after_materials: Dictionary = {}
var v0421_before_snapshots: Dictionary = {}
var v0421_after_snapshots: Dictionary = {}
var v0421_audit: Dictionary = {}

func _read_v0409_args() -> void:
	super._read_v0409_args()
	v0421_capture_mode = false
	v0421_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0421-secondary-barn-entrance-frame-capture":
			v0421_capture_mode = true
		if arg == "--v0421-secondary-barn-entrance-frame-smoke":
			v0421_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root:
		v0388_capture_root = V0421_CAPTURE_ROOT
	v0409_capture_mode = v0421_capture_mode
	v0409_smoke_mode = v0421_smoke_mode
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

func _v0409_apply_existing_material_treatment() -> void:
	_v0420_apply_existing_material_treatment()
	_v0421_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0421_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0421_write_audit(root)
	var file := FileAccess.open(root.path_join("v0421-secondary-barn-entrance-frame-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0421_CHECKPOINT, "status": v0421_audit.get("status", V0421_LIMITATION), "candidateRetained": v0421_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "surfacesChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0421_apply_existing_material_treatment() -> void:
	v0421_nodes.clear()
	v0421_door = null
	v0421_classes.clear()
	v0421_inventory.clear()
	v0421_excluded_inventory.clear()
	v0421_unexpected.clear()
	v0421_before_materials.clear()
	v0421_after_materials.clear()
	v0421_before_snapshots.clear()
	v0421_after_snapshots.clear()
	var barn := v0383_world.find_child(V0421_BARN_ROOT, true, false) as Node3D if v0383_world else null
	if barn == null:
		_v0421_fail_closed("accepted secondary-barn root missing")
		return
	var expected := {V0421_POST_LEFT: "BARN_ENTRANCE_FRAME_POST", V0421_POST_RIGHT: "BARN_ENTRANCE_FRAME_POST", V0421_LINTEL: "BARN_ENTRANCE_FRAME_LINTEL"}
	for candidate in barn.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var key := str(node.name)
		var material_name := _v0414_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var value := (key + " " + material_name + " " + mesh_name).to_lower()
		var entry := {"name": key, "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else ""}
		v0421_inventory.append(entry)
		if key == V0421_DOOR:
			if node.visible and node.mesh != null:
				v0421_door = node
			v0421_excluded_inventory.append(entry)
			continue
		if expected.has(key):
			if node.visible and node.mesh != null:
				v0421_nodes.append(node)
				v0421_classes[key] = expected[key]
			else:
				_v0421_fail_closed("expected entrance-frame node is hidden or has no mesh: " + key)
				return
			continue
		var possible_frame := value.contains("jamb") or value.contains("header") or value.contains("threshold") or value.contains("sill") or value.contains("arch") or (value.contains("door") and value.contains("post"))
		if possible_frame and node.visible and node.mesh != null:
			v0421_unexpected.append(key)
			v0421_excluded_inventory.append(entry)
		else:
			v0421_excluded_inventory.append(entry)
	if v0421_nodes.size() != 3 or v0421_door == null or not v0421_unexpected.is_empty() or v0421_classes.size() != 3:
		_v0421_fail_closed("entrance-frame inventory mismatch; expected exactly two posts, one lintel and one excluded door")
		return
	var before_hashes := _v0414_house_hashes(barn)
	var mesh_count := _v0406_mesh_node_count()
	for node in v0421_nodes:
		v0421_before_materials[node.name] = node.material_override
		v0421_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var frame := _v0421_material("V0421_Secondary_Barn_Entrance_Frame", Color("#65503e"), 0.96, 0.08)
	for node in v0421_nodes:
		node.material_override = frame
		v0421_after_materials[node.name] = frame
		v0421_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(barn)
	v0421_audit = {"baselineCommit": V0421_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0421_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_secondary_barn_entrance_frame_material_only", "affectedNodeCount": v0421_nodes.size(), "affectedNodeNames": v0421_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0421_inventory.filter(func(item): return expected.has(str(item.name))), "functionalClassification": v0421_classes, "excludedAdjacentInventory": v0421_excluded_inventory, "expectedInventory": [V0421_POST_LEFT, V0421_POST_RIGHT, V0421_LINTEL], "excludedDoor": V0421_DOOR, "unexpectedVisibleEntranceFrameNames": v0421_unexpected, "originalMaterials": _v0414_material_inventory(v0421_before_materials), "finalMaterials": _v0414_material_inventory(v0421_after_materials), "finalMaterialParameters": ["entrance frame albedo=#65503e roughness=0.96 specular=0.08"], "originalSnapshots": v0421_before_snapshots, "finalSnapshots": v0421_after_snapshots, "uvCountEveryAffectedMesh": _v0421_uv_inventory(), "worldHashesBefore": before_hashes, "worldHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "v0420StoneBase": "preserved", "v0419Gable": "preserved", "v0418Openings": "preserved", "v0417WallBody": "preserved", "door": "preserved", "terrain": "preserved", "route": "preserved", "bridge": "preserved", "landings": "preserved", "mainHouse": "preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0420Audit": v0420_audit}

func _v0421_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = colour
	material.roughness = roughness
	material.specular = specular_value
	material.vertex_color_use_as_albedo = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _v0421_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0421_nodes:
		result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0421_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node:
			node.material_override = materials[key]

func _v0421_restore_before_materials() -> void:
	_v0420_restore_before_materials()
	_v0421_set_materials(v0421_before_materials)

func _v0421_restore_after_materials() -> void:
	_v0420_restore_after_materials()
	_v0421_set_materials(v0421_after_materials)

func _v0421_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_SECONDARY_BARN_ENTRANCE_FRAME_CLOSE_COLOUR.png", Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_SECONDARY_BARN_ENTRANCE_FRAME_CLOSE_GRAYSCALE.png"))
	_v0421_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2)
	_v0421_restore_after_materials()
	await _v0421_capture_diagnostic(root)
	_v0421_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0421_write_audit(root)
	get_tree().quit(0)

func _v0421_capture_diagnostic(root: String) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#17140f"))
	var original: Dictionary = {}
	var frame_material := _v0421_material("V0421_Diagnostic_Entrance_Frame", Color("#d2b24b"), 1.0, 0.0)
	frame_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var door_material := _v0421_material("V0421_Diagnostic_Door", Color("#456b78"), 1.0, 0.0)
	door_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for node in v0421_nodes:
		original[node.name] = node.material_override
		node.material_override = frame_material
	if v0421_door:
		original[v0421_door.name] = v0421_door.material_override
		v0421_door.material_override = door_material
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.color = Color(0.03, 0.025, 0.02, 0.92)
	panel.position = Vector2(12.0, 12.0)
	panel.size = Vector2(1400.0, 116.0)
	var label := Label.new()
	label.position = Vector2(10.0, 8.0)
	label.add_theme_font_size_override("font_size", 18)
	label.text = "v0.421 TEMPORARY BARN ENTRANCE FRAME NODE ID\nPOSTS: " + V0421_POST_LEFT + " + " + V0421_POST_RIGHT + "\nLINTEL: " + V0421_LINTEL + " | DOOR LEAF EXCLUDED: " + V0421_DOOR
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
	for node in v0421_nodes:
		node.material_override = original.get(node.name)
	if v0421_door:
		v0421_door.material_override = original.get(v0421_door.name)
	sheet.save_png(root.path_join("05_TEMPORARY_BARN_ENTRANCE_FRAME_NODE_ID.png"))

func _v0421_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_primary.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0420_V0421_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0420_V0421_ENTRANCE_FRAME_CLOSE_COMPARISON.png"))

func _v0421_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0421-preservation-audit.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(v0421_audit, "  "))

func _v0421_fail_closed(reason: String) -> void:
	v0421_audit = {"baselineCommit": V0421_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0421_CHECKPOINT, "status": V0421_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0421_nodes.size(), "affectedNodeNames": v0421_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0421_inventory, "functionalClassification": v0421_classes, "excludedAdjacentInventory": v0421_excluded_inventory, "expectedInventory": [V0421_POST_LEFT, V0421_POST_RIGHT, V0421_LINTEL], "excludedDoor": V0421_DOOR, "unexpectedVisibleEntranceFrameNames": v0421_unexpected, "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0420Audit": v0420_audit}
