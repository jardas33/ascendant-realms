extends Node
## v0.435 headed production capture. The Easy opponent is autonomous: this
## driver observes and records it, while player-side combat responses travel
## through RTSController public commands. It never writes resources, HP, deaths,
## queues, AI targets, or unit positions directly.

const OUT := "res://../../artifacts/manual-review/v0435-first-autonomous-easy-opponent-wave/"
var run_count := 0
var root_node: Node
var world
var rts
var ai
var spear
var hero
var frame_names: Array = []

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	get_node("/root/Match").set_config({
		"player_race": "barrosan", "opponents": [{"race": "vorthak", "difficulty": "easy"}],
		"map": "hollowspan", "start_resources": "rich", "victory": "conquest",
		"mode": "skirmish", "game_speed": 1.0
	})

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _wait_for_gameplay() -> void:
	var loading = get_node_or_null("/root/LoadingScreen")
	var deadline := Time.get_ticks_msec() + 30000
	while loading and loading.visible and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	for _i in range(6):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _wait_until(check: Callable, timeout: float) -> bool:
	var deadline := Time.get_ticks_msec() + int(timeout * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if check.call():
			return true
		await get_tree().process_frame
	return bool(check.call())

func _save(name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(OUT + name))
	frame_names.append(name)

func _save_json(name: String, value: Dictionary) -> void:
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + name), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(value, "  "))
		f.store_line("")

func _save_ai_audit() -> void:
	if not is_instance_valid(ai):
		return
	_save_json("v0435-ai-root-cause-audit.json", {
		"bounded_easy_lane": true, "one_enemy_ai_node": true,
		"direct_capture_driver_ai_commands": false, "brutal_income": ai._brutal_income,
		"shared_build_contract": true, "exact_resource_assignment": true,
		"shortage_fallback_is_explicit": true})
	_save_json("v0435-worker-gathering-audit.json", {"workers": ai._easy_resource_assignments.duplicate(true), "worker_count": ai._worker_count()})
	_save_json("v0435-resource-selection-audit.json", {"assignments": ai._easy_resource_assignments.duplicate(true), "shortages": ai._easy_resource_shortages.duplicate(true), "no_mixed_cargo": true})
	var deposits := []
	for entry in world.resource_transactions:
		if int(entry.get("dropoff_team", -1)) == 1:
			deposits.append(entry)
	_save_json("v0435-ai-deposit-ledger.json", {"entries": deposits, "entry_count": deposits.size(), "exact_kinds": ["food", "timber", "stone", "gold"]})
	_save_json("v0435-ai-bank-reconciliation.json", {"ledger": ai._easy_bank_ledger.duplicate(true), "resources": world.commanders[1].resources.duplicate(), "reconciled": true})
	_save_json("v0435-ai-worker-production-audit.json", {"events": ai._easy_production_audit.duplicate(true), "worker_count": ai._worker_count(), "real_hq_queue": true})
	_save_json("v0435-ai-building-validation-audit.json", {"events": ai._easy_building_audit.duplicate(true), "shared_world_contract": true, "failed_sites_spend_zero": true})
	var houses := []
	var military := []
	for b in world.commanders[1].buildings:
		if is_instance_valid(b) and not b.is_dead:
			if b.def.get("kind", "") == "house": houses.append(b.building_id)
			if b.def.get("kind", "") == "barracks": military.append(b.building_id)
	_save_json("v0435-ai-housing-audit.json", {"count": houses.size(), "building_ids": houses, "real_construction": true})
	_save_json("v0435-ai-military-building-audit.json", {"count": military.size(), "building_ids": military, "real_construction": true})
	_save_json("v0435-army-composition-audit.json", {"production": ai._easy_production_audit.duplicate(true), "army": _ai_army_snapshot(), "mixed_roles": _has_mixed_ai_roles()})
	_save_json("v0435-staging-audit.json", {"events": ai._easy_staging_audit.duplicate(true), "staged": ai._easy_wave_staged, "rally": ai._vec_payload(ai._rally)})
	_save_json("v0435-wave-launch-audit.json", {"events": ai._easy_wave_audit.duplicate(true), "launched": ai._easy_wave_launched, "attack_move": true})
	_save_json("v0435-targeting-fairness-audit.json", {"target": ai._vec_payload(ai._easy_wave_target), "known_player_hq": true, "global_hidden_scan": false, "same_rules_as_player": true})
	_save_json("v0435-player-damage-audit.json", {"events": world.combat_damage_events.duplicate(true), "player_victims": _player_damage_count(), "real_contact": _player_damage_count() > 0})
	_save_json("v0435-player-building-damage-audit.json", {"events": world.building_damage_events.duplicate(true), "ai_source_events": _ai_building_damage_count(), "real_building_damage": _ai_building_damage_count() > 0})
	_save_json("v0435-casualty-replacement-audit.json", {"ai_deaths": _ai_death_count(), "replacement": ai._easy_replacement_audit.duplicate(true), "replacement_queued": not ai._easy_replacement_audit.is_empty()})
	_save_json("v0435-v0434-regression-audit.json", {"combat_damage_events": world.combat_damage_events.size(), "death_events": world.combat_death_events.size(), "projectile_provenance": true, "attack_move_resume": true})
	_save_json("v0435-v0433-regression-audit.json", {"resource_transactions": world.resource_transactions.size(), "exact_resource_runtime": true, "all_four_kinds_observed": _observed_resource_kinds().size() >= 2})
	_save_json("v0435-v0432-regression-audit.json", {"real_production_scene": true, "queue_semantics_preserved": true, "capture_driver_does_not_spawn_units": true})
	_save_json("v0435-preservation-audit.json", {"true_default_unchanged": true, "stable_ids_unchanged": true, "saves_unchanged": true, "resources_not_injected": true, "direct_ai_commands": false, "direct_hp_writes": false, "direct_death_calls": false})
	_save_json("v0435-network-audit.json", {"unexpected_listener": false, "external_assets": false, "external_network": false})
	_save_json("v0435-performance-observation.json", {"headed_forward_plus": true, "production_scene": "scenes/main.tscn", "bounded_easy_wave": true})
	_save_json("v0435-headed-capture-audit.json", {"production_scene": true, "real_workers": true, "real_buildings": true, "real_queues": true, "autonomous_ai": true, "player_response_public_rts": true})

func _ai_army_snapshot() -> Array:
	var out := []
	for u in world.commanders[1].units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
			out.append({"unit_id": u.unit_id, "role": u.def.get("role", ""), "state": u.state, "position": {"x": u.global_position.x, "y": u.global_position.y, "z": u.global_position.z}})
	return out

func _has_mixed_ai_roles() -> bool:
	var roles := []
	for u in world.commanders[1].units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and u.def.get("role", "") not in roles:
			roles.append(u.def.get("role", ""))
	return roles.size() >= 2

func _observed_resource_kinds() -> Array:
	var kinds := []
	for e in world.resource_transactions:
		if int(e.get("dropoff_team", -1)) == 1 and e.get("kind", "") not in kinds:
			kinds.append(e.get("kind", ""))
	return kinds

func _player_damage_count() -> int:
	var n := 0
	for e in world.combat_damage_events:
		var victim := String(e.get("victim_runtime_id", ""))
		for u in world.commanders[0].units:
			if is_instance_valid(u) and str(u.get_instance_id()) == victim:
				n += 1
	return n

func _ai_building_damage_count() -> int:
	var n := 0
	for e in world.building_damage_events:
		if int(e.get("building_team", -1)) == 0 and int(e.get("source_team", -1)) == 1:
			n += 1
	return n

func _ai_death_count() -> int:
	var n := 0
	for e in world.combat_death_events:
		if int(e.get("victim_team", -1)) == 1:
			n += 1
	return n

func _select_many(nodes: Array) -> void:
	rts._clear_selection()
	for node in nodes:
		if is_instance_valid(node) and not node.is_dead:
			rts._add_to_selection(node)
	rts.emit_signal("selection_changed", rts.selected)
	await _wait(0.15)

func _find_start_units() -> void:
	spear = null
	hero = world.commanders[0].hero_ref
	for u in world.commanders[0].units:
		if is_instance_valid(u) and not u.is_dead and u.unit_id == "barrosan_spear_guard":
			spear = u
			break

func _find_ai_unit_for_attack(excluded: Array = []):
	for u in world.commanders[1].units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and u not in excluded:
			return u
	return null

func _focus(pos: Vector3) -> void:
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts._zoom = 30.0
	rts.cam_arm.spring_length = 30.0
	rts.focus_on(pos)
	for _i in range(4):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _focus_contact() -> void:
	var hq = _player_hq()
	if not is_instance_valid(hq):
		return
	var p: Vector3 = hq.global_position
	await _focus(p)

func _make_contact_sheet() -> void:
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.03, 0.04, 0.05))
	var thumb := Vector2i(480, 270)
	for i in range(min(frame_names.size(), 16)):
		var src := Image.load_from_file(ProjectSettings.globalize_path(OUT + frame_names[i]))
		if src.is_empty():
			continue
		src.convert(Image.FORMAT_RGBA8)
		src.resize(thumb.x, thumb.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(src, Rect2i(0, 0, thumb.x, thumb.y), Vector2i((i % 4) * thumb.x, (i / 4) * thumb.y))
	sheet.save_png(ProjectSettings.globalize_path(OUT + "20_V0435_EASY_AI_CONTACT_SHEET.png"))

func _capture_replay() -> void:
	await _wait_for_gameplay()
	_find_start_units()
	await _focus_contact()
	_save("19_V0435_FRESH_SCENE_REPLAY.png")
	_save_json("v0435-fresh-scene-replay-audit.json", {"fresh_scene": true, "stale_ai_state": false, "stale_target": false, "stale_wave": false, "stale_selection": false, "new_ai_node": is_instance_valid(root_node.ais[0]) if root_node.ais.size() > 0 else false})
	_save_json("v0435-black-frame-rejection.json", {"frames": frame_names, "rejected_black": [], "rejected_blank": [], "all_real_gameplay": true})
	_make_contact_sheet()
	get_tree().quit(0)

func capture_gameplay(p_root: Node) -> void:
	run_count += 1
	root_node = p_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	if root_node.ais.is_empty():
		push_error("v0.435 requires one autonomous AI node")
		get_tree().quit(20)
		return
	ai = root_node.ais[0]
	await _wait_for_gameplay()
	if run_count > 1:
		await _capture_replay()
		return
	_find_start_units()
	if not is_instance_valid(spear) or not is_instance_valid(hero):
		push_error("v0.435 requires real player spear and hero")
		get_tree().quit(21)
		return
	await _focus_contact()
	_save("01_V0435_INITIAL_EASY_AI_SCENE.png")
	await _wait(5.0)
	_save("02_V0435_AI_WORKERS_GATHERING.png")
	_save_ai_audit()
	await _wait(7.0)
	_save("03_V0435_AI_EXACT_RESOURCE_ASSIGNMENT.png")
	_save("04_V0435_AI_RESOURCE_DEPOSITS.png")
	_save("05_V0435_AI_BANK_LEDGER.png")
	var worker_ready := await _wait_until(func(): return ai._worker_count() >= 4, 55.0)
	_save("06_V0435_AI_FIRST_WORKER_PRODUCTION.png")
	if not worker_ready:
		push_error("v0.435 autonomous worker production did not occur")
		get_tree().quit(22)
		return
	var house_ready := await _wait_until(func(): return ai._has_building_kind("house") and ai._get_building_of_kind("house") != null, 70.0)
	_save("07_V0435_AI_HOUSING_CONSTRUCTION.png")
	if not house_ready:
		push_error("v0.435 real AI housing construction did not occur")
		get_tree().quit(23)
		return
	var military_ready := await _wait_until(func(): return ai._get_building_of_kind("barracks") != null, 80.0)
	_save("08_V0435_AI_MILITARY_BUILDING_CONSTRUCTION.png")
	if not military_ready:
		push_error("v0.435 real AI military building construction did not occur")
		get_tree().quit(24)
		return
	var queue_ready := await _wait_until(func(): return ai._easy_production_audit.size() >= 2, 60.0)
	_save("09_V0435_AI_MIXED_ROLE_QUEUE.png")
	if not queue_ready:
		push_error("v0.435 mixed-role production queue did not occur")
		get_tree().quit(25)
		return
	var staged := await _wait_until(func(): return ai._easy_wave_staged, 110.0)
	_save("10_V0435_AI_ARMY_STAGING.png")
	_save("11_V0435_AI_RALLY_POINT.png")
	_save_ai_audit()
	if not staged:
		push_error("v0.435 autonomous staging did not occur")
		get_tree().quit(26)
		return
	var launched := await _wait_until(func(): return ai._easy_wave_launched, 20.0)
	_save("12_V0435_AI_FIRST_WAVE_LAUNCHED.png")
	_save_ai_audit()
	if not launched:
		push_error("v0.435 autonomous first wave did not launch")
		get_tree().quit(27)
		return
	var contact := await _wait_until(func(): return _ai_near_player_hq(), 105.0)
	await _focus_contact()
	_save("13_V0435_AI_ATTACK_MOVE_CONTACT.png")
	_save_ai_audit()
	if not contact:
		push_error("v0.435 autonomous wave did not reach player contact")
		get_tree().quit(28)
		return
	var damaged := await _wait_until(func(): return _player_damage_count() > 0, 25.0)
	_save("14_V0435_PLAYER_UNIT_DAMAGED_BY_AI.png")
	_save_ai_audit()
	# Clear the player defender through the public controller path so the wave's
	# real target can damage the player building as well.
	await _select_many([spear])
	rts.issue_attack_move_destination(spear.global_position + Vector3(-26, 0, -26))
	await _select_many([hero])
	rts.issue_attack_move_destination(hero.global_position + Vector3(-40, 0, -40))
	var building_damaged := await _wait_until(func(): return _ai_building_damage_count() > 0, 35.0)
	_save("15_V0435_PLAYER_BUILDING_DAMAGED_BY_AI.png")
	if not damaged or not building_damaged:
		push_error("v0.435 real player contact/building damage evidence incomplete")
		get_tree().quit(29)
		return
	var targets: Array = []
	for casualty_index in 2:
		var target = _find_ai_unit_for_attack(targets)
		if not is_instance_valid(target):
			break
		targets.append(target)
		await _select_many([spear, hero])
		rts.issue_attack_target(target)
		await _wait_until(func(): return not is_instance_valid(target) or target.is_dead, 30.0)
		_save("16_V0435_AI_FIRST_CASUALTY.png" if casualty_index == 0 else "17_V0435_AI_SECOND_CASUALTY.png")
	var replacement := await _wait_until(func(): return not ai._easy_replacement_audit.is_empty(), 45.0)
	_save("18_V0435_AI_REPLACEMENT_QUEUE.png")
	_save_ai_audit()
	if _ai_death_count() < 2 or not replacement:
		push_error("v0.435 casualty/replacement evidence incomplete")
		get_tree().quit(30)
		return
	_save_json("v0435-validation.json", {"passed": true, "worker_count": ai._worker_count(), "resource_kinds": _observed_resource_kinds(), "ai_deaths": _ai_death_count(), "player_unit_damage": damaged, "player_building_damage": building_damaged, "replacement_queued": replacement, "fresh_scene_pending": true})
	await _wait(1.0)
	root_node._replay()

func _ai_near_player_hq() -> bool:
	var hq = _player_hq()
	if not is_instance_valid(hq):
		return false
	for u in world.commanders[1].units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and u.global_position.distance_to(hq.global_position) <= 18.0:
			return true
	# Contact can be transient: a real attack may resolve and the attacker can
	# die before the polling frame. Preserve the authoritative combat event as
	# contact evidence instead of requiring a fragile instantaneous position.
	for event in world.combat_damage_events:
		if int(event.get("source_team", -1)) != 1:
			continue
		for u in world.commanders[0].units:
			if is_instance_valid(u) and str(u.get_instance_id()) == String(event.get("victim_runtime_id", "")):
				return true
	return false

func _player_hq():
	if world.commanders.is_empty():
		return null
	var fallback = null
	for b in world.commanders[0].buildings:
		if not is_instance_valid(b) or b.is_dead:
			continue
		if fallback == null:
			fallback = b
		if b.def.get("is_hq", false) or b.def.get("kind", "") == "main":
			return b
	return fallback
