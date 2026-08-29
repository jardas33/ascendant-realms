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
	# The default fresh profile intentionally has no spent skill nodes. For the
	# hero presentation cell only, expose the already-authored public abilities
	# so the command-card review can inspect their real UI states without saving
	# or changing progression data.
	if _view in ["hero", "hero_cooldown"] and target is Unit:
		target.abilities = {"rally": 1, "slam": 1}
		target.ability_cd = {"rally": 0.0, "slam": 0.0}
	if _view == "disabled" and _world.player_commander:
		# Fixture-only affordability state for the real disabled presentation.
		# This does not call a gameplay command or persist profile state.
		for kind in ["food", "timber", "stone", "gold"]:
			_world.player_commander.resources[kind] = 0
	_rts._clear_selection()
	_rts._add_to_selection(target)
	_rts.emit_signal("selection_changed", _rts.selected)
	if _view == "placement":
		_rts.enter_build_mode("clanhold")
		if is_instance_valid(_rts._build_ghost):
			_rts._build_ghost.global_position = Vector3(-70.0, 0.0, -90.0)
		for _i in 12: await get_tree().process_frame
	if target is Building:
		_rts.focus_on(target.global_position)
	else:
		_rts.focus_on(target.global_position)
	# World readiness can precede HUD construction while imported portraits and
	# materials finish streaming. Wait for the actual player-facing command
	# surface instead of accepting a world-only frame as UI evidence.
	var hud_ready := false
	var hud_deadline := Time.get_ticks_msec() + 12000
	while Time.get_ticks_msec() < hud_deadline:
		var hud_layer := get_node_or_null("/root/GameRoot/HUDLayer")
		var command_panel := hud_layer.find_child("CommandPanel", true, false) if hud_layer else null
		if is_instance_valid(command_panel) and command_panel.visible and command_panel.get_child_count() > 0:
			hud_ready = true
			break
		await get_tree().process_frame
	if not hud_ready:
		_failures.append("hud_surface_timeout:%s" % _view)
		_write_manifest()
		get_tree().quit(1)
		return
	for _i in 12: await get_tree().process_frame
	var command_panel := get_node_or_null("/root/GameRoot/HUDLayer").find_child("CommandPanel", true, false)
	var command_buttons: Array = command_panel.find_children("*", "Button", true, false) if command_panel else []
	var command_tooltip := get_node_or_null("/root/GameRoot/HUDLayer").find_child("CommandTooltip", true, false)
	var selection_switch_regression := false
	if _view == "selection_switch":
		var switch_targets: Array = [target]
		for unit in get_tree().get_nodes_in_group("units"):
			if unit.team == 0 and not unit.is_worker and not unit.is_hero and not unit.is_dead:
				switch_targets.append(unit)
				break
		for unit in get_tree().get_nodes_in_group("units"):
			if unit.team == 0 and unit.is_hero and not unit.is_dead:
				switch_targets.append(unit)
				break
		for building in _world.all_buildings():
			if building.team == 0 and (bool(building.def.get("is_hq", false)) or building.def.get("kind", "") == "main"):
				switch_targets.append(building)
				break
		if switch_targets.size() < 4:
			_failures.append("selection_switch_targets_missing")
		else:
			Input.warp_mouse(Vector2(20, 20))
			if is_instance_valid(command_tooltip): command_tooltip.hide()
			for switch_target in switch_targets:
				_rts._clear_selection()
				_rts._add_to_selection(switch_target)
				_rts.emit_signal("selection_changed", _rts.selected)
				Input.warp_mouse(Vector2(20, 20))
				for _i in 8: await get_tree().process_frame
				var switched_panel := get_node_or_null("/root/GameRoot/HUDLayer").find_child("CommandPanel", true, false)
				var switched_buttons: Array = switched_panel.find_children("*", "Button", true, false) if switched_panel else []
				if switched_buttons.is_empty():
					_failures.append("selection_switch_command_surface_missing")
			_rts._clear_selection()
			_rts._add_to_selection(target)
			_rts.emit_signal("selection_changed", _rts.selected)
			for _i in 8: await get_tree().process_frame
			command_panel = get_node_or_null("/root/GameRoot/HUDLayer").find_child("CommandPanel", true, false)
			command_buttons = command_panel.find_children("*", "Button", true, false) if command_panel else []
			command_tooltip = get_node_or_null("/root/GameRoot/HUDLayer").find_child("CommandTooltip", true, false)
			selection_switch_regression = _failures.is_empty()
	if _view == "hero_cooldown":
		var cast_button = null
		for command_button in command_buttons:
			if String(command_button.get_meta("command_tooltip_text", "")).contains("Ground Slam"):
				cast_button = command_button
				break
		if cast_button == null:
			_failures.append("missing_public_slam_button")
		else:
			cast_button.pressed.emit()
			for _i in 4: await get_tree().process_frame
			if not target.ability_cd.has("slam") or float(target.ability_cd.get("slam", 0.0)) <= 0.05:
				_failures.append("public_slam_did_not_enter_cooldown")
	if _view == "tooltip":
		var tooltip_button = command_buttons[0] if not command_buttons.is_empty() else null
		if tooltip_button == null or String(tooltip_button.get_meta("command_tooltip_text", "")).is_empty():
			_failures.append("missing_genuine_command_tooltip")
		else:
			Input.warp_mouse(tooltip_button.get_global_rect().get_center())
			# Headless/windowed capture does not always synthesize a hover signal
			# after warp_mouse; exercise the same production signal path directly.
			tooltip_button.mouse_entered.emit()
			for _i in 48: await get_tree().process_frame
			if not is_instance_valid(command_tooltip) or not command_tooltip.visible:
				_failures.append("anchored_command_tooltip_not_visible")
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty(): _failures.append("empty_frame")
	else:
		var command_button_texts: Array[String] = []
		for command_button in command_buttons:
			command_button_texts.append(str(command_button.text))
		var player_commander = _world.player_commander if _world and "player_commander" in _world else null
		var commander_race := str(player_commander.race) if player_commander else ""
		var available_buildings: Array = GameData.buildings_for_race(commander_race) if not commander_race.is_empty() else []
		var png := _output.path_join("%s.png" % OS.get_environment("ASCENDANT_P1R22_NAME")); image.save_png(png)
		_frames.append({"name":OS.get_environment("ASCENDANT_P1R22_NAME"),"view":_view,"png":png,"width":image.get_width(),"height":image.get_height(),"target_id":String(target.unit_id) if "unit_id" in target else String(target.building_id),"target_name":String(target.def.get("name","")),"command_panel_contract":true,"command_button_count":command_buttons.size(),"command_button_texts":command_button_texts,"commander_race":commander_race,"available_building_count":available_buildings.size(),"command_body_child_count":command_panel.get_child_count() if command_panel else 0,"command_tooltip_visible":is_instance_valid(command_tooltip) and command_tooltip.visible,"selection_switch_regression":selection_switch_regression,"hero_ability_review_fixture":_view == "hero"})
	_write_manifest(); get_tree().quit(0 if _failures.is_empty() else 1)

func _pick_target():
	if _view == "worker" or _view == "worker_build" or _view == "tooltip" or _view == "selection_switch":
		for u in get_tree().get_nodes_in_group("units"):
			if u.team == 0 and bool(u.is_worker): return u
	if _view == "military" or _view == "hero" or _view == "hero_cooldown":
		for u in get_tree().get_nodes_in_group("units"):
			if u.team != 0 or u.is_dead: continue
			if (_view == "hero" or _view == "hero_cooldown") and bool(u.is_hero): return u
			if _view == "military" and not bool(u.is_worker) and not bool(u.is_hero): return u
	var buildings: Array = _world.all_buildings() if _world and _world.has_method("all_buildings") else []
	for b in buildings:
		if b.team != 0: continue
		var def: Dictionary = b.def
		if _view == "hq" or _view == "clanhold":
			if bool(def.get("is_hq",false)) or def.get("kind","") == "main": return b
		if _view == "warhall" and (String(def.get("id","")).contains("war_hall") or String(def.get("name","")).to_lower().contains("war hall")): return b
		if _view == "production" and not def.get("produces",[]).is_empty(): return b
		if _view == "research" and (not def.get("research",[]).is_empty() or bool(def.get("is_research",false))): return b
		if _view == "disabled" and not def.get("produces",[]).is_empty(): return b
	if _view == "warhall": return null
	return buildings[0] if not buildings.is_empty() else null

func _write_manifest() -> void:
	var file := FileAccess.open(_output.path_join("command-card-manifest.json"),FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"schema":"ascendant-realms-p1r22-command-card-v1","source_sha":OS.get_environment("ASCENDANT_P1R22_SOURCE_SHA"),"view":_view,"frames":_frames,"failures":_failures,"pass":_failures.is_empty()},"  ")+"\n")
