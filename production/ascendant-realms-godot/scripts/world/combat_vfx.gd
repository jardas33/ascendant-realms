extends RefCounted
class_name CombatVfx
## Presentation-only combat effects with cached, pre-built materials so a
## busy fight never compiles a new pipeline mid-battle.
##   hit(): hot spark streaks, a short additive flash and a low dust kick.
##   death(): a ground-hugging dust cloud with a few thrown clods.
## Nothing here touches damage, targeting, collision or navigation.

static var _spark_process: ParticleProcessMaterial
static var _dust_process: ParticleProcessMaterial
static var _clod_process: ParticleProcessMaterial
static var _spark_mesh: QuadMesh
static var _flash_mesh: QuadMesh
static var _dust_mesh: QuadMesh
static var _clod_mesh: BoxMesh
static var _spark_mats := {}
static var _flash_mats := {}
static var _dust_mat: StandardMaterial3D
static var _soft_tex: Texture2D


static func hit(parent: Node3D, pos: Vector3, col: Color, heavy: bool = false) -> void:
	_ensure()
	var key := col.to_html(false)
	if not _spark_mats.has(key):
		_spark_mats[key] = _additive(col, BaseMaterial3D.BILLBOARD_PARTICLES, 2.2)
		var flash := _additive(col, BaseMaterial3D.BILLBOARD_ENABLED, 1.1)
		_flash_mats[key] = flash
	var sparks := _emitter(parent, pos, _spark_process, _spark_mesh, _spark_mats[key], 14 if heavy else 9, 0.32)
	sparks.transform_align = GPUParticles3D.TRANSFORM_ALIGN_Z_BILLBOARD_Y_TO_VELOCITY
	# A single flash quad that pops and fades.
	var flash := MeshInstance3D.new()
	flash.mesh = _flash_mesh
	flash.material_override = (_flash_mats[key] as StandardMaterial3D).duplicate()
	flash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(flash)
	flash.global_position = pos
	flash.scale = Vector3.ONE * (1.25 if heavy else 0.9)
	var t := flash.create_tween().set_parallel(true)
	t.tween_property(flash, "scale", flash.scale * 1.5, 0.1)
	t.tween_property(flash.material_override, "albedo_color", Color(0, 0, 0, 1), 0.1)
	t.chain().tween_callback(flash.queue_free)
	# A low dust kick at the target's feet.
	_emitter(parent, Vector3(pos.x, 0.15, pos.z), _dust_process, _dust_mesh, _dust_mat, 5 if heavy else 3, 0.9)


## A few chips flying off a resource being worked: wood splinters, stone
## grit, gold glints or chaff, in the resource's own colour.
static var _chip_mats := {}
static var _chip_mesh: BoxMesh

static func gather_chips(parent: Node3D, pos: Vector3, kind: String) -> void:
	_ensure()
	if _chip_mesh == null:
		_chip_mesh = BoxMesh.new()
		_chip_mesh.size = Vector3(0.07, 0.04, 0.1)
	if not _chip_mats.has(kind):
		var m := StandardMaterial3D.new()
		m.roughness = 0.9
		match kind:
			"timber": m.albedo_color = Color(0.72, 0.52, 0.3)
			"stone": m.albedo_color = Color(0.66, 0.66, 0.64)
			"gold":
				m.albedo_color = Color(1.0, 0.82, 0.3)
				m.emission_enabled = true
				m.emission = Color(0.9, 0.65, 0.15)
				m.emission_energy_multiplier = 1.6
			_: m.albedo_color = Color(0.78, 0.7, 0.36)
		_chip_mats[kind] = m
	var p := _emitter(parent, pos, _clod_process, _chip_mesh, _chip_mats[kind], 4, 0.7)
	p.scale = Vector3.ONE * 0.8

static func death(parent: Node3D, pos: Vector3) -> void:
	_ensure()
	_emitter(parent, Vector3(pos.x, 0.2, pos.z), _dust_process, _dust_mesh, _dust_mat, 12, 1.4).scale = Vector3.ONE * 1.6
	_emitter(parent, Vector3(pos.x, 0.3, pos.z), _clod_process, _clod_mesh, null, 8, 0.9)


static func _emitter(parent: Node3D, pos: Vector3, process: ParticleProcessMaterial, mesh: Mesh, mat: Material, count: int, life: float) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.process_material = process
	p.draw_pass_1 = mesh
	if mat:
		p.material_override = mat
	p.amount = count
	p.lifetime = life
	p.one_shot = true
	p.explosiveness = 0.92
	p.randomness = 0.4
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.visibility_aabb = AABB(Vector3(-4, -1, -4), Vector3(8, 6, 8))
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	p.finished.connect(p.queue_free)
	return p


static func _ensure() -> void:
	if _spark_process != null:
		return
	_soft_tex = _radial_texture(32)
	_spark_process = ParticleProcessMaterial.new()
	_spark_process.direction = Vector3(0, 0.6, 0)
	_spark_process.spread = 75.0
	_spark_process.initial_velocity_min = 3.5
	_spark_process.initial_velocity_max = 7.0
	_spark_process.gravity = Vector3(0, -14, 0)
	_spark_process.scale_min = 0.6
	_spark_process.scale_max = 1.1
	var spark_fade := Gradient.new()
	spark_fade.set_color(0, Color(1, 1, 1, 1))
	spark_fade.set_color(1, Color(1, 0.5, 0.2, 0))
	var spark_ramp := GradientTexture1D.new()
	spark_ramp.gradient = spark_fade
	_spark_process.color_ramp = spark_ramp
	_spark_mesh = QuadMesh.new()
	_spark_mesh.size = Vector2(0.035, 0.2)
	_flash_mesh = QuadMesh.new()
	_flash_mesh.size = Vector2(0.5, 0.5)

	_dust_process = ParticleProcessMaterial.new()
	_dust_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_dust_process.emission_sphere_radius = 0.35
	_dust_process.direction = Vector3(0, 1, 0)
	_dust_process.spread = 80.0
	_dust_process.initial_velocity_min = 0.6
	_dust_process.initial_velocity_max = 1.6
	_dust_process.gravity = Vector3(0, 0.25, 0)
	_dust_process.damping_min = 1.5
	_dust_process.damping_max = 2.5
	_dust_process.angle_min = -180.0
	_dust_process.angle_max = 180.0
	var dust_grow := Curve.new()
	dust_grow.add_point(Vector2(0, 0.4))
	dust_grow.add_point(Vector2(1, 1.0))
	var dust_grow_tex := CurveTexture.new()
	dust_grow_tex.curve = dust_grow
	_dust_process.scale_curve = dust_grow_tex
	var dust_fade := Gradient.new()
	dust_fade.set_color(0, Color(0.55, 0.47, 0.36, 0.0))
	dust_fade.set_color(1, Color(0.60, 0.54, 0.44, 0.0))
	dust_fade.add_point(0.15, Color(0.52, 0.45, 0.35, 0.5))
	var dust_ramp := GradientTexture1D.new()
	dust_ramp.gradient = dust_fade
	_dust_process.color_ramp = dust_ramp
	_dust_mesh = QuadMesh.new()
	_dust_mesh.size = Vector2(1.1, 1.1)
	_dust_mat = StandardMaterial3D.new()
	_dust_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_dust_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_dust_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	_dust_mat.vertex_color_use_as_albedo = true
	_dust_mat.albedo_texture = _soft_tex

	_clod_process = ParticleProcessMaterial.new()
	_clod_process.direction = Vector3(0, 1, 0)
	_clod_process.spread = 55.0
	_clod_process.initial_velocity_min = 2.5
	_clod_process.initial_velocity_max = 4.5
	_clod_process.gravity = Vector3(0, -12, 0)
	_clod_process.angular_velocity_min = -360.0
	_clod_process.angular_velocity_max = 360.0
	_clod_process.scale_min = 0.5
	_clod_process.scale_max = 1.2
	_clod_mesh = BoxMesh.new()
	_clod_mesh.size = Vector3(0.09, 0.07, 0.08)
	var clod_mat := StandardMaterial3D.new()
	clod_mat.albedo_color = Color(0.23, 0.17, 0.11)
	clod_mat.roughness = 1.0
	_clod_mesh.material = clod_mat


static func _additive(col: Color, billboard: int, energy: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.billboard_mode = billboard
	m.vertex_color_use_as_albedo = billboard == BaseMaterial3D.BILLBOARD_PARTICLES
	m.albedo_color = Color(col.r * energy, col.g * energy, col.b * energy, 1.0)
	m.albedo_texture = _soft_tex
	m.disable_receive_shadows = true
	return m


static func _radial_texture(size: int) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in size:
		for x in size:
			var p := Vector2((x + 0.5) / size - 0.5, (y + 0.5) / size - 0.5) * 2.0
			var a := clampf(1.0 - p.length(), 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a * a))
	return ImageTexture.create_from_image(img)


# --------------------------------------------------------------------------
# Ground markers: order confirmations and ability shockwaves.
# --------------------------------------------------------------------------
static var _ring_tex: Texture2D
static var _chevron_tex: Texture2D
static var _marker_quad: QuadMesh

static func _ground_quad_material(tex: Texture2D, col: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_texture = tex
	m.albedo_color = col
	m.no_depth_test = false
	m.disable_receive_shadows = true
	return m

static func _ensure_markers() -> void:
	if _ring_tex != null:
		return
	_marker_quad = QuadMesh.new()
	_marker_quad.size = Vector2(2.0, 2.0)
	_marker_quad.orientation = PlaneMesh.FACE_Y
	var n := 96
	var ring := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var chev := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for y in n:
		for x in n:
			var p := Vector2((x + 0.5) / n - 0.5, (y + 0.5) / n - 0.5) * 2.0
			var r := p.length()
			# Soft ring with a bright core and a faint inner fill.
			var band := exp(-pow((r - 0.82) / 0.07, 2.0)) + 0.12 * clampf(1.0 - r, 0.0, 1.0)
			ring.set_pixel(x, y, Color(1, 1, 1, clampf(band, 0.0, 1.0)))
			# Four inward chevrons on the diagonals.
			var a := fposmod(atan2(p.y, p.x) + PI * 0.25, PI * 0.5) - PI * 0.25
			var along := r * cos(a)
			var across := absf(r * sin(a))
			var v := 0.0
			if along > 0.45 and along < 0.95:
				var edge := absf(across - (along - 0.45) * 0.7)
				v = clampf(1.0 - edge / 0.07, 0.0, 1.0)
			chev.set_pixel(x, y, Color(1, 1, 1, v))
	_ring_tex = ImageTexture.create_from_image(ring)
	_chevron_tex = ImageTexture.create_from_image(chev)

## Order confirmation: a soft ring that collapses onto the spot, with inward
## chevrons for attack orders, plus a brief glow. Presentation only.
static func order_marker(parent: Node3D, pos: Vector3, col: Color, radius: float, attack: bool) -> void:
	_ensure_markers()
	var root := Node3D.new()
	parent.add_child(root)
	root.global_position = pos + Vector3(0, 0.1, 0)
	var ring := MeshInstance3D.new()
	ring.mesh = _marker_quad
	var ring_mat := _ground_quad_material(_ring_tex, Color(col.r * 1.6, col.g * 1.6, col.b * 1.6, 1.0))
	ring.material_override = ring_mat
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(ring)
	ring.scale = Vector3.ONE * radius * 1.7
	var t := root.create_tween().set_parallel(true)
	t.tween_property(ring, "scale", Vector3.ONE * radius * 0.55, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(ring_mat, "albedo_color:a", 0.0, 0.42).set_delay(0.12)
	if attack:
		var chev := MeshInstance3D.new()
		chev.mesh = _marker_quad
		var chev_mat := _ground_quad_material(_chevron_tex, Color(col.r * 1.8, col.g * 1.8, col.b * 1.8, 1.0))
		chev.material_override = chev_mat
		chev.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(chev)
		chev.scale = Vector3.ONE * radius * 1.9
		t.tween_property(chev, "scale", Vector3.ONE * radius * 0.9, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.tween_property(chev_mat, "albedo_color:a", 0.0, 0.45).set_delay(0.15)
	t.chain().tween_callback(root.queue_free)

## Ability shockwave: the same soft ring expanding outward and fading.
static func shockwave(parent: Node3D, pos: Vector3, col: Color, radius: float) -> void:
	_ensure_markers()
	var ring := MeshInstance3D.new()
	ring.mesh = _marker_quad
	var mat := _ground_quad_material(_ring_tex, Color(col.r * 1.4, col.g * 1.4, col.b * 1.4, 1.0))
	ring.material_override = mat
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(ring)
	ring.global_position = pos + Vector3(0, 0.12, 0)
	ring.scale = Vector3.ONE * radius * 0.2
	var t := ring.create_tween().set_parallel(true)
	t.tween_property(ring, "scale", Vector3.ONE * radius * 1.12, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(mat, "albedo_color:a", 0.0, 0.6).set_delay(0.1)
	t.chain().tween_callback(ring.queue_free)


## A column of Lume light where a fallen hero rises again: a tall additive
## beam that swells and fades, with a warm light flash on the ground.
static func lume_pillar(parent: Node3D, pos: Vector3, col: Color) -> void:
	var beam := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.7
	cyl.bottom_radius = 1.1
	cyl.height = 16.0
	cyl.radial_segments = 20
	cyl.cap_top = false
	cyl.cap_bottom = false
	beam.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(col.r, col.g, col.b, 0.0)
	beam.material_override = mat
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(beam)
	beam.global_position = pos + Vector3(0, 8.0, 0)
	beam.scale = Vector3(0.3, 1.0, 0.3)
	var light := OmniLight3D.new()
	light.light_color = col
	light.light_energy = 0.0
	light.omni_range = 9.0
	parent.add_child(light)
	light.global_position = pos + Vector3(0, 1.5, 0)
	var t := beam.create_tween().set_parallel(true)
	t.tween_property(mat, "albedo_color:a", 0.38, 0.35)
	t.tween_property(beam, "scale", Vector3(1.0, 1.0, 1.0), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(light, "light_energy", 5.0, 0.3)
	t.chain().tween_interval(0.7)
	t.chain().set_parallel(true)
	t.tween_property(mat, "albedo_color:a", 0.0, 1.2)
	t.tween_property(beam, "scale", Vector3(0.1, 1.0, 0.1), 1.2)
	t.tween_property(light, "light_energy", 0.0, 1.2)
	t.chain().tween_callback(func():
		beam.queue_free()
		light.queue_free())


## Rising glow motes around a unit (heals, rallies, empowerment).
static var _mote_process: ParticleProcessMaterial
static var _mote_mesh: QuadMesh
static var _mote_mats := {}

static func motes(parent: Node3D, pos: Vector3, col: Color, size_scale: float = 1.0) -> void:
	_ensure()
	if _mote_process == null:
		_mote_process = ParticleProcessMaterial.new()
		_mote_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
		_mote_process.emission_ring_axis = Vector3.UP
		_mote_process.emission_ring_radius = 0.55
		_mote_process.emission_ring_inner_radius = 0.2
		_mote_process.emission_ring_height = 0.2
		_mote_process.direction = Vector3(0, 1, 0)
		_mote_process.spread = 12.0
		_mote_process.initial_velocity_min = 1.2
		_mote_process.initial_velocity_max = 2.4
		_mote_process.gravity = Vector3(0, 0.6, 0)
		_mote_process.damping_min = 0.8
		_mote_process.damping_max = 1.4
		var fade := Gradient.new()
		fade.set_color(0, Color(1, 1, 1, 0))
		fade.set_color(1, Color(1, 1, 1, 0))
		fade.add_point(0.2, Color(1, 1, 1, 1))
		var ramp := GradientTexture1D.new()
		ramp.gradient = fade
		_mote_process.color_ramp = ramp
		_mote_mesh = QuadMesh.new()
		_mote_mesh.size = Vector2(0.24, 0.24)
	var key := col.to_html(false)
	if not _mote_mats.has(key):
		_mote_mats[key] = _additive(col, BaseMaterial3D.BILLBOARD_PARTICLES, 2.4)
	var p := _emitter(parent, pos + Vector3(0, 0.2, 0), _mote_process, _mote_mesh, _mote_mats[key], 14, 1.1)
	p.explosiveness = 0.35
	p.scale = Vector3.ONE * size_scale

## Heavy ground impact: a wide dust ring and thrown clods.
static func slam(parent: Node3D, pos: Vector3, radius: float) -> void:
	_ensure()
	var dust := _emitter(parent, Vector3(pos.x, 0.25, pos.z), _dust_process, _dust_mesh, _dust_mat, 26, 1.6)
	dust.scale = Vector3.ONE * clampf(radius * 0.32, 1.4, 3.2)
	dust.visibility_aabb = AABB(Vector3(-12, -1, -12), Vector3(24, 8, 24))
	_emitter(parent, Vector3(pos.x, 0.3, pos.z), _clod_process, _clod_mesh, null, 18, 1.0).scale = Vector3.ONE * 1.5

## Shared selection-ring material per team colour (units and buildings).
static var _selection_ring_materials := {}

static func selection_ring_material(col: Color) -> ShaderMaterial:
	var key := col.to_html(false)
	if not _selection_ring_materials.has(key):
		var m := ShaderMaterial.new()
		m.shader = load("res://assets/shaders/selection_ring.gdshader")
		m.set_shader_parameter("ring_color", col)
		_selection_ring_materials[key] = m
	return _selection_ring_materials[key]


## Churned, darkened ground where a unit fell; fades out over ~25 s. At most
## MAX_SCARS stay on the field (oldest recycled) so long wars stay cheap.
const MAX_SCARS := 40
static var _scar_shader: Shader
static var _scar_mesh: QuadMesh
static var _scars: Array = []

static func battle_scar(parent: Node3D, pos: Vector3) -> void:
	if _scar_shader == null:
		_scar_shader = load("res://assets/shaders/battle_scar.gdshader")
		_scar_mesh = QuadMesh.new()
		_scar_mesh.orientation = PlaneMesh.FACE_Y
		_scar_mesh.size = Vector2(2.2, 2.2)
	while _scars.size() >= MAX_SCARS:
		var old = _scars.pop_front()
		if is_instance_valid(old):
			old.queue_free()
	var scar := MeshInstance3D.new()
	scar.mesh = _scar_mesh
	var m := ShaderMaterial.new()
	m.shader = _scar_shader
	m.set_shader_parameter("seed", randf() * 100.0)
	scar.material_override = m
	scar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(scar)
	scar.global_position = Vector3(pos.x, 0.05, pos.z)
	scar.rotation.y = randf() * TAU
	scar.scale = Vector3.ONE * randf_range(0.8, 1.2)
	_scars.append(scar)
	var t := scar.create_tween()
	t.tween_interval(18.0)
	t.tween_method(func(v: float): m.set_shader_parameter("fade", v), 1.0, 0.0, 8.0)
	t.tween_callback(func():
		_scars.erase(scar)
		scar.queue_free())

## A building coming down: a towering dust cloud, thrown debris, and a
## rubble heap with scorched ground that stays for the rest of the match.
const _RUBBLE := "res://assets/environment/visual_convergence/small_stone_cairn.glb"
const _LOGS := "res://assets/environment/visual_convergence/fallen_timber_cluster.glb"

static func collapse(parent: Node3D, pos: Vector3, footprint: float) -> void:
	_ensure()
	for k in 3:
		var off := Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * footprint * 0.4
		var dust := _emitter(parent, Vector3(pos.x, 0.4, pos.z) + off, _dust_process, _dust_mesh, _dust_mat, 60, 3.2)
		dust.scale = Vector3.ONE * clampf(footprint * 1.1, 2.5, 5.5)
		dust.visibility_aabb = AABB(Vector3(-15, -1, -15), Vector3(30, 14, 30))
	_emitter(parent, Vector3(pos.x, 0.8, pos.z), _clod_process, _clod_mesh, null, 30, 1.2).scale = Vector3.ONE * 2.6
	# Scorched footprint that does not fade.
	if _scar_shader == null:
		_scar_shader = load("res://assets/shaders/battle_scar.gdshader")
	var scar := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.orientation = PlaneMesh.FACE_Y
	quad.size = Vector2.ONE * footprint * 3.0
	scar.mesh = quad
	var m := ShaderMaterial.new()
	m.shader = _scar_shader
	m.set_shader_parameter("seed", randf() * 100.0)
	scar.material_override = m
	scar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(scar)
	scar.global_position = Vector3(pos.x, 0.045, pos.z)
	# Rubble: tumbled stones and broken timbers, rising as the dust clears.
	var rubble := Node3D.new()
	parent.add_child(rubble)
	rubble.global_position = Vector3(pos.x, 0.0, pos.z)
	var pieces := 5 + int(footprint * 1.5)
	for i in pieces:
		var path := _LOGS if i % 3 == 2 else _RUBBLE
		if not ResourceLoader.exists(path):
			continue
		var piece: Node3D = load(path).instantiate()
		rubble.add_child(piece)
		var a := randf() * TAU
		piece.position = Vector3(cos(a), 0.0, sin(a)) * randf_range(0.0, footprint * 0.75)
		ModelUtils.scale_to_height(piece, randf_range(1.0, 1.9) if path == _RUBBLE else 1.3)
		ModelUtils.ground_model(piece)
		piece.rotation.y = randf() * TAU
		for body in piece.find_children("*", "CollisionObject3D", true, false):
			body.queue_free()
		for g in piece.find_children("*", "GeometryInstance3D", true, false):
			g.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	rubble.scale = Vector3(1, 0.01, 1)
	rubble.create_tween().tween_property(rubble, "scale", Vector3.ONE, 1.4).set_delay(0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
