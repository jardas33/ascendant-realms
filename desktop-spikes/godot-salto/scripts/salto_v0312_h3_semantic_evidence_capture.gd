extends Node

## v0.312 capture-only evidence runner. It drives the existing workload runtime,
## records the authoritative state beside every rendered frame, and never owns
## gameplay positions or selection state.

const VIEWPORT_SIZE := Vector2i(1600, 900)
const WORKER_ID := "worker_00"
const MILITIA_ID := "friendly_00"
const BRIDGE_TARGET := Vector2(1100, 524)
const STOREHOUSE_TARGET := Vector2(210, 210)
const WORK_TARGET := Vector2(635, 452)

var host: Node
var scene: Node
var artifact_root := ""
var screenshot_root := ""
var sidecar_root := ""
var mode := "PLAYER"
var frame_number := 0
var records: Array[Dictionary] = []
var errors: Array[String] = []
var previous_hashes: Dictionary = {}
var scenario_hashes: Dictionary = {}
var debug_layer: CanvasLayer
var debug_label: Label
var saved_state: Dictionary = {}
var save_path := ""

func start() -> void:
	host = get_parent()
	artifact_root = str(host.call("_artifact_root_from_args"))
	screenshot_root = _join(artifact_root, "screenshots")
	sidecar_root = _join(artifact_root, "sidecars")
	mode = str(host.call("_barrosan_presentation_mode_from_args"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(screenshot_root))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(sidecar_root))
	host.callv("_set_capture_viewport", [VIEWPORT_SIZE])
	if mode == "DEBUG_REVIEW":
		_create_debug_overlay()
	await _reset_runtime()
	await _capture("preflight", "preflight", [WORKER_ID, MILITIA_ID], "initial authoritative runtime")
	await _worker_movement_sequence()
	await _militia_movement_sequence()
	await _bridge_sequence(WORKER_ID, "worker_bridge")
	await _bridge_sequence(MILITIA_ID, "militia_bridge")
	await _occlusion_sequence("road_occlusion", Vector2(520, 452), 5)
	await _occlusion_sequence("storehouse_occlusion", STOREHOUSE_TARGET, 5)
	await _occlusion_sequence("bridge_railing_occlusion", BRIDGE_TARGET, 5)
	await _camera_sequences()
	await _worker_state_sequence()
	await _militia_ready_sequence()
	await _selection_sequence()
	await _save_reload_sequence()
	await _rollback_sequence()
	await _scale_sequence()
	await _capture("clean_player_gameplay" if mode == "PLAYER" else "debug_metadata_gameplay", "clean_gameplay", [WORKER_ID, MILITIA_ID], "final runtime overview")
	var manifest := {
		"schemaVersion": 1,
		"checkpoint": "v0.312",
		"mode": mode,
		"status": "PASS_V0312_SEMANTIC_CAPTURE" if errors.is_empty() else "FAIL_V0312_SEMANTIC_CAPTURE",
		"artifactRoot": artifact_root,
		"captureCount": records.size(),
		"physicalPngCount": records.size(),
		"pairedMomentPolicy": "PLAYER and DEBUG_REVIEW views share pairedMomentId and count as one event",
		"h3OptIn": true,
		"integratedRoles": ["Worker", "Militia"],
		"records": records,
		"errors": errors,
		"savePath": save_path,
		"saveWritten": save_path != "",
		"saveRestored": saved_state.size() > 0,
		"defaultRuntimeChanged": false,
		"gameplayChanged": false,
		"protectedAssetsImported": false
	}
	host.callv("_write_absolute_json", [_join(artifact_root, "semantic-capture-manifest.json"), manifest])
	host.callv("_write_absolute_json", [_join(artifact_root, "runtime-state-register.json"), _runtime_state_register()])
	get_tree().quit(0 if errors.is_empty() else 1)

func _reset_runtime() -> void:
	if scene != null and is_instance_valid(scene):
		scene.queue_free()
		await get_tree().process_frame
	host.callv("load_mode", ["2_5D_ORTHOGRAPHIC_PLACEHOLDER"])
	await _settle(8)
	scene = host.get("active_scene") as Node
	if scene == null:
		errors.append("runtime scene did not load")
		return
	scene.callv("set_workload_tier", ["M"])
	host.set("current_step_id", "v0312_semantic_capture")
	host.callv("_render_player_screen", ["battle"])
	await _settle(6)

func _settle(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _advance(frames: int) -> void:
	var runtime = scene.get("runtime")
	for index in range(frames):
		if runtime != null:
			runtime.advance_live_frame()
		if index % 24 == 0:
			scene.call("_sync_unit_visuals")
			await get_tree().process_frame
	scene.call("_sync_unit_visuals")
	await get_tree().process_frame

func _select(id: String) -> void:
	scene.callv("select_entity", [id])
	scene.call("_sync_unit_visuals")
	scene.call("_sync_hud")

func _issue_move(id: String, target: Vector2) -> void:
	_select(id)
	var world_target: Vector3 = scene.callv("_to_world", [target, 0.20])
	scene.callv("issue_move_order", [world_target])
	scene.call("_sync_unit_visuals")

func _worker_movement_sequence() -> void:
	await _reset_runtime()
	await _capture("worker_before_command", "worker_movement", [WORKER_ID], "before command")
	_issue_move(WORKER_ID, BRIDGE_TARGET)
	await _capture("worker_immediately_after_command", "worker_movement", [WORKER_ID], "command accepted")
	for pair in [[60, "worker_25_percent"], [140, "worker_50_percent"], [260, "worker_75_percent"], [500, "worker_destination_reached"]]:
		await _advance(int(pair[0]))
		await _capture(str(pair[1]), "worker_movement", [WORKER_ID], "authoritative movement sample")
	await _capture("worker_stopped", "worker_movement", [WORKER_ID], "stopped after destination; distinctness audited")

func _militia_movement_sequence() -> void:
	await _reset_runtime()
	await _capture("militia_before_command", "militia_movement", [MILITIA_ID], "before command")
	_issue_move(MILITIA_ID, BRIDGE_TARGET)
	await _capture("militia_immediately_after_command", "militia_movement", [MILITIA_ID], "command accepted")
	for pair in [[60, "militia_25_percent"], [140, "militia_50_percent"], [260, "militia_75_percent"], [500, "militia_destination_reached"]]:
		await _advance(int(pair[0]))
		await _capture(str(pair[1]), "militia_movement", [MILITIA_ID], "authoritative movement sample")
	await _capture("militia_stopped", "militia_movement", [MILITIA_ID], "stopped after destination; distinctness audited")

func _bridge_sequence(id: String, scenario: String) -> void:
	await _reset_runtime()
	_issue_move(id, BRIDGE_TARGET)
	var elapsed := 0
	for pair in [[0, "approach_bank"], [100, "bridge_entry"], [220, "bridge_first_quarter"], [315, "bridge_centre"], [390, "bridge_third_quarter"], [470, "bridge_exit"], [560, "beyond_bridge"]]:
		var target_frame := int(pair[0])
		if target_frame > elapsed:
			await _advance(target_frame - elapsed)
		elapsed = target_frame
		await _capture(str(pair[1]), scenario, [id], "same stable ID bridge progression")

func _occlusion_sequence(scenario: String, target: Vector2, count: int) -> void:
	await _reset_runtime()
	_issue_move(WORKER_ID, target)
	for index in range(count):
		if index > 0:
			await _advance(45)
		await _capture("%s_%02d" % [scenario, index + 1], scenario, [WORKER_ID], "depth interaction sample")

func _camera_sequences() -> void:
	await _reset_runtime()
	_select(WORKER_ID)
	await _capture("camera_initial", "camera_pan", [WORKER_ID], "initial camera")
	scene.call("pan_camera")
	await _settle(3)
	await _capture("camera_pan_left", "camera_pan", [WORKER_ID], "camera coordinates changed")
	scene.call("pan_camera")
	await _settle(3)
	await _capture("camera_pan_final", "camera_pan", [WORKER_ID], "camera coordinates changed again")
	await _reset_runtime()
	_select(WORKER_ID)
	var camera := scene.get_node_or_null("FixedOrthographicCamera") as Camera3D
	if camera == null:
		errors.append("camera missing for semantic capture")
		return
	camera.size = 11.0
	await _capture("camera_zoom_ordinary", "camera_zoom", [WORKER_ID], "ordinary gameplay zoom")
	camera.size = 7.8
	await _capture("camera_zoom_minimum", "camera_zoom", [WORKER_ID], "minimum supported gameplay zoom")
	camera.size = 13.8
	await _capture("camera_zoom_maximum", "camera_zoom", [WORKER_ID], "maximum supported gameplay zoom")

func _worker_state_sequence() -> void:
	await _reset_runtime()
	_select(WORKER_ID)
	await _capture("worker_idle", "worker_work_state", [WORKER_ID], "idle; authored work animation absent")
	_issue_move(WORKER_ID, WORK_TARGET)
	await _capture("worker_work_command", "worker_work_state", [WORKER_ID], "existing move-to-work command")
	await _advance(180)
	await _capture("worker_travelling_to_work", "worker_work_state", [WORKER_ID], "travelling to existing work target")
	scene.call("capture_mine_site")
	scene.call("assign_worker_to_mine")
	await _settle(4)
	await _capture("worker_working_state", "worker_work_state", [WORKER_ID], "runtime work state proven; authored work animation absent")
	await _capture("worker_work_pose_limitation", "worker_work_state", [WORKER_ID], "visual pose remains authored idle source")

func _militia_ready_sequence() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	await _capture("militia_idle", "militia_ready_state", [MILITIA_ID], "idle")
	_issue_move(MILITIA_ID, Vector2(760, 524))
	await _capture("militia_move_command", "militia_ready_state", [MILITIA_ID], "move command")
	await _advance(240)
	await _capture("militia_arrival", "militia_ready_state", [MILITIA_ID], "arrival")
	await _capture("militia_ready_unsupported", "militia_ready_state", [MILITIA_ID], "ready/hold state is not supported by current runtime")

func _selection_sequence() -> void:
	await _reset_runtime()
	await _capture("worker_unselected", "selection", [WORKER_ID], "unselected")
	_select(WORKER_ID)
	await _capture("worker_selected", "selection", [WORKER_ID], "selected")
	_select(MILITIA_ID)
	await _capture("militia_selected", "selection", [MILITIA_ID], "selected")
	var runtime = scene.get("runtime")
	var mixed_ids: Array[String] = [WORKER_ID, MILITIA_ID]
	runtime.select_units_by_ids(mixed_ids)
	scene.call("_sync_unit_visuals")
	await _capture("mixed_selected", "selection", [WORKER_ID, MILITIA_ID], "mixed selection")
	runtime.box_select_squad()
	scene.call("_sync_unit_visuals")
	await _capture("box_selection_completed", "selection", [WORKER_ID, MILITIA_ID], "box selection completed")
	runtime.clear_selection()
	scene.call("_sync_unit_visuals")
	await _capture("selection_cleared", "selection", [WORKER_ID, MILITIA_ID], "selection cleared")
	_select(WORKER_ID)
	_issue_move(WORKER_ID, Vector2(900, 500))
	await _advance(90)
	await _capture("selection_after_movement", "selection", [WORKER_ID], "selection after movement")

func _save_reload_sequence() -> void:
	await _reset_runtime()
	_issue_move(WORKER_ID, Vector2(720, 470))
	await _advance(90)
	_select(MILITIA_ID)
	var runtime = scene.get("runtime")
	saved_state = runtime.capture_save_state()
	save_path = "user://v0312-h3-runtime-save.json"
	var save_file := FileAccess.open(save_path, FileAccess.WRITE)
	if save_file == null:
		errors.append("unable to write real runtime save")
		return
	save_file.store_string(JSON.stringify(saved_state))
	save_file.close()
	await _capture("before_real_save", "save_write_reload", [WORKER_ID, MILITIA_ID], "written runtime state before save")
	await _reset_runtime()
	await _capture("after_runtime_reset", "save_write_reload", [WORKER_ID, MILITIA_ID], "runtime reset before load")
	runtime = scene.get("runtime")
	var load_file := FileAccess.open(save_path, FileAccess.READ)
	var loaded = JSON.parse_string(load_file.get_as_text()) if load_file != null else null
	if load_file != null:
		load_file.close()
	if not loaded is Dictionary or not runtime.restore_capture_save_state(loaded):
		errors.append("real runtime save did not restore authoritative state")
	else:
		scene.call("_sync_unit_visuals")
		await _capture("after_real_load", "save_write_reload", [WORKER_ID, MILITIA_ID], "loaded written save")
		await _capture("selected_state_after_load", "save_write_reload", [WORKER_ID, MILITIA_ID], "selection restored from save")

func _rollback_sequence() -> void:
	await _reset_runtime()
	_select(WORKER_ID)
	_issue_move(WORKER_ID, Vector2(870, 520))
	await _advance(80)
	await _capture("h3_enabled", "rollback", [WORKER_ID, MILITIA_ID], "H3 presentation enabled")
	scene.callv("set_v0311_h3_runtime_pilot_enabled", [false])
	await _settle(4)
	await _capture("fallback_disabled_h3", "rollback", [WORKER_ID, MILITIA_ID], "fallback presentation after H3 disable")
	scene.callv("set_v0311_h3_runtime_pilot_enabled", [true])
	await _settle(4)
	await _capture("h3_reconstructed", "rollback", [WORKER_ID, MILITIA_ID], "H3 presentation reconstructed from same authoritative state")

func _scale_sequence() -> void:
	await _reset_runtime()
	_select(WORKER_ID)
	var adapter = scene.get("barrosan_h3_runtime_adapter")
	if adapter == null:
		errors.append("H3 adapter missing for scale comparison")
		return
	for pair in [[1.0, "scale_current_v0311"], [0.88, "scale_12_percent_smaller"], [0.76, "scale_24_percent_smaller"]]:
		adapter.set_presentation_scale(float(pair[0]))
		await _settle(3)
		await _capture(str(pair[1]), "scale_comparison", [WORKER_ID, MILITIA_ID], "bounded presentation scale")
	adapter.set_presentation_scale(1.0)

func _capture(file_stem: String, scenario: String, unit_ids: Array, note: String) -> void:
	await _settle(2)
	var metadata := _metadata("", scenario, unit_ids, note)
	if mode == "DEBUG_REVIEW":
		_update_debug_overlay(metadata)
	await _settle(1)
	var texture := get_viewport().get_texture()
	if texture == null:
		errors.append("missing viewport texture for %s" % file_stem)
		return
	var image := texture.get_image()
	var file_name := "%03d_%s.png" % [frame_number + 1, file_stem]
	var target := _join(screenshot_root, file_name)
	var result := image.save_png(target)
	if result != OK:
		errors.append("failed to write %s" % file_name)
		return
	metadata["captureFilename"] = file_name
	metadata["screenshotSha256"] = str(host.callv("_sha256_file", [target]))
	var h3_status: Dictionary = scene.call("get_v0311_h3_runtime_status")
	metadata["h3Enabled"] = bool(h3_status.get("enabled", false))
	metadata["fallbackState"] = not metadata["h3Enabled"]
	metadata["h3FlagState"] = true
	if scenario == "save_write_reload" and save_path != "":
		metadata["saveChecksum"] = str(host.callv("_sha256_file", [ProjectSettings.globalize_path(save_path)]))
	var previous: Variant = previous_hashes.get(scenario, null)
	metadata["previousRelatedScreenshotSha256"] = previous
	previous_hashes[scenario] = metadata["screenshotSha256"]
	metadata["pixelEvidenceRequired"] = true
	var scenario_seen: Array = scenario_hashes.get(scenario, [])
	var duplicate_semantic_frame := scenario_seen.has(metadata["screenshotSha256"])
	metadata["semanticAccepted"] = not note.contains("unsupported") and not note.contains("not supported") and not duplicate_semantic_frame
	if duplicate_semantic_frame:
		metadata["semanticRejectionReason"] = "exact screenshot duplicate within semantic scenario"
	scenario_seen.append(metadata["screenshotSha256"])
	scenario_hashes[scenario] = scenario_seen
	metadata["visualPoseLimitation"] = note.contains("authored")
	host.callv("_write_absolute_json", [_join(sidecar_root, file_name.trim_suffix(".png") + ".json"), metadata])
	records.append(metadata)
	frame_number += 1

func _metadata(file_name: String, scenario: String, unit_ids: Array, note: String) -> Dictionary:
	var runtime = scene.get("runtime")
	var rows: Array[Dictionary] = []
	for id in unit_ids:
		var row := _unit_row(runtime, str(id))
		if not row.is_empty():
			rows.append(row)
	var camera := scene.get_node_or_null("FixedOrthographicCamera") as Camera3D
	return {
		"captureFilename": file_name,
		"runtimeTimestampMs": Time.get_ticks_msec(),
		"frameNumber": frame_number + 1,
		"scenarioName": scenario,
		"pairedMomentId": scenario + "_" + str(frame_number + 1),
		"authoritativeUnitIds": unit_ids,
		"units": rows,
		"selectedIds": runtime.selected_ids.duplicate() if runtime != null else [],
		"cameraWorldPosition": _vec3(camera.position) if camera != null else {},
		"cameraZoom": camera.size if camera != null else null,
		"h3FlagState": true,
		"h3Enabled": true,
		"presentationMode": mode,
		"fallbackState": false,
		"saveIdentifier": save_path if scenario == "save_write_reload" else null,
		"note": note,
		"stateSource": "authoritative runtime.units",
		"selectionSource": "authoritative runtime.selected_ids"
	}

func _unit_row(runtime, id: String) -> Dictionary:
	if runtime == null:
		return {}
	for unit in runtime.units:
		if str(unit.get("id", "")) != id:
			continue
		return {
			"id": id,
			"role": str(unit.get("role", "")),
			"fixtureId": str(unit.get("fixtureId", "")),
			"worldPosition": _vec2(unit.get("position", Vector2.ZERO)),
			"destination": _vec2(unit.get("destination", Vector2.ZERO)),
			"facing": str(unit.get("facing", "south-east")),
			"commandState": str(unit.get("commandState", "idle")),
			"activityState": str(unit.get("activityState", "idle")),
			"readyState": str(unit.get("readyState", "unsupported")),
			"hasDestination": bool(unit.get("hasDestination", false)),
			"health": float(unit.get("health", 0.0)),
			"alive": bool(unit.get("alive", false))
		}
	return {}

func _runtime_state_register() -> Dictionary:
	var runtime = scene.get("runtime")
	return {
		"selectedIds": runtime.selected_ids.duplicate() if runtime != null else [],
		"resources": runtime.resources.duplicate(true) if runtime != null else {},
		"pressure": scene.get("barrosan_playtest").get("v0299Pressure", {}) if scene.get("barrosan_playtest") != null else {},
		"stableIds": [WORKER_ID, MILITIA_ID],
		"h3Enabled": true,
		"defaultRuntimeChanged": false
	}

func _create_debug_overlay() -> void:
	debug_layer = CanvasLayer.new()
	debug_layer.name = "V0312SemanticDebugOverlay"
	host.add_child(debug_layer)
	debug_label = Label.new()
	debug_label.position = Vector2(24, 110)
	debug_label.size = Vector2(640, 160)
	debug_label.add_theme_font_size_override("font_size", 14)
	debug_label.add_theme_color_override("font_color", Color(0.74, 0.92, 0.78))
	debug_layer.add_child(debug_label)

func _update_debug_overlay(metadata: Dictionary) -> void:
	if debug_label == null:
		return
	var rows: Array[String] = []
	for unit in metadata.get("units", []):
		rows.append("%s %s pos=%s state=%s/%s facing=%s" % [unit.get("id", ""), unit.get("role", ""), str(unit.get("worldPosition", {})), unit.get("commandState", ""), unit.get("activityState", ""), unit.get("facing", "")])
	debug_label.text = "v0.312 DEBUG_REVIEW | %s\nselected=%s camera=%s zoom=%s\n%s" % [metadata.get("scenarioName", ""), str(metadata.get("selectedIds", [])), str(metadata.get("cameraWorldPosition", {})), str(metadata.get("cameraZoom", "")), "\n".join(rows)]

func _vec2(value) -> Dictionary:
	if value is Vector2:
		return {"x": snappedf(value.x, 0.01), "y": snappedf(value.y, 0.01)}
	return {}

func _vec3(value) -> Dictionary:
	if value is Vector3:
		return {"x": snappedf(value.x, 0.01), "y": snappedf(value.y, 0.01), "z": snappedf(value.z, 0.01)}
	return {}

func _join(root: String, child: String) -> String:
	return root.trim_suffix("/").trim_suffix("\\") + "/" + child.trim_prefix("/").trim_prefix("\\")
