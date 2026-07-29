extends "res://scripts/v0415_main_house_foundation_step_grounding.gd"

## v0.416 is an opt-in, material-only calibration of existing visible main-house
## chimney body/cap surfaces. v0.415 remains authoritative and fail-closed.

const V0416_CHECKPOINT := "v0.416"
const V0416_CAPTURE_ROOT := "artifacts/runtime/v0416"
const V0416_LIMITATION := "ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_CHIMNEY"
const V0416_BASELINE := "73bbc22d0137a11b4a2cd0f377dbe9157e6f2c7c"
const V0416_HOUSE_NAME := "V0394_One_Primary_Barrosan_Homestead"

var v0416_capture_mode := false
var v0416_smoke_mode := false
var v0416_nodes: Array[MeshInstance3D] = []
var v0416_classes: Dictionary = {}
var v0416_excluded_inventory: Array = []
var v0416_before_materials: Dictionary = {}
var v0416_after_materials: Dictionary = {}
var v0416_before_snapshots: Dictionary = {}
var v0416_after_snapshots: Dictionary = {}
var v0416_audit: Dictionary = {}
var v0416_candidate_debug: Array = []

func _read_v0409_args() -> void:
	v0416_capture_mode = false
	v0416_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0416-main-house-chimney-capture": v0416_capture_mode = true
		if arg == "--v0416-main-house-chimney-smoke": v0416_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0416_CAPTURE_ROOT
	v0409_capture_mode = v0416_capture_mode
	v0409_smoke_mode = v0416_smoke_mode
	v0410_capture_mode = false
	v0410_smoke_mode = false
	v0411_capture_mode = v0416_capture_mode
	v0411_smoke_mode = v0416_smoke_mode
	v0415_capture_mode = false
	v0415_smoke_mode = false

func _v0409_apply_existing_material_treatment() -> void:
	_v0414_apply_existing_material_treatment()
	_v0415_apply_existing_material_treatment()
	_v0416_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0416_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0416_write_audit(root)
	var file := FileAccess.open(root.path_join("v0416-main-house-chimney-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0416_CHECKPOINT, "status": v0416_audit.get("status", V0416_LIMITATION), "candidateRetained": v0416_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "surfacesChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0416_apply_existing_material_treatment() -> void:
	v0416_nodes.clear(); v0416_classes.clear(); v0416_excluded_inventory.clear(); v0416_before_materials.clear(); v0416_after_materials.clear(); v0416_before_snapshots.clear(); v0416_after_snapshots.clear(); v0416_candidate_debug.clear()
	var house := v0383_world.find_child(V0416_HOUSE_NAME, true, false) as Node3D if v0383_world else null
	if house == null:
		_v0416_fail_closed("accepted main-house root missing")
		return
	v0400_house = house
	var inventory: Array = []
	for candidate in house.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var material_name := _v0414_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var entry := {"name": str(node.name), "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else ""}
		inventory.append(entry)
		var value := (str(node.name) + " " + material_name + " " + mesh_name).to_lower()
		if value.contains("chimney") or value.contains("smoke_stack") or value.contains("flue"):
			v0416_candidate_debug.append(str(node.name))
		if node.mesh == null or not node.visible:
			v0416_excluded_inventory.append(entry)
			continue
		var role := _v0416_classify(value)
		if role == "CHIMNEY_BODY" or role == "CHIMNEY_CAP_OR_CROWN":
			v0416_nodes.append(node); v0416_classes[node.name] = role
		else:
			v0416_excluded_inventory.append(entry)
	if v0416_nodes.is_empty() or not v0416_classes.values().has("CHIMNEY_BODY"):
		_v0416_fail_closed("incomplete visible CHIMNEY_BODY/CHIMNEY_CAP_OR_CROWN inventory")
		return
	var before_hashes := _v0414_house_hashes(house)
	var mesh_count := _v0406_mesh_node_count()
	for node in v0416_nodes:
		v0416_before_materials[node.name] = node.material_override
		v0416_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var body := _v0416_material("V0416_Main_House_Chimney_Body", Color("#625f58"), 0.98, 0.08)
	var cap := _v0416_material("V0416_Main_House_Chimney_Cap", Color("#504c47"), 0.98, 0.07)
	for node in v0416_nodes:
		var material: StandardMaterial3D = body if v0416_classes[node.name] == "CHIMNEY_BODY" else cap
		node.material_override = material
		v0416_after_materials[node.name] = material
		v0416_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(house)
	v0416_audit = {"baselineCommit": V0416_BASELINE, "checkpoint": V0416_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_main_house_chimney_body_and_cap_materials_only", "affectedNodeCount": v0416_nodes.size(), "affectedNodeNames": v0416_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": inventory.filter(func(item): return str(item.name) in v0416_classes), "functionalClassification": v0416_classes, "excludedAdjacentInventory": v0416_excluded_inventory, "candidateDebugNames": v0416_candidate_debug, "originalMaterials": _v0414_material_inventory(v0416_before_materials), "finalMaterials": _v0414_material_inventory(v0416_after_materials), "finalMaterialParameters": ["chimney body albedo=#625f58 roughness=0.98 specular=0.08", "chimney cap albedo=#504c47 roughness=0.98 specular=0.07"], "originalSnapshots": v0416_before_snapshots, "finalSnapshots": v0416_after_snapshots, "uvCountEveryAffectedMesh": _v0416_uv_inventory(), "worldHashesBefore": before_hashes, "worldHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "roof": "v0408-preserved", "masonry": "v0413-preserved", "openingsTrim": "v0414-preserved", "foundationSteps": "v0415-preserved", "terrain": "preserved", "route": "preserved", "bridge": "v0412-preserved", "landings": "preserved", "barn": "v0409-preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0415Audit": v0415_audit}

func _v0416_classify(value: String) -> String:
	if value.contains("collision") or value.contains("roof") or value.contains("ridge") or value.contains("eave") or value.contains("wall") or value.contains("door") or value.contains("window") or value.contains("timber") or value.contains("foundation") or value.contains("threshold"):
		return "EXCLUDED"
	if not value.contains("chimney") and not value.contains("smoke_stack") and not value.contains("flue"):
		return "EXCLUDED"
	if value.contains("cap") or value.contains("crown") or value.contains("top"):
		return "CHIMNEY_CAP_OR_CROWN"
	return "CHIMNEY_BODY"

func _v0416_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.resource_name = name; material.albedo_color = colour; material.roughness = roughness; material.specular = specular_value; material.vertex_color_use_as_albedo = false; material.cull_mode = BaseMaterial3D.CULL_DISABLED; return material

func _v0416_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0416_nodes: result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0416_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node: node.material_override = materials[key]

func _v0416_restore_before_materials() -> void:
	_v0415_restore_before_materials(); _v0416_set_materials(v0416_before_materials)

func _v0416_restore_after_materials() -> void:
	_v0415_restore_after_materials(); _v0416_set_materials(v0416_after_materials)

func _v0416_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root); DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_MAIN_HOUSE_CHIMNEY_CLOSE_COLOUR.png", Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5, root)
	var primary_gray := primary.duplicate(); primary_gray.convert(Image.FORMAT_L8); primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate(); close_gray.convert(Image.FORMAT_L8); close_gray.save_png(root.path_join("04_MAIN_HOUSE_CHIMNEY_CLOSE_GRAYSCALE.png"))
	_v0416_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5)
	_v0416_restore_after_materials()
	await _v0416_capture_diagnostic(root)
	_v0416_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0416_write_audit(root); get_tree().quit(0)

func _v0416_capture_diagnostic(root: String) -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8); sheet.fill(Color("#17140f")); var colours := [Color("#d2b24b"), Color("#4b86d5"), Color("#6fbf67"), Color("#c65b3c")]; var columns := 2; var rows := maxi(1, ceili(float(v0416_nodes.size()) / float(columns))); var tile_width := 1920 / columns; var tile_height := 1080 / rows
	if v0416_nodes.is_empty():
		await RenderingServer.frame_post_draw
		var evidence := get_viewport().get_texture().get_image(); evidence.convert(Image.FORMAT_RGBA8)
		if evidence.get_width() != 1920 or evidence.get_height() != 1080: evidence.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(evidence, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); sheet.save_png(root.path_join("05_TEMPORARY_CHIMNEY_NODE_ID.png")); return
	for index in v0416_nodes.size():
		var node: MeshInstance3D = v0416_nodes[index]; var original := node.material_override; var diagnostic_material := StandardMaterial3D.new(); diagnostic_material.albedo_color = colours[index % colours.size()]; diagnostic_material.vertex_color_use_as_albedo = false; diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; node.material_override = diagnostic_material
		var layer := CanvasLayer.new(); var panel := ColorRect.new(); panel.color = Color(0.03, 0.025, 0.02, 0.92); panel.position = Vector2(12.0, 12.0); panel.size = Vector2(900.0, 84.0); var label := Label.new(); label.position = Vector2(10.0, 8.0); label.add_theme_font_size_override("font_size", 18); label.text = "v0.416 TEMPORARY CHIMNEY NODE ID\n" + str(v0416_classes[node.name]) + " | " + str(node.name) + " | existing node only"; panel.add_child(label); layer.add_child(panel); add_child(layer)
		await get_tree().process_frame; await RenderingServer.frame_post_draw; var image := get_viewport().get_texture().get_image(); image.convert(Image.FORMAT_RGBA8); image.resize(tile_width, tile_height, Image.INTERPOLATE_LANCZOS); sheet.blit_rect(image, Rect2i(0, 0, tile_width, tile_height), Vector2i((index % columns) * tile_width, (index / columns) * tile_height)); layer.free(); node.material_override = original
	sheet.save_png(root.path_join("05_TEMPORARY_CHIMNEY_NODE_ID.png"))

func _v0416_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_primary.convert(Image.FORMAT_RGBA8); primary.convert(Image.FORMAT_RGBA8); wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); wide.save_png(root.path_join("06_V0415_V0416_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_close.convert(Image.FORMAT_RGBA8); close.convert(Image.FORMAT_RGBA8); near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); near.save_png(root.path_join("07_V0415_V0416_CHIMNEY_CLOSE_COMPARISON.png"))

func _v0416_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0416-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0416_audit, "  "))

func _v0416_fail_closed(reason: String) -> void:
	var partial_inventory: Array = []
	for entry in v0416_excluded_inventory: partial_inventory.append(entry)
	v0416_audit = {"baselineCommit": V0416_BASELINE, "checkpoint": V0416_CHECKPOINT, "status": V0416_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0416_nodes.size(), "affectedNodeNames": v0416_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": partial_inventory, "functionalClassification": v0416_classes, "excludedAdjacentInventory": v0416_excluded_inventory, "candidateDebugNames": v0416_candidate_debug, "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0415Audit": v0415_audit}
