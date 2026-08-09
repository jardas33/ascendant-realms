extends Node
## P1-R10 headed proof: building ghosts communicate placement without opaque discs.

var _output := ""
var _width := 1920
var _height := 1080
var _world: Node
var _rts: Node
var _frames: Array = []
var _failures: Array = []
var _before_entities := {}

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R10_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1R10_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1R10_HEIGHT"))
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1-remediation-b/p1r10/default"
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	get_node("/root/Match").set_config({
		"player_race": "barrosan", "opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": "hollowspan", "start_resources": "standard", "victory": "conquest",
		"mode": "skirmish", "game_speed": 1.0
	})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	var deadline := Time.get_ticks_msec() + 20000
	while Time.get_ticks_msec() < deadline:
		var root := get_node_or_null("/root/GameRoot")
		_world = root.get_node_or_null("GameWorld") if root else null
		_rts = root.get_node_or_null("RTS") if root else null
		if _world and _rts and _world.game_running: break
		await get_tree().process_frame
	if not _world or not _rts or not _world.game_running:
		_failures.append("runtime_timeout")
		_write_manifest()
		get_tree().quit(1)
		return
	for _i in 12: await get_tree().process_frame
	_before_entities = _entity_snapshot()
	var base: Vector3 = _world.commanders[0].buildings[0].global_position if not _world.commanders.is_empty() and not _world.commanders[0].buildings.is_empty() else Vector3.ZERO
	# This is intentionally outside the authoritative playable limit. It keeps
	# the red proof deterministic without relying on incidental base/resource
	# occupancy or mutating either one.
	var invalid_pos := Vector3(135.0, 0.0, 135.0)
	_rts.edge_scroll = false
	_rts.focus_on(base)
	for _i in 10: await get_tree().process_frame
	await _capture_ghost("01_SMALL_VALID_GHOST", "barrosan_clan_croft", base + Vector3(24, 0, 0), true)
	await _capture_ghost("02_SMALL_INVALID_GHOST", "barrosan_clan_croft", invalid_pos, false)
	await _capture_ghost("03_LARGE_VALID_GHOST", "barrosan_war_hall", base + Vector3(-26, 0, 0), true)
	await _capture_ghost("04_LARGE_INVALID_GHOST", "barrosan_war_hall", invalid_pos, false)
	_rts.cancel_build_mode()
	get_tree().paused = true
	if _entity_snapshot() != _before_entities: _failures.append("entity_positions_changed")
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _capture_ghost(name: String, building_id: String, pos: Vector3, expected_valid: bool) -> void:
	_rts.set_process(true)
	_rts.enter_build_mode(building_id)
	for _i in 4: await get_tree().process_frame
	if not is_instance_valid(_rts._build_ghost):
		_failures.append(name + ":ghost_missing")
		return
	_rts._build_ghost.global_position = pos
	_rts._build_valid = _rts._is_build_spot_valid(pos)
	if _rts._ghost_mat:
		_rts._ghost_mat.albedo_color = Color(0.3, 0.9, 0.4, 0.28) if _rts._build_valid else Color(0.9, 0.3, 0.3, 0.28)
	_rts.focus_on(pos)
	# Freeze the controller while capturing so its live mouse raycast cannot
	# overwrite the deterministic proof position before the frame is saved.
	_rts.set_process(false)
	for _i in 6: await get_tree().process_frame
	if bool(_rts._build_valid) != expected_valid: _failures.append(name + ":validity_mismatch")
	for _i in 4: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		_failures.append(name + ":empty_frame")
		return
	image.save_png(_output.path_join(name + ".png"))
	_frames.append({"name": name, "png": _output.path_join(name + ".png"), "expected_valid": expected_valid, "actual_valid": bool(_rts._build_valid), "width": image.get_width(), "height": image.get_height()})
	_rts.set_process(true)

func _entity_snapshot() -> Dictionary:
	var out := {}
	if not _world: return out
	for c in _world.commanders:
		for u in c.units:
			if is_instance_valid(u): out["u_" + str(u.get_instance_id())] = _vec(u.global_position)
		for b in c.buildings:
			if is_instance_valid(b): out["b_" + str(b.get_instance_id())] = _vec(b.global_position)
	return out

func _vec(v: Vector3) -> Dictionary:
	return {"x": snappedf(v.x, 0.001), "y": snappedf(v.y, 0.001), "z": snappedf(v.z, 0.001)}

func _write_manifest() -> void:
	var file := FileAccess.open(_output.path_join("build-preview-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"schema": "ascendant-realms-p1r10-build-preview-v1", "source_sha": OS.get_environment("ASCENDANT_P1R10_SOURCE_SHA"), "resolution": {"width": _width, "height": _height}, "frames": _frames, "failures": _failures, "pass": _failures.is_empty()}, "  "))
		file.store_line("")
