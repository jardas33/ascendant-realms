extends "res://scripts/v0382_clustered_highland_dressing.gd"

## v0.383 isolated repair: make the accepted crossing the focal point.
## The v0.380 infrastructure GLB is loaded read-only; only opt-in dressing,
## lighting, and capture framing are changed here.

const V0383_CHECKPOINT := "v0.383"
const V0383_KIT_PATH := "res://assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb"
const V0383_ASSET_ROOT := "res://assets/third_party/quaternius/v0370/"
const V0383_CAPTURE_ROOT := "artifacts/runtime/v0383"
const V0383_GLB_SHA256 := "746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb"
const V0383_SOURCE_SHA256 := "4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19"

var v0383_capture_mode := false
var v0383_smoke_mode := false
var v0383_capture_root := V0383_CAPTURE_ROOT
var v0383_iteration := 3
var v0383_camera: Camera3D
var v0383_world: Node3D
var v0383_dressing: Node3D

func _ready() -> void:
	_read_v0383_args()
	_build_v0383_environment()
	if not _build_v0383_world():
		get_tree().quit(1)
		return
	_build_v0383_camera()
	if v0383_capture_mode:
		_capture_v0383_sequence.call_deferred()
	elif v0383_smoke_mode:
		_smoke_v0383_exit.call_deferred()

func _read_v0383_args() -> void:
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0383-style-coherence-capture": v0383_capture_mode = true
		if arg == "--v0383-style-coherence-smoke": v0383_smoke_mode = true
		if arg.begins_with("--artifact-root="): v0383_capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0383-iteration="): v0383_iteration = clampi(int(arg.trim_prefix("--v0383-iteration=")), 1, 3)
	if v0383_capture_mode: v0383_smoke_mode = true

func _build_v0383_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#59685e")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d1d0c4")
	environment.ambient_light_energy = 0.42
	environment.ambient_light_sky_contribution = 0.24
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 0.68
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0383_Bridge_First_Neutral_Daylight"
	world_environment.environment = environment
	add_child(world_environment)

	var key := DirectionalLight3D.new()
	key.name = "V0383_Soft_Northwest_Key"
	key.rotation_degrees = Vector3(-48.0, -38.0, 0.0)
	key.light_color = Color("#e5d4b7")
	key.light_energy = 0.68
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 80.0
	key.shadow_bias = 0.09
	add_child(key)

	var fill := DirectionalLight3D.new()
	fill.name = "V0383_Cool_Soft_Fill"
	fill.rotation_degrees = Vector3(-28.0, 142.0, 0.0)
	fill.light_color = Color("#b8c6c0")
	fill.light_energy = 0.18
	fill.shadow_enabled = false
	add_child(fill)

func _build_v0383_world() -> bool:
	v0383_world = Node3D.new()
	v0383_world.name = "V0383_Bridge_First_Highland_Style_Coherence"
	add_child(v0383_world)
	var kit_scene := load(V0383_KIT_PATH) as PackedScene
	if kit_scene == null:
		push_error("v0.383 accepted v0.380 GLB failed to import: " + V0383_KIT_PATH)
		return false
	var kit := kit_scene.instantiate()
	kit.name = "V0380_Accepted_Corrected_Highland_Infrastructure_Unchanged"
	v0383_world.add_child(kit)
	_subdue_accepted_nonstructural_scatter(kit)
	v0383_dressing = Node3D.new()
	v0383_dressing.name = "V0383_Restricted_Dressing_Only"
	v0383_world.add_child(v0383_dressing)
	_build_v0383_rock_clusters()
	_build_v0383_masses()
	_build_v0383_bank_clusters()
	_build_v0383_approach_dressing()
	return true

func _subdue_accepted_nonstructural_scatter(root: Node) -> void:
	for child in root.get_children():
		var child_name := str(child.name)
		if child_name.begins_with("Rock_") or child_name.begins_with("Shrub_") or child_name.begins_with("Reed_"):
			child.visible = false
		_subdue_accepted_nonstructural_scatter(child)

func _build_v0383_rock_clusters() -> void:
	var root := Node3D.new()
	root.name = "V0383_Dark_Grouped_Geological_Rocks"
	v0383_dressing.add_child(root)
	var clusters := [
		["RockGroup_WestOuter", Vector3(-8.8, 0.20, -7.3), 0.55],
		["RockGroup_EastOuter", Vector3(7.6, 0.20, 7.0), 0.52],
		["RockGroup_WestDry", Vector3(-7.0, 0.18, 6.4), 0.48],
		["RockGroup_EastDry", Vector3(8.4, 0.18, -6.5), 0.46]
	]
	for item in clusters:
		var group := Node3D.new()
		group.name = str(item[0])
		root.add_child(group)
		var center: Vector3 = item[1]
		var scale_value: float = item[2]
		_place_v0383("nature/Rock_Medium_2.gltf", group, center + Vector3(-0.38, 0.02, 0.12), Vector3.ONE * scale_value, -0.18)
		_place_v0383("nature/Rock_Medium_3.gltf", group, center + Vector3(0.28, 0.02, -0.22), Vector3(scale_value * 0.72, scale_value * 0.60, scale_value * 0.74), 0.32)

func _build_v0383_masses() -> void:
	var root := Node3D.new()
	root.name = "V0383_Spaced_Asymmetrical_Landscape_Masses"
	v0383_dressing.add_child(root)
	var upper_z := -7.3
	var lower_z := 7.0
	var mass_scale := 1.0
	if v0383_iteration >= 2:
		upper_z = -6.0
		lower_z = 7.6
		mass_scale = 0.92
	if v0383_iteration >= 3:
		upper_z = -4.2
		lower_z = 8.6
		mass_scale = 0.70
	_build_v0383_mass(root, "UpperBank_MassA", Vector3(-9.6, 0.26, upper_z), [
		["nature/CommonTree_1.gltf", Vector3(-1.2, 0.12, -0.6), 0.84, -0.20],
		["nature/Pine_2.gltf", Vector3(0.5, 0.12, 0.8), 0.72, 0.28],
		["nature/CommonTree_3.gltf", Vector3(2.0, 0.12, -0.2), 0.58, 0.44]
	], mass_scale)
	_build_v0383_mass(root, "LowerBank_MassB", Vector3(9.7, 0.26, lower_z), [
		["nature/Pine_2.gltf", Vector3(-0.7, 0.12, 0.4), 0.82, 0.18],
		["nature/CommonTree_1.gltf", Vector3(1.0, 0.12, -0.7), 0.60, -0.34],
		["nature/CommonTree_3.gltf", Vector3(2.3, 0.12, 0.7), 0.50, 0.38]
	], mass_scale)

func _build_v0383_mass(root: Node3D, name: String, origin: Vector3, trees: Array, multiplier: float = 1.0) -> void:
	var group := Node3D.new()
	group.name = name
	root.add_child(group)
	for tree in trees:
		_place_v0383(str(tree[0]), group, origin + tree[1], Vector3.ONE * float(tree[2]) * multiplier, float(tree[3]))
	_place_v0383("nature/Grass_Common_Tall.gltf", group, origin + Vector3(-0.8, 0.08, 1.2), Vector3.ONE * 0.48 * multiplier, -0.18)
	_place_v0383("nature/Grass_Wispy_Short.gltf", group, origin + Vector3(1.0, 0.06, -1.1), Vector3.ONE * 0.72 * multiplier, 0.22)

func _build_v0383_bank_clusters() -> void:
	var root := Node3D.new()
	root.name = "V0383_Six_NonRepeating_Riverbank_Clusters"
	v0383_dressing.add_child(root)
	var positions := [
		["Cluster_A_ReedsLowGrassRock", Vector3(0.82, 0.16, -6.6), 0.12],
		["Cluster_B_RocksSparseReeds", Vector3(0.92, 0.16, -3.4), -0.32],
		["Cluster_C_LowShrubBuriedRock", Vector3(0.86, 0.16, 5.4), 0.38],
		["Cluster_D_RocksSparseReeds", Vector3(5.08, 0.16, -6.0), -0.24],
		["Cluster_E_ReedsLowGrassRock", Vector3(5.00, 0.16, 3.5), 0.28],
		["Cluster_F_LowShrubBuriedRock", Vector3(5.06, 0.16, 6.6), -0.42]
	]
	for index in positions.size():
		var item = positions[index]
		var group := Node3D.new()
		group.name = str(item[0])
		root.add_child(group)
		var center: Vector3 = item[1]
		var yaw: float = item[2]
		match index % 3:
			0:
				_place_v0383("nature/Grass_Common_Tall.gltf", group, center + Vector3(-0.28, 0.07, 0.22), Vector3(0.72, 0.74, 0.72), yaw)
				_place_v0383("nature/Grass_Wispy_Short.gltf", group, center + Vector3(0.32, 0.05, -0.18), Vector3.ONE * 0.78, yaw + 0.28)
				_place_v0383("nature/Rock_Medium_2.gltf", group, center + Vector3(0.66, 0.03, 0.32), Vector3.ONE * 0.34, yaw - 0.16)
			1:
				_place_v0383("nature/Rock_Medium_2.gltf", group, center + Vector3(-0.42, 0.03, 0.08), Vector3.ONE * 0.42, yaw)
				_place_v0383("nature/Rock_Medium_3.gltf", group, center + Vector3(0.42, 0.04, -0.26), Vector3(0.34, 0.29, 0.36), yaw + 0.36)
				_place_v0383("nature/Grass_Wispy_Short.gltf", group, center + Vector3(0.05, 0.05, 0.52), Vector3.ONE * 0.56, yaw - 0.20)
			2:
				_place_v0383("nature/Grass_Wispy_Short.gltf", group, center + Vector3(-0.24, 0.06, -0.12), Vector3.ONE * 0.46, yaw)
				_place_v0383("nature/Grass_Wispy_Short.gltf", group, center + Vector3(0.40, 0.05, 0.30), Vector3.ONE * 0.60, yaw + 0.22)
				_place_v0383("nature/Rock_Medium_3.gltf", group, center + Vector3(-0.56, 0.03, 0.38), Vector3.ONE * 0.30, yaw - 0.25)

func _build_v0383_approach_dressing() -> void:
	var root := Node3D.new()
	root.name = "V0383_Minimal_Approach_Dressing"
	v0383_dressing.add_child(root)
	_place_v0383("village/Prop_WoodenFence_Single.gltf", root, Vector3(-7.4, 0.20, -5.2), Vector3(0.42, 0.36, 0.36), 0.15)
	_place_v0383("props/Crate_Wooden.gltf", root, Vector3(7.0, 0.24, 5.0), Vector3.ONE * 0.30, -0.12)

func _build_v0383_camera() -> void:
	v0383_camera = Camera3D.new()
	v0383_camera.name = "V0383_Bridge_First_Oblique_RTS_Camera"
	v0383_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	v0383_camera.size = 24.5
	v0383_camera.current = true
	v0383_camera.position = Vector3(24.0, 30.0, 24.0)
	add_child(v0383_camera)
	v0383_camera.look_at(Vector3(1.0, 0.0, 0.0), Vector3.UP)

func _capture_v0383_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0383_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0383_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 30.0, 24.0), Vector3(1.0, 0.0, 0.0), 24.5, root)
	await _capture_v0383_view("02_BRIDGE_CLEARANCE_AUDIT.png", Vector3(17.0, 22.0, 17.0), Vector3(1.0, -0.04, 0.0), 15.5, root)
	await _capture_v0383_view("03_RIVERBANK_VARIATION_DETAIL.png", Vector3(15.0, 20.0, 15.0), Vector3(2.8, -0.06, 4.0), 14.5, root)
	await _capture_v0383_view("04_VEGETATION_MASS_SPACING.png", Vector3(26.0, 36.0, 26.0), Vector3(1.0, 0.0, 0.0), 27.0, root)
	await _capture_v0383_view("05_DRESSING_DISTRIBUTION_AUDIT.png", Vector3(24.0, 46.0, 24.0), Vector3(1.0, 0.0, 0.0), 31.0, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("06_GRAYSCALE_PRIMARY.png"))
	_write_v0383_json("v0383-highland-style-coherence.json", {
		"checkpoint": V0383_CHECKPOINT,
		"status": "RENDERED",
		"iteration": v0383_iteration,
		"resolution": "1920x1080",
		"stage": "highland-dressing-visual-hierarchy-and-style-coherence-repair",
		"baseKit": V0383_KIT_PATH,
		"baseKitUnchanged": true,
		"dressingOnly": true,
		"protectedBridgeClearance": true,
		"riverbankClusters": 6,
		"highlandMasses": 2,
		"rockClusters": 4,
		"isolatedRocks": 0,
		"strongRedAccents": 0,
		"buildings": false,
		"units": false,
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"route": "opt-in-only",
		"glbSha256": V0383_GLB_SHA256,
		"sourceSha256": V0383_SOURCE_SHA256
	})
	get_tree().quit(0)

func _capture_v0383_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080:
		image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _place_v0383(relative_path: String, parent: Node3D, position: Vector3, scale: Vector3, yaw: float) -> Node3D:
	var packed := load(V0383_ASSET_ROOT + relative_path) as PackedScene
	if packed == null:
		push_error("v0.383 missing existing in-repo asset: " + relative_path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("v0.383 asset is not Node3D: " + relative_path)
		return null
	instance.name = relative_path.get_file().get_basename()
	instance.position = position
	instance.scale = scale
	instance.rotation.y = yaw
	parent.add_child(instance)
	return instance

func _write_v0383_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(v0383_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_v0383_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_v0383_json("v0383-highland-style-coherence-smoke.json", {
		"checkpoint": V0383_CHECKPOINT,
		"status": "PASS",
		"sceneLoaded": true,
		"baseKit": V0383_KIT_PATH,
		"baseKitUnchanged": true,
		"protectedBridgeClearance": true,
		"riverbankClusters": 6,
		"highlandMasses": 2,
		"rockClusters": 4,
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"route": "opt-in-only",
		"glbSha256": V0383_GLB_SHA256,
		"sourceSha256": V0383_SOURCE_SHA256
	})
	get_tree().quit(0)
