class_name TerrainBuilder
extends Node3D
## Builds the visual battlefield: a textured, path-veined flat ground (units path
## on the separate flat navmesh, unchanged), a procedural mountain ring that frames
## the map and blocks the horizon, a forest foothill belt bridging the play field to
## the peaks, and a great lake to the north with stylized toon water. All of it is
## scenery around a flat playable core, so gameplay/pathing is untouched.

const GROUND_TEX := {
	"grass": "res://assets/textures/nature/highland_grass.png",
	"meadow": "res://assets/textures/nature/highland_meadow_grass.png",
	"dirt": "res://assets/textures/nature/highland_dirt_path.png",
	"rock": "res://assets/textures/stone/highland_rock.png",
}
const WATER_SHADER := "res://assets/shaders/toon_water.gdshader"
const GROUND_SHADER := "res://assets/shaders/ground_blend.gdshader"

# scenery geometry (world metres, all beyond the ±140 play walls)
const GROUND_SIZE := 640.0
const GROUND_CENTER := Vector3(0, 0, -90)
const MTN_INNER := 196.0
const MTN_OUTER := 312.0
const MTN_PEAK := 60.0
const MTN_COLS := 132
const MTN_ROWS := 12
# northern bay left open for the lake (angles measured atan2(z,x), radians)
const BAY_MIN := 1.01229   # 58°
const BAY_MAX := 2.12930   # 122°

var _rng := RandomNumberGenerator.new()
var _theme := {}
var _water_on := true
var _bay_open := true


func build(map: Dictionary) -> void:
	_rng.seed = 776644
	_theme = MapDefs.theme(map.get("theme", "highland"))
	_water_on = _theme.get("water", {}).get("enabled", false)
	_bay_open = _water_on   # open the north bay only when this map has a lake
	_build_ground(map)
	_build_mountains()
	if _water_on:
		_build_lake()


# ---------------------------------------------------------------------------
func _build_ground(map: Dictionary) -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(GROUND_SIZE, GROUND_SIZE)
	plane.subdivide_width = 8
	plane.subdivide_depth = 8
	var mi := MeshInstance3D.new()
	mi.name = "GroundVisual"
	mi.mesh = plane
	mi.position = GROUND_CENTER
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.material_override = _make_ground_material(map)
	add_child(mi)


func _make_ground_material(map: Dictionary) -> Material:
	if not ResourceLoader.exists(GROUND_SHADER):
		var fb := StandardMaterial3D.new()
		fb.albedo_color = Color(0.34, 0.44, 0.29)
		return fb
	var sm := ShaderMaterial.new()
	sm.shader = load(GROUND_SHADER)
	for key in GROUND_TEX:
		if ResourceLoader.exists(GROUND_TEX[key]):
			sm.set_shader_parameter("tex_" + key, load(GROUND_TEX[key]))
	# worn roads: each start base -> map centre, plus a couple of cross links
	var segs: Array = []
	var starts: Array = map.get("start_positions", [])
	for s in starts:
		segs.append(Vector4(s.x, s.z, 0.0, 0.0))
	# ring road linking the contested middle expansions
	segs.append(Vector4(-30, -20, 30, 20))
	var arr: Array = []
	for i in range(8):
		arr.append(segs[i] if i < segs.size() else Vector4(9999, 9999, 9999, 9999))
	sm.set_shader_parameter("paths", arr)
	sm.set_shader_parameter("path_count", min(segs.size(), 8))
	sm.set_shader_parameter("path_width", 7.0)
	sm.set_shader_parameter("path_feather", 5.5)
	# biome grade
	sm.set_shader_parameter("tint", _theme.get("ground_tint", Color.WHITE))
	sm.set_shader_parameter("dirt_bias", float(_theme.get("dirt_bias", 0.0)))
	sm.set_shader_parameter("rock_bias", float(_theme.get("rock_bias", 0.0)))
	sm.set_shader_parameter("snow_amt", float(_theme.get("snow", 0.0)))
	return sm


# ---------------------------------------------------------------------------
func _build_mountains() -> void:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.9
	noise.seed = 1337
	var ridge := FastNoiseLite.new()
	ridge.noise_type = FastNoiseLite.TYPE_SIMPLEX
	ridge.frequency = 2.3
	ridge.seed = 99

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for ci in range(MTN_COLS):
		var a0 := float(ci) / float(MTN_COLS) * TAU
		var a1 := float(ci + 1) / float(MTN_COLS) * TAU
		if _in_bay(a0) or _in_bay(a1):
			continue
		for ri in range(MTN_ROWS):
			var t0 := float(ri) / float(MTN_ROWS)
			var t1 := float(ri + 1) / float(MTN_ROWS)
			var p00 := _mtn_vertex(a0, t0, noise, ridge)
			var p10 := _mtn_vertex(a1, t0, noise, ridge)
			var p01 := _mtn_vertex(a0, t1, noise, ridge)
			var p11 := _mtn_vertex(a1, t1, noise, ridge)
			_add_tri(st, p00, p01, p11)
			_add_tri(st, p00, p11, p10)

	st.generate_normals()
	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.name = "MountainRing"
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.material_override = _make_rock_material()
	add_child(mi)


func _in_bay(a: float) -> bool:
	if not _bay_open:
		return false   # no lake -> full mountain ring, no gap/void
	# normalise to atan2(z,x) space where +Z (north) sits at +90°
	var n := a
	while n > PI:
		n -= TAU
	while n < -PI:
		n += TAU
	return n >= BAY_MIN and n <= BAY_MAX


func _mtn_vertex(ang: float, t: float, noise: FastNoiseLite, ridge: FastNoiseLite) -> Vector3:
	var r: float = lerp(MTN_INNER, MTN_OUTER, t)
	var cx := cos(ang)
	var cz := sin(ang)
	# rise from the shore, hold a jagged plateau toward the back
	var prof: float = smoothstep(0.0, 0.42, t)
	var n: float = noise.get_noise_2d(cx * r, cz * r) * 0.5 + 0.5
	var rg: float = absf(ridge.get_noise_2d(cx * r * 1.3, cz * r * 1.3))
	var h: float = MTN_PEAK * prof * (0.4 + 0.85 * n + 0.35 * rg)
	# jitter radius slightly so the footprint isn't a perfect circle
	var rr: float = r + noise.get_noise_2d(cz * r, cx * r) * 10.0
	return Vector3(cos(ang) * rr, h, sin(ang) * rr)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_uv(Vector2(a.x, a.z) * 0.03); st.add_vertex(a)
	st.set_uv(Vector2(b.x, b.z) * 0.03); st.add_vertex(b)
	st.set_uv(Vector2(c.x, c.z) * 0.03); st.add_vertex(c)


func _make_rock_material() -> Material:
	var m := StandardMaterial3D.new()
	if ResourceLoader.exists(GROUND_TEX["rock"]):
		m.albedo_texture = load(GROUND_TEX["rock"])
		m.uv1_scale = Vector3(1, 1, 1)
	else:
		m.albedo_color = Color(0.38, 0.36, 0.34)
	m.albedo_color = _theme.get("rock_tint", Color(0.72, 0.72, 0.7))
	m.roughness = 1.0
	m.metallic = 0.0
	return m


# ---------------------------------------------------------------------------
func _build_lake() -> void:
	# sloping lakebed under the northern bay (a gentle beach, not a cliff)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var noise := FastNoiseLite.new()
	noise.frequency = 0.03
	noise.seed = 71
	var x0 := -340.0
	var x1 := 340.0
	var z0 := 196.0
	var z1 := 392.0
	var step := 20.0
	var xn := int((x1 - x0) / step)
	var zn := int((z1 - z0) / step)
	for xi in range(xn):
		for zi in range(zn):
			var ax := x0 + xi * step
			var bx := x0 + (xi + 1) * step
			var az := z0 + zi * step
			var bz := z0 + (zi + 1) * step
			var p00 := _bed_vertex(ax, az, noise)
			var p10 := _bed_vertex(bx, az, noise)
			var p01 := _bed_vertex(ax, bz, noise)
			var p11 := _bed_vertex(bx, bz, noise)
			_add_tri(st, p00, p01, p11)
			_add_tri(st, p00, p11, p10)
	st.generate_normals()
	var bed := MeshInstance3D.new()
	bed.name = "Lakebed"
	bed.mesh = st.commit()
	bed.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var bm := StandardMaterial3D.new()
	if ResourceLoader.exists(GROUND_TEX["dirt"]):
		bm.albedo_texture = load(GROUND_TEX["dirt"])
		bm.uv1_scale = Vector3(0.08, 0.08, 1)
	bm.albedo_color = Color(0.55, 0.5, 0.42)
	bm.roughness = 1.0
	bed.material_override = bm
	add_child(bed)

	# water surface
	if ResourceLoader.exists(WATER_SHADER):
		var water := MeshInstance3D.new()
		water.name = "Lake"
		var pm := PlaneMesh.new()
		var extent := 420.0
		pm.size = Vector2(extent, extent)
		pm.subdivide_width = 120
		pm.subdivide_depth = 120
		water.mesh = pm
		var wm := ShaderMaterial.new()
		wm.shader = load(WATER_SHADER)
		var w: Dictionary = _theme.get("water", {})
		wm.set_shader_parameter("deep_color", w.get("deep", Color(0.05, 0.22, 0.34)))
		wm.set_shader_parameter("shallow_color", w.get("shallow", Color(0.16, 0.48, 0.58)))
		wm.set_shader_parameter("foam_color", w.get("foam", Color(0.86, 0.95, 1.0)))
		wm.set_shader_parameter("emission_strength", 0.9 if w.get("lava", false) else 0.12)
		water.material_override = wm
		water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		water.custom_aabb = AABB(Vector3(-extent, -20, -extent), Vector3(extent * 2, 40, extent * 2))
		water.position = Vector3(0, -1.7, 292)
		add_child(water)


func _bed_vertex(x: float, z: float, noise: FastNoiseLite) -> Vector3:
	var d: float = smoothstep(200.0, 252.0, z)
	var y: float = -8.0 * d + noise.get_noise_2d(x, z) * 0.7
	return Vector3(x, y, z)
