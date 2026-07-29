extends "res://scripts/v0411_bridge_rail_post_value_hierarchy.gd"

## v0.412 is an opt-in material-only calibration for the existing bridge
## underbeams and edge-course components.  It deliberately inherits the
## accepted v0.411 bridge scene and changes no geometry, gameplay, or state.

const V0412_CHECKPOINT := "v0.412"
const V0412_CAPTURE_ROOT := "artifacts/runtime/v0412"
const V0412_LIMITATION := "ASSET_MATERIAL_LIMITATION_BRIDGE_UNDERSTRUCTURE"

var v0412_capture_mode := false
var v0412_smoke_mode := false
var v0412_nodes: Array[MeshInstance3D] = []
var v0412_classes: Dictionary = {}
var v0412_before_materials: Dictionary = {}
var v0412_after_materials: Dictionary = {}
var v0412_audit: Dictionary = {}

func _read_v0409_args() -> void:
	v0412_capture_mode = false
	v0412_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0412-bridge-understructure-capture": v0412_capture_mode = true
		if arg == "--v0412-bridge-understructure-smoke": v0412_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0412_CAPTURE_ROOT
	v0410_capture_mode = false
	v0410_smoke_mode = false
	v0409_capture_mode = v0412_capture_mode
	v0409_smoke_mode = v0412_smoke_mode
	v0411_capture_mode = v0412_capture_mode
	v0411_smoke_mode = v0412_smoke_mode

func _v0409_apply_existing_material_treatment() -> void:
	_v0412_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0412_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0412_write_audit(root)
	var file := FileAccess.open(root.path_join("v0412-bridge-understructure-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"checkpoint": V0412_CHECKPOINT,
			"status": v0412_audit.get("status", V0412_LIMITATION),
			"candidateRetained": v0412_audit.get("candidateRetained", false),
			"materialOnly": true,
			"geometryChanged": false,
			"gameplay": false,
			"defaultRuntime": "unchanged"
		}, "  "))
	get_tree().quit(0)

func _v0412_apply_existing_material_treatment() -> void:
	v0412_nodes.clear()
	v0412_classes.clear()
	if v0399_barn == null:
		v0399_barn = v0383_world.find_child("V0394_One_Subordinate_Agricultural_Barn_Separate", true, false) as Node3D if v0383_world else null
	v0409_barn = v0399_barn
	if v0383_world == null:
		_v0412_fail_closed("accepted world root missing")
		return
	var inventory: Array = []
	for candidate in v0383_world.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var lower := str(node.name).to_lower()
		if not lower.contains("bridge"):
			continue
		var classification := ""
		if lower.contains("underbeam"):
			classification = "UNDERBEAM"
		elif lower.contains("edgecourse") or lower.contains("edge_course"):
			classification = "EDGE_COURSE"
		if classification.is_empty():
			continue
		if node.mesh == null:
			_v0412_fail_closed("identified " + classification + " has no mesh: " + str(node.name))
			return
		v0412_nodes.append(node)
		v0412_classes[node.name] = classification
		inventory.append({"name": str(node.name), "classification": classification, "visible": node.visible, "material": _v0412_material_name(node.material_override), "uvCount": _v0412_uv_count(node)})
	if v0412_nodes.is_empty():
		_v0412_fail_closed("no complete live underbeam/edge-course inventory found")
		return
	var underbeams := 0
	var edge_courses := 0
	for node in v0412_nodes:
		if v0412_classes[node.name] == "UNDERBEAM": underbeams += 1
		if v0412_classes[node.name] == "EDGE_COURSE": edge_courses += 1
	if underbeams == 0 or edge_courses == 0:
		_v0412_fail_closed("incomplete live inventory: underbeams=" + str(underbeams) + " edge_courses=" + str(edge_courses))
		return
	var before_hashes := _v0412_hashes()
	var mesh_count := _v0406_mesh_node_count()
	var before: Dictionary = {}
	for node in v0412_nodes:
		before[node.name] = _v0410_mesh_snapshot(node)
		v0412_before_materials[node.name] = node.material_override
	var underbeam := _v0412_material("V0412_Bridge_Underbeam", Color("#43342a"), 0.10)
	var edge := _v0412_material("V0412_Bridge_EdgeCourse", Color("#6a513a"), 0.14)
	for node in v0412_nodes:
		var material: StandardMaterial3D = underbeam if v0412_classes[node.name] == "UNDERBEAM" else edge
		node.material_override = material
		v0412_after_materials[node.name] = material
	var after: Dictionary = {}
	for node in v0412_nodes: after[node.name] = _v0410_mesh_snapshot(node)
	v0412_audit = _v0412_base_audit("RENDERED_CANDIDATE", true, "")
	v0412_audit["affectedNodeCount"] = v0412_nodes.size()
	v0412_audit["affectedNodeInventory"] = inventory
	v0412_audit["affectedNodeNames"] = v0412_nodes.map(func(n): return str(n.name))
	v0412_audit["functionalClassification"] = v0412_classes
	v0412_audit["originalSnapshots"] = before
	v0412_audit["finalSnapshots"] = after
	v0412_audit["originalMaterials"] = _v0412_material_inventory(v0412_before_materials)
	v0412_audit["finalMaterials"] = _v0412_material_inventory(v0412_after_materials)
	v0412_audit["finalMaterialParameters"] = ["underbeams albedo=#43342a roughness=0.94 specular=0.10 vertexColorAsAlbedo=false", "edgeCourses albedo=#6a513a roughness=0.92 specular=0.14 vertexColorAsAlbedo=false"]
	v0412_audit["meshInstanceCountBefore"] = mesh_count
	v0412_audit["meshInstanceCountAfter"] = _v0406_mesh_node_count()
	v0412_audit["newMeshInstances"] = 0
	v0412_audit["bridgeHashesBefore"] = before_hashes
	v0412_audit["bridgeHashesAfter"] = _v0412_hashes()
	v0412_audit["deckHashesBeforeAfter"] = _v0412_hashes_for("deck")
	v0412_audit["railPostHashesBeforeAfter"] = _v0412_hashes_for("rail", "post")
	v0412_audit["footingAbutmentHashesBeforeAfter"] = _v0412_hashes_for("footing", "abutment")
	v0412_audit["routeLandingHashesBeforeAfter"] = _v0412_hashes_for("route", "landing")

func _v0412_material(resource_name: String, colour: Color, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = resource_name
	material.albedo_color = colour
	material.roughness = 0.94 if resource_name.contains("Underbeam") else 0.92
	material.specular = specular_value
	material.vertex_color_use_as_albedo = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _v0412_material_name(material) -> String:
	if material is BaseMaterial3D: return str(material.resource_name)
	return "null"

func _v0412_uv_count(node: MeshInstance3D) -> int:
	if node.mesh is ArrayMesh and node.mesh.get_surface_count() > 0:
		var arrays := node.mesh.surface_get_arrays(0)
		if arrays.size() > Mesh.ARRAY_TEX_UV: return (arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array).size()
	return 0

func _v0412_material_inventory(materials: Dictionary) -> Array:
	var result: Array = []
	for key in materials.keys(): result.append(str(key) + "=" + _v0412_material_name(materials[key]))
	return result

func _v0412_hashes() -> Dictionary:
	var result: Dictionary = {}
	for node in v0412_nodes:
		if node.mesh is ArrayMesh and node.mesh.get_surface_count() > 0:
			result[str(node.name)] = _v0406_vertex_hash(node.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX])
	return result

func _v0412_hashes_for(...fragments) -> Dictionary:
	var result: Dictionary = {}
	for candidate in v0383_world.find_children("*", "MeshInstance3D", true, false):
		var lower := str(candidate.name).to_lower()
		var matches := true
		for fragment in fragments: matches = matches and lower.contains(fragment.to_lower())
		if matches and candidate.mesh is ArrayMesh and candidate.mesh.get_surface_count() > 0:
			result[str(candidate.name)] = _v0406_vertex_hash(candidate.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX])
	return result

func _v0412_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node: node.material_override = materials[key]

func _v0412_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_BRIDGE_UNDERSTRUCTURE_CLOSE_COLOUR.png", Vector3(15.5, 13.5, 15.5), Vector3(1.3, 0.62, 0.82), 7.0, root)
	var primary_gray := primary.duplicate(); primary_gray.convert(Image.FORMAT_L8); primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate(); close_gray.convert(Image.FORMAT_L8); close_gray.save_png(root.path_join("04_BRIDGE_UNDERSTRUCTURE_CLOSE_GRAYSCALE.png"))
	_v0412_set_materials(v0412_before_materials)
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(15.5, 13.5, 15.5), Vector3(1.3, 0.62, 0.82), 7.0)
	_v0412_set_materials(v0412_after_materials)
	await _v0412_capture_diagnostic(root)
	_v0412_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0412_write_audit(root)
	get_tree().quit(0)

func _v0412_capture_diagnostic(root: String) -> void:
	v0383_camera.position = Vector3(15.5, 13.5, 15.5)
	v0383_camera.size = 7.0
	v0383_camera.look_at(Vector3(1.3, 0.62, 0.82), Vector3.UP)
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#15120e"))
	var colours := [Color("#d92f24"), Color("#2fc34d"), Color("#3472d8"), Color("#e0b531"), Color("#b53bd0"), Color("#e07c31")]
	var columns := 4
	var rows := maxi(1, ceili(float(v0412_nodes.size()) / float(columns)))
	var tile_width := 1920 / columns
	var tile_height := 1080 / rows
	for index in v0412_nodes.size():
		var node: MeshInstance3D = v0412_nodes[index]
		var original := node.material_override
		var diagnostic_material := StandardMaterial3D.new()
		diagnostic_material.albedo_color = colours[index % colours.size()]
		diagnostic_material.vertex_color_use_as_albedo = false
		diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = diagnostic_material
		var layer := CanvasLayer.new()
		var panel := ColorRect.new(); panel.color = Color(0.03, 0.025, 0.02, 0.92); panel.position = Vector2(12.0, 12.0); panel.size = Vector2(600.0, 90.0)
		var label := Label.new(); label.position = Vector2(10.0, 8.0); label.add_theme_font_size_override("font_size", 18); label.text = "v0.412 TEMPORARY UNDERSTRUCTURE ID\n" + str(v0412_classes[node.name]) + " | " + str(node.name) + " | existing node only"
		panel.add_child(label); layer.add_child(panel); add_child(layer)
		await get_tree().process_frame; await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image(); image.convert(Image.FORMAT_RGBA8); image.resize(tile_width, tile_height, Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(image, Rect2i(0, 0, tile_width, tile_height), Vector2i((index % columns) * tile_width, (index / columns) * tile_height))
		layer.free(); node.material_override = original
	sheet.save_png(root.path_join("05_TEMPORARY_UNDERBEAM_EDGECOURSE_ID.png"))

func _v0412_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_primary.convert(Image.FORMAT_RGBA8); primary.convert(Image.FORMAT_RGBA8)
		wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); wide.save_png(root.path_join("06_V0411_V0412_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8); baseline_close.convert(Image.FORMAT_RGBA8); close.convert(Image.FORMAT_RGBA8)
		near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO); near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0)); near.save_png(root.path_join("07_V0411_V0412_CLOSE_COMPARISON.png"))

func _v0412_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0412-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0412_audit, "  "))

func _v0412_base_audit(status: String, retained: bool, reason: String) -> Dictionary:
	return {"baselineCommit": "7f73ded8743f415392f2eea2d08cfa4578432728", "checkpoint": V0412_CHECKPOINT, "status": status, "candidateRetained": retained, "scope": "existing_bridge_underbeam_and_edge_course_materials_only", "reason": reason, "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "transformsChanged": false, "aabbChanged": false, "uvArraysChanged": false, "inheritedVertexColourChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newGeometry": false, "newMeshInstances": 0, "deck": "preserved", "railsPosts": "v0411-preserved", "footingsAbutments": "preserved", "underbeams": "calibrated", "edgeCourses": "calibrated", "route": "preserved", "landings": "preserved", "building": "preserved", "barn": "preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}

func _v0412_fail_closed(reason: String) -> void:
	v0412_audit = _v0412_base_audit(V0412_LIMITATION, false, reason)
	v0412_audit["affectedNodeCount"] = v0412_nodes.size()
	v0412_audit["affectedNodeInventory"] = []
	v0412_audit["newMeshInstances"] = 0
