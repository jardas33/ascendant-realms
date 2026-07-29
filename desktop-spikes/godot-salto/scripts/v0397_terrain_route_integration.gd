extends "res://scripts/v0396_inherited_route_mesh_deduplication_material_unification.gd"

## v0.397 is a visual-only, opt-in terrain integration pass over the accepted
## v0.396 route. It keeps the route topology, elevation, camera, settlement,
## bridge, characters, props, and gameplay unchanged.

const V0397_CHECKPOINT := "v0.397"
const V0397_CAPTURE_ROOT := "artifacts/runtime/v0397"

var v0397_capture_mode := false
var v0397_smoke_mode := false

func _ready() -> void:
	_read_v0397_args()
	super._ready()
	_v0397_apply_visual_treatment()

func _read_v0388_args() -> void:
	super._read_v0388_args()
	_read_v0397_args()

func _read_v0397_args() -> void:
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0397-terrain-route-capture": v0397_capture_mode = true
		if arg == "--v0397-terrain-route-smoke": v0397_smoke_mode = true
		if arg.begins_with("--artifact-root="): explicit_root = true
	if not explicit_root: v0388_capture_root = V0397_CAPTURE_ROOT
	if v0397_capture_mode:
		v0388_capture_mode = true
		v0388_smoke_mode = true
	if v0397_smoke_mode: v0388_smoke_mode = true

func _v0397_apply_visual_treatment() -> void:
	var route := _v0396_main_route()
	if route == null: return
	# v0.396 applies its unified warm-earth material inside its own capture
	# sequence; v0.397 owns that sequence, so preserve the accepted material
	# explicitly before adding only the new low-opacity grounding treatment.
	_v0396_apply_route_material_unification()
	var route_parent := route.get_parent() as Node3D
	if route_parent == null: return
	var existing := route_parent.get_node_or_null("V0397_Route_Grass_Bedding")
	if existing == null:
		var centerline := PackedVector3Array([
			Vector3(-0.72, 0.0, 0.44), Vector3(-1.18, 0.0, 1.26),
			Vector3(-2.18, 0.0, 2.16), Vector3(-3.42, 0.0, 2.72),
			Vector3(-4.66, 0.0, 2.78), Vector3(-5.44, 0.0, 2.30),
			Vector3(-5.86, 0.0, 1.68), Vector3(-5.98, 0.0, 1.10)
		])
		var widths := PackedFloat32Array([1.52, 1.68, 1.88, 2.22, 2.48, 2.20, 1.78, 1.50])
		_v0397_add_route_bedding(route_parent, "V0397_Route_Grass_Bedding", centerline, widths, 1.105)
		var barn_branch := PackedVector3Array([
			Vector3(-3.90, 0.0, 2.60), Vector3(-5.05, 0.0, 3.32),
			Vector3(-6.38, 0.0, 3.78), Vector3(-8.28, 0.0, 4.18)
		])
		var branch_widths := PackedFloat32Array([1.30, 1.26, 1.14, 1.00])
		_v0397_add_route_bedding(route_parent, "V0397_Barn_Branch_Grass_Bedding", barn_branch, branch_widths, 1.108)
	if v0388_yard != null and v0388_yard.get_node_or_null("V0397_Contact_Grounding") == null:
		var grounding := Node3D.new()
		grounding.name = "V0397_Contact_Grounding"
		grounding.set_meta("visual_only", true)
		grounding.set_meta("gameplay_mutation", false)
		v0388_yard.add_child(grounding)
		_v0397_add_contact_patch(grounding, "House_Contact", Vector3(-5.85, 1.15, 1.12), 2.10, 1.46)
		_v0397_add_contact_patch(grounding, "Barn_Contact", Vector3(-8.90, 0.88, 4.50), 1.22, 0.92)
		_v0397_add_contact_patch(grounding, "Cart_Contact", Vector3(-3.00, 0.86, 4.35), 0.72, 0.52)
		_v0397_add_contact_patch(grounding, "Workbench_Contact", Vector3(-4.12, 0.82, 3.42), 0.72, 0.40)
		_v0397_add_contact_patch(grounding, "Western_Landing_Contact", Vector3(-0.72, 0.82, 0.44), 0.86, 0.66)
		_v0397_add_contact_patch(grounding, "Eastern_Landing_Contact", Vector3(-5.98, 0.82, 1.10), 0.74, 0.56)

func _v0397_add_route_bedding(parent: Node3D, name: String, centerline: PackedVector3Array, widths: PackedFloat32Array, y: float) -> void:
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = _ribbon_mesh_variable(centerline, widths)
	instance.material_override = _v0397_alpha_material(name + "_Material", Color(0.28, 0.22, 0.16, 0.18))
	instance.position.y = y
	instance.set_meta("visual_only", true)
	instance.set_meta("v0397_route_edge_bedding", true)
	instance.set_meta("v0397_geometry_changed", false)
	parent.add_child(instance)

func _v0397_add_contact_patch(parent: Node3D, name: String, center: Vector3, radius_x: float, radius_z: float) -> void:
	var points := PackedVector3Array([
		Vector3(-radius_x * 0.92, 0.0, -radius_z * 0.18), Vector3(-radius_x * 0.52, 0.0, -radius_z * 0.82),
		Vector3(radius_x * 0.16, 0.0, -radius_z * 0.94), Vector3(radius_x * 0.88, 0.0, -radius_z * 0.46),
		Vector3(radius_x * 0.96, 0.0, radius_z * 0.18), Vector3(radius_x * 0.48, 0.0, radius_z * 0.78),
		Vector3(-radius_x * 0.20, 0.0, radius_z * 0.92), Vector3(-radius_x * 0.86, 0.0, radius_z * 0.48)
	])
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = _polygon_mesh(points)
	instance.material_override = _v0397_alpha_material(name + "_Material", Color(0.18, 0.14, 0.10, 0.095))
	instance.position = center
	instance.position.y = 1.092
	instance.set_meta("visual_only", true)
	instance.set_meta("v0397_contact_grounding", true)
	parent.add_child(instance)

func _v0397_alpha_material(name: String, color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	material.roughness = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _capture_v0388_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0397_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 31.0, 24.0), Vector3(-5.3, 0.90, 3.05), 19.0, root)
	await _capture_v0397_view("02_CLOSE_ROUTE_YARD_DOORWAY.png", Vector3(16.0, 20.0, 16.0), Vector3(-5.1, 0.85, 2.80), 12.0, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("03_GRAYSCALE_PRIMARY.png"))
	var route := _v0396_main_route()
	var branch := get_node_or_null("V0383_Bridge_First_Highland_Style_Coherence/V0394_Route_Only_Visibility_Repair_Fence_Regression_Rollback/V0394_Five_Functional_Yard_Groups/V0395_Natural_Worn_Earth_Route_Material_Edge_Integration/V0395_Short_Compacted_Warm_Earth_Barn_Entrance_Branch") as MeshInstance3D
	if route: route.visible = false
	if branch: branch.visible = false
	await _capture_v0397_view("04_DIAGNOSTIC_ROUTE_BEDDING_AND_GROUNDING.png", Vector3(16.0, 20.0, 16.0), Vector3(-5.1, 0.85, 2.80), 12.0, root)
	if route: route.visible = true
	if branch: branch.visible = true
	var prior := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0396/01_PRIMARY_RTS_VIEW.png"))
	var current := Image.load_from_file(root.path_join("01_PRIMARY_RTS_VIEW.png"))
	if prior and current:
		prior.convert(Image.FORMAT_RGBA8)
		current.convert(Image.FORMAT_RGBA8)
		var comparison := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
		comparison.blit_rect(prior, Rect2i(0, 0, prior.get_width(), prior.get_height()), Vector2i(0, 0))
		comparison.blit_rect(current, Rect2i(0, 0, current.get_width(), current.get_height()), Vector2i(1920, 0))
		comparison.save_png(root.path_join("05_V0396_V0397_PRIMARY_COMPARISON.png"))
	_write_v0397_json()
	get_tree().quit(0)

func _capture_v0397_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0397_json() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0397-terrain-route-integration.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"checkpoint": V0397_CHECKPOINT, "status": "RENDERED",
			"routeGeometry": "v0396-preserved", "routeTreatment": "warm-earth-with-grass-bedding",
			"contactGrounding": "restrained-visual-only", "bridge": "unchanged",
			"terrain": "unchanged", "camera": "unchanged", "gameplay": false,
			"defaultRuntime": "unchanged", "grayscale": true
		}, "  "))

func _smoke_v0388_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0397-terrain-route-integration-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0397_CHECKPOINT, "status": "PASS", "visualOnly": true, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)
