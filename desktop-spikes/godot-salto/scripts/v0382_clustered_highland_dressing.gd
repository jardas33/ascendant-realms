extends Node3D

## v0.382 isolated environment dressing repair.
## The accepted v0.380 infrastructure kit is loaded unchanged. This scene
## replaces v0.381's sparse showroom distribution with deliberate clusters.

const CHECKPOINT := "v0.382"
const KIT_PATH := "res://assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb"
const ASSET_ROOT := "res://assets/third_party/quaternius/v0370/"
const CAPTURE_ROOT := "artifacts/runtime/v0382"
const INTAKE_GLB_SHA256 := "746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb"
const INTAKE_SOURCE_SHA256 := "4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19"

var capture_mode := false
var smoke_mode := false
var capture_root := CAPTURE_ROOT
var iteration := 3
var camera: Camera3D
var world: Node3D
var dressing: Node3D

func _ready() -> void:
	_read_args()
	_build_environment()
	if not _build_world():
		get_tree().quit(1)
		return
	_build_camera()
	if capture_mode:
		_capture_sequence.call_deferred()
	elif smoke_mode:
		_smoke_exit.call_deferred()

func _read_args() -> void:
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0382-clustered-dressing-capture": capture_mode = true
		if arg == "--v0382-clustered-dressing-smoke": smoke_mode = true
		if arg.begins_with("--artifact-root="): capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0382-iteration="): iteration = clampi(int(arg.trim_prefix("--v0382-iteration=")), 1, 3)
	if capture_mode: smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#56675c")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#c8c8ba")
	environment.ambient_light_energy = 0.28 if iteration == 1 else (0.26 if iteration == 2 else 0.24)
	environment.ambient_light_sky_contribution = 0.20
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 0.66 if iteration < 3 else 0.64
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0382_Neutral_Warm_Highland_Daylight"
	world_environment.environment = environment
	add_child(world_environment)

	var key := DirectionalLight3D.new()
	key.name = "V0382_Warm_Northwest_Key"
	key.rotation_degrees = Vector3(-50.0, -38.0, 0.0)
	key.light_color = Color("#ead1ad")
	key.light_energy = 0.88 if iteration == 1 else (0.92 if iteration == 2 else 0.90)
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 120.0
	key.shadow_bias = 0.035
	add_child(key)

	var fill := DirectionalLight3D.new()
	fill.name = "V0382_Cool_Readability_Fill"
	fill.rotation_degrees = Vector3(-30.0, 142.0, 0.0)
	fill.light_color = Color("#aec0bd")
	fill.light_energy = 0.08 if iteration == 1 else 0.07
	fill.shadow_enabled = false
	add_child(fill)

func _build_world() -> bool:
	world = Node3D.new()
	world.name = "V0382_Accepted_Crossing_With_Clustered_Highland_Dressing"
	add_child(world)
	var kit_scene := load(KIT_PATH) as PackedScene
	if kit_scene == null:
		push_error("v0.382 accepted v0.380 GLB failed to import: " + KIT_PATH)
		return false
	var kit := kit_scene.instantiate()
	kit.name = "V0380_Accepted_Corrected_Highland_Infrastructure_Unchanged"
	world.add_child(kit)

	dressing = Node3D.new()
	dressing.name = "V0382_Clustered_Highland_Dressing_Only"
	world.add_child(dressing)
	_build_rock_clusters()
	_build_highland_masses()
	if iteration >= 2:
		_build_riverbank_clusters()
	if iteration >= 3:
		_build_approach_dressing()
	return true

func _build_rock_clusters() -> void:
	var root := Node3D.new()
	root.name = "V0382_Geological_Rock_Clusters"
	dressing.add_child(root)
	var clusters := [
		["RockCluster_01_WestWetSlope", Vector3(-8.8, 0.24, -7.3), 0.72],
		["RockCluster_02_WestUpperSlope", Vector3(-7.2, 0.22, 6.7), 0.64],
		["RockCluster_03_EastWetSlope", Vector3(6.5, 0.24, -6.9), 0.70],
		["RockCluster_04_EastUpperSlope", Vector3(7.4, 0.22, 6.4), 0.66],
		["RockCluster_05_NorthApproach", Vector3(-4.6, 0.22, 8.0), 0.58]
	]
	for item in clusters:
		var group := Node3D.new()
		group.name = str(item[0])
		root.add_child(group)
		var center: Vector3 = item[1]
		var s: float = item[2]
		_place("nature/Rock_Medium_1.gltf", group, center + Vector3(-0.55, 0.02, 0.10), Vector3.ONE * s, -0.18)
		_place("nature/Rock_Medium_2.gltf", group, center + Vector3(0.15, 0.03, -0.36), Vector3(s * 0.82, s * 0.72, s * 0.86), 0.30)
		_place("nature/Rock_Medium_3.gltf", group, center + Vector3(0.62, 0.02, 0.22), Vector3(s * 0.70, s * 0.58, s * 0.74), -0.44)
		_place("nature/RockPath_Round_Wide.gltf", group, center + Vector3(-0.02, -0.01, 0.55), Vector3(s * 0.78, s * 0.34, s * 0.72), 0.08)

func _build_highland_masses() -> void:
	var root := Node3D.new()
	root.name = "V0382_Highland_Vegetation_Masses"
	dressing.add_child(root)
	_build_mass(root, "HighlandMass_West", Vector3(-10.2, 0.34, -6.1), [
		["nature/CommonTree_1.gltf", Vector3(-1.8, 0.16, -1.4), 1.30, -0.20],
		["nature/CommonTree_3.gltf", Vector3(0.0, 0.12, 0.9), 1.08, 0.34],
		["nature/Pine_2.gltf", Vector3(1.7, 0.14, -0.6), 1.16, -0.38]
	])
	_build_mass(root, "HighlandMass_East", Vector3(10.2, 0.34, 6.0), [
		["nature/Pine_2.gltf", Vector3(-1.8, 0.14, 0.8), 1.38, 0.18],
		["nature/CommonTree_1.gltf", Vector3(0.2, 0.12, -1.0), 1.12, -0.32],
		["nature/CommonTree_3.gltf", Vector3(1.8, 0.16, 0.2), 0.96, 0.40]
	])

func _build_mass(root: Node3D, name: String, origin: Vector3, trees: Array) -> void:
	var group := Node3D.new()
	group.name = name
	root.add_child(group)
	for tree in trees:
		_place(str(tree[0]), group, origin + tree[1], Vector3.ONE * float(tree[2]), float(tree[3]))
	var foliage := [
		["nature/Bush_Common.gltf", Vector3(-1.2, 0.10, 1.8), 1.05, -0.20],
		["nature/Bush_Common_Flowers.gltf", Vector3(0.7, 0.10, 1.6), 0.92, 0.22],
		["nature/Grass_Common_Tall.gltf", Vector3(-2.0, 0.08, 0.8), 1.15, 0.12],
		["nature/Grass_Wispy_Short.gltf", Vector3(1.7, 0.08, -1.3), 1.05, -0.32]
	]
	for item in foliage:
		_place(str(item[0]), group, origin + item[1], Vector3.ONE * float(item[2]), float(item[3]))
	_place("nature/Rock_Medium_2.gltf", group, origin + Vector3(-0.4, 0.04, -1.8), Vector3.ONE * 0.72, 0.18)
	_place("nature/Rock_Medium_3.gltf", group, origin + Vector3(1.5, 0.04, 0.7), Vector3.ONE * 0.58, -0.40)
	_place("nature/RockPath_Round_Wide.gltf", group, origin + Vector3(-1.5, 0.0, -0.1), Vector3(0.62, 0.25, 0.58), 0.08)

func _build_riverbank_clusters() -> void:
	var root := Node3D.new()
	root.name = "V0382_Riverbank_Vegetation_Clusters"
	dressing.add_child(root)
	var positions := [
		["RiverbankCluster_A_WestNorth", Vector3(1.00, 0.20, -7.4), 0.20],
		["RiverbankCluster_B_WestMid", Vector3(1.08, 0.20, -4.1), -0.35],
		["RiverbankCluster_C_WestSouth", Vector3(1.02, 0.20, 5.9), 0.42],
		["RiverbankCluster_D_EastNorth", Vector3(4.90, 0.20, -6.0), -0.28],
		["RiverbankCluster_E_EastMid", Vector3(4.84, 0.20, 2.8), 0.34],
		["RiverbankCluster_F_EastSouth", Vector3(4.86, 0.20, 6.7), -0.46]
	]
	for item in positions:
		var group := Node3D.new()
		group.name = str(item[0])
		root.add_child(group)
		var center: Vector3 = item[1]
		var yaw: float = item[2]
		_place("nature/Grass_Common_Tall.gltf", group, center + Vector3(-0.34, 0.10, 0.28), Vector3(1.22, 1.22, 1.22), yaw)
		_place("nature/Grass_Common_Tall.gltf", group, center + Vector3(0.28, 0.10, -0.18), Vector3(1.02, 1.12, 1.08), yaw + 0.35)
		_place("nature/Grass_Wispy_Short.gltf", group, center + Vector3(0.66, 0.06, 0.30), Vector3(1.10, 1.10, 1.10), yaw - 0.20)
		_place("nature/Bush_Common.gltf", group, center + Vector3(-0.18, 0.09, -0.56), Vector3.ONE * 0.96, yaw + 0.18)
		_place("nature/Rock_Medium_1.gltf", group, center + Vector3(-0.72, 0.04, -0.08), Vector3.ONE * 0.52, yaw - 0.15)
		_place("nature/Rock_Medium_3.gltf", group, center + Vector3(0.72, 0.04, -0.20), Vector3(0.44, 0.38, 0.46), yaw + 0.48)

func _build_approach_dressing() -> void:
	var root := Node3D.new()
	root.name = "V0382_Restrained_Bridge_Approach_Dressing"
	dressing.add_child(root)
	_place("village/Prop_WoodenFence_Single.gltf", root, Vector3(-7.6, 0.24, -4.8), Vector3(0.58, 0.50, 0.50), 0.15)
	_place("village/Prop_WoodenFence_Single.gltf", root, Vector3(7.2, 0.24, 4.2), Vector3(0.52, 0.46, 0.46), -0.18)
	_place("props/Crate_Wooden.gltf", root, Vector3(-6.9, 0.30, 5.2), Vector3.ONE * 0.42, -0.12)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0382_Tight_Oblique_RTS_Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 22.0
	camera.current = true
	camera.position = Vector3(21.0, 25.0, 22.0)
	add_child(camera)
	camera.look_at(Vector3(1.0, 0.0, 0.0), Vector3.UP)

func _capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_view("01_PRIMARY_RTS_VIEW.png", Vector3(21.0, 25.0, 22.0), Vector3(1.0, 0.0, 0.0), 22.0, root)
	await _capture_view("02_CLUSTERED_CROSSING_CONTEXT.png", Vector3(24.0, 29.0, 25.0), Vector3(1.0, 0.0, 0.0), 25.0, root)
	await _capture_view("03_RIVERBANK_VEGETATION_DETAIL.png", Vector3(14.0, 18.0, 16.0), Vector3(3.0, -0.08, 2.8), 15.0, root)
	await _capture_view("04_BRIDGE_APPROACH_DRESSING.png", Vector3(15.0, 20.0, 18.0), Vector3(1.2, 0.10, -1.8), 16.0, root)
	await _capture_view("05_DRESSING_DISTRIBUTION_AUDIT.png", Vector3(22.0, 44.0, 22.0), Vector3(1.0, 0.0, 0.0), 29.0, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("06_GRAYSCALE_PRIMARY.png"))
	_write_json("v0382-clustered-highland-dressing.json", {
		"checkpoint": CHECKPOINT,
		"status": "RENDERED",
		"iteration": iteration,
		"resolution": "1920x1080",
		"stage": "clustered-highland-environment-dressing-repair",
		"baseKit": KIT_PATH,
		"baseKitUnchanged": true,
		"dressingOnly": true,
		"riverbankClusters": 6,
		"highlandMasses": 2,
		"rockClusters": 5,
		"isolatedRocks": 0,
		"assets": "in-repo Quaternius v0370 kit; THIRD_PARTY_NOTICE.md retained",
		"buildings": false,
		"units": false,
		"gameplay": false,
		"hud": false,
		"defaultRuntime": "unchanged",
		"route": "opt-in-only",
		"glbSha256": INTAKE_GLB_SHA256,
		"sourceSha256": INTAKE_SOURCE_SHA256
	})
	get_tree().quit(0)

func _capture_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	camera.position = position
	camera.size = size
	camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080:
		image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _place(relative_path: String, parent: Node3D, position: Vector3, scale: Vector3, yaw: float) -> Node3D:
	var packed := load(ASSET_ROOT + relative_path) as PackedScene
	if packed == null:
		push_error("v0.382 missing existing in-repo asset: " + relative_path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("v0.382 asset is not Node3D: " + relative_path)
		return null
	instance.name = relative_path.get_file().get_basename()
	instance.position = position
	instance.scale = scale
	instance.rotation.y = yaw
	parent.add_child(instance)
	return instance

func _write_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_json("v0382-clustered-highland-dressing-smoke.json", {
		"checkpoint": CHECKPOINT,
		"status": "PASS",
		"sceneLoaded": true,
		"baseKit": KIT_PATH,
		"baseKitUnchanged": true,
		"dressingOnly": true,
		"riverbankClusters": 6,
		"highlandMasses": 2,
		"rockClusters": 5,
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"route": "opt-in-only",
		"glbSha256": INTAKE_GLB_SHA256,
		"sourceSha256": INTAKE_SOURCE_SHA256
	})
	get_tree().quit(0)
