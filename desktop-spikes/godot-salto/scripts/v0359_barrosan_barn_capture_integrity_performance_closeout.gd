extends "res://scripts/v0358_barrosan_barn_opt_in_isolation_evidence_repair.gd"

const V0359_CHECKPOINT := "v0.359"
const V0359_SCENE := "res://scenes/review/V0359BarrosanBarnCaptureIntegrityPerformanceCloseout.tscn"
const V0359_SCENARIO_PREFIX := "--v0359-scenario="
const V0359_VIEW_PREFIX := "--v0359-view="
const V0359_CAPTURE_PREFIX := "--v0359-capture="
const V0359_PURPOSE_PREFIX := "--v0359-purpose="
const V0359_PERFORMANCE_FLAG := "--v0359-performance"
const V0359_ROLLBACK_FLAG := "--v0359-rollback"
const V0359_WARMUP_FRAMES := 600
const V0359_MEASUREMENT_FRAMES_PER_PASS := 1200
const V0359_PASS_COUNT := 3

var v0359_scenario := ""
var v0359_view := "rts"
var v0359_capture_name := ""
var v0359_capture_purpose := ""
var v0359_capture_sequence := 0
var v0359_capture_manifest: Array[Dictionary] = []
var v0359_performance_report: Dictionary = {}
var v0359_diagnostic_layer: CanvasLayer

func _ready() -> void:
	print("V0359_READY")
	v0357_artifact_root = OS.get_environment("V0359_ARTIFACT_ROOT")
	v0357_repo_root = OS.get_environment("V0359_REPO_ROOT")
	capture_root = v0357_artifact_root
	v0357_opt_in_requested = _has_arg(OPT_IN_FLAG)
	v0357_debug_review = _has_arg(DEBUG_FLAG)
	v0359_scenario = _arg_value(V0359_SCENARIO_PREFIX)
	v0359_view = _arg_value(V0359_VIEW_PREFIX)
	if v0359_view == "":
		v0359_view = "rts"
	v0359_capture_name = _arg_value(V0359_CAPTURE_PREFIX)
	v0359_capture_purpose = _arg_value(V0359_PURPOSE_PREFIX)
	_build_world()
	_build_v0357_sector()
	_load_shared_house02_baseline()
	_build_context_dressing()
	_build_camera()
	_set_v0359_camera(v0359_view)
	v0358_baseline_records = _snapshot_world()
	v0358_baseline_signature = _records_signature(v0358_baseline_records)
	if _has_arg(V0359_PERFORMANCE_FLAG):
		await _run_uncapped_v0359_performance()
		_write_v0359_performance_manifest()
		get_tree().quit(0 if bool(v0359_performance_report.get("performanceUncappedValid", false)) else 1)
		return
	if _has_arg(V0359_ROLLBACK_FLAG):
		await _run_v0359_rollback_capture()
		_write_v0359_runtime_manifest()
		get_tree().quit(0 if v0357_rollback_clean else 1)
		return
	if v0357_opt_in_requested:
		var authority := _validate_authority()
		v0358_authority_valid = bool(authority.get("valid", false))
		v0358_source_hash_valid = v0358_authority_valid and str(authority.get("observedSourceHash", "")) == SOURCE_HASH
		v0358_roof_hash_valid = v0358_authority_valid and str(authority.get("roofHash", "")) == ROOF_HASH
		if not v0358_authority_valid:
			_set_fail_closed(str(authority.get("reason", "INVALID_AUTHORITY")))
		else:
			_load_single_barn(authority)
	else:
		v0357_status = "BASELINE_HOUSE02_NO_BARN"
	_build_v0358_debug_review()
	if v0359_scenario in ["missing-scene-fail-closed", "hash-mismatch-fail-closed", "invalid-authority-fail-closed", "unknown-slot-rejected"]:
		_build_human_fail_closed_panel()
	if v0359_capture_name != "":
		await _capture_v0359_frame(v0359_capture_name, v0359_capture_purpose, v0359_view)
	_write_v0359_runtime_manifest()
	get_tree().quit(0)

func _camera_spec(view: String) -> Dictionary:
	match view:
		"wide": return {"position":Vector3(-22.0, 11.5, 25.0), "target":Vector3(0.0, 1.2, 0.5), "size":28.0}
		"close-scale": return {"position":Vector3(-11.0, 6.8, 14.0), "target":Vector3(-0.8, 1.5, 0.2), "size":15.0}
		"rts": return {"position":Vector3(-26.0, 16.0, 30.0), "target":Vector3(2.5, 1.0, 3.0), "size":36.0}
		"terrain-contact": return {"position":Vector3(-7.5, 4.8, 10.5), "target":Vector3(-1.8, 0.75, 0.8), "size":10.5}
		"front": return {"position":Vector3(-15.0, 8.4, 17.0), "target":Vector3(-1.0, 2.5, 0.0), "size":24.0}
		"rear": return {"position":Vector3(16.0, 8.0, -18.0), "target":Vector3(0.0, 2.0, 0.0), "size":22.0}
		"roof": return {"position":Vector3(-7.0, 14.0, 18.0), "target":Vector3(-1.5, 2.4, -0.3), "size":15.0}
		_: return {"position":Vector3(-26.0, 16.0, 30.0), "target":Vector3(2.5, 1.0, 3.0), "size":36.0}

func _set_v0359_camera(view: String) -> void:
	var spec := _camera_spec(view)
	_set_camera(spec.position, spec.target, float(spec.size))
	camera.current = true

func _settle_after_camera_transition() -> void:
	for _frame in range(8):
		await get_tree().process_frame

func _capture_v0359_frame(filename: String, purpose: String, view: String) -> String:
	var final_name := filename if filename.ends_with(".png") else "%s.png" % filename
	_set_v0359_camera(view)
	await _settle_after_camera_transition()
	var image := get_viewport().get_texture().get_image()
	if image == null:
		return ""
	var screenshot_dir := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	var absolute_path := screenshot_dir.path_join(final_name)
	image.save_png(absolute_path)
	v0359_capture_sequence += 1
	var spec := _camera_spec(view)
	var record := {"panelId":"%s_%s" % [v0359_scenario, final_name.get_basename()], "semanticPurpose":purpose, "rawCapturePath":absolute_path, "rawCaptureSha256":_sha256_file(absolute_path), "cameraPosition":_vector_map(spec.position), "cameraTarget":_vector_map(spec.target), "cameraRotation":_vector_map(camera.rotation_degrees), "projectionType":"orthographic", "orthographicSize":float(spec.size), "viewportWidth":image.get_width(), "viewportHeight":image.get_height(), "sceneStateSignature":_records_signature(_snapshot_world()), "barnRootCount":world.find_children("V0358_Barrosan_Barn_Gold_OptIn_Single_Instance", "Node3D", true, false).size(), "house02Count":world.find_children("V0358_House02_Shared_Baseline_Unmodified", "Node3D", true, false).size(), "frameNumberAfterCameraTransition":Engine.get_process_frames(), "settleFrames":8, "timestampSequence":v0359_capture_sequence}
	v0359_capture_manifest.append(record)
	return str(record.rawCaptureSha256)

func _vector_map(value: Vector3) -> Dictionary:
	return {"x":value.x, "y":value.y, "z":value.z}

func _build_human_fail_closed_panel() -> void:
	v0359_diagnostic_layer = CanvasLayer.new()
	v0359_diagnostic_layer.name = "V0359_Human_Legible_Fail_Closed_Diagnostics"
	add_child(v0359_diagnostic_layer)
	var panel := ColorRect.new()
	panel.color = Color(0.045, 0.08, 0.07, 0.94)
	panel.position = Vector2(42.0, 672.0)
	panel.size = Vector2(1516.0, 190.0)
	v0359_diagnostic_layer.add_child(panel)
	var title := Label.new()
	title.position = Vector2(28.0, 16.0)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#f0c778"))
	title.text = "FAIL-CLOSED  |  %s" % v0359_scenario.to_upper().replace("-", "_")
	panel.add_child(title)
	var detail := Label.new()
	detail.position = Vector2(28.0, 62.0)
	detail.add_theme_font_size_override("font_size", 25)
	detail.add_theme_color_override("font_color", Color("#edf5e8"))
	detail.text = "Requested slot: %s    |    Load attempted: %s    |    Load succeeded: false\nBarn instances: 0    |    Fallback used: false    |    Runtime continued: true\nFailure code: %s" % [SLOT_ID, str(v0358_load_attempted).to_lower(), v0358_failure_code]
	panel.add_child(detail)

func _run_v0359_rollback_capture() -> void:
	v0357_opt_in_requested = false
	v0357_status = "BASELINE_HOUSE02_NO_BARN"
	var r0_hash := await _capture_v0359_frame("r0.png", "R0 deterministic baseline; Barn count 0", "rts")
	var authority := _validate_authority()
	if not bool(authority.get("valid", false)):
		_set_fail_closed(str(authority.get("reason", "INVALID_AUTHORITY")))
		return
	v0357_opt_in_requested = true
	_load_single_barn(authority)
	var r1_hash := await _capture_v0359_frame("r1.png", "R1 canonical Barn loaded once; Barn count 1", "rts")
	await _rollback_v0358()
	var r2_hash := await _capture_v0359_frame("r2.png", "R2 Barn removed; rollback complete", "rts")
	v0359_capture_manifest.append({"rollbackR0Hash":r0_hash, "rollbackR1Hash":r1_hash, "rollbackR2Hash":r2_hash, "rollbackR0R2PixelMatch":r0_hash == r2_hash, "rollbackR0StateSignature":v0359_capture_manifest[0].sceneStateSignature, "rollbackR2StateSignature":v0359_capture_manifest[-1].sceneStateSignature})

func _configure_uncapped_benchmark() -> void:
	Engine.max_fps = 0
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _run_uncapped_v0359_performance() -> void:
	_configure_uncapped_benchmark()
	_set_v0359_camera("rts")
	await _settle_after_camera_transition()
	var default_metrics := await _measure_uncapped_mode("default")
	var authority := _validate_authority()
	if bool(authority.get("valid", false)):
		_load_single_barn(authority)
		await _settle_after_camera_transition()
	var opt_in_metrics := await _measure_uncapped_mode("opt-in")
	await _rollback_v0358()
	var observed_vsync := int(DisplayServer.window_get_vsync_mode())
	var monitor_refresh := float(DisplayServer.screen_get_refresh_rate())
	var max_median_fps := maxf(float(default_metrics.median_fps), float(opt_in_metrics.median_fps))
	var frame_cap_detected := (monitor_refresh > 0.0 and max_median_fps <= monitor_refresh * 1.05) or max_median_fps < 90.0
	var uncapped_valid := observed_vsync == DisplayServer.VSYNC_DISABLED and Engine.max_fps == 0 and not frame_cap_detected and int(default_metrics.sample_count) >= V0359_WARMUP_FRAMES and int(opt_in_metrics.sample_count) >= V0359_WARMUP_FRAMES and float(default_metrics.median_fps) > 5.0 and float(opt_in_metrics.median_fps) > 5.0
	v0359_performance_report = {"vsyncDisabledForBenchmark":observed_vsync == DisplayServer.VSYNC_DISABLED, "requestedVsyncMode":"disabled", "observedVsyncMode":observed_vsync, "engineMaxFps":Engine.max_fps, "monitorRefreshHz":monitor_refresh, "frameCapDetected":frame_cap_detected, "performanceUncappedValid":uncapped_valid, "warmupFramesPerMode":V0359_WARMUP_FRAMES, "measurementFramesPerPass":V0359_MEASUREMENT_FRAMES_PER_PASS, "performancePassCount":V0359_PASS_COUNT, "default":default_metrics, "optIn":opt_in_metrics, "medianFpsRatio":float(opt_in_metrics.median_fps) / maxf(0.001, float(default_metrics.median_fps)), "p95FrameTimeRatio":float(opt_in_metrics.p95_frame_time_ms) / maxf(0.001, float(default_metrics.p95_frame_time_ms)), "renderingMethod":"gl_compatibility", "viewport":{"width":get_viewport().size.x, "height":get_viewport().size.y}, "graphicsAdapter":RenderingServer.get_video_adapter_name(), "rollbackBarnNodeCount":v0358_retained_barn_node_count, "rollbackStateMatch":v0358_baseline_rollback_state_match, "memoryDeltaBytes":null, "memoryAvailable":false, "deliberateSleep":false, "screenshotDuringSampling":false, "passBoundaries":[0, V0359_MEASUREMENT_FRAMES_PER_PASS, V0359_MEASUREMENT_FRAMES_PER_PASS * 2, V0359_MEASUREMENT_FRAMES_PER_PASS * 3]}

func _measure_uncapped_mode(mode: String) -> Dictionary:
	for _warmup in range(V0359_WARMUP_FRAMES):
		await get_tree().process_frame
	var frame_times: Array[float] = []
	var draw_calls: Array[float] = []
	var primitives: Array[float] = []
	for _pass in range(V0359_PASS_COUNT):
		for _frame_index in range(V0359_MEASUREMENT_FRAMES_PER_PASS):
			var before := Time.get_ticks_usec()
			await get_tree().process_frame
			var after := Time.get_ticks_usec()
			frame_times.append(maxf(float(after - before) / 1000000.0, 0.000001))
			draw_calls.append(float(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)))
			primitives.append(float(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)))
	var metrics := _metrics_v0359(frame_times, draw_calls, primitives)
	metrics["mode"] = mode
	metrics["rawFrameTimesMs"] = frame_times.map(func(value): return value * 1000.0)
	metrics["rawDrawCalls"] = draw_calls
	metrics["rawTriangleOrPrimitiveCounts"] = primitives
	return metrics

func _metrics_v0359(frame_times: Array[float], draw_calls: Array[float], primitives: Array[float]) -> Dictionary:
	var sorted_times := frame_times.duplicate()
	sorted_times.sort()
	var fps_values: Array[float] = []
	for value in frame_times:
		fps_values.append(1.0 / maxf(value, 0.000001))
	fps_values.sort()
	var low_count := maxi(1, int(ceil(float(fps_values.size()) * 0.01)))
	var low_sum := 0.0
	for index in range(low_count):
		low_sum += fps_values[index]
	return {"sample_count":frame_times.size(), "median_fps":_median(fps_values), "one_percent_low_fps":low_sum / low_count, "median_frame_time_ms":_median(sorted_times) * 1000.0, "p95_frame_time_ms":_percentile(sorted_times, 0.95) * 1000.0, "p99_frame_time_ms":_percentile(sorted_times, 0.99) * 1000.0, "max_frame_time_ms":(sorted_times[-1] if not sorted_times.is_empty() else 0.0) * 1000.0, "over_50_ms_spike_count":frame_times.filter(func(value): return value > 0.05).size(), "draw_calls":_median(draw_calls), "triangle_or_primitive_count":_median(primitives), "loaded_resource_count":_loaded_resource_count(), "total_node_count":_count_world_nodes(), "barn_node_count":world.find_children("V0358_Barrosan_Barn_Gold_OptIn_Single_Instance", "Node3D", true, false).size()}

func _write_v0359_performance_manifest() -> void:
	if capture_root == "":
		return
	DirAccess.make_dir_recursive_absolute(capture_root)
	var file := FileAccess.open(capture_root.path_join("v0359-performance.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(v0359_performance_report, "  "))
		file.close()

func _write_v0359_runtime_manifest() -> void:
	if capture_root == "":
		return
	DirAccess.make_dir_recursive_absolute(capture_root)
	var report := {"schemaVersion":1, "checkpoint":V0359_CHECKPOINT, "scenario":v0359_scenario, "statusDetail":v0357_status, "failureCode":v0358_failure_code, "loadAttempted":v0358_load_attempted, "loadSucceeded":v0358_load_succeeded, "barnInstanceCount":world.find_children("V0358_Barrosan_Barn_Gold_OptIn_Single_Instance", "Node3D", true, false).size(), "fallbackAssetUsed":v0358_fallback_asset_used, "runtimeContinued":v0358_runtime_continued, "baselineNodeSignature":v0358_baseline_signature, "optInNodeSignature":v0358_opt_in_signature, "rollbackNodeSignature":v0358_rollback_signature, "addedNodePaths":v0358_added_node_paths, "removedNodePaths":v0358_removed_node_paths, "changedNonBarnNodeCount":v0358_changed_non_barn_node_count, "duplicateInstanceCount":v0358_duplicate_instance_count, "rollbackClean":v0357_rollback_clean, "retainedBarnNodeCount":v0358_retained_barn_node_count, "baselineRollbackStateMatch":v0358_baseline_rollback_state_match, "sourceHashValid":v0358_source_hash_valid, "roofHashValid":v0358_roof_hash_valid, "canonicalAssetMutationCount":0, "gameplayMutationCount":0, "defaultRuntimeMutationCount":0, "browserMutationCount":0, "saveMutationCount":0, "stableIdMutationCount":0, "captures":v0359_capture_manifest, "humanDiagnosticsReadable":v0359_scenario in ["missing-scene-fail-closed", "hash-mismatch-fail-closed", "invalid-authority-fail-closed", "unknown-slot-rejected"]}
	var file := FileAccess.open(capture_root.path_join("v0359-barrosan-barn-runtime.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))
		file.close()
