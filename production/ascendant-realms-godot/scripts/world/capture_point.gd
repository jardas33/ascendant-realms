class_name CapturePoint
extends StaticBody3D
## A strategic Lume site. Units standing nearby capture it; grants a benefit
## to the owning team (income, vision, heal, mana regen).

signal captured(point, team)

var point_name := "Lume Spire"
var benefit := "income"        # income | vision | heal | mana
var owner_team := -1           # -1 neutral
var _progress := 0.0           # -1..+1 relative to contesting team
var _contesting_team := -1
var world = null
var footprint := 4.0

var ring: MeshInstance3D
var beam: MeshInstance3D
var _income_timer := 0.0

func configure(p_name: String, p_benefit: String, model_path: String, p_world) -> void:
	point_name = p_name
	benefit = p_benefit
	world = p_world
	add_to_group("capture_points")
	collision_layer = 16
	collision_mask = 0
	var root := Node3D.new()
	add_child(root)
	if model_path == "composed:ruin_chapel":
		_build_ruin_chapel(root)
	elif model_path == "composed:seven_mouths":
		_build_seven_mouths(root)
	elif model_path == "composed:highland_watch":
		_build_highland_watch(root)
	elif model_path != "" and ResourceLoader.exists(model_path):
		var load_start := Time.get_ticks_usec()
		var m = load(model_path).instantiate()
		var recorder = get_node_or_null("/root/HP4M20Startup")
		if recorder and OS.get_environment("ASCENDANT_HP4M20_DIAGNOSTICS") == "1":
			recorder.record_resource_load(model_path, "capture_point.configure", load_start, Time.get_ticks_usec(), "load_instantiate")
		root.add_child(m)
		ModelUtils.scale_to_height(m, 6.0)
		ModelUtils.ground_model(m)
		ModelUtils.add_per_part_convex_collision(m, 16)
		footprint = max(3.0, ModelUtils.measure_radius(m))
	_build_ring()
	_build_beam()

const _PILLAR := "res://assets/environment/structures/ancient_ruin_pillar.glb"
const _ALTAR := "res://assets/environment/visual_convergence/small_stone_cairn.glb"

func _build_ruin_chapel(root: Node3D) -> void:
	# A broken circle of old pillars around a lit altar stone. Only the altar
	# collides; the pillars stand outside the path units take to the centre.
	var rng := RandomNumberGenerator.new()
	rng.seed = int(global_position.x * 13.0 + global_position.z * 7.0)
	var count := 7
	for i in count:
		if i == 4:
			continue  # the gap: a fallen pillar lies here instead
		var a := TAU * float(i) / float(count) + 0.3
		var pillar: Node3D = load(_PILLAR).instantiate()
		root.add_child(pillar)
		pillar.position = Vector3(cos(a), 0.0, sin(a)) * 5.4
		ModelUtils.scale_to_height(pillar, rng.randf_range(2.6, 4.8) if i % 3 != 1 else rng.randf_range(1.2, 2.0))
		ModelUtils.ground_model(pillar)
		pillar.rotation = Vector3(rng.randf_range(-0.06, 0.06), rng.randf() * TAU, rng.randf_range(-0.06, 0.06))
		for body in pillar.find_children("*", "CollisionObject3D", true, false):
			body.queue_free()
	var fallen: Node3D = load(_PILLAR).instantiate()
	root.add_child(fallen)
	var fa := TAU * 4.0 / float(count) + 0.3
	ModelUtils.scale_to_height(fallen, 3.6)
	fallen.position = Vector3(cos(fa), 0.35, sin(fa)) * 5.8
	fallen.rotation = Vector3(PI * 0.5, fa, 0.0)
	for body in fallen.find_children("*", "CollisionObject3D", true, false):
		body.queue_free()
	var altar: Node3D = load(_ALTAR).instantiate()
	root.add_child(altar)
	ModelUtils.scale_to_height(altar, 1.5)
	ModelUtils.ground_model(altar)
	ModelUtils.add_per_part_convex_collision(altar, 16)
	var glow := OmniLight3D.new()
	glow.light_color = Color(0.55, 1.0, 0.7)
	glow.light_energy = 1.6
	glow.omni_range = 6.5
	glow.shadow_enabled = false
	glow.position = Vector3(0, 1.8, 0)
	root.add_child(glow)
	footprint = 3.0

## The Spring of Seven Mouths: a round pool with seven standing stones at
## its rim, each one a mouth of the spring, and the Lume's light in the water.
## Only the stones collide; the pool is ankle deep.
func _build_seven_mouths(root: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7707
	var pool := MeshInstance3D.new()
	pool.name = "SpringPool"
	var disc := CylinderMesh.new()
	disc.top_radius = 5.4
	disc.bottom_radius = 5.4
	disc.height = 0.08
	disc.radial_segments = 28
	pool.mesh = disc
	var water := StandardMaterial3D.new()
	water.albedo_color = Color(0.16, 0.42, 0.44)
	water.roughness = 0.12
	water.metallic = 0.2
	water.emission_enabled = true
	water.emission = Color(0.20, 0.75, 0.55)
	water.emission_energy_multiplier = 0.22
	pool.material_override = water
	pool.position.y = 0.06
	pool.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(pool)
	var rim := MeshInstance3D.new()
	rim.name = "SpringRim"
	var ring := TorusMesh.new()
	ring.inner_radius = 5.3
	ring.outer_radius = 6.3
	ring.rings = 28
	ring.ring_segments = 6
	rim.mesh = ring
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color(0.42, 0.42, 0.40)
	stone.roughness = 0.95
	rim.material_override = stone
	rim.scale.y = 0.55
	rim.position.y = 0.1
	root.add_child(rim)
	for i in 7:
		var a := TAU * float(i) / 7.0 + 0.22
		# The carved spring waystones, one for each mouth.
		var mouth: Node3D = load(_WAYSTONE if ResourceLoader.exists(_WAYSTONE) else _PILLAR).instantiate()
		root.add_child(mouth)
		mouth.position = Vector3(cos(a), 0.0, sin(a)) * 6.6
		ModelUtils.scale_to_height(mouth, rng.randf_range(2.6, 3.4))
		ModelUtils.ground_model(mouth)
		mouth.rotation.y = rng.randf() * TAU
		for body in mouth.find_children("*", "CollisionObject3D", true, false):
			body.queue_free()
	var glow := OmniLight3D.new()
	glow.light_color = Color(0.45, 1.0, 0.75)
	glow.light_energy = 2.0
	glow.omni_range = 9.0
	glow.shadow_enabled = false
	glow.position = Vector3(0, 1.4, 0)
	root.add_child(glow)
	footprint = 3.0

const _OUTCROP := "res://assets/environment/rocks/highland_rock_cluster.glb"
const _WAYSTONE := "res://assets/environment/visual_convergence/lioraen_moonstone.glb"
const _BRAZIER := "res://assets/environment/visual_convergence/barrosan_settlement/barrosan_watch_brazier_lod1.glb"

func _build_highland_watch(root: Node3D) -> void:
	# A rocky lookout: an outcrop with standing stones and a lit signal
	# brazier. Only the outcrop collides.
	var rock: Node3D = load(_OUTCROP).instantiate()
	root.add_child(rock)
	ModelUtils.scale_to_height(rock, 2.6)
	ModelUtils.ground_model(rock)
	ModelUtils.add_per_part_convex_collision(rock, 16)
	for i in 3:
		var a := TAU * float(i) / 3.0 + 0.9
		var stone: Node3D = load(_PILLAR).instantiate()
		root.add_child(stone)
		stone.position = Vector3(cos(a), 0.0, sin(a)) * 4.6
		ModelUtils.scale_to_height(stone, [3.8, 2.6, 4.4][i])
		ModelUtils.ground_model(stone)
		stone.rotation.y = a
		for body in stone.find_children("*", "CollisionObject3D", true, false):
			body.queue_free()
	var brazier: Node3D = load(_BRAZIER).instantiate()
	root.add_child(brazier)
	brazier.position = Vector3(2.4, 0.0, 1.6)
	ModelUtils.ground_model(brazier)
	var fire := BrazierFire.new()
	fire.position = Vector3(0.0, 1.36, 0.0)
	brazier.add_child(fire)
	for body in brazier.find_children("*", "CollisionObject3D", true, false):
		body.queue_free()
	footprint = 3.0

func _build_ring() -> void:
	# Rune circle over the real 7.5 m capture radius with a progress arc that
	# fills as a team captures (capture_zone shader). Presentation only.
	ring = MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.orientation = PlaneMesh.FACE_Y
	quad.size = Vector2(15.4, 15.4)
	ring.mesh = quad
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/capture_zone.gdshader")
	ring.material_override = mat
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.position.y = 0.12
	add_child(ring)

func _build_beam() -> void:
	beam = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.9
	cyl.bottom_radius = 0.6
	cyl.height = 16.0
	cyl.cap_top = false
	cyl.cap_bottom = false
	beam.mesh = cyl
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/capture_beam.gdshader")
	beam.material_override = mat
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	beam.position.y = 8.0
	add_child(beam)

func _physics_process(delta: float) -> void:
	# Capture ownership, progress, and benefits are match mutations. Once the
	# existing world terminal commits, freeze this child-owned tick alongside
	# GameWorld, Units, AI, and input; do not create a second terminal state.
	if not world or not world.game_running:
		return
	# find which team dominates the ring
	var counts := {}
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead:
			continue
		# Defeated-Commander remnants remain physically present for world
		# readability, but they are no longer an active capture authority.
		# Reuse the existing Unit lifecycle predicate; do not invent a second
		# defeated/remnant state machine in the capture point.
		if u.has_method("_is_defeated_remnant") and u._is_defeated_remnant():
			continue
		if u.global_position.distance_to(global_position) <= 7.5:
			counts[u.team] = int(counts.get(u.team, 0)) + 1
	var lead_team := -1
	var lead := 0
	var tie := false
	for t in counts:
		if counts[t] > lead:
			lead = counts[t]
			lead_team = t
			tie = false
		elif counts[t] == lead:
			tie = true
	if lead_team != -1 and not tie and lead_team != owner_team:
		# Every claim starts from nothing. An owned site kept its progress at
		# full, so one enemy scout stepping into the ring took it in a single
		# tick; and a second team inherited whatever the first had built up.
		if _contesting_team != lead_team:
			_contesting_team = lead_team
			_progress = 0.0
		_progress += delta * 0.35
		_tint(GameData.TEAM_COLORS.get(lead_team, Color.WHITE), clamp(_progress, 0, 1))
		if _progress >= 1.0:
			_set_owner(lead_team)
	elif _contesting_team >= 0:
		# Nobody presses the claim: it fades, and an owned site settles back
		# to its owner's colours.
		_progress = max(0.0, _progress - delta * 0.15)
		if _progress > 0.0:
			_tint(GameData.TEAM_COLORS.get(_contesting_team, Color.WHITE), _progress)
		else:
			var faded := _contesting_team
			_contesting_team = -1
			if owner_team >= 0:
				_progress = 1.0
				_tint(GameData.TEAM_COLORS.get(owner_team, Color.WHITE), 1.0)
			else:
				_tint(GameData.TEAM_COLORS.get(faded, Color.WHITE), 0.0)

	# benefit income
	if owner_team >= 0:
		_income_timer += delta
		if _income_timer >= 2.0:
			_income_timer = 0.0
			_apply_benefit()

func _apply_benefit() -> void:
	if not world or not world.game_running:
		return
	var cmd = world.commander_for_team(owner_team)
	if not cmd or cmd.defeated:
		return
	match benefit:
		"income":
			cmd.add_resources("gold", 12)
		"heal":
			world.heal_allies_near(global_position, 14.0, 8.0, owner_team)
		"mana":
			if cmd.hero_ref and is_instance_valid(cmd.hero_ref):
				cmd.hero_ref.mana = min(cmd.hero_ref.max_mana, cmd.hero_ref.mana + 20.0)
		"vision":
			pass

func _set_owner(team: int) -> void:
	if not world or not world.game_running:
		return
	var previous_owner := owner_team
	owner_team = team
	_progress = 1.0
	_contesting_team = -1
	_tint(GameData.TEAM_COLORS.get(team, Color.WHITE), 1.0)
	emit_signal("captured", self, team)
	if world:
		world.on_point_captured(self, team, previous_owner)

func _tint(c: Color, strength: float) -> void:
	var owned := owner_team >= 0 and strength >= 1.0
	if ring and ring.material_override is ShaderMaterial:
		var m := ring.material_override as ShaderMaterial
		m.set_shader_parameter("contest_color", c)
		m.set_shader_parameter("progress", clampf(strength, 0.0, 1.0))
		if owned:
			m.set_shader_parameter("owner_color", c)
		m.set_shader_parameter("owned", 1.0 if owned else 0.0)
	if beam and beam.material_override is ShaderMaterial:
		var b := beam.material_override as ShaderMaterial
		b.set_shader_parameter("beam_color", c.lerp(Color(1, 0.85, 0.4), 0.35) if owned else Color(1, 0.85, 0.4))
		b.set_shader_parameter("strength", 0.9 if owned else 0.6)

func get_capture_snapshot() -> Dictionary:
	return {"point_name": point_name, "owner_team": owner_team, "progress": _progress, "contesting_team": _contesting_team, "global_position": global_position}
