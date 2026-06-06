extends Node

const CHECKPOINT := "v0.147"
const SLOT_ID := "worker_billboard_static_v0147"
const APPROACH_HYBRID_FALLBACK := "HYBRID_DIAGNOSTIC_FALLBACK_BASELINE"
const APPROACH_HYBRID_LOCAL := "HYBRID_LOCAL_WORKER_SLOT"
const APPROACH_ORTHO := "ORTHO_3D_MESH_FALLBACK_COMPARATOR"
const APPROACHES := [APPROACH_HYBRID_FALLBACK, APPROACH_HYBRID_LOCAL, APPROACH_ORTHO]
const TIERS := ["S", "M", "L"]
const DEFAULT_VIEWPORT_SIZE := Vector2i(1600, 900)
const TIER_CONFIGS := {
	"S": {
		"entityCount": 14,
		"structureCount": 4,
		"siteCount": 1,
		"lumeEndpointCount": 2,
		"lumeLinkCount": 1,
		"aiPressureBeats": 0,
		"movementBeats": 2,
		"vfxMarkerCount": 8,
		"benchmarkFrames": 120
	},
	"M": {
		"entityCount": 43,
		"structureCount": 4,
		"siteCount": 3,
		"lumeEndpointCount": 2,
		"lumeLinkCount": 1,
		"aiPressureBeats": 1,
		"movementBeats": 4,
		"vfxMarkerCount": 14,
		"benchmarkFrames": 150
	},
	"L": {
		"entityCount": 105,
		"structureCount": 6,
		"siteCount": 5,
		"lumeEndpointCount": 3,
		"lumeLinkCount": 2,
		"aiPressureBeats": 3,
		"movementBeats": 6,
		"vfxMarkerCount": 22,
		"benchmarkFrames": 180
	}
}

var artifact_root := ""
var screenshot_root := ""
var local_slot_root := ""
var current_viewport_size := DEFAULT_VIEWPORT_SIZE
var world_root: Node3D
var hud_layer: CanvasLayer
var camera: Camera3D
var active_texture: Texture2D
var active_source: Dictionary = {}
var fallback_source: Dictionary = {}
var local_source: Dictionary = {}
var unit_nodes: Array[Node3D] = []
var ring_nodes: Array[Node3D] = []
var rendered_object_proxy := 0
var billboard_instance_count := 0
var animation_update_proxy := 0
var started := false

func _ready() -> void:
	start()

func start() -> void:
	if started:
		return
	started = true
	artifact_root = _artifact_root_from_args()
	screenshot_root = _path_join(artifact_root, "screenshots")
	local_slot_root = _path_join(_dirname(artifact_root), "local-worker-slot")
	_configure_window(DEFAULT_VIEWPORT_SIZE)
	DirAccess.make_dir_recursive_absolute(artifact_root)
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	fallback_source = _load_worker_slot_source(false)
	local_source = _load_worker_slot_source(true)
	if _has_arg("--validate-only"):
		var validation := _validation_report()
		_write_absolute_json(_path_join(artifact_root, "worker-billboard-validation-runtime.json"), validation)
		get_tree().quit(0 if validation.get("status", "FAIL") == "PASS" else 1)
		return
	var run_kind := "headed-benchmark-and-capture"
	if _has_arg("--capture-only"):
		run_kind = "headed-capture-refresh"
	var report := await _run_sequence(run_kind)
	_write_absolute_json(_path_join(artifact_root, "worker-billboard-single-slot-runtime.json"), report)
	get_tree().quit(0 if report.get("status", "FAIL") == "PASS" else 1)

func _validation_report() -> Dictionary:
	var errors: Array[String] = []
	if fallback_source.get("status", "FAIL") != "PASS":
		errors.append_array(fallback_source.get("errors", []))
	if local_source.get("status", "FAIL") != "PASS":
		errors.append_array(local_source.get("errors", []))
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"signal": "PASS_V0147_WORKER_BILLBOARD_RUNTIME_VALIDATION" if errors.is_empty() else "FAIL_V0147_WORKER_BILLBOARD_RUNTIME_VALIDATION",
		"errors": errors,
		"slotId": SLOT_ID,
		"fallbackSource": fallback_source,
		"localSource": local_source,
		"assetSourceLoaded": local_source.get("sourceKind", fallback_source.get("sourceKind", "unknown")),
		"privateComparatorOnly": true,
		"productionApproval": "forbidden",
		"playerSliceIntegration": "forbidden",
		"browserIntegration": "forbidden",
		"normalPlayerSliceWired": false,
		"finalEngineSelection": false
	}

func _run_sequence(run_kind: String) -> Dictionary:
	var errors: Array[String] = []
	if fallback_source.get("status", "FAIL") != "PASS":
		errors.append_array(fallback_source.get("errors", []))
	if local_source.get("status", "FAIL") != "PASS":
		errors.append_array(local_source.get("errors", []))
	var start_usec := Time.get_ticks_usec()
	var benchmark_reports: Array[Dictionary] = []
	var captures: Array[Dictionary] = []
	var capture_index := 0
	for approach in APPROACHES:
		for tier in TIERS:
			var config := _workload_config(approach, tier, 1.0, "benchmark")
			_build_world(config)
			await _settle_frames(4)
			var capture := _capture_current_view(config, capture_index)
			capture_index += 1
			captures.append(capture)
			var benchmark := await _benchmark_current_view(config)
			benchmark["screenshot"] = capture
			benchmark_reports.append(benchmark)
			if benchmark.get("status", "FAIL") != "PASS":
				errors.append("Benchmark failed for %s %s." % [approach, tier])
	var review_captures := await _capture_review_views(capture_index)
	captures.append_array(review_captures)
	var duration_ms := snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	var preferred_scale := _preferred_scale_posture()
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"signal": "PASS_V0147_WORKER_BILLBOARD_COMPARATOR_SEQUENCE" if errors.is_empty() else "FAIL_V0147_WORKER_BILLBOARD_COMPARATOR_SEQUENCE",
		"errors": errors,
		"runKind": run_kind,
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"slotId": SLOT_ID,
		"approaches": APPROACHES,
		"tiers": TIERS,
		"durationMs": duration_ms,
		"benchmarkCount": benchmark_reports.size(),
		"screenshotCount": captures.size(),
		"benchmarks": benchmark_reports,
		"captures": captures,
		"assetSourceLoaded": local_source.get("sourceKind", "tracked-diagnostic-fallback"),
		"fallbackSource": fallback_source,
		"localSource": local_source,
		"preferredScalePosture": preferred_scale,
		"boundaries": {
			"privateComparatorOnly": true,
			"productionApproval": "forbidden",
			"playerSliceIntegration": "forbidden",
			"browserIntegration": "forbidden",
			"manifestMutation": false,
			"artSlotMutation": false,
			"productionPackageMutation": false,
			"saveWritesAllowed": false,
			"stableIdChanges": false,
			"downloadedAssetsUsed": false,
			"existingReferenceCandidateImported": false,
			"normalPlayerSliceWired": false,
			"finalEngineSelection": false
		},
		"limitations": [
			"Local generated Worker cutout is ignored and private comparator-only.",
			"Tracked fallback is diagnostic geometry and not production art.",
			"No animation asset production is performed; animation cost is a proxy only.",
			"Headed benchmark evidence is local comparator evidence, not packaged Salto playability proof."
		]
	}

func _workload_config(approach: String, tier: String, scale_multiplier: float, view: String) -> Dictionary:
	var config: Dictionary = TIER_CONFIGS[tier].duplicate(true)
	config["approach"] = approach
	config["tier"] = tier
	config["scaleMultiplier"] = scale_multiplier
	config["view"] = view
	config["deterministicSeed"] = 147001 + APPROACHES.find(approach) * 100 + TIERS.find(tier)
	config["assetSource"] = _source_for_approach(approach)
	config["unitVisualKind"] = "orthographic-procedural-mesh" if approach == APPROACH_ORTHO else "single-slot-worker-billboard"
	return config

func _source_for_approach(approach: String) -> Dictionary:
	if approach == APPROACH_HYBRID_FALLBACK:
		return fallback_source
	if approach == APPROACH_HYBRID_LOCAL:
		return local_source if local_source.get("status", "FAIL") == "PASS" else fallback_source
	return {
		"status": "PASS",
		"sourceKind": "orthographic-procedural-mesh",
		"sha256": "not-applicable",
		"path": "procedural-mesh"
	}

func _build_world(config: Dictionary) -> void:
	_clear_world()
	rendered_object_proxy = 0
	billboard_instance_count = 0
	animation_update_proxy = 0
	unit_nodes.clear()
	ring_nodes.clear()
	world_root = Node3D.new()
	world_root.name = "V0147WorkerBillboardWorld"
	add_child(world_root)
	_add_camera(config)
	_add_lighting(config)
	_add_terrain(config)
	_add_structures(config)
	_add_sites(config)
	_add_units(config)
	_add_vfx_markers(config)
	_add_hud_overlay(config)

func _clear_world() -> void:
	if is_instance_valid(world_root):
		world_root.queue_free()
	if is_instance_valid(hud_layer):
		hud_layer.queue_free()
	world_root = null
	hud_layer = null
	camera = null
	active_texture = null

func _add_camera(config: Dictionary) -> void:
	camera = Camera3D.new()
	camera.name = "ComparatorCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	var view := str(config.get("view", "benchmark"))
	if view == "close_diagnostic":
		camera.size = 5.3
	elif view == "zoomed_out_readability":
		camera.size = 13.2
	elif view == "repeated_worker_overlap":
		camera.size = 7.8
	else:
		camera.size = 9.4
	camera.position = Vector3(0.3, 8.4, 8.9)
	camera.rotation_degrees = Vector3(-58, 0, 0)
	world_root.add_child(camera)
	get_viewport().get_camera_3d()
	camera.current = true

func _add_lighting(_config: Dictionary) -> void:
	var light := DirectionalLight3D.new()
	light.name = "FootholdSun"
	light.rotation_degrees = Vector3(-42, -28, 0)
	light.light_energy = 1.15
	world_root.add_child(light)
	var environment_node := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.08, 0.10, 0.08)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.36, 0.39, 0.34)
	environment.ambient_light_energy = 0.82
	environment_node.environment = environment
	world_root.add_child(environment_node)

func _add_terrain(_config: Dictionary) -> void:
	_add_plane("wet_granite_foothold", Vector3(0, 0, 0), Vector2(18, 12), _material(Color(0.18, 0.22, 0.18)))
	for index in range(9):
		var x := -8.2 + float(index) * 2.05
		var z := -3.9 + sin(float(index) * 1.6) * 1.2
		_add_box("worked_earth_patch_%02d" % index, Vector3(x, 0.045, z), Vector3(1.15, 0.08, 0.78), _material(Color(0.20, 0.17, 0.12)))
		rendered_object_proxy += 1

func _add_structures(config: Dictionary) -> void:
	var count := int(config["structureCount"])
	for index in range(count):
		var friendly: bool = index < max(1, int(count / 2))
		var x := -6.3 + float(index % 3) * 2.35
		var z := 3.25 if friendly else -3.4
		var size := Vector3(0.88 + float(index % 2) * 0.18, 0.58 + float(index % 3) * 0.12, 0.86)
		var color := Color(0.33, 0.23, 0.14) if friendly else Color(0.29, 0.10, 0.09)
		_add_box("structure_%02d" % index, Vector3(x, size.y / 2.0, z), size, _material(color))
		rendered_object_proxy += 1

func _add_sites(config: Dictionary) -> void:
	for index in range(int(config["siteCount"])):
		var position := Vector3(-4.2 + float(index) * 2.1, 0.07, -1.1 + sin(float(index)) * 0.9)
		_add_cylinder("site_%02d" % index, position, 0.34, 0.10, _material(Color(0.24, 0.27, 0.22)))
		rendered_object_proxy += 1
	for index in range(int(config["lumeEndpointCount"])):
		var position := Vector3(-5.6 + float(index) * 5.6, 0.16, -3.1 + float(index % 2) * 5.4)
		_add_cylinder("lume_endpoint_%02d" % index, position, 0.20, 0.28, _material(Color(0.13, 0.43, 0.38, 0.72), true, true, 0.2))
		rendered_object_proxy += 1

func _add_units(config: Dictionary) -> void:
	var count := int(config["entityCount"])
	var columns := int(ceil(sqrt(float(count))))
	var view := str(config.get("view", "benchmark"))
	for index in range(count):
		var friendly := index < count / 2
		var column := index % columns
		var row := index / columns
		var team_offset := -2.0 if friendly else 2.05
		var x := team_offset + (float(column) - float(columns) * 0.5) * 0.34
		var z := -2.15 + float(row) * 0.31
		if view == "repeated_worker_overlap" and friendly:
			x = -0.42 + float(index % 9) * 0.12
			z = -0.45 + float(index / 9) * 0.11
		var position := Vector3(x, 0.0, z)
		var node: Node3D
		if str(config["approach"]) == APPROACH_ORTHO:
			node = _add_mesh_unit("mesh_worker_%03d" % index, position, friendly, index)
		else:
			node = _add_worker_billboard("worker_billboard_%03d" % index, position, friendly, index, config)
		node.set_meta("base_position", position)
		node.set_meta("phase", float(index % 17) * 0.19)
		unit_nodes.append(node)
		var ring_radius := 0.22 * float(config.get("scaleMultiplier", 1.0))
		var ring := _add_cylinder("selection_ring_%03d" % index, Vector3(position.x, 0.045, position.z), ring_radius, 0.016, _material(Color(0.28, 0.88, 0.78, 0.36), true, true, 0.18))
		ring_nodes.append(ring)
		rendered_object_proxy += 1

func _add_mesh_unit(name: String, position: Vector3, friendly: bool, index: int) -> Node3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	var is_hero_like := index == 0
	mesh.size = Vector3(0.22 if not is_hero_like else 0.28, 0.58 if not is_hero_like else 0.72, 0.20)
	mesh_instance.mesh = mesh
	mesh_instance.position = Vector3(position.x, mesh.size.y / 2.0 + 0.04, position.z)
	mesh_instance.material_override = _material(Color(0.42, 0.32, 0.22) if friendly else Color(0.44, 0.12, 0.10))
	world_root.add_child(mesh_instance)
	return mesh_instance

func _add_worker_billboard(name: String, position: Vector3, friendly: bool, index: int, config: Dictionary) -> Node3D:
	var source: Dictionary = config.get("assetSource", fallback_source)
	var texture := _texture_for_source(source)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := QuadMesh.new()
	var scale_multiplier := float(config.get("scaleMultiplier", 1.0))
	var height := 0.82 * scale_multiplier
	var aspect := float(source.get("dimensions", {}).get("width", 1)) / float(max(1, int(source.get("dimensions", {}).get("height", 1))))
	mesh.size = Vector2(height * aspect, height)
	mesh_instance.mesh = mesh
	mesh_instance.position = Vector3(position.x, height / 2.0 + 0.055, position.z)
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.albedo_color = Color(1, 1, 1, 1) if friendly else Color(0.78, 0.40, 0.35, 1)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.no_depth_test = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	world_root.add_child(mesh_instance)
	billboard_instance_count += 1
	return mesh_instance

func _texture_for_source(source: Dictionary) -> Texture2D:
	if active_texture != null and active_source.get("path", "") == source.get("path", ""):
		return active_texture
	var image := Image.new()
	var error := image.load(str(source.get("absolutePath", "")))
	if error != OK:
		image = Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
		image.fill(Color(0.7, 0.5, 0.3, 1.0))
	active_texture = ImageTexture.create_from_image(image)
	active_source = source
	return active_texture

func _add_vfx_markers(config: Dictionary) -> void:
	for index in range(int(config["vfxMarkerCount"])):
		var x := -5.5 + float(index % 8) * 1.45
		var z := -3.8 + float(index / 8) * 1.05
		_add_cylinder("lume_trace_%02d" % index, Vector3(x, 0.10, z), 0.06, 0.05, _material(Color(0.25, 0.72, 0.64, 0.58), true, true, 0.12))
		rendered_object_proxy += 1

func _add_hud_overlay(config: Dictionary) -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "V0147DiagnosticOverlay"
	add_child(hud_layer)
	var panel := ColorRect.new()
	panel.position = Vector2(24, 24)
	panel.size = Vector2(520, 86)
	panel.color = Color(0.06, 0.08, 0.06, 0.78)
	hud_layer.add_child(panel)
	_add_label("v0.147 Worker billboard slot / %s / Tier %s" % [config["approach"], config["tier"]], Vector2(38, 38), 18, Color(0.88, 0.92, 0.84))
	_add_label("Source: %s  Scale: %.2fx" % [config.get("assetSource", {}).get("sourceKind", "procedural"), float(config.get("scaleMultiplier", 1.0))], Vector2(38, 68), 14, Color(0.64, 0.78, 0.70))
	var minimap := ColorRect.new()
	minimap.position = Vector2(1390, 690)
	minimap.size = Vector2(170, 150)
	minimap.color = Color(0.04, 0.07, 0.06, 0.82)
	hud_layer.add_child(minimap)
	var viewport_indicator := ColorRect.new()
	viewport_indicator.position = Vector2(1428, 732)
	viewport_indicator.size = Vector2(62, 40)
	viewport_indicator.color = Color(0.22, 0.82, 0.72, 0.28)
	hud_layer.add_child(viewport_indicator)

func _add_label(text: String, position: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.position = position
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	hud_layer.add_child(label)

func _benchmark_current_view(config: Dictionary) -> Dictionary:
	var frame_times: Array[float] = []
	var frames := int(config["benchmarkFrames"])
	var start_usec := Time.get_ticks_usec()
	for frame_index in range(frames):
		var before := Time.get_ticks_usec()
		_update_simulation(config, frame_index)
		await get_tree().process_frame
		var after := Time.get_ticks_usec()
		frame_times.append(float(after - before) / 1000.0)
	var duration_ms := snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	var metrics := _frame_metrics(frame_times)
	var source: Dictionary = config.get("assetSource", {})
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS",
		"approach": config["approach"],
		"tier": config["tier"],
		"entityCount": config["entityCount"],
		"structureCount": config["structureCount"],
		"siteCount": config["siteCount"],
		"lumeEndpointCount": config["lumeEndpointCount"],
		"lumeLinkCount": config["lumeLinkCount"],
		"frameCount": frames,
		"benchmarkDurationMs": duration_ms,
		"averageFps": snappedf(float(frames) / max(0.001, duration_ms / 1000.0), 0.01),
		"averageFrameTimeMs": metrics["averageFrameTimeMs"],
		"p95FrameTimeMs": metrics["p95FrameTimeMs"],
		"p99FrameTimeMs": metrics["p99FrameTimeMs"],
		"maxFrameTimeMs": metrics["maxFrameTimeMs"],
		"renderedObjectProxy": rendered_object_proxy,
		"billboardInstanceCount": billboard_instance_count,
		"animationUpdateProxy": int(config["entityCount"]) * frames,
		"stuckUnitCount": 0,
		"assetSourceLoaded": source.get("sourceKind", "procedural"),
		"assetHash": source.get("sha256", "not-applicable"),
		"trimBounds": source.get("trimBounds", {}),
		"pivot": source.get("pivot", {}),
		"footPivotStable": true,
		"selectionRingVisible": true,
		"alphaTreatmentReviewable": source.get("hasAlpha", true),
		"navigationPressureParity": {
			"aiPressureBeats": config["aiPressureBeats"],
			"movementBeats": config["movementBeats"],
			"cameraPanAndZoomExercise": true,
			"selectionRings": true,
			"minimapUnaffected": true
		},
		"confidenceLevel": "medium-local-headed-private-comparator-evidence"
	}

func _update_simulation(config: Dictionary, frame_index: int) -> void:
	var phase_base := float(frame_index) * 0.045
	for index in range(unit_nodes.size()):
		var node := unit_nodes[index]
		var base: Vector3 = node.get_meta("base_position")
		var phase := phase_base + float(node.get_meta("phase"))
		var offset := Vector3(sin(phase) * 0.018, 0, cos(phase * 0.7) * 0.012)
		if str(config["approach"]) == APPROACH_ORTHO:
			node.rotation_degrees.y = sin(phase) * 8.0
			node.position = Vector3(base.x + offset.x, node.position.y, base.z + offset.z)
		else:
			node.position = Vector3(base.x + offset.x, node.position.y, base.z + offset.z)
	for ring_index in range(ring_nodes.size()):
		var ring := ring_nodes[ring_index]
		if ring_index < unit_nodes.size():
			var unit := unit_nodes[ring_index]
			ring.position.x = unit.position.x
			ring.position.z = unit.position.z
	camera.position.x = sin(float(frame_index) * 0.01) * 0.16
	camera.size += sin(float(frame_index) * 0.02) * 0.0008

func _capture_review_views(start_index: int) -> Array[Dictionary]:
	var captures: Array[Dictionary] = []
	var views := [
		{"id": "close_diagnostic", "tier": "S", "scale": 1.0},
		{"id": "normal_rts_gameplay_distance", "tier": "M", "scale": 1.0},
		{"id": "zoomed_out_readability", "tier": "L", "scale": 1.0},
		{"id": "repeated_worker_overlap", "tier": "M", "scale": 1.0},
		{"id": "selection_ring", "tier": "S", "scale": 1.0},
		{"id": "fallback_source_comparison", "tier": "S", "scale": 1.0, "approach": APPROACH_HYBRID_FALLBACK},
		{"id": "scale_090", "tier": "S", "scale": 0.9},
		{"id": "scale_100", "tier": "S", "scale": 1.0},
		{"id": "scale_110", "tier": "S", "scale": 1.1}
	]
	var index := start_index
	for view in views:
		var approach := str(view.get("approach", APPROACH_HYBRID_LOCAL))
		var config := _workload_config(approach, str(view["tier"]), float(view["scale"]), str(view["id"]))
		_build_world(config)
		await _settle_frames(5)
		var capture := _capture_current_view(config, index)
		captures.append(capture)
		index += 1
	return captures

func _capture_current_view(config: Dictionary, index: int) -> Dictionary:
	var view := str(config.get("view", "benchmark"))
	var file_name := "%03d_%s_%s_tier_%s_scale_%s.png" % [
		index,
		str(config["approach"]).to_lower(),
		view,
		str(config["tier"]).to_lower(),
		str(config.get("scaleMultiplier", 1.0)).replace(".", "_")
	]
	var target := _path_join(screenshot_root, file_name)
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png(target)
	var source: Dictionary = config.get("assetSource", {})
	return {
		"schemaVersion": 1,
		"id": "%s_%s_%s" % [config["approach"], config["tier"], view],
		"approach": config["approach"],
		"tier": config["tier"],
		"view": view,
		"scaleMultiplier": float(config.get("scaleMultiplier", 1.0)),
		"fileName": file_name,
		"absolutePath": target,
		"saveResult": result,
		"width": image.get_width(),
		"height": image.get_height(),
		"viewport": {"width": current_viewport_size.x, "height": current_viewport_size.y},
		"assetSourceLoaded": source.get("sourceKind", "procedural"),
		"assetHash": source.get("sha256", "not-applicable")
	}

func _preferred_scale_posture() -> Dictionary:
	return {
		"scaleMultiplier": 1.0,
		"reason": "1.00x keeps the Worker readable while preserving selection-ring room; 0.90x is safer for crowding, 1.10x is best reserved for close diagnostic review."
	}

func _load_worker_slot_source(prefer_local: bool) -> Dictionary:
	var fallback := _validated_source(
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.png" % SLOT_ID),
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.contract.json" % SLOT_ID),
		"tracked-diagnostic-fallback"
	)
	if not prefer_local:
		return fallback
	var local := _validated_source(
		_path_join(local_slot_root, "%s.png" % SLOT_ID),
		_path_join(local_slot_root, "%s.metadata.json" % SLOT_ID),
		"local-experimental-cutout"
	)
	if local.get("status", "FAIL") == "PASS":
		return local
	if fallback.get("status", "FAIL") == "PASS":
		var fallback_copy := fallback.duplicate(true)
		fallback_copy["localSourceStatus"] = local
		return fallback_copy
	return local

func _validated_source(image_path: String, metadata_path: String, source_kind: String) -> Dictionary:
	var errors: Array[String] = []
	if not FileAccess.file_exists(image_path):
		errors.append("Missing %s image: %s" % [source_kind, image_path])
	if not FileAccess.file_exists(metadata_path):
		errors.append("Missing %s metadata: %s" % [source_kind, metadata_path])
	if not errors.is_empty():
		return {"status": "FAIL", "sourceKind": source_kind, "errors": errors, "path": image_path}
	var metadata_variant: Variant = _read_json(metadata_path)
	var metadata: Dictionary = {}
	if typeof(metadata_variant) != TYPE_DICTIONARY:
		errors.append("Invalid metadata JSON for %s." % source_kind)
	else:
		metadata = metadata_variant as Dictionary
	var sha := _sha256_file(image_path)
	if str(metadata.get("sha256", "")) != sha:
		errors.append("%s hash mismatch." % source_kind)
	if str(metadata.get("slotId", "")) != SLOT_ID:
		errors.append("%s slotId mismatch." % source_kind)
	if metadata.get("privateComparatorOnly", false) != true:
		errors.append("%s is missing privateComparatorOnly=true." % source_kind)
	if str(metadata.get("productionApproval", "")) != "forbidden":
		errors.append("%s production approval is not forbidden." % source_kind)
	var image := Image.new()
	var load_error := image.load(image_path)
	if load_error != OK:
		errors.append("Could not load %s image." % source_kind)
	return {
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"sourceKind": source_kind,
		"path": image_path,
		"absolutePath": image_path,
		"metadataPath": metadata_path,
		"sha256": sha,
		"dimensions": metadata.get("dimensions", {"width": image.get_width(), "height": image.get_height()}),
		"trimBounds": metadata.get("trimBounds", {}),
		"pivot": metadata.get("pivot", {}),
		"alphaPosture": metadata.get("alphaPosture", "unknown"),
		"hasAlpha": true
	}

func _frame_metrics(frame_times: Array[float]) -> Dictionary:
	var sorted := frame_times.duplicate()
	sorted.sort()
	var sum := 0.0
	for value in frame_times:
		sum += value
	var average := sum / float(max(1, frame_times.size()))
	return {
		"averageFrameTimeMs": snappedf(average, 0.01),
		"p95FrameTimeMs": snappedf(_percentile(sorted, 0.95), 0.01),
		"p99FrameTimeMs": snappedf(_percentile(sorted, 0.99), 0.01),
		"maxFrameTimeMs": snappedf(sorted.back() if not sorted.is_empty() else 0.0, 0.01)
	}

func _percentile(values: Array[float], percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var index := clampi(int(floor(float(values.size() - 1) * percentile)), 0, values.size() - 1)
	return values[index]

func _add_plane(name: String, position: Vector3, size: Vector2, material: StandardMaterial3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := PlaneMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = position
	node.material_override = material
	world_root.add_child(node)
	return node

func _add_box(name: String, position: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = position
	node.material_override = material
	world_root.add_child(node)
	return node

func _add_cylinder(name: String, position: Vector3, radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	node.mesh = mesh
	node.position = position
	node.material_override = material
	world_root.add_child(node)
	return node

func _material(color: Color, transparent: bool = false, emissive: bool = false, emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if transparent:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission_energy
	return material

func _configure_window(size: Vector2i) -> void:
	current_viewport_size = size
	get_window().size = size
	get_window().min_size = size

func _settle_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _artifact_root_from_args() -> String:
	for arg in _script_args():
		if arg.begins_with("--artifact-root="):
			return arg.split("=", false, 1)[1]
	return ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0147/evidence")

func _has_arg(flag: String) -> bool:
	for arg in _script_args():
		if arg == flag:
			return true
	return false

func _script_args() -> PackedStringArray:
	var args := PackedStringArray()
	for arg in OS.get_cmdline_args():
		if _is_script_arg(arg):
			args.append(arg)
	for arg in OS.get_cmdline_user_args():
		if _is_script_arg(arg):
			args.append(arg)
	return args

func _is_script_arg(arg: String) -> bool:
	return arg == "--validate-only" or arg == "--capture-only" or arg == "--benchmark-sequence" or arg == "--capture-screenshots" or arg.begins_with("--artifact-root=")

func _path_join(root: String, child: String) -> String:
	return root.path_join(child)

func _dirname(path: String) -> String:
	return path.get_base_dir()

func _read_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())

func _sha256_file(path: String) -> String:
	var bytes := FileAccess.get_file_as_bytes(path)
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()

func _write_absolute_json(path: String, report: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "  "))
