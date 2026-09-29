extends Control
## Hero Skill Constellation presentation layer.
## This file owns only the Skill Tree screen presentation and input routing.
## SkillDefs and ProfileManager remain the semantic authorities.

const FONT := "res://assets/fonts/cinzel.ttf"
const SPACING := Vector2(220.0, 160.0)
const FOCUSED_SPACING := Vector2(250.0, 160.0)
const MARGIN := Vector2(34.0, 48.0)
const NODE_SIZE := Vector2(190.0, 146.0)
const ORB := Vector2(96.0, 96.0)
const PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")
const GRAPH_ZOOM := 0.74
const FOCUSED_ZOOM := 0.92
const GRAPH_ORIGIN := Vector2(18.0, 18.0)

const INK := Color("#0b1020")
const BACKDROP := "res://assets/textures/backgrounds/main_menu_bg.png"
var _backdrop: Texture2D
const PANEL := Color("#11182a")
const PAPER := Color("#e8dfca")
const MUTED := Color("#9ba9bb")
const GOLD := Color("#d8a951")
const GOLD_BRIGHT := Color("#f3cf78")
const MINT := Color("#76d3a4")
const ACTIVE := Color("#a889ed")
const LOCKED := Color("#637087")

const BRANCH_COLORS := {
	"combat": Color("#e16b5e"),
	"defense": Color("#70b5c9"),
	"mobility": Color("#d4a252"),
	"active": Color("#b08ae9"),
	"magic": Color("#72a6ec"),
	"command": Color("#d589a9"),
	"economy": Color("#79c68e"),
	"race": Color("#c59b62")
}

const GLYPH_TEXTURES := {
	"cmb_2": "res://assets/ui/skill_glyphs/task613_r1/a08_b1_battle_fury.png",
	"act_1": "res://assets/ui/skill_glyphs/task613_r1/a08_b1_rallying_cry.png",
	"act_2": "res://assets/ui/skill_glyphs/task613_r1/a08_b1_ground_slam.png",
	"act_3": "res://assets/ui/skill_glyphs/task613_r1/a08_b1_deepened_reserves.png"
}

class Glyph extends Control:
	## A star of the constellation: a glowing orb in the path's colour. Its
	## ring and halo say the state (owned, ready to claim, open, locked);
	## ready stars pulse and wear a turning rune ring, keystones a crown of
	## light. Also used, smaller, for the selected-star panel.
	var kind := "passive"
	var accent := Color.WHITE
	var locked := false
	var state := "PURCHASABLE"
	var hovered := false
	var texture: Texture2D
	var _t := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()

	func _process(delta: float) -> void:
		_t += delta
		if state == "PURCHASABLE" or hovered or kind == "keystone":
			queue_redraw()

	func _state_color() -> Color:
		match state:
			"UNLOCKED":
				return MINT
			"PURCHASABLE":
				return GOLD_BRIGHT
			"INSUFFICIENT_POINTS":
				return accent.lerp(GOLD, 0.35)
			_:
				return LOCKED

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * (0.40 if kind == "keystone" else 0.36)
		var sc := _state_color()
		var dim := locked or state == "PREREQUISITE_BLOCKED"
		var pulse := 0.5 + 0.5 * sin(_t * 3.2)
		# Halo: soft rings of light, stronger for owned and ready stars.
		var halo := 0.10 if dim else (0.22 if state == "UNLOCKED" else (0.18 + 0.12 * pulse if state == "PURCHASABLE" else 0.12))
		if hovered:
			halo += 0.1
		for k in 6:
			draw_circle(c, r * (1.0 + 0.12 * float(k + 1)), Color(sc, halo * (1.0 - float(k) / 6.0) * 0.55))
		# Keystone crown: four long points of light behind the orb.
		if kind == "keystone":
			var spin := _t * 0.2
			for q in 4:
				var a := spin + q * PI * 0.5
				var tip := c + Vector2(cos(a), sin(a)) * r * 1.75
				var side := Vector2(cos(a + PI * 0.5), sin(a + PI * 0.5)) * r * 0.22
				draw_colored_polygon(PackedVector2Array([c + side, tip, c - side]), Color(sc, 0.35 if not dim else 0.15))
		# The orb: deep ink shading up to the path colour at its heart.
		for k in 8:
			var f := 1.0 - float(k) / 8.0
			var col := INK.lerp(accent.darkened(0.35), 0.15 + 0.6 * (1.0 - f))
			if dim:
				col = col.darkened(0.45)
			draw_circle(c + Vector2(-r * 0.12, -r * 0.14) * (1.0 - f), r * f, col)
		if texture:
			var tint := Color(0.62, 0.66, 0.74, 0.7) if dim else Color.WHITE
			var inner := r * 1.42
			draw_texture_rect(texture, Rect2(c - Vector2(inner, inner) * 0.5, Vector2(inner, inner)), false, tint)
		else:
			var gc := Color(PAPER, 0.45) if dim else PAPER
			if kind == "active":
				draw_circle(c, r * 0.18, gc)
				for q in 4:
					var a2 := q * PI * 0.5 + PI * 0.25
					draw_line(c + Vector2(cos(a2), sin(a2)) * r * 0.32, c + Vector2(cos(a2), sin(a2)) * r * 0.62, gc, 2.2, true)
			elif kind == "keystone":
				var s := r * 0.48
				draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.62, 0), c + Vector2(0, s), c + Vector2(-s * 0.62, 0)]), gc)
			else:
				# A small four-point star.
				var s2 := r * 0.46
				draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s2), c + Vector2(s2 * 0.24, -s2 * 0.24), c + Vector2(s2, 0), c + Vector2(s2 * 0.24, s2 * 0.24),
					c + Vector2(0, s2), c + Vector2(-s2 * 0.24, s2 * 0.24), c + Vector2(-s2, 0), c + Vector2(-s2 * 0.24, -s2 * 0.24)]), gc)
		# Gloss highlight.
		draw_arc(c, r * 0.82, PI * 1.1, PI * 1.55, 16, Color(1, 1, 1, 0.10 if dim else 0.22), r * 0.14, true)
		# State ring.
		draw_arc(c, r, 0.0, TAU, 48, Color(sc, 0.9 if not dim else 0.55), 2.6 if not dim else 1.6, true)
		if state == "PURCHASABLE":
			# A turning ring of runes: the star is ready to claim.
			var rr := r * 1.22
			for q in 10:
				var a3 := _t * 0.8 + q * TAU / 10.0
				draw_arc(c, rr, a3, a3 + TAU / 22.0, 6, Color(GOLD_BRIGHT, 0.55 + 0.35 * pulse), 2.0, true)
		elif state == "UNLOCKED":
			draw_arc(c, r * 1.16, 0.0, TAU, 48, Color(MINT, 0.35), 1.2, true)
		if dim:
			# Padlock badge.
			var b := c + Vector2(r * 0.72, r * 0.72)
			draw_circle(b, r * 0.3, Color(INK, 0.95))
			draw_arc(b, r * 0.3, 0.0, TAU, 20, Color(LOCKED, 0.9), 1.2, true)
			draw_rect(Rect2(b + Vector2(-r * 0.13, -r * 0.02), Vector2(r * 0.26, r * 0.2)), LOCKED, false, 1.4)
			draw_arc(b + Vector2(0, -r * 0.02), r * 0.09, PI, TAU, 10, LOCKED, 1.4, true)

class ConstellationCanvas extends Control:
	var presenter: Object

	func _draw() -> void:
		if is_instance_valid(presenter):
			presenter._draw_constellation(self)

var _canvas: ConstellationCanvas
var _viewport: Control
var _points_label: Label
var _points_subtitle: Label
var _hero_subtitle: Label
var _detail_title: Label
var _detail_type: Label
var _detail_glyph: Glyph
var _detail_meta: Label
var _detail_body: Label
var _detail_requirements: Label
var _detail_action: Label
var _status_label: Label
var _path_filter: OptionButton
var _legend_panel: PanelContainer
var _node_buttons := {}
var _layout_positions := {}
var _glyph_texture_cache := {}
var _nodes: Array = []
var _selected_id := ""
var _hovered_id := ""
var _branch_filter := ""
var _zoom := GRAPH_ZOOM
var _pan := Vector2.ZERO
var _dragging := false

func _ready() -> void:
	_nodes = SkillDefs.get_tree()
	_build()
	ProfileManager.profile_changed.connect(_refresh_nodes)
	_refresh_nodes()
	call_deferred("_fit_default_zoom")

func _title_font() -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font

func _hero_race() -> String:
	return str(ProfileManager.hero().get("race", ""))

func _branch_color(branch: String) -> Color:
	return BRANCH_COLORS.get(branch, GOLD)

func _build() -> void:
	draw.connect(_draw_background)
	var header := MarginContainer.new()
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 28.0
	header.offset_right = -28.0
	header.offset_top = 18.0
	header.offset_bottom = 106.0
	add_child(header)
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 18)
	header.add_child(header_row)
	var title_col := VBoxContainer.new()
	title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(title_col)
	title_col.add_child(_label("HERO CONSTELLATION", 30, GOLD_BRIGHT))
	_hero_subtitle = _label("Shape the legend you carry into battle", 17, MUTED)
	title_col.add_child(_hero_subtitle)
	var point_card: PanelContainer = PLATE_SCRIPT.new()
	point_card.custom_minimum_size = Vector2(270.0, 70.0)
	point_card.add_theme_stylebox_override("panel", _plate_inset(10))
	header_row.add_child(point_card)
	var point_box := VBoxContainer.new()
	point_box.alignment = BoxContainer.ALIGNMENT_CENTER
	point_card.add_child(point_box)
	_points_label = _label("SKILL POINTS  0", 22, GOLD_BRIGHT)
	_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	point_box.add_child(_points_label)
	_points_subtitle = _label("AVAILABLE TO SPEND", 11, MUTED)
	_points_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	point_box.add_child(_points_subtitle)

	var detail_bg: PanelContainer = PLATE_SCRIPT.new()
	detail_bg.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	detail_bg.offset_left = 24.0
	detail_bg.offset_top = 128.0
	detail_bg.offset_right = 374.0
	detail_bg.offset_bottom = -116.0
	detail_bg.add_theme_stylebox_override("panel", _plate_inset(4))
	add_child(detail_bg)
	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 20)
	detail_margin.add_theme_constant_override("margin_right", 20)
	detail_margin.add_theme_constant_override("margin_top", 19)
	detail_margin.add_theme_constant_override("margin_bottom", 17)
	detail_bg.add_child(detail_margin)
	var detail_box := VBoxContainer.new()
	detail_box.add_theme_constant_override("separation", 10)
	detail_margin.add_child(detail_box)
	detail_box.add_child(_label("SELECTED STAR", 11, MUTED))
	var detail_header := HBoxContainer.new()
	detail_header.add_theme_constant_override("separation", 12)
	_detail_glyph = Glyph.new()
	_detail_glyph.custom_minimum_size = Vector2(50.0, 50.0)
	_detail_glyph.size = Vector2(50.0, 50.0)
	_detail_glyph.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	detail_header.add_child(_detail_glyph)
	var detail_title_col := VBoxContainer.new()
	detail_title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_title_col.add_theme_constant_override("separation", 4)
	detail_header.add_child(detail_title_col)
	_detail_title = _label("Choose a skill", 23, PAPER)
	_detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_type = _label("A path waits in the dark", 14, GOLD)
	detail_title_col.add_child(_detail_title)
	detail_title_col.add_child(_detail_type)
	detail_box.add_child(detail_header)
	var rule := HSeparator.new()
	rule.modulate = Color(0.5, 0.58, 0.7, 0.45)
	detail_box.add_child(rule)
	_detail_meta = _label("", 15, PAPER)
	_detail_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(_detail_meta)
	_detail_body = _label("Hover a star to reveal its power, then click to inspect its place in your build.", 15, MUTED)
	_detail_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(_detail_body)
	_detail_requirements = _label("", 13, Color("#c6a9e8"))
	_detail_requirements.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(_detail_requirements)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_box.add_child(spacer)
	_detail_action = _label("", 13, GOLD_BRIGHT)
	_detail_action.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(_detail_action)
	_status_label = _label("", 13, MUTED)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(_status_label)

	_viewport = Control.new()
	_viewport.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_viewport.offset_left = 390.0
	_viewport.offset_top = 124.0
	_viewport.offset_right = -24.0
	_viewport.offset_bottom = -116.0
	_viewport.clip_contents = true
	_viewport.gui_input.connect(_on_viewport_input)
	add_child(_viewport)
	_canvas = ConstellationCanvas.new()
	_canvas.presenter = self
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_viewport.add_child(_canvas)

	_rebuild_layout()
	for n in _nodes:
		var race: String = str(n.get("race", ""))
		if race != "" and race != _hero_race():
			continue
		_add_node_button(n)
	if _node_buttons.has("act_1"):
		_selected_id = "act_1"

	var legend: PanelContainer = PLATE_SCRIPT.new()
	legend.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	legend.offset_left = -690.0
	legend.offset_right = -300.0
	legend.offset_top = 11.0
	legend.offset_bottom = 107.0
	_legend_panel = legend
	legend.add_theme_stylebox_override("panel", _plate_inset(4))
	add_child(legend)
	var legend_margin := MarginContainer.new()
	legend_margin.add_theme_constant_override("margin_left", 15)
	legend_margin.add_theme_constant_override("margin_right", 15)
	legend_margin.add_theme_constant_override("margin_top", 11)
	legend_margin.add_theme_constant_override("margin_bottom", 10)
	legend.add_child(legend_margin)
	var legend_box := VBoxContainer.new()
	legend_box.add_theme_constant_override("separation", 7)
	legend_margin.add_child(legend_box)
	legend_box.add_child(_label("PATH FOCUS", 14, GOLD))
	_path_filter = OptionButton.new()
	_path_filter.custom_minimum_size = Vector2(360.0, 32.0)
	_path_filter.focus_mode = Control.FOCUS_NONE
	_path_filter.add_theme_font_override("font", _title_font())
	_path_filter.add_theme_font_size_override("font_size", 15)
	_path_filter.add_theme_color_override("font_color", PAPER)
	_path_filter.add_theme_stylebox_override("normal", _panel_style(Color("#182238"), Color("#52657e"), 7, 1))
	_path_filter.add_theme_stylebox_override("hover", _panel_style(Color("#26334d"), GOLD, 7, 1))
	_path_filter.add_theme_stylebox_override("pressed", _panel_style(Color("#332b1d"), GOLD_BRIGHT, 7, 1))
	_path_filter.add_item("ALL PATHS")
	for branch in BRANCH_COLORS.keys():
		_path_filter.add_item(str(branch).to_upper())
	_path_filter.select(BRANCH_COLORS.keys().find(_branch_filter) + 1)
	_path_filter.item_selected.connect(_on_path_filter_selected)
	legend_box.add_child(_path_filter)
	var legend_row := HBoxContainer.new()
	legend_row.add_theme_constant_override("separation", 12)
	legend_box.add_child(legend_row)
	legend_row.add_child(_legend_item("OWNED", MINT))
	legend_row.add_child(_legend_item("READY", GOLD_BRIGHT))
	legend_row.add_child(_legend_item("LOCKED", LOCKED))

	var footer := HBoxContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 390.0
	footer.offset_right = -24.0
	footer.offset_top = -92.0
	footer.offset_bottom = -24.0
	footer.add_theme_constant_override("separation", 10)
	add_child(footer)
	footer.add_child(_tool_button("BACK TO HERO", func(): _goto("res://scenes/ui/hero_sheet.tscn")))
	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)
	var navigation_hint := _label("DRAG TO EXPLORE  ·  SCROLL TO ZOOM", 13, MUTED)
	navigation_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	navigation_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_child(navigation_hint)
	footer.add_child(_tool_button("− ZOOM", func(): _set_zoom(_zoom - 0.08)))
	footer.add_child(_tool_button("+ ZOOM", func(): _set_zoom(_zoom + 0.08)))
	footer.add_child(_tool_button("RECENTER", _recenter_view))
	footer.add_child(_tool_button("RESPEC", _on_respec))
	_update_canvas_size()

func _add_node_button(n: Dictionary) -> void:
	var id := str(n.get("id", ""))
	var b := Button.new()
	b.name = "Skill_%s" % id
	b.toggle_mode = false
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size = NODE_SIZE
	b.size = NODE_SIZE
	b.position = _node_pos(n)
	# The selected-star panel is the authoritative detail surface. Avoid the
	# engine's delayed one-line tooltip obscuring neighboring constellation nodes.
	b.tooltip_text = ""
	b.add_theme_font_size_override("font_size", 1)
	# A star, not a card: the button itself draws nothing; the orb, the name
	# under it and a small cost line make the node.
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	b.pivot_offset = NODE_SIZE * 0.5
	var glyph := Glyph.new()
	glyph.position = Vector2((NODE_SIZE.x - ORB.x) * 0.5, 0.0)
	glyph.size = ORB
	glyph.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	glyph.kind = "active" if n.get("effect", {}).has("ability") else "passive"
	glyph.kind = "keystone" if n.get("keystone", false) else glyph.kind
	glyph.accent = _branch_color(str(n.get("branch", "")))
	glyph.texture = _skill_glyph_texture(n)
	b.add_child(glyph)
	var name_label := _label(str(n.get("name", "")), 17, PAPER)
	name_label.add_theme_font_override("font", _title_font())
	name_label.position = Vector2(0.0, ORB.y - 2.0)
	name_label.size = Vector2(NODE_SIZE.x, 34.0)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	name_label.max_lines_visible = 2
	name_label.add_theme_constant_override("line_spacing", -3)
	name_label.add_theme_color_override("font_outline_color", Color(0.01, 0.015, 0.03, 0.95))
	name_label.add_theme_constant_override("outline_size", 5)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(name_label)
	var cost_label := _label("%d SP" % int(n.get("cost", 1)), 12, MUTED)
	var two_lines: bool = _title_font().get_string_size(name_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x > NODE_SIZE.x - 4.0
	cost_label.position = Vector2(0.0, ORB.y + (38.0 if two_lines else 20.0))
	cost_label.size = Vector2(NODE_SIZE.x, 16.0)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_color_override("font_outline_color", Color(0.01, 0.015, 0.03, 0.95))
	cost_label.add_theme_constant_override("outline_size", 4)
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(cost_label)
	b.pressed.connect(_on_node_pressed.bind(n))
	b.mouse_entered.connect(_on_node_hovered.bind(n))
	b.mouse_exited.connect(_on_node_exited.bind(n))
	_canvas.add_child(b)
	_node_buttons[id] = b

func _node_pos(n: Dictionary) -> Vector2:
	var p := _display_grid_pos(n)
	var base := MARGIN + Vector2(p.x, p.y) * _layout_spacing()
	# A little deterministic drift off the grid, so all the paths together
	# read as a sky of constellations rather than a spreadsheet.
	var h := str(n.get("id", "")).hash()
	return base + Vector2(float(h % 37) - 18.0, float((h / 37) % 21) - 10.0)

func _layout_spacing() -> Vector2:
	return FOCUSED_SPACING if _branch_filter != "" else SPACING

func _display_grid_pos(n: Dictionary) -> Vector2:
	var id := str(n.get("id", ""))
	if _layout_positions.has(id):
		return _layout_positions[id]
	var p: Vector2 = n.get("pos", Vector2.ZERO)
	return p

func _rebuild_layout() -> void:
	_layout_positions.clear()
	var visible: Array = []
	var columns: Array = []
	for n in _nodes:
		if not _is_visible_node(n):
			continue
		visible.append(n)
		var x := float((n.get("pos", Vector2.ZERO) as Vector2).x)
		if not columns.has(x):
			columns.append(x)
	columns.sort()
	var column_map := {}
	for i in range(columns.size()):
		column_map[columns[i]] = i
	visible.sort_custom(func(a, b):
		var ap: Vector2 = a.get("pos", Vector2.ZERO)
		var bp: Vector2 = b.get("pos", Vector2.ZERO)
		if ap.y == bp.y:
			return ap.x < bp.x
		return ap.y < bp.y
	)
	var occupied := {}
	var branch_map := {}
	for n in visible:
		var branch := str(n.get("branch", ""))
		if not branch_map.has(branch):
			branch_map[branch] = branch_map.size()
	var focused_sequence := [1, 0, 2, 3, 1, 2, 0, 3]
	for i in range(visible.size()):
		var n: Dictionary = visible[i]
		var id := str(n.get("id", ""))
		var authored: Vector2 = n.get("pos", Vector2.ZERO)
		var column := int(branch_map[str(n.get("branch", ""))])
		if _branch_filter != "":
			# Focused paths use a restrained four-column constellation pattern.
			# This changes presentation only; prerequisite links remain authored.
			column = focused_sequence[i % focused_sequence.size()]
		var row := maxi(0, int(round(authored.y)))
		var key := "%d:%d" % [column, row]
		while occupied.has(key):
			row += 1
			key = "%d:%d" % [column, row]
		occupied[key] = id
		_layout_positions[id] = Vector2(column, row)

func _is_visible_node(n: Dictionary) -> bool:
	if n.is_empty():
		return false
	var race: String = str(n.get("race", ""))
	if race != "" and race != _hero_race():
		return false
	return _branch_filter == "" or str(n.get("branch", "")) == _branch_filter

func _update_canvas_size() -> void:
	_rebuild_layout()
	var max_x := 0.0
	var max_y := 0.0
	for n in _nodes:
		if not _is_visible_node(n):
			continue
		var p := _display_grid_pos(n)
		max_x = maxf(max_x, p.x)
		max_y = maxf(max_y, p.y)
	_canvas.custom_minimum_size = MARGIN * 2.0 + Vector2(max_x, max_y) * _layout_spacing() + NODE_SIZE
	_canvas.size = _canvas.custom_minimum_size
	_apply_transform()

func _fit_default_zoom() -> void:
	if not is_instance_valid(_viewport) or _viewport.size.x <= 0.0:
		return
	# Focused paths are taller than the view. Open on complete, readable stars
	# and let players drag down for the rest instead of cutting a card at the rail.
	var target := FOCUSED_ZOOM if _branch_filter != "" else GRAPH_ZOOM
	if _branch_filter == "":
		target = minf(target, maxf(0.62, (_viewport.size.x - 36.0) / maxf(1.0, _canvas.size.x)))
	_zoom = clampf(target, 0.52, 1.16)
	_apply_transform()

func _apply_transform() -> void:
	_canvas.scale = Vector2(_zoom, _zoom)
	var view_size := _viewport.size
	var scaled_size := _canvas.size * _zoom
	var centered := Vector2(GRAPH_ORIGIN.x, GRAPH_ORIGIN.y)
	if view_size.x > 0.0:
		centered.x = maxf(GRAPH_ORIGIN.x, (view_size.x - scaled_size.x) * 0.5)
		centered.y = maxf(GRAPH_ORIGIN.y, (view_size.y - scaled_size.y) * 0.5)
	_canvas.position = centered + _pan
	_canvas.queue_redraw()

func _set_zoom(z: float) -> void:
	Sfx.play("select")
	_zoom = clampf(z, 0.52, 1.16)
	_apply_transform()

func _recenter_view() -> void:
	_pan = Vector2.ZERO
	_fit_default_zoom()

func _on_viewport_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_set_zoom(_zoom + 0.08)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_set_zoom(_zoom - 0.08)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
	elif event is InputEventMouseMotion and _dragging:
		_pan += event.relative
		_apply_transform()

func _draw_background() -> void:
	# Night sky over the realm's key art: a deep scrim, then a violet-to-ink
	# wash so the constellation is the brightest thing on the page.
	draw_rect(Rect2(Vector2.ZERO, size), INK)
	if _backdrop == null and ResourceLoader.exists(BACKDROP):
		_backdrop = load(BACKDROP)
	if _backdrop:
		var tex_size := _backdrop.get_size()
		var cover := maxf(size.x / tex_size.x, size.y / tex_size.y)
		var draw_size := tex_size * cover
		draw_texture_rect(_backdrop, Rect2((size - draw_size) * 0.5, draw_size), false, Color(1, 1, 1, 0.38))
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.025, 0.06, 0.72))
	# A wash of night colour: violet high up, ink low down.
	for k in 12:
		var f := float(k) / 12.0
		draw_rect(Rect2(0, size.y * f, size.x, size.y / 12.0 + 1.0), Color(0.16, 0.08, 0.26, 0.10 * (1.0 - f)))
	for i in 10:
		var inset := float(i) * 26.0
		draw_rect(Rect2(Vector2(inset, inset), size - Vector2(inset, inset) * 2.0), Color(0, 0, 0, 0.05), false, 26.0)
	# Faint fixed stars across the whole page, so the twinkling sky inside
	# the constellation view has no visible edge.
	var srng := RandomNumberGenerator.new()
	srng.seed = 1977
	for k in int(size.x * size.y / 5200.0):
		draw_circle(Vector2(srng.randf() * size.x, srng.randf() * size.y), srng.randf_range(0.5, 1.4), Color(0.85, 0.9, 1.0, srng.randf_range(0.12, 0.35)))
	draw_line(Vector2(24, 108), Vector2(size.x - 24, 108), Color(GOLD, 0.35), 1.0)
	draw_line(Vector2(24, size.y - 105), Vector2(size.x - 24, size.y - 105), Color(GOLD, 0.22), 1.0)

## Stars of the sky behind the constellation, made once and twinkled each frame.
var _sky: Array = []
var _sky_size := Vector2.ZERO
## Bursts of light when a star is claimed: {pos, t, col}.
var _bursts: Array = []
var _sky_time := 0.0

func _process(delta: float) -> void:
	_sky_time += delta
	if is_instance_valid(_canvas) and is_visible_in_tree():
		_canvas.queue_redraw()
	if not _bursts.is_empty():
		_bursts = _bursts.filter(func(b): return _sky_time - float(b["t"]) < 1.2)

func _orb_center(n: Dictionary) -> Vector2:
	return _node_pos(n) + Vector2(NODE_SIZE.x * 0.5, ORB.y * 0.5)

func _ensure_sky(area: Vector2) -> void:
	if _sky_size == area and not _sky.is_empty():
		return
	_sky_size = area
	_sky.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 77077
	var count := int(clampf(area.x * area.y / 5200.0, 120.0, 900.0))
	for k in count:
		_sky.append({"p": Vector2(rng.randf() * area.x, rng.randf() * area.y), "r": rng.randf_range(0.6, 1.9),
			"ph": rng.randf() * TAU, "sp": rng.randf_range(0.6, 2.2), "tint": rng.randf()})

func _draw_constellation(canvas: CanvasItem) -> void:
	var area: Vector2 = _canvas.size + Vector2(600, 600)
	_ensure_sky(area)
	# The sky: twinkling stars, a few warm, most cold.
	for st in _sky:
		var tw := 0.35 + 0.65 * (0.5 + 0.5 * sin(_sky_time * float(st["sp"]) + float(st["ph"])))
		var col := Color(0.85, 0.9, 1.0) if float(st["tint"]) < 0.8 else Color(1.0, 0.85, 0.6)
		canvas.draw_circle(Vector2(st["p"]) - Vector2(300, 300), float(st["r"]), Color(col, 0.55 * tw))
	# Nebulae: soft clouds of each path's colour around its stars.
	var branch_pts := {}
	for n in _nodes:
		if _node_buttons.has(str(n.get("id", ""))) and _is_visible_node(n):
			var br := str(n.get("branch", ""))
			if not branch_pts.has(br):
				branch_pts[br] = []
			branch_pts[br].append(_orb_center(n))
	for br in branch_pts:
		var pts: Array = branch_pts[br]
		var bc: Color = _branch_color(br)
		for k in pts.size():
			if k % 2 == 1:
				continue
			var p: Vector2 = pts[k]
			for q in 5:
				canvas.draw_circle(p + Vector2(sin(k * 1.7) * 30.0, cos(k * 2.3) * 24.0), 50.0 + q * 26.0, Color(bc, 0.014))
		# The constellation's name, large and faint above its first star.
		var top: Vector2 = pts[0]
		for p2 in pts:
			if p2.y < top.y:
				top = p2
		var title: String = String(br).to_upper()
		var tfs := 26
		var tw2 := _title_font().get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, tfs).x
		canvas.draw_string(_title_font(), top + Vector2(-tw2 * 0.5, -58.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, tfs, Color(bc, 0.42))
	# Links: faint for locked, bright for open paths, with motes of light
	# flowing along the owned ones toward the next star.
	for n in _nodes:
		var id := str(n.get("id", ""))
		if not _node_buttons.has(id) or not _is_visible_node(n):
			continue
		var to := _orb_center(n)
		for req in n.get("req", []):
			var required := _find_node(str(req))
			if required.is_empty() or not _node_buttons.has(req) or not _is_visible_node(required):
				continue
			var from := _orb_center(required)
			var complete := _is_unlocked(id) and _is_unlocked(req)
			var available := _prereqs_met(n) and not _is_unlocked(id)
			var col := MINT if complete else GOLD_BRIGHT if available else LOCKED
			var path := _constellation_link(from, to)
			var strength := 0.9 if complete else (0.75 if available else 0.28)
			canvas.draw_polyline(path, Color(col, strength * 0.10), 12.0 if complete or available else 5.0, true)
			canvas.draw_polyline(path, Color(col, strength * 0.40), 3.4 if complete or available else 1.6, true)
			canvas.draw_polyline(path, Color(PAPER, strength * 0.55), 1.0, true)
			if complete or available:
				var motes := 3 if complete else 2
				for m in motes:
					var t := fmod(_sky_time * (0.28 if complete else 0.18) + float(m) / float(motes) + float(id.hash() % 97) / 97.0, 1.0)
					var idx := t * float(path.size() - 1)
					var i0 := int(idx)
					var p3: Vector2 = path[i0].lerp(path[mini(i0 + 1, path.size() - 1)], idx - float(i0))
					canvas.draw_circle(p3, 5.0, Color(col, 0.18))
					canvas.draw_circle(p3, 2.4, Color(col.lightened(0.4), 0.9))
	# A dark plate behind each star's name keeps links from crossing the text.
	for n in _nodes:
		var nid := str(n.get("id", ""))
		if not _node_buttons.has(nid) or not _is_visible_node(n):
			continue
		var b: Button = _node_buttons[nid]
		var lab: Label = b.get_child(1) as Label
		var tw3 := minf(NODE_SIZE.x, _title_font().get_string_size(lab.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x + 18.0)
		var lines := 2 if tw3 >= NODE_SIZE.x - 2.0 else 1
		var plate := Rect2(b.position + Vector2((NODE_SIZE.x - tw3) * 0.5, ORB.y - 3.0), Vector2(tw3, 19.0 * lines + 22.0))
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.02, 0.025, 0.05, 0.72)
		sb.set_corner_radius_all(8)
		canvas.draw_style_box(sb, plate)
	# The selected star wears two counter-turning gilt rings.
	var sel := _find_node(_selected_id)
	if not sel.is_empty() and _is_visible_node(sel):
		var sc2 := _orb_center(sel)
		var rr2 := ORB.x * 0.62
		for q in 3:
			var a4 := _sky_time * 0.9 + q * TAU / 3.0
			canvas.draw_arc(sc2, rr2, a4, a4 + 1.3, 20, Color(GOLD_BRIGHT, 0.85), 2.2, true)
			var a5 := -_sky_time * 0.6 + q * TAU / 3.0
			canvas.draw_arc(sc2, rr2 + 7.0, a5, a5 + 0.8, 14, Color(GOLD_BRIGHT, 0.45), 1.4, true)
	# Claim bursts: an expanding ring and sparks.
	for b in _bursts:
		var age := (_sky_time - float(b["t"])) / 1.2
		var bp: Vector2 = b["pos"]
		var bcol: Color = b["col"]
		canvas.draw_arc(bp, 30.0 + age * 90.0, 0.0, TAU, 40, Color(bcol, 0.8 * (1.0 - age)), 3.0 * (1.0 - age) + 1.0, true)
		canvas.draw_arc(bp, 20.0 + age * 55.0, 0.0, TAU, 40, Color(PAPER, 0.5 * (1.0 - age)), 1.5, true)
		for q in 12:
			var a := q * TAU / 12.0 + float(b["t"])
			canvas.draw_circle(bp + Vector2(cos(a), sin(a)) * (26.0 + age * 110.0), 2.5 * (1.0 - age) + 0.5, Color(bcol.lightened(0.3), 1.0 - age))

func _constellation_link(from: Vector2, to: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	var delta := to - from
	var bend := minf(22.0, absf(delta.y) * 0.18)
	var first := from + Vector2(delta.x * 0.3, bend)
	var second := to - Vector2(delta.x * 0.3, bend)
	for step in range(17):
		var t := float(step) / 16.0
		var inverse := 1.0 - t
		points.append(from * pow(inverse, 3.0) + first * 3.0 * pow(inverse, 2.0) * t + second * 3.0 * inverse * t * t + to * pow(t, 3.0))
	return points

func _find_node(id: String) -> Dictionary:
	for n in _nodes:
		if str(n.get("id", "")) == id:
			return n
	return {}

func _is_unlocked(id: String) -> bool:
	return id in ProfileManager.hero().get("skills", [])

func _prereqs_met(n: Dictionary) -> bool:
	var owned: Array = ProfileManager.hero().get("skills", [])
	for req in n.get("req", []):
		if not (req in owned):
			return false
	return true

func _node_state(n: Dictionary) -> String:
	var id := str(n.get("id", ""))
	if _is_unlocked(id):
		return "UNLOCKED"
	if not _prereqs_met(n):
		return "PREREQUISITE_BLOCKED"
	if int(ProfileManager.hero().get("skill_points", 0)) >= int(n.get("cost", 1)):
		return "PURCHASABLE"
	return "INSUFFICIENT_POINTS"

func _node_tag(n: Dictionary) -> String:
	match _node_state(n):
		"UNLOCKED":
			return "UNLOCKED"
		"PURCHASABLE":
			return "CLAIM"
		"INSUFFICIENT_POINTS":
			return "OPEN"
		_:
			return "LOCKED"

func _node_style(n: Dictionary, selected: bool, hovered: bool) -> StyleBoxFlat:
	var state := _node_state(n)
	var bg := Color("#172238")
	var border := Color(0.27, 0.34, 0.47, 0.9)
	if state == "UNLOCKED":
		bg = Color("#14352f")
		border = MINT
	elif state == "PURCHASABLE":
		bg = Color("#3a2d18")
		border = GOLD_BRIGHT
	elif state == "INSUFFICIENT_POINTS":
		bg = Color("#272638")
		border = Color(GOLD, 0.75)
	elif state == "PREREQUISITE_BLOCKED":
		bg = Color("#131a29")
		border = Color(LOCKED, 0.7)
	if n.get("keystone", false):
		border = GOLD_BRIGHT if state != "UNLOCKED" else MINT
	if hovered:
		bg = bg.lightened(0.14)
		border = PAPER
	if selected:
		border = GOLD_BRIGHT
	var box := _panel_style(bg, border, 9, 2 if selected or state == "PURCHASABLE" else 1)
	box.border_width_top = 3 if state == "UNLOCKED" or state == "PURCHASABLE" else 1
	box.shadow_color = Color(border, 0.28) if selected or hovered else Color(0, 0, 0, 0.3)
	box.shadow_size = 7 if selected or hovered else 3
	return box

func _refresh_nodes() -> void:
	if not ProfileManager.has_hero():
		return
	var h := ProfileManager.hero()
	var sp := int(h.get("skill_points", 0))
	var race := GameData.get_race(str(h.get("race", "")))
	_hero_subtitle.text = "%s  /  %s  ·  SHAPE THE LEGEND YOU CARRY INTO BATTLE" % [str(race.get("name", h.get("race", "Hero"))).to_upper(), str(h.get("archetype", "Warrior")).to_upper()]
	_points_label.text = "SKILL POINTS  %d" % sp
	for n in _nodes:
		var id := str(n.get("id", ""))
		if not _node_buttons.has(id):
			continue
		var b: Button = _node_buttons[id]
		b.visible = _is_visible_node(n)
		b.position = _node_pos(n)
		var state := _node_state(n)
		var cost_label: Label = b.get_child(2) as Label
		cost_label.text = "%d SP  ·  %s" % [int(n.get("cost", 1)), _node_tag(n)]
		cost_label.modulate = GOLD_BRIGHT if state == "PURCHASABLE" else MINT if state == "UNLOCKED" else MUTED
		var name_label: Label = b.get_child(1) as Label
		name_label.modulate = Color(1, 1, 1, 1) if state != "PREREQUISITE_BLOCKED" else Color(0.72, 0.75, 0.82, 0.8)
		if id == _selected_id:
			name_label.add_theme_color_override("font_color", GOLD_BRIGHT)
		else:
			name_label.add_theme_color_override("font_color", PAPER)
		var glyph: Glyph = b.get_child(0) as Glyph
		glyph.state = state
		glyph.locked = state == "PREREQUISITE_BLOCKED"
		glyph.hovered = id == _hovered_id or id == _selected_id
		glyph.accent = _branch_color(str(n.get("branch", "")))
		glyph.queue_redraw()
		var want := Vector2.ONE * (1.12 if id == _hovered_id else 1.0)
		var heading: Vector2 = b.get_meta("scaling_to") if b.has_meta("scaling_to") else Vector2.ONE
		if heading != want:
			b.set_meta("scaling_to", want)
			b.create_tween().tween_property(b, "scale", want, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var visible_count := 0
	var owned_count := 0
	for n in _nodes:
		if _is_visible_node(n):
			visible_count += 1
			if _is_unlocked(str(n.get("id", ""))):
				owned_count += 1
	var focus_text := "ALL PATHS" if _branch_filter == "" else _branch_filter.to_upper() + " PATH"
	_status_label.text = "%s  ·  %d / %d UNLOCKED" % [focus_text, owned_count, visible_count]
	_canvas.queue_redraw()
	if _selected_id != "":
		var selected := _find_node(_selected_id)
		if not selected.is_empty():
			_update_detail(selected)

func _on_node_hovered(n: Dictionary) -> void:
	_hovered_id = str(n.get("id", ""))
	_update_detail(n)
	_refresh_nodes()

func _on_node_exited(n: Dictionary) -> void:
	if _hovered_id == str(n.get("id", "")):
		_hovered_id = ""
		if _selected_id != "":
			var selected := _find_node(_selected_id)
			if not selected.is_empty():
				_update_detail(selected)
	_refresh_nodes()

func _on_path_filter_selected(index: int) -> void:
	_branch_filter = "" if index == 0 else str(BRANCH_COLORS.keys()[index - 1])
	if _selected_id != "" and not _is_visible_node(_find_node(_selected_id)):
		_selected_id = ""
		for n in _nodes:
			if _is_visible_node(n):
				_selected_id = str(n.get("id", ""))
				break
	_update_canvas_size()
	_refresh_nodes()
	_pan = Vector2.ZERO
	_fit_default_zoom()

func _skill_glyph_texture(n: Dictionary) -> Texture2D:
	var id := str(n.get("id", ""))
	if _glyph_texture_cache.has(id):
		return _glyph_texture_cache[id]
	var path := str(GLYPH_TEXTURES.get(id, ""))
	var texture: Texture2D = load(path) if path != "" and ResourceLoader.exists(path) else null
	_glyph_texture_cache[id] = texture
	return texture

func _on_node_pressed(n: Dictionary) -> void:
	_selected_id = str(n.get("id", ""))
	_update_detail(n)
	var id := _selected_id
	if _is_unlocked(id):
		Sfx.play("select")
		_refresh_nodes()
		return
	if _prereqs_met(n) and int(ProfileManager.hero().get("skill_points", 0)) >= int(n.get("cost", 1)):
		if ProfileManager.unlock_skill(id):
			Sfx.play("levelup")
			_bursts.append({"pos": _orb_center(n), "t": _sky_time, "col": _branch_color(str(n.get("branch", "")))})
			_status_label.text = "%s joined your constellation." % str(n.get("name", ""))
		else:
			Sfx.play("select")
	else:
		Sfx.play("select")
		_detail_action.text = "NOT READY  •  See the requirement above"
	_refresh_nodes()

func _update_detail(n: Dictionary) -> void:
	var state := _node_state(n)
	var has_ability: bool = bool(n.get("effect", {}).has("ability"))
	if is_instance_valid(_detail_glyph):
		_detail_glyph.kind = "active" if has_ability else "passive"
		_detail_glyph.kind = "keystone" if n.get("keystone", false) else _detail_glyph.kind
		_detail_glyph.accent = _branch_color(str(n.get("branch", "")))
		_detail_glyph.locked = state == "PREREQUISITE_BLOCKED"
		_detail_glyph.texture = _skill_glyph_texture(n)
		_detail_glyph.queue_redraw()
	_detail_title.text = str(n.get("name", ""))
	_detail_type.text = ("ACTIVE ABILITY" if has_ability else "PASSIVE AUGMENT") + ("  •  KEYSTONE" if n.get("keystone", false) else "")
	_detail_type.modulate = ACTIVE if has_ability else GOLD
	_detail_meta.text = "COST  %d SKILL POINT%s\nSTATE  %s" % [int(n.get("cost", 1)), "" if int(n.get("cost", 1)) == 1 else "S", state.replace("_", " ")]
	_detail_body.text = str(n.get("desc", ""))
	var req_names: Array[String] = []
	for req in n.get("req", []):
		var parent := _find_node(str(req))
		req_names.append(str(parent.get("name", req)))
	if req_names.is_empty():
		_detail_requirements.text = "ROOT STAR  •  No prerequisite"
	else:
		_detail_requirements.text = ("REQUIRES  " + "  +  ".join(req_names)) if state == "PREREQUISITE_BLOCKED" else ("PATH FROM  " + "  +  ".join(req_names))
	if state == "UNLOCKED":
		_detail_action.text = "UNLOCKED  •  This power is active in your build"
	elif state == "PURCHASABLE":
		_detail_action.text = "READY TO CLAIM  •  Click to spend %d point%s" % [int(n.get("cost", 1)), "" if int(n.get("cost", 1)) == 1 else "s"]
	elif state == "INSUFFICIENT_POINTS":
		_detail_action.text = "AVAILABLE  •  INSUFFICIENT POINTS to claim it"
	else:
		_detail_action.text = "PREREQUISITE BLOCKED  •  Follow the parent path"

func _legend_item(text: String, color: Color) -> Label:
	var label := _label("●  " + text, 10, color)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", _title_font() if font_size > 22 else ThemeDB.fallback_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _tool_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(132.0, 48.0)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_override("font", ThemeDB.fallback_font)
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_color_override("font_color", PAPER)
	# The game's forged gilt buttons, as on every other page.
	if ResourceLoader.exists("res://assets/ui/theme.tres"):
		b.theme = load("res://assets/ui/theme.tres")
	b.pressed.connect(cb)
	return b

func _plate_inset(pad: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color.TRANSPARENT
	box.set_content_margin_all(pad)
	return box

func _panel_style(bg: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 8.0
	box.content_margin_right = 8.0
	box.content_margin_top = 6.0
	box.content_margin_bottom = 6.0
	return box

func _on_respec() -> void:
	Sfx.play("select")
	var dlg := ConfirmationDialog.new()
	dlg.dialog_text = "Refund all unlocked skills? Your skill points will be returned."
	dlg.title = "Respec Constellation"
	add_child(dlg)
	dlg.confirmed.connect(func():
		ProfileManager.respec_skills()
		dlg.queue_free())
	dlg.canceled.connect(func(): dlg.queue_free())
	dlg.popup_centered()

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)
