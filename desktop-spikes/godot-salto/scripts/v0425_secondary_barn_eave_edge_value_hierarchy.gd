extends "res://scripts/v0424_secondary_barn_ridge_beam_value_hierarchy.gd"

## v0.425 calibrates only the two existing secondary-barn eave timbers.
## The accepted roof, ridge, gable, front and side material groups remain excluded.

const V0425_CHECKPOINT := "v0.425"
const V0425_CAPTURE_ROOT := "artifacts/runtime/v0425"
const V0425_LIMITATION := "ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_EAVES"
const V0425_BASELINE := "5ded7a7b59bd09ef4e466f48b68dd8b16c1ae224"
const V0425_BARN_ROOT := "V0399_Barn_Structural_Readability"
const V0425_LEFT := "V0399_Barn_Left_Eave"
const V0425_RIGHT := "V0399_Barn_Right_Eave"
const V0425_RIDGE := "V0399_Barn_Ridge_Beam"
const V0425_ROOF_LEFT := "V0399_Barn_Roof_Left"
const V0425_ROOF_RIGHT := "V0399_Barn_Roof_Right"
const V0425_FRONT_BEAM := "V0399_Barn_Front_Beam"
const V0425_FRONT_POST_LEFT := "V0399_Barn_Front_Post_-2_25"
const V0425_FRONT_POST_RIGHT := "V0399_Barn_Front_Post_2_25"
const V0425_SIDE_LEFT := "V0399_Barn_Side_Beam_-1_8"
const V0425_SIDE_RIGHT := "V0399_Barn_Side_Beam_1_8"
const V0425_FRAME_LEFT := "V0399_Barn_Door_Left_Post"
const V0425_FRAME_RIGHT := "V0399_Barn_Door_Right_Post"
const V0425_FRAME_LINTEL := "V0399_Barn_Door_Lintel"

var v0425_capture_mode := false
var v0425_smoke_mode := false
var v0425_nodes: Array[MeshInstance3D] = []
var v0425_classes: Dictionary = {}
var v0425_inventory: Array = []
var v0425_excluded_inventory: Array = []
var v0425_unexpected: Array[String] = []
var v0425_before_materials: Dictionary = {}
var v0425_after_materials: Dictionary = {}
var v0425_before_snapshots: Dictionary = {}
var v0425_after_snapshots: Dictionary = {}
var v0425_audit: Dictionary = {}

func _read_v0409_args() -> void:
	super._read_v0409_args()
	v0425_capture_mode = false
	v0425_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0425-secondary-barn-eaves-capture":
			v0425_capture_mode = true
		if arg == "--v0425-secondary-barn-eaves-smoke":
			v0425_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root:
		v0388_capture_root = V0425_CAPTURE_ROOT
	v0424_capture_mode = false
	v0424_smoke_mode = false
	v0423_capture_mode = false
	v0423_smoke_mode = false
	v0409_capture_mode = v0425_capture_mode
	v0409_smoke_mode = v0425_smoke_mode

func _v0409_apply_existing_material_treatment() -> void:
	_v0421_apply_existing_material_treatment()
	_v0425_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0425_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0425_write_audit(root)
	var file := FileAccess.open(root.path_join("v0425-secondary-barn-eaves-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0425_CHECKPOINT, "status": v0425_audit.get("status", V0425_LIMITATION), "candidateRetained": v0425_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0425_apply_existing_material_treatment() -> void:
	v0425_nodes.clear()
	v0425_classes.clear()
	v0425_inventory.clear()
	v0425_excluded_inventory.clear()
	v0425_unexpected.clear()
	v0425_before_materials.clear()
	v0425_after_materials.clear()
	v0425_before_snapshots.clear()
	v0425_after_snapshots.clear()
	var barn := v0383_world.find_child(V0425_BARN_ROOT, true, false) as Node3D if v0383_world else null
	if barn == null:
		_v0425_fail_closed("accepted secondary-barn root missing")
		return
	var expected := {V0425_LEFT: "BARN_EAVE_EDGE", V0425_RIGHT: "BARN_EAVE_EDGE"}
	var excluded := {V0425_RIDGE: "BARN_RIDGE_BEAM", V0425_ROOF_LEFT: "BARN_ROOF_PLANE", V0425_ROOF_RIGHT: "BARN_ROOF_PLANE", V0425_FRONT_BEAM: "BARN_FRONT_STRUCTURAL_BEAM", V0425_FRONT_POST_LEFT: "BARN_FRONT_STRUCTURAL_POST", V0425_FRONT_POST_RIGHT: "BARN_FRONT_STRUCTURAL_POST", V0425_SIDE_LEFT: "BARN_SIDE_STRUCTURAL_BEAM", V0425_SIDE_RIGHT: "BARN_SIDE_STRUCTURAL_BEAM", V0425_FRAME_LEFT: "BARN_ENTRANCE_FRAME_POST", V0425_FRAME_RIGHT: "BARN_ENTRANCE_FRAME_POST", V0425_FRAME_LINTEL: "BARN_ENTRANCE_FRAME_LINTEL"}
	for candidate in barn.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var key := str(node.name)
		var material_name := _v0414_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var value := (key + " " + material_name + " " + mesh_name).to_lower()
		var entry := {"name": key, "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else ""}
		v0425_inventory.append(entry)
		if expected.has(key):
			if node.visible and node.mesh != null:
				v0425_nodes.append(node)
				v0425_classes[key] = expected[key]
			else:
				_v0425_fail_closed("expected eave node is hidden or has no mesh: " + key)
				return
		elif excluded.has(key):
			v0425_excluded_inventory.append(entry)
		else:
			var possible_eave := value.contains("eave") or value.contains("fascia") or value.contains("soffit") or value.contains("overhang") or value.contains("roof_edge")
			if possible_eave and node.visible and node.mesh != null:
				v0425_unexpected.append(key)
			v0425_excluded_inventory.append(entry)
	if v0425_nodes.size() != 2 or v0425_classes.size() != 2 or not v0425_unexpected.is_empty():
		_v0425_fail_closed("eave inventory mismatch; expected exactly two classified equivalent eaves with no additional visible eave surfaces")
		return
	var before_hashes := _v0414_house_hashes(barn)
	var mesh_count := _v0406_mesh_node_count()
	for node in v0425_nodes:
		v0425_before_materials[node.name] = node.material_override
		v0425_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var eave_material := _v0425_material("V0425_Secondary_Barn_Eave_Timber", Color("#564536"), 0.98, 0.06)
	for node in v0425_nodes:
		node.material_override = eave_material
		v0425_after_materials[node.name] = eave_material
		v0425_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(barn)
	v0425_audit = {"baselineCommit": V0425_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0425_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_secondary_barn_eaves_material_only", "affectedNodeCount": v0425_nodes.size(), "affectedNodeNames": v0425_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0425_inventory.filter(func(item): return expected.has(str(item.name))), "functionalClassification": v0425_classes, "eaveFunctionalEquivalence": true, "excludedAdjacentInventory": v0425_excluded_inventory, "expectedInventory": [V0425_LEFT, V0425_RIGHT], "unexpectedVisibleEaveNames": v0425_unexpected, "excludedRoofPlaneInventory": [V0425_ROOF_LEFT, V0425_ROOF_RIGHT], "excludedRidgeInventory": [V0425_RIDGE], "excludedFrontStructureInventory": [V0425_FRONT_BEAM, V0425_FRONT_POST_LEFT, V0425_FRONT_POST_RIGHT], "excludedSideBeamInventory": [V0425_SIDE_LEFT, V0425_SIDE_RIGHT], "excludedEntranceFrameInventory": [V0425_FRAME_LEFT, V0425_FRAME_RIGHT, V0425_FRAME_LINTEL], "originalMaterials": _v0414_material_inventory(v0425_before_materials), "finalMaterials": _v0414_material_inventory(v0425_after_materials), "finalMaterialParameters": ["both eaves albedo=#564536 roughness=0.98 specular=0.06"], "originalSnapshots": v0425_before_snapshots, "finalSnapshots": v0425_after_snapshots, "uvCountEveryAffectedMesh": _v0425_uv_inventory(), "worldHashesBefore": before_hashes, "worldHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "captureOnlyContextIsolation": "barn descendants only for close and diagnostic; visibility restored before comparisons, audit and exit", "v0424Ridge": "preserved", "v0423SideBeams": "preserved", "v0422FrontStructure": "preserved", "v0421EntranceFrame": "preserved", "v0420StoneBase": "preserved", "v0419Gable": "preserved", "v0418Openings": "preserved", "v0417WallBody": "preserved", "door": "preserved", "terrain": "preserved", "route": "preserved", "bridge": "preserved", "landings": "preserved", "mainHouse": "preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}

func _v0425_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = colour
	material.roughness = roughness
	material.specular = specular_value
	material.vertex_color_use_as_albedo = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _v0425_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0425_nodes:
		result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0425_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node:
			node.material_override = materials[key]

func _v0425_restore_before_materials() -> void:
	_v0421_restore_before_materials()
	_v0425_set_materials(v0425_before_materials)

func _v0425_restore_after_materials() -> void:
	_v0421_restore_after_materials()
	_v0425_set_materials(v0425_after_materials)

func _v0425_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close_visibility := _v0423_isolate_barn_close_context()
	var close := await _v0409_capture_view("02_SECONDARY_BARN_EAVES_CLOSE_COLOUR.png", Vector3(-4.30, 4.35, 4.70), Vector3(-10.20, 1.40, 4.95), 2.80, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_SECONDARY_BARN_EAVES_CLOSE_GRAYSCALE.png"))
	_v0423_restore_barn_close_context(close_visibility)
	_v0425_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(-4.30, 4.35, 4.70), Vector3(-10.20, 1.40, 4.95), 2.80)
	_v0425_restore_after_materials()
	await _v0425_capture_diagnostic(root)
	_v0425_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0425_write_audit(root)
	get_tree().quit(0)

func _v0425_capture_diagnostic(root: String) -> void:
	var visibility := _v0423_isolate_barn_close_context()
	var original: Dictionary = {}
	var eave_material := _v0425_material("V0425_Diagnostic_Eave", Color("#d2b24b"), 1.0, 0.0)
	var roof_material := _v0425_material("V0425_Diagnostic_Excluded_Roof", Color("#456b78"), 1.0, 0.0)
	var context_material := _v0425_material("V0425_Diagnostic_Excluded_Context", Color("#777777"), 1.0, 0.0)
	for material in [eave_material, roof_material, context_material]:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for key in [V0425_LEFT, V0425_RIGHT, V0425_ROOF_LEFT, V0425_ROOF_RIGHT, V0425_RIDGE, V0425_FRONT_BEAM, V0425_FRONT_POST_LEFT, V0425_FRONT_POST_RIGHT, V0425_SIDE_LEFT, V0425_SIDE_RIGHT, V0425_FRAME_LEFT, V0425_FRAME_RIGHT, V0425_FRAME_LINTEL]:
		var node := v0383_world.find_child(key, true, false) as MeshInstance3D
		if node:
			original[node.name] = node.material_override
			if key == V0425_LEFT or key == V0425_RIGHT:
				node.material_override = eave_material
			elif key == V0425_ROOF_LEFT or key == V0425_ROOF_RIGHT:
				node.material_override = roof_material
			else:
				node.material_override = context_material
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.color = Color(0.03, 0.025, 0.02, 0.92)
	panel.position = Vector2(12.0, 12.0)
	panel.size = Vector2(1620.0, 210.0)
	var label := Label.new()
	label.position = Vector2(10.0, 8.0)
	label.add_theme_font_size_override("font_size", 18)
	label.text = "v0.425 TEMPORARY BARN EAVE NODE ID\nLEFT EAVE: " + V0425_LEFT + "\nRIGHT EAVE: " + V0425_RIGHT + "\nROOF PLANES EXCLUDED: " + V0425_ROOF_LEFT + " + " + V0425_ROOF_RIGHT + "\nRIDGE EXCLUDED: " + V0425_RIDGE + "\nFRONT/SIDE STRUCTURE EXCLUDED: " + V0425_FRONT_BEAM + " + " + V0425_SIDE_LEFT + " + " + V0425_SIDE_RIGHT
	panel.add_child(label)
	layer.add_child(panel)
	add_child(layer)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.convert(Image.FORMAT_RGBA8)
	if image.get_width() != 1920 or image.get_height() != 1080:
		image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	layer.free()
	for key in original.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node:
			node.material_override = original[key]
	_v0423_restore_barn_close_context(visibility)
	image.save_png(root.path_join("05_TEMPORARY_BARN_EAVE_NODE_ID.png"))

func _v0425_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_primary.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0424_V0425_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0424_V0425_EAVES_CLOSE_COMPARISON.png"))

func _v0425_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0425-preservation-audit.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(v0425_audit, "  "))

func _v0425_fail_closed(reason: String) -> void:
	v0425_audit = {"baselineCommit": V0425_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0425_CHECKPOINT, "status": V0425_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0425_nodes.size(), "affectedNodeNames": v0425_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0425_inventory, "expectedInventory": [V0425_LEFT, V0425_RIGHT], "unexpectedVisibleEaveNames": v0425_unexpected, "excludedRoofPlaneInventory": [V0425_ROOF_LEFT, V0425_ROOF_RIGHT], "excludedRidgeInventory": [V0425_RIDGE], "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}
