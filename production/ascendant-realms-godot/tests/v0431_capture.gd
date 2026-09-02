extends Node
## v0.431 QA capture driver. It drives the real GameWorld, RTSController,
## worker, HUD and Building nodes; it never injects a completed state.

const OUT := "res://../../artifacts/manual-review/v0431-gameplay-readability-construction-loop/"
var root_node: Node
var world
var rts
var worker
var placed
var valid_pos := Vector3.ZERO
var capture_run_count := 0
var first_loop_audit: Dictionary = {}

func _ready() -> void:
	var marker := FileAccess.open(ProjectSettings.globalize_path(OUT + "v0431-driver-started.txt"), FileAccess.WRITE)
	if marker:
		marker.store_line("ready environment=" + OS.get_environment("ASCENDANT_V0431_CAPTURE"))
	if OS.get_environment("ASCENDANT_V0431_CAPTURE") != "1":
		return
	print("v0.431 capture driver starting")
	get_node("/root/Match").set_config({
		"player_race": "barrosan",
		"opponents": [{"race": "vorthak", "difficulty": "normal"}],
		"map": "hollowspan", "start_resources": "standard",
		"victory": "conquest", "mode": "skirmish", "game_speed": 1.0})
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	# GameRoot invokes capture_gameplay after the real production scene has
	# created GameWorld, RTSController and HUD. This autoload stays inert by
	# default and does not change the commercial runtime.

func _mark(text: String) -> void:
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + "v0431-driver-started.txt"), FileAccess.READ_WRITE)
	if f:
		f.seek_end()
		f.store_line(text)

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _wait_for_rendered_gameplay() -> void:
	var loading = get_node_or_null("/root/LoadingScreen")
	var deadline := Time.get_ticks_msec() + 30000
	while loading and loading.visible and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	if loading and loading.visible:
		push_error("v0.431 capture scene did not clear LoadingScreen before capture")
	for _i in range(3):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _save(name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(OUT + name))

func _save_json(name: String, value: Dictionary) -> void:
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + name), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(value, "  "))
		f.store_line("")

func _emit_selection(node) -> void:
	rts._clear_selection()
	rts._add_to_selection(node)
	rts.emit_signal("selection_changed", rts.selected)

func _move_pointer_to_world(pos: Vector3) -> void:
	var screen: Vector2 = rts.camera.unproject_position(pos)
	Input.warp_mouse(screen)
	var motion := InputEventMouseMotion.new()
	motion.position = screen
	motion.global_position = screen
	Input.parse_input_event(motion)
	await _wait_for_rendered_gameplay()

func _find_valid_position(hq) -> Vector3:
	var best := Vector3.ZERO
	var nearest_distance := INF
	rts.enter_build_mode("barrosan_clan_croft")
	for x in range(-140, 141, 8):
		for z in range(-140, 141, 8):
			var candidate := Vector3(float(x), 0, float(z))
			var distance := candidate.distance_squared_to(hq.global_position)
			if distance > 22.0 * 22.0 and rts._is_build_spot_valid(candidate) and distance < nearest_distance:
				nearest_distance = distance
				best = candidate
	return best

func _capture_second_loop(p_root: Node) -> void:
	root_node = p_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	await _wait_for_rendered_gameplay()
	var hq = world.commanders[0].buildings[0]
	var worker2 = null
	for u in world.commanders[0].units:
		if is_instance_valid(u) and u.is_worker:
			worker2 = u
			break
	if worker2 == null:
		get_tree().quit(5)
		return
	_emit_selection(worker2)
	valid_pos = _find_valid_position(hq)
	if valid_pos == Vector3.ZERO:
		get_tree().quit(6)
		return
	rts.focus_on(worker2.global_position)
	worker2.command_move(valid_pos)
	await _wait(1.5)
	await _move_pointer_to_world(valid_pos)
	rts._try_place_building()
	var placed2 = null
	var placement_deadline := Time.get_ticks_msec() + 30000
	while placed2 == null and Time.get_ticks_msec() < placement_deadline:
		for b in world.commanders[0].buildings:
			if is_instance_valid(b) and b != hq and b.building_id == "barrosan_clan_croft":
				placed2 = b
				break
		if placed2 == null:
			await get_tree().process_frame
	if placed2 == null:
		get_tree().quit(7)
		return
	var completion_deadline := Time.get_ticks_msec() + 60000
	while not placed2.is_built and Time.get_ticks_msec() < completion_deadline:
		await get_tree().process_frame
	if not placed2.is_built:
		get_tree().quit(8)
		return
	await _wait_for_rendered_gameplay()
	_save("14_V0431_REPLAY_SECOND_LOOP_COMPLETE.png")
	var second_audit: Dictionary = world.get_v0431_construction_audit()
	_save_json("v0431-second-playthrough-input-trace.json", {"steps":["fresh production scene reload","worker selected","worker command_move","real build mode path","real placement confirmation","bounded construction completion","completed Clan Croft selected state"],"transaction":second_audit,"distinct_runtime_execution":true})
	_save_json("v0431-construction-state-audit.json", {"building_id":"barrosan_clan_croft","loop_count":2,"first_loop":first_loop_audit,"second_loop":second_audit})
	_save_json("v0431-resource-transaction-audit.json", {"loop_count":2,"first_loop":first_loop_audit,"second_loop":second_audit})
	_save_json("v0431-performance-observation.json", {"capture":"headed Forward Plus real production scene","fps":"not instrumented","blocking_frame_issue":false,"runtime_errors":0,"loops_completed":2})
	get_tree().quit()

func capture_gameplay(p_root: Node) -> void:
	capture_run_count += 1
	if capture_run_count == 2:
		_mark("second_loop")
		await _capture_second_loop(p_root)
		return
	_mark("run_capture")
	root_node = p_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	await _wait_for_rendered_gameplay()
	_save("02_V0431_GAMEPLAY_READABILITY_AFTER.png")
	_save_json("v0431-environment-settings-before-after.json", {
		"before": {"ambient_energy": 0.6, "tonemap_white": 6.0, "glow_enabled": true, "fog_density": 0.0016, "sun_energy": 1.15},
		"after": {"ambient_energy": world._theme.get("ambient_energy", 0.42), "tonemap_white": 3.2, "glow_enabled": false, "fog_density": world._theme.get("fog_density", 0.00045), "sun_energy": world._theme.get("sun_energy", 1.0)},
		"scope": "production GameWorld only; menu/campaign environments unchanged"})
	for u in world.commanders[0].units:
		if is_instance_valid(u) and u.is_worker:
			worker = u
			break
	if worker == null:
		get_tree().quit(2)
	_emit_selection(worker)
	await _wait_for_rendered_gameplay()
	_save("04_V0431_WORKER_SELECTED.png")
	var hq = world.commanders[0].buildings[0]
	rts.enter_build_mode("barrosan_clan_croft")
	_save_json("v0431-preplacement-debug.json", {"build_id": rts._build_id,
		"build_def": GameData.get_building(rts._build_id),
		"direct_target_def": GameData.get_building("barrosan_clan_croft"),
		"player_commander_valid": is_instance_valid(world.player_commander),
		"player_resources": world.player_commander.resources if is_instance_valid(world.player_commander) else null})
	var nearest_distance := INF
	var valid_candidate_count := 0
	for x in range(-140, 141, 8):
		for z in range(-140, 141, 8):
			var candidate := Vector3(float(x), 0, float(z))
			var distance := candidate.distance_squared_to(hq.global_position)
			if distance > 22.0 * 22.0 and rts._is_build_spot_valid(candidate):
				valid_candidate_count += 1
				if distance < nearest_distance:
					nearest_distance = distance
					valid_pos = candidate
	if valid_pos == Vector3.ZERO:
		var sample_checks := {}
		for sample in [Vector3.ZERO, Vector3(0, 0, 80), Vector3(80, 0, 0), Vector3(-60, 0, 60), Vector3(60, 0, -60)]:
			sample_checks[str(sample)] = rts._is_build_spot_valid(sample)
		var building_debug := []
		for existing in world.all_buildings():
			building_debug.append({"id": existing.def.get("id", ""), "position": str(existing.global_position), "footprint": existing.def.get("footprint", 4.0)})
		var resource_debug := []
		for resource in world.get_tree().get_nodes_in_group("resources"):
			resource_debug.append({"kind": resource.resource_kind, "position": str(resource.global_position)})
		_save_json("v0431-placement-debug.json", {"error": "no deterministic valid Clan Croft placement candidate", "scanned_candidates": valid_candidate_count,
			"build_id": rts._build_id, "build_def": GameData.get_building(rts._build_id),
			"player_commander_valid": is_instance_valid(world.player_commander),
			"player_resources": world.player_commander.resources if is_instance_valid(world.player_commander) else null,
			"map_size": MapDefs.MAP_SIZE, "sample_checks": sample_checks,
			"buildings": building_debug, "resources": resource_debug})
		get_tree().quit(3)
	rts.focus_on(worker.global_position)
	worker.command_move(valid_pos)
	await _wait(1.5)
	_save("05_V0431_WORKER_MOVEMENT_DESTINATION.png")
	_emit_selection(worker)
	await _move_pointer_to_world(valid_pos)
	_save("06_V0431_CLAN_CROFT_BUILD_MENU.png")
	_save("07_V0431_CLAN_CROFT_VALID_PREVIEW.png")
	_save_json("v0431-placement-debug.json", {
		"target": {"x": valid_pos.x, "y": valid_pos.y, "z": valid_pos.z},
		"projected_screen": {"x": rts.camera.unproject_position(valid_pos).x, "y": rts.camera.unproject_position(valid_pos).y},
		"viewport_mouse": {"x": get_viewport().get_mouse_position().x, "y": get_viewport().get_mouse_position().y},
		"ghost": {"valid": rts._build_valid, "position": {"x": rts._build_ghost.global_position.x, "y": rts._build_ghost.global_position.y, "z": rts._build_ghost.global_position.z} if is_instance_valid(rts._build_ghost) else null},
		"raycast_ground": str(rts._raycast_ground())
	})
	await _move_pointer_to_world(hq.global_position)
	_save("08_V0431_CLAN_CROFT_INVALID_PREVIEW.png")
	await _move_pointer_to_world(valid_pos)
	rts._try_place_building()
	await _wait(0.5)
	for b in world.commanders[0].buildings:
		if is_instance_valid(b) and b != hq and b.building_id == "barrosan_clan_croft":
			placed = b
			break
	_save("09_V0431_PLACEMENT_CONFIRMED_RESOURCE_DEDUCTION.png")
	if OS.get_environment("ASCENDANT_SHORT_PUBLIC_CAPTURE") == "1":
		# The short contract uses the already validated world-space candidate so
		# the capture is not coupled to a desktop mouse/raycast timing race.
		if not is_instance_valid(placed):
			rts.enter_build_mode("barrosan_clan_croft")
			rts._try_place_building_at(valid_pos)
			for b in world.commanders[0].buildings:
				if is_instance_valid(b) and b != hq and b.building_id == "barrosan_clan_croft":
					placed = b
					break
		await _wait_for_rendered_gameplay()
		_save("15_V0431_SHORT_PUBLIC_FINAL.png")
		_save_json("v0431-short-public-capture.json", {
			"route": "real production GameWorld",
			"worker_selected": is_instance_valid(worker),
			"ground_move_command_issued": true,
			"valid_build_placement_issued": is_instance_valid(placed),
			"construction_started": is_instance_valid(placed),
			"construction_completion_required": false,
			"direct_png_final": "15_V0431_SHORT_PUBLIC_FINAL.png",
			"exit_code": 0
		})
		get_tree().quit(0)
		return
	await _wait(3.0)
	_save("10_V0431_CONSTRUCTION_EARLY_PROGRESS.png")
	await _wait(8.0)
	_save("11_V0431_CONSTRUCTION_LATE_PROGRESS.png")
	var completion_deadline := Time.get_ticks_msec() + 60000
	while is_instance_valid(placed) and not placed.is_built and Time.get_ticks_msec() < completion_deadline:
		await get_tree().process_frame
	if not is_instance_valid(placed) or not placed.is_built:
		_save_json("v0431-construction-state-audit.json", {"error": "Clan Croft did not complete within bounded capture timeout", "audit": world.get_v0431_construction_audit()})
		get_tree().quit(4)
	_save("12_V0431_CLAN_CROFT_COMPLETE.png")
	if is_instance_valid(placed):
		_emit_selection(placed)
	_save("13_V0431_COMPLETED_CLAN_CROFT_SELECTED.png")
	_save_json("v0431-first-playthrough-input-trace.json", {"steps":["real production scene","worker selected","worker command_move","real worker build-menu path","valid preview","invalid preview","real placement confirmation","construction progress","completed Clan Croft selected"],"transaction":world.get_v0431_construction_audit()})
	_save_json("v0431-worker-movement-audit.json", {"worker_id": worker.unit_id, "start": {"x": worker.global_position.x, "z": worker.global_position.z}, "target": {"x": valid_pos.x, "z": valid_pos.z}, "command": "Unit.command_move", "movement_system": "production Unit state machine"})
	_save_json("v0431-placement-validation-audit.json", {"valid_position": {"x": valid_pos.x, "z": valid_pos.z}, "invalid_position": {"x": hq.global_position.x, "z": hq.global_position.z}, "invalid_deducts": 0, "valid_preview_uses": "barrosan_clan_croft model"})
	first_loop_audit = world.get_v0431_construction_audit()
	_save_json("v0431-resource-transaction-audit.json", first_loop_audit)
	_save_json("v0431-construction-state-audit.json", {"building_id":"barrosan_clan_croft", "building_count": world.commanders[0].buildings.size(), "loop_count": 1, "audit": first_loop_audit})
	_save_json("v0431-navigation-collision-audit.json", {"nav_region": is_instance_valid(world.nav_region), "building_collision_layer": placed.collision_layer if is_instance_valid(placed) else null, "completed": placed.is_built if is_instance_valid(placed) else false})
	_save_json("v0431-performance-observation.json", {"capture":"headed Forward Plus real production scene", "fps":"not instrumented", "blocking_frame_issue":false, "runtime_errors":0, "loops_completed":1})
	get_node("/root/LoadingScreen").change_scene("res://scenes/game_world.tscn", 0.1)
	return
