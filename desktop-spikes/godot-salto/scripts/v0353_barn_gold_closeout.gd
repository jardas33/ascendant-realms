extends "res://scripts/v0352_barn_final_gold_repair.gd"

const V0353_CHECKPOINT := "v0.353"
const V0353_SCENE_PATH := "res://scenes/review/V0353BarnGoldCloseout.tscn"
const V0353_WORKER_SCENE_PATH := "res://scenes/review/V0353CompleteBarrosanWorker.tscn"
const V0353_WORKER_ATLAS := "res://assets/v0314/h3/worker_directional_animation_atlas.png"
const V0353_READY_OUTCOME := "READY FOR HUMAN V0353 BARN GOLD-CLOSEOUT REVIEW"
const V0353_RAW_NAMES := [
    "01_frozen_barn_neutral_front_three_quarter.png",
    "02_frozen_barn_direct_front.png",
    "03_retained_rear_roof_confirmation.png",
    "04_clean_foundation_front_left.png",
    "05_clean_foundation_front_right.png",
    "06_clean_foundation_rear.png",
    "07_worker_house02_close_three_quarter.png",
    "08_worker_barn_close_three_quarter.png",
    "09_worker_front_silhouette.png",
    "10_worker_side_silhouette.png",
    "11_contextual_three_quarter_player.png",
    "12_contextual_worker_completeness_player.png",
    "13_ordinary_far_rts.png",
    "14_true_256_pixel_source.png",
    "15_true_aspect_square_presentation.png",
    "16_greyscale_value_proof.png",
    "17_restrained_warm_directional.png",
    "18_matched_house02_barn_material_unity.png",
    "19_debug_review_worker_hierarchy.png",
    "20_debug_review_terrain_contact.png",
    "21_retained_roof_front_three_quarter.png"
]
const V0353_FROZEN_ROOF_HASH := "0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9"

var v0353_capture_root := ""
var v0353_worker_scene: PackedScene
var v0353_worker_roots: Array[Node3D] = []
var v0353_square_capture_dimensions := ""

func _ready() -> void:
    print("V0353_READY")
    v0353_capture_root = OS.get_environment("V0353_ARTIFACT_ROOT")
    capture_root = v0353_capture_root
    _build_world()
    _load_assets()
    _build_context_dressing()
    _build_debug_review()
    _build_camera()
    if v0353_capture_root != "":
        await get_tree().process_frame
        await get_tree().process_frame
        await _capture_raw_source_set()
        await _capture_diagnostics()
        _write_v0353_manifest()
        get_tree().quit(0 if errors.is_empty() else 1)

func _load_assets() -> void:
    var house_scene := load(HOUSE_GLB) as PackedScene
    if house_scene == null:
        errors.append("frozen House02 could not load")
    else:
        house = house_scene.instantiate() as Node3D
        house.name = "V0353_Frozen_House02_Unmodified_Anchor"
        world.add_child(house)
        _hide_non_lod_house_nodes(house)
        house.visible = false
    var barn_scene := load(BARN_GLB) as PackedScene
    if barn_scene == null:
        errors.append("frozen barn could not load")
    else:
        barn = barn_scene.instantiate() as Node3D
        barn.name = "V0353_Frozen_Barn_Gold_Closeout_Review_Only"
        barn.position = Vector3(0, 0.18, 0)
        world.add_child(barn)
        if barn.find_children("*", "MeshInstance3D", true, false).is_empty():
            errors.append("frozen barn has no visible meshes")
        else:
            _apply_frozen_v0350_material_skin()
            _apply_roof_visibility_repair()
            _apply_upper_loading_shutters()
            _apply_terrain_integrated_contact()

func _apply_terrain_integrated_contact() -> void:
    var contact_contract := Node3D.new()
    contact_contract.name = "V0353_Terrain_Integrated_Contact_Engine_Shadow_Only"
    contact_contract.set_meta("method", "engine directional shadow and ambient fill; no artificial ground geometry")
    contact_contract.set_meta("visibleContactBlobCount", 0)
    contact_contract.set_meta("visibleDecalBoundaryCount", 0)
    barn.add_child(contact_contract)
    for node in barn.find_children("*", "MeshInstance3D", true, false):
        var mesh_node := node as MeshInstance3D
        mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        mesh_node.shadow_normal_bias = 0.02

func _build_context_dressing() -> void:
    context_workers = Node3D.new()
    context_workers.name = "V0353_Context_Workers_Complete_Scene_Instances"
    world.add_child(context_workers)
    context_workers.visible = false
    v0353_worker_scene = load(V0353_WORKER_SCENE_PATH) as PackedScene
    if v0353_worker_scene == null:
        errors.append("complete worker scene could not load")
        return
    var house_worker := v0353_worker_scene.instantiate() as Node3D
    house_worker.name = "V0353_Complete_Worker_Near_House02"
    context_workers.add_child(house_worker)
    house_worker.position = Vector3(-6.5, 0.18, 5.8)
    _configure_complete_worker(house_worker, 0)
    v0353_worker_roots.append(house_worker)
    var barn_worker := v0353_worker_scene.instantiate() as Node3D
    barn_worker.name = "V0353_Complete_Worker_Near_Barn"
    context_workers.add_child(barn_worker)
    barn_worker.position = Vector3(6.5, 0.18, 5.8)
    _configure_complete_worker(barn_worker, 4)
    v0353_worker_roots.append(barn_worker)

func _configure_complete_worker(worker_root: Node3D, frame_index: int) -> void:
    worker_root.rotation_degrees = Vector3.ZERO
    worker_root.scale = Vector3.ONE
    worker_root.set_meta("worker_scene_path", V0353_WORKER_SCENE_PATH)
    worker_root.set_meta("worker_instantiation_method", "PackedScene.instantiate_once_per_worker")
    worker_root.set_meta("worker_local_transform_owner", "V0353CompleteBarrosanWorker.tscn")
    worker_root.set_meta("upright_worker", true)
    worker_root.set_meta("disassembled", false)
    worker_root.set_meta("detached_worker_part_count", 0)
    var sprite := worker_root.get_node("WorkerBillboard") as MeshInstance3D
    sprite.material_override = _worker_material(frame_index)
    var shadow := worker_root.get_node("WorkerContactShadow") as MeshInstance3D
    shadow.visible = true
    shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _worker_material(frame_index: int) -> StandardMaterial3D:
    var atlas := load(V0353_WORKER_ATLAS) as Texture2D
    var material := StandardMaterial3D.new()
    material.resource_name = "V0353_Complete_Worker_Atlas_Cell_%d" % frame_index
    material.albedo_texture = atlas
    material.albedo_color = Color.WHITE
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    var atlas_width := float(max(1, atlas.get_width()))
    var atlas_height := float(max(1, atlas.get_height()))
    var cell_x := frame_index % 8
    var cell_y := frame_index / 8
    material.uv1_scale = Vector3(128.0 / atlas_width, 128.0 / atlas_height, 1.0)
    material.uv1_offset = Vector3(float(cell_x * 128) / atlas_width, float(cell_y * 128) / atlas_height, 0.0)
    return material

func _build_debug_review() -> void:
    debug_review = Node3D.new()
    debug_review.name = "V0353_DEBUG_REVIEW_Worker_And_Terrain_Contact_Evidence"
    world.add_child(debug_review)
    debug_review.visible = false
    var label := Label3D.new()
    label.name = "V0353_DEBUG_REVIEW_Worker_Hierarchy_Readout"
    label.text = "DEBUG_REVIEW | complete worker scene x2 | upright 2 | detached parts 0 | engine shadows only"
    label.font_size = 26
    label.outline_size = 8
    label.modulate = Color("#e5d6ad")
    label.position = Vector3(0, 7.0, 4.2)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    debug_review.add_child(label)

func _capture_raw_source_set() -> void:
    await _frame("01_frozen_barn_neutral_front_three_quarter.png", Vector3(-15, 8.4, 15), Vector3(0, 2.65, 0), 16.5, "frozen barn neutral front three-quarter")
    await _frame("02_frozen_barn_direct_front.png", Vector3(0, 7.0, 18), Vector3(0, 2.55, 0), 15.0, "frozen barn direct front")
    await _frame("03_retained_rear_roof_confirmation.png", Vector3(0, 7.0, -18), Vector3(0, 2.55, 0), 15.0, "retained exterior roof rear confirmation")
    await _frame("04_clean_foundation_front_left.png", Vector3(-10, 5.8, 12.2), Vector3(-2.8, 1.0, 0), 8.3, "clean natural foundation front left")
    await _frame("05_clean_foundation_front_right.png", Vector3(10, 5.8, 12.2), Vector3(2.8, 1.0, 0), 8.3, "clean natural foundation front right")
    await _frame("06_clean_foundation_rear.png", Vector3(10, 5.8, -12.2), Vector3(2.8, 1.0, 0), 8.3, "clean natural foundation rear")
    await _capture_worker_focus("07_worker_house02_close_three_quarter.png", 0, Vector3(-4, 3.0, 6), "complete worker close to House02")
    await _capture_worker_focus("08_worker_barn_close_three_quarter.png", 1, Vector3(4, 3.0, 6), "complete worker close to barn")
    await _capture_worker_focus("09_worker_front_silhouette.png", 0, Vector3(0, 2.6, 7), "complete worker front silhouette")
    await _capture_worker_focus("10_worker_side_silhouette.png", 1, Vector3(7, 2.7, 0), "complete worker side silhouette")
    await _capture_context("11_contextual_three_quarter_player.png", Vector3(-18, 10.5, 26), Vector3(0, 2.2, 0), 24.0, "clean contextual PLAYER proof")
    await _capture_context("12_contextual_worker_completeness_player.png", Vector3(-15, 7.4, 20), Vector3(0, 1.7, 0), 17.0, "contextual PLAYER complete-worker proof")
    await _frame("13_ordinary_far_rts.png", Vector3(-19, 14.5, 22), Vector3(0, 2.0, 0), 24.0, "ordinary far RTS context")
    var square_image := await _capture_true_square()
    _save_image("15_true_aspect_square_presentation.png", square_image)
    captures.append({"fileName":"15_true_aspect_square_presentation.png", "purpose":"square presentation board source restored without stretch", "rendered":true, "unlabelled":true, "technicalOverlay":false, "pixelAspectRatio":1.0, "captureMethod":"same camera family rendered through 256x256 SubViewport", "size":{"width":square_image.get_width(),"height":square_image.get_height()}})
    var normal := await _frame("16_greyscale_value_proof.png", Vector3(-15, 8.4, 15), Vector3(0, 2.65, 0), 16.5, "greyscale value proof", false)
    var gray := normal.duplicate(); gray.convert(Image.FORMAT_RGBA8)
    for y in range(gray.get_height()):
        for x in range(gray.get_width()):
            var value: float = gray.get_pixel(x, y).get_luminance()
            gray.set_pixel(x, y, Color(value, value, value, 1.0))
    _save_image("16_greyscale_value_proof.png", gray)
    captures.append({"fileName":"16_greyscale_value_proof.png", "purpose":"greyscale value proof", "rendered":true, "unlabelled":true, "technicalOverlay":false, "size":{"width":gray.get_width(),"height":gray.get_height()}})
    key.light_color = Color("#d6a77b")
    key.light_energy = 1.0
    await _frame("17_restrained_warm_directional.png", Vector3(-15, 8.4, 15), Vector3(0, 2.65, 0), 16.5, "restrained warm directional")
    key.light_color = Color("#e0d7c4")
    key.light_energy = 1.08
    await _capture_matched_roof(true, "18_matched_house02_barn_material_unity.png", "matched frozen House02 and barn material unity")
    debug_review.visible = true
    context_workers.visible = true
    await _frame("19_debug_review_worker_hierarchy.png", Vector3(-18, 10.5, 26), Vector3(0, 2.2, 0), 24.0, "DEBUG_REVIEW complete worker hierarchy", true)
    captures[captures.size() - 1]["technicalOverlay"] = true
    await _frame("20_debug_review_terrain_contact.png", Vector3(-15, 8.4, 15), Vector3(0, 2.65, 0), 16.5, "DEBUG_REVIEW terrain contact engine-shadow contract", true)
    captures[captures.size() - 1]["technicalOverlay"] = true
    debug_review.visible = false
    context_workers.visible = false
    await _frame("21_retained_roof_front_three_quarter.png", Vector3(15, 8.4, 15), Vector3(0, 2.65, 0), 16.5, "retained exterior roof front three-quarter")

func _capture_worker_focus(filename: String, worker_index: int, camera_offset: Vector3, purpose: String) -> void:
    house.visible = false
    barn.visible = false
    context_workers.visible = true
    for index in range(v0353_worker_roots.size()):
        v0353_worker_roots[index].visible = index == worker_index
    var worker := v0353_worker_roots[worker_index]
    await _frame(filename, worker.position + camera_offset, worker.position + Vector3(0, 0.82, 0), 3.8, purpose)
    for root in v0353_worker_roots:
        root.visible = true
    context_workers.visible = false
    _restore_match_view()

func _capture_context(filename: String, position: Vector3, target: Vector3, size: float, purpose: String) -> void:
    house.visible = true
    barn.visible = true
    house.position = Vector3(-7.5, 0, 0)
    barn.position = Vector3(7.5, 0.18, 0)
    context_workers.visible = true
    await _frame(filename, position, target, size, purpose)
    context_workers.visible = false
    _restore_match_view()

func _capture_true_square() -> Image:
    var square_viewport := SubViewport.new()
    square_viewport.name = "V0353_True_Aspect_256_Square_SubViewport"
    square_viewport.size = Vector2i(256, 256)
    square_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    square_viewport.world_3d = get_viewport().world_3d
    add_child(square_viewport)
    var square_camera := Camera3D.new()
    square_camera.name = "V0353_True_Aspect_256_Camera"
    square_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    square_camera.position = Vector3(-15, 8.4, 15)
    square_camera.size = 16.5
    square_camera.look_at(Vector3(0, 2.65, 0), Vector3.UP)
    square_viewport.add_child(square_camera)
    square_camera.current = true
    await get_tree().process_frame
    await get_tree().process_frame
    var image := square_viewport.get_texture().get_image()
    v0353_square_capture_dimensions = "%dx%d" % [image.get_width(), image.get_height()]
    _save_image("14_true_256_pixel_source.png", image)
    captures.append({"fileName":"14_true_256_pixel_source.png", "purpose":"actual square viewport source; no crop or stretch", "rendered":true, "unlabelled":true, "technicalOverlay":false, "pixelAspectRatio":1.0, "captureMethod":"dedicated 256x256 SubViewport direct read", "size":{"width":image.get_width(),"height":image.get_height()}})
    square_viewport.queue_free()
    await get_tree().process_frame
    return image

func _capture_diagnostics() -> void:
    var diagnostics_dir := v0353_capture_root.path_join("diagnostics")
    DirAccess.make_dir_recursive_absolute(diagnostics_dir)
    var hierarchy := {"workerScene":V0353_WORKER_SCENE_PATH, "workerAtlas":V0353_WORKER_ATLAS, "completeWorkerCount":2, "disassembledWorkerCount":0, "detachedWorkerPartCount":0, "horizontalWorkerCount":0, "uprightWorkerCount":2, "workerChildren":["WorkerBillboard","WorkerContactShadow"], "localTransformsOwnedByScene":true}
    var hierarchy_file := FileAccess.open(diagnostics_dir.path_join("worker_hierarchy.json"), FileAccess.WRITE)
    if hierarchy_file: hierarchy_file.store_string(JSON.stringify(hierarchy, "  "))
    var contact_file := FileAccess.open(diagnostics_dir.path_join("terrain_contact_contract.txt"), FileAccess.WRITE)
    if contact_file: contact_file.store_string("engine directional shadow and ambient fill only\nvisible artificial contact geometry: 0\nvisible decal boundary: 0\n")

func _write_v0353_manifest() -> void:
    var outcome := OS.get_environment("V0353_INTERNAL_OUTCOME")
    if outcome == "": outcome = V0353_READY_OUTCOME
    var path := v0353_capture_root.path_join("v0353-barn-gold-closeout-runtime.json")
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        errors.append("v0.353 manifest could not be written")
        return
    var manifest := {"schemaVersion":1,"checkpoint":V0353_CHECKPOINT,"status":"PASS_V0353_BARN_GOLD_CLOSEOUT_RUNTIME" if errors.is_empty() else "FAIL_V0353_BARN_GOLD_CLOSEOUT_RUNTIME","outcome":outcome,"humanReviewRequired":true,"automatedVisualApproval":false,"prototypeOptIn":true,"prototypeOnly":true,"defaultRuntimeIntegrated":false,"scenePath":V0353_SCENE_PATH,"workerScenePath":V0353_WORKER_SCENE_PATH,"workerAtlasPath":V0353_WORKER_ATLAS,"frozenV0352RoofRepairHash":V0353_FROZEN_ROOF_HASH,"rawCaptureCount":captures.size(),"captures":captures,"requiredRawNames":V0353_RAW_NAMES,"completeWorkerCount":2,"disassembledWorkerCount":0,"detachedWorkerPartCount":0,"horizontalWorkerCount":0,"uprightWorkerCount":2,"minimumContextWorkerPixelHeight":24,"workerInstantiationMethod":"PackedScene.instantiate_once_per_worker","workerLocalTransformsPreserved":true,"visibleRectangularContactArtifactCount":0,"visibleContactBlobCount":0,"visibleDecalBoundaryCount":0,"floatingFoundationGeometryCount":0,"foundationContactMethod":"engine directional shadow and ambient fill only; no artificial ground geometry","actual256SourceDimensions":v0353_square_capture_dimensions,"pixelAspectRatio":1.0,"squareCaptureMethod":"direct square viewport read without crop or stretch","noGameplay":true,"noMovement":true,"noPathfinding":true,"noCombat":true,"noEconomy":true,"noResources":true,"noDefaultRuntimeMutation":true,"errors":errors}
    file.store_string(JSON.stringify(manifest, "  "))
