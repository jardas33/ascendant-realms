class_name Projectile
extends Node3D
## Simple homing/ballistic projectile. Pooled-free: frees on impact.

var target = null
var target_pos: Vector3
var speed: float = 24.0
var damage: float = 10.0
var dmg_type: String = "pierce"
var team: int = 0
var splash: float = 0.0
var world = null
var kind: String = "arrow"
var source = null
var source_team := -1
var source_unit_id := ""
var source_runtime_id := ""
var projectile_kind := "arrow"
var r1j_attack_event_id := ""
var r1j_projectile_event_id := ""
var _alive_time := 0.0

var _mesh: MeshInstance3D

# P1 task 266 presentation tuning. These values enlarge only the rendered
# projectile silhouette and contrast; movement, collision, impact timing, and
# damage remain unchanged.
const P1_PROJECTILE_RADIUS := 0.09
const P1_PROJECTILE_HEIGHT := 1.28
const P1_PROJECTILE_EMISSION := 3.8

func setup(from: Vector3, tgt, dmg: float, dtype: String, p_team: int, p_world, p_kind: String, p_splash: float = 0.0, p_source = null, p_attack_event_id: String = "") -> void:
	global_position = from
	target = tgt
	damage = dmg
	dmg_type = dtype
	team = p_team
	world = p_world
	kind = p_kind
	projectile_kind = p_kind
	r1j_attack_event_id = p_attack_event_id
	source = p_source if is_instance_valid(p_source) else null
	source_team = p_team
	if is_instance_valid(p_source):
		source_unit_id = String(p_source.unit_id) if "unit_id" in p_source else ""
		source_runtime_id = str(p_source.get_instance_id())
	splash = p_splash
	if is_instance_valid(tgt):
		target_pos = tgt.global_position + Vector3.UP * 0.8

func _ready() -> void:
	_build_visual()

func _build_visual() -> void:
	# Presentation only: flight speed, collision/impact timing and damage are
	# unchanged. Arrows are dark shafts with a faint warm streak; magic bolts are
	# a small hot core inside a soft additive halo, so neither reads as a bright
	# solid bar or disc under the battlefield glow.
	_mesh = MeshInstance3D.new()
	var col := Color(0.9, 0.85, 0.5)
	match kind:
		"arrow", "bolt", "thorn":
			var shaft := CylinderMesh.new()
			shaft.top_radius = 0.022
			shaft.bottom_radius = 0.022
			shaft.height = 0.85
			shaft.radial_segments = 5
			_mesh.mesh = shaft
			_mesh.rotation_degrees.x = 90.0
			var wood := StandardMaterial3D.new()
			wood.albedo_color = Color(0.30, 0.20, 0.11) if kind != "thorn" else Color(0.22, 0.34, 0.14)
			wood.roughness = 0.8
			_mesh.material_override = wood
			add_child(_mesh)
			col = Color(1.0, 0.78, 0.40) if kind != "thorn" else Color(0.58, 0.95, 0.46)
			var streak := MeshInstance3D.new()
			var quad := QuadMesh.new()
			quad.size = Vector2(0.12, 1.3)
			streak.mesh = quad
			streak.rotation_degrees.x = 90.0
			streak.position.z = 0.35
			streak.material_override = _glow_material(col, 0.55, BaseMaterial3D.BILLBOARD_FIXED_Y)
			streak.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(streak)
		_:
			match kind:
				"cinder": col = Color(1.0, 0.45, 0.12)
				"void_bolt", "rift_shell": col = Color(0.72, 0.30, 0.95)
				"lume_bolt": col = Color(1.0, 0.85, 0.4)
				"thornpod": col = Color(0.5, 0.75, 0.4)
				"cannon": col = Color(0.35, 0.32, 0.30)
			var core := SphereMesh.new()
			core.radius = 0.11 if kind != "cannon" else 0.2
			core.height = core.radius * 2.0
			_mesh.mesh = core
			var core_mat := StandardMaterial3D.new()
			core_mat.albedo_color = col.lerp(Color.WHITE, 0.35)
			if kind != "cannon":
				core_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			_mesh.material_override = core_mat
			add_child(_mesh)
			if kind != "cannon":
				var halo := MeshInstance3D.new()
				var hq := QuadMesh.new()
				hq.size = Vector2(0.75, 0.75)
				halo.mesh = hq
				halo.material_override = _glow_material(col, 0.9, BaseMaterial3D.BILLBOARD_ENABLED)
				halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				add_child(halo)
	# glow light for magic
	if kind in ["cinder", "void_bolt", "lume_bolt", "rift_shell"]:
		var l := OmniLight3D.new()
		l.light_color = col
		l.light_energy = 1.4
		l.omni_range = 4.0
		add_child(l)

static var _glow_cache := {}
static var _glow_tex: Texture2D

static func _glow_material(col: Color, energy: float, billboard: int) -> StandardMaterial3D:
	var key := "%s_%s_%d" % [col.to_html(false), energy, billboard]
	if _glow_cache.has(key):
		return _glow_cache[key]
	if _glow_tex == null:
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		for y in 32:
			for x in 32:
				var p := Vector2((x + 0.5) / 32.0 - 0.5, (y + 0.5) / 32.0 - 0.5) * 2.0
				var a := clampf(1.0 - p.length(), 0.0, 1.0)
				img.set_pixel(x, y, Color(1, 1, 1, a * a))
		_glow_tex = ImageTexture.create_from_image(img)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.billboard_mode = billboard
	m.albedo_color = Color(col.r * energy, col.g * energy, col.b * energy, 1.0)
	m.albedo_texture = _glow_tex
	m.disable_receive_shadows = true
	_glow_cache[key] = m
	return m

func _physics_process(delta: float) -> void:
	_alive_time += delta
	if _alive_time > 5.0:
		if world and world.has_method("_v0436_r1j_recorder"):
			var recorder = world._v0436_r1j_recorder()
			if recorder: recorder.record_projectile_phase(self, "despawn", {"reason":"lifetime_expired"})
		queue_free()
		return
	if is_instance_valid(target) and not target.is_dead:
		target_pos = target.global_position + Vector3.UP * 0.8
	var to := target_pos - global_position
	var dist := to.length()
	var step := speed * delta
	if dist <= step or dist < 0.4:
		_impact()
		return
	global_position += to.normalized() * step
	look_at(target_pos, Vector3.UP)

func _impact() -> void:
	if world and world.has_method("projectile_impact"):
		world.projectile_impact(global_position, target, damage, dmg_type, team, splash, kind, self)
	queue_free()
