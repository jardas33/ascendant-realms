extends RefCounted
class_name SaltoFixtureImporter

const GENERATED_DIR := "res://data/generated"
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
const UNKNOWN_PROBE_ID := "v0117_unknown_fixture_id_must_be_rejected"

func load_json(file_name: String) -> Variant:
	var path := "%s/%s" % [GENERATED_DIR, file_name]
	if not FileAccess.file_exists(path):
		return null
	var text := FileAccess.get_file_as_string(path)
	return JSON.parse_string(text)

func validate_fixture() -> Dictionary:
	var errors: Array[String] = []
	var loaded: Dictionary = {}
	for file_name in REQUIRED_JSON_FILES:
		var parsed: Variant = load_json(file_name)
		if parsed == null:
			errors.append("Missing or invalid generated fixture JSON: %s" % file_name)
		else:
			loaded[file_name] = parsed

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

	var validation: Dictionary = {
		"schemaVersion": 1,
		"checkpoint": "v0.117",
		"selectedStableIds": selected_ids,
		"selectedStableIdCount": selected_ids.size(),
		"missingSelectedStableIds": missing_ids,
		"unknownProbeId": UNKNOWN_PROBE_ID,
		"unknownProbeRejected": not stable_ids.has(UNKNOWN_PROBE_ID),
		"linkedWardDamageTakenMultiplier": linked_ward,
		"readOnlySaveFixtures": true,
		"localStorageMutationAllowed": false,
		"runtimeArtIntegrated": false
	}
	return _report(errors, scene, validation, selected_ids)

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
