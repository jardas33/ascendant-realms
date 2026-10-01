extends Control
## Tutorial — teaches core mechanics through gameplay with lightweight prompts
## that advance as the player performs each action.

signal step_changed(snapshot: Dictionary)

var world = null
var rts = null

var _steps := []
var _step := 0
var _panel: Panel
var _dots: Control
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
	_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# The lesson sits on the same gilt plate as the menus.
	var plate: PanelContainer = load("res://scripts/ui/hero_sheet_plate.gd").new()
	plate.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	plate.surface_alpha = 0.95
	plate.surface_alpha_bottom = 0.9
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(plate)
	plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Progress along the lesson: a row of diamonds along the bottom edge,
	# gold for steps done, a glowing one for the step at hand.
	_dots = Control.new()
	_dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dots.draw.connect(func():
		if _steps.is_empty():
			return
		var n := _steps.size()
		var gap := 18.0
		var x0 := _dots.size.x * 0.5 - (n - 1) * gap * 0.5
		var y := _dots.size.y - 1.0
		for k in n:
			var c := Vector2(x0 + k * gap, y)
			var d := 6.0 if k == _step else 4.5
			var col := Color(0.98, 0.84, 0.46) if k < _step else (Color(1.0, 0.92, 0.6) if k == _step else Color(0.3, 0.32, 0.36))
			_dots.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), col)
			if k == _step:
				_dots.draw_arc(c, d + 4.0, 0.0, TAU, 16, Color(1.0, 0.9, 0.55, 0.5), 1.2, true))
	_panel.add_child(_dots)
	_dots.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.resized.connect(_dots.queue_redraw)
	add_child(_panel)
	# top-center band, explicit anchors + offsets (never a hand position on an anchored node)
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.0
	_panel.anchor_bottom = 0.0
	_panel.offset_left = -360.0
	_panel.offset_right = 360.0
	# Below the top metric row: at 68 px the panel covered Population,
	# Opponents and the idle counts that the steps talk about.
	_panel.offset_top = 118.0
	_panel.offset_bottom = 290.0

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
	vb.add_child(_label)

	_success = Label.new()
	_success.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_success.add_theme_color_override("font_color", Color(0.93, 0.78, 0.45))
	_success.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_success.add_theme_constant_override("outline_size", 3)
	_success.add_theme_font_size_override("font_size", 15)
	vb.add_child(_success)
	_vb = vb

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

var _success: Label
var _vb: VBoxContainer

## Grow the panel to fit the step text; the fixed height let long steps
## spill the goal line out below the panel.
func _fit_panel() -> void:
	if not is_instance_valid(_vb):
		return
	var h := 24.0
	for child in _vb.get_children():
		if child is Label:
			var l := child as Label
			var lines := maxi(1, l.get_line_count()) if l.text != "" else 0
			h += lines * (l.get_line_height() + 1) + 6
	_panel.offset_bottom = _panel.offset_top + maxf(110.0, h)

func _build_steps() -> void:
	_steps = [
		{"id": "camera", "title": "Move the Camera", "text": "Use the ARROW KEYS or push the mouse to the screen edge to move the camera. Scroll the wheel to zoom.", "success": "The camera focus moves to a new position.", "check": "camera"},
		{"id": "select", "title": "Select Units", "text": "Left-click a unit to select it, or drag a box to select many. Hold Shift while clicking or dragging to add units. Press Tab to select your army. Your units glow with your color when selected.", "success": "A player-owned unit is selected.", "check": "select"},
		{"id": "gather", "title": "Gather Resources", "text": "Select a Worker and right-click a resource (food, timber, stone or gold) to send them gathering.", "success": "A worker extracts a real resource from the node.", "check": "gather"},
		{"id": "build", "title": "Build a Structure", "text": "With a Worker selected, use the command card (bottom-right) to place a building. Left-click to set its spot. Right-click to cancel build mode.", "success": "The placed structure finishes construction.", "check": "build"},
		{"id": "train", "title": "Train an Army", "text": "Select a military building and click a unit to train it. Watch your population (top bar) — build houses for more.", "success": "A newly queued military unit completes training.", "check": "train"},
		{"id": "vein", "title": "Claim a Vein", "text": "Veins glow between the bases. Select Workers and right-click a vein's ring to raise an outpost. When it is built, right-click it with Workers: they go inside and gather in safety.", "success": "You claimed a vein.", "check": "vein"},
		{"id": "hero", "title": "Command Your Hero", "text": "Press SPACE to focus your Hero. Move them into battle and press B for your people's signature spell. More spells come with levels and the skill constellation.", "success": "Your selected hero receives a real move order and changes position.", "check": "hero"},
		{"id": "combat", "title": "Attack the Enemy", "text": "Press J, then click the ground, for an attack-move, or right-click an enemy directly. Destroy their base to win!", "success": "A real player attack deals combat damage to an enemy.", "check": "combat"},
		{"id": "final", "title": "Claim the Lume", "text": "Send units to the glowing Lume Spire in the center. Holding strategic sites gives you gold and power. Good luck, Commander!", "success": "Your units enter the site, capture progress completes, and the Lume becomes yours.", "check": "final"},
	]

func _show_step() -> void:
	if _completed:
		_title.text = "Tutorial Complete"
		_label.text = "You have learned the core battlefield loop. Your Lume claim was recorded through normal gameplay."
		if _success: _success.text = ""
		_fit_panel.call_deferred()
		_skip_button.text = "Return to Main Menu"
		return
	if is_instance_valid(_dots):
		_dots.queue_redraw()
	var s = _steps[_step]
	_title.text = "Step %d/%d: %s" % [_step + 1, _steps.size(), s["title"]]
	_label.text = String(s["text"])
	_success.text = "Goal: " + String(s["success"])
	_fit_panel.call_deferred()
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
	_panel.queue_redraw()
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
		"vein":
			for b in world.player_commander.buildings:
				if is_instance_valid(b) and bool(b.def.get("vein_outpost", false)):
					return true
			return false
		"final":
			return is_instance_valid(_lume_point) and int(_lume_point.owner_team) == int(world.player_commander.team)
	return false

func _army_count() -> int:
	var n := 0
	for u in world.player_commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
			n += 1
	return n
