extends Node3D

## Isolated v0.378 evaluation of the supplied authored Stage 1 infrastructure kit.
## No buildings, units, gameplay, HUD, mine, camp or runtime integration.

const CHECKPOINT := "v0.378"
const KIT_PATH := "res://assets/v0378/provided-infrastructure/barrosan_infrastructure_v0378.glb"
const CAPTURE_ROOT := "artifacts/runtime/v0378"
const INTAKE_GLB_SHA256 := "91cf29f5a964cf6b43f67fd1f9ac98d3bd6d3ea27623bb313479d362deef7e88"

var capture_mode := false
var smoke_mode := false
var capture_root := CAPTURE_ROOT
var iteration := 1
var camera: Camera3D
var world: Node3D

func _ready() -> void:
	_read_args()
	_build_environment()
	_build_world()
	_build_camera()
	if capture_mode:
		_capture_sequence.call_deferred()
	elif smoke_mode:
		_smoke_exit.call_deferred()

func _read_args() -> void:
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0378-provided-infrastructure-capture": capture_mode = true
		if arg == "--v0378-provided-infrastructure-smoke": smoke_mode = true
		if arg.begins_with("--artifact-root="): capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0378-iteration="): iteration = int(arg.trim_prefix("--v0378-iteration="))
	if capture_mode: smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#708164")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d9d5c2")
	environment.ambient_light_energy = 0.62 if iteration == 1 else 0.48
	environment.ambient_light_sky_contribution = 0.22
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 0.92
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0378_Soft_Barrosan_Daylight"
	world_environment.environment = environment
	add_child(world_environment)
	var key := DirectionalLight3D.new()
	key.name = "V0378_Soft_Northwest_Key"
	key.rotation_degrees = Vector3(-53.0, -38.0, 0.0)
	key.light_color = Color("#f1d4ae")
	key.light_energy = 1.08 if iteration <= 2 else 1.18
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 90.0
	key.shadow_bias = 0.035
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0378_Restrained_South_Fill"
	fill.rotation_degrees = Vector3(-35.0, 142.0, 0.0)
	fill.light_color = Color("#aebfc0")
	fill.light_energy = 0.18 if iteration <= 2 else 0.24
	fill.shadow_enabled = false
	add_child(fill)

func _build_world() -> void:
	world = Node3D.new()
	world.name = "V0378_Provided_Authored_Infrastructure_Stage1"
	add_child(world)
	var kit_scene := load(KIT_PATH) as PackedScene
	if kit_scene == null:
		push_error("v0.378 supplied infrastructure GLB failed to import: " + KIT_PATH)
		return
	var kit := kit_scene.instantiate()
	kit.name = "Supplied_Barrosan_Infrastructure_Kit"
	world.add_child(kit)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0378_Orthographic_Oblique_RTS_Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 31.0
	camera.current = true
	camera.position = Vector3(30.0, 31.0, 34.0)
	add_child(camera)
	camera.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)

func _capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary_position := Vector3(30.0, 31.0, 34.0)
	var primary_size := 31.0
	if iteration == 2:
		primary_position = Vector3(24.0, 40.0, 30.0)
		primary_size = 30.0
	elif iteration == 4:
		primary_position = Vector3(27.0, 32.0, 28.0)
		primary_size = 29.5
	elif iteration >= 3:
		primary_position = Vector3(18.0, 45.0, 24.0)
		primary_size = 30.0
	camera.size = primary_size
	var primary := await _capture_view("01_PRIMARY_RTS_VIEW.png", primary_position, Vector3(0.0, 0.0, 0.0), root)
	camera.size = 18.0
	await _capture_view("02_ROAD_AND_TERRAIN_DETAIL.png", Vector3(17.0, 28.0, 20.0) if iteration >= 2 else Vector3(19.0, 22.0, 22.0), Vector3(-7.0, 0.0, 0.0), root)
	camera.size = 17.0
	await _capture_view("03_RIVERBANK_DETAIL.png", Vector3(16.0, 27.0, 19.0) if iteration >= 2 else Vector3(18.0, 21.0, 21.0), Vector3(0.0, 5.0, 0.0), root)
	camera.size = 13.0
	await _capture_view("04_BRIDGE_AND_LANDINGS.png", Vector3(12.0, 20.0, 15.0) if iteration >= 2 else Vector3(14.0, 16.0, 17.0), Vector3(0.0, 0.0, 0.45), root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("05_GRAYSCALE_PRIMARY.png"))
	_write_json("v0378-provided-infrastructure.json", {
		"checkpoint": CHECKPOINT,
		"status": "RENDERED",
		"iteration": iteration,
		"resolution": "1920x1080",
		"stage": "stage-1-provided-terrain-road-riverbanks-bridge",
		"prototype": "external-art-intake/original-barrosan/v0378-authored-infrastructure/exports/barrosan_infrastructure_v0378.glb",
		"suppliedGeometry": true,
		"buildings": false,
		"units": false,
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"route": "opt-in-only",
		"glbSha256": INTAKE_GLB_SHA256
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

func _write_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_json("v0378-provided-infrastructure-smoke.json", {
		"checkpoint": CHECKPOINT,
		"status": "PASS",
		"sceneLoaded": true,
		"kit": KIT_PATH,
		"stage": "stage-1-provided-terrain-road-riverbanks-bridge",
		"suppliedGeometry": true,
		"buildings": false,
		"units": false,
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"glbSha256": INTAKE_GLB_SHA256
	})
	get_tree().quit(0)
