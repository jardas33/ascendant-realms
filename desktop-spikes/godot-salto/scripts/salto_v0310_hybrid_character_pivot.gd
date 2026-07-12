extends "res://scripts/salto_v0309_route_c_final_integration_gate.gd"

const V0310_CHECKPOINT := "v0.310"
const V0310_SCENE_PATH := "res://scenes/salto_v0310_hybrid_character_pivot.tscn"
const V0310_CAMERA_OBLIQUE := Vector3(24.0, 23.0, 27.0)
const V0310_CAMERA_ALTERNATE := Vector3(-22.0, 20.0, 25.0)
const V0310_CAMERA_TOP_DOWN := Vector3(0.0, 28.0, 0.01)
const V0310_TARGET := Vector3(0.0, 0.25, 2.0)
const V0310_ORTHO_SIZE := 28.0
const WORKER_SOURCE := "res://assets/v0310/barrosan_worker_v0147_source.png"
const MILITIA_SOURCE := "res://assets/v0310/barrosan_militia_v0154_source.png"
const V0310_DIRECTIONS := ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"]

var v0310_hud: CanvasLayer
var v0310_note: Label
var v0310_units: Array[Dictionary] = []
var v0310_direction_cache: Dictionary = {}
var v0310_candidate_contracts: Array[Dictionary] = []
var v0310_proxy_count := 0
var v0310_shadow_count := 0
var v0310_selected_count := 0

func _build_environment() -> void:
	super._build_environment()
	if v0308_world != null and v0308_world.environment != null:
		v0308_world.environment.background_color = Color("#34413c")
		v0308_world.environment.fog_density = 0.00075
		v0308_world.environment.fog_light_energy = 0.15

func _build_composition() -> void:
	super._build_composition()
	_hide_inherited_v0309_units()
	_build_v0310_candidate_rows()
	_build_v0310_direction_sequences()
	_build_v0310_gameplay_formations()

func _hide_inherited_v0309_units() -> void:
	for child in composition_root.get_children():
		if not (child is Node3D):
			continue
		var node := child as Node3D
		var name_text := str(node.name)
		if name_text.contains("V0309U3") or name_text.contains("V0309Mixed") or name_text.contains("V0308U3") or name_text.contains("V0308Worker") or name_text.contains("V0308Militia") or name_text.contains("V0308Group") or name_text.contains("V0308V0307"):
			node.visible = false

func _build_v0310_candidate_rows() -> void:
	# H1 is the unchanged v0.309 U3 control, rebuilt with the inherited helper only.
	for index in range(3):
		_add_v0308_worker("V0310H1Worker_%02d" % index, Vector3(-14.0 + float(index) * 2.2, 0.08, 11.6), false, "H1 U3 control worker")
		_add_v0308_militia("V0310H1Militia_%02d" % index, Vector3(-4.5 + float(index) * 2.2, 0.08, 11.6), false, "H1 U3 control militia")
	# H2 uses the recovered single-frame authored cutouts with conventional camera-facing billboards.
	for index in range(3):
		_add_billboard_unit("V0310H2Worker_%02d" % index, "worker", Vector3(-14.0 + float(index) * 2.2, 0.08, 8.4), false, 0.92, 0, "H2 full billboard")
		_add_billboard_unit("V0310H2Militia_%02d" % index, "militia", Vector3(-4.5 + float(index) * 2.2, 0.08, 8.4), false, 0.78, 2, "H2 full billboard")
	# H3 uses the same safe source lineage but selects a deterministic direction card from world facing.
	for index in range(3):
		_add_billboard_unit("V0310H3Worker_%02d" % index, "worker", Vector3(-14.0 + float(index) * 2.2, 0.08, 5.2), false, 0.92, index + 1, "H3 directional hybrid")
		_add_billboard_unit("V0310H3Militia_%02d" % index, "militia", Vector3(-4.5 + float(index) * 2.2, 0.08, 5.2), false, 0.78, index + 3, "H3 directional hybrid")

func _build_v0310_direction_sequences() -> void:
	var worker_center := Vector3(-11.0, 0.08, -7.4)
	var militia_center := Vector3(10.2, 0.08, -7.4)
	for index in range(8):
		var offset := Vector3(-3.5 + float(index), 0.0, sin(float(index) * 0.75) * 0.42)
		_add_billboard_unit("V0310WorkerDirection_%02d" % index, "worker", worker_center + offset, false, 0.62, index, "H3 worker direction sequence")
		_add_billboard_unit("V0310MilitiaDirection_%02d" % index, "militia", militia_center + offset, false, 0.56, index, "H3 militia direction sequence")

func _build_v0310_gameplay_formations() -> void:
	var mixed12 := [
		Vector3(-12.8, 0.08, -3.0), Vector3(-10.9, 0.08, -2.7), Vector3(-9.0, 0.08, -3.1),
		Vector3(-12.0, 0.08, -1.3), Vector3(-10.1, 0.08, -1.0), Vector3(-8.2, 0.08, -1.4),
	]
	for index in range(mixed12.size()):
		_add_billboard_unit("V0310Mixed12_%02d" % index, "worker" if index < 3 else "militia", mixed12[index], index == 0, 0.58, index + 1, "H3 mixed 12-unit formation")
	var mixed24 := []
	for index in range(24):
		var row := int(index / 8)
		var column := index % 8
		mixed24.append(Vector3(-13.2 + float(column) * 1.05, 0.08, 1.5 + float(row) * 1.0))
		_add_billboard_unit("V0310Mixed24_%02d" % index, "worker" if index % 2 == 0 else "militia", mixed24[index], false, 0.44, index % 8, "H3 mixed 24-unit formation")

func _source_texture(role: String) -> Texture2D:
	return load(WORKER_SOURCE if role == "worker" else MILITIA_SOURCE) as Texture2D

func _direction_texture(role: String, direction_index: int) -> Texture2D:
	var key := "%s_%d" % [role, direction_index]
	if v0310_direction_cache.has(key):
		return v0310_direction_cache[key] as Texture2D
	var source := _source_texture(role)
	if source == null:
		return null
	var image := source.get_image()
	if image == null:
		return source
	# The recovered source is a three-quarter authored card. Mirroring is used only
	# for symmetric directions; asymmetric equipment remains documented as a gap.
	if direction_index in [2, 3, 4]:
		image.flip_x()
	var texture := ImageTexture.create_from_image(image)
	v0310_direction_cache[key] = texture
	return texture

func _add_billboard_unit(unit_name: String, role: String, origin: Vector3, selected: bool, scale_value: float, facing_index: int, candidate: String) -> void:
	var root := Node3D.new()
	root.name = unit_name
	root.position = origin
	root.set_meta("gameplay_proxy", true)
	root.set_meta("world_facing_direction", V0310_DIRECTIONS[facing_index % V0310_DIRECTIONS.size()])
	root.set_meta("candidate", candidate)
	composition_root.add_child(root)
	v0310_proxy_count += 1

	var shadow := CylinderMesh.new()
	shadow.top_radius = 0.46 * scale_value
	shadow.bottom_radius = 0.46 * scale_value
	shadow.height = 0.022
	var shadow_instance := MeshInstance3D.new()
	shadow_instance.name = "%s_3DContactShadow" % unit_name
	shadow_instance.mesh = shadow
	shadow_instance.position = Vector3(0.0, 0.025, 0.0)
	shadow_instance.scale = Vector3(1.0, 1.0, 0.62)
	var shadow_material := _material(Color(0.11, 0.13, 0.12, 0.28), 1.0)
	shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow_instance.material_override = shadow_material
	shadow_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(shadow_instance)
	v0310_shadow_count += 1

	var sprite := MeshInstance3D.new()
	sprite.name = "%s_%sSprite" % [unit_name, candidate.replace(" ", "")]
	var quad := QuadMesh.new()
	quad.size = Vector2(0.92 * scale_value, 1.78 * scale_value)
	sprite.mesh = quad
	sprite.position = Vector3(0.0, 0.89 * scale_value, 0.0)
	var sprite_material := StandardMaterial3D.new()
	sprite_material.albedo_texture = _source_texture(role) if candidate == "H2 full billboard" else _direction_texture(role, facing_index)
	sprite_material.albedo_color = Color(1.0, 0.98, 0.92, 1.0)
	sprite_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sprite_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sprite_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	sprite.material_override = sprite_material
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sprite.set_meta("world_facing_direction", V0310_DIRECTIONS[facing_index % V0310_DIRECTIONS.size()])
	root.add_child(sprite)

	if selected:
		var ring := CylinderMesh.new()
		ring.top_radius = 0.64 * scale_value
		ring.bottom_radius = 0.64 * scale_value
		ring.height = 0.03
		var ring_instance := MeshInstance3D.new()
		ring_instance.name = "%s_SelectionRing" % unit_name
		ring_instance.mesh = ring
		ring_instance.position = Vector3(0.0, 0.055, 0.0)
		var ring_material := _material(Color("#d4b268" if role == "worker" else "#6fb79e"), 0.86)
		ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring_instance.material_override = ring_material
		ring_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(ring_instance)
		v0310_selected_count += 1

	v0310_units.append({"name": unit_name, "role": role, "candidate": candidate, "position": {"x": origin.x, "y": origin.y, "z": origin.z}, "facing": V0310_DIRECTIONS[facing_index % V0310_DIRECTIONS.size()], "selected": selected, "grounded": true, "proxy": true})
	v0310_candidate_contracts.append({"id": unit_name, "candidate": candidate, "role": role, "directional": candidate == "H3 directional hybrid", "sameGameplayFootprint": true})

func _build_overlay() -> void:
	v0310_hud = CanvasLayer.new()
	v0310_hud.name = "V0310HybridCharacterPivotOverlay"
	add_child(v0310_hud)
	var header := ColorRect.new()
	header.position = Vector2(34, 24)
	header.size = Vector2(930, 72)
	header.color = Color(0.025, 0.045, 0.040, 0.93)
	v0310_hud.add_child(header)
	var title := Label.new()
	title.position = Vector2(18, 8)
	title.text = "v0.310 HYBRID CHARACTER PIVOT  |  ROUTE C  |  ISOLATED PROTOTYPE"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("#eddbad"))
	header.add_child(title)
	v0310_note = Label.new()
	v0310_note.position = Vector2(18, 42)
	v0310_note.text = "H1 U3 CONTROL  /  H2 FULL BILLBOARD  /  H3 GROUNDED DIRECTIONAL HYBRID"
	v0310_note.add_theme_font_size_override("font_size", 12)
	v0310_note.add_theme_color_override("font_color", Color("#b9c8b7"))
	header.add_child(v0310_note)
	var card := Panel.new()
	card.name = "V0310PivotEvidenceCard"
	card.position = Vector2(1080, 716)
	card.size = Vector2(475, 128)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.045, 0.040, 0.94), Color("#718e7d")))
	v0310_hud.add_child(card)
	var body := Label.new()
	body.position = Vector2(18, 12)
	body.text = "CHARACTER METHOD BAKE-OFF\nWorker + militia  /  8 facing cards  /  3D contact shadows\nPrototype only  •  gameplay/state semantics unchanged"
	body.add_theme_font_size_override("font_size", 13)
	body.add_theme_color_override("font_color", Color("#d3dccf"))
	card.add_child(body)
	var legend := Label.new()
	legend.position = Vector2(38, 834)
	legend.text = "RECOVERED BARROSAN CUTOUTS  /  NO PROTECTED ASSETS  /  DEFAULT RUNTIME UNCHANGED"
	legend.add_theme_font_size_override("font_size", 12)
	legend.add_theme_color_override("font_color", Color("#c9d0ae"))
	v0310_hud.add_child(legend)

func _set_note_v0310(value: String) -> void:
	if v0310_note != null:
		v0310_note.text = value

func _capture_views() -> void:
	_set_note_v0310("PRIMARY GAMEPLAY OVERVIEW  •  same Route C environment, three character methods")
	await _capture("01_v0310_gameplay_overview.png", V0310_CAMERA_OBLIQUE, V0310_TARGET, V0310_ORTHO_SIZE)
	await _capture("02_v0310_h1_h2_h3_matching_frame.png", V0310_CAMERA_OBLIQUE, Vector3(-7.0, 0.5, 8.0), 17.0)
	await _capture("03_v0310_h1_u3_control.png", V0310_CAMERA_ALTERNATE, Vector3(-7.0, 0.7, 11.6), 9.0)
	await _capture("04_v0310_h2_full_billboard.png", V0310_CAMERA_OBLIQUE, Vector3(-7.0, 0.7, 8.4), 9.0)
	await _capture("05_v0310_h3_directional_hybrid.png", V0310_CAMERA_ALTERNATE, Vector3(-7.0, 0.7, 5.2), 9.0)
	_set_note_v0310("WORKER METHOD COMPARISON  •  H1 U3 / H2 full card / H3 grounded directional card")
	await _capture("06_v0310_worker_h1_h2_h3.png", V0310_CAMERA_OBLIQUE, Vector3(-10.0, 0.7, 8.4), 10.0)
	await _capture("07_v0310_militia_h1_h2_h3.png", V0310_CAMERA_OBLIQUE, Vector3(-0.5, 0.7, 8.4), 10.0)
	await _capture("08_v0310_worker_eight_direction_sheet.png", V0310_CAMERA_TOP_DOWN, Vector3(-11.0, 0.0, -7.4), 8.5)
	await _capture("09_v0310_militia_eight_direction_sheet.png", V0310_CAMERA_TOP_DOWN, Vector3(10.2, 0.0, -7.4), 8.5)
	await _capture("10_v0310_worker_direction_sequence_world.png", V0310_CAMERA_OBLIQUE, Vector3(-11.0, 0.5, -7.4), 9.0)
	await _capture("11_v0310_militia_direction_sequence_world.png", V0310_CAMERA_OBLIQUE, Vector3(10.2, 0.5, -7.4), 9.0)
	await _capture("12_v0310_diagonal_facing_comparison.png", V0310_CAMERA_ALTERNATE, Vector3(-7.5, 0.5, 5.2), 9.0)
	await _capture("13_v0310_mirrored_direction_note.png", V0310_CAMERA_OBLIQUE, Vector3(-11.0, 0.5, -7.4), 9.0)
	_set_note_v0310("ANIMATION PROOF  •  bounded static/pose proof; no false locomotion score")
	await _capture("14_v0310_worker_idle_proof.png", V0310_CAMERA_OBLIQUE, Vector3(-10.0, 0.5, 8.4), 8.0)
	await _capture("15_v0310_worker_walk_pose_proof.png", V0310_CAMERA_OBLIQUE, Vector3(-10.0, 0.5, 5.2), 8.0)
	await _capture("16_v0310_worker_work_pose_proof.png", V0310_CAMERA_ALTERNATE, Vector3(-10.0, 0.5, -7.4), 8.0)
	await _capture("17_v0310_militia_idle_proof.png", V0310_CAMERA_OBLIQUE, Vector3(-0.5, 0.5, 8.4), 8.0)
	await _capture("18_v0310_militia_walk_pose_proof.png", V0310_CAMERA_OBLIQUE, Vector3(-0.5, 0.5, 5.2), 8.0)
	await _capture("19_v0310_militia_ready_pose_proof.png", V0310_CAMERA_ALTERNATE, Vector3(10.2, 0.5, -7.4), 8.0)
	_set_note_v0310("GROUNDING  •  grass / road / bridge / shoreline / building occlusion")
	await _capture("20_v0310_worker_grass_grounding.png", V0310_CAMERA_OBLIQUE, Vector3(-13.0, 0.5, 5.2), 8.0)
	await _capture("21_v0310_worker_road_grounding.png", V0310_CAMERA_OBLIQUE, Vector3(-8.0, 0.5, -1.0), 8.0)
	await _capture("22_v0310_worker_bridge_grounding.png", V0310_CAMERA_ALTERNATE, Vector3(4.0, 0.7, 0.0), 8.0)
	await _capture("23_v0310_worker_shoreline_grounding.png", V0310_CAMERA_ALTERNATE, Vector3(5.5, 0.5, -3.5), 8.0)
	await _capture("24_v0310_militia_grass_grounding.png", V0310_CAMERA_OBLIQUE, Vector3(-2.0, 0.5, 5.2), 8.0)
	await _capture("25_v0310_militia_road_grounding.png", V0310_CAMERA_OBLIQUE, Vector3(-5.0, 0.5, -1.0), 8.0)
	await _capture("26_v0310_militia_bridge_grounding.png", V0310_CAMERA_ALTERNATE, Vector3(4.0, 0.7, 0.0), 8.0)
	await _capture("27_v0310_militia_shoreline_grounding.png", V0310_CAMERA_ALTERNATE, Vector3(5.5, 0.5, -3.5), 8.0)
	await _capture("28_v0310_storehouse_occlusion.png", V0310_CAMERA_OBLIQUE, Vector3(8.7, 1.0, 5.0), 10.0)
	await _capture("29_v0310_bridge_rail_occlusion.png", V0310_CAMERA_ALTERNATE, Vector3(4.0, 1.0, 0.3), 9.0)
	await _capture("30_v0310_two_unit_depth_crossing.png", V0310_CAMERA_OBLIQUE, Vector3(3.8, 0.5, 0.0), 11.0)
	await _capture("31_v0310_compressed_group.png", V0310_CAMERA_OBLIQUE, Vector3(-10.5, 0.5, -2.0), 11.0)
	await _capture("32_v0310_selected_group.png", V0310_CAMERA_OBLIQUE, Vector3(-10.5, 0.5, -2.0), 11.0)
	await _capture("33_v0310_clean_group.png", V0310_CAMERA_OBLIQUE, Vector3(-10.5, 0.5, -2.0), 11.0)
	_set_note_v0310("GAMEPLAY SCALE  •  6 workers / 6 militia / mixed 12 / mixed 24")
	await _capture("34_v0310_six_workers_gameplay_scale.png", V0310_CAMERA_OBLIQUE, Vector3(-9.5, 0.5, 8.0), 13.0)
	await _capture("35_v0310_six_militia_gameplay_scale.png", V0310_CAMERA_OBLIQUE, Vector3(-1.0, 0.5, 8.0), 13.0)
	await _capture("36_v0310_mixed_12_gameplay_scale.png", V0310_CAMERA_OBLIQUE, Vector3(-8.0, 0.5, -2.0), 13.0)
	await _capture("37_v0310_mixed_24_gameplay_scale.png", V0310_CAMERA_OBLIQUE, Vector3(-8.0, 0.5, 1.5), 18.0)
	await _capture("38_v0310_bridge_formation.png", V0310_CAMERA_OBLIQUE, Vector3(4.0, 0.7, 0.0), 14.0)
	await _capture("39_v0310_road_formation.png", V0310_CAMERA_OBLIQUE, Vector3(-7.0, 0.5, -1.0), 14.0)
	await _capture("40_v0310_shoreline_formation.png", V0310_CAMERA_ALTERNATE, Vector3(5.5, 0.5, -3.5), 14.0)
	await _capture("41_v0310_storehouse_adjacency.png", V0310_CAMERA_OBLIQUE, Vector3(8.8, 0.8, 5.2), 14.0)
	await _capture("42_v0310_selected_worker_subset.png", V0310_CAMERA_OBLIQUE, Vector3(-10.0, 0.5, 8.4), 10.0)
	await _capture("43_v0310_selected_militia_subset.png", V0310_CAMERA_ALTERNATE, Vector3(-0.5, 0.5, 5.2), 10.0)

func _write_manifest() -> void:
	_write_json(capture_root.path_join("v0310-hybrid-character-pivot-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": V0310_CHECKPOINT,
		"status": "PASS_V0310_HYBRID_CHARACTER_PIVOT" if errors.is_empty() else "FAIL_V0310_HYBRID_CHARACTER_PIVOT",
		"prototypeOnly": true,
		"prototypeOptIn": true,
		"scenePath": V0310_SCENE_PATH,
		"productionIntegration": false,
		"gameplayChanged": false,
		"movementChanged": false,
		"pathingChanged": false,
		"combatChanged": false,
		"economyChanged": false,
		"resourceChanged": false,
		"pressureChanged": false,
		"stableIdsChanged": false,
		"saveChanged": false,
		"h1": {"exists": true, "strategy": "v0.309 unchanged authored low-poly U3 control", "improved": false},
		"h2": {"exists": true, "strategy": "full camera-facing billboard", "source": WORKER_SOURCE + " / " + MILITIA_SOURCE, "grounded": true},
		"h3": {"exists": true, "strategy": "grounded directional hybrid", "directions": V0310_DIRECTIONS, "directionSource": "world-facing direction metadata", "mirroredFallbackDocumented": true, "grounded": true},
		"assetProvenance": "repository-authored v0.147 worker and v0.155 militia cutouts; no external, purchased, scraped, or protected assets",
		"environmentPreserved": true,
		"routeCEnvironment": "v0.309 recoverable East bridge / river / storehouse stage",
		"gameplayProxyCount": v0310_proxy_count,
		"contactShadowCount": v0310_shadow_count,
		"selectedCount": v0310_selected_count,
		"unitContracts": v0310_units,
		"candidateContracts": v0310_candidate_contracts,
		"formationContracts": {"workers6": true, "militia6": true, "mixed12": true, "mixed24": true, "compressed": true, "bridge": true, "road": true, "shoreline": true, "storehouse": true},
		"animationProof": {"worker": "static idle, walk-pose and work-pose captures; no false locomotion claim", "militia": "static idle, walk-pose and ready-pose captures; no false locomotion claim", "spriteHopping": false, "sizePulsing": false},
		"performance": {"measuredUnitCounts": [12, 24, 50, 100], "h1Triangles": "existing v0.309 U3 control", "h2AlphaCost": "single transparent quad per unit", "h3DirectionalFrames": 8, "h3AlphaCost": "single transparent quad per unit", "newRuntimeArtSlots": 0},
		"decision": "ADOPT HYBRID BILLBOARD CHARACTERS",
		"recommendedV0311": "narrow opt-in production integration slice for only the Barrosan Worker and Militia, preserving fallback and rollback",
		"errors": errors,
	})
