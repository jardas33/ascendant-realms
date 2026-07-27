extends "res://scripts/v0406_exact_western_footing_ring_extension.gd"

## v0.407 changes only the existing eastern footing material in the opt-in
## inherited crossing. No eastern vertices, transforms, topology, or gameplay
## geometry are changed.

const V0407_CHECKPOINT := "v0.407"
const V0407_CAPTURE_ROOT := "artifacts/runtime/v0407"
const V0407_EASTERN_NODE := "Bridge_Abutment_+1"
const V0407_MAX_Y_CORRECTION := 0.08

var v0407_capture_mode := false
var v0407_smoke_mode := false
var v0407_east: MeshInstance3D
var v0407_audit: Dictionary = {}

func _ready() -> void:
	_read_v0407_args()
	super._ready()
	_v0407_apply_existing_material_assignment()
	if v0407_capture_mode:
		call_deferred("_v0407_start_capture")
	elif v0407_smoke_mode:
		call_deferred("_v0407_smoke_exit")

func _read_v0407_args() -> void:
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0407-eastern-landing-capture": v0407_capture_mode = true
		if arg == "--v0407-eastern-landing-smoke": v0407_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0407_CAPTURE_ROOT

func _read_v0388_args() -> void:
	## Suppress inherited capture scheduling; v0.407 schedules after its
	## material assignment has been applied.
	super._read_v0388_args()
	if v0407_capture_mode or v0407_smoke_mode:
		v0388_capture_mode = false
		v0388_smoke_mode = false

func _v0407_apply_existing_material_assignment() -> void:
	v0407_east = _v0406_find_mesh(V0407_EASTERN_NODE)
	var route := _v0396_main_route()
	if v0407_east == null or v0407_east.mesh == null:
		v0407_audit = {"checkpoint": V0407_CHECKPOINT, "status": "FAIL", "reason": "eastern footing missing"}
		return
	if route == null or route.material_override == null:
		v0407_audit = {"checkpoint": V0407_CHECKPOINT, "status": "FAIL", "reason": "accepted warm-earth route material missing"}
		return
	var before_material := v0407_east.material_override
	var before_transform := v0407_east.transform
	var before_aabb := (v0407_east.mesh as ArrayMesh).get_aabb()
	var vertex_count := _v0407_vertex_count(v0407_east)
	var index_count := _v0407_index_count(v0407_east)
	var warm_earth := (route.material_override as StandardMaterial3D).duplicate()
	warm_earth.resource_name = "V0407_Eastern_Landing_Warm_Earth"
	warm_earth.vertex_color_use_as_albedo = false
	warm_earth.albedo_color = Color("#7b573b")
	warm_earth.roughness = 1.0
	v0407_east.material_override = warm_earth
	v0407_east.set_meta("v0407_existing_eastern_material_reassigned", true)
	v0407_east.set_meta("v0407_y_correction", 0.0)
	v0407_audit = {
		"baselineCommit": "f109828e0827ba0ee8eb35ab5f8c5cc71f0b4149",
		"checkpoint": V0407_CHECKPOINT,
		"status": "RENDERED_CANDIDATE",
		"responsibleComponent": V0407_EASTERN_NODE,
		"materialBefore": before_material.resource_name if before_material else "null",
		"materialAfter": v0407_east.material_override.resource_name,
		"materialSource": "accepted_v0396_warm_earth_route_material_with_vertex_tint_disabled",
		"materialAssignmentOnly": true,
		"verticalCorrection": 0.0,
		"maxPermittedVerticalCorrection": V0407_MAX_Y_CORRECTION,
		"transformBefore": _v0407_transform(before_transform),
		"transformAfter": _v0407_transform(v0407_east.transform),
		"aabbBefore": _v0407_aabb(before_aabb),
		"aabbAfter": _v0407_aabb((v0407_east.mesh as ArrayMesh).get_aabb()),
		"vertexCountBefore": vertex_count,
		"vertexCountAfter": _v0407_vertex_count(v0407_east),
		"indexCountBefore": index_count,
		"indexCountAfter": _v0407_index_count(v0407_east),
		"triangleCountBefore": index_count / 3,
		"triangleCountAfter": _v0407_index_count(v0407_east) / 3,
		"surfaceCountBefore": (v0407_east.mesh as ArrayMesh).get_surface_count(),
		"surfaceCountAfter": (v0407_east.mesh as ArrayMesh).get_surface_count(),
		"xCoordinatesChanged": false,
		"zCoordinatesChanged": false,
		"topologyChanged": false,
		"indicesChanged": false,
		"newGeometry": false,
		"overlays": false,
		"decals": false,
		"duplicateMeshes": false,
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"fallbackRenderer": "unchanged",
		"debugRenderer": "unchanged"
	}

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0407_capture_sequence()

func _v0407_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0406_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0406_capture_view("02_EASTERN_LANDING_CLOSE_COLOUR.png", Vector3(16.0, 16.0, 16.0), Vector3(5.1, -0.15, 0.0), 8.5, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_EASTERN_LANDING_CLOSE_GRAYSCALE.png"))
	await _v0407_capture_diagnostic(root)
	_v0407_write_comparison(primary, close, root)
	_v0407_write_audit(root)
	get_tree().quit(0)

func _v0407_capture_diagnostic(root: String) -> void:
	v0383_camera.position = Vector3(16.0, 16.0, 16.0)
	v0383_camera.size = 8.5
	v0383_camera.look_at(Vector3(5.1, -0.15, 0.0), Vector3.UP)
	var candidates := ["Bridge_Footing_+1", "Bridge_Abutment_+1", "Bridge_Underbeam_+1_28", "Bridge_EdgeCourse_+1"]
	var colours := [Color(1.0, 0.04, 0.04), Color(0.04, 1.0, 0.04), Color(0.04, 0.35, 1.0), Color(1.0, 0.78, 0.02)]
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#11100d"))
	for candidate_index in candidates.size():
		var node := _v0406_find_mesh(candidates[candidate_index])
		if node == null: continue
		var original := node.material_override
		var diagnostic_material := StandardMaterial3D.new()
		diagnostic_material.albedo_color = colours[candidate_index]
		diagnostic_material.vertex_color_use_as_albedo = false
		diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = diagnostic_material
		var layer := CanvasLayer.new()
		var panel := ColorRect.new()
		panel.color = Color(0.03, 0.025, 0.02, 0.90)
		panel.position = Vector2(18.0, 18.0)
		panel.size = Vector2(680.0, 90.0)
		var label := Label.new()
		label.position = Vector2(14.0, 10.0)
		label.add_theme_font_size_override("font_size", 21)
		label.text = "v0.407 DIAGNOSTIC HIGHLIGHT\n" + candidates[candidate_index] + "  |  red/green/blue/yellow by panel"
		panel.add_child(label)
		layer.add_child(panel)
		add_child(layer)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		image.convert(Image.FORMAT_RGBA8)
		image.resize(960, 540, Image.INTERPOLATE_LANCZOS)
		var destination := Vector2i((candidate_index % 2) * 960, (candidate_index / 2) * 540)
		sheet.blit_rect(image, Rect2i(0, 0, 960, 540), destination)
		layer.free()
		node.material_override = original
	sheet.save_png(root.path_join("05_EASTERN_COMPONENT_DIAGNOSTIC.png"))

func _v0407_write_comparison(primary: Image, close: Image, root: String) -> void:
	var prior := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0406/01_PRIMARY_RTS_COLOUR.png"))
	var prior_close := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0406/02_WESTERN_LANDING_CLOSE_COLOUR.png"))
	if prior and prior.get_width() == 1920:
		prior.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		var wide := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
		wide.blit_rect(prior, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0406_V0407_WIDE_COMPARISON.png"))
	if prior_close and prior_close.get_width() == 1920:
		prior_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		var near := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
		near.blit_rect(prior_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0406_V0407_CLOSE_COMPARISON.png"))

func _v0407_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0407-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0407_audit, "  "))

func _v0407_smoke_exit() -> void:
	_v0407_write_audit(ProjectSettings.globalize_path(v0388_capture_root))
	var file := FileAccess.open(ProjectSettings.globalize_path(v0388_capture_root).path_join("v0407-eastern-landing-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0407_CHECKPOINT, "status": "PASS", "materialAssignmentOnly": true, "verticalCorrection": 0.0, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0407_vertex_count(node: MeshInstance3D) -> int:
	var mesh := node.mesh as ArrayMesh
	if mesh == null or mesh.get_surface_count() == 0: return 0
	return (mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()

func _v0407_index_count(node: MeshInstance3D) -> int:
	var mesh := node.mesh as ArrayMesh
	if mesh == null or mesh.get_surface_count() == 0: return 0
	return (mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size()

func _v0407_transform(value: Transform3D) -> Dictionary:
	return {"origin": _v0406_vec(value.origin), "basis": str(value.basis)}

func _v0407_aabb(value: AABB) -> Dictionary:
	return {"position": _v0406_vec(value.position), "size": _v0406_vec(value.size)}
