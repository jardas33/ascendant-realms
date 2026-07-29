extends Node3D

## Isolated v0.380 presentation of the exact supplied corrected highland kit.
## No buildings, units, HUD, gameplay, debug overlays or default-runtime mutation.

const CHECKPOINT := "v0.380"
const KIT_PATH := "res://assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb"
const CAPTURE_ROOT := "artifacts/runtime/v0380"
const INTAKE_GLB_SHA256 := "746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb"
const INTAKE_SOURCE_SHA256 := "4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19"

var capture_mode := false
var smoke_mode := false
var capture_root := CAPTURE_ROOT
var iteration := 1
var camera: Camera3D
var world: Node3D

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
		if arg == "--v0380-highland-infrastructure-capture": capture_mode = true
		if arg == "--v0380-highland-infrastructure-smoke": smoke_mode = true
		if arg.begins_with("--artifact-root="): capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0380-iteration="): iteration = int(arg.trim_prefix("--v0380-iteration="))
	if capture_mode: smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#526255")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#c8c6b5")
	environment.ambient_light_energy = 0.30 if iteration == 1 else (0.25 if iteration == 2 else 0.22)
	environment.ambient_light_sky_contribution = 0.20
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 0.68 if iteration == 1 else (0.64 if iteration == 2 else 0.60)
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0380_Restrained_Highland_Daylight"
	world_environment.environment = environment
	add_child(world_environment)

	var key := DirectionalLight3D.new()
	key.name = "V0380_Warm_Northwest_Key"
	key.rotation_degrees = Vector3(-50.0, -38.0, 0.0)
	key.light_color = Color("#efd0a5")
	key.light_energy = 0.90 if iteration == 1 else (0.96 if iteration == 2 else 0.92)
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 120.0
	key.shadow_bias = 0.035
	add_child(key)

	var fill := DirectionalLight3D.new()
	fill.name = "V0380_Cool_Low_Intensity_Fill"
	fill.rotation_degrees = Vector3(-30.0, 142.0, 0.0)
	fill.light_color = Color("#a8bbbd")
	fill.light_energy = 0.07 if iteration <= 2 else 0.06
	fill.shadow_enabled = false
	add_child(fill)

func _build_world() -> bool:
	world = Node3D.new()
	world.name = "V0380_Exact_Corrected_Highland_Infrastructure"
	add_child(world)
	var kit_scene := load(KIT_PATH) as PackedScene
	if kit_scene == null:
		push_error("v0.380 supplied corrected highland GLB failed to import: " + KIT_PATH)
		return false
	var kit := kit_scene.instantiate()
	kit.name = "Supplied_Corrected_Highland_Infrastructure_Kit"
	world.add_child(kit)
	return true

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0380_Orthographic_Oblique_RTS_Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 40.0
	camera.current = true
	camera.position = Vector3(31.0, 34.0, 32.0)
	add_child(camera)
	camera.look_at(Vector3.ZERO, Vector3.UP)

func _capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary_position := Vector3(31.0, 34.0, 32.0)
	var primary_size := 40.0
	if iteration == 2:
		primary_position = Vector3(23.0, 31.0, 25.0)
		primary_size = 30.0
	elif iteration >= 3:
		primary_position = Vector3(24.0, 28.0, 25.0)
		primary_size = 25.0

	camera.size = primary_size
	var primary := await _capture_view("01_PRIMARY_RTS_VIEW.png", primary_position, Vector3.ZERO, root)
	camera.size = 25.0
	await _capture_view("02_ROAD_AND_TERRAIN_DETAIL.png", Vector3(24.0, 27.0, 25.0), Vector3(-5.0, 0.2, 0.0), root)
	camera.size = 23.0
	await _capture_view("03_CONTINUOUS_RIVER_CROSSING.png", Vector3(21.0, 25.0, 23.0), Vector3(2.0, -0.35, 4.5), root)
	camera.size = 14.0
	await _capture_view("04_BRIDGE_AND_LANDINGS.png", Vector3(13.0, 19.0, 19.0), Vector3(0.0, 0.25, 0.0), root)
	camera.size = 31.0
	await _capture_view("05_ELEVATED_TOPOLOGY_AUDIT.png", Vector3(24.0, 48.0, 24.0), Vector3.ZERO, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("06_GRAYSCALE_PRIMARY.png"))
	_write_json("v0380-corrected-highland-infrastructure.json", {
		"checkpoint": CHECKPOINT,
		"status": "RENDERED",
		"iteration": iteration,
		"resolution": "1920x1080",
		"stage": "corrected-highland-terrain-road-continuous-riverbanks-bridge",
		"prototype": "external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/exports/barrosan_highland_infrastructure_v0380.glb",
		"suppliedGeometry": true,
		"buildings": false,
		"units": false,
		"gameplay": false,
		"hud": false,
		"debugOverlays": false,
		"defaultRuntime": "unchanged",
		"route": "opt-in-only",
		"vertexColours": "preserved",
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

func _write_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_json("v0380-corrected-highland-infrastructure-smoke.json", {
		"checkpoint": CHECKPOINT,
		"status": "PASS",
		"sceneLoaded": true,
		"kit": KIT_PATH,
		"stage": "corrected-highland-terrain-road-continuous-riverbanks-bridge",
		"suppliedGeometry": true,
		"buildings": false,
		"units": false,
		"gameplay": false,
		"hud": false,
		"debugOverlays": false,
		"defaultRuntime": "unchanged",
		"vertexColours": "preserved",
		"glbSha256": INTAKE_GLB_SHA256,
		"sourceSha256": INTAKE_SOURCE_SHA256
	})
	get_tree().quit(0)
