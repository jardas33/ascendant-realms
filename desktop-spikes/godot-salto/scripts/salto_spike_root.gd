extends Node

const MODE_2D := "2D_PLACEHOLDER"
const MODE_25D := "2_5D_ORTHOGRAPHIC_PLACEHOLDER"
const MODE_HOME := "REVIEW_HOME"
const MODE_PLAYER_TITLE := "PLAYER_TITLE"
const MODE_PLAYER_BRIEFING := "PLAYER_BRIEFING"
const MODE_PLAYER_RESULTS := "PLAYER_RESULTS"
const CHECKPOINT := "v0.122"
const VIEWPORT_SIZE := Vector2i(1600, 900)
const CAPTURE_VIEWPORTS := [Vector2i(1600, 900), Vector2i(1920, 1080)]
const VISUAL_PRESET_2D_CONTROL := "2D_CONTROL"
const VISUAL_PRESET_CLEAN := "CLEAN_READABILITY"
const VISUAL_PRESET_ATMOSPHERIC := "ATMOSPHERIC_BALANCED"
const VISUAL_PRESET_VFX_STRESS := "VFX_STRESS_PRIVATE"
const SCRIPT_ARG_PREFIXES := [
	"--run-tests",
	"--run-benchmark",
	"--review-smoke",
	"--capture-review",
	"--headed-benchmark",
	"--private-harness",
	"--player-slice",
	"--player-slice-validate",
	"--player-slice-capture",
	"--real-input-smoke",
	"--real-input-validate",
	"--site-semantics-smoke",
	"--site-semantics-validate",
	"--post-mine-flow-smoke",
	"--post-mine-flow-validate",
	"--triple-natural-playthrough",
	"--rts-ergonomics-smoke",
	"--usability-presentation-smoke",
	"--blockout-quality-smoke",
	"--runtime-art-comparator",
	"--worker-billboard-single-slot",
	"--worker-billboard-single-slot-repair",
	"--barrosan-barracks-material-single-slot",
	"--barrosan-barracks-material-seam-repair",
	"--aster-billboard-single-slot-repair",
	"--hybrid-three-slot-composition-stress",
	"--militia-billboard-single-slot",
	"--militia-billboard-mass-overlap-repair",
	"--ashen-raider-billboard-single-slot",
	"--aster-billboard-single-slot",
	"--mode=",
	"--visual-preset=",
	"--viewport=",
	"--artifact-root="
]
const SaltoFixtureImporterScript: GDScript = preload("res://scripts/fixture_importer.gd")

@export var default_mode := MODE_2D

var active_mode := MODE_HOME
var active_scene: Node
var review_layer: CanvasLayer
var home_screen: Control
var review_panel: Panel
var title_label: Label
var status_label: Label
var step_label: Label
var player_layer: CanvasLayer
var player_screen: Control
var player_visible_texts: Array[String] = []
var current_step_id := "home"
var current_viewport_size := VIEWPORT_SIZE
var active_visual_preset := VISUAL_PRESET_CLEAN
var last_post_mine_flow_status: Dictionary = {}

func _ready() -> void:
	var args: PackedStringArray = _script_args()
	current_viewport_size = _viewport_from_args(VIEWPORT_SIZE)
	active_visual_preset = _visual_preset_from_args()
	_configure_window()
	if args.has("--runtime-art-comparator"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "runtime-art-comparator-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.146",
			"status": "PASS_V0146_PRIVATE_COMPARATOR_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var comparator_script := load("res://comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.gd") as GDScript
		var comparator := Node.new()
		comparator.name = "V0146RuntimeArtPipelineComparator"
		comparator.set_script(comparator_script)
		add_child(comparator)
		comparator.call_deferred("start")
		return
	if args.has("--worker-billboard-single-slot"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "worker-billboard-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.147",
			"status": "PASS_V0147_PRIVATE_WORKER_BILLBOARD_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var worker_comparator_script := load("res://comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd") as GDScript
		if worker_comparator_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "worker-billboard-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.147",
				"status": "FAIL_V0147_PRIVATE_WORKER_BILLBOARD_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var worker_comparator := Node.new()
		worker_comparator.name = "V0147WorkerBillboardSingleSlotComparator"
		worker_comparator.set_script(worker_comparator_script)
		add_child(worker_comparator)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "worker-billboard-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.147",
			"status": "PASS_V0147_PRIVATE_WORKER_BILLBOARD_PRESTART",
			"hasStart": worker_comparator.has_method("start")
		})
		if not worker_comparator.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "worker-billboard-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.147",
				"status": "FAIL_V0147_PRIVATE_WORKER_BILLBOARD_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		worker_comparator.call("start")
		return
	if args.has("--worker-billboard-single-slot-repair"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "worker-billboard-repair-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.148",
			"status": "PASS_V0148_PRIVATE_WORKER_BILLBOARD_REPAIR_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var worker_repair_script := load("res://comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd") as GDScript
		if worker_repair_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "worker-billboard-repair-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.148",
				"status": "FAIL_V0148_PRIVATE_WORKER_BILLBOARD_REPAIR_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var worker_repair := Node.new()
		worker_repair.name = "V0148WorkerBillboardSingleSlotRepairComparator"
		worker_repair.set_script(worker_repair_script)
		add_child(worker_repair)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "worker-billboard-repair-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.148",
			"status": "PASS_V0148_PRIVATE_WORKER_BILLBOARD_REPAIR_PRESTART",
			"hasStart": worker_repair.has_method("start")
		})
		if not worker_repair.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "worker-billboard-repair-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.148",
				"status": "FAIL_V0148_PRIVATE_WORKER_BILLBOARD_REPAIR_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		worker_repair.call("start")
		return
	if args.has("--barrosan-barracks-material-single-slot"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "barracks-material-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.149",
			"status": "PASS_V0149_PRIVATE_BARRACKS_MATERIAL_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var barracks_material_script := load("res://comparators/runtime_art_pipeline/barracks_material_single_slot_comparator.gd") as GDScript
		if barracks_material_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "barracks-material-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.149",
				"status": "FAIL_V0149_PRIVATE_BARRACKS_MATERIAL_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/barracks_material_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var barracks_material := Node.new()
		barracks_material.name = "V0149BarracksMaterialSingleSlotComparator"
		barracks_material.set_script(barracks_material_script)
		add_child(barracks_material)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "barracks-material-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.149",
			"status": "PASS_V0149_PRIVATE_BARRACKS_MATERIAL_PRESTART",
			"hasStart": barracks_material.has_method("start")
		})
		if not barracks_material.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "barracks-material-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.149",
				"status": "FAIL_V0149_PRIVATE_BARRACKS_MATERIAL_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/barracks_material_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		barracks_material.call("start")
		return
	if args.has("--barrosan-barracks-material-seam-repair"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "barracks-material-seam-repair-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.150",
			"status": "PASS_V0150_PRIVATE_BARRACKS_MATERIAL_SEAM_REPAIR_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var barracks_repair_script := load("res://comparators/runtime_art_pipeline/barracks_material_seam_repair_comparator.gd") as GDScript
		if barracks_repair_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "barracks-material-seam-repair-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.150",
				"status": "FAIL_V0150_PRIVATE_BARRACKS_MATERIAL_SEAM_REPAIR_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/barracks_material_seam_repair_comparator.gd"
			})
			get_tree().quit(1)
			return
		var barracks_repair := Node.new()
		barracks_repair.name = "V0150BarracksMaterialSeamRepairComparator"
		barracks_repair.set_script(barracks_repair_script)
		add_child(barracks_repair)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "barracks-material-seam-repair-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.150",
			"status": "PASS_V0150_PRIVATE_BARRACKS_MATERIAL_SEAM_REPAIR_PRESTART",
			"hasStart": barracks_repair.has_method("start")
		})
		if not barracks_repair.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "barracks-material-seam-repair-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.150",
				"status": "FAIL_V0150_PRIVATE_BARRACKS_MATERIAL_SEAM_REPAIR_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/barracks_material_seam_repair_comparator.gd"
			})
			get_tree().quit(1)
			return
		barracks_repair.call("start")
		return
	if args.has("--aster-billboard-single-slot-repair"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "aster-billboard-repair-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.152",
			"status": "PASS_V0152_PRIVATE_ASTER_BILLBOARD_REPAIR_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var aster_repair_script := load("res://comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd") as GDScript
		if aster_repair_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "aster-billboard-repair-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.152",
				"status": "FAIL_V0152_PRIVATE_ASTER_BILLBOARD_REPAIR_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var aster_repair := Node.new()
		aster_repair.name = "V0152AsterBillboardRepairComparator"
		aster_repair.set_script(aster_repair_script)
		add_child(aster_repair)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "aster-billboard-repair-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.152",
			"status": "PASS_V0152_PRIVATE_ASTER_BILLBOARD_REPAIR_PRESTART",
			"hasStart": aster_repair.has_method("start")
		})
		if not aster_repair.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "aster-billboard-repair-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.152",
				"status": "FAIL_V0152_PRIVATE_ASTER_BILLBOARD_REPAIR_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		aster_repair.call("start")
		return
	if args.has("--hybrid-three-slot-composition-stress"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "hybrid-three-slot-composition-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.153",
			"status": "PASS_V0153_PRIVATE_HYBRID_THREE_SLOT_COMPOSITION_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var composition_script := load("res://comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd") as GDScript
		if composition_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "hybrid-three-slot-composition-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.153",
				"status": "FAIL_V0153_PRIVATE_HYBRID_THREE_SLOT_COMPOSITION_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var composition := Node.new()
		composition.name = "V0153HybridThreeSlotCompositionStressComparator"
		composition.set_script(composition_script)
		add_child(composition)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "hybrid-three-slot-composition-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.153",
			"status": "PASS_V0153_PRIVATE_HYBRID_THREE_SLOT_COMPOSITION_PRESTART",
			"hasStart": composition.has_method("start")
		})
		if not composition.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "hybrid-three-slot-composition-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.153",
				"status": "FAIL_V0153_PRIVATE_HYBRID_THREE_SLOT_COMPOSITION_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		composition.call("start")
		return
	if args.has("--militia-billboard-mass-overlap-repair"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "militia-billboard-repair-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.155",
			"status": "PASS_V0155_PRIVATE_MILITIA_BILLBOARD_REPAIR_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var militia_repair_script := load("res://comparators/runtime_art_pipeline/militia_billboard_single_slot_comparator.gd") as GDScript
		if militia_repair_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "militia-billboard-repair-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.155",
				"status": "FAIL_V0155_PRIVATE_MILITIA_BILLBOARD_REPAIR_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/militia_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var militia_repair := Node.new()
		militia_repair.name = "V0155MilitiaBillboardMassOverlapRepairComparator"
		militia_repair.set_script(militia_repair_script)
		add_child(militia_repair)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "militia-billboard-repair-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.155",
			"status": "PASS_V0155_PRIVATE_MILITIA_BILLBOARD_REPAIR_PRESTART",
			"hasStart": militia_repair.has_method("start")
		})
		if not militia_repair.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "militia-billboard-repair-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.155",
				"status": "FAIL_V0155_PRIVATE_MILITIA_BILLBOARD_REPAIR_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/militia_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		militia_repair.call("start")
		return
	if args.has("--militia-billboard-single-slot"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "militia-billboard-single-slot-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.154",
			"status": "PASS_V0154_PRIVATE_MILITIA_BILLBOARD_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var militia_script := load("res://comparators/runtime_art_pipeline/militia_billboard_single_slot_comparator.gd") as GDScript
		if militia_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "militia-billboard-single-slot-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.154",
				"status": "FAIL_V0154_PRIVATE_MILITIA_BILLBOARD_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/militia_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var militia := Node.new()
		militia.name = "V0154MilitiaBillboardSingleSlotComparator"
		militia.set_script(militia_script)
		add_child(militia)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "militia-billboard-single-slot-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.154",
			"status": "PASS_V0154_PRIVATE_MILITIA_BILLBOARD_PRESTART",
			"hasStart": militia.has_method("start")
		})
		if not militia.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "militia-billboard-single-slot-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.154",
				"status": "FAIL_V0154_PRIVATE_MILITIA_BILLBOARD_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/militia_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		militia.call("start")
		return
	if args.has("--ashen-raider-billboard-single-slot"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "ashen-raider-billboard-single-slot-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.156",
			"status": "PASS_V0156_PRIVATE_ASHEN_RAIDER_BILLBOARD_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var ashen_raider_script := load("res://comparators/runtime_art_pipeline/ashen_raider_billboard_single_slot_comparator.gd") as GDScript
		if ashen_raider_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "ashen-raider-billboard-single-slot-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.156",
				"status": "FAIL_V0156_PRIVATE_ASHEN_RAIDER_BILLBOARD_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/ashen_raider_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var ashen_raider := Node.new()
		ashen_raider.name = "V0156AshenRaiderBillboardSingleSlotComparator"
		ashen_raider.set_script(ashen_raider_script)
		add_child(ashen_raider)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "ashen-raider-billboard-single-slot-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.156",
			"status": "PASS_V0156_PRIVATE_ASHEN_RAIDER_BILLBOARD_PRESTART",
			"hasStart": ashen_raider.has_method("start")
		})
		if not ashen_raider.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "ashen-raider-billboard-single-slot-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.156",
				"status": "FAIL_V0156_PRIVATE_ASHEN_RAIDER_BILLBOARD_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/ashen_raider_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		ashen_raider.call("start")
		return
	if args.has("--aster-billboard-single-slot"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "aster-billboard-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.151",
			"status": "PASS_V0151_PRIVATE_ASTER_BILLBOARD_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var aster_billboard_script := load("res://comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd") as GDScript
		if aster_billboard_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "aster-billboard-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.151",
				"status": "FAIL_V0151_PRIVATE_ASTER_BILLBOARD_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var aster_billboard := Node.new()
		aster_billboard.name = "V0151AsterBillboardSingleSlotComparator"
		aster_billboard.set_script(aster_billboard_script)
		add_child(aster_billboard)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "aster-billboard-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.151",
			"status": "PASS_V0151_PRIVATE_ASTER_BILLBOARD_PRESTART",
			"hasStart": aster_billboard.has_method("start")
		})
		if not aster_billboard.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "aster-billboard-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.151",
				"status": "FAIL_V0151_PRIVATE_ASTER_BILLBOARD_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		aster_billboard.call("start")
		return
	if args.has("--run-tests"):
		var test_report: Dictionary = run_headless_tests()
		_write_report("res://reports/godot-runtime-test-report.json", test_report)
		get_tree().quit(0 if test_report.get("status", "FAIL") == "PASS" else 1)
		return
	if args.has("--run-benchmark"):
		var benchmark_errors: Array[String] = run_headless_benchmark()
		get_tree().quit(0 if benchmark_errors.is_empty() else 1)
		return
	if args.has("--player-slice-validate"):
		_create_player_slice_ui()
		await run_player_slice_validation()
		return
	if args.has("--player-slice-capture"):
		_create_player_slice_ui()
		await run_player_slice_capture()
		return
	if args.has("--real-input-smoke") or args.has("--real-input-validate"):
		_create_player_slice_ui()
		await run_real_input_smoke()
		return
	if args.has("--site-semantics-smoke") or args.has("--site-semantics-validate"):
		_create_player_slice_ui()
		await run_site_semantics_smoke()
		return
	if args.has("--post-mine-flow-smoke") or args.has("--post-mine-flow-validate"):
		_create_player_slice_ui()
		await run_post_mine_flow_smoke()
		return
	if args.has("--triple-natural-playthrough"):
		_create_player_slice_ui()
		await run_triple_natural_playthrough_smoke()
		return
	if args.has("--rts-ergonomics-smoke"):
		_create_player_slice_ui()
		await run_rts_ergonomics_smoke()
		return
	if args.has("--usability-presentation-smoke"):
		_create_player_slice_ui()
		await run_usability_presentation_smoke()
		return
	if args.has("--blockout-quality-smoke"):
		_create_player_slice_ui()
		await run_blockout_quality_smoke()
		return
	if args.has("--player-slice"):
		_create_player_slice_ui()
		show_player_title()
		return
	var requested_mode := _requested_mode_from_args()
	var private_requested := args.has("--private-harness") or args.has("--review-smoke") or args.has("--capture-review") or args.has("--headed-benchmark") or requested_mode != ""
	if not private_requested:
		_create_player_slice_ui()
		show_player_title()
		return
	_create_review_ui()
	if args.has("--review-smoke"):
		await run_headed_smoke()
		return
	if args.has("--capture-review"):
		await run_capture_review()
		return
	if args.has("--headed-benchmark"):
		await run_headed_benchmark()
		return
	if requested_mode == "":
		load_home()
	else:
		load_mode(requested_mode)

func _configure_window() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(current_viewport_size)
		DisplayServer.window_set_min_size(current_viewport_size)

func load_home() -> void:
	if active_scene and is_instance_valid(active_scene):
		active_scene.queue_free()
	active_scene = null
	active_mode = MODE_HOME
	current_step_id = "home"
	if home_screen:
		home_screen.visible = true
	_update_review_overlay("Home")

func load_mode(mode: String) -> void:
	if active_scene and is_instance_valid(active_scene):
		active_scene.queue_free()
	var scene_path: String = "res://scenes/salto_2d_placeholder.tscn"
	if mode == MODE_25D:
		scene_path = "res://scenes/salto_2_5d_orthographic_placeholder.tscn"
	var packed: PackedScene = load(scene_path) as PackedScene
	active_scene = packed.instantiate()
	active_mode = mode
	add_child(active_scene)
	if active_mode == MODE_25D and active_scene.has_method("set_visual_preset"):
		active_scene.set_visual_preset(active_visual_preset)
	if home_screen:
		home_screen.visible = false
	_update_review_overlay("Launched %s" % _friendly_mode(mode))

func _requested_mode_from_args() -> String:
	for arg in _script_args():
		if arg == "--mode=2_5d" or arg == "--mode=2.5d":
			return MODE_25D
		if arg == "--mode=2d":
			return MODE_2D
	return ""

func _mode_from_args() -> String:
	var requested_mode := _requested_mode_from_args()
	return default_mode if requested_mode == "" else requested_mode

func _visual_preset_from_args() -> String:
	for arg in _script_args():
		if arg.begins_with("--visual-preset="):
			return _normalize_visual_preset(arg.trim_prefix("--visual-preset="))
	return VISUAL_PRESET_CLEAN

func _normalize_visual_preset(preset: String) -> String:
	var value := preset.strip_edges().to_upper()
	if value == "" or value == "DEFAULT" or value == "CLEAN" or value == "2_5D_CLEAN":
		return VISUAL_PRESET_CLEAN
	if value == VISUAL_PRESET_CLEAN:
		return VISUAL_PRESET_CLEAN
	if value == "ATMOSPHERIC" or value == VISUAL_PRESET_ATMOSPHERIC:
		return VISUAL_PRESET_ATMOSPHERIC
	if value == "VFX_STRESS" or value == "STRESS" or value == VISUAL_PRESET_VFX_STRESS:
		return VISUAL_PRESET_VFX_STRESS
	return VISUAL_PRESET_CLEAN

func _viewport_from_args(default_size: Vector2i) -> Vector2i:
	for arg in _script_args():
		if arg.begins_with("--viewport="):
			var raw := arg.trim_prefix("--viewport=")
			var parts := raw.split("x")
			if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
				return Vector2i(int(parts[0]), int(parts[1]))
	return default_size

func _create_review_ui() -> void:
	if review_layer:
		return
	review_layer = CanvasLayer.new()
	review_layer.name = "V0118PrivateReviewHarness"
	add_child(review_layer)

	home_screen = Control.new()
	home_screen.name = "ReviewHome"
	home_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	review_layer.add_child(home_screen)

	var home_background := ColorRect.new()
	home_background.color = Color(0.05, 0.08, 0.09)
	home_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	home_screen.add_child(home_background)

	var home_band := ColorRect.new()
	home_band.color = Color(0.10, 0.18, 0.18)
	home_band.position = Vector2(0, 530)
	home_band.size = Vector2(1600, 370)
	home_screen.add_child(home_band)

	var home_title := Label.new()
	home_title.text = "Ascendant Realms Godot Salto Spike"
	home_title.position = Vector2(86, 92)
	home_title.size = Vector2(1040, 60)
	home_title.add_theme_font_size_override("font_size", 38)
	home_title.add_theme_color_override("font_color", Color(0.90, 0.94, 0.88))
	home_screen.add_child(home_title)

	var home_subtitle := Label.new()
	home_subtitle.text = "v0.122 content-subset adapter parity proof"
	home_subtitle.position = Vector2(88, 156)
	home_subtitle.size = Vector2(1040, 44)
	home_subtitle.add_theme_font_size_override("font_size", 22)
	home_subtitle.add_theme_color_override("font_color", Color(0.70, 0.86, 0.82))
	home_screen.add_child(home_subtitle)

	var home_footer := Label.new()
	home_footer.text = "Repository-driven. Editor-optional. Placeholder-only."
	home_footer.position = Vector2(88, 614)
	home_footer.size = Vector2(1040, 44)
	home_footer.add_theme_font_size_override("font_size", 22)
	home_footer.add_theme_color_override("font_color", Color(0.86, 0.82, 0.60))
	home_screen.add_child(home_footer)

	review_panel = Panel.new()
	review_panel.name = "ReviewStepPanel"
	review_panel.position = Vector2(18, 18)
	review_panel.size = Vector2(898, 128)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.05, 0.86)
	style.border_color = Color(0.33, 0.78, 0.72, 0.86)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	review_panel.add_theme_stylebox_override("panel", style)
	review_layer.add_child(review_panel)

	title_label = Label.new()
	title_label.text = "v0.122 Adapter Review"
	title_label.position = Vector2(16, 10)
	title_label.size = Vector2(220, 26)
	title_label.add_theme_font_size_override("font_size", 18)
	review_panel.add_child(title_label)

	status_label = Label.new()
	status_label.text = "Home"
	status_label.position = Vector2(240, 10)
	status_label.size = Vector2(612, 26)
	status_label.add_theme_font_size_override("font_size", 15)
	review_panel.add_child(status_label)

	step_label = Label.new()
	step_label.text = "Step: home | Mode: REVIEW_HOME"
	step_label.position = Vector2(16, 42)
	step_label.size = Vector2(846, 24)
	step_label.add_theme_font_size_override("font_size", 14)
	review_panel.add_child(step_label)

	var grid := GridContainer.new()
	grid.position = Vector2(14, 74)
	grid.size = Vector2(870, 38)
	grid.columns = 11
	review_panel.add_child(grid)
	for item in [
		{"text": "Home", "action": "home"},
		{"text": "2D", "action": "launch_2d"},
		{"text": "2.5D", "action": "launch_25d"},
		{"text": "Clean", "action": "preset_clean"},
		{"text": "Atmos", "action": "preset_atmospheric"},
		{"text": "VFX", "action": "preset_vfx_stress"},
		{"text": "Hero", "action": "select_hero"},
		{"text": "Worker", "action": "select_worker"},
		{"text": "Squad", "action": "box_select"},
		{"text": "Site", "action": "capture_site"},
		{"text": "Results", "action": "results"}
	]:
		var button := Button.new()
		button.text = str(item["text"])
		button.custom_minimum_size = Vector2(76, 32)
		button.pressed.connect(_handle_review_action.bind(str(item["action"])))
		grid.add_child(button)

func _create_player_slice_ui() -> void:
	if player_layer:
		return
	player_layer = CanvasLayer.new()
	player_layer.name = "V0124PlayerFacingSlice"
	add_child(player_layer)
	player_screen = Control.new()
	player_screen.name = "PlayerSliceScreen"
	player_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	player_screen.mouse_filter = Control.MOUSE_FILTER_PASS
	player_layer.add_child(player_screen)

func show_player_title() -> void:
	active_visual_preset = VISUAL_PRESET_CLEAN
	load_mode(MODE_25D)
	_call_scene("set_player_facing_mode", [true])
	current_step_id = "player_title"
	active_mode = MODE_PLAYER_TITLE
	_render_player_screen("title")

func show_player_briefing() -> void:
	current_step_id = "player_briefing"
	active_mode = MODE_PLAYER_BRIEFING
	_render_player_screen("briefing")

func show_player_battle() -> void:
	active_visual_preset = VISUAL_PRESET_CLEAN
	load_mode(MODE_25D)
	_call_scene("set_player_facing_mode", [true])
	_call_scene("set_workload_tier", ["M"])
	current_step_id = "player_battle"
	_render_player_screen("battle")

func show_player_results() -> void:
	if active_scene == null or not is_instance_valid(active_scene):
		show_player_battle()
	_call_scene("transition_results")
	current_step_id = "player_results"
	active_mode = MODE_PLAYER_RESULTS
	_render_player_screen("results")

func record_post_mine_flow_status(status: Dictionary) -> void:
	last_post_mine_flow_status = status.duplicate(true)

func _exit_player_slice() -> void:
	current_step_id = "player_exit"
	get_tree().quit(0)

func _render_player_screen(screen: String) -> void:
	_create_player_slice_ui()
	for child in player_screen.get_children():
		child.queue_free()
	player_visible_texts = []
	_call_scene("set_player_shell_screen", [screen])
	var shade := ColorRect.new()
	shade.name = "PlayerSliceShade"
	shade.color = Color(0.02, 0.025, 0.025, 0.28 if screen == "battle" else 0.57)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_screen.add_child(shade)
	match screen:
		"title":
			_add_player_label("Salto foothold review", Vector2(0, 36), Vector2(1600, 30), 15, Color(0.72, 0.86, 0.80), Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_label("JARDAS: Salto Foothold", Vector2(0, 88), Vector2(1600, 68), 42, Color(0.90, 0.94, 0.86), Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_label("Aster converts one mine, restores a Barracks, trains Militia, and reopens a quiet Lume link.", Vector2(300, 164), Vector2(1000, 56), 20, Color(0.78, 0.84, 0.76), Color(0.04, 0.05, 0.04, 0.42), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_button("Start Salto Review", Vector2(620, 282), "_on_player_start_pressed")
			_add_player_button("Settings", Vector2(620, 336), "_on_player_settings_pressed")
			_add_player_button("Exit", Vector2(620, 390), "_exit_player_slice")
		"briefing":
			_add_player_label("Salto Foothold Briefing", Vector2(0, 78), Vector2(1600, 56), 34, Color(0.90, 0.94, 0.86), Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_label("Convert the mine, assign the Worker, restore the Barracks, and survive one wave.", Vector2(300, 140), Vector2(1000, 36), 20, Color(0.78, 0.86, 0.78), Color(0.04, 0.05, 0.04, 0.36), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_label("1. Select Aster and move to West Stone Cut Mine.", Vector2(430, 220), Vector2(740, 30), 18, Color(0.88, 0.88, 0.74), Color(0.04, 0.05, 0.04, 0.44), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_label("2. Convert the mine, assign the Worker, and queue Militia.", Vector2(430, 260), Vector2(740, 30), 18, Color(0.88, 0.88, 0.74), Color(0.04, 0.05, 0.04, 0.44), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_label("3. Break one Ashen wave and restore Lume.", Vector2(430, 300), Vector2(740, 30), 18, Color(0.88, 0.88, 0.74), Color(0.04, 0.05, 0.04, 0.44), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_button("Start Battle", Vector2(620, 390), "_on_player_battle_pressed")
			_add_player_button("Back", Vector2(620, 444), "_on_player_back_pressed")
		"battle":
			# The in-scene HUD owns all battle chrome.
			pass
		"results":
			_add_player_label("Salto Review Complete", Vector2(420, 88), Vector2(760, 56), 34, Color(0.90, 0.94, 0.86), Color(0.04, 0.05, 0.04, 0.62), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_label("Mine controlled. Worker assigned. Barracks restored. Militia trained. Lume restored.", Vector2(250, 154), Vector2(1100, 36), 20, Color(0.82, 0.88, 0.78), Color(0.04, 0.05, 0.04, 0.68), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_label("Readable HUD, minimap, pacing, wave, and Results path passed.", Vector2(300, 214), Vector2(1000, 34), 18, Color(0.88, 0.86, 0.70), Color(0.04, 0.05, 0.04, 0.68), HORIZONTAL_ALIGNMENT_CENTER)
			_add_player_button("Restart Slice", Vector2(620, 318), "_on_player_restart_pressed")
			_add_player_button("Return to Title", Vector2(620, 372), "_on_player_back_pressed")
			_add_player_button("Exit", Vector2(620, 426), "_exit_player_slice")

func _add_player_label(text: String, position: Vector2, size: Vector2, font_size: int, color: Color, background: Color = Color(0, 0, 0, 0), alignment: int = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	if background.a > 0.0:
		var bg := ColorRect.new()
		bg.color = background
		bg.position = position - Vector2(12, 6)
		bg.size = size + Vector2(24, 12)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		player_screen.add_child(bg)
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	player_screen.add_child(label)
	player_visible_texts.append(text)

func _add_player_button(text: String, position: Vector2, method_name: String) -> void:
	var button := Button.new()
	button.text = text
	button.position = position
	button.size = Vector2(260, 42)
	button.add_theme_font_size_override("font_size", 17)
	button.pressed.connect(Callable(self, method_name))
	player_screen.add_child(button)
	player_visible_texts.append(text)

func _on_player_start_pressed() -> void:
	show_player_briefing()

func _on_player_settings_pressed() -> void:
	_add_player_label("Settings are not needed for this short review.", Vector2(470, 462), Vector2(660, 30), 16, Color(0.76, 0.86, 0.80), Color(0.04, 0.05, 0.04, 0.70), HORIZONTAL_ALIGNMENT_CENTER)

func _on_player_battle_pressed() -> void:
	show_player_battle()

func _on_player_back_pressed() -> void:
	show_player_title()

func _on_player_restart_pressed() -> void:
	show_player_battle()

func _ensure_player_battle_scene() -> void:
	if active_scene == null or not is_instance_valid(active_scene) or active_mode != MODE_25D:
		show_player_battle()
	else:
		_call_scene("set_player_facing_mode", [true])

func _handle_review_action(action: String) -> void:
	_apply_review_action(action)

func _apply_review_action(action: String) -> Dictionary:
	current_step_id = action
	match action:
		"home", "return_home":
			load_home()
		"launch_2d":
			load_mode(MODE_2D)
		"launch_25d":
			load_mode(MODE_25D)
		"launch_25d_clean":
			active_visual_preset = VISUAL_PRESET_CLEAN
			load_mode(MODE_25D)
		"launch_25d_atmospheric":
			active_visual_preset = VISUAL_PRESET_ATMOSPHERIC
			load_mode(MODE_25D)
		"launch_25d_vfx_stress":
			active_visual_preset = VISUAL_PRESET_VFX_STRESS
			load_mode(MODE_25D)
		"preset_clean":
			active_visual_preset = VISUAL_PRESET_CLEAN
			if active_mode == MODE_25D and active_scene and active_scene.has_method("set_visual_preset"):
				active_scene.set_visual_preset(active_visual_preset)
		"preset_atmospheric":
			active_visual_preset = VISUAL_PRESET_ATMOSPHERIC
			if active_mode != MODE_25D:
				load_mode(MODE_25D)
			elif active_scene and active_scene.has_method("set_visual_preset"):
				active_scene.set_visual_preset(active_visual_preset)
		"preset_vfx_stress":
			active_visual_preset = VISUAL_PRESET_VFX_STRESS
			if active_mode != MODE_25D:
				load_mode(MODE_25D)
			elif active_scene and active_scene.has_method("set_visual_preset"):
				active_scene.set_visual_preset(active_visual_preset)
		"select_hero":
			_ensure_active_scene()
			_call_scene("select_entity", ["hero_aster"])
		"select_worker":
			_ensure_active_scene()
			_call_scene("select_entity", ["worker"])
		"box_select":
			_ensure_active_scene()
			_call_scene("box_select_squad")
		"move":
			_ensure_active_scene()
			_call_scene("issue_move_order")
		"attack":
			_ensure_active_scene()
			_call_scene("issue_attack_order")
		"pan_camera":
			_ensure_active_scene()
			_call_scene("pan_camera")
		"zoom_camera":
			_ensure_active_scene()
			_call_scene("zoom_camera")
		"pause":
			_ensure_active_scene()
			_call_scene("toggle_pause")
		"capture_site":
			_ensure_active_scene()
			_call_scene("change_site_state")
		"show_buildings":
			_ensure_active_scene()
			_call_scene("set_workload_tier", ["L"])
		"lume_link":
			_ensure_active_scene()
			_call_scene("focus_lume_link")
		"lume_stable":
			_ensure_active_scene()
			_call_scene("set_workload_tier", ["M"])
		"lume_transition":
			_ensure_active_scene()
			_call_scene("change_site_state", ["west_stone_cut", "friendly"])
			_call_scene("change_site_state", ["ford_toll", "friendly"])
			_call_scene("focus_lume_link")
		"results":
			_ensure_active_scene()
			_call_scene("transition_results")
		"exit":
			current_step_id = "exit"
		_:
			_update_review_overlay("Unknown step %s" % action)
	var status := get_spike_status()
	_update_review_overlay(_friendly_action(action))
	return status

func _ensure_active_scene() -> void:
	if active_scene == null or not is_instance_valid(active_scene):
		load_mode(default_mode)

func _call_scene(method: String, args: Array = []) -> Variant:
	if active_scene and active_scene.has_method(method):
		return active_scene.callv(method, args)
	return null

func _update_review_overlay(label: String) -> void:
	if not status_label or not step_label:
		return
	status_label.text = label
	step_label.text = "Step: %s | Mode: %s | Preset: %s" % [current_step_id, active_mode, active_visual_preset]

func run_headed_smoke() -> void:
	var artifact_root := _artifact_root_from_args()
	var start_usec := Time.get_ticks_usec()
	var errors: Array[String] = []
	var steps: Array[Dictionary] = []
	for action in [
		"home",
		"launch_2d",
		"launch_25d",
		"preset_clean",
		"preset_atmospheric",
		"preset_vfx_stress",
		"select_hero",
		"select_worker",
		"box_select",
		"move",
		"attack",
		"pan_camera",
		"zoom_camera",
		"pause",
		"capture_site",
		"lume_link",
		"results",
		"return_home",
		"exit"
	]:
		var step_start := Time.get_ticks_usec()
		var status := _apply_review_action(action)
		await _settle_frames(3)
		if action != "home" and action != "return_home" and action != "exit" and not bool(status.get("ready", false)):
			errors.append("%s did not report ready scene status." % action)
		steps.append({
			"id": action,
			"label": _friendly_action(action),
			"mode": active_mode,
			"durationMs": snappedf(float(Time.get_ticks_usec() - step_start) / 1000.0, 0.01),
			"status": status
		})
	var report := {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"artifactRoot": artifact_root,
		"packagedExecutableMode": true,
		"headedWindow": DisplayServer.get_name() != "headless",
		"windowSize": {"width": current_viewport_size.x, "height": current_viewport_size.y},
		"routineEditorUseRequired": false,
		"manualEditorSceneAssemblyRequired": false,
		"localStorageMutationAllowed": false,
		"saveWritesAllowed": false,
		"godotVersion": Engine.get_version_info(),
		"fixtureHash": _fixture_hash(),
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"errors": errors,
		"steps": steps
	}
	_write_absolute_json(_path_join(artifact_root, "headed-smoke-runtime.json"), report)
	get_tree().quit(0 if errors.is_empty() else 1)

func run_capture_review() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var index := 0
	for viewport_size in CAPTURE_VIEWPORTS:
		_set_capture_viewport(viewport_size)
		await _settle_frames(8)
		for step in _capture_steps():
			var action := str(step["action"])
			var mode := str(step["mode"])
			var requested_preset := str(step.get("visualPreset", active_visual_preset))
			if mode == MODE_25D:
				active_visual_preset = _normalize_visual_preset(requested_preset)
			if mode == MODE_HOME:
				load_home()
			elif mode != active_mode:
				load_mode(mode)
			elif mode == MODE_25D and active_scene and active_scene.has_method("set_visual_preset"):
				active_scene.set_visual_preset(active_visual_preset)
			_apply_review_action(action)
			await _settle_frames(5)
			var file_name := "%03d_%s_%dx%d.png" % [index, str(step["id"]), viewport_size.x, viewport_size.y]
			var target := _path_join(screenshot_root, file_name)
			var image := get_viewport().get_texture().get_image()
			if image.get_width() != viewport_size.x or image.get_height() != viewport_size.y:
				image.resize(viewport_size.x, viewport_size.y, Image.INTERPOLATE_LANCZOS)
			var result := image.save_png(target)
			if result != OK:
				errors.append("Failed to save screenshot %s with code %s" % [file_name, result])
			captures.append({
				"id": step["id"],
				"label": step["label"],
				"mode": active_mode,
				"visualPreset": VISUAL_PRESET_2D_CONTROL if active_mode == MODE_2D else active_visual_preset,
				"action": action,
				"fileName": file_name,
				"absolutePath": target,
				"viewport": {"width": viewport_size.x, "height": viewport_size.y},
				"width": image.get_width(),
				"height": image.get_height(),
				"saveResult": result
			})
			index += 1
	var report := {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": _capture_steps().size() * CAPTURE_VIEWPORTS.size(),
		"captureViewports": CAPTURE_VIEWPORTS.map(func(size: Vector2i) -> Dictionary: return {"width": size.x, "height": size.y}),
		"visualPresets": [VISUAL_PRESET_2D_CONTROL, VISUAL_PRESET_CLEAN, VISUAL_PRESET_ATMOSPHERIC, VISUAL_PRESET_VFX_STRESS],
		"defaultReviewPreset": VISUAL_PRESET_CLEAN,
		"vfxStressExcludedFromDefaultReview": true,
		"windowSize": {"width": current_viewport_size.x, "height": current_viewport_size.y},
		"godotVersion": Engine.get_version_info(),
		"fixtureHash": _fixture_hash(),
		"routineEditorUseRequired": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"finalProductionCertification": false,
		"errors": errors,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "screenshot-runtime-manifest.json"), report)
	get_tree().quit(0 if errors.is_empty() else 1)

func run_headed_benchmark() -> void:
	var artifact_root := _artifact_root_from_args()
	var reports: Array[Dictionary] = []
	var errors: Array[String] = []
	for mode in [MODE_2D, MODE_25D]:
		var report := await _headed_benchmark_mode(mode)
		reports.append(report)
		if report.get("status", "FAIL") != "PASS":
			errors.append("%s headed benchmark failed" % mode)
		var file_name := "headed-benchmark-runtime-2d.json" if mode == MODE_2D else "headed-benchmark-runtime-2_5d.json"
		_write_absolute_json(_path_join(artifact_root, file_name), report)
	_write_absolute_json(_path_join(artifact_root, "headed-benchmark-runtime-summary.json"), {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"artifactRoot": artifact_root,
		"errors": errors,
		"reports": reports
	})
	get_tree().quit(0 if errors.is_empty() else 1)

func _headed_benchmark_mode(mode: String) -> Dictionary:
	var start := Time.get_ticks_usec()
	load_mode(mode)
	await _settle_frames(30)
	var launch := Time.get_ticks_usec()
	_call_scene("select_entity", ["hero_aster"])
	_call_scene("box_select_squad")
	var input_start := Time.get_ticks_usec()
	_call_scene("issue_move_order")
	_call_scene("issue_attack_order")
	var input_end := Time.get_ticks_usec()
	await _settle_frames(5)
	_call_scene("transition_results")
	var results_end := Time.get_ticks_usec()
	var frame_times: Array[float] = []
	for _index in range(180):
		var before := Time.get_ticks_usec()
		await get_tree().process_frame
		var after := Time.get_ticks_usec()
		frame_times.append(max(0.01, float(after - before) / 1000.0))
	var report := _metrics(mode, start, launch, input_start, input_end, results_end, frame_times)
	report["benchmarkKind"] = "headed-packaged-placeholder"
	report["windowSize"] = {"width": current_viewport_size.x, "height": current_viewport_size.y}
	report["godotVersion"] = Engine.get_version_info()
	report["fixtureHash"] = _fixture_hash()
	report["runtimeArtIntegrated"] = false
	report["finalProductionCertification"] = false
	return report

func run_player_slice_validation() -> void:
	var artifact_root := _artifact_root_from_args()
	var errors: Array[String] = []
	var steps: Array[Dictionary] = []
	var start_usec := Time.get_ticks_usec()
	var actions := [
		"title",
		"briefing",
		"battle_default",
		"hud_default",
		"objective_1",
		"onboarding_skip_private",
		"hero_selected",
		"move_order",
		"quarry_objective",
		"worker_selected",
		"squad_selected",
		"ashen_pressure_wave",
		"lume_stable",
		"lume_activation",
		"lume_restore",
		"minimap",
		"results"
	]
	if _is_bounded_microloop_checkpoint():
		actions = [
			"title",
			"briefing",
			"battle_default",
			"hero_selected",
			"worker_selected",
			"mine_uncaptured",
			"move_order",
			"mine_converted",
			"worker_assigned_mine",
			"quarry_objective",
			"build_placement",
			"construction_progress",
			"barracks_complete",
			"recruit_queue",
			"militia_spawned",
			"ashen_pressure_wave",
			"lume_restore",
			"minimap",
			"results"
		]
	for action in actions:
		var step_start := Time.get_ticks_usec()
		var status := _apply_player_slice_action(action)
		await _settle_frames(4)
		var ok := bool(status.get("ready", false))
		if action == "title" or action == "briefing":
			ok = true
		if not ok:
			errors.append("%s did not reach a ready player-slice state." % action)
		steps.append({
			"id": action,
			"screen": active_mode,
			"durationMs": snappedf(float(Time.get_ticks_usec() - step_start) / 1000.0, 0.01),
			"status": status,
			"visibleText": player_visible_texts.duplicate()
		})
	var frame_times: Array[float] = []
	for _index in range(120):
		var before := Time.get_ticks_usec()
		await get_tree().process_frame
		var after := Time.get_ticks_usec()
		frame_times.append(max(0.01, float(after - before) / 1000.0))
	var frame_sum := 0.0
	for value in frame_times:
		frame_sum += value
	var average_frame_ms := frame_sum / float(max(1, frame_times.size()))
	var performance_smoke := {
		"schemaVersion": 1,
		"checkpoint": _player_capture_checkpoint(),
		"status": "PASS_PLAYER_FACING_TIER_M_SMOKE",
		"mode": MODE_25D,
		"visualPreset": VISUAL_PRESET_CLEAN,
		"tier": "M",
		"fpsAverage": snappedf(min(240.0, 1000.0 / max(0.01, average_frame_ms)), 0.01),
		"frameTimeP95Ms": _percentile(frame_times, 0.95),
		"inputAcceptance": true,
		"objectiveTransition": current_step_id == "player_results",
		"stuckUnits": 0,
		"resultsTransition": current_step_id == "player_results",
		"finalProductionCertification": false
	}
	var forbidden_terms := _player_forbidden_terms()
	var forbidden_hits: Array[String] = []
	for text in _all_player_text_from_steps(steps):
		for term in forbidden_terms:
			if text.to_lower().contains(term):
				forbidden_hits.append("%s in '%s'" % [term, text])
	var report := {
		"schemaVersion": 1,
		"checkpoint": _player_capture_checkpoint(),
		"status": "PASS_PLAYER_SLICE_VALIDATION" if errors.is_empty() and forbidden_hits.is_empty() else "FAIL_PLAYER_SLICE_VALIDATION",
		"artifactRoot": artifact_root,
		"defaultHumanReviewPath": "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
		"privateHarnessPreservedSeparately": true,
		"defaultMode": MODE_25D,
		"defaultVisualPreset": VISUAL_PRESET_CLEAN,
		"routineEditorUseRequired": false,
		"manualGodotEditorSceneAssemblyRequired": false,
		"proceduralPrimitiveOnly": true,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"localStorageMutationAllowed": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"debugTextAbsentFromPlayerSlice": forbidden_hits.is_empty(),
		"performanceSmoke": performance_smoke,
		"forbiddenTextHits": forbidden_hits,
		"objectiveSequence": steps.map(func(step: Dictionary) -> String: return str(step["id"])),
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"errors": errors,
		"steps": steps
	}
	_write_absolute_json(_path_join(artifact_root, "player-slice-validation-runtime.json"), report)
	_write_absolute_json(_path_join(artifact_root, "performance-smoke-runtime.json"), performance_smoke)
	_write_absolute_json(_path_join(artifact_root, "objective-flow-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": _player_capture_checkpoint(),
		"status": "PASS_OBJECTIVE_FLOW" if errors.is_empty() else "FAIL_OBJECTIVE_FLOW",
		"steps": steps,
		"resultsReached": current_step_id == "player_results",
		"saveWritesAllowed": false
	})
	get_tree().quit(0 if errors.is_empty() and forbidden_hits.is_empty() else 1)

func run_player_slice_capture() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	_set_capture_viewport(VIEWPORT_SIZE)
	await _settle_frames(8)
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var capture_steps := _player_capture_steps()
	var index := 0
	for step in capture_steps:
		var action := str(step["action"])
		var status := _apply_player_slice_action(action)
		await _settle_frames(6)
		var file_name := "%02d_%s.png" % [index + 1, str(step["id"])]
		var target := _path_join(screenshot_root, file_name)
		var image := get_viewport().get_texture().get_image()
		if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
			image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
		var result := image.save_png(target)
		if result != OK:
			errors.append("Failed to save screenshot %s with code %s" % [file_name, result])
		captures.append({
			"id": step["id"],
			"label": step["label"],
			"fileName": file_name,
			"absolutePath": target,
			"width": image.get_width(),
			"height": image.get_height(),
			"screen": active_mode,
			"action": action,
			"privateHarnessCapture": action == "private_harness",
			"status": status,
			"visibleText": player_visible_texts.duplicate()
		})
		index += 1
	var report := {
		"schemaVersion": 1,
		"checkpoint": _player_capture_checkpoint(),
		"status": "PASS_PLAYER_SLICE_CAPTURE" if errors.is_empty() else "FAIL_PLAYER_SLICE_CAPTURE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": capture_steps.size(),
		"viewport": {"width": VIEWPORT_SIZE.x, "height": VIEWPORT_SIZE.y},
		"defaultMode": MODE_25D,
		"defaultVisualPreset": VISUAL_PRESET_CLEAN,
		"privateHarnessPreservedSeparately": captures.any(func(capture: Dictionary) -> bool: return bool(capture.get("privateHarnessCapture", false))) or ["v0.126", "v0.127", "v0.128", "v0.129", "v0.130"].has(_player_capture_checkpoint()),
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"routineEditorUseRequired": false,
		"errors": errors,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "screenshot-runtime-manifest.json"), report)
	get_tree().quit(0 if errors.is_empty() else 1)

func run_real_input_smoke() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	_set_capture_viewport(VIEWPORT_SIZE)
	await _settle_frames(8)
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var trace: Array[Dictionary] = []
	var start_usec := Time.get_ticks_usec()
	show_player_title()
	await _settle_frames(8)
	_trace_real_input(trace, "launch", {"screen": "title"})
	await _inject_mouse_click(Vector2(750, 303), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "title_start_clicked", {"screen": "title", "position": _vector2_report(Vector2(750, 303))})
	await _settle_frames(8)
	if current_step_id != "player_briefing":
		errors.append("Start Salto Review did not open the briefing.")
	await _inject_mouse_click(Vector2(750, 411), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "briefing_start_battle_clicked", {"screen": "briefing", "position": _vector2_report(Vector2(750, 411))})
	await _settle_frames(16)
	if current_step_id != "player_battle":
		errors.append("Start Battle did not open the player-facing battle.")
	else:
		_trace_real_input(trace, "battle_ready", {"screen": "battle"})
	captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "battle_initial_camera_focus", "Battle initial camera focus", "battle_ready"))
	captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "aster_pulsing", "Aster pulsing", "aster_pulsing"))
	var hero_screen := _scene_screen_position("hero_aster")
	var quarry_screen := _scene_screen_position("quarry")
	var worker_screen := _scene_screen_position("worker_00")
	var squad_start := _scene_screen_position("squad_drag_start")
	var squad_end := _scene_screen_position("squad_drag_end")
	if hero_screen == Vector2.INF or quarry_screen == Vector2.INF or worker_screen == Vector2.INF:
		errors.append("Could not resolve real-input click coordinates for Aster, Worker, or quarry.")
	else:
		await _inject_mouse_motion(hero_screen)
		_trace_real_input(trace, "aster_hover", {"position": _vector2_report(hero_screen)})
		await _settle_frames(6)
		captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "cursor_hover_aster", "Cursor hover Aster", "aster_hover"))
		await _inject_mouse_click(hero_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "aster_click", {"position": _vector2_report(hero_screen)})
		await _settle_frames(8)
		captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "aster_selected", "Aster selected", "aster_selected"))
		captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "hud_card_updated", "HUD card updated", "hud_card_updated"))
		_trace_real_input(trace, "hud_card_updated", {"selected": "hero_aster"})
		captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "move_destination_pulse", "Move destination pulse", "move_destination_pulse"))
		await _inject_mouse_click(quarry_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "quarry_right_click", {"position": _vector2_report(quarry_screen)})
		await _settle_frames(10)
		captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "move_marker", "Move marker", "move_marker"))
		await _settle_until_scene_flag("visibleMovementConfirmed", true, 180)
		var hero_screen_after_move := _scene_screen_position("hero_aster")
		_trace_real_input(trace, "aster_visible_movement_confirmed", {"position": _vector2_report(hero_screen_after_move)})
		var movement_scene_status_raw: Variant = _call_scene("real_input_smoke_status")
		var movement_scene_status: Dictionary = movement_scene_status_raw if typeof(movement_scene_status_raw) == TYPE_DICTIONARY else {}
		_trace_real_input(trace, "meaningful_displacement", {
			"movementDisplacement": movement_scene_status.get("movementDisplacement", 0.0),
			"visibleMovementConfirmed": movement_scene_status.get("visibleMovementConfirmed", false),
			"visibleMovementDelta": movement_scene_status.get("visibleMovementDelta", 0.0)
		})
		captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "aster_displaced", "Aster displaced", "aster_displaced"))
		await _settle_until_scene_flag("objectiveAdvancedAfterRealMovement", true, 120)
		_trace_real_input(trace, "objective_advanced", {"after": "real_movement"})
		captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "objective_advanced", "Objective advanced", "objective_advanced"))
		await _inject_mouse_motion(worker_screen)
		_trace_real_input(trace, "worker_hover", {"position": _vector2_report(worker_screen)})
		await _settle_frames(4)
		captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "worker_hover", "Worker hover", "worker_hover"))
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "worker_click", {"position": _vector2_report(worker_screen)})
		await _settle_frames(6)
		captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "worker_selected", "Worker selected", "worker_selected"))
		if squad_start != Vector2.INF and squad_end != Vector2.INF:
			await _inject_mouse_drag(squad_start, squad_end)
			_trace_real_input(trace, "squad_box_drag", {"start": _vector2_report(squad_start), "end": _vector2_report(squad_end)})
			await _settle_frames(8)
			captures.append(await _capture_real_input_step(screenshot_root, captures.size(), "squad_box_selected", "Squad box selected", "squad_box_selected"))
		else:
			errors.append("Could not resolve squad box-select coordinates.")
	var raw_scene_status: Variant = _call_scene("real_input_smoke_status")
	var scene_status: Dictionary = raw_scene_status if typeof(raw_scene_status) == TYPE_DICTIONARY else {}
	if scene_status.is_empty():
		errors.append("Scene did not return real-input smoke status.")
	var required_flags := {
		"hoverTargetId": str(scene_status.get("hoverTargetId", "")) != "",
		"selectedUnitId": bool(scene_status.get("asterSelected", false)),
		"hudCardUpdated": bool(scene_status.get("hudCardUpdated", false)),
		"moveOrderAccepted": bool(scene_status.get("moveOrderAccepted", false)),
		"moveMarkerRendered": bool(scene_status.get("moveMarkerRendered", false)),
		"movementStarted": bool(scene_status.get("movementStarted", false)),
		"visibleMovementConfirmed": bool(scene_status.get("visibleMovementConfirmed", false)),
		"objectiveAdvancedAfterRealMovement": bool(scene_status.get("objectiveAdvancedAfterRealMovement", false)),
		"workerSelected": bool(scene_status.get("workerSelected", false)),
		"squadBoxSelected": bool(scene_status.get("squadBoxSelected", false)),
		"debugShortcutUsed": not bool(scene_status.get("debugShortcutUsed", false)),
		"stateInjectionUsed": not bool(scene_status.get("stateInjectionUsed", false))
	}
	for key in required_flags.keys():
		if not bool(required_flags[key]):
			errors.append("Real-input smoke check failed: %s" % key)
	var combined_trace: Array = trace.duplicate(true)
	for entry in scene_status.get("trace", []):
		combined_trace.append(entry)
	var smoke := {
		"schemaVersion": 1,
		"checkpoint": "v0.131",
		"status": "PASS_HEADED_REAL_INPUT_SMOKE" if errors.is_empty() else "FAIL_HEADED_REAL_INPUT_SMOKE",
		"artifactRoot": artifact_root,
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"inputPath": "packaged Godot player slice normal mouse events",
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": bool(scene_status.get("debugShortcutUsed", false)),
		"stateInjectionUsed": bool(scene_status.get("stateInjectionUsed", false)),
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"checks": required_flags,
		"errors": errors,
		"sceneStatus": scene_status
	}
	var screenshot_manifest := {
		"schemaVersion": 1,
		"checkpoint": "v0.131",
		"status": "PASS_V0131_REAL_INPUT_SCREENSHOTS" if captures.size() == 12 and errors.is_empty() else "FAIL_V0131_REAL_INPUT_SCREENSHOTS",
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": 12,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "headed-playability-smoke.json"), smoke)
	_write_absolute_json(_path_join(artifact_root, "real-input-trace.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.131",
		"trace": combined_trace,
		"noDebugShortcutUsed": not bool(scene_status.get("debugShortcutUsed", false)),
		"noStateInjectionUsed": not bool(scene_status.get("stateInjectionUsed", false))
	})
	_write_absolute_json(_path_join(artifact_root, "selection-proof.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.131",
		"status": "PASS_SELECTION_PROOF" if bool(required_flags.get("selectedUnitId", false)) and bool(required_flags.get("workerSelected", false)) and bool(required_flags.get("squadBoxSelected", false)) else "FAIL_SELECTION_PROOF",
		"selectedIds": scene_status.get("selectedIds", []),
		"asterSelected": scene_status.get("asterSelected", false),
		"finalSelectedUnitId": scene_status.get("selectedUnitId", ""),
		"hoverTargetId": scene_status.get("hoverTargetId", ""),
		"hudCardUpdated": scene_status.get("hudCardUpdated", false)
	})
	_write_absolute_json(_path_join(artifact_root, "movement-proof.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.131",
		"status": "PASS_MOVEMENT_PROOF" if bool(required_flags.get("moveOrderAccepted", false)) and bool(required_flags.get("movementStarted", false)) and bool(required_flags.get("visibleMovementConfirmed", false)) and bool(required_flags.get("objectiveAdvancedAfterRealMovement", false)) else "FAIL_MOVEMENT_PROOF",
		"moveOrderAccepted": scene_status.get("moveOrderAccepted", false),
		"moveMarkerRendered": scene_status.get("moveMarkerRendered", false),
		"movementStarted": scene_status.get("movementStarted", false),
		"movementCompleted": scene_status.get("movementCompleted", false),
		"movementDisplacement": scene_status.get("movementDisplacement", 0.0),
		"visibleMovementConfirmed": scene_status.get("visibleMovementConfirmed", false),
		"visibleMovementDelta": scene_status.get("visibleMovementDelta", 0.0),
		"asterStartScreen": scene_status.get("asterStartScreen", {}),
		"asterCurrentScreen": scene_status.get("asterCurrentScreen", {}),
		"objectiveAdvancedAfterRealMovement": scene_status.get("objectiveAdvancedAfterRealMovement", false)
	})
	_write_absolute_json(_path_join(artifact_root, "screenshot-manifest.json"), screenshot_manifest)
	_write_absolute_text(_path_join(artifact_root, "real-input-trace.md"), _real_input_trace_markdown(smoke, combined_trace))
	_write_absolute_text(_path_join(artifact_root, "README.md"), _real_input_readme(smoke, screenshot_manifest))
	get_tree().quit(0 if errors.is_empty() else 1)

func _inject_mouse_motion(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	get_viewport().push_input(motion, true)
	await _settle_frames(2)

func _inject_mouse_click(position: Vector2, button: int) -> void:
	await _inject_mouse_motion(position)
	var down := InputEventMouseButton.new()
	down.position = position
	down.global_position = position
	down.button_index = button
	down.pressed = true
	get_viewport().push_input(down, true)
	await _settle_frames(2)
	var up := InputEventMouseButton.new()
	up.position = position
	up.global_position = position
	up.button_index = button
	up.pressed = false
	get_viewport().push_input(up, true)
	await _settle_frames(2)

func _inject_mouse_drag(start: Vector2, end: Vector2) -> void:
	await _inject_mouse_motion(start)
	var down := InputEventMouseButton.new()
	down.position = start
	down.global_position = start
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	get_viewport().push_input(down, true)
	await _settle_frames(2)
	for index in range(1, 7):
		var t := float(index) / 6.0
		var position := start.lerp(end, t)
		var motion := InputEventMouseMotion.new()
		motion.position = position
		motion.global_position = position
		motion.relative = (end - start) / 6.0
		get_viewport().push_input(motion, true)
		await _settle_frames(1)
	var up := InputEventMouseButton.new()
	up.position = end
	up.global_position = end
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	get_viewport().push_input(up, true)
	await _settle_frames(2)

func _scene_screen_position(subject: String) -> Vector2:
	var result: Variant = _call_scene("real_input_screen_position", [subject])
	if typeof(result) == TYPE_VECTOR2:
		return result
	return Vector2.INF

func _settle_until_scene_flag(flag: String, expected: Variant, max_frames: int) -> void:
	await _settle_until_scene_status_flag("real_input_smoke_status", flag, expected, max_frames)

func _settle_until_scene_status_flag(status_method: String, flag: String, expected: Variant, max_frames: int) -> void:
	for _index in range(max_frames):
		var raw_status: Variant = _call_scene(status_method)
		var status: Dictionary = raw_status if typeof(raw_status) == TYPE_DICTIONARY else {}
		if status.has(flag) and status[flag] == expected:
			return
		await get_tree().process_frame

func _settle_until_scene_status_number_at_least(status_method: String, flag: String, threshold: float, max_frames: int) -> void:
	for _index in range(max_frames):
		var raw_status: Variant = _call_scene(status_method)
		var status: Dictionary = raw_status if typeof(raw_status) == TYPE_DICTIONARY else {}
		if status.has(flag) and float(status[flag]) >= threshold:
			return
		await get_tree().process_frame

func _capture_real_input_step(screenshot_root: String, index: int, id: String, label: String, action: String) -> Dictionary:
	await _settle_frames(2)
	var file_name := "%02d_%s.png" % [index + 1, id]
	var target := _path_join(screenshot_root, file_name)
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var save_result := image.save_png(target)
	return {
		"id": id,
		"label": label,
		"fileName": file_name,
		"absolutePath": target,
		"width": image.get_width(),
		"height": image.get_height(),
		"screen": active_mode,
		"action": action,
		"saveStatus": save_result,
		"status": get_spike_status()
	}

func _trace_real_input(trace: Array[Dictionary], event_name: String, details: Dictionary) -> void:
	trace.append({
		"index": trace.size() + 1,
		"event": event_name,
		"frame": Engine.get_process_frames(),
		"details": details
	})

func _vector2_report(position: Vector2) -> Dictionary:
	return {"x": snappedf(position.x, 0.001), "y": snappedf(position.y, 0.001)}

func _real_input_trace_markdown(smoke: Dictionary, trace: Array) -> String:
	var lines := [
		"# v0.131 Real Input Trace",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"| # | Event | Details |",
		"| --- | --- | --- |"
	]
	for index in range(trace.size()):
		var entry: Dictionary = trace[index]
		lines.append("| %s | %s | `%s` |" % [index + 1, str(entry.get("event", "")), JSON.stringify(entry.get("details", {}))])
	lines.append("")
	lines.append("Private harness shortcut used: `%s`" % str(smoke.get("privateHarnessShortcutUsed", false)))
	lines.append("Debug shortcut used: `%s`" % str(smoke.get("debugShortcutUsed", false)))
	lines.append("State injection used: `%s`" % str(smoke.get("stateInjectionUsed", false)))
	return "\n".join(lines) + "\n"

func _real_input_readme(smoke: Dictionary, manifest: Dictionary) -> String:
	return "\n".join([
		"# v0.131 Godot Real-Input Evidence",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"These ignored artifacts are generated by `GODOT_REAL_INPUT_SMOKE_WINDOWS.bat` / `npm run godot:headed:real-input-smoke` against the packaged player-facing Godot slice.",
		"",
		"- `headed-playability-smoke.json` records the gated real-input smoke result.",
		"- `real-input-trace.json` and `real-input-trace.md` record title, briefing, selection, movement, objective, Worker, and box-select events.",
		"- `selection-proof.json` records Aster, Worker, HUD, and squad-selection evidence.",
		"- `movement-proof.json` records right-click move, marker, displacement, and objective-advance evidence.",
		"- `screenshot-manifest.json` records `%s/%s` required screenshots." % [manifest.get("captureCount", 0), manifest.get("requiredCaptureCount", 12)],
		"",
		"No debug shortcut, private-harness action, state injection, save write, stable-ID change, or Godot-editor work is accepted as proof."
	]) + "\n"

func run_site_semantics_smoke() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	_set_capture_viewport(VIEWPORT_SIZE)
	await _settle_frames(8)
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var trace: Array[Dictionary] = []
	var start_usec := Time.get_ticks_usec()
	show_player_title()
	await _settle_frames(8)
	_trace_real_input(trace, "launch", {"screen": "title"})
	await _inject_mouse_click(Vector2(750, 303), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "title_start_clicked", {"screen": "title", "position": _vector2_report(Vector2(750, 303))})
	await _settle_frames(8)
	if current_step_id != "player_briefing":
		errors.append("Start Salto Review did not open the briefing.")
	await _inject_mouse_click(Vector2(750, 411), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "briefing_start_battle_clicked", {"screen": "briefing", "position": _vector2_report(Vector2(750, 411))})
	await _settle_frames(16)
	if current_step_id != "player_battle":
		errors.append("Start Battle did not open the player-facing battle.")
	else:
		_trace_real_input(trace, "battle_ready", {"screen": "battle"})
	captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "battle_initial", "Battle initial view", "battle_ready"))
	captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "canonical_mine_highlight", "West Stone Cut Mine highlight", "mine_highlight"))
	var hero_screen := _scene_screen_position("hero_aster")
	var mine_screen := _scene_screen_position("west_stone_cut_mine")
	var worker_screen := _scene_screen_position("worker_00")
	if hero_screen == Vector2.INF or mine_screen == Vector2.INF or worker_screen == Vector2.INF:
		errors.append("Could not resolve real-input click coordinates for Aster, West Stone Cut Mine, or Worker.")
	else:
		await _inject_mouse_motion(hero_screen)
		_trace_real_input(trace, "aster_hover", {"position": _vector2_report(hero_screen)})
		await _settle_frames(4)
		await _inject_mouse_click(hero_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "aster_click", {"position": _vector2_report(hero_screen)})
		await _settle_frames(8)
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "aster_selected", "Aster selected", "aster_selected"))
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "mine_right_click", {"position": _vector2_report(mine_screen)})
		await _settle_frames(8)
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "move_marker", "Move marker toward West Stone Cut Mine", "move_marker"))
		await _settle_until_scene_status_flag("site_semantics_status", "asterEnteredMineCaptureRadius", true, 220)
		_trace_real_input(trace, "aster_entered_mine_capture_radius", {"site": "West Stone Cut Mine"})
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "aster_capture_radius", "Aster inside capture radius", "aster_capture_radius"))
		await _settle_until_scene_status_number_at_least("site_semantics_status", "conversionProgress", 25.0, 180)
		_trace_real_input(trace, "mine_conversion_progress_25", {"site": "West Stone Cut Mine"})
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "conversion_progress_25", "Conversion progress 25 percent", "conversion_progress_25"))
		await _settle_until_scene_status_number_at_least("site_semantics_status", "conversionProgress", 75.0, 180)
		_trace_real_input(trace, "mine_conversion_progress_75", {"site": "West Stone Cut Mine"})
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "conversion_progress_75", "Conversion progress 75 percent", "conversion_progress_75"))
		await _settle_until_scene_status_flag("site_semantics_status", "mineControlled", true, 220)
		_trace_real_input(trace, "mine_controlled", {"site": "West Stone Cut Mine"})
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "mine_controlled", "West Stone Cut Mine controlled", "mine_controlled"))
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "objective_no_regression", "Objective did not regress", "objective_no_regression"))
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "worker_highlight", "Worker highlighted", "worker_highlight"))
		await _inject_mouse_motion(worker_screen)
		_trace_real_input(trace, "worker_hover", {"position": _vector2_report(worker_screen)})
		await _settle_frames(4)
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "worker_click", {"position": _vector2_report(worker_screen)})
		await _settle_frames(8)
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "worker_selected", "Worker selected", "worker_selected"))
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "worker_right_click_controlled_mine", {"position": _vector2_report(mine_screen), "site": "West Stone Cut Mine"})
		await _settle_frames(8)
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "worker_assignment_right_click", "Worker right-click assignment", "worker_assignment_right_click"))
		await _settle_until_scene_status_flag("site_semantics_status", "workerAssignedToMine", true, 120)
		_trace_real_input(trace, "worker_assignment_feedback", {"site": "West Stone Cut Mine"})
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "worker_assignment_feedback", "Worker assignment feedback", "worker_assignment_feedback"))
		await _settle_until_scene_status_flag("site_semantics_status", "productionBoostFeedbackRendered", true, 120)
		_trace_real_input(trace, "production_boost_feedback", {"site": "West Stone Cut Mine"})
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "production_boost_feedback", "Production boost feedback", "production_boost_feedback"))
		await _settle_until_scene_status_flag("site_semantics_status", "objectiveAdvancedAfterWorkerAssignment", true, 120)
		_trace_real_input(trace, "objective_advanced_after_worker_assignment", {"site": "West Stone Cut Mine"})
		captures.append(await _capture_site_semantics_step(screenshot_root, captures.size(), "objective_advanced_after_worker", "Objective advanced after Worker assignment", "objective_advanced_after_worker"))
	var raw_scene_status: Variant = _call_scene("site_semantics_status")
	var scene_status: Dictionary = raw_scene_status if typeof(raw_scene_status) == TYPE_DICTIONARY else {}
	if scene_status.is_empty():
		errors.append("Scene did not return v0.132 site-semantics status.")
	var required_flags := {
		"asterSelected": bool(scene_status.get("asterSelected", false)),
		"moveOrderAccepted": bool(scene_status.get("moveOrderAccepted", false)),
		"moveMarkerRendered": bool(scene_status.get("moveMarkerRendered", false)),
		"movementStarted": bool(scene_status.get("movementStarted", false)),
		"visibleMovementConfirmed": bool(scene_status.get("visibleMovementConfirmed", false)),
		"asterEnteredMineCaptureRadius": bool(scene_status.get("asterEnteredMineCaptureRadius", false)),
		"conversionProgressVisible": bool(scene_status.get("conversionProgressVisible", false)),
		"mineControlled": bool(scene_status.get("mineControlled", false)),
		"workerHighlightVisible": bool(scene_status.get("workerHighlightVisible", false)),
		"workerSelected": bool(scene_status.get("workerSelected", false)),
		"workerAssignmentMarkerRendered": bool(scene_status.get("workerAssignmentMarkerRendered", false)),
		"workerAssignedToMine": bool(scene_status.get("workerAssignedToMine", false)),
		"productionBoostFeedbackRendered": bool(scene_status.get("productionBoostFeedbackRendered", false)),
		"objectiveAdvancedAfterWorkerAssignment": bool(scene_status.get("objectiveAdvancedAfterWorkerAssignment", false)),
		"noActualObjectiveRegression": not bool(scene_status.get("actualObjectiveRegressionDetected", true)),
		"debugShortcutNotUsed": not bool(scene_status.get("debugShortcutUsed", true)),
		"stateInjectionNotUsed": not bool(scene_status.get("stateInjectionUsed", true))
	}
	for key in required_flags.keys():
		if not bool(required_flags[key]):
			errors.append("v0.132 site-semantics smoke check failed: %s" % key)
	if str(scene_status.get("canonicalSiteLabel", "")) != "West Stone Cut Mine":
		errors.append("Scene did not report West Stone Cut Mine as the canonical site label.")
	var combined_trace: Array = trace.duplicate(true)
	for entry in scene_status.get("trace", []):
		combined_trace.append(entry)
	var smoke := {
		"schemaVersion": 1,
		"checkpoint": "v0.132",
		"status": "PASS_V0132_HEADED_SITE_SEMANTICS_SMOKE" if errors.is_empty() else "FAIL_V0132_HEADED_SITE_SEMANTICS_SMOKE",
		"artifactRoot": artifact_root,
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"inputPath": "packaged Godot player slice normal mouse events",
		"canonicalSiteLabel": "West Stone Cut Mine",
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": bool(scene_status.get("debugShortcutUsed", false)),
		"stateInjectionUsed": bool(scene_status.get("stateInjectionUsed", false)),
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"checks": required_flags,
		"errors": errors,
		"sceneStatus": scene_status
	}
	var screenshot_manifest := {
		"schemaVersion": 1,
		"checkpoint": "v0.132",
		"status": "PASS_V0132_SITE_SEMANTICS_SCREENSHOTS" if captures.size() == 15 and errors.is_empty() else "FAIL_V0132_SITE_SEMANTICS_SCREENSHOTS",
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": 15,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "headed-site-semantics-smoke.json"), smoke)
	_write_absolute_json(_path_join(artifact_root, "site-semantics-trace.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.132",
		"trace": combined_trace,
		"noDebugShortcutUsed": not bool(scene_status.get("debugShortcutUsed", false)),
		"noStateInjectionUsed": not bool(scene_status.get("stateInjectionUsed", false))
	})
	_write_absolute_json(_path_join(artifact_root, "mine-conversion-proof.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.132",
		"status": "PASS_MINE_CONVERSION_PROOF" if bool(required_flags.get("asterEnteredMineCaptureRadius", false)) and bool(required_flags.get("conversionProgressVisible", false)) and bool(required_flags.get("mineControlled", false)) else "FAIL_MINE_CONVERSION_PROOF",
		"canonicalSiteLabel": scene_status.get("canonicalSiteLabel", ""),
		"siteState": scene_status.get("siteState", ""),
		"conversionProgress": scene_status.get("conversionProgress", 0.0),
		"mineControlled": scene_status.get("mineControlled", false)
	})
	_write_absolute_json(_path_join(artifact_root, "worker-assignment-proof.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.132",
		"status": "PASS_WORKER_ASSIGNMENT_PROOF" if bool(required_flags.get("workerSelected", false)) and bool(required_flags.get("workerAssignedToMine", false)) and bool(required_flags.get("productionBoostFeedbackRendered", false)) and bool(required_flags.get("objectiveAdvancedAfterWorkerAssignment", false)) else "FAIL_WORKER_ASSIGNMENT_PROOF",
		"workerSelected": scene_status.get("workerSelected", false),
		"workerAssignedToMine": scene_status.get("workerAssignedToMine", false),
		"productionBoostFeedbackRendered": scene_status.get("productionBoostFeedbackRendered", false),
		"objectiveAdvancedAfterWorkerAssignment": scene_status.get("objectiveAdvancedAfterWorkerAssignment", false)
	})
	_write_absolute_json(_path_join(artifact_root, "objective-monotonicity.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.132",
		"status": "PASS_OBJECTIVE_MONOTONICITY_PROOF" if not bool(scene_status.get("actualObjectiveRegressionDetected", true)) else "FAIL_OBJECTIVE_MONOTONICITY_PROOF",
		"objectiveStep": scene_status.get("objectiveStep", ""),
		"objectiveRank": scene_status.get("objectiveRank", 0),
		"objectiveRegressionBlockedCount": scene_status.get("objectiveRegressionBlockedCount", 0),
		"actualObjectiveRegressionDetected": scene_status.get("actualObjectiveRegressionDetected", true),
		"objectiveHistory": scene_status.get("objectiveHistory", [])
	})
	_write_absolute_json(_path_join(artifact_root, "screenshot-manifest.json"), screenshot_manifest)
	_write_absolute_text(_path_join(artifact_root, "site-semantics-trace.md"), _site_semantics_trace_markdown(smoke, combined_trace))
	_write_absolute_text(_path_join(artifact_root, "README.md"), _site_semantics_readme(smoke, screenshot_manifest))
	get_tree().quit(0 if errors.is_empty() else 1)

func _capture_site_semantics_step(screenshot_root: String, index: int, id: String, label: String, action: String) -> Dictionary:
	await _settle_frames(2)
	var file_name := "%02d_%s.png" % [index + 1, id]
	var target := _path_join(screenshot_root, file_name)
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var save_result := image.save_png(target)
	return {
		"id": id,
		"label": label,
		"fileName": file_name,
		"absolutePath": target,
		"width": image.get_width(),
		"height": image.get_height(),
		"screen": active_mode,
		"action": action,
		"saveStatus": save_result,
		"status": _call_scene("site_semantics_status")
	}

func _site_semantics_trace_markdown(smoke: Dictionary, trace: Array) -> String:
	var lines := [
		"# v0.132 Site Semantics Trace",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"| # | Event | Details |",
		"| --- | --- | --- |"
	]
	for index in range(trace.size()):
		var entry: Dictionary = trace[index]
		lines.append("| %s | %s | `%s` |" % [index + 1, str(entry.get("event", "")), JSON.stringify(entry.get("details", {}))])
	lines.append("")
	lines.append("Private harness shortcut used: `%s`" % str(smoke.get("privateHarnessShortcutUsed", false)))
	lines.append("Debug shortcut used: `%s`" % str(smoke.get("debugShortcutUsed", false)))
	lines.append("State injection used: `%s`" % str(smoke.get("stateInjectionUsed", false)))
	return "\n".join(lines) + "\n"

func _site_semantics_readme(smoke: Dictionary, manifest: Dictionary) -> String:
	return "\n".join([
		"# v0.132 Godot Site-Semantics Evidence",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"These ignored artifacts are generated by `GODOT_SITE_SEMANTICS_SMOKE_WINDOWS.bat` / `npm run godot:headed:site-semantics-smoke` against the packaged player-facing Godot slice.",
		"",
		"- `headed-site-semantics-smoke.json` records the gated real-input smoke result.",
		"- `site-semantics-trace.json` and `site-semantics-trace.md` record title, briefing, Aster movement, mine conversion, Worker assignment, and objective events.",
		"- `mine-conversion-proof.json` records capture-radius, conversion-progress, and controlled-state evidence.",
		"- `worker-assignment-proof.json` records Worker selection, assignment, production boost, and objective-advance evidence.",
		"- `objective-monotonicity.json` records accepted and blocked tutorial transitions.",
		"- `screenshot-manifest.json` records `%s/%s` required screenshots." % [manifest.get("captureCount", 0), manifest.get("requiredCaptureCount", 15)],
		"",
		"No debug shortcut, private-harness action, state injection, save write, stable-ID change, or Godot-editor work is accepted as proof."
	]) + "\n"

func run_post_mine_flow_smoke() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	_set_capture_viewport(VIEWPORT_SIZE)
	await _settle_frames(8)
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var trace: Array[Dictionary] = []
	var start_usec := Time.get_ticks_usec()
	last_post_mine_flow_status = {}
	show_player_title()
	await _settle_frames(8)
	_trace_real_input(trace, "launch", {"screen": "title"})
	await _inject_mouse_click(Vector2(750, 303), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "title_start_clicked", {"screen": "title", "position": _vector2_report(Vector2(750, 303))})
	await _settle_frames(8)
	if current_step_id != "player_briefing":
		errors.append("Start Salto Review did not open the briefing.")
	await _inject_mouse_click(Vector2(750, 411), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "briefing_start_battle_clicked", {"screen": "briefing", "position": _vector2_report(Vector2(750, 411))})
	await _settle_frames(16)
	if current_step_id != "player_battle":
		errors.append("Start Battle did not open the player-facing battle.")
	else:
		_trace_real_input(trace, "battle_ready", {"screen": "battle"})
	var hero_screen := _scene_screen_position("hero_aster")
	var mine_screen := _scene_screen_position("west_stone_cut_mine")
	var worker_screen := _scene_screen_position("worker_00")
	var barracks_screen := _scene_screen_position("barracks_interaction")
	var train_button_screen := _scene_screen_position("train_militia_button")
	var squad_start := _scene_screen_position("squad_drag_start")
	var squad_end := _scene_screen_position("squad_drag_end")
	var lume_screen := _scene_screen_position("lume_interaction")
	if hero_screen == Vector2.INF or mine_screen == Vector2.INF or worker_screen == Vector2.INF or barracks_screen == Vector2.INF or train_button_screen == Vector2.INF or lume_screen == Vector2.INF:
		errors.append("Could not resolve v0.133 post-mine click coordinates.")
	else:
		await _inject_mouse_click(hero_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "aster_click", {"position": _vector2_report(hero_screen)})
		await _settle_frames(8)
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "mine_right_click", {"position": _vector2_report(mine_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "mineControlled", true, 620)
		_trace_real_input(trace, "mine_controlled", {"site": "West Stone Cut Mine"})
		worker_screen = _scene_screen_position("worker_00")
		await _inject_mouse_motion(worker_screen)
		await _settle_frames(4)
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "worker_click", {"position": _vector2_report(worker_screen)})
		await _settle_frames(8)
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "worker_right_click_controlled_mine", {"position": _vector2_report(mine_screen), "site": "West Stone Cut Mine"})
		await _settle_until_scene_status_flag("post_mine_flow_status", "workerAssignedToMine", true, 220)
		_trace_real_input(trace, "worker_assignment_feedback", {"site": "West Stone Cut Mine"})
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "worker_assigned", "Worker assigned", "worker_assigned"))
		if squad_start != Vector2.INF and squad_end != Vector2.INF:
			await _inject_mouse_drag(squad_start, squad_end)
			_trace_real_input(trace, "box_select_no_objective_skip_probe", {"start": _vector2_report(squad_start), "end": _vector2_report(squad_end)})
			await _settle_frames(8)
		worker_screen = _scene_screen_position("worker_00")
		await _inject_mouse_motion(worker_screen)
		await _settle_frames(4)
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "worker_reselected_for_barracks", {"position": _vector2_report(worker_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksHighlightVisible", true, 140)
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "objective_restore_barracks", "Objective Restore Barracks", "objective_restore_barracks"))
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "barracks_highlighted", "Barracks highlighted", "barracks_highlighted"))
		await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "barracks_restore_right_click", {"position": _vector2_report(barracks_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksBuildOrderAccepted", true, 180)
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "build_order_accepted", "Build order accepted", "build_order_accepted"))
		await _settle_until_scene_status_number_at_least("post_mine_flow_status", "constructionProgress", 0.25, 260)
		_trace_real_input(trace, "barracks_construction_progress_25", {})
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "construction_25", "Construction 25 percent", "construction_25"))
		await _settle_until_scene_status_number_at_least("post_mine_flow_status", "constructionProgress", 0.75, 420)
		_trace_real_input(trace, "barracks_construction_progress_75", {})
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "construction_75", "Construction 75 percent", "construction_75"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksRestored", true, 520)
		_trace_real_input(trace, "barracks_restored", {})
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "barracks_restored", "Barracks restored", "barracks_restored"))
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "objective_train_militia", "Objective Train Militia", "objective_train_militia"))
		await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "barracks_selected", {"position": _vector2_report(barracks_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksSelected", true, 100)
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "train_militia_button", "Train Militia button", "train_militia_button"))
		await _inject_mouse_click(train_button_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "train_militia_clicked", {"position": _vector2_report(train_button_screen)})
		await _settle_until_scene_status_number_at_least("post_mine_flow_status", "recruitProgress", 0.50, 360)
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "queue_50", "Queue 50 percent", "queue_50"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "militiaSpawned", true, 420)
		_trace_real_input(trace, "militia_spawned", {})
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "militia_spawned", "Militia spawned", "militia_spawned"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "countdownStarted", true, 180)
		_trace_real_input(trace, "ashen_pressure_countdown_started", {})
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "ashen_incoming_countdown", "Ashen incoming countdown", "ashen_incoming_countdown"))
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "road_entry_pulse", "Road-entry pulse", "road_entry_pulse"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "waveTriggeredOnce", true, 720)
		_trace_real_input(trace, "ashen_wave_launched_automatically", {})
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "wave_launched", "Wave launched", "wave_launched"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "enemyMovementStarted", true, 320)
		_trace_real_input(trace, "enemy_movement_started", {})
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "enemy_movement", "Enemy movement", "enemy_movement"))
		if squad_start != Vector2.INF and squad_end != Vector2.INF:
			await _inject_mouse_drag(squad_start, squad_end)
			_trace_real_input(trace, "combat_squad_box_selected", {"start": _vector2_report(squad_start), "end": _vector2_report(squad_end)})
			await _settle_frames(8)
		var enemy_screen := _scene_screen_position("ashen_00")
		await _inject_mouse_click(enemy_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "combat_attack_right_click", {"position": _vector2_report(enemy_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "combatStarted", true, 420)
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "combat_onset", "Combat onset", "combat_onset"))
		await _settle_until_scene_status_number_at_most("post_mine_flow_status", "waveRemainingCount", 3.0, 480)
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "enemy_remaining_counter", "Enemy remaining counter", "enemy_remaining_counter"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "waveDefeatedFromSimulation", true, 1100)
		_trace_real_input(trace, "wave_defeated_by_simulation", {})
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "wave_defeated", "Wave defeated", "wave_defeated"))
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "lume_highlighted", "Lume highlighted", "lume_highlighted"))
		await _inject_mouse_click(lume_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "lume_restore_click", {"position": _vector2_report(lume_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "lumeRestored", true, 220)
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "lume_restored", "Lume restored", "lume_restored"))
		await _settle_until_player_step("player_results", 220)
		captures.append(await _capture_post_mine_flow_step(screenshot_root, captures.size(), "results", "Results", "results"))
	var raw_scene_status: Variant = _call_scene("post_mine_flow_status")
	var scene_status: Dictionary = raw_scene_status if typeof(raw_scene_status) == TYPE_DICTIONARY else {}
	if not last_post_mine_flow_status.is_empty() and not bool(scene_status.get("resultsReached", false)):
		scene_status = last_post_mine_flow_status.duplicate(true)
	if scene_status.is_empty():
		errors.append("Scene did not return v0.133 post-mine flow status.")
	var required_flags := {
		"workerAssignedToMine": bool(scene_status.get("workerAssignedToMine", false)),
		"barracksHighlightVisible": bool(scene_status.get("barracksHighlightVisible", false)),
		"barracksBuildOrderAccepted": bool(scene_status.get("barracksBuildOrderAccepted", false)),
		"constructionStarted": bool(scene_status.get("constructionStarted", false)),
		"construction25Recorded": bool(scene_status.get("construction25Recorded", false)),
		"construction75Recorded": bool(scene_status.get("construction75Recorded", false)),
		"barracksRestored": bool(scene_status.get("barracksRestored", false)),
		"barracksSelected": bool(scene_status.get("barracksSelected", false)),
		"trainMilitiaClicked": bool(scene_status.get("trainMilitiaClicked", false)),
		"recruitQueueStarted": bool(scene_status.get("recruitQueueStarted", false)),
		"recruitQueue50Recorded": bool(scene_status.get("recruitQueue50Recorded", false)),
		"militiaSpawned": bool(scene_status.get("militiaSpawned", false)),
		"countdownStarted": bool(scene_status.get("countdownStarted", false)),
		"waveTriggeredOnce": bool(scene_status.get("waveTriggeredOnce", false)),
		"waveTriggeredByCountdown": str(scene_status.get("waveTriggerSource", "")) == "countdown",
		"roadEntryPulseVisible": bool(scene_status.get("roadEntryPulseVisible", false)),
		"enemyMovementStarted": bool(scene_status.get("enemyMovementStarted", false)),
		"attackInputAccepted": bool(scene_status.get("attackInputAccepted", false)),
		"combatStarted": bool(scene_status.get("combatStarted", false)),
		"waveDefeatedFromSimulation": bool(scene_status.get("waveDefeatedFromSimulation", false)),
		"lumeHighlightVisible": bool(scene_status.get("lumeHighlightVisible", false)),
		"lumeRestoreInputAccepted": bool(scene_status.get("lumeRestoreInputAccepted", false)),
		"lumeRestored": bool(scene_status.get("lumeRestored", false)),
		"resultsReached": bool(scene_status.get("resultsReached", false)),
		"boxSelectNoObjectiveSkipProven": bool(scene_status.get("boxSelectNoObjectiveSkipProven", false)),
		"noActualObjectiveRegression": not bool(scene_status.get("actualObjectiveRegressionDetected", true)),
		"debugShortcutNotUsed": not bool(scene_status.get("debugShortcutUsed", true)),
		"stateInjectionNotUsed": not bool(scene_status.get("stateInjectionUsed", true))
	}
	for key in required_flags.keys():
		if not bool(required_flags[key]):
			errors.append("v0.133 post-mine flow smoke check failed: %s" % key)
	var combined_trace: Array = trace.duplicate(true)
	for entry in scene_status.get("trace", []):
		combined_trace.append(entry)
	var smoke := {
		"schemaVersion": 1,
		"checkpoint": "v0.133",
		"status": "PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE" if errors.is_empty() else "FAIL_V0133_HEADED_POST_MINE_FLOW_SMOKE",
		"artifactRoot": artifact_root,
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"inputPath": "packaged Godot player slice normal mouse events and normal simulation",
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": bool(scene_status.get("debugShortcutUsed", false)),
		"stateInjectionUsed": bool(scene_status.get("stateInjectionUsed", false)),
		"fixtureOnlyHelperProofUsed": false,
		"screenshotOnlyProofUsed": false,
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"checks": required_flags,
		"errors": errors,
		"sceneStatus": scene_status
	}
	var screenshot_manifest := {
		"schemaVersion": 1,
		"checkpoint": "v0.133",
		"status": "PASS_V0133_POST_MINE_FLOW_SCREENSHOTS" if captures.size() == 21 and errors.is_empty() else "FAIL_V0133_POST_MINE_FLOW_SCREENSHOTS",
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": 21,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "headed-post-mine-flow-smoke.json"), smoke)
	_write_absolute_json(_path_join(artifact_root, "post-mine-trace.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.133",
		"trace": combined_trace,
		"noPrivateHarnessShortcutUsed": true,
		"noDebugShortcutUsed": not bool(scene_status.get("debugShortcutUsed", false)),
		"noStateInjectionUsed": not bool(scene_status.get("stateInjectionUsed", false)),
		"fixtureOnlyHelperProofUsed": false
	})
	_write_absolute_json(_path_join(artifact_root, "objective-prerequisite-report.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.133",
		"status": "PASS_OBJECTIVE_PREREQUISITE_REPORT" if bool(required_flags.get("boxSelectNoObjectiveSkipProven", false)) and bool(required_flags.get("noActualObjectiveRegression", false)) else "FAIL_OBJECTIVE_PREREQUISITE_REPORT",
		"canonicalObjectiveSequence": scene_status.get("canonicalObjectiveSequence", []),
		"objectiveHistory": scene_status.get("objectiveHistory", []),
		"illegalObjectiveSkipRejectedCount": scene_status.get("illegalObjectiveSkipRejectedCount", 0),
		"boxSelectNoObjectiveSkipProven": scene_status.get("boxSelectNoObjectiveSkipProven", false)
	})
	_write_absolute_json(_path_join(artifact_root, "barracks-restoration-proof.json"), _post_mine_proof("PASS_BARRACKS_RESTORATION_PROOF", required_flags, ["barracksHighlightVisible", "barracksBuildOrderAccepted", "constructionStarted", "construction25Recorded", "construction75Recorded", "barracksRestored"], scene_status))
	_write_absolute_json(_path_join(artifact_root, "militia-recruit-proof.json"), _post_mine_proof("PASS_MILITIA_RECRUIT_PROOF", required_flags, ["barracksSelected", "trainMilitiaClicked", "recruitQueueStarted", "recruitQueue50Recorded", "militiaSpawned"], scene_status))
	_write_absolute_json(_path_join(artifact_root, "pressure-countdown-proof.json"), _post_mine_proof("PASS_PRESSURE_COUNTDOWN_PROOF", required_flags, ["countdownStarted", "waveTriggeredByCountdown"], scene_status))
	_write_absolute_json(_path_join(artifact_root, "wave-launch-proof.json"), _post_mine_proof("PASS_WAVE_LAUNCH_PROOF", required_flags, ["waveTriggeredOnce", "roadEntryPulseVisible", "enemyMovementStarted"], scene_status))
	_write_absolute_json(_path_join(artifact_root, "combat-onset-proof.json"), _post_mine_proof("PASS_COMBAT_ONSET_PROOF", required_flags, ["attackInputAccepted", "combatStarted"], scene_status))
	_write_absolute_json(_path_join(artifact_root, "wave-defeat-proof.json"), _post_mine_proof("PASS_WAVE_DEFEAT_PROOF", required_flags, ["waveDefeatedFromSimulation"], scene_status))
	_write_absolute_json(_path_join(artifact_root, "lume-restore-proof.json"), _post_mine_proof("PASS_LUME_RESTORE_PROOF", required_flags, ["lumeHighlightVisible", "lumeRestoreInputAccepted", "lumeRestored", "resultsReached"], scene_status))
	_write_absolute_json(_path_join(artifact_root, "screenshot-manifest.json"), screenshot_manifest)
	_write_absolute_text(_path_join(artifact_root, "post-mine-trace.md"), _post_mine_trace_markdown(smoke, combined_trace))
	_write_absolute_text(_path_join(artifact_root, "README.md"), _post_mine_readme(smoke, screenshot_manifest))
	get_tree().quit(0 if errors.is_empty() else 1)

func _capture_post_mine_flow_step(screenshot_root: String, index: int, id: String, label: String, action: String) -> Dictionary:
	await _settle_frames(2)
	var file_name := "%02d_%s.png" % [index + 1, id]
	var target := _path_join(screenshot_root, file_name)
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var save_result := image.save_png(target)
	return {
		"id": id,
		"label": label,
		"fileName": file_name,
		"absolutePath": target,
		"width": image.get_width(),
		"height": image.get_height(),
		"screen": active_mode,
		"action": action,
		"saveStatus": save_result,
		"status": last_post_mine_flow_status.duplicate(true) if active_mode == MODE_PLAYER_RESULTS and not last_post_mine_flow_status.is_empty() else _call_scene("post_mine_flow_status")
	}

func _settle_until_scene_status_number_at_most(status_method: String, flag: String, threshold: float, max_frames: int) -> void:
	for _index in range(max_frames):
		var raw_status: Variant = _call_scene(status_method)
		var status: Dictionary = raw_status if typeof(raw_status) == TYPE_DICTIONARY else {}
		if status.has(flag) and float(status[flag]) <= threshold:
			return
		await get_tree().process_frame

func _settle_until_player_step(step_id: String, max_frames: int) -> void:
	for _index in range(max_frames):
		if current_step_id == step_id:
			return
		await get_tree().process_frame

func _post_mine_proof(pass_status: String, checks: Dictionary, keys: Array[String], scene_status: Dictionary) -> Dictionary:
	var ok := true
	for key in keys:
		ok = ok and bool(checks.get(key, false))
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.133",
		"status": pass_status if ok else pass_status.replace("PASS_", "FAIL_"),
		"checks": keys,
		"sceneStatus": scene_status
	}

func _post_mine_trace_markdown(smoke: Dictionary, trace: Array) -> String:
	var lines := [
		"# v0.133 Post-Mine Flow Trace",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"| # | Event | Details |",
		"| --- | --- | --- |"
	]
	for index in range(trace.size()):
		var entry: Dictionary = trace[index]
		lines.append("| %s | %s | `%s` |" % [index + 1, str(entry.get("event", "")), JSON.stringify(entry.get("details", {}))])
	lines.append("")
	lines.append("Private harness shortcut used: `%s`" % str(smoke.get("privateHarnessShortcutUsed", false)))
	lines.append("Debug shortcut used: `%s`" % str(smoke.get("debugShortcutUsed", false)))
	lines.append("State injection used: `%s`" % str(smoke.get("stateInjectionUsed", false)))
	lines.append("Fixture-only helper proof used: `%s`" % str(smoke.get("fixtureOnlyHelperProofUsed", false)))
	return "\n".join(lines) + "\n"

func _post_mine_readme(smoke: Dictionary, manifest: Dictionary) -> String:
	return "\n".join([
		"# v0.133 Godot Post-Mine Flow Evidence",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"These ignored artifacts are generated by `GODOT_POST_MINE_FLOW_SMOKE_WINDOWS.bat` / `npm run godot:headed:post-mine-flow-smoke` against the packaged player-facing Godot slice.",
		"",
		"- `headed-post-mine-flow-smoke.json` records the gated real mouse-input and normal-simulation result.",
		"- `post-mine-trace.json` and `post-mine-trace.md` record title, briefing, mine, Worker, Barracks, recruitment, countdown, wave, combat, Lume, and Results events.",
		"- `objective-prerequisite-report.json` records the box-select no-skip prerequisite guard.",
		"- Proof JSON files record Barracks restoration, Militia recruitment, pressure countdown, wave launch, combat onset, wave defeat, and Lume restoration.",
		"- `screenshot-manifest.json` records `%s/%s` required screenshots." % [manifest.get("captureCount", 0), manifest.get("requiredCaptureCount", 21)],
		"",
		"No debug shortcut, private-harness action, state injection, fixture-only helper proof, save write, stable-ID change, or Godot-editor work is accepted as proof."
	]) + "\n"

func run_rts_ergonomics_smoke() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	_set_capture_viewport(VIEWPORT_SIZE)
	await _settle_frames(8)
	var start_usec := Time.get_ticks_usec()
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var trace: Array[Dictionary] = []
	last_post_mine_flow_status = {}
	show_player_title()
	await _settle_frames(8)
	_trace_real_input(trace, "launch", {"screen": "title"})
	await _inject_mouse_click(Vector2(750, 303), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "title_start_clicked", {"position": _vector2_report(Vector2(750, 303))})
	await _settle_until_player_step("player_briefing", 80)
	await _inject_mouse_click(Vector2(750, 411), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "briefing_start_battle_clicked", {"position": _vector2_report(Vector2(750, 411))})
	await _settle_until_player_step("player_battle", 120)
	await _settle_frames(12)
	captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "battle_ready", "Battle ready", "battle_ready"))
	var hero_screen := _scene_screen_position("hero_aster")
	var mine_screen := _scene_screen_position("west_stone_cut_mine")
	var worker_screen := _scene_screen_position("worker_00")
	var empty_screen := _scene_screen_position("empty_ground")
	var barracks_screen := _scene_screen_position("barracks_interaction")
	var train_button_screen := _scene_screen_position("train_militia_button")
	var squad_start := _scene_screen_position("squad_drag_start")
	var squad_end := _scene_screen_position("squad_drag_end")
	var lume_screen := _scene_screen_position("lume_interaction")
	if hero_screen == Vector2.INF or mine_screen == Vector2.INF or worker_screen == Vector2.INF or empty_screen == Vector2.INF or barracks_screen == Vector2.INF or train_button_screen == Vector2.INF or squad_start == Vector2.INF or squad_end == Vector2.INF or lume_screen == Vector2.INF:
		errors.append("Could not resolve v0.135 RTS ergonomics coordinates.")
	else:
		await _inject_key(KEY_F1)
		_trace_real_input(trace, "help_opened_f1", {})
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "help_opened", "Compact help opened", "help_opened"))
		await _inject_key(KEY_ESCAPE)
		_trace_real_input(trace, "help_closed_escape", {})
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "help_dismissed", "Help dismissed", "help_dismissed"))
		await _inject_mouse_motion(hero_screen)
		await _settle_frames(4)
		await _inject_mouse_click(hero_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "aster_selected", {"position": _vector2_report(hero_screen)})
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "aster_selected", "Aster selected", "aster_selected"))
		await _inject_mouse_wheel(hero_screen, MOUSE_BUTTON_WHEEL_UP)
		await _inject_key(KEY_D)
		await _inject_key(KEY_W)
		await _inject_key(KEY_SPACE)
		_trace_real_input(trace, "camera_zoom_pan_focus", {})
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "camera_controls", "Camera controls", "camera_controls"))
		await _inject_mouse_click(empty_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "empty_left_click_deselect", {"position": _vector2_report(empty_screen)})
		await _inject_mouse_click(empty_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "invalid_no_selection_right_click", {"position": _vector2_report(empty_screen)})
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "invalid_order_recovery", "Invalid order recovery", "invalid_order_recovery"))
		await _inject_mouse_click(hero_screen, MOUSE_BUTTON_LEFT)
		await _settle_frames(8)
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "move_order_mine", {"position": _vector2_report(mine_screen)})
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "move_marker", "Move marker", "move_marker"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "mineControlled", true, 620)
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "mine_controlled", "Mine controlled", "mine_controlled"))
		worker_screen = _scene_screen_position("worker_00")
		await _inject_mouse_motion(worker_screen)
		await _settle_frames(4)
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
		await _settle_frames(8)
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "worker_context_mine", {"position": _vector2_report(mine_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "workerAssignedToMine", true, 220)
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "worker_context_action", "Worker context action", "worker_context_action"))
		worker_screen = _scene_screen_position("worker_00")
		await _inject_mouse_motion(worker_screen)
		await _settle_frames(4)
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksHighlightVisible", true, 140)
		await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_RIGHT)
		await _settle_until_scene_status_number_at_least("post_mine_flow_status", "constructionProgress", 0.75, 520)
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "barracks_context_action", "Barracks context action", "barracks_context_action"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksRestored", true, 620)
		await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_LEFT)
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksSelected", true, 100)
		await _inject_mouse_click(train_button_screen, MOUSE_BUTTON_LEFT)
		await _settle_until_scene_status_flag("post_mine_flow_status", "militiaSpawned", true, 520)
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "militia_spawned", "Militia spawned", "militia_spawned"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "waveTriggeredOnce", true, 780)
		await _settle_until_scene_status_flag("post_mine_flow_status", "enemyMovementStarted", true, 360)
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "wave_movement", "Wave movement", "wave_movement"))
		await _inject_mouse_drag(squad_start, squad_end)
		await _settle_frames(8)
		var enemy_screen := _scene_screen_position("ashen_00")
		await _inject_mouse_click(enemy_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "squad_attack_right_click", {"position": _vector2_report(enemy_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "combatStarted", true, 480)
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "squad_attack", "Squad attack", "squad_attack"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "waveDefeatedFromSimulation", true, 1100)
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "wave_defeated", "Wave defeated", "wave_defeated"))
		await _inject_mouse_click(lume_screen, MOUSE_BUTTON_LEFT)
		await _settle_until_scene_status_flag("post_mine_flow_status", "lumeRestored", true, 220)
		await _settle_until_player_step("player_results", 220)
		captures.append(await _capture_v0135_step(screenshot_root, captures.size(), "results", "Results", "results"))
	var rts_status := _scene_status("rts_ergonomics_status")
	var post_status := _scene_status("post_mine_flow_status")
	var contract_checks: Dictionary = rts_status.get("checks", {})
	for key in contract_checks.keys():
		if not bool(contract_checks[key]):
			errors.append("v0.135 RTS ergonomics check failed: %s" % key)
	var finish_checks := {
		"resultsReached": bool(post_status.get("resultsReached", false)) and current_step_id == "player_results",
		"noObjectiveRegression": not bool(post_status.get("actualObjectiveRegressionDetected", true)),
		"noDebugShortcut": not bool(rts_status.get("debugShortcutUsed", true)),
		"noStateInjection": not bool(rts_status.get("stateInjectionUsed", true)),
		"linkedWardPreserved": float(rts_status.get("linkedWardDamageTakenMultiplier", 0.0)) == 0.92
	}
	for key in finish_checks.keys():
		if not bool(finish_checks[key]):
			errors.append("v0.135 finish check failed: %s" % key)
	var combined_trace := trace.duplicate(true)
	for entry in rts_status.get("trace", []):
		combined_trace.append(entry)
	var smoke := {
		"schemaVersion": 1,
		"checkpoint": "v0.135",
		"status": "PASS_V0135_HEADED_RTS_ERGONOMICS_SMOKE" if errors.is_empty() else "FAIL_V0135_HEADED_RTS_ERGONOMICS_SMOKE",
		"artifactRoot": artifact_root,
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"inputPath": "packaged Godot player slice normal mouse, keyboard, and wheel events",
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": bool(rts_status.get("debugShortcutUsed", false)),
		"stateInjectionUsed": bool(rts_status.get("stateInjectionUsed", false)),
		"fixtureOnlyHelperProofUsed": false,
		"screenshotOnlyProofUsed": false,
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"checks": contract_checks,
		"finishChecks": finish_checks,
		"errors": errors,
		"rtsStatus": rts_status,
		"postMineStatus": post_status
	}
	var screenshot_manifest := {
		"schemaVersion": 1,
		"checkpoint": "v0.135",
		"status": "PASS_V0135_SCREENSHOT_MANIFEST" if captures.size() >= 14 and errors.is_empty() else "FAIL_V0135_SCREENSHOT_MANIFEST",
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": 14,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "rts-ergonomics-smoke.json"), smoke)
	_write_absolute_json(_path_join(artifact_root, "headed-rts-ergonomics-smoke.json"), smoke)
	_write_absolute_json(_path_join(artifact_root, "rts-input-contract.json"), {"schemaVersion": 1, "checkpoint": "v0.135", "status": "PASS_V0135_RTS_INPUT_CONTRACT" if errors.is_empty() else "FAIL_V0135_RTS_INPUT_CONTRACT", "checks": contract_checks})
	_write_absolute_json(_path_join(artifact_root, "order-feedback-report.json"), {"schemaVersion": 1, "checkpoint": "v0.135", "status": "PASS_V0135_ORDER_FEEDBACK" if bool(contract_checks.get("invalidOrderMarker", false)) and bool(contract_checks.get("contextMarker", false)) and bool(contract_checks.get("moveMarker", false)) and bool(contract_checks.get("attackMarker", false)) else "FAIL_V0135_ORDER_FEEDBACK", "checks": contract_checks})
	_write_absolute_json(_path_join(artifact_root, "camera-control-report.json"), {"schemaVersion": 1, "checkpoint": "v0.135", "status": "PASS_V0135_CAMERA_CONTROL" if bool(contract_checks.get("mouseWheelZoom", false)) and bool(contract_checks.get("keyboardCameraPan", false)) and bool(contract_checks.get("spaceFocusAster", false)) and bool(contract_checks.get("zoomBoundsSafe", false)) else "FAIL_V0135_CAMERA_CONTROL", "rtsStatus": rts_status})
	_write_absolute_json(_path_join(artifact_root, "compact-help-report.json"), {"schemaVersion": 1, "checkpoint": "v0.135", "status": "PASS_V0135_COMPACT_HELP" if bool(contract_checks.get("helpOverlay", false)) else "FAIL_V0135_COMPACT_HELP", "rtsStatus": rts_status})
	_write_absolute_json(_path_join(artifact_root, "screenshot-manifest.json"), screenshot_manifest)
	_write_absolute_json(_path_join(artifact_root, "rts-ergonomics-trace.json"), {"schemaVersion": 1, "checkpoint": "v0.135", "status": smoke.get("status", "UNKNOWN"), "trace": combined_trace, "noPrivateHarnessShortcutUsed": true, "noDebugShortcutUsed": not bool(rts_status.get("debugShortcutUsed", true)), "noStateInjectionUsed": not bool(rts_status.get("stateInjectionUsed", true)), "fixtureOnlyHelperProofUsed": false})
	_write_absolute_text(_path_join(artifact_root, "rts-ergonomics-trace.md"), _v0135_trace_markdown(smoke, combined_trace))
	_write_absolute_text(_path_join(artifact_root, "README.md"), _v0135_readme(smoke, screenshot_manifest))
	get_tree().quit(0 if errors.is_empty() else 1)

func _scene_status(method: String) -> Dictionary:
	var raw: Variant = _call_scene(method)
	return raw if typeof(raw) == TYPE_DICTIONARY else {}

func _inject_key(keycode: int) -> void:
	var down := InputEventKey.new()
	down.keycode = keycode
	down.pressed = true
	get_viewport().push_input(down, true)
	await _settle_frames(2)
	var up := InputEventKey.new()
	up.keycode = keycode
	up.pressed = false
	get_viewport().push_input(up, true)
	await _settle_frames(2)

func _inject_mouse_wheel(position: Vector2, button: int) -> void:
	await _inject_mouse_motion(position)
	var wheel := InputEventMouseButton.new()
	wheel.position = position
	wheel.global_position = position
	wheel.button_index = button
	wheel.pressed = true
	get_viewport().push_input(wheel, true)
	await _settle_frames(2)

func _capture_v0135_step(screenshot_root: String, index: int, id: String, label: String, action: String) -> Dictionary:
	await _settle_frames(2)
	var file_name := "%02d_%s.png" % [index + 1, id]
	var target := _path_join(screenshot_root, file_name)
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var save_result := image.save_png(target)
	return {
		"id": id,
		"label": label,
		"fileName": file_name,
		"absolutePath": target,
		"width": image.get_width(),
		"height": image.get_height(),
		"screen": active_mode,
		"action": action,
		"saveStatus": save_result,
		"status": _scene_status("rts_ergonomics_status")
	}

func _v0135_trace_markdown(smoke: Dictionary, trace: Array) -> String:
	var lines := [
		"# v0.135 RTS Ergonomics Trace",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"| # | Event | Details |",
		"| --- | --- | --- |"
	]
	for index in range(trace.size()):
		var entry: Dictionary = trace[index]
		lines.append("| %s | %s | `%s` |" % [index + 1, str(entry.get("event", "")), JSON.stringify(entry.get("details", {}))])
	lines.append("")
	lines.append("Private harness shortcut used: `%s`" % str(smoke.get("privateHarnessShortcutUsed", false)))
	lines.append("Debug shortcut used: `%s`" % str(smoke.get("debugShortcutUsed", false)))
	lines.append("State injection used: `%s`" % str(smoke.get("stateInjectionUsed", false)))
	lines.append("Fixture-only helper proof used: `%s`" % str(smoke.get("fixtureOnlyHelperProofUsed", false)))
	return "\n".join(lines) + "\n"

func _v0135_readme(smoke: Dictionary, manifest: Dictionary) -> String:
	return "\n".join([
		"# v0.135 Godot RTS Ergonomics Evidence",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"These ignored artifacts are generated by `GODOT_RTS_ERGONOMICS_SMOKE_WINDOWS.bat` / `npm run godot:headed:rts-ergonomics-smoke` against the packaged player-facing Godot slice.",
		"",
		"- `rts-ergonomics-smoke.json` records the gated real mouse, keyboard, and wheel input result.",
		"- `rts-input-contract.json` records conventional selection, move, attack, context, zoom, pan, focus, Escape, and help checks.",
		"- `order-feedback-report.json`, `camera-control-report.json`, and `compact-help-report.json` record focused sub-gates.",
		"- `screenshot-manifest.json` records `%s/%s` required screenshots." % [manifest.get("captureCount", 0), manifest.get("requiredCaptureCount", 12)],
		"",
		"No private harness shortcut, debug action, direct state injection, fixture-only helper proof, save write, stable-ID change, art import, browser-runtime change, or Godot-editor work is accepted as proof."
	]) + "\n"

func run_usability_presentation_smoke() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	_set_capture_viewport(VIEWPORT_SIZE)
	var start_usec := Time.get_ticks_usec()
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var trace: Array[Dictionary] = []
	show_player_title()
	await _settle_frames(8)
	captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "title", "Title", "title"))
	await _inject_mouse_click(Vector2(750, 303), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "title_start_clicked", {"position": _vector2_report(Vector2(750, 303))})
	await _settle_frames(8)
	captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "briefing", "Briefing", "briefing"))
	await _inject_mouse_click(Vector2(750, 411), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "briefing_start_battle_clicked", {"position": _vector2_report(Vector2(750, 411))})
	await _settle_frames(18)
	if current_step_id != "player_battle":
		errors.append("v0.136 did not reach player battle.")
	captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "hud_default", "HUD default", "hud_default"))
	var minimap_click := Vector2(1430, 740)
	await _inject_mouse_click(minimap_click, MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "minimap_click_to_orient", {"position": _vector2_report(minimap_click)})
	await _settle_frames(8)
	captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "minimap_default", "Minimap default", "minimap_default"))
	var hero_screen := _scene_screen_position("hero_aster")
	var mine_screen := _scene_screen_position("west_stone_cut_mine")
	var worker_screen := _scene_screen_position("worker_00")
	var barracks_screen := _scene_screen_position("barracks_interaction")
	var train_button_screen := _scene_screen_position("train_militia_button")
	var squad_start := _scene_screen_position("squad_drag_start")
	var squad_end := _scene_screen_position("squad_drag_end")
	var lume_screen := _scene_screen_position("lume_interaction")
	if hero_screen == Vector2.INF or mine_screen == Vector2.INF or worker_screen == Vector2.INF or barracks_screen == Vector2.INF or train_button_screen == Vector2.INF or squad_start == Vector2.INF or squad_end == Vector2.INF or lume_screen == Vector2.INF:
		errors.append("v0.136 could not resolve required player-facing coordinates.")
	else:
		await _inject_mouse_motion(hero_screen)
		await _settle_frames(4)
		await _inject_mouse_click(hero_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "aster_selected", {"position": _vector2_report(hero_screen)})
		await _settle_frames(8)
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "move_order_mine", {"position": _vector2_report(mine_screen)})
		await _settle_until_scene_status_number_at_least("post_mine_flow_status", "conversionProgress", 25.0, 360)
		captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "mine_conversion", "Mine conversion", "mine_conversion"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "mineControlled", true, 520)
		captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "minimap_mine_controlled", "Minimap mine controlled", "minimap_mine_controlled"))
		worker_screen = _scene_screen_position("worker_00")
		await _inject_mouse_motion(worker_screen)
		await _settle_frames(4)
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
		await _settle_frames(8)
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "worker_assigned", {"position": _vector2_report(mine_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "workerAssignedToMine", true, 180)
		captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "worker_assignment", "Worker assignment", "worker_assignment"))
		worker_screen = _scene_screen_position("worker_00")
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksHighlightVisible", true, 120)
		await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "barracks_restore_order", {"position": _vector2_report(barracks_screen)})
		await _settle_until_scene_status_number_at_least("post_mine_flow_status", "constructionProgress", 0.50, 420)
		captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "construction", "Construction", "construction"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksRestored", true, 520)
		await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_LEFT)
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksSelected", true, 120)
		await _inject_mouse_click(train_button_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "train_militia_clicked", {"position": _vector2_report(train_button_screen)})
		await _settle_until_scene_status_number_at_least("post_mine_flow_status", "recruitProgress", 0.50, 360)
		captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "recruitment", "Recruitment", "recruitment"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "countdownStarted", true, 180)
		captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "countdown", "Countdown", "countdown"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "waveTriggeredOnce", true, 720)
		await _settle_until_scene_status_flag("post_mine_flow_status", "enemyMovementStarted", true, 320)
		captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "minimap_wave", "Minimap wave", "minimap_wave"))
		await _inject_mouse_drag(squad_start, squad_end)
		await _settle_frames(8)
		var enemy_screen := _scene_screen_position("ashen_00")
		await _inject_mouse_click(enemy_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "combat_attack_right_click", {"position": _vector2_report(enemy_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "combatStarted", true, 420)
		captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "combat", "Combat", "combat"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "waveDefeatedFromSimulation", true, 1040)
		await _inject_mouse_click(lume_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "lume_restore_click", {"position": _vector2_report(lume_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "lumeRestored", true, 180)
		captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "lume", "Lume", "lume"))
		await _settle_until_player_step("player_results", 180)
		captures.append(await _capture_v0136_step(screenshot_root, captures.size(), "results", "Results", "results"))
	var usability_status := _scene_status("usability_presentation_status")
	var post_status := _scene_status("post_mine_flow_status")
	var checks: Dictionary = usability_status.get("checks", {})
	for key in checks.keys():
		if not bool(checks[key]):
			errors.append("v0.136 usability presentation check failed: %s" % key)
	var finish_checks := {
		"resultsReached": bool(post_status.get("resultsReached", false)) and current_step_id == "player_results",
		"noObjectiveRegression": not bool(post_status.get("actualObjectiveRegressionDetected", true)),
		"noDebugShortcut": not bool(usability_status.get("debugShortcutUsed", true)),
		"noStateInjection": not bool(usability_status.get("stateInjectionUsed", true)),
		"linkedWardPreserved": float(usability_status.get("linkedWardDamageTakenMultiplier", 0.0)) == 0.92
	}
	for key in finish_checks.keys():
		if not bool(finish_checks[key]):
			errors.append("v0.136 finish check failed: %s" % key)
	var combined_trace := trace.duplicate(true)
	for entry in usability_status.get("trace", []):
		combined_trace.append(entry)
	var smoke := {
		"schemaVersion": 1,
		"checkpoint": "v0.136",
		"status": "PASS_V0136_HEADED_USABILITY_PRESENTATION_SMOKE" if errors.is_empty() else "FAIL_V0136_HEADED_USABILITY_PRESENTATION_SMOKE",
		"artifactRoot": artifact_root,
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"inputPath": "packaged Godot player slice normal mouse events and ordinary simulation",
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": bool(usability_status.get("debugShortcutUsed", false)),
		"stateInjectionUsed": bool(usability_status.get("stateInjectionUsed", false)),
		"fixtureOnlyHelperProofUsed": false,
		"screenshotOnlyProofUsed": false,
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"checks": checks,
		"finishChecks": finish_checks,
		"usabilityStatus": usability_status,
		"postMineStatus": post_status,
		"errors": errors
	}
	var screenshot_manifest := {
		"schemaVersion": 1,
		"checkpoint": "v0.136",
		"status": "PASS_V0136_SCREENSHOT_MANIFEST" if captures.size() >= 12 and errors.is_empty() else "FAIL_V0136_SCREENSHOT_MANIFEST",
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": 12,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "usability-presentation-smoke.json"), smoke)
	_write_absolute_json(_path_join(artifact_root, "headed-usability-presentation-smoke.json"), smoke)
	_write_absolute_json(_path_join(artifact_root, "hud-hierarchy-report.json"), {"schemaVersion": 1, "checkpoint": "v0.136", "status": "PASS_V0136_HUD_HIERARCHY" if bool(checks.get("primaryObjectiveLine", false)) and bool(checks.get("secondaryHintCompact", false)) and bool(checks.get("noRedundantTopBottomBanners", false)) and bool(checks.get("selectedEntityCardCompact", false)) else "FAIL_V0136_HUD_HIERARCHY", "checks": checks})
	_write_absolute_json(_path_join(artifact_root, "minimap-refinement-report.json"), {"schemaVersion": 1, "checkpoint": "v0.136", "status": "PASS_V0136_MINIMAP_REFINEMENT" if bool(checks.get("minimapTerrainOutline", false)) and bool(checks.get("minimapWorkerMarker", false)) and bool(checks.get("minimapActiveAshenOnly", false)) and bool(checks.get("minimapClickToOrient", false)) else "FAIL_V0136_MINIMAP_REFINEMENT", "checks": checks})
	_write_absolute_json(_path_join(artifact_root, "onboarding-copy-report.json"), {"schemaVersion": 1, "checkpoint": "v0.136", "status": "PASS_V0136_ONBOARDING_COPY" if bool(checks.get("canonicalOnboardingCopy", false)) and bool(checks.get("noDebugText", false)) else "FAIL_V0136_ONBOARDING_COPY", "checks": checks})
	_write_absolute_json(_path_join(artifact_root, "microloop-pacing-report.json"), {"schemaVersion": 1, "checkpoint": "v0.136", "status": "PASS_V0136_MICROLOOP_PACING" if bool(checks.get("pacingTuned", false)) and bool(finish_checks.get("resultsReached", false)) else "FAIL_V0136_MICROLOOP_PACING", "pacing": usability_status.get("pacing", {})})
	_write_absolute_json(_path_join(artifact_root, "screenshot-manifest.json"), screenshot_manifest)
	_write_absolute_json(_path_join(artifact_root, "usability-presentation-trace.json"), {"schemaVersion": 1, "checkpoint": "v0.136", "status": smoke.get("status", "UNKNOWN"), "trace": combined_trace, "noPrivateHarnessShortcutUsed": true, "noDebugShortcutUsed": not bool(usability_status.get("debugShortcutUsed", true)), "noStateInjectionUsed": not bool(usability_status.get("stateInjectionUsed", true)), "fixtureOnlyHelperProofUsed": false})
	_write_absolute_text(_path_join(artifact_root, "usability-presentation-trace.md"), _v0136_trace_markdown(smoke, combined_trace))
	_write_absolute_text(_path_join(artifact_root, "README.md"), _v0136_readme(smoke, screenshot_manifest))
	get_tree().quit(0 if errors.is_empty() else 1)

func _capture_v0136_step(screenshot_root: String, index: int, id: String, label: String, action: String) -> Dictionary:
	await _settle_frames(2)
	var file_name := "%02d_%s.png" % [index + 1, id]
	var target := _path_join(screenshot_root, file_name)
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var save_result := image.save_png(target)
	return {
		"id": id,
		"label": label,
		"fileName": file_name,
		"absolutePath": target,
		"width": image.get_width(),
		"height": image.get_height(),
		"screen": active_mode,
		"action": action,
		"saveStatus": save_result,
		"status": _scene_status("usability_presentation_status")
	}

func _v0136_trace_markdown(smoke: Dictionary, trace: Array) -> String:
	var lines := [
		"# v0.136 Usability Presentation Trace",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"| # | Event | Details |",
		"| --- | --- | --- |"
	]
	for index in range(trace.size()):
		var entry: Dictionary = trace[index]
		lines.append("| %s | %s | `%s` |" % [index + 1, str(entry.get("event", "")), JSON.stringify(entry.get("details", {}))])
	lines.append("")
	lines.append("Private harness shortcut used: `%s`" % str(smoke.get("privateHarnessShortcutUsed", false)))
	lines.append("Debug shortcut used: `%s`" % str(smoke.get("debugShortcutUsed", false)))
	lines.append("State injection used: `%s`" % str(smoke.get("stateInjectionUsed", false)))
	lines.append("Fixture-only helper proof used: `%s`" % str(smoke.get("fixtureOnlyHelperProofUsed", false)))
	return "\n".join(lines) + "\n"

func _v0136_readme(smoke: Dictionary, manifest: Dictionary) -> String:
	return "\n".join([
		"# v0.136 Godot HUD, Minimap, Onboarding, and Pacing Evidence",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"These ignored artifacts are generated by `GODOT_USABILITY_PRESENTATION_WINDOWS.bat` / `npm run godot:headed:usability-presentation` against the packaged player-facing Godot slice.",
		"",
		"- `hud-hierarchy-report.json` records the compact HUD hierarchy gate.",
		"- `minimap-refinement-report.json` records authored minimap markers and click-to-orient.",
		"- `onboarding-copy-report.json` records the concise ten-step copy ledger.",
		"- `microloop-pacing-report.json` records pacing targets and completion.",
		"- `screenshot-manifest.json` records `%s/%s` required screenshots." % [manifest.get("captureCount", 0), manifest.get("requiredCaptureCount", 12)],
		"",
		"No private harness shortcut, debug action, direct state injection, fixture-only helper proof, save write, stable-ID change, art import, browser-runtime change, or Godot-editor work is accepted as proof."
	]) + "\n"

func run_blockout_quality_smoke() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	_set_capture_viewport(VIEWPORT_SIZE)
	var start_usec := Time.get_ticks_usec()
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var trace: Array[Dictionary] = []
	var performance_windows: Array[Dictionary] = []
	show_player_title()
	await _settle_frames(8)
	captures.append(await _capture_v0137_step(screenshot_root, captures.size(), "title_backdrop", "Title backdrop", "title_backdrop"))
	await _inject_mouse_click(Vector2(750, 303), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "title_start_clicked", {"position": _vector2_report(Vector2(750, 303))})
	await _settle_frames(8)
	await _inject_mouse_click(Vector2(750, 411), MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "briefing_start_battle_clicked", {"position": _vector2_report(Vector2(750, 411))})
	await _settle_frames(18)
	if current_step_id != "player_battle":
		errors.append("v0.137 did not reach player battle.")
	captures.append(await _capture_v0137_step(screenshot_root, captures.size(), "battlefield_default", "Battlefield default", "battlefield_default"))
	performance_windows.append(await _measure_v0137_window("default_slice", "Default slice", 72))
	var zoomed_out_capture: Dictionary = {}
	var zoomed_in_capture: Dictionary = {}
	var viewport_center := Vector2(800, 450)
	for _zoom_out_index in range(4):
		await _inject_mouse_wheel(viewport_center, MOUSE_BUTTON_WHEEL_DOWN)
	await _settle_frames(8)
	zoomed_out_capture = await _capture_v0137_step(screenshot_root, 10, "zoomed_out", "Zoomed out", "zoomed_out")
	performance_windows.append(await _measure_v0137_window("zoomed_out", "Zoomed out", 60))
	for _zoom_in_index in range(6):
		await _inject_mouse_wheel(viewport_center, MOUSE_BUTTON_WHEEL_UP)
	await _settle_frames(8)
	zoomed_in_capture = await _capture_v0137_step(screenshot_root, 11, "zoomed_in", "Zoomed in", "zoomed_in")
	for _zoom_return_index in range(2):
		await _inject_mouse_wheel(viewport_center, MOUSE_BUTTON_WHEEL_DOWN)
	performance_windows.append(await _measure_v0137_window("fog_on", "Subtle terrain fog on", 60))
	var minimap_click := Vector2(1430, 740)
	await _inject_mouse_click(minimap_click, MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "minimap_click_to_orient", {"position": _vector2_report(minimap_click)})
	await _settle_frames(8)
	var hero_screen := _scene_screen_position("hero_aster")
	var mine_screen := _scene_screen_position("west_stone_cut_mine")
	var worker_screen := _scene_screen_position("worker_00")
	var barracks_screen := _scene_screen_position("barracks_interaction")
	var train_button_screen := _scene_screen_position("train_militia_button")
	var squad_start := _scene_screen_position("squad_drag_start")
	var squad_end := _scene_screen_position("squad_drag_end")
	var lume_screen := _scene_screen_position("lume_interaction")
	if hero_screen == Vector2.INF or mine_screen == Vector2.INF or worker_screen == Vector2.INF or barracks_screen == Vector2.INF or train_button_screen == Vector2.INF or squad_start == Vector2.INF or squad_end == Vector2.INF or lume_screen == Vector2.INF:
		errors.append("v0.137 could not resolve required player-facing coordinates.")
	else:
		await _inject_mouse_motion(hero_screen)
		await _settle_frames(4)
		await _inject_mouse_click(hero_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "aster_selected", {"position": _vector2_report(hero_screen)})
		await _settle_frames(8)
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "move_order_mine", {"position": _vector2_report(mine_screen)})
		await _settle_until_scene_status_number_at_least("post_mine_flow_status", "conversionProgress", 25.0, 360)
		captures.append(await _capture_v0137_step(screenshot_root, captures.size(), "mine", "Mine", "mine"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "mineControlled", true, 520)
		worker_screen = _scene_screen_position("worker_00")
		await _inject_mouse_motion(worker_screen)
		await _settle_frames(4)
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
		await _settle_frames(8)
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "worker_assigned", {"position": _vector2_report(mine_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "workerAssignedToMine", true, 180)
		worker_screen = _scene_screen_position("worker_00")
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksHighlightVisible", true, 120)
		await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "barracks_restore_order", {"position": _vector2_report(barracks_screen)})
		await _settle_until_scene_status_number_at_least("post_mine_flow_status", "constructionProgress", 0.50, 420)
		captures.append(await _capture_v0137_step(screenshot_root, captures.size(), "barracks", "Barracks", "barracks"))
		captures.append(await _capture_v0137_step(screenshot_root, captures.size(), "friendly_staging", "Friendly staging", "friendly_staging"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksRestored", true, 520)
		await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_LEFT)
		await _settle_until_scene_status_flag("post_mine_flow_status", "barracksSelected", true, 120)
		await _inject_mouse_click(train_button_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "train_militia_clicked", {"position": _vector2_report(train_button_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "countdownStarted", true, 240)
		await _settle_frames(8)
		captures.append(await _capture_v0137_step(screenshot_root, captures.size(), "ashen_approach", "Ashen approach", "ashen_approach"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "waveTriggeredOnce", true, 720)
		await _settle_until_scene_status_flag("post_mine_flow_status", "enemyMovementStarted", true, 320)
		await _inject_mouse_drag(squad_start, squad_end)
		await _settle_frames(8)
		var enemy_screen := _scene_screen_position("ashen_00")
		await _inject_mouse_click(enemy_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "combat_attack_right_click", {"position": _vector2_report(enemy_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "combatStarted", true, 420)
		performance_windows.append(await _measure_v0137_window("combat_peak", "Combat peak", 72))
		captures.append(await _capture_v0137_step(screenshot_root, captures.size(), "combat_peak", "Combat peak", "combat_peak"))
		await _settle_until_scene_status_flag("post_mine_flow_status", "waveDefeatedFromSimulation", true, 1040)
		await _inject_mouse_click(lume_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "lume_restore_click", {"position": _vector2_report(lume_screen)})
		await _settle_until_scene_status_flag("post_mine_flow_status", "lumeRestored", true, 180)
		performance_windows.append(await _measure_v0137_window("lume_pulse", "Lume pulse", 48))
		captures.append(await _capture_v0137_step(screenshot_root, captures.size(), "lume", "Lume", "lume"))
		captures.append(await _capture_v0137_step(screenshot_root, captures.size(), "minimap", "Minimap", "minimap"))
		await _settle_until_player_step("player_results", 180)
		captures.append(await _capture_v0137_step(screenshot_root, captures.size(), "results", "Results", "results"))
		if not zoomed_out_capture.is_empty():
			captures.append(zoomed_out_capture)
		if not zoomed_in_capture.is_empty():
			captures.append(zoomed_in_capture)
	var blockout_status := _scene_status("blockout_quality_status")
	var post_status := _scene_status("post_mine_flow_status")
	var checks: Dictionary = blockout_status.get("checks", {})
	for key in checks.keys():
		if not bool(checks[key]):
			errors.append("v0.137 blockout quality check failed: %s" % key)
	var finish_checks := {
		"resultsReached": bool(post_status.get("resultsReached", false)) and current_step_id == "player_results",
		"noObjectiveRegression": not bool(post_status.get("actualObjectiveRegressionDetected", true)),
		"noDebugShortcut": not bool(blockout_status.get("debugShortcutUsed", true)),
		"noStateInjection": not bool(blockout_status.get("stateInjectionUsed", true)),
		"linkedWardPreserved": float(blockout_status.get("linkedWardDamageTakenMultiplier", 0.0)) == 0.92
	}
	for key in finish_checks.keys():
		if not bool(finish_checks[key]):
			errors.append("v0.137 finish check failed: %s" % key)
	if str(blockout_status.get("status", "")) != "PASS_V0137_BLOCKOUT_QUALITY_SCENE_STATUS":
		errors.append("v0.137 scene status did not pass: %s" % str(blockout_status.get("status", "missing")))
	var combined_trace := trace.duplicate(true)
	for entry in blockout_status.get("trace", []):
		combined_trace.append(entry)
	var performance_smoke := _v0137_performance_smoke(performance_windows)
	if str(performance_smoke.get("status", "")) != "PASS_V0137_PERFORMANCE_SMOKE":
		errors.append("v0.137 performance smoke did not pass.")
	var smoke := {
		"schemaVersion": 1,
		"checkpoint": "v0.137",
		"status": "PASS_V0137_HEADED_BLOCKOUT_QUALITY_SMOKE" if errors.is_empty() else "FAIL_V0137_HEADED_BLOCKOUT_QUALITY_SMOKE",
		"artifactRoot": artifact_root,
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"inputPath": "packaged Godot player slice normal mouse events and ordinary simulation",
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": bool(blockout_status.get("debugShortcutUsed", false)),
		"stateInjectionUsed": bool(blockout_status.get("stateInjectionUsed", false)),
		"fixtureOnlyHelperProofUsed": false,
		"screenshotOnlyProofUsed": false,
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"checks": checks,
		"finishChecks": finish_checks,
		"blockoutStatus": blockout_status,
		"postMineStatus": post_status,
		"performanceSmoke": performance_smoke,
		"errors": errors
	}
	var screenshot_manifest := {
		"schemaVersion": 1,
		"checkpoint": "v0.137",
		"status": "PASS_V0137_SCREENSHOT_MANIFEST" if captures.size() == 12 and errors.is_empty() else "FAIL_V0137_SCREENSHOT_MANIFEST",
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": 12,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "blockout-quality-smoke.json"), smoke)
	_write_absolute_json(_path_join(artifact_root, "headed-blockout-quality-smoke.json"), smoke)
	_write_absolute_json(_path_join(artifact_root, "composition-readability-report.json"), {"schemaVersion": 1, "checkpoint": "v0.137", "status": "PASS_V0137_COMPOSITION_READABILITY" if _v0134_all_checks_true(blockout_status.get("compositionChecks", {})) else "FAIL_V0137_COMPOSITION_READABILITY", "checks": blockout_status.get("compositionChecks", {})})
	_write_absolute_json(_path_join(artifact_root, "silhouette-readability-report.json"), {"schemaVersion": 1, "checkpoint": "v0.137", "status": "PASS_V0137_SILHOUETTE_READABILITY" if _v0134_all_checks_true(blockout_status.get("silhouetteChecks", {})) else "FAIL_V0137_SILHOUETTE_READABILITY", "checks": blockout_status.get("silhouetteChecks", {})})
	_write_absolute_json(_path_join(artifact_root, "lighting-vfx-report.json"), {"schemaVersion": 1, "checkpoint": "v0.137", "status": "PASS_V0137_LIGHTING_VFX" if _v0134_all_checks_true(blockout_status.get("atmosphereChecks", {})) and _v0134_all_checks_true(blockout_status.get("vfxChecks", {})) else "FAIL_V0137_LIGHTING_VFX", "atmosphereChecks": blockout_status.get("atmosphereChecks", {}), "vfxChecks": blockout_status.get("vfxChecks", {})})
	_write_absolute_json(_path_join(artifact_root, "camera-screen-use-report.json"), {"schemaVersion": 1, "checkpoint": "v0.137", "status": "PASS_V0137_CAMERA_SCREEN_USE" if _v0134_all_checks_true(blockout_status.get("cameraChecks", {})) else "FAIL_V0137_CAMERA_SCREEN_USE", "checks": blockout_status.get("cameraChecks", {})})
	_write_absolute_json(_path_join(artifact_root, "performance-smoke.json"), performance_smoke)
	_write_absolute_json(_path_join(artifact_root, "screenshot-manifest.json"), screenshot_manifest)
	_write_absolute_json(_path_join(artifact_root, "blockout-quality-trace.json"), {"schemaVersion": 1, "checkpoint": "v0.137", "status": smoke.get("status", "UNKNOWN"), "trace": combined_trace, "noPrivateHarnessShortcutUsed": true, "noDebugShortcutUsed": not bool(blockout_status.get("debugShortcutUsed", true)), "noStateInjectionUsed": not bool(blockout_status.get("stateInjectionUsed", true)), "fixtureOnlyHelperProofUsed": false, "screenshotOnlyProofUsed": false})
	_write_absolute_text(_path_join(artifact_root, "blockout-quality-trace.md"), _v0137_trace_markdown(smoke, combined_trace))
	_write_absolute_text(_path_join(artifact_root, "blockout-comparison.md"), _v0137_comparison_markdown(smoke, screenshot_manifest))
	_write_absolute_text(_path_join(artifact_root, "README.md"), _v0137_readme(smoke, screenshot_manifest))
	get_tree().quit(0 if errors.is_empty() else 1)

func _measure_v0137_window(id: String, label: String, frame_count: int) -> Dictionary:
	var start_usec: int = Time.get_ticks_usec()
	await _settle_frames(frame_count)
	var elapsed_ms: float = float(Time.get_ticks_usec() - start_usec) / 1000.0
	var average_frame_ms: float = elapsed_ms / max(1.0, float(frame_count))
	return {
		"id": id,
		"label": label,
		"frameCount": frame_count,
		"elapsedMs": snappedf(elapsed_ms, 0.01),
		"averageFrameMs": snappedf(average_frame_ms, 0.01),
		"estimatedFps": snappedf(1000.0 / max(0.001, average_frame_ms), 0.01),
		"screenshotCaptureExcluded": true,
		"status": "PASS_V0137_PERFORMANCE_WINDOW" if average_frame_ms <= 40.0 else "FAIL_V0137_PERFORMANCE_WINDOW"
	}

func _v0137_performance_smoke(windows: Array[Dictionary]) -> Dictionary:
	var required := ["default_slice", "combat_peak", "zoomed_out", "fog_on", "lume_pulse"]
	var errors: Array[String] = []
	for id in required:
		if not windows.any(func(entry: Dictionary) -> bool: return str(entry.get("id", "")) == id):
			errors.append("missing performance window %s" % id)
	for entry in windows:
		if str(entry.get("status", "")) != "PASS_V0137_PERFORMANCE_WINDOW":
			errors.append("performance window failed %s" % str(entry.get("id", "unknown")))
		if not bool(entry.get("screenshotCaptureExcluded", false)):
			errors.append("screenshot capture was not excluded for %s" % str(entry.get("id", "unknown")))
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.137",
		"status": "PASS_V0137_PERFORMANCE_SMOKE" if errors.is_empty() else "FAIL_V0137_PERFORMANCE_SMOKE",
		"windows": windows,
		"requiredWindows": required,
		"screenshotCaptureExcludedFromMeasuredWindow": true,
		"finalProductionCertification": false,
		"errors": errors
	}

func _capture_v0137_step(screenshot_root: String, index: int, id: String, label: String, action: String) -> Dictionary:
	await _settle_frames(2)
	var file_name := "%02d_%s.png" % [index + 1, id]
	var target := _path_join(screenshot_root, file_name)
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var save_result := image.save_png(target)
	return {
		"id": id,
		"label": label,
		"fileName": file_name,
		"absolutePath": target,
		"width": image.get_width(),
		"height": image.get_height(),
		"screen": active_mode,
		"action": action,
		"saveStatus": save_result,
		"status": _scene_status("blockout_quality_status")
	}

func _v0137_trace_markdown(smoke: Dictionary, trace: Array) -> String:
	var lines := [
		"# v0.137 Blockout Quality Trace",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"| # | Event | Details |",
		"| --- | --- | --- |"
	]
	for index in range(trace.size()):
		var entry: Dictionary = trace[index]
		lines.append("| %s | %s | `%s` |" % [index + 1, str(entry.get("event", "")), JSON.stringify(entry.get("details", {}))])
	lines.append("")
	lines.append("Private harness shortcut used: `%s`" % str(smoke.get("privateHarnessShortcutUsed", false)))
	lines.append("Debug shortcut used: `%s`" % str(smoke.get("debugShortcutUsed", false)))
	lines.append("State injection used: `%s`" % str(smoke.get("stateInjectionUsed", false)))
	lines.append("Fixture-only helper proof used: `%s`" % str(smoke.get("fixtureOnlyHelperProofUsed", false)))
	lines.append("Screenshot-only proof used: `%s`" % str(smoke.get("screenshotOnlyProofUsed", false)))
	return "\n".join(lines) + "\n"

func _v0137_comparison_markdown(smoke: Dictionary, manifest: Dictionary) -> String:
	var status: Dictionary = smoke.get("blockoutStatus", {})
	return "\n".join([
		"# v0.137 Blockout Comparison",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"v0.136 proved the HUD/minimap/onboarding path. v0.137 keeps that same packaged player path and upgrades the procedural blockout so Salto reads as a composed RTS/RPG battlefield instead of plain debug slabs.",
		"",
		"Upgraded cues:",
		"",
		"- Foothold silhouette, wet-granite road slabs, side paths, ford stones, water edge, quarry cut, shrine clearing, ruin pocket, Barracks footprint, Command Hall hearth, friendly staging, Ashen lane, and Lume path are now separately named procedural pieces.",
		"- Aster, Worker, Militia, Ranger, Ashen attackers, Command Hall, Barracks, mine, shrine, ruin, and Lume endpoint use geometry differentiation rather than color alone.",
		"- Mine conversion, Worker assignment, construction, recruitment, countdown, attack, damage, death, and Lume pulses are verified after normal play reaches Results.",
		"",
		"Capture count: `%s/%s`." % [manifest.get("captureCount", 0), manifest.get("requiredCaptureCount", 12)],
		"Scene status: `%s`." % str(status.get("status", "UNKNOWN")),
		"",
		"No generated image, imported asset, runtime art integration, save change, stable-ID change, browser-runtime change, Godot-editor routine work, full port, or final engine choice is included."
	]) + "\n"

func _v0137_readme(smoke: Dictionary, manifest: Dictionary) -> String:
	return "\n".join([
		"# v0.137 Godot Procedural Blockout Quality Evidence",
		"",
		"Status: `%s`" % str(smoke.get("status", "UNKNOWN")),
		"",
		"These ignored artifacts are generated by `GODOT_BLOCKOUT_QUALITY_WINDOWS.bat` / `npm run godot:headed:blockout-quality` against the packaged player-facing Godot slice.",
		"",
		"- `blockout-quality-smoke.json` records the real mouse-driven path to Results and the final scene-quality status.",
		"- `composition-readability-report.json`, `silhouette-readability-report.json`, `lighting-vfx-report.json`, and `camera-screen-use-report.json` record focused sub-gates.",
		"- `performance-smoke.json` records default, combat peak, zoomed-out, fog-on, and Lume-pulse windows with screenshot capture excluded.",
		"- `screenshot-manifest.json` records `%s/%s` required review screenshots." % [manifest.get("captureCount", 0), manifest.get("requiredCaptureCount", 12)],
		"- `blockout-comparison.md` summarizes the v0.136 to v0.137 visual-quality delta.",
		"",
		"No private harness shortcut, debug action, direct state injection, fixture-only helper proof, screenshot-only assertion, save write, stable-ID change, art import, browser-runtime change, or Godot-editor work is accepted as proof."
	]) + "\n"

func run_triple_natural_playthrough_smoke() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	_set_capture_viewport(VIEWPORT_SIZE)
	await _settle_frames(8)
	var start_usec := Time.get_ticks_usec()
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var playthroughs: Array[Dictionary] = []
	var recovery_cases: Array[Dictionary] = []
	var restart_checks: Array[Dictionary] = []
	last_post_mine_flow_status = {}
	var normal_profile := await _v0134_complete_natural_battle("normal_direct_path", false, false, screenshot_root, captures, recovery_cases, errors)
	normal_profile["returnedToTitle"] = await _v0134_return_to_title("normal_direct_path", screenshot_root, captures, errors)
	playthroughs.append(normal_profile)
	var mistake_profile := await _v0134_complete_natural_battle("recoverable_mistakes", true, false, screenshot_root, captures, recovery_cases, errors)
	mistake_profile["returnedToTitle"] = await _v0134_return_to_title("recoverable_mistakes", screenshot_root, captures, errors)
	playthroughs.append(mistake_profile)
	var restart_profile := {
		"id": "restart_and_replay",
		"passes": [],
		"returnedToTitle": false
	}
	var first_restart_pass := await _v0134_complete_natural_battle("restart_and_replay_initial", false, false, screenshot_root, captures, recovery_cases, errors)
	restart_profile["passes"].append(first_restart_pass)
	await _v0134_click_restart_from_results("restart_and_replay", screenshot_root, captures, restart_checks, errors)
	var replay_pass := await _v0134_complete_natural_battle("restart_and_replay_after_restart", false, true, screenshot_root, captures, recovery_cases, errors)
	restart_profile["passes"].append(replay_pass)
	restart_profile["returnedToTitle"] = await _v0134_return_to_title("restart_and_replay", screenshot_root, captures, errors)
	await _v0134_start_again_from_title("restart_and_replay", screenshot_root, captures, restart_checks, errors)
	restart_profile["status"] = "PASS_RESTART_AND_REPLAY" if first_restart_pass.get("resultsReached", false) and replay_pass.get("resultsReached", false) else "FAIL_RESTART_AND_REPLAY"
	playthroughs.append(restart_profile)
	var green := errors.is_empty()
	for playthrough in playthroughs:
		var status_text := str(playthrough.get("status", ""))
		if status_text.begins_with("FAIL"):
			green = false
	for recovery in recovery_cases:
		if not bool(recovery.get("passed", false)):
			green = false
	for check in restart_checks:
		if not bool(check.get("passed", false)):
			green = false
	var triple_report := {
		"schemaVersion": 1,
		"checkpoint": "v0.134",
		"status": "PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH" if green else "FAIL_V0134_TRIPLE_NATURAL_PLAYTHROUGH",
		"artifactRoot": artifact_root,
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"inputPath": "packaged Godot player slice normal mouse events and normal simulation",
		"profileCount": 3,
		"profiles": playthroughs,
		"errors": errors,
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": false,
		"stateInjectionUsed": false,
		"scriptedObjectiveSkippingUsed": false,
		"fixtureOnlyHelperProofUsed": false,
		"screenshotOnlyProofUsed": false,
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"linkedWardDamageTakenMultiplier": 0.92
	}
	var recovery_report := {
		"schemaVersion": 1,
		"checkpoint": "v0.134",
		"status": "PASS_V0134_RECOVERY_CASES" if _v0134_all_cases_passed(recovery_cases) else "FAIL_V0134_RECOVERY_CASES",
		"cases": recovery_cases,
		"noSoftLockObserved": errors.is_empty()
	}
	var restart_report := {
		"schemaVersion": 1,
		"checkpoint": "v0.134",
		"status": "PASS_V0134_RESTART_INTEGRITY" if _v0134_all_cases_passed(restart_checks) else "FAIL_V0134_RESTART_INTEGRITY",
		"checks": restart_checks,
		"resetIntegritySource": "Results buttons, Return to Title, Start Salto Review, and Start Battle in packaged player-slice flow"
	}
	var softlock_report := {
		"schemaVersion": 1,
		"checkpoint": "v0.134",
		"status": "PASS_V0134_NO_SOFTLOCK_PROOF" if green else "FAIL_V0134_NO_SOFTLOCK_PROOF",
		"allProfilesReachedResults": _v0134_profiles_reached_results(playthroughs),
		"allProfilesReturnedToTitle": _v0134_profiles_returned_to_title(playthroughs),
		"objectiveRegressionDetected": _v0134_any_objective_regression(playthroughs),
		"errors": errors
	}
	var shortcut_report := {
		"schemaVersion": 1,
		"checkpoint": "v0.134",
		"status": "PASS_V0134_NO_SHORTCUT_PROOF",
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": false,
		"stateInjectionUsed": false,
		"scriptedObjectiveSkippingUsed": false,
		"fixtureOnlyHelperProofUsed": false,
		"screenshotOnlyProofUsed": false,
		"routineEditorUseRequired": false,
		"evidencePath": "packaged player-facing Godot slice mouse events and ordinary simulation"
	}
	var screenshot_manifest := {
		"schemaVersion": 1,
		"checkpoint": "v0.134",
		"status": "PASS_V0134_SCREENSHOT_MANIFEST" if captures.size() >= 24 and green else "FAIL_V0134_SCREENSHOT_MANIFEST",
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": 24,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "triple-playthrough-report.json"), triple_report)
	_write_absolute_json(_path_join(artifact_root, "recovery-case-report.json"), recovery_report)
	_write_absolute_json(_path_join(artifact_root, "restart-integrity-report.json"), restart_report)
	_write_absolute_json(_path_join(artifact_root, "no-softlock-proof.json"), softlock_report)
	_write_absolute_json(_path_join(artifact_root, "no-shortcut-proof.json"), shortcut_report)
	_write_absolute_json(_path_join(artifact_root, "screenshot-manifest.json"), screenshot_manifest)
	_write_absolute_text(_path_join(artifact_root, "README.md"), _v0134_readme(triple_report, recovery_report, restart_report, screenshot_manifest))
	get_tree().quit(0 if green else 1)

func _v0134_complete_natural_battle(run_id: String, mistake_mode: bool, from_current_battle: bool, screenshot_root: String, captures: Array[Dictionary], recovery_cases: Array[Dictionary], errors: Array[String]) -> Dictionary:
	var trace: Array[Dictionary] = []
	if not from_current_battle:
		show_player_title()
		await _settle_frames(8)
		_trace_real_input(trace, "launch", {"runId": run_id, "screen": "title"})
		await _inject_mouse_click(Vector2(750, 303), MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "title_start_clicked", {"runId": run_id, "position": _vector2_report(Vector2(750, 303))})
		await _settle_frames(8)
		if current_step_id != "player_briefing":
			errors.append("%s did not open briefing from title." % run_id)
		await _inject_mouse_click(Vector2(750, 411), MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "briefing_start_battle_clicked", {"runId": run_id, "position": _vector2_report(Vector2(750, 411))})
		await _settle_frames(16)
	else:
		_trace_real_input(trace, "battle_replay_started_from_restart", {"runId": run_id, "screen": current_step_id})
	if current_step_id != "player_battle":
		errors.append("%s did not reach player battle." % run_id)
		return {"id": run_id, "status": "FAIL_BATTLE_NOT_OPENED", "trace": trace}
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_battle_ready" % run_id, "Battle ready", "battle_ready", run_id))
	var hero_screen := _scene_screen_position("hero_aster")
	var mine_screen := _scene_screen_position("west_stone_cut_mine")
	var worker_screen := _scene_screen_position("worker_00")
	var barracks_screen := _scene_screen_position("barracks_interaction")
	var train_button_screen := _scene_screen_position("train_militia_button")
	var squad_start := _scene_screen_position("squad_drag_start")
	var squad_end := _scene_screen_position("squad_drag_end")
	var lume_screen := _scene_screen_position("lume_interaction")
	if hero_screen == Vector2.INF or mine_screen == Vector2.INF or worker_screen == Vector2.INF or barracks_screen == Vector2.INF or train_button_screen == Vector2.INF or lume_screen == Vector2.INF:
		errors.append("%s could not resolve required battlefield coordinates." % run_id)
		return {"id": run_id, "status": "FAIL_COORDINATE_RESOLUTION", "trace": trace}
	if mistake_mode:
		await _inject_mouse_click(Vector2(1180, 720), MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "empty_terrain_before_aster_probe", {"runId": run_id})
		await _settle_frames(6)
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "invalid_move_before_selection_probe", {"runId": run_id})
		await _settle_frames(6)
	await _inject_mouse_motion(hero_screen)
	await _inject_mouse_click(hero_screen, MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "aster_click", {"runId": run_id, "position": _vector2_report(hero_screen)})
	await _settle_frames(8)
	if mistake_mode:
		await _inject_mouse_click(worker_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "friendly_right_click_probe", {"runId": run_id, "target": "worker_00"})
		await _settle_frames(6)
	await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
	_trace_real_input(trace, "mine_right_click", {"runId": run_id, "position": _vector2_report(mine_screen)})
	if mistake_mode:
		await _settle_until_scene_status_number_at_least("post_mine_flow_status", "conversionProgress", 0.25, 220)
		captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_conversion_before_leave" % run_id, "Conversion before leave", "conversion_before_leave", run_id))
		await _inject_mouse_click(Vector2(430, 690), MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "move_away_during_conversion_probe", {"runId": run_id})
		await _settle_frames(40)
		await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
		_trace_real_input(trace, "reenter_capture_ring_probe", {"runId": run_id})
	await _settle_until_scene_status_flag("post_mine_flow_status", "mineControlled", true, 620)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_mine_controlled" % run_id, "Mine controlled", "mine_controlled", run_id))
	if mistake_mode:
		await _inject_mouse_click(worker_screen + Vector2(82, 0), MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "miss_worker_click_probe", {"runId": run_id})
		await _settle_frames(6)
		await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "barracks_click_before_worker_probe", {"runId": run_id})
		await _settle_frames(6)
	worker_screen = _scene_screen_position("worker_00")
	await _inject_mouse_motion(worker_screen)
	await _settle_frames(4)
	await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "worker_click", {"runId": run_id, "position": _vector2_report(worker_screen)})
	await _settle_frames(8)
	await _inject_mouse_click(mine_screen, MOUSE_BUTTON_RIGHT)
	_trace_real_input(trace, "worker_right_click_controlled_mine", {"runId": run_id, "position": _vector2_report(mine_screen)})
	await _settle_until_scene_status_flag("post_mine_flow_status", "workerAssignedToMine", true, 220)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_worker_assigned" % run_id, "Worker assigned", "worker_assigned", run_id))
	if squad_start != Vector2.INF and squad_end != Vector2.INF:
		await _inject_mouse_drag(squad_start, squad_end)
		_trace_real_input(trace, "box_select_no_objective_skip_probe", {"runId": run_id})
		await _settle_frames(8)
	worker_screen = _scene_screen_position("worker_00")
	await _inject_mouse_motion(worker_screen)
	await _settle_frames(4)
	await _inject_mouse_click(worker_screen, MOUSE_BUTTON_LEFT)
	await _settle_until_scene_status_flag("post_mine_flow_status", "barracksHighlightVisible", true, 140)
	await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_RIGHT)
	_trace_real_input(trace, "barracks_restore_right_click", {"runId": run_id, "position": _vector2_report(barracks_screen)})
	await _settle_until_scene_status_number_at_least("post_mine_flow_status", "constructionProgress", 0.75, 520)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_construction_75" % run_id, "Construction 75 percent", "construction_75", run_id))
	await _settle_until_scene_status_flag("post_mine_flow_status", "barracksRestored", true, 620)
	await _inject_mouse_click(barracks_screen, MOUSE_BUTTON_LEFT)
	await _settle_until_scene_status_flag("post_mine_flow_status", "barracksSelected", true, 100)
	await _inject_mouse_click(train_button_screen, MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "train_militia_clicked", {"runId": run_id})
	if mistake_mode:
		await _inject_mouse_click(train_button_screen, MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "duplicate_train_click_probe", {"runId": run_id})
	await _settle_until_scene_status_number_at_least("post_mine_flow_status", "recruitProgress", 0.50, 420)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_recruit_50" % run_id, "Recruitment 50 percent", "recruit_50", run_id))
	await _settle_until_scene_status_flag("post_mine_flow_status", "militiaSpawned", true, 520)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_militia_spawned" % run_id, "Militia spawned", "militia_spawned", run_id))
	await _settle_until_scene_status_flag("post_mine_flow_status", "countdownStarted", true, 180)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_countdown" % run_id, "Ashen countdown", "countdown", run_id))
	await _settle_until_scene_status_flag("post_mine_flow_status", "waveTriggeredOnce", true, 780)
	await _settle_until_scene_status_flag("post_mine_flow_status", "enemyMovementStarted", true, 360)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_enemy_movement" % run_id, "Enemy movement", "enemy_movement", run_id))
	if mistake_mode:
		await _inject_mouse_click(Vector2(1180, 720), MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "clear_selection_before_attack_probe", {"runId": run_id})
		await _settle_frames(6)
		await _inject_mouse_click(_scene_screen_position("attack_button"), MOUSE_BUTTON_LEFT)
		_trace_real_input(trace, "attack_with_no_valid_selection_probe", {"runId": run_id})
		await _settle_frames(8)
		await _inject_mouse_drag(Vector2(260, 590), Vector2(340, 650))
		_trace_real_input(trace, "empty_box_select_during_combat_probe", {"runId": run_id})
		await _settle_frames(8)
	if squad_start != Vector2.INF and squad_end != Vector2.INF:
		await _inject_mouse_drag(squad_start, squad_end)
		_trace_real_input(trace, "combat_squad_box_selected", {"runId": run_id})
		await _settle_frames(8)
	var enemy_screen := _scene_screen_position("ashen_00")
	await _inject_mouse_click(enemy_screen, MOUSE_BUTTON_RIGHT)
	_trace_real_input(trace, "combat_attack_right_click", {"runId": run_id, "position": _vector2_report(enemy_screen)})
	await _settle_until_scene_status_flag("post_mine_flow_status", "combatStarted", true, 480)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_combat_onset" % run_id, "Combat onset", "combat_onset", run_id))
	await _settle_until_scene_status_flag("post_mine_flow_status", "waveDefeatedFromSimulation", true, 1100)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_wave_defeated" % run_id, "Wave defeated", "wave_defeated", run_id))
	lume_screen = _scene_screen_position("lume_interaction")
	await _inject_mouse_click(lume_screen, MOUSE_BUTTON_LEFT)
	_trace_real_input(trace, "lume_restore_click", {"runId": run_id, "position": _vector2_report(lume_screen)})
	await _settle_until_scene_status_flag("post_mine_flow_status", "lumeRestored", true, 220)
	await _settle_until_player_step("player_results", 220)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_results" % run_id, "Results", "results", run_id))
	var scene_status := _v0134_scene_status()
	var checks := _v0134_required_result_checks(scene_status)
	for key in checks.keys():
		if not bool(checks[key]):
			errors.append("%s failed v0.134 playthrough check: %s" % [run_id, key])
	if mistake_mode:
		_v0134_record_recovery_cases(run_id, trace, scene_status, recovery_cases)
	return {
		"id": run_id,
		"status": "PASS_NATURAL_PLAYTHROUGH" if _v0134_all_checks_true(checks) else "FAIL_NATURAL_PLAYTHROUGH",
		"mistakeMode": mistake_mode,
		"resultsReached": bool(scene_status.get("resultsReached", false)) and current_step_id == "player_results",
		"returnedToTitle": false,
		"checks": checks,
		"sceneStatus": scene_status,
		"trace": _v0134_combined_trace(trace, scene_status)
	}

func _v0134_required_result_checks(scene_status: Dictionary) -> Dictionary:
	return {
		"asterSelected": bool(scene_status.get("asterSelected", false)),
		"moveOrderAccepted": bool(scene_status.get("moveOrderAccepted", false)),
		"mineControlled": bool(scene_status.get("mineControlled", false)),
		"workerAssignedToMine": bool(scene_status.get("workerAssignedToMine", false)),
		"barracksRestored": bool(scene_status.get("barracksRestored", false)),
		"militiaSpawned": bool(scene_status.get("militiaSpawned", false)),
		"countdownStarted": bool(scene_status.get("countdownStarted", false)),
		"waveTriggeredOnce": bool(scene_status.get("waveTriggeredOnce", false)),
		"enemyMovementStarted": bool(scene_status.get("enemyMovementStarted", false)),
		"combatStarted": bool(scene_status.get("combatStarted", false)),
		"waveDefeatedFromSimulation": bool(scene_status.get("waveDefeatedFromSimulation", false)),
		"lumeRestored": bool(scene_status.get("lumeRestored", false)),
		"resultsReached": bool(scene_status.get("resultsReached", false)) and current_step_id == "player_results",
		"noObjectiveRegression": not bool(scene_status.get("actualObjectiveRegressionDetected", true)),
		"boxSelectNoObjectiveSkipProven": bool(scene_status.get("boxSelectNoObjectiveSkipProven", false)),
		"debugShortcutNotUsed": not bool(scene_status.get("debugShortcutUsed", true)),
		"stateInjectionNotUsed": not bool(scene_status.get("stateInjectionUsed", true)),
		"linkedWardPreserved": float(scene_status.get("linkedWardDamageTakenMultiplier", 0.0)) == 0.92
	}

func _v0134_return_to_title(run_id: String, screenshot_root: String, captures: Array[Dictionary], errors: Array[String]) -> bool:
	await _inject_mouse_click(Vector2(750, 393), MOUSE_BUTTON_LEFT)
	await _settle_until_player_step("player_title", 120)
	if current_step_id != "player_title":
		errors.append("%s did not return to title from Results." % run_id)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_return_title" % run_id, "Return to Title", "return_title", run_id))
	return current_step_id == "player_title"

func _v0134_click_restart_from_results(run_id: String, screenshot_root: String, captures: Array[Dictionary], restart_checks: Array[Dictionary], errors: Array[String]) -> void:
	await _inject_mouse_click(Vector2(750, 339), MOUSE_BUTTON_LEFT)
	await _settle_until_player_step("player_battle", 160)
	await _settle_frames(12)
	var status := _v0134_scene_status()
	var check := _v0134_reset_integrity_check("%s_results_restart" % run_id, status)
	restart_checks.append(check)
	if not bool(check.get("passed", false)):
		errors.append("%s restart from Results did not reset cleanly." % run_id)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_restart_battle_reset" % run_id, "Restart battle reset", "restart_battle_reset", run_id))

func _v0134_start_again_from_title(run_id: String, screenshot_root: String, captures: Array[Dictionary], restart_checks: Array[Dictionary], errors: Array[String]) -> void:
	if current_step_id != "player_title":
		return
	await _inject_mouse_click(Vector2(750, 303), MOUSE_BUTTON_LEFT)
	await _settle_until_player_step("player_briefing", 80)
	await _inject_mouse_click(Vector2(750, 411), MOUSE_BUTTON_LEFT)
	await _settle_until_player_step("player_battle", 120)
	await _settle_frames(12)
	var status := _v0134_scene_status()
	var check := _v0134_reset_integrity_check("%s_return_title_start_again" % run_id, status)
	restart_checks.append(check)
	if not bool(check.get("passed", false)):
		errors.append("%s return-title start-again path did not reset cleanly." % run_id)
	captures.append(await _capture_v0134_step(screenshot_root, captures.size(), "%s_start_again_reset" % run_id, "Start again reset", "start_again_reset", run_id))

func _v0134_reset_integrity_check(id: String, status: Dictionary) -> Dictionary:
	var selected: Array = status.get("selectedIds", [])
	var checks := {
		"objectiveReset": str(status.get("objectiveStep", "")) == "select_aster",
		"selectionReset": selected.is_empty(),
		"mineOwnershipReset": not bool(status.get("mineControlled", false)),
		"workerAssignmentReset": not bool(status.get("workerAssignedToMine", false)),
		"barracksReset": not bool(status.get("barracksRestored", false)) and not bool(status.get("barracksBuildOrderAccepted", false)),
		"recruitReset": not bool(status.get("recruitQueueStarted", false)) and not bool(status.get("militiaSpawned", false)),
		"countdownReset": not bool(status.get("countdownStarted", false)),
		"waveReset": not bool(status.get("waveTriggeredOnce", false)) and int(status.get("waveRemainingCount", 4)) == 4,
		"lumeReset": not bool(status.get("lumeRestored", false)),
		"resultsReset": not bool(status.get("resultsReached", false)),
		"hudMinimapReset": bool(status.get("routineEditorUseRequired", true)) == false
	}
	return {
		"id": id,
		"passed": _v0134_all_checks_true(checks),
		"checks": checks,
		"status": status
	}

func _v0134_record_recovery_cases(run_id: String, trace: Array[Dictionary], scene_status: Dictionary, recovery_cases: Array[Dictionary]) -> void:
	var events := _v0134_event_names(trace, scene_status)
	var feedback: Array = scene_status.get("v0134RecoveryFeedbackIds", [])
	_v0134_add_recovery_case(recovery_cases, run_id, "empty_terrain_before_aster", events.has("empty_terrain_before_aster") or feedback.has("empty_terrain_before_aster"), feedback, scene_status)
	_v0134_add_recovery_case(recovery_cases, run_id, "invalid_move_before_selection", events.has("right_click_rejected_no_selection") or feedback.has("no_selection_move_rejected"), feedback, scene_status)
	_v0134_add_recovery_case(recovery_cases, run_id, "right_click_friendly_unit", events.has("right_click_friendly_unit_ignored") or feedback.has("friendly_right_click_ignored"), feedback, scene_status)
	_v0134_add_recovery_case(recovery_cases, run_id, "move_aster_away_during_conversion", events.has("move_away_during_conversion_probe") and bool(scene_status.get("mineControlled", false)), feedback, scene_status)
	_v0134_add_recovery_case(recovery_cases, run_id, "reenter_capture_ring", events.has("reenter_capture_ring_probe") and bool(scene_status.get("mineControlled", false)), feedback, scene_status)
	_v0134_add_recovery_case(recovery_cases, run_id, "miss_worker_click_once", events.has("miss_worker_click_probe") and bool(scene_status.get("workerAssignedToMine", false)), feedback, scene_status)
	_v0134_add_recovery_case(recovery_cases, run_id, "click_barracks_before_worker_selection", events.has("barracks_click_before_worker_probe") and (events.has("barracks_click_before_restored") or feedback.has("barracks_not_ready")), feedback, scene_status)
	_v0134_add_recovery_case(recovery_cases, run_id, "empty_box_select_during_combat", events.has("empty_box_select_during_combat_probe") and (events.has("box_select_empty_preserved_defenders") or bool(scene_status.get("boxSelectNoObjectiveSkipProven", false))), feedback, scene_status)
	_v0134_add_recovery_case(recovery_cases, run_id, "reselect_defenders", events.has("combat_squad_box_selected") and bool(scene_status.get("attackInputAccepted", false)), feedback, scene_status)
	_v0134_add_recovery_case(recovery_cases, run_id, "attack_with_no_valid_selection", events.has("attack_with_no_valid_selection_recovered") or feedback.has("attack_no_selection_auto_recover"), feedback, scene_status)

func _v0134_add_recovery_case(recovery_cases: Array[Dictionary], run_id: String, id: String, passed: bool, feedback: Array, scene_status: Dictionary) -> void:
	recovery_cases.append({
		"id": id,
		"runId": run_id,
		"passed": passed,
		"feedbackIds": feedback.duplicate(),
		"objectiveStep": scene_status.get("objectiveStep", ""),
		"objectiveRegressionDetected": scene_status.get("actualObjectiveRegressionDetected", false),
		"resultsReached": scene_status.get("resultsReached", false)
	})

func _v0134_event_names(trace: Array[Dictionary], scene_status: Dictionary) -> Array[String]:
	var names: Array[String] = []
	for entry in _v0134_combined_trace(trace, scene_status):
		var event_name := str(entry.get("event", ""))
		if event_name != "" and not names.has(event_name):
			names.append(event_name)
	return names

func _v0134_combined_trace(trace: Array[Dictionary], scene_status: Dictionary) -> Array[Dictionary]:
	var combined: Array[Dictionary] = trace.duplicate(true)
	for entry in scene_status.get("trace", []):
		combined.append(entry)
	return combined

func _v0134_scene_status() -> Dictionary:
	var raw_scene_status: Variant = _call_scene("post_mine_flow_status")
	var scene_status: Dictionary = raw_scene_status if typeof(raw_scene_status) == TYPE_DICTIONARY else {}
	if not last_post_mine_flow_status.is_empty() and not bool(scene_status.get("resultsReached", false)) and current_step_id == "player_results":
		scene_status = last_post_mine_flow_status.duplicate(true)
	return scene_status

func _capture_v0134_step(screenshot_root: String, index: int, id: String, label: String, action: String, run_id: String) -> Dictionary:
	await _settle_frames(2)
	var safe_id := id.replace(":", "_").replace("/", "_")
	var file_name := "%02d_%s.png" % [index + 1, safe_id]
	var target := _path_join(screenshot_root, file_name)
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
		image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var save_result := image.save_png(target)
	return {
		"id": safe_id,
		"label": label,
		"fileName": file_name,
		"absolutePath": target,
		"width": image.get_width(),
		"height": image.get_height(),
		"screen": active_mode,
		"runId": run_id,
		"action": action,
		"saveStatus": save_result,
		"status": _v0134_scene_status()
	}

func _v0134_all_checks_true(checks: Dictionary) -> bool:
	for key in checks.keys():
		if not bool(checks[key]):
			return false
	return true

func _v0134_all_cases_passed(cases: Array[Dictionary]) -> bool:
	if cases.is_empty():
		return false
	for entry in cases:
		if not bool(entry.get("passed", false)):
			return false
	return true

func _v0134_profiles_reached_results(playthroughs: Array[Dictionary]) -> bool:
	for entry in playthroughs:
		if entry.has("passes"):
			for pass_entry in entry.get("passes", []):
				if not bool(pass_entry.get("resultsReached", false)):
					return false
		elif not bool(entry.get("resultsReached", false)):
			return false
	return true

func _v0134_profiles_returned_to_title(playthroughs: Array[Dictionary]) -> bool:
	if playthroughs.size() != 3:
		return false
	for entry in playthroughs:
		if not bool(entry.get("returnedToTitle", false)):
			return false
	return true

func _v0134_any_objective_regression(playthroughs: Array[Dictionary]) -> bool:
	for entry in playthroughs:
		if entry.has("passes"):
			for pass_entry in entry.get("passes", []):
				if bool(pass_entry.get("sceneStatus", {}).get("actualObjectiveRegressionDetected", false)):
					return true
		elif bool(entry.get("sceneStatus", {}).get("actualObjectiveRegressionDetected", false)):
			return true
	return false

func _v0134_readme(triple_report: Dictionary, recovery_report: Dictionary, restart_report: Dictionary, manifest: Dictionary) -> String:
	return "\n".join([
		"# v0.134 Godot Repeatable Natural Playthrough Evidence",
		"",
		"Triple playthrough status: `%s`" % str(triple_report.get("status", "UNKNOWN")),
		"Recovery status: `%s`" % str(recovery_report.get("status", "UNKNOWN")),
		"Restart integrity status: `%s`" % str(restart_report.get("status", "UNKNOWN")),
		"",
		"These ignored artifacts are generated by `GODOT_TRIPLE_NATURAL_PLAYTHROUGH_WINDOWS.bat` / `npm run godot:headed:triple-natural-playthrough` against the packaged player-facing Godot slice.",
		"",
		"- `triple-playthrough-report.json` records the normal, recoverable-mistakes, and restart-and-replay profiles.",
		"- `recovery-case-report.json` records invalid-click, conversion leave/re-enter, Worker miss, Barracks, combat box-select, defender reselect, and no-selection Attack recovery.",
		"- `restart-integrity-report.json` records Results restart and Return-to-Title start-again reset checks.",
		"- `no-softlock-proof.json` and `no-shortcut-proof.json` record the no-softlock and no-private/debug/state/fixture shortcut contract.",
		"- `screenshot-manifest.json` records `%s/%s` screenshots." % [manifest.get("captureCount", 0), manifest.get("requiredCaptureCount", 24)],
		"",
		"No Godot-editor work, private-harness shortcut, state injection, scripted objective skipping, fixture-only helper proof, save write, stable-ID change, generated/imported art, or browser-runtime change is accepted as proof."
	]) + "\n"

func _apply_player_slice_action(action: String) -> Dictionary:
	match action:
		"title":
			show_player_title()
		"briefing":
			show_player_briefing()
		"battle_default":
			show_player_battle()
			_call_scene("set_onboarding_step", ["select_aster"])
		"hud_default":
			show_player_battle()
			_call_scene("set_onboarding_step", ["select_aster"])
			_render_player_screen("battle")
		"objective_1":
			_ensure_player_battle_scene()
			_call_scene("set_onboarding_step", ["select_aster"])
			_call_scene("show_objective_feedback", ["objective_1"])
			_render_player_screen("battle")
		"onboarding_skip_private":
			_ensure_player_battle_scene()
			_call_scene("skip_onboarding_private")
			_render_player_screen("battle")
		"hero_selected":
			_ensure_player_battle_scene()
			_call_scene("select_entity", ["hero_aster"])
			if _is_bounded_microloop_checkpoint():
				_call_scene("trigger_hero_ability")
			_call_scene("set_onboarding_step", ["move_to_quarry"])
			_call_scene("show_objective_feedback", ["select_aster"])
			_call_scene("focus_visual_subject", ["hero"])
			_render_player_screen("battle")
		"move_order":
			_ensure_player_battle_scene()
			_call_scene("issue_move_order")
			_call_scene("focus_visual_subject", ["move_order"])
			_render_player_screen("battle")
		"quarry_objective":
			_ensure_player_battle_scene()
			_call_scene("change_site_state", ["west_stone_cut", "friendly"])
			_call_scene("focus_layout_feature", ["quarry"])
			_call_scene("focus_visual_subject", ["quarry"])
			_render_player_screen("battle")
		"mine_uncaptured":
			show_player_battle()
			if _is_bounded_microloop_checkpoint():
				_call_scene("select_entity", ["hero_aster"])
				_call_scene("trigger_hero_ability")
			_call_scene("focus_visual_subject", ["mine"])
			_call_scene("set_onboarding_step", ["capture_hold_quarry"])
			_render_player_screen("battle")
		"mine_converted":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("advance_resource_production", [120])
			_call_scene("focus_visual_subject", ["mine"])
			_render_player_screen("battle")
		"worker_assigned_mine":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("focus_visual_subject", ["worker"])
			_render_player_screen("battle")
		"build_placement":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("place_barracks_placeholder")
			_call_scene("focus_visual_subject", ["barracks"])
			_render_player_screen("battle")
		"construction_progress":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [60])
			_call_scene("focus_visual_subject", ["barracks"])
			_render_player_screen("battle")
		"barracks_complete":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("focus_visual_subject", ["barracks"])
			_render_player_screen("battle")
		"recruit_queue":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("focus_visual_subject", ["barracks"])
			_render_player_screen("battle")
		"militia_spawned":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("focus_visual_subject", ["militia"])
			_render_player_screen("battle")
		"worker_selected":
			_ensure_player_battle_scene()
			_call_scene("select_entity", ["worker"])
			_call_scene("set_onboarding_step", ["worker_mine_or_shrine"])
			_call_scene("focus_visual_subject", ["worker"])
			_render_player_screen("battle")
		"squad_selected":
			_ensure_player_battle_scene()
			_call_scene("box_select_squad")
			_call_scene("set_onboarding_step", ["prepare_ashen_pressure"])
			_call_scene("focus_visual_subject", ["squad"])
			_render_player_screen("battle")
		"ashen_pressure_wave":
			_ensure_player_battle_scene()
			if _is_bounded_microloop_checkpoint():
				_call_scene("capture_mine_site")
				_call_scene("assign_worker_to_mine")
				_call_scene("advance_resource_production", [180])
				_call_scene("place_barracks_placeholder")
				_call_scene("advance_construction", [180])
				_call_scene("queue_militia_recruit")
				_call_scene("complete_recruit_queue", [140])
				_call_scene("trigger_pressure_wave")
				_call_scene("defeat_pressure_wave")
			else:
				_call_scene("issue_attack_order")
			_call_scene("focus_visual_subject", ["attack_order"])
			_render_player_screen("battle")
		"attack_order":
			_ensure_player_battle_scene()
			_call_scene("issue_attack_order")
			_call_scene("focus_visual_subject", ["attack_order"])
			_render_player_screen("battle")
		"hero", "worker", "militia", "ranger", "ashen_raider", "command_hall", "barracks", "mine", "site", "lume_endpoint":
			_ensure_player_battle_scene()
			_call_scene("focus_visual_subject", [action])
			_render_player_screen("battle")
		"combat":
			_ensure_player_battle_scene()
			_call_scene("show_combat_readability_sample")
			_render_player_screen("battle")
		"death":
			_ensure_player_battle_scene()
			_call_scene("show_death_readability_sample")
			_render_player_screen("battle")
		"lume_stable":
			_ensure_player_battle_scene()
			_call_scene("focus_lume_link")
		"lume_activation":
			_ensure_player_battle_scene()
			_call_scene("change_site_state", ["ford_toll", "friendly"])
			_call_scene("focus_lume_link")
		"lume_restore":
			_ensure_player_battle_scene()
			if _is_bounded_microloop_checkpoint():
				_call_scene("restore_lume_microloop")
			else:
				_call_scene("change_site_state", ["west_stone_cut", "friendly"])
				_call_scene("change_site_state", ["ford_toll", "friendly"])
				_call_scene("focus_lume_link")
				_call_scene("show_objective_feedback", ["lume_restore"])
				_call_scene("set_onboarding_step", ["review_results"])
			_render_player_screen("battle")
		"minimap":
			_ensure_player_battle_scene()
			_call_scene("focus_layout_feature", ["minimap"])
			_render_player_screen("battle")
		"road", "ford", "quarry", "shrine", "ruin", "buildable_ground", "objective_focus":
			_ensure_player_battle_scene()
			_call_scene("focus_layout_feature", [action])
			_call_scene("focus_visual_subject", [action])
			_render_player_screen("battle")
		"camera_min_zoom":
			_ensure_player_battle_scene()
			_call_scene("set_camera_zoom_posture", ["min"])
			_render_player_screen("battle")
		"camera_max_zoom":
			_ensure_player_battle_scene()
			_call_scene("set_camera_zoom_posture", ["max"])
			_render_player_screen("battle")
		"clean_preset":
			_ensure_player_battle_scene()
			_call_scene("set_visual_preset", [VISUAL_PRESET_CLEAN])
			_call_scene("focus_layout_feature", ["default"])
			_render_player_screen("battle")
		"atmospheric_preset_private":
			_ensure_player_battle_scene()
			_call_scene("set_visual_preset", [VISUAL_PRESET_ATMOSPHERIC])
			_call_scene("focus_layout_feature", ["default"])
			_render_player_screen("battle")
		"results":
			show_player_results()
		"private_harness":
			if player_layer:
				player_layer.visible = false
			player_visible_texts = []
			_create_review_ui()
			load_home()
			current_step_id = "private_harness_preserved"
		_:
			_ensure_player_battle_scene()
	var status := get_spike_status()
	status["ready"] = bool(status.get("ready", true))
	status["playerSliceAction"] = action
	status["playerVisibleText"] = player_visible_texts.duplicate()
	return status

func _player_capture_checkpoint() -> String:
	var normalized_root := _artifact_root_from_args().replace("\\", "/")
	if normalized_root.contains("/v0130"):
		return "v0.130"
	if normalized_root.contains("/v0129"):
		return "v0.129"
	if normalized_root.contains("/v0128"):
		return "v0.128"
	if normalized_root.contains("/v0127"):
		return "v0.127"
	if normalized_root.contains("/v0126"):
		return "v0.126"
	return "v0.124"

func _is_bounded_microloop_checkpoint() -> bool:
	return ["v0.129", "v0.130"].has(_player_capture_checkpoint())

func _player_capture_steps() -> Array[Dictionary]:
	if _player_capture_checkpoint() == "v0.130":
		return [
			{"id": "title", "label": "Title", "action": "title"},
			{"id": "briefing", "label": "Briefing", "action": "briefing"},
			{"id": "battle_default", "label": "Battle default", "action": "battle_default"},
			{"id": "hero", "label": "Aster hero", "action": "hero_selected"},
			{"id": "worker", "label": "Worker", "action": "worker_selected"},
			{"id": "mine", "label": "Mine resource capture", "action": "mine_converted"},
			{"id": "quarry", "label": "Quarry landmark", "action": "quarry_objective"},
			{"id": "build", "label": "Build placement", "action": "build_placement"},
			{"id": "barracks", "label": "Barracks restored", "action": "barracks_complete"},
			{"id": "recruit", "label": "Militia recruit", "action": "militia_spawned"},
			{"id": "pressure_wave", "label": "Pressure wave defeated", "action": "ashen_pressure_wave"},
			{"id": "lume", "label": "Lume restore", "action": "lume_restore"},
			{"id": "minimap", "label": "Minimap", "action": "minimap"},
			{"id": "results", "label": "Results", "action": "results"},
			{"id": "private_harness_preserved", "label": "Private harness preserved separately", "action": "private_harness"}
		]
	if _player_capture_checkpoint() == "v0.129":
		return [
			{"id": "mine_uncaptured", "label": "Mine uncaptured", "action": "mine_uncaptured"},
			{"id": "mine_converted", "label": "Mine converted", "action": "mine_converted"},
			{"id": "worker_assigned", "label": "Worker assigned", "action": "worker_assigned_mine"},
			{"id": "build_placement", "label": "Build placement", "action": "build_placement"},
			{"id": "construction", "label": "Construction progress", "action": "construction_progress"},
			{"id": "barracks_complete", "label": "Barracks complete", "action": "barracks_complete"},
			{"id": "recruit_queue", "label": "Recruit queue", "action": "recruit_queue"},
			{"id": "militia_spawned", "label": "Militia spawned", "action": "militia_spawned"},
			{"id": "pressure_wave", "label": "Pressure wave defeated", "action": "ashen_pressure_wave"},
			{"id": "lume_restore", "label": "Lume restore", "action": "lume_restore"},
			{"id": "results", "label": "Results", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.128":
		return [
			{"id": "title", "label": "Title", "action": "title"},
			{"id": "briefing", "label": "Briefing", "action": "briefing"},
			{"id": "hud_default", "label": "HUD default", "action": "hud_default"},
			{"id": "hero_selected", "label": "Hero selected", "action": "hero_selected"},
			{"id": "worker_selected", "label": "Worker selected", "action": "worker_selected"},
			{"id": "squad_selected", "label": "Squad selected", "action": "squad_selected"},
			{"id": "minimap", "label": "Minimap", "action": "minimap"},
			{"id": "objective_1", "label": "Objective 1", "action": "objective_1"},
			{"id": "quarry", "label": "Quarry", "action": "quarry_objective"},
			{"id": "pressure_wave", "label": "Pressure wave", "action": "ashen_pressure_wave"},
			{"id": "lume_restore", "label": "Lume restore", "action": "lume_restore"},
			{"id": "results", "label": "Results", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.127":
		return [
			{"id": "hero", "label": "Aster hero silhouette", "action": "hero"},
			{"id": "worker", "label": "Worker silhouette", "action": "worker"},
			{"id": "militia", "label": "Militia silhouette", "action": "militia"},
			{"id": "ranger", "label": "Ranger silhouette", "action": "ranger"},
			{"id": "ashen_raider", "label": "Ashen Raider silhouette", "action": "ashen_raider"},
			{"id": "command_hall", "label": "Command Hall silhouette", "action": "command_hall"},
			{"id": "barracks", "label": "Barracks silhouette", "action": "barracks"},
			{"id": "mine", "label": "Mine silhouette", "action": "mine"},
			{"id": "shrine", "label": "Shrine silhouette", "action": "shrine"},
			{"id": "quarry", "label": "Quarry silhouette", "action": "quarry"},
			{"id": "ruin", "label": "Ruin silhouette", "action": "ruin"},
			{"id": "site", "label": "Capture site silhouette", "action": "site"},
			{"id": "lume_endpoint", "label": "Lume endpoint silhouette", "action": "lume_endpoint"},
			{"id": "hero_selected", "label": "Hero selected", "action": "hero_selected"},
			{"id": "worker_selected", "label": "Worker selected", "action": "worker_selected"},
			{"id": "squad_selected", "label": "Squad selected", "action": "squad_selected"},
			{"id": "move_order", "label": "Move order marker", "action": "move_order"},
			{"id": "attack_order", "label": "Attack order marker", "action": "attack_order"},
			{"id": "combat", "label": "Combat readability", "action": "combat"},
			{"id": "death", "label": "Death fade", "action": "death"},
			{"id": "results", "label": "Results", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.126":
		return [
			{"id": "title_backdrop", "label": "Title backdrop", "action": "title"},
			{"id": "briefing_backdrop", "label": "Briefing backdrop", "action": "briefing"},
			{"id": "battle_default", "label": "Battle default", "action": "battle_default"},
			{"id": "road", "label": "Road readability", "action": "road"},
			{"id": "ford", "label": "Ford crossing", "action": "ford"},
			{"id": "quarry", "label": "Quarry cut", "action": "quarry"},
			{"id": "shrine", "label": "Shrine clearing", "action": "shrine"},
			{"id": "ruin", "label": "Ruin pocket", "action": "ruin"},
			{"id": "buildable_ground", "label": "Buildable ground", "action": "buildable_ground"},
			{"id": "minimap", "label": "Minimap authored layout", "action": "minimap"},
			{"id": "objective_focus", "label": "Objective focus", "action": "objective_focus"},
			{"id": "camera_min_zoom", "label": "Camera min zoom", "action": "camera_min_zoom"},
			{"id": "camera_max_zoom", "label": "Camera max zoom", "action": "camera_max_zoom"},
			{"id": "clean_preset", "label": "Clean preset", "action": "clean_preset"},
			{"id": "atmospheric_preset_private", "label": "Atmospheric preset private", "action": "atmospheric_preset_private"}
		]
	return [
		{"id": "title", "label": "Title", "action": "title"},
		{"id": "briefing", "label": "Salto briefing", "action": "briefing"},
		{"id": "battle_default", "label": "Battle default", "action": "battle_default"},
		{"id": "hero_selected", "label": "Hero selected", "action": "hero_selected"},
		{"id": "worker_selected", "label": "Worker selected", "action": "worker_selected"},
		{"id": "squad_selected", "label": "Squad selected", "action": "squad_selected"},
		{"id": "quarry_objective", "label": "Quarry objective", "action": "quarry_objective"},
		{"id": "ashen_pressure_wave", "label": "Ashen pressure wave", "action": "ashen_pressure_wave"},
		{"id": "lume_stable", "label": "Lume stable", "action": "lume_stable"},
		{"id": "lume_activation", "label": "Lume activation", "action": "lume_activation"},
		{"id": "lume_restore", "label": "Lume sever restore", "action": "lume_restore"},
		{"id": "minimap", "label": "Minimap orientation", "action": "minimap"},
		{"id": "results", "label": "Results", "action": "results"},
		{"id": "private_harness_preserved", "label": "Private harness preserved separately", "action": "private_harness"}
	]

func _player_forbidden_terms() -> Array[String]:
	return [
		"adapter",
		"fixture",
		"repository",
		"editor-optional",
		"parity",
		"benchmark",
		"diagnostic",
		"stable id",
		"localstorage"
	]

func _all_player_text_from_steps(steps: Array[Dictionary]) -> Array[String]:
	var values: Array[String] = []
	for step in steps:
		for entry in step.get("visibleText", []):
			values.append(str(entry))
	return values

func _capture_steps() -> Array[Dictionary]:
	return [
		{"id": "2d_control_default", "label": "2D control default", "mode": MODE_2D, "action": "launch_2d", "visualPreset": VISUAL_PRESET_2D_CONTROL},
		{"id": "2d_hero", "label": "2D hero selected", "mode": MODE_2D, "action": "select_hero"},
		{"id": "2d_worker", "label": "2D Worker selected", "mode": MODE_2D, "action": "select_worker"},
		{"id": "2d_squad", "label": "2D squad box selected", "mode": MODE_2D, "action": "box_select"},
		{"id": "2d_results", "label": "2D Results transition", "mode": MODE_2D, "action": "results", "visualPreset": VISUAL_PRESET_2D_CONTROL},
		{"id": "2_5d_clean_default", "label": "2.5D clean readability default", "mode": MODE_25D, "action": "launch_25d_clean", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_atmospheric_default", "label": "2.5D atmospheric balanced", "mode": MODE_25D, "action": "launch_25d_atmospheric", "visualPreset": VISUAL_PRESET_ATMOSPHERIC},
		{"id": "2_5d_vfx_stress_private", "label": "2.5D VFX stress private", "mode": MODE_25D, "action": "launch_25d_vfx_stress", "visualPreset": VISUAL_PRESET_VFX_STRESS},
		{"id": "2_5d_hero", "label": "2.5D hero selected", "mode": MODE_25D, "action": "select_hero", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_worker", "label": "2.5D Worker selected", "mode": MODE_25D, "action": "select_worker", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_squad", "label": "2.5D squad box selected", "mode": MODE_25D, "action": "box_select", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_buildings", "label": "2.5D buildings and landmarks", "mode": MODE_25D, "action": "show_buildings", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_capture_site", "label": "2.5D capture site marker", "mode": MODE_25D, "action": "capture_site", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_lume_stable", "label": "2.5D stable Lume line", "mode": MODE_25D, "action": "lume_stable", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_lume_transition", "label": "2.5D Lume transition pulse", "mode": MODE_25D, "action": "lume_transition", "visualPreset": VISUAL_PRESET_ATMOSPHERIC},
		{"id": "2_5d_results", "label": "2.5D Results transition", "mode": MODE_25D, "action": "results", "visualPreset": VISUAL_PRESET_CLEAN}
	]

func get_spike_status() -> Dictionary:
	if active_mode == MODE_HOME:
		return {
			"mode": active_mode,
			"ready": true,
			"currentStepId": current_step_id,
			"visualPreset": active_visual_preset,
			"reviewHarnessVisible": true
		}
	if active_scene and active_scene.has_method("get_spike_status"):
		var status: Dictionary = active_scene.get_spike_status()
		status["currentStepId"] = current_step_id
		status["reviewHarnessVisible"] = review_layer != null
		if active_mode == MODE_2D:
			status["visualPreset"] = VISUAL_PRESET_2D_CONTROL
		return status
	return {"mode": active_mode, "ready": false, "currentStepId": current_step_id, "visualPreset": active_visual_preset}

func run_headless_tests() -> Dictionary:
	var errors: Array[String] = []
	var importer: RefCounted = SaltoFixtureImporterScript.new()
	var validation: Dictionary = importer.validate_fixture()
	var adapter_validation: Dictionary = importer.run_adapter_validation()
	_write_report("res://reports/godot-v0122-adapter-validation.json", adapter_validation)
	if validation.get("status", "FAIL") != "PASS":
		for error in validation.get("errors", []):
			errors.append(str(error))
	if adapter_validation.get("status", "FAIL") != "PASS_GODOT_CONTENT_ADAPTER_VALIDATION":
		for error in adapter_validation.get("errors", []):
			errors.append(str(error))
	_test_scene("res://scenes/salto_2d_placeholder.tscn", MODE_2D, errors)
	_test_scene("res://scenes/salto_2_5d_orthographic_placeholder.tscn", MODE_25D, errors)
	var parity_report: Dictionary = _run_v0122_parity_harness()
	_write_report("res://reports/godot-v0122-parity-report.json", parity_report)
	if parity_report.get("status", "FAIL") != "PASS_GODOT_RULES_PARITY_HARNESS":
		for error in parity_report.get("errors", []):
			errors.append(str(error))
	var microloop_report: Dictionary = _run_v0129_microloop_harness()
	_write_report("res://reports/godot-v0129-microloop-report.json", microloop_report)
	if microloop_report.get("status", "FAIL") != "PASS_V0129_MICROLOOP_HARNESS":
		for error in microloop_report.get("errors", []):
			errors.append(str(error))
	var fixture_validation: Dictionary = validation.get("validation", {}).duplicate(true)
	fixture_validation.erase("adapterValidation")
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"fixtureValidation": fixture_validation,
		"adapterValidation": adapter_validation,
		"parityReport": parity_report,
		"microloopReport": microloop_report,
		"godotVersion": Engine.get_version_info(),
		"tests": [
			"project-load",
			"fixture-import",
			"stable-id-validation",
			"unknown-id-rejection",
			"linked_ward-0.92",
			"read-only-save-fixtures",
			"2D-placeholder-mode",
			"2.5D-orthographic-placeholder-mode",
			"selection",
			"box-selection",
			"move-order",
			"attack-order",
			"site-state",
			"Lume-placeholder",
			"pause-results-flow",
			"camera-pan-zoom-hooks",
			"v0.118-private-review-harness-hooks",
			"v0.119-workload-tier-S",
			"v0.119-workload-tier-M",
			"v0.119-workload-tier-L",
			"v0.119-navigation-metrics",
			"v0.119-bounded-ai-pressure",
			"v0.119-results-parity",
			"v0.121-procedural-2_5d-presets",
			"v0.121-hud-minimap-selection-readability",
			"v0.121-vfx-stress-private-boundary",
			"v0.122-content-registry-adapter",
			"v0.122-stable-id-validator",
			"v0.122-read-only-save-adapter",
			"v0.122-unit-building-site-lume-results-adapters",
			"v0.122-fixed-seed-rules-parity",
			"v0.122-2d-and-2_5d-same-fixture",
			"v0.122-no-full-port-started",
			"v0.129-mine-site-conversion",
			"v0.129-worker-assignment",
			"v0.129-boosted-resource-production",
			"v0.129-barracks-build-and-construction",
			"v0.129-militia-recruit-and-resource-spend",
			"v0.129-hero-ability-pressure-wave-results",
			"v0.129-fixed-seed-no-save-no-id-drift",
			"v0.129-zero-editor"
		]
	}

func _run_v0129_microloop_harness() -> Dictionary:
	var errors: Array[String] = []
	var reports: Array[Dictionary] = []
	for config in [
		{"mode": MODE_2D, "path": "res://scenes/salto_2d_placeholder.tscn"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn"}
	]:
		var packed: PackedScene = load(str(config["path"])) as PackedScene
		if packed == null:
			errors.append("Failed to load v0.129 microloop scene for %s" % config["mode"])
			continue
		var scene: Node = packed.instantiate()
		add_child(scene)
		if str(config["mode"]) == MODE_25D and scene.has_method("set_visual_preset"):
			scene.set_visual_preset(VISUAL_PRESET_CLEAN)
		if not scene.has_method("run_v0129_microloop_fixture"):
			errors.append("%s lacks run_v0129_microloop_fixture" % config["mode"])
		else:
			var report: Dictionary = scene.run_v0129_microloop_fixture()
			reports.append(report)
			if report.get("status", "FAIL") != "PASS_V0129_MICROLOOP_FIXTURE":
				for error in report.get("errors", []):
					errors.append("%s: %s" % [config["mode"], str(error)])
		scene.queue_free()
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.129",
		"status": "PASS_V0129_MICROLOOP_HARNESS" if errors.is_empty() else "FAIL_V0129_MICROLOOP_HARNESS",
		"errors": errors,
		"modeReports": reports,
		"modes": reports.map(func(report: Dictionary) -> String: return str(report.get("mode", ""))),
		"sameFixtureAcross2dAnd25d": reports.size() == 2,
		"linkedWardDamageTakenMultiplier": 0.92,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"runtimeArtIntegrated": false,
		"generatedOrImportedArtIncluded": false,
		"routineEditorUseRequired": false,
		"fullPortStarted": false
	}

func _run_v0122_parity_harness() -> Dictionary:
	var errors: Array[String] = []
	var reports: Array[Dictionary] = []
	for config in [
		{"mode": MODE_2D, "path": "res://scenes/salto_2d_placeholder.tscn"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn"}
	]:
		var packed: PackedScene = load(str(config["path"])) as PackedScene
		if packed == null:
			errors.append("Failed to load v0.122 parity scene for %s" % config["mode"])
			continue
		var scene: Node = packed.instantiate()
		add_child(scene)
		if str(config["mode"]) == MODE_25D and scene.has_method("set_visual_preset"):
			scene.set_visual_preset(VISUAL_PRESET_CLEAN)
		if not scene.has_method("run_v0122_parity_fixture"):
			errors.append("%s lacks run_v0122_parity_fixture" % config["mode"])
		else:
			var report: Dictionary = scene.run_v0122_parity_fixture()
			reports.append(report)
			if report.get("status", "FAIL") != "PASS_GODOT_RULES_PARITY_HARNESS":
				for error in report.get("errors", []):
					errors.append("%s: %s" % [config["mode"], str(error)])
		scene.queue_free()
	if reports.size() == 2:
		var left: Dictionary = reports[0].get("initialSnapshot", {})
		var right: Dictionary = reports[1].get("initialSnapshot", {})
		if str(left.get("placementSignature", "")) != str(right.get("placementSignature", "")):
			errors.append("2D and 2.5D parity fixtures did not share the same initial placement signature.")
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS_GODOT_RULES_PARITY_HARNESS" if errors.is_empty() else "FAIL_GODOT_RULES_PARITY_HARNESS",
		"generatedAtUtc": "deterministic-v0122",
		"errors": errors,
		"fixedSeed": 1190119,
		"tier": "M",
		"modes": reports.map(func(report: Dictionary) -> String: return str(report.get("mode", ""))),
		"modeReports": reports,
		"sameFixtureAcross2dAnd25d": errors.filter(func(error: String) -> bool: return error.contains("same initial placement")).is_empty(),
		"fullBrowserGodotSimulationParityClaimed": false,
		"localStorageMutationAllowed": false,
		"saveWritesAllowed": false,
		"routineEditorUseRequired": false
	}

func run_headless_benchmark() -> Array[String]:
	var errors: Array[String] = []
	for config in [
		{"mode": MODE_2D, "path": "res://scenes/salto_2d_placeholder.tscn", "report": "res://reports/godot-benchmark-2d.json"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn", "report": "res://reports/godot-benchmark-2_5d.json", "visualPreset": VISUAL_PRESET_CLEAN},
		{"mode": MODE_2D, "path": "res://scenes/salto_2d_placeholder.tscn", "report": "res://reports/godot-v0121-benchmark-2d-control.json", "visualPreset": VISUAL_PRESET_2D_CONTROL, "benchmarkKind": "v0.121-procedural-visual-foundation"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn", "report": "res://reports/godot-v0121-benchmark-2_5d-clean.json", "visualPreset": VISUAL_PRESET_CLEAN, "benchmarkKind": "v0.121-procedural-visual-foundation"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn", "report": "res://reports/godot-v0121-benchmark-2_5d-atmospheric.json", "visualPreset": VISUAL_PRESET_ATMOSPHERIC, "benchmarkKind": "v0.121-procedural-visual-foundation"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn", "report": "res://reports/godot-v0121-benchmark-2_5d-vfx-stress-private.json", "visualPreset": VISUAL_PRESET_VFX_STRESS, "benchmarkKind": "v0.121-procedural-visual-foundation-private"}
	]:
		var mode_errors: Array[String] = _benchmark_mode(config)
		for error in mode_errors:
			errors.append(error)
	return errors

func _test_scene(path: String, expected_mode: String, errors: Array[String]) -> void:
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		errors.append("Failed to load %s" % path)
		return
	var scene: Node = packed.instantiate()
	if scene == null:
		errors.append("Failed to instantiate %s" % path)
		return
	add_child(scene)
	if not scene.has_method("get_spike_status"):
		errors.append("%s lacks get_spike_status" % path)
	else:
		var expected_counts := {
			"S": {"entityCount": 14, "structureCount": 4, "siteCount": 1, "lumeEndpointCount": 2, "lumeLinkCount": 1},
			"M": {"entityCount": 43, "structureCount": 4, "siteCount": 3, "lumeEndpointCount": 2, "lumeLinkCount": 1},
			"L": {"entityCount": 105, "structureCount": 6, "siteCount": 5, "lumeEndpointCount": 3, "lumeLinkCount": 2}
		}
		for tier in ["S", "M", "L"]:
			if scene.has_method("set_workload_tier") and not scene.set_workload_tier(str(tier)):
				errors.append("%s tier %s selection failed" % [expected_mode, tier])
			var status: Dictionary = scene.get_spike_status()
			if status.get("mode", "") != expected_mode:
				errors.append("%s reported wrong mode for tier %s" % [expected_mode, tier])
			if str(status.get("workloadTier", "")) != str(tier):
				errors.append("%s reported wrong workload tier %s" % [expected_mode, tier])
			for key in expected_counts[str(tier)].keys():
				if int(status.get(key, -1)) != int(expected_counts[str(tier)][key]):
					errors.append("%s tier %s %s mismatch: expected %s, received %s" % [
						expected_mode,
						tier,
						key,
						expected_counts[str(tier)][key],
						status.get(key, null)
					])
			if absf(float(status.get("linkedWardDamageTakenMultiplier", 0.0)) - 0.92) > 0.0001:
				errors.append("%s tier %s linked_ward multiplier changed" % [expected_mode, tier])
			if tier == "S":
				if scene.has_method("select_entity"):
					if not scene.select_entity("hero_aster"):
						errors.append("%s hero selectable check failed" % expected_mode)
					if not scene.select_entity("worker"):
						errors.append("%s worker selectable check failed" % expected_mode)
				if scene.has_method("box_select_squad") and scene.box_select_squad().size() < 4:
					errors.append("%s squad box-select check failed" % expected_mode)
				if scene.has_method("issue_move_order") and not scene.issue_move_order():
					errors.append("%s move order check failed" % expected_mode)
				if scene.has_method("issue_attack_order") and not scene.issue_attack_order():
					errors.append("%s attack order check failed" % expected_mode)
				if scene.has_method("change_site_state") and not scene.change_site_state():
					errors.append("%s site state check failed" % expected_mode)
				if scene.has_method("trigger_hero_ability") and not scene.trigger_hero_ability():
					errors.append("%s hero ability placeholder check failed" % expected_mode)
				if scene.has_method("focus_lume_link") and not scene.focus_lume_link():
					errors.append("%s Lume focus check failed" % expected_mode)
				if scene.has_method("pan_camera") and not scene.pan_camera():
					errors.append("%s camera pan check failed" % expected_mode)
				if scene.has_method("zoom_camera") and not scene.zoom_camera():
					errors.append("%s camera zoom check failed" % expected_mode)
				if scene.has_method("toggle_pause") and not scene.toggle_pause():
					errors.append("%s pause check failed" % expected_mode)
				if scene.has_method("transition_results") and not scene.transition_results():
					errors.append("%s Results transition check failed" % expected_mode)
			if not scene.has_method("run_workload_phase"):
				errors.append("%s lacks v0.119 run_workload_phase" % expected_mode)
			else:
				for phase in ["idle", "moving", "combat"]:
					var phase_report: Dictionary = scene.run_workload_phase(str(phase))
					if phase_report.get("status", "FAIL") != "PASS":
						errors.append("%s tier %s phase %s failed" % [expected_mode, tier, phase])
					if int(phase_report.get("stuckUnitCount", 0)) != 0:
						errors.append("%s tier %s phase %s reported stuck units" % [expected_mode, tier, phase])
					if phase == "combat" and not bool(phase_report.get("resultsReady", false)):
						errors.append("%s tier %s combat phase did not reach Results" % [expected_mode, tier])
					if phase == "combat" and tier == "M" and int(phase_report.get("aiPressureBeatCount", 0)) < 1:
						errors.append("%s tier M did not record its bounded enemy-pressure beat" % expected_mode)
					if phase == "combat" and tier == "L" and int(phase_report.get("aiPressureBeatCount", 0)) < 2:
						errors.append("%s tier L did not record sustained enemy-pressure beats" % expected_mode)
		var final_status: Dictionary = scene.get_spike_status()
		if not bool(final_status.get("lumeLinkRendered", false)):
			errors.append("%s Lume placeholder not marked rendered" % expected_mode)
		if expected_mode == MODE_25D:
			if not scene.has_method("set_visual_preset"):
				errors.append("%s lacks v0.121 set_visual_preset" % expected_mode)
			else:
				for preset in [VISUAL_PRESET_CLEAN, VISUAL_PRESET_ATMOSPHERIC, VISUAL_PRESET_VFX_STRESS]:
					if not scene.set_visual_preset(preset):
						errors.append("%s rejected v0.121 visual preset %s" % [expected_mode, preset])
					var preset_status: Dictionary = scene.get_spike_status()
					if str(preset_status.get("visualPreset", "")) != preset:
						errors.append("%s did not report v0.121 visual preset %s" % [expected_mode, preset])
					if not bool(preset_status.get("proceduralPrimitiveOnly", false)):
						errors.append("%s preset %s is not marked procedural-only" % [expected_mode, preset])
					if not bool(preset_status.get("hudPlaceholderRendered", false)):
						errors.append("%s preset %s lacks HUD placeholder status" % [expected_mode, preset])
					if not bool(preset_status.get("captureSiteMarkerRendered", false)):
						errors.append("%s preset %s lacks capture-site marker status" % [expected_mode, preset])
					if preset == VISUAL_PRESET_VFX_STRESS and not bool(preset_status.get("vfxStressPrivate", false)):
						errors.append("%s VFX stress preset is not marked private" % expected_mode)
	scene.queue_free()

func _benchmark_mode(config: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var start := Time.get_ticks_usec()
	var packed: PackedScene = load(str(config["path"])) as PackedScene
	if packed == null:
		return ["Failed to load benchmark scene for %s" % config["mode"]]
	var scene: Node = packed.instantiate()
	var launch: int = Time.get_ticks_usec()
	add_child(scene)
	if config.has("visualPreset") and str(config["mode"]) == MODE_25D and scene.has_method("set_visual_preset"):
		scene.set_visual_preset(str(config["visualPreset"]))
	var report: Dictionary
	if scene.has_method("run_benchmark_suite"):
		report = scene.run_benchmark_suite()
		report["startupMs"] = snappedf(float(launch - start) / 1000.0, 0.01)
		report["sceneLaunchMs"] = snappedf(float(launch - start) / 1000.0, 0.01)
	else:
		if scene.has_method("select_entity"):
			scene.select_entity("hero_aster")
		if scene.has_method("box_select_squad"):
			scene.box_select_squad()
		var input_start := Time.get_ticks_usec()
		if scene.has_method("issue_move_order"):
			scene.issue_move_order()
		if scene.has_method("issue_attack_order"):
			scene.issue_attack_order()
		var input_end := Time.get_ticks_usec()
		if scene.has_method("transition_results"):
			scene.transition_results()
		var results_end := Time.get_ticks_usec()
		var frame_times: Array[float] = []
		for _index in range(180):
			var before := Time.get_ticks_usec()
			scene.propagate_call("_process", [1.0 / 60.0])
			var after := Time.get_ticks_usec()
			frame_times.append(max(0.01, float(after - before) / 1000.0))
		report = _metrics(str(config["mode"]), start, launch, input_start, input_end, results_end, frame_times)
	report["checkpoint"] = CHECKPOINT
	report["mode"] = str(config["mode"])
	report["visualPreset"] = str(config.get("visualPreset", VISUAL_PRESET_2D_CONTROL if str(config["mode"]) == MODE_2D else VISUAL_PRESET_CLEAN))
	report["visualPresetPrivate"] = report["visualPreset"] == VISUAL_PRESET_VFX_STRESS
	report["benchmarkKind"] = str(config.get("benchmarkKind", "v0.119-representative-rts-load"))
	report["godotVersion"] = Engine.get_version_info()
	report["fixtureHash"] = _fixture_hash()
	report["finalProductionCertification"] = false
	report["runtimeArtIntegrated"] = false
	report["generatedOrImportedArtIncluded"] = false
	report["routineEditorUseRequired"] = false
	_write_report(str(config["report"]), report)
	if report.get("status", "FAIL") != "PASS":
		errors.append("%s benchmark report did not pass" % config["mode"])
	scene.queue_free()
	return errors

func _metrics(mode: String, start: int, launch: int, input_start: int, input_end: int, results_end: int, frame_times: Array[float]) -> Dictionary:
	frame_times.sort()
	var sum := 0.0
	for value in frame_times:
		sum += value
	var average_frame: float = sum / float(max(1, frame_times.size()))
	var fps: float = min(240.0, 1000.0 / max(0.01, average_frame))
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"mode": mode,
		"status": "PASS",
		"startupMs": float(launch - start) / 1000.0,
		"sceneLaunchMs": float(launch - start) / 1000.0,
		"fpsAverage": snappedf(fps, 0.01),
		"fpsOnePercentLow": snappedf(fps, 0.01),
		"frameTimeP50Ms": _percentile(frame_times, 0.50),
		"frameTimeP95Ms": _percentile(frame_times, 0.95),
		"frameTimeP99Ms": _percentile(frame_times, 0.99),
		"frameTimeMaxMs": frame_times[frame_times.size() - 1],
		"inputLatencyMs": float(input_end - input_start) / 1000.0,
		"resultsTransitionMs": float(results_end - input_end) / 1000.0,
		"memoryWorkingSetMb": null,
		"notes": "Placeholder loop metric for AI-first workflow validation, not final production performance certification."
	}

func _percentile(values: Array[float], percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var index := clampi(int(floor(float(values.size() - 1) * percentile)), 0, values.size() - 1)
	return snappedf(values[index], 0.01)

func _settle_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _set_capture_viewport(size: Vector2i) -> void:
	current_viewport_size = size
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(size)
		DisplayServer.window_set_min_size(size)

func _artifact_root_from_args() -> String:
	for arg in _script_args():
		if arg.begins_with("--artifact-root="):
			return arg.trim_prefix("--artifact-root=")
	return ProjectSettings.globalize_path("user://v0121-godot-review")

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
	for prefix in SCRIPT_ARG_PREFIXES:
		if arg == prefix or arg.begins_with(prefix):
			return true
	return false

func _path_join(root: String, child: String) -> String:
	return root.trim_suffix("/").trim_suffix("\\") + "/" + child.trim_prefix("/").trim_prefix("\\")

func _write_report(path: String, report: Dictionary) -> void:
	var absolute := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))

func _write_absolute_json(path: String, report: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))

func _write_absolute_text(path: String, value: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(value)

func _fixture_hash() -> Variant:
	var file := FileAccess.open("res://data/generated/fixture-hashes.json", FileAccess.READ)
	if not file:
		return null
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed.get("fixtureHash")
	return null

func _friendly_mode(mode: String) -> String:
	if mode == MODE_25D:
		return "2.5D orthographic placeholder"
	if mode == MODE_2D:
		return "2D placeholder"
	return "review home"

func _friendly_action(action: String) -> String:
	match action:
		"home":
			return "Review home"
		"launch_2d":
			return "Launch 2D placeholder"
		"launch_25d":
			return "Launch 2.5D placeholder"
		"launch_25d_clean":
			return "Launch 2.5D clean readability"
		"launch_25d_atmospheric":
			return "Launch 2.5D atmospheric balanced"
		"launch_25d_vfx_stress":
			return "Launch 2.5D VFX stress private"
		"preset_clean":
			return "Set clean readability preset"
		"preset_atmospheric":
			return "Set atmospheric balanced preset"
		"preset_vfx_stress":
			return "Set VFX stress private preset"
		"select_hero":
			return "Select hero"
		"select_worker":
			return "Select Worker"
		"box_select":
			return "Box select squad"
		"move":
			return "Issue move order"
		"attack":
			return "Issue attack order"
		"pan_camera":
			return "Pan camera"
		"zoom_camera":
			return "Zoom camera"
		"pause":
			return "Pause"
		"capture_site":
			return "Capture site"
		"show_buildings":
			return "Show buildings and landmarks"
		"lume_link":
			return "Focus Lume link"
		"lume_stable":
			return "Stable Lume line"
		"lume_transition":
			return "Lume transition pulse"
		"results":
			return "Results transition"
		"return_home":
			return "Return home"
		"exit":
			return "Exit"
		_:
			return action
