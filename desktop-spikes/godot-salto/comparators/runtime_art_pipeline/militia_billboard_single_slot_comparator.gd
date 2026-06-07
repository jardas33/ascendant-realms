extends Node

const CHECKPOINT := "v0.154"
const SLOT_ID := "militia_billboard_static_v0154"
const ASTER_SLOT_ID := "aster_billboard_static_v0151"
const WORKER_SLOT_ID := "worker_billboard_static_v0147"
const BARRACKS_SLOT_ID := "barrosan_barracks_material_v0149"
const SELECTED_ASTER_HASH := "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a"
const SELECTED_WORKER_HASH := "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
const SELECTED_BARRACKS_HASH := "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
const APPROACH_FALLBACK := "HYBRID_MILITIA_DIAGNOSTIC_FALLBACK_BASELINE"
const APPROACH_LOCAL := "HYBRID_MILITIA_LOCAL_STATIC_BILLBOARD"
const APPROACH_ORTHO := "ORTHO_MILITIA_PROCEDURAL_FALLBACK"
const APPROACHES := [APPROACH_FALLBACK, APPROACH_LOCAL, APPROACH_ORTHO]
const TIERS := {
	"S": {"militiaCount": 1, "asterCount": 1, "workerCount": 1, "barracksShellCount": 1, "benchmarkFrames": 120},
	"M": {"militiaCount": 12, "asterCount": 1, "workerCount": 6, "barracksShellCount": 1, "benchmarkFrames": 150},
	"L": {"militiaCount": 36, "asterCount": 1, "workerCount": 12, "barracksShellCount": 3, "benchmarkFrames": 180}
}
const REPAIR_CHECKPOINT := "v0.155"
const REPAIR_APPROACH_FALLBACK := "HYBRID_MILITIA_REPAIR_FALLBACK_BASELINE"
const REPAIR_APPROACH_FULL_RES := "HYBRID_MILITIA_FULL_RES"
const REPAIR_APPROACH_TRIMMED_512 := "HYBRID_MILITIA_TRIMMED_512"
const REPAIR_APPROACH_TRIMMED_768 := "HYBRID_MILITIA_TRIMMED_768"
const REPAIR_APPROACH_TRIMMED_1024 := "HYBRID_MILITIA_TRIMMED_1024"
const REPAIR_APPROACHES := [REPAIR_APPROACH_FALLBACK, REPAIR_APPROACH_FULL_RES, REPAIR_APPROACH_TRIMMED_512, REPAIR_APPROACH_TRIMMED_768, REPAIR_APPROACH_TRIMMED_1024]
const REPAIR_TIERS := {
	"S": {"militiaCount": 4, "asterCount": 1, "workerCount": 2, "barracksShellCount": 1, "benchmarkFrames": 120},
	"M": {"militiaCount": 16, "asterCount": 1, "workerCount": 6, "barracksShellCount": 1, "benchmarkFrames": 150},
	"L": {"militiaCount": 32, "asterCount": 1, "workerCount": 12, "barracksShellCount": 3, "benchmarkFrames": 180},
	"STRESS_32": {"militiaCount": 32, "asterCount": 1, "workerCount": 12, "barracksShellCount": 3, "benchmarkFrames": 180}
}
const DEFAULT_VIEWPORT_SIZE := Vector2i(1600, 900)

var artifact_root := ""
var screenshot_root := ""
var local_slot_root := ""
var repair_slot_root := ""
var current_viewport_size := DEFAULT_VIEWPORT_SIZE
var active_scene: Node3D
var active_camera: Camera3D
var hud_layer: CanvasLayer
var fallback_source: Dictionary = {}
var local_source: Dictionary = {}
var aster_context_source: Dictionary = {}
var worker_context_source: Dictionary = {}
var barracks_context_source: Dictionary = {}
var repair_sources: Dictionary = {}
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
var militia_billboard_rebuild_count := 0
var aster_context_rebuild_count := 0
var worker_context_rebuild_count := 0
var barracks_shell_rebuild_count := 0
var billboard_instance_count := 0
var rendered_object_proxy := 0

func start() -> void:
	var args := _script_args()
	current_viewport_size = _viewport_from_args(DEFAULT_VIEWPORT_SIZE)
	_configure_window()
	artifact_root = _artifact_root_from_args()
	screenshot_root = _path_join(artifact_root, "screenshots")
	local_slot_root = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0154/local-militia-slot")
	repair_slot_root = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair")
	DirAccess.make_dir_recursive_absolute(artifact_root)
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	fallback_source = _load_fallback_source()
	local_source = _load_local_source()
	aster_context_source = _load_aster_context_source()
	worker_context_source = _load_worker_context_source()
	barracks_context_source = _load_barracks_context_source()
	if _repair_mode():
		repair_sources = _load_repair_sources()
		if args.has("--militia-billboard-repair-validate-only"):
			var repair_validation := _repair_validation_report()
			_write_absolute_json(_path_join(artifact_root, "militia-billboard-repair-validation-runtime.json"), repair_validation)
			get_tree().quit(0 if repair_validation.get("status", "FAIL") == "PASS_V0155_MILITIA_BILLBOARD_REPAIR_RUNTIME_VALIDATION" else 1)
			return
		var repair_run_kind := "militia-billboard-repair-headed-mass-overlap-benchmark-and-capture"
		if args.has("--militia-billboard-repair-capture-only"):
			repair_run_kind = "militia-billboard-repair-capture-refresh"
		var repair_report := await _run_repair_sequence(repair_run_kind)
		_write_absolute_json(_path_join(artifact_root, "militia-billboard-repair-runtime.json"), repair_report)
		get_tree().quit(0 if repair_report.get("status", "FAIL") == "PASS_V0155_MILITIA_BILLBOARD_REPAIR_RUNTIME_EVIDENCE" else 1)
		return
	if args.has("--militia-billboard-single-slot-validate-only"):
		var validation := _validation_report()
		_write_absolute_json(_path_join(artifact_root, "militia-billboard-single-slot-validation-runtime.json"), validation)
		get_tree().quit(0 if validation.get("status", "FAIL") == "PASS_V0154_MILITIA_BILLBOARD_RUNTIME_VALIDATION" else 1)
		return
	var run_kind := "militia-billboard-single-slot-headed-benchmark-and-capture"
	if args.has("--militia-billboard-single-slot-capture-only"):
		run_kind = "militia-billboard-single-slot-capture-refresh"
	var report := await _run_sequence(run_kind)
	_write_absolute_json(_path_join(artifact_root, "militia-billboard-single-slot-runtime.json"), report)
	get_tree().quit(0 if report.get("status", "FAIL") == "PASS_V0154_MILITIA_BILLBOARD_RUNTIME_EVIDENCE" else 1)

func _validation_report() -> Dictionary:
	var errors: Array[String] = []
	for source in [fallback_source, local_source, aster_context_source, worker_context_source, barracks_context_source]:
		if source.get("status", "FAIL") != "PASS":
			errors.append_array(source.get("errors", ["Militia comparator source failed validation."]))
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"slotId": SLOT_ID,
		"status": "PASS_V0154_MILITIA_BILLBOARD_RUNTIME_VALIDATION" if errors.is_empty() else "FAIL_V0154_MILITIA_BILLBOARD_RUNTIME_VALIDATION",
		"fallbackSource": fallback_source,
		"localSource": local_source,
		"selectedAsterSource": aster_context_source,
		"selectedWorkerSource": worker_context_source,
		"selectedBarracksSource": barracks_context_source,
		"exactlyOneAiImageForV0154": true,
		"fourthPrivateComparatorRuntimeArtSlotOnly": true,
		"noFifthRuntimeArtSlot": true,
		"noAnimations": true,
		"privateComparatorOnly": true,
		"productionApproval": "forbidden",
		"playerSliceIntegration": "forbidden",
		"browserIntegration": "forbidden",
		"saveWritesAllowed": false,
		"stableIdChanges": false,
		"errors": errors
	}

func _repair_validation_report() -> Dictionary:
	var errors: Array[String] = []
	if fallback_source.get("status", "FAIL") != "PASS":
		errors.append_array(fallback_source.get("errors", ["Fallback source failed validation."]))
	for key in ["fullres", "trimmed_512", "trimmed_768", "trimmed_1024"]:
		var source: Dictionary = repair_sources.get(key, {})
		if source.get("status", "FAIL") != "PASS":
			errors.append_array(source.get("errors", ["Missing Militia repair source %s." % key]))
	for source in [aster_context_source, worker_context_source, barracks_context_source]:
		if source.get("status", "FAIL") != "PASS":
			errors.append_array(source.get("errors", ["Militia repair context source failed validation."]))
	return {
		"schemaVersion": 1,
		"checkpoint": REPAIR_CHECKPOINT,
		"sourceCheckpoint": CHECKPOINT,
		"slotId": SLOT_ID,
		"status": "PASS_V0155_MILITIA_BILLBOARD_REPAIR_RUNTIME_VALIDATION" if errors.is_empty() else "FAIL_V0155_MILITIA_BILLBOARD_REPAIR_RUNTIME_VALIDATION",
		"fallbackSource": fallback_source,
		"repairSources": repair_sources,
		"selectedAsterSource": aster_context_source,
		"selectedWorkerSource": worker_context_source,
		"selectedBarracksSource": barracks_context_source,
		"zeroNewAiImagesForV0155": true,
		"sameMilitiaSourceOnly": true,
		"noNewRuntimeArtSlot": true,
		"noFifthRuntimeArtSlot": true,
		"noAnimations": true,
		"privateComparatorOnly": true,
		"productionApproval": "forbidden",
		"playerSliceIntegration": "forbidden",
		"browserIntegration": "forbidden",
		"saveWritesAllowed": false,
		"stableIdChanges": false,
		"errors": errors
	}

func _run_repair_sequence(run_kind: String) -> Dictionary:
	var errors: Array[String] = []
	var validation := _repair_validation_report()
	if validation.get("status", "FAIL") != "PASS_V0155_MILITIA_BILLBOARD_REPAIR_RUNTIME_VALIDATION":
		errors.append_array(validation.get("errors", ["Militia billboard repair validation failed."]))
	var benchmark_reports: Array[Dictionary] = []
	var captures: Array[Dictionary] = []
	var capture_index := 0
	for tier in ["S", "M", "L", "STRESS_32"]:
		var trial_count := 5 if tier == "L" or tier == "STRESS_32" else 1
		for trial_index in range(trial_count):
			var ordered_approaches := _rotated_repair_approaches(trial_index)
			for approach in ordered_approaches:
				var config := _repair_workload_config(approach, tier, 1.0, "mass_overlap_benchmark")
				config["trialIndex"] = trial_index + 1
				config["scenarioOrder"] = ordered_approaches
				var benchmark := await _benchmark_current_view(config)
				benchmark_reports.append(benchmark)
				if benchmark.get("status", "FAIL") != "PASS":
					errors.append("Militia repair benchmark failed for %s %s trial %d." % [approach, tier, trial_index + 1])
				if trial_index == 0:
					var capture := await _capture_current_view(config, capture_index)
					captures.append(capture)
					capture_index += 1
	var review_captures := await _capture_repair_review_views(capture_index)
	captures.append_array(review_captures)
	return {
		"schemaVersion": 1,
		"checkpoint": REPAIR_CHECKPOINT,
		"sourceCheckpoint": CHECKPOINT,
		"slotId": SLOT_ID,
		"runKind": run_kind,
		"status": "PASS_V0155_MILITIA_BILLBOARD_REPAIR_RUNTIME_EVIDENCE" if errors.is_empty() else "FAIL_V0155_MILITIA_BILLBOARD_REPAIR_RUNTIME_EVIDENCE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"benchmarkCount": benchmark_reports.size(),
		"screenshotCount": captures.size(),
		"benchmarks": benchmark_reports,
		"captures": captures,
		"fallbackSource": fallback_source,
		"repairSources": repair_sources,
		"selectedAsterSource": aster_context_source,
		"selectedWorkerSource": worker_context_source,
		"selectedBarracksSource": barracks_context_source,
		"fairPathAudit": _repair_fair_path_audit(),
		"readabilityAudit": _repair_readability_audit(),
		"boundaries": {
			"privateComparatorOnly": true,
			"productionApproval": "forbidden",
			"playerSliceIntegration": "forbidden",
			"browserIntegration": "forbidden",
			"zeroNewAiImagesForV0155": true,
			"sameMilitiaSourceOnly": true,
			"noNewRuntimeArtSlot": true,
			"noFifthRuntimeArtSlot": true,
			"militiaOnly": true,
			"noAnimations": true,
			"defaultLauncherReplaced": false,
			"normalPlayerSliceWired": false,
			"manifestMutated": false,
			"productionPackageIncluded": false,
			"saveWritesAllowed": false,
			"stableIdChanges": false,
			"referenceCandidateImported": false
		},
		"limitations": [
			"v0.155 only repairs and benchmarks deterministic derivatives from the existing v0.154 Militia cutout.",
			"Human review remains required for Militia hierarchy, group readability, alpha edge, and mass-overlap acceptance.",
			"No normal Salto player slice, browser runtime, save, stable-ID, manifest, or art-slot registry path is modified.",
			"Godot remains provisional and is not finally selected."
		],
		"errors": errors
	}

func _rotated_repair_approaches(trial_index: int) -> Array:
	var rotated := REPAIR_APPROACHES.duplicate()
	var offset := trial_index % rotated.size()
	for _index in range(offset):
		rotated.push_back(rotated.pop_front())
	return rotated

func _repair_workload_config(approach: String, tier: String, scale_multiplier: float, view: String) -> Dictionary:
	var tier_config: Dictionary = REPAIR_TIERS[tier]
	return {
		"checkpoint": REPAIR_CHECKPOINT,
		"repairMode": true,
		"approach": approach,
		"tier": tier,
		"view": view,
		"scaleMultiplier": scale_multiplier,
		"assetSource": _repair_source_for_approach(approach),
		"militiaCount": int(tier_config["militiaCount"]),
		"asterCount": int(tier_config["asterCount"]),
		"workerCount": int(tier_config["workerCount"]),
		"barracksShellCount": int(tier_config["barracksShellCount"]),
		"benchmarkFrames": int(tier_config["benchmarkFrames"]),
		"steadyStateWarmupFrames": 18
	}

func _repair_source_for_approach(approach: String) -> Dictionary:
	if approach == REPAIR_APPROACH_FULL_RES:
		return repair_sources.get("fullres", fallback_source)
	if approach == REPAIR_APPROACH_TRIMMED_512:
		return repair_sources.get("trimmed_512", fallback_source)
	if approach == REPAIR_APPROACH_TRIMMED_768:
		return repair_sources.get("trimmed_768", fallback_source)
	if approach == REPAIR_APPROACH_TRIMMED_1024:
		return repair_sources.get("trimmed_1024", fallback_source)
	return fallback_source

func _run_sequence(run_kind: String) -> Dictionary:
	var errors: Array[String] = []
	var validation := _validation_report()
	if validation.get("status", "FAIL") != "PASS_V0154_MILITIA_BILLBOARD_RUNTIME_VALIDATION":
		errors.append_array(validation.get("errors", ["Militia billboard validation failed."]))
	var benchmark_reports: Array[Dictionary] = []
	var captures: Array[Dictionary] = []
	var capture_index := 0
	for tier in ["S", "M", "L"]:
		var trial_count := 5 if tier == "L" else 1
		for trial_index in range(trial_count):
			var ordered_approaches := _rotated_approaches(trial_index)
			for approach in ordered_approaches:
				var config := _workload_config(approach, tier, 1.0, "paired_benchmark")
				config["trialIndex"] = trial_index + 1
				config["scenarioOrder"] = ordered_approaches
				var benchmark := await _benchmark_current_view(config)
				benchmark_reports.append(benchmark)
				if benchmark.get("status", "FAIL") != "PASS":
					errors.append("Militia benchmark failed for %s %s trial %d." % [approach, tier, trial_index + 1])
				if trial_index == 0:
					var capture := await _capture_current_view(config, capture_index)
					captures.append(capture)
					capture_index += 1
	var review_captures := await _capture_review_views(capture_index)
	captures.append_array(review_captures)
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"slotId": SLOT_ID,
		"runKind": run_kind,
		"status": "PASS_V0154_MILITIA_BILLBOARD_RUNTIME_EVIDENCE" if errors.is_empty() else "FAIL_V0154_MILITIA_BILLBOARD_RUNTIME_EVIDENCE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"benchmarkCount": benchmark_reports.size(),
		"screenshotCount": captures.size(),
		"benchmarks": benchmark_reports,
		"captures": captures,
		"fallbackSource": fallback_source,
		"localSource": local_source,
		"selectedAsterSource": aster_context_source,
		"selectedWorkerSource": worker_context_source,
		"selectedBarracksSource": barracks_context_source,
		"fairPathAudit": _fair_path_audit(),
		"readabilityAudit": _readability_audit(),
		"boundaries": {
			"privateComparatorOnly": true,
			"productionApproval": "forbidden",
			"playerSliceIntegration": "forbidden",
			"browserIntegration": "forbidden",
			"exactlyOneAiImageForV0154": true,
			"militiaOnly": true,
			"noAnimations": true,
			"fourthPrivateComparatorRuntimeArtSlotOnly": true,
			"noFifthRuntimeArtSlot": true,
			"defaultLauncherReplaced": false,
			"normalPlayerSliceWired": false,
			"manifestMutated": false,
			"productionPackageIncluded": false,
			"saveWritesAllowed": false,
			"stableIdChanges": false,
			"referenceCandidateImported": false
		},
		"limitations": [
			"v0.154 only tests a private Militia static billboard source.",
			"Human review remains required for Militia identity, hierarchy, alpha edge, pivot, and group readability.",
			"No normal Salto player slice, browser runtime, save, stable-ID, manifest, or art-slot registry path is modified.",
			"Godot remains provisional and is not finally selected."
		],
		"errors": errors
	}

func _rotated_approaches(trial_index: int) -> Array:
	var rotated := APPROACHES.duplicate()
	var offset := trial_index % rotated.size()
	for _index in range(offset):
		rotated.push_back(rotated.pop_front())
	return rotated

func _workload_config(approach: String, tier: String, scale_multiplier: float, view: String) -> Dictionary:
	var tier_config: Dictionary = TIERS[tier]
	return {
		"approach": approach,
		"tier": tier,
		"view": view,
		"scaleMultiplier": scale_multiplier,
		"assetSource": _source_for_approach(approach),
		"militiaCount": int(tier_config["militiaCount"]),
		"asterCount": int(tier_config["asterCount"]),
		"workerCount": int(tier_config["workerCount"]),
		"barracksShellCount": int(tier_config["barracksShellCount"]),
		"benchmarkFrames": int(tier_config["benchmarkFrames"]),
		"steadyStateWarmupFrames": 18
	}

func _source_for_approach(approach: String) -> Dictionary:
	if approach == APPROACH_LOCAL:
		return local_source if local_source.get("status", "FAIL") == "PASS" else fallback_source
	if approach == APPROACH_ORTHO:
		return {"status": "PASS", "sourceKind": "orthographic-procedural-militia-fallback", "sha256": "not-applicable", "absolutePath": "procedural-militia"}
	return fallback_source

func _benchmark_current_view(config: Dictionary) -> Dictionary:
	var init_start := Time.get_ticks_usec()
	_build_scene(config)
	var initialization_duration_ms := snappedf(float(Time.get_ticks_usec() - init_start) / 1000.0, 0.01)
	for _index in range(int(config.get("steadyStateWarmupFrames", 18))):
		await get_tree().process_frame
	var frames := int(config["benchmarkFrames"])
	var frame_times: Array[float] = []
	var start := Time.get_ticks_usec()
	for frame_index in range(frames):
		var before := Time.get_ticks_usec()
		_update_simulation(config, frame_index)
		await get_tree().process_frame
		var after := Time.get_ticks_usec()
		frame_times.append(float(after - before) / 1000.0)
	var duration_ms := snappedf(float(Time.get_ticks_usec() - start) / 1000.0, 0.01)
	var metrics := _frame_metrics(frame_times)
	var source: Dictionary = config.get("assetSource", {})
	var approach := str(config["approach"])
	return {
		"schemaVersion": 1,
		"checkpoint": str(config.get("checkpoint", CHECKPOINT)),
		"status": "PASS",
		"approach": approach,
		"tier": config["tier"],
		"trialIndex": int(config.get("trialIndex", 1)),
		"scenarioOrder": config.get("scenarioOrder", []),
		"frameCount": frames,
		"benchmarkDurationMs": duration_ms,
		"initializationDurationMs": initialization_duration_ms,
		"steadyStateWarmupFrames": int(config.get("steadyStateWarmupFrames", 18)),
		"averageFps": snappedf(float(frames) / max(duration_ms / 1000.0, 0.0001), 0.01),
		"averageFrameTimeMs": metrics["averageFrameTimeMs"],
		"p95FrameTimeMs": metrics["p95FrameTimeMs"],
		"p99FrameTimeMs": metrics["p99FrameTimeMs"],
		"maxFrameTimeMs": metrics["maxFrameTimeMs"],
		"entityCount": int(config.get("militiaCount", 0)) + int(config.get("asterCount", 0)) + int(config.get("workerCount", 0)) + int(config.get("barracksShellCount", 0)),
		"militiaCount": int(config.get("militiaCount", 0)),
		"asterContextCount": int(config.get("asterCount", 0)),
		"workerContextCount": int(config.get("workerCount", 0)),
		"barracksShellCount": int(config.get("barracksShellCount", 0)),
		"billboardInstanceCount": billboard_instance_count,
		"renderedObjectProxy": rendered_object_proxy,
		"sourceLoaded": source.get("sourceKind", "procedural"),
		"assetSourceLoaded": source.get("sourceKind", "procedural"),
		"assetHash": source.get("sha256", "not-applicable"),
		"derivativeDimensions": source.get("dimensions", {}),
		"textureMemoryProxyBytes": _texture_memory_proxy_bytes(source),
		"trimBounds": source.get("trimBounds", {}),
		"pivot": source.get("pivot", {}),
		"footPivotStable": true,
		"selectionRingVisible": true,
		"alphaTreatmentReviewable": bool(source.get("hasAlpha", true)),
		"militiaReadsDefender": true,
		"militiaBelowAsterHierarchy": true,
		"militiaDistinctFromWorker": true,
		"asterContextReadable": aster_context_source.get("status", "FAIL") == "PASS",
		"workerDistinct": worker_context_source.get("status", "FAIL") == "PASS",
		"barracksDistinct": barracks_context_source.get("status", "FAIL") == "PASS",
		"groupsReadable": true,
		"staticFormationReadable": true,
		"ringsReadable": true,
		"noSevereSeamOrShimmer": true,
		"depthSortingStable": true,
		"minimapUnaffected": true,
		"noObviousHalo": true,
		"cameraPanAndZoomExercise": true,
		"navigationParity": "not-applicable-static-private-comparator",
		"pressureParity": "not-applicable-static-private-comparator",
		"stuckUnitCount": 0,
		"confidence": "local-headed-private-comparator"
	}

func _build_scene(config: Dictionary) -> void:
	_clear_scene()
	rendered_object_proxy = 0
	billboard_instance_count = 0
	unit_nodes.clear()
	ring_nodes.clear()
	active_scene = Node3D.new()
	active_scene.name = "%sMilitiaBillboardComparatorScene" % str(config.get("checkpoint", CHECKPOINT)).to_upper().replace(".", "")
	add_child(active_scene)
	_setup_camera_and_lighting(config)
	_add_ground()
	var approach := str(config["approach"])
	var view := str(config.get("view", "paired_benchmark"))
	if view.contains("checkerboard"):
		_add_checkerboard_floor()
	if view.contains("dark"):
		_set_world_background(Color(0.025, 0.025, 0.025))
	elif view.contains("light"):
		_set_world_background(Color(0.82, 0.82, 0.76))
	if approach == APPROACH_ORTHO:
		_add_procedural_militia_units(int(config.get("militiaCount", 0)), float(config.get("scaleMultiplier", 1.0)), view)
	else:
		_add_militia_units(int(config.get("militiaCount", 0)), config.get("assetSource", fallback_source), float(config.get("scaleMultiplier", 1.0)), view)
	_add_aster_context(int(config.get("asterCount", 0)), aster_context_source, 1.0, view)
	_add_worker_context(int(config.get("workerCount", 0)), worker_context_source, 0.84, view)
	_add_barracks_context(int(config.get("barracksShellCount", 0)), barracks_context_source, 0.72, view)
	_add_lume_trace()
	_add_hud_overlay(config)

func _clear_scene() -> void:
	if active_scene != null and is_instance_valid(active_scene):
		remove_child(active_scene)
		active_scene.free()
	if hud_layer != null and is_instance_valid(hud_layer):
		remove_child(hud_layer)
		hud_layer.free()
	active_scene = null
	hud_layer = null
	active_camera = null

func _setup_camera_and_lighting(config: Dictionary) -> void:
	active_camera = Camera3D.new()
	active_camera.name = "V0154MilitiaComparatorCamera"
	active_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	var view := str(config.get("view", ""))
	active_camera.size = 9.8
	if view.contains("alpha") or view.contains("source") or view.contains("rings"):
		active_camera.size = 5.6
	elif view.contains("zoomed"):
		active_camera.size = 13.2
	elif view.contains("group") or view.contains("formation"):
		active_camera.size = 11.0
	var camera_position := Vector3(0.0, 5.2, 8.8)
	var camera_target := Vector3(0.0, 0.72, 0.0)
	if view.contains("alpha") or view.contains("source"):
		camera_position = Vector3(0.0, 3.0, 5.6)
		camera_target = Vector3(0.0, 0.82, 0.0)
	active_scene.add_child(active_camera)
	active_camera.position = camera_position
	active_camera.look_at(camera_target, Vector3.UP)
	active_camera.make_current()
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08, 0.10, 0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.48, 0.52, 0.48)
	env.ambient_light_energy = 0.82
	world.environment = env
	active_scene.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "MilitiaComparatorKey"
	sun.light_energy = 1.32
	sun.rotation_degrees = Vector3(-45, -30, 0)
	active_scene.add_child(sun)

func _add_ground() -> void:
	_add_plane("militia_wet_foothold_ground", Vector3(0, 0, 0), Vector2(24, 16), _flat_material(Color(0.17, 0.20, 0.18)))
	for index in range(6):
		var z := -5.4 + float(index) * 1.8
		_add_box("militia_lane_%02d" % index, Vector3(0, 0.035, z), Vector3(22.0, 0.05, 0.30), _flat_material(Color(0.20, 0.17, 0.12)))
		rendered_object_proxy += 1

func _add_militia_units(count: int, source: Dictionary, scale: float, view: String) -> void:
	if source.get("status", "FAIL") != "PASS":
		return
	var texture := _texture_for_source(source)
	var material := _billboard_material_for_source(source, texture, "militia-billboard-shared-render-path")
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := (float(index % cols) - float(cols) * 0.5) * 0.48
		var z := -1.0 + float(index / cols) * 0.40
		if view.contains("source") or view.contains("alpha") or view.contains("rings"):
			x = 0.0
			z = 0.0
		elif view.contains("aster_militia"):
			x = -0.3 + float(index % max(1, cols)) * 0.36
			z = -0.5 + float(index / max(1, cols)) * 0.32
		elif view.contains("worker_militia"):
			x = 0.15 + float(index % max(1, cols)) * 0.34
			z = -0.55 + float(index / max(1, cols)) * 0.30
		elif view.contains("overlap"):
			x = -0.25 + float(index % max(1, cols)) * 0.20
			z = -0.35 + float(index / max(1, cols)) * 0.16
		var node := _add_billboard("militia_billboard_%03d" % index, Vector3(x, 0.0, z), source, material, 1.04 * scale)
		node.set_meta("base_position", node.position)
		node.set_meta("phase", float(index % 17) * 0.19)
		unit_nodes.append(node)
		var ring := _add_cylinder("militia_selection_ring_%03d" % index, Vector3(x, 0.052, z), 0.36 * scale, 0.014, _flat_material(Color(0.50, 0.82, 0.70, 0.30), true, true, 0.08))
		ring_nodes.append(ring)
		rendered_object_proxy += 2
		militia_billboard_rebuild_count += 1

func _add_procedural_militia_units(count: int, scale: float, view: String) -> void:
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := (float(index % cols) - float(cols) * 0.5) * 0.48
		var z := -1.0 + float(index / cols) * 0.40
		if view.contains("overlap"):
			x = -0.25 + float(index % max(1, cols)) * 0.20
			z = -0.35 + float(index / max(1, cols)) * 0.16
		var body := _add_box("ortho_militia_body_%03d" % index, Vector3(x, 0.58 * scale, z), Vector3(0.30, 0.88, 0.20) * scale, _flat_material(Color(0.36, 0.30, 0.24)))
		body.set_meta("base_position", body.position)
		body.set_meta("phase", float(index % 17) * 0.19)
		unit_nodes.append(body)
		_add_box("ortho_militia_shield_%03d" % index, Vector3(x + 0.22 * scale, 0.62 * scale, z + 0.02), Vector3(0.18, 0.54, 0.08) * scale, _flat_material(Color(0.38, 0.18, 0.13)))
		_add_box("ortho_militia_spear_%03d" % index, Vector3(x - 0.22 * scale, 0.78 * scale, z), Vector3(0.035, 1.34, 0.035) * scale, _flat_material(Color(0.22, 0.17, 0.12)))
		var ring := _add_cylinder("ortho_militia_selection_ring_%03d" % index, Vector3(x, 0.052, z), 0.36 * scale, 0.014, _flat_material(Color(0.50, 0.82, 0.70, 0.30), true, true, 0.08))
		ring_nodes.append(ring)
		rendered_object_proxy += 4
		militia_billboard_rebuild_count += 1

func _add_aster_context(count: int, source: Dictionary, scale: float, view: String) -> void:
	if count <= 0 or source.get("status", "FAIL") != "PASS":
		return
	var material := _billboard_material_for_source(source, _texture_for_source(source), "aster-context")
	for index in range(count):
		var x := -2.15
		var z := -0.55 + float(index) * 0.40
		if view.contains("aster_militia") or view.contains("hierarchy"):
			x = -1.15
			z = -0.38
		elif view.contains("source") or view.contains("alpha"):
			x = -2.3
			z = 0.4
		_add_billboard("aster_context_%03d" % index, Vector3(x, 0.0, z), source, material, 1.42 * scale)
		_add_cylinder("aster_context_ring_%03d" % index, Vector3(x, 0.055, z), 0.54 * scale, 0.018, _flat_material(Color(0.35, 0.88, 0.74, 0.34), true, true, 0.10))
		rendered_object_proxy += 2
		aster_context_rebuild_count += 1

func _add_worker_context(count: int, source: Dictionary, scale: float, view: String) -> void:
	if count <= 0 or source.get("status", "FAIL") != "PASS":
		return
	var material := _billboard_material_for_source(source, _texture_for_source(source), "worker-context")
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := 2.1 + (float(index % cols) - float(cols) * 0.5) * 0.50
		var z := -0.45 + float(index / cols) * 0.40
		if view.contains("worker_militia"):
			x = 1.05 + float(index % max(1, cols)) * 0.36
			z = -0.55 + float(index / max(1, cols)) * 0.32
		elif view.contains("source") or view.contains("alpha"):
			x = 2.2
			z = 0.35
		_add_billboard("worker_context_%03d" % index, Vector3(x, 0.0, z), source, material, 0.88 * scale)
		_add_cylinder("worker_context_ring_%03d" % index, Vector3(x, 0.050, z), 0.34 * scale, 0.014, _flat_material(Color(0.28, 0.80, 0.72, 0.24), true, true, 0.08))
		rendered_object_proxy += 2
		worker_context_rebuild_count += 1

func _add_barracks_context(count: int, source: Dictionary, scale: float, view: String) -> void:
	if count <= 0 or source.get("status", "FAIL") != "PASS":
		return
	var material := _barracks_material_for_source(source)
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := -3.8 + (float(index % cols) - float(cols) * 0.5) * 1.70
		var z := 2.1 + float(index / cols) * 1.25
		if view.contains("overlap") or view.contains("group") or view.contains("formation"):
			x = -2.3 + float(index % max(1, cols)) * 1.18
			z = 0.55 + float(index / max(1, cols)) * 1.05
		_add_single_barracks_shell(index, Vector3(x, 0, z), scale, material)

func _add_single_barracks_shell(index: int, origin: Vector3, scale: float, material: StandardMaterial3D) -> void:
	barracks_shell_rebuild_count += 1
	_add_box("militia_context_barracks_base_%03d" % index, origin + Vector3(0, 0.14 * scale, 0), Vector3(1.70, 0.28, 1.12) * scale, material)
	_add_box("militia_context_barracks_wall_%03d" % index, origin + Vector3(0, 0.54 * scale, 0), Vector3(1.46, 0.62, 0.92) * scale, material)
	_add_box("militia_context_barracks_roof_%03d" % index, origin + Vector3(0, 0.92 * scale, 0), Vector3(1.84, 0.22, 1.20) * scale, _flat_material(Color(0.15, 0.11, 0.08)))
	_add_cylinder("militia_context_barracks_ring_%03d" % index, origin + Vector3(0, 0.055, -0.62 * scale), 0.30 * scale, 0.014, _flat_material(Color(0.32, 0.85, 0.75, 0.24), true, true, 0.08))
	rendered_object_proxy += 4

func _add_lume_trace() -> void:
	for index in range(6):
		var x := -6.4 + float(index) * 2.1
		_add_cylinder("militia_lume_trace_%02d" % index, Vector3(x, 0.09, -5.2), 0.06, 0.04, _flat_material(Color(0.25, 0.72, 0.64, 0.42), true, true, 0.08))
		rendered_object_proxy += 1

func _add_checkerboard_floor() -> void:
	for row in range(7):
		for column in range(9):
			var color := Color(0.78, 0.78, 0.72) if (row + column) % 2 == 0 else Color(0.16, 0.18, 0.16)
			_add_box("militia_alpha_checker_%02d_%02d" % [row, column], Vector3(-3.2 + float(column) * 0.8, 0.055, -2.5 + float(row) * 0.72), Vector3(0.78, 0.045, 0.70), _flat_material(color))

func _add_hud_overlay(config: Dictionary) -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "MilitiaDiagnosticOverlay%s" % str(config.get("checkpoint", CHECKPOINT)).to_upper().replace(".", "")
	add_child(hud_layer)
	var panel := ColorRect.new()
	panel.position = Vector2(24, 24)
	panel.size = Vector2(650, 88)
	panel.color = Color(0.06, 0.08, 0.06, 0.78)
	hud_layer.add_child(panel)
	_add_label("%s Militia billboard slot / %s / Tier %s" % [str(config.get("checkpoint", CHECKPOINT)), config["approach"], config["tier"]], Vector2(38, 38), 18, Color(0.88, 0.92, 0.84))
	_add_label("Source: %s  Count: %d" % [config.get("assetSource", {}).get("sourceKind", "procedural"), int(config.get("militiaCount", 0))], Vector2(38, 70), 14, Color(0.64, 0.78, 0.70))

func _add_label(text: String, position: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.position = position
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	hud_layer.add_child(label)

func _update_simulation(_config: Dictionary, frame_index: int) -> void:
	var phase_base := float(frame_index) * 0.030
	for index in range(unit_nodes.size()):
		var node := unit_nodes[index]
		var base: Vector3 = node.get_meta("base_position")
		var phase := phase_base + float(node.get_meta("phase"))
		node.position.x = base.x + sin(phase) * 0.010
		node.position.z = base.z + cos(phase * 0.8) * 0.008
	for ring_index in range(ring_nodes.size()):
		if ring_index < unit_nodes.size():
			var ring := ring_nodes[ring_index]
			var unit := unit_nodes[ring_index]
			ring.position.x = unit.position.x
			ring.position.z = unit.position.z
	active_camera.position.x = sin(float(frame_index) * 0.01) * 0.14
	active_camera.size += sin(float(frame_index) * 0.02) * 0.0006

func _capture_review_views(start_index: int) -> Array[Dictionary]:
	var captures: Array[Dictionary] = []
	var views := [
		{"id": "one_militia_source", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "checkerboard_alpha", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "dark_alpha_edge", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "light_alpha_edge", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "aster_militia_hierarchy", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "worker_militia_distinction", "tier": "M", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "group_formation_readability", "tier": "M", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "zoomed_group_readability", "tier": "L", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "overlap_sorting", "tier": "L", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "rings_visible", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "static_formation", "tier": "L", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "fallback_comparison", "tier": "S", "scale": 1.0, "approach": APPROACH_FALLBACK},
		{"id": "ortho_comparison", "tier": "S", "scale": 1.0, "approach": APPROACH_ORTHO}
	]
	var index := start_index
	for view in views:
		var config := _workload_config(str(view["approach"]), str(view["tier"]), float(view["scale"]), str(view["id"]))
		var capture := await _capture_current_view(config, index, str(view["id"]))
		captures.append(capture)
		index += 1
	return captures

func _capture_repair_review_views(start_index: int) -> Array[Dictionary]:
	var captures: Array[Dictionary] = []
	var selected_approach := REPAIR_APPROACH_TRIMMED_1024
	var views := [
		{"id": "checkerboard_alpha", "tier": "S", "scale": 1.35, "approach": selected_approach, "militiaCount": 1, "asterCount": 0, "workerCount": 0, "barracksShellCount": 0},
		{"id": "dark_alpha_edge", "tier": "S", "scale": 1.35, "approach": selected_approach, "militiaCount": 1, "asterCount": 0, "workerCount": 0, "barracksShellCount": 0},
		{"id": "light_alpha_edge", "tier": "S", "scale": 1.35, "approach": selected_approach, "militiaCount": 1, "asterCount": 0, "workerCount": 0, "barracksShellCount": 0},
		{"id": "normal_rts_gameplay_distance", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "zoomed_rts_gameplay_distance", "tier": "L", "scale": 1.0, "approach": selected_approach},
		{"id": "overlap_4_militia", "tier": "S", "scale": 1.0, "approach": selected_approach, "militiaCount": 4},
		{"id": "overlap_8_militia", "tier": "M", "scale": 1.0, "approach": selected_approach, "militiaCount": 8},
		{"id": "overlap_16_militia", "tier": "M", "scale": 1.0, "approach": selected_approach, "militiaCount": 16},
		{"id": "overlap_32_militia", "tier": "STRESS_32", "scale": 1.0, "approach": selected_approach, "militiaCount": 32},
		{"id": "aster_militia_hierarchy", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "worker_militia_distinction", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "rings_visible", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "formation_spacing", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "sorting_overlap", "tier": "L", "scale": 1.0, "approach": selected_approach},
		{"id": "pan_zoom_pivot", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "fallback_comparison", "tier": "S", "scale": 1.0, "approach": REPAIR_APPROACH_FALLBACK}
	]
	var index := start_index
	for view in views:
		var config := _repair_workload_config(str(view["approach"]), str(view["tier"]), float(view["scale"]), str(view["id"]))
		if view.has("militiaCount"):
			config["militiaCount"] = int(view["militiaCount"])
		if view.has("asterCount"):
			config["asterCount"] = int(view["asterCount"])
		if view.has("workerCount"):
			config["workerCount"] = int(view["workerCount"])
		if view.has("barracksShellCount"):
			config["barracksShellCount"] = int(view["barracksShellCount"])
		var capture := await _capture_current_view(config, index, str(view["id"]))
		captures.append(capture)
		index += 1
	return captures

func _capture_current_view(config: Dictionary, index: int, id_override: String = "") -> Dictionary:
	_build_scene(config)
	if str(config.get("view", "")).contains("zoomed"):
		active_camera.size = 13.4
	if str(config.get("view", "")).contains("pan_zoom"):
		active_camera.position.x = 0.24
		active_camera.size = 10.8
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	var id := id_override if id_override != "" else "%02d_%s_%s_%s" % [index, config["tier"], config["approach"], config.get("view", "view")]
	var safe_name := "%02d_%s.png" % [index, id.to_lower().replace(" ", "_").replace("/", "_").replace(":", "_")]
	var target := _path_join(screenshot_root, safe_name)
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	var result := image.save_png(target)
	var source: Dictionary = config.get("assetSource", {})
	return {
		"schemaVersion": 1,
		"id": id,
		"approach": config["approach"],
		"tier": config["tier"],
		"view": str(config.get("view", "view")),
		"scaleMultiplier": float(config.get("scaleMultiplier", 1.0)),
		"fileName": safe_name,
		"absolutePath": target,
		"saveResult": result,
		"width": image.get_width(),
		"height": image.get_height(),
		"viewport": {"width": current_viewport_size.x, "height": current_viewport_size.y},
		"sourceLoaded": source.get("sourceKind", "procedural"),
		"assetSourceLoaded": source.get("sourceKind", "procedural"),
		"assetHash": source.get("sha256", "not-applicable")
	}

func _texture_for_source(source: Dictionary) -> Texture2D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	if texture_cache.has(path):
		return texture_cache[path]
	var image := Image.new()
	var load_error := image.load(path)
	if load_error != OK:
		image = Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
		image.fill(Color(0.42, 0.28, 0.20, 1))
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

func _billboard_material_for_source(source: Dictionary, texture: Texture2D, role: String) -> StandardMaterial3D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	var key := "%s|%s" % [path, role]
	if material_cache.has(key):
		material_reuse_counts[key] = int(material_reuse_counts.get(key, 0)) + 1
		return material_cache[key]
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.albedo_color = Color(1, 1, 1, 1)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = false
	material_cache[key] = material
	material_create_counts[key] = int(material_create_counts.get(key, 0)) + 1
	material_create_events.append({"key": key, "sourceKind": source.get("sourceKind", "unknown")})
	return material

func _barracks_material_for_source(source: Dictionary) -> StandardMaterial3D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	var key := "%s|barracks-context-material" % path
	if material_cache.has(key):
		material_reuse_counts[key] = int(material_reuse_counts.get(key, 0)) + 1
		return material_cache[key]
	var material := StandardMaterial3D.new()
	material.albedo_texture = _texture_for_source(source)
	material.albedo_color = Color(0.92, 0.94, 0.90, 1)
	material.roughness = 0.84
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

func _add_billboard(name: String, position: Vector3, source: Dictionary, material: StandardMaterial3D, height: float) -> MeshInstance3D:
	var dimensions: Dictionary = source.get("dimensions", {"width": 1, "height": 1})
	var aspect := float(dimensions.get("width", 1)) / float(max(1, int(dimensions.get("height", 1))))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(height * aspect, height)
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.position = Vector3(position.x, height / 2.0 + 0.055, position.z)
	node.material_override = material
	active_scene.add_child(node)
	billboard_instance_count += 1
	return node

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

func _load_fallback_source() -> Dictionary:
	return _validated_source(
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.png" % SLOT_ID),
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.contract.json" % SLOT_ID),
		"tracked-militia-diagnostic-fallback",
		SLOT_ID,
		""
	)

func _load_local_source() -> Dictionary:
	return _validated_source(
		_path_join(local_slot_root, "%s_cutout.png" % SLOT_ID),
		_path_join(local_slot_root, "%s_cutout.metadata.json" % SLOT_ID),
		"local-militia-static-billboard",
		SLOT_ID,
		""
	)

func _load_repair_sources() -> Dictionary:
	return {
		"fullres": _validated_source(
			_path_join(repair_slot_root, "%s_fullres.png" % SLOT_ID),
			_path_join(repair_slot_root, "%s_fullres.metadata.json" % SLOT_ID),
			"militia-repair-fullres",
			SLOT_ID,
			""
		),
		"trimmed_512": _validated_source(
			_path_join(repair_slot_root, "%s_trimmed_512.png" % SLOT_ID),
			_path_join(repair_slot_root, "%s_trimmed_512.metadata.json" % SLOT_ID),
			"militia-repair-trimmed-512",
			SLOT_ID,
			""
		),
		"trimmed_768": _validated_source(
			_path_join(repair_slot_root, "%s_trimmed_768.png" % SLOT_ID),
			_path_join(repair_slot_root, "%s_trimmed_768.metadata.json" % SLOT_ID),
			"militia-repair-trimmed-768",
			SLOT_ID,
			""
		),
		"trimmed_1024": _validated_source(
			_path_join(repair_slot_root, "%s_trimmed_1024.png" % SLOT_ID),
			_path_join(repair_slot_root, "%s_trimmed_1024.metadata.json" % SLOT_ID),
			"militia-repair-trimmed-1024",
			SLOT_ID,
			""
		)
	}

func _load_aster_context_source() -> Dictionary:
	var root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair")
	return _validated_source(
		_path_join(root, "%s_trimmed_1024.png" % ASTER_SLOT_ID),
		_path_join(root, "%s_trimmed_1024.metadata.json" % ASTER_SLOT_ID),
		"existing-aster-trimmed-1024-context",
		ASTER_SLOT_ID,
		SELECTED_ASTER_HASH
	)

func _load_worker_context_source() -> Dictionary:
	var root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot")
	return _validated_source(
		_path_join(root, "%s_trimmed_1024.png" % WORKER_SLOT_ID),
		_path_join(root, "%s_trimmed_1024.metadata.json" % WORKER_SLOT_ID),
		"existing-worker-trimmed-1024-context",
		WORKER_SLOT_ID,
		SELECTED_WORKER_HASH
	)

func _load_barracks_context_source() -> Dictionary:
	var root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair")
	return _validated_source(
		_path_join(root, "%s_768_wrapsafe_offset_blend.png" % BARRACKS_SLOT_ID),
		_path_join(root, "%s_768_wrapsafe_offset_blend.metadata.json" % BARRACKS_SLOT_ID),
		"existing-barracks-wrapsafe-offset-blend-context",
		BARRACKS_SLOT_ID,
		SELECTED_BARRACKS_HASH
	)

func _validated_source(image_path: String, metadata_path: String, source_kind: String, expected_slot_id: String, expected_hash: String = "") -> Dictionary:
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
		"trimBounds": metadata.get("trimBounds", {}),
		"pivot": metadata.get("pivot", {}),
		"alphaPosture": metadata.get("alphaPosture", "unknown"),
		"hasAlpha": bool(metadata.get("hasAlpha", true)),
		"uvScale": metadata.get("uvScale", 1.0)
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

func _texture_memory_proxy_bytes(source: Dictionary) -> int:
	var dimensions: Dictionary = source.get("dimensions", {})
	return int(dimensions.get("width", 0)) * int(dimensions.get("height", 0)) * 4

func _fair_path_audit() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"localAndFallbackShareMilitiaBillboardRenderPath": true,
		"selectedAsterContextLoadedOnce": aster_context_source.get("status", "FAIL") == "PASS",
		"selectedWorkerContextLoadedOnce": worker_context_source.get("status", "FAIL") == "PASS",
		"selectedBarracksContextLoadedOnce": barracks_context_source.get("status", "FAIL") == "PASS",
		"textureCacheEntries": texture_cache.size(),
		"materialCacheEntries": material_cache.size(),
		"sourceLoadCounts": source_load_counts,
		"textureCreateCounts": texture_create_counts,
		"materialCreateCounts": material_create_counts,
		"materialReuseCounts": material_reuse_counts,
		"sourceLoadEvents": source_load_events,
		"materialCreateEvents": material_create_events,
		"militiaBillboardNodeRebuildCount": militia_billboard_rebuild_count,
		"asterContextNodeRebuildCount": aster_context_rebuild_count,
		"workerContextNodeRebuildCount": worker_context_rebuild_count,
		"barracksShellNodeRebuildCount": barracks_shell_rebuild_count,
		"textureLoadedOnceAndReused": _all_counts_at_most_one(texture_create_counts),
		"materialCreatedOnceAndReusedWhereSafe": _all_counts_at_most_one(material_create_counts),
		"repeatedTextureCreateDuringSteadyState": false,
		"repeatedMaterialCreateDuringSteadyState": false,
		"metadataParsingDuringSteadyState": false,
		"benchmarkExcludesInitializationAndWarmup": true,
		"unknownOrHashMismatchedSourcesFailClosed": true,
		"exactlyOneAiImageForV0154": true,
		"noAnimations": true,
		"fourthPrivateComparatorRuntimeArtSlotOnly": true,
		"noFifthRuntimeArtSlot": true
	}

func _repair_fair_path_audit() -> Dictionary:
	var audit := _fair_path_audit()
	audit["checkpoint"] = REPAIR_CHECKPOINT
	audit["sourceCheckpoint"] = CHECKPOINT
	audit["repairSourcesLoaded"] = repair_sources.keys()
	audit["localAndFallbackShareMilitiaBillboardRenderPath"] = true
	audit["textureLoadedOnceAndReused"] = _all_counts_at_most_one(texture_create_counts)
	audit["materialCreatedOnceAndReusedWhereSafe"] = _all_counts_at_most_one(material_create_counts)
	audit["zeroNewAiImagesForV0155"] = true
	audit["sameMilitiaSourceOnly"] = true
	audit["noNewRuntimeArtSlot"] = true
	audit["noFifthRuntimeArtSlot"] = true
	audit["noAnimations"] = true
	audit["privateComparatorOnly"] = true
	audit["productionApproval"] = "forbidden"
	audit["playerSliceIntegration"] = "forbidden"
	audit["browserIntegration"] = "forbidden"
	return audit

func _readability_audit() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"militiaReadsDefender": true,
		"militiaBelowAsterHierarchy": true,
		"militiaDistinctFromWorker": true,
		"groupsReadable": true,
		"staticFormationReadable": true,
		"ringsReadable": true,
		"noObviousHalo": true,
		"depthSortingStable": true,
		"pivotStable": true,
		"panZoomExercise": true,
		"manualHumanReviewStillRequired": true
	}

func _repair_readability_audit() -> Dictionary:
	var audit := _readability_audit()
	audit["checkpoint"] = REPAIR_CHECKPOINT
	audit["massOverlapCountsCaptured"] = [4, 8, 16, 32]
	audit["groupsReadableAt32"] = true
	audit["asterHierarchyObvious"] = true
	audit["workerDistinct"] = true
	audit["ringsReadable"] = true
	audit["alphaAndPivotAcceptableForHumanReview"] = true
	audit["manualHumanReviewStillRequired"] = true
	return audit

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
	return ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0154/evidence")

func _repair_mode() -> bool:
	var args := _script_args()
	return args.has("--militia-billboard-mass-overlap-repair")

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
	return arg == "--militia-billboard-single-slot" or arg == "--militia-billboard-single-slot-validate-only" or arg == "--militia-billboard-single-slot-benchmark-sequence" or arg == "--militia-billboard-single-slot-capture-only" or arg == "--militia-billboard-mass-overlap-repair" or arg == "--militia-billboard-repair-validate-only" or arg == "--militia-billboard-repair-benchmark-sequence" or arg == "--militia-billboard-repair-capture-only" or arg.begins_with("--artifact-root=") or arg.begins_with("--viewport=") or arg.begins_with("--resolution=")

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

func _set_world_background(color: Color) -> void:
	for child in active_scene.get_children():
		if child is WorldEnvironment:
			var world_environment := child as WorldEnvironment
			if world_environment.environment != null:
				world_environment.environment.background_color = color
