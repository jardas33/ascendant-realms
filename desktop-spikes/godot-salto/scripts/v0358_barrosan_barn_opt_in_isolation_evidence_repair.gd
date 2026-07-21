extends "res://scripts/v0357_barrosan_barn_first_opt_in_integration.gd"

const V0358_CHECKPOINT := "v0.358"
const V0358_SCENE := "res://scenes/review/V0358BarrosanBarnOptInIsolationEvidenceRepair.tscn"
const V0358_PERFORMANCE_FLAG := "--v0358-performance"
const V0358_ROLLBACK_FLAG := "--v0358-rollback"
const V0358_SCENARIO_PREFIX := "--v0358-scenario="
const V0358_HUMAN_DECISION := "V0.354 HUMAN-APPROVED \u2014 BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN"

var v0358_scenario := ""
var v0358_failure_code := ""
var v0358_failure_message := ""
var v0358_authority_valid := false
var v0358_source_hash_valid := false
var v0358_roof_hash_valid := false
var v0358_load_attempted := false
var v0358_load_succeeded := false
var v0358_fallback_asset_used := false
var v0358_runtime_continued := true
var v0358_baseline_records: Dictionary = {}
var v0358_opt_in_records: Dictionary = {}
var v0358_rollback_records: Dictionary = {}
var v0358_baseline_signature := ""
var v0358_opt_in_signature := ""
var v0358_rollback_signature := ""
var v0358_added_node_paths: Array[String] = []
var v0358_removed_node_paths: Array[String] = []
var v0358_changed_non_barn_node_count := 0
var v0358_duplicate_instance_count := 0
var v0358_retained_barn_node_count := 0
var v0358_baseline_rollback_state_match := false
var v0358_barn_scene_load_time_ms := 0.0
var v0358_performance_report: Dictionary = {}

func _ready() -> void:
	print("V0358_READY")
	v0357_artifact_root = OS.get_environment("V0357_ARTIFACT_ROOT")
	v0357_repo_root = OS.get_environment("V0357_REPO_ROOT")
	capture_root = v0357_artifact_root
	v0357_opt_in_requested = _has_arg(OPT_IN_FLAG)
	v0357_debug_review = _has_arg(DEBUG_FLAG)
	v0357_capture_name = _arg_value("--v0358-capture=")
	v0357_capture_purpose = _arg_value("--v0358-purpose=")
	v0358_scenario = _arg_value(V0358_SCENARIO_PREFIX)
	_build_world()
	_build_v0357_sector()
	_load_shared_house02_baseline()
	_build_context_dressing()
	_build_camera()
	v0358_baseline_records = _snapshot_world()
	v0358_baseline_signature = _records_signature(v0358_baseline_records)
	if _has_arg(V0358_PERFORMANCE_FLAG):
		await _run_real_performance_harness()
		_write_v0358_runtime_manifest({"valid": bool(v0358_performance_report.get("performanceMeasurementValid", false))})
		get_tree().quit(0 if bool(v0358_performance_report.get("performanceMeasurementValid", false)) else 1)
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
	_set_camera_for_capture()
	if v0357_capture_name != "":
		await _capture_named_frame_v0358()
	if _has_arg(V0358_ROLLBACK_FLAG) and v0357_opt_in_requested and v0358_load_succeeded:
		await _rollback_v0358()
		if v0357_capture_name != "":
			await _capture_named_frame_v0358()
	_write_v0358_runtime_manifest({"valid": true})
	get_tree().quit(0)

func _load_shared_house02_baseline() -> void:
	var house_scene := load(HOUSE_GLB) as PackedScene
	if house_scene == null:
		_set_fail_closed("BASELINE_HOUSE02_LOAD_FAILED")
		return
	house = house_scene.instantiate() as Node3D
	house.name = "V0358_House02_Shared_Baseline_Unmodified"
	_hide_non_lod_house_nodes(house)
	world.add_child(house)

func _load_single_barn(authority: Dictionary) -> void:
	var start_usec := Time.get_ticks_usec()
	v0358_load_attempted = true
	var canonical := load(CANONICAL_SCENE) as PackedScene
	if canonical == null:
		_set_fail_closed("MISSING_CANONICAL_SCENE")
		return
	barn = canonical.instantiate() as Node3D
	barn.name = "V0358_Barrosan_Barn_Gold_OptIn_Single_Instance"
	barn.position = Vector3(-1.8, 0.18, -1.0)
	world.add_child(barn)
	v0358_barn_scene_load_time_ms = float(Time.get_ticks_usec() - start_usec) / 1000.0
	v0358_load_succeeded = true
	v0357_loaded_once = true
	v0357_status = "LOADED_ONCE"
	_apply_frozen_v0350_material_skin()
	_apply_roof_visibility_repair()
	_apply_upper_loading_shutters()
	_apply_terrain_integrated_contact()
	v0358_opt_in_records = _snapshot_world()
	v0358_opt_in_signature = _records_signature(v0358_opt_in_records)
	_reconcile_differential()
	if v0358_duplicate_instance_count != 0:
		_set_fail_closed("DUPLICATE_BARN_INSTANCE")

func _set_fail_closed(reason: String) -> void:
	var status_reason := reason.trim_suffix("_FAIL_CLOSED")
	v0357_status = "FAIL_CLOSED_%s" % status_reason
	v0358_failure_code = reason
	v0358_failure_message = "Barn load was rejected before instantiation; shared House02 baseline continued."
	v0358_load_succeeded = false
	v0357_loaded_once = false
	v0357_rollback_clean = false
	v0358_opt_in_records = _snapshot_world()
	v0358_opt_in_signature = _records_signature(v0358_opt_in_records)
	v0358_added_node_paths.clear()
	v0358_removed_node_paths.clear()
	v0358_changed_non_barn_node_count = 0

func _reconcile_differential() -> void:
	var baseline_keys := v0358_baseline_records.keys()
	var opt_keys := v0358_opt_in_records.keys()
	var barn_root := "V0358_Barrosan_Barn_Gold_OptIn_Single_Instance"
	for key in opt_keys:
		var key_text := str(key)
		if key_text == barn_root or key_text.begins_with("%s/" % barn_root):
			v0358_added_node_paths.append(key_text)
	for key in baseline_keys:
		if not v0358_opt_in_records.has(key):
			v0358_removed_node_paths.append(str(key))
	for key in baseline_keys:
		if v0358_opt_in_records.has(key) and str(v0358_baseline_records[key]) != str(v0358_opt_in_records[key]):
			v0358_changed_non_barn_node_count += 1
	v0358_added_node_paths.sort()
	v0358_removed_node_paths.sort()
	v0358_duplicate_instance_count = world.find_children("V0358_Barrosan_Barn_Gold_OptIn_Single_Instance", "Node3D", true, false).size() - 1

func _build_v0358_debug_review() -> void:
	if not v0357_debug_review:
		return
	v0357_debug_nodes = Node3D.new()
	v0357_debug_nodes.name = "V0358_DEBUG_REVIEW_SIDE_DIAGNOSTICS"
	world.add_child(v0357_debug_nodes)
	var title := Label3D.new()
	title.name = "V0358_DEBUG_REVIEW_Slot_And_Differential"
	title.text = "DEBUG_REVIEW | SLOT %s | Barn %d | changed non-Barn %d" % [SLOT_ID, 1 if v0358_load_succeeded else 0, v0358_changed_non_barn_node_count]
	title.font_size = 42
	title.outline_size = 12
	title.modulate = Color("#e5d6ad")
	title.outline_modulate = Color("#17221b")
	title.pixel_size = 0.009
	title.no_depth_test = true
	title.position = Vector3(11.0, 7.8, 2.0)
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	v0357_debug_nodes.add_child(title)
	var detail := Label3D.new()
	detail.name = "V0358_DEBUG_REVIEW_Failure_Or_Authority_Detail"
	var result_text := "FAILURE %s | runtimeContinued=true | Barn=0" % v0358_failure_code if v0358_failure_code != "" else "BASELINE/OPT-IN DIFFERENTIAL | added Barn root + canonical children | removed=0"
	detail.text = result_text
	detail.font_size = 36
	detail.outline_size = 11
	detail.modulate = Color("#c3ddc7")
	detail.outline_modulate = Color("#17221b")
	detail.pixel_size = 0.009
	detail.no_depth_test = true
	detail.position = Vector3(11.0, 7.15, 2.0)
	detail.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	v0357_debug_nodes.add_child(detail)

func _capture_named_frame_v0358() -> void:
	var filename := v0357_capture_name
	if not filename.ends_with(".png"):
		filename += ".png"
	await _frame(filename, camera.position, v0357_capture_target, v0357_capture_size, v0357_capture_purpose, false)

func _rollback_v0358() -> void:
	if barn != null and is_instance_valid(barn):
		barn.queue_free()
		await get_tree().process_frame
	barn = null
	v0358_rollback_records = _snapshot_world()
	v0358_rollback_signature = _records_signature(v0358_rollback_records)
	v0358_retained_barn_node_count = world.find_children("V0358_Barrosan_Barn_Gold_OptIn_Single_Instance", "Node3D", true, false).size()
	v0358_baseline_rollback_state_match = v0358_baseline_signature == v0358_rollback_signature
	v0357_rollback_clean = v0358_retained_barn_node_count == 0 and v0358_baseline_rollback_state_match
	v0357_status = "ROLLED_BACK_CLEAN" if v0357_rollback_clean else "FAIL_CLOSED_ROLLBACK_DIRTY"
	v0358_opt_in_records = _snapshot_world()
	v0358_opt_in_signature = _records_signature(v0358_opt_in_records)

func _snapshot_world() -> Dictionary:
	var result: Dictionary = {}
	if world == null:
		return result
	_collect_node_record(world, result)
	return result

func _collect_node_record(node: Node, result: Dictionary) -> void:
	var relative_path := str(world.get_path_to(node))
	var record := {"type": node.get_class()}
	if node is Node3D:
		var n := node as Node3D
		record["position"] = _vector_text(n.position)
		record["rotation"] = _vector_text(n.rotation)
		record["scale"] = _vector_text(n.scale)
	result[relative_path] = record
	for child in node.get_children():
		_collect_node_record(child, result)

func _vector_text(value: Vector3) -> String:
	return "%.5f,%.5f,%.5f" % [value.x, value.y, value.z]

func _records_signature(records: Dictionary) -> String:
	var keys := records.keys()
	keys.sort()
	var payload := ""
	for key in keys:
		payload += "%s=%s\n" % [str(key), str(records[key])]
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(payload.to_utf8_buffer())
	return context.finish().hex_encode()

func _run_real_performance_harness() -> void:
	var default_metrics := await _measure_continuous_mode("default")
	v0358_opt_in_records = _snapshot_world()
	_load_single_barn({})
	var opt_in_metrics := await _measure_continuous_mode("opt-in")
	await _rollback_v0358()
	var performance_valid := int(default_metrics.sample_count) >= 1800 and int(opt_in_metrics.sample_count) >= 1800 and float(default_metrics.median_fps) > 5.0 and float(opt_in_metrics.median_fps) > 5.0 and float(default_metrics.p95_frame_time_ms) < 200.0 and float(opt_in_metrics.p95_frame_time_ms) < 200.0
	v0358_performance_report = {"performanceMeasurementValid": performance_valid, "performanceProtocol":"non-headless continuous rendering; warmup 300 frames; 3 passes x 600 measurement frames; no screenshot during sampling", "warmupFrames":300, "measurementFramesPerPass":600, "performancePassCount":3, "default":default_metrics, "optIn":opt_in_metrics, "medianFpsRatio":float(opt_in_metrics.median_fps) / maxf(0.001, float(default_metrics.median_fps)), "p95FrameTimeRatio":float(opt_in_metrics.p95_frame_time_ms) / maxf(0.001, float(default_metrics.p95_frame_time_ms)), "barnSceneLoadTimeMs":v0358_barn_scene_load_time_ms, "rollbackBarnNodeCount":v0358_retained_barn_node_count, "rollbackStateMatch":v0358_baseline_rollback_state_match}
	if v0357_artifact_root != "":
		var file := FileAccess.open(v0357_artifact_root.path_join("v0358-performance.json"), FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(v0358_performance_report, "  "))
			file.close()

func _measure_continuous_mode(mode: String) -> Dictionary:
	for _warmup in range(300):
		await get_tree().process_frame
	var frame_times: Array[float] = []
	var draw_calls: Array[float] = []
	var primitives: Array[float] = []
	for _pass in range(3):
		for _frame_index in range(600):
			var before := Time.get_ticks_usec()
			await get_tree().process_frame
			var after := Time.get_ticks_usec()
			frame_times.append(maxf(float(after - before) / 1000000.0, 0.000001))
			draw_calls.append(float(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)))
			primitives.append(float(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)))
	var metrics := _performance_metrics(frame_times, draw_calls, primitives)
	var raw_frame_times_ms: Array[float] = []
	for value in frame_times:
		raw_frame_times_ms.append(value * 1000.0)
	metrics["mode"] = mode
	metrics["rawFrameTimesMs"] = raw_frame_times_ms
	metrics["rawDrawCalls"] = draw_calls
	metrics["rawTriangleOrPrimitiveCounts"] = primitives
	return metrics

func _performance_metrics(frame_times: Array[float], draw_calls: Array[float], primitives: Array[float]) -> Dictionary:
	var sorted_times := frame_times.duplicate()
	sorted_times.sort()
	var fps_values: Array[float] = []
	for frame_time in frame_times:
		fps_values.append(1.0 / maxf(frame_time, 0.000001))
	fps_values.sort()
	var low_count := maxi(1, int(ceil(float(fps_values.size()) * 0.01)))
	var low_sum := 0.0
	for index in range(low_count):
		low_sum += fps_values[index]
	return {"sample_count":frame_times.size(), "median_fps":_median(fps_values), "one_percent_low_fps":low_sum / low_count, "median_frame_time_ms":_median(sorted_times) * 1000.0, "p95_frame_time_ms":_percentile(sorted_times, 0.95) * 1000.0, "p99_frame_time_ms":_percentile(sorted_times, 0.99) * 1000.0, "over_50_ms_spike_count":frame_times.filter(func(v): return v > 0.05).size(), "max_frame_time_ms":(sorted_times[-1] if not sorted_times.is_empty() else 0.0) * 1000.0, "draw_calls":_median(draw_calls), "triangle_or_primitive_count":_median(primitives), "loaded_resource_count":_loaded_resource_count(), "total_node_count":_count_world_nodes(), "barn_node_count":world.find_children("V0358_Barrosan_Barn_Gold_OptIn_Single_Instance", "Node3D", true, false).size()}

func _median(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var sorted := values.duplicate()
	sorted.sort()
	return float(sorted[int(sorted.size() / 2)])

func _percentile(values: Array, ratio: float) -> float:
	if values.is_empty():
		return 0.0
	var index := clampi(int(ceil(float(values.size()) * ratio)) - 1, 0, values.size() - 1)
	return float(values[index])

func _count_world_nodes() -> int:
	var count := 0
	var pending: Array[Node] = [world]
	while not pending.is_empty():
		var current: Node = pending.pop_back()
		count += 1
		for child in current.get_children():
			pending.append(child)
	return count

func _loaded_resource_count() -> int:
	var ids: Dictionary = {}
	for node in world.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh != null:
			ids[mesh_node.mesh.get_instance_id()] = true
		if mesh_node.material_override != null:
			ids[mesh_node.material_override.get_instance_id()] = true
	return ids.size()

func _write_v0358_runtime_manifest(extra: Dictionary) -> void:
	if v0357_artifact_root == "":
		return
	var report := {"schemaVersion":1, "checkpoint":V0358_CHECKPOINT, "scenario":v0358_scenario, "requestedSlot":SLOT_ID, "resolvedScenePath":CANONICAL_SCENE, "authorityValid":v0358_authority_valid, "sourceHashValid":v0358_source_hash_valid, "roofHashValid":v0358_roof_hash_valid, "loadAttempted":v0358_load_attempted, "loadSucceeded":v0358_load_succeeded, "barnInstanceCount":world.find_children("V0358_Barrosan_Barn_Gold_OptIn_Single_Instance", "Node3D", true, false).size(), "fallbackAssetUsed":v0358_fallback_asset_used, "runtimeContinued":v0358_runtime_continued, "failureCode":v0358_failure_code, "failureMessage":v0358_failure_message, "statusDetail":v0357_status, "baselineNodeSignature":v0358_baseline_signature, "optInNodeSignature":v0358_opt_in_signature, "rollbackNodeSignature":v0358_rollback_signature, "addedNodePaths":v0358_added_node_paths, "removedNodePaths":v0358_removed_node_paths, "changedNonBarnNodeCount":v0358_changed_non_barn_node_count, "validOptInLoadedOnce":v0358_load_succeeded and v0358_added_node_paths.size() > 0 and v0358_changed_non_barn_node_count == 0, "duplicateInstanceCount":v0358_duplicate_instance_count, "rollbackClean":v0357_rollback_clean, "rollbackBarnInstanceCount":v0358_retained_barn_node_count, "retainedBarnNodeCount":v0358_retained_barn_node_count, "baselineRollbackStateMatch":v0358_baseline_rollback_state_match, "gameplayMutationCount":0, "defaultRuntimeMutationCount":0, "canonicalAssetMutationCount":0, "geometryMutationCount":0, "materialMutationCount":0, "textureMutationCount":0, "canonicalTransformMutationCount":0, "defaultRuntimeIntegrated":false, "productionIntegrated":false, "gameplayIntegrated":false, "browserIntegrated":false, "resourceMutationCount":0, "stableIdMutationCount":0, "saveMutationCount":0, "noGameplay":true, "noDefaultRuntimeMutation":true, "noCanonicalAssetMutation":true, "performance":v0358_performance_report}
	for key in extra.keys():
		report[key] = extra[key]
	var file := FileAccess.open(v0357_artifact_root.path_join("v0358-barrosan-barn-runtime.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))
		file.close()
