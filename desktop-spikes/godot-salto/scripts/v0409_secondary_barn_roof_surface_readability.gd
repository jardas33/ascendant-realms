extends "res://scripts/v0408_main_house_roof_surface_readability.gd"

## v0.409 is a material-only, opt-in correction for the accepted subordinate
## barn. The barn's existing roof and trim geometry remains authoritative.

const V0409_CHECKPOINT := "v0.409"
const V0409_CAPTURE_ROOT := "artifacts/runtime/v0409"
const V0409_ROOF_TEXTURE := "res://assets/v0338/barrosan_house_02_material_gold_candidate_slate_albedo_1024.png"
const V0409_BARN_NODE_NAMES := [
	"V0399_Barn_Front_Gable",
	"V0399_Barn_Roof_Left",
	"V0399_Barn_Roof_Right",
	"V0399_Barn_Ridge_Beam",
	"V0399_Barn_Left_Eave",
	"V0399_Barn_Right_Eave"
]

var v0409_capture_mode := false
var v0409_smoke_mode := false
var v0409_barn: Node3D
var v0409_roof_texture: Texture2D
var v0409_audit: Dictionary = {}
var v0409_before_materials: Dictionary = {}
var v0409_after_materials: Dictionary = {}

func _ready() -> void:
	_read_v0409_args()
	super._ready()
	_v0409_apply_existing_material_treatment()

func _read_v0409_args() -> void:
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0409-secondary-barn-roof-capture": v0409_capture_mode = true
		if arg == "--v0409-secondary-barn-roof-smoke": v0409_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0409_CAPTURE_ROOT

func _read_v0408_args() -> void:
	super._read_v0408_args()
	if v0409_capture_mode or v0409_smoke_mode:
		v0408_capture_mode = v0409_capture_mode
		v0408_smoke_mode = v0409_smoke_mode
		v0388_capture_root = V0409_CAPTURE_ROOT

func _read_v0407_args() -> void:
	super._read_v0407_args()
	if v0409_capture_mode or v0409_smoke_mode:
		v0407_capture_mode = v0409_capture_mode
		v0407_smoke_mode = v0409_smoke_mode
		v0388_capture_root = V0409_CAPTURE_ROOT

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0409_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join("v0409-secondary-barn-roof-surface-readability-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"checkpoint": V0409_CHECKPOINT,
			"status": v0409_audit.get("status", "ASSET_UV_LIMITATION_SECONDARY_BARN_ROOF"),
			"candidateRetained": v0409_audit.get("candidateRetained", false),
			"materialOnly": v0409_audit.get("materialOnly", true),
			"geometryChanged": false,
			"uvArraysChanged": false,
			"gameplay": false,
			"defaultRuntime": "unchanged"
		}, "  "))
	get_tree().quit(0)

func _v0409_apply_existing_material_treatment() -> void:
	if v0399_barn == null:
		v0399_barn = v0383_world.find_child("V0394_One_Subordinate_Agricultural_Barn_Separate", true, false) as Node3D if v0383_world else null
	v0409_barn = v0399_barn
	if v0409_barn == null:
		_v0409_fail_closed("accepted subordinate barn root missing")
		return
	v0409_roof_texture = load(V0409_ROOF_TEXTURE) as Texture2D
	if v0409_roof_texture == null:
		_v0409_fail_closed("accepted weathered slate texture missing")
		return
	var slate := StandardMaterial3D.new()
	slate.resource_name = "V0409_Secondary_Barn_Weathered_Slate"
	slate.albedo_texture = v0409_roof_texture
	slate.albedo_color = Color("#a39a91")
	slate.roughness = 0.98
	slate.uv1_scale = Vector3(1.6, 1.6, 1.6)
	slate.uv1_triplanar = true
	slate.uv1_triplanar_sharpness = 1.0
	slate.cull_mode = BaseMaterial3D.CULL_DISABLED
	var ridge := StandardMaterial3D.new()
	ridge.resource_name = "V0409_Secondary_Barn_Slate_Ridge"
	ridge.albedo_color = Color("#393536")
	ridge.roughness = 0.98
	ridge.cull_mode = BaseMaterial3D.CULL_DISABLED
	var eave := StandardMaterial3D.new()
	eave.resource_name = "V0409_Secondary_Barn_Weathered_Eave_Timber"
	eave.albedo_color = Color("#46362c")
	eave.roughness = 0.98
	eave.cull_mode = BaseMaterial3D.CULL_DISABLED
	var before: Dictionary = {}
	var after: Dictionary = {}
	var required_nodes := 0
	var inventory: Array = []
	for mesh_candidate in v0409_barn.find_children("*", "MeshInstance3D", true, false):
		var inventory_node := mesh_candidate as MeshInstance3D
		inventory.append({"name": inventory_node.name, "visible": inventory_node.visible, "material": inventory_node.material_override.resource_name if inventory_node.material_override else "null"})
	for node_name in V0409_BARN_NODE_NAMES:
		var node := v0409_barn.find_child(node_name, true, false) as MeshInstance3D
		if node == null or node.mesh == null:
			_v0409_fail_closed("existing barn roof face missing: " + node_name)
			return
		required_nodes += 1
		before[node_name] = _v0409_mesh_snapshot(node)
		if node_name == "V0399_Barn_Front_Gable" and before[node_name].get("uvCount", 0) == 0:
			_v0409_fail_closed("visible roof-facing V0399_Barn_Front_Gable has no UV arrays; existing roof boxes cover only edge geometry")
			return
		v0409_before_materials[node_name] = node.material_override
		if node_name.contains("Front_Gable") or node_name.contains("Roof_Left") or node_name.contains("Roof_Right"):
			node.material_override = slate
		elif node_name.contains("Ridge"):
			node.material_override = ridge
		else:
			node.material_override = eave
		v0409_after_materials[node_name] = node.material_override
		after[node_name] = _v0409_mesh_snapshot(node)
	v0409_audit = {
		"baselineCommit": "548705c19c36aa2edf3655bc490c23372d515db3",
		"checkpoint": V0409_CHECKPOINT,
		"status": "RENDERED_CANDIDATE",
		"candidateRetained": true,
		"scope": "existing_secondary_barn_roof_materials_only",
		"materialOnly": true,
		"texture": V0409_ROOF_TEXTURE,
		"requiredBarnRoofNodes": required_nodes,
		"barnMeshInventory": inventory,
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
		"walls": "preserved",
		"entrance": "preserved",
		"eaves": "preserved_geometry_material_refined",
		"ridge": "preserved_geometry_material_refined",
		"mainHouse": "v0408-preserved",
		"camera": "unchanged",
		"lighting": "unchanged",
		"bridge": "unchanged",
		"route": "unchanged",
		"characters": "unchanged",
		"props": "unchanged",
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"fallbackRenderer": "unchanged",
		"debugRenderer": "unchanged"
	}

func _v0409_fail_closed(reason: String) -> void:
	v0409_before_materials.clear()
	v0409_after_materials.clear()
	v0409_audit = {
		"baselineCommit": "548705c19c36aa2edf3655bc490c23372d515db3",
		"checkpoint": V0409_CHECKPOINT,
		"status": "ASSET_UV_LIMITATION_SECONDARY_BARN_ROOF",
		"candidateRetained": false,
		"materialOnly": true,
		"reason": reason,
		"visibleRoofFacingSurface": "V0399_Barn_Front_Gable",
		"existingRoofPlanes": ["V0399_Barn_Roof_Left", "V0399_Barn_Roof_Right"],
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
		"walls": "preserved",
		"entrance": "preserved",
		"eaves": "preserved_geometry",
		"ridge": "preserved_geometry",
		"mainHouse": "v0408-preserved",
		"camera": "unchanged",
		"lighting": "unchanged",
		"bridge": "unchanged",
		"route": "unchanged",
		"characters": "unchanged",
		"props": "unchanged",
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"fallbackRenderer": "unchanged",
		"debugRenderer": "unchanged"
	}

func _v0409_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_SECONDARY_BARN_ROOF_CLOSE_COLOUR.png", Vector3(17.0, 18.0, 17.0), Vector3(-10.2, 1.40, 4.95), 7.4, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_SECONDARY_BARN_ROOF_GRAYSCALE.png"))
	_v0409_set_materials(v0409_before_materials)
	var prior_close := await _v0409_capture_image(Vector3(17.0, 18.0, 17.0), Vector3(-10.2, 1.40, 4.95), 7.4)
	_v0409_set_materials(v0409_after_materials)
	await _v0409_capture_diagnostic(root)
	_v0409_write_comparisons(primary, close, prior_close, root)
	_v0409_write_audit(root)
	get_tree().quit(0)

func _v0409_capture_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	var image := await _v0409_capture_image(position, target, size)
	image.save_png(root.path_join(file_name))
	return image

func _v0409_capture_image(position: Vector3, target: Vector3, size: float) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080:
		image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	return image

func _v0409_set_materials(materials: Dictionary) -> void:
	for node_name in materials.keys():
		var node := v0409_barn.find_child(str(node_name), true, false) as MeshInstance3D
		if node:
			node.material_override = materials[node_name]

func _v0409_capture_diagnostic(root: String) -> void:
	v0383_camera.position = Vector3(17.0, 18.0, 17.0)
	v0383_camera.size = 7.4
	v0383_camera.look_at(Vector3(-10.2, 1.40, 4.95), Vector3.UP)
	var candidates := ["V0399_Barn_Front_Gable", "V0399_Barn_Roof_Left", "V0399_Barn_Roof_Right", "V0399_Barn_Ridge_Beam"]
	var colours := [Color(0.95, 0.1, 0.1), Color(0.1, 0.95, 0.1), Color(0.1, 0.35, 1.0), Color(1.0, 0.75, 0.05)]
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#11100d"))
	for candidate_index in candidates.size():
		var node := v0409_barn.find_child(candidates[candidate_index], true, false) as MeshInstance3D
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
		label.text = "v0.409 BARN ROOF MATERIAL DIAGNOSTIC\n" + candidates[candidate_index] + "  |  red/green/blue/yellow by panel"
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
	sheet.save_png(root.path_join("05_SECONDARY_BARN_ROOF_MATERIAL_DIAGNOSTIC.png"))

func _v0409_write_comparisons(primary: Image, close: Image, prior_close: Image, root: String) -> void:
	var prior := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0408/01_PRIMARY_RTS_COLOUR.png"))
	if prior and prior.get_width() == 1920:
		prior.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		wide.blit_rect(prior, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0408_V0409_WIDE_COMPARISON.png"))
	if prior_close and prior_close.get_width() == 1920:
		prior_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		near.blit_rect(prior_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0408_V0409_BARN_ROOF_CLOSE_COMPARISON.png"))

func _v0409_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0409-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0409_audit, "  "))

func _v0409_mesh_snapshot(node: MeshInstance3D) -> Dictionary:
	var mesh := node.mesh
	var vertex_count := 0
	var index_count := 0
	var uv_count := 0
	var surface_count := mesh.get_surface_count() if mesh else 0
	if mesh is ArrayMesh and surface_count > 0:
		var arrays := mesh.surface_get_arrays(0)
		if arrays.size() > Mesh.ARRAY_VERTEX: vertex_count = (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
		if arrays.size() > Mesh.ARRAY_INDEX: index_count = (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size()
		if arrays.size() > Mesh.ARRAY_TEX_UV: uv_count = (arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array).size()
	return {
		"material": node.material_override.resource_name if node.material_override else "null",
		"meshType": mesh.get_class() if mesh else "null",
		"vertexCount": vertex_count,
		"indexCount": index_count,
		"triangleCount": index_count / 3,
		"surfaceCount": surface_count,
		"uvCount": uv_count,
		"aabb": _v0409_aabb(mesh.get_aabb()) if mesh else {},
		"transform": _v0407_transform(node.transform)
	}

func _v0409_aabb(value: AABB) -> Dictionary:
	return {"position": _v0406_vec(value.position), "size": _v0406_vec(value.size)}
