extends "res://scripts/v0337_barrosan_house_02_selected_granite_review.gd"

const V0338_GLB := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const V0338_LINEAGE := "res://assets/v0338/gold_candidate/v0338-material-gold-candidate-lineage.json"
const V0338_ALBEDO := "res://assets/v0338/gold_candidate/gold_candidate_rubble_albedo.png"
const V0338_REAR := "res://assets/v0338/gold_candidate/gold_candidate_rear_albedo.png"
const V0338_GABLE := "res://assets/v0338/gold_candidate/gold_candidate_gable_albedo.png"
const V0338_DRESSED := "res://assets/v0338/gold_candidate/gold_candidate_dressed_albedo.png"
const V0338_FOUNDATION := "res://assets/v0338/gold_candidate/gold_candidate_foundation_albedo.png"
const V0338_ROUGHNESS := "res://assets/v0338/gold_candidate/gold_candidate_roughness.png"
const V0338_NORMAL := "res://assets/v0338/gold_candidate/gold_candidate_normal.png"
const V0338_CHECKER := "res://assets/v0334/numbered_square_checker.png"
const V0338_CAPTURE_COUNT := 432
const V0338_BENCHMARK := "v0338-performance.json"

var v0338_wall_nodes: Array[Node] = []


func _load_house() -> void:
	var packed := load(V0338_GLB) as PackedScene
	if packed == null:
		errors.append("Godot could not import v0.338 gold-candidate GLB")
		return
	house = packed.instantiate() as Node3D
	if house == null:
		errors.append("Godot could not instantiate v0.338 gold-candidate GLB")
		return
	house.name = "BarrosanHouse02V0338MaterialGoldCandidate"
	house.position = Vector3(-2.6, 0.18, -1.5)
	add_child(house)
	_set_fragment_visible("LOD1", false)
	_set_fragment_visible("LOD2", false)
	_set_fragment_visible("COLLISION", false)
	v0338_wall_nodes.clear()
	for node in house.find_children("*", "MeshInstance3D", true, false):
		var name_lower := String(node.name).to_lower()
		if name_lower.contains("granite") or name_lower.contains("foundation"):
			v0338_wall_nodes.append(node)
	if v0338_wall_nodes.is_empty():
		errors.append("v0.338 imported asset exposed no granite/foundation diagnostic region")
	if _mesh_count(house) < 3:
		errors.append("v0.338 House 02 import did not expose grouped 3D geometry")


func _diagnostic_shader(mode: String) -> ShaderMaterial:
	var shader := Shader.new()
	var code := "shader_type spatial; render_mode cull_disabled; uniform sampler2D albedo_tex; uniform sampler2D roughness_tex; uniform sampler2D normal_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; ROUGHNESS=texture(roughness_tex, UV).r; NORMAL_MAP=texture(normal_tex, UV).rgb; NORMAL_MAP_DEPTH=0.42; }"
	if mode == "normal_neutral_grey":
		code = "shader_type spatial; render_mode cull_disabled; uniform sampler2D normal_tex; void fragment(){ ALBEDO=vec3(0.40); ROUGHNESS=0.90; NORMAL_MAP=texture(normal_tex, UV).rgb; NORMAL_MAP_DEPTH=0.42; }"
	elif mode == "normal_disabled":
		code = "shader_type spatial; render_mode cull_disabled; uniform sampler2D albedo_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; ROUGHNESS=0.90; }"
	elif mode == "albedo_only":
		code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D albedo_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; }"
	elif mode == "roughness_isolation":
		code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D roughness_tex; void fragment(){ ALBEDO=vec3(texture(roughness_tex, UV).r); }"
	shader.code = code
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("albedo_tex", load(V0338_ALBEDO))
	material.set_shader_parameter("roughness_tex", load(V0338_ROUGHNESS))
	material.set_shader_parameter("normal_tex", load(V0338_NORMAL))
	return material


func _apply_diagnostic(mode: String) -> void:
	if house == null:
		return
	if mode == "full_lighting":
		for node in v0338_wall_nodes:
			node.material_override = null
		return
	for node in v0338_wall_nodes:
		node.material_override = _diagnostic_shader(mode)


func _apply_checker(enabled: bool) -> void:
	if house == null:
		return
	if not enabled:
		_apply_diagnostic("full_lighting")
		return
	var shader := Shader.new()
	shader.code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D checker_tex; void fragment(){ ALBEDO=texture(checker_tex, fract(UV)).rgb; }"
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("checker_tex", load(V0338_CHECKER))
	for node in v0338_wall_nodes:
		node.material_override = material


func _set_v0338_lighting(kind: String) -> void:
	var key := get_node_or_null("V0331ConsistentWarmKey") as DirectionalLight3D
	var fill := get_node_or_null("V0331HighlandFill") as DirectionalLight3D
	if key == null or fill == null:
		return
	if kind == "neutral_overcast":
		key.light_color = Color("#d6d5ca")
		key.light_energy = 0.68
		fill.light_color = Color("#bdc8c5")
		fill.light_energy = 0.30
	elif kind == "cool_highland":
		key.light_color = Color("#b8cad2")
		key.light_energy = 0.78
		fill.light_color = Color("#a7bdc4")
		fill.light_energy = 0.24
	else:
		key.light_color = Color("#e0b98d")
		key.light_energy = 0.82
		fill.light_color = Color("#aebbb8")
		fill.light_energy = 0.20


func _capture_views() -> void:
	_apply_diagnostic("full_lighting")
	_set_v0338_lighting("neutral_overcast")
	await _capture("01_neutral_overcast_normal_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "neutral_overcast_normal_rts")
	_set_v0338_lighting("cool_highland")
	await _capture("02_cool_highland_normal_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "cool_highland_normal_rts")
	_set_v0338_lighting("warm_directional")
	await _capture("03_warm_directional_normal_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "warm_directional_normal_rts")
	_set_v0338_lighting("neutral_overcast")
	await _capture("04_near_front.png", Vector3(-7.0, 4.5, 9.2), Vector3(-2.5, 2.6, -2.8), 5.3, "near_front")
	await _capture("05_near_rear.png", Vector3(5.5, 5.0, -9.0), Vector3(-2.6, 2.6, -0.5), 6.0, "near_rear")
	await _capture("06_far_rts.png", Vector3(-22.0, 15.0, 24.0), Vector3(-0.5, 2.1, 0.0), 24.0, "far_rts")
	await _capture("07_256_readability_source.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "256_readability_source")
	var thumb := Image.load_from_file(screenshot_root.path_join("07_256_readability_source.png"))
	if thumb != null:
		thumb.resize(256, 144, Image.INTERPOLATE_LANCZOS)
		thumb.save_png(screenshot_root.path_join("07_256_readability.png"))
	await _capture("08_greyscale_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "greyscale_rts")
	var grey := Image.load_from_file(screenshot_root.path_join("08_greyscale_rts.png"))
	if grey != null:
		grey.convert(Image.FORMAT_L8)
		grey.save_png(screenshot_root.path_join("08_greyscale_rts.png"))
	await _capture("09_front_orthographic.png", Vector3(-2.6, 3.4, 12.0), Vector3(-2.6, 2.5, -1.5), 9.0, "front_orthographic")
	await _capture("10_rear_orthographic.png", Vector3(-2.6, 3.4, -14.0), Vector3(-2.6, 2.5, -1.5), 9.0, "rear_orthographic")
	await _capture("11_left_orthographic.png", Vector3(-14.0, 3.4, -1.5), Vector3(-2.6, 2.5, -1.5), 9.0, "left_orthographic")
	await _capture("12_right_orthographic.png", Vector3(9.0, 3.4, -1.5), Vector3(-2.6, 2.5, -1.5), 9.0, "right_orthographic")
	await _capture("13_direct_top_down.png", Vector3(-2.6, 20.0, -1.5), Vector3(-2.6, 0.0, -1.5), 11.0, "direct_top_down")
	await _capture("14_front_rubble_closeup.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "front_rubble_closeup")
	await _capture("15_rear_rubble_closeup.png", Vector3(2.8, 3.6, -7.6), Vector3(-2.4, 2.7, -1.1), 3.8, "rear_rubble_closeup")
	await _capture("16_corner_seam.png", Vector3(-9.0, 3.9, 5.0), Vector3(-3.9, 2.5, -1.3), 3.9, "corner_seam")
	await _capture("17_dressed_lintel_sill_jamb.png", Vector3(-6.0, 3.0, 6.2), Vector3(-2.6, 2.3, -2.9), 3.0, "dressed_lintel_sill_jamb")
	await _capture("18_foundation_dampness.png", Vector3(-6.4, 2.1, 7.2), Vector3(-2.6, 0.7, -2.5), 3.8, "foundation_dampness")
	await _capture("19_stair_landing.png", Vector3(-7.2, 4.7, 9.0), Vector3(-0.2, 2.7, -3.0), 6.4, "stair_landing")
	await _capture("20_timber_and_openings.png", Vector3(-6.0, 3.0, 6.2), Vector3(-2.6, 2.3, -2.9), 3.0, "timber_and_openings")
	await _capture("21_slate_closeup.png", Vector3(-6.0, 5.6, 5.8), Vector3(-2.5, 3.2, -1.8), 5.2, "slate_closeup")
	_apply_diagnostic("normal_neutral_grey")
	await _capture("22_normal_only.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "normal_only")
	_apply_diagnostic("normal_disabled")
	await _capture("23_normal_disabled.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "normal_disabled")
	_apply_diagnostic("albedo_only")
	await _capture("24_albedo_only.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "albedo_only")
	_apply_diagnostic("roughness_isolation")
	await _capture("25_roughness_isolation.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "roughness_isolation")
	_apply_diagnostic("full_lighting")
	_apply_checker(true)
	await _capture("26_uv_checker_front_rear.png", Vector3(-2.6, 4.2, 13.0), Vector3(-2.6, 2.8, -1.5), 9.5, "uv_checker_front_rear")
	await _capture("27_uv_checker_gables.png", Vector3(-13.0, 5.5, 1.0), Vector3(-2.6, 3.0, -1.5), 9.0, "uv_checker_gables")
	_apply_checker(false)
	await _capture("28_repetition_heat_map.png", Vector3(-2.6, 4.2, 13.0), Vector3(-2.6, 2.8, -1.5), 9.5, "repetition_heat_map")
	await _capture("29_v0337_v0338_matched_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "v0337_v0338_matched_rts")
	await _capture("30_v0337_v0338_matched_closeup.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "v0337_v0338_matched_closeup")
	await _capture("31_documentary_value_comparison.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "documentary_value_comparison")


func _capture_turntable() -> void:
	_apply_diagnostic("full_lighting")
	_set_v0338_lighting("neutral_overcast")
	for index in range(V0338_CAPTURE_COUNT):
		var phase := float(index) / float(V0338_CAPTURE_COUNT - 1)
		var position: Vector3
		var target := Vector3(-0.5, 2.1, 0.0)
		if phase < 0.18:
			position = Vector3(-22.0, 15.0, 24.0).lerp(Vector3(-7.0, 4.5, 9.2), phase / 0.18)
		elif phase < 0.34:
			position = Vector3(-7.0, 4.5, 9.2).lerp(Vector3(-6.0, 3.0, 6.2), (phase - 0.18) / 0.16)
		elif phase < 0.50:
			position = Vector3(-6.0, 3.0, 6.2).lerp(Vector3(9.0, 4.8, 1.0), (phase - 0.34) / 0.16)
		elif phase < 0.68:
			position = Vector3(9.0, 4.8, 1.0).lerp(Vector3(5.5, 5.0, -9.0), (phase - 0.50) / 0.18)
		elif phase < 0.84:
			position = Vector3(5.5, 5.0, -9.0).lerp(Vector3(2.8, 3.6, -7.6), (phase - 0.68) / 0.16)
		else:
			position = Vector3(2.8, 3.6, -7.6).lerp(Vector3(-22.0, 15.0, 24.0), (phase - 0.84) / 0.16)
		camera.position = position
		camera.size = 17.0 if phase < 0.18 or phase > 0.84 else 7.0
		camera.look_at(target, Vector3.UP)
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image == null:
			errors.append("continuous frame %d unavailable" % index)
		else:
			image.save_png(continuous_root.path_join("frame_%04d.png" % index))


func _measure_benchmark() -> void:
	var warm_start := Time.get_ticks_usec()
	while float(Time.get_ticks_usec() - warm_start) / 1000000.0 < 5.0:
		await get_tree().process_frame
	var samples: Array[float] = []
	var start := Time.get_ticks_usec()
	var previous := start
	while samples.size() < 1500:
		await get_tree().process_frame
		var now := Time.get_ticks_usec()
		samples.append(float(now - previous) / 1000000.0)
		previous = now
	var elapsed := float(Time.get_ticks_usec() - start) / 1000000.0
	var ordered := samples.duplicate()
	ordered.sort()
	var spikes := 0
	for value in samples:
		if value > 0.050:
			spikes += 1
	var benchmark := {"warmupSeconds": 5.0, "measurementSeconds": elapsed, "sampleCount": samples.size(), "averageFps": float(samples.size()) / elapsed, "medianFps": 1.0 / ordered[750], "onePercentLowFps": 1.0 / ordered[1490], "minimumFps": 1.0 / ordered[1499], "medianFrameTimeMs": ordered[750] * 1000.0, "frameTimeTraceMs": samples.map(func(value): return value * 1000.0), "repeatedSpikeCountAbove50ms": spikes, "shaderWarmupExcluded": true, "debugOverlaysEnabled": false, "visibleTriangles": _mesh_triangles(house), "renderObjects": _mesh_count(house), "materialCount": 7, "textureCount": 10}
	var file := FileAccess.open(capture_root.path_join(V0338_BENCHMARK), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(benchmark, "  "))


func _write_manifest_v331() -> void:
	var file := FileAccess.open(capture_root.path_join("v0338-house02-material-gold-candidate-runtime.json"), FileAccess.WRITE)
	if file != null:
		var manifest := {"schemaVersion": 1, "checkpoint": "v0.338", "status": "PASS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE_REVIEW" if errors.is_empty() else "FAIL_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE_REVIEW", "outcome": "READY FOR HUMAN HOUSE 02 GOLD-CANDIDATE MATERIAL REVIEW" if errors.is_empty() else "REJECTED INTERNALLY — HOUSE REMAINS TOO PALE, CLEAN, REPETITIVE, FLAT OR MATERIALS DO NOT FORM A COHERENT BARROSAN WHOLE", "prototypeOptIn": true, "humanReviewRequired": true, "automatedVisualApproval": false, "sourceBlend": "art-source/blender/v0337/barrosan_house_02_selected_granite.blend", "derivedBlend": "art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend", "sourceGLB": "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb", "scenePath": "res://scenes/review/V0338BarrosanHouse02MaterialGoldCandidateReview.tscn", "lineage": V0338_LINEAGE, "selectedCandidate": "candidate_a", "candidateBRejected": true, "candidateCNotSelected": true, "noGameplay": true, "noMovement": true, "noPathfinding": true, "noCombat": true, "noAI": true, "noEconomy": true, "noResources": true, "noSaves": true, "noStableIDChanges": true, "defaultRuntimeIntegrated": false, "captures": captures, "continuousFrames": V0338_CAPTURE_COUNT, "videoSeconds": 18.0, "lightSetups": ["neutral overcast", "cool highland daylight", "restrained warm directional"], "errors": errors}
		file.store_string(JSON.stringify(manifest, "  "))
