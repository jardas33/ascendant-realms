extends Node
## Director-authorized headed runtime gate for Barrosan Iron Forge B01 R1/R2.
## Uses the live build command, verifies the unchanged gameplay envelope, then
## captures a matched legacy-vs-candidate view at the required RTS zooms.

const BUILDING_ID := "barrosan_iron_forge"
const B01_MODEL_TEMPLATE := "res://assets/environment/buildings/barrosan_iron_forge_b01_%s.glb"
const LEGACY_MODEL := "res://assets/environment/buildings/barrosan_iron_forge.glb"
const TARGET_HEIGHT := 4.6
const TEST_WIDTH := 1920
const TEST_HEIGHT := 1080
const MIN_CARDINAL_ENDPOINT_CLEARANCE := 1.2
const MIN_HQ_ENDPOINT_CLEARANCE := 8.0
const MIN_HQ_FOOTPRINT_GAP := 2.0
const MIN_RESOURCE_CLEARANCE := 1.2
const MIN_PROP_CLEARANCE := 1.2
const REPRESENTATIVE_SITE_RADII := [22.0, 24.0, 26.0]
const REPRESENTATIVE_SITE_ANGLE := 5.0 * PI / 4.0
const PROP_BLOCKER_CLASSES := ["ENVIRONMENT_PROP", "ASTRA_LARGE", "BRIDGE_STRUCTURE"]
const CARDINALS := [
	{"name": "east", "offset": Vector3(8.5, 0.0, 0.0)},
	{"name": "south", "offset": Vector3(0.0, 0.0, 8.5)},
	{"name": "west", "offset": Vector3(-8.5, 0.0, 0.0)},
	{"name": "north", "offset": Vector3(0.0, 0.0, -8.5)},
]
const PERIMETER_SEQUENCE := ["east", "south", "west", "north", "east"]
const EXPECTED_STATS := {
	"race": "barrosan", "name": "Iron Forge", "kind": "economy",
	"hp": 700, "armor_class": "medium", "armor": 3, "footprint": 4.0,
	"cost": {"timber": 100, "stone": 80}, "build_time": 28,
	"grants_pop": 0, "is_research": true, "produces": [],
	"research": ["tech_weapons", "tech_armor"],
}
const SHARED_FORGE_CONSUMERS := [
	"karak_anvil", "sunspear_bazaar", "sunspear_temple", "frostborn_runeforge",
]

var output_root := ""
var phase_file: FileAccess
var world: Node
var rts: Node
var worker: Node
var forge: Node
var legacy_preview: Node
var failures: Array[String] = []
var route_results: Array[Dictionary] = []
var frame_results: Array[Dictionary] = []
var frame_images: Dictionary = {}
var site_selection_audit: Dictionary = {}
var pickability_audit: Dictionary = {}
var candidate_revision := "r1"
var candidate_model_path := ""
var candidate_label := "B01_R1"

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var requested_revision := OS.get_environment("BARROSAN_B01_REVISION").strip_edges().to_lower()
	if not requested_revision.is_empty():
		candidate_revision = requested_revision
	candidate_model_path = B01_MODEL_TEMPLATE % candidate_revision
	candidate_label = "B01_%s" % candidate_revision.to_upper()
	output_root = OS.get_environment("BARROSAN_B01_RUNTIME_OUT")
	if output_root.is_empty():
		if candidate_revision == "r1":
			output_root = OS.get_environment("BARROSAN_B01_R1_RUNTIME_OUT")
		if output_root.is_empty():
			output_root = "D:/CodexData/evidence/barrosan-iron-forge-original-b01-%s-20260925/runtime-headed-%s" % [candidate_revision, candidate_revision]
	DirAccess.make_dir_recursive_absolute(output_root)
	phase_file = FileAccess.open(output_root.path_join("runtime-phases.jsonl"), FileAccess.WRITE)
	var match_config: Node = get_tree().root.get_node_or_null("Match")
	if match_config:
		match_config.set_config({
			"player_race": "barrosan", "opponents": [{"race": "lioraen", "difficulty": "easy"}],
			"map": "hollowspan", "start_resources": "standard", "victory": "conquest",
			"mode": "skirmish", "game_speed": 1.0,
		})

func _ready() -> void:
	call_deferred("_run")

func _phase(name: String, fields: Dictionary = {}) -> void:
	var row := {
		"phase": name,
		"timestamp": Time.get_datetime_string_from_system(true),
		"monotonic_seconds": Time.get_ticks_msec() / 1000.0,
		"engine_frame": Engine.get_process_frames(),
	}
	row.merge(fields)
	if phase_file:
		phase_file.store_line(JSON.stringify(row))
		phase_file.flush()
	print(JSON.stringify(row))

func _write_json(name: String, value: Dictionary) -> void:
	var file := FileAccess.open(output_root.path_join(name), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
		file.close()

func _wait_until(predicate: Callable, timeout_seconds: float) -> bool:
	var started := Time.get_ticks_msec()
	while Time.get_ticks_msec() - started < int(timeout_seconds * 1000.0):
		if predicate.call():
			return true
		await get_tree().process_frame
	return bool(predicate.call())

func _run() -> void:
	if candidate_revision not in ["r1", "r2"]:
		await _finish(false, "unsupported_candidate_revision")
		return
	_phase("DRIVER_ENTRY", {
		"worktree_branch": "codex/barrosan-iron-forge-original-b01-r1",
		"candidate_revision": candidate_revision,
		"candidate_model_path": candidate_model_path,
		"viewport_target": {"width": TEST_WIDTH, "height": TEST_HEIGHT},
		"output_root": output_root,
	})
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(TEST_WIDTH, TEST_HEIGHT))
	var ready := await _wait_until(func():
		var root := get_parent()
		var candidate_world = root.get_node_or_null("GameWorld") if root else null
		return candidate_world != null and candidate_world.game_running and candidate_world.commanders.size() >= 2
	, 45.0)
	if not ready:
		await _finish(false, "production_runtime_not_ready")
		return
	var root := get_parent()
	world = root.get_node("GameWorld")
	rts = root.get_node("RTS")
	for _frame in 12:
		await get_tree().process_frame
	_phase("PRODUCTION_RUNTIME_READY", {
		"scene": "res://scenes/game_world.tscn",
		"runtime_identity": world.get_runtime_identity_snapshot(),
		"window_size": _vec2i(DisplayServer.window_get_size()),
		"root_viewport_size": _vec2i(get_tree().root.size),
		"navigation_ready": world.is_navigation_ready(),
	})
	if get_tree().root.size != Vector2i(TEST_WIDTH, TEST_HEIGHT):
		failures.append("viewport_not_1920x1080")
	if not _verify_definitions():
		await _finish(false, "definition_or_shared_asset_contract_failed")
		return
	if not await _build_through_player_command():
		var build_failure_reason := "normal_player_construction_failed" if bool(site_selection_audit.get("passed", false)) else "site_clearance_precheck_failed"
		await _finish(false, build_failure_reason)
		return
	var routes_passed := await _verify_access_routes()
	var pickability_passed := await _verify_pickability()
	await _capture_matched_views()
	var passed := routes_passed and pickability_passed and bool(site_selection_audit.get("passed", false)) and failures.is_empty() and frame_results.size() == 4
	var reason := "runtime_fit_and_matched_captures_passed" if passed else ("principal_side_worker_access_failed" if not routes_passed else "runtime_assertions_failed")
	await _finish(passed, reason)

func _verify_definitions() -> bool:
	var game_data: Node = get_tree().root.get_node_or_null("GameData")
	if not game_data:
		failures.append("autoload_game_data_missing")
		return false
	var current: Dictionary = game_data.get_building(BUILDING_ID)
	var field_errors: Array[String] = []
	for key in EXPECTED_STATS:
		if current.get(key) != EXPECTED_STATS[key]:
			field_errors.append("%s:%s!=%s" % [key, str(current.get(key)), str(EXPECTED_STATS[key])])
	if String(current.get("model", "")) != candidate_model_path:
		field_errors.append("barrosan_model_pointer_mismatch")
	for shared_id in SHARED_FORGE_CONSUMERS:
		var shared: Dictionary = game_data.get_building(shared_id)
		if shared.is_empty() or String(shared.get("model", "")) != LEGACY_MODEL:
			field_errors.append("shared_legacy_model_changed:%s" % shared_id)
	var expected_report := {
		"candidate_definition": current.duplicate(true),
		"expected_gameplay_fields": EXPECTED_STATS,
		"shared_legacy_consumers": SHARED_FORGE_CONSUMERS,
		"field_errors": field_errors,
	}
	_write_json("definition-and-shared-use-audit.json", expected_report)
	_phase("DEFINITION_AUDIT", expected_report)
	if not field_errors.is_empty():
		failures.append_array(field_errors)
	return field_errors.is_empty()

func _find_worker() -> Node:
	for unit in world.commanders[0].units:
		if is_instance_valid(unit) and not unit.is_dead and unit.is_worker and unit.state != unit.State.BUILDING:
			return unit
	return null

func _find_build_position() -> Vector3:
	var hq = _find_headquarters()
	if not hq:
		site_selection_audit = {"passed": false, "status": "HEADQUARTERS_MISSING", "candidate_attempts": []}
		return Vector3(INF, 0.0, INF)
	var attempts: Array[Dictionary] = []
	for radius in REPRESENTATIVE_SITE_RADII:
		var position: Vector3 = hq.global_position + Vector3(cos(REPRESENTATIVE_SITE_ANGLE) * radius, 0.0, sin(REPRESENTATIVE_SITE_ANGLE) * radius)
		var report := _audit_build_site_candidate(position, hq, float(EXPECTED_STATS["footprint"]))
		report["radius_from_hq"] = radius
		attempts.append(report.duplicate(true))
		if bool(report.get("passed", false)):
			site_selection_audit = {
				"passed": true,
				"status": "OBJECTIVE_PRECHECK_PASS",
				"selection_rule": "fixed southwest radial line; inspect 22m then 24m then 26m; select first site passing every predeclared gate",
				"candidate_attempts": attempts,
				"selected": report,
			}
			return position
	site_selection_audit = {
		"passed": false,
		"status": "NO_PREDECLARED_SITE_PASSED_OBJECTIVE_SCREEN",
		"selection_rule": "fixed southwest radial line; inspect 22m then 24m then 26m; no post-outcome site search",
		"candidate_attempts": attempts,
	}
	return Vector3(INF, 0.0, INF)

func _find_headquarters():
	for building in world.commanders[0].buildings:
		if is_instance_valid(building) and bool(building.def.get("is_hq", false)):
			return building
	return null

func _audit_build_site_candidate(position: Vector3, hq: Node, footprint: float) -> Dictionary:
	var placement_reason: String = world.get_building_placement_reason(BUILDING_ID, 0, position, true, worker)
	if not placement_reason.is_empty():
		return {"position": _vec3(position), "passed": false, "placement_legal": false, "placement_reason": placement_reason}
	var blockers: Array[Dictionary] = world._navigation_blocker_snapshots()
	var hq_blocker: Dictionary = {}
	for blocker in blockers:
		if blocker.get("owner") == hq or blocker.get("node") == hq:
			hq_blocker = blocker
			break
	if hq_blocker.is_empty():
		return {"position": _vec3(position), "passed": false, "placement_legal": true, "reason": "hq_world_blocker_missing_from_route_snapshot"}

	var hq_center: Vector3 = hq_blocker.get("center", hq.global_position)
	var hq_extents: Vector2 = hq_blocker.get("half_extents", Vector2.ZERO)
	var candidate_half := Vector2(footprint, footprint)
	var hq_footprint_gap := _rectangle_clearance(position, candidate_half, hq_center, hq_extents)
	var clearance := float(worker._building_route_clearance())
	var endpoint_audits: Array[Dictionary] = []
	var endpoint_minimum := INF
	var hq_endpoint_minimum := INF
	var resource_minimum := INF
	var prop_minimum := INF
	var navigable_count := 0
	var complete_route_chain_count := 0
	var origin_blocker_report: Dictionary = {}
	var side_route_gates := {}
	for side in CARDINALS:
		var target: Vector3 = position + side.offset
		var endpoint_clearance := _minimum_point_clearance(target, blockers)
		var hq_clearance := _point_rectangle_clearance(target, hq_center, hq_extents)
		var resource_clearance := _minimum_point_clearance(target, blockers, ["RESOURCE_NODE"])
		var prop_clearance := _minimum_point_clearance(target, blockers, PROP_BLOCKER_CLASSES)
		endpoint_minimum = minf(endpoint_minimum, endpoint_clearance)
		hq_endpoint_minimum = minf(hq_endpoint_minimum, hq_clearance)
		resource_minimum = minf(resource_minimum, resource_clearance) if resource_clearance >= 0.0 else resource_minimum
		prop_minimum = minf(prop_minimum, prop_clearance) if prop_clearance >= 0.0 else prop_minimum

		var nav_snapshot: Dictionary = world.navigation_target_snapshot(target)
		var route: Array = world.navigation_waypoints_for_unit(worker.global_position, target, clearance, null, "PLAYER_MOVE")
		var route_segments_clear := not route.is_empty()
		var segment_audits: Array[Dictionary] = []
		var previous: Vector3 = worker.global_position
		var origin_blocker: Dictionary = _origin_blocker_exemption(previous, blockers, clearance)
		var origin_exemption_node = origin_blocker.get("node") if not origin_blocker.is_empty() else null
		if origin_blocker_report.is_empty() and not origin_blocker.is_empty():
			origin_blocker_report = {
				"object_id": origin_blocker.get("object_id", ""),
				"object_class": origin_blocker.get("object_class", ""),
				"source": origin_blocker.get("source", ""),
				"center": _vec3(origin_blocker.get("center", Vector3.ZERO)),
				"half_extents": _vec2(origin_blocker.get("half_extents", Vector2.ZERO)),
			}
		var segment_index := 0
		for waypoint_value in route:
			var waypoint: Vector3 = waypoint_value
			var segment_exemption = origin_exemption_node if segment_index == 0 else null
			var helper_clear: bool = world._segment_clear_of_active_route_blockers(previous, waypoint, blockers, clearance, segment_exemption)
			var intersections: Array[Dictionary] = []
			for blocker in blockers:
				if blocker.get("node") == segment_exemption:
					continue
				var blocker_center: Vector3 = blocker.get("center", Vector3.ZERO)
				var expanded_extents: Vector2 = world._route_blocker_half_extents(blocker, clearance)
				if world._segment_enters_route_rectangle(previous, waypoint, blocker_center, expanded_extents):
					intersections.append({"object_id": blocker.get("object_id", ""), "object_class": blocker.get("object_class", ""), "source": blocker.get("source", ""), "center": _vec3(blocker_center), "expanded_half_extents": _vec2(expanded_extents)})
			if not helper_clear:
				route_segments_clear = false
			segment_audits.append({"from": _vec3(previous), "to": _vec3(waypoint), "helper_clear": helper_clear, "origin_escape_exemption_applied": segment_index == 0 and not origin_blocker.is_empty(), "exempted_origin_blocker": origin_blocker_report, "intersections": intersections})
			previous = waypoint
			segment_index += 1
		var route_reaches_target: bool = not route.is_empty() and route.back().distance_to(target) <= 0.15
		if route_reaches_target:
			complete_route_chain_count += 1
		var projection_distance := float(nav_snapshot.get("projection_distance", INF))
		var navigable: bool = bool(nav_snapshot.get("ready", false)) and projection_distance <= 1.2 and route_segments_clear and route_reaches_target
		if navigable:
			navigable_count += 1
		side_route_gates["%s_ROUTE_SEGMENTS" % String(side.name).to_upper()] = "PASS" if route_segments_clear else "FAIL"
		endpoint_audits.append({
			"side": side.name,
			"target": _vec3(target),
			"endpoint_clearance_m": endpoint_clearance,
			"hq_endpoint_clearance_m": hq_clearance,
			"resource_endpoint_clearance_m": resource_clearance,
			"prop_endpoint_clearance_m": prop_clearance,
			"endpoint_clearance_passed": endpoint_clearance >= MIN_CARDINAL_ENDPOINT_CLEARANCE,
			"navigation_target": nav_snapshot.get("ready", false),
			"projection_distance_m": projection_distance,
			"route_waypoints": route.map(func(point): return _vec3(point)),
			"route_segments_clear": route_segments_clear,
			"route_segment_audits": segment_audits,
			"route_reaches_target": route_reaches_target,
			"origin_containing_blocker_found": not origin_blocker.is_empty(),
			"origin_escape_exemption_applied": not origin_blocker.is_empty() and not route.is_empty(),
			"exempted_origin_blocker": origin_blocker_report,
			"navigable": navigable,
		})

	var resource_site_clearance := _minimum_class_rectangle_clearance(position, candidate_half, blockers, ["RESOURCE_NODE"])
	var prop_site_clearance := _minimum_class_rectangle_clearance(position, candidate_half, blockers, PROP_BLOCKER_CLASSES)
	var resource_gate := (resource_site_clearance < 0.0 or resource_site_clearance >= MIN_RESOURCE_CLEARANCE) and (resource_minimum == INF or resource_minimum >= MIN_RESOURCE_CLEARANCE)
	var prop_gate := (prop_site_clearance < 0.0 or prop_site_clearance >= MIN_PROP_CLEARANCE) and (prop_minimum == INF or prop_minimum >= MIN_PROP_CLEARANCE)
	var hq_gate := hq_footprint_gap >= MIN_HQ_FOOTPRINT_GAP and hq_endpoint_minimum >= MIN_HQ_ENDPOINT_CLEARANCE
	var cardinal_gate := endpoint_minimum >= MIN_CARDINAL_ENDPOINT_CLEARANCE
	var passed := cardinal_gate and hq_gate and resource_gate and prop_gate and navigable_count == CARDINALS.size()
	var side_gates := {}
	for row in endpoint_audits:
		var side_key := String(row.side).to_upper()
		side_gates["CARDINAL_ENDPOINT_CLEARANCE_%s" % side_key] = "PASS" if bool(row.endpoint_clearance_passed) else "FAIL"
	var report := {
		"position": _vec3(position),
		"placement_legal": true,
		"placement_reason": "",
		"cardinal_endpoints": endpoint_audits,
		"minimum_cardinal_endpoint_clearance_m": endpoint_minimum,
		"minimum_hq_cardinal_endpoint_clearance_m": hq_endpoint_minimum,
		"hq_footprint_gap_m": hq_footprint_gap,
		"minimum_resource_endpoint_clearance_m": -1.0 if resource_minimum == INF else resource_minimum,
		"minimum_resource_footprint_clearance_m": resource_site_clearance,
		"minimum_prop_endpoint_clearance_m": -1.0 if prop_minimum == INF else prop_minimum,
		"minimum_prop_footprint_clearance_m": prop_site_clearance,
		"HQ_CORRIDOR_CLEARANCE": "PASS" if hq_gate else "FAIL",
		"RESOURCE_BLOCKER_CLEARANCE": "PASS" if resource_gate else "FAIL",
		"PROP_BLOCKER_CLEARANCE": "PASS" if prop_gate else "FAIL",
		"ORIGIN_CONTAINING_BLOCKER_FOUND": "YES" if not origin_blocker_report.is_empty() else "NO",
		"ORIGIN_ESCAPE_EXEMPTION_APPLIED": "YES" if not origin_blocker_report.is_empty() else "NO",
		"EXEMPTED_BLOCKER": origin_blocker_report,
		"PRODUCTION_ROUTE_CHAINS_COMPLETE": complete_route_chain_count,
		"NAVIGABLE_CARDINAL_TARGETS": navigable_count,
		"required_cardinal_route_count": CARDINALS.size(),
		"cardinal_endpoint_clearance_gates": side_gates,
		"cardinal_route_segment_gates": side_route_gates,
		"passed": passed,
	}
	report.merge(side_gates)
	report.merge(side_route_gates)
	return report

func _origin_blocker_exemption(origin: Vector3, blockers: Array[Dictionary], clearance: float) -> Dictionary:
	var closest_blocker: Dictionary = {}
	var closest_distance := INF
	for blocker in blockers:
		var center: Vector3 = blocker.get("center", Vector3.ZERO)
		var expanded: Vector2 = world._route_blocker_half_extents(blocker, clearance)
		if world._point_inside_route_rectangle(origin, center, expanded):
			var distance := origin.distance_to(center)
			if distance < closest_distance:
				closest_blocker = blocker
				closest_distance = distance
	return closest_blocker

func _point_rectangle_clearance(point: Vector3, center: Vector3, extents: Vector2) -> float:
	var dx := maxf(absf(point.x - center.x) - extents.x, 0.0)
	var dz := maxf(absf(point.z - center.z) - extents.y, 0.0)
	return sqrt(dx * dx + dz * dz)

func _minimum_point_clearance(point: Vector3, blockers: Array[Dictionary], classes: Array = []) -> float:
	var minimum := INF
	for blocker in blockers:
		if not classes.is_empty() and not classes.has(String(blocker.get("object_class", ""))):
			continue
		var center: Vector3 = blocker.get("center", Vector3.ZERO)
		var extents: Vector2 = blocker.get("half_extents", Vector2.ZERO)
		minimum = minf(minimum, _point_rectangle_clearance(point, center, extents))
	return -1.0 if minimum == INF else minimum

func _rectangle_clearance(first_center: Vector3, first_extents: Vector2, second_center: Vector3, second_extents: Vector2) -> float:
	var dx := maxf(absf(first_center.x - second_center.x) - first_extents.x - second_extents.x, 0.0)
	var dz := maxf(absf(first_center.z - second_center.z) - first_extents.y - second_extents.y, 0.0)
	return sqrt(dx * dx + dz * dz)

func _minimum_class_rectangle_clearance(position: Vector3, footprint_half: Vector2, blockers: Array[Dictionary], classes: Array) -> float:
	var minimum := INF
	for blocker in blockers:
		if not classes.has(String(blocker.get("object_class", ""))):
			continue
		var center: Vector3 = blocker.get("center", Vector3.ZERO)
		var extents: Vector2 = blocker.get("half_extents", Vector2.ZERO)
		minimum = minf(minimum, _rectangle_clearance(position, footprint_half, center, extents))
	return -1.0 if minimum == INF else minimum

func _build_through_player_command() -> bool:
	worker = _find_worker()
	if not worker:
		failures.append("available_worker_missing")
		return false
	var build_position := _find_build_position()
	_phase("BUILD_SITE_SELECTION", site_selection_audit)
	if not is_finite(build_position.x):
		failures.append("valid_base_adjacent_build_site_missing")
		return false
	var commander = world.commanders[0]
	var resources_before: Dictionary = commander.resources.duplicate(true)
	rts._clear_selection()
	rts._add_to_selection(worker)
	rts.emit_signal("selection_changed", rts.selected)
	rts.enter_build_mode(BUILDING_ID)
	if String(rts._build_id) != BUILDING_ID:
		failures.append("normal_build_mode_not_entered")
		return false
	var reason: String = world.get_building_placement_reason(BUILDING_ID, 0, build_position, true, worker)
	if not reason.is_empty():
		failures.append("site_invalid_at_transaction:%s" % reason)
		return false
	var accepted: bool = rts._try_place_building_at(build_position)
	if not accepted:
		failures.append("rts_player_placement_rejected")
		return false
	for building in commander.buildings:
		if is_instance_valid(building) and building.building_id == BUILDING_ID and building.global_position.distance_to(build_position) < 0.05:
			forge = building
			break
	if not is_instance_valid(forge):
		failures.append("normal_transaction_did_not_create_forge")
		return false
	var expected_after := resources_before.duplicate(true)
	expected_after["timber"] = int(expected_after.get("timber", 0)) - int(EXPECTED_STATS.cost.timber)
	expected_after["stone"] = int(expected_after.get("stone", 0)) - int(EXPECTED_STATS.cost.stone)
	var resources_after: Dictionary = commander.resources.duplicate(true)
	if resources_after != expected_after:
		failures.append("resource_debit_not_exactly_once")
	var blocker_half_extents: Vector2 = world._building_world_blocker_half_extents(forge)
	var geometry: Dictionary = forge.get_selection_geometry()
	var collision_shapes: int = forge.model_root.find_children("*", "CollisionShape3D", true, false).size()
	var definition_valid: bool = String(forge.def.get("id", "")) == BUILDING_ID and forge.building_id == BUILDING_ID
	if blocker_half_extents.distance_to(Vector2(4.0, 4.0)) > 0.001:
		failures.append("world_navigation_blocker_changed:%s" % str(blocker_half_extents))
	if forge.collision_layer != 4 or forge.collision_mask != 0:
		failures.append("building_collision_layer_contract_changed")
	if collision_shapes <= 0:
		failures.append("standard_per_part_model_collision_missing")
	if not definition_valid or String(forge.def.get("model", "")) != candidate_model_path:
		failures.append("placed_building_identity_or_model_mismatch")
	var model_instance: Node3D = forge.model_root.get_child(0) as Node3D if forge.model_root.get_child_count() > 0 else null
	var measured_height := ModelUtils.measure_height(model_instance) if model_instance else 0.0
	if absf(measured_height - TARGET_HEIGHT) > 0.08:
		failures.append("runtime_presentation_height_out_of_tolerance:%.3f" % measured_height)
	_phase("NORMAL_PLACEMENT_ACCEPTED", {
		"building_runtime_id": str(forge.get_instance_id()),
		"unit_runtime_id": str(worker.get_instance_id()),
		"building_id": forge.building_id,
		"model_path": forge.def.get("model", ""),
		"position": _vec3(forge.global_position),
		"resources_before": resources_before,
		"resources_after": resources_after,
		"expected_resources_after": expected_after,
		"is_built": forge.is_built,
		"build_time_seconds": forge.build_time,
		"model_height_m": measured_height,
		"visual_extents": geometry.get("visual_extents", {}),
		"world_blocker_half_extents": _vec2(blocker_half_extents),
		"building_collision_layer": forge.collision_layer,
		"building_collision_mask": forge.collision_mask,
		"per_part_collision_shape_count": collision_shapes,
		"world_blocker_contract": _matching_blocker_record(forge),
	})
	if not failures.is_empty():
		return false
	var deadline := Time.get_ticks_msec() + 75000
	var last_log := 0
	while not forge.is_built and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
		if Time.get_ticks_msec() - last_log >= 2500:
			last_log = Time.get_ticks_msec()
			_phase("CONSTRUCTION_PROGRESS", {
				"progress": float(forge.build_progress),
				"worker_state": int(worker.state),
				"worker_position": _vec3(worker.global_position),
			})
	if not forge.is_built:
		failures.append("normal_construction_completion_timeout")
		return false
	if absf(float(forge.build_progress) - 1.0) > 0.001:
		failures.append("construction_completion_progress_not_one")
	_phase("CONSTRUCTION_COMPLETED", {
		"building_runtime_id": str(forge.get_instance_id()),
		"is_built": forge.is_built,
		"build_progress": forge.build_progress,
		"worker_state": int(worker.state),
		"worker_position": _vec3(worker.global_position),
		"construction_events": world.construction_events.duplicate(true),
	})
	return failures.is_empty()

func _matching_blocker_record(building: Node) -> Dictionary:
	for blocker in world._world_blocker_records.values():
		if blocker.get("owner") == building:
			return {
				"source": blocker.get("source", ""),
				"half_extents": _vec2(blocker.get("half_extents", Vector2.ZERO)),
				"physics_body": is_instance_valid(blocker.get("body")),
				"navigation_obstacle": is_instance_valid(blocker.get("obstacle")),
			}
	return {}

func _verify_access_routes() -> bool:
	if not await _wait_until(func(): return world.is_navigation_ready(), 25.0):
		failures.append("navigation_not_ready_for_access_test")
		return false
	_phase("NEARBY_ROUTE_BLOCKERS", {"candidate_center": _vec3(forge.global_position), "north_approach": _vec3(forge.global_position + Vector3(0.0, 0.0, -8.5)), "blockers": _nearby_route_blockers()})
	rts._clear_selection()
	var geometry: Dictionary = forge.get_selection_geometry()
	var mass_data: Dictionary = geometry.get("visual_extents", {})
	var major_mass_half := Vector2(float(mass_data.get("x", 0.0)), float(mass_data.get("z", 0.0)))
	var collision_before: Array[Dictionary] = _candidate_collision_snapshot()
	var collisions_active_before := _candidate_collisions_active(collision_before)
	var collision_shape_count: int = forge.model_root.find_children("*", "CollisionShape3D", true, false).size()
	var all_passed := true
	var mass_crossing := false
	for side_name in PERIMETER_SEQUENCE:
		var side = _side_for_name(side_name)
		if side.is_empty():
			failures.append("perimeter_sequence_side_missing:%s" % side_name)
			all_passed = false
			continue
		var target: Vector3 = forge.global_position + side.offset
		var result: Dictionary = await _move_worker_to_side(side_name, target, major_mass_half)
		route_results.append(result)
		_phase("PRINCIPAL_SIDE_ACCESS", result)
		if not bool(result.get("reached", false)):
			all_passed = false
			failures.append("worker_could_not_reach_%s_perimeter_target" % side_name)
		if not bool(result.get("no_major_mass_pass_through", false)):
			mass_crossing = true
			all_passed = false
			failures.append("worker_path_crossed_major_visible_mass:%s" % side_name)
		if not bool(result.get("colliders_active", false)):
			all_passed = false
			failures.append("candidate_per_part_collision_not_active:%s" % side_name)
	var collision_after: Array[Dictionary] = _candidate_collision_snapshot()
	var collision_signature_stable := collision_before == collision_after
	var collisions_active_after := _candidate_collisions_active(collision_after)
	if not collisions_active_before or not collisions_active_after or not collision_signature_stable or collision_shape_count <= 0:
		all_passed = false
		failures.append("candidate_collision_contract_not_preserved_during_access_test")
	_phase("ACCESS_ROUTE_COLLISION_AUDIT", {
		"perimeter_sequence": PERIMETER_SEQUENCE,
		"completed_steps": route_results.size(),
		"required_steps": PERIMETER_SEQUENCE.size(),
		"all_steps_reached": all_passed and not mass_crossing,
		"no_major_mass_pass_through": not mass_crossing,
		"world_blocker_half_extents": _vec2(world._building_world_blocker_half_extents(forge)),
		"visual_mass_half_extents": _vec2(major_mass_half),
		"per_part_collision_shape_count": collision_shape_count,
		"per_part_colliders_active_before_and_after": collisions_active_before and collisions_active_after,
		"collision_signature_stable": collision_signature_stable,
	})
	if worker.has_method("command_stop"):
		worker.command_stop()
	rts._clear_selection()
	rts.emit_signal("selection_changed", rts.selected)
	for _frame in 8:
		await get_tree().process_frame
	return all_passed

func _side_for_name(side_name: String) -> Dictionary:
	for side in CARDINALS:
		if String(side.name) == side_name:
			return side
	return {}

func _candidate_collision_snapshot() -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for node in forge.model_root.find_children("*", "CollisionObject3D", true, false):
		var collision_object := node as CollisionObject3D
		if not collision_object:
			continue
		snapshot.append({"name": String(collision_object.name), "type": collision_object.get_class(), "layer": collision_object.collision_layer, "mask": collision_object.collision_mask})
	return snapshot

func _candidate_collisions_active(snapshot: Array[Dictionary]) -> bool:
	if snapshot.is_empty():
		return false
	for collider in snapshot:
		if int(collider.get("layer", 0)) == 0:
			return false
	return true

func _move_worker_to_side(side_name: String, target: Vector3, major_mass_half: Vector2) -> Dictionary:
	var started := Time.get_ticks_msec()
	var start_position: Vector3 = worker.global_position
	var collider_snapshot := _candidate_collision_snapshot()
	worker.command_move(target)
	var previous := start_position
	var mass_crossed := false
	var samples := 0
	var reached := false
	while Time.get_ticks_msec() - started < 24000:
		await get_tree().process_frame
		var current: Vector3 = worker.global_position
		samples += 1
		if world._segment_enters_route_rectangle(previous, current, forge.global_position, major_mass_half):
			mass_crossed = true
		previous = current
		if current.distance_to(target) <= 1.7 and worker.state != worker.State.MOVING and worker.state != worker.State.ATTACK_MOVE:
			reached = true
			break
	var collision_after := _candidate_collision_snapshot()
	var collider_state_stable := collider_snapshot == collision_after
	return {
		"side": side_name,
		"sequence_index": route_results.size() + 1,
		"target": _vec3(target),
		"start": _vec3(start_position),
		"endpoint": _vec3(worker.global_position),
		"distance_to_target": worker.global_position.distance_to(target),
		"distance_to_building_center": worker.global_position.distance_to(forge.global_position),
		"elapsed_seconds": float(Time.get_ticks_msec() - started) / 1000.0,
		"sample_count": samples,
		"state": int(worker.state),
		"reached": reached,
		"no_major_mass_pass_through": not mass_crossed,
		"colliders_active": _candidate_collisions_active(collision_after) and collider_state_stable,
		"collision_signature_stable": collider_state_stable,
	}

func _verify_pickability() -> bool:
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts.cam_pivot.rotation.y = 0.0
	rts._zoom = 40.0
	rts.cam_arm.spring_length = 40.0
	rts.focus_on(forge.global_position)
	await _settle_render(16)
	var aim_point: Vector3 = forge.global_position + Vector3.UP * 1.5
	var screen_point: Vector2 = rts.camera.unproject_position(aim_point)
	var viewport_rect := Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size)
	var hit = rts.raycast_selection_at(screen_point) if viewport_rect.has_point(screen_point) else null
	var hit_building_id := String(hit.building_id) if hit is Building else ""
	if hit == forge:
		rts._apply_single_click_target(hit, false)
		await get_tree().process_frame
	var selected: bool = forge in rts.selected
	pickability_audit = {
		"pick_screen_point": _vec2(screen_point),
		"pick_inside_viewport": viewport_rect.has_point(screen_point),
		"raycast_hit_building_id": hit_building_id,
		"expected_building_id": BUILDING_ID,
		"normal_single_click_selection_applied": hit == forge and selected,
		"selected_after_click": selected,
	}
	_phase("BUILDING_PICKABILITY", pickability_audit)
	if not bool(pickability_audit.get("normal_single_click_selection_applied", false)):
		failures.append("candidate_building_not_pickable_through_normal_raycast_selection")
	return bool(pickability_audit.get("normal_single_click_selection_applied", false))

func _nearby_route_blockers() -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	for blocker in world._world_route_blockers:
		var center: Vector3 = blocker.get("center", Vector3.ZERO)
		var extents: Vector2 = blocker.get("half_extents", Vector2.ZERO)
		var distance := center.distance_to(forge.global_position)
		var cardinal_buffer_hits := {}
		for side in CARDINALS:
			var approach: Vector3 = forge.global_position + side.offset
			var hit := absf(approach.x - center.x) <= extents.x + 1.0 and absf(approach.z - center.z) <= extents.y + 1.0
			cardinal_buffer_hits[String(side.name)] = hit
		if distance > 32.0 and not cardinal_buffer_hits.values().has(true):
			continue
		var owner = blocker.get("owner")
		output.append({
			"object_id": blocker.get("object_id", ""),
			"object_class": blocker.get("object_class", ""),
			"source": blocker.get("source", ""),
			"owner_name": String(owner.name) if is_instance_valid(owner) else "",
			"owner_class": owner.get_class() if is_instance_valid(owner) else "",
			"center": _vec3(center),
			"half_extents": _vec2(extents),
			"distance_from_forge": distance,
			"cardinal_approach_buffer_hits": cardinal_buffer_hits,
		})
	return output

func _capture_matched_views() -> void:
	var baseline_def: Dictionary = forge.def.duplicate(true)
	baseline_def["model"] = LEGACY_MODEL
	legacy_preview = Building.new()
	legacy_preview.name = "B01RuntimeLegacyVisualReference"
	world.add_child(legacy_preview)
	legacy_preview.global_position = forge.global_position
	legacy_preview.configure(baseline_def, 0, world.commanders[0], world, true)
	legacy_preview.set_selected(false)
	rts._clear_selection()
	rts._set_inspection_target(null)
	rts._add_to_selection(forge)
	rts.emit_signal("selection_changed", rts.selected)
	for _frame in 10:
		await get_tree().process_frame
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts.cam_pivot.rotation.y = 0.0
	rts.process_mode = Node.PROCESS_MODE_ALWAYS
	rts.cam_pivot.process_mode = Node.PROCESS_MODE_ALWAYS
	rts.cam_arm.process_mode = Node.PROCESS_MODE_ALWAYS
	rts.camera.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	for zoom in [40.0, 25.0]:
		rts._zoom = zoom
		rts.cam_arm.spring_length = zoom
		rts.focus_on(forge.global_position)
		await _settle_render(12)
		legacy_preview.visible = true
		legacy_preview.set_selected(true)
		forge.visible = false
		await _capture_frame("tesana_baseline_zoom%d" % int(zoom), "TESANA_CURRENT")
		legacy_preview.visible = false
		legacy_preview.set_selected(false)
		forge.visible = true
		forge.set_selected(true)
		await _capture_frame("b01_runtime_zoom%d" % int(zoom), candidate_label)
		var baseline_image: Image = frame_images["tesana_baseline_zoom%d" % int(zoom)]
		var candidate_image: Image = frame_images["b01_runtime_zoom%d" % int(zoom)]
		var pair_difference := _sampled_image_difference(baseline_image, candidate_image)
		var baseline_frame: Dictionary = frame_results[frame_results.size() - 2]
		var candidate_frame: Dictionary = frame_results[frame_results.size() - 1]
		var same_camera := absf(float(baseline_frame.camera_actual_distance) - float(candidate_frame.camera_actual_distance)) <= 0.1 and absf(float(baseline_frame.camera_pitch_degrees) - float(candidate_frame.camera_pitch_degrees)) <= 0.1 and absf(float(baseline_frame.camera_yaw_degrees) - float(candidate_frame.camera_yaw_degrees)) <= 0.1 and Vector3(baseline_frame.focus.x, baseline_frame.focus.y, baseline_frame.focus.z).distance_to(Vector3(candidate_frame.focus.x, candidate_frame.focus.y, candidate_frame.focus.z)) <= 0.1
		var distinct_hashes := String(baseline_frame.sha256) != "" and String(candidate_frame.sha256) != "" and String(baseline_frame.sha256) != String(candidate_frame.sha256)
		_phase("MATCHED_PAIR_DIFFERENCE", {"zoom": zoom, "sampled_different_pixels": pair_difference, "camera_match": same_camera, "distinct_sha256": distinct_hashes})
		if pair_difference < 8:
			failures.append("baseline_and_candidate_frames_not_visibly_distinct_zoom_%d" % int(zoom))
		if not same_camera:
			failures.append("baseline_and_candidate_camera_mismatch_zoom_%d" % int(zoom))
		if not distinct_hashes:
			failures.append("baseline_and_candidate_sha256_not_distinct_zoom_%d" % int(zoom))
	var baseline40: Image = frame_images.get("tesana_baseline_zoom40")
	var baseline25: Image = frame_images.get("tesana_baseline_zoom25")
	var b0140: Image = frame_images.get("b01_runtime_zoom40")
	var b0125: Image = frame_images.get("b01_runtime_zoom25")
	var zoom_difference := _sampled_image_difference(baseline40, baseline25) if baseline40 and baseline25 else 0
	var b01_zoom_difference := _sampled_image_difference(b0140, b0125) if b0140 and b0125 else 0
	var baseline_frames: Dictionary = {"zoom40": _frame_by_name("tesana_baseline_zoom40"), "zoom25": _frame_by_name("tesana_baseline_zoom25")}
	var b01_frames: Dictionary = {"zoom40": _frame_by_name("b01_runtime_zoom40"), "zoom25": _frame_by_name("b01_runtime_zoom25")}
	var zoom_hashes_distinct := String(baseline_frames.zoom40.get("sha256", "")) != String(baseline_frames.zoom25.get("sha256", "")) and String(b01_frames.zoom40.get("sha256", "")) != String(b01_frames.zoom25.get("sha256", ""))
	var camera_transforms_differ := absf(float(baseline_frames.zoom40.get("camera_actual_distance", 0.0)) - float(baseline_frames.zoom25.get("camera_actual_distance", 0.0))) >= 10.0 and absf(float(b01_frames.zoom40.get("camera_actual_distance", 0.0)) - float(b01_frames.zoom25.get("camera_actual_distance", 0.0))) >= 10.0
	_phase("ZOOM_FRAME_DIFFERENCE", {"baseline_zoom40_vs_zoom25_sampled_different_pixels": zoom_difference, "b01_zoom40_vs_zoom25_sampled_different_pixels": b01_zoom_difference, "zoom40_vs_zoom25_sha256_distinct_for_both": zoom_hashes_distinct, "camera_transforms_differ": camera_transforms_differ})
	if zoom_difference < 8:
		failures.append("camera_zoom_40_and_25_frames_indistinguishable")
	if b01_zoom_difference < 8:
		failures.append("b01_camera_zoom_40_and_25_frames_indistinguishable")
	if not zoom_hashes_distinct or not camera_transforms_differ:
		failures.append("zoom_frame_hash_or_camera_transform_did_not_change")
	get_tree().paused = false
	legacy_preview.queue_free()

func _frame_by_name(frame_name: String) -> Dictionary:
	for frame in frame_results:
		if String(frame.get("name", "")) == frame_name:
			return frame
	return {}

func _settle_render(frames: int) -> void:
	for _frame in frames:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _capture_frame(name: String, variant: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	frame_images[name] = image.duplicate()
	var output_path := output_root.path_join(name + ".png")
	var saved := not image.is_empty() and image.get_width() == TEST_WIDTH and image.get_height() == TEST_HEIGHT and image.save_png(output_path) == OK
	var sha256 := FileAccess.get_sha256(output_path) if saved else ""
	var pixel_bins := {}
	if saved:
		for x in range(0, image.get_width(), 160):
			for y in range(0, image.get_height(), 135):
				var color := image.get_pixel(x, y)
				pixel_bins["%d,%d,%d" % [int(color.r * 10.0), int(color.g * 10.0), int(color.b * 10.0)]] = true
	var frame := {
		"name": name,
		"variant": variant,
		"png": output_path,
		"width": image.get_width(),
		"height": image.get_height(),
		"camera_zoom": rts.cam_arm.spring_length,
		"camera_actual_distance": rts.camera.global_position.distance_to(rts.cam_pivot.global_position),
		"camera_pitch_degrees": rts.get_camera_pitch_degrees(),
		"camera_yaw_degrees": rad_to_deg(rts.cam_pivot.rotation.y),
		"focus": _vec3(rts.cam_pivot.global_position),
		"camera_origin": _vec3(rts.camera.global_position),
		"building_center": _vec3(forge.global_position),
		"gameplay_paused": get_tree().paused,
		"camera_processing_active": rts.cam_pivot.process_mode == Node.PROCESS_MODE_ALWAYS and rts.cam_arm.process_mode == Node.PROCESS_MODE_ALWAYS and rts.camera.process_mode == Node.PROCESS_MODE_ALWAYS,
		"sampled_color_bins": pixel_bins.size(),
		"sha256": sha256,
		"saved": saved,
	}
	frame_results.append(frame)
	_phase("MATCHED_FRAME_CAPTURE", frame)
	if not saved or pixel_bins.size() < 12:
		failures.append("invalid_or_blank_capture:%s" % name)
	if absf(float(frame.camera_actual_distance) - float(frame.camera_zoom)) > 0.75:
		failures.append("camera_spring_distance_not_applied:%s" % name)
	if not bool(frame.gameplay_paused) or not bool(frame.camera_processing_active):
		failures.append("capture_pause_or_camera_processing_contract_failed:%s" % name)

func _sampled_image_difference(first: Image, second: Image) -> int:
	if first == null or second == null or first.get_size() != second.get_size():
		return 0
	var different_samples := 0
	for x in range(0, first.get_width(), 8):
		for y in range(0, first.get_height(), 8):
			var a := first.get_pixel(x, y)
			var b := second.get_pixel(x, y)
			if absf(a.r - b.r) > 0.025 or absf(a.g - b.g) > 0.025 or absf(a.b - b.b) > 0.025:
				different_samples += 1
	return different_samples

func _finish(passed: bool, reason: String) -> void:
	var result := {
		"schema": "barrosan-iron-forge-b01-%s-headed-runtime-v1" % candidate_revision,
		"passed": passed,
		"terminal_reason": reason,
		"failures": failures,
		"site_selection_audit": site_selection_audit,
		"routes": route_results,
		"expected_perimeter_sequence": PERIMETER_SEQUENCE,
		"pickability": pickability_audit,
		"frames": frame_results,
		"output_root": output_root,
		"engine_version": Engine.get_version_info(),
	}
	_write_json("runtime-result.json", result)
	_phase("TERMINAL", result)
	if phase_file:
		phase_file.close()
	get_tree().quit(0 if passed else 1)

func _vec3(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _vec2(value: Vector2) -> Dictionary:
	return {"x": value.x, "y": value.y}

func _vec2i(value: Vector2i) -> Dictionary:
	return {"x": value.x, "y": value.y}
