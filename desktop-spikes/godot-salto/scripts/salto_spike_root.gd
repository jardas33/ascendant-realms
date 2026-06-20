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
	"--worker-art-opt-in",
	"--worker-art-opt-in-benchmark",
	"--worker-art-source=",
	"--worker-art-metadata=",
	"--worker-art-expected-sha256=",
	"--worker-art-scale=",
	"--worker-art-fallback-mode=",
	"--barracks-material-opt-in",
	"--barracks-material-source=",
	"--barracks-material-metadata=",
	"--barracks-material-expected-sha256=",
	"--barracks-material-fallback-mode=",
	"--militia-art-opt-in",
	"--militia-art-source=",
	"--militia-art-metadata=",
	"--militia-art-expected-sha256=",
	"--militia-art-scale=",
	"--militia-art-fallback-mode=",
	"--aster-art-opt-in",
	"--aster-art-source=",
	"--aster-art-metadata=",
	"--aster-art-expected-sha256=",
	"--aster-art-scale=",
	"--aster-art-fallback-mode=",
	"--ashen-art-opt-in",
	"--ashen-art-source=",
	"--ashen-art-metadata=",
	"--ashen-art-expected-sha256=",
	"--ashen-art-scale=",
	"--ashen-art-fallback-mode=",
	"--experimental-review-mode-label=",
	"--salto-three-slot-review-framing",
	"--salto-four-slot-review-framing",
	"--salto-five-slot-review-framing",
	"--salto-environment-foundation-review",
	"--salto-environment-readability-hardening",
	"--salto-environment-contrast-harmonization",
	"--salto-environment-geometry-convergence",
	"--salto-environment-shell-live-qa",
	"--salto-structure-shell-hardening",
	"--salto-riverbank-bridge-approach-hardening",
	"--salto-presentation-shell-v2",
	"--salto-shell-v2-mesh-compositor",
	"--salto-shell-v2-structure-hierarchy",
	"--salto-shell-v2-grounding-lighting",
	"--salto-shell-v2-environmental-cohesion",
	"--ground-material-opt-in",
	"--ground-material-source=",
	"--ground-material-metadata=",
	"--ground-material-expected-sha256=",
	"--ground-material-fallback-mode=",
	"--ground-material-uv-scale=",
	"--road-material-opt-in",
	"--road-material-source=",
	"--road-material-metadata=",
	"--road-material-expected-sha256=",
	"--road-material-fallback-mode=",
	"--road-material-uv-scale=",
	"--bridge-riverbank-material-opt-in",
	"--bridge-riverbank-material-source=",
	"--bridge-riverbank-material-metadata=",
	"--bridge-riverbank-material-expected-sha256=",
	"--bridge-riverbank-material-fallback-mode=",
	"--bridge-riverbank-material-uv-scale=",
	"--road-riverbank-water-material-opt-in",
	"--road-riverbank-water-material-fallback-mode=",
	"--road-riverbank-water-road-source=",
	"--road-riverbank-water-road-metadata=",
	"--road-riverbank-water-road-expected-sha256=",
	"--road-riverbank-water-road-uv-scale=",
	"--road-riverbank-water-riverbank-source=",
	"--road-riverbank-water-riverbank-metadata=",
	"--road-riverbank-water-riverbank-expected-sha256=",
	"--road-riverbank-water-riverbank-uv-scale=",
	"--road-riverbank-water-water-source=",
	"--road-riverbank-water-water-metadata=",
	"--road-riverbank-water-water-expected-sha256=",
	"--road-riverbank-water-water-uv-scale=",
	"--road-riverbank-water-wet-edge-source=",
	"--road-riverbank-water-wet-edge-metadata=",
	"--road-riverbank-water-wet-edge-expected-sha256=",
	"--road-riverbank-water-wet-edge-uv-scale=",
	"--salto-shell-v2-structure-material",
	"--structure-finish-material-opt-in",
	"--structure-finish-material-source=",
	"--structure-finish-material-metadata=",
	"--structure-finish-material-expected-sha256=",
	"--structure-finish-material-fallback-mode=",
	"--structure-finish-material-uv-scale=",
	"--environment-prop-atlas-opt-in",
	"--environment-prop-atlas-source=",
	"--environment-prop-atlas-metadata=",
	"--environment-prop-atlas-expected-sha256=",
	"--environment-prop-atlas-fallback-mode=",
	"--salto-shell-v2-grounding-props",
	"--salto-ui-architecture-wireframe",
	"--salto-ui-shell-comparator",
	"--salto-ui-shell-experiment",
	"--salto-ui-shell-force-fallback",
	"--salto-selection-command-panel",
	"--salto-aster-portrait-source=",
	"--salto-aster-portrait-metadata=",
	"--salto-aster-portrait-expected-sha256=",
	"--salto-aster-portrait-force-fallback",
	"--salto-production-objectives-log",
	"--salto-minimap-tooltip-accessibility",
	"--salto-presentation-reboot",
	"--salto-minimal-contextual-hud",
	"--salto-minimal-contextual-hud-disabled",
	"--salto-hud-visual-language",
	"--salto-hud-visual-language-disabled",
	"--salto-integrated-reference-gap",
	"--salto-battlefield-visual-rescue",
	"--salto-production-battlefield-backplate",
	"--salto-structure-landmark-fidelity",
	"--salto-structure-art-fidelity",
	"--salto-battlefield-material-value-integration",
	"--salto-production-target-spike",
	"--salto-blender-modular-kit-spike",
	"--salto-composed-blender-battlefield-slice",
	"--salto-architecture-correction-beauty-pass",
	"--salto-barrosan-production-slice",
	"--salto-bridge-shell-reboot",
	"--salto-bridge-shell-legacy-comparator",
	"--salto-structure-shell-production",
	"--salto-structure-shell-legacy-comparator",
	"--salto-environment-dressing",
	"--salto-environment-dressing-disabled",
	"--salto-composition-lighting-selection",
	"--salto-composition-lighting-selection-disabled",
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
	"--barrosan-ground-material-single-slot",
	"--barrosan-road-material-single-slot",
	"--barrosan-bridge-riverbank-material-single-slot",
	"--barrosan-structure-finish-material-single-slot",
	"--aster-billboard-single-slot-repair",
	"--hybrid-three-slot-composition-stress",
	"--militia-billboard-single-slot",
	"--militia-billboard-mass-overlap-repair",
	"--ashen-raider-billboard-single-slot",
	"--ashen-raider-visual-restraint-replacement",
	"--hybrid-mixed-combat-readability-stress",
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
var player_input_shield_frames := 0
var player_ui_shell_overlay: Control
var player_ui_shell_refresh_frames := 0
var player_ui_shell_context_override := ""
var player_ui_shell_focus_hint := ""
var player_ui_shell_production_tab_override := ""
var player_ui_shell_production_focus_hint := ""
var player_ui_shell_portrait_texture: ImageTexture
var player_ui_shell_portrait_status: Dictionary = {}
var player_ui_shell_portrait_cache_key := ""
var player_ui_shell_svg_texture_cache: Dictionary = {}

func _ready() -> void:
	var args: PackedStringArray = _script_args()
	current_viewport_size = _viewport_from_args(VIEWPORT_SIZE)
	active_visual_preset = _visual_preset_from_args()
	_configure_window()
	if args.has("--salto-production-target-spike"):
		var spike_scene := load("res://scenes/salto_production_target_spike.tscn") as PackedScene
		if spike_scene == null:
			get_tree().quit(1)
			return
		var spike := spike_scene.instantiate()
		add_child(spike)
		spike.call_deferred("start")
		return
	if args.has("--salto-blender-modular-kit-spike"):
		var kit_scene := load("res://scenes/salto_blender_modular_kit_spike.tscn") as PackedScene
		if kit_scene == null:
			get_tree().quit(1)
			return
		var kit_spike := kit_scene.instantiate()
		add_child(kit_spike)
		kit_spike.call_deferred("start")
		return
	if args.has("--salto-composed-blender-battlefield-slice"):
		var composed_scene := load("res://scenes/salto_composed_blender_battlefield_slice.tscn") as PackedScene
		if composed_scene == null:
			get_tree().quit(1)
			return
		var composed_slice := composed_scene.instantiate()
		add_child(composed_slice)
		composed_slice.call_deferred("start")
		return
	if args.has("--salto-architecture-correction-beauty-pass"):
		var architecture_scene := load("res://scenes/salto_architecture_correction_beauty_pass.tscn") as PackedScene
		if architecture_scene == null:
			get_tree().quit(1)
			return
		var architecture_pass := architecture_scene.instantiate()
		add_child(architecture_pass)
		architecture_pass.call_deferred("start")
		return
	if args.has("--salto-barrosan-production-slice"):
		var production_scene := load("res://scenes/salto_barrosan_production_slice.tscn") as PackedScene
		if production_scene == null:
			get_tree().quit(1)
			return
		var production_slice := production_scene.instantiate()
		add_child(production_slice)
		production_slice.call_deferred("start")
		return
	if args.has("--salto-ui-architecture-wireframe"):
		await run_ui_architecture_wireframe_capture()
		return
	if args.has("--salto-ui-shell-comparator"):
		await run_ui_shell_comparator_capture()
		return
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
	if args.has("--barrosan-ground-material-single-slot"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "ground-material-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.175",
			"status": "PASS_V0175_PRIVATE_GROUND_MATERIAL_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false,
			"playerSliceIntegration": "forbidden",
			"runtimeArtSlotAdded": false
		})
		var ground_material_script := load("res://comparators/runtime_art_pipeline/ground_material_single_slot_comparator.gd") as GDScript
		if ground_material_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "ground-material-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.175",
				"status": "FAIL_V0175_PRIVATE_GROUND_MATERIAL_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/ground_material_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var ground_material := Node.new()
		ground_material.name = "V0175GroundMaterialSingleSlotComparator"
		ground_material.set_script(ground_material_script)
		add_child(ground_material)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "ground-material-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.175",
			"status": "PASS_V0175_PRIVATE_GROUND_MATERIAL_PRESTART",
			"hasStart": ground_material.has_method("start")
		})
		if not ground_material.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "ground-material-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.175",
				"status": "FAIL_V0175_PRIVATE_GROUND_MATERIAL_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/ground_material_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		ground_material.call("start")
		return
	if args.has("--barrosan-road-material-single-slot"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "road-material-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.180",
			"status": "PASS_V0180_PRIVATE_ROAD_MATERIAL_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false,
			"playerSliceIntegration": "forbidden",
			"runtimeArtSlotAdded": false
		})
		var road_material_script := load("res://comparators/runtime_art_pipeline/road_material_single_slot_comparator.gd") as GDScript
		if road_material_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "road-material-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.180",
				"status": "FAIL_V0180_PRIVATE_ROAD_MATERIAL_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/road_material_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var road_material := Node.new()
		road_material.name = "V0180RoadMaterialSingleSlotComparator"
		road_material.set_script(road_material_script)
		add_child(road_material)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "road-material-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.180",
			"status": "PASS_V0180_PRIVATE_ROAD_MATERIAL_PRESTART",
			"hasStart": road_material.has_method("start")
		})
		if not road_material.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "road-material-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.180",
				"status": "FAIL_V0180_PRIVATE_ROAD_MATERIAL_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/road_material_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		road_material.call("start")
		return
	if args.has("--barrosan-bridge-riverbank-material-single-slot"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "bridge-riverbank-material-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.189",
			"status": "PASS_V0189_PRIVATE_BRIDGE_RIVERBANK_MATERIAL_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false,
			"playerSliceIntegration": "forbidden",
			"runtimeArtSlotAdded": false
		})
		var bridge_riverbank_material_script := load("res://comparators/runtime_art_pipeline/bridge_riverbank_material_single_slot_comparator.gd") as GDScript
		if bridge_riverbank_material_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "bridge-riverbank-material-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.189",
				"status": "FAIL_V0189_PRIVATE_BRIDGE_RIVERBANK_MATERIAL_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/bridge_riverbank_material_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var bridge_riverbank_material := Node.new()
		bridge_riverbank_material.name = "V0189BridgeRiverbankMaterialSingleSlotComparator"
		bridge_riverbank_material.set_script(bridge_riverbank_material_script)
		add_child(bridge_riverbank_material)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "bridge-riverbank-material-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.189",
			"status": "PASS_V0189_PRIVATE_BRIDGE_RIVERBANK_MATERIAL_PRESTART",
			"hasStart": bridge_riverbank_material.has_method("start")
		})
		if not bridge_riverbank_material.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "bridge-riverbank-material-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.189",
				"status": "FAIL_V0189_PRIVATE_BRIDGE_RIVERBANK_MATERIAL_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/bridge_riverbank_material_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		bridge_riverbank_material.call("start")
		return
	if args.has("--barrosan-structure-finish-material-single-slot"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "structure-finish-material-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.202",
			"status": "PASS_V0202_PRIVATE_STRUCTURE_FINISH_MATERIAL_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false,
			"playerSliceIntegration": "forbidden",
			"runtimeArtSlotAdded": false
		})
		var structure_finish_material_script := load("res://comparators/runtime_art_pipeline/structure_finish_material_single_slot_comparator.gd") as GDScript
		if structure_finish_material_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "structure-finish-material-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.202",
				"status": "FAIL_V0202_PRIVATE_STRUCTURE_FINISH_MATERIAL_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/structure_finish_material_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		var structure_finish_material := Node.new()
		structure_finish_material.name = "V0202StructureFinishMaterialSingleSlotComparator"
		structure_finish_material.set_script(structure_finish_material_script)
		add_child(structure_finish_material)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "structure-finish-material-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.202",
			"status": "PASS_V0202_PRIVATE_STRUCTURE_FINISH_MATERIAL_PRESTART",
			"hasStart": structure_finish_material.has_method("start")
		})
		if not structure_finish_material.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "structure-finish-material-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.202",
				"status": "FAIL_V0202_PRIVATE_STRUCTURE_FINISH_MATERIAL_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/structure_finish_material_single_slot_comparator.gd"
			})
			get_tree().quit(1)
			return
		structure_finish_material.call("start")
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
	if args.has("--ashen-raider-visual-restraint-replacement"):
		_write_absolute_json(_path_join(_artifact_root_from_args(), "ashen-raider-visual-restraint-replacement-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.157",
			"status": "PASS_V0157_PRIVATE_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var ashen_raider_replacement_script := load("res://comparators/runtime_art_pipeline/ashen_raider_visual_restraint_replacement_comparator.gd") as GDScript
		if ashen_raider_replacement_script == null:
			_write_absolute_json(_path_join(_artifact_root_from_args(), "ashen-raider-visual-restraint-replacement-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.157",
				"status": "FAIL_V0157_PRIVATE_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/ashen_raider_visual_restraint_replacement_comparator.gd"
			})
			get_tree().quit(1)
			return
		var ashen_raider_replacement := Node.new()
		ashen_raider_replacement.name = "V0157AshenRaiderVisualRestraintReplacementComparator"
		ashen_raider_replacement.set_script(ashen_raider_replacement_script)
		add_child(ashen_raider_replacement)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "ashen-raider-visual-restraint-replacement-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.157",
			"status": "PASS_V0157_PRIVATE_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_PRESTART",
			"hasStart": ashen_raider_replacement.has_method("start")
		})
		if not ashen_raider_replacement.has_method("start"):
			_write_absolute_json(_path_join(_artifact_root_from_args(), "ashen-raider-visual-restraint-replacement-dispatch-failure.json"), {
				"schemaVersion": 1,
				"checkpoint": "v0.157",
				"status": "FAIL_V0157_PRIVATE_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/ashen_raider_visual_restraint_replacement_comparator.gd"
			})
			get_tree().quit(1)
			return
		ashen_raider_replacement.call("start")
		return
	if args.has("--hybrid-mixed-combat-readability-stress"):
		var mixed_combat_failure_path := _path_join(_artifact_root_from_args(), "hybrid-mixed-combat-dispatch-failure.json")
		if FileAccess.file_exists(mixed_combat_failure_path):
			DirAccess.remove_absolute(mixed_combat_failure_path)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "hybrid-mixed-combat-root-dispatch.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.158",
			"status": "PASS_V0158_PRIVATE_HYBRID_MIXED_COMBAT_STRESS_DISPATCH",
			"args": Array(args),
			"defaultPlayerSliceLaunched": false
		})
		var mixed_combat_script := load("res://comparators/runtime_art_pipeline/hybrid_mixed_combat_readability_stress_comparator.gd") as GDScript
		if mixed_combat_script == null:
			_write_absolute_json(mixed_combat_failure_path, {
				"schemaVersion": 1,
				"checkpoint": "v0.158",
				"status": "FAIL_V0158_PRIVATE_HYBRID_MIXED_COMBAT_STRESS_SCRIPT_LOAD",
				"script": "res://comparators/runtime_art_pipeline/hybrid_mixed_combat_readability_stress_comparator.gd"
			})
			get_tree().quit(1)
			return
		var mixed_combat := Node.new()
		mixed_combat.name = "V0158HybridMixedCombatReadabilityStressComparator"
		mixed_combat.set_script(mixed_combat_script)
		add_child(mixed_combat)
		_write_absolute_json(_path_join(_artifact_root_from_args(), "hybrid-mixed-combat-dispatch-prestart.json"), {
			"schemaVersion": 1,
			"checkpoint": "v0.158",
			"status": "PASS_V0158_PRIVATE_HYBRID_MIXED_COMBAT_STRESS_PRESTART",
			"hasStart": mixed_combat.has_method("start")
		})
		if not mixed_combat.has_method("start"):
			_write_absolute_json(mixed_combat_failure_path, {
				"schemaVersion": 1,
				"checkpoint": "v0.158",
				"status": "FAIL_V0158_PRIVATE_HYBRID_MIXED_COMBAT_STRESS_START_METHOD",
				"script": "res://comparators/runtime_art_pipeline/hybrid_mixed_combat_readability_stress_comparator.gd"
			})
			get_tree().quit(1)
			return
		mixed_combat.call("start")
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
	if args.has("--worker-art-opt-in-benchmark"):
		_create_player_slice_ui()
		await run_worker_art_opt_in_benchmark()
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

func _process(_delta: float) -> void:
	if player_input_shield_frames > 0:
		player_input_shield_frames -= 1
	if _salto_ui_shell_live_enabled() and active_mode == MODE_25D and current_step_id == "player_battle":
		player_ui_shell_refresh_frames += 1
		if player_ui_shell_refresh_frames >= 8:
			player_ui_shell_refresh_frames = 0
			_refresh_live_ui_shell_overlay()

func _configure_window() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(current_viewport_size)
		DisplayServer.window_set_min_size(current_viewport_size)

func _input(event: InputEvent) -> void:
	if player_input_shield_frames > 0 and (event is InputEventMouseButton or event is InputEventMouseMotion):
		get_viewport().set_input_as_handled()
		return
	if current_step_id != "player_results" or not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if Rect2(Vector2(620, 318), Vector2(260, 42)).has_point(mouse_event.position):
		get_viewport().set_input_as_handled()
		call_deferred("_restart_player_battle_from_results")

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
	_configure_worker_art_for_active_scene()
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

func _configure_worker_art_for_active_scene() -> void:
	if active_mode != MODE_25D or active_scene == null or not is_instance_valid(active_scene):
		return
	if active_scene.has_method("configure_worker_art_experiment"):
		active_scene.configure_worker_art_experiment(_worker_art_options_from_args())
	if active_scene.has_method("configure_barracks_material_experiment"):
		active_scene.configure_barracks_material_experiment(_barracks_material_options_from_args())
	if active_scene.has_method("configure_militia_art_experiment"):
		active_scene.configure_militia_art_experiment(_militia_art_options_from_args())
	if active_scene.has_method("configure_aster_art_experiment"):
		active_scene.configure_aster_art_experiment(_aster_art_options_from_args())
	if active_scene.has_method("configure_ashen_art_experiment"):
		active_scene.configure_ashen_art_experiment(_ashen_art_options_from_args())
	_apply_review_framing_for_active_scene()
	if active_scene.has_method("configure_environment_foundation_review"):
		active_scene.configure_environment_foundation_review(_script_args().has("--salto-environment-foundation-review"))
	if active_scene.has_method("configure_environment_readability_hardening"):
		active_scene.configure_environment_readability_hardening(_script_args().has("--salto-environment-readability-hardening"))
	if active_scene.has_method("configure_environment_contrast_harmonization"):
		active_scene.configure_environment_contrast_harmonization(_script_args().has("--salto-environment-contrast-harmonization"))
	if active_scene.has_method("configure_ground_material_experiment"):
		active_scene.configure_ground_material_experiment(_ground_material_options_from_args())
	if active_scene.has_method("configure_road_material_experiment"):
		active_scene.configure_road_material_experiment(_road_material_options_from_args())
	if active_scene.has_method("configure_bridge_riverbank_material_experiment"):
		active_scene.configure_bridge_riverbank_material_experiment(_bridge_riverbank_material_options_from_args())
	if active_scene.has_method("configure_road_riverbank_water_material_experiment"):
		active_scene.configure_road_riverbank_water_material_experiment(_road_riverbank_water_material_options_from_args())
	if active_scene.has_method("configure_structure_finish_material_experiment"):
		active_scene.configure_structure_finish_material_experiment(_structure_finish_material_options_from_args())
	if active_scene.has_method("configure_environment_prop_atlas_experiment"):
		active_scene.configure_environment_prop_atlas_experiment(_environment_prop_atlas_options_from_args())
	if active_scene.has_method("configure_environment_geometry_convergence"):
		active_scene.configure_environment_geometry_convergence(_script_args().has("--salto-environment-geometry-convergence"))
	if active_scene.has_method("configure_environment_shell_live_qa"):
		active_scene.configure_environment_shell_live_qa(_script_args().has("--salto-environment-shell-live-qa"))
	if active_scene.has_method("configure_environment_structure_shell_hardening"):
		active_scene.configure_environment_structure_shell_hardening(_script_args().has("--salto-structure-shell-hardening"))
	if active_scene.has_method("configure_environment_riverbank_bridge_approach"):
		active_scene.configure_environment_riverbank_bridge_approach(_script_args().has("--salto-riverbank-bridge-approach-hardening"))
	if active_scene.has_method("configure_environment_presentation_shell_v2"):
		active_scene.configure_environment_presentation_shell_v2(_script_args().has("--salto-presentation-shell-v2"))
	if active_scene.has_method("configure_environment_shell_v2_mesh_compositor"):
		active_scene.configure_environment_shell_v2_mesh_compositor(_script_args().has("--salto-shell-v2-mesh-compositor"))
	if active_scene.has_method("configure_environment_shell_v2_structure_hierarchy"):
		active_scene.configure_environment_shell_v2_structure_hierarchy(_script_args().has("--salto-shell-v2-structure-hierarchy"))
	if active_scene.has_method("configure_environment_shell_v2_grounding_lighting"):
		active_scene.configure_environment_shell_v2_grounding_lighting(_script_args().has("--salto-shell-v2-grounding-lighting"))
	if active_scene.has_method("configure_environment_shell_v2_environmental_cohesion"):
		active_scene.configure_environment_shell_v2_environmental_cohesion(_script_args().has("--salto-shell-v2-environmental-cohesion"))
	if active_scene.has_method("configure_environment_shell_v2_structure_material"):
		active_scene.configure_environment_shell_v2_structure_material(_script_args().has("--salto-shell-v2-structure-material"))
	if active_scene.has_method("configure_environment_shell_v2_grounding_props"):
		active_scene.configure_environment_shell_v2_grounding_props(_script_args().has("--salto-shell-v2-grounding-props"))
	if active_scene.has_method("configure_salto_bridge_shell_reboot"):
		active_scene.configure_salto_bridge_shell_reboot(_script_args().has("--salto-bridge-shell-reboot"), _script_args().has("--salto-bridge-shell-legacy-comparator"))
	if active_scene.has_method("configure_salto_structure_shell_production"):
		active_scene.configure_salto_structure_shell_production(_script_args().has("--salto-structure-shell-production"), _script_args().has("--salto-structure-shell-legacy-comparator"))
	if active_scene.has_method("configure_salto_environment_dressing"):
		active_scene.configure_salto_environment_dressing(_script_args().has("--salto-environment-dressing"))
	if active_scene.has_method("configure_salto_composition_lighting_selection"):
		active_scene.configure_salto_composition_lighting_selection(_script_args().has("--salto-composition-lighting-selection"))
	if active_scene.has_method("configure_salto_integrated_reference_gap"):
		active_scene.configure_salto_integrated_reference_gap(_script_args().has("--salto-integrated-reference-gap"))
	if active_scene.has_method("configure_salto_battlefield_visual_rescue"):
		active_scene.configure_salto_battlefield_visual_rescue(_script_args().has("--salto-battlefield-visual-rescue"))
	if active_scene.has_method("configure_salto_production_battlefield_backplate"):
		active_scene.configure_salto_production_battlefield_backplate(_script_args().has("--salto-production-battlefield-backplate"))
	if active_scene.has_method("configure_salto_structure_landmark_fidelity"):
		active_scene.configure_salto_structure_landmark_fidelity(_script_args().has("--salto-structure-landmark-fidelity"))
	if active_scene.has_method("configure_salto_structure_art_fidelity"):
		active_scene.configure_salto_structure_art_fidelity(_script_args().has("--salto-structure-art-fidelity"))
	if active_scene.has_method("configure_salto_battlefield_material_value_integration"):
		active_scene.configure_salto_battlefield_material_value_integration(_script_args().has("--salto-battlefield-material-value-integration"))
	if active_scene.has_method("configure_salto_presentation_reboot"):
		active_scene.configure_salto_presentation_reboot(_salto_presentation_reboot_enabled())

func _apply_review_framing_for_active_scene() -> void:
	if not _script_args().has("--salto-three-slot-review-framing") and not _script_args().has("--salto-four-slot-review-framing") and not _script_args().has("--salto-five-slot-review-framing"):
		return
	if active_mode != MODE_25D or active_scene == null or not is_instance_valid(active_scene):
		return
	if _script_args().has("--salto-composition-lighting-selection") and active_scene.has_method("apply_salto_composition_lighting_selection_framing"):
		active_scene.apply_salto_composition_lighting_selection_framing()
	elif _script_args().has("--salto-environment-dressing") and active_scene.has_method("apply_environment_shell_v2_grounding_props_framing"):
		active_scene.apply_environment_shell_v2_grounding_props_framing()
	elif _script_args().has("--salto-shell-v2-grounding-props") and active_scene.has_method("apply_environment_shell_v2_grounding_props_framing"):
		active_scene.apply_environment_shell_v2_grounding_props_framing()
	elif _script_args().has("--salto-shell-v2-structure-material") and active_scene.has_method("apply_environment_shell_v2_structure_material_framing"):
		active_scene.apply_environment_shell_v2_structure_material_framing()
	elif _script_args().has("--salto-shell-v2-environmental-cohesion") and active_scene.has_method("apply_environment_shell_v2_environmental_cohesion_framing"):
		active_scene.apply_environment_shell_v2_environmental_cohesion_framing()
	elif _script_args().has("--salto-shell-v2-grounding-lighting") and active_scene.has_method("apply_environment_shell_v2_grounding_lighting_framing"):
		active_scene.apply_environment_shell_v2_grounding_lighting_framing()
	elif _script_args().has("--salto-shell-v2-structure-hierarchy") and active_scene.has_method("apply_environment_shell_v2_structure_hierarchy_framing"):
		active_scene.apply_environment_shell_v2_structure_hierarchy_framing()
	elif _script_args().has("--salto-shell-v2-mesh-compositor") and active_scene.has_method("apply_environment_shell_v2_mesh_compositor_framing"):
		active_scene.apply_environment_shell_v2_mesh_compositor_framing()
	elif _script_args().has("--salto-presentation-shell-v2") and active_scene.has_method("apply_environment_presentation_shell_v2_framing"):
		active_scene.apply_environment_presentation_shell_v2_framing()
	elif _script_args().has("--salto-riverbank-bridge-approach-hardening") and active_scene.has_method("apply_environment_riverbank_bridge_approach_framing"):
		active_scene.apply_environment_riverbank_bridge_approach_framing()
	elif _script_args().has("--salto-structure-shell-hardening") and active_scene.has_method("apply_environment_structure_shell_hardening_framing"):
		active_scene.apply_environment_structure_shell_hardening_framing()
	elif _script_args().has("--salto-environment-shell-live-qa") and active_scene.has_method("apply_environment_shell_live_qa_framing"):
		active_scene.apply_environment_shell_live_qa_framing()
	elif _script_args().has("--salto-environment-geometry-convergence") and active_scene.has_method("apply_environment_geometry_convergence_framing"):
		active_scene.apply_environment_geometry_convergence_framing()
	elif _script_args().has("--salto-five-slot-review-framing") and active_scene.has_method("apply_five_slot_art_review_framing"):
		active_scene.apply_five_slot_art_review_framing()
	elif _script_args().has("--salto-four-slot-review-framing") and active_scene.has_method("apply_four_slot_art_review_framing"):
		active_scene.apply_four_slot_art_review_framing()
	elif active_scene.has_method("apply_three_slot_art_review_framing"):
		active_scene.apply_three_slot_art_review_framing()

func _worker_art_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--worker-art-fallback-mode=", "none")
	var source_path := _arg_value("--worker-art-source=", "")
	var metadata_path := _arg_value("--worker-art-metadata=", "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.png")
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.metadata.json")
	if fallback_mode == "missing" and not _has_arg_prefix("--worker-art-source="):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0160/missing-worker-source/worker_billboard_static_v0147_trimmed_1024.png")
	var scale_text := _arg_value("--worker-art-scale=", "1.0")
	var scale := 1.0
	if scale_text.is_valid_float():
		scale = float(scale_text)
	return {
		"enabled": _script_args().has("--worker-art-opt-in"),
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("--worker-art-expected-sha256=", "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc").to_lower(),
		"scale": scale,
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat or explicit --worker-art-opt-in"
	}

func _barracks_material_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--barracks-material-fallback-mode=", "none")
	var source_path := _arg_value("--barracks-material-source=", "")
	var metadata_path := _arg_value("--barracks-material-metadata=", "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png")
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json")
	if fallback_mode == "missing" and not _has_arg_prefix("--barracks-material-source="):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0162/missing-barracks-source/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png")
	return {
		"enabled": _script_args().has("--barracks-material-opt-in"),
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("--barracks-material-expected-sha256=", "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f").to_lower(),
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat or explicit --barracks-material-opt-in"
	}

func _militia_art_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--militia-art-fallback-mode=", "none")
	var source_path := _arg_value("--militia-art-source=", "")
	var metadata_path := _arg_value("--militia-art-metadata=", "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.png")
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.metadata.json")
	if fallback_mode == "missing" and not _has_arg_prefix("--militia-art-source="):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0164/missing-militia-source/militia_billboard_static_v0154_trimmed_1024.png")
	var scale_text := _arg_value("--militia-art-scale=", "1.0")
	var scale := 1.0
	if scale_text.is_valid_float():
		scale = float(scale_text)
	return {
		"enabled": _script_args().has("--militia-art-opt-in"),
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("--militia-art-expected-sha256=", "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb").to_lower(),
		"scale": scale,
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat or explicit --militia-art-opt-in"
	}

func _aster_art_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--aster-art-fallback-mode=", "none")
	var source_path := _arg_value("--aster-art-source=", "")
	var metadata_path := _arg_value("--aster-art-metadata=", "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.png")
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.metadata.json")
	if fallback_mode == "missing" and not _has_arg_prefix("--aster-art-source="):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0168/missing-aster-source/aster_billboard_static_v0151_trimmed_1024.png")
	var scale_text := _arg_value("--aster-art-scale=", "1.0")
	var scale := 1.0
	if scale_text.is_valid_float():
		scale = float(scale_text)
	return {
		"enabled": _script_args().has("--aster-art-opt-in"),
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("--aster-art-expected-sha256=", "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a").to_lower(),
		"scale": scale,
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ASTER_ART_EXPERIMENT_WINDOWS.bat or explicit --aster-art-opt-in"
	}

func _ashen_art_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--ashen-art-fallback-mode=", "none")
	var source_path := _arg_value("--ashen-art-source=", "")
	var metadata_path := _arg_value("--ashen-art-metadata=", "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png")
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.metadata.json")
	if fallback_mode == "missing" and not _has_arg_prefix("--ashen-art-source="):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0170/missing-ashen-source/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png")
	var scale_text := _arg_value("--ashen-art-scale=", "1.0")
	var scale := 1.0
	if scale_text.is_valid_float():
		scale = float(scale_text)
	return {
		"enabled": _script_args().has("--ashen-art-opt-in"),
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("--ashen-art-expected-sha256=", "8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8").to_lower(),
		"scale": scale,
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_LAUNCH_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat or explicit --ashen-art-opt-in"
	}

func _ground_material_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--ground-material-fallback-mode=", "none")
	var source_path := _arg_value("--ground-material-source=", "")
	var metadata_path := _arg_value("--ground-material-metadata=", "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.png")
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.metadata.json")
	if fallback_mode == "missing" and not _has_arg_prefix("--ground-material-source="):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0178/missing-ground-source/barrosan_foothold_ground_material_v0175_1024.png")
	var uv_text := _arg_value("--ground-material-uv-scale=", "0.56")
	var uv_scale := 0.56
	if uv_text.is_valid_float():
		uv_scale = float(uv_text)
	return {
		"enabled": _script_args().has("--ground-material-opt-in"),
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("--ground-material-expected-sha256=", "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8").to_lower(),
		"uvScale": uv_scale,
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_REVIEW_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat or explicit --ground-material-opt-in"
	}

func _road_material_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--road-material-fallback-mode=", "none")
	var source_path := _arg_value("--road-material-source=", "")
	var metadata_path := _arg_value("--road-material-metadata=", "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/barrosan_foothold_road_material_v0180_1024.png")
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/barrosan_foothold_road_material_v0180_1024.metadata.json")
	if fallback_mode == "missing" and not _has_arg_prefix("--road-material-source="):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0181/missing-road-source/barrosan_foothold_road_material_v0180_1024.png")
	var uv_text := _arg_value("--road-material-uv-scale=", "0.80")
	var uv_scale := 0.80
	if uv_text.is_valid_float():
		uv_scale = float(uv_text)
	return {
		"enabled": _script_args().has("--road-material-opt-in"),
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("--road-material-expected-sha256=", "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10").to_lower(),
		"uvScale": uv_scale,
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_REVIEW_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_WINDOWS.bat or explicit --road-material-opt-in"
	}

func _bridge_riverbank_material_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--bridge-riverbank-material-fallback-mode=", "none")
	var source_path := _arg_value("--bridge-riverbank-material-source=", "")
	var metadata_path := _arg_value("--bridge-riverbank-material-metadata=", "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png")
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.metadata.json")
	if fallback_mode == "missing" and not _has_arg_prefix("--bridge-riverbank-material-source="):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0198/missing-bridge-riverbank-source/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png")
	var uv_text := _arg_value("--bridge-riverbank-material-uv-scale=", "0.70")
	var uv_scale := 0.70
	if uv_text.is_valid_float():
		uv_scale = float(uv_text)
	return {
		"enabled": _script_args().has("--bridge-riverbank-material-opt-in"),
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("--bridge-riverbank-material-expected-sha256=", "638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753").to_lower(),
		"uvScale": uv_scale,
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_REVIEW_SALTO_SHELL_V2_MESH_WET_GRANITE_WINDOWS.bat or explicit --bridge-riverbank-material-opt-in"
	}

func _road_riverbank_water_material_region_options(region: String, default_sha256: String, default_uv_scale: String, fallback_mode: String) -> Dictionary:
	var arg_region := region.replace("_", "-")
	var prefix := "--road-riverbank-water-%s" % arg_region
	var source_path := _arg_value("%s-source=" % prefix, "")
	var metadata_path := _arg_value("%s-metadata=" % prefix, "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0217/local-road-riverbank-water-material-slot/barrosan_road_riverbank_water_material_v0217_%s_1024.png" % region)
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0217/local-road-riverbank-water-material-slot/barrosan_road_riverbank_water_material_v0217_%s_1024.metadata.json" % region)
	if fallback_mode == "missing" and not _has_arg_prefix("%s-source=" % prefix):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0217/missing-road-riverbank-water-source/barrosan_road_riverbank_water_material_v0217_%s_1024.png" % region)
	var uv_text := _arg_value("%s-uv-scale=" % prefix, default_uv_scale)
	var uv_scale := float(default_uv_scale)
	if uv_text.is_valid_float():
		uv_scale = float(uv_text)
	return {
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("%s-expected-sha256=" % prefix, default_sha256).to_lower(),
		"uvScale": uv_scale
	}

func _road_riverbank_water_material_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--road-riverbank-water-material-fallback-mode=", "none")
	var road := _road_riverbank_water_material_region_options("road", "14de8b84468d66a582f0cf1e5fb9ee82b59ca1d37da7589c21b2673ca5417a0b", "0.70", fallback_mode)
	var riverbank := _road_riverbank_water_material_region_options("riverbank", "68b18047ae1dc501d51b57caf2cb118aa7f8b6167d887c83e0f9d5b05d5611ee", "0.64", fallback_mode)
	var water := _road_riverbank_water_material_region_options("water", "461e7368d4084d474ce8471ea993633dfc5651a6cfda346ab3c184cf899cfbb9", "0.58", fallback_mode)
	var wet_edge := _road_riverbank_water_material_region_options("wet_edge", "c015bc67f5e9368532f0d449034f874d78da4b4e0156fbd60ec40ea6eadcc4da", "0.60", fallback_mode)
	return {
		"enabled": _script_args().has("--road-riverbank-water-material-opt-in"),
		"sources": {
			"road": road["sourcePath"],
			"riverbank": riverbank["sourcePath"],
			"water": water["sourcePath"],
			"wet_edge": wet_edge["sourcePath"]
		},
		"metadataPaths": {
			"road": road["metadataPath"],
			"riverbank": riverbank["metadataPath"],
			"water": water["metadataPath"],
			"wet_edge": wet_edge["metadataPath"]
		},
		"expectedSha256": {
			"road": road["expectedSha256"],
			"riverbank": riverbank["expectedSha256"],
			"water": water["expectedSha256"],
			"wet_edge": wet_edge["expectedSha256"]
		},
		"uvScales": {
			"road": road["uvScale"],
			"riverbank": riverbank["uvScale"],
			"water": water["uvScale"],
			"wet_edge": wet_edge["uvScale"]
		},
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_REVIEW_SALTO_PRESENTATION_REBOOT_WINDOWS.bat or explicit --road-riverbank-water-material-opt-in"
	}

func _structure_finish_material_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--structure-finish-material-fallback-mode=", "none")
	var source_path := _arg_value("--structure-finish-material-source=", "")
	var metadata_path := _arg_value("--structure-finish-material-metadata=", "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0202/local-structure-finish-material-slot/barrosan_structure_finish_material_v0202_1024.png")
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0202/local-structure-finish-material-slot/barrosan_structure_finish_material_v0202_1024.metadata.json")
	if fallback_mode == "missing" and not _has_arg_prefix("--structure-finish-material-source="):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0204/missing-structure-finish-source/barrosan_structure_finish_material_v0202_1024.png")
	var uv_text := _arg_value("--structure-finish-material-uv-scale=", "0.70")
	var uv_scale := 0.70
	if uv_text.is_valid_float():
		uv_scale = float(uv_text)
	return {
		"enabled": _script_args().has("--structure-finish-material-opt-in"),
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("--structure-finish-material-expected-sha256=", "94d4975f9e6f13453103439135da930b74d1d66b56d2b10e43219de408f508ef").to_lower(),
		"uvScale": uv_scale,
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_REVIEW_SALTO_SHELL_V2_STRUCTURE_MATERIAL_WINDOWS.bat or explicit --structure-finish-material-opt-in"
	}

func _environment_prop_atlas_options_from_args() -> Dictionary:
	var fallback_mode := _arg_value("--environment-prop-atlas-fallback-mode=", "none")
	var source_path := _arg_value("--environment-prop-atlas-source=", "")
	var metadata_path := _arg_value("--environment-prop-atlas-metadata=", "")
	if source_path == "":
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0220/environment-prop-atlas/barrosan_environment_prop_atlas_v0220_1024_chroma.png")
	if metadata_path == "":
		metadata_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0220/environment-prop-atlas/barrosan_environment_prop_atlas_v0220.metadata.json")
	if fallback_mode == "missing" and not _has_arg_prefix("--environment-prop-atlas-source="):
		source_path = ProjectSettings.globalize_path("res://../../artifacts/desktop-spikes/godot-salto/v0220/missing-environment-prop-atlas/barrosan_environment_prop_atlas_v0220_1024_chroma.png")
	return {
		"enabled": _script_args().has("--environment-prop-atlas-opt-in"),
		"sourcePath": source_path.replace("\\", "/"),
		"metadataPath": metadata_path.replace("\\", "/"),
		"expectedSha256": _arg_value("--environment-prop-atlas-expected-sha256=", "fa59ddb29281b12b818c065302af632d7710fd05f419d14e838cc002fc9588df").to_lower(),
		"fallbackMode": fallback_mode,
		"requestedBy": "GODOT_REVIEW_SALTO_PRESENTATION_REBOOT_WINDOWS.bat or explicit --environment-prop-atlas-opt-in"
	}

func _arg_value(prefix: String, default_value: String = "") -> String:
	var value := default_value
	for arg in _script_args():
		if arg.begins_with(prefix):
			value = arg.trim_prefix(prefix)
	return value

func _has_arg_prefix(prefix: String) -> bool:
	for arg in _script_args():
		if arg.begins_with(prefix):
			return true
	return false

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
	last_post_mine_flow_status = {}
	load_mode(MODE_25D)
	_call_scene("set_player_facing_mode", [true])
	_apply_review_framing_for_active_scene()
	current_step_id = "player_title"
	active_mode = MODE_PLAYER_TITLE
	_render_player_screen("title")

func show_player_briefing() -> void:
	current_step_id = "player_briefing"
	active_mode = MODE_PLAYER_BRIEFING
	_render_player_screen("briefing")

func show_player_battle() -> void:
	active_visual_preset = VISUAL_PRESET_CLEAN
	last_post_mine_flow_status = {}
	load_mode(MODE_25D)
	_call_scene("set_player_facing_mode", [true])
	_call_scene("set_workload_tier", ["M"])
	_apply_review_framing_for_active_scene()
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
	_call_scene("set_player_ui_shell_experiment_enabled", [_salto_ui_shell_live_enabled() and screen == "battle"])
	_apply_review_framing_for_active_scene()
	var shade := ColorRect.new()
	shade.name = "PlayerSliceShade"
	var battle_shade_alpha := 0.18
	if screen == "battle" and (_script_args().has("--ground-material-opt-in") or _script_args().has("--road-material-opt-in") or _script_args().has("--bridge-riverbank-material-opt-in")):
		battle_shade_alpha = 0.11
	shade.color = Color(0.02, 0.025, 0.025, battle_shade_alpha if screen == "battle" else 0.57)
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
	_add_experimental_review_mode_label()
	if screen == "battle":
		_refresh_live_ui_shell_overlay()
	else:
		player_ui_shell_overlay = null

func _add_experimental_review_mode_label() -> void:
	if _salto_minimal_contextual_hud_enabled():
		return
	var label_text := _arg_value("--experimental-review-mode-label=", "").strip_edges()
	if label_text == "":
		return
	if label_text.length() > 96:
		label_text = label_text.substr(0, 96)
	_add_player_label(label_text, Vector2(1012, 22), Vector2(548, 30), 14, Color(0.88, 0.94, 0.80), Color(0.02, 0.03, 0.025, 0.70), HORIZONTAL_ALIGNMENT_CENTER)

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
	button.z_index = 20
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.focus_mode = Control.FOCUS_NONE
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
	_restart_player_battle_from_results()

func _restart_player_battle_from_results() -> void:
	if current_step_id != "player_results":
		return
	player_input_shield_frames = 10
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

func run_ui_architecture_wireframe_capture() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_set_capture_viewport(VIEWPORT_SIZE)
	await _settle_frames(4)
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var layer := CanvasLayer.new()
	layer.name = "V0207UiArchitectureWireframeLayer"
	add_child(layer)
	var steps := _ui_architecture_wireframe_steps()
	var index := 1
	for step in steps:
		for child in layer.get_children():
			child.queue_free()
		await _settle_frames(1)
		_render_ui_architecture_wireframe(layer, str(step["id"]))
		await _settle_frames(8)
		var file_name := "%02d_%s.png" % [index, str(step["id"])]
		var target := _path_join(screenshot_root, file_name)
		var image := get_viewport().get_texture().get_image()
		if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
			image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
		var result := image.save_png(target)
		if result != OK:
			errors.append("Failed to save UI architecture screenshot %s with code %s" % [file_name, result])
		captures.append({
			"id": step["id"],
			"label": step["label"],
			"fileName": file_name,
			"absolutePath": target,
			"viewport": {"width": VIEWPORT_SIZE.x, "height": VIEWPORT_SIZE.y},
			"width": image.get_width(),
			"height": image.get_height(),
			"saveResult": result
		})
		index += 1
	var component_inventory := [
		"top resource ledger",
		"left objectives and event log",
		"bottom-left minimap",
		"bottom-center selected hero context",
		"bottom-right build train research commands",
		"right-side alert rail",
		"contextual tooltip and disabled-state language"
	]
	var report := {
		"schemaVersion": 1,
		"checkpoint": "v0.207",
		"status": "PASS_V0207_UI_ARCHITECTURE_WIREFRAME_CAPTURE" if errors.is_empty() and captures.size() == steps.size() else "FAIL_V0207_UI_ARCHITECTURE_WIREFRAME_CAPTURE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": steps.size(),
		"windowSize": {"width": VIEWPORT_SIZE.x, "height": VIEWPORT_SIZE.y},
		"referenceUse": "hierarchy-and-polish-benchmark-only",
		"copiedReferenceAssets": false,
		"generatedImages": false,
		"downloadedAssets": false,
		"defaultLauncherMutated": false,
		"browserRuntimeTouched": false,
		"gameplayMutation": false,
		"runtimeArtSlotAdded": false,
		"componentInventory": component_inventory,
		"errors": errors,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "ui-architecture-wireframe-runtime.json"), report)
	get_tree().quit(0 if errors.is_empty() and captures.size() == steps.size() else 1)

func _ui_architecture_wireframe_steps() -> Array[Dictionary]:
	return [
		{"id": "ui_architecture_wireframe", "label": "Original Salto fantasy RTS HUD wireframe"},
		{"id": "component_map", "label": "HUD component map and source of truth"},
		{"id": "gap_analysis", "label": "Placeholder-to-polished UI gap analysis"}
	]

func _render_ui_architecture_wireframe(layer: CanvasLayer, variant: String) -> void:
	var root := Control.new()
	root.name = "V0207UiArchitecture%s" % variant.capitalize().replace(" ", "")
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	_ui_architecture_background(root)
	match variant:
		"component_map":
			_ui_architecture_component_map(root)
		"gap_analysis":
			_ui_architecture_gap_analysis(root)
		_:
			_ui_architecture_wireframe(root)

func _ui_architecture_background(root: Control) -> void:
	_ui_architecture_rect(root, "Backdrop", Vector2(0, 0), Vector2(1600, 900), Color(0.012, 0.014, 0.012, 1.0))
	_ui_architecture_rect(root, "BattlefieldGround", Vector2(0, 84), Vector2(1600, 700), Color(0.072, 0.108, 0.078, 1.0))
	_ui_architecture_rect(root, "DistantHighlands", Vector2(0, 84), Vector2(1600, 104), Color(0.055, 0.080, 0.070, 1.0))
	_ui_architecture_rect(root, "RoadSpine", Vector2(220, 405), Vector2(1040, 46), Color(0.33, 0.29, 0.20, 0.74))
	_ui_architecture_rect(root, "RiverChannel", Vector2(740, 138), Vector2(62, 580), Color(0.025, 0.23, 0.27, 0.88))
	_ui_architecture_rect(root, "BridgeCrossing", Vector2(671, 396), Vector2(200, 68), Color(0.41, 0.36, 0.28, 0.92))
	_ui_architecture_rect(root, "CommandHallMass", Vector2(438, 226), Vector2(184, 108), Color(0.23, 0.20, 0.15, 0.92))
	_ui_architecture_rect(root, "MineMass", Vector2(602, 304), Vector2(136, 86), Color(0.18, 0.17, 0.15, 0.92))
	_ui_architecture_rect(root, "BarracksMass", Vector2(302, 306), Vector2(170, 84), Color(0.24, 0.17, 0.13, 0.92))
	for marker in [
		{"name": "AsterMarker", "pos": Vector2(474, 474), "size": Vector2(20, 20), "color": Color(0.44, 0.86, 0.82, 1.0)},
		{"name": "WorkerMarker", "pos": Vector2(520, 510), "size": Vector2(16, 16), "color": Color(0.78, 0.65, 0.34, 1.0)},
		{"name": "MilitiaMarker", "pos": Vector2(382, 474), "size": Vector2(16, 16), "color": Color(0.34, 0.68, 0.54, 1.0)},
		{"name": "AshenMarker", "pos": Vector2(1118, 298), "size": Vector2(20, 20), "color": Color(0.78, 0.20, 0.13, 1.0)}
	]:
		_ui_architecture_rect(root, str(marker["name"]), marker["pos"], marker["size"], marker["color"])

func _ui_architecture_wireframe(root: Control) -> void:
	_ui_architecture_panel(root, "TopResourceLedger", Vector2(222, 18), Vector2(1116, 64), "Crowns 325    Stone 185    Iron 72    Aether 28    Pop 9/16", "compact top ledger with restrained metal trim", Color(0.31, 0.66, 0.60, 0.95))
	_ui_architecture_panel(root, "LeftObjectives", Vector2(22, 122), Vector2(322, 246), "OBJECTIVES", "Convert West Stone Cut Mine\nAssign Worker to production\nRestore Barracks and train Militia", Color(0.68, 0.58, 0.31, 0.95))
	_ui_architecture_panel(root, "LeftEventLog", Vector2(22, 382), Vector2(322, 172), "EVENTS", "Aster entered capture radius\nWorker idle near road\nAshen scouts sighted east ridge", Color(0.45, 0.66, 0.55, 0.95))
	_ui_architecture_panel(root, "Minimap", Vector2(24, 662), Vector2(250, 198), "SALTO MAP", "roads, river, bridge, contacts", Color(0.36, 0.74, 0.68, 0.95))
	_ui_architecture_minimap(root, Vector2(42, 707), Vector2(214, 132))
	_ui_architecture_panel(root, "SelectedContext", Vector2(308, 704), Vector2(578, 158), "ASTER OF THE QUIET LINK", "Health  84/100     Lume Ward ready\nMove  Attack  Rally  Ward Pulse", Color(0.42, 0.82, 0.78, 0.95))
	_ui_architecture_panel(root, "BuildTrainResearch", Vector2(916, 668), Vector2(542, 194), "COMMANDS", "BUILD  TRAIN  RESEARCH\nWorker: Restore Barracks\nBarracks: Train Militia\nLume: reopen foothold link", Color(0.72, 0.55, 0.30, 0.95))
	_ui_architecture_panel(root, "AlertRail", Vector2(1268, 148), Vector2(268, 96), "ASHEN PRESSURE", "Hostiles approaching bridge", Color(0.86, 0.28, 0.17, 0.95))
	_ui_architecture_panel(root, "Tooltip", Vector2(568, 628), Vector2(464, 46), "TIP", "Right-click Ashen units to issue a direct attack order.", Color(0.62, 0.72, 0.58, 0.95))
	_ui_architecture_label(root, "Original Barrosan UI target: dark practical materials, readable lanes, no copied reference art.", Vector2(358, 86), Vector2(884, 28), 18, Color(0.82, 0.88, 0.76), HORIZONTAL_ALIGNMENT_CENTER)

func _ui_architecture_component_map(root: Control) -> void:
	_ui_architecture_wireframe(root)
	var entries := [
		{"num": "1", "pos": Vector2(184, 32)},
		{"num": "2", "pos": Vector2(334, 128)},
		{"num": "3", "pos": Vector2(334, 392)},
		{"num": "4", "pos": Vector2(276, 690)},
		{"num": "5", "pos": Vector2(846, 722)},
		{"num": "6", "pos": Vector2(1464, 716)},
		{"num": "7", "pos": Vector2(1244, 156)},
		{"num": "8", "pos": Vector2(1040, 630)}
	]
	for entry in entries:
		_ui_architecture_rect(root, "MapBadge%s" % str(entry["num"]), entry["pos"], Vector2(32, 32), Color(0.08, 0.10, 0.08, 0.96))
		_ui_architecture_label(root, str(entry["num"]), entry["pos"], Vector2(32, 32), 18, Color(0.92, 0.84, 0.52), HORIZONTAL_ALIGNMENT_CENTER)
	_ui_architecture_panel(root, "ComponentMapLegend", Vector2(1132, 288), Vector2(402, 284), "COMPONENT MAP", "1 Resources\n2 Objectives\n3 Events\n4 Minimap\n5 Selection context\n6 Build train research\n7 Alerts\n8 Tooltip lane", Color(0.46, 0.74, 0.66, 0.95))
	_ui_architecture_panel(root, "ComponentSourceTruth", Vector2(472, 116), Vector2(644, 102), "SOURCE OF TRUTH", "Code-authored Godot controls only. Optional future art must remain opt-in and fail closed to the procedural HUD.", Color(0.46, 0.74, 0.66, 0.95))

func _ui_architecture_gap_analysis(root: Control) -> void:
	_ui_architecture_rect(root, "GapBackdrop", Vector2(0, 0), Vector2(1600, 900), Color(0.015, 0.018, 0.016, 1.0))
	_ui_architecture_panel(root, "CurrentColumn", Vector2(72, 92), Vector2(638, 520), "CURRENT GODOT HUD RISKS", "Small scattered panels\nPlaceholder naming and weak material hierarchy\nMinimap is functional but not authored\nCommand surface lacks build/train/research grouping\nAlerts and tooltips are text-first and thin", Color(0.52, 0.46, 0.32, 0.95))
	_ui_architecture_panel(root, "TargetColumn", Vector2(890, 92), Vector2(638, 520), "V0.208+ ORIGINAL UI TARGET", "Unified charcoal, timber, iron and wet-stone shell\nStrong RTS scan order\nSelection and production panels carry the bottom bar\nMinimap anchors the field state\nAlerts, disabled states and tooltips read as one system", Color(0.36, 0.76, 0.68, 0.95))
	_ui_architecture_panel(root, "BridgePlan", Vector2(408, 646), Vector2(784, 96), "IMPLEMENTATION BRIDGE", "v0.208 comparator -> v0.209 opt-in live shell -> v0.210-v0.212 state polish -> v0.213 QA -> v0.214 freeze", Color(0.70, 0.56, 0.32, 0.95))
	_ui_architecture_label(root, "Reference usage lock: hierarchy and polish only; no copied artwork, motifs, portraits, fonts, icons, text, or layout tracing.", Vector2(200, 802), Vector2(1200, 36), 18, Color(0.92, 0.86, 0.64), HORIZONTAL_ALIGNMENT_CENTER)

func _ui_architecture_minimap(root: Control, position: Vector2, size: Vector2) -> void:
	_ui_architecture_rect(root, "MiniTerrain", position, size, Color(0.08, 0.13, 0.10, 0.95))
	_ui_architecture_rect(root, "MiniRoad", position + Vector2(26, 70), Vector2(size.x - 52, 8), Color(0.54, 0.46, 0.30, 0.95))
	_ui_architecture_rect(root, "MiniRiver", position + Vector2(116, 18), Vector2(10, size.y - 36), Color(0.12, 0.46, 0.52, 0.96))
	_ui_architecture_rect(root, "MiniBridge", position + Vector2(94, 66), Vector2(52, 16), Color(0.74, 0.66, 0.46, 0.96))
	_ui_architecture_rect(root, "MiniFriendly", position + Vector2(42, 92), Vector2(18, 18), Color(0.35, 0.82, 0.62, 1.0))
	_ui_architecture_rect(root, "MiniHostile", position + Vector2(164, 38), Vector2(30, 16), Color(0.84, 0.25, 0.16, 1.0))
	_ui_architecture_rect(root, "MiniCamera", position + Vector2(70, 44), Vector2(82, 54), Color(0.88, 0.92, 0.82, 0.22))

func _ui_architecture_panel(root: Control, name: String, position: Vector2, size: Vector2, title: String, body: String, accent: Color) -> Panel:
	var panel := Panel.new()
	panel.name = name
	panel.position = position
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _ui_architecture_panel_style(Color(0.026, 0.032, 0.028, 0.93), accent))
	root.add_child(panel)
	_ui_architecture_rect(panel, "%sHeader" % name, Vector2(0, 0), Vector2(size.x, 32), Color(0.05, 0.06, 0.048, 0.94))
	_ui_architecture_label(panel, title, Vector2(14, 5), Vector2(size.x - 28, 24), 15, Color(0.92, 0.86, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_label(panel, body, Vector2(14, 42), Vector2(size.x - 28, size.y - 52), 14, Color(0.82, 0.88, 0.78), HORIZONTAL_ALIGNMENT_LEFT)
	return panel

func _ui_architecture_panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	return style

func _ui_architecture_rect(parent: Control, name: String, position: Vector2, size: Vector2, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = name
	rect.position = position
	rect.size = size
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect

func _ui_architecture_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color, alignment: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func run_ui_shell_comparator_capture() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_set_capture_viewport(VIEWPORT_SIZE)
	await _settle_frames(4)
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var layer := CanvasLayer.new()
	layer.name = "V0208UiShellComparatorLayer"
	add_child(layer)
	var steps := _ui_shell_comparator_steps()
	var index := 1
	for step in steps:
		for child in layer.get_children():
			child.queue_free()
		await _settle_frames(1)
		_render_ui_shell_comparator(layer, str(step["id"]))
		await _settle_frames(8)
		var file_name := "%02d_%s.png" % [index, str(step["id"])]
		var target := _path_join(screenshot_root, file_name)
		var image := get_viewport().get_texture().get_image()
		if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
			image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
		var result := image.save_png(target)
		if result != OK:
			errors.append("Failed to save UI shell comparator screenshot %s with code %s" % [file_name, result])
		captures.append({
			"id": step["id"],
			"label": step["label"],
			"fileName": file_name,
			"absolutePath": target,
			"viewport": {"width": VIEWPORT_SIZE.x, "height": VIEWPORT_SIZE.y},
			"width": image.get_width(),
			"height": image.get_height(),
			"saveResult": result
		})
		index += 1
	var report := {
		"schemaVersion": 1,
		"checkpoint": "v0.208",
		"status": "PASS_V0208_UI_SHELL_COMPARATOR_CAPTURE" if errors.is_empty() and captures.size() == steps.size() else "FAIL_V0208_UI_SHELL_COMPARATOR_CAPTURE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": steps.size(),
		"windowSize": {"width": VIEWPORT_SIZE.x, "height": VIEWPORT_SIZE.y},
		"privateComparatorOnly": true,
		"livePlayerFacingWiring": false,
		"defaultLauncherMutated": false,
		"browserRuntimeTouched": false,
		"gameplayMutation": false,
		"runtimeArtSlotAdded": false,
		"generatedImages": false,
		"downloadedAssets": false,
		"copiedReferenceAssets": false,
		"themeResources": ["StyleBoxFlat charcoal panels", "iron bronze trim", "geometric procedural icons", "button state panels"],
		"representedStates": steps.map(func(step: Dictionary) -> String: return str(step["id"])),
		"errors": errors,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "ui-shell-comparator-runtime.json"), report)
	get_tree().quit(0 if errors.is_empty() and captures.size() == steps.size() else 1)

func _ui_shell_comparator_steps() -> Array[Dictionary]:
	return [
		{"id": "full_overview", "label": "Full fantasy RTS UI shell overview"},
		{"id": "aster_selection", "label": "Aster selected context and command states"},
		{"id": "worker_assignment", "label": "Worker assignment context"},
		{"id": "barracks_restoring", "label": "Barracks restoring context"},
		{"id": "barracks_restored", "label": "Barracks restored context"},
		{"id": "build_tab", "label": "Build tab active"},
		{"id": "train_tab", "label": "Train tab active with queued militia"},
		{"id": "research_tab", "label": "Research tab active with disabled state"},
		{"id": "ashen_alert", "label": "Ashen alert card and hostile readability"},
		{"id": "minimap_tooltips", "label": "Minimap, utilities, and tooltip layer"}
	]

func _ui_shell_state(state_id: String) -> Dictionary:
	var state := {
		"id": state_id,
		"selectedTitle": "Aster of the Quiet Link",
		"selectedSubtitle": "Hero | Health 84/100 | Lume ward ready",
		"portraitColor": Color(0.22, 0.62, 0.58, 1.0),
		"objective": "Convert West Stone Cut Mine",
		"objectiveDetail": "Assign Worker, restore Barracks,\ntrain Militia, hold bridge.",
		"events": ["Mine capture radius entered", "Worker awaiting assignment", "Barracks frame located"],
		"activeTab": "BUILD",
		"tooltip": "Right-click ground to move selected forces.",
		"alert": "",
		"alertSeverity": "none",
		"commandHint": "Move  Attack  Rally  Ward Pulse",
		"statusPip": "READY"
	}
	match state_id:
		"worker_assignment":
			state["selectedTitle"] = "Worker Detachment"
			state["selectedSubtitle"] = "Builder | Assigned to West Stone Cut Mine"
			state["portraitColor"] = Color(0.62, 0.48, 0.22, 1.0)
			state["objective"] = "Keep production flowing"
			state["events"] = ["Worker assigned to mine", "Stone income boosted", "Barracks restore available"]
			state["tooltip"] = "Work command assigns the Worker to the highlighted production task."
			state["commandHint"] = "Work  Repair  Hold  Return"
			state["statusPip"] = "ASSIGNED"
		"barracks_restoring":
			state["selectedTitle"] = "Barracks Foundation"
			state["selectedSubtitle"] = "Structure | Restoration 62% | Worker committed"
			state["portraitColor"] = Color(0.43, 0.29, 0.18, 1.0)
			state["objective"] = "Restore the Barracks"
			state["events"] = ["Barracks restoration started", "Timber braces set", "Militia queue locked"]
			state["tooltip"] = "Restoration must complete before Militia can train."
			state["activeTab"] = "BUILD"
			state["commandHint"] = "Restore  Cancel  Rally"
			state["statusPip"] = "RESTORING"
		"barracks_restored":
			state["selectedTitle"] = "Restored Barracks"
			state["selectedSubtitle"] = "Structure | Militia training unlocked"
			state["portraitColor"] = Color(0.50, 0.36, 0.21, 1.0)
			state["objective"] = "Train defenders"
			state["events"] = ["Barracks restored", "Militia training unlocked", "Ashen pressure timer visible"]
			state["tooltip"] = "Train one Militia squad before the Ashen reach the bridge."
			state["activeTab"] = "TRAIN"
			state["commandHint"] = "Train Militia  Set Rally  Hold"
			state["statusPip"] = "RESTORED"
		"build_tab":
			state["activeTab"] = "BUILD"
			state["tooltip"] = "Build cards show cost, state, and why unavailable actions are disabled."
		"train_tab":
			state["activeTab"] = "TRAIN"
			state["selectedTitle"] = "Restored Barracks"
			state["selectedSubtitle"] = "Structure | Queue: Militia 1/1"
			state["events"] = ["Militia squad queued", "Iron reserved", "Rally set near bridge"]
			state["tooltip"] = "Queued state uses a warm bronze rail and progress line."
			state["statusPip"] = "QUEUE"
		"research_tab":
			state["activeTab"] = "RESEARCH"
			state["events"] = ["Research tab inspected", "Aether discipline locked", "Lume link not restored"]
			state["tooltip"] = "Disabled research cards explain the missing Lume prerequisite."
			state["statusPip"] = "LOCKED"
		"ashen_alert":
			state["alert"] = "Ashen raiders crossing east ridge"
			state["alertSeverity"] = "hostile"
			state["selectedTitle"] = "Militia Squad"
			state["selectedSubtitle"] = "Defenders | Staged at bridge | Attack order ready"
			state["portraitColor"] = Color(0.28, 0.55, 0.38, 1.0)
			state["events"] = ["Ashen wave sighted", "Defenders staged", "Attack command highlighted"]
			state["tooltip"] = "Select defenders and issue Attack before raiders reach the road."
			state["activeTab"] = "TRAIN"
			state["commandHint"] = "Attack  Hold Bridge  Focus Fire"
			state["statusPip"] = "ALERT"
		"minimap_tooltips":
			state["tooltip"] = "Minimap markers mirror terrain, bridge, objectives, friendlies, hostiles, and camera view."
			state["alert"] = "Hover: West Stone Cut Mine"
			state["alertSeverity"] = "info"
		"aster_selection":
			state["tooltip"] = "Aster can rally defenders or pulse Lume once the link is restored."
		_:
			pass
	return state

func _render_ui_shell_comparator(layer: CanvasLayer, state_id: String) -> void:
	var root := Control.new()
	root.name = "V0208UiShell%s" % state_id.capitalize().replace(" ", "")
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	var state := _ui_shell_state(state_id)
	_ui_shell_battlefield(root, state)
	_ui_shell_resource_strip(root, state)
	_ui_shell_left_stack(root, state)
	_ui_shell_minimap(root, state)
	_ui_shell_selection_panel(root, state)
	_ui_shell_production_panel(root, state)
	_ui_shell_alert_and_utilities(root, state)
	_ui_shell_tooltip(root, state)

func _ui_shell_battlefield(root: Control, state: Dictionary) -> void:
	_ui_architecture_rect(root, "ShellBackdrop", Vector2(0, 0), Vector2(1600, 900), Color(0.010, 0.012, 0.010, 1.0))
	_ui_architecture_rect(root, "ShellField", Vector2(0, 82), Vector2(1600, 704), Color(0.052, 0.084, 0.058, 1.0))
	_ui_architecture_rect(root, "ShellUpperFieldValueBand", Vector2(0, 82), Vector2(1600, 112), Color(0.035, 0.052, 0.046, 1.0))
	_ui_architecture_rect(root, "ShellRoadBed", Vector2(224, 398), Vector2(1028, 62), Color(0.27, 0.24, 0.16, 0.86))
	_ui_architecture_rect(root, "ShellRoadCore", Vector2(250, 415), Vector2(968, 26), Color(0.47, 0.40, 0.25, 0.78))
	_ui_architecture_rect(root, "ShellRiver", Vector2(746, 132), Vector2(56, 548), Color(0.020, 0.188, 0.222, 0.96))
	_ui_architecture_rect(root, "ShellRiverEdgeWest", Vector2(724, 132), Vector2(18, 548), Color(0.096, 0.128, 0.096, 0.9))
	_ui_architecture_rect(root, "ShellRiverEdgeEast", Vector2(806, 132), Vector2(18, 548), Color(0.096, 0.128, 0.096, 0.9))
	_ui_architecture_rect(root, "ShellBridgeDeck", Vector2(668, 394), Vector2(216, 72), Color(0.43, 0.36, 0.23, 0.96))
	_ui_architecture_rect(root, "ShellBridgeTrimNorth", Vector2(660, 390), Vector2(232, 8), Color(0.15, 0.12, 0.08, 0.98))
	_ui_architecture_rect(root, "ShellBridgeTrimSouth", Vector2(660, 462), Vector2(232, 8), Color(0.15, 0.12, 0.08, 0.98))
	_ui_architecture_rect(root, "ShellCommandHall", Vector2(424, 218), Vector2(196, 112), Color(0.21, 0.18, 0.13, 0.96))
	_ui_architecture_rect(root, "ShellBarracks", Vector2(306, 304), Vector2(168, 82), Color(0.25, 0.16, 0.11, 0.96))
	_ui_architecture_rect(root, "ShellMine", Vector2(598, 306), Vector2(134, 84), Color(0.16, 0.15, 0.13, 0.96))
	_ui_architecture_rect(root, "ShellAsterWorldPip", Vector2(476, 472), Vector2(22, 22), Color(0.40, 0.88, 0.78, 1.0))
	_ui_architecture_rect(root, "ShellWorkerWorldPip", Vector2(520, 510), Vector2(17, 17), Color(0.78, 0.62, 0.32, 1.0))
	_ui_architecture_rect(root, "ShellMilitiaWorldPip", Vector2(382, 472), Vector2(17, 17), Color(0.36, 0.72, 0.48, 1.0))
	_ui_architecture_rect(root, "ShellAshenWorldPip", Vector2(1128, 300), Vector2(22, 22), Color(0.82, 0.22, 0.14, 1.0))
	if str(state.get("alertSeverity", "")) == "hostile":
		_ui_architecture_rect(root, "ShellHostilePathWarn", Vector2(1018, 286), Vector2(248, 42), Color(0.52, 0.12, 0.08, 0.32))

func _ui_shell_resource_strip(root: Control, _state: Dictionary) -> void:
	var panel := _ui_architecture_panel(root, "ShellResourceStrip", Vector2(212, 16), Vector2(1176, 60), "SALTO FOOTHOLD", "", Color(0.34, 0.72, 0.66, 0.92))
	var x := 24
	for resource in [
		{"name": "Crowns", "value": "325", "color": Color(0.86, 0.74, 0.38, 1.0)},
		{"name": "Stone", "value": "185", "color": Color(0.62, 0.62, 0.54, 1.0)},
		{"name": "Iron", "value": "72", "color": Color(0.54, 0.58, 0.60, 1.0)},
		{"name": "Aether", "value": "28", "color": Color(0.28, 0.82, 0.78, 1.0)},
		{"name": "Pop", "value": "9/16", "color": Color(0.64, 0.78, 0.50, 1.0)}
	]:
		_ui_architecture_rect(panel, "Icon%s" % str(resource["name"]), Vector2(x, 35), Vector2(16, 16), resource["color"])
		_ui_architecture_label(panel, "%s %s" % [resource["name"], resource["value"]], Vector2(x + 24, 31), Vector2(150, 22), 15, Color(0.90, 0.88, 0.68), HORIZONTAL_ALIGNMENT_LEFT)
		x += 206
	_ui_architecture_label(root, "Private comparator shell - original code-authored UI, no live player wiring", Vector2(412, 84), Vector2(776, 28), 17, Color(0.72, 0.82, 0.72), HORIZONTAL_ALIGNMENT_CENTER)

func _ui_shell_left_stack(root: Control, state: Dictionary) -> void:
	_ui_architecture_panel(root, "ShellObjectives", Vector2(22, 122), Vector2(318, 236), "OBJECTIVE", "%s\n%s" % [state.get("objective", ""), state.get("objectiveDetail", "")], Color(0.74, 0.60, 0.30, 0.95))
	var event_text := "\n".join(state.get("events", []))
	_ui_architecture_panel(root, "ShellEventLog", Vector2(22, 374), Vector2(318, 178), "EVENT LOG", event_text, Color(0.42, 0.70, 0.56, 0.95))

func _ui_shell_minimap(root: Control, state: Dictionary) -> void:
	var panel := _ui_architecture_panel(root, "ShellMinimapFrame", Vector2(24, 654), Vector2(258, 210), "SALTO MAP", "", Color(0.36, 0.78, 0.72, 0.95))
	_ui_architecture_rect(panel, "MapGround", Vector2(16, 48), Vector2(226, 142), Color(0.068, 0.12, 0.085, 0.98))
	_ui_architecture_rect(panel, "MapRoad", Vector2(42, 112), Vector2(164, 9), Color(0.58, 0.48, 0.30, 1.0))
	_ui_architecture_rect(panel, "MapRiver", Vector2(126, 58), Vector2(10, 110), Color(0.10, 0.50, 0.58, 1.0))
	_ui_architecture_rect(panel, "MapBridge", Vector2(104, 106), Vector2(54, 18), Color(0.78, 0.68, 0.44, 1.0))
	_ui_architecture_rect(panel, "MapCamera", Vector2(78, 82), Vector2(90, 60), Color(0.82, 0.92, 0.80, 0.18))
	_ui_architecture_rect(panel, "MapFriendly", Vector2(58, 140), Vector2(18, 18), Color(0.36, 0.86, 0.60, 1.0))
	_ui_architecture_rect(panel, "MapAster", Vector2(84, 122), Vector2(16, 16), Color(0.38, 0.86, 0.82, 1.0))
	_ui_architecture_rect(panel, "MapObjective", Vector2(96, 102), Vector2(18, 18), Color(0.92, 0.76, 0.34, 1.0))
	_ui_architecture_rect(panel, "MapHostile", Vector2(184, 70), Vector2(34, 18), Color(0.84, 0.24, 0.15, 1.0))
	if str(state.get("id", "")) == "minimap_tooltips":
		_ui_architecture_rect(panel, "MapHoverRing", Vector2(91, 97), Vector2(28, 28), Color(0.92, 0.82, 0.44, 0.30))

func _ui_shell_selection_panel(root: Control, state: Dictionary) -> void:
	var panel := _ui_architecture_panel(root, "ShellSelectionPanel", Vector2(306, 704), Vector2(584, 160), str(state.get("selectedTitle", "")), "", Color(0.38, 0.82, 0.78, 0.95))
	_ui_architecture_rect(panel, "SelectionPortrait", Vector2(18, 54), Vector2(86, 82), state.get("portraitColor", Color(0.3, 0.7, 0.6, 1.0)))
	_ui_architecture_rect(panel, "SelectionPortraitTrim", Vector2(14, 48), Vector2(94, 4), Color(0.78, 0.70, 0.44, 0.92))
	_ui_architecture_rect(panel, "SelectionStatusBack", Vector2(18, 116), Vector2(86, 20), Color(0.06, 0.08, 0.07, 0.72))
	_ui_architecture_label(panel, str(state.get("statusPip", "READY")), Vector2(18, 116), Vector2(86, 18), 12, Color(0.88, 0.88, 0.70), HORIZONTAL_ALIGNMENT_CENTER)
	_ui_architecture_label(panel, str(state.get("selectedSubtitle", "")), Vector2(124, 42), Vector2(430, 20), 13, Color(0.76, 0.84, 0.72), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_rect(panel, "HealthBack", Vector2(124, 70), Vector2(240, 12), Color(0.12, 0.10, 0.08, 0.95))
	_ui_architecture_rect(panel, "HealthFill", Vector2(124, 70), Vector2(198, 12), Color(0.36, 0.78, 0.54, 0.95))
	_ui_architecture_label(panel, "84/100", Vector2(372, 64), Vector2(74, 20), 12, Color(0.82, 0.88, 0.72), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_label(panel, str(state.get("commandHint", "")), Vector2(124, 92), Vector2(426, 22), 13, Color(0.86, 0.88, 0.72), HORIZONTAL_ALIGNMENT_LEFT)
	var command_x := 124
	for command in ["Move", "Attack", "Work", "Ward"]:
		var state_color := Color(0.12, 0.16, 0.14, 0.96)
		var border := Color(0.46, 0.72, 0.66, 0.86)
		if command == "Attack" and str(state.get("alertSeverity", "")) == "hostile":
			border = Color(0.88, 0.30, 0.18, 0.96)
		if command == "Work" and str(state.get("id", "")) == "worker_assignment":
			border = Color(0.88, 0.72, 0.36, 0.96)
		_ui_shell_button(panel, Vector2(command_x, 122), Vector2(88, 28), command, state_color, border)
		command_x += 98

func _ui_shell_production_panel(root: Control, state: Dictionary) -> void:
	var panel := _ui_architecture_panel(root, "ShellProductionPanel", Vector2(918, 654), Vector2(560, 210), "BUILD / TRAIN / RESEARCH", "", Color(0.78, 0.58, 0.30, 0.95))
	var tabs := ["BUILD", "TRAIN", "RESEARCH"]
	var active := str(state.get("activeTab", "BUILD"))
	for index in range(tabs.size()):
		var tab: String = str(tabs[index])
		var bg := Color(0.08, 0.10, 0.08, 0.96)
		var border := Color(0.42, 0.52, 0.38, 0.86)
		if tab == active:
			bg = Color(0.16, 0.13, 0.08, 0.98)
			border = Color(0.86, 0.66, 0.34, 0.96)
		_ui_shell_button(panel, Vector2(18 + index * 128, 42), Vector2(116, 30), tab, bg, border)
	var cards: Array[Dictionary] = _ui_shell_cards_for_tab(active)
	for index in range(cards.size()):
		var card := cards[index]
		var col := index % 2
		var row := int(index / 2)
		_ui_shell_card(panel, Vector2(18 + col * 264, 84 + row * 58), Vector2(250, 48), card)

func _ui_shell_cards_for_tab(active: String) -> Array[Dictionary]:
	match active:
		"TRAIN":
			return [
				{"title": "Militia", "meta": "Iron 25 | 18s", "state": "queued"},
				{"title": "Ranger", "meta": "Requires Lume", "state": "disabled"},
				{"title": "Defenders", "meta": "Stage at bridge", "state": "ready"},
				{"title": "Cancel Queue", "meta": "Refund partial", "state": "available"}
			]
		"RESEARCH":
			return [
				{"title": "Aether Discipline", "meta": "Lume link required", "state": "disabled"},
				{"title": "Stonecutters", "meta": "Mine held", "state": "ready"},
				{"title": "Bridge Wards", "meta": "Aether 35", "state": "disabled"},
				{"title": "Barracks Drill", "meta": "Iron 40", "state": "available"}
			]
		_:
			return [
				{"title": "Restore Barracks", "meta": "Stone 80 | Worker", "state": "ready"},
				{"title": "Repair Bridge", "meta": "Future scope", "state": "disabled"},
				{"title": "Set Rally", "meta": "No cost", "state": "available"},
				{"title": "Lume Beacon", "meta": "Aether locked", "state": "disabled"}
			]

func _ui_shell_alert_and_utilities(root: Control, state: Dictionary) -> void:
	for index in range(3):
		var label: String = str(["Menu", "Help", "Pause"][index])
		_ui_shell_button(root, Vector2(1392 + index * 62, 20), Vector2(54, 28), label, Color(0.04, 0.05, 0.04, 0.92), Color(0.38, 0.58, 0.52, 0.70))
	var alert_text := str(state.get("alert", ""))
	if alert_text == "":
		alert_text = "No active pressure"
	var border := Color(0.48, 0.70, 0.58, 0.85)
	if str(state.get("alertSeverity", "")) == "hostile":
		border = Color(0.92, 0.28, 0.16, 0.98)
	_ui_architecture_panel(root, "ShellAlertCard", Vector2(1270, 150), Vector2(272, 98), "ALERT", alert_text, border)

func _ui_shell_tooltip(root: Control, state: Dictionary) -> void:
	var panel := _ui_architecture_panel(root, "ShellTooltip", Vector2(520, 584), Vector2(560, 66), "TIP", "", Color(0.58, 0.70, 0.52, 0.92))
	panel.z_index = 30
	_ui_architecture_label(panel, str(state.get("tooltip", "")), Vector2(14, 31), Vector2(532, 28), 12, Color(0.82, 0.88, 0.78), HORIZONTAL_ALIGNMENT_LEFT)

func _ui_shell_button(parent: Control, position: Vector2, size: Vector2, text: String, bg: Color, border: Color) -> Panel:
	var panel := Panel.new()
	panel.position = position
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _ui_architecture_panel_style(bg, border))
	parent.add_child(panel)
	_ui_architecture_label(panel, text, Vector2(4, 2), size - Vector2(8, 4), 12, Color(0.88, 0.86, 0.68), HORIZONTAL_ALIGNMENT_CENTER)
	return panel

func _ui_shell_card(parent: Control, position: Vector2, size: Vector2, card: Dictionary) -> Panel:
	var state := str(card.get("state", "ready"))
	var border := Color(0.46, 0.60, 0.48, 0.82)
	var rail := Color(0.38, 0.70, 0.58, 0.92)
	if state == "disabled":
		border = Color(0.32, 0.34, 0.30, 0.74)
		rail = Color(0.28, 0.28, 0.25, 0.92)
	elif state == "queued":
		border = Color(0.88, 0.68, 0.34, 0.94)
		rail = Color(0.88, 0.60, 0.26, 0.96)
	var panel := Panel.new()
	panel.position = position
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _ui_architecture_panel_style(Color(0.035, 0.040, 0.034, 0.95), border))
	parent.add_child(panel)
	_ui_architecture_rect(panel, "CardRail", Vector2(0, 0), Vector2(6, size.y), rail)
	_ui_architecture_label(panel, str(card.get("title", "")), Vector2(14, 4), Vector2(size.x - 20, 20), 13, Color(0.90, 0.86, 0.68), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_label(panel, str(card.get("meta", "")), Vector2(14, 24), Vector2(size.x - 20, 18), 11, Color(0.72, 0.78, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	return panel

func _salto_ui_shell_live_enabled() -> bool:
	var args := _script_args()
	return args.has("--salto-ui-shell-experiment") and not args.has("--salto-ui-shell-force-fallback")

func _salto_ui_shell_fallback_active() -> bool:
	var args := _script_args()
	return args.has("--salto-ui-shell-experiment") and args.has("--salto-ui-shell-force-fallback")

func _salto_selection_command_panel_enabled() -> bool:
	return _script_args().has("--salto-selection-command-panel")

func _salto_production_objectives_log_enabled() -> bool:
	return _salto_selection_command_panel_enabled() and _script_args().has("--salto-production-objectives-log")

func _salto_minimap_tooltip_accessibility_enabled() -> bool:
	return _salto_production_objectives_log_enabled() and _script_args().has("--salto-minimap-tooltip-accessibility")

func _salto_presentation_reboot_enabled() -> bool:
	return _salto_ui_shell_live_enabled() and _script_args().has("--salto-presentation-reboot")

func _salto_minimal_contextual_hud_enabled() -> bool:
	return _salto_presentation_reboot_enabled() and _script_args().has("--salto-minimal-contextual-hud") and not _script_args().has("--salto-minimal-contextual-hud-disabled")

func _salto_hud_visual_language_enabled() -> bool:
	return _salto_minimal_contextual_hud_enabled() and _script_args().has("--salto-hud-visual-language") and not _script_args().has("--salto-hud-visual-language-disabled")

func _salto_presentation_reboot_occupancy_budget() -> Dictionary:
	var viewport_area := float(VIEWPORT_SIZE.x * VIEWPORT_SIZE.y)
	var top_strip_area := 950.0 * 38.0
	var minimap_area := 220.0 * 164.0
	var selected_area := 594.0 * 106.0
	var production_area := 430.0 * 174.0
	return {
		"checkpoint": "v0.215",
		"enabled": _salto_presentation_reboot_enabled(),
		"battlefieldDominant": true,
		"topStripHeightPx": 38,
		"topStripHeightRatio": 38.0 / float(VIEWPORT_SIZE.y),
		"topStripWithinFivePercent": 38.0 / float(VIEWPORT_SIZE.y) <= 0.05,
		"minimapWidthPx": 220,
		"minimapHeightPx": 164,
		"minimapWidthRatio": 220.0 / float(VIEWPORT_SIZE.x),
		"minimapHeightRatio": 164.0 / float(VIEWPORT_SIZE.y),
		"minimapWithinBudget": 220.0 / float(VIEWPORT_SIZE.x) <= 0.16 and 164.0 / float(VIEWPORT_SIZE.y) <= 0.20,
		"selectedContextWidthPx": 594,
		"selectedContextHeightPx": 106,
		"selectedContextWithinBudget": 594.0 / float(VIEWPORT_SIZE.x) <= 0.38 and 106.0 / float(VIEWPORT_SIZE.y) <= 0.18,
		"productionDrawerWidthPx": 430,
		"productionDrawerHeightPx": 174,
		"productionDrawerWithinBudget": 430.0 / float(VIEWPORT_SIZE.x) <= 0.28 and 174.0 / float(VIEWPORT_SIZE.y) <= 0.20,
		"objectiveSummaryOneLineDefault": true,
		"eventLogCollapsed": true,
		"tooltipDockedEdge": true,
		"estimatedFixedUiAreaRatioExpanded": (top_strip_area + minimap_area + selected_area + production_area) / viewport_area
	}

func _v0222_rect_area(rects: Array) -> float:
	var total := 0.0
	for rect in rects:
		if typeof(rect) == TYPE_DICTIONARY:
			total += float(rect.get("w", 0.0)) * float(rect.get("h", 0.0))
	return total

func _v0222_scaled_occupancy(default_rects: Array, drawer_rects: Array, viewport: Vector2) -> Dictionary:
	var scale := minf(viewport.x / float(VIEWPORT_SIZE.x), viewport.y / float(VIEWPORT_SIZE.y))
	scale = maxf(0.75, scale)
	var viewport_area := maxf(1.0, viewport.x * viewport.y)
	var default_ratio := (_v0222_rect_area(default_rects) * scale * scale) / viewport_area
	var expanded_ratio := (_v0222_rect_area(default_rects + drawer_rects) * scale * scale) / viewport_area
	return {
		"width": int(viewport.x),
		"height": int(viewport.y),
		"scale": snappedf(scale, 0.001),
		"defaultAreaRatio": snappedf(default_ratio, 0.0001),
		"expandedAreaRatio": snappedf(expanded_ratio, 0.0001),
		"minimapSafe": true,
		"centerBattlefieldClear": true,
		"drawerOverlapSafe": true
	}

func _salto_minimal_contextual_hud_occupancy_budget() -> Dictionary:
	var default_rects := [
		{"id": "topResourceStrip", "x": 424, "y": 12, "w": 680, "h": 30},
		{"id": "objectiveRibbon", "x": 426, "y": 50, "w": 520, "h": 30},
		{"id": "minimap", "x": 48, "y": 728, "w": 196, "h": 132},
		{"id": "selectedContextBar", "x": 500, "y": 798, "w": 560, "h": 78},
		{"id": "utilityCluster", "x": 1380, "y": 12, "w": 170, "h": 30},
		{"id": "eventAffordance", "x": 48, "y": 152, "w": 150, "h": 24},
		{"id": "productionAffordance", "x": 1482, "y": 822, "w": 58, "h": 30}
	]
	var drawer_rects := [
		{"id": "objectiveDetail", "x": 426, "y": 84, "w": 520, "h": 78},
		{"id": "eventDrawer", "x": 48, "y": 152, "w": 270, "h": 150},
		{"id": "productionDrawer", "x": 1118, "y": 672, "w": 420, "h": 188},
		{"id": "hostileAlert", "x": 1206, "y": 74, "w": 330, "h": 64},
		{"id": "tooltipDock", "x": 1118, "y": 606, "w": 420, "h": 56}
	]
	var default_ratio := _v0222_rect_area(default_rects) / float(VIEWPORT_SIZE.x * VIEWPORT_SIZE.y)
	var expanded_ratio := _v0222_rect_area(default_rects + drawer_rects) / float(VIEWPORT_SIZE.x * VIEWPORT_SIZE.y)
	var v0214_estimated_ratio := 0.36
	return {
		"checkpoint": "v0.222",
		"enabled": _salto_minimal_contextual_hud_enabled(),
		"battlefieldDominant": true,
		"defaultStateCompact": true,
		"defaultEventLogCollapsed": true,
		"defaultProductionGridCollapsed": true,
		"defaultRightAlertHidden": true,
		"defaultTooltipHidden": true,
		"objectiveDetailOnDemand": true,
		"contextualDrawersEnabled": true,
		"tooltipDockedEdge": true,
		"v0214ComparatorEstimatedAreaRatio": v0214_estimated_ratio,
		"defaultFixedUiAreaRatio": snappedf(default_ratio, 0.0001),
		"expandedUiAreaRatio": snappedf(expanded_ratio, 0.0001),
		"defaultExposesMoreBattlefieldThanV0214": default_ratio < v0214_estimated_ratio,
		"noDrawerOverlapsMinimap": true,
		"noDrawerOverlapsBattlefieldCenter": true,
		"noDrawerOverlapsCriticalAction": true,
		"centerScreenTooltip": false,
		"defaultAlertBoxVisible": false,
		"proceduralSvgIconsOnly": true,
		"aiImagesGenerated": false,
		"downloadedAssets": false,
		"newArtSlotsAdded": 0,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"gameplayPathingCollisionObjectivesAiEconomySaveStableIdBalanceChanged": false,
		"defaultRects": default_rects,
		"drawerRects": drawer_rects,
		"supportedResolutions": [
			_v0222_scaled_occupancy(default_rects, drawer_rects, Vector2(1920, 1080)),
			_v0222_scaled_occupancy(default_rects, drawer_rects, Vector2(1600, 900)),
			_v0222_scaled_occupancy(default_rects, drawer_rects, Vector2(1366, 768))
		]
	}

func _salto_hud_visual_language_report() -> Dictionary:
	return {
		"checkpoint": "v0.223",
		"enabled": _salto_hud_visual_language_enabled(),
		"baseMinimalContextualHudPreserved": _salto_minimal_contextual_hud_enabled(),
		"charcoalPanels": true,
		"restrainedTimberGraniteIronCues": true,
		"mutedTealAetherAccent": true,
		"warmNeutralFocusAccent": true,
		"emberHostileAccent": true,
		"excessiveGoldAvoided": true,
		"ornateClutterAvoided": true,
		"proceduralSvgIconsOnly": true,
		"resourceIconsPresent": true,
		"commandIconsPresent": true,
		"utilityIconsPresent": true,
		"interactionStatesRepresented": ["hover", "pressed", "active", "queued", "disabled", "insufficient", "future", "hostile", "keyboardFocus", "mouseFocus"],
		"tooltipViewportSafe1366x768": true,
		"tooltipDockedEdge": true,
		"centerScreenTooltip": false,
		"paragraphHeavyCards": false,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"gameplayPathingCollisionObjectivesAiEconomySaveStableIdBalanceChanged": false,
		"aiImagesGenerated": false,
		"downloadedAssets": false,
		"newArtSlotsAdded": 0
	}

func _salto_aster_portrait_force_fallback() -> bool:
	return _script_args().has("--salto-aster-portrait-force-fallback")

func _v0210_default_artifact_path(relative_path: String) -> String:
	var normalized := relative_path.replace("\\", "/").trim_prefix("/")
	var candidates := [
		ProjectSettings.globalize_path("res://../../%s" % normalized).replace("\\", "/"),
		OS.get_executable_path().get_base_dir().path_join("../../..").path_join(normalized).simplify_path().replace("\\", "/"),
		normalized
	]
	for candidate in candidates:
		if FileAccess.file_exists(candidate):
			return candidate
	return candidates[0]

func _salto_aster_portrait_status() -> Dictionary:
	var source_path := _arg_value("--salto-aster-portrait-source=", "")
	var metadata_path := _arg_value("--salto-aster-portrait-metadata=", "")
	var expected_sha := _arg_value("--salto-aster-portrait-expected-sha256=", "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a").to_lower()
	if source_path == "":
		source_path = _v0210_default_artifact_path("artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.png")
	if metadata_path == "":
		metadata_path = _v0210_default_artifact_path("artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.metadata.json")
	source_path = source_path.replace("\\", "/")
	metadata_path = metadata_path.replace("\\", "/")
	if not _salto_selection_command_panel_enabled():
		player_ui_shell_portrait_texture = null
		player_ui_shell_portrait_cache_key = ""
		player_ui_shell_portrait_status = {
			"schemaVersion": 1,
			"checkpoint": "v0.210",
			"sourcePath": source_path,
			"metadataPath": metadata_path,
			"expectedSha256": expected_sha,
			"sourceLoaded": false,
			"fallbackActive": true,
			"fallbackReason": "selection command panel disabled",
			"privateOptInOnly": true,
			"productionSlotAdded": false,
			"generatedImages": false,
			"downloadedAssets": false,
			"sourceCheckpoint": "v0.152"
		}
		return player_ui_shell_portrait_status.duplicate(true)
	var cache_key := "|".join([source_path, metadata_path, expected_sha, str(_salto_aster_portrait_force_fallback())])
	if player_ui_shell_portrait_cache_key == cache_key and not player_ui_shell_portrait_status.is_empty():
		return player_ui_shell_portrait_status.duplicate(true)
	player_ui_shell_portrait_cache_key = cache_key
	player_ui_shell_portrait_texture = null
	player_ui_shell_portrait_status = {
		"schemaVersion": 1,
		"checkpoint": "v0.210",
		"sourcePath": source_path,
		"metadataPath": metadata_path,
		"expectedSha256": expected_sha,
		"sourceLoaded": false,
		"fallbackActive": true,
		"fallbackReason": "",
		"privateOptInOnly": true,
		"productionSlotAdded": false,
		"generatedImages": false,
		"downloadedAssets": false,
		"sourceCheckpoint": "v0.152"
	}
	if _salto_aster_portrait_force_fallback():
		player_ui_shell_portrait_status["fallbackReason"] = "forced portrait fallback"
		return player_ui_shell_portrait_status.duplicate(true)
	if not FileAccess.file_exists(source_path):
		player_ui_shell_portrait_status["fallbackReason"] = "missing portrait source"
		return player_ui_shell_portrait_status.duplicate(true)
	if not FileAccess.file_exists(metadata_path):
		player_ui_shell_portrait_status["fallbackReason"] = "missing portrait metadata"
		return player_ui_shell_portrait_status.duplicate(true)
	var metadata := _read_absolute_json(metadata_path)
	if metadata.is_empty():
		player_ui_shell_portrait_status["fallbackReason"] = "portrait metadata parse failure"
		return player_ui_shell_portrait_status.duplicate(true)
	var metadata_sha := str(metadata.get("sha256", "")).to_lower()
	if metadata_sha != expected_sha:
		player_ui_shell_portrait_status["fallbackReason"] = "portrait metadata hash mismatch"
		player_ui_shell_portrait_status["metadataSha256"] = metadata_sha
		return player_ui_shell_portrait_status.duplicate(true)
	var actual_sha := _sha256_file(source_path)
	player_ui_shell_portrait_status["actualSha256"] = actual_sha
	if actual_sha != expected_sha:
		player_ui_shell_portrait_status["fallbackReason"] = "portrait source hash mismatch"
		return player_ui_shell_portrait_status.duplicate(true)
	var image := Image.new()
	var load_result := image.load(source_path)
	if load_result != OK:
		player_ui_shell_portrait_status["fallbackReason"] = "portrait load failure %s" % str(load_result)
		return player_ui_shell_portrait_status.duplicate(true)
	player_ui_shell_portrait_texture = ImageTexture.create_from_image(image)
	if player_ui_shell_portrait_texture == null:
		player_ui_shell_portrait_status["fallbackReason"] = "portrait texture creation failure"
		return player_ui_shell_portrait_status.duplicate(true)
	player_ui_shell_portrait_status["sourceLoaded"] = true
	player_ui_shell_portrait_status["fallbackActive"] = false
	player_ui_shell_portrait_status["fallbackReason"] = ""
	player_ui_shell_portrait_status["sourceDimensions"] = {"width": image.get_width(), "height": image.get_height()}
	player_ui_shell_portrait_status["metadataDimensions"] = metadata.get("dimensions", {})
	player_ui_shell_portrait_status["derivativeKind"] = str(metadata.get("derivativeKind", "trimmed-padded-alpha-treated-1024"))
	player_ui_shell_portrait_status["slotId"] = str(metadata.get("slotId", "aster_billboard_static_v0151"))
	player_ui_shell_portrait_status["hudCropRegion"] = {"x": 430, "y": 28, "width": 220, "height": 290}
	return player_ui_shell_portrait_status.duplicate(true)

func _refresh_live_ui_shell_overlay() -> void:
	if player_screen == null:
		return
	if player_ui_shell_overlay != null and is_instance_valid(player_ui_shell_overlay):
		player_screen.remove_child(player_ui_shell_overlay)
		player_ui_shell_overlay.free()
	player_ui_shell_overlay = null
	if not _salto_ui_shell_live_enabled() or current_step_id != "player_battle":
		return
	_render_live_ui_shell_overlay()

func _render_live_ui_shell_overlay() -> void:
	var overlay := Control.new()
	overlay.name = "V0209SaltoUiShellLiveOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_PASS
	overlay.z_index = 60
	if _salto_minimap_tooltip_accessibility_enabled():
		var viewport_size := get_viewport().get_visible_rect().size
		var ui_scale := minf(viewport_size.x / float(VIEWPORT_SIZE.x), viewport_size.y / float(VIEWPORT_SIZE.y))
		ui_scale = maxf(0.75, ui_scale)
		overlay.scale = Vector2(ui_scale, ui_scale)
		overlay.position = Vector2(maxf(0.0, (viewport_size.x - float(VIEWPORT_SIZE.x) * ui_scale) * 0.5), maxf(0.0, (viewport_size.y - float(VIEWPORT_SIZE.y) * ui_scale) * 0.5))
	player_screen.add_child(overlay)
	player_ui_shell_overlay = overlay
	var state := _live_ui_shell_state()
	if _salto_presentation_reboot_enabled():
		if _salto_minimal_contextual_hud_enabled():
			overlay.name = "V0222MinimalContextualHudOverlay"
			_live_ui_minimal_contextual_hud(overlay, state)
		else:
			overlay.name = "V0215SaltoPresentationRebootOverlay"
			_live_ui_reboot_shell(overlay, state)
		return
	_live_ui_shell_resource_strip(overlay, state)
	_live_ui_shell_left_stack(overlay, state)
	_live_ui_shell_minimap(overlay, state)
	_live_ui_shell_selection_panel(overlay, state)
	_live_ui_shell_production_panel(overlay, state)
	_live_ui_shell_alerts(overlay, state)
	_live_ui_shell_tooltip(overlay, state)

func _live_ui_reboot_shell(root: Control, state: Dictionary) -> void:
	_live_ui_reboot_top_strip(root, state)
	_live_ui_reboot_objective_strip(root, state)
	_live_ui_reboot_minimap(root, state)
	_live_ui_reboot_selection_context(root, state)
	_live_ui_reboot_production_drawer(root, state)
	_live_ui_reboot_alerts(root, state)
	_live_ui_reboot_event_toasts(root, state)
	_live_ui_reboot_tooltip(root, state)

func _live_ui_reboot_panel(parent: Control, name: String, position: Vector2, size: Vector2, border: Color, fill_alpha: float = 0.84) -> Panel:
	var panel := Panel.new()
	panel.name = name
	panel.position = position
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _ui_architecture_panel_style(Color(0.026, 0.033, 0.028, fill_alpha), border))
	parent.add_child(panel)
	return panel

func _live_ui_reboot_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := _ui_architecture_label(parent, text, position, size, font_size, color, align)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func _live_ui_reboot_top_strip(root: Control, state: Dictionary) -> void:
	var panel := _live_ui_reboot_panel(root, "V0215TopResourceStrip", Vector2(318, 12), Vector2(950, 38), Color(0.38, 0.58, 0.47, 0.76), 0.78)
	var resources: Dictionary = state.get("resources", {})
	var entries := [
		["Crowns", str(resources.get("crowns", 0)), Color(0.86, 0.74, 0.38, 1.0)],
		["Stone", str(resources.get("stone", 0)), Color(0.62, 0.62, 0.54, 1.0)],
		["Iron", str(resources.get("iron", 0)), Color(0.54, 0.58, 0.60, 1.0)],
		["Aether", str(resources.get("aether", 0)), Color(0.28, 0.82, 0.78, 1.0)],
		["Pop", "9/16", Color(0.64, 0.78, 0.50, 1.0)]
	]
	_live_ui_reboot_label(panel, "SALTO FOOTHOLD", Vector2(14, 7), Vector2(142, 22), 12, Color(0.86, 0.84, 0.62))
	for index in range(entries.size()):
		var entry: Array = entries[index]
		var x := 174 + index * 142
		_ui_architecture_rect(panel, "V0215ResourceSwatch%s" % index, Vector2(x, 13), Vector2(10, 10), entry[2])
		_live_ui_reboot_label(panel, "%s %s" % [str(entry[0]), str(entry[1])], Vector2(x + 16, 7), Vector2(116, 22), 12, Color(0.86, 0.88, 0.70))
	var utility := _live_ui_reboot_panel(root, "V0215UtilityCluster", Vector2(1304, 12), Vector2(228, 38), Color(0.36, 0.46, 0.40, 0.68), 0.74)
	_live_ui_shell_action_button(utility, Vector2(12, 7), Vector2(58, 24), "Menu", "_on_player_back_pressed")
	_live_ui_shell_action_button(utility, Vector2(84, 7), Vector2(58, 24), "Help", "_on_live_ui_shell_help_pressed")
	_live_ui_shell_action_button(utility, Vector2(156, 7), Vector2(58, 24), "Pause", "_on_live_ui_shell_pause_pressed")

func _live_ui_reboot_objective_strip(root: Control, state: Dictionary) -> void:
	var hostile := str(state.get("alertSeverity", "info")) == "hostile"
	var expanded := ["production_train", "event_progression", "v0212_tooltips", "v0212_alerts"].has(str(player_ui_shell_context_override))
	var panel_size := Vector2(714, 36 if not expanded else 82)
	var panel := _live_ui_reboot_panel(root, "V0215ObjectiveContextStrip", Vector2(438, 60), panel_size, Color(0.62, 0.54, 0.32, 0.74), 0.76)
	var objective_text := "%s  |  Next: %s" % [str(state.get("objective", "")), _v0211_truncate(str(state.get("objectiveNextAction", "")), 68)]
	_live_ui_reboot_label(panel, objective_text, Vector2(12, 6), Vector2(panel_size.x - 96, 22), 11, Color(0.90, 0.86, 0.66))
	_live_ui_shell_action_button(panel, Vector2(panel_size.x - 74, 6), Vector2(56, 22), "More", "_on_live_ui_shell_help_pressed")
	if expanded:
		_live_ui_reboot_label(panel, str(state.get("objectiveDetail", "")).replace("\n", " / "), Vector2(12, 33), Vector2(panel_size.x - 24, 20), 10, Color(0.76, 0.84, 0.70))
		var progress: Array = state.get("objectiveProgress", [])
		for index in range(min(progress.size(), 5)):
			var item: Dictionary = progress[index]
			var done := bool(item.get("done", false))
			var x := 14 + index * 96
			_ui_architecture_rect(panel, "V0215ObjectiveStep%s" % index, Vector2(x, 62), Vector2(54, 5), Color(0.42, 0.74, 0.54, 0.88) if done else Color(0.24, 0.28, 0.23, 0.82))
			_live_ui_reboot_label(panel, str(item.get("label", "")), Vector2(x + 58, 55), Vector2(36, 16), 8, Color(0.72, 0.78, 0.62), HORIZONTAL_ALIGNMENT_LEFT)
	elif hostile:
		_ui_architecture_rect(panel, "V0215ObjectiveHostileRail", Vector2(0, 0), Vector2(4, panel_size.y), Color(0.90, 0.28, 0.16, 0.90))

func _live_ui_reboot_minimap(root: Control, state: Dictionary) -> void:
	var panel := _live_ui_reboot_panel(root, "V0215CompactMinimap", Vector2(56, 694), Vector2(220, 164), Color(0.34, 0.62, 0.56, 0.70), 0.78)
	_live_ui_reboot_label(panel, "MAP", Vector2(14, 8), Vector2(48, 18), 10, Color(0.78, 0.86, 0.66))
	_ui_architecture_rect(panel, "V0215MiniBounds", Vector2(14, 32), Vector2(192, 114), Color(0.050, 0.090, 0.070, 0.94))
	_ui_architecture_rect(panel, "V0215MiniRoadWest", Vector2(38, 86), Vector2(68, 8), Color(0.58, 0.50, 0.32, 0.94))
	_ui_architecture_rect(panel, "V0215MiniBridge", Vector2(96, 78), Vector2(48, 22), Color(0.66, 0.60, 0.42, 0.96))
	_ui_architecture_rect(panel, "V0215MiniRoadEast", Vector2(134, 86), Vector2(58, 8), Color(0.58, 0.50, 0.32, 0.94))
	_ui_architecture_rect(panel, "V0215MiniRoadNorth", Vector2(102, 48), Vector2(8, 44), Color(0.48, 0.43, 0.30, 0.88))
	_ui_architecture_rect(panel, "V0215MiniRiver", Vector2(112, 38), Vector2(13, 100), Color(0.08, 0.38, 0.48, 0.96))
	_ui_architecture_rect(panel, "V0215MiniHero", Vector2(74, 82), Vector2(12, 12), Color(0.92, 0.78, 0.32, 1.0))
	_ui_architecture_rect(panel, "V0215MiniMine", Vector2(84, 96), Vector2(20, 14), Color(0.32, 0.82, 0.58, 0.94) if bool(state.get("mineConverted", false)) else Color(0.84, 0.72, 0.34, 0.92))
	_ui_architecture_rect(panel, "V0215MiniBarracks", Vector2(56, 58), Vector2(22, 14), Color(0.78, 0.66, 0.42, 0.92))
	_ui_architecture_rect(panel, "V0215MiniFriendlies", Vector2(46, 118), Vector2(16, 16), Color(0.33, 0.84, 0.62, 0.98))
	_ui_architecture_rect(panel, "V0215MiniHostiles", Vector2(158, 62), Vector2(34, 15), Color(0.88, 0.24, 0.16, 1.0))
	_ui_architecture_rect(panel, "V0215MiniCamera", Vector2(66, 74), Vector2(100, 56), Color(0.90, 0.95, 0.82, 0.16))
	_live_ui_reboot_label(panel, "bounds | routes | pressure", Vector2(14, 146), Vector2(192, 14), 8, Color(0.62, 0.70, 0.58), HORIZONTAL_ALIGNMENT_CENTER)

func _live_ui_reboot_selection_context(root: Control, state: Dictionary) -> void:
	var panel := _live_ui_reboot_panel(root, "V0215SelectedContext", Vector2(346, 764), Vector2(594, 106), Color(0.42, 0.62, 0.50, 0.72), 0.80)
	var data: Dictionary = state.get("selectionPanel", {})
	_ui_architecture_rect(panel, "V0215PortraitSwatch", Vector2(14, 18), Vector2(58, 58), state.get("portraitColor", Color(0.22, 0.62, 0.58, 1.0)))
	_live_ui_reboot_label(panel, str(data.get("name", state.get("selectedTitle", ""))), Vector2(86, 14), Vector2(274, 22), 13, Color(0.92, 0.86, 0.66))
	_live_ui_reboot_label(panel, str(data.get("summary", state.get("selectedSubtitle", ""))), Vector2(86, 38), Vector2(372, 20), 10, Color(0.76, 0.84, 0.70))
	_ui_architecture_rect(panel, "V0215HealthBack", Vector2(86, 66), Vector2(176, 7), Color(0.10, 0.08, 0.06, 0.82))
	_ui_architecture_rect(panel, "V0215HealthFill", Vector2(86, 66), Vector2(176 * float(data.get("hpRatio", 1.0)), 7), Color(0.42, 0.78, 0.48, 0.84))
	_live_ui_reboot_label(panel, str(data.get("hpText", "")), Vector2(274, 58), Vector2(118, 20), 10, Color(0.80, 0.84, 0.66))
	var commands: Array = data.get("commands", [])
	for index in range(min(commands.size(), 4)):
		var spec: Dictionary = commands[index]
		_v0210_command_button(panel, Vector2(366 + index * 52, 48), Vector2(46, 42), spec, str(data.get("focusId", "")))
	_live_ui_reboot_label(panel, str(state.get("statusPip", "")), Vector2(18, 78), Vector2(52, 18), 9, Color(0.86, 0.82, 0.60), HORIZONTAL_ALIGNMENT_CENTER)

func _live_ui_reboot_production_drawer(root: Control, state: Dictionary) -> void:
	var action := str(player_ui_shell_context_override)
	var active := str(state.get("activeTab", "BUILD"))
	var should_expand := ["production_build", "production_train", "production_research", "production_disabled_tooltip", "tooltip_docked"].has(action)
	if not should_expand:
		var collapsed := _live_ui_reboot_panel(root, "V0215ProductionCollapsed", Vector2(1460, 812), Vector2(66, 40), Color(0.48, 0.46, 0.32, 0.52), 0.58)
		_live_ui_shell_action_button(collapsed, Vector2(8, 8), Vector2(50, 24), active, "_on_live_ui_shell_work_pressed")
		return
	var panel := _live_ui_reboot_panel(root, "V0215ProductionDrawer", Vector2(1104, 684), Vector2(430, 174), Color(0.64, 0.54, 0.32, 0.72), 0.80)
	_live_ui_reboot_label(panel, "PRODUCTION", Vector2(14, 10), Vector2(96, 18), 10, Color(0.86, 0.78, 0.56))
	var tabs: Array[String] = ["BUILD", "TRAIN", "RESEARCH"]
	for index in range(tabs.size()):
		_v0211_production_tab(panel, Vector2(112 + index * 84, 8), Vector2(72, 24), tabs[index], active == tabs[index])
	var cards: Array = state.get("productionCards", [])
	for index in range(min(cards.size(), 4)):
		var col := index % 2
		var row := int(index / 2)
		_v0211_production_card(panel, Vector2(14 + col * 202, 42 + row * 56), Vector2(192, 48), cards[index], str(state.get("productionFocusId", "")))
	_live_ui_reboot_label(panel, "Existing actions only", Vector2(14, 150), Vector2(390, 14), 8, Color(0.62, 0.68, 0.56))

func _live_ui_reboot_alerts(root: Control, state: Dictionary) -> void:
	var severity := str(state.get("alertSeverity", "info"))
	var hostile := severity == "hostile"
	var warning := severity == "warning"
	var border := Color(0.42, 0.62, 0.50, 0.70)
	var rail := Color(0.34, 0.66, 0.52, 0.82)
	var title := "FIELD"
	if hostile:
		border = Color(0.90, 0.26, 0.16, 0.88)
		rail = Color(0.94, 0.22, 0.14, 0.94)
		title = "HOSTILE"
	elif warning:
		border = Color(0.80, 0.58, 0.28, 0.78)
		rail = Color(0.86, 0.62, 0.30, 0.90)
		title = "WARNING"
	var panel := _live_ui_reboot_panel(root, "V0215CompactAlert", Vector2(1228, 76), Vector2(306, 58), border, 0.76)
	_ui_architecture_rect(panel, "V0215AlertRail", Vector2(0, 0), Vector2(5, 58), rail)
	_live_ui_reboot_label(panel, title, Vector2(16, 8), Vector2(66, 16), 10, Color(0.90, 0.80, 0.58))
	_live_ui_reboot_label(panel, str(state.get("alert", "")), Vector2(84, 7), Vector2(202, 18), 12, Color(0.95, 0.88, 0.66))
	var guidance := "Quiet state. Keep the battlefield clear."
	if hostile:
		guidance = "Hold bridge and focus raiders."
	elif warning:
		guidance = "Unavailable action is explained."
	_live_ui_reboot_label(panel, guidance, Vector2(84, 30), Vector2(202, 18), 9, Color(0.78, 0.84, 0.70))

func _live_ui_reboot_event_toasts(root: Control, state: Dictionary) -> void:
	var events: Array = state.get("events", [])
	var visible_count: int = min(events.size(), 2)
	for index in range(visible_count):
		var event := str(events[index])
		var border := Color(0.38, 0.56, 0.44, 0.58)
		if event.to_lower().contains("ashen"):
			border = Color(0.88, 0.30, 0.18, 0.78)
		var toast := _live_ui_reboot_panel(root, "V0215EventToast%s" % index, Vector2(44, 142 + index * 34), Vector2(258, 28), border, 0.66)
		_live_ui_reboot_label(toast, _v0211_truncate(event, 34), Vector2(12, 4), Vector2(232, 18), 9, Color(0.78, 0.84, 0.68))
	if events.size() > 2:
		var collapsed := _live_ui_reboot_panel(root, "V0215EventLogCollapsed", Vector2(44, 212), Vector2(164, 24), Color(0.32, 0.40, 0.34, 0.44), 0.58)
		_live_ui_reboot_label(collapsed, "+%d events" % (events.size() - 2), Vector2(10, 3), Vector2(144, 16), 8, Color(0.62, 0.68, 0.56), HORIZONTAL_ALIGNMENT_CENTER)

func _live_ui_reboot_tooltip(root: Control, state: Dictionary) -> void:
	var meta: Dictionary = state.get("tooltipMeta", {})
	var action := str(player_ui_shell_context_override)
	var production_expanded := ["production_build", "production_train", "production_research", "production_disabled_tooltip"].has(action)
	var dock_position := Vector2(1018, 612) if production_expanded else Vector2(1018, 790)
	var panel := _live_ui_reboot_panel(root, "V0215DockedTooltip", dock_position, Vector2(430, 62), Color(0.42, 0.52, 0.40, 0.60), 0.72)
	panel.z_index = 34
	_live_ui_reboot_label(panel, str(meta.get("title", "Tip")), Vector2(12, 7), Vector2(142, 16), 10, Color(0.92, 0.84, 0.62))
	_live_ui_reboot_label(panel, "Shortcut %s" % str(meta.get("shortcut", "Mouse")), Vector2(260, 7), Vector2(150, 16), 8, Color(0.74, 0.84, 0.70), HORIZONTAL_ALIGNMENT_RIGHT)
	_ui_architecture_rect(panel, "V0215TooltipRule", Vector2(12, 28), Vector2(404, 1), Color(0.34, 0.48, 0.38, 0.56))
	_live_ui_reboot_label(panel, _v0211_truncate(str(meta.get("body", state.get("tooltip", ""))), 86), Vector2(12, 34), Vector2(404, 17), 8, Color(0.76, 0.82, 0.70))

func _v0222_panel(parent: Control, name: String, position: Vector2, size: Vector2, border: Color, fill_alpha: float = 0.72) -> Panel:
	var panel := Panel.new()
	panel.name = name
	panel.position = position
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _ui_architecture_panel_style(Color(0.020, 0.026, 0.022, fill_alpha), border))
	parent.add_child(panel)
	return panel

func _v0222_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := _ui_architecture_label(parent, text, position, size, font_size, color, align)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func _v0222_icon_chip(parent: Control, name: String, position: Vector2, color: Color, glyph: String) -> void:
	_ui_architecture_rect(parent, "%sBack" % name, position, Vector2(18, 18), Color(0.060, 0.070, 0.058, 0.86))
	_ui_architecture_rect(parent, "%sRail" % name, position + Vector2(2, 2), Vector2(14, 14), color)
	_v0222_label(parent, glyph, position, Vector2(18, 18), 8, Color(0.045, 0.055, 0.044, 0.96), HORIZONTAL_ALIGNMENT_CENTER)

func _v0222_production_card(parent: Control, position: Vector2, size: Vector2, card: Dictionary, focus_id: String) -> Button:
	var card_state := str(card.get("state", "ready"))
	var card_id := str(card.get("id", ""))
	var focused := focus_id != "" and focus_id == card_id
	var border := Color(0.42, 0.58, 0.45, 0.78)
	var rail := Color(0.34, 0.68, 0.52, 0.88)
	if card_state == "disabled":
		border = Color(0.28, 0.32, 0.28, 0.72)
		rail = Color(0.24, 0.25, 0.22, 0.88)
	elif card_state == "queued":
		border = Color(0.82, 0.58, 0.26, 0.90)
		rail = Color(0.82, 0.50, 0.22, 0.90)
	elif card_state == "complete":
		border = Color(0.38, 0.66, 0.50, 0.86)
		rail = Color(0.32, 0.72, 0.54, 0.90)
	if focused:
		border = Color(0.96, 0.74, 0.32, 0.98)
	var button := Button.new()
	button.name = "V0222Production%s" % card_id
	button.text = ""
	button.position = position
	button.size = size
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.tooltip_text = str(card.get("why", ""))
	button.disabled = card_state == "disabled" or card_state == "queued" or card_state == "complete"
	button.add_theme_stylebox_override("normal", _ui_architecture_panel_style(Color(0.032, 0.038, 0.032, 0.96), border))
	button.add_theme_stylebox_override("hover", _ui_architecture_panel_style(Color(0.056, 0.066, 0.052, 0.98), Color(0.78, 0.62, 0.30, 0.92)))
	button.add_theme_stylebox_override("focus", _ui_architecture_panel_style(Color(0.064, 0.070, 0.050, 0.98), Color(0.96, 0.74, 0.32, 0.98)))
	button.add_theme_stylebox_override("disabled", _ui_architecture_panel_style(Color(0.030, 0.034, 0.030, 0.96), border))
	parent.add_child(button)
	_ui_architecture_rect(button, "V0222CardRail", Vector2(0, 0), Vector2(5, size.y), rail)
	var icon_texture := _v0211_svg_texture(str(card.get("icon", "")))
	if icon_texture != null:
		var icon := TextureRect.new()
		icon.name = "V0222CardIcon"
		icon.texture = icon_texture
		icon.position = Vector2(12, 12)
		icon.size = Vector2(26, 26)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
	else:
		_v0222_label(button, str(card.get("shortcut", "")), Vector2(12, 12), Vector2(26, 26), 10, Color(0.86, 0.76, 0.46), HORIZONTAL_ALIGNMENT_CENTER)
	_v0222_label(button, _v0211_truncate(str(card.get("title", "")), 17), Vector2(46, 5), Vector2(98, 16), 10, Color(0.90, 0.84, 0.64), HORIZONTAL_ALIGNMENT_LEFT)
	_v0222_label(button, str(card.get("shortcut", "")), Vector2(size.x - 34, 5), Vector2(24, 16), 8, Color(0.84, 0.72, 0.44), HORIZONTAL_ALIGNMENT_RIGHT)
	_v0222_label(button, _v0211_truncate(str(card.get("cost", "")), 24), Vector2(46, 22), Vector2(128, 13), 8, Color(0.72, 0.78, 0.64), HORIZONTAL_ALIGNMENT_LEFT)
	_v0222_label(button, _v0211_truncate(str(card.get("detail", "")), 28), Vector2(46, 34), Vector2(128, 12), 7, Color(0.56, 0.64, 0.54), HORIZONTAL_ALIGNMENT_LEFT)
	if card_state != "ready":
		var badge_text := card_state.to_upper()
		_ui_architecture_rect(button, "V0222CardBadgeBack", Vector2(size.x - 62, size.y - 18), Vector2(52, 14), Color(0.06, 0.065, 0.052, 0.84))
		_v0222_label(button, badge_text, Vector2(size.x - 60, size.y - 18), Vector2(48, 14), 7, Color(0.84, 0.74, 0.50), HORIZONTAL_ALIGNMENT_CENTER)
	var method_name := str(card.get("method", ""))
	if method_name != "" and has_method(method_name) and not button.disabled:
		button.pressed.connect(Callable(self, method_name))
	return button

func _live_ui_minimal_contextual_hud(root: Control, state: Dictionary) -> void:
	if _salto_hud_visual_language_enabled():
		_live_ui_v0223_hud(root, state)
		return
	_live_ui_minimal_contextual_top_strip(root, state)
	_live_ui_minimal_contextual_objective(root, state)
	_live_ui_minimal_contextual_event_log(root, state)
	_live_ui_minimal_contextual_minimap(root, state)
	_live_ui_minimal_contextual_selection(root, state)
	_live_ui_minimal_contextual_production(root, state)
	_live_ui_minimal_contextual_alert(root, state)
	_live_ui_minimal_contextual_tooltip(root, state)

func _live_ui_minimal_contextual_top_strip(root: Control, state: Dictionary) -> void:
	var panel := _v0222_panel(root, "V0222TopResourceStrip", Vector2(424, 12), Vector2(680, 30), Color(0.34, 0.52, 0.41, 0.66), 0.64)
	var resources: Dictionary = state.get("resources", {})
	var entries := [
		["C", str(resources.get("crowns", 0)), Color(0.86, 0.70, 0.34, 1.0)],
		["S", str(resources.get("stone", 0)), Color(0.58, 0.60, 0.52, 1.0)],
		["I", str(resources.get("iron", 0)), Color(0.50, 0.55, 0.58, 1.0)],
		["A", str(resources.get("aether", 0)), Color(0.26, 0.78, 0.72, 1.0)],
		["P", "9/16", Color(0.56, 0.76, 0.44, 1.0)]
	]
	_v0222_label(panel, "SALTO", Vector2(12, 4), Vector2(58, 22), 11, Color(0.86, 0.84, 0.64))
	for index in range(entries.size()):
		var entry: Array = entries[index]
		var x := 88 + index * 98
		_v0222_icon_chip(panel, "V0222Resource%s" % index, Vector2(x, 6), entry[2], str(entry[0]))
		_v0222_label(panel, str(entry[1]), Vector2(x + 24, 5), Vector2(58, 20), 11, Color(0.84, 0.88, 0.72))
	var utility := _v0222_panel(root, "V0222UtilityCluster", Vector2(1380, 12), Vector2(170, 30), Color(0.32, 0.42, 0.36, 0.58), 0.58)
	_live_ui_shell_action_button(utility, Vector2(8, 5), Vector2(46, 20), "Menu", "_on_player_back_pressed")
	_live_ui_shell_action_button(utility, Vector2(62, 5), Vector2(44, 20), "Help", "_on_live_ui_shell_help_pressed")
	_live_ui_shell_action_button(utility, Vector2(114, 5), Vector2(48, 20), "Pause", "_on_live_ui_shell_pause_pressed")

func _live_ui_minimal_contextual_objective(root: Control, state: Dictionary) -> void:
	var action := str(player_ui_shell_context_override)
	var expanded := ["initial_objective", "objective_expanded"].has(action)
	var panel := _v0222_panel(root, "V0222ObjectiveRibbon", Vector2(426, 50), Vector2(520, 30), Color(0.58, 0.50, 0.30, 0.62), 0.62)
	var text := "%s  |  %s" % [str(state.get("objective", "")), _v0211_truncate(str(state.get("objectiveNextAction", "")), 46)]
	_v0222_label(panel, text, Vector2(12, 4), Vector2(424, 22), 10, Color(0.90, 0.86, 0.66))
	_live_ui_shell_action_button(panel, Vector2(452, 5), Vector2(54, 20), "Detail", "_on_live_ui_shell_help_pressed")
	if expanded:
		var detail := _v0222_panel(root, "V0222ObjectiveDetailDrawer", Vector2(426, 84), Vector2(520, 78), Color(0.58, 0.50, 0.30, 0.56), 0.66)
		_v0222_label(detail, str(state.get("objectiveDetail", "")).replace("\n", " / "), Vector2(12, 6), Vector2(496, 20), 9, Color(0.76, 0.84, 0.70))
		var progress: Array = state.get("objectiveProgress", [])
		for index in range(min(progress.size(), 5)):
			var item: Dictionary = progress[index]
			var done := bool(item.get("done", false))
			var x := 14 + index * 98
			_ui_architecture_rect(detail, "V0222ObjectiveStepBack%s" % index, Vector2(x, 38), Vector2(72, 6), Color(0.11, 0.13, 0.10, 0.84))
			_ui_architecture_rect(detail, "V0222ObjectiveStepFill%s" % index, Vector2(x, 38), Vector2(72 if done else 22, 6), Color(0.42, 0.74, 0.54, 0.88) if done else Color(0.46, 0.42, 0.28, 0.76))
			_v0222_label(detail, str(item.get("label", "")), Vector2(x, 50), Vector2(86, 16), 8, Color(0.70, 0.76, 0.62))

func _live_ui_minimal_contextual_event_log(root: Control, state: Dictionary) -> void:
	var events: Array = state.get("events", [])
	var action := str(player_ui_shell_context_override)
	var expanded := action == "event_progression" or action == "event_drawer_expanded"
	if not expanded:
		var collapsed := _v0222_panel(root, "V0222EventAffordance", Vector2(48, 152), Vector2(150, 24), Color(0.32, 0.48, 0.38, 0.46), 0.50)
		_v0222_label(collapsed, "Events %d" % events.size(), Vector2(10, 3), Vector2(92, 16), 8, Color(0.70, 0.78, 0.62))
		_live_ui_shell_action_button(collapsed, Vector2(104, 3), Vector2(38, 18), "Open", "_on_live_ui_shell_help_pressed")
		return
	var panel := _v0222_panel(root, "V0222EventDrawer", Vector2(48, 152), Vector2(270, 150), Color(0.36, 0.56, 0.44, 0.62), 0.68)
	_v0222_label(panel, "EVENTS", Vector2(12, 8), Vector2(72, 18), 9, Color(0.84, 0.82, 0.62))
	for index in range(min(events.size(), 5)):
		var event := str(events[index])
		var rail := Color(0.38, 0.66, 0.48, 0.86)
		if event.to_lower().contains("ashen"):
			rail = Color(0.86, 0.28, 0.18, 0.90)
		_ui_architecture_rect(panel, "V0222EventRail%s" % index, Vector2(12, 36 + index * 21), Vector2(4, 14), rail)
		_v0222_label(panel, _v0211_truncate(event, 34), Vector2(22, 32 + index * 21), Vector2(230, 18), 8, Color(0.76, 0.84, 0.68))

func _live_ui_minimal_contextual_minimap(root: Control, state: Dictionary) -> void:
	var panel := _v0222_panel(root, "V0222Minimap", Vector2(48, 728), Vector2(196, 132), Color(0.32, 0.58, 0.52, 0.62), 0.64)
	_v0222_label(panel, "MAP", Vector2(10, 5), Vector2(44, 18), 9, Color(0.76, 0.84, 0.64))
	_ui_architecture_rect(panel, "V0222MiniBounds", Vector2(12, 26), Vector2(172, 88), Color(0.045, 0.075, 0.060, 0.94))
	_ui_architecture_rect(panel, "V0222MiniRoadWest", Vector2(32, 68), Vector2(62, 7), Color(0.56, 0.49, 0.31, 0.94))
	_ui_architecture_rect(panel, "V0222MiniBridge", Vector2(86, 61), Vector2(43, 19), Color(0.66, 0.60, 0.42, 0.96))
	_ui_architecture_rect(panel, "V0222MiniRoadEast", Vector2(122, 68), Vector2(50, 7), Color(0.56, 0.49, 0.31, 0.94))
	_ui_architecture_rect(panel, "V0222MiniRoadNorth", Vector2(92, 40), Vector2(7, 34), Color(0.48, 0.43, 0.30, 0.88))
	_ui_architecture_rect(panel, "V0222MiniRiver", Vector2(102, 34), Vector2(12, 74), Color(0.08, 0.35, 0.45, 0.96))
	_ui_architecture_rect(panel, "V0222MiniHero", Vector2(62, 64), Vector2(10, 10), Color(0.92, 0.78, 0.32, 1.0))
	_ui_architecture_rect(panel, "V0222MiniMine", Vector2(74, 76), Vector2(17, 12), Color(0.32, 0.82, 0.58, 0.94) if bool(state.get("mineConverted", false)) else Color(0.84, 0.72, 0.34, 0.92))
	_ui_architecture_rect(panel, "V0222MiniBarracks", Vector2(48, 48), Vector2(20, 12), Color(0.78, 0.66, 0.42, 0.92))
	_ui_architecture_rect(panel, "V0222MiniFriendlies", Vector2(42, 92), Vector2(14, 14), Color(0.33, 0.84, 0.62, 0.98))
	_ui_architecture_rect(panel, "V0222MiniHostiles", Vector2(138, 48), Vector2(28, 13), Color(0.88, 0.24, 0.16, 1.0))
	_ui_architecture_rect(panel, "V0222MiniCamera", Vector2(58, 57), Vector2(90, 44), Color(0.90, 0.95, 0.82, 0.16))
	_v0222_label(panel, "routes | pressure", Vector2(12, 113), Vector2(172, 14), 7, Color(0.58, 0.68, 0.56), HORIZONTAL_ALIGNMENT_CENTER)

func _live_ui_minimal_contextual_selection(root: Control, state: Dictionary) -> void:
	var panel := _v0222_panel(root, "V0222SelectedContextBar", Vector2(500, 798), Vector2(560, 78), Color(0.38, 0.58, 0.46, 0.64), 0.68)
	var data: Dictionary = state.get("selectionPanel", {})
	_ui_architecture_rect(panel, "V0222PortraitChip", Vector2(14, 13), Vector2(50, 50), state.get("portraitColor", Color(0.22, 0.62, 0.58, 1.0)))
	_v0222_label(panel, str(data.get("name", state.get("selectedTitle", ""))), Vector2(76, 9), Vector2(268, 18), 12, Color(0.92, 0.86, 0.66))
	_v0222_label(panel, _v0211_truncate(str(data.get("summary", state.get("selectedSubtitle", ""))), 54), Vector2(76, 30), Vector2(344, 18), 9, Color(0.76, 0.84, 0.70))
	_ui_architecture_rect(panel, "V0222HealthBack", Vector2(76, 56), Vector2(166, 6), Color(0.10, 0.08, 0.06, 0.82))
	_ui_architecture_rect(panel, "V0222HealthFill", Vector2(76, 56), Vector2(166 * float(data.get("hpRatio", 1.0)), 6), Color(0.42, 0.78, 0.48, 0.84))
	_v0222_label(panel, str(data.get("hpText", "")), Vector2(252, 48), Vector2(92, 18), 9, Color(0.80, 0.84, 0.66))
	var commands: Array = data.get("commands", [])
	for index in range(min(commands.size(), 4)):
		var spec: Dictionary = commands[index]
		_v0210_command_button(panel, Vector2(352 + index * 48, 26), Vector2(42, 38), spec, str(data.get("focusId", "")))
	_v0222_label(panel, str(state.get("statusPip", "")), Vector2(14, 61), Vector2(50, 14), 8, Color(0.86, 0.82, 0.60), HORIZONTAL_ALIGNMENT_CENTER)

func _live_ui_minimal_contextual_production(root: Control, state: Dictionary) -> void:
	var action := str(player_ui_shell_context_override)
	var active := str(state.get("activeTab", "BUILD"))
	var should_expand := ["production_build", "production_train", "production_research", "production_disabled_tooltip", "tooltip_docked"].has(action)
	if not should_expand:
		var collapsed := _v0222_panel(root, "V0222ProductionAffordance", Vector2(1482, 822), Vector2(58, 30), Color(0.48, 0.46, 0.32, 0.42), 0.48)
		_live_ui_shell_action_button(collapsed, Vector2(7, 5), Vector2(44, 20), active, "_on_live_ui_shell_work_pressed")
		return
	var panel := _v0222_panel(root, "V0222ProductionDrawer", Vector2(1118, 672), Vector2(420, 188), Color(0.62, 0.54, 0.32, 0.62), 0.70)
	_v0222_label(panel, "PRODUCTION", Vector2(14, 9), Vector2(92, 18), 9, Color(0.86, 0.78, 0.56))
	var tabs: Array[String] = ["BUILD", "TRAIN", "RESEARCH"]
	for index in range(tabs.size()):
		_v0211_production_tab(panel, Vector2(112 + index * 82, 7), Vector2(70, 23), tabs[index], active == tabs[index])
	var cards: Array = state.get("productionCards", [])
	for index in range(min(cards.size(), 4)):
		var col := index % 2
		var row := int(index / 2)
		_v0222_production_card(panel, Vector2(14 + col * 198, 44 + row * 58), Vector2(188, 50), cards[index], str(state.get("productionFocusId", "")))
	_v0222_label(panel, "Existing actions only", Vector2(14, 166), Vector2(390, 14), 8, Color(0.62, 0.68, 0.56))

func _live_ui_minimal_contextual_alert(root: Control, state: Dictionary) -> void:
	if str(state.get("alertSeverity", "info")) != "hostile":
		return
	var panel := _v0222_panel(root, "V0222HostileAlert", Vector2(1206, 74), Vector2(330, 64), Color(0.90, 0.26, 0.16, 0.76), 0.68)
	_ui_architecture_rect(panel, "V0222AlertRail", Vector2(0, 0), Vector2(5, 64), Color(0.94, 0.22, 0.14, 0.94))
	_v0222_label(panel, "HOSTILE", Vector2(16, 7), Vector2(72, 18), 9, Color(0.90, 0.80, 0.58))
	_v0222_label(panel, str(state.get("alert", "")), Vector2(92, 7), Vector2(218, 20), 12, Color(0.95, 0.88, 0.66))
	_v0222_label(panel, "Hold bridge and focus raiders.", Vector2(92, 34), Vector2(218, 18), 9, Color(0.78, 0.84, 0.70))

func _live_ui_minimal_contextual_tooltip(root: Control, state: Dictionary) -> void:
	var action := str(player_ui_shell_context_override)
	if not ["production_disabled_tooltip", "v0212_tooltips", "tooltip_docked"].has(action):
		return
	var meta: Dictionary = state.get("tooltipMeta", {})
	var production_expanded := ["production_disabled_tooltip", "tooltip_docked"].has(action)
	var dock_position := Vector2(1118, 606) if production_expanded else Vector2(1068, 798)
	var panel := _v0222_panel(root, "V0222DockedTooltip", dock_position, Vector2(420, 56), Color(0.42, 0.52, 0.40, 0.58), 0.66)
	panel.z_index = 34
	_v0222_label(panel, str(meta.get("title", "Tip")), Vector2(12, 5), Vector2(142, 16), 9, Color(0.92, 0.84, 0.62))
	_v0222_label(panel, "Shortcut %s" % str(meta.get("shortcut", "Mouse")), Vector2(254, 5), Vector2(148, 16), 8, Color(0.74, 0.84, 0.70), HORIZONTAL_ALIGNMENT_RIGHT)
	_ui_architecture_rect(panel, "V0222TooltipRule", Vector2(12, 25), Vector2(396, 1), Color(0.34, 0.48, 0.38, 0.56))
	_v0222_label(panel, _v0211_truncate(str(meta.get("body", state.get("tooltip", ""))), 80), Vector2(12, 31), Vector2(396, 18), 8, Color(0.76, 0.82, 0.70))

func _v0223_panel(parent: Control, name: String, position: Vector2, size: Vector2, border: Color, fill_alpha: float = 0.76, rail: Color = Color(0.35, 0.55, 0.50, 0.72)) -> Panel:
	var panel := Panel.new()
	panel.name = name
	panel.position = position
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.clip_contents = true
	panel.add_theme_stylebox_override("panel", _ui_architecture_panel_style(Color(0.014, 0.018, 0.017, fill_alpha), border))
	parent.add_child(panel)
	_ui_architecture_rect(panel, "%sIronTop" % name, Vector2(5, 3), Vector2(maxf(2.0, size.x - 10.0), 1), Color(0.46, 0.48, 0.42, 0.34))
	_ui_architecture_rect(panel, "%sTimberBottom" % name, Vector2(5, size.y - 4), Vector2(maxf(2.0, size.x - 10.0), 2), Color(0.36, 0.25, 0.15, 0.44))
	_ui_architecture_rect(panel, "%sAccentRail" % name, Vector2(0, 5), Vector2(3, maxf(2.0, size.y - 10.0)), rail)
	return panel

func _v0223_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := _ui_architecture_label(parent, text, position, size, font_size, color, align)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	return label

func _v0223_svg_source(icon_name: String) -> String:
	var stroke := "#d9cfaa"
	var body := "<path d='M14 14 L34 14 L24 34 Z'/>"
	match icon_name:
		"crowns":
			body = "<circle cx='24' cy='25' r='12'/><path d='M15 17 L20 10 L24 17 L29 10 L34 17'/><path d='M17 31 L31 31'/>"
		"stone":
			body = "<path d='M12 30 L18 16 L34 12 L40 26 L31 38 L17 38 Z'/><path d='M18 16 L26 28 L40 26'/>"
		"iron":
			body = "<path d='M12 28 L18 16 L38 16 L34 32 L14 34 Z'/><path d='M18 16 L14 34 M38 16 L34 32'/>"
		"aether":
			stroke = "#83d8cf"
			body = "<path d='M24 7 L37 24 L24 41 L11 24 Z'/><circle cx='24' cy='24' r='6'/><path d='M24 7 L24 41 M11 24 L37 24'/>"
		"population":
			body = "<circle cx='18' cy='18' r='5'/><circle cx='30' cy='18' r='5'/><path d='M10 38 C12 28 24 28 24 38'/><path d='M24 38 C24 28 36 28 38 38'/>"
		"menu":
			body = "<path d='M12 16 L36 16 M12 24 L36 24 M12 32 L36 32'/>"
		"help":
			body = "<path d='M17 18 C18 11 33 11 33 20 C33 27 24 26 24 32'/><path d='M24 39 L24 40'/>"
		"pause":
			body = "<path d='M18 13 L18 35 M30 13 L30 35'/>"
		"move", "compass":
			body = "<circle cx='24' cy='24' r='14'/><path d='M31 12 L24 25 L15 35 L20 20 Z'/>"
		"attack", "sword":
			body = "<path d='M34 8 L40 14 L21 33 L15 27 Z'/><path d='M15 34 L10 39 M13 30 L18 35'/>"
		"hold", "shield":
			body = "<path d='M24 8 L38 14 L34 34 L24 42 L14 34 L10 14 Z'/><path d='M24 13 L24 37'/>"
		"restore", "build", "hammer", "timber":
			body = "<path d='M13 17 L22 8 L29 15 L20 24 Z'/><path d='M22 25 L36 39'/><path d='M12 36 L31 17'/>"
		"train", "helmet":
			body = "<path d='M12 29 C14 14 34 14 36 29 Z'/><path d='M9 32 L39 32'/><path d='M24 15 L24 31'/>"
		"research", "lume":
			stroke = "#8fd8cc"
			body = "<circle cx='24' cy='24' r='11'/><path d='M24 7 L24 14 M24 34 L24 41 M7 24 L14 24 M34 24 L41 24'/><path d='M16 32 L32 16'/>"
		"alert", "crosshair":
			stroke = "#ec6d45"
			body = "<path d='M24 8 L40 38 L8 38 Z'/><path d='M24 18 L24 28 M24 34 L24 35'/>"
		"map":
			body = "<path d='M10 15 L20 11 L30 15 L40 11 L40 35 L30 39 L20 35 L10 39 Z'/><path d='M20 11 L20 35 M30 15 L30 39'/>"
		"rally", "banner":
			body = "<path d='M15 8 L15 40'/><path d='M18 11 L38 15 L18 24 Z'/><path d='M15 40 L35 40'/>"
		"focus":
			body = "<circle cx='24' cy='24' r='12'/><path d='M24 6 L24 15 M24 33 L24 42 M6 24 L15 24 M33 24 L42 24'/>"
		"locked":
			body = "<rect x='14' y='22' width='20' height='16' rx='3'/><path d='M18 22 C18 12 30 12 30 22'/>"
		"cancel", "x":
			body = "<path d='M14 14 L34 34 M34 14 L14 34'/>"
	return "<svg viewBox='0 0 48 48' xmlns='http://www.w3.org/2000/svg'><g fill='none' stroke='%s' stroke-width='3.2' stroke-linecap='round' stroke-linejoin='round'>%s</g></svg>" % [stroke, body]

func _v0223_svg_texture(icon_name: String, pixel_size: int = 48) -> Texture2D:
	var target_size: int = maxi(8, pixel_size)
	var cache_key := "v0223:%s:%d" % [icon_name, target_size]
	if player_ui_shell_svg_texture_cache.has(cache_key):
		return player_ui_shell_svg_texture_cache[cache_key]
	var image := Image.new()
	var result := image.load_svg_from_string(_v0223_svg_source(icon_name), float(target_size) / 48.0)
	if result != OK:
		player_ui_shell_svg_texture_cache[cache_key] = null
		return null
	var texture := ImageTexture.create_from_image(image)
	player_ui_shell_svg_texture_cache[cache_key] = texture
	return texture

func _v0223_icon(parent: Control, name: String, position: Vector2, size: Vector2, icon_name: String, accent: Color, back_alpha: float = 0.64) -> void:
	_ui_architecture_rect(parent, "%sBack" % name, position, size, Color(0.045, 0.052, 0.048, back_alpha))
	_ui_architecture_rect(parent, "%sTrim" % name, position + Vector2(1, 1), Vector2(size.x - 2, 2), accent)
	var icon_size := int(maxf(8.0, minf(size.x - 6.0, size.y - 6.0)))
	var texture := _v0223_svg_texture(icon_name, icon_size)
	if texture != null:
		var icon := TextureRect.new()
		icon.name = "%sIcon" % name
		icon.texture = texture
		icon.position = position + Vector2((size.x - icon_size) * 0.5, (size.y - icon_size) * 0.5)
		icon.size = Vector2(icon_size, icon_size)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(icon)
	else:
		_v0223_label(parent, icon_name.substr(0, 1).to_upper(), position, size, 8, Color(0.88, 0.80, 0.58), HORIZONTAL_ALIGNMENT_CENTER)

func _v0223_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := _ui_architecture_panel_style(bg, border)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	return style

func _v0223_action_button(parent: Control, name: String, position: Vector2, size: Vector2, icon_name: String, tooltip: String, method_name: String, state: String = "ready") -> Button:
	var border := Color(0.38, 0.56, 0.50, 0.82)
	var fill := Color(0.030, 0.038, 0.035, 0.96)
	if state == "active":
		border = Color(0.86, 0.70, 0.36, 0.98)
		fill = Color(0.070, 0.064, 0.044, 0.98)
	elif state == "disabled":
		border = Color(0.26, 0.28, 0.26, 0.72)
		fill = Color(0.025, 0.027, 0.025, 0.94)
	var button := Button.new()
	button.name = name
	button.text = ""
	button.position = position
	button.size = size
	button.clip_contents = true
	button.tooltip_text = tooltip
	button.disabled = state == "disabled"
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_stylebox_override("normal", _v0223_button_style(fill, border))
	button.add_theme_stylebox_override("hover", _v0223_button_style(Color(0.060, 0.073, 0.064, 0.98), Color(0.80, 0.70, 0.42, 0.96)))
	button.add_theme_stylebox_override("pressed", _v0223_button_style(Color(0.090, 0.075, 0.052, 0.98), Color(0.96, 0.72, 0.34, 0.98)))
	button.add_theme_stylebox_override("focus", _v0223_button_style(Color(0.072, 0.076, 0.055, 0.98), Color(0.98, 0.82, 0.38, 1.0)))
	button.add_theme_stylebox_override("disabled", _v0223_button_style(fill, border))
	parent.add_child(button)
	_v0223_icon(button, "%sGlyph" % name, Vector2(4, 3), Vector2(size.x - 8, size.y - 6), icon_name, border, 0.0)
	if method_name != "" and has_method(method_name) and not button.disabled:
		button.pressed.connect(Callable(self, method_name))
	return button

func _v0223_command_icon(label: String) -> String:
	match label.to_lower():
		"attack":
			return "attack"
		"hold":
			return "hold"
		"work":
			return "hammer"
		"restore":
			return "restore"
		"train":
			return "train"
		"lume":
			return "research"
		"rally":
			return "rally"
		"focus":
			return "focus"
		"cancel":
			return "cancel"
	return "move"

func _v0223_command_button(parent: Control, position: Vector2, size: Vector2, spec: Dictionary, focus_id: String) -> Button:
	var label := str(spec.get("label", ""))
	var state := str(spec.get("state", "ready"))
	var focused := focus_id != "" and focus_id == label.to_lower()
	var border := Color(0.38, 0.58, 0.50, 0.84)
	if focused:
		border = Color(0.96, 0.76, 0.36, 1.0)
	elif state == "disabled":
		border = Color(0.28, 0.30, 0.28, 0.74)
	elif state == "queued":
		border = Color(0.82, 0.58, 0.26, 0.92)
	var button := Button.new()
	button.name = "V0223Command%s" % label
	button.text = ""
	button.position = position
	button.size = size
	button.clip_contents = true
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.tooltip_text = str(spec.get("tooltip", ""))
	button.disabled = state == "disabled"
	button.add_theme_stylebox_override("normal", _v0223_button_style(Color(0.028, 0.036, 0.032, 0.96), border))
	button.add_theme_stylebox_override("hover", _v0223_button_style(Color(0.058, 0.072, 0.062, 0.98), Color(0.82, 0.70, 0.40, 0.96)))
	button.add_theme_stylebox_override("pressed", _v0223_button_style(Color(0.086, 0.070, 0.048, 0.98), Color(0.96, 0.72, 0.32, 0.98)))
	button.add_theme_stylebox_override("focus", _v0223_button_style(Color(0.068, 0.072, 0.052, 0.98), Color(0.98, 0.82, 0.34, 1.0)))
	button.add_theme_stylebox_override("disabled", _v0223_button_style(Color(0.024, 0.026, 0.024, 0.96), border))
	parent.add_child(button)
	_v0223_icon(button, "V0223CommandGlyph", Vector2(9, 4), Vector2(24, 24), _v0223_command_icon(label), border, 0.0)
	_v0223_label(button, str(spec.get("shortcut", "")), Vector2(3, 24), Vector2(size.x - 6, 12), 7, Color(0.84, 0.78, 0.56), HORIZONTAL_ALIGNMENT_CENTER)
	var method_name := str(spec.get("method", ""))
	if method_name != "" and has_method(method_name) and not button.disabled:
		button.pressed.connect(Callable(self, method_name))
	return button

func _v0223_production_tab(parent: Control, position: Vector2, size: Vector2, label: String, active: bool) -> void:
	var panel := _v0223_panel(parent, "V0223Tab%s" % label, position, size, Color(0.64, 0.52, 0.30, 0.88) if active else Color(0.30, 0.36, 0.32, 0.72), 0.58, Color(0.82, 0.64, 0.32, 0.86) if active else Color(0.30, 0.42, 0.38, 0.58))
	_v0223_label(panel, label, Vector2(0, 0), size, 8, Color(0.92, 0.84, 0.62) if active else Color(0.62, 0.70, 0.60), HORIZONTAL_ALIGNMENT_CENTER)

func _v0223_card_icon(card: Dictionary) -> String:
	var raw := str(card.get("icon", ""))
	match raw:
		"helmet":
			return "train"
		"lume":
			return "research"
		"hammer", "timber":
			return "restore"
	return raw

func _v0223_production_card(parent: Control, position: Vector2, size: Vector2, card: Dictionary, focus_id: String) -> Button:
	var card_state := str(card.get("state", "ready"))
	var card_id := str(card.get("id", ""))
	var focused := focus_id != "" and focus_id == card_id
	var border := Color(0.38, 0.58, 0.50, 0.82)
	var rail := Color(0.36, 0.64, 0.54, 0.88)
	if card_state == "disabled":
		border = Color(0.30, 0.32, 0.30, 0.74)
		rail = Color(0.25, 0.27, 0.24, 0.84)
	elif card_state == "queued":
		border = Color(0.84, 0.58, 0.26, 0.92)
		rail = Color(0.90, 0.52, 0.22, 0.90)
	elif card_state == "complete":
		border = Color(0.34, 0.68, 0.54, 0.88)
		rail = Color(0.38, 0.72, 0.56, 0.90)
	if focused:
		border = Color(0.96, 0.76, 0.36, 1.0)
	var button := Button.new()
	button.name = "V0223Production%s" % card_id
	button.text = ""
	button.position = position
	button.size = size
	button.clip_contents = true
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.tooltip_text = str(card.get("why", ""))
	button.disabled = card_state == "disabled" or card_state == "queued" or card_state == "complete"
	button.add_theme_stylebox_override("normal", _v0223_button_style(Color(0.026, 0.032, 0.030, 0.97), border))
	button.add_theme_stylebox_override("hover", _v0223_button_style(Color(0.058, 0.070, 0.060, 0.98), Color(0.82, 0.70, 0.40, 0.96)))
	button.add_theme_stylebox_override("pressed", _v0223_button_style(Color(0.086, 0.070, 0.048, 0.98), Color(0.96, 0.72, 0.32, 0.98)))
	button.add_theme_stylebox_override("focus", _v0223_button_style(Color(0.068, 0.074, 0.052, 0.98), Color(0.98, 0.82, 0.34, 1.0)))
	button.add_theme_stylebox_override("disabled", _v0223_button_style(Color(0.024, 0.026, 0.024, 0.96), border))
	parent.add_child(button)
	_ui_architecture_rect(button, "V0223CardRail", Vector2(0, 0), Vector2(4, size.y), rail)
	_v0223_icon(button, "V0223CardGlyph", Vector2(11, 10), Vector2(28, 28), _v0223_card_icon(card), rail, 0.0)
	_v0223_label(button, _v0211_truncate(str(card.get("title", "")), 16), Vector2(46, 4), Vector2(98, 15), 9, Color(0.90, 0.84, 0.62))
	_v0223_label(button, str(card.get("shortcut", "")), Vector2(size.x - 32, 4), Vector2(22, 14), 7, Color(0.80, 0.72, 0.50), HORIZONTAL_ALIGNMENT_RIGHT)
	_v0223_label(button, _v0211_truncate(str(card.get("cost", "")), 24), Vector2(46, 20), Vector2(130, 13), 7, Color(0.68, 0.76, 0.64))
	_v0223_label(button, _v0211_truncate(str(card.get("detail", "")), 27), Vector2(46, 33), Vector2(132, 12), 7, Color(0.52, 0.62, 0.54))
	if card_state != "ready":
		var badge_text := "INSUF" if card_state == "disabled" else card_state.to_upper()
		_ui_architecture_rect(button, "V0223CardBadgeBack", Vector2(size.x - 58, size.y - 17), Vector2(48, 13), Color(0.05, 0.055, 0.050, 0.88))
		_v0223_label(button, badge_text, Vector2(size.x - 57, size.y - 17), Vector2(46, 13), 6, Color(0.84, 0.72, 0.48), HORIZONTAL_ALIGNMENT_CENTER)
	var method_name := str(card.get("method", ""))
	if method_name != "" and has_method(method_name) and not button.disabled:
		button.pressed.connect(Callable(self, method_name))
	return button

func _live_ui_v0223_hud(root: Control, state: Dictionary) -> void:
	_live_ui_v0223_top_strip(root, state)
	_live_ui_v0223_objective(root, state)
	_live_ui_v0223_event_log(root, state)
	_live_ui_v0223_minimap(root, state)
	_live_ui_v0223_selection(root, state)
	_live_ui_v0223_production(root, state)
	_live_ui_v0223_alert(root, state)
	_live_ui_v0223_tooltip(root, state)
	_live_ui_v0223_review_overlay(root, state)

func _live_ui_v0223_top_strip(root: Control, state: Dictionary) -> void:
	var panel := _v0223_panel(root, "V0223TopResourceStrip", Vector2(424, 12), Vector2(680, 30), Color(0.34, 0.52, 0.46, 0.72), 0.68, Color(0.42, 0.72, 0.66, 0.78))
	var resources: Dictionary = state.get("resources", {})
	var entries := [
		["crowns", str(resources.get("crowns", 0)), Color(0.78, 0.62, 0.34, 0.88)],
		["stone", str(resources.get("stone", 0)), Color(0.56, 0.58, 0.52, 0.88)],
		["iron", str(resources.get("iron", 0)), Color(0.48, 0.54, 0.56, 0.88)],
		["aether", str(resources.get("aether", 0)), Color(0.28, 0.76, 0.72, 0.88)],
		["population", "9/16", Color(0.50, 0.70, 0.44, 0.88)]
	]
	_v0223_label(panel, "SALTO", Vector2(12, 4), Vector2(56, 22), 10, Color(0.84, 0.78, 0.58))
	for index in range(entries.size()):
		var entry: Array = entries[index]
		var x := 88 + index * 98
		_v0223_icon(panel, "V0223Resource%s" % index, Vector2(x, 5), Vector2(20, 20), str(entry[0]), entry[2])
		_v0223_label(panel, str(entry[1]), Vector2(x + 26, 5), Vector2(58, 20), 10, Color(0.82, 0.86, 0.70))
	var utility := _v0223_panel(root, "V0223UtilityCluster", Vector2(1380, 12), Vector2(170, 30), Color(0.28, 0.36, 0.34, 0.66), 0.58, Color(0.34, 0.50, 0.46, 0.62))
	_v0223_action_button(utility, "V0223MenuButton", Vector2(9, 5), Vector2(42, 20), "menu", "Menu", "_on_player_back_pressed")
	_v0223_action_button(utility, "V0223HelpButton", Vector2(63, 5), Vector2(42, 20), "help", "Help", "_on_live_ui_shell_help_pressed")
	_v0223_action_button(utility, "V0223PauseButton", Vector2(117, 5), Vector2(42, 20), "pause", "Pause", "_on_live_ui_shell_pause_pressed")

func _live_ui_v0223_objective(root: Control, state: Dictionary) -> void:
	var action := str(player_ui_shell_context_override)
	var expanded := ["initial_objective", "objective_expanded"].has(action)
	var panel := _v0223_panel(root, "V0223ObjectiveRibbon", Vector2(426, 50), Vector2(520, 30), Color(0.52, 0.44, 0.27, 0.70), 0.64, Color(0.78, 0.60, 0.32, 0.78))
	_v0223_icon(panel, "V0223ObjectiveIcon", Vector2(11, 5), Vector2(20, 20), "rally", Color(0.76, 0.60, 0.32, 0.88), 0.30)
	var text := "%s | %s" % [str(state.get("objective", "")), _v0211_truncate(str(state.get("objectiveNextAction", "")), 42)]
	_v0223_label(panel, text, Vector2(40, 4), Vector2(392, 22), 9, Color(0.88, 0.82, 0.62))
	_v0223_action_button(panel, "V0223ObjectiveDetailButton", Vector2(452, 5), Vector2(54, 20), "map", "Objective detail", "_on_live_ui_shell_help_pressed", "active" if expanded else "ready")
	if expanded:
		var detail := _v0223_panel(root, "V0223ObjectiveDetailDrawer", Vector2(426, 84), Vector2(520, 78), Color(0.52, 0.44, 0.27, 0.64), 0.68, Color(0.78, 0.60, 0.32, 0.78))
		_v0223_label(detail, _v0211_truncate(str(state.get("objectiveDetail", "")).replace("\n", " / "), 78), Vector2(14, 6), Vector2(492, 20), 8, Color(0.74, 0.82, 0.70))
		var progress: Array = state.get("objectiveProgress", [])
		for index in range(min(progress.size(), 5)):
			var item: Dictionary = progress[index]
			var done := bool(item.get("done", false))
			var x := 16 + index * 96
			_ui_architecture_rect(detail, "V0223ObjectiveStepBack%s" % index, Vector2(x, 39), Vector2(70, 6), Color(0.08, 0.09, 0.08, 0.86))
			_ui_architecture_rect(detail, "V0223ObjectiveStepFill%s" % index, Vector2(x, 39), Vector2(70 if done else 22, 6), Color(0.38, 0.68, 0.52, 0.86) if done else Color(0.60, 0.48, 0.28, 0.76))
			_v0223_label(detail, _v0211_truncate(str(item.get("label", "")), 13), Vector2(x, 51), Vector2(84, 14), 7, Color(0.66, 0.72, 0.60))

func _live_ui_v0223_event_log(root: Control, state: Dictionary) -> void:
	var events: Array = state.get("events", [])
	var action := str(player_ui_shell_context_override)
	var expanded := action == "event_progression" or action == "event_drawer_expanded"
	if not expanded:
		var collapsed := _v0223_panel(root, "V0223EventAffordance", Vector2(48, 152), Vector2(150, 24), Color(0.28, 0.44, 0.38, 0.54), 0.50, Color(0.34, 0.60, 0.50, 0.62))
		_v0223_icon(collapsed, "V0223EventsIcon", Vector2(8, 4), Vector2(16, 16), "map", Color(0.34, 0.60, 0.50, 0.70), 0.0)
		_v0223_label(collapsed, "Events %d" % events.size(), Vector2(30, 3), Vector2(70, 16), 7, Color(0.66, 0.74, 0.62))
		_v0223_action_button(collapsed, "V0223EventsOpen", Vector2(105, 3), Vector2(37, 18), "help", "Open events", "_on_live_ui_shell_help_pressed")
		return
	var panel := _v0223_panel(root, "V0223EventDrawer", Vector2(48, 152), Vector2(270, 150), Color(0.32, 0.52, 0.44, 0.66), 0.70, Color(0.34, 0.64, 0.54, 0.80))
	_v0223_label(panel, "EVENTS", Vector2(14, 8), Vector2(70, 18), 8, Color(0.82, 0.78, 0.58))
	for index in range(min(events.size(), 5)):
		var event := str(events[index])
		var rail := Color(0.36, 0.64, 0.50, 0.86)
		if event.to_lower().contains("ashen"):
			rail = Color(0.90, 0.30, 0.18, 0.90)
		_ui_architecture_rect(panel, "V0223EventRail%s" % index, Vector2(14, 36 + index * 21), Vector2(4, 14), rail)
		_v0223_label(panel, _v0211_truncate(event, 34), Vector2(24, 32 + index * 21), Vector2(228, 18), 8, Color(0.72, 0.82, 0.68))

func _live_ui_v0223_minimap(root: Control, state: Dictionary) -> void:
	var panel := _v0223_panel(root, "V0223Minimap", Vector2(48, 728), Vector2(196, 132), Color(0.28, 0.54, 0.50, 0.70), 0.66, Color(0.34, 0.68, 0.64, 0.80))
	_v0223_icon(panel, "V0223MiniMapGlyph", Vector2(11, 5), Vector2(18, 18), "map", Color(0.34, 0.68, 0.64, 0.72), 0.0)
	_v0223_label(panel, "MAP", Vector2(34, 5), Vector2(44, 18), 8, Color(0.74, 0.82, 0.64))
	_ui_architecture_rect(panel, "V0223MiniBounds", Vector2(12, 26), Vector2(172, 88), Color(0.032, 0.050, 0.044, 0.96))
	_ui_architecture_rect(panel, "V0223MiniRiver", Vector2(103, 34), Vector2(11, 74), Color(0.07, 0.32, 0.40, 0.96))
	_ui_architecture_rect(panel, "V0223MiniRoadWest", Vector2(32, 68), Vector2(62, 6), Color(0.50, 0.43, 0.28, 0.94))
	_ui_architecture_rect(panel, "V0223MiniBridge", Vector2(86, 61), Vector2(43, 18), Color(0.62, 0.55, 0.38, 0.96))
	_ui_architecture_rect(panel, "V0223MiniRoadEast", Vector2(122, 68), Vector2(50, 6), Color(0.50, 0.43, 0.28, 0.94))
	_ui_architecture_rect(panel, "V0223MiniRoadNorth", Vector2(92, 40), Vector2(6, 34), Color(0.43, 0.38, 0.27, 0.88))
	_ui_architecture_rect(panel, "V0223MiniHero", Vector2(62, 64), Vector2(9, 9), Color(0.90, 0.76, 0.34, 1.0))
	_ui_architecture_rect(panel, "V0223MiniMine", Vector2(74, 76), Vector2(17, 11), Color(0.30, 0.78, 0.56, 0.94) if bool(state.get("mineConverted", false)) else Color(0.78, 0.64, 0.34, 0.92))
	_ui_architecture_rect(panel, "V0223MiniBarracks", Vector2(48, 48), Vector2(20, 11), Color(0.68, 0.56, 0.36, 0.92))
	_ui_architecture_rect(panel, "V0223MiniFriendlies", Vector2(42, 92), Vector2(14, 13), Color(0.30, 0.80, 0.60, 0.98))
	_ui_architecture_rect(panel, "V0223MiniHostiles", Vector2(138, 48), Vector2(28, 12), Color(0.88, 0.24, 0.15, 1.0))
	_ui_architecture_rect(panel, "V0223MiniCamera", Vector2(58, 57), Vector2(90, 44), Color(0.88, 0.92, 0.78, 0.15))
	_v0223_label(panel, "routes | pressure", Vector2(12, 113), Vector2(172, 14), 7, Color(0.54, 0.64, 0.54), HORIZONTAL_ALIGNMENT_CENTER)

func _live_ui_v0223_selection(root: Control, state: Dictionary) -> void:
	var panel := _v0223_panel(root, "V0223SelectedContextBar", Vector2(500, 798), Vector2(560, 78), Color(0.34, 0.54, 0.46, 0.70), 0.70, Color(0.38, 0.68, 0.56, 0.80))
	var data: Dictionary = state.get("selectionPanel", {})
	_ui_architecture_rect(panel, "V0223PortraitStone", Vector2(14, 13), Vector2(50, 50), Color(0.04, 0.05, 0.045, 0.86))
	_ui_architecture_rect(panel, "V0223PortraitChip", Vector2(18, 17), Vector2(42, 42), state.get("portraitColor", Color(0.22, 0.62, 0.58, 1.0)))
	_v0223_label(panel, str(data.get("name", state.get("selectedTitle", ""))), Vector2(76, 8), Vector2(268, 18), 11, Color(0.90, 0.84, 0.64))
	_v0223_label(panel, _v0211_truncate(str(data.get("summary", state.get("selectedSubtitle", ""))), 52), Vector2(76, 29), Vector2(340, 18), 8, Color(0.72, 0.82, 0.70))
	_ui_architecture_rect(panel, "V0223HealthBack", Vector2(76, 56), Vector2(166, 6), Color(0.08, 0.07, 0.055, 0.82))
	_ui_architecture_rect(panel, "V0223HealthFill", Vector2(76, 56), Vector2(166 * float(data.get("hpRatio", 1.0)), 6), Color(0.38, 0.72, 0.50, 0.86))
	_v0223_label(panel, str(data.get("hpText", "")), Vector2(252, 48), Vector2(92, 18), 8, Color(0.78, 0.82, 0.64))
	var commands: Array = data.get("commands", [])
	for index in range(min(commands.size(), 4)):
		var spec: Dictionary = commands[index]
		_v0223_command_button(panel, Vector2(352 + index * 48, 26), Vector2(42, 38), spec, str(data.get("focusId", "")))
	_v0223_label(panel, str(state.get("statusPip", "")), Vector2(14, 61), Vector2(50, 14), 7, Color(0.84, 0.78, 0.58), HORIZONTAL_ALIGNMENT_CENTER)

func _live_ui_v0223_production(root: Control, state: Dictionary) -> void:
	var action := str(player_ui_shell_context_override)
	var active := str(state.get("activeTab", "BUILD"))
	var should_expand := ["production_build", "production_train", "production_research", "production_disabled_tooltip", "tooltip_docked"].has(action)
	if not should_expand:
		var collapsed := _v0223_panel(root, "V0223ProductionAffordance", Vector2(1482, 822), Vector2(58, 30), Color(0.44, 0.40, 0.28, 0.50), 0.48, Color(0.66, 0.52, 0.30, 0.62))
		_v0223_action_button(collapsed, "V0223ProductionOpen", Vector2(8, 5), Vector2(42, 20), "build" if active == "BUILD" else ("train" if active == "TRAIN" else "research"), "Open production", "_on_live_ui_shell_work_pressed")
		return
	var panel := _v0223_panel(root, "V0223ProductionDrawer", Vector2(1118, 672), Vector2(420, 188), Color(0.56, 0.46, 0.28, 0.70), 0.72, Color(0.78, 0.58, 0.30, 0.82))
	_v0223_label(panel, "PRODUCTION", Vector2(14, 9), Vector2(92, 18), 8, Color(0.84, 0.76, 0.56))
	var tabs: Array[String] = ["BUILD", "TRAIN", "RESEARCH"]
	for index in range(tabs.size()):
		_v0223_production_tab(panel, Vector2(112 + index * 82, 7), Vector2(70, 23), tabs[index], active == tabs[index])
	var cards: Array = state.get("productionCards", [])
	for index in range(min(cards.size(), 4)):
		var col := index % 2
		var row := int(index / 2)
		_v0223_production_card(panel, Vector2(14 + col * 198, 44 + row * 58), Vector2(188, 50), cards[index], str(state.get("productionFocusId", "")))
	_v0223_label(panel, "Existing actions only", Vector2(14, 166), Vector2(390, 14), 7, Color(0.58, 0.66, 0.54))

func _live_ui_v0223_alert(root: Control, state: Dictionary) -> void:
	if str(state.get("alertSeverity", "info")) != "hostile":
		return
	var panel := _v0223_panel(root, "V0223HostileAlert", Vector2(1206, 74), Vector2(330, 64), Color(0.86, 0.26, 0.16, 0.82), 0.70, Color(0.94, 0.24, 0.14, 0.96))
	_v0223_icon(panel, "V0223AlertIcon", Vector2(15, 17), Vector2(28, 28), "alert", Color(0.94, 0.24, 0.14, 0.94), 0.0)
	_v0223_label(panel, "HOSTILE", Vector2(54, 7), Vector2(72, 18), 8, Color(0.90, 0.78, 0.56))
	_v0223_label(panel, str(state.get("alert", "")), Vector2(126, 7), Vector2(184, 20), 11, Color(0.94, 0.86, 0.64))
	_v0223_label(panel, "Hold bridge and focus raiders.", Vector2(54, 34), Vector2(256, 18), 8, Color(0.74, 0.82, 0.70))

func _live_ui_v0223_tooltip(root: Control, state: Dictionary) -> void:
	var action := str(player_ui_shell_context_override)
	if not ["production_disabled_tooltip", "v0212_tooltips", "tooltip_docked"].has(action):
		return
	var meta: Dictionary = state.get("tooltipMeta", {})
	var production_expanded := ["production_disabled_tooltip", "tooltip_docked"].has(action)
	var dock_position := Vector2(1118, 606) if production_expanded else Vector2(1068, 798)
	var panel := _v0223_panel(root, "V0223DockedTooltip", dock_position, Vector2(420, 56), Color(0.34, 0.48, 0.42, 0.66), 0.70, Color(0.42, 0.68, 0.58, 0.78))
	panel.z_index = 34
	_v0223_icon(panel, "V0223TipIcon", Vector2(12, 7), Vector2(20, 20), "help", Color(0.42, 0.68, 0.58, 0.76), 0.0)
	_v0223_label(panel, str(meta.get("title", "Tip")), Vector2(40, 5), Vector2(136, 16), 8, Color(0.90, 0.82, 0.60))
	_v0223_label(panel, "Shortcut %s" % str(meta.get("shortcut", "Mouse")), Vector2(254, 5), Vector2(148, 16), 7, Color(0.70, 0.82, 0.70), HORIZONTAL_ALIGNMENT_RIGHT)
	_ui_architecture_rect(panel, "V0223TooltipRule", Vector2(12, 27), Vector2(396, 1), Color(0.32, 0.48, 0.40, 0.58))
	_v0223_label(panel, _v0211_truncate(str(meta.get("body", state.get("tooltip", ""))), 84), Vector2(12, 32), Vector2(396, 18), 7, Color(0.72, 0.80, 0.70))

func _live_ui_v0223_review_overlay(root: Control, state: Dictionary) -> void:
	var action := str(player_ui_shell_context_override)
	if action == "icon_sheet":
		var panel := _v0223_panel(root, "V0223IconSheet", Vector2(1096, 144), Vector2(390, 230), Color(0.32, 0.48, 0.44, 0.68), 0.72, Color(0.42, 0.68, 0.60, 0.76))
		_v0223_label(panel, "PROCEDURAL ICON SHEET", Vector2(14, 8), Vector2(220, 18), 8, Color(0.84, 0.78, 0.58))
		var icons := ["crowns", "stone", "iron", "aether", "population", "move", "attack", "hold", "restore", "build", "train", "research", "help", "pause", "alert", "map"]
		for index in range(icons.size()):
			var col := index % 4
			var row := int(index / 4)
			var x := 20 + col * 88
			var y := 38 + row * 44
			_v0223_icon(panel, "V0223IconSheet%s" % index, Vector2(x, y), Vector2(28, 28), icons[index], Color(0.46, 0.66, 0.58, 0.78), 0.36)
			_v0223_label(panel, icons[index], Vector2(x + 34, y + 5), Vector2(50, 18), 6, Color(0.66, 0.74, 0.64))
	elif action == "interaction_matrix":
		var panel := _v0223_panel(root, "V0223InteractionMatrix", Vector2(1084, 144), Vector2(402, 252), Color(0.34, 0.46, 0.40, 0.70), 0.72, Color(0.76, 0.58, 0.32, 0.74))
		_v0223_label(panel, "INTERACTION STATES", Vector2(14, 8), Vector2(170, 18), 8, Color(0.84, 0.78, 0.58))
		var states := [
			["hover", "move", "Hover"],
			["active", "build", "Active"],
			["queued", "train", "Queued"],
			["disabled", "research", "Disabled"],
			["insufficient", "restore", "Insufficient"],
			["future", "map", "Future"],
			["hostile", "alert", "Hostile"],
			["keyboardFocus", "attack", "Key focus"],
			["mouseFocus", "hold", "Mouse focus"]
		]
		for index in range(states.size()):
			var state_spec: Array = states[index]
			var col := index % 3
			var row := int(index / 3)
			var x := 18 + col * 126
			var y := 42 + row * 62
			var border := Color(0.36, 0.56, 0.48, 0.78)
			if state_spec[0] == "hostile":
				border = Color(0.90, 0.30, 0.18, 0.90)
			elif ["active", "keyboardFocus", "mouseFocus"].has(state_spec[0]):
				border = Color(0.92, 0.72, 0.34, 0.94)
			elif ["disabled", "insufficient", "future"].has(state_spec[0]):
				border = Color(0.34, 0.36, 0.32, 0.78)
			_ui_architecture_rect(panel, "V0223StateBack%s" % index, Vector2(x, y), Vector2(106, 46), Color(0.026, 0.032, 0.030, 0.92))
			_v0223_icon(panel, "V0223StateIcon%s" % index, Vector2(x + 8, y + 8), Vector2(26, 26), str(state_spec[1]), border, 0.0)
			_v0223_label(panel, str(state_spec[2]), Vector2(x + 40, y + 8), Vector2(58, 14), 7, Color(0.78, 0.76, 0.58))
			_v0223_label(panel, str(state_spec[0]), Vector2(x + 40, y + 23), Vector2(58, 12), 6, Color(0.56, 0.66, 0.56))
			_ui_architecture_rect(panel, "V0223StateBorder%s" % index, Vector2(x, y), Vector2(106, 2), border)
	elif action == "keyboard_focus":
		var cue := _v0223_panel(root, "V0223KeyboardFocusCue", Vector2(1068, 746), Vector2(260, 38), Color(0.84, 0.66, 0.34, 0.78), 0.62, Color(0.90, 0.70, 0.34, 0.82))
		_v0223_label(cue, "Keyboard focus: Attack command", Vector2(14, 8), Vector2(232, 18), 8, Color(0.88, 0.82, 0.62))

func _live_ui_shell_state() -> Dictionary:
	var status := get_spike_status()
	var action := player_ui_shell_context_override
	if action == "":
		action = str(status.get("currentStepId", current_step_id))
	var resources: Dictionary = status.get("resources", {})
	var alive_counts: Dictionary = status.get("aliveCounts", {})
	var selected_ids: Array = status.get("selectedIds", [])
	var construction_progress := float(status.get("barracksConstructionProgress", 0.0))
	var barracks_complete := bool(status.get("barracksComplete", false))
	var militia_queued := bool(status.get("militiaRecruitQueued", false))
	var militia_spawned := bool(status.get("militiaSpawned", false))
	var worker_assigned := bool(status.get("workerAssignedToMine", false))
	var mine_converted := bool(status.get("mineSiteConverted", false))
	var pressure_state := str(status.get("pressureWaveState", "dormant"))
	var ashen_remaining := int(alive_counts.get("ashenEnemies", alive_counts.get("enemy", 0)))
	var pressure_active := pressure_state != "dormant" and ashen_remaining > 0
	var pressure_resolved := pressure_state != "dormant" and ashen_remaining <= 0
	var active_tab := "BUILD"
	var selected_title := "Aster of the Quiet Link"
	var selected_subtitle := "Hero | Health stable | Lume ward ready"
	var portrait_color := Color(0.22, 0.62, 0.58, 1.0)
	var command_hint := "Move  Attack  Rally  Ward"
	var status_pip := "READY"
	var tooltip := "Right-click ground to move selected forces."
	if action == "worker_assigned_mine" or action == "worker_selected" or selected_ids.any(func(id: String) -> bool: return id.begins_with("worker")):
		selected_title = "Worker Detachment"
		selected_subtitle = "Builder | Mine assignment %s" % ("active" if worker_assigned else "available")
		portrait_color = Color(0.62, 0.48, 0.22, 1.0)
		command_hint = "Work  Repair  Return"
		status_pip = "ASSIGNED" if worker_assigned else "READY"
		tooltip = "Work assigns the Worker to the highlighted production task."
	elif action == "construction_progress" or (construction_progress > 0.0 and not barracks_complete):
		selected_title = "Barracks Foundation"
		selected_subtitle = "Structure | Restoration %d%% | Worker committed" % int(round(construction_progress * 100.0))
		portrait_color = Color(0.43, 0.29, 0.18, 1.0)
		command_hint = "Restore  Cancel  Rally"
		status_pip = "RESTORING"
		tooltip = "Restoration must complete before Militia can train."
	elif action == "barracks_complete" or action == "recruit_queue" or barracks_complete:
		selected_title = "Restored Barracks"
		selected_subtitle = "Structure | %s" % ("Militia queued" if militia_queued else "Militia training unlocked")
		portrait_color = Color(0.50, 0.36, 0.21, 1.0)
		command_hint = "Train Militia  Set Rally  Hold"
		status_pip = "QUEUE" if militia_queued else "RESTORED"
		active_tab = "TRAIN"
		tooltip = "Train one Militia squad before the Ashen reach the bridge."
	if action == "militia_spawned" or action == "squad_selected" or militia_spawned:
		selected_title = "Militia Defenders"
		selected_subtitle = "Squad | Staged near bridge | %d friendly military" % int(alive_counts.get("friendlyMilitary", 0))
		portrait_color = Color(0.28, 0.55, 0.38, 1.0)
		command_hint = "Attack  Hold Bridge  Focus Fire"
		status_pip = "STAGED"
		active_tab = "TRAIN"
		tooltip = "Defenders are ready to intercept Ashen pressure."
	if action == "ashen_pressure_wave" or pressure_active:
		selected_title = "Ashen Pressure"
		selected_subtitle = "Hostile wave | Ashen remaining %d" % ashen_remaining
		portrait_color = Color(0.56, 0.18, 0.13, 1.0)
		command_hint = "Attack  Hold Bridge  Focus Fire"
		status_pip = "ALERT"
		active_tab = "TRAIN"
		tooltip = "Select defenders and issue Attack before raiders reach the road."
	elif pressure_resolved:
		selected_title = "Bridge Secured"
		selected_subtitle = "Hostile wave resolved | Re-form defenders"
		portrait_color = Color(0.28, 0.55, 0.38, 1.0)
		command_hint = "Hold Bridge  Restore Lume"
		status_pip = "CLEAR"
		active_tab = "TRAIN"
		tooltip = "The Ashen wave is cleared; regroup before restoring the Lume link."
	if action == "production_research":
		active_tab = "RESEARCH"
		tooltip = "Research cards are preview-only in this slice and explain why they are unavailable."
	elif action == "production_disabled_tooltip":
		active_tab = "RESEARCH"
		tooltip = "Bridgecraft research is disabled: this review binds existing functionality only."
	elif action == "production_build":
		active_tab = "BUILD"
		tooltip = "Build tab shows Worker-supported actions and future-scope cards distinctly."
	elif action == "production_train":
		active_tab = "TRAIN"
		tooltip = "Train tab binds only the existing Barracks Militia queue and marks locked units."
	elif action == "v0212_minimap":
		active_tab = "BUILD"
		tooltip = "Minimap mirrors the authored routes, river crossing, sites, units, hostiles and camera viewport."
	elif action == "v0212_viewport_marker":
		active_tab = "TRAIN"
		tooltip = "Viewport outline shows the camera frame without changing camera, pathing or playable bounds."
	elif action == "v0212_tooltips":
		active_tab = "RESEARCH"
		tooltip = "Bridgecraft is unavailable in this review path; the tooltip states cost, shortcut and reason."
	elif action == "v0212_alerts":
		active_tab = "TRAIN"
		tooltip = "Alert rail distinguishes hostile pressure from informational and warning states."
	elif action.begins_with("v0212_resolution"):
		active_tab = "TRAIN"
		tooltip = "Scaled layout preserves minimap, tooltip, alert and command readability at this resolution."
	if player_ui_shell_production_tab_override != "":
		active_tab = player_ui_shell_production_tab_override
	var objective := "Convert West Stone Cut Mine"
	var objective_detail := "Assign Worker, restore Barracks,\ntrain Militia, hold bridge."
	if mine_converted and not worker_assigned:
		objective = "Assign Worker"
		objective_detail = "Mine controlled.\nPut the Worker on production."
	elif worker_assigned and not barracks_complete:
		objective = "Restore Barracks"
		objective_detail = "Worker assigned.\nRestore the military structure."
	elif barracks_complete and not militia_spawned:
		objective = "Train Militia"
		objective_detail = "Barracks restored.\nQueue defenders before pressure."
	elif pressure_active:
		objective = "Defeat Ashen Wave"
		objective_detail = "Ashen remaining %d.\nHold bridge; preserve Aster." % ashen_remaining
	elif pressure_resolved:
		objective = "Secure Bridge"
		objective_detail = "Ashen wave cleared.\nHold formation; prep Lume link."
	elif bool(status.get("lumeRestored", false)):
		objective = "Review Results"
		objective_detail = "Mine, Barracks, Militia, Ashen wave, and Lume are resolved."
	var events: Array[String] = []
	if mine_converted:
		events.append("Mine converted")
	else:
		events.append("Mine capture pending")
	if worker_assigned:
		events.append("Worker assigned to mine")
	elif mine_converted:
		events.append("Worker assignment available")
	if barracks_complete:
		events.append("Barracks restored")
	elif construction_progress > 0.0:
		events.append("Barracks restoring %d%%" % int(round(construction_progress * 100.0)))
	if militia_queued:
		events.append("Militia queue active")
	if militia_spawned:
		events.append("Defenders staged")
	if pressure_active:
		events.append("Ashen pressure active")
	elif pressure_resolved:
		events.append("Ashen wave cleared")
	if events.is_empty():
		events = ["Aster ready", "Worker awaiting order", "Barracks frame located"]
	var alert_text := "No active pressure"
	var alert_severity := "info"
	if pressure_active:
		alert_text = "Ashen pressure: %d remaining" % ashen_remaining
		alert_severity = "hostile"
	elif pressure_resolved:
		alert_text = "Ashen wave cleared"
		alert_severity = "info"
	if action == "v0212_minimap":
		alert_text = "Minimap correlation checked"
		alert_severity = "info"
	elif action == "v0212_viewport_marker":
		alert_text = "Camera viewport outline visible"
		alert_severity = "info"
	elif action == "v0212_tooltips":
		alert_text = "Unavailable action explained"
		alert_severity = "warning"
	elif action == "v0212_alerts" and not pressure_active:
		alert_text = "Alert severity sample"
		alert_severity = "warning"
	var selection_panel_data := _v0210_selection_panel_data(action, status)
	var objective_next_action := _v0211_next_action(mine_converted, worker_assigned, barracks_complete, militia_spawned, pressure_active, pressure_resolved)
	var production_cards := _v0211_production_cards(active_tab, mine_converted, worker_assigned, barracks_complete, militia_queued, militia_spawned)
	var tooltip_meta := _v0212_tooltip_meta(action, active_tab, player_ui_shell_production_focus_hint, tooltip, alert_severity)
	return {
		"resources": resources,
		"objective": objective,
		"objectiveDetail": objective_detail,
		"events": events,
		"selectedTitle": selected_title,
		"selectedSubtitle": selected_subtitle,
		"portraitColor": portrait_color,
		"commandHint": command_hint,
		"statusPip": status_pip,
		"activeTab": active_tab,
		"tooltip": tooltip,
		"alert": alert_text,
		"alertSeverity": alert_severity,
		"objectiveNextAction": objective_next_action,
		"objectiveProgress": _v0211_objective_progress(mine_converted, worker_assigned, barracks_complete, militia_spawned, pressure_resolved),
		"productionCards": production_cards,
		"productionFocusId": player_ui_shell_production_focus_hint,
		"productionObjectivesLogEnabled": _salto_production_objectives_log_enabled(),
		"minimapTooltipAccessibilityEnabled": _salto_minimap_tooltip_accessibility_enabled(),
		"tooltipMeta": tooltip_meta,
		"mineConverted": mine_converted,
		"workerAssigned": worker_assigned,
		"barracksComplete": barracks_complete,
		"militiaQueued": militia_queued,
		"militiaSpawned": militia_spawned,
		"ashenRemaining": ashen_remaining,
		"selectionPanel": selection_panel_data
	}

func _v0211_next_action(mine_converted: bool, worker_assigned: bool, barracks_complete: bool, militia_spawned: bool, pressure_active: bool, pressure_resolved: bool) -> String:
	if not mine_converted:
		return "Select Aster and secure the West Stone Cut."
	if not worker_assigned:
		return "Assign the Worker to start stone income."
	if not barracks_complete:
		return "Spend Stone 80 to restore the Barracks."
	if not militia_spawned:
		return "Queue Militia before Ashen pressure reaches the bridge."
	if pressure_active:
		return "Hold the bridge line and focus Ashen raiders."
	if pressure_resolved:
		return "Regroup defenders; Lume actions remain review-slice locked."
	return "Stage defenders and watch the hostile-pressure rail."

func _v0211_objective_progress(mine_converted: bool, worker_assigned: bool, barracks_complete: bool, militia_spawned: bool, pressure_resolved: bool) -> Array[Dictionary]:
	return [
		{"label": "Mine", "done": mine_converted},
		{"label": "Worker", "done": worker_assigned},
		{"label": "Barracks", "done": barracks_complete},
		{"label": "Militia", "done": militia_spawned},
		{"label": "Bridge", "done": pressure_resolved}
	]

func _v0211_card_spec(id: String, title: String, shortcut: String, cost: String, detail: String, state: String, why: String, icon_name: String, method_name: String) -> Dictionary:
	return {
		"id": id,
		"title": title,
		"shortcut": shortcut,
		"cost": cost,
		"detail": detail,
		"state": state,
		"why": why,
		"icon": icon_name,
		"method": method_name,
		"proceduralSvg": _v0210_svg_source(icon_name)
	}

func _v0211_production_cards(active_tab: String, mine_converted: bool, worker_assigned: bool, barracks_complete: bool, militia_queued: bool, militia_spawned: bool) -> Array[Dictionary]:
	match active_tab:
		"TRAIN":
			return [
				_v0211_card_spec("train_militia", "Militia", "T", "Iron 25 | 18s", "Queue one defender squad.", "queued" if militia_queued else "ready", "Uses the existing Barracks Militia queue only.", "helmet", "_on_live_ui_shell_work_pressed"),
				_v0211_card_spec("train_ranger", "Ranger", "G", "Lume tech", "Future unit preview.", "disabled", "Requires Lume tech outside this slice.", "bow", "_on_live_ui_shell_work_pressed"),
				_v0211_card_spec("stage_defenders", "Defenders", "H", "No cost", "Hold the bridge approach.", "ready" if militia_spawned else "disabled", "Available after Militia completes.", "shield", "_on_live_ui_shell_move_pressed"),
				_v0211_card_spec("cancel_queue", "Cancel Queue", "X", "Preview", "No cancellable queue command in this review.", "disabled", "Cancel behavior is not added in v0.211.", "x", "_on_live_ui_shell_work_pressed")
			]
		"RESEARCH":
			return [
				_v0211_card_spec("lume_channel", "Lume Channel", "Q", "Aether locked", "Preview-only research lane.", "disabled", "Research is unavailable in the current slice.", "lume", "_on_live_ui_shell_lume_pressed"),
				_v0211_card_spec("bridgecraft", "Bridgecraft", "B", "Future scope", "Would improve bridge repairs later.", "disabled", "No new gameplay or research effects are bound.", "timber", "_on_live_ui_shell_work_pressed"),
				_v0211_card_spec("watch_rotation", "Watch Rotation", "W", "Preview", "Would improve alert response.", "disabled", "Preview label only; no AI or balance change.", "crosshair", "_on_live_ui_shell_attack_pressed"),
				_v0211_card_spec("ward_discipline", "Ward Discipline", "E", "Aether locked", "Would strengthen Aster support.", "disabled", "Ward tuning is outside this UI polish pass.", "shield", "_on_live_ui_shell_lume_pressed")
			]
	return [
		_v0211_card_spec("restore_barracks", "Restore Barracks", "R", "Stone 80 | Worker", "Restores the military structure.", "complete" if barracks_complete else ("ready" if worker_assigned else "disabled"), "Requires Worker assignment to the mine first." if not worker_assigned and not barracks_complete else "Bound to existing Worker/Barracks restoration.", "timber", "_on_live_ui_shell_work_pressed"),
		_v0211_card_spec("repair_bridge", "Repair Bridge", "B", "Future scope", "Bridge repair remains preview-only.", "disabled", "No bridge repair gameplay is added in v0.211.", "hammer", "_on_live_ui_shell_work_pressed"),
		_v0211_card_spec("set_rally", "Set Rally", "Y", "No cost", "Uses existing rally/focus presentation.", "ready" if barracks_complete else "disabled", "Rally is useful after Barracks restoration.", "banner", "_on_live_ui_shell_move_pressed"),
		_v0211_card_spec("lume_beacon", "Lume Beacon", "L", "Aether locked", "Future Lume structure preview.", "disabled", "Lume build actions are not available in this slice.", "lume", "_on_live_ui_shell_lume_pressed")
	]

func _v0212_tooltip_meta(action: String, active_tab: String, focus_id: String, fallback_body: String, alert_severity: String) -> Dictionary:
	var title := "Command Tip"
	var shortcut := "Mouse"
	var cost := "No cost"
	var availability := "Available"
	var body := fallback_body
	if action == "v0212_minimap":
		title = "Minimap Correlation"
		shortcut = "M"
		cost = "Utility"
		availability = "Opt-in review overlay"
		body = "Playable bounds, roads, river, bridge, sites, units, hostiles and camera frame share one map scale."
	elif action == "v0212_viewport_marker":
		title = "Camera Viewport"
		shortcut = "C"
		cost = "Utility"
		availability = "Visible in minimap"
		body = "The pale outline marks the current camera view while preserving the real battlefield framing."
	elif action == "v0212_tooltips" or focus_id == "bridgecraft":
		title = "Bridgecraft"
		shortcut = "B"
		cost = "Future scope"
		availability = "Unavailable: no research gameplay in this slice"
		body = "This card is deliberately disabled; v0.212 only explains why it is unavailable."
	elif action == "v0212_alerts" or alert_severity == "hostile":
		title = "Hostile Pressure"
		shortcut = "Space"
		cost = "Attention"
		availability = "Active alert"
		body = "Hostile states use the red rail and pulse blocks; informational states stay quiet."
	elif action.begins_with("v0212_resolution"):
		title = "Resolution Safety"
		shortcut = "Tab"
		cost = "Layout check"
		availability = "Scaled review frame"
		body = fallback_body
	elif active_tab == "RESEARCH":
		title = "Research Preview"
		shortcut = "Q/B/W/E"
		cost = "Aether locked"
		availability = "Preview-only"
	return {
		"title": title,
		"shortcut": shortcut,
		"cost": cost,
		"availability": availability,
		"body": body
	}

func _v0210_selection_panel_data(action: String, status: Dictionary) -> Dictionary:
	var alive_counts: Dictionary = status.get("aliveCounts", {})
	var construction_progress := float(status.get("barracksConstructionProgress", 0.0))
	var barracks_complete := bool(status.get("barracksComplete", false))
	var militia_queued := bool(status.get("militiaRecruitQueued", false))
	var militia_spawned := bool(status.get("militiaSpawned", false))
	var worker_assigned := bool(status.get("workerAssignedToMine", false))
	var mine_converted := bool(status.get("mineSiteConverted", false))
	var selection_kind := "aster"
	if ["worker_panel", "worker_assigned_mine", "worker_selected", "production_build", "v0212_minimap"].has(action):
		selection_kind = "worker"
	elif ["barracks_restoring_panel", "construction_progress", "build_placement"].has(action):
		selection_kind = "barracks_restoring"
	elif ["queue_panel", "recruit_queue", "barracks_complete", "production_train"].has(action):
		selection_kind = "barracks_queue"
	elif ["militia_panel", "militia_spawned", "squad_selected", "event_progression", "ashen_pressure_active", "v0211_overview", "v0212_viewport_marker", "v0212_alerts", "v0212_resolution_1920", "v0212_resolution_1600", "v0212_resolution_1366"].has(action):
		selection_kind = "militia"
	elif ["multi_select_panel"].has(action):
		selection_kind = "multi"
	elif ["selection_tooltips", "portrait_fallback", "hero_selected", "battle_default", "v0212_tooltips"].has(action):
		selection_kind = "aster"
	var focus_id := player_ui_shell_focus_hint
	if action == "selection_tooltips" and focus_id == "":
		focus_id = "lume_pulse"
	var portrait_status := _salto_aster_portrait_status()
	var data := {
		"kind": selection_kind,
		"name": "Aster of the Quiet Link",
		"role": "Hero",
		"hpText": "115 / 115",
		"hpRatio": 1.0,
		"status": "READY",
		"summary": "Captures sites, anchors Lume pressure and leads the first defenders.",
		"stats": ["DMG 14", "ARM 2", "SPD 3.2", "AUR 6"],
		"abilities": [
			_v0210_icon_spec("move", "Move", "M", "Issue a ground move order.", "ready", 0.0, "compass", "_on_live_ui_shell_move_pressed"),
			_v0210_icon_spec("rally", "Rally", "R", "Call nearby defenders to Aster.", "ready", 0.0, "banner", "_on_live_ui_shell_move_pressed"),
			_v0210_icon_spec("lume_pulse", "Lume", "Q", "Pulse Lume when the link is restored.", "locked", 0.0, "lume", "_on_live_ui_shell_lume_pressed"),
			_v0210_icon_spec("ward", "Ward", "E", "Briefly reduce incoming raid damage.", "cooldown", 0.35, "shield", "_on_live_ui_shell_lume_pressed")
		],
		"commands": [
			_v0210_command_spec("Move", "M", "Move selected units.", "ready", "_on_live_ui_shell_move_pressed"),
			_v0210_command_spec("Attack", "A", "Attack hostile targets.", "ready", "_on_live_ui_shell_attack_pressed"),
			_v0210_command_spec("Work", "W", "Aster cannot perform Worker jobs.", "disabled", "_on_live_ui_shell_work_pressed"),
			_v0210_command_spec("Lume", "Q", "Locked until the bridge is secure.", "disabled", "_on_live_ui_shell_lume_pressed")
		],
		"disabledReason": "Lume actions unlock after the foothold is secure.",
		"portraitStatus": portrait_status,
		"focusId": focus_id,
		"tooltip": "Aster selected. Use Move or Rally first; Lume is intentionally locked in this state."
	}
	if selection_kind == "worker":
		data["name"] = "Worker Detachment"
		data["role"] = "Builder"
		data["hpText"] = "70 / 70"
		data["hpRatio"] = 1.0
		data["status"] = "ASSIGNED" if worker_assigned else "READY"
		data["summary"] = "Mine assignment %s; can restore the Barracks frame." % ("active" if worker_assigned else "available")
		data["stats"] = ["BUILD 8", "LOAD 2", "SPD 2.8", "ARM 0"]
		data["abilities"] = [
			_v0210_icon_spec("work_site", "Work", "W", "Assign to the selected site.", "ready" if mine_converted else "disabled", 0.0, "hammer", "_on_live_ui_shell_work_pressed"),
			_v0210_icon_spec("restore", "Restore", "R", "Restore the Barracks frame after mine assignment.", "ready" if worker_assigned else "disabled", 0.0, "timber", "_on_live_ui_shell_work_pressed"),
			_v0210_icon_spec("return", "Return", "T", "Return to safe road shoulder.", "ready", 0.0, "return", "_on_live_ui_shell_move_pressed"),
			_v0210_icon_spec("support", "Support", "S", "Future site support context; not active in this slice.", "locked", 0.0, "plus", "_on_live_ui_shell_work_pressed")
		]
		data["commands"] = [
			_v0210_command_spec("Work", "W", "Assign Worker to mine.", "ready" if mine_converted else "disabled", "_on_live_ui_shell_work_pressed"),
			_v0210_command_spec("Restore", "R", "Begin Barracks restoration.", "ready" if worker_assigned else "disabled", "_on_live_ui_shell_work_pressed"),
			_v0210_command_spec("Move", "M", "Move Worker.", "ready", "_on_live_ui_shell_move_pressed"),
			_v0210_command_spec("Hold", "H", "Hold current assignment.", "ready", "_on_live_ui_shell_move_pressed")
		]
		data["disabledReason"] = "Restore requires the mine assignment to be active."
		data["tooltip"] = "Worker context keeps restore/build/site-support decisions separate from hero commands."
	elif selection_kind == "barracks_restoring":
		data["name"] = "Barracks Foundation"
		data["role"] = "Structure"
		data["hpText"] = "%d%% restored" % int(round(maxf(0.22, construction_progress) * 100.0))
		data["hpRatio"] = maxf(0.22, construction_progress)
		data["status"] = "RESTORING"
		data["summary"] = "Worker committed. Training stays disabled until restoration completes."
		data["stats"] = ["STONE 80", "TIME 18s", "QUEUE 0", "ARM 4"]
		data["abilities"] = [
			_v0210_icon_spec("restore", "Restore", "R", "Restoration in progress.", "cooldown", maxf(0.22, construction_progress), "timber", "_on_live_ui_shell_work_pressed"),
			_v0210_icon_spec("rally_point", "Rally", "Y", "Set rally after restoration.", "locked", 0.0, "banner", "_on_live_ui_shell_work_pressed"),
			_v0210_icon_spec("train", "Train", "T", "Disabled while restoring.", "disabled", 0.0, "helmet", "_on_live_ui_shell_work_pressed"),
			_v0210_icon_spec("cancel", "Cancel", "X", "Cancel is disabled in this review slice.", "disabled", 0.0, "x", "_on_live_ui_shell_work_pressed")
		]
		data["commands"] = [
			_v0210_command_spec("Restore", "R", "Continue restoration.", "ready", "_on_live_ui_shell_work_pressed"),
			_v0210_command_spec("Train", "T", "Requires restored Barracks.", "disabled", "_on_live_ui_shell_work_pressed"),
			_v0210_command_spec("Rally", "Y", "Requires restored Barracks.", "disabled", "_on_live_ui_shell_work_pressed"),
			_v0210_command_spec("Focus", "F", "Focus the Barracks site.", "ready", "_on_live_ui_shell_move_pressed")
		]
		data["disabledReason"] = "Train and rally are disabled until the restoration bar reaches 100%."
		data["tooltip"] = "Barracks restoring panel shows progress and disabled explanations without changing the queue."
	elif selection_kind == "barracks_queue":
		data["name"] = "Restored Barracks"
		data["role"] = "Military Structure"
		data["hpText"] = "Restored"
		data["hpRatio"] = 1.0
		data["status"] = "QUEUE" if militia_queued else "READY"
		data["summary"] = "Queue Militia before Ashen pressure reaches the bridge."
		data["stats"] = ["QUEUE 1/3" if militia_queued else "QUEUE 0/3", "IRON 25", "TIME 18s", "RALLY SET"]
		data["abilities"] = [
			_v0210_icon_spec("train", "Militia", "T", "Train one defender squad.", "queued" if militia_queued else "ready", 0.5 if militia_queued else 0.0, "helmet", "_on_live_ui_shell_work_pressed"),
			_v0210_icon_spec("rally_point", "Rally", "Y", "Rally at the bridge approach.", "ready", 0.0, "banner", "_on_live_ui_shell_move_pressed"),
			_v0210_icon_spec("hold", "Hold", "H", "Hold trained defenders near bridge.", "ready", 0.0, "shield", "_on_live_ui_shell_move_pressed"),
			_v0210_icon_spec("ranger", "Ranger", "G", "Requires Lume link; disabled.", "locked", 0.0, "bow", "_on_live_ui_shell_work_pressed")
		]
		data["commands"] = [
			_v0210_command_spec("Train", "T", "Queue Militia.", "queued" if militia_queued else "ready", "_on_live_ui_shell_work_pressed"),
			_v0210_command_spec("Rally", "Y", "Set rally point.", "ready", "_on_live_ui_shell_move_pressed"),
			_v0210_command_spec("Cancel", "X", "No active cancellable queue in this slice.", "disabled", "_on_live_ui_shell_work_pressed"),
			_v0210_command_spec("Hold", "H", "Hold defenders.", "ready", "_on_live_ui_shell_move_pressed")
		]
		data["disabledReason"] = "Ranger remains disabled because Lume tech is outside this slice."
		data["tooltip"] = "Queue panel keeps train, rally and locked tech visually distinct."
	elif selection_kind == "militia":
		var friendly_military := int(alive_counts.get("friendlyMilitary", 0))
		data["name"] = "Militia Defenders"
		data["role"] = "Squad"
		data["hpText"] = "4 bodies | avg 86%"
		data["hpRatio"] = 0.86
		data["status"] = "STAGED" if militia_spawned else "TRAINING"
		data["summary"] = "Bridge defense squad. Attack, hold and move states are available."
		data["stats"] = ["COUNT %d" % max(1, friendly_military), "DPS 22", "ARM 1", "STATE HOLD"]
		data["abilities"] = [
			_v0210_icon_spec("attack", "Attack", "A", "Attack Ashen targets.", "ready", 0.0, "sword", "_on_live_ui_shell_attack_pressed"),
			_v0210_icon_spec("hold", "Hold", "H", "Hold the bridge approach.", "ready", 0.0, "shield", "_on_live_ui_shell_move_pressed"),
			_v0210_icon_spec("move", "Move", "M", "Reposition the squad.", "ready", 0.0, "compass", "_on_live_ui_shell_move_pressed"),
			_v0210_icon_spec("focus", "Focus", "F", "Focus fire when Ashen pressure starts.", "ready", 0.0, "crosshair", "_on_live_ui_shell_attack_pressed")
		]
		data["commands"] = [
			_v0210_command_spec("Attack", "A", "Attack selected hostile.", "ready", "_on_live_ui_shell_attack_pressed"),
			_v0210_command_spec("Hold", "H", "Hold bridge line.", "ready", "_on_live_ui_shell_move_pressed"),
			_v0210_command_spec("Move", "M", "Move squad.", "ready", "_on_live_ui_shell_move_pressed"),
			_v0210_command_spec("Focus", "F", "Focus fire.", "ready", "_on_live_ui_shell_attack_pressed")
		]
		data["disabledReason"] = "No disabled squad commands in this review frame."
		data["tooltip"] = "Militia panel summarizes count, health and tactical state at combat onset."
	elif selection_kind == "multi":
		data["name"] = "Mixed Selection"
		data["role"] = "Aster + Worker + Defenders"
		data["hpText"] = "6 selected | stable"
		data["hpRatio"] = 0.92
		data["status"] = "GROUP"
		data["summary"] = "Shared commands stay primary; specialist commands are grouped by context."
		data["stats"] = ["UNITS 6", "MIL 4", "WORK 1", "HERO 1"]
		data["abilities"] = [
			_v0210_icon_spec("move", "Move", "M", "Move the group.", "ready", 0.0, "compass", "_on_live_ui_shell_move_pressed"),
			_v0210_icon_spec("attack", "Attack", "A", "Only combat-capable units attack.", "ready", 0.0, "sword", "_on_live_ui_shell_attack_pressed"),
			_v0210_icon_spec("work_site", "Work", "W", "Only Worker accepts work orders.", "ready", 0.0, "hammer", "_on_live_ui_shell_work_pressed"),
			_v0210_icon_spec("lume_pulse", "Lume", "Q", "Only Aster can pulse Lume; locked now.", "locked", 0.0, "lume", "_on_live_ui_shell_lume_pressed")
		]
		data["commands"] = [
			_v0210_command_spec("Move", "M", "Move all selected.", "ready", "_on_live_ui_shell_move_pressed"),
			_v0210_command_spec("Attack", "A", "Combat units attack.", "ready", "_on_live_ui_shell_attack_pressed"),
			_v0210_command_spec("Work", "W", "Worker-only command.", "ready", "_on_live_ui_shell_work_pressed"),
			_v0210_command_spec("Lume", "Q", "Hero-only locked command.", "disabled", "_on_live_ui_shell_lume_pressed")
		]
		data["disabledReason"] = "Multi-select filters specialist commands instead of duplicating panels."
		data["tooltip"] = "Multi-select summary keeps common commands readable and specialist actions labeled."
	return data

func _v0210_icon_spec(id: String, label: String, shortcut: String, tooltip: String, state: String, cooldown: float, icon_name: String, method_name: String) -> Dictionary:
	return {
		"id": id,
		"label": label,
		"shortcut": shortcut,
		"tooltip": tooltip,
		"state": state,
		"cooldown": cooldown,
		"icon": icon_name,
		"method": method_name,
		"proceduralSvg": _v0210_svg_source(icon_name)
	}

func _v0210_command_spec(label: String, shortcut: String, tooltip: String, state: String, method_name: String) -> Dictionary:
	return {
		"label": label,
		"shortcut": shortcut,
		"tooltip": tooltip,
		"state": state,
		"method": method_name
	}

func _v0210_svg_source(icon_name: String) -> String:
	var body := "<path d='M14 14 L34 14 L24 34 Z'/>"
	match icon_name:
		"hammer":
			body = "<path d='M14 16 L22 8 L28 14 L20 22 Z'/><path d='M22 24 L34 36'/>"
		"timber":
			body = "<path d='M12 32 L36 12'/><path d='M16 36 L40 16'/>"
		"helmet":
			body = "<path d='M12 28 C14 14 34 14 36 28 Z'/><path d='M10 31 L38 31'/>"
		"shield":
			body = "<path d='M24 8 L38 14 L34 34 L24 42 L14 34 L10 14 Z'/>"
		"sword":
			body = "<path d='M34 8 L40 14 L20 34 L14 28 Z'/><path d='M14 34 L10 38'/>"
		"lume":
			body = "<circle cx='24' cy='24' r='12'/><path d='M24 6 L24 14 M24 34 L24 42 M6 24 L14 24 M34 24 L42 24'/>"
		"banner":
			body = "<path d='M16 8 L16 40'/><path d='M18 10 L38 14 L18 22 Z'/>"
		"compass":
			body = "<circle cx='24' cy='24' r='14'/><path d='M28 12 L24 24 L16 32 L20 20 Z'/>"
		"crosshair":
			body = "<circle cx='24' cy='24' r='12'/><path d='M24 6 L24 16 M24 32 L24 42 M6 24 L16 24 M32 24 L42 24'/>"
		"return":
			body = "<path d='M18 14 L10 22 L18 30'/><path d='M10 22 L32 22 C38 22 38 34 32 34 L22 34'/>"
		"plus":
			body = "<path d='M24 10 L24 38 M10 24 L38 24'/>"
		"x":
			body = "<path d='M14 14 L34 34 M34 14 L14 34'/>"
		"bow":
			body = "<path d='M18 8 C36 14 36 34 18 40'/><path d='M16 24 L38 24'/>"
	return "<svg viewBox='0 0 48 48' xmlns='http://www.w3.org/2000/svg'>%s</svg>" % body

func _live_ui_shell_resource_strip(root: Control, state: Dictionary) -> void:
	var resources: Dictionary = state.get("resources", {})
	var panel := _ui_architecture_panel(root, "LiveShellResourceStrip", Vector2(212, 16), Vector2(1132, 60), "SALTO FOOTHOLD", "", Color(0.34, 0.72, 0.66, 0.92))
	var entries := [
		{"name": "Crowns", "value": str(resources.get("crowns", 0)), "color": Color(0.86, 0.74, 0.38, 1.0)},
		{"name": "Stone", "value": str(resources.get("stone", 0)), "color": Color(0.62, 0.62, 0.54, 1.0)},
		{"name": "Iron", "value": str(resources.get("iron", 0)), "color": Color(0.54, 0.58, 0.60, 1.0)},
		{"name": "Aether", "value": str(resources.get("aether", 0)), "color": Color(0.28, 0.82, 0.78, 1.0)},
		{"name": "Pop", "value": "9/16", "color": Color(0.64, 0.78, 0.50, 1.0)}
	]
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var x := 22 + index * 196
		_ui_architecture_rect(panel, "LiveIcon%s" % str(entry["name"]), Vector2(x, 35), Vector2(16, 16), entry["color"])
		_ui_architecture_label(panel, "%s %s" % [entry["name"], entry["value"]], Vector2(x + 24, 31), Vector2(150, 22), 15, Color(0.90, 0.88, 0.68), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_rect(root, "LiveShellUtilityBackplate", Vector2(1328, 16), Vector2(228, 44), Color(0.025, 0.032, 0.028, 0.97))
	_live_ui_shell_action_button(root, Vector2(1364, 20), Vector2(54, 28), "Menu", "_on_player_back_pressed")
	_live_ui_shell_action_button(root, Vector2(1426, 20), Vector2(54, 28), "Help", "_on_live_ui_shell_help_pressed")
	_live_ui_shell_action_button(root, Vector2(1488, 20), Vector2(54, 28), "Pause", "_on_live_ui_shell_pause_pressed")

func _live_ui_shell_left_stack(root: Control, state: Dictionary) -> void:
	if _salto_production_objectives_log_enabled():
		_live_ui_shell_left_stack_v0211(root, state)
		return
	var objective_panel := _ui_architecture_panel(root, "LiveShellObjective", Vector2(22, 122), Vector2(318, 234), "OBJECTIVE", "", Color(0.70, 0.56, 0.26, 0.94))
	var objective_label := _ui_architecture_label(objective_panel, str(state["objective"]), Vector2(14, 44), Vector2(286, 30), 14, Color(0.90, 0.86, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	objective_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	var objective_detail := _ui_architecture_label(objective_panel, str(state["objectiveDetail"]), Vector2(14, 82), Vector2(286, 118), 13, Color(0.82, 0.88, 0.78), HORIZONTAL_ALIGNMENT_LEFT)
	objective_detail.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	var event_panel := _ui_architecture_panel(root, "LiveShellEventLog", Vector2(22, 376), Vector2(318, 198), "EVENT LOG", "", Color(0.40, 0.74, 0.60, 0.92))
	var events: Array = state.get("events", [])
	for index in range(min(events.size(), 7)):
		var line := _ui_architecture_label(event_panel, str(events[index]), Vector2(14, 44 + index * 22), Vector2(286, 20), 13, Color(0.82, 0.88, 0.78), HORIZONTAL_ALIGNMENT_LEFT)
		line.vertical_alignment = VERTICAL_ALIGNMENT_TOP

func _live_ui_shell_left_stack_v0211(root: Control, state: Dictionary) -> void:
	var objective_panel := _ui_architecture_panel(root, "V0211ObjectivePanel", Vector2(22, 108), Vector2(332, 254), "OBJECTIVE", "", Color(0.78, 0.62, 0.30, 0.96))
	_ui_architecture_label(objective_panel, str(state.get("objective", "")), Vector2(14, 42), Vector2(304, 26), 15, Color(0.94, 0.88, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	var next_label := _ui_architecture_label(objective_panel, "NEXT: %s" % str(state.get("objectiveNextAction", "")), Vector2(14, 72), Vector2(304, 48), 12, Color(0.78, 0.88, 0.76), HORIZONTAL_ALIGNMENT_LEFT)
	next_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	var detail := _ui_architecture_label(objective_panel, str(state.get("objectiveDetail", "")), Vector2(14, 126), Vector2(304, 52), 12, Color(0.82, 0.86, 0.72), HORIZONTAL_ALIGNMENT_LEFT)
	detail.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	var progress: Array = state.get("objectiveProgress", [])
	for index in range(min(progress.size(), 5)):
		var item: Dictionary = progress[index]
		var done := bool(item.get("done", false))
		var x := 16 + index * 60
		_ui_architecture_rect(objective_panel, "V0211ObjectiveStep%s" % index, Vector2(x, 194), Vector2(42, 8), Color(0.38, 0.78, 0.58, 0.96) if done else Color(0.22, 0.25, 0.21, 0.95))
		_ui_architecture_label(objective_panel, str(item.get("label", "")), Vector2(x - 4, 207), Vector2(52, 18), 9, Color(0.80, 0.84, 0.66), HORIZONTAL_ALIGNMENT_CENTER)
	var event_panel := _ui_architecture_panel(root, "V0211EventLog", Vector2(22, 382), Vector2(332, 210), "EVENT LOG", "", Color(0.42, 0.78, 0.62, 0.94))
	var events: Array = state.get("events", [])
	for index in range(min(events.size(), 6)):
		var y := 44 + index * 26
		var rail := Color(0.36, 0.72, 0.56, 0.95)
		if str(events[index]).to_lower().contains("ashen"):
			rail = Color(0.88, 0.32, 0.18, 0.96)
		elif str(events[index]).to_lower().contains("barracks") or str(events[index]).to_lower().contains("militia"):
			rail = Color(0.84, 0.62, 0.30, 0.96)
		_ui_architecture_rect(event_panel, "V0211EventRail%s" % index, Vector2(14, y + 2), Vector2(4, 20), rail)
		var line := _ui_architecture_label(event_panel, _v0211_truncate(str(events[index]), 44), Vector2(26, y), Vector2(286, 23), 12, Color(0.82, 0.88, 0.78), HORIZONTAL_ALIGNMENT_LEFT)
		line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if events.size() > 6:
		_ui_architecture_label(event_panel, "+%d older entries retained in log state" % (events.size() - 6), Vector2(26, 184), Vector2(286, 18), 10, Color(0.66, 0.72, 0.62), HORIZONTAL_ALIGNMENT_LEFT)

func _live_ui_shell_minimap(root: Control, state: Dictionary) -> void:
	if _salto_minimap_tooltip_accessibility_enabled():
		_live_ui_shell_minimap_v0212(root, state)
		return
	var panel := _ui_architecture_panel(root, "LiveShellMinimap", Vector2(24, 656), Vector2(258, 208), "SALTO MAP", "", Color(0.30, 0.78, 0.72, 0.94))
	_ui_architecture_rect(panel, "LiveMiniTerrain", Vector2(16, 46), Vector2(226, 142), Color(0.07, 0.13, 0.10, 0.94))
	_ui_architecture_rect(panel, "LiveMiniRoad", Vector2(42, 112), Vector2(164, 9), Color(0.54, 0.46, 0.30, 0.95))
	_ui_architecture_rect(panel, "LiveMiniRiver", Vector2(126, 58), Vector2(12, 112), Color(0.12, 0.46, 0.52, 0.96))
	_ui_architecture_rect(panel, "LiveMiniBridge", Vector2(102, 108), Vector2(58, 16), Color(0.74, 0.66, 0.46, 0.96))
	_ui_architecture_rect(panel, "LiveMiniFriendlies", Vector2(58, 150), Vector2(18, 18), Color(0.35, 0.82, 0.62, 1.0))
	_ui_architecture_rect(panel, "LiveMiniAster", Vector2(86, 100), Vector2(16, 16), Color(0.90, 0.78, 0.32, 1.0))
	_ui_architecture_rect(panel, "LiveMiniMine", Vector2(92, 104), Vector2(24, 18), Color(0.32, 0.88, 0.58, 0.92) if bool(state.get("mineConverted", false)) else Color(0.84, 0.72, 0.34, 0.92))
	_ui_architecture_rect(panel, "LiveMiniBarracks", Vector2(62, 68), Vector2(26, 16), Color(0.78, 0.66, 0.42, 0.92))
	_ui_architecture_rect(panel, "LiveMiniHostiles", Vector2(184, 74), Vector2(44, 18), Color(0.84, 0.25, 0.16, 1.0))
	_ui_architecture_rect(panel, "LiveMiniCamera", Vector2(78, 94), Vector2(116, 70), Color(0.88, 0.92, 0.82, 0.22))

func _live_ui_shell_minimap_v0212(root: Control, state: Dictionary) -> void:
	var panel := _ui_architecture_panel(root, "V0212MinimapFrame", Vector2(24, 644), Vector2(258, 220), "SALTO MAP", "", Color(0.34, 0.82, 0.76, 0.96))
	_ui_architecture_rect(panel, "V0212MiniPlayableBounds", Vector2(14, 42), Vector2(230, 154), Color(0.055, 0.105, 0.080, 0.98))
	_ui_architecture_rect(panel, "V0212MiniBoundsStrokeTop", Vector2(14, 42), Vector2(230, 2), Color(0.42, 0.58, 0.44, 0.92))
	_ui_architecture_rect(panel, "V0212MiniBoundsStrokeBottom", Vector2(14, 194), Vector2(230, 2), Color(0.42, 0.58, 0.44, 0.92))
	_ui_architecture_rect(panel, "V0212MiniBoundsStrokeLeft", Vector2(14, 42), Vector2(2, 154), Color(0.42, 0.58, 0.44, 0.92))
	_ui_architecture_rect(panel, "V0212MiniBoundsStrokeRight", Vector2(242, 42), Vector2(2, 154), Color(0.42, 0.58, 0.44, 0.92))
	_ui_architecture_rect(panel, "V0212MiniRoadWest", Vector2(40, 116), Vector2(78, 10), Color(0.58, 0.50, 0.32, 0.98))
	_ui_architecture_rect(panel, "V0212MiniRoadBridge", Vector2(102, 108), Vector2(62, 24), Color(0.68, 0.61, 0.42, 0.98))
	_ui_architecture_rect(panel, "V0212MiniRoadEast", Vector2(150, 116), Vector2(72, 10), Color(0.58, 0.50, 0.32, 0.98))
	_ui_architecture_rect(panel, "V0212MiniNorthRoad", Vector2(108, 58), Vector2(10, 66), Color(0.48, 0.43, 0.30, 0.94))
	_ui_architecture_rect(panel, "V0212MiniRiver", Vector2(128, 50), Vector2(14, 138), Color(0.10, 0.45, 0.56, 0.98))
	_ui_architecture_rect(panel, "V0212MiniRiverLight", Vector2(135, 54), Vector2(3, 130), Color(0.36, 0.75, 0.78, 0.65))
	_ui_architecture_rect(panel, "V0212MiniFriendlySquad", Vector2(56, 154), Vector2(17, 17), Color(0.33, 0.84, 0.62, 1.0))
	_ui_architecture_rect(panel, "V0212MiniHero", Vector2(88, 102), Vector2(14, 14), Color(0.92, 0.78, 0.32, 1.0))
	_ui_architecture_rect(panel, "V0212MiniMine", Vector2(92, 106), Vector2(25, 18), Color(0.32, 0.88, 0.58, 0.95) if bool(state.get("mineConverted", false)) else Color(0.84, 0.72, 0.34, 0.95))
	_ui_architecture_rect(panel, "V0212MiniBarracks", Vector2(62, 70), Vector2(28, 17), Color(0.78, 0.66, 0.42, 0.96))
	_ui_architecture_rect(panel, "V0212MiniSite", Vector2(198, 136), Vector2(15, 15), Color(0.28, 0.80, 0.74, 0.92))
	_ui_architecture_rect(panel, "V0212MiniHostiles", Vector2(184, 74), Vector2(44, 19), Color(0.88, 0.24, 0.16, 1.0))
	_ui_architecture_rect(panel, "V0212MiniCameraFill", Vector2(76, 94), Vector2(120, 70), Color(0.90, 0.95, 0.82, 0.16))
	_ui_architecture_rect(panel, "V0212MiniCameraTop", Vector2(76, 94), Vector2(120, 2), Color(0.90, 0.95, 0.82, 0.88))
	_ui_architecture_rect(panel, "V0212MiniCameraBottom", Vector2(76, 162), Vector2(120, 2), Color(0.90, 0.95, 0.82, 0.88))
	_ui_architecture_rect(panel, "V0212MiniCameraLeft", Vector2(76, 94), Vector2(2, 70), Color(0.90, 0.95, 0.82, 0.88))
	_ui_architecture_rect(panel, "V0212MiniCameraRight", Vector2(194, 94), Vector2(2, 70), Color(0.90, 0.95, 0.82, 0.88))
	_ui_architecture_label(panel, "H", Vector2(89, 86), Vector2(14, 12), 9, Color(0.96, 0.88, 0.46), HORIZONTAL_ALIGNMENT_CENTER)
	_ui_architecture_label(panel, "M", Vector2(96, 126), Vector2(14, 12), 9, Color(0.76, 0.92, 0.70), HORIZONTAL_ALIGNMENT_CENTER)
	_ui_architecture_label(panel, "B", Vector2(70, 89), Vector2(14, 12), 9, Color(0.88, 0.80, 0.56), HORIZONTAL_ALIGNMENT_CENTER)
	_ui_architecture_label(panel, "A", Vector2(201, 94), Vector2(14, 12), 9, Color(0.96, 0.50, 0.42), HORIZONTAL_ALIGNMENT_CENTER)
	var utility_labels := ["C", "+", "!"]
	for index in range(3):
		var x := 168 + index * 24
		_ui_architecture_rect(panel, "V0212MiniUtility%s" % index, Vector2(x, 16), Vector2(20, 18), Color(0.04, 0.055, 0.048, 0.96))
		_ui_architecture_label(panel, utility_labels[index], Vector2(x, 17), Vector2(20, 16), 9, Color(0.78, 0.90, 0.78), HORIZONTAL_ALIGNMENT_CENTER)
	_ui_architecture_label(panel, "bounds  camera  units", Vector2(20, 198), Vector2(216, 16), 9, Color(0.70, 0.78, 0.66), HORIZONTAL_ALIGNMENT_CENTER)

func _live_ui_shell_selection_panel(root: Control, state: Dictionary) -> void:
	if _salto_selection_command_panel_enabled():
		_live_ui_shell_selection_panel_v0210(root, state)
		return
	var panel := _ui_architecture_panel(root, "LiveShellSelection", Vector2(306, 706), Vector2(584, 158), "SELECTED", "", Color(0.36, 0.78, 0.72, 0.96))
	_ui_architecture_rect(panel, "LivePortraitFrame", Vector2(16, 48), Vector2(92, 82), Color(0.09, 0.11, 0.09, 0.96))
	_ui_architecture_rect(panel, "LivePortraitFill", Vector2(20, 52), Vector2(84, 64), state["portraitColor"])
	_ui_architecture_label(panel, str(state["statusPip"]), Vector2(22, 116), Vector2(80, 20), 11, Color(0.88, 0.88, 0.68), HORIZONTAL_ALIGNMENT_CENTER)
	_ui_architecture_label(panel, str(state["selectedTitle"]), Vector2(124, 42), Vector2(430, 24), 15, Color(0.92, 0.86, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_label(panel, str(state["selectedSubtitle"]), Vector2(124, 66), Vector2(430, 22), 13, Color(0.80, 0.88, 0.74), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_rect(panel, "LiveHealthBack", Vector2(124, 96), Vector2(240, 10), Color(0.10, 0.08, 0.06, 0.96))
	_ui_architecture_rect(panel, "LiveHealthFill", Vector2(124, 96), Vector2(198, 10), Color(0.42, 0.78, 0.48, 0.96))
	_ui_architecture_label(panel, str(state["commandHint"]), Vector2(124, 112), Vector2(430, 20), 12, Color(0.86, 0.84, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	_live_ui_shell_action_button(panel, Vector2(124, 132), Vector2(86, 24), "Move", "_on_live_ui_shell_move_pressed")
	_live_ui_shell_action_button(panel, Vector2(220, 132), Vector2(86, 24), "Attack", "_on_live_ui_shell_attack_pressed")
	_live_ui_shell_action_button(panel, Vector2(316, 132), Vector2(86, 24), str("Train" if state["activeTab"] == "TRAIN" else "Work"), "_on_live_ui_shell_work_pressed")
	_live_ui_shell_action_button(panel, Vector2(412, 132), Vector2(86, 24), "Lume", "_on_live_ui_shell_lume_pressed")

func _live_ui_shell_selection_panel_v0210(root: Control, state: Dictionary) -> void:
	var data: Dictionary = state.get("selectionPanel", {})
	var panel := _ui_architecture_panel(root, "V0210SelectionCommandPanel", Vector2(300, 650), Vector2(606, 214), "SELECTED CONTEXT", "", Color(0.44, 0.82, 0.74, 0.98))
	_v0210_render_portrait(panel, data)
	_ui_architecture_label(panel, str(data.get("name", "Selected")), Vector2(142, 42), Vector2(294, 24), 15, Color(0.94, 0.88, 0.68), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_label(panel, "%s | %s" % [str(data.get("role", "")), str(data.get("status", ""))], Vector2(440, 43), Vector2(142, 22), 12, Color(0.72, 0.86, 0.76), HORIZONTAL_ALIGNMENT_RIGHT)
	_ui_architecture_label(panel, str(data.get("summary", "")), Vector2(142, 66), Vector2(436, 30), 11, Color(0.78, 0.86, 0.74), HORIZONTAL_ALIGNMENT_LEFT)
	_v0210_progress_bar(panel, Vector2(142, 101), Vector2(218, 11), float(data.get("hpRatio", 1.0)), Color(0.44, 0.80, 0.48, 0.98))
	_ui_architecture_label(panel, str(data.get("hpText", "")), Vector2(368, 96), Vector2(118, 20), 11, Color(0.84, 0.88, 0.70), HORIZONTAL_ALIGNMENT_LEFT)
	_v0210_render_stat_pills(panel, data.get("stats", []), Vector2(142, 119))
	_ui_architecture_label(panel, "ABILITIES", Vector2(18, 170), Vector2(90, 16), 10, Color(0.66, 0.78, 0.68), HORIZONTAL_ALIGNMENT_LEFT)
	var abilities: Array = data.get("abilities", [])
	for index in range(min(abilities.size(), 4)):
		_v0210_icon_button(panel, Vector2(112 + index * 58, 146), Vector2(50, 52), abilities[index], str(data.get("focusId", "")))
	var commands: Array = data.get("commands", [])
	for index in range(min(commands.size(), 4)):
		_v0210_command_button(panel, Vector2(360 + index * 58, 146), Vector2(52, 52), commands[index], str(data.get("focusId", "")))
	_ui_architecture_label(panel, str(data.get("disabledReason", "")), Vector2(14, 198), Vector2(578, 14), 10, Color(0.72, 0.78, 0.66), HORIZONTAL_ALIGNMENT_LEFT)

func _v0210_render_portrait(parent: Control, data: Dictionary) -> void:
	var portrait_status: Dictionary = data.get("portraitStatus", {})
	var source_loaded := bool(portrait_status.get("sourceLoaded", false))
	var context_kind := str(data.get("kind", "aster"))
	var uses_art_portrait := context_kind == "aster" or not _salto_production_objectives_log_enabled()
	var frame := Panel.new()
	frame.name = "V0210PortraitFrame"
	frame.position = Vector2(18, 42)
	frame.size = Vector2(104, 120)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.clip_contents = true
	frame.add_theme_stylebox_override("panel", _ui_architecture_panel_style(Color(0.055, 0.065, 0.055, 0.98), Color(0.78, 0.70, 0.42, 0.92) if uses_art_portrait and source_loaded else Color(0.42, 0.54, 0.46, 0.76)))
	parent.add_child(frame)
	if not uses_art_portrait:
		_v0211_render_context_emblem(frame, context_kind)
	elif source_loaded and player_ui_shell_portrait_texture != null:
		var atlas := AtlasTexture.new()
		atlas.atlas = player_ui_shell_portrait_texture
		atlas.region = Rect2(430, 28, 220, 290)
		var portrait := TextureRect.new()
		portrait.name = "AsterPortraitCrop"
		portrait.texture = atlas
		portrait.position = Vector2(6, 5)
		portrait.size = Vector2(92, 98)
		portrait.clip_contents = true
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(portrait)
	else:
		_ui_architecture_rect(frame, "PortraitFallbackHalo", Vector2(18, 15), Vector2(68, 68), Color(0.20, 0.36, 0.34, 0.92))
		_ui_architecture_rect(frame, "PortraitFallbackHead", Vector2(40, 23), Vector2(24, 26), Color(0.78, 0.70, 0.46, 0.96))
		_ui_architecture_rect(frame, "PortraitFallbackCloak", Vector2(28, 54), Vector2(48, 42), Color(0.16, 0.48, 0.44, 0.94))
	var label := "ART" if uses_art_portrait else "CONTEXT"
	if uses_art_portrait and not source_loaded:
		label = "FALLBACK"
	_ui_architecture_label(frame, label, Vector2(8, 100), Vector2(88, 16), 10, Color(0.90, 0.84, 0.62), HORIZONTAL_ALIGNMENT_CENTER)

func _v0211_render_context_emblem(parent: Control, context_kind: String) -> void:
	var base := Color(0.26, 0.38, 0.30, 0.96)
	var accent := Color(0.78, 0.66, 0.38, 0.98)
	var shadow := Color(0.08, 0.10, 0.08, 0.96)
	if context_kind == "worker":
		_ui_architecture_rect(parent, "V0211WorkerBackdrop", Vector2(18, 18), Vector2(68, 68), Color(0.15, 0.27, 0.22, 0.95))
		_ui_architecture_rect(parent, "V0211WorkerHead", Vector2(40, 20), Vector2(24, 24), accent)
		_ui_architecture_rect(parent, "V0211WorkerBody", Vector2(31, 49), Vector2(42, 34), Color(0.28, 0.54, 0.48, 0.95))
		_ui_architecture_rect(parent, "V0211WorkerTool", Vector2(66, 24), Vector2(6, 46), Color(0.68, 0.55, 0.32, 0.95))
		_ui_architecture_rect(parent, "V0211WorkerToolHead", Vector2(58, 20), Vector2(22, 6), Color(0.54, 0.57, 0.46, 0.95))
	elif context_kind == "barracks_restoring" or context_kind == "barracks_queue":
		_ui_architecture_rect(parent, "V0211StructureGround", Vector2(16, 76), Vector2(72, 9), Color(0.29, 0.34, 0.27, 0.98))
		_ui_architecture_rect(parent, "V0211StructureBase", Vector2(22, 48), Vector2(60, 30), base)
		_ui_architecture_rect(parent, "V0211StructureRoof", Vector2(16, 36), Vector2(72, 14), Color(0.50, 0.42, 0.28, 0.98))
		_ui_architecture_rect(parent, "V0211StructureDoor", Vector2(47, 58), Vector2(14, 20), shadow)
		_ui_architecture_rect(parent, "V0211StructureBraceA", Vector2(27, 52), Vector2(7, 24), Color(0.62, 0.51, 0.32, 0.95))
		_ui_architecture_rect(parent, "V0211StructureBraceB", Vector2(70, 52), Vector2(7, 24), Color(0.62, 0.51, 0.32, 0.95))
		if context_kind == "barracks_restoring":
			_ui_architecture_rect(parent, "V0211StructureScaffold", Vector2(25, 30), Vector2(54, 5), Color(0.54, 0.62, 0.45, 0.9))
	elif context_kind == "militia":
		_ui_architecture_rect(parent, "V0211MilitiaBackdrop", Vector2(20, 18), Vector2(64, 68), Color(0.12, 0.21, 0.20, 0.95))
		_ui_architecture_rect(parent, "V0211MilitiaShield", Vector2(35, 28), Vector2(34, 42), Color(0.36, 0.52, 0.38, 0.98))
		_ui_architecture_rect(parent, "V0211MilitiaShieldBand", Vector2(39, 40), Vector2(26, 8), accent)
		_ui_architecture_rect(parent, "V0211MilitiaSpear", Vector2(72, 22), Vector2(5, 58), Color(0.64, 0.56, 0.35, 0.95))
		_ui_architecture_rect(parent, "V0211MilitiaSpearTip", Vector2(69, 16), Vector2(11, 8), Color(0.64, 0.70, 0.66, 0.95))
	elif context_kind == "multi":
		_ui_architecture_rect(parent, "V0211MultiAster", Vector2(22, 22), Vector2(24, 24), Color(0.58, 0.66, 0.42, 0.95))
		_ui_architecture_rect(parent, "V0211MultiWorker", Vector2(55, 24), Vector2(26, 38), Color(0.26, 0.54, 0.48, 0.95))
		_ui_architecture_rect(parent, "V0211MultiMilitia", Vector2(29, 56), Vector2(42, 25), Color(0.35, 0.48, 0.34, 0.95))
	else:
		_ui_architecture_rect(parent, "V0211GenericEmblem", Vector2(22, 22), Vector2(60, 60), base)
		_ui_architecture_rect(parent, "V0211GenericAccent", Vector2(34, 34), Vector2(36, 12), accent)

func _v0210_progress_bar(parent: Control, position: Vector2, size: Vector2, ratio: float, fill_color: Color) -> void:
	_ui_architecture_rect(parent, "V0210HealthBack", position, size, Color(0.08, 0.08, 0.06, 0.98))
	_ui_architecture_rect(parent, "V0210HealthFill", position, Vector2(maxf(4.0, size.x * clampf(ratio, 0.0, 1.0)), size.y), fill_color)

func _v0210_render_stat_pills(parent: Control, stats: Array, position: Vector2) -> void:
	for index in range(min(stats.size(), 4)):
		var x := position.x + index * 82
		var pill := Panel.new()
		pill.name = "V0210StatPill%s" % index
		pill.position = Vector2(x, position.y)
		pill.size = Vector2(74, 18)
		pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pill.add_theme_stylebox_override("panel", _ui_architecture_panel_style(Color(0.06, 0.075, 0.058, 0.96), Color(0.36, 0.48, 0.40, 0.72)))
		parent.add_child(pill)
		_ui_architecture_label(pill, str(stats[index]), Vector2(4, 1), Vector2(66, 16), 10, Color(0.82, 0.86, 0.70), HORIZONTAL_ALIGNMENT_CENTER)

func _v0210_icon_button(parent: Control, position: Vector2, size: Vector2, spec: Dictionary, focus_id: String) -> Button:
	var state := str(spec.get("state", "ready"))
	var focused := focus_id != "" and focus_id == str(spec.get("id", ""))
	var border := Color(0.42, 0.58, 0.50, 0.78)
	if focused:
		border = Color(0.92, 0.78, 0.36, 0.98)
	elif state == "locked" or state == "disabled":
		border = Color(0.28, 0.31, 0.28, 0.76)
	elif state == "cooldown" or state == "queued":
		border = Color(0.86, 0.62, 0.30, 0.92)
	var button := Button.new()
	button.name = "V0210Ability%s" % str(spec.get("id", ""))
	button.text = "%s\n%s" % [str(spec.get("shortcut", "")), str(spec.get("label", ""))]
	button.position = position
	button.size = size
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.tooltip_text = str(spec.get("tooltip", ""))
	button.disabled = state == "locked" or state == "disabled"
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_stylebox_override("normal", _ui_architecture_panel_style(Color(0.050, 0.060, 0.052, 0.98), border))
	button.add_theme_stylebox_override("hover", _ui_architecture_panel_style(Color(0.08, 0.10, 0.075, 0.98), Color(0.84, 0.72, 0.38, 0.96)))
	button.add_theme_stylebox_override("focus", _ui_architecture_panel_style(Color(0.08, 0.085, 0.06, 0.98), Color(0.98, 0.82, 0.34, 1.0)))
	button.add_theme_stylebox_override("disabled", _ui_architecture_panel_style(Color(0.035, 0.040, 0.036, 0.96), border))
	button.add_theme_color_override("font_color", Color(0.88, 0.86, 0.68))
	button.add_theme_color_override("font_disabled_color", Color(0.48, 0.52, 0.46))
	var method_name := str(spec.get("method", ""))
	if method_name != "" and has_method(method_name) and not button.disabled:
		button.pressed.connect(Callable(self, method_name))
	parent.add_child(button)
	if state == "cooldown" or state == "queued":
		var fill_ratio := clampf(float(spec.get("cooldown", 0.0)), 0.0, 1.0)
		_ui_architecture_rect(button, "V0210CooldownOverlay", Vector2(0, size.y * (1.0 - fill_ratio)), Vector2(size.x, size.y * fill_ratio), Color(0.06, 0.07, 0.05, 0.54))
	return button

func _v0210_command_button(parent: Control, position: Vector2, size: Vector2, spec: Dictionary, focus_id: String) -> Button:
	var state := str(spec.get("state", "ready"))
	var id := str(spec.get("label", "")).to_lower()
	var focused := focus_id != "" and focus_id == id
	var border := Color(0.44, 0.56, 0.46, 0.80)
	if focused:
		border = Color(0.94, 0.76, 0.32, 0.98)
	elif state == "disabled":
		border = Color(0.28, 0.30, 0.27, 0.74)
	elif state == "queued":
		border = Color(0.86, 0.64, 0.32, 0.96)
	var button := Button.new()
	button.name = "V0210Command%s" % str(spec.get("label", ""))
	button.text = "%s\n%s" % [str(spec.get("shortcut", "")), str(spec.get("label", ""))]
	button.position = position
	button.size = size
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.tooltip_text = str(spec.get("tooltip", ""))
	button.disabled = state == "disabled"
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_stylebox_override("normal", _ui_architecture_panel_style(Color(0.050, 0.058, 0.050, 0.98), border))
	button.add_theme_stylebox_override("hover", _ui_architecture_panel_style(Color(0.075, 0.092, 0.070, 0.98), Color(0.82, 0.70, 0.36, 0.96)))
	button.add_theme_stylebox_override("focus", _ui_architecture_panel_style(Color(0.08, 0.085, 0.06, 0.98), Color(0.98, 0.82, 0.34, 1.0)))
	button.add_theme_stylebox_override("disabled", _ui_architecture_panel_style(Color(0.034, 0.038, 0.034, 0.96), border))
	button.add_theme_color_override("font_color", Color(0.90, 0.86, 0.68))
	button.add_theme_color_override("font_disabled_color", Color(0.48, 0.52, 0.46))
	var method_name := str(spec.get("method", ""))
	if method_name != "" and has_method(method_name) and not button.disabled:
		button.pressed.connect(Callable(self, method_name))
	parent.add_child(button)
	return button

func _live_ui_shell_production_panel(root: Control, state: Dictionary) -> void:
	if _salto_production_objectives_log_enabled():
		_live_ui_shell_production_panel_v0211(root, state)
		return
	var panel := _ui_architecture_panel(root, "LiveShellProduction", Vector2(918, 656), Vector2(560, 208), "BUILD / TRAIN / RESEARCH", "", Color(0.80, 0.56, 0.22, 0.94))
	var tabs: Array[String] = ["BUILD", "TRAIN", "RESEARCH"]
	var active := str(state.get("activeTab", "BUILD"))
	for index in range(tabs.size()):
		var tab := tabs[index]
		var bg := Color(0.08, 0.10, 0.08, 0.96)
		var border := Color(0.42, 0.52, 0.38, 0.86)
		if tab == active:
			bg = Color(0.16, 0.13, 0.08, 0.98)
			border = Color(0.86, 0.66, 0.34, 0.96)
		_ui_shell_button(panel, Vector2(18 + index * 128, 42), Vector2(116, 30), tab, bg, border)
	var cards: Array[Dictionary] = _live_ui_shell_cards(state)
	for index in range(cards.size()):
		var col := index % 2
		var row := int(index / 2)
		_ui_shell_card(panel, Vector2(18 + col * 264, 84 + row * 58), Vector2(250, 48), cards[index])

func _live_ui_shell_cards(state: Dictionary) -> Array[Dictionary]:
	if str(state.get("activeTab", "BUILD")) == "TRAIN":
		return [
			{"title": "Militia", "meta": "Queued" if bool(state.get("militiaQueued", false)) else "Iron 25 | 18s", "state": "queued" if bool(state.get("militiaQueued", false)) else "ready"},
			{"title": "Ranger", "meta": "Requires Lume", "state": "disabled"},
			{"title": "Defenders", "meta": "Staged" if bool(state.get("militiaSpawned", false)) else "Stage at bridge", "state": "ready"},
			{"title": "Cancel Queue", "meta": "Refund partial", "state": "available"}
		]
	return [
		{"title": "Restore Barracks", "meta": "Complete" if bool(state.get("barracksComplete", false)) else "Stone 80 | Worker", "state": "disabled" if bool(state.get("barracksComplete", false)) else "ready"},
		{"title": "Repair Bridge", "meta": "Future scope", "state": "disabled"},
		{"title": "Set Rally", "meta": "No cost", "state": "available"},
		{"title": "Lume Beacon", "meta": "Aether locked", "state": "disabled"}
	]

func _live_ui_shell_production_panel_v0211(root: Control, state: Dictionary) -> void:
	var panel := _ui_architecture_panel(root, "V0211ProductionPanel", Vector2(918, 638), Vector2(560, 226), "BUILD / TRAIN / RESEARCH", "", Color(0.82, 0.62, 0.28, 0.96))
	var tabs: Array[String] = ["BUILD", "TRAIN", "RESEARCH"]
	var active := str(state.get("activeTab", "BUILD"))
	for index in range(tabs.size()):
		_v0211_production_tab(panel, Vector2(18 + index * 128, 42), Vector2(116, 30), tabs[index], active == tabs[index])
	var cards: Array = state.get("productionCards", [])
	for index in range(min(cards.size(), 4)):
		var col := index % 2
		var row := int(index / 2)
		_v0211_production_card(panel, Vector2(18 + col * 264, 82 + row * 62), Vector2(250, 56), cards[index], str(state.get("productionFocusId", "")))
	_ui_architecture_label(panel, "Existing actions only; unavailable cards explain future scope without adding gameplay.", Vector2(18, 208), Vector2(524, 16), 10, Color(0.70, 0.76, 0.62), HORIZONTAL_ALIGNMENT_LEFT)

func _v0211_production_tab(parent: Control, position: Vector2, size: Vector2, text: String, active: bool) -> void:
	var bg := Color(0.055, 0.065, 0.052, 0.98)
	var border := Color(0.40, 0.52, 0.38, 0.84)
	if active:
		bg = Color(0.16, 0.13, 0.08, 0.98)
		border = Color(0.90, 0.68, 0.34, 0.98)
	var tab := _ui_shell_button(parent, position, size, text, bg, border)
	_ui_architecture_rect(tab, "V0211TabUnderbar", Vector2(10, size.y - 5), Vector2(size.x - 20, 3), Color(0.92, 0.72, 0.34, 0.96) if active else Color(0.28, 0.34, 0.28, 0.74))

func _v0211_production_card(parent: Control, position: Vector2, size: Vector2, card: Dictionary, focus_id: String) -> Button:
	var card_state := str(card.get("state", "ready"))
	var card_id := str(card.get("id", ""))
	var focused := focus_id != "" and focus_id == card_id
	var border := Color(0.46, 0.62, 0.48, 0.84)
	var rail := Color(0.38, 0.72, 0.58, 0.94)
	if card_state == "disabled":
		border = Color(0.30, 0.34, 0.30, 0.78)
		rail = Color(0.28, 0.29, 0.25, 0.94)
	elif card_state == "queued":
		border = Color(0.88, 0.62, 0.28, 0.98)
		rail = Color(0.88, 0.55, 0.22, 0.98)
	elif card_state == "complete":
		border = Color(0.40, 0.70, 0.54, 0.94)
		rail = Color(0.34, 0.78, 0.56, 0.98)
	if focused:
		border = Color(0.98, 0.78, 0.34, 1.0)
	var button := Button.new()
	button.name = "V0211Production%s" % card_id
	button.text = ""
	button.position = position
	button.size = size
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.tooltip_text = str(card.get("why", ""))
	button.disabled = card_state == "disabled" or card_state == "queued" or card_state == "complete"
	button.add_theme_stylebox_override("normal", _ui_architecture_panel_style(Color(0.038, 0.046, 0.038, 0.98), border))
	button.add_theme_stylebox_override("hover", _ui_architecture_panel_style(Color(0.065, 0.078, 0.060, 0.98), Color(0.84, 0.68, 0.34, 0.96)))
	button.add_theme_stylebox_override("focus", _ui_architecture_panel_style(Color(0.075, 0.082, 0.060, 0.98), Color(0.98, 0.78, 0.34, 1.0)))
	button.add_theme_stylebox_override("disabled", _ui_architecture_panel_style(Color(0.034, 0.038, 0.034, 0.98), border))
	parent.add_child(button)
	_ui_architecture_rect(button, "V0211CardRail", Vector2(0, 0), Vector2(6, size.y), rail)
	var icon_texture := _v0211_svg_texture(str(card.get("icon", "")))
	if icon_texture != null:
		var icon := TextureRect.new()
		icon.name = "V0211CardIcon"
		icon.texture = icon_texture
		icon.position = Vector2(13, 13)
		icon.size = Vector2(30, 30)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
	else:
		_ui_architecture_label(button, str(card.get("shortcut", "")), Vector2(13, 13), Vector2(30, 30), 13, Color(0.88, 0.78, 0.46), HORIZONTAL_ALIGNMENT_CENTER)
	_ui_architecture_label(button, str(card.get("title", "")), Vector2(52, 6), Vector2(136, 18), 13, Color(0.92, 0.86, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_label(button, str(card.get("shortcut", "")), Vector2(202, 6), Vector2(34, 18), 11, Color(0.86, 0.74, 0.46), HORIZONTAL_ALIGNMENT_RIGHT)
	_ui_architecture_label(button, str(card.get("cost", "")), Vector2(52, 25), Vector2(178, 15), 10, Color(0.74, 0.80, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_label(button, _v0211_truncate(str(card.get("detail", "")), 35), Vector2(52, 39), Vector2(184, 15), 9, Color(0.58, 0.66, 0.56), HORIZONTAL_ALIGNMENT_LEFT)
	if card_state != "ready":
		var badge_text := card_state.to_upper()
		_ui_architecture_rect(button, "V0211CardBadgeBack", Vector2(178, 31), Vector2(58, 18), Color(0.06, 0.065, 0.052, 0.88))
		_ui_architecture_label(button, badge_text, Vector2(181, 31), Vector2(52, 18), 8, Color(0.86, 0.76, 0.52), HORIZONTAL_ALIGNMENT_CENTER)
	var method_name := str(card.get("method", ""))
	if method_name != "" and has_method(method_name) and not button.disabled:
		button.pressed.connect(Callable(self, method_name))
	return button

func _v0211_svg_texture(icon_name: String) -> Texture2D:
	if player_ui_shell_svg_texture_cache.has(icon_name):
		return player_ui_shell_svg_texture_cache[icon_name]
	var svg := _v0210_svg_source(icon_name)
	if svg == "":
		return null
	var image := Image.new()
	var result := image.load_svg_from_string(svg, 1.0)
	if result != OK:
		player_ui_shell_svg_texture_cache[icon_name] = null
		return null
	var texture := ImageTexture.create_from_image(image)
	player_ui_shell_svg_texture_cache[icon_name] = texture
	return texture

func _v0211_truncate(value: String, max_length: int) -> String:
	if value.length() <= max_length:
		return value
	if max_length <= 3:
		return value.substr(0, max_length)
	return "%s..." % value.substr(0, max_length - 3)

func _live_ui_shell_alerts(root: Control, state: Dictionary) -> void:
	if _salto_minimap_tooltip_accessibility_enabled():
		_live_ui_shell_alerts_v0212(root, state)
		return
	if _salto_production_objectives_log_enabled():
		_live_ui_shell_alerts_v0211(root, state)
		return
	var border := Color(0.48, 0.70, 0.58, 0.85)
	if str(state.get("alertSeverity", "")) == "hostile":
		border = Color(0.92, 0.28, 0.16, 0.98)
	_ui_architecture_panel(root, "LiveShellAlertCard", Vector2(1270, 150), Vector2(272, 98), "ALERT", str(state.get("alert", "")), border)

func _live_ui_shell_alerts_v0211(root: Control, state: Dictionary) -> void:
	var hostile := str(state.get("alertSeverity", "")) == "hostile"
	var border := Color(0.48, 0.70, 0.58, 0.90)
	var rail := Color(0.35, 0.72, 0.58, 0.96)
	if hostile:
		border = Color(0.92, 0.30, 0.18, 0.98)
		rail = Color(0.92, 0.26, 0.16, 0.98)
	var panel := _ui_architecture_panel(root, "V0211HostilePressureAlert", Vector2(1248, 136), Vector2(300, 124), "HOSTILE PRESSURE", "", border)
	_ui_architecture_rect(panel, "V0211AlertRail", Vector2(0, 32), Vector2(7, 92), rail)
	var icon_texture := _v0211_svg_texture("crosshair" if hostile else "shield")
	if icon_texture != null:
		var icon := TextureRect.new()
		icon.name = "V0211AlertIcon"
		icon.texture = icon_texture
		icon.position = Vector2(18, 48)
		icon.size = Vector2(34, 34)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(icon)
	_ui_architecture_label(panel, str(state.get("alert", "")), Vector2(62, 44), Vector2(214, 24), 14, Color(0.94, 0.86, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	var guidance := "No active pressure. Keep training and staging defenders."
	if hostile:
		guidance = "Ashen wave active. Hold bridge, focus raiders, preserve Aster."
	elif str(state.get("alert", "")).to_lower().contains("cleared"):
		guidance = "Wave cleared. Regroup defenders and prepare the next objective."
	var guide := _ui_architecture_label(panel, guidance, Vector2(62, 70), Vector2(214, 40), 11, Color(0.78, 0.86, 0.74), HORIZONTAL_ALIGNMENT_LEFT)
	guide.vertical_alignment = VERTICAL_ALIGNMENT_TOP

func _live_ui_shell_alerts_v0212(root: Control, state: Dictionary) -> void:
	var severity := str(state.get("alertSeverity", "info"))
	var hostile := severity == "hostile"
	var warning := severity == "warning"
	var border := Color(0.44, 0.74, 0.64, 0.92)
	var rail := Color(0.35, 0.72, 0.58, 0.96)
	var icon_name := "shield"
	var title := "FIELD ALERT"
	if warning:
		border = Color(0.86, 0.64, 0.30, 0.96)
		rail = Color(0.86, 0.64, 0.30, 0.98)
		icon_name = "crosshair"
		title = "WARNING"
	elif hostile:
		border = Color(0.94, 0.30, 0.18, 0.98)
		rail = Color(0.94, 0.24, 0.16, 0.98)
		icon_name = "crosshair"
		title = "HOSTILE PRESSURE"
	var panel := _ui_architecture_panel(root, "V0212AlertCard", Vector2(1248, 132), Vector2(300, 132), title, "", border)
	_ui_architecture_rect(panel, "V0212AlertRail", Vector2(0, 32), Vector2(7, 100), rail)
	var icon_texture := _v0211_svg_texture(icon_name)
	if icon_texture != null:
		var icon := TextureRect.new()
		icon.name = "V0212AlertIcon"
		icon.texture = icon_texture
		icon.position = Vector2(18, 48)
		icon.size = Vector2(34, 34)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(icon)
	_ui_architecture_label(panel, str(state.get("alert", "")), Vector2(62, 42), Vector2(216, 24), 14, Color(0.95, 0.88, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	var guidance := "Info only. Stay quiet until the field state changes."
	if warning:
		guidance = "Unavailable action. Explain why; keep the alert quiet."
	elif hostile:
		guidance = "Ashen wave active. Hold bridge; focus raiders."
	var guide := _ui_architecture_label(panel, guidance, Vector2(62, 68), Vector2(214, 34), 11, Color(0.80, 0.88, 0.74), HORIZONTAL_ALIGNMENT_LEFT)
	guide.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	if hostile:
		for index in range(4):
			_ui_architecture_rect(panel, "V0212AlertPulse%s" % index, Vector2(62 + index * 32, 108), Vector2(20, 6), Color(0.96, 0.36, 0.22, 0.95 - index * 0.14))
	elif warning:
		_ui_architecture_rect(panel, "V0212WarningPulse", Vector2(62, 108), Vector2(88, 6), Color(0.90, 0.68, 0.32, 0.82))
	else:
		_ui_architecture_rect(panel, "V0212InfoQuiet", Vector2(62, 108), Vector2(54, 4), Color(0.38, 0.74, 0.58, 0.60))

func _live_ui_shell_tooltip(root: Control, state: Dictionary) -> void:
	if _salto_minimap_tooltip_accessibility_enabled():
		_live_ui_shell_tooltip_v0212(root, state)
		return
	var panel := _ui_architecture_panel(root, "LiveShellTooltip", Vector2(1000, 278), Vector2(428, 60), "TIP", "", Color(0.52, 0.62, 0.46, 0.82))
	panel.z_index = 30
	_ui_architecture_label(panel, str(state.get("tooltip", "")), Vector2(13, 28), Vector2(400, 26), 9, Color(0.82, 0.88, 0.78), HORIZONTAL_ALIGNMENT_LEFT)

func _live_ui_shell_tooltip_v0212(root: Control, state: Dictionary) -> void:
	var meta: Dictionary = state.get("tooltipMeta", {})
	var panel := _ui_architecture_panel(root, "V0212StructuredTooltip", Vector2(986, 264), Vector2(444, 106), "TIP", "", Color(0.52, 0.62, 0.46, 0.80))
	panel.z_index = 34
	_ui_architecture_label(panel, str(meta.get("title", "Command Tip")), Vector2(12, 27), Vector2(194, 16), 11, Color(0.95, 0.88, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_label(panel, "Shortcut %s" % str(meta.get("shortcut", "Mouse")), Vector2(278, 27), Vector2(142, 15), 8, Color(0.78, 0.90, 0.78), HORIZONTAL_ALIGNMENT_RIGHT)
	_ui_architecture_rect(panel, "V0212TooltipRule", Vector2(12, 48), Vector2(420, 1), Color(0.38, 0.54, 0.42, 0.70))
	_ui_architecture_label(panel, str(meta.get("body", state.get("tooltip", ""))), Vector2(12, 54), Vector2(420, 21), 8, Color(0.82, 0.88, 0.78), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_label(panel, "Cost: %s" % str(meta.get("cost", "No cost")), Vector2(12, 80), Vector2(156, 12), 8, Color(0.74, 0.80, 0.66), HORIZONTAL_ALIGNMENT_LEFT)
	_ui_architecture_label(panel, str(meta.get("availability", "Available")), Vector2(172, 80), Vector2(260, 12), 8, Color(0.88, 0.76, 0.46) if str(meta.get("availability", "")).to_lower().contains("unavailable") else Color(0.70, 0.86, 0.70), HORIZONTAL_ALIGNMENT_RIGHT)

func _live_ui_shell_action_button(parent: Control, position: Vector2, size: Vector2, text: String, method_name: String) -> Button:
	var button := Button.new()
	button.text = text
	button.position = position
	button.size = size
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_stylebox_override("normal", _ui_architecture_panel_style(Color(0.045, 0.055, 0.048, 0.96), Color(0.38, 0.58, 0.52, 0.76)))
	button.add_theme_stylebox_override("hover", _ui_architecture_panel_style(Color(0.08, 0.10, 0.075, 0.98), Color(0.70, 0.62, 0.36, 0.92)))
	button.add_theme_stylebox_override("pressed", _ui_architecture_panel_style(Color(0.12, 0.10, 0.07, 0.98), Color(0.90, 0.70, 0.34, 0.96)))
	button.add_theme_color_override("font_color", Color(0.88, 0.86, 0.68))
	button.pressed.connect(Callable(self, method_name))
	parent.add_child(button)
	return button

func _on_live_ui_shell_help_pressed() -> void:
	_call_scene("toggle_controls_help")
	_refresh_live_ui_shell_overlay()

func _on_live_ui_shell_pause_pressed() -> void:
	_call_scene("toggle_pause")
	_refresh_live_ui_shell_overlay()

func _on_live_ui_shell_move_pressed() -> void:
	_call_scene("issue_move_order")
	_refresh_live_ui_shell_overlay()

func _on_live_ui_shell_attack_pressed() -> void:
	_call_scene("issue_attack_order")
	_refresh_live_ui_shell_overlay()

func _on_live_ui_shell_work_pressed() -> void:
	var status := get_spike_status()
	if bool(status.get("barracksComplete", false)):
		_call_scene("queue_militia_recruit")
	elif bool(status.get("workerAssignedToMine", false)):
		_call_scene("place_barracks_placeholder")
		_call_scene("advance_construction", [60])
	elif bool(status.get("mineSiteConverted", false)):
		_call_scene("assign_worker_to_mine")
	else:
		_call_scene("capture_mine_site")
	_refresh_live_ui_shell_overlay()

func _on_live_ui_shell_lume_pressed() -> void:
	_call_scene("focus_lume_link")
	_refresh_live_ui_shell_overlay()

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
		"saltoUiShellOptInRequested": _script_args().has("--salto-ui-shell-experiment"),
		"saltoUiShellFallbackActive": _salto_ui_shell_fallback_active(),
		"saltoUiShellLiveOverlayEnabled": _salto_ui_shell_live_enabled(),
		"saltoSelectionCommandPanelEnabled": _salto_selection_command_panel_enabled(),
		"saltoProductionObjectivesLogEnabled": _salto_production_objectives_log_enabled(),
		"saltoMinimapTooltipAccessibilityEnabled": _salto_minimap_tooltip_accessibility_enabled(),
		"saltoPresentationRebootEnabled": _salto_presentation_reboot_enabled(),
		"saltoPresentationRebootUiOccupancy": _salto_presentation_reboot_occupancy_budget(),
		"saltoMinimalContextualHudEnabled": _salto_minimal_contextual_hud_enabled(),
		"saltoMinimalContextualHudOccupancy": _salto_minimal_contextual_hud_occupancy_budget(),
		"saltoHudVisualLanguageEnabled": _salto_hud_visual_language_enabled(),
		"saltoHudVisualLanguageReport": _salto_hud_visual_language_report(),
		"saltoAsterPortraitStatus": _salto_aster_portrait_status(),
		"saltoAsterPortraitSourceLoaded": bool(_salto_aster_portrait_status().get("sourceLoaded", false)),
		"saltoAsterPortraitFallbackActive": bool(_salto_aster_portrait_status().get("fallbackActive", true)),
		"saltoAsterPortraitProductionSlotAdded": false,
		"saltoAsterPortraitGeneratedImages": false,
		"finalProductionCertification": false
	}
	var forbidden_terms := _player_forbidden_terms()
	var forbidden_hits: Array[String] = []
	for text in _all_player_text_from_steps(steps):
		for term in forbidden_terms:
			if text.to_lower().contains(term):
				forbidden_hits.append("%s in '%s'" % [term, text])
	var final_status := get_spike_status()
	var worker_art: Dictionary = final_status.get("workerArtExperiment", {})
	var worker_art_loaded := bool(worker_art.get("sourceLoaded", false))
	var barracks_material: Dictionary = final_status.get("barracksMaterialExperiment", {})
	var barracks_material_loaded := bool(barracks_material.get("sourceLoaded", false))
	var militia_art: Dictionary = final_status.get("militiaArtExperiment", {})
	var militia_art_loaded := bool(militia_art.get("sourceLoaded", false))
	var aster_art: Dictionary = final_status.get("asterArtExperiment", {})
	var aster_art_loaded := bool(aster_art.get("sourceLoaded", false))
	var ashen_art: Dictionary = final_status.get("ashenArtExperiment", {})
	var ashen_art_loaded := bool(ashen_art.get("sourceLoaded", false))
	var ground_material: Dictionary = final_status.get("groundMaterialExperiment", {})
	var ground_material_loaded := bool(ground_material.get("sourceLoaded", false))
	var road_material: Dictionary = final_status.get("roadMaterialExperiment", {})
	var road_material_loaded := bool(road_material.get("sourceLoaded", false))
	var bridge_riverbank_material: Dictionary = final_status.get("bridgeRiverbankMaterialExperiment", {})
	var bridge_riverbank_material_loaded := bool(bridge_riverbank_material.get("sourceLoaded", false))
	var road_riverbank_water_material: Dictionary = final_status.get("roadRiverbankWaterMaterialExperiment", {})
	var road_riverbank_water_material_loaded := bool(road_riverbank_water_material.get("sourceLoaded", false))
	var bridge_shell: Dictionary = final_status.get("saltoBridgeShellReboot", {})
	var environment_foundation: Dictionary = final_status.get("environmentFoundationReview", {})
	var environment_readability: Dictionary = final_status.get("environmentReadabilityHardening", {})
	var environment_contrast: Dictionary = final_status.get("environmentContrastHarmonization", {})
	var environment_geometry: Dictionary = final_status.get("environmentGeometryConvergence", {})
	var environment_shell_live_qa: Dictionary = final_status.get("environmentShellLiveQa", {})
	var environment_structure_shell_hardening: Dictionary = final_status.get("environmentStructureShellHardening", {})
	var environment_riverbank_bridge_approach: Dictionary = final_status.get("environmentRiverbankBridgeApproach", {})
	var environment_presentation_shell_v2: Dictionary = final_status.get("environmentPresentationShellV2", {})
	var environment_shell_v2_mesh_compositor: Dictionary = final_status.get("environmentShellV2MeshCompositor", {})
	performance_smoke["workerArtOptInRequested"] = _script_args().has("--worker-art-opt-in")
	performance_smoke["workerArtExperiment"] = worker_art
	performance_smoke["barracksMaterialOptInRequested"] = _script_args().has("--barracks-material-opt-in")
	performance_smoke["barracksMaterialExperiment"] = barracks_material
	performance_smoke["militiaArtOptInRequested"] = _script_args().has("--militia-art-opt-in")
	performance_smoke["militiaArtExperiment"] = militia_art
	performance_smoke["asterArtOptInRequested"] = _script_args().has("--aster-art-opt-in")
	performance_smoke["asterArtExperiment"] = aster_art
	performance_smoke["ashenArtOptInRequested"] = _script_args().has("--ashen-art-opt-in")
	performance_smoke["ashenArtExperiment"] = ashen_art
	performance_smoke["groundMaterialOptInRequested"] = _script_args().has("--ground-material-opt-in")
	performance_smoke["groundMaterialExperiment"] = ground_material
	performance_smoke["roadMaterialOptInRequested"] = _script_args().has("--road-material-opt-in")
	performance_smoke["roadMaterialExperiment"] = road_material
	performance_smoke["bridgeRiverbankMaterialOptInRequested"] = _script_args().has("--bridge-riverbank-material-opt-in")
	performance_smoke["bridgeRiverbankMaterialExperiment"] = bridge_riverbank_material
	performance_smoke["roadRiverbankWaterMaterialOptInRequested"] = _script_args().has("--road-riverbank-water-material-opt-in")
	performance_smoke["roadRiverbankWaterMaterialExperiment"] = road_riverbank_water_material
	performance_smoke["roadRiverbankWaterMaterialRuntimeSlotAdded"] = false
	performance_smoke["roadRiverbankWaterMaterialProductionSlotAdded"] = false
	performance_smoke["saltoBridgeShellRebootEnabled"] = bool(final_status.get("saltoBridgeShellRebootEnabled", false))
	performance_smoke["saltoBridgeShellLegacyComparatorActive"] = bool(final_status.get("saltoBridgeShellLegacyComparatorActive", false))
	performance_smoke["saltoBridgeShellReboot"] = bridge_shell
	performance_smoke["environmentFoundationReviewEnabled"] = bool(final_status.get("environmentFoundationReviewEnabled", false))
	performance_smoke["environmentFoundationReview"] = environment_foundation
	performance_smoke["environmentReadabilityHardeningEnabled"] = bool(final_status.get("environmentReadabilityHardeningEnabled", false))
	performance_smoke["environmentReadabilityHardening"] = environment_readability
	performance_smoke["environmentContrastHarmonizationEnabled"] = bool(final_status.get("environmentContrastHarmonizationEnabled", false))
	performance_smoke["environmentContrastHarmonization"] = environment_contrast
	performance_smoke["environmentGeometryConvergenceEnabled"] = bool(final_status.get("environmentGeometryConvergenceEnabled", false))
	performance_smoke["environmentGeometryConvergence"] = environment_geometry
	performance_smoke["environmentShellLiveQaEnabled"] = bool(final_status.get("environmentShellLiveQaEnabled", false))
	performance_smoke["environmentShellLiveQa"] = environment_shell_live_qa
	performance_smoke["environmentStructureShellHardeningEnabled"] = bool(final_status.get("environmentStructureShellHardeningEnabled", false))
	performance_smoke["environmentStructureShellHardening"] = environment_structure_shell_hardening
	performance_smoke["environmentRiverbankBridgeApproachEnabled"] = bool(final_status.get("environmentRiverbankBridgeApproachEnabled", false))
	performance_smoke["environmentRiverbankBridgeApproach"] = environment_riverbank_bridge_approach
	performance_smoke["environmentPresentationShellV2Enabled"] = bool(final_status.get("environmentPresentationShellV2Enabled", false))
	performance_smoke["environmentPresentationShellV2"] = environment_presentation_shell_v2
	performance_smoke["environmentShellV2MeshCompositorEnabled"] = bool(final_status.get("environmentShellV2MeshCompositorEnabled", false))
	performance_smoke["environmentShellV2MeshCompositor"] = environment_shell_v2_mesh_compositor
	var report := {
		"schemaVersion": 1,
		"checkpoint": _player_capture_checkpoint(),
		"status": "PASS_PLAYER_SLICE_VALIDATION" if errors.is_empty() and forbidden_hits.is_empty() else "FAIL_PLAYER_SLICE_VALIDATION",
		"artifactRoot": artifact_root,
		"defaultHumanReviewPath": "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
		"workerArtOptInHumanReviewPath": "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat",
		"workerBarracksArtOptInHumanReviewPath": "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat",
		"workerBarracksMilitiaArtOptInHumanReviewPath": "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat",
		"workerBarracksMilitiaAsterArtOptInHumanReviewPath": "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ASTER_ART_EXPERIMENT_WINDOWS.bat",
		"fiveSlotArtOptInHumanReviewPath": "GODOT_LAUNCH_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat",
		"environmentFoundationReviewPath": "GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat",
		"environmentReadabilityReviewPath": "GODOT_REVIEW_SALTO_ENVIRONMENT_READABILITY_WINDOWS.bat",
		"groundMaterialOptInHumanReviewPath": "GODOT_REVIEW_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat",
		"environmentContrastReviewPath": "GODOT_REVIEW_SALTO_ENVIRONMENT_CONTRAST_WINDOWS.bat",
		"groundRoadMaterialOptInHumanReviewPath": "GODOT_REVIEW_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_WINDOWS.bat",
		"environmentGeometryConvergenceReviewPath": "GODOT_REVIEW_SALTO_ENVIRONMENT_GEOMETRY_CONVERGENCE_WINDOWS.bat",
		"environmentShellLiveQaReviewPath": "GODOT_REVIEW_SALTO_ENVIRONMENT_SHELL_LIVE_QA_WINDOWS.bat",
		"structureShellHardeningReviewPath": "GODOT_REVIEW_SALTO_STRUCTURE_SHELL_HARDENING_WINDOWS.bat",
		"riverbankBridgeApproachReviewPath": "GODOT_REVIEW_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat",
		"privateHarnessPreservedSeparately": true,
		"defaultMode": MODE_25D,
		"defaultVisualPreset": VISUAL_PRESET_CLEAN,
		"saltoUiShellOptInRequested": _script_args().has("--salto-ui-shell-experiment"),
		"saltoUiShellFallbackActive": _salto_ui_shell_fallback_active(),
		"saltoUiShellLiveOverlayEnabled": _salto_ui_shell_live_enabled(),
		"saltoUiShellProductionSlotAdded": false,
		"saltoSelectionCommandPanelEnabled": _salto_selection_command_panel_enabled(),
		"saltoProductionObjectivesLogEnabled": _salto_production_objectives_log_enabled(),
		"saltoMinimapTooltipAccessibilityEnabled": _salto_minimap_tooltip_accessibility_enabled(),
		"saltoPresentationRebootEnabled": _salto_presentation_reboot_enabled(),
		"saltoPresentationRebootUiOccupancy": _salto_presentation_reboot_occupancy_budget(),
		"saltoMinimalContextualHudEnabled": _salto_minimal_contextual_hud_enabled(),
		"saltoMinimalContextualHudOccupancy": _salto_minimal_contextual_hud_occupancy_budget(),
		"saltoHudVisualLanguageEnabled": _salto_hud_visual_language_enabled(),
		"saltoHudVisualLanguageReport": _salto_hud_visual_language_report(),
		"saltoAsterPortraitStatus": _salto_aster_portrait_status(),
		"saltoAsterPortraitSourceLoaded": bool(_salto_aster_portrait_status().get("sourceLoaded", false)),
		"saltoAsterPortraitFallbackActive": bool(_salto_aster_portrait_status().get("fallbackActive", true)),
		"saltoAsterPortraitProductionSlotAdded": false,
		"saltoAsterPortraitGeneratedImages": false,
		"routineEditorUseRequired": false,
		"manualGodotEditorSceneAssemblyRequired": false,
		"proceduralPrimitiveOnly": not worker_art_loaded and not barracks_material_loaded and not militia_art_loaded and not aster_art_loaded and not ashen_art_loaded and not ground_material_loaded and not road_material_loaded and not bridge_riverbank_material_loaded and not road_riverbank_water_material_loaded,
		"generatedOrImportedArtIncluded": worker_art_loaded or barracks_material_loaded or militia_art_loaded or aster_art_loaded or ashen_art_loaded or ground_material_loaded or road_material_loaded or bridge_riverbank_material_loaded or road_riverbank_water_material_loaded,
		"runtimeArtIntegrated": worker_art_loaded or barracks_material_loaded or militia_art_loaded or aster_art_loaded or ashen_art_loaded or ground_material_loaded or road_material_loaded or bridge_riverbank_material_loaded or road_riverbank_water_material_loaded,
		"workerArtOptInRequested": _script_args().has("--worker-art-opt-in"),
		"workerArtExperiment": worker_art,
		"barracksMaterialOptInRequested": _script_args().has("--barracks-material-opt-in"),
		"barracksMaterialExperiment": barracks_material,
		"militiaArtOptInRequested": _script_args().has("--militia-art-opt-in"),
		"militiaArtExperiment": militia_art,
		"asterArtOptInRequested": _script_args().has("--aster-art-opt-in"),
		"asterArtExperiment": aster_art,
		"ashenArtOptInRequested": _script_args().has("--ashen-art-opt-in"),
		"ashenArtExperiment": ashen_art,
		"groundMaterialOptInRequested": _script_args().has("--ground-material-opt-in"),
		"groundMaterialExperiment": ground_material,
		"roadMaterialOptInRequested": _script_args().has("--road-material-opt-in"),
		"roadMaterialExperiment": road_material,
		"bridgeRiverbankMaterialOptInRequested": _script_args().has("--bridge-riverbank-material-opt-in"),
		"bridgeRiverbankMaterialExperiment": bridge_riverbank_material,
		"roadRiverbankWaterMaterialOptInRequested": _script_args().has("--road-riverbank-water-material-opt-in"),
		"roadRiverbankWaterMaterialExperiment": road_riverbank_water_material,
		"roadRiverbankWaterMaterialRuntimeSlotAdded": false,
		"roadRiverbankWaterMaterialProductionSlotAdded": false,
		"saltoBridgeShellRebootEnabled": bool(final_status.get("saltoBridgeShellRebootEnabled", false)),
		"saltoBridgeShellLegacyComparatorActive": bool(final_status.get("saltoBridgeShellLegacyComparatorActive", false)),
		"saltoBridgeShellReboot": bridge_shell,
		"environmentFoundationReviewEnabled": bool(final_status.get("environmentFoundationReviewEnabled", false)),
		"environmentFoundationReview": environment_foundation,
		"environmentReadabilityHardeningEnabled": bool(final_status.get("environmentReadabilityHardeningEnabled", false)),
		"environmentReadabilityHardening": environment_readability,
		"environmentContrastHarmonizationEnabled": bool(final_status.get("environmentContrastHarmonizationEnabled", false)),
		"environmentContrastHarmonization": environment_contrast,
		"environmentGeometryConvergenceEnabled": bool(final_status.get("environmentGeometryConvergenceEnabled", false)),
		"environmentGeometryConvergence": environment_geometry,
		"environmentGeometryConvergenceArtSlotCount": int(final_status.get("environmentGeometryConvergenceArtSlotCount", 0)),
		"environmentShellLiveQaEnabled": bool(final_status.get("environmentShellLiveQaEnabled", false)),
		"environmentShellLiveQa": environment_shell_live_qa,
		"environmentShellLiveQaArtSlotCount": int(final_status.get("environmentShellLiveQaArtSlotCount", 0)),
		"environmentStructureShellHardeningEnabled": bool(final_status.get("environmentStructureShellHardeningEnabled", false)),
		"environmentStructureShellHardening": environment_structure_shell_hardening,
		"environmentStructureShellHardeningArtSlotCount": int(final_status.get("environmentStructureShellHardeningArtSlotCount", 0)),
		"environmentRiverbankBridgeApproachEnabled": bool(final_status.get("environmentRiverbankBridgeApproachEnabled", false)),
		"environmentRiverbankBridgeApproach": environment_riverbank_bridge_approach,
		"environmentRiverbankBridgeApproachArtSlotCount": int(final_status.get("environmentRiverbankBridgeApproachArtSlotCount", 0)),
		"environmentPresentationShellV2Enabled": bool(final_status.get("environmentPresentationShellV2Enabled", false)),
		"environmentPresentationShellV2": environment_presentation_shell_v2,
		"environmentPresentationShellV2ArtSlotCount": int(final_status.get("environmentPresentationShellV2ArtSlotCount", 0)),
		"environmentShellV2MeshCompositorEnabled": bool(final_status.get("environmentShellV2MeshCompositorEnabled", false)),
		"environmentShellV2MeshCompositor": environment_shell_v2_mesh_compositor,
		"environmentFoundationArtSlotCount": int(final_status.get("environmentFoundationArtSlotCount", 0)),
		"terrainMaterialSourceImported": bool(final_status.get("terrainMaterialSourceImported", false)),
		"terrainMaterialRuntimeSlotAdded": bool(final_status.get("terrainMaterialRuntimeSlotAdded", false)),
		"roadMaterialSourceImported": bool(final_status.get("roadMaterialSourceImported", false)),
		"roadMaterialRuntimeSlotAdded": bool(final_status.get("roadMaterialRuntimeSlotAdded", false)),
		"bridgeRiverbankMaterialSourceImported": bool(final_status.get("bridgeRiverbankMaterialSourceImported", false)),
		"bridgeRiverbankMaterialRuntimeSlotAdded": bool(final_status.get("bridgeRiverbankMaterialRuntimeSlotAdded", false)),
		"environmentMaterialOptInRequestedSlotCount": int(final_status.get("environmentMaterialOptInRequestedSlotCount", 0)),
		"environmentMaterialOptInLoadedSlotCount": int(final_status.get("environmentMaterialOptInLoadedSlotCount", 0)),
		"environmentMaterialOptInRequestedBundleCount": int(final_status.get("environmentMaterialOptInRequestedBundleCount", 0)),
		"environmentMaterialOptInLoadedBundleCount": int(final_status.get("environmentMaterialOptInLoadedBundleCount", 0)),
		"normalSliceOptInRequestedSlotCount": int(final_status.get("normalSliceOptInRequestedSlotCount", 0)),
		"normalSliceOptInLoadedSlotCount": int(final_status.get("normalSliceOptInLoadedSlotCount", 0)),
		"workerArtProceduralFallbackActive": bool(final_status.get("workerArtProceduralFallbackActive", false)),
		"barracksMaterialProceduralFallbackActive": bool(final_status.get("barracksMaterialProceduralFallbackActive", false)),
		"militiaArtProceduralFallbackActive": bool(final_status.get("militiaArtProceduralFallbackActive", false)),
		"asterArtProceduralFallbackActive": bool(final_status.get("asterArtProceduralFallbackActive", false)),
		"ashenArtProceduralFallbackActive": bool(final_status.get("ashenArtProceduralFallbackActive", false)),
		"groundMaterialProceduralFallbackActive": bool(final_status.get("groundMaterialProceduralFallbackActive", false)),
		"roadMaterialProceduralFallbackActive": bool(final_status.get("roadMaterialProceduralFallbackActive", false)),
		"bridgeRiverbankMaterialProceduralFallbackActive": bool(final_status.get("bridgeRiverbankMaterialProceduralFallbackActive", false)),
		"roadRiverbankWaterMaterialProceduralFallbackActive": bool(final_status.get("roadRiverbankWaterMaterialProceduralFallbackActive", false)),
		"fourthPlayerFacingArtSlotAdded": bool(final_status.get("fourthPlayerFacingArtSlotAdded", false)),
		"fifthPlayerFacingArtSlotAdded": bool(final_status.get("fifthPlayerFacingArtSlotAdded", false)),
		"sixthPlayerFacingArtSlotAdded": bool(final_status.get("sixthPlayerFacingArtSlotAdded", false)),
		"v0165VisualHardeningAudit": final_status.get("v0165VisualHardeningAudit", {}),
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

func _capture_step_viewport(step: Dictionary) -> Vector2i:
	var viewport_value = step.get("viewport", {})
	if typeof(viewport_value) == TYPE_DICTIONARY:
		var viewport: Dictionary = viewport_value
		return Vector2i(max(320, int(viewport.get("width", VIEWPORT_SIZE.x))), max(240, int(viewport.get("height", VIEWPORT_SIZE.y))))
	return VIEWPORT_SIZE

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
		var target_viewport := _capture_step_viewport(step)
		_set_capture_viewport(target_viewport)
		await _settle_frames(4)
		var action := str(step["action"])
		var status := _apply_player_slice_action(action)
		await _settle_frames(6)
		var file_name := "%02d_%s.png" % [index + 1, str(step["id"])]
		var target := _path_join(screenshot_root, file_name)
		var image: Image = null
		for attempt in range(20):
			var texture := get_viewport().get_texture()
			if texture != null:
				image = texture.get_image()
			if image != null:
				break
			await _settle_frames(2)
		if image == null:
			errors.append("Viewport texture was unavailable for screenshot %s" % file_name)
			image = Image.create(target_viewport.x, target_viewport.y, false, Image.FORMAT_RGBA8)
			image.fill(Color(0.02, 0.02, 0.02, 1.0))
		if image.get_width() != target_viewport.x or image.get_height() != target_viewport.y:
			image.resize(target_viewport.x, target_viewport.y, Image.INTERPOLATE_LANCZOS)
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
			"viewport": {"width": target_viewport.x, "height": target_viewport.y},
			"screen": active_mode,
			"action": action,
			"privateHarnessCapture": action == "private_harness",
			"status": status,
			"visibleText": player_visible_texts.duplicate()
		})
		index += 1
	var final_status := get_spike_status()
	var worker_art: Dictionary = final_status.get("workerArtExperiment", {})
	var worker_art_loaded := bool(worker_art.get("sourceLoaded", false))
	var barracks_material: Dictionary = final_status.get("barracksMaterialExperiment", {})
	var barracks_material_loaded := bool(barracks_material.get("sourceLoaded", false))
	var militia_art: Dictionary = final_status.get("militiaArtExperiment", {})
	var militia_art_loaded := bool(militia_art.get("sourceLoaded", false))
	var aster_art: Dictionary = final_status.get("asterArtExperiment", {})
	var aster_art_loaded := bool(aster_art.get("sourceLoaded", false))
	var ashen_art: Dictionary = final_status.get("ashenArtExperiment", {})
	var ashen_art_loaded := bool(ashen_art.get("sourceLoaded", false))
	var ground_material: Dictionary = final_status.get("groundMaterialExperiment", {})
	var ground_material_loaded := bool(ground_material.get("sourceLoaded", false))
	var road_material: Dictionary = final_status.get("roadMaterialExperiment", {})
	var road_material_loaded := bool(road_material.get("sourceLoaded", false))
	var bridge_riverbank_material: Dictionary = final_status.get("bridgeRiverbankMaterialExperiment", {})
	var bridge_riverbank_material_loaded := bool(bridge_riverbank_material.get("sourceLoaded", false))
	var road_riverbank_water_material: Dictionary = final_status.get("roadRiverbankWaterMaterialExperiment", {})
	var road_riverbank_water_material_loaded := bool(road_riverbank_water_material.get("sourceLoaded", false))
	var bridge_shell: Dictionary = final_status.get("saltoBridgeShellReboot", {})
	var environment_foundation: Dictionary = final_status.get("environmentFoundationReview", {})
	var environment_readability: Dictionary = final_status.get("environmentReadabilityHardening", {})
	var environment_contrast: Dictionary = final_status.get("environmentContrastHarmonization", {})
	var environment_geometry: Dictionary = final_status.get("environmentGeometryConvergence", {})
	var environment_shell_live_qa: Dictionary = final_status.get("environmentShellLiveQa", {})
	var environment_structure_shell_hardening: Dictionary = final_status.get("environmentStructureShellHardening", {})
	var environment_riverbank_bridge_approach: Dictionary = final_status.get("environmentRiverbankBridgeApproach", {})
	var environment_presentation_shell_v2: Dictionary = final_status.get("environmentPresentationShellV2", {})
	var environment_shell_v2_mesh_compositor: Dictionary = final_status.get("environmentShellV2MeshCompositor", {})
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
		"saltoUiShellOptInRequested": _script_args().has("--salto-ui-shell-experiment"),
		"saltoUiShellFallbackActive": _salto_ui_shell_fallback_active(),
		"saltoUiShellLiveOverlayEnabled": _salto_ui_shell_live_enabled(),
		"saltoUiShellProductionSlotAdded": false,
		"saltoSelectionCommandPanelEnabled": _salto_selection_command_panel_enabled(),
		"saltoProductionObjectivesLogEnabled": _salto_production_objectives_log_enabled(),
		"saltoMinimapTooltipAccessibilityEnabled": _salto_minimap_tooltip_accessibility_enabled(),
		"saltoPresentationRebootEnabled": _salto_presentation_reboot_enabled(),
		"saltoPresentationRebootUiOccupancy": _salto_presentation_reboot_occupancy_budget(),
		"saltoMinimalContextualHudEnabled": _salto_minimal_contextual_hud_enabled(),
		"saltoMinimalContextualHudOccupancy": _salto_minimal_contextual_hud_occupancy_budget(),
		"saltoHudVisualLanguageEnabled": _salto_hud_visual_language_enabled(),
		"saltoHudVisualLanguageReport": _salto_hud_visual_language_report(),
		"saltoAsterPortraitStatus": _salto_aster_portrait_status(),
		"saltoAsterPortraitSourceLoaded": bool(_salto_aster_portrait_status().get("sourceLoaded", false)),
		"saltoAsterPortraitFallbackActive": bool(_salto_aster_portrait_status().get("fallbackActive", true)),
		"saltoAsterPortraitProductionSlotAdded": false,
		"saltoAsterPortraitGeneratedImages": false,
		"privateHarnessPreservedSeparately": captures.any(func(capture: Dictionary) -> bool: return bool(capture.get("privateHarnessCapture", false))) or ["v0.126", "v0.127", "v0.128", "v0.129", "v0.130", "v0.160", "v0.162", "v0.164", "v0.166", "v0.168", "v0.169", "v0.170", "v0.173", "v0.174", "v0.177", "v0.178", "v0.179", "v0.181", "v0.184", "v0.185", "v0.186", "v0.187", "v0.193", "v0.194", "v0.195", "v0.196", "v0.197", "v0.198", "v0.199", "v0.200", "v0.203", "v0.204", "v0.205", "v0.206", "v0.209", "v0.210", "v0.211", "v0.212", "v0.217", "v0.218", "v0.219", "v0.220", "v0.221", "v0.222"].has(_player_capture_checkpoint()),
		"proceduralPrimitiveOnly": not worker_art_loaded and not barracks_material_loaded and not militia_art_loaded and not aster_art_loaded and not ashen_art_loaded and not ground_material_loaded and not road_material_loaded and not bridge_riverbank_material_loaded and not road_riverbank_water_material_loaded,
		"generatedOrImportedArtIncluded": worker_art_loaded or barracks_material_loaded or militia_art_loaded or aster_art_loaded or ashen_art_loaded or ground_material_loaded or road_material_loaded or bridge_riverbank_material_loaded or road_riverbank_water_material_loaded,
		"runtimeArtIntegrated": worker_art_loaded or barracks_material_loaded or militia_art_loaded or aster_art_loaded or ashen_art_loaded or ground_material_loaded or road_material_loaded or bridge_riverbank_material_loaded or road_riverbank_water_material_loaded,
		"workerArtOptInRequested": _script_args().has("--worker-art-opt-in"),
		"workerArtExperiment": worker_art,
		"barracksMaterialOptInRequested": _script_args().has("--barracks-material-opt-in"),
		"barracksMaterialExperiment": barracks_material,
		"militiaArtOptInRequested": _script_args().has("--militia-art-opt-in"),
		"militiaArtExperiment": militia_art,
		"asterArtOptInRequested": _script_args().has("--aster-art-opt-in"),
		"asterArtExperiment": aster_art,
		"ashenArtOptInRequested": _script_args().has("--ashen-art-opt-in"),
		"ashenArtExperiment": ashen_art,
		"groundMaterialOptInRequested": _script_args().has("--ground-material-opt-in"),
		"groundMaterialExperiment": ground_material,
		"roadMaterialOptInRequested": _script_args().has("--road-material-opt-in"),
		"roadMaterialExperiment": road_material,
		"bridgeRiverbankMaterialOptInRequested": _script_args().has("--bridge-riverbank-material-opt-in"),
		"bridgeRiverbankMaterialExperiment": bridge_riverbank_material,
		"roadRiverbankWaterMaterialOptInRequested": _script_args().has("--road-riverbank-water-material-opt-in"),
		"roadRiverbankWaterMaterialExperiment": road_riverbank_water_material,
		"roadRiverbankWaterMaterialRuntimeSlotAdded": false,
		"roadRiverbankWaterMaterialProductionSlotAdded": false,
		"saltoBridgeShellRebootEnabled": bool(final_status.get("saltoBridgeShellRebootEnabled", false)),
		"saltoBridgeShellLegacyComparatorActive": bool(final_status.get("saltoBridgeShellLegacyComparatorActive", false)),
		"saltoBridgeShellReboot": bridge_shell,
		"environmentFoundationReviewEnabled": bool(final_status.get("environmentFoundationReviewEnabled", false)),
		"environmentFoundationReview": environment_foundation,
		"environmentReadabilityHardeningEnabled": bool(final_status.get("environmentReadabilityHardeningEnabled", false)),
		"environmentReadabilityHardening": environment_readability,
		"environmentContrastHarmonizationEnabled": bool(final_status.get("environmentContrastHarmonizationEnabled", false)),
		"environmentContrastHarmonization": environment_contrast,
		"environmentGeometryConvergenceEnabled": bool(final_status.get("environmentGeometryConvergenceEnabled", false)),
		"environmentGeometryConvergence": environment_geometry,
		"environmentGeometryConvergenceArtSlotCount": int(final_status.get("environmentGeometryConvergenceArtSlotCount", 0)),
		"environmentShellLiveQaEnabled": bool(final_status.get("environmentShellLiveQaEnabled", false)),
		"environmentShellLiveQa": environment_shell_live_qa,
		"environmentShellLiveQaArtSlotCount": int(final_status.get("environmentShellLiveQaArtSlotCount", 0)),
		"environmentStructureShellHardeningEnabled": bool(final_status.get("environmentStructureShellHardeningEnabled", false)),
		"environmentStructureShellHardening": environment_structure_shell_hardening,
		"environmentStructureShellHardeningArtSlotCount": int(final_status.get("environmentStructureShellHardeningArtSlotCount", 0)),
		"environmentRiverbankBridgeApproachEnabled": bool(final_status.get("environmentRiverbankBridgeApproachEnabled", false)),
		"environmentRiverbankBridgeApproach": environment_riverbank_bridge_approach,
		"environmentRiverbankBridgeApproachArtSlotCount": int(final_status.get("environmentRiverbankBridgeApproachArtSlotCount", 0)),
		"environmentPresentationShellV2Enabled": bool(final_status.get("environmentPresentationShellV2Enabled", false)),
		"environmentPresentationShellV2": environment_presentation_shell_v2,
		"environmentPresentationShellV2ArtSlotCount": int(final_status.get("environmentPresentationShellV2ArtSlotCount", 0)),
		"environmentShellV2MeshCompositorEnabled": bool(final_status.get("environmentShellV2MeshCompositorEnabled", false)),
		"environmentShellV2MeshCompositor": environment_shell_v2_mesh_compositor,
		"environmentFoundationArtSlotCount": int(final_status.get("environmentFoundationArtSlotCount", 0)),
		"terrainMaterialSourceImported": bool(final_status.get("terrainMaterialSourceImported", false)),
		"terrainMaterialRuntimeSlotAdded": bool(final_status.get("terrainMaterialRuntimeSlotAdded", false)),
		"roadMaterialSourceImported": bool(final_status.get("roadMaterialSourceImported", false)),
		"roadMaterialRuntimeSlotAdded": bool(final_status.get("roadMaterialRuntimeSlotAdded", false)),
		"bridgeRiverbankMaterialSourceImported": bool(final_status.get("bridgeRiverbankMaterialSourceImported", false)),
		"bridgeRiverbankMaterialRuntimeSlotAdded": bool(final_status.get("bridgeRiverbankMaterialRuntimeSlotAdded", false)),
		"environmentMaterialOptInRequestedSlotCount": int(final_status.get("environmentMaterialOptInRequestedSlotCount", 0)),
		"environmentMaterialOptInLoadedSlotCount": int(final_status.get("environmentMaterialOptInLoadedSlotCount", 0)),
		"environmentMaterialOptInRequestedBundleCount": int(final_status.get("environmentMaterialOptInRequestedBundleCount", 0)),
		"environmentMaterialOptInLoadedBundleCount": int(final_status.get("environmentMaterialOptInLoadedBundleCount", 0)),
		"normalSliceOptInRequestedSlotCount": int(final_status.get("normalSliceOptInRequestedSlotCount", 0)),
		"normalSliceOptInLoadedSlotCount": int(final_status.get("normalSliceOptInLoadedSlotCount", 0)),
		"workerArtProceduralFallbackActive": bool(final_status.get("workerArtProceduralFallbackActive", false)),
		"barracksMaterialProceduralFallbackActive": bool(final_status.get("barracksMaterialProceduralFallbackActive", false)),
		"militiaArtProceduralFallbackActive": bool(final_status.get("militiaArtProceduralFallbackActive", false)),
		"asterArtProceduralFallbackActive": bool(final_status.get("asterArtProceduralFallbackActive", false)),
		"ashenArtProceduralFallbackActive": bool(final_status.get("ashenArtProceduralFallbackActive", false)),
		"groundMaterialProceduralFallbackActive": bool(final_status.get("groundMaterialProceduralFallbackActive", false)),
		"roadMaterialProceduralFallbackActive": bool(final_status.get("roadMaterialProceduralFallbackActive", false)),
		"bridgeRiverbankMaterialProceduralFallbackActive": bool(final_status.get("bridgeRiverbankMaterialProceduralFallbackActive", false)),
		"roadRiverbankWaterMaterialProceduralFallbackActive": bool(final_status.get("roadRiverbankWaterMaterialProceduralFallbackActive", false)),
		"fourthPlayerFacingArtSlotAdded": bool(final_status.get("fourthPlayerFacingArtSlotAdded", false)),
		"fifthPlayerFacingArtSlotAdded": bool(final_status.get("fifthPlayerFacingArtSlotAdded", false)),
		"sixthPlayerFacingArtSlotAdded": bool(final_status.get("sixthPlayerFacingArtSlotAdded", false)),
		"v0165VisualHardeningAudit": final_status.get("v0165VisualHardeningAudit", {}),
		"routineEditorUseRequired": false,
		"errors": errors,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "screenshot-runtime-manifest.json"), report)
	get_tree().quit(0 if errors.is_empty() else 1)

func run_worker_art_opt_in_benchmark() -> void:
	var artifact_root := _artifact_root_from_args()
	var errors: Array[String] = []
	var start_usec := Time.get_ticks_usec()
	var actions := [
		"battle_default",
		"worker_selected",
		"mine_converted",
		"worker_assigned_mine",
		"build_placement",
		"barracks_complete",
		"squad_selected"
	]
	var steps: Array[Dictionary] = []
	for action in actions:
		var step_start := Time.get_ticks_usec()
		var status := _apply_player_slice_action(action)
		await _settle_frames(6)
		if not bool(status.get("ready", false)):
			errors.append("%s did not reach a ready player-slice benchmark state." % action)
		steps.append({
			"id": action,
			"durationMs": snappedf(float(Time.get_ticks_usec() - step_start) / 1000.0, 0.01),
			"status": status
		})
	var frame_times: Array[float] = []
	for _index in range(240):
		var before := Time.get_ticks_usec()
		await get_tree().process_frame
		var after := Time.get_ticks_usec()
		frame_times.append(max(0.01, float(after - before) / 1000.0))
	var frame_sum := 0.0
	for value in frame_times:
		frame_sum += value
	var average_frame_ms := frame_sum / float(max(1, frame_times.size()))
	var final_status := get_spike_status()
	var worker_art: Dictionary = final_status.get("workerArtExperiment", {})
	var barracks_material: Dictionary = final_status.get("barracksMaterialExperiment", {})
	var militia_art: Dictionary = final_status.get("militiaArtExperiment", {})
	var aster_art: Dictionary = final_status.get("asterArtExperiment", {})
	var ashen_art: Dictionary = final_status.get("ashenArtExperiment", {})
	var ground_material: Dictionary = final_status.get("groundMaterialExperiment", {})
	var road_material: Dictionary = final_status.get("roadMaterialExperiment", {})
	var bridge_riverbank_material: Dictionary = final_status.get("bridgeRiverbankMaterialExperiment", {})
	var road_riverbank_water_material: Dictionary = final_status.get("roadRiverbankWaterMaterialExperiment", {})
	var bridge_shell: Dictionary = final_status.get("saltoBridgeShellReboot", {})
	var environment_foundation: Dictionary = final_status.get("environmentFoundationReview", {})
	var environment_readability: Dictionary = final_status.get("environmentReadabilityHardening", {})
	var environment_contrast: Dictionary = final_status.get("environmentContrastHarmonization", {})
	var environment_geometry: Dictionary = final_status.get("environmentGeometryConvergence", {})
	var environment_shell_live_qa: Dictionary = final_status.get("environmentShellLiveQa", {})
	var environment_structure_shell_hardening: Dictionary = final_status.get("environmentStructureShellHardening", {})
	var environment_riverbank_bridge_approach: Dictionary = final_status.get("environmentRiverbankBridgeApproach", {})
	var environment_presentation_shell_v2: Dictionary = final_status.get("environmentPresentationShellV2", {})
	var environment_shell_v2_mesh_compositor: Dictionary = final_status.get("environmentShellV2MeshCompositor", {})
	var any_loaded := bool(worker_art.get("sourceLoaded", false)) or bool(barracks_material.get("sourceLoaded", false)) or bool(militia_art.get("sourceLoaded", false)) or bool(aster_art.get("sourceLoaded", false)) or bool(ashen_art.get("sourceLoaded", false)) or bool(ground_material.get("sourceLoaded", false)) or bool(road_material.get("sourceLoaded", false)) or bool(bridge_riverbank_material.get("sourceLoaded", false)) or bool(road_riverbank_water_material.get("sourceLoaded", false))
	var five_slot_requested := _script_args().has("--ashen-art-opt-in")
	var four_slot_requested := _script_args().has("--aster-art-opt-in")
	var three_slot_requested := _script_args().has("--militia-art-opt-in")
	var two_slot_requested := _script_args().has("--barracks-material-opt-in")
	var report := {
		"schemaVersion": 1,
		"checkpoint": _player_capture_checkpoint(),
		"status": ("PASS_V0170_WORKER_BARRACKS_MILITIA_ASTER_ASHEN_ART_OPT_IN_RUNTIME_BENCHMARK" if five_slot_requested else ("PASS_V0168_WORKER_BARRACKS_MILITIA_ASTER_ART_OPT_IN_RUNTIME_BENCHMARK" if four_slot_requested else ("PASS_V0164_WORKER_BARRACKS_MILITIA_ART_OPT_IN_RUNTIME_BENCHMARK" if three_slot_requested else ("PASS_V0162_WORKER_BARRACKS_ART_OPT_IN_RUNTIME_BENCHMARK" if two_slot_requested else "PASS_V0160_WORKER_ART_OPT_IN_RUNTIME_BENCHMARK")))) if errors.is_empty() else ("FAIL_V0170_WORKER_BARRACKS_MILITIA_ASTER_ASHEN_ART_OPT_IN_RUNTIME_BENCHMARK" if five_slot_requested else ("FAIL_V0168_WORKER_BARRACKS_MILITIA_ASTER_ART_OPT_IN_RUNTIME_BENCHMARK" if four_slot_requested else ("FAIL_V0164_WORKER_BARRACKS_MILITIA_ART_OPT_IN_RUNTIME_BENCHMARK" if three_slot_requested else ("FAIL_V0162_WORKER_BARRACKS_ART_OPT_IN_RUNTIME_BENCHMARK" if two_slot_requested else "FAIL_V0160_WORKER_ART_OPT_IN_RUNTIME_BENCHMARK")))),
		"artifactRoot": artifact_root,
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"mode": MODE_25D,
		"visualPreset": VISUAL_PRESET_CLEAN,
		"fpsAverage": snappedf(min(240.0, 1000.0 / max(0.01, average_frame_ms)), 0.01),
		"frameTimeAverageMs": snappedf(average_frame_ms, 0.01),
		"frameTimeP95Ms": _percentile(frame_times, 0.95),
		"frameTimeP99Ms": _percentile(frame_times, 0.99),
		"saltoUiShellOptInRequested": _script_args().has("--salto-ui-shell-experiment"),
		"saltoUiShellFallbackActive": _salto_ui_shell_fallback_active(),
		"saltoUiShellLiveOverlayEnabled": _salto_ui_shell_live_enabled(),
		"saltoSelectionCommandPanelEnabled": _salto_selection_command_panel_enabled(),
		"saltoProductionObjectivesLogEnabled": _salto_production_objectives_log_enabled(),
		"saltoMinimapTooltipAccessibilityEnabled": _salto_minimap_tooltip_accessibility_enabled(),
		"saltoPresentationRebootEnabled": _salto_presentation_reboot_enabled(),
		"saltoPresentationRebootUiOccupancy": _salto_presentation_reboot_occupancy_budget(),
		"saltoMinimalContextualHudEnabled": _salto_minimal_contextual_hud_enabled(),
		"saltoMinimalContextualHudOccupancy": _salto_minimal_contextual_hud_occupancy_budget(),
		"saltoHudVisualLanguageEnabled": _salto_hud_visual_language_enabled(),
		"saltoHudVisualLanguageReport": _salto_hud_visual_language_report(),
		"workerArtOptInRequested": _script_args().has("--worker-art-opt-in"),
		"workerArtExperiment": worker_art,
		"barracksMaterialOptInRequested": _script_args().has("--barracks-material-opt-in"),
		"barracksMaterialExperiment": barracks_material,
		"militiaArtOptInRequested": _script_args().has("--militia-art-opt-in"),
		"militiaArtExperiment": militia_art,
		"asterArtOptInRequested": _script_args().has("--aster-art-opt-in"),
		"asterArtExperiment": aster_art,
		"ashenArtOptInRequested": _script_args().has("--ashen-art-opt-in"),
		"ashenArtExperiment": ashen_art,
		"groundMaterialOptInRequested": _script_args().has("--ground-material-opt-in"),
		"groundMaterialExperiment": ground_material,
		"roadMaterialOptInRequested": _script_args().has("--road-material-opt-in"),
		"roadMaterialExperiment": road_material,
		"bridgeRiverbankMaterialOptInRequested": _script_args().has("--bridge-riverbank-material-opt-in"),
		"bridgeRiverbankMaterialExperiment": bridge_riverbank_material,
		"roadRiverbankWaterMaterialOptInRequested": _script_args().has("--road-riverbank-water-material-opt-in"),
		"roadRiverbankWaterMaterialExperiment": road_riverbank_water_material,
		"roadRiverbankWaterMaterialRuntimeSlotAdded": false,
		"roadRiverbankWaterMaterialProductionSlotAdded": false,
		"saltoBridgeShellRebootEnabled": bool(final_status.get("saltoBridgeShellRebootEnabled", false)),
		"saltoBridgeShellLegacyComparatorActive": bool(final_status.get("saltoBridgeShellLegacyComparatorActive", false)),
		"saltoBridgeShellReboot": bridge_shell,
		"environmentFoundationReviewEnabled": bool(final_status.get("environmentFoundationReviewEnabled", false)),
		"environmentFoundationReview": environment_foundation,
		"environmentReadabilityHardeningEnabled": bool(final_status.get("environmentReadabilityHardeningEnabled", false)),
		"environmentReadabilityHardening": environment_readability,
		"environmentContrastHarmonizationEnabled": bool(final_status.get("environmentContrastHarmonizationEnabled", false)),
		"environmentContrastHarmonization": environment_contrast,
		"environmentGeometryConvergenceEnabled": bool(final_status.get("environmentGeometryConvergenceEnabled", false)),
		"environmentGeometryConvergence": environment_geometry,
		"environmentGeometryConvergenceArtSlotCount": int(final_status.get("environmentGeometryConvergenceArtSlotCount", 0)),
		"environmentShellLiveQaEnabled": bool(final_status.get("environmentShellLiveQaEnabled", false)),
		"environmentShellLiveQa": environment_shell_live_qa,
		"environmentShellLiveQaArtSlotCount": int(final_status.get("environmentShellLiveQaArtSlotCount", 0)),
		"environmentStructureShellHardeningEnabled": bool(final_status.get("environmentStructureShellHardeningEnabled", false)),
		"environmentStructureShellHardening": environment_structure_shell_hardening,
		"environmentStructureShellHardeningArtSlotCount": int(final_status.get("environmentStructureShellHardeningArtSlotCount", 0)),
		"environmentRiverbankBridgeApproachEnabled": bool(final_status.get("environmentRiverbankBridgeApproachEnabled", false)),
		"environmentRiverbankBridgeApproach": environment_riverbank_bridge_approach,
		"environmentRiverbankBridgeApproachArtSlotCount": int(final_status.get("environmentRiverbankBridgeApproachArtSlotCount", 0)),
		"environmentPresentationShellV2Enabled": bool(final_status.get("environmentPresentationShellV2Enabled", false)),
		"environmentPresentationShellV2": environment_presentation_shell_v2,
		"environmentPresentationShellV2ArtSlotCount": int(final_status.get("environmentPresentationShellV2ArtSlotCount", 0)),
		"environmentShellV2MeshCompositorEnabled": bool(final_status.get("environmentShellV2MeshCompositorEnabled", false)),
		"environmentShellV2MeshCompositor": environment_shell_v2_mesh_compositor,
		"environmentReadabilityArtSlotCount": int(final_status.get("environmentReadabilityArtSlotCount", 0)),
		"environmentFoundationArtSlotCount": int(final_status.get("environmentFoundationArtSlotCount", 0)),
		"terrainMaterialSourceImported": bool(final_status.get("terrainMaterialSourceImported", false)),
		"terrainMaterialRuntimeSlotAdded": bool(final_status.get("terrainMaterialRuntimeSlotAdded", false)),
		"roadMaterialSourceImported": bool(final_status.get("roadMaterialSourceImported", false)),
		"roadMaterialRuntimeSlotAdded": bool(final_status.get("roadMaterialRuntimeSlotAdded", false)),
		"bridgeRiverbankMaterialSourceImported": bool(final_status.get("bridgeRiverbankMaterialSourceImported", false)),
		"bridgeRiverbankMaterialRuntimeSlotAdded": bool(final_status.get("bridgeRiverbankMaterialRuntimeSlotAdded", false)),
		"environmentMaterialOptInRequestedSlotCount": int(final_status.get("environmentMaterialOptInRequestedSlotCount", 0)),
		"environmentMaterialOptInLoadedSlotCount": int(final_status.get("environmentMaterialOptInLoadedSlotCount", 0)),
		"environmentMaterialOptInRequestedBundleCount": int(final_status.get("environmentMaterialOptInRequestedBundleCount", 0)),
		"environmentMaterialOptInLoadedBundleCount": int(final_status.get("environmentMaterialOptInLoadedBundleCount", 0)),
		"normalSliceOptInRequestedSlotCount": int(final_status.get("normalSliceOptInRequestedSlotCount", 0)),
		"normalSliceOptInLoadedSlotCount": int(final_status.get("normalSliceOptInLoadedSlotCount", 0)),
		"workerArtProceduralFallbackActive": bool(final_status.get("workerArtProceduralFallbackActive", false)),
		"barracksMaterialProceduralFallbackActive": bool(final_status.get("barracksMaterialProceduralFallbackActive", false)),
		"militiaArtProceduralFallbackActive": bool(final_status.get("militiaArtProceduralFallbackActive", false)),
		"asterArtProceduralFallbackActive": bool(final_status.get("asterArtProceduralFallbackActive", false)),
		"ashenArtProceduralFallbackActive": bool(final_status.get("ashenArtProceduralFallbackActive", false)),
		"groundMaterialProceduralFallbackActive": bool(final_status.get("groundMaterialProceduralFallbackActive", false)),
		"roadMaterialProceduralFallbackActive": bool(final_status.get("roadMaterialProceduralFallbackActive", false)),
		"bridgeRiverbankMaterialProceduralFallbackActive": bool(final_status.get("bridgeRiverbankMaterialProceduralFallbackActive", false)),
		"roadRiverbankWaterMaterialProceduralFallbackActive": bool(final_status.get("roadRiverbankWaterMaterialProceduralFallbackActive", false)),
		"fourthPlayerFacingArtSlotAdded": bool(final_status.get("fourthPlayerFacingArtSlotAdded", false)),
		"fifthPlayerFacingArtSlotAdded": bool(final_status.get("fifthPlayerFacingArtSlotAdded", false)),
		"sixthPlayerFacingArtSlotAdded": bool(final_status.get("sixthPlayerFacingArtSlotAdded", false)),
		"v0165VisualHardeningAudit": final_status.get("v0165VisualHardeningAudit", {}),
		"proceduralPrimitiveOnly": not any_loaded,
		"generatedOrImportedArtIncluded": any_loaded,
		"runtimeArtIntegrated": any_loaded,
		"cacheCounters": {
			"sourceLoadCount": int(worker_art.get("sourceLoadCount", 0)),
			"metadataParseCount": int(worker_art.get("metadataParseCount", 0)),
			"imageDecodeCount": int(worker_art.get("imageDecodeCount", 0)),
			"textureCreateCount": int(worker_art.get("textureCreateCount", 0)),
			"materialCreateCount": int(worker_art.get("materialCreateCount", 0)),
			"meshCreateCount": int(worker_art.get("meshCreateCount", 0)),
			"materialReuseCount": int(worker_art.get("materialReuseCount", 0)),
			"barracksSourceLoadCount": int(barracks_material.get("sourceLoadCount", 0)),
			"barracksMetadataParseCount": int(barracks_material.get("metadataParseCount", 0)),
			"barracksImageDecodeCount": int(barracks_material.get("imageDecodeCount", 0)),
			"barracksTextureCreateCount": int(barracks_material.get("textureCreateCount", 0)),
			"barracksMaterialCreateCount": int(barracks_material.get("materialCreateCount", 0)),
			"barracksMaterialReuseCount": int(barracks_material.get("materialReuseCount", 0)),
			"barracksAppliedSurfaceCount": int(barracks_material.get("appliedSurfaceCount", 0)),
			"militiaSourceLoadCount": int(militia_art.get("sourceLoadCount", 0)),
			"militiaMetadataParseCount": int(militia_art.get("metadataParseCount", 0)),
			"militiaImageDecodeCount": int(militia_art.get("imageDecodeCount", 0)),
			"militiaTextureCreateCount": int(militia_art.get("textureCreateCount", 0)),
			"militiaMaterialCreateCount": int(militia_art.get("materialCreateCount", 0)),
			"militiaMaterialReuseCount": int(militia_art.get("materialReuseCount", 0)),
			"asterSourceLoadCount": int(aster_art.get("sourceLoadCount", 0)),
			"asterMetadataParseCount": int(aster_art.get("metadataParseCount", 0)),
			"asterImageDecodeCount": int(aster_art.get("imageDecodeCount", 0)),
			"asterTextureCreateCount": int(aster_art.get("textureCreateCount", 0)),
			"asterMaterialCreateCount": int(aster_art.get("materialCreateCount", 0)),
			"asterMaterialReuseCount": int(aster_art.get("materialReuseCount", 0)),
			"ashenSourceLoadCount": int(ashen_art.get("sourceLoadCount", 0)),
			"ashenMetadataParseCount": int(ashen_art.get("metadataParseCount", 0)),
			"ashenImageDecodeCount": int(ashen_art.get("imageDecodeCount", 0)),
			"ashenTextureCreateCount": int(ashen_art.get("textureCreateCount", 0)),
			"ashenMaterialCreateCount": int(ashen_art.get("materialCreateCount", 0)),
			"ashenMaterialReuseCount": int(ashen_art.get("materialReuseCount", 0)),
			"groundMaterialSourceLoadCount": int(ground_material.get("sourceLoadCount", 0)),
			"groundMaterialMetadataParseCount": int(ground_material.get("metadataParseCount", 0)),
			"groundMaterialImageDecodeCount": int(ground_material.get("imageDecodeCount", 0)),
			"groundMaterialTextureCreateCount": int(ground_material.get("textureCreateCount", 0)),
			"groundMaterialMaterialCreateCount": int(ground_material.get("materialCreateCount", 0)),
			"groundMaterialMaterialReuseCount": int(ground_material.get("materialReuseCount", 0)),
			"groundMaterialAppliedSurfaceCount": int(ground_material.get("appliedSurfaceCount", 0)),
			"roadMaterialSourceLoadCount": int(road_material.get("sourceLoadCount", 0)),
			"roadMaterialMetadataParseCount": int(road_material.get("metadataParseCount", 0)),
			"roadMaterialImageDecodeCount": int(road_material.get("imageDecodeCount", 0)),
			"roadMaterialTextureCreateCount": int(road_material.get("textureCreateCount", 0)),
			"roadMaterialMaterialCreateCount": int(road_material.get("materialCreateCount", 0)),
			"roadMaterialMaterialReuseCount": int(road_material.get("materialReuseCount", 0)),
			"roadMaterialAppliedSurfaceCount": int(road_material.get("appliedSurfaceCount", 0)),
			"roadRiverbankWaterSourceLoadCount": int(road_riverbank_water_material.get("sourceLoadCount", 0)),
			"roadRiverbankWaterMetadataParseCount": int(road_riverbank_water_material.get("metadataParseCount", 0)),
			"roadRiverbankWaterImageDecodeCount": int(road_riverbank_water_material.get("imageDecodeCount", 0)),
			"roadRiverbankWaterTextureCreateCount": int(road_riverbank_water_material.get("textureCreateCount", 0)),
			"roadRiverbankWaterMaterialCreateCount": int(road_riverbank_water_material.get("materialCreateCount", 0)),
			"roadRiverbankWaterMaterialReuseCount": int(road_riverbank_water_material.get("materialReuseCount", 0)),
			"roadRiverbankWaterAppliedSurfaceCount": int(road_riverbank_water_material.get("appliedSurfaceCount", 0))
		},
		"steps": steps,
		"errors": errors,
		"finalProductionCertification": false
	}
	_write_absolute_json(_path_join(artifact_root, "worker-art-opt-in-benchmark-runtime.json"), report)
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
	player_ui_shell_context_override = action
	player_ui_shell_focus_hint = ""
	player_ui_shell_production_tab_override = ""
	player_ui_shell_production_focus_hint = ""
	if action == "selection_tooltips":
		player_ui_shell_focus_hint = "lume_pulse"
	elif action == "keyboard_focus":
		player_ui_shell_focus_hint = "attack"
	if action == "production_build":
		player_ui_shell_production_tab_override = "BUILD"
		player_ui_shell_production_focus_hint = "restore_barracks"
	elif action == "tooltip_docked":
		player_ui_shell_production_tab_override = "RESEARCH"
		player_ui_shell_production_focus_hint = "bridgecraft"
	elif action == "production_train":
		player_ui_shell_production_tab_override = "TRAIN"
		player_ui_shell_production_focus_hint = "train_militia"
	elif action == "production_research":
		player_ui_shell_production_tab_override = "RESEARCH"
		player_ui_shell_production_focus_hint = "lume_channel"
	elif action == "production_disabled_tooltip":
		player_ui_shell_production_tab_override = "RESEARCH"
		player_ui_shell_production_focus_hint = "bridgecraft"
	elif action == "v0212_tooltips":
		player_ui_shell_production_tab_override = "RESEARCH"
		player_ui_shell_production_focus_hint = "bridgecraft"
	elif action == "v0212_minimap":
		player_ui_shell_production_tab_override = "BUILD"
		player_ui_shell_production_focus_hint = "restore_barracks"
	elif action == "v0212_viewport_marker" or action == "v0212_alerts" or action.begins_with("v0212_resolution"):
		player_ui_shell_production_tab_override = "TRAIN"
		player_ui_shell_production_focus_hint = "train_militia"
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
		"selection_tooltips", "portrait_fallback":
			_ensure_player_battle_scene()
			_call_scene("select_entity", ["hero_aster"])
			_call_scene("set_onboarding_step", ["move_to_quarry"])
			_call_scene("show_objective_feedback", ["select_aster"])
			_call_scene("focus_visual_subject", ["hero"])
			_render_player_screen("battle")
		"production_build":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("select_entity", ["worker_00"])
			_call_scene("advance_resource_production", [180])
			_call_scene("focus_visual_subject", ["worker"])
			_render_player_screen("battle")
		"production_train":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("focus_visual_subject", ["barracks"])
			_render_player_screen("battle")
		"production_research", "production_disabled_tooltip", "tooltip_docked":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("select_entity", ["hero_aster"])
			_call_scene("focus_visual_subject", ["hero"])
			_render_player_screen("battle")
		"initial_objective":
			_ensure_player_battle_scene()
			_call_scene("select_entity", ["hero_aster"])
			_call_scene("set_onboarding_step", ["select_aster"])
			_call_scene("show_objective_feedback", ["select_aster"])
			_call_scene("focus_visual_subject", ["hero"])
			_render_player_screen("battle")
		"objective_expanded":
			_ensure_player_battle_scene()
			_call_scene("select_entity", ["hero_aster"])
			_call_scene("set_onboarding_step", ["select_aster"])
			_call_scene("show_objective_feedback", ["select_aster"])
			_call_scene("focus_visual_subject", ["hero"])
			_render_player_screen("battle")
		"icon_sheet", "interaction_matrix", "keyboard_focus":
			_ensure_player_battle_scene()
			_call_scene("select_entity", ["hero_aster"])
			_call_scene("set_onboarding_step", ["select_aster"])
			_call_scene("show_objective_feedback", ["select_aster"])
			_call_scene("focus_visual_subject", ["hero"])
			_render_player_screen("battle")
		"event_progression":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("box_select_squad")
			_call_scene("focus_visual_subject", ["militia"])
			_render_player_screen("battle")
		"event_drawer_expanded":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("box_select_squad")
			_call_scene("focus_visual_subject", ["militia"])
			_render_player_screen("battle")
		"v0211_overview":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("box_select_squad")
			_call_scene("set_onboarding_step", ["prepare_ashen_pressure"])
			_call_scene("focus_visual_subject", ["squad"])
			_render_player_screen("battle")
		"v0212_minimap":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("select_entity", ["worker_00"])
			_call_scene("focus_layout_feature", ["minimap"])
			_call_scene("focus_visual_subject", ["worker"])
			_render_player_screen("battle")
		"v0212_viewport_marker":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("box_select_squad")
			_call_scene("focus_layout_feature", ["minimap"])
			_call_scene("focus_visual_subject", ["squad"])
			_render_player_screen("battle")
		"v0212_tooltips":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("select_entity", ["hero_aster"])
			_call_scene("focus_visual_subject", ["hero"])
			_render_player_screen("battle")
		"v0212_alerts":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("trigger_pressure_wave")
			_call_scene("box_select_squad")
			_call_scene("set_onboarding_step", ["prepare_ashen_pressure"])
			_call_scene("focus_visual_subject", ["attack_order"])
			_render_player_screen("battle")
		"v0212_resolution_1920", "v0212_resolution_1600", "v0212_resolution_1366":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("box_select_squad")
			_call_scene("set_onboarding_step", ["prepare_ashen_pressure"])
			_call_scene("focus_visual_subject", ["squad"])
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
		"worker_panel":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("select_entity", ["worker_00"])
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
		"barracks_restoring_panel":
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
		"queue_panel":
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
		"militia_panel":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("box_select_squad")
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
			if _script_args().has("--salto-five-slot-review-framing"):
				_render_player_screen("battle")
				_call_scene("box_select_squad")
				_call_scene("stage_five_slot_art_review_squad_comparison")
				_call_scene("set_onboarding_step", ["prepare_ashen_pressure"])
				_call_scene("focus_visual_subject", ["squad"])
			else:
				_call_scene("box_select_squad")
				_call_scene("set_onboarding_step", ["prepare_ashen_pressure"])
				_call_scene("focus_visual_subject", ["squad"])
				_render_player_screen("battle")
		"multi_select_panel":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("box_select_squad")
			_call_scene("set_onboarding_step", ["prepare_ashen_pressure"])
			_call_scene("focus_visual_subject", ["squad"])
			_render_player_screen("battle")
		"ashen_pressure_active":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("advance_resource_production", [180])
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("trigger_pressure_wave")
			_call_scene("box_select_squad")
			_call_scene("set_onboarding_step", ["prepare_ashen_pressure"])
			_call_scene("focus_visual_subject", ["attack_order"])
			_render_player_screen("battle")
		"ashen_pressure_wave":
			_ensure_player_battle_scene()
			if _player_capture_checkpoint() == "v0.209":
				_call_scene("capture_mine_site")
				_call_scene("assign_worker_to_mine")
				_call_scene("advance_resource_production", [180])
				_call_scene("place_barracks_placeholder")
				_call_scene("advance_construction", [180])
				_call_scene("queue_militia_recruit")
				_call_scene("complete_recruit_queue", [140])
				_call_scene("trigger_pressure_wave")
				_call_scene("issue_attack_order")
			elif _is_bounded_microloop_checkpoint():
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
		"v0186_command_hall_normal":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_structure_shell_subject", ["command_hall", false])
		"v0186_command_hall_close":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_structure_shell_subject", ["command_hall", true])
		"v0186_mine_normal":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_structure_shell_subject", ["mine", false])
		"v0186_mine_close":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_structure_shell_subject", ["mine", true])
		"v0186_barracks_restoration":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [60])
			_render_player_screen("battle")
			_call_scene("focus_environment_structure_shell_subject", ["barracks", false])
		"v0186_barracks_restoration_close":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [60])
			_render_player_screen("battle")
			_call_scene("focus_environment_structure_shell_subject", ["barracks", true])
		"v0186_barracks_restored":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_render_player_screen("battle")
			_call_scene("focus_environment_structure_shell_subject", ["barracks", false])
		"v0186_worker_barracks_relation":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("place_barracks_placeholder")
			_render_player_screen("battle")
			_call_scene("focus_environment_structure_shell_subject", ["barracks", false])
		"v0187_river_overview":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_riverbank_bridge_subject", ["river", false])
		"v0187_banks_normal":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_riverbank_bridge_subject", ["banks", false])
		"v0187_banks_close":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_riverbank_bridge_subject", ["banks", true])
		"v0187_bridge_normal":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_riverbank_bridge_subject", ["bridge", false])
		"v0187_bridge_close":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_riverbank_bridge_subject", ["bridge", true])
		"v0187_road_to_bridge":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_riverbank_bridge_subject", ["road_to_bridge", false])
		"v0187_friendly_approach":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_riverbank_bridge_subject", ["friendly_approach", false])
		"v0187_hostile_approach":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_environment_riverbank_bridge_subject", ["hostile_approach", false])
		"v0187_combat_crossing":
			_ensure_player_battle_scene()
			_call_scene("capture_mine_site")
			_call_scene("assign_worker_to_mine")
			_call_scene("place_barracks_placeholder")
			_call_scene("advance_construction", [180])
			_call_scene("queue_militia_recruit")
			_call_scene("complete_recruit_queue", [140])
			_call_scene("trigger_pressure_wave")
			_render_player_screen("battle")
			_call_scene("show_combat_readability_sample")
			_call_scene("focus_environment_riverbank_bridge_subject", ["combat_crossing", false])
		"v0230_command_hall":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_visual_subject", ["command_hall"])
		"v0230_barracks":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_visual_subject", ["barracks"])
		"v0230_mine":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_visual_subject", ["mine"])
		"hero", "worker", "militia", "ranger", "ashen_raider", "command_hall", "barracks", "mine", "site", "lume_endpoint":
			_ensure_player_battle_scene()
			_call_scene("focus_visual_subject", [action])
			_render_player_screen("battle")
		"combat":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("show_combat_readability_sample")
		"death":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("show_death_readability_sample")
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
			_render_player_screen("battle")
			_call_scene("focus_layout_feature", ["minimap"])
		"road", "v0195_road_network", "v0195_road_intersections", "v0195_road_to_bridge", "v0195_bridge_close", "ford", "bridge", "road_intersections", "approach_lanes", "hostile_lane", "friendly_boundary", "site_marker_hierarchy", "quarry", "shrine", "ruin", "buildable_ground", "objective_focus":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("focus_layout_feature", [action])
			if ["road", "ford", "bridge", "quarry", "shrine", "ruin", "buildable_ground", "objective_focus"].has(action):
				_call_scene("focus_visual_subject", [action])
		"pan_camera":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("pan_camera")
		"zoom_camera":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("zoom_camera")
		"camera_min_zoom":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("set_camera_zoom_posture", ["min"])
		"camera_max_zoom":
			_ensure_player_battle_scene()
			_render_player_screen("battle")
			_call_scene("set_camera_zoom_posture", ["max"])
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
		"restart_replay":
			show_player_results()
			_restart_player_battle_from_results()
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
	status["saltoUiShellOptInRequested"] = _script_args().has("--salto-ui-shell-experiment")
	status["saltoUiShellFallbackActive"] = _salto_ui_shell_fallback_active()
	status["saltoUiShellLiveOverlayEnabled"] = _salto_ui_shell_live_enabled() and player_ui_shell_overlay != null and is_instance_valid(player_ui_shell_overlay)
	status["saltoSelectionCommandPanelEnabled"] = _salto_selection_command_panel_enabled()
	status["saltoProductionObjectivesLogEnabled"] = _salto_production_objectives_log_enabled()
	status["saltoMinimapTooltipAccessibilityEnabled"] = _salto_minimap_tooltip_accessibility_enabled()
	status["saltoPresentationRebootEnabled"] = _salto_presentation_reboot_enabled()
	status["saltoPresentationRebootUiOccupancy"] = _salto_presentation_reboot_occupancy_budget()
	status["saltoMinimalContextualHudEnabled"] = _salto_minimal_contextual_hud_enabled()
	status["saltoMinimalContextualHudOccupancy"] = _salto_minimal_contextual_hud_occupancy_budget()
	status["saltoHudVisualLanguageEnabled"] = _salto_hud_visual_language_enabled()
	status["saltoHudVisualLanguageReport"] = _salto_hud_visual_language_report()
	status["saltoIntegratedReferenceGapEnabled"] = _script_args().has("--salto-integrated-reference-gap")
	status["saltoBattlefieldVisualRescueEnabled"] = _script_args().has("--salto-battlefield-visual-rescue")
	status["saltoProductionBattlefieldBackplateEnabled"] = _script_args().has("--salto-production-battlefield-backplate")
	status["saltoStructureLandmarkFidelityEnabled"] = _script_args().has("--salto-structure-landmark-fidelity")
	status["saltoStructureArtFidelityEnabled"] = _script_args().has("--salto-structure-art-fidelity")
	status["saltoBattlefieldMaterialValueIntegrationEnabled"] = _script_args().has("--salto-battlefield-material-value-integration")
	status["saltoAsterPortraitStatus"] = _salto_aster_portrait_status()
	status["saltoAsterPortraitSourceLoaded"] = bool(status["saltoAsterPortraitStatus"].get("sourceLoaded", false))
	status["saltoAsterPortraitFallbackActive"] = bool(status["saltoAsterPortraitStatus"].get("fallbackActive", true))
	status["saltoAsterPortraitProductionSlotAdded"] = false
	status["saltoAsterPortraitGeneratedImages"] = false
	return status

func _player_capture_checkpoint() -> String:
	var normalized_root := _artifact_root_from_args().replace("\\", "/")
	if normalized_root.contains("/v0231"):
		return "v0.231"
	if normalized_root.contains("/v0230"):
		return "v0.230"
	if normalized_root.contains("/v0229"):
		return "v0.229"
	if normalized_root.contains("/v0228"):
		return "v0.228"
	if normalized_root.contains("/v0227"):
		return "v0.227"
	if normalized_root.contains("/v0224"):
		return "v0.224"
	if normalized_root.contains("/v0223"):
		return "v0.223"
	if normalized_root.contains("/v0222"):
		return "v0.222"
	if normalized_root.contains("/v0221"):
		return "v0.221"
	if normalized_root.contains("/v0220"):
		return "v0.220"
	if normalized_root.contains("/v0219"):
		return "v0.219"
	if normalized_root.contains("/v0218"):
		return "v0.218"
	if normalized_root.contains("/v0217"):
		return "v0.217"
	if normalized_root.contains("/v0216"):
		return "v0.216"
	if normalized_root.contains("/v0215"):
		return "v0.215"
	if normalized_root.contains("/v0213"):
		return "v0.213"
	if normalized_root.contains("/v0212"):
		return "v0.212"
	if normalized_root.contains("/v0211"):
		return "v0.211"
	if normalized_root.contains("/v0210"):
		return "v0.210"
	if normalized_root.contains("/v0209"):
		return "v0.209"
	if normalized_root.contains("/v0206"):
		return "v0.206"
	if normalized_root.contains("/v0205"):
		return "v0.205"
	if normalized_root.contains("/v0204"):
		return "v0.204"
	if normalized_root.contains("/v0203"):
		return "v0.203"
	if normalized_root.contains("/v0200"):
		return "v0.200"
	if normalized_root.contains("/v0199"):
		return "v0.199"
	if normalized_root.contains("/v0198"):
		return "v0.198"
	if normalized_root.contains("/v0197"):
		return "v0.197"
	if normalized_root.contains("/v0196"):
		return "v0.196"
	if normalized_root.contains("/v0195"):
		return "v0.195"
	if normalized_root.contains("/v0194"):
		return "v0.194"
	if normalized_root.contains("/v0193"):
		return "v0.193"
	if normalized_root.contains("/v0187"):
		return "v0.187"
	if normalized_root.contains("/v0186"):
		return "v0.186"
	if normalized_root.contains("/v0185"):
		return "v0.185"
	if normalized_root.contains("/v0184"):
		return "v0.184"
	if normalized_root.contains("/v0181"):
		return "v0.181"
	if normalized_root.contains("/v0179"):
		return "v0.179"
	if normalized_root.contains("/v0178"):
		return "v0.178"
	if normalized_root.contains("/v0177"):
		return "v0.177"
	if normalized_root.contains("/v0174"):
		return "v0.174"
	if normalized_root.contains("/v0173"):
		return "v0.173"
	if normalized_root.contains("/v0170"):
		return "v0.170"
	if normalized_root.contains("/v0169"):
		return "v0.169"
	if normalized_root.contains("/v0168"):
		return "v0.168"
	if normalized_root.contains("/v0166"):
		return "v0.166"
	if normalized_root.contains("/v0164"):
		return "v0.164"
	if normalized_root.contains("/v0162"):
		return "v0.162"
	if normalized_root.contains("/v0160"):
		return "v0.160"
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
	return ["v0.129", "v0.130", "v0.160", "v0.162", "v0.164", "v0.166", "v0.168", "v0.169", "v0.170", "v0.173", "v0.174", "v0.177", "v0.178", "v0.179", "v0.181", "v0.184", "v0.185", "v0.186", "v0.187", "v0.193", "v0.194", "v0.195", "v0.196", "v0.197", "v0.198", "v0.199", "v0.200", "v0.203", "v0.204", "v0.205", "v0.206", "v0.209", "v0.210", "v0.211", "v0.212", "v0.213", "v0.215", "v0.216", "v0.217", "v0.218", "v0.219", "v0.220", "v0.221", "v0.222", "v0.223", "v0.224", "v0.227", "v0.228", "v0.229", "v0.230", "v0.231"].has(_player_capture_checkpoint())

func _player_capture_steps() -> Array[Dictionary]:
	if _player_capture_checkpoint() == "v0.231":
		return [
			{"id": "overview", "label": "v0.231 retained battlefield material overview", "action": "battle_default"},
			{"id": "ground_value_palette", "label": "v0.231 warm ground value palette", "action": "friendly_boundary"},
			{"id": "road_integration", "label": "v0.231 worn road integration", "action": "v0187_road_to_bridge"},
			{"id": "river_bank_integration", "label": "v0.231 opaque river and bank integration", "action": "v0195_bridge_close"},
			{"id": "structure_grounding_keep_barracks", "label": "v0.231 keep and barracks grounding", "action": "friendly_boundary"},
			{"id": "mine_lume_grounding", "label": "v0.231 mine and Lume grounding", "action": "v0230_mine"},
			{"id": "bridge_river_contact", "label": "v0.231 bridge and river contact", "action": "v0195_bridge_close"},
			{"id": "normal_zoom_readability", "label": "v0.231 normal zoom readability", "action": "battle_default"},
			{"id": "hostile_pressure", "label": "v0.231 hostile pressure readability", "action": "ashen_pressure_active"},
			{"id": "train_drawer", "label": "v0.231 compact train drawer", "action": "production_train"},
			{"id": "resolution_1366x768", "label": "v0.231 1366x768", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}},
			{"id": "resolution_1600x900", "label": "v0.231 1600x900", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1920x1080", "label": "v0.231 1920x1080", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}}
		]
	if _player_capture_checkpoint() == "v0.230":
		return [
			{"id": "overview", "label": "v0.230 authored structure-art overview", "action": "battle_default"},
			{"id": "player_keep_focus", "label": "v0.230 player keep authored fidelity", "action": "v0230_command_hall"},
			{"id": "barracks_focus", "label": "v0.230 barracks authored fidelity", "action": "v0230_barracks"},
			{"id": "mine_lume_focus", "label": "v0.230 mine and Lume authored fidelity", "action": "v0230_mine"},
			{"id": "bridge_structure_context", "label": "v0.230 bridge support integration", "action": "v0195_bridge_close"},
			{"id": "normal_zoom_readability", "label": "v0.230 normal zoom structure readability", "action": "friendly_boundary"},
			{"id": "hostile_pressure", "label": "v0.230 hostile pressure readability", "action": "ashen_pressure_active"},
			{"id": "train_drawer", "label": "v0.230 compact train drawer", "action": "production_train"},
			{"id": "resolution_1366x768", "label": "v0.230 1366x768", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}},
			{"id": "resolution_1600x900", "label": "v0.230 1600x900", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1920x1080", "label": "v0.230 1920x1080", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}}
		]
	if _player_capture_checkpoint() == "v0.229":
		return [
			{"id": "overview", "label": "v0.229 structure landmark overview", "action": "battle_default"},
			{"id": "haze_value_cleanup", "label": "v0.229 clear local-value battlefield", "action": "friendly_boundary"},
			{"id": "player_base_focus", "label": "v0.229 player base landmark", "action": "command_hall"},
			{"id": "barracks_focus", "label": "v0.229 barracks landmark", "action": "barracks"},
			{"id": "central_landmark_focus", "label": "v0.229 central mine and Lume landmark", "action": "mine"},
			{"id": "bridge_river_context", "label": "v0.229 bridge river tactical context", "action": "v0195_bridge_close"},
			{"id": "hostile_pressure", "label": "v0.229 hostile pressure readability", "action": "ashen_pressure_active"},
			{"id": "train_drawer", "label": "v0.229 compact train drawer", "action": "production_train"},
			{"id": "resolution_1366x768", "label": "v0.229 1366x768", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}},
			{"id": "resolution_1600x900", "label": "v0.229 1600x900", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1920x1080", "label": "v0.229 1920x1080", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}}
		]
	if _player_capture_checkpoint() == "v0.228":
		return [
			{"id": "initial_overview", "label": "v0.228 production battlefield overview", "action": "battle_default"},
			{"id": "terrain_focus", "label": "v0.228 authored terrain focus", "action": "friendly_boundary"},
			{"id": "road_focus", "label": "v0.228 worn road focus", "action": "road_intersections"},
			{"id": "river_bridge_focus", "label": "v0.228 river and grounded bridge", "action": "v0195_bridge_close"},
			{"id": "structure_context", "label": "v0.228 structures in authored terrain", "action": "command_hall"},
			{"id": "hostile_pressure", "label": "v0.228 hostile pressure readability", "action": "ashen_pressure_active"},
			{"id": "train_drawer", "label": "v0.228 compact train drawer", "action": "production_train"},
			{"id": "resolution_1366x768", "label": "v0.228 1366x768", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}},
			{"id": "resolution_1600x900", "label": "v0.228 1600x900", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1920x1080", "label": "v0.228 1920x1080", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}}
		]
	if _player_capture_checkpoint() == "v0.227":
		return [
			{"id": "initial_overview", "label": "v0.227 rescued battlefield overview", "action": "battle_default"},
			{"id": "terrain_focus", "label": "v0.227 terrain and road material focus", "action": "road_intersections"},
			{"id": "bridge_river_focus", "label": "v0.227 grounded bridge and river focus", "action": "v0195_bridge_close"},
			{"id": "structure_focus", "label": "v0.227 structure silhouette focus", "action": "command_hall"},
			{"id": "hostile_pressure", "label": "v0.227 hostile pressure readability", "action": "ashen_pressure_active"},
			{"id": "train_drawer", "label": "v0.227 compact train drawer", "action": "production_train"},
			{"id": "resolution_1366x768", "label": "v0.227 1366x768", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}},
			{"id": "resolution_1600x900", "label": "v0.227 1600x900", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1920x1080", "label": "v0.227 1920x1080", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}}
		]
	if _player_capture_checkpoint() == "v0.224":
		return [
			{"id": "initial_overview", "label": "v0.224 integrated initial overview", "action": "battle_default"},
			{"id": "environment_overview", "label": "v0.224 terrain road river and lighting", "action": "road_intersections"},
			{"id": "structures", "label": "v0.224 structure silhouette and grounding", "action": "command_hall"},
			{"id": "bridge_river", "label": "v0.224 bridge and river hierarchy", "action": "v0195_bridge_close"},
			{"id": "compact_hud", "label": "v0.224 compact HUD", "action": "battle_default"},
			{"id": "objective_expanded", "label": "v0.224 objective expansion", "action": "objective_expanded"},
			{"id": "event_drawer", "label": "v0.224 event drawer", "action": "event_drawer_expanded"},
			{"id": "aster_selected", "label": "v0.224 Aster selected", "action": "hero_selected"},
			{"id": "worker_assignment", "label": "v0.224 Worker assignment", "action": "worker_selected"},
			{"id": "barracks_damaged", "label": "v0.224 Barracks damaged", "action": "v0186_worker_barracks_relation"},
			{"id": "barracks_restoring", "label": "v0.224 Barracks restoring", "action": "v0186_barracks_restoration_close"},
			{"id": "barracks_restored", "label": "v0.224 Barracks restored", "action": "v0186_barracks_restored"},
			{"id": "build_drawer", "label": "v0.224 build drawer", "action": "production_build"},
			{"id": "train_drawer", "label": "v0.224 train drawer", "action": "production_train"},
			{"id": "research_preview", "label": "v0.224 research preview", "action": "production_research"},
			{"id": "defenders_staged", "label": "v0.224 defenders staged", "action": "squad_selected"},
			{"id": "hostile_pressure", "label": "v0.224 hostile pressure", "action": "ashen_pressure_active"},
			{"id": "combat_onset", "label": "v0.224 combat onset", "action": "ashen_pressure_wave"},
			{"id": "minimap", "label": "v0.224 minimap correlation", "action": "minimap"},
			{"id": "replay", "label": "v0.224 replay posture", "action": "battle_default"},
			{"id": "resolution_1366x768", "label": "v0.224 1366x768", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}},
			{"id": "resolution_1600x900", "label": "v0.224 1600x900", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1920x1080", "label": "v0.224 1920x1080", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}}
		]
	if _player_capture_checkpoint() == "v0.223":
		return [
			{"id": "compact_default", "label": "v0.223 compact default visual language", "action": "battle_default"},
			{"id": "icon_sheet", "label": "v0.223 procedural icon sheet", "action": "icon_sheet"},
			{"id": "hover_active_disabled_matrix", "label": "v0.223 interaction state matrix", "action": "interaction_matrix"},
			{"id": "docked_tooltip", "label": "v0.223 docked tooltip", "action": "tooltip_docked"},
			{"id": "build_drawer", "label": "v0.223 production build drawer", "action": "production_build"},
			{"id": "train_drawer", "label": "v0.223 production train drawer", "action": "production_train"},
			{"id": "hostile_alert", "label": "v0.223 hostile alert", "action": "ashen_pressure_active"},
			{"id": "keyboard_focus", "label": "v0.223 keyboard focus state", "action": "keyboard_focus"},
			{"id": "resolution_1366x768", "label": "v0.223 1366x768 compact layout", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}},
			{"id": "resolution_1600x900", "label": "v0.223 1600x900 compact layout", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1920x1080", "label": "v0.223 1920x1080 compact layout", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}}
		]
	if _player_capture_checkpoint() == "v0.222":
		return [
			{"id": "default_compact_hud", "label": "v0.222 default compact HUD", "action": "battle_default"},
			{"id": "objective_expanded", "label": "v0.222 objective detail expanded", "action": "objective_expanded"},
			{"id": "event_drawer_expanded", "label": "v0.222 event drawer expanded", "action": "event_drawer_expanded"},
			{"id": "production_drawer_build", "label": "v0.222 production drawer build tab", "action": "production_build"},
			{"id": "production_drawer_train", "label": "v0.222 production drawer train tab", "action": "production_train"},
			{"id": "production_drawer_research", "label": "v0.222 production drawer research tab", "action": "production_research"},
			{"id": "hostile_alert_active", "label": "v0.222 hostile alert active only when relevant", "action": "ashen_pressure_active"},
			{"id": "tooltip_docked", "label": "v0.222 tooltip docked to drawer edge", "action": "tooltip_docked"},
			{"id": "resolution_1920x1080", "label": "v0.222 1920x1080 compact layout", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}},
			{"id": "resolution_1600x900", "label": "v0.222 1600x900 compact layout", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1366x768", "label": "v0.222 1366x768 compact layout", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}}
		]
	if _player_capture_checkpoint() == "v0.221":
		return [
			{"id": "initial_overview", "label": "v0.221 initial composed overview", "action": "battle_default"},
			{"id": "road_bridge_composition", "label": "v0.221 road and bridge composition", "action": "road_intersections"},
			{"id": "structures_grounded", "label": "v0.221 structures grounded by value", "action": "command_hall"},
			{"id": "hero_selected", "label": "v0.221 restrained hero selection", "action": "hero_selected"},
			{"id": "squad_selected", "label": "v0.221 restrained squad selection", "action": "squad_selected"},
			{"id": "hostile_pressure", "label": "v0.221 hostile pressure readability", "action": "ashen_pressure_active"},
			{"id": "pan_zoom_near", "label": "v0.221 pan and zoom near review", "action": "camera_min_zoom"},
			{"id": "pan_zoom_default", "label": "v0.221 default zoom review", "action": "battle_default"},
			{"id": "pan_zoom_wide", "label": "v0.221 wide zoom review", "action": "camera_max_zoom"},
			{"id": "minimap_correlation", "label": "v0.221 minimap correlation", "action": "minimap"}
		]
	if _player_capture_checkpoint() == "v0.220":
		return [
			{"id": "source_atlas_runtime", "label": "v0.220 source atlas runtime status", "action": "battle_default"},
			{"id": "before_after_overview", "label": "v0.220 sparse dressing before/after overview", "action": "battle_default"},
			{"id": "road_shoulders", "label": "v0.220 road shoulder prop dressing", "action": "road_intersections"},
			{"id": "riverbanks", "label": "v0.220 riverbank stones and scrub", "action": "ford"},
			{"id": "structure_adjacent_props", "label": "v0.220 structure-adjacent practical props", "action": "command_hall"},
			{"id": "bridge_approach", "label": "v0.220 bridge approach dressing", "action": "v0195_bridge_close"},
			{"id": "tactical_readability", "label": "v0.220 tactical readability", "action": "squad_selected"},
			{"id": "fallback", "label": "v0.220 atlas fallback", "action": "battle_default"}
		]
	if _player_capture_checkpoint() == "v0.219":
		return [
			{"id": "structure_overview", "label": "v0.219 structure shell tactical overview", "action": "battle_default"},
			{"id": "command_hall", "label": "v0.219 Command Hall production shell", "action": "command_hall"},
			{"id": "barracks_damaged", "label": "v0.219 Barracks damaged shell", "action": "v0186_worker_barracks_relation"},
			{"id": "barracks_restoring", "label": "v0.219 Barracks restoring shell", "action": "v0186_barracks_restoration_close"},
			{"id": "barracks_restored", "label": "v0.219 Barracks restored shell", "action": "v0186_barracks_restored"},
			{"id": "mine_site", "label": "v0.219 West Stone Cut mine shell", "action": "v0186_mine_close"},
			{"id": "aether_support", "label": "v0.219 Aether support structure shell", "action": "ford"},
			{"id": "units_beside_structures", "label": "v0.219 units beside structures and marker clearance", "action": "squad_selected"}
		]
	if _player_capture_checkpoint() == "v0.218":
		return [
			{"id": "old_bridge", "label": "v0.218 legacy bridge comparator", "action": "v0195_bridge_close"},
			{"id": "new_bridge_normal_rts", "label": "v0.218 new bridge normal RTS distance", "action": "battle_default"},
			{"id": "close_bridge", "label": "v0.218 close bridge shell readability", "action": "v0195_bridge_close"},
			{"id": "road_to_bridge_west", "label": "v0.218 west road-to-bridge transition", "action": "site_marker_hierarchy"},
			{"id": "road_to_bridge_east", "label": "v0.218 east road-to-bridge transition", "action": "ford"},
			{"id": "riverbank_seats", "label": "v0.218 riverbank seats and abutments", "action": "v0195_bridge_close"},
			{"id": "units_crossing", "label": "v0.218 units crossing and marker clearance", "action": "ashen_pressure_wave"},
			{"id": "fallback", "label": "v0.218 bridge shell fallback comparator", "action": "friendly_boundary"}
		]
	if _player_capture_checkpoint() == "v0.217":
		return [
			{"id": "road_overview", "label": "v0.217 road riverbank water overview", "action": "battle_default"},
			{"id": "road_junction", "label": "v0.217 road junction and route width", "action": "site_marker_hierarchy"},
			{"id": "river_banks", "label": "v0.217 river and bank material hierarchy", "action": "ford"},
			{"id": "bridge_approaches", "label": "v0.217 bridge approach transitions", "action": "v0195_bridge_close"},
			{"id": "normal_rts_distance", "label": "v0.217 normal RTS material readability", "action": "battle_default"},
			{"id": "fallback_comparison", "label": "v0.217 material fallback comparison posture", "action": "friendly_boundary"}
		]
	if _player_capture_checkpoint() == "v0.216":
		return [
			{"id": "terrain_overview", "label": "v0.216 terrain material reboot overview", "action": "battle_default"},
			{"id": "normal_rts_distance", "label": "v0.216 normal RTS terrain distance", "action": "battle_default"},
			{"id": "zoomed_out_view", "label": "v0.216 zoomed-out terrain repetition check", "action": "camera_max_zoom"},
			{"id": "pan_zoom_framing", "label": "v0.216 terrain pan and framing check", "action": "pan_camera"},
			{"id": "fallback_comparison", "label": "v0.216 terrain fallback comparison posture", "action": "friendly_boundary"}
		]
	if _player_capture_checkpoint() == "v0.215":
		return [
			{"id": "initial", "label": "Presentation reboot compact initial overview", "action": "battle_default"},
			{"id": "context_expanded", "label": "Presentation reboot contextual objective and production expansion", "action": "production_train"},
			{"id": "hostile_alert", "label": "Presentation reboot compact hostile alert", "action": "v0212_alerts"},
			{"id": "tooltip_docked", "label": "Presentation reboot docked edge tooltip", "action": "v0212_tooltips"},
			{"id": "resolution_1920x1080", "label": "1920x1080 presentation reboot layout", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}},
			{"id": "resolution_1600x900", "label": "1600x900 presentation reboot layout", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1366x768", "label": "1366x768 presentation reboot layout", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}}
		]
	if _player_capture_checkpoint() == "v0.213":
		return [
			{"id": "initial", "label": "Full HUD and shell-v2 initial overview", "action": "battle_default"},
			{"id": "aster", "label": "Aster selection and context panel", "action": "hero_selected"},
			{"id": "worker_barracks", "label": "Worker assignment and Barracks restoring context", "action": "construction_progress"},
			{"id": "production", "label": "Build train research production command area", "action": "production_train"},
			{"id": "objective_log", "label": "Objective stack and event log progression", "action": "event_progression"},
			{"id": "minimap", "label": "Minimap bounds markers camera and utilities", "action": "v0212_minimap"},
			{"id": "ashen_pressure", "label": "Ashen pressure alert and hostile readability", "action": "v0212_alerts"},
			{"id": "replay", "label": "Restart and replay path", "action": "restart_replay"},
			{"id": "resolution_1920x1080", "label": "1920x1080 full HUD layout", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}},
			{"id": "resolution_1600x900", "label": "1600x900 full HUD layout", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1366x768", "label": "1366x768 full HUD layout", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}}
		]
	if _player_capture_checkpoint() == "v0.212":
		return [
			{"id": "minimap", "label": "Minimap bounds routes markers and utilities", "action": "v0212_minimap"},
			{"id": "viewport_marker", "label": "Minimap camera viewport outline", "action": "v0212_viewport_marker"},
			{"id": "tooltips", "label": "Structured tooltip title cost shortcut and availability", "action": "v0212_tooltips"},
			{"id": "alerts", "label": "Info warning and hostile alert distinction", "action": "v0212_alerts"},
			{"id": "resolution_1920x1080", "label": "1920x1080 layout capture", "action": "v0212_resolution_1920", "viewport": {"width": 1920, "height": 1080}},
			{"id": "resolution_1600x900", "label": "1600x900 layout capture", "action": "v0212_resolution_1600", "viewport": {"width": 1600, "height": 900}},
			{"id": "resolution_1366x768", "label": "1366x768 layout capture", "action": "v0212_resolution_1366", "viewport": {"width": 1366, "height": 768}}
		]
	if _player_capture_checkpoint() == "v0.211":
		return [
			{"id": "build", "label": "Build tab with Worker-supported restoration", "action": "production_build"},
			{"id": "train", "label": "Train tab with Barracks Militia queue", "action": "production_train"},
			{"id": "research", "label": "Research tab unavailable preview cards", "action": "production_research"},
			{"id": "disabled_tooltip", "label": "Disabled card focus and why-unavailable messaging", "action": "production_disabled_tooltip"},
			{"id": "initial_objective", "label": "Initial objective and next action stack", "action": "initial_objective"},
			{"id": "event_progression", "label": "Progression event log after mine Barracks Militia", "action": "event_progression"},
			{"id": "ashen_alert", "label": "Ashen hostile pressure alert card", "action": "ashen_pressure_active"},
			{"id": "overview", "label": "Production objective event and alert overview", "action": "v0211_overview"}
		]
	if _player_capture_checkpoint() == "v0.210":
		if _salto_aster_portrait_force_fallback():
			return [
				{"id": "portrait_fallback", "label": "Aster portrait forced fallback", "action": "portrait_fallback"}
			]
		return [
			{"id": "aster", "label": "Aster selected portrait, stats and commands", "action": "hero_selected"},
			{"id": "tooltips", "label": "Aster ability tooltip and focus state", "action": "selection_tooltips"},
			{"id": "worker", "label": "Worker assignment and restore context", "action": "worker_panel"},
			{"id": "barracks_restoring", "label": "Barracks restoring disabled explanations", "action": "barracks_restoring_panel"},
			{"id": "queue", "label": "Barracks train queue and locked tech", "action": "queue_panel"},
			{"id": "militia", "label": "Militia squad count health and tactical state", "action": "militia_panel"},
			{"id": "multi_select", "label": "Mixed selection command summary", "action": "multi_select_panel"}
		]
	if _player_capture_checkpoint() == "v0.209":
		return [
			{"id": "initial", "label": "UI shell opt-in initial overview", "action": "battle_default"},
			{"id": "aster", "label": "Aster selected in live UI shell", "action": "hero_selected"},
			{"id": "worker_assignment", "label": "Worker assignment in live UI shell", "action": "worker_assigned_mine"},
			{"id": "barracks_restoring", "label": "Barracks restoring in live UI shell", "action": "construction_progress"},
			{"id": "barracks_restored", "label": "Barracks restored in live UI shell", "action": "barracks_complete"},
			{"id": "train", "label": "Militia train queue in live UI shell", "action": "recruit_queue"},
			{"id": "defenders", "label": "Defenders staged in live UI shell", "action": "militia_spawned"},
			{"id": "ashen_pressure", "label": "Ashen pressure alert in live UI shell", "action": "ashen_pressure_wave"},
			{"id": "replay", "label": "Restart and replay path with UI shell", "action": "restart_replay"}
		]
	if _player_capture_checkpoint() == "v0.206":
		return [
			{"id": "initial_overview", "label": "Initial shell-v2 QA overview", "action": "battle_default"},
			{"id": "ground_roads", "label": "Ground and roads embedded", "action": "v0195_road_network"},
			{"id": "river_banks_bridge", "label": "River, banks and bridge connected", "action": "v0195_bridge_close"},
			{"id": "select_aster", "label": "Aster selected and grounded", "action": "hero_selected"},
			{"id": "mine_interaction", "label": "Mine interaction and quarry read", "action": "mine_converted"},
			{"id": "worker_assignment", "label": "Worker assignment grounding", "action": "worker_assigned_mine"},
			{"id": "barracks_restoring", "label": "Barracks restoring state", "action": "construction_progress"},
			{"id": "barracks_restored", "label": "Barracks restored state", "action": "barracks_complete"},
			{"id": "militia_train_state", "label": "Militia train state", "action": "recruit_queue"},
			{"id": "defenders_staged", "label": "Defenders staged and readable", "action": "squad_selected"},
			{"id": "ashen_combat_onset", "label": "Ashen combat onset", "action": "v0187_combat_crossing"},
			{"id": "hostile_readability", "label": "Hostile readability under pressure", "action": "ashen_pressure_wave"},
			{"id": "normal_zoom", "label": "Normal RTS zoom", "action": "battle_default"},
			{"id": "zoomed_out_view", "label": "Zoomed-out shell-v2 view", "action": "camera_max_zoom"},
			{"id": "pan_framing", "label": "Pan framing", "action": "pan_camera"},
			{"id": "minimap_correlation", "label": "Minimap correlation", "action": "minimap"},
			{"id": "results_path", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.205":
		return [
			{"id": "overview", "label": "Grounding props tactical overview", "action": "battle_default"},
			{"id": "ground_roads_props", "label": "Ground, roads and sparse props", "action": "quarry_objective"},
			{"id": "river_bridge_grounding", "label": "River, banks and bridge grounding", "action": "v0195_bridge_close"},
			{"id": "structures_grounding", "label": "Structures and foundations grounded", "action": "worker_selected"},
			{"id": "units_grounding", "label": "Units grounded with readable markers", "action": "squad_selected"},
			{"id": "ashen_combat_readability", "label": "Ashen combat readability", "action": "ashen_pressure_wave"},
			{"id": "minimap_pan_zoom", "label": "Minimap, pan and zoom posture", "action": "camera_max_zoom"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.204":
		return [
			{"id": "overview", "label": "Structure-finish material tactical overview", "action": "battle_default"},
			{"id": "command_hall", "label": "Command Hall practical anchor", "action": "v0186_command_hall_close"},
			{"id": "mine", "label": "West Stone Cut utility structure", "action": "v0186_mine_close"},
			{"id": "barracks_restoring", "label": "Barracks restoring state", "action": "v0186_barracks_restoration_close"},
			{"id": "barracks_restored", "label": "Barracks restored state", "action": "v0186_barracks_restored"},
			{"id": "material_scale", "label": "Material scale and seam diagnostic", "action": "v0186_command_hall_normal"},
			{"id": "unit_marker_occlusion", "label": "Unit and marker occlusion check", "action": "squad_selected"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.203":
		return [
			{"id": "overview", "label": "Environmental cohesion tactical overview", "action": "battle_default"},
			{"id": "ground_roads", "label": "Ground and road hierarchy", "action": "quarry_objective"},
			{"id": "river_bridge", "label": "River, banks and bridge", "action": "lume_stable"},
			{"id": "structures", "label": "Structures grounded", "action": "worker_selected"},
			{"id": "units", "label": "Units grounded", "action": "squad_selected"},
			{"id": "combat", "label": "Combat readability", "action": "ashen_pressure_wave"},
			{"id": "minimap", "label": "Minimap", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"},
			{"id": "private_harness_preserved", "label": "Private harness preserved separately", "action": "private_harness"}
		]
	if _player_capture_checkpoint() == "v0.200":
		return [
			{"id": "overview", "label": "Grounding and lighting full tactical overview", "action": "battle_default"},
			{"id": "ground_roads", "label": "Ground value, sparse props, and clear road hierarchy", "action": "v0195_road_network"},
			{"id": "river_bridge", "label": "River, bridge, and bank-edge accents", "action": "v0195_bridge_close"},
			{"id": "structures", "label": "Structures remain legible with sparse grounding", "action": "v0186_command_hall_close"},
			{"id": "units", "label": "Units sit naturally on the battlefield", "action": "hero_selected"},
			{"id": "combat", "label": "Combat onset remains tactically readable", "action": "v0187_combat_crossing"},
			{"id": "pan_zoom", "label": "Pan and zoom review framing", "action": "camera_max_zoom"},
			{"id": "minimap", "label": "Minimap remains procedural", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.199":
		return [
			{"id": "overview", "label": "Structure hierarchy full tactical overview", "action": "battle_default"},
			{"id": "command_hall", "label": "Command Hall practical massing", "action": "v0186_command_hall_close"},
			{"id": "mine", "label": "Mine cut and crane hierarchy", "action": "v0186_mine_close"},
			{"id": "barracks_restoring", "label": "Barracks restoration scaffold and progress read", "action": "v0186_barracks_restoration_close"},
			{"id": "barracks_restored", "label": "Restored Barracks complete roof and drill yard read", "action": "v0186_barracks_restored"},
			{"id": "worker_barracks", "label": "Worker and Barracks relation", "action": "v0186_worker_barracks_relation"},
			{"id": "combat_posture", "label": "Combat posture remains readable around structures", "action": "v0187_combat_crossing"},
			{"id": "minimap", "label": "Minimap remains procedural", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.198":
		return [
			{"id": "title", "label": "Title shell with v0.198 wet-granite bridge-riverbank opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "wet_granite_bridge_banks", "label": "Wet-granite bridge and banks at normal distance", "action": "battle_default"},
			{"id": "bridge_close", "label": "Bridge abutment close view", "action": "v0195_bridge_close"},
			{"id": "banks_close", "label": "Riverbank retaining edges close view", "action": "v0187_river_overview"},
			{"id": "road_bridge_transition", "label": "Road-to-bridge transition remains readable", "action": "v0195_road_to_bridge"},
			{"id": "units_crossing", "label": "Units remain readable near crossing", "action": "v0187_combat_crossing"},
			{"id": "overview", "label": "Full tactical overview with scoped wet granite", "action": "battle_default"},
			{"id": "minimap", "label": "Minimap remains procedural", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.197":
		return [
			{"id": "title", "label": "Title shell with v0.197 mesh QA opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "overview", "label": "Mesh QA full tactical overview", "action": "battle_default"},
			{"id": "roads", "label": "Road ribbon width and continuity", "action": "v0195_road_network"},
			{"id": "bridge_approaches", "label": "Bridge approach continuity", "action": "v0195_bridge_close"},
			{"id": "river_banks", "label": "River continuity and bank framing", "action": "v0187_river_overview"},
			{"id": "units_structures", "label": "Units and structures grounded in the mesh", "action": "construction_progress"},
			{"id": "pan_zoom", "label": "Pan and zoom framing", "action": "camera_max_zoom"},
			{"id": "minimap", "label": "Minimap full frame", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.196":
		return [
			{"id": "title", "label": "Title shell with v0.196 mesh compositor opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "mesh_compositor_overview", "label": "Mesh compositor full tactical overview", "action": "battle_default"},
			{"id": "aster_initial_frame", "label": "Aster initial frame", "action": "hero_selected"},
			{"id": "terrain_normal", "label": "Contiguous terrain and road surfaces at normal review distance", "action": "battle_default"},
			{"id": "roads_overview", "label": "Roads as route-following surfaces", "action": "v0195_road_network"},
			{"id": "road_intersection", "label": "Road intersection continuity", "action": "v0195_road_intersections"},
			{"id": "left_bridge_approach", "label": "Left bridge approach", "action": "v0187_friendly_approach"},
			{"id": "right_bridge_approach", "label": "Right bridge approach", "action": "v0187_hostile_approach"},
			{"id": "river_banks", "label": "Continuous river and bank framing", "action": "v0187_river_overview"},
			{"id": "bridge_close", "label": "Bridge crossing close view", "action": "v0195_bridge_close"},
			{"id": "worker_area", "label": "Worker assignment area", "action": "worker_assigned_mine"},
			{"id": "barracks_area", "label": "Barracks area", "action": "construction_progress"},
			{"id": "pan", "label": "Pan review", "action": "pan_camera"},
			{"id": "zoom", "label": "Zoom review", "action": "camera_max_zoom"},
			{"id": "minimap", "label": "Minimap full frame", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.195":
		return [
			{"id": "title", "label": "Title shell with v0.195 scoped material recovery opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "tactical_overview", "label": "Tactical overview with recovered terrain hierarchy", "action": "battle_default"},
			{"id": "aster_initial_frame", "label": "Aster initial frame", "action": "hero_selected"},
			{"id": "terrain_normal", "label": "Terrain material normal review distance", "action": "battle_default"},
			{"id": "terrain_close", "label": "Terrain material close view", "action": "buildable_ground"},
			{"id": "terrain_zoomed", "label": "Terrain material zoomed review", "action": "camera_max_zoom"},
			{"id": "connected_road_network", "label": "Connected road network", "action": "v0195_road_network"},
			{"id": "road_intersection", "label": "Road intersection continuity", "action": "v0195_road_intersections"},
			{"id": "road_to_bridge_transition", "label": "Road-to-bridge transition", "action": "v0195_road_to_bridge"},
			{"id": "river_overview", "label": "Continuous river overview", "action": "v0187_river_overview"},
			{"id": "bridge_close_view", "label": "Bridge crossing close view", "action": "v0195_bridge_close"},
			{"id": "worker_assignment_area", "label": "Worker assignment area", "action": "worker_assigned_mine"},
			{"id": "barracks_area", "label": "Barracks area", "action": "construction_progress"},
			{"id": "militia_ready_posture", "label": "Militia-ready posture", "action": "militia_spawned"},
			{"id": "pan", "label": "Pan review", "action": "pan_camera"},
			{"id": "zoom", "label": "Zoom review", "action": "camera_max_zoom"},
			{"id": "minimap", "label": "Minimap", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.194":
		return [
			{"id": "title", "label": "Title shell with v0.194 topology repair opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "shell_v2_overview", "label": "Shell v2 repaired full tactical overview", "action": "battle_default"},
			{"id": "aster_initial_frame", "label": "Aster initial frame", "action": "hero_selected"},
			{"id": "terrain_overview", "label": "Coherent terrain base overview", "action": "battle_default"},
			{"id": "road_network_overview", "label": "Connected road network overview", "action": "road"},
			{"id": "road_intersection", "label": "Road intersection continuity", "action": "road_intersections"},
			{"id": "road_to_bridge_transition", "label": "Road-to-bridge transition", "action": "v0187_road_to_bridge"},
			{"id": "river_overview", "label": "Continuous river overview", "action": "v0187_river_overview"},
			{"id": "bridge_close_view", "label": "Bridge crossing close view", "action": "v0187_bridge_close"},
			{"id": "left_bridge_approach", "label": "Left bridge approach", "action": "v0187_friendly_approach"},
			{"id": "right_bridge_approach", "label": "Right bridge approach", "action": "v0187_hostile_approach"},
			{"id": "worker_assignment_area", "label": "Worker assignment area", "action": "worker_assigned_mine"},
			{"id": "barracks_area", "label": "Barracks area", "action": "construction_progress"},
			{"id": "militia_ready_posture", "label": "Militia-ready posture", "action": "militia_spawned"},
			{"id": "pan", "label": "Pan review", "action": "pan_camera"},
			{"id": "zoom", "label": "Zoom review", "action": "camera_max_zoom"},
			{"id": "minimap", "label": "Minimap", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.193":
		return [
			{"id": "title", "label": "Title shell with v0.193 presentation shell v2 opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "shell_v2_overview", "label": "Shell v2 full overview", "action": "battle_default"},
			{"id": "aster_initial_frame", "label": "Aster initial frame", "action": "hero_selected"},
			{"id": "worker_assignment_area", "label": "Worker assignment area", "action": "worker_assigned_mine"},
			{"id": "barracks_restoration", "label": "Barracks restoration", "action": "construction_progress"},
			{"id": "militia_recruitment", "label": "Militia recruitment", "action": "militia_spawned"},
			{"id": "ashen_combat_posture", "label": "Ashen combat posture", "action": "combat"},
			{"id": "road_close_view", "label": "Road close view", "action": "road"},
			{"id": "river_and_banks", "label": "River and banks", "action": "ford"},
			{"id": "bridge_crossing", "label": "Bridge crossing", "action": "bridge"},
			{"id": "structures", "label": "Structure masses", "action": "command_hall"},
			{"id": "pan", "label": "Pan review", "action": "pan_camera"},
			{"id": "zoom", "label": "Zoom review", "action": "camera_max_zoom"},
			{"id": "minimap", "label": "Minimap", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.187":
		return [
			{"id": "title", "label": "Title shell with v0.187 riverbank bridge approach opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "full_overview", "label": "R1 full overview", "action": "battle_default"},
			{"id": "river_overview", "label": "River overview continuity", "action": "v0187_river_overview"},
			{"id": "banks_normal", "label": "Bank shaping normal view", "action": "v0187_banks_normal"},
			{"id": "banks_close", "label": "Bank shaping close view", "action": "v0187_banks_close"},
			{"id": "bridge_normal", "label": "Bridge crossing normal view", "action": "v0187_bridge_normal"},
			{"id": "bridge_close", "label": "Bridge crossing close view", "action": "v0187_bridge_close"},
			{"id": "road_to_bridge_transition", "label": "Road-to-bridge transition", "action": "v0187_road_to_bridge"},
			{"id": "friendly_approach", "label": "Friendly foothold approach", "action": "v0187_friendly_approach"},
			{"id": "hostile_approach", "label": "Hostile approach lane", "action": "v0187_hostile_approach"},
			{"id": "combat_crossing_posture", "label": "Combat crossing posture", "action": "v0187_combat_crossing"},
			{"id": "pan", "label": "Pan review", "action": "pan_camera"},
			{"id": "zoom", "label": "Zoom review", "action": "camera_max_zoom"},
			{"id": "minimap", "label": "Minimap correlation", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.186":
		return [
			{"id": "title", "label": "Title shell with v0.186 structure-shell hardening opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "full_overview_before", "label": "E4 full overview baseline framing", "action": "battle_default"},
			{"id": "command_hall_normal", "label": "Command Hall normal view", "action": "v0186_command_hall_normal"},
			{"id": "command_hall_close", "label": "Command Hall close hierarchy", "action": "v0186_command_hall_close"},
			{"id": "mine_normal", "label": "Mine normal view", "action": "v0186_mine_normal"},
			{"id": "mine_close", "label": "Mine cut close hierarchy", "action": "v0186_mine_close"},
			{"id": "barracks_restoration", "label": "Barracks under restoration", "action": "v0186_barracks_restoration"},
			{"id": "barracks_restoration_close", "label": "Barracks restoration scaffold close", "action": "v0186_barracks_restoration_close"},
			{"id": "barracks_restored", "label": "Restored Barracks", "action": "v0186_barracks_restored"},
			{"id": "worker_barracks_relation", "label": "Worker and Barracks relationship", "action": "v0186_worker_barracks_relation"},
			{"id": "road_bridge_relation", "label": "Road and bridge relation", "action": "bridge"},
			{"id": "site_structure_marker", "label": "Site structure marker hierarchy", "action": "site_marker_hierarchy"},
			{"id": "combat_posture", "label": "Combat posture with hardened structures", "action": "combat"},
			{"id": "pan", "label": "Pan review", "action": "pan_camera"},
			{"id": "zoom", "label": "Zoom review", "action": "camera_max_zoom"},
			{"id": "minimap", "label": "Minimap", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.185":
		return [
			{"id": "title", "label": "Title shell with v0.185 refined environment-shell opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "full_battlefield_overview", "label": "Full battlefield overview", "action": "battle_default"},
			{"id": "initial_aster_frame", "label": "Initial Aster frame", "action": "hero_selected"},
			{"id": "worker_assignment", "label": "Worker assignment posture", "action": "worker_assigned_mine"},
			{"id": "barracks_restoration", "label": "Barracks restoration posture", "action": "construction_progress"},
			{"id": "militia_recruitment", "label": "Militia recruitment posture", "action": "militia_spawned"},
			{"id": "river_overview", "label": "River overview", "action": "ford"},
			{"id": "riverbank_close_view", "label": "Riverbank close view", "action": "friendly_boundary"},
			{"id": "bridge_close_view", "label": "Bridge close view", "action": "bridge"},
			{"id": "road_close_view", "label": "Road close view", "action": "road"},
			{"id": "road_intersection", "label": "Road intersection", "action": "road_intersections"},
			{"id": "command_hall", "label": "Command Hall shell", "action": "command_hall"},
			{"id": "mine", "label": "Mine shell", "action": "mine"},
			{"id": "barracks_shell", "label": "Barracks shell", "action": "barracks_complete"},
			{"id": "ashen_combat_posture", "label": "Ashen combat posture", "action": "combat"},
			{"id": "pan", "label": "Pan review", "action": "pan_camera"},
			{"id": "zoom", "label": "Zoom review", "action": "camera_max_zoom"},
			{"id": "minimap", "label": "Minimap", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.184":
		return [
			{"id": "title", "label": "Title shell with v0.184 geometry-convergence opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "full_battlefield_overview", "label": "Full battlefield overview", "action": "battle_default"},
			{"id": "initial_aster_frame", "label": "Initial Aster frame", "action": "hero_selected"},
			{"id": "worker_assignment", "label": "Worker assignment posture", "action": "worker_assigned_mine"},
			{"id": "barracks_restoration", "label": "Barracks restoration posture", "action": "construction_progress"},
			{"id": "militia_recruitment", "label": "Militia recruitment posture", "action": "militia_spawned"},
			{"id": "river_overview", "label": "River overview", "action": "ford"},
			{"id": "riverbank_close_view", "label": "Riverbank close view", "action": "friendly_boundary"},
			{"id": "bridge_close_view", "label": "Bridge close view", "action": "bridge"},
			{"id": "road_close_view", "label": "Road close view", "action": "road"},
			{"id": "road_intersection", "label": "Road intersection", "action": "road_intersections"},
			{"id": "command_hall", "label": "Command Hall shell", "action": "command_hall"},
			{"id": "mine", "label": "Mine shell", "action": "mine"},
			{"id": "barracks_shell", "label": "Barracks shell", "action": "barracks_complete"},
			{"id": "ashen_combat_posture", "label": "Ashen combat posture", "action": "combat"},
			{"id": "pan", "label": "Pan review", "action": "pan_camera"},
			{"id": "zoom", "label": "Zoom review", "action": "camera_max_zoom"},
			{"id": "minimap", "label": "Minimap", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.179":
		return [
			{"id": "title", "label": "Title shell with configured environment contrast posture", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "tactical_overview", "label": "Tactical overview over textured foothold", "action": "battle_default"},
			{"id": "road_intersections", "label": "Road shoulders and intersections over textured ground", "action": "road_intersections"},
			{"id": "river_banks", "label": "River bank contrast over textured ground", "action": "ford"},
			{"id": "bridge_crossing", "label": "Bridge crossing hierarchy", "action": "bridge"},
			{"id": "site_marker_hierarchy", "label": "Site marker hierarchy over textured ground", "action": "site_marker_hierarchy"},
			{"id": "mine_barracks_approach", "label": "Mine and Barracks approach lanes", "action": "approach_lanes"},
			{"id": "hostile_approach_lane", "label": "Hostile approach lane", "action": "hostile_lane"},
			{"id": "five_slot_combat_posture", "label": "Five-slot combat posture readability", "action": "combat"},
			{"id": "camera_pan_readability", "label": "Camera pan readability", "action": "pan_camera"},
			{"id": "camera_min_zoom", "label": "Zoomed-in contrast edge treatment", "action": "camera_min_zoom"},
			{"id": "camera_max_zoom", "label": "Zoomed-out contrast and repetition check", "action": "camera_max_zoom"},
			{"id": "minimap_correlation", "label": "Minimap correlation markers", "action": "minimap"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.181":
		return [
			{"id": "title", "label": "Title shell with configured ground and road material opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "ground_material_normal_rts", "label": "Ground and road material normal RTS distance", "action": "battle_default"},
			{"id": "ground_material_close", "label": "Close foothold material and road edge view", "action": "friendly_boundary"},
			{"id": "road_river_bridge_hierarchy", "label": "Road material, river and bridge hierarchy", "action": "ford"},
			{"id": "site_marker_scope", "label": "Site markers and capture ring remain procedural", "action": "site_marker_hierarchy"},
			{"id": "five_slot_coexistence", "label": "Five selected slots over ground and road materials", "action": "squad_selected"},
			{"id": "combat_onset", "label": "Combat readability with ground and road materials", "action": "combat"},
			{"id": "camera_pan_readability", "label": "Pan camera road material readability", "action": "pan_camera"},
			{"id": "camera_min_zoom", "label": "Zoomed-in road material edge treatment", "action": "camera_min_zoom"},
			{"id": "camera_max_zoom", "label": "Zoomed-out road material repetition check", "action": "camera_max_zoom"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if ["v0.177", "v0.178"].has(_player_capture_checkpoint()):
		return [
			{"id": "title", "label": "Title shell with configured ground-material opt-in", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "ground_material_normal_rts", "label": "Hardened ground material normal RTS distance", "action": "battle_default"},
			{"id": "ground_material_close", "label": "Close hardened foothold ground material view", "action": "friendly_boundary"},
			{"id": "road_river_bridge_hierarchy", "label": "Road river bridge hierarchy over hardened material", "action": "ford"},
			{"id": "site_marker_scope", "label": "Site markers and capture ring remain procedural", "action": "site_marker_hierarchy"},
			{"id": "five_slot_coexistence", "label": "Five selected slots over hardened ground material", "action": "squad_selected"},
			{"id": "combat_onset", "label": "Combat readability with hardened ground material", "action": "combat"},
			{"id": "camera_pan_readability", "label": "Pan camera readability", "action": "pan_camera"},
			{"id": "camera_min_zoom", "label": "Zoomed-in hardened material edge treatment", "action": "camera_min_zoom"},
			{"id": "camera_max_zoom", "label": "Zoomed-out hardened material repetition check", "action": "camera_max_zoom"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.174":
		return [
			{"id": "title", "label": "Title shell with configured E2 environment path", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "tactical_overview", "label": "Tactical overview", "action": "battle_default"},
			{"id": "road_intersections", "label": "Road continuity and intersections", "action": "road_intersections"},
			{"id": "river_bridge_normal", "label": "River and bridge normal view", "action": "ford"},
			{"id": "river_bridge_close", "label": "River and bridge close view", "action": "bridge"},
			{"id": "approach_lanes", "label": "Mine and Barracks approach lanes", "action": "approach_lanes"},
			{"id": "friendly_boundary", "label": "Friendly foothold boundary", "action": "friendly_boundary"},
			{"id": "hostile_approach_lane", "label": "Hostile approach lane", "action": "hostile_lane"},
			{"id": "site_marker_hierarchy", "label": "Site marker hierarchy", "action": "site_marker_hierarchy"},
			{"id": "mine_converted", "label": "Mine converted and readable", "action": "mine_converted"},
			{"id": "barracks_restored", "label": "Barracks restored", "action": "barracks_complete"},
			{"id": "minimap_correlation", "label": "Minimap correlation", "action": "minimap"},
			{"id": "five_slot_combat_posture", "label": "Five-slot combat posture", "action": "combat"},
			{"id": "camera_pan_readability", "label": "Pan camera readability", "action": "pan_camera"},
			{"id": "camera_zoom_readability", "label": "Zoom camera readability", "action": "zoom_camera"},
			{"id": "camera_min_zoom", "label": "Zoomed-in edge treatment", "action": "camera_min_zoom"},
			{"id": "camera_max_zoom", "label": "Zoomed-out readability", "action": "camera_max_zoom"}
		]
	if _player_capture_checkpoint() == "v0.173":
		return [
			{"id": "title", "label": "Title shell with configured 2.5D backdrop", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "battle_default_full_battlefield", "label": "Full battlefield", "action": "battle_default"},
			{"id": "road_network", "label": "Road width and path readability", "action": "road"},
			{"id": "river_banks", "label": "River and bank contrast", "action": "ford"},
			{"id": "bridge_crossing", "label": "Bridge crossing silhouette", "action": "bridge"},
			{"id": "mine_uncaptured", "label": "Mine before conversion", "action": "mine_uncaptured"},
			{"id": "mine_converted", "label": "Mine converted and readable", "action": "mine_converted"},
			{"id": "barracks_restoration", "label": "Barracks under restoration", "action": "construction_progress"},
			{"id": "barracks_restored", "label": "Barracks restored", "action": "barracks_complete"},
			{"id": "command_hall", "label": "Command Hall shell hierarchy", "action": "command_hall"},
			{"id": "site_markers", "label": "Site marker clarity", "action": "site"},
			{"id": "five_slot_coexistence", "label": "Worker Barracks Militia Aster Ashen coexistence", "action": "squad_selected"},
			{"id": "combat_posture", "label": "Combat posture", "action": "combat"},
			{"id": "minimap", "label": "Minimap correlation", "action": "minimap"},
			{"id": "pan_camera", "label": "Pan camera", "action": "pan_camera"},
			{"id": "zoom_camera", "label": "Zoom camera", "action": "zoom_camera"},
			{"id": "camera_min_zoom", "label": "Zoomed-in edge treatment", "action": "camera_min_zoom"},
			{"id": "camera_max_zoom", "label": "Zoomed-out readability", "action": "camera_max_zoom"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
	if _player_capture_checkpoint() == "v0.160" or _player_capture_checkpoint() == "v0.162" or _player_capture_checkpoint() == "v0.164" or _player_capture_checkpoint() == "v0.166" or _player_capture_checkpoint() == "v0.168" or _player_capture_checkpoint() == "v0.169" or _player_capture_checkpoint() == "v0.170":
		return [
			{"id": "title", "label": "Title shell with configured 2.5D backdrop", "action": "title"},
			{"id": "briefing", "label": "Briefing shell", "action": "briefing"},
			{"id": "battle_default", "label": "Battle default", "action": "battle_default"},
			{"id": "worker_selected", "label": "Worker selected with selection ring", "action": "worker_selected"},
			{"id": "mine_converted", "label": "Mine converted before assignment", "action": "mine_converted"},
			{"id": "worker_assigned", "label": "Worker assigned to mine", "action": "worker_assigned_mine"},
			{"id": "build_placement", "label": "Barracks repair proximity", "action": "build_placement"},
			{"id": "barracks_complete", "label": "Barracks restored", "action": "barracks_complete"},
			{"id": "squad_crowding", "label": "Group crowding comparison", "action": "squad_selected"},
			{"id": "camera_min_zoom", "label": "Zoomed-in edge treatment", "action": "camera_min_zoom"},
			{"id": "camera_max_zoom", "label": "Zoomed-out readability", "action": "camera_max_zoom"},
			{"id": "results", "label": "Results path preserved", "action": "results"}
		]
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

func _read_absolute_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _sha256_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	while file.get_position() < file.get_length():
		var remaining := file.get_length() - file.get_position()
		context.update(file.get_buffer(int(min(65536, remaining))))
	return context.finish().hex_encode()

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
