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
	# Plan 494: the jar was three stacked cylinders on a flat disc and read as
	# an orange traffic cone. It is now a turned clay amphora with painted
	# bands, tipped and half sunk in a rounded mound of fresh earth, with
	# broken shards of its neighbours around it.
	var earth := StandardMaterial3D.new()
	earth.albedo_color = Color(0.27, 0.19, 0.12)
	earth.roughness = 1.0
	var mound := MeshInstance3D.new()
	var mm := SphereMesh.new()
	mm.radius = 2.2
	mm.height = 4.4
	mm.radial_segments = 20
	mm.rings = 8
	mound.mesh = mm
	mound.material_override = earth
	mound.scale = Vector3(1.0, 0.13, 0.85)
	add_child(mound)
	var clay := StandardMaterial3D.new()
	clay.vertex_color_use_as_albedo = true
	clay.vertex_color_is_srgb = true
	clay.albedo_color = Color(1, 1, 1)
	clay.roughness = 0.82
	var jar := MeshInstance3D.new()
	jar.name = "Jar"
	jar.mesh = _amphora_mesh()
	jar.material_override = clay
	jar.position = Vector3(0.15, -0.35, 0.0)
	jar.rotation = Vector3(0.12, 0.6, 0.32)
	add_child(jar)
	var wax := StandardMaterial3D.new()
	wax.albedo_color = Color(0.6, 0.12, 0.1)
	wax.emission_enabled = true
	wax.emission = Color(0.8, 0.5, 1.0)
	wax.emission_energy_multiplier = 0.6
	var seal := MeshInstance3D.new()
	var sm := CylinderMesh.new()
	sm.top_radius = 0.24
	sm.bottom_radius = 0.33
	sm.height = 0.14
	sm.radial_segments = 14
	seal.mesh = sm
	seal.material_override = wax
	seal.position.y = 2.42
	jar.add_child(seal)
	var mouth := jar.transform * Vector3(0.0, 2.45, 0.0)
	# Shards of jars that broke on the way up.
	var rng := RandomNumberGenerator.new()
	rng.seed = 4401
	var shard_mat := StandardMaterial3D.new()
	shard_mat.albedo_color = Color(0.58, 0.32, 0.19)
	shard_mat.roughness = 0.85
	for i in 5:
		var shard := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(rng.randf_range(0.25, 0.5), 0.05, rng.randf_range(0.18, 0.35))
		shard.mesh = bm
		shard.material_override = shard_mat
		var a := TAU * float(i) / 5.0 + rng.randf_range(-0.4, 0.4)
		var d := rng.randf_range(1.5, 2.4)
		shard.position = Vector3(cos(a) * d, 0.06, sin(a) * d)
		shard.rotation = Vector3(rng.randf_range(-0.5, 0.5), rng.randf() * TAU, rng.randf_range(-0.4, 0.4))
		add_child(shard)
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
	shaft.position = mouth + Vector3(0.0, 3.5, 0.0)
	add_child(shaft)
	# Lume seeping out: a violet-gold glow and a slow claim ring.
	_light = OmniLight3D.new()
	_light.light_color = Color(0.85, 0.7, 1.0)
	_light.light_energy = 1.6
	_light.omni_range = 7.0
	_light.position = mouth + Vector3(0.0, 0.5, 0.0)
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

## A lathe-turned amphora about 2.4 m tall: foot, wide belly, shoulder,
## narrow neck and a rolled lip. Terracotta with two dark painted bands
## and a lighter slip on the neck, as vertex colours.
static func _amphora_mesh() -> ArrayMesh:
	# x radius, y height, z paint: 0 clay, 1 dark band, 2 pale slip. A band
	# edge is two rings at one height, so the paint ends sharply.
	var prof := [Vector3(0.0, 0.0, 0), Vector3(0.32, 0.0, 0), Vector3(0.42, 0.06, 0), Vector3(0.6, 0.28, 0), Vector3(0.86, 0.68, 0),
		Vector3(1.0, 1.08, 0), Vector3(0.975, 1.34, 0), Vector3(0.975, 1.34, 1), Vector3(0.94, 1.48, 1), Vector3(0.94, 1.48, 0),
		Vector3(0.88, 1.6, 0), Vector3(0.88, 1.6, 1), Vector3(0.83, 1.68, 1), Vector3(0.83, 1.68, 0), Vector3(0.8, 1.74, 0),
		Vector3(0.5, 2.0, 0), Vector3(0.38, 2.12, 0), Vector3(0.38, 2.12, 2), Vector3(0.34, 2.18, 2),
		Vector3(0.33, 2.3, 2), Vector3(0.4, 2.36, 2), Vector3(0.39, 2.43, 2), Vector3(0.28, 2.44, 2)]
	var segs := 24
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var base := Color(0.66, 0.37, 0.22)
	var band := Color(0.16, 0.08, 0.05)
	var slip := Color(0.8, 0.6, 0.42)
	for i in prof.size():
		var y: float = prof[i].y
		var c := base.darkened(0.12 * (1.0 - clampf(y / 1.2, 0.0, 1.0)))
		if int(prof[i].z) == 1:
			c = band
		elif int(prof[i].z) == 2:
			c = slip
		for k in segs + 1:
			var a := TAU * float(k) / float(segs)
			st.set_color(c)
			st.set_uv(Vector2(float(k) / float(segs), y / 2.44))
			st.add_vertex(Vector3(cos(a) * prof[i].x, y, sin(a) * prof[i].x))
	for i in prof.size() - 1:
		for k in segs:
			var a0 := i * (segs + 1) + k
			var b0 := a0 + segs + 1
			st.add_index(a0)
			st.add_index(a0 + 1)
			st.add_index(b0)
			st.add_index(a0 + 1)
			st.add_index(b0 + 1)
			st.add_index(b0)
	st.generate_normals()
	return st.commit()
