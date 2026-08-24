extends Control
## Campaign Map — "The Border Marches", six connected battles across a branching path.
## Unlocked nodes are playable; locked ones are greyed. Clicking marches to war.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG   := "res://assets/textures/backgrounds/main_menu_bg.png"
const THEME_PATH := "res://assets/ui/theme.tres"

# --- Campaign node definitions ------------------------------------------------
# Each entry: name, description, difficulty label, opponent list
const NODE_NAMES := [
	"Ashfen Crossing",
	"Verdant Hollow",
	"Emberfall Pass",
	"Frostmere Vale",
	"The Sunken Necropolis",
	"The Sundered Keep",
]

const NODE_DESC := [
	"A lone Vorthak warband tests your borders. An easy first march through the boggy lowlands.",
	"The Lioraen Concord contests the sacred groves. A measured fight among ancient trees.",
	"Grimtusk orcs hold the mountain pass with iron discipline. Expect a hard-fought siege.",
	"The Frostborn have claimed the frozen vale and will not yield it without blood.",
	"Something stirs beneath the ruins — Hollow undead rise alongside a warlord's remnant host.",
	"Two rival armies converge on the Sundered Keep. A brutal final stand on broken stone.",
]

const NODE_DIFFICULTY := ["Easy", "Normal", "Hard", "Hard", "Hard", "Brutal"]

# Battlefield each campaign node is fought on (ids from MapDefs), themed to match
# the story beat: boggy lowlands, sacred groves, mountain pass, frozen vale,
# haunted ruins, broken keep.
const CAMPAIGN_MAPS := ["mirefen", "verdant_hollows", "emberfall_rift", "frostmere_basin", "ruins_of_vael", "crucible"]

# Opponent configurations per node — race ids must match what game uses
const NODE_OPPONENTS := [
	[{"race": "vorthak",  "difficulty": "easy"}],
	[{"race": "lioraen",  "difficulty": "normal"}],
	[{"race": "grimtusk", "difficulty": "hard"}],
	[{"race": "frostborn","difficulty": "hard"}],
	[{"race": "hollow",   "difficulty": "hard"}, {"race": "karak", "difficulty": "normal"}],
	[{"race": "vorthak",  "difficulty": "brutal"}, {"race": "grimtusk", "difficulty": "brutal"}],
]

# Difficulty label colours
const DIFF_COLORS := {
	"Easy":   Color(0.4, 0.85, 0.45),
	"Normal": Color(0.7, 0.85, 0.3),
	"Hard":   Color(0.95, 0.6, 0.2),
	"Brutal": Color(0.95, 0.25, 0.2),
}

# Node positions as fractions of viewport size (x_frac, y_frac)
# Forms a winding path left-to-right across the map
const NODE_POS_FRAC := [
	Vector2(0.20, 0.60),
	Vector2(0.34, 0.38),
	Vector2(0.49, 0.55),
	Vector2(0.63, 0.32),
	Vector2(0.76, 0.54),
	Vector2(0.88, 0.38),
]

const NODE_SIZE := Vector2(230, 110)

# --- State -------------------------------------------------------------------
var _canvas: Control
var _desc_label: Label
var _node_positions: Array[Vector2] = []

# --------------------------------------------------------------------------
func _ready() -> void:
	_build()

func _title_font() -> Font:
	if ResourceLoader.exists(FONT):
		return load(FONT)
	return ThemeDB.fallback_font

func _hero_race() -> String:
	var h: Dictionary = ProfileManager.hero()
	if h.is_empty():
		return "barrosan"
	return str(h.get("race", "barrosan"))

# --------------------------------------------------------------------------
func _build() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	if vp_size == Vector2.ZERO:
		vp_size = Vector2(1280, 720)

	# Compute actual pixel positions from fractions
	_node_positions.clear()
	for frac in NODE_POS_FRAC:
		_node_positions.append(Vector2(frac.x * vp_size.x, frac.y * vp_size.y))

	# Background
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if ResourceLoader.exists(BG):
		bg.texture = load(BG)
	add_child(bg)

	# Dark scrim for readability
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.07, 0.65)
	add_child(scrim)

	# Title
	var title := Label.new()
	title.text = "The Border Marches"
	title.add_theme_font_override("font", _title_font())
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.97, 0.92, 0.68))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override("outline_size", 4)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 14.0
	title.offset_bottom = 68.0
	add_child(title)

	# Hero banner
	var banner := Label.new()
	var h: Dictionary = ProfileManager.hero()
	if h.is_empty():
		banner.text = "No hero yet — create one from the main menu"
	else:
		var race_name: String = str(GameData.get_race(_hero_race()).get("name", _hero_race()))
		banner.text = "%s  —  %s, Level %d" % [
			str(h.get("name", "Hero")),
			race_name,
			int(h.get("level", 1))
		]
	banner.add_theme_font_override("font", _title_font())
	banner.add_theme_font_size_override("font_size", 17)
	banner.add_theme_color_override("font_color", Color(0.85, 0.78, 0.5))
	banner.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	banner.add_theme_constant_override("outline_size", 3)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	banner.offset_top = 70.0
	banner.offset_bottom = 102.0
	add_child(banner)

	# Canvas node for drawing connecting lines (drawn under buttons)
	_canvas = Control.new()
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_path)
	add_child(_canvas)

	# Read campaign state (self-healed by ProfileManager.campaign())
	var camp: Dictionary = ProfileManager.campaign()

	# Build node buttons
	for i in NODE_NAMES.size():
		_build_node(i, camp)

	# Description panel at bottom
	var desc_panel := Panel.new()
	desc_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	# Keep enough vertical room for the title/difficulty line plus the wrapped
	# story line at the supported 16 px presentation size.
	desc_panel.offset_top = -128.0
	desc_panel.offset_bottom = -70.0
	desc_panel.offset_left = 180.0
	desc_panel.offset_right = -180.0
	if ResourceLoader.exists(THEME_PATH):
		desc_panel.theme = load(THEME_PATH)
	add_child(desc_panel)

	_desc_label = Label.new()
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.add_theme_font_override("font", _title_font())
	_desc_label.add_theme_font_size_override("font_size", 16)
	_desc_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.78))
	_desc_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	_desc_label.add_theme_constant_override("outline_size", 2)
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_desc_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_desc_label.offset_left = 12.0
	_desc_label.offset_right = -12.0
	_desc_label.text = "Hover over a region to read its story."
	desc_panel.add_child(_desc_label)

	# Back button
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(190, 50)
	back.focus_mode = Control.FOCUS_NONE
	if ResourceLoader.exists(THEME_PATH):
		back.theme = load(THEME_PATH)
	back.add_theme_font_override("font", _title_font())
	back.add_theme_font_size_override("font_size", 20)
	back.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	back.offset_left = 36.0
	back.offset_top = -66.0
	back.offset_bottom = -16.0
	back.offset_right = 226.0
	back.pressed.connect(_on_back_pressed)
	add_child(back)

# --------------------------------------------------------------------------
func _build_node(i: int, camp: Dictionary) -> void:
	var unlocked_arr: Array = camp.get("unlocked", [0])
	var current_node: int = int(camp.get("node", 0))

	# Node 0 is always unlocked regardless of save state
	var is_unlocked: bool = (i == 0) or (i in unlocked_arr)
	# A node is "cleared" if the player has already beaten it (node index < campaign.node)
	var is_cleared: bool = i < current_node

	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = NODE_SIZE
	btn.size = NODE_SIZE
	btn.position = _node_positions[i] - NODE_SIZE * 0.5
	btn.disabled = not is_unlocked

	if ResourceLoader.exists(THEME_PATH):
		btn.theme = load(THEME_PATH)

	# VBox for node contents
	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 8.0
	vb.offset_right = -8.0
	vb.offset_top = 6.0
	vb.offset_bottom = -6.0
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Battle number + node name
	var name_lbl := Label.new()
	name_lbl.add_theme_font_override("font", _title_font())
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_unlocked:
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.87, 0.35))
		name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		name_lbl.add_theme_constant_override("outline_size", 4)
	else:
		name_lbl.add_theme_color_override("font_color", Color(0.42, 0.44, 0.5))
		name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
		name_lbl.add_theme_constant_override("outline_size", 3)
	name_lbl.text = NODE_NAMES[i]
	vb.add_child(name_lbl)

	# Status line
	var status_lbl := Label.new()
	status_lbl.add_theme_font_size_override("font_size", 13)
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_cleared:
		status_lbl.text = "Cleared ✓"
		status_lbl.add_theme_color_override("font_color", Color(0.5, 0.9, 0.55))
		status_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
		status_lbl.add_theme_constant_override("outline_size", 3)
	elif is_unlocked:
		status_lbl.text = "Battle %d — Ready" % (i + 1)
		status_lbl.add_theme_color_override("font_color", Color(0.82, 0.82, 0.76))
		status_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
		status_lbl.add_theme_constant_override("outline_size", 3)
	else:
		status_lbl.text = "Locked — win the previous battle"
		status_lbl.add_theme_color_override("font_color", Color(0.48, 0.5, 0.56))
		status_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
		status_lbl.add_theme_constant_override("outline_size", 2)
	vb.add_child(status_lbl)

	# Difficulty label
	var diff_lbl := Label.new()
	diff_lbl.add_theme_font_size_override("font_size", 12)
	diff_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	diff_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var diff_str: String = NODE_DIFFICULTY[i]
	diff_lbl.text = diff_str
	var diff_col: Color = DIFF_COLORS.get(diff_str, Color(0.8, 0.8, 0.8))
	if not is_unlocked:
		diff_col = Color(0.38, 0.4, 0.44)
	diff_lbl.add_theme_color_override("font_color", diff_col)
	diff_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	diff_lbl.add_theme_constant_override("outline_size", 2)
	vb.add_child(diff_lbl)

	btn.add_child(vb)

	if is_unlocked:
		btn.mouse_entered.connect(_show_desc.bind(i))
		btn.pressed.connect(_on_node_pressed.bind(i))

	add_child(btn)

# --------------------------------------------------------------------------
func _draw_path() -> void:
	var camp: Dictionary = ProfileManager.campaign()
	var unlocked_arr: Array = camp.get("unlocked", [0])
	var current_node: int = int(camp.get("node", 0))

	for i in _node_positions.size() - 1:
		var from: Vector2 = _node_positions[i]
		var to: Vector2   = _node_positions[i + 1]
		# Segment is "lit" when both endpoints are accessible
		var next_unlocked: bool = ((i + 1) == 0) or ((i + 1) in unlocked_arr)
		var this_unlocked: bool = (i == 0) or (i in unlocked_arr)
		var lit: bool = this_unlocked and next_unlocked
		var col: Color
		if lit:
			col = Color(0.85, 0.75, 0.3, 0.82)
		else:
			col = Color(0.38, 0.4, 0.45, 0.45)
		_canvas.draw_line(from, to, col, 4.0, true)

		# Draw node number circle on each node
		var radius := 10.0
		var circle_col: Color = Color(0.85, 0.75, 0.3, 0.9) if (i == 0 or i in unlocked_arr) else Color(0.35, 0.37, 0.42, 0.7)
		_canvas.draw_circle(from, radius, circle_col)

	# Draw the last node circle too
	if _node_positions.size() > 0:
		var last := _node_positions.size() - 1
		var last_unlocked: bool = last in unlocked_arr
		var last_col: Color = Color(0.85, 0.75, 0.3, 0.9) if last_unlocked else Color(0.35, 0.37, 0.42, 0.7)
		_canvas.draw_circle(_node_positions[last], 10.0, last_col)

# --------------------------------------------------------------------------
func _show_desc(i: int) -> void:
	var diff_str: String = NODE_DIFFICULTY[i]
	_desc_label.text = "%s  [%s]\n%s" % [NODE_NAMES[i], diff_str, NODE_DESC[i]]

func _on_node_pressed(i: int) -> void:
	Sfx.play("select")
	var cfg: Dictionary = Match.default_config()
	cfg["player_race"] = _hero_race()
	cfg["opponents"]   = NODE_OPPONENTS[i].duplicate(true)
	cfg["mode"]        = "campaign"
	cfg["campaign_node"] = i
	cfg["victory"]     = "conquest"
	cfg["map"]         = CAMPAIGN_MAPS[i] if i < CAMPAIGN_MAPS.size() else "hollowspan"
	Match.set_config(cfg)
	LoadingScreen.preload_and_change_scene("res://scenes/game_world.tscn", 1.5)

func _on_back_pressed() -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
