extends Node

## v0.316 capture-only evidence runner.
## This runner records rendered unit crops after RenderingServer.frame_post_draw;
## it never owns movement, root motion, gameplay state, or production input.

const VIEWPORT_SIZE := Vector2i(1600, 900)
const WORKER_ID := "worker_00"
const MILITIA_ID := "friendly_00"
const DIRECTIONS := ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"]
const DELTAS := {
	"north": Vector2(0, -110), "north-east": Vector2(78, -78), "east": Vector2(110, 0), "south-east": Vector2(78, 78),
	"south": Vector2(0, 110), "south-west": Vector2(-78, 78), "west": Vector2(-110, 0), "north-west": Vector2(-78, -78)
}

var host: Node
var scene: Node
var runtime: RefCounted
var artifact_root := ""
var screenshot_root := ""
var crop_root := ""
var enlarged_root := ""
var sidecar_root := ""
var mode := "PLAYER"
var frame_number := 0
var records: Array[Dictionary] = []
var errors: Array[String] = []
var last_crops: Dictionary = {}
var watermark: Label

func start() -> void:
	host = get_parent()
	host.callv("_write_absolute_json", [_join(str(host.call("_artifact_root_from_args")), "v0316-started.json"), {"status": "STARTED_V0316_CAPTURE"}])
	artifact_root = str(host.call("_artifact_root_from_args"))
	screenshot_root = _join(artifact_root, "screenshots")
	crop_root = _join(artifact_root, "crops")
	enlarged_root = _join(artifact_root, "crops_4x")
	sidecar_root = _join(artifact_root, "sidecars")
	mode = str(host.call("_barrosan_presentation_mode_from_args"))
	for path in [screenshot_root, crop_root, enlarged_root, sidecar_root]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	host.callv("_set_capture_viewport", [VIEWPORT_SIZE])
	_add_capture_watermark()
	await _reset_runtime()
	await _capture("01_preflight_head_runtime", "preflight", [WORKER_ID, MILITIA_ID], "rendered runtime after opt-in H3 adapter configuration", false)
	await _capture_idle_cycle("worker_idle", WORKER_ID, 8)
	await _reset_runtime()
	await _capture_locomotion_cycle("worker_locomotion", WORKER_ID, 8)
	await _reset_runtime()
	await _capture_worker_work_cycle()
	await _reset_runtime()
	await _capture_idle_cycle("militia_idle", MILITIA_ID, 8)
	await _reset_runtime()
	await _capture_locomotion_cycle("militia_locomotion", MILITIA_ID, 8)
	await _capture_directional_coverage(WORKER_ID, "worker")
	await _capture_directional_coverage(MILITIA_ID, "militia")
	await _capture_scale_comparison()
	await _capture_bridge_road_traversal()
	await _capture_formations()
	await _capture_save_load()
	await _capture_rollback()
	await _capture_hold_contract()

	var status: Dictionary = scene.call("get_v0314_h3_directional_animation_status") if scene != null and scene.has_method("get_v0314_h3_directional_animation_status") else {}
	var manifest := {
		"schemaVersion": 3,
		"checkpoint": "v0.316",
		"mode": mode,
		"status": "PASS_V0316_H3_VISIBLE_ANIMATION_DIRECTIONAL_CLOSURE_CAPTURE" if errors.is_empty() else "FAIL_V0316_H3_VISIBLE_ANIMATION_DIRECTIONAL_CLOSURE_CAPTURE",
		"captureCount": records.size(),
		"physicalPngCount": records.size(),
		"h3OptIn": true,
		"integratedRoles": ["Worker", "Militia"],
		"animationStatus": status,
		"directions": DIRECTIONS,
		"directionFamiliesRequired": 4,
		"holdUiContract": "HIDDEN_WHEN_UNSUPPORTED",
		"records": records,
		"defaultRuntimeChanged": false,
		"gameplayChanged": false,
		"movementOwnedByAnimation": false,
		"rootMotion": false,
		"evidenceIntegrity": "RENDERED_CROPS_AFTER_FRAME_POST_DRAW_WITH_GLOBAL_HASH_REGISTER",
		"errors": errors,
	}
	host.callv("_write_absolute_json", [_join(artifact_root, "capture-manifest.json"), manifest])
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
	host.set("current_step_id", "v0316_h3_visible_animation_directional_closure")
	host.callv("_render_player_screen", ["battle"])
	await _settle(10)

func _capture_idle_cycle(prefix: String, id: String, count: int) -> void:
	_select(id)
	for index in range(count):
		await _wait_seconds(0.135)
		await _capture("%s_%02d" % [prefix, index + 1], prefix, [id], "continuous rendered %s cycle sample %d" % [prefix, index + 1], true)

func _capture_locomotion_cycle(prefix: String, id: String, count: int) -> void:
	_select(id)
	var origin: Vector2 = _position(id)
	runtime.issue_move_order(origin + Vector2(240, 18))
	scene.call("_sync_unit_visuals")
	for index in range(count):
		runtime.advance_live_frame()
		scene.call("_sync_unit_visuals")
		await _settle(2)
		await _capture("%s_%02d" % [prefix, index + 1], prefix, [id], "continuous rendered %s sample %d" % [prefix, index + 1], true)

func _capture_worker_work_cycle() -> void:
	_select(WORKER_ID)
	runtime.capture_mine_site()
	runtime.assign_worker_to_mine(WORKER_ID)
	scene.call("_sync_unit_visuals")
	for index in range(8):
		await _wait_seconds(0.135)
		await _capture("worker_work_%02d" % (index + 1), "worker_work", [WORKER_ID], "continuous rendered Worker work sample %d" % (index + 1), true)

func _capture_directional_coverage(id: String, label: String) -> void:
	for direction in DIRECTIONS:
		await _reset_runtime()
		_select(id)
		var origin: Vector2 = _position(id)
		runtime.issue_move_order(origin + DELTAS[direction])
		scene.call("_sync_unit_visuals")
		await _settle(3)
		await _capture("direction_%s_%s" % [label, direction.replace("-", "_")], "direction_%s" % label, [id], "authoritative %s facing proof" % direction, false)

func _capture_scale_comparison() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	if scene.has_method("set_v0314_h3_presentation_scale"):
		for item in [["scale_current_1_00", 1.0], ["scale_candidate_0_88", 0.88], ["scale_candidate_0_76", 0.76]]:
			scene.callv("set_v0314_h3_presentation_scale", [float(item[1])])
			var adapter = scene.get("barrosan_h3_directional_animation_adapter")
			if adapter != null and is_instance_valid(adapter) and adapter.has_method("set_proof_phase"):
				adapter.call("set_proof_phase", 0)
			await _settle(2)
			await _capture(str(item[0]), "scale_comparison", [MILITIA_ID], "same unit/state/frame environment at scale %.2f" % float(item[1]), false)
		scene.callv("set_v0314_h3_presentation_scale", [1.0])

func _capture_bridge_road_traversal() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	var waypoints := [Vector2(800, 475), Vector2(900, 475), Vector2(1000, 475), Vector2(1100, 475), Vector2(1180, 475)]
	for index in range(waypoints.size()):
		var target: Vector2 = waypoints[index]
		runtime.issue_move_order(target)
		scene.call("_sync_unit_visuals")
		await _settle(2)
		await _capture("bridge_traversal_%02d" % (index + 1), "bridge_traversal", [MILITIA_ID], "authoritative bridge traversal waypoint %d" % (index + 1), false)
		for _step in range(3):
			runtime.advance_live_frame()
			scene.call("_sync_unit_visuals")
			await _settle(1)
	for index in range(4):
		var target := Vector2(520 + index * 120, 430)
		runtime.issue_move_order(target)
		scene.call("_sync_unit_visuals")
		await _settle(2)
		await _capture("road_traversal_%02d" % (index + 1), "road_traversal", [MILITIA_ID], "authoritative road traversal waypoint %d" % (index + 1), false)

func _capture_formations() -> void:
	for item in [["formation_12", "M", 12], ["formation_24", "L", 24]]:
		await _reset_runtime()
		scene.callv("set_workload_tier", [str(item[1])])
		runtime.box_select_squad(int(item[2]))
		scene.call("_sync_unit_visuals")
		await _settle(3)
		var ids: Array[String] = []
		for id in runtime.selected_ids:
			ids.append(str(id))
		await _capture(str(item[0]) + "_phase_a", "formation_%s" % str(item[1]), ids, "real mixed-role formation phase A", false)
		await _wait_seconds(0.14)
		await _capture(str(item[0]) + "_phase_b", "formation_%s" % str(item[1]), ids, "real mixed-role formation phase B", true)

func _capture_save_load() -> void:
	await _reset_runtime()
	_select(WORKER_ID)
	runtime.capture_mine_site()
	runtime.assign_worker_to_mine(WORKER_ID)
	scene.call("_sync_unit_visuals")
	await _settle(2)
	var save_state: Dictionary = runtime.capture_save_state()
	var save_path := _join(artifact_root, "v0316-nondefault-worker-working-save.json")
	var file := FileAccess.open(ProjectSettings.globalize_path(save_path), FileAccess.WRITE)
	if file == null:
		errors.append("v0.316 writable save could not be opened")
	else:
		file.store_string(JSON.stringify(save_state, "  "))
		file.close()
	await _capture("save_before", "save_load", [WORKER_ID], "non-default Worker working state before file-backed save", false)
	await _reset_runtime()
	var loaded := _read_json(save_path)
	if loaded.is_empty() or not runtime.restore_capture_save_state(loaded):
		errors.append("v0.316 non-default save did not reconstruct")
	scene.call("_sync_unit_visuals")
	await _settle(3)
	await _capture("save_after", "save_load", [WORKER_ID], "non-default Worker working state after file-backed reconstruction", false)

func _capture_rollback() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	await _capture("rollback_animated", "rollback_animated", [MILITIA_ID], "ANIMATED_H3 snapshot", false)
	if scene.has_method("set_v0314_h3_directional_animation_enabled"):
		scene.callv("set_v0314_h3_directional_animation_enabled", [false])
		await _settle(3)
		await _capture("rollback_static", "rollback_static", [MILITIA_ID], "STATIC_H3_V0311 snapshot", false)
	if scene.has_method("set_v0311_h3_runtime_pilot_enabled"):
		scene.callv("set_v0311_h3_runtime_pilot_enabled", [false])
		await _settle(3)
		await _capture("rollback_fallback", "rollback_fallback", [MILITIA_ID], "FALLBACK_RENDERER snapshot", false)
	if scene.has_method("set_v0311_h3_runtime_pilot_enabled"):
		scene.callv("set_v0311_h3_runtime_pilot_enabled", [true])
	if scene.has_method("set_v0314_h3_directional_animation_enabled"):
		scene.callv("set_v0314_h3_directional_animation_enabled", [true])
	await _settle(4)
	await _capture("rollback_reconstructed", "rollback_reconstructed", [MILITIA_ID], "ANIMATED_H3_RECONSTRUCTED snapshot", false)

func _capture_hold_contract() -> void:
	await _reset_runtime()
	_select(MILITIA_ID)
	var before := _authoritative_digest()
	var event := InputEventKey.new()
	event.keycode = KEY_H
	event.pressed = true
	if host.has_method("_input"):
		host.call("_input", event)
	await _settle(2)
	var after := _authoritative_digest()
	await _capture("hold_contract", "hold_contract", [MILITIA_ID], "H hidden and unsupported; authoritative digest unchanged", false)
	if before != after:
		errors.append("H input changed authoritative state")

func _capture(event_id: String, scenario: String, ids: Array[String], note: String, advance_animation: bool) -> void:
	if advance_animation:
		await _settle(2)
	else:
		await _settle(2)
	frame_number += 1
	var filename := "%s_%03d_%s.png" % [mode.to_lower(), frame_number, event_id]
	watermark.text = "V0.316 LIVE RUNTIME | %s | %s | %s" % [mode, scenario, _caption_for(ids)]
	await _settle(1)
	if scenario == "scale_comparison":
		var phase_adapter = scene.get("barrosan_h3_directional_animation_adapter")
		if phase_adapter != null and is_instance_valid(phase_adapter) and phase_adapter.has_method("set_proof_phase"):
			phase_adapter.call("set_proof_phase", 0)
			await get_tree().process_frame
			RenderingServer.force_draw(false)
	var image := get_viewport().get_texture().get_image()
	var absolute := ProjectSettings.globalize_path(_join(screenshot_root, filename))
	if image.save_png(absolute) != OK:
		errors.append("failed to save %s" % filename)
		return
	var rendered_units: Array[Dictionary] = []
	for id in ids:
		var crop := _unit_crop(image, id)
		if crop.is_empty():
			continue
		var crop_filename := "%s__%s_crop.png" % [filename.trim_suffix(".png"), id]
		var crop_absolute := ProjectSettings.globalize_path(_join(crop_root, crop_filename))
		crop["image"].save_png(crop_absolute)
		var enlarged: Image = crop["image"].duplicate()
		enlarged.resize(int(crop["rect"]["w"]) * 4, int(crop["rect"]["h"]) * 4, Image.INTERPOLATE_NEAREST)
		var enlarged_filename := crop_filename.trim_suffix(".png") + "_4x.png"
		enlarged.save_png(ProjectSettings.globalize_path(_join(enlarged_root, enlarged_filename)))
		var prior_key := "%s:%s" % [scenario, id]
		var prior: Image = last_crops.get(prior_key)
		var diff := _image_diff(crop["image"], prior)
		last_crops[prior_key] = crop["image"].duplicate()
		rendered_units.append({
			"id": id,
			"sourceRuntimeScreenshot": filename,
			"timestampSeconds": Time.get_ticks_msec() / 1000.0,
			"cropFilename": crop_filename,
			"cropRect": crop["rect"],
			"cropSha256": str(host.callv("_sha256_file", [crop_absolute])),
			"cropPerceptualHash": _perceptual_hash(crop["image"]),
			"changedPixelCount": diff["changedPixelCount"],
			"changedPixelPercent": diff["changedPixelPercent"],
			"maxChannelDiff": diff["maxChannelDiff"],
			"groundAnchor": crop["groundAnchor"],
			"selectionAnchor": crop["selectionAnchor"],
			"shadowAnchor": crop["shadowAnchor"],
			"renderedBbox": crop["renderedBbox"],
			"nearestNeighbor4x": _join("crops_4x", enlarged_filename),
		})
	var row := {
		"semanticEventId": "v0316-%s" % event_id,
		"captureFilename": filename,
		"presentationMode": mode,
		"scenario": scenario,
		"stableUnitIds": ids,
		"selectedIds": runtime.selected_ids.duplicate() if runtime != null else [],
		"units": ids.map(func(id: String) -> Dictionary: return _unit_snapshot(id)),
		"animationRuntime": ids.map(func(id: String) -> Dictionary: return _animation_snapshot(id)),
		"renderedUnits": rendered_units,
		"camera": _camera_snapshot(),
		"holdContract": "HIDDEN_WHEN_UNSUPPORTED",
		"gameplayMutation": false,
		"rootMotion": false,
		"screenshotSha256": str(host.callv("_sha256_file", [absolute])),
		"note": note,
		"acceptedReason": "rendered crop captured after frame_post_draw",
	}
	records.append(row)
	host.callv("_write_absolute_json", [_join(sidecar_root, filename.trim_suffix(".png") + ".json"), row])

func _unit_crop(image: Image, id: String) -> Dictionary:
	var unit: Dictionary = _unit_snapshot(id)
	if unit.is_empty():
		return {}
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return {}
	var screen: Vector2 = Vector2.ZERO
	var adapter = scene.get("barrosan_h3_directional_animation_adapter")
	var proxy_nodes: Dictionary = adapter.get("proxy_nodes") if adapter != null and is_instance_valid(adapter) else {}
	var proxy := proxy_nodes.get(id) as Node3D
	if proxy != null and is_instance_valid(proxy):
		var sprite := proxy.get_node_or_null("H3AnimatedBillboard") as MeshInstance3D
		screen = camera.unproject_position(sprite.global_position if sprite != null else proxy.global_position + Vector3(0.0, 0.70, 0.0))
	else:
		var position := Vector2(float(unit["position"]["x"]), float(unit["position"]["y"]))
		screen = camera.unproject_position(scene.call("_to_world", position, 0.8))
	var rect := Rect2i(int(screen.x - 48.0), int(screen.y - 92.0), 96, 112)
	rect.position.x = clampi(rect.position.x, 0, image.get_width() - rect.size.x)
	rect.position.y = clampi(rect.position.y, 0, image.get_height() - rect.size.y)
	var crop_image := image.get_region(rect)
	return {"image": crop_image, "rect": {"x": rect.position.x, "y": rect.position.y, "w": rect.size.x, "h": rect.size.y}, "groundAnchor": {"x": 48, "y": 91}, "selectionAnchor": {"x": 48, "y": 89}, "shadowAnchor": {"x": 48, "y": 94}, "renderedBbox": {"x": 24, "y": 7, "w": 48, "h": 89}}

func _image_diff(current: Image, prior: Image) -> Dictionary:
	if prior == null:
		return {"changedPixelCount": 0, "changedPixelPercent": 0.0, "maxChannelDiff": 0}
	var changed := 0
	var maximum := 0
	var total := current.get_width() * current.get_height()
	for y in range(current.get_height()):
		for x in range(current.get_width()):
			var a := current.get_pixel(x, y)
			var b := prior.get_pixel(x, y)
			var delta := maxi(maxi(absi(int(a.r8) - int(b.r8)), absi(int(a.g8) - int(b.g8))), maxi(absi(int(a.b8) - int(b.b8)), absi(int(a.a8) - int(b.a8))))
			if delta > 2:
				changed += 1
			maximum = maxi(maximum, delta)
	return {"changedPixelCount": changed, "changedPixelPercent": snappedf(float(changed) / float(maxi(1, total)) * 100.0, 0.01), "maxChannelDiff": maximum}

func _perceptual_hash(image: Image) -> String:
	var small := image.duplicate()
	small.resize(8, 8, Image.INTERPOLATE_BILINEAR)
	var values: Array[float] = []
	var total := 0.0
	for y in range(8):
		for x in range(8):
			var pixel: Color = small.get_pixel(x, y)
			var value: float = pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114
			values.append(value)
			total += value
	var average := total / 64.0
	var output := ""
	for value in values:
		output += "1" if value >= average else "0"
	return output

func _animation_snapshot(id: String) -> Dictionary:
	var adapter = scene.get("barrosan_h3_directional_animation_adapter")
	if adapter != null and is_instance_valid(adapter) and adapter.has_method("runtime_unit_snapshot"):
		return adapter.call("runtime_unit_snapshot", id)
	return {"id": id, "present": false}

func _unit_snapshot(id: String) -> Dictionary:
	if runtime == null:
		return {}
	for unit in runtime.units:
		if str(unit.get("id", "")) == id:
			return {"id": id, "role": str(unit.get("role", "")), "position": _vec2_dict(unit.get("position", Vector2.ZERO)), "destination": _vec2_dict(unit.get("destination", Vector2.ZERO)), "facing": str(unit.get("facing", "")), "commandState": str(unit.get("commandState", "idle")), "activityState": str(unit.get("activityState", "idle")), "hasDestination": bool(unit.get("hasDestination", false))}
	return {}

func _position(id: String) -> Vector2:
	var snapshot := _unit_snapshot(id)
	return Vector2(float(snapshot.get("position", {}).get("x", 0.0)), float(snapshot.get("position", {}).get("y", 0.0)))

func _camera_snapshot() -> Dictionary:
	var camera := get_viewport().get_camera_3d()
	return {"projection": "orthographic", "position": str(camera.position) if camera != null else "", "size": camera.size if camera != null else 0.0, "mode": mode}

func _authoritative_digest() -> Dictionary:
	return {"selectedIds": runtime.selected_ids.duplicate(), "units": runtime.units.map(func(unit: Dictionary) -> Dictionary: return _unit_snapshot(str(unit.get("id", ""))))}

func _add_capture_watermark() -> void:
	watermark = Label.new()
	watermark.name = "V0316LiveRuntimeEvidenceWatermark"
	watermark.text = "V0.316 LIVE RUNTIME | %s" % mode
	watermark.position = Vector2(18, 866)
	watermark.add_theme_font_size_override("font_size", 12)
	watermark.modulate = Color(0.82, 0.88, 0.78, 0.86)
	host.add_child(watermark)

func _capture_save_path() -> String:
	return _join(artifact_root, "v0316-nondefault-worker-working-save.json")

func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}

func _select(id: String) -> void:
	scene.callv("select_entity", [id])
	scene.call("_sync_unit_visuals")
	scene.call("_sync_hud")

func _hold_contract() -> void:
	pass

func _caption_for(ids: Array[String]) -> String:
	if ids.is_empty():
		return "no-unit"
	return str(_animation_snapshot(ids[0]).get("direction", "")) + "/" + str(_animation_snapshot(ids[0]).get("state", ""))

func _wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _settle(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame
		RenderingServer.force_draw(false)

func _vec2_dict(value: Variant) -> Dictionary:
	var vector := value as Vector2
	return {"x": snappedf(vector.x, 0.01), "y": snappedf(vector.y, 0.01)}

func _join(base: String, child: String) -> String:
	return base.rstrip("/") + "/" + child
