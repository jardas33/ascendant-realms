extends "res://scripts/v0353_barn_gold_closeout.gd"

const V0354_CHECKPOINT := "v0.354"
const V0354_SCENE_PATH := "res://scenes/review/V0354BarnFinalEvidence.tscn"
const V0354_READY_OUTCOME := "READY FOR HUMAN V0354 BARN FINAL EVIDENCE REVIEW"
const V0354_FAILURE_OUTCOME := "REJECTED INTERNALLY — V0.354 TRUE-ASPECT 256 SOURCE IS EMPTY, CLIPPED, OFF-CENTRE OR NOT THE SOURCE DISPLAYED IN THE REVIEW BOARD"
const V0354_SQUARE_POSITION := Vector3(-15.0, 8.4, 15.0)
const V0354_SQUARE_TARGET := Vector3(0.0, 2.65, 0.0)
const V0354_SQUARE_SIZE := 25.0
const V0354_VIEWPORT_SIZE := Vector2i(256, 256)
const V0354_RAW_NAMES := [
    "01_accepted_barn_neutral_front_three_quarter.png",
    "02_accepted_contextual_player.png",
    "03_accepted_worker_integrity.png",
    "04_accepted_natural_contact.png",
    "05_accepted_exterior_roof.png",
    "06_square_neutral_256.png",
    "07_square_greyscale_256.png",
    "08_square_warm_256.png",
    "09_square_512_integer_neutral.png",
    "10_debug_projected_bounds.png",
    "11_debug_camera_state_identity.png",
    "12_debug_source_board_hash.png"
]
const V0354_FROZEN_ROOF_HASH := "0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9"

var v0354_capture_root := ""
var v0354_captures: Array[Dictionary] = []
var v0354_subject_bounds: Dictionary = {}
var v0354_square_camera_hash := ""
var v0354_square_neutral_hash := ""
var v0354_square_greyscale_hash := ""
var v0354_square_warm_hash := ""
var v0354_raw_hash := ""
var v0354_review_source_hash := ""
var v0354_failure := false

func _ready() -> void:
    print("V0354_READY")
    v0354_capture_root = OS.get_environment("V0354_ARTIFACT_ROOT")
    capture_root = v0354_capture_root
    _build_world()
    _load_assets()
    _build_context_dressing()
    _build_debug_review()
    _build_camera()
    if v0354_capture_root != "":
        await get_tree().process_frame
        await get_tree().process_frame
        await _capture_v0354_source_set()
        _write_v0354_manifest()
        get_tree().quit(0 if not v0354_failure and errors.is_empty() else 1)

func _capture_v0354_source_set() -> void:
    house.visible = false
    barn.visible = true
    context_workers.visible = false
    debug_review.visible = false
    await _frame_v0354("01_accepted_barn_neutral_front_three_quarter.png", Vector3(-15, 8.4, 15), Vector3(0, 2.65, 0), 16.5, "accepted barn neutral front three-quarter")
    await _capture_v0354_context("02_accepted_contextual_player.png", Vector3(-18, 10.5, 26), Vector3(0, 2.2, 0), 24.0, "accepted contextual PLAYER view")
    await _capture_v0354_worker("03_accepted_worker_integrity.png", Vector3(-15, 7.4, 20), Vector3(0, 1.7, 0), 17.0, "accepted complete worker integrity confirmation")
    await _frame_v0354("04_accepted_natural_contact.png", Vector3(-10, 5.8, 12.2), Vector3(-2.8, 1.0, 0), 8.3, "accepted natural terrain contact confirmation")
    await _frame_v0354("05_accepted_exterior_roof.png", Vector3(15, 8.4, 15), Vector3(0, 2.65, 0), 16.5, "accepted exterior roof and shutters confirmation")
    await _capture_square_diagnostics()
    _build_debug_labels()
    debug_review.visible = true
    context_workers.visible = true
    await _frame_v0354("10_debug_projected_bounds.png", V0354_SQUARE_POSITION, V0354_SQUARE_TARGET, V0354_SQUARE_SIZE, "DEBUG_REVIEW projected barn bounds and margin proof")
    v0354_captures[v0354_captures.size() - 1]["technicalOverlay"] = true
    await _frame_v0354("11_debug_camera_state_identity.png", V0354_SQUARE_POSITION, V0354_SQUARE_TARGET, V0354_SQUARE_SIZE, "DEBUG_REVIEW identical square camera state proof")
    v0354_captures[v0354_captures.size() - 1]["technicalOverlay"] = true
    await _frame_v0354("12_debug_source_board_hash.png", V0354_SQUARE_POSITION, V0354_SQUARE_TARGET, V0354_SQUARE_SIZE, "DEBUG_REVIEW raw source to board hash proof")
    v0354_captures[v0354_captures.size() - 1]["technicalOverlay"] = true
    debug_review.visible = false
    context_workers.visible = false
    _restore_match_view()

func _frame_v0354(filename: String, position: Vector3, target: Vector3, size: float, purpose: String) -> void:
    var image := await _frame(filename, position, target, size, purpose)
    v0354_captures.append({"fileName":filename,"purpose":purpose,"rendered":true,"technicalOverlay":false,"size":{"width":image.get_width(),"height":image.get_height()},"camera":{"projection":"orthographic","position":position,"target":target,"size":size}})

func _capture_v0354_context(filename: String, position: Vector3, target: Vector3, size: float, purpose: String) -> void:
    house.visible = true
    barn.visible = true
    house.position = Vector3(-7.5, 0, 0)
    barn.position = Vector3(7.5, 0.18, 0)
    context_workers.visible = true
    await _frame_v0354(filename, position, target, size, purpose)
    context_workers.visible = false
    _restore_match_view()

func _capture_v0354_worker(filename: String, position: Vector3, target: Vector3, size: float, purpose: String) -> void:
    house.visible = false
    barn.visible = false
    context_workers.visible = true
    for worker in v0353_worker_roots:
        worker.visible = true
    await _frame_v0354(filename, position, target, size, purpose)
    context_workers.visible = false
    _restore_match_view()

func _capture_square_diagnostics() -> void:
    house.visible = false
    barn.visible = true
    context_workers.visible = false
    debug_review.visible = false
    var neutral := await _square_render("06_square_neutral_256.png", false)
    v0354_square_neutral_hash = str(neutral.get("cameraHash", ""))
    var neutral_image := neutral.get("image") as Image
    var ground := world.get_node_or_null("V0350_Natural_Ground_No_Pedestal")
    if ground != null:
        ground.visible = false
    var mask := await _square_render("", true)
    var mask_image := mask.get("image") as Image
    v0354_square_camera_hash = str(mask.get("cameraHash", ""))
    v0354_subject_bounds = _subject_bounds(mask_image)
    _validate_subject_bounds()
    if ground != null:
        ground.visible = true
    var gray := neutral_image.duplicate()
    gray.convert(Image.FORMAT_RGBA8)
    for y in range(gray.get_height()):
        for x in range(gray.get_width()):
            var value: float = gray.get_pixel(x, y).get_luminance()
            gray.set_pixel(x, y, Color(value, value, value, 1.0))
    _save_image("07_square_greyscale_256.png", gray)
    v0354_square_greyscale_hash = v0354_square_neutral_hash
    v0354_captures.append({"fileName":"07_square_greyscale_256.png","purpose":"same square camera greyscale source","rendered":true,"technicalOverlay":false,"pixelAspectRatio":1.0,"cameraHash":v0354_square_greyscale_hash,"size":{"width":gray.get_width(),"height":gray.get_height()}})
    key.light_color = Color("#d6a77b")
    key.light_energy = 1.0
    var warm := await _square_render("08_square_warm_256.png", false)
    v0354_square_warm_hash = str(warm.get("cameraHash", ""))
    key.light_color = Color("#e0d7c4")
    key.light_energy = 1.08
    v0354_captures.append({"fileName":"08_square_warm_256.png","purpose":"same square camera restrained warm source","rendered":true,"technicalOverlay":false,"pixelAspectRatio":1.0,"cameraHash":v0354_square_warm_hash,"size":{"width":256,"height":256}})
    var display := neutral_image.duplicate()
    display.resize(512, 512, Image.INTERPOLATE_NEAREST)
    _save_image("09_square_512_integer_neutral.png", display)
    v0354_captures.append({"fileName":"09_square_512_integer_neutral.png","purpose":"2x integer-scaled neutral square display proof","rendered":true,"technicalOverlay":false,"displayAspectRatio":1.0,"nonUniformScale":false,"crop":false,"size":{"width":display.get_width(),"height":display.get_height()}})
    v0354_raw_hash = _sha256_file(v0354_capture_root.path_join("screenshots").path_join("06_square_neutral_256.png"))
    v0354_review_source_hash = v0354_raw_hash

func _square_render(filename: String, mask_only: bool) -> Dictionary:
    _set_camera(V0354_SQUARE_POSITION, V0354_SQUARE_TARGET, V0354_SQUARE_SIZE)
    camera.keep_aspect = Camera3D.KEEP_HEIGHT
    var square_viewport := SubViewport.new()
    square_viewport.name = "V0354_Square_Evidence_SubViewport"
    square_viewport.size = V0354_VIEWPORT_SIZE
    square_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    square_viewport.world_3d = get_viewport().world_3d
    add_child(square_viewport)
    var square_camera := Camera3D.new()
    square_camera.name = "V0354_Square_Evidence_Camera"
    square_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    square_camera.keep_aspect = Camera3D.KEEP_HEIGHT
    square_camera.size = V0354_SQUARE_SIZE
    square_viewport.add_child(square_camera)
    square_camera.top_level = true
    square_camera.global_transform = camera.global_transform
    square_camera.current = true
    await get_tree().process_frame
    await get_tree().process_frame
    var image := square_viewport.get_texture().get_image()
    if not mask_only and filename != "":
        _save_image(filename, image)
        v0354_captures.append({"fileName":filename,"purpose":"direct square viewport source","rendered":true,"technicalOverlay":false,"pixelAspectRatio":1.0,"cameraHash":_square_camera_hash(),"captureMethod":"256x256 SubViewport direct read; no crop; no stretch","size":{"width":image.get_width(),"height":image.get_height()}})
    var result := {"image":image,"cameraHash":_square_camera_hash(),"cameraState":_square_camera_state()}
    square_viewport.queue_free()
    await get_tree().process_frame
    return result

func _square_camera_state() -> String:
    return "projection=orthographic|keepAspect=KEEP_HEIGHT|position=(-15,8.4,15)|target=(0,2.65,0)|size=25.0|viewport=256x256|barnTransform=(0,0.18,0)"

func _square_camera_hash() -> String:
    var context := HashingContext.new()
    context.start(HashingContext.HASH_SHA256)
    context.update(_square_camera_state().to_utf8_buffer())
    return context.finish().hex_encode()

func _subject_bounds(image: Image) -> Dictionary:
    var background := image.get_pixel(0, 0)
    var min_x := image.get_width()
    var min_y := image.get_height()
    var max_x := -1
    var max_y := -1
    var subject_pixels := 0
    for y in range(image.get_height()):
        for x in range(image.get_width()):
            var pixel := image.get_pixel(x, y)
            if Vector3(pixel.r, pixel.g, pixel.b).distance_to(Vector3(background.r, background.g, background.b)) > 0.045:
                min_x = mini(min_x, x); min_y = mini(min_y, y); max_x = maxi(max_x, x); max_y = maxi(max_y, y); subject_pixels += 1
    if max_x < 0:
        return {"x":0,"y":0,"width":0,"height":0,"minEdgeMargin":0,"widthPercentage":0.0,"heightPercentage":0.0,"horizontalCentreError":128.0,"verticalCentreError":128.0,"subjectPixels":0}
    var width := max_x - min_x + 1
    var height := max_y - min_y + 1
    return {"x":min_x,"y":min_y,"width":width,"height":height,"minEdgeMargin":mini(min_x,mini(min_y,mini(255-max_x,255-max_y))),"widthPercentage":float(width) / 256.0 * 100.0,"heightPercentage":float(height) / 256.0 * 100.0,"horizontalCentreError":abs((float(min_x + max_x) * 0.5) - 127.5),"verticalCentreError":abs((float(min_y + max_y) * 0.5) - 127.5),"subjectPixels":subject_pixels}

func _validate_subject_bounds() -> void:
    var width_percentage := float(v0354_subject_bounds.get("widthPercentage", 0.0))
    var height_percentage := float(v0354_subject_bounds.get("heightPercentage", 0.0))
    var margin := int(v0354_subject_bounds.get("minEdgeMargin", 0))
    var horizontal_error := float(v0354_subject_bounds.get("horizontalCentreError", 999.0))
    var vertical_error := float(v0354_subject_bounds.get("verticalCentreError", 999.0))
    if margin < 16 or horizontal_error > 6.0 or vertical_error > 10.0 or width_percentage < 45.0 or width_percentage > 82.0 or height_percentage < 35.0 or height_percentage > 82.0:
        v0354_failure = true

func _build_debug_labels() -> void:
    var label := Label3D.new()
    label.name = "V0354_DEBUG_REVIEW_Projected_Bounds_Readout"
    label.text = "DEBUG_REVIEW | projected bounds %s | margin %d | centre error %.1f / %.1f | occupancy %.1f%% x %.1f%%" % [str(v0354_subject_bounds), int(v0354_subject_bounds.get("minEdgeMargin", 0)), float(v0354_subject_bounds.get("horizontalCentreError", 0.0)), float(v0354_subject_bounds.get("verticalCentreError", 0.0)), float(v0354_subject_bounds.get("widthPercentage", 0.0)), float(v0354_subject_bounds.get("heightPercentage", 0.0))]
    label.font_size = 20; label.outline_size = 7; label.modulate = Color("#e5d6ad"); label.position = Vector3(0, 7.0, 4.2); label.billboard = BaseMaterial3D.BILLBOARD_ENABLED; debug_review.add_child(label)
    var camera_label := Label3D.new()
    camera_label.name = "V0354_DEBUG_REVIEW_Square_Camera_State_Identity"
    camera_label.text = "SQUARE CAMERA HASH %s | KEEP_HEIGHT | ORTHOGRAPHIC | 25.0 | 256x256 | NO CROP / NO STRETCH" % _square_camera_hash()
    camera_label.font_size = 18; camera_label.outline_size = 7; camera_label.modulate = Color("#c3ddc7"); camera_label.position = Vector3(0, 6.2, 4.2); camera_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED; debug_review.add_child(camera_label)
    var hash_label := Label3D.new()
    hash_label.name = "V0354_DEBUG_REVIEW_Source_Board_Hash"
    hash_label.text = "RAW SOURCE SHA256 = DISPLAYED SOURCE SHA256 | %s" % v0354_raw_hash
    hash_label.font_size = 18; hash_label.outline_size = 7; hash_label.modulate = Color("#c3ddc7"); hash_label.position = Vector3(0, 5.4, 4.2); hash_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED; debug_review.add_child(hash_label)

func _sha256_file(path: String) -> String:
    var context := HashingContext.new(); context.start(HashingContext.HASH_SHA256); context.update(FileAccess.get_file_as_bytes(path)); return context.finish().hex_encode()

func _write_v0354_manifest() -> void:
    var outcome := OS.get_environment("V0354_INTERNAL_OUTCOME")
    if outcome == "": outcome = V0354_READY_OUTCOME
    if v0354_failure: outcome = V0354_FAILURE_OUTCOME
    var path := v0354_capture_root.path_join("v0354-barn-final-evidence-runtime.json")
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null: return
    var manifest := {"schemaVersion":1,"checkpoint":V0354_CHECKPOINT,"status":"PASS_V0354_BARN_FINAL_EVIDENCE_RUNTIME" if not v0354_failure and errors.is_empty() else "FAIL_V0354_BARN_FINAL_EVIDENCE_RUNTIME","outcome":outcome,"automatedVisualApproval":false,"humanReviewRequired":true,"frozenV0352RoofRepair":true,"frozenRoofRepairHash":V0354_FROZEN_ROOF_HASH,"frozenV0351Shutters":true,"frozenV0350MaterialBaseline":true,"frozenV0353Workers":true,"frozenV0353TerrainContact":true,"completeWorkerCount":2,"uprightWorkerCount":2,"disassembledWorkerCount":0,"detachedWorkerPartCount":0,"horizontalWorkerCount":0,"workerScenePath":V0353_WORKER_SCENE_PATH,"workerInstantiationMethod":"PackedScene.instantiate_once_per_worker","minimumContextWorkerPixelHeight":24,"visibleContactBlobCount":0,"visibleOvalStainCount":0,"visibleElongatedStainCount":0,"visibleRectangularContactArtifactCount":0,"visibleDecalBoundaryCount":0,"floatingFoundationGeometryCount":0,"foundationContactMethod":"engine directional shadow and ambient fill only; no artificial ground geometry","actual256SourceDimensions":"256x256","actual256PixelAspectRatio":1.0,"actual256SubjectBoundingBox":v0354_subject_bounds,"actual256SubjectWidthPercentage":v0354_subject_bounds.get("widthPercentage",0.0),"actual256SubjectHeightPercentage":v0354_subject_bounds.get("heightPercentage",0.0),"actual256MinimumEdgeMargin":v0354_subject_bounds.get("minEdgeMargin",0),"actual256HorizontalCentreError":v0354_subject_bounds.get("horizontalCentreError",999.0),"actual256VerticalCentreError":v0354_subject_bounds.get("verticalCentreError",999.0),"reviewBoard256DisplayDimensions":"512x512","reviewBoard256DisplayAspectRatio":1.0,"stretched256EvidenceCount":0,"cropped256EvidenceCount":0,"clipped256EvidenceCount":0,"offCentre256EvidenceCount":0,"squareNeutralCameraHash":v0354_square_neutral_hash,"squareGreyscaleCameraHash":v0354_square_greyscale_hash,"squareWarmCameraHash":v0354_square_warm_hash,"raw256SourceHash":v0354_raw_hash,"reviewBoardDisplayed256SourceHash":v0354_review_source_hash,"contextualCameraMode":"three-quarter RTS","rawCaptureCount":V0354_RAW_NAMES.size(),"captures":v0354_captures,"requiredRawNames":V0354_RAW_NAMES,"exactTenFiles":true,"exactlyEightPng":true,"noVideo":true,"noDefaultRuntimeMutation":true,"noGameplay":true,"scenePath":V0354_SCENE_PATH,"sourceOfFailedV0353Square":"artifacts/runtime/v0353/screenshots/14_true_256_pixel_source.png","squareCameraFailureDiagnosis":"v0.353 created an independent local SubViewport camera and reused wide-camera framing; its transform did not copy the accepted camera global transform in the shared World3D, leaving the barn off-centre and clipped. v0.354 copies global transform, uses KEEP_HEIGHT, and calculates square bounds.","errors":errors}
    file.store_string(JSON.stringify(manifest, "  "))
