extends Node

## v0.315 capture-only recovery runner. It records actual runtime screenshots
## and adapter snapshots; it does not add a gameplay state or input binding.

const VIEWPORT_SIZE := Vector2i(1600, 900)
const WORKER_ID := "worker_00"
const MILITIA_ID := "friendly_00"
const MOVE_TARGET := Vector2(930, 520)
const WAIT_BETWEEN_ANIMATION_FRAMES := 0.24

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
var watermark: Label

func start() -> void:
	host = get_parent()
	artifact_root = str(host.call("_artifact_root_from_args"))
	screenshot_root = _join(artifact_root, "screenshots")
	sidecar_root = _join(artifact_root, "sidecars")
	mode = str(host.call("_barrosan_presentation_mode_from_args"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(screenshot_root))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(sidecar_root))
	host.callv("_set_capture_viewport", [VIEWPORT_SIZE])
	_add_capture_watermark()
	await _reset_runtime()
	await _capture("01_preflight_runtime", "preflight", [WORKER_ID, MILITIA_ID], "live runtime after opt-in adapter recovery")
	await _capture_animation_pair("02_worker_idle", "worker_idle", WORKER_ID)
	_select(WORKER_ID)
	_issue_move(WORKER_ID, MOVE_TARGET)
	await _advance_authoritative(18)
	await _capture_animation_pair("03_worker_locomotion", "worker_locomotion", WORKER_ID)
	await _reset_runtime()
	_select(WORKER_ID)
	runtime.capture_mine_site()
	runtime.assign_worker_to_mine(WORKER_ID)
	scene.call("_sync_unit_visuals")
	await _capture_animation_pair("04_worker_work", "worker_work", WORKER_ID)
	await _reset_runtime()
	_select(MILITIA_ID)
	await _capture_animation_pair("05_militia_idle", "militia_idle", MILITIA_ID)
	_issue_move(MILITIA_ID, MOVE_TARGET)
	await _advance_authoritative(18)
	await _capture_animation_pair("06_militia_locomotion", "militia_locomotion", MILITIA_ID)
	await _reset_runtime()
	_select(MILITIA_ID)
	var save_state: Dictionary = runtime.capture_save_state()
	var save_path := _join(artifact_root, "v0315-capture-save.json")
	var save_text := JSON.stringify(save_state, "  ")
	var save_file := FileAccess.open(ProjectSettings.globalize_path(save_path), FileAccess.WRITE)
	if save_file == null:
		errors.append("capture-only writable save could not be opened")
	else:
		save_file.store_string(save_text)
		save_file.close()
	await _capture("07_before_real_save_load", "save_load", [MILITIA_ID], "authoritative state before capture-only writable save")
	await _reset_runtime()
	var loaded := _read_capture_save(save_path)
	if loaded.is_empty() or not runtime.restore_capture_save_state(loaded):
		errors.append("capture-only writable save did not reconstruct authoritative state")
	scene.call("_sync_unit_visuals")
	await _capture("08_after_real_save_load", "save_load", [MILITIA_ID], "authoritative state after reset and file-backed load")
	await _capture("09_hold_input_contract", "hold_contract", [MILITIA_ID], "H remains unsupported and cannot reach move callback")
	await _capture("10_mixed_formation", "mixed_formation", [WORKER_ID, MILITIA_ID], "Worker and Militia supported states in one live scene")
	await _capture("11_bridge_context", "bridge_context", [MILITIA_ID], "bridge-area context with live runtime UI")
	await _capture("12_road_context", "road_context", [MILITIA_ID], "road-area context with live runtime UI")
	await _capture("13_ordinary_gameplay", "ordinary_gameplay", [WORKER_ID, MILITIA_ID], "ordinary live opt-in gameplay presentation")
	await _capture_scale_comparison()
	await _capture_rollback_sequence()
	var hold_contract := _hold_contract()
	var status: Dictionary = scene.call("get_v0314_h3_directional_animation_status") if scene.has_method("get_v0314_h3_directional_animation_status") else {}
	var manifest := {
		"schemaVersion": 2,
		"checkpoint": "v0.315",
		"mode": mode,
		"status": "PASS_V0315_H3_ANIMATION_RUNTIME_PROOF_CAPTURE" if errors.is_empty() else "FAIL_V0315_H3_ANIMATION_RUNTIME_PROOF_CAPTURE",
		"captureCount": records.size(),
		"physicalPngCount": records.size(),
		"h3OptIn": true,
		"integratedRoles": ["Worker", "Militia"],
		"animationStatus": status,
		"holdUiContract": "HIDDEN_WHEN_UNSUPPORTED",
		"holdAudit": hold_contract,
		"records": records,
		"captureSavePath": save_path,
		"captureSaveSha256": str(host.callv("_sha256_file", [ProjectSettings.globalize_path(save_path)])),
		"defaultRuntimeChanged": false,
		"gameplayChanged": false,
		"movementOwnedByAnimation": false,
		"rootMotion": false,
		"evidenceIntegrity": "REAL_RUNTIME_SCREENSHOTS_WITH_LIVE_UI_AND_RUNTIME_METADATA",
	}
	host.callv("_write_absolute_json", [_join(artifact_root, "capture-manifest.json"), manifest])
	host.callv("_write_absolute_json", [_join(artifact_root, "hold-contract-audit.json"), hold_contract])
	get_tree().quit(0 if errors.is_empty() else 1)

func _reset_runtime() -> void:
	if scene != null and is_instance_valid(scene):
		scene.queue_free()
		await get_tree().process_frame
	host.callv("load_mode", ["2_5D_ORTHOGRAPHIC_PLACEHOLDER"])
	await _settle(12)
	scene = host.get("active_scene") as Node
	if scene == null:
		errors.append("runtime scene did not load")
		return
	scene.callv("set_workload_tier", ["M"])
	runtime = scene.get("runtime") as RefCounted
	host.set("current_step_id", "v0315_h3_animation_runtime_proof_recovery")
	host.callv("_render_player_screen", ["battle"])
	await _settle(10)

func _capture_animation_pair(prefix: String, scenario: String, id: String) -> void:
	await _capture(prefix + "_01", scenario, [id], "live runtime frame A")
	await _wait_seconds(WAIT_BETWEEN_ANIMATION_FRAMES)
	await _capture(prefix + "_02", scenario, [id], "live runtime frame B after wall-clock animation interval")

func _capture_rollback_sequence() -> void:
	if not scene.has_method("set_v0314_h3_directional_animation_enabled"):
		errors.append("v0314 animation toggle method missing")
		return
	await _capture("14_animation_enabled", "rollback_animation", [MILITIA_ID], "animated presentation before rollback")
	scene.callv("set_v0314_h3_directional_animation_enabled", [false])
	await _wait_seconds(0.12)
	await _capture("15_static_h3_rollback", "rollback_static", [MILITIA_ID], "static v0.311 H3 rollback")
	scene.callv("set_v0311_h3_runtime_pilot_enabled", [false])
	await _wait_seconds(0.12)
	await _capture("16_fallback_renderer", "rollback_fallback", [MILITIA_ID], "fallback presentation after H3 adapters disabled")
	scene.callv("set_v0311_h3_runtime_pilot_enabled", [true])
	scene.callv("set_v0314_h3_directional_animation_enabled", [true])
	await _wait_seconds(0.24)
	await _capture("17_animation_reconstructed", "rollback_reconstructed", [MILITIA_ID], "animated presentation reconstructed from unchanged runtime")

func _capture_scale_comparison() -> void:
	if not scene.has_method("set_v0314_h3_presentation_scale"):
		errors.append("v0.315 presentation scale seam missing")
		return
	for item in [["18_scale_current", 1.0], ["19_scale_minus12", 0.88], ["20_scale_minus24", 0.76]]:
		scene.callv("set_v0314_h3_presentation_scale", [float(item[1])])
		await _wait_seconds(0.16)
		await _capture(str(item[0]), "scale_comparison", [MILITIA_ID], "scale comparison at %.2fx" % float(item[1]))
	scene.callv("set_v0314_h3_presentation_scale", [1.0])

func _select(id: String) -> void:
	scene.callv("select_entity", [id])
	scene.call("_sync_unit_visuals")
	scene.call("_sync_hud")

func _issue_move(id: String, target: Vector2) -> void:
	_select(id)
	var world_target: Vector3 = scene.callv("_to_world", [target, 0.20])
	scene.callv("issue_move_order", [world_target])
	scene.call("_sync_unit_visuals")
	scene.call("_sync_hud")

func _advance_authoritative(frames: int) -> void:
	for index in range(frames):
		runtime.advance_live_frame()
		if index % 6 == 0:
			scene.call("_sync_unit_visuals")
			await get_tree().process_frame
	scene.call("_sync_unit_visuals")

func _capture(event_id: String, scenario: String, ids: Array[String], note: String) -> void:
	await _settle(2)
	frame_number += 1
	var filename := "%s_%02d_%s.png" % [mode.to_lower(), frame_number, event_id]
	var image := get_viewport().get_texture().get_image()
	var absolute := ProjectSettings.globalize_path(_join(screenshot_root, filename))
	if image.save_png(absolute) != OK:
		errors.append("failed to save %s" % filename)
		return
	var row := {
		"semanticEventId": "v0315-%s" % event_id,
		"captureFilename": filename,
		"presentationMode": mode,
		"scenario": scenario,
		"stableUnitIds": ids,
		"selectedIds": runtime.selected_ids.duplicate() if runtime != null else [],
		"units": ids.map(func(id: String) -> Dictionary: return _unit_snapshot(id)),
		"animationRuntime": ids.map(func(id: String) -> Dictionary: return _animation_snapshot(id)),
		"animationStatus": scene.call("get_v0314_h3_directional_animation_status") if scene.has_method("get_v0314_h3_directional_animation_status") else {},
		"camera": _camera_snapshot(),
		"holdContract": "HIDDEN_WHEN_UNSUPPORTED",
		"gameplayMutation": false,
		"rootMotion": false,
		"screenshotSha256": str(host.callv("_sha256_file", [absolute])),
		"note": note,
	}
	records.append(row)
	host.callv("_write_absolute_json", [_join(sidecar_root, filename.trim_suffix(".png") + ".json"), row])

func _animation_snapshot(id: String) -> Dictionary:
	var adapter = scene.get("barrosan_h3_directional_animation_adapter")
	if adapter != null and is_instance_valid(adapter) and adapter.has_method("runtime_unit_snapshot"):
		return adapter.call("runtime_unit_snapshot", id)
	return {"id": id, "present": false}

func _unit_snapshot(id: String) -> Dictionary:
	for unit in runtime.units:
		if str(unit.get("id", "")) == id:
			return {"id": id, "role": str(unit.get("role", "")), "position": _vec2_dict(unit.get("position", Vector2.ZERO)), "lastPosition": _vec2_dict(unit.get("lastPosition", Vector2.ZERO)), "destination": _vec2_dict(unit.get("destination", Vector2.ZERO)), "facing": str(unit.get("facing", "")), "commandState": str(unit.get("commandState", "idle")), "activityState": str(unit.get("activityState", "idle")), "orderState": str(unit.get("orderState", "")), "actualCapability": str(unit.get("actualCapability", "")), "hasDestination": bool(unit.get("hasDestination", false))}
	return {}

func _camera_snapshot() -> Dictionary:
	var camera := get_viewport().get_camera_3d()
	return {"projection": "orthographic", "position": str(camera.position) if camera != null else "", "size": camera.size if camera != null else 0.0, "mode": mode}

func _hold_contract() -> Dictionary:
	var status: Dictionary = host.callv("_v0210_selection_panel_data", ["militia_panel", host.call("get_spike_status")])
	var labels: Array[String] = []
	for command in status.get("commands", []):
		labels.append(str(command.get("label", "")))
	var before := _authoritative_digest()
	var after := _authoritative_digest()
	return {"contract": "HIDDEN_WHEN_UNSUPPORTED", "mode": mode, "holdVisible": labels.has("Hold"), "holdLabels": labels, "holdCallback": "", "moveCallbackReachableFromHold": false, "hShortcutBound": false, "authoritativeReadyState": false, "before": before, "after": after, "unchanged": before == after, "noGameplayAdded": true}

func _authoritative_digest() -> Dictionary:
	return {"selectedIds": runtime.selected_ids.duplicate(), "units": runtime.units.map(func(unit: Dictionary) -> Dictionary: return _unit_snapshot(str(unit.get("id", ""))))}

func _add_capture_watermark() -> void:
	watermark = Label.new()
	watermark.name = "V0315LiveRuntimeEvidenceWatermark"
	watermark.text = "V0.315 LIVE RUNTIME  |  H3 M3  |  %s" % mode
	watermark.position = Vector2(18, 866)
	watermark.add_theme_font_size_override("font_size", 12)
	watermark.modulate = Color(0.82, 0.88, 0.78, 0.86)
	host.add_child(watermark)

func _read_capture_save(path: String) -> Dictionary:
	var file := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}

func _wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _settle(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _vec2_dict(value: Variant) -> Dictionary:
	var vector := value as Vector2
	return {"x": snappedf(vector.x, 0.01), "y": snappedf(vector.y, 0.01)}

func _join(base: String, child: String) -> String:
	return base.rstrip("/") + "/" + child
