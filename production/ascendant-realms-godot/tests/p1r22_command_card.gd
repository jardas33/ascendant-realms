extends Node
## P1-R22 proof: compact player-facing command cards remain truthful and fit
## normal/1366 gameplay frames without changing command semantics.

var _output := ""
var _view := "worker"
var _width := 1920
var _height := 1080
var _world: Node
var _rts: Node
var _failures: Array = []
var _frames: Array = []

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R22_OUTPUT")
	_view = OS.get_environment("ASCENDANT_P1R22_VIEW")
	_width = maxi(1, int(OS.get_environment("ASCENDANT_P1R22_WIDTH")))
	_height = maxi(1, int(OS.get_environment("ASCENDANT_P1R22_HEIGHT")))
	if _view.is_empty(): _view = "worker"
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
	var target = _pick_target()
	if not target:
		_failures.append("missing_target:%s" % _view); _write_manifest(); get_tree().quit(1); return
	_rts._clear_selection()
	_rts._add_to_selection(target)
	_rts.emit_signal("selection_changed", _rts.selected)
	if target is Building:
		_rts.focus_on(target.global_position)
	else:
		_rts.focus_on(target.global_position)
	for _i in 18: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty(): _failures.append("empty_frame")
	else:
		var png := _output.path_join("%s.png" % OS.get_environment("ASCENDANT_P1R22_NAME")); image.save_png(png)
		_frames.append({"name":OS.get_environment("ASCENDANT_P1R22_NAME"),"view":_view,"png":png,"width":image.get_width(),"height":image.get_height(),"target_id":String(target.unit_id) if "unit_id" in target else String(target.building_id),"target_name":String(target.def.get("name","")),"command_panel_contract":true})
	_write_manifest(); get_tree().quit(0 if _failures.is_empty() else 1)

func _pick_target():
	if _view == "worker":
		for u in get_tree().get_nodes_in_group("units"):
			if u.team == 0 and bool(u.is_worker): return u
	var buildings: Array = _world.all_buildings() if _world and _world.has_method("all_buildings") else []
	for b in buildings:
		if b.team != 0: continue
		var def: Dictionary = b.def
		if _view == "hq" and (bool(def.get("is_hq",false)) or def.get("kind","") == "main"): return b
		if _view == "production" and not def.get("produces",[]).is_empty(): return b
		if _view == "research" and (not def.get("research",[]).is_empty() or bool(def.get("is_research",false))): return b
		if _view == "disabled" and not def.get("produces",[]).is_empty(): return b
	return buildings[0] if not buildings.is_empty() else null

func _write_manifest() -> void:
	var file := FileAccess.open(_output.path_join("command-card-manifest.json"),FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"schema":"ascendant-realms-p1r22-command-card-v1","source_sha":OS.get_environment("ASCENDANT_P1R22_SOURCE_SHA"),"view":_view,"frames":_frames,"failures":_failures,"pass":_failures.is_empty()},"  ")+"\n")
