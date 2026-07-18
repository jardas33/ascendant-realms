extends "res://scripts/v0331_barrosan_house_02_review.gd"

const V0333_GLB := "res://assets/v0333/barrosan_house_gold_02.glb"
const V0333_METRICS := "res://assets/v0333/barrosan_house_gold_02.export.json"
const V0333_CHECKER := "res://assets/v0333/numbered_square_checker.png"
const V0333_ALBEDO := "res://assets/v0333/barrosan_house_gold_02_granite_albedo_1024.png"
const V0333_NORMAL := "res://assets/v0333/barrosan_house_gold_02_granite_normal_1024.png"
const V0333_BENCHMARK := "v0333-benchmark.json"


func _load_house() -> void:
	var packed := load(V0333_GLB) as PackedScene
	if packed == null:
		errors.append("Godot could not import v0.333 House 02 GLB")
		return
	house = packed.instantiate() as Node3D
	if house == null:
		errors.append("Godot could not instantiate v0.333 House 02 GLB")
		return
	house.name = "BarrosanHouse02V0333GraniteRoof"
	house.position = Vector3(-2.6, 0.18, -1.5)
	add_child(house)
	_apply_house_material_language()
	_set_fragment_visible("LOD1", false)
	_set_fragment_visible("LOD2", false)
	_set_fragment_visible("COLLISION", false)
	if _mesh_count(house) < 3:
		errors.append("House 02 v0.333 import did not expose grouped 3D geometry")


func _diagnostic_shader(mode: String) -> ShaderMaterial:
	var shader := Shader.new()
	var code := "shader_type spatial; render_mode cull_disabled; uniform sampler2D albedo_tex; uniform sampler2D normal_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; ROUGHNESS=0.93;"
	if mode == "albedo_only":
		code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D albedo_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; }"
	elif mode == "normal_neutral_grey":
		code += " ALBEDO=vec3(0.46,0.46,0.46); NORMAL_MAP=texture(normal_tex, UV).rgb; NORMAL_MAP_DEPTH=0.9; }"
	else:
		code += " }"
	shader.code = code
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("albedo_tex", load(V0333_ALBEDO))
	material.set_shader_parameter("normal_tex", load(V0333_NORMAL))
	return material


func _apply_diagnostic(mode: String) -> void:
	if house == null:
		return
	if mode == "full_lighting":
		_apply_house_material_language()
		return
	for node in house.find_children("*", "MeshInstance3D", true, false):
		node.material_override = _diagnostic_shader(mode)


func _shader_checker() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type spatial; render_mode cull_disabled; uniform sampler2D checker_tex; void fragment(){ ALBEDO=texture(checker_tex,fract(UV)).rgb; ROUGHNESS=0.84; }"
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("checker_tex", load(V0333_CHECKER))
	return material


func _capture_unlabelled() -> void:
	_apply_diagnostic("full_lighting")
	await _capture("diagnostic_granite_full_lighting.png", Vector3(-6.0, 3.6, 6.7), Vector3(-2.6, 2.7, -2.9), 3.9, "unlabelled_granite_full_lighting")
	_apply_diagnostic("albedo_only")
	await _capture("diagnostic_granite_albedo_only.png", Vector3(-6.0, 3.6, 6.7), Vector3(-2.6, 2.7, -2.9), 3.9, "unlabelled_granite_albedo_only")
	_apply_diagnostic("normal_neutral_grey")
	await _capture("diagnostic_granite_normal_neutral_grey.png", Vector3(-6.0, 3.6, 6.7), Vector3(-2.6, 2.7, -2.9), 3.9, "unlabelled_granite_normal_neutral_grey")
	_apply_diagnostic("normal_disabled")
	await _capture("diagnostic_granite_normal_disabled.png", Vector3(-6.0, 3.6, 6.7), Vector3(-2.6, 2.7, -2.9), 3.9, "unlabelled_granite_normal_disabled")
	_apply_diagnostic("full_lighting")
	await _capture("unlabelled_close_facade.png", Vector3(-7.0, 4.5, 9.2), Vector3(-2.5, 2.6, -2.8), 5.3, "unlabelled_close_facade")
	await _capture("unlabelled_normal_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "unlabelled_normal_rts")
	await _capture("unlabelled_far_rts.png", Vector3(-22.0, 15.0, 24.0), Vector3(-0.5, 2.1, 0.0), 24.0, "unlabelled_far_rts")
	await _capture("unlabelled_greyscale.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "unlabelled_greyscale_source")
	var grey_path := screenshot_root.path_join("unlabelled_greyscale.png")
	var grey := Image.load_from_file(grey_path)
	if grey != null:
		grey.convert(Image.FORMAT_L8)
		grey.save_png(grey_path)
	var normal_path := screenshot_root.path_join("unlabelled_normal_rts.png")
	var thumb := Image.load_from_file(normal_path)
	if thumb != null:
		thumb.resize(256, 144, Image.INTERPOLATE_LANCZOS)
		thumb.save_png(screenshot_root.path_join("unlabelled_thumbnail.png"))


func _capture_views() -> void:
	await _capture_unlabelled()
	await _capture("ordinary_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "oblique_rts")
	await _capture("front_orthographic.png", Vector3(-2.6, 3.4, 12.0), Vector3(-2.6, 2.5, -1.5), 9.0, "front_orthographic")
	await _capture("rear_orthographic.png", Vector3(-2.6, 3.4, -14.0), Vector3(-2.6, 2.5, -1.5), 9.0, "rear_orthographic")
	await _capture("left_orthographic.png", Vector3(-14.0, 3.4, -1.5), Vector3(-2.6, 2.5, -1.5), 9.0, "left_orthographic")
	await _capture("right_orthographic.png", Vector3(9.0, 3.4, -1.5), Vector3(-2.6, 2.5, -1.5), 9.0, "right_orthographic")
	await _capture("top_orthographic.png", Vector3(-2.6, 20.0, -1.5), Vector3(-2.6, 0.0, -1.5), 11.0, "top_orthographic")
	await _capture("roof_front_three_quarter.png", Vector3(-10.5, 8.5, 10.5), Vector3(-2.6, 4.5, -1.5), 8.5, "roof_front_three_quarter")
	await _capture("roof_rear_three_quarter.png", Vector3(5.5, 8.2, -12.0), Vector3(-2.6, 4.5, -1.5), 8.5, "roof_rear_three_quarter")
	await _capture("roof_direct_top.png", Vector3(-2.6, 18.0, -1.5), Vector3(-2.6, 4.5, -1.5), 8.0, "roof_direct_top")
	await _capture("roof_left_verge.png", Vector3(-13.0, 5.5, 1.0), Vector3(-2.6, 5.0, -1.5), 6.5, "roof_left_verge")
	await _capture("roof_right_verge.png", Vector3(8.0, 5.5, 1.0), Vector3(-2.6, 5.0, -1.5), 6.5, "roof_right_verge")
	await _capture("roof_ridge_chimney.png", Vector3(-7.0, 10.0, 4.0), Vector3(-2.6, 5.6, -1.5), 6.0, "roof_ridge")
	await _capture("house02_stair_landing.png", Vector3(-7.2, 4.7, 9.0), Vector3(-0.2, 2.7, -3.0), 6.4, "stair_landing")
	await _capture("materials_and_openings.png", Vector3(-6.0, 3.8, 8.0), Vector3(-2.6, 2.6, -2.6), 5.9, "openings")
	await _capture("granite_closeup.png", Vector3(-6.0, 3.4, 6.5), Vector3(-3.0, 2.7, -2.9), 3.8, "granite_closeup")
	await _capture("roof_material_closeup.png", Vector3(-5.5, 6.8, 6.0), Vector3(-2.6, 5.2, -1.5), 4.2, "slate_closeup")
	await _capture("human_scale_and_units.png", Vector3(13.0, 7.2, -15.0), Vector3(0.2, 1.5, -1.0), 14.0, "human_scale")
	_apply_checker(true)
	await _capture("checker_front.png", Vector3(-8.0, 4.2, 10.0), Vector3(-2.6, 3.0, -1.5), 7.0, "checker_front")
	await _capture("checker_roof.png", Vector3(-7.0, 9.0, 8.0), Vector3(-2.6, 5.0, -1.5), 7.0, "checker_roof")
	await _capture("checker_rotation_a.png", Vector3(9.0, 6.0, -11.0), Vector3(-2.5, 2.8, -1.5), 8.5, "checker_rotation_a")
	house.rotation.y = 0.42
	await _capture("checker_rotation_b.png", Vector3(9.0, 6.0, -11.0), Vector3(-2.5, 2.8, -1.5), 8.5, "checker_rotation_b")
	house.rotation.y = 0.0
	_apply_checker(false)
	await _capture("lod0_overview.png", Vector3(-16.0, 12.0, 18.0), Vector3(0.5, 2.0, 0.0), 17.0, "lod0")
	_set_fragment_visible("LOD1", true)
	await _capture("lod1_overview.png", Vector3(-16.0, 12.0, 18.0), Vector3(0.5, 2.0, 0.0), 19.0, "lod1")
	_set_fragment_visible("LOD1", false)
	_set_fragment_visible("LOD2", true)
	await _capture("lod2_overview.png", Vector3(-16.0, 12.0, 18.0), Vector3(0.5, 2.0, 0.0), 22.0, "lod2")
	_set_fragment_visible("LOD2", false)
	_set_fragment_visible("LOD0", false)
	_set_fragment_visible("COLLISION", true)
	await _capture("collision_overview.png", Vector3(-16.0, 12.0, 18.0), Vector3(0.5, 2.0, 0.0), 17.0, "isolated_collision_front")
	_set_fragment_visible("COLLISION", false)
	_set_fragment_visible("LOD0", true)
	for child in get_children():
		if child != house and child != camera and child is Node3D:
			child.visible = false
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	await _capture("wireframe_lod0.png", Vector3(-10.0, 8.0, 12.0), Vector3(-2.6, 2.8, -1.5), 10.0, "isolated_wireframe_front")
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED


func _measure_benchmark() -> void:
	var start_usec := Time.get_ticks_usec()
	while float(Time.get_ticks_usec() - start_usec) / 1000000.0 < 5.0:
		await get_tree().process_frame
	var frame_times: Array[float] = []
	start_usec = Time.get_ticks_usec()
	var previous_usec := start_usec
	while frame_times.size() < 1500:
		await get_tree().process_frame
		var now_usec := Time.get_ticks_usec()
		frame_times.append(float(now_usec - previous_usec) / 1000000.0)
		previous_usec = now_usec
	var elapsed := float(Time.get_ticks_usec() - start_usec) / 1000000.0
	frame_times.sort()
	var median_dt := frame_times[frame_times.size() / 2]
	var p99_dt := frame_times[min(frame_times.size() - 1, int(ceil(float(frame_times.size()) * 0.99)))]
	var p999_dt := frame_times[min(frame_times.size() - 1, int(ceil(float(frame_times.size()) * 0.999)))]
	var max_dt := frame_times[frame_times.size() - 1]
	var spikes := 0
	for dt in frame_times:
		if dt > 0.050:
			spikes += 1
	var benchmark := {"warmupSeconds": 5.0, "measurementSeconds": elapsed, "sampleCount": frame_times.size(), "averageFps": float(frame_times.size()) / elapsed, "medianFps": 1.0 / median_dt, "onePercentLowFps": 1.0 / p99_dt, "zeroPointOnePercentLowFps": 1.0 / p999_dt, "minimumFps": 1.0 / max_dt, "medianFrameTimeMs": median_dt * 1000.0, "p99FrameTimeMs": p99_dt * 1000.0, "maximumFrameTimeMs": max_dt * 1000.0, "repeatedSpikeCountAbove50ms": spikes, "screenshotDumpingEnabled": false, "videoEncodingEnabled": false, "debugOverlaysEnabled": false, "cameraMode": "controlled oblique orthographic RTS", "visibleTriangles": _mesh_triangles(house), "frameTimesMs": frame_times.map(func(value): return value * 1000.0)}
	var file := FileAccess.open(capture_root.path_join(V0333_BENCHMARK), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(benchmark, "  "))


func _write_manifest_v331() -> void:
	var file := FileAccess.open(capture_root.path_join("v0333-house02-granite-roof-runtime.json"), FileAccess.WRITE)
	if file != null:
		var manifest := {"schemaVersion": 3, "checkpoint": "v0.333", "status": "PASS_V0333_HOUSE02_GRANITE_ROOF_EVIDENCE" if errors.is_empty() else "FAIL_V0333_HOUSE02_GRANITE_ROOF_EVIDENCE", "outcome": "REJECTED INTERNALLY — HOUSE STILL DOES NOT READ AS GRANITE OR FALSE ROOF FORMS REMAIN", "prototypeOptIn": true, "humanReviewRequired": true, "sourceBlend": "art-source/blender/v0333/barrosan_house_gold_02.blend", "sourceGLB": V0333_GLB, "scenePath": "res://scenes/review/V0333BarrosanHouse02GraniteRoof.tscn", "falseCrossGablesRemoved": true, "principalRoofSlopes": 2, "noGameplay": true, "noMovement": true, "noPathfinding": true, "noCombat": true, "noEconomy": true, "noResources": true, "house01Imported": false, "checkerUsesUV": true, "checkerScreenSpaceOverlay": false, "actualWireframe": true, "isolatedCollision": true, "completeDimensions": true, "diagnosticCaptures": true, "captures": captures, "errors": errors}
		file.store_string(JSON.stringify(manifest, "  "))
