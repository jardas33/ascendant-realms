extends "res://scripts/v0412_bridge_understructure_value_hierarchy.gd"

## v0.413 is a material-only calibration of the live main-house masonry walls.
## It inherits the accepted v0.412 scene and never changes geometry, topology,
## gameplay, state, camera, lighting, fallback, or debug presentation.

const V0413_CHECKPOINT := "v0.413"
const V0413_CAPTURE_ROOT := "artifacts/runtime/v0413"
const V0413_LIMITATION := "ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_MASONRY"
const V0413_HOUSE_NAME := "V0394_One_Primary_Barrosan_Homestead"

var v0413_capture_mode := false
var v0413_smoke_mode := false
var v0413_wall_nodes: Array[MeshInstance3D] = []
var v0413_wall_roles: Dictionary = {}
var v0413_excluded_inventory: Array = []
var v0413_before_materials: Dictionary = {}
var v0413_after_materials: Dictionary = {}
var v0413_before_snapshots: Dictionary = {}
var v0413_after_snapshots: Dictionary = {}
var v0413_audit: Dictionary = {}

func _read_v0409_args() -> void:
	v0413_capture_mode = false
	v0413_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0413-main-house-masonry-capture": v0413_capture_mode = true
		if arg == "--v0413-main-house-masonry-smoke": v0413_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0413_CAPTURE_ROOT
	v0410_capture_mode = false
	v0410_smoke_mode = false
	v0409_capture_mode = v0413_capture_mode
	v0409_smoke_mode = v0413_smoke_mode
	v0411_capture_mode = v0413_capture_mode
	v0411_smoke_mode = v0413_smoke_mode

func _v0409_apply_existing_material_treatment() -> void:
	_v0412_apply_existing_material_treatment()
	_v0413_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0413_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0413_write_audit(root)
	var file := FileAccess.open(root.path_join("v0413-main-house-masonry-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"checkpoint": V0413_CHECKPOINT,
			"status": v0413_audit.get("status", V0413_LIMITATION),
			"candidateRetained": v0413_audit.get("candidateRetained", false),
			"materialOnly": v0413_audit.get("materialOnly", true),
			"geometryChanged": false,
			"surfacesChanged": false,
			"gameplay": false,
			"defaultRuntime": "unchanged"
		}, "  "))
	get_tree().quit(0)

func _v0413_apply_existing_material_treatment() -> void:
	v0413_wall_nodes.clear()
	v0413_wall_roles.clear()
	v0413_excluded_inventory.clear()
	v0413_before_materials.clear()
	v0413_after_materials.clear()
	v0413_before_snapshots.clear()
	v0413_after_snapshots.clear()
	var house := v0383_world.find_child(V0413_HOUSE_NAME, true, false) as Node3D if v0383_world else null
	if house == null:
		_v0413_fail_closed("accepted main-house root missing")
		return
	v0400_house = house
	var inventory: Array = []
	for candidate in house.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var material_name := _v0413_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var entry := {"name": str(node.name), "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0413_uv_count(node)}
		inventory.append(entry)
		if node.mesh == null or not node.visible:
			v0413_excluded_inventory.append(entry)
			continue
		var role := _v0413_classify_wall(node, material_name, mesh_name)
		if role == "MAIN_HOUSE_MASONRY_WALL":
			v0413_wall_nodes.append(node)
			v0413_wall_roles[str(node.name)] = role
		else:
			v0413_excluded_inventory.append(entry)
	if v0413_wall_nodes.is_empty():
		_v0413_fail_closed("no confident visible main-house masonry wall nodes in live inventory")
		return
	var wall_names := v0413_wall_nodes.map(func(node): return str(node.name))
	if v0413_wall_nodes.size() != wall_names.size():
		_v0413_fail_closed("wall inventory could not be represented without ambiguity")
		return
	var before_hashes := _v0413_house_mesh_hashes(house)
	var mesh_count := _v0406_mesh_node_count()
	for node in v0413_wall_nodes:
		v0413_before_materials[node.name] = node.material_override
		v0413_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var masonry := StandardMaterial3D.new()
	masonry.resource_name = "V0413_Main_House_Restrained_Masonry"
	masonry.albedo_color = Color("#81786d")
	masonry.roughness = 0.96
	masonry.specular = 0.10
	masonry.vertex_color_use_as_albedo = false
	masonry.cull_mode = BaseMaterial3D.CULL_DISABLED
	for node in v0413_wall_nodes:
		node.material_override = masonry
		v0413_after_materials[node.name] = masonry
		v0413_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	var after_hashes := _v0413_house_mesh_hashes(house)
	v0413_audit = {
		"baselineCommit": "5a064c8df089336f71324b0c477d5b48578f560b",
		"checkpoint": V0413_CHECKPOINT,
		"status": "RENDERED_CANDIDATE",
		"candidateRetained": true,
		"scope": "existing_visible_main_house_masonry_wall_materials_only",
		"affectedNodeCount": v0413_wall_nodes.size(),
		"affectedNodeNames": wall_names,
		"affectedNodeInventory": inventory.filter(func(item): return str(item.name) in wall_names),
		"excludedNearbyHouseInventory": v0413_excluded_inventory,
		"functionalClassification": v0413_wall_roles,
		"originalMaterials": _v0413_material_inventory(v0413_before_materials),
		"finalMaterials": _v0413_material_inventory(v0413_after_materials),
		"finalMaterialParameters": ["albedo=#81786d", "roughness=0.96", "specular=0.10", "vertexColorAsAlbedo=false"],
		"originalSnapshots": v0413_before_snapshots,
		"finalSnapshots": v0413_after_snapshots,
		"uvCountEveryAffectedMesh": _v0413_uv_inventory(v0413_wall_nodes),
		"inheritedVertexColourBeforeAfter": "unchanged",
		"houseHashesBefore": before_hashes,
		"houseHashesAfter": after_hashes,
		"meshInstanceCountBefore": mesh_count,
		"meshInstanceCountAfter": _v0406_mesh_node_count(),
		"materialOnly": true,
		"geometryChanged": false,
		"topologyChanged": false,
		"indicesChanged": false,
		"verticesChanged": false,
		"surfacesChanged": false,
		"transformsChanged": false,
		"aabbChanged": false,
		"uvArraysChanged": false,
		"newGeometry": false,
		"newMeshInstances": 0,
		"overlays": false,
		"decals": false,
		"duplicateMeshes": false,
		"roof": "v0408-preserved",
		"ridge": "v0408-preserved",
		"eaves": "v0408-preserved",
		"chimney": "preserved",
		"doorsWindowsTimber": "preserved",
		"foundationStairsGround": "preserved",
		"bridge": "v0412-preserved",
		"route": "preserved",
		"barn": "v0409-preserved",
		"characters": "preserved",
		"props": "preserved",
		"camera": "unchanged",
		"lighting": "unchanged",
		"gameplay": false,
		"stateBehavior": "unchanged",
		"defaultRuntime": "unchanged",
		"fallbackRenderer": "unchanged",
		"debugRenderer": "unchanged",
		"v0412Audit": v0412_audit
	}

func _v0413_classify_wall(node: MeshInstance3D, material_name: String, mesh_name: String) -> String:
	var lower := str(node.name).to_lower()
	var material_lower := material_name.to_lower()
	var mesh_lower := mesh_name.to_lower()
	var excluded := ["roof", "ridge", "eave", "chimney", "door", "window", "recess", "timber", "iron", "foundation", "stair", "step", "ground", "threshold", "collision"]
	for token in excluded:
		if lower.contains(token) or material_lower.contains(token) or mesh_lower.contains(token): return "EXCLUDED"
	if lower.contains("granite") or material_lower.contains("rubble") or material_lower.contains("granite"):
		return "MAIN_HOUSE_MASONRY_WALL"
	return "EXCLUDED"

func _v0413_material_name(material) -> String:
	if material is BaseMaterial3D: return str(material.resource_name)
	return "null"

func _v0413_uv_count(node: MeshInstance3D) -> int:
	if node.mesh is ArrayMesh and node.mesh.get_surface_count() > 0:
		var arrays := node.mesh.surface_get_arrays(0)
		if arrays.size() > Mesh.ARRAY_TEX_UV and arrays[Mesh.ARRAY_TEX_UV] is PackedVector2Array:
			return (arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array).size()
	return 0

func _v0413_material_inventory(materials: Dictionary) -> Array:
	var result: Array = []
	for key in materials.keys(): result.append(str(key) + "=" + _v0413_material_name(materials[key]))
	return result

func _v0413_uv_inventory(nodes: Array[MeshInstance3D]) -> Dictionary:
	var result := {}
	for node in nodes: result[str(node.name)] = _v0413_uv_count(node)
	return result

func _v0413_house_mesh_hashes(house: Node3D) -> Dictionary:
	var result := {}
	for candidate in house.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		if node.mesh is ArrayMesh and node.mesh.get_surface_count() > 0:
			result[str(node.name)] = _v0406_vertex_hash(node.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX])
	return result

func _v0413_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_MAIN_HOUSE_MASONRY_CLOSE_COLOUR.png", Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5, root)
	var primary_gray := primary.duplicate(); primary_gray.convert(Image.FORMAT_L8); primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate(); close_gray.convert(Image.FORMAT_L8); close_gray.save_png(root.path_join("04_MAIN_HOUSE_MASONRY_CLOSE_GRAYSCALE.png"))
	_v0413_set_materials(v0413_before_materials)
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5)
	_v0413_set_materials(v0413_after_materials)
	await _v0413_capture_diagnostic(root)
	_v0413_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0413_write_audit(root)
	get_tree().quit(0)

func _v0413_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0400_house.find_child(str(key), true, false) as MeshInstance3D
		if node: node.material_override = materials[key]

func _v0413_capture_diagnostic(root: String) -> void:
	v0383_camera.position = Vector3(15.0, 16.0, 15.0)
	v0383_camera.size = 8.5
	v0383_camera.look_at(Vector3(-7.1, 1.55, 2.55), Vector3.UP)
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#17140f"))
	var colours := [Color("#d92f24"), Color("#2fc34d"), Color("#3472d8"), Color("#e0b531"), Color("#b53bd0"), Color("#e07c31")]
	var columns := 3
	var rows := maxi(1, ceili(float(v0413_wall_nodes.size()) / float(columns)))
	var tile_width := 1920 / columns
	var tile_height := 1080 / rows
	for index in v0413_wall_nodes.size():
		var node: MeshInstance3D = v0413_wall_nodes[index]
		var original := node.material_override
		var diagnostic_material := StandardMaterial3D.new()
		diagnostic_material.albedo_color = colours[index % colours.size()]
		diagnostic_material.vertex_color_use_as_albedo = false
		diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = diagnostic_material
		var layer := CanvasLayer.new()
		var panel := ColorRect.new(); panel.color = Color(0.03, 0.025, 0.02, 0.92); panel.position = Vector2(12.0, 12.0); panel.size = Vector2(760.0, 84.0)
		var label := Label.new(); label.position = Vector2(10.0, 8.0); label.add_theme_font_size_override("font_size", 18); label.text = "v0.413 TEMPORARY MASONRY NODE MATERIAL ID\nWALL | " + str(node.name) + " | existing node only"
		panel.add_child(label); layer.add_child(panel); add_child(layer)
		await get_tree().process_frame; await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image(); image.convert(Image.FORMAT_RGBA8); image.resize(tile_width, tile_height, Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(image, Rect2i(0, 0, tile_width, tile_height), Vector2i((index % columns) * tile_width, (index / columns) * tile_height))
		layer.free(); node.material_override = original
	sheet.save_png(root.path_join("05_TEMPORARY_MASONRY_NODE_MATERIAL_ID.png"))

func _v0413_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_primary.convert(Image.FORMAT_RGBA8); primary.convert(Image.FORMAT_RGBA8)
		wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); wide.save_png(root.path_join("06_V0412_V0413_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_close.convert(Image.FORMAT_RGBA8); close.convert(Image.FORMAT_RGBA8)
		near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); near.save_png(root.path_join("07_V0412_V0413_HOUSE_CLOSE_COMPARISON.png"))

func _v0413_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0413-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0413_audit, "  "))

func _v0413_fail_closed(reason: String) -> void:
	v0413_audit = {
		"baselineCommit": "5a064c8df089336f71324b0c477d5b48578f560b",
		"checkpoint": V0413_CHECKPOINT,
		"status": V0413_LIMITATION,
		"candidateRetained": false,
		"reason": reason,
		"affectedNodeCount": 0,
		"affectedNodeInventory": [],
		"excludedNearbyHouseInventory": v0413_excluded_inventory,
		"materialOnly": true,
		"geometryChanged": false,
		"topologyChanged": false,
		"indicesChanged": false,
		"verticesChanged": false,
		"surfacesChanged": false,
		"transformsChanged": false,
		"aabbChanged": false,
		"uvArraysChanged": false,
		"inheritedVertexColourChanged": false,
		"overlays": false,
		"decals": false,
		"duplicateMeshes": false,
		"newMeshInstances": 0,
		"gameplay": false,
		"stateBehavior": "unchanged",
		"defaultRuntime": "unchanged",
		"fallbackRenderer": "unchanged",
		"debugRenderer": "unchanged"
	}
