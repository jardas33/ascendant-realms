extends SceneTree
## Builds desert_palm.scn: a date palm with a curved, ringed trunk, a crown
## of arching fronds cut into folded leaflets, a skirt of dead fronds and
## clusters of dates. Three surfaces (trunk, green fronds, dry fronds+dates).
## Run headless: PALM_OUT=res://assets/environment/vegetation/desert_palm.scn
## (seed 7, lean 0.9) and PALM_SEED=11 PALM_LEAN=0.35 PALM_OUT=...desert_palm_b.scn.

var rng := RandomNumberGenerator.new()

func _initialize() -> void:
	rng.seed = int(OS.get_environment("PALM_SEED")) if OS.get_environment("PALM_SEED") != "" else 7
	var lean := float(OS.get_environment("PALM_LEAN")) if OS.get_environment("PALM_LEAN") != "" else 0.9
	var trunk := SurfaceTool.new()
	trunk.begin(Mesh.PRIMITIVE_TRIANGLES)
	var green := SurfaceTool.new()
	green.begin(Mesh.PRIMITIVE_TRIANGLES)
	var dry := SurfaceTool.new()
	dry.begin(Mesh.PRIMITIVE_TRIANGLES)
	var height := 7.0
	var rings := 22
	var sides := 10
	var centre := func(t: float) -> Vector3:
		return Vector3(lean * t * t, height * t, 0.25 * lean * sin(t * 2.0))
	var top: Vector3 = centre.call(1.0)
	# Trunk: rings of old leaf bases, each ring flaring then pinching.
	for r in rings:
		var t0 := float(r) / rings
		var t1 := float(r + 1) / rings
		var c0: Vector3 = centre.call(t0)
		var c1: Vector3 = centre.call(t1)
		var base_r0 := lerpf(0.34, 0.2, t0)
		var base_r1 := lerpf(0.34, 0.2, t1)
		for s in sides:
			var a0 := TAU * float(s) / sides
			var a1 := TAU * float(s + 1) / sides
			# Bottom of each ring is pinched, its top flared (the leaf scar).
			var p00 := c0 + Vector3(cos(a0), 0, sin(a0)) * base_r0 * 0.9
			var p01 := c0 + Vector3(cos(a1), 0, sin(a1)) * base_r0 * 0.9
			var p10 := c1 + Vector3(cos(a0), 0, sin(a0)) * base_r1 * 1.06
			var p11 := c1 + Vector3(cos(a1), 0, sin(a1)) * base_r1 * 1.06
			var shade := 0.82 + 0.18 * float(r % 2)
			_quad(trunk, p00, p01, p11, p10, Color(shade, shade, shade))
	# Trunk top cap (hidden by the crown).
	# Crown: fronds around the top.
	var fronds := 14
	for f in fronds:
		var az := TAU * float(f) / fronds + rng.randf_range(-0.2, 0.2)
		var rise := rng.randf_range(0.15, 0.95) if f % 2 == 0 else rng.randf_range(-0.1, 0.5)
		_frond(green, top, az, rise, rng.randf_range(3.6, 4.6), 1.5, Color(1, 1, 1))
	# A few young spears standing up in the middle.
	for f in 3:
		_frond(green, top + Vector3(0, 0.1, 0), TAU * rng.randf(), 1.25, rng.randf_range(2.0, 2.6), 0.6, Color(1.08, 1.12, 1.0))
	# Dead fronds hanging down the trunk.
	for f in 6:
		_frond(dry, top - Vector3(0, 0.35, 0), TAU * float(f) / 6.0 + 0.3, -0.9, rng.randf_range(2.2, 3.0), 0.5, Color(0.9, 0.9, 0.9))
	# Date clusters under the crown.
	for k in 3:
		var a := TAU * float(k) / 3.0 + 0.5
		var hang := top + Vector3(cos(a) * 0.45, -0.5, sin(a) * 0.45)
		for d in 9:
			var p := hang + Vector3(rng.randf_range(-0.22, 0.22), rng.randf_range(-0.45, 0.05), rng.randf_range(-0.22, 0.22))
			_blob(dry, p, 0.09, Color(1.25, 0.75, 0.45))
	var mesh := ArrayMesh.new()
	trunk.generate_normals()
	trunk.commit(mesh)
	green.commit(mesh)
	dry.commit(mesh)
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color(0.46, 0.36, 0.26)
	bark.roughness = 1.0
	bark.vertex_color_use_as_albedo = true
	var leaf := StandardMaterial3D.new()
	leaf.albedo_color = Color(0.27, 0.42, 0.14)
	leaf.roughness = 0.85
	leaf.cull_mode = BaseMaterial3D.CULL_DISABLED
	leaf.vertex_color_use_as_albedo = true
	var husk := StandardMaterial3D.new()
	husk.albedo_color = Color(0.58, 0.45, 0.26)
	husk.roughness = 0.95
	husk.cull_mode = BaseMaterial3D.CULL_DISABLED
	husk.vertex_color_use_as_albedo = true
	mesh.surface_set_material(0, bark)
	mesh.surface_set_material(1, leaf)
	mesh.surface_set_material(2, husk)
	var root := Node3D.new()
	root.name = "DesertPalm"
	var mi := MeshInstance3D.new()
	mi.name = "Palm"
	mi.mesh = mesh
	root.add_child(mi)
	mi.owner = root
	var packed := PackedScene.new()
	packed.pack(root)
	var out := OS.get_environment("PALM_OUT") if OS.get_environment("PALM_OUT") != "" else "res://desert_palm.scn"
	print("SAVE ", ResourceSaver.save(packed, out), " verts=", mesh.surface_get_array_len(0) + mesh.surface_get_array_len(1) + mesh.surface_get_array_len(2))
	quit(0)


func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, col: Color) -> void:
	for p in [a, b, c, a, c, d]:
		st.set_color(col)
		st.add_vertex(p)


func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color) -> void:
	var n := (b - a).cross(c - a).normalized()
	if n.y < 0.0:
		n = -n
	# Leaves light from above whichever side is seen: one normal, both faces.
	n = (n + Vector3.UP * 0.6).normalized()
	# Both windings, so the leaf shows from below and behind with any
	# material's back-face culling.
	for p in [a, b, c, a, c, b]:
		st.set_color(col)
		st.set_normal(n)
		st.add_vertex(p)


## One frond: a spine leaving the crown at azimuth `az`, starting `rise`
## radians above level and bending down under its own weight, with folded
## leaflets down both sides, longest in the middle.
func _frond(st: SurfaceTool, from: Vector3, az: float, rise: float, length: float, droop: float, col: Color) -> void:
	var out := Vector3(cos(az), 0, sin(az))
	var side := Vector3(-sin(az), 0, cos(az))
	var steps := 14
	var p := from
	var prev := p
	var seg := length / steps
	for i in steps:
		var s := float(i + 1) / steps
		var pitch := rise - droop * s * s
		var dir := (out * cos(pitch) + Vector3.UP * sin(pitch)).normalized()
		p = prev + dir * seg
		var mid := (prev + p) * 0.5
		# Leaflets: none on the bare stalk near the crown, longest mid-frond.
		var w := 0.0 if s < 0.16 else 0.95 * sin(PI * clampf((s - 0.12) / 0.92, 0.0, 1.0))
		if w > 0.02:
			var shade := col * (0.85 + 0.25 * rng.randf())
			for k: float in [-1.0, 1.0]:
				# Each leaflet is folded up along the spine and points forward.
				var tip: Vector3 = mid + side * k * w + dir * (seg * 1.4) - Vector3.UP * (0.18 * w)
				var fold: Vector3 = mid + side * k * w * 0.35 + Vector3.UP * 0.07
				_tri(st, prev, fold, tip, shade)
				_tri(st, fold, p, tip, shade * 0.92)
		# The rachis itself, a thin ribbon.
		var up := Vector3.UP * 0.04
		_tri(st, prev - side * 0.04, p - side * 0.03, prev + side * 0.04 + up, col * 0.8)
		_tri(st, prev + side * 0.04 + up, p - side * 0.03, p + side * 0.03 + up, col * 0.8)
		prev = p


func _blob(st: SurfaceTool, at: Vector3, r: float, col: Color) -> void:
	# An octahedron is enough at RTS distance.
	var v := [Vector3(r, 0, 0), Vector3(-r, 0, 0), Vector3(0, r * 1.3, 0), Vector3(0, -r * 1.3, 0), Vector3(0, 0, r), Vector3(0, 0, -r)]
	var faces := [[0, 2, 4], [4, 2, 1], [1, 2, 5], [5, 2, 0], [4, 3, 0], [1, 3, 4], [5, 3, 1], [0, 3, 5]]
	for f in faces:
		_tri(st, at + v[f[0]], at + v[f[1]], at + v[f[2]], col)
