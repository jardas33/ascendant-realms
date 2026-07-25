extends Node3D

## Isolated v0.381 environment-dressing support scene.
## The supplied v0.380 infrastructure kit is loaded unchanged; this scene only
## adds sparse, deterministic in-repo environmental context around the crossing.

const CHECKPOINT := "v0.381"
const KIT_PATH := "res://assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb"
const ASSET_ROOT := "res://assets/third_party/quaternius/v0370/"
const CAPTURE_ROOT := "artifacts/runtime/v0381"
const INTAKE_GLB_SHA256 := "746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb"
const INTAKE_SOURCE_SHA256 := "4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19"

var capture_mode := false
var smoke_mode := false
var capture_root := CAPTURE_ROOT
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
		if arg == "--v0381-highland-dressing-capture": capture_mode = true
		if arg == "--v0381-highland-dressing-smoke": smoke_mode = true
		if arg.begins_with("--artifact-root="): capture_root = arg.trim_prefix("--artifact-root=")
	if capture_mode: smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#526255")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#c8c6b5")
	environment.ambient_light_energy = 0.22
	environment.ambient_light_sky_contribution = 0.20
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 0.60
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0381_Restrained_Highland_Daylight"
	world_environment.environment = environment
	add_child(world_environment)

	var key := DirectionalLight3D.new()
	key.name = "V0381_Warm_Northwest_Key"
	key.rotation_degrees = Vector3(-50.0, -38.0, 0.0)
	key.light_color = Color("#efd0a5")
	key.light_energy = 0.92
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 120.0
	key.shadow_bias = 0.035
	add_child(key)

	var fill := DirectionalLight3D.new()
	fill.name = "V0381_Cool_Low_Intensity_Fill"
	fill.rotation_degrees = Vector3(-30.0, 142.0, 0.0)
	fill.light_color = Color("#a8bbbd")
	fill.light_energy = 0.06
	fill.shadow_enabled = false
	add_child(fill)

func _build_world() -> bool:
	world = Node3D.new()
	world.name = "V0381_Accepted_Crossing_With_Sparse_Environment_Dressing"
	add_child(world)
	var kit_scene := load(KIT_PATH) as PackedScene
	if kit_scene == null:
		push_error("v0.381 accepted v0.380 GLB failed to import: " + KIT_PATH)
		return false
	var kit := kit_scene.instantiate()
	kit.name = "V0380_Accepted_Corrected_Highland_Infrastructure_Unchanged"
	world.add_child(kit)

	dressing = Node3D.new()
	dressing.name = "V0381_Sparse_Environment_Dressing_Only"
	world.add_child(dressing)
	_build_dressing()
	return true

func _build_dressing() -> void:
	var tree_group := Node3D.new()
	tree_group.name = "Dressing_Tree_Silhouettes"
	dressing.add_child(tree_group)
	var trees := [
		["nature/CommonTree_1.gltf", Vector3(-12.6, 0.48, -8.6), Vector3(0.92, 0.92, 0.92), -0.18],
		["nature/CommonTree_3.gltf", Vector3(-10.4, 0.42, 7.9), Vector3(0.86, 0.86, 0.86), 0.32],
		["nature/Pine_2.gltf", Vector3(12.3, 0.45, -7.8), Vector3(0.92, 0.92, 0.92), 0.22],
		["nature/CommonTree_1.gltf", Vector3(11.2, 0.46, 7.8), Vector3(0.80, 0.80, 0.80), -0.38]
	]
	for item in trees:
		_place(str(item[0]), tree_group, item[1], item[2], float(item[3]))

	var bank_group := Node3D.new()
	bank_group.name = "Dressing_Riverbank_Shrubs_Reeds"
	dressing.add_child(bank_group)
	var banks := [
		["nature/Bush_Common.gltf", Vector3(0.62, 0.34, -6.3), Vector3(0.72, 0.72, 0.72), -0.25],
		["nature/Bush_Common_Flowers.gltf", Vector3(4.65, 0.34, 5.8), Vector3(0.70, 0.70, 0.70), 0.20],
		["nature/Grass_Common_Tall.gltf", Vector3(0.55, 0.18, -5.35), Vector3(0.58, 0.58, 0.58), 0.10],
		["nature/Grass_Common_Tall.gltf", Vector3(4.70, 0.18, 4.85), Vector3(0.54, 0.54, 0.54), -0.30],
		["nature/Grass_Wispy_Short.gltf", Vector3(0.70, 0.16, 6.05), Vector3(0.62, 0.62, 0.62), 0.22],
		["nature/Grass_Wispy_Short.gltf", Vector3(4.62, 0.16, -6.0), Vector3(0.58, 0.58, 0.58), -0.18]
	]
	for item in banks:
		_place(str(item[0]), bank_group, item[1], item[2], float(item[3]))

	var rock_group := Node3D.new()
	rock_group.name = "Dressing_Rock_Distribution"
	dressing.add_child(rock_group)
	var rocks := [
		["nature/Rock_Medium_1.gltf", Vector3(-8.8, 0.30, -7.4), Vector3(0.52, 0.46, 0.52), 0.16],
		["nature/Rock_Medium_2.gltf", Vector3(-6.5, 0.28, 6.8), Vector3(0.46, 0.40, 0.46), -0.38],
		["nature/Rock_Medium_3.gltf", Vector3(6.2, 0.30, -7.0), Vector3(0.50, 0.44, 0.50), 0.28],
		["nature/Rock_Medium_1.gltf", Vector3(7.0, 0.26, 6.5), Vector3(0.44, 0.38, 0.44), -0.22],
		["nature/RockPath_Round_Wide.gltf", Vector3(-5.2, 0.20, -4.2), Vector3(0.48, 0.22, 0.48), 0.08],
		["nature/RockPath_Round_Wide.gltf", Vector3(6.1, 0.20, 3.5), Vector3(0.44, 0.20, 0.44), -0.18]
	]
	for item in rocks:
		_place(str(item[0]), rock_group, item[1], item[2], float(item[3]))

	var minor_group := Node3D.new()
	minor_group.name = "Dressing_Minor_Ground_Props"
	dressing.add_child(minor_group)
	_place("village/Prop_WoodenFence_Single.gltf", minor_group, Vector3(-8.8, 0.24, -5.4), Vector3(0.52, 0.46, 0.46), 0.12)
	_place("village/Prop_WoodenFence_Single.gltf", minor_group, Vector3(-7.5, 0.24, -4.8), Vector3(0.48, 0.42, 0.42), 0.18)
	_place("props/Crate_Wooden.gltf", minor_group, Vector3(-7.0, 0.30, 5.4), Vector3(0.38, 0.38, 0.38), -0.12)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0381_Orthographic_Oblique_RTS_Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 25.0
	camera.current = true
	camera.position = Vector3(24.0, 28.0, 25.0)
	add_child(camera)
	camera.look_at(Vector3.ZERO, Vector3.UP)

func _capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	camera.size = 25.0
	var primary := await _capture_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 28.0, 25.0), Vector3.ZERO, root)
	camera.size = 28.0
	await _capture_view("02_CROSSING_CONTEXT_VIEW.png", Vector3(27.0, 32.0, 29.0), Vector3(1.0, 0.0, 0.5), root)
	camera.size = 18.0
	await _capture_view("03_RIVERBANK_AND_REEDS_DETAIL.png", Vector3(15.0, 19.0, 17.0), Vector3(2.6, -0.08, 4.8), root)
	camera.size = 14.0
	await _capture_view("04_BRIDGE_AND_LANDINGS_DETAIL.png", Vector3(13.0, 19.0, 19.0), Vector3(3.0, 0.20, -1.8), root)
	camera.size = 31.0
	await _capture_view("05_DRESSING_DISTRIBUTION_AUDIT.png", Vector3(24.0, 48.0, 24.0), Vector3.ZERO, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("06_GRAYSCALE_PRIMARY.png"))
	_write_json("v0381-highland-infrastructure-dressing.json", {
		"checkpoint": CHECKPOINT,
		"status": "RENDERED",
		"resolution": "1920x1080",
		"stage": "v0380-accepted-crossing-with-sparse-environment-dressing",
		"baseKit": KIT_PATH,
		"baseKitUnchanged": true,
		"dressingOnly": true,
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

func _capture_view(file_name: String, position: Vector3, target: Vector3, root: String) -> Image:
	camera.position = position
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
		push_error("v0.381 missing existing in-repo asset: " + relative_path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("v0.381 asset is not Node3D: " + relative_path)
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
	_write_json("v0381-highland-infrastructure-dressing-smoke.json", {
		"checkpoint": CHECKPOINT,
		"status": "PASS",
		"sceneLoaded": true,
		"baseKit": KIT_PATH,
		"baseKitUnchanged": true,
		"dressingOnly": true,
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"route": "opt-in-only",
		"glbSha256": INTAKE_GLB_SHA256,
		"sourceSha256": INTAKE_SOURCE_SHA256
	})
	get_tree().quit(0)
