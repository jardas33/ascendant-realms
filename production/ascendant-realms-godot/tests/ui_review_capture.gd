extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var size_text := OS.get_environment("ASCENDANT_UI_SIZE")
	if not size_text.is_empty():
		var parts := size_text.split("x")
		if parts.size() == 2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(int(parts[0]), int(parts[1])))
	var map_id := OS.get_environment("ASCENDANT_UI_MAP")
	if not map_id.is_empty():
		root.get_node("Match").set_config({
			"player_race": "barrosan",
			"opponents": [{"race": "vorthak", "difficulty": "easy"}],
			"map": map_id,
			"start_resources": "standard",
			"victory": "conquest",
			"mode": "skirmish",
			"game_speed": 1.0,
		})
	var target := OS.get_environment("ASCENDANT_UI_SCENE")
	if target.is_empty():
		target = "res://scenes/game_world.tscn"
	var scene := load(target) as PackedScene
	if scene == null:
		push_error("Unable to load UI scene: " + target)
		quit(2)
		return
	var instance := scene.instantiate()
	root.add_child(instance)
	var frames := maxi(5, int(OS.get_environment("ASCENDANT_UI_FRAMES")))
	for index in frames:
		await process_frame
	# A capture is not a pass when a HUD dependency fails to compile and the
	# world quietly continues without the interface under review.
	if not is_instance_valid(instance.get("hud")) or not is_instance_valid(instance.hud._cmd_panel):
		push_error("UI_CAPTURE_HUD_MISSING_OR_INCOMPLETE")
		instance.queue_free()
		quit(3)
		return
	if OS.get_environment("ASCENDANT_UI_SELECT") == "hero" and instance.get("rts") != null:
		instance.rts._cycle_hero()
		for index in 5:
			await process_frame
	if OS.get_environment("ASCENDANT_UI_SELECT") == "worker" and instance.get("rts") != null:
		instance.rts._select_idle_worker()
		for index in 5:
			await process_frame
	if OS.get_environment("ASCENDANT_UI_SELECT") == "military" and instance.get("rts") != null:
		instance.rts._select_army()
		if not instance.rts.selected.is_empty():
			var first_unit = instance.rts.selected[0]
			instance.rts._clear_selection()
			instance.rts._add_to_selection(first_unit)
			instance.rts.selection_changed.emit(instance.rts.selected)
		for index in 5:
			await process_frame
	if OS.get_environment("ASCENDANT_UI_SELECT") == "group" and instance.get("rts") != null:
		instance.rts._select_army()
		for index in 5:
			await process_frame
	if OS.get_environment("ASCENDANT_UI_SELECT") in ["building", "war_hall", "construction"] and instance.get("rts") != null:
		var building = null
		if OS.get_environment("ASCENDANT_UI_SELECT") == "building":
			for candidate in instance.world.commanders[0].buildings:
				if is_instance_valid(candidate) and not candidate.is_dead and bool(candidate.def.get("is_hq", false)):
					building = candidate
					break
		else:
			var building_id := "barrosan_watchtower" if OS.get_environment("ASCENDANT_UI_SELECT") == "construction" else "barrosan_war_hall"
			var definition: Dictionary = root.get_node("GameData").get_building(building_id).duplicate()
			definition["id"] = building_id
			building = instance.world._create_building(definition, 0, Vector3(8, 0, 8), building_id != "barrosan_watchtower")
		if is_instance_valid(building):
			instance.rts._clear_selection()
			instance.rts._add_to_selection(building)
			instance.rts.selection_changed.emit(instance.rts.selected)
			if OS.get_environment("ASCENDANT_UI_SELECT") == "construction":
				building.build_progress = 0.5
				await create_timer(0.25).timeout
		for index in 5:
			await process_frame
	await RenderingServer.frame_post_draw
	var validation_errors: Array[String] = []
	if instance.get("hud") != null:
		var hud = instance.hud
		print("UI_COMMAND_CONTENT_SIZE ", hud._cmd_body.get_combined_minimum_size())
		for panel in [hud._minimap_panel, hud._sel_panel, hud._cmd_panel]:
			if is_instance_valid(panel):
				print("UI_PANEL ", panel.name, " visible=", panel.visible, " rect=", panel.get_global_rect(), " scale=", panel.scale, " offsets=", [panel.offset_left, panel.offset_top, panel.offset_right, panel.offset_bottom], " min=", panel.get_combined_minimum_size())
		for instrument in [hud._top_panel, hud._force_panel, hud._age_panel, hud._objective_panel, hud._menu_button, hud._faction_crest, hud._selection_portrait]:
			if is_instance_valid(instrument):
				print("UI_INSTRUMENT ", instrument.name, " rect=", instrument.get_global_rect())
		var objective = hud.find_child("MatchObjectiveLabel", true, false)
		if is_instance_valid(objective):
			print("UI_OBJECTIVE ", objective.text, " rect=", objective.get_global_rect())
		var command_names := []
		for button in hud._cmd_panel.find_children("*", "Button", true, false):
			if button.has_meta("command_kind"):
				command_names.append([button.get_meta("command_kind"), button.get_meta("command_status_label").text if button.has_meta("command_status_label") else "", button.get_global_rect()])
		print("UI_COMMAND_CARDS ", command_names)
		if OS.get_environment("ASCENDANT_UI_VALIDATE") == "1":
			var safe_rect := root.get_viewport().get_visible_rect()
			for panel in [hud._minimap_panel, hud._sel_panel, hud._cmd_panel]:
				if is_instance_valid(panel) and panel.visible and not safe_rect.encloses(panel.get_global_rect()):
					validation_errors.append("panel_outside_viewport:" + panel.name)
			for instrument in [hud._top_panel, hud._force_panel, hud._age_panel, hud._objective_panel, hud._menu_button, hud._faction_crest, hud._selection_portrait]:
				if is_instance_valid(instrument) and instrument.visible and not safe_rect.encloses(instrument.get_global_rect()):
					validation_errors.append("instrument_outside_viewport:" + instrument.name)
			if hud._top_panel.get_global_rect().intersects(hud._force_panel.get_global_rect()):
				validation_errors.append("top_economy_force_overlap")
			if hud._force_panel.get_global_rect().intersects(hud._age_panel.get_global_rect()):
				validation_errors.append("top_force_age_overlap")
			if hud._age_panel.get_global_rect().intersects(hud._objective_panel.get_global_rect()):
				validation_errors.append("top_age_objective_overlap")
			if hud._objective_panel.get_global_rect().intersects(hud._menu_button.get_global_rect()):
				validation_errors.append("top_objective_menu_overlap")
			if not is_instance_valid(objective) or not safe_rect.encloses(objective.get_global_rect()):
				validation_errors.append("objective_outside_viewport")
			if hud._sel_panel.get_global_rect().intersects(hud._cmd_panel.get_global_rect()):
				validation_errors.append("selection_command_overlap")
			if hud._minimap_panel.get_global_rect().intersects(hud._sel_panel.get_global_rect()):
				validation_errors.append("minimap_selection_overlap")
			var selected_kind := OS.get_environment("ASCENDANT_UI_SELECT")
			var expected_cards := 5 if selected_kind in ["hero", "worker"] else (4 if selected_kind == "military" else 0)
			var actual_cards := 0
			var card_kinds: Array[String] = []
			var card_copy := ""
			for button in hud._cmd_panel.find_children("*", "Button", true, false):
				if not button.has_meta("command_kind"):
					continue
				actual_cards += 1
				card_kinds.append(str(button.get_meta("command_kind")))
				if selected_kind != "war_hall" and not hud._cmd_panel.get_global_rect().encloses(button.get_global_rect()):
					validation_errors.append("card_outside_deck:" + str(actual_cards))
				if button.pressed.get_connections().is_empty():
					validation_errors.append("card_missing_command:" + str(actual_cards))
				for label in button.find_children("*", "Label", true, false):
					card_copy += label.text + " "
			if expected_cards > 0 and actual_cards != expected_cards:
				validation_errors.append("card_count:%d_expected_%d" % [actual_cards, expected_cards])
			if selected_kind == "building" and (not card_kinds.has("TRAIN") or not card_kinds.has("RESEARCH")):
				validation_errors.append("building_action_families_missing:" + str(card_kinds))
			if selected_kind == "war_hall" and not card_kinds.has("TRAIN"):
				validation_errors.append("war_hall_train_family_missing:" + str(card_kinds))
			if selected_kind == "war_hall":
				var deck_scroll := hud._cmd_panel.get_child(0) as ScrollContainer
				if deck_scroll == null or deck_scroll.get_v_scroll_bar().max_value <= deck_scroll.size.y:
					validation_errors.append("war_hall_overflow_not_scrollable")
			if selected_kind == "construction":
				var site = hud._cmd_panel.find_child("ConstructionProgress", true, false)
				if not is_instance_valid(site) or site.get_combined_minimum_size().y < 100.0:
					validation_errors.append("construction_site_surface_missing")
				elif absf(site.progress - 0.5) > 0.02:
					validation_errors.append("construction_progress_did_not_refresh")
			var expected_words: Array[String] = []
			if selected_kind == "hero":
				expected_words = ["Rallying Cry", "40 mana", "18s CD", "Attack Move", "Stop", "Hold", "Patrol"]
			elif selected_kind == "worker":
				expected_words = ["Clanhold", "Clan Croft", "War Hall", "Iron Forge", "Watchtower", "timber", "stone", "LOCKED", "READY"]
			elif selected_kind == "military":
				expected_words = ["Attack Move", "Stop", "Hold", "Patrol"]
			for word in expected_words:
				if not card_copy.contains(word):
					validation_errors.append("missing_card_copy:" + word)
			print("UI_VALIDATION ", "PASS" if validation_errors.is_empty() else "FAIL", " ", validation_errors)
	var output := OS.get_environment("ASCENDANT_UI_OUTPUT")
	if output.is_empty():
		output = "user://ui_review.png"
	var image := root.get_viewport().get_texture().get_image()
	var result := image.save_png(output)
	print("UI_CAPTURE ", target, " ", image.get_size(), " ", result, " ", output)
	if OS.get_environment("ASCENDANT_UI_VALIDATE") == "1" and instance.get("rts") != null and instance.get("hud") != null:
		var selected_kind := OS.get_environment("ASCENDANT_UI_SELECT")
		var expected_keys := {"cmd_attack": KEY_J, "cmd_stop": KEY_K, "cmd_hold": KEY_H, "cmd_patrol": KEY_P}
		for action in expected_keys:
			var bound := false
			for event in InputMap.action_get_events(action):
				if event is InputEventKey and event.physical_keycode == expected_keys[action]:
					bound = true
			if not bound:
				validation_errors.append("missing_hotkey:" + action)
		var card_by_title := {}
		for button in instance.hud._cmd_panel.find_children("*", "Button", true, false):
			if not button.has_meta("command_kind"):
				continue
			for label in button.find_children("*", "Label", true, false):
				if label.text in ["Attack Move", "Stop", "Hold", "Patrol", "Rallying Cry", "Clan Croft", "Advance to Age of Iron", "Clan Levy"]:
					card_by_title[label.text] = button
		if selected_kind in ["hero", "military"]:
			for title in ["Attack Move", "Stop", "Hold", "Patrol"]:
				if not card_by_title.has(title):
					validation_errors.append("missing_command_button:" + title)
			if validation_errors.is_empty():
				card_by_title["Attack Move"].pressed.emit()
				if not instance.rts._attack_move_mode:
					validation_errors.append("attack_move_button_did_not_activate")
				card_by_title["Stop"].pressed.emit()
				if instance.rts._attack_move_mode:
					validation_errors.append("stop_button_did_not_cancel_attack_move")
				card_by_title["Hold"].pressed.emit()
				card_by_title["Patrol"].pressed.emit()
				if not instance.rts._patrol_mode:
					validation_errors.append("patrol_button_did_not_activate")
				instance.rts.cancel_patrol_mode()
		if selected_kind == "hero" and card_by_title.has("Rallying Cry"):
			var hero = instance.rts.selected[0]
			var mana_before: float = float(hero.mana)
			card_by_title["Rallying Cry"].pressed.emit()
			if hero.mana >= mana_before or float(hero.ability_cd.get("rally", 0.0)) <= 0.0:
				validation_errors.append("rallying_cry_button_did_not_cast")
		if selected_kind == "worker" and card_by_title.has("Clan Croft"):
			card_by_title["Clan Croft"].pressed.emit()
			if instance.rts._build_id.is_empty():
				validation_errors.append("build_button_did_not_activate")
			instance.rts.cancel_build_mode()
		if selected_kind == "building" and card_by_title.has("Advance to Age of Iron"):
			card_by_title["Advance to Age of Iron"].pressed.emit()
			var selected_building = instance.rts.selected[0]
			if selected_building.queue.is_empty() or str(selected_building.queue[0].get("id", "")) != "advance_tier_2":
				validation_errors.append("research_button_did_not_queue_tech")
		if selected_kind == "war_hall" and card_by_title.has("Clan Levy"):
			card_by_title["Clan Levy"].pressed.emit()
			var selected_hall = instance.rts.selected[0]
			if selected_hall.queue.is_empty() or str(selected_hall.queue[0].get("id", "")) != "barrosan_clan_levy":
				validation_errors.append("train_button_did_not_queue_unit")
		var map_click := InputEventMouseButton.new()
		map_click.button_index = MOUSE_BUTTON_LEFT
		map_click.pressed = true
		map_click.position = instance.hud._minimap.size * Vector2(0.35, 0.65)
		instance.hud._on_minimap_input(map_click)
		var expected_focus := Vector2(-42.0, 42.0)
		var actual_focus := Vector2(instance.rts.cam_pivot.global_position.x, instance.rts.cam_pivot.global_position.z)
		if actual_focus.distance_to(expected_focus) > 2.0:
			validation_errors.append("minimap_click_did_not_focus_camera")
		print("UI_FUNCTIONAL ", "PASS" if validation_errors.is_empty() else "FAIL", " ", validation_errors)
	instance.queue_free()
	for index in 2:
		await process_frame
	quit(0 if result == OK and validation_errors.is_empty() else 3)
