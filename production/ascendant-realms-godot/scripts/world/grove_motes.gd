extends GPUParticles3D
class_name GroveMotes
## Presentation-only drifting pollen and lume motes over a Lioraen grove:
## slow, soft green-gold specks that rise and wander. No gameplay role.

static var _material: StandardMaterial3D
static var _process: ParticleProcessMaterial

@export var radius := 16.0


func _ready() -> void:
	if _material == null:
		_material = StandardMaterial3D.new()
		_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		_material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		_material.vertex_color_use_as_albedo = true
		var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		for y in 16:
			for x in 16:
				var p := Vector2((x + 0.5) / 16.0 - 0.5, (y + 0.5) / 16.0 - 0.5) * 2.0
				var a := clampf(1.0 - p.length(), 0.0, 1.0)
				img.set_pixel(x, y, Color(1, 1, 1, a * a))
		_material.albedo_texture = ImageTexture.create_from_image(img)
		_process = ParticleProcessMaterial.new()
		_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		_process.direction = Vector3(0, 1, 0)
		_process.spread = 40.0
		_process.initial_velocity_min = 0.1
		_process.initial_velocity_max = 0.35
		_process.gravity = Vector3(0.05, 0.08, 0.0)
		_process.turbulence_enabled = true
		_process.turbulence_noise_strength = 0.6
		_process.turbulence_noise_scale = 3.0
		_process.scale_min = 0.6
		_process.scale_max = 1.2
		var fade := Gradient.new()
		fade.set_color(0, Color(0.8, 1.0, 0.55, 0.0))
		fade.set_color(1, Color(0.9, 0.85, 0.45, 0.0))
		fade.add_point(0.25, Color(0.75, 1.0, 0.55, 0.9))
		fade.add_point(0.7, Color(0.95, 0.9, 0.5, 0.6))
		var fade_tex := GradientTexture1D.new()
		fade_tex.gradient = fade
		_process.color_ramp = fade_tex
	var box := _process.duplicate() as ParticleProcessMaterial
	box.emission_box_extents = Vector3(radius, 0.8, radius)
	process_material = box
	amount = 70
	lifetime = 7.0
	preprocess = 7.0
	randomness = 0.6
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visibility_aabb = AABB(Vector3(-radius - 2, -1, -radius - 2), Vector3(radius * 2 + 4, 8, radius * 2 + 4))
	var quad := QuadMesh.new()
	quad.size = Vector2(0.12, 0.12)
	quad.material = _material
	draw_pass_1 = quad
