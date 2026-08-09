extends Control
## Tutorial — teaches core mechanics through gameplay with lightweight prompts
## that advance as the player performs each action.

signal step_changed(snapshot: Dictionary)

var world = null
var rts = null

var _steps := []
var _step := 0
var _panel: Panel
var _label: Label
var _title: Label
var _skip_button: Button
var _check_timer := 0.0
var _completed := false
var _camera_origin := Vector3.ZERO
var _camera_seen := false
var _selection_seen := false
var _resource_extraction_baseline := 0
var _construction_baseline := 0
var _army_baseline := 0
var _combat_damage_baseline := 0
var _hero_origin := Vector3.ZERO
var _hero_command_seen := false
var _lume_point = null
var _transition_log: Array = []

func setup(p_world, p_rts) -> void:
	world = p_world
	rts = p_rts
	_camera_origin = rts.cam_pivot.global_position if is_instance_valid(rts.cam_pivot) else Vector3.ZERO
	_resource_extraction_baseline = world.resource_extractions.size()
	_construction_baseline = int(world.get_v0431_construction_audit().get("completed_count", 0))
	_combat_damage_baseline = world.combat_damage_events.size()
	_army_baseline = _army_count()
	for point in world.get_tree().get_nodes_in_group("capture_points"):
		if is_instance_valid(point):
			_lume_point = point
			break
	if rts.has_signal("selection_changed"):
		rts.selection_changed.connect(_on_selection_changed)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_panel = Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.06, 0.085, 0.94)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.62, 0.5, 0.28, 0.95)
	sb.set_corner_radius_all(8)
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 6
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)
	# top-center band, explicit anchors + offsets (never a hand position on an anchored node)
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.0
	_panel.anchor_bottom = 0.0
	_panel.offset_left = -360.0
	_panel.offset_right = 360.0
	_panel.offset_top = 68.0
	_panel.offset_bottom = 196.0

	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(vb)
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 22; vb.offset_right = -150; vb.offset_top = 12; vb.offset_bottom = -12
	vb.add_theme_constant_override("separation", 6)

	var font = load("res://assets/fonts/cinzel.ttf") if ResourceLoader.exists("res://assets/fonts/cinzel.ttf") else null

	_title = Label.new()
	if font: _title.add_theme_font_override("font", font)
	_title.add_theme_font_size_override("font_size", 24)
	_title.add_theme_color_override("font_color", Color(0.98, 0.88, 0.58))
	_title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_title.add_theme_constant_override("outline_size", 4)
	vb.add_child(_title)

	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_color_override("font_color", Color(0.96, 0.94, 0.88))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("outline_size", 3)
	_label.add_theme_font_size_override("font_size", 18)
	_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(_label)

	_skip_button = Button.new()
	_skip_button.text = "Skip Tutorial"
	_skip_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_skip_button.focus_mode = Control.FOCUS_NONE
	_panel.add_child(_skip_button)
	_skip_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_skip_button.offset_left = -132.0
	_skip_button.offset_right = -12.0
	_skip_button.offset_top = 10.0
	_skip_button.offset_bottom = 44.0
	_skip_button.pressed.connect(_on_skip_or_return)

	_build_steps()
	_show_step()

func _build_steps() -> void:
	_steps = [
		{"id": "camera", "title": "Move the Camera", "text": "Use the ARROW KEYS or push the mouse to the screen edge to move the camera. Scroll the wheel to zoom.", "success": "The camera focus moves to a new position.", "check": "camera"},
		{"id": "select", "title": "Select Units", "text": "Left-click a unit to select it, or drag a box to select many. Your units glow with your color when selected.", "success": "A player-owned unit is selected.", "check": "select"},
		{"id": "gather", "title": "Gather Resources", "text": "Select a Worker and right-click a glowing resource pile (timber, stone or gold) to send them gathering.", "success": "A worker extracts a real resource from the node.", "check": "gather"},
		{"id": "build", "title": "Build a Structure", "text": "With a Worker selected, use the command card (bottom-right) to place a building. Left-click to set its spot.", "success": "The placed structure finishes construction.", "check": "build"},
		{"id": "train", "title": "Train an Army", "text": "Select a military building and click a unit to train it. Watch your population (top bar) — build houses for more.", "success": "A newly queued military unit completes training.", "check": "train"},
		{"id": "hero", "title": "Command Your Hero", "text": "Press SPACE to jump to your Hero. Move them into battle and unlock abilities on the Hero screen between fights.", "success": "Your selected hero receives a real move order and changes position.", "check": "hero"},
		{"id": "combat", "title": "Attack the Enemy", "text": "Press A then click the ground for an attack-move, or right-click an enemy directly. Destroy their base to win!", "success": "A real player attack deals combat damage to an enemy.", "check": "combat"},
		{"id": "final", "title": "Claim the Lume", "text": "Send units to the glowing Lume Spire in the center. Holding strategic sites gives you gold and power. Good luck, Commander!", "success": "Your units enter the site, capture progress completes, and the Lume becomes yours.", "check": "final"},
	]

func _show_step() -> void:
	if _completed:
		_title.text = "Tutorial Complete"
		_label.text = "You have learned the core battlefield loop. Your Lume claim was recorded through normal gameplay."
		_skip_button.text = "Return to Main Menu"
		return
	var s = _steps[_step]
	_title.text = "Step %d/%d: %s" % [_step + 1, _steps.size(), s["title"]]
	_label.text = "%s\n\nSuccess when: %s" % [s["text"], s["success"]]
	if s["check"] == "hero":
		var hero = world.player_commander.hero_ref
		_hero_origin = hero.global_position if is_instance_valid(hero) else Vector3.ZERO
		_hero_command_seen = false
	if s["check"] == "combat":
		_combat_damage_baseline = world.combat_damage_events.size()
	step_changed.emit(get_state_snapshot())

func _process(delta: float) -> void:
	if _completed:
		return
	_check_timer += delta
	if _check_timer < 0.5:
		return
	_check_timer = 0.0
	if _step >= _steps.size():
		return
	if _check_condition(_steps[_step]["check"]):
		_advance()

var _seen_selection := false
func _advance() -> void:
	_transition_log.append({"from_step": _step + 1, "to_step": _step + 2, "timestamp_ms": Time.get_ticks_msec(), "state": get_state_snapshot()})
	_step += 1
	Sfx.play("ready", -8.0)
	if _step >= _steps.size():
		_completed = true
		_show_step()
	else:
		_show_step()

func _on_selection_changed(units: Array) -> void:
	if _step >= _steps.size():
		return
	for unit in units:
		if is_instance_valid(unit) and int(unit.team) == int(world.player_commander.team):
			_selection_seen = true
			return

func _on_skip_or_return() -> void:
	if _completed:
		Match.set_config(Match.default_config())
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	else:
		queue_free()

func get_state_snapshot() -> Dictionary:
	var current: Dictionary = {}
	if _step < _steps.size():
		current = _steps[_step]
	return {
		"active": is_inside_tree(),
		"step_index": _steps.size() + 1 if _completed else min(_step + 1, _steps.size()),
		"step_id": "complete" if _completed else String(current.get("id", "")),
		"step_title": "Tutorial Complete" if _completed else String(current.get("title", "")),
		"instruction": "You have learned the core battlefield loop." if _completed else String(current.get("text", "")),
		"success_description": "Completion visible; return to the main menu." if _completed else String(current.get("success", "")),
		"completed": _completed,
		"completion_visible": _completed and is_instance_valid(_panel),
		"transitions": _transition_log.duplicate(true),
	}

func get_completion_button() -> Button:
	return _skip_button if _completed and is_instance_valid(_skip_button) else null

func _check_condition(cond: String) -> bool:
	match cond:
		"camera":
			_camera_seen = is_instance_valid(rts.cam_pivot) and rts.cam_pivot.global_position.distance_to(_camera_origin) > 2.0
			return _camera_seen
		"select":
			return _selection_seen
		"gather":
			return world.resource_extractions.size() > _resource_extraction_baseline
		"build":
			return int(world.get_v0431_construction_audit().get("completed_count", 0)) > _construction_baseline
		"train":
			return _army_count() > _army_baseline
		"hero":
			var h = world.player_commander.hero_ref
			if not is_instance_valid(h) or not rts.selected.has(h):
				return false
			_hero_command_seen = h.global_position.distance_to(_hero_origin) > 2.0
			return _hero_command_seen
		"combat":
			return world.combat_damage_events.size() > _combat_damage_baseline
		"final":
			return is_instance_valid(_lume_point) and int(_lume_point.owner_team) == int(world.player_commander.team)
	return false

func _army_count() -> int:
	var n := 0
	for u in world.player_commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
			n += 1
	return n
