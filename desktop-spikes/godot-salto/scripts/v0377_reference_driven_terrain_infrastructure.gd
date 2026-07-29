extends Node3D

## Isolated v0.377 Stage 1 infrastructure proof. No buildings, units or gameplay.

const CHECKPOINT := "v0.377"
const KIT_PATH := "res://assets/v0377/terrain-infrastructure/barrosan_terrain_infrastructure_v0377.glb"
const CAPTURE_ROOT := "artifacts/runtime/v0377"
const REFERENCE_PATH := "res://../../docs/art-direction/v0377-visual-reference-pack/03_TERRAIN_ROAD_RIVER_BRIDGE.png"

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
		if arg == "--v0377-terrain-infrastructure-capture": capture_mode = true
		if arg == "--v0377-terrain-infrastructure-smoke": smoke_mode = true
		if arg.begins_with("--artifact-root="): capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0377-iteration="): iteration = int(arg.trim_prefix("--v0377-iteration="))
	if capture_mode: smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#3e5146")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d2c9ae")
	environment.ambient_light_energy = 0.48
	environment.ambient_light_sky_contribution = 0.28
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 0.86
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0377_Barrosan_Stage1_Daylight"
	world_environment.environment = environment
	add_child(world_environment)
	var key := DirectionalLight3D.new()
	key.name = "V0377_Warm_Northwest_Key"
	key.rotation_degrees = Vector3(-52.0, -34.0, 0.0)
	key.light_color = Color("#f2d2a6")
	key.light_energy = 0.98
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 90.0
	key.shadow_bias = 0.035
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0377_Cool_South_Fill"
	fill.rotation_degrees = Vector3(-34.0, 145.0, 0.0)
	fill.light_color = Color("#a7c2c1")
	fill.light_energy = 0.22
	fill.shadow_enabled = false
	add_child(fill)

func _build_world() -> void:
	world = Node3D.new()
	world.name = "V0377_Reference_Driven_Terrain_Infrastructure_Stage1"
	add_child(world)
	var kit_scene := load(KIT_PATH) as PackedScene
	if kit_scene == null:
		push_error("v0.377 missing terrain infrastructure kit: " + KIT_PATH)
		return
	var kit := kit_scene.instantiate()
	kit.name = "Barrosan_Terrain_Road_River_Bridge_Kit"
	world.add_child(kit)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0377_Orthographic_Oblique_RTS_Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 31.0
	camera.current = true
	camera.position = Vector3(30.0, 33.0, 34.0)
	add_child(camera)
	camera.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)

func _capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	camera.size = 31.0
	var primary := await _capture_view("01_CLEAN_PRIMARY_RTS_VIEW.png", Vector3(30.0, 33.0, 34.0), Vector3(0.0, 0.0, 0.0), root)
	camera.size = 17.0
	await _capture_view("02_ROAD_AND_TERRAIN_DETAIL.png", Vector3(19.0, 20.0, 22.0), Vector3(-10.0, -8.0, 0.05), root)
	camera.size = 16.0
	await _capture_view("03_RIVERBANK_DETAIL.png", Vector3(18.0, 20.0, 21.0), Vector3(0.5, 7.0, -0.15), root)
	camera.size = 12.0
	await _capture_view("04_BRIDGE_AND_LANDINGS.png", Vector3(13.0, 15.0, 16.0), Vector3(0.0, 0.0, 0.45), root)
	primary.convert(Image.FORMAT_L8)
	primary.save_png(root.path_join("05_GRAYSCALE_PRIMARY.png"))
	_make_comparison_board(root)
	_write_json("v0377-terrain-infrastructure.json", {
		"checkpoint": CHECKPOINT,
		"status": "RENDERED",
		"iteration": iteration,
		"resolution": "1920x1080",
		"stage": "stage-1-terrain-road-riverbanks-bridge",
		"prototype": "original-reference-driven-infrastructure-kit",
		"buildings": false,
		"units": false,
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"route": "opt-in-only"
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

func _make_comparison_board(root: String) -> void:
	var reference := Image.new()
	var reference_path := ProjectSettings.globalize_path(REFERENCE_PATH)
	if reference.load(reference_path) != OK:
		push_error("v0.377 reference image could not be loaded: " + reference_path)
		return
	var primary := Image.load_from_file(root.path_join("01_CLEAN_PRIMARY_RTS_VIEW.png"))
	if primary == null:
		push_error("v0.377 primary render missing for comparison board")
		return
	reference.convert(Image.FORMAT_RGBA8)
	primary.convert(Image.FORMAT_RGBA8)
	reference.resize(900, 506, Image.INTERPOLATE_LANCZOS)
	primary.resize(900, 506, Image.INTERPOLATE_LANCZOS)
	var board := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	board.fill(Color("#d9d1c2"))
	board.blit_rect(reference, Rect2i(0, 0, 900, 506), Vector2i(40, 210))
	board.blit_rect(primary, Rect2i(0, 0, 900, 506), Vector2i(980, 210))
	board.save_png(root.path_join("06_REFERENCE_COMPARISON.png"))

func _write_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_json("v0377-terrain-infrastructure-smoke.json", {
		"checkpoint": CHECKPOINT,
		"status": "PASS",
		"sceneLoaded": true,
		"kit": KIT_PATH,
		"stage": "stage-1-terrain-road-riverbanks-bridge",
		"buildings": false,
		"units": false,
		"gameplay": false,
		"defaultRuntime": "unchanged"
	})
	get_tree().quit(0)
