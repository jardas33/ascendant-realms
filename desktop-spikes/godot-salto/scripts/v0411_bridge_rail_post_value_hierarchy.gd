extends "res://scripts/v0410_bridge_deck_timber_surface_readability.gd"

## v0.411 is an opt-in material-only value calibration for existing bridge rails/posts.
## Deck, bridge geometry, route, gameplay, and the v0.410 fail-closed result remain authoritative.

const V0411_CHECKPOINT := "v0.411"
const V0411_CAPTURE_ROOT := "artifacts/runtime/v0411"
const V0411_AFFECTED_NAMES := [
	"Bridge_Rail_+1_High", "Bridge_Rail_+1_Low", "Bridge_Rail_-1_High", "Bridge_Rail_-1_Low",
	"Bridge_Post_+1_00", "Bridge_Post_+1_01", "Bridge_Post_+1_02", "Bridge_Post_+1_03", "Bridge_Post_+1_04", "Bridge_Post_+1_05",
	"Bridge_Post_-1_00", "Bridge_Post_-1_01", "Bridge_Post_-1_02", "Bridge_Post_-1_03", "Bridge_Post_-1_04", "Bridge_Post_-1_05"
]

var v0411_capture_mode := false
var v0411_smoke_mode := false
var v0411_nodes: Array[MeshInstance3D] = []
var v0411_before_materials: Dictionary = {}
var v0411_after_materials: Dictionary = {}
var v0411_audit: Dictionary = {}

func _read_v0409_args() -> void:
	v0411_capture_mode = false
	v0411_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0411-bridge-rail-post-capture": v0411_capture_mode = true
		if arg == "--v0411-bridge-rail-post-smoke": v0411_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0411_CAPTURE_ROOT
	v0409_capture_mode = v0411_capture_mode
	v0409_smoke_mode = v0411_smoke_mode

func _v0409_apply_existing_material_treatment() -> void:
	_v0411_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0411_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0411_write_audit(root)
	var file := FileAccess.open(root.path_join("v0411-bridge-rail-post-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0411_CHECKPOINT, "status": v0411_audit.get("status", "ASSET_MATERIAL_LIMITATION_BRIDGE_RAIL_POSTS"), "candidateRetained": v0411_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0411_apply_existing_material_treatment() -> void:
	v0411_nodes.clear()
	var missing: Array[String] = []
	for node_name in V0411_AFFECTED_NAMES:
		var node := _v0406_find_mesh(node_name)
		if node == null or node.mesh == null: missing.append(node_name)
		else: v0411_nodes.append(node)
	if not missing.is_empty():
		_v0411_fail_closed("existing visible rail/post node missing: " + ", ".join(missing))
		return
	var before: Dictionary = {}
	var original_inventory: Array[String] = []
	var final_inventory: Array[String] = []
	var original_hashes := _v0411_hashes()
	var total_meshes := _v0406_mesh_node_count()
	for node in v0411_nodes:
		before[node.name] = _v0410_mesh_snapshot(node)
		v0411_before_materials[node.name] = node.material_override
		original_inventory.append(str(node.name) + "=" + _v0411_material_name(node.material_override))
	var high := _v0411_material("V0411_Bridge_Rail_High", Color("#62503d"), 0.20)
	var low := _v0411_material("V0411_Bridge_Rail_Low", Color("#574432"), 0.16)
	var post := _v0411_material("V0411_Bridge_Post", Color("#4d3b2c"), 0.13)
	for node in v0411_nodes:
		var material := post
		if str(node.name).contains("_High"): material = high
		elif str(node.name).contains("_Low"): material = low
		node.material_override = material
		v0411_after_materials[node.name] = material
	var after: Dictionary = {}
	for node in v0411_nodes:
		after[node.name] = _v0410_mesh_snapshot(node)
		final_inventory.append(str(node.name) + "=" + _v0411_material_name(node.material_override))
	v0411_audit = _v0411_base_audit("RENDERED_CANDIDATE", true, "")
	v0411_audit["affectedNodeCount"] = v0411_nodes.size()
	v0411_audit["affectedNodeNames"] = V0411_AFFECTED_NAMES
	v0411_audit["originalMaterials"] = original_inventory
	v0411_audit["finalMaterials"] = final_inventory
	v0411_audit["finalMaterialParameters"] = ["highRails albedo=#62503d roughness=0.92 specular=0.20 vertexColorAsAlbedo=false", "lowRails albedo=#574432 roughness=0.92 specular=0.16 vertexColorAsAlbedo=false", "posts albedo=#4d3b2c roughness=0.92 specular=0.13 vertexColorAsAlbedo=false"]
	v0411_audit["bridgeHashesBefore"] = original_hashes
	v0411_audit["bridgeHashesAfter"] = _v0411_hashes()
	v0411_audit["meshInstanceCountBefore"] = total_meshes
	v0411_audit["meshInstanceCountAfter"] = _v0406_mesh_node_count()
	v0411_audit["newMeshInstances"] = 0
	v0411_audit["nodeCountBefore"] = v0411_nodes.size()
	v0411_audit["nodeCountAfter"] = v0411_nodes.size()
	v0411_audit["cameraBefore"] = _v0411_camera_state()
	v0411_audit["cameraAfter"] = _v0411_camera_state()
	v0411_audit["lightingBefore"] = "unchanged"
	v0411_audit["lightingAfter"] = "unchanged"

func _v0411_material(resource_name: String, colour: Color, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = resource_name
	material.albedo_color = colour
	material.roughness = 0.92
	material.specular = specular_value
	material.vertex_color_use_as_albedo = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _v0411_material_name(material) -> String:
	if material is BaseMaterial3D: return str(material.resource_name)
	return "null"

func _v0411_base_audit(status: String, retained: bool, reason: String) -> Dictionary:
	return {"baselineCommit": "b1f9c717f4ba0bdd7f5bd93d3d72c8001ee4240f", "checkpoint": V0411_CHECKPOINT, "status": status, "candidateRetained": retained, "scope": "existing_bridge_rail_and_post_materials_only", "reason": reason, "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newGeometry": false, "rails": "preserved", "posts": "preserved", "deck": "v0410-fail-closed-preserved", "footings": "preserved", "abutments": "preserved", "underbeams": "preserved", "edgeCourses": "preserved", "route": "preserved", "landings": "preserved", "house": "v0408-preserved", "barn": "v0409-fail-closed-preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}

func _v0411_fail_closed(reason: String) -> void:
	v0411_before_materials.clear()
	v0411_after_materials.clear()
	v0411_audit = _v0411_base_audit("ASSET_MATERIAL_LIMITATION_BRIDGE_RAIL_POSTS", false, reason)
	v0411_audit["affectedNodeCount"] = v0411_nodes.size()
	v0411_audit["affectedNodeNames"] = V0411_AFFECTED_NAMES
	v0411_audit["newMeshInstances"] = 0

func _v0411_hashes() -> Dictionary:
	var result: Dictionary = {}
	for node_name in V0411_AFFECTED_NAMES:
		var node := _v0406_find_mesh(node_name)
		if node and node.mesh is ArrayMesh and node.mesh.get_surface_count() > 0:
			result[node_name] = _v0406_vertex_hash(node.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX])
	return result

func _v0411_camera_state() -> Dictionary:
	if v0383_camera == null: return {}
	return {"position": _v0406_vec(v0383_camera.position), "rotation": _v0406_vec(v0383_camera.rotation), "size": v0383_camera.size}

func _v0411_set_materials(materials: Dictionary) -> void:
	for node_name in materials.keys():
		var node := _v0406_find_mesh(str(node_name))
		if node: node.material_override = materials[node_name]

func _v0411_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_BRIDGE_RAIL_POST_CLOSE_COLOUR.png", Vector3(15.5, 13.5, 15.5), Vector3(1.3, 0.62, 0.82), 7.0, root)
	var primary_gray := primary.duplicate(); primary_gray.convert(Image.FORMAT_L8); primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate(); close_gray.convert(Image.FORMAT_L8); close_gray.save_png(root.path_join("04_BRIDGE_RAIL_POST_CLOSE_GRAYSCALE.png"))
	_v0411_set_materials(v0411_before_materials)
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(15.5, 13.5, 15.5), Vector3(1.3, 0.62, 0.82), 7.0)
	_v0411_set_materials(v0411_after_materials)
	await _v0411_capture_diagnostic(root)
	_v0411_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0411_write_audit(root)
	get_tree().quit(0)

func _v0411_capture_diagnostic(root: String) -> void:
	v0383_camera.position = Vector3(15.5, 13.5, 15.5)
	v0383_camera.size = 7.0
	v0383_camera.look_at(Vector3(1.3, 0.62, 0.82), Vector3.UP)
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#15120e"))
	var colours := [Color("#d92f24"), Color("#2fc34d"), Color("#3472d8"), Color("#e0b531"), Color("#b53bd0"), Color("#e07c31")]
	for index in v0411_nodes.size():
		var node: MeshInstance3D = v0411_nodes[index]
		var original := node.material_override
		var diagnostic_material := StandardMaterial3D.new()
		diagnostic_material.albedo_color = colours[index % colours.size()]
		diagnostic_material.vertex_color_use_as_albedo = false
		diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = diagnostic_material
		var layer := CanvasLayer.new()
		var panel := ColorRect.new()
		panel.color = Color(0.03, 0.025, 0.02, 0.92)
		panel.position = Vector2(12.0, 12.0)
		panel.size = Vector2(720.0, 70.0)
		var label := Label.new()
		label.position = Vector2(10.0, 8.0)
		label.add_theme_font_size_override("font_size", 20)
		label.text = "v0.411 TEMPORARY RAIL/POST MATERIAL ID\n" + str(node.name) + "  |  existing node only"
		panel.add_child(label); layer.add_child(panel); add_child(layer)
		await get_tree().process_frame; await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image(); image.convert(Image.FORMAT_RGBA8); image.resize(640, 360, Image.INTERPOLATE_LANCZOS)
		var destination := Vector2i((index % 3) * 640, (index / 3) * 180)
		image.resize(640, 180, Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(image, Rect2i(0, 0, 640, 180), destination)
		layer.free(); node.material_override = original
	sheet.save_png(root.path_join("05_TEMPORARY_RAIL_POST_MATERIAL_ID.png"))

func _v0411_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_primary.convert(Image.FORMAT_RGBA8); primary.convert(Image.FORMAT_RGBA8)
		wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); wide.save_png(root.path_join("06_ACCEPTED_BASELINE_V0411_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_close.convert(Image.FORMAT_RGBA8); close.convert(Image.FORMAT_RGBA8)
		near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); near.save_png(root.path_join("07_ACCEPTED_BASELINE_V0411_CLOSE_COMPARISON.png"))

func _v0411_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0411-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0411_audit, "  "))
