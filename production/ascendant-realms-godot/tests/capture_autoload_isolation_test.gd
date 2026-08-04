extends SceneTree

const CaptureGate = preload("res://tests/capture_autoload_gate.gd")

const EXPECTED_REGISTRY := {
	"V0431Capture": "ASCENDANT_V0431_CAPTURE",
	"V0432Capture": "ASCENDANT_V0432_CAPTURE",
	"V0433Capture": "ASCENDANT_V0433_CAPTURE",
	"V0434Capture": "ASCENDANT_V0434_CAPTURE",
	"V0435Capture": "ASCENDANT_V0435_CAPTURE",
	"V0436Capture": "ASCENDANT_V0436_CAPTURE",
	"V0436R1Capture": "ASCENDANT_V0436_R1_CAPTURE",
	"V0436R1FCapture": "ASCENDANT_V0436_R1F_CAPTURE",
	"V0436R1CCapture": "ASCENDANT_V0436_R1C_CAPTURE",
	"V0436R1DStartupCapture": "ASCENDANT_V0436_R1D_STARTUP_CAPTURE",
	"V0436R1GCapture": "ASCENDANT_V0436_R1G_CAPTURE",
	"V0436R1HCapture": "ASCENDANT_V0436_R1H_CAPTURE",
	"V0436R1JCapture": "ASCENDANT_V0436_R1J_CAPTURE",
	"V0436R1KCapture": "ASCENDANT_V0436_R1K_CAPTURE",
}

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _environment(variable: String, value: String = "") -> Dictionary:
	var environment: Dictionary = {}
	for recognized in CaptureGate.recognized_variables():
		environment[recognized] = ""
	if not value.is_empty():
		environment[variable] = value
	return environment

func _active(environment: Dictionary) -> Array[String]:
	return CaptureGate.active_variables_for(environment)

func _assert_node_disabled(autoload_name: String, active: Array[String], label: String) -> void:
	var node := Node.new()
	var allowed := CaptureGate.guard_autoload_with_active_variables(node, autoload_name, active)
	_check(not allowed, label + " must be denied")
	_check(node.is_queued_for_deletion(), label + " must queue itself for deletion")

func _init() -> void:
	_check(CaptureGate.REGISTRY == EXPECTED_REGISTRY, "registry must contain exactly the fourteen authorized autoload identities")
	_check(CaptureGate.REGISTRY.size() == 14, "registry size must be fourteen")
	var variables := CaptureGate.recognized_variables()
	var unique := {}
	for variable in variables:
		unique[variable] = true
	_check(unique.size() == 14, "capture activation variables must be unique")

	var empty := _environment("")
	_check(_active(empty).is_empty(), "no capture variables must activate nothing")
	for autoload_name in EXPECTED_REGISTRY:
		_assert_node_disabled(autoload_name, [], "no-variable " + autoload_name)

	for autoload_name in EXPECTED_REGISTRY:
		var variable: String = EXPECTED_REGISTRY[autoload_name]
		var active := _active(_environment(variable, "1"))
		_check(CaptureGate.is_enabled_for_values(autoload_name, active), "matching variable must enable " + autoload_name)
		for other_name in EXPECTED_REGISTRY:
			if other_name != autoload_name:
				_check(not CaptureGate.is_enabled_for_values(other_name, active), "matching variable must deny " + other_name)

	var conflict_environment := _environment(EXPECTED_REGISTRY["V0431Capture"], "1")
	conflict_environment[EXPECTED_REGISTRY["V0432Capture"]] = "1"
	var conflict := _active(conflict_environment)
	_check(conflict.size() == 2, "two recognized variables must be active in conflict case")
	for autoload_name in EXPECTED_REGISTRY:
		_assert_node_disabled(autoload_name, conflict, "conflict " + autoload_name)

	for invalid in ["true", "yes", "0", "", " ", " 1"]:
		var invalid_environment := _environment(EXPECTED_REGISTRY["V0431Capture"], invalid)
		_check(_active(invalid_environment).is_empty(), "invalid value must not activate: '" + invalid + "'")

	var unknown_environment := _environment("")
	unknown_environment["ASCENDANT_UNKNOWN_CAPTURE"] = "1"
	_check(_active(unknown_environment).is_empty(), "unknown ASCENDANT capture variable must not activate")

	var enabled_node := Node.new()
	_check(CaptureGate.guard_autoload_with_active_variables(enabled_node, "V0431Capture", ["ASCENDANT_V0431_CAPTURE"]), "matching node must remain enabled")
	_check(not enabled_node.is_queued_for_deletion(), "matching node must not queue itself for deletion")

	if failures.is_empty():
		print("capture_autoload_isolation_test: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("capture_autoload_isolation_test: FAIL count=%d" % failures.size())
		quit(1)
