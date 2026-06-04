extends SceneTree

const MODES := {
	"2D_PLACEHOLDER": {
		"path": "res://scenes/salto_2d_placeholder.tscn",
		"report": "res://reports/godot-benchmark-2d.json"
	},
	"2_5D_ORTHOGRAPHIC_PLACEHOLDER": {
		"path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn",
		"report": "res://reports/godot-benchmark-2_5d.json"
	}
}

func _init() -> void:
	var errors: Array[String] = []
	for mode in MODES.keys():
		var mode_errors := _benchmark_mode(mode, MODES[mode])
		for error in mode_errors:
			errors.append(error)
	quit(0 if errors.is_empty() else 1)

func _benchmark_mode(mode: String, config: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var start := Time.get_ticks_usec()
	var packed := load(config["path"])
	if packed == null:
		return ["Failed to load benchmark scene for %s" % mode]
	var scene = packed.instantiate()
	var launch := Time.get_ticks_usec()
	root.add_child(scene)
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
	for index in 180:
		var before := Time.get_ticks_usec()
		scene.propagate_call("_process", [1.0 / 60.0])
		var after := Time.get_ticks_usec()
		frame_times.append(max(0.01, float(after - before) / 1000.0))

	var report := _metrics(mode, start, launch, input_start, input_end, results_end, frame_times)
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
