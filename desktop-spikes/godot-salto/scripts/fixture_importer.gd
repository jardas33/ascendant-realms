extends RefCounted
class_name SaltoFixtureImporter

const GENERATED_DIR := "res://data/generated"
const ContentRegistryAdapterScript := preload("res://scripts/adapters/content_registry_adapter.gd")
const StableIdValidatorScript := preload("res://scripts/adapters/stable_id_validator.gd")
const SaveFixtureReadOnlyAdapterScript := preload("res://scripts/adapters/save_fixture_read_only_adapter.gd")
const UnitDefinitionAdapterScript := preload("res://scripts/adapters/unit_definition_adapter.gd")
const BuildingDefinitionAdapterScript := preload("res://scripts/adapters/building_definition_adapter.gd")
const SiteDefinitionAdapterScript := preload("res://scripts/adapters/site_definition_adapter.gd")
const LumeDefinitionAdapterScript := preload("res://scripts/adapters/lume_definition_adapter.gd")
const ResultsContractAdapterScript := preload("res://scripts/adapters/results_contract_adapter.gd")
const REQUIRED_JSON_FILES := [
	"benchmark-contract.json",
	"content-subset.json",
	"expected-parity.json",
	"fixture-hashes.json",
	"input-contract.json",
	"results-contract.json",
	"save-fixture-index.json",
	"scene-fixture.json",
	"stable-id-subset.json",
	"visual-placeholder-contract.json",
	"fixture-manifest.json",
	"unknown-id-rejection-fixture.json"
]
const UNKNOWN_PROBE_ID := "v0122_unknown_fixture_id_must_be_rejected"

func load_json(file_name: String) -> Variant:
	var path := "%s/%s" % [GENERATED_DIR, file_name]
	if not FileAccess.file_exists(path):
		return null
	var text := FileAccess.get_file_as_string(path)
	return JSON.parse_string(text)

func validate_fixture() -> Dictionary:
	var errors: Array[String] = []
	var bundle := _load_required_json()
	var loaded: Dictionary = bundle["loaded"]
	for error in bundle["errors"]:
		errors.append(str(error))

	if errors.size() > 0:
		return _report(errors, {}, {}, [])

	var scene: Dictionary = loaded["scene-fixture.json"] as Dictionary
	var stable: Dictionary = loaded["stable-id-subset.json"] as Dictionary
	var expected: Dictionary = loaded["expected-parity.json"] as Dictionary
	var save_index: Dictionary = loaded["save-fixture-index.json"] as Dictionary
	var unknown_probe: Dictionary = loaded["unknown-id-rejection-fixture.json"] as Dictionary
	var stable_ids: Dictionary = _stable_id_set(stable)
	var selected_ids: Array[String] = selected_fixture_ids(scene)
	var missing_ids: Array[String] = []
	for id in selected_ids:
		if not stable_ids.has(id):
			missing_ids.append(id)

	var linked_ward := float(scene.get("lume", {}).get("linkedWardDamageTakenMultiplier", -1.0))
	var expected_linked_ward := float(expected.get("mustMatch", {}).get("linkedWardDamageTakenMultiplier", -1.0))
	if abs(linked_ward - 0.92) > 0.00001 or abs(expected_linked_ward - 0.92) > 0.00001:
		errors.append("linked_ward multiplier must remain exactly 0.92")
	if missing_ids.size() > 0:
		errors.append("Selected fixture IDs missing from stable subset: %s" % ", ".join(missing_ids))
	if stable_ids.has(UNKNOWN_PROBE_ID):
		errors.append("Unknown ID probe unexpectedly exists in stable-ID subset")
	if unknown_probe.get("accepted", true) != false:
		errors.append("Unknown ID rejection fixture must declare accepted=false")
	if int(save_index.get("currentSaveVersion", -1)) != 2:
		errors.append("Save fixture index must remain on current save version 2")
	if not str(expected.get("mustMatch", {}).get("saveFixtures", "")).contains("read-only"):
		errors.append("Save fixture posture must remain read-only")
	var adapter_validation := _adapter_validation_from_loaded(loaded, selected_ids)
	if adapter_validation.get("status", "FAIL") != "PASS_GODOT_CONTENT_ADAPTER_VALIDATION":
		for error in adapter_validation.get("errors", []):
			errors.append(str(error))

	var validation: Dictionary = {
		"schemaVersion": 1,
		"checkpoint": "v0.122",
		"selectedStableIds": selected_ids,
		"selectedStableIdCount": selected_ids.size(),
		"missingSelectedStableIds": missing_ids,
		"unknownProbeId": UNKNOWN_PROBE_ID,
		"unknownProbeRejected": not stable_ids.has(UNKNOWN_PROBE_ID),
		"linkedWardDamageTakenMultiplier": linked_ward,
		"readOnlySaveFixtures": true,
		"localStorageMutationAllowed": false,
		"runtimeArtIntegrated": false,
		"adapterValidationStatus": adapter_validation.get("status", "FAIL"),
		"adapterValidation": adapter_validation
	}
	return _report(errors, scene, validation, selected_ids)

func run_adapter_validation() -> Dictionary:
	var bundle := _load_required_json()
	if not (bundle["errors"] as Array).is_empty():
		return {
			"schemaVersion": 1,
			"checkpoint": "v0.122",
			"status": "FAIL_GODOT_CONTENT_ADAPTER_VALIDATION",
			"errors": bundle["errors"],
			"routineEditorUseRequired": false,
			"localStorageMutationAllowed": false,
			"saveWritesAllowed": false
		}
	var loaded: Dictionary = bundle["loaded"]
	var scene: Dictionary = loaded["scene-fixture.json"] as Dictionary
	return _adapter_validation_from_loaded(loaded, selected_fixture_ids(scene))

func selected_fixture_ids(scene: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	_add_id(ids, scene.get("map", {}).get("campaignNodeId", ""))
	_add_id(ids, scene.get("map", {}).get("mapId", ""))
	_add_id(ids, scene.get("lume", {}).get("networkId", ""))
	_add_id(ids, scene.get("player", {}).get("factionId", ""))
	_add_id(ids, scene.get("player", {}).get("worker", {}).get("unitId", ""))
	for unit in scene.get("player", {}).get("units", []):
		_add_id(ids, unit.get("unitId", ""))
	_add_id(ids, scene.get("enemy", {}).get("factionId", ""))
	for unit in scene.get("enemy", {}).get("units", []):
		_add_id(ids, unit.get("unitId", ""))
	for structure in scene.get("structures", []):
		_add_id(ids, structure.get("buildingId", ""))
	for site in scene.get("sites", []):
		_add_id(ids, site.get("siteId", ""))
	ids.sort()
	return ids

func _stable_id_set(stable: Dictionary) -> Dictionary:
	var ids: Dictionary = {}
	for entry in stable.get("manifestEntries", []):
		ids[entry.get("id", "")] = true
	return ids

func _load_required_json() -> Dictionary:
	var errors: Array[String] = []
	var loaded: Dictionary = {}
	for file_name in REQUIRED_JSON_FILES:
		var parsed: Variant = load_json(file_name)
		if parsed == null:
			errors.append("Missing or invalid generated fixture JSON: %s" % file_name)
		else:
			loaded[file_name] = parsed
	return {"errors": errors, "loaded": loaded}

func _adapter_validation_from_loaded(loaded: Dictionary, selected_ids: Array[String]) -> Dictionary:
	var errors: Array[String] = []
	var content_subset: Dictionary = loaded["content-subset.json"] as Dictionary
	var stable_subset: Dictionary = loaded["stable-id-subset.json"] as Dictionary
	var scene_fixture: Dictionary = loaded["scene-fixture.json"] as Dictionary
	var save_index: Dictionary = loaded["save-fixture-index.json"] as Dictionary
	var results_contract: Dictionary = loaded["results-contract.json"] as Dictionary
	var hashes: Dictionary = loaded["fixture-hashes.json"] as Dictionary
	var registry = ContentRegistryAdapterScript.new()
	var registry_report: Dictionary = registry.load_registry(content_subset, hashes)
	var stable_report: Dictionary = _stable_id_adapter_report(stable_subset, registry, selected_ids, UNKNOWN_PROBE_ID)
	var save_report: Dictionary = _save_fixture_adapter_report(save_index)
	var unit_report: Dictionary = _unit_adapter_report(registry)
	var building_report: Dictionary = _building_adapter_report(registry)
	var site_report: Dictionary = _site_adapter_report(registry)
	var lume_report: Dictionary = _lume_adapter_report(registry, scene_fixture)
	var results_report: Dictionary = _results_adapter_report(results_contract)
	var adapter_reports := {
		"ContentRegistryAdapter": registry_report,
		"StableIdValidator": stable_report,
		"SaveFixtureReadOnlyAdapter": save_report,
		"UnitDefinitionAdapter": unit_report,
		"BuildingDefinitionAdapter": building_report,
		"SiteDefinitionAdapter": site_report,
		"LumeDefinitionAdapter": lume_report,
		"ResultsContractAdapter": results_report
	}
	for adapter_name in adapter_reports.keys():
		var report: Dictionary = adapter_reports[adapter_name]
		if str(report.get("status", "FAIL")) != "PASS":
			for error in report.get("errors", []):
				errors.append("%s: %s" % [adapter_name, str(error)])
	var required_subset := {
		"barrosanPlaceholderFactionReference": "free_marches",
		"ashenPlaceholderEnemyReference": "ashen_covenant",
		"heroReference": "hero_aster",
		"units": ["worker", "militia", "ranger"],
		"buildings": ["command_hall", "barracks"],
		"mineEquivalentSiteId": "west_stone_cut",
		"shrineEquivalentSiteId": "ford_toll",
		"captureSiteId": "north_aether_spring",
		"lumeNetworkId": "aether_well_ruins_lume_ward",
		"lumeLinkId": str(scene_fixture.get("lume", {}).get("linkId", "")),
		"abilityPlaceholderId": "rally_banner",
		"resultsContract": "results-contract.json",
		"enemyPressureFixture": "Tier M bounded Ashen pressure"
	}
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.122",
		"status": "PASS_GODOT_CONTENT_ADAPTER_VALIDATION" if errors.is_empty() else "FAIL_GODOT_CONTENT_ADAPTER_VALIDATION",
		"generatedAtUtc": "deterministic-v0122",
		"errors": errors,
		"fixtureHash": hashes.get("fixtureHash"),
		"sourceAuthority": "generated portable JSON only",
		"requiredSubset": required_subset,
		"adapterReports": adapter_reports,
		"linkedWardDamageTakenMultiplier": scene_fixture.get("lume", {}).get("linkedWardDamageTakenMultiplier"),
		"readOnlySaveFixtures": true,
		"localStorageMutationAllowed": false,
		"saveWritesAllowed": false,
		"browserLocalStorageAccessed": false,
		"routineEditorUseRequired": false,
		"fullPortStarted": false
	}

func _adapter_report(adapter_name: String, errors: Array[String], extra: Dictionary = {}) -> Dictionary:
	var report := {
		"schemaVersion": 1,
		"adapter": adapter_name,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"textBasedAdapterLoaded": true,
		"routineEditorUseRequired": false
	}
	for key in extra.keys():
		report[key] = extra[key]
	return report

func _stable_id_adapter_report(stable_subset: Dictionary, registry, selected_ids: Array[String], unknown_probe_id: String) -> Dictionary:
	var errors: Array[String] = []
	var seen: Dictionary = {}
	var duplicate_ids: Array[String] = []
	var missing_ids: Array[String] = []
	var manifest_entries: Array = stable_subset.get("manifestEntries", [])
	for raw_entry in manifest_entries:
		if typeof(raw_entry) != TYPE_DICTIONARY:
			errors.append("Stable ID manifest contains a non-object entry.")
			continue
		var entry: Dictionary = raw_entry
		var id := str(entry.get("id", ""))
		var category := str(entry.get("category", ""))
		if id == "":
			errors.append("Stable ID manifest contains a missing id.")
			continue
		var pair := "%s:%s" % [category, id]
		if seen.has(pair):
			duplicate_ids.append(pair)
		seen[pair] = true
		if category != "" and registry.has_category(category) and not registry.has_id(category, id):
			errors.append("Stable ID %s:%s is absent from the generated content registry." % [category, id])
	for id in selected_ids:
		var value := str(id)
		var selected_found := false
		for pair in seen.keys():
			if str(pair).ends_with(":%s" % value):
				selected_found = true
				break
		if value == "" or not selected_found:
			missing_ids.append(value)
	if duplicate_ids.size() > 0:
		errors.append("Duplicate stable IDs: %s" % ", ".join(duplicate_ids))
	if missing_ids.size() > 0:
		errors.append("Missing selected stable IDs: %s" % ", ".join(missing_ids))
	var unknown_rejected := true
	for pair in seen.keys():
		if str(pair).ends_with(":%s" % unknown_probe_id):
			unknown_rejected = false
			break
	if not unknown_rejected:
		errors.append("Unknown probe ID was accepted: %s" % unknown_probe_id)
	return _adapter_report("StableIdValidator", errors, {
		"selectedStableIds": selected_ids,
		"selectedStableIdCount": selected_ids.size(),
		"knownStableIdCount": seen.size(),
		"duplicateIds": duplicate_ids,
		"missingIds": missing_ids,
		"unknownProbeId": unknown_probe_id,
		"unknownProbeRejected": unknown_rejected,
		"stableIdsRenamed": false
	})

func _save_fixture_adapter_report(save_fixture_index: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var fixtures: Array = save_fixture_index.get("fixtures", [])
	if int(save_fixture_index.get("currentSaveVersion", -1)) != 2:
		errors.append("Save fixture index must remain on save version 2.")
	if fixtures.is_empty():
		errors.append("Save fixture index is empty.")
	for raw_fixture in fixtures:
		if typeof(raw_fixture) != TYPE_DICTIONARY:
			errors.append("Save fixture index contains a non-object fixture.")
			continue
		var fixture: Dictionary = raw_fixture
		var id := str(fixture.get("id", ""))
		if id == "":
			errors.append("Save fixture contains a missing id.")
		if fixture.get("readOnly", false) != true:
			errors.append("Save fixture %s is not read-only." % id)
		if fixture.get("rawSaveIncludedInDesktopSpikeFixture", true) != false:
			errors.append("Save fixture %s includes raw save payload in the Godot spike." % id)
	return _adapter_report("SaveFixtureReadOnlyAdapter", errors, {
		"fixtureCount": fixtures.size(),
		"readOnlySaveFixtures": true,
		"saveWritesAllowed": false,
		"localStorageMutationAllowed": false,
		"browserLocalStorageAccessed": false
	})

func _unit_adapter_report(registry) -> Dictionary:
	var errors: Array[String] = []
	var player_units := ["worker", "militia", "ranger"]
	var enemy_units := ["raider", "hexer", "brute", "enemy_commander"]
	var missing: Array = registry.require_ids("units", player_units + enemy_units)
	if missing.size() > 0:
		errors.append("Missing unit definitions: %s" % ", ".join(missing))
	return _adapter_report("UnitDefinitionAdapter", errors, {
		"playerUnits": player_units,
		"enemyUnits": enemy_units,
		"workerReference": registry.get_entry("units", "worker").get("displayName", "Worker"),
		"deterministicOrdering": true
	})

func _building_adapter_report(registry) -> Dictionary:
	var errors: Array[String] = []
	var player_buildings := ["command_hall", "barracks"]
	var fixture_only_enemy_buildings := ["enemy_stronghold", "enemy_barracks"]
	var missing: Array = registry.require_ids("buildings", player_buildings)
	if missing.size() > 0:
		errors.append("Missing building definitions: %s" % ", ".join(missing))
	return _adapter_report("BuildingDefinitionAdapter", errors, {
		"playerBuildings": player_buildings,
		"fixtureOnlyEnemyBuildings": fixture_only_enemy_buildings,
		"fullBuildingMigrationClaimed": false
	})

func _site_adapter_report(registry) -> Dictionary:
	var errors: Array[String] = []
	var required_sites := ["west_stone_cut", "ford_toll", "north_aether_spring"]
	var missing: Array = registry.require_ids("captureSites", required_sites)
	if missing.size() > 0:
		errors.append("Missing site definitions: %s" % ", ".join(missing))
	return _adapter_report("SiteDefinitionAdapter", errors, {
		"mineEquivalentSiteId": "west_stone_cut",
		"shrineEquivalentSiteId": "ford_toll",
		"captureSiteId": "north_aether_spring"
	})

func _lume_adapter_report(registry, scene_fixture: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var required_lume := ["aether_well_ruins_lume_ward"]
	var missing: Array = registry.require_ids("lumeNetworks", required_lume)
	var lume: Dictionary = scene_fixture.get("lume", {})
	var linked_ward := float(lume.get("linkedWardDamageTakenMultiplier", -1.0))
	if missing.size() > 0:
		errors.append("Missing Lume definitions: %s" % ", ".join(missing))
	if abs(linked_ward - 0.92) > 0.00001:
		errors.append("linked_ward must remain exactly 0.92.")
	if str(lume.get("benefitId", "")) != "linked_ward":
		errors.append("Lume benefit must remain linked_ward.")
	return _adapter_report("LumeDefinitionAdapter", errors, {
		"networkId": lume.get("networkId", ""),
		"linkId": lume.get("linkId", ""),
		"benefitId": lume.get("benefitId", ""),
		"linkedWardDamageTakenMultiplier": linked_ward,
		"transitionStates": ["active", "severed", "restored"]
	})

func _results_adapter_report(results_contract: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var required_fields: Array[String] = [
		"outcome",
		"objective summary",
		"no-save marker",
		"Lume summary",
		"performance scorecard link",
		"return action"
	]
	var actual_fields: Array = results_contract.get("requiredFields", [])
	for field in required_fields:
		if not actual_fields.has(field):
			errors.append("Results contract missing field: %s" % field)
	if results_contract.get("saveMutationAllowed", true) != false:
		errors.append("Results contract must not allow save mutation.")
	if results_contract.get("rewardMutationAllowed", true) != false:
		errors.append("Results contract must not allow reward mutation.")
	if results_contract.get("localStorageMutationAllowed", true) != false:
		errors.append("Results contract must not allow localStorage mutation.")
	return _adapter_report("ResultsContractAdapter", errors, {
		"requiredFields": required_fields,
		"saveMutationAllowed": false,
		"rewardMutationAllowed": false,
		"localStorageMutationAllowed": false
	})

func _add_id(ids: Array[String], value: String) -> void:
	if value.length() > 0 and not ids.has(value):
		ids.append(value)

func _report(errors: Array[String], scene: Dictionary, validation: Dictionary, selected_ids: Array[String]) -> Dictionary:
	return {
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"scene": scene,
		"validation": validation,
		"selectedIds": selected_ids
	}
