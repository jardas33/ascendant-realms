extends RefCounted
class_name SiteDefinitionAdapter

const REQUIRED_SITES := ["west_stone_cut", "ford_toll", "north_aether_spring"]

func validate_adapter(registry) -> Dictionary:
	var errors: Array[String] = []
	var missing: Array = registry.require_ids("captureSites", REQUIRED_SITES)
	if missing.size() > 0:
		errors.append("Missing site definitions: %s" % ", ".join(missing))
	return {
		"schemaVersion": 1,
		"adapter": "SiteDefinitionAdapter",
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"mineEquivalentSiteId": "west_stone_cut",
		"shrineEquivalentSiteId": "ford_toll",
		"captureSiteFixtureId": "north_aether_spring",
		"deterministicOrdering": true
	}
