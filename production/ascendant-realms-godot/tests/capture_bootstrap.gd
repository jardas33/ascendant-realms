extends RefCounted
## Explicit opt-in bridge for legacy capture drivers.
## Normal PLAYER startup leaves every capture script unattached and dormant.

const DRIVER_SPECS: Array[Dictionary] = [
	{"env": "ASCENDANT_CURRENT_RESEARCH_CAPTURE", "name": "CurrentResearchCapture", "path": "res://tests/current_research_capture.gd"},
	{"env": "ASCENDANT_CURRENT_MILITARY_PRODUCTION_CAPTURE", "name": "CurrentMilitaryProductionCapture", "path": "res://tests/current_military_production_capture.gd"},
	{"env": "ASCENDANT_CURRENT_WORKER_ECONOMY_CAPTURE", "name": "CurrentWorkerEconomyCapture", "path": "res://tests/current_worker_economy_capture.gd"},
	{"env": "ASCENDANT_CURRENT_SHORT_PUBLIC_CAPTURE", "name": "CurrentShortPublicCapture", "path": "res://tests/current_short_public_capture.gd"},
	{"env": "ASCENDANT_P1_UI_CAPTURE", "name": "P1UiPresentationFixPack1", "path": "res://tests/p1_ui_presentation_fix_pack_1.gd"},
	{"env": "ASCENDANT_P1S1_CAPTURE", "name": "P1S1Capture", "path": "res://tests/p1s1_viewport_safe_area.gd"},
	{"env": "ASCENDANT_P1S4_CAPTURE", "name": "P1S4Capture", "path": "res://tests/p1s4_command_feedback.gd"},
	{"env": "ASCENDANT_P1_LOAD01", "name": "P1Load01Observer", "path": "res://tests/p1_load_01_observer.gd"},
	{"env": "ASCENDANT_V0436_R1D_STARTUP_CAPTURE", "name": "V0436R1DStartupCapture", "path": "res://tests/v0436_r1d_startup_capture.gd"},
	{"env": "ASCENDANT_V0436_R1K_CAPTURE", "name": "V0436R1KCapture", "path": "res://tests/v0436_r1k_capture.gd"},
	{"env": "ASCENDANT_V0436_R1J_CAPTURE", "name": "V0436R1JCapture", "path": "res://tests/v0436_r1j_capture.gd"},
	{"env": "ASCENDANT_V0436_E3R_CAPTURE", "name": "V0436R1HCapture", "path": "res://tests/v0436_r1h_capture.gd"},
	{"env": "ASCENDANT_V0436_R1H_CAPTURE", "name": "V0436R1HCapture", "path": "res://tests/v0436_r1h_capture.gd"},
	{"env": "ASCENDANT_V0436_R1G_CAPTURE", "name": "V0436R1GCapture", "path": "res://tests/v0436_r1g_capture.gd"},
	{"env": "ASCENDANT_V0436_R1F_CAPTURE", "name": "V0436R1FCapture", "path": "res://tests/v0436_r1f_boundary_physics.gd"},
	{"env": "ASCENDANT_V0436_R1_CAPTURE", "name": "V0436R1Capture", "path": "res://tests/v0436_r1_navigation_behavioral_proof.gd"},
	{"env": "ASCENDANT_V0436_R1C_CAPTURE", "name": "V0436R1CCapture", "path": "res://tests/v0436_r1c_capture.gd"},
	{"env": "ASCENDANT_V0436_CAPTURE", "name": "V0436Capture", "path": "res://tests/v0436_capture.gd"},
	{"env": "ASCENDANT_V0435_CAPTURE", "name": "V0435Capture", "path": "res://tests/v0435_capture.gd"},
	{"env": "ASCENDANT_V0434_CAPTURE", "name": "V0434Capture", "path": "res://tests/v0434_capture.gd"},
	{"env": "ASCENDANT_V0433_CAPTURE", "name": "V0433Capture", "path": "res://tests/v0433_capture.gd"},
	{"env": "ASCENDANT_V0432_CAPTURE", "name": "V0432Capture", "path": "res://tests/v0432_capture.gd"},
	{"env": "ASCENDANT_V0431_CAPTURE", "name": "V0431Capture", "path": "res://tests/v0431_capture.gd"},
]
const DRIVER_SCHEDULED_META := "ascendant_capture_driver_scheduled"

func attach_selected_driver(root: Node) -> Node:
	if root.has_meta(DRIVER_SCHEDULED_META):
		return null
	for spec in DRIVER_SPECS:
		if OS.get_environment(String(spec["env"])) != "1":
			continue
		var driver_script := load(String(spec["path"]))
		if driver_script == null:
			push_error("Capture driver could not be loaded: " + String(spec["path"]))
			return null
		var runner: Node = driver_script.new()
		runner.name = String(spec["name"])
		root.set_meta(DRIVER_SCHEDULED_META, runner.name)
		root.call_deferred("add_child", runner)
		return runner
	return null
