extends Node3D
## GameWorld — the battle orchestrator. Builds terrain, navigation, environment,
## commanders, resource nodes, capture points; runs combat resolution, auras,
## fog-of-war bookkeeping, and victory/defeat. UI and input live in child nodes.

const Unit := preload("res://scripts/units/unit.gd")
const Building := preload("res://scripts/buildings/building.gd")
const ProjectileScript := preload("res://scripts/units/projectile.gd")
const ResourceNodeScript := preload("res://scripts/world/resource_node.gd")
const CapturePointScript := preload("res://scripts/world/capture_point.gd")

signal game_over(victory: bool)
signal hero_leveled(level: int)
signal alert(message: String, pos: Vector3)

var map := {}
var commanders := []            # Commander instances indexed by team
var player_team := 0
var player_commander = null

var nav_region: NavigationRegion3D
var navigation_map_rid := RID()
var navigation_ready := false
var navigation_ready_frame := -1
var navigation_map_iteration := 0
var terrain_mesh: MeshInstance3D
var _projectile_container: Node3D
var _fx_container: Node3D

var game_running := false
var last_alert_message := ""
var match_ended := false
var playable_min := Vector3(-136.0, -100.0, -136.0)
var playable_max := Vector3(136.0, 100.0, 136.0)
var playable_safety_margin := 4.0
var playable_recovery_tolerance := 2.0
var game_over_count := 0
var profile_record_count := 0
var result_snapshot := {}
var _profile_recorded := false
var _victory_kind := "conquest"
var _aura_timer := 0.0
var _slow_timer := 0.0
var _battle_music := false
var _combat_intensity := 0.0
const BASE_ATTACK_ALERT_COOLDOWN_SEC := 6.0
var _base_attack_alert_until_msec := 0
var match_time := 0.0
var kills_by_player := 0
var combat_damage_events: Array = []
var combat_death_events: Array = []
var combat_kill_events: Array = []
var building_damage_events: Array = []
var building_destruction_events: Array = []
var navigation_watchdog_samples: Array = []
var navigation_watchdog_violations: Array = []
var _navigation_watchdog_timer := 0.0

# v0.431 runtime evidence: this is an audit trail around the existing
# construction transaction, not a second economy or construction system.
var build_transactions: Array = []
var construction_events: Array = []
var resource_transactions: Array = []
var resource_rejections: Array = []
var resource_extractions: Array = []
var _active_build_transaction := ""
var _build_transaction_seq := 0

# combat spatial helpers (rebuilt cheaply)
var _unit_cache_timer := 0.0

var _theme := {}

# WORLD-03 player-facing environment dressing. These counts affect only
# non-colliding scenery; gameplay positions, resources, navigation, and map
# topology remain owned by the existing systems.
const WORLD03_INTERIOR_DECOR_TARGET := 40
const WORLD03_ROADSIDE_DRESSING_TARGET := 32

func _v0436_r1j_recorder():
	if OS.get_environment("ASCENDANT_V0436_R1J_CAPTURE") != "1":
		return null
	if not has_meta("v0436_r1j_recorder"):
		return null
	var recorder = get_meta("v0436_r1j_recorder", null)
	return recorder if is_instance_valid(recorder) else null

func _m20_recorder():
	if OS.get_environment("ASCENDANT_HP4_M20_DIAGNOSTICS") != "1":
		return null
	var recorder = get_node_or_null("/root/HP4M20Startup")
	return recorder if is_instance_valid(recorder) else null

func _m20_begin(stage: String, parent_stage: String = "", depth: int = 0) -> Dictionary:
	var recorder = _m20_recorder()
	return recorder.begin_stage(stage, parent_stage, depth) if recorder else {}

func _m20_end(token: Dictionary) -> void:
	var recorder = _m20_recorder()
	if recorder:
		recorder.end_stage(token)

func _m20_record_resource(resource_path: String, caller: String, start_us: int, end_us: int, operation: String) -> void:
	var recorder = _m20_recorder()
	if recorder:
		recorder.record_resource_load(resource_path, caller, start_us, end_us, operation)

func _ready() -> void:
	var ready_stage := _m20_begin("GAMEWORLD_READY")
	var cfg := Match.get_config()
	map = MapDefs.get_map(cfg.get("map", "hollowspan"))
	var bounds_stage := _m20_begin("GAMEWORLD_BOUNDS", "GAMEWORLD_READY", 1)
	_setup_playable_bounds()
	_m20_end(bounds_stage)
	_theme = MapDefs.theme(map.get("theme", "highland"))
	_projectile_container = Node3D.new()
	_projectile_container.name = "Projectiles"
	add_child(_projectile_container)
	_fx_container = Node3D.new()
	_fx_container.name = "FX"
	add_child(_fx_container)
	var environment_stage := _m20_begin("GAMEWORLD_ENVIRONMENT", "GAMEWORLD_READY", 1)
	_setup_environment()
	_m20_end(environment_stage)
	var terrain_stage := _m20_begin("GAMEWORLD_TERRAIN", "GAMEWORLD_READY", 1)
	_build_terrain()
	_m20_end(terrain_stage)
	var navigation_stage := _m20_begin("GAMEWORLD_NAVIGATION", "GAMEWORLD_READY", 1)
	_build_navigation()
	_m20_end(navigation_stage)
	var decoration_stage := _m20_begin("GAMEWORLD_DECORATION", "GAMEWORLD_READY", 1)
	_scatter_environment()
	_m20_end(decoration_stage)
	var commanders_stage := _m20_begin("GAMEWORLD_COMMANDERS", "GAMEWORLD_READY", 1)
	_setup_commanders()
	_m20_end(commanders_stage)
	var resources_stage := _m20_begin("GAMEWORLD_RESOURCES", "GAMEWORLD_READY", 1)
	_spawn_resources()
	_m20_end(resources_stage)
	var capture_stage := _m20_begin("GAMEWORLD_CAPTURE_POINTS", "GAMEWORLD_READY", 1)
	_spawn_capture_points()
	_m20_end(capture_stage)
	call_deferred("_start_match")
	_m20_end(ready_stage)

func _setup_playable_bounds() -> void:
	# MapDefs owns the actual battlefield half-extent. The safety margin keeps
	# unit bodies away from the edge while the recovery tolerance accepts the
	# small numerical overshoot produced by CharacterBody3D movement.
	var half_extent: float = maxf(8.0, float(map.get("size", 140.0)))
	playable_safety_margin = minf(4.0, half_extent * 0.08)
	playable_recovery_tolerance = minf(2.0, playable_safety_margin * 0.5)
	playable_min = Vector3(-half_extent + playable_safety_margin, -100.0, -half_extent + playable_safety_margin)
	playable_max = Vector3(half_extent - playable_safety_margin, 100.0, half_extent - playable_safety_margin)

func is_inside_playable_bounds(position: Vector3, tolerance: float = 0.0) -> bool:
	if not _finite_position(position):
		return false
	return position.x >= playable_min.x - tolerance and position.x <= playable_max.x + tolerance and position.z >= playable_min.z - tolerance and position.z <= playable_max.z + tolerance

func clamp_to_playable_bounds(position: Vector3) -> Vector3:
	if not _finite_position(position):
		return Vector3.ZERO
	return Vector3(clampf(position.x, playable_min.x, playable_max.x), position.y, clampf(position.z, playable_min.z, playable_max.z))

func nearest_safe_in_bounds_recovery_point(position: Vector3) -> Vector3:
	return clamp_to_playable_bounds(position)

func distance_outside_playable_bounds(position: Vector3) -> float:
	if not _finite_position(position):
		return INF
	var dx := maxf(playable_min.x - position.x, 0.0) + maxf(position.x - playable_max.x, 0.0)
	var dz := maxf(playable_min.z - position.z, 0.0) + maxf(position.z - playable_max.z, 0.0)
	return maxf(dx, dz)

func playable_bounds_contract() -> Dictionary:
	return {"minimum_x": playable_min.x, "maximum_x": playable_max.x, "minimum_z": playable_min.z, "maximum_z": playable_max.z, "safety_margin": playable_safety_margin, "recovery_tolerance": playable_recovery_tolerance, "source": "MapDefs.map.size"}

func _finite_position(position: Vector3) -> bool:
	return abs(position.x) < 1000000.0 and abs(position.y) < 1000000.0 and abs(position.z) < 1000000.0 and position.x == position.x and position.y == position.y and position.z == position.z

func _sample_navigation_watchdog() -> void:
	var live: Array = []
	for u in all_units():
		if not is_instance_valid(u) or u.is_dead:
			continue
		var inside := is_inside_playable_bounds(u.global_position, playable_recovery_tolerance)
		var outside_distance := distance_outside_playable_bounds(u.global_position)
		var recovery := bool(u.get("_boundary_recovery_active"))
		var sample := {"runtime_id": str(u.get_instance_id()), "unit_id": String(u.unit_id), "team": int(u.team), "state": int(u.state), "command": String(u.get("_navigation_command_type")), "position": {"x": u.global_position.x, "y": u.global_position.y, "z": u.global_position.z}, "requested_target": {"x": u.get("_requested_move_target").x, "y": u.get("_requested_move_target").y, "z": u.get("_requested_move_target").z}, "effective_target": {"x": u.get("_navigation_effective_target").x, "y": u.get("_navigation_effective_target").y, "z": u.get("_navigation_effective_target").z}, "inside_bounds": inside, "recovery_active": recovery, "distance_outside": outside_distance, "invalid_path_count": int(u.get("_navigation_invalid_count")), "rejected_velocity_count": int(u.get("_navigation_rejected_velocity_count"))}
		live.append(sample)
		if outside_distance > playable_recovery_tolerance and not recovery:
			navigation_watchdog_violations.append(sample.duplicate(true))
	navigation_watchdog_samples.append({"timestamp": Time.get_ticks_msec(), "units": live})
	if navigation_watchdog_samples.size() > 240:
		navigation_watchdog_samples.pop_front()
	if navigation_watchdog_violations.size() > 120:
		navigation_watchdog_violations.pop_front()

func navigation_watchdog_snapshot() -> Dictionary:
	var max_abs_x := 0.0
	var max_abs_z := 0.0
	for sample in navigation_watchdog_samples:
		for unit_sample in sample.get("units", []):
			var p: Dictionary = unit_sample.get("position", {})
			max_abs_x = maxf(max_abs_x, abs(float(p.get("x", 0.0))))
			max_abs_z = maxf(max_abs_z, abs(float(p.get("z", 0.0))))
	return {"samples": navigation_watchdog_samples.duplicate(true), "violations": navigation_watchdog_violations.duplicate(true), "max_observed_abs_x": max_abs_x, "max_observed_abs_z": max_abs_z, "final_live_units_inside_tolerance": navigation_watchdog_violations.is_empty()}

# --------------------------------------------------------------------------
# Environment
# --------------------------------------------------------------------------
func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky_path := "res://assets/textures/skyboxes/highland_storm_sky_sky.tres"
	if ResourceLoader.exists(sky_path):
		var load_start := Time.get_ticks_usec()
		env.sky = load(sky_path)
		_m20_record_resource(sky_path, "game_world._setup_environment", load_start, Time.get_ticks_usec(), "load")
		env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	else:
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.5, 0.6, 0.7)
	# The Tesana export's sky fill, ACES white point, glow and fog compounded
	# into a pale gameplay image. Keep this correction local to the production
	# battle world; title, campaign and settings environments are unchanged.
	env.ambient_light_energy = float(_theme.get("ambient_energy", 0.42))
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_white = 3.2
	env.glow_enabled = false
	env.glow_intensity = 0.0
	env.glow_bloom = 0.0
	env.fog_enabled = true
	env.fog_light_color = _theme.get("fog_color", Color(0.72, 0.78, 0.85))
	env.fog_density = float(_theme.get("fog_density", 0.00045))
	env.fog_sky_affect = 0.12
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-52, 40, 0)
	sun.light_energy = float(_theme.get("sun_energy", 1.0))
	sun.light_color = _theme.get("sun_color", Color(0.96, 0.94, 0.88))
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 200.0
	sun.directional_shadow_split_1 = 0.08
	sun.directional_shadow_split_2 = 0.25
	add_child(sun)

func _build_terrain() -> void:
	var size: float = map["size"] * 2.0

	# Scenery: textured path-veined ground, mountain ring, forest foothills, lake.
	# All decoration around a flat playable core — pathing is unchanged.
	var tb := TerrainBuilder.new()
	tb.name = "Scenery"
	add_child(tb)
	tb.build(map)

	# flat ground collision under the whole play field (units ride the navmesh)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(size + 80.0, 1.0, size + 80.0)
	col.shape = shape
	col.position.y = -0.5
	body.add_child(col)
	add_child(body)

	# perimeter invisible bounds keeping units on the play field
	_build_bounds(size)

func _build_bounds(size: float) -> void:
	var half := size * 0.5
	var wall_positions := [
		[Vector3(0, 0, -half), Vector3(size, 40, 4)],
		[Vector3(0, 0, half), Vector3(size, 40, 4)],
		[Vector3(-half, 0, 0), Vector3(4, 40, size)],
		[Vector3(half, 0, 0), Vector3(4, 40, size)],
	]
	for w in wall_positions:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		body.position = w[0]
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = w[1]
		col.shape = shape
		col.position.y = 20
		body.add_child(col)
		add_child(body)

func _scatter_environment() -> void:
	# Fill the battlefield with trees, boulders and ruins so it reads as a living
	# highland warfront instead of an empty plain. Decoration only (no collision,
	# no shadow-casting) so units path freely on the flat navmesh and web stays fast.
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260729 + int(Match.get_config().get("campaign_node", 0)) * 17

	# bridge centerpiece
	var bridge = map.get("bridge", {})
	if bridge and ResourceLoader.exists(bridge.get("model", "")):
		var bridge_path: String = bridge["model"]
		var load_start := Time.get_ticks_usec()
		var b = load(bridge_path).instantiate()
		_m20_record_resource(bridge_path, "game_world._scatter_environment.bridge", load_start, Time.get_ticks_usec(), "load_instantiate")
		add_child(b)
		b.position = bridge["pos"]
		ModelUtils.scale_to_height(b, 8.0)
		ModelUtils.ground_model(b)

	var decor := Node3D.new()
	decor.name = "Decor"
	add_child(decor)

	var trees := []
	for p in ["res://assets/environment/vegetation/highland_pine.glb",
			"res://assets/environment/vegetation/broadleaf_oak.glb"]:
		if ResourceLoader.exists(p):
			trees.append(p)
	var rocks := []
	for p in ["res://assets/environment/rocks/mossy_boulder.glb",
			"res://assets/environment/rocks/highland_rock_cluster.glb",
			"res://assets/environment/structures/ancient_ruin_pillar.glb"]:
		if ResourceLoader.exists(p):
			rocks.append(p)
	if trees.is_empty() and rocks.is_empty():
		return

	var half: float = map["size"]
	var starts: Array = map.get("start_positions", [])
	var density: float = float(_theme.get("decor_density", 1.0))
	var has_water: bool = _theme.get("water", {}).get("enabled", false)

	# Dense perimeter belt of woodland ringing the play field.
	var perimeter_start := Time.get_ticks_usec()
	var perimeter_count := int(54 * density)
	for i in perimeter_count:
		var ang := rng.randf() * TAU
		var rad := half * rng.randf_range(0.70, 0.97)
		var pos := Vector3(cos(ang) * rad, 0.0, sin(ang) * rad)
		_place_decor(decor, (trees if rng.randf() < 0.62 else rocks), pos, rng)
	var recorder = _m20_recorder()
	if recorder:
		recorder.record_population("perimeter_decor", perimeter_count, float(Time.get_ticks_usec() - perimeter_start) / 1000.0, 0.0, "game_world._scatter_environment")

	# Outer foothill forest bridging the walls out to the mountain bases (all
	# decoration beyond the ±140 bounds; skips the northern lake bay when present).
	var foothill_start := Time.get_ticks_usec()
	var foothill_count := int(84 * density)
	for i in foothill_count:
		var ang := rng.randf() * TAU
		var nrm := ang
		while nrm > PI: nrm -= TAU
		while nrm < -PI: nrm += TAU
		if has_water and nrm > 0.95 and nrm < 2.19:  # leave the north lake shore open
			continue
		var rad := half * rng.randf_range(1.03, 1.37)
		var pos := Vector3(cos(ang) * rad, 0.0, sin(ang) * rad)
		_place_decor(decor, (trees if rng.randf() < 0.72 else rocks), pos, rng)
	if recorder:
		recorder.record_population("foothill_decor", foothill_count, float(Time.get_ticks_usec() - foothill_start) / 1000.0, 0.0, "game_world._scatter_environment")

	# Sparser interior groves and outcrops, kept clear of bases, center and
	# objectives. The interior is deliberately quieter than the perimeter so
	# tactical lanes and resource clusters remain readable at default zoom.
	var placed := 0
	var attempts := 0
	var interior_target: int = int(WORLD03_INTERIOR_DECOR_TARGET * density)
	var interior_start := Time.get_ticks_usec()
	while placed < interior_target and attempts < 400:
		attempts += 1
		var pos := Vector3(rng.randf_range(-half, half) * 0.62, 0.0, rng.randf_range(-half, half) * 0.62)
		if _too_close_to_key(pos, starts):
			continue
		_place_decor(decor, (trees if rng.randf() < 0.68 else rocks), pos, rng)
		placed += 1
	if recorder:
		recorder.record_population("interior_decor", placed, float(Time.get_ticks_usec() - interior_start) / 1000.0, 0.0, "game_world._scatter_environment")

	_scatter_world03_roadside_dressing(decor, trees, rocks, starts, rng)
	_scatter_world03_landmarks(decor, trees, rocks, starts, rng)


func _scatter_world03_roadside_dressing(parent: Node3D, trees: Array, rocks: Array, starts: Array, rng: RandomNumberGenerator) -> void:
	if map.get("id", "") != "hollowspan":
		return
	var roads: Array = map.get("overview", {}).get("roads", [])
	var placed := 0
	for road in roads:
		if placed >= WORLD03_ROADSIDE_DRESSING_TARGET:
			break
		if not road is Array or road.size() < 2:
			continue
		for segment_index in range(road.size() - 1):
			if placed >= WORLD03_ROADSIDE_DRESSING_TARGET:
				break
			var a: Vector3 = road[segment_index]
			var b: Vector3 = road[segment_index + 1]
			var direction := Vector2(b.x - a.x, b.z - a.z)
			if direction.length_squared() < 1.0:
				continue
			direction = direction.normalized()
			var side := Vector2(-direction.y, direction.x)
			var center := a.lerp(b, 0.34 if placed % 2 == 0 else 0.68)
			var offset := 10.0 + float((placed % 3) * 3)
			var pos := Vector3(center.x + side.x * offset, 0.0, center.z + side.y * offset)
			if _too_close_to_key(pos, starts):
				continue
			_place_decor(parent, (trees if placed % 3 == 0 else rocks), pos, rng)
			placed += 1


func _scatter_world03_landmarks(parent: Node3D, trees: Array, rocks: Array, starts: Array, rng: RandomNumberGenerator) -> void:
	if map.get("id", "") != "hollowspan":
		return
	# Fixed landmark pockets give the center and crossing approach a readable
	# authored rhythm without introducing collision or gameplay affordances.
	var landmarks := [
		Vector3(-44.0, 0.0, -42.0), Vector3(44.0, 0.0, 42.0),
		Vector3(42.0, 0.0, -42.0), Vector3(-42.0, 0.0, 42.0),
		Vector3(-18.0, 0.0, -31.0), Vector3(18.0, 0.0, 31.0),
		Vector3(-31.0, 0.0, 18.0), Vector3(31.0, 0.0, -18.0),
	]
	for pos in landmarks:
		if _too_close_to_key(pos, starts):
			continue
		_place_decor(parent, (trees if rng.randf() < 0.58 else rocks), pos, rng)

func _too_close_to_key(pos: Vector3, starts: Array) -> bool:
	for s in starts:
		if pos.distance_to(s) < 42.0:
			return true
	if pos.distance_to(Vector3.ZERO) < 30.0:
		return true
	for c in map.get("capture_points", []):
		if pos.distance_to(c.get("pos", Vector3.ZERO)) < 22.0:
			return true
	return false

func _place_decor(parent: Node3D, pool: Array, pos: Vector3, rng: RandomNumberGenerator) -> void:
	if pool.is_empty():
		return
	var path: String = pool[rng.randi() % pool.size()]
	var load_start := Time.get_ticks_usec()
	var inst = load(path).instantiate()
	_m20_record_resource(path, "game_world._place_decor", load_start, Time.get_ticks_usec(), "load_instantiate")
	parent.add_child(inst)
	inst.position = pos
	var is_tree: bool = "vegetation" in path
	var h: float = rng.randf_range(6.5, 10.5) if is_tree else rng.randf_range(1.6, 3.6)
	ModelUtils.scale_to_height(inst, h)
	ModelUtils.ground_model(inst)
	inst.rotation.y = rng.randf() * TAU
	_prep_decor(inst)

func _prep_decor(n: Node) -> void:
	if n is CollisionObject3D:
		n.set_deferred("collision_layer", 0)
		n.set_deferred("collision_mask", 0)
	if n is GeometryInstance3D:
		n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if n is MeshInstance3D:
		_apply_p1r14_decor_material_tone(n)
	for c in n.get_children():
		_prep_decor(c)

func _apply_p1r14_decor_material_tone(mesh: MeshInstance3D) -> void:
	# R14 is presentation-only: mute secondary decoration while preserving its
	# meshes, positions, collisions and navigation exclusion.
	if mesh.material_override is StandardMaterial3D:
		var override_copy := (mesh.material_override as StandardMaterial3D).duplicate()
		override_copy.albedo_color = override_copy.albedo_color.lerp(Color(0.60, 0.64, 0.56), 0.16)
		override_copy.roughness = maxf(override_copy.roughness, 0.82)
		mesh.material_override = override_copy
	for surface in mesh.get_surface_override_material_count():
		var surface_mat: Material = mesh.get_surface_override_material(surface)
		if surface_mat is StandardMaterial3D:
			var surface_copy := (surface_mat as StandardMaterial3D).duplicate()
			surface_copy.albedo_color = surface_copy.albedo_color.lerp(Color(0.60, 0.64, 0.56), 0.16)
			surface_copy.roughness = maxf(surface_copy.roughness, 0.82)
			mesh.set_surface_override_material(surface, surface_copy)

func _build_navigation() -> void:
	var stage := _m20_begin("GAMEWORLD_NAVMESH", "GAMEWORLD_NAVIGATION", 2)
	nav_region = NavigationRegion3D.new()
	nav_region.name = "NavRegion"
	var nav := NavigationMesh.new()
	nav.agent_radius = 0.6
	nav.agent_height = 1.8
	nav.agent_max_climb = 0.5
	nav.agent_max_slope = 45.0
	nav.cell_size = 0.4
	nav.cell_height = 0.3
	var size: float = map["size"] * 2.0
	# Define the walkable region as a big box; bake from terrain plane.
	nav.filter_baking_aabb = AABB(Vector3(-size*0.5, -2, -size*0.5), Vector3(size, 10, size))
	# Build a simple flat navmesh procedurally (no baking needed for a flat plane).
	_build_flat_navmesh(nav, map["size"])
	# Assign only after the authored polygons exist. Assigning first and mutating
	# the resource afterwards leaves the live NavigationServer region waiting for
	# a synchronization it never receives reliably at match start.
	nav_region.navigation_mesh = nav
	add_child(nav_region)
	navigation_map_rid = nav_region.get_navigation_map()
	navigation_ready = false
	navigation_ready_frame = -1
	navigation_map_iteration = 0
	_m20_end(stage)

func _build_flat_navmesh(nav: NavigationMesh, half: float) -> void:
	# Create a single quad navmesh covering the play field.
	var verts := PackedVector3Array([
		Vector3(-half, 0.05, -half),
		Vector3(half, 0.05, -half),
		Vector3(half, 0.05, half),
		Vector3(-half, 0.05, half),
	])
	nav.vertices = verts
	nav.add_polygon(PackedInt32Array([0, 1, 2]))
	nav.add_polygon(PackedInt32Array([0, 2, 3]))

## The production navmesh is intentionally a broad flat quad, so authored
## buildings need a small deterministic route layer on top of it. This keeps
## decorative scenery non-blocking while preventing ground-unit centers from
## crossing completed building footprints. It only returns waypoints; it does
## not mutate gameplay state, placement geometry, or the authoritative map.
func navigation_waypoints_for_unit(origin: Vector3, requested: Vector3, clearance: float = 1.0, building_snapshot = null) -> Array:
	var points: Array = []
	var current := origin
	var ignored: Array = []
	var final_target := requested
	# The route solver is synchronous: buildings cannot be added, removed, or
	# change lifecycle between its bounded blocker passes. Reuse one shallow
	# group snapshot for this operation instead of allocating the same group
	# array once per route leg. Callers that already scanned buildings (the
	# velocity guard below) may pass that same snapshot through.
	var building_candidates: Array = all_buildings() if building_snapshot == null else building_snapshot
	for _step in range(6):
		var blocker = _first_route_blocking_building(current, final_target, clearance, ignored, building_candidates)
		if blocker == null:
			break
		# The old two-side heuristic could choose a waypoint that cleared the
		# first leg but let the next leg cut back through the same footprint. Use
		# deterministic perimeter candidates and require both legs to clear the
		# blocker before it can be ignored for the next route segment.
		# Keep a small deterministic margin beyond the live clearance envelope.
		# With the corrected segment-circle predicate this leaves enough tangent
		# room for units that begin close to the perimeter without selecting an
		# incoming segment that cuts through the building.
		var radius := _building_route_radius(blocker, clearance) + 0.2
		var candidates: Array[Vector3] = []
		# A unit can begin close to a building perimeter, leaving only a narrow
		# tangent corridor between the origin and the safe route circle. Sample
		# densely enough to find that corridor instead of falling back to an
		# invalid straight-through candidate.
		const ROUTE_CANDIDATE_COUNT := 64
		for candidate_index in range(ROUTE_CANDIDATE_COUNT):
			var angle := TAU * float(candidate_index) / float(ROUTE_CANDIDATE_COUNT)
			candidates.append(blocker.global_position + Vector3(cos(angle), 0.0, sin(angle)) * radius)
		var destination_inside := final_target.distance_to(blocker.global_position) < radius
		var origin_inside_clearance := current.distance_to(blocker.global_position) < radius
		var target_direction: Vector3 = final_target - blocker.global_position
		target_direction.y = 0.0
		if target_direction.length_squared() > 0.01:
			target_direction = target_direction.normalized()
		var legal_candidates: Array[Vector3] = []
		for candidate in candidates:
			# If the unit is already inside the clearance envelope, the current
			# position is the result of an earlier close approach, not a legal
			# incoming route. Force the next waypoint onto the non-target-facing
			# side so the unit exits the envelope before the target leg resumes.
			var candidate_direction: Vector3 = candidate - blocker.global_position
			candidate_direction.y = 0.0
			var exits_away_from_target: bool = not origin_inside_clearance or target_direction.length_squared() < 0.01 or candidate_direction.dot(target_direction) <= 0.01
			var incoming_clearance := _segment_clearance(current, candidate, blocker.global_position)
			var outgoing_clearance := _segment_clearance(candidate, final_target, blocker.global_position)
			var incoming_clear := origin_inside_clearance or incoming_clearance >= radius - 0.001
			var outgoing_clear := destination_inside or outgoing_clearance >= radius - 0.001
			if incoming_clear and outgoing_clear and exits_away_from_target:
				legal_candidates.append(candidate)
		var candidate: Vector3 = candidates.front()
		var fallback_second: Vector3 = candidate
		if not legal_candidates.is_empty():
			candidate = legal_candidates[0]
			for alternative in legal_candidates:
				if _route_cost(current, alternative, final_target) < _route_cost(current, candidate, final_target):
					candidate = alternative
		else:
			# A single perimeter point cannot always satisfy both tangent legs of a
			# circular clearance envelope. Search a bounded pair so the fallback
			# never cuts back through the completed Building before it is ignored.
			var best_clearance := -INF
			for first in candidates:
				var incoming_score := _segment_clearance(current, first, blocker.global_position)
				if origin_inside_clearance:
					incoming_score = INF
				for second in candidates:
					var middle_score := _segment_clearance(first, second, blocker.global_position)
					var outgoing_score := _segment_clearance(second, final_target, blocker.global_position)
					if destination_inside:
						outgoing_score = INF
					var score := minf(incoming_score, minf(middle_score, outgoing_score))
					if score > best_clearance:
						best_clearance = score
						candidate = first
						fallback_second = second
		points.append(candidate)
		if fallback_second.distance_to(candidate) > 0.01:
			points.append(fallback_second)
		current = candidate
		if fallback_second.distance_to(candidate) > 0.01:
			current = fallback_second
		ignored.append(blocker)
		# A destination inside a building is a semantic interaction request, not
		# a valid ground position. Stop at its safe perimeter instead.
		if final_target.distance_to(blocker.global_position) < radius:
			final_target = candidate
			break
	if points.is_empty() or points.back().distance_to(final_target) > 0.15:
		points.append(final_target)
	return points

func _first_route_blocking_building(origin: Vector3, target: Vector3, clearance: float, ignored: Array, building_candidates: Array):
	var closest = null
	var closest_distance := INF
	for building in building_candidates:
		if not is_instance_valid(building) or building.is_dead or not building.is_built or ignored.has(building):
			continue
		var radius := _building_route_radius(building, clearance)
		if target.distance_to(building.global_position) < radius or _segment_intersects_route_circle(origin, target, building.global_position, radius):
			var distance := origin.distance_to(building.global_position)
			if distance < closest_distance:
				closest = building
				closest_distance = distance
	return closest

func _segment_intersects_route_circle(a: Vector3, b: Vector3, center: Vector3, radius: float) -> bool:
	return _segment_clearance(a, b, center) < radius

func _segment_clearance(a: Vector3, b: Vector3, center: Vector3) -> float:
	var start := Vector2(a.x, a.z)
	var end := Vector2(b.x, b.z)
	var point := Vector2(center.x, center.z)
	var delta := end - start
	if delta.length_squared() < 0.0001:
		return start.distance_to(point)
	var t := clampf((point - start).dot(delta) / delta.length_squared(), 0.0, 1.0)
	# Measure the closest point on the segment against the circle centre. The
	# previous start-to-projection distance treated every segment whose circle
	# lay behind its origin as an intersection, producing false detours around
	# the player's own HQ during ordinary movement.
	return point.distance_to(start + delta * t)

func _route_cost(from: Vector3, via: Vector3, target: Vector3) -> float:
	return from.distance_to(via) + via.distance_to(target)

func _building_route_radius(building, clearance: float) -> float:
	var base_radius := float(building.def.get("footprint", 4.0))
	if is_instance_valid(building) and building.has_method("get_selection_geometry"):
		var geometry: Dictionary = building.get_selection_geometry()
		var visual_extents: Dictionary = geometry.get("visual_extents", {})
		base_radius = maxf(base_radius, maxf(float(visual_extents.get("x", 0.0)), float(visual_extents.get("z", 0.0))))
	return base_radius + clearance

## Last-frame guard for the broad production navmesh. It only constrains a
## movement velocity when a completed-building clearance envelope would be
## entered; it does not change targets, combat range, or authoritative state.
func constrain_unit_velocity_around_buildings(origin: Vector3, requested_velocity: Vector3, delta: float, clearance: float = 1.0) -> Vector3:
	var speed := requested_velocity.length()
	if speed < 0.01:
		return requested_velocity
	var step_end: Vector3 = origin + requested_velocity * maxf(delta, 0.016)
	var building_candidates: Array = all_buildings()
	for building in building_candidates:
		if not is_instance_valid(building) or building.is_dead or not building.is_built:
			continue
		var radius := _building_route_radius(building, clearance)
		var radial: Vector3 = origin - building.global_position
		radial.y = 0.0
		if radial.length() < radius:
			if radial.length_squared() < 0.01:
				radial = Vector3.RIGHT
			return radial.normalized() * speed
		if not _segment_intersects_route_circle(origin, step_end, building.global_position, radius):
			continue
		var travel_target: Vector3 = origin + requested_velocity.normalized() * maxf(radius * 4.0, 12.0)
		var waypoints: Array = navigation_waypoints_for_unit(origin, travel_target, clearance, building_candidates)
		if not waypoints.is_empty():
			var waypoint_direction: Vector3 = waypoints[0] - origin
			waypoint_direction.y = 0.0
			if waypoint_direction.length_squared() > 0.01:
				return waypoint_direction.normalized() * speed
		var tangent: Vector3 = Vector3(-radial.z, 0.0, radial.x).normalized()
		if tangent.dot(requested_velocity) < 0.0:
			tangent = -tangent
		return tangent * speed
	return requested_velocity

func is_navigation_ready() -> bool:
	if not is_instance_valid(nav_region) or not nav_region.enabled:
		return false
	var map_rid := nav_region.get_navigation_map()
	if not map_rid.is_valid():
		return false
	var regions := NavigationServer3D.map_get_regions(map_rid)
	var iteration := NavigationServer3D.map_get_iteration_id(map_rid)
	return not regions.is_empty() and iteration > 0

func navigation_target_snapshot(requested: Vector3) -> Dictionary:
	var bounded := clamp_to_playable_bounds(requested)
	var snapshot := {
		"ready": is_navigation_ready(),
		"map_rid": str(navigation_map_rid),
		"iteration": navigation_map_iteration,
		"requested": requested,
		"bounded": bounded,
		"projected": bounded,
		"projection_distance": 0.0,
		"reason": "navigation_map_not_ready",
	}
	if not snapshot["ready"]:
		return snapshot
	var owner := NavigationServer3D.map_get_closest_point_owner(navigation_map_rid, bounded)
	if not owner.is_valid():
		snapshot["ready"] = false
		snapshot["reason"] = "target_not_on_navigation_map"
		return snapshot
	var projected := NavigationServer3D.map_get_closest_point(navigation_map_rid, bounded)
	if not _finite_position(projected):
		snapshot["ready"] = false
		snapshot["reason"] = "non_finite_projected_target"
		return snapshot
	snapshot["projected"] = projected
	snapshot["projection_distance"] = bounded.distance_to(projected)
	snapshot["reason"] = "projected"
	return snapshot

func navigation_runtime_snapshot() -> Dictionary:
	var rid := nav_region.get_navigation_map() if is_instance_valid(nav_region) else RID()
	var result := {"ready": is_navigation_ready(), "map_rid": str(rid), "iteration": NavigationServer3D.map_get_iteration_id(rid) if rid.is_valid() else 0, "regions": NavigationServer3D.map_get_regions(rid).size() if rid.is_valid() else 0, "units": []}
	if not rid.is_valid():
		return result
	for u in all_units():
		if not is_instance_valid(u) or u.is_dead:
			continue
		var source: Vector3 = u.global_position
		var target: Vector3 = u.get("_navigation_effective_target")
		var source_point := NavigationServer3D.map_get_closest_point(rid, source)
		var target_point := NavigationServer3D.map_get_closest_point(rid, target)
		var path := NavigationServer3D.map_get_path(rid, source, target, true)
		result["units"].append({"unit_id": String(u.unit_id), "state": int(u.state), "command": String(u.get("_navigation_command_type")), "source": source, "target": target, "source_closest": source_point, "target_closest": target_point, "direct_path_size": path.size(), "direct_path_first": path[0] if not path.is_empty() else Vector3.ZERO, "direct_path_last": path[path.size() - 1] if not path.is_empty() else Vector3.ZERO})
	return result

# --------------------------------------------------------------------------
# Commanders & starting bases
# --------------------------------------------------------------------------
func _setup_commanders() -> void:
	var stage := _m20_begin("GAMEWORLD_COMMANDER_SETUP", "GAMEWORLD_COMMANDERS", 2)
	var cfg := Match.get_config()
	player_team = 0
	_victory_kind = cfg.get("victory", "conquest")
	var bank := Match.starting_bank(cfg.get("start_resources", "standard"))

	# hero stats from persistent profile
	var hero_stats := {}
	if ProfileManager.has_hero():
		hero_stats = HeroProgression.compute(ProfileManager.hero())

	# player
	var pc := Commander.new()
	pc.name = "Commander_0"
	add_child(pc)
	pc.setup(0, cfg.get("player_race", "barrosan"), true, bank.duplicate(), hero_stats)
	commanders.append(pc)
	player_commander = pc

	# opponents
	var opps: Array = cfg.get("opponents", [{"race": "vorthak", "difficulty": "normal"}])
	var t := 1
	for o in opps:
		var ec := Commander.new()
		ec.name = "Commander_%d" % t
		add_child(ec)
		ec.setup(t, o.get("race", "vorthak"), false, bank.duplicate(), {})
		commanders.append(ec)
		t += 1

	# build starting bases
	for i in commanders.size():
		_build_starting_base(commanders[i], map["start_positions"][i])
	_m20_end(stage)

func _build_starting_base(cmd, pos: Vector3) -> void:
	var stage := _m20_begin("GAMEWORLD_STARTING_BASE_%d" % int(cmd.team), "GAMEWORLD_COMMANDER_SETUP", 3)
	var race := GameData.get_race(cmd.race)
	var main_id: String = race.get("main_building", "")
	var main_def := GameData.get_building(main_id)
	main_def = main_def.duplicate()
	main_def["id"] = main_id
	var hq = _create_building(main_def, cmd.team, pos, true)
	cmd.hero_ref = null
	# starting workers + one soldier + hero
	var start_units: Array = race.get("start_units", [])
	var angle := 0.0
	var i := 0
	for uid_key in start_units:
		var uid := _resolve_unit_id(cmd.race, uid_key)
		var sp := pos + Vector3(cos(angle) * 10.0, 0, sin(angle) * 10.0)
		spawn_unit(uid, cmd.team, sp)
		angle += TAU / max(1, start_units.size())
		i += 1
	# hero
	var hero_id: String = race.get("hero", "")
	var hero = spawn_unit(hero_id, cmd.team, pos + Vector3(6, 0, 6))
	if hero:
		cmd.hero_ref = hero
		if ProfileManager.has_hero() and cmd.is_human:
			hero.def = hero.def  # name already set from def
	_m20_end(stage)

func _resolve_unit_id(race: String, key: String) -> String:
	# start_units use short keys; map to actual ids
	match key:
		"barrosan_worker", "lioraen_worker", "vorthak_worker":
			return key
		"barrosan_spears": return "barrosan_spear_guard"
		"lioraen_thorns": return "lioraen_thorn_ranger"
		"vorthak_thrall": return "vorthak_ash_thrall"
		_:
			return key

# --------------------------------------------------------------------------
# Spawning
# --------------------------------------------------------------------------
func spawn_unit(unit_id: String, team: int, pos: Vector3):
	var udef := GameData.get_unit(unit_id).duplicate()
	if udef.is_empty():
		return null
	udef["id"] = unit_id
	var u = Unit.new()
	nav_region.add_child(u) if nav_region else add_child(u)
	u.global_position = pos + Vector3(0, 0.1, 0)
	u.configure(udef, team, commanders[team] if team < commanders.size() else null, self)
	u.died.connect(_on_unit_died)
	if team < commanders.size():
		commanders[team].units.append(u)
		commanders[team].recompute_pop()
	return u

func _create_building(bdef: Dictionary, team: int, pos: Vector3, prebuilt: bool):
	var d := bdef.duplicate()
	var authoritative_id := String(d.get("id", "")).strip_edges()
	if authoritative_id == "":
		push_error("Cannot create building without an authoritative definition ID")
		return null
	d["id"] = authoritative_id
	var b = Building.new()
	add_child(b)
	b.global_position = pos
	b.configure(d, team, commanders[team] if team < commanders.size() else null, self, prebuilt)
	b.died.connect(_on_building_died)
	if team < commanders.size():
		commanders[team].buildings.append(b)
		commanders[team].recompute_pop()
	return b

func place_building(building_id: String, team: int, pos: Vector3):
	var bdef := GameData.get_building(building_id).duplicate()
	if bdef.is_empty():
		return null
	bdef["id"] = building_id
	if not can_place_building(building_id, team, pos, true):
		return null
	var cmd = commanders[team]
	var is_v0431_target := building_id == "barrosan_clan_croft" and team == 0
	# One live transaction per confirmed placement. Preview and invalid clicks
	# never reach this function; the guard also makes repeated input idempotent.
	if is_v0431_target and _active_build_transaction != "":
		return null
	if not cmd.can_afford(bdef.get("cost", {})):
		return null
	if not is_v0431_target:
		if not cmd.spend(bdef.get("cost", {}).duplicate()):
			return null
		return _create_building(bdef, team, pos, false)
	var before: Dictionary = cmd.resources.duplicate()
	var cost: Dictionary = bdef.get("cost", {}).duplicate()
	if not cmd.spend(cost):
		return null
	_build_transaction_seq += 1
	var tx_id := "v0431-clan-croft-%03d" % _build_transaction_seq
	_active_build_transaction = tx_id
	var after: Dictionary = cmd.resources.duplicate()
	var audit := {"id": tx_id, "building_id": building_id, "team": team,
		"position": {"x": pos.x, "y": pos.y, "z": pos.z},
		"cost": cost, "resources_before": before, "resources_after": after,
		"deductions": 1, "status": "placed", "completed": false}
	build_transactions.append(audit)
	var b = _create_building(bdef, team, pos, false)
	if b == null:
		_active_build_transaction = ""
		cmd.refund(cost)
		build_transactions.pop_back()
		return null
	b.set_meta("v0431_transaction_id", tx_id)
	b.set_meta("v0431_cost", cost)
	return b

## Shared authoritative build-site contract used by both the player controller
## and EnemyAI. This is validation only: it does not spend resources or create
## nodes. A caller still owns the construction transaction through
## place_building(), so invalid previews and failed AI attempts are side-effect
## free.
func get_building_placement_reason(building_id: String, team: int, pos: Vector3, check_affordability: bool = true, worker = null) -> String:
	var bdef := GameData.get_building(building_id)
	if bdef.is_empty() or team < 0 or team >= commanders.size():
		return "Cannot build this"
	if not game_running:
		return "Cannot build this"
	var cmd = commanders[team]
	if not is_instance_valid(cmd) or cmd.defeated:
		return "Cannot build this"
	if building_id not in GameData.buildings_for_race(String(cmd.race)):
		return "Cannot build this"
	if check_affordability and not cmd.can_afford(bdef.get("cost", {})):
		return "Not enough resources"
	var fp := float(bdef.get("footprint", 4.0))
	var lim := float(map.get("size", MapDefs.MAP_SIZE)) - 6.0
	if abs(pos.x) > lim or abs(pos.z) > lim or abs(pos.y) > 1.0:
		return "Outside build area"
	# A real construction worker is required, but the worker is not reserved by
	# this pure validation call. This catches AI/player attempts that could never
	# be serviced while leaving the existing worker command as the authority.
	var has_worker := false
	for u in cmd.units:
		if is_instance_valid(u) and not u.is_dead and u.is_worker and u.state != u.State.BUILDING:
			if worker == null or u == worker:
				has_worker = true
				break
	if not has_worker:
		return "No available Worker"
	# Entire radial footprint must clear every friendly and enemy building,
	# including unfinished buildings, and resource nodes.
	for b in all_buildings():
		if is_instance_valid(b) and not b.is_dead:
			var other_fp := float(b.def.get("footprint", 4.0))
			if pos.distance_to(b.global_position) < fp + other_fp:
				return "Blocked by building"
	# A green preview must also reserve space from every live Unit. Units use a
	# fixed 0.5 navigation/body radius in the current RTS contract; dead Units
	# are already removed from gameplay occupancy and must not block new sites.
	for u in all_units():
		if is_instance_valid(u) and not u.is_dead and pos.distance_to(u.global_position) < fp + 0.5:
			return "Blocked by unit"
	for r in get_tree().get_nodes_in_group("resources"):
		if is_instance_valid(r) and not r.depleted and pos.distance_to(r.global_position) < fp + 2.0:
			return "Blocked by resource"
	return ""

func can_place_building(building_id: String, team: int, pos: Vector3, check_affordability: bool = true, worker = null) -> bool:
	return get_building_placement_reason(building_id, team, pos, check_affordability, worker).is_empty()

func _projectile_source_is_live(source, p_team: int) -> bool:
	if not is_instance_valid(source):
		return false
	if source is Unit:
		return source.world == self and source.team == p_team and not source.is_dead and not source._is_defeated_remnant()
	if source is Building:
		return source.world == self and source.team == p_team and source.is_built and not source.is_dead and not (source.commander and source.commander.defeated)
	return false

func spawn_projectile(from: Vector3, target, dmg: float, dtype: String, team: int, kind: String, splash: float, source, attack_event_id: String = "") -> void:
	if not game_running or not _projectile_source_is_live(source, team):
		return
	var p = ProjectileScript.new()
	_projectile_container.add_child(p)
	p.setup(from, target, dmg, dtype, team, self, kind, splash, source, attack_event_id)
	var recorder = _v0436_r1j_recorder()
	if recorder:
		p.r1j_projectile_event_id = recorder.record_projectile_spawn(p)
	# speed by kind
	if kind in ["arrow", "bolt", "thorn"]:
		p.speed = 34.0
	else:
		p.speed = 22.0

# --------------------------------------------------------------------------
# Combat resolution callbacks (from projectiles / units)
# --------------------------------------------------------------------------
func projectile_impact(pos: Vector3, target, dmg: float, dtype: String, team: int, splash: float, kind: String, projectile = null) -> void:
	spawn_hit_fx(pos, kind)
	var recorder = _v0436_r1j_recorder()
	if recorder and is_instance_valid(projectile):
		recorder.record_projectile_phase(projectile, "impact", {"position": {"x":pos.x, "y":pos.y, "z":pos.z}, "target_valid":is_instance_valid(target) and not _is_dead(target), "target_runtime_id":str(target.get_instance_id()) if is_instance_valid(target) else ""})
	if is_instance_valid(target) and not _is_dead(target) and target.team != team:
		var ac = target.armor_class if "armor_class" in target else "medium"
		var ar = target.cur_armor() if target.has_method("cur_armor") else 0.0
		var final = GameData.compute_damage(dmg, dtype, ac, ar)
		var source_unit = projectile.source if is_instance_valid(projectile) and is_instance_valid(projectile.source) else null
		var source_payload = {"source_unit": source_unit, "source_team": team, "source_unit_id": String(projectile.source_unit_id) if is_instance_valid(projectile) else "", "source_runtime_id": String(projectile.source_runtime_id) if is_instance_valid(projectile) else "", "projectile_kind": kind, "damage_type": dtype, "raw_damage":dmg, "armor_class":ac, "flat_armor":ar, "multiplier":GameData.damage_multiplier(dtype, ac), "calculated_damage_before_clamp":dmg * GameData.damage_multiplier(dtype, ac) - maxf(0.0, ar) * 0.5, "expected_applied_damage":final, "attack_event_id":String(projectile.r1j_attack_event_id) if is_instance_valid(projectile) else "", "projectile_event_id":String(projectile.r1j_projectile_event_id) if is_instance_valid(projectile) else ""}
		target.take_damage(final, source_payload)
	if splash > 0.0:
		var splash_source = {"source_unit": projectile.source if is_instance_valid(projectile) and is_instance_valid(projectile.source) else null, "source_team": team, "source_unit_id": String(projectile.source_unit_id) if is_instance_valid(projectile) else "", "source_runtime_id": String(projectile.source_runtime_id) if is_instance_valid(projectile) else "", "projectile_kind": kind, "damage_type": dtype, "raw_damage":dmg * 0.5, "attack_event_id":String(projectile.r1j_attack_event_id) if is_instance_valid(projectile) else "", "projectile_event_id":String(projectile.r1j_projectile_event_id) if is_instance_valid(projectile) else ""}
		apply_splash(pos, splash, dmg * 0.5, dtype, team, target, splash_source, kind)

func apply_splash(center: Vector3, radius: float, dmg: float, dtype: String, team: int, exclude, source = null, kind: String = "splash") -> void:
	for u in all_units():
		if u == exclude or not is_instance_valid(u) or u.is_dead:
			continue
		if u.team != team and u.global_position.distance_to(center) <= radius:
			var final = GameData.compute_damage(dmg, dtype, u.armor_class, u.cur_armor())
			u.take_damage(final, source)

func _is_dead(n) -> bool:
	return "is_dead" in n and n.is_dead

# --------------------------------------------------------------------------
# Queries used by unit AI
# --------------------------------------------------------------------------
func all_units() -> Array:
	return get_tree().get_nodes_in_group("units")

func all_buildings() -> Array:
	return get_tree().get_nodes_in_group("buildings")

func find_enemy_in_range(unit, rng: float):
	var best = null
	var best_d := rng * rng
	var p: Vector3 = unit.global_position
	for u in all_units():
		if not is_instance_valid(u) or u.is_dead or u.team == unit.team:
			continue
		var d = p.distance_squared_to(u.global_position)
		if d < best_d:
			best_d = d
			best = u
	# also consider buildings if no unit and unit is combat
	if best == null and not unit.is_worker:
		for b in all_buildings():
			if not is_instance_valid(b) or b.is_dead or b.team == unit.team:
				continue
			var d = p.distance_squared_to(b.global_position)
			if d < best_d:
				best_d = d
				best = b
	return best

func find_enemy_near(pos: Vector3, rng: float, team: int):
	var best = null
	var best_d := rng * rng
	for u in all_units():
		if not is_instance_valid(u) or u.is_dead or u.team == team:
			continue
		var d = pos.distance_squared_to(u.global_position)
		if d < best_d:
			best_d = d
			best = u
	return best

func find_wounded_ally(unit, rng: float):
	var best = null
	var best_ratio := 0.95
	for u in all_units():
		if not is_instance_valid(u) or u.is_dead or u.team != unit.team or u == unit:
			continue
		if u.global_position.distance_to(unit.global_position) <= rng:
			var r = u.get_hp_ratio()
			if r < best_ratio:
				best_ratio = r
				best = u
	return best

func find_nearest_resource(pos: Vector3, kind: String):
	var best = null
	var best_d := INF
	for r in get_tree().get_nodes_in_group("resources"):
		if not is_instance_valid(r) or r.depleted:
			continue
		if kind != "" and r.resource_kind != kind:
			continue
		var d = pos.distance_squared_to(r.global_position)
		if d < best_d:
			best_d = d
			best = r
	if best == null and kind != "":
		return find_nearest_resource(pos, "")
	return best

func find_nearest_resource_exact(pos: Vector3, kind: String):
	var best = null
	var best_d := INF
	for r in get_tree().get_nodes_in_group("resources"):
		if not is_instance_valid(r) or r.depleted or r.resource_kind != kind:
			continue
		var d = pos.distance_squared_to(r.global_position)
		if d < best_d:
			best_d = d
			best = r
	return best

func is_resource_command_valid(node, worker) -> bool:
	if not is_instance_valid(node) or not (node is ResourceNode) or node.depleted:
		return false
	if not is_instance_valid(worker) or not worker.is_worker or worker.is_dead:
		return false
	if worker.team < 0 or worker.team >= commanders.size() or commanders[worker.team].defeated:
		return false
	var half := float(map.get("size", MapDefs.MAP_SIZE))
	return abs(node.global_position.x) <= half and abs(node.global_position.z) <= half

func record_resource_command_rejection(worker, node, reason: String) -> void:
	resource_rejections.append({"worker_id": worker.unit_id if is_instance_valid(worker) else "", "node_id": str(node.get_instance_id()) if is_instance_valid(node) else "", "reason": reason})

func record_resource_extraction(worker, node, before_amount: int, after_amount: int, granted: int) -> void:
	resource_extractions.append({"worker_id": worker.unit_id, "worker_runtime_id": str(worker.get_instance_id()), "node_id": str(node.get_instance_id()), "kind": node.resource_kind, "node_before": before_amount, "node_after": after_amount, "granted": granted, "capacity": worker.CARRY_MAX, "carry_after": worker.get_economy_snapshot().carry})

func record_resource_deposit(worker, drop, kind: String, carried: int, multiplier: float, deposited: int, bank_before: Dictionary, bank_after: Dictionary) -> void:
	var snap: Dictionary = worker.get_economy_snapshot()
	var drop_valid := is_instance_valid(drop) and drop is Building
	var drop_id := String(drop.building_id).strip_edges() if drop_valid else ""
	var drop_position := {"x": drop.global_position.x, "y": drop.global_position.y, "z": drop.global_position.z} if drop_valid else {"x": 0.0, "y": 0.0, "z": 0.0}
	resource_transactions.append({
		"worker_id": worker.unit_id,
		"worker_runtime_id": str(worker.get_instance_id()),
		"resource_node_runtime_id": snap.get("source_node_id", ""),
		"kind": kind,
		"carried_amount": carried,
		"gather_multiplier": multiplier,
		"deposited_amount": deposited,
		"bank_before": bank_before,
		"bank_after": bank_after,
		"deposit_count": snap.get("deposit_sequence", 0),
		"timestamp_msec": Time.get_ticks_msec(),
		"dropoff_id": drop_id,
		"dropoff_building_id": drop_id,
		"dropoff_runtime_id": str(drop.get_instance_id()) if drop_valid else "",
		"dropoff_team": int(drop.team) if drop_valid else -1,
		"dropoff_position": drop_position,
		"dropoff_is_built": bool(drop.is_built) if drop_valid else false,
		"dropoff_is_friendly": bool(drop_valid and drop.team == worker.team),
		"dropoff_definition_name": String(drop.def.get("name", "")) if drop_valid else "",
		"next_target": snap.get("target", "None")
	})

func find_nearest_dropoff(pos: Vector3, team: int):
	var best = null
	var best_d := INF
	for b in all_buildings():
		if not is_instance_valid(b) or b.is_dead or b.team != team:
			continue
		if not b.is_built or not b.def.get("drop_off", false):
			continue
		var d = pos.distance_squared_to(b.global_position)
		if d < best_d:
			best_d = d
			best = b
	return best

func near_friendly_hq(pos: Vector3, team: int, rng: float) -> bool:
	for b in all_buildings():
		if not is_instance_valid(b) or b.is_dead or not b.is_built or b.team != team:
			continue
		var owner = commander_for_team(b.team)
		if not is_instance_valid(owner) or owner.defeated:
			continue
		if b.def.get("is_hq", false) and pos.distance_to(b.global_position) <= rng:
			return true
	return false

func heal_allies_near(center: Vector3, rng: float, amt: float, team: int) -> void:
	for u in all_units():
		if is_instance_valid(u) and not u.is_dead and u.team == team:
			if u.global_position.distance_to(center) <= rng:
				u.heal(amt)

func commander_for_team(team: int):
	if team >= 0 and team < commanders.size():
		return commanders[team]
	return null

# --------------------------------------------------------------------------
# Resources & capture points
# --------------------------------------------------------------------------
func _spawn_resources() -> void:
	var stage := _m20_begin("GAMEWORLD_RESOURCE_NODES", "GAMEWORLD_RESOURCES", 2)
	var models := {
		"timber": "res://assets/props/containers/resource_timber_pile.glb",
		"stone": "res://assets/props/misc/resource_stone_quarry_chunk.glb",
		"gold": "res://assets/environment/rocks/gold_mine_lumevein.glb",
		"food": "res://assets/props/containers/resource_timber_pile.glb",
	}
	var amounts := {"timber": 800, "stone": 700, "gold": 900, "food": 600}
	var heights := {"timber": 2.0, "stone": 2.2, "gold": 3.0, "food": 2.0}
	for r in map.get("resources", []):
		var kind: String = r["kind"]
		var node = ResourceNodeScript.new()
		add_child(node)
		node.global_position = r["pos"]
		node.configure(kind, amounts.get(kind, 800), models.get(kind, ""), heights.get(kind, 2.0))
	var recorder = _m20_recorder()
	if recorder:
		recorder.record_population("resource_nodes", map.get("resources", []).size(), 0.0, 0.0, "game_world._spawn_resources")
	_m20_end(stage)

func _spawn_capture_points() -> void:
	var stage := _m20_begin("GAMEWORLD_CAPTURE_NODE_SETUP", "GAMEWORLD_CAPTURE_POINTS", 2)
	for c in map.get("capture_points", []):
		var cp = CapturePointScript.new()
		add_child(cp)
		cp.global_position = c["pos"]
		cp.configure(c["name"], c["benefit"], c.get("model", ""), self)
		cp.captured.connect(_on_point_captured_signal)
	var recorder = _m20_recorder()
	if recorder:
		recorder.record_population("capture_points", map.get("capture_points", []).size(), 0.0, 0.0, "game_world._spawn_capture_points")
	_m20_end(stage)

func on_point_captured(point, team: int) -> void:
	if team == player_team:
		emit_signal("alert", "You captured %s!" % point.point_name, point.global_position)

func _on_point_captured_signal(point, team: int) -> void:
	pass

# --------------------------------------------------------------------------
# Match lifecycle
# --------------------------------------------------------------------------
func _start_match() -> void:
	game_running = true
	AudioManager.play_music_path(Sfx.music_key("battle"), -10.0, true)
	_battle_music = true
	last_alert_message = "The battle for %s begins!" % str(map.get("name", Match.get_config().get("map", "the selected battlefield")))
	emit_signal("alert", last_alert_message, Vector3.ZERO)

func get_runtime_identity_snapshot() -> Dictionary:
	var cfg := Match.get_identity_snapshot()
	var configured_opponents: Array = cfg.get("opponents", [])
	var runtime_opponents: Array = []
	for i in range(1, commanders.size()):
		var commander = commanders[i]
		var difficulty := "normal"
		if i - 1 < configured_opponents.size():
			difficulty = str(configured_opponents[i - 1].get("difficulty", "normal"))
		runtime_opponents.append({"race": String(commander.race), "difficulty": difficulty})
	var player_hq := ""
	var starting_units: Array = []
	if is_instance_valid(player_commander):
		for building in player_commander.buildings:
			if is_instance_valid(building) and bool(building.def.get("is_hq", false)):
				player_hq = String(building.building_id)
				break
		for unit in player_commander.units:
			if is_instance_valid(unit):
				starting_units.append(String(unit.unit_id))
	var hero_definition := ""
	if is_instance_valid(player_commander) and is_instance_valid(player_commander.hero_ref):
		hero_definition = String(player_commander.hero_ref.def.get("id", ""))
	return {
		"config": cfg,
		"runtime_map_id": String(map.get("id", "")),
		"runtime_map_name": String(map.get("name", map.get("id", ""))),
		"runtime_player_race": String(player_commander.race) if is_instance_valid(player_commander) else "",
		"runtime_player_hq": player_hq,
		"runtime_starting_units": starting_units,
		"runtime_hero_definition": hero_definition,
		"battle_start_alert": last_alert_message,
		"runtime_opponents": runtime_opponents,
		"profile_hero": ProfileManager.hero().duplicate(true),
	}

func _physics_process(delta: float) -> void:
	var ready_now := is_navigation_ready()
	if ready_now and not navigation_ready:
		navigation_ready_frame = Engine.get_physics_frames()
		navigation_map_rid = nav_region.get_navigation_map() if is_instance_valid(nav_region) else RID()
		navigation_map_iteration = NavigationServer3D.map_get_iteration_id(navigation_map_rid) if navigation_map_rid.is_valid() else 0
	navigation_ready = ready_now
	if not game_running:
		return
	match_time += delta
	_aura_timer += delta
	_navigation_watchdog_timer += delta
	if _navigation_watchdog_timer >= 0.25:
		_navigation_watchdog_timer = 0.0
		_sample_navigation_watchdog()
	if _aura_timer >= 0.4:
		_update_command_auras()
		_aura_timer = 0.0
	_check_victory()

func _update_command_auras() -> void:
	# reset then apply hero command auras
	for u in all_units():
		if is_instance_valid(u) and not u.is_dead:
			u.set_aura_bonus(0.0, 0.0)
	for cmd in commanders:
		var hero = cmd.hero_ref
		if not is_instance_valid(hero) or hero.is_dead:
			continue
		var rng: float = 12.0 + hero.aura_range
		if hero.aura_dmg <= 0.0 and hero.aura_armor <= 0.0:
			continue
		for u in cmd.units:
			if is_instance_valid(u) and not u.is_dead and u != hero:
				if u.is_siege and not cmd.build_flags.get("aura_siege", false):
					continue
				if hero.global_position.distance_to(u.global_position) <= rng:
					u.set_aura_bonus(hero.aura_dmg, hero.aura_armor)

func _check_victory() -> void:
	# Conquest requires no HQ, no live rebuilding worker, and no live buildings.
	var newly_defeated_opponents: Array = []
	for cmd in commanders:
		if cmd.defeated:
			continue
		var no_hq: bool = not cmd.has_hq()
		var no_workers: bool = bool(_no_workers(cmd))
		var no_buildings: bool = cmd.alive_buildings() == 0
		if no_hq and no_workers and no_buildings:
			cmd.defeated = true
			cmd.defeat_reason = "conquest_rebuild_capability_eliminated"
			_freeze_defeated_commander(cmd)
			if cmd.team != player_team:
				newly_defeated_opponents.append(cmd)
			if cmd.team == player_team:
				_end_game(false, "hq_destroyed" if no_hq else "no_live_buildings")
				return
	# domination victory: hold all capture points for a while — simplified to conquest here
	var alive_teams := 0
	var player_alive := false
	for cmd in commanders:
		if not cmd.defeated:
			alive_teams += 1
			if cmd.team == player_team:
				player_alive = true
	# The existing alert surface confirms an intermediate strategic defeat while
	# another hostile Commander remains. The transition list makes this exactly
	# once without adding a second victory-state registry or world scan.
	if player_alive and alive_teams > 1:
		for defeated_cmd in newly_defeated_opponents:
			var race_def: Dictionary = GameData.get_race(String(defeated_cmd.race))
			var faction_name := String(race_def.get("name", defeated_cmd.race)).strip_edges()
			if faction_name.is_empty():
				faction_name = String(defeated_cmd.race)
			emit_signal("alert", "%s defeated" % faction_name, Vector3.ZERO)
	if player_alive and alive_teams == 1:
		for cmd in commanders:
			if cmd.team != player_team and cmd.defeated and cmd.defeat_reason == "":
				cmd.defeat_reason = "conquest_rebuild_capability_eliminated"
		_end_game(true, "Conquest")

func _no_workers(cmd) -> bool:
	for u in cmd.units:
		if is_instance_valid(u) and not u.is_dead and u.is_worker:
			return false
	return true

func _freeze_defeated_commander(cmd) -> void:
	for u in cmd.units:
		if is_instance_valid(u) and not u.is_dead and u.has_method("freeze_as_defeated_remnant"):
			u.freeze_as_defeated_remnant()

func _end_game(victory: bool, reason: String = "Conquest") -> void:
	if match_ended:
		return
	match_ended = true
	game_running = false
	game_over_count += 1
	AudioManager.play_music_path(Sfx.music_key("victory" if victory else "defeat"), -6.0, false)
	# rewards
	var xp := 200.0 + float(kills_by_player) * 12.0 + match_time * 0.5
	if victory:
		xp *= 1.6
	if not _profile_recorded and ProfileManager.has_hero():
		_profile_recorded = true
		profile_record_count += 1
		ProfileManager.record_battle(victory, kills_by_player, xp)
	result_snapshot = {"victory": victory, "reason": reason, "mode": Match.get_config().get("mode", "skirmish"),
		"victory_kind": _victory_kind, "player_team": player_team, "kills": kills_by_player,
		"building_kills": building_destruction_events.filter(func(e): return int(e.get("source_team", -1)) == player_team).size(),
		"xp": xp, "time": match_time, "completion_timestamp": Time.get_unix_time_from_system(),
		"defeated_teams": commanders.filter(func(c): return c.defeated).map(func(c): return c.team)}
	Match.last_result = result_snapshot.duplicate(true)
	emit_signal("game_over", victory)

# --------------------------------------------------------------------------
# Damage / death notifications
# --------------------------------------------------------------------------
func on_unit_damaged(unit, from) -> void:
	if unit.team == player_team and unit.is_worker:
		emit_signal("alert", "Workers under attack!", unit.global_position)

func record_combat_damage(victim, source, final_damage: float, hp_before: float, hp_after: float) -> void:
	var source_team := -1
	var source_id := ""
	var source_runtime_id := ""
	var kind := "environment"
	var attack_event_id := ""
	var projectile_event_id := ""
	var raw_damage := final_damage
	var armor_class := String(victim.armor_class) if "armor_class" in victim else ""
	var flat_armor := float(victim.cur_armor()) if victim.has_method("cur_armor") else 0.0
	var multiplier := 1.0
	var calculated_before_clamp := final_damage
	var expected_applied_damage := final_damage
	if source is Dictionary:
		source_team = int(source.get("source_team", -1))
		source_id = String(source.get("source_unit_id", source.get("source_id", "")))
		source_runtime_id = String(source.get("source_runtime_id", ""))
		kind = String(source.get("projectile_kind", "melee"))
		attack_event_id = String(source.get("attack_event_id", ""))
		projectile_event_id = String(source.get("projectile_event_id", ""))
		raw_damage = float(source.get("raw_damage", final_damage))
		armor_class = String(source.get("armor_class", armor_class))
		flat_armor = float(source.get("flat_armor", flat_armor))
		multiplier = float(source.get("multiplier", 1.0))
		calculated_before_clamp = float(source.get("calculated_damage_before_clamp", final_damage))
		expected_applied_damage = float(source.get("expected_applied_damage", final_damage))
	elif is_instance_valid(source):
		source_team = int(source.source_team) if "source_team" in source else int(source.team) if "team" in source else -1
		source_id = String(source.unit_id) if "unit_id" in source else String(source.source_unit_id) if "source_unit_id" in source else ""
		source_runtime_id = str(source.get_instance_id())
		kind = String(source.projectile_kind) if "projectile_kind" in source else "melee"
	var event := {"victim_id": String(victim.unit_id), "victim_runtime_id": str(victim.get_instance_id()), "source_id": source_id, "source_runtime_id": source_runtime_id, "source_team": source_team, "damage_type": String(victim._last_damage_type), "kind": kind, "final_damage": final_damage, "hp_before": hp_before, "hp_after": hp_after, "killing_blow": hp_after <= 0.0, "timestamp": Time.get_ticks_msec(), "attack_event_id":attack_event_id, "projectile_event_id":projectile_event_id, "raw_damage":raw_damage, "armor_class":armor_class, "flat_armor":flat_armor, "multiplier":multiplier, "calculated_damage_before_clamp":calculated_before_clamp, "expected_applied_damage":expected_applied_damage, "observed_hp_delta":hp_before - hp_after}
	var recorder = _v0436_r1j_recorder()
	if recorder:
		event["damage_event_id"] = recorder.record_damage_event(event)
		victim.set_meta("v0436_r1j_last_damage_event_id", String(event["damage_event_id"]))
	combat_damage_events.append(event)

func on_building_damaged(building, from, hp_before: float = -1.0, final_damage: float = -1.0) -> void:
	var source_team := -1
	var source_id := ""
	var kind := "environment"
	if from is Dictionary:
		source_team = int(from.get("source_team", -1))
		source_id = String(from.get("source_unit_id", ""))
		kind = String(from.get("projectile_kind", "melee"))
	elif is_instance_valid(from):
		source_team = int(from.team) if "team" in from else -1
		source_id = String(from.unit_id) if "unit_id" in from else ""
		kind = String(from.projectile_kind) if "projectile_kind" in from else "melee"
	if hp_before < 0.0:
		hp_before = building.hp + maxf(0.0, final_damage)
	if final_damage < 0.0:
		final_damage = maxf(0.0, hp_before - building.hp)
	building_damage_events.append({"building_id": String(building.building_id),
		"building_runtime_id": str(building.get_instance_id()), "building_team": int(building.team),
		"source_id": source_id, "source_team": source_team, "kind": kind,
		"damage_type": kind, "raw_damage": final_damage, "effective_damage": final_damage,
		"final_damage": final_damage, "hp_before": hp_before, "hp_after": building.hp,
		"killing_blow": building.hp <= 0.0, "timestamp": Time.get_ticks_msec()})
	# Strategic warning is presentation-only: require a known hostile damage
	# source, then debounce the shared player-facing cue across all buildings.
	if building.team == player_team and source_team >= 0 and source_team != player_team:
		var now_msec := Time.get_ticks_msec()
		if now_msec >= _base_attack_alert_until_msec:
			_base_attack_alert_until_msec = now_msec + int(BASE_ATTACK_ALERT_COOLDOWN_SEC * 1000.0)
			Sfx.play("under_attack", -6.0)
			emit_signal("alert", "Your base is under attack!", building.global_position)

func _on_unit_died(unit) -> void:
	if unit.get_meta("v0434_death_handled", false):
		return
	unit.set_meta("v0434_death_handled", true)
	var source_team := int(unit._last_damage_source_team)
	var credited := source_team == player_team
	if credited:
		kills_by_player += 1
		combat_kill_events.append({"victim_id": String(unit.unit_id), "victim_runtime_id": str(unit.get_instance_id()), "source_id": String(unit._last_damage_source_id), "source_team": source_team, "kind": String(unit._last_damage_kind), "kill_index": kills_by_player})
	combat_death_events.append({"victim_id": String(unit.unit_id), "victim_runtime_id": str(unit.get_instance_id()), "victim_team": unit.team, "source_id": String(unit._last_damage_source_id), "source_team": source_team, "kind": String(unit._last_damage_kind), "credited_to_player": credited})
	var recorder = _v0436_r1j_recorder()
	if recorder:
		var final_damage_event_id := String(unit.get_meta("v0436_r1j_last_damage_event_id", "")) if unit.has_meta("v0436_r1j_last_damage_event_id") else ""
		recorder.record_death_event({"victim_id":String(unit.unit_id), "victim_runtime_id":str(unit.get_instance_id()), "victim_team":int(unit.team), "final_attacker_runtime_id":String(unit._last_damage_source_id), "final_damage_event_id":final_damage_event_id, "current_command":String(unit.get("_navigation_command_type")), "current_state":int(unit.state)})
	if unit.team < commanders.size():
		commanders[unit.team].units.erase(unit)
		commanders[unit.team].recompute_pop()
	# hero down handling
	for cmd in commanders:
		if cmd.hero_ref == unit:
			cmd.hero_ref = null

func _on_building_died(building) -> void:
	if building.team < commanders.size():
		commanders[building.team].buildings.erase(building)
		commanders[building.team].recompute_pop()

func on_building_completed(building) -> void:
	var tx_id := String(building.get_meta("v0431_transaction_id", ""))
	if tx_id == "":
		return
	for tx in build_transactions:
		if tx.get("id", "") == tx_id:
			if tx.get("completed", false):
				return
			tx["completed"] = true
			tx["status"] = "completed"
			construction_events.append({"id": tx_id, "event": "completed",
				"building_id": building.def.get("id", ""),
				"is_built": building.is_built, "hp": building.hp,
				"position": {"x": building.global_position.x,
					"y": building.global_position.y, "z": building.global_position.z}})
			_active_build_transaction = ""
			return

func get_v0431_construction_audit() -> Dictionary:
	return {"transactions": build_transactions.duplicate(true),
		"construction_events": construction_events.duplicate(true),
		"active_transaction": _active_build_transaction,
		"transaction_count": build_transactions.size(),
		"completed_count": construction_events.size()}

func on_building_destroyed(building) -> void:
	if building.get_meta("v0436_destruction_recorded", false):
		return
	building.set_meta("v0436_destruction_recorded", true)
	# A placed-but-unfinished Croft owns the legacy single-live-transaction guard.
	# Destruction already owns the current no-refund accounting and site teardown;
	# retire only the stale guard so a later valid player placement can proceed.
	var tx_id := String(building.get_meta("v0431_transaction_id", ""))
	if tx_id != "" and tx_id == _active_build_transaction:
		for tx in build_transactions:
			if String(tx.get("id", "")) == tx_id and not tx.get("completed", false):
				tx["status"] = "destroyed"
				tx["destroyed"] = true
				_active_build_transaction = ""
				break
	var source_team := -1
	var source_id := ""
	if not building_damage_events.is_empty():
		var last: Dictionary = building_damage_events.back()
		if String(last.get("building_runtime_id", "")) == str(building.get_instance_id()) and last.get("killing_blow", false):
			source_team = int(last.get("source_team", -1))
			source_id = String(last.get("source_id", ""))
	building_destruction_events.append({"building_id": String(building.building_id),
		"building_runtime_id": str(building.get_instance_id()), "building_team": int(building.team),
		"kind": String(building.def.get("kind", "")), "is_hq": bool(building.def.get("is_hq", false)),
		"source_id": source_id, "source_team": source_team, "destroyed_once": true,
		"queue_cleared": building.queue.is_empty(), "collision_disabled": building.collision_layer == 0})
	# Only a completed friendly structure is a strategic loss. Construction sites
	# are transient and already have their own teardown/transaction semantics.
	if building.team == player_team and building.is_built:
		emit_signal("alert", "Building lost: %s" % building.def.get("name", "building"), building.global_position)

# --------------------------------------------------------------------------
# Hero abilities
# --------------------------------------------------------------------------
func execute_hero_ability(hero, id: String, target_pos: Vector3, level: int) -> void:
	var ab := SkillDefs.get_abilities().get(id, {})
	match id:
		"rally":
			heal_allies_near(hero.global_position, ab.get("range", 14.0), 40.0 + hero.heal_power, hero.team)
			for u in commander_for_team(hero.team).units:
				if is_instance_valid(u) and not u.is_dead:
					if u.global_position.distance_to(hero.global_position) <= ab.get("range", 14.0):
						u.apply_slow(-1.0)  # no-op clear
			spawn_ring_fx(hero.global_position, Color(1, 0.9, 0.4), ab.get("range", 14.0))
		"slam":
			var dmg = ab.get("dmg", 60) * (1.5 if level >= 2 else 1.0)
			var rng = ab.get("range", 8.0) * (1.4 if level >= 2 else 1.0)
			for u in all_units():
				if is_instance_valid(u) and not u.is_dead and u.team != hero.team:
					if u.global_position.distance_to(hero.global_position) <= rng:
						u.take_damage(GameData.compute_damage(dmg, "blunt", u.armor_class, u.cur_armor()), hero)
						u.apply_stun(1.5)
			spawn_ring_fx(hero.global_position, Color(0.9, 0.6, 0.2), rng)
		"charge":
			var dir = (target_pos - hero.global_position)
			dir.y = 0
			var dist = min(dir.length(), ab.get("range", 18.0))
			var dest = hero.global_position + dir.normalized() * dist
			var dmg = ab.get("dmg", 50) * (1.4 if level >= 2 else 1.0)
			for u in all_units():
				if is_instance_valid(u) and not u.is_dead and u.team != hero.team:
					if _point_near_segment(u.global_position, hero.global_position, dest, 3.0):
						u.take_damage(GameData.compute_damage(dmg, "slash", u.armor_class, u.cur_armor()), hero)
			hero.command_move(dest)
			spawn_ring_fx(dest, hero.commander.color, 3.0)
		"bolt":
			var arcs = 1
			if level == 2: arcs = 2
			elif level >= 3: arcs = 3
			var hit := []
			for a in arcs:
				var tgt = _nearest_enemy_to(target_pos, hero.team, hit)
				if tgt:
					hit.append(tgt)
					spawn_projectile(hero.global_position + Vector3.UP * 1.5, tgt, ab.get("dmg", 70), "arcane", hero.team, "lume_bolt", 0.0, hero)
		"heal":
			heal_allies_near(hero.global_position, ab.get("range", 14.0), ab.get("heal", 120) + hero.heal_power, hero.team)
			spawn_ring_fx(hero.global_position, Color(0.4, 1.0, 0.6), ab.get("range", 14.0))
		"root":
			for u in all_units():
				if is_instance_valid(u) and not u.is_dead and u.team != hero.team:
					if u.global_position.distance_to(target_pos) <= ab.get("range", 16.0):
						u.apply_root(4.0)
			spawn_ring_fx(target_pos, Color(0.4, 0.8, 0.4), ab.get("range", 16.0))
		"avatar":
			hero.max_hp *= 1.5
			hero.hp = hero.max_hp
			hero.base_dmg *= 1.6
			if hero.model_root:
				var t := create_tween()
				t.tween_property(hero.model_root, "scale", hero.model_root.scale * 1.4, 0.4)
			spawn_ring_fx(hero.global_position, Color(1, 0.5, 0.9), 6.0)
			get_tree().create_timer(12.0).timeout.connect(func():
				if is_instance_valid(hero) and not hero.is_dead:
					hero.max_hp /= 1.5
					hero.hp = min(hero.hp, hero.max_hp)
					hero.base_dmg /= 1.6
					if hero.model_root:
						var t2 = hero.create_tween()
						t2.tween_property(hero.model_root, "scale", hero.model_root.scale / 1.4, 0.4)
			)

func _nearest_enemy_to(pos: Vector3, team: int, exclude: Array):
	var best = null
	var bolt_range := float(SkillDefs.get_abilities().get("bolt", {}).get("range", 20.0))
	var best_d := bolt_range * bolt_range
	for u in all_units():
		if not is_instance_valid(u) or u.is_dead or u.team == team or u in exclude:
			continue
		var d = pos.distance_squared_to(u.global_position)
		if d < best_d:
			best_d = d
			best = u
	return best

func _point_near_segment(p: Vector3, a: Vector3, b: Vector3, tol: float) -> bool:
	var ab := b - a
	var t := 0.0
	if ab.length_squared() > 0.0001:
		t = clamp((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
	var closest := a + ab * t
	return p.distance_to(closest) <= tol

# --------------------------------------------------------------------------
# FX (lightweight procedural)
# --------------------------------------------------------------------------
func spawn_hit_fx(pos: Vector3, kind: String) -> void:
	var col := Color(1, 0.8, 0.4)
	match kind:
		"cinder": col = Color(1, 0.5, 0.15)
		"void_bolt", "rift_shell": col = Color(0.7, 0.3, 0.9)
		"thorn", "thornpod": col = Color(0.5, 0.8, 0.4)
	_burst(pos, col, 6, 0.4)

func spawn_heal_fx(pos: Vector3) -> void:
	_burst(pos + Vector3.UP, Color(0.4, 1.0, 0.6), 5, 0.6)

func spawn_ring_fx(pos: Vector3, col: Color, radius: float) -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius * 0.7
	torus.outer_radius = radius
	ring.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.emission_enabled = true
	mat.emission = col
	mat.emission_energy_multiplier = 3.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.material_override = mat
	_fx_container.add_child(ring)
	ring.global_position = pos + Vector3.UP * 0.3
	ring.scale = Vector3(0.2, 0.2, 0.2)
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(ring, "scale", Vector3.ONE, 0.5)
	t.tween_property(mat, "albedo_color:a", 0.0, 0.6)
	t.chain().tween_callback(ring.queue_free)

func _burst(pos: Vector3, col: Color, count: int, life: float) -> void:
	var p := GPUParticles3D.new()
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 5.0
	mat.gravity = Vector3(0, -6, 0)
	mat.scale_min = 0.15
	mat.scale_max = 0.35
	mat.color = col
	p.process_material = mat
	var mesh := SphereMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.24
	var mm := StandardMaterial3D.new()
	mm.albedo_color = col
	mm.emission_enabled = true
	mm.emission = col
	mm.emission_energy_multiplier = 2.0
	mm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mm
	p.draw_pass_1 = mesh
	p.amount = count
	p.lifetime = life
	p.one_shot = true
	p.explosiveness = 0.9
	_fx_container.add_child(p)
	p.global_position = pos
	p.emitting = true
	get_tree().create_timer(life + 0.5).timeout.connect(p.queue_free)
