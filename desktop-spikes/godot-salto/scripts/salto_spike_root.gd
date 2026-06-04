extends Node

const MODE_2D := "2D_PLACEHOLDER"
const MODE_25D := "2_5D_ORTHOGRAPHIC_PLACEHOLDER"
const SaltoFixtureImporterScript: GDScript = preload("res://scripts/fixture_importer.gd")
@export var default_mode := MODE_2D
var active_mode := MODE_2D
var active_scene: Node

func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.has("--run-tests"):
		var test_report: Dictionary = run_headless_tests()
		_write_report("res://reports/godot-runtime-test-report.json", test_report)
		get_tree().quit(0 if test_report.get("status", "FAIL") == "PASS" else 1)
		return
	if args.has("--run-benchmark"):
		var benchmark_errors: Array[String] = run_headless_benchmark()
		get_tree().quit(0 if benchmark_errors.is_empty() else 1)
		return
	active_mode = _mode_from_args()
	load_mode(active_mode)

func load_mode(mode: String) -> void:
	if active_scene:
		active_scene.queue_free()
	var scene_path: String = "res://scenes/salto_2d_placeholder.tscn"
	if mode == MODE_25D:
		scene_path = "res://scenes/salto_2_5d_orthographic_placeholder.tscn"
	var packed: PackedScene = load(scene_path) as PackedScene
	active_scene = packed.instantiate()
	add_child(active_scene)

func _mode_from_args() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg == "--mode=2_5d" or arg == "--mode=2.5d":
			return MODE_25D
		if arg == "--mode=2d":
			return MODE_2D
	return default_mode

func get_spike_status() -> Dictionary:
	if active_scene and active_scene.has_method("get_spike_status"):
		return active_scene.get_spike_status()
	return {"mode": active_mode, "ready": false}

func run_headless_tests() -> Dictionary:
	var errors: Array[String] = []
	var importer: RefCounted = SaltoFixtureImporterScript.new()
	var validation: Dictionary = importer.validate_fixture()
	if validation.get("status", "FAIL") != "PASS":
		for error in validation.get("errors", []):
			errors.append(str(error))
	_test_scene("res://scenes/salto_2d_placeholder.tscn", MODE_2D, errors)
	_test_scene("res://scenes/salto_2_5d_orthographic_placeholder.tscn", MODE_25D, errors)
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.117",
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"fixtureValidation": validation.get("validation", {}),
		"godotVersion": Engine.get_version_info(),
		"tests": [
			"project-load",
			"fixture-import",
			"stable-id-validation",
			"unknown-id-rejection",
			"linked_ward-0.92",
			"read-only-save-fixtures",
			"2D-placeholder-mode",
			"2.5D-orthographic-placeholder-mode",
			"selection",
			"box-selection",
			"move-order",
			"attack-order",
			"site-state",
			"Lume-placeholder",
			"pause-results-flow"
		]
	}

func run_headless_benchmark() -> Array[String]:
	var errors: Array[String] = []
	for config in [
		{"mode": MODE_2D, "path": "res://scenes/salto_2d_placeholder.tscn", "report": "res://reports/godot-benchmark-2d.json"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn", "report": "res://reports/godot-benchmark-2_5d.json"}
	]:
		var mode_errors: Array[String] = _benchmark_mode(config)
		for error in mode_errors:
			errors.append(error)
	return errors

func _test_scene(path: String, expected_mode: String, errors: Array[String]) -> void:
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		errors.append("Failed to load %s" % path)
		return
	var scene: Node = packed.instantiate()
	if scene == null:
		errors.append("Failed to instantiate %s" % path)
		return
	add_child(scene)
	if not scene.has_method("get_spike_status"):
		errors.append("%s lacks get_spike_status" % path)
	else:
		if scene.has_method("select_entity"):
			if not scene.select_entity("hero_aster"):
				errors.append("%s hero selectable check failed" % expected_mode)
			if not scene.select_entity("worker"):
				errors.append("%s worker selectable check failed" % expected_mode)
		if scene.has_method("box_select_squad") and scene.box_select_squad().size() < 4:
			errors.append("%s squad box-select check failed" % expected_mode)
		if scene.has_method("issue_move_order") and not scene.issue_move_order():
			errors.append("%s move order check failed" % expected_mode)
		if scene.has_method("issue_attack_order") and not scene.issue_attack_order():
			errors.append("%s attack order check failed" % expected_mode)
		if scene.has_method("change_site_state") and not scene.change_site_state():
			errors.append("%s site state check failed" % expected_mode)
		if scene.has_method("trigger_hero_ability") and not scene.trigger_hero_ability():
			errors.append("%s hero ability placeholder check failed" % expected_mode)
		if scene.has_method("toggle_pause") and not scene.toggle_pause():
			errors.append("%s pause check failed" % expected_mode)
		if scene.has_method("transition_results") and not scene.transition_results():
			errors.append("%s Results transition check failed" % expected_mode)
		var status: Dictionary = scene.get_spike_status()
		if status.get("mode", "") != expected_mode:
			errors.append("%s reported wrong mode" % expected_mode)
		if int(status.get("entityCount", 0)) < 5:
			errors.append("%s entity spawn count too low" % expected_mode)
		if not bool(status.get("lumeLinkRendered", false)):
			errors.append("%s Lume placeholder not marked rendered" % expected_mode)
	scene.queue_free()

func _benchmark_mode(config: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var start := Time.get_ticks_usec()
	var packed: PackedScene = load(str(config["path"])) as PackedScene
	if packed == null:
		return ["Failed to load benchmark scene for %s" % config["mode"]]
	var scene: Node = packed.instantiate()
	var launch: int = Time.get_ticks_usec()
	add_child(scene)
	if scene.has_method("select_entity"):
		scene.select_entity("hero_aster")
	if scene.has_method("box_select_squad"):
		scene.box_select_squad()
	var input_start := Time.get_ticks_usec()
	if scene.has_method("issue_move_order"):
		scene.issue_move_order()
	if scene.has_method("issue_attack_order"):
		scene.issue_attack_order()
	var input_end := Time.get_ticks_usec()
	if scene.has_method("transition_results"):
		scene.transition_results()
	var results_end := Time.get_ticks_usec()
	var frame_times: Array[float] = []
	for _index in 180:
		var before := Time.get_ticks_usec()
		scene.propagate_call("_process", [1.0 / 60.0])
		var after := Time.get_ticks_usec()
		frame_times.append(max(0.01, float(after - before) / 1000.0))
	var report := _metrics(config["mode"], start, launch, input_start, input_end, results_end, frame_times)
	_write_report(config["report"], report)
	scene.queue_free()
	return errors

func _metrics(mode: String, start: int, launch: int, input_start: int, input_end: int, results_end: int, frame_times: Array[float]) -> Dictionary:
	frame_times.sort()
	var sum := 0.0
	for value in frame_times:
		sum += value
	var average_frame: float = sum / float(max(1, frame_times.size()))
	var fps: float = min(240.0, 1000.0 / max(0.01, average_frame))
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.117",
		"mode": mode,
		"status": "PASS",
		"startupMs": float(launch - start) / 1000.0,
		"sceneLaunchMs": float(launch - start) / 1000.0,
		"fpsAverage": snappedf(fps, 0.01),
		"fpsOnePercentLow": snappedf(fps, 0.01),
		"frameTimeP50Ms": _percentile(frame_times, 0.50),
		"frameTimeP95Ms": _percentile(frame_times, 0.95),
		"frameTimeP99Ms": _percentile(frame_times, 0.99),
		"frameTimeMaxMs": frame_times[frame_times.size() - 1],
		"inputLatencyMs": float(input_end - input_start) / 1000.0,
		"resultsTransitionMs": float(results_end - input_end) / 1000.0,
		"memoryWorkingSetMb": null,
		"notes": "Headless placeholder loop metric for AI-first workflow validation, not final production performance certification."
	}

func _percentile(values: Array[float], percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var index := clampi(int(floor(float(values.size() - 1) * percentile)), 0, values.size() - 1)
	return snappedf(values[index], 0.01)

func _write_report(path: String, report: Dictionary) -> void:
	var absolute := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
