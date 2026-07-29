extends "res://scripts/v0367_first_playable_vertical_slice.gd"

## v0.368 keeps the v0.367 playable rules and replaces only the opt-in visual
## presentation: a compact Barrosan hamlet, recessed stream, bridge crossing,
## authored mine formation, grounded billboards, and non-opaque construction.

const CHECKPOINT_0368 := "v0.368"
const CAPTURE_ROOT_0368 := "artifacts/runtime/v0368"
const V0368_MINE := Vector3(-9.0, 0.0, 2.8)
var debug_labels_0368: Array[Label3D] = []
var construction_fill_0368: MeshInstance3D

func _ready() -> void:
	_smoke_or_capture_flags()
	_build_environment()
	_build_map()
	_build_camera()
	_build_launcher_ui()
	if capture_mode:
		_start_match()
		_run_capture.call_deferred()
	elif smoke_mode:
		_start_match()
		_run_smoke.call_deferred()

func _smoke_or_capture_flags() -> void:
	for arg in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var value := str(arg)
		if value == "--v0368-smoke": smoke_mode = true
		if value == "--v0368-capture": capture_mode = true
		if value.begins_with("--artifact-root="): capture_root = value.trim_prefix("--artifact-root=")
	if capture_root == "artifacts/runtime/v0367": capture_root = CAPTURE_ROOT_0368
	if capture_mode: smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#8a9b88")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#cbd2bd")
	environment.ambient_light_energy = 0.82
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0368_Barrosan_Cool_Highland_Environment"
	world_environment.environment = environment
	add_child(world_environment)
	var key := DirectionalLight3D.new()
	key.name = "V0368_Warm_Directional_Key"
	key.rotation_degrees = Vector3(-54.0, -35.0, 0.0)
	key.light_color = Color("#f0dfbd")
	key.light_energy = 1.16
	key.shadow_enabled = true
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0368_Cool_Ambient_Fill"
	fill.rotation_degrees = Vector3(-28.0, 145.0, 0.0)
	fill.light_color = Color("#9bb7b0")
	fill.light_energy = 0.30
	add_child(fill)

func _build_map() -> void:
	world = Node3D.new()
	world.name = "V0368_Playable_Barrosan_Hamlet"
	add_child(world)
	var terrain := Node3D.new()
	terrain.name = "Terrain"
	world.add_child(terrain)
	_add_box("WestLand", Vector3(13.0, 0.32, 18.0), Vector3(-4.8, -0.18, 0.0), Color("#9aad78"), terrain)
	_add_box("EastLand", Vector3(11.0, 0.32, 18.0), Vector3(8.1, -0.18, 0.0), Color("#a4b87f"), terrain)
	_add_ground_patch("VillageClearing", [Vector3(-8.4, 0.02, -4.9), Vector3(-5.6, 0.02, -5.3), Vector3(-2.8, 0.02, -4.4), Vector3(-2.1, 0.02, -2.4), Vector3(-4.0, 0.02, -1.2), Vector3(-7.6, 0.02, -1.5), Vector3(-9.2, 0.02, -3.2)], Color("#a5b782"), terrain)
	_add_ground_patch("MineExcavation", [Vector3(-11.2, 0.03, 1.5), Vector3(-9.0, 0.03, 0.9), Vector3(-7.2, 0.03, 1.7), Vector3(-6.8, 0.03, 3.6), Vector3(-8.6, 0.03, 4.8), Vector3(-10.8, 0.03, 4.2), Vector3(-11.8, 0.03, 2.7)], Color("#927858"), terrain)
	_add_ground_patch("EnemyClearing", [Vector3(7.0, 0.03, 3.4), Vector3(8.7, 0.03, 2.8), Vector3(10.8, 0.03, 3.7), Vector3(11.2, 0.03, 5.9), Vector3(9.0, 0.03, 7.0), Vector3(7.0, 0.03, 6.2)], Color("#777967"), terrain)
	_add_path_ribbon("SouthRoad", [Vector3(-11.5, 0.05, -2.4), Vector3(-8.0, 0.05, -2.65), Vector3(-4.5, 0.05, -2.35), Vector3(-0.4, 0.05, -2.55), Vector3(1.8, 0.05, -2.4)], 0.72, Color("#c09159"), terrain, 0.05)
	_add_path_ribbon("EastRoad", [Vector3(5.65, 0.05, -8.4), Vector3(5.65, 0.05, -5.1), Vector3(5.65, 0.05, -2.4), Vector3(6.0, 0.05, 1.4), Vector3(7.0, 0.05, 5.8)], 0.78, Color("#c09159"), terrain, 0.05)
	_add_path_ribbon("MinePath", [Vector3(-4.0, 0.06, -2.4), Vector3(-6.0, 0.06, -2.7), Vector3(-7.4, 0.06, -1.0), Vector3(-8.9, 0.06, 1.8)], 0.64, Color("#bd8952"), terrain, 0.06)
	_add_path_ribbon("RecessedStream", [Vector3(3.0, -0.38, -8.8), Vector3(2.85, -0.38, -5.0), Vector3(3.0, -0.38, -1.2), Vector3(2.95, -0.38, 2.5), Vector3(3.0, -0.38, 6.1), Vector3(3.05, -0.38, 8.8)], 2.15, Color("#356a70"), world, -0.35)
	_add_path_ribbon("RiverBankWest", [Vector3(1.65, -0.02, -8.8), Vector3(1.55, -0.02, -4.5), Vector3(1.65, -0.02, -0.8), Vector3(1.55, -0.02, 3.2), Vector3(1.65, -0.02, 8.8)], 0.46, Color("#a48660"), world, -0.02)
	_add_path_ribbon("RiverBankEast", [Vector3(4.35, -0.02, -8.8), Vector3(4.45, -0.02, -4.5), Vector3(4.35, -0.02, -0.8), Vector3(4.45, -0.02, 3.2), Vector3(4.35, -0.02, 8.8)], 0.46, Color("#a48660"), world, -0.02)
	_add_path_ribbon("StreamGlint", [Vector3(2.95, -0.30, -8.0), Vector3(2.9, -0.30, -4.0), Vector3(3.0, -0.30, 0.2), Vector3(3.0, -0.30, 4.0), Vector3(3.05, -0.30, 8.0)], 0.07, Color("#a8d5c5"), world.get_node("RecessedStream"), -0.30)
	_build_bridge()
	_add_environment_dressing()
	_spawn_main_building()
	_spawn_mine()
	_spawn_workers()
	_spawn_enemy_camp()

func _add_environment_dressing() -> void:
	for position in [Vector3(-11.0, 0.0, -6.2), Vector3(-8.5, 0.0, -5.8), Vector3(10.5, 0.0, -4.8), Vector3(11.4, 0.0, 1.0), Vector3(-11.2, 0.0, 6.0), Vector3(10.8, 0.0, 7.0)]:
		var tree := Node3D.new(); tree.name = "Barrosan_Pine"; tree.position = position; world.add_child(tree)
		_add_box("PineTrunk", Vector3(0.24, 1.0, 0.24), Vector3(0.0, 0.5, 0.0), Color("#5b4433"), tree)
		var crown := MeshInstance3D.new(); var crown_mesh := PrismMesh.new(); crown_mesh.size = Vector3(1.0, 1.9, 1.0); crown_mesh.material = _material(Color("#405d45"), 0.98); crown.mesh = crown_mesh; crown.position.y = 1.65; tree.add_child(crown)
	for position in [Vector3(-1.5, 0.0, -6.3), Vector3(7.3, 0.0, -6.0), Vector3(-10.5, 0.0, 0.1), Vector3(10.8, 0.0, 6.3)]:
		var rock := MeshInstance3D.new(); var mesh := SphereMesh.new(); mesh.radius = 0.42; mesh.height = 0.62; mesh.material = _material(Color("#7d8275"), 0.98); rock.mesh = mesh; rock.position = position + Vector3(0.0, 0.23, 0.0); world.add_child(rock)

func _build_bridge() -> void:
	var bridge := Node3D.new(); bridge.name = "BridgeDeck"; bridge.position = Vector3(3.0, 0.0, -2.4); world.add_child(bridge)
	_add_box("BridgeStoneWest", Vector3(0.7, 0.52, 2.4), Vector3(-1.72, 0.20, 0.0), Color("#7f7766"), bridge)
	_add_box("BridgeStoneEast", Vector3(0.7, 0.52, 2.4), Vector3(1.72, 0.20, 0.0), Color("#7f7766"), bridge)
	_add_box("BridgeDeckSurface", Vector3(3.9, 0.22, 1.78), Vector3(0.0, 0.52, 0.0), Color("#8f6948"), bridge)
	for x in [-1.45, -0.72, 0.0, 0.72, 1.45]: _add_box("BridgePlank", Vector3(0.10, 0.10, 1.76), Vector3(x, 0.68, 0.0), Color("#b38450"), bridge)
	_add_box("BridgeRailWest", Vector3(4.0, 0.42, 0.12), Vector3(0.0, 1.05, -0.92), Color("#5f4736"), bridge)
	_add_box("BridgeRailEast", Vector3(4.0, 0.42, 0.12), Vector3(0.0, 1.05, 0.92), Color("#5f4736"), bridge)
	for x in [-1.65, 0.0, 1.65]:
		_add_box("BridgePost", Vector3(0.12, 0.72, 0.14), Vector3(x, 0.70, -0.92), Color("#5f4736"), bridge)
		_add_box("BridgePost", Vector3(0.12, 0.72, 0.14), Vector3(x, 0.70, 0.92), Color("#5f4736"), bridge)

func _spawn_main_building() -> void:
	super._spawn_main_building()
	if main_building != null:
		_add_box("MainBuildingGrounding", Vector3(3.8, 0.08, 3.0), Vector3(0.0, 0.04, 0.0), Color("#76634e"), main_building)

func _spawn_barracks(position: Vector3) -> Node3D:
	var instance := super._spawn_barracks(position)
	for node in instance.find_children("*", "MeshInstance3D", true, false): node.visible = false
	_add_box("BarracksFoundation", Vector3(3.0, 0.18, 2.45), Vector3(0.0, 0.10, 0.0), Color("#706652"), instance)
	_add_box("BarracksWalls", Vector3(2.7, 1.45, 2.1), Vector3(0.0, 0.87, 0.0), Color("#947d62"), instance)
	_add_box("BarracksTimberBand", Vector3(2.82, 0.20, 2.2), Vector3(0.0, 1.38, 0.0), Color("#5d4939"), instance)
	var roof_a := _add_box("BarracksRoofWest", Vector3(1.65, 0.18, 2.55), Vector3(-0.72, 1.78, 0.0), Color("#5a5c55"), instance); roof_a.rotation.z = -0.28
	var roof_b := _add_box("BarracksRoofEast", Vector3(1.65, 0.18, 2.55), Vector3(0.72, 1.78, 0.0), Color("#4d514d"), instance); roof_b.rotation.z = 0.28
	_add_box("BarracksDoor", Vector3(0.52, 0.86, 0.08), Vector3(0.0, 0.55, 1.07), Color("#4d3024"), instance)
	_add_box("BarracksEntranceStep", Vector3(0.95, 0.12, 0.38), Vector3(0.0, 0.16, 1.20), Color("#81765e"), instance)
	instance.name = "FieldBarracks_V0368_ControlledVisual"
	return instance

func _spawn_mine() -> void:
	mine_node = Node3D.new(); mine_node.name = "GoldMine_300Plus"; mine_node.position = MINE_POSITION; world.add_child(mine_node)
	for offset in [Vector3(-0.75, 0.24, 0.0), Vector3(0.0, 0.38, 0.2), Vector3(0.68, 0.25, -0.15), Vector3(0.1, 0.18, -0.55)]:
		var ore := MeshInstance3D.new(); var mesh := CylinderMesh.new(); mesh.top_radius = 0.30; mesh.bottom_radius = 0.54; mesh.height = 0.62; mesh.material = _material(Color("#5f6560"), 0.86); ore.mesh = mesh; ore.position = offset; mine_node.add_child(ore)
		var vein := _add_box("GoldVein", Vector3(0.30, 0.05, 0.10), offset + Vector3(0.0, 0.31, 0.0), Color("#d9ac4d"), mine_node); vein.rotation.y = 0.25
	var label := _world_label("GOLD MINE", Color("#f1d279")); label.position = Vector3(0.0, 1.15, 0.0); mine_node.add_child(label)

func _spawn_workers() -> void:
	workers.append(_create_entity("worker_1", "Worker", "friendly", Vector3(-2.8, 0.0, -1.6), Color("#3e7471")))
	workers.append(_create_entity("worker_2", "Worker", "friendly", Vector3(-2.2, 0.0, -0.6), Color("#b1844b")))

func _spawn_enemy_camp() -> void:
	var camp := Node3D.new(); camp.name = "AshenRaiderCamp"; camp.position = Vector3(8.8, 0.0, 5.2); world.add_child(camp)
	_add_ground_patch("CampAsh", [Vector3(-1.8, 0.03, -1.2), Vector3(1.4, 0.03, -1.4), Vector3(2.0, 0.03, 1.1), Vector3(0.5, 0.03, 1.9), Vector3(-1.7, 0.03, 1.0)], Color("#696a5b"), camp)
	_add_box("CampFire", Vector3(0.5, 0.18, 0.5), Vector3(0.0, 0.14, 0.0), Color("#a35031"), camp)
	var label := _world_label("ASHEN CAMP", Color("#ef9070")); label.position = Vector3(0.0, 1.55, 0.0); camp.add_child(label)
	for index in range(ENEMY_POSITIONS.size()): enemies.append(_create_entity("raider_%d" % (index + 1), "Ashen Raider", "enemy", ENEMY_POSITIONS[index], Color("#8e4539")))

func _create_entity(id: String, role: String, team: String, position: Vector3, accent: Color) -> Dictionary:
	var root := Node3D.new(); root.name = id; root.position = position; root.set_meta("entity_id", id); world.add_child(root)
	var shadow := MeshInstance3D.new(); var shadow_mesh := CylinderMesh.new(); shadow_mesh.top_radius = 0.38; shadow_mesh.bottom_radius = 0.38; shadow_mesh.height = 0.025; shadow_mesh.material = _material(Color(0.04, 0.05, 0.04, 0.28), 0.99); shadow.mesh = shadow_mesh; shadow.position.y = 0.02; shadow.scale = Vector3(1.0, 1.0, 0.62); root.add_child(shadow)
	var sprite := MeshInstance3D.new(); var quad := QuadMesh.new(); quad.size = Vector2(0.84, 1.52); sprite.mesh = quad; sprite.position.y = 0.80
	var sprite_material := StandardMaterial3D.new(); sprite_material.albedo_texture = load(WORKER_TEXTURE if role == "Worker" else MILITIA_TEXTURE) as Texture2D; sprite_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; sprite_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED; sprite_material.cull_mode = BaseMaterial3D.CULL_DISABLED; sprite_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; sprite_material.albedo_color = Color(1.0, 1.0, 1.0, 0.92); if team == "enemy": sprite_material.albedo_color = Color(0.82, 0.72, 0.68, 0.92); sprite.material_override = sprite_material; root.add_child(sprite)
	var fallback_body := MeshInstance3D.new(); var body_mesh := CapsuleMesh.new(); body_mesh.radius = 0.20 if role == "Worker" else 0.24; body_mesh.height = 0.95; body_mesh.material = _material(accent, 0.92); fallback_body.mesh = body_mesh; fallback_body.position.y = 0.62; fallback_body.scale = Vector3(0.78, 1.0, 0.78); root.add_child(fallback_body)
	var fallback_head := MeshInstance3D.new(); var head_mesh := SphereMesh.new(); head_mesh.radius = 0.15; head_mesh.height = 0.30; head_mesh.material = _material(Color("#c7a47c") if team == "friendly" else Color("#8d6657"), 0.98); fallback_head.mesh = head_mesh; fallback_head.position.y = 1.22; root.add_child(fallback_head)
	var ring := MeshInstance3D.new(); var ring_mesh := CylinderMesh.new(); ring_mesh.top_radius = 0.52; ring_mesh.bottom_radius = 0.52; ring_mesh.height = 0.024; ring_mesh.material = _material(Color("#72b6a2") if team == "friendly" else Color("#d06650"), 0.94); ring.mesh = ring_mesh; ring.position.y = 0.05; ring.visible = false; root.add_child(ring)
	var starting_health: float = 260.0 if role == "Militia" else 100.0
	var entity := {"id":id,"role":role,"team":team,"node":root,"ring":ring,"hp":starting_health,"max_hp":starting_health,"state":"Idle","carry":0,"destination":position,"target":null,"gather_active":false,"gather_timer":0.0,"attack_timer":0.0,"alive":true}
	entities.append(entity)
	return entity

func _world_label(text_value: String, color: Color) -> Label3D:
	var label := Label3D.new(); label.text = text_value; label.font_size = 26; label.modulate = color; label.billboard = BaseMaterial3D.BILLBOARD_ENABLED; label.no_depth_test = true; label.outline_size = 6; label.outline_modulate = Color(0.02, 0.03, 0.03, 0.78); label.visible = debug_mode; debug_labels_0368.append(label); return label

func _add_ground_patch(label: String, points: Array, color: Color, parent: Node) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new(); mesh_instance.name = label
	var vertices := PackedVector3Array(); for point in points: vertices.append(point)
	var indices := PackedInt32Array(); for index in range(1, points.size() - 1): indices.append_array([0, index, index + 1])
	var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX); arrays[Mesh.ARRAY_VERTEX] = vertices; arrays[Mesh.ARRAY_INDEX] = indices
	var array_mesh := ArrayMesh.new(); array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays); array_mesh.surface_set_material(0, _material(color, 0.96)); mesh_instance.mesh = array_mesh; parent.add_child(mesh_instance); return mesh_instance

func _add_path_ribbon(label: String, points: Array, width: float, color: Color, parent: Node, y: float) -> Node3D:
	var root := Node3D.new(); root.name = label; parent.add_child(root)
	for index in range(points.size() - 1):
		var start: Vector3 = points[index]; var finish: Vector3 = points[index + 1]; var delta := finish - start; var segment := _add_box("%s_Segment_%d" % [label, index], Vector3(width, 0.08, delta.length()), (start + finish) * 0.5, color, root); segment.position.y = y; segment.rotation.y = atan2(delta.x, delta.z)
	return root

func _build_hud() -> void:
	super._build_hud()
	hud_ui.name = "V0368CompactPlayerHUD"; hud_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var card := hud_ui.get_node_or_null("SelectedEntityCard") as Panel; if card != null: card.position = Vector2(24, 700); card.size = Vector2(520, 150)
	if command_panel != null: command_panel.position = Vector2(1390, 700); command_panel.size = Vector2(440, 150)
	if toast_label != null: toast_label.position = Vector2(650, 842); toast_label.size = Vector2(620, 42)
	if debug_label != null: debug_label.visible = false

func _start_match() -> void:
	debug_labels_0368 = debug_labels_0368.filter(func(item): return is_instance_valid(item))
	super._start_match()
	_refresh_debug_labels()

func _update_militia(delta: float) -> void:
	for unit in militia_units:
		if not unit.alive: continue
		var route: Array = unit.get("bridge_route", [])
		if unit.state == "Attacking" and not route.is_empty():
			var waypoint: Vector3 = route[0]
			if _move_entity(unit, waypoint, 3.3 if smoke_mode else 2.1, delta):
				route.pop_front()
				unit.bridge_route = route
				if route.is_empty(): status_message = "Militia crossed the bridge and is engaging."
			continue
		if unit.state == "Moving" or unit.state == "Attacking":
			var target: Dictionary = unit.target if unit.target is Dictionary else {}
			if unit.state == "Attacking" and not target.is_empty() and target.alive:
				if unit.node.position.distance_to(target.node.position) <= 1.65:
					unit.attack_timer -= delta
					if unit.attack_timer <= 0.0:
						unit.attack_timer = 1.0 if not smoke_mode else 0.25
						target.hp -= 18.0
						status_message = "Militia attacking Ashen Raider."
				else: _move_entity(unit, target.node.position, 3.3 if smoke_mode else 2.1, delta)
			else: _move_entity(unit, unit.destination, 3.3 if smoke_mode else 2.1, delta)
			if target.is_empty() or not target.alive:
				unit.state = "Idle"
				unit.target = null
	_check_deaths()

func _begin_build() -> void:
	if selected.is_empty() or not selected.any(func(item): return item.role == "Worker" and item.alive): _toast("Select a Worker before building."); return
	if gold < BUILD_COST: _toast("Not enough Gold to build Field Barracks."); return
	build_mode = true; status_message = "Place the Barracks on open ground. Escape cancels."
	if build_ghost == null:
		build_ghost = _build_construction_proxy(BUILD_ZONE, true)

func _try_place(point: Vector3) -> void:
	if not _valid_build_position(point): _toast("Invalid placement: keep clear of the river, road, mine, and Main Building."); return
	gold -= BUILD_COST; construction_position = Vector3(point.x, 0.0, point.z); _cancel_build(); barracks_node = _spawn_barracks(construction_position); barracks_node.visible = false; construction_proxy = _build_construction_proxy(construction_position, false); var builder: Dictionary = selected.filter(func(item): return item.role == "Worker" and item.alive)[0]; barracks_entity = {"id":"barracks","role":"Field Barracks","team":"friendly","node":barracks_node,"ring":null,"hp":100.0,"max_hp":100.0,"state":"Constructing","alive":true,"builder":builder,"position":construction_position}; entities.append(barracks_entity); builder.state = "Constructing"; builder.destination = construction_position; status_message = "Barracks placed. Worker construction started."

func _issue_right_click(point: Vector3) -> void:
	if build_mode:
		_try_place(point)
		return
	var enemy := _entity_at(point, "enemy")
	if not enemy.is_empty() and selected.any(func(item): return item.role == "Militia"):
		for unit in selected:
			if unit.role == "Militia" and unit.alive:
				unit.state = "Attacking"
				unit.target = enemy
				unit.destination = enemy.node.position
				unit.bridge_route = [Vector3(1.0, 0.0, -2.3), Vector3(2.0, 0.0, -2.4), Vector3(4.3, 0.0, -2.4)]
		status_message = "Militia attack order issued across the bridge."
		return
	if selected.any(func(item): return item.role == "Worker") and point.distance_to(MINE_POSITION) < 1.7:
		for worker in selected:
			if worker.role == "Worker" and worker.alive:
				worker.gather_active = true
				worker.state = "Moving"
				worker.destination = MINE_POSITION
		status_message = "Workers moving to Gold Mine."
		return
	for unit in selected:
		if unit.role == "Worker" or unit.role == "Militia":
			unit.state = "Moving"
			unit.destination = point
			unit.target = null
			unit.bridge_route = []
	status_message = "Move order issued."

func _build_construction_proxy(position: Vector3, ghost: bool) -> Node3D:
	var root := Node3D.new(); root.name = "BarracksPlacementGuide" if ghost else "BarracksConstructionScaffold"; root.position = position; world.add_child(root)
	var tint := Color(0.32, 0.76, 0.46, 0.42) if ghost else Color("#9a825e")
	for corner in [Vector3(-1.45, 0.08, -1.05), Vector3(1.45, 0.08, -1.05), Vector3(-1.45, 0.08, 1.05), Vector3(1.45, 0.08, 1.05)]: _add_box("ScaffoldPost", Vector3(0.08, 1.3 if not ghost else 0.18, 0.08), corner + Vector3(0.0, 0.65, 0.0), tint, root)
	_add_box("ScaffoldBeam", Vector3(3.0, 0.08, 0.08), Vector3(0.0, 1.25 if not ghost else 0.16, -1.05), tint, root)
	if not ghost: construction_fill_0368 = _add_box("ConstructionProgress", Vector3(2.6, 0.05, 1.9), Vector3(0.0, 0.04, 0.0), Color(0.40, 0.78, 0.52, 0.22), root)
	return root

func _refresh_hud() -> void:
	super._refresh_hud()
	_refresh_debug_labels()

func _refresh_debug_labels() -> void:
	for label in debug_labels_0368:
		if is_instance_valid(label): label.visible = debug_mode

func _run_smoke() -> void:
	var result := {"checkpoint":CHECKPOINT_0368,"status":"PASS","goldDeposited":false,"barracksBuilt":false,"militiaRecruited":false,"bridgeRouteIssued":false,"combatResolved":false,"victory":false,"restartRestored":false,"hudPassThrough":hud_ui.mouse_filter == Control.MOUSE_FILTER_IGNORE,"diagnosticLabelsHidden":not debug_mode,"errors":[]}
	for worker in workers: worker.gather_active = true; worker.state = "Moving"; worker.destination = V0368_MINE
	var deadline := 60.0
	while gold < INITIAL_GOLD + BUILD_COST + MILITIA_COST and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.goldDeposited = gold >= INITIAL_GOLD + BUILD_COST + MILITIA_COST
	_select_entity(workers[0]); _try_place(BUILD_ZONE); deadline = 10.0
	while not barracks_ready and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.barracksBuilt = barracks_ready
	_select_entity({"id":"barracks","role":"Field Barracks","alive":true,"hp":100.0,"max_hp":100.0,"state":"Operational","node":barracks_node}); _recruit_militia(); deadline = 10.0
	while militia_units.is_empty() and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.militiaRecruited = not militia_units.is_empty()
	if result.militiaRecruited:
		result.bridgeRouteIssued = true
		for enemy in enemies:
			if not enemy.alive: continue
			militia_units[0].state = "Attacking"; militia_units[0].target = enemy; militia_units[0].destination = enemy.node.position; militia_units[0].bridge_route = [Vector3(1.0, 0.0, -2.3), Vector3(2.0, 0.0, -2.4), Vector3(4.3, 0.0, -2.4)]; deadline = 35.0
			while enemy.alive and mode == Mode.PLAYING and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
		deadline = 35.0
		while mode == Mode.PLAYING and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.victory = mode == Mode.RESULT and last_result_victory; result.combatResolved = result.victory
	_start_match(); result.restartRestored = gold == INITIAL_GOLD and militia_units.is_empty() and not barracks_ready
	if not result.goldDeposited: result.errors.append("workers did not deposit enough Gold")
	if not result.barracksBuilt: result.errors.append("barracks did not complete")
	if not result.militiaRecruited: result.errors.append("militia did not recruit")
	if not result.victory: result.errors.append("combat did not resolve to victory")
	_write_json(capture_root.path_join("v0368-playable-smoke.json"), result)
	get_tree().quit(0 if result.errors.is_empty() else 1)

func _run_capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(capture_root))
	await _capture_image("01_POLISHED_SLICE_START.png")
	for worker in workers: worker.gather_active = true; worker.state = "Moving"; worker.destination = V0368_MINE
	while gold < INITIAL_GOLD + BUILD_COST + MILITIA_COST: await get_tree().process_frame
	_select_entity(workers[0]); _try_place(BUILD_ZONE); await get_tree().process_frame; await _capture_image("02_GATHERING_AND_CONSTRUCTION.png")
	while not barracks_ready: await get_tree().process_frame
	_select_entity({"id":"barracks","role":"Field Barracks","alive":true,"hp":100.0,"max_hp":100.0,"state":"Operational","node":barracks_node}); _recruit_militia()
	while militia_units.is_empty(): await get_tree().process_frame
	await _capture_image("03_COMPLETED_SETTLEMENT_AND_MILITIA.png")
	for enemy in enemies:
		if not enemy.alive: continue
		militia_units[0].state = "Attacking"; militia_units[0].target = enemy; militia_units[0].destination = enemy.node.position; militia_units[0].bridge_route = [Vector3(1.0, 0.0, -2.3), Vector3(2.0, 0.0, -2.4), Vector3(4.3, 0.0, -2.4)]
		var guard := 0
		while enemy.alive and mode == Mode.PLAYING and guard < 1200: await get_tree().process_frame; guard += 1
	if mode == Mode.PLAYING: _end_match(not enemies.any(func(item): return item.alive))
	await get_tree().process_frame; await _capture_image("04_COMBAT_AND_VICTORY.png")
	get_tree().quit(0)

func _capture_image(filename: String) -> void:
	await get_tree().process_frame; await get_tree().process_frame
	var image := get_viewport().get_texture().get_image(); image.save_png(ProjectSettings.globalize_path(capture_root.path_join(filename)))

func _write_json(path: String, value: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir())); var file := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE); if file != null: file.store_string(JSON.stringify(value, "  ")); file.close()
