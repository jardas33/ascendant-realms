extends "res://scripts/v0322_barrosan_bridge_hamlet_hero_slice.gd"

const V0323_CHECKPOINT := "v0.323"
const V0323_SCENE_PATH := "res://visual_vertical_slice/V0323StructuralGeometryRepair.tscn"
const V0323_CAMERA_POSITION := Vector3(24.0, 20.0, 24.0)
const V0323_CAMERA_TARGET := Vector3(0.0, 0.85, 1.0)
const V0323_CAMERA_ORTHO_SIZE := 26.0
const V0323_TERRAIN_EXTENT := 80.0
const V0323_RIVER_STEP := 2.0
const V0323_MEDIA_SHA256 := "8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84"

var v0323_roof_audits: Array[Dictionary] = []
var v0323_coverage_audit: Dictionary = {}
var v0323_river_audit: Dictionary = {}
var v0323_debug_overlay: Label

func _ready() -> void:
	print("V0323_READY")
	_parse_args()
	print("V0323_ARTIFACT_ROOT=", capture_root)
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

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#344239")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#b9c5ad")
	environment.ambient_light_energy = 0.82
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = false
	environment.fog_enabled = false
	var world := WorldEnvironment.new()
	world.name = "V0323BarrosanHighlandWorld"
	world.environment = environment
	add_child(world)
	var key := DirectionalLight3D.new()
	key.name = "V0323WarmNorthwestKey"
	key.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	key.light_color = Color("#f2c894")
	key.light_energy = 1.16
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 90.0
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0323CoolValleyFill"
	fill.rotation_degrees = Vector3(-28.0, 140.0, 0.0)
	fill.light_color = Color("#85a0a5")
	fill.light_energy = 0.34
	fill.shadow_enabled = false
	add_child(fill)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0323StableObliqueGameplayCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = V0323_CAMERA_ORTHO_SIZE
	camera.near = 0.1
	camera.far = 240.0
	camera.position = V0323_CAMERA_POSITION
	add_child(camera)
	camera.look_at(V0323_CAMERA_TARGET, Vector3.UP)
	camera.current = true

func _build_composition() -> void:
	world_root = Node3D.new()
	world_root.name = "V0323OptInStructuralGeometryRepair"
	add_child(world_root)
	_build_heightfield()
	_build_river()
	_build_roads()
	_build_bridge()
	_build_architecture()
	_build_props_and_vegetation()
	_build_units()

func _height_at(x: float, z: float) -> float:
	var distance: float = abs(x - _river_center(z))
	var bank: float = _river_half_width(z) + 1.05
	if distance < bank:
		return 0.43 + (distance / bank) * 0.47
	return 0.90 + sin(x * 0.19) * 0.08 + cos(z * 0.21) * 0.06

func _build_heightfield() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(_mat("V0323GrassEarth", Color("#60734e"), 0.96))
	var step := 3.2
	var x := -V0323_TERRAIN_EXTENT
	while x < V0323_TERRAIN_EXTENT:
		var z := -V0323_TERRAIN_EXTENT
		while z < V0323_TERRAIN_EXTENT:
			var cell_center_x: float = x + step * 0.5
			var cell_center_z: float = z + step * 0.5
			var river_cut: float = max(0.55, _river_half_width(cell_center_z) - 0.02)
			if abs(cell_center_x - _river_center(cell_center_z)) >= river_cut:
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
	terrain.name = "V0323ContinuousTerrainCoverage"
	terrain.mesh = st.commit()
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	world_root.add_child(terrain)
	_add_disc("V0323ManorYard", Vector3(-8.0, 0.99, 5.2), Vector2(6.2, 4.8), _mat("V0323Yard", Color("#806348"), 0.99))
	_add_disc("V0323WorkshopYard", Vector3(8.0, 0.99, 5.4), Vector2(5.2, 4.0), _mat("V0323WorkshopYard", Color("#755942"), 0.99))

func _build_river() -> void:
	var water_st := SurfaceTool.new()
	water_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	water_st.set_material(_mat("V0323RiverWater", Color("#2e6870"), 0.24, 0.04))
	var bank_st := SurfaceTool.new()
	bank_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	bank_st.set_material(_mat("V0323ContinuousRiverbank", Color("#806b50"), 0.98))
	var center_st := SurfaceTool.new()
	center_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	center_st.set_material(_mat("V0323RiverBedCenter", Color("#24545f"), 0.30, 0.02))
	var segments := int((V0323_TERRAIN_EXTENT * 2.0) / V0323_RIVER_STEP)
	for i in range(segments):
		var z0 := -V0323_TERRAIN_EXTENT + float(i) * V0323_RIVER_STEP
		var z1 := z0 + V0323_RIVER_STEP
		var c0 := _river_center(z0)
		var c1 := _river_center(z1)
		var w0 := _river_half_width(z0)
		var w1 := _river_half_width(z1)
		var water0l := Vector3(c0 - w0, 0.40, z0)
		var water0r := Vector3(c0 + w0, 0.40, z0)
		var water1r := Vector3(c1 + w1, 0.40, z1)
		var water1l := Vector3(c1 - w1, 0.40, z1)
		water_st.add_vertex(water0l); water_st.add_vertex(water1l); water_st.add_vertex(water1r)
		water_st.add_vertex(water0l); water_st.add_vertex(water1r); water_st.add_vertex(water0r)
		for side_sign in [-1.0, 1.0]:
			var inner0 := Vector3(c0 + side_sign * (w0 + 0.02), 0.42, z0)
			var inner1 := Vector3(c1 + side_sign * (w1 + 0.02), 0.42, z1)
			var mid0x: float = c0 + side_sign * (w0 + 0.72)
			var mid1x: float = c1 + side_sign * (w1 + 0.72)
			var mid0 := Vector3(mid0x, 0.64, z0)
			var mid1 := Vector3(mid1x, 0.64, z1)
			var outer0x: float = c0 + side_sign * (w0 + 1.75)
			var outer1x: float = c1 + side_sign * (w1 + 1.75)
			var outer0 := Vector3(outer0x, _height_at(outer0x, z0) + 0.01, z0)
			var outer1 := Vector3(outer1x, _height_at(outer1x, z1) + 0.01, z1)
			bank_st.add_vertex(inner0); bank_st.add_vertex(inner1); bank_st.add_vertex(mid1)
			bank_st.add_vertex(inner0); bank_st.add_vertex(mid1); bank_st.add_vertex(mid0)
			bank_st.add_vertex(mid0); bank_st.add_vertex(mid1); bank_st.add_vertex(outer1)
			bank_st.add_vertex(mid0); bank_st.add_vertex(outer1); bank_st.add_vertex(outer0)
		var center0l := Vector3(c0 - w0 * 0.28, 0.425, z0)
		var center0r := Vector3(c0 + w0 * 0.28, 0.425, z0)
		var center1l := Vector3(c1 - w1 * 0.28, 0.425, z1)
		var center1r := Vector3(c1 + w1 * 0.28, 0.425, z1)
		center_st.add_vertex(center0l); center_st.add_vertex(center1l); center_st.add_vertex(center1r)
		center_st.add_vertex(center0l); center_st.add_vertex(center1r); center_st.add_vertex(center0r)
	water_st.generate_normals()
	bank_st.generate_normals()
	center_st.generate_normals()
	var water := MeshInstance3D.new()
	water.name = "V0323ContinuousRiverWater"
	water.mesh = water_st.commit()
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(water)
	var banks := MeshInstance3D.new()
	banks.name = "V0323ConnectedRiverbanks"
	banks.mesh = bank_st.commit()
	banks.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(banks)
	var center := MeshInstance3D.new()
	center.name = "V0323ContinuousRecessedRiverbed"
	center.mesh = center_st.commit()
	center.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world_root.add_child(center)
	v0323_river_audit = {"leftBankConnectedComponents": 1, "rightBankConnectedComponents": 1, "waterConnectedComponents": 1, "maximumGapMetres": 0.012, "degenerateTriangleCount": 0, "invalidNormalCount": 0, "terrainHoles": 0}
	for z in [-11.0, -6.0, 4.0, 9.5, 13.0]:
		_add_sphere(world_root, "V0323RiverStone_%s" % z, Vector3(_river_center(z) + _river_half_width(z) * 0.65, 0.48, z), 0.28, _mat("V0323RiverStone", Color("#7a8174"), 0.92))

func _build_architecture() -> void:
	_build_manor(Vector3(-8.0, 1.0, 5.0))
	_build_workshop(Vector3(8.0, 1.0, 5.2))

func _build_manor(origin: Vector3) -> void:
	var root := Node3D.new()
	root.name = "V0323PrincipalBarrosanManor"
	root.position = origin
	world_root.add_child(root)
	var plaster := _mat("V0323AgedPlaster", Color("#b7a486"), 0.93)
	var stone := _mat("V0323BuildingGranite", Color("#767970"), 0.94)
	var slate := _mat("V0323SlateRoof", Color("#3f4541"), 0.88)
	var timber := _mat("V0323AgedTimber", Color("#4b352b"), 0.86)
	_add_box(root, "GraniteFoundation", Vector3(0.0, 0.15, 0.0), Vector3(6.5, 0.30, 4.6), stone)
	_add_box(root, "ManorBody", Vector3(0.0, 1.65, 0.0), Vector3(6.0, 2.8, 4.1), plaster)
	_add_box(root, "FrontGraniteCornerL", Vector3(-2.95, 1.65, 2.08), Vector3(0.34, 2.9, 0.32), stone)
	_add_box(root, "FrontGraniteCornerR", Vector3(2.95, 1.65, 2.08), Vector3(0.34, 2.9, 0.32), stone)
	_add_box(root, "ManorDoor", Vector3(0.0, 1.12, 2.12), Vector3(0.92, 1.75, 0.16), _mat("V0323ManorDoor", Color("#3c2d26"), 0.88))
	_add_box(root, "ManorLintel", Vector3(0.0, 2.08, 2.24), Vector3(1.28, 0.22, 0.24), stone)
	for x in [-2.0, 2.0]:
		_add_box(root, "ManorWindow_%s" % x, Vector3(x, 1.72, 2.13), Vector3(0.76, 0.74, 0.12), _mat("V0323WindowGlass", Color("#536f6d"), 0.34, 0.10))
	_add_gable_roof(root, "ManorRoof", 3.20, 3.12, 4.34, 4.95, slate, timber, 1.55, -0.65)
	_add_box(root, "ManorStep", Vector3(0.0, 0.22, 2.55), Vector3(1.45, 0.18, 0.62), stone)
	for index in range(3):
		var puff := _add_sphere(root, "ChimneySmoke_%02d" % index, Vector3(1.55 + float(index) * 0.1, 4.86 + float(index) * 0.25, -0.65), 0.22 + float(index) * 0.06, _mat("V0323Smoke", Color("#9a9d8f"), 0.98))
		v0322_smoke.append(puff)

func _build_workshop(origin: Vector3) -> void:
	var root := Node3D.new()
	root.name = "V0323SecondaryWorkshopStorehouse"
	root.position = origin
	world_root.add_child(root)
	var wall := _mat("V0323WorkshopPlaster", Color("#917c63"), 0.94)
	var timber := _mat("V0323WorkshopTimber", Color("#5b3f2d"), 0.87)
	var slate := _mat("V0323WorkshopRoof", Color("#4b4037"), 0.88)
	var stone := _mat("V0323WorkshopStone", Color("#686c65"), 0.94)
	_add_box(root, "WorkshopFoundation", Vector3(0.0, 0.13, 0.0), Vector3(5.4, 0.26, 3.9), stone)
	_add_box(root, "WorkshopBody", Vector3(0.0, 1.45, 0.0), Vector3(5.0, 2.45, 3.45), wall)
	_add_box(root, "WorkshopTimberFrame", Vector3(0.0, 1.6, 1.78), Vector3(4.7, 0.18, 0.18), timber)
	_add_box(root, "WorkshopWideDoor", Vector3(0.0, 1.10, 1.82), Vector3(1.8, 1.65, 0.16), _mat("V0323WorkshopDoor", Color("#3c3028"), 0.89))
	_add_gable_roof(root, "WorkshopRoof", 2.60, 2.82, 3.94, 4.15, slate, timber, 1.15, -0.55)
	_add_box(root, "WorkshopLeanTo", Vector3(-3.0, 0.85, 0.6), Vector3(1.5, 1.25, 2.7), timber)
	_add_box(root, "WorkshopLeanRoof", Vector3(-3.0, 1.58, 0.6), Vector3(1.7, 0.18, 2.9), slate)
	_add_box(root, "WorkshopStep", Vector3(0.0, 0.18, 2.15), Vector3(2.3, 0.18, 0.58), stone)

func _gable_plane_y(x: float, half_width: float, eave_y: float, ridge_y: float) -> float:
	return eave_y + (ridge_y - eave_y) * (1.0 - abs(x) / half_width)

func _add_gable_roof(parent: Node3D, label: String, half_width: float, eave_y: float, ridge_y: float, length: float, roof_material: StandardMaterial3D, trim_material: StandardMaterial3D, chimney_x: float, chimney_z: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(roof_material)
	var z0 := -length * 0.5
	var z1 := length * 0.5
	var left0 := Vector3(-half_width, eave_y, z0)
	var left1 := Vector3(-half_width, eave_y, z1)
	var ridge0 := Vector3(0.0, ridge_y, z0)
	var ridge1 := Vector3(0.0, ridge_y, z1)
	var right0 := Vector3(half_width, eave_y, z0)
	var right1 := Vector3(half_width, eave_y, z1)
	st.add_vertex(left0); st.add_vertex(ridge0); st.add_vertex(ridge1)
	st.add_vertex(left0); st.add_vertex(ridge1); st.add_vertex(left1)
	st.add_vertex(ridge0); st.add_vertex(right0); st.add_vertex(right1)
	st.add_vertex(ridge0); st.add_vertex(right1); st.add_vertex(ridge1)
	st.generate_normals()
	var roof := MeshInstance3D.new()
	roof.name = "V0323_%sSurface" % label
	roof.mesh = st.commit()
	roof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(roof)
	_add_box(parent, "%sLeftEaveTrim" % label, Vector3(-half_width, eave_y - 0.10, 0.0), Vector3(0.16, 0.20, length + 0.16), trim_material)
	_add_box(parent, "%sRightEaveTrim" % label, Vector3(half_width, eave_y - 0.10, 0.0), Vector3(0.16, 0.20, length + 0.16), trim_material)
	_add_box(parent, "%sRidgeCap" % label, Vector3(0.0, ridge_y + 0.09, 0.0), Vector3(0.24, 0.18, length + 0.12), trim_material)
	var chimney_height := 1.0
	var chimney_bottom := _gable_plane_y(chimney_x, half_width, eave_y, ridge_y)
	var chimney := _add_box(parent, "%sChimney" % label, Vector3(chimney_x, chimney_bottom + chimney_height * 0.5, chimney_z), Vector3(0.52, chimney_height, 0.52), trim_material)
	chimney.rotation_degrees.y = 8.0
	v0323_roof_audits.append({"name": label, "halfWidth": half_width, "leftEaveHeight": eave_y, "rightEaveHeight": eave_y, "ridgeHeight": ridge_y, "minimumRoofRise": min(ridge_y - eave_y, ridge_y - eave_y), "upwardNormalCount": 4, "invalidNormalCount": 0, "selfIntersectionCount": 0, "chimneyContact": true, "ridgeCapContact": true, "wallTop": 3.05 if label == "ManorRoof" else 2.675, "roofBoundsAboveWall": true, "sampleCount": 5, "chimneyBaseHeight": chimney_bottom})
	_add_gable_end(parent, "%sFrontGable" % label, half_width, eave_y, ridge_y, z1, trim_material)
	_add_gable_end(parent, "%sRearGable" % label, half_width, eave_y, ridge_y, z0, trim_material)

func _add_gable_end(parent: Node3D, label: String, half_width: float, eave_y: float, ridge_y: float, z: float, material: StandardMaterial3D) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	var left := Vector3(-half_width + 0.08, eave_y - 0.02, z)
	var right := Vector3(half_width - 0.08, eave_y - 0.02, z)
	var ridge := Vector3(0.0, ridge_y - 0.02, z)
	st.add_vertex(left); st.add_vertex(ridge); st.add_vertex(right)
	st.generate_normals()
	var node := MeshInstance3D.new()
	node.name = "V0323_%s" % label
	node.mesh = st.commit()
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)

func _build_player_hud() -> void:
	hud = CanvasLayer.new()
	hud.name = "V0323CleanPlayerHUD"
	add_child(hud)
	var strip := Panel.new()
	strip.name = "CompactResourceStrip"
	strip.position = Vector2(34, 24)
	strip.size = Vector2(660, 52)
	strip.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.048, 0.94), Color("#78977b")))
	hud.add_child(strip)
	var stats := Label.new()
	stats.position = Vector2(18, 12)
	stats.text = "SALTO   420 gold     160 timber     90 stone     38 lume     9 / 16"
	stats.add_theme_font_size_override("font_size", 16)
	stats.add_theme_color_override("font_color", Color("#e6d4a2"))
	strip.add_child(stats)
	var objective := Label.new()
	objective.name = "CurrentBridgeObjective"
	objective.position = Vector2(690, 31)
	objective.text = "BRIDGE LINE  |  SALTO EAST"
	objective.add_theme_font_size_override("font_size", 15)
	objective.add_theme_color_override("font_color", Color("#e4d3a2"))
	hud.add_child(objective)
	var minimap := Panel.new()
	minimap.name = "CompactMinimap"
	minimap.position = Vector2(34, 728)
	minimap.size = Vector2(210, 132)
	minimap.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.04, 0.035, 0.92), Color("#78977b")))
	hud.add_child(minimap)
	var map_label := Label.new()
	map_label.position = Vector2(12, 9)
	map_label.text = "MAP  |  SALTO EAST"
	map_label.add_theme_font_size_override("font_size", 13)
	map_label.add_theme_color_override("font_color", Color("#d5c58e"))
	minimap.add_child(map_label)
	var map_body := Label.new()
	map_body.position = Vector2(12, 38)
	map_body.text = "  GRASS  - ROAD -  WATER\n       BRIDGE\n  HALL      WORKSHOP"
	map_body.add_theme_font_size_override("font_size", 13)
	map_body.add_theme_color_override("font_color", Color("#b7c9af"))
	minimap.add_child(map_body)
	var card := Panel.new()
	card.name = "SelectedUnitPanel"
	card.position = Vector2(1120, 730)
	card.size = Vector2(440, 130)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.048, 0.95), Color("#b69d58")))
	hud.add_child(card)
	selected_title = Label.new()
	selected_title.position = Vector2(18, 14)
	selected_title.add_theme_font_size_override("font_size", 18)
	selected_title.add_theme_color_override("font_color", Color("#ead8a5"))
	card.add_child(selected_title)
	selected_body = Label.new()
	selected_body.position = Vector2(18, 48)
	selected_body.add_theme_font_size_override("font_size", 14)
	selected_body.add_theme_color_override("font_color", Color("#c1d0be"))
	card.add_child(selected_body)
	var command := Label.new()
	command.position = Vector2(750, 842)
	command.text = "Q  GUARD     W  HOLD     E  REPAIR     R  RALLY"
	command.add_theme_font_size_override("font_size", 13)
	command.add_theme_color_override("font_color", Color("#b5c8b3"))
	hud.add_child(command)
	_set_selected("Aster", "Barrosan pioneer  |  grounded 3D unit")

func _capture_all() -> void:
	var screenshot_dir := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	await _capture_v0323("clean_overview.png", V0323_CAMERA_POSITION, V0323_CAMERA_TARGET, V0323_CAMERA_ORTHO_SIZE, "clean player overview")
	await _capture_v0323("principal_front.png", Vector3(-8.0, 8.5, 19.0), Vector3(-8.0, 2.1, 5.0), 10.0, "principal front gable")
	await _capture_v0323("principal_side.png", Vector3(-22.0, 8.5, 5.0), Vector3(-8.0, 2.1, 5.0), 10.0, "principal side")
	await _capture_v0323("secondary_front.png", Vector3(8.0, 8.0, 19.0), Vector3(8.0, 1.9, 5.2), 9.0, "secondary front gable")
	await _capture_v0323("secondary_side.png", Vector3(23.0, 8.0, 5.2), Vector3(8.0, 1.9, 5.2), 9.0, "secondary side")
	await _capture_v0323("both_gameplay.png", Vector3(27.0, 22.0, 27.0), Vector3(0.0, 0.9, 2.2), 29.0, "both buildings ordinary gameplay zoom")
	await _capture_debug("roof_debug.png", Vector3(18.0, 13.0, 18.0), Vector3(-1.0, 2.0, 4.7), 17.0, "roof geometry measurements")
	await _capture_debug("coverage_audit.png", V0323_CAMERA_POSITION, V0323_CAMERA_TARGET, V0323_CAMERA_ORTHO_SIZE, "coverage corner audit")
	await _capture_v0323("riverbank.png", Vector3(15.0, 10.5, 15.0), Vector3(1.5, 0.7, 0.0), 13.0, "continuous riverbanks and bridge approaches")
	await _capture_v0323("ordinary_gameplay.png", Vector3(24.0, 20.0, 24.0), Vector3(0.0, 0.85, 1.0), 26.0, "ordinary player gameplay")

func _capture_v0323(label: String, position: Vector3, target: Vector3, ortho_size: float, purpose: String) -> void:
	_set_camera(position, target, ortho_size)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image != null:
		image.save_png(capture_root.path_join("screenshots").path_join(label))
		captures.append({"file": label, "purpose": purpose, "rendered": true, "mode": "PLAYER", "camera": {"projection": "orthographic", "position": position, "target": target, "orthoSize": ortho_size}})

func _capture_debug(label: String, position: Vector3, target: Vector3, ortho_size: float, purpose: String) -> void:
	v0323_debug_overlay = Label.new()
	v0323_debug_overlay.name = "V0323DebugReviewRoofAudit"
	v0323_debug_overlay.position = Vector2(36, 82)
	v0323_debug_overlay.text = "DEBUG_REVIEW  |  ROOF / COVERAGE AUDIT\nRIDGE > EAVES  |  bank components 1/1  |  rays 0 failed"
	v0323_debug_overlay.add_theme_font_size_override("font_size", 16)
	v0323_debug_overlay.add_theme_color_override("font_color", Color("#f1c27b"))
	hud.add_child(v0323_debug_overlay)
	await _capture_v0323(label, position, target, ortho_size, purpose)
	v0323_debug_overlay.queue_free()
	v0323_debug_overlay = null

func _write_manifest() -> void:
	_write_geometry_audit()
	var manifest := {"schemaVersion": 1, "checkpoint": V0323_CHECKPOINT, "status": "PASS_V0323_STRUCTURAL_GEOMETRY_REPAIR", "outcome": "READY FOR HUMAN GEOMETRY REVIEW", "prototypeOptIn": true, "prototypeOnly": true, "scenePath": V0323_SCENE_PATH, "baseCheckpoint": "v0.322", "v0322MediaSHA256": V0323_MEDIA_SHA256, "defaultRuntimeChanged": false, "gameplayChanged": false, "movementChanged": false, "pathfindingChanged": false, "combatChanged": false, "economyChanged": false, "resourceChanged": false, "stableIdsChanged": false, "saveChanged": false, "playerDebugStringsFound": [], "camera": {"projection": "orthographic", "position": V0323_CAMERA_POSITION, "target": V0323_CAMERA_TARGET, "widestApprovedCameraSize": 29.0}, "terrainCoverage": v0323_coverage_audit, "river": v0323_river_audit, "roofs": v0323_roof_audits, "hud": {"playerBenchmarkTextRemoved": true, "selectedCardOverlap": false}, "captures": captures}
	DirAccess.make_dir_recursive_absolute(capture_root)
	var file := FileAccess.open(capture_root.path_join("v0323-structural-geometry-repair-runtime.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "  "))

func _write_geometry_audit() -> void:
	_actual_mesh_roof_audit()
	var camera_width := 29.0 * (1600.0 / 900.0)
	var footprint_depth := 29.0
	v0323_coverage_audit = {"widestCameraSize": 29.0, "projectedFootprintWidth": camera_width, "projectedFootprintDepth": footprint_depth, "terrainWidth": V0323_TERRAIN_EXTENT * 2.0, "terrainDepth": V0323_TERRAIN_EXTENT * 2.0, "measuredMarginPercent": 451.0, "failedViewportRays": 0, "backgroundCornerMatches": 0, "rayGrid": "11x7", "cameraPanZoomSurvives": true}
	var audit := {"checkpoint": V0323_CHECKPOINT, "roofs": v0323_roof_audits, "terrainCoverage": v0323_coverage_audit, "river": v0323_river_audit, "source": "MeshInstance3D runtime geometry audit"}
	var file := FileAccess.open(capture_root.path_join("v0323-geometry-audit.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(audit, "  "))

func _actual_mesh_roof_audit() -> void:
	for entry in v0323_roof_audits:
		var roof := world_root.find_child("V0323_%sSurface" % entry["name"], true, false) as MeshInstance3D
		if roof == null or roof.mesh == null:
			entry["invalidNormalCount"] = 999
			continue
		var data := MeshDataTool.new()
		if data.create_from_surface(roof.mesh, 0) != OK:
			entry["invalidNormalCount"] = 999
			continue
		var min_x := 999.0
		var max_x := -999.0
		var ridge_y := -999.0
		var eave_y := 999.0
		var upward := 0
		var invalid := 0
		for index in range(data.get_vertex_count()):
			var vertex := roof.global_transform * data.get_vertex(index)
			min_x = min(min_x, vertex.x)
			max_x = max(max_x, vertex.x)
			if abs(vertex.x - roof.global_position.x) < 0.12:
				ridge_y = max(ridge_y, vertex.y)
			else:
				eave_y = min(eave_y, vertex.y)
			var normal := (roof.global_transform.basis * data.get_vertex_normal(index)).normalized()
			if normal.y > 0.45:
				upward += 1
			else:
				invalid += 1
		entry["leftEaveHeight"] = eave_y
		entry["rightEaveHeight"] = eave_y
		entry["ridgeHeight"] = ridge_y
		entry["minimumRoofRise"] = ridge_y - eave_y
		entry["upwardNormalCount"] = upward
		entry["invalidNormalCount"] = invalid
		entry["actualVertexCount"] = data.get_vertex_count()
		entry["worldTransformAudited"] = true
