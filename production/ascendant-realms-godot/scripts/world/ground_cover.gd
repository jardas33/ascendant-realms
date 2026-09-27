extends Node3D

## Instanced grass tufts and wildflowers over the open battlefield, grown in
## clumps from a noise field, kept off roads, water and start yards, and split
## into chunks so the camera culls what it can't see. Building footprints and
## resource sites clear the cover through a mask texture (see `clear_circle`).
## Presentation only: no collision, no navigation, no shadows cast.

const SHADER := preload("res://assets/shaders/grass_cover.gdshader")
const CHUNK := 40.0
const SPACING := 1.25
const MASK_RES := 256
const START_CLEAR := 30.0

## Per-theme look: tip/root/dry colours, density 0..1, flower share, flower palette.
const THEMES := {
	"highland": {"tip": Color(0.70, 0.72, 0.32), "root": Color(0.15, 0.21, 0.07), "dry": Color(0.72, 0.62, 0.34), "density": 1.0, "dryness": 0.35, "flowers": 0.10,
		"palette": [Color(0.95, 0.86, 0.35), Color(0.92, 0.92, 0.88), Color(0.62, 0.48, 0.86), Color(0.90, 0.46, 0.52)]},
	"verdant": {"tip": Color(0.50, 0.68, 0.26), "root": Color(0.11, 0.22, 0.06), "dry": Color(0.62, 0.62, 0.30), "density": 1.0, "dryness": 0.15, "flowers": 0.12,
		"palette": [Color(0.98, 0.90, 0.40), Color(0.95, 0.95, 0.92), Color(0.86, 0.40, 0.55)]},
	"tropical": {"tip": Color(0.42, 0.66, 0.24), "root": Color(0.08, 0.20, 0.06), "dry": Color(0.58, 0.60, 0.28), "density": 1.0, "dryness": 0.1, "flowers": 0.10,
		"palette": [Color(0.98, 0.52, 0.30), Color(0.95, 0.30, 0.45), Color(0.98, 0.88, 0.30)]},
	"wetland": {"tip": Color(0.46, 0.56, 0.26), "root": Color(0.10, 0.17, 0.07), "dry": Color(0.56, 0.52, 0.30), "density": 0.9, "dryness": 0.25, "flowers": 0.05,
		"palette": [Color(0.92, 0.92, 0.85), Color(0.70, 0.60, 0.90)]},
	"autumn": {"tip": Color(0.78, 0.58, 0.26), "root": Color(0.24, 0.18, 0.07), "dry": Color(0.80, 0.50, 0.22), "density": 0.85, "dryness": 0.6, "flowers": 0.04,
		"palette": [Color(0.95, 0.72, 0.30), Color(0.85, 0.35, 0.22)]},
	"desert": {"tip": Color(0.80, 0.70, 0.44), "root": Color(0.40, 0.32, 0.18), "dry": Color(0.82, 0.72, 0.46), "density": 0.22, "dryness": 1.0, "flowers": 0.0, "palette": []},
	"badlands": {"tip": Color(0.72, 0.56, 0.36), "root": Color(0.34, 0.24, 0.14), "dry": Color(0.76, 0.58, 0.38), "density": 0.25, "dryness": 1.0, "flowers": 0.0, "palette": []},
	"volcanic": {"tip": Color(0.42, 0.38, 0.30), "root": Color(0.14, 0.12, 0.10), "dry": Color(0.46, 0.40, 0.32), "density": 0.18, "dryness": 1.0, "flowers": 0.0, "palette": []},
	"ashen": {"tip": Color(0.52, 0.52, 0.46), "root": Color(0.18, 0.18, 0.16), "dry": Color(0.56, 0.54, 0.48), "density": 0.3, "dryness": 0.9, "flowers": 0.0, "palette": []},
	"snow": {"tip": Color(0.62, 0.62, 0.52), "root": Color(0.30, 0.30, 0.26), "dry": Color(0.70, 0.66, 0.56), "density": 0.12, "dryness": 0.9, "flowers": 0.0, "palette": []},
}

var _mask_image: Image
var _mask_texture: ImageTexture
var _half := 140.0
var _material: ShaderMaterial

func build(map: Dictionary, theme_name: String, density_scale: float = 1.0) -> void:
	var look: Dictionary = THEMES.get(theme_name, THEMES["highland"])
	var density := float(look["density"]) * density_scale
	if density <= 0.0:
		return
	_half = float(map.get("size", 140.0))
	_mask_image = Image.create(MASK_RES, MASK_RES, false, Image.FORMAT_R8)
	_mask_texture = ImageTexture.create_from_image(_mask_image)
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter("tip_color", look["tip"])
	_material.set_shader_parameter("root_color", look["root"])
	_material.set_shader_parameter("dry_color", look["dry"])
	_material.set_shader_parameter("clear_mask", _mask_texture)
	_material.set_shader_parameter("mask_origin", Vector2(-_half, -_half))
	_material.set_shader_parameter("mask_size", Vector2(_half * 2.0, _half * 2.0))

	var tuft := _make_tuft_mesh(false)
	var flower := _make_tuft_mesh(true)
	var starts: Array = map.get("start_positions", [])
	var roads: Array = []
	for s in starts:
		roads.append([Vector2(s.x, s.z), Vector2.ZERO])
	roads.append([Vector2(-30, -20), Vector2(30, 20)])
	var water: Dictionary = map.get("water", {})
	var overview: Dictionary = map.get("overview", {})
	var water_on := bool(water.get("enabled", false))
	var crossing := str(overview.get("water_axis", "")) == "crossing"
	var water_z := float(overview.get("water_center_z", 118.0))
	var water_half := float(overview.get("water_width", 34.0)) * 0.5

	var clumps := FastNoiseLite.new()
	clumps.seed = 4411
	clumps.frequency = 0.045
	var meadows := FastNoiseLite.new()
	meadows.seed = 907
	meadows.frequency = 0.012
	var rng := RandomNumberGenerator.new()
	rng.seed = 55173 + hash(str(map.get("id", "")))
	var palette: Array = look["palette"]
	var chunks := int(ceil(_half * 2.0 / CHUNK))
	for cx in chunks:
		for cz in chunks:
			var x0 := -_half + cx * CHUNK
			var z0 := -_half + cz * CHUNK
			var blades: Array = []
			var blooms: Array = []
			var x := x0
			while x < minf(x0 + CHUNK, _half):
				var z := z0
				while z < minf(z0 + CHUNK, _half):
					var p := Vector2(x + rng.randf_range(0.0, SPACING), z + rng.randf_range(0.0, SPACING))
					z += SPACING
					if absf(p.x) > _half - 1.0 or absf(p.y) > _half - 1.0:
						continue
					# Clumped: dense meadow swathes, bare-ish patches between.
					var c := clumps.get_noise_2dv(p) * 0.5 + 0.5
					var m := meadows.get_noise_2dv(p) * 0.5 + 0.5
					var chance := density * smoothstep(0.40, 0.56, c * 0.55 + m * 0.45)
					var road := 1e9
					for r in roads:
						road = minf(road, _segment_distance(p, r[0], r[1]))
					if road < 7.5:
						continue
					chance *= smoothstep(7.5, 10.5, road)
					if water_on:
						var dz := absf(p.y - water_z) if crossing else (water_z - water_half) - p.y
						if (crossing and dz < water_half + 1.5) or (not crossing and dz < 2.0):
							continue
					var near_start := false
					for s in starts:
						if p.distance_to(Vector2(s.x, s.z)) < START_CLEAR:
							near_start = true
							break
					if near_start or rng.randf() > chance:
						continue
					var is_flower := not palette.is_empty() and rng.randf() < float(look["flowers"]) * (0.4 + m)
					var basis := Basis(Vector3.UP, rng.randf() * TAU)
					var sc := rng.randf_range(1.0, 1.65) * (0.8 + 0.4 * c)
					basis = basis.scaled(Vector3(sc, sc * rng.randf_range(0.8, 1.2), sc))
					var t := Transform3D(basis, Vector3(p.x, 0.0, p.y))
					if is_flower:
						var col: Color = palette[rng.randi() % palette.size()]
						blooms.append([t, Color(col.r, col.g, col.b, float(look["dryness"]) * 0.5)])
					else:
						var dry := clampf(float(look["dryness"]) * (1.25 - m) + rng.randf_range(-0.15, 0.15), 0.0, 1.0)
						blades.append([t, Color(0, 0, 0, dry)])
				x += SPACING
			_add_chunk(tuft, blades, "GrassChunk_%d_%d" % [cx, cz])
			_add_chunk(flower, blooms, "FlowerChunk_%d_%d" % [cx, cz])


func _add_chunk(mesh: Mesh, items: Array, chunk_name: String) -> void:
	if items.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = mesh
	mm.instance_count = items.size()
	for i in items.size():
		mm.set_instance_transform(i, items[i][0])
		mm.set_instance_custom_data(i, items[i][1])
	var mmi := MultiMeshInstance3D.new()
	mmi.name = chunk_name
	mmi.multimesh = mm
	mmi.material_override = _material
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)


## Clears the cover inside a circle (world XZ), e.g. under a new building.
func clear_circle(pos: Vector3, radius: float) -> void:
	if _mask_image == null:
		return
	var scale := float(MASK_RES) / (_half * 2.0)
	var cx := (pos.x + _half) * scale
	var cz := (pos.z + _half) * scale
	var r := radius * scale
	var feather := 1.5 * scale
	for y in range(maxi(0, int(cz - r - feather - 1.0)), mini(MASK_RES, int(cz + r + feather + 2.0))):
		for x in range(maxi(0, int(cx - r - feather - 1.0)), mini(MASK_RES, int(cx + r + feather + 2.0))):
			var d := Vector2(x + 0.5 - cx, y + 0.5 - cz).length()
			var v := 1.0 - smoothstep(r, r + feather, d)
			if v > _mask_image.get_pixel(x, y).r:
				_mask_image.set_pixel(x, y, Color(v, 0, 0))
	_mask_texture.update(_mask_image)


static func _segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var t := clampf((p - a).dot(ab) / maxf(ab.length_squared(), 0.0001), 0.0, 1.0)
	return p.distance_to(a + ab * t)


func _make_tuft_mesh(with_flowers: bool) -> ArrayMesh:
	# A tuft of tapered, curved blades radiating from the root; the flower
	# variant is shorter and carries small upward-facing heads on some blades.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7 if with_flowers else 3
	var count := 6 if with_flowers else 9
	for b in count:
		var ang := TAU * float(b) / float(count) + rng.randf_range(-0.3, 0.3)
		var dir := Vector3(cos(ang), 0.0, sin(ang))
		var side := Vector3(-dir.z, 0.0, dir.x)
		var height := rng.randf_range(0.22, 0.34) if with_flowers else rng.randf_range(0.26, 0.48)
		var lean := rng.randf_range(0.10, 0.28) * height
		var width := rng.randf_range(0.035, 0.055)
		var root := dir * rng.randf_range(0.0, 0.06)
		var rows := [0.0, 0.45, 0.8]
		var pts: Array = []
		for t: float in rows:
			var c: Vector3 = root + dir * lean * t * t + Vector3.UP * height * t
			var w: float = width * (1.0 - t * 0.85)
			pts.append([c - side * w, c + side * w, t])
		var tip: Vector3 = root + dir * lean + Vector3.UP * height
		for i in rows.size() - 1:
			var a: Array = pts[i]
			var n: Array = pts[i + 1]
			_tri(st, a[0], a[1], n[1], a[2], a[2], n[2])
			_tri(st, a[0], n[1], n[0], a[2], n[2], n[2])
		var last: Array = pts[rows.size() - 1]
		_tri(st, last[0], last[1], tip, last[2], last[2], 1.0)
		if with_flowers and b % 2 == 0:
			var hs := rng.randf_range(0.035, 0.05)
			var hc := tip + Vector3.UP * 0.01
			var h0 := hc + Vector3(-hs, 0, -hs)
			var h1 := hc + Vector3(hs, 0, -hs)
			var h2 := hc + Vector3(hs, 0, hs)
			var h3 := hc + Vector3(-hs, 0, hs)
			_tri(st, h0, h1, h2, 1.0, 1.0, 1.0, true)
			_tri(st, h0, h2, h3, 1.0, 1.0, 1.0, true)
	st.generate_normals()
	return st.commit()


func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, ha: float, hb: float, hc: float, head := false) -> void:
	var ux := 2.0 if head else 0.0
	st.set_uv(Vector2(ux, ha)); st.add_vertex(a)
	st.set_uv(Vector2(ux, hb)); st.add_vertex(b)
	st.set_uv(Vector2(ux, hc)); st.add_vertex(c)
