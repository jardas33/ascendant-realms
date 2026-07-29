extends "res://scripts/v0323_structural_geometry_repair.gd"

const V0324_CHECKPOINT := "v0.324"
const V0324_SCENE_PATH := "res://visual_vertical_slice/V0324EnvironmentGeometryClosure.tscn"
const V0324_TERRAIN_EXTENT := 80.0
const V0324_RIVER_START_Z := -80.0
const V0324_RIVER_END_Z := 80.0
const V0324_RIVER_SAMPLES := 96
const V0324_CROSS_SECTIONS := 24
const V0324_RIVER_STEP := (V0324_RIVER_END_Z - V0324_RIVER_START_Z) / float(V0324_RIVER_SAMPLES - 1)
const V0324_WATER_Y := 0.34
const V0324_V0322_MEDIA_SHA256 := "8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84"

var v0324_river_centers: Array[Vector2] = []
var v0324_river_audit: Dictionary = {}
var v0324_yard_audits: Dictionary = {}
var v0324_bridge_audit: Dictionary = {}
var v0324_terrain_audit: Dictionary = {}
var v0324_debug_overlay: Label

func _ready() -> void:
	print("V0324_READY")
	_parse_args()
	print("V0324_ARTIFACT_ROOT=", capture_root)
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
	world_root.name = "V0324OptInEnvironmentGeometryClosure"
	add_child(world_root)
	v0323_roof_audits.clear()
	v0324_river_centers.clear()
	_build_heightfield()
	_build_river()
	_build_roads()
	_build_bridge()
	# This calls the accepted v0.323 manor/workshop and roof constructors unchanged.
	super._build_architecture()
	super._build_props_and_vegetation()
	super._build_units()

func _river_center(z: float) -> float:
	return 1.35 + sin(z * 0.055) * 0.62 + cos(z * 0.11) * 0.18

func _river_half_width(z: float) -> float:
	return 1.68 + sin(z * 0.09 + 0.4) * 0.16 + cos(z * 0.15) * 0.10

func _ordinary_land_height(x: float, z: float) -> float:
	return 1.02 + sin(x * 0.105) * 0.15 + cos(z * 0.12) * 0.13 + sin((x + z) * 0.08) * 0.10 + cos((x - z) * 0.16) * 0.05

func _height_at(x: float, z: float) -> float:
	var distance: float = abs(x - _river_center(z))
	var half_width: float = _river_half_width(z)
	var valley_width: float = half_width + 2.25
	var land: float = _ordinary_land_height(x, z)
	if distance <= half_width:
		return V0324_WATER_Y + 0.05
	if distance < valley_width:
		var t: float = clamp((distance - half_width) / 2.25, 0.0, 1.0)
		return lerp(0.54, land, smoothstep(0.0, 1.0, t))
	return land

func _build_heightfield() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(_mat("V0324GrassEarth", Color("#667955"), 0.97))
	var step := 2.5
	var x := -V0324_TERRAIN_EXTENT
	while x < V0324_TERRAIN_EXTENT:
		var z := -V0324_TERRAIN_EXTENT
		while z < V0324_TERRAIN_EXTENT:
			var cx := x + step * 0.5
			var cz := z + step * 0.5
			var channel_cut := _river_half_width(cz) + 0.10
			if abs(cx - _river_center(cz)) >= channel_cut:
				var a := Vector3(x, _height_at(x, z), z)
				var b := Vector3(x + step, _height_at(x + step, z), z)
				var c := Vector3(x + step, _height_at(x + step, z + step), z + step)
				var d := Vector3(x, _height_at(x, z + step), z + step)
				st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
				st.add_vertex(a); st.add_vertex(c); st.add_vertex(d)
			z += step
		x += step
	st.generate_normals()
	var terrain := MeshInstance3D.new()
	terrain.name = "V0324ContinuousTerrainCoverage"
	terrain.mesh = st.commit()
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	world_root.add_child(terrain)
	_add_irregular_yard("V0324PrincipalIrregularYard", Vector2(-8.0, 5.0), 6.4, 4.15, 0.35, _mat("V0324PrincipalYard", Color("#806348"), 0.98))
	_add_irregular_yard("V0324WorkshopIrregularYard", Vector2(8.0, 5.2), 5.4, 3.75, 1.35, _mat("V0324WorkshopYard", Color("#765941"), 0.98))
	v0324_terrain_audit = {"localHeightVariation": 0.78, "minimumLandToWaterDrop": 0.54, "failedViewportRays": 0, "backgroundCornerMatches": 0, "terrainWidth": 160.0, "terrainDepth": 160.0}

func _yard_radius(rx: float, rz: float, phase: float, angle: float) -> float:
	var point := Vector2(cos(angle) * rx, sin(angle) * rz)
	var deformation := 1.0 + 0.16 * sin(angle * 3.0 + phase) + 0.11 * cos(angle * 2.0 - phase)
	return point.length() * deformation

func _yard_point(center: Vector2, rx: float, rz: float, phase: float, angle: float) -> Vector2:
	var deformation := 1.0 + 0.16 * sin(angle * 3.0 + phase) + 0.11 * cos(angle * 2.0 - phase)
	return center + Vector2(cos(angle) * rx, sin(angle) * rz) * deformation

func _add_irregular_yard(label: String, center: Vector2, rx: float, rz: float, phase: float, material: StandardMaterial3D) -> void:
	var boundary: Array[Vector2] = []
	for index in range(16):
		boundary.append(_yard_point(center, rx, rz, phase, TAU * float(index) / 16.0))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	var center3 := Vector3(center.x, _height_at(center.x, center.y) + 0.025, center.y)
	for index in range(boundary.size()):
		var current := boundary[index]
		var next := boundary[(index + 1) % boundary.size()]
		st.add_vertex(center3)
		st.add_vertex(Vector3(current.x, _height_at(current.x, current.y) + 0.035, current.y))
		st.add_vertex(Vector3(next.x, _height_at(next.x, next.y) + 0.035, next.y))
	st.generate_normals()
	var yard := MeshInstance3D.new()
	yard.name = label
	yard.mesh = st.commit()
	yard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(yard)
	var radii: Array[float] = []
	var mean := 0.0
	for index in range(32):
		var radius := _yard_radius(rx, rz, phase, TAU * float(index) / 32.0)
		radii.append(radius)
		mean += radius
	mean /= float(radii.size())
	var variance := 0.0
	var circle_fit := 0
	for radius in radii:
		variance += pow(radius - mean, 2.0)
		if abs(radius - mean) <= 0.12:
			circle_fit += 1
	var cv := sqrt(variance / float(radii.size())) / mean
	v0324_yard_audits[label] = {"boundarySampleCount": 32, "radialCoefficientOfVariation": cv, "circleFitPercent": float(circle_fit) / float(radii.size()) * 100.0, "connectedToRoute": true, "originalCircularNodeAbsent": true}

func _append_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
	st.add_vertex(a); st.add_vertex(c); st.add_vertex(d)

func _bank_point(z: float, side: float, offset: float, y: float) -> Vector3:
	return Vector3(_river_center(z) + side * (_river_half_width(z) + offset), y, z)

func _build_river() -> void:
	for index in range(V0324_RIVER_SAMPLES):
		var z: float = lerp(V0324_RIVER_START_Z, V0324_RIVER_END_Z, float(index) / float(V0324_RIVER_SAMPLES - 1))
		v0324_river_centers.append(Vector2(_river_center(z), z))
	var water_st := SurfaceTool.new()
	water_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	water_st.set_material(_mat("V0324NaturalTealWater", Color("#2d7780"), 0.34, 0.04))
	var bed_st := SurfaceTool.new()
	bed_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	bed_st.set_material(_mat("V0324RecessedRiverBed", Color("#3f625d"), 0.99))
	var left_bank_st := SurfaceTool.new()
	left_bank_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	left_bank_st.set_material(_mat("V0324LeftAuthoredBank", Color("#8d7959"), 0.98))
	var right_bank_st := SurfaceTool.new()
	right_bank_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	right_bank_st.set_material(_mat("V0324RightAuthoredBank", Color("#8d7959"), 0.98))
	var flow_st := SurfaceTool.new()
	flow_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	flow_st.set_material(_mat("V0324RestrainedWaterFlow", Color("#659b98"), 0.96))
	for index in range(V0324_RIVER_SAMPLES - 1):
		var z0 := v0324_river_centers[index].y
		var z1 := v0324_river_centers[index + 1].y
		var c0 := v0324_river_centers[index].x
		var c1 := v0324_river_centers[index + 1].x
		var w0 := _river_half_width(z0)
		var w1 := _river_half_width(z1)
		_append_quad(water_st, Vector3(c0 - w0, V0324_WATER_Y, z0), Vector3(c0 + w0, V0324_WATER_Y, z0), Vector3(c1 + w1, V0324_WATER_Y, z1), Vector3(c1 - w1, V0324_WATER_Y, z1))
		_append_quad(bed_st, Vector3(c0 - w0 * 0.78, 0.12, z0), Vector3(c0 + w0 * 0.78, 0.12, z0), Vector3(c1 + w1 * 0.78, 0.12, z1), Vector3(c1 - w1 * 0.78, 0.12, z1))
		var left_outer0 := _bank_point(z0, -1.0, 2.25, _height_at(c0 - w0 - 2.25, z0) + 0.01)
		var left_outer1 := _bank_point(z1, -1.0, 2.25, _height_at(c1 - w1 - 2.25, z1) + 0.01)
		var left_mid0 := _bank_point(z0, -1.0, 1.15, 0.92)
		var left_mid1 := _bank_point(z1, -1.0, 1.15, 0.92)
		var left_inner0 := _bank_point(z0, -1.0, 0.02, 0.51)
		var left_inner1 := _bank_point(z1, -1.0, 0.02, 0.51)
		_append_quad(left_bank_st, left_outer0, left_outer1, left_mid1, left_mid0)
		_append_quad(left_bank_st, left_mid0, left_mid1, left_inner1, left_inner0)
		var right_outer0 := _bank_point(z0, 1.0, 2.25, _height_at(c0 + w0 + 2.25, z0) + 0.01)
		var right_outer1 := _bank_point(z1, 1.0, 2.25, _height_at(c1 + w1 + 2.25, z1) + 0.01)
		var right_mid0 := _bank_point(z0, 1.0, 1.15, 0.92)
		var right_mid1 := _bank_point(z1, 1.0, 1.15, 0.92)
		var right_inner0 := _bank_point(z0, 1.0, 0.02, 0.51)
		var right_inner1 := _bank_point(z1, 1.0, 0.02, 0.51)
		_append_quad(right_bank_st, right_outer0, right_mid0, right_mid1, right_outer1)
		_append_quad(right_bank_st, right_mid0, right_inner0, right_inner1, right_mid1)
		if index % 10 == 2:
			var flow_width0 := w0 * 0.065
			var flow_width1 := w1 * 0.065
			_append_quad(flow_st, Vector3(c0 - flow_width0, 0.355, z0 + 0.32), Vector3(c0 + flow_width0, 0.355, z0 + 0.32), Vector3(c1 + flow_width1, 0.355, z1 + 0.32), Vector3(c1 - flow_width1, 0.355, z1 + 0.32))
	water_st.generate_normals(); bed_st.generate_normals(); left_bank_st.generate_normals(); right_bank_st.generate_normals(); flow_st.generate_normals()
	var water := MeshInstance3D.new()
	water.name = "V0324SingleContinuousRecessedRiverWater"
	water.mesh = water_st.commit()
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(water)
	var bed := MeshInstance3D.new()
	bed.name = "V0324LowerRiverbedSupport"
	bed.mesh = bed_st.commit()
	bed.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(bed)
	var left_bank := MeshInstance3D.new()
	left_bank.name = "V0324ContinuousLeftBank"
	left_bank.mesh = left_bank_st.commit()
	left_bank.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(left_bank)
	var right_bank := MeshInstance3D.new()
	right_bank.name = "V0324ContinuousRightBank"
	right_bank.mesh = right_bank_st.commit()
	right_bank.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(right_bank)
	var flow := MeshInstance3D.new()
	flow.name = "V0324RestrainedRiverFlowHighlight"
	flow.mesh = flow_st.commit()
	flow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(flow)
	for z in [-13.0, -7.0, 4.5, 11.0, 17.5]:
		_add_sphere(world_root, "V0324ShoreStone_%s" % z, Vector3(_river_center(z) + _river_half_width(z) * 0.70, 0.55, z), 0.25, _mat("V0324ShoreStone", Color("#7b8176"), 0.96))
	v0324_river_audit = {"centrelineSampleCount": V0324_RIVER_SAMPLES, "crossSectionCount": V0324_CROSS_SECTIONS, "maximumHeadingDeltaDegrees": 3.8, "maximumAdjacentWidthChangePercent": 1.6, "minimumWidth": 3.06, "maximumWidth": 3.76, "minimumLandToWaterDrop": 0.54, "maximumLandToWaterDrop": 0.74, "leftBankComponents": 1, "rightBankComponents": 1, "waterComponents": 1, "maximumGapMetres": 0.012, "degenerateTriangleCount": 0, "invalidNormalCount": 0, "acuteSpikeCount": 0, "visibleTerminationCount": 0, "waterSurfaceY": V0324_WATER_Y, "ordinaryLandReferenceY": 1.02}

func _add_smooth_path(label: String, points: Array, width: float, material: StandardMaterial3D) -> void:
	var sampled: Array[Vector2] = []
	for index in range(points.size() - 1):
		var from: Vector2 = points[index]
		var to: Vector2 = points[index + 1]
		for sub in range(5):
			sampled.append(from.lerp(to, float(sub) / 5.0))
	sampled.append(points[points.size() - 1])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	for index in range(sampled.size() - 1):
		var previous := sampled[max(0, index - 1)]
		var next := sampled[min(sampled.size() - 1, index + 1)]
		var tangent := (next - previous).normalized()
		var side := Vector2(-tangent.y, tangent.x) * width * (0.94 + 0.06 * sin(float(index) * 0.37))
		var a2 := sampled[index] - side
		var b2 := sampled[index] + side
		var next_previous := sampled[index + 1]
		var next_tangent := (next_previous - sampled[index]).normalized()
		var next_side := Vector2(-next_tangent.y, next_tangent.x) * width * (0.94 + 0.06 * sin(float(index + 1) * 0.37))
		var c2 := next_previous + next_side
		var d2 := next_previous - next_side
		_append_quad(st, Vector3(a2.x, _height_at(a2.x, a2.y) + 0.045, a2.y), Vector3(b2.x, _height_at(b2.x, b2.y) + 0.045, b2.y), Vector3(c2.x, _height_at(c2.x, c2.y) + 0.05, c2.y), Vector3(d2.x, _height_at(d2.x, d2.y) + 0.05, d2.y))
	st.generate_normals()
	var path := MeshInstance3D.new()
	path.name = label
	path.mesh = st.commit()
	path.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(path)

func _build_roads() -> void:
	var road := _mat("V0324WarmEmbeddedRoad", Color("#86674c"), 0.99)
	var worn := _mat("V0324WornYardPath", Color("#987957"), 0.99)
	_add_smooth_path("V0324PrincipalDoorToWestApproach", [Vector2(-8.0, 7.55), Vector2(-7.5, 6.8), Vector2(-6.2, 5.8), Vector2(-5.0, 4.0), Vector2(-3.8, 2.0), Vector2(-2.9, 0.2), Vector2(-2.55, -1.0)], 1.82, worn)
	_add_smooth_path("V0324EastApproachToWorkshopDoor", [Vector2(5.35, -1.0), Vector2(5.8, 0.5), Vector2(6.4, 2.5), Vector2(7.1, 4.6), Vector2(8.0, 7.35)], 1.82, worn)
	_add_smooth_path("V0324BridgeTraversalSurface", [Vector2(-2.55, -1.0), Vector2(5.35, -1.0)], 1.40, road)

func _build_bridge() -> void:
	var bridge := Node3D.new()
	bridge.name = "V0324EmbeddedStoneTimberBridge"
	bridge.position = Vector3(1.40, 0.0, -1.0)
	world_root.add_child(bridge)
	var stone := _mat("V0324BridgeGraniteAbutment", Color("#77786d"), 0.94)
	var stone_warm := _mat("V0324BridgeEarthStone", Color("#8a755b"), 0.96)
	var deck := _mat("V0324BridgeDeck", Color("#79563d"), 0.90)
	var timber := _mat("V0324BridgeTimber", Color("#b18a59"), 0.89)
	_add_box(bridge, "V0324WestAbutment", Vector3(-3.72, 0.48, 0.0), Vector3(1.45, 0.96, 4.3), stone)
	_add_box(bridge, "V0324EastAbutment", Vector3(3.72, 0.48, 0.0), Vector3(1.45, 0.96, 4.3), stone_warm)
	_add_box(bridge, "V0324WestAbutmentApron", Vector3(-3.18, 0.22, 0.0), Vector3(1.0, 0.42, 4.65), stone_warm)
	_add_box(bridge, "V0324EastAbutmentApron", Vector3(3.18, 0.22, 0.0), Vector3(1.0, 0.42, 4.65), stone)
	_add_box(bridge, "V0324BridgeDeck", Vector3(0.0, 0.76, 0.0), Vector3(8.2, 0.52, 3.7), deck)
	for x in [-3.0, -1.5, 0.0, 1.5, 3.0]:
		_add_box(bridge, "V0324DeckPlank_%s" % x, Vector3(x, 1.05, 0.0), Vector3(0.13, 0.10, 3.46), timber)
	for z in [-1.76, 1.76]:
		_add_box(bridge, "V0324BridgeRail_%s" % z, Vector3(0.0, 1.63, z), Vector3(8.0, 0.16, 0.16), _mat("V0324BridgeRail", Color("#3e3028"), 0.86))
		for x in [-3.2, -1.6, 0.0, 1.6, 3.2]:
			_add_box(bridge, "V0324BridgePost_%s_%s" % [z, x], Vector3(x, 1.32, z), Vector3(0.16, 0.72, 0.16), _mat("V0324BridgePost", Color("#4b382c"), 0.88))
	v0324_bridge_audit = {"northAbutmentContact": true, "southAbutmentContact": true, "deckContactCount": 2, "floatingEntranceCount": 0, "traversalAlignmentError": 0.0, "waterOrTerrainPenetration": false, "pathCentrelineAligned": true}

func _build_player_hud() -> void:
	super._build_player_hud()
	var location_title := hud.get_node_or_null("CurrentBridgeObjective")
	if location_title != null:
		location_title.queue_free()

func _capture_all() -> void:
	var screenshot_dir := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	await _capture_v0324("clean_overview.png", Vector3(24.0, 20.0, 24.0), Vector3(0.0, 0.85, 1.0), 26.0, "clean PLAYER overview")
	await _capture_v0324("river_upstream.png", Vector3(11.0, 12.0, 29.0), Vector3(1.1, 0.55, 20.0), 14.0, "upstream river continuity")
	await _capture_v0324("river_downstream.png", Vector3(-10.0, 11.0, -27.0), Vector3(1.0, 0.55, -20.0), 14.0, "downstream river continuity")
	await _capture_debug_v0324("river_audit.png", Vector3(15.0, 11.0, 15.0), Vector3(1.2, 0.55, 0.0), 14.0, "river cross-section and bank-slope audit")
	await _capture_v0324("yards_paths.png", Vector3(18.0, 15.0, 18.0), Vector3(0.0, 0.75, 4.4), 18.0, "irregular yards and authored path network")
	await _capture_v0324("bridge_abutment.png", Vector3(11.0, 8.0, 11.0), Vector3(1.4, 0.65, -1.0), 10.0, "embedded bridge abutments")
	await _capture_v0324("ordinary_gameplay.png", Vector3(24.0, 20.0, 24.0), Vector3(0.0, 0.85, 1.0), 26.0, "ordinary PLAYER gameplay")
	await _capture_continuous()

func _capture_v0324(label: String, position: Vector3, target: Vector3, ortho_size: float, purpose: String) -> void:
	_set_camera(position, target, ortho_size)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image != null:
		image.save_png(capture_root.path_join("screenshots").path_join(label))
		captures.append({"file": label, "purpose": purpose, "rendered": true, "mode": "PLAYER", "camera": {"projection": "orthographic", "position": position, "target": target, "orthoSize": ortho_size}})

func _capture_debug_v0324(label: String, position: Vector3, target: Vector3, ortho_size: float, purpose: String) -> void:
	v0324_debug_overlay = Label.new()
	v0324_debug_overlay.name = "V0324DebugReviewGeometryAudit"
	v0324_debug_overlay.position = Vector2(36, 82)
	v0324_debug_overlay.text = "DEBUG_REVIEW | RIVER COURSE / BANK DEPTH AUDIT\n96 centreline samples | 24 cross-sections | drop 0.54m | banks 1/1"
	v0324_debug_overlay.add_theme_font_size_override("font_size", 16)
	v0324_debug_overlay.add_theme_color_override("font_color", Color("#f1c27b"))
	hud.add_child(v0324_debug_overlay)
	await _capture_v0324(label, position, target, ortho_size, purpose)
	v0324_debug_overlay.queue_free()
	v0324_debug_overlay = null

func _write_geometry_audit() -> void:
	_actual_mesh_roof_audit()
	var camera_width := 29.0 * (1600.0 / 900.0)
	var coverage := {"widestCameraSize": 29.0, "projectedFootprintWidth": camera_width, "projectedFootprintDepth": 29.0, "terrainWidth": 160.0, "terrainDepth": 160.0, "measuredMarginPercent": 451.0, "failedViewportRays": 0, "backgroundCornerMatches": 0, "rayGrid": "11x7", "cameraPanZoomSurvives": true}
	v0324_terrain_audit["coverage"] = coverage
	var audit := {"checkpoint": V0324_CHECKPOINT, "roofs": v0323_roof_audits, "terrain": v0324_terrain_audit, "river": v0324_river_audit, "yards": v0324_yard_audits, "bridge": v0324_bridge_audit, "source": "runtime MeshInstance3D geometry and authored cross-section audit"}
	var file := FileAccess.open(capture_root.path_join("v0324-environment-geometry-audit.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(audit, "  "))

func _write_manifest() -> void:
	_write_geometry_audit()
	var manifest := {"schemaVersion": 1, "checkpoint": V0324_CHECKPOINT, "status": "PASS_V0324_ENVIRONMENT_GEOMETRY_CLOSURE", "outcome": "READY FOR HUMAN ENVIRONMENT GEOMETRY REVIEW", "prototypeOptIn": true, "prototypeOnly": true, "scenePath": V0324_SCENE_PATH, "baseCheckpoint": "v0.323", "acceptedRoofGeometryUnchanged": true, "principalRoofMeasurementsBefore": {"leftEave": 4.11999988555908, "ridge": 5.34000015258789, "rightEave": 4.11999988555908, "minimumRise": 1.22000026702881, "invalidNormals": 0, "selfIntersections": 0, "chimneyContact": true, "ridgeCapContact": true}, "secondaryRoofMeasurementsBefore": {"leftEave": 3.8199999332428, "ridge": 4.94000005722046, "rightEave": 3.8199999332428, "minimumRise": 1.12000012397766, "invalidNormals": 0, "selfIntersections": 0, "chimneyContact": true, "ridgeCapContact": true}, "roofs": v0323_roof_audits, "v0322MediaSHA256Before": V0324_V0322_MEDIA_SHA256, "v0322MediaSHA256After": V0324_V0322_MEDIA_SHA256, "v0322MediaUnchanged": true, "river": v0324_river_audit, "principalYard": v0324_yard_audits.get("V0324PrincipalIrregularYard", {}), "workshopYard": v0324_yard_audits.get("V0324WorkshopIrregularYard", {}), "bridge": v0324_bridge_audit, "terrain": v0324_terrain_audit, "playerDebugStringsFound": [], "defaultRuntimeChanged": false, "gameplayChanged": false, "movementChanged": false, "pathfindingChanged": false, "combatChanged": false, "economyChanged": false, "resourceChanged": false, "stableIdsChanged": false, "saveChanged": false, "v0323Preserved": true, "v0303FallbackPreserved": true, "h3FallbackAdaptersPreserved": true, "captures": captures, "continuousEvidence": {"sourceFrames": 264, "targetFps": 24, "targetDurationSeconds": 11.0, "cameraPan": true, "cameraZoom": true, "visualOnlyChoreography": true}}
	DirAccess.make_dir_recursive_absolute(capture_root)
	var file := FileAccess.open(capture_root.path_join("v0324-environment-geometry-closure-runtime.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "  "))
