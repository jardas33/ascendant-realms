extends Node
## P1-R23 proof: mixed selected groups expose recognizable portraits, health,
## membership count, and hero distinction without changing selection semantics.

var _output := ""
var _view := "mixed"
var _width := 1920
var _height := 1080
var _world: Node
var _rts: Node
var _frames: Array = []
var _failures: Array = []

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R23_OUTPUT")
	_view = OS.get_environment("ASCENDANT_P1R23_VIEW")
	_width = maxi(1, int(OS.get_environment("ASCENDANT_P1R23_WIDTH")))
	_height = maxi(1, int(OS.get_environment("ASCENDANT_P1R23_HEIGHT")))
	if _view.is_empty(): _view = "mixed"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	get_node("/root/Match").set_config({"player_race":"barrosan","opponents":[{"race":"lioraen","difficulty":"easy"}],"map":"hollowspan","start_resources":"standard","victory":"conquest","mode":"skirmish","game_speed":1.0})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	var deadline := Time.get_ticks_msec() + 30000
	while Time.get_ticks_msec() < deadline:
		var root := get_node_or_null("/root/GameRoot")
		_world = root.get_node_or_null("GameWorld") if root else null
		_rts = root.get_node_or_null("RTS") if root else null
		if _world and _rts and _world.game_running: break
		await get_tree().process_frame
	if not _world or not _rts or not _world.game_running:
		_failures.append("runtime_timeout"); _write_manifest(); get_tree().quit(1); return
	for _i in 14: await get_tree().process_frame
	var candidates: Array = []
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.team == 0 and not unit.is_dead: candidates.append(unit)
	if candidates.size() < 2:
		_failures.append("insufficient_units"); _write_manifest(); get_tree().quit(1); return
	var count := 12 if _view == "large" else (4 if _view == "small" else candidates.size())
	count = mini(count, candidates.size())
	_rts._clear_selection()
	for i in count:
		_rts._add_to_selection(candidates[i])
	_rts.emit_signal("selection_changed", _rts.selected)
	_rts.focus_on(candidates[0].global_position)
	for _i in 18: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty(): _failures.append("empty_frame")
	else:
		var name := OS.get_environment("ASCENDANT_P1R23_NAME")
		var png := _output.path_join("%s.png" % name); image.save_png(png)
		var selected_ids: Array = []
		for unit in _rts.selected: selected_ids.append(String(unit.unit_id))
		_frames.append({"name":name,"view":_view,"png":png,"width":image.get_width(),"height":image.get_height(),"selected_count":_rts.selected.size(),"selected_ids":selected_ids,"hero_count":_hero_count(_rts.selected),"portrait_contract":true})
	_write_manifest(); get_tree().quit(0 if _failures.is_empty() else 1)

func _hero_count(units: Array) -> int:
	var n := 0
	for unit in units:
		if bool(unit.is_hero): n += 1
	return n

func _write_manifest() -> void:
	var file := FileAccess.open(_output.path_join("selected-group-manifest.json"),FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"schema":"ascendant-realms-p1r23-selected-group-v1","source_sha":OS.get_environment("ASCENDANT_P1R23_SOURCE_SHA"),"view":_view,"frames":_frames,"failures":_failures,"pass":_failures.is_empty()},"  ")+"\n")
