extends RefCounted
class_name StableIdValidator

func validate_adapter(stable_subset: Dictionary, registry, selected_ids: Array, unknown_probe_id: String) -> Dictionary:
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
		if category != "" and not registry.has_id(category, id):
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
	var unknown_rejected := not seen.has(unknown_probe_id)
	if not unknown_rejected:
		errors.append("Unknown probe ID was accepted: %s" % unknown_probe_id)
	return {
		"schemaVersion": 1,
		"adapter": "StableIdValidator",
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"selectedStableIds": selected_ids,
		"selectedStableIdCount": selected_ids.size(),
		"knownStableIdCount": seen.size(),
		"duplicateIds": duplicate_ids,
		"missingIds": missing_ids,
		"unknownProbeId": unknown_probe_id,
		"unknownProbeRejected": unknown_rejected,
		"stableIdsRenamed": false
	}
