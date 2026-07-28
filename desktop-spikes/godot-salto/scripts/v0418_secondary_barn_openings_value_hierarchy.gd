extends "res://scripts/v0417_secondary_barn_wall_value_hierarchy.gd"

## v0.418 calibrates only the three existing secondary-barn opening surfaces.
## The v0.417 wall body and every surrounding structural component remain intact.

const V0418_CHECKPOINT := "v0.418"
const V0418_CAPTURE_ROOT := "artifacts/runtime/v0418"
const V0418_LIMITATION := "ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_OPENINGS"
const V0418_BASELINE := "02edf9d0e469bf11ea9d3597a5768f62c422e757"
const V0418_BARN_ROOT := "V0399_Barn_Structural_Readability"
const V0418_EXPECTED := {
	"V0399_Barn_Entrance_Door": "BARN_ENTRANCE",
	"V0399_Barn_Front_Window_-2_25": "BARN_WINDOW_RECESS",
	"V0399_Barn_Front_Window_2_25": "BARN_WINDOW_RECESS",
}

var v0418_capture_mode := false
var v0418_smoke_mode := false
var v0418_nodes: Array[MeshInstance3D] = []
var v0418_classes: Dictionary = {}
var v0418_inventory: Array = []
var v0418_excluded_inventory: Array = []
var v0418_before_materials: Dictionary = {}
var v0418_after_materials: Dictionary = {}
var v0418_before_snapshots: Dictionary = {}
var v0418_after_snapshots: Dictionary = {}
var v0418_audit: Dictionary = {}

func _read_v0409_args() -> void:
	v0418_capture_mode = false
	v0418_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0418-secondary-barn-openings-capture": v0418_capture_mode = true
		if arg == "--v0418-secondary-barn-openings-smoke": v0418_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0418_CAPTURE_ROOT
	v0409_capture_mode = v0418_capture_mode
	v0409_smoke_mode = v0418_smoke_mode
	v0410_capture_mode = false; v0410_smoke_mode = false
	v0411_capture_mode = v0418_capture_mode; v0411_smoke_mode = v0418_smoke_mode
	v0415_capture_mode = false; v0415_smoke_mode = false
	v0416_capture_mode = false; v0416_smoke_mode = false
	v0417_capture_mode = false; v0417_smoke_mode = false

func _v0409_apply_existing_material_treatment() -> void:
	_v0417_apply_existing_material_treatment()
	_v0418_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0418_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0418_write_audit(root)
	var file := FileAccess.open(root.path_join("v0418-secondary-barn-openings-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0418_CHECKPOINT, "status": v0418_audit.get("status", V0418_LIMITATION), "candidateRetained": v0418_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "surfacesChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0418_apply_existing_material_treatment() -> void:
	v0418_nodes.clear(); v0418_classes.clear(); v0418_inventory.clear(); v0418_excluded_inventory.clear()
	v0418_before_materials.clear(); v0418_after_materials.clear(); v0418_before_snapshots.clear(); v0418_after_snapshots.clear()
	var barn := v0383_world.find_child(V0418_BARN_ROOT, true, false) as Node3D if v0383_world else null
	if barn == null:
		_v0418_fail_closed("accepted secondary-barn root missing")
		return
	var visible_opening_names: Array[String] = []
	for candidate in barn.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var material_name := _v0414_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var entry := {"name": str(node.name), "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else ""}
		v0418_inventory.append(entry)
		var key := str(node.name)
		var value := (key + " " + material_name + " " + mesh_name).to_lower()
		var is_opening_surface := (value.contains("door") or value.contains("window")) and not (value.contains("post") or value.contains("lintel") or value.contains("beam") or value.contains("frame"))
		if is_opening_surface:
			visible_opening_names.append(key)
		if not node.visible or node.mesh == null:
			v0418_excluded_inventory.append(entry)
			continue
		if V0418_EXPECTED.has(key):
			v0418_nodes.append(node)
			v0418_classes[key] = V0418_EXPECTED[key]
		else:
			v0418_excluded_inventory.append(entry)
	var expected_names: Array[String] = []
	for key in V0418_EXPECTED.keys(): expected_names.append(str(key))
	var missing := false
	for key in expected_names:
		if not v0418_classes.has(key): missing = true
	var unexpected_visible := visible_opening_names.filter(func(name): return not expected_names.has(name))
	if missing or not unexpected_visible.is_empty() or v0418_nodes.size() != expected_names.size():
		_v0418_fail_closed("opening inventory mismatch; expected three isolated visible opening surfaces")
		return
	var before_hashes := _v0414_house_hashes(barn)
	var mesh_count := _v0406_mesh_node_count()
	for node in v0418_nodes:
		v0418_before_materials[node.name] = node.material_override
		v0418_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var door := _v0418_material("V0418_Secondary_Barn_Entrance_Door", Color("#4a3b32"), 0.97, 0.08)
	var window := _v0418_material("V0418_Secondary_Barn_Window_Recess", Color("#454946"), 0.93, 0.12)
	for node in v0418_nodes:
		var material: StandardMaterial3D = door if v0418_classes[node.name] == "BARN_ENTRANCE" else window
		node.material_override = material
		v0418_after_materials[node.name] = material
		v0418_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(barn)
	v0418_audit = {"baselineCommit": V0418_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0418_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_secondary_barn_entrance_and_two_window_materials_only", "affectedNodeCount": v0418_nodes.size(), "affectedNodeNames": v0418_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0418_inventory.filter(func(item): return str(item.name) in v0418_classes), "functionalClassification": v0418_classes, "excludedAdjacentInventory": v0418_excluded_inventory, "expectedInventory": expected_names, "unexpectedVisibleOpeningNames": unexpected_visible, "originalMaterials": _v0414_material_inventory(v0418_before_materials), "finalMaterials": _v0414_material_inventory(v0418_after_materials), "finalMaterialParameters": ["entrance door albedo=#4a3b32 roughness=0.97 specular=0.08", "both window recesses albedo=#454946 roughness=0.93 specular=0.12"], "originalSnapshots": v0418_before_snapshots, "finalSnapshots": v0418_after_snapshots, "uvCountEveryAffectedMesh": _v0418_uv_inventory(), "worldHashesBefore": before_hashes, "worldHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "v0417WallBody": "preserved", "excludedFramesAndStructure": "preserved", "mainHouse": "preserved", "roof": "preserved", "gable": "preserved", "foundation": "preserved", "terrain": "preserved", "route": "preserved", "bridge": "preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0417Audit": v0417_audit}

func _v0418_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name; material.albedo_color = colour; material.roughness = roughness; material.specular = specular_value
	material.vertex_color_use_as_albedo = false; material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _v0418_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0418_nodes: result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0418_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node: node.material_override = materials[key]

func _v0418_restore_before_materials() -> void:
	_v0417_restore_before_materials(); _v0418_set_materials(v0418_before_materials)

func _v0418_restore_after_materials() -> void:
	_v0417_restore_after_materials(); _v0418_set_materials(v0418_after_materials)

func _v0418_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root); DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_SECONDARY_BARN_OPENINGS_CLOSE_COLOUR.png", Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2, root)
	var primary_gray := primary.duplicate(); primary_gray.convert(Image.FORMAT_L8); primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate(); close_gray.convert(Image.FORMAT_L8); close_gray.save_png(root.path_join("04_SECONDARY_BARN_OPENINGS_CLOSE_GRAYSCALE.png"))
	_v0418_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(8.0, 10.5, 14.0), Vector3(-8.90, 1.05, 4.50), 4.2)
	_v0418_restore_after_materials()
	await _v0418_capture_diagnostic(root)
	_v0418_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0418_write_audit(root)
	get_tree().quit(0)

func _v0418_capture_diagnostic(root: String) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8); sheet.fill(Color("#17140f"))
	var colours := [Color("#c65b3c"), Color("#4b86d5"), Color("#4b86d5")]
	var columns := 2; var rows := maxi(1, ceili(float(v0418_nodes.size()) / float(columns))); var tile_width := 1920 / columns; var tile_height := 1080 / rows
	for index in v0418_nodes.size():
		var node: MeshInstance3D = v0418_nodes[index]; var original := node.material_override
		var diagnostic_material := StandardMaterial3D.new(); diagnostic_material.albedo_color = colours[index]; diagnostic_material.vertex_color_use_as_albedo = false; diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = diagnostic_material
		var layer := CanvasLayer.new(); var panel := ColorRect.new(); panel.color = Color(0.03, 0.025, 0.02, 0.92); panel.position = Vector2(12.0, 12.0); panel.size = Vector2(1150.0, 92.0)
		var label := Label.new(); label.position = Vector2(10.0, 8.0); label.add_theme_font_size_override("font_size", 18); label.text = "v0.418 TEMPORARY BARN OPENING NODE ID\n" + str(v0418_classes[node.name]) + " | " + str(node.name) + " | existing surface only"
		panel.add_child(label); layer.add_child(panel); add_child(layer)
		await get_tree().process_frame; await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image(); image.convert(Image.FORMAT_RGBA8); image.resize(tile_width, tile_height, Image.INTERPOLATE_LANCZOS); sheet.blit_rect(image, Rect2i(0, 0, tile_width, tile_height), Vector2i((index % columns) * tile_width, (index / columns) * tile_height))
		layer.free(); node.material_override = original
	sheet.save_png(root.path_join("05_TEMPORARY_BARN_OPENING_NODE_ID.png"))

func _v0418_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_primary.convert(Image.FORMAT_RGBA8); primary.convert(Image.FORMAT_RGBA8); wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); wide.save_png(root.path_join("06_V0417_V0418_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_close.convert(Image.FORMAT_RGBA8); close.convert(Image.FORMAT_RGBA8); near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); near.save_png(root.path_join("07_V0417_V0418_BARN_CLOSE_COMPARISON.png"))

func _v0418_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0418-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0418_audit, "  "))

func _v0418_fail_closed(reason: String) -> void:
	v0418_audit = {"baselineCommit": V0418_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0418_CHECKPOINT, "status": V0418_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0418_nodes.size(), "affectedNodeNames": v0418_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0418_inventory, "functionalClassification": v0418_classes, "excludedAdjacentInventory": v0418_excluded_inventory, "expectedInventory": V0418_EXPECTED.keys(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0417Audit": v0417_audit}
