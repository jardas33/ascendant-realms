extends Control
## Tutorial — teaches core mechanics through gameplay with lightweight prompts
## that advance as the player performs each action.

var world = null
var rts = null

var _steps := []
var _step := 0
var _panel: Panel
var _label: Label
var _title: Label
var _check_timer := 0.0

func setup(p_world, p_rts) -> void:
	world = p_world
	rts = p_rts
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

	var skip := Button.new()
	skip.text = "Skip Tutorial"
	skip.mouse_filter = Control.MOUSE_FILTER_STOP
	skip.focus_mode = Control.FOCUS_NONE
	_panel.add_child(skip)
	skip.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	skip.offset_left = -132.0
	skip.offset_right = -12.0
	skip.offset_top = 10.0
	skip.offset_bottom = 44.0
	skip.pressed.connect(func(): queue_free())

	_build_steps()
	_show_step()

func _build_steps() -> void:
	_steps = [
		{"title": "Move the Camera", "text": "Use the ARROW KEYS or push the mouse to the screen edge to move the camera. Scroll the wheel to zoom.", "check": "camera"},
		{"title": "Select Units", "text": "Left-click a unit to select it, or drag a box to select many. Your units glow with your color when selected.", "check": "select"},
		{"title": "Gather Resources", "text": "Select a Worker and right-click a glowing resource pile (timber, stone or gold) to send them gathering.", "check": "gather"},
		{"title": "Build a Structure", "text": "With a Worker selected, use the command card (bottom-right) to place a building. Left-click to set its spot.", "check": "build"},
		{"title": "Train an Army", "text": "Select a military building and click a unit to train it. Watch your population (top bar) — build houses for more.", "check": "train"},
		{"title": "Command Your Hero", "text": "Press SPACE to jump to your Hero. Move them into battle and unlock abilities on the Hero screen between fights.", "check": "hero"},
		{"title": "Attack the Enemy", "text": "Press A then click the ground for an attack-move, or right-click an enemy directly. Destroy their base to win!", "check": "combat"},
		{"title": "Claim the Lume", "text": "Send units to the glowing Lume Spire in the center. Holding strategic sites gives you gold and power. Good luck, Commander!", "check": "final"},
	]

func _show_step() -> void:
	if _step >= _steps.size():
		queue_free()
		return
	var s = _steps[_step]
	_title.text = "Step %d/%d: %s" % [_step + 1, _steps.size(), s["title"]]
	_label.text = s["text"]

func _process(delta: float) -> void:
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
	_step += 1
	Sfx.play("ready", -8.0)
	_show_step()

func _check_condition(cond: String) -> bool:
	match cond:
		"camera":
			return world.match_time > 4.0
		"select":
			return rts.selected.size() > 0
		"gather":
			for u in world.player_commander.units:
				if is_instance_valid(u) and u.is_worker and u.state == u.State.GATHERING:
					return true
			return false
		"build":
			for b in world.player_commander.buildings:
				if is_instance_valid(b) and not b.def.get("is_hq", false):
					return true
			return false
		"train":
			for b in world.player_commander.buildings:
				if is_instance_valid(b) and b.queue.size() > 0:
					return true
			# or army grew
			return _army_count() > 1
		"hero":
			var h = world.player_commander.hero_ref
			return is_instance_valid(h) and rts.selected.has(h)
		"combat":
			return world.kills_by_player > 0
		"final":
			return world.match_time > 8.0 or world.kills_by_player > 2
	return false

func _army_count() -> int:
	var n := 0
	for u in world.player_commander.units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker and not u.is_hero:
			n += 1
	return n
