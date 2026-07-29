extends "res://scripts/v0333_barrosan_house_02_granite_roof.gd"

const V0334_GLB := "res://assets/v0334/barrosan_house_gold_02.glb"
const V0334_METRICS := "res://assets/v0334/barrosan_house_gold_02.export.json"
const V0334_CHECKER := "res://assets/v0334/numbered_square_checker.png"
const V0334_ALBEDO := "res://assets/v0334/granite_albedo_2048.png"
const V0334_ROUGHNESS := "res://assets/v0334/granite_roughness_2048.png"
const V0334_NORMAL := "res://assets/v0334/granite_normal_2048.png"
const V0334_CANDIDATE_A := "res://assets/v0334/granite_candidate_a_1024.png"
const V0334_CANDIDATE_B := "res://assets/v0334/granite_candidate_b_1024.png"
const V0334_CANDIDATE_C := "res://assets/v0334/granite_candidate_c_1024.png"
const V0334_BENCHMARK := "v0334-benchmark.json"

var candidate_root: Node3D
var wireframe_root: Node3D


func _build_sector() -> void:
    # Isolated material study: no settlement/gameplay fixture is instantiated.
    pass


func _load_house() -> void:
    var packed := load(V0334_GLB) as PackedScene
    if packed == null:
        errors.append("Godot could not import v0.334 House 02 GLB")
        return
    house = packed.instantiate() as Node3D
    if house == null:
        errors.append("Godot could not instantiate v0.334 House 02 GLB")
        return
    house.name = "BarrosanHouse02V0334GraniteAuthenticity"
    house.position = Vector3(-2.6, 0.18, -1.5)
    add_child(house)
    _apply_house_material_language()
    _set_fragment_visible("LOD1", false)
    _set_fragment_visible("LOD2", false)
    _set_fragment_visible("COLLISION", false)
    _build_candidate_study()
    if _mesh_count(house) < 3:
        errors.append("House 02 v0.334 import did not expose grouped 3D geometry")


func _granite_material() -> ShaderMaterial:
    var shader := Shader.new()
    shader.code = "shader_type spatial; render_mode cull_disabled; uniform sampler2D albedo_tex; uniform sampler2D roughness_tex; uniform sampler2D normal_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; ROUGHNESS=texture(roughness_tex, UV).r; NORMAL_MAP=texture(normal_tex, UV).rgb; NORMAL_MAP_DEPTH=0.48; }"
    var material := ShaderMaterial.new()
    material.shader = shader
    material.set_shader_parameter("albedo_tex", load(V0334_ALBEDO))
    material.set_shader_parameter("roughness_tex", load(V0334_ROUGHNESS))
    material.set_shader_parameter("normal_tex", load(V0334_NORMAL))
    return material


func _apply_house_material_language() -> void:
    if house == null:
        return
    var granite := _granite_material()
    for node in house.find_children("*", "MeshInstance3D", true, false):
        var name_lower := String(node.name).to_lower()
        if name_lower.contains("granite") or name_lower.contains("foundation") or name_lower.contains("gable") or name_lower.contains("relief"):
            node.material_override = granite
        else:
            node.material_override = null


func _diagnostic_shader(mode: String) -> ShaderMaterial:
    var shader := Shader.new()
    var code := "shader_type spatial; render_mode cull_disabled; uniform sampler2D albedo_tex; uniform sampler2D roughness_tex; uniform sampler2D normal_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; ROUGHNESS=texture(roughness_tex, UV).r; NORMAL_MAP=texture(normal_tex, UV).rgb; NORMAL_MAP_DEPTH=0.48; }"
    if mode == "albedo_only":
        code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D albedo_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; }"
    elif mode == "normal_neutral_grey":
        code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D normal_tex; void fragment(){ ALBEDO=vec3(0.46); NORMAL_MAP=texture(normal_tex, UV).rgb; NORMAL_MAP_DEPTH=0.48; }"
    elif mode == "normal_disabled":
        code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D albedo_tex; void fragment(){ ALBEDO=texture(albedo_tex, UV).rgb; }"
    shader.code = code
    var material := ShaderMaterial.new()
    material.shader = shader
    material.set_shader_parameter("albedo_tex", load(V0334_ALBEDO))
    material.set_shader_parameter("roughness_tex", load(V0334_ROUGHNESS))
    material.set_shader_parameter("normal_tex", load(V0334_NORMAL))
    return material


func _shader_checker() -> ShaderMaterial:
    var shader := Shader.new()
    shader.code = "shader_type spatial; render_mode cull_disabled, unshaded; uniform sampler2D checker_tex; void fragment(){ ALBEDO=texture(checker_tex, fract(UV)).rgb; }"
    var material := ShaderMaterial.new()
    material.shader = shader
    material.set_shader_parameter("checker_tex", load(V0334_CHECKER))
    return material


func _build_candidate_study() -> void:
    candidate_root = Node3D.new()
    candidate_root.name = "V0334IsolatedGraniteCandidateStudy"
    add_child(candidate_root)
    var candidates := [V0334_CANDIDATE_A, V0334_CANDIDATE_B, V0334_CANDIDATE_C]
    for index in range(3):
        var x := -5.2 + float(index) * 5.2
        var material := _candidate_material(candidates[index])
        _study_box("Candidate_%s_Wall" % String.chr(65 + index), Vector3(x, 1.5, 0.0), Vector3(4.0, 3.0, 0.24), material)
        _study_box("Candidate_%s_Corner" % String.chr(65 + index), Vector3(x + 2.05, 1.5, -0.65), Vector3(0.24, 3.0, 1.55), material)
        _study_box("Candidate_%s_Foundation" % String.chr(65 + index), Vector3(x, 0.20, -0.16), Vector3(4.0, 0.38, 0.44), _solid_material(Color("#34372f")))
        _study_box("Candidate_%s_Window" % String.chr(65 + index), Vector3(x, 1.72, -0.19), Vector3(1.10, 1.35, 0.08), _solid_material(Color("#111817")))
        _study_box("Candidate_%s_Sill" % String.chr(65 + index), Vector3(x, 0.96, -0.30), Vector3(1.42, 0.18, 0.30), _solid_material(Color("#77786b")))
        _study_box("Candidate_%s_Lintel" % String.chr(65 + index), Vector3(x, 2.48, -0.30), Vector3(1.42, 0.22, 0.30), _solid_material(Color("#77786b")))
        _study_unit("Candidate_%s_Human" % String.chr(65 + index), Vector3(x - 1.45, 0.90, -0.42))


func _candidate_material(path: String) -> ShaderMaterial:
    var shader := Shader.new()
    shader.code = "shader_type spatial; render_mode cull_disabled; uniform sampler2D candidate_tex; void fragment(){ ALBEDO=texture(candidate_tex, UV).rgb; ROUGHNESS=0.90; }"
    var material := ShaderMaterial.new()
    material.shader = shader
    material.set_shader_parameter("candidate_tex", load(path))
    return material


func _solid_material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.90
    return material


func _study_box(name: String, position: Vector3, size: Vector3, material: Material) -> void:
    var instance := MeshInstance3D.new()
    instance.name = name
    var mesh := BoxMesh.new()
    mesh.size = size
    instance.mesh = mesh
    instance.material_override = material
    instance.position = position
    candidate_root.add_child(instance)


func _study_unit(name: String, position: Vector3) -> void:
    var body := MeshInstance3D.new()
    body.name = name
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.22
    mesh.height = 1.15
    body.mesh = mesh
    body.material_override = _solid_material(Color("#bda16c"))
    body.position = position + Vector3(0.0, 0.58, 0.0)
    candidate_root.add_child(body)
    var head := MeshInstance3D.new()
    head.name = name + "_Head"
    var sphere := SphereMesh.new()
    sphere.radius = 0.18
    sphere.height = 0.36
    head.mesh = sphere
    head.material_override = _solid_material(Color("#d4b27b"))
    head.position = position + Vector3(0.0, 1.30, 0.0)
    candidate_root.add_child(head)


func _capture_candidate_study() -> void:
    candidate_root.visible = true
    house.visible = false
    await _capture("candidate_study.png", Vector3(0.0, 5.4, 13.0), Vector3(0.0, 1.45, 0.0), 16.0, "three_candidate_study")
    await _capture("candidate_near.png", Vector3(0.0, 3.9, 9.0), Vector3(-1.7, 1.55, 0.0), 9.2, "candidate_near")
    await _capture("candidate_normal.png", Vector3(0.0, 5.4, 13.0), Vector3(0.0, 1.45, 0.0), 16.0, "candidate_normal")
    await _capture("candidate_far.png", Vector3(0.0, 8.0, 20.0), Vector3(0.0, 1.3, 0.0), 23.0, "candidate_far")
    candidate_root.visible = false
    house.visible = true


func _capture_views() -> void:
    await _capture_candidate_study()
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
    var grey := Image.load_from_file(screenshot_root.path_join("unlabelled_greyscale.png"))
    if grey != null:
        grey.convert(Image.FORMAT_L8)
        grey.save_png(screenshot_root.path_join("unlabelled_greyscale.png"))
    var thumbnail := Image.load_from_file(screenshot_root.path_join("unlabelled_normal_rts.png"))
    if thumbnail != null:
        thumbnail.resize(256, 144, Image.INTERPOLATE_LANCZOS)
        thumbnail.save_png(screenshot_root.path_join("unlabelled_thumbnail.png"))
    await _capture("ordinary_rts.png", Vector3(-16.0, 11.0, 18.0), Vector3(-0.5, 2.1, 0.0), 17.0, "oblique_rts")
    await _capture("front_orthographic.png", Vector3(-2.6, 3.4, 12.0), Vector3(-2.6, 2.5, -1.5), 9.0, "front_orthographic")
    await _capture("rear_orthographic.png", Vector3(-2.6, 3.4, -14.0), Vector3(-2.6, 2.5, -1.5), 9.0, "rear_orthographic")
    await _capture("left_orthographic.png", Vector3(-14.0, 3.4, -1.5), Vector3(-2.6, 2.5, -1.5), 9.0, "left_orthographic")
    await _capture("right_orthographic.png", Vector3(9.0, 3.4, -1.5), Vector3(-2.6, 2.5, -1.5), 9.0, "right_orthographic")
    await _capture("top_orthographic.png", Vector3(-2.6, 20.0, -1.5), Vector3(-2.6, 0.0, -1.5), 11.0, "top_orthographic")
    await _capture("roof_front_three_quarter.png", Vector3(-10.5, 8.5, 10.5), Vector3(-2.6, 4.5, -1.5), 8.5, "roof_front_three_quarter")
    await _capture("roof_rear_three_quarter.png", Vector3(5.5, 8.2, -12.0), Vector3(-2.6, 4.5, -1.5), 8.5, "roof_rear_three_quarter")
    await _capture("roof_direct_top.png", Vector3(-2.6, 18.0, -1.5), Vector3(-2.6, 4.5, -1.5), 8.0, "roof_direct_top")
    await _capture("roof_ridge_chimney.png", Vector3(-7.0, 10.0, 4.0), Vector3(-2.6, 5.6, -1.5), 6.0, "roof_ridge")
    await _capture("roof_left_verge.png", Vector3(-13.0, 5.5, 1.0), Vector3(-2.6, 5.0, -1.5), 6.5, "roof_left_verge")
    await _capture("roof_right_verge.png", Vector3(8.0, 5.5, 1.0), Vector3(-2.6, 5.0, -1.5), 6.5, "roof_right_verge")
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
    await _capture_collision()
    await _capture_wireframe()


func _capture_collision() -> void:
    house.visible = true
    _set_fragment_visible("LOD0", false)
    _set_fragment_visible("COLLISION", true)
    var index := 0
    for node in house.find_children("*", "MeshInstance3D", true, false):
        if String(node.name).to_lower().contains("collision"):
            var material := _solid_material([Color("#e35b4f"), Color("#54c7a2"), Color("#d6c35e")][min(index, 2)])
            node.material_override = material
            index += 1
    await _capture("collision_overview.png", Vector3(-16.0, 12.0, 18.0), Vector3(0.5, 2.0, 0.0), 17.0, "isolated_collision_front")
    _set_fragment_visible("COLLISION", false)
    _set_fragment_visible("LOD0", true)
    _apply_house_material_language()


func _capture_wireframe() -> void:
    wireframe_root = Node3D.new()
    wireframe_root.name = "V0334ActualTriangleWireframe"
    add_child(wireframe_root)
    house.visible = false
    var wire_material := _solid_material(Color("#f0c76a"))
    for source_node in house.find_children("*", "MeshInstance3D", true, false):
        if source_node.mesh == null:
            continue
        var immediate := ImmediateMesh.new()
        for surface in range(source_node.mesh.get_surface_count()):
            var arrays: Array = source_node.mesh.surface_get_arrays(surface)
            var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
            if indices.is_empty():
                for i in range(0, vertices.size(), 3):
                    if i + 2 < vertices.size():
                        _wire_triangle(immediate, vertices[i], vertices[i + 1], vertices[i + 2], wire_material)
            else:
                for i in range(0, indices.size(), 3):
                    if i + 2 < indices.size():
                        _wire_triangle(immediate, vertices[indices[i]], vertices[indices[i + 1]], vertices[indices[i + 2]], wire_material)
        var overlay := MeshInstance3D.new()
        overlay.name = source_node.name + "_TriangleEdges"
        overlay.mesh = immediate
        overlay.position = source_node.position
        overlay.rotation = source_node.rotation
        overlay.scale = source_node.scale
        wireframe_root.add_child(overlay)
    await _capture("wireframe_lod0.png", Vector3(-10.0, 8.0, 12.0), Vector3(-2.6, 2.8, -1.5), 10.0, "isolated_wireframe_front")
    wireframe_root.queue_free()
    wireframe_root = null
    house.visible = true


func _wire_triangle(mesh: ImmediateMesh, a: Vector3, b: Vector3, c: Vector3, material: Material) -> void:
    mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
    mesh.surface_add_vertex(a); mesh.surface_add_vertex(b)
    mesh.surface_add_vertex(b); mesh.surface_add_vertex(c)
    mesh.surface_add_vertex(c); mesh.surface_add_vertex(a)
    mesh.surface_end()


func _measure_benchmark() -> void:
    var start_usec := Time.get_ticks_usec()
    while float(Time.get_ticks_usec() - start_usec) / 1000000.0 < 5.0:
        await get_tree().process_frame
    var raw: Array[float] = []
    start_usec = Time.get_ticks_usec()
    var previous_usec := start_usec
    while raw.size() < 1500 or float(Time.get_ticks_usec() - start_usec) / 1000000.0 < 20.0:
        await get_tree().process_frame
        var now_usec := Time.get_ticks_usec()
        raw.append(float(now_usec - previous_usec) / 1000000.0)
        previous_usec = now_usec
    var stored: Array[float] = []
    for index in range(1500):
        stored.append(raw[int(float(index) * float(raw.size() - 1) / 1499.0)])
    var elapsed := float(Time.get_ticks_usec() - start_usec) / 1000000.0
    var sorted := stored.duplicate()
    sorted.sort()
    var median_dt: float = sorted[750]
    var p99_dt: float = sorted[1490]
    var max_dt: float = sorted[1499]
    var spikes := 0
    for dt in stored:
        if dt > 0.050:
            spikes += 1
    var benchmark := {"warmupSeconds": 5.0, "measurementSeconds": elapsed, "rawSampleCount": raw.size(), "sampleCount": 1500, "storedSampleCount": stored.size(), "averageFps": float(raw.size()) / elapsed, "medianFrameTimeMs": median_dt * 1000.0, "p99FrameTimeMs": p99_dt * 1000.0, "maximumFrameTimeMs": max_dt * 1000.0, "repeatedSpikeCountAbove50ms": spikes, "screenshotDumpingEnabled": false, "videoEncodingEnabled": false, "debugOverlaysEnabled": false, "cameraMode": "controlled oblique orthographic RTS", "visibleTriangles": _mesh_triangles(house), "frameTimesMs": stored.map(func(value): return value * 1000.0)}
    var file := FileAccess.open(capture_root.path_join(V0334_BENCHMARK), FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(benchmark, "  "))


func _write_manifest_v331() -> void:
    var file := FileAccess.open(capture_root.path_join("v0334-house02-granite-authenticity-runtime.json"), FileAccess.WRITE)
    if file != null:
        var manifest := {"schemaVersion": 4, "checkpoint": "v0.334", "status": "PASS_V0334_HOUSE02_GRANITE_EVIDENCE" if errors.is_empty() else "FAIL_V0334_HOUSE02_GRANITE_EVIDENCE", "outcome": "REJECTED INTERNALLY — GRANITE STILL READS AS PATTERNED CLADDING, MARBLE TILES OR SYNTHETIC BLOCKS", "roofOutcome": "ROOF FORM PRESERVED — PASS", "prototypeOptIn": true, "humanReviewRequired": true, "sourceBlend": "art-source/blender/v0334/barrosan_house_gold_02.blend", "sourceGLB": V0334_GLB, "scenePath": "res://scenes/review/V0334BarrosanHouse02GraniteAuthenticity.tscn", "commonHeightMap": "art-source/materials/v0334/granite_height_2048.png", "candidateSystems": ["A", "B", "C"], "falseCrossGablesRemoved": true, "principalRoofSlopes": 2, "noGameplay": true, "noMovement": true, "noPathfinding": true, "noCombat": true, "noEconomy": true, "noResources": true, "house01Imported": false, "checkerUsesUV": true, "checkerScreenSpaceOverlay": false, "actualWireframe": true, "isolatedCollision": true, "completeDimensions": true, "benchmarkTwentySeconds": true, "captures": captures, "errors": errors}
        file.store_string(JSON.stringify(manifest, "  "))
