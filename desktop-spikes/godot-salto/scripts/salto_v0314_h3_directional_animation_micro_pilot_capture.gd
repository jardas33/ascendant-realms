extends Node

## v0.314 opt-in capture runner. It records real runtime frames while the H3
## adapter binds only to authoritative Worker/Militia state.

const VIEWPORT_SIZE := Vector2i(1600, 900)
const WORKER_ID := "worker_00"
const MILITIA_ID := "friendly_00"
const MOVE_TARGET := Vector2(930, 520)

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
	await _capture("01_preflight_runtime", "preflight", [], "real opt-in runtime loaded")
	await _capture("02_worker_idle_01", "worker_idle", [WORKER_ID], "Worker idle frame 1")
	await _settle(8)
	await _capture("03_worker_idle_02", "worker_idle", [WORKER_ID], "Worker idle frame 2")
	_select(WORKER_ID)
	await _capture("04_worker_idle_selected", "worker_idle_selected", [WORKER_ID], "Worker selected idle")
	_issue_move(WORKER_ID, MOVE_TARGET)
	await _settle(6)
	await _capture("05_worker_locomotion_01", "worker_locomotion", [WORKER_ID], "Worker authoritative travelling frame")
	await _settle(8)
	await _capture("06_worker_locomotion_02", "worker_locomotion", [WORKER_ID], "Worker locomotion phase variation")
	await _reset_runtime()
	_select(WORKER_ID)
	scene.call("assign_worker_to_mine")
	scene.call("_sync_unit_visuals")
	await _settle(4)
	await _capture("07_worker_work_01", "worker_work", [WORKER_ID], "Worker authoritative working frame")
	await _settle(8)
	await _capture("08_worker_work_02", "worker_work", [WORKER_ID], "Worker work phase variation")
	await _reset_runtime()
	_select(MILITIA_ID)
	await _capture("09_militia_idle_selected", "militia_idle", [MILITIA_ID], "Militia idle selected")
	await _settle(8)
	await _capture("10_militia_idle_phase", "militia_idle", [MILITIA_ID], "Militia idle phase variation")
	_issue_move(MILITIA_ID, MOVE_TARGET)
	await _settle(6)
	await _capture("11_militia_locomotion_01", "militia_locomotion", [MILITIA_ID], "Militia authoritative travelling frame")
	await _settle(8)
	await _capture("12_militia_locomotion_02", "militia_locomotion", [MILITIA_ID], "Militia locomotion phase variation")
	await _advance_authoritative(520)
	await _capture("13_militia_arrival", "militia_arrival", [MILITIA_ID], "Militia authoritative arrival stops locomotion")
	await _settle(8)
	await _capture("14_militia_idle_after_arrival", "militia_idle_after_arrival", [MILITIA_ID], "Militia idle after arrival")
	await _reset_runtime()
	_select(MILITIA_ID)
	await _capture("15_hold_ui_contract", "hold_ui_contract", [MILITIA_ID], "Hold is hidden in PLAYER or disabled in DEBUG_REVIEW")
	await _capture("16_scale_current", "scale_comparison", [MILITIA_ID], "H3 presentation scale CURRENT")
	var saved: Dictionary = runtime.capture_save_state()
	await _capture("17_before_save", "save_reload", [MILITIA_ID], "authoritative state before capture save")
	if not runtime.restore_capture_save_state(saved):
		errors.append("capture save did not reconstruct authoritative state")
	scene.call("_sync_unit_visuals")
	await _capture("18_after_real_load", "save_reload", [MILITIA_ID], "authoritative state after capture save reconstruction")
	await _capture("19_mixed_formation", "mixed_formation", [WORKER_ID, MILITIA_ID], "mixed Worker/Militia presentation")
	await _capture("20_bridge_crossing", "bridge_crossing", [MILITIA_ID], "bridge and road context retained")
	await _capture("21_road_traversal", "road_traversal", [MILITIA_ID], "road traversal context retained")
	await _capture("22_ordinary_gameplay", "ordinary_gameplay", [WORKER_ID, MILITIA_ID], "ordinary gameplay overview")
	if scene.has_method("set_v0314_h3_directional_animation_enabled"):
		scene.callv("set_v0314_h3_directional_animation_enabled", [false])
		await _settle(3)
		await _capture("23_static_rollback", "rollback", [MILITIA_ID], "v0.311 static adapter rollback")
		scene.callv("set_v0314_h3_directional_animation_enabled", [true])
		await _settle(3)
		await _capture("24_animation_reconstructed", "rollback", [MILITIA_ID], "v0.314 reconstructed from unchanged runtime")
	else:
		errors.append("v0.314 toggle method missing")
	var h3_status: Dictionary = scene.call("get_v0314_h3_directional_animation_status") if scene.has_method("get_v0314_h3_directional_animation_status") else {}
	var hold_contract := _hold_contract()
	var manifest := {
		"schemaVersion": 1,
		"checkpoint": "v0.314",
		"mode": mode,
		"status": "PASS_V0314_H3_DIRECTIONAL_ANIMATION_CAPTURE" if errors.is_empty() else "FAIL_V0314_H3_DIRECTIONAL_ANIMATION_CAPTURE",
		"captureCount": records.size(),
		"physicalPngCount": records.size(),
		"h3OptIn": true,
		"integratedRoles": ["Worker", "Militia"],
		"animationStatus": h3_status,
		"holdUiContract": "HIDDEN_WHEN_UNSUPPORTED",
		"holdAudit": hold_contract,
		"records": records,
		"defaultRuntimeChanged": false,
		"gameplayChanged": false,
		"movementOwnedByAnimation": false,
		"rootMotion": false,
	}
	host.callv("_write_absolute_json", [_join(artifact_root, "capture-manifest.json"), manifest])
	host.callv("_write_absolute_json", [_join(artifact_root, "hold-contract-audit.json"), hold_contract])
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
	host.set("current_step_id", "v0314_h3_directional_animation_micro_pilot")
	host.callv("_render_player_screen", ["battle"])
	await _settle(6)

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

func _settle(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _advance_authoritative(frames: int) -> void:
	for index in range(frames):
		runtime.advance_live_frame()
		if index % 24 == 0:
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
		"semanticEventId": "v0314-%s" % event_id,
		"captureFilename": filename,
		"presentationMode": mode,
		"scenario": scenario,
		"stableUnitIds": ids,
		"selectedIds": runtime.selected_ids.duplicate() if runtime != null else [],
		"units": ids.map(func(id: String) -> Dictionary: return _unit_snapshot(id)),
		"animationStatus": scene.call("get_v0314_h3_directional_animation_status") if scene.has_method("get_v0314_h3_directional_animation_status") else {},
		"holdContract": "HIDDEN_WHEN_UNSUPPORTED",
		"gameplayMutation": false,
		"rootMotion": false,
		"screenshotSha256": str(host.callv("_sha256_file", [absolute])),
		"note": note,
	}
	records.append(row)
	host.callv("_write_absolute_json", [_join(sidecar_root, filename.trim_suffix(".png") + ".json"), row])

func _hold_contract() -> Dictionary:
	var status: Dictionary = host.callv("_v0210_selection_panel_data", ["militia_panel", host.call("get_spike_status")])
	var labels: Array[String] = []
	for command in status.get("commands", []):
		labels.append(str(command.get("label", "")))
	return {
		"contract": "HIDDEN_WHEN_UNSUPPORTED",
		"mode": mode,
		"holdVisible": labels.has("Hold"),
		"holdLabels": labels,
		"holdCallback": "",
		"moveCallbackReachableFromHold": false,
		"hShortcutBound": false,
		"authoritativeReadyState": false,
		"noGameplayAdded": true,
	}

func _unit_snapshot(id: String) -> Dictionary:
	for unit in runtime.units:
		if str(unit.get("id", "")) == id:
			return {"id": id, "position": _vec2_dict(unit.get("position", Vector2.ZERO)), "destination": _vec2_dict(unit.get("destination", Vector2.ZERO)), "facing": str(unit.get("facing", "")), "commandState": str(unit.get("commandState", "idle")), "activityState": str(unit.get("activityState", "idle")), "hasDestination": bool(unit.get("hasDestination", false))}
	return {}

func _vec2_dict(value: Variant) -> Dictionary:
	var vector := value as Vector2
	return {"x": snappedf(vector.x, 0.01), "y": snappedf(vector.y, 0.01)}

func _join(base: String, child: String) -> String:
	return base.rstrip("/") + "/" + child
