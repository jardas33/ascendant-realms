extends RefCounted
class_name LumeDefinitionAdapter

const REQUIRED_LUME_NETWORK := "aether_well_ruins_lume_ward"
const REQUIRED_LINKED_WARD := 0.92

func validate_adapter(registry, scene_fixture: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var missing: Array = registry.require_ids("lumeNetworks", [REQUIRED_LUME_NETWORK])
	if missing.size() > 0:
		errors.append("Missing Lume network definitions: %s" % ", ".join(missing))
	var lume: Dictionary = scene_fixture.get("lume", {})
	var multiplier := float(lume.get("linkedWardDamageTakenMultiplier", -1.0))
	if abs(multiplier - REQUIRED_LINKED_WARD) > 0.00001:
		errors.append("linked_ward must remain exactly 0.92.")
	return {
		"schemaVersion": 1,
		"adapter": "LumeDefinitionAdapter",
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"networkId": REQUIRED_LUME_NETWORK,
		"benefitId": str(lume.get("benefitId", "")),
		"linkId": str(lume.get("linkId", "")),
		"linkedWardDamageTakenMultiplier": multiplier,
		"expectedTransitions": ["active", "severed", "restored"],
		"saveMutationAllowed": false
	}
