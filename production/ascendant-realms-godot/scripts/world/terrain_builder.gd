class_name TerrainBuilder
extends Node3D
## Builds the visual battlefield: a textured, path-veined flat ground (units path
## on the separate flat navmesh, unchanged), a procedural mountain ring that frames
## the map and blocks the horizon, a forest foothill belt bridging the play field to
## the peaks, and a great lake to the north with stylized toon water. All of it is
## scenery around a flat playable core, so gameplay/pathing is untouched.

const GROUND_TEX := {
	"grass": "res://assets/textures/nature/highland_grass.png",
	"meadow": "res://assets/textures/nature/highland_meadow_grass_r5.png",
	"dirt": "res://assets/textures/nature/highland_dirt_path.png",
	"rock": "res://assets/textures/stone/highland_rock.png",
	"snow": "res://assets/textures/nature/frostmere_windswept_snow_r1.png",
	"volcanic": "res://assets/textures/ground/vorthak_volcanic_ash_r1.png",
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
var _ground_material: Material = null

# WORLD-03 is a player-facing environment layer for Hollowspan only. These
# shelves are shallow, non-colliding visual landforms over the existing flat
# playable plane; they do not alter the navmesh, topology, or object positions.
const WORLD03_HOLLOWSPAN_SHELVES := [
	[Vector3(-58.0, 0.0, -54.0), Vector2(13.0, 8.5), 0.18],
	[Vector3(58.0, 0.0, 54.0), Vector2(13.0, 8.5), -0.22],
	[Vector3(54.0, 0.0, -54.0), Vector2(11.0, 7.5), 0.36],
	[Vector3(-54.0, 0.0, 54.0), Vector2(11.0, 7.5), -0.34],
	[Vector3(-28.0, 0.0, -18.0), Vector2(9.0, 6.5), 0.20],
	[Vector3(28.0, 0.0, 18.0), Vector2(9.0, 6.5), -0.20],
]


func build(map: Dictionary) -> void:
	_rng.seed = 776644
	_theme = MapDefs.theme(map.get("theme", "highland"))
	_water_on = _theme.get("water", {}).get("enabled", false)
	_bay_open = _water_on   # open the north bay only when this map has a lake
	_build_ground(map)
	_build_world03_landforms(map)
	_build_mountains()
	if _water_on:
		_build_lake()
		if map.has("bridge"):
			_build_ford(map)


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
	_ground_material = _make_ground_material(map)
	mi.material_override = _ground_material
	add_child(mi)


func _build_world03_landforms(map: Dictionary) -> void:
	if map.get("id", "") != "hollowspan":
		return
	var layer := Node3D.new()
	layer.name = "World03TerrainShelves"
	add_child(layer)
	for index in WORLD03_HOLLOWSPAN_SHELVES.size():
		var spec: Array = WORLD03_HOLLOWSPAN_SHELVES[index]
		# Two shelves sat on the crossing line and floated over the ford.
		if map.has("bridge") and absf(Vector3(spec[0]).z - float(map.get("overview", {}).get("water_center_z", 52.0))) < 14.0:
			continue
		var shelf := _make_world03_shelf(spec[1], float(spec[2]), index)
		shelf.position = spec[0]
		shelf.add_to_group("world03_shelves")
		layer.add_child(shelf)


func _make_world03_shelf(size: Vector2, rotation_y: float, index: int) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segments := 16
	var crown := Vector2(size.x * 0.48, size.y * 0.48)
	for i in segments:
		var a0 := TAU * float(i) / float(segments)
		var a1 := TAU * float(i + 1) / float(segments)
		var wob0 := 1.0 + 0.13 * sin(float(i * 7 + index * 3)) + 0.05 * sin(float(i * 3 + index))
		var wob1 := 1.0 + 0.13 * sin(float((i + 1) * 7 + index * 3)) + 0.05 * sin(float((i + 1) * 3 + index))
		var outer0 := Vector3(cos(a0) * size.x * wob0, 0.012 + 0.008 * sin(float(i * 5 + index)), sin(a0) * size.y * wob0)
		var outer1 := Vector3(cos(a1) * size.x * wob1, 0.012 + 0.008 * sin(float((i + 1) * 5 + index)), sin(a1) * size.y * wob1)
		var crown0 := Vector3(cos(a0) * crown.x * wob0, 0.042 + 0.01 * sin(float(i * 2 + index)), sin(a0) * crown.y * wob0)
		var crown1 := Vector3(cos(a1) * crown.x * wob1, 0.042 + 0.01 * sin(float((i + 1) * 2 + index)), sin(a1) * crown.y * wob1)
		var center := Vector3(0.0, 0.055 + 0.008 * sin(float(index + 1)), 0.0)
		# Keep every shelf surface on one continuous planar XZ map. The former
		# per-triangle reset collapsed the crown and centre to one UV point,
		# producing a visible radial texture wedge at normal RTS scale.
		var uv_outer0 := Vector2(outer0.x, outer0.z)
		var uv_outer1 := Vector2(outer1.x, outer1.z)
		var uv_crown0 := Vector2(crown0.x, crown0.z)
		var uv_crown1 := Vector2(crown1.x, crown1.z)
		var uv_center := Vector2(center.x, center.z)
		st.set_uv(uv_outer0); st.add_vertex(outer0)
		st.set_uv(uv_outer1); st.add_vertex(outer1)
		st.set_uv(uv_crown1); st.add_vertex(crown1)
		st.set_uv(uv_outer0); st.add_vertex(outer0)
		st.set_uv(uv_crown1); st.add_vertex(crown1)
		st.set_uv(uv_crown0); st.add_vertex(crown0)
		st.set_uv(uv_crown0); st.add_vertex(crown0)
		st.set_uv(uv_crown1); st.add_vertex(crown1)
		st.set_uv(uv_center); st.add_vertex(center)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.name = "World03FieldShelf_%02d" % index
	mi.mesh = st.commit()
	mi.rotation.y = rotation_y
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Shelves share the ground's world-space material, so they read as a gentle
	# rise in the same meadow instead of a flat green carpet laid on top.
	if _ground_material:
		mi.material_override = _ground_material
	else:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.34, 0.44, 0.29)
		mi.material_override = mat
	return mi


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
	sm.set_shader_parameter("volcanic_surface", 1.0 if String(map.get("theme", "")) == "volcanic" else 0.0)
	# R19 material hierarchy: calm the walkable plane first, then let roads
	# carry a restrained value shift.  This is presentation-only and does not
	# change the map's authored geometry or navigation data.
	var grade := _r19_ground_grade(str(map.get("theme", "highland")))
	sm.set_shader_parameter("ground_base", grade.ground_base)
	sm.set_shader_parameter("road_base", grade.road_base)
	sm.set_shader_parameter("road_edge_color", grade.road_edge_color)
	sm.set_shader_parameter("surface_detail", grade.surface_detail)
	sm.set_shader_parameter("surface_macro", grade.surface_macro)
	sm.set_shader_parameter("road_detail", grade.road_detail)
	sm.set_shader_parameter("road_edge_strength", grade.road_edge_strength)
	sm.set_shader_parameter("surface_saturation", grade.surface_saturation)
	sm.set_shader_parameter("field_strength", float(grade.get("field_strength", 0.0)))
	sm.set_shader_parameter("field_lush", grade.get("field_lush", Color(0.26, 0.36, 0.16)))
	sm.set_shader_parameter("field_dry", grade.get("field_dry", Color(0.52, 0.48, 0.26)))
	sm.set_shader_parameter("field_moss", grade.get("field_moss", Color(0.18, 0.25, 0.14)))
	sm.set_shader_parameter("relief_strength", float(grade.get("relief_strength", 0.0)))
	if _water_on and map.has("bridge"):
		var ov: Dictionary = map.get("overview", {})
		sm.set_shader_parameter("ford", Vector3(float(ov.get("water_center_z", 52.0)), float(ov.get("water_width", 22.0)) * 0.5, 1.0))
	# Scorched ash yards under Vorthak opponent starts (start i+1 is opponent i).
	var scorch: Array = []
	var opponents: Array = Match.get_config().get("opponents", [])
	# Bloom meadows under Lioraen starts use a negative strength.
	var races: Array = [str(Match.get_config().get("player_race", ""))]
	for opponent in opponents:
		races.append(str(opponent.get("race", "")))
	for i in range(0, starts.size()):
		if scorch.size() >= 4 or i >= races.size():
			break
		if races[i] == "vorthak":
			scorch.append(Vector4(starts[i].x, starts[i].z, 22.0, 0.92))
		elif races[i] == "lioraen":
			scorch.append(Vector4(starts[i].x, starts[i].z, 24.0, -0.85))
	var scorch_count := scorch.size()
	while scorch.size() < 4:
		scorch.append(Vector4(9999, 9999, 0.1, 0.0))
	sm.set_shader_parameter("scorch_zones", scorch)
	sm.set_shader_parameter("scorch_count", scorch_count)
	sm.set_shader_parameter("snow_shadow_color", grade.get("snow_shadow_color", Color(0.62, 0.69, 0.80)))
	sm.set_shader_parameter("snow_highlight_color", grade.get("snow_highlight_color", Color(0.90, 0.95, 1.0)))
	sm.set_shader_parameter("snow_underlay_strength", float(grade.get("snow_underlay_strength", 0.24)))
	sm.set_shader_parameter("snow_variation_strength", float(grade.get("snow_variation_strength", 0.78)))
	return sm


func _r19_ground_grade(theme_name: String) -> Dictionary:
	match theme_name:
		"volcanic":
			# Broad ash and basalt fields cool the play surface behind Vorthak's
			# warm structures. Rusted roads retain a clear navigational read.
			return {"ground_base": Color(0.35, 0.35, 0.37), "road_base": Color(0.47, 0.36, 0.29), "road_edge_color": Color(0.19, 0.19, 0.21), "surface_detail": 0.77, "surface_macro": 0.14, "road_detail": 0.38, "road_edge_strength": 0.21, "surface_saturation": 0.72, "field_strength": 0.32, "field_lush": Color(0.33, 0.34, 0.36), "field_dry": Color(0.49, 0.44, 0.40), "field_moss": Color(0.27, 0.28, 0.30), "relief_strength": 0.26}
		"ashen":
			# Ashen needs a firmer value floor and broader breakup so the existing
			# stone/dirt inputs survive the full battlefield view.
			return {"ground_base": Color(0.31, 0.32, 0.35), "road_base": Color(0.46, 0.37, 0.29), "road_edge_color": Color(0.16, 0.17, 0.19), "surface_detail": 0.52, "surface_macro": 0.34, "road_detail": 0.54, "road_edge_strength": 0.23, "surface_saturation": 0.64}
		"snow":
			# The authored snow texture supplies drift structure; the cool road
			# and earth values retain tactical hierarchy under the winter light.
			return {"ground_base": Color(0.34, 0.40, 0.49), "road_base": Color(0.40, 0.39, 0.38), "road_edge_color": Color(0.18, 0.23, 0.29), "surface_detail": 0.42, "surface_macro": 0.28, "road_detail": 0.38, "road_edge_strength": 0.26, "surface_saturation": 0.66, "snow_shadow_color": Color(0.58, 0.66, 0.77), "snow_highlight_color": Color(0.88, 0.93, 1.0), "snow_underlay_strength": 0.08, "snow_variation_strength": 0.82}
		"verdant":
			# Keep Bloomvale's inviting green mids after replacing the repeated
			# plant stamps with a finer, more natural meadow texture.
			return {"ground_base": Color(0.29, 0.43, 0.25), "road_base": Color(0.48, 0.37, 0.24), "road_edge_color": Color(0.19, 0.22, 0.16), "surface_detail": 0.52, "surface_macro": 0.23, "road_detail": 0.48, "road_edge_strength": 0.29, "surface_saturation": 0.88, "field_strength": 0.42, "relief_strength": 1.0}
		_:
			# WORLD-03 highland grade: broader value variation and a clearer
			# road verge, while keeping the grass palette restrained for units.
			return {"ground_base": Color(0.31, 0.39, 0.26), "road_base": Color(0.48, 0.37, 0.24), "road_edge_color": Color(0.19, 0.22, 0.16), "surface_detail": 0.46, "surface_macro": 0.27, "road_detail": 0.48, "road_edge_strength": 0.29, "surface_saturation": 0.82, "field_strength": 0.5, "relief_strength": 1.0}


# ---------------------------------------------------------------------------
# Bridge maps (Hollowspan Crossing, Mirefen, Frostmere, Duskwater) name and
# draw a river crossing on the minimap, but the battlefield had no water: the
# bridge stood on grass. A shallow, walkable ford now runs along the crossing
# line. It is presentation only: navigation, pathing and the bridge's own
# structural blockers are unchanged, so units wade the ford or take the bridge.
func _build_ford(map: Dictionary) -> void:
	if not ResourceLoader.exists(WATER_SHADER):
		return
	var ov: Dictionary = map.get("overview", {})
	var center_z := float(ov.get("water_center_z", 52.0))
	var width := float(ov.get("water_width", 22.0)) * 0.8
	var water := MeshInstance3D.new()
	water.name = "CrossingFord"
	var pm := PlaneMesh.new()
	pm.size = Vector2(GROUND_SIZE, width)
	water.mesh = pm
	var wm := ShaderMaterial.new()
	wm.shader = load("res://assets/shaders/ford_water.gdshader")
	var w: Dictionary = _theme.get("water", {})
	if w.get("lava", false):
		wm.set_shader_parameter("shallow_tint", Color(0.9, 0.35, 0.08))
		wm.set_shader_parameter("deep_tint", Color(0.55, 0.12, 0.03))
	water.material_override = wm
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	water.position = Vector3(0.0, 0.07, center_z)
	add_child(water)


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
