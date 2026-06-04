extends RefCounted
class_name BuildingDefinitionAdapter

const REQUIRED_BUILDINGS := ["command_hall", "barracks"]

func validate_adapter(registry) -> Dictionary:
	var errors: Array[String] = []
	var missing: Array = registry.require_ids("buildings", REQUIRED_BUILDINGS)
	if missing.size() > 0:
		errors.append("Missing building definitions: %s" % ", ".join(missing))
	return {
		"schemaVersion": 1,
		"adapter": "BuildingDefinitionAdapter",
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"playerBuildings": REQUIRED_BUILDINGS,
		"enemyStructuresFixtureOnly": ["enemy_stronghold", "enemy_barracks"],
		"deterministicOrdering": true
	}
