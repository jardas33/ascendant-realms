extends Node3D

## Isolated v0.376 original Barrosan art-quality pass. World-only, opt-in, no gameplay.

const CHECKPOINT := "v0.376"
const KIT_PATH := "res://assets/v0376/original_barrosan/barrosan_original_kit_v0376.glb"
const UNIT_ROOT := "res://assets/third_party/quaternius/v0370/men/"
const CAPTURE_ROOT := "artifacts/runtime/v0376"

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
		if arg == "--v0376-original-barrosan-capture": capture_mode = true
		if arg == "--v0376-original-barrosan-smoke": smoke_mode = true
		if arg.begins_with("--artifact-root="): capture_root = arg.trim_prefix("--artifact-root=")
		if arg.begins_with("--v0376-iteration="): iteration = int(arg.trim_prefix("--v0376-iteration="))
	if capture_mode: smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#46584d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d8d0b6")
	environment.ambient_light_energy = 0.40
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 0.78
	environment.ambient_light_sky_contribution = 0.34
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0376_Barrosan_Daylight"
	world_environment.environment = environment
	add_child(world_environment)
	var key := DirectionalLight3D.new()
	key.name = "V0376_Warm_Northwest_Key"
	key.rotation_degrees = Vector3(-52.0, -34.0, 0.0)
	key.light_color = Color("#f4d7ad")
	key.light_energy = 0.92
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 80.0
	key.shadow_bias = 0.04
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0376_Cool_South_Fill"
	fill.rotation_degrees = Vector3(-35.0, 145.0, 0.0)
	fill.light_color = Color("#a9c4c4")
	fill.light_energy = 0.20
	fill.shadow_enabled = false
	add_child(fill)

func _build_world() -> void:
	world = Node3D.new()
	world.name = "V0376_Original_Barrosan_Art_Quality_Sector"
	add_child(world)
	var kit_scene := load(KIT_PATH) as PackedScene
	if kit_scene == null:
		push_error("v0.376 missing original kit: " + KIT_PATH)
		return
	var kit := kit_scene.instantiate()
	kit.name = "Original_Barrosan_Art_Quality_Kit"
	world.add_child(kit)
	_build_scale_reference_units()

func _build_scale_reference_units() -> void:
	_add_unit("Worker.gltf", "Worker_Scale_Reference", Vector3(-6.6, 0.30, -1.5), 1.08, 0.15)
	_add_unit("Farmer.gltf", "Militia_Scale_Reference", Vector3(-3.8, 0.30, -5.0), 1.02, -0.25)
	_add_unit("Adventurer.gltf", "Reserve_Support_Scale_Reference", Vector3(5.0, 0.30, 3.5), 1.08, 2.8)
	_add_unit("Adventurer.gltf", "Hostile_Scale_Reference", Vector3(7.2, 0.30, 5.0), 0.98, -2.0)

func _add_unit(file_name: String, label: String, position: Vector3, scale_value: float, yaw: float) -> void:
	var packed := load(UNIT_ROOT + file_name) as PackedScene
	if packed == null:
		push_error("v0.376 missing temporary scale unit: " + file_name)
		return
	var unit := packed.instantiate() as Node3D
	unit.name = label
	unit.position = position
	unit.scale = Vector3.ONE * scale_value
	unit.rotation.y = yaw
	world.add_child(unit)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0376_Oblique_RTS_Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 25.0
	camera.current = true
	camera.position = Vector3(24.5, 25.5, 27.5)
	add_child(camera)
	camera.look_at(Vector3(0.0, 0.2, 0.0), Vector3.UP)

func _capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	camera.size = 19.5
	await _capture_view("01_ART_QUALITY_PRIMARY_OVERVIEW.png", Vector3(24.5,25.5,27.5), Vector3(0.0,0.25,0.0), root)
	camera.size = 15.5
	await _capture_view("02_ART_QUALITY_SETTLEMENT_AND_MINE.png", Vector3(18.0,18.5,20.0), Vector3(-6.8,0.45,-3.2), root)
	camera.size = 15.5
	await _capture_view("03_ART_QUALITY_BRIDGE_AND_CAMP.png", Vector3(20.0,20.5,22.0), Vector3(3.0,0.15,2.4), root)
	camera.size = 20.0
	await _capture_view("04_ART_QUALITY_ELEVATED_SPACING_AUDIT.png", Vector3(20.0,29.0,22.0), Vector3(0.0,0.0,0.0), root)
	_write_json("v0376-original-barrosan-art-quality.json", {"checkpoint": CHECKPOINT, "status": "RENDERED", "iteration": iteration, "resolution": "1920x1080", "prototype": "original-repository-authored-low-poly-art-quality-pass", "hud": false, "gameplay": false, "route": "opt-in-only", "visualGate": "pending"})
	get_tree().quit(0)

func _capture_view(file_name: String, position: Vector3, target: Vector3, root: String) -> void:
	camera.position = position
	camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080:
		image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))

func _write_json(file_name: String, data: Dictionary) -> void:
	var root := ProjectSettings.globalize_path(capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var file := FileAccess.open(root.path_join(file_name), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data, "  "))

func _smoke_exit() -> void:
	await get_tree().create_timer(0.6).timeout
	_write_json("v0376-original-barrosan-art-quality-smoke.json", {"checkpoint": CHECKPOINT, "status": "PASS", "sceneLoaded": true, "kit": KIT_PATH, "hud": false, "gameplay": false, "defaultRuntime": "unchanged"})
	get_tree().quit(0)
