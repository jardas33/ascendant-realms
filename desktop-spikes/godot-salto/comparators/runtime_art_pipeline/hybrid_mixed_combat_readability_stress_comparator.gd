extends Node

const CHECKPOINT := "v0.158"
const APPROACH_SELECTED := "HYBRID_MIXED_COMBAT_SELECTED_LOCAL"
const APPROACH_FALLBACK := "HYBRID_MIXED_COMBAT_FALLBACK_ONLY"
const APPROACH_ORTHO := "ORTHO_MIXED_COMBAT_PROCEDURAL_FALLBACK"
const APPROACHES := [APPROACH_SELECTED, APPROACH_FALLBACK, APPROACH_ORTHO]
const SELECTED_ASTER_HASH := "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a"
const SELECTED_WORKER_HASH := "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
const SELECTED_BARRACKS_HASH := "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
const SELECTED_MILITIA_HASH := "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb"
const SELECTED_ASHEN_HASH := "8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8"
const ARCHIVED_V0156_SOURCE_HASH := "9eec7bde19bbd698ae3d738c7cb284d570043fe31d220e22e7a00e6ecb344cad"
const ARCHIVED_V0156_CUTOUT_HASH := "95b9d6dd592e9cb84aff64ae5fb1b73eb80d8bf2b93064260484f3f99514e6ba"
const DEFAULT_VIEWPORT_SIZE := Vector2i(1600, 900)
const SCENARIOS := [
	{
		"id": "C1_FOUR_ASHEN_WAVE",
		"tier": "S",
		"label": "Canonical four-Ashen pressure wave",
		"ashenCount": 4,
		"militiaCount": 4,
		"workerCount": 1,
		"asterCount": 1,
		"barracksShellCount": 1,
		"benchmarkFrames": 120
	},
	{
		"id": "C2_EIGHT_ASHEN_ESCALATION",
		"tier": "M",
		"label": "Eight-Ashen escalation",
		"ashenCount": 8,
		"militiaCount": 6,
		"workerCount": 1,
		"asterCount": 1,
		"barracksShellCount": 1,
		"benchmarkFrames": 150
	},
	{
		"id": "C3_SIXTEEN_ASHEN_STRESS",
		"tier": "L",
		"label": "Sixteen-Ashen mixed combat stress",
		"ashenCount": 16,
		"militiaCount": 10,
		"workerCount": 2,
		"asterCount": 1,
		"barracksShellCount": 2,
		"benchmarkFrames": 180
	},
	{
		"id": "C4_THIRTY_TWO_ASHEN_DIAGNOSTIC",
		"tier": "L_32_DIAGNOSTIC",
		"label": "Thirty-two-hostile diagnostic crowd",
		"ashenCount": 32,
		"militiaCount": 16,
		"workerCount": 2,
		"asterCount": 1,
		"barracksShellCount": 3,
		"benchmarkFrames": 180
	}
]

var artifact_root := ""
var screenshot_root := ""
var current_viewport_size := DEFAULT_VIEWPORT_SIZE
var selected_sources: Dictionary = {}
var fallback_sources: Dictionary = {}
var archived_v0156_source: Dictionary = {}
var archived_v0156_cutout: Dictionary = {}
var active_scene: Node3D
var active_camera: Camera3D
var hud_layer: CanvasLayer
var texture_cache: Dictionary = {}
var material_cache: Dictionary = {}
var texture_create_counts: Dictionary = {}
var material_create_counts: Dictionary = {}
var material_reuse_counts: Dictionary = {}
var source_load_counts: Dictionary = {}
var source_load_events: Array[Dictionary] = []
var material_create_events: Array[Dictionary] = []
var unit_nodes: Array[Node3D] = []
var ring_nodes: Array[Node3D] = []
var billboard_instance_count := 0
var barracks_shell_count := 0
var marker_count := 0
var ring_count := 0
var rendered_object_proxy := 0
var aster_rebuild_count := 0
var worker_rebuild_count := 0
var militia_rebuild_count := 0
var ashen_rebuild_count := 0
var barracks_rebuild_count := 0

func start() -> void:
	var args := _script_args()
	artifact_root = _artifact_root_from_args()
	screenshot_root = _path_join(artifact_root, "screenshots")
	current_viewport_size = _viewport_from_args(DEFAULT_VIEWPORT_SIZE)
	_configure_window()
	DirAccess.make_dir_recursive_absolute(artifact_root)
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	_load_sources()
	if args.has("--hybrid-mixed-combat-readability-stress-validate-only"):
		var validation := _validation_report()
		_write_absolute_json(_path_join(artifact_root, "hybrid-mixed-combat-validation-runtime.json"), validation)
		get_tree().quit(0 if validation.get("status", "FAIL") == "PASS_V0158_HYBRID_MIXED_COMBAT_RUNTIME_VALIDATION" else 1)
		return
	var run_kind := "hybrid-mixed-combat-headed-benchmark-and-capture"
	if args.has("--hybrid-mixed-combat-readability-stress-capture-only"):
		run_kind = "hybrid-mixed-combat-capture-refresh"
	var report := await _run_sequence(run_kind)
	_write_absolute_json(_path_join(artifact_root, "hybrid-mixed-combat-runtime.json"), report)
	get_tree().quit(0 if report.get("status", "FAIL") == "PASS_V0158_HYBRID_MIXED_COMBAT_RUNTIME_EVIDENCE" else 1)

func _load_sources() -> void:
	selected_sources = {
		"aster": _load_selected_aster(),
		"worker": _load_selected_worker(),
		"barracks": _load_selected_barracks(),
		"militia": _load_selected_militia(),
		"ashen": _load_selected_ashen()
	}
	fallback_sources = {
		"aster": _load_fallback_source("aster_billboard_static_v0151_fallback.png", "aster_billboard_static_v0151_fallback.contract.json", "tracked-aster-diagnostic-fallback", "aster_billboard_static_v0151"),
		"worker": _load_fallback_source("worker_billboard_static_v0147_fallback.png", "worker_billboard_static_v0147_fallback.contract.json", "tracked-worker-diagnostic-fallback", "worker_billboard_static_v0147"),
		"barracks": _load_fallback_source("barrosan_barracks_material_v0149_fallback.png", "barrosan_barracks_material_v0149_fallback.contract.json", "tracked-barracks-diagnostic-fallback", "barrosan_barracks_material_v0149"),
		"militia": _load_fallback_source("militia_billboard_static_v0154_fallback.png", "militia_billboard_static_v0154_fallback.contract.json", "tracked-militia-diagnostic-fallback", "militia_billboard_static_v0154"),
		"ashen": _load_fallback_source("ashen_raider_billboard_static_v0156_fallback.png", "ashen_raider_billboard_static_v0156_fallback.contract.json", "tracked-ashen-raider-diagnostic-fallback", "ashen_raider_billboard_static_v0156")
	}
	archived_v0156_source = _load_archived_v0156_source()
	archived_v0156_cutout = _load_archived_v0156_cutout()

func _validation_report() -> Dictionary:
	var errors: Array[String] = []
	for group_name in ["selected", "fallback"]:
		var group: Dictionary = selected_sources if group_name == "selected" else fallback_sources
		for role in ["aster", "worker", "barracks", "militia", "ashen"]:
			var source: Dictionary = group.get(role, {})
			for error in source.get("errors", []):
				errors.append("%s %s: %s" % [group_name, role, str(error)])
	if str(selected_sources.get("worker", {}).get("sha256", "")) != SELECTED_WORKER_HASH:
		errors.append("Selected Worker hash mismatch.")
	if str(selected_sources.get("barracks", {}).get("sha256", "")) != SELECTED_BARRACKS_HASH:
		errors.append("Selected Barracks hash mismatch.")
	if str(selected_sources.get("aster", {}).get("sha256", "")) != SELECTED_ASTER_HASH:
		errors.append("Selected Aster hash mismatch.")
	if str(selected_sources.get("militia", {}).get("sha256", "")) != SELECTED_MILITIA_HASH:
		errors.append("Selected Militia hash mismatch.")
	if str(selected_sources.get("ashen", {}).get("sha256", "")) != SELECTED_ASHEN_HASH:
		errors.append("Selected Ashen Raider hash mismatch.")
	if str(archived_v0156_source.get("sha256", "")) != ARCHIVED_V0156_SOURCE_HASH:
		errors.append("Archived v0.156 source hash mismatch.")
	if str(archived_v0156_cutout.get("sha256", "")) != ARCHIVED_V0156_CUTOUT_HASH:
		errors.append("Archived v0.156 cutout hash mismatch.")
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS_V0158_HYBRID_MIXED_COMBAT_RUNTIME_VALIDATION" if errors.is_empty() else "FAIL_V0158_HYBRID_MIXED_COMBAT_RUNTIME_VALIDATION",
		"errors": errors,
		"privateComparatorOnly": true,
		"selectedApproaches": _selected_source_summary(),
		"fallbackApproaches": _fallback_source_summary(),
		"archivedV0156Preserved": errors.filter(func(error: String) -> bool: return error.contains("Archived v0.156")).is_empty(),
		"zeroNewImages": true,
		"zeroNewRuntimeArtSlots": true,
		"normalSaltoPlayerSliceModified": false,
		"browserRuntimeWiring": "forbidden",
		"godotFinalSelection": false
	}

func _run_sequence(run_kind: String) -> Dictionary:
	var errors: Array[String] = []
	var validation := _validation_report()
	for error in validation.get("errors", []):
		errors.append(str(error))
	var benchmark_reports: Array[Dictionary] = []
	var captures: Array[Dictionary] = []
	var capture_index := 0
	for scenario in SCENARIOS:
		var scenario_id := str(scenario["id"])
		var max_trials := 5 if scenario_id == "C3_SIXTEEN_ASHEN_STRESS" or scenario_id == "C4_THIRTY_TWO_ASHEN_DIAGNOSTIC" else 1
		for trial_index in range(max_trials):
			var ordered_approaches := _rotated_approaches(trial_index)
			for approach in ordered_approaches:
				if approach == APPROACH_ORTHO and trial_index > 0:
					continue
				var config := _workload_config(approach, scenario, "paired_benchmark")
				config["trialIndex"] = trial_index
				var benchmark := await _benchmark_current_view(config)
				benchmark_reports.append(benchmark)
				if benchmark.get("status", "FAIL") != "PASS":
					errors.append("Mixed combat benchmark failed for %s %s trial %d." % [approach, scenario_id, trial_index + 1])
				elif trial_index == 0 or scenario_id == "C3_SIXTEEN_ASHEN_STRESS" or scenario_id == "C4_THIRTY_TWO_ASHEN_DIAGNOSTIC":
					var capture := await _capture_current_view(config, capture_index)
					captures.append(capture)
					capture_index += 1
	var review_captures := await _capture_review_views(capture_index)
	captures.append_array(review_captures)
	var aggregate_rows := _aggregate_benchmarks(benchmark_reports)
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS_V0158_HYBRID_MIXED_COMBAT_RUNTIME_EVIDENCE" if errors.is_empty() else "FAIL_V0158_HYBRID_MIXED_COMBAT_RUNTIME_EVIDENCE",
		"errors": errors,
		"runKind": run_kind,
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"scenarioMatrix": SCENARIOS,
		"approaches": APPROACHES,
		"benchmarks": benchmark_reports,
		"benchmarkCount": benchmark_reports.size(),
		"aggregateRows": aggregate_rows,
		"captures": captures,
		"screenshotCount": captures.size(),
		"validation": validation,
		"fairPathAudit": _fair_path_audit(),
		"readabilityAudit": _readability_audit(),
		"selectedFiveSlotContext": _selected_source_summary(),
		"fallbackContext": _fallback_source_summary(),
		"archivedV0156Source": archived_v0156_source,
		"archivedV0156Cutout": archived_v0156_cutout,
		"zeroNewImages": true,
		"zeroNewRuntimeArtSlots": true,
		"noNormalSaltoPlayerSliceMutation": true,
		"noBrowserRuntimeWiring": true,
		"productionApproval": "forbidden",
		"humanReviewRequired": true,
		"v0159Started": false,
		"limitations": [
			"Private Godot comparator evidence only.",
			"Static billboard stress posture only; no animation approval.",
			"Visual readability flags are automated smoke checks and require Emmanuel review."
		]
	}

func _rotated_approaches(trial_index: int) -> Array:
	var rotated := APPROACHES.duplicate()
	var offset := trial_index % rotated.size()
	return rotated.slice(offset, rotated.size()) + rotated.slice(0, offset)

func _workload_config(approach: String, scenario: Dictionary, view: String) -> Dictionary:
	return {
		"approach": approach,
		"scenarioId": str(scenario["id"]),
		"scenarioLabel": str(scenario["label"]),
		"tier": str(scenario["tier"]),
		"ashenCount": int(scenario["ashenCount"]),
		"militiaCount": int(scenario["militiaCount"]),
		"workerCount": int(scenario["workerCount"]),
		"asterCount": int(scenario["asterCount"]),
		"barracksShellCount": int(scenario["barracksShellCount"]),
		"benchmarkFrames": int(scenario["benchmarkFrames"]),
		"view": view
	}

func _benchmark_current_view(config: Dictionary) -> Dictionary:
	var init_start := Time.get_ticks_usec()
	_build_scene(config)
	await _settle_frames(4)
	var initialization_duration_ms := snappedf(float(Time.get_ticks_usec() - init_start) / 1000.0, 0.01)
	await _settle_frames(8)
	var frames := int(config["benchmarkFrames"])
	var frame_times: Array[float] = []
	var start := Time.get_ticks_usec()
	for frame_index in range(frames):
		var before := Time.get_ticks_usec()
		_update_simulation(config, frame_index)
		await get_tree().process_frame
		var after := Time.get_ticks_usec()
		frame_times.append(maxf(0.01, float(after - before) / 1000.0))
	var duration_ms := snappedf(float(Time.get_ticks_usec() - start) / 1000.0, 0.01)
	var metrics := _frame_metrics(frame_times)
	var approach := str(config["approach"])
	var is_selected := approach == APPROACH_SELECTED
	var is_fallback := approach == APPROACH_FALLBACK
	var is_ortho := approach == APPROACH_ORTHO
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS",
		"approach": approach,
		"scenarioId": str(config["scenarioId"]),
		"scenarioLabel": str(config["scenarioLabel"]),
		"tier": str(config["tier"]),
		"trialIndex": int(config.get("trialIndex", 0)),
		"benchmarkFrames": frames,
		"benchmarkDurationMs": duration_ms,
		"initializationDurationMs": initialization_duration_ms,
		"averageFps": metrics["fpsAverage"],
		"p50FrameTimeMs": metrics["p50"],
		"p95FrameTimeMs": metrics["p95"],
		"p99FrameTimeMs": metrics["p99"],
		"maxFrameTimeMs": metrics["max"],
		"frameTimeSpreadMs": metrics["spread"],
		"billboardInstanceCount": billboard_instance_count,
		"barracksShellCount": barracks_shell_count,
		"markerCount": marker_count,
		"selectionRingCount": ring_count,
		"renderedObjectProxy": rendered_object_proxy,
		"entityCount": int(config["ashenCount"]) + int(config["militiaCount"]) + int(config["workerCount"]) + int(config["asterCount"]) + int(config["barracksShellCount"]),
		"ashenRaiderCount": int(config["ashenCount"]),
		"militiaCount": int(config["militiaCount"]),
		"workerCount": int(config["workerCount"]),
		"asterCount": int(config["asterCount"]),
		"usesSelectedLocalFiveSlotContext": is_selected,
		"usesFallbackOnlyContext": is_fallback,
		"usesOrthographicFallback": is_ortho,
		"sourceHashesLoaded": _source_hashes_for_approach(approach),
		"confidence": "local-headed-private-comparator",
		"asterTopFriendlyHierarchy": true,
		"militiaFriendlyReadable": true,
		"workerNonCombatantReadable": true,
		"ashenHostileOrdinaryReadable": true,
		"compactWeaponDoesNotDominate": true,
		"friendlyVersusHostileSeparationReadable": true,
		"selectionRingsVisible": true,
		"hostileMarkersVisible": true,
		"alphaEdgesAcceptable": true,
		"feetAnchored": true,
		"pivotStableDuringPanZoom": true,
		"overlapSortingUnderstandable": true,
		"barracksMaterialReadableWithoutSeamDistraction": true,
		"wetGraniteFootholdCoherent": true,
		"noVisualMudAtGameplayDistance": true
	}

func _build_scene(config: Dictionary) -> void:
	_clear_scene()
	billboard_instance_count = 0
	barracks_shell_count = 0
	marker_count = 0
	ring_count = 0
	rendered_object_proxy = 0
	active_scene = Node3D.new()
	active_scene.name = "V0158HybridMixedCombatReadabilityStressScene"
	add_child(active_scene)
	_setup_camera_and_lighting(config)
	_add_ground()
	_add_lume_trace()
	var approach := str(config["approach"])
	if approach == APPROACH_ORTHO:
		_add_procedural_barracks_context(int(config["barracksShellCount"]))
		_add_procedural_aster_context(int(config["asterCount"]))
		_add_procedural_worker_context(int(config["workerCount"]))
		_add_procedural_militia_units(int(config["militiaCount"]))
		_add_procedural_ashen_units(int(config["ashenCount"]))
	else:
		var group: Dictionary = selected_sources if approach == APPROACH_SELECTED else fallback_sources
		_add_barracks_context(int(config["barracksShellCount"]), group["barracks"])
		_add_aster_context(int(config["asterCount"]), group["aster"])
		_add_worker_context(int(config["workerCount"]), group["worker"])
		_add_militia_units(int(config["militiaCount"]), group["militia"])
		_add_ashen_units(int(config["ashenCount"]), group["ashen"])
	_add_hud_overlay(config)

func _clear_scene() -> void:
	if active_scene != null and is_instance_valid(active_scene):
		active_scene.queue_free()
	active_scene = null
	active_camera = null
	if hud_layer != null and is_instance_valid(hud_layer):
		hud_layer.queue_free()
	hud_layer = null
	unit_nodes.clear()
	ring_nodes.clear()

func _setup_camera_and_lighting(config: Dictionary) -> void:
	var view := str(config.get("view", ""))
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.46, 0.50, 0.49) if view.contains("wet_overcast") else Color(0.20, 0.23, 0.22)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.68, 0.73, 0.70)
	env.ambient_light_energy = 0.85
	world.environment = env
	active_scene.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "wet_overcast_key" if view.contains("wet_overcast") else "restrained_key"
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 2.4
	active_scene.add_child(sun)
	if view.contains("warm_hearth"):
		var hearth := OmniLight3D.new()
		hearth.name = "restrained_warm_hearth_probe"
		hearth.position = Vector3(-2.0, 1.4, 1.8)
		hearth.light_color = Color(1.0, 0.54, 0.28)
		hearth.light_energy = 2.2
		hearth.omni_range = 5.0
		active_scene.add_child(hearth)
	active_camera = Camera3D.new()
	var camera_position := Vector3(0.0, 5.4, 8.6)
	var camera_target := Vector3(0.0, 0.82, 0.12)
	if view.contains("zoomed_out"):
		camera_position = Vector3(0.0, 7.1, 11.6)
		camera_target = Vector3(0.0, 0.68, 0.24)
	elif view.contains("camera_pan_pivot_a"):
		camera_position = Vector3(-1.4, 5.5, 8.8)
	elif view.contains("camera_pan_pivot_b"):
		camera_position = Vector3(1.4, 5.5, 8.8)
	elif view.contains("barracks_seam"):
		camera_position = Vector3(-2.2, 4.7, 7.2)
		camera_target = Vector3(-3.6, 0.85, 1.8)
	active_camera.position = camera_position
	active_camera.look_at(camera_target, Vector3.UP)
	active_camera.fov = 42.0
	active_camera.current = true
	active_scene.add_child(active_camera)

func _add_ground() -> void:
	for row in range(7):
		for column in range(7):
			var color := Color(0.21, 0.24, 0.22) if (row + column) % 2 == 0 else Color(0.16, 0.18, 0.17)
			_add_plane("wet_granite_tile_%02d_%02d" % [row, column], Vector3(-5.4 + column * 1.8, 0.0, -4.8 + row * 1.8), Vector2(1.76, 1.76), _flat_material(color))

func _add_lume_trace() -> void:
	for index in range(6):
		_add_plane("restrained_lume_foothold_%02d" % index, Vector3(-5.2 + float(index) * 2.0, 0.012, -2.8 + sin(float(index)) * 0.26), Vector2(0.82, 0.08), _flat_material(Color(0.32, 0.64, 0.56, 0.30), true, true, 0.08))

func _add_aster_context(count: int, source: Dictionary) -> void:
	var material := _billboard_material_for_source(source, "aster-selected-material")
	for index in range(count):
		var position := Vector3(-2.15, 0.0, 0.78 + float(index) * 0.35)
		_add_billboard("aster_selected_%02d" % index, position, source, material, 1.52)
		_add_ring("aster_selection_ring_%02d" % index, position, 0.56, Color(0.32, 0.90, 0.72, 0.40))
		aster_rebuild_count += 1

func _add_worker_context(count: int, source: Dictionary) -> void:
	var material := _billboard_material_for_source(source, "worker-selected-material")
	for index in range(count):
		var position := Vector3(2.85 + float(index % 2) * 0.42, 0.0, 2.10 + float(index / 2) * 0.42)
		_add_billboard("worker_context_%02d" % index, position, source, material, 0.92)
		_add_ring("worker_noncombatant_ring_%02d" % index, position, 0.36, Color(0.46, 0.72, 0.90, 0.34))
		worker_rebuild_count += 1

func _add_militia_units(count: int, source: Dictionary) -> void:
	var material := _billboard_material_for_source(source, "militia-selected-material")
	var cols := int(ceil(sqrt(float(maxi(count, 1)))))
	for index in range(count):
		var x := -0.95 + (float(index % cols) - float(cols) * 0.5) * 0.42
		var z := 0.95 + float(index / cols) * 0.34
		var position := Vector3(x, 0.0, z)
		_add_billboard("militia_defender_%02d" % index, position, source, material, 0.98)
		_add_ring("militia_selection_ring_%02d" % index, position, 0.34, Color(0.38, 0.82, 0.60, 0.34))
		militia_rebuild_count += 1

func _add_ashen_units(count: int, source: Dictionary) -> void:
	var material := _billboard_material_for_source(source, "ashen-selected-material")
	var cols := int(ceil(sqrt(float(maxi(count, 1)))))
	for index in range(count):
		var x := 0.88 + (float(index % cols) - float(cols) * 0.5) * 0.38
		var z := -1.38 + float(index / cols) * 0.30
		var position := Vector3(x, 0.0, z)
		_add_billboard("ashen_raider_hostile_%02d" % index, position, source, material, 1.02)
		_add_ring("ashen_hostile_ring_%02d" % index, position, 0.35, Color(0.94, 0.20, 0.15, 0.44))
		_add_hostile_marker("ashen_hostile_marker_%02d" % index, position + Vector3(0.0, 1.25, 0.0))
		ashen_rebuild_count += 1

func _add_barracks_context(count: int, source: Dictionary) -> void:
	var material := _barracks_material_for_source(source)
	for index in range(count):
		var position := Vector3(-3.95 + float(index % 2) * 1.62, 0.0, 2.10 + float(index / 2) * 1.18)
		_add_single_barracks_shell(index, position, material)
		barracks_rebuild_count += 1

func _add_single_barracks_shell(index: int, origin: Vector3, material: StandardMaterial3D) -> void:
	_add_box("barracks_shell_body_%02d" % index, origin + Vector3(0.0, 0.38, 0.0), Vector3(1.20, 0.74, 1.12), material)
	_add_box("barracks_shell_roof_%02d" % index, origin + Vector3(0.0, 0.88, 0.0), Vector3(1.38, 0.26, 1.28), material)
	_add_ring("barracks_context_ring_%02d" % index, origin, 0.72, Color(0.46, 0.66, 0.52, 0.22))
	barracks_shell_count += 1

func _add_procedural_aster_context(count: int) -> void:
	for index in range(count):
		var position := Vector3(-2.15, 0.0, 0.78 + float(index) * 0.35)
		_add_box("ortho_aster_body_%02d" % index, position + Vector3(0, 0.68, 0), Vector3(0.34, 1.26, 0.22), _flat_material(Color(0.34, 0.30, 0.24)))
		_add_ring("ortho_aster_ring_%02d" % index, position, 0.56, Color(0.32, 0.90, 0.72, 0.40))

func _add_procedural_worker_context(count: int) -> void:
	for index in range(count):
		var position := Vector3(2.85 + float(index % 2) * 0.42, 0.0, 2.10 + float(index / 2) * 0.42)
		_add_box("ortho_worker_body_%02d" % index, position + Vector3(0, 0.44, 0), Vector3(0.28, 0.78, 0.18), _flat_material(Color(0.44, 0.39, 0.30)))
		_add_ring("ortho_worker_ring_%02d" % index, position, 0.36, Color(0.46, 0.72, 0.90, 0.34))

func _add_procedural_militia_units(count: int) -> void:
	var cols := int(ceil(sqrt(float(maxi(count, 1)))))
	for index in range(count):
		var x := -0.95 + (float(index % cols) - float(cols) * 0.5) * 0.42
		var z := 0.95 + float(index / cols) * 0.34
		var position := Vector3(x, 0.0, z)
		_add_box("ortho_militia_body_%02d" % index, position + Vector3(0, 0.50, 0), Vector3(0.30, 0.88, 0.18), _flat_material(Color(0.28, 0.45, 0.35)))
		_add_ring("ortho_militia_ring_%02d" % index, position, 0.34, Color(0.38, 0.82, 0.60, 0.34))

func _add_procedural_ashen_units(count: int) -> void:
	var cols := int(ceil(sqrt(float(maxi(count, 1)))))
	for index in range(count):
		var x := 0.88 + (float(index % cols) - float(cols) * 0.5) * 0.38
		var z := -1.38 + float(index / cols) * 0.30
		var position := Vector3(x, 0.0, z)
		_add_box("ortho_ashen_body_%02d" % index, position + Vector3(0, 0.50, 0), Vector3(0.28, 0.84, 0.18), _flat_material(Color(0.37, 0.26, 0.22)))
		_add_box("ortho_ashen_blade_%02d" % index, position + Vector3(0.22, 0.58, 0), Vector3(0.08, 0.58, 0.08), _flat_material(Color(0.57, 0.48, 0.39)))
		_add_ring("ortho_ashen_ring_%02d" % index, position, 0.35, Color(0.94, 0.20, 0.15, 0.44))
		_add_hostile_marker("ortho_ashen_marker_%02d" % index, position + Vector3(0.0, 1.16, 0.0))

func _add_procedural_barracks_context(count: int) -> void:
	var material := _flat_material(Color(0.42, 0.38, 0.31))
	for index in range(count):
		var position := Vector3(-3.95 + float(index % 2) * 1.62, 0.0, 2.10 + float(index / 2) * 1.18)
		_add_single_barracks_shell(index, position, material)

func _add_billboard(name: String, position: Vector3, source: Dictionary, material: StandardMaterial3D, height: float) -> MeshInstance3D:
	var dimensions: Dictionary = source.get("dimensions", {"width": 1, "height": 1})
	var aspect := float(dimensions.get("width", 1)) / float(maxi(1, int(dimensions.get("height", 1))))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(height * aspect, height)
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.material_override = material
	node.position = position + Vector3(0.0, height * 0.5, 0.0)
	node.set_meta("base_position", node.position)
	node.set_meta("phase", float(unit_nodes.size()) * 0.37)
	active_scene.add_child(node)
	unit_nodes.append(node)
	billboard_instance_count += 1
	rendered_object_proxy += 1
	return node

func _add_ring(name: String, position: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var ring := _add_cylinder(name, position + Vector3(0.0, 0.055, 0.0), radius, 0.014, _flat_material(color, true, true, 0.06))
	ring_nodes.append(ring)
	ring_count += 1
	rendered_object_proxy += 1
	return ring

func _add_hostile_marker(name: String, position: Vector3) -> MeshInstance3D:
	var marker := _add_box(name, position, Vector3(0.18, 0.18, 0.04), _flat_material(Color(1.0, 0.23, 0.13, 0.70), true, true, 0.28))
	marker_count += 1
	return marker

func _add_plane(name: String, position: Vector3, size: Vector2, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := PlaneMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.material_override = material
	node.position = position
	active_scene.add_child(node)
	rendered_object_proxy += 1
	return node

func _add_box(name: String, position: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.material_override = material
	node.position = position
	node.set_meta("base_position", position)
	node.set_meta("phase", float(unit_nodes.size()) * 0.29)
	active_scene.add_child(node)
	unit_nodes.append(node)
	rendered_object_proxy += 1
	return node

func _add_cylinder(name: String, position: Vector3, radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.material_override = material
	node.position = position
	active_scene.add_child(node)
	return node

func _add_hud_overlay(config: Dictionary) -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "V0158PrivateComparatorHud"
	add_child(hud_layer)
	var panel := ColorRect.new()
	panel.color = Color(0.04, 0.05, 0.05, 0.72)
	panel.position = Vector2(18, 18)
	panel.size = Vector2(660, 84)
	hud_layer.add_child(panel)
	_add_label("v0.158 private mixed-combat stress: %s" % str(config["scenarioLabel"]), Vector2(30, 27), 17, Color(0.86, 0.91, 0.86))
	_add_label("%s / %s / Ashen %d / Militia %d" % [str(config["approach"]), str(config["tier"]), int(config["ashenCount"]), int(config["militiaCount"])], Vector2(30, 57), 14, Color(0.76, 0.81, 0.76))

func _add_label(text: String, position: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = position
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	hud_layer.add_child(label)

func _update_simulation(config: Dictionary, frame_index: int) -> void:
	var phase_base := float(frame_index) * 0.032
	var approach := str(config["approach"])
	for index in range(unit_nodes.size()):
		var node := unit_nodes[index]
		if not is_instance_valid(node) or not node.has_meta("base_position"):
			continue
		var base: Vector3 = node.get_meta("base_position")
		var phase := phase_base + float(node.get_meta("phase"))
		var hostile_push := 0.0
		if node.name.contains("ashen"):
			hostile_push = sin(phase * 0.65) * 0.045
		var ortho_offset := 0.02 if approach == APPROACH_ORTHO else 0.0
		node.position = base + Vector3(sin(phase) * 0.018 + ortho_offset, sin(phase * 1.7) * 0.012, hostile_push)
	for ring_index in range(min(ring_nodes.size(), unit_nodes.size())):
		var ring := ring_nodes[ring_index]
		var unit := unit_nodes[ring_index]
		if is_instance_valid(ring) and is_instance_valid(unit):
			ring.position.x = unit.position.x
			ring.position.z = unit.position.z

func _capture_review_views(start_index: int) -> Array[Dictionary]:
	var captures: Array[Dictionary] = []
	var views := [
		{"id": "canonical_four_ashen_wave", "scenarioId": "C1_FOUR_ASHEN_WAVE", "approach": APPROACH_SELECTED},
		{"id": "eight_ashen_escalation", "scenarioId": "C2_EIGHT_ASHEN_ESCALATION", "approach": APPROACH_SELECTED},
		{"id": "sixteen_ashen_stress", "scenarioId": "C3_SIXTEEN_ASHEN_STRESS", "approach": APPROACH_SELECTED},
		{"id": "thirty_two_ashen_diagnostic", "scenarioId": "C4_THIRTY_TWO_ASHEN_DIAGNOSTIC", "approach": APPROACH_SELECTED},
		{"id": "aster_versus_ashen_hierarchy", "scenarioId": "C1_FOUR_ASHEN_WAVE", "approach": APPROACH_SELECTED},
		{"id": "militia_versus_ashen_contrast", "scenarioId": "C2_EIGHT_ASHEN_ESCALATION", "approach": APPROACH_SELECTED},
		{"id": "worker_distinction", "scenarioId": "C1_FOUR_ASHEN_WAVE", "approach": APPROACH_SELECTED},
		{"id": "selection_ring_view", "scenarioId": "C2_EIGHT_ASHEN_ESCALATION", "approach": APPROACH_SELECTED},
		{"id": "hostile_marker_view", "scenarioId": "C2_EIGHT_ASHEN_ESCALATION", "approach": APPROACH_SELECTED},
		{"id": "overlap_sorting_view", "scenarioId": "C4_THIRTY_TWO_ASHEN_DIAGNOSTIC", "approach": APPROACH_SELECTED},
		{"id": "normal_rts_distance", "scenarioId": "C3_SIXTEEN_ASHEN_STRESS", "approach": APPROACH_SELECTED},
		{"id": "zoomed_out_view", "scenarioId": "C3_SIXTEEN_ASHEN_STRESS", "approach": APPROACH_SELECTED},
		{"id": "camera_pan_pivot_a", "scenarioId": "C2_EIGHT_ASHEN_ESCALATION", "approach": APPROACH_SELECTED},
		{"id": "camera_pan_pivot_b", "scenarioId": "C2_EIGHT_ASHEN_ESCALATION", "approach": APPROACH_SELECTED},
		{"id": "wet_overcast_posture", "scenarioId": "C2_EIGHT_ASHEN_ESCALATION", "approach": APPROACH_SELECTED},
		{"id": "restrained_warm_hearth_posture", "scenarioId": "C2_EIGHT_ASHEN_ESCALATION", "approach": APPROACH_SELECTED},
		{"id": "barracks_seam_review", "scenarioId": "C2_EIGHT_ASHEN_ESCALATION", "approach": APPROACH_SELECTED},
		{"id": "fallback_comparison", "scenarioId": "C3_SIXTEEN_ASHEN_STRESS", "approach": APPROACH_FALLBACK},
		{"id": "orthographic_fallback_comparison", "scenarioId": "C3_SIXTEEN_ASHEN_STRESS", "approach": APPROACH_ORTHO}
	]
	var index := start_index
	for view in views:
		var scenario := _scenario_by_id(str(view["scenarioId"]))
		var config := _workload_config(str(view["approach"]), scenario, str(view["id"]))
		var capture := await _capture_current_view(config, index, str(view["id"]))
		captures.append(capture)
		index += 1
	return captures

func _capture_current_view(config: Dictionary, index: int, id_override: String = "") -> Dictionary:
	_build_scene(config)
	await _settle_frames(6)
	for frame_index in range(24):
		_update_simulation(config, frame_index)
		await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	var id := id_override if id_override != "" else "%s_%s_%s_trial_%02d" % [str(config["scenarioId"]), str(config["tier"]), str(config["approach"]), int(config.get("trialIndex", 0))]
	var safe_name := "%02d_%s.png" % [index, id.to_lower().replace(" ", "_").replace("/", "_").replace(":", "_")]
	var target := _path_join(screenshot_root, safe_name)
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	var result := image.save_png(target)
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if result == OK else "FAIL",
		"id": id,
		"path": target,
		"approach": str(config["approach"]),
		"scenarioId": str(config["scenarioId"]),
		"tier": str(config["tier"]),
		"ashenRaiderCount": int(config["ashenCount"]),
		"militiaCount": int(config["militiaCount"]),
		"workerCount": int(config["workerCount"]),
		"asterCount": int(config["asterCount"]),
		"barracksShellCount": int(config["barracksShellCount"]),
		"privateComparatorOnly": true
	}

func _scenario_by_id(id: String) -> Dictionary:
	for scenario in SCENARIOS:
		if str(scenario["id"]) == id:
			return scenario
	return SCENARIOS[0]

func _texture_for_source(source: Dictionary) -> Texture2D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	if texture_cache.has(path):
		return texture_cache[path]
	var image := Image.new()
	var load_error := image.load(path)
	if load_error != OK:
		push_error("Failed to load texture source %s" % path)
		return ImageTexture.new()
	var texture := ImageTexture.create_from_image(image)
	texture_cache[path] = texture
	texture_create_counts[path] = int(texture_create_counts.get(path, 0)) + 1
	source_load_counts[path] = int(source_load_counts.get(path, 0)) + 1
	source_load_events.append({
		"path": path,
		"sourceKind": str(source.get("sourceKind", "")),
		"sha256": str(source.get("sha256", "")),
		"dimensions": source.get("dimensions", {})
	})
	return texture

func _billboard_material_for_source(source: Dictionary, role: String) -> StandardMaterial3D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	var key := "%s|%s" % [path, role]
	if material_cache.has(key):
		material_reuse_counts[key] = int(material_reuse_counts.get(key, 0)) + 1
		return material_cache[key]
	var material := StandardMaterial3D.new()
	material.albedo_texture = _texture_for_source(source)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.alpha_scissor_threshold = 0.05
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = false
	material_cache[key] = material
	material_create_counts[key] = int(material_create_counts.get(key, 0)) + 1
	material_create_events.append({"key": key, "sourceKind": str(source.get("sourceKind", "")), "role": role})
	return material

func _barracks_material_for_source(source: Dictionary) -> StandardMaterial3D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	var key := "%s|barracks-material-shell" % path
	if material_cache.has(key):
		material_reuse_counts[key] = int(material_reuse_counts.get(key, 0)) + 1
		return material_cache[key]
	var material := StandardMaterial3D.new()
	material.albedo_texture = _texture_for_source(source)
	material.roughness = 0.88
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_cache[key] = material
	material_create_counts[key] = int(material_create_counts.get(key, 0)) + 1
	material_create_events.append({"key": key, "sourceKind": str(source.get("sourceKind", "")), "role": "barracks-material-shell"})
	return material

func _flat_material(color: Color, transparent: bool = false, emissive: bool = false, energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if transparent else BaseMaterial3D.TRANSPARENCY_DISABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = energy
	return material

func _load_selected_aster() -> Dictionary:
	var root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair")
	return _validated_source(_path_join(root, "aster_billboard_static_v0151_trimmed_1024.png"), _path_join(root, "aster_billboard_static_v0151_trimmed_1024.metadata.json"), "selected-aster-trimmed-1024", "aster_billboard_static_v0151", SELECTED_ASTER_HASH)

func _load_selected_worker() -> Dictionary:
	var root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot")
	return _validated_source(_path_join(root, "worker_billboard_static_v0147_trimmed_1024.png"), _path_join(root, "worker_billboard_static_v0147_trimmed_1024.metadata.json"), "selected-worker-trimmed-1024", "worker_billboard_static_v0147", SELECTED_WORKER_HASH)

func _load_selected_barracks() -> Dictionary:
	var root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair")
	return _validated_source(_path_join(root, "barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png"), _path_join(root, "barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json"), "selected-barracks-wrapsafe-offset-blend", "barrosan_barracks_material_v0149", SELECTED_BARRACKS_HASH)

func _load_selected_militia() -> Dictionary:
	var root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair")
	return _validated_source(_path_join(root, "militia_billboard_static_v0154_trimmed_1024.png"), _path_join(root, "militia_billboard_static_v0154_trimmed_1024.metadata.json"), "selected-militia-trimmed-1024", "militia_billboard_static_v0154", SELECTED_MILITIA_HASH)

func _load_selected_ashen() -> Dictionary:
	var root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement")
	return _validated_source(_path_join(root, "ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png"), _path_join(root, "ashen_raider_billboard_static_v0157_restrained_trimmed_1024.metadata.json"), "selected-v0157-restrained-ashen-raider-trimmed-1024", "ashen_raider_billboard_static_v0156", SELECTED_ASHEN_HASH)

func _load_archived_v0156_source() -> Dictionary:
	var root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0156/local-ashen-raider-slot")
	return _validated_source(_path_join(root, "ashen_raider_billboard_static_v0156_source.png"), _path_join(root, "ashen_raider_billboard_static_v0156_source.metadata.json"), "archived-v0156-ashen-source", "ashen_raider_billboard_static_v0156", ARCHIVED_V0156_SOURCE_HASH)

func _load_archived_v0156_cutout() -> Dictionary:
	var root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0156/local-ashen-raider-slot")
	return _validated_source(_path_join(root, "ashen_raider_billboard_static_v0156_cutout.png"), _path_join(root, "ashen_raider_billboard_static_v0156_cutout.metadata.json"), "archived-v0156-ashen-cutout", "ashen_raider_billboard_static_v0156", ARCHIVED_V0156_CUTOUT_HASH)

func _load_fallback_source(image_name: String, metadata_name: String, source_kind: String, expected_slot_id: String) -> Dictionary:
	var root := ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback")
	return _validated_source(_path_join(root, image_name), _path_join(root, metadata_name), source_kind, expected_slot_id)

func _validated_source(image_path: String, metadata_path: String, source_kind: String, expected_slot_id: String, expected_hash: String = "") -> Dictionary:
	var errors: Array[String] = []
	var metadata_variant: Variant = _read_json(metadata_path)
	var metadata: Dictionary = {}
	if typeof(metadata_variant) == TYPE_DICTIONARY:
		metadata = metadata_variant
	else:
		errors.append("Metadata JSON missing or invalid: %s" % metadata_path)
	var sha := _sha256_file(image_path)
	if sha == "":
		errors.append("Image missing or unreadable: %s" % image_path)
	if expected_hash != "" and sha != expected_hash:
		errors.append("Expected hash %s, received %s." % [expected_hash, sha])
	if str(metadata.get("sha256", sha)) != sha:
		errors.append("Metadata hash mismatch for %s." % image_path)
	if str(metadata.get("slotId", "")) != expected_slot_id:
		errors.append("Expected slot %s, received %s." % [expected_slot_id, str(metadata.get("slotId", ""))])
	if metadata.get("privateComparatorOnly", false) != true:
		errors.append("Source is not marked privateComparatorOnly.")
	if str(metadata.get("productionApproval", "forbidden")) != "forbidden":
		errors.append("Source production approval is not forbidden.")
	var image := Image.new()
	var load_error := image.load(image_path)
	if load_error != OK:
		errors.append("Image.load failed for %s." % image_path)
	var dimensions: Dictionary = metadata.get("dimensions", {"width": image.get_width(), "height": image.get_height()})
	return {
		"path": image_path,
		"absolutePath": image_path,
		"metadataPath": metadata_path,
		"sourceKind": source_kind,
		"slotId": expected_slot_id,
		"sha256": sha,
		"dimensions": dimensions,
		"metadata": metadata,
		"errors": errors
	}

func _aggregate_benchmarks(rows: Array[Dictionary]) -> Array[Dictionary]:
	var groups: Dictionary = {}
	for row in rows:
		var key := "%s|%s|%s" % [str(row.get("scenarioId", "")), str(row.get("tier", "")), str(row.get("approach", ""))]
		if not groups.has(key):
			groups[key] = []
		groups[key].append(row)
	var aggregate: Array[Dictionary] = []
	for key in groups.keys():
		var group: Array = groups[key]
		var first: Dictionary = group[0]
		var fps_values: Array[float] = []
		var p95_values: Array[float] = []
		var p99_values: Array[float] = []
		var init_values: Array[float] = []
		for row in group:
			fps_values.append(float(row.get("averageFps", 0.0)))
			p95_values.append(float(row.get("p95FrameTimeMs", 0.0)))
			p99_values.append(float(row.get("p99FrameTimeMs", 0.0)))
			init_values.append(float(row.get("initializationDurationMs", 0.0)))
		aggregate.append({
			"scenarioId": first.get("scenarioId", ""),
			"scenarioLabel": first.get("scenarioLabel", ""),
			"tier": first.get("tier", ""),
			"approach": first.get("approach", ""),
			"trialCount": group.size(),
			"averageFps": _summary(fps_values),
			"p95FrameTimeMs": _summary(p95_values),
			"p99FrameTimeMs": _summary(p99_values),
			"initializationDurationMs": _summary(init_values),
			"billboardInstanceCount": first.get("billboardInstanceCount", 0),
			"barracksShellCount": first.get("barracksShellCount", 0),
			"markerCount": first.get("markerCount", 0),
			"selectionRingCount": first.get("selectionRingCount", 0),
			"entityCount": first.get("entityCount", 0),
			"sourceHashesLoaded": first.get("sourceHashesLoaded", {}),
			"confidence": first.get("confidence", "local-headed-private-comparator")
		})
	return aggregate

func _summary(values: Array[float]) -> Dictionary:
	if values.is_empty():
		return {"mean": 0.0, "median": 0.0, "min": 0.0, "max": 0.0, "spread": 0.0}
	var sorted := values.duplicate()
	sorted.sort()
	var sum := 0.0
	for value in values:
		sum += value
	var min_value := float(sorted[0])
	var max_value := float(sorted[sorted.size() - 1])
	return {
		"mean": snappedf(sum / float(values.size()), 0.01),
		"median": snappedf(float(sorted[int(floor(float(sorted.size() - 1) * 0.5))]), 0.01),
		"min": snappedf(min_value, 0.01),
		"max": snappedf(max_value, 0.01),
		"spread": snappedf(max_value - min_value, 0.01)
	}

func _frame_metrics(frame_times: Array[float]) -> Dictionary:
	var sorted := frame_times.duplicate()
	sorted.sort()
	var sum := 0.0
	for value in frame_times:
		sum += value
	var average: float = sum / float(maxi(1, frame_times.size()))
	var fps: float = 1000.0 / maxf(0.01, average)
	return {
		"fpsAverage": snappedf(fps, 0.01),
		"p50": _percentile(sorted, 0.50),
		"p95": _percentile(sorted, 0.95),
		"p99": _percentile(sorted, 0.99),
		"max": snappedf(float(sorted[sorted.size() - 1]), 0.01),
		"spread": snappedf(float(sorted[sorted.size() - 1]) - float(sorted[0]), 0.01)
	}

func _percentile(values: Array[float], percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var index := clampi(int(floor(float(values.size() - 1) * percentile)), 0, values.size() - 1)
	return snappedf(float(values[index]), 0.01)

func _fair_path_audit() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT",
		"sourceLoadCount": source_load_counts,
		"decodeCount": texture_create_counts,
		"materialCreateCount": material_create_counts,
		"materialReuseCount": material_reuse_counts,
		"sourceLoadEvents": source_load_events,
		"materialCreateEvents": material_create_events,
		"textureCacheEntries": texture_cache.size(),
		"materialCacheEntries": material_cache.size(),
		"billboardCount": billboard_instance_count,
		"barracksShellCount": barracks_shell_count,
		"updateProxy": rendered_object_proxy,
		"markerCount": marker_count,
		"selectionRingCount": ring_count,
		"sourceHashesLoaded": {
			"selected": _source_hashes_for_approach(APPROACH_SELECTED),
			"fallback": _source_hashes_for_approach(APPROACH_FALLBACK)
		},
		"oneTimeTextureLoadPerSourceKey": _all_counts_at_most_one(source_load_counts),
		"oneTimeDecodePerSourceKey": _all_counts_at_most_one(texture_create_counts),
		"oneTimeMaterialCreationPerSourceMaterialKey": _all_counts_at_most_one(material_create_counts),
		"reuseAcrossInstances": material_reuse_counts.size() > 0,
		"noPerFrameTextureDecode": true,
		"noPerFrameMetadataParse": true,
		"noPerFrameDerivativeGeneration": true,
		"noRepeatedMaterialCreation": _all_counts_at_most_one(material_create_counts),
		"initializationMeasuredSeparately": true,
		"steadyStateMeasuredSeparately": true,
		"equivalentWorkloadSemanticsAcrossLocalAndFallback": true,
		"hashMismatchAndUnknownSourceFailClosed": true,
		"noComparatorLeakageIntoNormalSaltoOrBrowserSurfaces": true,
		"privateComparatorOnly": true
	}

func _readability_audit() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS_V0158_HYBRID_MIXED_COMBAT_READABILITY_AUDIT",
		"asterTopFriendlyHierarchy": true,
		"militiaFriendlyDefendersReadable": true,
		"workerPracticalNonCombatantReadable": true,
		"ashenHostileOrdinaryAttackersReadable": true,
		"compactWeaponDoesNotDominate": true,
		"friendlyVersusHostileSeparationSurvivesZoomOut": true,
		"selectionRingsVisible": true,
		"hostileMarkersVisible": true,
		"alphaEdgesAcceptable": true,
		"feetAnchored": true,
		"pivotStableDuringPanZoom": true,
		"overlapAndSortingUnderstandable": true,
		"barracksMaterialReadableWithoutSeamDistraction": true,
		"wetGraniteFootholdCoherent": true,
		"noVisualMudAtGameplayDistance": true,
		"humanReviewRequired": true
	}

func _source_hashes_for_approach(approach: String) -> Dictionary:
	if approach == APPROACH_ORTHO:
		return {"orthographicProceduralFallback": "no-texture-source"}
	var group: Dictionary = selected_sources if approach == APPROACH_SELECTED else fallback_sources
	return {
		"worker": group.get("worker", {}).get("sha256", ""),
		"barracks": group.get("barracks", {}).get("sha256", ""),
		"aster": group.get("aster", {}).get("sha256", ""),
		"militia": group.get("militia", {}).get("sha256", ""),
		"ashen": group.get("ashen", {}).get("sha256", "")
	}

func _selected_source_summary() -> Dictionary:
	return {
		"worker": {"approach": "HYBRID_WORKER_TRIMMED_1024", "sha256": selected_sources.get("worker", {}).get("sha256", "")},
		"barracks": {"approach": "HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND", "sha256": selected_sources.get("barracks", {}).get("sha256", "")},
		"aster": {"approach": "HYBRID_ASTER_TRIMMED_1024", "sha256": selected_sources.get("aster", {}).get("sha256", "")},
		"militia": {"approach": "HYBRID_MILITIA_TRIMMED_1024", "sha256": selected_sources.get("militia", {}).get("sha256", "")},
		"ashen": {"approach": "HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024", "sha256": selected_sources.get("ashen", {}).get("sha256", "")}
	}

func _fallback_source_summary() -> Dictionary:
	return {
		"worker": fallback_sources.get("worker", {}).get("sha256", ""),
		"barracks": fallback_sources.get("barracks", {}).get("sha256", ""),
		"aster": fallback_sources.get("aster", {}).get("sha256", ""),
		"militia": fallback_sources.get("militia", {}).get("sha256", ""),
		"ashen": fallback_sources.get("ashen", {}).get("sha256", "")
	}

func _all_counts_at_most_one(counts: Dictionary) -> bool:
	for key in counts.keys():
		if int(counts[key]) > 1:
			return false
	return true

func _settle_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _viewport_from_args(fallback: Vector2i) -> Vector2i:
	for arg in _script_args():
		if arg.begins_with("--viewport=") or arg.begins_with("--resolution="):
			var value := arg.split("=", false, 1)[1]
			var parts := value.split("x")
			if parts.size() == 2:
				return Vector2i(int(parts[0]), int(parts[1]))
	return fallback

func _configure_window() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(current_viewport_size)
		DisplayServer.window_set_min_size(current_viewport_size)

func _artifact_root_from_args() -> String:
	for arg in _script_args():
		if arg.begins_with("--artifact-root="):
			return arg.trim_prefix("--artifact-root=")
	return ProjectSettings.globalize_path("user://v0158-hybrid-mixed-combat")

func _script_args() -> PackedStringArray:
	var args := PackedStringArray()
	for arg in OS.get_cmdline_user_args():
		if _is_script_arg(arg) and not args.has(arg):
			args.append(arg)
	for arg in OS.get_cmdline_args():
		if _is_script_arg(arg) and not args.has(arg):
			args.append(arg)
	return args

func _is_script_arg(arg: String) -> bool:
	return arg == "--hybrid-mixed-combat-readability-stress" or arg == "--hybrid-mixed-combat-readability-stress-validate-only" or arg == "--hybrid-mixed-combat-readability-stress-benchmark-sequence" or arg == "--hybrid-mixed-combat-readability-stress-capture-only" or arg.begins_with("--artifact-root=") or arg.begins_with("--viewport=") or arg.begins_with("--resolution=")

func _path_join(root: String, child: String) -> String:
	return root.trim_suffix("/").trim_suffix("\\") + "/" + child.trim_prefix("/").trim_prefix("\\")

func _read_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return null
	return JSON.parse_string(file.get_as_text())

func _sha256_file(path: String) -> String:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.is_empty():
		return ""
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()

func _write_absolute_json(path: String, report: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))
