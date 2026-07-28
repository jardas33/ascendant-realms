extends "res://scripts/v0413_main_house_masonry_value_hierarchy.gd"

## v0.414 is an opt-in, material-only calibration of existing main-house
## doors, windows, and exterior timber trim. v0.413 masonry and v0.408 roof
## remain authoritative; no geometry, gameplay, or runtime semantics change.

const V0414_CHECKPOINT := "v0.414"
const V0414_CAPTURE_ROOT := "artifacts/runtime/v0414"
const V0414_LIMITATION := "ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_OPENINGS_TRIM"
const V0414_HOUSE_NAME := "V0394_One_Primary_Barrosan_Homestead"

var v0414_capture_mode := false
var v0414_smoke_mode := false
var v0414_nodes: Array[MeshInstance3D] = []
var v0414_classes: Dictionary = {}
var v0414_excluded_inventory: Array = []
var v0414_before_materials: Dictionary = {}
var v0414_after_materials: Dictionary = {}
var v0414_before_snapshots: Dictionary = {}
var v0414_after_snapshots: Dictionary = {}
var v0414_audit: Dictionary = {}

func _read_v0409_args() -> void:
	v0414_capture_mode = false
	v0414_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0414-main-house-openings-trim-capture": v0414_capture_mode = true
		if arg == "--v0414-main-house-openings-trim-smoke": v0414_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0414_CAPTURE_ROOT
	v0410_capture_mode = false
	v0410_smoke_mode = false
	v0409_capture_mode = v0414_capture_mode
	v0409_smoke_mode = v0414_smoke_mode
	v0411_capture_mode = v0414_capture_mode
	v0411_smoke_mode = v0414_smoke_mode

func _v0409_apply_existing_material_treatment() -> void:
	_v0413_apply_existing_material_treatment()
	_v0414_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0414_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0414_write_audit(root)
	var file := FileAccess.open(root.path_join("v0414-main-house-openings-trim-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0414_CHECKPOINT, "status": v0414_audit.get("status", V0414_LIMITATION), "candidateRetained": v0414_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "surfacesChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0414_apply_existing_material_treatment() -> void:
	v0414_nodes.clear(); v0414_classes.clear(); v0414_excluded_inventory.clear(); v0414_before_materials.clear(); v0414_after_materials.clear(); v0414_before_snapshots.clear(); v0414_after_snapshots.clear()
	var house := v0383_world.find_child(V0414_HOUSE_NAME, true, false) as Node3D if v0383_world else null
	if house == null:
		_v0414_fail_closed("accepted main-house root missing")
		return
	v0400_house = house
	var inventory: Array = []
	for candidate in house.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var material_name := _v0414_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var entry := {"name": str(node.name), "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node)}
		inventory.append(entry)
		if node.mesh == null or not node.visible:
			v0414_excluded_inventory.append(entry)
			continue
		var role := _v0414_classify(node, material_name, mesh_name)
		if role == "DOOR" or role == "WINDOW" or role == "TIMBER_TRIM":
			v0414_nodes.append(node); v0414_classes[node.name] = role
		else:
			v0414_excluded_inventory.append(entry)
	if v0414_nodes.is_empty() or not _v0414_has_all_roles():
		_v0414_fail_closed("incomplete visible DOOR/WINDOW/TIMBER_TRIM inventory")
		return
	var before_hashes := _v0414_house_hashes(house)
	var mesh_count := _v0406_mesh_node_count()
	for node in v0414_nodes:
		v0414_before_materials[node.name] = node.material_override
		v0414_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var door := _v0414_material("V0414_Main_House_Door", Color("#514139"), 0.97, 0.08)
	var window := _v0414_material("V0414_Main_House_Window_Frame", Color("#62655f"), 0.91, 0.16)
	var timber := _v0414_material("V0414_Main_House_Timber_Trim", Color("#584437"), 0.96, 0.12)
	for node in v0414_nodes:
		var material: StandardMaterial3D = door if v0414_classes[node.name] == "DOOR" else (window if v0414_classes[node.name] == "WINDOW" else timber)
		node.material_override = material; v0414_after_materials[node.name] = material; v0414_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0414_house_hashes(house)
	v0414_audit = {"baselineCommit": "77b2b2289f76754cbc0644727f6c2e05ba216b69", "checkpoint": V0414_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_main_house_openings_and_timber_trim_materials_only", "affectedNodeCount": v0414_nodes.size(), "affectedNodeNames": v0414_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": inventory.filter(func(item): return str(item.name) in v0414_classes), "functionalClassification": v0414_classes, "excludedAdjacentInventory": v0414_excluded_inventory, "originalMaterials": _v0414_material_inventory(v0414_before_materials), "finalMaterials": _v0414_material_inventory(v0414_after_materials), "finalMaterialParameters": ["doors albedo=#514139 roughness=0.97 specular=0.08", "windows albedo=#62655f roughness=0.91 specular=0.16", "timber trim albedo=#584437 roughness=0.96 specular=0.12"], "originalSnapshots": v0414_before_snapshots, "finalSnapshots": v0414_after_snapshots, "uvCountEveryAffectedMesh": _v0414_uv_inventory(), "inheritedVertexColourBeforeAfter": "unchanged", "houseHashesBefore": before_hashes, "houseHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "masonry": "v0413-preserved", "roof": "v0408-preserved", "foundationStairs": "preserved", "bridge": "v0412-preserved", "route": "preserved", "landings": "preserved", "barn": "v0409-preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged", "v0413Audit": v0413_audit}

func _v0414_classify(node: MeshInstance3D, material_name: String, mesh_name: String) -> String:
	var value := (str(node.name) + " " + material_name + " " + mesh_name).to_lower()
	if value.contains("roof") or value.contains("ridge") or value.contains("eave") or value.contains("chimney") or value.contains("granite") or value.contains("foundation") or value.contains("stair") or value.contains("collision"): return "EXCLUDED"
	if value.contains("recessed_window") or value.contains("window"): return "WINDOW"
	if value.contains("interior_recess") or value.contains("door"): return "DOOR"
	if value.contains("weathered_timber") or value.contains("timber") or value.contains("trim"): return "TIMBER_TRIM"
	return "EXCLUDED"

func _v0414_has_all_roles() -> bool:
	return v0414_classes.values().has("DOOR") and v0414_classes.values().has("WINDOW") and v0414_classes.values().has("TIMBER_TRIM")

func _v0414_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.resource_name = name; material.albedo_color = colour; material.roughness = roughness; material.specular = specular_value; material.vertex_color_use_as_albedo = false; material.cull_mode = BaseMaterial3D.CULL_DISABLED; return material

func _v0414_material_name(material) -> String:
	if material is BaseMaterial3D: return str(material.resource_name)
	return "null"

func _v0414_uv_count(node: MeshInstance3D) -> int:
	if node.mesh is ArrayMesh and node.mesh.get_surface_count() > 0:
		var arrays := node.mesh.surface_get_arrays(0)
		if arrays.size() > Mesh.ARRAY_TEX_UV and arrays[Mesh.ARRAY_TEX_UV] is PackedVector2Array: return (arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array).size()
	return 0

func _v0414_uv_inventory() -> Dictionary:
	var result := {}
	for node in v0414_nodes: result[str(node.name)] = _v0414_uv_count(node)
	return result

func _v0414_material_inventory(materials: Dictionary) -> Array:
	var result: Array = []
	for key in materials.keys(): result.append(str(key) + "=" + _v0414_material_name(materials[key]))
	return result

func _v0414_house_hashes(house: Node3D) -> Dictionary:
	var result := {}
	for candidate in house.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		if node.mesh is ArrayMesh and node.mesh.get_surface_count() > 0: result[str(node.name)] = _v0406_vertex_hash(node.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX])
	return result

func _v0414_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0400_house.find_child(str(key), true, false) as MeshInstance3D
		if node: node.material_override = materials[key]

func _v0414_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root); DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_MAIN_HOUSE_OPENINGS_TRIM_CLOSE_COLOUR.png", Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5, root)
	var primary_gray := primary.duplicate(); primary_gray.convert(Image.FORMAT_L8); primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate(); close_gray.convert(Image.FORMAT_L8); close_gray.save_png(root.path_join("04_MAIN_HOUSE_OPENINGS_TRIM_CLOSE_GRAYSCALE.png"))
	_v0414_set_materials(v0414_before_materials)
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5)
	_v0414_set_materials(v0414_after_materials)
	await _v0414_capture_diagnostic(root)
	_v0414_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0414_write_audit(root); get_tree().quit(0)

func _v0414_capture_diagnostic(root: String) -> void:
	v0383_camera.position = Vector3(15.0, 16.0, 15.0); v0383_camera.size = 8.5; v0383_camera.look_at(Vector3(-7.1, 1.55, 2.55), Vector3.UP)
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8); sheet.fill(Color("#17140f")); var colours := [Color("#d92f24"), Color("#2fc34d"), Color("#3472d8"), Color("#e0b531"), Color("#b53bd0"), Color("#e07c31")]; var columns := 3; var rows := maxi(1, ceili(float(v0414_nodes.size()) / float(columns))); var tile_width := 1920 / columns; var tile_height := 1080 / rows
	for index in v0414_nodes.size():
		var node: MeshInstance3D = v0414_nodes[index]; var original := node.material_override; var diagnostic_material := StandardMaterial3D.new(); diagnostic_material.albedo_color = colours[index % colours.size()]; diagnostic_material.vertex_color_use_as_albedo = false; diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; node.material_override = diagnostic_material
		var layer := CanvasLayer.new(); var panel := ColorRect.new(); panel.color = Color(0.03, 0.025, 0.02, 0.92); panel.position = Vector2(12.0, 12.0); panel.size = Vector2(760.0, 84.0); var label := Label.new(); label.position = Vector2(10.0, 8.0); label.add_theme_font_size_override("font_size", 18); label.text = "v0.414 TEMPORARY OPENING/TRIM NODE ID\n" + str(v0414_classes[node.name]) + " | " + str(node.name) + " | existing node only"; panel.add_child(label); layer.add_child(panel); add_child(layer)
		await get_tree().process_frame; await RenderingServer.frame_post_draw; var image := get_viewport().get_texture().get_image(); image.convert(Image.FORMAT_RGBA8); image.resize(tile_width, tile_height, Image.INTERPOLATE_LANCZOS); sheet.blit_rect(image, Rect2i(0, 0, tile_width, tile_height), Vector2i((index % columns) * tile_width, (index / columns) * tile_height)); layer.free(); node.material_override = original
	sheet.save_png(root.path_join("05_TEMPORARY_OPENING_TRIM_NODE_ID.png"))

func _v0414_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_primary.convert(Image.FORMAT_RGBA8); primary.convert(Image.FORMAT_RGBA8); wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); wide.save_png(root.path_join("06_V0413_V0414_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_close.convert(Image.FORMAT_RGBA8); close.convert(Image.FORMAT_RGBA8); near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); near.save_png(root.path_join("07_V0413_V0414_HOUSE_CLOSE_COMPARISON.png"))

func _v0414_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0414-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0414_audit, "  "))

func _v0414_fail_closed(reason: String) -> void:
	v0414_audit = {"baselineCommit": "77b2b2289f76754cbc0644727f6c2e05ba216b69", "checkpoint": V0414_CHECKPOINT, "status": V0414_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": 0, "affectedNodeInventory": [], "excludedAdjacentInventory": v0414_excluded_inventory, "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "inheritedVertexColourChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}
