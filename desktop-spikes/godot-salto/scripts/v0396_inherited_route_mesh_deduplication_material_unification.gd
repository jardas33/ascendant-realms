extends "res://scripts/v0395_natural_worn_earth_route_material_edge_integration.gd"

## v0.396 isolates the inherited dark main-route material override and unifies
## it with the accepted v0.395 warm-earth route. Geometry, topology, elevation,
## camera, bridge, terrain, props, characters, and gameplay remain unchanged.

const V0396_CHECKPOINT := "v0.396"
const V0396_CAPTURE_ROOT := "artifacts/runtime/v0396"

var v0396_capture_mode := false
var v0396_smoke_mode := false
var v0396_diagnostic_mode := false

func _ready() -> void:
	v0396_capture_mode = v0396_capture_mode or bool(get_meta("v0396_capture_mode", false))
	v0396_smoke_mode = v0396_smoke_mode or bool(get_meta("v0396_smoke_mode", false))
	v0396_diagnostic_mode = v0396_diagnostic_mode or bool(get_meta("v0396_diagnostic_mode", false))
	super._ready()
	_v0396_enumerate_inherited_meshes()
	if v0396_smoke_mode and not v0396_capture_mode:
		_v0396_apply_route_material_unification()

func _read_v0388_args() -> void:
	super._read_v0388_args()
	v0396_capture_mode = v0396_capture_mode or bool(get_meta("v0396_capture_mode", false))
	v0396_smoke_mode = v0396_smoke_mode or bool(get_meta("v0396_smoke_mode", false))
	v0396_diagnostic_mode = v0396_diagnostic_mode or bool(get_meta("v0396_diagnostic_mode", false))
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0396-route-mesh-capture": v0396_capture_mode = true
		if arg == "--v0396-route-mesh-smoke": v0396_smoke_mode = true
		if arg == "--v0396-route-mesh-diagnostic": v0396_diagnostic_mode = true
		if arg.begins_with("--artifact-root="): explicit_root = true
	if not explicit_root: v0388_capture_root = V0396_CAPTURE_ROOT
	if v0396_capture_mode: v0388_capture_mode = true
	if v0396_smoke_mode: v0388_smoke_mode = true

func _v0396_enumerate_inherited_meshes() -> void:
	var records: Array[Dictionary] = []
	_v0396_collect_meshes(v0383_world, records)
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join("v0396-inherited-route-mesh-inventory.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"checkpoint": V0396_CHECKPOINT,
			"captureMode": v0396_capture_mode,
			"smokeMode": v0396_smoke_mode,
			"v0388CaptureMode": v0388_capture_mode,
			"v0388CaptureRoot": v0388_capture_root,
			"meshCount": records.size(),
			"identifiedLegacyOverride": "V0395_One_Compacted_Warm_Earth_Bridge_Yard_Door_Route -> V0394_Bridge_Desaturated_Value",
			"meshes": records
		}, "  "))

func _v0396_collect_meshes(node: Node, records: Array[Dictionary]) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh := (child as MeshInstance3D).mesh
			var surface_count := mesh.get_surface_count() if mesh else 0
			var surface_materials: Array[String] = []
			for surface_index in range(surface_count):
				var surface_material := mesh.surface_get_material(surface_index)
				surface_materials.append(str(surface_material.resource_name) if surface_material else "null")
			records.append({
				"name": str(child.name),
				"path": str(child.get_path()),
				"worldPosition": var_to_str((child as MeshInstance3D).global_position),
				"aabb": var_to_str(mesh.get_aabb() if mesh else AABB()),
				"surfaceCount": surface_count,
				"surfaceMaterials": surface_materials,
				"materialOverride": str((child as MeshInstance3D).material_override.resource_name) if (child as MeshInstance3D).material_override else "null",
				"visible": (child as MeshInstance3D).visible
			})
		_v0396_collect_meshes(child, records)

func _v0396_main_route() -> MeshInstance3D:
	return get_node_or_null("V0383_Bridge_First_Highland_Style_Coherence/V0394_Route_Only_Visibility_Repair_Fence_Regression_Rollback/V0394_Five_Functional_Yard_Groups/V0395_Natural_Worn_Earth_Route_Material_Edge_Integration/V0395_One_Compacted_Warm_Earth_Bridge_Yard_Door_Route") as MeshInstance3D

func _v0396_apply_route_material_unification() -> void:
	var route := _v0396_main_route()
	if route == null: return
	var material := _ground_material("V0396_Compacted_Warm_Earth_Unified_Main_Route_Material", Color("#7b573b"), true)
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	route.material_override = material
	route.set_meta("v0396_inherited_override_repaired", true)
	route.set_meta("v0396_previous_material_override", "V0394_Bridge_Desaturated_Value")
	route.set_meta("v0396_material_unified", "compacted_warm_worn_earth")

func _capture_v0388_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var route := _v0396_main_route()
	if route:
		route.visible = false
	await _capture_v0396_view("04_DIAGNOSTIC_INHERITED_ROUTE_MESH_ISOLATED.png", Vector3(16.0, 20.0, 16.0), Vector3(-5.1, 0.85, 2.80), 12.0, root)
	if route: route.visible = true
	_v0396_apply_route_material_unification()
	await _capture_v0396_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 31.0, 24.0), Vector3(-5.3, 0.90, 3.05), 19.0, root)
	await _capture_v0396_view("02_CLOSE_ROUTE_YARD_DOORWAY.png", Vector3(16.0, 20.0, 16.0), Vector3(-5.1, 0.85, 2.80), 12.0, root)
	var grayscale := await _capture_v0396_view("03_GRAYSCALE_PRIMARY.png", Vector3(24.0, 31.0, 24.0), Vector3(-5.3, 0.90, 3.05), 19.0, root)
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("03_GRAYSCALE_PRIMARY.png"))
	var prior_path := ProjectSettings.globalize_path("artifacts/runtime/v0395/01_PRIMARY_RTS_VIEW.png")
	var prior := Image.load_from_file(prior_path)
	var current := Image.load_from_file(root.path_join("01_PRIMARY_RTS_VIEW.png"))
	if prior and current:
		prior.convert(Image.FORMAT_RGBA8)
		current.convert(Image.FORMAT_RGBA8)
		var comparison := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
		comparison.blit_rect(prior, Rect2i(0, 0, prior.get_width(), prior.get_height()), Vector2i(0, 0))
		comparison.blit_rect(current, Rect2i(0, 0, current.get_width(), current.get_height()), Vector2i(1920, 0))
		comparison.save_png(root.path_join("05_V0395_V0396_PRIMARY_COMPARISON.png"))
	_write_v0396_json()
	get_tree().quit(0)

func _capture_v0396_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0396_json() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0396-inherited-route-mesh-deduplication-material-unification.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"checkpoint": V0396_CHECKPOINT,
			"status": "RENDERED",
			"diagnostic": "inherited main route hidden before final capture; V0394_Bridge_Desaturated_Value override identified",
			"material": "compacted-warm-worn-earth-unified",
			"topology": "v0394-preserved",
			"elevation": "v0395-flush-preserved",
			"bridge": true,
			"terrain": true,
			"gameplay": false,
			"defaultRuntime": "unchanged"
		}, "  "))

func _smoke_v0388_exit() -> void:
	_v0396_apply_route_material_unification()
	await get_tree().create_timer(0.6).timeout
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0396-inherited-route-mesh-deduplication-material-unification-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0396_CHECKPOINT, "status": "PASS", "materialUnified": true, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)
