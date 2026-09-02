extends Node
## Current canonical short-public validation surface.
## Test/dev-only: drives the real production GameRoot/GameWorld route.

const OUT := "res://../../artifacts/current-short-public-capture/"
var root_node: Node
var world: Node
var rts: Node
var worker: Node
var placed: Node
var target := Vector3.ZERO
var phase_file: FileAccess

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	phase_file = FileAccess.open(ProjectSettings.globalize_path(OUT + "phases.jsonl"), FileAccess.WRITE)
	_phase("DRIVER_ENTRY", {"task": "748-R1", "renderer": "Forward Plus"})
	if OS.get_environment("ASCENDANT_CURRENT_SHORT_PUBLIC_CAPTURE") != "1":
		_phase("TERMINAL", {"terminal_reason": "capture_flag_not_enabled", "intended_exit_code": 0})
		return
	_phase("ARTIFACT_ROOT_READY", {"artifact_root": ProjectSettings.globalize_path(OUT)})
	get_node("/root/Match").set_config({
		"player_race": "barrosan", "opponents": [{"race": "vorthak", "difficulty": "normal"}],
		"map": "hollowspan", "start_resources": "standard", "victory": "conquest",
		"mode": "skirmish", "game_speed": 1.0
	})

func _phase(name: String, fields: Dictionary = {}) -> void:
	if phase_file == null:
		return
	var row := {"phase": name, "timestamp": Time.get_datetime_string_from_system(true)}
	row.merge(fields)
	phase_file.store_line(JSON.stringify(row))
	phase_file.flush()

func _capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := OUT + name + ".png"
	image.save_png(ProjectSettings.globalize_path(path))
	_phase(name, {"frame_path": ProjectSettings.globalize_path(path)})

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _wait_for_gameplay() -> bool:
	var loading := get_node_or_null("/root/LoadingScreen")
	var deadline := Time.get_ticks_msec() + 30000
	while loading and loading.visible and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	return not loading or not loading.visible

func _finish(reason: String, code: int) -> void:
	_phase("TERMINAL", {"terminal_reason": reason, "intended_exit_code": code})
	if phase_file:
		phase_file.close()
	get_tree().quit(code)

func _find_worker() -> Node:
	for unit in world.commanders[0].units:
		if is_instance_valid(unit) and unit.is_worker:
			return unit
	return null

func _find_valid_target(hq: Node) -> Vector3:
	rts.enter_build_mode("barrosan_clan_croft")
	var nearest := INF
	var best := Vector3.ZERO
	for x in range(-140, 141, 8):
		for z in range(-140, 141, 8):
			var candidate := Vector3(float(x), 0, float(z))
			var distance := candidate.distance_squared_to(hq.global_position)
			if distance > 22.0 * 22.0 and distance < nearest and rts._is_build_spot_valid(candidate):
				nearest = distance
				best = candidate
	return best

func capture_gameplay(p_root: Node) -> void:
	root_node = p_root
	_phase("PUBLIC_BOOTSTRAP", {"root": "/root/GameRoot"})
	world = root_node.get_node_or_null("GameWorld")
	rts = root_node.get_node_or_null("RTS")
	if world == null or rts == null:
		await _finish("game_root_or_gameworld_missing", 10)
		return
	_phase("GAME_ROOT", {"children": root_node.get_child_count()})
	_phase("GAMEWORLD", {"commanders": world.commanders.size()})
	if not await _wait_for_gameplay():
		await _finish("loading_timeout", 11)
		return
	await _capture("01_GAMEWORLD_READY")
	worker = _find_worker()
	if worker == null:
		await _finish("worker_not_found", 12)
		return
	_phase("WORKER_FOUND", {"worker_id": str(worker.unit_id)})
	rts._clear_selection()
	rts._add_to_selection(worker)
	rts.emit_signal("selection_changed", rts.selected)
	_phase("WORKER_SELECTED", {"worker_id": str(worker.unit_id)})
	await _capture("02_WORKER_SELECTED")
	var hq = world.commanders[0].buildings[0]
	target = _find_valid_target(hq)
	if target == Vector3.ZERO:
		await _finish("valid_build_target_not_found", 13)
		return
	worker.command_move(target)
	_phase("GROUND_MOVE_ISSUED", {"target": {"x": target.x, "z": target.z}})
	await _capture("03_MOVE_ISSUED")
	await _wait(1.5)
	_phase("GROUND_MOVE_OBSERVED", {"position": {"x": worker.global_position.x, "z": worker.global_position.z}})
	rts.enter_build_mode("barrosan_clan_croft")
	_phase("BUILD_MODE_ENTERED", {"building_id": "barrosan_clan_croft"})
	await _capture("04_BUILD_MODE")
	rts._try_place_building_at(target)
	_phase("VALID_PLACEMENT_ISSUED", {"building_id": "barrosan_clan_croft"})
	await _wait(0.5)
	for building in world.commanders[0].buildings:
		if is_instance_valid(building) and building != hq and building.building_id == "barrosan_clan_croft":
			placed = building
			break
	if placed == null:
		await _finish("placement_not_observed", 14)
		return
	await _capture("05_PLACEMENT_ACCEPTED")
	_phase("CONSTRUCTION_STARTED", {"building_id": "barrosan_clan_croft", "is_built": placed.is_built})
	await _capture("06_CONSTRUCTION_STARTED")
	await _capture("07_FINAL")
	_phase("FINAL_FRAME_WRITTEN", {"frame_path": ProjectSettings.globalize_path(OUT + "07_FINAL.png")})
	await _finish("qualified_short_public_route", 0)
