extends RefCounted
## Battle keys the player can change in Settings. The bindings live in the
## engine's InputMap; the ones that differ from the defaults are saved in the
## profile settings under "keybinds" (action -> physical keycode).
##
## Use through a preload:
##   const KeyBinds := preload("res://scripts/game/key_binds.gd")

## Spells that have a button but no action in project.godot.
const EXTRA := {"ability_5": KEY_Y, "ability_6": KEY_U, "ability_7": KEY_V,
	"ability_sig": KEY_B, "ability_p1": KEY_N, "ability_p2": KEY_M}

## What can be rebound, in the order Settings lists it: [group, [[action, name], ...]].
const ACTIONS := [
	["ORDERS", [["cmd_attack", "Attack-move"], ["cmd_stop", "Stop"], ["cmd_hold", "Hold position"], ["cmd_patrol", "Patrol"]]],
	["SELECTION", [["select_army", "Select the army"], ["idle_worker", "Next idle worker"], ["cycle_hero", "Focus the hero"]]],
	["HERO SPELLS", [["ability_1", "Rallying Cry"], ["ability_2", "Ground Slam"], ["ability_3", "Charge"], ["ability_4", "Lume Bolt"],
		["ability_5", "Heal Wave"], ["ability_6", "Entangling Roots"], ["ability_7", "Avatar of War"],
		["ability_sig", "Signature spell"], ["ability_p1", "People spell (level 10)"], ["ability_p2", "People spell (level 25)"]]],
	["CAMERA", [["cam_rot_l", "Rotate left"], ["cam_rot_r", "Rotate right"]]],
]

## Keys with a fixed job: menus, control groups, camera movement, modifiers.
const RESERVED := [KEY_ESCAPE, KEY_F1, KEY_F3, KEY_BACKSPACE, KEY_ENTER, KEY_KP_ENTER,
	KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9,
	KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT,
	KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META, KEY_CAPSLOCK, KEY_PRINT]

static var _defaults := {}   # action -> physical keycode, as shipped

## Registers the extra spell actions and remembers the shipped keys. Safe to
## call any number of times.
static func ensure_actions() -> void:
	for action in EXTRA:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var ev := InputEventKey.new()
			ev.physical_keycode = EXTRA[action]
			InputMap.action_add_event(action, ev)
	if _defaults.is_empty():
		for group in ACTIONS:
			for entry in group[1]:
				_defaults[String(entry[0])] = key_of(String(entry[0]))

## The physical keycode bound to `action` (0 if none).
static func key_of(action: String) -> int:
	if not InputMap.has_action(action):
		return 0
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return int(ev.physical_keycode) if int(ev.physical_keycode) != 0 else int(ev.keycode)
	return 0

## The key's name as shown on buttons and in help text ("J", "SPACE", "TAB").
static func label(action: String) -> String:
	ensure_actions()
	var code := key_of(action)
	return OS.get_keycode_string(code).to_upper() if code != 0 else ""

static func default_of(action: String) -> int:
	ensure_actions()
	return int(_defaults.get(action, 0))

static func is_reserved(code: int) -> bool:
	return RESERVED.has(code)

static func _set_key(action: String, code: int) -> void:
	if not InputMap.has_action(action) or code == 0:
		return
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			InputMap.action_erase_event(action, ev)
	var fresh := InputEventKey.new()
	fresh.physical_keycode = code
	InputMap.action_add_event(action, fresh)

## Applies the saved bindings over the shipped ones (at startup, and after a reset).
static func apply(saved: Dictionary) -> void:
	ensure_actions()
	for action in _defaults:
		var code := int(saved.get(action, _defaults[action]))
		if code == 0 or is_reserved(code):
			code = int(_defaults[action])
		_set_key(action, code)

## Binds `action` to `code`. If another action held that key, the two swap,
## and that action's name is returned ("" otherwise).
static func rebind(action: String, code: int) -> String:
	ensure_actions()
	if not _defaults.has(action) or code == 0 or is_reserved(code):
		return ""
	var old := key_of(action)
	var other := ""
	for a in _defaults:
		if a != action and key_of(a) == code:
			other = a
	_set_key(action, code)
	if other != "":
		_set_key(other, old)
	return other

## The bindings that differ from the shipped ones, for the profile.
static func saved() -> Dictionary:
	ensure_actions()
	var out := {}
	for action in _defaults:
		if key_of(action) != int(_defaults[action]):
			out[action] = key_of(action)
	return out

static func reset() -> void:
	apply({})

## The display name of an action ("Attack-move"), for messages.
static func name_of(action: String) -> String:
	for group in ACTIONS:
		for entry in group[1]:
			if String(entry[0]) == action:
				return String(entry[1])
	return action

## Help text carries its keys as tokens ("Press {cmd_attack}, then click"):
## this fills them with the keys bound right now.
static func fill(text: String) -> String:
	if not text.contains("{"):
		return text
	ensure_actions()
	for action in _defaults:
		text = text.replace("{%s}" % action, label(action))
	return text
