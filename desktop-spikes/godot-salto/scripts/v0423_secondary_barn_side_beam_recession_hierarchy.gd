extends "res://scripts/v0422_secondary_barn_front_structure_value_hierarchy.gd"

## v0.423 calibrates only the two existing secondary-barn side structural beams.
## The accepted v0.422 front structure remains inherited and excluded.

const V0423_CHECKPOINT := "v0.423"
const V0423_CAPTURE_ROOT := "artifacts/runtime/v0423"
const V0423_LIMITATION := "ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_SIDE_BEAMS"
const V0423_BASELINE := "5a74f257d582d6b1adcce4bf17dae23737d92621"
const V0423_BARN_ROOT := "V0399_Barn_Structural_Readability"
const V0423_SIDE_LEFT := "V0399_Barn_Side_Beam_-1_8"
const V0423_SIDE_RIGHT := "V0399_Barn_Side_Beam_1_8"
const V0423_FRONT_BEAM := "V0399_Barn_Front_Beam"
const V0423_FRONT_POST_LEFT := "V0399_Barn_Front_Post_-2_25"
const V0423_FRONT_POST_RIGHT := "V0399_Barn_Front_Post_2_25"
const V0423_FRAME_LEFT := "V0399_Barn_Door_Left_Post"
const V0423_FRAME_RIGHT := "V0399_Barn_Door_Right_Post"
const V0423_FRAME_LINTEL := "V0399_Barn_Door_Lintel"
const V0423_RIDGE := "V0399_Barn_Ridge_Beam"
const V0423_EAVE_LEFT := "V0399_Barn_Left_Eave"
const V0423_EAVE_RIGHT := "V0399_Barn_Right_Eave"

var v0423_capture_mode := false
var v0423_smoke_mode := false
var v0423_nodes: Array[MeshInstance3D] = []
var v0423_excluded: Array[MeshInstance3D] = []
var v0423_classes: Dictionary = {}
var v0423_inventory: Array = []
var v0423_excluded_inventory: Array = []
var v0423_unexpected: Array[String] = []
var v0423_before_materials: Dictionary = {}
var v0423_after_materials: Dictionary = {}
var v0423_before_snapshots: Dictionary = {}
var v0423_after_snapshots: Dictionary = {}
var v0423_audit: Dictionary = {}

func _read_v0409_args() -> void:
	super._read_v0409_args()
	v0423_capture_mode = false
	v0423_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0423-secondary-barn-side-beams-capture":
			v0423_capture_mode = true
		if arg == "--v0423-secondary-barn-side-beams-smoke":
			v0423_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root:
		v0388_capture_root = V0423_CAPTURE_ROOT
	v0422_capture_mode = false
	v0422_smoke_mode = false
	v0421_capture_mode = false
	v0421_smoke_mode = false
	v0409_capture_mode = v0423_capture_mode
	v0409_smoke_mode = v0423_smoke_mode

func _v0409_apply_existing_material_treatment() -> void:
	_v0421_apply_existing_material_treatment()
	_v0423_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0423_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0423_write_audit(root)
	var file := FileAccess.open(root.path_join("v0423-secondary-barn-side-beams-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0423_CHECKPOINT, "status": v0423_audit.get("status", V0423_LIMITATION), "candidateRetained": v0423_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0423_apply_existing_material_treatment() -> void:
	v0423_nodes.clear()
	v0423_excluded.clear()
	v0423_classes.clear()
	v0423_inventory.clear()
	v0423_excluded_inventory.clear()
	v0423_unexpected.clear()
	v0423_before_materials.clear()
	v0423_after_materials.clear()
	v0423_before_snapshots.clear()
	v0423_after_snapshots.clear()
	var barn := v0383_world.find_child(V0423_BARN_ROOT, true, false) as Node3D if v0383_world else null
	if barn == null:
		_v0423_fail_closed("accepted secondary-barn root missing")
		return
	var expected := {V0423_SIDE_LEFT: "BARN_SIDE_STRUCTURAL_BEAM", V0423_SIDE_RIGHT: "BARN_SIDE_STRUCTURAL_BEAM"}
	var excluded := {V0423_FRONT_BEAM: "BARN_FRONT_STRUCTURAL_BEAM", V0423_FRONT_POST_LEFT: "BARN_FRONT_STRUCTURAL_POST", V0423_FRONT_POST_RIGHT: "BARN_FRONT_STRUCTURAL_POST", V0423_FRAME_LEFT: "BARN_ENTRANCE_FRAME_POST", V0423_FRAME_RIGHT: "BARN_ENTRANCE_FRAME_POST", V0423_FRAME_LINTEL: "BARN_ENTRANCE_FRAME_LINTEL", V0423_RIDGE: "BARN_RIDGE_BEAM", V0423_EAVE_LEFT: "BARN_EAVE", V0423_EAVE_RIGHT: "BARN_EAVE"}
	for candidate in barn.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var key := str(node.name)
		var material_name := _v0414_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var value := (key + " " + material_name + " " + mesh_name).to_lower()
		var entry := {"name": key, "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else ""}
		v0423_inventory.append(entry)
		if expected.has(key):
			if node.visible and node.mesh != null:
				v0423_nodes.append(node)
				v0423_classes[key] = expected[key]
			else:
				_v0423_fail_closed("expected side-beam node is hidden or has no mesh: " + key)
				return
		elif excluded.has(key):
			if node.visible and node.mesh != null:
				v0423_excluded.append(node)
			v0423_excluded_inventory.append(entry)
		else:
			var possible_side_structure := value.contains("side") and (value.contains("beam") or value.contains("rail") or value.contains("sill") or value.contains("brace") or value.contains("support"))
			if possible_side_structure and node.visible and node.mesh != null:
				v0423_unexpected.append(key)
			v0423_excluded_inventory.append(entry)
	if v0423_nodes.size() != 2 or v0423_classes.size() != 2 or not v0423_unexpected.is_empty():
		_v0423_fail_closed("side-beam inventory mismatch; expected exactly two classified side beams with no additional visible side structural surfaces")
		return
	var before_hashes := _v0414_house_hashes(barn)
	var mesh_count := _v0406_mesh_node_count()
	for node in v0423_nodes:
		v0423_before_materials[node.name] = node.material_override
		v0423_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var structure := _v0423_material("V0423_Secondary_Barn_Side_Structural_Timber", Color("#524235"), 0.98, 0.06)
	for node in v0423_nodes:
		node.material_override = structure
		v0423_after_materials[node.name] = structure
		v0423_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(barn)
	v0423_audit = {"baselineCommit": V0423_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0423_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_secondary_barn_side_structural_beam_material_only", "affectedNodeCount": v0423_nodes.size(), "affectedNodeNames": v0423_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0423_inventory.filter(func(item): return expected.has(str(item.name))), "functionalClassification": v0423_classes, "excludedAdjacentInventory": v0423_excluded_inventory, "expectedInventory": [V0423_SIDE_LEFT, V0423_SIDE_RIGHT], "unexpectedVisibleSideStructureNames": v0423_unexpected, "excludedFrontStructureInventory": [V0423_FRONT_BEAM, V0423_FRONT_POST_LEFT, V0423_FRONT_POST_RIGHT], "excludedEntranceFrameInventory": [V0423_FRAME_LEFT, V0423_FRAME_RIGHT, V0423_FRAME_LINTEL], "excludedRidgeEaveInventory": [V0423_RIDGE, V0423_EAVE_LEFT, V0423_EAVE_RIGHT], "originalMaterials": _v0414_material_inventory(v0423_before_materials), "finalMaterials": _v0414_material_inventory(v0423_after_materials), "finalMaterialParameters": ["side beams albedo=#524235 roughness=0.98 specular=0.06"], "originalSnapshots": v0423_before_snapshots, "finalSnapshots": v0423_after_snapshots, "uvCountEveryAffectedMesh": _v0423_uv_inventory(), "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "v0422FrontStructure": "preserved", "v0421EntranceFrame": "preserved", "v0420StoneBase": "preserved", "v0419Gable": "preserved", "v0418Openings": "preserved", "v0417WallBody": "preserved", "door": "preserved", "terrain": "preserved", "route": "preserved", "bridge": "preserved", "landings": "preserved", "mainHouse": "preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}

func _v0423_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = colour
	material.roughness = roughness
	material.specular = specular_value
	material.vertex_color_use_as_albedo = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _v0423_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0423_nodes:
		result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0423_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node:
			node.material_override = materials[key]

func _v0423_restore_before_materials() -> void:
	_v0421_restore_before_materials()
	_v0423_set_materials(v0423_before_materials)

func _v0423_restore_after_materials() -> void:
	_v0421_restore_after_materials()
	_v0423_set_materials(v0423_after_materials)

func _v0423_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close_visibility := _v0423_isolate_barn_close_context()
	var close := await _v0409_capture_view("02_SECONDARY_BARN_SIDE_BEAMS_CLOSE_COLOUR.png", Vector3(-4.30, 4.35, 4.70), Vector3(-10.20, 1.40, 4.95), 2.80, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_SECONDARY_BARN_SIDE_BEAMS_CLOSE_GRAYSCALE.png"))
	_v0423_restore_barn_close_context(close_visibility)
	_v0423_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(-4.30, 4.35, 4.70), Vector3(-10.20, 1.40, 4.95), 2.80)
	_v0423_restore_after_materials()
	await _v0423_capture_diagnostic(root)
	_v0423_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0423_write_audit(root)
	get_tree().quit(0)

func _v0423_isolate_barn_close_context() -> Dictionary:
	var visibility: Dictionary = {}
	if v0383_world == null or v0399_barn == null:
		return visibility
	for node in v0383_world.find_children("*", "GeometryInstance3D", true, false):
		var geometry := node as GeometryInstance3D
		if geometry and not v0399_barn.is_ancestor_of(geometry):
			visibility[geometry] = geometry.visible
			geometry.visible = false
	return visibility

func _v0423_restore_barn_close_context(visibility: Dictionary) -> void:
	for node in visibility.keys():
		var geometry := node as GeometryInstance3D
		if is_instance_valid(geometry):
			geometry.visible = bool(visibility[node])

func _v0423_capture_diagnostic(root: String) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#17140f"))
	var close_visibility := _v0423_isolate_barn_close_context()
	var original: Dictionary = {}
	var side_material := _v0423_material("V0423_Diagnostic_Side_Beams", Color("#d2b24b"), 1.0, 0.0)
	var front_material := _v0423_material("V0423_Diagnostic_Front_Structure", Color("#456b78"), 1.0, 0.0)
	var context_material := _v0423_material("V0423_Diagnostic_Excluded_Context", Color("#777777"), 1.0, 0.0)
	for material in [side_material, front_material, context_material]:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for node in v0423_nodes:
		original[node.name] = node.material_override
		node.material_override = side_material
	for key in [V0423_FRONT_BEAM, V0423_FRONT_POST_LEFT, V0423_FRONT_POST_RIGHT]:
		var node := v0383_world.find_child(key, true, false) as MeshInstance3D
		if node:
			original[node.name] = node.material_override
			node.material_override = front_material
	for key in [V0423_RIDGE, V0423_EAVE_LEFT, V0423_EAVE_RIGHT]:
		var node := v0383_world.find_child(key, true, false) as MeshInstance3D
		if node:
			original[node.name] = node.material_override
			node.material_override = context_material
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.color = Color(0.03, 0.025, 0.02, 0.92)
	panel.position = Vector2(12.0, 12.0)
	panel.size = Vector2(1620.0, 170.0)
	var label := Label.new()
	label.position = Vector2(10.0, 8.0)
	label.add_theme_font_size_override("font_size", 18)
	label.text = "v0.423 TEMPORARY BARN SIDE-BEAM NODE ID\nSIDE BEAMS: " + V0423_SIDE_LEFT + " + " + V0423_SIDE_RIGHT + "\nFRONT STRUCTURE EXCLUDED: " + V0423_FRONT_BEAM + " + " + V0423_FRONT_POST_LEFT + " + " + V0423_FRONT_POST_RIGHT + "\nRIDGE/EAVES EXCLUDED: " + V0423_RIDGE + " + " + V0423_EAVE_LEFT + " + " + V0423_EAVE_RIGHT
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
	for key in original.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node:
			node.material_override = original[key]
	_v0423_restore_barn_close_context(close_visibility)
	sheet.save_png(root.path_join("05_TEMPORARY_BARN_SIDE_BEAM_NODE_ID.png"))

func _v0423_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_primary.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0422_V0423_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0422_V0423_SIDE_BEAMS_CLOSE_COMPARISON.png"))

func _v0423_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0423-preservation-audit.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(v0423_audit, "  "))

func _v0423_fail_closed(reason: String) -> void:
	v0423_audit = {"baselineCommit": V0423_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0423_CHECKPOINT, "status": V0423_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0423_nodes.size(), "affectedNodeNames": v0423_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0423_inventory, "functionalClassification": v0423_classes, "excludedAdjacentInventory": v0423_excluded_inventory, "expectedInventory": [V0423_SIDE_LEFT, V0423_SIDE_RIGHT], "unexpectedVisibleSideStructureNames": v0423_unexpected, "excludedFrontStructureInventory": [V0423_FRONT_BEAM, V0423_FRONT_POST_LEFT, V0423_FRONT_POST_RIGHT], "excludedEntranceFrameInventory": [V0423_FRAME_LEFT, V0423_FRAME_RIGHT, V0423_FRAME_LINTEL], "excludedRidgeEaveInventory": [V0423_RIDGE, V0423_EAVE_LEFT, V0423_EAVE_RIGHT], "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}
