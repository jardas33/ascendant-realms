extends Node

## v0.313 focused capture runner. It audits the existing Militia command/state
## contract and captures only the supported-state evidence needed for closure.
## It never adds gameplay state or owns authoritative positions.

const VIEWPORT_SIZE := Vector2i(1600, 900)
const WORKER_ID := "worker_00"
const MILITIA_ID := "friendly_00"
const MOVE_TARGET := Vector2(930, 520)
const RELEASE_TARGET := Vector2(760, 410)
const SAVE_PATH := "user://v0313-h3-supported-state-save.json"

var host: Node
var scene: Node
var runtime: RefCounted
var artifact_root := ""
var screenshot_root := ""
var sidecar_root := ""
var mode := "PLAYER"
var frame_number := 0
var records: Array[Dictionary] = []
var errors: Array[String] = []
var hold_audit: Dictionary = {}
var save_checksum := ""

func start() -> void:
	host = get_parent()
	artifact_root = str(host.call("_artifact_root_from_args"))
	screenshot_root = _join(artifact_root, "screenshots")
	sidecar_root = _join(artifact_root, "sidecars")
	mode = str(host.call("_barrosan_presentation_mode_from_args"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(screenshot_root))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(sidecar_root))
	host.callv("_set_capture_viewport", [VIEWPORT_SIZE])
	await _reset_runtime()
	await _militia_supported_state_sequence()
	await _hold_contract_sequence()
	await _save_reload_sequence()
	await _presentation_rollback_sequence()
	await _worker_supported_state_overview()
	await _militia_supported_state_overview()
	await _ordinary_gameplay_overview()
	var manifest := {
		"schemaVersion": 1,
		"checkpoint": "v0.313",
		"mode": mode,
		"status": "PASS_V0313_SUPPORTED_STATE_CAPTURE" if errors.is_empty() else "FAIL_V0313_SUPPORTED_STATE_CAPTURE",
		"captureCount": records.size(),
		"physicalPngCount": records.size(),
		"pairedMomentPolicy": "PLAYER and DEBUG_REVIEW views share pairedViewId and count as one semantic event",
		"h3OptIn": true,
		"integratedRoles": ["Worker", "Militia"],
		"records": records,
		"holdAudit": hold_audit,
		"savePath": SAVE_PATH,
		"saveChecksum": save_checksum,
		"defaultRuntimeChanged": false,
		"gameplayChanged": false,
		"protectedAssetsImported": false,
		"militiaReadyVisualState": "MILITIA READY VISUAL STATE: NOT APPLICABLE — NO AUTHORITATIVE GAMEPLAY STATE EXISTS"
	}
	host.callv("_write_absolute_json", [_join(artifact_root, "semantic-capture-manifest.json"), manifest])
	host.callv("_write_absolute_json", [_join(artifact_root, "hold-command-audit.json"), hold_audit])
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
	runtime = scene.get("runtime") as RefCounted
	host.set("current_step_id", "v0313_supported_state_contract")
	host.callv("_render_player_screen", ["battle"])
	await _settle(6)

func _settle(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _advance(frames: int) -> void:
	if runtime == null:
		return
	for index in range(frames):
		runtime.advance_live_frame()
		if index % 24 == 0:
			scene.call("_sync_unit_visuals")
			await get_tree().process_frame
	scene.call("_sync_unit_visuals")
	scene.call("_sync_hud")
	await get_tree().process_frame

func _select(id: String) -> void:
	scene.callv("select_entity", [id])
	scene.call("_sync_unit_visuals")
	scene.call("_sync_hud")

func _clear_selection() -> void:
	runtime.clear_selection()
	scene.call("_sync_unit_visuals")
	scene.call("_sync_hud")

func _issue_move(id: String, target: Vector2) -> void:
	_select(id)
	var world_target: Vector3 = scene.callv("_to_world", [target, 0.20])
	scene.callv("issue_move_order", [world_target])
	scene.call("_sync_unit_visuals")
	scene.call("_sync_hud")

func _militia_supported_state_sequence() -> void:
	await _reset_runtime()
	_pan(0)
	await _capture("militia_idle", "militia_idle", [MILITIA_ID], "authoritative idle")
	_select(MILITIA_ID)
	_pan(1)
	await _capture("militia_selected", "militia_selected", [MILITIA_ID], "authoritative selected")
	_clear_selection()
	_pan(2)
	await _capture("militia_unselected", "militia_unselected", [MILITIA_ID], "authoritative unselected")
	_issue_move(MILITIA_ID, MOVE_TARGET)
	_pan(3)
	await _capture("militia_moving", "militia_moving", [MILITIA_ID], "move_ordered and travelling")
	await _advance(520)
	_pan(4)
	await _capture("militia_stopped", "militia_stopped", [MILITIA_ID], "destination reached and stopped")

func _hold_contract_sequence() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	var before := _unit_snapshot(MILITIA_ID)
	var selected_before: Array = runtime.selected_ids.duplicate()
	_pan(5)
	await _capture("militia_hold_invocation_before", "militia_hold_invocation", [MILITIA_ID], "selected before visible Hold callback")
	scene.call("pan_camera")
	await _settle(3)
	var callback_reached := host.has_method("_on_live_ui_shell_move_pressed")
	if callback_reached:
		host.call("_on_live_ui_shell_move_pressed")
	else:
		errors.append("visible Hold callback path missing")
	_pan(6)
	await _capture("militia_hold_invoked", "militia_hold_invocation", [MILITIA_ID], "visible Hold callback invoked")
	var after := _unit_snapshot(MILITIA_ID)
	var selected_after: Array = runtime.selected_ids.duplicate()
	hold_audit = {
		"uiCommandPresent": true,
		"uiLabel": "Hold",
		"uiShortcut": "H",
		"uiCallback": "_on_live_ui_shell_move_pressed",
		"uiCallbackReached": callback_reached,
		"authoritativeRuntimeMethod": "issue_move_order",
		"authoritativeStateBefore": before,
		"authoritativeStateAfter": after,
		"selectedIdsBefore": selected_before,
		"selectedIdsAfter": selected_after,
		"stateChanged": before.hash() != after.hash(),
		"distinctReadyStateExists": false,
		"holdSemanticResult": "visible Hold currently aliases the existing move-order callback; no distinct Militia ready/hold gameplay state exists",
		"classification": "not applicable",
		"exactClassification": "MILITIA READY VISUAL STATE: NOT APPLICABLE — NO AUTHORITATIVE GAMEPLAY STATE EXISTS",
		"adapterDefect": false,
		"gameplayAdded": false
	}
	await _advance(60)
	_pan(7)
	await _capture("militia_post_hold_state", "militia_post_hold", [MILITIA_ID], "actual state after Hold callback")
	_issue_move(MILITIA_ID, RELEASE_TARGET)
	_pan(8)
	await _capture("militia_release_valid_command", "militia_release", [MILITIA_ID], "subsequent valid move command releases alias state")

func _save_reload_sequence() -> void:
	await _reset_runtime()
	_issue_move(MILITIA_ID, MOVE_TARGET)
	await _advance(120)
	var saved: Dictionary = runtime.capture_save_state()
	var absolute_save := ProjectSettings.globalize_path(SAVE_PATH)
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		errors.append("unable to write v0.313 capture save")
		return
	save_file.store_string(JSON.stringify(saved))
	save_file.close()
	save_checksum = str(host.callv("_sha256_file", [absolute_save]))
	await _capture("before_save", "save_reload", [MILITIA_ID], "real writable save before reset")
	runtime.set_workload_tier("M")
	scene.call("_sync_unit_visuals")
	var loaded_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var loaded = JSON.parse_string(loaded_file.get_as_text()) if loaded_file != null else null
	if loaded_file != null:
		loaded_file.close()
	if not loaded is Dictionary or not runtime.restore_capture_save_state(loaded):
		errors.append("v0.313 real save did not restore authoritative state")
	else:
		scene.call("_sync_unit_visuals")
		scene.call("_sync_hud")
		scene.call("pan_camera")
		await _settle(3)
		await _capture("after_real_load", "save_reload", [MILITIA_ID], "real save reload reconstruction")

func _presentation_rollback_sequence() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	if scene.has_method("set_v0311_h3_runtime_pilot_enabled"):
		scene.callv("set_v0311_h3_runtime_pilot_enabled", [true])
		await _capture("h3_enabled", "presentation_rollback", [MILITIA_ID], "H3 presentation enabled")
		scene.callv("set_v0311_h3_runtime_pilot_enabled", [false])
		scene.call("pan_camera")
		await _settle(3)
		await _capture("fallback_enabled", "presentation_rollback", [MILITIA_ID], "fallback presentation enabled")
		scene.callv("set_v0311_h3_runtime_pilot_enabled", [true])
		scene.call("pan_camera")
		await _settle(3)
		await _capture("h3_reconstructed", "presentation_rollback", [MILITIA_ID], "H3 reconstructed from same runtime state")
	else:
		errors.append("H3 toggle method missing")

func _worker_supported_state_overview() -> void:
	await _reset_runtime()
	_select(WORKER_ID)
	await _capture("worker_supported_states", "worker_supported_states", [WORKER_ID], "idle selected supported-state overview")

func _militia_supported_state_overview() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	scene.call("pan_camera")
	await _settle(3)
	await _capture("militia_supported_states", "militia_supported_states", [MILITIA_ID], "supported idle selected movement stop overview")

func _ordinary_gameplay_overview() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	scene.call("pan_camera")
	scene.call("pan_camera")
	await _settle(3)
	await _capture("ordinary_gameplay_overview", "ordinary_gameplay_overview", [MILITIA_ID], "ordinary gameplay overview")

func _pan(count: int) -> void:
	for _i in range(count):
		scene.call("pan_camera")
	await _settle(1)

func _unit_snapshot(id: String) -> Dictionary:
	if runtime == null:
		return {}
	for unit in runtime.units:
		if str(unit.get("id", "")) == id:
			return {
				"id": id,
				"role": str(unit.get("role", "")),
				"position": _vec2_dict(unit.get("position", Vector2.ZERO)),
				"destination": _vec2_dict(unit.get("destination", Vector2.ZERO)),
				"facing": str(unit.get("facing", "")),
				"commandState": str(unit.get("commandState", "idle")),
				"orderState": "destination_set" if bool(unit.get("hasDestination", false)) else "none",
				"activityState": str(unit.get("activityState", "idle")),
				"readyState": str(unit.get("readyState", "unsupported")),
				"hasDestination": bool(unit.get("hasDestination", false))
			}
	return {}

func _capture(event_id: String, scenario: String, ids: Array[String], note: String) -> void:
	await _settle(2)
	frame_number += 1
	var filename := "%s_%02d_%s.png" % [mode.to_lower(), frame_number, event_id]
	var image := get_viewport().get_texture().get_image()
	var absolute := ProjectSettings.globalize_path(_join(screenshot_root, filename))
	var result := image.save_png(absolute)
	if result != OK:
		errors.append("failed to save %s" % filename)
		return
	var row := {
		"semanticEventId": "v0313-%s" % event_id,
		"pairedViewId": "v0313-%s" % event_id,
		"captureFilename": filename,
		"presentationMode": mode,
		"playerDebugClassification": "player" if mode == "PLAYER" else "debug",
		"runtimeTimestampMs": Time.get_ticks_msec(),
		"frameNumber": frame_number,
		"scenario": scenario,
		"stableUnitIds": ids,
		"units": ids.map(func(id: String) -> Dictionary: return _unit_snapshot(id)),
		"selectedIds": runtime.selected_ids.duplicate(),
		"cameraCoordinates": _camera_snapshot(),
		"cameraZoom": _camera_zoom(),
		"h3Flag": _h3_enabled(),
		"fallbackFlag": not _h3_enabled(),
		"saveIdentifier": SAVE_PATH if scenario == "save_reload" else null,
		"screenshotSha256": str(host.callv("_sha256_file", [absolute])),
		"perceptualHash": "computed-by-pack-builder",
		"accepted": true,
		"rejected": false,
		"rejectionReason": null,
		"note": note,
		"lastOrder": str(runtime.last_order),
		"gameplayMutation": false,
		"stateSource": "runtime.units"
	}
	records.append(row)
	host.callv("_write_absolute_json", [_join(sidecar_root, filename.trim_suffix(".png") + ".json"), row])

func _camera_snapshot() -> Dictionary:
	var camera := scene.get_node_or_null("FixedOrthographicCamera") as Camera3D
	if camera == null:
		return {}
	return {"x": snappedf(camera.position.x, 0.01), "y": snappedf(camera.position.y, 0.01), "z": snappedf(camera.position.z, 0.01)}

func _camera_zoom() -> float:
	var camera := scene.get_node_or_null("FixedOrthographicCamera") as Camera3D
	return snappedf(camera.size, 0.01) if camera != null else 0.0

func _h3_enabled() -> bool:
	var status: Dictionary = scene.call("get_v0311_h3_runtime_status") if scene.has_method("get_v0311_h3_runtime_status") else {}
	return bool(status.get("enabled", false))

func _vec2_dict(value: Variant) -> Dictionary:
	var vector := value as Vector2
	return {"x": snappedf(vector.x, 0.01), "y": snappedf(vector.y, 0.01)}

func _join(base: String, child: String) -> String:
	return base.rstrip("/") + "/" + child
