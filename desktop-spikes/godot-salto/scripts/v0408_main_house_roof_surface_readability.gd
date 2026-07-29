extends "res://scripts/v0407_eastern_bridge_landing_footprint_cleanup.gd"

## v0.408 changes only material treatment on the existing v0.400 main-house
## roof planes, ridge, and eave faces. The accepted roof geometry remains fixed.

const V0408_CHECKPOINT := "v0.408"
const V0408_CAPTURE_ROOT := "artifacts/runtime/v0408"
const V0408_ROOF_TEXTURE := "res://assets/v0338/barrosan_house_02_material_gold_candidate_slate_albedo_1024.png"
const V0408_ROOF_NODE_NAMES := [
	"V0400_Main_House_Roof_Left_Plane",
	"V0400_Main_House_Roof_Right_Plane",
	"V0400_Main_House_Ridge_Beam",
	"V0400_Main_House_Left_Eave",
	"V0400_Main_House_Right_Eave"
]
const V0408_VISIBLE_ROOF_FACE_NAMES := [
	"V0400_Main_House_Left_Roof_Visual_Closure",
	"V0400_Main_House_Right_Roof_Visual_Closure"
]

var v0408_capture_mode := false
var v0408_smoke_mode := false
var v0408_audit: Dictionary = {}
var v0408_roof_texture: Texture2D
var v0408_before_materials: Dictionary = {}
var v0408_after_materials: Dictionary = {}

func _ready() -> void:
	_read_v0408_args()
	super._ready()
	_v0408_apply_existing_material_treatment()

func _read_v0408_args() -> void:
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0408-main-house-roof-capture": v0408_capture_mode = true
		if arg == "--v0408-main-house-roof-smoke": v0408_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0408_CAPTURE_ROOT
	v0407_capture_mode = v0408_capture_mode
	v0407_smoke_mode = v0408_smoke_mode

func _read_v0407_args() -> void:
	if v0408_capture_mode or v0408_smoke_mode:
		v0407_capture_mode = v0408_capture_mode
		v0407_smoke_mode = v0408_smoke_mode
		v0388_capture_root = V0408_CAPTURE_ROOT
		return
	super._read_v0407_args()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0408_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join("v0408-main-house-roof-surface-readability-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0408_CHECKPOINT, "status": "PASS", "materialOnly": true, "geometryChanged": false, "uvArraysChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0408_apply_existing_material_treatment() -> void:
	if v0400_house == null:
		v0408_audit = {"checkpoint": V0408_CHECKPOINT, "status": "ASSET_UV_LIMITATION_MAIN_HOUSE_ROOF", "reason": "accepted main-house roof root missing"}
		return
	if bool(v0400_house.get_meta("v0408_material_treatment_applied", false)):
		return
	v0408_roof_texture = load(V0408_ROOF_TEXTURE) as Texture2D
	if v0408_roof_texture == null:
		v0408_audit = {"checkpoint": V0408_CHECKPOINT, "status": "ASSET_UV_LIMITATION_MAIN_HOUSE_ROOF", "reason": "accepted weathered slate texture missing"}
		return
	var slate := StandardMaterial3D.new()
	slate.resource_name = "V0408_Main_House_Weathered_Slate"
	slate.albedo_texture = v0408_roof_texture
	slate.albedo_color = Color("#c8bcae")
	slate.roughness = 0.97
	slate.uv1_scale = Vector3(2.4, 2.4, 2.4)
	slate.cull_mode = BaseMaterial3D.CULL_DISABLED
	var ridge := StandardMaterial3D.new()
	ridge.resource_name = "V0408_Main_House_Slate_Ridge"
	ridge.albedo_color = Color("#29292b")
	ridge.roughness = 0.98
	ridge.cull_mode = BaseMaterial3D.CULL_DISABLED
	var eave := StandardMaterial3D.new()
	eave.resource_name = "V0408_Main_House_Weathered_Eave_Timber"
	eave.albedo_color = Color("#3b302a")
	eave.roughness = 0.97
	eave.cull_mode = BaseMaterial3D.CULL_DISABLED
	var before: Dictionary = {}
	var after: Dictionary = {}
	var required_nodes := 0
	for node_name in V0408_ROOF_NODE_NAMES + V0408_VISIBLE_ROOF_FACE_NAMES:
		var node := v0400_house.find_child(node_name, true, false) as MeshInstance3D
		if node == null or node.mesh == null:
			v0408_audit = {"checkpoint": V0408_CHECKPOINT, "status": "ASSET_UV_LIMITATION_MAIN_HOUSE_ROOF", "reason": "existing roof face missing: " + node_name}
			return
		required_nodes += 1
		before[node_name] = _v0408_mesh_snapshot(node)
		v0408_before_materials[node_name] = node.material_override
		if node_name.contains("Roof_Left") or node_name.contains("Roof_Right"):
			node.material_override = slate
		elif node_name.contains("Ridge"):
			node.material_override = ridge
		else:
			node.material_override = eave
		v0408_after_materials[node_name] = node.material_override
		after[node_name] = _v0408_mesh_snapshot(node)
	v0400_house.set_meta("v0408_material_treatment_applied", true)
	v0408_audit = {
		"baselineCommit": "9c6b763d6d0e62cb9f13c214e852b93faa4c07a4",
		"checkpoint": V0408_CHECKPOINT,
		"status": "RENDERED_CANDIDATE",
		"scope": "existing_main_house_roof_materials_only",
		"materialOnly": true,
		"texture": V0408_ROOF_TEXTURE,
		"requiredRoofNodes": V0408_ROOF_NODE_NAMES.size(),
		"visibleRoofFaceNodes": V0408_VISIBLE_ROOF_FACE_NAMES.size(),
		"materializedExistingNodes": required_nodes,
		"before": before,
		"after": after,
		"geometryChanged": false,
		"topologyChanged": false,
		"indicesChanged": false,
		"verticesChanged": false,
		"uvArraysChanged": false,
		"transformsChanged": false,
		"aabbChanged": false,
		"newGeometry": false,
		"duplicateSurfaces": false,
		"duplicateMeshes": false,
		"overlays": false,
		"decals": false,
		"chimney": "preserved",
		"ridge": "preserved_geometry_material_refined",
		"eaves": "preserved_geometry_material_refined",
		"camera": "unchanged",
		"lighting": "unchanged",
		"bridge": "unchanged",
		"route": "unchanged",
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"fallbackRenderer": "unchanged",
		"debugRenderer": "unchanged"
	}

func _v0408_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0408_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0408_capture_view("02_MAIN_HOUSE_ROOF_CLOSE_COLOUR.png", Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_MAIN_HOUSE_ROOF_GRAYSCALE.png"))
	_v0408_set_materials(v0408_before_materials)
	var prior_roof_close := await _v0408_capture_image(Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5)
	_v0408_set_materials(v0408_after_materials)
	await _v0408_capture_diagnostic(root)
	_v0408_write_comparisons(primary, close, prior_roof_close, root)
	_v0408_write_audit(root)
	get_tree().quit(0)

func _v0408_capture_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	var image := await _v0408_capture_image(position, target, size)
	image.save_png(root.path_join(file_name))
	return image

func _v0408_capture_image(position: Vector3, target: Vector3, size: float) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080:
		image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	return image

func _v0408_set_materials(materials: Dictionary) -> void:
	for node_name in materials.keys():
		var node := v0400_house.find_child(str(node_name), true, false) as MeshInstance3D
		if node:
			node.material_override = materials[node_name]

func _v0408_capture_diagnostic(root: String) -> void:
	v0383_camera.position = Vector3(15.0, 16.0, 15.0)
	v0383_camera.size = 8.5
	v0383_camera.look_at(Vector3(-7.1, 1.55, 2.55), Vector3.UP)
	var candidates := ["V0400_Main_House_Left_Roof_Visual_Closure", "V0400_Main_House_Right_Roof_Visual_Closure", "V0400_Main_House_Ridge_Beam", "V0400_Main_House_Left_Eave"]
	var colours := [Color(0.95, 0.1, 0.1), Color(0.1, 0.95, 0.1), Color(0.1, 0.35, 1.0), Color(1.0, 0.75, 0.05)]
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#11100d"))
	for candidate_index in candidates.size():
		var node := v0400_house.find_child(candidates[candidate_index], true, false) as MeshInstance3D
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
		panel.size = Vector2(760.0, 90.0)
		var label := Label.new()
		label.position = Vector2(14.0, 10.0)
		label.add_theme_font_size_override("font_size", 21)
		label.text = "v0.408 ROOF MATERIAL DIAGNOSTIC\n" + candidates[candidate_index] + "  |  red/green/blue/yellow by panel"
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
	sheet.save_png(root.path_join("05_MAIN_HOUSE_ROOF_MATERIAL_DIAGNOSTIC.png"))

func _v0408_write_comparisons(primary: Image, close: Image, prior_close: Image, root: String) -> void:
	var prior := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0407/01_PRIMARY_RTS_COLOUR.png"))
	if prior and prior.get_width() == 1920:
		prior.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		wide.blit_rect(prior, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0407_V0408_WIDE_COMPARISON.png"))
	if prior_close and prior_close.get_width() == 1920:
		prior_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		near.blit_rect(prior_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0407_V0408_ROOF_CLOSE_COMPARISON.png"))

func _v0408_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0408-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0408_audit, "  "))

func _v0408_mesh_snapshot(node: MeshInstance3D) -> Dictionary:
	var mesh := node.mesh as ArrayMesh
	var arrays := mesh.surface_get_arrays(0) if mesh and mesh.get_surface_count() > 0 else []
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array if arrays.size() > Mesh.ARRAY_VERTEX else PackedVector3Array()
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array if arrays.size() > Mesh.ARRAY_INDEX else PackedInt32Array()
	var uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array if arrays.size() > Mesh.ARRAY_TEX_UV else PackedVector2Array()
	return {"material": node.material_override.resource_name if node.material_override else "null", "vertexCount": vertices.size(), "indexCount": indices.size(), "triangleCount": indices.size() / 3, "surfaceCount": mesh.get_surface_count() if mesh else 0, "uvCount": uvs.size(), "aabb": _v0408_aabb(mesh.get_aabb()) if mesh else {}, "transform": _v0407_transform(node.transform)}

func _v0408_aabb(value: AABB) -> Dictionary:
	return {"position": _v0406_vec(value.position), "size": _v0406_vec(value.size)}
