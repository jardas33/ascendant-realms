extends Node3D
class_name BrazierFire
## Presentation-only fire for braziers and torches: a flickering warm light
## plus a small additive flame. No collision, navigation or gameplay role.

@export var light_range := 7.5
@export var light_energy := 2.2
@export var flame_scale := 1.0

var _light: OmniLight3D
var _time := 0.0
var _seed := 0.0

static var _flame_material: StandardMaterial3D
static var _flame_process: ParticleProcessMaterial


func _ready() -> void:
	_seed = randf() * 100.0
	_light = OmniLight3D.new()
	_light.name = "FireLight"
	_light.light_color = Color(1.0, 0.62, 0.30)
	_light.light_energy = light_energy
	_light.omni_range = light_range
	_light.omni_attenuation = 1.4
	_light.shadow_enabled = false
	_light.position = Vector3(0.0, 0.45 * flame_scale, 0.0)
	add_child(_light)
	add_child(_make_flame())


func _process(delta: float) -> void:
	_time += delta
	# Two out-of-phase sines read as fire without per-frame noise sampling.
	var flicker := 0.86 + 0.09 * sin(_time * 11.0 + _seed) + 0.05 * sin(_time * 23.0 + _seed * 1.7)
	_light.light_energy = light_energy * flicker


func _make_flame() -> GPUParticles3D:
	if _flame_material == null:
		_flame_material = StandardMaterial3D.new()
		_flame_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_flame_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_flame_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		_flame_material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		_flame_material.vertex_color_use_as_albedo = true
		_flame_material.albedo_texture = _flame_texture()
		_flame_material.disable_receive_shadows = true
		_flame_process = ParticleProcessMaterial.new()
		_flame_process.direction = Vector3.UP
		_flame_process.spread = 12.0
		_flame_process.initial_velocity_min = 0.7
		_flame_process.initial_velocity_max = 1.2
		_flame_process.gravity = Vector3(0.0, 0.6, 0.0)
		_flame_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		_flame_process.emission_sphere_radius = 0.14
		_flame_process.scale_min = 0.7
		_flame_process.scale_max = 1.1
		var scale_curve := Curve.new()
		scale_curve.add_point(Vector2(0.0, 0.6))
		scale_curve.add_point(Vector2(0.3, 1.0))
		scale_curve.add_point(Vector2(1.0, 0.15))
		var scale_tex := CurveTexture.new()
		scale_tex.curve = scale_curve
		_flame_process.scale_curve = scale_tex
		var ramp := Gradient.new()
		ramp.set_color(0, Color(1.0, 0.72, 0.32, 0.55))
		ramp.set_color(1, Color(0.8, 0.18, 0.04, 0.0))
		ramp.add_point(0.4, Color(1.0, 0.42, 0.08, 0.45))
		var ramp_tex := GradientTexture1D.new()
		ramp_tex.gradient = ramp
		_flame_process.color_ramp = ramp_tex
	var particles := GPUParticles3D.new()
	particles.name = "Flame"
	particles.amount = 16
	particles.lifetime = 0.55
	particles.randomness = 0.4
	particles.process_material = _flame_process
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	particles.visibility_aabb = AABB(Vector3(-1, -0.5, -1), Vector3(2, 3, 2))
	var quad := QuadMesh.new()
	quad.size = Vector2(0.42, 0.55) * flame_scale
	quad.material = _flame_material
	particles.draw_pass_1 = quad
	particles.scale = Vector3.ONE * flame_scale
	return particles


static func _flame_texture() -> Texture2D:
	# Soft radial falloff so each additive quad reads as a tongue of flame.
	var size := 32
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in size:
		for x in size:
			var p := Vector2((x + 0.5) / size - 0.5, (y + 0.5) / size - 0.5) * 2.0
			p.y *= 0.8
			var a := clampf(1.0 - p.length(), 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a * a))
	return ImageTexture.create_from_image(img)
