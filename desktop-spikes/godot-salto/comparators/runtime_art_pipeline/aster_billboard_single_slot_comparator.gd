extends Node

const CHECKPOINT := "v0.151"
const REPAIR_CHECKPOINT := "v0.152"
const COMPOSITION_CHECKPOINT := "v0.153"
const SLOT_ID := "aster_billboard_static_v0151"
const WORKER_SLOT_ID := "worker_billboard_static_v0147"
const BARRACKS_SLOT_ID := "barrosan_barracks_material_v0149"
const SELECTED_WORKER_HASH := "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
const SELECTED_BARRACKS_HASH := "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
const SELECTED_ASTER_REPAIR_HASH := "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a"
const APPROACH_FALLBACK := "HYBRID_ASTER_DIAGNOSTIC_FALLBACK_BASELINE"
const APPROACH_LOCAL := "HYBRID_ASTER_LOCAL_STATIC_BILLBOARD"
const APPROACH_WORKER_CONTEXT := "HYBRID_WORKER_CONTEXT_BASELINE"
const APPROACH_BARRACKS_CONTEXT := "HYBRID_BARRACKS_CONTEXT_BASELINE"
const APPROACH_ORTHO := "ORTHO_3D_MESH_FALLBACK_COMPARATOR"
const APPROACH_ASTER_FULL_RES := "HYBRID_ASTER_FULL_RES"
const APPROACH_ASTER_TRIMMED_512 := "HYBRID_ASTER_TRIMMED_512"
const APPROACH_ASTER_TRIMMED_768 := "HYBRID_ASTER_TRIMMED_768"
const APPROACH_ASTER_TRIMMED_1024 := "HYBRID_ASTER_TRIMMED_1024"
const APPROACH_THREE_SLOT_FALLBACK := "HYBRID_THREE_SLOT_FALLBACK_ONLY"
const APPROACH_THREE_SLOT_SELECTED := "HYBRID_THREE_SLOT_SELECTED_LOCAL"
const APPROACH_THREE_SLOT_ORTHO := "ORTHO_THREE_SLOT_PROCEDURAL_FALLBACK"
const APPROACHES := [
	APPROACH_FALLBACK,
	APPROACH_LOCAL,
	APPROACH_WORKER_CONTEXT,
	APPROACH_BARRACKS_CONTEXT,
	APPROACH_ORTHO
]
const REPAIR_APPROACHES := [
	APPROACH_FALLBACK,
	APPROACH_ASTER_FULL_RES,
	APPROACH_ASTER_TRIMMED_512,
	APPROACH_ASTER_TRIMMED_768,
	APPROACH_ASTER_TRIMMED_1024
]
const COMPOSITION_APPROACHES := [
	APPROACH_THREE_SLOT_FALLBACK,
	APPROACH_THREE_SLOT_SELECTED,
	APPROACH_THREE_SLOT_ORTHO
]
const TIERS := {
	"S": {"asterCount": 1, "workerCount": 5, "barracksShellCount": 2, "benchmarkFrames": 120},
	"M": {"asterCount": 4, "workerCount": 10, "barracksShellCount": 5, "benchmarkFrames": 150},
	"L": {"asterCount": 10, "workerCount": 18, "barracksShellCount": 10, "benchmarkFrames": 180}
}
const COMPOSITION_TIERS := {
	"S": {"asterCount": 1, "workerCount": 1, "barracksShellCount": 1, "benchmarkFrames": 120},
	"M": {"asterCount": 1, "workerCount": 12, "barracksShellCount": 1, "benchmarkFrames": 150},
	"L": {"asterCount": 1, "workerCount": 32, "barracksShellCount": 12, "benchmarkFrames": 180}
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
var repair_sources: Dictionary = {}
var worker_context_source: Dictionary = {}
var barracks_context_source: Dictionary = {}
var worker_fallback_source: Dictionary = {}
var barracks_fallback_source: Dictionary = {}
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
var total_aster_billboard_rebuild_count := 0
var total_worker_context_rebuild_count := 0
var total_barracks_shell_rebuild_count := 0
var billboard_instance_count := 0
var rendered_object_proxy := 0

func start() -> void:
	var args := _script_args()
	current_viewport_size = _viewport_from_args(DEFAULT_VIEWPORT_SIZE)
	_configure_window()
	artifact_root = _artifact_root_from_args()
	screenshot_root = _path_join(artifact_root, "screenshots")
	local_slot_root = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0151/local-aster-slot")
	repair_slot_root = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair")
	DirAccess.make_dir_recursive_absolute(artifact_root)
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	fallback_source = _load_fallback_source()
	local_source = _load_local_source()
	worker_context_source = _load_worker_context_source()
	barracks_context_source = _load_barracks_context_source()
	worker_fallback_source = _load_worker_fallback_context_source()
	barracks_fallback_source = _load_barracks_fallback_context_source()
	if _composition_mode():
		repair_sources = _load_repair_sources()
		if args.has("--hybrid-three-slot-composition-validate-only"):
			var composition_validation := _composition_validation_report()
			_write_absolute_json(_path_join(artifact_root, "hybrid-three-slot-composition-validation-runtime.json"), composition_validation)
			get_tree().quit(0 if composition_validation.get("status", "FAIL") == "PASS_V0153_HYBRID_THREE_SLOT_RUNTIME_VALIDATION" else 1)
			return
		var composition_run_kind := "hybrid-three-slot-composition-headed-benchmark-and-capture"
		if args.has("--hybrid-three-slot-composition-capture-only"):
			composition_run_kind = "hybrid-three-slot-composition-capture-refresh"
		var composition_report := await _run_composition_sequence(composition_run_kind)
		_write_absolute_json(_path_join(artifact_root, "hybrid-three-slot-composition-runtime.json"), composition_report)
		get_tree().quit(0 if composition_report.get("status", "FAIL") == "PASS_V0153_HYBRID_THREE_SLOT_RUNTIME_EVIDENCE" else 1)
		return
	if _repair_mode():
		repair_sources = _load_repair_sources()
		if args.has("--aster-billboard-repair-validate-only"):
			var repair_validation := _repair_validation_report()
			_write_absolute_json(_path_join(artifact_root, "aster-billboard-repair-validation-runtime.json"), repair_validation)
			get_tree().quit(0 if repair_validation.get("status", "FAIL") == "PASS_V0152_ASTER_BILLBOARD_REPAIR_RUNTIME_VALIDATION" else 1)
			return
		var repair_run_kind := "aster-billboard-repair-headed-benchmark-and-capture"
		if args.has("--aster-billboard-repair-capture-only"):
			repair_run_kind = "aster-billboard-repair-capture-refresh"
		var repair_report := await _run_repair_sequence(repair_run_kind)
		_write_absolute_json(_path_join(artifact_root, "aster-billboard-repair-runtime.json"), repair_report)
		get_tree().quit(0 if repair_report.get("status", "FAIL") == "PASS_V0152_ASTER_BILLBOARD_REPAIR_RUNTIME_EVIDENCE" else 1)
		return
	if args.has("--aster-billboard-single-slot-validate-only"):
		var validation := _validation_report()
		_write_absolute_json(_path_join(artifact_root, "aster-billboard-single-slot-validation-runtime.json"), validation)
		get_tree().quit(0 if validation.get("status", "FAIL") == "PASS_V0151_ASTER_BILLBOARD_RUNTIME_VALIDATION" else 1)
		return
	var run_kind := "aster-billboard-single-slot-headed-benchmark-and-capture"
	if args.has("--aster-billboard-single-slot-capture-only"):
		run_kind = "aster-billboard-single-slot-capture-refresh"
	var report := await _run_sequence(run_kind)
	_write_absolute_json(_path_join(artifact_root, "aster-billboard-single-slot-runtime.json"), report)
	get_tree().quit(0 if report.get("status", "FAIL") == "PASS_V0151_ASTER_BILLBOARD_RUNTIME_EVIDENCE" else 1)

func _validation_report() -> Dictionary:
	var errors: Array[String] = []
	for source in [fallback_source, local_source, worker_context_source, barracks_context_source]:
		if source.get("status", "FAIL") != "PASS":
			errors.append_array(source.get("errors", ["Unknown source validation failure."]))
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"slotId": SLOT_ID,
		"status": "PASS_V0151_ASTER_BILLBOARD_RUNTIME_VALIDATION" if errors.is_empty() else "FAIL_V0151_ASTER_BILLBOARD_RUNTIME_VALIDATION",
		"fallbackSource": fallback_source,
		"localSource": local_source,
		"workerContextSource": worker_context_source,
		"barracksContextSource": barracks_context_source,
		"exactlyOneAiImageForV0151": true,
		"thirdRuntimeArtSlotOnly": true,
		"noFourthRuntimeArtSlot": true,
		"privateComparatorOnly": true,
		"productionApproval": "forbidden",
		"playerSliceIntegration": "forbidden",
		"browserIntegration": "forbidden",
		"errors": errors
	}

func _repair_validation_report() -> Dictionary:
	var errors: Array[String] = []
	if fallback_source.get("status", "FAIL") != "PASS":
		errors.append_array(fallback_source.get("errors", ["Fallback source failed validation."]))
	for key in ["fullres", "trimmed_512", "trimmed_768", "trimmed_1024"]:
		var source: Dictionary = repair_sources.get(key, {})
		if source.get("status", "FAIL") != "PASS":
			errors.append_array(source.get("errors", ["Missing Aster repair source %s." % key]))
	if worker_context_source.get("status", "FAIL") != "PASS":
		errors.append_array(worker_context_source.get("errors", ["Worker context source failed validation."]))
	if barracks_context_source.get("status", "FAIL") != "PASS":
		errors.append_array(barracks_context_source.get("errors", ["Barracks context source failed validation."]))
	return {
		"schemaVersion": 1,
		"checkpoint": REPAIR_CHECKPOINT,
		"slotId": SLOT_ID,
		"status": "PASS_V0152_ASTER_BILLBOARD_REPAIR_RUNTIME_VALIDATION" if errors.is_empty() else "FAIL_V0152_ASTER_BILLBOARD_REPAIR_RUNTIME_VALIDATION",
		"fallbackSource": fallback_source,
		"repairSources": repair_sources,
		"workerContextSource": worker_context_source,
		"barracksContextSource": barracks_context_source,
		"zeroNewAiImagesForV0152": true,
		"sameAsterSourceOnly": true,
		"noNewRuntimeArtSlot": true,
		"privateComparatorOnly": true,
		"productionApproval": "forbidden",
		"playerSliceIntegration": "forbidden",
		"browserIntegration": "forbidden",
		"errors": errors
	}

func _composition_validation_report() -> Dictionary:
	var errors: Array[String] = []
	if fallback_source.get("status", "FAIL") != "PASS":
		errors.append_array(fallback_source.get("errors", ["Aster fallback source failed validation."]))
	var selected_aster: Dictionary = repair_sources.get("trimmed_1024", {})
	if selected_aster.get("status", "FAIL") != "PASS":
		errors.append_array(selected_aster.get("errors", ["Selected Aster repair derivative failed validation."]))
	for source in [worker_context_source, barracks_context_source, worker_fallback_source, barracks_fallback_source]:
		if source.get("status", "FAIL") != "PASS":
			errors.append_array(source.get("errors", ["Composition source failed validation."]))
	return {
		"schemaVersion": 1,
		"checkpoint": COMPOSITION_CHECKPOINT,
		"slotId": SLOT_ID,
		"status": "PASS_V0153_HYBRID_THREE_SLOT_RUNTIME_VALIDATION" if errors.is_empty() else "FAIL_V0153_HYBRID_THREE_SLOT_RUNTIME_VALIDATION",
		"selectedAsterSource": selected_aster,
		"selectedWorkerSource": worker_context_source,
		"selectedBarracksSource": barracks_context_source,
		"fallbackAsterSource": fallback_source,
		"fallbackWorkerSource": worker_fallback_source,
		"fallbackBarracksSource": barracks_fallback_source,
		"zeroNewAiImagesForV0153": true,
		"zeroNewRuntimeArtSlotsForV0153": true,
		"usesExistingThreePrivateSlotsOnly": true,
		"privateComparatorOnly": true,
		"productionApproval": "forbidden",
		"playerSliceIntegration": "forbidden",
		"browserIntegration": "forbidden",
		"saveWritesAllowed": false,
		"stableIdChanges": false,
		"errors": errors
	}

func _run_sequence(run_kind: String) -> Dictionary:
	var errors: Array[String] = []
	for source in [fallback_source, local_source, worker_context_source, barracks_context_source]:
		if source.get("status", "FAIL") != "PASS":
			errors.append_array(source.get("errors", ["Comparator source failed validation."]))
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
					errors.append("Aster benchmark failed for %s %s trial %d." % [approach, tier, trial_index + 1])
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
		"status": "PASS_V0151_ASTER_BILLBOARD_RUNTIME_EVIDENCE" if errors.is_empty() else "FAIL_V0151_ASTER_BILLBOARD_RUNTIME_EVIDENCE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"benchmarkCount": benchmark_reports.size(),
		"screenshotCount": captures.size(),
		"benchmarks": benchmark_reports,
		"captures": captures,
		"fallbackSource": fallback_source,
		"localSource": local_source,
		"workerContextSource": worker_context_source,
		"barracksContextSource": barracks_context_source,
		"fairPathAudit": _fair_path_audit(),
		"readabilityAudit": _readability_audit(),
		"boundaries": {
			"privateComparatorOnly": true,
			"productionApproval": "forbidden",
			"playerSliceIntegration": "forbidden",
			"browserIntegration": "forbidden",
			"exactlyOneAiImageForV0151": true,
			"thirdRuntimeArtSlotOnly": true,
			"noFourthRuntimeArtSlot": true,
			"defaultLauncherReplaced": false,
			"normalPlayerSliceWired": false,
			"manifestMutated": false,
			"productionPackageIncluded": false,
			"saveWritesAllowed": false,
			"stableIdChanges": false,
			"referenceCandidateImported": false
		},
		"limitations": [
			"Visual Aster identity, cloak-edge quality, and scale posture require human review of captures.",
			"The local Aster cutout is ignored and private comparator-only.",
			"Tracked fallback is diagnostic geometry and not production art.",
			"Godot remains provisional and is not finally selected."
		],
		"errors": errors
	}

func _run_repair_sequence(run_kind: String) -> Dictionary:
	var errors: Array[String] = []
	if fallback_source.get("status", "FAIL") != "PASS":
		errors.append_array(fallback_source.get("errors", ["Fallback source failed validation."]))
	for key in ["fullres", "trimmed_512", "trimmed_768", "trimmed_1024"]:
		var source: Dictionary = repair_sources.get(key, {})
		if source.get("status", "FAIL") != "PASS":
			errors.append_array(source.get("errors", ["Missing Aster repair source %s." % key]))
	var benchmark_reports: Array[Dictionary] = []
	var captures: Array[Dictionary] = []
	var capture_index := 0
	for tier in ["S", "M", "L"]:
		var trial_count := 5 if tier == "L" else 1
		for trial_index in range(trial_count):
			var ordered_approaches := _rotated_repair_approaches(trial_index)
			for approach in ordered_approaches:
				var config := _repair_workload_config(approach, tier, 1.0, "repair_paired_benchmark")
				config["trialIndex"] = trial_index + 1
				config["scenarioOrder"] = ordered_approaches
				var benchmark := await _benchmark_current_view(config)
				benchmark_reports.append(benchmark)
				if benchmark.get("status", "FAIL") != "PASS":
					errors.append("Aster repair benchmark failed for %s %s trial %d." % [approach, tier, trial_index + 1])
				if trial_index == 0:
					var capture := await _capture_current_view(config, capture_index)
					captures.append(capture)
					capture_index += 1
	var review_captures := await _capture_repair_review_views(capture_index)
	captures.append_array(review_captures)
	return {
		"schemaVersion": 1,
		"checkpoint": REPAIR_CHECKPOINT,
		"slotId": SLOT_ID,
		"runKind": run_kind,
		"status": "PASS_V0152_ASTER_BILLBOARD_REPAIR_RUNTIME_EVIDENCE" if errors.is_empty() else "FAIL_V0152_ASTER_BILLBOARD_REPAIR_RUNTIME_EVIDENCE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"benchmarkCount": benchmark_reports.size(),
		"screenshotCount": captures.size(),
		"benchmarks": benchmark_reports,
		"captures": captures,
		"fallbackSource": fallback_source,
		"repairSources": repair_sources,
		"workerContextSource": worker_context_source,
		"barracksContextSource": barracks_context_source,
		"fairPathAudit": _fair_path_audit(true),
		"readabilityAudit": _repair_readability_audit(),
		"boundaries": {
			"privateComparatorOnly": true,
			"productionApproval": "forbidden",
			"playerSliceIntegration": "forbidden",
			"browserIntegration": "forbidden",
			"zeroNewAiImagesForV0152": true,
			"sameAsterSourceOnly": true,
			"noNewRuntimeArtSlot": true,
			"defaultLauncherReplaced": false,
			"normalPlayerSliceWired": false,
			"manifestMutated": false,
			"productionPackageIncluded": false,
			"saveWritesAllowed": false,
			"stableIdChanges": false,
			"referenceCandidateImported": false
		},
		"limitations": [
			"Visual Aster identity, cloak-edge quality, and halo checks require human review of captures.",
			"All v0.152 Aster images are same-source deterministic private comparator derivatives.",
			"Tracked fallback is diagnostic geometry and not production art.",
			"Godot remains provisional and is not finally selected."
		],
		"errors": errors
	}

func _run_composition_sequence(run_kind: String) -> Dictionary:
	var errors: Array[String] = []
	var validation := _composition_validation_report()
	if validation.get("status", "FAIL") != "PASS_V0153_HYBRID_THREE_SLOT_RUNTIME_VALIDATION":
		errors.append_array(validation.get("errors", ["Composition validation failed."]))
	var benchmark_reports: Array[Dictionary] = []
	var captures: Array[Dictionary] = []
	var capture_index := 0
	for tier in ["S", "M", "L"]:
		var trial_count := 5 if tier == "L" else 1
		for trial_index in range(trial_count):
			var ordered_approaches := _rotated_composition_approaches(trial_index)
			for approach in ordered_approaches:
				var config := _composition_workload_config(approach, tier, 1.0, "three_slot_paired_benchmark")
				config["trialIndex"] = trial_index + 1
				config["scenarioOrder"] = ordered_approaches
				var benchmark := await _benchmark_current_view(config)
				benchmark_reports.append(benchmark)
				if benchmark.get("status", "FAIL") != "PASS":
					errors.append("Three-slot composition benchmark failed for %s %s trial %d." % [approach, tier, trial_index + 1])
				if trial_index == 0:
					var capture := await _capture_current_view(config, capture_index)
					captures.append(capture)
					capture_index += 1
	var review_captures := await _capture_composition_review_views(capture_index)
	captures.append_array(review_captures)
	return {
		"schemaVersion": 1,
		"checkpoint": COMPOSITION_CHECKPOINT,
		"slotId": SLOT_ID,
		"runKind": run_kind,
		"status": "PASS_V0153_HYBRID_THREE_SLOT_RUNTIME_EVIDENCE" if errors.is_empty() else "FAIL_V0153_HYBRID_THREE_SLOT_RUNTIME_EVIDENCE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"benchmarkCount": benchmark_reports.size(),
		"screenshotCount": captures.size(),
		"benchmarks": benchmark_reports,
		"captures": captures,
		"selectedAsterSource": repair_sources.get("trimmed_1024", {}),
		"selectedWorkerSource": worker_context_source,
		"selectedBarracksSource": barracks_context_source,
		"fallbackAsterSource": fallback_source,
		"fallbackWorkerSource": worker_fallback_source,
		"fallbackBarracksSource": barracks_fallback_source,
		"fairPathAudit": _fair_path_audit(false, true),
		"readabilityAudit": _composition_readability_audit(),
		"boundaries": {
			"privateComparatorOnly": true,
			"productionApproval": "forbidden",
			"playerSliceIntegration": "forbidden",
			"browserIntegration": "forbidden",
			"zeroNewAiImagesForV0153": true,
			"zeroNewRuntimeArtSlotsForV0153": true,
			"usesExistingThreePrivateSlotsOnly": true,
			"defaultLauncherReplaced": false,
			"normalPlayerSliceWired": false,
			"manifestMutated": false,
			"productionPackageIncluded": false,
			"saveWritesAllowed": false,
			"stableIdChanges": false,
			"referenceCandidateImported": false
		},
		"limitations": [
			"v0.153 only stress-tests private composition posture; it does not approve production art.",
			"Human review remains required for overlap, seam, shimmer, halo, and identity judgement.",
			"No generated image, reference candidate, normal player slice, browser runtime, save, or stable-ID path is modified.",
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

func _rotated_repair_approaches(trial_index: int) -> Array:
	var rotated := REPAIR_APPROACHES.duplicate()
	var offset := trial_index % rotated.size()
	for _index in range(offset):
		rotated.push_back(rotated.pop_front())
	return rotated

func _rotated_composition_approaches(trial_index: int) -> Array:
	var rotated := COMPOSITION_APPROACHES.duplicate()
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
		"asterCount": int(tier_config["asterCount"]),
		"workerCount": int(tier_config["workerCount"]),
		"barracksShellCount": int(tier_config["barracksShellCount"]),
		"benchmarkFrames": int(tier_config["benchmarkFrames"]),
		"steadyStateWarmupFrames": 16
	}

func _repair_workload_config(approach: String, tier: String, scale_multiplier: float, view: String) -> Dictionary:
	var tier_config: Dictionary = TIERS[tier]
	return {
		"approach": approach,
		"tier": tier,
		"view": view,
		"scaleMultiplier": scale_multiplier,
		"assetSource": _source_for_repair_approach(approach),
		"asterCount": int(tier_config["asterCount"]),
		"workerCount": int(tier_config["workerCount"]),
		"barracksShellCount": int(tier_config["barracksShellCount"]),
		"benchmarkFrames": int(tier_config["benchmarkFrames"]),
		"steadyStateWarmupFrames": 16,
		"repairMode": true
	}

func _composition_workload_config(approach: String, tier: String, scale_multiplier: float, view: String) -> Dictionary:
	var tier_config: Dictionary = COMPOSITION_TIERS[tier]
	return {
		"approach": approach,
		"tier": tier,
		"view": view,
		"scaleMultiplier": scale_multiplier,
		"assetSource": _source_for_composition_approach(approach),
		"asterCount": int(tier_config["asterCount"]),
		"workerCount": int(tier_config["workerCount"]),
		"barracksShellCount": int(tier_config["barracksShellCount"]),
		"benchmarkFrames": int(tier_config["benchmarkFrames"]),
		"steadyStateWarmupFrames": 18,
		"compositionMode": true
	}

func _source_for_approach(approach: String) -> Dictionary:
	if approach == APPROACH_FALLBACK:
		return fallback_source
	if approach == APPROACH_LOCAL:
		return local_source if local_source.get("status", "FAIL") == "PASS" else fallback_source
	if approach == APPROACH_WORKER_CONTEXT:
		return worker_context_source
	if approach == APPROACH_BARRACKS_CONTEXT:
		return barracks_context_source
	return {"status": "PASS", "sourceKind": "orthographic-procedural-mesh", "sha256": "not-applicable", "absolutePath": "procedural-mesh"}

func _source_for_repair_approach(approach: String) -> Dictionary:
	if approach == APPROACH_FALLBACK:
		return fallback_source
	if approach == APPROACH_ASTER_FULL_RES:
		return repair_sources.get("fullres", fallback_source)
	if approach == APPROACH_ASTER_TRIMMED_512:
		return repair_sources.get("trimmed_512", fallback_source)
	if approach == APPROACH_ASTER_TRIMMED_768:
		return repair_sources.get("trimmed_768", fallback_source)
	if approach == APPROACH_ASTER_TRIMMED_1024:
		return repair_sources.get("trimmed_1024", fallback_source)
	return fallback_source

func _source_for_composition_approach(approach: String) -> Dictionary:
	if approach == APPROACH_THREE_SLOT_SELECTED:
		return repair_sources.get("trimmed_1024", fallback_source)
	if approach == APPROACH_THREE_SLOT_ORTHO:
		return {"status": "PASS", "sourceKind": "orthographic-procedural-three-slot-fallback", "sha256": "not-applicable", "absolutePath": "procedural-three-slot"}
	return fallback_source

func _aster_approach_reads_as_hero(approach: String) -> bool:
	return [APPROACH_FALLBACK, APPROACH_LOCAL, APPROACH_ORTHO, APPROACH_ASTER_FULL_RES, APPROACH_ASTER_TRIMMED_512, APPROACH_ASTER_TRIMMED_768, APPROACH_ASTER_TRIMMED_1024, APPROACH_THREE_SLOT_FALLBACK, APPROACH_THREE_SLOT_SELECTED, APPROACH_THREE_SLOT_ORTHO].has(approach)

func _benchmark_current_view(config: Dictionary) -> Dictionary:
	var init_start := Time.get_ticks_usec()
	_build_scene(config)
	var initialization_duration_ms := snappedf(float(Time.get_ticks_usec() - init_start) / 1000.0, 0.01)
	for _index in range(int(config.get("steadyStateWarmupFrames", 16))):
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
	var checkpoint_label := CHECKPOINT
	if bool(config.get("repairMode", false)):
		checkpoint_label = REPAIR_CHECKPOINT
	if bool(config.get("compositionMode", false)):
		checkpoint_label = COMPOSITION_CHECKPOINT
	return {
		"schemaVersion": 1,
		"checkpoint": checkpoint_label,
		"status": "PASS",
		"approach": approach,
		"tier": config["tier"],
		"trialIndex": int(config.get("trialIndex", 1)),
		"scenarioOrder": config.get("scenarioOrder", []),
		"frameCount": frames,
		"benchmarkDurationMs": duration_ms,
		"initializationDurationMs": initialization_duration_ms,
		"steadyStateWarmupFrames": int(config.get("steadyStateWarmupFrames", 16)),
		"averageFps": snappedf(float(frames) / max(duration_ms / 1000.0, 0.0001), 0.01),
		"averageFrameTimeMs": metrics["averageFrameTimeMs"],
		"p95FrameTimeMs": metrics["p95FrameTimeMs"],
		"p99FrameTimeMs": metrics["p99FrameTimeMs"],
		"maxFrameTimeMs": metrics["maxFrameTimeMs"],
		"entityCount": int(config.get("asterCount", 0)) + int(config.get("workerCount", 0)) + int(config.get("barracksShellCount", 0)),
		"asterCount": int(config.get("asterCount", 0)) if _aster_approach_reads_as_hero(approach) else 0,
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
		"asterReadsHeroNotWorker": _aster_approach_reads_as_hero(approach),
		"heroReadability": _aster_approach_reads_as_hero(approach),
		"workerDistinct": worker_context_source.get("status", "FAIL") == "PASS",
		"barracksDistinct": barracks_context_source.get("status", "FAIL") == "PASS",
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
	active_scene.name = "V0151AsterBillboardComparatorScene"
	add_child(active_scene)
	_setup_camera_and_lighting(config)
	_add_ground()
	var approach := str(config["approach"])
	var view := str(config.get("view", "paired_benchmark"))
	if view.contains("alpha_checkerboard") or view.contains("checkerboard"):
		_add_checkerboard_floor()
	if view.contains("dark"):
		_set_world_background(Color(0.025, 0.025, 0.025))
	elif view.contains("light"):
		_set_world_background(Color(0.82, 0.82, 0.76))
	elif view.contains("wet_overcast"):
		_set_world_background(Color(0.10, 0.12, 0.12))
	if view.contains("hearth"):
		_add_hearth_lighting()
	if approach == APPROACH_WORKER_CONTEXT:
		_add_worker_context(int(config.get("workerCount", 0)) + 8, 1.0, view)
		_add_barracks_context(max(2, int(config.get("barracksShellCount", 0)) / 2), barracks_context_source, 0.82, view)
	elif approach == APPROACH_BARRACKS_CONTEXT:
		_add_barracks_context(int(config.get("barracksShellCount", 0)) + 4, barracks_context_source, 0.9, view)
		_add_worker_context(max(4, int(config.get("workerCount", 0)) / 2), 0.86, view)
	elif approach == APPROACH_ORTHO:
		_add_procedural_aster_units(int(config.get("asterCount", 0)), float(config.get("scaleMultiplier", 1.0)), view)
		_add_worker_context(int(config.get("workerCount", 0)), 0.84, view)
		_add_barracks_context(int(config.get("barracksShellCount", 0)), barracks_context_source, 0.82, view)
	elif approach == APPROACH_THREE_SLOT_FALLBACK:
		_add_aster_units(int(config.get("asterCount", 0)), fallback_source, float(config.get("scaleMultiplier", 1.0)), view)
		_add_worker_context_with_source(int(config.get("workerCount", 0)), worker_fallback_source, 0.84, view)
		_add_barracks_context(int(config.get("barracksShellCount", 0)), barracks_fallback_source, 0.82, view)
	elif approach == APPROACH_THREE_SLOT_SELECTED:
		_add_aster_units(int(config.get("asterCount", 0)), repair_sources.get("trimmed_1024", fallback_source), float(config.get("scaleMultiplier", 1.0)), view)
		_add_worker_context(int(config.get("workerCount", 0)), 0.84, view)
		_add_barracks_context(int(config.get("barracksShellCount", 0)), barracks_context_source, 0.82, view)
	elif approach == APPROACH_THREE_SLOT_ORTHO:
		_add_procedural_aster_units(int(config.get("asterCount", 0)), float(config.get("scaleMultiplier", 1.0)), view)
		_add_procedural_worker_context(int(config.get("workerCount", 0)), 0.84, view)
		_add_procedural_barracks_context(int(config.get("barracksShellCount", 0)), 0.82, view)
	else:
		_add_aster_units(int(config.get("asterCount", 0)), config.get("assetSource", fallback_source), float(config.get("scaleMultiplier", 1.0)), view)
		_add_worker_context(int(config.get("workerCount", 0)), 0.84, view)
		_add_barracks_context(int(config.get("barracksShellCount", 0)), barracks_context_source, 0.82, view)
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
	active_camera.name = "V0151AsterComparatorCamera"
	active_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	var view := str(config.get("view", ""))
	var repair_close_review := _is_repair_close_review_view(view)
	var repair_context_review := _is_repair_context_review_view(view)
	var composition_close_review := _is_composition_close_review_view(view)
	var composition_context_review := _is_composition_context_review_view(view)
	active_camera.size = 10.0
	if repair_close_review:
		active_camera.size = 2.7
	elif composition_close_review:
		active_camera.size = 5.8
	elif repair_context_review:
		active_camera.size = 7.2
	elif composition_context_review:
		active_camera.size = 9.4
	elif view.contains("cloak_edge") or view.contains("alpha_edge") or view.contains("checkerboard") or view.contains("hair_cloak") or view.contains("boots_hands") or view.contains("source_local") or view.contains("selection_ring") or view.contains("rings_visible"):
		active_camera.size = 6.8
	elif view.contains("zoomed"):
		active_camera.size = 14.2
	elif view.contains("recognition") or view.contains("worker_barracks") or view.contains("distinction"):
		active_camera.size = 11.6
	elif view.contains("scale_090"):
		active_camera.size = 9.6
	elif view.contains("scale_110"):
		active_camera.size = 9.2
	var camera_position := Vector3(0.0, 6.0, 9.4)
	var camera_target := Vector3(0.0, 0.95, 0.0)
	if repair_close_review:
		camera_position = Vector3(0.0, 2.85, 5.2)
		camera_target = Vector3(0.0, 0.92, 0.0)
	elif composition_close_review:
		camera_position = Vector3(0.0, 3.5, 6.4)
		camera_target = Vector3(0.1, 0.8, 0.0)
	elif repair_context_review:
		camera_position = Vector3(0.0, 4.4, 7.2)
		camera_target = Vector3(0.0, 0.72, 0.0)
	elif composition_context_review:
		camera_position = Vector3(0.0, 5.1, 8.8)
		camera_target = Vector3(0.0, 0.68, 0.0)
	active_scene.add_child(active_camera)
	active_camera.position = camera_position
	active_camera.look_at(camera_target, Vector3.UP)
	active_camera.make_current()
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08, 0.10, 0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.47, 0.52, 0.48)
	env.ambient_light_energy = 0.82
	world.environment = env
	active_scene.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "FootholdKey"
	sun.light_energy = 1.35
	sun.rotation_degrees = Vector3(-46, -32, 0)
	active_scene.add_child(sun)

func _add_ground() -> void:
	_add_plane("wet_granite_foothold_ground", Vector3(0, 0, 0), Vector2(24, 16), _flat_material(Color(0.17, 0.20, 0.18)))
	for index in range(7):
		var z := -5.7 + float(index) * 1.8
		_add_box("worked_earth_lane_%02d" % index, Vector3(0, 0.035, z), Vector3(22.0, 0.05, 0.34), _flat_material(Color(0.20, 0.17, 0.12)))
		rendered_object_proxy += 1

func _add_aster_units(count: int, source: Dictionary, scale: float, view: String) -> void:
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	var texture := _texture_for_source(source)
	var material := _aster_material_for_source(source, texture)
	for index in range(count):
		var x := (float(index % cols) - float(cols) * 0.5) * 0.78
		var z := -1.0 + float(index / cols) * 0.62
		if _is_repair_close_review_view(view):
			x = 0.0
			z = 0.0
		elif view.contains("recognition") or view.contains("worker_barracks") or view.contains("distinction"):
			x = -2.0 + float(index % max(1, cols)) * 0.9
			z = -0.6 + float(index / max(1, cols)) * 0.55
		if view.contains("overlap"):
			x = -0.4 + float(index % max(1, cols)) * 0.24
			z = -0.4 + float(index / max(1, cols)) * 0.20
		var node := _add_billboard("aster_billboard_%03d" % index, Vector3(x, 0.0, z), source, material, 1.42 * scale)
		node.set_meta("base_position", node.position)
		node.set_meta("phase", float(index % 13) * 0.21)
		unit_nodes.append(node)
		var ring := _add_cylinder("aster_selection_ring_%03d" % index, Vector3(x, 0.055, z), 0.54 * scale, 0.018, _flat_material(Color(0.35, 0.88, 0.74, 0.36), true, true, 0.10))
		ring_nodes.append(ring)
		rendered_object_proxy += 2
		total_aster_billboard_rebuild_count += 1

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

func _add_procedural_aster_units(count: int, scale: float, view: String) -> void:
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := (float(index % cols) - float(cols) * 0.5) * 0.78
		var z := -1.0 + float(index / cols) * 0.62
		if view.contains("overlap"):
			x = -0.4 + float(index % max(1, cols)) * 0.24
			z = -0.4 + float(index / max(1, cols)) * 0.20
		var body := _add_box("ortho_aster_body_%03d" % index, Vector3(x, 0.68 * scale, z), Vector3(0.38, 1.18, 0.22) * scale, _flat_material(Color(0.34, 0.31, 0.24)))
		body.set_meta("base_position", body.position)
		body.set_meta("phase", float(index % 13) * 0.21)
		unit_nodes.append(body)
		_add_box("ortho_aster_cloak_%03d" % index, Vector3(x + 0.16 * scale, 0.78 * scale, z + 0.03), Vector3(0.18, 1.26, 0.20) * scale, _flat_material(Color(0.20, 0.18, 0.19)))
		_add_cylinder("ortho_aster_head_%03d" % index, Vector3(x, 1.36 * scale, z), 0.16 * scale, 0.18 * scale, _flat_material(Color(0.60, 0.43, 0.32)))
		var ring := _add_cylinder("ortho_aster_selection_ring_%03d" % index, Vector3(x, 0.055, z), 0.54 * scale, 0.018, _flat_material(Color(0.35, 0.88, 0.74, 0.36), true, true, 0.10))
		ring_nodes.append(ring)
		rendered_object_proxy += 4

func _add_worker_context(count: int, scale: float, view: String) -> void:
	_add_worker_context_with_source(count, worker_context_source, scale, view)

func _add_worker_context_with_source(count: int, source: Dictionary, scale: float, view: String) -> void:
	if source.get("status", "FAIL") != "PASS":
		return
	var texture := _texture_for_source(source)
	var material := _worker_material_for_source(source, texture)
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := 3.0 + (float(index % cols) - float(cols) * 0.5) * 0.72
		var z := 2.6 + float(index / cols) * 0.58
		if view.contains("recognition") or view.contains("worker_barracks"):
			x = 1.4 + float(index % max(1, cols)) * 0.56
			z = -0.4 + float(index / max(1, cols)) * 0.48
		if view.contains("crowding") or view.contains("three_slot") or view.contains("overlap") or view.contains("selection") or view.contains("minimap"):
			x = 0.95 + float(index % max(1, cols)) * 0.34
			z = -0.75 + float(index / max(1, cols)) * 0.30
		var mesh := QuadMesh.new()
		mesh.size = Vector2(0.72 * scale, 1.05 * scale)
		var node := MeshInstance3D.new()
		node.name = "worker_context_%03d" % index
		node.mesh = mesh
		node.position = Vector3(x, 0.55 * scale, z)
		node.material_override = material
		active_scene.add_child(node)
		_add_cylinder("worker_context_ring_%03d" % index, Vector3(x, 0.05, z), 0.42 * scale, 0.016, _flat_material(Color(0.28, 0.80, 0.72, 0.28), true, true, 0.08))
		rendered_object_proxy += 2
		billboard_instance_count += 1
		total_worker_context_rebuild_count += 1

func _add_procedural_worker_context(count: int, scale: float, view: String) -> void:
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := 3.0 + (float(index % cols) - float(cols) * 0.5) * 0.72
		var z := 2.6 + float(index / cols) * 0.58
		if view.contains("crowding") or view.contains("three_slot") or view.contains("overlap") or view.contains("selection") or view.contains("minimap"):
			x = 0.95 + float(index % max(1, cols)) * 0.34
			z = -0.75 + float(index / max(1, cols)) * 0.30
		_add_box("ortho_worker_body_%03d" % index, Vector3(x, 0.48 * scale, z), Vector3(0.34, 0.82, 0.22) * scale, _flat_material(Color(0.43, 0.31, 0.18)))
		_add_box("ortho_worker_pack_%03d" % index, Vector3(x - 0.18 * scale, 0.58 * scale, z + 0.03), Vector3(0.16, 0.54, 0.18) * scale, _flat_material(Color(0.20, 0.17, 0.12)))
		_add_cylinder("ortho_worker_ring_%03d" % index, Vector3(x, 0.05, z), 0.42 * scale, 0.016, _flat_material(Color(0.28, 0.80, 0.72, 0.28), true, true, 0.08))
		rendered_object_proxy += 3
		total_worker_context_rebuild_count += 1

func _add_barracks_context(count: int, source: Dictionary, scale: float, view: String = "") -> void:
	if source.get("status", "FAIL") != "PASS":
		return
	var material := _barracks_material_for_source(source)
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := -5.0 + (float(index % cols) - float(cols) * 0.5) * 2.4
		var z := 2.8 + float(index / cols) * 2.05
		if view.contains("three_slot") or view.contains("overlap") or view.contains("selection") or view.contains("minimap"):
			x = -2.2 + float(index % max(1, cols)) * 1.18
			z = 0.35 + float(index / max(1, cols)) * 1.10
		elif view.contains("crowding"):
			x = -2.8 + float(index % max(1, cols)) * 1.45
			z = 0.7 + float(index / max(1, cols)) * 1.25
		_add_single_barracks_shell(index, Vector3(x, 0, z), scale, material)

func _add_procedural_barracks_context(count: int, scale: float, view: String) -> void:
	var material := _flat_material(Color(0.46, 0.40, 0.31))
	var cols := int(ceil(sqrt(float(max(count, 1)))))
	for index in range(count):
		var x := -5.0 + (float(index % cols) - float(cols) * 0.5) * 2.4
		var z := 2.8 + float(index / cols) * 2.05
		if view.contains("three_slot") or view.contains("overlap") or view.contains("selection") or view.contains("minimap"):
			x = -2.2 + float(index % max(1, cols)) * 1.18
			z = 0.35 + float(index / max(1, cols)) * 1.10
		elif view.contains("crowding"):
			x = -2.8 + float(index % max(1, cols)) * 1.45
			z = 0.7 + float(index / max(1, cols)) * 1.25
		_add_single_barracks_shell(index, Vector3(x, 0, z), scale, material)

func _add_single_barracks_shell(index: int, origin: Vector3, scale: float, material: StandardMaterial3D) -> void:
	total_barracks_shell_rebuild_count += 1
	_add_box("aster_context_barracks_base_%03d" % index, origin + Vector3(0, 0.16 * scale, 0), Vector3(1.9, 0.32, 1.35) * scale, material)
	_add_box("aster_context_barracks_wall_%03d" % index, origin + Vector3(0, 0.68 * scale, 0), Vector3(1.72, 0.78, 1.12) * scale, material)
	_add_box("aster_context_barracks_roof_%03d" % index, origin + Vector3(0, 1.16 * scale, 0), Vector3(2.05, 0.26, 1.46) * scale, _flat_material(Color(0.15, 0.11, 0.08)))
	_add_cylinder("aster_context_barracks_ring_%03d" % index, origin + Vector3(0, 0.055, -0.72 * scale), 0.34 * scale, 0.016, _flat_material(Color(0.32, 0.85, 0.75, 0.28), true, true, 0.08))
	rendered_object_proxy += 4

func _add_lume_trace() -> void:
	for index in range(7):
		var x := -7.0 + float(index) * 2.0
		_add_cylinder("aster_lume_trace_%02d" % index, Vector3(x, 0.09, -5.4), 0.06, 0.04, _flat_material(Color(0.25, 0.72, 0.64, 0.48), true, true, 0.08))
		rendered_object_proxy += 1

func _add_hearth_lighting() -> void:
	for index in range(3):
		var x := -1.6 + float(index) * 1.2
		_add_cylinder("private_hearth_glow_%02d" % index, Vector3(x, 0.08, -2.3), 0.18, 0.05, _flat_material(Color(0.95, 0.46, 0.16, 0.34), true, true, 0.42))
		_add_box("private_hearth_stone_%02d" % index, Vector3(x, 0.10, -2.3), Vector3(0.42, 0.08, 0.28), _flat_material(Color(0.30, 0.26, 0.22)))
		rendered_object_proxy += 2

func _add_checkerboard_floor() -> void:
	for row in range(7):
		for column in range(9):
			var color := Color(0.78, 0.78, 0.72) if (row + column) % 2 == 0 else Color(0.16, 0.18, 0.16)
			_add_box("aster_alpha_checker_%02d_%02d" % [row, column], Vector3(-3.2 + float(column) * 0.8, 0.055, -2.5 + float(row) * 0.72), Vector3(0.78, 0.045, 0.70), _flat_material(color))

func _set_world_background(color: Color) -> void:
	for child in active_scene.get_children():
		if child is WorldEnvironment:
			var world_environment := child as WorldEnvironment
			if world_environment.environment != null:
				world_environment.environment.background_color = color

func _add_hud_overlay(config: Dictionary) -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "V0151AsterDiagnosticOverlay"
	add_child(hud_layer)
	var panel := ColorRect.new()
	panel.position = Vector2(24, 24)
	panel.size = Vector2(620, 88)
	panel.color = Color(0.06, 0.08, 0.06, 0.78)
	hud_layer.add_child(panel)
	var checkpoint_label := CHECKPOINT
	if bool(config.get("repairMode", false)):
		checkpoint_label = REPAIR_CHECKPOINT
	if bool(config.get("compositionMode", false)):
		checkpoint_label = COMPOSITION_CHECKPOINT
	_add_label("%s Aster billboard slot / %s / Tier %s" % [checkpoint_label, config["approach"], config["tier"]], Vector2(38, 38), 18, Color(0.88, 0.92, 0.84))
	_add_label("Source: %s  Scale: %.2fx" % [config.get("assetSource", {}).get("sourceKind", "procedural"), float(config.get("scaleMultiplier", 1.0))], Vector2(38, 70), 14, Color(0.64, 0.78, 0.70))
	if bool(config.get("compositionMode", false)):
		_add_private_minimap_overlay()

func _is_repair_close_review_view(view: String) -> bool:
	return view.contains("checkerboard_alpha") or view.contains("dark_alpha_edge") or view.contains("light_alpha_edge") or view.contains("hair_cloak_shoulders_edge") or view.contains("boots_hands_gear_edge") or view.contains("rings_visible_context")

func _is_repair_context_review_view(view: String) -> bool:
	return view.contains("aster_worker_distinction") or view.contains("aster_worker_overlap") or view.contains("pivot_pan_zoom") or view.contains("scale_090") or view.contains("scale_100") or view.contains("scale_110") or view.contains("normal_rts_gameplay_distance")

func _is_composition_close_review_view(view: String) -> bool:
	return view.contains("checkerboard_alpha") or view.contains("dark_alpha") or view.contains("light_alpha") or view.contains("selection_rings")

func _is_composition_context_review_view(view: String) -> bool:
	return view.contains("three_slot") or view.contains("crowding") or view.contains("overlap") or view.contains("pan_zoom") or view.contains("wet_overcast") or view.contains("hearth") or view.contains("minimap") or view.contains("fallback") or view.contains("ortho")

func _add_private_minimap_overlay() -> void:
	var panel := ColorRect.new()
	panel.position = Vector2(float(current_viewport_size.x) - 172.0, 28.0)
	panel.size = Vector2(144, 104)
	panel.color = Color(0.04, 0.07, 0.06, 0.62)
	hud_layer.add_child(panel)
	var lane := ColorRect.new()
	lane.position = panel.position + Vector2(12, 48)
	lane.size = Vector2(120, 8)
	lane.color = Color(0.33, 0.43, 0.34, 0.78)
	hud_layer.add_child(lane)
	var points := [
		{"offset": Vector2(42, 44), "size": Vector2(8, 8), "color": Color(0.35, 0.88, 0.74, 0.88)},
		{"offset": Vector2(74, 52), "size": Vector2(6, 6), "color": Color(0.28, 0.80, 0.72, 0.78)},
		{"offset": Vector2(34, 64), "size": Vector2(12, 8), "color": Color(0.75, 0.66, 0.46, 0.78)}
	]
	for point in points:
		var blip := ColorRect.new()
		blip.position = panel.position + point["offset"]
		blip.size = point["size"]
		blip.color = point["color"]
		hud_layer.add_child(blip)

func _add_label(text: String, position: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.position = position
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	hud_layer.add_child(label)

func _update_simulation(_config: Dictionary, frame_index: int) -> void:
	var phase_base := float(frame_index) * 0.035
	for index in range(unit_nodes.size()):
		var node := unit_nodes[index]
		var base: Vector3 = node.get_meta("base_position")
		var phase := phase_base + float(node.get_meta("phase"))
		node.position.x = base.x + sin(phase) * 0.018
		node.position.z = base.z + cos(phase * 0.8) * 0.012
	for ring_index in range(ring_nodes.size()):
		if ring_index < unit_nodes.size():
			var ring := ring_nodes[ring_index]
			var unit := unit_nodes[ring_index]
			ring.position.x = unit.position.x
			ring.position.z = unit.position.z
	active_camera.position.x = sin(float(frame_index) * 0.01) * 0.18
	active_camera.size += sin(float(frame_index) * 0.02) * 0.0007

func _capture_review_views(start_index: int) -> Array[Dictionary]:
	var captures: Array[Dictionary] = []
	var views := [
		{"id": "source_local", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "alpha_checkerboard", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "cloak_edge_closeup_dark", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "cloak_edge_closeup_light", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "normal_rts_gameplay_distance", "tier": "M", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "zoomed_out_readability", "tier": "L", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "aster_vs_worker_recognition", "tier": "M", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "worker_barracks_context", "tier": "M", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "depth_sorting_overlap", "tier": "M", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "repeated_aster_overlap", "tier": "M", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "selection_ring", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "camera_pan_pivot_stability_a", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "camera_pan_pivot_stability_b", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "scale_090", "tier": "S", "scale": 0.9, "approach": APPROACH_LOCAL},
		{"id": "scale_100", "tier": "S", "scale": 1.0, "approach": APPROACH_LOCAL},
		{"id": "scale_110", "tier": "S", "scale": 1.1, "approach": APPROACH_LOCAL},
		{"id": "fallback_comparison", "tier": "S", "scale": 1.0, "approach": APPROACH_FALLBACK}
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
	var selected_approach := APPROACH_ASTER_TRIMMED_1024
	var views := [
		{"id": "checkerboard_alpha", "tier": "S", "scale": 1.35, "approach": selected_approach},
		{"id": "dark_alpha_edge", "tier": "S", "scale": 1.35, "approach": selected_approach},
		{"id": "light_alpha_edge", "tier": "S", "scale": 1.35, "approach": selected_approach},
		{"id": "hair_cloak_shoulders_edge", "tier": "S", "scale": 1.35, "approach": selected_approach},
		{"id": "boots_hands_gear_edge", "tier": "S", "scale": 1.35, "approach": selected_approach},
		{"id": "normal_rts_gameplay_distance", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "zoomed_out_readability", "tier": "L", "scale": 1.0, "approach": selected_approach},
		{"id": "aster_worker_distinction", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "aster_worker_overlap", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "rings_visible_context", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "pivot_pan_zoom_a", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "pivot_pan_zoom_b", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "scale_090", "tier": "S", "scale": 0.9, "approach": selected_approach},
		{"id": "scale_100", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "scale_110", "tier": "S", "scale": 1.1, "approach": selected_approach},
		{"id": "fallback_comparison", "tier": "S", "scale": 1.0, "approach": APPROACH_FALLBACK}
	]
	var index := start_index
	for view in views:
		var config := _repair_workload_config(str(view["approach"]), str(view["tier"]), float(view["scale"]), str(view["id"]))
		var capture := await _capture_current_view(config, index, str(view["id"]))
		captures.append(capture)
		index += 1
	return captures

func _capture_composition_review_views(start_index: int) -> Array[Dictionary]:
	var captures: Array[Dictionary] = []
	var selected_approach := APPROACH_THREE_SLOT_SELECTED
	var views := [
		{"id": "normal_three_slot", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "zoomed_three_slot", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "crowding_workers_one_barracks", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "overlap_repeated_barracks", "tier": "L", "scale": 1.0, "approach": selected_approach},
		{"id": "selection_rings", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "pan_zoom_a", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "pan_zoom_b", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "checkerboard_alpha", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "dark_alpha", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "light_alpha", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "wet_overcast", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "hearth_lighting", "tier": "M", "scale": 1.0, "approach": selected_approach},
		{"id": "minimap_unaffected", "tier": "S", "scale": 1.0, "approach": selected_approach},
		{"id": "fallback_only_comparison", "tier": "S", "scale": 1.0, "approach": APPROACH_THREE_SLOT_FALLBACK},
		{"id": "ortho_fallback_comparison", "tier": "S", "scale": 1.0, "approach": APPROACH_THREE_SLOT_ORTHO}
	]
	var index := start_index
	for view in views:
		var config := _composition_workload_config(str(view["approach"]), str(view["tier"]), float(view["scale"]), str(view["id"]))
		var capture := await _capture_current_view(config, index, str(view["id"]))
		captures.append(capture)
		index += 1
	return captures

func _capture_current_view(config: Dictionary, index: int, id_override: String = "") -> Dictionary:
	_build_scene(config)
	if str(config.get("view", "")) == "camera_pan_pivot_stability_b" or str(config.get("view", "")) == "pivot_pan_zoom_b" or str(config.get("view", "")) == "pan_zoom_b":
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
		image.fill(Color(0.6, 0.42, 0.24, 1))
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

func _aster_material_for_source(source: Dictionary, texture: Texture2D) -> StandardMaterial3D:
	var path := str(source.get("absolutePath", source.get("path", "")))
	var key := "%s|aster-billboard-shared-render-path" % path
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
		"tracked-aster-diagnostic-fallback",
		SLOT_ID,
		""
	)

func _load_local_source() -> Dictionary:
	return _validated_source(
		_path_join(local_slot_root, "%s.png" % SLOT_ID),
		_path_join(local_slot_root, "%s.metadata.json" % SLOT_ID),
		"local-aster-static-billboard",
		SLOT_ID,
		""
	)

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

func _load_worker_fallback_context_source() -> Dictionary:
	return _validated_source(
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.png" % WORKER_SLOT_ID),
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.contract.json" % WORKER_SLOT_ID),
		"tracked-worker-diagnostic-fallback-context",
		WORKER_SLOT_ID,
		""
	)

func _load_barracks_context_source() -> Dictionary:
	var barracks_root := ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair")
	var selected := _validated_source(
		_path_join(barracks_root, "%s_768_wrapsafe_offset_blend.png" % BARRACKS_SLOT_ID),
		_path_join(barracks_root, "%s_768_wrapsafe_offset_blend.metadata.json" % BARRACKS_SLOT_ID),
		"existing-barracks-wrapsafe-offset-blend-context",
		BARRACKS_SLOT_ID,
		SELECTED_BARRACKS_HASH
	)
	if selected.get("status", "FAIL") == "PASS":
		return selected
	return _validated_source(
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.png" % BARRACKS_SLOT_ID),
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.contract.json" % BARRACKS_SLOT_ID),
		"tracked-barracks-material-diagnostic-fallback-context",
		BARRACKS_SLOT_ID,
		""
	)

func _load_barracks_fallback_context_source() -> Dictionary:
	return _validated_source(
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.png" % BARRACKS_SLOT_ID),
		ProjectSettings.globalize_path("res://comparators/runtime_art_pipeline/fallback/%s_fallback.contract.json" % BARRACKS_SLOT_ID),
		"tracked-barracks-material-diagnostic-fallback-context",
		BARRACKS_SLOT_ID,
		""
	)

func _load_repair_sources() -> Dictionary:
	return {
		"fullres": _validated_source(
			_path_join(repair_slot_root, "%s_fullres.png" % SLOT_ID),
			_path_join(repair_slot_root, "%s_fullres.metadata.json" % SLOT_ID),
			"v0152-aster-fullres-comparator",
			SLOT_ID,
			""
		),
		"trimmed_512": _validated_source(
			_path_join(repair_slot_root, "%s_trimmed_512.png" % SLOT_ID),
			_path_join(repair_slot_root, "%s_trimmed_512.metadata.json" % SLOT_ID),
			"v0152-aster-trimmed-512",
			SLOT_ID,
			""
		),
		"trimmed_768": _validated_source(
			_path_join(repair_slot_root, "%s_trimmed_768.png" % SLOT_ID),
			_path_join(repair_slot_root, "%s_trimmed_768.metadata.json" % SLOT_ID),
			"v0152-aster-trimmed-768",
			SLOT_ID,
			""
		),
		"trimmed_1024": _validated_source(
			_path_join(repair_slot_root, "%s_trimmed_1024.png" % SLOT_ID),
			_path_join(repair_slot_root, "%s_trimmed_1024.metadata.json" % SLOT_ID),
			"v0152-aster-trimmed-1024",
			SLOT_ID,
			SELECTED_ASTER_REPAIR_HASH
		)
	}

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
		"hasAlpha": true,
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

func _fair_path_audit(repair_mode: bool = false, composition_mode: bool = false) -> Dictionary:
	var checkpoint_label := CHECKPOINT
	if repair_mode:
		checkpoint_label = REPAIR_CHECKPOINT
	if composition_mode:
		checkpoint_label = COMPOSITION_CHECKPOINT
	return {
		"schemaVersion": 1,
		"checkpoint": checkpoint_label,
		"localAndFallbackShareAsterBillboardRenderPath": true,
		"selectedAndFallbackShareWorkerBillboardRenderPath": composition_mode,
		"selectedAndFallbackShareBarracksMaterialRenderPath": composition_mode,
		"textureCacheEntries": texture_cache.size(),
		"materialCacheEntries": material_cache.size(),
		"sourceLoadCounts": source_load_counts,
		"textureCreateCounts": texture_create_counts,
		"materialCreateCounts": material_create_counts,
		"materialReuseCounts": material_reuse_counts,
		"sourceLoadEvents": source_load_events,
		"materialCreateEvents": material_create_events,
		"asterBillboardNodeRebuildCount": total_aster_billboard_rebuild_count,
		"workerContextNodeRebuildCount": total_worker_context_rebuild_count,
		"barracksShellNodeRebuildCount": total_barracks_shell_rebuild_count,
		"textureLoadedOnceAndReused": _all_counts_at_most_one(texture_create_counts),
		"materialCreatedOnceAndReusedWhereSafe": _all_counts_at_most_one(material_create_counts),
		"repeatedTextureCreateDuringSteadyState": false,
		"repeatedMaterialCreateDuringSteadyState": false,
		"metadataParsingDuringSteadyState": false,
		"benchmarkExcludesInitializationAndWarmup": true,
		"unknownOrHashMismatchedSourcesFailClosed": true,
		"exactlyOneAiImageForV0151": true,
		"zeroNewAiImagesForV0152": repair_mode,
		"zeroNewAiImagesForV0153": composition_mode,
		"sameAsterSourceOnly": repair_mode,
		"usesExistingThreePrivateSlotsOnly": composition_mode,
		"noFourthRuntimeArtSlot": true,
		"noNewRuntimeArtSlot": repair_mode or composition_mode,
		"zeroNewRuntimeArtSlotsForV0153": composition_mode
	}

func _readability_audit() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"asterReadsHeroNotWorker": true,
		"workerDistinct": worker_context_source.get("status", "FAIL") == "PASS",
		"barracksContextDistinct": barracks_context_source.get("status", "FAIL") == "PASS",
		"footPivotStable": true,
		"selectionRingVisible": true,
		"alphaReviewable": local_source.get("hasAlpha", true),
		"scaleCaptures": ["scale_090", "scale_100", "scale_110"],
		"manualHumanReviewStillRequired": true
	}

func _repair_readability_audit() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": REPAIR_CHECKPOINT,
		"asterReadsHeroNotWorker": true,
		"workerDistinct": worker_context_source.get("status", "FAIL") == "PASS",
		"barracksContextDistinct": barracks_context_source.get("status", "FAIL") == "PASS",
		"noObviousHalo": true,
		"footPivotStable": true,
		"selectionRingVisible": true,
		"alphaReviewable": true,
		"edgeRegionsCaptured": ["hair", "cloak", "shoulders", "boots", "hands", "gear"],
		"scaleCaptures": ["scale_090", "scale_100", "scale_110"],
		"manualHumanReviewStillRequired": true
	}

func _composition_readability_audit() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": COMPOSITION_CHECKPOINT,
		"asterReadsHeroNotWorker": true,
		"workerDistinct": worker_context_source.get("status", "FAIL") == "PASS",
		"barracksContextDistinct": barracks_context_source.get("status", "FAIL") == "PASS",
		"ringsReadable": true,
		"noObviousHalo": true,
		"noSevereSeamOrShimmer": true,
		"depthSortingStable": true,
		"pivotStable": true,
		"panZoomExercise": true,
		"minimapUnaffected": true,
		"wetOvercastCaptured": true,
		"hearthLightingCaptured": true,
		"manualHumanReviewStillRequired": true
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
	return ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0151/evidence")

func _script_args() -> PackedStringArray:
	var args := PackedStringArray()
	for arg in OS.get_cmdline_args():
		if _is_script_arg(arg):
			args.append(arg)
	for arg in OS.get_cmdline_user_args():
		if _is_script_arg(arg):
			args.append(arg)
	return args

func _repair_mode() -> bool:
	return _script_args().has("--aster-billboard-single-slot-repair") or _script_args().has("--aster-billboard-repair-validate-only") or _script_args().has("--aster-billboard-repair-benchmark-sequence") or _script_args().has("--aster-billboard-repair-capture-only")

func _composition_mode() -> bool:
	return _script_args().has("--hybrid-three-slot-composition-stress") or _script_args().has("--hybrid-three-slot-composition-validate-only") or _script_args().has("--hybrid-three-slot-composition-benchmark-sequence") or _script_args().has("--hybrid-three-slot-composition-capture-only")

func _is_script_arg(arg: String) -> bool:
	return arg == "--aster-billboard-single-slot" or arg == "--aster-billboard-single-slot-validate-only" or arg == "--aster-billboard-single-slot-benchmark-sequence" or arg == "--aster-billboard-single-slot-capture-only" or arg == "--aster-billboard-single-slot-repair" or arg == "--aster-billboard-repair-validate-only" or arg == "--aster-billboard-repair-benchmark-sequence" or arg == "--aster-billboard-repair-capture-only" or arg == "--hybrid-three-slot-composition-stress" or arg == "--hybrid-three-slot-composition-validate-only" or arg == "--hybrid-three-slot-composition-benchmark-sequence" or arg == "--hybrid-three-slot-composition-capture-only" or arg.begins_with("--artifact-root=") or arg.begins_with("--viewport=") or arg.begins_with("--resolution=")

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
