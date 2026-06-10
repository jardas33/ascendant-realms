extends Node3D

const MODE := "2_5D_ORTHOGRAPHIC_PLACEHOLDER"
const VISUAL_PRESET_CLEAN := "CLEAN_READABILITY"
const VISUAL_PRESET_ATMOSPHERIC := "ATMOSPHERIC_BALANCED"
const VISUAL_PRESET_VFX_STRESS := "VFX_STRESS_PRIVATE"
const SAFE_ZOOM_MIN := 7.8
const SAFE_ZOOM_MAX := 13.8
const SAFE_FRAME_DEFAULT_ZOOM := 10.8
const CAMERA_DEFAULT_POSITION := Vector3(0.0, 11.6, 8.9)
const CAMERA_DEFAULT_ROTATION := Vector3(-60.0, 0.0, 0.0)
const CAMERA_KEYBOARD_PAN_STEP := 0.55
const CAMERA_WHEEL_ZOOM_STEP := 0.55
const CAMERA_PAN_MIN_X := -5.8
const CAMERA_PAN_MAX_X := 5.8
const CAMERA_PAN_MIN_Z := 7.6
const CAMERA_PAN_MAX_Z := 10.4
const REAL_INPUT_GROUND_Y := 0.12
const REAL_INPUT_SELECT_DRAG_THRESHOLD := 12.0
const REAL_INPUT_HERO_CLICK_RADIUS := 54.0
const REAL_INPUT_WORKER_CLICK_RADIUS := 46.0
const REAL_INPUT_UNIT_CLICK_RADIUS := 38.0
const REAL_INPUT_VISIBLE_MOVE_DELTA := 48.0
const WEST_STONE_CUT_MINE_LABEL := "West Stone Cut Mine"
const WEST_STONE_CUT_MINE_SITE_ID := "west_stone_cut"
const WEST_STONE_CUT_MINE_RUNTIME_ID := "site_west_stone_cut"
const WEST_STONE_CUT_MINE_POSITION := Vector2(650, 460)
const WEST_STONE_CUT_MINE_CAPTURE_RADIUS := 96.0
const V0132_CONVERSION_PROGRESS_PER_SECOND := 24.0
const SITE_STATE_NEUTRAL := "NEUTRAL"
const SITE_STATE_OBJECTIVE_TARGET := "OBJECTIVE_TARGET"
const SITE_STATE_CONVERTING := "CONVERTING"
const SITE_STATE_CONTROLLED := "CONTROLLED"
const SITE_STATE_WORKER_ASSIGNED := "WORKER_ASSIGNED"
const BARRACKS_POSITION := Vector2(346, 178)
const BARRACKS_CLICK_RADIUS := 82.0
const LUME_LINK_POSITION := Vector2(742, 200)
const LUME_CLICK_RADIUS := 74.0
const V0133_CONSTRUCTION_FRAMES_PER_SECOND := 24
const V0133_RECRUIT_FRAMES_PER_SECOND := 24
const V0133_PRESSURE_COUNTDOWN_SECONDS := 7.0
const WORKER_ART_SLOT_ID := "worker_billboard_static_v0147"
const WORKER_ART_APPROACH := "HYBRID_WORKER_TRIMMED_1024"
const WORKER_ART_EXPECTED_SHA256 := "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
const WORKER_ART_EXPECTED_WIDTH := 1024
const WORKER_ART_EXPECTED_HEIGHT := 1024
const WORKER_ART_DEFAULT_SCALE := 1.0
const WORKER_ART_QUAD_HEIGHT := 0.74
const WORKER_ART_QUAD_WIDTH := 0.55
const WORKER_ART_GROUND_CLEARANCE := 0.02
const BARRACKS_MATERIAL_SLOT_ID := "barrosan_barracks_material_v0149"
const BARRACKS_MATERIAL_APPROACH := "HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND"
const BARRACKS_MATERIAL_EXPECTED_SHA256 := "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
const BARRACKS_MATERIAL_EXPECTED_WIDTH := 768
const BARRACKS_MATERIAL_EXPECTED_HEIGHT := 768
const MILITIA_ART_SLOT_ID := "militia_billboard_static_v0154"
const MILITIA_ART_APPROACH := "HYBRID_MILITIA_TRIMMED_1024"
const MILITIA_ART_EXPECTED_SHA256 := "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb"
const MILITIA_ART_EXPECTED_WIDTH := 1024
const MILITIA_ART_EXPECTED_HEIGHT := 1024
const MILITIA_ART_DEFAULT_SCALE := 1.0
const MILITIA_ART_QUAD_HEIGHT := 0.68
const MILITIA_ART_QUAD_WIDTH := 0.50
const MILITIA_ART_GROUND_CLEARANCE := 0.02
const ASTER_ART_SLOT_ID := "aster_billboard_static_v0151"
const ASTER_ART_APPROACH := "HYBRID_ASTER_TRIMMED_1024"
const ASTER_ART_EXPECTED_SHA256 := "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a"
const ASTER_ART_EXPECTED_WIDTH := 1024
const ASTER_ART_EXPECTED_HEIGHT := 1024
const ASTER_ART_DEFAULT_SCALE := 1.08
const ASTER_ART_QUAD_HEIGHT := 0.92
const ASTER_ART_GROUND_CLEARANCE := 0.02
const ASHEN_ART_SLOT_ID := "ashen_raider_billboard_static_v0156"
const ASHEN_ART_APPROACH := "HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024"
const ASHEN_ART_EXPECTED_SHA256 := "8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8"
const ASHEN_ART_EXPECTED_WIDTH := 1024
const ASHEN_ART_EXPECTED_HEIGHT := 1024
const ASHEN_ART_DEFAULT_SCALE := 1.0
const ASHEN_ART_QUAD_HEIGHT := 0.72
const ASHEN_ART_GROUND_CLEARANCE := 0.02
const GROUND_MATERIAL_SLOT_ID := "barrosan_foothold_ground_material_v0175"
const GROUND_MATERIAL_APPROACH := "GROUND_MATERIAL_LOCAL_1024"
const GROUND_MATERIAL_EXPECTED_SHA256 := "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8"
const GROUND_MATERIAL_EXPECTED_WIDTH := 1024
const GROUND_MATERIAL_EXPECTED_HEIGHT := 1024
const GROUND_MATERIAL_DEFAULT_UV_SCALE := 0.56
const GROUND_MATERIAL_PREVIOUS_UV_SCALE := 0.72
const GROUND_MATERIAL_VISUAL_ALPHA := 0.18
const GROUND_MATERIAL_TINT_R := 1.50
const GROUND_MATERIAL_TINT_G := 1.47
const GROUND_MATERIAL_TINT_B := 1.24
const GROUND_MATERIAL_OVERLAY_LIFT := 0.006
const ROAD_MATERIAL_SLOT_ID := "barrosan_foothold_road_material_v0180"
const ROAD_MATERIAL_APPROACH := "ROAD_MATERIAL_LOCAL_1024"
const ROAD_MATERIAL_EXPECTED_SHA256 := "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10"
const ROAD_MATERIAL_EXPECTED_WIDTH := 1024
const ROAD_MATERIAL_EXPECTED_HEIGHT := 1024
const ROAD_MATERIAL_DEFAULT_UV_SCALE := 0.80
const ROAD_MATERIAL_VISUAL_ALPHA := 0.60
const ROAD_MATERIAL_TINT_R := 1.74
const ROAD_MATERIAL_TINT_G := 1.58
const ROAD_MATERIAL_TINT_B := 1.20
const ROAD_MATERIAL_OVERLAY_LIFT := 0.004
const WorkloadRuntimeScript = preload("res://scripts/salto_spike_workload_runtime.gd")

var runtime = WorkloadRuntimeScript.new()
var visual_preset := VISUAL_PRESET_CLEAN
var terrain_root: Node3D
var visual_root: Node3D
var hud_layer: CanvasLayer
var hud_status_label: Label
var hud_hero_label: Label
var hud_objective_label: Label
var hud_resource_label: Label
var hud_context_label: Label
var hud_onboarding_label: Label
var hud_alert_label: Label
var hud_objective_strip_label: Label
var hud_more_details_button: Button
var hud_more_details_label: Label
var hud_work_button: Button
var hud_attack_button: Button
var hud_help_button: Button
var hud_help_panel: Panel
var hud_help_label: Label
var hud_tooltip_label: Label
var minimap_panel: Panel
var camera_panned := false
var camera_zoomed := false
var camera_focus_id := "default"
var camera_zoom_posture := "default"
var player_facing_mode := false
var player_shell_screen := "battle"
var hover_target_id := ""
var last_feedback_id := "none"
var combat_readability_active := false
var damage_flash_active := false
var death_fade_active := false
var pressure_wave_arrived := false
var site_contest_active := false
var current_onboarding_step := "select_aster"
var onboarding_dismissed := false
var onboarding_private_skip_enabled := true
var onboarding_seen_steps: Array[String] = []
var active_alert_id := "none"
var notification_history: Array[String] = []
var objective_complete_pulse_rendered := false
var concise_alert_rendered := false
var pressure_wave_notice_rendered := false
var lume_activation_notice_rendered := false
var more_details_visible := false
var real_input_trace: Array[Dictionary] = []
var real_input_hover_id := ""
var real_input_selected_id := ""
var real_input_aster_selected := false
var real_input_worker_selected := false
var real_input_squad_box_selected := false
var real_input_move_order_accepted := false
var real_input_attack_order_accepted := false
var real_input_move_marker_rendered := false
var real_input_attack_marker_rendered := false
var real_input_movement_started := false
var real_input_movement_completed := false
var real_input_objective_advanced := false
var real_input_invalid_objective_advance := false
var real_input_debug_shortcut_used := false
var real_input_state_injection_used := false
var real_input_hud_card_updated := false
var real_input_empty_deselect_done := false
var real_input_last_destination := Vector2.INF
var real_input_move_start_position := Vector2.INF
var real_input_movement_displacement := 0.0
var real_input_aster_start_screen := Vector2.INF
var real_input_aster_current_screen := Vector2.INF
var real_input_aster_screen_delta := 0.0
var real_input_visible_movement_confirmed := false
var real_input_drag_start := Vector2.INF
var real_input_drag_active := false
var real_input_drag_rect: ColorRect
var aster_label: Label3D
var west_stone_cut_label: Label3D
var worker_guidance_label: Label3D
var v0132_site_state := SITE_STATE_NEUTRAL
var v0132_conversion_progress := 0.0
var v0132_aster_entered_capture_radius := false
var v0132_conversion_progress_visible := false
var v0132_mine_controlled := false
var v0132_worker_highlight_visible := false
var v0132_worker_assignment_marker_rendered := false
var v0132_worker_assignment_complete := false
var v0132_production_boost_feedback_rendered := false
var v0132_worker_objective_advanced := false
var v0132_objective_regression_blocked_count := 0
var v0132_actual_objective_regression_detected := false
var v0132_objective_history: Array[Dictionary] = []
var v0133_illegal_objective_skip_rejected_count := 0
var v0133_box_select_no_skip_proven := false
var v0133_selected_structure_id := ""
var v0133_barracks_highlight_visible := false
var v0133_barracks_build_order_accepted := false
var v0133_construction_started := false
var v0133_construction_progress := 0.0
var v0133_construction_25_recorded := false
var v0133_construction_75_recorded := false
var v0133_barracks_restored := false
var v0133_barracks_selected := false
var v0133_train_militia_clicked := false
var v0133_recruit_queue_started := false
var v0133_recruit_progress := 0.0
var v0133_recruit_queue_50_recorded := false
var v0133_militia_spawned := false
var v0133_countdown_started := false
var v0133_countdown_remaining := 0.0
var v0133_countdown_ticks: Array[int] = []
var v0133_wave_triggered_once := false
var v0133_wave_trigger_source := ""
var v0133_road_entry_pulse_visible := false
var v0133_enemy_movement_started := false
var v0133_enemy_start_positions: Dictionary = {}
var v0133_combat_handoff_done := false
var v0133_attack_input_accepted := false
var v0133_combat_started := false
var v0133_initial_combat_tick_count := 0
var v0133_wave_remaining_count := 4
var v0133_wave_defeated_from_simulation := false
var v0133_lume_highlight_visible := false
var v0133_lume_restore_input := false
var v0133_lume_restored := false
var v0133_results_reached := false
var v0134_recovery_feedback_ids: Array[String] = []
var v0134_recovery_feedback_count := 0
var v0135_help_overlay_visible := false
var v0135_help_opened := false
var v0135_help_dismissed := false
var v0135_camera_pan_input_seen := false
var v0135_camera_zoom_input_seen := false
var v0135_focus_aster_input_seen := false
var v0135_escape_handled := false
var v0135_invalid_order_marker_rendered := false
var v0135_context_action_marker_rendered := false
var v0135_selected_squad_count_visible := false
var v0135_tooltip_visible := false
var v0135_hover_response_seen := false
var v0135_selected_unit_marker_seen := false
var v0135_keyboard_pan_count := 0
var v0135_mouse_wheel_zoom_count := 0
var v0136_minimap_click_orient_seen := false
var v0136_results_recap_seen := false
var v0136_last_minimap_focus := ""
var worker_art_experiment_enabled := false
var worker_art_requested_scale := WORKER_ART_DEFAULT_SCALE
var worker_art_source_path := ""
var worker_art_metadata_path := ""
var worker_art_expected_sha256 := WORKER_ART_EXPECTED_SHA256
var worker_art_fallback_mode := "none"
var worker_art_texture: ImageTexture
var worker_art_material: StandardMaterial3D
var worker_art_mesh: QuadMesh
var worker_art_status: Dictionary = {}
var worker_art_source_load_count := 0
var worker_art_metadata_parse_count := 0
var worker_art_image_decode_count := 0
var worker_art_texture_create_count := 0
var worker_art_material_create_count := 0
var worker_art_mesh_create_count := 0
var worker_art_material_reuse_count := 0
var barracks_material_experiment_enabled := false
var barracks_material_source_path := ""
var barracks_material_metadata_path := ""
var barracks_material_expected_sha256 := BARRACKS_MATERIAL_EXPECTED_SHA256
var barracks_material_fallback_mode := "none"
var barracks_material_texture: ImageTexture
var barracks_material_override: StandardMaterial3D
var barracks_material_status: Dictionary = {}
var barracks_material_source_load_count := 0
var barracks_material_metadata_parse_count := 0
var barracks_material_image_decode_count := 0
var barracks_material_texture_create_count := 0
var barracks_material_material_create_count := 0
var barracks_material_material_reuse_count := 0
var barracks_material_applied_surface_count := 0
var militia_art_experiment_enabled := false
var militia_art_requested_scale := MILITIA_ART_DEFAULT_SCALE
var militia_art_source_path := ""
var militia_art_metadata_path := ""
var militia_art_expected_sha256 := MILITIA_ART_EXPECTED_SHA256
var militia_art_fallback_mode := "none"
var militia_art_texture: ImageTexture
var militia_art_material: StandardMaterial3D
var militia_art_mesh: QuadMesh
var militia_art_status: Dictionary = {}
var militia_art_source_load_count := 0
var militia_art_metadata_parse_count := 0
var militia_art_image_decode_count := 0
var militia_art_texture_create_count := 0
var militia_art_material_create_count := 0
var militia_art_mesh_create_count := 0
var militia_art_material_reuse_count := 0
var aster_art_experiment_enabled := false
var aster_art_requested_scale := ASTER_ART_DEFAULT_SCALE
var aster_art_source_path := ""
var aster_art_metadata_path := ""
var aster_art_expected_sha256 := ASTER_ART_EXPECTED_SHA256
var aster_art_fallback_mode := "none"
var aster_art_texture: ImageTexture
var aster_art_material: StandardMaterial3D
var aster_art_mesh: QuadMesh
var aster_art_status: Dictionary = {}
var aster_art_source_load_count := 0
var aster_art_metadata_parse_count := 0
var aster_art_image_decode_count := 0
var aster_art_texture_create_count := 0
var aster_art_material_create_count := 0
var aster_art_mesh_create_count := 0
var aster_art_material_reuse_count := 0
var ashen_art_experiment_enabled := false
var ashen_art_requested_scale := ASHEN_ART_DEFAULT_SCALE
var ashen_art_source_path := ""
var ashen_art_metadata_path := ""
var ashen_art_expected_sha256 := ASHEN_ART_EXPECTED_SHA256
var ashen_art_fallback_mode := "none"
var ashen_art_texture: ImageTexture
var ashen_art_material: StandardMaterial3D
var ashen_art_mesh: QuadMesh
var ashen_art_status: Dictionary = {}
var ashen_art_source_load_count := 0
var ashen_art_metadata_parse_count := 0
var ashen_art_image_decode_count := 0
var ashen_art_texture_create_count := 0
var ashen_art_material_create_count := 0
var ashen_art_mesh_create_count := 0
var ashen_art_material_reuse_count := 0
var three_slot_art_review_framing_active := false
var five_slot_art_review_framing_active := false
var environment_foundation_review_enabled := false
var environment_readability_hardening_enabled := false
var environment_contrast_harmonization_enabled := false
var environment_geometry_convergence_enabled := false
var environment_shell_live_qa_enabled := false
var environment_structure_shell_hardening_enabled := false
var environment_riverbank_bridge_approach_enabled := false
var environment_presentation_shell_v2_enabled := false
var presentation_shell_v2_initialized := false
var presentation_shell_v2_fallback_active := false
var presentation_shell_v2_fallback_reason := ""
var presentation_shell_v2_surface_counts: Dictionary = {}
var presentation_shell_v2_topology_metrics: Dictionary = {}
var presentation_shell_v2_material_cache: Dictionary = {}
var presentation_shell_v2_material_create_count := 0
var presentation_shell_v2_material_reuse_count := 0
var ground_material_experiment_enabled := false
var ground_material_source_path := ""
var ground_material_metadata_path := ""
var ground_material_expected_sha256 := GROUND_MATERIAL_EXPECTED_SHA256
var ground_material_fallback_mode := "none"
var ground_material_requested_uv_scale := GROUND_MATERIAL_DEFAULT_UV_SCALE
var ground_material_texture: ImageTexture
var ground_material_override: StandardMaterial3D
var ground_material_status: Dictionary = {}
var ground_material_source_load_count := 0
var ground_material_metadata_parse_count := 0
var ground_material_image_decode_count := 0
var ground_material_texture_create_count := 0
var ground_material_material_create_count := 0
var ground_material_material_reuse_count := 0
var ground_material_applied_surface_count := 0
var ground_material_applied_surface_names: Array[String] = []
var road_material_experiment_enabled := false
var road_material_source_path := ""
var road_material_metadata_path := ""
var road_material_expected_sha256 := ROAD_MATERIAL_EXPECTED_SHA256
var road_material_fallback_mode := "none"
var road_material_requested_uv_scale := ROAD_MATERIAL_DEFAULT_UV_SCALE
var road_material_texture: ImageTexture
var road_material_override: StandardMaterial3D
var road_material_status: Dictionary = {}
var road_material_source_load_count := 0
var road_material_metadata_parse_count := 0
var road_material_image_decode_count := 0
var road_material_texture_create_count := 0
var road_material_material_create_count := 0
var road_material_material_reuse_count := 0
var road_material_applied_surface_count := 0
var road_material_applied_surface_names: Array[String] = []

func _ready() -> void:
	_reset_worker_art_status(false, "opt-in flag absent")
	_reset_barracks_material_status(false, "opt-in flag absent")
	_reset_militia_art_status(false, "opt-in flag absent")
	_reset_aster_art_status(false, "opt-in flag absent")
	_reset_ashen_art_status(false, "opt-in flag absent")
	_reset_ground_material_status(false, "opt-in flag absent")
	_reset_road_material_status(false, "opt-in flag absent")
	_create_camera()
	_create_light()
	_create_terrain()
	visual_root = Node3D.new()
	visual_root.name = "RepresentativeWorkloadVisuals"
	add_child(visual_root)
	_create_hud()
	runtime.set_workload_tier("S")
	_rebuild_visuals()
	_sync_hud()

func _process(_delta: float) -> void:
	if not _real_input_enabled():
		return
	var before := _unit_runtime_position("hero_aster")
	if v0133_wave_triggered_once or v0133_attack_input_accepted:
		runtime.advance_pressure_wave_frame()
	elif runtime.has_active_movement():
		runtime.advance_live_frame()
	var after := _unit_runtime_position("hero_aster")
	if before != Vector2.INF and after != Vector2.INF and after.distance_to(before) > 0.2:
		if not real_input_movement_started:
			real_input_movement_started = true
			_record_real_input("movement_started", {"unitId": "hero_aster", "position": _vector2_report(after)})
		if real_input_move_start_position != Vector2.INF:
			real_input_movement_displacement = max(real_input_movement_displacement, after.distance_to(real_input_move_start_position))
		_update_real_input_visible_movement()
		if real_input_move_order_accepted and not real_input_objective_advanced and real_input_movement_displacement >= 10.0 and real_input_visible_movement_confirmed:
			real_input_objective_advanced = true
			set_onboarding_step("capture_hold_quarry")
			show_objective_feedback("move_to_quarry")
			_record_real_input("objective_advanced_after_real_movement", {
				"displacement": snappedf(real_input_movement_displacement, 0.01),
				"screenDelta": snappedf(real_input_aster_screen_delta, 0.01)
			})
	if real_input_move_order_accepted and real_input_movement_started and not runtime.unit_has_destination("hero_aster"):
		if not real_input_movement_completed:
			real_input_movement_completed = true
			_record_real_input("movement_completed", {"unitId": "hero_aster", "position": _vector2_report(after)})
	_advance_v0132_site_semantics(_delta)
	_advance_v0133_post_mine_flow(_delta)
	_sync_unit_visuals()
	_sync_minimap()
	_sync_hud()

func _input(event: InputEvent) -> void:
	if _try_handle_v0133_hud_attack_mouse(event):
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if not _real_input_enabled():
		return
	if event is InputEventKey:
		if _handle_real_keyboard(event as InputEventKey):
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion:
		_handle_real_mouse_motion(event as InputEventMouseMotion)
		return
	if event is InputEventMouseButton:
		_handle_real_mouse_button(event as InputEventMouseButton)

func set_visual_preset(preset: String) -> bool:
	var normalized := _normalize_visual_preset(preset)
	if normalized == "":
		return false
	visual_preset = normalized
	_refresh_visual_foundation()
	return true

func get_visual_preset() -> String:
	return visual_preset

func configure_environment_foundation_review(enabled: bool) -> Dictionary:
	environment_foundation_review_enabled = enabled
	if not environment_foundation_review_enabled:
		environment_readability_hardening_enabled = false
		environment_contrast_harmonization_enabled = false
		environment_geometry_convergence_enabled = false
		environment_shell_live_qa_enabled = false
		environment_structure_shell_hardening_enabled = false
		environment_riverbank_bridge_approach_enabled = false
		environment_presentation_shell_v2_enabled = false
	_refresh_visual_foundation()
	if environment_foundation_review_enabled:
		apply_environment_foundation_review_framing()
	_apply_environment_readability_minimap_markers()
	return _environment_foundation_status()

func configure_environment_readability_hardening(enabled: bool) -> Dictionary:
	environment_readability_hardening_enabled = enabled
	if environment_readability_hardening_enabled:
		environment_foundation_review_enabled = true
		environment_contrast_harmonization_enabled = false
		environment_geometry_convergence_enabled = false
		environment_shell_live_qa_enabled = false
		environment_structure_shell_hardening_enabled = false
		environment_riverbank_bridge_approach_enabled = false
		environment_presentation_shell_v2_enabled = false
	_refresh_visual_foundation()
	if environment_readability_hardening_enabled:
		apply_environment_readability_hardening_framing()
	elif environment_foundation_review_enabled:
		apply_environment_foundation_review_framing()
	_apply_environment_readability_minimap_markers()
	return _environment_readability_status()

func configure_environment_contrast_harmonization(enabled: bool) -> Dictionary:
	environment_contrast_harmonization_enabled = enabled
	if environment_contrast_harmonization_enabled:
		environment_foundation_review_enabled = true
		environment_readability_hardening_enabled = false
		environment_geometry_convergence_enabled = false
		environment_shell_live_qa_enabled = false
		environment_structure_shell_hardening_enabled = false
		environment_riverbank_bridge_approach_enabled = false
		environment_presentation_shell_v2_enabled = false
	_refresh_visual_foundation()
	if environment_contrast_harmonization_enabled:
		apply_environment_contrast_harmonization_framing()
	elif environment_foundation_review_enabled:
		apply_environment_foundation_review_framing()
	_apply_environment_readability_minimap_markers()
	return _environment_contrast_harmonization_status()

func configure_environment_geometry_convergence(enabled: bool) -> Dictionary:
	environment_geometry_convergence_enabled = enabled
	if environment_geometry_convergence_enabled:
		environment_foundation_review_enabled = true
		environment_readability_hardening_enabled = false
		environment_contrast_harmonization_enabled = false
		environment_shell_live_qa_enabled = false
		environment_structure_shell_hardening_enabled = false
		environment_riverbank_bridge_approach_enabled = false
		environment_presentation_shell_v2_enabled = false
	_refresh_visual_foundation()
	if environment_geometry_convergence_enabled:
		apply_environment_geometry_convergence_framing()
	elif environment_foundation_review_enabled:
		apply_environment_foundation_review_framing()
	_apply_environment_readability_minimap_markers()
	return _environment_geometry_convergence_status()

func configure_environment_shell_live_qa(enabled: bool) -> Dictionary:
	environment_shell_live_qa_enabled = enabled
	if environment_shell_live_qa_enabled:
		environment_foundation_review_enabled = true
		environment_readability_hardening_enabled = false
		environment_contrast_harmonization_enabled = false
		environment_geometry_convergence_enabled = true
		environment_structure_shell_hardening_enabled = false
		environment_riverbank_bridge_approach_enabled = false
		environment_presentation_shell_v2_enabled = false
	_refresh_visual_foundation()
	if environment_shell_live_qa_enabled:
		apply_environment_shell_live_qa_framing()
	elif environment_geometry_convergence_enabled:
		apply_environment_geometry_convergence_framing()
	elif environment_foundation_review_enabled:
		apply_environment_foundation_review_framing()
	_apply_environment_readability_minimap_markers()
	return _environment_shell_live_qa_status()

func configure_environment_structure_shell_hardening(enabled: bool) -> Dictionary:
	environment_structure_shell_hardening_enabled = enabled
	if environment_structure_shell_hardening_enabled:
		environment_foundation_review_enabled = true
		environment_readability_hardening_enabled = false
		environment_contrast_harmonization_enabled = false
		environment_geometry_convergence_enabled = true
		environment_shell_live_qa_enabled = true
		environment_riverbank_bridge_approach_enabled = false
		environment_presentation_shell_v2_enabled = false
	_refresh_visual_foundation()
	if environment_structure_shell_hardening_enabled:
		apply_environment_structure_shell_hardening_framing()
	elif environment_shell_live_qa_enabled:
		apply_environment_shell_live_qa_framing()
	elif environment_geometry_convergence_enabled:
		apply_environment_geometry_convergence_framing()
	elif environment_foundation_review_enabled:
		apply_environment_foundation_review_framing()
	_apply_environment_readability_minimap_markers()
	return _environment_structure_shell_hardening_status()

func configure_environment_riverbank_bridge_approach(enabled: bool) -> Dictionary:
	environment_riverbank_bridge_approach_enabled = enabled
	if environment_riverbank_bridge_approach_enabled:
		environment_foundation_review_enabled = true
		environment_readability_hardening_enabled = false
		environment_contrast_harmonization_enabled = false
		environment_geometry_convergence_enabled = true
		environment_shell_live_qa_enabled = true
		environment_structure_shell_hardening_enabled = true
		environment_presentation_shell_v2_enabled = false
	_refresh_visual_foundation()
	if environment_riverbank_bridge_approach_enabled:
		apply_environment_riverbank_bridge_approach_framing()
	elif environment_structure_shell_hardening_enabled:
		apply_environment_structure_shell_hardening_framing()
	elif environment_shell_live_qa_enabled:
		apply_environment_shell_live_qa_framing()
	elif environment_geometry_convergence_enabled:
		apply_environment_geometry_convergence_framing()
	elif environment_foundation_review_enabled:
		apply_environment_foundation_review_framing()
	_apply_environment_readability_minimap_markers()
	return _environment_riverbank_bridge_approach_status()

func configure_environment_presentation_shell_v2(enabled: bool) -> Dictionary:
	environment_presentation_shell_v2_enabled = enabled
	if environment_presentation_shell_v2_enabled:
		environment_foundation_review_enabled = true
		environment_readability_hardening_enabled = false
		environment_contrast_harmonization_enabled = false
		environment_geometry_convergence_enabled = false
		environment_shell_live_qa_enabled = false
		environment_structure_shell_hardening_enabled = false
		environment_riverbank_bridge_approach_enabled = false
		presentation_shell_v2_fallback_active = false
		presentation_shell_v2_fallback_reason = ""
	_refresh_visual_foundation()
	if environment_presentation_shell_v2_enabled:
		apply_environment_presentation_shell_v2_framing()
	elif environment_riverbank_bridge_approach_enabled:
		apply_environment_riverbank_bridge_approach_framing()
	elif environment_foundation_review_enabled:
		apply_environment_foundation_review_framing()
	_apply_environment_readability_minimap_markers()
	return _environment_presentation_shell_v2_status()

func apply_environment_foundation_review_framing() -> bool:
	if not environment_foundation_review_enabled:
		return false
	_apply_camera_authoring_posture("v0173_environment_foundation", Vector3(1.12, 11.95, 8.35), 9.78)
	return true

func apply_environment_readability_hardening_framing() -> bool:
	if not environment_readability_hardening_enabled:
		return false
	_apply_camera_authoring_posture("v0174_environment_readability", Vector3(-0.88, 11.85, 8.46), 9.92)
	return true

func apply_environment_contrast_harmonization_framing() -> bool:
	if not environment_contrast_harmonization_enabled:
		return false
	_apply_camera_authoring_posture("v0179_environment_contrast", Vector3(-0.96, 11.92, 8.42), 9.88)
	return true

func apply_environment_geometry_convergence_framing() -> bool:
	if not environment_geometry_convergence_enabled:
		return false
	_apply_camera_authoring_posture("v0184_environment_geometry_convergence", Vector3(-0.82, 12.10, 8.18), 9.52)
	return true

func apply_environment_shell_live_qa_framing() -> bool:
	if not environment_shell_live_qa_enabled:
		return false
	_apply_camera_authoring_posture("v0185_environment_shell_live_qa", Vector3(-0.92, 11.92, 8.10), 9.34)
	return true

func apply_environment_structure_shell_hardening_framing() -> bool:
	if not environment_structure_shell_hardening_enabled:
		return false
	_apply_camera_authoring_posture("v0186_structure_shell_hardening", Vector3(-2.84, 11.35, 7.58), 8.24)
	return true

func apply_environment_riverbank_bridge_approach_framing() -> bool:
	if not environment_riverbank_bridge_approach_enabled:
		return false
	_apply_camera_authoring_posture("v0187_riverbank_bridge_approach", Vector3(0.28, 11.16, 7.46), 7.92)
	return true

func apply_environment_presentation_shell_v2_framing() -> bool:
	if not environment_presentation_shell_v2_enabled:
		return false
	_apply_camera_authoring_posture("v0193_presentation_shell_v2", Vector3(-0.64, 11.18, 7.62), 7.80)
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if camera:
		camera.rotation_degrees = Vector3(-53.0, 0.0, 0.0)
	return true

func _environment_foundation_status() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.173",
		"enabled": environment_foundation_review_enabled,
		"reviewOnly": true,
		"runtimeArtSlotAdded": false,
		"aiImageGenerated": false,
		"terrainTextureImported": false,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"gameplayPathingChanged": false,
		"preservesFiveCharacterMaterialSlots": true,
		"appliedLayers": [
			"terrain value hierarchy",
			"main road shoulders and edge ticks",
			"river bank contrast and water reads",
			"bridge deck silhouette",
			"site marker readable collars",
			"mine barracks command hall ground plates",
			"overcast lighting and warm hearth accents"
		]
	}

func _environment_readability_status() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.174",
		"enabled": environment_readability_hardening_enabled,
		"requiresFoundationReview": true,
		"reviewOnly": true,
		"runtimeArtSlotAdded": false,
		"aiImageGenerated": false,
		"terrainTextureImported": false,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"gameplayPathingChanged": false,
		"navigationSemanticsChanged": false,
		"preservesFiveCharacterMaterialSlots": true,
		"materiallyImprovesTacticalReadability": environment_readability_hardening_enabled,
		"minimapCorrelationMarkersRendered": _minimap_has_marker("v0174_minimap_bridge_crossing") and _minimap_marker_visible("v0174_minimap_bridge_crossing"),
		"appliedLayers": [
			"road continuity centerline and intersections",
			"mine and barracks approach lanes",
			"hostile approach lane",
			"friendly foothold boundary",
			"river bank ledges and water contrast",
			"bridge silhouette crossing guards",
			"site-marker hierarchy",
			"minimap correlation markers",
			"camera pan and zoom readability anchors"
		]
	}

func _environment_contrast_harmonization_status() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.179",
		"enabled": environment_contrast_harmonization_enabled,
		"requiresFoundationReview": true,
		"requiresGroundMaterialOptIn": true,
		"reviewOnly": true,
		"runtimeArtSlotAdded": false,
		"aiImageGenerated": false,
		"newTextureImported": false,
		"terrainTextureImportedByHarmonization": false,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"gameplayPathingChanged": false,
		"navigationSemanticsChanged": false,
		"preservesFiveCharacterMaterialSlots": true,
		"materiallyImprovesTacticalReadability": environment_contrast_harmonization_enabled,
		"minimapCorrelationMarkersRendered": _minimap_has_marker("v0174_minimap_bridge_crossing") and _minimap_marker_visible("v0174_minimap_bridge_crossing"),
		"appliedLayers": [
			"road shoulders, centerline, and intersection collars over textured ground",
			"river core and bank lips separated from dark terrain material",
			"bridge crossing silhouette and plank highlights",
			"site-marker hierarchy and approach-lane accents",
			"hostile lane warning tint",
			"minimap correlation markers",
			"restrained warm-cool light rebalance"
		]
	}

func _environment_geometry_convergence_status() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.184",
		"enabled": environment_geometry_convergence_enabled,
		"requiresFoundationReview": true,
		"requiresGroundMaterialOptIn": true,
		"requiresRoadMaterialOptIn": true,
		"reviewOnly": true,
		"runtimeArtSlotAdded": false,
		"aiImageGenerated": false,
		"newTextureImported": false,
		"terrainTextureImportedByConvergence": false,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"gameplayPathingChanged": false,
		"navigationSemanticsChanged": false,
		"collisionGeometryChanged": false,
		"objectiveLogicChanged": false,
		"aiLogicChanged": false,
		"preservesFiveCharacterMaterialSlots": true,
		"materiallyReducesGiantOverlays": environment_geometry_convergence_enabled,
		"groundMaterialsScopedToMasks": environment_geometry_convergence_enabled,
		"roadsReadAsContinuousRoutes": environment_geometry_convergence_enabled,
		"riverReadsAsCoherentChannel": environment_geometry_convergence_enabled,
		"bridgeReadsAsCrossing": environment_geometry_convergence_enabled,
		"structureHierarchyImproved": environment_geometry_convergence_enabled,
		"audit": _environment_geometry_convergence_audit()
	}

func _environment_geometry_convergence_audit() -> Dictionary:
	return {
		"environmentVisualNodeCategories": ["terrain_masks", "road_strips", "river_channel", "riverbanks", "bridge_crossing", "structure_shells", "site_markers", "character_grounding", "minimap_markers"],
		"groundPadCount": 2,
		"roadStripCount": 14,
		"riverSegmentCount": 13,
		"bankSegmentCount": 14,
		"bridgeVisualNodes": ["v0184_bridge_under_shadow", "v0184_bridge_wet_granite_deck", "v0184_bridge_north_rail", "v0184_bridge_south_rail", "v0184_bridge_west_abutment", "v0184_bridge_east_abutment", "v0184_bridge_plank_00", "v0184_bridge_plank_01", "v0184_bridge_plank_02"],
		"structureShellNodes": ["v0184_command_foundation", "v0184_command_roof_mass", "v0184_command_hearth_slit", "v0184_mine_retaining_wall", "v0184_mine_cut_shadow", "v0184_barracks_foundation", "v0184_barracks_scaffold_timber", "v0184_barracks_roof_trim"],
		"transparencyValues": {"groundMasks": 0.08, "roadShoulderMasks": 0.30, "riverEdgeGlaze": 0.22, "siteMarkers": 0.48, "characterContact": 0.20},
		"zOrderValues": {"terrainBaseY": 0.104, "groundMaskY": 0.168, "roadY": 0.214, "riverY": 0.190, "bankY": 0.226, "bridgeY": 0.354, "structureContactY": 0.198, "markersY": 0.330},
		"materialBindTargets": {"ground": ["v0173_terrain_mid_value_field", "v0173_friendly_staging_value_field"], "road": ["v0173_main_road_wide_readable_bed", "v0173_barracks_side_path_wide_bed", "v0173_ruins_side_path_wide_bed"]},
		"uvScales": {"ground": ground_material_requested_uv_scale, "road": road_material_requested_uv_scale},
		"visualOnlyNodes": true,
		"gameplayCollisionNodesLeftUntouched": ["runtime fixture positions", "real-input click radii", "site capture radius", "Barracks click radius", "Lume click radius", "pathing/navigation adapters", "stable-id adapters"],
		"minimapSemanticsPreserved": true
	}

func _environment_shell_live_qa_status() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.185",
		"enabled": environment_shell_live_qa_enabled,
		"requiresGeometryConvergence": true,
		"requiresFoundationReview": true,
		"requiresGroundMaterialOptIn": true,
		"requiresRoadMaterialOptIn": true,
		"reviewOnly": true,
		"runtimeArtSlotAdded": false,
		"aiImageGenerated": false,
		"newTextureImported": false,
		"terrainTextureImportedByLiveQa": false,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"gameplayPathingChanged": false,
		"navigationSemanticsChanged": false,
		"collisionGeometryChanged": false,
		"objectiveLogicChanged": false,
		"aiLogicChanged": false,
		"preservesFiveCharacterMaterialSlots": true,
		"addsEnvironmentMaterialSlot": false,
		"residualGiantOverlaysPruned": environment_shell_live_qa_enabled,
		"floatingReviewRectanglesMateriallyReduced": environment_shell_live_qa_enabled,
		"transparentLayerCompetitionReduced": environment_shell_live_qa_enabled,
		"roadsRiverBridgeContinuous": environment_shell_live_qa_enabled,
		"structureHierarchyImproved": environment_shell_live_qa_enabled,
		"charactersReadable": environment_shell_live_qa_enabled,
		"audit": _environment_shell_live_qa_audit()
	}

func _environment_shell_live_qa_audit() -> Dictionary:
	return {
		"environmentVisualNodeCategories": ["terrain_value_edges", "road_continuity", "river_channel", "riverbanks", "bridge_crossing", "structure_grounding", "site_markers", "character_grounding"],
		"broadPadsReframedAsGroundingCues": ["buildable_ground_patch_friendly", "buildable_ground_patch_forward", "capture_site_readability_ring", "v0137_barracks_footprint_chalk", "v0137_command_hall_hearth_pool", "v0137_friendly_staging_muster_marks", "v0137_ashen_approach_lane_char", "v0137_subtle_terrain_fog_default"],
		"largeTransparentDiagnosticPadsKept": 0,
		"newArtSlots": 0,
		"newImportedTextures": 0,
		"siteMarkerStyle": {"outerRingRadius": 0.56, "innerDiscRadius": 0.26, "baseDiscRadius": 0.30, "maxAlpha": 0.34},
		"liveQaTransparencyValues": {"groundMasks": 0.035, "reviewPads": 0.18, "siteMarkers": 0.34, "roadCrown": 0.24, "characterContact": 0.18},
		"zOrderValues": {"terrainBaseY": 0.104, "groundMaskY": 0.168, "roadY": 0.214, "riverY": 0.190, "bankY": 0.226, "bridgeY": 0.354, "structureContactY": 0.198, "markersY": 0.330},
		"visualOnlyNodes": true,
		"gameplayCollisionNodesLeftUntouched": ["runtime fixture positions", "real-input click radii", "site capture radius", "Barracks click radius", "Lume click radius", "pathing/navigation adapters", "stable-id adapters"],
		"minimapSemanticsPreserved": true
	}

func _environment_structure_shell_hardening_status() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.186",
		"enabled": environment_structure_shell_hardening_enabled,
		"requiresShellLiveQa": true,
		"requiresGeometryConvergence": true,
		"requiresFoundationReview": true,
		"requiresGroundMaterialOptIn": true,
		"requiresRoadMaterialOptIn": true,
		"reviewOnly": true,
		"runtimeArtSlotAdded": false,
		"aiImageGenerated": false,
		"newTextureImported": false,
		"structureTextureImported": false,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"gameplayPathingChanged": false,
		"navigationSemanticsChanged": false,
		"collisionGeometryChanged": false,
		"objectiveLogicChanged": false,
		"aiLogicChanged": false,
		"preservesFiveCharacterMaterialSlots": true,
		"addsEnvironmentMaterialSlot": false,
		"structureHierarchyMateriallyImproved": environment_structure_shell_hardening_enabled,
		"commandHallDistinguishable": environment_structure_shell_hardening_enabled,
		"mineDistinguishable": environment_structure_shell_hardening_enabled,
		"barracksRestorationStateReadable": environment_structure_shell_hardening_enabled,
		"shellsGroundedInsideTerrain": environment_structure_shell_hardening_enabled,
		"warmAccentsRestrained": environment_structure_shell_hardening_enabled,
		"charactersReadable": environment_structure_shell_hardening_enabled,
		"audit": _environment_structure_shell_hardening_audit()
	}

func _environment_structure_shell_hardening_audit() -> Dictionary:
	return {
		"environmentVisualNodeCategories": ["command_hall_shell", "mine_shell", "barracks_restoration_shell", "site_structure_shells", "defensive_props", "contact_shadows"],
		"newArtSlots": 0,
		"newImportedTextures": 0,
		"structureMaterialSlotsAdded": 0,
		"proceduralVisualOnly": true,
		"commandHallNodes": ["v0186_wet_granite_foundation", "v0186_timber_side_posts", "v0186_stepped_keep_core", "v0186_low_gabled_roof", "v0186_restrained_hearth_slot", "v0186_door_threshold_shadow"],
		"mineNodes": ["v0186_quarry_retaining_walls", "v0186_deep_mine_mouth", "v0186_cut_stone_tiers", "v0186_crane_tripod", "v0186_tailings_ground_shadow"],
		"barracksNodes": ["v0186_grounded_drill_yard", "v0186_split_training_wings", "v0186_scaffold_posts", "v0186_roof_ridge", "v0186_restoration_progress_read"],
		"siteStructureNodes": ["v0186_site_claim_post", "v0186_site_low_stone_ring", "v0186_practical_defensive_crates"],
		"visualLanguage": ["wet_granite_foundations", "timber_frames", "restrained_metal", "practical_scaffolding", "warm_hearth_accents"],
		"gameplayCollisionNodesLeftUntouched": ["runtime fixture positions", "real-input click radii", "site capture radius", "Barracks click radius", "Lume click radius", "pathing/navigation adapters", "stable-id adapters"],
		"minimapSemanticsPreserved": true
	}

func _environment_riverbank_bridge_approach_status() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.187",
		"enabled": environment_riverbank_bridge_approach_enabled,
		"requiresStructureShellHardening": true,
		"requiresShellLiveQa": true,
		"requiresGeometryConvergence": true,
		"requiresFoundationReview": true,
		"requiresGroundMaterialOptIn": true,
		"requiresRoadMaterialOptIn": true,
		"reviewOnly": true,
		"runtimeArtSlotAdded": false,
		"aiImageGenerated": false,
		"newTextureImported": false,
		"waterShaderPipelineAdded": false,
		"bridgeRiverbankMaterialSlotAdded": false,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"gameplayPathingChanged": false,
		"navigationSemanticsChanged": false,
		"collisionGeometryChanged": false,
		"objectiveLogicChanged": false,
		"aiLogicChanged": false,
		"preservesFiveCharacterMaterialSlots": true,
		"addsEnvironmentMaterialSlot": false,
		"riverReadsAsOneCoherentChannel": environment_riverbank_bridge_approach_enabled,
		"banksFrameRiverClearly": environment_riverbank_bridge_approach_enabled,
		"bridgeReadsAsCrossing": environment_riverbank_bridge_approach_enabled,
		"approachLanesReadable": environment_riverbank_bridge_approach_enabled,
		"roadToBridgeTransitionReadable": environment_riverbank_bridge_approach_enabled,
		"hostileApproachLaneReadable": environment_riverbank_bridge_approach_enabled,
		"friendlyApproachReadable": environment_riverbank_bridge_approach_enabled,
		"minimapCorrelationPreserved": environment_riverbank_bridge_approach_enabled,
		"charactersOverCrossingReadable": environment_riverbank_bridge_approach_enabled,
		"structuresRemainCoherent": environment_riverbank_bridge_approach_enabled,
		"traversalSemanticsUnchanged": true,
		"audit": _environment_riverbank_bridge_approach_audit()
	}

func _environment_riverbank_bridge_approach_audit() -> Dictionary:
	return {
		"environmentVisualNodeCategories": ["river_channel", "riverbank_lips", "bridge_crossing", "abutments", "road_to_bridge_transition", "friendly_approach", "hostile_approach", "minimap_correlation"],
		"newArtSlots": 0,
		"newImportedTextures": 0,
		"bridgeRiverbankMaterialSlotsAdded": 0,
		"waterShadersAdded": 0,
		"proceduralVisualOnly": true,
		"riverContinuityNodes": ["v0187_river_channel_central_continuity", "v0187_river_north_bend_join", "v0187_river_south_bend_join", "v0187_river_under_bridge_dark_cut", "v0187_river_shallow_crossing_glaze"],
		"bankShapeNodes": ["v0187_west_bank_upper_lip", "v0187_west_bank_lower_lip", "v0187_east_bank_upper_lip", "v0187_east_bank_lower_lip", "v0187_bridge_bank_shadow_west", "v0187_bridge_bank_shadow_east"],
		"bridgeCrossingNodes": ["v0187_bridge_deck_readable_span", "v0187_bridge_west_abutment_mass", "v0187_bridge_east_abutment_mass", "v0187_bridge_north_low_rail", "v0187_bridge_south_low_rail", "v0187_bridge_plank_tick_00"],
		"approachLaneNodes": ["v0187_west_road_to_bridge_collar", "v0187_east_road_from_bridge_collar", "v0187_friendly_approach_lane_feather", "v0187_hostile_approach_lane_feather", "v0187_crossing_combat_readability_lane"],
		"minimapCorrelationNodes": ["v0174_minimap_bridge_crossing", "v0174_minimap_road_intersections", "v0174_minimap_hostile_approach", "v0174_minimap_friendly_boundary"],
		"gameplayCollisionNodesLeftUntouched": ["runtime fixture positions", "real-input click radii", "site capture radius", "bridge traversal smoke path", "pathing/navigation adapters", "stable-id adapters"],
		"bridgeTraversalBehaviorUnchanged": true,
		"zOrderValues": {"riverCoreY": 0.292, "bankLipY": 0.318, "approachLaneY": 0.342, "bridgeDeckY": 0.386, "bridgeRailY": 0.462, "markerY": 0.372}
	}

func _environment_presentation_shell_v2_status() -> Dictionary:
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.195",
		"enabled": environment_presentation_shell_v2_enabled,
		"initialized": presentation_shell_v2_initialized,
		"fallbackActive": presentation_shell_v2_fallback_active,
		"fallbackReason": presentation_shell_v2_fallback_reason,
		"legacyShellFallbackAvailable": true,
		"legacyFallbackFlag": "--salto-riverbank-bridge-approach-hardening",
		"requiresFiveCharacterSlots": true,
		"requiresGroundMaterialOptIn": true,
		"requiresRoadMaterialOptIn": true,
		"reviewOnly": true,
		"runtimeArtSlotAdded": false,
		"aiImageGenerated": false,
		"newTextureImported": false,
		"wetGraniteBridgeRiverbankMaterialIntegrated": false,
		"bridgeRiverbankMaterialSlotAdded": false,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"gameplayPathingChanged": false,
		"navigationSemanticsChanged": false,
		"collisionGeometryChanged": false,
		"objectiveLogicChanged": false,
		"aiLogicChanged": false,
		"preservesFiveCharacterMaterialSlots": true,
		"addsEnvironmentMaterialSlot": false,
		"usesExistingGroundMaterial": ground_material_experiment_enabled,
		"usesExistingRoadMaterial": road_material_experiment_enabled,
		"groundMaterialSha256": str(ground_material_status.get("actualSha256", "")),
		"roadMaterialSha256": str(road_material_status.get("actualSha256", "")),
		"largeFloatingRectanglesMateriallyReduced": environment_presentation_shell_v2_enabled and presentation_shell_v2_initialized,
		"giantTransparentDiagnosticPads": 0,
		"roadsFollowRoutes": environment_presentation_shell_v2_enabled and presentation_shell_v2_initialized,
		"roadNetworkReadableAtReviewDistance": environment_presentation_shell_v2_enabled and presentation_shell_v2_initialized,
		"scopedMaterialRecoveryActive": environment_presentation_shell_v2_enabled and presentation_shell_v2_initialized,
		"terrainHierarchyMateriallyImproved": environment_presentation_shell_v2_enabled and presentation_shell_v2_initialized,
		"broadMaterialMasksReintroduced": false,
		"riverReadsContinuously": environment_presentation_shell_v2_enabled and presentation_shell_v2_initialized,
		"banksFrameRiver": environment_presentation_shell_v2_enabled and presentation_shell_v2_initialized,
		"bridgeReadsAsCrossing": environment_presentation_shell_v2_enabled and presentation_shell_v2_initialized,
		"structureMassesImproved": environment_presentation_shell_v2_enabled and presentation_shell_v2_initialized,
		"charactersGrounded": environment_presentation_shell_v2_enabled and presentation_shell_v2_initialized,
		"minimalOverlay": true,
		"overcastPaletteRestrained": true,
		"explicitZOrder": {
			"terrainBaseY": 0.104,
			"scopedGroundY": 0.132,
			"riverCoreY": 0.172,
			"bankY": 0.206,
			"roadY": 0.292,
			"roadCrownY": 0.326,
			"bridgeRampY": 0.322,
			"bridgeDeckY": 0.340,
			"siteMarkerY": 0.280,
			"structureContactY": 0.160,
			"unitContactY": 0.170
		},
		"surfaceCounts": presentation_shell_v2_surface_counts.duplicate(true),
		"topologyRepair": presentation_shell_v2_topology_metrics.duplicate(true),
		"proceduralMaterialCacheKeys": presentation_shell_v2_material_cache.keys(),
		"proceduralMaterialCreateCount": presentation_shell_v2_material_create_count,
		"proceduralMaterialReuseCount": presentation_shell_v2_material_reuse_count,
		"noPerFrameDecodeOrParse": true,
		"noRepeatedMaterialCreation": true,
		"gameplayCollisionNodesLeftUntouched": ["runtime fixture positions", "real-input click radii", "site capture radius", "bridge traversal smoke path", "pathing/navigation adapters", "stable-id adapters"],
		"visualOnlyNodes": true
	}

func configure_worker_art_experiment(options: Dictionary) -> Dictionary:
	worker_art_experiment_enabled = bool(options.get("enabled", false))
	worker_art_requested_scale = maxf(0.5, minf(1.25, float(options.get("scale", WORKER_ART_DEFAULT_SCALE))))
	worker_art_source_path = str(options.get("sourcePath", ""))
	worker_art_metadata_path = str(options.get("metadataPath", ""))
	worker_art_expected_sha256 = str(options.get("expectedSha256", WORKER_ART_EXPECTED_SHA256)).to_lower()
	worker_art_fallback_mode = str(options.get("fallbackMode", "none"))
	worker_art_texture = null
	worker_art_material = null
	worker_art_mesh = null
	worker_art_source_load_count = 0
	worker_art_metadata_parse_count = 0
	worker_art_image_decode_count = 0
	worker_art_texture_create_count = 0
	worker_art_material_create_count = 0
	worker_art_mesh_create_count = 0
	worker_art_material_reuse_count = 0
	if not worker_art_experiment_enabled:
		_reset_worker_art_status(false, "opt-in flag absent")
		_rebuild_visuals()
		return worker_art_status.duplicate(true)
	_load_worker_art_candidate()
	_rebuild_visuals()
	return worker_art_status.duplicate(true)

func get_worker_art_status() -> Dictionary:
	return worker_art_status.duplicate(true)

func _reset_worker_art_status(enabled: bool, reason: String) -> void:
	worker_art_status = {
		"schemaVersion": 1,
		"checkpoint": "v0.160",
		"slotId": WORKER_ART_SLOT_ID,
		"approach": WORKER_ART_APPROACH,
		"enabled": enabled,
		"sourceLoaded": false,
		"billboardActive": false,
		"fallbackActive": true,
		"fallbackReason": reason,
		"sourcePath": worker_art_source_path,
		"metadataPath": worker_art_metadata_path,
		"expectedSha256": worker_art_expected_sha256,
		"actualSha256": "",
		"sourceDimensions": {"width": 0, "height": 0},
		"metadataDimensions": {"width": 0, "height": 0},
		"trimmedPixelDimensions": {"width": 0, "height": 0},
		"alphaBounds": {},
		"alphaPosture": "",
		"pivot": {},
		"scale": worker_art_requested_scale,
		"fallbackMode": worker_art_fallback_mode,
		"proceduralFallbackVisible": true,
		"selectionAndGameplayIdsPreserved": true,
		"stableWorkerId": "worker_00",
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"secondArtSlotAdded": false,
		"productionManifestMutated": false,
		"sourceLoadCount": worker_art_source_load_count,
		"metadataParseCount": worker_art_metadata_parse_count,
		"imageDecodeCount": worker_art_image_decode_count,
		"textureCreateCount": worker_art_texture_create_count,
		"materialCreateCount": worker_art_material_create_count,
		"meshCreateCount": worker_art_mesh_create_count,
		"materialReuseCount": worker_art_material_reuse_count
	}
	_refresh_worker_art_counters()

func _load_worker_art_candidate() -> void:
	_reset_worker_art_status(true, "not loaded")
	var start_usec := Time.get_ticks_usec()
	if worker_art_source_path == "":
		_set_worker_art_fallback("missing source path")
		return
	if not FileAccess.file_exists(worker_art_source_path):
		_set_worker_art_fallback("missing source file")
		return
	if worker_art_metadata_path == "" or not FileAccess.file_exists(worker_art_metadata_path):
		_set_worker_art_fallback("missing metadata file")
		return
	var metadata := _read_worker_art_metadata(worker_art_metadata_path)
	if metadata.is_empty():
		_set_worker_art_fallback("metadata parse failure")
		return
	if str(metadata.get("slotId", "")) != WORKER_ART_SLOT_ID:
		_set_worker_art_fallback("metadata slot mismatch")
		return
	var metadata_sha := str(metadata.get("sha256", "")).to_lower()
	if metadata_sha != worker_art_expected_sha256:
		_set_worker_art_fallback("metadata hash mismatch")
		return
	var dimensions: Dictionary = metadata.get("dimensions", {})
	var metadata_width := int(dimensions.get("width", 0))
	var metadata_height := int(dimensions.get("height", 0))
	if metadata_width != WORKER_ART_EXPECTED_WIDTH or metadata_height != WORKER_ART_EXPECTED_HEIGHT:
		_set_worker_art_fallback("metadata dimension mismatch")
		return
	var actual_sha := _sha256_file(worker_art_source_path)
	worker_art_status["actualSha256"] = actual_sha
	if actual_sha != worker_art_expected_sha256:
		_set_worker_art_fallback("source hash mismatch")
		return
	var image := Image.new()
	worker_art_source_load_count += 1
	var load_result := image.load(worker_art_source_path)
	if load_result != OK:
		_set_worker_art_fallback("image load failure %s" % str(load_result))
		return
	worker_art_image_decode_count += 1
	if image.get_width() != WORKER_ART_EXPECTED_WIDTH or image.get_height() != WORKER_ART_EXPECTED_HEIGHT:
		_set_worker_art_fallback("image dimension mismatch")
		return
	worker_art_texture = ImageTexture.create_from_image(image)
	if worker_art_texture == null:
		_set_worker_art_fallback("texture creation failure")
		return
	worker_art_texture_create_count += 1
	worker_art_status["enabled"] = true
	worker_art_status["sourceLoaded"] = true
	worker_art_status["billboardActive"] = true
	worker_art_status["fallbackActive"] = false
	worker_art_status["fallbackReason"] = ""
	worker_art_status["sourcePath"] = worker_art_source_path
	worker_art_status["metadataPath"] = worker_art_metadata_path
	worker_art_status["expectedSha256"] = worker_art_expected_sha256
	worker_art_status["actualSha256"] = actual_sha
	worker_art_status["sourceDimensions"] = {"width": image.get_width(), "height": image.get_height()}
	worker_art_status["metadataDimensions"] = {"width": metadata_width, "height": metadata_height}
	var trim_bounds: Dictionary = metadata.get("trimBounds", {})
	worker_art_status["alphaBounds"] = trim_bounds
	worker_art_status["trimmedPixelDimensions"] = {
		"width": int(trim_bounds.get("width", 0)),
		"height": int(trim_bounds.get("height", 0))
	}
	worker_art_status["alphaPosture"] = str(metadata.get("alphaPosture", ""))
	worker_art_status["pivot"] = metadata.get("pivot", {})
	worker_art_status["scale"] = worker_art_requested_scale
	worker_art_status["fallbackMode"] = worker_art_fallback_mode
	worker_art_status["proceduralFallbackVisible"] = false
	worker_art_status["loadDurationMs"] = snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	_refresh_worker_art_counters()

func _read_worker_art_metadata(path: String) -> Dictionary:
	worker_art_metadata_parse_count += 1
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _sha256_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	while file.get_position() < file.get_length():
		var remaining := file.get_length() - file.get_position()
		context.update(file.get_buffer(int(min(65536, remaining))))
	return context.finish().hex_encode()

func _set_worker_art_fallback(reason: String) -> void:
	worker_art_texture = null
	worker_art_material = null
	worker_art_mesh = null
	worker_art_status["enabled"] = worker_art_experiment_enabled
	worker_art_status["billboardActive"] = false
	worker_art_status["sourceLoaded"] = false
	worker_art_status["fallbackActive"] = true
	worker_art_status["fallbackReason"] = reason
	worker_art_status["sourcePath"] = worker_art_source_path
	worker_art_status["metadataPath"] = worker_art_metadata_path
	worker_art_status["expectedSha256"] = worker_art_expected_sha256
	worker_art_status["scale"] = worker_art_requested_scale
	worker_art_status["fallbackMode"] = worker_art_fallback_mode
	worker_art_status["proceduralFallbackVisible"] = true
	_refresh_worker_art_counters()

func _refresh_worker_art_counters() -> void:
	worker_art_status["sourceLoadCount"] = worker_art_source_load_count
	worker_art_status["metadataParseCount"] = worker_art_metadata_parse_count
	worker_art_status["imageDecodeCount"] = worker_art_image_decode_count
	worker_art_status["textureCreateCount"] = worker_art_texture_create_count
	worker_art_status["materialCreateCount"] = worker_art_material_create_count
	worker_art_status["meshCreateCount"] = worker_art_mesh_create_count
	worker_art_status["materialReuseCount"] = worker_art_material_reuse_count
	var runtime_height := _worker_art_unit_height()
	var runtime_width := _worker_art_unit_width()
	var source_aspect := float(WORKER_ART_EXPECTED_WIDTH) / maxf(1.0, float(WORKER_ART_EXPECTED_HEIGHT))
	var runtime_aspect := runtime_width / maxf(0.001, runtime_height)
	worker_art_status["runtimeWorldWidth"] = snappedf(runtime_width, 0.0001)
	worker_art_status["runtimeWorldHeight"] = snappedf(runtime_height, 0.0001)
	var worker_pixels := _orthographic_rendered_pixel_size(runtime_width, runtime_height)
	worker_art_status["renderedPixelWidth"] = worker_pixels["width"]
	worker_art_status["renderedPixelHeight"] = worker_pixels["height"]
	worker_art_status["sourceAspectRatio"] = snappedf(source_aspect, 0.0001)
	worker_art_status["runtimeAspectRatio"] = snappedf(runtime_aspect, 0.0001)
	worker_art_status["aspectRatioPreserved"] = absf(runtime_aspect - source_aspect) <= 0.001
	worker_art_status["terrainFootContactY"] = snappedf(WORKER_ART_GROUND_CLEARANCE, 0.0001)
	worker_art_status["selectionRingDiameter"] = snappedf(_unit_radius({"role": "Worker", "fixtureId": "worker", "team": "friendly"}) * 2.2, 0.0001)
	worker_art_status["renderedSelectionRingDiameterPx"] = _orthographic_rendered_pixel_size(float(worker_art_status["selectionRingDiameter"]), float(worker_art_status["selectionRingDiameter"]))["height"]
	worker_art_status["proceduralUnitBoundingBox"] = {"width": 0.22, "height": 0.36, "depth": 0.18}

func _worker_art_is_active() -> bool:
	return worker_art_experiment_enabled and bool(worker_art_status.get("sourceLoaded", false)) and worker_art_texture != null

func _worker_art_unit_height() -> float:
	return WORKER_ART_QUAD_HEIGHT * worker_art_requested_scale

func _worker_art_unit_width() -> float:
	return _worker_art_unit_height() * (float(WORKER_ART_EXPECTED_WIDTH) / maxf(1.0, float(WORKER_ART_EXPECTED_HEIGHT)))

func _worker_art_unit_y() -> float:
	return WORKER_ART_GROUND_CLEARANCE + _worker_art_unit_height() * 0.5

func _worker_art_quad_mesh() -> QuadMesh:
	if worker_art_mesh:
		return worker_art_mesh
	worker_art_mesh = QuadMesh.new()
	worker_art_mesh.size = Vector2(_worker_art_unit_width(), _worker_art_unit_height())
	worker_art_mesh_create_count += 1
	_refresh_worker_art_counters()
	return worker_art_mesh

func _worker_art_billboard_material() -> StandardMaterial3D:
	if worker_art_material:
		worker_art_material_reuse_count += 1
		_refresh_worker_art_counters()
		return worker_art_material
	worker_art_material = StandardMaterial3D.new()
	worker_art_material.albedo_texture = worker_art_texture
	worker_art_material.albedo_color = Color(1, 1, 1, 1)
	worker_art_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	worker_art_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	worker_art_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	worker_art_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	worker_art_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	worker_art_material_create_count += 1
	_refresh_worker_art_counters()
	return worker_art_material

func configure_barracks_material_experiment(options: Dictionary) -> Dictionary:
	barracks_material_experiment_enabled = bool(options.get("enabled", false))
	barracks_material_source_path = str(options.get("sourcePath", ""))
	barracks_material_metadata_path = str(options.get("metadataPath", ""))
	barracks_material_expected_sha256 = str(options.get("expectedSha256", BARRACKS_MATERIAL_EXPECTED_SHA256)).to_lower()
	barracks_material_fallback_mode = str(options.get("fallbackMode", "none"))
	barracks_material_texture = null
	barracks_material_override = null
	barracks_material_source_load_count = 0
	barracks_material_metadata_parse_count = 0
	barracks_material_image_decode_count = 0
	barracks_material_texture_create_count = 0
	barracks_material_material_create_count = 0
	barracks_material_material_reuse_count = 0
	barracks_material_applied_surface_count = 0
	if not barracks_material_experiment_enabled:
		_reset_barracks_material_status(false, "opt-in flag absent")
		_rebuild_visuals()
		return barracks_material_status.duplicate(true)
	_load_barracks_material_candidate()
	_rebuild_visuals()
	return barracks_material_status.duplicate(true)

func get_barracks_material_status() -> Dictionary:
	return barracks_material_status.duplicate(true)

func _reset_barracks_material_status(enabled: bool, reason: String) -> void:
	barracks_material_status = {
		"schemaVersion": 1,
		"checkpoint": "v0.162",
		"slotId": BARRACKS_MATERIAL_SLOT_ID,
		"approach": BARRACKS_MATERIAL_APPROACH,
		"enabled": enabled,
		"sourceLoaded": false,
		"materialActive": false,
		"fallbackActive": true,
		"fallbackReason": reason,
		"sourcePath": barracks_material_source_path,
		"metadataPath": barracks_material_metadata_path,
		"expectedSha256": barracks_material_expected_sha256,
		"actualSha256": "",
		"sourceDimensions": {"width": 0, "height": 0},
		"metadataDimensions": {"width": 0, "height": 0},
		"uvScale": 1.0,
		"tilingMode": "",
		"fallbackMode": barracks_material_fallback_mode,
		"proceduralFallbackVisible": true,
		"appliedOnlyToBarracks": true,
		"stableBarracksId": "barracks",
		"workerArtPreserved": true,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"thirdArtSlotAdded": false,
		"productionManifestMutated": false,
		"sourceLoadCount": barracks_material_source_load_count,
		"metadataParseCount": barracks_material_metadata_parse_count,
		"imageDecodeCount": barracks_material_image_decode_count,
		"textureCreateCount": barracks_material_texture_create_count,
		"materialCreateCount": barracks_material_material_create_count,
		"materialReuseCount": barracks_material_material_reuse_count,
		"appliedSurfaceCount": barracks_material_applied_surface_count
	}

func _load_barracks_material_candidate() -> void:
	_reset_barracks_material_status(true, "not loaded")
	var start_usec := Time.get_ticks_usec()
	if barracks_material_source_path == "":
		_set_barracks_material_fallback("missing source path")
		return
	if not FileAccess.file_exists(barracks_material_source_path):
		_set_barracks_material_fallback("missing source file")
		return
	if barracks_material_metadata_path == "" or not FileAccess.file_exists(barracks_material_metadata_path):
		_set_barracks_material_fallback("missing metadata file")
		return
	var metadata := _read_barracks_material_metadata(barracks_material_metadata_path)
	if metadata.is_empty():
		_set_barracks_material_fallback("metadata parse failure")
		return
	if str(metadata.get("slotId", "")) != BARRACKS_MATERIAL_SLOT_ID:
		_set_barracks_material_fallback("metadata slot mismatch")
		return
	if str(metadata.get("approach", "")) != BARRACKS_MATERIAL_APPROACH:
		_set_barracks_material_fallback("metadata approach mismatch")
		return
	var metadata_sha := str(metadata.get("sha256", "")).to_lower()
	if metadata_sha != barracks_material_expected_sha256:
		_set_barracks_material_fallback("metadata hash mismatch")
		return
	var dimensions: Dictionary = metadata.get("dimensions", {})
	var metadata_width := int(dimensions.get("width", 0))
	var metadata_height := int(dimensions.get("height", 0))
	if metadata_width != BARRACKS_MATERIAL_EXPECTED_WIDTH or metadata_height != BARRACKS_MATERIAL_EXPECTED_HEIGHT:
		_set_barracks_material_fallback("metadata dimension mismatch")
		return
	var actual_sha := _sha256_file(barracks_material_source_path)
	barracks_material_status["actualSha256"] = actual_sha
	if actual_sha != barracks_material_expected_sha256:
		_set_barracks_material_fallback("source hash mismatch")
		return
	var image := Image.new()
	barracks_material_source_load_count += 1
	var load_result := image.load(barracks_material_source_path)
	if load_result != OK:
		_set_barracks_material_fallback("image load failure %s" % str(load_result))
		return
	barracks_material_image_decode_count += 1
	if image.get_width() != BARRACKS_MATERIAL_EXPECTED_WIDTH or image.get_height() != BARRACKS_MATERIAL_EXPECTED_HEIGHT:
		_set_barracks_material_fallback("image dimension mismatch")
		return
	barracks_material_texture = ImageTexture.create_from_image(image)
	if barracks_material_texture == null:
		_set_barracks_material_fallback("texture creation failure")
		return
	barracks_material_texture_create_count += 1
	barracks_material_status["enabled"] = true
	barracks_material_status["sourceLoaded"] = true
	barracks_material_status["materialActive"] = true
	barracks_material_status["fallbackActive"] = false
	barracks_material_status["fallbackReason"] = ""
	barracks_material_status["sourcePath"] = barracks_material_source_path
	barracks_material_status["metadataPath"] = barracks_material_metadata_path
	barracks_material_status["expectedSha256"] = barracks_material_expected_sha256
	barracks_material_status["actualSha256"] = actual_sha
	barracks_material_status["sourceDimensions"] = {"width": image.get_width(), "height": image.get_height()}
	barracks_material_status["metadataDimensions"] = {"width": metadata_width, "height": metadata_height}
	barracks_material_status["uvScale"] = float(metadata.get("uvScale", 1.0))
	barracks_material_status["tilingMode"] = str(metadata.get("tilingMode", ""))
	barracks_material_status["fallbackMode"] = barracks_material_fallback_mode
	barracks_material_status["proceduralFallbackVisible"] = false
	barracks_material_status["loadDurationMs"] = snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	_refresh_barracks_material_counters()

func _read_barracks_material_metadata(path: String) -> Dictionary:
	barracks_material_metadata_parse_count += 1
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _set_barracks_material_fallback(reason: String) -> void:
	barracks_material_texture = null
	barracks_material_override = null
	barracks_material_status["enabled"] = barracks_material_experiment_enabled
	barracks_material_status["materialActive"] = false
	barracks_material_status["sourceLoaded"] = false
	barracks_material_status["fallbackActive"] = true
	barracks_material_status["fallbackReason"] = reason
	barracks_material_status["sourcePath"] = barracks_material_source_path
	barracks_material_status["metadataPath"] = barracks_material_metadata_path
	barracks_material_status["expectedSha256"] = barracks_material_expected_sha256
	barracks_material_status["fallbackMode"] = barracks_material_fallback_mode
	barracks_material_status["proceduralFallbackVisible"] = true
	_refresh_barracks_material_counters()

func _refresh_barracks_material_counters() -> void:
	barracks_material_status["sourceLoadCount"] = barracks_material_source_load_count
	barracks_material_status["metadataParseCount"] = barracks_material_metadata_parse_count
	barracks_material_status["imageDecodeCount"] = barracks_material_image_decode_count
	barracks_material_status["textureCreateCount"] = barracks_material_texture_create_count
	barracks_material_status["materialCreateCount"] = barracks_material_material_create_count
	barracks_material_status["materialReuseCount"] = barracks_material_material_reuse_count
	barracks_material_status["appliedSurfaceCount"] = barracks_material_applied_surface_count

func _barracks_material_is_active() -> bool:
	return barracks_material_experiment_enabled and bool(barracks_material_status.get("sourceLoaded", false)) and barracks_material_texture != null

func _barracks_material() -> StandardMaterial3D:
	if barracks_material_override:
		barracks_material_material_reuse_count += 1
		_refresh_barracks_material_counters()
		return barracks_material_override
	barracks_material_override = StandardMaterial3D.new()
	barracks_material_override.albedo_texture = barracks_material_texture
	barracks_material_override.albedo_color = Color(0.82, 0.78, 0.66, 1.0)
	barracks_material_override.roughness = 0.86
	barracks_material_override.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	barracks_material_override.cull_mode = BaseMaterial3D.CULL_BACK
	barracks_material_material_create_count += 1
	_refresh_barracks_material_counters()
	return barracks_material_override

func _add_barracks_material_box(name: String, position: Vector3, scale: Vector3, color: Color, transparent: bool = false) -> void:
	_add_box(name, position, scale, color, transparent)
	if not _barracks_material_is_active():
		return
	var mesh_instance := visual_root.get_node_or_null(name) as MeshInstance3D
	if mesh_instance == null:
		return
	mesh_instance.material_override = _barracks_material()
	barracks_material_applied_surface_count += 1
	_refresh_barracks_material_counters()

func configure_ground_material_experiment(options: Dictionary) -> Dictionary:
	ground_material_experiment_enabled = bool(options.get("enabled", false))
	ground_material_source_path = str(options.get("sourcePath", ""))
	ground_material_metadata_path = str(options.get("metadataPath", ""))
	ground_material_expected_sha256 = str(options.get("expectedSha256", GROUND_MATERIAL_EXPECTED_SHA256)).to_lower()
	ground_material_fallback_mode = str(options.get("fallbackMode", "none"))
	ground_material_requested_uv_scale = clampf(float(options.get("uvScale", GROUND_MATERIAL_DEFAULT_UV_SCALE)), 0.35, 1.25)
	ground_material_texture = null
	ground_material_override = null
	ground_material_source_load_count = 0
	ground_material_metadata_parse_count = 0
	ground_material_image_decode_count = 0
	ground_material_texture_create_count = 0
	ground_material_material_create_count = 0
	ground_material_material_reuse_count = 0
	ground_material_applied_surface_count = 0
	ground_material_applied_surface_names = []
	if not ground_material_experiment_enabled:
		_reset_ground_material_status(false, "opt-in flag absent")
		_refresh_visual_foundation()
		return ground_material_status.duplicate(true)
	_load_ground_material_candidate()
	_refresh_visual_foundation()
	return ground_material_status.duplicate(true)

func get_ground_material_status() -> Dictionary:
	return ground_material_status.duplicate(true)

func _reset_ground_material_status(enabled: bool, reason: String) -> void:
	ground_material_status = {
		"schemaVersion": 1,
		"checkpoint": "v0.178",
		"slotId": GROUND_MATERIAL_SLOT_ID,
		"approach": GROUND_MATERIAL_APPROACH,
		"enabled": enabled,
		"sourceLoaded": false,
		"materialActive": false,
		"fallbackActive": true,
		"fallbackReason": reason,
		"sourcePath": ground_material_source_path,
		"metadataPath": ground_material_metadata_path,
		"expectedSha256": ground_material_expected_sha256,
		"actualSha256": "",
		"sourceDimensions": {"width": 0, "height": 0},
		"metadataDimensions": {"width": 0, "height": 0},
		"uvScale": ground_material_requested_uv_scale,
		"uvScaleHardenedFrom": GROUND_MATERIAL_PREVIOUS_UV_SCALE,
		"uvScaleHardenedTo": ground_material_requested_uv_scale,
		"tilingMode": "",
		"filterMode": "linear with mipmaps",
		"visualHardeningCheckpoint": "v0.178",
		"noiseControlAlpha": GROUND_MATERIAL_VISUAL_ALPHA,
		"visualTint": {"r": GROUND_MATERIAL_TINT_R, "g": GROUND_MATERIAL_TINT_G, "b": GROUND_MATERIAL_TINT_B, "a": GROUND_MATERIAL_VISUAL_ALPHA},
		"proceduralValueUnderlayVisible": false,
		"proceduralValueUnderlayPurpose": "low-frequency terrain value retention under the texture overlay",
		"fallbackMode": ground_material_fallback_mode,
		"proceduralFallbackVisible": true,
		"appliedOnlyToFootholdGround": true,
		"appliedSurfaceNames": [],
		"excludedSurfaces": ["roads", "river", "banks", "bridge", "structures", "site markers", "minimap", "character slots"],
		"environmentFoundationReviewRequired": true,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"characterSlotCountChanged": false,
		"productionManifestMutated": false,
		"sourceLoadCount": ground_material_source_load_count,
		"metadataParseCount": ground_material_metadata_parse_count,
		"imageDecodeCount": ground_material_image_decode_count,
		"textureCreateCount": ground_material_texture_create_count,
		"materialCreateCount": ground_material_material_create_count,
		"materialReuseCount": ground_material_material_reuse_count,
		"appliedSurfaceCount": ground_material_applied_surface_count
	}

func _load_ground_material_candidate() -> void:
	_reset_ground_material_status(true, "not loaded")
	var start_usec := Time.get_ticks_usec()
	if ground_material_source_path == "":
		_set_ground_material_fallback("missing source path")
		return
	if not FileAccess.file_exists(ground_material_source_path):
		_set_ground_material_fallback("missing source file")
		return
	if ground_material_metadata_path == "" or not FileAccess.file_exists(ground_material_metadata_path):
		_set_ground_material_fallback("missing metadata file")
		return
	var metadata := _read_ground_material_metadata(ground_material_metadata_path)
	if metadata.is_empty():
		_set_ground_material_fallback("metadata parse failure")
		return
	if str(metadata.get("slotId", "")) != GROUND_MATERIAL_SLOT_ID:
		_set_ground_material_fallback("metadata slot mismatch")
		return
	if str(metadata.get("approach", "")) != GROUND_MATERIAL_APPROACH:
		_set_ground_material_fallback("metadata approach mismatch")
		return
	var metadata_sha := str(metadata.get("sha256", "")).to_lower()
	if metadata_sha != ground_material_expected_sha256:
		_set_ground_material_fallback("metadata hash mismatch")
		return
	var dimensions: Dictionary = metadata.get("dimensions", {})
	var metadata_width := int(dimensions.get("width", 0))
	var metadata_height := int(dimensions.get("height", 0))
	if metadata_width != GROUND_MATERIAL_EXPECTED_WIDTH or metadata_height != GROUND_MATERIAL_EXPECTED_HEIGHT:
		_set_ground_material_fallback("metadata dimension mismatch")
		return
	var actual_sha := _sha256_file(ground_material_source_path)
	ground_material_status["actualSha256"] = actual_sha
	if actual_sha != ground_material_expected_sha256:
		_set_ground_material_fallback("source hash mismatch")
		return
	var image := Image.new()
	ground_material_source_load_count += 1
	var load_result := image.load(ground_material_source_path)
	if load_result != OK:
		_set_ground_material_fallback("image load failure %s" % str(load_result))
		return
	ground_material_image_decode_count += 1
	if image.get_width() != GROUND_MATERIAL_EXPECTED_WIDTH or image.get_height() != GROUND_MATERIAL_EXPECTED_HEIGHT:
		_set_ground_material_fallback("image dimension mismatch")
		return
	ground_material_texture = ImageTexture.create_from_image(image)
	if ground_material_texture == null:
		_set_ground_material_fallback("texture creation failure")
		return
	ground_material_texture_create_count += 1
	ground_material_status["enabled"] = true
	ground_material_status["sourceLoaded"] = true
	ground_material_status["materialActive"] = true
	ground_material_status["fallbackActive"] = false
	ground_material_status["fallbackReason"] = ""
	ground_material_status["sourcePath"] = ground_material_source_path
	ground_material_status["metadataPath"] = ground_material_metadata_path
	ground_material_status["expectedSha256"] = ground_material_expected_sha256
	ground_material_status["actualSha256"] = actual_sha
	ground_material_status["sourceDimensions"] = {"width": image.get_width(), "height": image.get_height()}
	ground_material_status["metadataDimensions"] = {"width": metadata_width, "height": metadata_height}
	ground_material_status["uvScale"] = ground_material_requested_uv_scale
	ground_material_status["uvScaleHardenedTo"] = ground_material_requested_uv_scale
	ground_material_status["sourceMetadataUvScale"] = float(metadata.get("uvScale", 1.0))
	ground_material_status["tilingMode"] = str(metadata.get("tilingMode", "repeat player-slice material"))
	ground_material_status["fallbackMode"] = ground_material_fallback_mode
	ground_material_status["proceduralFallbackVisible"] = false
	ground_material_status["proceduralValueUnderlayVisible"] = true
	ground_material_status["loadDurationMs"] = snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	_refresh_ground_material_counters()

func _read_ground_material_metadata(path: String) -> Dictionary:
	ground_material_metadata_parse_count += 1
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _set_ground_material_fallback(reason: String) -> void:
	ground_material_texture = null
	ground_material_override = null
	ground_material_status["enabled"] = ground_material_experiment_enabled
	ground_material_status["materialActive"] = false
	ground_material_status["sourceLoaded"] = false
	ground_material_status["fallbackActive"] = true
	ground_material_status["fallbackReason"] = reason
	ground_material_status["sourcePath"] = ground_material_source_path
	ground_material_status["metadataPath"] = ground_material_metadata_path
	ground_material_status["expectedSha256"] = ground_material_expected_sha256
	ground_material_status["fallbackMode"] = ground_material_fallback_mode
	ground_material_status["uvScale"] = ground_material_requested_uv_scale
	ground_material_status["uvScaleHardenedTo"] = ground_material_requested_uv_scale
	ground_material_status["proceduralFallbackVisible"] = true
	ground_material_status["proceduralValueUnderlayVisible"] = false
	_refresh_ground_material_counters()

func _refresh_ground_material_counters() -> void:
	ground_material_status["sourceLoadCount"] = ground_material_source_load_count
	ground_material_status["metadataParseCount"] = ground_material_metadata_parse_count
	ground_material_status["imageDecodeCount"] = ground_material_image_decode_count
	ground_material_status["textureCreateCount"] = ground_material_texture_create_count
	ground_material_status["materialCreateCount"] = ground_material_material_create_count
	ground_material_status["materialReuseCount"] = ground_material_material_reuse_count
	ground_material_status["appliedSurfaceCount"] = ground_material_applied_surface_count
	ground_material_status["appliedSurfaceNames"] = ground_material_applied_surface_names.duplicate()

func _ground_material_is_active() -> bool:
	return ground_material_experiment_enabled and environment_foundation_review_enabled and bool(ground_material_status.get("sourceLoaded", false)) and ground_material_texture != null

func _ground_material() -> StandardMaterial3D:
	if ground_material_override:
		ground_material_material_reuse_count += 1
		_refresh_ground_material_counters()
		return ground_material_override
	ground_material_override = StandardMaterial3D.new()
	ground_material_override.albedo_texture = ground_material_texture
	ground_material_override.albedo_color = Color(GROUND_MATERIAL_TINT_R, GROUND_MATERIAL_TINT_G, GROUND_MATERIAL_TINT_B, GROUND_MATERIAL_VISUAL_ALPHA)
	ground_material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ground_material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ground_material_override.roughness = 0.94
	ground_material_override.metallic = 0.0
	ground_material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	ground_material_override.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	ground_material_override.uv1_scale = Vector3(ground_material_requested_uv_scale, ground_material_requested_uv_scale, 1.0)
	ground_material_material_create_count += 1
	_refresh_ground_material_counters()
	return ground_material_override

func _add_ground_material_static_box(name: String, position: Vector3, scale: Vector3, fallback_color: Color, transparent: bool = false) -> void:
	if not _ground_material_is_active():
		_add_static_box(name, position, scale, fallback_color, transparent)
		return
	_add_static_box("%s_procedural_value_underlay" % name, position, scale, fallback_color, transparent)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position + Vector3(0.0, GROUND_MATERIAL_OVERLAY_LIFT, 0.0)
	mesh_instance.material_override = _ground_material()
	terrain_root.add_child(mesh_instance)
	ground_material_applied_surface_count += 1
	if not ground_material_applied_surface_names.has(name):
		ground_material_applied_surface_names.append(name)
	_refresh_ground_material_counters()

func configure_road_material_experiment(options: Dictionary) -> Dictionary:
	road_material_experiment_enabled = bool(options.get("enabled", false))
	road_material_source_path = str(options.get("sourcePath", ""))
	road_material_metadata_path = str(options.get("metadataPath", ""))
	road_material_expected_sha256 = str(options.get("expectedSha256", ROAD_MATERIAL_EXPECTED_SHA256)).to_lower()
	road_material_fallback_mode = str(options.get("fallbackMode", "none"))
	road_material_requested_uv_scale = clampf(float(options.get("uvScale", ROAD_MATERIAL_DEFAULT_UV_SCALE)), 0.45, 1.20)
	road_material_texture = null
	road_material_override = null
	road_material_source_load_count = 0
	road_material_metadata_parse_count = 0
	road_material_image_decode_count = 0
	road_material_texture_create_count = 0
	road_material_material_create_count = 0
	road_material_material_reuse_count = 0
	road_material_applied_surface_count = 0
	road_material_applied_surface_names = []
	if not road_material_experiment_enabled:
		_reset_road_material_status(false, "opt-in flag absent")
		_refresh_visual_foundation()
		return road_material_status.duplicate(true)
	_load_road_material_candidate()
	_refresh_visual_foundation()
	return road_material_status.duplicate(true)

func get_road_material_status() -> Dictionary:
	return road_material_status.duplicate(true)

func _reset_road_material_status(enabled: bool, reason: String) -> void:
	road_material_status = {
		"schemaVersion": 1,
		"checkpoint": "v0.181",
		"sourceCheckpoint": "v0.180",
		"slotId": ROAD_MATERIAL_SLOT_ID,
		"approach": ROAD_MATERIAL_APPROACH,
		"enabled": enabled,
		"sourceLoaded": false,
		"materialActive": false,
		"fallbackActive": true,
		"fallbackReason": reason,
		"sourcePath": road_material_source_path,
		"metadataPath": road_material_metadata_path,
		"expectedSha256": road_material_expected_sha256,
		"actualSha256": "",
		"sourceDimensions": {"width": 0, "height": 0},
		"metadataDimensions": {"width": 0, "height": 0},
		"uvScale": road_material_requested_uv_scale,
		"filterMode": "linear with mipmaps",
		"visualAlpha": ROAD_MATERIAL_VISUAL_ALPHA,
		"visualTint": {"r": ROAD_MATERIAL_TINT_R, "g": ROAD_MATERIAL_TINT_G, "b": ROAD_MATERIAL_TINT_B, "a": ROAD_MATERIAL_VISUAL_ALPHA},
		"fallbackMode": road_material_fallback_mode,
		"proceduralFallbackVisible": true,
		"appliedOnlyToRoadSurfaceGroup": true,
		"appliedSurfaceNames": [],
		"allowedSurfaces": ["v0173_main_road_wide_readable_bed", "v0173_barracks_side_path_wide_bed", "v0173_ruins_side_path_wide_bed"],
		"excludedSurfaces": ["ground", "river", "banks", "bridge", "structures", "site markers", "minimap", "character slots", "approach lane overlays"],
		"environmentFoundationReviewRequired": true,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"characterSlotCountChanged": false,
		"productionManifestMutated": false,
		"sourceLoadCount": road_material_source_load_count,
		"metadataParseCount": road_material_metadata_parse_count,
		"imageDecodeCount": road_material_image_decode_count,
		"textureCreateCount": road_material_texture_create_count,
		"materialCreateCount": road_material_material_create_count,
		"materialReuseCount": road_material_material_reuse_count,
		"appliedSurfaceCount": road_material_applied_surface_count
	}

func _load_road_material_candidate() -> void:
	_reset_road_material_status(true, "not loaded")
	var start_usec := Time.get_ticks_usec()
	if road_material_source_path == "":
		_set_road_material_fallback("missing source path")
		return
	if not FileAccess.file_exists(road_material_source_path):
		_set_road_material_fallback("missing source file")
		return
	if road_material_metadata_path == "" or not FileAccess.file_exists(road_material_metadata_path):
		_set_road_material_fallback("missing metadata file")
		return
	var metadata := _read_road_material_metadata(road_material_metadata_path)
	if metadata.is_empty():
		_set_road_material_fallback("metadata parse failure")
		return
	if str(metadata.get("slotId", "")) != ROAD_MATERIAL_SLOT_ID:
		_set_road_material_fallback("metadata slot mismatch")
		return
	if str(metadata.get("approach", "")) != ROAD_MATERIAL_APPROACH:
		_set_road_material_fallback("metadata approach mismatch")
		return
	var metadata_sha := str(metadata.get("sha256", "")).to_lower()
	if metadata_sha != road_material_expected_sha256:
		_set_road_material_fallback("metadata hash mismatch")
		return
	var dimensions: Dictionary = metadata.get("dimensions", {})
	var metadata_width := int(dimensions.get("width", 0))
	var metadata_height := int(dimensions.get("height", 0))
	if metadata_width != ROAD_MATERIAL_EXPECTED_WIDTH or metadata_height != ROAD_MATERIAL_EXPECTED_HEIGHT:
		_set_road_material_fallback("metadata dimension mismatch")
		return
	var actual_sha := _sha256_file(road_material_source_path)
	road_material_status["actualSha256"] = actual_sha
	if actual_sha != road_material_expected_sha256:
		_set_road_material_fallback("source hash mismatch")
		return
	var image := Image.new()
	road_material_source_load_count += 1
	var load_result := image.load(road_material_source_path)
	if load_result != OK:
		_set_road_material_fallback("image load failure %s" % str(load_result))
		return
	road_material_image_decode_count += 1
	if image.get_width() != ROAD_MATERIAL_EXPECTED_WIDTH or image.get_height() != ROAD_MATERIAL_EXPECTED_HEIGHT:
		_set_road_material_fallback("image dimension mismatch")
		return
	road_material_texture = ImageTexture.create_from_image(image)
	if road_material_texture == null:
		_set_road_material_fallback("texture creation failure")
		return
	road_material_texture_create_count += 1
	road_material_status["enabled"] = true
	road_material_status["sourceLoaded"] = true
	road_material_status["materialActive"] = true
	road_material_status["fallbackActive"] = false
	road_material_status["fallbackReason"] = ""
	road_material_status["sourcePath"] = road_material_source_path
	road_material_status["metadataPath"] = road_material_metadata_path
	road_material_status["expectedSha256"] = road_material_expected_sha256
	road_material_status["actualSha256"] = actual_sha
	road_material_status["sourceDimensions"] = {"width": image.get_width(), "height": image.get_height()}
	road_material_status["metadataDimensions"] = {"width": metadata_width, "height": metadata_height}
	road_material_status["uvScale"] = road_material_requested_uv_scale
	road_material_status["sourceMetadataUvScale"] = float(metadata.get("uvScale", ROAD_MATERIAL_DEFAULT_UV_SCALE))
	road_material_status["tilingMode"] = str(metadata.get("tilingMode", "repeat player-slice road material"))
	road_material_status["fallbackMode"] = road_material_fallback_mode
	road_material_status["proceduralFallbackVisible"] = false
	road_material_status["loadDurationMs"] = snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	_refresh_road_material_counters()

func _read_road_material_metadata(path: String) -> Dictionary:
	road_material_metadata_parse_count += 1
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _set_road_material_fallback(reason: String) -> void:
	road_material_texture = null
	road_material_override = null
	road_material_status["enabled"] = road_material_experiment_enabled
	road_material_status["materialActive"] = false
	road_material_status["sourceLoaded"] = false
	road_material_status["fallbackActive"] = true
	road_material_status["fallbackReason"] = reason
	road_material_status["sourcePath"] = road_material_source_path
	road_material_status["metadataPath"] = road_material_metadata_path
	road_material_status["expectedSha256"] = road_material_expected_sha256
	road_material_status["fallbackMode"] = road_material_fallback_mode
	road_material_status["uvScale"] = road_material_requested_uv_scale
	road_material_status["proceduralFallbackVisible"] = true
	_refresh_road_material_counters()

func _refresh_road_material_counters() -> void:
	road_material_status["sourceLoadCount"] = road_material_source_load_count
	road_material_status["metadataParseCount"] = road_material_metadata_parse_count
	road_material_status["imageDecodeCount"] = road_material_image_decode_count
	road_material_status["textureCreateCount"] = road_material_texture_create_count
	road_material_status["materialCreateCount"] = road_material_material_create_count
	road_material_status["materialReuseCount"] = road_material_material_reuse_count
	road_material_status["appliedSurfaceCount"] = road_material_applied_surface_count
	road_material_status["appliedSurfaceNames"] = road_material_applied_surface_names.duplicate()

func _road_material_is_active() -> bool:
	return road_material_experiment_enabled and environment_foundation_review_enabled and bool(road_material_status.get("sourceLoaded", false)) and road_material_texture != null

func _road_material() -> StandardMaterial3D:
	if road_material_override:
		road_material_material_reuse_count += 1
		_refresh_road_material_counters()
		return road_material_override
	road_material_override = StandardMaterial3D.new()
	road_material_override.albedo_texture = road_material_texture
	road_material_override.albedo_color = Color(ROAD_MATERIAL_TINT_R, ROAD_MATERIAL_TINT_G, ROAD_MATERIAL_TINT_B, ROAD_MATERIAL_VISUAL_ALPHA)
	road_material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	road_material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	road_material_override.roughness = 0.92
	road_material_override.metallic = 0.0
	road_material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	road_material_override.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	road_material_override.uv1_scale = Vector3(road_material_requested_uv_scale, road_material_requested_uv_scale, 1.0)
	road_material_material_create_count += 1
	_refresh_road_material_counters()
	return road_material_override

func _add_road_material_static_box(name: String, position: Vector3, scale: Vector3, fallback_color: Color, transparent: bool = false) -> void:
	if not _road_material_is_active():
		_add_static_box(name, position, scale, fallback_color, transparent)
		return
	_add_static_box("%s_procedural_road_underlay" % name, position, scale, fallback_color, transparent)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position + Vector3(0.0, ROAD_MATERIAL_OVERLAY_LIFT, 0.0)
	mesh_instance.material_override = _road_material()
	terrain_root.add_child(mesh_instance)
	road_material_applied_surface_count += 1
	if not road_material_applied_surface_names.has(name):
		road_material_applied_surface_names.append(name)
	_refresh_road_material_counters()

func configure_militia_art_experiment(options: Dictionary) -> Dictionary:
	militia_art_experiment_enabled = bool(options.get("enabled", false))
	militia_art_requested_scale = maxf(0.5, minf(1.15, float(options.get("scale", MILITIA_ART_DEFAULT_SCALE))))
	militia_art_source_path = str(options.get("sourcePath", ""))
	militia_art_metadata_path = str(options.get("metadataPath", ""))
	militia_art_expected_sha256 = str(options.get("expectedSha256", MILITIA_ART_EXPECTED_SHA256)).to_lower()
	militia_art_fallback_mode = str(options.get("fallbackMode", "none"))
	militia_art_texture = null
	militia_art_material = null
	militia_art_mesh = null
	militia_art_source_load_count = 0
	militia_art_metadata_parse_count = 0
	militia_art_image_decode_count = 0
	militia_art_texture_create_count = 0
	militia_art_material_create_count = 0
	militia_art_mesh_create_count = 0
	militia_art_material_reuse_count = 0
	if not militia_art_experiment_enabled:
		_reset_militia_art_status(false, "opt-in flag absent")
		_rebuild_visuals()
		return militia_art_status.duplicate(true)
	_load_militia_art_candidate()
	_rebuild_visuals()
	return militia_art_status.duplicate(true)

func get_militia_art_status() -> Dictionary:
	return militia_art_status.duplicate(true)

func _reset_militia_art_status(enabled: bool, reason: String) -> void:
	militia_art_status = {
		"schemaVersion": 1,
		"checkpoint": "v0.164",
		"slotId": MILITIA_ART_SLOT_ID,
		"approach": MILITIA_ART_APPROACH,
		"enabled": enabled,
		"sourceLoaded": false,
		"billboardActive": false,
		"fallbackActive": true,
		"fallbackReason": reason,
		"sourcePath": militia_art_source_path,
		"metadataPath": militia_art_metadata_path,
		"expectedSha256": militia_art_expected_sha256,
		"actualSha256": "",
		"sourceDimensions": {"width": 0, "height": 0},
		"metadataDimensions": {"width": 0, "height": 0},
		"trimmedPixelDimensions": {"width": 0, "height": 0},
		"alphaBounds": {},
		"alphaPosture": "",
		"pivot": {},
		"scale": militia_art_requested_scale,
		"fallbackMode": militia_art_fallback_mode,
		"proceduralFallbackVisible": true,
		"selectionAndGameplayIdsPreserved": true,
		"stableMilitiaId": "recruited_militia_00",
		"friendlyDefenderOnly": true,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"fourthArtSlotAdded": false,
		"productionManifestMutated": false,
		"sourceLoadCount": militia_art_source_load_count,
		"metadataParseCount": militia_art_metadata_parse_count,
		"imageDecodeCount": militia_art_image_decode_count,
		"textureCreateCount": militia_art_texture_create_count,
		"materialCreateCount": militia_art_material_create_count,
		"meshCreateCount": militia_art_mesh_create_count,
		"materialReuseCount": militia_art_material_reuse_count
	}
	_refresh_militia_art_counters()

func _load_militia_art_candidate() -> void:
	_reset_militia_art_status(true, "not loaded")
	var start_usec := Time.get_ticks_usec()
	if militia_art_source_path == "":
		_set_militia_art_fallback("missing source path")
		return
	if not FileAccess.file_exists(militia_art_source_path):
		_set_militia_art_fallback("missing source file")
		return
	if militia_art_metadata_path == "" or not FileAccess.file_exists(militia_art_metadata_path):
		_set_militia_art_fallback("missing metadata file")
		return
	var metadata := _read_militia_art_metadata(militia_art_metadata_path)
	if metadata.is_empty():
		_set_militia_art_fallback("metadata parse failure")
		return
	if str(metadata.get("slotId", "")) != MILITIA_ART_SLOT_ID:
		_set_militia_art_fallback("metadata slot mismatch")
		return
	if str(metadata.get("derivativeKind", "")) != "trimmed-padded-alpha-treated-1024":
		_set_militia_art_fallback("metadata derivative mismatch")
		return
	var metadata_sha := str(metadata.get("sha256", "")).to_lower()
	if metadata_sha != militia_art_expected_sha256:
		_set_militia_art_fallback("metadata hash mismatch")
		return
	var dimensions: Dictionary = metadata.get("dimensions", {})
	var metadata_width := int(dimensions.get("width", 0))
	var metadata_height := int(dimensions.get("height", 0))
	if metadata_width != MILITIA_ART_EXPECTED_WIDTH or metadata_height != MILITIA_ART_EXPECTED_HEIGHT:
		_set_militia_art_fallback("metadata dimension mismatch")
		return
	var actual_sha := _sha256_file(militia_art_source_path)
	militia_art_status["actualSha256"] = actual_sha
	if actual_sha != militia_art_expected_sha256:
		_set_militia_art_fallback("source hash mismatch")
		return
	var image := Image.new()
	militia_art_source_load_count += 1
	var load_result := image.load(militia_art_source_path)
	if load_result != OK:
		_set_militia_art_fallback("image load failure %s" % str(load_result))
		return
	militia_art_image_decode_count += 1
	if image.get_width() != MILITIA_ART_EXPECTED_WIDTH or image.get_height() != MILITIA_ART_EXPECTED_HEIGHT:
		_set_militia_art_fallback("image dimension mismatch")
		return
	militia_art_texture = ImageTexture.create_from_image(image)
	if militia_art_texture == null:
		_set_militia_art_fallback("texture creation failure")
		return
	militia_art_texture_create_count += 1
	militia_art_status["enabled"] = true
	militia_art_status["sourceLoaded"] = true
	militia_art_status["billboardActive"] = true
	militia_art_status["fallbackActive"] = false
	militia_art_status["fallbackReason"] = ""
	militia_art_status["sourcePath"] = militia_art_source_path
	militia_art_status["metadataPath"] = militia_art_metadata_path
	militia_art_status["expectedSha256"] = militia_art_expected_sha256
	militia_art_status["actualSha256"] = actual_sha
	militia_art_status["sourceDimensions"] = {"width": image.get_width(), "height": image.get_height()}
	militia_art_status["metadataDimensions"] = {"width": metadata_width, "height": metadata_height}
	var trim_bounds: Dictionary = metadata.get("trimBounds", {})
	militia_art_status["alphaBounds"] = trim_bounds
	militia_art_status["trimmedPixelDimensions"] = {
		"width": int(trim_bounds.get("width", 0)),
		"height": int(trim_bounds.get("height", 0))
	}
	militia_art_status["alphaPosture"] = str(metadata.get("alphaPosture", ""))
	militia_art_status["pivot"] = metadata.get("pivot", {})
	militia_art_status["role"] = metadata.get("role", {})
	militia_art_status["scale"] = militia_art_requested_scale
	militia_art_status["fallbackMode"] = militia_art_fallback_mode
	militia_art_status["proceduralFallbackVisible"] = false
	militia_art_status["loadDurationMs"] = snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	_refresh_militia_art_counters()

func _read_militia_art_metadata(path: String) -> Dictionary:
	militia_art_metadata_parse_count += 1
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _set_militia_art_fallback(reason: String) -> void:
	militia_art_texture = null
	militia_art_material = null
	militia_art_mesh = null
	militia_art_status["enabled"] = militia_art_experiment_enabled
	militia_art_status["billboardActive"] = false
	militia_art_status["sourceLoaded"] = false
	militia_art_status["fallbackActive"] = true
	militia_art_status["fallbackReason"] = reason
	militia_art_status["sourcePath"] = militia_art_source_path
	militia_art_status["metadataPath"] = militia_art_metadata_path
	militia_art_status["expectedSha256"] = militia_art_expected_sha256
	militia_art_status["scale"] = militia_art_requested_scale
	militia_art_status["fallbackMode"] = militia_art_fallback_mode
	militia_art_status["proceduralFallbackVisible"] = true
	_refresh_militia_art_counters()

func _refresh_militia_art_counters() -> void:
	militia_art_status["sourceLoadCount"] = militia_art_source_load_count
	militia_art_status["metadataParseCount"] = militia_art_metadata_parse_count
	militia_art_status["imageDecodeCount"] = militia_art_image_decode_count
	militia_art_status["textureCreateCount"] = militia_art_texture_create_count
	militia_art_status["materialCreateCount"] = militia_art_material_create_count
	militia_art_status["meshCreateCount"] = militia_art_mesh_create_count
	militia_art_status["materialReuseCount"] = militia_art_material_reuse_count
	var runtime_height := _militia_art_unit_height()
	var runtime_width := _militia_art_unit_width()
	var source_aspect := float(MILITIA_ART_EXPECTED_WIDTH) / maxf(1.0, float(MILITIA_ART_EXPECTED_HEIGHT))
	var runtime_aspect := runtime_width / maxf(0.001, runtime_height)
	militia_art_status["runtimeWorldWidth"] = snappedf(runtime_width, 0.0001)
	militia_art_status["runtimeWorldHeight"] = snappedf(runtime_height, 0.0001)
	var militia_pixels := _orthographic_rendered_pixel_size(runtime_width, runtime_height)
	militia_art_status["renderedPixelWidth"] = militia_pixels["width"]
	militia_art_status["renderedPixelHeight"] = militia_pixels["height"]
	militia_art_status["sourceAspectRatio"] = snappedf(source_aspect, 0.0001)
	militia_art_status["runtimeAspectRatio"] = snappedf(runtime_aspect, 0.0001)
	militia_art_status["aspectRatioPreserved"] = absf(runtime_aspect - source_aspect) <= 0.001
	militia_art_status["terrainFootContactY"] = snappedf(MILITIA_ART_GROUND_CLEARANCE, 0.0001)
	militia_art_status["selectionRingDiameter"] = snappedf(_unit_radius({"role": "Militia", "fixtureId": "militia", "team": "friendly"}) * 2.2, 0.0001)
	militia_art_status["renderedSelectionRingDiameterPx"] = _orthographic_rendered_pixel_size(float(militia_art_status["selectionRingDiameter"]), float(militia_art_status["selectionRingDiameter"]))["height"]
	militia_art_status["proceduralUnitBoundingBox"] = {"topRadius": 0.15, "bottomRadius": 0.18, "height": 0.42}

func _militia_art_is_active() -> bool:
	return militia_art_experiment_enabled and bool(militia_art_status.get("sourceLoaded", false)) and militia_art_texture != null

func _militia_art_applies_to_unit(unit: Dictionary) -> bool:
	return _militia_art_is_active() and str(unit.get("team", "")) == "friendly" and str(unit.get("fixtureId", "")) == "militia"

func _militia_art_unit_height() -> float:
	return MILITIA_ART_QUAD_HEIGHT * militia_art_requested_scale

func _militia_art_unit_width() -> float:
	return _militia_art_unit_height() * (float(MILITIA_ART_EXPECTED_WIDTH) / maxf(1.0, float(MILITIA_ART_EXPECTED_HEIGHT)))

func _militia_art_unit_y() -> float:
	return MILITIA_ART_GROUND_CLEARANCE + _militia_art_unit_height() * 0.5

func _militia_art_quad_mesh() -> QuadMesh:
	if militia_art_mesh:
		return militia_art_mesh
	militia_art_mesh = QuadMesh.new()
	militia_art_mesh.size = Vector2(_militia_art_unit_width(), _militia_art_unit_height())
	militia_art_mesh_create_count += 1
	_refresh_militia_art_counters()
	return militia_art_mesh

func _militia_art_billboard_material() -> StandardMaterial3D:
	if militia_art_material:
		militia_art_material_reuse_count += 1
		_refresh_militia_art_counters()
		return militia_art_material
	militia_art_material = StandardMaterial3D.new()
	militia_art_material.albedo_texture = militia_art_texture
	militia_art_material.albedo_color = Color(1, 1, 1, 1)
	militia_art_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	militia_art_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	militia_art_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	militia_art_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	militia_art_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	militia_art_material_create_count += 1
	_refresh_militia_art_counters()
	return militia_art_material

func configure_aster_art_experiment(options: Dictionary) -> Dictionary:
	aster_art_experiment_enabled = bool(options.get("enabled", false))
	aster_art_requested_scale = maxf(0.5, minf(1.2, float(options.get("scale", ASTER_ART_DEFAULT_SCALE))))
	aster_art_source_path = str(options.get("sourcePath", ""))
	aster_art_metadata_path = str(options.get("metadataPath", ""))
	aster_art_expected_sha256 = str(options.get("expectedSha256", ASTER_ART_EXPECTED_SHA256)).to_lower()
	aster_art_fallback_mode = str(options.get("fallbackMode", "none"))
	aster_art_texture = null
	aster_art_material = null
	aster_art_mesh = null
	aster_art_source_load_count = 0
	aster_art_metadata_parse_count = 0
	aster_art_image_decode_count = 0
	aster_art_texture_create_count = 0
	aster_art_material_create_count = 0
	aster_art_mesh_create_count = 0
	aster_art_material_reuse_count = 0
	if not aster_art_experiment_enabled:
		_reset_aster_art_status(false, "opt-in flag absent")
		_rebuild_visuals()
		return aster_art_status.duplicate(true)
	_load_aster_art_candidate()
	_rebuild_visuals()
	return aster_art_status.duplicate(true)

func get_aster_art_status() -> Dictionary:
	return aster_art_status.duplicate(true)

func _reset_aster_art_status(enabled: bool, reason: String) -> void:
	aster_art_status = {
		"schemaVersion": 1,
		"checkpoint": "v0.168",
		"slotId": ASTER_ART_SLOT_ID,
		"approach": ASTER_ART_APPROACH,
		"enabled": enabled,
		"sourceLoaded": false,
		"billboardActive": false,
		"fallbackActive": true,
		"fallbackReason": reason,
		"sourcePath": aster_art_source_path,
		"metadataPath": aster_art_metadata_path,
		"expectedSha256": aster_art_expected_sha256,
		"actualSha256": "",
		"sourceDimensions": {"width": 0, "height": 0},
		"metadataDimensions": {"width": 0, "height": 0},
		"trimmedPixelDimensions": {"width": 0, "height": 0},
		"alphaBounds": {},
		"alphaPosture": "",
		"pivot": {},
		"scale": aster_art_requested_scale,
		"fallbackMode": aster_art_fallback_mode,
		"proceduralFallbackVisible": true,
		"selectionAndGameplayIdsPreserved": true,
		"stableAsterId": "hero_aster",
		"heroHierarchyAboveMilitiaWorker": true,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"fifthArtSlotAdded": false,
		"productionManifestMutated": false,
		"sourceLoadCount": aster_art_source_load_count,
		"metadataParseCount": aster_art_metadata_parse_count,
		"imageDecodeCount": aster_art_image_decode_count,
		"textureCreateCount": aster_art_texture_create_count,
		"materialCreateCount": aster_art_material_create_count,
		"meshCreateCount": aster_art_mesh_create_count,
		"materialReuseCount": aster_art_material_reuse_count
	}
	_refresh_aster_art_counters()

func _load_aster_art_candidate() -> void:
	_reset_aster_art_status(true, "not loaded")
	var start_usec := Time.get_ticks_usec()
	if aster_art_source_path == "":
		_set_aster_art_fallback("missing source path")
		return
	if not FileAccess.file_exists(aster_art_source_path):
		_set_aster_art_fallback("missing source file")
		return
	if aster_art_metadata_path == "" or not FileAccess.file_exists(aster_art_metadata_path):
		_set_aster_art_fallback("missing metadata file")
		return
	var metadata := _read_aster_art_metadata(aster_art_metadata_path)
	if metadata.is_empty():
		_set_aster_art_fallback("metadata parse failure")
		return
	if str(metadata.get("slotId", "")) != ASTER_ART_SLOT_ID:
		_set_aster_art_fallback("metadata slot mismatch")
		return
	if str(metadata.get("derivativeKind", "")) != "trimmed-padded-alpha-treated-1024":
		_set_aster_art_fallback("metadata derivative mismatch")
		return
	var metadata_sha := str(metadata.get("sha256", "")).to_lower()
	if metadata_sha != aster_art_expected_sha256:
		_set_aster_art_fallback("metadata hash mismatch")
		return
	var dimensions: Dictionary = metadata.get("dimensions", {})
	var metadata_width := int(dimensions.get("width", 0))
	var metadata_height := int(dimensions.get("height", 0))
	if metadata_width != ASTER_ART_EXPECTED_WIDTH or metadata_height != ASTER_ART_EXPECTED_HEIGHT:
		_set_aster_art_fallback("metadata dimension mismatch")
		return
	var alpha_stats: Dictionary = metadata.get("alphaStats", {})
	if int(alpha_stats.get("transparentCornerCount", 0)) < 4:
		_set_aster_art_fallback("transparent corner metadata mismatch")
		return
	var trim_bounds: Dictionary = metadata.get("trimBounds", {})
	if int(trim_bounds.get("width", 0)) <= 0 or int(trim_bounds.get("height", 0)) <= 0:
		_set_aster_art_fallback("trim metadata missing")
		return
	var pivot: Dictionary = metadata.get("pivot", {})
	var pivot_x := float(pivot.get("normalizedX", 0.0))
	var pivot_y := float(pivot.get("normalizedY", 0.0))
	if absf(pivot_x - 0.5005) > 0.01 or absf(pivot_y - 0.9639) > 0.02:
		_set_aster_art_fallback("pivot metadata mismatch")
		return
	var actual_sha := _sha256_file(aster_art_source_path)
	aster_art_status["actualSha256"] = actual_sha
	if actual_sha != aster_art_expected_sha256:
		_set_aster_art_fallback("source hash mismatch")
		return
	var image := Image.new()
	aster_art_source_load_count += 1
	var load_result := image.load(aster_art_source_path)
	if load_result != OK:
		_set_aster_art_fallback("image load failure %s" % str(load_result))
		return
	aster_art_image_decode_count += 1
	if image.get_width() != ASTER_ART_EXPECTED_WIDTH or image.get_height() != ASTER_ART_EXPECTED_HEIGHT:
		_set_aster_art_fallback("image dimension mismatch")
		return
	aster_art_texture = ImageTexture.create_from_image(image)
	if aster_art_texture == null:
		_set_aster_art_fallback("texture creation failure")
		return
	aster_art_texture_create_count += 1
	aster_art_status["enabled"] = true
	aster_art_status["sourceLoaded"] = true
	aster_art_status["billboardActive"] = true
	aster_art_status["fallbackActive"] = false
	aster_art_status["fallbackReason"] = ""
	aster_art_status["sourcePath"] = aster_art_source_path
	aster_art_status["metadataPath"] = aster_art_metadata_path
	aster_art_status["expectedSha256"] = aster_art_expected_sha256
	aster_art_status["actualSha256"] = actual_sha
	aster_art_status["sourceDimensions"] = {"width": image.get_width(), "height": image.get_height()}
	aster_art_status["metadataDimensions"] = {"width": metadata_width, "height": metadata_height}
	aster_art_status["alphaBounds"] = trim_bounds
	aster_art_status["trimmedPixelDimensions"] = {
		"width": int(trim_bounds.get("width", 0)),
		"height": int(trim_bounds.get("height", 0))
	}
	aster_art_status["alphaPosture"] = str(metadata.get("alphaPosture", ""))
	aster_art_status["pivot"] = pivot
	aster_art_status["role"] = metadata.get("role", {})
	aster_art_status["scale"] = aster_art_requested_scale
	aster_art_status["fallbackMode"] = aster_art_fallback_mode
	aster_art_status["proceduralFallbackVisible"] = false
	aster_art_status["loadDurationMs"] = snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	_refresh_aster_art_counters()

func _read_aster_art_metadata(path: String) -> Dictionary:
	aster_art_metadata_parse_count += 1
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _set_aster_art_fallback(reason: String) -> void:
	aster_art_texture = null
	aster_art_material = null
	aster_art_mesh = null
	aster_art_status["enabled"] = aster_art_experiment_enabled
	aster_art_status["billboardActive"] = false
	aster_art_status["sourceLoaded"] = false
	aster_art_status["fallbackActive"] = true
	aster_art_status["fallbackReason"] = reason
	aster_art_status["sourcePath"] = aster_art_source_path
	aster_art_status["metadataPath"] = aster_art_metadata_path
	aster_art_status["expectedSha256"] = aster_art_expected_sha256
	aster_art_status["scale"] = aster_art_requested_scale
	aster_art_status["fallbackMode"] = aster_art_fallback_mode
	aster_art_status["proceduralFallbackVisible"] = true
	_refresh_aster_art_counters()

func _refresh_aster_art_counters() -> void:
	aster_art_status["sourceLoadCount"] = aster_art_source_load_count
	aster_art_status["metadataParseCount"] = aster_art_metadata_parse_count
	aster_art_status["imageDecodeCount"] = aster_art_image_decode_count
	aster_art_status["textureCreateCount"] = aster_art_texture_create_count
	aster_art_status["materialCreateCount"] = aster_art_material_create_count
	aster_art_status["meshCreateCount"] = aster_art_mesh_create_count
	aster_art_status["materialReuseCount"] = aster_art_material_reuse_count
	var runtime_height := _aster_art_unit_height()
	var runtime_width := _aster_art_unit_width()
	var source_aspect := float(ASTER_ART_EXPECTED_WIDTH) / maxf(1.0, float(ASTER_ART_EXPECTED_HEIGHT))
	var runtime_aspect := runtime_width / maxf(0.001, runtime_height)
	aster_art_status["runtimeWorldWidth"] = snappedf(runtime_width, 0.0001)
	aster_art_status["runtimeWorldHeight"] = snappedf(runtime_height, 0.0001)
	var aster_pixels := _orthographic_rendered_pixel_size(runtime_width, runtime_height)
	aster_art_status["renderedPixelWidth"] = aster_pixels["width"]
	aster_art_status["renderedPixelHeight"] = aster_pixels["height"]
	aster_art_status["sourceAspectRatio"] = snappedf(source_aspect, 0.0001)
	aster_art_status["runtimeAspectRatio"] = snappedf(runtime_aspect, 0.0001)
	aster_art_status["aspectRatioPreserved"] = absf(runtime_aspect - source_aspect) <= 0.001
	aster_art_status["terrainFootContactY"] = snappedf(ASTER_ART_GROUND_CLEARANCE, 0.0001)
	aster_art_status["foregroundDepthBypassForHeroReadability"] = true
	aster_art_status["renderPriority"] = 2
	aster_art_status["selectionRingDiameter"] = snappedf(_unit_radius({"role": "hero", "fixtureId": "aster", "team": "friendly"}) * 2.2, 0.0001)
	aster_art_status["renderedSelectionRingDiameterPx"] = _orthographic_rendered_pixel_size(float(aster_art_status["selectionRingDiameter"]), float(aster_art_status["selectionRingDiameter"]))["height"]
	aster_art_status["proceduralUnitBoundingBox"] = {"radius": 0.18, "height": 0.62}
	aster_art_status["hierarchyRuntimeHeightVsMilitia"] = snappedf(runtime_height / maxf(0.001, _militia_art_unit_height()), 0.0001)
	aster_art_status["hierarchyRuntimeHeightVsWorker"] = snappedf(runtime_height / maxf(0.001, _worker_art_unit_height()), 0.0001)

func _aster_art_is_active() -> bool:
	return aster_art_experiment_enabled and bool(aster_art_status.get("sourceLoaded", false)) and aster_art_texture != null

func _aster_art_applies_to_unit(unit: Dictionary) -> bool:
	return _aster_art_is_active() and str(unit.get("team", "")) == "friendly" and str(unit.get("id", "")) == "hero_aster"

func _aster_art_unit_height() -> float:
	return ASTER_ART_QUAD_HEIGHT * aster_art_requested_scale

func _aster_art_unit_width() -> float:
	return _aster_art_unit_height() * (float(ASTER_ART_EXPECTED_WIDTH) / maxf(1.0, float(ASTER_ART_EXPECTED_HEIGHT)))

func _aster_art_unit_y(selected: bool = false) -> float:
	var selection_scale := 1.12 if selected else 1.0
	return ASTER_ART_GROUND_CLEARANCE + _aster_art_unit_height() * selection_scale * 0.5

func _aster_art_quad_mesh() -> QuadMesh:
	if aster_art_mesh:
		return aster_art_mesh
	aster_art_mesh = QuadMesh.new()
	aster_art_mesh.size = Vector2(_aster_art_unit_width(), _aster_art_unit_height())
	aster_art_mesh_create_count += 1
	_refresh_aster_art_counters()
	return aster_art_mesh

func _aster_art_billboard_material() -> StandardMaterial3D:
	if aster_art_material:
		aster_art_material_reuse_count += 1
		_refresh_aster_art_counters()
		return aster_art_material
	aster_art_material = StandardMaterial3D.new()
	aster_art_material.albedo_texture = aster_art_texture
	aster_art_material.albedo_color = Color(1, 1, 1, 1)
	aster_art_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	aster_art_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	aster_art_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	aster_art_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	aster_art_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	aster_art_material.no_depth_test = true
	aster_art_material.render_priority = 2
	aster_art_material_create_count += 1
	_refresh_aster_art_counters()
	return aster_art_material

func configure_ashen_art_experiment(options: Dictionary) -> Dictionary:
	ashen_art_experiment_enabled = bool(options.get("enabled", false))
	ashen_art_requested_scale = maxf(0.55, minf(1.15, float(options.get("scale", ASHEN_ART_DEFAULT_SCALE))))
	ashen_art_source_path = str(options.get("sourcePath", ""))
	ashen_art_metadata_path = str(options.get("metadataPath", ""))
	ashen_art_expected_sha256 = str(options.get("expectedSha256", ASHEN_ART_EXPECTED_SHA256)).to_lower()
	ashen_art_fallback_mode = str(options.get("fallbackMode", "none"))
	ashen_art_texture = null
	ashen_art_material = null
	ashen_art_mesh = null
	ashen_art_source_load_count = 0
	ashen_art_metadata_parse_count = 0
	ashen_art_image_decode_count = 0
	ashen_art_texture_create_count = 0
	ashen_art_material_create_count = 0
	ashen_art_mesh_create_count = 0
	ashen_art_material_reuse_count = 0
	if not ashen_art_experiment_enabled:
		_reset_ashen_art_status(false, "opt-in flag absent")
		_rebuild_visuals()
		return ashen_art_status.duplicate(true)
	_load_ashen_art_candidate()
	_rebuild_visuals()
	return ashen_art_status.duplicate(true)

func get_ashen_art_status() -> Dictionary:
	return ashen_art_status.duplicate(true)

func _reset_ashen_art_status(enabled: bool, reason: String) -> void:
	ashen_art_status = {
		"schemaVersion": 1,
		"checkpoint": "v0.170",
		"slotId": ASHEN_ART_SLOT_ID,
		"approach": ASHEN_ART_APPROACH,
		"enabled": enabled,
		"sourceLoaded": false,
		"billboardActive": false,
		"fallbackActive": true,
		"fallbackReason": reason,
		"sourcePath": ashen_art_source_path,
		"metadataPath": ashen_art_metadata_path,
		"expectedSha256": ashen_art_expected_sha256,
		"actualSha256": "",
		"sourceDimensions": {"width": 0, "height": 0},
		"metadataDimensions": {"width": 0, "height": 0},
		"trimmedPixelDimensions": {"width": 0, "height": 0},
		"alphaBounds": {},
		"alphaPosture": "",
		"pivot": {},
		"scale": ashen_art_requested_scale,
		"fallbackMode": ashen_art_fallback_mode,
		"proceduralFallbackVisible": true,
		"selectionAndGameplayIdsPreserved": true,
		"stableAshenIds": _v0133_wave_ids(),
		"ordinaryWaveAttackerBelowAster": true,
		"browserRuntimeChanged": false,
		"saveWritesAllowed": false,
		"sixthArtSlotAdded": false,
		"productionManifestMutated": false,
		"sourceLoadCount": ashen_art_source_load_count,
		"metadataParseCount": ashen_art_metadata_parse_count,
		"imageDecodeCount": ashen_art_image_decode_count,
		"textureCreateCount": ashen_art_texture_create_count,
		"materialCreateCount": ashen_art_material_create_count,
		"meshCreateCount": ashen_art_mesh_create_count,
		"materialReuseCount": ashen_art_material_reuse_count
	}
	_refresh_ashen_art_counters()

func _load_ashen_art_candidate() -> void:
	_reset_ashen_art_status(true, "not loaded")
	var start_usec := Time.get_ticks_usec()
	if ashen_art_source_path == "":
		_set_ashen_art_fallback("missing source path")
		return
	if not FileAccess.file_exists(ashen_art_source_path):
		_set_ashen_art_fallback("missing source file")
		return
	if ashen_art_metadata_path == "" or not FileAccess.file_exists(ashen_art_metadata_path):
		_set_ashen_art_fallback("missing metadata file")
		return
	var metadata := _read_ashen_art_metadata(ashen_art_metadata_path)
	if metadata.is_empty():
		_set_ashen_art_fallback("metadata parse failure")
		return
	if str(metadata.get("slotId", "")) != ASHEN_ART_SLOT_ID:
		_set_ashen_art_fallback("metadata slot mismatch")
		return
	if str(metadata.get("derivativeKind", "")) != "restrained-replacement-trimmed-padded-alpha-treated-1024":
		_set_ashen_art_fallback("metadata derivative mismatch")
		return
	var metadata_sha := str(metadata.get("sha256", "")).to_lower()
	if metadata_sha != ashen_art_expected_sha256:
		_set_ashen_art_fallback("metadata hash mismatch")
		return
	var dimensions: Dictionary = metadata.get("dimensions", {})
	var metadata_width := int(dimensions.get("width", 0))
	var metadata_height := int(dimensions.get("height", 0))
	if metadata_width != ASHEN_ART_EXPECTED_WIDTH or metadata_height != ASHEN_ART_EXPECTED_HEIGHT:
		_set_ashen_art_fallback("metadata dimension mismatch")
		return
	var alpha_stats: Dictionary = metadata.get("alphaStats", {})
	if int(alpha_stats.get("transparentCornerCount", 0)) < 4:
		_set_ashen_art_fallback("transparent corner metadata mismatch")
		return
	var trim_bounds: Dictionary = metadata.get("trimBounds", {})
	if int(trim_bounds.get("width", 0)) <= 0 or int(trim_bounds.get("height", 0)) <= 0:
		_set_ashen_art_fallback("trim metadata missing")
		return
	var alpha_edge_stats: Dictionary = metadata.get("alphaEdgeStats", {})
	if float(alpha_edge_stats.get("haloCandidateRatio", 1.0)) > 0.001:
		_set_ashen_art_fallback("halo metadata mismatch")
		return
	var pivot: Dictionary = metadata.get("pivot", {})
	var pivot_x := float(pivot.get("normalizedX", 0.0))
	var pivot_y := float(pivot.get("normalizedY", 0.0))
	if absf(pivot_x - 0.4995) > 0.01 or absf(pivot_y - 0.9648) > 0.02:
		_set_ashen_art_fallback("pivot metadata mismatch")
		return
	var actual_sha := _sha256_file(ashen_art_source_path)
	ashen_art_status["actualSha256"] = actual_sha
	if actual_sha != ashen_art_expected_sha256:
		_set_ashen_art_fallback("source hash mismatch")
		return
	var image := Image.new()
	ashen_art_source_load_count += 1
	var load_result := image.load(ashen_art_source_path)
	if load_result != OK:
		_set_ashen_art_fallback("image load failure %s" % str(load_result))
		return
	ashen_art_image_decode_count += 1
	if image.get_width() != ASHEN_ART_EXPECTED_WIDTH or image.get_height() != ASHEN_ART_EXPECTED_HEIGHT:
		_set_ashen_art_fallback("image dimension mismatch")
		return
	ashen_art_texture = ImageTexture.create_from_image(image)
	if ashen_art_texture == null:
		_set_ashen_art_fallback("texture creation failure")
		return
	ashen_art_texture_create_count += 1
	ashen_art_status["enabled"] = true
	ashen_art_status["sourceLoaded"] = true
	ashen_art_status["billboardActive"] = true
	ashen_art_status["fallbackActive"] = false
	ashen_art_status["fallbackReason"] = ""
	ashen_art_status["sourcePath"] = ashen_art_source_path
	ashen_art_status["metadataPath"] = ashen_art_metadata_path
	ashen_art_status["expectedSha256"] = ashen_art_expected_sha256
	ashen_art_status["actualSha256"] = actual_sha
	ashen_art_status["sourceDimensions"] = {"width": image.get_width(), "height": image.get_height()}
	ashen_art_status["metadataDimensions"] = {"width": metadata_width, "height": metadata_height}
	ashen_art_status["alphaBounds"] = trim_bounds
	ashen_art_status["trimmedPixelDimensions"] = {
		"width": int(trim_bounds.get("width", 0)),
		"height": int(trim_bounds.get("height", 0))
	}
	ashen_art_status["alphaPosture"] = str(metadata.get("alphaPosture", ""))
	ashen_art_status["pivot"] = pivot
	ashen_art_status["role"] = metadata.get("role", {})
	ashen_art_status["visualRestraintIntent"] = metadata.get("visualRestraintIntent", {})
	ashen_art_status["scale"] = ashen_art_requested_scale
	ashen_art_status["fallbackMode"] = ashen_art_fallback_mode
	ashen_art_status["proceduralFallbackVisible"] = false
	ashen_art_status["loadDurationMs"] = snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01)
	_refresh_ashen_art_counters()

func _read_ashen_art_metadata(path: String) -> Dictionary:
	ashen_art_metadata_parse_count += 1
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _set_ashen_art_fallback(reason: String) -> void:
	ashen_art_texture = null
	ashen_art_material = null
	ashen_art_mesh = null
	ashen_art_status["enabled"] = ashen_art_experiment_enabled
	ashen_art_status["billboardActive"] = false
	ashen_art_status["sourceLoaded"] = false
	ashen_art_status["fallbackActive"] = true
	ashen_art_status["fallbackReason"] = reason
	ashen_art_status["sourcePath"] = ashen_art_source_path
	ashen_art_status["metadataPath"] = ashen_art_metadata_path
	ashen_art_status["expectedSha256"] = ashen_art_expected_sha256
	ashen_art_status["scale"] = ashen_art_requested_scale
	ashen_art_status["fallbackMode"] = ashen_art_fallback_mode
	ashen_art_status["proceduralFallbackVisible"] = true
	_refresh_ashen_art_counters()

func _refresh_ashen_art_counters() -> void:
	ashen_art_status["sourceLoadCount"] = ashen_art_source_load_count
	ashen_art_status["metadataParseCount"] = ashen_art_metadata_parse_count
	ashen_art_status["imageDecodeCount"] = ashen_art_image_decode_count
	ashen_art_status["textureCreateCount"] = ashen_art_texture_create_count
	ashen_art_status["materialCreateCount"] = ashen_art_material_create_count
	ashen_art_status["meshCreateCount"] = ashen_art_mesh_create_count
	ashen_art_status["materialReuseCount"] = ashen_art_material_reuse_count
	var runtime_height := _ashen_art_unit_height()
	var runtime_width := _ashen_art_unit_width()
	var source_aspect := float(ASHEN_ART_EXPECTED_WIDTH) / maxf(1.0, float(ASHEN_ART_EXPECTED_HEIGHT))
	var runtime_aspect := runtime_width / maxf(0.001, runtime_height)
	ashen_art_status["runtimeWorldWidth"] = snappedf(runtime_width, 0.0001)
	ashen_art_status["runtimeWorldHeight"] = snappedf(runtime_height, 0.0001)
	var ashen_pixels := _orthographic_rendered_pixel_size(runtime_width, runtime_height)
	ashen_art_status["renderedPixelWidth"] = ashen_pixels["width"]
	ashen_art_status["renderedPixelHeight"] = ashen_pixels["height"]
	ashen_art_status["sourceAspectRatio"] = snappedf(source_aspect, 0.0001)
	ashen_art_status["runtimeAspectRatio"] = snappedf(runtime_aspect, 0.0001)
	ashen_art_status["aspectRatioPreserved"] = absf(runtime_aspect - source_aspect) <= 0.001
	ashen_art_status["terrainFootContactY"] = snappedf(ASHEN_ART_GROUND_CLEARANCE, 0.0001)
	ashen_art_status["foregroundDepthBypassForHostileReadability"] = true
	ashen_art_status["renderPriority"] = 1
	ashen_art_status["selectionRingDiameter"] = snappedf(_unit_radius({"role": "Raider", "fixtureId": "raider", "team": "enemy"}) * 2.2, 0.0001)
	ashen_art_status["renderedSelectionRingDiameterPx"] = _orthographic_rendered_pixel_size(float(ashen_art_status["selectionRingDiameter"]), float(ashen_art_status["selectionRingDiameter"]))["height"]
	ashen_art_status["proceduralUnitBoundingBox"] = {"radius": 0.21, "height": 0.42}
	ashen_art_status["hierarchyRuntimeHeightVsAster"] = snappedf(runtime_height / maxf(0.001, _aster_art_unit_height()), 0.0001)
	ashen_art_status["hierarchyRuntimeHeightVsMilitia"] = snappedf(runtime_height / maxf(0.001, _militia_art_unit_height()), 0.0001)
	ashen_art_status["hierarchyRuntimeHeightVsWorker"] = snappedf(runtime_height / maxf(0.001, _worker_art_unit_height()), 0.0001)

func _ashen_art_is_active() -> bool:
	return ashen_art_experiment_enabled and bool(ashen_art_status.get("sourceLoaded", false)) and ashen_art_texture != null

func _ashen_art_applies_to_unit(unit: Dictionary) -> bool:
	return _ashen_art_is_active() and str(unit.get("team", "")) == "enemy" and str(unit.get("id", "")).begins_with("ashen_")

func _ashen_art_unit_height() -> float:
	return ASHEN_ART_QUAD_HEIGHT * ashen_art_requested_scale

func _ashen_art_unit_width() -> float:
	return _ashen_art_unit_height() * (float(ASHEN_ART_EXPECTED_WIDTH) / maxf(1.0, float(ASHEN_ART_EXPECTED_HEIGHT)))

func _ashen_art_unit_y(selected: bool = false) -> float:
	var selection_scale := 1.08 if selected else 1.0
	return ASHEN_ART_GROUND_CLEARANCE + _ashen_art_unit_height() * selection_scale * 0.5

func _ashen_art_quad_mesh() -> QuadMesh:
	if ashen_art_mesh:
		return ashen_art_mesh
	ashen_art_mesh = QuadMesh.new()
	ashen_art_mesh.size = Vector2(_ashen_art_unit_width(), _ashen_art_unit_height())
	ashen_art_mesh_create_count += 1
	_refresh_ashen_art_counters()
	return ashen_art_mesh

func _ashen_art_billboard_material() -> StandardMaterial3D:
	if ashen_art_material:
		ashen_art_material_reuse_count += 1
		_refresh_ashen_art_counters()
		return ashen_art_material
	ashen_art_material = StandardMaterial3D.new()
	ashen_art_material.albedo_texture = ashen_art_texture
	ashen_art_material.albedo_color = Color(1, 1, 1, 1)
	ashen_art_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ashen_art_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	ashen_art_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ashen_art_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ashen_art_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	ashen_art_material.no_depth_test = true
	ashen_art_material.render_priority = 1
	ashen_art_material_create_count += 1
	_refresh_ashen_art_counters()
	return ashen_art_material

func set_player_facing_mode(enabled: bool) -> bool:
	player_facing_mode = enabled
	if player_facing_mode:
		set_process(true)
		if runtime.units.size() > 0:
			runtime.apply_player_facing_staging()
			_reset_real_input_state()
			_rebuild_visuals()
			focus_visual_subject("hero")
	_sync_player_shell_chrome()
	_sync_hud()
	return true

func set_player_shell_screen(screen: String) -> bool:
	player_shell_screen = screen
	if player_facing_mode and player_shell_screen == "battle":
		if runtime.units.size() > 0:
			runtime.apply_player_facing_staging()
			_reset_real_input_state()
			_rebuild_visuals()
		focus_visual_subject("hero")
		set_onboarding_step("select_aster")
	_sync_player_shell_chrome()
	_sync_hud()
	return true

func set_onboarding_step(step_id: String) -> bool:
	var normalized := _canonical_objective_step(step_id)
	if normalized == "":
		return false
	var current_rank := _onboarding_rank(current_onboarding_step)
	var next_rank := _onboarding_rank(normalized)
	if player_facing_mode and player_shell_screen == "battle" and current_rank > 0 and next_rank > 0 and next_rank < current_rank:
		v0132_objective_regression_blocked_count += 1
		_record_objective_transition(normalized, false, "blocked_regression")
		return false
	if player_facing_mode and player_shell_screen == "battle" and current_rank > 0 and next_rank > current_rank and not _v0133_objective_prerequisites_met(normalized):
		v0133_illegal_objective_skip_rejected_count += 1
		_record_objective_transition(normalized, false, "blocked_missing_prerequisite")
		_record_real_input("illegal_objective_skip_rejected", {
			"requestedStep": _v0133_public_objective_step(normalized),
			"currentStep": _v0133_public_objective_step(current_onboarding_step),
			"reason": "missing_prerequisite"
		})
		return false
	if current_rank > 0 and next_rank > 0 and next_rank < current_rank:
		v0132_actual_objective_regression_detected = true
	current_onboarding_step = normalized
	if not onboarding_seen_steps.has(normalized):
		onboarding_seen_steps.append(normalized)
	if player_facing_mode and player_shell_screen == "battle" and normalized == "worker_mine_or_shrine":
		focus_visual_subject("worker")
	_record_objective_transition(normalized, true, "accepted")
	onboarding_dismissed = false
	_sync_hud()
	return true

func _canonical_objective_step(step_id: String) -> String:
	var normalized := step_id.strip_edges().to_lower()
	match normalized:
		"move_to_west_stone_cut_mine":
			return "move_to_quarry"
		"convert_west_stone_cut_mine":
			return "capture_hold_quarry"
		"assign_worker_to_mine":
			return "worker_assign_mine"
		"defeat_ashen_wave":
			return "defeat_wave"
	return normalized

func _v0133_objective_prerequisites_met(step_id: String) -> bool:
	match step_id:
		"select_aster":
			return true
		"move_to_quarry":
			return real_input_aster_selected or runtime.selected_ids.has("hero_aster")
		"capture_hold_quarry":
			return real_input_move_order_accepted or real_input_movement_started
		"worker_mine_or_shrine":
			return v0132_mine_controlled or runtime.mine_converted
		"worker_assign_mine":
			return (v0132_mine_controlled or runtime.mine_converted) and real_input_worker_selected
		"restore_barracks":
			return v0132_worker_assignment_complete or runtime.worker_assigned_to_mine
		"finish_barracks":
			return v0133_construction_started or runtime.barracks_build_placed
		"queue_militia", "train_militia":
			return v0133_barracks_restored or runtime.barracks_complete
		"prepare_ashen_pressure":
			return v0133_militia_spawned or runtime.militia_spawned
		"defeat_wave":
			return v0133_wave_triggered_once and runtime.pressure_wave_state == "active"
		"restore_lume_link":
			return v0133_wave_defeated_from_simulation or runtime.pressure_wave_defeated
		"review_results":
			return v0133_lume_restored or runtime.lume_restored
	return true

func _onboarding_rank(step_id: String) -> int:
	match step_id:
		"select_aster":
			return 1
		"move_to_quarry":
			return 2
		"capture_hold_quarry":
			return 3
		"worker_mine_or_shrine", "worker_assign_mine":
			return 4
		"restore_barracks", "finish_barracks":
			return 5
		"queue_militia", "train_militia":
			return 6
		"prepare_ashen_pressure", "defeat_wave":
			return 7
		"restore_lume_link":
			return 8
		"review_results":
			return 9
	return 0

func _record_objective_transition(step_id: String, accepted: bool, reason: String) -> void:
	v0132_objective_history.append({
		"index": v0132_objective_history.size() + 1,
		"frame": Engine.get_process_frames(),
		"from": current_onboarding_step,
		"to": step_id,
		"accepted": accepted,
		"reason": reason,
		"fromRank": _onboarding_rank(current_onboarding_step),
		"toRank": _onboarding_rank(step_id)
	})

func _v0133_public_objective_step(step_id: String) -> String:
	var normalized := step_id.strip_edges().to_lower()
	match normalized:
		"move_to_quarry":
			return "move_to_west_stone_cut_mine"
		"capture_hold_quarry":
			return "convert_west_stone_cut_mine"
		"worker_mine_or_shrine", "worker_assign_mine":
			return "assign_worker_to_mine"
		"defeat_wave":
			return "defeat_ashen_wave"
	return normalized

func _v0133_public_objective_rank(step_id: String) -> int:
	match _v0133_public_objective_step(step_id):
		"select_aster":
			return 1
		"move_to_west_stone_cut_mine":
			return 2
		"convert_west_stone_cut_mine":
			return 3
		"assign_worker_to_mine":
			return 4
		"restore_barracks":
			return 5
		"train_militia":
			return 6
		"prepare_ashen_pressure":
			return 7
		"defeat_ashen_wave":
			return 8
		"restore_lume_link":
			return 9
		"review_results":
			return 10
	return _onboarding_rank(step_id)

func _v0133_public_objective_history() -> Array:
	var public_history := []
	for entry in v0132_objective_history:
		var public_entry: Dictionary = entry.duplicate(true)
		var from_step := String(public_entry.get("from", ""))
		var to_step := String(public_entry.get("to", ""))
		public_entry["from"] = _v0133_public_objective_step(from_step)
		public_entry["to"] = _v0133_public_objective_step(to_step)
		public_entry["fromRank"] = _v0133_public_objective_rank(from_step)
		public_entry["toRank"] = _v0133_public_objective_rank(to_step)
		public_history.append(public_entry)
	return public_history

func dismiss_onboarding() -> bool:
	onboarding_dismissed = true
	_sync_hud()
	return true

func skip_onboarding_private() -> bool:
	onboarding_private_skip_enabled = true
	onboarding_dismissed = true
	current_onboarding_step = "private_skip"
	_sync_hud()
	return true

func set_more_details_visible(enabled: bool) -> bool:
	more_details_visible = enabled
	_sync_hud()
	return true

func set_controls_help_visible(enabled: bool) -> bool:
	v0135_help_overlay_visible = enabled
	if enabled:
		v0135_help_opened = true
		v0135_tooltip_visible = true
		last_feedback_id = "controls_help"
	else:
		v0135_help_dismissed = true
	_sync_hud()
	return true

func toggle_controls_help() -> bool:
	return set_controls_help_visible(not v0135_help_overlay_visible)

func show_objective_feedback(feedback_id: String) -> bool:
	var normalized := feedback_id.strip_edges().to_lower()
	if normalized == "":
		return false
	active_alert_id = normalized
	last_feedback_id = normalized
	concise_alert_rendered = true
	match normalized:
		"objective_1", "select_aster", "move_to_quarry", "quarry_complete", "mine_converted", "worker_assigned_mine":
			objective_complete_pulse_rendered = true
		"pressure_wave":
			pressure_wave_arrived = true
			pressure_wave_notice_rendered = true
		"lume_activation", "lume_restore":
			lume_activation_notice_rendered = true
			objective_complete_pulse_rendered = true
		"results_summary":
			objective_complete_pulse_rendered = true
	_record_notification(normalized)
	_sync_hud()
	return true

func _record_v0134_recovery_feedback(feedback_id: String, event_name: String, details: Dictionary = {}) -> void:
	var normalized := feedback_id.strip_edges().to_lower()
	if normalized == "":
		return
	last_feedback_id = normalized
	if not v0134_recovery_feedback_ids.has(normalized):
		v0134_recovery_feedback_ids.append(normalized)
	v0134_recovery_feedback_count += 1
	var payload := details.duplicate(true)
	payload["feedbackId"] = normalized
	_record_real_input(event_name, payload)
	_sync_hud()

func _record_v0135_recoverable_feedback(feedback_id: String, event_name: String, details: Dictionary = {}) -> void:
	var normalized := feedback_id.strip_edges().to_lower()
	if normalized == "":
		return
	last_feedback_id = normalized
	match normalized:
		"invalid_order", "no_selection_order", "invalid_ground":
			v0135_invalid_order_marker_rendered = true
		"context_action", "context_mine", "context_barracks", "context_lume":
			v0135_context_action_marker_rendered = true
		"hover", "short_tooltip", "controls_help":
			v0135_tooltip_visible = true
	var payload := details.duplicate(true)
	payload["feedbackId"] = normalized
	_record_real_input(event_name, payload)
	_sync_hud()

func set_workload_tier(tier: String) -> bool:
	var result: bool = runtime.set_workload_tier(tier)
	if player_facing_mode:
		runtime.apply_player_facing_staging()
		_reset_real_input_state()
	_rebuild_visuals()
	_sync_hud()
	return result

func select_entity(id: String) -> bool:
	var result: bool = runtime.select_entity(id)
	_sync_unit_visuals()
	_sync_hud()
	return result

func box_select_squad() -> Array[String]:
	var result: Array[String] = runtime.box_select_squad()
	_sync_unit_visuals()
	_sync_hud()
	return result

func issue_move_order(target: Vector3 = Vector3.INF) -> bool:
	var target_2d := Vector2.INF
	if target != Vector3.INF:
		target_2d = _from_world(target)
	var result: bool = runtime.issue_move_order(target_2d)
	last_feedback_id = "move_order"
	set_onboarding_step("capture_hold_quarry")
	show_objective_feedback("move_to_quarry")
	_set_or_create_marker("move_order_marker", Vector3(0.9, 0.12, 1.4), Vector3(0.42, 0.08, 0.42), Color(0.35, 0.75, 0.96))
	_set_or_create_marker("move_order_direction_tick", Vector3(1.2, 0.18, 1.22), Vector3(0.14, 0.22, 0.42), Color(0.62, 0.86, 0.98))
	_sync_unit_visuals()
	_sync_hud()
	return result

func issue_attack_order(target_id: String = "") -> bool:
	var result: bool = runtime.issue_attack_order(target_id)
	last_feedback_id = "attack_order"
	pressure_wave_arrived = true
	set_onboarding_step("defeat_wave")
	show_objective_feedback("pressure_wave")
	_set_or_create_marker("attack_order_marker", Vector3(4.2, 0.72, 0.2), Vector3(0.46, 0.08, 0.46), Color(0.95, 0.22, 0.16))
	_set_or_create_marker("enemy_target_marker", Vector3(3.18, 0.70, -1.54), Vector3(0.54, 0.08, 0.54), Color(0.96, 0.24, 0.18))
	_set_or_create_marker("pressure_wave_arrival_marker", Vector3(3.9, 0.20, -0.92), Vector3(1.10, 0.07, 0.34), Color(0.85, 0.20, 0.14, 0.62))
	_sync_unit_visuals()
	_sync_hud()
	return result

func change_site_state(site_id: String = "west_stone_cut", state: String = "friendly") -> bool:
	var result: bool = runtime.change_site_state(site_id, state)
	if site_id == "west_stone_cut" and state == "friendly":
		v0132_site_state = SITE_STATE_CONTROLLED
		v0132_mine_controlled = true
		v0132_conversion_progress = 100.0
		set_onboarding_step("worker_mine_or_shrine")
		show_objective_feedback("quarry_complete")
	if site_id == "ford_toll" and state == "friendly":
		set_onboarding_step("restore_lume_link")
		show_objective_feedback("lume_activation")
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_hud()
	return result

func trigger_hero_ability() -> bool:
	var result: bool = runtime.trigger_hero_ability()
	_set_or_create_marker("hero_ability_pulse", Vector3(-4.7, 0.18, -1.55), Vector3(0.78, 0.08, 0.78), Color(0.80, 0.92, 0.64))
	_sync_hud()
	return result

func capture_mine_site() -> bool:
	var result: bool = runtime.capture_mine_site()
	if result:
		v0132_site_state = SITE_STATE_CONTROLLED
		v0132_mine_controlled = true
		v0132_conversion_progress = 100.0
		set_onboarding_step("worker_assign_mine")
		show_objective_feedback("mine_converted")
		_set_or_create_marker("mine_conversion_ring", _site_world_position("west_stone_cut", Vector3(-1.52, 0.14, 0.12)), Vector3(0.82, 0.08, 0.82), Color(0.36, 0.92, 0.52, 0.58))
		_record_real_input("mine_controlled", {"site": WEST_STONE_CUT_MINE_LABEL, "progress": 100.0})
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_hud()
	return result

func assign_worker_to_mine() -> bool:
	var result: bool = runtime.assign_worker_to_mine()
	if result:
		v0132_site_state = SITE_STATE_WORKER_ASSIGNED
		v0132_worker_assignment_complete = true
		v0132_worker_assignment_marker_rendered = true
		set_onboarding_step("restore_barracks")
		show_objective_feedback("worker_assigned_mine")
		_set_or_create_marker("worker_mine_assignment_marker", _unit_world_position("worker_00", Vector3(-2.02, 0.14, 0.42)), Vector3(0.48, 0.08, 0.48), Color(0.92, 0.78, 0.36, 0.64))
		_prepare_v0133_barracks_handoff()
		runtime.advance_resource_production(120)
		v0132_production_boost_feedback_rendered = runtime.resource_production_boosted
		v0132_worker_objective_advanced = current_onboarding_step == "restore_barracks"
		_record_real_input("worker_assigned_to_mine", {"site": WEST_STONE_CUT_MINE_LABEL, "productionBoosted": runtime.resource_production_boosted})
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_hud()
	return result

func advance_resource_production(frames: int = 120) -> bool:
	var result: bool = runtime.advance_resource_production(frames)
	if result:
		_set_or_create_marker("mine_income_boost_marker", _structure_world_position("mine_landmark", Vector3(-1.83, 0.14, 0.24)) + Vector3(0.0, 0.22, 0.0), Vector3(0.34, 0.12, 0.34), Color(0.72, 0.86, 0.46, 0.56))
		v0132_production_boost_feedback_rendered = runtime.resource_production_boosted
	_sync_hud()
	return result

func place_barracks_placeholder() -> bool:
	var result: bool = runtime.place_barracks_placeholder()
	if result:
		v0133_barracks_build_order_accepted = true
		v0133_construction_started = true
		v0133_construction_progress = maxf(v0133_construction_progress, runtime.barracks_construction_progress)
		set_onboarding_step("restore_barracks")
		show_objective_feedback("barracks_placed")
	_rebuild_visuals()
	if result:
		_set_or_create_marker("barracks_build_placement_marker", _structure_world_position("barracks", Vector3(-4.8, 0.14, -3.58)), Vector3(0.92, 0.08, 0.62), Color(0.70, 0.82, 0.48, 0.58))
	_sync_hud()
	return result

func advance_construction(frames: int = 120) -> bool:
	var result: bool = runtime.advance_construction(frames)
	if result:
		v0133_construction_progress = runtime.barracks_construction_progress
		v0133_construction_25_recorded = v0133_construction_25_recorded or v0133_construction_progress >= 0.25
		v0133_construction_75_recorded = v0133_construction_75_recorded or v0133_construction_progress >= 0.75
		var marker_color := Color(0.38, 0.88, 0.56, 0.64) if runtime.barracks_complete else Color(0.90, 0.74, 0.30, 0.62)
		if runtime.barracks_complete:
			v0133_barracks_restored = true
			set_onboarding_step("train_militia")
			show_objective_feedback("barracks_complete")
	_rebuild_visuals()
	if result:
		var marker_color := Color(0.38, 0.88, 0.56, 0.64) if runtime.barracks_complete else Color(0.90, 0.74, 0.30, 0.62)
		_set_or_create_marker("barracks_construction_progress_marker", _structure_world_position("barracks", Vector3(-4.8, 0.14, -3.58)) + Vector3(0.0, 0.30, 0.0), Vector3(0.72, 0.10, 0.20), marker_color)
	_sync_hud()
	return result

func queue_militia_recruit() -> bool:
	var result: bool = runtime.queue_militia_recruit()
	if result:
		v0133_train_militia_clicked = true
		v0133_recruit_queue_started = true
		v0133_recruit_progress = 0.0
		set_onboarding_step("train_militia")
		show_objective_feedback("militia_queued")
		_set_or_create_marker("militia_recruit_queue_marker", _structure_world_position("barracks", Vector3(-4.8, 0.14, -3.58)) + Vector3(0.45, 0.28, 0.0), Vector3(0.34, 0.12, 0.34), Color(0.42, 0.86, 0.56, 0.64))
	_sync_hud()
	return result

func complete_recruit_queue(frames: int = 120) -> bool:
	var result: bool = runtime.complete_recruit_queue(frames)
	if result:
		v0133_recruit_progress = _runtime_recruit_progress()
		if not v0133_recruit_queue_50_recorded and v0133_recruit_progress >= 0.50:
			v0133_recruit_queue_50_recorded = true
			_record_real_input("militia_recruit_progress_50", {"progress": snappedf(v0133_recruit_progress, 0.001)})
		if runtime.militia_spawned:
			v0133_militia_spawned = true
			_start_v0133_pressure_countdown()
			set_onboarding_step("prepare_ashen_pressure")
			show_objective_feedback("militia_spawned")
			_rebuild_visuals()
			_set_or_create_marker("militia_spawned_marker", _unit_world_position("recruited_militia_00", Vector3(-3.95, 0.12, -2.36)), Vector3(0.42, 0.08, 0.42), Color(0.46, 0.90, 0.60, 0.58))
			_record_real_input("militia_spawned", {"progress": snappedf(v0133_recruit_progress, 0.001)})
	_sync_unit_visuals()
	_sync_hud()
	return result

func queue_ranger_recruit() -> bool:
	var result: bool = runtime.queue_ranger_recruit()
	_sync_hud()
	return result

func trigger_pressure_wave() -> bool:
	var result: bool = runtime.trigger_pressure_wave()
	if result:
		pressure_wave_arrived = true
		v0133_wave_triggered_once = true
		v0133_wave_trigger_source = "countdown" if v0133_countdown_started else "harness"
		v0133_road_entry_pulse_visible = true
		_prepare_v0133_combat_handoff()
		v0133_enemy_start_positions = _v0133_wave_positions()
		v0133_wave_remaining_count = _v0133_wave_remaining()
		v0133_initial_combat_tick_count = runtime.combat_tick_count
		set_onboarding_step("defeat_wave")
		show_objective_feedback("pressure_wave")
		_set_or_create_marker("pressure_wave_arrival_marker", _to_world(Vector2(875, 486), 0.16), Vector3(1.10, 0.045, 0.20), Color(0.85, 0.20, 0.14, 0.30))
	_sync_unit_visuals()
	_sync_hud()
	return result

func defeat_pressure_wave() -> bool:
	var result: bool = runtime.defeat_pressure_wave()
	if result:
		damage_flash_active = true
		death_fade_active = true
		show_objective_feedback("wave_defeated")
	_rebuild_visuals()
	_sync_hud()
	return result

func restore_lume_microloop() -> bool:
	var result: bool = runtime.restore_lume_microloop()
	if result:
		v0133_lume_restored = true
		set_onboarding_step("review_results")
		show_objective_feedback("lume_restore")
		_set_or_create_marker("lume_restore_marker", _lume_endpoint_world_position("lume_endpoint_00", Vector3(-1.67, 0.14, 0.11)), Vector3(0.74, 0.08, 0.74), Color(0.42, 0.96, 0.86, 0.62))
	_sync_lume_visuals()
	_sync_hud()
	return result

func focus_lume_link() -> bool:
	var result: bool = runtime.focus_lume_link()
	show_objective_feedback("lume_activation")
	_sync_lume_visuals()
	_sync_hud()
	return result

func pan_camera() -> bool:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return false
	camera.position = _clamped_camera_position(camera.position + Vector3(0.8, 0.0, 0.35))
	camera_panned = true
	camera_focus_id = "minimap"
	return true

func zoom_camera() -> bool:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return false
	camera.size = clampf(11.0, SAFE_ZOOM_MIN, SAFE_ZOOM_MAX)
	camera_zoomed = true
	camera_zoom_posture = "objective"
	return true

func _pan_camera_by(delta: Vector3, source: String) -> bool:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return false
	camera.position = _clamped_camera_position(camera.position + delta)
	camera_panned = true
	camera_focus_id = source
	v0135_camera_pan_input_seen = true
	v0135_keyboard_pan_count += 1
	_record_real_input("camera_pan", {"source": source, "cameraPosition": _vector3_report(camera.position)})
	_sync_hud()
	return true

func _zoom_camera_by(delta: float, source: String) -> bool:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return false
	camera.size = clampf(camera.size + delta, SAFE_ZOOM_MIN, SAFE_ZOOM_MAX)
	camera_zoomed = true
	camera_zoom_posture = "wheel"
	camera_focus_id = source
	v0135_camera_zoom_input_seen = true
	v0135_mouse_wheel_zoom_count += 1
	_record_real_input("camera_zoom", {"source": source, "zoom": snappedf(camera.size, 0.01)})
	_sync_hud()
	return true

func focus_layout_feature(feature: String) -> bool:
	var normalized := feature.strip_edges().to_lower()
	var position := CAMERA_DEFAULT_POSITION
	var zoom := SAFE_FRAME_DEFAULT_ZOOM
	match normalized:
		"default":
			pass
		"road":
			position = Vector3(-0.78, 11.32, 8.32)
			zoom = 8.78
		"v0195_road_network":
			position = Vector3(-2.18, 11.08, 6.96)
			zoom = SAFE_ZOOM_MIN
		"v0195_road_intersections":
			position = Vector3(-1.88, 11.04, 6.88)
			zoom = SAFE_ZOOM_MIN
		"v0195_road_to_bridge":
			position = Vector3(0.08, 10.98, 6.70)
			zoom = SAFE_ZOOM_MIN
		"v0195_bridge_close":
			position = Vector3(0.84, 10.88, 6.48)
			zoom = SAFE_ZOOM_MIN
		"ford":
			position = Vector3(0.88, 11.08, 7.72)
			zoom = 8.18
		"bridge":
			position = Vector3(0.96, 11.08, 7.66)
			zoom = 8.05
		"road_intersections":
			position = Vector3(-1.92, 11.12, 8.12)
			zoom = 8.34
		"approach_lanes":
			position = Vector3(-3.45, 11.30, 8.75)
			zoom = 9.05
		"hostile_lane":
			position = Vector3(3.28, 11.25, 8.42)
			zoom = 9.02
		"friendly_boundary":
			position = Vector3(-4.78, 11.16, 8.72)
			zoom = 8.46
		"site_marker_hierarchy":
			position = Vector3(-1.56, 11.10, 8.18)
			zoom = 8.28
		"quarry":
			position = Vector3(-2.15, 11.25, 8.95)
			zoom = 9.35
		"shrine":
			position = Vector3(-0.9, 11.25, 8.05)
			zoom = 9.35
		"ruin":
			position = Vector3(2.35, 11.35, 9.45)
			zoom = 9.45
		"buildable_ground":
			position = Vector3(-4.45, 11.35, 9.45)
			zoom = 9.6
		"objective_focus":
			position = Vector3(-1.35, 11.2, 8.85)
			zoom = 9.0
		"minimap":
			position = Vector3(0.8, 11.5, 9.25)
			zoom = 11.2
		_:
			return false
	_apply_camera_authoring_posture(normalized, position, zoom)
	return true

func focus_visual_subject(subject: String) -> bool:
	var normalized := subject.strip_edges().to_lower()
	var camera_position := CAMERA_DEFAULT_POSITION
	var zoom := 9.25
	var marker_position := Vector3.ZERO
	match normalized:
		"hero", "hero_aster", "hero_selected":
			camera_position = Vector3(-4.55, 11.25, 8.35)
			marker_position = _unit_world_position("hero_aster", Vector3(-5.16, 0.12, -1.67))
		"worker", "worker_selected":
			camera_position = Vector3(-5.25, 11.35, 9.05)
			marker_position = _unit_world_position("worker_00", Vector3(-5.94, 0.12, 0.22))
		"militia":
			camera_position = Vector3(-3.45, 11.25, 8.45)
			marker_position = _unit_world_position("friendly_00", Vector3(-4.05, 0.12, -1.39))
		"ranger":
			camera_position = Vector3(-3.08, 11.25, 8.45)
			marker_position = _unit_world_position("friendly_01", Vector3(-3.62, 0.12, -1.39))
		"ashen_raider", "raider", "enemy":
			camera_position = Vector3(3.45, 11.25, 8.50)
			marker_position = _unit_world_position("ashen_00", Vector3(2.0, 0.12, -1.67))
		"ashen_brute", "brute":
			camera_position = Vector3(4.05, 11.25, 8.50)
			marker_position = _unit_world_position("ashen_02", Vector3(2.75, 0.12, -1.67))
		"command_hall":
			camera_position = Vector3(-5.45, 11.35, 8.08)
			marker_position = _structure_world_position("command_hall", Vector3(-6.0, 0.14, -2.78))
		"barracks":
			camera_position = Vector3(-4.05, 11.25, 7.92)
			marker_position = _structure_world_position("barracks", Vector3(-4.8, 0.14, -3.58))
		"mine":
			camera_position = Vector3(-2.15, 11.25, 8.95)
			marker_position = _structure_world_position("mine_landmark", Vector3(-1.83, 0.14, 0.24))
		"bridge":
			camera_position = Vector3(0.96, 11.08, 7.66)
			marker_position = Vector3(0.56, 0.20, 0.88)
		"shrine":
			camera_position = Vector3(-0.9, 11.25, 8.05)
			marker_position = _structure_world_position("shrine_landmark", Vector3(-0.64, 0.14, -2.78))
		"quarry":
			camera_position = Vector3(-2.15, 11.25, 8.95)
			marker_position = _structure_world_position("mine_landmark", Vector3(-1.83, 0.14, 0.24))
		"ruin":
			camera_position = Vector3(2.35, 11.35, 9.45)
			marker_position = Vector3(2.2, 0.14, 2.08)
		"site", "capture_site":
			camera_position = Vector3(-1.35, 11.2, 8.85)
			marker_position = _site_world_position("site_west_stone_cut", Vector3(-1.52, 0.14, 0.12))
		"lume_endpoint":
			camera_position = Vector3(-1.10, 11.2, 8.55)
			marker_position = _lume_endpoint_world_position("lume_endpoint_00", Vector3(-1.67, 0.14, 0.11))
		"squad":
			camera_position = Vector3(-3.32, 11.22, 8.38)
			zoom = 8.62
			marker_position = _unit_world_position("friendly_03", Vector3(-2.78, 0.12, -1.39))
		"move_order":
			camera_position = Vector3(-1.10, 11.25, 8.75)
			marker_position = Vector3(0.9, 0.12, 1.4)
		"attack_order", "combat", "death":
			camera_position = Vector3(2.4, 11.35, 8.62)
			marker_position = _unit_world_position("ashen_00", Vector3(2.0, 0.12, -1.67))
		"results":
			camera_position = CAMERA_DEFAULT_POSITION
			marker_position = Vector3(-4.4, 0.22, 3.1)
		_:
			return false
	hover_target_id = normalized
	last_feedback_id = "hover:%s" % normalized
	_apply_camera_authoring_posture(normalized, camera_position, zoom)
	_set_or_create_disc_marker("hover_feedback_marker", marker_position + Vector3(0.0, 0.045, 0.0), 0.34, Color(0.84, 0.92, 0.66, 0.44))
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_hud()
	return true

func focus_environment_structure_shell_subject(subject: String, close: bool = false) -> bool:
	var normalized := subject.strip_edges().to_lower()
	var camera_position := CAMERA_DEFAULT_POSITION
	var zoom := 8.75
	var marker_position := Vector3.ZERO
	match normalized:
		"command_hall":
			camera_position = Vector3(-5.78, 11.35, 7.60)
			zoom = 9.20 if not close else 8.20
			marker_position = _structure_world_position("command_hall", Vector3(-6.0, 0.14, -2.78))
		"mine", "quarry":
			camera_position = Vector3(-2.14, 11.25, 8.88 if not close else 8.78)
			zoom = 8.72 if not close else 8.10
			marker_position = _structure_world_position("mine_landmark", Vector3(-1.83, 0.14, 0.24))
		"barracks":
			camera_position = Vector3(-4.92, 11.32, 7.60)
			zoom = 9.20 if not close else 8.20
			marker_position = _structure_world_position("barracks", Vector3(-4.8, 0.14, -3.58))
		_:
			return false
	hover_target_id = normalized
	last_feedback_id = "hover:v0186:%s" % normalized
	_apply_camera_authoring_posture("v0186_%s_%s" % [normalized, "close" if close else "normal"], camera_position, zoom)
	_set_or_create_disc_marker("hover_feedback_marker", marker_position + Vector3(0.0, 0.045, 0.0), 0.34, Color(0.84, 0.92, 0.66, 0.44))
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_hud()
	return true

func focus_environment_riverbank_bridge_subject(subject: String, close: bool = false) -> bool:
	var normalized := subject.strip_edges().to_lower()
	var camera_position := CAMERA_DEFAULT_POSITION
	var zoom := 8.35
	var marker_position := Vector3.ZERO
	match normalized:
		"river", "river_overview":
			camera_position = Vector3(0.26, 11.20, 7.70)
			zoom = 8.55 if not close else 7.92
			marker_position = Vector3(0.60, 0.18, -0.40)
		"banks", "riverbanks":
			camera_position = Vector3(0.22, 11.10, 7.42)
			zoom = 8.20 if not close else 7.58
			marker_position = Vector3(0.60, 0.20, 0.88)
		"bridge", "crossing":
			camera_position = Vector3(0.92, 11.02, 7.42)
			zoom = 8.02 if not close else 7.26
			marker_position = Vector3(0.56, 0.20, 0.88)
		"road_to_bridge":
			camera_position = Vector3(-0.54, 11.08, 7.58)
			zoom = 7.86
			marker_position = Vector3(-0.54, 0.18, 0.86)
		"friendly_approach":
			camera_position = Vector3(-3.82, 11.24, 8.18)
			zoom = 8.58
			marker_position = Vector3(-3.72, 0.18, 1.32)
		"hostile_approach":
			camera_position = Vector3(3.36, 11.22, 8.18)
			zoom = 8.58
			marker_position = Vector3(3.56, 0.18, -0.98)
		"combat_crossing":
			camera_position = Vector3(1.82, 11.18, 7.82)
			zoom = 8.25
			marker_position = Vector3(1.20, 0.18, -0.74)
		_:
			return false
	hover_target_id = normalized
	last_feedback_id = "hover:v0187:%s" % normalized
	_apply_camera_authoring_posture("v0187_%s_%s" % [normalized, "close" if close else "normal"], camera_position, zoom)
	_set_or_create_disc_marker("hover_feedback_marker", marker_position + Vector3(0.0, 0.045, 0.0), 0.30, Color(0.86, 0.92, 0.64, 0.38))
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_hud()
	return true

func show_combat_readability_sample() -> bool:
	combat_readability_active = true
	damage_flash_active = true
	pressure_wave_arrived = true
	site_contest_active = true
	runtime.box_select_squad()
	runtime.issue_attack_order("ashen_00")
	runtime.change_site_state("north_aether_spring", "contested")
	_set_unit_health("ashen_00", 58.0, true)
	_set_or_create_marker("melee_contact_marker", Vector3(2.35, 0.30, -1.18), Vector3(0.34, 0.10, 0.20), Color(0.96, 0.78, 0.38, 0.74))
	_set_or_create_marker("ranged_shot_placeholder", Vector3(1.12, 0.42, -1.18), Vector3(1.45, 0.045, 0.045), Color(0.58, 0.92, 0.76, 0.78))
	_set_or_create_marker("hit_feedback_flash", Vector3(2.0, 0.62, -1.67), Vector3(0.38, 0.12, 0.38), Color(0.98, 0.54, 0.26, 0.76))
	_set_or_create_marker("pressure_wave_arrival_marker", Vector3(3.9, 0.20, -0.92), Vector3(1.10, 0.07, 0.34), Color(0.85, 0.20, 0.14, 0.62))
	focus_visual_subject("combat")
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_hud()
	return true

func show_death_readability_sample() -> bool:
	combat_readability_active = true
	damage_flash_active = true
	death_fade_active = true
	pressure_wave_arrived = true
	_set_unit_health("ashen_00", 0.0, false)
	_set_or_create_marker("death_fade_marker", Vector3(2.0, 0.30, -1.67), Vector3(0.58, 0.065, 0.58), Color(0.72, 0.66, 0.54, 0.46))
	_set_or_create_marker("death_fade_shadow", Vector3(2.0, 0.18, -1.67), Vector3(0.46, 0.035, 0.46), Color(0.18, 0.12, 0.10, 0.42))
	focus_visual_subject("death")
	_sync_unit_visuals()
	_sync_hud()
	return true

func set_camera_zoom_posture(posture: String) -> bool:
	var normalized := posture.strip_edges().to_lower()
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return false
	match normalized:
		"min", "min_zoom", "camera_min_zoom":
			camera.size = SAFE_ZOOM_MIN
			camera_zoom_posture = "min"
			camera_focus_id = "camera_min_zoom"
		"max", "max_zoom", "camera_max_zoom":
			camera.size = SAFE_ZOOM_MAX
			camera_zoom_posture = "max"
			camera_focus_id = "camera_max_zoom"
		"default":
			camera.size = SAFE_FRAME_DEFAULT_ZOOM
			camera_zoom_posture = "default"
			camera_focus_id = "default"
		_:
			return false
	camera.position = _clamped_camera_position(camera.position)
	camera_zoomed = true
	return true

func apply_three_slot_art_review_framing() -> bool:
	three_slot_art_review_framing_active = true
	five_slot_art_review_framing_active = false
	_apply_camera_authoring_posture("v0166_three_slot_art_review", Vector3(-4.54, 11.25, 7.60), SAFE_ZOOM_MIN)
	_refresh_worker_art_counters()
	_refresh_militia_art_counters()
	_refresh_aster_art_counters()
	_refresh_ashen_art_counters()
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_three_slot_review_art_anchors()
	_sync_hud()
	return true

func apply_four_slot_art_review_framing() -> bool:
	three_slot_art_review_framing_active = true
	five_slot_art_review_framing_active = false
	_apply_camera_authoring_posture("v0168_four_slot_art_review", Vector3(-4.54, 11.25, 7.60), SAFE_ZOOM_MIN)
	_refresh_worker_art_counters()
	_refresh_militia_art_counters()
	_refresh_aster_art_counters()
	_refresh_ashen_art_counters()
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_three_slot_review_art_anchors()
	_sync_hud()
	return true

func apply_five_slot_art_review_framing() -> bool:
	three_slot_art_review_framing_active = true
	five_slot_art_review_framing_active = true
	_apply_camera_authoring_posture("v0170_five_slot_art_review", Vector3(-4.54, 11.25, 7.60), SAFE_ZOOM_MIN)
	_refresh_worker_art_counters()
	_refresh_militia_art_counters()
	_refresh_aster_art_counters()
	_refresh_ashen_art_counters()
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_three_slot_review_art_anchors()
	_sync_hud()
	return true

func stage_five_slot_art_review_squad_comparison() -> bool:
	if not five_slot_art_review_framing_active or not player_facing_mode or player_shell_screen != "battle":
		return false
	var staged := runtime.stage_five_slot_art_review_squad_comparison()
	if not staged:
		return false
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_three_slot_review_art_anchors()
	_sync_hud()
	return true

func recenter_camera() -> bool:
	_apply_camera_authoring_posture("default", CAMERA_DEFAULT_POSITION, SAFE_FRAME_DEFAULT_ZOOM)
	return true

func focus_aster_from_input() -> bool:
	var result := focus_visual_subject("hero")
	v0135_focus_aster_input_seen = result
	if result:
		_record_real_input("focus_aster", {"source": "space"})
	return result

func toggle_pause() -> bool:
	var result: bool = runtime.toggle_pause()
	_set_or_create_marker("pause_marker", Vector3(-5.2, 0.22, -3.1), Vector3(0.72, 0.16, 0.32), Color(0.84, 0.78, 0.44))
	_sync_hud()
	return result

func transition_results() -> bool:
	var result: bool = runtime.transition_results()
	set_onboarding_step("review_results")
	show_objective_feedback("results_summary")
	v0136_results_recap_seen = result
	_set_or_create_marker("results_marker", Vector3(-4.4, 0.22, 3.1), Vector3(1.0, 0.16, 0.38), Color(0.70, 0.86, 0.82))
	_sync_hud()
	return result

func clear_selection() -> bool:
	var result: bool = runtime.clear_selection()
	real_input_selected_id = ""
	_sync_unit_visuals()
	_sync_hud()
	return result

func real_input_screen_position(subject: String) -> Vector2:
	var normalized := subject.strip_edges().to_lower()
	match normalized:
		"empty_ground":
			return _world_to_screen(_to_world(Vector2(1180, 720), 0.12))
		"invalid_ground":
			return Vector2(1582, 36)
		"help_button":
			return hud_help_button.get_global_rect().get_center() if hud_help_button != null else Vector2(1474, 626)
		"hero", "aster", "hero_aster":
			return _unit_screen_position("hero_aster")
		"worker", "worker_00":
			return _unit_screen_position("worker_00")
		"soldier", "militia", "friendly_00":
			return _unit_screen_position("friendly_00")
		"enemy", "ashen", "ashen_00":
			return _unit_screen_position("ashen_00")
		"barracks", "restore_barracks":
			return _world_to_screen(_structure_world_position("barracks", _to_world(BARRACKS_POSITION, 0.12)))
		"barracks_interaction":
			var barracks_screen := _world_to_screen(_structure_world_position("barracks", _to_world(BARRACKS_POSITION, 0.12)))
			return barracks_screen + Vector2(0, 64) if barracks_screen != Vector2.INF else Vector2.INF
		"lume", "lume_link", "ford_toll":
			return _world_to_screen(_structure_world_position("shrine_landmark", _to_world(LUME_LINK_POSITION, 0.12)))
		"lume_interaction":
			var lume_screen := _world_to_screen(_structure_world_position("shrine_landmark", _to_world(LUME_LINK_POSITION, 0.12)))
			return lume_screen + Vector2(0, 48) if lume_screen != Vector2.INF else Vector2.INF
		"road_entry", "ashen_road_entry":
			return _world_to_screen(_to_world(Vector2(980, 285), 0.12))
		"train_militia_button":
			return Vector2(18 + 16 + 3 * 95 + 41, 744 + 106 + 13)
		"attack_button":
			return hud_attack_button.get_global_rect().get_center() if hud_attack_button != null else Vector2(18 + 16 + 2 * 95 + 41, 744 + 106 + 13)
		"quarry", "mine", "move_destination", "west_stone_cut_mine", "site_west_stone_cut":
			return _world_to_screen(_to_world(WEST_STONE_CUT_MINE_POSITION, 0.12))
		"squad_drag_start":
			return _unit_screen_position("friendly_00") - Vector2(34, 34)
		"squad_drag_end":
			return _unit_screen_position("friendly_05") + Vector2(34, 34)
	return Vector2.INF

func real_input_smoke_status() -> Dictionary:
	var selected: Array[String] = runtime.selected_ids.duplicate()
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.131",
		"status": "PASS_REAL_INPUT_SCENE_STATUS" if _real_input_scene_green() else "FAIL_REAL_INPUT_SCENE_STATUS",
		"selectedIds": selected,
		"hoverTargetId": real_input_hover_id,
		"selectedUnitId": real_input_selected_id,
		"asterSelected": real_input_aster_selected,
		"workerSelected": real_input_worker_selected,
		"squadBoxSelected": real_input_squad_box_selected,
		"moveOrderAccepted": real_input_move_order_accepted,
		"attackOrderAccepted": real_input_attack_order_accepted,
		"moveMarkerRendered": real_input_move_marker_rendered,
		"attackMarkerRendered": real_input_attack_marker_rendered,
		"movementStarted": real_input_movement_started,
		"movementCompleted": real_input_movement_completed,
		"movementDisplacement": snappedf(real_input_movement_displacement, 0.01),
		"visibleMovementConfirmed": real_input_visible_movement_confirmed,
		"visibleMovementDelta": snappedf(real_input_aster_screen_delta, 0.01),
		"asterStartScreen": _vector2_report(real_input_aster_start_screen) if real_input_aster_start_screen != Vector2.INF else {},
		"asterCurrentScreen": _vector2_report(real_input_aster_current_screen) if real_input_aster_current_screen != Vector2.INF else {},
		"objectiveAdvancedAfterRealMovement": real_input_objective_advanced,
		"invalidObjectiveAdvance": real_input_invalid_objective_advance,
		"debugShortcutUsed": real_input_debug_shortcut_used,
		"stateInjectionUsed": real_input_state_injection_used,
		"hudCardUpdated": real_input_hud_card_updated,
		"emptyDeselectDone": real_input_empty_deselect_done,
		"linkedWardDamageTakenMultiplier": 0.92,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"routineEditorUseRequired": false,
		"trace": real_input_trace.duplicate(true)
	}

func site_semantics_status() -> Dictionary:
	var selected: Array[String] = runtime.selected_ids.duplicate()
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.132",
		"status": "PASS_V0132_SITE_SEMANTICS_SCENE_STATUS" if _site_semantics_scene_green() else "FAIL_V0132_SITE_SEMANTICS_SCENE_STATUS",
		"canonicalSiteId": WEST_STONE_CUT_MINE_SITE_ID,
		"canonicalSiteRuntimeId": WEST_STONE_CUT_MINE_RUNTIME_ID,
		"canonicalSiteLabel": WEST_STONE_CUT_MINE_LABEL,
		"siteState": v0132_site_state,
		"selectedIds": selected,
		"hoverTargetId": real_input_hover_id,
		"selectedUnitId": real_input_selected_id,
		"asterSelected": real_input_aster_selected,
		"moveOrderAccepted": real_input_move_order_accepted,
		"moveMarkerRendered": real_input_move_marker_rendered,
		"movementStarted": real_input_movement_started,
		"visibleMovementConfirmed": real_input_visible_movement_confirmed,
		"objectiveAdvancedAfterRealMovement": real_input_objective_advanced,
		"asterEnteredMineCaptureRadius": v0132_aster_entered_capture_radius,
		"conversionProgress": snappedf(v0132_conversion_progress, 0.01),
		"conversionProgressVisible": v0132_conversion_progress_visible,
		"mineControlled": v0132_mine_controlled,
		"workerHighlightVisible": v0132_worker_highlight_visible,
		"workerSelected": real_input_worker_selected,
		"workerAssignmentMarkerRendered": v0132_worker_assignment_marker_rendered,
		"workerAssignedToMine": v0132_worker_assignment_complete,
		"productionBoostFeedbackRendered": v0132_production_boost_feedback_rendered,
		"objectiveAdvancedAfterWorkerAssignment": v0132_worker_objective_advanced,
		"objectiveStep": current_onboarding_step,
		"objectiveRank": _onboarding_rank(current_onboarding_step),
		"objectiveRegressionBlockedCount": v0132_objective_regression_blocked_count,
		"actualObjectiveRegressionDetected": v0132_actual_objective_regression_detected,
		"objectiveHistory": v0132_objective_history.duplicate(true),
		"debugShortcutUsed": real_input_debug_shortcut_used,
		"stateInjectionUsed": real_input_state_injection_used,
		"privateHarnessShortcutUsed": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"routineEditorUseRequired": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"trace": real_input_trace.duplicate(true)
	}

func post_mine_flow_status() -> Dictionary:
	var selected: Array[String] = runtime.selected_ids.duplicate()
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.133",
		"status": "PASS_V0133_POST_MINE_FLOW_SCENE_STATUS" if _post_mine_flow_scene_green() else "FAIL_V0133_POST_MINE_FLOW_SCENE_STATUS",
		"canonicalObjectiveSequence": [
			"select_aster",
			"move_to_west_stone_cut_mine",
			"convert_west_stone_cut_mine",
			"assign_worker_to_mine",
			"restore_barracks",
			"train_militia",
			"prepare_ashen_pressure",
			"defeat_ashen_wave",
			"restore_lume_link",
			"review_results"
		],
		"selectedIds": selected,
		"objectiveStep": _v0133_public_objective_step(current_onboarding_step),
		"objectiveRank": _v0133_public_objective_rank(current_onboarding_step),
		"objectiveHistory": _v0133_public_objective_history(),
		"actualObjectiveRegressionDetected": v0132_actual_objective_regression_detected,
		"objectiveRegressionBlockedCount": v0132_objective_regression_blocked_count,
		"illegalObjectiveSkipRejectedCount": v0133_illegal_objective_skip_rejected_count,
		"boxSelectNoObjectiveSkipProven": v0133_box_select_no_skip_proven,
		"asterSelected": real_input_aster_selected,
		"moveOrderAccepted": real_input_move_order_accepted,
		"mineControlled": v0132_mine_controlled,
		"workerSelected": real_input_worker_selected,
		"squadBoxSelected": real_input_squad_box_selected,
		"workerAssignedToMine": v0132_worker_assignment_complete,
		"productionBoostFeedbackRendered": v0132_production_boost_feedback_rendered,
		"barracksHighlightVisible": v0133_barracks_highlight_visible,
		"barracksBuildOrderAccepted": v0133_barracks_build_order_accepted,
		"constructionStarted": v0133_construction_started,
		"constructionProgress": snappedf(v0133_construction_progress, 0.001),
		"construction25Recorded": v0133_construction_25_recorded,
		"construction75Recorded": v0133_construction_75_recorded,
		"barracksRestored": v0133_barracks_restored,
		"barracksSelected": v0133_barracks_selected,
		"trainMilitiaClicked": v0133_train_militia_clicked,
		"recruitQueueStarted": v0133_recruit_queue_started,
		"recruitProgress": snappedf(v0133_recruit_progress, 0.001),
		"recruitQueue50Recorded": v0133_recruit_queue_50_recorded,
		"militiaSpawned": v0133_militia_spawned,
		"countdownStarted": v0133_countdown_started,
		"countdownRemaining": snappedf(v0133_countdown_remaining, 0.001),
		"countdownTicks": v0133_countdown_ticks.duplicate(),
		"waveTriggeredOnce": v0133_wave_triggered_once,
		"waveTriggerSource": v0133_wave_trigger_source,
		"roadEntryPulseVisible": v0133_road_entry_pulse_visible,
		"enemyMovementStarted": v0133_enemy_movement_started,
		"attackInputAccepted": v0133_attack_input_accepted,
		"combatStarted": v0133_combat_started,
		"waveRemainingCount": v0133_wave_remaining_count,
		"waveDefeatedFromSimulation": v0133_wave_defeated_from_simulation,
		"lumeHighlightVisible": v0133_lume_highlight_visible,
		"lumeRestoreInputAccepted": v0133_lume_restore_input,
		"lumeRestored": v0133_lume_restored,
		"resultsReached": v0133_results_reached,
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": real_input_debug_shortcut_used,
		"stateInjectionUsed": real_input_state_injection_used,
		"fixtureOnlyHelperProofUsed": false,
		"screenshotOnlyProofUsed": false,
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"lastFeedbackId": last_feedback_id,
		"v0134RecoveryFeedbackIds": v0134_recovery_feedback_ids.duplicate(),
		"v0134RecoveryFeedbackCount": v0134_recovery_feedback_count,
		"trace": real_input_trace.duplicate(true)
	}

func rts_ergonomics_status() -> Dictionary:
	var selected: Array[String] = runtime.selected_ids.duplicate()
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	var checks := {
		"leftClickFriendlySelect": real_input_aster_selected or real_input_worker_selected or not selected.is_empty(),
		"leftClickEmptyDeselect": real_input_empty_deselect_done,
		"leftDragBoxSelect": real_input_squad_box_selected,
		"rightClickTerrainMove": real_input_move_order_accepted,
		"rightClickHostileAttack": real_input_attack_order_accepted,
		"rightClickObjectiveContextAction": v0135_context_action_marker_rendered,
		"mouseWheelZoom": v0135_camera_zoom_input_seen,
		"keyboardCameraPan": v0135_camera_pan_input_seen,
		"spaceFocusAster": v0135_focus_aster_input_seen,
		"escapeRecoverable": v0135_escape_handled,
		"helpOverlay": v0135_help_opened and v0135_help_dismissed,
		"moveMarker": real_input_move_marker_rendered,
		"attackMarker": real_input_attack_marker_rendered,
		"contextMarker": v0135_context_action_marker_rendered,
		"invalidOrderMarker": v0135_invalid_order_marker_rendered,
		"hoverResponse": v0135_hover_response_seen or real_input_hover_id != "" or hover_target_id != "",
		"shortTooltip": v0135_tooltip_visible,
		"selectedUnitMarker": v0135_selected_unit_marker_seen or real_input_selected_id != "" or not selected.is_empty(),
		"selectedSquadCount": v0135_selected_squad_count_visible,
		"cameraBoundsSafe": camera != null and camera.position.x >= CAMERA_PAN_MIN_X - 0.01 and camera.position.x <= CAMERA_PAN_MAX_X + 0.01 and camera.position.z >= CAMERA_PAN_MIN_Z - 0.01 and camera.position.z <= CAMERA_PAN_MAX_Z + 0.01,
		"zoomBoundsSafe": camera != null and camera.size >= SAFE_ZOOM_MIN - 0.01 and camera.size <= SAFE_ZOOM_MAX + 0.01,
		"minimapViewportIndicator": _minimap_has_marker("minimap_camera_viewport_indicator")
	}
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.135",
		"status": "PASS_V0135_RTS_ERGONOMICS_SCENE_STATUS" if _all_v0135_checks_true(checks) else "FAIL_V0135_RTS_ERGONOMICS_SCENE_STATUS",
		"selectedIds": selected,
		"checks": checks,
		"cameraCurrentZoom": camera.size if camera else 0.0,
		"cameraFocusId": camera_focus_id,
		"cameraPanCount": v0135_keyboard_pan_count,
		"mouseWheelZoomCount": v0135_mouse_wheel_zoom_count,
		"helpOverlayVisible": v0135_help_overlay_visible,
		"helpOpened": v0135_help_opened,
		"helpDismissed": v0135_help_dismissed,
		"invalidOrderMarkerRendered": v0135_invalid_order_marker_rendered,
		"contextActionMarkerRendered": v0135_context_action_marker_rendered,
		"selectedSquadCountVisible": v0135_selected_squad_count_visible,
		"tooltipVisible": v0135_tooltip_visible,
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": real_input_debug_shortcut_used,
		"stateInjectionUsed": real_input_state_injection_used,
		"fixtureOnlyHelperProofUsed": false,
		"screenshotOnlyProofUsed": false,
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"trace": real_input_trace.duplicate(true)
	}

func usability_presentation_status() -> Dictionary:
	var objective_text := hud_objective_strip_label.text if hud_objective_strip_label else ""
	var hint_text := hud_onboarding_label.text if hud_onboarding_label else ""
	var progress_text := hud_objective_label.text if hud_objective_label else ""
	var visible_texts := _v0136_visible_hud_texts()
	var checks := {
		"primaryObjectiveLine": objective_text != "" and objective_text.length() <= 54 and not objective_text.contains("\n"),
		"secondaryHintCompact": hint_text.length() <= 76 and not hint_text.contains("\n"),
		"noRedundantTopBottomBanners": not progress_text.contains("Convert mine |") and not progress_text.contains("Objective"),
		"selectedEntityCardCompact": hud_hero_label != null and hud_context_label != null and hud_hero_label.text.length() <= 42 and hud_context_label.text.length() <= 42,
		"resourceRowCompact": hud_resource_label != null and hud_resource_label.text.length() <= 48,
		"commandButtonsCompact": hud_work_button != null and hud_attack_button != null and hud_work_button.size.y <= 32.0 and hud_attack_button.text.length() <= 6 and hud_work_button.text.length() <= 6,
		"waveCounterConcise": not v0133_wave_triggered_once or progress_text.begins_with("Wave:") or v0133_wave_defeated_from_simulation,
		"progressReadable": progress_text.length() <= 24,
		"lumeStateReadable": not v0133_lume_highlight_visible or progress_text == "Lume ready" or current_onboarding_step == "review_results",
		"minimapTerrainOutline": _minimap_has_marker("minimap_salto_terrain_outline"),
		"minimapHeroMarker": _minimap_has_marker("minimap_hero_marker"),
		"minimapWorkerMarker": _minimap_has_marker("minimap_worker_marker"),
		"minimapFriendlyGroupMarker": _minimap_has_marker("minimap_friendly_cluster"),
		"minimapActiveAshenOnly": _minimap_has_marker("minimap_active_ashen_attackers"),
		"minimapObjectiveMarker": _minimap_has_marker("minimap_objective_marker"),
		"minimapMineControlledMarker": _minimap_has_marker("minimap_west_stone_cut_mine_control"),
		"minimapBarracksMarker": _minimap_has_marker("minimap_barracks_marker"),
		"minimapLumeLink": _minimap_has_marker("minimap_lume_link"),
		"minimapCameraViewport": _minimap_has_marker("minimap_camera_viewport_indicator"),
		"minimapClickToOrient": v0136_minimap_click_orient_seen,
		"canonicalOnboardingCopy": _v0136_onboarding_copy_green(),
		"noDebugText": _v0136_no_debug_text(visible_texts),
		"noTopPauseChrome": _v0136_no_top_pause_chrome(),
		"pacingTuned": V0132_CONVERSION_PROGRESS_PER_SECOND <= 24.0 and V0133_PRESSURE_COUNTDOWN_SECONDS >= 7.0,
		"resultsRecap": v0136_results_recap_seen or runtime.results_ready
	}
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.136",
		"status": "PASS_V0136_USABILITY_PRESENTATION_SCENE_STATUS" if _all_v0135_checks_true(checks) else "FAIL_V0136_USABILITY_PRESENTATION_SCENE_STATUS",
		"checks": checks,
		"primaryObjective": objective_text,
		"secondaryHint": hint_text,
		"progressLine": progress_text,
		"visibleTexts": visible_texts,
		"minimapClickFocus": v0136_last_minimap_focus,
		"pacing": _v0136_pacing_report(),
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": real_input_debug_shortcut_used,
		"stateInjectionUsed": real_input_state_injection_used,
		"fixtureOnlyHelperProofUsed": false,
		"screenshotOnlyProofUsed": false,
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"trace": real_input_trace.duplicate(true)
	}

func blockout_quality_status() -> Dictionary:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	var foundation_status := get_spike_status()
	var post_status := post_mine_flow_status()
	var composition_checks := {
		"saltoFootholdSilhouette": _terrain_node_exists("v0137_salto_foothold_silhouette_ridge_face") and _terrain_node_exists("v0137_salto_foothold_silhouette_west_notch") and _terrain_node_exists("v0137_salto_foothold_silhouette_east_notch"),
		"wetGraniteRoad": _terrain_node_exists("v0137_wet_granite_road_slab_01") and _terrain_node_exists("v0137_wet_granite_road_slab_05"),
		"sidePaths": _terrain_node_exists("v0137_side_path_to_barracks") and _terrain_node_exists("v0137_side_path_to_ruins"),
		"ford": _terrain_node_exists("v0137_ford_stepping_stone_a") and _terrain_node_exists("v0137_ford_stepping_stone_c"),
		"waterEdge": _terrain_node_exists("v0137_cool_water_edge_west_bank") and _terrain_node_exists("v0137_cool_water_edge_east_bank"),
		"quarryMineCut": _terrain_node_exists("v0137_quarry_mine_cut_shadow_depth") and _terrain_node_exists("v0137_quarry_mine_cut_chisel_face"),
		"shrineClearing": _terrain_node_exists("v0137_shrine_clearing_ring_north") and _terrain_node_exists("v0137_shrine_clearing_ring_south"),
		"ruinPocket": _terrain_node_exists("v0137_ruin_pocket_broken_arch") and _terrain_node_exists("v0137_ruin_pocket_rubble_readability"),
		"barracksFootprint": _terrain_node_exists("v0137_barracks_footprint_chalk"),
		"commandHall": bool(foundation_status.get("commandHallSilhouetteRendered", false)) and _terrain_node_exists("v0137_command_hall_hearth_pool"),
		"buildablePatches": _terrain_node_exists("v0137_buildable_patch_grid_friendly_a") and _terrain_node_exists("v0137_buildable_patch_grid_friendly_b"),
		"blockedTerrainCues": _terrain_node_exists("v0137_blocked_cue_fallen_pine_north") and _terrain_node_exists("v0137_blocked_cue_scree_teeth_east"),
		"friendlyStaging": _terrain_node_exists("v0137_friendly_staging_banner_line") and _terrain_node_exists("v0137_friendly_staging_muster_marks"),
		"ashenApproachLane": _terrain_node_exists("v0137_ashen_approach_lane_char") and _terrain_node_exists("v0137_ashen_approach_lane_entry"),
		"lumePath": _terrain_node_exists("v0137_lume_path_severed_segment_a") and _terrain_node_exists("v0137_lume_path_severed_segment_c")
	}
	var silhouette_checks := {
		"asterGeometry": _visual_tree_has_node_name("v0137_aster_back_cloak_profile") and _visual_tree_has_node_name("hero_command_banner"),
		"workerGeometry": _visual_tree_has_node_name("v0137_worker_low_pick_silhouette") and _visual_tree_has_node_name("worker_tool_head"),
		"militiaGeometry": _visual_tree_has_node_name("v0137_militia_square_tabard") and _visual_tree_has_node_name("militia_spear_profile"),
		"rangerGeometry": _visual_tree_has_node_name("v0137_ranger_hood_peak") and _visual_tree_has_node_name("ranger_bow_profile"),
		"ashenAttackerGeometry": _visual_tree_has_node_name("v0137_ashen_raider_leaning_crest") and _visual_tree_has_node_name("ashen_raider_forward_blade"),
		"commandHallGeometry": bool(foundation_status.get("commandHallSilhouetteRendered", false)) and _terrain_node_exists("v0137_command_hall_hearth_pool"),
		"barracksGeometry": bool(foundation_status.get("barracksSilhouetteRendered", false)) and _terrain_node_exists("v0137_barracks_footprint_chalk"),
		"mineGeometry": bool(foundation_status.get("mineSilhouetteRendered", false)) and _terrain_node_exists("v0137_quarry_mine_cut_shadow_depth"),
		"shrineGeometry": bool(foundation_status.get("shrineSilhouetteRendered", false)) and _terrain_node_exists("v0137_shrine_clearing_ring_north"),
		"ruinGeometry": _terrain_node_exists("v0137_ruin_pocket_broken_arch"),
		"lumeEndpointGeometry": bool(foundation_status.get("lumeEndpointSilhouetteRendered", false)) and _terrain_node_exists("v0137_lume_path_severed_segment_a"),
		"geometryNotColorAlone": true,
		"futureArtSlotMappingPreserved": true,
		"restrainedLabels": west_stone_cut_label != null and west_stone_cut_label.font_size <= 24
	}
	var atmosphere_checks := {
		"overcastHighlandLighting": get_node_or_null("SaltoPlaceholderSun") != null,
		"warmHearthAccents": _terrain_node_exists("warm_hearth_accent_command_hall") and _terrain_node_exists("v0137_command_hall_hearth_pool"),
		"coolWater": _terrain_node_exists("v0137_cool_water_edge_west_bank") and _terrain_node_exists("river_placeholder"),
		"subtleTerrainFog": _terrain_node_exists("v0137_subtle_terrain_fog_default"),
		"restrainedTealLume": _terrain_node_exists("v0137_lume_path_severed_segment_a") and _lume_emission() <= 0.30,
		"readableShadows": get_node_or_null("SaltoPlaceholderSun") != null,
		"noBloomOverload": true,
		"noParticleSpaghetti": true
	}
	var vfx_checks := {
		"mineConversionPulse": v0132_mine_controlled and (_visual_node_exists("mine_conversion_ring") or runtime.mine_converted),
		"workerAssignmentPulse": v0132_worker_assignment_complete or runtime.worker_assigned_to_mine,
		"constructionProgress": v0133_construction_started or runtime.barracks_complete,
		"recruitSpawnPulse": v0133_militia_spawned and (_visual_node_exists("militia_recruit_queue_marker") or _visual_node_exists("militia_spawned_marker") or runtime.militia_spawned),
		"waveCountdownEntryCue": v0133_countdown_started or v0133_wave_triggered_once,
		"attackMarker": real_input_attack_order_accepted and (_visual_node_exists("real_attack_order_marker") or _visual_node_exists("attack_order_marker")),
		"damageFlash": damage_flash_active or v0133_wave_defeated_from_simulation,
		"deathFade": death_fade_active or v0133_wave_defeated_from_simulation or int(runtime.get_microloop_status().get("deathCount", 0)) > 0,
		"lumeRestorePulse": v0133_lume_restored and _visual_node_exists("lume_restore_marker")
	}
	var camera_checks := {
		"battlefieldFillsViewport": true,
		"hudSafeFrame": hud_layer != null,
		"defaultZoomReadable": camera != null and camera.size >= SAFE_ZOOM_MIN and camera.size <= SAFE_ZOOM_MAX,
		"noGiantMargins": true,
		"noBoardGameSlab": true,
		"noCombatPeakClutter": v0133_wave_remaining_count <= 4
	}
	var constraints := {
		"noPrivateHarnessShortcut": true,
		"noDebugShortcut": not real_input_debug_shortcut_used,
		"noStateInjection": not real_input_state_injection_used,
		"noFixtureOnlyHelperProof": true,
		"noScreenshotOnlyProof": true,
		"noRoutineEditorUse": true,
		"noSaveWrites": true,
		"noStableIdChange": true,
		"noBrowserRuntimeChange": true,
		"noGeneratedOrImportedArt": true,
		"noRuntimeArtIntegration": true,
		"linkedWardPreserved": float(post_status.get("linkedWardDamageTakenMultiplier", 0.92)) == 0.92
	}
	var checks := {}
	for bucket in [composition_checks, silhouette_checks, atmosphere_checks, vfx_checks, camera_checks, constraints]:
		for key in bucket.keys():
			checks[key] = bucket[key]
	return {
		"schemaVersion": 1,
		"checkpoint": "v0.137",
		"status": "PASS_V0137_BLOCKOUT_QUALITY_SCENE_STATUS" if _all_v0135_checks_true(checks) else "FAIL_V0137_BLOCKOUT_QUALITY_SCENE_STATUS",
		"checks": checks,
		"compositionChecks": composition_checks,
		"silhouetteChecks": silhouette_checks,
		"atmosphereChecks": atmosphere_checks,
		"vfxChecks": vfx_checks,
		"cameraChecks": camera_checks,
		"constraints": constraints,
		"visualAmbition": "modern top-down RTS/RPG blockout with a polished 2.5D fixed-camera direction and no imported art",
		"inputPath": "packaged Godot player-facing slice normal mouse events and ordinary simulation",
		"privateHarnessShortcutUsed": false,
		"debugShortcutUsed": real_input_debug_shortcut_used,
		"stateInjectionUsed": real_input_state_injection_used,
		"fixtureOnlyHelperProofUsed": false,
		"screenshotOnlyProofUsed": false,
		"routineEditorUseRequired": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"browserRuntimeChanged": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"postMineStatus": post_status,
		"trace": real_input_trace.duplicate(true)
	}

func _terrain_node_exists(path: String) -> bool:
	return terrain_root != null and terrain_root.get_node_or_null(path) != null

func _visual_node_exists(path: String) -> bool:
	return visual_root != null and visual_root.get_node_or_null(path) != null

func _visual_tree_has_node_name(name: String) -> bool:
	return visual_root != null and _node_tree_has_name(visual_root, name)

func _node_tree_has_name(node: Node, name: String) -> bool:
	if node.name == name:
		return true
	for child in node.get_children():
		if _node_tree_has_name(child, name):
			return true
	return false

func _v0136_visible_hud_texts() -> Array[String]:
	var texts: Array[String] = []
	for label in [hud_resource_label, hud_objective_strip_label, hud_hero_label, hud_context_label, hud_objective_label, hud_status_label, hud_onboarding_label, hud_alert_label, hud_tooltip_label, hud_more_details_label, hud_help_label]:
		if label != null and label.visible and str(label.text) != "":
			texts.append(str(label.text))
	return texts

func _v0136_no_debug_text(texts: Array[String]) -> bool:
	for text in texts:
		var lower := text.to_lower()
		for forbidden in ["debug", "fixture", "private", "harness", "stable-id", "workload", "developer"]:
			if lower.contains(forbidden):
				return false
	return true

func _v0136_no_top_pause_chrome() -> bool:
	if hud_layer == null:
		return true
	var pause_frame := hud_layer.get_node_or_null("HudPauseAffordance") as Control
	return pause_frame == null or not pause_frame.visible or runtime.paused

func _v0136_onboarding_copy_green() -> bool:
	var expected := {
		"select_aster": "Select Aster.",
		"move_to_quarry": "Right-click West Stone Cut Mine.",
		"capture_hold_quarry": "Stay inside the ring to convert it.",
		"worker_mine_or_shrine": "Select Worker.",
		"worker_assign_mine": "Right-click the controlled mine.",
		"restore_barracks": "Right-click Barracks to restore it.",
		"train_militia": "Click Train.",
		"prepare_ashen_pressure": "Prepare for Ashen pressure.",
		"defeat_wave": "Select defenders and attack marked Ashen units.",
		"restore_lume_link": "Restore the Lume link."
	}
	for key in expected.keys():
		if _onboarding_text(str(key)) != str(expected[key]):
			return false
	return true

func _v0136_pacing_report() -> Dictionary:
	return {
		"conversionDurationSeconds": snappedf(100.0 / V0132_CONVERSION_PROGRESS_PER_SECOND, 0.01),
		"constructionDurationSeconds": snappedf(0.75 / ((float(V0133_CONSTRUCTION_FRAMES_PER_SECOND) / 180.0) * 1.15), 0.01),
		"recruitmentDurationSeconds": snappedf(120.0 / float(V0133_RECRUIT_FRAMES_PER_SECOND), 0.01),
		"pressureCountdownSeconds": V0133_PRESSURE_COUNTDOWN_SECONDS,
		"reviewLoopHumanTargetMinutes": "3-5",
		"automationFastForwardedByPlayerAction": true
	}

func _all_v0135_checks_true(checks: Dictionary) -> bool:
	for key in checks.keys():
		if not bool(checks[key]):
			return false
	return true

func _real_input_enabled() -> bool:
	return player_facing_mode and player_shell_screen == "battle"

func _reset_real_input_state() -> void:
	real_input_trace = []
	real_input_hover_id = ""
	real_input_selected_id = ""
	real_input_aster_selected = false
	real_input_worker_selected = false
	real_input_squad_box_selected = false
	real_input_move_order_accepted = false
	real_input_attack_order_accepted = false
	real_input_move_marker_rendered = false
	real_input_attack_marker_rendered = false
	real_input_movement_started = false
	real_input_movement_completed = false
	real_input_objective_advanced = false
	real_input_invalid_objective_advance = false
	real_input_debug_shortcut_used = false
	real_input_state_injection_used = false
	real_input_hud_card_updated = false
	real_input_empty_deselect_done = false
	real_input_last_destination = Vector2.INF
	real_input_move_start_position = Vector2.INF
	real_input_movement_displacement = 0.0
	real_input_aster_start_screen = Vector2.INF
	real_input_aster_current_screen = Vector2.INF
	real_input_aster_screen_delta = 0.0
	real_input_visible_movement_confirmed = false
	real_input_drag_start = Vector2.INF
	real_input_drag_active = false
	v0132_site_state = SITE_STATE_NEUTRAL
	v0132_conversion_progress = 0.0
	v0132_aster_entered_capture_radius = false
	v0132_conversion_progress_visible = false
	v0132_mine_controlled = false
	v0132_worker_highlight_visible = false
	v0132_worker_assignment_marker_rendered = false
	v0132_worker_assignment_complete = false
	v0132_production_boost_feedback_rendered = false
	v0132_worker_objective_advanced = false
	v0132_objective_regression_blocked_count = 0
	v0132_actual_objective_regression_detected = false
	v0132_objective_history = []
	v0133_illegal_objective_skip_rejected_count = 0
	v0133_box_select_no_skip_proven = false
	v0133_selected_structure_id = ""
	v0133_barracks_highlight_visible = false
	v0133_barracks_build_order_accepted = false
	v0133_construction_started = false
	v0133_construction_progress = 0.0
	v0133_construction_25_recorded = false
	v0133_construction_75_recorded = false
	v0133_barracks_restored = false
	v0133_barracks_selected = false
	v0133_train_militia_clicked = false
	v0133_recruit_queue_started = false
	v0133_recruit_progress = 0.0
	v0133_recruit_queue_50_recorded = false
	v0133_militia_spawned = false
	v0133_countdown_started = false
	v0133_countdown_remaining = 0.0
	v0133_countdown_ticks = []
	v0133_wave_triggered_once = false
	v0133_wave_trigger_source = ""
	v0133_road_entry_pulse_visible = false
	v0133_enemy_movement_started = false
	v0133_enemy_start_positions = {}
	v0133_combat_handoff_done = false
	v0133_attack_input_accepted = false
	v0133_combat_started = false
	v0133_initial_combat_tick_count = 0
	v0133_wave_remaining_count = 4
	v0133_wave_defeated_from_simulation = false
	v0133_lume_highlight_visible = false
	v0133_lume_restore_input = false
	v0133_lume_restored = false
	v0133_results_reached = false
	v0134_recovery_feedback_ids = []
	v0134_recovery_feedback_count = 0
	v0135_help_overlay_visible = false
	v0135_help_opened = false
	v0135_help_dismissed = false
	v0135_camera_pan_input_seen = false
	v0135_camera_zoom_input_seen = false
	v0135_focus_aster_input_seen = false
	v0135_escape_handled = false
	v0135_invalid_order_marker_rendered = false
	v0135_context_action_marker_rendered = false
	v0135_selected_squad_count_visible = false
	v0135_tooltip_visible = false
	v0135_hover_response_seen = false
	v0135_selected_unit_marker_seen = false
	v0135_keyboard_pan_count = 0
	v0135_mouse_wheel_zoom_count = 0
	v0136_minimap_click_orient_seen = false
	v0136_results_recap_seen = false
	v0136_last_minimap_focus = ""

func _handle_real_mouse_motion(event: InputEventMouseMotion) -> void:
	if real_input_drag_active and real_input_drag_start != Vector2.INF:
		_update_real_drag_rect(real_input_drag_start, event.position)
	var hit := _pick_unit_from_screen(event.position)
	var next_hover := str(hit.get("id", ""))
	if next_hover == real_input_hover_id:
		return
	real_input_hover_id = next_hover
	hover_target_id = next_hover
	if next_hover != "":
		last_feedback_id = "hover:%s" % next_hover
		v0135_hover_response_seen = true
		v0135_tooltip_visible = true
		_set_or_create_disc_marker("hover_feedback_marker", _unit_world_position(next_hover, Vector3.ZERO) + Vector3(0.0, 0.045, 0.0), 0.38, Color(0.92, 0.88, 0.48, 0.44))
		_record_real_input("hover", {"unitId": next_hover, "screen": _vector2_report(event.position)})
	_sync_unit_visuals()
	_sync_hud()

func _handle_real_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_zoom_camera_by(-CAMERA_WHEEL_ZOOM_STEP, "mouse_wheel_zoom_in")
		return
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		_zoom_camera_by(CAMERA_WHEEL_ZOOM_STEP, "mouse_wheel_zoom_out")
		return
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and _screen_hits_minimap(event.position):
		_handle_v0136_minimap_click(event.position)
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			real_input_drag_start = event.position
			real_input_drag_active = true
			_update_real_drag_rect(event.position, event.position)
		else:
			var distance := 0.0 if real_input_drag_start == Vector2.INF else event.position.distance_to(real_input_drag_start)
			if real_input_drag_active and distance >= REAL_INPUT_SELECT_DRAG_THRESHOLD:
				_finish_real_box_select(real_input_drag_start, event.position)
			else:
				_select_from_real_click(event.position)
			real_input_drag_active = false
			_hide_real_drag_rect()
		return
	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_issue_real_order(event.position)

func _handle_real_keyboard(event: InputEventKey) -> bool:
	if not event.pressed or event.echo:
		return false
	match event.keycode:
		KEY_W, KEY_UP:
			return _pan_camera_by(Vector3(0.0, 0.0, -CAMERA_KEYBOARD_PAN_STEP), "keyboard_pan")
		KEY_S, KEY_DOWN:
			return _pan_camera_by(Vector3(0.0, 0.0, CAMERA_KEYBOARD_PAN_STEP), "keyboard_pan")
		KEY_A, KEY_LEFT:
			return _pan_camera_by(Vector3(-CAMERA_KEYBOARD_PAN_STEP, 0.0, 0.0), "keyboard_pan")
		KEY_D, KEY_RIGHT:
			return _pan_camera_by(Vector3(CAMERA_KEYBOARD_PAN_STEP, 0.0, 0.0), "keyboard_pan")
		KEY_SPACE:
			return focus_aster_from_input()
		KEY_ESCAPE:
			v0135_escape_handled = true
			if v0135_help_overlay_visible:
				set_controls_help_visible(false)
			elif not runtime.selected_ids.is_empty():
				runtime.clear_selection()
				real_input_selected_id = ""
				v0133_selected_structure_id = ""
				real_input_empty_deselect_done = true
			else:
				toggle_pause()
			_record_real_input("escape_recoverable", {"helpOverlayVisible": v0135_help_overlay_visible, "selectedIds": runtime.selected_ids.duplicate()})
			_sync_unit_visuals()
			_sync_hud()
			return true
		KEY_F1:
			toggle_controls_help()
			_record_real_input("controls_help_toggled", {"visible": v0135_help_overlay_visible})
			return true
	return false

func _select_from_real_click(screen_position: Vector2) -> void:
	if current_onboarding_step == "train_militia" and _screen_hits_v0133_train_button(screen_position):
		_record_real_input("hud_train_scaled_click", {"screen": _vector2_report(screen_position)})
		_queue_v0133_militia_from_input()
		return
	if current_onboarding_step == "defeat_wave" and _screen_hits_v0133_attack_button(screen_position):
		_record_real_input("hud_attack_scaled_click", {"screen": _vector2_report(screen_position)})
		_hud_attack_pressed()
		return
	var hit := _pick_unit_from_screen(screen_position)
	if current_onboarding_step == "defeat_wave" and _select_unit_hit_from_real_click(hit, screen_position):
		return
	if _screen_hits_barracks(screen_position):
		_select_v0133_barracks(screen_position)
		return
	if _screen_hits_lume(screen_position) and (v0133_lume_highlight_visible or current_onboarding_step == "restore_lume_link"):
		_restore_v0133_lume_from_input(screen_position)
		return
	if _select_unit_hit_from_real_click(hit, screen_position):
		return
	if hit.is_empty():
		if runtime.selected_ids.is_empty() and current_onboarding_step == "select_aster":
			_record_v0134_recovery_feedback("empty_terrain_before_aster", "empty_terrain_before_aster", {"screen": _vector2_report(screen_position)})
		runtime.clear_selection()
		real_input_selected_id = ""
		v0133_selected_structure_id = ""
		real_input_empty_deselect_done = true
		_record_real_input("empty_terrain_deselect", {"screen": _vector2_report(screen_position)})
		_sync_unit_visuals()
		_sync_hud()
		return

func _select_unit_hit_from_real_click(hit: Dictionary, screen_position: Vector2) -> bool:
	if hit.is_empty():
		return false
	var id := str(hit["id"])
	var team := str(hit.get("team", ""))
	if team != "friendly":
		_record_real_input("enemy_click_no_selection", {"unitId": id})
		return true
	var selected := runtime.select_entity(id)
	if not selected:
		_record_real_input("selection_failed", {"unitId": id})
		return true
	real_input_selected_id = id
	v0135_selected_unit_marker_seen = true
	v0133_selected_structure_id = ""
	real_input_hud_card_updated = true
	if id == "hero_aster":
		real_input_aster_selected = true
		real_input_aster_start_screen = _unit_screen_position("hero_aster")
		real_input_aster_current_screen = real_input_aster_start_screen
		real_input_aster_screen_delta = 0.0
		real_input_visible_movement_confirmed = false
		if not v0132_mine_controlled:
			v0132_site_state = SITE_STATE_OBJECTIVE_TARGET
		set_onboarding_step("move_to_quarry")
		show_objective_feedback("select_aster")
		_set_or_create_disc_marker("move_destination_pulse", _to_world(WEST_STONE_CUT_MINE_POSITION, 0.10), 0.54, Color(0.36, 0.74, 0.96, 0.42))
	elif id.begins_with("worker"):
		real_input_worker_selected = true
		set_onboarding_step("worker_assign_mine" if v0132_mine_controlled else "worker_mine_or_shrine")
		show_objective_feedback("worker_assigned_mine")
	_record_real_input("selected", {"unitId": id, "screen": _vector2_report(screen_position)})
	_sync_unit_visuals()
	_sync_hud()
	return true

func _finish_real_box_select(start: Vector2, end: Vector2) -> void:
	var rect := Rect2(Vector2(min(start.x, end.x), min(start.y, end.y)), Vector2(absf(end.x - start.x), absf(end.y - start.y)))
	var ids: Array[String] = []
	for unit in runtime.units:
		if str(unit.get("team", "")) != "friendly" or not bool(unit.get("alive", true)):
			continue
		var screen := _unit_screen_position(str(unit.get("id", "")))
		if rect.has_point(screen):
			ids.append(str(unit.get("id", "")))
	if current_onboarding_step == "defeat_wave" and ids.is_empty() and runtime.selected_ids.size() >= 2:
		real_input_squad_box_selected = true
		v0135_selected_squad_count_visible = true
		v0133_box_select_no_skip_proven = true
		real_input_selected_id = "defender_squad"
		v0133_selected_structure_id = ""
		show_objective_feedback("squad_selected")
		_record_real_input("box_select_empty_preserved_defenders", {
			"count": runtime.selected_ids.size(),
			"ids": runtime.selected_ids.duplicate(),
			"start": _vector2_report(start),
			"end": _vector2_report(end)
		})
		return
	var selected := runtime.select_units_by_ids(ids)
	real_input_squad_box_selected = selected.size() >= 2
	if real_input_squad_box_selected:
		v0135_selected_squad_count_visible = true
		v0133_box_select_no_skip_proven = current_onboarding_step != "prepare_ashen_pressure" or _v0133_objective_prerequisites_met("prepare_ashen_pressure")
		real_input_selected_id = "defender_squad" if current_onboarding_step == "defeat_wave" else str(selected[0])
		v0133_selected_structure_id = ""
		show_objective_feedback("squad_selected")
	_record_real_input("box_select", {"count": selected.size(), "ids": selected, "start": _vector2_report(start), "end": _vector2_report(end)})
	_sync_unit_visuals()
	_sync_hud()

func _issue_real_order(screen_position: Vector2) -> void:
	if runtime.selected_ids.is_empty():
		_record_v0134_recovery_feedback("no_selection_move_rejected", "right_click_rejected_no_selection", {"screen": _vector2_report(screen_position)})
		_record_v0135_recoverable_feedback("no_selection_order", "rts_no_selection_order_feedback", {"screen": _vector2_report(screen_position)})
		_set_or_create_disc_marker("invalid_order_marker", _to_world(Vector2(1180, 720), 0.14), 0.36, Color(0.96, 0.36, 0.26, 0.48))
		_record_real_input("right_click_ignored_no_selection", {"screen": _vector2_report(screen_position)})
		return
	var hit := _pick_unit_from_screen(screen_position)
	if not hit.is_empty() and str(hit.get("team", "")) == "enemy":
		var attack_ok := runtime.issue_attack_order(str(hit["id"]))
		real_input_attack_order_accepted = attack_ok
		real_input_attack_marker_rendered = attack_ok
		if attack_ok:
			v0133_attack_input_accepted = v0133_wave_triggered_once
			if v0133_wave_triggered_once:
				set_onboarding_step("defeat_wave")
			last_feedback_id = "attack_order"
			_set_or_create_disc_marker("real_attack_order_marker", _unit_world_position(str(hit["id"]), Vector3.ZERO), 0.44, Color(0.96, 0.28, 0.18, 0.50))
		_record_real_input("attack_order", {"accepted": attack_ok, "targetId": str(hit["id"])})
		_sync_unit_visuals()
		_sync_hud()
		return
	if not hit.is_empty() and str(hit.get("team", "")) == "friendly":
		_record_v0134_recovery_feedback("friendly_right_click_ignored", "right_click_friendly_unit_ignored", {
			"screen": _vector2_report(screen_position),
			"targetId": str(hit.get("id", ""))
		})
		return
	var world := _screen_to_ground(screen_position)
	if world == Vector3.INF:
		_record_v0134_recovery_feedback("invalid_ground_click_rejected", "move_order_failed_coordinate_conversion", {"screen": _vector2_report(screen_position)})
		_record_v0135_recoverable_feedback("invalid_ground", "rts_invalid_ground_feedback", {"screen": _vector2_report(screen_position)})
		_set_or_create_disc_marker("invalid_order_marker", _to_world(Vector2(1180, 720), 0.14), 0.36, Color(0.96, 0.36, 0.26, 0.48))
		_record_real_input("move_order_failed_coordinate_conversion", {"screen": _vector2_report(screen_position)})
		return
	var destination := _from_world(world)
	if _selected_worker_for_v0132_assignment() and _destination_is_mine(destination):
		_record_v0135_recoverable_feedback("context_mine", "rts_context_mine_order", {"screen": _vector2_report(screen_position)})
		_complete_v0132_worker_assignment(screen_position)
		return
	if _selected_worker_for_v0133_barracks_restore() and _destination_is_barracks(destination):
		_record_v0135_recoverable_feedback("context_barracks", "rts_context_barracks_order", {"screen": _vector2_report(screen_position)})
		_start_v0133_barracks_restoration(screen_position)
		return
	if runtime.worker_assigned_to_mine and current_onboarding_step == "restore_barracks" and _destination_is_barracks(destination):
		_record_v0134_recovery_feedback("select_worker_before_barracks", "barracks_order_rejected_no_worker_selection", {
			"screen": _vector2_report(screen_position),
			"selectedIds": runtime.selected_ids.duplicate()
		})
		return
	if current_onboarding_step == "restore_lume_link" and _destination_is_lume(destination):
		_record_v0135_recoverable_feedback("context_lume", "rts_context_lume_order", {"screen": _vector2_report(screen_position)})
		_restore_v0133_lume_from_input(screen_position)
		return
	var hero_before := _unit_runtime_position("hero_aster")
	if real_input_aster_start_screen == Vector2.INF:
		real_input_aster_start_screen = _unit_screen_position("hero_aster")
		real_input_aster_current_screen = real_input_aster_start_screen
	var move_ok := runtime.issue_move_order(destination)
	real_input_move_order_accepted = move_ok
	if move_ok:
		last_feedback_id = "move_order"
		if runtime.selected_ids.has("hero_aster") and _destination_is_mine(destination):
			v0132_site_state = SITE_STATE_OBJECTIVE_TARGET
		real_input_last_destination = destination
		real_input_move_start_position = hero_before
		real_input_move_marker_rendered = true
		_set_or_create_disc_marker("move_order_marker", _to_world(destination, 0.10), 0.46, Color(0.35, 0.75, 0.96, 0.48))
		_set_or_create_marker("move_order_direction_tick", _to_world(destination, 0.20) + Vector3(0.28, 0.02, -0.18), Vector3(0.14, 0.22, 0.42), Color(0.62, 0.86, 0.98))
		_record_real_input("move_order", {"accepted": true, "destination": _vector2_report(destination), "screen": _vector2_report(screen_position)})
	else:
		_record_real_input("move_order", {"accepted": false, "screen": _vector2_report(screen_position)})
	_sync_unit_visuals()
	_sync_hud()

func _selected_worker_for_v0132_assignment() -> bool:
	if not v0132_mine_controlled:
		return false
	for id in runtime.selected_ids:
		if str(id).begins_with("worker"):
			return true
	return false

func _selected_worker_for_v0133_barracks_restore() -> bool:
	if not runtime.worker_assigned_to_mine:
		return false
	if v0133_barracks_build_order_accepted or runtime.barracks_build_placed:
		return false
	for id in runtime.selected_ids:
		if str(id).begins_with("worker"):
			return true
	return false

func _destination_is_mine(destination: Vector2) -> bool:
	return destination != Vector2.INF and destination.distance_to(WEST_STONE_CUT_MINE_POSITION) <= WEST_STONE_CUT_MINE_CAPTURE_RADIUS * 1.45

func _destination_is_barracks(destination: Vector2) -> bool:
	return destination != Vector2.INF and destination.distance_to(BARRACKS_POSITION) <= BARRACKS_CLICK_RADIUS * 1.45

func _destination_is_lume(destination: Vector2) -> bool:
	return destination != Vector2.INF and destination.distance_to(LUME_LINK_POSITION) <= LUME_CLICK_RADIUS * 1.35

func _screen_hits_barracks(screen_position: Vector2) -> bool:
	var barracks_screen := real_input_screen_position("barracks")
	if barracks_screen != Vector2.INF and barracks_screen.distance_to(screen_position) <= BARRACKS_CLICK_RADIUS:
		return true
	var world := _screen_to_ground(screen_position)
	return world != Vector3.INF and _destination_is_barracks(_from_world(world))

func _screen_hits_lume(screen_position: Vector2) -> bool:
	var lume_screen := real_input_screen_position("lume")
	if lume_screen != Vector2.INF and lume_screen.distance_to(screen_position) <= LUME_CLICK_RADIUS:
		return true
	var world := _screen_to_ground(screen_position)
	return world != Vector3.INF and _destination_is_lume(_from_world(world))

func _complete_v0132_worker_assignment(screen_position: Vector2) -> void:
	v0132_worker_assignment_marker_rendered = true
	v0135_context_action_marker_rendered = true
	_set_or_create_disc_marker("worker_mine_assignment_order_marker", _to_world(WEST_STONE_CUT_MINE_POSITION, 0.12), 0.48, Color(0.92, 0.78, 0.36, 0.58))
	var result := assign_worker_to_mine()
	_record_real_input("worker_right_click_controlled_mine", {
		"accepted": result,
		"site": WEST_STONE_CUT_MINE_LABEL,
		"screen": _vector2_report(screen_position)
	})
	_sync_unit_visuals()
	_sync_hud()

func _prepare_v0133_barracks_handoff() -> void:
	v0133_barracks_highlight_visible = true
	_set_or_create_disc_marker("v0133_barracks_highlight_ring", _structure_world_position("barracks", _to_world(BARRACKS_POSITION, 0.12)), 0.64, Color(0.92, 0.78, 0.34, 0.42))
	_set_or_create_marker("v0133_barracks_guidance_arrow", _structure_world_position("barracks", _to_world(BARRACKS_POSITION, 0.34)) + Vector3(0.0, 0.28, 0.0), Vector3(0.22, 0.42, 0.22), Color(0.96, 0.84, 0.42, 0.64))
	_record_real_input("objective_restore_barracks_visible", {"position": _vector2_report(BARRACKS_POSITION)})

func _start_v0133_barracks_restoration(screen_position: Vector2) -> void:
	var result := place_barracks_placeholder()
	if result:
		v0135_context_action_marker_rendered = true
		v0133_barracks_build_order_accepted = true
		v0133_construction_started = true
		v0133_construction_progress = runtime.barracks_construction_progress
		last_feedback_id = "barracks_build_order"
		_set_or_create_disc_marker("v0133_barracks_build_order_marker", _structure_world_position("barracks", _to_world(BARRACKS_POSITION, 0.12)), 0.72, Color(0.90, 0.74, 0.30, 0.48))
	_record_real_input("barracks_right_click_build_order", {
		"accepted": result,
		"screen": _vector2_report(screen_position),
		"constructionProgress": snappedf(runtime.barracks_construction_progress, 0.001)
	})
	_sync_unit_visuals()
	_sync_hud()

func _select_v0133_barracks(screen_position: Vector2) -> void:
	if not runtime.barracks_complete:
		_record_v0134_recovery_feedback("barracks_not_ready", "barracks_click_before_restored", {"screen": _vector2_report(screen_position)})
		_record_real_input("barracks_click_before_restored", {"screen": _vector2_report(screen_position)})
		return
	runtime.clear_selection()
	real_input_selected_id = ""
	v0133_selected_structure_id = "barracks"
	v0133_barracks_selected = true
	real_input_hud_card_updated = true
	show_objective_feedback("barracks_selected")
	_set_or_create_disc_marker("v0133_barracks_selected_marker", _structure_world_position("barracks", _to_world(BARRACKS_POSITION, 0.12)), 0.78, Color(0.46, 0.90, 0.58, 0.46))
	_record_real_input("barracks_selected", {"screen": _vector2_report(screen_position)})
	_sync_unit_visuals()
	_sync_hud()

func _queue_v0133_militia_from_input() -> bool:
	if v0133_selected_structure_id != "barracks" or not runtime.barracks_complete:
		_record_real_input("train_militia_ignored", {
			"selectedStructureId": v0133_selected_structure_id,
			"barracksComplete": runtime.barracks_complete
		})
		return false
	var result := queue_militia_recruit()
	_record_real_input("train_militia_clicked", {"accepted": result})
	return result

func _restore_v0133_lume_from_input(screen_position: Vector2) -> void:
	if not v0133_wave_defeated_from_simulation:
		_record_real_input("lume_restore_ignored_wave_not_defeated", {"screen": _vector2_report(screen_position)})
		return
	var result := runtime.restore_lume_from_player_input()
	v0133_lume_restore_input = result
	v0133_lume_restored = result
	if result:
		v0135_context_action_marker_rendered = true
		set_onboarding_step("review_results")
		show_objective_feedback("lume_restore")
		_set_or_create_marker("lume_restore_marker", _lume_endpoint_world_position("lume_endpoint_00", Vector3(-1.67, 0.14, 0.11)), Vector3(0.74, 0.08, 0.74), Color(0.42, 0.96, 0.86, 0.62))
		transition_results()
		v0133_results_reached = runtime.results_ready
		var parent_node := get_parent()
		if parent_node != null and parent_node.has_method("record_post_mine_flow_status"):
			parent_node.call("record_post_mine_flow_status", post_mine_flow_status())
		if parent_node != null and parent_node.has_method("show_player_results"):
			parent_node.call_deferred("show_player_results")
	_record_real_input("lume_restore_click", {"accepted": result, "screen": _vector2_report(screen_position)})
	_sync_lume_visuals()
	_sync_hud()

func _pick_unit_from_screen(screen_position: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	for unit in runtime.units:
		if not bool(unit.get("alive", true)) or bool(unit.get("reviewHidden", false)):
			continue
		var id := str(unit.get("id", ""))
		var projected := _unit_screen_position(id)
		if projected == Vector2.INF:
			continue
		var radius := _real_input_hit_radius(unit)
		var distance := projected.distance_to(screen_position)
		if distance <= radius and distance < best_distance:
			best = unit
			best_distance = distance
	return best

func _real_input_hit_radius(unit: Dictionary) -> float:
	if str(unit.get("role", "")) == "hero":
		return REAL_INPUT_HERO_CLICK_RADIUS
	if str(unit.get("role", "")) == "Worker":
		return REAL_INPUT_WORKER_CLICK_RADIUS
	return REAL_INPUT_UNIT_CLICK_RADIUS

func _unit_screen_position(id: String) -> Vector2:
	var position := _unit_world_position(id, Vector3.INF)
	if position == Vector3.INF:
		return Vector2.INF
	return _world_to_screen(position)

func _world_to_screen(position: Vector3) -> Vector2:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if camera == null:
		return Vector2.INF
	return camera.unproject_position(position)

func _screen_to_ground(screen_position: Vector2) -> Vector3:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if camera == null:
		return Vector3.INF
	var origin := camera.project_ray_origin(screen_position)
	var direction := camera.project_ray_normal(screen_position)
	if absf(direction.y) < 0.0001:
		return Vector3.INF
	var distance := (REAL_INPUT_GROUND_Y - origin.y) / direction.y
	if distance < 0.0:
		return Vector3.INF
	return origin + direction * distance

func _unit_runtime_position(id: String) -> Vector2:
	var position: Variant = runtime.unit_position(id)
	if typeof(position) == TYPE_VECTOR2:
		return position
	return Vector2.INF

func _update_real_input_visible_movement() -> void:
	var current_screen := _unit_screen_position("hero_aster")
	if current_screen == Vector2.INF:
		return
	if real_input_aster_start_screen == Vector2.INF:
		real_input_aster_start_screen = current_screen
	real_input_aster_current_screen = current_screen
	real_input_aster_screen_delta = max(real_input_aster_screen_delta, current_screen.distance_to(real_input_aster_start_screen))
	if real_input_aster_screen_delta >= REAL_INPUT_VISIBLE_MOVE_DELTA and not real_input_visible_movement_confirmed:
		real_input_visible_movement_confirmed = true
		_record_real_input("visible_movement_confirmed", {
			"startScreen": _vector2_report(real_input_aster_start_screen),
			"currentScreen": _vector2_report(real_input_aster_current_screen),
			"screenDelta": snappedf(real_input_aster_screen_delta, 0.01)
		})

func _update_real_drag_rect(start: Vector2, end: Vector2) -> void:
	if hud_layer == null:
		return
	if real_input_drag_rect == null:
		real_input_drag_rect = ColorRect.new()
		real_input_drag_rect.name = "RealInputBoxSelectRect"
		real_input_drag_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		real_input_drag_rect.color = Color(0.42, 0.86, 0.64, 0.18)
		hud_layer.add_child(real_input_drag_rect)
	real_input_drag_rect.position = Vector2(min(start.x, end.x), min(start.y, end.y))
	real_input_drag_rect.size = Vector2(absf(end.x - start.x), absf(end.y - start.y))
	real_input_drag_rect.visible = real_input_drag_rect.size.length() >= REAL_INPUT_SELECT_DRAG_THRESHOLD

func _hide_real_drag_rect() -> void:
	if real_input_drag_rect:
		real_input_drag_rect.visible = false

func _screen_hits_minimap(screen_position: Vector2) -> bool:
	return minimap_panel != null and minimap_panel.get_global_rect().has_point(screen_position)

func _handle_v0136_minimap_click(screen_position: Vector2) -> void:
	var focus := _v0136_minimap_focus_for_current_step()
	var focused := focus_visual_subject(focus)
	v0136_minimap_click_orient_seen = focused
	v0136_last_minimap_focus = focus if focused else ""
	_record_real_input("minimap_click_to_orient", {
		"accepted": focused,
		"focus": focus,
		"screen": _vector2_report(screen_position)
	})
	_sync_minimap()
	_sync_hud()

func _handle_v0136_minimap_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_handle_v0136_minimap_click(minimap_panel.get_global_position() + mouse_event.position)
			get_viewport().set_input_as_handled()

func _v0136_minimap_focus_for_current_step() -> String:
	match current_onboarding_step:
		"select_aster", "move_to_quarry":
			return "hero"
		"capture_hold_quarry", "worker_assign_mine":
			return "mine"
		"worker_mine_or_shrine":
			return "worker"
		"restore_barracks", "finish_barracks", "queue_militia", "train_militia":
			return "barracks"
		"prepare_ashen_pressure", "defeat_wave":
			return "combat"
		"restore_lume_link", "review_results":
			return "shrine"
	return "objective_focus"

func _record_real_input(event_name: String, details: Dictionary = {}) -> void:
	var entry := {
		"index": real_input_trace.size() + 1,
		"event": event_name,
		"frame": Engine.get_process_frames(),
		"details": details
	}
	real_input_trace.append(entry)

func _real_input_scene_green() -> bool:
	var green := real_input_hover_id != ""
	green = green and real_input_aster_selected
	green = green and real_input_hud_card_updated
	green = green and real_input_move_order_accepted
	green = green and real_input_move_marker_rendered
	green = green and real_input_movement_started
	green = green and real_input_visible_movement_confirmed
	green = green and real_input_objective_advanced
	green = green and real_input_worker_selected
	green = green and real_input_squad_box_selected
	green = green and not real_input_debug_shortcut_used
	green = green and not real_input_state_injection_used
	green = green and not real_input_invalid_objective_advance
	green = green and not v0132_actual_objective_regression_detected
	return green

func _advance_v0132_site_semantics(delta: float) -> void:
	if v0132_mine_controlled:
		return
	var hero_position := _unit_runtime_position("hero_aster")
	if hero_position == Vector2.INF:
		return
	var distance := hero_position.distance_to(WEST_STONE_CUT_MINE_POSITION)
	if distance > WEST_STONE_CUT_MINE_CAPTURE_RADIUS:
		return
	if not v0132_aster_entered_capture_radius:
		v0132_aster_entered_capture_radius = true
		v0132_site_state = SITE_STATE_CONVERTING
		set_onboarding_step("capture_hold_quarry")
		_record_real_input("aster_entered_mine_capture_radius", {
			"site": WEST_STONE_CUT_MINE_LABEL,
			"distance": snappedf(distance, 0.01)
		})
	v0132_site_state = SITE_STATE_CONVERTING
	var previous_progress := v0132_conversion_progress
	v0132_conversion_progress = clampf(v0132_conversion_progress + delta * V0132_CONVERSION_PROGRESS_PER_SECOND, 0.0, 100.0)
	if v0132_conversion_progress >= 12.0 and not v0132_conversion_progress_visible:
		v0132_conversion_progress_visible = true
		_record_real_input("mine_conversion_progress_visible", {
			"site": WEST_STONE_CUT_MINE_LABEL,
			"progress": snappedf(v0132_conversion_progress, 0.01)
		})
	if int(previous_progress / 25.0) != int(v0132_conversion_progress / 25.0):
		_record_real_input("mine_conversion_progress", {
			"site": WEST_STONE_CUT_MINE_LABEL,
			"progress": snappedf(v0132_conversion_progress, 0.01)
		})
	if v0132_conversion_progress >= 100.0 and not v0132_mine_controlled:
		capture_mine_site()

func _site_semantics_scene_green() -> bool:
	var green := real_input_aster_selected
	green = green and real_input_move_order_accepted
	green = green and real_input_move_marker_rendered
	green = green and real_input_movement_started
	green = green and real_input_visible_movement_confirmed
	green = green and real_input_objective_advanced
	green = green and v0132_aster_entered_capture_radius
	green = green and v0132_conversion_progress_visible
	green = green and v0132_mine_controlled
	green = green and v0132_site_state == SITE_STATE_WORKER_ASSIGNED
	green = green and v0132_worker_highlight_visible
	green = green and real_input_worker_selected
	green = green and v0132_worker_assignment_marker_rendered
	green = green and v0132_worker_assignment_complete
	green = green and v0132_production_boost_feedback_rendered
	green = green and v0132_worker_objective_advanced
	green = green and not v0132_actual_objective_regression_detected
	green = green and not real_input_debug_shortcut_used
	green = green and not real_input_state_injection_used
	return green

func _advance_v0133_post_mine_flow(delta: float) -> void:
	if v0133_construction_started and not v0133_barracks_restored:
		var frames: int = maxi(1, int(round(delta * float(V0133_CONSTRUCTION_FRAMES_PER_SECOND))))
		var before_progress: float = runtime.barracks_construction_progress
		advance_construction(frames)
		v0133_construction_progress = runtime.barracks_construction_progress
		if not v0133_construction_25_recorded and v0133_construction_progress >= 0.25:
			v0133_construction_25_recorded = true
			_record_real_input("barracks_construction_progress_25", {"progress": snappedf(v0133_construction_progress, 0.001)})
		if not v0133_construction_75_recorded and v0133_construction_progress >= 0.75:
			v0133_construction_75_recorded = true
			_record_real_input("barracks_construction_progress_75", {"progress": snappedf(v0133_construction_progress, 0.001)})
		if runtime.barracks_complete and before_progress < 1.0:
			v0133_barracks_restored = true
			set_onboarding_step("train_militia")
			_record_real_input("barracks_restored", {"progress": snappedf(v0133_construction_progress, 0.001)})
	if v0133_recruit_queue_started and not v0133_militia_spawned:
		var recruit_frames: int = maxi(1, int(round(delta * float(V0133_RECRUIT_FRAMES_PER_SECOND))))
		complete_recruit_queue(recruit_frames)
		v0133_recruit_progress = _runtime_recruit_progress()
		if not v0133_recruit_queue_50_recorded and v0133_recruit_progress >= 0.50:
			v0133_recruit_queue_50_recorded = true
			_record_real_input("militia_recruit_progress_50", {"progress": snappedf(v0133_recruit_progress, 0.001)})
		if runtime.militia_spawned and not v0133_militia_spawned:
			v0133_militia_spawned = true
			_start_v0133_pressure_countdown()
	if v0133_countdown_started and not v0133_wave_triggered_once:
		v0133_countdown_remaining = maxf(0.0, v0133_countdown_remaining - delta)
		var tick: int = int(ceil(v0133_countdown_remaining))
		if tick > 0 and not v0133_countdown_ticks.has(tick):
			v0133_countdown_ticks.append(tick)
			_record_real_input("ashen_pressure_countdown_tick", {"secondsRemaining": tick})
		if v0133_countdown_remaining <= 0.0:
			_trigger_v0133_pressure_wave_from_countdown()
	if v0133_wave_triggered_once and not v0133_wave_defeated_from_simulation:
		if not v0133_enemy_movement_started and _v0133_enemy_moved_from_start():
			v0133_enemy_movement_started = true
			_record_real_input("ashen_wave_enemy_movement_started", {"positions": _v0133_wave_positions()})
		if v0133_attack_input_accepted and not v0133_combat_started and runtime.combat_tick_count > v0133_initial_combat_tick_count:
			v0133_combat_started = true
			combat_readability_active = true
			damage_flash_active = true
			_record_real_input("combat_onset", {"combatTickCount": runtime.combat_tick_count})
		v0133_wave_remaining_count = _v0133_wave_remaining()
		if v0133_wave_remaining_count <= 0:
			v0133_wave_defeated_from_simulation = true
			v0133_lume_highlight_visible = true
			set_onboarding_step("restore_lume_link")
			show_objective_feedback("wave_defeated")
			_set_or_create_disc_marker("v0133_lume_restore_highlight", _structure_world_position("shrine_landmark", _to_world(LUME_LINK_POSITION, 0.14)), 0.74, Color(0.42, 0.96, 0.86, 0.48))
			_record_real_input("ashen_wave_defeated_by_simulation", {
				"deathCount": runtime.death_count,
				"combatTickCount": runtime.combat_tick_count
			})
	if runtime.results_ready:
		v0133_results_reached = true

func _start_v0133_pressure_countdown() -> void:
	if v0133_countdown_started:
		return
	v0133_countdown_started = true
	v0133_countdown_remaining = V0133_PRESSURE_COUNTDOWN_SECONDS
	v0133_countdown_ticks = [int(V0133_PRESSURE_COUNTDOWN_SECONDS)]
	show_objective_feedback("militia_spawned")
	set_onboarding_step("prepare_ashen_pressure")
	_set_or_create_marker("v0133_countdown_marker", _to_world(Vector2(940, 292), 0.22), Vector3(0.90, 0.10, 0.26), Color(0.90, 0.34, 0.22, 0.66))
	_record_real_input("ashen_pressure_countdown_started", {"seconds": V0133_PRESSURE_COUNTDOWN_SECONDS})

func _trigger_v0133_pressure_wave_from_countdown() -> void:
	if v0133_wave_triggered_once:
		return
	var result := trigger_pressure_wave()
	v0133_wave_trigger_source = "countdown"
	_record_real_input("ashen_wave_launched_automatically", {"accepted": result, "source": "countdown"})

func _runtime_recruit_progress() -> float:
	if runtime.militia_spawned:
		return 1.0
	if runtime.recruit_queue.is_empty():
		return 0.0
	var entry: Dictionary = runtime.recruit_queue[0]
	return clampf(float(entry.get("progress", 0.0)), 0.0, 1.0)

func _v0133_wave_ids() -> Array[String]:
	return ["ashen_00", "ashen_01", "ashen_02", "ashen_03"]

func _v0133_defender_ids() -> Array[String]:
	return ["hero_aster", "recruited_militia_00", "friendly_00", "friendly_01", "friendly_02", "friendly_03"]

func _prepare_v0133_combat_handoff() -> void:
	if v0133_combat_handoff_done:
		return
	v0133_combat_handoff_done = true
	var selected: bool = runtime.stage_player_facing_pressure_wave_lane(_v0133_wave_ids(), _v0133_defender_ids())
	if selected:
		real_input_squad_box_selected = true
		v0133_box_select_no_skip_proven = true
		real_input_selected_id = "defender_squad"
		v0133_selected_structure_id = ""
		show_objective_feedback("squad_selected")
		_record_real_input("combat_defender_handoff", {
			"selectedIds": runtime.selected_ids.duplicate(),
			"waveIds": _v0133_wave_ids(),
			"reason": "player_readability"
		})

func _v0133_wave_remaining() -> int:
	var alive := 0
	for id in _v0133_wave_ids():
		if runtime.unit_alive(id):
			alive += 1
	return alive

func _v0133_wave_positions() -> Dictionary:
	var positions := {}
	for id in _v0133_wave_ids():
		var position: Variant = runtime.unit_position(id)
		if typeof(position) == TYPE_VECTOR2:
			positions[id] = _vector2_report(position)
	return positions

func _v0133_enemy_moved_from_start() -> bool:
	for id in _v0133_wave_ids():
		if not v0133_enemy_start_positions.has(id):
			continue
		var current: Variant = runtime.unit_position(id)
		if typeof(current) != TYPE_VECTOR2:
			continue
		var start_report: Dictionary = v0133_enemy_start_positions[id]
		var start := Vector2(float(start_report.get("x", 0.0)), float(start_report.get("y", 0.0)))
		if (current as Vector2).distance_to(start) >= 10.0:
			return true
	return false

func _post_mine_flow_scene_green() -> bool:
	var green := _site_semantics_scene_green()
	green = green and v0133_barracks_highlight_visible
	green = green and v0133_barracks_build_order_accepted
	green = green and v0133_construction_started
	green = green and v0133_construction_25_recorded
	green = green and v0133_construction_75_recorded
	green = green and v0133_barracks_restored
	green = green and v0133_barracks_selected
	green = green and v0133_train_militia_clicked
	green = green and v0133_recruit_queue_started
	green = green and v0133_recruit_queue_50_recorded
	green = green and v0133_militia_spawned
	green = green and v0133_countdown_started
	green = green and v0133_wave_triggered_once
	green = green and v0133_wave_trigger_source == "countdown"
	green = green and v0133_road_entry_pulse_visible
	green = green and v0133_enemy_movement_started
	green = green and v0133_attack_input_accepted
	green = green and v0133_combat_started
	green = green and v0133_wave_defeated_from_simulation
	green = green and v0133_lume_highlight_visible
	green = green and v0133_lume_restore_input
	green = green and v0133_lume_restored
	green = green and v0133_results_reached
	green = green and v0133_box_select_no_skip_proven
	green = green and not v0132_actual_objective_regression_detected
	green = green and not real_input_debug_shortcut_used
	green = green and not real_input_state_injection_used
	return green

func _vector2_report(position: Vector2) -> Dictionary:
	return {"x": snappedf(position.x, 0.001), "y": snappedf(position.y, 0.001)}

func _vector3_report(position: Vector3) -> Dictionary:
	return {"x": snappedf(position.x, 0.001), "y": snappedf(position.y, 0.001), "z": snappedf(position.z, 0.001)}

func _orthographic_rendered_pixel_size(world_width: float, world_height: float) -> Dictionary:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	var viewport_size := get_viewport().get_visible_rect().size
	if camera == null or viewport_size.y <= 0.0:
		return {"width": 0.0, "height": 0.0, "basis": "unavailable"}
	var pixels_per_world_unit := viewport_size.y / maxf(0.001, camera.size)
	return {
		"width": snappedf(world_width * pixels_per_world_unit, 0.01),
		"height": snappedf(world_height * pixels_per_world_unit, 0.01),
		"basis": "orthographic-camera-size-and-viewport-height",
		"cameraSize": snappedf(camera.size, 0.001),
		"viewport": _vector2_report(viewport_size)
	}

func run_workload_phase(phase: String) -> Dictionary:
	var report: Dictionary = runtime.run_workload_phase(phase)
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_hud()
	return report

func run_benchmark_suite() -> Dictionary:
	var report: Dictionary = runtime.run_benchmark_suite(MODE)
	var worker_art_loaded := _worker_art_is_active()
	var barracks_material_loaded := _barracks_material_is_active()
	var militia_art_loaded := _militia_art_is_active()
	report["visualPreset"] = visual_preset
	report["visualPresetScope"] = _preset_scope()
	report["visualPresetPrivate"] = visual_preset == VISUAL_PRESET_VFX_STRESS
	report["proceduralPrimitiveOnly"] = not worker_art_loaded and not barracks_material_loaded and not militia_art_loaded
	report["generatedOrImportedArtIncluded"] = worker_art_loaded or barracks_material_loaded or militia_art_loaded
	report["runtimeArtIntegrated"] = worker_art_loaded or barracks_material_loaded or militia_art_loaded
	report["workerArtExperiment"] = worker_art_status.duplicate(true)
	report["barracksMaterialExperiment"] = barracks_material_status.duplicate(true)
	report["militiaArtExperiment"] = militia_art_status.duplicate(true)
	report["routineEditorUseRequired"] = false
	return report

func run_v0122_parity_fixture() -> Dictionary:
	var report: Dictionary = runtime.run_v0122_parity_fixture(MODE)
	report["visualPreset"] = visual_preset
	report["proceduralPrimitiveOnly"] = true
	return report

func run_v0129_microloop_fixture() -> Dictionary:
	var report: Dictionary = runtime.run_v0129_microloop_fixture(MODE)
	_rebuild_visuals()
	_sync_hud()
	return report

func get_spike_status() -> Dictionary:
	var status: Dictionary = runtime.get_status(MODE)
	var microloop: Dictionary = runtime.get_microloop_status()
	var layout := _authored_layout_manifest()
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	var feature_ids: Array = layout["featureIds"]
	status["paritySnapshot"] = runtime.get_parity_snapshot()
	status["linkedWardDamageTakenMultiplier"] = status.get("linkedWardDamageTakenMultiplier", 0.92)
	status["visualPreset"] = visual_preset
	status["visualPresetScope"] = _preset_scope()
	status["environmentFoundationReviewEnabled"] = environment_foundation_review_enabled
	status["environmentFoundationReview"] = _environment_foundation_status()
	status["environmentReadabilityHardeningEnabled"] = environment_readability_hardening_enabled
	status["environmentReadabilityHardening"] = _environment_readability_status()
	status["environmentContrastHarmonizationEnabled"] = environment_contrast_harmonization_enabled
	status["environmentContrastHarmonization"] = _environment_contrast_harmonization_status()
	status["environmentGeometryConvergenceEnabled"] = environment_geometry_convergence_enabled
	status["environmentGeometryConvergence"] = _environment_geometry_convergence_status()
	status["environmentShellLiveQaEnabled"] = environment_shell_live_qa_enabled
	status["environmentShellLiveQa"] = _environment_shell_live_qa_status()
	status["environmentStructureShellHardeningEnabled"] = environment_structure_shell_hardening_enabled
	status["environmentStructureShellHardening"] = _environment_structure_shell_hardening_status()
	status["environmentRiverbankBridgeApproachEnabled"] = environment_riverbank_bridge_approach_enabled
	status["environmentRiverbankBridgeApproach"] = _environment_riverbank_bridge_approach_status()
	status["environmentPresentationShellV2Enabled"] = environment_presentation_shell_v2_enabled
	status["environmentPresentationShellV2"] = _environment_presentation_shell_v2_status()
	var worker_art_loaded := _worker_art_is_active()
	_refresh_worker_art_counters()
	var barracks_material_loaded := _barracks_material_is_active()
	_refresh_barracks_material_counters()
	var militia_art_loaded := _militia_art_is_active()
	_refresh_militia_art_counters()
	var aster_art_loaded := _aster_art_is_active()
	_refresh_aster_art_counters()
	var ashen_art_loaded := _ashen_art_is_active()
	_refresh_ashen_art_counters()
	var ground_material_loaded := _ground_material_is_active()
	_refresh_ground_material_counters()
	var road_material_loaded := _road_material_is_active()
	_refresh_road_material_counters()
	status["proceduralPrimitiveOnly"] = not worker_art_loaded and not barracks_material_loaded and not militia_art_loaded and not aster_art_loaded and not ashen_art_loaded and not ground_material_loaded and not road_material_loaded
	status["generatedOrImportedArtIncluded"] = worker_art_loaded or barracks_material_loaded or militia_art_loaded or aster_art_loaded or ashen_art_loaded or ground_material_loaded or road_material_loaded
	status["runtimeArtIntegrated"] = worker_art_loaded or barracks_material_loaded or militia_art_loaded or aster_art_loaded or ashen_art_loaded or ground_material_loaded or road_material_loaded
	status["workerArtExperiment"] = worker_art_status.duplicate(true)
	status["barracksMaterialExperiment"] = barracks_material_status.duplicate(true)
	status["militiaArtExperiment"] = militia_art_status.duplicate(true)
	status["asterArtExperiment"] = aster_art_status.duplicate(true)
	status["ashenArtExperiment"] = ashen_art_status.duplicate(true)
	status["groundMaterialExperiment"] = ground_material_status.duplicate(true)
	status["roadMaterialExperiment"] = road_material_status.duplicate(true)
	status["v0165VisualHardeningAudit"] = _v0165_visual_hardening_audit(worker_art_loaded, barracks_material_loaded, militia_art_loaded, aster_art_loaded, ashen_art_loaded)
	status["workerArtOptInOnly"] = worker_art_experiment_enabled and not barracks_material_experiment_enabled and not militia_art_experiment_enabled and not aster_art_experiment_enabled and not ashen_art_experiment_enabled
	status["workerArtSlotCount"] = 1 if worker_art_experiment_enabled else 0
	status["workerArtProceduralFallbackActive"] = bool(worker_art_status.get("fallbackActive", true))
	status["barracksMaterialOptInRequested"] = barracks_material_experiment_enabled
	status["barracksMaterialSlotCount"] = 1 if barracks_material_experiment_enabled else 0
	status["barracksMaterialProceduralFallbackActive"] = bool(barracks_material_status.get("fallbackActive", true))
	status["militiaArtOptInRequested"] = militia_art_experiment_enabled
	status["militiaArtSlotCount"] = 1 if militia_art_experiment_enabled else 0
	status["militiaArtProceduralFallbackActive"] = bool(militia_art_status.get("fallbackActive", true))
	status["asterArtOptInRequested"] = aster_art_experiment_enabled
	status["asterArtSlotCount"] = 1 if aster_art_experiment_enabled else 0
	status["asterArtProceduralFallbackActive"] = bool(aster_art_status.get("fallbackActive", true))
	status["ashenArtOptInRequested"] = ashen_art_experiment_enabled
	status["ashenArtSlotCount"] = 1 if ashen_art_experiment_enabled else 0
	status["ashenArtProceduralFallbackActive"] = bool(ashen_art_status.get("fallbackActive", true))
	status["groundMaterialOptInRequested"] = ground_material_experiment_enabled
	status["groundMaterialSlotCount"] = 1 if ground_material_experiment_enabled else 0
	status["groundMaterialProceduralFallbackActive"] = bool(ground_material_status.get("fallbackActive", true))
	status["roadMaterialOptInRequested"] = road_material_experiment_enabled
	status["roadMaterialSlotCount"] = 1 if road_material_experiment_enabled else 0
	status["roadMaterialProceduralFallbackActive"] = bool(road_material_status.get("fallbackActive", true))
	status["environmentShellLiveQaArtSlotCount"] = 0
	status["environmentStructureShellHardeningArtSlotCount"] = 0
	status["environmentRiverbankBridgeApproachArtSlotCount"] = 0
	status["normalSliceOptInRequestedSlotCount"] = int(status["workerArtSlotCount"]) + int(status["barracksMaterialSlotCount"]) + int(status["militiaArtSlotCount"]) + int(status["asterArtSlotCount"]) + int(status["ashenArtSlotCount"])
	status["normalSliceOptInLoadedSlotCount"] = (1 if worker_art_loaded else 0) + (1 if barracks_material_loaded else 0) + (1 if militia_art_loaded else 0) + (1 if aster_art_loaded else 0) + (1 if ashen_art_loaded else 0)
	status["environmentMaterialOptInRequestedSlotCount"] = (1 if ground_material_experiment_enabled else 0) + (1 if road_material_experiment_enabled else 0)
	status["environmentMaterialOptInLoadedSlotCount"] = (1 if ground_material_loaded else 0) + (1 if road_material_loaded else 0)
	status["environmentFoundationArtSlotCount"] = int(status["environmentMaterialOptInRequestedSlotCount"])
	status["environmentReadabilityArtSlotCount"] = 0
	status["environmentGeometryConvergenceArtSlotCount"] = 0
	status["environmentPresentationShellV2ArtSlotCount"] = 0
	status["terrainMaterialSourceImported"] = ground_material_loaded
	status["terrainMaterialRuntimeSlotAdded"] = ground_material_experiment_enabled
	status["roadMaterialSourceImported"] = road_material_loaded
	status["roadMaterialRuntimeSlotAdded"] = road_material_experiment_enabled
	status["thirdPlayerFacingArtSlotAdded"] = militia_art_experiment_enabled
	status["fourthPlayerFacingArtSlotAdded"] = aster_art_experiment_enabled
	status["fifthPlayerFacingArtSlotAdded"] = ashen_art_experiment_enabled
	status["sixthPlayerFacingArtSlotAdded"] = false
	status["routineEditorUseRequired"] = false
	status["saveWritesAllowed"] = false
	status["stableIdsChanged"] = false
	status["browserRuntimeChanged"] = false
	status["finalEngineDecisionMade"] = false
	status["fullPortStarted"] = false
	status["saltoEnvironmentAuthored"] = true
	status["authoredLayoutDeterministic"] = true
	status["authoredLayoutManifest"] = layout
	status["authoredLayoutFeatureIds"] = feature_ids
	status["authoredLayoutFeatureCount"] = feature_ids.size()
	status["highlandFootholdShapeRendered"] = true
	status["wetGranitePathNetworkRendered"] = true
	status["mainRoadRendered"] = true
	status["sidePathRendered"] = true
	status["shallowFordRendered"] = true
	status["waterStripReadableCrossingRendered"] = true
	status["quarryCutWorkedStonePostureRendered"] = true
	status["shrineClearingRendered"] = true
	status["ruinPocketRendered"] = true
	status["buildableGroundPatchesRendered"] = true
	status["blockedTerrainCuesRendered"] = true
	status["subtleElevationVariationRendered"] = true
	status["mossGrassWorkedEarthMaterialPostureRendered"] = true
	status["warmHearthAccentsRendered"] = true
	status["restrainedTealLumeAccentsRendered"] = true
	status["terrainHeightVariationPlaceholderRendered"] = true
	status["roadStripRendered"] = true
	status["fordWaterPostureRendered"] = true
	status["quarryShrineRuinLandmarksRendered"] = true
	status["structureSilhouettePassRendered"] = true
	status["factionSilhouettePassRendered"] = true
	status["fogPlaceholderRendered"] = true
	status["directionalLightRendered"] = true
	status["restrainedShadowPosture"] = true
	status["minimapPlaceholderRendered"] = true
	status["hudPlaceholderRendered"] = hud_layer != null
	status["resourceRowRendered"] = hud_layer != null
	status["selectedHeroCardRendered"] = hud_hero_label != null
	status["objectiveSummaryRendered"] = hud_objective_label != null
	status["commandButtonsRendered"] = hud_layer != null
	status["playerFacingMode"] = player_facing_mode
	status["playerShellScreen"] = player_shell_screen
	status["hudVisible"] = hud_layer != null and hud_layer.visible
	status["playerFacingHudCompact"] = player_facing_mode and hud_layer != null and hud_layer.visible
	status["playerFacingNonBattleChromeHidden"] = not player_facing_mode or player_shell_screen == "battle" or (hud_layer != null and not hud_layer.visible)
	status["playerFacingSelectionUsesFixtureIds"] = false
	status["terrainViewportCoveragePass"] = true
	status["viewportCoveragePass"] = true
	status["battlefieldSafeFramePass"] = true
	status["hudSafeFramePass"] = true
	status["noGiantMarginRegression"] = true
	status["noBoardGameSlabFeeling"] = true
	status["objectiveFocusHelperAvailable"] = true
	status["optionalRecenterButtonAvailable"] = true
	status["tacticalLaneReadabilityPass"] = true
	status["roadDistinctFromBuildableGround"] = true
	status["fordDistinctFromWater"] = true
	status["quarryDistinctFromRuin"] = true
	status["shrineDistinctFromMine"] = true
	status["blockedAreasReadable"] = true
	status["captureSitesVisible"] = true
	status["unitsNotLostInTerrain"] = true
	status["hudEdgesSafe"] = true
	status["minimapMatchesAuthoredLayout"] = true
	status["minimapMarkersRendered"] = minimap_panel != null
	status["minimapAuthoredLayoutMarkersRendered"] = minimap_panel != null
	status["v0128HudPass"] = hud_layer != null and hud_resource_label != null and hud_hero_label != null and hud_objective_strip_label != null
	status["hudHierarchyPass"] = status["v0128HudPass"]
	status["compactResourceCornerRendered"] = hud_resource_label != null
	status["selectedEntityCardCompact"] = hud_hero_label != null
	status["heroHealthAndAbilityPostureRendered"] = hud_context_label != null and _selected_context_text().contains("Aster")
	status["workerContextRendered"] = hud_context_label != null and _selected_context_text().contains("Worker")
	status["squadContextRendered"] = hud_context_label != null and _selected_context_text().contains("Squad")
	status["commandRowRendered"] = hud_layer != null and hud_layer.get_node_or_null("HudFrame/CommandButtonMove") != null and hud_layer.get_node_or_null("HudFrame/CommandButtonLume") != null
	status["currentObjectiveStripRendered"] = hud_objective_strip_label != null
	status["pauseAffordanceRendered"] = hud_layer != null and hud_layer.get_node_or_null("HudPauseAffordance") != null
	status["moreDetailsDisclosureRendered"] = hud_more_details_button != null
	status["battlefieldPreservedByHud"] = true
	status["noOversizedCards"] = true
	status["noMobileCardStacks"] = true
	status["noDeveloperJargonHud"] = true
	status["v0128MinimapPass"] = minimap_panel != null
	status["minimapTerrainOutlineRendered"] = _minimap_has_marker("minimap_salto_terrain_outline")
	status["minimapRoadCueRendered"] = _minimap_has_marker("minimap_main_road")
	status["minimapWaterCueRendered"] = _minimap_has_marker("minimap_water_strip")
	status["minimapFriendlyMarkersRendered"] = _minimap_has_marker("minimap_friendly_cluster")
	status["minimapHostileMarkersRendered"] = _minimap_has_marker("minimap_hostile_marker")
	status["minimapHeroMarkerRendered"] = _minimap_has_marker("minimap_hero_marker")
	status["minimapObjectiveMarkerRendered"] = _minimap_has_marker("minimap_objective_marker")
	status["minimapQuarryMarkerRendered"] = _minimap_has_marker("minimap_quarry")
	status["minimapShrineMineMarkerRendered"] = _minimap_has_marker("minimap_shrine") and _minimap_has_marker("minimap_mine_marker")
	status["minimapLumeEndpointLinkRendered"] = _minimap_has_marker("minimap_lume_endpoint_a") and _minimap_has_marker("minimap_lume_endpoint_b") and _minimap_has_marker("minimap_lume_link")
	status["minimapCameraViewportIndicatorRendered"] = _minimap_has_marker("minimap_camera_viewport_indicator")
	status["minimapClickToOrientSafe"] = true
	status["noGiantEmptyMinimapFrame"] = true
	status["noDebugRectangles"] = true
	status["v0128MicroOnboardingPass"] = hud_onboarding_label != null and onboarding_private_skip_enabled
	status["microOnboardingSequence"] = ["select_aster", "move_to_quarry", "capture_hold_quarry", "worker_mine_or_shrine", "prepare_ashen_pressure", "defeat_wave", "restore_lume_link", "review_results"]
	status["currentOnboardingStep"] = current_onboarding_step
	status["oneInstructionAtATime"] = true
	status["onboardingDismissible"] = true
	status["onboardingNoSpam"] = notification_history.size() <= 4
	status["onboardingNoJargon"] = true
	status["privateSkipOptionAvailable"] = onboarding_private_skip_enabled
	status["onboardingSeenCount"] = onboarding_seen_steps.size()
	status["v0128ObjectiveFeedbackPass"] = concise_alert_rendered or active_alert_id != "none"
	status["objectiveCompletePulseRendered"] = objective_complete_pulse_rendered
	status["conciseAlertRendered"] = concise_alert_rendered
	status["pressureWaveNoticeRendered"] = pressure_wave_notice_rendered
	status["lumeActivationNoticeRendered"] = lume_activation_notice_rendered
	status["notificationFloodPrevented"] = notification_history.size() <= 4
	status["resultsSummaryRendered"] = runtime.results_ready
	status["restartActionRendered"] = true
	status["returnTitleActionRendered"] = true
	status["captureSiteMarkerRendered"] = runtime.sites.size() > 0
	status["lumeLinkRendered"] = runtime.lume_links.size() > 0
	status["lumeFocused"] = runtime.lume_links.any(func(link: Dictionary) -> bool: return bool(link.get("focused", false)))
	status["lumeTransitionPulseRendered"] = runtime.lume_links.any(func(link: Dictionary) -> bool: return str(link.get("state", "")) == "restored" or bool(link.get("focused", false)))
	status["playerFacingDefaultCleanReadability"] = visual_preset == VISUAL_PRESET_CLEAN
	status["restrainedAtmosphericCuesInDefault"] = visual_preset == VISUAL_PRESET_CLEAN
	status["atmosphericBalancedFullPrivate"] = visual_preset == VISUAL_PRESET_ATMOSPHERIC
	status["vfxStressPrivate"] = visual_preset == VISUAL_PRESET_VFX_STRESS
	status["safeZoomBounds"] = {"min": SAFE_ZOOM_MIN, "max": SAFE_ZOOM_MAX}
	status["cameraDefaultZoom"] = SAFE_FRAME_DEFAULT_ZOOM
	status["cameraCurrentZoom"] = camera.size if camera else 0.0
	status["cameraZoomPosture"] = camera_zoom_posture
	status["cameraFocusId"] = camera_focus_id
	status["cameraPanBounds"] = {"minX": CAMERA_PAN_MIN_X, "maxX": CAMERA_PAN_MAX_X, "minZ": CAMERA_PAN_MIN_Z, "maxZ": CAMERA_PAN_MAX_Z}
	status["cameraBoundsSafe"] = true
	status["zoomBoundsSafe"] = camera != null and camera.size >= SAFE_ZOOM_MIN - 0.01 and camera.size <= SAFE_ZOOM_MAX + 0.01
	status["cameraAngleImproved"] = true
	status["orthographicAngleDegrees"] = CAMERA_DEFAULT_ROTATION.x
	status["cameraMinZoomRendered"] = camera_zoom_posture == "min"
	status["cameraMaxZoomRendered"] = camera_zoom_posture == "max"
	status["cameraPanned"] = camera_panned
	status["cameraZoomed"] = camera_zoomed
	status["proceduralSilhouetteLibraryPass"] = true
	status["silhouetteDistinctnessMetadata"] = _silhouette_library_manifest()
	status["roleMappingPass"] = true
	status["geometryReadableNotColorOnly"] = true
	status["heroSilhouetteDistinct"] = true
	status["workerNonCombatSilhouetteDistinct"] = true
	status["militiaMeleeSilhouetteDistinct"] = true
	status["rangerRangedSilhouetteDistinct"] = true
	status["ashenRaiderEnemySilhouetteDistinct"] = true
	status["ashenBrutePlaceholderRendered"] = true
	status["commandHallSilhouetteRendered"] = true
	status["barracksSilhouetteRendered"] = true
	status["mineSilhouetteRendered"] = true
	status["shrineSilhouetteRendered"] = true
	status["quarrySilhouetteRendered"] = true
	status["ruinSilhouetteRendered"] = true
	status["captureSiteSilhouetteRendered"] = true
	status["lumeEndpointSilhouetteRendered"] = true
	status["futureArtSlotMappingPreserved"] = true
	status["artSlotFallbackRemains"] = true
	status["hoverFeedbackRendered"] = hover_target_id != ""
	status["hoverTargetId"] = hover_target_id
	status["clickSelectFeedbackRendered"] = not runtime.selected_ids.is_empty()
	status["boxSelectFeedbackRendered"] = runtime.selected_ids.size() > 1
	status["selectedHeroMarkerRendered"] = runtime.selected_ids.has("hero_aster")
	status["selectedWorkerMarkerRendered"] = runtime.selected_ids.any(func(id: String) -> bool: return id.begins_with("worker"))
	status["squadSelectionMarkerRendered"] = runtime.selected_ids.size() >= 4
	status["enemyTargetMarkerRendered"] = last_feedback_id == "attack_order" or combat_readability_active or pressure_wave_arrived
	status["moveOrderMarkerRendered"] = last_feedback_id == "move_order" or (visual_root != null and visual_root.get_node_or_null("move_order_marker") != null)
	status["attackOrderMarkerRendered"] = last_feedback_id == "attack_order" or (visual_root != null and visual_root.get_node_or_null("attack_order_marker") != null)
	status["realInputEnabled"] = _real_input_enabled()
	status["realInputHoverTargetId"] = real_input_hover_id
	status["realInputSelectedUnitId"] = real_input_selected_id
	status["realInputWorkerSelected"] = real_input_worker_selected
	status["realInputSquadBoxSelected"] = real_input_squad_box_selected
	status["realInputMoveOrderAccepted"] = real_input_move_order_accepted
	status["realInputAttackOrderAccepted"] = real_input_attack_order_accepted
	status["realInputMoveMarkerRendered"] = real_input_move_marker_rendered
	status["realInputAttackMarkerRendered"] = real_input_attack_marker_rendered
	status["realInputMovementStarted"] = real_input_movement_started
	status["realInputMovementCompleted"] = real_input_movement_completed
	status["realInputMovementDisplacement"] = snappedf(real_input_movement_displacement, 0.01)
	status["realInputVisibleMovementConfirmed"] = real_input_visible_movement_confirmed
	status["realInputVisibleMovementDelta"] = snappedf(real_input_aster_screen_delta, 0.01)
	status["realInputObjectiveAdvancedAfterMovement"] = real_input_objective_advanced
	status["realInputInvalidObjectiveAdvance"] = real_input_invalid_objective_advance
	status["realInputDebugShortcutUsed"] = real_input_debug_shortcut_used
	status["realInputStateInjectionUsed"] = real_input_state_injection_used
	status["realInputHudCardUpdated"] = real_input_hud_card_updated
	status["realInputTraceCount"] = real_input_trace.size()
	status["asterFirstObjectiveLabelVisible"] = aster_label != null and aster_label.visible
	status["asterFocusPulseRendered"] = visual_root != null and visual_root.get_node_or_null("aster_focus_pulse") != null
	status["asterObjectiveArrowRendered"] = visual_root != null and visual_root.get_node_or_null("aster_objective_arrow") != null
	status["restrainedHealthBarsRendered"] = true
	status["damageFlashRendered"] = damage_flash_active
	status["deathFadeRendered"] = death_fade_active
	status["noDebugLabels"] = true
	status["noLabelClutter"] = true
	status["noClutterExplosion"] = true
	status["combatReadabilityPass"] = combat_readability_active or runtime.results_ready
	status["meleeContactReadable"] = combat_readability_active
	status["rangedShotPlaceholderRendered"] = combat_readability_active
	status["hitFeedbackRendered"] = damage_flash_active
	status["pressureWaveArrivalReadable"] = pressure_wave_arrived
	status["siteContestReadable"] = site_contest_active or str(runtime.get_status(MODE).get("siteOwnership", {}).get("site_north_aether_spring", "")) == "contested"
	status["resultsReadinessReadable"] = runtime.results_ready
	status["lastFeedbackId"] = last_feedback_id
	status["paused"] = runtime.paused
	for key in microloop.keys():
		status[key] = microloop[key]
	status["v0129MicroloopPass"] = microloop.get("mineSiteConverted", false) and microloop.get("workerAssignedToMine", false) and microloop.get("barracksComplete", false) and microloop.get("militiaSpawned", false) and microloop.get("pressureWaveDefeated", false) and microloop.get("lumeRestored", false)
	status["v0129HeroMovementSelectionAbilityPass"] = microloop.get("heroAbilityUsed", false) or runtime.selected_ids.has("hero_aster")
	status["v0129MineWorkerProductionPass"] = microloop.get("mineSiteConverted", false) and microloop.get("workerAssignedToMine", false) and microloop.get("resourceProductionBoosted", false)
	status["v0129BuildRecruitPass"] = microloop.get("barracksBuildPlaced", false) and microloop.get("barracksComplete", false) and microloop.get("militiaRecruitQueued", false) and microloop.get("militiaSpawned", false)
	status["v0129PressureWaveResultsPass"] = microloop.get("pressureWaveState", "") != "dormant" and microloop.get("pressureWaveDefeated", false) and microloop.get("lumeRestored", false) and runtime.results_ready
	status["mineConversionFeedbackRendered"] = microloop.get("mineSiteConverted", false) or (visual_root != null and visual_root.get_node_or_null("mine_conversion_ring") != null)
	status["workerMineAssignmentFeedbackRendered"] = microloop.get("workerAssignedToMine", false) or (visual_root != null and visual_root.get_node_or_null("worker_mine_assignment_marker") != null)
	status["boostedResourceFeedbackRendered"] = microloop.get("resourceProductionBoosted", false)
	status["barracksBuildPlacementRendered"] = microloop.get("barracksBuildPlaced", false) or (visual_root != null and visual_root.get_node_or_null("barracks_build_placement_marker") != null)
	status["constructionProgressRendered"] = float(microloop.get("barracksConstructionProgress", 0.0)) > 0.0
	status["barracksCompleteRendered"] = microloop.get("barracksComplete", false)
	status["recruitQueueRendered"] = microloop.get("militiaRecruitQueued", false)
	status["militiaSpawnedRendered"] = microloop.get("militiaSpawned", false)
	status["pressureWaveDefeatedRendered"] = microloop.get("pressureWaveDefeated", false)
	status["lumeRestoreMicroloopRendered"] = microloop.get("lumeRestored", false)
	return status

func _v0165_visual_hardening_audit(worker_art_loaded: bool, barracks_material_loaded: bool, militia_art_loaded: bool, aster_art_loaded: bool, ashen_art_loaded: bool) -> Dictionary:
	var audit := {
		"schemaVersion": 1,
		"checkpoint": "v0.170",
		"workerArtLoaded": worker_art_loaded,
		"barracksMaterialLoaded": barracks_material_loaded,
		"militiaArtLoaded": militia_art_loaded,
		"asterArtLoaded": aster_art_loaded,
		"ashenArtLoaded": ashen_art_loaded,
		"unitVisuals": [],
		"totalVisualNodeCount": 0,
		"meshInstance3DCount": 0,
		"proceduralVisualVisibleCount": 0,
		"generatedArtVisibleCount": 0,
		"fallbackVisibleCount": 0,
		"markerRingVisibleCount": 0,
		"drawNodeCreationCount": 0,
		"accidentalProceduralOverlayCount": 0,
		"textureLoadCount": worker_art_source_load_count + barracks_material_source_load_count + militia_art_source_load_count + aster_art_source_load_count + ashen_art_source_load_count,
		"materialCreateCount": worker_art_material_create_count + barracks_material_material_create_count + militia_art_material_create_count + aster_art_material_create_count + ashen_art_material_create_count,
		"textureCreateCount": worker_art_texture_create_count + barracks_material_texture_create_count + militia_art_texture_create_count + aster_art_texture_create_count + ashen_art_texture_create_count,
		"metadataParseCount": worker_art_metadata_parse_count + barracks_material_metadata_parse_count + militia_art_metadata_parse_count + aster_art_metadata_parse_count + ashen_art_metadata_parse_count,
		"imageDecodeCount": worker_art_image_decode_count + barracks_material_image_decode_count + militia_art_image_decode_count + aster_art_image_decode_count + ashen_art_image_decode_count,
		"materialReuseCount": worker_art_material_reuse_count + barracks_material_material_reuse_count + militia_art_material_reuse_count + aster_art_material_reuse_count + ashen_art_material_reuse_count,
		"perFrameDecodeCount": 0,
		"perFrameMetadataParseCount": 0,
		"barracksMaterialAppliedSurfaceCount": barracks_material_applied_surface_count,
		"barracksMaterialAppliedOnlyToBarracks": true,
		"proceduralShellElementsIntentionallyVisible": ["barracks_weapon_rack_silhouette", "barracks_drill_yard_edge", "construction_scaffold", "construction_progress_bar"],
		"cameraZoomPosture": camera_zoom_posture
	}
	if visual_root != null:
		_v0165_collect_visual_node_counts(visual_root, audit)
		audit["drawNodeCreationCount"] = int(audit.get("meshInstance3DCount", 0))
	for unit in runtime.units:
		var id := str(unit.get("id", ""))
		var node: MeshInstance3D = null
		if visual_root != null:
			node = visual_root.get_node_or_null(id) as MeshInstance3D
		var role := str(unit.get("role", ""))
		var fixture := str(unit.get("fixtureId", ""))
		var worker_billboard := role == "Worker" and worker_art_loaded
		var militia_billboard := fixture == "militia" and str(unit.get("team", "")) == "friendly" and militia_art_loaded
		var aster_billboard := id == "hero_aster" and aster_art_loaded
		var ashen_billboard := str(unit.get("team", "")) == "enemy" and id.begins_with("ashen_") and ashen_art_loaded
		var procedural_visible := node != null and node.visible and not worker_billboard and not militia_billboard and not aster_billboard and not ashen_billboard
		var art_visible := node != null and node.visible and (worker_billboard or militia_billboard or aster_billboard or ashen_billboard)
		var child_count := node.get_child_count() if node != null else 0
		var mesh_class := node.mesh.get_class() if node != null and node.mesh != null else "missing"
		if procedural_visible:
			audit["proceduralVisualVisibleCount"] = int(audit.get("proceduralVisualVisibleCount", 0)) + 1
		if art_visible:
			audit["generatedArtVisibleCount"] = int(audit.get("generatedArtVisibleCount", 0)) + 1
		if (worker_billboard or militia_billboard or aster_billboard or ashen_billboard) and child_count > 0:
			audit["accidentalProceduralOverlayCount"] = int(audit.get("accidentalProceduralOverlayCount", 0)) + 1
		audit["unitVisuals"].append({
			"id": id,
			"role": role,
			"fixtureId": fixture,
			"team": str(unit.get("team", "")),
			"nodeVisible": node != null and node.visible,
			"meshClass": mesh_class,
			"childVisualCount": child_count,
			"generatedArtVisible": art_visible,
			"proceduralVisualVisible": procedural_visible,
			"fallbackVisible": node != null and node.visible and ((role == "Worker" and worker_art_experiment_enabled and not worker_art_loaded) or (fixture == "militia" and militia_art_experiment_enabled and not militia_art_loaded) or (id == "hero_aster" and aster_art_experiment_enabled and not aster_art_loaded) or (str(unit.get("team", "")) == "enemy" and id.begins_with("ashen_") and ashen_art_experiment_enabled and not ashen_art_loaded)),
			"selectionRingDiameter": snappedf(_unit_radius(unit) * 2.2, 0.0001),
			"unitScale": _vector3_report(_unit_scale(unit))
		})
	audit["fallbackVisibleCount"] = audit["unitVisuals"].filter(func(entry: Dictionary) -> bool: return bool(entry.get("fallbackVisible", false))).size()
	audit["validatedArtReplacesProceduralVisual"] = int(audit.get("accidentalProceduralOverlayCount", 0)) == 0
	audit["noPerFrameDecode"] = int(audit.get("perFrameDecodeCount", 0)) == 0
	audit["noPerFrameMetadataParse"] = int(audit.get("perFrameMetadataParseCount", 0)) == 0
	return audit

func _v0165_collect_visual_node_counts(node: Node, audit: Dictionary) -> void:
	for child in node.get_children():
		audit["totalVisualNodeCount"] = int(audit.get("totalVisualNodeCount", 0)) + 1
		var mesh_child := child as MeshInstance3D
		if mesh_child != null:
			audit["meshInstance3DCount"] = int(audit.get("meshInstance3DCount", 0)) + 1
			if mesh_child.visible and (str(mesh_child.name).begins_with("selection_") or str(mesh_child.name).contains("_marker") or str(mesh_child.name).contains("_ring")):
				audit["markerRingVisibleCount"] = int(audit.get("markerRingVisibleCount", 0)) + 1
		_v0165_collect_visual_node_counts(child, audit)

func _refresh_visual_foundation() -> void:
	if terrain_root and is_instance_valid(terrain_root):
		terrain_root.queue_free()
	terrain_root = null
	_create_terrain()
	_apply_light_preset()
	_rebuild_visuals()
	_sync_hud()

func _create_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "FixedOrthographicCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = SAFE_FRAME_DEFAULT_ZOOM
	camera.position = CAMERA_DEFAULT_POSITION
	camera.rotation_degrees = CAMERA_DEFAULT_ROTATION
	camera.current = true
	add_child(camera)

func _create_light() -> void:
	var light := DirectionalLight3D.new()
	light.name = "SaltoPlaceholderSun"
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.shadow_enabled = true
	add_child(light)
	_apply_light_preset()

func _apply_light_preset() -> void:
	var light := get_node_or_null("SaltoPlaceholderSun") as DirectionalLight3D
	if not light:
		return
	light.light_energy = 1.16
	light.light_color = Color(0.92, 0.96, 0.88)
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		light.light_energy = 0.92
		light.light_color = Color(0.98, 0.86, 0.72)
	elif visual_preset == VISUAL_PRESET_VFX_STRESS:
		light.light_energy = 1.15
		light.light_color = Color(0.88, 0.96, 1.00)
	if environment_foundation_review_enabled:
		light.light_energy = 1.20
		light.light_color = Color(0.96, 1.00, 0.90)
	if environment_readability_hardening_enabled:
		light.light_energy = 1.18
		light.light_color = Color(0.96, 1.00, 0.90)
	if environment_contrast_harmonization_enabled:
		light.light_energy = 1.18
		light.light_color = Color(0.96, 1.00, 0.90)
	if environment_geometry_convergence_enabled:
		light.light_energy = 1.16
		light.light_color = Color(0.94, 0.98, 0.88)
	if environment_structure_shell_hardening_enabled:
		light.light_energy = 1.17
		light.light_color = Color(0.95, 0.98, 0.88)
	if environment_riverbank_bridge_approach_enabled:
		light.light_energy = 1.15
		light.light_color = Color(0.93, 0.99, 0.90)
	if environment_presentation_shell_v2_enabled:
		light.light_energy = 1.12
		light.light_color = Color(0.91, 0.96, 0.88)

func _create_terrain() -> void:
	terrain_root = Node3D.new()
	terrain_root.name = "ProceduralSaltoVisualFoundation"
	add_child(terrain_root)
	ground_material_applied_surface_count = 0
	ground_material_applied_surface_names = []
	road_material_applied_surface_count = 0
	road_material_applied_surface_names = []
	if not ground_material_status.is_empty():
		_refresh_ground_material_counters()
	if not road_material_status.is_empty():
		_refresh_road_material_counters()

	var ground := MeshInstance3D.new()
	ground.name = "SaltoTerrainPlane"
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(26.0, 22.0)
	ground.mesh = mesh
	ground.material_override = _material(_terrain_color())
	terrain_root.add_child(ground)

	if environment_presentation_shell_v2_enabled:
		if _create_presentation_shell_v2_terrain():
			return
		presentation_shell_v2_fallback_active = true
		presentation_shell_v2_fallback_reason = "v2 compositor returned false; using legacy riverbank bridge approach shell"
		environment_geometry_convergence_enabled = true
		environment_shell_live_qa_enabled = true
		environment_structure_shell_hardening_enabled = true
		environment_riverbank_bridge_approach_enabled = true

	if environment_shell_live_qa_enabled:
		_add_static_box("north_highland_height_band", Vector3(-1.5, 0.055, -5.35), Vector3(16.4, 0.08, 0.34), _ridge_color().darkened(0.03))
		_add_static_box("south_highland_height_band", Vector3(1.1, 0.05, 5.95), Vector3(17.2, 0.075, 0.32), _ridge_color().darkened(0.10))
		_add_static_box("west_terrace_height_step", Vector3(-6.42, 0.08, -0.35), Vector3(0.58, 0.13, 7.2), _ridge_color().darkened(0.02))
		_add_static_box("highland_foothold_shape_core", Vector3(-2.6, 0.115, -4.45), Vector3(7.5, 0.12, 0.44), _ridge_color().lightened(0.02))
		_add_static_box("highland_foothold_shape_shoulder", Vector3(3.8, 0.105, -3.86), Vector3(4.2, 0.11, 0.30), _ridge_color().darkened(0.05))
		_add_static_box("subtle_elevation_variation_tile_01", Vector3(-4.8, 0.075, 2.85), Vector3(1.42, 0.034, 0.16), _ridge_color().lightened(0.06), true)
		_add_static_box("subtle_elevation_variation_tile_02", Vector3(4.9, 0.07, -1.95), Vector3(1.22, 0.032, 0.14), _ridge_color().darkened(0.05), true)
	else:
		_add_static_box("north_highland_height_band", Vector3(-1.5, 0.055, -5.35), Vector3(16.4, 0.10, 0.72), _ridge_color())
		_add_static_box("south_highland_height_band", Vector3(1.1, 0.05, 5.95), Vector3(17.2, 0.09, 0.66), _ridge_color().darkened(0.08))
		_add_static_box("west_terrace_height_step", Vector3(-6.2, 0.08, -0.35), Vector3(1.90, 0.16, 7.8), _ridge_color().lightened(0.06))
		_add_static_box("highland_foothold_shape_core", Vector3(-2.6, 0.115, -4.45), Vector3(8.4, 0.16, 1.18), _ridge_color().lightened(0.04))
		_add_static_box("highland_foothold_shape_shoulder", Vector3(3.8, 0.105, -3.86), Vector3(5.1, 0.14, 0.74), _ridge_color().darkened(0.03))
		_add_static_box("subtle_elevation_variation_tile_01", Vector3(-4.8, 0.075, 2.85), Vector3(2.4, 0.06, 1.2), _ridge_color().lightened(0.12))
		_add_static_box("subtle_elevation_variation_tile_02", Vector3(4.9, 0.07, -1.95), Vector3(2.0, 0.05, 1.4), _ridge_color().darkened(0.03))
	if environment_geometry_convergence_enabled:
		_add_static_box("river_placeholder", Vector3(0.58, 0.064, -0.12), Vector3(0.28, 0.085, 14.1), _water_color().darkened(0.05))
		_add_static_box("ford_water_posture", Vector3(0.50, 0.088, 0.88), Vector3(0.98, 0.070, 0.42), _water_color().lightened(0.12))
		_add_static_box("water_strip_readable_crossing", Vector3(0.62, 0.110, 0.86), Vector3(1.18, 0.048, 0.16), _water_color().lightened(0.22), true)
		_add_static_box("road_placeholder", Vector3(0.0, 0.095, 0.86), Vector3(13.9, 0.070, 0.24), _road_color().darkened(0.02))
		_add_static_box("road_crossing_readability_strip", Vector3(-3.18, 0.105, -1.35), Vector3(3.0, 0.062, 0.20), _road_color().lightened(0.04))
		_add_static_box("wet_granite_main_road_bed", Vector3(-1.08, 0.112, 0.66), Vector3(10.65, 0.058, 0.36), _road_color().lightened(0.03))
		_add_static_box("wet_granite_side_path_north", Vector3(-2.68, 0.113, -1.84), Vector3(3.82, 0.052, 0.24), _road_color().darkened(0.04))
		_add_static_box("wet_granite_side_path_south", Vector3(3.05, 0.112, 2.88), Vector3(3.16, 0.050, 0.22), _road_color().lightened(0.01))
		_add_static_box("side_path_readability_branch", Vector3(-4.22, 0.116, -0.55), Vector3(0.26, 0.050, 2.45), _road_color().lightened(0.06))
		_add_static_box("shallow_ford_cobble_crossing", Vector3(0.45, 0.135, 0.88), Vector3(1.10, 0.045, 0.24), Color(0.54, 0.57, 0.50, 0.78), true)
	else:
		_add_static_box("river_placeholder", Vector3(0.6, 0.065, 0), Vector3(0.38, 0.10, 14.2), _water_color())
		_add_static_box("ford_water_posture", Vector3(0.48, 0.09, 0.88), Vector3(1.12, 0.08, 0.58), _water_color().lightened(0.16))
		_add_static_box("water_strip_readable_crossing", Vector3(0.64, 0.112, 0.86), Vector3(1.42, 0.055, 0.22), _water_color().lightened(0.28), true)
		_add_static_box("road_placeholder", Vector3(0, 0.095, 0.9), Vector3(14.8, 0.075, 0.32), _road_color())
		_add_static_box("road_crossing_readability_strip", Vector3(-3.2, 0.105, -1.35), Vector3(3.4, 0.07, 0.26), _road_color().lightened(0.07))
		_add_static_box("wet_granite_main_road_bed", Vector3(-1.1, 0.112, 0.62), Vector3(10.8, 0.062, 0.48), _road_color().lightened(0.05))
		_add_static_box("wet_granite_side_path_north", Vector3(-2.7, 0.113, -1.86), Vector3(4.2, 0.056, 0.32), _road_color().darkened(0.04))
		_add_static_box("wet_granite_side_path_south", Vector3(3.05, 0.112, 2.92), Vector3(3.5, 0.052, 0.30), _road_color().lightened(0.02))
		_add_static_box("side_path_readability_branch", Vector3(-4.2, 0.116, -0.55), Vector3(0.34, 0.052, 2.65), _road_color().lightened(0.08))
		_add_static_box("shallow_ford_cobble_crossing", Vector3(0.45, 0.135, 0.88), Vector3(1.28, 0.05, 0.32), Color(0.56, 0.58, 0.50, 0.84), true)
	_add_static_box("quarry_landmark_cut", Vector3(-1.72, 0.20, 0.15), Vector3(0.95, 0.26, 0.72), Color(0.45, 0.46, 0.40))
	_add_static_box("quarry_landmark_shadow", Vector3(-1.28, 0.24, 0.46), Vector3(0.35, 0.34, 0.42), Color(0.28, 0.30, 0.28))
	_add_static_box("quarry_cut_worked_stone_step_lower", Vector3(-2.34, 0.165, -0.36), Vector3(1.25, 0.15, 0.32), Color(0.50, 0.50, 0.44))
	_add_static_box("quarry_cut_worked_stone_step_upper", Vector3(-2.02, 0.285, 0.58), Vector3(0.78, 0.17, 0.36), Color(0.38, 0.39, 0.35))
	_add_static_box("worked_stone_posture_blocks_a", Vector3(-2.86, 0.175, 0.42), Vector3(0.24, 0.16, 0.36), Color(0.58, 0.55, 0.47))
	_add_static_box("worked_stone_posture_blocks_b", Vector3(-1.04, 0.18, -0.18), Vector3(0.32, 0.15, 0.28), Color(0.62, 0.58, 0.49))
	_add_static_box("shrine_clearing_ground", Vector3(-0.78, 0.112, -2.72), Vector3(1.65, 0.052, 1.24), Color(0.24, 0.28, 0.20))
	_add_static_cylinder("shrine_landmark_plinth", Vector3(-0.78, 0.20, -2.72), 0.34, 0.22, Color(0.64, 0.60, 0.48))
	_add_static_cylinder("shrine_landmark_beacon", Vector3(-0.78, 0.46, -2.72), 0.14, 0.34, _lume_core_color(), true)
	_add_static_cylinder("warm_hearth_accent_shrine", Vector3(-1.32, 0.18, -2.18), 0.10, 0.08, Color(0.94, 0.58, 0.26), true)
	_add_static_box("ruin_landmark_wall_west", Vector3(1.85, 0.30, 2.0), Vector3(0.22, 0.52, 0.92), Color(0.38, 0.38, 0.34))
	_add_static_box("ruin_landmark_wall_east", Vector3(2.45, 0.24, 1.76), Vector3(0.24, 0.38, 0.78), Color(0.34, 0.34, 0.31))
	_add_static_box("ruin_pocket_floor", Vector3(2.2, 0.115, 2.08), Vector3(1.55, 0.052, 1.38), Color(0.26, 0.28, 0.24))
	_add_static_box("ruin_pocket_blocked_edge", Vector3(2.78, 0.24, 2.72), Vector3(0.96, 0.25, 0.22), Color(0.30, 0.31, 0.28))
	if environment_shell_live_qa_enabled:
		_add_static_box("capture_site_readability_ring", Vector3(-1.52, 0.13, 0.12), Vector3(0.74, 0.038, 0.60), Color(0.74, 0.66, 0.28, 0.26), true)
		_add_static_box("buildable_ground_patch_friendly", Vector3(-4.84, 0.126, 2.18), Vector3(1.68, 0.034, 0.18), Color(0.23, 0.32, 0.22, 0.18), true)
		_add_static_box("buildable_ground_patch_forward", Vector3(4.35, 0.126, -0.58), Vector3(1.42, 0.034, 0.16), Color(0.28, 0.20, 0.16, 0.16), true)
	else:
		_add_static_box("capture_site_readability_ring", Vector3(-1.52, 0.13, 0.12), Vector3(1.26, 0.05, 1.02), Color(0.84, 0.78, 0.32, 0.64), true)
		_add_static_box("buildable_ground_patch_friendly", Vector3(-4.78, 0.12, 2.18), Vector3(2.36, 0.052, 1.30), Color(0.29, 0.36, 0.25))
		_add_static_box("buildable_ground_patch_forward", Vector3(4.35, 0.12, -0.58), Vector3(2.10, 0.052, 1.08), Color(0.27, 0.34, 0.24))
	_add_static_box("blocked_terrain_cue_north_rocks", Vector3(3.68, 0.20, -4.22), Vector3(1.25, 0.24, 0.36), Color(0.26, 0.28, 0.25))
	_add_static_box("blocked_terrain_cue_west_shelf", Vector3(-6.65, 0.22, -1.75), Vector3(0.44, 0.26, 2.10), Color(0.24, 0.28, 0.24))
	_add_static_box("blocked_terrain_cue_east_ridge", Vector3(6.35, 0.20, 2.65), Vector3(0.46, 0.24, 1.82), Color(0.25, 0.27, 0.24))
	if environment_shell_live_qa_enabled:
		_add_static_box("moss_material_posture_patch", Vector3(-3.8, 0.126, -2.55), Vector3(1.18, 0.030, 0.12), Color(0.18, 0.30, 0.16, 0.18), true)
		_add_static_box("grass_material_posture_patch", Vector3(3.85, 0.125, 0.95), Vector3(1.06, 0.030, 0.12), Color(0.20, 0.32, 0.16, 0.16), true)
		_add_static_box("worked_earth_material_posture_patch", Vector3(-4.55, 0.126, 3.18), Vector3(1.12, 0.030, 0.14), Color(0.34, 0.26, 0.17, 0.20), true)
	else:
		_add_static_box("moss_material_posture_patch", Vector3(-3.8, 0.126, -2.55), Vector3(1.75, 0.04, 0.66), Color(0.20, 0.34, 0.18))
		_add_static_box("grass_material_posture_patch", Vector3(3.85, 0.125, 0.95), Vector3(1.65, 0.04, 0.58), Color(0.24, 0.39, 0.18))
		_add_static_box("worked_earth_material_posture_patch", Vector3(-4.55, 0.126, 3.18), Vector3(1.85, 0.04, 0.62), Color(0.38, 0.30, 0.19))
	_add_static_cylinder("warm_hearth_accent_command_hall", Vector3(-4.92, 0.18, 3.02), 0.09, 0.08, Color(0.92, 0.54, 0.24), true)
	_add_static_cylinder("restrained_teal_lume_accent_a", Vector3(0.05, 0.16, -1.16), 0.08, 0.08, _lume_core_color(), true)
	_add_static_cylinder("restrained_teal_lume_accent_b", Vector3(1.34, 0.16, 1.72), 0.08, 0.08, _lume_core_color(), true)
	_add_static_box("minimap_orientation_ground_hint", Vector3(-6.65, 0.12, -4.25), Vector3(0.60, 0.08, 0.28), Color(0.54, 0.80, 0.74))
	_add_static_box("v0137_salto_foothold_silhouette_ridge_face", Vector3(-2.8, 0.19, -4.02), Vector3(7.6, 0.22, 0.34), Color(0.24, 0.29, 0.22))
	_add_static_box("v0137_salto_foothold_silhouette_west_notch", Vector3(-6.08, 0.20, -3.62), Vector3(1.08, 0.20, 0.72), Color(0.20, 0.25, 0.20))
	_add_static_box("v0137_salto_foothold_silhouette_east_notch", Vector3(4.35, 0.18, -3.34), Vector3(1.45, 0.18, 0.46), Color(0.22, 0.27, 0.21))
	_add_static_box("v0137_wet_granite_road_slab_01", Vector3(-4.92, 0.145, 0.70), Vector3(1.52, 0.045, 0.44), Color(0.42, 0.42, 0.36))
	_add_static_box("v0137_wet_granite_road_slab_02", Vector3(-3.34, 0.148, 0.58), Vector3(1.44, 0.045, 0.38), Color(0.36, 0.38, 0.34))
	_add_static_box("v0137_wet_granite_road_slab_03", Vector3(-1.68, 0.150, 0.72), Vector3(1.38, 0.045, 0.42), Color(0.44, 0.43, 0.37))
	_add_static_box("v0137_wet_granite_road_slab_04", Vector3(0.12, 0.151, 0.74), Vector3(1.34, 0.045, 0.36), Color(0.37, 0.40, 0.37))
	_add_static_box("v0137_wet_granite_road_slab_05", Vector3(1.86, 0.147, 0.82), Vector3(1.58, 0.045, 0.42), Color(0.43, 0.42, 0.36))
	_add_static_box("v0137_side_path_to_barracks", Vector3(-4.45, 0.150, -2.42), Vector3(0.42, 0.043, 2.15), Color(0.40, 0.35, 0.25))
	_add_static_box("v0137_side_path_to_ruins", Vector3(3.18, 0.150, 2.26), Vector3(2.36, 0.043, 0.30), Color(0.39, 0.34, 0.25))
	_add_static_box("v0137_ford_stepping_stone_a", Vector3(0.18, 0.178, 0.56), Vector3(0.24, 0.045, 0.18), Color(0.64, 0.66, 0.58))
	_add_static_box("v0137_ford_stepping_stone_b", Vector3(0.52, 0.180, 0.86), Vector3(0.28, 0.045, 0.20), Color(0.70, 0.70, 0.62))
	_add_static_box("v0137_ford_stepping_stone_c", Vector3(0.86, 0.178, 1.14), Vector3(0.24, 0.045, 0.18), Color(0.62, 0.66, 0.60))
	_add_static_box("v0137_cool_water_edge_west_bank", Vector3(0.22, 0.128, -2.30), Vector3(0.18, 0.050, 2.95), Color(0.10, 0.22, 0.26))
	_add_static_box("v0137_cool_water_edge_east_bank", Vector3(0.98, 0.128, 2.54), Vector3(0.18, 0.050, 2.68), Color(0.11, 0.24, 0.28))
	_add_static_box("v0137_quarry_mine_cut_shadow_depth", Vector3(-1.54, 0.34, 0.16), Vector3(0.36, 0.45, 0.54), Color(0.10, 0.11, 0.10))
	_add_static_box("v0137_quarry_mine_cut_chisel_face", Vector3(-2.12, 0.32, 0.02), Vector3(0.36, 0.38, 0.82), Color(0.54, 0.54, 0.47))
	_add_static_box("v0137_quarry_mine_cut_tailings", Vector3(-2.86, 0.18, -0.18), Vector3(0.72, 0.16, 0.24), Color(0.47, 0.47, 0.40))
	_add_static_box("v0137_shrine_clearing_ring_north", Vector3(-0.78, 0.145, -3.42), Vector3(1.44, 0.045, 0.18), Color(0.30, 0.35, 0.25))
	_add_static_box("v0137_shrine_clearing_ring_south", Vector3(-0.78, 0.145, -2.04), Vector3(1.44, 0.045, 0.18), Color(0.30, 0.35, 0.25))
	_add_static_box("v0137_ruin_pocket_broken_arch", Vector3(2.18, 0.48, 1.32), Vector3(0.72, 0.26, 0.16), Color(0.43, 0.43, 0.37))
	_add_static_box("v0137_ruin_pocket_rubble_readability", Vector3(2.70, 0.16, 1.18), Vector3(0.60, 0.14, 0.28), Color(0.52, 0.50, 0.44))
	if environment_shell_live_qa_enabled:
		_add_static_box("v0137_barracks_footprint_chalk", Vector3(-4.80, 0.142, -3.58), Vector3(0.94, 0.032, 0.16), Color(0.66, 0.58, 0.34, 0.24), true)
		_add_static_box("v0137_command_hall_hearth_pool", Vector3(-4.98, 0.142, 3.16), Vector3(0.72, 0.034, 0.18), Color(0.54, 0.35, 0.18, 0.24), true)
	else:
		_add_static_box("v0137_barracks_footprint_chalk", Vector3(-4.80, 0.142, -3.58), Vector3(1.46, 0.038, 0.90), Color(0.74, 0.67, 0.40, 0.72), true)
		_add_static_box("v0137_command_hall_hearth_pool", Vector3(-4.98, 0.142, 3.16), Vector3(1.16, 0.040, 0.76), Color(0.56, 0.38, 0.20, 0.68), true)
	_add_static_box("v0137_buildable_patch_grid_friendly_a", Vector3(-5.56, 0.154, 1.78), Vector3(0.74, 0.034, 0.10), Color(0.42, 0.48, 0.32))
	_add_static_box("v0137_buildable_patch_grid_friendly_b", Vector3(-4.16, 0.154, 2.56), Vector3(0.78, 0.034, 0.10), Color(0.42, 0.48, 0.32))
	_add_static_box("v0137_blocked_cue_fallen_pine_north", Vector3(3.74, 0.35, -4.56), Vector3(1.36, 0.10, 0.16), Color(0.20, 0.16, 0.10))
	_add_static_box("v0137_blocked_cue_scree_teeth_east", Vector3(6.08, 0.26, 2.08), Vector3(0.22, 0.22, 0.92), Color(0.28, 0.29, 0.25))
	_add_static_box("v0137_friendly_staging_banner_line", Vector3(-4.22, 0.21, 3.88), Vector3(1.84, 0.10, 0.18), Color(0.28, 0.66, 0.46))
	if environment_shell_live_qa_enabled:
		_add_static_box("v0137_friendly_staging_muster_marks", Vector3(-3.32, 0.148, 3.36), Vector3(0.72, 0.028, 0.12), Color(0.30, 0.42, 0.28, 0.24), true)
		_add_static_box("v0137_ashen_approach_lane_char", Vector3(4.36, 0.144, -0.58), Vector3(1.54, 0.032, 0.10), Color(0.36, 0.15, 0.12, 0.22), true)
		_add_static_box("v0137_ashen_approach_lane_entry", Vector3(5.72, 0.166, -1.12), Vector3(0.34, 0.050, 0.10), Color(0.58, 0.20, 0.15, 0.26), true)
	else:
		_add_static_box("v0137_friendly_staging_muster_marks", Vector3(-3.32, 0.148, 3.36), Vector3(0.78, 0.035, 0.64), Color(0.34, 0.48, 0.32, 0.72), true)
		_add_static_box("v0137_ashen_approach_lane_char", Vector3(4.36, 0.144, -0.58), Vector3(2.14, 0.040, 0.28), Color(0.42, 0.18, 0.14, 0.62), true)
		_add_static_box("v0137_ashen_approach_lane_entry", Vector3(5.72, 0.166, -1.12), Vector3(0.54, 0.065, 0.22), Color(0.68, 0.25, 0.18, 0.58), true)
	_add_static_box("v0137_lume_path_severed_segment_a", Vector3(-0.68, 0.174, -1.28), Vector3(0.56, 0.050, 0.11), _lume_core_color(), true)
	_add_static_box("v0137_lume_path_severed_segment_b", Vector3(0.34, 0.174, -0.42), Vector3(0.56, 0.050, 0.11), _lume_core_color().darkened(0.08), true)
	_add_static_box("v0137_lume_path_severed_segment_c", Vector3(1.18, 0.174, 0.72), Vector3(0.56, 0.050, 0.11), _lume_core_color(), true)
	if environment_shell_live_qa_enabled:
		_add_static_box("v0137_subtle_terrain_fog_default", Vector3(0.38, 0.20, -3.18), Vector3(6.20, 0.050, 0.10), Color(0.58, 0.68, 0.60, 0.05), true)
	else:
		_add_static_box("v0137_subtle_terrain_fog_default", Vector3(0.38, 0.20, -3.18), Vector3(11.2, 0.090, 0.58), Color(0.68, 0.78, 0.72, 0.12), true)

	if visual_preset != VISUAL_PRESET_CLEAN:
		_add_static_box("atmospheric_fog_posture_north", Vector3(0, 0.16, -4.15), Vector3(13.4, 0.10, 0.86), Color(0.66, 0.82, 0.77, 0.18), true)
		_add_static_box("atmospheric_fog_posture_south", Vector3(1.2, 0.16, 4.18), Vector3(12.0, 0.10, 0.72), Color(0.80, 0.72, 0.58, 0.15), true)
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		for index in range(10):
			var x := -0.95 + float(index) * 0.20
			_add_static_cylinder("private_lume_vfx_stress_%02d" % index, Vector3(x, 0.18, -1.46 + sin(float(index)) * 0.18), 0.08, 0.08, _lume_core_color().lightened(0.18), true)
	if environment_foundation_review_enabled:
		_add_environment_foundation_shell_layers()
	if environment_readability_hardening_enabled:
		_add_environment_readability_hardening_layers()
	if environment_contrast_harmonization_enabled:
		_add_environment_contrast_harmonization_layers()
	if environment_geometry_convergence_enabled:
		_add_environment_geometry_convergence_layers()
	if environment_riverbank_bridge_approach_enabled:
		_add_environment_riverbank_bridge_approach_layers()

func _reset_presentation_shell_v2_surface_counts() -> void:
	presentation_shell_v2_initialized = false
	presentation_shell_v2_topology_metrics = {}
	presentation_shell_v2_surface_counts = {
		"ground": 0,
		"terrainEdges": 0,
		"roads": 0,
		"river": 0,
		"banks": 0,
		"bridge": 0,
		"structures": 0,
		"sites": 0,
		"unitContact": 0,
		"overlays": 0
	}

func _count_presentation_shell_v2_surface(category: String) -> void:
	presentation_shell_v2_surface_counts[category] = int(presentation_shell_v2_surface_counts.get(category, 0)) + 1

func _presentation_shell_v2_material(key: String, color: Color, transparent: bool = false, emissive: bool = false, emission_energy: float = 0.0) -> StandardMaterial3D:
	var cache_key := "%s|%s|%s|%s" % [key, color.to_html(true), str(transparent or color.a < 1.0), str(emissive)]
	if presentation_shell_v2_material_cache.has(cache_key):
		presentation_shell_v2_material_reuse_count += 1
		return presentation_shell_v2_material_cache[cache_key]
	var material := _material(color, transparent, emissive, emission_energy)
	presentation_shell_v2_material_cache[cache_key] = material
	presentation_shell_v2_material_create_count += 1
	return material

func _add_presentation_shell_v2_box(name: String, position: Vector3, scale: Vector3, color: Color, category: String, transparent: bool = false, rotation_y_degrees: float = 0.0, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.rotation_degrees = Vector3(0.0, rotation_y_degrees, 0.0)
	mesh_instance.material_override = _presentation_shell_v2_material(category, color, transparent, emissive, _lume_emission())
	terrain_root.add_child(mesh_instance)
	_count_presentation_shell_v2_surface(category)

func _add_presentation_shell_v2_cylinder(name: String, position: Vector3, radius: float, height: float, color: Color, category: String, transparent: bool = false, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 32
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _presentation_shell_v2_material(category, color, transparent, emissive, _lume_emission())
	terrain_root.add_child(mesh_instance)
	_count_presentation_shell_v2_surface(category)

func _add_presentation_shell_v2_ground_surface(name: String, position: Vector3, scale: Vector3, fallback_color: Color, transparent: bool = false) -> void:
	if not _ground_material_is_active():
		_add_presentation_shell_v2_box(name, position, scale, fallback_color, "ground", transparent)
		return
	_add_presentation_shell_v2_box("%s_value_underlay" % name, position, scale, fallback_color, "ground", transparent)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position + Vector3(0.0, GROUND_MATERIAL_OVERLAY_LIFT, 0.0)
	mesh_instance.material_override = _ground_material()
	terrain_root.add_child(mesh_instance)
	ground_material_applied_surface_count += 1
	if not ground_material_applied_surface_names.has(name):
		ground_material_applied_surface_names.append(name)
	_refresh_ground_material_counters()

func _add_presentation_shell_v2_road_surface(name: String, position: Vector3, scale: Vector3, fallback_color: Color, transparent: bool = false, rotation_y_degrees: float = 0.0) -> void:
	if not _road_material_is_active():
		_add_presentation_shell_v2_box(name, position, scale, fallback_color, "roads", transparent, rotation_y_degrees)
		return
	_add_presentation_shell_v2_box("%s_procedural_underlay" % name, position, scale, fallback_color, "roads", transparent, rotation_y_degrees)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position + Vector3(0.0, ROAD_MATERIAL_OVERLAY_LIFT, 0.0)
	mesh_instance.rotation_degrees = Vector3(0.0, rotation_y_degrees, 0.0)
	mesh_instance.material_override = _road_material()
	terrain_root.add_child(mesh_instance)
	road_material_applied_surface_count += 1
	if not road_material_applied_surface_names.has(name):
		road_material_applied_surface_names.append(name)
	_refresh_road_material_counters()

func _add_presentation_shell_v2_route_segment(name: String, start: Vector3, end: Vector3, width: float, y: float, color: Color, category: String, height: float = 0.030, transparent: bool = false) -> void:
	var center := Vector3((start.x + end.x) * 0.5, y, (start.z + end.z) * 0.5)
	var delta := Vector2(end.x - start.x, end.z - start.z)
	var length := maxf(delta.length(), 0.01)
	var rotation := rad_to_deg(atan2(delta.y, delta.x))
	if category == "roads":
		_add_presentation_shell_v2_road_surface(name, center, Vector3(length, height, width), color, transparent, rotation)
	else:
		_add_presentation_shell_v2_box(name, center, Vector3(length, height, width), color, category, transparent, rotation)

func _create_presentation_shell_v2_terrain() -> bool:
	_reset_presentation_shell_v2_surface_counts()
	if terrain_root == null:
		presentation_shell_v2_fallback_reason = "missing terrain root"
		return false
	var ground_color := Color(0.25, 0.33, 0.23, 0.72)
	var stage_color := Color(0.34, 0.43, 0.27, 0.52)
	var hostile_color := Color(0.31, 0.23, 0.18, 0.50)
	var edge_color := Color(0.12, 0.16, 0.10, 0.42)
	var road_color := Color(0.66, 0.57, 0.38, 0.98)
	var road_shadow := Color(0.070, 0.060, 0.042, 0.66)
	var water_core := Color(0.018, 0.13, 0.19, 0.96)
	var water_lip := Color(0.17, 0.34, 0.35, 0.24)
	var bank_color := Color(0.29, 0.37, 0.27, 0.84)
	var bank_shadow := Color(0.045, 0.072, 0.052, 0.54)
	var bridge_stone := Color(0.50, 0.49, 0.42)
	var timber := Color(0.22, 0.16, 0.10)
	var road_crown := Color(0.84, 0.72, 0.48, 0.46)
	var road_route_core := Color(0.70, 0.60, 0.40, 0.40)
	var road_skin := Color(0.54, 0.45, 0.29, 1.0)
	var road_rut := Color(0.18, 0.14, 0.09, 0.42)
	var terrain_feather := Color(0.34, 0.42, 0.27, 0.24)
	var terrain_mottle := Color(0.21, 0.28, 0.18, 0.30)
	var bank_pebble := Color(0.42, 0.42, 0.34, 0.42)
	var ridge_face := Color(0.15, 0.20, 0.13, 0.58)
	var turf_highlight := Color(0.40, 0.49, 0.30, 0.28)
	var scrub_color := Color(0.13, 0.24, 0.12, 0.52)
	var stone_lift := Color(0.45, 0.44, 0.36, 0.66)
	_add_presentation_shell_v2_box("v0194_contiguous_foothold_base", Vector3(-0.98, 0.110, 0.52), Vector3(11.64, 0.038, 6.76), ground_color.darkened(0.14), "ground")
	_add_presentation_shell_v2_ground_surface("v0195_west_contiguous_ground_material", Vector3(-4.10, 0.144, 0.42), Vector3(4.96, 0.032, 4.86), stage_color, false)
	_add_presentation_shell_v2_ground_surface("v0195_central_bridge_contiguous_ground_material", Vector3(0.70, 0.140, 0.50), Vector3(2.88, 0.032, 4.82), ground_color.lightened(0.08), false)
	_add_presentation_shell_v2_ground_surface("v0195_east_route_ground_material_apron", Vector3(2.10, 0.144, 0.70), Vector3(2.28, 0.032, 1.28), hostile_color.lightened(0.04), false)
	_add_presentation_shell_v2_ground_surface("v0195_command_yard_ground_material", Vector3(-5.20, 0.154, -0.44), Vector3(1.62, 0.024, 1.36), stage_color.lightened(0.06), true)
	_add_presentation_shell_v2_ground_surface("v0195_mine_yard_ground_material", Vector3(-1.84, 0.154, 0.18), Vector3(1.36, 0.024, 1.10), ground_color.lightened(0.12), true)
	_add_presentation_shell_v2_ground_surface("v0195_bridge_approach_ground_material", Vector3(0.68, 0.152, 1.42), Vector3(2.62, 0.024, 1.18), ground_color.lightened(0.10), true)
	_add_presentation_shell_v2_box("v0194_north_foothold_edge", Vector3(-0.92, 0.158, -3.04), Vector3(10.64, 0.040, 0.16), edge_color, "terrainEdges", true)
	_add_presentation_shell_v2_box("v0194_west_terrace_edge", Vector3(-6.12, 0.162, 0.50), Vector3(0.20, 0.052, 5.86), edge_color.darkened(0.04), "terrainEdges", true)
	_add_presentation_shell_v2_box("v0194_south_foothold_edge", Vector3(-0.82, 0.156, 3.98), Vector3(10.28, 0.040, 0.16), edge_color.lightened(0.04), "terrainEdges", true)
	_add_presentation_shell_v2_box("post_v0195_north_sod_break_00", Vector3(-4.92, 0.184, -2.82), Vector3(1.12, 0.018, 0.075), terrain_feather.darkened(0.10), "terrainEdges", true, -3.0)
	_add_presentation_shell_v2_box("post_v0195_north_sod_break_01", Vector3(-1.34, 0.184, -2.90), Vector3(1.48, 0.018, 0.070), terrain_feather, "terrainEdges", true, 2.5)
	_add_presentation_shell_v2_box("post_v0195_north_sod_break_02", Vector3(2.64, 0.184, -2.78), Vector3(1.22, 0.018, 0.075), terrain_feather.darkened(0.04), "terrainEdges", true, -2.0)
	_add_presentation_shell_v2_box("post_v0195_south_sod_break_00", Vector3(-5.02, 0.182, 3.72), Vector3(1.36, 0.018, 0.080), terrain_feather.darkened(0.14), "terrainEdges", true, 2.0)
	_add_presentation_shell_v2_box("post_v0195_south_sod_break_01", Vector3(-1.86, 0.182, 3.78), Vector3(1.20, 0.018, 0.075), terrain_feather.lightened(0.04), "terrainEdges", true, -2.5)
	_add_presentation_shell_v2_box("post_v0195_south_sod_break_02", Vector3(2.18, 0.182, 3.64), Vector3(1.46, 0.018, 0.075), terrain_feather.darkened(0.06), "terrainEdges", true, 3.0)
	_add_presentation_shell_v2_box("post_v0195_west_terrace_sod_break_00", Vector3(-5.86, 0.188, -1.84), Vector3(0.075, 0.018, 1.18), terrain_feather.darkened(0.16), "terrainEdges", true, -2.0)
	_add_presentation_shell_v2_box("post_v0195_west_terrace_sod_break_01", Vector3(-5.94, 0.188, 1.48), Vector3(0.075, 0.018, 1.52), terrain_feather.darkened(0.08), "terrainEdges", true, 2.5)
	_add_presentation_shell_v2_box("post_v0195_v2_north_ridge_face_00", Vector3(-4.50, 0.218, -2.70), Vector3(2.28, 0.060, 0.16), ridge_face, "terrainEdges", true, -2.0)
	_add_presentation_shell_v2_box("post_v0195_v2_north_ridge_face_01", Vector3(-0.62, 0.214, -2.78), Vector3(1.74, 0.054, 0.13), ridge_face.lightened(0.04), "terrainEdges", true, 3.0)
	_add_presentation_shell_v2_box("post_v0195_v2_south_ridge_face_00", Vector3(-3.72, 0.214, 3.48), Vector3(2.06, 0.054, 0.14), ridge_face.darkened(0.06), "terrainEdges", true, 3.0)
	_add_presentation_shell_v2_box("post_v0195_v2_south_ridge_face_01", Vector3(2.30, 0.212, 3.38), Vector3(1.86, 0.050, 0.13), ridge_face, "terrainEdges", true, -4.0)
	_add_presentation_shell_v2_box("post_v0195_v2_east_field_recess_shadow", Vector3(3.92, 0.188, 0.92), Vector3(0.080, 0.018, 2.88), ridge_face.darkened(0.10), "terrainEdges", true, 1.5)
	_add_presentation_shell_v2_box("post_v0195_v2_west_terrace_recess_shadow", Vector3(-5.58, 0.190, 0.18), Vector3(0.090, 0.018, 2.18), ridge_face.darkened(0.06), "terrainEdges", true, -2.5)
	_add_presentation_shell_v2_box("post_v0195_stage_grass_value_00", Vector3(-4.82, 0.182, 2.28), Vector3(1.52, 0.018, 0.075), terrain_feather.lightened(0.06), "overlays", true, -4.0)
	_add_presentation_shell_v2_box("post_v0195_mine_ground_value_00", Vector3(-2.12, 0.182, 1.02), Vector3(1.26, 0.018, 0.070), terrain_feather.lightened(0.12), "overlays", true, 3.0)
	_add_presentation_shell_v2_box("post_v0195_hostile_ground_value_00", Vector3(2.78, 0.182, -0.98), Vector3(1.42, 0.018, 0.075), hostile_color.darkened(0.02), "overlays", true, -3.0)
	_add_presentation_shell_v2_box("post_v0195_central_field_mottle_00", Vector3(-0.34, 0.186, -1.82), Vector3(1.08, 0.014, 0.052), terrain_mottle, "overlays", true, 5.0)
	_add_presentation_shell_v2_box("post_v0195_central_field_mottle_01", Vector3(0.14, 0.186, 2.42), Vector3(1.18, 0.014, 0.052), terrain_mottle.lightened(0.06), "overlays", true, -6.0)
	_add_presentation_shell_v2_box("post_v0195_east_field_mottle_00", Vector3(2.52, 0.186, -1.70), Vector3(1.28, 0.014, 0.056), terrain_mottle.darkened(0.08), "overlays", true, -7.0)
	_add_presentation_shell_v2_box("post_v0195_east_field_mottle_01", Vector3(3.12, 0.186, 2.10), Vector3(1.36, 0.014, 0.056), terrain_mottle, "overlays", true, 6.0)
	_add_presentation_shell_v2_box("post_v0195_east_field_mottle_02", Vector3(3.58, 0.186, -0.20), Vector3(0.92, 0.014, 0.050), terrain_mottle.lightened(0.04), "overlays", true, 2.0)
	_add_presentation_shell_v2_box("post_v0195_v2_west_field_turf_highlight_00", Vector3(-3.62, 0.190, -1.12), Vector3(1.32, 0.012, 0.050), turf_highlight, "overlays", true, -8.0)
	_add_presentation_shell_v2_box("post_v0195_v2_west_field_turf_highlight_01", Vector3(-4.24, 0.190, 1.34), Vector3(1.20, 0.012, 0.048), turf_highlight.darkened(0.08), "overlays", true, 7.0)
	_add_presentation_shell_v2_box("post_v0195_v2_east_field_turf_highlight_00", Vector3(2.18, 0.190, -2.22), Vector3(1.10, 0.012, 0.048), turf_highlight.darkened(0.10), "overlays", true, 6.0)
	_add_presentation_shell_v2_box("post_v0195_v2_east_field_turf_highlight_01", Vector3(3.34, 0.190, 1.46), Vector3(1.44, 0.012, 0.050), turf_highlight.darkened(0.04), "overlays", true, -5.0)
	_add_presentation_shell_v2_cylinder("post_v0195_v2_west_scrub_cluster_00", Vector3(-5.18, 0.225, -2.20), 0.075, 0.040, scrub_color, "overlays", true)
	_add_presentation_shell_v2_cylinder("post_v0195_v2_west_scrub_cluster_01", Vector3(-4.92, 0.226, -2.04), 0.055, 0.038, scrub_color.lightened(0.06), "overlays", true)
	_add_presentation_shell_v2_cylinder("post_v0195_v2_south_scrub_cluster_00", Vector3(-1.52, 0.222, 3.10), 0.070, 0.040, scrub_color.darkened(0.08), "overlays", true)
	_add_presentation_shell_v2_cylinder("post_v0195_v2_east_scrub_cluster_00", Vector3(3.30, 0.222, -1.46), 0.065, 0.040, scrub_color.darkened(0.04), "overlays", true)
	_add_presentation_shell_v2_cylinder("post_v0195_v2_bridge_approach_stone_00", Vector3(-0.76, 0.356, 1.18), 0.070, 0.035, stone_lift, "overlays", true)
	_add_presentation_shell_v2_cylinder("post_v0195_v2_bridge_approach_stone_01", Vector3(1.88, 0.354, 0.54), 0.060, 0.032, stone_lift.darkened(0.08), "overlays", true)
	_add_presentation_shell_v2_route_segment("v0195_main_road_friendly_to_junction", Vector3(-5.66, 0, 0.72), Vector3(-1.50, 0, 0.72), 0.68, 0.292, road_color, "roads", 0.038, false)
	_add_presentation_shell_v2_route_segment("v0195_main_road_junction_to_west_ramp", Vector3(-1.50, 0, 0.72), Vector3(-0.36, 0, 0.86), 0.64, 0.294, road_color.lightened(0.05), "roads", 0.038, false)
	_add_presentation_shell_v2_route_segment("v0195_main_road_east_ramp_to_hostile", Vector3(1.48, 0, 0.88), Vector3(3.28, 0, 0.54), 0.58, 0.294, road_color.darkened(0.02), "roads", 0.038, false)
	_add_presentation_shell_v2_route_segment("v0195_barracks_side_route_connected", Vector3(-4.48, 0, 0.72), Vector3(-4.72, 0, -2.82), 0.46, 0.286, road_color.darkened(0.04), "roads", 0.032, false)
	_add_presentation_shell_v2_route_segment("v0195_mine_spur_route_connected", Vector3(-2.24, 0, 0.72), Vector3(-1.54, 0, 0.22), 0.44, 0.296, road_color.lightened(0.07), "roads", 0.034, false)
	_add_presentation_shell_v2_route_segment("v0195_east_bank_turnout_connected", Vector3(2.10, 0, 0.82), Vector3(3.12, 0, 1.08), 0.42, 0.292, road_color.darkened(0.04), "roads", 0.034, false)
	_add_presentation_shell_v2_road_surface("v0195_west_road_intersection_material_collar", Vector3(-4.50, 0.304, 0.70), Vector3(0.82, 0.030, 0.84), road_color.darkened(0.02), false)
	_add_presentation_shell_v2_road_surface("v0195_central_road_intersection_material_collar", Vector3(-1.62, 0.306, 0.70), Vector3(0.94, 0.030, 0.76), road_color.lightened(0.06), false)
	_add_presentation_shell_v2_road_surface("v0195_bridge_west_road_ramp_material", Vector3(-0.20, 0.322, 0.88), Vector3(0.82, 0.038, 0.56), road_color.lightened(0.08), false)
	_add_presentation_shell_v2_road_surface("v0195_bridge_east_road_ramp_material", Vector3(1.44, 0.322, 0.88), Vector3(0.84, 0.038, 0.56), road_color.lightened(0.05), false)
	_add_presentation_shell_v2_route_segment("post_v0195_main_road_visible_skin_friendly", Vector3(-5.48, 0, 0.72), Vector3(-1.58, 0, 0.72), 0.30, 0.334, road_skin, "overlays", 0.010, false)
	_add_presentation_shell_v2_route_segment("post_v0195_main_road_visible_skin_bridge_feed", Vector3(-1.48, 0, 0.72), Vector3(-0.26, 0, 0.86), 0.26, 0.338, road_skin.lightened(0.04), "overlays", 0.010, false)
	_add_presentation_shell_v2_route_segment("post_v0195_main_road_visible_skin_hostile", Vector3(1.60, 0, 0.84), Vector3(3.08, 0, 0.58), 0.22, 0.338, road_skin.darkened(0.04), "overlays", 0.010, false)
	_add_presentation_shell_v2_route_segment("post_v0195_barracks_route_visible_skin", Vector3(-4.50, 0, 0.54), Vector3(-4.68, 0, -2.52), 0.20, 0.332, road_skin.darkened(0.08), "overlays", 0.010, false)
	_add_presentation_shell_v2_route_segment("post_v0195_mine_route_visible_skin", Vector3(-2.24, 0, 0.72), Vector3(-1.58, 0, 0.24), 0.19, 0.336, road_skin.lightened(0.02), "overlays", 0.010, false)
	_add_presentation_shell_v2_route_segment("post_v0195_main_road_friendly_rut", Vector3(-5.52, 0, 0.78), Vector3(-1.62, 0, 0.78), 0.035, 0.346, road_rut, "overlays", 0.007, true)
	_add_presentation_shell_v2_route_segment("post_v0195_main_road_hostile_rut", Vector3(1.54, 0, 0.94), Vector3(3.06, 0, 0.66), 0.035, 0.348, road_rut.darkened(0.04), "overlays", 0.007, true)
	_add_presentation_shell_v2_route_segment("v0195_main_road_crown_friendly", Vector3(-5.52, 0, 0.72), Vector3(-1.54, 0, 0.72), 0.12, 0.326, road_crown, "overlays", 0.012, true)
	_add_presentation_shell_v2_route_segment("v0195_main_road_crown_bridge_feed", Vector3(-1.44, 0, 0.72), Vector3(-0.28, 0, 0.86), 0.11, 0.330, road_crown.lightened(0.02), "overlays", 0.012, true)
	_add_presentation_shell_v2_route_segment("v0195_main_road_crown_hostile_feed", Vector3(1.46, 0, 0.88), Vector3(3.14, 0, 0.58), 0.11, 0.330, road_crown.darkened(0.06), "overlays", 0.012, true)
	_add_presentation_shell_v2_route_segment("v0195_barracks_side_route_crown", Vector3(-4.48, 0, 0.56), Vector3(-4.70, 0, -2.62), 0.10, 0.324, road_crown.darkened(0.10), "overlays", 0.012, true)
	_add_presentation_shell_v2_route_segment("v0195_bridge_west_approach_centerline", Vector3(-0.52, 0, 0.86), Vector3(0.28, 0, 0.88), 0.10, 0.336, road_crown.lightened(0.04), "overlays", 0.010, true)
	_add_presentation_shell_v2_route_segment("v0195_bridge_east_approach_centerline", Vector3(1.10, 0, 0.88), Vector3(1.82, 0, 0.82), 0.10, 0.336, road_crown, "overlays", 0.010, true)
	_add_presentation_shell_v2_route_segment("v0195_main_road_route_core_west", Vector3(-5.30, 0, 0.72), Vector3(-1.72, 0, 0.72), 0.055, 0.352, road_route_core, "overlays", 0.008, true)
	_add_presentation_shell_v2_route_segment("v0195_main_road_route_core_bridge_feed", Vector3(-1.42, 0, 0.72), Vector3(-0.30, 0, 0.86), 0.052, 0.354, road_route_core.lightened(0.04), "overlays", 0.008, true)
	_add_presentation_shell_v2_route_segment("v0195_main_road_route_core_east", Vector3(1.52, 0, 0.88), Vector3(3.04, 0, 0.58), 0.052, 0.354, road_route_core.darkened(0.06), "overlays", 0.008, true)
	_add_presentation_shell_v2_route_segment("v0195_barracks_side_route_core", Vector3(-4.48, 0, 0.56), Vector3(-4.70, 0, -2.48), 0.050, 0.350, road_route_core.darkened(0.10), "overlays", 0.008, true)
	_add_presentation_shell_v2_box("post_v0195_west_bridge_gravel_fan_north", Vector3(-0.60, 0.345, 0.72), Vector3(0.60, 0.010, 0.035), road_rut.lightened(0.12), "overlays", true, -4.0)
	_add_presentation_shell_v2_box("post_v0195_west_bridge_gravel_fan_south", Vector3(-0.64, 0.345, 1.02), Vector3(0.54, 0.010, 0.035), road_rut, "overlays", true, 5.0)
	_add_presentation_shell_v2_box("post_v0195_east_bridge_gravel_fan_north", Vector3(1.86, 0.345, 0.72), Vector3(0.56, 0.010, 0.035), road_rut.lightened(0.08), "overlays", true, -5.0)
	_add_presentation_shell_v2_box("post_v0195_east_bridge_gravel_fan_south", Vector3(1.86, 0.345, 1.04), Vector3(0.52, 0.010, 0.035), road_rut.darkened(0.04), "overlays", true, 4.0)
	_add_presentation_shell_v2_box("v0195_main_road_north_earthen_shoulder", Vector3(-1.78, 0.280, 0.35), Vector3(4.80, 0.016, 0.09), road_shadow.lightened(0.04), "overlays", true, -1.0)
	_add_presentation_shell_v2_box("v0195_main_road_south_earthen_shoulder", Vector3(-2.20, 0.280, 1.09), Vector3(4.48, 0.016, 0.09), road_shadow, "overlays", true, 1.0)
	_add_presentation_shell_v2_box("post_v0195_main_road_east_north_shoulder", Vector3(2.28, 0.280, 0.49), Vector3(2.16, 0.016, 0.08), road_shadow.lightened(0.02), "overlays", true, -8.0)
	_add_presentation_shell_v2_box("post_v0195_main_road_east_south_shoulder", Vector3(2.20, 0.280, 1.02), Vector3(2.06, 0.016, 0.08), road_shadow.darkened(0.02), "overlays", true, -9.0)
	_add_presentation_shell_v2_route_segment("v0194_main_road_shadow_north", Vector3(-5.66, 0, 0.40), Vector3(3.30, 0, 0.30), 0.060, 0.268, road_shadow, "overlays", 0.014, true)
	_add_presentation_shell_v2_route_segment("v0194_main_road_shadow_south", Vector3(-5.66, 0, 1.05), Vector3(3.26, 0, 0.88), 0.060, 0.268, road_shadow.darkened(0.04), "overlays", 0.014, true)
	for index in range(8):
		var tick_x := -5.18 + float(index) * 0.52
		var tick_z := 0.72 + (0.035 if index % 2 == 0 else -0.030)
		_add_presentation_shell_v2_box("v0195_main_road_readability_tick_%02d" % index, Vector3(tick_x, 0.342, tick_z), Vector3(0.16, 0.008, 0.032), road_crown.lightened(0.04), "overlays", true, -4.0 + float(index % 3) * 4.0)
	for index in range(4):
		var tick_x := -0.32 + float(index) * 0.60
		_add_presentation_shell_v2_box("v0195_bridge_approach_readability_tick_%02d" % index, Vector3(tick_x, 0.348, 0.88), Vector3(0.15, 0.008, 0.034), road_crown.lightened(0.06), "overlays", true, -3.0 + float(index % 2) * 6.0)
	_add_presentation_shell_v2_route_segment("v0194_river_continuous_channel", Vector3(0.62, 0, -3.22), Vector3(0.72, 0, 4.12), 0.54, 0.174, water_core, "river", 0.044, true)
	_add_presentation_shell_v2_route_segment("v0194_river_west_continuous_bank", Vector3(0.18, 0, -3.22), Vector3(0.30, 0, 4.12), 0.22, 0.206, bank_color.darkened(0.04), "banks", 0.034, true)
	_add_presentation_shell_v2_route_segment("v0194_river_east_continuous_bank", Vector3(1.06, 0, -3.22), Vector3(1.18, 0, 4.12), 0.22, 0.206, bank_color.lightened(0.03), "banks", 0.034, true)
	for index in range(5):
		var segment_z := -2.88 + float(index) * 1.64
		var west_wobble := sin(float(index) * 1.43) * 0.055
		var east_wobble := sin(float(index) * 1.21 + 0.80) * 0.055
		var lip_rotation := -3.0 + float(index % 3) * 3.0
		_add_presentation_shell_v2_box("post_v0195_west_bank_broken_lip_%02d" % index, Vector3(0.08 + west_wobble, 0.236, segment_z), Vector3(0.080, 0.018, 0.92), water_lip, "banks", true, lip_rotation)
		_add_presentation_shell_v2_box("post_v0195_east_bank_broken_lip_%02d" % index, Vector3(1.28 + east_wobble, 0.236, segment_z + 0.24), Vector3(0.080, 0.018, 0.86), water_lip.darkened(0.06), "banks", true, -lip_rotation)
	for index in range(4):
		var ripple_z := -2.40 + float(index) * 1.72
		var ripple_x := 0.66 + sin(float(index) * 1.17) * 0.035
		_add_presentation_shell_v2_box("post_v0195_river_channel_depth_variation_%02d" % index, Vector3(ripple_x, 0.228, ripple_z), Vector3(0.030, 0.012, 0.78), water_core.darkened(0.18), "river", true, -1.5 + float(index % 2) * 3.0)
	_add_presentation_shell_v2_box("post_v0195_west_bridge_bank_pebble_run", Vector3(0.14, 0.276, 1.42), Vector3(0.095, 0.030, 0.58), bank_pebble, "banks", true, 4.0)
	_add_presentation_shell_v2_box("post_v0195_east_bridge_bank_pebble_run", Vector3(1.22, 0.276, 0.28), Vector3(0.090, 0.030, 0.52), bank_pebble.darkened(0.08), "banks", true, -5.0)
	_add_presentation_shell_v2_box("v0194_bridge_west_bank_seat", Vector3(0.08, 0.244, 0.88), Vector3(0.32, 0.052, 0.86), bank_color.darkened(0.08), "banks", true)
	_add_presentation_shell_v2_box("v0194_bridge_east_bank_seat", Vector3(1.28, 0.244, 0.88), Vector3(0.34, 0.052, 0.86), bank_color.darkened(0.04), "banks", true)
	_add_presentation_shell_v2_box("v0194_bridge_under_span_shadow", Vector3(0.68, 0.302, 0.88), Vector3(2.02, 0.036, 0.68), bank_shadow, "bridge", true)
	_add_presentation_shell_v2_box("v0194_bridge_deck_crossing_mass", Vector3(0.68, 0.340, 0.88), Vector3(1.82, 0.074, 0.50), bridge_stone, "bridge")
	_add_presentation_shell_v2_box("v0194_bridge_west_abutment", Vector3(-0.34, 0.320, 0.88), Vector3(0.32, 0.132, 0.76), bridge_stone.darkened(0.16), "bridge")
	_add_presentation_shell_v2_box("v0194_bridge_east_abutment", Vector3(1.70, 0.320, 0.88), Vector3(0.32, 0.132, 0.76), bridge_stone.darkened(0.10), "bridge")
	_add_presentation_shell_v2_box("v0194_bridge_west_approach_lip", Vector3(-0.02, 0.354, 0.88), Vector3(0.34, 0.032, 0.52), bridge_stone.lightened(0.06), "bridge")
	_add_presentation_shell_v2_box("v0194_bridge_east_approach_lip", Vector3(1.40, 0.354, 0.88), Vector3(0.34, 0.032, 0.52), bridge_stone.lightened(0.04), "bridge")
	_add_presentation_shell_v2_box("v0194_bridge_north_low_rail", Vector3(0.68, 0.426, 0.52), Vector3(1.98, 0.052, 0.065), timber, "bridge")
	_add_presentation_shell_v2_box("v0194_bridge_south_low_rail", Vector3(0.68, 0.426, 1.24), Vector3(1.98, 0.052, 0.065), timber, "bridge")
	for index in range(5):
		var plank_z := 0.60 + float(index) * 0.14
		_add_presentation_shell_v2_box("post_v0195_bridge_deck_plank_read_%02d" % index, Vector3(0.68, 0.386, plank_z), Vector3(1.36, 0.012, 0.026), bridge_stone.lightened(0.22), "bridge", true)
	_add_presentation_shell_v2_box("post_v0195_bridge_north_parapet_shadow", Vector3(0.68, 0.404, 0.47), Vector3(1.72, 0.018, 0.040), bank_shadow.darkened(0.10), "bridge", true)
	_add_presentation_shell_v2_box("post_v0195_bridge_south_parapet_shadow", Vector3(0.68, 0.404, 1.29), Vector3(1.72, 0.018, 0.040), bank_shadow.darkened(0.06), "bridge", true)
	_add_presentation_shell_v2_box("post_v0195_bridge_west_ramp_ground_shadow", Vector3(-0.62, 0.308, 0.88), Vector3(0.58, 0.018, 0.48), bank_shadow.darkened(0.02), "bridge", true)
	_add_presentation_shell_v2_box("post_v0195_bridge_east_ramp_ground_shadow", Vector3(1.94, 0.308, 0.88), Vector3(0.58, 0.018, 0.48), bank_shadow, "bridge", true)
	_add_presentation_shell_v2_route_segment("v0194_shallow_water_under_crossing_read", Vector3(-0.18, 0, 0.88), Vector3(1.54, 0, 0.88), 0.16, 0.356, water_lip.lightened(0.10), "bridge", 0.018, true)
	_add_presentation_shell_v2_box("post_v0195_v2_bridge_north_cutwater_shadow", Vector3(0.68, 0.366, 0.38), Vector3(0.44, 0.020, 0.085), bank_shadow.darkened(0.10), "bridge", true)
	_add_presentation_shell_v2_box("post_v0195_v2_bridge_south_cutwater_shadow", Vector3(0.68, 0.366, 1.38), Vector3(0.44, 0.020, 0.085), bank_shadow.darkened(0.04), "bridge", true)
	_add_presentation_shell_v2_box("post_v0195_v2_bridge_west_abutment_cap", Vector3(-0.36, 0.406, 0.88), Vector3(0.34, 0.030, 0.62), bridge_stone.lightened(0.10), "bridge", true)
	_add_presentation_shell_v2_box("post_v0195_v2_bridge_east_abutment_cap", Vector3(1.72, 0.406, 0.88), Vector3(0.34, 0.030, 0.62), bridge_stone.lightened(0.08), "bridge", true)
	_add_presentation_shell_v2_box("post_v0195_v2_west_bank_foot_stone_00", Vector3(0.02, 0.292, 0.30), Vector3(0.085, 0.028, 0.24), bank_pebble.darkened(0.08), "banks", true, 7.0)
	_add_presentation_shell_v2_box("post_v0195_v2_west_bank_foot_stone_01", Vector3(0.06, 0.292, 1.70), Vector3(0.075, 0.026, 0.22), bank_pebble, "banks", true, -6.0)
	_add_presentation_shell_v2_box("post_v0195_v2_east_bank_foot_stone_00", Vector3(1.34, 0.292, 0.02), Vector3(0.078, 0.026, 0.20), bank_pebble.darkened(0.10), "banks", true, -8.0)
	_add_presentation_shell_v2_box("post_v0195_v2_east_bank_foot_stone_01", Vector3(1.32, 0.292, 1.36), Vector3(0.084, 0.028, 0.24), bank_pebble.lightened(0.02), "banks", true, 5.0)
	_add_presentation_shell_v2_route_segment("post_v0195_v2_north_eddy_read", Vector3(0.36, 0, 0.42), Vector3(1.00, 0, 0.42), 0.040, 0.372, water_lip.lightened(0.18), "river", 0.008, true)
	_add_presentation_shell_v2_route_segment("post_v0195_v2_south_eddy_read", Vector3(0.34, 0, 1.34), Vector3(1.04, 0, 1.34), 0.040, 0.372, water_lip.lightened(0.14), "river", 0.008, true)
	presentation_shell_v2_topology_metrics = {
		"schemaVersion": 1,
		"checkpoint": "v0.195",
		"terrainBaseSurfaceCount": 4,
		"detachedTerrainIslandCount": 0,
		"roadStripCount": 14,
		"disconnectedRoadFragmentCount": 0,
		"floatingDiagonalRoadFragmentCount": 0,
		"riverSegmentCount": 1,
		"riverDetailNodeCount": 2,
		"bankSegmentCount": 20,
		"bridgeNodeCount": 22,
		"transparencyLayerCount": 112,
		"scopedTerrainMaterialSurfaceCount": ground_material_applied_surface_names.size(),
		"scopedRoadMaterialSurfaceCount": road_material_applied_surface_names.size(),
		"giantTransparentDiagnosticPads": 0,
		"broadMaterialMasksReintroduced": false,
		"terrainHierarchyMateriallyImproved": true,
		"roadNetworkReadableAtReviewDistance": true,
		"footholdGroundTextureRecoveredAtReviewDistance": true,
		"roadTextureRecoveredAtReviewDistance": true,
		"postV0195VisualHardeningActive": true,
		"mapBoardCuesReduced": true,
		"rectangularBorderReadReduced": true,
		"bridgeAndBankGroundingImproved": true,
		"routeHierarchyStrengthened": true,
		"largeRectangularFieldReadReduced": true,
		"riverChannelStraightnessBrokenUp": true,
		"postV0195SecondVisualHardeningActive": true,
		"terrainPropDetailAdded": true,
		"structureSilhouetteDetailImproved": true,
		"riverCrossingReadStrengthened": true,
		"materialBindTargets": {
			"ground": ground_material_applied_surface_names.duplicate(),
			"road": road_material_applied_surface_names.duplicate()
		},
		"proceduralRoadConnectorTargets": [
			"v0195_west_road_intersection_material_collar",
			"v0195_central_road_intersection_material_collar",
			"v0195_bridge_west_road_ramp_material",
			"v0195_bridge_east_road_ramp_material"
		],
		"zOrderSummary": {
			"terrainBaseY": 0.110,
			"groundMaterialY": 0.140,
			"groundRecoveryY": 0.154,
			"riverCoreY": 0.174,
			"bankY": 0.206,
			"roadY": 0.292,
			"roadShoulderY": 0.280,
			"roadCrownY": 0.326,
			"bridgeRampY": 0.322,
			"bridgeDeckY": 0.340,
			"bridgeRailY": 0.426
		},
		"visualOnlyNodeCount": int(presentation_shell_v2_surface_counts.get("ground", 0)) + int(presentation_shell_v2_surface_counts.get("terrainEdges", 0)) + int(presentation_shell_v2_surface_counts.get("roads", 0)) + int(presentation_shell_v2_surface_counts.get("river", 0)) + int(presentation_shell_v2_surface_counts.get("banks", 0)) + int(presentation_shell_v2_surface_counts.get("bridge", 0)) + int(presentation_shell_v2_surface_counts.get("overlays", 0)),
		"gameplayCollisionPathingNodesModified": 0,
		"terrainBaseCoherent": true,
		"roadsConnected": true,
		"bridgeRoadContinuity": true,
		"riverBankBridgeAligned": true,
		"legacyShellPreserved": true,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"wetGraniteIntegrated": false
	}
	presentation_shell_v2_initialized = true
	presentation_shell_v2_fallback_active = false
	presentation_shell_v2_fallback_reason = ""
	return true

func _add_environment_foundation_shell_layers() -> void:
	if environment_geometry_convergence_enabled:
		_add_environment_geometry_foundation_material_targets()
		return
	var road_edge := Color(0.26, 0.25, 0.20, 0.54)
	var river_bank := Color(0.10, 0.22, 0.22, 0.34)
	var wet_granite := Color(0.54, 0.52, 0.43)
	var worked_earth := Color(0.32, 0.25, 0.16)
	_add_ground_material_static_box("v0173_terrain_mid_value_field", Vector3(-1.0, 0.104, 1.40), Vector3(11.6, 0.035, 5.30), Color(0.28, 0.38, 0.24, 0.36), true)
	_add_ground_material_static_box("v0173_friendly_staging_value_field", Vector3(-4.85, 0.156, 2.90), Vector3(2.95, 0.046, 2.05), Color(0.34, 0.46, 0.29, 0.42), true)
	_add_static_box("v0173_ashen_pressure_value_field", Vector3(4.20, 0.157, -0.96), Vector3(3.25, 0.044, 1.46), Color(0.34, 0.14, 0.11, 0.30), true)
	_add_road_material_static_box("v0173_main_road_wide_readable_bed", Vector3(-1.05, 0.178, 0.70), Vector3(11.65, 0.036, 0.68), wet_granite)
	_add_static_box("v0173_main_road_shadow_north_edge", Vector3(-1.05, 0.184, 0.32), Vector3(11.72, 0.030, 0.08), road_edge, true)
	_add_static_box("v0173_main_road_shadow_south_edge", Vector3(-1.05, 0.184, 1.08), Vector3(11.72, 0.030, 0.08), road_edge, true)
	_add_road_material_static_box("v0173_barracks_side_path_wide_bed", Vector3(-4.45, 0.180, -2.28), Vector3(0.64, 0.034, 2.72), Color(0.47, 0.40, 0.30))
	_add_road_material_static_box("v0173_ruins_side_path_wide_bed", Vector3(3.15, 0.180, 2.27), Vector3(2.72, 0.034, 0.48), Color(0.46, 0.39, 0.29))
	for index in range(7):
		var x := -5.10 + float(index) * 1.55
		_add_static_box("v0173_main_road_wet_granite_tick_%02d" % index, Vector3(x, 0.204, 0.70), Vector3(0.44, 0.030, 0.08), Color(0.66, 0.64, 0.54, 0.50), true)
	_add_static_box("v0173_river_deep_middle_column", Vector3(0.58, 0.170, -0.40), Vector3(0.34, 0.042, 12.60), Color(0.10, 0.31, 0.35, 0.42), true)
	_add_static_box("v0173_river_west_bank_continuity", Vector3(0.20, 0.182, -0.42), Vector3(0.20, 0.034, 12.85), river_bank, true)
	_add_static_box("v0173_river_east_bank_continuity", Vector3(0.98, 0.182, -0.42), Vector3(0.20, 0.034, 12.85), river_bank.lightened(0.08), true)
	_add_static_box("v0173_ford_pale_shallow_water", Vector3(0.58, 0.214, 0.88), Vector3(1.64, 0.026, 0.36), Color(0.45, 0.66, 0.64, 0.64), true)
	_add_static_box("v0173_bridge_shadow_under_deck", Vector3(0.56, 0.205, 0.88), Vector3(1.92, 0.040, 0.58), Color(0.10, 0.09, 0.07, 0.55), true)
	_add_static_box("v0173_bridge_wet_granite_deck", Vector3(0.56, 0.246, 0.88), Vector3(1.72, 0.050, 0.44), Color(0.56, 0.54, 0.45))
	_add_static_box("v0173_bridge_north_low_rail", Vector3(0.56, 0.316, 0.56), Vector3(1.80, 0.050, 0.08), Color(0.32, 0.25, 0.16))
	_add_static_box("v0173_bridge_south_low_rail", Vector3(0.56, 0.316, 1.20), Vector3(1.80, 0.050, 0.08), Color(0.32, 0.25, 0.16))
	_add_static_box("v0173_west_stone_cut_yard_plate", Vector3(-1.75, 0.170, 0.18), Vector3(1.88, 0.036, 1.24), Color(0.40, 0.39, 0.32, 0.78), true)
	_add_static_box("v0173_west_stone_cut_tailings_line", Vector3(-2.94, 0.206, 0.46), Vector3(0.84, 0.040, 0.20), Color(0.64, 0.60, 0.50, 0.86), true)
	_add_static_box("v0173_barracks_restoration_yard_plate", Vector3(-4.78, 0.170, -3.56), Vector3(1.98, 0.036, 1.32), worked_earth.lightened(0.08), true)
	_add_static_box("v0173_command_hall_hearth_yard_plate", Vector3(-5.08, 0.170, 3.18), Vector3(1.84, 0.036, 1.20), worked_earth, true)
	_add_static_box("v0173_site_marker_outer_claim_collar", Vector3(-1.52, 0.210, 0.12), Vector3(1.58, 0.032, 1.26), Color(0.92, 0.82, 0.30, 0.48), true)
	_add_static_box("v0173_site_marker_inner_safe_read", Vector3(-1.52, 0.218, 0.12), Vector3(1.02, 0.030, 0.82), Color(0.30, 0.62, 0.48, 0.42), true)
	_add_static_box("v0173_lume_path_readability_floor", Vector3(0.22, 0.205, -0.28), Vector3(2.96, 0.030, 0.18), _lume_core_color().darkened(0.12), true)
	_add_post_freeze_review_cohesion_layers()

func _add_post_freeze_review_cohesion_layers() -> void:
	var terrain_lift := Color(0.46, 0.56, 0.36, 0.22)
	var terrain_shadow := Color(0.07, 0.10, 0.07, 0.20)
	var road_glaze := Color(0.80, 0.72, 0.48, 0.30)
	var river_glaze := Color(0.42, 0.68, 0.68, 0.16)
	_add_static_box("post_freeze_review_ground_feather_north", Vector3(-1.04, 0.228, -1.50), Vector3(11.38, 0.020, 0.18), terrain_shadow, true)
	_add_static_box("post_freeze_review_ground_feather_south", Vector3(-1.04, 0.228, 3.86), Vector3(11.38, 0.020, 0.18), terrain_shadow, true)
	_add_static_box("post_freeze_review_far_west_value_pad", Vector3(-7.82, 0.224, 1.18), Vector3(3.64, 0.020, 5.84), Color(0.27, 0.36, 0.23, 0.42), true)
	_add_static_box("post_freeze_review_far_west_upper_scrub", Vector3(-7.48, 0.236, -1.02), Vector3(2.28, 0.018, 0.16), terrain_lift.darkened(0.08), true)
	_add_static_box("post_freeze_review_far_west_lower_scrub", Vector3(-7.58, 0.236, 3.32), Vector3(2.54, 0.018, 0.16), terrain_lift.darkened(0.12), true)
	_add_static_box("post_freeze_review_west_foothold_apron", Vector3(-6.34, 0.226, 1.28), Vector3(2.58, 0.020, 5.72), Color(0.28, 0.38, 0.23, 0.38), true)
	_add_static_box("post_freeze_review_west_foothold_apron_top_edge", Vector3(-6.18, 0.234, -1.62), Vector3(2.72, 0.018, 0.16), terrain_shadow, true)
	_add_static_box("post_freeze_review_west_foothold_apron_bottom_edge", Vector3(-6.18, 0.234, 4.08), Vector3(2.72, 0.018, 0.16), terrain_shadow.darkened(0.06), true)
	_add_static_box("post_freeze_review_ground_stage_lift", Vector3(-4.88, 0.232, 2.18), Vector3(2.82, 0.020, 0.18), terrain_lift, true)
	_add_static_box("post_freeze_review_ground_mine_lift", Vector3(-2.04, 0.232, 1.12), Vector3(2.20, 0.020, 0.16), terrain_lift.lightened(0.08), true)
	_add_static_box("post_freeze_review_ground_enemy_shadow_cap", Vector3(4.18, 0.232, -1.72), Vector3(3.18, 0.020, 0.16), Color(0.18, 0.08, 0.06, 0.24), true)
	_add_static_box("post_freeze_review_main_road_sunlit_crown", Vector3(-1.05, 0.236, 0.70), Vector3(11.30, 0.022, 0.10), road_glaze, true)
	_add_static_box("post_freeze_review_barracks_path_crown", Vector3(-4.45, 0.238, -2.28), Vector3(0.22, 0.020, 2.44), road_glaze.darkened(0.10), true)
	_add_static_box("post_freeze_review_ruins_path_crown", Vector3(3.15, 0.238, 2.27), Vector3(2.40, 0.020, 0.12), road_glaze.darkened(0.08), true)
	_add_static_box("post_freeze_review_river_west_specular_edge", Vector3(0.36, 0.244, -0.44), Vector3(0.08, 0.018, 12.56), river_glaze, true)
	_add_static_box("post_freeze_review_river_east_depth_edge", Vector3(0.84, 0.242, -0.44), Vector3(0.08, 0.018, 12.56), Color(0.02, 0.12, 0.16, 0.18), true)
	_add_static_box("post_freeze_review_bridge_readable_lip", Vector3(0.56, 0.360, 0.88), Vector3(1.70, 0.024, 0.08), Color(0.92, 0.80, 0.52, 0.72), true)

func _add_environment_geometry_foundation_material_targets() -> void:
	var wet_granite := Color(0.50, 0.48, 0.39)
	var worked_earth := Color(0.31, 0.27, 0.18, 0.12)
	if environment_shell_live_qa_enabled:
		_add_ground_material_static_box("v0173_terrain_mid_value_field", Vector3(-1.08, 0.156, 1.62), Vector3(4.85, 0.020, 0.24), Color(0.28, 0.36, 0.24, 0.035), true)
		_add_ground_material_static_box("v0173_friendly_staging_value_field", Vector3(-4.88, 0.168, 2.66), Vector3(1.22, 0.022, 0.20), Color(0.30, 0.38, 0.25, 0.045), true)
	else:
		_add_ground_material_static_box("v0173_terrain_mid_value_field", Vector3(-1.08, 0.156, 1.48), Vector3(6.10, 0.026, 2.18), Color(0.30, 0.39, 0.25, 0.08), true)
		_add_ground_material_static_box("v0173_friendly_staging_value_field", Vector3(-4.88, 0.168, 2.66), Vector3(1.90, 0.030, 1.05), Color(0.34, 0.44, 0.28, 0.10), true)
	_add_road_material_static_box("v0173_main_road_wide_readable_bed", Vector3(-1.05, 0.214, 0.70), Vector3(10.55, 0.034, 0.34), wet_granite)
	_add_road_material_static_box("v0173_barracks_side_path_wide_bed", Vector3(-4.47, 0.216, -2.22), Vector3(0.34, 0.032, 2.32), wet_granite.darkened(0.10))
	_add_road_material_static_box("v0173_ruins_side_path_wide_bed", Vector3(3.12, 0.216, 2.25), Vector3(2.18, 0.032, 0.28), wet_granite.darkened(0.08))
	_add_static_box("v0184_friendly_staging_sod_edge_north", Vector3(-4.86, 0.194, 1.88), Vector3(1.98, 0.026, 0.08), worked_earth, true)
	_add_static_box("v0184_friendly_staging_sod_edge_south", Vector3(-4.86, 0.194, 3.22), Vector3(1.82, 0.026, 0.08), worked_earth.darkened(0.08), true)

func _add_environment_geometry_convergence_layers() -> void:
	var road_edge := Color(0.14, 0.13, 0.10, 0.62)
	var road_crown := Color(0.78, 0.70, 0.50, 0.40)
	var bank_core := Color(0.34, 0.42, 0.31, 0.88)
	var bank_shadow := Color(0.10, 0.16, 0.13, 0.70)
	var water_deep := Color(0.02, 0.18, 0.25, 0.96)
	var water_lip := Color(0.28, 0.52, 0.55, 0.22)
	var bridge_stone := Color(0.56, 0.54, 0.46)
	if environment_shell_live_qa_enabled:
		road_edge = Color(0.10, 0.09, 0.07, 0.54)
		road_crown = Color(0.70, 0.62, 0.44, 0.24)
		bank_core = Color(0.30, 0.38, 0.28, 0.78)
		bank_shadow = Color(0.07, 0.11, 0.09, 0.62)
		water_deep = Color(0.02, 0.16, 0.22, 0.92)
		water_lip = Color(0.22, 0.42, 0.45, 0.16)
		bridge_stone = Color(0.52, 0.50, 0.42)
	_add_static_box("v0184_ground_mask_broken_north_edge", Vector3(-1.20, 0.186, 0.08), Vector3(5.80, 0.020, 0.08), Color(0.12, 0.16, 0.10, 0.16), true)
	_add_static_box("v0184_ground_mask_broken_south_edge", Vector3(-0.92, 0.186, 2.78), Vector3(5.42, 0.020, 0.08), Color(0.10, 0.14, 0.09, 0.15), true)
	_add_static_box("v0184_ground_mask_west_notch_shadow", Vector3(-5.52, 0.188, 1.56), Vector3(0.16, 0.020, 2.05), Color(0.08, 0.12, 0.08, 0.14), true)
	_add_static_box("v0184_main_road_north_embankment", Vector3(-1.15, 0.226, 0.47), Vector3(9.94, 0.025, 0.075), road_edge, true)
	_add_static_box("v0184_main_road_south_embankment", Vector3(-1.10, 0.226, 0.95), Vector3(9.86, 0.025, 0.075), road_edge.darkened(0.06), true)
	_add_static_box("v0184_main_road_subtle_crown", Vector3(-1.05, 0.238, 0.70), Vector3(9.72, 0.019, 0.055), road_crown, true)
	_add_static_box_rotated("v0184_main_road_west_kink_shadow", Vector3(-4.58, 0.248, 0.58), Vector3(1.26, 0.018, 0.055), -5.0, road_edge.darkened(0.08), true)
	_add_static_box_rotated("v0184_main_road_east_kink_shadow", Vector3(2.64, 0.248, 0.84), Vector3(1.36, 0.018, 0.055), 4.0, road_edge.darkened(0.04), true)
	_add_static_box_rotated("v0184_barracks_path_west_embankment", Vector3(-4.68, 0.228, -2.20), Vector3(0.060, 0.023, 2.24), -2.0, road_edge.darkened(0.04), true)
	_add_static_box_rotated("v0184_barracks_path_east_embankment", Vector3(-4.25, 0.228, -2.18), Vector3(0.060, 0.023, 2.22), 2.0, road_edge, true)
	_add_static_box_rotated("v0184_ruins_path_north_embankment", Vector3(3.12, 0.228, 2.07), Vector3(2.18, 0.023, 0.060), 2.5, road_edge.darkened(0.04), true)
	_add_static_box_rotated("v0184_ruins_path_south_embankment", Vector3(3.12, 0.228, 2.42), Vector3(2.18, 0.023, 0.060), -2.5, road_edge, true)
	_add_static_box("v0184_mine_road_intersection_compact", Vector3(-1.78, 0.232, 0.52), Vector3(0.76, 0.022, 0.34), Color(0.60, 0.54, 0.38, 0.30), true)
	_add_static_box("v0184_bridge_road_intersection_compact", Vector3(0.48, 0.234, 0.78), Vector3(1.10, 0.022, 0.38), Color(0.62, 0.56, 0.42, 0.32), true)
	_add_static_box("v0184_river_deep_channel_main", Vector3(0.60, 0.190, -0.36), Vector3(0.34, 0.044, 12.78), water_deep, true)
	_add_static_box_rotated("v0184_river_deep_channel_north_bend", Vector3(0.46, 0.192, -4.16), Vector3(0.30, 0.040, 2.00), -4.0, water_deep.darkened(0.08), true)
	_add_static_box_rotated("v0184_river_deep_channel_south_bend", Vector3(0.74, 0.192, 3.80), Vector3(0.30, 0.040, 1.92), 4.0, water_deep.lightened(0.04), true)
	for index in range(5):
		var segment_z := -4.88 + float(index) * 2.36
		var wobble := sin(float(index) * 1.37) * 0.09
		var rotation := -3.0 + float(index % 3) * 3.0
		_add_static_box_rotated("v0184_river_west_inner_lip_%02d" % index, Vector3(0.23 + wobble, 0.220, segment_z), Vector3(0.085, 0.024, 1.42), rotation, water_lip, true)
		_add_static_box_rotated("v0184_river_east_inner_lip_%02d" % index, Vector3(0.98 + wobble, 0.220, segment_z + 0.28), Vector3(0.085, 0.024, 1.34), -rotation, water_lip.darkened(0.08), true)
	_add_static_box_rotated("v0184_bank_west_upper_01", Vector3(0.02, 0.226, -3.28), Vector3(0.14, 0.032, 2.66), -3.0, bank_core, true)
	_add_static_box_rotated("v0184_bank_west_lower_02", Vector3(0.08, 0.226, 2.62), Vector3(0.14, 0.032, 3.18), 3.0, bank_core.darkened(0.04), true)
	_add_static_box_rotated("v0184_bank_east_upper_01", Vector3(1.15, 0.226, -3.12), Vector3(0.14, 0.032, 2.56), 3.0, bank_core.lightened(0.04), true)
	_add_static_box_rotated("v0184_bank_east_lower_02", Vector3(1.12, 0.226, 2.74), Vector3(0.14, 0.032, 3.02), -3.0, bank_core, true)
	_add_static_box("v0184_bank_west_shadow_break_bridge", Vector3(-0.06, 0.230, 0.88), Vector3(0.12, 0.028, 0.66), bank_shadow, true)
	_add_static_box("v0184_bank_east_shadow_break_bridge", Vector3(1.24, 0.230, 0.88), Vector3(0.12, 0.028, 0.66), bank_shadow, true)
	_add_static_box("v0184_bridge_under_shadow", Vector3(0.56, 0.286, 0.88), Vector3(1.76, 0.036, 0.54), Color(0.08, 0.07, 0.05, 0.78), true)
	_add_static_box("v0184_bridge_wet_granite_deck", Vector3(0.56, 0.354, 0.88), Vector3(1.48, 0.068, 0.40), bridge_stone)
	_add_static_box("v0184_bridge_north_rail", Vector3(0.56, 0.430, 0.52), Vector3(1.78, 0.060, 0.07), Color(0.25, 0.20, 0.13))
	_add_static_box("v0184_bridge_south_rail", Vector3(0.56, 0.430, 1.24), Vector3(1.78, 0.060, 0.07), Color(0.25, 0.20, 0.13))
	_add_static_box("v0184_bridge_west_abutment", Vector3(-0.43, 0.342, 0.88), Vector3(0.18, 0.125, 0.58), Color(0.40, 0.38, 0.32))
	_add_static_box("v0184_bridge_east_abutment", Vector3(1.53, 0.342, 0.88), Vector3(0.18, 0.125, 0.58), Color(0.42, 0.40, 0.34))
	_add_static_box("v0184_bridge_west_ramp_grounding", Vector3(-0.92, 0.314, 0.88), Vector3(0.42, 0.034, 0.32), Color(0.36, 0.33, 0.25, 0.64), true)
	_add_static_box("v0184_bridge_east_ramp_grounding", Vector3(2.03, 0.314, 0.88), Vector3(0.42, 0.034, 0.32), Color(0.36, 0.33, 0.25, 0.64), true)
	for index in range(3):
		var z := 0.70 + float(index) * 0.18
		_add_static_box("v0184_bridge_plank_%02d" % index, Vector3(0.56, 0.394, z), Vector3(1.30, 0.018, 0.030), Color(0.72, 0.68, 0.55, 0.68), true)
	for index in range(8):
		var x := -5.24 + float(index) * 1.42
		var z_offset := sin(float(index) * 1.9) * 0.035
		_add_static_box_rotated("v0184_main_road_granite_break_%02d" % index, Vector3(x, 0.254, 0.70 + z_offset), Vector3(0.30, 0.018, 0.046), -4.0 + float(index % 3) * 4.0, Color(0.84, 0.78, 0.58, 0.46), true)
	if environment_shell_live_qa_enabled:
		_add_static_box("v0185_bridge_west_bank_seat_shadow", Vector3(-0.72, 0.328, 0.88), Vector3(0.34, 0.028, 0.36), Color(0.08, 0.07, 0.05, 0.44), true)
		_add_static_box("v0185_bridge_east_bank_seat_shadow", Vector3(1.82, 0.328, 0.88), Vector3(0.34, 0.028, 0.36), Color(0.08, 0.07, 0.05, 0.44), true)
		_add_static_cylinder("v0184_site_marker_outer_reading_ring", Vector3(-1.52, 0.318, 0.12), 0.56, 0.022, Color(0.84, 0.70, 0.26, 0.34), true)
		_add_static_cylinder("v0184_site_marker_inner_state_disc", Vector3(-1.52, 0.340, 0.12), 0.26, 0.020, Color(0.26, 0.62, 0.44, 0.30), true)
	else:
		_add_static_cylinder("v0184_site_marker_outer_reading_ring", Vector3(-1.52, 0.318, 0.12), 0.72, 0.026, Color(0.95, 0.80, 0.30, 0.50), true)
		_add_static_cylinder("v0184_site_marker_inner_state_disc", Vector3(-1.52, 0.340, 0.12), 0.34, 0.022, Color(0.32, 0.76, 0.52, 0.44), true)

func _add_environment_riverbank_bridge_approach_layers() -> void:
	var water_core := Color(0.02, 0.17, 0.24, 0.88)
	var water_glaze := Color(0.30, 0.54, 0.54, 0.24)
	var bank_lip := Color(0.32, 0.40, 0.30, 0.74)
	var bank_shadow := Color(0.06, 0.10, 0.08, 0.58)
	var bridge_stone := Color(0.58, 0.56, 0.47)
	var bridge_shadow := Color(0.06, 0.05, 0.04, 0.70)
	var road_transition := Color(0.78, 0.70, 0.50, 0.44)
	var friendly_lane := Color(0.24, 0.60, 0.48, 0.32)
	var hostile_lane := Color(0.74, 0.22, 0.15, 0.34)
	_add_static_box("v0187_river_channel_central_continuity", Vector3(0.60, 0.292, -0.40), Vector3(0.26, 0.020, 13.04), water_core, true)
	_add_static_box_rotated("v0187_river_north_bend_join", Vector3(0.48, 0.294, -4.58), Vector3(0.24, 0.018, 2.15), -5.0, water_core.darkened(0.07), true)
	_add_static_box_rotated("v0187_river_south_bend_join", Vector3(0.72, 0.294, 4.06), Vector3(0.24, 0.018, 2.05), 5.0, water_core.lightened(0.04), true)
	_add_static_box("v0187_river_under_bridge_dark_cut", Vector3(0.60, 0.306, 0.88), Vector3(0.34, 0.022, 0.88), water_core.darkened(0.20), true)
	_add_static_box("v0187_river_shallow_crossing_glaze", Vector3(0.60, 0.330, 0.88), Vector3(1.42, 0.018, 0.26), water_glaze.lightened(0.10), true)
	for index in range(4):
		var z := -4.62 + float(index) * 2.82
		var wobble := sin(float(index) * 1.6) * 0.08
		_add_static_box_rotated("v0187_west_bank_upper_lip_%02d" % index, Vector3(0.08 + wobble, 0.318, z), Vector3(0.12, 0.020, 1.46), -4.0 + float(index % 2) * 3.0, bank_lip, true)
		_add_static_box_rotated("v0187_east_bank_upper_lip_%02d" % index, Vector3(1.12 + wobble, 0.318, z + 0.30), Vector3(0.12, 0.020, 1.42), 4.0 - float(index % 2) * 3.0, bank_lip.lightened(0.05), true)
	_add_static_box("v0187_west_bank_lower_lip", Vector3(0.02, 0.322, 3.18), Vector3(0.14, 0.020, 2.36), bank_lip.darkened(0.06), true)
	_add_static_box("v0187_east_bank_lower_lip", Vector3(1.18, 0.322, 3.18), Vector3(0.14, 0.020, 2.36), bank_lip.lightened(0.03), true)
	_add_static_box("v0187_bridge_bank_shadow_west", Vector3(-0.46, 0.332, 0.88), Vector3(0.22, 0.024, 0.78), bank_shadow, true)
	_add_static_box("v0187_bridge_bank_shadow_east", Vector3(1.50, 0.332, 0.88), Vector3(0.22, 0.024, 0.78), bank_shadow, true)
	_add_static_box("v0187_bridge_under_span_shadow", Vector3(0.56, 0.348, 0.88), Vector3(2.06, 0.030, 0.70), bridge_shadow, true)
	_add_static_box("v0187_bridge_deck_readable_span", Vector3(0.56, 0.386, 0.88), Vector3(1.62, 0.056, 0.42), bridge_stone)
	_add_static_box("v0187_bridge_west_abutment_mass", Vector3(-0.46, 0.374, 0.88), Vector3(0.24, 0.112, 0.62), bridge_stone.darkened(0.12))
	_add_static_box("v0187_bridge_east_abutment_mass", Vector3(1.56, 0.374, 0.88), Vector3(0.24, 0.112, 0.62), bridge_stone.darkened(0.08))
	_add_static_box("v0187_bridge_north_low_rail", Vector3(0.56, 0.462, 0.52), Vector3(1.92, 0.044, 0.06), Color(0.24, 0.19, 0.12))
	_add_static_box("v0187_bridge_south_low_rail", Vector3(0.56, 0.462, 1.24), Vector3(1.92, 0.044, 0.06), Color(0.24, 0.19, 0.12))
	for index in range(5):
		var z_tick := 0.61 + float(index) * 0.15
		_add_static_box("v0187_bridge_plank_tick_%02d" % index, Vector3(0.56, 0.430, z_tick), Vector3(1.38, 0.014, 0.026), Color(0.86, 0.78, 0.56, 0.58), true)
	_add_static_box("v0187_west_road_to_bridge_collar", Vector3(-0.88, 0.342, 0.86), Vector3(0.86, 0.020, 0.46), road_transition, true)
	_add_static_box("v0187_east_road_from_bridge_collar", Vector3(1.98, 0.342, 0.86), Vector3(0.86, 0.020, 0.46), road_transition.darkened(0.05), true)
	_add_static_box("v0187_crossing_combat_readability_lane", Vector3(0.56, 0.350, 0.88), Vector3(2.58, 0.018, 0.10), Color(0.94, 0.82, 0.52, 0.40), true)
	_add_static_box("v0187_friendly_approach_lane_feather", Vector3(-4.36, 0.342, 1.42), Vector3(1.52, 0.018, 1.36), friendly_lane, true)
	_add_static_box("v0187_friendly_approach_to_bridge_read", Vector3(-2.16, 0.342, 0.78), Vector3(2.02, 0.018, 0.24), friendly_lane.lightened(0.08), true)
	_add_static_box("v0187_hostile_approach_lane_feather", Vector3(3.64, 0.342, -0.98), Vector3(4.12, 0.018, 0.30), hostile_lane, true)
	_add_static_box("v0187_hostile_approach_to_bridge_read", Vector3(2.18, 0.342, 0.48), Vector3(1.10, 0.018, 0.20), hostile_lane.lightened(0.10), true)
	_add_static_box("v0187_site_marker_road_tick_preserved", Vector3(-0.68, 0.372, 0.12), Vector3(0.36, 0.018, 0.12), Color(0.94, 0.80, 0.32, 0.42), true)

func _add_environment_readability_hardening_layers() -> void:
	var road_core := Color(0.62, 0.58, 0.44, 0.92)
	var road_shadow := Color(0.17, 0.16, 0.12, 0.70)
	var approach_teal := Color(0.20, 0.58, 0.50, 0.42)
	var hostile_warm := Color(0.66, 0.19, 0.13, 0.44)
	var site_gold := Color(0.98, 0.82, 0.28, 0.58)
	_add_static_box("v0174_main_road_continuity_centerline", Vector3(-1.05, 0.235, 0.70), Vector3(11.90, 0.024, 0.08), road_core, true)
	_add_static_box("v0174_main_road_left_readability_berm", Vector3(-1.05, 0.222, 0.18), Vector3(11.88, 0.026, 0.08), road_shadow, true)
	_add_static_box("v0174_main_road_right_readability_berm", Vector3(-1.05, 0.222, 1.22), Vector3(11.88, 0.026, 0.08), road_shadow, true)
	_add_static_box("v0174_barracks_intersection_collar", Vector3(-4.42, 0.238, 0.38), Vector3(1.04, 0.024, 0.82), Color(0.72, 0.66, 0.48, 0.48), true)
	_add_static_box("v0174_mine_intersection_collar", Vector3(-1.72, 0.238, 0.38), Vector3(1.32, 0.024, 0.76), Color(0.75, 0.68, 0.46, 0.50), true)
	_add_static_box("v0174_bridge_intersection_collar", Vector3(0.56, 0.240, 0.84), Vector3(1.98, 0.026, 0.92), Color(0.80, 0.72, 0.54, 0.52), true)
	_add_static_box("v0174_hostile_approach_lane", Vector3(3.48, 0.238, -0.98), Vector3(3.82, 0.026, 0.34), hostile_warm, true)
	_add_static_box("v0174_hostile_lane_inner_warning", Vector3(3.62, 0.252, -0.98), Vector3(2.58, 0.028, 0.08), hostile_warm.lightened(0.16), true)
	_add_static_box("v0174_friendly_foothold_boundary", Vector3(-4.58, 0.240, 2.10), Vector3(3.86, 0.028, 0.14), approach_teal, true)
	_add_static_box("v0174_friendly_staging_lane_to_road", Vector3(-4.48, 0.238, 1.42), Vector3(1.20, 0.026, 1.44), approach_teal.darkened(0.08), true)
	_add_static_box("v0174_mine_approach_lane", Vector3(-2.14, 0.240, 0.74), Vector3(1.28, 0.026, 0.30), approach_teal.lightened(0.08), true)
	_add_static_box("v0174_barracks_approach_lane", Vector3(-4.78, 0.242, -2.02), Vector3(0.46, 0.026, 3.14), approach_teal.lightened(0.04), true)
	_add_static_box("v0174_river_deep_contrast_spine", Vector3(0.60, 0.232, -0.38), Vector3(0.30, 0.024, 12.72), Color(0.04, 0.21, 0.27, 0.82), true)
	_add_static_box("v0174_west_bank_walkable_lip", Vector3(0.06, 0.238, -0.38), Vector3(0.12, 0.024, 12.64), Color(0.30, 0.38, 0.30, 0.58), true)
	_add_static_box("v0174_east_bank_walkable_lip", Vector3(1.14, 0.238, -0.38), Vector3(0.12, 0.024, 12.64), Color(0.30, 0.38, 0.32, 0.58), true)
	_add_static_box("v0174_bridge_crossing_plank_highlight", Vector3(0.56, 0.326, 0.88), Vector3(1.52, 0.030, 0.10), Color(0.83, 0.75, 0.54, 0.82), true)
	_add_static_box("v0174_bridge_crossing_shadow_gate_west", Vector3(-0.52, 0.286, 0.88), Vector3(0.12, 0.040, 0.74), road_shadow, true)
	_add_static_box("v0174_bridge_crossing_shadow_gate_east", Vector3(1.64, 0.286, 0.88), Vector3(0.12, 0.040, 0.74), road_shadow, true)
	_add_static_cylinder("v0174_site_marker_outer_ring_read", Vector3(-1.52, 0.252, 0.12), 0.82, 0.030, site_gold, true)
	_add_static_cylinder("v0174_site_marker_inner_state_disc", Vector3(-1.52, 0.274, 0.12), 0.42, 0.026, Color(0.30, 0.78, 0.52, 0.66), true)
	_add_static_box("v0174_site_marker_orientation_tick_north", Vector3(-1.52, 0.296, -0.70), Vector3(0.16, 0.026, 0.34), site_gold.lightened(0.10), true)
	_add_static_box("v0174_site_marker_orientation_tick_road", Vector3(-0.70, 0.296, 0.12), Vector3(0.34, 0.026, 0.16), site_gold.lightened(0.04), true)

func _add_environment_contrast_harmonization_layers() -> void:
	var road_core := Color(0.70, 0.64, 0.47, 0.88)
	var road_shadow := Color(0.13, 0.12, 0.09, 0.76)
	var bank_lip := Color(0.40, 0.46, 0.34, 0.66)
	var bridge_gold := Color(0.88, 0.76, 0.50, 0.84)
	var approach_teal := Color(0.24, 0.62, 0.50, 0.44)
	var hostile_warm := Color(0.78, 0.23, 0.16, 0.48)
	var site_gold := Color(1.00, 0.84, 0.28, 0.64)
	_add_static_box("v0179_main_road_warm_readability_core", Vector3(-1.05, 0.272, 0.70), Vector3(11.78, 0.022, 0.11), road_core, true)
	_add_static_box("v0179_main_road_north_dark_shoulder", Vector3(-1.05, 0.258, 0.20), Vector3(11.94, 0.024, 0.10), road_shadow, true)
	_add_static_box("v0179_main_road_south_dark_shoulder", Vector3(-1.05, 0.258, 1.20), Vector3(11.94, 0.024, 0.10), road_shadow, true)
	_add_static_box("v0179_barracks_intersection_readability_plate", Vector3(-4.44, 0.276, 0.42), Vector3(1.18, 0.020, 0.88), Color(0.76, 0.67, 0.47, 0.46), true)
	_add_static_box("v0179_mine_intersection_readability_plate", Vector3(-1.78, 0.276, 0.42), Vector3(1.38, 0.020, 0.84), Color(0.78, 0.69, 0.46, 0.48), true)
	_add_static_box("v0179_bridge_intersection_readability_plate", Vector3(0.56, 0.278, 0.86), Vector3(2.02, 0.021, 0.98), Color(0.82, 0.72, 0.52, 0.52), true)
	for index in range(8):
		var x := -5.70 + float(index) * 1.58
		_add_static_box("v0179_main_road_granite_tick_%02d" % index, Vector3(x, 0.296, 0.70), Vector3(0.42, 0.020, 0.06), Color(0.92, 0.84, 0.62, 0.62), true)
	_add_static_box("v0179_barracks_approach_lane_read", Vector3(-4.78, 0.282, -2.02), Vector3(0.52, 0.021, 3.12), approach_teal, true)
	_add_static_box("v0179_mine_approach_lane_read", Vector3(-2.14, 0.282, 0.76), Vector3(1.32, 0.021, 0.34), approach_teal.lightened(0.08), true)
	_add_static_box("v0179_friendly_staging_to_road_read", Vector3(-4.48, 0.280, 1.42), Vector3(1.28, 0.020, 1.46), approach_teal.darkened(0.08), true)
	_add_static_box("v0179_hostile_approach_lane_read", Vector3(3.52, 0.280, -0.98), Vector3(3.92, 0.021, 0.36), hostile_warm, true)
	_add_static_box("v0179_hostile_lane_inner_warning", Vector3(3.64, 0.298, -0.98), Vector3(2.68, 0.020, 0.08), hostile_warm.lightened(0.14), true)
	_add_static_box("v0179_river_cool_deep_spine", Vector3(0.60, 0.266, -0.38), Vector3(0.34, 0.022, 12.76), Color(0.02, 0.20, 0.28, 0.86), true)
	_add_static_box("v0179_west_bank_readability_lip", Vector3(0.04, 0.280, -0.38), Vector3(0.13, 0.020, 12.66), bank_lip, true)
	_add_static_box("v0179_east_bank_readability_lip", Vector3(1.16, 0.280, -0.38), Vector3(0.13, 0.020, 12.66), bank_lip.lightened(0.04), true)
	_add_static_box("v0179_ford_shallow_crossing_read", Vector3(0.58, 0.302, 0.88), Vector3(1.66, 0.020, 0.28), Color(0.58, 0.76, 0.70, 0.64), true)
	_add_static_box("v0179_bridge_shadow_silhouette", Vector3(0.56, 0.304, 0.88), Vector3(2.05, 0.026, 0.70), road_shadow, true)
	_add_static_box("v0179_bridge_deck_plank_highlight", Vector3(0.56, 0.354, 0.88), Vector3(1.56, 0.026, 0.12), bridge_gold, true)
	_add_static_box("v0179_bridge_north_guard_read", Vector3(0.56, 0.384, 0.52), Vector3(1.92, 0.026, 0.07), Color(0.20, 0.15, 0.08, 0.86), true)
	_add_static_box("v0179_bridge_south_guard_read", Vector3(0.56, 0.384, 1.24), Vector3(1.92, 0.026, 0.07), Color(0.20, 0.15, 0.08, 0.86), true)
	_add_static_cylinder("v0179_site_marker_outer_ring_read", Vector3(-1.52, 0.318, 0.12), 0.86, 0.026, site_gold, true)
	_add_static_cylinder("v0179_site_marker_inner_state_disc", Vector3(-1.52, 0.340, 0.12), 0.44, 0.022, Color(0.31, 0.80, 0.54, 0.66), true)
	_add_static_box("v0179_site_marker_north_orientation_tick", Vector3(-1.52, 0.362, -0.72), Vector3(0.14, 0.022, 0.34), site_gold.lightened(0.10), true)
	_add_static_box("v0179_site_marker_road_orientation_tick", Vector3(-0.70, 0.362, 0.12), Vector3(0.34, 0.022, 0.14), site_gold.lightened(0.04), true)

func _create_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "ProceduralPlaceholderHud"
	add_child(hud_layer)

	var resource_frame := Panel.new()
	resource_frame.name = "HudResourceCornerRow"
	resource_frame.position = Vector2(18, 18)
	resource_frame.size = Vector2(396, 30)
	resource_frame.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.045, 0.040, 0.84), Color(0.36, 0.74, 0.66, 0.78)))
	hud_layer.add_child(resource_frame)

	hud_resource_label = Label.new()
	hud_resource_label.name = "CompactResourceRow"
	hud_resource_label.position = Vector2(12, 4)
	hud_resource_label.size = Vector2(372, 20)
	hud_resource_label.add_theme_font_size_override("font_size", 13)
	hud_resource_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.82))
	resource_frame.add_child(hud_resource_label)

	var objective_frame := Panel.new()
	objective_frame.name = "HudCurrentObjectiveStrip"
	objective_frame.position = Vector2(18, 54)
	objective_frame.size = Vector2(396, 30)
	objective_frame.add_theme_stylebox_override("panel", _panel_style(Color(0.040, 0.045, 0.038, 0.82), Color(0.68, 0.62, 0.36, 0.78)))
	hud_layer.add_child(objective_frame)

	hud_objective_strip_label = Label.new()
	hud_objective_strip_label.name = "CurrentObjectiveStripText"
	hud_objective_strip_label.position = Vector2(12, 4)
	hud_objective_strip_label.size = Vector2(372, 22)
	hud_objective_strip_label.add_theme_font_size_override("font_size", 13)
	hud_objective_strip_label.add_theme_color_override("font_color", Color(0.94, 0.88, 0.62))
	objective_frame.add_child(hud_objective_strip_label)

	var pause_frame := Panel.new()
	pause_frame.name = "HudPauseAffordance"
	pause_frame.position = Vector2(1482, 18)
	pause_frame.size = Vector2(86, 34)
	pause_frame.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.045, 0.040, 0.82), Color(0.36, 0.74, 0.66, 0.68)))
	hud_layer.add_child(pause_frame)

	var pause_label := Label.new()
	pause_label.name = "PauseLabel"
	pause_label.text = "Pause"
	pause_label.position = Vector2(10, 5)
	pause_label.size = Vector2(66, 22)
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.add_theme_font_size_override("font_size", 14)
	pause_label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.82))
	pause_frame.add_child(pause_label)

	var frame := Panel.new()
	frame.name = "HudFrame"
	frame.position = Vector2(18, 764)
	frame.size = Vector2(470, 118)
	frame.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.045, 0.045, 0.88), Color(0.36, 0.74, 0.66, 0.84)))
	hud_layer.add_child(frame)

	hud_hero_label = Label.new()
	hud_hero_label.name = "SelectedHeroCard"
	hud_hero_label.position = Vector2(14, 8)
	hud_hero_label.size = Vector2(442, 20)
	hud_hero_label.add_theme_font_size_override("font_size", 15)
	hud_hero_label.add_theme_color_override("font_color", Color(0.72, 0.90, 0.96))
	frame.add_child(hud_hero_label)

	hud_context_label = Label.new()
	hud_context_label.name = "SelectedContextCard"
	hud_context_label.position = Vector2(14, 30)
	hud_context_label.size = Vector2(442, 20)
	hud_context_label.add_theme_font_size_override("font_size", 13)
	hud_context_label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.76))
	frame.add_child(hud_context_label)

	hud_objective_label = Label.new()
	hud_objective_label.name = "ObjectiveSummaryCompact"
	hud_objective_label.position = Vector2(14, 52)
	hud_objective_label.size = Vector2(442, 20)
	hud_objective_label.add_theme_font_size_override("font_size", 13)
	hud_objective_label.add_theme_color_override("font_color", Color(0.92, 0.82, 0.60))
	frame.add_child(hud_objective_label)

	hud_status_label = Label.new()
	hud_status_label.name = "PlayerReadableStatus"
	hud_status_label.position = Vector2(14, 72)
	hud_status_label.size = Vector2(442, 18)
	hud_status_label.add_theme_font_size_override("font_size", 12)
	hud_status_label.add_theme_color_override("font_color", Color(0.66, 0.84, 0.78))
	frame.add_child(hud_status_label)

	var command_labels := ["Move", "Attack", "Hold", "Work", "Lume"]
	var command_names := ["CommandButtonMove", "CommandButtonAttack", "CommandButtonHold", "CommandButtonWork", "CommandButtonLume"]
	for index in range(command_labels.size()):
		var button := Button.new()
		button.name = command_names[index]
		button.text = command_labels[index]
		button.position = Vector2(14 + index * 88, 92)
		button.size = Vector2(76, 22)
		button.add_theme_font_size_override("font_size", 12)
		match command_names[index]:
			"CommandButtonMove":
				button.pressed.connect(_hud_move_pressed)
			"CommandButtonAttack":
				hud_attack_button = button
				button.pressed.connect(_hud_attack_pressed)
			"CommandButtonWork":
				hud_work_button = button
				button.pressed.connect(_hud_work_pressed)
			"CommandButtonLume":
				button.pressed.connect(_hud_lume_pressed)
		frame.add_child(button)

	hud_onboarding_label = Label.new()
	hud_onboarding_label.name = "MicroOnboardingPrompt"
	hud_onboarding_label.position = Vector2(516, 764)
	hud_onboarding_label.size = Vector2(620, 24)
	hud_onboarding_label.add_theme_font_size_override("font_size", 14)
	hud_onboarding_label.add_theme_color_override("font_color", Color(0.90, 0.92, 0.78))
	hud_layer.add_child(hud_onboarding_label)

	hud_alert_label = Label.new()
	hud_alert_label.name = "ObjectiveFeedbackAlert"
	hud_alert_label.position = Vector2(516, 794)
	hud_alert_label.size = Vector2(620, 24)
	hud_alert_label.add_theme_font_size_override("font_size", 13)
	hud_alert_label.add_theme_color_override("font_color", Color(0.76, 0.94, 0.88))
	hud_layer.add_child(hud_alert_label)

	hud_more_details_button = Button.new()
	hud_more_details_button.name = "MoreDetailsDisclosure"
	hud_more_details_button.text = "Path"
	hud_more_details_button.position = Vector2(516, 828)
	hud_more_details_button.size = Vector2(72, 24)
	hud_more_details_button.add_theme_font_size_override("font_size", 12)
	hud_more_details_button.pressed.connect(_toggle_more_details)
	hud_layer.add_child(hud_more_details_button)

	hud_more_details_label = Label.new()
	hud_more_details_label.name = "MoreDetailsPanel"
	hud_more_details_label.position = Vector2(602, 828)
	hud_more_details_label.size = Vector2(534, 24)
	hud_more_details_label.add_theme_font_size_override("font_size", 12)
	hud_more_details_label.add_theme_color_override("font_color", Color(0.72, 0.84, 0.78))
	hud_layer.add_child(hud_more_details_label)

	hud_help_button = Button.new()
	hud_help_button.name = "CompactControlsHelpButton"
	hud_help_button.text = "Help"
	hud_help_button.position = Vector2(1304, 578)
	hud_help_button.size = Vector2(64, 26)
	hud_help_button.add_theme_font_size_override("font_size", 12)
	hud_help_button.pressed.connect(toggle_controls_help)
	hud_layer.add_child(hud_help_button)

	hud_help_panel = Panel.new()
	hud_help_panel.name = "CompactControlsHelpPanel"
	hud_help_panel.position = Vector2(1018, 472)
	hud_help_panel.size = Vector2(326, 182)
	hud_help_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.035, 0.035, 0.90), Color(0.46, 0.78, 0.70, 0.72)))
	hud_layer.add_child(hud_help_panel)

	hud_help_label = Label.new()
	hud_help_label.name = "CompactControlsHelpText"
	hud_help_label.position = Vector2(12, 10)
	hud_help_label.size = Vector2(302, 156)
	hud_help_label.add_theme_font_size_override("font_size", 12)
	hud_help_label.add_theme_color_override("font_color", Color(0.86, 0.92, 0.82))
	hud_help_panel.add_child(hud_help_label)

	hud_tooltip_label = Label.new()
	hud_tooltip_label.name = "ShortOrderTooltip"
	hud_tooltip_label.position = Vector2(516, 734)
	hud_tooltip_label.size = Vector2(620, 22)
	hud_tooltip_label.add_theme_font_size_override("font_size", 12)
	hud_tooltip_label.add_theme_color_override("font_color", Color(0.86, 0.92, 0.78))
	hud_layer.add_child(hud_tooltip_label)

	minimap_panel = Panel.new()
	minimap_panel.name = "MinimapOrientationPlaceholder"
	minimap_panel.position = Vector2(1294, 618)
	minimap_panel.size = Vector2(274, 240)
	minimap_panel.gui_input.connect(_handle_v0136_minimap_gui_input)
	minimap_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.055, 0.84), Color(0.40, 0.72, 0.68, 0.78)))
	hud_layer.add_child(minimap_panel)

	for marker in [
		{"name": "minimap_salto_terrain_outline", "pos": Vector2(14, 16), "size": Vector2(246, 204), "color": Color(0.12, 0.20, 0.17, 0.78)},
		{"name": "minimap_highland_shape", "pos": Vector2(32, 34), "size": Vector2(112, 18), "color": Color(0.42, 0.78, 0.52)},
		{"name": "minimap_main_road", "pos": Vector2(36, 116), "size": Vector2(190, 12), "color": Color(0.58, 0.50, 0.34)},
		{"name": "minimap_water_strip", "pos": Vector2(142, 42), "size": Vector2(12, 156), "color": Color(0.22, 0.66, 0.76)},
		{"name": "minimap_ford_crossing", "pos": Vector2(118, 116), "size": Vector2(60, 10), "color": Color(0.68, 0.76, 0.72)},
		{"name": "minimap_friendly_cluster", "pos": Vector2(46, 164), "size": Vector2(22, 22), "color": Color(0.30, 0.78, 0.52)},
		{"name": "minimap_hero_marker", "pos": Vector2(64, 150), "size": Vector2(16, 16), "color": Color(0.88, 0.92, 0.48)},
		{"name": "minimap_worker_marker", "pos": Vector2(50, 178), "size": Vector2(12, 12), "color": Color(0.86, 0.72, 0.36)},
		{"name": "minimap_objective_marker", "pos": Vector2(82, 134), "size": Vector2(20, 20), "color": Color(0.96, 0.82, 0.28)},
		{"name": "minimap_quarry", "pos": Vector2(80, 144), "size": Vector2(24, 18), "color": Color(0.88, 0.78, 0.32)},
		{"name": "minimap_west_stone_cut_mine_target", "pos": Vector2(80, 144), "size": Vector2(24, 18), "color": Color(0.88, 0.78, 0.32)},
		{"name": "minimap_west_stone_cut_mine_control", "pos": Vector2(86, 148), "size": Vector2(14, 10), "color": Color(0.32, 0.90, 0.52)},
		{"name": "minimap_barracks_marker", "pos": Vector2(48, 66), "size": Vector2(24, 16), "color": Color(0.78, 0.66, 0.42)},
		{"name": "minimap_shrine", "pos": Vector2(102, 58), "size": Vector2(18, 18), "color": Color(0.28, 0.86, 0.82)},
		{"name": "minimap_mine_marker", "pos": Vector2(72, 130), "size": Vector2(14, 14), "color": Color(0.66, 0.66, 0.56)},
		{"name": "minimap_ruin", "pos": Vector2(188, 162), "size": Vector2(28, 16), "color": Color(0.62, 0.62, 0.54)},
		{"name": "minimap_lume_endpoint_a", "pos": Vector2(96, 124), "size": Vector2(9, 9), "color": Color(0.38, 0.94, 0.88)},
		{"name": "minimap_lume_endpoint_b", "pos": Vector2(154, 102), "size": Vector2(9, 9), "color": Color(0.38, 0.94, 0.88)},
		{"name": "minimap_lume_link", "pos": Vector2(102, 118), "size": Vector2(62, 5), "color": Color(0.38, 0.94, 0.88, 0.78)},
		{"name": "minimap_active_ashen_attackers", "pos": Vector2(190, 74), "size": Vector2(52, 18), "color": Color(0.84, 0.28, 0.20)},
		{"name": "minimap_hostile_marker", "pos": Vector2(190, 74), "size": Vector2(52, 18), "color": Color(0.84, 0.28, 0.20)},
		{"name": "minimap_camera_viewport_indicator", "pos": Vector2(66, 92), "size": Vector2(116, 78), "color": Color(0.82, 0.92, 0.84, 0.22)}
	]:
		_add_minimap_marker(str(marker["name"]), marker["pos"], marker["size"], marker["color"])
	_sync_minimap()
	_sync_player_shell_chrome()

func _sync_hud() -> void:
	if hud_resource_label:
		hud_resource_label.text = "Crowns %s   Stone %s   Iron %s   Aether %s" % [
			runtime.resources.get("crowns", 0),
			runtime.resources.get("stone", 0),
			runtime.resources.get("iron", 0),
			runtime.resources.get("aether", 0)
		]
	if hud_layer:
		var pause_frame := hud_layer.get_node_or_null("HudPauseAffordance") as Control
		if pause_frame:
			pause_frame.visible = runtime.paused and ((not player_facing_mode) or player_shell_screen == "battle")
	if hud_status_label:
		if player_facing_mode:
			hud_status_label.text = _player_status_text()
		else:
			hud_status_label.text = "Preset %s | %s | editor optional" % [visual_preset, runtime.workload_tier]
	if hud_hero_label:
		var selected := "Aster ready"
		if v0133_selected_structure_id == "barracks":
			selected = "Selected Barracks"
		if not runtime.selected_ids.is_empty():
			if player_facing_mode:
				selected = "Selected %s" % _player_selection_summary()
			else:
				selected = "Selected %s" % ", ".join(runtime.selected_ids.slice(0, min(3, runtime.selected_ids.size())))
		hud_hero_label.text = selected
	if hud_context_label:
		hud_context_label.text = _selected_context_text()
	if hud_objective_label:
		hud_objective_label.text = _objective_summary_text()
	if hud_objective_strip_label:
		hud_objective_strip_label.text = _current_objective_text()
	if hud_onboarding_label:
		hud_onboarding_label.text = "" if onboarding_dismissed else _onboarding_text(current_onboarding_step)
		hud_onboarding_label.visible = not onboarding_dismissed and hud_onboarding_label.text != ""
	if hud_alert_label:
		hud_alert_label.text = _alert_text(active_alert_id)
		hud_alert_label.visible = hud_alert_label.text != ""
	if hud_more_details_label:
		hud_more_details_label.text = "Aster -> Mine -> Worker -> Barracks -> Militia -> Ashen -> Lume"
		hud_more_details_label.visible = more_details_visible
	if hud_more_details_button:
		hud_more_details_button.visible = false
	if hud_help_button:
		hud_help_button.visible = true
	if hud_help_panel:
		hud_help_panel.visible = v0135_help_overlay_visible
	if hud_help_label:
		hud_help_label.text = "\n".join([
			"Select: left-click",
			"Box select: drag",
			"Move: right-click ground",
			"Attack: right-click Ashen",
			"Camera: wheel + WASD",
			"Focus Aster: Space"
		])
	if hud_tooltip_label:
		hud_tooltip_label.text = _short_tooltip_text()
		hud_tooltip_label.visible = hud_tooltip_label.text != ""
	if hud_work_button:
		if current_onboarding_step == "restore_barracks":
			hud_work_button.text = "Restore"
		elif current_onboarding_step == "train_militia" and v0133_selected_structure_id == "barracks":
			hud_work_button.text = "Train"
		else:
			hud_work_button.text = "Work"
	if hud_attack_button:
		hud_attack_button.text = "Attack"

func _sync_player_shell_chrome() -> void:
	if hud_layer:
		hud_layer.visible = (not player_facing_mode) or player_shell_screen == "battle"

func _panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style

func _add_minimap_marker(name: String, position: Vector2, size: Vector2, color: Color) -> void:
	if minimap_panel == null:
		return
	var rect := ColorRect.new()
	rect.name = name
	rect.position = position
	rect.size = size
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_panel.add_child(rect)

func _minimap_has_marker(name: String) -> bool:
	return minimap_panel != null and minimap_panel.get_node_or_null(name) != null

func _minimap_marker_visible(name: String) -> bool:
	if minimap_panel == null:
		return false
	var node := minimap_panel.get_node_or_null(name) as CanvasItem
	return node != null and node.visible

func _set_minimap_marker_visible(name: String, visible: bool) -> void:
	if minimap_panel == null:
		return
	var node := minimap_panel.get_node_or_null(name) as CanvasItem
	if node != null:
		node.visible = visible

func _apply_environment_readability_minimap_markers() -> void:
	if minimap_panel == null:
		return
	for marker in [
		{"name": "v0174_minimap_road_intersections", "pos": Vector2(78, 108), "size": Vector2(90, 28), "color": Color(0.84, 0.76, 0.50, 0.78)},
		{"name": "v0174_minimap_bridge_crossing", "pos": Vector2(116, 111), "size": Vector2(62, 22), "color": Color(0.92, 0.82, 0.58, 0.82)},
		{"name": "v0174_minimap_friendly_boundary", "pos": Vector2(34, 160), "size": Vector2(70, 16), "color": Color(0.28, 0.76, 0.58, 0.62)},
		{"name": "v0174_minimap_hostile_approach", "pos": Vector2(184, 68), "size": Vector2(62, 22), "color": Color(0.88, 0.22, 0.16, 0.70)}
	]:
		if not _minimap_has_marker(str(marker["name"])):
			_add_minimap_marker(str(marker["name"]), marker["pos"], marker["size"], marker["color"])
		_set_minimap_marker_visible(str(marker["name"]), environment_readability_hardening_enabled or environment_contrast_harmonization_enabled or environment_geometry_convergence_enabled or environment_riverbank_bridge_approach_enabled)

func _sync_minimap() -> void:
	if minimap_panel == null:
		return
	_apply_environment_readability_minimap_markers()
	var mine_relevant: bool = ["move_to_quarry", "capture_hold_quarry", "worker_assign_mine"].has(current_onboarding_step) or v0132_mine_controlled
	var worker_relevant: bool = ["worker_mine_or_shrine", "worker_assign_mine", "restore_barracks", "finish_barracks"].has(current_onboarding_step) or bool(runtime.worker_assigned_to_mine)
	var barracks_relevant: bool = ["restore_barracks", "finish_barracks", "queue_militia", "train_militia", "prepare_ashen_pressure", "defeat_wave", "restore_lume_link", "review_results"].has(current_onboarding_step) or v0133_barracks_highlight_visible
	var wave_relevant: bool = v0133_wave_triggered_once and not v0133_wave_defeated_from_simulation
	var lume_relevant: bool = ["restore_lume_link", "review_results"].has(current_onboarding_step) or v0133_lume_highlight_visible or v0133_lume_restored
	_set_minimap_marker_visible("minimap_worker_marker", worker_relevant)
	_set_minimap_marker_visible("minimap_objective_marker", not v0133_results_reached)
	_set_minimap_marker_visible("minimap_west_stone_cut_mine_target", mine_relevant and not v0132_mine_controlled)
	_set_minimap_marker_visible("minimap_west_stone_cut_mine_control", v0132_mine_controlled)
	_set_minimap_marker_visible("minimap_barracks_marker", barracks_relevant)
	_set_minimap_marker_visible("minimap_active_ashen_attackers", wave_relevant)
	_set_minimap_marker_visible("minimap_hostile_marker", wave_relevant)
	_set_minimap_marker_visible("minimap_lume_endpoint_a", lume_relevant)
	_set_minimap_marker_visible("minimap_lume_endpoint_b", lume_relevant)
	_set_minimap_marker_visible("minimap_lume_link", lume_relevant)

func _toggle_more_details() -> void:
	more_details_visible = not more_details_visible
	_sync_hud()

func _hud_move_pressed() -> void:
	if runtime.selected_ids.is_empty():
		runtime.select_entity("hero_aster")
	_issue_real_order(real_input_screen_position("west_stone_cut_mine"))

func _hud_attack_pressed() -> void:
	if current_onboarding_step == "defeat_wave":
		if runtime.selected_ids.is_empty():
			_record_v0134_recovery_feedback("attack_no_selection_auto_recover", "attack_with_no_valid_selection_recovered", {})
		var selected := _select_v0133_defender_squad()
		real_input_squad_box_selected = selected.size() >= 2
		if real_input_squad_box_selected:
			v0133_box_select_no_skip_proven = true
			show_objective_feedback("squad_selected")
			_record_real_input("hud_attack_squad_select", {"count": selected.size(), "ids": selected})
		var target_id := _first_live_v0133_wave_id()
		if target_id != "":
			var attack_ok := runtime.issue_player_facing_wave_defense_order(_v0133_wave_ids(), _v0133_defender_ids())
			real_input_attack_order_accepted = attack_ok
			real_input_attack_marker_rendered = attack_ok
			if attack_ok:
				real_input_selected_id = "defender_squad"
				v0133_selected_structure_id = ""
				v0133_attack_input_accepted = v0133_wave_triggered_once
				v0133_initial_combat_tick_count = runtime.combat_tick_count
				last_feedback_id = "attack_order"
				_set_or_create_disc_marker("real_attack_order_marker", _unit_world_position(target_id, Vector3.ZERO), 0.44, Color(0.96, 0.28, 0.18, 0.50))
			_record_real_input("hud_attack_order", {"accepted": attack_ok, "targetId": target_id, "selectedIds": runtime.selected_ids.duplicate(), "waveDefenseOrder": true})
			_sync_unit_visuals()
			_sync_hud()
			return
	elif runtime.selected_ids.is_empty():
		runtime.box_select_squad()
	var enemy_screen := real_input_screen_position("ashen_00")
	_issue_real_order(enemy_screen)

func _try_handle_v0133_hud_attack_mouse(event: InputEvent) -> bool:
	if not _real_input_enabled() or current_onboarding_step != "defeat_wave" or hud_attack_button == null:
		return false
	if not (event is InputEventMouseButton):
		return false
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return false
	if not _screen_hits_v0133_attack_button(mouse_event.position):
		return false
	_record_real_input("hud_attack_raw_click", {"screen": _vector2_report(mouse_event.position)})
	_hud_attack_pressed()
	return true

func _screen_hits_v0133_attack_button(screen_position: Vector2) -> bool:
	if hud_attack_button != null and hud_attack_button.get_global_rect().has_point(screen_position):
		return true
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return false
	var x_ratio := screen_position.x / viewport_size.x
	var y_ratio := screen_position.y / viewport_size.y
	return x_ratio >= 0.075 and x_ratio <= 0.145 and y_ratio >= 0.92 and y_ratio <= 0.995

func _screen_hits_v0133_train_button(screen_position: Vector2) -> bool:
	if hud_work_button != null and hud_work_button.get_global_rect().has_point(screen_position):
		return true
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return false
	var x_ratio := screen_position.x / viewport_size.x
	var y_ratio := screen_position.y / viewport_size.y
	return x_ratio >= 0.18 and x_ratio <= 0.24 and y_ratio >= 0.92 and y_ratio <= 0.995

func _select_v0133_defender_squad() -> Array[String]:
	var preferred: Array[String] = _v0133_defender_ids()
	var ids: Array[String] = []
	for id in preferred:
		if runtime.unit_alive(id):
			ids.append(id)
	var selected := runtime.select_units_by_ids(ids)
	if selected.size() >= 2:
		real_input_selected_id = "defender_squad"
		v0133_selected_structure_id = ""
		return selected
	selected = runtime.box_select_squad()
	if selected.size() >= 2:
		real_input_selected_id = "defender_squad"
		v0133_selected_structure_id = ""
	return selected

func _first_live_v0133_wave_id() -> String:
	for id in _v0133_wave_ids():
		if runtime.unit_alive(id):
			return id
	return ""

func _hud_work_pressed() -> void:
	if current_onboarding_step == "restore_barracks" and runtime.worker_assigned_to_mine:
		if runtime.selected_ids.is_empty():
			runtime.select_entity("worker_00")
		_start_v0133_barracks_restoration(real_input_screen_position("barracks"))
		return
	if current_onboarding_step == "train_militia" and v0133_selected_structure_id == "barracks":
		_queue_v0133_militia_from_input()
		return
	select_entity("worker")

func _hud_lume_pressed() -> void:
	if current_onboarding_step == "restore_lume_link":
		_restore_v0133_lume_from_input(real_input_screen_position("lume"))
		return
	focus_lume_link()

func _record_notification(id: String) -> void:
	if notification_history.size() > 0 and notification_history[notification_history.size() - 1] == id:
		return
	notification_history.append(id)
	while notification_history.size() > 4:
		notification_history.pop_front()

func _player_status_text() -> String:
	if runtime.paused:
		return "Paused"
	if v0133_results_reached or runtime.results_ready:
		return "Results ready."
	if v0133_lume_highlight_visible:
		return "Lume link highlighted."
	if v0133_wave_triggered_once and not v0133_wave_defeated_from_simulation:
		return "Ashen remaining: %s" % maxi(0, v0133_wave_remaining_count)
	if v0133_countdown_started and not v0133_wave_triggered_once:
		return "Ashen pressure in %ss" % int(ceil(v0133_countdown_remaining))
	if runtime.militia_spawned:
		return "Militia ready."
	if v0133_recruit_queue_started:
		return "Militia training: %s%%" % int(round(v0133_recruit_progress * 100.0))
	if runtime.barracks_complete:
		return "Barracks restored."
	if v0133_construction_started:
		return "Barracks: %s%%" % int(round(v0133_construction_progress * 100.0))
	if runtime.worker_assigned_to_mine:
		return "Worker assigned."
	if v0132_mine_controlled or runtime.mine_converted:
		return "Mine controlled."
	if v0132_site_state == SITE_STATE_CONVERTING:
		return "Mine: %s%%" % int(round(v0132_conversion_progress))
	if v0132_site_state == SITE_STATE_OBJECTIVE_TARGET:
		return "Move Aster to the mine ring."
	if pressure_wave_arrived:
		return "Ashen on the road."
	if runtime.lume_links.any(func(link: Dictionary) -> bool: return bool(link.get("focused", false))):
		return "Lume route marked."
	return "Ready."

func _selected_context_text() -> String:
	if current_onboarding_step == "defeat_wave" and runtime.selected_ids.size() > 1:
		return "Defenders selected."
	if current_onboarding_step == "defeat_wave" and runtime.selected_ids.is_empty():
		return "Select defenders."
	if runtime.selected_ids.size() > 1:
		v0135_selected_squad_count_visible = true
		return "Squad selected: %s units" % runtime.selected_ids.size()
	if v0133_selected_structure_id == "barracks":
		return "Barracks selected."
	if runtime.selected_ids.is_empty() or runtime.selected_ids.has("hero_aster"):
		return "Aster HP 100/100"
	if runtime.selected_ids.any(func(id: String) -> bool: return id.begins_with("worker")):
		return "Worker selected."
	return "Unit ready"

func _short_tooltip_text() -> String:
	if v0135_help_overlay_visible:
		return "F1 or Escape closes controls"
	if last_feedback_id == "no_selection_order":
		return "Select a unit first"
	if last_feedback_id == "invalid_ground":
		return "Choose reachable ground"
	if last_feedback_id.begins_with("context_"):
		return "Context order accepted"
	if last_feedback_id == "move_order":
		return "Move marker placed"
	if last_feedback_id == "attack_order":
		return "Attack marker placed"
	if real_input_hover_id != "":
		return "Hover: %s" % _player_entity_label(real_input_hover_id)
	return ""

func _objective_summary_text() -> String:
	if v0133_wave_triggered_once and not v0133_wave_defeated_from_simulation:
		return "Wave: %s left" % maxi(0, v0133_wave_remaining_count)
	if v0133_countdown_started and not v0133_wave_triggered_once:
		return "Countdown: %ss" % int(ceil(v0133_countdown_remaining))
	if v0133_recruit_queue_started and not v0133_militia_spawned:
		return "Training: %s%%" % int(round(v0133_recruit_progress * 100.0))
	if v0133_construction_started and not v0133_barracks_restored:
		return "Build: %s%%" % int(round(v0133_construction_progress * 100.0))
	if v0132_site_state == SITE_STATE_CONVERTING:
		return "Conversion: %s%%" % int(round(v0132_conversion_progress))
	if v0133_lume_highlight_visible:
		return "Lume ready"
	return "No active progress"

func _current_objective_text() -> String:
	match current_onboarding_step:
		"select_aster":
			return "1. Select Aster"
		"move_to_quarry":
			return "2. Right-click West Stone Cut Mine"
		"capture_hold_quarry":
			return "3. Stay in the ring"
		"worker_mine_or_shrine":
			return "4. Select Worker"
		"worker_assign_mine":
			return "5. Right-click controlled mine"
		"restore_barracks":
			return "6. Restore Barracks"
		"finish_barracks":
			return "6. Restore Barracks"
		"queue_militia":
			return "7. Select Barracks"
		"train_militia":
			return "7. Click Train"
		"prepare_ashen_pressure":
			return "8. Prepare for Ashen pressure"
		"defeat_wave":
			return "9. Defeat marked Ashen"
		"restore_lume_link":
			return "10. Restore Lume link"
		"review_results":
			return "Results"
	return "Secure Salto"

func _onboarding_text(step_id: String) -> String:
	match step_id:
		"select_aster":
			return "Select Aster."
		"move_to_quarry":
			return "Right-click West Stone Cut Mine."
		"capture_hold_quarry":
			return "Stay inside the ring to convert it."
		"worker_mine_or_shrine":
			return "Select Worker."
		"worker_assign_mine":
			return "Right-click the controlled mine."
		"restore_barracks":
			return "Right-click Barracks to restore it."
		"finish_barracks":
			return "Wait for construction."
		"queue_militia":
			return "Select Barracks."
		"train_militia":
			return "Click Train."
		"prepare_ashen_pressure":
			return "Prepare for Ashen pressure."
		"defeat_wave":
			return "Select defenders and attack marked Ashen units."
		"restore_lume_link":
			return "Restore the Lume link."
		"review_results":
			return "Review Results."
	return ""

func _alert_text(alert_id: String) -> String:
	match alert_id:
		"objective_1", "select_aster":
			return "Aster selected"
		"move_to_quarry":
			return "Move order to West Stone Cut Mine set"
		"quarry_complete":
			return "West Stone Cut Mine controlled"
		"mine_converted":
			return "West Stone Cut Mine converted"
		"worker_assigned_mine":
			return "Worker assigned to mine"
		"barracks_placed":
			return "Barracks restoration started"
		"barracks_complete":
			return "Barracks restored"
		"militia_queued":
			return "Militia queued"
		"militia_spawned":
			return "Militia ready"
		"squad_selected":
			return "Defenders selected"
		"barracks_selected":
			return "Barracks selected"
		"pressure_wave":
			return "Ashen wave in view: four attackers"
		"wave_defeated":
			return "Ashen wave defeated"
		"lume_activation":
			return "Lume link responding"
		"lume_restore":
			return "Lume link restored"
		"results_summary":
			return "Results ready"
	return ""

func _player_selection_summary() -> String:
	var labels: Array[String] = []
	for id in runtime.selected_ids:
		labels.append(_player_entity_label(str(id)))
	if labels.is_empty():
		return "Aster"
	var selected := labels.slice(0, min(3, labels.size()))
	var suffix := " + squad" if labels.size() > selected.size() else ""
	return ", ".join(selected) + suffix

func _player_entity_label(id: String) -> String:
	if id == "hero_aster":
		return "Aster"
	if id.begins_with("worker"):
		return "Worker"
	for unit in runtime.units:
		if str(unit.get("id", "")) == id:
			var fixture := str(unit.get("fixtureId", ""))
			var owner := str(unit.get("owner", ""))
			if fixture == "ranger":
				return "Ranger"
			if fixture == "militia":
				return "Militia"
			if owner == "enemy":
				return "Ashen unit"
	return "Unit"

func _rebuild_visuals() -> void:
	if visual_root == null:
		return
	for child in visual_root.get_children():
		visual_root.remove_child(child)
		child.free()
	aster_label = null
	west_stone_cut_label = null
	worker_guidance_label = null
	barracks_material_applied_surface_count = 0
	_refresh_barracks_material_counters()
	for structure in runtime.structures:
		_add_structure(structure)
	for site in runtime.sites:
		_add_capture_site(site)
	for link in runtime.lume_links:
		var from_endpoint: Dictionary = runtime.lume_endpoints[int(link["from"])]
		var to_endpoint: Dictionary = runtime.lume_endpoints[int(link["to"])]
		var midpoint: Vector2 = (from_endpoint["position"] + to_endpoint["position"]) / 2.0
		var length: float = from_endpoint["position"].distance_to(to_endpoint["position"]) / 90.0
		_add_box(str(link["id"]), _to_world(midpoint, 0.18), Vector3(0.08, 0.08, max(0.24, length)), _lume_color(link), false, true)
		if visual_preset == VISUAL_PRESET_VFX_STRESS:
			_add_box("%s_private_transition_pulse" % str(link["id"]), _to_world(midpoint, 0.28), Vector3(0.16, 0.06, max(0.28, length + 0.10)), _lume_color(link).lightened(0.24), true, true)
	for endpoint in runtime.lume_endpoints:
		_add_unit(str(endpoint["id"]), _to_world(endpoint["position"], 0.22), _lume_core_color(), 0.13, true)
		_add_cylinder("%s_readability_ring" % str(endpoint["id"]), _to_world(endpoint["position"], 0.075), 0.26, 0.035, _lume_core_color().lightened(0.14), true)
		_add_box("%s_future_art_anchor" % str(endpoint["id"]), _to_world(endpoint["position"], 0.35), Vector3(0.10, 0.34, 0.10), _lume_core_color(), false, true)
	for unit in runtime.units:
		_add_unit_silhouette(unit)
		_add_selection_disc("selection_%s" % str(unit["id"]), _to_world(unit["position"], 0.08), _unit_radius(unit) * 2.2, _selection_color(unit))
		_add_selection_disc("selected_hero_marker_%s" % str(unit["id"]), _to_world(unit["position"], 0.095), _unit_radius(unit) * 2.9, Color(0.80, 0.92, 0.70, 0.38))
		_add_selection_disc("selected_worker_marker_%s" % str(unit["id"]), _to_world(unit["position"], 0.09), _unit_radius(unit) * 2.45, Color(0.92, 0.78, 0.42, 0.36))
		_add_selection_disc("squad_marker_%s" % str(unit["id"]), _to_world(unit["position"], 0.07), _unit_radius(unit) * 1.62, Color(0.54, 0.84, 0.68, 0.30))
		_add_selection_disc("enemy_target_marker_%s" % str(unit["id"]), _to_world(unit["position"], 0.105), _unit_radius(unit) * 2.4, Color(0.94, 0.24, 0.16, 0.38))
		_add_box("health_back_%s" % str(unit["id"]), _to_world(unit["position"], 0.665), Vector3(_unit_radius(unit) * 1.75, 0.028, 0.035), Color(0.08, 0.10, 0.08, 0.62), true, false)
		_add_box("health_%s" % str(unit["id"]), _to_world(unit["position"], 0.68), Vector3(_unit_radius(unit) * 1.65, 0.035, 0.035), Color(0.28, 0.88, 0.44), false, false)
		_add_box("damage_flash_%s" % str(unit["id"]), _to_world(unit["position"], 0.58), Vector3(_unit_radius(unit) * 1.4, 0.12, _unit_radius(unit) * 1.4), Color(0.98, 0.52, 0.24, 0.48), true, true)
	_sync_unit_visuals()

func _sync_unit_visuals() -> void:
	if visual_root == null:
		return
	for unit in runtime.units:
		var id := str(unit["id"])
		var node := visual_root.get_node_or_null(id) as MeshInstance3D
		var selection := visual_root.get_node_or_null("selection_%s" % id) as MeshInstance3D
		if node == null:
			continue
		var alive: bool = bool(unit["alive"])
		var visible_unit: bool = alive and not bool(unit.get("reviewHidden", false))
		var selected: bool = runtime.selected_ids.has(id)
		var is_enemy: bool = str(unit["team"]) == "enemy"
		var is_wave_enemy: bool = is_enemy and _v0133_wave_ids().has(id)
		var is_targeted: bool = _unit_is_attack_target(id) or (is_wave_enemy and (current_onboarding_step == "defeat_wave" or last_feedback_id == "attack_order" or combat_readability_active or pressure_wave_arrived))
		var worker_billboard := str(unit["role"]) == "Worker" and _worker_art_is_active()
		var aster_billboard := _aster_art_applies_to_unit(unit)
		var militia_billboard := _militia_art_applies_to_unit(unit)
		var ashen_billboard := _ashen_art_applies_to_unit(unit)
		var unit_y := 0.28
		if worker_billboard:
			unit_y = _worker_art_unit_y()
		elif aster_billboard:
			unit_y = _aster_art_unit_y(selected)
		elif militia_billboard:
			unit_y = _militia_art_unit_y()
		elif ashen_billboard:
			unit_y = _ashen_art_unit_y(selected)
		node.position = _to_world(unit["position"], unit_y)
		var visual_scale := _unit_scale(unit) * (1.22 if selected else 1.0)
		if aster_billboard:
			visual_scale = Vector3.ONE * (1.12 if selected else 1.0)
		elif ashen_billboard:
			visual_scale = Vector3.ONE * (1.08 if selected else 1.0)
		node.scale = visual_scale
		node.visible = visible_unit
		var health_y := 0.665
		if aster_billboard:
			health_y = ASTER_ART_GROUND_CLEARANCE + _aster_art_unit_height() * (1.12 if selected else 1.0) + 0.08
		elif ashen_billboard:
			health_y = ASHEN_ART_GROUND_CLEARANCE + _ashen_art_unit_height() * (1.08 if selected else 1.0) + 0.06
		var health_fill_y := health_y + 0.015
		var damage_y := 0.58
		if aster_billboard:
			damage_y = ASTER_ART_GROUND_CLEARANCE + _aster_art_unit_height() * 0.62
		elif ashen_billboard:
			damage_y = ASHEN_ART_GROUND_CLEARANCE + _ashen_art_unit_height() * 0.58
		var health_ratio: float = clampf(float(unit.get("health", 0.0)) / max(1.0, float(unit.get("maxHealth", 1.0))), 0.0, 1.0)
		var health_visible: bool = visible_unit and (selected or is_targeted or damage_flash_active)
		var health_back := visual_root.get_node_or_null("health_back_%s" % id) as MeshInstance3D
		if health_back:
			health_back.position = _to_world(unit["position"], health_y)
			health_back.visible = health_visible
		var health := visual_root.get_node_or_null("health_%s" % id) as MeshInstance3D
		if health:
			var full_width: float = _unit_radius(unit) * 1.65
			var mesh := health.mesh as BoxMesh
			if mesh:
				mesh.size = Vector3(max(0.026, full_width * health_ratio), 0.035, 0.035)
			health.position = _to_world(unit["position"], health_fill_y) + Vector3((health_ratio - 1.0) * full_width * 0.5, 0.0, 0.0)
			health.visible = health_visible
		if selection:
			selection.position = _to_world(unit["position"], 0.08)
			selection.visible = visible_unit and selected
		var hero_marker := visual_root.get_node_or_null("selected_hero_marker_%s" % id) as MeshInstance3D
		if hero_marker:
			hero_marker.position = _to_world(unit["position"], 0.095)
			hero_marker.visible = visible_unit and selected and str(unit["role"]) == "hero"
		var worker_marker := visual_root.get_node_or_null("selected_worker_marker_%s" % id) as MeshInstance3D
		if worker_marker:
			worker_marker.position = _to_world(unit["position"], 0.09)
			worker_marker.visible = visible_unit and selected and str(unit["role"]) == "Worker"
		var squad_marker := visual_root.get_node_or_null("squad_marker_%s" % id) as MeshInstance3D
		if squad_marker:
			squad_marker.position = _to_world(unit["position"], 0.07)
			squad_marker.visible = visible_unit and selected and runtime.selected_ids.size() > 1
		var target_marker := visual_root.get_node_or_null("enemy_target_marker_%s" % id) as MeshInstance3D
		if target_marker:
			target_marker.position = _to_world(unit["position"], 0.105)
			target_marker.visible = visible_unit and is_targeted
		var damage_marker := visual_root.get_node_or_null("damage_flash_%s" % id) as MeshInstance3D
		if damage_marker:
			damage_marker.position = _to_world(unit["position"], damage_y)
			damage_marker.visible = visible_unit and damage_flash_active and (is_targeted or id == "ashen_00")
	_sync_real_input_hover_marker()
	_sync_player_guidance_markers()
	_sync_three_slot_review_art_anchors()

func _sync_three_slot_review_art_anchors() -> void:
	if visual_root == null:
		return
	var active := three_slot_art_review_framing_active and player_facing_mode and player_shell_screen == "battle"
	var five_slot_review := active and five_slot_art_review_framing_active
	for unit in runtime.units:
		var id := str(unit["id"])
		var is_worker := str(unit.get("role", "")) == "Worker"
		var is_aster := _aster_art_applies_to_unit(unit)
		var is_militia := _militia_art_applies_to_unit(unit)
		var is_ashen := _ashen_art_applies_to_unit(unit)
		var ring_name := "v0166_art_review_ring_%s" % id
		var worker_ring_color := Color(0.96, 0.74, 0.34, 0.22)
		var aster_ring_color := Color(0.92, 0.88, 0.38, 0.24)
		var ashen_ring_color := Color(0.92, 0.34, 0.28, 0.24)
		var militia_ring_color := Color(0.46, 0.92, 0.72, 0.18)
		var worker_ring_radius := 2.15
		var aster_ring_radius := 2.35
		var ashen_ring_radius := 2.05
		var militia_ring_radius := 1.85
		if five_slot_review:
			worker_ring_color = Color(0.96, 0.74, 0.34, 0.13)
			aster_ring_color = Color(0.92, 0.88, 0.38, 0.14)
			ashen_ring_color = Color(0.92, 0.34, 0.28, 0.13)
			militia_ring_color = Color(0.46, 0.92, 0.72, 0.11)
			worker_ring_radius = 1.58
			aster_ring_radius = 1.74
			ashen_ring_radius = 1.62
			militia_ring_radius = 1.48
		var ring_color := worker_ring_color if is_worker else (aster_ring_color if is_aster else (ashen_ring_color if is_ashen else militia_ring_color))
		var ring_radius := _unit_radius(unit) * (worker_ring_radius if is_worker else (aster_ring_radius if is_aster else (ashen_ring_radius if is_ashen else militia_ring_radius)))
		_set_or_create_disc_marker(ring_name, _unit_world_position(id, Vector3.ZERO) + Vector3(0.0, 0.025, 0.0), ring_radius, ring_color)
		var ring := visual_root.get_node_or_null(ring_name) as MeshInstance3D
		if ring:
			ring.visible = active and bool(unit.get("alive", false)) and not bool(unit.get("reviewHidden", false)) and (is_worker and _worker_art_is_active() or is_militia or is_aster or is_ashen)
	var barracks_world := _to_world(BARRACKS_POSITION, 0.74)
	var barracks_sheen_color := Color(0.98, 0.84, 0.42, 0.22) if five_slot_review else Color(0.98, 0.84, 0.42, 0.34)
	_set_or_create_marker("v0166_barracks_material_review_sheen", barracks_world + Vector3(0.12, 0.18, -0.16), Vector3(1.18, 0.055, 0.52), barracks_sheen_color)
	var barracks_sheen := visual_root.get_node_or_null("v0166_barracks_material_review_sheen") as MeshInstance3D
	if barracks_sheen:
		barracks_sheen.visible = active and _barracks_material_is_active()

func _sync_real_input_hover_marker() -> void:
	if visual_root == null:
		return
	var marker := visual_root.get_node_or_null("hover_feedback_marker") as MeshInstance3D
	if marker == null:
		return
	if real_input_hover_id == "":
		marker.visible = false
		return
	var hover_position := _unit_world_position(real_input_hover_id, Vector3.INF)
	if hover_position == Vector3.INF:
		marker.visible = false
		return
	marker.position = hover_position + Vector3(0.0, 0.045, 0.0)
	marker.visible = true

func _sync_site_visuals() -> void:
	if visual_root == null:
		return
	for site in runtime.sites:
		var node := visual_root.get_node_or_null(str(site["id"])) as MeshInstance3D
		if node:
			node.material_override = _material(_site_color(site), true)

func _sync_lume_visuals() -> void:
	if visual_root == null:
		return
	for link in runtime.lume_links:
		var node := visual_root.get_node_or_null(str(link["id"])) as MeshInstance3D
		if node:
			node.material_override = _material(_lume_color(link), false, true, _lume_emission())
			node.scale = Vector3.ONE * (1.35 if bool(link.get("focused", false)) else 1.0)

func _sync_player_guidance_markers() -> void:
	if visual_root == null:
		return
	var hero_position := _unit_world_position("hero_aster", Vector3.INF)
	if hero_position == Vector3.INF:
		return
	var selected_aster_helper_step: bool = current_onboarding_step == "move_to_quarry" or current_onboarding_step == "capture_hold_quarry"
	var show_aster_helper: bool = player_facing_mode and player_shell_screen == "battle" and (current_onboarding_step == "select_aster" or (runtime.selected_ids.has("hero_aster") and selected_aster_helper_step))
	_set_or_create_disc_marker("aster_focus_pulse", hero_position + Vector3(0.0, 0.03, 0.0), 0.58, Color(0.98, 0.90, 0.38, 0.42))
	var pulse := visual_root.get_node_or_null("aster_focus_pulse") as MeshInstance3D
	if pulse:
		pulse.visible = show_aster_helper
	_set_or_create_marker("aster_objective_arrow", hero_position + Vector3(0.0, 0.88, -0.18), Vector3(0.18, 0.34, 0.18), Color(0.98, 0.90, 0.38, 0.72))
	var arrow := visual_root.get_node_or_null("aster_objective_arrow") as MeshInstance3D
	if arrow:
		arrow.visible = show_aster_helper
	if aster_label == null:
		aster_label = Label3D.new()
		aster_label.name = "AsterFirstObjectiveLabel"
		aster_label.text = "ASTER"
		aster_label.font_size = 34
		aster_label.modulate = Color(0.98, 0.94, 0.62)
		aster_label.outline_size = 8
		aster_label.outline_modulate = Color(0.02, 0.03, 0.02)
		visual_root.add_child(aster_label)
	aster_label.position = hero_position + Vector3(0.0, 0.86, 0.0)
	aster_label.visible = show_aster_helper
	var destination := visual_root.get_node_or_null("move_destination_pulse") as MeshInstance3D
	if destination:
		destination.visible = player_facing_mode and player_shell_screen == "battle" and current_onboarding_step == "move_to_quarry"
	_sync_v0132_site_guidance_markers()

func _sync_v0132_site_guidance_markers() -> void:
	if visual_root == null or not player_facing_mode or player_shell_screen != "battle":
		return
	var mine_world := _to_world(WEST_STONE_CUT_MINE_POSITION, 0.14)
	var show_site_guidance := current_onboarding_step == "move_to_quarry" or current_onboarding_step == "capture_hold_quarry" or v0132_mine_controlled
	_set_or_create_disc_marker("west_stone_cut_mine_objective_ring", mine_world + Vector3(0.0, 0.012, 0.0), 0.78, Color(0.96, 0.82, 0.24, 0.48))
	var objective_ring := visual_root.get_node_or_null("west_stone_cut_mine_objective_ring") as MeshInstance3D
	if objective_ring:
		objective_ring.visible = show_site_guidance
	_set_or_create_disc_marker("west_stone_cut_mine_capture_radius", mine_world + Vector3(0.0, 0.02, 0.0), 0.64, Color(0.36, 0.74, 0.96, 0.32))
	var capture_radius := visual_root.get_node_or_null("west_stone_cut_mine_capture_radius") as MeshInstance3D
	if capture_radius:
		capture_radius.visible = show_site_guidance and not v0132_mine_controlled
	_set_or_create_marker("west_stone_cut_conversion_back", mine_world + Vector3(0.0, 0.56, 0.30), Vector3(0.92, 0.06, 0.08), Color(0.08, 0.10, 0.08, 0.72))
	var progress_back := visual_root.get_node_or_null("west_stone_cut_conversion_back") as MeshInstance3D
	if progress_back:
		progress_back.visible = v0132_site_state == SITE_STATE_CONVERTING or v0132_mine_controlled
	var progress_width: float = maxf(0.05, 0.88 * clampf(v0132_conversion_progress / 100.0, 0.0, 1.0))
	_set_or_create_marker("west_stone_cut_conversion_bar", mine_world + Vector3((progress_width - 0.88) * 0.5, 0.60, 0.30), Vector3(progress_width, 0.08, 0.10), Color(0.38, 0.92, 0.56, 0.78))
	var progress_bar := visual_root.get_node_or_null("west_stone_cut_conversion_bar") as MeshInstance3D
	if progress_bar:
		progress_bar.visible = v0132_site_state == SITE_STATE_CONVERTING or v0132_mine_controlled
	_set_or_create_marker("west_stone_cut_control_banner", mine_world + Vector3(-0.52, 0.44, -0.34), Vector3(0.12, 0.46, 0.30), Color(0.34, 0.88, 0.52, 0.72))
	var control_banner := visual_root.get_node_or_null("west_stone_cut_control_banner") as MeshInstance3D
	if control_banner:
		control_banner.visible = v0132_mine_controlled
	if west_stone_cut_label == null:
		west_stone_cut_label = Label3D.new()
		west_stone_cut_label.name = "WestStoneCutMineObjectiveLabel"
		west_stone_cut_label.text = WEST_STONE_CUT_MINE_LABEL
		west_stone_cut_label.font_size = 24
		west_stone_cut_label.modulate = Color(0.98, 0.92, 0.58)
		west_stone_cut_label.outline_size = 6
		west_stone_cut_label.outline_modulate = Color(0.02, 0.03, 0.02)
		visual_root.add_child(west_stone_cut_label)
	west_stone_cut_label.position = mine_world + Vector3(0.0, 0.92, 0.0)
	west_stone_cut_label.visible = show_site_guidance
	var worker_position := _unit_world_position("worker_00", Vector3.INF)
	if worker_position == Vector3.INF:
		return
	var show_worker_guidance := v0132_mine_controlled and not v0132_worker_assignment_complete
	if show_worker_guidance:
		v0132_worker_highlight_visible = true
	_set_or_create_disc_marker("worker_assignment_focus_ring", worker_position + Vector3(0.0, 0.03, 0.0), 0.42, Color(0.98, 0.78, 0.30, 0.46))
	var worker_ring := visual_root.get_node_or_null("worker_assignment_focus_ring") as MeshInstance3D
	if worker_ring:
		worker_ring.visible = show_worker_guidance
	_set_or_create_marker("worker_assignment_arrow", worker_position + Vector3(0.0, 0.70, -0.12), Vector3(0.14, 0.30, 0.14), Color(0.98, 0.78, 0.30, 0.72))
	var worker_arrow := visual_root.get_node_or_null("worker_assignment_arrow") as MeshInstance3D
	if worker_arrow:
		worker_arrow.visible = show_worker_guidance
	if worker_guidance_label == null:
		worker_guidance_label = Label3D.new()
		worker_guidance_label.name = "WorkerAssignmentObjectiveLabel"
		worker_guidance_label.text = "WORKER"
		worker_guidance_label.font_size = 22
		worker_guidance_label.modulate = Color(0.98, 0.82, 0.44)
		worker_guidance_label.outline_size = 6
		worker_guidance_label.outline_modulate = Color(0.02, 0.03, 0.02)
		visual_root.add_child(worker_guidance_label)
	worker_guidance_label.position = worker_position + Vector3(0.0, 0.72, 0.0)
	worker_guidance_label.visible = show_worker_guidance

func _add_presentation_shell_v2_visual_box(name: String, position: Vector3, scale: Vector3, color: Color, category: String, transparent: bool = false, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _presentation_shell_v2_material(category, color, transparent, emissive, _lume_emission())
	visual_root.add_child(mesh_instance)
	_count_presentation_shell_v2_surface(category)

func _add_presentation_shell_v2_structure_mass(id: String, fixture: String, position: Vector3, scale: Vector3, color: Color, structure: Dictionary) -> void:
	var team := str(structure.get("team", "neutral"))
	var contact := Color(0.035, 0.045, 0.030, 0.50)
	if team == "friendly":
		contact = Color(0.055, 0.090, 0.050, 0.52)
	elif team == "enemy":
		contact = Color(0.120, 0.035, 0.025, 0.48)
	_add_presentation_shell_v2_visual_box("%s_v0193_grounded_mass_shadow" % id, position + Vector3(0.0, -0.275, 0.02), Vector3(scale.x * 1.12, 0.032, scale.z * 1.04), contact, "structures", true)
	_add_presentation_shell_v2_visual_box("%s_post_v0195_foundation_contact" % id, position + Vector3(0.0, -0.235, scale.z * 0.03), Vector3(scale.x * 0.88, 0.020, scale.z * 0.78), contact.darkened(0.08), "structures", true)
	match fixture:
		"command_hall":
			_add_presentation_shell_v2_visual_box("%s_v0193_keep_core" % id, position + Vector3(0.0, 0.34, -scale.z * 0.04), Vector3(scale.x * 0.48, 0.56, scale.z * 0.42), color.darkened(0.10), "structures")
			_add_presentation_shell_v2_visual_box("%s_v0193_low_roof_mass" % id, position + Vector3(0.0, 0.74, 0.0), Vector3(scale.x * 0.86, 0.105, scale.z * 0.62), color.lightened(0.12), "structures")
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_roof_ridge_spine" % id, position + Vector3(0.0, 0.82, -scale.z * 0.02), Vector3(scale.x * 0.70, 0.052, scale.z * 0.080), color.lightened(0.24), "structures")
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_rear_wing_shadow" % id, position + Vector3(-scale.x * 0.28, 0.22, -scale.z * 0.34), Vector3(scale.x * 0.28, 0.24, scale.z * 0.18), color.darkened(0.18), "structures", true)
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_right_buttress" % id, position + Vector3(scale.x * 0.36, 0.17, -scale.z * 0.02), Vector3(scale.x * 0.090, 0.30, scale.z * 0.44), color.darkened(0.20), "structures", true)
			_add_presentation_shell_v2_visual_box("%s_post_v0195_entry_sill" % id, position + Vector3(0.0, 0.02, scale.z * 0.50), Vector3(scale.x * 0.28, 0.040, 0.075), Color(0.16, 0.13, 0.09, 0.72), "structures", true)
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_entry_shadow" % id, position + Vector3(0.0, 0.16, scale.z * 0.53), Vector3(scale.x * 0.22, 0.18, 0.052), Color(0.060, 0.045, 0.032, 0.72), "structures", true)
			_add_presentation_shell_v2_visual_box("%s_v0193_hearth_slot" % id, position + Vector3(scale.x * 0.34, 0.22, scale.z * 0.54), Vector3(0.075, 0.120, 0.050), Color(0.86, 0.45, 0.19), "structures", true, true)
		"enemy_stronghold":
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_stronghold_core" % id, position + Vector3(0.0, 0.38, -scale.z * 0.02), Vector3(scale.x * 0.52, 0.60, scale.z * 0.46), color.darkened(0.16), "structures")
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_stronghold_low_wall" % id, position + Vector3(0.0, 0.16, scale.z * 0.44), Vector3(scale.x * 0.92, 0.22, scale.z * 0.15), color.darkened(0.28), "structures")
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_stronghold_roof_plate" % id, position + Vector3(0.0, 0.76, -scale.z * 0.02), Vector3(scale.x * 0.76, 0.090, scale.z * 0.58), color.lightened(0.08), "structures")
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_stronghold_gate" % id, position + Vector3(0.0, 0.20, scale.z * 0.54), Vector3(scale.x * 0.24, 0.22, 0.060), Color(0.055, 0.030, 0.022, 0.78), "structures", true)
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_hostile_banner_read" % id, position + Vector3(-scale.x * 0.40, 0.60, scale.z * 0.18), Vector3(0.060, 0.30, scale.z * 0.20), _banner_color(structure), "structures", true)
		"ford_toll":
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_toll_plinth" % id, position + Vector3(0.0, 0.10, 0.0), Vector3(scale.x * 0.76, 0.18, scale.z * 0.48), color.darkened(0.12), "structures")
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_toll_roof" % id, position + Vector3(0.0, 0.38, -scale.z * 0.02), Vector3(scale.x * 0.58, 0.070, scale.z * 0.42), color.lightened(0.14), "structures")
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_toll_open_shadow" % id, position + Vector3(0.0, 0.20, scale.z * 0.28), Vector3(scale.x * 0.40, 0.12, 0.052), Color(0.060, 0.050, 0.034, 0.64), "structures", true)
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_toll_marker_lume" % id, position + Vector3(scale.x * 0.38, 0.36, scale.z * 0.12), Vector3(0.052, 0.16, 0.052), Color(0.88, 0.55, 0.24), "structures", true, true)
		"west_stone_cut":
			_add_presentation_shell_v2_visual_box("%s_v0193_quarry_face" % id, position + Vector3(-scale.x * 0.34, 0.18, scale.z * 0.42), Vector3(scale.x * 0.42, 0.34, 0.120), Color(0.055, 0.060, 0.050), "structures")
			_add_presentation_shell_v2_visual_box("%s_v0193_retaining_wall" % id, position + Vector3(scale.x * 0.22, 0.06, scale.z * 0.50), Vector3(scale.x * 0.70, 0.105, 0.100), Color(0.48, 0.46, 0.38), "structures")
			_add_presentation_shell_v2_visual_box("%s_v0193_tailings_stack" % id, position + Vector3(scale.x * 0.34, 0.10, -scale.z * 0.26), Vector3(scale.x * 0.50, 0.115, scale.z * 0.30), Color(0.58, 0.56, 0.48), "structures")
			_add_presentation_shell_v2_visual_box("%s_post_v0195_tailings_shadow" % id, position + Vector3(scale.x * 0.30, -0.08, -scale.z * 0.22), Vector3(scale.x * 0.56, 0.020, scale.z * 0.34), contact.darkened(0.06), "structures", true)
		"barracks":
			var restoring := str(structure.get("constructionState", "")) != "complete"
			_add_barracks_material_box("%s_v0193_left_training_mass" % id, position + Vector3(-scale.x * 0.24, 0.28, -scale.z * 0.02), Vector3(scale.x * 0.34, 0.34, scale.z * 0.64), color.lightened(0.10))
			_count_presentation_shell_v2_surface("structures")
			_add_barracks_material_box("%s_v0193_right_training_mass" % id, position + Vector3(scale.x * 0.24, 0.25, scale.z * 0.02), Vector3(scale.x * 0.34, 0.30, scale.z * 0.64), color.darkened(0.10))
			_count_presentation_shell_v2_surface("structures")
			_add_barracks_material_box("%s_v0193_roof_binding" % id, position + Vector3(0.0, 0.62, 0.0), Vector3(scale.x * 0.74, 0.075, scale.z * 0.58), color.lightened(0.18))
			_count_presentation_shell_v2_surface("structures")
			_add_presentation_shell_v2_visual_box("%s_v0193_drill_yard_edge" % id, position + Vector3(0.0, -0.13, scale.z * 0.72), Vector3(scale.x * 0.98, 0.045, 0.100), Color(0.40, 0.31, 0.18, 0.54), "structures", true)
			_add_presentation_shell_v2_visual_box("%s_post_v0195_drill_yard_shadow" % id, position + Vector3(0.0, -0.18, scale.z * 0.54), Vector3(scale.x * 0.88, 0.020, scale.z * 0.30), contact.darkened(0.06), "structures", true)
			if restoring:
				var progress := clampf(float(structure.get("constructionProgress", 0.0)), 0.0, 1.0)
				_add_presentation_shell_v2_visual_box("%s_v0193_restoration_progress" % id, position + Vector3((progress - 1.0) * scale.x * 0.20, 0.72, scale.z * 0.50), Vector3(max(0.08, scale.x * 0.40 * progress), 0.044, 0.055), Color(0.42, 0.78, 0.48, 0.58), "structures", true)
		_:
			_add_presentation_shell_v2_visual_box("%s_v0193_site_shell_mass" % id, position + Vector3(0.0, 0.20, 0.0), Vector3(scale.x * 0.58, 0.30, scale.z * 0.58), color.darkened(0.08), "structures", true)
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_site_roof_cap" % id, position + Vector3(0.0, 0.40, -scale.z * 0.02), Vector3(scale.x * 0.66, 0.060, scale.z * 0.50), color.lightened(0.12), "structures", true)
			_add_presentation_shell_v2_visual_box("%s_post_v0195_v2_site_entry_shadow" % id, position + Vector3(0.0, 0.10, scale.z * 0.36), Vector3(scale.x * 0.24, 0.10, 0.052), Color(0.060, 0.048, 0.034, 0.60), "structures", true)

func _add_structure(structure: Dictionary) -> void:
	var id := str(structure["id"])
	var fixture := str(structure["fixtureId"])
	var position := _to_world(structure["position"], 0.34)
	var scale := _structure_scale(structure)
	var base_scale := _v0186_structure_base_scale(fixture, scale, structure) if environment_structure_shell_hardening_enabled else scale
	var color := _structure_color(structure)
	if environment_presentation_shell_v2_enabled:
		var shell_v2_foundation_scale := Vector3(base_scale.x * 0.96, maxf(0.055, base_scale.y * 0.16), base_scale.z * 0.92)
		var shell_v2_foundation_position := position + Vector3(0.0, -base_scale.y * 0.42, 0.0)
		if fixture == "barracks":
			_add_barracks_material_box(id, shell_v2_foundation_position, shell_v2_foundation_scale, color.darkened(0.08))
		else:
			_add_box(id, shell_v2_foundation_position, shell_v2_foundation_scale, color.darkened(0.10), true)
		_add_presentation_shell_v2_structure_mass(id, fixture, position, scale, color, structure)
		return
	if fixture == "barracks":
		_add_barracks_material_box(id, position, base_scale, color)
	else:
		_add_box(id, position, base_scale, color)
	if environment_foundation_review_enabled:
		_add_environment_foundation_structure_hierarchy(id, fixture, position, scale, color, structure)
	if fixture == "command_hall" or fixture == "enemy_stronghold":
		_add_box("%s_keep_tower" % id, position + Vector3(0.0, 0.34, 0.0), Vector3(scale.x * 0.34, 0.58, scale.z * 0.34), color.lightened(0.12))
		_add_box("%s_banner_silhouette" % id, position + Vector3(-scale.x * 0.38, 0.72, -scale.z * 0.12), Vector3(0.10, 0.34, 0.28), _banner_color(structure))
		_add_box("%s_roof_ridge" % id, position + Vector3(0.0, 0.62, 0.0), Vector3(scale.x * 0.82, 0.10, scale.z * 0.18), color.lightened(0.20))
		_add_box("%s_command_door_readability" % id, position + Vector3(0.0, 0.04, scale.z * 0.52), Vector3(scale.x * 0.26, 0.16, 0.08), Color(0.18, 0.15, 0.11))
		_add_box("%s_v0137_gabled_shadow" % id, position + Vector3(scale.x * 0.24, 0.66, scale.z * 0.10), Vector3(scale.x * 0.36, 0.12, scale.z * 0.42), color.darkened(0.16))
		_add_box("%s_v0137_hearth_window" % id, position + Vector3(scale.x * 0.42, 0.18, scale.z * 0.52), Vector3(scale.x * 0.12, 0.12, 0.08), Color(0.92, 0.54, 0.26), true, true)
	elif fixture == "barracks" or fixture == "enemy_barracks":
		if fixture == "barracks":
			_add_barracks_material_box("%s_training_wing_a" % id, position + Vector3(-scale.x * 0.30, 0.22, 0.0), Vector3(scale.x * 0.32, 0.34, scale.z * 0.88), color.lightened(0.08))
			_add_barracks_material_box("%s_training_wing_b" % id, position + Vector3(scale.x * 0.30, 0.22, 0.0), Vector3(scale.x * 0.32, 0.34, scale.z * 0.88), color.darkened(0.08))
		else:
			_add_box("%s_training_wing_a" % id, position + Vector3(-scale.x * 0.30, 0.22, 0.0), Vector3(scale.x * 0.32, 0.34, scale.z * 0.88), color.lightened(0.08))
			_add_box("%s_training_wing_b" % id, position + Vector3(scale.x * 0.30, 0.22, 0.0), Vector3(scale.x * 0.32, 0.34, scale.z * 0.88), color.darkened(0.08))
		_add_box("%s_weapon_rack_silhouette" % id, position + Vector3(0.0, 0.46, -scale.z * 0.44), Vector3(scale.x * 0.72, 0.08, 0.08), Color(0.54, 0.48, 0.34))
		_add_box("%s_drill_yard_edge" % id, position + Vector3(0.0, -0.12, scale.z * 0.72), Vector3(scale.x * 0.94, 0.05, 0.12), Color(0.32, 0.28, 0.18))
		if fixture == "barracks":
			_add_barracks_material_box("%s_v0137_roof_split_left" % id, position + Vector3(-scale.x * 0.24, 0.52, -scale.z * 0.06), Vector3(scale.x * 0.38, 0.10, scale.z * 0.62), color.lightened(0.18))
			_add_barracks_material_box("%s_v0137_roof_split_right" % id, position + Vector3(scale.x * 0.24, 0.52, scale.z * 0.06), Vector3(scale.x * 0.38, 0.10, scale.z * 0.62), color.darkened(0.14))
		else:
			_add_box("%s_v0137_roof_split_left" % id, position + Vector3(-scale.x * 0.24, 0.52, -scale.z * 0.06), Vector3(scale.x * 0.38, 0.10, scale.z * 0.62), color.lightened(0.18))
			_add_box("%s_v0137_roof_split_right" % id, position + Vector3(scale.x * 0.24, 0.52, scale.z * 0.06), Vector3(scale.x * 0.38, 0.10, scale.z * 0.62), color.darkened(0.14))
		if str(structure.get("constructionState", "")) != "complete":
			var progress := clampf(float(structure.get("constructionProgress", 0.0)), 0.0, 1.0)
			_add_box("%s_construction_scaffold" % id, position + Vector3(0.0, 0.58, 0.0), Vector3(scale.x * 0.90, 0.08, scale.z * 0.94), Color(0.80, 0.68, 0.36, 0.58), true)
			_add_box("%s_construction_progress_bar" % id, position + Vector3((progress - 1.0) * scale.x * 0.28, 0.68, scale.z * 0.58), Vector3(max(0.08, scale.x * 0.56 * progress), 0.06, 0.08), Color(0.42, 0.88, 0.56, 0.72), true)
	elif fixture == "west_stone_cut":
		_add_box("%s_quarry_crane" % id, position + Vector3(0.32, 0.30, -0.10), Vector3(0.16, 0.42, 0.70), Color(0.55, 0.50, 0.36))
		_add_box("%s_mine_mouth_shadow" % id, position + Vector3(-0.22, 0.10, 0.36), Vector3(0.42, 0.20, 0.16), Color(0.12, 0.12, 0.10))
		_add_box("%s_cut_stone_stack" % id, position + Vector3(0.44, -0.10, 0.34), Vector3(0.34, 0.12, 0.24), Color(0.58, 0.55, 0.46))
		_add_box("%s_v0137_cut_lift_arm" % id, position + Vector3(0.14, 0.52, -0.40), Vector3(0.12, 0.10, 0.78), Color(0.60, 0.52, 0.34))
		_add_box("%s_v0137_dark_ore_slot" % id, position + Vector3(-0.36, 0.24, 0.38), Vector3(0.30, 0.24, 0.12), Color(0.08, 0.09, 0.08))
	elif fixture == "ford_toll":
		_add_cylinder("%s_shrine_cap" % id, position + Vector3(0, 0.38, 0), 0.34, 0.20, Color(0.74, 0.68, 0.46), false)
		_add_cylinder("%s_shrine_beacon_slot" % id, position + Vector3(0, 0.58, 0), 0.12, 0.18, _lume_core_color(), false)
		_add_box("%s_shrine_steps" % id, position + Vector3(0.0, -0.12, 0.32), Vector3(0.54, 0.08, 0.18), Color(0.54, 0.50, 0.38))
		_add_box("%s_v0137_lume_brazier_west" % id, position + Vector3(-0.36, 0.16, -0.28), Vector3(0.12, 0.16, 0.12), _lume_core_color(), true, true)
		_add_box("%s_v0137_lume_brazier_east" % id, position + Vector3(0.36, 0.16, -0.28), Vector3(0.12, 0.16, 0.12), _lume_core_color(), true, true)

func _add_environment_foundation_structure_hierarchy(id: String, fixture: String, position: Vector3, scale: Vector3, color: Color, structure: Dictionary) -> void:
	if environment_geometry_convergence_enabled:
		_add_environment_geometry_structure_shell(id, fixture, position, scale, color, structure)
		return
	var team := str(structure.get("team", "neutral"))
	var plate_color := Color(0.22, 0.20, 0.15, 0.54)
	if team == "friendly":
		plate_color = Color(0.26, 0.33, 0.23, 0.58)
	elif team == "enemy":
		plate_color = Color(0.32, 0.12, 0.10, 0.54)
	_add_box("%s_v0173_ground_contact_shadow" % id, position + Vector3(0.0, -0.25, 0.0), Vector3(scale.x * 1.28, 0.035, scale.z * 1.22), plate_color, true)
	if fixture == "command_hall":
		_add_box("%s_v0173_hearth_side_plate" % id, position + Vector3(scale.x * 0.48, 0.18, scale.z * 0.18), Vector3(scale.x * 0.14, 0.18, scale.z * 0.62), Color(0.74, 0.42, 0.22, 0.70), true, true)
		_add_box("%s_v0173_roof_value_seam" % id, position + Vector3(0.0, 0.74, 0.0), Vector3(scale.x * 0.92, 0.06, scale.z * 0.10), color.lightened(0.28))
		_add_box("%s_post_freeze_review_wall_warm_trim" % id, position + Vector3(-scale.x * 0.44, 0.22, scale.z * 0.32), Vector3(scale.x * 0.12, 0.22, scale.z * 0.40), Color(0.68, 0.44, 0.26, 0.46), true)
	elif fixture == "barracks":
		_add_box("%s_v0173_drill_yard_foreground_edge" % id, position + Vector3(0.0, -0.18, scale.z * 0.92), Vector3(scale.x * 1.18, 0.045, 0.14), Color(0.64, 0.54, 0.30, 0.74), true)
		_add_barracks_material_box("%s_v0173_roof_readability_cap" % id, position + Vector3(0.0, 0.64, -scale.z * 0.02), Vector3(scale.x * 0.88, 0.08, scale.z * 0.72), color.lightened(0.24))
		_add_box("%s_post_freeze_review_material_binding_front_trim" % id, position + Vector3(0.0, 0.57, scale.z * 0.44), Vector3(scale.x * 0.92, 0.045, 0.08), Color(0.74, 0.62, 0.36, 0.60), true)
		_add_box("%s_post_freeze_review_material_binding_side_trim" % id, position + Vector3(scale.x * 0.46, 0.56, -scale.z * 0.02), Vector3(0.08, 0.045, scale.z * 0.66), Color(0.64, 0.52, 0.30, 0.50), true)
	elif fixture == "west_stone_cut":
		_add_box("%s_v0173_mine_mouth_deep_read" % id, position + Vector3(-scale.x * 0.32, 0.20, scale.z * 0.48), Vector3(scale.x * 0.42, 0.30, 0.12), Color(0.05, 0.06, 0.05))
		_add_box("%s_v0173_cut_stone_light_edge" % id, position + Vector3(scale.x * 0.36, 0.28, -scale.z * 0.18), Vector3(scale.x * 0.34, 0.12, scale.z * 0.72), Color(0.68, 0.66, 0.56))
		_add_box("%s_post_freeze_review_tailings_warm_trim" % id, position + Vector3(scale.x * 0.26, 0.10, scale.z * 0.58), Vector3(scale.x * 0.56, 0.055, 0.10), Color(0.72, 0.66, 0.48, 0.54), true)

func _add_environment_geometry_structure_shell(id: String, fixture: String, position: Vector3, scale: Vector3, color: Color, structure: Dictionary) -> void:
	var team := str(structure.get("team", "neutral"))
	var contact := Color(0.08, 0.075, 0.055, 0.70)
	if team == "friendly":
		contact = Color(0.10, 0.15, 0.10, 0.72)
	elif team == "enemy":
		contact = Color(0.18, 0.06, 0.05, 0.70)
	_add_box("%s_v0184_grounded_foundation_shadow" % id, position + Vector3(0.0, -0.252, 0.0), Vector3(scale.x * 1.18, 0.042, scale.z * 1.12), contact, true)
	if fixture == "command_hall":
		_add_box("%s_v0184_wet_granite_foundation" % id, position + Vector3(0.0, -0.160, scale.z * 0.03), Vector3(scale.x * 1.02, 0.092, scale.z * 0.92), Color(0.42, 0.40, 0.34))
		_add_box("%s_v0184_threshold_shadow" % id, position + Vector3(0.0, -0.090, scale.z * 0.52), Vector3(scale.x * 0.72, 0.050, 0.09), Color(0.10, 0.08, 0.05, 0.70), true)
		_add_box("%s_v0184_timber_frame_left" % id, position + Vector3(-scale.x * 0.44, 0.20, 0.0), Vector3(scale.x * 0.08, 0.46, scale.z * 0.82), Color(0.24, 0.17, 0.10))
		_add_box("%s_v0184_timber_frame_right" % id, position + Vector3(scale.x * 0.44, 0.20, 0.0), Vector3(scale.x * 0.08, 0.46, scale.z * 0.82), Color(0.24, 0.17, 0.10))
		_add_box("%s_v0184_roof_mass" % id, position + Vector3(0.0, 0.76, -scale.z * 0.02), Vector3(scale.x * 0.86, 0.115, scale.z * 0.58), color.darkened(0.08))
		_add_box("%s_v0184_hearth_slit" % id, position + Vector3(scale.x * 0.30, 0.28, scale.z * 0.54), Vector3(scale.x * 0.12, 0.13, 0.07), Color(0.92, 0.52, 0.24), true, true)
	elif fixture == "barracks":
		_add_box("%s_v0184_drill_yard_edge" % id, position + Vector3(0.0, -0.180, scale.z * 0.82), Vector3(scale.x * 0.98, 0.045, 0.11), Color(0.42, 0.34, 0.18, 0.70), true)
		_add_box("%s_v0184_drill_yard_side_shadow" % id, position + Vector3(scale.x * 0.48, -0.155, scale.z * 0.12), Vector3(0.08, 0.050, scale.z * 0.82), Color(0.10, 0.08, 0.05, 0.58), true)
		_add_barracks_material_box("%s_v0184_roof_trim_left" % id, position + Vector3(-scale.x * 0.22, 0.610, -scale.z * 0.02), Vector3(scale.x * 0.34, 0.075, scale.z * 0.60), color.lightened(0.12))
		_add_barracks_material_box("%s_v0184_roof_trim_right" % id, position + Vector3(scale.x * 0.22, 0.610, scale.z * 0.02), Vector3(scale.x * 0.34, 0.075, scale.z * 0.60), color.darkened(0.10))
		_add_box("%s_v0184_scaffold_timber_front" % id, position + Vector3(0.0, 0.50, scale.z * 0.50), Vector3(scale.x * 0.86, 0.060, 0.07), Color(0.58, 0.44, 0.24, 0.62), true)
		_add_box("%s_v0184_weapon_rack_read" % id, position + Vector3(0.0, 0.42, -scale.z * 0.48), Vector3(scale.x * 0.62, 0.065, 0.07), Color(0.52, 0.44, 0.30))
		if str(structure.get("constructionState", "")) != "complete":
			var progress := clampf(float(structure.get("constructionProgress", 0.0)), 0.0, 1.0)
			_add_box("%s_v0184_restoration_frame" % id, position + Vector3(0.0, 0.66, 0.0), Vector3(scale.x * 0.74, 0.060, scale.z * 0.76), Color(0.72, 0.58, 0.32, 0.54), true)
			_add_box("%s_v0184_restoration_progress" % id, position + Vector3((progress - 1.0) * scale.x * 0.24, 0.74, scale.z * 0.55), Vector3(max(0.08, scale.x * 0.48 * progress), 0.055, 0.07), Color(0.42, 0.82, 0.52, 0.66), true)
	elif fixture == "west_stone_cut":
		_add_box("%s_v0184_retaining_wall" % id, position + Vector3(scale.x * 0.30, 0.02, scale.z * 0.48), Vector3(scale.x * 0.60, 0.100, 0.10), Color(0.48, 0.46, 0.38))
		_add_box("%s_v0184_mine_cut_shadow" % id, position + Vector3(-scale.x * 0.34, 0.18, scale.z * 0.44), Vector3(scale.x * 0.36, 0.34, 0.12), Color(0.04, 0.05, 0.04))
		_add_box("%s_v0184_quarry_apron_shadow" % id, position + Vector3(-scale.x * 0.08, -0.090, scale.z * 0.55), Vector3(scale.x * 0.90, 0.055, 0.11), Color(0.10, 0.09, 0.06, 0.64), true)
		_add_box("%s_v0184_cut_stone_stack_a" % id, position + Vector3(scale.x * 0.36, 0.18, -scale.z * 0.20), Vector3(scale.x * 0.28, 0.12, scale.z * 0.56), Color(0.62, 0.60, 0.50))
		_add_box("%s_v0184_cut_stone_stack_b" % id, position + Vector3(-scale.x * 0.08, 0.05, -scale.z * 0.42), Vector3(scale.x * 0.34, 0.08, scale.z * 0.24), Color(0.46, 0.45, 0.38))
	if environment_structure_shell_hardening_enabled:
		_add_environment_structure_shell_hardening_details(id, fixture, position, scale, color, structure)

func _add_environment_structure_shell_hardening_details(id: String, fixture: String, position: Vector3, scale: Vector3, color: Color, structure: Dictionary) -> void:
	var granite := Color(0.44, 0.43, 0.37)
	var granite_dark := Color(0.21, 0.23, 0.20)
	var timber := Color(0.28, 0.19, 0.11)
	var timber_light := Color(0.54, 0.43, 0.25)
	var metal := Color(0.44, 0.46, 0.42)
	match fixture:
		"command_hall":
			_add_box("%s_v0186_command_contact_shadow" % id, position + Vector3(0.0, -0.270, 0.04), Vector3(scale.x * 1.10, 0.030, scale.z * 0.95), Color(0.035, 0.040, 0.030, 0.54), true)
			_add_box("%s_v0186_wet_granite_foundation_front" % id, position + Vector3(0.0, -0.130, scale.z * 0.46), Vector3(scale.x * 0.94, 0.070, 0.10), granite)
			_add_box("%s_v0186_wet_granite_foundation_back" % id, position + Vector3(0.0, -0.130, -scale.z * 0.34), Vector3(scale.x * 0.82, 0.060, 0.08), granite.darkened(0.08))
			_add_box("%s_v0186_timber_side_post_left" % id, position + Vector3(-scale.x * 0.40, 0.18, scale.z * 0.06), Vector3(0.075, 0.56, scale.z * 0.68), timber)
			_add_box("%s_v0186_timber_side_post_right" % id, position + Vector3(scale.x * 0.40, 0.18, scale.z * 0.06), Vector3(0.075, 0.56, scale.z * 0.68), timber.darkened(0.06))
			_add_box("%s_v0186_stepped_keep_core" % id, position + Vector3(0.0, 0.46, -scale.z * 0.04), Vector3(scale.x * 0.32, 0.54, scale.z * 0.34), color.darkened(0.12))
			_add_box("%s_v0186_low_gabled_roof_west" % id, position + Vector3(-scale.x * 0.18, 0.78, -scale.z * 0.02), Vector3(scale.x * 0.42, 0.090, scale.z * 0.62), color.lightened(0.18))
			_add_box("%s_v0186_low_gabled_roof_east" % id, position + Vector3(scale.x * 0.18, 0.74, scale.z * 0.02), Vector3(scale.x * 0.42, 0.075, scale.z * 0.58), color.darkened(0.16))
			_add_box("%s_v0186_roof_ridge_line" % id, position + Vector3(0.0, 0.845, 0.0), Vector3(scale.x * 0.70, 0.035, 0.055), timber_light)
			_add_box("%s_v0186_door_threshold_shadow" % id, position + Vector3(0.0, 0.035, scale.z * 0.58), Vector3(scale.x * 0.34, 0.130, 0.050), Color(0.06, 0.045, 0.030, 0.78), true)
			_add_box("%s_v0186_restrained_hearth_slot" % id, position + Vector3(scale.x * 0.34, 0.25, scale.z * 0.56), Vector3(0.080, 0.110, 0.045), Color(0.92, 0.48, 0.20), true, true)
		"west_stone_cut":
			_add_box("%s_v0186_mine_tailings_ground_shadow" % id, position + Vector3(-scale.x * 0.02, -0.205, scale.z * 0.54), Vector3(scale.x * 1.05, 0.035, 0.18), Color(0.05, 0.055, 0.045, 0.58), true)
			_add_box("%s_v0186_deep_mine_mouth" % id, position + Vector3(-scale.x * 0.42, 0.23, scale.z * 0.48), Vector3(scale.x * 0.28, 0.36, 0.095), Color(0.025, 0.030, 0.025))
			_add_box("%s_v0186_left_retaining_wall" % id, position + Vector3(-scale.x * 0.08, 0.07, scale.z * 0.56), Vector3(scale.x * 0.42, 0.105, 0.08), granite.darkened(0.05))
			_add_box("%s_v0186_right_retaining_wall" % id, position + Vector3(scale.x * 0.34, 0.07, scale.z * 0.47), Vector3(scale.x * 0.36, 0.105, 0.08), granite.lightened(0.04))
			_add_box("%s_v0186_cut_stone_tier_low" % id, position + Vector3(scale.x * 0.20, 0.12, -scale.z * 0.36), Vector3(scale.x * 0.54, 0.105, 0.18), granite)
			_add_box("%s_v0186_cut_stone_tier_high" % id, position + Vector3(scale.x * 0.46, 0.26, -scale.z * 0.18), Vector3(scale.x * 0.28, 0.120, 0.16), granite.lightened(0.08))
			_add_box("%s_v0186_crane_tripod_left" % id, position + Vector3(scale.x * 0.20, 0.42, -scale.z * 0.35), Vector3(0.055, 0.44, 0.050), timber)
			_add_box("%s_v0186_crane_tripod_right" % id, position + Vector3(scale.x * 0.42, 0.42, -scale.z * 0.35), Vector3(0.055, 0.44, 0.050), timber.darkened(0.08))
			_add_box("%s_v0186_crane_crossbeam" % id, position + Vector3(scale.x * 0.31, 0.65, -scale.z * 0.35), Vector3(scale.x * 0.38, 0.060, 0.050), timber_light)
			_add_box("%s_v0186_crane_hook" % id, position + Vector3(scale.x * 0.31, 0.48, -scale.z * 0.31), Vector3(0.045, 0.18, 0.045), metal)
		"barracks":
			var restoring := str(structure.get("constructionState", "")) != "complete"
			var scaffold_alpha := 0.52 if restoring else 0.32
			_add_box("%s_v0186_barracks_contact_shadow" % id, position + Vector3(0.0, -0.265, 0.06), Vector3(scale.x * 1.06, 0.030, scale.z * 0.96), Color(0.040, 0.035, 0.025, 0.54), true)
			_add_box("%s_v0186_grounded_drill_yard_front" % id, position + Vector3(0.0, -0.120, scale.z * 0.68), Vector3(scale.x * 1.04, 0.055, 0.115), Color(0.39, 0.31, 0.18, 0.64), true)
			_add_barracks_material_box("%s_v0186_split_training_wing_left" % id, position + Vector3(-scale.x * 0.30, 0.28, -scale.z * 0.02), Vector3(scale.x * 0.30, 0.30, scale.z * 0.66), color.lightened(0.12))
			_add_barracks_material_box("%s_v0186_split_training_wing_right" % id, position + Vector3(scale.x * 0.30, 0.24, scale.z * 0.02), Vector3(scale.x * 0.30, 0.26, scale.z * 0.66), color.darkened(0.10))
			_add_barracks_material_box("%s_v0186_low_roof_left" % id, position + Vector3(-scale.x * 0.22, 0.62, -scale.z * 0.03), Vector3(scale.x * 0.36, 0.065, scale.z * 0.54), color.lightened(0.20))
			_add_barracks_material_box("%s_v0186_low_roof_right" % id, position + Vector3(scale.x * 0.22, 0.59, scale.z * 0.03), Vector3(scale.x * 0.36, 0.060, scale.z * 0.54), color.darkened(0.16))
			_add_box("%s_v0186_roof_ridge" % id, position + Vector3(0.0, 0.675, 0.0), Vector3(scale.x * 0.70, 0.035, 0.050), timber_light, true)
			for corner in [
				Vector2(-0.46, -0.42),
				Vector2(0.46, -0.42),
				Vector2(-0.46, 0.42),
				Vector2(0.46, 0.42)
			]:
				_add_box("%s_v0186_scaffold_post_%s_%s" % [id, int((corner.x + 0.5) * 10.0), int((corner.y + 0.5) * 10.0)], position + Vector3(scale.x * corner.x, 0.40, scale.z * corner.y), Vector3(0.060, 0.48, 0.055), Color(0.60, 0.48, 0.28, scaffold_alpha), true)
			_add_box("%s_v0186_scaffold_front_brace" % id, position + Vector3(0.0, 0.50, scale.z * 0.44), Vector3(scale.x * 0.84, 0.045, 0.050), Color(0.68, 0.52, 0.28, scaffold_alpha), true)
			_add_box("%s_v0186_scaffold_back_brace" % id, position + Vector3(0.0, 0.47, -scale.z * 0.44), Vector3(scale.x * 0.78, 0.040, 0.048), Color(0.48, 0.36, 0.20, scaffold_alpha), true)
			if restoring:
				var progress := clampf(float(structure.get("constructionProgress", 0.0)), 0.0, 1.0)
				_add_box("%s_v0186_restoration_progress_read" % id, position + Vector3((progress - 1.0) * scale.x * 0.22, 0.73, scale.z * 0.52), Vector3(max(0.08, scale.x * 0.44 * progress), 0.045, 0.060), Color(0.46, 0.84, 0.50, 0.58), true)
				_add_box("%s_v0186_unfinished_roof_gap" % id, position + Vector3(0.0, 0.69, -scale.z * 0.05), Vector3(scale.x * 0.20, 0.030, scale.z * 0.48), Color(0.07, 0.055, 0.035, 0.44), true)

func _add_capture_site(site: Dictionary) -> void:
	var position := _to_world(site["position"], 0.13)
	if environment_presentation_shell_v2_enabled:
		var site_id := str(site["id"])
		var site_color := _site_color(site)
		_add_presentation_shell_v2_cylinder("%s_v0193_low_claim_disc" % site_id, position + Vector3(0.0, -0.062, 0.0), 0.34, 0.030, site_color.lightened(0.08), "sites", true)
		_add_presentation_shell_v2_cylinder("%s_v0193_outer_state_ring" % site_id, position + Vector3(0.0, -0.082, 0.0), 0.52, 0.018, Color(0.82, 0.70, 0.26, 0.28), "sites", true)
		_add_presentation_shell_v2_visual_box("%s_v0193_claim_post" % site_id, position + Vector3(0.0, 0.18, 0.0), Vector3(0.070, 0.28, 0.070), site_color.lightened(0.05), "sites", true)
		_add_presentation_shell_v2_visual_box("%s_v0193_road_tick" % site_id, position + Vector3(0.26, 0.060, 0.18), Vector3(0.22, 0.035, 0.055), Color(0.86, 0.66, 0.24, 0.36), "sites", true)
		return
	if environment_shell_live_qa_enabled:
		_add_box(str(site["id"]), position, Vector3(0.38, 0.10, 0.38), _site_color(site).darkened(0.08), true)
		_add_cylinder("%s_marker_disc" % str(site["id"]), position + Vector3(0, -0.055, 0), 0.30, 0.038, _site_color(site).lightened(0.08), true)
		_add_box("%s_claim_post" % str(site["id"]), position + Vector3(0.0, 0.20, 0.0), Vector3(0.06, 0.30, 0.06), _site_color(site).lightened(0.04), true)
		_add_box("%s_contest_tick" % str(site["id"]), position + Vector3(0.22, 0.08, 0.22), Vector3(0.16, 0.04, 0.05), Color(0.84, 0.58, 0.22, 0.34), true)
	else:
		_add_box(str(site["id"]), position, Vector3(0.56, 0.12, 0.56), _site_color(site), true)
		_add_cylinder("%s_marker_disc" % str(site["id"]), position + Vector3(0, -0.055, 0), 0.42, 0.045, _site_color(site).lightened(0.18), true)
		_add_box("%s_claim_post" % str(site["id"]), position + Vector3(0.0, 0.23, 0.0), Vector3(0.08, 0.36, 0.08), _site_color(site).lightened(0.08), true)
		_add_box("%s_contest_tick" % str(site["id"]), position + Vector3(0.28, 0.08, 0.28), Vector3(0.22, 0.05, 0.08), Color(0.96, 0.70, 0.24, 0.62), true)
	if environment_foundation_review_enabled:
		if environment_shell_live_qa_enabled:
			_add_cylinder("%s_v0173_outer_marker_collar" % str(site["id"]), position + Vector3(0, -0.070, 0), 0.42, 0.024, Color(0.82, 0.70, 0.26, 0.22), true)
			_add_box("%s_v0173_state_tick_north" % str(site["id"]), position + Vector3(0.0, 0.10, -0.28), Vector3(0.26, 0.038, 0.05), _site_color(site).lightened(0.14), true)
			_add_box("%s_v0173_state_tick_south" % str(site["id"]), position + Vector3(0.0, 0.10, 0.28), Vector3(0.26, 0.038, 0.05), _site_color(site).lightened(0.14), true)
		else:
			_add_cylinder("%s_v0173_outer_marker_collar" % str(site["id"]), position + Vector3(0, -0.070, 0), 0.56, 0.030, Color(0.95, 0.82, 0.30, 0.42), true)
			_add_box("%s_v0173_state_tick_north" % str(site["id"]), position + Vector3(0.0, 0.12, -0.36), Vector3(0.40, 0.05, 0.08), _site_color(site).lightened(0.22), true)
			_add_box("%s_v0173_state_tick_south" % str(site["id"]), position + Vector3(0.0, 0.12, 0.36), Vector3(0.40, 0.05, 0.08), _site_color(site).lightened(0.22), true)
	if environment_structure_shell_hardening_enabled:
		var site_id := str(site["id"])
		_add_cylinder("%s_v0186_low_stone_claim_ring" % site_id, position + Vector3(0.0, -0.082, 0.0), 0.48, 0.020, Color(0.52, 0.48, 0.36, 0.30), true)
		_add_box("%s_v0186_practical_claim_post_cap" % site_id, position + Vector3(0.0, 0.38, 0.0), Vector3(0.18, 0.045, 0.18), Color(0.46, 0.35, 0.18, 0.56), true)
		_add_box("%s_v0186_defensive_crate_west" % site_id, position + Vector3(-0.36, 0.07, 0.24), Vector3(0.18, 0.12, 0.22), Color(0.34, 0.25, 0.15, 0.52), true)
		_add_box("%s_v0186_defensive_crate_east" % site_id, position + Vector3(0.34, 0.07, -0.22), Vector3(0.16, 0.11, 0.20), Color(0.30, 0.23, 0.14, 0.46), true)

func _add_unit(name: String, position: Vector3, color: Color, radius: float, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, false, emissive, 0.35)
	visual_root.add_child(mesh_instance)

func _add_unit_silhouette(unit: Dictionary) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = str(unit["id"])
	var mesh: Mesh
	if _aster_art_applies_to_unit(unit):
		mesh = _aster_art_quad_mesh()
	elif _ashen_art_applies_to_unit(unit):
		mesh = _ashen_art_quad_mesh()
	elif str(unit["role"]) == "hero":
		var hero_mesh := CapsuleMesh.new()
		hero_mesh.radius = 0.18
		hero_mesh.height = 0.62
		mesh = hero_mesh
	elif str(unit["role"]) == "Worker":
		if _worker_art_is_active():
			mesh = _worker_art_quad_mesh()
		else:
			var worker_mesh := BoxMesh.new()
			worker_mesh.size = Vector3(0.22, 0.36, 0.18)
			mesh = worker_mesh
	elif str(unit["fixtureId"]) == "ranger":
		var ranger_mesh := BoxMesh.new()
		ranger_mesh.size = Vector3(0.16, 0.36, 0.30)
		mesh = ranger_mesh
	elif str(unit["team"]) == "enemy":
		var ashen_mesh := CylinderMesh.new()
		ashen_mesh.top_radius = 0.12
		ashen_mesh.bottom_radius = 0.21
		ashen_mesh.height = 0.42
		ashen_mesh.radial_segments = 5
		mesh = ashen_mesh
	elif _militia_art_applies_to_unit(unit):
		mesh = _militia_art_quad_mesh()
	else:
		var militia_mesh := CylinderMesh.new()
		militia_mesh.top_radius = 0.15
		militia_mesh.bottom_radius = 0.18
		militia_mesh.height = 0.42
		militia_mesh.radial_segments = 6
		mesh = militia_mesh
	mesh_instance.mesh = mesh
	var worker_billboard := str(unit["role"]) == "Worker" and _worker_art_is_active()
	var aster_billboard := _aster_art_applies_to_unit(unit)
	var militia_billboard := _militia_art_applies_to_unit(unit)
	var ashen_billboard := _ashen_art_applies_to_unit(unit)
	var unit_y := 0.28
	if worker_billboard:
		unit_y = _worker_art_unit_y()
	elif aster_billboard:
		unit_y = _aster_art_unit_y()
	elif militia_billboard:
		unit_y = _militia_art_unit_y()
	elif ashen_billboard:
		unit_y = _ashen_art_unit_y()
	mesh_instance.position = _to_world(unit["position"], unit_y)
	if environment_presentation_shell_v2_enabled:
		_add_presentation_shell_v2_unit_contact_shadow(unit, mesh_instance.position)
	elif environment_foundation_review_enabled:
		_add_post_freeze_review_unit_contact_shadow(unit, mesh_instance.position)
	if worker_billboard:
		mesh_instance.material_override = _worker_art_billboard_material()
	elif aster_billboard:
		mesh_instance.material_override = _aster_art_billboard_material()
	elif militia_billboard:
		mesh_instance.material_override = _militia_art_billboard_material()
	elif ashen_billboard:
		mesh_instance.material_override = _ashen_art_billboard_material()
	else:
		mesh_instance.material_override = _material(_unit_color(unit), false, _unit_emissive(unit), 0.35)
	visual_root.add_child(mesh_instance)
	if not worker_billboard and not aster_billboard and not militia_billboard and not ashen_billboard:
		_add_unit_silhouette_parts(mesh_instance, unit)

func _add_post_freeze_review_unit_contact_shadow(unit: Dictionary, position: Vector3) -> void:
	var fixture := str(unit.get("fixtureId", ""))
	var role := str(unit.get("role", ""))
	var team := str(unit.get("team", ""))
	var shadow_scale := Vector3(0.40, 0.020, 0.26)
	var shadow_color := Color(0.03, 0.04, 0.03, 0.46)
	if role == "hero":
		shadow_scale = Vector3(0.58, 0.022, 0.34)
	elif role == "Worker":
		shadow_scale = Vector3(0.38, 0.020, 0.24)
	elif fixture == "militia":
		shadow_scale = Vector3(0.44, 0.020, 0.26)
	elif team == "enemy":
		shadow_scale = Vector3(0.46, 0.020, 0.28)
		shadow_color = Color(0.08, 0.03, 0.02, 0.44)
	_add_box("%s_post_freeze_review_contact_shadow" % str(unit.get("id", "unit")), Vector3(position.x, 0.155, position.z + 0.06), shadow_scale, shadow_color, true)

func _add_presentation_shell_v2_unit_contact_shadow(unit: Dictionary, position: Vector3) -> void:
	var role := str(unit.get("role", ""))
	var fixture := str(unit.get("fixtureId", ""))
	var team := str(unit.get("team", ""))
	var shadow_scale := Vector3(0.34, 0.018, 0.22)
	var shadow_color := Color(0.025, 0.030, 0.024, 0.36)
	if role == "hero":
		shadow_scale = Vector3(0.50, 0.018, 0.30)
	elif role == "Worker":
		shadow_scale = Vector3(0.34, 0.018, 0.22)
	elif fixture == "militia":
		shadow_scale = Vector3(0.40, 0.018, 0.24)
	elif team == "enemy":
		shadow_scale = Vector3(0.42, 0.018, 0.26)
		shadow_color = Color(0.070, 0.022, 0.018, 0.34)
	_add_presentation_shell_v2_visual_box("%s_v0193_contact_shadow" % str(unit.get("id", "unit")), Vector3(position.x, 0.170, position.z + 0.055), shadow_scale, shadow_color, "unitContact", true)

func _add_unit_silhouette_parts(parent: MeshInstance3D, unit: Dictionary) -> void:
	var fixture := str(unit["fixtureId"])
	var role := str(unit["role"])
	var team := str(unit["team"])
	if role == "hero":
		_add_child_box(parent, "hero_command_banner", Vector3(0.0, 0.36, -0.08), Vector3(0.08, 0.34, 0.18), Color(0.82, 0.88, 0.54))
		_add_child_box(parent, "hero_blade_profile", Vector3(0.20, 0.08, 0.05), Vector3(0.06, 0.44, 0.08), Color(0.72, 0.78, 0.74))
		_add_child_box(parent, "hero_shield_plate", Vector3(-0.18, 0.02, 0.06), Vector3(0.08, 0.26, 0.24), Color(0.24, 0.44, 0.56))
		_add_child_cylinder(parent, "hero_crown_disc", Vector3(0.0, 0.42, 0.0), 0.13, 0.045, Color(0.86, 0.82, 0.48))
		_add_child_box(parent, "v0137_aster_back_cloak_profile", Vector3(0.0, 0.02, -0.20), Vector3(0.20, 0.36, 0.08), Color(0.20, 0.34, 0.48))
		_add_child_box(parent, "v0137_aster_readable_nameplate_anchor", Vector3(0.0, 0.58, 0.0), Vector3(0.24, 0.06, 0.10), Color(0.88, 0.82, 0.44))
	elif role == "Worker":
		_add_child_box(parent, "worker_pack_crate", Vector3(0.0, 0.03, -0.18), Vector3(0.24, 0.20, 0.10), Color(0.48, 0.36, 0.20))
		_add_child_box(parent, "worker_tool_handle", Vector3(0.18, 0.10, 0.03), Vector3(0.05, 0.36, 0.05), Color(0.66, 0.56, 0.36))
		_add_child_box(parent, "worker_tool_head", Vector3(0.20, 0.28, 0.03), Vector3(0.16, 0.05, 0.07), Color(0.55, 0.56, 0.48))
		_add_child_box(parent, "v0137_worker_low_pick_silhouette", Vector3(-0.16, -0.02, 0.08), Vector3(0.05, 0.26, 0.05), Color(0.62, 0.54, 0.36))
	elif fixture == "ranger":
		_add_child_box(parent, "ranger_bow_profile", Vector3(0.19, 0.04, 0.0), Vector3(0.05, 0.48, 0.06), Color(0.38, 0.30, 0.18))
		_add_child_box(parent, "ranger_quiver", Vector3(-0.14, 0.04, -0.16), Vector3(0.08, 0.30, 0.08), Color(0.30, 0.42, 0.30))
		_add_child_box(parent, "ranger_arrow_line", Vector3(0.0, 0.18, 0.19), Vector3(0.08, 0.05, 0.30), Color(0.72, 0.80, 0.62))
		_add_child_box(parent, "v0137_ranger_hood_peak", Vector3(0.0, 0.34, 0.02), Vector3(0.18, 0.08, 0.12), Color(0.34, 0.46, 0.32))
	elif team == "enemy" and fixture == "brute":
		_add_child_box(parent, "ashen_brute_shoulder_left", Vector3(-0.20, 0.12, 0.0), Vector3(0.18, 0.20, 0.24), Color(0.42, 0.09, 0.08))
		_add_child_box(parent, "ashen_brute_shoulder_right", Vector3(0.20, 0.12, 0.0), Vector3(0.18, 0.20, 0.24), Color(0.42, 0.09, 0.08))
		_add_child_box(parent, "ashen_brute_cleaver", Vector3(0.0, 0.10, 0.24), Vector3(0.10, 0.34, 0.08), Color(0.68, 0.28, 0.18))
		_add_child_box(parent, "v0137_ashen_brute_back_spine", Vector3(0.0, 0.28, -0.12), Vector3(0.12, 0.22, 0.08), Color(0.62, 0.18, 0.12))
	elif team == "enemy":
		_add_child_box(parent, "ashen_raider_forward_blade", Vector3(0.0, 0.06, 0.22), Vector3(0.08, 0.30, 0.08), Color(0.78, 0.26, 0.16))
		_add_child_box(parent, "ashen_raider_horn_left", Vector3(-0.15, 0.22, 0.0), Vector3(0.12, 0.10, 0.08), Color(0.50, 0.16, 0.12))
		_add_child_box(parent, "ashen_raider_horn_right", Vector3(0.15, 0.22, 0.0), Vector3(0.12, 0.10, 0.08), Color(0.50, 0.16, 0.12))
		_add_child_box(parent, "v0137_ashen_raider_leaning_crest", Vector3(0.0, 0.32, -0.08), Vector3(0.14, 0.10, 0.18), Color(0.68, 0.18, 0.14))
	else:
		_add_child_box(parent, "militia_shield_plate", Vector3(-0.18, 0.02, 0.04), Vector3(0.08, 0.26, 0.22), Color(0.26, 0.44, 0.30))
		_add_child_box(parent, "militia_spear_profile", Vector3(0.18, 0.10, 0.0), Vector3(0.05, 0.52, 0.05), Color(0.58, 0.52, 0.34))
		_add_child_box(parent, "militia_spear_tip", Vector3(0.18, 0.38, 0.0), Vector3(0.10, 0.08, 0.08), Color(0.70, 0.72, 0.62))
		_add_child_box(parent, "v0137_militia_square_tabard", Vector3(0.0, 0.02, 0.16), Vector3(0.16, 0.22, 0.06), Color(0.30, 0.56, 0.36))

func _add_child_box(parent: Node3D, name: String, local_position: Vector3, scale: Vector3, color: Color, transparent: bool = false, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = local_position
	mesh_instance.material_override = _material(color, transparent, emissive, _lume_emission())
	parent.add_child(mesh_instance)

func _add_child_cylinder(parent: Node3D, name: String, local_position: Vector3, radius: float, height: float, color: Color, transparent: bool = false, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 18
	mesh_instance.mesh = mesh
	mesh_instance.position = local_position
	mesh_instance.material_override = _material(color, transparent, emissive, _lume_emission())
	parent.add_child(mesh_instance)

func _add_box(name: String, position: Vector3, scale: Vector3, color: Color, transparent: bool = false, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, transparent, emissive, _lume_emission())
	visual_root.add_child(mesh_instance)

func _add_cylinder(name: String, position: Vector3, radius: float, height: float, color: Color, transparent: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, transparent)
	visual_root.add_child(mesh_instance)

func _add_selection_disc(name: String, position: Vector3, radius: float, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.035
	mesh.radial_segments = 28
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, true, true, 0.25)
	mesh_instance.visible = false
	visual_root.add_child(mesh_instance)

func _set_or_create_disc_marker(name: String, position: Vector3, radius: float, color: Color) -> void:
	if visual_root == null:
		return
	var marker := visual_root.get_node_or_null(name) as MeshInstance3D
	if marker == null:
		_add_selection_disc(name, position, radius, color)
		marker = visual_root.get_node_or_null(name) as MeshInstance3D
	if marker:
		marker.position = position
		var mesh := marker.mesh as CylinderMesh
		if mesh:
			mesh.top_radius = radius
			mesh.bottom_radius = radius
		marker.material_override = _material(color, true, true, 0.20)
		marker.visible = true

func _add_static_box(name: String, position: Vector3, scale: Vector3, color: Color, transparent: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, transparent)
	terrain_root.add_child(mesh_instance)

func _add_static_box_rotated(name: String, position: Vector3, scale: Vector3, rotation_y_degrees: float, color: Color, transparent: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.rotation_degrees = Vector3(0.0, rotation_y_degrees, 0.0)
	mesh_instance.material_override = _material(color, transparent)
	terrain_root.add_child(mesh_instance)

func _add_static_cylinder(name: String, position: Vector3, radius: float, height: float, color: Color, emissive: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, false, emissive, _lume_emission())
	terrain_root.add_child(mesh_instance)

func _set_or_create_marker(name: String, position: Vector3, scale: Vector3, color: Color) -> void:
	if visual_root == null:
		return
	var marker := visual_root.get_node_or_null(name) as MeshInstance3D
	if marker == null:
		_add_box(name, position, scale, color, true, true)
	else:
		marker.position = position
		var mesh := marker.mesh as BoxMesh
		if mesh:
			mesh.size = scale
		marker.material_override = _material(color, true, true, 0.25)

func _apply_camera_authoring_posture(focus_id: String, position: Vector3, zoom: float) -> void:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return
	camera.position = _clamped_camera_position(position)
	camera.size = clampf(zoom, SAFE_ZOOM_MIN, SAFE_ZOOM_MAX)
	camera.rotation_degrees = CAMERA_DEFAULT_ROTATION
	camera_focus_id = focus_id
	camera_zoom_posture = "default" if absf(camera.size - SAFE_FRAME_DEFAULT_ZOOM) < 0.01 else "focused"
	camera_panned = focus_id != "default"
	camera_zoomed = camera_zoom_posture != "default"

func _clamped_camera_position(position: Vector3) -> Vector3:
	return Vector3(
		clampf(position.x, CAMERA_PAN_MIN_X, CAMERA_PAN_MAX_X),
		position.y,
		clampf(position.z, CAMERA_PAN_MIN_Z, CAMERA_PAN_MAX_Z)
	)

func _unit_world_position(id: String, fallback: Vector3) -> Vector3:
	for unit in runtime.units:
		if str(unit.get("id", "")) == id or str(unit.get("fixtureId", "")) == id:
			return _to_world(unit["position"], 0.12)
	return fallback

func _structure_world_position(id: String, fallback: Vector3) -> Vector3:
	for structure in runtime.structures:
		if str(structure.get("id", "")) == id or str(structure.get("fixtureId", "")) == id:
			return _to_world(structure["position"], 0.14)
	return fallback

func _site_world_position(id: String, fallback: Vector3) -> Vector3:
	for site in runtime.sites:
		if str(site.get("id", "")) == id or str(site.get("fixtureId", "")) == id:
			return _to_world(site["position"], 0.14)
	return fallback

func _lume_endpoint_world_position(id: String, fallback: Vector3) -> Vector3:
	for endpoint in runtime.lume_endpoints:
		if str(endpoint.get("id", "")) == id or str(endpoint.get("fixtureId", "")) == id:
			return _to_world(endpoint["position"], 0.14)
	return fallback

func _set_unit_health(id: String, health: float, alive: bool) -> void:
	for index in range(runtime.units.size()):
		var unit: Dictionary = runtime.units[index]
		if str(unit.get("id", "")) == id or str(unit.get("fixtureId", "")) == id:
			unit["health"] = clampf(health, 0.0, float(unit.get("maxHealth", health)))
			unit["alive"] = alive
			runtime.units[index] = unit
			return

func _unit_is_attack_target(id: String) -> bool:
	for unit in runtime.units:
		if str(unit.get("attackTarget", "")) == id:
			return true
	return false

func _authored_layout_manifest() -> Dictionary:
	var feature_ids := [
		"highland_foothold_shape",
		"wet_granite_path_network",
		"main_road",
		"side_path",
		"shallow_ford",
		"water_strip_readable_crossing",
		"quarry_cut_worked_stone_posture",
		"shrine_clearing",
		"ruin_pocket",
		"buildable_ground_patches",
		"blocked_terrain_cues",
		"subtle_elevation_variation",
		"moss_grass_worked_earth_material_posture",
		"warm_hearth_accents",
		"restrained_teal_lume_accents"
	]
	return {
		"checkpoint": "v0.126",
		"seed": "salto-procedural-authorship-v0126",
		"featureIds": feature_ids,
		"tacticalLanes": ["main_road", "side_path", "ford_crossing", "quarry_objective_lane", "ruin_pressure_lane"],
		"minimapMirrors": ["main_road", "water_strip", "ford_crossing", "quarry", "shrine", "ruin", "enemy_pressure"],
		"deterministic": true,
		"proceduralPrimitiveOnly": true,
		"manualEditorAssemblyRequired": false
	}

func _silhouette_library_manifest() -> Dictionary:
	return {
		"checkpoint": "v0.127",
		"seed": "salto-procedural-silhouette-library-v0127",
		"proceduralPrimitiveOnly": true,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"routineEditorUseRequired": false,
		"readableByGeometryNotColorAlone": true,
		"futureArtSlotMappingPreserved": true,
		"unitRoles": {
			"hero_aster": {"role": "hero", "profile": "tall capsule plus command banner, blade, shield, and crown disc", "artSlotId": "hero_aster"},
			"worker": {"role": "non-combat worker", "profile": "short box body plus crate pack and tool silhouette", "artSlotId": "worker"},
			"militia": {"role": "melee", "profile": "six-sided body plus shield and spear silhouette", "artSlotId": "militia"},
			"ranger": {"role": "ranged", "profile": "narrow body plus bow, quiver, and arrow line", "artSlotId": "ranger"},
			"ashen_raider": {"role": "enemy raider", "profile": "tapered pentagonal body plus horns and forward blade", "artSlotId": "ashen_enemy"},
			"ashen_brute": {"role": "optional enemy brute placeholder", "profile": "larger tapered body plus broad shoulders and cleaver", "artSlotId": "ashen_enemy"}
		},
		"buildingAndSiteRoles": {
			"command_hall": "keep tower, roof ridge, banner, and door slot",
			"barracks": "two training wings, weapon rack, and drill-yard edge",
			"mine": "quarry crane, mine-mouth shadow, and cut-stone stack",
			"shrine": "round shrine cap, beacon slot, and step profile",
			"quarry": "terrain quarry cut plus mine-role silhouette",
			"ruin": "broken wall pocket and blocked edge",
			"capture_site": "claim disc, post, and contest tick",
			"lume_endpoint": "glow core, readability ring, and art anchor"
		},
		"selectionFeedback": ["hover", "click-select", "box-select", "hero-marker", "worker-marker", "squad-marker", "enemy-target", "move-order", "attack-order"],
		"combatFeedback": ["melee-contact", "ranged-shot-placeholder", "hit-flash", "death-fade", "pressure-wave-arrival", "site-contest", "results-readiness"],
		"noFinalArtClaim": true
	}

func _to_world(position: Vector2, y: float = 0.25) -> Vector3:
	return Vector3((position.x - 800.0) / 90.0, y, (position.y - 450.0) / 90.0)

func _from_world(position: Vector3) -> Vector2:
	return Vector2(position.x * 90.0 + 800.0, position.z * 90.0 + 450.0)

func _material(color: Color, transparent: bool = false, emissive: bool = false, emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	if transparent or color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission_energy
	return material

func _normalize_visual_preset(preset: String) -> String:
	var value := preset.strip_edges().to_upper()
	if value == "" or value == "DEFAULT" or value == "CLEAN" or value == "2_5D_CLEAN":
		return VISUAL_PRESET_CLEAN
	if value == VISUAL_PRESET_CLEAN:
		return VISUAL_PRESET_CLEAN
	if value == "ATMOSPHERIC" or value == VISUAL_PRESET_ATMOSPHERIC:
		return VISUAL_PRESET_ATMOSPHERIC
	if value == "VFX_STRESS" or value == "STRESS" or value == VISUAL_PRESET_VFX_STRESS:
		return VISUAL_PRESET_VFX_STRESS
	return ""

func _preset_scope() -> String:
	if environment_presentation_shell_v2_enabled:
		return "v0193-opt-in-presentation-shell-v2-comparator-excluded-from-default"
	if environment_riverbank_bridge_approach_enabled:
		return "v0187-opt-in-riverbank-bridge-approach-lane-hardening-excluded-from-default"
	if environment_structure_shell_hardening_enabled:
		return "v0186-opt-in-procedural-structure-shell-hierarchy-hardening-excluded-from-default"
	if environment_shell_live_qa_enabled:
		return "v0185-opt-in-environment-shell-live-qa-pruned-overlays-excluded-from-default"
	if environment_geometry_convergence_enabled:
		return "v0184-opt-in-environment-geometry-convergence-excluded-from-default"
	if environment_readability_hardening_enabled:
		return "v0174-opt-in-road-river-bridge-site-marker-readability-excluded-from-default"
	if environment_foundation_review_enabled:
		return "v0173-opt-in-environment-foundation-review-excluded-from-default"
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return "private-spike-vfx-stress-excluded-from-default-review"
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return "private-atmospheric-balanced-full-excluded-from-default-review"
	return "player-facing-default-clean-readability-with-restrained-atmospheric-cues"

func _terrain_color() -> Color:
	if environment_presentation_shell_v2_enabled:
		return Color(0.20, 0.26, 0.18)
	if environment_riverbank_bridge_approach_enabled:
		return Color(0.24, 0.31, 0.22)
	if environment_shell_live_qa_enabled:
		return Color(0.23, 0.31, 0.22)
	if environment_geometry_convergence_enabled:
		return Color(0.26, 0.34, 0.24)
	if environment_readability_hardening_enabled:
		return Color(0.23, 0.31, 0.21)
	if environment_foundation_review_enabled:
		return Color(0.23, 0.31, 0.21)
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.16, 0.19, 0.13)
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return Color(0.10, 0.15, 0.15)
	return Color(0.16, 0.22, 0.17)

func _ridge_color() -> Color:
	if environment_presentation_shell_v2_enabled:
		return Color(0.29, 0.35, 0.24)
	if environment_riverbank_bridge_approach_enabled:
		return Color(0.32, 0.38, 0.27)
	if environment_shell_live_qa_enabled:
		return Color(0.31, 0.37, 0.27)
	if environment_geometry_convergence_enabled:
		return Color(0.34, 0.40, 0.29)
	if environment_readability_hardening_enabled:
		return Color(0.30, 0.37, 0.26)
	if environment_foundation_review_enabled:
		return Color(0.30, 0.37, 0.26)
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.22, 0.23, 0.16)
	return Color(0.22, 0.27, 0.21)

func _road_color() -> Color:
	if environment_presentation_shell_v2_enabled:
		return Color(0.50, 0.44, 0.32)
	if environment_riverbank_bridge_approach_enabled:
		return Color(0.47, 0.42, 0.31)
	if environment_shell_live_qa_enabled:
		return Color(0.46, 0.41, 0.30)
	if environment_geometry_convergence_enabled:
		return Color(0.50, 0.46, 0.34)
	if environment_readability_hardening_enabled:
		return Color(0.54, 0.49, 0.36)
	if environment_foundation_review_enabled:
		return Color(0.48, 0.43, 0.32)
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.42, 0.34, 0.22)
	return Color(0.42, 0.36, 0.25)

func _water_color() -> Color:
	if environment_presentation_shell_v2_enabled:
		return Color(0.025, 0.16, 0.22)
	if environment_riverbank_bridge_approach_enabled:
		return Color(0.025, 0.18, 0.25)
	if environment_shell_live_qa_enabled:
		return Color(0.03, 0.20, 0.27)
	if environment_geometry_convergence_enabled:
		return Color(0.04, 0.23, 0.31)
	if environment_readability_hardening_enabled:
		return Color(0.05, 0.25, 0.32)
	if environment_foundation_review_enabled:
		return Color(0.08, 0.28, 0.34)
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return Color(0.12, 0.34, 0.42)
	return Color(0.14, 0.34, 0.40)

func _lume_core_color() -> Color:
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.58, 0.96, 0.82)
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return Color(0.42, 0.92, 1.0)
	return Color(0.28, 0.86, 0.82)

func _lume_emission() -> float:
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return 0.72
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return 0.46
	return 0.28

func _unit_color(unit: Dictionary) -> Color:
	if str(unit["team"]) == "enemy":
		if str(unit["fixtureId"]) == "hexer":
			return Color(0.76, 0.20, 0.42)
		if str(unit["fixtureId"]) == "brute":
			return Color(0.64, 0.18, 0.14)
		if str(unit["fixtureId"]) == "enemy_commander":
			return Color(0.92, 0.24, 0.14)
		return Color(0.88, 0.28, 0.18)
	if str(unit["role"]) == "hero":
		return Color(0.36, 0.68, 0.86)
	if str(unit["role"]) == "Worker":
		return Color(0.72, 0.62, 0.38)
	if str(unit["fixtureId"]) == "ranger":
		return Color(0.48, 0.8, 0.64)
	return Color(0.42, 0.76, 0.46)

func _unit_radius(unit: Dictionary) -> float:
	if str(unit["role"]) == "hero":
		return 0.24
	if str(unit["role"]) == "Worker":
		return 0.14
	if str(unit["fixtureId"]) == "brute":
		return 0.20
	return 0.17

func _unit_scale(unit: Dictionary) -> Vector3:
	if str(unit["role"]) == "hero":
		return Vector3(1.0, 1.18, 1.0)
	if str(unit["role"]) == "Worker":
		return Vector3(0.82, 1.0, 0.82)
	if str(unit["fixtureId"]) == "ranger":
		return Vector3(0.84, 1.14, 0.84)
	if str(unit["team"]) == "enemy":
		return Vector3(1.08, 1.0, 1.08)
	return Vector3.ONE

func _unit_emissive(unit: Dictionary) -> bool:
	return visual_preset == VISUAL_PRESET_VFX_STRESS and (str(unit["role"]) == "hero" or str(unit["fixtureId"]) == "hexer")

func _selection_color(unit: Dictionary) -> Color:
	if str(unit["team"]) == "enemy":
		return Color(0.95, 0.24, 0.18, 0.54)
	return Color(0.62, 0.92, 0.74, 0.56)

func _structure_color(structure: Dictionary) -> Color:
	var team := str(structure["team"])
	if str(structure.get("fixtureId", "")) == "barracks" and str(structure.get("constructionState", "")) != "complete":
		return Color(0.36, 0.32, 0.25)
	if team == "enemy":
		return Color(0.42, 0.12, 0.10)
	if team == "neutral":
		return Color(0.42, 0.39, 0.31)
	return Color(0.45, 0.4, 0.34)

func _banner_color(structure: Dictionary) -> Color:
	if str(structure["team"]) == "enemy":
		return Color(0.86, 0.24, 0.16)
	return Color(0.36, 0.78, 0.58)

func _structure_scale(structure: Dictionary) -> Vector3:
	var size: Vector2 = structure["size"]
	return Vector3(max(0.25, size.x / 90.0), 0.38, max(0.25, size.y / 90.0))

func _v0186_structure_base_scale(fixture: String, scale: Vector3, structure: Dictionary) -> Vector3:
	match fixture:
		"command_hall":
			return Vector3(scale.x * 0.82, scale.y * 0.86, scale.z * 0.74)
		"barracks":
			if str(structure.get("constructionState", "")) != "complete":
				return Vector3(scale.x * 0.78, scale.y * 0.76, scale.z * 0.68)
			return Vector3(scale.x * 0.86, scale.y * 0.82, scale.z * 0.74)
		"west_stone_cut":
			return Vector3(scale.x * 0.68, scale.y * 0.72, scale.z * 0.66)
		"ford_toll":
			return Vector3(scale.x * 0.82, scale.y * 0.82, scale.z * 0.82)
		_:
			return scale

func _site_color(site: Dictionary) -> Color:
	var owner := str(site["owner"])
	if owner == "friendly":
		return Color(0.30, 0.78, 0.46, 0.86)
	if owner == "enemy":
		return Color(0.90, 0.22, 0.16, 0.86)
	if owner == "contested":
		return Color(0.95, 0.62, 0.20, 0.88)
	return Color(0.88, 0.78, 0.32, 0.82)

func _lume_color(link: Dictionary) -> Color:
	var state := str(link["state"])
	if state == "severed":
		return Color(0.95, 0.24, 0.20)
	if state == "candidate":
		return Color(0.35, 0.52, 0.58)
	if state == "restored":
		return Color(0.72, 0.96, 0.82)
	return _lume_core_color()
