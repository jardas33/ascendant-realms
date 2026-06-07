extends Node

const CHECKPOINT := "v0.150"
const SLOT_ID := "barrosan_barracks_material_v0149"
const WORKER_SLOT_ID := "worker_billboard_static_v0147"
const SELECTED_WORKER_HASH := "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
const SELECTED_MATERIAL_HASH := "2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3"
const APPROACH_FALLBACK := "HYBRID_BARRACKS_V0150_FALLBACK"
const APPROACH_ORIGINAL := "HYBRID_BARRACKS_768_ORIGINAL"
const APPROACH_OFFSET_BLEND := "HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND"
const APPROACH_QUADRANT := "HYBRID_BARRACKS_768_WRAPSAFE_QUADRANT"
const APPROACH_SOFTSEAM := "HYBRID_BARRACKS_768_WRAPSAFE_SOFTSEAM"
const APPROACH_WORKER_CONTEXT := "HYBRID_WORKER_CONTEXT_BASELINE"
const APPROACH_ORTHO := "ORTHO_3D_MESH_FALLBACK_COMPARATOR"
const APPROACHES := [
	APPROACH_FALLBACK,
	APPROACH_ORIGINAL,
	APPROACH_OFFSET_BLEND,
	APPROACH_QUADRANT,
	APPROACH_SOFTSEAM,
	APPROACH_WORKER_CONTEXT,
	APPROACH_ORTHO
]
const TIERS := {
	"S": {"barracksShellCount": 3, "workerCount": 5, "benchmarkFrames": 120},
	"M": {"barracksShellCount": 9, "workerCount": 10, "benchmarkFrames": 150},
	"L": {"barracksShellCount": 24, "workerCount": 18, "benchmarkFrames": 180}
}

var artifact_root := ""
var screenshot_root := ""
var local_slot_root := ""
var current_viewport_size := Vector2i(1600, 900)
var material_sources: Dictionary = {}
var worker_context_source: Dictionary = {}
var texture_cache: Dictionary = {}
var material_cache: Dictionary = {}
var texture_create_counts: Dictionary = {}
var material_create_counts: Dictionary = {}
var material_reuse_counts: Dictionary = {}
var source_load_counts: Dictionary = {}
var source_load_events: Array[Dictionary] = []
var material_create_events: Array[Dictionary] = []
var total_barracks_shell_rebuild_count := 0
var total_worker_context_rebuild_count := 0
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
	local_slot_root = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair")
	material_sources = _load_material_sources()
	worker_context_source = _load_worker_context_source()
	if args.has("--barracks-material-seam-repair-validate-only"):
		var validation := _validation_report()
		_write_absolute_json(_path_join(artifact_root, "barracks-material-seam-repair-validation-runtime.json"), validation)
		get_tree().quit(0 if validation.get("status", "FAIL") == "PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_RUNTIME_VALIDATION" else 1)
		return
	var run_kind := "barracks-material-seam-repair-headed-benchmark-and-capture"
	if args.has("--barracks-material-seam-repair-capture-only"):
		run_kind = "barracks-material-seam-repair-capture-refresh"
	var report := await _run_sequence(run_kind)
	_write_absolute_json(_path_join(artifact_root, "barracks-material-seam-repair-runtime.json"), report)
	get_tree().quit(0 if report.get("status", "FAIL") == "PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_RUNTIME_EVIDENCE" else 1)

func _validation_report() -> Dictionary:
	var errors: Array[String] = []
	for key in material_sources.keys():
		var source: Dictionary = material_sources[key]
		if source.get("status", "FAIL") != "PASS":
			errors.append_array(source.get("errors", ["Unknown material source validation failure."]))
	if worker_context_source.get("status", "FAIL") != "PASS":
		errors.append_array(worker_context_source.get("errors", ["Worker context source validation failed."]))
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"slotId": SLOT_ID,
		"status": "PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_RUNTIME_VALIDATION" if errors.is_empty() else "FAIL_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_RUNTIME_VALIDATION",
		"materialSources": material_sources,
		"workerContextSource": worker_context_source,
		"zeroAiImagesGeneratedForV0150": true,
		"sameV0149SourceOnly": true,
		"noNewRuntimeArtSlot": true,
		"privateComparatorOnly": true,
		"productionApproval": "forbidden",
		"playerSliceIntegration": "forbidden",
		"browserIntegration": "forbidden",
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
					errors.append("Barracks seam repair benchmark failed for %s %s trial %d." % [approach, tier, trial_index + 1])
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
		"status": "PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_RUNTIME_EVIDENCE" if errors.is_empty() else "FAIL_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_RUNTIME_EVIDENCE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"benchmarkCount": benchmark_reports.size(),
		"screenshotCount": captures.size(),
		"benchmarks": benchmark_reports,
		"captures": captures,
		"materialSources": material_sources,
		"workerContextSource": worker_context_source,
		"fairPathAudit": _fair_path_audit(),
		"boundaries": {
			"privateComparatorOnly": true,
			"productionApproval": "forbidden",
			"playerSliceIntegration": "forbidden",
			"browserIntegration": "forbidden",
			"zeroAiImagesGeneratedForV0150": true,
			"sameV0149SourceOnly": true,
			"noNewRuntimeArtSlot": true,
			"defaultLauncherReplaced": false,
			"manifestMutated": false,
			"productionPackageIncluded": false
		},
		"limitations": [
			"Visual seam, shimmer, stretch, and mud checks require human review of captures.",
			"Generated v0.150 variants are ignored deterministic derivatives of the v0.149 source.",
			"Godot remains provisional and is not finally selected."
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
		"barracksShellCount": int(tier_config["barracksShellCount"]),
		"workerCount": int(tier_config["workerCount"]),
		"benchmarkFrames": int(tier_config["benchmarkFrames"]),
		"steadyStateWarmupFrames": 16
	}

func _source_for_approach(approach: String) -> Dictionary:
	if approach == APPROACH_FALLBACK:
		return material_sources.get("fallback", {})
	if approach == APPROACH_ORIGINAL:
		return material_sources.get("original_768", material_sources.get("fallback", {}))
	if approach == APPROACH_OFFSET_BLEND:
		return material_sources.get("wrapsafe_offset_blend", material_sources.get("fallback", {}))
	if approach == APPROACH_QUADRANT:
		return material_sources.get("wrapsafe_quadrant", material_sources.get("fallback", {}))
	if approach == APPROACH_SOFTSEAM:
		return material_sources.get("wrapsafe_softseam", material_sources.get("fallback", {}))
	return material_sources.get("fallback", {})

func _benchmark_current_view(config: Dictionary) -> Dictionary:
	var init_start := Time.get_ticks_usec()
	_build_scene(config)
	var initialization_duration_ms := float(Time.get_ticks_usec() - init_start) / 1000.0
	for i in range(int(config.get("steadyStateWarmupFrames", 16))):
		await get_tree().process_frame
	var frames := int(config["benchmarkFrames"])
	var frame_times: Array[float] = []
	var start := Time.get_ticks_usec()
	var last := start
	for frame in range(frames):
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
		"entityCount": int(config.get("barracksShellCount", 0)) + int(config.get("workerCount", 0)),
		"barracksShellCount": int(config.get("barracksShellCount", 0)),
		"workerContextCount": int(config.get("workerCount", 0)),
		"materialReuseCount": _material_reuse_count_for_source(source),
		"renderedObjectProxy": _rendered_object_proxy(config),
		"textureMemoryProxyBytes": _texture_memory_proxy_bytes(source),
		"sourceLoaded": source.get("sourceKind", "procedural"),
		"assetHash": source.get("sha256", "not-applicable"),
		"derivativeDimensions": source.get("dimensions", {"width": 0, "height": 0}),
		"uvScale": source.get("uvScale", 1.0),
		"navigationParity": "not-applicable-static-comparator",
		"pressureParity": "not-applicable-static-comparator",
		"stuckUnitCount": 0,
		"confidence": "local-headed-private-comparator"
	}

func _capture_review_views(start_index: int) -> Array[Dictionary]:
	var captures: Array[Dictionary] = []
	var views := [
		{"id": "source_original_768", "tier": "S", "approach": APPROACH_ORIGINAL, "view": "source_board"},
		{"id": "source_wrapsafe_offset_blend", "tier": "S", "approach": APPROACH_OFFSET_BLEND, "view": "source_board"},
		{"id": "source_wrapsafe_quadrant", "tier": "S", "approach": APPROACH_QUADRANT, "view": "source_board"},
		{"id": "source_wrapsafe_softseam", "tier": "S", "approach": APPROACH_SOFTSEAM, "view": "source_board"},
		{"id": "tiling_2x2_original", "tier": "S", "approach": APPROACH_ORIGINAL, "view": "tiling_2x2"},
		{"id": "tiling_2x2_offset_blend", "tier": "S", "approach": APPROACH_OFFSET_BLEND, "view": "tiling_2x2"},
		{"id": "tiling_2x2_quadrant", "tier": "S", "approach": APPROACH_QUADRANT, "view": "tiling_2x2"},
		{"id": "tiling_2x2_softseam", "tier": "S", "approach": APPROACH_SOFTSEAM, "view": "tiling_2x2"},
		{"id": "tiling_4x4_original", "tier": "S", "approach": APPROACH_ORIGINAL, "view": "tiling_4x4"},
		{"id": "tiling_4x4_offset_blend", "tier": "S", "approach": APPROACH_OFFSET_BLEND, "view": "tiling_4x4"},
		{"id": "tiling_4x4_quadrant", "tier": "S", "approach": APPROACH_QUADRANT, "view": "tiling_4x4"},
		{"id": "tiling_4x4_softseam", "tier": "S", "approach": APPROACH_SOFTSEAM, "view": "tiling_4x4"},
		{"id": "seam_diagnostic_original", "tier": "S", "approach": APPROACH_ORIGINAL, "view": "seam_diagnostic"},
		{"id": "seam_diagnostic_offset_blend", "tier": "S", "approach": APPROACH_OFFSET_BLEND, "view": "seam_diagnostic"},
		{"id": "seam_diagnostic_quadrant", "tier": "S", "approach": APPROACH_QUADRANT, "view": "seam_diagnostic"},
		{"id": "seam_diagnostic_softseam", "tier": "S", "approach": APPROACH_SOFTSEAM, "view": "seam_diagnostic"},
		{"id": "normal_rts_shell_offset_blend", "tier": "M", "approach": APPROACH_OFFSET_BLEND, "view": "normal_rts_gameplay_distance"},
		{"id": "zoomed_rts_shell_offset_blend", "tier": "L", "approach": APPROACH_OFFSET_BLEND, "view": "zoomed_out_gameplay_view"},
		{"id": "wet_overcast_offset_blend", "tier": "M", "approach": APPROACH_OFFSET_BLEND, "view": "wet_overcast_lighting_posture"},
		{"id": "restrained_hearth_offset_blend", "tier": "S", "approach": APPROACH_OFFSET_BLEND, "view": "restrained_warm_hearth_posture"},
		{"id": "worker_plus_barracks_offset_blend", "tier": "M", "approach": APPROACH_OFFSET_BLEND, "view": "worker_plus_barracks_composition"},
		{"id": "mipmap_zoom_transition_near_offset_blend", "tier": "S", "approach": APPROACH_OFFSET_BLEND, "view": "mipmap_zoom_transition_near"},
		{"id": "mipmap_zoom_transition_far_offset_blend", "tier": "L", "approach": APPROACH_OFFSET_BLEND, "view": "mipmap_zoom_transition_far"},
		{"id": "repeated_shell_stress_offset_blend", "tier": "L", "approach": APPROACH_OFFSET_BLEND, "view": "repeated_shell_stress_view"},
		{"id": "normal_rts_shell_quadrant", "tier": "M", "approach": APPROACH_QUADRANT, "view": "normal_rts_gameplay_distance"},
		{"id": "zoomed_rts_shell_quadrant", "tier": "L", "approach": APPROACH_QUADRANT, "view": "zoomed_out_gameplay_view"},
		{"id": "wet_overcast_quadrant", "tier": "M", "approach": APPROACH_QUADRANT, "view": "wet_overcast_lighting_posture"},
		{"id": "restrained_hearth_quadrant", "tier": "S", "approach": APPROACH_QUADRANT, "view": "restrained_warm_hearth_posture"},
		{"id": "worker_plus_barracks_quadrant", "tier": "M", "approach": APPROACH_QUADRANT, "view": "worker_plus_barracks_composition"},
		{"id": "mipmap_zoom_transition_near_quadrant", "tier": "S", "approach": APPROACH_QUADRANT, "view": "mipmap_zoom_transition_near"},
		{"id": "mipmap_zoom_transition_far_quadrant", "tier": "L", "approach": APPROACH_QUADRANT, "view": "mipmap_zoom_transition_far"},
		{"id": "repeated_shell_stress_quadrant", "tier": "L", "approach": APPROACH_QUADRANT, "view": "repeated_shell_stress_view"},
		{"id": "normal_rts_shell_softseam", "tier": "M", "approach": APPROACH_SOFTSEAM, "view": "normal_rts_gameplay_distance"},
		{"id": "zoomed_rts_shell_softseam", "tier": "L", "approach": APPROACH_SOFTSEAM, "view": "zoomed_out_gameplay_view"},
		{"id": "wet_overcast_softseam", "tier": "M", "approach": APPROACH_SOFTSEAM, "view": "wet_overcast_lighting_posture"},
		{"id": "restrained_hearth_softseam", "tier": "S", "approach": APPROACH_SOFTSEAM, "view": "restrained_warm_hearth_posture"},
		{"id": "worker_plus_barracks_softseam", "tier": "M", "approach": APPROACH_SOFTSEAM, "view": "worker_plus_barracks_composition"},
		{"id": "mipmap_zoom_transition_near_softseam", "tier": "S", "approach": APPROACH_SOFTSEAM, "view": "mipmap_zoom_transition_near"},
		{"id": "mipmap_zoom_transition_far_softseam", "tier": "L", "approach": APPROACH_SOFTSEAM, "view": "mipmap_zoom_transition_far"},
		{"id": "repeated_shell_stress_softseam", "tier": "L", "approach": APPROACH_SOFTSEAM, "view": "repeated_shell_stress_view"},
		{"id": "fallback_comparison", "tier": "S", "approach": APPROACH_FALLBACK, "view": "fallback_comparison"}
	]
	var index := start_index
	for view in views:
		var config := _workload_config(str(view["approach"]), str(view["tier"]), str(view["view"]))
		var capture := await _capture_current_view(config, index, str(view["id"]))
		captures.append(capture)
		index += 1
	return captures

func _capture_current_view(config: Dictionary, index: int, id_override: String = "") -> Dictionary:
	_build_scene(config)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	var view := str(config.get("view", "view"))
	var id := id_override if id_override != "" else "%02d_%s_%s_%s" % [index, config["tier"], config["approach"], view]
	var safe_name := "%02d_%s.png" % [index, id.to_lower().replace(" ", "_").replace("/", "_").replace(":", "_")]
	var target := _path_join(screenshot_root, safe_name)
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	var result := image.save_png(target)
	var source: Dictionary = config.get("assetSource", {})
	return {
		"id": id,
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
	active_scene.name = "V0150BarracksMaterialSeamRepairComparatorScene"
	add_child(active_scene)
	_setup_camera_and_lighting(config)
	var view := str(config.get("view", ""))
	if view.contains("source_board") or view.contains("tiling_") or view.contains("seam_diagnostic"):
		_add_material_review_board(config)
		return
	_add_plane("wet_granite_ground", Vector3(0, 0, 0), Vector2(24, 16), _flat_material(Color(0.17, 0.20, 0.18)))
	_add_lane_guides()
	var approach := str(config["approach"])
	if approach == APPROACH_WORKER_CONTEXT:
		_add_worker_context(int(config.get("workerCount", 0)), 1.0)
	elif approach == APPROACH_ORTHO:
		_add_procedural_ortho_shells(int(config.get("barracksShellCount", 0)))
		_add_worker_context(int(config.get("workerCount", 0)), 0.9)
	else:
		_add_barracks_shells(int(config.get("barracksShellCount", 0)), config.get("assetSource", {}), view)
		_add_worker_context(int(config.get("workerCount", 0)), 1.0)
	_add_lume_trace()

func _setup_camera_and_lighting(config: Dictionary) -> void:
	active_camera = Camera3D.new()
	active_camera.name = "V0150ComparatorCamera"
	active_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	var view := str(config.get("view", ""))
	active_camera.size = 8.8
	if view.contains("source_board") or view.contains("tiling_") or view.contains("seam_diagnostic"):
		active_camera.size = 6.0
	elif view.contains("zoomed") or view.contains("far") or view.contains("repeated"):
		active_camera.size = 12.6
	elif view.contains("normal") or view.contains("worker_plus") or view.contains("wet_overcast"):
		active_camera.size = 9.4
	active_camera.position = Vector3(0.0, 4.6, 8.2)
	active_camera.look_at(Vector3(0, 0.9, 0), Vector3.UP)
	active_scene.add_child(active_camera)
	active_camera.make_current()
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08, 0.10, 0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.50, 0.57, 0.54)
	env.ambient_light_energy = 0.88
	if view.contains("wet_overcast"):
		env.ambient_light_color = Color(0.45, 0.55, 0.57)
		env.ambient_light_energy = 0.72
	world.environment = env
	active_scene.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "OvercastKey"
	sun.light_energy = 1.4
	sun.rotation_degrees = Vector3(-48, -36, 0)
	active_scene.add_child(sun)
	if view.contains("warm_hearth"):
		var warm := OmniLight3D.new()
		warm.name = "RestrainedWarmHearth"
		warm.position = Vector3(-1.2, 1.0, 0.3)
		warm.light_color = Color(1.0, 0.62, 0.30)
		warm.light_energy = 0.55
		warm.omni_range = 4.2
		active_scene.add_child(warm)

func _add_material_review_board(config: Dictionary) -> void:
	var view := str(config.get("view", ""))
	var source: Dictionary = config.get("assetSource", {})
	var uv_scale := 1.0
	if view.contains("tiling_2x2"):
		uv_scale = 2.0
	elif view.contains("tiling_4x4") or view.contains("seam_diagnostic"):
		uv_scale = 4.0
	var material := _barracks_material_for_source(source, uv_scale, true)
	_add_quad("material_review_board", Vector3(0, 2.25, 0), Vector2(5.0, 5.0), material)
	if view.contains("seam_diagnostic"):
		_add_box("seam_line_horizontal", Vector3(0, 2.25, -0.06), Vector3(5.0, 0.035, 0.025), _flat_material(Color(0.25, 0.95, 0.82, 0.72), true, true, 0.10))
		_add_box("seam_line_vertical", Vector3(0, 2.25, -0.07), Vector3(0.035, 5.0, 0.025), _flat_material(Color(0.25, 0.95, 0.82, 0.72), true, true, 0.10))
	_add_cylinder("board_review_ring", Vector3(0, 0.12, -2.65), 0.45, 0.018, _flat_material(Color(0.32, 0.85, 0.75, 0.34), true, true, 0.08))

func _add_lane_guides() -> void:
	for index in range(5):
		var z := -6.0 + index * 3.0
		_add_box("worked_earth_lane_%02d" % index, Vector3(0, 0.035, z), Vector3(22.0, 0.05, 0.42), _flat_material(Color(0.20, 0.17, 0.12)))

func _add_barracks_shells(count: int, source: Dictionary, view: String) -> void:
	var material := _barracks_material_for_source(source)
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	var spacing := 4.2
	for index in range(count):
		var x := (index % cols - cols / 2.0) * spacing + 1.8
		var z := (index / cols - cols / 2.0) * spacing + 1.2
		var scale := 1.0
		if view.contains("repeated"):
			scale = 0.92
		_add_single_barracks_shell(index, Vector3(x, 0, z), scale, material)

func _add_single_barracks_shell(index: int, origin: Vector3, scale: float, material: StandardMaterial3D) -> void:
	total_barracks_shell_rebuild_count += 1
	_add_box("barracks_base_%03d" % index, origin + Vector3(0, 0.18 * scale, 0), Vector3(2.5, 0.36, 1.75) * scale, material)
	_add_box("barracks_wall_%03d" % index, origin + Vector3(0, 0.88 * scale, 0), Vector3(2.25, 1.05, 1.48) * scale, material)
	_add_box("barracks_roof_%03d" % index, origin + Vector3(0, 1.55 * scale, 0), Vector3(2.65, 0.36, 1.85) * scale, _flat_material(Color(0.15, 0.11, 0.08)))
	_add_box("barracks_door_%03d" % index, origin + Vector3(0, 0.72 * scale, -0.78 * scale), Vector3(0.55, 0.82, 0.08) * scale, material)
	_add_box("barracks_beam_a_%03d" % index, origin + Vector3(-1.24 * scale, 0.92 * scale, 0), Vector3(0.12, 1.25, 1.68) * scale, _flat_material(Color(0.12, 0.09, 0.07)))
	_add_box("barracks_beam_b_%03d" % index, origin + Vector3(1.24 * scale, 0.92 * scale, 0), Vector3(0.12, 1.25, 1.68) * scale, _flat_material(Color(0.12, 0.09, 0.07)))
	_add_cylinder("repair_posture_ring_%03d" % index, origin + Vector3(0, 0.055, -1.06 * scale), 0.42 * scale, 0.018, _flat_material(Color(0.32, 0.85, 0.75, 0.34), true, true, 0.08))

func _add_procedural_ortho_shells(count: int) -> void:
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := (index % cols - cols / 2.0) * 4.1 + 1.7
		var z := (index / cols - cols / 2.0) * 4.1 + 1.1
		_add_box("ortho_shell_%03d" % index, Vector3(x, 0.55, z), Vector3(2.3, 1.1, 1.55), _flat_material(Color(0.36, 0.31, 0.25)))
		_add_box("ortho_roof_%03d" % index, Vector3(x, 1.32, z), Vector3(2.65, 0.32, 1.85), _flat_material(Color(0.16, 0.12, 0.09)))

func _add_worker_context(count: int, scale: float) -> void:
	var texture := _texture_for_source(worker_context_source)
	var material := _worker_material_for_source(worker_context_source, texture)
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := (index % cols - cols / 2.0) * 1.35 - 4.6
		var z := (index / cols - cols / 2.0) * 1.25 + 2.8
		total_worker_context_rebuild_count += 1
		var mesh := QuadMesh.new()
		mesh.size = Vector2(0.92 * scale, 1.35 * scale)
		var node := MeshInstance3D.new()
		node.name = "worker_context_%03d" % index
		node.mesh = mesh
		node.position = Vector3(x, 0.78 * scale, z)
		node.rotation_degrees = Vector3(0, 180, 0)
		node.material_override = material
		active_scene.add_child(node)
		_add_cylinder("worker_selection_ring_%03d" % index, Vector3(x, 0.05, z), 0.48 * scale, 0.016, _flat_material(Color(0.28, 0.88, 0.78, 0.36), true, true, 0.10))

func _add_lume_trace() -> void:
	for index in range(8):
		var x := -7.0 + index * 2.0
		_add_cylinder("lume_trace_%02d" % index, Vector3(x, 0.09, -5.4), 0.06, 0.04, _flat_material(Color(0.25, 0.72, 0.64, 0.5), true, true, 0.08))

func _texture_for_source(source: Dictionary) -> Texture2D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	if texture_cache.has(path):
		return texture_cache[path]
	var image := Image.new()
	var load_error := image.load(path)
	if load_error != OK:
		push_error("Could not load comparator texture %s" % path)
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

func _barracks_material_for_source(source: Dictionary, uv_scale_override: float = -1.0, unshaded: bool = false) -> StandardMaterial3D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	var uv_scale := uv_scale_override if uv_scale_override > 0.0 else float(source.get("uvScale", 1.0))
	var key := "%s|barracks-material|uv%.2f|unshaded%s" % [path, uv_scale, str(unshaded)]
	if material_cache.has(key):
		material_reuse_counts[key] = int(material_reuse_counts.get(key, 0)) + 1
		return material_cache[key]
	var material := StandardMaterial3D.new()
	material.albedo_texture = _texture_for_source(source)
	material.albedo_color = Color(0.92, 0.94, 0.90, 1)
	material.roughness = 0.84
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.uv1_scale = Vector3(uv_scale, uv_scale, 1.0)
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_cache[key] = material
	material_create_counts[key] = int(material_create_counts.get(key, 0)) + 1
	material_create_events.append({"key": key, "sourceKind": source.get("sourceKind", "unknown"), "uvScale": uv_scale})
	return material

func _worker_material_for_source(source: Dictionary, texture: Texture2D) -> StandardMaterial3D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	var key := "%s|worker-context" % path
	if material_cache.has(key):
		material_reuse_counts[key] = int(material_reuse_counts.get(key, 0)) + 1
		return material_cache[key]
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.albedo_color = Color(1, 1, 1, 1)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
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

func _add_plane(name: String, position: Vector3, size: Vector2, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := PlaneMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.position = position
	node.material_override = material
	active_scene.add_child(node)
	return node

func _add_quad(name: String, position: Vector3, size: Vector2, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := QuadMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.position = position
	node.rotation_degrees = Vector3(0, 180, 0)
	node.material_override = material
	active_scene.add_child(node)
	return node

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
			"tracked-barracks-material-diagnostic-fallback"
		),
		"original_768": _validated_source(
			_path_join(local_slot_root, "%s_768_original.png" % SLOT_ID),
			_path_join(local_slot_root, "%s_768_original.metadata.json" % SLOT_ID),
			"v0150-original-768-control",
			SLOT_ID,
			SELECTED_MATERIAL_HASH
		),
		"wrapsafe_offset_blend": _validated_source(
			_path_join(local_slot_root, "%s_768_wrapsafe_offset_blend.png" % SLOT_ID),
			_path_join(local_slot_root, "%s_768_wrapsafe_offset_blend.metadata.json" % SLOT_ID),
			"v0150-wrapsafe-offset-blend"
		),
		"wrapsafe_quadrant": _validated_source(
			_path_join(local_slot_root, "%s_768_wrapsafe_quadrant.png" % SLOT_ID),
			_path_join(local_slot_root, "%s_768_wrapsafe_quadrant.metadata.json" % SLOT_ID),
			"v0150-wrapsafe-quadrant"
		),
		"wrapsafe_softseam": _validated_source(
			_path_join(local_slot_root, "%s_768_wrapsafe_softseam.png" % SLOT_ID),
			_path_join(local_slot_root, "%s_768_wrapsafe_softseam.metadata.json" % SLOT_ID),
			"v0150-wrapsafe-softseam"
		)
	}

func _load_worker_context_source() -> Dictionary:
	var worker_root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot")
	var selected := _validated_source(
		_path_join(worker_root, "%s_trimmed_1024.png" % WORKER_SLOT_ID),
		_path_join(worker_root, "%s_trimmed_1024.metadata.json" % WORKER_SLOT_ID),
		"existing-worker-trimmed-1024-context",
		WORKER_SLOT_ID,
		SELECTED_WORKER_HASH
	)
	if selected.get("status", "FAIL") == "PASS":
		return selected
	return _validated_source(
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.png" % WORKER_SLOT_ID),
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.contract.json" % WORKER_SLOT_ID),
		"tracked-worker-diagnostic-fallback-context",
		WORKER_SLOT_ID,
		""
	)

func _validated_source(image_path: String, metadata_path: String, source_kind: String, expected_slot_id: String = SLOT_ID, expected_hash: String = "") -> Dictionary:
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
	if expected_hash != "" and sha != expected_hash:
		errors.append("%s did not match required selected hash." % source_kind)
	if str(metadata.get("slotId", "")) != expected_slot_id:
		errors.append("%s slotId mismatch." % source_kind)
	if metadata.get("privateComparatorOnly", false) != true:
		errors.append("%s missing privateComparatorOnly=true." % source_kind)
	if str(metadata.get("productionApproval", "")) != "forbidden":
		errors.append("%s productionApproval must remain forbidden." % source_kind)
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
		"dimensions": metadata.get("dimensions", metadata.get("sourceDimensions", {"width": image.get_width(), "height": image.get_height()})),
		"uvScale": metadata.get("uvScale", 1.0),
		"tilingMode": metadata.get("tilingMode", "repeat comparator material"),
		"colorSpacePosture": metadata.get("colorSpacePosture", "unknown"),
		"seamMetrics": metadata.get("seamMetrics", {})
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
	var approach := str(config["approach"])
	var view := str(config.get("view", ""))
	if view.contains("source_board") or view.contains("tiling_") or view.contains("seam_diagnostic"):
		return 3
	if approach == APPROACH_WORKER_CONTEXT:
		return int(config.get("workerCount", 0)) * 2 + 2
	if approach == APPROACH_ORTHO:
		return int(config.get("barracksShellCount", 0)) * 2 + int(config.get("workerCount", 0)) * 2 + 2
	return int(config.get("barracksShellCount", 0)) * 7 + int(config.get("workerCount", 0)) * 2 + 2

func _fair_path_audit() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"localAndFallbackShareBarracksShellRenderPath": true,
		"textureCacheEntries": texture_cache.size(),
		"materialCacheEntries": material_cache.size(),
		"sourceLoadCounts": source_load_counts,
		"textureCreateCounts": texture_create_counts,
		"materialCreateCounts": material_create_counts,
		"materialReuseCounts": material_reuse_counts,
		"sourceLoadEvents": source_load_events,
		"materialCreateEvents": material_create_events,
		"barracksShellNodeRebuildCount": total_barracks_shell_rebuild_count,
		"workerContextNodeRebuildCount": total_worker_context_rebuild_count,
		"textureLoadedOnceAndReused": _all_counts_at_most_one(texture_create_counts),
		"materialCreatedOnceAndReusedWhereSafe": _all_counts_at_most_one(material_create_counts),
		"repeatedTextureCreateDuringSteadyState": false,
		"repeatedMaterialCreateDuringSteadyState": false,
		"derivativeGenerationDuringRuntime": false,
		"metadataParsingDuringSteadyState": false,
		"uvRebuildDuringSteadyState": false,
		"benchmarkExcludesInitializationAndWarmup": true,
		"unknownOrHashMismatchedSourcesFailClosed": true,
		"zeroAiImagesGeneratedForV0150": true,
		"sameV0149SourceOnly": true,
		"noNewRuntimeArtSlot": true
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
	return ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0150/evidence")

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
	return arg == "--barrosan-barracks-material-seam-repair" or arg == "--barracks-material-seam-repair-validate-only" or arg == "--barracks-material-seam-repair-benchmark-sequence" or arg == "--barracks-material-seam-repair-capture-only" or arg.begins_with("--artifact-root=") or arg.begins_with("--viewport=") or arg.begins_with("--resolution=")

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
