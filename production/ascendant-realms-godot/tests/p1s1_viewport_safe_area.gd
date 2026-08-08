extends Node
## P1-S1 local-only viewport/safe-area probe and capture driver.
## It is inert unless ASCENDANT_P1S1_CAPTURE=1 is explicitly set.

const HudScript := preload("res://scripts/ui/hud.gd")

var _started := false

func _ready() -> void:
	if OS.get_environment("ASCENDANT_P1S1_CAPTURE") != "1":
		return
	if _started:
		return
	_started = true
	call_deferred("_run")


func _run() -> void:
	var kind := OS.get_environment("ASCENDANT_P1S1_CAPTURE_KIND")
	var requested_width := int(OS.get_environment("ASCENDANT_P1S1_WIDTH"))
	var requested_height := int(OS.get_environment("ASCENDANT_P1S1_HEIGHT"))
	if requested_width > 0 and requested_height > 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(requested_width, requested_height))
		await get_tree().process_frame
		await get_tree().process_frame
	if kind == "menu":
		await get_tree().create_timer(1.0).timeout
		_capture(kind)
		return

	var match_config = get_node("/root/Match")
	match_config.set_config(match_config.default_config())
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(1.5).timeout

	var root := get_tree().current_scene
	if kind == "live_selected_unit" and root != null and root.get("rts") != null:
		var units: Array = root.world.all_units()
		for unit in units:
			if is_instance_valid(unit) and not unit.is_dead and unit.team == 0:
				root.rts._clear_selection()
				root.rts._add_to_selection(unit)
				root.rts.emit_signal("selection_changed", root.rts.selected)
				break
		await get_tree().process_frame
		await get_tree().process_frame

	_capture(kind)


func _rect_data(control: Control, viewport_rect: Rect2, scale: Vector2) -> Dictionary:
	if not is_instance_valid(control):
		return {"visible": false, "inside": true, "rect": {}}
	var logical_rect := control.get_global_rect()
	var rect := Rect2(logical_rect.position * scale, logical_rect.size * scale)
	return {
		"visible": control.visible,
		"inside": not control.visible or viewport_rect.encloses(rect),
		"rect": {"x": rect.position.x, "y": rect.position.y, "width": rect.size.x, "height": rect.size.y},
	}


func _geometry(root, image_size: Vector2i = Vector2i.ZERO) -> Dictionary:
	var logical_viewport := get_viewport().get_visible_rect()
	var physical_size := image_size if image_size != Vector2i.ZERO else DisplayServer.window_get_size()
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(physical_size))
	var scale := Vector2(
		physical_size.x / maxf(1.0, logical_viewport.size.x),
		physical_size.y / maxf(1.0, logical_viewport.size.y))
	var hud = root.get_node_or_null("HUDLayer").get_child(0) if root != null and root.get_node_or_null("HUDLayer") != null else null
	var surfaces := {}
	if hud != null:
		surfaces = {
			"top_resource_bar": _rect_data(hud.get("_top_panel"), viewport_rect, scale),
			"menu_button": _rect_data(hud.get("_menu_button"), viewport_rect, scale),
			"minimap_panel": _rect_data(hud.get("_minimap_panel"), viewport_rect, scale),
			"selection_panel": _rect_data(hud.get("_sel_panel"), viewport_rect, scale),
			"command_panel": _rect_data(hud.get("_cmd_panel"), viewport_rect, scale),
			"result_surface": _rect_data(hud.get("_gameover_layer"), viewport_rect, scale),
		}
	return {
		"requested_viewport": {"width": int(OS.get_environment("ASCENDANT_P1S1_WIDTH")), "height": int(OS.get_environment("ASCENDANT_P1S1_HEIGHT"))},
		"actual_viewport": {"width": physical_size.x, "height": physical_size.y},
		"logical_viewport": {"width": logical_viewport.size.x, "height": logical_viewport.size.y},
		"window_size": {"width": DisplayServer.window_get_size().x, "height": DisplayServer.window_get_size().y},
		"window_mode": DisplayServer.window_get_mode(),
		"scale": {"x": scale.x, "y": scale.y},
		"surfaces": surfaces,
		"all_visible_surfaces_inside": _all_inside(surfaces),
	}


func _all_inside(surfaces: Dictionary) -> bool:
	for item in surfaces.values():
		if item.get("visible", false) and not item.get("inside", false):
			return false
	return true


func _capture(kind: String) -> void:
	var output := OS.get_environment("ASCENDANT_P1S1_OUTPUT")
	if output.is_empty():
		get_tree().quit(2)
		return
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		get_tree().quit(3)
		return
	var png_path := output + ".png"
	var json_path := output + ".json"
	image.save_png(png_path)
	var payload := _geometry(get_tree().current_scene, Vector2i(image.get_width(), image.get_height()))
	payload["capture_kind"] = kind
	payload["image_width"] = image.get_width()
	payload["image_height"] = image.get_height()
	payload["image_path"] = png_path
	var file := FileAccess.open(json_path, FileAccess.WRITE)
	if file == null:
		get_tree().quit(4)
		return
	file.store_string(JSON.stringify(payload, "  "))
	file.close()
	get_tree().quit(0)
