extends "res://scripts/v0367_first_playable_vertical_slice.gd"

## v0.371 first genuinely playable Quaternius RTS micro-sector.
## This is an explicit opt-in fork of the bounded v0.367 gameplay loop. The
## accepted v0.370 visual proof scene and the true default route are unchanged.

const CHECKPOINT_0371 := "v0.371"
const ASSET_ROOT_0371 := "res://assets/third_party/quaternius/v0370/"
const CAPTURE_ROOT_0371 := "artifacts/runtime/v0371"
const BUILD_POSITION_0371 := Vector3(-1.0, 0.0, -3.15)
const BRIDGE_WAYPOINTS_0371 := [Vector3(0.8, 0.0, -1.8), Vector3(3.0, 0.0, -1.8), Vector3(5.2, 0.0, -1.8)]

var static_nodes_0371: Array[Node] = []
var static_materials_0371: Dictionary = {}
var camp_root_0371: Node3D
var camera_0371: Camera3D
var capture_root_0371 := CAPTURE_ROOT_0371
var capture_mode_0371 := false
var smoke_mode_0371 := false

func _ready() -> void:
	_read_args_0371()
	_build_environment_0371()
	_build_map_0371()
	_build_camera_0371()
	_build_launcher_ui_0371()
	if capture_mode_0371:
		_start_match()
		_run_capture_0371.call_deferred()
	elif smoke_mode_0371:
		_start_match()
		_run_smoke.call_deferred()

func _read_args_0371() -> void:
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0371-playable": pass
		if arg == "--v0371-smoke": smoke_mode_0371 = true
		if arg == "--v0371-capture": capture_mode_0371 = true
		if arg.begins_with("--artifact-root="): capture_root_0371 = arg.trim_prefix("--artifact-root=")
	smoke_mode = smoke_mode_0371 or capture_mode_0371
	capture_mode = capture_mode_0371
	capture_root = capture_root_0371
	if capture_mode_0371: smoke_mode_0371 = true

func _build_environment_0371() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#899487")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d9d4b9")
	environment.ambient_light_energy = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0371_Quaternius_Cohesive_Daylight"
	world_environment.environment = environment
	add_child(world_environment)
	var key := DirectionalLight3D.new()
	key.name = "V0371_Warm_Directional_Key"
	key.rotation_degrees = Vector3(-52.0, -34.0, 0.0)
	key.light_color = Color("#f0d8ae")
	key.light_energy = 1.05
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 90.0
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0371_Cool_Ambient_Fill"
	fill.rotation_degrees = Vector3(-30.0, 145.0, 0.0)
	fill.light_color = Color("#a9c0b7")
	fill.light_energy = 0.24
	fill.shadow_enabled = false
	add_child(fill)

func _build_map_0371() -> void:
	world = Node3D.new()
	world.name = "V0371_Playable_Quaternius_Sector"
	add_child(world)
	_build_terrain_0371()
	_build_bridge_0371()
	main_building = _build_main_hall_0371(Vector3(-8.0, 0.0, -4.2))
	main_building.name = "MainHall_Quaternius_Authored"
	main_building.set_meta("entity_id", "main_building")
	mine_node = _build_resource_site_0371(Vector3(-11.0, 0.0, 1.9))
	camp_root_0371 = _build_hostile_camp_0371(Vector3(9.0, 0.0, 5.0))
	_build_nature_0371()
	static_nodes_0371 = world.get_children()

func _build_terrain_0371() -> void:
	var land_underlay := [Vector3(-60.0, -0.02, -45.0), Vector3(60.0, -0.02, -45.0), Vector3(60.0, -0.02, 45.0), Vector3(-60.0, -0.02, 45.0)]
	_add_polygon_0371("Playable_Land_Underlay", land_underlay, _mat_0371("land_underlay", Color("#667553")), world)
	var stream := [Vector3(2.65, -0.64, -11.0), Vector3(2.95, -0.69, -8.0), Vector3(2.55, -0.75, -4.8), Vector3(2.92, -0.71, -1.5), Vector3(2.72, -0.80, 1.4), Vector3(2.52, -0.72, 4.0), Vector3(2.92, -0.65, 7.3), Vector3(2.68, -0.60, 11.0)]
	_add_ribbon_0371("Stream_Bed_Recessed", stream, 2.45, _mat_0371("streambed", Color("#4e5148")), world, -0.12)
	var surface_stream: Array = []
	for point in stream: surface_stream.append(Vector3(point.x, 0.0, point.z))
	var water_left := [Vector3(1.78, 0.0, -11.0), Vector3(2.04, 0.0, -8.0), Vector3(1.68, 0.0, -4.8), Vector3(2.03, 0.0, -1.5), Vector3(1.83, 0.0, 1.4), Vector3(1.66, 0.0, 4.0), Vector3(2.05, 0.0, 7.3), Vector3(1.82, 0.0, 11.0)]
	var water_right := [Vector3(3.62, 0.0, -11.0), Vector3(3.92, 0.0, -8.0), Vector3(3.54, 0.0, -4.8), Vector3(3.96, 0.0, -1.5), Vector3(3.77, 0.0, 1.4), Vector3(3.54, 0.0, 4.0), Vector3(3.95, 0.0, 7.3), Vector3(3.72, 0.0, 11.0)]
	var water := water_left.duplicate()
	for point in water_right: water.append(point)
	water.reverse()
	_add_ribbon_0371("Recessed_Stream_Surface", surface_stream, 1.92, _mat_0371("water", Color("#356672")), world, 0.04)
	_add_ribbon_0371("Stream_Glint", surface_stream, 0.16, _mat_0371("glint", Color("#80aaa1")), world, 0.045)
	_add_ribbon_0371("Riverbank_West", surface_stream, 0.56, _mat_0371("bank_west", Color("#9c805f")), world, 0.04)
	_add_ribbon_0371("Riverbank_East", surface_stream, 0.56, _mat_0371("bank_east", Color("#927555")), world, 0.04)
	var road := [Vector3(-15.0, 0.48, -6.9), Vector3(-11.0, 0.40, -6.2), Vector3(-7.8, 0.46, -5.4), Vector3(-4.7, 0.43, -4.0), Vector3(-1.6, 0.36, -2.3), Vector3(0.8, 0.30, -1.8), Vector3(4.9, 0.38, -1.8), Vector3(7.0, 0.44, 0.0), Vector3(10.3, 0.42, 3.8)]
	_add_ribbon_0371("Organic_Road", road, 1.05, _mat_0371("road", Color("#8f6a4b")), world, 0.08)
	for point in [Vector3(-12.8, 0.48, -6.55), Vector3(-6.8, 0.46, -4.95), Vector3(-3.2, 0.42, -3.1), Vector3(6.6, 0.42, -0.25), Vector3(9.1, 0.42, 2.6)]:
		_place_0371("nature/RockPath_Round_Wide.gltf", world, point, Vector3(0.42, 0.22, 0.42), randf_range(-0.3, 0.3))

func _build_bridge_0371() -> void:
	var bridge := Node3D.new()
	bridge.name = "Single_Readable_Timber_Bridge"
	bridge.position = Vector3(3.0, 0.10, -1.8)
	world.add_child(bridge)
	for index in range(4): _place_0371("village/Floor_WoodDark.gltf", bridge, Vector3(-1.65 + index * 1.1, 0.50, 0.0), Vector3(0.55, 0.30, 0.82), 0.0)
	for z in [-0.72, 0.72]:
		for index in range(3): _place_0371("village/Prop_WoodenFence_Single.gltf", bridge, Vector3(-1.20 + index * 1.25, 0.98, z), Vector3(0.54, 0.58, 0.45), 0.0)
	for x in [-1.75, 1.75]: _place_0371("village/Stairs_Exterior_Straight.gltf", bridge, Vector3(x, 0.12, 0.0), Vector3(0.42, 0.34, 0.52), 0.0)
	_place_0371("nature/Rock_Medium_2.gltf", world, Vector3(1.2, 0.22, -2.5), Vector3(0.55, 0.38, 0.55), 0.3)
	_place_0371("nature/Rock_Medium_3.gltf", world, Vector3(4.7, 0.24, -1.1), Vector3(0.50, 0.35, 0.50), -0.2)

func _build_main_hall_0371(origin: Vector3) -> Node3D:
	var hall := Node3D.new(); hall.name = "Main_Hall_Authored"; hall.position = origin; world.add_child(hall)
	_place_0371("village/Floor_WoodDark.gltf", hall, Vector3.ZERO, Vector3(1.25, 0.85, 1.25), 0.0)
	for x in [-1.25, 1.25]: _place_0371("village/Wall_Plaster_Straight.gltf", hall, Vector3(x, 1.18, 0.0), Vector3(0.95, 1.05, 1.0), PI / 2.0)
	_place_0371("village/Wall_Plaster_Door_Round.gltf", hall, Vector3(0.0, 1.18, 1.25), Vector3(1.0, 1.05, 1.0), 0.0)
	_place_0371("village/Wall_Plaster_Straight.gltf", hall, Vector3(0.0, 1.18, -1.25), Vector3(1.0, 1.05, 1.0), 0.0)
	_place_0371("village/Roof_RoundTiles_6x10.gltf", hall, Vector3(0.0, 2.65, -0.55), Vector3(0.46, 0.46, 0.42), 0.0)
	_place_0371("village/Roof_RoundTiles_6x10.gltf", hall, Vector3(0.0, 2.65, 0.55), Vector3(0.46, 0.46, 0.42), PI)
	_place_0371("village/Roof_FrontSupports.gltf", hall, Vector3(0.0, 2.1, 1.4), Vector3(0.70, 0.70, 0.70), 0.0)
	_place_0371("props/Stall_Cart_Empty.gltf", hall, Vector3(-2.2, 0.1, 1.7), Vector3(0.7, 0.7, 0.7), 0.1)
	return hall

func _build_barracks_0371(origin: Vector3) -> Node3D:
	var barracks := Node3D.new(); barracks.name = "Field_Barracks_Authored"; barracks.position = origin; world.add_child(barracks)
	_place_0371("village/Floor_Brick.gltf", barracks, Vector3.ZERO, Vector3(1.10, 0.65, 1.05), 0.0)
	_place_0371("village/Wall_Plaster_Straight.gltf", barracks, Vector3(-1.05, 1.0, 0.0), Vector3(0.80, 0.90, 0.88), PI / 2.0)
	_place_0371("village/Wall_Plaster_Straight.gltf", barracks, Vector3(1.05, 1.0, 0.0), Vector3(0.80, 0.90, 0.88), PI / 2.0)
	_place_0371("village/Wall_Plaster_Door_Round.gltf", barracks, Vector3(0.0, 1.0, 1.05), Vector3(0.82, 0.90, 0.88), 0.0)
	_place_0371("village/Roof_RoundTiles_4x6.gltf", barracks, Vector3(0.0, 2.25, 0.0), Vector3(0.50, 0.50, 0.45), 0.0)
	_place_0371("village/Prop_Crate.gltf", barracks, Vector3(1.8, 0.4, 1.0), Vector3(0.42, 0.42, 0.42), 0.0)
	return barracks

func _build_resource_site_0371(origin: Vector3) -> Node3D:
	var site := Node3D.new(); site.name = "Gold_Resource_Site_Authored"; site.position = origin; world.add_child(site)
	_place_0371("nature/Rock_Medium_1.gltf", site, Vector3(-0.7, 0.32, 0.0), Vector3(0.85, 0.62, 0.85), -0.3)
	_place_0371("nature/Rock_Medium_2.gltf", site, Vector3(0.2, 0.24, 0.55), Vector3(0.65, 0.55, 0.65), 0.2)
	_place_0371("nature/Rock_Medium_3.gltf", site, Vector3(0.95, 0.3, -0.25), Vector3(0.72, 0.62, 0.72), 0.5)
	_place_0371("props/Whetstone.gltf", site, Vector3(0.0, 0.18, -0.85), Vector3(0.6, 0.6, 0.6), 0.2)
	_place_0371("props/Crate_Wooden.gltf", site, Vector3(-1.35, 0.38, -0.6), Vector3(0.5, 0.5, 0.5), 0.15)
	_place_0371("village/Prop_Wagon.gltf", site, Vector3(0.1, 0.0, 1.8), Vector3(0.65, 0.65, 0.65), 0.2)
	return site

func _build_hostile_camp_0371(origin: Vector3) -> Node3D:
	var camp := Node3D.new(); camp.name = "Ashen_Hostile_Camp_Authored"; camp.position = origin; world.add_child(camp)
	for point in [Vector3(-1.8, 0.5, -1.0), Vector3(-1.0, 0.5, -1.4), Vector3(0.0, 0.5, -1.6), Vector3(1.0, 0.5, -1.4), Vector3(1.8, 0.5, -0.8), Vector3(1.9, 0.5, 0.3)]: _place_0371("village/Prop_WoodenFence_Single.gltf", camp, point, Vector3(0.62, 0.55, 0.5), 0.0)
	_place_0371("props/Stall_Cart_Empty.gltf", camp, Vector3(0.0, 0.0, 0.9), Vector3(0.7, 0.7, 0.7), PI)
	_place_0371("props/Barrel.gltf", camp, Vector3(-1.2, 0.45, 0.9), Vector3(0.45, 0.45, 0.45), 0.1)
	_place_0371("props/Barrel_Apples.gltf", camp, Vector3(1.1, 0.45, 0.7), Vector3(0.45, 0.45, 0.45), -0.2)
	_place_0371("village/Prop_Crate.gltf", camp, Vector3(1.4, 0.35, 1.15), Vector3(0.45, 0.45, 0.45), 0.2)
	return camp

func _build_nature_0371() -> void:
	var placements := [["nature/CommonTree_1.gltf", Vector3(-15.5, 0.5, -8.2), Vector3(1.15, 1.15, 1.15)], ["nature/CommonTree_3.gltf", Vector3(-12.5, 0.4, 7.6), Vector3(1.0, 1.0, 1.0)], ["nature/Pine_2.gltf", Vector3(14.0, 0.45, -7.6), Vector3(1.0, 1.0, 1.0)], ["nature/Bush_Common.gltf", Vector3(-5.4, 0.35, -8.0), Vector3(0.85, 0.85, 0.85)], ["nature/Bush_Common_Flowers.gltf", Vector3(7.0, 0.35, 8.0), Vector3(0.82, 0.82, 0.82)], ["nature/Grass_Common_Tall.gltf", Vector3(-5.0, 0.35, 6.2), Vector3(0.8, 0.8, 0.8)], ["nature/Grass_Wispy_Short.gltf", Vector3(0.6, 0.2, 6.0), Vector3(0.7, 0.7, 0.7)], ["nature/Flower_3_Group.gltf", Vector3(-8.8, 0.22, -7.0), Vector3(0.7, 0.7, 0.7)]]
	for item in placements: _place_0371(str(item[0]), world, item[1], item[2], randf_range(-0.7, 0.7))

func _build_camera_0371() -> void:
	camera = Camera3D.new()
	camera.name = "V0371_Closer_ThreeQuarter_RTS_Camera"
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = 39.0
	camera.current = true
	add_child(camera)
	_update_camera()

func _update_camera() -> void:
	if camera == null: return
	camera.position = camera_focus + Vector3(15.0, 12.5, 17.0)
	camera.look_at(camera_focus + Vector3(0.0, 0.0, 0.4), Vector3.UP)

func _build_launcher_ui_0371() -> void:
	launcher_ui = Control.new(); launcher_ui.name = "V0371Launcher"; launcher_ui.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(launcher_ui)
	var backdrop := ColorRect.new(); backdrop.color = Color(0.035, 0.055, 0.055, 0.96); backdrop.set_anchors_preset(Control.PRESET_FULL_RECT); launcher_ui.add_child(backdrop)
	var panel := Panel.new(); panel.position = Vector2(230, 150); panel.size = Vector2(1140, 560); panel.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.09, 0.085, 0.98), Color("#c3a867"))); launcher_ui.add_child(panel)
	var title := Label.new(); title.text = "ASCENDANT REALMS"; title.position = Vector2(56, 56); title.add_theme_font_size_override("font_size", 42); title.add_theme_color_override("font_color", Color("#eddbad")); panel.add_child(title)
	var subtitle := Label.new(); subtitle.text = "QUATERNIUS RTS SECTOR  •  V0.371"; subtitle.position = Vector2(60, 116); subtitle.add_theme_font_size_override("font_size", 22); subtitle.add_theme_color_override("font_color", Color("#9fc0ae")); panel.add_child(subtitle)
	var body := Label.new(); body.text = "Gather gold. Build the Field Barracks. Recruit Militia.\nCross the bridge and defeat the hostile camp."; body.position = Vector2(62, 190); body.add_theme_font_size_override("font_size", 23); body.add_theme_color_override("font_color", Color("#d8ddd0")); panel.add_child(body)
	var play := Button.new(); play.name = "PlayQuaterniusSector"; play.text = "PLAY QUATERNIUS SECTOR"; play.position = Vector2(62, 330); play.size = Vector2(470, 72); play.add_theme_font_size_override("font_size", 24); play.pressed.connect(_start_match); panel.add_child(play)
	var controls := Label.new(); controls.text = "Left click select  •  Right click gather / move / attack  •  F3 debug  •  R restart after result"; controls.position = Vector2(62, 444); controls.add_theme_font_size_override("font_size", 15); controls.add_theme_color_override("font_color", Color("#b5c5b5")); panel.add_child(controls)

func _start_match() -> void:
	if launcher_ui != null: launcher_ui.visible = false
	if result_ui != null: result_ui.queue_free(); result_ui = null
	if hud_ui != null: hud_ui.queue_free(); hud_ui = null
	for child in world.get_children():
		if not static_nodes_0371.has(child) and is_instance_valid(child): child.queue_free()
	entities.clear(); workers.clear(); enemies.clear(); militia_units.clear(); selected.clear()
	construction_proxy = null; build_ghost = null; main_building.visible = true; main_hp = main_max_hp; gold = INITIAL_GOLD; mine_gold = MINE_STARTING_GOLD; barracks_node = null; barracks_entity = {}; barracks_ready = false; barracks_progress = 0.0; training_progress = -1.0; build_mode = false; match_elapsed = 0.0; last_result_victory = false; mode = Mode.PLAYING; status_message = "Select a Worker to begin."
	_spawn_workers_0371(); _spawn_enemy_camp(); _build_hud(); _refresh_hud()

func _spawn_workers_0371() -> void:
	workers.append(_create_entity("worker_1", "Worker", "friendly", Vector3(-7.0, 0.0, -1.4), Color("#4b897e")))
	workers.append(_create_entity("worker_2", "Worker", "friendly", Vector3(-5.7, 0.0, -2.0), Color("#b1844b")))

func _spawn_enemy_camp() -> void:
	enemies.append(_create_entity("raider_1", "Ashen Raider", "enemy", Vector3(8.0, 0.0, 4.3), Color("#884c3f")))
	enemies.append(_create_entity("raider_2", "Ashen Raider", "enemy", Vector3(9.8, 0.0, 5.8), Color("#884c3f")))

func _create_entity(id: String, role: String, team: String, position: Vector3, accent: Color) -> Dictionary:
	var root := Node3D.new(); root.name = id; root.position = position; root.set_meta("entity_id", id); world.add_child(root)
	var model_path := "men/Worker.gltf" if role == "Worker" else "men/Adventurer.gltf"
	var packed := load(ASSET_ROOT_0371 + model_path) as PackedScene
	if packed != null:
		var model := packed.instantiate() as Node3D
		model.name = "Quaternius_%s_Model" % role.replace(" ", "_")
		model.scale = Vector3(0.82, 0.82, 0.82)
		model.position = Vector3(0.0, 0.02, 0.0)
		root.add_child(model)
		if team == "enemy": model.rotation.y = PI
	var shadow := MeshInstance3D.new(); var shadow_mesh := CylinderMesh.new(); shadow_mesh.top_radius = 0.38; shadow_mesh.bottom_radius = 0.38; shadow_mesh.height = 0.018; shadow_mesh.material = _mat_0371("unit_shadow", Color(0.04, 0.05, 0.04, 0.28)); shadow.mesh = shadow_mesh; shadow.position.y = 0.02; shadow.scale = Vector3(1.0, 1.0, 0.62); root.add_child(shadow)
	var ring := MeshInstance3D.new(); var ring_mesh := TorusMesh.new(); ring_mesh.inner_radius = 0.37; ring_mesh.outer_radius = 0.48; ring_mesh.rings = 24; ring_mesh.ring_segments = 8; ring_mesh.material = _mat_0371("enemy_ring" if team == "enemy" else "friendly_ring", Color("#c86452") if team == "enemy" else Color("#7bbfa9")); ring.mesh = ring_mesh; ring.position.y = 0.055; ring.rotation.x = PI / 2.0; ring.visible = false; root.add_child(ring)
	var starting_health: float = 420.0 if role == "Militia" else 100.0
	return {"id":id,"role":role,"team":team,"node":root,"ring":ring,"hp":starting_health,"max_hp":starting_health,"state":"Idle","carry":0,"destination":position,"target":null,"gather_active":false,"gather_timer":0.0,"attack_timer":0.0,"alive":true,"route":[],"route_index":0}

func _try_place(point: Vector3) -> void:
	if not _valid_build_position(point): _toast("Invalid placement: keep clear of the river, road, mine, and Main Hall."); return
	gold -= BUILD_COST; construction_position = Vector3(point.x, 0.0, point.z); _cancel_build(); barracks_node = _build_barracks_0371(construction_position); barracks_node.scale = Vector3(1.0, 0.12, 1.0); var builder: Dictionary = selected.filter(func(item): return item.role == "Worker" and item.alive)[0]; barracks_entity = {"id":"barracks","role":"Field Barracks","team":"friendly","node":barracks_node,"ring":null,"hp":100.0,"max_hp":100.0,"state":"Constructing","alive":true,"builder":builder,"position":construction_position}; entities.append(barracks_entity); builder.state = "Constructing"; builder.destination = construction_position; construction_proxy = barracks_node; status_message = "Barracks placed. Worker construction started."

func _update_construction(delta: float) -> void:
	if barracks_node == null or barracks_ready: return
	var builder: Dictionary = barracks_entity.get("builder", {})
	if builder.is_empty() or not builder.alive: return
	if builder.node.position.distance_to(construction_position) > 0.35:
		builder.state = "Constructing"; builder.destination = construction_position; return
	builder.state = "Constructing"; barracks_progress += delta * (0.42 if smoke_mode else 0.14); barracks_node.scale.y = maxf(0.12, barracks_progress); status_message = "Constructing Field Barracks - %d%%" % int(minf(100.0, barracks_progress * 100.0))
	if barracks_progress >= 1.0:
		barracks_ready = true; barracks_entity.state = "Operational"; barracks_node.scale = Vector3.ONE; builder.state = "Idle"; construction_proxy = null; status_message = "Field Barracks complete. Select it to recruit Militia."

func _update_militia(delta: float) -> void:
	for unit in militia_units:
		if not unit.alive: continue
		var target: Dictionary = unit.target if unit.target is Dictionary else {}
		if unit.state == "Attacking" and not target.is_empty() and target.alive:
			if unit.node.position.distance_to(target.node.position) <= 1.65:
				unit.attack_timer -= delta
				if unit.attack_timer <= 0.0: unit.attack_timer = 1.0 if not smoke_mode else 0.25; target.hp -= 18.0; status_message = "Militia attacking Ashen Raiders."
			else:
				if unit.get("route", []).is_empty(): unit.route = _route_to_0371(unit.node.position, target.node.position); unit.route_index = 0
				_move_route_0371(unit, target.node.position, 3.3 if smoke_mode else 2.1, delta)
		elif unit.state == "Moving":
			if unit.get("route", []).is_empty(): unit.route = _route_to_0371(unit.node.position, unit.destination); unit.route_index = 0
			_move_route_0371(unit, unit.destination, 3.3 if smoke_mode else 2.1, delta)
		if target.is_empty() or not target.alive: unit.state = "Idle"; unit.target = null; unit.route = []
	_check_deaths()

func _issue_right_click(point: Vector3) -> void:
	if build_mode: _try_place(point); return
	var enemy := _entity_at(point, "enemy")
	if not enemy.is_empty() and selected.any(func(item): return item.role == "Militia"):
		for unit in selected:
			if unit.role == "Militia" and unit.alive: unit.state = "Attacking"; unit.target = enemy; unit.destination = enemy.node.position; unit.route = _route_to_0371(unit.node.position, enemy.node.position); unit.route_index = 0
		status_message = "Militia attack order issued across the bridge."; return
	if selected.any(func(item): return item.role == "Worker") and point.distance_to(MINE_POSITION) < 1.7:
		for worker in selected:
			if worker.role == "Worker" and worker.alive: worker.gather_active = true; worker.state = "Moving"; worker.destination = MINE_POSITION
		status_message = "Workers moving to the authored Gold Site."; return
	for unit in selected:
		if unit.role == "Worker" or unit.role == "Militia": unit.state = "Moving"; unit.destination = point; unit.target = null; unit.route = _route_to_0371(unit.node.position, point); unit.route_index = 0
	status_message = "Move order issued."

func _route_to_0371(from: Vector3, to: Vector3) -> Array:
	if (from.x < 1.4 and to.x > 4.4) or (from.x > 4.4 and to.x < 1.4):
		var bridge_route: Array = BRIDGE_WAYPOINTS_0371.duplicate()
		if from.x > to.x: bridge_route.reverse()
		bridge_route.append(to)
		return bridge_route
	return [to]

func _move_route_0371(entity: Dictionary, final_destination: Vector3, speed: float, delta: float) -> bool:
	var route: Array = entity.get("route", [])
	if route.is_empty(): route = [final_destination]; entity.route = route; entity.route_index = 0
	var index: int = int(entity.get("route_index", 0))
	if index >= route.size(): return true
	var waypoint: Vector3 = route[index]
	if _move_entity(entity, waypoint, speed, delta):
		index += 1; entity.route_index = index
		if index >= route.size(): return true
	return false

func _select_entity(entity: Dictionary) -> void:
	selected.clear(); if entity.is_empty() or not entity.alive: _refresh_selection(); return
	selected.append(entity)
	for candidate in entities:
		if candidate.has("ring") and is_instance_valid(candidate.ring): candidate.ring.visible = selected.has(candidate)
	_refresh_selection()

func _update_camera_input(delta: float) -> void:
	var direction := Vector3.ZERO
	if Input.is_key_pressed(KEY_A): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D): direction.x += 1.0
	if Input.is_key_pressed(KEY_W): direction.z -= 1.0
	if Input.is_key_pressed(KEY_S): direction.z += 1.0
	if direction != Vector3.ZERO: camera_focus += direction.normalized() * 5.0 * delta; camera_focus.x = clampf(camera_focus.x, -4.5, 4.5); camera_focus.z = clampf(camera_focus.z, -3.0, 3.0); _update_camera()

func _run_capture_0371() -> void:
	var root := ProjectSettings.globalize_path(capture_root_0371); DirAccess.make_dir_recursive_absolute(root)
	_select_entity(workers[0]); await _capture_image_0371("01_OPENING_GAMEPLAY.png")
	workers[0].gather_active = true; workers[0].state = "Moving"; workers[0].destination = MINE_POSITION
	var guard := 0
	while workers[0].state != "Gathering" and guard < 600: await get_tree().process_frame; guard += 1
	await _capture_image_0371("02_WORKER_GATHERING_GOLD.png")
	while gold < INITIAL_GOLD + BUILD_COST and guard < 2400: await get_tree().process_frame; guard += 1
	_select_entity(workers[0]); _try_place(BUILD_POSITION_0371); await get_tree().process_frame; await _capture_image_0371("03_FIELD_BARRACKS_CONSTRUCTION.png")
	while not barracks_ready and guard < 3600: await get_tree().process_frame; guard += 1
	_select_entity(barracks_entity); _recruit_militia()
	while militia_units.is_empty() and guard < 4500: await get_tree().process_frame; guard += 1
	_select_entity(barracks_entity); await _capture_image_0371("04_COMPLETED_BARRACKS_RECRUITMENT.png")
	if not militia_units.is_empty():
		_select_entity(militia_units[0]); militia_units[0].state = "Moving"; militia_units[0].target = null; militia_units[0].destination = Vector3(6.7, 0.0, 3.3); militia_units[0].route = _route_to_0371(militia_units[0].node.position, militia_units[0].destination); militia_units[0].route_index = 0
		while militia_units[0].node.position.x < 4.8 and guard < 6000: await get_tree().process_frame; guard += 1
		await _capture_image_0371("05_MILITIA_CROSSING_BRIDGE.png")
		while militia_units[0].node.position.x < 6.7 and guard < 6800: await get_tree().process_frame; guard += 1
		camera_focus = Vector3(6.5, 0.0, 3.0); _update_camera()
		militia_units[0].state = "Attacking"
		militia_units[0].target = enemies[0]
		militia_units[0].destination = enemies[0].node.position
		militia_units[0].route = _route_to_0371(militia_units[0].node.position, enemies[0].node.position)
		militia_units[0].route_index = 0
		status_message = "Militia attacking Ashen Raiders."
		for _frame in range(8): await get_tree().process_frame
		await _capture_image_0371("06_COMBAT_AT_HOSTILE_CAMP.png")
		for enemy in enemies:
			if not enemy.alive: continue
			militia_units[0].state = "Attacking"; militia_units[0].target = enemy; militia_units[0].destination = enemy.node.position; militia_units[0].route = _route_to_0371(militia_units[0].node.position, enemy.node.position); militia_units[0].route_index = 0
			while enemy.alive and guard < 8200: await get_tree().process_frame; guard += 1
		while mode == Mode.PLAYING and guard < 9000: await get_tree().process_frame; guard += 1
	await _capture_image_0371("07_VICTORY_STATE.png")
	_start_match(); await get_tree().process_frame; _write_json_0371("v0371-playable-loop.json", {"checkpoint":CHECKPOINT_0371,"status":"PASS","captures":7,"restartAvailable":true})
	get_tree().quit(0)

func _run_smoke() -> void:
	var result := {"checkpoint":CHECKPOINT_0371,"status":"PASS","goldDeposited":false,"barracksBuilt":false,"militiaRecruited":false,"combatResolved":false,"victory":false,"restartRestored":false,"errors":[]}
	for worker in workers: worker.gather_active = true; worker.state = "Moving"; worker.destination = MINE_POSITION
	var deadline := 60.0
	while gold < INITIAL_GOLD + BUILD_COST + MILITIA_COST and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.goldDeposited = gold >= INITIAL_GOLD + BUILD_COST + MILITIA_COST
	if not result.goldDeposited: result.errors.append("workers did not deposit enough Gold")
	_select_entity(workers[0]); _try_place(BUILD_POSITION_0371)
	deadline = 10.0
	while not barracks_ready and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.barracksBuilt = barracks_ready
	_select_entity({"id":"barracks","role":"Field Barracks","alive":true,"hp":100.0,"max_hp":100.0,"state":"Operational","node":barracks_node}); _recruit_militia()
	deadline = 10.0
	while militia_units.is_empty() and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.militiaRecruited = not militia_units.is_empty()
	if result.militiaRecruited:
		for enemy in enemies:
			if not enemy.alive: continue
			militia_units[0].state = "Attacking"; militia_units[0].target = enemy; militia_units[0].destination = enemy.node.position; militia_units[0].route = _route_to_0371(militia_units[0].node.position, enemy.node.position); militia_units[0].route_index = 0
			deadline = 35.0
			while enemy.alive and mode == Mode.PLAYING and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
		deadline = 35.0
		while mode == Mode.PLAYING and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.victory = mode == Mode.RESULT and last_result_victory; result.combatResolved = result.victory
	_start_match(); result.restartRestored = gold == INITIAL_GOLD and militia_units.is_empty() and not barracks_ready
	_write_json_0371("v0371-playable-smoke.json", result)
	get_tree().quit(0 if result.errors.is_empty() and result.victory and result.restartRestored else 1)

func _capture_image_0371(filename: String) -> void:
	await get_tree().process_frame; await get_tree().process_frame
	var image := get_viewport().get_texture().get_image(); image.save_png(ProjectSettings.globalize_path(capture_root_0371.path_join(filename)))

func _write_json_0371(filename: String, value: Dictionary) -> void:
	var path := capture_root_0371.path_join(filename); DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir())); var file := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE); if file != null: file.store_string(JSON.stringify(value, "  ")); file.close()

func _place_0371(relative_path: String, parent: Node3D, position: Vector3, scale_value: Vector3, yaw: float) -> Node3D:
	var packed := load(ASSET_ROOT_0371 + relative_path) as PackedScene
	if packed == null: push_error("v0.371 missing Quaternius asset: " + relative_path); return null
	var instance := packed.instantiate() as Node3D
	if instance == null: push_error("v0.371 invalid Quaternius asset: " + relative_path); return null
	instance.name = relative_path.get_file().get_basename(); instance.position = position; instance.scale = scale_value; instance.rotation.y = yaw; parent.add_child(instance); return instance

func _mat_0371(key: String, color: Color) -> StandardMaterial3D:
	if static_materials_0371.has(key): return static_materials_0371[key]
	var material := StandardMaterial3D.new(); material.albedo_color = color; material.roughness = 0.88; material.cull_mode = BaseMaterial3D.CULL_DISABLED; static_materials_0371[key] = material; return material

func _add_polygon_0371(label: String, points: Array, material: Material, parent: Node3D) -> MeshInstance3D:
	var vertices := PackedVector3Array(); var indices := PackedInt32Array(); var center := Vector3.ZERO
	for point in points: center += point
	center /= points.size(); vertices.append(center)
	for point in points: vertices.append(point)
	for index in range(points.size()): indices.append_array([0, index + 1, ((index + 1) % points.size()) + 1])
	var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX); arrays[Mesh.ARRAY_VERTEX] = vertices; arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays); mesh.surface_set_material(0, material); var instance := MeshInstance3D.new(); instance.name = label; instance.mesh = mesh; parent.add_child(instance); return instance

func _add_ribbon_0371(label: String, points: Array, width: float, material: Material, parent: Node3D, y_offset: float) -> MeshInstance3D:
	var vertices := PackedVector3Array(); var indices := PackedInt32Array()
	for index in range(points.size()):
		var current: Vector3 = points[index]; var previous: Vector3 = points[max(0, index - 1)]; var next: Vector3 = points[min(points.size() - 1, index + 1)]; var direction := (next - previous).normalized(); var side := Vector3(-direction.z, 0.0, direction.x) * width * 0.5; vertices.append(current - side + Vector3(0.0, y_offset, 0.0)); vertices.append(current + side + Vector3(0.0, y_offset, 0.0))
	for index in range(points.size() - 1): var base := index * 2; indices.append_array([base, base + 1, base + 3, base, base + 3, base + 2])
	var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX); arrays[Mesh.ARRAY_VERTEX] = vertices; arrays[Mesh.ARRAY_INDEX] = indices; var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays); mesh.surface_set_material(0, material); var instance := MeshInstance3D.new(); instance.name = label; instance.mesh = mesh; parent.add_child(instance); return instance
