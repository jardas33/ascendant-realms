extends RefCounted
class_name BuildPlacementValidationAdapter

const CONTENT_PATH := "res://data/generated/content-subset.json"
const MAP_ID := "broken_ford"
const BUILD_RADIUS := 560.0

var source_map: Dictionary = {}
var building_definitions: Dictionary = {}
var errors: Array[String] = []


func load_authority() -> Dictionary:
	errors.clear()
	source_map = {}
	building_definitions.clear()
	if not FileAccess.file_exists(CONTENT_PATH):
		errors.append("Missing generated portable content subset.")
		return status()
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(CONTENT_PATH))
	if not parsed is Dictionary:
		errors.append("Generated portable content subset is invalid.")
		return status()
	var categories: Dictionary = parsed.get("categories", {})
	for raw_entry in categories.get("buildings", []):
		if raw_entry is Dictionary:
			var entry: Dictionary = raw_entry
			var data: Dictionary = entry.get("data", {})
			building_definitions[str(entry.get("id", ""))] = data
	for raw_entry in categories.get("maps", []):
		if raw_entry is Dictionary and str(raw_entry.get("id", "")) == MAP_ID:
			source_map = raw_entry.get("data", {})
			break
	if source_map.is_empty():
		errors.append("Generated portable content subset is missing map %s." % MAP_ID)
	if not building_definitions.has("barracks"):
		errors.append("Generated portable content subset is missing Barracks.")
	return status()


func evaluate(point: Vector2, building_id: String, resources: Dictionary) -> Dictionary:
	if source_map.is_empty() or building_definitions.is_empty():
		load_authority()
	if not errors.is_empty():
		return _result(false, "adapter-unavailable", point, building_id)
	var definition: Dictionary = building_definitions.get(building_id, {})
	if definition.is_empty():
		return _result(false, "unknown-building", point, building_id)
	var size_data: Dictionary = definition.get("size", {})
	var size := Vector2(float(size_data.get("width", 0.0)), float(size_data.get("height", 0.0)))
	var footprint := Rect2(point - size * 0.5, size)
	if not _can_afford(resources, definition.get("cost", {})):
		return _result(false, "missing-resources", point, building_id)
	if footprint.position.x < 0.0 or footprint.position.y < 0.0 or footprint.end.x > float(source_map.get("width", 0.0)) or footprint.end.y > float(source_map.get("height", 0.0)):
		return _result(false, "outside-map", point, building_id)
	for zone in source_map.get("terrainZones", []):
		if str(zone.get("type", "")) in ["blocked", "water"] and footprint.intersects(_zone_rect(zone), false):
			return _result(false, "blocked-terrain", point, building_id)
	var buildable := false
	for zone in source_map.get("terrainZones", []):
		if str(zone.get("type", "")) == "buildable" and _rect_contains(_zone_rect(zone), footprint):
			buildable = true
			break
	if not buildable:
		return _result(false, "not-buildable-terrain", point, building_id)
	var near_owned := false
	for spawn in source_map.get("scenario", {}).get("buildingSpawns", []):
		if str(spawn.get("team", "")) == "player" and point.distance_to(Vector2(float(spawn.get("x", 0.0)), float(spawn.get("y", 0.0)))) <= BUILD_RADIUS:
			near_owned = true
			break
	if not near_owned:
		return _result(false, "too-far-from-owned-building", point, building_id)
	var half_extent := maxf(size.x, size.y) * 0.5
	for spawn in source_map.get("scenario", {}).get("buildingSpawns", []):
		var other_id := str(spawn.get("buildingId", ""))
		var other: Dictionary = building_definitions.get(other_id, {})
		var other_size: Dictionary = other.get("size", {})
		var radius := maxf(float(other_size.get("width", 0.0)), float(other_size.get("height", 0.0))) * 0.5
		var other_point := Vector2(float(spawn.get("x", 0.0)), float(spawn.get("y", 0.0)))
		if point.distance_to(other_point) < radius + half_extent + 12.0:
			return _result(false, "overlaps-building", point, building_id)
	for site in source_map.get("captureSites", []):
		var site_point := Vector2(float(site.get("x", 0.0)), float(site.get("y", 0.0)))
		if point.distance_to(site_point) < float(site.get("radius", 0.0)) + half_extent:
			return _result(false, "overlaps-capture-site", point, building_id)
	return _result(true, "", point, building_id)


func definition(building_id: String) -> Dictionary:
	if source_map.is_empty() or building_definitions.is_empty():
		load_authority()
	return (building_definitions.get(building_id, {}) as Dictionary).duplicate(true)


func reason_text(reason: String) -> String:
	match reason:
		"missing-resources":
			return "Insufficient resources."
		"outside-map":
			return "Outside the battlefield."
		"blocked-terrain":
			return "Blocked terrain."
		"not-buildable-terrain":
			return "Not buildable terrain."
		"too-far-from-owned-building":
			return "Too far from an owned building."
		"overlaps-building":
			return "Overlaps another structure."
		"overlaps-capture-site":
			return "Overlaps a resource site."
		_:
			return "Invalid building site."


func source_to_runtime_world(point: Vector2) -> Vector3:
	var width := maxf(1.0, float(source_map.get("width", 2600.0)))
	var height := maxf(1.0, float(source_map.get("height", 1700.0)))
	return Vector3((point.x / width - 0.5) * 13.0, 0.22, (point.y / height - 0.5) * 10.0)


func status() -> Dictionary:
	return {
		"adapter": "BuildPlacementValidationAdapter",
		"status": "PASS" if errors.is_empty() and not source_map.is_empty() else "FAIL",
		"sourcePath": CONTENT_PATH,
		"mapId": MAP_ID,
		"ruleAuthority": "src/game/systems/BuildingPlacementRules.ts via generated portable content",
		"checkOrder": [
			"missing-resources", "outside-map", "blocked-terrain", "not-buildable-terrain",
			"too-far-from-owned-building", "overlaps-building", "overlaps-capture-site",
		],
		"readOnly": true,
		"mutatesGameplay": false,
		"errors": errors.duplicate(),
	}


func _result(ok: bool, reason: String, point: Vector2, building_id: String) -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"reasonText": "Valid %s site." % building_id.capitalize() if ok else reason_text(reason),
		"point": {"x": point.x, "y": point.y},
		"buildingId": building_id,
		"sourceMapId": MAP_ID,
		"realRuleData": true,
		"readOnly": true,
	}


func _can_afford(resources: Dictionary, cost: Dictionary) -> bool:
	for key in cost:
		if int(resources.get(key, 0)) < int(cost[key]):
			return false
	return true


func _zone_rect(zone: Dictionary) -> Rect2:
	return Rect2(
		float(zone.get("x", 0.0)),
		float(zone.get("y", 0.0)),
		float(zone.get("width", 0.0)),
		float(zone.get("height", 0.0))
	)


func _rect_contains(outer: Rect2, inner: Rect2) -> bool:
	return inner.position.x >= outer.position.x and inner.end.x <= outer.end.x and inner.position.y >= outer.position.y and inner.end.y <= outer.end.y
