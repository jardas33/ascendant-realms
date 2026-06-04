extends RefCounted
class_name ContentRegistryAdapter

const REQUIRED_CATEGORIES := [
	"abilities",
	"buildings",
	"captureSites",
	"factions",
	"lumeNetworks",
	"units"
]

var fixture_hash: Variant = null
var indexes: Dictionary = {}
var category_order: Dictionary = {}
var errors: Array[String] = []

func load_registry(content_subset: Dictionary, fixture_hashes: Dictionary = {}) -> Dictionary:
	fixture_hash = fixture_hashes.get("fixtureHash")
	indexes = {}
	category_order = {}
	errors = []
	var categories: Dictionary = content_subset.get("categories", {})
	if categories.is_empty():
		errors.append("Content subset is missing categories.")
	for category in REQUIRED_CATEGORIES:
		_index_category(category, categories.get(category, []))
	return validation_report()

func has_id(category: String, id: String) -> bool:
	return indexes.has(category) and (indexes[category] as Dictionary).has(id)

func has_category(category: String) -> bool:
	return indexes.has(category)

func require_ids(category: String, ids: Array) -> Array[String]:
	var missing: Array[String] = []
	for id in ids:
		var value := str(id)
		if value == "":
			missing.append("<missing-id>")
		elif not has_id(category, value):
			missing.append(value)
	return missing

func reject_unknown_id(category: String, id: String) -> bool:
	return not has_id(category, id)

func get_entry(category: String, id: String) -> Dictionary:
	if not has_id(category, id):
		return {}
	return (indexes[category] as Dictionary)[id]

func all_ids(category: String) -> Array:
	return category_order.get(category, [])

func validation_report() -> Dictionary:
	return {
		"schemaVersion": 1,
		"adapter": "ContentRegistryAdapter",
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"fixtureHash": fixture_hash,
		"categoryOrder": category_order,
		"deterministicOrdering": true,
		"localStorageMutationAllowed": false,
		"saveWritesAllowed": false
	}

func _index_category(category: String, entries: Array) -> void:
	var ids: Array[String] = []
	var index: Dictionary = {}
	for raw_entry in entries:
		if typeof(raw_entry) != TYPE_DICTIONARY:
			errors.append("%s contains a non-object entry." % category)
			continue
		var entry: Dictionary = raw_entry
		var id := str(entry.get("id", ""))
		if id == "":
			errors.append("%s contains a missing id." % category)
			continue
		if index.has(id):
			errors.append("%s contains duplicate id %s." % [category, id])
			continue
		index[id] = entry
		ids.append(id)
	var sorted_ids := ids.duplicate()
	sorted_ids.sort()
	indexes[category] = index
	category_order[category] = sorted_ids
