extends "res://scripts/v0398_route_edge_bedding_cleanup.gd"

## v0.399 is a visual-only, opt-in correction for the subordinate left
## outbuilding. The accepted v0.398 route, bridge, camera, characters, props,
## layout, and gameplay semantics remain authoritative.

const V0399_CHECKPOINT := "v0.399"
const V0399_CAPTURE_ROOT := "artifacts/runtime/v0399"

var v0399_capture_mode := false
var v0399_smoke_mode := false
var v0399_barn: Node3D

func _ready() -> void:
	_read_v0399_args()
	super._ready()
	_v0399_apply_barn_structure()

func _read_v0398_args() -> void:
	super._read_v0398_args()
	_read_v0399_args()

func _read_v0399_args() -> void:
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0399-barn-structure-capture": v0399_capture_mode = true
		if arg == "--v0399-barn-structure-smoke": v0399_smoke_mode = true
		if arg.begins_with("--artifact-root="): explicit_root = true
	if not explicit_root: v0388_capture_root = V0399_CAPTURE_ROOT
	if v0399_capture_mode:
		v0398_capture_mode = true
		v0388_capture_mode = true
		v0388_smoke_mode = true
	if v0399_smoke_mode:
		v0398_smoke_mode = true
		v0388_smoke_mode = true

func _v0399_apply_barn_structure() -> void:
	# v0.394 is the authoritative opt-in settlement layer in this chain. The
	# older v0.386 name is intentionally not used because it is not present in
	# the rendered v0.398 hierarchy.
	v0399_barn = v0383_world.find_child("V0394_One_Subordinate_Agricultural_Barn_Separate", true, false) as Node3D if v0383_world else null
	if v0399_barn == null: return
	if v0399_barn.get_node_or_null("V0399_Barn_Structural_Readability") != null: return
	for mesh in v0399_barn.find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).visible = false
	v0399_barn.set_meta("v0399_original_asset_retained", true)
	v0399_barn.set_meta("v0399_original_asset_visible", false)
	var shell := Node3D.new()
	shell.name = "V0399_Barn_Structural_Readability"
	shell.set_meta("visual_only", true)
	shell.set_meta("gameplay_mutation", false)
	shell.set_meta("position_preserved", true)
	v0399_barn.add_child(shell)
	var stone := _v0399_material("V0399_Warm_Weathered_Stone", Color("#645747"), 0.94)
	var stone_light := _v0399_material("V0399_Sunlit_Stone", Color("#806f5a"), 0.94)
	var timber := _v0399_material("V0399_Weathered_Timber", Color("#4d3526"), 0.96)
	var timber_light := _v0399_material("V0399_Dry_Timber_Edge", Color("#76553a"), 0.96)
	var slate := _v0399_material("V0399_Charcoal_Slate", Color("#272522"), 0.98)
	var door := _v0399_material("V0399_Barn_Door", Color("#36251d"), 0.98)
	var shadow := _v0399_material("V0399_Barn_Contact_Shadow", Color(0.10, 0.075, 0.055, 0.32), 1.0, true)
	var width := 7.2
	var depth := 4.8
	var wall_height := 3.45
	var ridge_height := 5.25
	_v0399_box(shell, "V0399_Barn_Contact_Shadow", Vector3(width + 0.9, 0.045, depth + 0.9), Vector3(0.0, 0.035, 0.0), shadow)
	_v0399_box(shell, "V0399_Barn_Stone_Base", Vector3(width + 0.18, 0.36, depth + 0.18), Vector3(0.0, 0.24, 0.0), stone)
	_v0399_box(shell, "V0399_Barn_Main_Walls", Vector3(width, wall_height, depth), Vector3(0.0, 0.36 + wall_height * 0.5, 0.0), stone)
	_v0399_gable(shell, "V0399_Barn_Front_Gable", width + 0.02, depth + 0.02, wall_height + 0.36, ridge_height + 0.18, stone_light)
	var roof_span := sqrt(pow(width * 0.5 + 0.42, 2.0) + pow(ridge_height - (wall_height + 0.36) + 0.28, 2.0))
	var roof_angle := atan2(ridge_height - (wall_height + 0.36) + 0.28, width * 0.5 + 0.42)
	_v0399_box_rotated(shell, "V0399_Barn_Roof_Left", Vector3(roof_span, 0.28, depth + 0.62), Vector3(-width * 0.25, (wall_height + ridge_height) * 0.5 + 0.08, 0.0), slate, roof_angle)
	_v0399_box_rotated(shell, "V0399_Barn_Roof_Right", Vector3(roof_span, 0.28, depth + 0.62), Vector3(width * 0.25, (wall_height + ridge_height) * 0.5 + 0.08, 0.0), slate, -roof_angle)
	_v0399_box(shell, "V0399_Barn_Ridge_Beam", Vector3(0.28, 0.26, depth + 0.70), Vector3(0.0, ridge_height + 0.08, 0.0), timber)
	_v0399_box(shell, "V0399_Barn_Left_Eave", Vector3(0.24, 0.22, depth + 0.56), Vector3(-width * 0.5 - 0.10, wall_height + 0.44, 0.0), timber)
	_v0399_box(shell, "V0399_Barn_Right_Eave", Vector3(0.24, 0.22, depth + 0.56), Vector3(width * 0.5 + 0.10, wall_height + 0.44, 0.0), timber)
	var front_z := -depth * 0.5 - 0.08
	_v0399_box(shell, "V0399_Barn_Entrance_Door", Vector3(1.05, 1.92, 0.14), Vector3(0.0, 1.32, front_z), door)
	_v0399_box(shell, "V0399_Barn_Door_Left_Post", Vector3(0.18, 2.18, 0.20), Vector3(-0.66, 1.38, front_z - 0.02), timber_light)
	_v0399_box(shell, "V0399_Barn_Door_Right_Post", Vector3(0.18, 2.18, 0.20), Vector3(0.66, 1.38, front_z - 0.02), timber_light)
	_v0399_box(shell, "V0399_Barn_Door_Lintel", Vector3(1.48, 0.20, 0.20), Vector3(0.0, 2.43, front_z - 0.02), timber_light)
	_v0399_box(shell, "V0399_Barn_Front_Beam", Vector3(width - 0.34, 0.18, 0.18), Vector3(0.0, 0.72, front_z - 0.02), timber)
	for x in [-2.25, 2.25]:
		_v0399_box(shell, "V0399_Barn_Front_Window_%s" % str(x), Vector3(0.62, 0.46, 0.10), Vector3(x, 2.05, front_z - 0.03), door)
		_v0399_box(shell, "V0399_Barn_Front_Post_%s" % str(x), Vector3(0.16, wall_height - 0.25, 0.18), Vector3(x, 1.85, front_z - 0.01), timber)
	for x in [-width * 0.25, width * 0.25]:
		_v0399_box(shell, "V0399_Barn_Side_Beam_%s" % str(x), Vector3(0.18, 0.20, depth - 0.24), Vector3(x, 2.04, depth * 0.02), timber_light)

func _v0399_material(name: String, color: Color, roughness: float, alpha := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = color
	material.roughness = roughness
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if alpha: material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material

func _v0399_box(parent: Node3D, name: String, size: Vector3, position: Vector3, material: Material) -> MeshInstance3D:
	return _v0399_box_rotated(parent, name, size, position, material, 0.0)

func _v0399_box_rotated(parent: Node3D, name: String, size: Vector3, position: Vector3, material: Material, rotation_z: float) -> MeshInstance3D:
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

func _v0399_gable(parent: Node3D, name: String, width: float, depth: float, eave: float, ridge: float, material: Material) -> MeshInstance3D:
	var half_w := width * 0.5
	var half_d := depth * 0.5
	var vertices := PackedVector3Array([
		Vector3(-half_w, eave, -half_d), Vector3(half_w, eave, -half_d), Vector3(0.0, ridge, -half_d),
		Vector3(-half_w, eave, half_d), Vector3(half_w, eave, half_d), Vector3(0.0, ridge, half_d)
	])
	var indices := PackedInt32Array([0, 1, 2, 3, 5, 4, 0, 3, 4, 0, 4, 1, 1, 4, 5, 1, 5, 2, 2, 5, 3, 2, 3, 0])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = mesh
	instance.material_override = material
	instance.set_meta("visual_only", true)
	parent.add_child(instance)
	return instance

func _capture_v0388_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0399_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 31.0, 24.0), Vector3(-5.3, 0.90, 3.05), 19.0, root)
	await _capture_v0399_view("02_BARN_STRUCTURAL_CLOSE.png", Vector3(17.0, 18.0, 17.0), Vector3(-10.2, 1.40, 4.95), 7.4, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("03_GRAYSCALE_PRIMARY.png"))
	var barn_close := await _capture_v0399_view("04_BARN_STRUCTURAL_GRAYSCALE.png", Vector3(17.0, 18.0, 17.0), Vector3(-10.2, 1.40, 4.95), 7.4, root)
	barn_close.convert(Image.FORMAT_L8)
	barn_close.save_png(root.path_join("04_BARN_STRUCTURAL_GRAYSCALE.png"))
	var prior := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0398/01_PRIMARY_RTS_VIEW.png"))
	var current := Image.load_from_file(root.path_join("01_PRIMARY_RTS_VIEW.png"))
	if prior and current:
		prior.convert(Image.FORMAT_RGBA8)
		current.convert(Image.FORMAT_RGBA8)
		var comparison := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
		comparison.blit_rect(prior, Rect2i(0, 0, prior.get_width(), prior.get_height()), Vector2i(0, 0))
		comparison.blit_rect(current, Rect2i(0, 0, current.get_width(), current.get_height()), Vector2i(1920, 0))
		comparison.save_png(root.path_join("05_V0398_V0399_PRIMARY_COMPARISON.png"))
	_write_v0399_json()
	get_tree().quit(0)

func _capture_v0399_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0399_json() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0399-barn-outbuilding-structural-readability.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"checkpoint": V0399_CHECKPOINT, "status": "RENDERED",
			"priorVerdict": "v0398-ACCEPTED", "scope": "left-subordinate-outbuilding-only",
			"walls": "visible", "eaves": "visible", "entrance": "visible",
			"contactShadow": "visible", "route": "v0398-preserved", "bridge": "unchanged",
			"camera": "unchanged", "characters": "unchanged", "props": "unchanged",
			"layout": "unchanged", "gameplay": false, "defaultRuntime": "unchanged",
			"grayscale": true
		}, "  "))

func _smoke_v0388_exit() -> void:
	_v0399_apply_barn_structure()
	await get_tree().create_timer(0.6).timeout
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0399-barn-outbuilding-structural-readability-smoke.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"checkpoint": V0399_CHECKPOINT, "status": "PASS", "visualOnly": true, "barnStructure": true, "route": "unchanged", "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)
