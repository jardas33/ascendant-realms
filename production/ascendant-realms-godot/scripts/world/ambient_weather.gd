extends Node3D
## Drifting atmosphere around the camera's view of the ground: pollen and
## seed fluff over meadows, falling leaves in autumn, snow, blown sand, and
## rising embers with falling ash on scorched maps. One GPU particle system
## per layer, emitted in world space inside a box that follows the point the
## camera looks at, so the effect costs the same wherever the player is.
## Presentation only.

const LOOKS := {
	"meadow": {"amount": 200, "size": 0.13, "color": Color(1.0, 0.96, 0.82, 0.75), "gravity": Vector3(0.25, -0.04, 0.12), "speed": 0.35, "life": 9.0, "spin": 0.0, "glow": 0.25},
	"leaves": {"amount": 140, "size": 0.45, "color": Color(0.86, 0.46, 0.16, 1.0), "gravity": Vector3(0.45, -0.55, 0.2), "speed": 0.4, "life": 10.0, "spin": 180.0, "glow": 0.0},
	"snow": {"amount": 800, "size": 0.2, "color": Color(0.96, 0.98, 1.0, 0.9), "gravity": Vector3(0.35, -1.3, 0.15), "speed": 0.2, "life": 9.0, "spin": 0.0, "glow": 0.1},
	"sand": {"amount": 260, "size": 0.1, "color": Color(0.92, 0.80, 0.58, 0.55), "gravity": Vector3(2.2, -0.08, 0.6), "speed": 1.2, "life": 5.0, "spin": 0.0, "glow": 0.0},
	"embers": {"amount": 140, "size": 0.13, "color": Color(1.0, 0.52, 0.18, 1.0), "gravity": Vector3(0.2, 0.55, 0.1), "speed": 0.3, "life": 6.0, "spin": 0.0, "glow": 2.2},
	"ash": {"amount": 240, "size": 0.15, "color": Color(0.42, 0.40, 0.40, 0.8), "gravity": Vector3(0.3, -0.45, 0.1), "speed": 0.2, "life": 10.0, "spin": 90.0, "glow": 0.0},
}

const THEME_LAYERS := {
	"highland": ["meadow"], "verdant": ["meadow"], "tropical": ["meadow"], "wetland": ["meadow"],
	"autumn": ["leaves", "meadow"], "snow": ["snow"], "desert": ["sand"], "badlands": ["sand"],
	"volcanic": ["embers", "ash"], "ashen": ["ash", "embers"],
}

const BOX := Vector3(46.0, 7.0, 34.0)

var _systems: Array[GPUParticles3D] = []

func build(theme_name: String) -> void:
	for layer in THEME_LAYERS.get(theme_name, ["meadow"]):
		_systems.append(_make_layer(LOOKS[layer]))


func _make_layer(look: Dictionary) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.amount = int(look["amount"])
	p.lifetime = float(look["life"])
	p.preprocess = float(look["life"])
	p.local_coords = false
	p.visibility_aabb = AABB(-BOX, BOX * 2.0 + Vector3(0, 10, 0))
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = BOX * 0.5
	pm.gravity = look["gravity"]
	pm.direction = Vector3(1, 0.2, 0.4)
	pm.spread = 180.0
	pm.initial_velocity_min = float(look["speed"]) * 0.4
	pm.initial_velocity_max = float(look["speed"])
	pm.turbulence_enabled = true
	pm.turbulence_noise_strength = 0.6
	pm.turbulence_noise_scale = 6.0
	pm.turbulence_influence_min = 0.05
	pm.turbulence_influence_max = 0.15
	pm.scale_min = 0.6
	pm.scale_max = 1.3
	if float(look["spin"]) > 0.0:
		pm.angular_velocity_min = -float(look["spin"])
		pm.angular_velocity_max = float(look["spin"])
		pm.angle_min = 0.0
		pm.angle_max = 360.0
	# Fade in and out over each particle's life so nothing pops.
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.set_color(1, Color(1, 1, 1, 0))
	fade.add_point(0.15, Color(1, 1, 1, 1))
	fade.add_point(0.8, Color(1, 1, 1, 1))
	var ramp := GradientTexture1D.new()
	ramp.gradient = fade
	pm.color_ramp = ramp
	p.process_material = pm
	var quad := QuadMesh.new()
	var size := float(look["size"])
	quad.size = Vector2(size, size * (0.6 if float(look["spin"]) > 0.0 else 1.0))
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = look["color"]
	mat.albedo_texture = _soft_dot()
	if float(look["glow"]) > 0.0:
		mat.emission_enabled = true
		mat.emission = Color(look["color"]).lightened(0.1)
		mat.emission_energy_multiplier = float(look["glow"])
	quad.material = mat
	p.draw_pass_1 = quad
	add_child(p)
	return p


static var _dot: Texture2D
static func _soft_dot() -> Texture2D:
	if _dot == null:
		var n := 32
		var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				var d := Vector2(x + 0.5 - n * 0.5, y + 0.5 - n * 0.5).length() / (n * 0.5)
				img.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - d * d, 0.0, 1.0)))
		_dot = ImageTexture.create_from_image(img)
	return _dot


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	# Centre the box on the ground point under the middle of the view.
	var origin := cam.global_position
	var forward := -cam.global_transform.basis.z
	var focus := origin
	if forward.y < -0.05:
		focus = origin + forward * (origin.y / -forward.y)
	global_position = Vector3(focus.x, 4.0, focus.z)
