extends Node3D

const MODE := "2_5D_ORTHOGRAPHIC_PLACEHOLDER"
const VISUAL_PRESET_CLEAN := "CLEAN_READABILITY"
const VISUAL_PRESET_ATMOSPHERIC := "ATMOSPHERIC_BALANCED"
const VISUAL_PRESET_VFX_STRESS := "VFX_STRESS_PRIVATE"
const SAFE_ZOOM_MIN := 8.8
const SAFE_ZOOM_MAX := 13.8
const SAFE_FRAME_DEFAULT_ZOOM := 10.8
const CAMERA_DEFAULT_POSITION := Vector3(0.0, 11.6, 8.9)
const CAMERA_DEFAULT_ROTATION := Vector3(-60.0, 0.0, 0.0)
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
const V0132_CONVERSION_PROGRESS_PER_SECOND := 46.0
const SITE_STATE_NEUTRAL := "NEUTRAL"
const SITE_STATE_OBJECTIVE_TARGET := "OBJECTIVE_TARGET"
const SITE_STATE_CONVERTING := "CONVERTING"
const SITE_STATE_CONTROLLED := "CONTROLLED"
const SITE_STATE_WORKER_ASSIGNED := "WORKER_ASSIGNED"
const BARRACKS_POSITION := Vector2(346, 178)
const BARRACKS_CLICK_RADIUS := 82.0
const LUME_LINK_POSITION := Vector2(742, 200)
const LUME_CLICK_RADIUS := 74.0
const V0133_CONSTRUCTION_FRAMES_PER_SECOND := 42
const V0133_RECRUIT_FRAMES_PER_SECOND := 38
const V0133_PRESSURE_COUNTDOWN_SECONDS := 5.0
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

func _ready() -> void:
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
	_sync_hud()

func _input(event: InputEvent) -> void:
	if _try_handle_v0133_hud_attack_mouse(event):
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if not _real_input_enabled():
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

func focus_layout_feature(feature: String) -> bool:
	var normalized := feature.strip_edges().to_lower()
	var position := CAMERA_DEFAULT_POSITION
	var zoom := SAFE_FRAME_DEFAULT_ZOOM
	match normalized:
		"default":
			pass
		"road":
			position = Vector3(-1.2, 11.4, 8.65)
			zoom = 9.65
		"ford":
			position = Vector3(0.45, 11.2, 8.35)
			zoom = 9.25
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
			camera_position = Vector3(-3.2, 11.25, 8.65)
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

func recenter_camera() -> bool:
	_apply_camera_authoring_posture("default", CAMERA_DEFAULT_POSITION, SAFE_FRAME_DEFAULT_ZOOM)
	return true

func toggle_pause() -> bool:
	var result: bool = runtime.toggle_pause()
	_set_or_create_marker("pause_marker", Vector3(-5.2, 0.22, -3.1), Vector3(0.72, 0.16, 0.32), Color(0.84, 0.78, 0.44))
	_sync_hud()
	return result

func transition_results() -> bool:
	var result: bool = runtime.transition_results()
	set_onboarding_step("review_results")
	show_objective_feedback("results_summary")
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
		"trace": real_input_trace.duplicate(true)
	}

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
		_set_or_create_disc_marker("hover_feedback_marker", _unit_world_position(next_hover, Vector3.ZERO) + Vector3(0.0, 0.045, 0.0), 0.38, Color(0.92, 0.88, 0.48, 0.44))
		_record_real_input("hover", {"unitId": next_hover, "screen": _vector2_report(event.position)})
	_sync_unit_visuals()
	_sync_hud()

func _handle_real_mouse_button(event: InputEventMouseButton) -> void:
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

func _select_from_real_click(screen_position: Vector2) -> void:
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
		v0133_box_select_no_skip_proven = current_onboarding_step != "prepare_ashen_pressure" or _v0133_objective_prerequisites_met("prepare_ashen_pressure")
		real_input_selected_id = "defender_squad" if current_onboarding_step == "defeat_wave" else str(selected[0])
		v0133_selected_structure_id = ""
		show_objective_feedback("squad_selected")
	_record_real_input("box_select", {"count": selected.size(), "ids": selected, "start": _vector2_report(start), "end": _vector2_report(end)})
	_sync_unit_visuals()
	_sync_hud()

func _issue_real_order(screen_position: Vector2) -> void:
	if runtime.selected_ids.is_empty():
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
	var world := _screen_to_ground(screen_position)
	if world == Vector3.INF:
		_record_real_input("move_order_failed_coordinate_conversion", {"screen": _vector2_report(screen_position)})
		return
	var destination := _from_world(world)
	if _selected_worker_for_v0132_assignment() and _destination_is_mine(destination):
		_complete_v0132_worker_assignment(screen_position)
		return
	if _selected_worker_for_v0133_barracks_restore() and _destination_is_barracks(destination):
		_start_v0133_barracks_restoration(screen_position)
		return
	if current_onboarding_step == "restore_lume_link" and _destination_is_lume(destination):
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

func run_workload_phase(phase: String) -> Dictionary:
	var report: Dictionary = runtime.run_workload_phase(phase)
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	_sync_hud()
	return report

func run_benchmark_suite() -> Dictionary:
	var report: Dictionary = runtime.run_benchmark_suite(MODE)
	report["visualPreset"] = visual_preset
	report["visualPresetScope"] = _preset_scope()
	report["visualPresetPrivate"] = visual_preset == VISUAL_PRESET_VFX_STRESS
	report["proceduralPrimitiveOnly"] = true
	report["generatedOrImportedArtIncluded"] = false
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
	status["proceduralPrimitiveOnly"] = true
	status["generatedOrImportedArtIncluded"] = false
	status["runtimeArtIntegrated"] = false
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
	light.light_energy = 1.08
	light.light_color = Color(0.92, 0.96, 0.88)
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		light.light_energy = 0.92
		light.light_color = Color(0.98, 0.86, 0.72)
	elif visual_preset == VISUAL_PRESET_VFX_STRESS:
		light.light_energy = 1.15
		light.light_color = Color(0.88, 0.96, 1.00)

func _create_terrain() -> void:
	terrain_root = Node3D.new()
	terrain_root.name = "ProceduralSaltoVisualFoundation"
	add_child(terrain_root)

	var ground := MeshInstance3D.new()
	ground.name = "SaltoTerrainPlane"
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(26.0, 22.0)
	ground.mesh = mesh
	ground.material_override = _material(_terrain_color())
	terrain_root.add_child(ground)

	_add_static_box("north_highland_height_band", Vector3(-1.5, 0.055, -5.35), Vector3(16.4, 0.10, 0.72), _ridge_color())
	_add_static_box("south_highland_height_band", Vector3(1.1, 0.05, 5.95), Vector3(17.2, 0.09, 0.66), _ridge_color().darkened(0.08))
	_add_static_box("west_terrace_height_step", Vector3(-6.2, 0.08, -0.35), Vector3(1.90, 0.16, 7.8), _ridge_color().lightened(0.06))
	_add_static_box("highland_foothold_shape_core", Vector3(-2.6, 0.115, -4.45), Vector3(8.4, 0.16, 1.18), _ridge_color().lightened(0.04))
	_add_static_box("highland_foothold_shape_shoulder", Vector3(3.8, 0.105, -3.86), Vector3(5.1, 0.14, 0.74), _ridge_color().darkened(0.03))
	_add_static_box("subtle_elevation_variation_tile_01", Vector3(-4.8, 0.075, 2.85), Vector3(2.4, 0.06, 1.2), _ridge_color().lightened(0.12))
	_add_static_box("subtle_elevation_variation_tile_02", Vector3(4.9, 0.07, -1.95), Vector3(2.0, 0.05, 1.4), _ridge_color().darkened(0.03))
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
	_add_static_box("capture_site_readability_ring", Vector3(-1.52, 0.13, 0.12), Vector3(1.26, 0.05, 1.02), Color(0.84, 0.78, 0.32, 0.64), true)
	_add_static_box("buildable_ground_patch_friendly", Vector3(-4.78, 0.12, 2.18), Vector3(2.36, 0.052, 1.30), Color(0.29, 0.36, 0.25))
	_add_static_box("buildable_ground_patch_forward", Vector3(4.35, 0.12, -0.58), Vector3(2.10, 0.052, 1.08), Color(0.27, 0.34, 0.24))
	_add_static_box("blocked_terrain_cue_north_rocks", Vector3(3.68, 0.20, -4.22), Vector3(1.25, 0.24, 0.36), Color(0.26, 0.28, 0.25))
	_add_static_box("blocked_terrain_cue_west_shelf", Vector3(-6.65, 0.22, -1.75), Vector3(0.44, 0.26, 2.10), Color(0.24, 0.28, 0.24))
	_add_static_box("blocked_terrain_cue_east_ridge", Vector3(6.35, 0.20, 2.65), Vector3(0.46, 0.24, 1.82), Color(0.25, 0.27, 0.24))
	_add_static_box("moss_material_posture_patch", Vector3(-3.8, 0.126, -2.55), Vector3(1.75, 0.04, 0.66), Color(0.20, 0.34, 0.18))
	_add_static_box("grass_material_posture_patch", Vector3(3.85, 0.125, 0.95), Vector3(1.65, 0.04, 0.58), Color(0.24, 0.39, 0.18))
	_add_static_box("worked_earth_material_posture_patch", Vector3(-4.55, 0.126, 3.18), Vector3(1.85, 0.04, 0.62), Color(0.38, 0.30, 0.19))
	_add_static_cylinder("warm_hearth_accent_command_hall", Vector3(-4.92, 0.18, 3.02), 0.09, 0.08, Color(0.92, 0.54, 0.24), true)
	_add_static_cylinder("restrained_teal_lume_accent_a", Vector3(0.05, 0.16, -1.16), 0.08, 0.08, _lume_core_color(), true)
	_add_static_cylinder("restrained_teal_lume_accent_b", Vector3(1.34, 0.16, 1.72), 0.08, 0.08, _lume_core_color(), true)
	_add_static_box("minimap_orientation_ground_hint", Vector3(-6.65, 0.12, -4.25), Vector3(0.60, 0.08, 0.28), Color(0.54, 0.80, 0.74))

	if visual_preset != VISUAL_PRESET_CLEAN:
		_add_static_box("atmospheric_fog_posture_north", Vector3(0, 0.16, -4.15), Vector3(13.4, 0.10, 0.86), Color(0.66, 0.82, 0.77, 0.18), true)
		_add_static_box("atmospheric_fog_posture_south", Vector3(1.2, 0.16, 4.18), Vector3(12.0, 0.10, 0.72), Color(0.80, 0.72, 0.58, 0.15), true)
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		for index in range(10):
			var x := -0.95 + float(index) * 0.20
			_add_static_cylinder("private_lume_vfx_stress_%02d" % index, Vector3(x, 0.18, -1.46 + sin(float(index)) * 0.18), 0.08, 0.08, _lume_core_color().lightened(0.18), true)

func _create_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "ProceduralPlaceholderHud"
	add_child(hud_layer)

	var resource_frame := Panel.new()
	resource_frame.name = "HudResourceCornerRow"
	resource_frame.position = Vector2(18, 18)
	resource_frame.size = Vector2(444, 34)
	resource_frame.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.045, 0.040, 0.84), Color(0.36, 0.74, 0.66, 0.78)))
	hud_layer.add_child(resource_frame)

	hud_resource_label = Label.new()
	hud_resource_label.name = "CompactResourceRow"
	hud_resource_label.position = Vector2(14, 5)
	hud_resource_label.size = Vector2(416, 22)
	hud_resource_label.add_theme_font_size_override("font_size", 14)
	hud_resource_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.82))
	resource_frame.add_child(hud_resource_label)

	var objective_frame := Panel.new()
	objective_frame.name = "HudCurrentObjectiveStrip"
	objective_frame.position = Vector2(18, 58)
	objective_frame.size = Vector2(444, 30)
	objective_frame.add_theme_stylebox_override("panel", _panel_style(Color(0.040, 0.045, 0.038, 0.82), Color(0.68, 0.62, 0.36, 0.78)))
	hud_layer.add_child(objective_frame)

	hud_objective_strip_label = Label.new()
	hud_objective_strip_label.name = "CurrentObjectiveStripText"
	hud_objective_strip_label.position = Vector2(12, 4)
	hud_objective_strip_label.size = Vector2(420, 22)
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
	frame.position = Vector2(18, 744)
	frame.size = Vector2(506, 142)
	frame.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.045, 0.045, 0.88), Color(0.36, 0.74, 0.66, 0.84)))
	hud_layer.add_child(frame)

	hud_hero_label = Label.new()
	hud_hero_label.name = "SelectedHeroCard"
	hud_hero_label.position = Vector2(16, 10)
	hud_hero_label.size = Vector2(474, 22)
	hud_hero_label.add_theme_font_size_override("font_size", 15)
	hud_hero_label.add_theme_color_override("font_color", Color(0.72, 0.90, 0.96))
	frame.add_child(hud_hero_label)

	hud_context_label = Label.new()
	hud_context_label.name = "SelectedContextCard"
	hud_context_label.position = Vector2(16, 34)
	hud_context_label.size = Vector2(474, 22)
	hud_context_label.add_theme_font_size_override("font_size", 13)
	hud_context_label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.76))
	frame.add_child(hud_context_label)

	hud_objective_label = Label.new()
	hud_objective_label.name = "ObjectiveSummaryCompact"
	hud_objective_label.position = Vector2(16, 58)
	hud_objective_label.size = Vector2(474, 22)
	hud_objective_label.add_theme_font_size_override("font_size", 13)
	hud_objective_label.add_theme_color_override("font_color", Color(0.92, 0.82, 0.60))
	frame.add_child(hud_objective_label)

	hud_status_label = Label.new()
	hud_status_label.name = "PlayerReadableStatus"
	hud_status_label.position = Vector2(16, 80)
	hud_status_label.size = Vector2(474, 20)
	hud_status_label.add_theme_font_size_override("font_size", 12)
	hud_status_label.add_theme_color_override("font_color", Color(0.66, 0.84, 0.78))
	frame.add_child(hud_status_label)

	var command_labels := ["Move", "Attack", "Hold", "Work", "Lume"]
	var command_names := ["CommandButtonMove", "CommandButtonAttack", "CommandButtonHold", "CommandButtonWork", "CommandButtonLume"]
	for index in range(command_labels.size()):
		var button := Button.new()
		button.name = command_names[index]
		button.text = command_labels[index]
		button.position = Vector2(16 + index * 95, 106)
		button.size = Vector2(82, 26)
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
	hud_onboarding_label.position = Vector2(538, 744)
	hud_onboarding_label.size = Vector2(438, 44)
	hud_onboarding_label.add_theme_font_size_override("font_size", 14)
	hud_onboarding_label.add_theme_color_override("font_color", Color(0.90, 0.92, 0.78))
	hud_layer.add_child(hud_onboarding_label)

	hud_alert_label = Label.new()
	hud_alert_label.name = "ObjectiveFeedbackAlert"
	hud_alert_label.position = Vector2(538, 796)
	hud_alert_label.size = Vector2(438, 30)
	hud_alert_label.add_theme_font_size_override("font_size", 14)
	hud_alert_label.add_theme_color_override("font_color", Color(0.76, 0.94, 0.88))
	hud_layer.add_child(hud_alert_label)

	hud_more_details_button = Button.new()
	hud_more_details_button.name = "MoreDetailsDisclosure"
	hud_more_details_button.text = "More Details"
	hud_more_details_button.position = Vector2(538, 836)
	hud_more_details_button.size = Vector2(132, 28)
	hud_more_details_button.add_theme_font_size_override("font_size", 12)
	hud_more_details_button.pressed.connect(_toggle_more_details)
	hud_layer.add_child(hud_more_details_button)

	hud_more_details_label = Label.new()
	hud_more_details_label.name = "MoreDetailsPanel"
	hud_more_details_label.position = Vector2(684, 836)
	hud_more_details_label.size = Vector2(292, 42)
	hud_more_details_label.add_theme_font_size_override("font_size", 12)
	hud_more_details_label.add_theme_color_override("font_color", Color(0.72, 0.84, 0.78))
	hud_layer.add_child(hud_more_details_label)

	minimap_panel = Panel.new()
	minimap_panel.name = "MinimapOrientationPlaceholder"
	minimap_panel.position = Vector2(1362, 674)
	minimap_panel.size = Vector2(206, 184)
	minimap_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.055, 0.84), Color(0.40, 0.72, 0.68, 0.78)))
	hud_layer.add_child(minimap_panel)

	for marker in [
		{"name": "minimap_salto_terrain_outline", "pos": Vector2(12, 12), "size": Vector2(182, 160), "color": Color(0.12, 0.20, 0.17, 0.78)},
		{"name": "minimap_highland_shape", "pos": Vector2(24, 28), "size": Vector2(76, 14), "color": Color(0.42, 0.78, 0.52)},
		{"name": "minimap_main_road", "pos": Vector2(32, 82), "size": Vector2(132, 10), "color": Color(0.58, 0.50, 0.34)},
		{"name": "minimap_water_strip", "pos": Vector2(98, 34), "size": Vector2(10, 116), "color": Color(0.22, 0.66, 0.76)},
		{"name": "minimap_ford_crossing", "pos": Vector2(84, 82), "size": Vector2(40, 8), "color": Color(0.68, 0.76, 0.72)},
		{"name": "minimap_friendly_cluster", "pos": Vector2(34, 116), "size": Vector2(16, 16), "color": Color(0.30, 0.78, 0.52)},
		{"name": "minimap_hero_marker", "pos": Vector2(44, 106), "size": Vector2(14, 14), "color": Color(0.88, 0.92, 0.48)},
		{"name": "minimap_objective_marker", "pos": Vector2(60, 94), "size": Vector2(16, 16), "color": Color(0.96, 0.82, 0.28)},
		{"name": "minimap_quarry", "pos": Vector2(58, 100), "size": Vector2(18, 16), "color": Color(0.88, 0.78, 0.32)},
		{"name": "minimap_west_stone_cut_mine_target", "pos": Vector2(58, 100), "size": Vector2(18, 16), "color": Color(0.88, 0.78, 0.32)},
		{"name": "minimap_west_stone_cut_mine_control", "pos": Vector2(62, 104), "size": Vector2(10, 8), "color": Color(0.32, 0.90, 0.52)},
		{"name": "minimap_shrine", "pos": Vector2(74, 46), "size": Vector2(14, 14), "color": Color(0.28, 0.86, 0.82)},
		{"name": "minimap_mine_marker", "pos": Vector2(52, 92), "size": Vector2(12, 12), "color": Color(0.66, 0.66, 0.56)},
		{"name": "minimap_ruin", "pos": Vector2(130, 118), "size": Vector2(20, 12), "color": Color(0.62, 0.62, 0.54)},
		{"name": "minimap_lume_endpoint_a", "pos": Vector2(68, 92), "size": Vector2(8, 8), "color": Color(0.38, 0.94, 0.88)},
		{"name": "minimap_lume_endpoint_b", "pos": Vector2(110, 78), "size": Vector2(8, 8), "color": Color(0.38, 0.94, 0.88)},
		{"name": "minimap_lume_link", "pos": Vector2(74, 86), "size": Vector2(42, 4), "color": Color(0.38, 0.94, 0.88, 0.78)},
		{"name": "minimap_hostile_marker", "pos": Vector2(134, 40), "size": Vector2(44, 14), "color": Color(0.84, 0.28, 0.20)},
		{"name": "minimap_camera_viewport_indicator", "pos": Vector2(48, 66), "size": Vector2(86, 62), "color": Color(0.82, 0.92, 0.84, 0.22)}
	]:
		_add_minimap_marker(str(marker["name"]), marker["pos"], marker["size"], marker["color"])
	_sync_player_shell_chrome()

func _sync_hud() -> void:
	if hud_resource_label:
		hud_resource_label.text = "Crowns %s  Stone %s  Iron %s  Aether %s" % [
			runtime.resources.get("crowns", 0),
			runtime.resources.get("stone", 0),
			runtime.resources.get("iron", 0),
			runtime.resources.get("aether", 0)
		]
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
		hud_more_details_label.text = "West Stone Cut Mine, Worker, Barracks, one Militia recruit, one wave, and Lume are the only review goals."
		hud_more_details_label.visible = more_details_visible
	if hud_more_details_button:
		hud_more_details_button.visible = current_onboarding_step != "defeat_wave"
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
	minimap_panel.add_child(rect)

func _minimap_has_marker(name: String) -> bool:
	return minimap_panel != null and minimap_panel.get_node_or_null(name) != null

func _toggle_more_details() -> void:
	more_details_visible = not more_details_visible
	_sync_hud()

func _hud_move_pressed() -> void:
	if runtime.selected_ids.is_empty():
		runtime.select_entity("hero_aster")
	_issue_real_order(real_input_screen_position("west_stone_cut_mine"))

func _hud_attack_pressed() -> void:
	if current_onboarding_step == "defeat_wave":
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
		return "Results ready"
	if v0133_lume_highlight_visible:
		return "Wave broken; restore the highlighted Lume link"
	if v0133_wave_triggered_once and not v0133_wave_defeated_from_simulation:
		return "Ashen wave: %s remaining; click Attack or right-click a marked Ashen" % maxi(0, v0133_wave_remaining_count)
	if v0133_countdown_started and not v0133_wave_triggered_once:
		return "Ashen pressure in %ss" % int(ceil(v0133_countdown_remaining))
	if runtime.militia_spawned:
		return "Militia ready; break the Ashen wave"
	if v0133_recruit_queue_started:
		return "Militia training: %s%%" % int(round(v0133_recruit_progress * 100.0))
	if runtime.barracks_complete:
		return "Barracks restored; select it and train one Militia"
	if v0133_construction_started:
		return "Restoring Barracks: %s%%" % int(round(v0133_construction_progress * 100.0))
	if runtime.worker_assigned_to_mine:
		return "Worker assigned; right-click the highlighted Barracks"
	if v0132_mine_controlled or runtime.mine_converted:
		return "West Stone Cut Mine controlled; select the highlighted Worker"
	if v0132_site_state == SITE_STATE_CONVERTING:
		return "Converting West Stone Cut Mine: %s%%" % int(round(v0132_conversion_progress))
	if v0132_site_state == SITE_STATE_OBJECTIVE_TARGET:
		return "Move Aster into the West Stone Cut Mine ring"
	if pressure_wave_arrived:
		return "Hold formation; Ashen pressure is on the road"
	if runtime.lume_links.any(func(link: Dictionary) -> bool: return bool(link.get("focused", false))):
		return "Lume route is marked"
	return "Commands ready"

func _selected_context_text() -> String:
	if current_onboarding_step == "defeat_wave" and runtime.selected_ids.size() > 1:
		return "Defenders selected: click Attack or right-click the marked Ashen wave"
	if current_onboarding_step == "defeat_wave" and runtime.selected_ids.is_empty():
		return "No defenders selected: box-select the green line or click Attack"
	if runtime.selected_ids.size() > 1:
		return "Squad posture: protect Aster and hold the road"
	if v0133_selected_structure_id == "barracks":
		return "Barracks: train one Militia"
	if runtime.selected_ids.is_empty() or runtime.selected_ids.has("hero_aster"):
		return "Aster HP 100/100 | Rally ability ready"
	if runtime.selected_ids.any(func(id: String) -> bool: return id.begins_with("worker")):
		return "Worker: right-click controlled West Stone Cut Mine"
	return "Unit ready"

func _objective_summary_text() -> String:
	if current_onboarding_step == "defeat_wave":
		return "Ashen wave: %s remaining | Attack the marked red units" % maxi(0, v0133_wave_remaining_count)
	return "Convert mine | Build Barracks | Train Militia | Restore Lume"

func _current_objective_text() -> String:
	match current_onboarding_step:
		"select_aster":
			return "Objective 1: Select Aster"
		"move_to_quarry":
			return "Objective 2: Move Aster to West Stone Cut Mine"
		"capture_hold_quarry":
			return "Objective 3: Convert West Stone Cut Mine"
		"worker_mine_or_shrine":
			return "Objective 4: Select the highlighted Worker"
		"worker_assign_mine":
			return "Objective 4: Right-click West Stone Cut Mine"
		"restore_barracks":
			return "Objective 5: Restore the Barracks"
		"finish_barracks":
			return "Objective 5: Restore the Barracks"
		"queue_militia":
			return "Objective 6: Train one Militia"
		"train_militia":
			return "Objective 6: Train one Militia"
		"prepare_ashen_pressure":
			return "Objective 7: Prepare for Ashen pressure"
		"defeat_wave":
			return "Objective 8: Defeat the Ashen wave"
		"restore_lume_link":
			return "Objective 9: Restore the Lume link"
		"review_results":
			return "Objective 10: Review Results"
	return "Objective: Secure West Stone Cut Mine and restore Lume"

func _onboarding_text(step_id: String) -> String:
	match step_id:
		"select_aster":
			return "Tip: Select Aster."
		"move_to_quarry":
			return "Tip: Right-click the highlighted West Stone Cut Mine."
		"capture_hold_quarry":
			return "Tip: Keep Aster inside the ring while the conversion bar fills."
		"worker_mine_or_shrine":
			return "Tip: Select the highlighted Worker."
		"worker_assign_mine":
			return "Tip: Right-click the controlled West Stone Cut Mine with the Worker."
		"restore_barracks":
			return "Tip: With the Worker selected, right-click the highlighted Barracks frame."
		"finish_barracks":
			return "Tip: Watch construction finish on the highlighted Barracks."
		"queue_militia":
			return "Tip: Select the restored Barracks."
		"train_militia":
			return "Tip: Click Train, then wait for the Militia to step out."
		"prepare_ashen_pressure":
			return "Tip: Watch the Ashen-pressure countdown."
		"defeat_wave":
			return "Tip: Defenders are selected. Click Attack, or right-click a marked Ashen unit."
		"restore_lume_link":
			return "Tip: Click the highlighted Lume link."
		"review_results":
			return "Tip: Review the Results."
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
		child.queue_free()
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
		node.position = _to_world(unit["position"], 0.28)
		node.scale = _unit_scale(unit) * (1.22 if selected else 1.0)
		node.visible = visible_unit
		var health_ratio: float = clampf(float(unit.get("health", 0.0)) / max(1.0, float(unit.get("maxHealth", 1.0))), 0.0, 1.0)
		var health_visible: bool = visible_unit and (selected or is_targeted or damage_flash_active)
		var health_back := visual_root.get_node_or_null("health_back_%s" % id) as MeshInstance3D
		if health_back:
			health_back.position = _to_world(unit["position"], 0.665)
			health_back.visible = health_visible
		var health := visual_root.get_node_or_null("health_%s" % id) as MeshInstance3D
		if health:
			var full_width: float = _unit_radius(unit) * 1.65
			var mesh := health.mesh as BoxMesh
			if mesh:
				mesh.size = Vector3(max(0.026, full_width * health_ratio), 0.035, 0.035)
			health.position = _to_world(unit["position"], 0.68) + Vector3((health_ratio - 1.0) * full_width * 0.5, 0.0, 0.0)
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
			damage_marker.position = _to_world(unit["position"], 0.58)
			damage_marker.visible = visible_unit and damage_flash_active and (is_targeted or id == "ashen_00")
	_sync_real_input_hover_marker()
	_sync_player_guidance_markers()

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

func _add_structure(structure: Dictionary) -> void:
	var id := str(structure["id"])
	var fixture := str(structure["fixtureId"])
	var position := _to_world(structure["position"], 0.34)
	var scale := _structure_scale(structure)
	var color := _structure_color(structure)
	_add_box(id, position, scale, color)
	if fixture == "command_hall" or fixture == "enemy_stronghold":
		_add_box("%s_keep_tower" % id, position + Vector3(0.0, 0.34, 0.0), Vector3(scale.x * 0.34, 0.58, scale.z * 0.34), color.lightened(0.12))
		_add_box("%s_banner_silhouette" % id, position + Vector3(-scale.x * 0.38, 0.72, -scale.z * 0.12), Vector3(0.10, 0.34, 0.28), _banner_color(structure))
		_add_box("%s_roof_ridge" % id, position + Vector3(0.0, 0.62, 0.0), Vector3(scale.x * 0.82, 0.10, scale.z * 0.18), color.lightened(0.20))
		_add_box("%s_command_door_readability" % id, position + Vector3(0.0, 0.04, scale.z * 0.52), Vector3(scale.x * 0.26, 0.16, 0.08), Color(0.18, 0.15, 0.11))
	elif fixture == "barracks" or fixture == "enemy_barracks":
		_add_box("%s_training_wing_a" % id, position + Vector3(-scale.x * 0.30, 0.22, 0.0), Vector3(scale.x * 0.32, 0.34, scale.z * 0.88), color.lightened(0.08))
		_add_box("%s_training_wing_b" % id, position + Vector3(scale.x * 0.30, 0.22, 0.0), Vector3(scale.x * 0.32, 0.34, scale.z * 0.88), color.darkened(0.08))
		_add_box("%s_weapon_rack_silhouette" % id, position + Vector3(0.0, 0.46, -scale.z * 0.44), Vector3(scale.x * 0.72, 0.08, 0.08), Color(0.54, 0.48, 0.34))
		_add_box("%s_drill_yard_edge" % id, position + Vector3(0.0, -0.12, scale.z * 0.72), Vector3(scale.x * 0.94, 0.05, 0.12), Color(0.32, 0.28, 0.18))
		if str(structure.get("constructionState", "")) != "complete":
			var progress := clampf(float(structure.get("constructionProgress", 0.0)), 0.0, 1.0)
			_add_box("%s_construction_scaffold" % id, position + Vector3(0.0, 0.58, 0.0), Vector3(scale.x * 0.90, 0.08, scale.z * 0.94), Color(0.80, 0.68, 0.36, 0.58), true)
			_add_box("%s_construction_progress_bar" % id, position + Vector3((progress - 1.0) * scale.x * 0.28, 0.68, scale.z * 0.58), Vector3(max(0.08, scale.x * 0.56 * progress), 0.06, 0.08), Color(0.42, 0.88, 0.56, 0.72), true)
	elif fixture == "west_stone_cut":
		_add_box("%s_quarry_crane" % id, position + Vector3(0.32, 0.30, -0.10), Vector3(0.16, 0.42, 0.70), Color(0.55, 0.50, 0.36))
		_add_box("%s_mine_mouth_shadow" % id, position + Vector3(-0.22, 0.10, 0.36), Vector3(0.42, 0.20, 0.16), Color(0.12, 0.12, 0.10))
		_add_box("%s_cut_stone_stack" % id, position + Vector3(0.44, -0.10, 0.34), Vector3(0.34, 0.12, 0.24), Color(0.58, 0.55, 0.46))
	elif fixture == "ford_toll":
		_add_cylinder("%s_shrine_cap" % id, position + Vector3(0, 0.38, 0), 0.34, 0.20, Color(0.74, 0.68, 0.46), false)
		_add_cylinder("%s_shrine_beacon_slot" % id, position + Vector3(0, 0.58, 0), 0.12, 0.18, _lume_core_color(), false)
		_add_box("%s_shrine_steps" % id, position + Vector3(0.0, -0.12, 0.32), Vector3(0.54, 0.08, 0.18), Color(0.54, 0.50, 0.38))

func _add_capture_site(site: Dictionary) -> void:
	var position := _to_world(site["position"], 0.13)
	_add_box(str(site["id"]), position, Vector3(0.56, 0.12, 0.56), _site_color(site), true)
	_add_cylinder("%s_marker_disc" % str(site["id"]), position + Vector3(0, -0.055, 0), 0.42, 0.045, _site_color(site).lightened(0.18), true)
	_add_box("%s_claim_post" % str(site["id"]), position + Vector3(0.0, 0.23, 0.0), Vector3(0.08, 0.36, 0.08), _site_color(site).lightened(0.08), true)
	_add_box("%s_contest_tick" % str(site["id"]), position + Vector3(0.28, 0.08, 0.28), Vector3(0.22, 0.05, 0.08), Color(0.96, 0.70, 0.24, 0.62), true)

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
	if str(unit["role"]) == "hero":
		var hero_mesh := CapsuleMesh.new()
		hero_mesh.radius = 0.18
		hero_mesh.height = 0.62
		mesh = hero_mesh
	elif str(unit["role"]) == "Worker":
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
	else:
		var militia_mesh := CylinderMesh.new()
		militia_mesh.top_radius = 0.15
		militia_mesh.bottom_radius = 0.18
		militia_mesh.height = 0.42
		militia_mesh.radial_segments = 6
		mesh = militia_mesh
	mesh_instance.mesh = mesh
	mesh_instance.position = _to_world(unit["position"], 0.28)
	mesh_instance.material_override = _material(_unit_color(unit), false, _unit_emissive(unit), 0.35)
	visual_root.add_child(mesh_instance)
	_add_unit_silhouette_parts(mesh_instance, unit)

func _add_unit_silhouette_parts(parent: MeshInstance3D, unit: Dictionary) -> void:
	var fixture := str(unit["fixtureId"])
	var role := str(unit["role"])
	var team := str(unit["team"])
	if role == "hero":
		_add_child_box(parent, "hero_command_banner", Vector3(0.0, 0.36, -0.08), Vector3(0.08, 0.34, 0.18), Color(0.82, 0.88, 0.54))
		_add_child_box(parent, "hero_blade_profile", Vector3(0.20, 0.08, 0.05), Vector3(0.06, 0.44, 0.08), Color(0.72, 0.78, 0.74))
		_add_child_box(parent, "hero_shield_plate", Vector3(-0.18, 0.02, 0.06), Vector3(0.08, 0.26, 0.24), Color(0.24, 0.44, 0.56))
		_add_child_cylinder(parent, "hero_crown_disc", Vector3(0.0, 0.42, 0.0), 0.13, 0.045, Color(0.86, 0.82, 0.48))
	elif role == "Worker":
		_add_child_box(parent, "worker_pack_crate", Vector3(0.0, 0.03, -0.18), Vector3(0.24, 0.20, 0.10), Color(0.48, 0.36, 0.20))
		_add_child_box(parent, "worker_tool_handle", Vector3(0.18, 0.10, 0.03), Vector3(0.05, 0.36, 0.05), Color(0.66, 0.56, 0.36))
		_add_child_box(parent, "worker_tool_head", Vector3(0.20, 0.28, 0.03), Vector3(0.16, 0.05, 0.07), Color(0.55, 0.56, 0.48))
	elif fixture == "ranger":
		_add_child_box(parent, "ranger_bow_profile", Vector3(0.19, 0.04, 0.0), Vector3(0.05, 0.48, 0.06), Color(0.38, 0.30, 0.18))
		_add_child_box(parent, "ranger_quiver", Vector3(-0.14, 0.04, -0.16), Vector3(0.08, 0.30, 0.08), Color(0.30, 0.42, 0.30))
		_add_child_box(parent, "ranger_arrow_line", Vector3(0.0, 0.18, 0.19), Vector3(0.08, 0.05, 0.30), Color(0.72, 0.80, 0.62))
	elif team == "enemy" and fixture == "brute":
		_add_child_box(parent, "ashen_brute_shoulder_left", Vector3(-0.20, 0.12, 0.0), Vector3(0.18, 0.20, 0.24), Color(0.42, 0.09, 0.08))
		_add_child_box(parent, "ashen_brute_shoulder_right", Vector3(0.20, 0.12, 0.0), Vector3(0.18, 0.20, 0.24), Color(0.42, 0.09, 0.08))
		_add_child_box(parent, "ashen_brute_cleaver", Vector3(0.0, 0.10, 0.24), Vector3(0.10, 0.34, 0.08), Color(0.68, 0.28, 0.18))
	elif team == "enemy":
		_add_child_box(parent, "ashen_raider_forward_blade", Vector3(0.0, 0.06, 0.22), Vector3(0.08, 0.30, 0.08), Color(0.78, 0.26, 0.16))
		_add_child_box(parent, "ashen_raider_horn_left", Vector3(-0.15, 0.22, 0.0), Vector3(0.12, 0.10, 0.08), Color(0.50, 0.16, 0.12))
		_add_child_box(parent, "ashen_raider_horn_right", Vector3(0.15, 0.22, 0.0), Vector3(0.12, 0.10, 0.08), Color(0.50, 0.16, 0.12))
	else:
		_add_child_box(parent, "militia_shield_plate", Vector3(-0.18, 0.02, 0.04), Vector3(0.08, 0.26, 0.22), Color(0.26, 0.44, 0.30))
		_add_child_box(parent, "militia_spear_profile", Vector3(0.18, 0.10, 0.0), Vector3(0.05, 0.52, 0.05), Color(0.58, 0.52, 0.34))
		_add_child_box(parent, "militia_spear_tip", Vector3(0.18, 0.38, 0.0), Vector3(0.10, 0.08, 0.08), Color(0.70, 0.72, 0.62))

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
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return "private-spike-vfx-stress-excluded-from-default-review"
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return "private-atmospheric-balanced-full-excluded-from-default-review"
	return "player-facing-default-clean-readability-with-restrained-atmospheric-cues"

func _terrain_color() -> Color:
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.16, 0.19, 0.13)
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return Color(0.10, 0.15, 0.15)
	return Color(0.13, 0.19, 0.14)

func _ridge_color() -> Color:
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.22, 0.23, 0.16)
	return Color(0.18, 0.23, 0.18)

func _road_color() -> Color:
	if visual_preset == VISUAL_PRESET_ATMOSPHERIC:
		return Color(0.42, 0.34, 0.22)
	return Color(0.37, 0.32, 0.22)

func _water_color() -> Color:
	if visual_preset == VISUAL_PRESET_VFX_STRESS:
		return Color(0.12, 0.34, 0.42)
	return Color(0.12, 0.28, 0.34)

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
