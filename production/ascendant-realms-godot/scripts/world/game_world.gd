extends Node3D
## GameWorld — the battle orchestrator. Builds terrain, navigation, environment,
## commanders, resource nodes, capture points; runs combat resolution, auras,
## fog-of-war bookkeeping, and victory/defeat. UI and input live in child nodes.
const CampaignDefs := preload("res://scripts/game/campaign_defs.gd")

const Unit := preload("res://scripts/units/unit.gd")
const Building := preload("res://scripts/buildings/building.gd")
const ProjectileScript := preload("res://scripts/units/projectile.gd")
const ResourceNodeScript := preload("res://scripts/world/resource_node.gd")
const CommandBusScript := preload("res://scripts/world/command_bus.gd")
const VeinScript := preload("res://scripts/world/vein.gd")
## Player orders as serialisable data (the seam for online play).
var command_bus = CommandBusScript.new(self)
const CapturePointScript := preload("res://scripts/world/capture_point.gd")
const WorldBlockerContract := preload("res://scripts/world/world_blocker_contract.gd")

const VISIBILITY_UNEXPLORED := 0
const VISIBILITY_EXPLORED_NOT_VISIBLE := 1
const VISIBILITY_CURRENTLY_VISIBLE := 2
const VISIBILITY_CELL_SIZE := 4.0
const VISIBILITY_VISUAL_CELL_STRIDE := 2
const VISIBILITY_UPDATE_INTERVAL := 0.2
const RESOURCE_GATHER_INTERACTION_RADIUS := 2.2
const RESOURCE_CORE_ROUTE_MARGIN := 0.12

signal game_over(victory: bool)
signal hero_leveled(level: int)
signal alert(message: String, pos: Vector3)
## Presentation cue for heavy impacts; the RTS camera turns it into a short shake.
signal camera_shake(strength: float, at: Vector3)

var map := {}
var commanders := []            # Commander instances indexed by team
var player_team := 0
var player_commander = null

var nav_region: NavigationRegion3D
var navigation_map_rid := RID()
var navigation_ready := false
var navigation_ready_frame := -1
var navigation_map_iteration := 0
## Static Astra presentation pieces that participate in the same deterministic
## route layer as completed buildings. They are cached once after composition
## build; no collision body or per-frame blocker reconstruction is required.
var _navigation_soft_blockers: Array[Dictionary] = []
## Runtime world blockers are deliberately owned here so buildings, resources,
## substantial environment props, and bridge supports share one collision and
## avoidance contract without changing their gameplay scripts or art assets.
var _world_blocker_root: Node3D
var _world_blocker_records: Dictionary = {}
var _world_route_blockers: Array[Dictionary] = []
var _route_cache_generation := 0
var _route_result_cache: Dictionary = {}
var _active_route_segment_cache: Dictionary = {}
var _environment_world_blocker_counts := {"vegetation": 0, "rocks": 0}
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
var _battle_loot: Array = []
## Simulation randomness comes from one match seed so every machine in a
## future online match (or a replay) makes the same choices.
var match_seed := 0
var _spawn_serial := 0
## Elite enemies slain by the player this battle: each adds a better loot roll.
var elites_slain := 0
## This battle's optional objective (picked from the match seed at the start).
var bounty := {}
var enemy_heroes_slain := 0

## A world event once per battle: the Lume surges from the ground somewhere
## near the middle of the field. The first side to hold it for 8 seconds
## takes its gift (resources, and hero experience for the player).
var _surge_pos := Vector3.ZERO
var _surge_hold := {}

func _schedule_lume_surge() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = sim_seed_for(9090)
	var at := 240.0 + rng.randf() * 360.0
	var ang := rng.randf() * TAU
	_surge_pos = Vector3(cos(ang), 0.0, sin(ang)) * rng.randf_range(10.0, 45.0)
	get_tree().create_timer(at, false).timeout.connect(_start_lume_surge)

func _start_lume_surge() -> void:
	if not game_running:
		return
	_surge_hold.clear()
	emit_signal("alert", "The Lume surges from the earth! Hold the light for its gift.", _surge_pos)
	Sfx.play("spell", -2.0)
	# The AI races for it too, with idle soldiers that are close enough.
	for cmd in commanders:
		if int(cmd.team) == player_team or cmd.defeated:
			continue
		var sent := 0
		for u in cmd.units:
			if sent >= 6:
				break
			if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero and u.state == u.State.IDLE and u.global_position.distance_to(_surge_pos) < 70.0:
				u.command_move(_surge_pos, true)
				sent += 1
	_tick_lume_surge(0)

func _tick_lume_surge(elapsed: int) -> void:
	if not game_running or elapsed > 90:
		return
	if elapsed % 2 == 0 and is_instance_valid(_fx_container):
		CombatVfx.lume_pillar(_fx_container, _surge_pos, Color(0.7, 0.85, 1.0))
	var present := {}
	for u in all_units():
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and u.global_position.distance_to(_surge_pos) < 6.0:
			present[int(u.team)] = true
	if present.size() == 1:
		var team: int = present.keys()[0]
		_surge_hold[team] = int(_surge_hold.get(team, 0)) + 1
		if int(_surge_hold[team]) >= 8:
			var cmd = commanders[team]
			cmd.add_resources("gold", 200)
			cmd.add_resources("food", 200)
			if team == player_team:
				ProfileManager.add_xp(80.0 + float(ProfileManager.hero().get("level", 1)) * 6.0)
				emit_signal("alert", "The Lume's gift is yours: 200 gold, 200 food and your hero grows wiser.", _surge_pos)
				Sfx.play("levelup", -4.0)
			else:
				emit_signal("alert", "The enemy seized the Lume's gift.", _surge_pos)
			return
	get_tree().create_timer(1.0, false).timeout.connect(_tick_lume_surge.bind(elapsed + 1))

func _pick_bounty() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = sim_seed_for(4242)
	var options := [
		{"id": "hero", "text": "Bounty: slay an enemy hero."},
		{"id": "swift", "minutes": 12 + rng.randi() % 7, "text": ""},
		{"id": "thrift", "losses": 8 + rng.randi() % 8, "text": ""},
		{"id": "raze", "count": 4 + rng.randi() % 5, "text": ""},
	]
	bounty = options[rng.randi() % options.size()]
	match String(bounty["id"]):
		"swift": bounty["text"] = "Bounty: win within %d minutes." % int(bounty["minutes"])
		"thrift": bounty["text"] = "Bounty: win losing no more than %d units." % int(bounty["losses"])
		"raze": bounty["text"] = "Bounty: raze %d enemy buildings." % int(bounty["count"])
	get_tree().create_timer(6.0, false).timeout.connect(func():
		if game_running:
			emit_signal("alert", String(bounty["text"]) + " Reward: extra spoils.", Vector3.ZERO))

func _bounty_met(victory: bool) -> bool:
	if not victory or bounty.is_empty():
		return false
	match String(bounty["id"]):
		"hero": return enemy_heroes_slain > 0
		"swift": return match_time <= float(bounty["minutes"]) * 60.0
		"thrift": return combat_death_events.filter(func(e): return int(e.get("victim_team", -1)) == player_team).size() <= int(bounty["losses"])
		"raze": return building_destruction_events.filter(func(e): return int(e.get("source_team", -1)) == player_team).size() >= int(bounty["count"])
	return false

## About one enemy soldier in 25 is an Elite: tougher, larger, gold-edged and
## worth extra loot. Chosen from the match seed and spawn order.
func _maybe_make_elite(u, team: int) -> void:
	if team == player_team or u.is_worker or u.is_hero or u.is_siege:
		return
	if absi(sim_seed_for(u.spawn_serial) % 100) >= 4:
		return
	u.set_meta("elite", true)
	u.max_hp *= 1.8
	u.hp = u.max_hp
	u.base_dmg *= 1.5
	if is_instance_valid(u.model_root):
		u.model_root.scale *= 1.18
		for mi in u.model_root.find_children("*", "GeometryInstance3D", true, false):
			var glow := StandardMaterial3D.new()
			glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			glow.albedo_color = Color(1.0, 0.78, 0.3, 0.22)
			glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
			glow.grow = true
			glow.grow_amount = 0.02
			mi.material_overlay = glow

func sim_seed_for(salt: int) -> int:
	if match_seed == 0:
		var cfg := Match.get_config()
		match_seed = int(cfg.get("seed", 0))
		if match_seed == 0:
			match_seed = absi(hash(str(cfg.get("map", "")) + str(cfg.get("opponents", [])) + str(cfg.get("player_race", "")))) + 1
	return match_seed * 31 + salt
# Battle story for the result ledger.
var hero_kills := 0
var veterans_made := 0
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
var _last_croft_frame := -1
var _last_croft_pos := Vector3.INF
var _build_transaction_seq := 0

# combat spatial helpers (rebuilt cheaply)
var _unit_cache_timer := 0.0

# Runtime-only player fog state. This is intentionally not part of saves and
# does not replace the authoritative omniscient AI queries.
var _visibility_states := PackedByteArray()
var _visibility_columns := 0
var _visibility_rows := 0
var _visibility_timer := 0.0
var _visibility_overlay: MeshInstance3D
## Top-down picture of the battlefield (terrain, water, trees, bases), rendered
## once at match start for the minimap. Null until the bake finishes.
var overview_texture: Texture2D = null
const GroundCoverScript := preload("res://scripts/world/ground_cover.gd")
var _ground_cover: Node3D = null
var _visibility_overlay_material: ShaderMaterial
var _visibility_image: Image
var _visibility_texture: ImageTexture

var _theme := {}
var _decor_material_cache := {}
# The Tripo foliage bakes are pale sage; deepen them toward highland greens.
const DECOR_FOLIAGE_TINTS := {
	"broadleaf_oak.glb": Color(0.58, 0.74, 0.46),
	"highland_pine.glb": Color(0.78, 0.90, 0.68),
}

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
	# Campaign chapters can set the hour and weather over the map's own light.
	var mood := battle_mood()
	if mood != "":
		_theme = _theme.duplicate(true)
		_theme.merge(CampaignDefs.MOODS[mood], true)
	_projectile_container = Node3D.new()
	_projectile_container.name = "Projectiles"
	add_child(_projectile_container)
	_fx_container = Node3D.new()
	_fx_container.name = "FX"
	# Effects animate with tweens every rendered frame, not on simulation ticks.
	_fx_container.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	add_child(_fx_container)
	_world_blocker_root = Node3D.new()
	_world_blocker_root.name = "WorldBlockers"
	add_child(_world_blocker_root)
	var environment_stage := _m20_begin("GAMEWORLD_ENVIRONMENT", "GAMEWORLD_READY", 1)
	_setup_environment()
	_m20_end(environment_stage)
	var terrain_stage := _m20_begin("GAMEWORLD_TERRAIN", "GAMEWORLD_READY", 1)
	_build_terrain()
	_m20_end(terrain_stage)
	_setup_player_visibility()
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
	_spawn_veins()
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

func visibility_grid_contract() -> Dictionary:
	return {"cell_size": VISIBILITY_CELL_SIZE, "columns": _visibility_columns, "rows": _visibility_rows, "minimum_x": playable_min.x, "maximum_x": playable_max.x, "minimum_z": playable_min.z, "maximum_z": playable_max.z, "states": _visibility_states.duplicate()}

var _no_fog_cached := -1

func _player_visibility_scope_active() -> bool:
	# Fog of war was scoped to Hollowspan while it was proven there; every
	# battlefield uses it now, so scouting matters on all twenty maps.
	# AI-versus-AI balance tests switch it off so both seats see alike.
	# Read once per match: Match.get_config() copies the whole config, and
	# this check runs for every unit every tick (it cost ~4 ms a frame).
	if _no_fog_cached < 0:
		_no_fog_cached = 1 if bool(Match.get_config().get("no_fog", false)) else 0
	return player_team == 0 and _no_fog_cached == 0

func _setup_player_visibility() -> void:
	_visibility_columns = maxi(1, int(ceil((playable_max.x - playable_min.x) / VISIBILITY_CELL_SIZE)))
	_visibility_rows = maxi(1, int(ceil((playable_max.z - playable_min.z) / VISIBILITY_CELL_SIZE)))
	_visibility_states.resize(_visibility_columns * _visibility_rows)
	for i in _visibility_states.size():
		_visibility_states[i] = VISIBILITY_UNEXPLORED
	_visibility_image = Image.create_from_data(_visibility_columns, _visibility_rows, false, Image.FORMAT_R8, _visibility_states)
	_visibility_texture = ImageTexture.create_from_image(_visibility_image)
	_visibility_overlay_material = ShaderMaterial.new()
	_visibility_overlay_material.shader = load("res://assets/shaders/fog_of_war.gdshader")
	_visibility_overlay_material.set_shader_parameter("visibility_states", _visibility_texture)
	_visibility_overlay_material.render_priority = 1
	var grid_size := Vector2(float(_visibility_columns) * VISIBILITY_CELL_SIZE, float(_visibility_rows) * VISIBILITY_CELL_SIZE)
	_visibility_overlay_material.set_shader_parameter("grid_origin", Vector2(playable_min.x, playable_min.z))
	_visibility_overlay_material.set_shader_parameter("grid_size", grid_size)
	var plane := PlaneMesh.new()
	# Overhang past the playable grid so the shroud blends into the scenery.
	plane.size = grid_size + Vector2(240.0, 240.0)
	_visibility_overlay = MeshInstance3D.new()
	_visibility_overlay.name = "PlayerVisibilityOverlay"
	_visibility_overlay.mesh = plane
	_visibility_overlay.material_override = _visibility_overlay_material
	_visibility_overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_visibility_overlay.position = Vector3(playable_min.x + grid_size.x * 0.5, 0.12, playable_min.z + grid_size.y * 0.5)
	add_child(_visibility_overlay)
	_refresh_player_visibility_overlay()

func _visibility_cell_index(position: Vector3) -> int:
	var column := int(floor((position.x - playable_min.x) / VISIBILITY_CELL_SIZE))
	var row := int(floor((position.z - playable_min.z) / VISIBILITY_CELL_SIZE))
	if column < 0 or column >= _visibility_columns or row < 0 or row >= _visibility_rows:
		return -1
	return row * _visibility_columns + column

func player_visibility_state_at(position: Vector3) -> int:
	if not _player_visibility_scope_active():
		return VISIBILITY_CURRENTLY_VISIBLE
	var index := _visibility_cell_index(position)
	return int(_visibility_states[index]) if index >= 0 and index < _visibility_states.size() else VISIBILITY_UNEXPLORED

func is_player_visible(target) -> bool:
	if not _player_visibility_scope_active() or not is_instance_valid(target):
		return true
	if target is ResourceNode:
		# Resources never move: once explored they stay on the map and can be
		# ordered, as in any RTS. Requiring live sight left workers idle beside
		# a remembered field and hid explored forests as soon as units left.
		return player_visibility_state_at(target.global_position) != VISIBILITY_UNEXPLORED
	if "team" in target and int(target.team) == player_team:
		return true
	return player_visibility_state_at(target.global_position) == VISIBILITY_CURRENTLY_VISIBLE

func _mark_visibility_radius(origin: Vector3, radius: float) -> void:
	var min_column := maxi(0, int(floor((origin.x - radius - playable_min.x) / VISIBILITY_CELL_SIZE)))
	var max_column := mini(_visibility_columns - 1, int(floor((origin.x + radius - playable_min.x) / VISIBILITY_CELL_SIZE)))
	var min_row := maxi(0, int(floor((origin.z - radius - playable_min.z) / VISIBILITY_CELL_SIZE)))
	var max_row := mini(_visibility_rows - 1, int(floor((origin.z + radius - playable_min.z) / VISIBILITY_CELL_SIZE)))
	var cell_radius := radius + VISIBILITY_CELL_SIZE * 0.72
	for row in range(min_row, max_row + 1):
		for column in range(min_column, max_column + 1):
			var center := Vector3(playable_min.x + (float(column) + 0.5) * VISIBILITY_CELL_SIZE, 0.0, playable_min.z + (float(row) + 0.5) * VISIBILITY_CELL_SIZE)
			if origin.distance_squared_to(center) <= cell_radius * cell_radius:
				_visibility_states[row * _visibility_columns + column] = VISIBILITY_CURRENTLY_VISIBLE

func _update_player_visibility() -> void:
	if not _player_visibility_scope_active():
		for u in all_units():
			if is_instance_valid(u) and u.has_method("set_player_visibility_visible"):
				u.set_player_visibility_visible(true)
		for b in all_buildings():
			if is_instance_valid(b) and b.has_method("set_player_visibility_visible"):
				b.set_player_visibility_visible(true)
		for resource in get_tree().get_nodes_in_group("resources"):
			if is_instance_valid(resource) and resource.has_method("set_player_visibility_visible"):
				resource.set_player_visibility_visible(true)
		if is_instance_valid(_visibility_overlay):
			_visibility_overlay.visible = false
		return
	for i in _visibility_states.size():
		if _visibility_states[i] == VISIBILITY_CURRENTLY_VISIBLE:
			_visibility_states[i] = VISIBILITY_EXPLORED_NOT_VISIBLE
	for u in all_units():
		if is_instance_valid(u) and not u.is_dead and u.team == player_team and not u._is_defeated_remnant():
			_mark_visibility_radius(u.global_position, maxf(1.0, float(u.vision)))
	for u in all_units():
		if is_instance_valid(u) and u.has_method("set_player_visibility_visible"):
			u.set_player_visibility_visible(is_player_visible(u))
	for b in all_buildings():
		if is_instance_valid(b) and b.has_method("set_player_visibility_visible"):
			b.set_player_visibility_visible(is_player_visible(b))
	for resource in get_tree().get_nodes_in_group("resources"):
		if is_instance_valid(resource) and resource.has_method("set_player_visibility_visible"):
			resource.set_player_visibility_visible(is_player_visible(resource))
	if is_instance_valid(_visibility_overlay):
		_visibility_overlay.visible = true
		_refresh_player_visibility_overlay()

func _refresh_player_visibility_overlay() -> void:
	if not is_instance_valid(_visibility_overlay) or _visibility_texture == null:
		return
	# The state bytes are the texture data; the fog shader maps them to colour.
	_visibility_image.set_data(_visibility_columns, _visibility_rows, false, Image.FORMAT_R8, _visibility_states)
	_visibility_texture.update(_visibility_image)

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
	env.fog_aerial_perspective = float(_theme.get("fog_aerial_perspective", 0.0))
	env.fog_sun_scatter = float(_theme.get("fog_sun_scatter", 0.0))
	if _theme.has("ambient_color"):
		env.ambient_light_color = _theme["ambient_color"]
		env.ambient_light_sky_contribution = float(_theme.get("ambient_sky_contribution", 1.0))
	if bool(_theme.get("ssao", false)):
		# Contact shadows seat props, units and building footings on the ground.
		env.ssao_enabled = graphics_quality() != "low"
		env.ssao_radius = 1.4
		env.ssao_intensity = 1.8
		env.ssao_power = 1.6
		env.ssao_detail = 0.5
		env.ssao_light_affect = 0.15
	if bool(_theme.get("glow", false)):
		# Only genuinely bright pixels bloom: sunlit highlights, lit windows, fire.
		env.glow_enabled = true
		env.glow_intensity = 0.55
		env.glow_strength = 0.9
		env.glow_bloom = 0.0
		env.glow_hdr_threshold = 1.15
		env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	if _theme.has("grade_contrast"):
		env.adjustment_enabled = true
		env.adjustment_contrast = float(_theme["grade_contrast"])
		env.adjustment_saturation = float(_theme.get("grade_saturation", 1.0))
		env.adjustment_brightness = float(_theme.get("grade_brightness", 1.0))
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(float(_theme.get("sun_pitch", -52.0)), float(_theme.get("sun_yaw", 40.0)), 0)
	sun.light_energy = float(_theme.get("sun_energy", 1.0))
	sun.light_color = _theme.get("sun_color", Color(0.96, 0.94, 0.88))
	var quality := graphics_quality()
	sun.shadow_enabled = quality != "low"
	# Two cascades are enough for the RTS camera: the four-split default drew
	# every shadow caster four times (about a third of all draw calls).
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = 140.0 if quality == "high" else 110.0
	sun.directional_shadow_split_1 = 0.35
	add_child(sun)

func _build_terrain() -> void:
	var size: float = map["size"] * 2.0

	# Scenery: textured path-veined ground, mountain ring, forest foothills, lake.
	# All decoration around a flat playable core — pathing is unchanged.
	var tb := TerrainBuilder.new()
	tb.name = "Scenery"
	add_child(tb)
	tb.build(map)
	if map.get("id", "") == "hollowspan":
		var ring := tb.get_node_or_null("MountainRing") as MeshInstance3D
		if ring and ring.material_override is StandardMaterial3D:
			# Hollowspan's perimeter source is the shared rock ring, not an Astra
			# asset. Keep its authored texture while correcting the pale value range
			# locally for the Barrosan starting map.
			var ring_material := (ring.material_override as StandardMaterial3D).duplicate() as StandardMaterial3D
			ring_material.albedo_color = Color(0.48, 0.40, 0.34, 1.0)
			ring.material_override = ring_material

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
		_tint_hollowspan_bridge(b)
		_register_bridge_structural_blockers(b)

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
		var pick := rng.randf()
		# Corner starts sit inside this belt; keep their yards clear of trees.
		if _near_any_start(pos, starts, 30.0):
			continue
		_place_decor(decor, (trees if pick < 0.62 else rocks), pos, rng)
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
		var pick := rng.randf()
		if _near_any_start(pos, starts, 30.0):
			continue
		_place_decor(decor, (trees if pick < 0.72 else rocks), pos, rng)
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
	_build_visual_convergence_hollowspan(decor, starts)
	_ground_cover = GroundCoverScript.new()
	_ground_cover.name = "GroundCover"
	add_child(_ground_cover)
	# Merge the static base dressing into a few meshes per material.
	var batcher = load("res://scripts/world/static_batcher.gd")
	for layer in decor.find_children("*", "Node3D", true, false):
		if String(layer.name) in ["BarrosanHamlet", "VorthakHoldfast", "LioraenGrove", "BarrosanEnvironmentR2Dressing", "AstraBarrosanSettlementFirstWave"]:
			batcher.batch(layer)
	var quality := graphics_quality()
	if quality != "low":
		_ground_cover.build(map, str(map.get("theme", "highland")), 0.5 if quality == "medium" else 1.0)
		var weather: Node3D = load("res://scripts/world/ambient_weather.gd").new()
		weather.name = "AmbientWeather"
		add_child(weather)
		weather.build(str(map.get("theme", "highland")), battle_mood())
		# Medium quality keeps the weather but at half the particles (storm rain is 1,500).
		if quality == "medium":
			for ps in weather.find_children("*", "GPUParticles3D", true, false):
				ps.amount = maxi(20, ps.amount / 2)

## Battlefield ambience (wind, birds, crackle, the highland recording).
func _start_ambient_sound() -> void:
	var amb: Node = load("res://scripts/world/ambient_sound.gd").new()
	amb.name = "AmbientSound"
	add_child(amb)
	amb.build(str(map.get("theme", "highland")), battle_mood())

## The player's Graphics Quality setting: "low", "medium" or "high".
func graphics_quality() -> String:
	return String(ProfileManager.settings().get("graphics", "high"))

## Clears grass and flowers inside a circle, e.g. under a new building.
func clear_ground_cover(pos: Vector3, radius: float) -> void:
	if is_instance_valid(_ground_cover):
		_ground_cover.clear_circle(pos, radius)


func _build_visual_convergence_hollowspan(parent: Node3D, starts: Array) -> void:
	# Slice 1 is a presentation-only authored layer for the Barrosan starting
	# base on Hollowspan. These shallow opaque meshes have no collision, are not
	# part of the navmesh, and do not replace any authoritative map geometry.
	if starts.is_empty():
		return
	var origin: Vector3 = starts[0]
	if map.get("id", "") != "hollowspan":
		# Other battlefields get each faction's start dressing (hamlet, grove,
		# holdfast) so no base stands alone on an empty plain.
		var kit = load("res://scripts/world/hollowspan_environment_composition.gd").new()
		var race_list: Array = [String(Match.get_config().get("player_race", "barrosan"))]
		for opponent in Match.get_config().get("opponents", []):
			race_list.append(String(opponent.get("race", "")))
		for i in mini(starts.size(), race_list.size()):
			kit.build_faction_start(parent, starts[i], race_list[i])
		_rebuild_navigation_soft_blockers()
		return
	var layer := Node3D.new()
	layer.name = "VisualConvergenceBarrosanBase"
	parent.add_child(layer)
	# The authored Astra pieces now provide the settlement edge. The old straight
	# rails read as a second artificial perimeter and competed with the threshold.
	var composition_script = load("res://scripts/world/hollowspan_environment_composition.gd")
	if composition_script:
		var composition = composition_script.new()
		composition.build(parent, origin, map, String(Match.get_config().get("player_race", "barrosan")))
		# Opponent starts get their own faction dressing where a kit exists.
		var opponents: Array = Match.get_config().get("opponents", [])
		for i in range(1, starts.size()):
			if i - 1 < opponents.size() and str(opponents[i - 1].get("race", "")) == "vorthak":
				composition.build_vorthak_holdfast(parent, starts[i])
			elif i - 1 < opponents.size() and str(opponents[i - 1].get("race", "")) == "lioraen":
				composition.build_lioraen_grove(parent, starts[i])
		_rebuild_navigation_soft_blockers()


func _rebuild_navigation_soft_blockers() -> void:
	_navigation_soft_blockers.clear()
	for node in get_tree().get_nodes_in_group("navigation_soft_blockers"):
		if not is_instance_valid(node) or not node is Node3D:
			continue
		var bounds := _visible_world_xz_bounds(node as Node3D)
		if bounds.is_empty():
			continue
		_navigation_soft_blockers.append({
			"node": node,
			"object_id": String(node.get_meta("navigation_blocker_id", node.name)),
			"object_class": String(node.get_meta("navigation_blocker_class", "ASTRA_LARGE")),
			"center": bounds["center"],
			"half_extents": bounds["half_extents"],
			"source": "astra_presentation_cache",
		})
		_register_environment_world_blocker(node, "presentation", "presentation")
	_invalidate_route_result_cache()


func _world_blocker_key(owner: Node, blocker_id: String) -> String:
	return "%s:%s" % [str(owner.get_instance_id()), blocker_id]


func _register_navigation_obstacle(owner: Node3D, blocker_id: String, center: Vector3, half_extents: Vector2, height: float, object_class: String, source: String, collision_layer: int, create_physics_body: bool = false, physics_node: Node = null) -> void:
	if not is_instance_valid(owner) or not is_instance_valid(_world_blocker_root):
		return
	var key := _world_blocker_key(owner, blocker_id)
	if _world_blocker_records.has(key):
		return
	var safe_half := Vector2(maxf(0.5, half_extents.x), maxf(0.5, half_extents.y))
	var safe_height := maxf(1.0, height)
	var blocker_body: StaticBody3D = null
	if create_physics_body:
		blocker_body = StaticBody3D.new()
		blocker_body.name = "WorldBlocker_%s" % blocker_id
		blocker_body.collision_layer = collision_layer
		blocker_body.collision_mask = WorldBlockerContract.UNIT_LAYER
		blocker_body.position = Vector3(center.x, safe_height * 0.5, center.z)
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(safe_half.x * 2.0, safe_height, safe_half.y * 2.0)
		shape.shape = box
		blocker_body.add_child(shape)
		_world_blocker_root.add_child(blocker_body)
	var obstacle := NavigationObstacle3D.new()
	obstacle.name = "NavigationObstacle_%s" % blocker_id
	obstacle.avoidance_enabled = true
	obstacle.radius = maxf(0.5, maxf(safe_half.x, safe_half.y))
	obstacle.height = safe_height
	obstacle.position = Vector3(center.x, 0.0, center.z)
	_world_blocker_root.add_child(obstacle)
	_world_blocker_records[key] = {
		"owner": owner,
		"body": blocker_body,
		"obstacle": obstacle,
		"physics_node": physics_node,
		"object_class": object_class,
		"center": Vector3(center.x, 0.0, center.z),
		"half_extents": safe_half,
		"source": source,
	}
	var route_node: Node = blocker_body if blocker_body else owner
	_world_route_blockers.append({
		"node": route_node,
		"owner": owner,
		"object_id": "%s_%s" % [object_class.to_lower(), blocker_id],
		"object_class": object_class,
		"center": Vector3(center.x, 0.0, center.z),
		"half_extents": safe_half,
		"source": source,
	})
	_invalidate_route_result_cache()


func _unregister_world_blocker(owner: Node) -> void:
	if not is_instance_valid(owner):
		return
	var changed := false
	var remove_keys: Array[String] = []
	for key in _world_blocker_records.keys():
		var record: Dictionary = _world_blocker_records[key]
		if record.get("owner") != owner:
			continue
		remove_keys.append(String(key))
		changed = true
		for field in ["body", "obstacle", "physics_node"]:
			var node = record.get(field)
			if is_instance_valid(node):
				node.queue_free()
	for key in remove_keys:
		_world_blocker_records.erase(key)
	for index in range(_world_route_blockers.size() - 1, -1, -1):
		if _world_route_blockers[index].get("owner") == owner:
			_world_route_blockers.remove_at(index)
			changed = true
	if changed:
		_invalidate_route_result_cache()
	if owner is Building:
		for collision_object in owner.find_children("*", "CollisionObject3D", true, false):
			collision_object.set_deferred("collision_layer", 0)
			collision_object.set_deferred("collision_mask", 0)


func _building_world_blocker_half_extents(building: Building) -> Vector2:
	var half_extents := Vector2(float(building.def.get("footprint", 4.0)), float(building.def.get("footprint", 4.0)))
	if building.has_method("get_selection_geometry"):
		var geometry: Dictionary = building.get_selection_geometry()
		var visual_extents: Dictionary = geometry.get("visual_extents", {})
		half_extents.x = maxf(half_extents.x, float(visual_extents.get("x", half_extents.x)))
		half_extents.y = maxf(half_extents.y, float(visual_extents.get("z", half_extents.y)))
	return half_extents


func _register_building_world_blocker(building: Building) -> void:
	if not is_instance_valid(building) or building.is_dead:
		return
	_register_navigation_obstacle(building, "building_core", building.global_position, _building_world_blocker_half_extents(building), maxf(2.0, building.footprint * 1.4), "BUILDING" if building.is_built else "CONSTRUCTION_SITE", "building_world_blocker", WorldBlockerContract.BUILDING_BLOCKER_LAYER)


func _is_substantial_environment_asset(path: String) -> bool:
	return "/environment/vegetation/" in path or "/environment/rocks/" in path or "/environment/structures/" in path


func _register_environment_world_blocker(node: Node3D, blocker_id: String, asset_class: String = "") -> void:
	if not is_instance_valid(node) or not is_inside_playable_bounds(node.global_position, 1.0):
		return
	if asset_class == "vegetation" and int(_environment_world_blocker_counts["vegetation"]) >= 3:
		return
	if asset_class == "rocks" and int(_environment_world_blocker_counts["rocks"]) >= 4:
		return
	var bounds := _visible_world_xz_bounds(node)
	if bounds.is_empty():
		return
	var half_extents: Vector2 = bounds["half_extents"]
	# Keep malformed or aggregate imported scenery out of the blocker contract;
	# only substantial individual props and authored structural pieces qualify.
	if half_extents.x > 14.0 or half_extents.y > 14.0:
		return
	_register_navigation_obstacle(node, blocker_id, bounds["center"], half_extents, 3.0, "ENVIRONMENT_PROP", "environment_world_blocker", WorldBlockerContract.WORLD_BLOCKER_LAYER, true)
	if asset_class == "vegetation" or asset_class == "rocks":
		_environment_world_blocker_counts[asset_class] = int(_environment_world_blocker_counts[asset_class]) + 1


func _register_bridge_structural_blockers(bridge: Node3D) -> void:
	if not is_instance_valid(bridge):
		return
	# The bridge deck stays open. Two narrow side strips model the substantial
	# rails/supports that units must not pass through while crossing Hollowspan.
	for side in [-1, 1]:
		var center := bridge.global_position + Vector3(5.35 * float(side), 0.0, 0.0)
		_register_navigation_obstacle(bridge, "bridge_structure_%s" % ("west" if side < 0 else "east"), center, Vector2(1.0, 13.0), 3.6, "BRIDGE_STRUCTURE", "hollowspan_bridge_structure", WorldBlockerContract.WORLD_BLOCKER_LAYER, true)


func _resource_core_half_extents(kind: String, visible_half: Vector2) -> Vector2:
	# Resource meshes include decorative shoulders and imported bounds that are
	# larger than the usable mineral mass. Keep a compact central route core so
	# ordinary units cannot cross the deposit while Workers can still approach
	# within the existing 2.2m gathering interaction radius.
	var x := clampf(visible_half.x * 0.35, 0.55, 0.78)
	var z := clampf(visible_half.y * 0.35, 0.55, 0.78)
	if kind == "gold":
		x = clampf(visible_half.x * 0.42, 0.55, 0.70)
		z = clampf(visible_half.y * 0.42, 0.55, 0.70)
	return Vector2(x, z)


func _register_resource_navigation_blocker(node: ResourceNode) -> void:
	if not is_instance_valid(node) or node.depleted:
		return
	var bounds := _visible_world_xz_bounds(node)
	var center := node.global_position
	var visible_half := Vector2(node.footprint, node.footprint)
	if not bounds.is_empty():
		center = bounds["center"]
		visible_half = bounds["half_extents"]
	var core_half := _resource_core_half_extents(node.resource_kind, visible_half)
	_navigation_soft_blockers.append({
		"node": node,
		"object_id": "resource_%s_%s" % [node.resource_kind, str(node.get_instance_id())],
		"object_class": "RESOURCE_NODE",
		"center": center,
		"half_extents": core_half,
		"core_half_extents": core_half,
		"visible_half_extents": visible_half,
		"resource_kind": node.resource_kind,
		"gather_interaction_radius": RESOURCE_GATHER_INTERACTION_RADIUS,
		"source": "resource_core",
	})
	_invalidate_route_result_cache()
	var core_shape := CollisionShape3D.new()
	core_shape.name = "ResourceCoreBlocker"
	var core_box := BoxShape3D.new()
	core_box.size = Vector3(core_half.x * 2.0, 2.0, core_half.y * 2.0)
	core_shape.shape = core_box
	core_shape.position = Vector3(center.x - node.global_position.x, 1.0, center.z - node.global_position.z)
	node.add_child(core_shape)
	_register_navigation_obstacle(node, "resource_core", center, core_half, 2.0, "RESOURCE_NODE", "resource_core", WorldBlockerContract.RESOURCE_BLOCKER_LAYER, false, core_shape)
	node.depleted_once.connect(_on_resource_depleted_navigation_blocker)
	node.depleted_once.connect(_on_resource_depleted_notice)

## The home food node running dry is the economy's turning point (every unit
## eats), so tell the player once what feeds an army after it.
var _told_food_dry := false

func _on_resource_depleted_notice(node: ResourceNode) -> void:
	if _told_food_dry or node.resource_kind != "food" or bool(Match.get_config().get("no_veins", false)):
		return
	var starts: Array = map.get("start_positions", [])
	if player_team < 0 or player_team >= starts.size():
		return
	if node.global_position.distance_to(starts[player_team]) > 45.0:
		return
	_told_food_dry = true
	emit_signal("alert", "The food by your hall is gone. Houses keep a garden; claim a food vein or trade gold at the caravan.", node.global_position)

func _on_resource_depleted_navigation_blocker(node: ResourceNode) -> void:
	var changed := false
	for index in range(_navigation_soft_blockers.size() - 1, -1, -1):
		if _navigation_soft_blockers[index].get("node") == node:
			_navigation_soft_blockers.remove_at(index)
			changed = true
	if changed:
		_invalidate_route_result_cache()
	_unregister_world_blocker(node)


func _visible_world_xz_bounds(root: Node3D) -> Dictionary:
	var min_x := INF
	var max_x := -INF
	var min_z := INF
	var max_z := -INF
	var found := false
	var meshes: Array[Node] = []
	if root is MeshInstance3D:
		meshes.append(root)
	meshes.append_array(root.find_children("*", "MeshInstance3D", true, false))
	for child in meshes:
		var mesh_instance := child as MeshInstance3D
		if not mesh_instance or not mesh_instance.mesh or not mesh_instance.visible:
			continue
		var mesh_aabb := mesh_instance.mesh.get_aabb()
		for x in [mesh_aabb.position.x, mesh_aabb.end.x]:
			for z in [mesh_aabb.position.z, mesh_aabb.end.z]:
				var point: Vector3 = mesh_instance.global_transform * Vector3(x, 0.0, z)
				min_x = minf(min_x, point.x)
				max_x = maxf(max_x, point.x)
				min_z = minf(min_z, point.z)
				max_z = maxf(max_z, point.z)
				found = true
	if not found:
		return {}
	return {
		# Route geometry is planar X/Z data. Keep the waypoint on the unit ground
		# plane even when an imported mesh's visual AABB has a raised midpoint.
		"center": Vector3((min_x + max_x) * 0.5, 0.0, (min_z + max_z) * 0.5),
		"half_extents": Vector2((max_x - min_x) * 0.5, (max_z - min_z) * 0.5),
	}


func _visual_convergence_material(name: String, color: Color, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.resource_name = name
	mat.albedo_color = color
	mat.roughness = roughness
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	return mat


func _add_visual_convergence_apron(parent: Node3D, position: Vector3, size: Vector2, rotation_y: float, mat: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(size.x, 0.035, size.y)
	var mi := MeshInstance3D.new()
	mi.name = "BuildingApron"
	mi.mesh = mesh
	mi.position = position + Vector3(0.0, 0.02, 0.0)
	mi.rotation.y = rotation_y
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)


func _add_visual_convergence_path(parent: Node3D, from: Vector3, to: Vector3, width: float, mat: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, 0.04, from.distance_to(to))
	var mi := MeshInstance3D.new()
	mi.name = "WornPath"
	mi.mesh = mesh
	mi.position = from.lerp(to, 0.5) + Vector3(0.0, 0.025, 0.0)
	mi.rotation.y = atan2(to.x - from.x, to.z - from.z)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)


func _tint_hollowspan_bridge(root: Node) -> void:
	# The imported bridge texture is materially pale at the Hollowspan RTS
	# camera. Preserve its authored detail while bringing the bridge into the
	# existing Barrosan slate/timber value range. This is presentation-only.
	var mesh_nodes := root.find_children("*", "MeshInstance3D")
	if root is MeshInstance3D:
		mesh_nodes.push_front(root)
	for child in mesh_nodes:
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		var source_material: Material = mesh_instance.get_active_material(0)
		if not source_material is StandardMaterial3D:
			continue
		var bridge_material: StandardMaterial3D = source_material.duplicate() as StandardMaterial3D
		bridge_material.albedo_color = Color(0.34, 0.24, 0.16, 1.0)
		mesh_instance.set_surface_override_material(0, bridge_material)
		mesh_instance.material_override = bridge_material


func _add_visual_convergence_post(parent: Node3D, position: Vector3, mat: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.12
	mesh.bottom_radius = 0.18
	mesh.height = 1.1
	mesh.radial_segments = 8
	var mi := MeshInstance3D.new()
	mi.name = "TimberBoundaryPost"
	mi.mesh = mesh
	mi.position = position + Vector3(0.0, 0.55, 0.0)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)


func _add_visual_convergence_rail(parent: Node3D, from: Vector3, to: Vector3, mat: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.16, 0.16, from.distance_to(to))
	var mi := MeshInstance3D.new()
	mi.name = "TimberBoundaryRail"
	mi.mesh = mesh
	mi.position = from.lerp(to, 0.5) + Vector3(0.0, 0.58, 0.0)
	mi.rotation.y = atan2(to.x - from.x, to.z - from.z)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)


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

func _near_any_start(pos: Vector3, starts: Array, radius: float) -> bool:
	for s in starts:
		if pos.distance_to(s) < radius:
			return true
	return false

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
	# Keep trees and boulders out of the river ford on bridge maps.
	if map.has("bridge") and _theme.get("water", {}).get("enabled", false):
		var ov: Dictionary = map.get("overview", {})
		if absf(pos.z - float(ov.get("water_center_z", 52.0))) < float(ov.get("water_width", 22.0)) * 0.6:
			return
	var path: String = pool[rng.randi() % pool.size()]
	var load_start := Time.get_ticks_usec()
	var inst = load(path).instantiate()
	_m20_record_resource(path, "game_world._place_decor", load_start, Time.get_ticks_usec(), "load_instantiate")
	parent.add_child(inst)
	inst.position = pos
	var is_tree: bool = "vegetation" in path
	# Oaks spread about as wide as they are tall; at 6.5-10.5 m a single
	# canopy covered a whole squad. Slightly smaller trees keep the woodland
	# read while leaving fights visible.
	var h: float = (rng.randf_range(5.0, 7.5) if "oak" in path else rng.randf_range(6.0, 9.0)) if is_tree else rng.randf_range(1.6, 3.6)
	ModelUtils.scale_to_height(inst, h)
	ModelUtils.ground_model(inst)
	inst.rotation.y = rng.randf() * TAU
	_prep_decor(inst, DECOR_FOLIAGE_TINTS.get(path.get_file(), Color.WHITE), h if is_tree else 0.0)
	if _is_substantial_environment_asset(path) and is_inside_playable_bounds(pos, 1.0):
		_register_environment_world_blocker(inst, "decor_%s" % str(inst.get_instance_id()), "vegetation" if "/environment/vegetation/" in path else "rocks")

func _prep_decor(n: Node, tint: Color = Color.WHITE, tree_height: float = 0.0) -> void:
	if n is CollisionObject3D:
		n.set_deferred("collision_layer", 0)
		n.set_deferred("collision_mask", 0)
	if n is GeometryInstance3D:
		n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if n is MeshInstance3D:
		_apply_p1r14_decor_material_tone(n, tint, tree_height)
	for c in n.get_children():
		_prep_decor(c, tint, tree_height)

func _apply_p1r14_decor_material_tone(mesh: MeshInstance3D, tint: Color = Color.WHITE, tree_height: float = 0.0) -> void:
	# The Tripo vegetation and rock exports declare metallic 1.0 with a packed
	# roughness/metal map and emission on. Foliage then mirrors the sky and reads
	# pale teal. Decor is never metal, so each shared source material gets one
	# cached dielectric copy (instances keep sharing it for batching).
	if mesh.mesh != null and mesh.material_override == null:
		for surface in mesh.mesh.get_surface_count():
			if mesh.get_surface_override_material(surface) != null:
				continue
			var source := mesh.mesh.surface_get_material(surface)
			var fixed := _foliage_wind_material(source, tint, tree_height) if tree_height > 0.0 else _dielectric_decor_material(source, tint)
			if fixed != source:
				mesh.set_surface_override_material(surface, fixed)
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

const FOLIAGE_WIND_SHADER := preload("res://assets/shaders/foliage_wind.gdshader")

## Trees get a wind-and-canopy shader built from their imported material. One
## cached material per (source, tint, height band) so trees keep sharing.
func _foliage_wind_material(source: Material, tint: Color, tree_height: float) -> Material:
	if not source is StandardMaterial3D:
		return _dielectric_decor_material(source, tint)
	var standard := source as StandardMaterial3D
	if standard.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		return _dielectric_decor_material(source, tint)
	var band := snappedf(tree_height, 1.0)
	var key := [standard, tint, band]
	if _decor_material_cache.has(key):
		return _decor_material_cache[key]
	var m := ShaderMaterial.new()
	m.shader = FOLIAGE_WIND_SHADER
	m.set_shader_parameter("albedo_tex", standard.albedo_texture)
	m.set_shader_parameter("has_texture", standard.albedo_texture != null)
	# Same muted grade the R14 pass gives other decor.
	m.set_shader_parameter("albedo_color", (standard.albedo_color * tint).lerp(Color(0.60, 0.64, 0.56), 0.16))
	m.set_shader_parameter("uv_scale", standard.uv1_scale)
	m.set_shader_parameter("roughness_value", maxf(standard.roughness, 0.82))
	m.set_shader_parameter("tree_height", band)
	_decor_material_cache[key] = m
	return m

func _dielectric_decor_material(source: Material, tint: Color = Color.WHITE) -> Material:
	if not source is StandardMaterial3D:
		return source
	var standard := source as StandardMaterial3D
	if standard.metallic <= 0.05 and standard.metallic_texture == null and not standard.emission_enabled and tint == Color.WHITE:
		return source
	var key := [standard, tint]
	if _decor_material_cache.has(key):
		return _decor_material_cache[key]
	var copy := standard.duplicate() as StandardMaterial3D
	copy.metallic = 0.0
	copy.metallic_texture = null
	copy.metallic_specular = 0.35
	copy.emission_enabled = false
	copy.albedo_color *= tint
	_decor_material_cache[key] = copy
	return copy

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
## buildings and explicitly designated large Astra scenery need a small
## deterministic route layer on top of it. The route envelope is rectangular
## and derived from the visible world bounds, so a detour cannot cut through a
## rectangular wall, building, tower, or wagon corner. It only returns
## waypoints; it does not mutate gameplay state, placement geometry, or the
## authoritative map.
const ROUTE_BLOCKER_MARGIN := 0.35
const ROUTE_CACHE_BUCKET_SIZE := 0.5
const ROUTE_CACHE_MAX_ENTRIES := 512
const ROUTE_CACHE_MAX_AGE_FRAMES := 30
const ROUTE_CACHE_FAILED_MAX_AGE_FRAMES := 1
const ROUTE_SOLVER_BUDGET_USEC := 14000
const ROUTE_WAYPOINT_STOP_MARGIN := 1.5

func _invalidate_route_result_cache() -> void:
	_route_cache_generation += 1
	_route_result_cache.clear()

func _route_result_cache_key(origin: Vector3, requested: Vector3, clearance: float, building_snapshot, movement_reason: String, target_blocker = null) -> String:
	# Explicit building snapshots can represent a caller-owned view that is not
	# covered by the world's topology generation, so leave those requests uncached.
	if building_snapshot != null or not origin.is_finite() or not requested.is_finite():
		return ""
	var origin_x := roundi(origin.x / ROUTE_CACHE_BUCKET_SIZE)
	var origin_z := roundi(origin.z / ROUTE_CACHE_BUCKET_SIZE)
	var target_x := roundi(requested.x / ROUTE_CACHE_BUCKET_SIZE)
	var target_z := roundi(requested.z / ROUTE_CACHE_BUCKET_SIZE)
	var origin_y := roundi(origin.y * 2.0)
	var target_y := roundi(requested.y * 2.0)
	var clearance_bucket := roundi(clearance * 100.0)
	var target_blocker_key := str(target_blocker.get_instance_id()) if is_instance_valid(target_blocker) else ""
	return "%d|%d,%d,%d|%d,%d,%d|%d|%s|%s" % [_route_cache_generation, origin_x, origin_z, origin_y, target_x, target_z, target_y, clearance_bucket, movement_reason if movement_reason != "" else "OTHER", target_blocker_key]

func _route_result_cache_lookup(cache_key: String, origin: Vector3, requested: Vector3) -> Array:
	if cache_key == "" or not _route_result_cache.has(cache_key):
		return []
	var entry: Dictionary = _route_result_cache[cache_key]
	var frame := Engine.get_process_frames()
	var max_age := ROUTE_CACHE_FAILED_MAX_AGE_FRAMES if bool(entry.get("failed", false)) else ROUTE_CACHE_MAX_AGE_FRAMES
	if frame - int(entry.get("frame", -999999)) > max_age:
		_route_result_cache.erase(cache_key)
		return []
	var cached_origin: Vector3 = entry.get("origin", Vector3.INF)
	var cached_target: Vector3 = entry.get("requested", Vector3.INF)
	if cached_origin.distance_to(origin) > ROUTE_CACHE_BUCKET_SIZE * 0.5 or cached_target.distance_to(requested) > ROUTE_CACHE_BUCKET_SIZE * 0.5:
		_route_result_cache.erase(cache_key)
		return []
	var points: Array = entry.get("points", [])
	return points.duplicate()

func _route_result_cache_store(cache_key: String, origin: Vector3, requested: Vector3, points: Array, failed: bool = false) -> void:
	if cache_key == "" or points.is_empty():
		return
	if _route_result_cache.size() >= ROUTE_CACHE_MAX_ENTRIES:
		var oldest_key := ""
		var oldest_frame := Engine.get_process_frames() + 1
		for key in _route_result_cache.keys():
			var entry: Dictionary = _route_result_cache[key]
			var entry_frame := int(entry.get("frame", -999999))
			if entry_frame < oldest_frame:
				oldest_frame = entry_frame
				oldest_key = String(key)
		if oldest_key != "":
			_route_result_cache.erase(oldest_key)
	_route_result_cache[cache_key] = {
		"origin": origin,
		"requested": requested,
		"points": points.duplicate(),
		"frame": Engine.get_process_frames(),
		"failed": failed,
	}

func _route_search_blocker_broadphase(origin: Vector3, requested: Vector3, clearance: float, blockers: Array[Dictionary], target_blocker = null) -> Dictionary:
	var max_expanded_extent := 0.0
	for blocker in blockers:
		var expanded: Vector2 = _route_blocker_half_extents(blocker, clearance)
		max_expanded_extent = maxf(max_expanded_extent, maxf(expanded.x, expanded.y))
	var margin := maxf(clearance + ROUTE_BLOCKER_MARGIN + ROUTE_WAYPOINT_STOP_MARGIN, max_expanded_extent + ROUTE_WAYPOINT_STOP_MARGIN)
	var region_min := Vector3(minf(origin.x, requested.x) - margin, 0.0, minf(origin.z, requested.z) - margin)
	var region_max := Vector3(maxf(origin.x, requested.x) + margin, 0.0, maxf(origin.z, requested.z) + margin)
	var filtered: Array[Dictionary] = []
	var excluded: Array[Dictionary] = []
	for blocker in blockers:
		var node = blocker.get("node")
		var owner = blocker.get("owner")
		var target_match: bool = is_instance_valid(target_blocker) and (owner == target_blocker or node == target_blocker)
		var center: Vector3 = blocker.get("center", Vector3.INF)
		var expanded: Vector2 = _route_blocker_half_extents(blocker, clearance)
		var intersects_region := not (center.x + expanded.x < region_min.x or center.x - expanded.x > region_max.x or center.z + expanded.y < region_min.z or center.z - expanded.y > region_max.z)
		if target_match or intersects_region:
			filtered.append(blocker)
		else:
			excluded.append(blocker)
	return {"blockers": filtered, "excluded": excluded, "region_min": region_min, "region_max": region_max, "margin": margin}

func navigation_waypoints_for_unit(origin: Vector3, requested: Vector3, clearance: float = 1.0, building_snapshot = null, movement_reason: String = "OTHER", target_blocker = null) -> Array:
	var __started := Time.get_ticks_usec()
	var __result := _solve_navigation_waypoints(origin, requested, clearance, building_snapshot, movement_reason, target_blocker)
	_note_route_solver_time(Time.get_ticks_usec() - __started)
	return __result

# Frame budget for the authored route solver. In a big battle dozens of units
# asked for routes in the same frame (1-14 ms each), stalling frames by
# 150-250 ms at 4x. Callers ask route_budget_available() first and defer
# optional re-planning to a later frame once this frame has spent its budget.
# Heavy fights spent the whole budget every tick steering around buildings.
const ROUTE_FRAME_BUDGET_USEC := 2500
var _route_budget_frame := -1
var _route_budget_used := 0

func _note_route_solver_time(usec: int) -> void:
	var frame := Engine.get_physics_frames()
	if frame != _route_budget_frame:
		_route_budget_frame = frame
		_route_budget_used = 0
	_route_budget_used += usec

func route_budget_available() -> bool:
	return Engine.get_physics_frames() != _route_budget_frame or _route_budget_used < ROUTE_FRAME_BUDGET_USEC

func _solve_navigation_waypoints(origin: Vector3, requested: Vector3, clearance: float = 1.0, building_snapshot = null, movement_reason: String = "OTHER", target_blocker = null) -> Array:
	var solver_started_usec := Time.get_ticks_usec()
	var route_cache_key := _route_result_cache_key(origin, requested, clearance, building_snapshot, movement_reason, target_blocker)
	var cached_points := _route_result_cache_lookup(route_cache_key, origin, requested)
	if not cached_points.is_empty():
		return cached_points
	var points: Array = []
	var current := origin
	var fail_closed := false
	var origin_started_inside_blocker := false
	var solver_bailed := false
	var ignored: Array = []
	var final_target := requested
	_active_route_segment_cache.clear()
	var all_blockers: Array[Dictionary] = _navigation_blocker_snapshots(building_snapshot)
	var broadphase := _route_search_blocker_broadphase(origin, requested, clearance, all_blockers, target_blocker)
	var blockers: Array[Dictionary] = broadphase["blockers"]
	for _step in range(8):
		if Time.get_ticks_usec() - solver_started_usec > ROUTE_SOLVER_BUDGET_USEC:
			solver_bailed = true
			break
		var blocker: Dictionary = _first_route_blocking_blocker(current, final_target, clearance, ignored, blockers, target_blocker)
		if blocker.is_empty():
			break
		var center: Vector3 = blocker["center"]
		var half_extents: Vector2 = _route_blocker_half_extents(blocker, clearance)
		var candidates: Array[Vector3] = _route_rectangle_corners(center, half_extents)
		var destination_inside := _point_inside_route_rectangle(final_target, center, half_extents)
		var origin_inside := _point_inside_route_rectangle(current, center, half_extents)
		if origin_inside:
			origin_started_inside_blocker = true
		var target_direction := final_target - center
		target_direction.y = 0.0
		if target_direction.length_squared() > 0.01:
			target_direction = target_direction.normalized()

		var best_first := Vector3.ZERO
		var best_second := Vector3.ZERO
		var best_cost := INF
		for first in candidates:
			if Time.get_ticks_usec() - solver_started_usec > ROUTE_SOLVER_BUDGET_USEC:
				solver_bailed = true
				break
			var incoming_clear := origin_inside or not _segment_enters_route_rectangle(current, first, center, half_extents)
			if not incoming_clear:
				continue
			var incoming_exception = blocker.get("node") if origin_inside else null
			if not _segment_clear_of_active_route_blockers(current, first, blockers, clearance, incoming_exception):
				continue
			var first_direction := first - center
			first_direction.y = 0.0
			var exits_away_from_target := not origin_inside or target_direction.length_squared() < 0.01 or first_direction.dot(target_direction) <= 0.01
			if not exits_away_from_target:
				continue
			for second in candidates:
				if Time.get_ticks_usec() - solver_started_usec > ROUTE_SOLVER_BUDGET_USEC:
					solver_bailed = true
					break
				if second.distance_to(first) < 0.01:
					continue
				var middle_clear := not _segment_enters_route_rectangle(first, second, center, half_extents)
				var outgoing_clear := destination_inside or not _segment_enters_route_rectangle(second, final_target, center, half_extents)
				var outgoing_exception = blocker.get("node") if destination_inside else null
				if not middle_clear or not outgoing_clear or not _segment_clear_of_active_route_blockers(first, second, blockers, clearance) or not _segment_clear_of_active_route_blockers(second, final_target, blockers, clearance, outgoing_exception):
					continue
				var cost := current.distance_to(first) + first.distance_to(second) + second.distance_to(final_target)
				if cost < best_cost:
					best_cost = cost
					best_first = first
					best_second = second
			if solver_bailed:
				break
		if solver_bailed:
			break

		if solver_bailed:
			break
		if best_cost == INF:
			# If every corner of the selected blocker is screened by another
			# active blocker, bridge to the next safe rectangle corner and let the
			# bounded outer loop resolve that blocker in turn. This preserves the
			# rectangular route architecture while preventing an unsafe forced leg.
			var bridge_best := Vector3.ZERO
			var bridge_cost := INF
			for bridge_blocker in blockers:
				if Time.get_ticks_usec() - solver_started_usec > ROUTE_SOLVER_BUDGET_USEC:
					solver_bailed = true
					break
				if bridge_blocker.get("node") == blocker.get("node") or ignored.has(bridge_blocker.get("node")):
					continue
				var bridge_center: Vector3 = bridge_blocker["center"]
				var bridge_extents: Vector2 = _route_blocker_half_extents(bridge_blocker, clearance)
				for bridge_candidate in _route_rectangle_corners(bridge_center, bridge_extents):
					if Time.get_ticks_usec() - solver_started_usec > ROUTE_SOLVER_BUDGET_USEC:
						solver_bailed = true
						break
					if current.distance_to(bridge_candidate) < 0.2 or points.has(bridge_candidate):
						continue
					if _point_inside_route_rectangle(bridge_candidate, center, half_extents):
						continue
					if not _segment_clear_of_active_route_blockers(current, bridge_candidate, blockers, clearance, blocker.get("node") if origin_inside else null):
						continue
					var bridge_score := current.distance_to(bridge_candidate) + bridge_candidate.distance_to(final_target)
					if bridge_score < bridge_cost:
						bridge_cost = bridge_score
						bridge_best = bridge_candidate
				if solver_bailed:
					break
			if solver_bailed:
				break
			if bridge_cost < INF:
				points.append(bridge_best)
				current = bridge_best
				continue
			# A destination inside a blocker is an interaction request, not a
			# valid ground position. Pick the closest safe corner and stop there.
			for candidate in candidates:
				var fallback_exception = blocker.get("node") if origin_inside else null
				if (origin_inside or not _segment_enters_route_rectangle(current, candidate, center, half_extents)) and _segment_clear_of_active_route_blockers(current, candidate, blockers, clearance, fallback_exception):
					if best_first == Vector3.ZERO or current.distance_to(candidate) < current.distance_to(best_first):
						best_first = candidate
			if best_first == Vector3.ZERO:
				fail_closed = true
				break
			best_second = best_first

		points.append(best_first)
		if best_second.distance_to(best_first) > 0.01:
			points.append(best_second)
		current = best_second
		ignored.append(blocker.get("node"))
		if destination_inside:
			if String(blocker.get("object_class", "")) == "RESOURCE_NODE":
				var approach := _resource_navigation_approach_point(blocker, center, current)
				if _segment_clear_of_active_route_blockers(current, approach, blockers, clearance, blocker.get("node")):
					points.append(approach)
					current = approach
			final_target = current
			break

	if solver_bailed:
		# The broad NavigationAgent remains the deterministic fallback when the
		# authored detour search exceeds its CPU budget. Do not keep a partial
		# route that could be mistaken for a complete clearance solution.
		# This is a valid bounded NavigationAgent fallback, not a permanently
		# failed route. Reuse it for nearby requests until topology or age makes
		# a fresh authored detour search worthwhile.
		_route_result_cache_store(route_cache_key, origin, requested, [requested])
		return [requested]

	if fail_closed:
		var worker_owned_route := movement_reason == "PLAYER_MOVE" or movement_reason.begins_with("WORKER_")
		if worker_owned_route and origin_started_inside_blocker and origin.distance_to(requested) > maxf(1.2, clearance):
			# A Worker can legitimately receive a plain move while still inside
			# its own starting-base envelope. If every authored escape corner is
			# screened by adjacent base blockers, preserving [origin] makes the
			# NavigationAgent report immediate arrival and clears the public move.
			# Keep the semantic destination instead; the existing per-frame
			# blocker constraint remains active for this direct fallback and keeps
			# the body from entering a real blocker.
			_route_result_cache_store(route_cache_key, origin, requested, [requested])
			return [requested]
		# Never append the requested target after an unsatisfied blocker chain;
		# returning the last safe point lets Unit stop without crossing geometry.
		var fail_result: Array = points if not points.is_empty() else [origin]
		_route_result_cache_store(route_cache_key, origin, requested, fail_result, true)
		return points if not points.is_empty() else [origin]
	if points.is_empty() or points.back().distance_to(final_target) > 0.15:
		points.append(final_target)
	_route_result_cache_store(route_cache_key, origin, requested, points)
	return points

func _segment_clear_of_active_route_blockers(a: Vector3, b: Vector3, blockers: Array[Dictionary], clearance: float, exempt_node = null) -> bool:
	var cache_key := "%s|%s|%d|%s" % [a, b, roundi(clearance * 100.0), str(exempt_node.get_instance_id()) if is_instance_valid(exempt_node) else ""]
	if _active_route_segment_cache.has(cache_key):
		return bool(_active_route_segment_cache[cache_key])
	for blocker in blockers:
		if blocker.get("node") == exempt_node:
			continue
		var center: Vector3 = blocker["center"]
		var half_extents: Vector2 = _route_blocker_half_extents(blocker, clearance)
		# Broad-phase cull: an exact segment/rectangle test is only necessary
		# when the segment's axis-aligned bounds overlap the expanded blocker.
		# This is conservative and therefore preserves the no-pass-through
		# contract while avoiding a full blocker scan for distant geometry.
		if maxf(a.x, b.x) < center.x - half_extents.x or minf(a.x, b.x) > center.x + half_extents.x or maxf(a.z, b.z) < center.z - half_extents.y or minf(a.z, b.z) > center.z + half_extents.y:
			continue
		if _segment_enters_route_rectangle(a, b, center, half_extents):
			_active_route_segment_cache[cache_key] = false
			return false
	_active_route_segment_cache[cache_key] = true
	return true

# Rebuilt for every moving unit on every physics tick (allocating a
# dictionary per building and de-duplicating soft blockers with nested
# scans). The result only depends on world state, so the default snapshot is
# built once per physics frame and shared; callers only read it.
var _blocker_snapshot_cache: Array[Dictionary] = []
var _blocker_snapshot_frame := -1

func _navigation_blocker_snapshots(building_snapshot = null) -> Array[Dictionary]:
	if building_snapshot == null:
		var frame := Engine.get_physics_frames()
		if frame != _blocker_snapshot_frame:
			_blocker_snapshot_cache = _build_navigation_blocker_snapshots(null)
			_blocker_snapshot_frame = frame
		return _blocker_snapshot_cache
	return _build_navigation_blocker_snapshots(building_snapshot)

func _build_navigation_blocker_snapshots(building_snapshot = null) -> Array[Dictionary]:
	var blockers: Array[Dictionary] = []
	var buildings: Array = all_buildings() if building_snapshot == null else building_snapshot
	var registered_buildings: Array = []
	var registered_soft_owners: Array = []
	for world_blocker in _world_route_blockers:
		var owner = world_blocker.get("owner")
		if owner is Building and is_instance_valid(owner):
			registered_buildings.append(owner)
	for building in buildings:
		if not is_instance_valid(building) or building.is_dead or registered_buildings.has(building):
			continue
		var half_extents := Vector2(float(building.def.get("footprint", 4.0)), float(building.def.get("footprint", 4.0)))
		if building.has_method("get_selection_geometry"):
			var geometry: Dictionary = building.get_selection_geometry()
			var visual_extents: Dictionary = geometry.get("visual_extents", {})
			half_extents.x = maxf(half_extents.x, float(visual_extents.get("x", half_extents.x)))
			half_extents.y = maxf(half_extents.y, float(visual_extents.get("z", half_extents.y)))
		blockers.append({"node": building, "center": building.global_position, "half_extents": half_extents, "object_id": String(building.get("building_id")), "source": "completed_building"})
	for blocker in _world_route_blockers:
		var route_node = blocker.get("node")
		var owner = blocker.get("owner")
		if is_instance_valid(route_node) and is_instance_valid(owner) and (not owner is ResourceNode or not owner.depleted):
			blockers.append(blocker)
			registered_soft_owners.append({
				"owner": owner,
				"center": blocker.get("center", Vector3.INF),
				"half_extents": blocker.get("half_extents", Vector2.INF),
			})
	for blocker in _navigation_soft_blockers:
		var node = blocker.get("node")
		if is_instance_valid(node) and (not node is ResourceNode or not node.depleted):
			var duplicate := false
			var center: Vector3 = blocker.get("center", Vector3.INF)
			var half_extents: Vector2 = blocker.get("half_extents", Vector2.INF)
			for registered in registered_soft_owners:
				if registered.get("owner") == node and center.distance_to(registered.get("center", Vector3.INF)) <= 0.01 and half_extents.distance_to(registered.get("half_extents", Vector2.INF)) <= 0.01:
					duplicate = true
					break
			if not duplicate:
				blockers.append(blocker)
	return blockers

func _first_route_blocking_blocker(origin: Vector3, target: Vector3, clearance: float, ignored: Array, blockers: Array[Dictionary], target_blocker = null) -> Dictionary:
	var closest: Dictionary = {}
	var closest_distance := INF
	for blocker in blockers:
		var node = blocker.get("node")
		if not is_instance_valid(node) or ignored.has(node):
			continue
		var center: Vector3 = blocker.get("center", node.global_position)
		var half_extents := _route_blocker_half_extents(blocker, clearance)
		var target_is_interaction_point: bool = (blocker.get("owner") == target_blocker or node == target_blocker) \
			and not _point_inside_route_rectangle(target, center, blocker.get("half_extents", half_extents))
		var segment_hits_actual_footprint := _segment_enters_route_rectangle(origin, target, center, blocker.get("half_extents", half_extents))
		if (not target_is_interaction_point and _point_inside_route_rectangle(target, center, half_extents)) or segment_hits_actual_footprint or (not target_is_interaction_point and _segment_enters_route_rectangle(origin, target, center, half_extents)):
			var distance := origin.distance_to(center)
			if distance < closest_distance:
				closest = blocker
				closest_distance = distance
	return closest

func _route_blocker_half_extents(blocker: Dictionary, clearance: float) -> Vector2:
	var base: Vector2 = blocker.get("half_extents", Vector2(1.0, 1.0))
	var margin := clearance + ROUTE_BLOCKER_MARGIN
	return Vector2(maxf(0.5, base.x + margin), maxf(0.5, base.y + margin))


func _resource_navigation_approach_point(blocker: Dictionary, center: Vector3, from_point: Vector3) -> Vector3:
	var direction := from_point - center
	direction.y = 0.0
	if direction.length_squared() < 0.01:
		direction = Vector3.RIGHT
	direction = direction.normalized()
	var core: Vector2 = blocker.get("core_half_extents", blocker.get("half_extents", Vector2(0.6, 0.6)))
	var x_ratio := maxf(absf(direction.x), 0.001)
	var z_ratio := maxf(absf(direction.z), 0.001)
	var boundary_radius := maxf(core.x / x_ratio, core.y / z_ratio)
	var approach_radius := minf(RESOURCE_GATHER_INTERACTION_RADIUS - 0.05, boundary_radius + RESOURCE_CORE_ROUTE_MARGIN)
	return center + direction * maxf(0.65, approach_radius)

func _route_rectangle_corners(center: Vector3, half_extents: Vector2) -> Array[Vector3]:
	# Unit.command_move keeps the normal 1.2m arrival tolerance for ordinary
	# movement. Put route waypoints beyond that stop distance so a unit settling
	# at a corner cannot still overlap the visible AABB it is clearing.
	var corner_extents := half_extents + Vector2(ROUTE_WAYPOINT_STOP_MARGIN, ROUTE_WAYPOINT_STOP_MARGIN)
	return [
		center + Vector3(-corner_extents.x, 0.0, -corner_extents.y),
		center + Vector3(corner_extents.x, 0.0, -corner_extents.y),
		center + Vector3(corner_extents.x, 0.0, corner_extents.y),
		center + Vector3(-corner_extents.x, 0.0, corner_extents.y),
	]

func _point_inside_route_rectangle(point: Vector3, center: Vector3, half_extents: Vector2) -> bool:
	return point.x >= center.x - half_extents.x and point.x <= center.x + half_extents.x and point.z >= center.z - half_extents.y and point.z <= center.z + half_extents.y

func _segment_enters_route_rectangle(a: Vector3, b: Vector3, center: Vector3, half_extents: Vector2) -> bool:
	# Slab intersection against the open rectangle interior. A segment that
	# follows the safe perimeter boundary is therefore legal, while a segment
	# that cuts through the rectangle is rejected.
	var min_x := center.x - half_extents.x
	var max_x := center.x + half_extents.x
	var min_z := center.z - half_extents.y
	var max_z := center.z + half_extents.y
	var delta_x := b.x - a.x
	var delta_z := b.z - a.z
	var t_min := 0.0
	var t_max := 1.0
	if absf(delta_x) < 0.0001:
		if a.x <= min_x or a.x >= max_x:
			return false
	else:
		var tx1 := (min_x - a.x) / delta_x
		var tx2 := (max_x - a.x) / delta_x
		t_min = maxf(t_min, minf(tx1, tx2))
		t_max = minf(t_max, maxf(tx1, tx2))
	if absf(delta_z) < 0.0001:
		if a.z <= min_z or a.z >= max_z:
			return false
	else:
		var tz1 := (min_z - a.z) / delta_z
		var tz2 := (max_z - a.z) / delta_z
		t_min = maxf(t_min, minf(tz1, tz2))
		t_max = minf(t_max, maxf(tz1, tz2))
	return t_min < t_max and t_max > 0.0 and t_min < 1.0

## Last-frame guard for the broad production navmesh. It only constrains a
## movement velocity when a completed-building clearance envelope would be
## entered; it does not change targets, combat range, or authoritative state.
const STEERING_DETOUR_FRAMES := 24
var _steering_detour_cache := {}

func constrain_unit_velocity_around_buildings(origin: Vector3, requested_velocity: Vector3, delta: float, clearance: float = 1.0, movement_reason: String = "OTHER") -> Vector3:
	var speed := requested_velocity.length()
	if speed < 0.01:
		return requested_velocity
	var step_end: Vector3 = origin + requested_velocity * maxf(delta, 0.016)
	var blockers := _navigation_blocker_snapshots()
	# Cheap reject before the per-blocker rectangle work: a blocker whose
	# largest possible padded extent cannot reach this step is skipped.
	var reach := (step_end - origin).length() + clearance + ROUTE_BLOCKER_MARGIN
	for blocker in blockers:
		var center: Vector3 = blocker["center"]
		var base_half: Vector2 = blocker.get("half_extents", Vector2.ONE)
		var limit := maxf(base_half.x, base_half.y) + reach + 0.5
		if absf(origin.x - center.x) > limit or absf(origin.z - center.z) > limit:
			continue
		var half_extents: Vector2 = _route_blocker_half_extents(blocker, clearance)
		var radial: Vector3 = origin - center
		radial.y = 0.0
		if _point_inside_route_rectangle(origin, center, half_extents):
			if radial.length_squared() < 0.01:
				radial = Vector3.RIGHT
			return radial.normalized() * speed
		if not _segment_enters_route_rectangle(origin, step_end, center, half_extents):
			continue
		var travel_target: Vector3 = origin + requested_velocity.normalized() * maxf(maxf(half_extents.x, half_extents.y) * 4.0, 12.0)
		# Units brushing past a building hit this every tick, and each hit ran the
		# full route solver (1-14 ms) for a result only used as a steering
		# direction. Reuse a detour for a few frames within a 2 m / 4 m bucket.
		var detour_key := "%d,%d|%d,%d|%d|%s" % [roundi(origin.x / 2.0), roundi(origin.z / 2.0), roundi(travel_target.x / 4.0), roundi(travel_target.z / 4.0), roundi(clearance * 10.0), str(blocker.get("node", ""))]
		var frame := Engine.get_physics_frames()
		var waypoints: Array
		var cached_detour = _steering_detour_cache.get(detour_key)
		if cached_detour != null and frame - int(cached_detour[0]) <= STEERING_DETOUR_FRAMES:
			waypoints = cached_detour[1]
		elif not route_budget_available():
			# Out of solver time this frame: slide on the straight line and retry.
			return requested_velocity
		else:
			waypoints = navigation_waypoints_for_unit(origin, travel_target, clearance, null, movement_reason)
			if _steering_detour_cache.size() > 256:
				_steering_detour_cache.clear()
			_steering_detour_cache[detour_key] = [frame, waypoints]
		if not waypoints.is_empty():
			var waypoint_direction: Vector3 = waypoints[0] - origin
			waypoint_direction.y = 0.0
			if waypoint_direction.length_squared() > 0.01:
				return waypoint_direction.normalized() * speed
		return requested_velocity
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
	# AI-versus-AI balance tests: the player's seat gets the same hero an AI
	# of that difficulty would, so both seats are compared fairly.
	if String(cfg.get("ai_seat_difficulty", "")) != "":
		hero_stats = _ai_hero_stats(String(cfg.get("player_race", "barrosan")), String(cfg["ai_seat_difficulty"]))

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
		ec.setup(t, o.get("race", "vorthak"), false, bank.duplicate(), _ai_hero_stats(String(o.get("race", "vorthak")), String(o.get("difficulty", "normal"))))
		commanders.append(ec)
		t += 1

	# Prewarm building models and collision hulls for every race in the match
	# so later construction never stalls the frame mid-battle.
	var races_in_match := {}
	for cmd in commanders:
		races_in_match[String(cmd.race)] = true
	for bdef in BuildingDefs.get_all().values():
		if races_in_match.has(String(bdef.get("race", ""))):
			ModelUtils.prewarm_building_collision(String(bdef.get("model", "")))
			var warm = Building.new()
			add_child(warm)
			warm.prewarm_model(bdef)
			warm.free()
	# build starting bases
	for i in commanders.size():
		_build_starting_base(commanders[i], map["start_positions"][i])
	_apply_start_twists()
	Unit.damage_numbers_on = bool(ProfileManager.settings().get("damage_numbers", true))
	_m20_end(stage)

## Enemy heroes used to be bare stat blocks with no spells. They now get a
## race-flavoured spell kit by difficulty (none on Easy, up to three on
## Brutal), and in the campaign they grow tougher chapter by chapter.
const AI_HERO_KITS := {
	"barrosan": ["rally", "charge", "slam"], "grimtusk": ["charge", "slam", "rally"],
	"karak": ["slam", "rally", "charge"], "frostborn": ["slam", "charge", "rally"],
	"lioraen": ["heal", "root", "bolt"], "sylvan": ["bolt", "root", "heal"],
	"vorthak": ["bolt", "slam", "root"], "hollow": ["bolt", "root", "heal"],
	"sunspear": ["rally", "charge", "bolt"], "wyldkin": ["charge", "root", "slam"],
}

## The light and weather of this battle: a campaign chapter's mood, or an
## Endless Road stage twist.
func battle_mood() -> String:
	var cfg := Match.get_config()
	var chapter_mood := String(CampaignDefs.CHAPTER_MOODS.get(String(cfg.get("campaign_chapter", "")), ""))
	return chapter_mood if chapter_mood != "" else String(cfg.get("mood", ""))

func _ai_hero_stats(race: String, difficulty: String) -> Dictionary:
	var count := int({"easy": 0, "normal": 1, "hard": 2, "brutal": 3}.get(difficulty, 1))
	var level := 2 if difficulty in ["hard", "brutal"] else 1
	# Deep on the Endless Road enemy heroes learn more and cast stronger:
	# one more spell from stage 20, and a spell level every 25 stages up to
	# each spell's strongest form (their power keeps growing with depth).
	var depth_now := int(Match.get_config().get("endless_depth", 0))
	if depth_now >= 20:
		count += 1
	level += depth_now / 25
	var abilities := {}
	var kit: Array = AI_HERO_KITS.get(race, ["bolt", "charge", "rally"])
	for i in mini(count, kit.size()):
		abilities[String(kit[i])] = level
	var chapter_index := CampaignDefs.index_of(String(Match.get_config().get("campaign_chapter", "")))
	var growth := float(maxi(chapter_index, 0))
	# Endless Road "Champions" twist: enemy heroes half again as tough.
	var champ := 1.5 if "champions" in Match.get_config().get("twists", []) else 1.0
	# Enemy heroes also grow with every Endless Road stage.
	growth = (growth + float(Match.get_config().get("endless_depth", 0)) * 0.8) * champ
	return {"abilities": abilities, "max_mana": 120.0 + growth * 3.0, "mana_regen": 5.0 + growth * 0.1,
		"bonus_hp": growth * 8.0, "bonus_dmg": growth * 0.5, "bonus_armor": floorf(growth / 10.0),
		"regen": 1.5 + growth * 0.05}

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
	u.spawn_serial = _spawn_serial
	_spawn_serial += 1
	nav_region.add_child(u) if nav_region else add_child(u)
	u.global_position = pos + Vector3(0, 0.1, 0)
	u.reset_physics_interpolation()
	u.configure(udef, team, commanders[team] if team < commanders.size() else null, self)
	_maybe_make_elite(u, team)
	# Endless Road "Veteran foes" twist: enemy soldiers arrive already ranked.
	if team != player_team and twist_veteran_foes and not u.is_worker and not u.is_hero:
		u.set_veterancy(1)
	# Endless Road "Gloom" twist: the fog closes in on the player's side.
	if team == player_team and twist_gloom:
		u.vision *= 0.6
	# Endless Road mutations (EndlessDefs.mutations_for): deep-road enemies.
	if team != player_team and not u.is_worker and not _stage_mutations.is_empty():
		_apply_mutations(u)
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
	_register_building_world_blocker(b)
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
	if bool(bdef.get("vein_outpost", false)):
		var vein = vein_near(pos, 6.0)
		if vein == null or not cmd.can_afford(bdef.get("cost", {})) or not cmd.spend(bdef.get("cost", {}).duplicate()):
			return null
		var ob = _create_building(bdef, team, Vector3(vein.global_position.x, 0.0, vein.global_position.z), false)
		if ob:
			vein.outpost = ob
			ob.set_meta("vein", vein)
			emit_signal("alert", "%s claimed." % vein.display_name(), vein.global_position)
		return ob
	var is_v0431_target := building_id == "barrosan_clan_croft" and team == 0
	# One live transaction per confirmed placement. Preview and invalid clicks
	# never reach this function; the guard also makes repeated input idempotent.
	# This guard used to refuse every Croft while another was still under
	# construction, so a Barrosan player could only raise one house at a time
	# and extra placements vanished silently. Keep it to its real job: a
	# repeated confirmation of the same placement in the same frame.
	if is_v0431_target and _active_build_transaction != "" and Engine.get_physics_frames() == _last_croft_frame and pos.distance_to(_last_croft_pos) < 0.5:
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
	_last_croft_frame = Engine.get_physics_frames()
	_last_croft_pos = pos
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
	# Vein outposts stand on a free vein (the spot snaps to it); nothing else
	# may be built on a vein.
	if bool(bdef.get("vein_outpost", false)):
		var vein = vein_near(pos, 6.0)
		if vein == null:
			return "Must be built on a vein"
		if not vein.is_free():
			return "This vein is already claimed"
		pos = Vector3(vein.global_position.x, pos.y, vein.global_position.z)
	else:
		for v in get_tree().get_nodes_in_group("veins"):
			if Vector2(v.global_position.x - pos.x, v.global_position.z - pos.z).length() < fp + 4.0:
				return "Blocked by a vein (build an outpost there)"
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
		var hp_before := float(target.hp) if "hp" in target else -1.0
		target.take_damage(final, source_payload)
		# Physical pierce projectiles request one impact cue only after the target's
		# authoritative HP actually falls. Keep arcane/siege and launch routing intact.
		if kind in ["arrow", "bolt", "thorn"] and dtype == "pierce" and hp_before >= 0.0 and is_instance_valid(target) and float(target.hp) < hp_before:
			Sfx.play("projectile_impact", -8.0)
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
# Every unit scanned the whole unit and building groups each physics tick
# (find_enemy_in_range and friends), and each call allocated a fresh group
# array: O(n^2) allocations per tick, about 0.5 ms per unit in a 20v20 fight.
# The group snapshots are now taken once per physics frame and shared; all
# callers only iterate them. Entries can still be freed mid-frame, so callers
# keep their is_instance_valid checks.
var _units_snapshot: Array = []
var _units_snapshot_frame := -1
var _buildings_snapshot: Array = []
var _buildings_snapshot_frame := -1

## Units and buildings call this as they join or leave the tree, so a unit
## spawned (or freed) mid-frame is seen by queries later in the same frame.
func invalidate_entity_snapshots() -> void:
	_units_snapshot_frame = -1
	_buildings_snapshot_frame = -1
	_blocker_snapshot_frame = -1

func all_units() -> Array:
	var frame := Engine.get_physics_frames()
	if frame != _units_snapshot_frame:
		_units_snapshot = get_tree().get_nodes_in_group("units")
		_units_snapshot_frame = frame
	return _units_snapshot

func all_buildings() -> Array:
	var frame := Engine.get_physics_frames()
	if frame != _buildings_snapshot_frame:
		_buildings_snapshot = get_tree().get_nodes_in_group("buildings")
		_buildings_snapshot_frame = frame
	return _buildings_snapshot

func find_enemy_in_range(unit, rng: float):
	var best = null
	var best_d := rng * rng
	var p: Vector3 = unit.global_position
	# Heroes pick fighters before workers: AI heroes on attack-move spent whole
	# matches cutting down 25-30 workers while the armies fought elsewhere.
	var hero_prefers_fighters: bool = bool(unit.get("is_hero"))
	var worker_fallback = null
	var worker_d := rng * rng
	for u in all_units():
		if not is_instance_valid(u) or u.is_dead or u.team == unit.team:
			continue
		if hero_prefers_fighters and u.is_worker:
			var wd = p.distance_squared_to(u.global_position)
			if wd < worker_d and (unit.team != player_team or is_player_visible(u)):
				worker_d = wd
				worker_fallback = u
			continue
		var d = p.distance_squared_to(u.global_position)
		if d >= best_d:
			continue
		# Visibility is only consulted for candidates that would actually win.
		if unit.team == player_team and not is_player_visible(u):
			continue
		best_d = d
		best = u
	if best == null and worker_fallback != null:
		best = worker_fallback
		best_d = worker_d
	# also consider buildings if no unit and unit is combat
	if best == null and not unit.is_worker:
		for b in all_buildings():
			if not is_instance_valid(b) or b.is_dead or b.team == unit.team:
				continue
			if unit.team == player_team and not is_player_visible(b):
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
		if team == player_team and not is_player_visible(u):
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

func find_nearest_resource(pos: Vector3, kind: String, requesting_team: int = -1):
	var best = null
	var best_d := INF
	for r in get_tree().get_nodes_in_group("resources"):
		if not is_instance_valid(r) or r.depleted:
			continue
		if requesting_team == player_team and not is_player_visible(r):
			continue
		if kind != "" and r.resource_kind != kind:
			continue
		var d = pos.distance_squared_to(r.global_position)
		if d < best_d:
			best_d = d
			best = r
	if best == null and kind != "":
		return find_nearest_resource(pos, "", requesting_team)
	return best

func find_nearest_resource_exact(pos: Vector3, kind: String, requesting_team: int = -1):
	var best = null
	var best_d := INF
	for r in get_tree().get_nodes_in_group("resources"):
		if not is_instance_valid(r) or r.depleted or r.resource_kind != kind:
			continue
		if requesting_team == player_team and not is_player_visible(r):
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
	if worker.team == player_team and not is_player_visible(node):
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
		# Blender-authored sites (tools/blender/generateTimberAndGoldNodes.py).
		"timber": "res://assets/props/misc/resource_timber_stack.glb",
		"stone": "res://assets/props/misc/resource_stone_quarry_chunk.glb",
		"gold": "res://assets/props/misc/resource_gold_vein.glb",
		# Food had reused the timber pile; it is now a grain patch with sheaves.
		"food": "res://assets/props/misc/resource_harvest_grain.glb",
	}
	# Food nodes hold more than before (600) so the opening is not starved;
	# houses add a steady food trickle for the long game.
	var amounts := {"timber": 800, "stone": 700, "gold": 900, "food": 1200}
	var heights := {"timber": 1.6, "stone": 2.2, "gold": 2.6, "food": 1.5}
	for r in map.get("resources", []):
		var kind: String = r["kind"]
		var node = ResourceNodeScript.new()
		add_child(node)
		node.global_position = r["pos"]
		node.configure(kind, amounts.get(kind, 800), models.get(kind, ""), heights.get(kind, 2.0))
		clear_ground_cover(node.global_position, 3.8)
		_register_resource_navigation_blocker(node)
	var recorder = _m20_recorder()
	if recorder:
		recorder.record_population("resource_nodes", map.get("resources", []).size(), 0.0, 0.0, "game_world._spawn_resources")
	_m20_end(stage)

func _spawn_veins() -> void:
	if bool(Match.get_config().get("no_veins", false)):
		return
	var clear := float(map.get("size", MapDefs.MAP_SIZE)) - 8.0
	for v in map.get("veins", []):
		var p: Vector3 = v["pos"]
		if absf(p.x) > clear or absf(p.z) > clear:
			continue
		var vein = VeinScript.new()
		add_child(vein)
		vein.global_position = p
		# Deeper on the Endless Road the veins run richer.
		vein.configure(String(v["kind"]), 4000 + 120 * int(Match.get_config().get("endless_depth", 0)))
		clear_ground_cover(p, 5.0)

## Lume flares: from minute six, every four minutes one vein burns with Lume
## for 90 seconds and pays double to whoever works it. Worth fighting over.
var _flare_timer := 0.0

func _tick_vein_flares(delta: float) -> void:
	if match_time < 360.0:
		return
	_flare_timer += delta
	if _flare_timer < 240.0:
		return
	_flare_timer = 0.0
	var veins: Array = get_tree().get_nodes_in_group("veins").filter(func(v): return int(v.amount) > 0)
	if veins.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = sim_seed_for(7700 + int(match_time)) if has_method("sim_seed_for") else int(match_time)
	var v = veins[rng.randi() % veins.size()]
	v.rich_until = match_time + 90.0
	emit_signal("alert", "A Lume flare lights the %s: double output for 90 seconds." % v.display_name().to_lower(), v.global_position)
	if is_instance_valid(_fx_container):
		CombatVfx.lume_pillar(_fx_container, v.global_position, Color(1.0, 0.85, 0.35))

## The free vein nearest a point, within `radius`.
func vein_near(pos: Vector3, radius: float = 5.0):
	var best = null
	var best_d := radius
	for v in get_tree().get_nodes_in_group("veins"):
		var d: float = Vector2(v.global_position.x - pos.x, v.global_position.z - pos.z).length()
		if d < best_d:
			best_d = d
			best = v
	return best

func _spawn_capture_points() -> void:
	var stage := _m20_begin("GAMEWORLD_CAPTURE_NODE_SETUP", "GAMEWORLD_CAPTURE_POINTS", 2)
	for c in map.get("capture_points", []):
		var cp = CapturePointScript.new()
		add_child(cp)
		cp.global_position = c["pos"]
		cp.configure(c["name"], c["benefit"], c.get("model", ""), self)
		clear_ground_cover(cp.global_position, 6.0)
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
func _prewarm_combat_presentation() -> void:
	# Draw each combat effect and projectile look once, just under the ground in
	# front of the opening camera, so their pipelines compile during the
	# loading fade instead of stalling the first fight. Presentation only.
	if not is_instance_valid(_fx_container) or not is_instance_valid(player_commander):
		return
	var spot: Vector3 = map.get("start_positions", [Vector3.ZERO])[player_team] + Vector3(0, -1.5, 0)
	var cam := get_viewport().get_camera_3d()
	if cam:
		# Behind the ground plane along the opening view ray: inside the frustum,
		# hidden by the opaque ground, so the GPU compiles without anything showing.
		var focus := cam.global_position + (-cam.global_transform.basis.z) * 60.0
		spot = cam.global_position + (focus - cam.global_position).normalized() * 90.0
	# Enemy units and buildings stay hidden by fog until first sighted, so their
	# materials would otherwise compile at the moment the first attack arrives.
	var races_in_match := {}
	for cmd in commanders:
		races_in_match[String(cmd.race)] = true
	var warm_models: Array = []
	for udef in UnitDefs.get_all().values():
		if races_in_match.has(String(udef.get("race", ""))):
			warm_models.append(String(udef.get("model", "")))
	for bdef in BuildingDefs.get_all().values():
		if races_in_match.has(String(bdef.get("race", ""))):
			warm_models.append(String(bdef.get("model", "")))
	for path in warm_models:
		if path.is_empty() or not ResourceLoader.exists(path):
			continue
		var packed = load(path)
		if not packed is PackedScene:
			continue
		var model: Node3D = packed.instantiate()
		_fx_container.add_child(model)
		model.global_position = spot
		for body in model.find_children("*", "CollisionObject3D", true, false):
			body.queue_free()
		get_tree().create_timer(0.6).timeout.connect(model.queue_free)
	# The construction work-line shader compiles here too, not on first placement.
	var site := MeshInstance3D.new()
	site.mesh = BoxMesh.new()
	var site_mat := ShaderMaterial.new()
	site_mat.shader = load("res://assets/shaders/construction_rise.gdshader")
	site.material_override = site_mat
	var ring := MeshInstance3D.new()
	ring.mesh = QuadMesh.new()
	ring.material_override = CombatVfx.selection_ring_material(player_commander.color)
	_fx_container.add_child(ring)
	ring.global_position = spot
	get_tree().create_timer(0.6).timeout.connect(ring.queue_free)
	_fx_container.add_child(site)
	site.global_position = spot
	get_tree().create_timer(0.6).timeout.connect(site.queue_free)
	CombatVfx.hit(_fx_container, spot, Color(1.0, 0.72, 0.42), false)
	CombatVfx.hit(_fx_container, spot, Color(1, 0.5, 0.15), true)
	CombatVfx.death(_fx_container, spot)
	CombatVfx.battle_scar(_fx_container, spot)
	CombatVfx.motes(_fx_container, spot, Color(1.0, 0.82, 0.38))
	CombatVfx.slam(_fx_container, spot, 6.0)
	for kind in ["arrow", "cinder", "void_bolt", "thorn"]:
		var p = ProjectileScript.new()
		p.kind = kind
		_fx_container.add_child(p)
		p.set_physics_process(false)
		p.global_position = spot
		get_tree().create_timer(0.6).timeout.connect(p.queue_free)

const OVERVIEW_BAKE_SIZE := 384
const OVERVIEW_HIDDEN_LAYER := 1 << 19

func _bake_overview_texture() -> void:
	# One orthographic render of the static battlefield for the minimap. Units,
	# buildings, objectives, effects and the fog shroud are moved to a layer the
	# bake camera skips (the main camera still draws them), so nothing live or
	# hidden by fog is baked in. Presentation only.
	if DisplayServer.get_name() == "headless":
		return
	var half := float(map.get("size", 140.0))
	var vp := SubViewport.new()
	vp.name = "OverviewBake"
	vp.size = Vector2i(OVERVIEW_BAKE_SIZE, OVERVIEW_BAKE_SIZE)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.msaa_3d = Viewport.MSAA_4X
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = half * 2.0
	cam.near = 1.0
	cam.far = 200.0
	cam.cull_mask = 0xFFFFF & ~OVERVIEW_HIDDEN_LAYER
	var env_node := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if env_node and env_node.environment:
		var env: Environment = env_node.environment.duplicate()
		env.fog_enabled = false
		env.volumetric_fog_enabled = false
		env.ssao_enabled = false
		env.ssr_enabled = false
		env.glow_enabled = false
		cam.environment = env
	vp.add_child(cam)
	add_child(vp)
	cam.global_position = Vector3(0.0, 90.0, 0.0)
	cam.look_at(Vector3.ZERO, Vector3(0, 0, -1))
	cam.current = true
	var moved: Array = []
	var roots: Array = []
	roots.append_array(all_units())
	roots.append_array(all_buildings())
	roots.append_array(get_tree().get_nodes_in_group("capture_points"))
	roots.append(_fx_container)
	roots.append(_projectile_container)
	if is_instance_valid(_visibility_overlay):
		roots.append(_visibility_overlay)
	for r in roots:
		if not is_instance_valid(r):
			continue
		var visuals: Array = r.find_children("*", "VisualInstance3D", true, false)
		if r is VisualInstance3D:
			visuals.append(r)
		for v in visuals:
			moved.append([v, v.layers])
			v.layers = OVERVIEW_HIDDEN_LAYER
	# Two frames: the first registers the bake camera, the second draws with it.
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	for entry in moved:
		if is_instance_valid(entry[0]):
			entry[0].layers = entry[1]
	if not is_instance_valid(vp):
		return
	var img := vp.get_texture().get_image()
	vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	vp.queue_free()
	if img == null or img.is_empty():
		return
	img.generate_mipmaps()
	overview_texture = ImageTexture.create_from_image(img)

## Campaign battles speak: an opening line a few seconds in, then the enemy
## commander at three and eight minutes of battle time (CampaignDefs).
## In campaign battles an enemy faction speaks when its stronghold falls or
## its hero dies (CampaignDefs.REACTIONS).
func _saga_react(team: int, kind: String) -> void:
	if team == player_team or String(Match.get_config().get("campaign_chapter", "")) == "" or not game_running:
		return
	var cmd = commander_for_team(team)
	if cmd == null:
		return
	var line := String(CampaignDefs.REACTIONS.get(String(cmd.race), {}).get(kind, ""))
	if line != "":
		emit_signal("alert", line, Vector3.ZERO)

## Chapter events (CampaignDefs.EVENTS): allies join at the start, enemy
## reinforcements arrive later and march on the player's base.
## Warlords Battlecry's retinue: veterans who survived the last campaign
## battle march in beside the Jardas.
func _spawn_retinue() -> void:
	if String(Match.get_config().get("campaign_chapter", "")) == "" or not is_instance_valid(player_commander) or not ProfileManager.has_hero():
		return
	var roster: Array = ProfileManager.saga().get("retinue", [])
	if roster.is_empty():
		return
	var hq_pos: Vector3 = map.get("start_positions", [Vector3.ZERO])[player_team]
	var toward := (Vector3.ZERO - hq_pos).normalized()
	var side_axis := Vector3(toward.z, 0, -toward.x)
	var k := 0
	for entry in roster:
		if not UnitDefs.get_all().has(String(entry.get("id", ""))):
			continue
		var u = spawn_unit(String(entry["id"]), player_team, hq_pos + toward * 10.0 - side_axis * (float(k) - 2.5) * 1.8)
		if u == null:
			continue
		u.set_meta("retinue", true)
		if u.has_method("set_veterancy"):
			u.set_veterancy(int(entry.get("vet", 1)))
		if String(entry.get("name", "")) != "":
			u.veteran_name = String(entry["name"])
		k += 1
	player_commander.recompute_pop()
	if k > 0:
		get_tree().create_timer(12.0, false).timeout.connect(func():
			if game_running:
				emit_signal("alert", "Your retinue marches with you: %d veteran%s of earlier battles." % [k, "" if k == 1 else "s"], hq_pos))

## After a campaign battle the best living veterans join the retinue. After a
## defeat only the retinue members who survived stay with the Jardas.
## Every battle rolls gear for the hero (LootDefs). Item level follows the
## hero, deepened by campaign chapter and Endless Road stage; the roll is
## seeded from the battle's own numbers.
func _roll_battle_loot(victory: bool) -> Array:
	var cfg := Match.get_config()
	var hero := ProfileManager.hero()
	var hardest := "easy"
	var order := ["easy", "normal", "hard", "brutal"]
	for o in cfg.get("opponents", []):
		if order.find(String(o.get("difficulty", "normal"))) > order.find(hardest):
			hardest = String(o.get("difficulty", "normal"))
	var ilvl := int(hero.get("level", 1)) + int(cfg.get("endless_depth", 0)) + maxi(0, CampaignDefs.index_of(String(cfg.get("campaign_chapter", "")))) / 2
	var fortune := int(hero.get("attributes", {}).get("fortune", 0)) + 2 * int((hero.get("talents", {}) as Dictionary).get("treasure_hunter", 0))
	for syn in load("res://scripts/game/talent_defs.gd").active_synergies(hero.get("talents", {})):
		if String(syn["id"]) == "watchful":
			fortune += 3
	var seed_value := int(ProfileManager.data.get("stats", {}).get("battles", 0)) * 7919 + kills_by_player * 131 + int(match_time)
	var items: Array = load("res://scripts/game/loot_defs.gd").roll(seed_value, ilvl, fortune, victory, hardest)
	if _bounty_met(victory):
		items.append_array(load("res://scripts/game/loot_defs.gd").roll(seed_value + 77, ilvl + 2, fortune + 3, true, "hard").slice(0, 1))
	# Every Elite the player slew adds a roll with better odds.
	for e in elites_slain:
		items.append_array(load("res://scripts/game/loot_defs.gd").roll(seed_value + 100 + e, ilvl + 3, fortune + 5, true, "brutal").slice(0, 1))
	if tyrant_slain != "":
		var piece: Dictionary = load("res://scripts/game/loot_defs.gd").tyrant_piece(seed_value + 991, ilvl, tyrant_slain)
		if not piece.is_empty():
			items.append(piece)
	# Endless Road "Rich spoils" twist: a second roll.
	if "spoils" in cfg.get("twists", []):
		items.append_array(load("res://scripts/game/loot_defs.gd").roll(seed_value + 1, ilvl, fortune, victory, hardest))
	var shown: Array = []
	# Auto-salvage setting: low tiers turn straight into experience.
	var ladder := ["common", "uncommon", "rare"]
	var limit := ladder.find(String(ProfileManager.settings().get("auto_salvage", "none")))
	for it in items:
		var tier := ladder.find(String(it["rarity"]))
		if limit >= 0 and tier >= 0 and tier <= limit:
			var gained: float = load("res://scripts/game/loot_defs.gd").salvage_xp(it)
			ProfileManager.add_xp(gained)
			shown.append({"name": "%s (salvaged, +%d XP)" % [String(it["name"]), int(gained)], "rarity": String(it["rarity"])})
			continue
		ProfileManager.add_item(it)
		shown.append({"name": String(it["name"]), "rarity": String(it["rarity"])})
	return shown

func _record_retinue(victory: bool) -> void:
	if String(Match.get_config().get("campaign_chapter", "")) == "" or not ProfileManager.has_hero():
		return
	var picks: Array = []
	for u in get_tree().get_nodes_in_group("units"):
		if not is_instance_valid(u) or u.is_dead or int(u.team) != player_team or u.is_hero or u.is_worker or u.has_meta("saga_ally"):
			continue
		var vet := int(u.get("_veterancy"))
		if victory and vet < 1:
			continue
		if not victory and not u.has_meta("retinue"):
			continue
		picks.append({"id": String(u.unit_id), "vet": maxi(vet, 1), "name": String(u.get("veteran_name"))})
	picks.sort_custom(func(a, b): return int(a["vet"]) > int(b["vet"]))
	var s := ProfileManager.saga()
	s["retinue"] = picks.slice(0, ProfileManager.retinue_cap())
	ProfileManager.save_game()

func _start_saga_events() -> void:
	var chapter_id := String(Match.get_config().get("campaign_chapter", ""))
	var ev: Dictionary = CampaignDefs.EVENTS.get(chapter_id, {})
	if ev.is_empty():
		return
	if ev.has("allies") and is_instance_valid(player_commander):
		var hq_pos: Vector3 = map.get("start_positions", [Vector3.ZERO])[player_team]
		var toward := (Vector3.ZERO - hq_pos).normalized()
		var k := 0
		for uid in ev["allies"]["units"]:
			var side := Vector3(toward.z, 0, -toward.x) * (float(k) - 1.5) * 2.0
			var u = spawn_unit(String(uid), player_team, hq_pos + toward * 14.0 + side)
			if u:
				u.set_meta("saga_ally", true)
				player_commander.recompute_pop()
			if u and u.has_method("play_production_arrival_cue"):
				u.play_production_arrival_cue()
			k += 1
		get_tree().create_timer(8.0, false).timeout.connect(func():
			if game_running:
				emit_signal("alert", String(ev["allies"]["line"]), Vector3.ZERO))
	for wave in ev.get("waves", []):
		get_tree().create_timer(float(wave["at"]), false).timeout.connect(func(): _spawn_saga_wave(wave))

## Endless Road "Warband" twist: at three minutes a war party of the first
## enemy's line infantry marches on the player.
## Endless Road boss stages (every fifth stage that is not a festival): a
## Champion guards the enemy stronghold. Slaying it pays like three Elites.
func _spawn_champion(depth: int) -> void:
	if commanders.size() < 2:
		return
	var race := String(commanders[1].race)
	var pick := ""
	var best_tier := 0
	for id in UnitDefs.get_all():
		var d: Dictionary = UnitDefs.get_all()[id]
		if String(d.get("race", "")) != race or String(d.get("role", "")) in ["worker", "hero", "siege", "healer"] or bool(d.get("is_siege", false)):
			continue
		if int(d.get("tier", 1)) > best_tier:
			best_tier = int(d.get("tier", 1))
			pick = id
	if pick == "":
		return
	var home: Vector3 = map.get("start_positions", [Vector3.ZERO, Vector3.ZERO])[1]
	var toward := (Vector3.ZERO - home).normalized()
	var boss = spawn_unit(pick, 1, home + toward * 18.0)
	if boss == null:
		return
	boss.set_meta("elite", true)
	boss.set_meta("champion", true)
	boss.max_hp *= 4.0 + float(depth) * 0.1
	boss.hp = boss.max_hp
	boss.base_dmg *= 2.0
	if is_instance_valid(boss.model_root):
		boss.model_root.scale *= 1.5
	get_tree().create_timer(8.0, false).timeout.connect(func():
		if game_running:
			emit_signal("alert", "A Champion guards the enemy stronghold. Break it, and the road pays threefold.", boss.global_position if is_instance_valid(boss) else Vector3.ZERO))

## Road Tyrants (EndlessDefs.BOSSES): a named giant on every 25th stage, with
## a mechanic of its own, run from a once-a-second tick while it lives.
var road_boss = null
var tyrant_slain := ""

## Lifetime counters for deeds (AchievementDefs), kept in the profile stats.
func _bump_profile_stat(key: String) -> void:
	if not ProfileManager.has_hero():
		return
	var st: Dictionary = ProfileManager.data.get("stats", {})
	st[key] = int(st.get(key, 0)) + 1
	ProfileManager.data["stats"] = st
var _boss_kind := ""
var _boss_clock := 0.0

func _spawn_road_boss(depth: int) -> void:
	var bdef: Dictionary = load("res://scripts/game/endless_defs.gd").boss(depth)
	if bdef.is_empty() or commanders.size() < 2:
		return
	var race := String(commanders[1].race)
	var pick := ""
	var best_tier := 0
	for id in UnitDefs.get_all():
		var d: Dictionary = UnitDefs.get_all()[id]
		if String(d.get("race", "")) != race or String(d.get("role", "")) in ["worker", "hero", "siege", "healer"] or bool(d.get("is_siege", false)):
			continue
		if int(d.get("tier", 1)) > best_tier:
			best_tier = int(d.get("tier", 1))
			pick = id
	if pick == "":
		return
	var home: Vector3 = map.get("start_positions", [Vector3.ZERO, Vector3.ZERO])[1]
	var toward := (Vector3.ZERO - home).normalized()
	var boss = spawn_unit(pick, 1, home + toward * 20.0)
	if boss == null:
		return
	boss.def = boss.def.duplicate()
	boss.def["name"] = String(bdef["name"])
	boss.set_meta("elite", true)
	boss.set_meta("champion", true)
	boss.set_meta("road_boss", true)
	var cycle := float(depth / 100)
	boss.max_hp *= 12.0 + float(depth) * 0.25 + cycle * 6.0
	boss.hp = boss.max_hp
	boss.base_dmg *= 2.5 + cycle
	boss.base_armor += 3.0 + cycle * 2.0
	if is_instance_valid(boss.model_root):
		boss.model_root.scale *= 2.0
	road_boss = boss
	_boss_kind = String(bdef["kind"])
	if _boss_kind == "ward":
		for k in 4:
			var guard = spawn_unit(pick, 1, boss.global_position + Vector3(cos(k * 1.57), 0, sin(k * 1.57)) * 4.0)
			if guard:
				guard.set_meta("boss_court", true)
	get_tree().create_timer(6.0, false).timeout.connect(func():
		if game_running and is_instance_valid(boss):
			emit_signal("alert", "%s holds the enemy stronghold. %s" % [String(bdef["name"]), String(bdef["text"])], boss.global_position))
	_boss_tick()

func _boss_tick() -> void:
	if not game_running or not is_instance_valid(road_boss) or road_boss.is_dead:
		return
	get_tree().create_timer(1.0, false).timeout.connect(_boss_tick)
	_boss_clock += 1.0
	var b = road_boss
	match _boss_kind:
		"pulse":
			# A ring of fire every 8 seconds, with a second's warning flare.
			if int(_boss_clock) % 8 == 7:
				spawn_ring_fx(b.global_position, Color(1.0, 0.45, 0.15), 5.0)
			elif int(_boss_clock) % 8 == 0:
				apply_splash(b.global_position, 7.0, b.cur_dmg() * 1.2, "magic", b.team, null, b, "fire")
				spawn_hit_fx(b.global_position + Vector3.UP, "fire")
		"summon":
			# The pack answers every 20 seconds.
			if int(_boss_clock) % 20 == 0:
				var wolf := ""
				for id in UnitDefs.get_all():
					var d: Dictionary = UnitDefs.get_all()[id]
					if String(d.get("race", "")) == String(b.commander.race) and int(d.get("tier", 1)) == 1 and String(d.get("role", "")) == "melee":
						wolf = id
						break
				if wolf != "":
					for k in 3:
						var w = spawn_unit(wolf, b.team, b.global_position + Vector3(cos(k * 2.1), 0, sin(k * 2.1)) * 3.0)
						if w:
							w.command_move(map.get("start_positions", [Vector3.ZERO])[player_team], true)
					emit_signal("alert", "The pack answers the howl.", b.global_position)
		"regen":
			# Heals 3% a second once it has gone 3 seconds without being hit.
			if Time.get_ticks_msec() - int(b.get("_last_damaged_msec")) > int(3000.0 / maxf(0.01, Engine.time_scale)):
				b.hp = minf(b.max_hp, b.hp + b.max_hp * 0.03)

## The Moura Queen takes half damage while any of her court still stands.
func boss_damage_scale(unit) -> float:
	if unit != road_boss or _boss_kind != "ward":
		return 1.0
	for u in get_tree().get_nodes_in_group("units"):
		if is_instance_valid(u) and not u.is_dead and u.has_meta("boss_court"):
			return 0.5
	return 1.0

var _stage_mutations: Dictionary = {}

func _apply_mutations(u) -> void:
	for k in _stage_mutations:
		var r := float(_stage_mutations[k])
		match String(k):
			"ironhide": u.base_armor += 2.0 * r
			"frenzy": u.attack_cd = maxf(0.35, u.attack_cd / (1.0 + 0.12 * r))
			"leeching": u.hero_flags["lifesteal"] = float(u.hero_flags.get("lifesteal", 0.0)) + 0.05 * r
			"titan":
				u.max_hp *= 1.0 + 0.25 * r
				u.hp = u.max_hp
			"swift": u.move_speed *= 1.0 + 0.10 * r

## Endless Road stage twists that shape the start of a battle.
var twist_damage_mult := 1.0
var twist_veteran_foes := false
var twist_gloom := false
var twist_vein_mult := 1.0

func _apply_start_twists() -> void:
	var twists: Array = Match.get_config().get("twists", [])
	if String(Match.get_config().get("mode", "")) == "endless":
		_stage_mutations = load("res://scripts/game/endless_defs.gd").mutations_for(int(Match.get_config().get("endless_depth", 0)))
		# Soldiers already on the field at the start mutate too.
		if not _stage_mutations.is_empty():
			for u in all_units():
				if is_instance_valid(u) and u.team != player_team and not u.is_worker:
					_apply_mutations(u)
	# Blood Moon: every blow on the field lands harder, for both sides.
	if "blood_moon" in twists:
		twist_damage_mult = 1.25
	twist_veteran_foes = "veterans" in twists
	twist_gloom = "gloom" in twists
	twist_vein_mult = 1.5 if "rich_veins" in twists else 1.0
	if twist_gloom:
		for u in all_units():
			if is_instance_valid(u) and u.team == player_team:
				u.vision *= 0.6
	# Lean Season: everyone starts with half the stores.
	if "lean" in twists:
		for cmd in commanders:
			for k in cmd.resources.keys():
				cmd.resources[k] = int(float(cmd.resources[k]) * 0.5)
	# Fortified: each enemy start already has two towers raised.
	if "fortified" in twists:
		for i in range(1, commanders.size()):
			var cmd = commanders[i]
			var tower_id := ""
			for bid in GameData.buildings_for_race(String(cmd.race)):
				if String(GameData.get_building(bid).get("kind", "")) == "tower":
					tower_id = bid
					break
			if tower_id == "":
				continue
			var start: Vector3 = map["start_positions"][i]
			var toward := (Vector3.ZERO - start).normalized()
			var side := Vector3(toward.z, 0, -toward.x)
			for s in [-1.0, 1.0]:
				var tdef := GameData.get_building(tower_id).duplicate()
				tdef["id"] = tower_id
				_create_building(tdef, i, start + toward * 20.0 + side * s * 10.0, true)
	# Allies: a band of the player's own soldiers joins at the start.
	if "allies" in twists and player_team < commanders.size():
		var race := String(commanders[player_team].race)
		var picks: Array = []
		for id in UnitDefs.get_all():
			var d: Dictionary = UnitDefs.get_all()[id]
			if String(d.get("race", "")) == race and int(d.get("tier", 1)) == 1 and String(d.get("role", "")) in ["melee", "ranged", "defender"]:
				picks.append(id)
		var start2: Vector3 = map["start_positions"][player_team]
		var toward2 := (Vector3.ZERO - start2).normalized()
		for k in mini(4, picks.size() * 4):
			if picks.is_empty():
				break
			var u = spawn_unit(String(picks[k % picks.size()]), player_team, start2 + toward2 * 12.0 + Vector3(toward2.z, 0, -toward2.x) * (float(k) - 1.5) * 2.0)
			if u:
				u.set_meta("saga_ally", true)

func _schedule_warband() -> void:
	get_tree().create_timer(180.0, false).timeout.connect(func():
		if not game_running or commanders.size() < 2:
			return
		var race := String(commanders[1].race)
		var picks: Array = []
		for id in UnitDefs.get_all():
			var d: Dictionary = UnitDefs.get_all()[id]
			if String(d.get("race", "")) == race and int(d.get("tier", 1)) == 1 and String(d.get("role", "")) in ["melee", "ranged", "defender"]:
				picks.append(id)
		if picks.is_empty():
			return
		var n := 4 + int(Match.get_config().get("endless_depth", 1)) / 5
		var units: Array = []
		for i in n:
			units.append(picks[i % picks.size()])
		_spawn_saga_wave({"team": 1, "units": units, "line": "A warband crests the ridge. The road does not let you rest."}))

func _spawn_saga_wave(wave: Dictionary) -> void:
	if not game_running:
		return
	var team := int(wave.get("team", 1))
	if team >= commanders.size():
		team = commanders.size() - 1
	if team == player_team or commanders[team].defeated:
		return
	var from: Vector3 = map.get("start_positions", [Vector3.ZERO, Vector3.ZERO])[team]
	var target: Vector3 = map.get("start_positions", [Vector3.ZERO])[player_team]
	var toward := (target - from).normalized()
	var k := 0
	for uid in wave["units"]:
		var u = spawn_unit(String(uid), team, from + toward * 16.0 + Vector3(toward.z, 0, -toward.x) * (float(k) - 2.0) * 2.0)
		if u:
			u.command_move(target, true)
		k += 1
	emit_signal("alert", String(wave.get("line", "Enemy reinforcements arrive!")), from + toward * 16.0)

func _start_saga_voices() -> void:
	var chapter_id := String(Match.get_config().get("campaign_chapter", ""))
	if chapter_id == "":
		return
	var chapter := CampaignDefs.find(chapter_id)
	if chapter.is_empty():
		return
	var lines: Array = [[4.0, CampaignDefs.opening_for(chapter_id, String(player_commander.race) if is_instance_valid(player_commander) else "")]]
	var taunts: Array = chapter.get("taunts", [])
	if taunts.size() > 0:
		lines.append([180.0, String(taunts[0])])
	if taunts.size() > 1:
		lines.append([480.0, String(taunts[1])])
	for entry in lines:
		if String(entry[1]) == "":
			continue
		get_tree().create_timer(float(entry[0]), false).timeout.connect(func():
			if game_running:
				emit_signal("alert", String(entry[1]), Vector3.ZERO))

func _start_match() -> void:
	game_running = true
	_prewarm_combat_presentation()
	_bake_overview_texture()
	_start_ambient_sound()
	_visibility_timer = VISIBILITY_UPDATE_INTERVAL
	_update_player_visibility()
	AudioManager.play_music_path(Sfx.music_key("battle"), -10.0, true)
	_battle_music = true
	last_alert_message = "The battle for %s begins!" % str(map.get("name", Match.get_config().get("map", "the selected battlefield")))
	emit_signal("alert", last_alert_message, Vector3.ZERO)
	_start_saga_voices()
	_start_saga_events()
	_pick_bounty()
	_schedule_lume_surge()
	if "warband" in Match.get_config().get("twists", []):
		_schedule_warband()
	var e_depth := int(Match.get_config().get("endless_depth", 0))
	if String(Match.get_config().get("mode", "")) == "endless" and e_depth % 25 == 0:
		_spawn_road_boss(e_depth)
	elif String(Match.get_config().get("mode", "")) == "endless" and e_depth % 5 == 0 and e_depth % 10 != 0:
		_spawn_champion(e_depth)
	if String(Match.get_config().get("mode", "")) == "endless":
		var ecfg := Match.get_config()
		get_tree().create_timer(3.0, false).timeout.connect(func():
			if game_running:
				emit_signal("alert", "The Endless Road, stage %d: %s" % [int(ecfg.get("endless_depth", 1)), String(ecfg.get("endless_title", ""))], Vector3.ZERO))
	_spawn_retinue()

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
	_check_survival()
	_visibility_timer += delta
	if _visibility_timer >= VISIBILITY_UPDATE_INTERVAL:
		_visibility_timer = 0.0
		_update_player_visibility()
	_aura_timer += delta
	_navigation_watchdog_timer += delta
	if _navigation_watchdog_timer >= 0.25:
		_navigation_watchdog_timer = 0.0
		_sample_navigation_watchdog()
	if _aura_timer >= 0.4:
		_update_command_auras()
		_aura_timer = 0.0
	_tick_vein_flares(delta)
	_last_stand_timer += delta
	if _last_stand_timer >= 20.0:
		_last_stand_timer = 0.0
		_point_at_last_buildings()
	_check_victory()

## Hunting the last buildings: once an enemy has no fighters left, its
## remaining buildings are pinged on the minimap (and briefly revealed) every
## 20 s, so a won battle never turns into a search through the fog.
var _last_stand_timer := 0.0

func _point_at_last_buildings() -> void:
	for cmd in commanders:
		if cmd.team == player_team or cmd.defeated:
			continue
		var fighters := 0
		for u in cmd.units:
			if is_instance_valid(u) and not u.is_dead and not u.is_worker:
				fighters += 1
		if fighters > 0:
			continue
		var left: Array = []
		for b in cmd.buildings:
			if is_instance_valid(b) and not b.is_dead:
				left.append(b)
		if left.is_empty() or left.size() > 4:
			continue
		for b in left:
			if _player_visibility_scope_active():
				_mark_visibility_radius(b.global_position, float(b.footprint) + 4.0)
		emit_signal("alert", "The enemy's army is broken. %d building%s still stand%s: see the minimap." % [left.size(), "" if left.size() == 1 else "s", "s" if left.size() == 1 else ""], left[0].global_position)
		for b in left.slice(1):
			emit_signal("alert", "", b.global_position)

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

## Survival chapters (CampaignDefs "survive"): the player wins by holding
## out for the chapter's time with their base standing.
var _survive_seconds := -1

func survival_remaining() -> float:
	if _survive_seconds < 0:
		var chapter_id := String(Match.get_config().get("campaign_chapter", ""))
		_survive_seconds = CampaignDefs.survive_seconds(chapter_id) if chapter_id != "" else 0
	return maxf(0.0, float(_survive_seconds) - match_time) if _survive_seconds > 0 else -1.0

func _check_survival() -> void:
	var left := survival_remaining()
	if left == 0.0 and not match_ended and is_instance_valid(player_commander) and not player_commander.defeated:
		_end_game(true, "You held until dawn")

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
	# Side roads are optional; they pay half again in experience.
	if CampaignDefs.is_side(String(Match.get_config().get("campaign_chapter", ""))):
		xp *= 1.5
	if bool(Match.get_config().get("campaign_heroic", false)):
		xp *= 1.5
	if String(Match.get_config().get("mode", "")) == "endless":
		xp *= float(Match.get_config().get("endless_xp_mult", 1.0))
	if "spoils" in Match.get_config().get("twists", []):
		xp *= 1.25
	if victory:
		xp *= 1.6
	# Mentor talent: +5% battle experience per rank (sub-linear, never capped).
	if ProfileManager.has_hero():
		var mentor := int((ProfileManager.hero().get("talents", {}) as Dictionary).get("mentor", 0))
		if mentor > 0:
			xp *= 1.0 + 0.05 * pow(float(mentor), 0.9)
	var bounty_won := _bounty_met(victory)
	if bounty_won:
		xp *= 1.2
	var level_before := int(ProfileManager.hero().get("level", 1)) if ProfileManager.has_hero() else 0
	if not _profile_recorded and ProfileManager.has_hero():
		_profile_recorded = true
		_record_retinue(victory)
		profile_record_count += 1
		ProfileManager.record_battle(victory, kills_by_player, xp)
		_battle_loot = _roll_battle_loot(victory)
	result_snapshot = {"victory": victory, "reason": reason, "mode": Match.get_config().get("mode", "skirmish"),
		"victory_kind": _victory_kind, "player_team": player_team, "kills": kills_by_player,
		"building_kills": building_destruction_events.filter(func(e): return int(e.get("source_team", -1)) == player_team).size(),
		"units_lost": combat_death_events.filter(func(e): return int(e.get("victim_team", -1)) == player_team).size(),
		"hero_kills": hero_kills, "veterans_made": veterans_made, "loot": _battle_loot,
		"bounty": String(bounty.get("text", "")), "bounty_won": bounty_won,
		"deeds": ProfileManager.check_achievements() if ProfileManager.has_hero() else [],
		"talent_points": ProfileManager.talent_points() if ProfileManager.has_hero() else 0,
		"records": ProfileManager.endless_record(int(Match.get_config().get("endless_depth", 1)), String(Match.get_config().get("player_race", "")), match_time, ("w%d" % int(Match.get_config()["endless_weekly"])) if Match.get_config().has("endless_weekly") else "") if victory and String(Match.get_config().get("mode", "")) == "endless" else {},
		"xp": xp, "time": match_time, "completion_timestamp": Time.get_unix_time_from_system(),
		"level_before": level_before, "level_after": int(ProfileManager.hero().get("level", 1)) if ProfileManager.has_hero() else 0,
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

## Kills made within 18 m of a team's living hero feed that hero's battlefield
## level (see Unit.gain_field_xp). Heroes are worth more than soldiers.
func _award_hero_field_xp(victim, source_team: int) -> void:
	if source_team < 0 or source_team >= commanders.size():
		return
	var hero = commanders[source_team].hero_ref
	if not is_instance_valid(hero) or hero.is_dead or not hero.has_method("gain_field_xp"):
		return
	if hero.global_position.distance_to(victim.global_position) > 18.0:
		return
	var amount := 60 if victim.is_hero else (6 if victim.is_worker else 12)
	if hero.gain_field_xp(amount) and source_team == player_team:
		emit_signal("hero_leveled", hero.field_level)

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
	_award_hero_field_xp(unit, source_team)
	if unit.is_hero:
		_saga_react(int(unit.team), "hero")
		if int(unit.team) != player_team and source_team == player_team:
			enemy_heroes_slain += 1
	if unit.has_meta("road_boss") and source_team == player_team:
		# A Road Tyrant pays like ten Elites (on top of the milestone legendary),
		# and always drops a piece of its own set.
		elites_slain += 7
		tyrant_slain = String(load("res://scripts/game/endless_defs.gd").boss(int(Match.get_config().get("endless_depth", 0))).get("id", ""))
		_bump_profile_stat("tyrants_slain")
		emit_signal("alert", "%s is slain! The road will remember this." % String(unit.def.get("name", "The Tyrant")), unit.global_position)
	if unit.has_meta("elite") and source_team == player_team:
		elites_slain += 3 if unit.has_meta("champion") else 1
		_bump_profile_stat("elites_slain")
		emit_signal("alert", "An Elite %s falls. The field owes you a better spoil." % String(unit.def.get("name", "enemy")), unit.global_position)
		Sfx.play("levelup", -8.0)
		if is_instance_valid(_fx_container):
			CombatVfx.lume_pillar(_fx_container, unit.global_position, Color(1.0, 0.8, 0.3))
	# hero down handling
	for cmd in commanders:
		if cmd.hero_ref == unit:
			cmd.hero_ref = null
			_schedule_hero_revival(cmd, String(unit.unit_id))

## Warlords Battlecry heroes are not lost for the whole battle: the Lume
## raises a fallen hero at their stronghold after a while (45 s, plus a second
## per player hero level up to 90 s). No stronghold, no revival until one
## stands again.
func _schedule_hero_revival(cmd, hero_id: String) -> void:
	if hero_id == "" or not game_running:
		return
	var delay := 45.0
	if cmd.is_human and ProfileManager.has_hero():
		delay += minf(45.0, float(ProfileManager.hero().get("level", 1)))
	if cmd.team == player_team:
		emit_signal("alert", "Your hero has fallen. The Lume will raise them at your stronghold in %d seconds." % int(delay), Vector3.ZERO)
	get_tree().create_timer(delay, false).timeout.connect(_try_hero_revival.bind(cmd, hero_id))

func _try_hero_revival(cmd, hero_id: String) -> void:
	if not game_running or cmd.defeated or is_instance_valid(cmd.hero_ref):
		return
	var hq = null
	for b in cmd.buildings:
		if is_instance_valid(b) and not b.is_dead and bool(b.def.get("is_hq", false)) and bool(b.get("is_built")):
			hq = b
			break
	if hq == null:
		get_tree().create_timer(15.0, false).timeout.connect(_try_hero_revival.bind(cmd, hero_id))
		return
	var hq_pos: Vector3 = hq.global_position
	var toward := (Vector3.ZERO - hq_pos).normalized()
	var hero = spawn_unit(hero_id, cmd.team, hq_pos + toward * 9.0)
	if hero == null:
		return
	cmd.hero_ref = hero
	if is_instance_valid(_fx_container):
		CombatVfx.lume_pillar(_fx_container, hero.global_position, Color(1.0, 0.78, 0.36))
		CombatVfx.motes(_fx_container, hero.global_position, Color(1.0, 0.82, 0.35), 2.0)
		CombatVfx.shockwave(_fx_container, hero.global_position, Color(1.0, 0.82, 0.35), 3.0)
	# The hero grows up out of the light.
	if is_instance_valid(hero.model_root):
		var full: Vector3 = hero.model_root.scale
		hero.model_root.scale = full * 0.15
		hero.model_root.create_tween().tween_property(hero.model_root, "scale", full, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if cmd.team == player_team:
		emit_signal("alert", "The Lume burns. Your hero rises again at the stronghold!", hero.global_position)

func _on_building_died(building) -> void:
	_unregister_world_blocker(building)
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
	if bool(building.def.get("is_hq", false)) or String(building.def.get("kind", "")) == "main":
		_saga_react(int(building.team), "hq")
	_unregister_world_blocker(building)
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
	# Spells grow with the hero forever: they scale with the hero's real
	# damage (levels, gear, mastery) over the unit's base damage.
	var power := maxf(1.0, float(hero.cur_dmg()) / maxf(1.0, float(hero.def.get("dmg", 30)))) * (1.0 + float(hero.get("spell_power") if hero.get("spell_power") != null else 0.0))
	var ab := SkillDefs.get_abilities().get(id, {})
	match id:
		"rally":
			heal_allies_near(hero.global_position, ab.get("range", 14.0), (40.0 + hero.heal_power) * power, hero.team)
			for u in commander_for_team(hero.team).units:
				if is_instance_valid(u) and not u.is_dead:
					if u.global_position.distance_to(hero.global_position) <= ab.get("range", 14.0):
						u.apply_slow(-1.0)  # no-op clear
			spawn_ring_fx(hero.global_position, Color(1, 0.9, 0.4), ab.get("range", 14.0))
			_ability_motes_on_allies(hero, ab.get("range", 14.0), Color(1.0, 0.82, 0.38))
		"slam":
			var dmg = ab.get("dmg", 60) * (1.5 if level >= 2 else 1.0) * power
			var rng = ab.get("range", 8.0) * (1.4 if level >= 2 else 1.0)
			for u in all_units():
				if is_instance_valid(u) and not u.is_dead and u.team != hero.team:
					if u.global_position.distance_to(hero.global_position) <= rng:
						u.take_damage(GameData.compute_damage(dmg, "blunt", u.armor_class, u.cur_armor()), hero)
						u.apply_stun(1.5)
			spawn_ring_fx(hero.global_position, Color(0.9, 0.6, 0.2), rng)
			CombatVfx.slam(_fx_container, hero.global_position, rng)
			emit_signal("camera_shake", 0.9, hero.global_position)
		"charge":
			var dir = (target_pos - hero.global_position)
			dir.y = 0
			var dist = min(dir.length(), ab.get("range", 18.0))
			var dest = hero.global_position + dir.normalized() * dist
			var dmg = ab.get("dmg", 50) * (1.4 if level >= 2 else 1.0) * power
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
					spawn_projectile(hero.global_position + Vector3.UP * 1.5, tgt, float(ab.get("dmg", 70)) * power, "arcane", hero.team, "lume_bolt", 0.0, hero)
		"heal":
			heal_allies_near(hero.global_position, ab.get("range", 14.0), (float(ab.get("heal", 120)) + hero.heal_power) * power, hero.team)
			spawn_ring_fx(hero.global_position, Color(0.4, 1.0, 0.6), ab.get("range", 14.0))
			_ability_motes_on_allies(hero, ab.get("range", 14.0), Color(0.45, 1.0, 0.6))
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
			CombatVfx.motes(_fx_container, hero.global_position, Color(1.0, 0.55, 0.95), 2.0)
			emit_signal("camera_shake", 0.5, hero.global_position)
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
## A "+12 gold" that rises and fades over a paying outpost.
const INCOME_COLORS := {"gold": Color(1.0, 0.84, 0.35), "stone": Color(0.82, 0.85, 0.9), "timber": Color(0.62, 0.9, 0.45), "food": Color(1.0, 0.9, 0.55)}
func spawn_income_popup(pos: Vector3, amount: int, kind: String) -> void:
	if not is_instance_valid(_fx_container):
		return
	var l := Label3D.new()
	l.text = "+%d %s" % [amount, kind]
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.fixed_size = true
	l.pixel_size = 0.0009
	l.font_size = 22
	l.outline_size = 6
	l.modulate = INCOME_COLORS.get(kind, Color.WHITE)
	l.outline_modulate = Color(0.05, 0.03, 0.0, 0.9)
	_fx_container.add_child(l)
	l.global_position = pos
	var t := l.create_tween().set_parallel(true)
	t.tween_property(l, "global_position:y", pos.y + 2.2, 1.6)
	t.tween_property(l, "modulate:a", 0.0, 1.6).set_delay(0.6)
	t.chain().tween_callback(l.queue_free)

func spawn_hit_fx(pos: Vector3, kind: String) -> void:
	var col := Color(1, 0.8, 0.4)
	match kind:
		"cinder": col = Color(1, 0.5, 0.15)
		"void_bolt", "rift_shell": col = Color(0.7, 0.3, 0.9)
		"thorn", "thornpod": col = Color(0.5, 0.8, 0.4)
		"arcane": col = Color(0.6, 0.8, 1.0)
		"fire": col = Color(1.0, 0.4, 0.1)
		"blood": col = Color(0.95, 0.2, 0.2)
	# Sparks, flash and a dust kick from cached materials (CombatVfx); still a
	# single short-lived, non-gameplay effect for every impact kind.
	if kind == "melee":
		col = Color(1.0, 0.72, 0.42)
	CombatVfx.hit(_fx_container, pos, col, kind in ["cinder", "rift_shell", "thornpod", "arcane", "fire"])

func spawn_collapse_fx(pos: Vector3, footprint: float) -> void:
	if not is_instance_valid(_fx_container):
		return
	CombatVfx.collapse(_fx_container, pos, footprint)
	clear_ground_cover(pos, footprint * 1.5)
	emit_signal("camera_shake", 0.7, pos)

func spawn_death_fx(pos: Vector3) -> void:
	if is_instance_valid(_fx_container):
		CombatVfx.death(_fx_container, pos)
		CombatVfx.battle_scar(_fx_container, pos)
		# The grass where a unit fell stays trampled.
		clear_ground_cover(pos, 0.9)

func spawn_heal_fx(pos: Vector3) -> void:
	_burst(pos + Vector3.UP, Color(0.4, 1.0, 0.6), 5, 0.6)

func _ability_motes_on_allies(hero, radius: float, col: Color) -> void:
	# Rising motes on each ally the ability touched, capped so a big army
	# never spawns dozens of emitters in one frame.
	var shown := 0
	for u in commander_for_team(hero.team).units:
		if shown >= 14:
			break
		if is_instance_valid(u) and not u.is_dead and u.global_position.distance_to(hero.global_position) <= radius:
			CombatVfx.motes(_fx_container, u.global_position, col, 1.0)
			shown += 1

func spawn_ring_fx(pos: Vector3, col: Color, radius: float) -> void:
	# Ability areas: a soft expanding shockwave on the ground (CombatVfx).
	CombatVfx.shockwave(_fx_container, pos, col, radius)

func spawn_order_marker(pos: Vector3, col: Color, radius: float, attack: bool) -> void:
	CombatVfx.order_marker(_fx_container, pos, col, radius, attack)

func _burst(pos: Vector3, col: Color, count: int, life: float) -> void:
	var p := GPUParticles3D.new()
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 5.0
	mat.gravity = Vector3(0, -6, 0)
	mat.scale_min = 0.18
	mat.scale_max = 0.42
	mat.color = col
	p.process_material = mat
	var mesh := SphereMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.24
	var mm := StandardMaterial3D.new()
	mm.albedo_color = col
	mm.emission_enabled = true
	mm.emission = col
	mm.emission_energy_multiplier = 2.8
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
