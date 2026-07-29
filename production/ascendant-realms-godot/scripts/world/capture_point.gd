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
	if model_path != "" and ResourceLoader.exists(model_path):
		var m = load(model_path).instantiate()
		root.add_child(m)
		ModelUtils.scale_to_height(m, 6.0)
		ModelUtils.ground_model(m)
		ModelUtils.add_per_part_convex_collision(m, 16)
		footprint = max(3.0, ModelUtils.measure_radius(m))
	_build_ring()
	_build_beam()

func _build_ring() -> void:
	ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 6.0
	torus.outer_radius = 7.0
	ring.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.8, 0.8, 0.5)
	mat.emission_enabled = true
	mat.emission = Color(0.8, 0.8, 0.8)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.material_override = mat
	ring.position.y = 0.15
	add_child(ring)

func _build_beam() -> void:
	beam = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.6
	cyl.bottom_radius = 1.2
	cyl.height = 30.0
	beam.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.4, 0.25)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.85, 0.4)
	mat.emission_energy_multiplier = 2.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam.material_override = mat
	beam.position.y = 15.0
	add_child(beam)

func _physics_process(delta: float) -> void:
	if not world:
		return
	# find which team dominates the ring
	var counts := {}
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead:
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
		_progress += delta * 0.35
		_contesting_team = lead_team
		_tint(GameData.TEAM_COLORS.get(lead_team, Color.WHITE), clamp(_progress, 0, 1))
		if _progress >= 1.0:
			_set_owner(lead_team)
	elif owner_team == -1:
		_progress = max(0.0, _progress - delta * 0.15)

	# benefit income
	if owner_team >= 0:
		_income_timer += delta
		if _income_timer >= 2.0:
			_income_timer = 0.0
			_apply_benefit()

func _apply_benefit() -> void:
	var cmd = world.commander_for_team(owner_team)
	if not cmd:
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
	owner_team = team
	_progress = 1.0
	_contesting_team = -1
	_tint(GameData.TEAM_COLORS.get(team, Color.WHITE), 1.0)
	emit_signal("captured", self, team)
	if world:
		world.on_point_captured(self, team)

func _tint(c: Color, strength: float) -> void:
	if ring and ring.material_override:
		var m := ring.material_override as StandardMaterial3D
		m.albedo_color = c
		m.emission = c
		m.emission_energy_multiplier = 1.0 + strength * 2.0
	if beam and beam.material_override:
		(beam.material_override as StandardMaterial3D).emission = c.lerp(Color(1,0.85,0.4), 0.5)
