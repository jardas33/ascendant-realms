extends Node
## P1-R9 headed proof: decoration remains characterful while key RTS spaces stay readable.

var _output := ""
var _map_id := "hollowspan"
var _focus_kind := "base"
var _case_name := "01_HOLLOWSPAN_BASE"
var _world: Node
var _rts: Node
var _before_entities := {}
var _failures: Array = []

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R9_OUTPUT")
	_map_id = OS.get_environment("ASCENDANT_P1R9_MAP")
	_focus_kind = OS.get_environment("ASCENDANT_P1R9_FOCUS")
	_case_name = OS.get_environment("ASCENDANT_P1R9_CASE")
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1-remediation-b/p1r9/default"
	if _map_id.is_empty(): _map_id = "hollowspan"
	if _focus_kind.is_empty(): _focus_kind = "base"
	if _case_name.is_empty(): _case_name = "01_HOLLOWSPAN_BASE"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_node("/root/Match").set_config({
		"player_race": "barrosan", "opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": _map_id, "start_resources": "standard", "victory": "conquest",
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
	var focus := _find_focus()
	_rts.edge_scroll = false
	_rts.focus_on(focus)
	for _i in 12: await get_tree().process_frame
	get_tree().paused = true
	var after := _entity_snapshot()
	if after != _before_entities: _failures.append("entity_positions_changed")
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		_failures.append("empty_frame")
	else:
		image.save_png(_output.path_join(_case_name + ".png"))
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _find_focus() -> Vector3:
	if _focus_kind == "center": return Vector3.ZERO
	if _focus_kind == "resource":
		var resources := get_tree().get_nodes_in_group("resources")
		if not resources.is_empty(): return resources[0].global_position
	if _focus_kind == "site":
		var sites := get_tree().get_nodes_in_group("capture_points")
		if not sites.is_empty(): return sites[0].global_position
	if _world.commanders.size() > 0 and not _world.commanders[0].buildings.is_empty():
		return _world.commanders[0].buildings[0].global_position
	return Vector3.ZERO

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
	var file := FileAccess.open(_output.path_join("space-readability-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"schema": "ascendant-realms-p1r9-space-readability-v1",
			"source_sha": OS.get_environment("ASCENDANT_P1R9_SOURCE_SHA"),
			"map": _map_id, "focus": _focus_kind, "case": _case_name,
			"png": _output.path_join(_case_name + ".png"),
			"entity_positions_unchanged": _failures.find("entity_positions_changed") < 0,
			"failures": _failures, "pass": _failures.is_empty()
		}, "  "))
		file.store_line("")
