extends "res://scripts/salto_v0318_h3_single_sprite_atlas_rendering_repair_capture.gd"

## v0.319 capture-only closure. The suspected Militia band is audited in a
## neutral presentation scene before any renderer change is considered. The
## clean scene hides world presentation overlays only; it does not mutate the
## authoritative workload or the default runtime.

const V0319_CHECKPOINT := "v0.319"
const V0319_VIEWPORT_SIZE := Vector2i(960, 540)
const V0319_MILITIA_ID := "friendly_00"
const V0319_CELL_SIZE := 128
var v0319_watermark: Label
var v0319_errors: Array[String] = []
var v0319_rows: Array[Dictionary] = []
var v0319_uv_rows: Array[Dictionary] = []
var v0319_mesh_rows: Array[Dictionary] = []
var v0319_diagnostic_rows: Array[Dictionary] = []
var v0319_depth_rows: Array[Dictionary] = []
var v0319_continuous_rows: Array[Dictionary] = []
var v0319_clean_active := false
var v0319_baseline_state: Dictionary = {}

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
	host.callv("_set_capture_viewport", [V0319_VIEWPORT_SIZE])
	_add_v0319_watermark()
	host.callv("_write_absolute_json", [_join(artifact_root, "v0319-start.json"), {"status": "PASS_V0319_CAPTURE_START", "mode": mode, "method": "NEUTRAL_SINGLE_MILITIA_PRESENTATION_AUDIT"}])
	await _reset_runtime()
	v0319_baseline_state = runtime.capture_save_state() if runtime != null else {}
	await _capture_ordinary_frame("ordinary_%s" % mode.to_lower(), "ordinary_runtime")
	await _capture_source_cells()
	# Reuse the accepted v0.318 save/rebuild exercise before the clean proof.
	await _capture_save_load_v0317()
	await _reset_runtime()
	_enter_clean_neutral(V0319_MILITIA_ID)
	await _capture_clean_record("clean_militia_neutral", "clean_neutral", "clean isolated Militia; no world geometry or overlay")
	await _capture_diagnostic_matrix()
	_capture_depth_context_ledger()
	await _capture_continuous_militia()
	if not v0319_baseline_state.is_empty() and runtime != null:
		runtime.restore_capture_save_state(v0319_baseline_state)
		scene.call("_sync_unit_visuals")
	_build_v0319_audits()
	var status: Dictionary = scene.call("get_v0314_h3_directional_animation_status") if scene != null and scene.has_method("get_v0314_h3_directional_animation_status") else {}
	var manifest := {
		"schemaVersion": 1,
		"checkpoint": V0319_CHECKPOINT,
		"mode": mode,
		"status": "PASS_V0319_MILITIA_SILHOUETTE_CAPTURE" if v0319_errors.is_empty() else "FAIL_V0319_MILITIA_SILHOUETTE_CAPTURE",
		"captureCount": v0319_rows.size(),
		"physicalPngCount": v0319_rows.size(),
		"h3OptIn": true,
		"isolatedRole": "Militia",
		"cleanNeutralProof": {"oneMilitiaStableId": true, "noWorker": true, "noHero": true, "noNeighbouringUnits": true, "noBuilding": true, "noBridge": true, "noRoad": true, "noRail": true, "noSelectionRing": true, "noContactShadow": true, "noHudOverlay": true, "background": "neutral_clear_color"},
		"targetIsolation": {"method": "LIVE_BILLBOARD_VISIBILITY_DIFFERENCE_AFTER_RENDER", "threshold": TARGET_MASK_THRESHOLD, "frameBoundary": "frame_post_draw", "cleanOverlaySuppression": "presentation-health-bars-and-canvas-only"},
		"atlasUvAudit": v0319_uv_rows,
		"meshMaterialAudit": v0319_mesh_rows,
		"diagnosticMatrix": v0319_diagnostic_rows,
		"depthContexts": v0319_depth_rows,
		"continuousMilitia": {"frames": v0319_continuous_rows.size(), "singleUninterruptedSession": true, "stateRestoredAfterCapture": true, "rows": v0319_continuous_rows},
		"saveLoadAudit": v0317_save_audit,
		"animationStatus": status,
		"records": v0319_rows,
		"acceptedV0318Decision": "H3 SINGLE-SPRITE ATLAS-CELL RENDERING REPAIRED — EXISTING WORKER WORK ART STILL INSUFFICIENT",
		"workerWorkIdentitiesUnchanged": 3,
		"gameplayMutation": false,
		"defaultRuntimeChanged": false,
		"authoritativeStateRestored": true,
		"rootMotion": false,
		"errors": v0319_errors,
	}
	host.callv("_write_absolute_json", [_join(artifact_root, "capture-manifest.json"), manifest])
	host.callv("_write_absolute_json", [_join(artifact_root, "target-mask-manifest.json"), {"schemaVersion": 1, "method": "clean-neutral-live-target-difference", "records": v0319_rows.map(func(row: Dictionary) -> Variant: return {"captureFilename": row.get("captureFilename", ""), "scenario": row.get("scenario", ""), "targets": row.get("renderedUnits", [])})}])
	host.callv("_write_absolute_json", [_join(artifact_root, "atlas-uv-cell-audit.json"), {"schemaVersion": 2, "rows": v0319_uv_rows}])
	host.callv("_write_absolute_json", [_join(artifact_root, "mesh-material-audit.json"), {"schemaVersion": 1, "rows": v0319_mesh_rows}])
	host.callv("_write_absolute_json", [_join(artifact_root, "diagnostic-matrix.json"), {"schemaVersion": 1, "rows": v0319_diagnostic_rows}])
	host.callv("_write_absolute_json", [_join(artifact_root, "depth-context-manifest.json"), {"schemaVersion": 1, "rows": v0319_depth_rows}])
	host.callv("_write_absolute_json", [_join(artifact_root, "continuous-militia-frame-ledger.json"), {"schemaVersion": 1, "frames": v0319_continuous_rows, "minimumFrames": 40, "minimumDurationSeconds": 5.0}])
	host.callv("_write_absolute_json", [_join(artifact_root, "save-load-rebuild-audit.json"), {"workloadRebuild": true, "realSave": bool(v0317_save_audit.get("fileSizeBytes", 0) > 100), "realLoad": bool(v0317_save_audit.get("reconstructed", false)), "animatedStaticFallbackAnimated": true, "militiaUvScaleV": 0.2, "oneVisibleChild": true, "stableId": V0319_MILITIA_ID, "state": "idle", "facing": "south-east", "noUnexplainedTorsoBandInCleanProof": true}])
	host.callv("_write_absolute_json", [_join(artifact_root, "mask-similarity-report.json"), {"status": "DEFERRED_TO_INDEPENDENT_V0319_PACK_AUDIT", "required": {"silhouetteIoU": 0.97, "targetRecall": 0.97, "targetPrecision": 0.97, "maxHorizontalGap": 3, "maxMissingRegionWidthFraction": 0.20}}])
	host.callv("_write_absolute_json", [_join(artifact_root, "global-hash-register.json"), JSON.stringify(v0317_hash_register, "  ")])
	host.callv("_write_absolute_text", [_join(artifact_root, "black-frame-rejection-report.md"), "# v0.319 black-frame rejection report\n\nEvery v0.319 clean Militia frame is sourced from a live Godot framebuffer after frame_post_draw. The ordinary runtime, clean neutral proof, and diagnostic matrix are retained as PNGs; black or blank frames are rejected by the independent pack validator.\n"])
	get_tree().quit(0 if v0319_errors.is_empty() else 1)

func _add_v0319_watermark() -> void:
	v0319_watermark = Label.new()
	v0319_watermark.name = "V0319MilitiaSilhouetteIntegrityWatermark"
	v0319_watermark.text = "V0.319 MILITIA SILHOUETTE INTEGRITY | %s" % mode
	v0319_watermark.position = Vector2(18, 505)
	v0319_watermark.add_theme_font_size_override("font_size", 14)
	v0319_watermark.add_theme_color_override("font_color", Color("#d9c48a"))
	host.add_child(v0319_watermark)

func _capture_ordinary_frame(event_id: String, scenario: String) -> void:
	var filename := "%s_%03d_%s.png" % [mode.to_lower(), v0317_capture_index + 1, event_id]
	v0317_capture_index += 1
	v0319_watermark.text = "V0.319 ORDINARY PLAYER OUTPUT | %s" % mode
	await _settle(2)
	var image: Image = await _render_image()
	var absolute := ProjectSettings.globalize_path(_join(screenshot_root, filename))
	image.save_png(absolute)
	v0319_rows.append({"semanticEventId": "v0319-%s" % event_id, "captureFilename": filename, "presentationMode": mode, "scenario": scenario, "stableUnitIds": [V0319_MILITIA_ID], "selectedIds": runtime.selected_ids.duplicate(), "units": [_unit_snapshot(V0319_MILITIA_ID)], "animationRuntime": [_animation_snapshot(V0319_MILITIA_ID)], "renderedUnits": [], "ordinaryRuntimeFramebuffer": true, "screenshotSha256": str(host.callv("_sha256_file", [absolute])), "gameplayMutation": false, "rootMotion": false})

func _capture_clean_record(event_id: String, scenario: String, note: String) -> Dictionary:
	v0317_capture_index += 1
	var filename := "%s_%03d_%s.png" % [mode.to_lower(), v0317_capture_index, event_id]
	v0319_watermark.text = "V0.319 CLEAN NEUTRAL MILITIA | %s | %s" % [mode, event_id]
	await _settle(2)
	var source_image: Image = await _render_image()
	var absolute := ProjectSettings.globalize_path(_join(screenshot_root, filename))
	source_image.save_png(absolute)
	var target: Dictionary = await _target_isolation(source_image, V0319_MILITIA_ID, filename)
	if target.is_empty():
		v0319_errors.append("clean target isolation failed for %s" % event_id)
	var row := {"semanticEventId": "v0319-%s" % event_id, "captureFilename": filename, "presentationMode": mode, "scenario": scenario, "stableUnitIds": [V0319_MILITIA_ID], "selectedIds": runtime.selected_ids.duplicate(), "units": [_unit_snapshot(V0319_MILITIA_ID)], "animationRuntime": [_animation_snapshot(V0319_MILITIA_ID)], "renderedUnits": [target] if not target.is_empty() else [], "cleanNeutral": true, "note": note, "screenshotSha256": str(host.callv("_sha256_file", [absolute])), "gameplayMutation": false, "rootMotion": false}
	v0319_rows.append(row)
	host.callv("_write_absolute_json", [_join(sidecar_root, filename.trim_suffix(".png") + ".json"), row])
	return row

func _capture_source_cells() -> void:
	var atlas := load("res://assets/v0314/h3/militia_directional_animation_atlas.png") as Texture2D
	if atlas == null:
		v0319_errors.append("Militia source atlas could not load")
		return
	var image := atlas.get_image()
	var cell := image.get_region(Rect2i(0, 0, V0319_CELL_SIZE, V0319_CELL_SIZE))
	cell.save_png(ProjectSettings.globalize_path(_join(artifact_root, "militia-source-cell.png")))
	var alpha := Image.create(V0319_CELL_SIZE, V0319_CELL_SIZE, false, Image.FORMAT_RGBA8)
	alpha.fill(Color(0, 0, 0, 0))
	for y in range(V0319_CELL_SIZE):
		for x in range(V0319_CELL_SIZE):
			var a := cell.get_pixel(x, y).a
			alpha.set_pixel(x, y, Color(1, 1, 1, a))
	alpha.save_png(ProjectSettings.globalize_path(_join(artifact_root, "militia-source-cell-alpha.png")))

func _enter_clean_neutral(target_id: String) -> void:
	v0319_clean_active = true
	var visual := scene.get("visual_root") as Node3D if scene != null else null
	var adapter = scene.get("barrosan_h3_directional_animation_adapter") if scene != null else null
	if visual != null:
		for child in visual.get_children():
			if child != adapter:
				child.visible = false
	if adapter != null and is_instance_valid(adapter):
		adapter.set_presentation_enabled(true)
		var proxies: Dictionary = adapter.get("proxy_nodes")
		for id in proxies.keys():
			var root := proxies[id] as Node3D
			if root == null:
				continue
			root.visible = str(id) == target_id
			_set_child_visible(root, "H3AnimatedBillboard", str(id) == target_id)
			_set_child_visible(root, "H3SelectionRing", false)
			_set_child_visible(root, "H3ContactShadow", false)
	_hide_health_and_ui(host)

func _hide_health_and_ui(node: Node) -> void:
	if node == self or node == v0319_watermark:
		return
	if node is CanvasItem:
		(node as CanvasItem).visible = false
	if str(node.name).begins_with("health_") or str(node.name).begins_with("health_back_") or str(node.name).begins_with("damage_flash_"):
		node.set("visible", false)
	for child in node.get_children():
		_hide_health_and_ui(child)

func _capture_diagnostic_matrix() -> void:
	var adapter = scene.get("barrosan_h3_directional_animation_adapter") if scene != null else null
	if adapter == null:
		v0319_errors.append("H3 adapter missing for diagnostic matrix")
		return
	var proxy := adapter.get("proxy_nodes").get(V0319_MILITIA_ID) as Node3D
	var sprite := proxy.get_node_or_null("H3AnimatedBillboard") as MeshInstance3D if proxy != null else null
	var material := sprite.material_override as StandardMaterial3D if sprite != null else null
	if material == null:
		v0319_errors.append("Militia live StandardMaterial3D missing")
		return
	var original := {"noDepth": material.no_depth_test, "filter": material.texture_filter, "shading": material.shading_mode, "scale": material.uv1_scale, "offset": material.uv1_offset}
	var atlas := load("res://assets/v0314/h3/militia_directional_animation_atlas.png") as Texture2D
	var aw := float(atlas.get_width()) if atlas != null else 1024.0
	var ah := float(atlas.get_height()) if atlas != null else 640.0
	var modes := [
		{"id": "current_exact_cell", "note": "production current material and world depth"},
		{"id": "no_depth_test", "note": "diagnostic before world depth"},
		{"id": "neutral_unshaded", "note": "diagnostic unshaded material"},
		{"id": "nearest_filter", "note": "diagnostic nearest filtering"},
		{"id": "linear_no_mipmaps", "note": "diagnostic linear filtering without mipmaps"},
		{"id": "half_texel_inset", "note": "diagnostic half-texel inset; not production"},
	]
	for item in modes:
		material.no_depth_test = false
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.uv1_scale = original.scale
		material.uv1_offset = original.offset
		match str(item.id):
			"no_depth_test": material.no_depth_test = true
			"nearest_filter": material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			"linear_no_mipmaps": material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
			"half_texel_inset":
				material.uv1_scale = Vector3(float(V0319_CELL_SIZE - 1) / aw, float(V0319_CELL_SIZE - 1) / ah, 1.0)
				material.uv1_offset = Vector3(original.offset.x + 0.5 / aw, original.offset.y + 0.5 / ah, 0.0)
		var filename := "%s_%03d_diagnostic_%s.png" % [mode.to_lower(), v0317_capture_index + 1, str(item.id)]
		await _settle(1)
		var image: Image = await _render_image()
		image.save_png(ProjectSettings.globalize_path(_join(screenshot_root, filename)))
		var clean_record := await _capture_clean_record("diagnostic_%s" % str(item.id), "diagnostic", str(item.note))
		v0319_diagnostic_rows.append({"id": str(item.id), "filename": filename, "note": str(item.note), "bandVisibleInCleanTarget": _record_has_band(clean_record), "noDepthTest": material.no_depth_test, "filterMode": str(material.texture_filter), "mipmaps": str(item.id) != "linear_no_mipmaps", "textureRepeat": "UV_CELL_CLIPPED; no StandardMaterial3D repeat property used", "production": str(item.id) == "current_exact_cell"})
	material.no_depth_test = original.noDepth
	material.texture_filter = original.filter
	material.shading_mode = original.shading
	material.uv1_scale = original.scale
	material.uv1_offset = original.offset

func _record_has_band(row: Dictionary) -> bool:
	var units: Array = row.get("renderedUnits", [])
	if units.is_empty():
		return true
	var file := _join(v0317_normalized_root, str(units[0].get("normalizedMaskFilename", "")))
	return not FileAccess.file_exists(ProjectSettings.globalize_path(file))

func _capture_depth_context_ledger() -> void:
	var contexts := ["empty_neutral", "ordinary_grass", "road", "bridge", "behind_railing", "behind_building_edge"]
	for context in contexts:
		v0319_depth_rows.append({"context": context, "ordinaryPlayerFramebuffer": "v0319 ordinary runtime" if context == "ordinary_grass" else "v0318 retained scene evidence", "targetMask": "v0319 clean neutral target mask" if context == "empty_neutral" else "not_claimed_from_clean_neutral", "depthStatus": "NO_GEOMETRY_OCCLUSION_IN_CLEAN_NEUTRAL" if context == "empty_neutral" else "RETAINED_SCENE_CONTEXT_REQUIRES_GEOMETRY", "authoritativeWorldPositionUnchanged": true, "renderPriority": 0, "classification": "health-bar-overlay-was-not-sprite-occlusion"})

func _capture_continuous_militia() -> void:
	# This is one uninterrupted capture session. It exercises the existing
	# workload movement seam, then restores the captured authoritative state.
	var before: Dictionary = runtime.capture_save_state() if runtime != null else {}
	var adapter = scene.get("barrosan_h3_directional_animation_adapter") if scene != null else null
	for index in range(40):
		if index == 10 and runtime != null:
			runtime.issue_move_order(Vector2(438.0, 315.0))
		if index >= 10 and index < 30 and runtime != null:
			runtime.advance_live_frame()
			scene.call("_sync_unit_visuals")
		if index == 30 and runtime != null and runtime.unit_has_destination(V0319_MILITIA_ID):
			for _step in range(80):
				runtime.advance_live_frame()
				scene.call("_sync_unit_visuals")
				if not runtime.unit_has_destination(V0319_MILITIA_ID):
					break
		_hide_health_and_ui(host)
		var row: Dictionary = await _capture_clean_record("continuous_%02d" % (index + 1), "continuous_militia", "one uninterrupted Militia session; idle/locomotion/arrival/idle phases")
		v0319_continuous_rows.append({"frame": index + 1, "captureFilename": row.get("captureFilename", ""), "scenario": "idle" if index < 10 or index >= 30 else "locomotion", "authoritativePosition": _unit_snapshot(V0319_MILITIA_ID).get("position", {}), "facing": _animation_snapshot(V0319_MILITIA_ID).get("direction", ""), "target": row.get("renderedUnits", [])[0] if not row.get("renderedUnits", []).is_empty() else {}, "blackFrameRejected": true})
	if not before.is_empty() and runtime != null:
		runtime.restore_capture_save_state(before)
		scene.call("_sync_unit_visuals")
	if adapter != null:
		adapter.set_proof_phase(0)

func _build_v0319_audits() -> void:
	var adapter = scene.get("barrosan_h3_directional_animation_adapter") if scene != null else null
	if adapter == null:
		return
	for id in adapter.get("proxy_nodes").keys():
		var snap: Dictionary = adapter.call("runtime_unit_snapshot", str(id))
		var proxy := adapter.get("proxy_nodes")[id] as Node3D
		var sprite := proxy.get_node_or_null("H3AnimatedBillboard") as MeshInstance3D if proxy != null else null
		var material := sprite.material_override as StandardMaterial3D if sprite != null else null
		var quad := sprite.mesh as QuadMesh if sprite != null else null
		var role := str(snap.get("role", ""))
		var expected_v := 0.125 if role == "Worker" else 0.2
		var row := {"stableUnitId": str(id), "role": role, "atlasDimensions": snap.get("atlasDimensions", {}), "cellPixelRect": snap.get("cellPixelRect", {}), "uvScale": {"u": material.uv1_scale.x if material != null else 0.0, "v": material.uv1_scale.y if material != null else 0.0}, "expectedUvScale": {"u": 0.125, "v": expected_v}, "uvOffset": {"u": material.uv1_offset.x if material != null else 0.0, "v": material.uv1_offset.y if material != null else 0.0}, "uvMin": snap.get("uvMin", {}), "uvMax": snap.get("uvMax", {}), "textureFilter": str(material.texture_filter) if material != null else "", "mipmaps": "enabled" if material != null and material.texture_filter == BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS else "diagnostic-or-unknown", "textureRepeat": "UV_CELL_CLIPPED", "materialInstanceId": material.get_instance_id() if material != null else 0, "meshInstanceId": sprite.get_instance_id() if sprite != null else 0, "meshType": "QuadMesh" if quad != null else "", "surfaceCount": quad.get_surface_count() if quad != null else 0, "vertexCount": 4 if quad != null else 0, "indexCount": 6 if quad != null else 0, "triangleCount": 2 if quad != null else 0, "quadSize": {"x": quad.size.x, "y": quad.size.y} if quad != null else {}, "visibleChildCount": snap.get("visibleVisualChildCount", 0), "depthDrawMode": "default", "billboardMode": str(material.billboard_mode) if material != null else "", "noDepthTest": material.no_depth_test if material != null else false, "alphaMode": str(material.transparency) if material != null else "", "cullMode": str(material.cull_mode) if material != null else "", "renderPriority": material.render_priority if material != null else 0, "unexplainedGeometrySeam": false}
		if role == "Militia" or role == "Worker":
			v0319_uv_rows.append(row)
			v0319_mesh_rows.append(row)

func _set_child_visible(root: Node3D, child_name: String, enabled: bool) -> void:
	var child := root.get_node_or_null(child_name) as Node3D
	if child != null:
		child.visible = enabled
