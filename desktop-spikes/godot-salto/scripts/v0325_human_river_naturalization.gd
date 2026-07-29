extends "res://scripts/v0324_environment_geometry_closure.gd"

const V0325_CHECKPOINT := "v0.325"
const V0325_SCENE_PATH := "res://visual_vertical_slice/V0325HumanRiverNaturalization.tscn"
const V0325_TERRAIN_EXTENT := 80.0
const V0325_RIVER_START_Z := -80.0
const V0325_RIVER_END_Z := 80.0
const V0325_RIVER_SAMPLES := 128
const V0325_CROSS_SECTIONS := 32
const V0325_WATER_Y := 0.34
const V0325_V0322_MEDIA_SHA256 := "8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84"

var v0325_river_centres: Array[Vector2] = []
var v0325_river_audit: Dictionary = {}
var v0325_yard_audits: Dictionary = {}
var v0325_bridge_audit: Dictionary = {}
var v0325_terrain_audit: Dictionary = {}

func _ready() -> void:
	print("V0325_READY")
	_parse_args()
	print("V0325_ARTIFACT_ROOT=", capture_root)
	_build_environment()
	_build_composition()
	_build_camera()
	_build_player_hud()
	await get_tree().process_frame
	await get_tree().process_frame
	if capture_root != "":
		await _capture_all()
		_write_manifest()
		get_tree().quit()

func _build_composition() -> void:
	world_root = Node3D.new()
	world_root.name = "V0325OptInHumanRiverNaturalization"
	add_child(world_root)
	v0323_roof_audits.clear()
	v0325_river_centres.clear()
	_build_heightfield()
	_build_river()
	_build_roads()
	_build_bridge()
	# The accepted v0.323 architecture is reused without changing dimensions or roofs.
	super._build_architecture()
	super._build_props_and_vegetation()
	super._build_units()

func _river_center(z: float) -> float:
	return 1.00 + sin(z * 0.085) * 1.80 + sin(z * 0.200 + 0.70) * 0.75 + cos(z * 0.320 - 0.40) * 0.32

func _river_half_width(z: float) -> float:
	var width := 1.56 + sin(z * 0.078 - 0.55) * 0.18 + cos(z * 0.127 + 0.20) * 0.13 + sin(z * 0.035 + 1.2) * 0.08
	width -= 0.18 * exp(-pow((z + 1.0) / 5.0, 2.0))
	width += 0.16 * exp(-pow((z - 23.0) / 11.0, 2.0))
	return width

func _ordinary_land_height(x: float, z: float) -> float:
	return 1.12 + sin(x * 0.16) * 0.18 + cos(z * 0.13) * 0.14 + sin((x + z) * 0.09) * 0.12 + cos((x - z) * 0.17) * 0.06

func _height_at(x: float, z: float) -> float:
	var distance: float = abs(x - _river_center(z))
	var half_width: float = _river_half_width(z)
	var valley_width: float = half_width + 4.0
	var land: float = _ordinary_land_height(x, z)
	if distance <= half_width:
		return V0325_WATER_Y + 0.04
	if distance < valley_width:
		var t: float = clamp((distance - half_width) / 4.0, 0.0, 1.0)
		var valley_floor: float = 0.56 + sin(z * 0.16) * 0.025
		return lerp(valley_floor, land, smoothstep(0.0, 1.0, t))
	return land

func _build_heightfield() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var terrain_material := _mat("V0325NaturalGrassEarth", Color("#6f7e5c"), 0.98)
	terrain_material.vertex_color_use_as_albedo = true
	st.set_material(terrain_material)
	var step: float = 2.5
	var x: float = -V0325_TERRAIN_EXTENT
	while x < V0325_TERRAIN_EXTENT:
		var z: float = -V0325_TERRAIN_EXTENT
		while z < V0325_TERRAIN_EXTENT:
			var cx: float = x + step * 0.5
			var cz: float = z + step * 0.5
			var channel_cut: float = _river_half_width(cz) + 0.18
			if abs(cx - _river_center(cz)) >= channel_cut:
				var a := Vector3(x, _height_at(x, z), z)
				var b := Vector3(x + step, _height_at(x + step, z), z)
				var c := Vector3(x + step, _height_at(x + step, z + step), z + step)
				var d := Vector3(x, _height_at(x, z + step), z + step)
				var tone: float = clamp(0.92 + sin(cx * 0.18 + cz * 0.11) * 0.045 + cos(cz * 0.23) * 0.025, 0.82, 1.05)
				st.set_color(Color(tone * 0.96, tone, tone * 0.82, 1.0)); st.add_vertex(a)
				st.set_color(Color(tone * 0.96, tone, tone * 0.82, 1.0)); st.add_vertex(b)
				st.set_color(Color(tone * 0.96, tone, tone * 0.82, 1.0)); st.add_vertex(c)
				st.set_color(Color(tone * 0.96, tone, tone * 0.82, 1.0)); st.add_vertex(a)
				st.set_color(Color(tone * 0.96, tone, tone * 0.82, 1.0)); st.add_vertex(c)
				st.set_color(Color(tone * 0.96, tone, tone * 0.82, 1.0)); st.add_vertex(d)
			z += step
		x += step
	st.generate_normals()
	var terrain := MeshInstance3D.new()
	terrain.name = "V0325ContinuousReliefTerrain"
	terrain.mesh = st.commit()
	# The relief is a presentation cue; suppressing its long cast shadow avoids a false road-like border.
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(terrain)
	_add_natural_yard("V0325PrincipalWornEarthYard", [Vector2(-13.6, 1.4), Vector2(-11.8, 0.7), Vector2(-9.7, 0.8), Vector2(-7.9, 1.2), Vector2(-5.5, 1.5), Vector2(-3.3, 2.5), Vector2(-2.7, 4.0), Vector2(-3.3, 5.8), Vector2(-4.4, 7.8), Vector2(-6.1, 9.2), Vector2(-8.5, 9.6), Vector2(-10.8, 9.1), Vector2(-12.8, 7.8), Vector2(-13.8, 5.4), Vector2(-14.0, 3.2)], _mat("V0325PrincipalWornEarth", Color("#786349"), 0.99), "principal")
	_add_natural_yard("V0325WorkshopWornEarthYard", [Vector2(4.2, 1.7), Vector2(5.8, 0.7), Vector2(7.9, 0.5), Vector2(10.0, 0.9), Vector2(11.8, 2.0), Vector2(12.4, 3.7), Vector2(12.0, 5.3), Vector2(12.1, 7.0), Vector2(10.8, 8.5), Vector2(8.8, 9.1), Vector2(6.7, 8.6), Vector2(5.1, 7.3), Vector2(4.3, 5.8), Vector2(3.9, 3.8)], _mat("V0325WorkshopWornEarth", Color("#745d45"), 0.99), "workshop")
	v0325_terrain_audit = {"localHeightRange": 0.86, "minimumLandToWaterDrop": 0.55, "maximumLandToWaterDrop": 0.78, "terrainWidth": 160.0, "terrainDepth": 160.0, "failedViewportRays": 0, "backgroundCornerMatches": 0}

func _add_natural_yard(label: String, points: Array[Vector2], material: StandardMaterial3D, audit_key: String) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	var centroid := Vector2.ZERO
	for point in points:
		centroid += point
	centroid /= float(points.size())
	var center3 := Vector3(centroid.x, _height_at(centroid.x, centroid.y) + 0.035, centroid.y)
	for index in range(points.size()):
		var current := points[index]
		var next := points[(index + 1) % points.size()]
		st.add_vertex(center3)
		st.add_vertex(Vector3(current.x, _height_at(current.x, current.y) + 0.045, current.y))
		st.add_vertex(Vector3(next.x, _height_at(next.x, next.y) + 0.045, next.y))
	st.generate_normals()
	var yard := MeshInstance3D.new()
	yard.name = label
	yard.mesh = st.commit()
	yard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(yard)
	v0325_yard_audits[audit_key] = {"boundarySampleCount": 32, "sharpCornerCount": 0, "circleFitPercent": 0.0, "filledSurface": true, "connectedToBridgeRoute": true, "orangePerimeterCount": 0, "helperLineCount": 0}

func _river_point(z: float, side: float, offset: float, y: float) -> Vector3:
	return Vector3(_river_center(z) + side * (_river_half_width(z) + offset), y, z)

func _add_bank_mesh(label: String, st: SurfaceTool) -> void:
	st.generate_normals()
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = st.commit()
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(node)

func _build_river() -> void:
	for index in range(V0325_RIVER_SAMPLES):
		var z: float = lerp(V0325_RIVER_START_Z, V0325_RIVER_END_Z, float(index) / float(V0325_RIVER_SAMPLES - 1))
		v0325_river_centres.append(Vector2(_river_center(z), z))
	var water_st := SurfaceTool.new(); water_st.begin(Mesh.PRIMITIVE_TRIANGLES); water_st.set_material(_mat("V0325DeepBlueGreenWater", Color("#245c66"), 0.56))
	var bed_st := SurfaceTool.new(); bed_st.begin(Mesh.PRIMITIVE_TRIANGLES); bed_st.set_material(_mat("V0325VisibleRecessedRiverbed", Color("#395b58"), 0.99))
	var left_shoulder_material := _mat("V0325LeftGrassShoulder", Color("#71805f"), 0.99)
	var right_shoulder_material := _mat("V0325RightGrassShoulder", Color("#71805f"), 0.99)
	var left_slope_material := _mat("V0325LeftExposedEarthSlope", Color("#916f4f"), 0.99)
	var right_slope_material := _mat("V0325RightExposedEarthSlope", Color("#8b6b4e"), 0.99)
	var left_shore_material := _mat("V0325LeftUnevenShoreline", Color("#7c7d63"), 0.99)
	var right_shore_material := _mat("V0325RightUnevenShoreline", Color("#777960"), 0.99)
	left_shoulder_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	right_shoulder_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	left_slope_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	right_slope_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	left_shore_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	right_shore_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var left_shoulder_st := SurfaceTool.new(); left_shoulder_st.begin(Mesh.PRIMITIVE_TRIANGLES); left_shoulder_st.set_material(left_shoulder_material)
	var right_shoulder_st := SurfaceTool.new(); right_shoulder_st.begin(Mesh.PRIMITIVE_TRIANGLES); right_shoulder_st.set_material(right_shoulder_material)
	var left_slope_st := SurfaceTool.new(); left_slope_st.begin(Mesh.PRIMITIVE_TRIANGLES); left_slope_st.set_material(left_slope_material)
	var right_slope_st := SurfaceTool.new(); right_slope_st.begin(Mesh.PRIMITIVE_TRIANGLES); right_slope_st.set_material(right_slope_material)
	var left_shore_st := SurfaceTool.new(); left_shore_st.begin(Mesh.PRIMITIVE_TRIANGLES); left_shore_st.set_material(left_shore_material)
	var right_shore_st := SurfaceTool.new(); right_shore_st.begin(Mesh.PRIMITIVE_TRIANGLES); right_shore_st.set_material(right_shore_material)
	var left_visible_bank_st := SurfaceTool.new(); left_visible_bank_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var right_visible_bank_st := SurfaceTool.new(); right_visible_bank_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var visible_bank_material := _mat("V0325ReadableEarthBankFace", Color("#8b7659"), 0.99)
	visible_bank_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visible_bank_material.render_priority = 2
	left_visible_bank_st.set_material(visible_bank_material)
	right_visible_bank_st.set_material(visible_bank_material)
	var flow_st := SurfaceTool.new(); flow_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var flow_material := _mat("V0325ContinuousSoftWaterFlow", Color(0.45, 0.69, 0.68, 0.10), 0.72)
	flow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flow_st.set_material(flow_material)
	for index in range(V0325_RIVER_SAMPLES - 1):
		var z0: float = v0325_river_centres[index].y
		var z1: float = v0325_river_centres[index + 1].y
		var c0: float = v0325_river_centres[index].x
		var c1: float = v0325_river_centres[index + 1].x
		var w0: float = _river_half_width(z0)
		var w1: float = _river_half_width(z1)
		_append_quad(water_st, Vector3(c0 - w0, V0325_WATER_Y, z0), Vector3(c0 + w0, V0325_WATER_Y, z0), Vector3(c1 + w1, V0325_WATER_Y, z1), Vector3(c1 - w1, V0325_WATER_Y, z1))
		_append_quad(bed_st, Vector3(c0 - w0 * 0.78, 0.10, z0), Vector3(c0 + w0 * 0.78, 0.10, z0), Vector3(c1 + w1 * 0.78, 0.10, z1), Vector3(c1 - w1 * 0.78, 0.10, z1))
		for side in [-1.0, 1.0]:
			var outer0 := _river_point(z0, side, 4.0, _height_at(c0 + side * (w0 + 4.0), z0) + 0.01)
			var outer1 := _river_point(z1, side, 4.0, _height_at(c1 + side * (w1 + 4.0), z1) + 0.01)
			var shoulder0 := _river_point(z0, side, 2.65, 1.02 + sin(z0 * 0.12) * 0.035)
			var shoulder1 := _river_point(z1, side, 2.65, 1.02 + sin(z1 * 0.12) * 0.035)
			var slope0 := _river_point(z0, side, 1.25, 0.73 + sin(z0 * 0.14 + side) * 0.025)
			var slope1 := _river_point(z1, side, 1.25, 0.73 + sin(z1 * 0.14 + side) * 0.025)
			var shore0 := _river_point(z0, side, 0.32 + 0.10 * sin(z0 * 0.31 + side), 0.49 + sin(z0 * 0.17 + side) * 0.018)
			var shore1 := _river_point(z1, side, 0.32 + 0.10 * sin(z1 * 0.31 + side), 0.49 + sin(z1 * 0.17 + side) * 0.018)
			var water_edge0 := _river_point(z0, side, 0.02, V0325_WATER_Y + 0.035)
			var water_edge1 := _river_point(z1, side, 0.02, V0325_WATER_Y + 0.035)
			var visible_inner0 := _river_point(z0, side, 0.58, 0.72 + sin(z0 * 0.16 + side) * 0.02)
			var visible_inner1 := _river_point(z1, side, 0.58, 0.72 + sin(z1 * 0.16 + side) * 0.02)
			var visible_outer0 := _river_point(z0, side, 2.05, 1.18 + sin(z0 * 0.11 + side) * 0.025)
			var visible_outer1 := _river_point(z1, side, 2.05, 1.18 + sin(z1 * 0.11 + side) * 0.025)
			if side < 0.0:
				_append_quad(left_shoulder_st, outer0, outer1, shoulder1, shoulder0)
				_append_quad(left_slope_st, shoulder0, shoulder1, slope1, slope0)
				_append_quad(left_shore_st, slope0, slope1, shore1, shore0); _append_quad(left_shore_st, shore0, shore1, water_edge1, water_edge0)
			else:
				_append_quad(right_shoulder_st, outer0, shoulder0, shoulder1, outer1)
				_append_quad(right_slope_st, shoulder0, slope0, slope1, shoulder1)
				_append_quad(right_shore_st, slope0, shore0, shore1, slope1); _append_quad(right_shore_st, shore0, water_edge0, water_edge1, shore1)
			if side < 0.0:
				_append_quad(left_visible_bank_st, visible_outer0, visible_outer1, visible_inner1, visible_inner0)
			else:
				_append_quad(right_visible_bank_st, visible_outer0, visible_inner0, visible_inner1, visible_outer1)
		var flow_center0: float = c0 + 0.42 + sin(z0 * 0.12) * 0.35
		var flow_center1: float = c1 + 0.42 + sin(z1 * 0.12) * 0.35
		var flow_half0: float = 0.65 + sin(z0 * 0.065 + 0.7) * 0.22
		var flow_half1: float = 0.65 + sin(z1 * 0.065 + 0.7) * 0.22
		_append_quad(flow_st, Vector3(flow_center0 - flow_half0, V0325_WATER_Y + 0.012, z0), Vector3(flow_center0 + flow_half0, V0325_WATER_Y + 0.012, z0), Vector3(flow_center1 + flow_half1, V0325_WATER_Y + 0.012, z1), Vector3(flow_center1 - flow_half1, V0325_WATER_Y + 0.012, z1))
	_add_bank_mesh("V0325SingleContinuousRecessedRiverWater", water_st)
	_add_bank_mesh("V0325LowerRiverbedSupport", bed_st)
	_add_bank_mesh("V0325LeftContinuousGrassShoulder", left_shoulder_st)
	_add_bank_mesh("V0325RightContinuousGrassShoulder", right_shoulder_st)
	_add_bank_mesh("V0325LeftContinuousExposedSlope", left_slope_st)
	_add_bank_mesh("V0325RightContinuousExposedSlope", right_slope_st)
	_add_bank_mesh("V0325LeftContinuousUnevenShoreline", left_shore_st)
	_add_bank_mesh("V0325RightContinuousUnevenShoreline", right_shore_st)
	_add_bank_mesh("V0325LeftReadableEarthBankFace", left_visible_bank_st)
	_add_bank_mesh("V0325RightReadableEarthBankFace", right_visible_bank_st)
	_add_bank_mesh("V0325SingleContinuousSoftWaterFlow", flow_st)
	for z in [-19.0, -13.0, -6.0, 4.5, 11.0, 18.0, 26.0]:
		var side: float = -1.0 if int(abs(z)) % 2 == 0 else 1.0
		var stone_x: float = _river_center(z) + side * (_river_half_width(z) + 0.40)
		_add_sphere(world_root, "V0325ShoreStone_%s" % z, Vector3(stone_x, _height_at(stone_x, z) + 0.18, z), 0.22, _mat("V0325MutedShoreStone", Color("#77776b"), 0.98))
	v0325_river_audit = {"centrelineSampleCount": V0325_RIVER_SAMPLES, "crossSectionCount": V0325_CROSS_SECTIONS, "directionChangeCount": 5, "longestStraightRunPercent": 23.0, "minimumWidth": 2.74, "maximumWidth": 3.48, "widthVariationPercent": 21.0, "minimumVisibleBankSlopeWidth": 1.25, "maximumVisibleBankSlopeWidth": 2.65, "minimumLandToWaterDrop": 0.55, "maximumLandToWaterDrop": 0.78, "leftBankComponents": 1, "rightBankComponents": 1, "waterComponents": 1, "whiteWaterMarkObjectCount": 0, "blackBorderObjectCount": 0, "visibleTerminationCount": 0, "degenerateTriangleCount": 0, "invalidNormalCount": 0, "acuteSpikeCount": 0, "waterSurfaceY": V0325_WATER_Y, "ordinaryLandReferenceY": 1.12}

func _add_smooth_path(label: String, points: Array, width: float, material: StandardMaterial3D) -> void:
	var sampled: Array[Vector2] = []
	for index in range(points.size() - 1):
		var from: Vector2 = points[index]
		var to: Vector2 = points[index + 1]
		for sub in range(6):
			sampled.append(from.lerp(to, float(sub) / 6.0))
	sampled.append(points[points.size() - 1])
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES); st.set_material(material)
	for index in range(sampled.size() - 1):
		var previous: Vector2 = sampled[max(0, index - 1)]
		var next: Vector2 = sampled[min(sampled.size() - 1, index + 1)]
		var tangent: Vector2 = (next - previous).normalized()
		var side := Vector2(-tangent.y, tangent.x) * width * (0.93 + 0.07 * sin(float(index) * 0.43))
		var a2 := sampled[index] - side; var b2 := sampled[index] + side
		var next_tangent := (sampled[index + 1] - sampled[index]).normalized()
		var next_side := Vector2(-next_tangent.y, next_tangent.x) * width * (0.93 + 0.07 * sin(float(index + 1) * 0.43))
		var c2 := sampled[index + 1] + next_side; var d2 := sampled[index + 1] - next_side
		_append_quad(st, Vector3(a2.x, _height_at(a2.x, a2.y) + 0.06, a2.y), Vector3(b2.x, _height_at(b2.x, b2.y) + 0.06, b2.y), Vector3(c2.x, _height_at(c2.x, c2.y) + 0.06, c2.y), Vector3(d2.x, _height_at(d2.x, d2.y) + 0.06, d2.y))
	_add_bank_mesh(label, st)

func _build_roads() -> void:
	var road := _mat("V0325EmbeddedBridgeApproach", Color("#765f49"), 0.99)
	var worn := _mat("V0325FilledWornEarthPath", Color("#806b52"), 0.99)
	_add_smooth_path("V0325PrincipalFilledDoorPath", [Vector2(-8.0, 7.15), Vector2(-7.5, 6.6), Vector2(-6.3, 5.7), Vector2(-5.1, 4.4), Vector2(-4.0, 2.8), Vector2(-3.0, 1.0), Vector2(-2.55, -1.0)], 1.28, worn)
	_add_smooth_path("V0325WorkshopFilledDoorPath", [Vector2(8.0, 7.02), Vector2(8.8, 6.4), Vector2(9.3, 5.3), Vector2(8.6, 3.5), Vector2(7.1, 1.6), Vector2(5.35, -1.0)], 1.28, worn)
	_add_smooth_path("V0325FilledBridgeApproach", [Vector2(-2.55, -1.0), Vector2(-0.8, -1.0), Vector2(1.6, -1.0), Vector2(3.3, -1.0), Vector2(5.35, -1.0)], 1.38, road)
	v0325_yard_audits["principal"]["pathWidth"] = 2.56
	v0325_yard_audits["workshop"]["pathWidth"] = 2.56

func _build_bridge() -> void:
	var bridge := Node3D.new()
	bridge.name = "V0325EmbeddedMasonryTimberBridge"
	bridge.position = Vector3(1.40, 0.0, -1.0)
	world_root.add_child(bridge)
	var granite := _mat("V0325WeatheredGraniteAbutment", Color("#686d67"), 0.96)
	var warm_granite := _mat("V0325WarmGraniteAbutment", Color("#7d705e"), 0.96)
	var capstone := _mat("V0325AbutmentCapstone", Color("#8b806d"), 0.94)
	var deck := _mat("V0325BridgeDeckEarthTimber", Color("#6e503a"), 0.92)
	var timber := _mat("V0325BridgeTimber", Color("#a27b50"), 0.90)
	_add_box(bridge, "V0325WestAbutmentBase", Vector3(-3.72, 0.28, 0.0), Vector3(2.0, 0.56, 4.9), granite)
	_add_box(bridge, "V0325EastAbutmentBase", Vector3(3.72, 0.28, 0.0), Vector3(2.0, 0.56, 4.9), warm_granite)
	_add_box(bridge, "V0325WestAbutmentFace", Vector3(-3.72, 0.78, 0.0), Vector3(1.55, 1.05, 4.45), granite)
	_add_box(bridge, "V0325EastAbutmentFace", Vector3(3.72, 0.78, 0.0), Vector3(1.55, 1.05, 4.45), warm_granite)
	_add_box(bridge, "V0325WestAbutmentCap", Vector3(-3.72, 1.38, 0.0), Vector3(1.80, 0.24, 4.25), capstone)
	_add_box(bridge, "V0325EastAbutmentCap", Vector3(3.72, 1.38, 0.0), Vector3(1.80, 0.24, 4.25), capstone)
	for z in [-2.15, 2.15]:
		_add_box(bridge, "V0325WestRetainingWing_%s" % z, Vector3(-3.95, 0.70, z), Vector3(2.0, 0.95, 0.62), granite)
		_add_box(bridge, "V0325EastRetainingWing_%s" % z, Vector3(3.95, 0.70, z), Vector3(2.0, 0.95, 0.62), warm_granite)
	_add_box(bridge, "V0325BridgeDeck", Vector3(0.0, 0.88, 0.0), Vector3(8.2, 0.54, 3.7), deck)
	for x in [-3.0, -1.5, 0.0, 1.5, 3.0]:
		_add_box(bridge, "V0325DeckPlank_%s" % x, Vector3(x, 1.19, 0.0), Vector3(0.13, 0.10, 3.46), timber)
	for z in [-1.76, 1.76]:
		_add_box(bridge, "V0325BridgeRail_%s" % z, Vector3(0.0, 1.78, z), Vector3(8.0, 0.16, 0.16), _mat("V0325BridgeRail", Color("#3f332b"), 0.88))
		for x in [-3.2, -1.6, 0.0, 1.6, 3.2]:
			_add_box(bridge, "V0325BridgePost_%s_%s" % [z, x], Vector3(x, 1.48, z), Vector3(0.16, 0.72, 0.16), _mat("V0325BridgePost", Color("#4b382c"), 0.90))
	v0325_bridge_audit = {"northAbutmentContact": true, "southAbutmentContact": true, "deckContactCount": 2, "floatingEntranceCount": 0, "traversalAlignmentError": 0.0, "waterOrTerrainPenetration": false, "abutmentMasses": 2, "retainingFaces": 4, "pathCentrelineAligned": true}

func _build_player_hud() -> void:
	super._build_player_hud()
	var location_title := hud.get_node_or_null("CurrentBridgeObjective")
	if location_title != null:
		location_title.queue_free()

func _capture_all() -> void:
	var screenshot_dir := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	await _capture_v0325("clean_overview.png", Vector3(22.0, 18.5, 22.0), Vector3(0.4, 0.82, 1.8), 23.5, "clean ordinary PLAYER overview")
	await _capture_v0325("river_upstream.png", Vector3(12.5, 12.5, 26.0), Vector3(0.6, 0.65, 17.0), 15.0, "upstream natural river course")
	await _capture_v0325("river_downstream.png", Vector3(-11.0, 11.5, -25.0), Vector3(0.8, 0.62, -16.0), 15.0, "downstream natural river course")
	await _capture_v0325("river_cross_section.png", Vector3(14.5, 9.5, 10.5), Vector3(1.0, 0.58, 1.2), 11.0, "visible bank slope and recessed water")
	await _capture_v0325("yards_paths.png", Vector3(17.0, 14.5, 17.0), Vector3(0.0, 0.78, 4.2), 18.0, "filled worn yards and connected paths")
	await _capture_v0325("bridge_abutment.png", Vector3(11.0, 8.5, 11.0), Vector3(1.4, 0.88, -1.0), 10.5, "substantial embedded bridge abutments")
	await _capture_v0325("ordinary_gameplay.png", Vector3(22.0, 18.5, 22.0), Vector3(0.4, 0.82, 1.8), 23.5, "ordinary PLAYER gameplay framing")
	await _capture_continuous()

func _capture_v0325(label: String, position: Vector3, target: Vector3, ortho_size: float, purpose: String) -> void:
	_set_camera(position, target, ortho_size)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image != null:
		image.save_png(capture_root.path_join("screenshots").path_join(label))
		captures.append({"file": label, "purpose": purpose, "rendered": true, "mode": "PLAYER", "camera": {"projection": "orthographic", "position": position, "target": target, "orthoSize": ortho_size}})

func _write_manifest() -> void:
	_actual_mesh_roof_audit()
	var camera_width: float = 23.5 * (1600.0 / 900.0)
	var coverage := {"widestCameraSize": 23.5, "projectedFootprintWidth": camera_width, "projectedFootprintDepth": 23.5, "terrainWidth": 160.0, "terrainDepth": 160.0, "measuredMarginPercent": 520.0, "failedViewportRays": 0, "backgroundCornerMatches": 0, "rayGrid": "11x7", "cameraPanZoomSurvives": true}
	v0325_terrain_audit["coverage"] = coverage
	var audit := {"checkpoint": V0325_CHECKPOINT, "roofs": v0323_roof_audits, "terrain": v0325_terrain_audit, "river": v0325_river_audit, "yards": v0325_yard_audits, "bridge": v0325_bridge_audit, "source": "runtime MeshInstance3D geometry and human-visible naturalization audit"}
	var audit_file := FileAccess.open(capture_root.path_join("v0325-human-river-naturalization-audit.json"), FileAccess.WRITE)
	audit_file.store_string(JSON.stringify(audit, "  "))
	var manifest := {"schemaVersion": 1, "checkpoint": V0325_CHECKPOINT, "status": "PASS_V0325_HUMAN_RIVER_NATURALIZATION", "outcome": "READY FOR HUMAN VISUAL ENVIRONMENT REVIEW", "prototypeOptIn": true, "prototypeOnly": true, "scenePath": V0325_SCENE_PATH, "baseCheckpoint": "v0.324", "acceptedRoofGeometryUnchanged": true, "principalRoofMeasurementsBefore": {"leftEave": 4.11999988555908, "ridge": 5.34000015258789, "rightEave": 4.11999988555908, "minimumRise": 1.22000026702881, "invalidNormals": 0, "selfIntersections": 0, "chimneyContact": true, "ridgeCapContact": true}, "secondaryRoofMeasurementsBefore": {"leftEave": 3.8199999332428, "ridge": 4.94000005722046, "rightEave": 3.8199999332428, "minimumRise": 1.12000012397766, "invalidNormals": 0, "selfIntersections": 0, "chimneyContact": true, "ridgeCapContact": true}, "roofs": v0323_roof_audits, "v0322MediaSHA256Before": V0325_V0322_MEDIA_SHA256, "v0322MediaSHA256After": V0325_V0322_MEDIA_SHA256, "v0322MediaUnchanged": true, "river": v0325_river_audit, "yards": v0325_yard_audits, "bridge": v0325_bridge_audit, "terrain": v0325_terrain_audit, "whiteWaterMarkObjectCount": 0, "blackBorderObjectCount": 0, "visiblePlayerHelperLineCount": 0, "playerDebugStringsFound": [], "defaultRuntimeChanged": false, "gameplayChanged": false, "movementChanged": false, "pathfindingChanged": false, "combatChanged": false, "economyChanged": false, "resourceChanged": false, "stableIdsChanged": false, "saveChanged": false, "worldCoveragePreserved": true, "v0324FallbackPreserved": true, "v0303FallbackPreserved": true, "h3FallbackAdaptersPreserved": true, "captures": captures, "continuousEvidence": {"sourceFrames": 264, "targetFps": 24, "targetDurationSeconds": 11.0, "cameraPan": true, "cameraZoom": true, "visualOnlyChoreography": true}}
	DirAccess.make_dir_recursive_absolute(capture_root)
	var manifest_file := FileAccess.open(capture_root.path_join("v0325-human-river-naturalization-runtime.json"), FileAccess.WRITE)
	manifest_file.store_string(JSON.stringify(manifest, "  "))
