class_name CaptureAutoloadGate
extends RefCounted

## Shared fail-closed gate for legacy capture autoloads.
## This file intentionally contains no gameplay, scene, balance, or persistence data.

const REGISTRY: Dictionary = {
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
const CONFLICT_REPORTER := "V0431Capture"

static func recognized_variables() -> Array[String]:
	var variables: Array[String] = []
	for variable in REGISTRY.values():
		variables.append(String(variable))
	return variables

static func active_variables() -> Array[String]:
	var environment: Dictionary = {}
	for variable in recognized_variables():
		environment[variable] = OS.get_environment(variable)
	return active_variables_for(environment)

static func active_variables_for(environment: Dictionary) -> Array[String]:
	var active: Array[String] = []
	for variable in recognized_variables():
		if String(environment.get(variable, "")) == "1":
			active.append(variable)
	return active

static func is_enabled_for(autoload_name: String) -> bool:
	return is_enabled_for_values(autoload_name, active_variables())

static func is_enabled_for_values(autoload_name: String, active: Array[String]) -> bool:
	if not REGISTRY.has(autoload_name):
		return false
	return active.size() == 1 and active[0] == String(REGISTRY[autoload_name])

static func guard_autoload(node: Node, autoload_name: String) -> bool:
	return guard_autoload_with_active_variables(node, autoload_name, active_variables())

static func guard_autoload_with_active_variables(node: Node, autoload_name: String, active: Array[String]) -> bool:
	var requested := String(REGISTRY.get(autoload_name, ""))
	var enabled := requested != "" and is_enabled_for_values(autoload_name, active)
	if enabled:
		return true

	if active.size() > 1 and autoload_name == CONFLICT_REPORTER:
		push_error("CAPTURE_AUTOLOAD_CONFLICT denied %s active=%s" % [autoload_name, ",".join(active)])
	elif active.size() <= 1:
		print("CAPTURE_AUTOLOAD_INERT %s active=%s" % [autoload_name, ",".join(active)])
	if is_instance_valid(node):
		node.set_process(false)
		node.set_physics_process(false)
		node.set_process_input(false)
		node.set_process_unhandled_input(false)
		node.queue_free()
	return false
