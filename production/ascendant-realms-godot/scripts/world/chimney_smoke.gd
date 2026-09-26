extends GPUParticles3D
class_name ChimneySmoke
## Presentation-only hearth smoke: soft grey puffs that rise, swell, drift
## with the wind and thin out. No collision, navigation or gameplay role.

static var _material: StandardMaterial3D
static var _process: ParticleProcessMaterial


func _ready() -> void:
	if _material == null:
		_material = StandardMaterial3D.new()
		_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		_material.vertex_color_use_as_albedo = true
		_material.albedo_texture = _puff_texture()
		_material.disable_receive_shadows = true
		_process = ParticleProcessMaterial.new()
		_process.direction = Vector3(0.25, 1.0, 0.1)
		_process.spread = 8.0
		_process.initial_velocity_min = 0.6
		_process.initial_velocity_max = 0.9
		_process.gravity = Vector3(0.35, 0.12, 0.08)  # gentle up-valley breeze
		_process.damping_min = 0.1
		_process.damping_max = 0.2
		_process.angle_min = -180.0
		_process.angle_max = 180.0
		_process.scale_min = 0.8
		_process.scale_max = 1.2
		var grow := Curve.new()
		grow.add_point(Vector2(0.0, 0.35))
		grow.add_point(Vector2(1.0, 1.0))
		var grow_tex := CurveTexture.new()
		grow_tex.curve = grow
		_process.scale_curve = grow_tex
		var fade := Gradient.new()
		fade.set_color(0, Color(0.55, 0.52, 0.50, 0.0))
		fade.set_color(1, Color(0.72, 0.72, 0.74, 0.0))
		fade.add_point(0.12, Color(0.50, 0.48, 0.46, 0.42))
		fade.add_point(0.6, Color(0.66, 0.66, 0.68, 0.22))
		var fade_tex := GradientTexture1D.new()
		fade_tex.gradient = fade
		_process.color_ramp = fade_tex
	amount = 14
	lifetime = 6.0
	preprocess = 6.0
	randomness = 0.5
	process_material = _process
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visibility_aabb = AABB(Vector3(-2, -1, -2), Vector3(10, 10, 6))
	var quad := QuadMesh.new()
	quad.size = Vector2(1.3, 1.3)
	quad.material = _material
	draw_pass_1 = quad


static func _puff_texture() -> Texture2D:
	var size := 48
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in size:
		for x in size:
			var p := Vector2((x + 0.5) / size - 0.5, (y + 0.5) / size - 0.5) * 2.0
			# Lumpy edge so puffs don't read as perfect discs.
			var ang := atan2(p.y, p.x)
			var r := p.length() / (0.82 + 0.12 * sin(ang * 3.0) + 0.06 * sin(ang * 7.0))
			var a := clampf(1.0 - r, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a * a * (3.0 - 2.0 * a)))
	return ImageTexture.create_from_image(img)
