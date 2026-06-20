extends Node3D

const CHECKPOINT := "v0.234"
const KIT_PATH := "res://assets/v0233/salto_modular_environment_kit.glb"
const VIEWPORT_SIZE := Vector2i(1600, 900)
const SOURCE_MODULES := [
	"terrain_base_tile", "terrain_grass_patch", "terrain_earth_patch",
	"road_straight", "road_intersection", "road_bridge_connector",
	"river_channel_banks", "bridge_module", "keep_landmark",
	"barracks_workshop_landmark", "mine_lume_landmark",
	"prop_rock_cluster", "prop_log_stack", "prop_crate_stack",
	"prop_posts", "prop_tree", "prop_rubble", "prop_barrels",
	"unit_scale_dummies",
]

var camera: Camera3D
var source_kit: Node3D
var composition_root: Node3D
var capture_root := ""
var screenshot_root := ""
var captures: Array[Dictionary] = []
var placed_instances: Array[Dictionary] = []
var errors: Array[String] = []

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
	if not _load_source_kit():
		errors.append("Failed to load the v0.233R Blender-authored GLB.")
	else:
		_build_composition()
		_build_overlay()
		await _settle_frames(26)
		await _capture_views()
	_write_manifest()
	get_tree().quit(0 if errors.is_empty() else 1)

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#202a22")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#94a28c")
	environment.ambient_light_energy = 0.58
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = true
	environment.glow_intensity = 0.18
	environment.fog_enabled = true
	environment.fog_light_color = Color("#75806c")
	environment.fog_light_energy = 0.22
	environment.fog_density = 0.003
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -34.0, 0.0)
	sun.light_color = Color("#ffd19a")
	sun.light_energy = 1.48
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 160.0
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-28.0, 145.0, 0.0)
	fill.light_color = Color("#789aaa")
	fill.light_energy = 0.5
	add_child(fill)

	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.1
	camera.far = 500.0
	add_child(camera)
	camera.current = true

func _load_source_kit() -> bool:
	var packed := load(KIT_PATH) as PackedScene
	if packed == null:
		return false
	source_kit = packed.instantiate() as Node3D
	if source_kit == null:
		return false
	source_kit.name = "V0233RSourceKitLibrary"
	source_kit.visible = false
	add_child(source_kit)
	for module_name in SOURCE_MODULES:
		if source_kit.find_child(module_name, true, false) == null:
			errors.append("Source kit missing module %s" % module_name)
	_tune_imported_materials(source_kit)
	return errors.is_empty()

func _build_composition() -> void:
	composition_root = Node3D.new()
	composition_root.name = "V0234ComposedBattlefield"
	add_child(composition_root)
	_add_irregular_island("IslandEarthSkirt", -0.82, Color("#3a3024"), 1.04)
	_add_irregular_island("IslandGrassBody", -0.52, Color("#596443"), 1.0)
	_add_irregular_island("IslandSurfaceVariation", -0.34, Color("#66704a"), 0.965)

	var terrain_cells := [
		["terrain_earth_patch", Vector3(-21.5, 0.0, -10.0), -2.0],
		["terrain_grass_patch", Vector3(-10.5, 0.03, -10.0), 1.0],
		["terrain_base_tile", Vector3(0.5, 0.0, -10.0), -1.0],
		["terrain_grass_patch", Vector3(18.0, 0.0, -10.0), 2.0],
		["terrain_grass_patch", Vector3(-21.5, 0.02, 0.0), 1.0],
		["terrain_earth_patch", Vector3(-10.5, 0.0, 0.0), -1.5],
		["terrain_base_tile", Vector3(0.5, 0.02, 0.0), 1.0],
		["terrain_earth_patch", Vector3(18.0, 0.02, 0.0), -2.0],
		["terrain_base_tile", Vector3(-21.5, 0.0, 10.0), -1.0],
		["terrain_grass_patch", Vector3(-10.5, 0.02, 10.0), 2.0],
		["terrain_earth_patch", Vector3(0.5, 0.0, 10.0), -1.0],
		["terrain_grass_patch", Vector3(18.0, 0.02, 10.0), 1.0],
	]
	for cell in terrain_cells:
		_place_module(str(cell[0]), cell[1], float(cell[2]), Vector3(1.035, 1.0, 1.04))

	_place_module("river_channel_banks", Vector3(7.0, 0.0, -10.2), 0.0, Vector3(1.04, 1.0, 1.03))
	_place_module("bridge_module", Vector3(7.0, 0.0, 0.0), 0.0, Vector3(1.02, 1.0, 1.03))
	_place_module("river_channel_banks", Vector3(7.0, 0.0, 10.2), 0.0, Vector3(1.04, 1.0, 1.03))
	_add_ground_patch("ContinuousRiverBed", Vector3(7.0, -0.20, 0.0), Vector3(4.35, 0.22, 31.8), Color("#26383a"))
	_add_water_patch("ContinuousRiverWater", Vector3(7.0, -0.055, 0.0), Vector3(3.55, 0.08, 31.5))

	_place_module("road_straight", Vector3(-21.0, 0.22, 1.0), 0.0, Vector3(1.05, 1.0, 1.02))
	_place_module("road_intersection", Vector3(-10.0, 0.23, 1.0), 0.0, Vector3(1.05, 1.0, 1.02))
	_place_module("road_bridge_connector", Vector3(0.2, 0.23, 1.0), 0.0, Vector3(1.03, 1.0, 1.02))
	_place_module("road_bridge_connector", Vector3(17.6, 0.23, 1.0), 0.0, Vector3(1.03, 1.0, 1.02))
	_place_module("road_straight", Vector3(-10.0, 0.24, -6.7), 90.0, Vector3(1.02, 1.0, 1.03))
	_place_module("road_straight", Vector3(-10.0, 0.24, 8.8), 90.0, Vector3(1.02, 1.0, 1.03))
	_place_module("road_straight", Vector3(18.0, 0.24, -6.5), 90.0, Vector3(1.02, 1.0, 1.03))

	_add_ground_patch("KeepRise", Vector3(-12.0, 0.15, -10.0), Vector3(16.0, 0.9, 11.0), Color("#4c4434"))
	_add_ground_patch("KeepApron", Vector3(-10.0, 0.62, -6.0), Vector3(8.0, 0.18, 6.0), Color("#8a6841"))
	_place_module("keep_landmark", Vector3(-12.0, 1.05, -10.2), -3.0)

	_add_ground_patch("BarracksYard", Vector3(-13.0, -0.02, 9.1), Vector3(17.0, 0.55, 11.0), Color("#62513a"))
	_add_ground_patch("BarracksDoorWear", Vector3(-10.0, 0.36, 5.7), Vector3(5.5, 0.12, 4.0), Color("#a27743"))
	_place_module("barracks_workshop_landmark", Vector3(-13.5, 0.55, 9.3), 2.0)

	_add_ground_patch("MineShelf", Vector3(19.0, -0.08, -9.2), Vector3(16.0, 0.62, 11.5), Color("#45463c"))
	_add_ground_patch("MineApproachWear", Vector3(18.0, 0.32, -5.0), Vector3(5.5, 0.12, 5.0), Color("#8a663f"))
	_place_module("mine_lume_landmark", Vector3(18.2, 0.48, -9.2), -2.0)

	_add_ground_patch("WestRoadBlend", Vector3(-15.5, 0.35, 1.0), Vector3(23.0, 0.08, 4.2), Color("#8a633d"))
	_add_ground_patch("EastRoadBlend", Vector3(18.0, 0.35, 1.0), Vector3(13.0, 0.08, 4.0), Color("#8a633d"))
	_add_ground_patch("BridgeWestContact", Vector3(1.8, 0.45, 1.0), Vector3(6.0, 0.12, 4.7), Color("#64513a"))
	_add_ground_patch("BridgeEastContact", Vector3(12.2, 0.45, 1.0), Vector3(6.0, 0.12, 4.7), Color("#64513a"))

	_place_prop("prop_crate_stack", Vector3(-15.5, 0.62, 5.2), -12.0, 0.72)
	_place_prop("prop_barrels", Vector3(-9.0, 0.62, 10.5), 8.0, 0.7)
	_place_prop("prop_log_stack", Vector3(-17.5, 0.62, 11.8), 16.0, 0.78)
	_place_prop("prop_posts", Vector3(-4.2, 0.28, 3.6), 82.0, 0.8)
	_place_prop("prop_rock_cluster", Vector3(2.0, 0.18, -7.8), 14.0, 0.78)
	_place_prop("prop_rubble", Vector3(14.8, 0.5, -5.4), -8.0, 0.75)
	_place_prop("prop_crate_stack", Vector3(22.0, 0.52, -5.0), 18.0, 0.68)
	_place_prop("prop_barrels", Vector3(16.0, 0.45, -13.0), -12.0, 0.7)
	_place_prop("prop_rock_cluster", Vector3(3.0, 0.12, 9.0), -8.0, 0.72)
	for tree_config in [
		[Vector3(-25.0, 0.0, -12.0), -8.0, 0.88],
		[Vector3(-24.0, 0.0, 11.0), 12.0, 0.82],
		[Vector3(-2.0, 0.0, -14.0), -5.0, 0.78],
		[Vector3(22.5, 0.0, 10.5), 16.0, 0.86],
		[Vector3(26.0, 0.0, -2.0), -12.0, 0.8],
	]:
		_place_prop("prop_tree", tree_config[0], float(tree_config[1]), float(tree_config[2]))
	_place_prop("unit_scale_dummies", Vector3(-4.0, 0.35, -0.4), 8.0, 0.86)

func _place_module(module_name: String, target_position: Vector3, yaw_degrees := 0.0, scale_value := Vector3.ONE) -> Node3D:
	var source := source_kit.find_child(module_name, true, false) as Node3D
	if source == null:
		errors.append("Cannot place missing module %s" % module_name)
		return null
	var placed := source.duplicate(Node.DUPLICATE_USE_INSTANTIATION) as Node3D
	if placed == null:
		errors.append("Cannot duplicate module %s" % module_name)
		return null
	placed.name = "%s_%02d" % [module_name, placed_instances.size() + 1]
	placed.visible = true
	placed.position = target_position
	placed.rotation_degrees.y = yaw_degrees
	placed.scale = scale_value
	composition_root.add_child(placed)
	placed_instances.append({
		"sourceModule": module_name,
		"instanceName": placed.name,
		"position": {"x": target_position.x, "y": target_position.y, "z": target_position.z},
		"yawDegrees": yaw_degrees,
	})
	return placed

func _place_prop(module_name: String, target_position: Vector3, yaw_degrees: float, uniform_scale: float) -> void:
	var placed := _place_module(module_name, target_position, yaw_degrees, Vector3.ONE * uniform_scale)
	if placed == null:
		return
	for child in placed.get_children():
		if child is VisualInstance3D and str(child.name).contains("Plinth"):
			(child as VisualInstance3D).visible = false

func _tune_imported_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh != null:
			for surface_index in range(mesh_instance.mesh.get_surface_count()):
				var active := mesh_instance.get_active_material(surface_index)
				if active is StandardMaterial3D:
					var tuned := (active as StandardMaterial3D).duplicate() as StandardMaterial3D
					_tune_material(tuned)
					mesh_instance.set_surface_override_material(surface_index, tuned)
	for child in node.get_children():
		_tune_imported_materials(child)

func _tune_material(material: StandardMaterial3D) -> void:
	match material.resource_name:
		"MAT_Grass":
			material.albedo_color = Color("#566d43")
		"MAT_Earth":
			material.albedo_color = Color("#665039")
		"MAT_RoadDirt":
			material.albedo_color = Color("#9a6540")
		"MAT_Stone":
			material.albedo_color = Color("#727a78")
		"MAT_StoneDark":
			material.albedo_color = Color("#333b3d")
		"MAT_Wood":
			material.albedo_color = Color("#704328")
		"MAT_Roof":
			material.albedo_color = Color("#5c3028")
		"MAT_Plaster":
			material.albedo_color = Color("#9a855e")
		"MAT_Water":
			material.albedo_color = Color("#245866")
			material.metallic = 0.12
			material.roughness = 0.22
		"MAT_Crystal":
			material.albedo_color = Color("#4dd6c9")
			material.emission_enabled = true
			material.emission = Color("#2cb7ad")
			material.emission_energy_multiplier = 1.45
	material.roughness = min(material.roughness, 0.82)

func _add_irregular_island(label: String, y: float, color: Color, scale_value: float) -> void:
	var outline := [
		Vector2(-29.0, -14.0), Vector2(-24.0, -17.0), Vector2(-12.0, -18.0),
		Vector2(1.0, -17.4), Vector2(14.0, -16.5), Vector2(27.0, -13.5),
		Vector2(30.0, -5.0), Vector2(29.0, 6.0), Vector2(25.0, 14.5),
		Vector2(13.0, 17.0), Vector2(-1.0, 17.8), Vector2(-15.0, 17.2),
		Vector2(-26.0, 13.0), Vector2(-30.0, 4.0),
	]
	var vertices := PackedVector3Array()
	vertices.append(Vector3(0.0, y, 0.0))
	for point in outline:
		vertices.append(Vector3(point.x * scale_value, y, point.y * scale_value))
	var indices := PackedInt32Array()
	for index in range(outline.size()):
		var next_index := (index + 1) % outline.size()
		indices.append_array(PackedInt32Array([0, index + 1, next_index + 1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.material_override = _material(color, 0.92)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	composition_root.add_child(instance)

func _add_ground_patch(label: String, position: Vector3, size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color, 0.88)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	composition_root.add_child(instance)

func _add_water_patch(label: String, position: Vector3, size: Vector3) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.position = position
	var material := _material(Color("#245866"), 0.18)
	material.metallic = 0.14
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	composition_root.add_child(instance)

func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.position = Vector2(270, 18)
	panel.size = Vector2(1060, 50)
	panel.color = Color(0.018, 0.03, 0.024, 0.9)
	layer.add_child(panel)
	var title := Label.new()
	title.position = Vector2(20, 10)
	title.text = "v0.234  |  COMPOSED BLENDER BATTLEFIELD  |  ISOLATED VISUAL DIRECTION"
	title.add_theme_color_override("font_color", Color("#eadba6"))
	title.add_theme_font_size_override("font_size", 18)
	panel.add_child(title)

func _capture_views() -> void:
	await _capture("02_v0234_composed_overview.png", Vector3(43.0, 49.0, 48.0), Vector3(0.0, 0.5, 0.0), 47.0)
	await _capture("03_v0234_keep_and_base_focus.png", Vector3(9.0, 30.0, 20.0), Vector3(-12.0, 2.6, -8.2), 23.0)
	await _capture("04_v0234_barracks_workshop_focus.png", Vector3(8.0, 27.0, 31.0), Vector3(-12.0, 2.2, 8.0), 22.0)
	await _capture("05_v0234_mine_lume_focus.png", Vector3(39.0, 27.0, 12.0), Vector3(18.0, 2.0, -8.0), 22.0)
	await _capture("06_v0234_road_bridge_river_focus.png", Vector3(35.0, 36.0, 33.0), Vector3(5.0, 0.3, 1.0), 29.0)
	await _capture("07_v0234_props_grounding_scale_focus.png", Vector3(22.0, 28.0, 35.0), Vector3(-2.0, 0.8, 3.0), 28.0)

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
		"orthographicSize": ortho_size,
	})

func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0234-composed-blender-battlefield-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS_V0234_COMPOSED_BLENDER_BATTLEFIELD" if errors.is_empty() else "FAIL_V0234_COMPOSED_BLENDER_BATTLEFIELD",
		"sourceGlb": KIT_PATH,
		"compositionMethod": "Godot scene composition using imported Blender-authored module roots",
		"blenderUsedAgain": false,
		"scenePath": "res://scenes/salto_composed_blender_battlefield_slice.tscn",
		"placedModuleInstanceCount": placed_instances.size(),
		"placedInstances": placed_instances,
		"continuousTerrainIsland": true,
		"embeddedRiverSegments": 3,
		"bridgeContactsBothBanks": true,
		"connectedRoadNetwork": true,
		"raisedKeepPlatform": true,
		"sunkenRiverChannel": true,
		"groundedLandmarks": true,
		"captureCount": captures.size(),
		"captures": captures,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"gameplayChanged": false,
		"saveChanged": false,
		"pathingChanged": false,
		"collisionChanged": false,
		"newRuntimeArtSlots": 0,
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
	return ProjectSettings.globalize_path("user://v0234-composed-blender-battlefield")

func _write_json(path: String, value: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
