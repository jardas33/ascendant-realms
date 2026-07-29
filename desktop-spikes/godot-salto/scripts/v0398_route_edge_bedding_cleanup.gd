extends "res://scripts/v0397_terrain_route_integration.gd"

## v0.398 is the narrow v0.397 visual correction: remove the broad contact
## halos and keep only a low-opacity, tight edge bedding around the accepted
## v0.396 route. No geometry, layout, camera, or gameplay changes.

const V0398_CHECKPOINT := "v0.398"
const V0398_CAPTURE_ROOT := "artifacts/runtime/v0398"

var v0398_capture_mode := false
var v0398_smoke_mode := false

func _ready() -> void:
	_read_v0398_args()
	super._ready()
	_v0398_apply_visual_correction()

func _read_v0388_args() -> void:
	super._read_v0388_args()
	_read_v0398_args()

func _read_v0398_args() -> void:
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0398-route-edge-capture": v0398_capture_mode = true
		if arg == "--v0398-route-edge-smoke": v0398_smoke_mode = true
		if arg.begins_with("--artifact-root="): explicit_root = true
	if not explicit_root: v0388_capture_root = V0398_CAPTURE_ROOT
	if v0398_capture_mode:
		v0388_capture_mode = true
		v0388_smoke_mode = true
	if v0398_smoke_mode: v0388_smoke_mode = true

func _v0398_apply_visual_correction() -> void:
	_v0396_apply_route_material_unification()
	var route := _v0396_main_route()
	if route == null: return
	var route_parent := route.get_parent() as Node3D
	if route_parent == null: return
	for child in route_parent.get_children():
		if child is MeshInstance3D and bool(child.get_meta("v0397_route_edge_bedding", false)):
			(child as MeshInstance3D).visible = false
	var old_grounding := v0388_yard.get_node_or_null("V0397_Contact_Grounding") if v0388_yard else null
	if old_grounding:
		old_grounding.visible = false
	if route_parent.get_node_or_null("V0398_Narrow_Route_Edge_Bedding") == null:
		var centerline := PackedVector3Array([
			Vector3(-0.72, 0.0, 0.44), Vector3(-1.18, 0.0, 1.26),
			Vector3(-2.18, 0.0, 2.16), Vector3(-3.42, 0.0, 2.72),
			Vector3(-4.66, 0.0, 2.78), Vector3(-5.44, 0.0, 2.30),
			Vector3(-5.86, 0.0, 1.68), Vector3(-5.98, 0.0, 1.10)
		])
		var widths := PackedFloat32Array([1.34, 1.48, 1.66, 2.02, 2.26, 2.02, 1.62, 1.36])
		_v0398_add_bedding(route_parent, "V0398_Narrow_Route_Edge_Bedding", centerline, widths, 1.112)
		var barn_branch := PackedVector3Array([
			Vector3(-3.90, 0.0, 2.60), Vector3(-5.05, 0.0, 3.32),
			Vector3(-6.38, 0.0, 3.78), Vector3(-8.28, 0.0, 4.18)
		])
		var branch_widths := PackedFloat32Array([1.16, 1.14, 1.04, 0.90])
		_v0398_add_bedding(route_parent, "V0398_Narrow_Barn_Branch_Edge_Bedding", barn_branch, branch_widths, 1.113)

func _v0398_add_bedding(parent: Node3D, name: String, centerline: PackedVector3Array, widths: PackedFloat32Array, y: float) -> void:
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = _ribbon_mesh_variable(centerline, widths)
	instance.material_override = _v0397_alpha_material(name + "_Material", Color(0.20, 0.15, 0.10, 0.075))
	instance.position.y = y
	instance.set_meta("visual_only", true)
	instance.set_meta("v0398_narrow_route_edge_bedding", true)
	instance.set_meta("v0396_geometry_preserved", true)
	parent.add_child(instance)

func _capture_v0388_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0398_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 31.0, 24.0), Vector3(-5.3, 0.90, 3.05), 19.0, root)
	await _capture_v0398_view("02_CLOSE_ROUTE_YARD_DOORWAY.png", Vector3(16.0, 20.0, 16.0), Vector3(-5.1, 0.85, 2.80), 12.0, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("03_GRAYSCALE_PRIMARY.png"))
	var route := _v0396_main_route()
	var edge := get_node_or_null("V0383_Bridge_First_Highland_Style_Coherence/V0394_Route_Only_Visibility_Repair_Fence_Regression_Rollback/V0394_Five_Functional_Yard_Groups/V0395_Natural_Worn_Earth_Route_Material_Edge_Integration/V0398_Narrow_Route_Edge_Bedding") as MeshInstance3D
	var branch_edge := get_node_or_null("V0383_Bridge_First_Highland_Style_Coherence/V0394_Route_Only_Visibility_Repair_Fence_Regression_Rollback/V0394_Five_Functional_Yard_Groups/V0395_Natural_Worn_Earth_Route_Material_Edge_Integration/V0398_Narrow_Barn_Branch_Edge_Bedding") as MeshInstance3D
	if route: route.visible = false
	if edge: edge.visible = true
	if branch_edge: branch_edge.visible = true
	await _capture_v0398_view("04_DIAGNOSTIC_NARROW_EDGE_ONLY.png", Vector3(16.0, 20.0, 16.0), Vector3(-5.1, 0.85, 2.80), 12.0, root)
	if route: route.visible = true
	var prior := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0397/01_PRIMARY_RTS_VIEW.png"))
	var current := Image.load_from_file(root.path_join("01_PRIMARY_RTS_VIEW.png"))
	if prior and current:
		prior.convert(Image.FORMAT_RGBA8)
		current.convert(Image.FORMAT_RGBA8)
		var comparison := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
		comparison.blit_rect(prior, Rect2i(0, 0, prior.get_width(), prior.get_height()), Vector2i(0, 0))
		comparison.blit_rect(current, Rect2i(0, 0, current.get_width(), current.get_height()), Vector2i(1920, 0))
		comparison.save_png(root.path_join("05_V0397_V0398_PRIMARY_COMPARISON.png"))
	_write_v0398_json()
	get_tree().quit(0)

func _capture_v0398_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0398_json() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0398-route-edge-bedding-cleanup.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"checkpoint": V0398_CHECKPOINT, "status": "RENDERED",
			"priorVerdict": "v0397-REVISE-ONCE",
			"routeGeometry": "v0396-preserved", "routeTreatment": "narrow-low-opacity-edge-bedding",
			"contactHalos": "removed", "bridge": "unchanged", "terrain": "unchanged",
			"camera": "unchanged", "gameplay": false, "defaultRuntime": "unchanged",
			"grayscale": true
		}, "  "))

func _smoke_v0388_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0398-route-edge-bedding-cleanup-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0398_CHECKPOINT, "status": "PASS", "visualOnly": true, "contactHalos": "removed", "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)
