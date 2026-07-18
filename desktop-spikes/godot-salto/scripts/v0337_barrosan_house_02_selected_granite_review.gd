extends "res://scripts/v0334_barrosan_house_02_granite_authenticity.gd"

const V0337_GLB := "res://assets/v0337/barrosan_house_02_selected_granite.glb"
const V0337_LINEAGE := "res://assets/v0337/selected_granite/v0337-selected-granite-lineage.json"
const V0337_CHECKER := "res://assets/v0334/numbered_square_checker.png"
const V0337_ALBEDO := "res://assets/v0337/selected_granite/selected_granite_albedo.png"
const V0337_DRESSED_ALBEDO := "res://assets/v0337/selected_granite/selected_granite_dressed_albedo.png"
const V0337_ROUGHNESS := "res://assets/v0337/selected_granite/selected_granite_roughness.png"
const V0337_NORMAL := "res://assets/v0337/selected_granite/selected_granite_normal.png"
const V0337_CAPTURE_COUNT := 360
const V0337_BENCHMARK := "v0337-performance.json"

var v0337_wall_nodes: Array[Node] = []
var v0337_capture_records: Array[Dictionary] = []


func _load_house() -> void:
	var packed := load(V0337_GLB) as PackedScene
	if packed == null:
		errors.append("Godot could not import v0.337 selected-granite GLB")
		return
	house = packed.instantiate() as Node3D
	if house == null:
		errors.append("Godot could not instantiate v0.337 selected-granite GLB")
		return
	house.name = "BarrosanHouse02V0337SelectedGranite"
	house.position = Vector3(-2.6, 0.18, -1.5)
	add_child(house)
	_apply_house_material_language()
	_set_fragment_visible("LOD1", false)
	_set_fragment_visible("LOD2", false)
	_set_fragment_visible("COLLISION", false)
	v0337_wall_nodes.clear()
	for node in house.find_children("*", "MeshInstance3D", true, false):
		var name_lower := String(node.name).to_lower()
		if name_lower.contains("granite") or name_lower.contains("foundation"):
			v0337_wall_nodes.append(node)
	if v0337_wall_nodes.is_empty():
		errors.append("v0.337 imported asset exposed no granite/foundation diagnostic region")
	if _mesh_count(house) < 3:
		errors.append("v0.337 House 02 import did not expose grouped 3D geometry")


func _apply_house_material_language() -> void:
	if house == null:
		return
	for node in house.find_children("*", "MeshInstance3D", true, false):
		node.material_override = null


func _diagnostic_shader(mode: String) -> ShaderMaterial:
	var shader := Shader.new()
	var code := "shader_type spatial; render_mode cull_disabled; uniform sampler2D albedo_tex; uniform sampler2D roughness_tex; uniform sampler2D normal_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; ROUGHNESS=texture(roughness_tex, UV).r; NORMAL_MAP=texture(normal_tex, UV).rgb; NORMAL_MAP_DEPTH=0.42; }"
	if mode == "normal_neutral_grey":
		code = "shader_type spatial; render_mode cull_disabled; uniform sampler2D normal_tex; void fragment(){ ALBEDO=vec3(0.46); ROUGHNESS=0.88; NORMAL_MAP=texture(normal_tex, UV).rgb; NORMAL_MAP_DEPTH=0.42; }"
	elif mode == "normal_disabled":
		code = "shader_type spatial; render_mode cull_disabled; void fragment(){ ALBEDO=vec3(0.46); ROUGHNESS=0.88; }"
	elif mode == "albedo_only":
		code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D albedo_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; }"
	elif mode == "roughness_isolation":
		code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D roughness_tex; void fragment(){ ALBEDO=vec3(texture(roughness_tex, UV).r); }"
	shader.code = code
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("albedo_tex", load(V0337_ALBEDO))
	material.set_shader_parameter("roughness_tex", load(V0337_ROUGHNESS))
	material.set_shader_parameter("normal_tex", load(V0337_NORMAL))
	return material


func _apply_diagnostic(mode: String) -> void:
	if house == null:
		return
	if mode == "full_lighting":
		_apply_house_material_language()
		return
	for node in v0337_wall_nodes:
		node.material_override = _diagnostic_shader(mode)


func _shader_checker() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D checker_tex; void fragment(){ ALBEDO=texture(checker_tex, fract(UV)).rgb; }"
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("checker_tex", load(V0337_CHECKER))
	return material


func _set_lighting(neutral: bool) -> void:
	var key := get_node_or_null("V0331ConsistentWarmKey") as DirectionalLight3D
	var fill := get_node_or_null("V0331HighlandFill") as DirectionalLight3D
	if key == null or fill == null:
		return
	if neutral:
		key.light_color = Color("#c8d0cc")
		key.light_energy = 0.72
		fill.light_color = Color("#b7c3c3")
		fill.light_energy = 0.30
	else:
		key.light_color = Color("#e4bd91")
		key.light_energy = 0.86
		fill.light_color = Color("#aabdbb")
		fill.light_energy = 0.20


func _capture_views() -> void:
	_apply_diagnostic("full_lighting")
	_set_lighting(true)
	await _capture("01_normal_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "normal_rts")
	await _capture("02_near_front_three_quarter.png", Vector3(-7.0, 4.5, 9.2), Vector3(-2.5, 2.6, -2.8), 5.3, "near_front_three_quarter")
	await _capture("03_near_rear_three_quarter.png", Vector3(5.5, 5.0, -9.0), Vector3(-2.6, 2.6, -0.5), 6.0, "near_rear_three_quarter")
	await _capture("04_far_rts.png", Vector3(-22.0, 15.0, 24.0), Vector3(-0.5, 2.1, 0.0), 24.0, "far_rts")
	await _capture("05_front_orthographic.png", Vector3(-2.6, 3.4, 12.0), Vector3(-2.6, 2.5, -1.5), 9.0, "front_orthographic")
	await _capture("06_rear_orthographic.png", Vector3(-2.6, 3.4, -14.0), Vector3(-2.6, 2.5, -1.5), 9.0, "rear_orthographic")
	await _capture("07_left_orthographic.png", Vector3(-14.0, 3.4, -1.5), Vector3(-2.6, 2.5, -1.5), 9.0, "left_orthographic")
	await _capture("08_right_orthographic.png", Vector3(9.0, 3.4, -1.5), Vector3(-2.6, 2.5, -1.5), 9.0, "right_orthographic")
	await _capture("09_direct_top_down.png", Vector3(-2.6, 20.0, -1.5), Vector3(-2.6, 0.0, -1.5), 11.0, "direct_top_down")
	await _capture("10_256_readability_source.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "256_readability_source")
	var thumb := Image.load_from_file(screenshot_root.path_join("10_256_readability_source.png"))
	if thumb != null:
		thumb.resize(256, 144, Image.INTERPOLATE_LANCZOS)
		thumb.save_png(screenshot_root.path_join("10_256_readability.png"))
	await _capture("11_greyscale_normal_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "greyscale_normal_rts")
	var grey := Image.load_from_file(screenshot_root.path_join("11_greyscale_normal_rts.png"))
	if grey != null:
		grey.convert(Image.FORMAT_L8)
		grey.save_png(screenshot_root.path_join("11_greyscale_normal_rts.png"))
	_set_lighting(true)
	await _capture("12_neutral_overcast.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "neutral_overcast")
	_set_lighting(false)
	await _capture("13_warm_directional.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "warm_directional")
	_set_lighting(true)
	await _capture("14_damp_foundation_closeup.png", Vector3(-6.4, 2.1, 7.2), Vector3(-2.6, 0.7, -2.5), 3.8, "damp_foundation_closeup")
	await _capture("15_front_wall_material_closeup.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "front_wall_material_closeup")
	await _capture("16_corner_seam_closeup.png", Vector3(-9.0, 3.9, 5.0), Vector3(-3.9, 2.5, -1.3), 3.9, "corner_seam_closeup")
	await _capture("17_lintel_sill_jamb_closeup.png", Vector3(-6.0, 3.0, 6.2), Vector3(-2.6, 2.3, -2.9), 3.0, "lintel_sill_jamb_closeup")
	await _capture("18_stair_landing_closeup.png", Vector3(-7.2, 4.7, 9.0), Vector3(-0.2, 2.7, -3.0), 6.4, "stair_landing_closeup")
	_apply_diagnostic("normal_neutral_grey")
	await _capture("19_normal_only.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "normal_only")
	_apply_diagnostic("normal_disabled")
	await _capture("20_normal_disabled.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "normal_disabled")
	_apply_diagnostic("albedo_only")
	await _capture("21_albedo_only.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "albedo_only")
	_apply_diagnostic("roughness_isolation")
	await _capture("22_roughness_isolation.png", Vector3(-6.2, 3.6, 7.0), Vector3(-2.7, 2.7, -2.9), 3.8, "roughness_isolation")
	_apply_diagnostic("full_lighting")
	_apply_checker(true)
	await _capture("23_uv_checker_front_rear.png", Vector3(-2.6, 4.2, 13.0), Vector3(-2.6, 2.8, -1.5), 9.5, "uv_checker_front_rear")
	await _capture("24_uv_checker_gables.png", Vector3(-13.0, 5.5, 1.0), Vector3(-2.6, 3.0, -1.5), 9.0, "uv_checker_gables")
	_apply_checker(false)
	await _capture("25_v0334_v0337_matched_normal_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "v0334_v0337_matched_normal_rts")


func _capture_turntable() -> void:
	_apply_diagnostic("full_lighting")
	for index in range(V0337_CAPTURE_COUNT):
		var phase := float(index) / float(V0337_CAPTURE_COUNT - 1)
		var position: Vector3
		var target := Vector3(-0.5, 2.1, 0.0)
		if phase < 0.28:
			var p := phase / 0.28
			position = Vector3(-22.0, 15.0, 24.0).lerp(Vector3(-7.0, 4.5, 9.2), p)
		elif phase < 0.48:
			var p := (phase - 0.28) / 0.20
			position = Vector3(-7.0, 4.5, 9.2).lerp(Vector3(9.0, 4.8, 1.0), p)
		elif phase < 0.72:
			var p := (phase - 0.48) / 0.24
			position = Vector3(9.0, 4.8, 1.0).lerp(Vector3(5.5, 5.0, -9.0), p)
		else:
			var p := (phase - 0.72) / 0.28
			position = Vector3(5.5, 5.0, -9.0).lerp(Vector3(-22.0, 15.0, 24.0), p)
		camera.position = position
		camera.size = 17.0 if phase < 0.28 or phase > 0.72 else 7.0
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
	var sum := 0.0
	for value in samples:
		sum += value
	var spikes := 0
	for value in samples:
		if value > 0.050:
			spikes += 1
	var benchmark := {"warmupSeconds": 5.0, "measurementSeconds": elapsed, "sampleCount": samples.size(), "averageFps": float(samples.size()) / elapsed, "medianFps": 1.0 / ordered[750], "onePercentLowFps": 1.0 / ordered[1490], "minimumFps": 1.0 / ordered[1499], "medianFrameTimeMs": ordered[750] * 1000.0, "frameTimeTraceMs": samples.map(func(value): return value * 1000.0), "repeatedSpikeCountAbove50ms": spikes, "shaderWarmupExcluded": true, "debugOverlaysEnabled": false, "visibleTriangles": _mesh_triangles(house), "renderObjects": _mesh_count(house), "materialCount": 7}
	var file := FileAccess.open(capture_root.path_join(V0337_BENCHMARK), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(benchmark, "  "))


func _write_manifest_v331() -> void:
	var file := FileAccess.open(capture_root.path_join("v0337-house02-selected-granite-runtime.json"), FileAccess.WRITE)
	if file != null:
		var manifest := {"schemaVersion": 1, "checkpoint": "v0.337", "status": "PASS_V0337_HOUSE02_SELECTED_GRANITE_REVIEW" if errors.is_empty() else "FAIL_V0337_HOUSE02_SELECTED_GRANITE_REVIEW", "outcome": "READY FOR HUMAN HOUSE 02 SELECTED-GRANITE APPLICATION REVIEW" if errors.is_empty() else "REJECTED INTERNALLY — FULL-HOUSE MATERIAL STILL READS AS TILED, PALE, FLAT, BRICK-LIKE OR NON-GRANITE", "prototypeOptIn": true, "humanReviewRequired": true, "automatedVisualApproval": false, "sourceBlend": "art-source/blender/v0334/barrosan_house_gold_02.blend", "derivedBlend": "art-source/blender/v0337/barrosan_house_02_selected_granite.blend", "sourceGLB": "res://assets/v0337/barrosan_house_02_selected_granite.glb", "scenePath": "res://scenes/review/V0337BarrosanHouse02SelectedGraniteReview.tscn", "selectedCandidate": "candidate_a", "candidateBRejected": true, "candidateCNotSelected": true, "noMaterial1Relief": true, "noGameplay": true, "noMovement": true, "noPathfinding": true, "noCombat": true, "noEconomy": true, "noResources": true, "defaultRuntimeIntegrated": false, "captures": captures, "continuousFrames": V0337_CAPTURE_COUNT, "errors": errors}
		file.store_string(JSON.stringify(manifest, "  "))
