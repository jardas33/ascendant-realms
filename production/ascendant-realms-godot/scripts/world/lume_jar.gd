extends Node3D
## A buried Lume jar surfacing on the battlefield. In the last war the elders
## hid their Lume in clay jars under the fields (the Wine of the Dead); the
## Ascension is pushing them up again. Troops of one side standing over a jar
## for OPEN_TIME seconds dig it up and claim the spoils. If rival troops stand
## there too, nobody digs. A small contested objective between the bases.

const OPEN_TIME := 6.0
const RADIUS := 4.5
const REWARD_GOLD := 150
const REWARD_OTHER := 100

var progress := 0.0
var digging_team := -1
var _ring: MeshInstance3D
var _ring_mat: StandardMaterial3D
var _light: OmniLight3D

func _ready() -> void:
	add_to_group("lume_jars")
	# Fresh-turned earth where the jar has pushed up.
	var mound := MeshInstance3D.new()
	var mm := CylinderMesh.new()
	mm.top_radius = 1.5
	mm.bottom_radius = 2.1
	mm.height = 0.35
	mm.radial_segments = 18
	mound.mesh = mm
	var earth := StandardMaterial3D.new()
	earth.albedo_color = Color(0.3, 0.2, 0.13)
	earth.roughness = 1.0
	mound.material_override = earth
	mound.position.y = 0.1
	add_child(mound)
	# A big amphora-shaped clay jar, half sunk in the earth: a wide belly, a
	# narrower shoulder and neck, sealed with red wax.
	var clay := StandardMaterial3D.new()
	clay.albedo_color = Color(0.62, 0.36, 0.22)
	clay.roughness = 0.85
	for part in [[0.85, 1.05, 1.1, 0.75], [0.55, 0.85, 0.5, 1.55], [0.4, 0.45, 0.45, 2.0]]:
		var piece := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = float(part[0])
		cm.bottom_radius = float(part[1])
		cm.height = float(part[2])
		cm.radial_segments = 16
		piece.mesh = cm
		piece.material_override = clay
		piece.position.y = float(part[3])
		add_child(piece)
	var seal := MeshInstance3D.new()
	var sm := CylinderMesh.new()
	sm.top_radius = 0.34
	sm.bottom_radius = 0.46
	sm.height = 0.18
	seal.mesh = sm
	var wax := StandardMaterial3D.new()
	wax.albedo_color = Color(0.6, 0.12, 0.1)
	wax.emission_enabled = true
	wax.emission = Color(0.8, 0.5, 1.0)
	wax.emission_energy_multiplier = 0.6
	seal.material_override = wax
	seal.position.y = 2.3
	add_child(seal)
	# The Lume escaping through the cracked seal: a faint violet shaft.
	var shaft := MeshInstance3D.new()
	var shm := CylinderMesh.new()
	shm.top_radius = 0.05
	shm.bottom_radius = 0.22
	shm.height = 7.0
	shaft.mesh = shm
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.albedo_color = Color(0.82, 0.62, 1.0, 0.35)
	shaft.material_override = glow
	shaft.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	shaft.position.y = 5.8
	add_child(shaft)
	# Lume seeping out: a violet-gold glow and a slow claim ring.
	_light = OmniLight3D.new()
	_light.light_color = Color(0.85, 0.7, 1.0)
	_light.light_energy = 1.6
	_light.omni_range = 7.0
	_light.position.y = 2.8
	add_child(_light)
	_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = RADIUS - 0.25
	torus.outer_radius = RADIUS
	torus.rings = 32
	torus.ring_segments = 4
	_ring.mesh = torus
	_ring_mat = StandardMaterial3D.new()
	_ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ring_mat.albedo_color = Color(0.78, 0.6, 1.0, 0.6)
	_ring.material_override = _ring_mat
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ring.position.y = 0.08
	add_child(_ring)

func _process(delta: float) -> void:
	if is_instance_valid(_ring):
		_ring.rotation.y += delta * (0.3 + progress)
	if is_instance_valid(_light):
		_light.light_energy = 1.6 + 2.0 * (progress / OPEN_TIME) + 0.3 * sin(Time.get_ticks_msec() / 300.0)

## Called by the world every half second with the teams standing over the jar.
## Returns the team that finished digging, or -1.
func tick_claim(teams_present: Array, step: float) -> int:
	if teams_present.size() != 1:
		# Nobody here, or a fight over it: the digging stalls.
		if teams_present.is_empty():
			progress = maxf(0.0, progress - step * 0.5)
		return -1
	var t := int(teams_present[0])
	if t != digging_team:
		digging_team = t
		progress = 0.0
	progress += step
	if is_instance_valid(_ring_mat):
		_ring_mat.albedo_color = Color(GameData.TEAM_COLORS.get(t, Color.WHITE), 0.75)
	return t if progress >= OPEN_TIME else -1
