extends SceneTree
## Builds broadleaf_oak_crown.scn (plan 420): a broadleaf oak whose crown is
## made of leaf cards cut from a leaf-spray texture painted here in code, set
## in rounded tufts around spreading limbs. Two surfaces: bark, leaves. The
## leaf material is alpha scissor; foliage_wind discards the cut-outs.

var rng := RandomNumberGenerator.new()

func _initialize() -> void:
	rng.seed = int(OS.get_environment("TREE_SEED")) if OS.get_environment("TREE_SEED") != "" else 11
	var atlas := _paint_leaf_atlas(512)
	var bark := SurfaceTool.new()
	bark.begin(Mesh.PRIMITIVE_TRIANGLES)
	var leaves := SurfaceTool.new()
	leaves.begin(Mesh.PRIMITIVE_TRIANGLES)
	var trunk_top := Vector3(0.18, 3.0, -0.1)
	_limb(bark, Vector3(0, -0.3, 0), trunk_top, 0.46, 0.3, 9, true)
	var crown_c := Vector3(0.1, 5.4, 0.0)
	var crown_r := Vector3(3.5, 2.5, 3.3)
	var tips: Array = []
	var limbs := 6
	for i in limbs:
		var az := TAU * float(i) / limbs + rng.randf_range(-0.35, 0.35)
		var out := Vector3(cos(az), 0, sin(az))
		var start := trunk_top + Vector3(0, rng.randf_range(-0.5, 0.2), 0)
		var end := crown_c + Vector3(out.x * crown_r.x * rng.randf_range(0.55, 0.8), rng.randf_range(-0.9, 0.9), out.z * crown_r.z * rng.randf_range(0.55, 0.8))
		_limb(bark, start, end, 0.24, 0.07, 6, false)
		tips.append(end)
		for k in 2:
			var t := rng.randf_range(0.4, 0.75)
			var from := start.lerp(end, t)
			var side := out.rotated(Vector3.UP, (1.0 if k == 0 else -1.0) * rng.randf_range(0.6, 1.1))
			var to := from + side * rng.randf_range(1.2, 1.9) + Vector3(0, rng.randf_range(0.4, 1.2), 0)
			_limb(bark, from, to, 0.1, 0.035, 5, false)
			tips.append(to)
	var clumps: Array = []
	for t in tips:
		clumps.append(t)
	while clumps.size() < 52:
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1))
		if d.length() > 1.0 or d.length() < 0.2 or d.y < -0.55:
			continue
		clumps.append(crown_c + Vector3(d.x * crown_r.x, d.y * crown_r.y, d.z * crown_r.z))
	var cards := 0
	for c: Vector3 in clumps:
		var cr := rng.randf_range(0.75, 1.05)
		for j in 11:
			var dir := Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.45, 1), rng.randf_range(-1, 1)).normalized()
			_card(leaves, c + dir * cr * rng.randf_range(0.35, 0.8), dir, crown_c, crown_r)
			cards += 1
	var mesh := ArrayMesh.new()
	bark.generate_normals()
	bark.commit(mesh)
	leaves.index()
	leaves.commit(mesh)
	var bark_mat := StandardMaterial3D.new()
	bark_mat.albedo_color = Color(0.27, 0.21, 0.16)
	bark_mat.roughness = 1.0
	bark_mat.vertex_color_use_as_albedo = true
	var leaf_mat := StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(1, 1, 1)
	leaf_mat.albedo_texture = ImageTexture.create_from_image(atlas)
	leaf_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	leaf_mat.alpha_scissor_threshold = 0.45
	leaf_mat.roughness = 0.85
	leaf_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	leaf_mat.vertex_color_use_as_albedo = true
	mesh.surface_set_material(0, bark_mat)
	mesh.surface_set_material(1, leaf_mat)
	var root := Node3D.new()
	root.name = "BroadleafOak"
	var mi := MeshInstance3D.new()
	mi.name = "Oak"
	mi.mesh = mesh
	root.add_child(mi)
	mi.owner = root
	# A soft ground shadow: decor casts no real shadows, and without one the
	# crown floated over the meadow.
	var blob := MeshInstance3D.new()
	blob.name = "GroundShadow"
	var quad := QuadMesh.new()
	quad.size = Vector2(9.0, 8.4)
	blob.mesh = quad
	blob.rotation_degrees = Vector3(-90, 0, 0)
	# Oaks are sunk 6.5% (lone) to 12% (woods) of their height: the shadow sits
	# at the woods depth so it shows in both.
	blob.position = Vector3(1.1, 0.85, 0.9)
	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0.62))
	grad.set_color(1, Color(0, 0, 0, 0.0))
	grad.add_point(0.55, Color(0, 0, 0, 0.42))
	var gtex := GradientTexture2D.new()
	gtex.gradient = grad
	gtex.fill = GradientTexture2D.FILL_RADIAL
	gtex.fill_from = Vector2(0.5, 0.5)
	gtex.fill_to = Vector2(1.0, 0.5)
	gtex.width = 128
	gtex.height = 128
	var shade_mat := StandardMaterial3D.new()
	shade_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shade_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shade_mat.albedo_texture = gtex
	quad.material = shade_mat
	blob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(blob)
	blob.owner = root
	var packed := PackedScene.new()
	packed.pack(root)
	var out_path := OS.get_environment("TREE_OUT") if OS.get_environment("TREE_OUT") != "" else "res://broadleaf_oak_crown.scn"
	if OS.get_environment("TREE_ATLAS_PNG") != "":
		atlas.save_png(OS.get_environment("TREE_ATLAS_PNG"))
	print("SAVE ", ResourceSaver.save(packed, out_path), " cards=", cards, " verts=", mesh.surface_get_array_len(0) + mesh.surface_get_array_len(1))
	quit(0)


## A spray of oak leaves on a transparent ground: lobed blades with a midrib,
## each its own green, the earlier (lower) ones darker as they sit beneath.
func _paint_leaf_atlas(size: int) -> Image:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.18, 0.26, 0.1, 0.0))
	var count := 110
	for i in count:
		var t := float(i) / count
		var c := (Vector2(0.5, 0.5) + Vector2.from_angle(rng.randf() * TAU) * 0.34 * sqrt(rng.randf())) * size
		var ang := rng.randf() * TAU
		var length := rng.randf_range(0.11, 0.16) * size
		var width := length * rng.randf_range(0.5, 0.62)
		var green := Color(0.34, 0.45, 0.16).lerp(Color(0.62, 0.67, 0.28), rng.randf())
		green = green.lerp(Color(0.5, 0.52, 0.2), rng.randf() * 0.25)
		var depth := lerpf(0.72, 1.12, t)
		var along := Vector2(cos(ang), sin(ang))
		var side := Vector2(-along.y, along.x)
		var r := int(length * 0.6) + 2
		for y in range(maxi(0, int(c.y) - r), mini(size, int(c.y) + r)):
			for x in range(maxi(0, int(c.x) - r), mini(size, int(c.x) + r)):
				var d := Vector2(x + 0.5, y + 0.5) - c
				var u := d.dot(along) / length
				var v := d.dot(side) / width
				if absf(u) > 0.5:
					continue
				# Oak lobes: the outline swells and pinches along the blade.
				var outline := sin(PI * (u + 0.5)) * (0.42 + 0.1 * sin((u + 0.5) * TAU * 3.0))
				var edge := outline - absf(v)
				if edge <= 0.0:
					continue
				var a := clampf(edge * 9.0, 0.0, 1.0)
				var vein := 1.0 - clampf(absf(v) * 22.0, 0.0, 1.0)
				var shade := depth * (0.84 + 0.22 * (u + 0.5)) * (1.0 - 0.25 * clampf(1.0 - edge * 6.0, 0.0, 1.0))
				var col := green * shade
				col = col.lerp(Color(0.62, 0.68, 0.36) * depth, vein * 0.45)
				var old := img.get_pixel(x, y)
				var mixed := Color(col.r, col.g, col.b, a)
				if old.a > 0.0:
					mixed = Color(lerpf(old.r, col.r, a), lerpf(old.g, col.g, a), lerpf(old.b, col.b, a), maxf(old.a, a))
				img.set_pixel(x, y, mixed)
	img.generate_mipmaps()
	return img


func _card(st: SurfaceTool, p: Vector3, tuft: Vector3, crown_c: Vector3, crown_r: Vector3) -> void:
	var rel := p - crown_c
	var outward := Vector3(rel.x / crown_r.x, rel.y / crown_r.y, rel.z / crown_r.z)
	var shell := clampf(outward.length(), 0.0, 1.3)
	var n := (outward.normalized() * 0.5 + tuft * 0.35 + Vector3.UP * 0.35).normalized()
	var face := (tuft + Vector3(rng.randf_range(-0.5, 0.5), rng.randf_range(-0.2, 0.6), rng.randf_range(-0.5, 0.5))).normalized()
	var ref := Vector3.UP if absf(face.y) < 0.92 else Vector3.RIGHT
	var a := face.cross(ref).normalized().rotated(face, rng.randf() * TAU)
	var b := face.cross(a).normalized()
	var half := rng.randf_range(0.7, 0.95)
	var light := clampf(0.70 + 0.40 * shell + 0.22 * outward.y + 0.3 * tuft.y, 0.5, 1.55) * rng.randf_range(0.9, 1.08)
	var warm := clampf(outward.y, 0.0, 1.0) * 0.18
	var col := Color(light * (1.0 + warm * 1.2), light * (1.0 + warm * 0.5), light * (1.0 - warm))
	var corners := [p - a * half - b * half, p + a * half - b * half, p + a * half + b * half, p - a * half + b * half]
	var uvs := [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
	# One of four turns of the spray, so neighbouring cards differ.
	var turn := rng.randi() % 4
	for tri in [[0, 1, 2], [0, 2, 3], [0, 2, 1], [0, 3, 2]]:
		for k in tri:
			st.set_color(col)
			st.set_normal(n)
			st.set_uv(uvs[(k + turn) % 4])
			st.add_vertex(corners[k])


func _limb(st: SurfaceTool, a: Vector3, b: Vector3, r0: float, r1: float, sides: int, flare: bool) -> void:
	var axis := (b - a)
	var len := axis.length()
	var dir := axis / len
	var ref := Vector3.UP if absf(dir.y) < 0.9 else Vector3.RIGHT
	var u := dir.cross(ref).normalized()
	var v := dir.cross(u).normalized()
	var segs := 6
	var bend := Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.3, 0.3), rng.randf_range(-1, 1)) * len * 0.06
	var rings: Array = []
	for s in segs + 1:
		var t := float(s) / segs
		var centre := a + axis * t + bend * sin(t * PI)
		var r := lerpf(r0, r1, t)
		if flare:
			r *= 1.0 + 0.9 * pow(1.0 - clampf(t * 3.0, 0.0, 1.0), 2.0)
		var ring: Array = []
		for k in sides:
			var ang := TAU * float(k) / sides
			var bump := 1.0 + (0.12 * sin(ang * 3.0 + t * 5.0) if flare else 0.0)
			ring.append(centre + (u * cos(ang) + v * sin(ang)) * r * bump)
		rings.append(ring)
	for s in segs:
		for k in sides:
			var k1 := (k + 1) % sides
			var shade := 0.78 + 0.22 * rng.randf()
			var foot := lerpf(0.7, 1.0, clampf((a.y + axis.y * float(s) / segs) / 2.0, 0.0, 1.0))
			var col := Color(shade * foot, shade * foot, shade * foot)
			var p00: Vector3 = rings[s][k]
			var p01: Vector3 = rings[s][k1]
			var p10: Vector3 = rings[s + 1][k]
			var p11: Vector3 = rings[s + 1][k1]
			for p in [p00, p10, p11, p00, p11, p01]:
				st.set_color(col)
				st.add_vertex(p)
