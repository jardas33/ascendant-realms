class_name Unit
extends CharacterBody3D
## The universal combat/worker unit. Data-driven from a unit def dictionary.
## Handles movement (NavigationAgent3D), combat, gathering, states, selection.

signal died(unit)

enum State { IDLE, MOVING, ATTACK_MOVE, ATTACKING, GATHERING, RETURNING, BUILDING, HOLD, PATROL, FOLLOW, DEAD }

# --- identity ---
var def := {}
var unit_id := ""
var team := 0
var commander = null
var world = null
var is_hero := false
var is_worker := false
var is_siege := false

# --- stats ---
var max_hp := 100.0
var hp := 100.0
var base_dmg := 10.0
var dmg_type := "slash"
var armor_class := "medium"
var base_armor := 0.0
var atk_range := 0.0
var attack_cd := 1.0
var move_speed := 3.5
var vision := 20.0
var pop := 1
var splash := 0.0

# --- hero extras ---
var mana := 0.0
var max_mana := 0.0
var mana_regen := 0.0
var abilities := {}          # id -> level
var ability_cd := {}         # id -> time remaining
var aura_dmg := 0.0
var aura_armor := 0.0
var aura_range := 0.0
var regen := 0.0
var hero_flags := {}
var heal_power := 0.0
var _last_stand_used := false

# --- runtime ---
var state: int = State.IDLE
var is_dead := false
var is_built := true
var _attack_timer := 0.0
var _target = null            # attack target (Unit or Building)
var _move_target := Vector3.ZERO
var _attack_move_ordered := false
var _attack_move_destination := Vector3.ZERO
var _patrol_a := Vector3.ZERO
var _patrol_b := Vector3.ZERO
var _follow_target = null
var _hold_position := false
var _stun := 0.0
var _rooted := 0.0
var _slow := 0.0
var _upg_dmg := 0.0
var _upg_armor := 0.0
var _aura_bonus_dmg := 0.0
var _aura_bonus_armor := 0.0
var _veterancy := 0
var _kills := 0
var _last_damage_source = null
var _last_damage_source_team := -1
var _last_damage_source_id := ""
var _last_damage_kind := ""
var _last_damage_type := ""
var _death_recorded := false

# gather
var _gather_node = null
var _pending_gather_node = null
var _desired_gather_kind := ""
var _carry := 0
var _carry_kind := ""
const CARRY_MAX := 10
var _gather_timer := 0.0
var _dropoff_retry := 0.0
var _carry_hold := false
var _last_source_node_id := ""
var _last_source_amount_before := 0
var _last_source_amount_after := 0
var _last_deposit_sequence := 0

# build
var _build_target = null

# nodes
var agent: NavigationAgent3D
var model_root: Node3D
var _team_marker: MeshInstance3D
var anim: AnimationPlayer
var selection_ring: MeshInstance3D
var _selection_visual_radius := 0.4
var _selection_pick_radius := 0.5
var _selection_indicator_radius := 0.5
var _visual_height := 0.0
var _anim_names := {}
var _cur_anim := ""
var _repath := 0.0
var _requested_move_target := Vector3.ZERO
var _navigation_effective_target := Vector3.ZERO
var _navigation_command_type := ""
var _navigation_invalid_count := 0
var _navigation_invalid_consecutive := 0
var _navigation_repath_attempts := 0
var _navigation_rejected_velocity_count := 0
var _navigation_failure_count := 0
var _navigation_last_invalid_reason := ""
var _navigation_audit_events: Array = []
var _navigation_target_pending := true
var _navigation_target_projection_distance := 0.0
var _navigation_path_wait_frames := 0
var _navigation_terminal_failure_recorded := false
var _navigation_last_target := Vector3(INF, INF, INF)
var _navigation_last_target_ready := false
var _navigation_retry_elapsed := 0.0
var _navigation_repath_cooldown := 0.0
var _boundary_recovery_active := false
var _boundary_recovery_target := Vector3.ZERO
var _boundary_resume_state := State.IDLE
var _boundary_recovery_reason := ""
var _boundary_recovery_distance_last := 0.0
var _v0436_r1f_physics_audit: Array = []
var _v0436_r1f_last_move_frame := -1
var _v0436_r1f_move_count := 0
var _v0436_r1f_last_recovery_move_frame := -1
var _health_bar_root: Node3D
var _health_bar_fill: MeshInstance3D
var _health_bar_back: MeshInstance3D
var _r15_attack_cue: MeshInstance3D
var _r15_hit_flash: MeshInstance3D
var _r15_hit_flash_time := 0.0

const ARRIVE_DIST := 1.2
const NAVIGATION_REPATH_INTERVAL := 0.20
const NAVIGATION_RETRY_BUDGET := 2.5
const V0436_R1F_AUDIT_CAP := 512

# P1-R13 presentation targets. These affect only the visible model envelope;
# gameplay height, collision, navigation radius, spacing, range and speed stay
# sourced from the unit definition below.
const P1R13_WORKER_VISUAL_EMPHASIS := 1.34
const P1R13_MILITARY_VISUAL_EMPHASIS := 1.52
const P1R13_HERO_VISUAL_EMPHASIS := 1.68
const P1R13_VISUAL_HEIGHT_MAX := 3.8

# P1-R20 imported-model readability: a small per-instance material lift keeps
# authored character identity intact while separating silhouettes from noisy
# ground. TeamPip remains a secondary ownership cue; no gameplay values change.
const P1R20_WORKER_VALUE_LIFT := 0.08
const P1R20_MILITARY_VALUE_LIFT := 0.11
const P1R20_HERO_VALUE_LIFT := 0.15
const P1R20_ROUGHNESS_FLOOR := 0.28

func _v0436_r1j_recorder():
	if OS.get_environment("ASCENDANT_V0436_R1J_CAPTURE") != "1" or not world:
		return null
	if not world.has_meta("v0436_r1j_recorder"):
		return null
	var recorder = world.get_meta("v0436_r1j_recorder", null)
	return recorder if is_instance_valid(recorder) else null

func _v0436_r1j_target_ref(target) -> Dictionary:
	if not is_instance_valid(target):
		return {"runtime_id":"", "definition_id":"", "team":-1, "alive":false}
	return {"runtime_id":str(target.get_instance_id()), "definition_id":String(target.unit_id) if target is Unit else String(target.building_id), "team":int(target.team), "alive":not bool(target.is_dead)}

func _v0436_r1j_set_target(value, reason: String) -> void:
	var previous = _target
	_target = value
	var recorder = _v0436_r1j_recorder()
	if recorder and previous != value:
		recorder.record_target_transition(self, previous, value, reason)

func _ready() -> void:
	add_to_group("units")
	collision_layer = 2       # units layer
	collision_mask = 0        # we resolve avoidance via nav; no physics collisions
	floor_max_angle = deg_to_rad(60)

func configure(p_def: Dictionary, p_team: int, p_commander, p_world) -> void:
	def = p_def
	unit_id = p_def.get("id", "")
	team = p_team
	commander = p_commander
	world = p_world
	is_hero = p_def.get("is_hero", false)
	is_worker = p_def.get("role", "") == "worker"
	is_siege = p_def.get("is_siege", false)
	pop = int(p_def.get("pop", 1))

	max_hp = float(p_def.get("hp", 100))
	hp = max_hp
	base_dmg = float(p_def.get("dmg", 10))
	dmg_type = p_def.get("dmg_type", "slash")
	armor_class = p_def.get("armor_class", "medium")
	base_armor = float(p_def.get("armor", 0))
	atk_range = float(p_def.get("range", 0.0))
	attack_cd = float(p_def.get("attack_cd", 1.0))
	move_speed = float(p_def.get("speed", 3.5))
	vision = float(p_def.get("vision", 20.0))
	splash = float(p_def.get("splash", 0.0))
	heal_power = float(p_def.get("heal", 0.0))

	if is_hero:
		_apply_hero_stats()

	_apply_race_passive()

	_setup_nav()
	_build_model()
	_add_pick_shape()
	_build_selection_ring()
	_build_health_bar()
	_build_r15_combat_presentation()
	refresh_upgrade_bonuses()

## A capsule shape purely so mouse raycasts can pick this unit for selection.
## The body's collision_mask stays 0, so this never causes physical collisions.
func _add_pick_shape() -> void:
	var visual_height := ModelUtils.measure_height(model_root) if is_instance_valid(model_root) else 0.0
	var h: float = maxf(1.2, maxf(float(def.get("height", 1.8)), visual_height))
	_selection_visual_radius = _measure_selection_visual_radius()
	_selection_pick_radius = clampf(_selection_visual_radius * 1.2, 0.48, 0.9)
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = _selection_pick_radius
	cap.height = h
	cs.shape = cap
	cs.position.y = h * 0.5
	add_child(cs)

func _apply_hero_stats() -> void:
	var hs = commander.hero_stats if commander else {}
	max_hp += float(hs.get("bonus_hp", 0.0))
	hp = max_hp
	base_dmg += float(hs.get("bonus_dmg", 0.0))
	base_armor += float(hs.get("bonus_armor", 0.0))
	move_speed += float(hs.get("bonus_speed", 0.0))
	vision += float(hs.get("bonus_vision", 0.0))
	atk_range += float(hs.get("bonus_range", 0.0))
	attack_cd = max(0.35, attack_cd * (1.0 - float(hs.get("attack_speed", 0.0))))
	max_mana = float(hs.get("max_mana", 100.0))
	mana = max_mana
	mana_regen = float(hs.get("mana_regen", 5.0))
	aura_dmg = float(hs.get("aura_dmg", 0.0))
	aura_armor = float(hs.get("aura_armor", 0.0))
	aura_range = float(hs.get("aura_range", 0.0))
	regen = float(hs.get("regen", 0.0))
	heal_power += float(hs.get("heal_power", 0.0))
	abilities = hs.get("abilities", {}).duplicate()
	hero_flags = hs.get("flags", {}).duplicate()
	for id in abilities:
		ability_cd[id] = 0.0

## Signature race power — a real, functioning identity passive applied to every
## unit of the race (Barrosan Fortify and Lioraen Bloomfields are handled
## dynamically elsewhere: cur_armor() near the Clanhold, and the Groveheart heal aura).
func _apply_race_passive() -> void:
	if commander == null:
		return
	match commander.race:
		"grimtusk":                       # Bloodfury — harder-hitting green tide
			base_dmg *= 1.12
		"sylvan":                         # Precision — keener sight and reach
			vision += 5.0
			if atk_range > 0.0:
				atk_range += 2.0
		"karak":                          # Stone Resolve — armored and hardy
			base_armor += 2.0
			max_hp *= 1.12
			hp = max_hp
		"sunspear":                       # Sunfire — resilient morale (steady healing)
			regen += 2.0
		"wyldkin":                        # Pack Hunt — the swiftest army in the realm
			move_speed *= 1.15
		"hollow":                         # Undying — every warrior drains life on hit
			hero_flags["lifesteal"] = maxf(float(hero_flags.get("lifesteal", 0.0)), 0.12)
		"frostborn":                      # Winter's Wrath — towering, hard-hitting
			base_dmg *= 1.12
			max_hp *= 1.10
			hp = max_hp
		"vorthak":                        # Rift Toll — thralls move a touch faster
			move_speed *= 1.06
		_:
			pass

func _setup_nav() -> void:
	agent = NavigationAgent3D.new()
	agent.path_desired_distance = 0.8
	agent.target_desired_distance = ARRIVE_DIST
	agent.radius = 0.5
	agent.avoidance_enabled = true
	agent.max_speed = move_speed
	agent.neighbor_distance = 4.0
	agent.max_neighbors = 8
	agent.time_horizon_agents = 1.5
	agent.avoidance_priority = 0.9 if is_hero else 0.5
	add_child(agent)
	agent.velocity_computed.connect(_on_velocity_computed)

func _build_model() -> void:
	model_root = Node3D.new()
	model_root.name = "MeshRoot"
	add_child(model_root)
	var path: String = def.get("model", "")
	_visual_height = _visual_target_height()
	if path != "" and ResourceLoader.exists(path):
		var scn = load(path)
		var m = scn.instantiate()
		model_root.add_child(m)
		ModelUtils.setup_character_for_movement(m, _visual_height)
		_apply_p1r20_model_materials(m)
		# animation
		anim = m.find_child("AnimationPlayer", true, false)
		if not anim:
			var lib_path := _anim_lib_path()
			if lib_path != "" and ResourceLoader.exists(lib_path):
				anim = AnimationPlayer.new()
				m.add_child(anim)
				var lib = load(lib_path)
				if lib:
					anim.add_animation_library("", lib)
		if anim:
			ModelUtils.set_animation_loops(anim)
			_map_anims()
			_play("idle")
	else:
		# fallback capsule so the unit is always visible
		var mi := MeshInstance3D.new()
		var cap := CapsuleMesh.new()
		cap.radius = 0.4
		cap.height = _visual_height
		mi.mesh = cap
		mi.position.y = _visual_height * 0.5
		var mat := StandardMaterial3D.new()
		mat.albedo_color = commander.color if commander else Color.GRAY
		mi.material_override = mat
		model_root.add_child(mi)
	# team-color banner tint indicator
	_add_team_marker()


func _apply_p1r20_model_materials(model: Node3D) -> void:
	var lift := P1R20_WORKER_VALUE_LIFT if is_worker else (P1R20_HERO_VALUE_LIFT if is_hero else P1R20_MILITARY_VALUE_LIFT)
	for child in model.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		if not mi or not mi.mesh:
			continue
		for surface in mi.mesh.get_surface_count():
			var source := mi.get_active_material(surface)
			if not source or not source is BaseMaterial3D:
				continue
			# Duplicate per instance so two units sharing one imported GLB never
			# mutate the source resource or each other's visual state.
			var mat := (source as BaseMaterial3D).duplicate()
			mat.albedo_color = mat.albedo_color.lerp(Color(1.08, 1.08, 1.08), lift)
			mat.roughness = maxf(mat.roughness, P1R20_ROUGHNESS_FLOOR)
			mi.set_surface_override_material(surface, mat)

func _visual_target_height() -> float:
	# Presentation-only emphasis: keep gameplay definitions authoritative while
	# giving small role silhouettes enough screen presence at RTS zoom.
	# Selection/pick geometry is measured after this scale is applied.
	var configured := maxf(1.0, float(def.get("height", 1.8)))
	var role := String(def.get("role", ""))
	var emphasis := 1.22
	if role == "worker":
		emphasis = P1R13_WORKER_VISUAL_EMPHASIS
	elif is_hero or bool(def.get("is_hero", false)):
		emphasis = P1R13_HERO_VISUAL_EMPHASIS
	elif role in ["melee", "defender", "ranged", "flanker", "antiarmor", "caster", "healer"]:
		emphasis = P1R13_MILITARY_VISUAL_EMPHASIS
	elif role == "siege" or bool(def.get("is_siege", false)):
		emphasis = 1.08
	return clampf(configured * emphasis, 1.35, P1R13_VISUAL_HEIGHT_MAX)

func _anim_lib_path() -> String:
	var path: String = def.get("model", "")
	# characters live at assets/characters/<name>/<name>.glb
	var file := path.get_file().get_basename()
	var lib := "res://assets/characters/%s/%s_animations.tres" % [file, file]
	return lib

func _map_anims() -> void:
	if not anim:
		return
	for a in anim.get_animation_list():
		var low := a.to_lower()
		if "idle" in low and not _anim_names.has("idle"):
			_anim_names["idle"] = a
		elif "walk" in low and not _anim_names.has("walk"):
			_anim_names["walk"] = a
		elif ("work" in low or "build" in low or "hammer" in low or "chop" in low or "mine" in low or "gather" in low or "harvest" in low or "dig" in low or "repair" in low) and not _anim_names.has("work"):
			_anim_names["work"] = a
		elif ("attack" in low or "shoot" in low or "punch" in low or "spell" in low) and not _anim_names.has("attack"):
			_anim_names["attack"] = a
		elif "death" in low and not _anim_names.has("death"):
			_anim_names["death"] = a
	if not _anim_names.has("work"):
		# Idle is the least misleading fallback when an imported character has no
		# authored work cycle; never repurpose an attack animation for gathering.
		_anim_names["work"] = _anim_names.get("idle", "")

func _play(key: String, force: bool = false) -> void:
	if not anim:
		return
	var name: String = _anim_names.get(key, "")
	if name == "":
		return
	if _cur_anim == name and not force:
		return
	_cur_anim = name
	anim.play(name)

func _play_sfx(key: String, volume_db: float) -> void:
	var sfx = get_node_or_null("/root/Sfx")
	if sfx and sfx.has_method("play"):
		sfx.play(key, volume_db)

func _add_team_marker() -> void:
	if is_instance_valid(_team_marker):
		return
	# Small role/ownership cue for normal RTS zoom. Presentation only: it does
	# not alter selection, combat, hitboxes, or the unit's gameplay silhouette.
	_team_marker = MeshInstance3D.new()
	_team_marker.name = "TeamPip"
	var pip := CylinderMesh.new()
	var radius := 0.16 if is_worker else (0.20 if is_hero else 0.18)
	pip.top_radius = radius
	pip.bottom_radius = radius
	pip.height = 0.10
	_team_marker.mesh = pip
	_team_marker.position.y = _visual_height + 0.19
	var mat := StandardMaterial3D.new()
	mat.albedo_color = commander.color if commander else Color(0.85, 0.85, 0.85)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_team_marker.material_override = mat
	add_child(_team_marker)

func _build_selection_ring() -> void:
	selection_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	_selection_visual_radius = _measure_selection_visual_radius()
	_selection_indicator_radius = clampf(_selection_visual_radius * (1.25 if is_hero else 1.18), 0.5, 1.15)
	var r: float = _selection_indicator_radius
	torus.inner_radius = r * 0.85
	torus.outer_radius = r
	selection_ring.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.albedo_color = commander.color if commander else Color.WHITE
	mat.emission_enabled = true
	mat.emission = commander.color if commander else Color.WHITE
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	selection_ring.material_override = mat
	selection_ring.position.y = 0.08
	selection_ring.visible = false
	add_child(selection_ring)

func _measure_selection_visual_radius() -> float:
	if is_instance_valid(model_root):
		var measured := ModelUtils.measure_radius(model_root)
		if measured > 0.05:
			return measured
	return 0.45 if not is_hero else 0.55

func get_selection_geometry() -> Dictionary:
	return {
		"entity_type": "hero" if is_hero else "unit",
		"visual_radius": _selection_visual_radius,
		"pick_radius": _selection_pick_radius,
		"indicator_outer_radius": _selection_indicator_radius,
		"indicator_y": selection_ring.position.y if is_instance_valid(selection_ring) else 0.0,
		"selected": selection_ring.visible if is_instance_valid(selection_ring) else false,
		"pick_collision_layer": collision_layer,
		"pick_collision_mask": collision_mask,
		"navigation_radius": agent.radius if is_instance_valid(agent) else -1.0,
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z}
	}

func set_selected(sel: bool) -> void:
	if selection_ring:
		selection_ring.visible = sel
	_update_health_bar()

func _build_health_bar() -> void:
	_health_bar_root = Node3D.new()
	_health_bar_root.name = "CombatHealthBar"
	_health_bar_root.position.y = maxf(_visual_height, ModelUtils.measure_height(model_root)) + 0.45
	add_child(_health_bar_root)
	_health_bar_back = MeshInstance3D.new()
	_health_bar_back.name = "HealthBarBackground"
	var back_mesh := BoxMesh.new()
	back_mesh.size = Vector3(1.25, 0.09, 0.035)
	_health_bar_back.mesh = back_mesh
	var back_mat := StandardMaterial3D.new()
	back_mat.albedo_color = Color(0.03, 0.04, 0.04, 0.9)
	back_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_health_bar_back.material_override = back_mat
	_health_bar_root.add_child(_health_bar_back)
	_health_bar_fill = MeshInstance3D.new()
	_health_bar_fill.name = "HealthBarFill"
	var fill_mesh := BoxMesh.new()
	fill_mesh.size = Vector3(1.15, 0.055, 0.045)
	_health_bar_fill.mesh = fill_mesh
	var fill_mat := StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.25, 0.8, 0.35) if team == 0 else Color(0.85, 0.25, 0.2)
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_health_bar_fill.material_override = fill_mat
	_health_bar_root.add_child(_health_bar_fill)
	_update_health_bar()

func _update_health_bar() -> void:
	if not is_instance_valid(_health_bar_root) or is_dead:
		return
	var ratio := clamp(get_hp_ratio(), 0.0, 1.0)
	var show_bar: bool = ratio < 0.999 or (is_instance_valid(selection_ring) and selection_ring.visible)
	_health_bar_root.visible = show_bar
	if is_instance_valid(_health_bar_fill):
		_health_bar_fill.scale.x = maxf(0.02, ratio)
		_health_bar_fill.position.x = -0.575 * (1.0 - ratio)

func _build_r15_combat_presentation() -> void:
	# Presentation-only cues: no target, damage, timing or combat outcome is
	# authored here. The existing controller and Unit combat path remain owner.
	_r15_attack_cue = MeshInstance3D.new()
	_r15_attack_cue.name = "CombatAttackCue"
	var cue_mesh := TorusMesh.new()
	var cue_radius := clampf(_selection_indicator_radius * 0.92, 0.42, 1.0)
	cue_mesh.inner_radius = cue_radius * 0.86
	cue_mesh.outer_radius = cue_radius
	cue_mesh.rings = 12
	cue_mesh.ring_segments = 6
	_r15_attack_cue.mesh = cue_mesh
	_r15_attack_cue.position.y = 0.12
	_r15_attack_cue.visible = false
	var cue_mat := StandardMaterial3D.new()
	cue_mat.albedo_color = Color(0.96, 0.34, 0.22, 0.88)
	cue_mat.emission_enabled = true
	cue_mat.emission = Color(0.96, 0.20, 0.12)
	cue_mat.emission_energy_multiplier = 1.15
	cue_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_r15_attack_cue.material_override = cue_mat
	add_child(_r15_attack_cue)

	_r15_hit_flash = MeshInstance3D.new()
	_r15_hit_flash.name = "CombatHitFlash"
	var flash_mesh := SphereMesh.new()
	flash_mesh.radius = 0.23
	flash_mesh.height = 0.46
	_r15_hit_flash.mesh = flash_mesh
	_r15_hit_flash.position.y = maxf(0.6, _visual_height * 0.52)
	_r15_hit_flash.visible = false
	var flash_mat := StandardMaterial3D.new()
	flash_mat.albedo_color = Color(1.0, 0.78, 0.36, 0.92)
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(1.0, 0.32, 0.12)
	flash_mat.emission_energy_multiplier = 1.8
	flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_r15_hit_flash.material_override = flash_mat
	add_child(_r15_hit_flash)

func _update_r15_combat_presentation(delta: float) -> void:
	if is_instance_valid(_r15_attack_cue):
		_r15_attack_cue.visible = not is_worker and state == State.ATTACKING and _can_attack_target(_target)
	if _r15_hit_flash_time > 0.0:
		_r15_hit_flash_time = maxf(0.0, _r15_hit_flash_time - delta)
	if is_instance_valid(_r15_hit_flash):
		_r15_hit_flash.visible = _r15_hit_flash_time > 0.0 and not is_dead

func refresh_upgrade_bonuses() -> void:
	if commander:
		_upg_dmg = commander.dmg_bonus
		_upg_armor = commander.armor_bonus

# --------------------------------------------------------------------------
# Stat accessors (with upgrades, veterancy, auras, fortify)
# --------------------------------------------------------------------------
func cur_dmg() -> float:
	var d := base_dmg + _upg_dmg + _aura_bonus_dmg + float(_veterancy) * 2.0
	if hero_flags.get("execute", false) and is_instance_valid(_target) and _target.has_method("get_hp_ratio"):
		if _target.get_hp_ratio() < 0.3:
			d *= 1.5
	return d

func cur_armor() -> float:
	var a := base_armor + _upg_armor + _aura_bonus_armor + float(_veterancy) * 0.5
	# Barrosan fortify: bonus near own HQ
	if commander and commander.race == "barrosan":
		if world and world.near_friendly_hq(global_position, team, 22.0):
			a += 3.0 if not commander.build_flags.get("fortify_boost", false) else 6.0
	return a

func get_hp_ratio() -> float:
	return hp / max_hp if max_hp > 0 else 0.0

# --------------------------------------------------------------------------
# Commands
# --------------------------------------------------------------------------
func command_move(pos: Vector3, attack_move: bool = false, queue: bool = false, r1j_order_id: String = "") -> void:
	if is_dead:
		return
	var before_state := state
	var before_target = _target
	_carry_hold = _carry > 0
	_hold_position = false
	_v0436_r1j_set_target(null, "public_order")
	_gather_node = null
	_pending_gather_node = null
	_build_target = null
	_follow_target = null
	_move_target = pos
	_attack_move_ordered = attack_move
	_attack_move_destination = pos if attack_move else Vector3.ZERO
	_set_agent_target(pos, "attack_move" if attack_move else "move")
	state = State.ATTACK_MOVE if attack_move else State.MOVING
	var recorder = _v0436_r1j_recorder()
	if recorder:
		recorder.record_unit_command(self, r1j_order_id, "attack_move" if attack_move else "move", before_state, state, before_target, _target, pos)

func command_stop() -> void:
	if is_dead: return
	var before_state := state
	var before_target = _target
	_carry_hold = _carry > 0
	_v0436_r1j_set_target(null, "command_cancellation")
	_gather_node = null
	_pending_gather_node = null
	_build_target = null
	_follow_target = null
	_attack_move_ordered = false
	_attack_move_destination = Vector3.ZERO
	state = State.IDLE
	velocity = Vector3.ZERO
	_boundary_recovery_active = false
	_navigation_invalid_consecutive = 0
	if agent: agent.set_velocity(Vector3.ZERO)
	var recorder = _v0436_r1j_recorder()
	if recorder:
		recorder.record_unit_command(self, "", "stop", before_state, state, before_target, _target, Vector3.ZERO)

func command_hold() -> void:
	if is_dead: return
	command_stop()
	_hold_position = true
	state = State.HOLD

func command_attack(tgt, r1j_order_id: String = "") -> void:
	if not _can_attack_target(tgt):
		return
	var before_state := state
	var before_target = _target
	_hold_position = false
	_gather_node = null
	_build_target = null
	_attack_move_ordered = false
	_attack_move_destination = Vector3.ZERO
	_v0436_r1j_set_target(tgt, "public_order" if r1j_order_id != "" else "auto_acquisition")
	state = State.ATTACKING
	var recorder = _v0436_r1j_recorder()
	if recorder:
		recorder.record_unit_command(self, r1j_order_id, "attack_target" if r1j_order_id != "" else "auto_attack", before_state, state, before_target, _target, tgt.global_position)

func _can_attack_target(tgt) -> bool:
	if is_dead or not is_instance_valid(tgt) or tgt == self:
		return false
	if not (tgt is Unit or tgt is Building):
		return false
	if not ("team" in tgt) or not ("is_dead" in tgt) or tgt.is_dead:
		return false
	if int(tgt.team) == team:
		return false
	if tgt is Building and not tgt.is_built:
		return false
	return tgt.has_method("take_damage") and tgt.has_method("get_hp_ratio")

func command_patrol(pos: Vector3) -> void:
	if is_dead: return
	_attack_move_ordered = false
	_attack_move_destination = Vector3.ZERO
	_patrol_a = global_position
	_patrol_b = pos
	state = State.PATROL
	_set_agent_target(_patrol_b, "patrol")

func command_guard(tgt) -> void:
	if is_dead or not is_instance_valid(tgt): return
	_attack_move_ordered = false
	_attack_move_destination = Vector3.ZERO
	_follow_target = tgt
	state = State.FOLLOW

func command_gather(node) -> void:
	if is_dead or not is_worker or not is_instance_valid(node) or not (node is ResourceNode):
		if world and world.has_method("record_resource_command_rejection"):
			world.record_resource_command_rejection(self, node, "not_a_live_resource_node")
		return
	if node.depleted or (world and world.has_method("is_resource_command_valid") and not world.is_resource_command_valid(node, self)):
		if world and world.has_method("record_resource_command_rejection"):
			world.record_resource_command_rejection(self, node, "depleted_or_unreachable")
		return
	_hold_position = false
	_v0436_r1j_set_target(null, "command_cancellation")
	_build_target = null
	_attack_move_ordered = false
	_attack_move_destination = Vector3.ZERO
	_carry_hold = false
	_desired_gather_kind = node.resource_kind
	_gather_timer = 0.0
	_dropoff_retry = 0.0
	if _carry > 0 and _carry_kind != node.resource_kind:
		_pending_gather_node = node
		_gather_node = null
		state = State.RETURNING
		return
	_pending_gather_node = null
	_gather_node = node
	if _carry >= CARRY_MAX:
		state = State.RETURNING
		return
	state = State.GATHERING

func command_build(building) -> void:
	if is_dead or not is_worker or not is_instance_valid(building):
		return
	_attack_move_ordered = false
	_attack_move_destination = Vector3.ZERO
	_hold_position = false
	_v0436_r1j_set_target(null, "public_order")
	_gather_node = null
	_build_target = building
	state = State.BUILDING

func _set_agent_target(pos: Vector3, command_type: String = "") -> void:
	_requested_move_target = pos
	if command_type != "":
		_navigation_command_type = command_type
	var snapshot := {"ready": true, "projected": pos, "projection_distance": 0.0, "reason": "local"}
	if world and world.has_method("navigation_target_snapshot"):
		snapshot = world.navigation_target_snapshot(pos)
	_navigation_target_pending = not bool(snapshot.get("ready", false))
	_navigation_target_projection_distance = float(snapshot.get("projection_distance", 0.0))
	if _navigation_target_pending:
		_navigation_path_wait_frames = 0
		if not _navigation_last_target_ready:
			_record_navigation_event("navigation_target_deferred", {"reason": snapshot.get("reason", "navigation_map_not_ready")})
		_navigation_last_target_ready = false
		return
	var effective: Vector3 = snapshot.get("projected", pos)
	var changed := not _navigation_last_target_ready or _navigation_last_target.distance_to(effective) > 0.05
	_navigation_effective_target = effective
	_navigation_last_target = effective
	_navigation_last_target_ready = true
	_navigation_terminal_failure_recorded = false
	if agent and changed:
		agent.target_position = effective
		_navigation_path_wait_frames = 0
		_navigation_retry_elapsed = 0.0
		_navigation_repath_cooldown = 0.0

func _record_navigation_event(kind: String, details: Dictionary = {}) -> void:
	var event := {"kind": kind, "timestamp": Time.get_ticks_msec(), "unit_id": unit_id, "runtime_id": str(get_instance_id()), "command": _navigation_command_type, "state": int(state), "position": {"x": global_position.x, "y": global_position.y, "z": global_position.z}, "requested_target": {"x": _requested_move_target.x, "y": _requested_move_target.y, "z": _requested_move_target.z}, "effective_target": {"x": _navigation_effective_target.x, "y": _navigation_effective_target.y, "z": _navigation_effective_target.z}}
	for key in details:
		event[key] = details[key]
	_navigation_audit_events.append(event)
	if _navigation_audit_events.size() > 120:
		_navigation_audit_events.pop_front()

func _navigation_terminal_stop(reason: String) -> void:
	if _navigation_terminal_failure_recorded:
		return
	_navigation_terminal_failure_recorded = true
	_navigation_failure_count += 1
	_record_navigation_event("navigation_terminal_failure", {
		"reason": reason,
		"command_preserved_during_retry": true,
		"retry_count": _navigation_repath_attempts,
		"retry_elapsed": _navigation_retry_elapsed,
		"map_ready": world.is_navigation_ready() if world and world.has_method("is_navigation_ready") else false,
	})
	# A terminal failure is the one deliberate place where the owning state is
	# released. Transient failures never call command_stop and therefore retain
	# build/gather/return/attack-move/pursuit context through the retry budget.
	command_stop()

func _finite_position(pos: Vector3) -> bool:
	return abs(pos.x) < 1000000.0 and abs(pos.y) < 1000000.0 and abs(pos.z) < 1000000.0 and pos.x == pos.x and pos.y == pos.y and pos.z == pos.z

func _v0436_r1f_audit_enabled() -> bool:
	return bool(get_meta("v0436_boundary_fixture", false)) or OS.get_environment("ASCENDANT_V0436_R1F_BOUNDARY_AUDIT") == "1"

func _v0436_r1f_vec(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _v0436_r1f_note_move(frame: int) -> int:
	if _v0436_r1f_last_move_frame != frame:
		_v0436_r1f_last_move_frame = frame
		_v0436_r1f_move_count = 0
	_v0436_r1f_move_count += 1
	return _v0436_r1f_move_count

func _v0436_r1f_record(entry: Dictionary) -> void:
	if not _v0436_r1f_audit_enabled():
		return
	_v0436_r1f_physics_audit.append(entry)
	if _v0436_r1f_physics_audit.size() > V0436_R1F_AUDIT_CAP:
		_v0436_r1f_physics_audit.pop_front()

func v0436_r1f_physics_audit_snapshot() -> Array:
	return _v0436_r1f_physics_audit.duplicate(true)

func _v0436_r1f_record_callback(frame: int, safe_vel: Vector3, before: Vector3, after: Vector3, called_move: bool, recovery_already_moved: bool) -> void:
	_v0436_r1f_record({
		"kind": "avoidance_callback",
		"physics_frame": frame,
		"wall_timestamp_ms": Time.get_ticks_msec(),
		"physics_delta": get_physics_process_delta_time(),
		"time_scale": Engine.time_scale,
		"physics_ticks_per_second": Engine.physics_ticks_per_second,
		"safe_velocity": _v0436_r1f_vec(safe_vel),
		"position_before": _v0436_r1f_vec(before),
		"position_after": _v0436_r1f_vec(after),
		"called_move_and_slide": called_move,
		"displacement": before.distance_to(after),
		"recovery_already_moved": recovery_already_moved,
		"movement_applications_same_frame": _v0436_r1f_move_count if _v0436_r1f_last_move_frame == frame else 0,
	})

func _inside_playable(pos: Vector3, tolerance: float = 0.0) -> bool:
	return not world or not world.has_method("is_inside_playable_bounds") or world.is_inside_playable_bounds(pos, tolerance)

func _begin_boundary_recovery(reason: String) -> void:
	if is_dead or (world and not world.game_running):
		return
	if not _boundary_recovery_active:
		_boundary_resume_state = state
		_boundary_recovery_active = true
		_boundary_recovery_reason = reason
		_boundary_recovery_target = world.nearest_safe_in_bounds_recovery_point(global_position) if world and world.has_method("nearest_safe_in_bounds_recovery_point") else Vector3(clampf(global_position.x, -136.0, 136.0), 0.0, clampf(global_position.z, -136.0, 136.0))
		_boundary_recovery_distance_last = world.distance_outside_playable_bounds(global_position) if world and world.has_method("distance_outside_playable_bounds") else 0.0
		_navigation_invalid_consecutive = 0
		_record_navigation_event("boundary_recovery_started", {"reason": reason, "recovery_target": {"x": _boundary_recovery_target.x, "y": _boundary_recovery_target.y, "z": _boundary_recovery_target.z}})

func _state_boundary_recovery(delta: float) -> void:
	if is_dead or (world and not world.game_running):
		velocity = Vector3.ZERO
		return
	if _inside_playable(global_position, 0.0):
		_boundary_recovery_active = false
		velocity = Vector3.ZERO
		_navigation_invalid_consecutive = 0
		_record_navigation_event("boundary_recovery_completed", {"reason": _boundary_recovery_reason})
		_boundary_recovery_reason = ""
		if _boundary_resume_state == State.ATTACKING and (not is_instance_valid(_target) or _target.is_dead or not _inside_playable(_target.global_position, world.playable_recovery_tolerance)):
			state = State.IDLE
		elif _boundary_resume_state == State.BUILDING and (not is_instance_valid(_build_target) or _build_target.is_dead or not _inside_playable(_build_target.global_position, world.playable_recovery_tolerance)):
			state = State.IDLE
		else:
			state = _boundary_resume_state
		_set_agent_target(_requested_move_target, _navigation_command_type)
		return
	var to_safe := _boundary_recovery_target - global_position
	to_safe.y = 0.0
	var distance := to_safe.length()
	if world and world.has_method("distance_outside_playable_bounds"):
		var remaining: float = float(world.distance_outside_playable_bounds(global_position))
		if remaining > _boundary_recovery_distance_last + 0.05:
			_record_navigation_event("boundary_recovery_distance_increased", {"previous": _boundary_recovery_distance_last, "current": remaining})
		_boundary_recovery_distance_last = remaining
	var recovery_speed := move_speed
	if _slow > 0.0: recovery_speed *= 0.5
	var direction := to_safe.normalized()
	var audit_enabled := _v0436_r1f_audit_enabled()
	var audit_frame := Engine.get_physics_frames()
	var position_before := global_position
	var velocity_before := velocity
	var outside_before: float = float(world.distance_outside_playable_bounds(position_before)) if world and world.has_method("distance_outside_playable_bounds") else 0.0
	velocity = direction * recovery_speed
	velocity.y = 0.0
	move_and_slide()
	if audit_enabled:
		_v0436_r1f_last_recovery_move_frame = audit_frame
		var movement_count := _v0436_r1f_note_move(audit_frame)
		var position_after := global_position
		var outside_after: float = float(world.distance_outside_playable_bounds(position_after)) if world and world.has_method("distance_outside_playable_bounds") else 0.0
		var physics_delta := maxf(delta, 0.000001)
		_v0436_r1f_record({
			"kind": "recovery_step",
			"physics_frame": audit_frame,
			"wall_timestamp_ms": Time.get_ticks_msec(),
			"physics_delta": delta,
			"time_scale": Engine.time_scale,
			"physics_ticks_per_second": Engine.physics_ticks_per_second,
			"position_before": _v0436_r1f_vec(position_before),
			"position_after": _v0436_r1f_vec(position_after),
			"displacement": position_before.distance_to(position_after),
			"requested_recovery_speed": recovery_speed,
			"simulation_speed": position_before.distance_to(position_after) / physics_delta,
			"velocity_before": _v0436_r1f_vec(velocity_before),
			"velocity_after": _v0436_r1f_vec(velocity),
			"recovery_target": _v0436_r1f_vec(_boundary_recovery_target),
			"distance_outside_before": outside_before,
			"distance_outside_after": outside_after,
			"movement_applications_same_frame": movement_count,
		})
	_face(global_position + direction)
	_play("walk")

# --------------------------------------------------------------------------
# Main loop
# --------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	var r1j_recorder = _v0436_r1j_recorder()
	if r1j_recorder:
		r1j_recorder.record_unit_sample(self)
	if world and not world.game_running:
		velocity = Vector3.ZERO
		return
	if is_dead:
		if is_instance_valid(_health_bar_root):
			_health_bar_root.visible = false
		return
	_update_r15_combat_presentation(delta)
	set_meta("v0436_max_abs_x", maxf(abs(global_position.x), float(get_meta("v0436_max_abs_x", 0.0))))
	set_meta("v0436_max_abs_z", maxf(abs(global_position.z), float(get_meta("v0436_max_abs_z", 0.0))))
	if world and world.has_method("is_inside_playable_bounds") and not world.is_inside_playable_bounds(global_position, world.playable_recovery_tolerance) and not _boundary_recovery_active:
		_begin_boundary_recovery("position_outside_playable_tolerance")
	if _boundary_recovery_active:
		_state_boundary_recovery(delta)
		return
	_update_health_bar()
	# timers
	if _attack_timer > 0.0: _attack_timer -= delta
	if _stun > 0.0:
		_stun -= delta
		velocity = Vector3.ZERO
		move_and_slide()
		return
	if _rooted > 0.0: _rooted -= delta
	if _slow > 0.0: _slow -= delta

	# regen / mana
	if regen > 0.0 and hp < max_hp:
		hp = min(max_hp, hp + regen * delta)
	if is_hero and max_mana > 0.0:
		mana = min(max_mana, mana + mana_regen * delta)
		for id in ability_cd:
			if ability_cd[id] > 0.0:
				ability_cd[id] -= delta
	if not is_hero and heal_power > 0.0:
		_healer_tick(delta)

	# Flat-ground RTS: units are navmesh-driven and carry no ground collision
	# (unit avoidance handles spacing), so physics gravity has no floor to stop
	# it and would sink every unit through the terrain. Keep them planted on the
	# battlefield at ground height instead.
	velocity.y = 0.0
	if global_position.y != 0.0:
		global_position.y = 0.0

	match state:
		State.IDLE, State.HOLD:
			_state_idle(delta)
		State.MOVING:
			_state_move(delta, false)
		State.ATTACK_MOVE:
			_state_move(delta, true)
		State.ATTACKING:
			_state_attack(delta)
		State.GATHERING:
			_state_gather(delta)
		State.RETURNING:
			_state_return(delta)
		State.BUILDING:
			_state_build(delta)
		State.PATROL:
			_state_patrol(delta)
		State.FOLLOW:
			_state_follow(delta)

func _state_idle(delta: float) -> void:
	velocity.x = 0
	velocity.z = 0
	move_and_slide()
	_play("idle")
	if is_worker and _carry > 0 and not _carry_hold:
		if _dropoff_retry > 0.0:
			_dropoff_retry -= delta
		else:
			state = State.RETURNING
		return
	# auto-acquire nearby enemies if not holding fire and not worker
	if not is_worker or is_hero:
		var e = world.find_enemy_in_range(self, vision) if world else null
		if e and not _hold_position:
			command_attack(e)
		elif e and _hold_position:
			# hold: attack only if within attack range
			if global_position.distance_to(e.global_position) <= _engage_range() + 1.0:
				_v0436_r1j_set_target(e, "threat_response")
				state = State.ATTACKING

func _state_move(delta: float, attack_move: bool) -> void:
	if attack_move and _attack_move_ordered:
		var e = world.find_enemy_in_range(self, vision * 0.7) if world else null
		if e and _can_attack_target(e):
			_v0436_r1j_set_target(e, "auto_acquisition")
			state = State.ATTACKING
			return
	if _move_along_path(delta):
		_attack_move_ordered = false
		_attack_move_destination = Vector3.ZERO
		state = State.IDLE

func _state_patrol(delta: float) -> void:
	var e = world.find_enemy_in_range(self, vision * 0.7) if world else null
	if e:
		_v0436_r1j_set_target(e, "auto_acquisition")
		state = State.ATTACKING
		return
	if _move_along_path(delta):
		var tmp := _patrol_a
		_patrol_a = _patrol_b
		_patrol_b = tmp
		_set_agent_target(_patrol_b, "patrol")

func _state_follow(delta: float) -> void:
	if not is_instance_valid(_follow_target) or _follow_target.is_dead:
		state = State.IDLE
		return
	var e = world.find_enemy_in_range(self, vision * 0.6) if world else null
	if e:
		_v0436_r1j_set_target(e, "threat_response")
		state = State.ATTACKING
		return
	var d := global_position.distance_to(_follow_target.global_position)
	if d > 5.0:
		_set_agent_target(_follow_target.global_position, "follow")
		_move_along_path(delta)
	else:
		velocity.x = 0; velocity.z = 0
		move_and_slide()
		_play("idle")

func _engage_range() -> float:
	return atk_range if atk_range > 0.0 else 1.6

func _state_attack(delta: float) -> void:
	if not _can_attack_target(_target):
		var invalid_reason := "target_dead" if is_instance_valid(_target) and _target.is_dead else "target_invalid"
		_v0436_r1j_set_target(null, invalid_reason)
		# after kill, look for next enemy nearby
		var e = world.find_enemy_in_range(self, vision) if world else null
		if e and not _hold_position and _can_attack_target(e):
			_v0436_r1j_set_target(e, "fallback_target")
		elif _attack_move_ordered:
			_move_target = _attack_move_destination
			_set_agent_target(_attack_move_destination, "attack_move")
			state = State.ATTACK_MOVE
		else:
			state = State.HOLD if _hold_position else State.IDLE
		return
	var d := global_position.distance_to(_target.global_position)
	var er := _engage_range()
	if d > er:
		if _hold_position:
			# don't chase far when holding
			if d > er + 4.0:
				_v0436_r1j_set_target(null, "target_out_of_acquisition_rules")
				state = State.HOLD
				return
		_move_target = _target.global_position
		_set_agent_target(_move_target, "attack")
		_move_along_path(delta)
	else:
		# in range: face + attack
		velocity.x = 0; velocity.z = 0
		move_and_slide()
		_face(_target.global_position)
		if _attack_timer <= 0.0:
			_do_attack()

func _do_attack() -> void:
	_attack_timer = attack_cd
	_play("attack", true)
	var r1j_recorder = _v0436_r1j_recorder()
	var attack_event_id := ""
	if r1j_recorder:
		attack_event_id = r1j_recorder.record_attack_start(self, _target, cur_dmg(), dmg_type, _engage_range(), global_position.distance_to(_target.global_position), state, _navigation_command_type)
	if atk_range > 0.0 and def.has("projectile"):
		_spawn_projectile(attack_event_id)
		_play_sfx("arrow" if dmg_type == "pierce" else "spell", -8.0)
	else:
		# melee: apply after small delay
		_play_sfx("sword", -8.0)
		var tgt = _target
		get_tree().create_timer(0.25).timeout.connect(func():
			if not is_dead and _can_attack_target(tgt) and global_position.distance_to(tgt.global_position) <= _engage_range() + 0.15:
				if r1j_recorder:
					r1j_recorder.record_attack_phase(attack_event_id, "windup_completed", {"target_valid":true, "distance":global_position.distance_to(tgt.global_position)})
				var dealt = _resolve_damage(tgt, cur_dmg(), attack_event_id)
				_on_dealt_damage(dealt, tgt)
				if r1j_recorder:
					r1j_recorder.record_attack_phase(attack_event_id, "melee_resolution", {"applied_damage":dealt})
				if splash > 0.0:
					world.apply_splash(tgt.global_position, splash, cur_dmg() * 0.5, dmg_type, team, tgt, self, "melee")
		)

func _spawn_projectile(attack_event_id: String = "") -> void:
	if not world:
		return
	var muzzle := global_position + Vector3.UP * 1.2
	world.spawn_projectile(muzzle, _target, cur_dmg(), dmg_type, team,
		def.get("projectile", "arrow"), splash, self, attack_event_id)

func _on_dealt_damage(dealt: float, tgt) -> void:
	# lifesteal
	if hero_flags.get("lifesteal", 0.0) > 0.0:
		hp = min(max_hp, hp + dealt * float(hero_flags["lifesteal"]))

func _resolve_damage(tgt, raw: float, attack_event_id: String = "", projectile_event_id: String = "") -> float:
	if not _can_attack_target(tgt):
		return 0.0
	var ac: String = tgt.armor_class if "armor_class" in tgt else "medium"
	var ar: float = tgt.cur_armor() if tgt.has_method("cur_armor") else 0.0
	var dmg := GameData.compute_damage(raw, dmg_type, ac, ar)
	var r1j_recorder = _v0436_r1j_recorder()
	if r1j_recorder and attack_event_id != "":
		tgt.take_damage(dmg, {"source_unit":self, "source_team":team, "source_unit_id":unit_id, "source_runtime_id":str(get_instance_id()), "projectile_kind":"melee", "damage_type":dmg_type, "raw_damage":raw, "armor_class":ac, "flat_armor":ar, "multiplier":GameData.damage_multiplier(dmg_type, ac), "calculated_damage_before_clamp":raw * GameData.damage_multiplier(dmg_type, ac) - maxf(0.0, ar) * 0.5, "expected_applied_damage":dmg, "attack_event_id":attack_event_id, "projectile_event_id":projectile_event_id})
	else:
		tgt.take_damage(dmg, self)
	return dmg

# --- worker: gathering ----------------------------------------------------
func _state_gather(delta: float) -> void:
	if _carry >= CARRY_MAX:
		state = State.RETURNING
		return
	if not is_instance_valid(_gather_node) or _gather_node.depleted:
		# Retarget only the requested resource kind; never silently switch kinds.
		var n = world.find_nearest_resource_exact(global_position, _desired_gather_kind) if world and world.has_method("find_nearest_resource_exact") else null
		if n:
			_gather_node = n
		else:
			state = State.RETURNING if _carry > 0 else State.IDLE
			return
	var d := global_position.distance_to(_gather_node.global_position)
	if d > 2.2:
		_move_target = _gather_node.global_position
		_set_agent_target(_move_target, "gather")
		_move_along_path(delta)
	else:
		_hold_worker_interaction(_gather_node.global_position)
		_play("work")
		_gather_timer += delta
		if _gather_timer >= 1.0:
			_gather_timer = 0.0
			var remaining_capacity := CARRY_MAX - _carry
			if remaining_capacity <= 0:
				state = State.RETURNING
				return
			var before_amount: int = _gather_node.amount
			var got: int = _gather_node.extract(min(3, remaining_capacity))
			if got > 0:
				_carry_kind = _gather_node.resource_kind
				_carry += got
				_last_source_node_id = str(_gather_node.get_instance_id())
				_last_source_amount_before = before_amount
				_last_source_amount_after = _gather_node.amount
				if world and world.has_method("record_resource_extraction"):
					world.record_resource_extraction(self, _gather_node, before_amount, _gather_node.amount, got)
			if _carry >= CARRY_MAX or _gather_node.depleted:
				state = State.RETURNING
			elif got == 0:
				state = State.RETURNING if _carry > 0 else State.IDLE

func _state_return(delta: float) -> void:
	var drop = world.find_nearest_dropoff(global_position, team) if world else null
	if not is_instance_valid(drop):
		_dropoff_retry = 2.0
		_carry_hold = false
		state = State.IDLE
		return
	var d := global_position.distance_to(drop.global_position)
	if d > (float(drop.def.get("footprint", 4.0)) + 1.0):
		_move_target = drop.global_position
		_set_agent_target(_move_target, "return")
		_move_along_path(delta)
	else:
		if _carry > 0 and commander:
			var carried_before := _carry
			var kind_before := _carry_kind
			var multiplier: float = commander.gather_mult()
			var bank_before: Dictionary = commander.resources.duplicate()
			var deposited := int(round(carried_before * multiplier))
			commander.add_resources(kind_before, deposited)
			_last_deposit_sequence += 1
			if world and world.has_method("record_resource_deposit"):
				world.record_resource_deposit(self, drop, kind_before, carried_before, multiplier, deposited, bank_before, commander.resources.duplicate())
			_carry = 0
			_carry_kind = ""
		_carry_hold = false
		_dropoff_retry = 0.0
		if is_instance_valid(_pending_gather_node) and not _pending_gather_node.depleted:
			_gather_node = _pending_gather_node
			_pending_gather_node = null
			_desired_gather_kind = _gather_node.resource_kind
			state = State.GATHERING
		elif is_instance_valid(_gather_node) and not _gather_node.depleted:
			state = State.GATHERING
		else:
			var next = world.find_nearest_resource_exact(global_position, _desired_gather_kind) if world and world.has_method("find_nearest_resource_exact") else null
			if next:
				_gather_node = next
				state = State.GATHERING
			else:
				state = State.IDLE

func get_economy_snapshot() -> Dictionary:
	var activity := "Idle"
	match state:
		State.GATHERING: activity = "Gathering"
		State.RETURNING: activity = "Returning"
		State.MOVING: activity = "Moving"
		State.BUILDING: activity = "Building"
		State.HOLD: activity = "Holding"
	var target_kind := _desired_gather_kind.capitalize() if _desired_gather_kind != "" else ""
	var target_text := target_kind
	if is_instance_valid(_gather_node):
		target_text = _gather_node.resource_kind.capitalize()
	elif is_instance_valid(_pending_gather_node):
		target_text = _pending_gather_node.resource_kind.capitalize()
	return {
		"activity": activity,
		"carry_kind": _carry_kind.capitalize() if _carry_kind != "" else "None",
		"carry": _carry,
		"capacity": CARRY_MAX,
		"target": target_text if target_text != "" else "None",
		"pending_target": _pending_gather_node.resource_kind.capitalize() if is_instance_valid(_pending_gather_node) else "",
		"source_node_id": _last_source_node_id,
		"source_before": _last_source_amount_before,
		"source_after": _last_source_amount_after,
		"deposit_sequence": _last_deposit_sequence,
	}

func get_economy_text() -> String:
	var s: Dictionary = get_economy_snapshot()
	var carry_text := "%s %d / %d" % [s["carry_kind"], s["carry"], s["capacity"]] if int(s["carry"]) > 0 else "Empty"
	var line := "%s   Carry: %s" % [s["activity"], carry_text]
	if s["pending_target"] != "":
		line += "   Next: %s" % s["pending_target"]
	elif s["target"] != "None":
		line += "   Target: %s" % s["target"]
	return line

# --- worker: building -----------------------------------------------------
func _state_build(delta: float) -> void:
	if not is_instance_valid(_build_target) or _build_target.is_dead:
		_build_target = null
		state = State.IDLE
		return
	if _build_target.is_built:
		_build_target = null
		state = State.IDLE
		return
	var reach: float = float(_build_target.def.get("footprint", 4.0)) + 1.2
	var d := global_position.distance_to(_build_target.global_position)
	if d > reach:
		_move_target = _build_target.global_position
		_set_agent_target(_move_target, "build")
		_move_along_path(delta)
	else:
		_hold_worker_interaction(_build_target.global_position)
		_play("work")
		_build_target.add_build_progress(delta, self)

func _hold_worker_interaction(target_position: Vector3) -> void:
	# Once a worker reaches its work radius, cancel the stale navigation target
	# and hold the body in place. Without this visual-only settling boundary,
	# NavigationAgent3D can keep returning tiny corrections and the worker
	# visibly slides/oscillates while gathering or building.
	velocity.x = 0.0
	velocity.z = 0.0
	_move_target = global_position
	_navigation_effective_target = global_position
	_navigation_target_pending = false
	_navigation_path_wait_frames = 0
	_navigation_retry_elapsed = 0.0
	if agent:
		agent.target_position = global_position
		agent.set_velocity(Vector3.ZERO)
	move_and_slide()
	_face(target_position)

# --- healer support unit --------------------------------------------------
func _healer_tick(delta: float) -> void:
	# handled inside attack/idle by targeting wounded allies
	if state == State.IDLE or state == State.HOLD:
		var ally = world.find_wounded_ally(self, float(def.get("heal_range", 12.0))) if world else null
		if ally:
			_face(ally.global_position)
			if _attack_timer <= 0.0:
				_attack_timer = float(def.get("heal_cd", 1.2))
				ally.heal(float(def.get("heal", 12.0)))
				world.spawn_heal_fx(ally.global_position)

# --------------------------------------------------------------------------
# Movement helpers
# --------------------------------------------------------------------------
func _move_along_path(delta: float) -> bool:
	if not agent:
		return true
	if world and world.has_method("is_navigation_ready") and not world.is_navigation_ready():
		_navigation_target_pending = true
		_navigation_path_wait_frames = 0
		velocity = Vector3.ZERO
		return false
	if _navigation_target_pending:
		velocity = Vector3.ZERO
		return false
	_navigation_repath_cooldown = maxf(0.0, _navigation_repath_cooldown - delta)
	if agent.is_navigation_finished():
		if global_position.distance_to(_navigation_effective_target) > ARRIVE_DIST:
			_navigation_path_wait_frames += 1
			# NavigationAgent3D can report finished for a frame while its map
			# synchronization/path query is still pending. Do not turn that
			# transient state into a command failure.
			if _navigation_path_wait_frames <= 8:
				velocity = Vector3.ZERO
				return false
			_navigation_retry_elapsed += delta
			if _navigation_retry_elapsed >= NAVIGATION_RETRY_BUDGET:
				_navigation_terminal_stop("navigation_finished_before_target_retry_budget_exhausted")
				return false
			_navigation_invalid_count += 1
			_navigation_invalid_consecutive += 1
			_navigation_last_invalid_reason = "navigation_finished_before_effective_target"
			_record_navigation_event("invalid_next_path_point", {"reason": _navigation_last_invalid_reason, "invalid_consecutive": _navigation_invalid_consecutive})
			velocity = Vector3.ZERO
			if agent:
				agent.set_velocity(Vector3.ZERO)
			if _navigation_repath_cooldown <= 0.0:
				_navigation_repath_attempts += 1
				_navigation_repath_cooldown = NAVIGATION_REPATH_INTERVAL
				_navigation_path_wait_frames = 0
				if agent:
					agent.target_position = _navigation_effective_target
			return false
		velocity.x = 0; velocity.z = 0
		move_and_slide()
		_play("idle")
		return true
	var next := agent.get_next_path_position()
	# NavigationAgent output is advisory. The command destination remains
	# authoritative, but an invalid next point triggers bounded repath and a
	# safe stop rather than unrestricted straight-line movement.
	var invalid_reason := ""
	if not _finite_position(next):
		invalid_reason = "non_finite_next_path_point"
	elif world and not world.is_inside_playable_bounds(next, world.playable_recovery_tolerance):
		invalid_reason = "next_path_point_outside_playable_bounds"
	# A flat production region legitimately returns a direct long segment for
	# distant targets. Fixed-distance waypoint guards misclassified that valid
	# path as unusable and stopped attack/pursuit orders. The map projection and
	# finite/in-bounds checks above are the authoritative safety boundary here.
	if invalid_reason != "":
		_navigation_retry_elapsed += delta
		_navigation_invalid_count += 1
		_navigation_invalid_consecutive += 1
		_navigation_last_invalid_reason = invalid_reason
		_record_navigation_event("invalid_next_path_point", {"reason": invalid_reason, "invalid_consecutive": _navigation_invalid_consecutive, "next": {"x": next.x, "y": next.y, "z": next.z}})
		velocity = Vector3.ZERO
		if agent:
			agent.set_velocity(Vector3.ZERO)
		if world and not world.is_inside_playable_bounds(global_position, world.playable_recovery_tolerance):
			_begin_boundary_recovery("invalid_next_path_point_while_outside")
		elif _navigation_retry_elapsed >= NAVIGATION_RETRY_BUDGET:
			_navigation_terminal_stop("invalid_next_path_point_retry_budget_exhausted")
		elif _navigation_repath_cooldown <= 0.0:
			_navigation_repath_attempts += 1
			_navigation_repath_cooldown = NAVIGATION_REPATH_INTERVAL
			if agent:
				agent.target_position = _navigation_effective_target
		return false
	_navigation_invalid_consecutive = 0
	_navigation_retry_elapsed = 0.0
	_navigation_repath_cooldown = 0.0
	var dir := (next - global_position)
	dir.y = 0
	if dir.length() < 0.05:
		return false
	dir = dir.normalized()
	var spd := move_speed
	if _slow > 0.0: spd *= 0.5
	if _rooted > 0.0: spd = 0.0
	var desired := dir * spd
	if agent.avoidance_enabled:
		agent.set_velocity(desired)
	else:
		velocity.x = desired.x
		velocity.z = desired.z
		move_and_slide()
	if desired.length() > 0.1:
		_face(global_position + dir)
		_play("walk")
	return false

func _on_velocity_computed(safe_vel: Vector3) -> void:
	var audit_enabled := _v0436_r1f_audit_enabled()
	var audit_frame := Engine.get_physics_frames()
	var callback_position_before := global_position
	var recovery_already_moved := _v0436_r1f_last_recovery_move_frame == audit_frame
	if state == State.IDLE or state == State.HOLD or state == State.DEAD:
		velocity = Vector3.ZERO
		if audit_enabled and (_boundary_recovery_active or recovery_already_moved):
			_v0436_r1f_record_callback(audit_frame, safe_vel, callback_position_before, global_position, false, recovery_already_moved)
		return
	var invalid_reason := ""
	if not _finite_position(safe_vel):
		invalid_reason = "non_finite_avoidance_velocity"
	elif safe_vel.length() > move_speed * 1.1 + 0.25:
		invalid_reason = "avoidance_velocity_exceeds_unit_speed"
	else:
		var predicted := global_position + safe_vel * get_physics_process_delta_time()
		if world and _boundary_recovery_active and world.distance_outside_playable_bounds(predicted) > world.distance_outside_playable_bounds(global_position) + 0.05:
			invalid_reason = "avoidance_velocity_increases_recovery_distance"
		elif world and not _boundary_recovery_active and not world.is_inside_playable_bounds(predicted, world.playable_recovery_tolerance):
			invalid_reason = "avoidance_velocity_predicts_out_of_bounds"
	if invalid_reason != "":
		_navigation_retry_elapsed += get_physics_process_delta_time()
		_navigation_rejected_velocity_count += 1
		_navigation_invalid_consecutive += 1
		_record_navigation_event("rejected_avoidance_velocity", {"reason": invalid_reason, "velocity": {"x": safe_vel.x, "y": safe_vel.y, "z": safe_vel.z}, "rejected_velocity_count": _navigation_rejected_velocity_count})
		velocity = Vector3.ZERO
		if agent:
			agent.set_velocity(Vector3.ZERO)
		if world and not world.is_inside_playable_bounds(global_position, world.playable_recovery_tolerance):
			_begin_boundary_recovery("rejected_avoidance_velocity_while_outside")
		elif _navigation_retry_elapsed >= NAVIGATION_RETRY_BUDGET:
			_navigation_terminal_stop("rejected_avoidance_velocity_retry_budget_exhausted")
		elif agent and _navigation_repath_cooldown <= 0.0:
			_navigation_repath_attempts += 1
			_navigation_repath_cooldown = NAVIGATION_REPATH_INTERVAL
			agent.target_position = _navigation_effective_target
		if audit_enabled and (_boundary_recovery_active or recovery_already_moved):
			_v0436_r1f_record_callback(audit_frame, safe_vel, callback_position_before, global_position, false, recovery_already_moved)
		return
	_navigation_invalid_consecutive = 0
	velocity.x = safe_vel.x
	velocity.z = safe_vel.z
	move_and_slide()
	if audit_enabled and (_boundary_recovery_active or recovery_already_moved):
		_v0436_r1f_note_move(audit_frame)
		_v0436_r1f_record_callback(audit_frame, safe_vel, callback_position_before, global_position, true, recovery_already_moved)

func _face(target_pos: Vector3) -> void:
	var to := target_pos - global_position
	to.y = 0
	if to.length() < 0.01:
		return
	var yaw := atan2(-to.x, -to.z)
	if model_root:
		model_root.rotation.y = lerp_angle(model_root.rotation.y, yaw, 0.25)

# --------------------------------------------------------------------------
# Damage / death / heal
# --------------------------------------------------------------------------
func take_damage(amount: float, from = null) -> void:
	if is_dead or (world and not world.game_running):
		return
	var source_team := _combat_source_team(from)
	if source_team == team:
		return
	var hp_before := hp
	var applied := maxf(0.0, amount)
	hp = maxf(0.0, hp - applied)
	_last_damage_source = from if from is Unit and is_instance_valid(from) else from.get("source_unit", null) if from is Dictionary and is_instance_valid(from.get("source_unit", null)) else null
	_last_damage_source_team = source_team
	_last_damage_source_id = _combat_source_id(from)
	_last_damage_kind = _combat_source_kind(from)
	_last_damage_type = _combat_source_type(from)
	_r15_hit_flash_time = 0.16
	if world:
		world.on_unit_damaged(self, from)
		if world.has_method("record_combat_damage"):
			world.record_combat_damage(self, from, applied, hp_before, hp)
	if hp <= 0.0:
		if hero_flags.get("last_stand", false) and not _last_stand_used:
			_last_stand_used = true
			hp = 1.0
			return
		_die(from)

func heal(amount: float) -> void:
	if is_dead: return
	hp = min(max_hp, hp + amount)

func apply_stun(t: float) -> void:
	_stun = max(_stun, t)

func apply_root(t: float) -> void:
	if hero_flags.get("unstoppable", false):
		return
	_rooted = max(_rooted, t)

func apply_slow(t: float) -> void:
	if hero_flags.get("unstoppable", false):
		return
	_slow = max(_slow, t)

func gain_veterancy() -> void:
	_kills += 1
	if _kills % 3 == 0 and _veterancy < 3:
		_veterancy += 1
		max_hp += 15.0
		hp += 15.0

func set_aura_bonus(d: float, a: float) -> void:
	_aura_bonus_dmg = d
	_aura_bonus_armor = a

func _die(from = null) -> void:
	if is_dead:
		return
	is_dead = true
	state = State.DEAD
	_r15_hit_flash_time = 0.0
	if is_instance_valid(_r15_attack_cue): _r15_attack_cue.visible = false
	if is_instance_valid(_r15_hit_flash): _r15_hit_flash.visible = false
	set_selected(false)
	collision_layer = 0
	_play_sfx("death", -12.0)
	var credit_source = _last_damage_source if is_instance_valid(_last_damage_source) else from
	if is_instance_valid(credit_source):
		if credit_source.has_method("gain_veterancy"):
			credit_source.gain_veterancy()
		if credit_source is Unit and credit_source.commander and credit_source.commander.build_flags.get("bounty", false):
			credit_source.commander.add_resources("gold", 3)
	if is_hero:
		# heroes are downed, not deleted from the profile — just removed from field
		pass
	emit_signal("died", self)
	if anim and _anim_names.has("death"):
		_play("death", true)
		await get_tree().create_timer(1.6).timeout
	else:
		await get_tree().create_timer(0.1).timeout
	# sink then free
	var t := create_tween()
	t.tween_property(self, "position:y", position.y - 2.0, 1.0)
	await t.finished
	queue_free()

func _combat_source_team(from) -> int:
	if from == null:
		return -1
	if from is Dictionary:
		return int(from.get("source_team", -1))
	if "source_team" in from:
		return int(from.source_team)
	if "team" in from:
		return int(from.team)
	return -1

func _combat_source_id(from) -> String:
	if from == null:
		return ""
	if from is Dictionary:
		return String(from.get("source_unit_id", from.get("source_id", "")))
	if "source_unit_id" in from:
		return String(from.source_unit_id)
	if "unit_id" in from:
		return String(from.unit_id)
	return ""

func _combat_source_kind(from) -> String:
	if from == null:
		return "environment"
	if from is Dictionary:
		return String(from.get("projectile_kind", "melee"))
	if "projectile_kind" in from:
		return String(from.projectile_kind)
	return "melee"

func _combat_source_type(from) -> String:
	if from == null:
		return ""
	if from is Dictionary:
		return String(from.get("damage_type", ""))
	if "dmg_type" in from:
		return String(from.dmg_type)
	return ""

# --------------------------------------------------------------------------
# Hero abilities
# --------------------------------------------------------------------------
func can_cast(id: String) -> bool:
	if not is_hero or not abilities.has(id):
		return false
	var ab := SkillDefs.get_abilities().get(id, {})
	if mana < float(ab.get("mana", 0)):
		return false
	if ability_cd.get(id, 0.0) > 0.0:
		return false
	return true

func cast_ability(id: String, target_pos: Vector3) -> bool:
	if not can_cast(id):
		return false
	var ab := SkillDefs.get_abilities().get(id, {})
	mana -= float(ab.get("mana", 0))
	ability_cd[id] = float(ab.get("cd", 10.0))
	_play_sfx("spell", -4.0)
	if world:
		world.execute_hero_ability(self, id, target_pos, abilities.get(id, 1))
	return true
