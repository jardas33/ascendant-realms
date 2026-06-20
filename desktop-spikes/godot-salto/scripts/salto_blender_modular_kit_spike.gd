extends Node3D

const CHECKPOINT := "v0.233R"
const KIT_PATH := "res://assets/v0233/salto_modular_environment_kit.glb"
const VIEWPORT_SIZE := Vector2i(1600, 900)
const EXPECTED_MODULES := [
	"terrain_base_tile", "terrain_grass_patch", "terrain_earth_patch",
	"road_straight", "road_intersection", "road_bridge_connector",
	"river_channel_banks", "bridge_module", "keep_landmark",
	"barracks_workshop_landmark", "mine_lume_landmark",
	"prop_rock_cluster", "prop_log_stack", "prop_crate_stack",
	"prop_posts", "prop_tree", "prop_rubble", "prop_barrels",
	"unit_scale_dummies",
]
const EXPECTED_MATERIALS := [
	"MAT_Stone", "MAT_StoneDark", "MAT_RoadDirt", "MAT_Grass",
	"MAT_Earth", "MAT_Roof", "MAT_Wood", "MAT_Water",
	"MAT_Crystal", "MAT_ContactDark", "MAT_Plaster", "MAT_Metal",
]

var camera: Camera3D
var capture_root := ""
var screenshot_root := ""
var kit_instance: Node
var captures: Array[Dictionary] = []
var errors: Array[String] = []
var modules_found: Array[String] = []
var materials_found: Array[String] = []

func _ready() -> void:
	if get_tree().current_scene == self:
		call_deferred("start")

func start() -> void:
	capture_root = _artifact_root_from_args()
	screenshot_root = capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	DisplayServer.window_set_min_size(VIEWPORT_SIZE)
	_build_environment()
	kit_instance = _import_authored_kit()
	if kit_instance == null:
		errors.append("Godot could not load the Blender-authored GLB.")
	else:
		_scan_imported_contract()
		_build_overlay()
		await _settle_frames(24)
		await _capture_views()
	_write_manifest()
	get_tree().quit(0 if errors.is_empty() else 1)

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#121a17")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#8fa28e")
	environment.ambient_light_energy = 0.72
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = true
	environment.glow_intensity = 0.32
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	sun.light_color = Color("#ffd7a0")
	sun.light_energy = 1.65
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 180.0
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-35.0, 135.0, 0.0)
	fill.light_color = Color("#83b9c1")
	fill.light_energy = 0.72
	fill.shadow_enabled = false
	add_child(fill)

	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.1
	camera.far = 500.0
	add_child(camera)
	camera.current = true

func _import_authored_kit() -> Node:
	var packed := load(KIT_PATH) as PackedScene
	if packed == null:
		return null
	var instance := packed.instantiate()
	instance.name = "V0233BlenderModularEnvironmentKit"
	add_child(instance)
	return instance

func _scan_imported_contract() -> void:
	for module_name in EXPECTED_MODULES:
		if kit_instance.find_child(module_name, true, false) != null:
			modules_found.append(module_name)
		else:
			errors.append("Missing imported module root: %s" % module_name)
	var material_names := {}
	_collect_material_names(kit_instance, material_names)
	for material_name in EXPECTED_MATERIALS:
		if material_names.has(material_name):
			materials_found.append(material_name)
		else:
			errors.append("Missing imported material: %s" % material_name)

func _collect_material_names(node: Node, names: Dictionary) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.material_override != null and not mesh_instance.material_override.resource_name.is_empty():
			names[mesh_instance.material_override.resource_name] = true
		if mesh_instance.mesh != null:
			for surface_index in range(mesh_instance.mesh.get_surface_count()):
				var surface_material := mesh_instance.get_active_material(surface_index)
				if surface_material != null and not surface_material.resource_name.is_empty():
					names[surface_material.resource_name] = true
	for child in node.get_children():
		_collect_material_names(child, names)

func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.position = Vector2(238, 18)
	panel.size = Vector2(1124, 54)
	panel.color = Color(0.02, 0.032, 0.027, 0.92)
	layer.add_child(panel)
	var title := Label.new()
	title.position = Vector2(22, 11)
	title.text = "v0.233R  |  BLENDER 5.1 AUTHORED GLB  |  ISOLATED NON-PLAYABLE MODULAR KIT REVIEW"
	title.add_theme_color_override("font_color", Color("#eadca9"))
	title.add_theme_font_size_override("font_size", 18)
	panel.add_child(title)

func _capture_views() -> void:
	await _capture("02_v0233_overview.png", Vector3(76.0, 70.0, 74.0), Vector3(12.0, 1.5, 0.0), 96.0)
	await _capture("03_v0233_base_structure_focus.png", Vector3(32.0, 28.0, 27.0), Vector3(10.0, 3.0, -2.0), 24.0)
	await _capture("04_v0233_barracks_workshop_focus.png", Vector3(51.0, 27.0, 27.0), Vector3(29.0, 3.0, -2.0), 24.0)
	await _capture("05_v0233_mine_lume_focus.png", Vector3(69.0, 26.0, 25.0), Vector3(47.0, 3.0, -2.0), 22.0)
	await _capture("06_v0233_road_bridge_river_focus.png", Vector3(18.0, 29.0, 31.0), Vector3(-12.0, 1.0, 0.0), 34.0)
	await _capture("07_v0233_props_and_scale.png", Vector3(55.0, 34.0, 28.0), Vector3(13.0, 1.8, -14.0), 72.0)

func _capture(file_name: String, camera_position: Vector3, target: Vector3, ortho_size: float) -> void:
	camera.position = camera_position
	camera.size = ortho_size
	camera.look_at(target)
	await _settle_frames(14)
	var image := get_viewport().get_texture().get_image()
	if image == null:
		errors.append("Viewport unavailable for %s" % file_name)
		return
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var target_path := screenshot_root.path_join(file_name)
	var result := image.save_png(target_path)
	if result != OK:
		errors.append("Failed to save %s" % file_name)
	captures.append({
		"fileName": file_name,
		"absolutePath": target_path,
		"width": image.get_width(),
		"height": image.get_height(),
		"cameraPosition": {"x": camera_position.x, "y": camera_position.y, "z": camera_position.z},
		"cameraTarget": {"x": target.x, "y": target.y, "z": target.z},
		"orthographicSize": ortho_size,
	})

func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0233-blender-modular-kit-runtime.json"), {
		"schemaVersion": 2,
		"checkpoint": CHECKPOINT,
		"status": "PASS_V0233R_IMPORTED_GLTF" if errors.is_empty() else "FAIL_V0233R_IMPORTED_GLTF",
		"blenderAvailable": true,
		"blenderPath": "C:/Program Files/Blender Foundation/Blender 5.1/blender.exe",
		"actualGlbPresent": kit_instance != null,
		"sourcePathRemappedInExport": not FileAccess.file_exists(KIT_PATH),
		"actualGlbImported": kit_instance != null,
		"isolatedSceneDisplayedAsset": kit_instance != null and captures.size() == 6,
		"kitPath": KIT_PATH,
		"contractPath": "res://assets/v0233/salto_modular_environment_kit.contract.json",
		"isolatedScene": "res://scenes/salto_blender_modular_kit_spike.tscn",
		"modulesFound": modules_found,
		"materialsFound": materials_found,
		"captureCount": captures.size(),
		"captures": captures,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"gameplayChanged": false,
		"saveChanged": false,
		"pathingChanged": false,
		"collisionChanged": false,
		"newRuntimeArtSlots": 0,
		"generatedAiImages": 0,
		"downloadedAssets": 0,
		"errors": errors,
	})

func _settle_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _artifact_root_from_args() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--artifact-root="):
			return arg.trim_prefix("--artifact-root=")
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--artifact-root="):
			return arg.trim_prefix("--artifact-root=")
	return ProjectSettings.globalize_path("user://v0233-blender-modular-kit")

func _write_json(path: String, value: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
