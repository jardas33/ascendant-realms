extends Node
## P1 LOAD-01 capture-only observer. Disabled unless ASCENDANT_P1_LOAD01=1.
## It records the real startup path without changing gameplay state or saves.

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
var _out := "D:/CodexData/evidence/ascendant-realms-p1-load-01/"
var _started_ms := 0
var _last_scene := ""
var _last_busy := false
var _events: Array = []
var _phases := {}
var _finished := false
var _menu_driven := false
var _setup_driven := false
var _capture_written := false
var _deadline_s := 180.0

func _ready() -> void:
	if OS.get_environment("ASCENDANT_P1_LOAD01") != "1":
		set_process(false)
		return
	_mode = OS.get_environment("ASCENDANT_P1_LOAD01_MODE")
	if _mode != "A" and _mode != "B":
		_mode = "B"
	var configured_out := OS.get_environment("ASCENDANT_P1_LOAD01_OUT")
	if configured_out != "":
		_out = configured_out
	if not _out.ends_with("/"):
		_out += "/"
	DirAccess.make_dir_recursive_absolute(_out)
	_started_ms = Time.get_ticks_msec()
	_record("observer_started", {"mode": _mode, "source_sha": OS.get_environment("ASCENDANT_P1_LOAD01_SOURCE_SHA"), "branch": OS.get_environment("ASCENDANT_P1_LOAD01_BRANCH")})
	get_tree().process_frame.connect(_tick)
	call_deferred("_begin")

func _begin() -> void:
	if _mode == "A":
		_mark_phase("T0_PLAYER_INITIATED_SKIRMISH", "waiting_for_main_menu")
		get_tree().change_scene_to_file("res://scenes/main.tscn")
		return
	var match_config = get_node_or_null("/root/Match")
	var loading = get_node_or_null("/root/LoadingScreen")
	if match_config == null or loading == null:
		_finish("BLOCKED_LOAD01_RUNTIME_AUTOLOAD_UNAVAILABLE")
		return
	match_config.set_config(CONFIG.duplicate(true))
	_mark_phase("T0_PLAYER_INITIATED_SKIRMISH", "configured_match_equivalent")
	_record("match_configured", {"configuration": CONFIG.duplicate(true)})
	_mark_phase("T1_LOAD_TRANSITION_BEGIN", "loading_screen_requested")
	loading.preload_and_change_scene("res://scenes/game_world.tscn", 0.1)

func _tick() -> void:
	if _finished:
		return
	var now := Time.get_ticks_msec()
	var elapsed := float(now - _started_ms) / 1000.0
	var scene = get_tree().current_scene
	var scene_name := String(scene.name) if is_instance_valid(scene) else ""
	if scene_name != _last_scene:
		_last_scene = scene_name
		_record("scene_changed", {"scene": scene_name, "script": String(scene.get_script().resource_path) if is_instance_valid(scene) and scene.get_script() != null else ""})
	if scene_name == "MainMenu" and not _menu_driven:
		_menu_driven = true
		_record("main_menu_ready", {})
		call_deferred("_drive_main_menu", scene)
	if scene_name == "HeroCreation":
		_mark_phase("BLOCKED_PROFILE_HERO_REQUIRED", "skirmish_redirected_to_hero_creation")
		if elapsed >= 8.0:
			_finish("BLOCKED_LOAD01_PROFILE_HERO_REQUIRED_BEFORE_SKIRMISH")
		return
	if scene_name == "SkirmishSetup" and not _setup_driven:
		_setup_driven = true
		call_deferred("_drive_setup", scene)
	var loading = get_node_or_null("/root/LoadingScreen")
	if loading != null:
		var busy := bool(loading.get("_busy"))
		if busy and not _last_busy:
			_mark_phase("T1_LOAD_TRANSITION_BEGIN", "loading_overlay_visible")
		_last_busy = busy
	var root = scene if scene_name == "GameRoot" else null
	if root != null:
		_mark_phase("T2_WORLD_SCENE_INSTANTIATED", "GameRoot_ready")
		var world = root.get("world")
		if is_instance_valid(world):
			if world.get("map") is Dictionary and not world.get("map").is_empty() and world.get_node_or_null("Scenery") != null:
				_mark_phase("T3_TERRAIN_INITIALIZED", "map_and_scenery_ready")
			if get_tree().get_nodes_in_group("resources").size() > 0 and world.get("map") is Dictionary and not world.get("map").get("resources", []).is_empty():
				_mark_phase("T4_RESOURCES_AND_WORLD_PROPS_INITIALIZED", "resources_present")
			var commander = world.get("player_commander")
			if is_instance_valid(commander) and world.all_units().size() > 0:
				_mark_phase("T5_PLAYER_FACTION_INITIALIZED", "player_commander_and_units_ready")
			if root.get("ais") is Array and root.get("ais").size() > 0:
				_mark_phase("T6_OPPONENT_INITIALIZED", "easy_ai_ready")
			var hud = root.get("hud")
			if is_instance_valid(hud) and hud.get("_minimap") != null:
				_mark_phase("T7_HUD_AND_MINIMAP_READY", "hud_minimap_ready")
			var rts = root.get("rts")
			if is_instance_valid(rts) and is_instance_valid(rts.get("camera")) and rts.get("camera").current:
				_mark_phase("T8_CAMERA_AND_PLAYER_CONTROL_READY", "active_rts_camera")
			var settled := loading == null or not bool(loading.get("_busy"))
			if bool(world.get("game_running")) and settled and bool(world.get("navigation_ready")):
				_mark_phase("T9_BATTLEFIELD_PLAYABLE", "game_running_navigation_ready_loader_settled")
				if not _capture_written:
					_capture_written = true
					_capture("01_LOAD01_PLAYABLE.png")
					_finish("PASSED_P1_LOAD01_REACHED_PLAYABLE_BATTLEFIELD")
	if elapsed >= _deadline_s:
		_finish("BLOCKED_LOAD01_TIMEOUT_BEFORE_PLAYABLE_BATTLEFIELD")

func _drive_main_menu(menu: Node) -> void:
	await get_tree().process_frame
	if is_instance_valid(menu) and menu.has_method("_on_skirmish"):
		_mark_phase("T0_PLAYER_INITIATED_SKIRMISH", "ordinary_skirmish_button_path")
		menu.call("_on_skirmish")

func _drive_setup(setup: Node) -> void:
	await get_tree().process_frame
	if not is_instance_valid(setup):
		return
	setup.set("_player_race", "barrosan")
	setup.set("_res_kind", "rich")
	setup.set("_victory", "conquest")
	setup.set("_game_speed", 2.0)
	setup.set("_map_id", "hollowspan")
	var rows = setup.get("_opp_rows")
	var game_data = get_node_or_null("/root/GameData")
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
	_mark_phase("T0_PLAYER_INITIATED_SKIRMISH", "ordinary_setup_ready")
	if setup.has_method("_on_begin"):
		_mark_phase("T1_LOAD_TRANSITION_BEGIN", "ordinary_begin_battle_button_path")
		setup.call("_on_begin")

func _mark_phase(name: String, detail: String) -> void:
	if _phases.has(name):
		return
	var elapsed := float(Time.get_ticks_msec() - _started_ms) / 1000.0
	_phases[name] = {"elapsed_s": elapsed, "detail": detail}
	_record("phase", {"phase": name, "detail": detail, "elapsed_s": elapsed})

func _capture(name: String) -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var image := viewport.get_texture().get_image()
	image.save_png(_out + name)
	_record("screenshot", {"name": name, "bytes": FileAccess.get_file_as_bytes(_out + name).size()})

func _record(kind: String, payload: Dictionary) -> void:
	var item := {"kind": kind, "timestamp_ms": Time.get_ticks_msec(), "elapsed_s": float(Time.get_ticks_msec() - _started_ms) / 1000.0}
	for key in payload.keys():
		item[key] = payload[key]
	_events.append(item)
	var file := FileAccess.open(_out + "load-events.jsonl", FileAccess.READ_WRITE if FileAccess.file_exists(_out + "load-events.jsonl") else FileAccess.WRITE)
	if file != null:
		file.seek_end()
		file.store_line(JSON.stringify(item))
		file.close()

func _finish(status: String) -> void:
	if _finished:
		return
	_finished = true
	var manifest := {"schema": "p1-load-01-observation-v1", "status": status, "mode": _mode, "source_sha": OS.get_environment("ASCENDANT_P1_LOAD01_SOURCE_SHA"), "branch": OS.get_environment("ASCENDANT_P1_LOAD01_BRANCH"), "godot": OS.get_environment("ASCENDANT_REALMS_GODOT"), "phases": _phases, "event_count": _events.size(), "configuration": CONFIG, "prototype_runtime": false}
	var file := FileAccess.open(_out + "load-manifest.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(manifest, "  ") + "\n")
		file.close()
	get_tree().quit(0)
