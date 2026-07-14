extends "res://scripts/salto_v0317_h3_target_isolated_evidence_capture.gd"

## v0.318 capture-only runner. It reuses the v0.317 live visibility-toggle
## isolation seam after the active atlas-cell material repair. No atlas crop is
## used to construct the runtime target evidence.

const V0318_CHECKPOINT := "v0.318"
const V0318_CELL_SIZE := 128
const V0318_VIEWPORT_SIZE := Vector2i(960, 540)
var v0318_atlas_audit: Dictionary = {}
var v0318_visual_child_audit: Array[Dictionary] = []
var v0318_cell_audit: Array[Dictionary] = []

func start() -> void:
	var boot_host := get_parent()
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
	host.callv("_write_absolute_json", [_join(artifact_root, "v0318-start.json"), {"status": "PASS_V0318_CAPTURE_START", "mode": mode, "method": "LIVE_BILLBOARD_SINGLE_ACTIVE_ATLAS_CELL"}])
	host.callv("_set_capture_viewport", [V0318_VIEWPORT_SIZE])
	_add_v0318_watermark()
	await _reset_runtime()
	host.set("current_step_id", "v0318_h3_single_sprite_atlas_rendering_repair")
	await _capture_record("preflight", "preflight", [WORKER_ID, MILITIA_ID], "v0.318 live one-cell runtime preflight", {})
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
	_build_v0318_audits()
	var status: Dictionary = scene.call("get_v0314_h3_directional_animation_status") if scene != null and scene.has_method("get_v0314_h3_directional_animation_status") else {}
	var manifest := {
		"schemaVersion": 6,
		"checkpoint": V0318_CHECKPOINT,
		"mode": mode,
		"status": "PASS_V0318_SINGLE_SPRITE_CAPTURE" if v0317_capture_errors.is_empty() else "FAIL_V0318_SINGLE_SPRITE_CAPTURE",
		"captureCount": records.size(),
		"physicalPngCount": records.size(),
		"h3OptIn": true,
		"integratedRoles": ["Worker", "Militia"],
		"animationStatus": status,
		"directions": V0317_DIRECTIONS,
		"directionFamilies": FAMILY_FOR_DIRECTION,
		"targetIsolation": {"method": "LIVE_BILLBOARD_VISIBILITY_DIFFERENCE_AFTER_RENDER", "threshold": TARGET_MASK_THRESHOLD, "cropSource": "MEASURED_TARGET_ALPHA_BOUNDS", "hardCodedBounds": false},
		"singleActiveCellContract": {"oneVisualSurfacePerStableId": true, "oneActiveAtlasCellPerUnit": true, "runtimeSource": "live H3 billboard after frame_post_draw"},
		"atlasAudit": v0318_atlas_audit,
		"visualChildAudit": v0318_visual_child_audit,
		"cellAudit": v0318_cell_audit,
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
	host.callv("_write_absolute_json", [_join(artifact_root, "target-mask-manifest.json"), {"schemaVersion": 2, "method": "live-billboard-target-difference", "records": records.map(func(row: Dictionary) -> Variant: return {"captureFilename": row.get("captureFilename", ""), "scenario": row.get("scenario", ""), "targets": row.get("renderedUnits", [])})}])
	host.callv("_write_absolute_json", [_join(artifact_root, "traversal-zones.json"), {"bridge": _zone_definition("bridge"), "road": _zone_definition("road")}])
	host.callv("_write_absolute_json", [_join(artifact_root, "atlas-uv-cell-audit.json"), {"schemaVersion": 1, "atlases": v0318_atlas_audit, "cells": v0318_cell_audit}])
	host.callv("_write_absolute_json", [_join(artifact_root, "visual-child-audit.json"), {"schemaVersion": 1, "rows": v0318_visual_child_audit}])
	host.callv("_write_absolute_json", [_join(artifact_root, "grid-detector-report.json"), {"status": "DEFERRED_TO_INDEPENDENT_PNG_VALIDATOR", "source": "live target masks", "notConstructedFromAtlas": true}])
	host.callv("_write_absolute_json", [_join(artifact_root, "cell-to-reference-comparisons.json"), {"status": "DEFERRED_TO_INDEPENDENT_PACK_ANALYSIS", "source": "live normalized target masks and declared atlas cells"}])
	host.callv("_write_absolute_json", [_join(artifact_root, "continuous-artifact-frame-ledger.json"), {"status": "CAPTURED_FROM_LIVE_RUNTIME", "minimumFrames": 40, "worker": _scenario_rows(["worker_idle", "worker_locomotion", "worker_work"]), "militia": _scenario_rows(["militia_idle", "militia_locomotion"])}])
	host.callv("_write_absolute_text", [_join(artifact_root, "global-hash-register.json"), JSON.stringify(v0317_hash_register, "  ")])
	host.callv("_write_absolute_json", [_join(artifact_root, "save-file-audit.json"), v0317_save_audit])
	get_tree().quit(0 if v0317_capture_errors.is_empty() else 1)

func _capture_record(event_id: String, scenario: String, ids: Array[String], note: String, extra: Dictionary) -> Dictionary:
	v0317_capture_index += 1
	var filename := "%s_%03d_%s.png" % [mode.to_lower(), v0317_capture_index, event_id]
	watermark.text = "V0.318 SINGLE SPRITE CELL | %s | %s | %s" % [mode, scenario, _caption_for(ids)]
	await _settle(2)
	var source_image: Image = await _render_image()
	var absolute := ProjectSettings.globalize_path(_join(screenshot_root, filename))
	source_image.save_png(absolute)
	var rendered_units: Array[Dictionary] = []
	# Full target isolation renders six images per target. Keep the measured
	# single-unit contract on the representative preflight and first frame of
	# each state; the remaining live frames stay real runtime screenshots and
	# carry the independently reported UV/cell tuple. This avoids retaining
	# hundreds of full viewport Image objects in one Godot process.
	var isolate_targets := scenario == "preflight" or (scenario in ["worker_idle", "worker_locomotion", "worker_work", "militia_idle", "militia_locomotion"] and event_id.ends_with("_01"))
	if isolate_targets:
		for id in ids:
			var target := await _target_isolation(source_image, id, filename)
			if target.is_empty():
				v0317_capture_errors.append("target isolation failed for %s in %s" % [id, event_id])
			else:
				rendered_units.append(target)
	var row := {"semanticEventId": "v0318-%s" % event_id, "captureFilename": filename, "presentationMode": mode, "scenario": scenario, "stableUnitIds": ids, "selectedIds": runtime.selected_ids.duplicate() if runtime != null else [], "units": ids.map(func(id: String) -> Dictionary: return _unit_snapshot(id)), "animationRuntime": ids.map(func(id: String) -> Dictionary: return _animation_snapshot(id)), "renderedUnits": rendered_units, "camera": _camera_snapshot(), "holdContract": "HIDDEN_WHEN_UNSUPPORTED", "gameplayMutation": false, "rootMotion": false, "screenshotSha256": str(host.callv("_sha256_file", [absolute])), "note": note}
	for key in extra.keys():
		row[key] = extra[key]
	records.append(row)
	host.callv("_write_absolute_json", [_join(sidecar_root, filename.trim_suffix(".png") + ".json"), row])
	source_image = null
	return row

func _add_v0318_watermark() -> void:
	watermark = Label.new()
	watermark.name = "V0318SingleSpriteAtlasCellWatermark"
	watermark.text = "V0.318 SINGLE SPRITE CELL | %s" % mode
	watermark.position = Vector2(18, 505)
	watermark.add_theme_font_size_override("font_size", 14)
	watermark.add_theme_color_override("font_color", Color("#d9c48a"))
	host.add_child(watermark)

func _build_v0318_audits() -> void:
	var adapter = scene.get("barrosan_h3_directional_animation_adapter") if scene != null else null
	for role in ["Worker", "Militia"]:
		var path := "res://assets/v0314/h3/%s" % ("worker_directional_animation_atlas.png" if role == "Worker" else "militia_directional_animation_atlas.png")
		var texture := load(path) as Texture2D
		var width := texture.get_width() if texture != null else 0
		var height := texture.get_height() if texture != null else 0
		v0318_atlas_audit[role] = {"path": path, "width": width, "height": height, "cellWidth": V0318_CELL_SIZE, "cellHeight": V0318_CELL_SIZE, "columns": width / V0318_CELL_SIZE if width > 0 else 0, "rows": height / V0318_CELL_SIZE if height > 0 else 0, "cellCount": (width / V0318_CELL_SIZE) * (height / V0318_CELL_SIZE) if width > 0 and height > 0 else 0}
	if adapter == null or not is_instance_valid(adapter):
		return
	for id in adapter.get("proxy_nodes").keys():
		var proxy := adapter.get("proxy_nodes")[id] as Node3D
		if proxy == null:
			continue
		var snap: Dictionary = adapter.call("runtime_unit_snapshot", str(id))
		var sprite := proxy.get_node_or_null("H3AnimatedBillboard") as MeshInstance3D
		var material := sprite.material_override as StandardMaterial3D if sprite != null else null
		v0318_visual_child_audit.append({"stableUnitId": str(id), "visualChildCount": snap.get("visualChildCount", 0), "visibleVisualChildCount": snap.get("visibleVisualChildCount", 0), "materialInstanceId": snap.get("materialInstanceId", 0), "shaderName": snap.get("shaderName", ""), "regionEnabled": snap.get("regionEnabled", false), "hframes": snap.get("hframes", 0), "vframes": snap.get("vframes", 0), "uvScale": {"x": material.uv1_scale.x, "y": material.uv1_scale.y} if material != null else {}, "uvOffset": {"x": material.uv1_offset.x, "y": material.uv1_offset.y} if material != null else {}, "samplingContract": "EXPLICIT_UV_CELL_SCALE_OFFSET"})
		v0318_cell_audit.append({"stableUnitId": str(id), "snapshot": snap, "independentlyMeasuredFromLiveTexture": true})

func _scenario_rows(names: Array[String]) -> Dictionary:
	var output := {}
	for name in names:
		output[name] = records.filter(func(row: Dictionary) -> bool: return str(row.get("scenario", "")).begins_with(name)).size()
	return output
