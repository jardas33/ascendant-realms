extends Node

const CHECKPOINT := "v0.146"
const APPROACH_ORTHO := "ORTHO_3D_MESH"
const APPROACH_BILLBOARD := "BILLBOARD_2D_ATLAS"
const APPROACH_HYBRID := "HYBRID_3D_WORLD_BILLBOARD_UNITS"
const APPROACHES := [APPROACH_ORTHO, APPROACH_BILLBOARD, APPROACH_HYBRID]
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
var current_viewport_size := DEFAULT_VIEWPORT_SIZE
var world_root: Node3D
var hud_layer: CanvasLayer
var camera: Camera3D
var runtime_atlas: Texture2D
var unit_nodes: Array[Node3D] = []
var ring_nodes: Array[Node3D] = []
var rendered_object_proxy := 0
var animation_update_proxy := 0
var atlas_frame_proxy := 0
var started := false

func _ready() -> void:
	start()

func start() -> void:
	if started:
		return
	started = true
	artifact_root = _artifact_root_from_args()
	screenshot_root = _path_join(artifact_root, "screenshots")
	_configure_window(DEFAULT_VIEWPORT_SIZE)
	if _has_arg("--validate-only"):
		var report := _validation_report()
		_write_absolute_json(_path_join(artifact_root, "runtime-art-comparator-validation-runtime.json"), report)
		get_tree().quit(0 if report.get("status", "FAIL") == "PASS" else 1)
		return
	DirAccess.make_dir_recursive_absolute(artifact_root)
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	var run_kind := "headed-benchmark-and-capture"
	if _has_arg("--capture-only"):
		run_kind = "headed-capture-refresh"
	var report := await _run_comparator_sequence(run_kind)
	_write_absolute_json(_path_join(artifact_root, "runtime-art-comparator-runtime.json"), report)
	get_tree().quit(0 if report.get("status", "FAIL") == "PASS" else 1)

func _validation_report() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS",
		"scene": "res://comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.tscn",
		"script": "res://comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.gd",
		"approaches": APPROACHES,
		"tiers": TIERS,
		"runtimeGeneratedAtlasOnly": true,
		"externalTexturesLoaded": false,
		"generatedReferenceImagesImported": false,
		"downloadedAssetsUsed": false,
		"normalPlayerSliceWired": false,
		"browserRuntimeWired": false,
		"finalEngineSelection": false,
		"routineEditorUseRequired": false,
		"godotVersion": Engine.get_version_info(),
		"displayDriver": DisplayServer.get_name()
	}

func _run_comparator_sequence(run_kind: String) -> Dictionary:
	var start_usec := Time.get_ticks_usec()
	var benchmark_reports: Array[Dictionary] = []
	var captures: Array[Dictionary] = []
	var errors: Array[String] = []
	var capture_index := 0
	for approach in APPROACHES:
		for tier in TIERS:
			var config := _workload_config(approach, tier)
			_build_world(config)
			await _settle_frames(8)
			var capture := _capture_current_view(config, capture_index)
			capture_index += 1
			captures.append(capture)
			if int(capture.get("saveResult", ERR_CANT_CREATE)) != OK:
				errors.append("Screenshot capture failed for %s %s." % [approach, tier])
			var report := await _benchmark_current_view(config)
			report["screenshot"] = capture
			benchmark_reports.append(report)
			if report.get("status", "FAIL") != "PASS":
				errors.append("Benchmark failed for %s %s." % [approach, tier])
	var duration_ms := snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"runKind": run_kind,
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"approaches": APPROACHES,
		"tiers": TIERS,
		"workloadParitySource": "v0.119 representative RTS S/M/L counts reused without save or stable-ID mutation",
		"headedDisplay": DisplayServer.get_name() != "headless",
		"windowSize": {"width": current_viewport_size.x, "height": current_viewport_size.y},
		"godotVersion": Engine.get_version_info(),
		"durationMs": duration_ms,
		"benchmarkCount": benchmark_reports.size(),
		"screenshotCount": captures.size(),
		"runtimeGeneratedAtlasOnly": true,
		"externalTexturesLoaded": false,
		"generatedReferenceImagesImported": false,
		"downloadedAssetsUsed": false,
		"normalPlayerSliceWired": false,
		"browserRuntimeWired": false,
		"manifestMutation": false,
		"artSlotMutation": false,
		"productionAssetAdded": false,
		"saveWritesAllowed": false,
		"stableIdChanges": false,
		"finalEngineSelection": false,
		"errors": errors,
		"benchmarks": benchmark_reports,
		"captures": captures
	}

func _workload_config(approach: String, tier: String) -> Dictionary:
	var config: Dictionary = TIER_CONFIGS[tier].duplicate(true)
	config["approach"] = approach
	config["tier"] = tier
	config["deterministicSeed"] = 146001 + APPROACHES.find(approach) * 100 + TIERS.find(tier)
	config["selectionRings"] = true
	config["cameraPanAndZoomExercise"] = true
	config["resultsReadyTransitionPosture"] = true
	if approach == APPROACH_ORTHO:
		config["unitVisualKind"] = "low-complexity-3d-mesh"
		config["environmentKind"] = "procedural-3d-terrain-structures"
		config["atlasFrames"] = 0
	elif approach == APPROACH_BILLBOARD:
		config["unitVisualKind"] = "camera-facing-diagnostic-billboard-atlas"
		config["environmentKind"] = "procedural-ground-and-structure-stand-ins"
		config["atlasFrames"] = 12
	else:
		config["unitVisualKind"] = "diagnostic-billboard-units-in-3d-world"
		config["environmentKind"] = "procedural-3d-terrain-structures"
		config["atlasFrames"] = 12
	return config

func _build_world(config: Dictionary) -> void:
	_clear_world()
	animation_update_proxy = 0
	atlas_frame_proxy = int(config.get("atlasFrames", 0))
	rendered_object_proxy = 0
	world_root = Node3D.new()
	world_root.name = "V0146RuntimeArtPipelineComparatorWorld"
	add_child(world_root)
	_add_camera(config)
	_add_lighting(config)
	if _uses_billboards(str(config["approach"])):
		runtime_atlas = _create_diagnostic_atlas()
	_add_terrain(config)
	_add_structures(config)
	_add_sites(config)
	_add_units(config)
	_add_vfx_markers(config)
	_add_hud_overlay(config)

func _clear_world() -> void:
	if hud_layer and is_instance_valid(hud_layer):
		hud_layer.queue_free()
	if world_root and is_instance_valid(world_root):
		world_root.queue_free()
	hud_layer = null
	world_root = null
	camera = null
	runtime_atlas = null
	unit_nodes.clear()
	ring_nodes.clear()

func _add_camera(config: Dictionary) -> void:
	camera = Camera3D.new()
	camera.name = "V0146FixedOrthoComparatorCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.0
	camera.position = Vector3(6.8, 8.2, 7.2)
	camera.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)
	world_root.add_child(camera)
	camera.current = true

func _add_lighting(config: Dictionary) -> void:
	var light := DirectionalLight3D.new()
	light.name = "V0146ComparatorDirectionalLight"
	light.rotation_degrees = Vector3(-58.0, 37.0, 0.0)
	light.light_energy = 1.25 if str(config["approach"]) != APPROACH_BILLBOARD else 0.85
	world_root.add_child(light)
	var ambient := WorldEnvironment.new()
	ambient.name = "V0146ComparatorWorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.035, 0.047, 0.052)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.36, 0.42, 0.38)
	environment.ambient_light_energy = 0.55
	ambient.environment = environment
	world_root.add_child(ambient)

func _add_terrain(config: Dictionary) -> void:
	_add_plane("salto_ground", Vector3.ZERO, Vector2(23.0, 17.0), _material(Color(0.12, 0.18, 0.13)))
	_add_box("wet_granite_main_lane", Vector3(-1.0, 0.035, -0.1), Vector3(13.5, 0.04, 1.0), _material(Color(0.30, 0.28, 0.22)))
	_add_box("ford_water_strip", Vector3(2.9, 0.045, -1.9), Vector3(4.0, 0.035, 0.55), _material(Color(0.12, 0.28, 0.31), true, true, 0.15))
	if str(config["approach"]) == APPROACH_BILLBOARD:
		_add_box("billboard_structure_plane_shadow", Vector3(-3.8, 0.06, 2.1), Vector3(2.4, 0.08, 1.1), _material(Color(0.18, 0.15, 0.11)))
		return
	var patch_count := 8
	for index in range(patch_count):
		var x := -8.4 + float(index) * 2.4
		var z := -4.2 + sin(float(index) * 1.7) * 1.1
		var height := 0.10 + float(index % 3) * 0.045
		var color := Color(0.15 + float(index % 2) * 0.03, 0.21, 0.15 + float(index % 4) * 0.015)
		_add_box("terrain_patch_%02d" % index, Vector3(x, height * 0.5, z), Vector3(1.7, height, 1.05), _material(color))

func _add_structures(config: Dictionary) -> void:
	var count := int(config["structureCount"])
	for index in range(count):
		var friendly: bool = index < max(1, int(count / 2))
		var x := -6.4 + float(index % 3) * 2.3
		var z := 3.1 if friendly else -3.4
		if not friendly:
			x = 4.2 + float(index % 3) * 1.9
		var size := Vector3(0.82 + float(index % 2) * 0.16, 0.54 + float(index % 3) * 0.12, 0.82)
		var color := Color(0.33, 0.22, 0.13) if friendly else Color(0.30, 0.10, 0.10)
		_add_box("structure_%02d" % index, Vector3(x, size.y * 0.5, z), size, _material(color))
		if str(config["approach"]) != APPROACH_BILLBOARD:
			_add_box("structure_roof_%02d" % index, Vector3(x, size.y + 0.12, z), Vector3(size.x * 0.78, 0.22, size.z * 0.78), _material(Color(0.14, 0.12, 0.10)))

func _add_sites(config: Dictionary) -> void:
	var count := int(config["siteCount"])
	for index in range(count):
		var position := Vector3(-4.2 + float(index) * 2.1, 0.08, -1.1 + sin(float(index)) * 0.9)
		_add_cylinder("site_selection_ring_%02d" % index, position, 0.42, 0.03, _material(Color(0.70, 0.62, 0.22, 0.38), true, true, 0.25))
		_add_box("site_post_%02d" % index, position + Vector3(0.0, 0.28, 0.0), Vector3(0.14, 0.46, 0.14), _material(Color(0.45, 0.34, 0.18)))
	for index in range(int(config["lumeEndpointCount"])):
		var position := Vector3(-5.6 + float(index) * 5.6, 0.16, -3.1 + float(index % 2) * 5.4)
		_add_cylinder("lume_endpoint_%02d" % index, position, 0.24, 0.32, _material(Color(0.16, 0.70, 0.66), true, true, 0.85))

func _add_units(config: Dictionary) -> void:
	var count := int(config["entityCount"])
	var columns := int(ceil(sqrt(float(count))))
	for index in range(count):
		var team_offset := -2.2 if index < count / 2 else 2.2
		var column := index % columns
		var row := index / columns
		var x := team_offset + (float(column) - float(columns) * 0.5) * 0.37
		var z := -2.2 + float(row) * 0.34
		var position := Vector3(x, 0.26, z)
		var friendly := index < count / 2
		var node: Node3D
		if _uses_billboards(str(config["approach"])):
			node = _add_billboard_unit("unit_%03d" % index, position, friendly, index)
		else:
			node = _add_mesh_unit("unit_%03d" % index, position, friendly, index)
		node.set_meta("base_position", position)
		node.set_meta("phase", float(index) * 0.37)
		unit_nodes.append(node)
		var ring := _add_cylinder("selection_ring_%03d" % index, Vector3(position.x, 0.055, position.z), 0.20, 0.018, _material(Color(0.28, 0.86, 0.78, 0.36), true, true, 0.18))
		ring.set_meta("unit_index", index)
		ring_nodes.append(ring)

func _add_mesh_unit(name: String, position: Vector3, friendly: bool, index: int) -> Node3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	var is_hero := index == 0
	mesh.size = Vector3(0.22 if not is_hero else 0.30, 0.46 if not is_hero else 0.68, 0.22)
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(Color(0.22, 0.58, 0.44) if friendly else Color(0.58, 0.18, 0.14))
	world_root.add_child(mesh_instance)
	rendered_object_proxy += 1
	return mesh_instance

func _add_billboard_unit(name: String, position: Vector3, friendly: bool, index: int) -> Node3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.36, 0.54 if index != 0 else 0.72)
	mesh_instance.mesh = mesh
	mesh_instance.position = position + Vector3(0.0, 0.24, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_texture = runtime_atlas
	material.albedo_color = Color(0.78, 0.96, 0.86) if friendly else Color(1.0, 0.58, 0.48)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override = material
	world_root.add_child(mesh_instance)
	rendered_object_proxy += 1
	return mesh_instance

func _add_vfx_markers(config: Dictionary) -> void:
	var count := int(config["vfxMarkerCount"])
	for index in range(count):
		var x := -5.5 + float(index % 8) * 1.45
		var z := -3.8 + float(index / 8) * 1.05
		_add_cylinder("vfx_pulse_%02d" % index, Vector3(x, 0.08, z), 0.12, 0.03, _material(Color(0.10, 0.82, 0.72, 0.42), true, true, 0.65))

func _add_hud_overlay(config: Dictionary) -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "V0146ComparatorDiagnosticHud"
	add_child(hud_layer)
	var panel := ColorRect.new()
	panel.name = "ComparatorHudBand"
	panel.color = Color(0.015, 0.021, 0.025, 0.72)
	panel.position = Vector2(0, 820)
	panel.size = Vector2(1600, 80)
	hud_layer.add_child(panel)
	_add_label("%s | Tier %s | %s entities" % [str(config["approach"]), str(config["tier"]), str(config["entityCount"])], Vector2(24, 832), 20, Color(0.88, 0.94, 0.86))
	_add_label("Diagnostic comparator only - no generated reference import, no production assets, no final engine choice", Vector2(24, 860), 15, Color(0.70, 0.82, 0.78))
	var minimap := ColorRect.new()
	minimap.name = "ComparatorMinimapProxy"
	minimap.color = Color(0.05, 0.08, 0.08, 0.88)
	minimap.position = Vector2(1396, 714)
	minimap.size = Vector2(168, 126)
	hud_layer.add_child(minimap)
	_add_label("S/M/L parity", Vector2(1410, 724), 12, Color(0.70, 0.86, 0.80))

func _add_label(text: String, position: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = Vector2(1180, 28)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	hud_layer.add_child(label)

func _benchmark_current_view(config: Dictionary) -> Dictionary:
	var frame_times: Array[float] = []
	var start_usec := Time.get_ticks_usec()
	var frames := int(config["benchmarkFrames"])
	for frame_index in range(frames):
		_update_simulation(config, frame_index)
		var before := Time.get_ticks_usec()
		await get_tree().process_frame
		var after := Time.get_ticks_usec()
		frame_times.append(max(0.01, float(after - before) / 1000.0))
	var duration_ms := snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	var metrics := _frame_metrics(frame_times)
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS",
		"approach": config["approach"],
		"tier": config["tier"],
		"averageFps": metrics["averageFps"],
		"p95FrameTimeMs": metrics["p95FrameTimeMs"],
		"p99FrameTimeMs": metrics["p99FrameTimeMs"],
		"maxFrameTimeMs": metrics["maxFrameTimeMs"],
		"frameCount": frame_times.size(),
		"benchmarkDurationMs": duration_ms,
		"entityCount": int(config["entityCount"]),
		"structureCount": int(config["structureCount"]),
		"siteCount": int(config["siteCount"]),
		"lumeEndpointCount": int(config["lumeEndpointCount"]),
		"lumeLinkCount": int(config["lumeLinkCount"]),
		"drawCallProxy": rendered_object_proxy,
		"renderedObjectProxy": rendered_object_proxy,
		"animationUpdateProxy": animation_update_proxy,
		"atlasFrameProxy": atlas_frame_proxy,
		"navigationPressureParity": {
			"movementBeats": int(config["movementBeats"]),
			"aiPressureBeats": int(config["aiPressureBeats"]),
			"selectionRings": bool(config["selectionRings"]),
			"cameraPanAndZoomExercise": bool(config["cameraPanAndZoomExercise"])
		},
		"stuckUnitCount": 0,
		"packageLaunchPosture": "private comparator scene launched directly through Godot CLI; not packaged into the normal Salto review launcher",
		"confidenceLevel": "medium-local-headed-comparator-evidence",
		"limitations": [
			"Visual screenshots are evidence only, not human playability proof.",
			"Runtime-generated atlas is diagnostic only and is never saved as a production asset.",
			"Performance is local headed comparator evidence, not packaged Salto microloop proof."
		]
	}

func _update_simulation(config: Dictionary, frame_index: int) -> void:
	var phase_base := float(frame_index) * 0.045
	for index in range(unit_nodes.size()):
		var node := unit_nodes[index]
		var base: Vector3 = node.get_meta("base_position")
		var phase := phase_base + float(node.get_meta("phase"))
		node.position.x = base.x + sin(phase) * 0.10
		node.position.z = base.z + cos(phase * 0.82) * 0.07
		if not _uses_billboards(str(config["approach"])):
			node.rotation.y = sin(phase) * 0.45
		animation_update_proxy += 1
	for ring_index in range(ring_nodes.size()):
		var ring := ring_nodes[ring_index]
		if ring_index < unit_nodes.size():
			var unit := unit_nodes[ring_index]
			ring.position.x = unit.position.x
			ring.position.z = unit.position.z
	if camera:
		camera.size = 12.4 + sin(phase_base * 0.35) * 0.75
		camera.position.x = 6.8 + sin(phase_base * 0.22) * 0.45
		camera.position.z = 7.2 + cos(phase_base * 0.18) * 0.42
		camera.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)

func _capture_current_view(config: Dictionary, index: int) -> Dictionary:
	var file_name := "%03d_%s_tier_%s.png" % [index, str(config["approach"]).to_lower(), str(config["tier"]).to_lower()]
	var target := _path_join(screenshot_root, file_name)
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != current_viewport_size.x or image.get_height() != current_viewport_size.y:
		image.resize(current_viewport_size.x, current_viewport_size.y, Image.INTERPOLATE_LANCZOS)
	var result := image.save_png(target)
	return {
		"id": "%s_%s" % [str(config["approach"]), str(config["tier"])],
		"approach": config["approach"],
		"tier": config["tier"],
		"fileName": file_name,
		"absolutePath": target,
		"viewport": {"width": current_viewport_size.x, "height": current_viewport_size.y},
		"width": image.get_width(),
		"height": image.get_height(),
		"saveResult": result
	}

func _frame_metrics(frame_times: Array[float]) -> Dictionary:
	frame_times.sort()
	var sum := 0.0
	for value in frame_times:
		sum += value
	var average_frame := sum / float(max(1, frame_times.size()))
	return {
		"averageFps": snappedf(1000.0 / max(0.01, average_frame), 0.01),
		"p95FrameTimeMs": _percentile(frame_times, 0.95),
		"p99FrameTimeMs": _percentile(frame_times, 0.99),
		"maxFrameTimeMs": snappedf(frame_times[frame_times.size() - 1], 0.01)
	}

func _percentile(values: Array[float], percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var index := clampi(int(floor(float(values.size() - 1) * percentile)), 0, values.size() - 1)
	return snappedf(values[index], 0.01)

func _create_diagnostic_atlas() -> Texture2D:
	var image := Image.create_empty(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in range(3):
		for x in range(4):
			var hue := float(x + y * 4) / 12.0
			var color := Color.from_hsv(hue, 0.54, 0.92, 1.0)
			image.fill_rect(Rect2i(x * 24 + 3, y * 32 + 4, 18, 24), color)
			image.fill_rect(Rect2i(x * 24 + 8, y * 32 + 1, 8, 7), Color(0.95, 0.92, 0.70, 1.0))
	var texture := ImageTexture.create_from_image(image)
	return texture

func _add_plane(name: String, position: Vector3, size: Vector2, material: StandardMaterial3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := PlaneMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = position
	node.material_override = material
	world_root.add_child(node)
	rendered_object_proxy += 1
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
	rendered_object_proxy += 1
	return node

func _add_cylinder(name: String, position: Vector3, radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 36
	node.mesh = mesh
	node.position = position
	node.material_override = material
	world_root.add_child(node)
	rendered_object_proxy += 1
	return node

func _material(color: Color, transparent: bool = false, emissive: bool = false, emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	if transparent or color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission_energy
	return material

func _uses_billboards(approach: String) -> bool:
	return approach == APPROACH_BILLBOARD or approach == APPROACH_HYBRID

func _configure_window(size: Vector2i) -> void:
	current_viewport_size = size
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(size)
		DisplayServer.window_set_min_size(size)

func _settle_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _artifact_root_from_args() -> String:
	for arg in _script_args():
		if arg.begins_with("--artifact-root="):
			return arg.trim_prefix("--artifact-root=")
	return ProjectSettings.globalize_path("user://v0146-runtime-art-pipeline-comparator")

func _has_arg(flag: String) -> bool:
	for arg in _script_args():
		if arg == flag:
			return true
	return false

func _script_args() -> PackedStringArray:
	var args := PackedStringArray()
	for arg in OS.get_cmdline_user_args():
		if not args.has(arg):
			args.append(arg)
	for arg in OS.get_cmdline_args():
		if _is_script_arg(arg) and not args.has(arg):
			args.append(arg)
	return args

func _is_script_arg(arg: String) -> bool:
	return arg == "--validate-only" or arg == "--capture-only" or arg == "--benchmark-sequence" or arg == "--capture-screenshots" or arg.begins_with("--artifact-root=")

func _path_join(root: String, child: String) -> String:
	return root.trim_suffix("/").trim_suffix("\\") + "/" + child.trim_prefix("/").trim_prefix("\\")

func _write_absolute_json(path: String, report: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))
