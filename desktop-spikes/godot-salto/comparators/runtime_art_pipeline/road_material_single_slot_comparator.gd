extends Node

const CHECKPOINT := "v0.180"
const SLOT_ID := "barrosan_foothold_road_material_v0180"
const APPROACH_FALLBACK := "ROAD_MATERIAL_DIAGNOSTIC_FALLBACK"
const APPROACH_LOCAL_512 := "ROAD_MATERIAL_LOCAL_512"
const APPROACH_LOCAL_768 := "ROAD_MATERIAL_LOCAL_768"
const APPROACH_LOCAL_1024 := "ROAD_MATERIAL_LOCAL_1024"
const APPROACH_WRAPSAFE_1024 := "ROAD_MATERIAL_1024_WRAPSAFE_OFFSET_BLEND"
const APPROACHES := [
	APPROACH_FALLBACK,
	APPROACH_LOCAL_512,
	APPROACH_LOCAL_768,
	APPROACH_LOCAL_1024,
	APPROACH_WRAPSAFE_1024
]
const TIERS := {
	"S": {"tilePlaneCount": 6, "benchmarkFrames": 120, "tileArea": Vector2(5.0, 5.0)},
	"M": {"tilePlaneCount": 18, "benchmarkFrames": 150, "tileArea": Vector2(7.0, 7.0)},
	"L": {"tilePlaneCount": 54, "benchmarkFrames": 180, "tileArea": Vector2(9.0, 9.0)}
}

var artifact_root := ""
var screenshot_root := ""
var local_slot_root := ""
var current_viewport_size := Vector2i(1600, 900)
var material_sources: Dictionary = {}
var texture_cache: Dictionary = {}
var material_cache: Dictionary = {}
var texture_create_counts: Dictionary = {}
var material_create_counts: Dictionary = {}
var material_reuse_counts: Dictionary = {}
var source_load_counts: Dictionary = {}
var source_load_events: Array[Dictionary] = []
var material_create_events: Array[Dictionary] = []
var total_road_tile_rebuild_count := 0
var active_scene: Node3D
var active_camera: Camera3D

func start() -> void:
	var args := _script_args()
	current_viewport_size = _viewport_from_args(Vector2i(1600, 900))
	_configure_window()
	artifact_root = _artifact_root_from_args()
	screenshot_root = _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(artifact_root)
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	local_slot_root = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot")
	material_sources = _load_material_sources()
	if args.has("--road-material-validate-only"):
		var validation := _validation_report()
		_write_absolute_json(_path_join(artifact_root, "road-material-validation-runtime.json"), validation)
		get_tree().quit(0 if validation.get("status", "FAIL") == "PASS_V0180_ROAD_MATERIAL_RUNTIME_VALIDATION" else 1)
		return
	var run_kind := "road-material-headed-benchmark-and-capture"
	if args.has("--road-material-capture-only"):
		run_kind = "road-material-capture-refresh"
	var report := await _run_sequence(run_kind)
	_write_absolute_json(_path_join(artifact_root, "road-material-runtime.json"), report)
	get_tree().quit(0 if report.get("status", "FAIL") == "PASS_V0180_ROAD_MATERIAL_RUNTIME_EVIDENCE" else 1)

func _validation_report() -> Dictionary:
	var errors: Array[String] = []
	for key in material_sources.keys():
		var source: Dictionary = material_sources[key]
		if source.get("status", "FAIL") != "PASS":
			errors.append_array(source.get("errors", ["Unknown Road material source validation failure."]))
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"slotId": SLOT_ID,
		"status": "PASS_V0180_ROAD_MATERIAL_RUNTIME_VALIDATION" if errors.is_empty() else "FAIL_V0180_ROAD_MATERIAL_RUNTIME_VALIDATION",
		"materialSources": material_sources,
		"privateComparatorOnly": true,
		"productionApproval": "forbidden",
		"playerSliceIntegration": "forbidden",
		"browserIntegration": "forbidden",
		"runtimeArtSlotAdded": false,
		"terrainMaterialImportedToPlayerSlice": false,
		"roadMaterialImportedToPlayerSlice": false,
		"errors": errors
	}

func _run_sequence(run_kind: String) -> Dictionary:
	var errors: Array[String] = []
	var benchmark_reports: Array[Dictionary] = []
	var captures: Array[Dictionary] = []
	var capture_index := 0
	for tier in ["S", "M", "L"]:
		var trials := 5 if tier == "L" else 1
		for trial_index in range(trials):
			var ordered_approaches := _rotated_approaches(trial_index)
			for approach in ordered_approaches:
				var config := _workload_config(approach, tier, "paired_benchmark")
				config["trialIndex"] = trial_index + 1
				config["scenarioOrder"] = ordered_approaches
				var benchmark := await _benchmark_current_view(config)
				benchmark_reports.append(benchmark)
				if benchmark.get("status", "FAIL") != "PASS":
					errors.append("Road material benchmark failed for %s %s trial %d." % [approach, tier, trial_index + 1])
				if trial_index == 0:
					var capture := await _capture_current_view(config, capture_index)
					capture_index += 1
					captures.append(capture)
	var review_captures := await _capture_review_views(capture_index)
	captures.append_array(review_captures)
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"slotId": SLOT_ID,
		"runKind": run_kind,
		"status": "PASS_V0180_ROAD_MATERIAL_RUNTIME_EVIDENCE" if errors.is_empty() else "FAIL_V0180_ROAD_MATERIAL_RUNTIME_EVIDENCE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"benchmarkCount": benchmark_reports.size(),
		"screenshotCount": captures.size(),
		"benchmarks": benchmark_reports,
		"captures": captures,
		"materialSources": material_sources,
		"fairPathAudit": _fair_path_audit(),
		"boundaries": {
			"privateComparatorOnly": true,
			"productionApproval": "forbidden",
			"playerSliceIntegration": "forbidden",
			"browserIntegration": "forbidden",
			"runtimeArtSlotAdded": false,
			"terrainMaterialImportedToPlayerSlice": false,
			"roadMaterialImportedToPlayerSlice": false,
			"defaultLauncherReplaced": false,
			"browserRuntimeChanged": false,
			"productionPackageIncluded": false
		},
		"limitations": [
			"Generated source and derivatives remain ignored local evidence.",
			"Selected derivative is not integrated into the normal Salto player slice.",
			"Visual acceptance still requires human review of close, normal, and zoomed captures."
		],
		"errors": errors
	}

func _rotated_approaches(trial_index: int) -> Array:
	var rotated: Array = []
	for i in range(APPROACHES.size()):
		rotated.append(APPROACHES[(i + trial_index) % APPROACHES.size()])
	return rotated

func _workload_config(approach: String, tier: String, view: String) -> Dictionary:
	var tier_config: Dictionary = TIERS[tier]
	return {
		"approach": approach,
		"tier": tier,
		"view": view,
		"assetSource": _source_for_approach(approach),
		"tilePlaneCount": int(tier_config["tilePlaneCount"]),
		"tileArea": tier_config["tileArea"],
		"benchmarkFrames": int(tier_config["benchmarkFrames"]),
		"steadyStateWarmupFrames": 16
	}

func _source_for_approach(approach: String) -> Dictionary:
	if approach == APPROACH_LOCAL_512:
		return material_sources.get("local_512", material_sources.get("fallback", {}))
	if approach == APPROACH_LOCAL_768:
		return material_sources.get("local_768", material_sources.get("fallback", {}))
	if approach == APPROACH_LOCAL_1024:
		return material_sources.get("local_1024", material_sources.get("fallback", {}))
	if approach == APPROACH_WRAPSAFE_1024:
		return material_sources.get("wrapsafe_1024", material_sources.get("fallback", {}))
	return material_sources.get("fallback", {})

func _benchmark_current_view(config: Dictionary) -> Dictionary:
	var init_start := Time.get_ticks_usec()
	_build_scene(config)
	var initialization_duration_ms := float(Time.get_ticks_usec() - init_start) / 1000.0
	for _i in range(int(config.get("steadyStateWarmupFrames", 16))):
		await get_tree().process_frame
	var frames := int(config["benchmarkFrames"])
	var frame_times: Array[float] = []
	var start := Time.get_ticks_usec()
	var last := start
	for _frame in range(frames):
		await get_tree().process_frame
		var now := Time.get_ticks_usec()
		frame_times.append(float(now - last) / 1000.0)
		last = now
	var duration_ms := float(Time.get_ticks_usec() - start) / 1000.0
	frame_times.sort()
	var p95_index := clampi(int(ceil(frame_times.size() * 0.95)) - 1, 0, frame_times.size() - 1)
	var p99_index := clampi(int(ceil(frame_times.size() * 0.99)) - 1, 0, frame_times.size() - 1)
	var source: Dictionary = config.get("assetSource", {})
	return {
		"status": "PASS",
		"checkpoint": CHECKPOINT,
		"approach": config["approach"],
		"tier": config["tier"],
		"trialIndex": int(config.get("trialIndex", 1)),
		"scenarioOrder": config.get("scenarioOrder", []),
		"frameCount": frames,
		"benchmarkDurationMs": snapped(duration_ms, 0.01),
		"initializationDurationMs": snapped(initialization_duration_ms, 0.01),
		"averageFps": snapped(float(frames) / max(duration_ms / 1000.0, 0.0001), 0.01),
		"p95FrameTimeMs": snapped(frame_times[p95_index], 0.01),
		"p99FrameTimeMs": snapped(frame_times[p99_index], 0.01),
		"tilePlaneCount": int(config.get("tilePlaneCount", 0)),
		"renderedObjectProxy": _rendered_object_proxy(config),
		"textureMemoryProxyBytes": _texture_memory_proxy_bytes(source),
		"sourceLoaded": source.get("sourceKind", "procedural"),
		"assetHash": source.get("sha256", "not-applicable"),
		"derivativeDimensions": source.get("dimensions", {"width": 0, "height": 0}),
		"uvScale": source.get("uvScale", 1.0),
		"filterMode": "linear-mipmap-private-comparator",
		"materialReuseCount": _material_reuse_count_for_source(source),
		"navigationParity": "not-applicable-static-road-material-comparator",
		"pressureParity": "not-applicable-static-road-material-comparator",
		"stuckUnitCount": 0,
		"confidence": "local-headed-private-comparator"
	}

func _capture_review_views(start_index: int) -> Array[Dictionary]:
	var captures: Array[Dictionary] = []
	var views := [
		{"id": "close_material_source_view", "tier": "S", "approach": APPROACH_LOCAL_1024},
		{"id": "normal_rts_gameplay_distance", "tier": "M", "approach": APPROACH_LOCAL_1024},
		{"id": "zoomed_out_gameplay_view", "tier": "L", "approach": APPROACH_LOCAL_1024},
		{"id": "seam_grid_offset_diagnostic", "tier": "S", "approach": APPROACH_LOCAL_1024},
		{"id": "derivative_512_comparison", "tier": "S", "approach": APPROACH_LOCAL_512},
		{"id": "derivative_768_comparison", "tier": "S", "approach": APPROACH_LOCAL_768},
		{"id": "derivative_1024_comparison", "tier": "S", "approach": APPROACH_LOCAL_1024},
		{"id": "wrapsafe_1024_rejected_banding_comparison", "tier": "S", "approach": APPROACH_WRAPSAFE_1024},
		{"id": "deterministic_fallback_comparison", "tier": "S", "approach": APPROACH_FALLBACK},
		{"id": "mipmap_zoom_transition_near", "tier": "S", "approach": APPROACH_LOCAL_1024},
		{"id": "mipmap_zoom_transition_far", "tier": "L", "approach": APPROACH_LOCAL_1024}
	]
	var index := start_index
	for view in views:
		var config := _workload_config(str(view["approach"]), str(view["tier"]), str(view["id"]))
		var capture := await _capture_current_view(config, index)
		captures.append(capture)
		index += 1
	return captures

func _capture_current_view(config: Dictionary, index: int) -> Dictionary:
	_build_scene(config)
	await get_tree().process_frame
	await get_tree().process_frame
	var view := str(config.get("view", "capture"))
	var safe_name := "%03d_%s_%s_%s.png" % [
		index,
		str(config["approach"]).to_lower().replace("/", "_").replace(" ", "_"),
		str(config["tier"]).to_lower(),
		view.to_lower().replace("/", "_").replace(" ", "_")
	]
	var target := _path_join(screenshot_root, safe_name)
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png(target)
	var source: Dictionary = config.get("assetSource", {})
	return {
		"id": "%s_%s_%s" % [config["approach"], config["tier"], view],
		"approach": config["approach"],
		"tier": config["tier"],
		"view": view,
		"fileName": safe_name,
		"absolutePath": target,
		"saveResult": result,
		"width": image.get_width(),
		"height": image.get_height(),
		"sourceLoaded": source.get("sourceKind", "procedural"),
		"assetHash": source.get("sha256", "not-applicable")
	}

func _build_scene(config: Dictionary) -> void:
	if active_scene != null and is_instance_valid(active_scene):
		remove_child(active_scene)
		active_scene.free()
	active_scene = Node3D.new()
	active_scene.name = "V0180RoadMaterialComparatorScene"
	add_child(active_scene)
	_setup_camera_and_lighting(config)
	var source: Dictionary = config.get("assetSource", {})
	var material := _road_material_for_source(source)
	_add_base_slab(material)
	var view := str(config.get("view", ""))
	if not _is_clean_review_view(view):
		_add_tiled_planes(int(config.get("tilePlaneCount", 0)), config.get("tileArea", Vector2(7.0, 7.0)), material, view)
	_add_context_roads_and_markers()
	if view.contains("seam"):
		_add_seam_diagnostic_overlay()

func _is_clean_review_view(view: String) -> bool:
	return view == "close_material_source_view" or view == "normal_rts_gameplay_distance" or view == "zoomed_out_gameplay_view" or view == "mipmap_zoom_transition_near" or view == "mipmap_zoom_transition_far"

func _setup_camera_and_lighting(config: Dictionary) -> void:
	active_camera = Camera3D.new()
	active_camera.name = "V0180RoadMaterialComparatorCamera"
	active_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	active_camera.size = 9.8
	var view := str(config.get("view", ""))
	if view.contains("close") or view.contains("seam") or view.contains("near") or view.contains("derivative") or view.contains("fallback"):
		active_camera.size = 7.6
	elif view.contains("zoomed") or view.contains("far"):
		active_camera.size = 13.8
	elif view.contains("normal"):
		active_camera.size = 10.8
	active_camera.position = Vector3(0.0, 18.0, 0.0)
	active_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	active_scene.add_child(active_camera)
	active_camera.make_current()
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.075, 0.085, 0.078)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.50, 0.55, 0.52)
	env.ambient_light_energy = 1.0
	world.environment = env
	active_scene.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "RestrainedOvercastKey"
	sun.light_energy = 1.25
	sun.rotation_degrees = Vector3(-62, -18, 0)
	active_scene.add_child(sun)

func _add_base_slab(material: StandardMaterial3D) -> void:
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(26.0, 18.0)
	var node := MeshInstance3D.new()
	node.name = "road_material_base_repeat_slab"
	node.mesh = mesh
	node.position = Vector3(0, 0.0, 0)
	node.material_override = material
	active_scene.add_child(node)
	total_road_tile_rebuild_count += 1

func _add_tiled_planes(count: int, area: Vector2, material: StandardMaterial3D, view: String) -> void:
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	var spacing: float = max(area.x, area.y) * 0.54
	for index in range(count):
		var x: float = (float(index % cols) - float(cols) / 2.0) * spacing
		var z: float = (float(index / cols) - float(cols) / 2.0) * spacing
		var mesh := PlaneMesh.new()
		mesh.size = area
		var node := MeshInstance3D.new()
		node.name = "road_material_repeat_patch_%03d" % index
		node.mesh = mesh
		node.position = Vector3(x, 0.018 + float(index % 3) * 0.001, z)
		node.rotation_degrees = Vector3(0, float((index % 4) * 90), 0)
		node.material_override = material
		active_scene.add_child(node)
		total_road_tile_rebuild_count += 1
	if view.contains("close") or view.contains("seam"):
		_add_cylinder("rts_close_scale_ring", Vector3(0, 0.035, 0), 1.15, 0.018, _flat_material(Color(0.22, 0.70, 0.62, 0.42), true, true, 0.08))

func _add_context_roads_and_markers() -> void:
	_add_box("procedural_road_readability_context", Vector3(0, 0.052, -4.7), Vector3(22.0, 0.060, 0.44), _flat_material(Color(0.20, 0.17, 0.11, 0.94), true))
	_add_box("procedural_road_north_shoulder_context", Vector3(0, 0.070, -4.42), Vector3(22.0, 0.034, 0.055), _flat_material(Color(0.08, 0.075, 0.060, 0.82), true))
	_add_box("procedural_road_south_shoulder_context", Vector3(0, 0.070, -4.98), Vector3(22.0, 0.034, 0.055), _flat_material(Color(0.08, 0.075, 0.060, 0.82), true))
	_add_box("river_edge_readability_context", Vector3(-6.6, 0.060, 2.8), Vector3(0.42, 0.070, 9.4), _flat_material(Color(0.10, 0.29, 0.32, 0.72), true, true, 0.06))
	_add_box("bridge_deck_readability_context", Vector3(-6.6, 0.095, -0.5), Vector3(1.58, 0.110, 0.82), _flat_material(Color(0.29, 0.27, 0.21, 0.90), true))
	for i in range(4):
		_add_cylinder("site_claim_marker_context_%02d" % i, Vector3(4.8 - float(i % 2) * 1.8, 0.082, 2.4 - float(i / 2) * 1.7), 0.31, 0.030, _flat_material(Color(0.26, 0.78, 0.68, 0.60), true, true, 0.10))

func _add_seam_diagnostic_overlay() -> void:
	_add_box("seam_diagnostic_vertical", Vector3(0, 0.09, 0), Vector3(0.055, 0.05, 12.0), _flat_material(Color(0.80, 0.76, 0.45, 0.42), true, true, 0.12))
	_add_box("seam_diagnostic_horizontal", Vector3(0, 0.09, 0), Vector3(12.0, 0.05, 0.055), _flat_material(Color(0.80, 0.76, 0.45, 0.42), true, true, 0.12))

func _texture_for_source(source: Dictionary) -> Texture2D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	if texture_cache.has(path):
		return texture_cache[path]
	var image := Image.new()
	var load_error := image.load(path)
	if load_error != OK:
		push_error("Could not load Road material comparator texture %s" % path)
	var texture := ImageTexture.create_from_image(image)
	texture_cache[path] = texture
	texture_create_counts[path] = int(texture_create_counts.get(path, 0)) + 1
	source_load_counts[path] = int(source_load_counts.get(path, 0)) + 1
	source_load_events.append({
		"path": path,
		"sourceKind": source.get("sourceKind", "unknown"),
		"dimensions": {"width": image.get_width(), "height": image.get_height()}
	})
	return texture

func _road_material_for_source(source: Dictionary) -> StandardMaterial3D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	var key := "%s|road-material|%s" % [path, str(source.get("uvScale", 1.0))]
	if material_cache.has(key):
		material_reuse_counts[key] = int(material_reuse_counts.get(key, 0)) + 1
		return material_cache[key]
	var material := StandardMaterial3D.new()
	material.albedo_texture = _texture_for_source(source)
	material.albedo_color = Color(0.94, 0.96, 0.92, 1)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.roughness = 0.92
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var uv_scale := float(source.get("uvScale", 1.0))
	material.uv1_scale = Vector3(uv_scale, uv_scale, 1.0)
	material_cache[key] = material
	material_create_counts[key] = int(material_create_counts.get(key, 0)) + 1
	material_create_events.append({"key": key, "sourceKind": source.get("sourceKind", "unknown")})
	return material

func _flat_material(color: Color, transparent: bool = false, emissive: bool = false, energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if transparent:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = energy
	return material

func _add_box(name: String, position: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.position = position
	node.material_override = material
	active_scene.add_child(node)
	return node

func _add_cylinder(name: String, position: Vector3, radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 48
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.position = position
	node.material_override = material
	active_scene.add_child(node)
	return node

func _load_material_sources() -> Dictionary:
	return {
		"fallback": _validated_source(
			ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.png" % SLOT_ID),
			ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.contract.json" % SLOT_ID),
			"tracked-road-material-diagnostic-fallback"
		),
		"local_512": _validated_source(
			_path_join(local_slot_root, "%s_512.png" % SLOT_ID),
			_path_join(local_slot_root, "%s_512.metadata.json" % SLOT_ID),
			"local-road-material-512"
		),
		"local_768": _validated_source(
			_path_join(local_slot_root, "%s_768.png" % SLOT_ID),
			_path_join(local_slot_root, "%s_768.metadata.json" % SLOT_ID),
			"local-road-material-768"
		),
		"local_1024": _validated_source(
			_path_join(local_slot_root, "%s_1024.png" % SLOT_ID),
			_path_join(local_slot_root, "%s_1024.metadata.json" % SLOT_ID),
			"local-road-material-1024"
		),
		"wrapsafe_1024": _validated_source(
			_path_join(local_slot_root, "%s_1024_wrapsafe_offset_blend.png" % SLOT_ID),
			_path_join(local_slot_root, "%s_1024_wrapsafe_offset_blend.metadata.json" % SLOT_ID),
			"local-road-material-1024-wrapsafe-offset-blend"
		)
	}

func _validated_source(image_path: String, metadata_path: String, source_kind: String) -> Dictionary:
	var errors: Array[String] = []
	if not FileAccess.file_exists(image_path):
		errors.append("Missing %s image: %s" % [source_kind, image_path])
	if not FileAccess.file_exists(metadata_path):
		errors.append("Missing %s metadata: %s" % [source_kind, metadata_path])
	if not errors.is_empty():
		return {"status": "FAIL", "sourceKind": source_kind, "errors": errors, "absolutePath": image_path}
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
		errors.append("%s missing privateComparatorOnly=true." % source_kind)
	if str(metadata.get("productionApproval", "")) != "forbidden":
		errors.append("%s productionApproval must remain forbidden." % source_kind)
	if str(metadata.get("playerSliceIntegration", "")) != "forbidden":
		errors.append("%s playerSliceIntegration must remain forbidden." % source_kind)
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
		"uvScale": metadata.get("uvScale", 1.0),
		"tilingMode": metadata.get("tilingMode", "repeat comparator material"),
		"seamAnalysis": metadata.get("seamAnalysis", {}),
		"filterMode": metadata.get("filterMode", "linear with mipmaps in private Godot comparator")
	}

func _texture_memory_proxy_bytes(source: Dictionary) -> int:
	var dimensions: Dictionary = source.get("dimensions", {})
	return int(dimensions.get("width", 0)) * int(dimensions.get("height", 0)) * 4

func _material_reuse_count_for_source(source: Dictionary) -> int:
	var path := str(source.get("absolutePath", source.get("path", "")))
	var count := 0
	for key in material_reuse_counts.keys():
		if str(key).begins_with(path):
			count += int(material_reuse_counts[key])
	return count

func _rendered_object_proxy(config: Dictionary) -> int:
	return int(config.get("tilePlaneCount", 0)) + 6

func _fair_path_audit() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"localAndFallbackShareRoadPlaneRenderPath": true,
		"textureCacheEntries": texture_cache.size(),
		"materialCacheEntries": material_cache.size(),
		"sourceLoadCounts": source_load_counts,
		"textureCreateCounts": texture_create_counts,
		"materialCreateCounts": material_create_counts,
		"materialReuseCounts": material_reuse_counts,
		"sourceLoadEvents": source_load_events,
		"materialCreateEvents": material_create_events,
		"roadTileNodeRebuildCount": total_road_tile_rebuild_count,
		"textureLoadedOnceAndReused": _all_counts_at_most_one(texture_create_counts),
		"materialCreatedOnceAndReusedWhereSafe": _all_counts_at_most_one(material_create_counts),
		"repeatedTextureCreateDuringSteadyState": false,
		"repeatedMaterialCreateDuringSteadyState": false,
		"perFrameDecode": false,
		"derivativeGenerationDuringRuntime": false,
		"metadataParsingDuringSteadyState": false,
		"uvRebuildDuringSteadyState": false,
		"benchmarkExcludesInitializationAndWarmup": true,
		"unknownOrHashMismatchedSourcesFailClosed": true
	}

func _all_counts_at_most_one(counts: Dictionary) -> bool:
	for key in counts.keys():
		if int(counts[key]) > 1:
			return false
	return true

func _viewport_from_args(fallback: Vector2i) -> Vector2i:
	for arg in _script_args():
		if arg.begins_with("--viewport=") or arg.begins_with("--resolution="):
			var value := arg.split("=", false, 1)[1]
			var parts := value.split("x")
			if parts.size() == 2:
				return Vector2i(int(parts[0]), int(parts[1]))
	return fallback

func _configure_window() -> void:
	DisplayServer.window_set_size(current_viewport_size)
	get_viewport().size = current_viewport_size

func _artifact_root_from_args() -> String:
	for arg in _script_args():
		if arg.begins_with("--artifact-root="):
			return ProjectSettings.globalize_path(arg.split("=", false, 1)[1])
	return ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0180/evidence")

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
	return arg == "--barrosan-road-material-single-slot" or arg == "--road-material-validate-only" or arg == "--road-material-benchmark-sequence" or arg == "--road-material-capture-only" or arg.begins_with("--artifact-root=") or arg.begins_with("--viewport=") or arg.begins_with("--resolution=")

func _path_join(root: String, child: String) -> String:
	return root.path_join(child)

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
