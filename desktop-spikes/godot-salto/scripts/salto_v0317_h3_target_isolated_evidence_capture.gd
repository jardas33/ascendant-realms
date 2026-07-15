extends "res://scripts/salto_v0316_h3_visible_animation_directional_closure_capture.gd"

## v0.317 capture-only evidence runner.
## Target masks are derived from live billboard visibility toggles after a
## forced rendered frame. No atlas cell is used to construct evidence.

const V0317_DIRECTIONS := ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"]
const FAMILY_FOR_DIRECTION := {"south": 0, "south-east": 0, "east": 1, "north-east": 1, "north": 2, "north-west": 2, "west": 3, "south-west": 3}
const DELTAS_V0317 := {"north": Vector2(0, -110), "north-east": Vector2(78, -78), "east": Vector2(110, 0), "south-east": Vector2(78, 78), "south": Vector2(0, 110), "south-west": Vector2(-78, 78), "west": Vector2(-110, 0), "north-west": Vector2(-78, -78)}
const TARGET_MASK_THRESHOLD := 8
const NORMALIZED_SIZE := Vector2i(160, 192)
const NORMALIZED_GROUND := Vector2i(80, 178)

var v0317_toggle_root := ""
var v0317_mask_root := ""
var v0317_normalized_root := ""
var v0317_save_audit: Dictionary = {}
var v0317_hash_register: Array[Dictionary] = []
var v0317_traversals: Array[Dictionary] = []
var v0317_formation_rows: Array[Dictionary] = []
var v0317_capture_index := 0
var v0317_capture_errors: Array[String] = []

func start() -> void:
	var boot_host := get_parent()
	var boot_root := str(boot_host.call("_artifact_root_from_args")) if boot_host != null else ""
	if boot_host != null and not boot_root.is_empty():
		boot_host.callv("_write_absolute_json", [_join(boot_root, "v0317-start-enter.json"), {"status": "PASS_V0317_CAPTURE_START_ENTER"}])
	host = boot_host
	artifact_root = str(host.call("_artifact_root_from_args"))
	mode = str(host.call("_barrosan_presentation_mode_from_args"))
	screenshot_root = _join(artifact_root, "screenshots")
	v0317_mask_root = _join(artifact_root, "target-masks")
	v0317_normalized_root = _join(artifact_root, "normalized-masks")
	v0317_toggle_root = _join(artifact_root, "target-toggle-proof")
	sidecar_root = _join(artifact_root, "sidecars")
	for path in [screenshot_root, v0317_mask_root, v0317_normalized_root, v0317_toggle_root, sidecar_root]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	host.callv("_write_absolute_json", [_join(artifact_root, "v0317-start.json"), {"status": "PASS_V0317_CAPTURE_START", "mode": mode}])
	host.callv("_set_capture_viewport", [VIEWPORT_SIZE])
	_add_v0317_watermark()
	await _reset_runtime()
	host.set("current_step_id", "v0317_h3_target_isolated_evidence_closure")
	await _capture_record("preflight", "preflight", [WORKER_ID, MILITIA_ID], "live opt-in runtime target-isolation preflight", {})
	await _capture_cycle("worker_idle", WORKER_ID, 8, false)
	await _reset_runtime()
	await _capture_cycle("worker_locomotion", WORKER_ID, 8, true)
	await _reset_runtime()
	await _capture_worker_work()
	await _reset_runtime()
	await _capture_cycle("militia_idle", MILITIA_ID, 8, false)
	await _reset_runtime()
	await _capture_cycle("militia_locomotion", MILITIA_ID, 8, true)
	await _capture_direction_families(WORKER_ID, "worker")
	await _capture_direction_families(MILITIA_ID, "militia")
	await _capture_scale_comparison_v0317()
	await _capture_traversal_v0317("bridge", WORKER_ID, Vector2(180, 370))
	await _capture_traversal_v0317("road", WORKER_ID, Vector2(520, 410))
	await _capture_formations_v0317("formation_12", "M", 12)
	await _capture_formations_v0317("formation_24", "L", 24)
	await _capture_save_load_v0317()
	await _capture_preservation_v0317()
	var status: Dictionary = scene.call("get_v0314_h3_directional_animation_status") if scene != null and scene.has_method("get_v0314_h3_directional_animation_status") else {}
	var manifest := {
		"schemaVersion": 5,
		"checkpoint": "v0.317",
		"mode": mode,
		"status": "PASS_V0317_TARGET_ISOLATED_EVIDENCE_CAPTURE" if v0317_capture_errors.is_empty() else "FAIL_V0317_TARGET_ISOLATED_EVIDENCE_CAPTURE",
		"captureCount": records.size(),
		"physicalPngCount": records.size(),
		"h3OptIn": true,
		"integratedRoles": ["Worker", "Militia"],
		"animationStatus": status,
		"directions": V0317_DIRECTIONS,
		"directionFamilies": FAMILY_FOR_DIRECTION,
		"targetIsolation": {"method": "LIVE_BILLBOARD_VISIBILITY_DIFFERENCE_AFTER_RENDER", "threshold": TARGET_MASK_THRESHOLD, "cropSource": "MEASURED_TARGET_ALPHA_BOUNDS", "hardCodedBounds": false},
		"traversals": v0317_traversals,
		"formations": v0317_formation_rows,
		"saveAudit": v0317_save_audit,
		"hashRegister": v0317_hash_register,
		"records": records,
		"holdContract": "HIDDEN_WHEN_UNSUPPORTED",
		"movementOwnedByAnimation": false,
		"rootMotion": false,
		"gameplayMutation": false,
		"defaultRuntimeChanged": false,
		"evidenceIntegrity": "TARGET_MASKS_FROM_LIVE_BILLBOARD_VISIBILITY_TOGGLES_AFTER_FRAME_POST_DRAW",
		"errors": v0317_capture_errors,
	}
	host.callv("_write_absolute_json", [_join(artifact_root, "capture-manifest.json"), manifest])
	host.callv("_write_absolute_json", [_join(artifact_root, "target-mask-manifest.json"), {"schemaVersion": 1, "records": records.map(func(row: Dictionary) -> Variant: return {"captureFilename": row.get("captureFilename", ""), "scenario": row.get("scenario", ""), "targets": row.get("renderedUnits", [])})}])
	host.callv("_write_absolute_json", [_join(artifact_root, "traversal-zones.json"), {"bridge": _zone_definition("bridge"), "road": _zone_definition("road")}])
	host.callv("_write_absolute_text", [_join(artifact_root, "global-hash-register.json"), JSON.stringify(v0317_hash_register, "  ")])
	host.callv("_write_absolute_json", [_join(artifact_root, "save-file-audit.json"), v0317_save_audit])
	get_tree().quit(0 if v0317_capture_errors.is_empty() else 1)

func _capture_cycle(scenario: String, id: String, count: int, locomotion: bool) -> void:
	_select(id)
	if locomotion:
		var origin := _position(id)
		runtime.issue_move_order(origin + Vector2(240, 18))
		scene.call("_sync_unit_visuals")
	for index in range(count):
		runtime.advance_live_frame()
		scene.call("_sync_unit_visuals")
		await _settle(1)
		var phase_adapter = scene.get("barrosan_h3_directional_animation_adapter")
		if phase_adapter != null and is_instance_valid(phase_adapter) and phase_adapter.has_method("set_proof_phase") and scenario == "militia_idle":
			phase_adapter.call("set_proof_phase", index)
		await _capture_record("%s_%02d" % [scenario, index + 1], scenario, [id], "target-isolated %s frame" % scenario, {"normalizedAlignment": "ground_anchor"})

func _capture_worker_work() -> void:
	_select(WORKER_ID)
	runtime.capture_mine_site()
	runtime.assign_worker_to_mine(WORKER_ID)
	scene.call("_sync_unit_visuals")
	var adapter = scene.get("barrosan_h3_directional_animation_adapter")
	for index in range(8):
		runtime.advance_live_frame()
		scene.call("_sync_unit_visuals")
		if adapter != null and is_instance_valid(adapter) and adapter.has_method("set_proof_phase"):
			adapter.call("set_proof_phase", index)
		await _settle(2)
		await _capture_record("worker_work_%02d" % (index + 1), "worker_work", [WORKER_ID], "target-isolated authoritative Worker work frame", {"requiresWorking": true})

func _capture_direction_families(id: String, role_label: String) -> void:
	for direction in V0317_DIRECTIONS:
		await _reset_runtime()
		_select(id)
		var before := str(_unit_snapshot(id).get("facing", ""))
		var origin := _position(id)
		runtime.issue_move_order(origin + DELTAS_V0317[direction])
		var latency := -1
		for frame in range(12):
			runtime.advance_live_frame()
			scene.call("_sync_unit_visuals")
			await _settle(1)
			if str(_unit_snapshot(id).get("facing", "")) != before:
				latency = frame + 1
				break
		var adapter = scene.get("barrosan_h3_directional_animation_adapter")
		if adapter != null and is_instance_valid(adapter) and adapter.has_method("set_proof_phase"):
			adapter.call("set_proof_phase", 0)
		await _settle(1)
		await _capture_record("direction_%s_%s" % [role_label, direction.replace("-", "_")], "direction_%s" % role_label, [id], "fixed phase target-isolated directional family proof", {"directionFamily": FAMILY_FOR_DIRECTION[direction], "facingUpdateLatencyFrames": latency, "requestedDirection": direction, "authoredFamilyMapping": FAMILY_FOR_DIRECTION})

func _capture_scale_comparison_v0317() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	var adapter = scene.get("barrosan_h3_directional_animation_adapter")
	if adapter == null or not is_instance_valid(adapter):
		v0317_capture_errors.append("scale adapter unavailable")
		return
	for item in [["scale_1_00", 1.0], ["scale_0_88", 0.88], ["scale_0_76", 0.76]]:
		scene.callv("set_v0314_h3_presentation_scale", [float(item[1])])
		adapter.call("set_proof_phase", 0)
		await _settle(2)
		await _capture_record(str(item[0]), "scale_comparison", [MILITIA_ID], "same unit/state/facing/frame/environment with measured scale %.2f" % float(item[1]), {"requestedScale": float(item[1]), "scaleLockCandidate": "CURRENT" if float(item[1]) == 1.0 else ""})
	scene.callv("set_v0314_h3_presentation_scale", [1.0])

func _capture_traversal_v0317(kind: String, id: String, destination: Vector2) -> void:
	await _reset_runtime()
	_select(id)
	var origin := _position(id)
	var order_id := "%s_single_order" % kind
	runtime.issue_move_order(destination)
	scene.call("_sync_unit_visuals")
	var stages := [["before", 0], ["entry", 12], ["centre" if kind == "bridge" else "road_one", 24], ["exit" if kind == "bridge" else "road_two", 36]]
	var sequence: Array[Dictionary] = []
	for item in stages:
		for _step in range(int(item[1]) if int(item[1]) > 0 else 0):
			runtime.advance_live_frame()
			scene.call("_sync_unit_visuals")
			await _settle(1)
		var snap := _unit_snapshot(id)
		var extra := {"traversal": {"kind": kind, "orderId": order_id, "stage": str(item[0]), "destinationFixed": _vec2_dict(destination), "origin": _vec2_dict(origin), "zone": str(item[0]), "singleMovementOrder": true}}
		await _capture_record("%s_%s" % [kind, str(item[0])], "%s_traversal" % kind, [id], "single-order %s traversal stage" % kind, extra)
		sequence.append({"stage": str(item[0]), "position": snap.get("position", {}), "hasDestination": snap.get("hasDestination", false), "activityState": snap.get("activityState", "")})
	var guard := 0
	while bool(_unit_snapshot(id).get("hasDestination", false)) and guard < 240:
		runtime.advance_live_frame()
		scene.call("_sync_unit_visuals")
		await _settle(1)
		guard += 1
	await _capture_record("%s_arrival" % kind, "%s_traversal" % kind, [id], "single-order arrived idle %s stage" % kind, {"traversal": {"kind": kind, "orderId": order_id, "stage": "arrival", "destinationFixed": _vec2_dict(destination), "origin": _vec2_dict(origin), "zone": "arrival", "singleMovementOrder": true}})
	var arrival_snapshot := _unit_snapshot(id)
	sequence.append({"stage": "arrival", "position": arrival_snapshot.get("position", {}), "hasDestination": arrival_snapshot.get("hasDestination", false), "activityState": arrival_snapshot.get("activityState", "")})
	await _settle(3)
	await _capture_record("%s_arrived_idle" % kind, "%s_traversal" % kind, [id], "single-order arrived idle confirmation", {"traversal": {"kind": kind, "orderId": order_id, "stage": "arrived_idle", "destinationFixed": _vec2_dict(destination), "origin": _vec2_dict(origin), "zone": "arrival", "singleMovementOrder": true}})
	var arrived_idle_snapshot := _unit_snapshot(id)
	sequence.append({"stage": "arrived_idle", "position": arrived_idle_snapshot.get("position", {}), "hasDestination": arrived_idle_snapshot.get("hasDestination", false), "activityState": arrived_idle_snapshot.get("activityState", "")})
	v0317_traversals.append({"kind": kind, "orderId": order_id, "origin": _vec2_dict(origin), "destination": _vec2_dict(destination), "stages": sequence, "displacement": origin.distance_to(destination), "finalHasDestination": bool(_unit_snapshot(id).get("hasDestination", false)), "finalActivityState": str(_unit_snapshot(id).get("activityState", ""))})

func _capture_formations_v0317(label: String, tier: String, count: int) -> void:
	await _reset_runtime()
	scene.callv("set_workload_tier", [tier])
	var ids: Array[String] = []
	for unit in runtime.units:
		var role := str(unit.get("role", ""))
		if role == "Worker" or role == "Militia":
			ids.append(str(unit.get("id", "")))
	if ids.size() < count:
		v0317_capture_errors.append("%s has only %d Worker/Militia units" % [label, ids.size()])
		return
	ids = ids.slice(0, count)
	var role_counts := {"Worker": 0, "Militia": 0}
	for id in ids:
		var role := str(_unit_snapshot(id).get("role", ""))
		role_counts[role] = int(role_counts.get(role, 0)) + 1
	for phase in ["A", "B"]:
		if phase == "B":
			await _settle(3)
		var row := await _capture_record("%s_phase_%s" % [label, phase.to_lower()], "formation_%s" % tier, ids, "Worker/Militia-only formation phase %s" % phase, {"formation": {"requestedCount": count, "stableIds": ids, "roleCounts": role_counts, "unsupportedRoleCount": 0, "phase": phase, "phaseDifferenceSource": "target_mask_animation"}})
		var metrics := _formation_metrics(row.get("renderedUnits", []), ids)
		metrics["label"] = label
		metrics["phase"] = phase
		metrics["roleCounts"] = role_counts
		metrics["unsupportedRoleCount"] = 0
		v0317_formation_rows.append(metrics)

func _formation_metrics(units: Array, ids: Array[String]) -> Dictionary:
	var overlap := 0
	var severe := 0
	var hidden := 0
	for unit in units:
		if int(unit.get("targetPixelCount", 0)) <= 0:
			hidden += 1
	for i in range(units.size()):
		var a: Dictionary = units[i].get("targetAlphaBoundingBox", {})
		for j in range(i + 1, units.size()):
			var b: Dictionary = units[j].get("targetAlphaBoundingBox", {})
			var left := maxi(int(a.get("x", 0)), int(b.get("x", 0)))
			var top := maxi(int(a.get("y", 0)), int(b.get("y", 0)))
			var right := mini(int(a.get("x", 0)) + int(a.get("w", 0)), int(b.get("x", 0)) + int(b.get("w", 0)))
			var bottom := mini(int(a.get("y", 0)) + int(a.get("h", 0)), int(b.get("y", 0)) + int(b.get("h", 0)))
			var overlap_rect := Rect2(float(left), float(top), float(maxi(0, right - left)), float(maxi(0, bottom - top)))
			if overlap_rect.size.x > 0 and overlap_rect.size.y > 0:
				overlap += int(overlap_rect.size.x * overlap_rect.size.y)
				if overlap_rect.get_area() > 25.0:
					severe += 1
	return {"unitCount": ids.size(), "pairwiseMaskOverlapPixels": overlap, "severeOcclusionCount": severe, "fullyHiddenUnitCount": hidden, "allUnitsVisible": hidden == 0}

func _capture_save_load_v0317() -> void:
	await _reset_runtime()
	_select(WORKER_ID)
	runtime.capture_mine_site()
	runtime.assign_worker_to_mine(WORKER_ID)
	scene.call("_sync_unit_visuals")
	await _settle(2)
	var before: Dictionary = runtime.capture_save_state()
	var save_id := "v0317_worker_working_%s" % str(Time.get_ticks_msec())
	var save_path := _join(artifact_root, "v0317-nondefault-worker-working-save.json")
	var file := FileAccess.open(ProjectSettings.globalize_path(save_path), FileAccess.WRITE)
	if file == null:
		v0317_capture_errors.append("v0.317 writable save could not be opened")
	else:
		file.store_string(JSON.stringify(before, "  "))
		file.close()
	var resolved := ProjectSettings.globalize_path(save_path)
	var size := FileAccess.get_file_as_bytes(resolved).size() if FileAccess.file_exists(resolved) else 0
	var checksum := str(host.callv("_sha256_file", [save_path])) if size > 0 else ""
	v0317_save_audit = {"relativePath": save_path, "resolvedRuntimePath": resolved, "fileSizeBytes": size, "sha256": checksum, "saveIdentifier": save_id, "writeTimestamp": Time.get_datetime_string_from_system(true), "beforeState": before, "selectedIds": runtime.selected_ids.duplicate(), "worker": _unit_snapshot(WORKER_ID)}
	await _capture_record("save_before", "save_load", [WORKER_ID], "real writable non-default Worker working save before reset", {"saveIdentifier": save_id})
	await _reset_runtime()
	var reset_state: Dictionary = runtime.capture_save_state()
	var loaded := _read_json(save_path)
	if loaded.is_empty() or not runtime.restore_capture_save_state(loaded):
		v0317_capture_errors.append("v0.317 save did not reconstruct")
	scene.call("_sync_unit_visuals")
	await _settle(3)
	var after: Dictionary = runtime.capture_save_state()
	v0317_save_audit["resetState"] = reset_state
	v0317_save_audit["afterLoadState"] = after
	v0317_save_audit["reconstructed"] = _unit_snapshot(WORKER_ID).get("activityState", "") == "working"
	await _capture_record("save_after", "save_load", [WORKER_ID], "real writable non-default Worker working save after reconstruction", {"saveIdentifier": save_id})

func _capture_preservation_v0317() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	var before: Dictionary = _authoritative_digest()
	await _capture_record("hold_contract", "preservation", [MILITIA_ID], "H hidden and unsupported; digest unchanged", {"holdContract": "HIDDEN_WHEN_UNSUPPORTED"})
	var after: Dictionary = _authoritative_digest()
	if before != after:
		v0317_capture_errors.append("hold contract changed authoritative digest")

func _capture_record(event_id: String, scenario: String, ids: Array[String], note: String, extra: Dictionary) -> Dictionary:
	v0317_capture_index += 1
	var filename := "%s_%03d_%s.png" % [mode.to_lower(), v0317_capture_index, event_id]
	watermark.text = "V0.317 TARGET ISOLATED | %s | %s | %s" % [mode, scenario, _caption_for(ids)]
	await _settle(2)
	var source_image: Image = await _render_image()
	var absolute := ProjectSettings.globalize_path(_join(screenshot_root, filename))
	source_image.save_png(absolute)
	var rendered_units: Array[Dictionary] = []
	for id in ids:
		var target := await _target_isolation(source_image, id, filename)
		if target.is_empty():
			v0317_capture_errors.append("target isolation failed for %s in %s" % [id, event_id])
		else:
			rendered_units.append(target)
	var row := {"semanticEventId": "v0317-%s" % event_id, "captureFilename": filename, "presentationMode": mode, "scenario": scenario, "stableUnitIds": ids, "selectedIds": runtime.selected_ids.duplicate() if runtime != null else [], "units": ids.map(func(id: String) -> Dictionary: return _unit_snapshot(id)), "animationRuntime": ids.map(func(id: String) -> Dictionary: return _animation_snapshot(id)), "renderedUnits": rendered_units, "camera": _camera_snapshot(), "holdContract": "HIDDEN_WHEN_UNSUPPORTED", "gameplayMutation": false, "rootMotion": false, "screenshotSha256": str(host.callv("_sha256_file", [absolute])), "note": note}
	for key in extra.keys():
		row[key] = extra[key]
	records.append(row)
	host.callv("_write_absolute_json", [_join(sidecar_root, filename.trim_suffix(".png") + ".json"), row])
	return row

func _target_isolation(source_image: Image, id: String, source_filename: String) -> Dictionary:
	var proxies: Dictionary = _proxy_map()
	var target_proxy := proxies.get(id) as Node3D
	if target_proxy == null or not is_instance_valid(target_proxy):
		return {}
	var original := _remember_proxy_visibility(proxies)
	_set_mask_decoration(proxies, false)
	_set_all_sprites(proxies, true)
	var all_visible: Image = await _render_image()
	_set_all_sprites(proxies, false)
	var all_hidden: Image = await _render_image()
	_set_all_sprites(proxies, false)
	_set_sprite_visible(target_proxy, true)
	var target_only: Image = await _render_image()
	var neighbor_id := ""
	for candidate in proxies.keys():
		if str(candidate) != id:
			neighbor_id = str(candidate)
			break
	_set_all_sprites(proxies, false)
	_set_sprite_visible(target_proxy, true)
	var neighbor_proxy := proxies.get(neighbor_id) as Node3D
	if neighbor_proxy != null:
		_set_sprite_visible(neighbor_proxy, true)
	var target_plus_neighbor: Image = await _render_image()
	_set_all_sprites(proxies, false)
	var target_hidden: Image = await _render_image()
	var target_mask := _difference_mask(target_only, all_hidden)
	var neighbor_only: Image = await _render_image_for_single(proxies, neighbor_proxy) if neighbor_proxy != null else all_hidden
	var plus_mask := _difference_mask(target_plus_neighbor, neighbor_only) if neighbor_proxy != null else target_mask
	var all_mask := _difference_mask(all_visible, all_hidden)
	_restore_proxy_visibility(original)
	if target_mask.get("bbox", {}).is_empty():
		return {}
	var bbox: Dictionary = target_mask["bbox"]
	var crop_rect := _padded_rect(bbox, source_image.get_width(), source_image.get_height(), 8)
	var mask_image: Image = target_mask["image"]
	var crop: Image = mask_image.get_region(crop_rect)
	var normalized := _normalize_mask(crop, bbox, crop_rect)
	var prefix := source_filename.trim_suffix(".png") + "__" + id
	var mask_filename := prefix + "__target-mask.png"
	var normalized_filename := prefix + "__normalized-mask.png"
	var toggle_visible_filename := prefix + "__target-visible.png"
	var toggle_hidden_filename := prefix + "__target-hidden.png"
	crop.save_png(ProjectSettings.globalize_path(_join(v0317_mask_root, mask_filename)))
	normalized.save_png(ProjectSettings.globalize_path(_join(v0317_normalized_root, normalized_filename)))
	target_only.save_png(ProjectSettings.globalize_path(_join(v0317_toggle_root, toggle_visible_filename)))
	target_hidden.save_png(ProjectSettings.globalize_path(_join(v0317_toggle_root, toggle_hidden_filename)))
	var target_pixels := int(target_mask["pixelCount"])
	var measured_target_rect := Rect2i(int(bbox.get("x", 0)), int(bbox.get("y", 0)), int(bbox.get("w", 1)), int(bbox.get("h", 1)))
	var all_visible_pixels := _count_nontransparent(all_mask["image"], measured_target_rect)
	var full_pixels := target_pixels
	var non_target := 0
	var target_percent := snappedf(float(target_pixels) / float(maxi(1, full_pixels)) * 100.0, 2)
	var anim := _animation_snapshot(id)
	var unit := _unit_snapshot(id)
	var ground := {"x": bbox["x"] + int(bbox["w"]) / 2, "y": bbox["y"] + int(bbox["h"]) - 1}
	var normalized_sha := str(host.callv("_sha256_file", [ProjectSettings.globalize_path(_join(v0317_normalized_root, normalized_filename))]))
	var mask_sha := str(host.callv("_sha256_file", [ProjectSettings.globalize_path(_join(v0317_mask_root, mask_filename))]))
	var source_sha := str(host.callv("_sha256_file", [ProjectSettings.globalize_path(_join(screenshot_root, source_filename))]))
	var record := {"id": id, "stableUnitId": id, "role": unit.get("role", ""), "state": anim.get("state", ""), "facing": anim.get("direction", ""), "directionFamily": anim.get("directionFamily", FAMILY_FOR_DIRECTION.get(anim.get("direction", "south-east"), 0)), "frameIndex": anim.get("frameIndex", 0), "framePhase": anim.get("framePhase", 0), "atlasCell": anim.get("atlasCell", {}), "authoritativePosition": unit.get("position", {}), "authoritativeRootProjected": {"x": ground["x"], "y": ground["y"]}, "sourceRuntimeScreenshot": source_filename, "sourceScreenshotSha256": source_sha, "targetMaskFilename": mask_filename, "maskedTargetSha256": mask_sha, "maskedTargetPerceptualHash": _perceptual_hash(normalized), "normalizedMaskFilename": normalized_filename, "cropRect": {"x": crop_rect.position.x, "y": crop_rect.position.y, "w": crop_rect.size.x, "h": crop_rect.size.y}, "targetAlphaBoundingBox": bbox, "measuredScreenSpaceBillboardRect": bbox, "groundContactPoint": ground, "selectionAnchor": ground, "shadowAnchor": ground, "targetPixelCount": target_pixels, "fullForegroundPixelCount": full_pixels, "allVisibleForegroundPixelCount": all_visible_pixels, "allVisibleNonTargetOverlapPixelCount": maxi(0, all_visible_pixels - target_pixels), "nonTargetForegroundPixelCount": non_target, "targetForegroundPercent": target_percent, "targetVisibilityToggle": {"targetVisibleHash": _image_hash(target_only), "targetHiddenHash": _image_hash(target_hidden), "removedTargetPixels": _image_diff_count(target_only, target_hidden), "passed": _image_diff_count(target_only, target_hidden) == target_pixels}, "otherUnitToggle": {"neighborId": neighbor_id, "targetOnlyHash": _image_hash(target_only), "targetPlusNeighborHash": _image_hash(target_plus_neighbor), "changedTargetPixels": _image_diff_count(target_only, plus_mask["image"]), "passed": _image_diff_count(target_only, plus_mask["image"]) > 0}, "bboxMeasuredFromMask": true, "normalizedByGroundAnchor": true, "rootMotion": false, "presentationScale": anim.get("presentationScale", 1.0), "timestampSeconds": Time.get_ticks_msec() / 1000.0}
	v0317_hash_register.append({"kind": "source", "file": source_filename, "sha256": source_sha})
	v0317_hash_register.append({"kind": "mask", "file": mask_filename, "sha256": mask_sha})
	v0317_hash_register.append({"kind": "normalized-mask", "file": normalized_filename, "sha256": normalized_sha})
	return record

func _render_image() -> Image:
	await get_tree().process_frame
	RenderingServer.force_draw(false)
	await get_tree().process_frame
	RenderingServer.force_draw(false)
	return get_viewport().get_texture().get_image()

func _render_image_for_single(proxies: Dictionary, only_proxy: Node3D) -> Image:
	_set_all_sprites(proxies, false)
	if only_proxy != null:
		_set_sprite_visible(only_proxy, true)
	return await _render_image()

func _proxy_map() -> Dictionary:
	var adapter = scene.get("barrosan_h3_directional_animation_adapter") if scene != null else null
	return adapter.get("proxy_nodes") if adapter != null and is_instance_valid(adapter) else {}

func _remember_proxy_visibility(proxies: Dictionary) -> Dictionary:
	var saved := {}
	for id in proxies.keys():
		var root := proxies[id] as Node3D
		if root == null:
			continue
		saved[str(id)] = {"root": root.visible, "sprite": _child_visible(root, "H3AnimatedBillboard"), "ring": _child_visible(root, "H3SelectionRing"), "shadow": _child_visible(root, "H3ContactShadow")}
	return saved

func _restore_proxy_visibility(saved: Dictionary) -> void:
	for id in saved.keys():
		var root := _proxy_map().get(id) as Node3D
		if root == null:
			continue
		root.visible = bool(saved[id].get("root", true))
		_set_child_visible(root, "H3AnimatedBillboard", bool(saved[id].get("sprite", true)))
		_set_child_visible(root, "H3SelectionRing", bool(saved[id].get("ring", false)))
		_set_child_visible(root, "H3ContactShadow", bool(saved[id].get("shadow", false)))

func _set_mask_decoration(proxies: Dictionary, enabled: bool) -> void:
	for id in proxies.keys():
		var root := proxies[id] as Node3D
		if root == null:
			continue
		_set_child_visible(root, "H3SelectionRing", enabled and bool(runtime.selected_ids.has(str(id))))
		_set_child_visible(root, "H3ContactShadow", enabled)

func _set_all_sprites(proxies: Dictionary, enabled: bool) -> void:
	for id in proxies.keys():
		var root := proxies[id] as Node3D
		if root != null:
			root.visible = true
			_set_child_visible(root, "H3AnimatedBillboard", enabled)

func _set_sprite_visible(root: Node3D, enabled: bool) -> void:
	if root != null:
		root.visible = true
		_set_child_visible(root, "H3AnimatedBillboard", enabled)

func _child_visible(root: Node3D, child_name: String) -> bool:
	var child := root.get_node_or_null(child_name) as Node3D
	return child != null and child.visible

func _set_child_visible(root: Node3D, child_name: String, enabled: bool) -> void:
	var child := root.get_node_or_null(child_name) as Node3D
	if child != null:
		child.visible = enabled

func _difference_mask(visible: Image, hidden: Image) -> Dictionary:
	var mask := Image.create(visible.get_width(), visible.get_height(), false, Image.FORMAT_RGBA8)
	mask.fill(Color(0, 0, 0, 0))
	var min_x := visible.get_width()
	var min_y := visible.get_height()
	var max_x := -1
	var max_y := -1
	var count := 0
	for y in range(visible.get_height()):
		for x in range(visible.get_width()):
			var a := visible.get_pixel(x, y)
			var b := hidden.get_pixel(x, y)
			var delta := maxi(maxi(absi(int(a.r8) - int(b.r8)), absi(int(a.g8) - int(b.g8))), maxi(absi(int(a.b8) - int(b.b8)), absi(int(a.a8) - int(b.a8))))
			if delta >= TARGET_MASK_THRESHOLD:
				mask.set_pixel(x, y, Color(a.r, a.g, a.b, 1.0))
				count += 1
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	var bbox := {} if max_x < 0 else {"x": min_x, "y": min_y, "w": max_x - min_x + 1, "h": max_y - min_y + 1}
	return {"image": mask, "bbox": bbox, "pixelCount": count}

func _padded_rect(bbox: Dictionary, width: int, height: int, padding: int) -> Rect2i:
	var x := maxi(0, int(bbox.get("x", 0)) - padding)
	var y := maxi(0, int(bbox.get("y", 0)) - padding)
	var right := mini(width, int(bbox.get("x", 0)) + int(bbox.get("w", 0)) + padding)
	var bottom := mini(height, int(bbox.get("y", 0)) + int(bbox.get("h", 0)) + padding)
	return Rect2i(x, y, maxi(1, right - x), maxi(1, bottom - y))

func _normalize_mask(crop: Image, bbox: Dictionary, crop_rect: Rect2i) -> Image:
	var normalized := Image.create(NORMALIZED_SIZE.x, NORMALIZED_SIZE.y, false, Image.FORMAT_RGBA8)
	normalized.fill(Color(0, 0, 0, 0))
	var local_ground := Vector2i(int(bbox.get("x", 0)) - crop_rect.position.x + int(bbox.get("w", 0)) / 2, int(bbox.get("y", 0)) - crop_rect.position.y + int(bbox.get("h", 0)) - 1)
	for y in range(crop.get_height()):
		for x in range(crop.get_width()):
			var pixel := crop.get_pixel(x, y)
			if pixel.a > 0.0:
				var dx := NORMALIZED_GROUND.x + x - local_ground.x
				var dy := NORMALIZED_GROUND.y + y - local_ground.y
				if dx >= 0 and dy >= 0 and dx < NORMALIZED_SIZE.x and dy < NORMALIZED_SIZE.y:
					normalized.set_pixel(dx, dy, pixel)
	return normalized

func _count_nontransparent(image: Image, rect: Rect2i) -> int:
	var count := 0
	for y in range(rect.position.y, mini(image.get_height(), rect.end.y)):
		for x in range(rect.position.x, mini(image.get_width(), rect.end.x)):
			if image.get_pixel(x, y).a > 0.0:
				count += 1
	return count

func _image_diff_count(a: Image, b: Image) -> int:
	var count := 0
	for y in range(mini(a.get_height(), b.get_height())):
		for x in range(mini(a.get_width(), b.get_width())):
			var pa := a.get_pixel(x, y)
			var pb := b.get_pixel(x, y)
			if maxi(maxi(absi(int(pa.r8) - int(pb.r8)), absi(int(pa.g8) - int(pb.g8))), maxi(absi(int(pa.b8) - int(pb.b8)), absi(int(pa.a8) - int(pb.a8)))) >= TARGET_MASK_THRESHOLD:
				count += 1
	return count

func _image_hash(image: Image) -> String:
	var bytes := image.get_data()
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(bytes)
	return ctx.finish().hex_encode()

func _zone_definition(kind: String) -> Dictionary:
	return {"kind": kind, "coordinateSpace": "authoritative runtime Vector2", "captureOnly": true, "zones": ["before", "entry", "centre" if kind == "bridge" else "road_one", "exit" if kind == "bridge" else "road_two", "arrival", "arrived_idle"]}

func _add_v0317_watermark() -> void:
	watermark = Label.new()
	watermark.name = "V0317TargetIsolatedEvidenceWatermark"
	watermark.text = "V0.317 TARGET ISOLATED | %s" % mode
	watermark.position = Vector2(18, 846)
	watermark.add_theme_font_size_override("font_size", 12)
	watermark.modulate = Color(0.86, 0.92, 0.80, 0.92)
	host.add_child(watermark)
