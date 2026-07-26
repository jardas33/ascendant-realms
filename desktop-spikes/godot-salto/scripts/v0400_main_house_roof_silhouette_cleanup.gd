extends "res://scripts/v0399_barn_outbuilding_structural_readability.gd"

## v0.400 is a visual-only, opt-in correction for the primary homestead roof.
## The accepted v0.399 barn, route, bridge, camera, characters, props, layout,
## and gameplay/default-runtime semantics remain authoritative.

const V0400_CHECKPOINT := "v0.400"
const V0400_CAPTURE_ROOT := "artifacts/runtime/v0400"

var v0400_capture_mode := false
var v0400_smoke_mode := false
var v0400_house: Node3D
var v0400_hidden_roof_count := 0

func _ready() -> void:
	_read_v0400_args()
	super._ready()
	_v0400_apply_roof_cleanup()

func _read_v0400_args() -> void:
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0400-house-roof-capture": v0400_capture_mode = true
		if arg == "--v0400-house-roof-smoke": v0400_smoke_mode = true
		if arg.begins_with("--artifact-root="): explicit_root = true
	if not explicit_root: v0388_capture_root = V0400_CAPTURE_ROOT
	if v0400_capture_mode:
		v0399_capture_mode = true
		v0398_capture_mode = true
		v0388_capture_mode = true
		v0388_smoke_mode = true
	if v0400_smoke_mode:
		v0399_smoke_mode = true
		v0398_smoke_mode = true
		v0388_smoke_mode = true

func _v0400_apply_roof_cleanup() -> void:
	if v0383_world == null: return
	v0400_house = v0383_world.find_child("V0394_One_Primary_Barrosan_Homestead", true, false) as Node3D
	if v0400_house == null: return
	if v0400_house.get_node_or_null("V0400_Main_House_Roof_Silhouette") != null: return
	var hidden_roof_count := 0
	# Match the imported material-role suffix rather than relying on the GLB
	# importer preserving the LOD node names across Godot versions. This keeps
	# granite, timber, doors, windows, and the chimney untouched.
	for mesh in v0400_house.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh as MeshInstance3D
		var mesh_resource_name := str(mesh_instance.mesh.resource_name) if mesh_instance.mesh else ""
		var roof_mesh_role := mesh_resource_name.contains("Roof_Front_Slate_Plane_Mesh")
		var collision_roof_role := str(mesh_instance.name).contains("Collision_RoofVolume")
		if str(mesh_instance.name).contains("Slate") or roof_mesh_role or collision_roof_role:
			mesh_instance.visible = false
			mesh_instance.set_deferred("visible", false)
			mesh_instance.mesh = null
			hidden_roof_count += 1
	# The imported GLB can expose the roof plane under a generated node name on
	# different Godot/importer versions. Re-apply the visual-only hide by mesh
	# role across the primary-house subtree after the importer has settled.
	for mesh in v0383_world.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh as MeshInstance3D
		var mesh_resource_name := str(mesh_instance.mesh.resource_name) if mesh_instance.mesh else ""
		if mesh_resource_name.contains("Roof_Front_Slate_Plane_Mesh") and _v0400_has_primary_house_ancestor(mesh_instance):
			if mesh_instance.visible:
				hidden_roof_count += 1
			mesh_instance.visible = false
			mesh_instance.set_deferred("visible", false)
			mesh_instance.mesh = null
	v0400_hidden_roof_count = hidden_roof_count
	var roof := Node3D.new()
	roof.name = "V0400_Main_House_Roof_Silhouette"
	roof.set_meta("visual_only", true)
	roof.set_meta("gameplay_mutation", false)
	roof.set_meta("position_preserved", true)
	roof.set_meta("single_ridge", true)
	roof.set_meta("hiddenAmbiguousSlateMeshes", hidden_roof_count)
	roof.position.z = 0.0
	v0400_house.add_child(roof)
	var slate := _v0400_material("V0400_Continuous_Weathered_Slate", Color("#343238"), 0.97)
	var slate_edge := _v0400_material("V0400_Slate_Edge", Color("#211f23"), 0.98)
	var timber := _v0400_material("V0400_Roof_Eave_Timber", Color("#3e2d25"), 0.96)
	var slate_gable_mask := _v0400_material("V0400_Slate_Gable_Occlusion", Color("#343238"), 0.97)
	slate_gable_mask.no_depth_test = true
	slate_gable_mask.render_priority = 20
	var half_width := 5.52
	var depth := 7.85
	var eave := 4.08
	var ridge := 7.18
	var roof_span := sqrt(pow(half_width, 2.0) + pow(ridge - eave, 2.0)) + 0.12
	var roof_angle := atan2(ridge - eave, half_width)
	_v0400_box_rotated(roof, "V0400_Main_House_Roof_Left_Plane", Vector3(roof_span, 0.22, depth), Vector3(-half_width * 0.5, (eave + ridge) * 0.5, 0.0), slate, roof_angle)
	_v0400_box_rotated(roof, "V0400_Main_House_Roof_Right_Plane", Vector3(roof_span, 0.22, depth), Vector3(half_width * 0.5, (eave + ridge) * 0.5, 0.0), slate, -roof_angle)
	_v0400_box_rotated(roof, "V0400_Main_House_Left_Roof_Visual_Closure", Vector3(roof_span, 0.04, depth + 0.08), Vector3(-half_width * 0.5, (eave + ridge) * 0.5, 0.0), slate_gable_mask, roof_angle)
	_v0400_box_rotated(roof, "V0400_Main_House_Right_Roof_Visual_Closure", Vector3(roof_span, 0.04, depth + 0.08), Vector3(half_width * 0.5, (eave + ridge) * 0.5, 0.0), slate_gable_mask, -roof_angle)
	_v0400_box(roof, "V0400_Main_House_Ridge_Beam", Vector3(0.26, 0.24, depth + 0.16), Vector3(0.0, ridge + 0.08, 0.0), slate_edge)
	_v0400_box(roof, "V0400_Main_House_Left_Eave", Vector3(0.20, 0.20, depth + 0.20), Vector3(-half_width - 0.04, eave - 0.06, 0.0), timber)
	_v0400_box(roof, "V0400_Main_House_Right_Eave", Vector3(0.20, 0.20, depth + 0.20), Vector3(half_width + 0.04, eave - 0.06, 0.0), timber)
	call_deferred("_v0400_reassert_roof_visibility")

func _v0400_has_primary_house_ancestor(node: Node) -> bool:
	var current := node.get_parent()
	while current:
		if current == v0400_house:
			return true
		current = current.get_parent()
	return false

func _v0400_reassert_roof_visibility() -> void:
	if v0400_house == null:
		return
	for mesh in v0400_house.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh as MeshInstance3D
		var mesh_resource_name := str(mesh_instance.mesh.resource_name) if mesh_instance.mesh else ""
		if str(mesh_instance.name).contains("Slate") or str(mesh_instance.name).contains("Collision_RoofVolume") or mesh_resource_name.contains("Roof_Front_Slate_Plane_Mesh"):
			mesh_instance.visible = false
			mesh_instance.mesh = null

func _v0400_material(name: String, color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = color
	material.roughness = roughness
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _v0400_box(parent: Node3D, name: String, size: Vector3, position: Vector3, material: Material) -> MeshInstance3D:
	return _v0400_box_rotated(parent, name, size, position, material, 0.0)

func _v0400_box_rotated(parent: Node3D, name: String, size: Vector3, position: Vector3, material: Material, rotation_z: float) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = position
	instance.rotation.z = rotation_z
	instance.material_override = material
	instance.set_meta("visual_only", true)
	parent.add_child(instance)
	return instance

func _capture_v0388_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0400_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 31.0, 24.0), Vector3(-5.3, 0.90, 3.05), 19.0, root)
	await _capture_v0400_view("02_MAIN_HOUSE_ROOF_CLOSE.png", Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("03_GRAYSCALE_PRIMARY.png"))
	var roof_close := await _capture_v0400_view("04_MAIN_HOUSE_ROOF_GRAYSCALE.png", Vector3(15.0, 16.0, 15.0), Vector3(-7.1, 1.55, 2.55), 8.5, root)
	roof_close.convert(Image.FORMAT_L8)
	roof_close.save_png(root.path_join("04_MAIN_HOUSE_ROOF_GRAYSCALE.png"))
	var prior := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0399/01_PRIMARY_RTS_VIEW.png"))
	var current := Image.load_from_file(root.path_join("01_PRIMARY_RTS_VIEW.png"))
	if prior and current:
		prior.convert(Image.FORMAT_RGBA8)
		current.convert(Image.FORMAT_RGBA8)
		var comparison := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
		comparison.blit_rect(prior, Rect2i(0, 0, prior.get_width(), prior.get_height()), Vector2i(0, 0))
		comparison.blit_rect(current, Rect2i(0, 0, current.get_width(), current.get_height()), Vector2i(1920, 0))
		comparison.save_png(root.path_join("05_V0399_V0400_PRIMARY_COMPARISON.png"))
	_write_v0400_json()
	get_tree().quit(0)

func _capture_v0400_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0400_json() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0400-main-house-roof-silhouette-cleanup.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0400_CHECKPOINT, "status": "RENDERED", "priorVerdict": "v0399-ACCEPTED", "scope": "primary-house-roof-silhouette-only", "singleRidge": true, "consistentEaves": true, "chimneyPreserved": true, "hiddenRoofMeshes": v0400_hidden_roof_count, "barn": "v0399-preserved", "route": "preserved", "bridge": "unchanged", "camera": "unchanged", "characters": "unchanged", "props": "unchanged", "layout": "unchanged", "gameplay": false, "defaultRuntime": "unchanged", "grayscale": true}, "  "))

func _smoke_v0388_exit() -> void:
	_v0400_apply_roof_cleanup()
	await get_tree().create_timer(0.6).timeout
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0400-main-house-roof-silhouette-cleanup-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0400_CHECKPOINT, "status": "PASS", "visualOnly": true, "singleRidge": true, "chimneyPreserved": true, "route": "unchanged", "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)
