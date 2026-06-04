extends RefCounted
class_name UnitDefinitionAdapter

const REQUIRED_PLAYER_UNITS := ["worker", "militia", "ranger"]
const REQUIRED_ENEMY_UNITS := ["raider", "hexer", "brute", "enemy_commander"]

func validate_adapter(registry) -> Dictionary:
	var errors: Array[String] = []
	var missing: Array = registry.require_ids("units", REQUIRED_PLAYER_UNITS + REQUIRED_ENEMY_UNITS)
	if missing.size() > 0:
		errors.append("Missing unit definitions: %s" % ", ".join(missing))
	return {
		"schemaVersion": 1,
		"adapter": "UnitDefinitionAdapter",
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"playerUnits": REQUIRED_PLAYER_UNITS,
		"enemyUnits": REQUIRED_ENEMY_UNITS,
		"workerReference": registry.get_entry("units", "worker").get("displayName", "Worker"),
		"deterministicOrdering": true
	}
