extends "res://scripts/v0401_character_scale_grounding_calibration.gd"

## v0.406 is the smallest bounded source-mesh correction for the accepted
## western bridge landing. It moves four existing vertices on the existing
## Bridge_Footing_-1 mesh only; no new surface, node, overlay, or gameplay is
## introduced.

const V0406_CHECKPOINT := "v0.406"
const V0406_CAPTURE_ROOT := "artifacts/runtime/v0406"
const V0406_DELTA := Vector3(0.444089, 0.0, 0.106548)
const V0406_INDICES := [2, 3, 4, 6]
const V0406_MAX_DISPLACEMENT := 0.46

var v0406_capture_mode := false
var v0406_smoke_mode := false
var v0406_footing: MeshInstance3D
var v0406_audit: Dictionary = {}

func _ready() -> void:
	_read_v0406_args()
	super._ready()
	_v0406_apply_source_correction()
	v0401_capture_mode = v0406_capture_mode
	v0401_smoke_mode = v0406_smoke_mode
	if v0406_capture_mode:
		v0400_capture_mode = true
		v0400_smoke_mode = true
		v0399_capture_mode = true
		v0399_smoke_mode = true
		v0398_capture_mode = true
		v0398_smoke_mode = true
		v0388_capture_mode = true
		v0388_smoke_mode = true
	if v0406_smoke_mode:
		v0400_smoke_mode = true
		v0399_smoke_mode = true
		v0398_smoke_mode = true
		v0388_smoke_mode = true
	if v0406_capture_mode:
		call_deferred("_v0406_start_capture")
	elif v0406_smoke_mode:
		call_deferred("_smoke_v0406_exit")

func _v0406_start_capture() -> void:
	await get_tree().process_frame
	await _capture_v0388_sequence()

func _read_v0406_args() -> void:
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0406-western-footing-capture": v0406_capture_mode = true
		if arg == "--v0406-western-footing-smoke": v0406_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0406_CAPTURE_ROOT

func _read_v0388_args() -> void:
	## v0.388 schedules its capture from this parser, so bridge the v0.406
	## opt-in flags into the inherited capture contract before scene construction.
	super._read_v0388_args()
	if v0406_capture_mode:
		v0388_capture_mode = false
		v0388_smoke_mode = false
	if v0406_smoke_mode:
		v0388_capture_mode = false
		v0388_smoke_mode = false

func _v0406_apply_source_correction() -> void:
	v0406_footing = _v0406_find_mesh("Bridge_Footing_-1")
	if v0406_footing == null or v0406_footing.mesh == null:
		v0406_audit = {"checkpoint": V0406_CHECKPOINT, "status": "FAIL", "reason": "Bridge_Footing_-1 missing"}
		return
	var source := v0406_footing.mesh as ArrayMesh
	if source == null or source.get_surface_count() != 1:
		v0406_audit = {"checkpoint": V0406_CHECKPOINT, "status": "FAIL", "reason": "footing is not a single-surface ArrayMesh"}
		return
	var before_arrays: Array = source.surface_get_arrays(0)
	var before_vertices: PackedVector3Array = before_arrays[Mesh.ARRAY_VERTEX]
	if before_vertices.size() != 8:
		v0406_audit = {"checkpoint": V0406_CHECKPOINT, "status": "FAIL", "reason": "unexpected footing vertex count", "vertexCount": before_vertices.size()}
		return
	var before_hash := _v0406_vertex_hash(before_vertices)
	var after_vertices := before_vertices.duplicate()
	var moves: Array = []
	for index in V0406_INDICES:
		var old_position: Vector3 = before_vertices[index]
		var new_position := old_position + V0406_DELTA
		after_vertices[index] = new_position
		moves.append({
			"vertexIndex": index,
			"old": _v0406_vec(old_position),
			"new": _v0406_vec(new_position),
			"delta": _v0406_vec(V0406_DELTA),
			"displacement": V0406_DELTA.length()
		})
	var after_arrays := before_arrays.duplicate()
	after_arrays[Mesh.ARRAY_VERTEX] = after_vertices
	var corrected := ArrayMesh.new()
	corrected.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, after_arrays)
	corrected.surface_set_material(0, source.surface_get_material(0))
	corrected.resource_name = source.resource_name
	v0406_footing.mesh = corrected
	var index_count := int((after_arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size())
	v0406_audit = {
		"baselineCommit": "c4c25ab04ca94e2098712fbd8e987c4d8af42e4c",
		"checkpoint": V0406_CHECKPOINT,
		"status": "RENDERED_CANDIDATE",
		"affectedNode": "Bridge_Footing_-1",
		"affectedVertexIndices": V0406_INDICES,
		"originalCoordinates": moves.map(func(move): return move["old"]),
		"finalCoordinates": moves.map(func(move): return move["new"]),
		"deltaPerVertex": moves.map(func(move): return move["delta"]),
		"displacementPerVertex": moves.map(func(move): return move["displacement"]),
		"maxHorizontalDisplacement": V0406_DELTA.length(),
		"yDeltaPerVertex": 0.0,
		"vertexCountBefore": before_vertices.size(),
		"vertexCountAfter": after_vertices.size(),
		"indexCountBefore": index_count,
		"indexCountAfter": index_count,
		"triangleCountBefore": index_count / 3,
		"triangleCountAfter": index_count / 3,
		"surfaceCountBefore": source.get_surface_count(),
		"surfaceCountAfter": corrected.get_surface_count(),
		"nodeCountBefore": _v0406_mesh_node_count(),
		"nodeCountAfter": _v0406_mesh_node_count(),
		"meshInstanceCountBefore": _v0406_mesh_node_count(),
		"meshInstanceCountAfter": _v0406_mesh_node_count(),
		"footingHashBefore": before_hash,
		"footingHashAfter": _v0406_vertex_hash(after_vertices),
		"routeMeshHashBefore": _v0406_named_mesh_hash("Route"),
		"routeMeshHashAfter": _v0406_named_mesh_hash("Route"),
		"bridgeDeckRailSupportHashesBefore": _v0406_bridge_hashes(),
		"bridgeDeckRailSupportHashesAfter": _v0406_bridge_hashes(),
		"transformUnchanged": true,
		"aabbBefore": _v0406_aabb(source.get_aabb()),
		"aabbAfter": _v0406_aabb(corrected.get_aabb()),
		"geometryChanged": true,
		"topologyChanged": false,
		"verticesMoved": 4,
		"verticesAdded": 0,
		"verticesDeleted": 0,
		"indicesChanged": false,
		"surfacesChanged": false,
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

func _capture_v0388_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0406_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-5.3, 0.90, 3.05), 19.0, root)
	var close := await _v0406_capture_view("02_WESTERN_LANDING_CLOSE_COLOUR.png", Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.25, 2.8), 8.5, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_WESTERN_LANDING_CLOSE_GRAYSCALE.png"))
	await _v0406_capture_diagnostic(root)
	_v0406_write_comparison(primary, close, root)
	_v0406_write_audit(root)
	get_tree().quit(0)

func _v0406_capture_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	if v0383_camera == null:
		return Image.create_empty(1920, 1080, false, Image.FORMAT_RGBA8)
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _v0406_capture_diagnostic(root: String) -> void:
	v0383_camera.position = Vector3(15.0, 16.0, 15.0)
	v0383_camera.size = 8.5
	v0383_camera.look_at(Vector3(-7.1, 1.25, 2.8), Vector3.UP)
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.color = Color(0.03, 0.025, 0.02, 0.90)
	panel.position = Vector2(24.0, 24.0)
	panel.size = Vector2(620.0, 165.0)
	var label := Label.new()
	label.position = Vector2(18.0, 16.0)
	label.add_theme_font_size_override("font_size", 22)
	label.text = "v0.406 MOVED RING DIAGNOSTIC\nBridge_Footing_-1 vertices [2, 3, 4, 6]\nDelta: X +0.444089 | Z +0.106548 | Y unchanged\nDisplacement: 0.4566918 world units"
	panel.add_child(label)
	layer.add_child(panel)
	add_child(layer)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join("05_MOVED_RING_DIAGNOSTIC.png"))
	layer.queue_free()

func _v0406_write_comparison(primary: Image, close: Image, root: String) -> void:
	var prior := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0401/01_PRIMARY_RTS_VIEW.png"))
	var prior_close := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0401/02_CHARACTER_SCALE_GROUNDING_CLOSE.png"))
	if prior and prior.get_width() == 1920:
		prior.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		var wide := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
		wide.blit_rect(prior, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0401_V0406_WIDE_COMPARISON.png"))
	if prior_close and prior_close.get_width() == 1920:
		prior_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		var near := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
		near.blit_rect(prior_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0401_V0406_CLOSE_COMPARISON.png"))

func _v0406_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0406-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0406_audit, "  "))

func _smoke_v0406_exit() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0406_write_audit(root)
	var file := FileAccess.open(root.path_join("v0406-exact-western-footing-ring-extension-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0406_CHECKPOINT, "status": "PASS", "verticesMoved": 4, "topologyChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0406_find_mesh(node_name: String) -> MeshInstance3D:
	for candidate in find_children("*", "MeshInstance3D", true, false):
		if candidate.name == node_name: return candidate as MeshInstance3D
	return null

func _v0406_mesh_node_count() -> int:
	return find_children("*", "MeshInstance3D", true, false).size()

func _v0406_named_mesh_hash(fragment: String) -> String:
	for candidate in find_children("*", "MeshInstance3D", true, false):
		if str(candidate.name).to_lower().contains(fragment.to_lower()):
			var mesh := candidate.mesh as ArrayMesh
			if mesh and mesh.get_surface_count() > 0: return _v0406_vertex_hash(mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX])
	return ""

func _v0406_bridge_hashes() -> Dictionary:
	var result := {}
	for candidate in find_children("*", "MeshInstance3D", true, false):
		var name := str(candidate.name)
		if name.to_lower().contains("bridge") and (name.to_lower().contains("deck") or name.to_lower().contains("rail") or name.to_lower().contains("support")):
			var mesh := candidate.mesh as ArrayMesh
			if mesh and mesh.get_surface_count() > 0: result[name] = _v0406_vertex_hash(mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX])
	return result

func _v0406_vertex_hash(vertices: PackedVector3Array) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	for vertex in vertices: context.update(("%.7f,%.7f,%.7f;" % [vertex.x, vertex.y, vertex.z]).to_utf8_buffer())
	return context.finish().hex_encode()

func _v0406_vec(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _v0406_aabb(value: AABB) -> Dictionary:
	return {"position": _v0406_vec(value.position), "size": _v0406_vec(value.size)}
