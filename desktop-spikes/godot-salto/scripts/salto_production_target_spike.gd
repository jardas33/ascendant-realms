extends Node3D

const CHECKPOINT := "v0.232"
const VIEWPORT_SIZE := Vector2i(1600, 900)

var camera: Camera3D
var capture_root := ""
var screenshot_root := ""
var captures: Array[Dictionary] = []
var errors: Array[String] = []

func start() -> void:
	capture_root = _artifact_root_from_args()
	screenshot_root = capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	DisplayServer.window_set_min_size(VIEWPORT_SIZE)
	_build_scene()
	await _settle_frames(20)
	await _capture_views()
	_write_manifest()
	get_tree().quit(0 if errors.is_empty() else 1)

func _build_scene() -> void:
	_build_environment()
	_build_terrain()
	_build_road_and_river()
	_build_bridge()
	_build_keep()
	_build_barracks()
	_build_mine()
	_build_units()
	_build_dressing()
	_build_overlay()

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#17211c")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#8fa287")
	environment.ambient_light_energy = 0.52
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = true
	environment.glow_intensity = 0.42
	environment.fog_enabled = true
	environment.fog_light_color = Color("#697961")
	environment.fog_light_energy = 0.36
	environment.fog_density = 0.009
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	sun.light_color = Color("#ffd9a0")
	sun.light_energy = 1.55
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)

	var cool_fill := OmniLight3D.new()
	cool_fill.position = Vector3(5.5, 8.0, 1.0)
	cool_fill.light_color = Color("#78b7c5")
	cool_fill.light_energy = 3.4
	cool_fill.omni_range = 20.0
	cool_fill.shadow_enabled = true
	add_child(cool_fill)

	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 38.5
	camera.position = Vector3(29.0, 31.0, 31.0)
	add_child(camera)
	camera.look_at(Vector3(0.0, 0.0, 0.0))
	camera.current = true

func _build_terrain() -> void:
	_box("Ground", Vector3(48.0, 1.0, 34.0), Vector3(0.0, -1.0, 0.0), Color("#596040"))
	_box("LeftTerrace", Vector3(22.0, 0.9, 29.0), Vector3(-8.0, -0.15, 0.0), Color("#6d6944"))
	_box("RightTerrace", Vector3(13.0, 0.75, 29.0), Vector3(14.5, -0.35, 0.0), Color("#58583b"))
	_box("KeepRise", Vector3(13.5, 1.25, 10.0), Vector3(-10.0, 0.1, -8.5), Color("#716b47"))
	_box("MineRise", Vector3(10.0, 1.05, 9.0), Vector3(14.5, -0.05, -8.5), Color("#55513d"))
	_box("BarracksYard", Vector3(12.0, 0.48, 8.0), Vector3(-7.0, 0.5, 8.5), Color("#776b49"))
	_add_terrain_scar(Vector3(-16.0, 0.55, 4.0), Vector3(5.5, 0.08, 2.8), Color("#857454"), -10.0)
	_add_terrain_scar(Vector3(-1.0, 0.56, -10.5), Vector3(6.5, 0.08, 2.1), Color("#4f593a"), 8.0)
	_add_terrain_scar(Vector3(15.0, 0.25, 7.0), Vector3(5.0, 0.08, 3.0), Color("#66583b"), 14.0)

func _build_road_and_river() -> void:
	var road_points := [
		Vector3(-23.0, 0.72, 8.0),
		Vector3(-17.0, 0.78, 7.2),
		Vector3(-11.0, 0.82, 5.5),
		Vector3(-5.0, 0.72, 4.6),
		Vector3(0.5, 0.38, 3.8),
		Vector3(5.0, 0.12, 3.1),
		Vector3(10.0, 0.18, 2.1),
		Vector3(17.0, 0.18, 0.2),
		Vector3(23.0, 0.15, -1.0)
	]
	_ribbon("RoadShoulder", road_points, [3.5, 3.8, 4.2, 4.3, 4.0, 3.7, 3.6, 3.3, 3.0], Color("#5e5038"))
	var road_surface: Array[Vector3] = []
	for point in road_points:
		road_surface.append(point + Vector3(0.0, 0.06, 0.0))
	_ribbon("RoadSurface", road_surface, [2.4, 2.7, 3.0, 3.1, 2.8, 2.5, 2.5, 2.3, 2.0], Color("#9b8053"))

	var river_points := [
		Vector3(5.0, -0.72, -18.0),
		Vector3(4.3, -0.74, -12.0),
		Vector3(5.4, -0.76, -6.0),
		Vector3(5.0, -0.78, 0.0),
		Vector3(5.8, -0.78, 6.0),
		Vector3(6.8, -0.75, 12.0),
		Vector3(6.0, -0.72, 18.0)
	]
	_ribbon("RiverBed", river_points, [6.6, 6.0, 6.8, 7.0, 6.6, 7.2, 6.5], Color("#273c3d"))
	var water_points: Array[Vector3] = []
	for point in river_points:
		water_points.append(point + Vector3(0.0, 0.25, 0.0))
	var water := _ribbon("Water", water_points, [5.2, 4.7, 5.4, 5.6, 5.1, 5.8, 5.0], Color("#245b67"))
	var water_material := water.material_override as StandardMaterial3D
	water_material.metallic = 0.18
	water_material.roughness = 0.2
	water_material.emission_enabled = true
	water_material.emission = Color("#153d49")
	water_material.emission_energy_multiplier = 0.32

	for z in [-14.0, -10.0, -5.5, 7.5, 11.0, 15.0]:
		_rock(Vector3(2.0, -0.1, z), 0.75, Color("#625f50"))
		_rock(Vector3(9.0, -0.18, z + 1.2), 0.6, Color("#54564d"))
	for z in [-10.0, -4.5, 8.0, 13.0]:
		_box("Foam", Vector3(2.2, 0.035, 0.17), Vector3(5.5, -0.42, z), Color("#a8c9bd"), -8.0)

func _build_bridge() -> void:
	for x in [2.0, 8.0]:
		_box("BridgePier", Vector3(1.5, 2.5, 4.8), Vector3(x, 0.05, 3.1), Color("#62594a"))
		_box("PierCap", Vector3(2.1, 0.42, 5.4), Vector3(x, 1.35, 3.1), Color("#91816a"))
	_box("BridgeDeck", Vector3(9.0, 0.55, 4.2), Vector3(5.0, 1.65, 3.1), Color("#6f5035"))
	for x in [1.2, 2.5, 3.8, 5.1, 6.4, 7.7, 9.0]:
		_box("BridgeBeam", Vector3(0.22, 0.5, 4.55), Vector3(x, 1.96, 3.1), Color("#362a22"))
	for z in [1.15, 5.05]:
		_box("BridgeRail", Vector3(9.4, 0.22, 0.18), Vector3(5.0, 2.55, z), Color("#382c24"))
		for x in [1.0, 3.0, 5.0, 7.0, 9.0]:
			_box("BridgePost", Vector3(0.18, 1.25, 0.18), Vector3(x, 2.25, z), Color("#443126"))

func _build_keep() -> void:
	var stone := Color("#82765d")
	var dark := Color("#433d35")
	_box("KeepPlinth", Vector3(11.5, 0.8, 8.5), Vector3(-11.0, 1.1, -8.0), dark)
	_box("KeepHall", Vector3(7.5, 5.2, 5.8), Vector3(-11.0, 4.1, -8.0), stone)
	for corner in [Vector3(-15.0, 4.7, -11.0), Vector3(-7.0, 4.7, -11.0), Vector3(-15.0, 4.7, -5.0), Vector3(-7.0, 4.7, -5.0)]:
		_cylinder("KeepTower", 1.65, 7.0, corner, Color("#746a57"), 8)
		_cylinder("TowerCrown", 2.0, 0.65, corner + Vector3(0.0, 3.75, 0.0), Color("#3d3a32"), 8)
	_roof("KeepRoof", Vector3(-11.0, 7.1, -8.0), Vector3(8.4, 0.42, 4.5), Color("#304543"))
	_box("KeepGate", Vector3(2.2, 3.1, 0.4), Vector3(-11.0, 2.7, -4.92), Color("#2a2521"))
	_box("KeepBanner", Vector3(0.42, 2.8, 0.12), Vector3(-11.0, 6.0, -4.65), Color("#c7a64c"))
	for x in [-13.6, -11.0, -8.4]:
		_box("KeepBattlement", Vector3(1.0, 0.65, 0.8), Vector3(x, 7.0, -5.0), stone)

func _build_barracks() -> void:
	var timber := Color("#513a2b")
	var plaster := Color("#a18d65")
	_box("BarracksFoundation", Vector3(10.0, 0.65, 6.8), Vector3(-7.0, 1.05, 8.0), Color("#4b4438"))
	_box("BarracksBody", Vector3(8.8, 3.7, 5.8), Vector3(-7.0, 3.1, 8.0), plaster)
	_roof("BarracksRoof", Vector3(-7.0, 5.4, 8.0), Vector3(10.2, 0.42, 4.3), Color("#432e28"))
	for x in [-10.8, -7.0, -3.2]:
		_box("BarracksPost", Vector3(0.36, 4.1, 0.36), Vector3(x, 3.0, 5.0), timber)
	_box("BarracksDoor", Vector3(1.8, 2.5, 0.3), Vector3(-7.0, 2.45, 5.0), Color("#2b211c"))
	_box("WorkshopLeanTo", Vector3(4.0, 2.2, 3.2), Vector3(-1.0, 2.1, 9.0), Color("#6b5237"))
	_box("Chimney", Vector3(0.8, 3.4, 0.8), Vector3(-1.5, 5.0, 8.5), Color("#4d4540"))

func _build_mine() -> void:
	_box("MineCut", Vector3(9.0, 2.0, 7.0), Vector3(15.0, 0.8, -8.0), Color("#3d4036"))
	for offset in [Vector3(-3.5, 1.3, -2.7), Vector3(3.5, 1.1, -2.5), Vector3(-3.0, 1.0, 2.6), Vector3(3.2, 1.2, 2.5)]:
		_rock(Vector3(15.0, 0.8, -8.0) + offset, 1.5, Color("#57594c"))
	_box("MinePortal", Vector3(4.2, 4.4, 0.8), Vector3(15.0, 2.6, -4.7), Color("#332c28"))
	_box("MineHeader", Vector3(5.2, 0.5, 1.2), Vector3(15.0, 5.0, -4.7), Color("#725238"))
	for x in [12.9, 17.1]:
		_box("MinePost", Vector3(0.55, 4.8, 0.8), Vector3(x, 2.8, -4.7), Color("#68472f"))
	_cylinder("LumeWell", 1.45, 1.6, Vector3(19.5, 1.15, -9.0), Color("#3c625f"), 10)
	var crystal := _cylinder("LumeCrystal", 0.7, 3.6, Vector3(19.5, 3.15, -9.0), Color("#58d8cb"), 6)
	var crystal_material := crystal.material_override as StandardMaterial3D
	crystal_material.emission_enabled = true
	crystal_material.emission = Color("#3ff1dc")
	crystal_material.emission_energy_multiplier = 2.8
	var lume_light := OmniLight3D.new()
	lume_light.position = Vector3(19.5, 4.0, -9.0)
	lume_light.light_color = Color("#45e3d1")
	lume_light.light_energy = 7.0
	lume_light.omni_range = 9.0
	lume_light.shadow_enabled = true
	add_child(lume_light)

func _build_units() -> void:
	for index in range(6):
		var x := -3.5 + float(index % 3) * 1.25
		var z := 1.2 + float(index / 3) * 1.5
		_unit("Militia", Vector3(x, 1.35, z), Color("#3d7390"), Color("#c6b177"), index == 0)
	for index in range(3):
		_unit("Worker", Vector3(11.0 + float(index) * 1.1, 1.05, -3.0), Color("#7d6041"), Color("#9d896a"), false)
	_unit("Aster", Vector3(-7.0, 1.6, 1.4), Color("#305e85"), Color("#d5bb72"), true)

func _unit(label: String, position: Vector3, cloth: Color, metal: Color, leader: bool) -> void:
	_cylinder(label + "Body", 0.34 if not leader else 0.43, 1.35 if not leader else 1.65, position, cloth, 8)
	_cylinder(label + "Head", 0.29 if not leader else 0.34, 0.5, position + Vector3(0.0, 0.92 if not leader else 1.12, 0.0), Color("#aa876a"), 10)
	_box(label + "Shield", Vector3(0.12, 0.82, 0.62), position + Vector3(-0.38, 0.0, 0.05), metal)
	_box(label + "Weapon", Vector3(0.08, 1.75, 0.08), position + Vector3(0.42, 0.25, 0.0), Color("#4a3b2e"), -8.0)
	if leader:
		_cylinder(label + "Selection", 0.72, 0.05, position + Vector3(0.0, -0.68, 0.0), Color("#59d6c9"), 32)

func _build_dressing() -> void:
	for point in [
		Vector3(-19.0, 0.7, -12.0), Vector3(-18.0, 0.7, 13.0), Vector3(-2.0, 0.7, -14.0),
		Vector3(20.0, 0.3, 11.0), Vector3(21.0, 0.3, -13.0), Vector3(11.0, 0.3, 13.5)
	]:
		_tree(point)
	for point in [
		Vector3(-19.0, 0.4, 2.0), Vector3(-14.0, 0.5, 11.0), Vector3(-3.0, 0.45, -12.0),
		Vector3(13.0, 0.2, 11.0), Vector3(19.0, 0.2, 5.0)
	]:
		_rock(point, 0.75, Color("#5e5c4f"))

func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var top := ColorRect.new()
	top.position = Vector2(285, 18)
	top.size = Vector2(1030, 50)
	top.color = Color(0.025, 0.038, 0.032, 0.94)
	layer.add_child(top)
	var title := Label.new()
	title.position = Vector2(24, 10)
	title.text = "SALTO  |  PRODUCTION TARGET SLICE     420      160      90      38      9/16"
	title.add_theme_color_override("font_color", Color("#e4d8aa"))
	title.add_theme_font_size_override("font_size", 17)
	top.add_child(title)

	var objective := ColorRect.new()
	objective.position = Vector2(285, 76)
	objective.size = Vector2(720, 38)
	objective.color = Color(0.035, 0.045, 0.035, 0.91)
	layer.add_child(objective)
	var objective_text := Label.new()
	objective_text.position = Vector2(16, 8)
	objective_text.text = "PRODUCTION DIRECTION SPIKE  |  Secure the crossing and restore the Lume mine"
	objective_text.add_theme_color_override("font_color", Color("#d8c58a"))
	objective.add_child(objective_text)

	var mini := ColorRect.new()
	mini.position = Vector2(48, 680)
	mini.size = Vector2(235, 165)
	mini.color = Color(0.02, 0.03, 0.025, 0.94)
	layer.add_child(mini)
	var mini_label := Label.new()
	mini_label.position = Vector2(14, 10)
	mini_label.text = "MAP"
	mini_label.add_theme_color_override("font_color", Color("#d8c58a"))
	mini.add_child(mini_label)
	var map_field := ColorRect.new()
	map_field.position = Vector2(14, 36)
	map_field.size = Vector2(207, 112)
	map_field.color = Color("#1c2820")
	mini.add_child(map_field)
	_ui_rect(map_field, Vector2(18, 44), Vector2(128, 18), Color("#93794e"))
	_ui_rect(map_field, Vector2(112, 8), Vector2(18, 96), Color("#285b68"))
	_ui_rect(map_field, Vector2(32, 20), Vector2(30, 30), Color("#c5af72"))
	_ui_rect(map_field, Vector2(154, 18), Vector2(27, 24), Color("#48cbbb"))

	var card := ColorRect.new()
	card.position = Vector2(515, 790)
	card.size = Vector2(570, 82)
	card.color = Color(0.025, 0.035, 0.028, 0.96)
	layer.add_child(card)
	var card_text := Label.new()
	card_text.position = Vector2(20, 12)
	card_text.text = "ASTER OF THE QUIET LINK\nField command intact  |  authored 3D visual-spike geometry  |  visual proof only"
	card_text.add_theme_color_override("font_color", Color("#ddd2a4"))
	card_text.add_theme_font_size_override("font_size", 15)
	card.add_child(card_text)

	var badge := ColorRect.new()
	badge.position = Vector2(1300, 790)
	badge.size = Vector2(245, 52)
	badge.color = Color(0.08, 0.12, 0.09, 0.94)
	layer.add_child(badge)
	var badge_text := Label.new()
	badge_text.position = Vector2(14, 15)
	badge_text.text = "ISOLATED / NON-PLAYABLE"
	badge_text.add_theme_color_override("font_color", Color("#75d8c7"))
	badge.add_child(badge_text)

func _capture_views() -> void:
	await _capture("overview", Vector3(29.0, 31.0, 31.0), Vector3(0.0, 1.0, 0.0), 38.5)
	await _capture("base_focus", Vector3(-1.0, 22.0, 20.0), Vector3(-9.0, 2.2, -4.0), 25.0)
	await _capture("road_river_bridge", Vector3(24.0, 21.0, 25.0), Vector3(4.5, 0.8, 3.0), 22.0)
	await _capture("units_scale", Vector3(10.0, 14.0, 16.0), Vector3(-3.0, 1.0, 2.5), 15.5)

func _capture(id: String, camera_position: Vector3, target: Vector3, ortho_size: float) -> void:
	camera.position = camera_position
	camera.size = ortho_size
	camera.look_at(target)
	await _settle_frames(12)
	var image := get_viewport().get_texture().get_image()
	if image == null:
		errors.append("Viewport unavailable for %s" % id)
		return
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var file_name := "%02d_%s.png" % [captures.size() + 1, id]
	var target_path := screenshot_root.path_join(file_name)
	var result := image.save_png(target_path)
	if result != OK:
		errors.append("Failed to save %s" % file_name)
	captures.append({
		"id": id,
		"absolutePath": target_path,
		"fileName": file_name,
		"width": image.get_width(),
		"height": image.get_height(),
		"cameraPosition": {"x": camera_position.x, "y": camera_position.y, "z": camera_position.z},
		"cameraTarget": {"x": target.x, "y": target.y, "z": target.z},
		"orthographicSize": ortho_size
	})

func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0232-production-target-spike-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS_V0232_PRODUCTION_TARGET_SPIKE" if errors.is_empty() else "FAIL_V0232_PRODUCTION_TARGET_SPIKE",
		"pipeline": "Godot 3D orthographic authored low-poly geometry",
		"isolatedScene": "res://scenes/salto_production_target_spike.tscn",
		"nonPlayable": true,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"gameplayChanged": false,
		"pathingChanged": false,
		"collisionChanged": false,
		"saveChanged": false,
		"generatedExternalImages": 0,
		"downloadedAssets": 0,
		"newRuntimeArtSlots": 0,
		"retainsV0231Comparator": true,
		"captureCount": captures.size(),
		"captures": captures,
		"errors": errors
	})

func _box(label: String, size: Vector3, position: Vector3, color: Color, y_rotation := 0.0) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.position = position
	instance.rotation_degrees.y = y_rotation
	instance.material_override = _material(color)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(instance)
	return instance

func _cylinder(label: String, radius: float, height: float, position: Vector3, color: Color, sides: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 1.08
	mesh.height = height
	mesh.radial_segments = sides
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(instance)
	return instance

func _roof(label: String, position: Vector3, size: Vector3, color: Color) -> void:
	var left := _box(label + "Left", size, position + Vector3(0.0, 0.0, -size.z * 0.22), color)
	left.rotation_degrees.x = -28.0
	var right := _box(label + "Right", size, position + Vector3(0.0, 0.0, size.z * 0.22), color)
	right.rotation_degrees.x = 28.0

func _tree(position: Vector3) -> void:
	_cylinder("TreeTrunk", 0.28, 2.5, position + Vector3(0.0, 1.25, 0.0), Color("#3c3026"), 7)
	_cylinder("TreeCrownLow", 1.15, 2.6, position + Vector3(0.0, 3.0, 0.0), Color("#263f2f"), 7)
	_cylinder("TreeCrownHigh", 0.8, 2.1, position + Vector3(0.0, 4.6, 0.0), Color("#31503a"), 7)

func _rock(position: Vector3, scale_value: float, color: Color) -> void:
	var rock := _box("Rock", Vector3(1.6, 1.1, 1.3) * scale_value, position, color, 22.0)
	rock.rotation_degrees.z = 12.0

func _add_terrain_scar(position: Vector3, size: Vector3, color: Color, rotation_y: float) -> void:
	_box("TerrainScar", size, position, color, rotation_y)

func _ribbon(label: String, points: Array, widths: Array, color: Color) -> MeshInstance3D:
	var vertices := PackedVector3Array()
	for index in range(points.size()):
		var current: Vector3 = points[index]
		var direction: Vector3
		if index == 0:
			direction = (points[1] - current).normalized()
		elif index == points.size() - 1:
			direction = (current - points[index - 1]).normalized()
		else:
			direction = (points[index + 1] - points[index - 1]).normalized()
		var side := Vector3(-direction.z, 0.0, direction.x).normalized() * float(widths[index]) * 0.5
		vertices.append(current - side)
		vertices.append(current + side)
	var indices := PackedInt32Array()
	for index in range(points.size() - 1):
		var base := index * 2
		indices.append_array(PackedInt32Array([base, base + 2, base + 1, base + 1, base + 2, base + 3]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.material_override = _material(color)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(instance)
	return instance

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.83
	return material

func _ui_rect(parent: Control, position: Vector2, size: Vector2, color: Color) -> void:
	var rect := ColorRect.new()
	rect.position = position
	rect.size = size
	rect.color = color
	parent.add_child(rect)

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
	return ProjectSettings.globalize_path("user://v0232-production-target-spike")

func _write_json(path: String, value: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
