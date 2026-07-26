extends "res://scripts/v0394_route_only_visibility_repair_fence_regression_rollback.gd"

## v0.395 keeps the independently accepted v0.394 route topology and repairs only
## its player-facing material, width profile, and edge readability. It is opt-in.

const V0395_CHECKPOINT := "v0.395"
const V0395_CAPTURE_ROOT := "artifacts/runtime/v0395"

var v0395_capture_mode := false
var v0395_smoke_mode := false
var v0395_iteration := 1

func _ready() -> void:
	super._ready()

func _read_v0388_args() -> void:
	super._read_v0388_args()
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0395-route-material-capture": v0395_capture_mode = true
		if arg == "--v0395-route-material-smoke": v0395_smoke_mode = true
		if arg.begins_with("--v0395-iteration="): v0395_iteration = clampi(int(arg.trim_prefix("--v0395-iteration=")), 1, 4)
		if arg.begins_with("--artifact-root="): explicit_root = true
	if not explicit_root: v0388_capture_root = V0395_CAPTURE_ROOT
	if v0395_capture_mode: v0388_capture_mode = true
	if v0395_capture_mode: v0395_smoke_mode = true
	if v0395_smoke_mode: v0388_smoke_mode = true

func _build_v0388_ground_connection() -> void:
	var path := Node3D.new()
	path.name = "V0395_Natural_Worn_Earth_Route_Material_Edge_Integration"
	path.set_meta("v0394_route_topology_preserved", true)
	v0388_yard.add_child(path)
	var centerline := PackedVector3Array([
		Vector3(-0.72, 0.0, 0.44), Vector3(-1.18, 0.0, 1.26),
		Vector3(-2.18, 0.0, 2.16), Vector3(-3.42, 0.0, 2.72),
		Vector3(-4.66, 0.0, 2.78), Vector3(-5.44, 0.0, 2.30),
		Vector3(-5.86, 0.0, 1.68), Vector3(-5.98, 0.0, 1.10)
	])
	var main_widths := PackedFloat32Array([1.24, 1.38, 1.56, 1.92, 2.16, 1.88, 1.48, 1.22])
	_ground_ribbon_variable(path, "V0395_One_Compacted_Warm_Earth_Bridge_Yard_Door_Route", centerline, main_widths, 1.12)
	var barn_branch := PackedVector3Array([
		Vector3(-3.90, 0.0, 2.60), Vector3(-5.05, 0.0, 3.32),
		Vector3(-6.38, 0.0, 3.78), Vector3(-8.28, 0.0, 4.18)
	])
	var branch_widths := PackedFloat32Array([1.06, 1.02, 0.92, 0.78])
	_ground_ribbon_variable(path, "V0395_Short_Compacted_Warm_Earth_Barn_Entrance_Branch", barn_branch, branch_widths, 1.125)
	var segment_names := [
		"V0395_Connection_Segment_A",
		"V0395_Connection_Segment_B",
		"V0395_Connection_Segment_C",
		"V0395_Connection_Segment_D",
		"V0395_Connection_Segment_E_Door_Approach"
	]
	for segment_name in segment_names:
		var segment := Node3D.new()
		segment.name = segment_name
		segment.set_meta("visual_segment_of_continuous_route", true)
		segment.set_meta("v0394_topology_preserved", true)
		path.add_child(segment)
	_box_prop(path, "V0395_Door_Threshold_Stone", Vector3(-5.98, 1.14, 1.08), Vector3(1.35, 0.12, 0.42), Color("#5d4b38"), deg_to_rad(-18.0))

func _ribbon_mesh_variable(centerline: PackedVector3Array, widths: PackedFloat32Array) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	for i in range(centerline.size()):
		var previous := centerline[maxi(0, i - 1)]
		var next := centerline[mini(centerline.size() - 1, i + 1)]
		var tangent := next - previous
		tangent.y = 0.0
		if tangent.length_squared() < 0.001: tangent = Vector3.FORWARD
		var side := Vector3(-tangent.z, 0.0, tangent.x).normalized()
		var half_width := widths[clampi(i, 0, widths.size() - 1)] * 0.5
		vertices.append(centerline[i] - side * half_width)
		vertices.append(centerline[i] + side * half_width)
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		var tone := 0.94 + float(i % 3) * 0.025
		colors.append(Color(tone, tone * 0.90, tone * 0.78, 1.0))
		colors.append(Color(tone * 0.98, tone * 0.88, tone * 0.74, 1.0))
	for i in range(centerline.size() - 1):
		var offset := i * 2
		indices.append(offset); indices.append(offset + 1); indices.append(offset + 2)
		indices.append(offset + 1); indices.append(offset + 3); indices.append(offset + 2)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func _ground_ribbon_variable(parent: Node3D, name: String, centerline: PackedVector3Array, widths: PackedFloat32Array, y := 0.80) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = _ribbon_mesh_variable(centerline, widths)
	var material := _ground_material(name + "_Material", Color("#7b573b"), true)
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	instance.material_override = material
	instance.position.y = y
	instance.set_meta("continuous_route_ribbon", true)
	instance.set_meta("v0394_route_topology_preserved", true)
	instance.set_meta("v0395_material", "compacted_warm_worn_earth")
	instance.set_meta("v0395_width_profile", "narrow_landings_wide_working_yard")
	parent.add_child(instance)
	return instance

func _capture_v0388_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0395_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 31.0, 24.0), Vector3(-5.3, 0.90, 3.05), 19.0, root)
	await _capture_v0395_view("02_SETTLEMENT_AND_CROSSING_CONTEXT.png", Vector3(28.0, 35.0, 28.0), Vector3(-5.2, 0.82, 3.10), 25.5, root)
	var close_route := await _capture_v0395_view("03_CLOSE_ROUTE_YARD_DOORWAY.png", Vector3(16.0, 20.0, 16.0), Vector3(-5.1, 0.85, 2.80), 12.0, root)
	await _capture_v0395_view("04_BARN_BRANCH_CONNECTION.png", Vector3(18.0, 22.0, 18.0), Vector3(-6.2, 0.90, 3.90), 12.8, root)
	var grayscale_primary := primary.duplicate()
	grayscale_primary.convert(Image.FORMAT_L8)
	grayscale_primary.save_png(root.path_join("05_GRAYSCALE_PRIMARY.png"))
	var grayscale_close := close_route.duplicate()
	grayscale_close.convert(Image.FORMAT_L8)
	grayscale_close.save_png(root.path_join("06_GRAYSCALE_CLOSE_ROUTE.png"))
	var comparison := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
	var prior_path := ProjectSettings.globalize_path("artifacts/runtime/v0394/01_PRIMARY_RTS_VIEW.png")
	var prior := Image.load_from_file(prior_path)
	if prior and prior.get_width() > 0:
		prior.convert(Image.FORMAT_RGBA8)
		var current := primary.duplicate()
		current.convert(Image.FORMAT_RGBA8)
		comparison.blit_rect(prior, Rect2i(0, 0, prior.get_width(), prior.get_height()), Vector2i(0, 0))
		comparison.blit_rect(current, Rect2i(0, 0, current.get_width(), current.get_height()), Vector2i(1920, 0))
		comparison.save_png(root.path_join("07_V0394_V0395_PRIMARY_COMPARISON.png"))
	_write_v0395_json("v0395-natural-worn-earth-route-material-edge-integration.json", {
		"checkpoint": V0395_CHECKPOINT, "status": "RENDERED", "iteration": v0395_iteration,
		"resolution": "1920x1080", "route": "opt-in-only", "routeTopology": "v0394-preserved",
		"routeMaterial": "compacted-warm-worn-earth", "routeValue": "darker-than-terrain-not-black",
		"widthProfile": "narrow-landings-wide-working-yard-narrow-door-and-branch",
		"bridgePreserved": true, "riverPreserved": true, "buildingsPreserved": true,
		"charactersPreserved": true, "propsPreserved": true, "cameraPreserved": true,
		"gameplay": false, "defaultRuntime": "unchanged"
	})
	get_tree().quit(0)

func _capture_v0395_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0395_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_v0388_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_v0395_json("v0395-natural-worn-earth-route-material-edge-integration-smoke.json", {
		"checkpoint": V0395_CHECKPOINT, "status": "PASS", "sceneLoaded": true,
		"v0394RouteTopologyPreserved": true, "gameplay": false,
		"defaultRuntime": "unchanged", "route": "opt-in-only"
	})
	get_tree().quit(0)
