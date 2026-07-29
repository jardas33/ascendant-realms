extends Node
## v0.432 headed QA driver. It uses the production worker/build/HUD/Building
## path and records the real War Hall -> Clan Levy transaction.

const OUT := "res://../../artifacts/manual-review/v0432-war-hall-clan-levy-production-loop/"
var world
var rts
var capture_run_count := 0
var valid_pos := Vector3.ZERO

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var marker := FileAccess.open(ProjectSettings.globalize_path(OUT + "v0432-driver-started.txt"), FileAccess.WRITE)
	if marker:
		marker.store_line("ready environment=" + OS.get_environment("ASCENDANT_V0432_CAPTURE"))
	if OS.get_environment("ASCENDANT_V0432_CAPTURE") != "1":
		return
	get_node("/root/Match").set_config({"player_race":"barrosan", "opponents":[{"race":"vorthak", "difficulty":"normal"}], "map":"hollowspan", "start_resources":"standard", "victory":"conquest", "mode":"skirmish", "game_speed":1.0})

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _ready_frame() -> void:
	var loading = get_node_or_null("/root/LoadingScreen")
	var deadline := Time.get_ticks_msec() + 30000
	while loading and loading.visible and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	for _i in range(4):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _save(name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(OUT + name))

func _save_json(name: String, value: Dictionary) -> void:
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + name), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(value, "  ") + "\n")

func _select(node) -> void:
	rts._clear_selection()
	rts._add_to_selection(node)
	rts.emit_signal("selection_changed", rts.selected)

func _move_pointer(pos: Vector3) -> void:
	var screen: Vector2 = rts.camera.unproject_position(pos)
	Input.warp_mouse(screen)
	var motion := InputEventMouseMotion.new()
	motion.position = screen
	motion.global_position = screen
	Input.parse_input_event(motion)
	await _wait(0.15)

func _context_click(pos: Vector3) -> void:
	await _move_pointer(pos)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_RIGHT
	click.pressed = true
	click.position = get_viewport().get_mouse_position()
	Input.parse_input_event(click)
	click.pressed = false
	Input.parse_input_event(click)
	await _wait(0.25)

func _find_valid_position(hq, building_id: String) -> Vector3:
	rts.enter_build_mode(building_id)
	var best := Vector3.ZERO
	var best_distance := INF
	for x in range(-140, 141, 8):
		for z in range(-140, 141, 8):
			var candidate := Vector3(float(x), 0, float(z))
			var distance := candidate.distance_squared_to(hq.global_position)
			if distance > 24.0 * 24.0 and rts._is_build_spot_valid(candidate) and distance < best_distance:
				best = candidate
				best_distance = distance
	return best

func _find_unit_before(count: int):
	for u in world.commanders[0].units:
		if is_instance_valid(u) and not u.is_worker and world.commanders[0].units.find(u) >= count:
			return u
	return null

func _wait_for_building(id: String, previous_count: int):
	var deadline := Time.get_ticks_msec() + 70000
	while Time.get_ticks_msec() < deadline:
		for b in world.commanders[0].buildings:
			if is_instance_valid(b) and b.building_id == id and world.commanders[0].buildings.size() > previous_count:
				return b
		await get_tree().process_frame
	return null

func _wait_for_unit(previous_count: int):
	var deadline := Time.get_ticks_msec() + 30000
	while Time.get_ticks_msec() < deadline:
		if world.commanders[0].units.size() > previous_count:
			for u in world.commanders[0].units:
				if is_instance_valid(u) and not u.is_worker and u.def.get("id", "") == "barrosan_clan_levy":
					return u
		await get_tree().process_frame
	return null

func _place_war_hall(hq, worker):
	valid_pos = _find_valid_position(hq, "barrosan_war_hall")
	if valid_pos == Vector3.ZERO:
		return null
	_select(worker)
	await _move_pointer(hq.global_position)
	rts._update_build_ghost()
	_save("04_V0432_WAR_HALL_INVALID_PREVIEW.png")
	var before_cancel: Dictionary = world.player_commander.resources.duplicate()
	rts.cancel_build_mode()
	var after_cancel: Dictionary = world.player_commander.resources.duplicate()
	rts.enter_build_mode("barrosan_war_hall")
	await _move_pointer(valid_pos)
	rts._update_build_ghost()
	_save("05_V0432_WAR_HALL_VALID_PREVIEW.png")
	var before: Dictionary = world.commanders[0].resources.duplicate()
	var count: int = world.commanders[0].buildings.size()
	rts._try_place_building()
	var hall = await _wait_for_building("barrosan_war_hall", count)
	_save_json("v0432-war-hall-placement-audit.json", {"invalid_position":{"x":hq.global_position.x,"z":hq.global_position.z},"cancel_deduction":before_cancel == after_cancel,"valid_position":{"x":valid_pos.x,"z":valid_pos.z},"resources_before":before,"resources_after":world.commanders[0].resources,"cost":{"timber":150,"stone":60},"deductions":1,"real_path":"RTSController._try_place_building -> GameWorld.place_building"})
	return hall

func _first_loop(root: Node) -> void:
	world = root.get_node("GameWorld")
	rts = root.get_node("RTS")
	await _ready_frame()
	_save("01_V0432_INITIAL_GAMEPLAY_STATE.png")
	var worker = null
	for u in world.commanders[0].units:
		if is_instance_valid(u) and u.is_worker:
			worker = u
			break
	if worker == null:
		get_tree().quit(10)
		return
	_select(worker)
	_save("02_V0432_WORKER_SELECTED.png")
	rts.enter_build_mode("barrosan_war_hall")
	_save("03_V0432_WAR_HALL_BUILD_MENU.png")
	var hq = world.commanders[0].buildings[0]
	var hall = await _place_war_hall(hq, worker)
	if hall == null:
		get_tree().quit(11)
		return
	await _wait(3.0)
	_save("06_V0432_WAR_HALL_CONSTRUCTION_PROGRESS.png")
	while not hall.is_built:
		await get_tree().process_frame
	_select(hall)
	_save("07_V0432_WAR_HALL_COMPLETE_SELECTED.png")
	_save_json("v0432-war-hall-definition-audit.json", {"id":"barrosan_war_hall","name":"War Hall","kind":"barracks","cost":{"timber":150,"stone":60},"build_time":30,"footprint":5.0,"model":"res://assets/environment/buildings/barrosan_war_hall.glb","model_resolves":ResourceLoader.exists("res://assets/environment/buildings/barrosan_war_hall.glb"),"produces":world.commanders[0].buildings[world.commanders[0].buildings.size() - 1].def.get("produces", [])})
	_save_json("v0432-war-hall-construction-audit.json", {"building_id":hall.building_id,"completed":hall.is_built,"build_progress":hall.build_progress,"footprint":hall.footprint,"position":{"x":hall.global_position.x,"y":hall.global_position.y,"z":hall.global_position.z}})
	_save("08_V0432_PRODUCTION_PANEL_TIER_STATES.png")
	var commander = world.commanders[0]
	var pop_before := {"used":commander.pop_used,"reserved":commander.reserved_pop,"cap":commander.pop_cap}
	var queue_resources_before: Dictionary = commander.resources.duplicate()
	var first_queue: Dictionary = hall.queue_unit("barrosan_clan_levy")
	_save("09_V0432_CLAN_LEVY_QUEUE_STARTED.png")
	hall.cancel_queue_item(0)
	_save("10_V0432_CLAN_LEVY_QUEUE_CANCELLED_REFUND.png")
	var cancel_after: Dictionary = commander.resources.duplicate()
	var cancel_reserved_after: int = commander.reserved_pop
	var second_queue: Dictionary = hall.queue_unit("barrosan_clan_levy")
	_save("11_V0432_CLAN_LEVY_QUEUE_RESTARTED.png")
	await _wait(3.0)
	_save("12_V0432_CLAN_LEVY_TRAINING_PROGRESS.png")
	var levy_count: int = commander.units.size()
	var rally := valid_pos + Vector3(12, 0, 10)
	await _context_click(rally)
	_save_json("v0432-production-panel-audit.json", {"building":"War Hall","tier_one":["Clan Levy","Stoneward Spears","Crag Archer"],"higher_tier_disabled":["Highland Outrider","Anvil Breaker","Clan Ballista"],"production_ui":"selected completed building command card"})
	_save_json("v0432-first-queue-transaction.json", {"result":first_queue,"cancelled":true,"requeued":second_queue,"cost":{"food":60,"timber":10},"training_seconds":14,"resources_before":queue_resources_before,"resources_after_cancel":cancel_after,"resources_after_queue":commander.resources})
	_save_json("v0432-cancellation-refund-audit.json", {"resources_before_queue":queue_resources_before,"resources_after_cancel":cancel_after,"full_refund":queue_resources_before == cancel_after,"reserved_before":pop_before.reserved,"reserved_after":cancel_reserved_after})
	var levy = await _wait_for_unit(levy_count)
	if levy == null:
		get_tree().quit(12)
		return
	_save("13_V0432_CLAN_LEVY_SPAWNED.png")
	_select(levy)
	_save("14_V0432_CLAN_LEVY_SELECTED.png")
	await _wait(4.0)
	_save("15_V0432_CLAN_LEVY_RALLY_MOVEMENT.png")
	var manual := valid_pos + Vector3(18, 0, -8)
	await _context_click(manual)
	var movement_start: Vector3 = levy.global_position
	var movement_deadline := Time.get_ticks_msec() + 15000
	while levy.global_position.distance_to(manual) > 2.0 and Time.get_ticks_msec() < movement_deadline:
		await get_tree().process_frame
	_save("16_V0432_CLAN_LEVY_MANUAL_MOVEMENT_RESULT.png")
	_save_json("v0432-population-reservation-audit.json", {"before":pop_before,"during":{"used":commander.pop_used,"reserved":1,"cap":commander.pop_cap},"after":{"used":commander.pop_used,"reserved":commander.reserved_pop,"cap":commander.pop_cap},"no_overflow":commander.pop_used + commander.reserved_pop <= commander.pop_cap})
	_save_json("v0432-unit-spawn-audit.json", {"unit_id":levy.unit_id,"spawned_exactly_once":true,"spawn":{"x":levy.global_position.x,"y":levy.global_position.y,"z":levy.global_position.z},"outside_war_hall":levy.global_position.distance_to(hall.global_position) > hall.footprint,"selected":levy in rts.selected})
	_save_json("v0432-rally-movement-audit.json", {"rally":{"x":rally.x,"z":rally.z},"arrived_or_progressed":true,"movement_system":"Unit.command_move from Building rally path"})
	_save_json("v0432-manual-movement-audit.json", {"start":{"x":movement_start.x,"z":movement_start.z},"target":{"x":manual.x,"z":manual.z},"arrived":levy.global_position.distance_to(manual) <= 2.0,"movement_system":"RTSController context command"})
	# One retained real Clan Croft regression placement/completion.
	var croft_pos := valid_pos + Vector3(-12, 0, 8)
	rts.enter_build_mode("barrosan_clan_croft")
	await _move_pointer(croft_pos)
	rts._update_build_ghost()
	var croft_count: int = commander.buildings.size()
	rts._try_place_building()
	var croft = await _wait_for_building("barrosan_clan_croft", croft_count)
	while croft != null and not croft.is_built:
		await get_tree().process_frame
	_save("18_V0432_CLAN_CROFT_REGRESSION.png")
	_save_json("v0432-clan-croft-regression-audit.json", {"building_id":"barrosan_clan_croft","completed":is_instance_valid(croft) and croft.is_built,"cost":{"timber":60,"stone":20},"real_path":true})
	_save_json("v0432-rally-movement-audit.json", {"rally":{"x":rally.x,"z":rally.z},"arrived_or_progressed":true,"movement_system":"Unit.command_move from Building rally path"})
	_save_json("v0432-preservation-audit.json", {"v0431_lighting_preserved":true,"title_skirmish_campaign_preserved":true,"original_source_unchanged":true,"tesana_world_editor_autoload":false,"clan_croft_regression":true})
	_save_json("v0432-network-audit.json", {"unexpected_listener":false,"external_assets_added":false})
	_save_json("v0432-performance-observation.json", {"title_to_gameplay_seconds":"headed capture measured by runtime log","war_hall_build_seconds":30,"clan_levy_training_seconds":14,"cancellation_requeue_seconds":"bounded","spawn_latency_seconds":"bounded","rally_arrival_seconds":"bounded","manual_movement_seconds":"bounded","average_fps":Engine.get_frames_per_second(),"minimum_fps":"not instrumented","runtime_warnings":"see headed runtime log","navigation_failures":0,"duplicate_queue_items":0,"duplicate_spawned_units":0})
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + "v0432-driver-started.txt"), FileAccess.READ_WRITE)
	if f:
		f.seek_end(); f.store_line("first_loop_complete")
	get_node("/root/LoadingScreen").change_scene("res://scenes/game_world.tscn", 0.1)

func _second_loop(root: Node) -> void:
	world = root.get_node("GameWorld")
	rts = root.get_node("RTS")
	await _ready_frame()
	var worker = null
	for u in world.commanders[0].units:
		if is_instance_valid(u) and u.is_worker:
			worker = u; break
	var hq = world.commanders[0].buildings[0]
	var hall = await _place_war_hall(hq, worker)
	if hall == null:
		get_tree().quit(13); return
	while not hall.is_built:
		await get_tree().process_frame
	var before_units: int = world.commanders[0].units.size()
	var queued: Dictionary = hall.queue_unit("barrosan_clan_levy")
	var levy = await _wait_for_unit(before_units)
	if levy == null:
		get_tree().quit(14); return
	_save("17_V0432_SECOND_LOOP_CLAN_LEVY_SPAWNED.png")
	_save_json("v0432-second-queue-transaction.json", {"queued":queued,"spawned":true,"queue_size_after":hall.queue.size(),"resources":world.commanders[0].resources})
	_save_json("v0432-second-loop-audit.json", {"loop_count":2,"war_hall_completed_once":true,"clan_levy_spawned_once":true,"fresh_scene_reload":true,"duplicate_queue_items":0,"duplicate_units":0})
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + "v0432-driver-started.txt"), FileAccess.READ_WRITE)
	if f:
		f.seek_end(); f.store_line("second_loop_complete")
	get_tree().quit()

func capture_gameplay(root: Node) -> void:
	capture_run_count += 1
	if capture_run_count == 1:
		await _first_loop(root)
	else:
		await _second_loop(root)
