extends RefCounted
class_name SaveFixtureReadOnlyAdapter

func validate_adapter(save_fixture_index: Dictionary) -> Dictionary:
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
	return {
		"schemaVersion": 1,
		"adapter": "SaveFixtureReadOnlyAdapter",
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"fixtureCount": fixtures.size(),
		"readOnlySaveFixtures": true,
		"saveWritesAllowed": false,
		"localStorageMutationAllowed": false,
		"browserLocalStorageAccessed": false
	}
