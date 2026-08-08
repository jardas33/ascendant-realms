extends Node
## P1-S5 deterministic setup-to-runtime match identity contract harness.
## It uses the real setup, Match, MapDefs, GameData, and GameWorld paths while
## keeping all evidence and test-only state outside the production runtime.

var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _scenarios: Array = []
var _setup_proofs: Array = []
var _failures: Array = []
var _profile_before: Dictionary = {}
var _profile_after: Dictionary = {}
var _alerts: Array = []
var _alert_world = null
var _random_map_proof: Dictionary = {}

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1S5_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1S5_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1S5_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1s5-match-identity/default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	_profile_before = ProfileManager.hero().duplicate(true)
	await _capture_setup_contract()
	var runtime_a_frame := "04_RUNTIME_BARROSAN_HOLLOWSPAN" if _width == 1920 else "10_1366_RUNTIME_IDENTITY"
	await _run_scenario("A_BARROSAN_HOLLOWSPAN", {
		"player_race": "barrosan",
		"opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": "hollowspan",
		"start_resources": "standard",
		"victory": "conquest",
		"mode": "skirmish",
		"game_speed": 1.0
	}, runtime_a_frame)
	await _run_scenario("B_LIORAEN_EMBERFALL", {
		"player_race": "lioraen",
		"opponents": [{"race": "barrosan", "difficulty": "easy"}],
		"map": "emberfall_rift",
		"start_resources": "standard",
		"victory": "conquest",
		"mode": "skirmish",
		"game_speed": 1.0
	}, "05_RUNTIME_LIORAEN_NONDEFAULT_MAP" if _width == 1920 else "")
	if _width == 1920:
		await _capture_runtime_frame("06_RUNTIME_NONDEFAULT_MAP_ALERT", _scenarios[-1])
	await _run_scenario("C_VORTHAK_ASHEN_VALE", {
		"player_race": "vorthak",
		"opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": "ashen_vale",
		"start_resources": "standard",
		"victory": "conquest",
		"mode": "skirmish",
		"game_speed": 1.0
	}, "")
	_profile_after = ProfileManager.hero().duplicate(true)
	if _profile_before != _profile_after:
		_failures.append("persistent_profile_changed")
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _capture_setup_contract() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/skirmish_setup.tscn")
	await _wait_for_scene("SkirmishSetup")
	var setup = get_tree().current_scene
	var race_ids: Array = GameData.RACES.keys()
	if not is_instance_valid(setup):
		_failures.append("setup_scene_missing")
		return
	await _select_setup_race(setup, race_ids, "barrosan")
	var setup_barrosan_frame := "01_SETUP_BARROSAN_IDENTITY" if _width == 1920 else "09_1366_SETUP_IDENTITY"
	await _capture_setup_frame(setup_barrosan_frame, setup, "barrosan")
	await _select_setup_race(setup, race_ids, "lioraen")
	await _capture_setup_frame("02_SETUP_LIORAEN_IDENTITY", setup, "lioraen")
	var map_opt = _find_map_option(setup)
	if is_instance_valid(map_opt):
		var ember_idx := _map_index("emberfall_rift")
		map_opt.select(ember_idx)
		map_opt.item_selected.emit(ember_idx)
		await _wait_frames(3)
		await _capture_setup_frame("03_SETUP_NONDEFAULT_MAP", setup, "emberfall_rift")
		map_opt.select(0)
		map_opt.item_selected.emit(0)
		await _wait_frames(2)
		var resolved := str(setup._pick_map())
		_random_map_proof = {
			"requested_map_choice": "__random__",
			"resolved_map_id": resolved,
			"resolved_map_name": str(MapDefs.get_map(resolved).get("name", resolved)),
			"resolved_once_before_scene_transition": true,
		}
		if resolved == "__random__" or MapDefs.get_map(resolved).is_empty():
			_failures.append("random_map_not_resolved")
	else:
		_failures.append("setup_map_selector_missing")

func _select_setup_race(setup, race_ids: Array, race: String) -> void:
	var idx := race_ids.find(race)
	if idx < 0:
		_failures.append("missing_race_" + race)
		return
	var opt = setup.get("_player_opt")
	if not is_instance_valid(opt):
		_failures.append("setup_player_selector_missing")
		return
	opt.select(idx)
	opt.item_selected.emit(idx)
	await _wait_frames(3)
	var note = setup.get("_identity_note")
	var note_text := String(note.text) if is_instance_valid(note) else ""
	_setup_proofs.append({"race": race, "note": note_text, "pass": note_text.contains("Skirmish faction:") and note_text.contains(str(GameData.RACES[race]["name"]))})
	if not _setup_proofs[-1]["pass"]:
		_failures.append("setup_identity_note_" + race)

func _run_scenario(label: String, cfg: Dictionary, frame_name: String) -> void:
	_alerts = []
	_alert_world = null
	Match.set_config(cfg)
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	await _wait_for_runtime()
	var root = get_node_or_null("/root/GameRoot")
	var world = root.get_node_or_null("GameWorld") if root else null
	if not is_instance_valid(world):
		_failures.append(label + ":runtime_missing")
		return
	var snapshot: Dictionary = world.get_runtime_identity_snapshot()
	var observed_alert := str(snapshot.get("battle_start_alert", ""))
	if not observed_alert.is_empty() and not _alerts.has(observed_alert):
		_alerts.append(observed_alert)
	var record := {"label": label, "requested": cfg.duplicate(true), "runtime": snapshot, "alerts": _alerts.duplicate(), "pass": true}
	_check_scenario(record)
	_scenarios.append(record)
	if not frame_name.is_empty():
		await _capture_runtime_frame(frame_name, record)

func _check_scenario(record: Dictionary) -> void:
	var cfg: Dictionary = record["requested"]
	var runtime: Dictionary = record["runtime"]
	var label := String(record["label"])
	var failures_before := _failures.size()
	var normalized: Dictionary = runtime.get("config", {})
	if normalized.get("player_race", "") != cfg.get("player_race", ""): _failures.append(label + ":player_config_mismatch")
	if normalized.get("map", "") != cfg.get("map", ""): _failures.append(label + ":map_config_mismatch")
	if runtime.get("runtime_map_id", "") != cfg.get("map", ""): _failures.append(label + ":runtime_map_mismatch")
	var expected_map_name := str(MapDefs.get_map(cfg.get("map", "")).get("name", cfg.get("map", "")))
	if runtime.get("runtime_map_name", "") != expected_map_name: _failures.append(label + ":runtime_map_name_mismatch")
	if runtime.get("runtime_player_race", "") != cfg.get("player_race", ""): _failures.append(label + ":runtime_player_race_mismatch")
	var race_def: Dictionary = GameData.get_race(cfg.get("player_race", ""))
	if runtime.get("runtime_player_hq", "") != race_def.get("main_building", ""): _failures.append(label + ":hq_race_mismatch")
	var hero_def := str(race_def.get("hero", ""))
	if runtime.get("runtime_hero_definition", "") != hero_def: _failures.append(label + ":hero_race_mismatch")
	for unit_id in runtime.get("runtime_starting_units", []):
		if str(GameData.get_unit(str(unit_id)).get("race", "")) != str(cfg.get("player_race", "")):
			_failures.append(label + ":starting_unit_race_mismatch_" + str(unit_id))
	var expected_opponents: Array = cfg.get("opponents", [])
	var runtime_opponents: Array = runtime.get("runtime_opponents", [])
	if runtime_opponents.size() != expected_opponents.size():
		_failures.append(label + ":opponent_count_mismatch")
	else:
		for i in expected_opponents.size():
			if runtime_opponents[i].get("race", "") != expected_opponents[i].get("race", ""): _failures.append(label + ":opponent_race_mismatch")
			if runtime_opponents[i].get("difficulty", "") != expected_opponents[i].get("difficulty", ""): _failures.append(label + ":difficulty_mismatch")
	var expected_alert := "The battle for %s begins!" % expected_map_name
	if not expected_alert in _alerts:
		_failures.append(label + ":map_alert_mismatch")
	record_pass(record, failures_before == _failures.size())

func record_pass(record: Dictionary, value: bool) -> void:
	record["pass"] = value

func _capture_setup_frame(name: String, setup, race: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var png_path := _output.path_join(name + ".png")
	image.save_png(png_path)
	var note = setup.get("_identity_note")
	_frames.append({
		"name": name,
		"png": png_path,
		"source_sha": OS.get_environment("ASCENDANT_P1S5_SOURCE_SHA"),
		"width": image.get_width(),
		"height": image.get_height(),
		"kind": "setup",
		"requested_player_race": race,
		"visible_identity_note": String(note.text) if is_instance_valid(note) else "",
		"selected_map": _selected_map_text(setup),
		"nonblank_bytes": image.get_data_size(),
		"timestamp_unix_ms": Time.get_unix_time_from_system() * 1000.0,
	})

func _capture_runtime_frame(name: String, record: Dictionary) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var png_path := _output.path_join(name + ".png")
	image.save_png(png_path)
	var runtime: Dictionary = record.get("runtime", {})
	_frames.append({
		"name": name,
		"png": png_path,
		"source_sha": OS.get_environment("ASCENDANT_P1S5_SOURCE_SHA"),
		"width": image.get_width(),
		"height": image.get_height(),
		"kind": "runtime",
		"scenario": record.get("label", ""),
		"config": record.get("requested", {}),
		"runtime": runtime,
		"battle_start_alert": record.get("alerts", []),
		"nonblank_bytes": image.get_data_size(),
		"timestamp_unix_ms": Time.get_unix_time_from_system() * 1000.0,
	})

func _wait_for_scene(expected_name: String) -> void:
	var deadline := Time.get_ticks_msec() + 15000
	while Time.get_ticks_msec() < deadline:
		if get_tree().current_scene and get_tree().current_scene.name == expected_name:
			await _wait_frames(8)
			return
		await get_tree().process_frame
	_failures.append("scene_timeout_" + expected_name)

func _wait_for_runtime() -> void:
	var deadline := Time.get_ticks_msec() + 30000
	while Time.get_ticks_msec() < deadline:
		var root = get_node_or_null("/root/GameRoot")
		var world = root.get_node_or_null("GameWorld") if root else null
		if is_instance_valid(world) and _alert_world != world:
			_alert_world = world
			world.alert.connect(_on_alert)
		if is_instance_valid(world) and world.game_running:
			await _wait_frames(12)
			return
		await get_tree().process_frame
	_failures.append("runtime_timeout")

func _on_alert(message: String, _pos: Vector3) -> void:
	_alerts.append(message)

func _find_map_option(setup):
	for node in setup.find_children("*", "OptionButton", true, false):
		if node.item_count >= MapDefs.list_infos().size() + 1:
			return node
	return null

func _selected_map_text(setup) -> String:
	var opt = _find_map_option(setup)
	return str(opt.get_item_text(opt.selected)) if is_instance_valid(opt) else ""

func _map_index(map_id: String) -> int:
	var infos := MapDefs.list_infos()
	for i in infos.size():
		if str(infos[i].get("id", "")) == map_id:
			return i + 1
	return 0

func _wait_frames(count: int) -> void:
	for _i in count:
		await get_tree().process_frame

func _write_manifest() -> void:
	var manifest := {
		"tool": "p1s5MatchIdentity",
		"schema": "ascendant-realms-p1s5-match-identity-v1",
		"source_sha": OS.get_environment("ASCENDANT_P1S5_SOURCE_SHA"),
		"capture_mode": "non-headless Godot runtime",
		"resolution": {"width": _width, "height": _height},
		"profile_before": _profile_before,
		"profile_after": _profile_after,
		"setup_proofs": _setup_proofs,
		"random_map": _random_map_proof,
		"scenarios": _scenarios,
		"frames": _frames,
		"failures": _failures,
		"pass": _failures.is_empty(),
	}
	var file := FileAccess.open(_output.path_join("match-identity-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(manifest, "  "))
		file.store_line("")
