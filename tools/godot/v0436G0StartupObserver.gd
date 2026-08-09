extends SceneTree

## G0 tool-owned startup observer. It never writes gameplay state beyond the
## same match configuration used by the existing opt-in startup path. Modes:
## A = menu-equivalent path, B = direct automated loader path, C = F2 hook path.

const CONFIG := {
	"player_race": "barrosan",
	"opponents": [{"race": "lioraen", "difficulty": "easy"}],
	"map": "hollowspan",
	"start_resources": "rich",
	"victory": "conquest",
	"mode": "skirmish",
	"game_speed": 2.0,
}

var _mode := "B"
var _out := "D:/CodexData/evidence/ascendant-realms-runtime-startup-g0/"
var _started_ms := 0
var _last_sample_ms := -1
var _last_scene := ""
var _last_script := ""
var _last_progress := -1.0
var _last_busy := false
var _last_preloaded := false
var _menu_driven := false
var _setup_driven := false
var _game_root_seen := false
var _game_world_seen := false
var _hud_seen := false
var _first_frame_seen := false
var _loading_entered_captured := false
var _loading_progress_captured := false
var _game_world_capture_scheduled := false
var _final_capture_scheduled := false
var _finished := false
var _events: Array = []

func _initialize() -> void:
	_mode = OS.get_environment("ASCENDANT_G0_MODE")
	if _mode != "A" and _mode != "B" and _mode != "C":
		_mode = "B"
	var configured_out := OS.get_environment("ASCENDANT_G0_OUT")
	if configured_out != "":
		_out = configured_out
	if not _out.ends_with("/"):
		_out += "/"
	DirAccess.make_dir_recursive_absolute(_out)
	_started_ms = Time.get_ticks_msec()
	_record("observer_started", {"mode": _mode, "source": OS.get_environment("ASCENDANT_G0_SOURCE_SHA"), "branch": OS.get_environment("ASCENDANT_G0_BRANCH")})
	process_frame.connect(_tick)
	call_deferred("_begin")

func _begin() -> void:
	if _mode == "A":
		_record("ordinary_main_scene_requested", {})
		change_scene_to_file("res://scenes/main.tscn")
		return
	var match_config = get_root().get_node_or_null("Match")
	if match_config == null:
		_finish("BLOCKED_G0_MATCH_CONFIG_UNAVAILABLE")
		return
	match_config.set_config(CONFIG.duplicate(true))
	_record("automated_match_configured", {"configuration": match_config.get_config().duplicate(true), "capture_hook": _mode == "C"})
	var loading = get_root().get_node_or_null("LoadingScreen")
	if loading == null:
		_finish("BLOCKED_G0_LOADING_SCREEN_UNAVAILABLE")
		return
	_record("loading_requested", {"path": "res://scenes/game_world.tscn", "mode": _mode})
	loading.preload_and_change_scene("res://scenes/game_world.tscn", 0.1)

func _tick() -> void:
	if _finished:
		return
	var now := Time.get_ticks_msec()
	var elapsed := float(now - _started_ms) / 1000.0
	var scene := current_scene
	var scene_name := String(scene.name) if is_instance_valid(scene) else ""
	var script_path := ""
	if is_instance_valid(scene) and scene.get_script() != null:
		script_path = String(scene.get_script().resource_path)
	if scene_name != _last_scene or script_path != _last_script:
		_last_scene = scene_name
		_last_script = script_path
		_record("scene_changed", {"scene": scene_name, "script": script_path, "elapsed_s": elapsed})

	var loading = get_root().get_node_or_null("LoadingScreen")
	if loading != null:
		var busy := bool(loading.get("_busy"))
		var progress := 0.0
		var progress_bar = loading.get("_progress")
		if progress_bar is ProgressBar:
			progress = float(progress_bar.value)
		var preloaded := bool(loading.get("_preloaded"))
		if busy != _last_busy or preloaded != _last_preloaded or absf(progress - _last_progress) >= 0.01 or now - _last_sample_ms >= 1000:
			_last_busy = busy
			_last_preloaded = preloaded
			_last_progress = progress
			_last_sample_ms = now
			var cache = loading.get("_cache")
			_record("loader_sample", {"busy": busy, "progress": progress, "preloaded": preloaded, "cache_size": cache.size() if cache is Dictionary else -1, "elapsed_s": elapsed})
		if busy and not _loading_entered_captured:
			_loading_entered_captured = true
			_capture("02_LOADING_ENTERED.png")
		if busy and progress >= 0.5 and not _loading_progress_captured:
			_loading_progress_captured = true
			_capture("03_LOADING_PROGRESS.png")

	if is_instance_valid(scene) and (scene_name == "Main" or scene_name == "MainMenu") and not _menu_driven:
		_menu_driven = true
		_capture("01_MAIN_MENU.png")
		call_deferred("_drive_main_menu", scene)
	if is_instance_valid(scene) and scene_name == "SkirmishSetup" and not _setup_driven:
		_setup_driven = true
		call_deferred("_drive_setup", scene)
	if is_instance_valid(scene) and scene_name == "GameRoot":
		if not _game_root_seen:
			_game_root_seen = true
			_record("game_root_ready", {"elapsed_s": elapsed})
		var world = scene.get_node_or_null("GameWorld")
		if is_instance_valid(world) and not _game_world_seen:
			_game_world_seen = true
			_record("game_world_ready", {"elapsed_s": elapsed, "game_running": bool(world.get("game_running"))})
			if not _game_world_capture_scheduled:
				_game_world_capture_scheduled = true
				call_deferred("_capture_after_loader_settle", "04_GAMEWORLD_%s.png" % ("F2_HARNESS" if _mode == "C" else ("ORDINARY_RUN1" if _mode == "A" else "AUTOMATED")), false)
		var hud_layer = scene.get_node_or_null("HUDLayer")
		var hud_ready := is_instance_valid(hud_layer) and hud_layer.get_child_count() > 0
		if hud_ready and not _hud_seen:
			_hud_seen = true
			_record("hud_ready", {"elapsed_s": elapsed})
		if _game_world_seen and _hud_seen and not _first_frame_seen:
			_first_frame_seen = true
			_record("first_playable_frame", {"elapsed_s": elapsed, "hud_ready": _hud_seen, "game_running": bool(world.get("game_running"))})
			if not _final_capture_scheduled:
				_final_capture_scheduled = true
				call_deferred("_capture_after_loader_settle", "07_FIRST_PLAYABLE_HUD.png", true)
	if elapsed >= 900.0 if _mode == "A" else elapsed >= 600.0:
		_finish("BLOCKED_G0_STARTUP_TIMEOUT_NO_GAMEWORLD")

func _drive_main_menu(menu: Node) -> void:
	await process_frame
	if is_instance_valid(menu) and menu.has_method("_on_skirmish"):
		_record("ordinary_skirmish_clicked", {})
		menu.call("_on_skirmish")

func _drive_setup(setup: Node) -> void:
	await process_frame
	if not is_instance_valid(setup):
		return
	setup.set("_player_race", "barrosan")
	setup.set("_res_kind", "rich")
	setup.set("_victory", "conquest")
	setup.set("_game_speed", 2.0)
	setup.set("_map_id", "hollowspan")
	var rows = setup.get("_opp_rows")
	var game_data = get_root().get_node_or_null("GameData")
	var race_ids: Array = game_data.RACES.keys() if game_data != null else []
	var lioraen_index := race_ids.find("lioraen")
	if rows is Array and not rows.is_empty() and lioraen_index >= 0:
		var race_opt = rows[0].get("race")
		var diff_opt = rows[0].get("diff")
		if race_opt != null:
			race_opt.select(lioraen_index)
		if diff_opt != null:
			diff_opt.select(0)
	_record("ordinary_skirmish_configured", {"configuration": CONFIG.duplicate(true)})
	if setup.has_method("_on_begin"):
		_record("ordinary_start_battle_clicked", {})
		setup.call("_on_begin")

func _capture(name: String) -> void:
	if get_root().get_viewport() == null:
		return
	var image := get_root().get_viewport().get_texture().get_image()
	image.save_png(_out + name)
	_record("screenshot", {"name": name})

func _capture_after_loader_settle(name: String, finish_after: bool) -> void:
	await process_frame
	var settled := false
	var settle_frames := 0
	for frame in range(300):
		settle_frames = frame + 1
		var loading = get_root().get_node_or_null("LoadingScreen")
		var busy := bool(loading.get("_busy")) if loading != null else false
		if not busy and frame >= 2:
			settled = true
			break
		await process_frame
	_record("playable_settled", {"name": name, "settled": settled, "settle_frames": settle_frames})
	_capture(name)
	if finish_after:
		_finish("PASSED_G0_STARTUP_REACHED_GAMEWORLD" if settled else "BLOCKED_G0_LOADER_DID_NOT_SETTLE_AFTER_GAMEWORLD")

func _record(kind: String, payload: Dictionary) -> void:
	var item := {"kind": kind, "timestamp_ms": Time.get_ticks_msec(), "elapsed_s": float(Time.get_ticks_msec() - _started_ms) / 1000.0}
	for key in payload.keys():
		item[key] = payload[key]
	_events.append(item)
	var events_path := _out + "startup-events.jsonl"
	var file := FileAccess.open(events_path, FileAccess.READ_WRITE if FileAccess.file_exists(events_path) else FileAccess.WRITE)
	if file != null:
		file.seek_end()
		file.store_line(JSON.stringify(item))
		file.close()

func _finish(status: String) -> void:
	if _finished:
		return
	_finished = true
	var result := {"schema": "v0436-g0-startup-observation-v1", "status": status, "mode": _mode, "source_sha": OS.get_environment("ASCENDANT_G0_SOURCE_SHA"), "branch": OS.get_environment("ASCENDANT_G0_BRANCH"), "godot": OS.get_environment("ASCENDANT_REALMS_GODOT"), "started_ms": _started_ms, "finished_ms": Time.get_ticks_msec(), "game_root_seen": _game_root_seen, "game_world_seen": _game_world_seen, "hud_seen": _hud_seen, "first_playable_frame_seen": _first_frame_seen, "event_count": _events.size()}
	var file := FileAccess.open(_out + "startup-manifest.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(result, "  ") + "\n")
		file.close()
	quit(0)
