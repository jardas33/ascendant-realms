extends Control
## Hero Skill Constellation presentation layer.
## This file owns only the Skill Tree screen presentation and input routing.
## SkillDefs and ProfileManager remain the semantic authorities.
const FORGED_FACES := preload("res://scripts/ui/main_menu.gd")

const FONT := "res://assets/fonts/cinzel.ttf"
## Each path is laid out as the tree it is: a spine down the middle, forks
## side by side, and the late side branch to its right (it used to be one
## column, with forks stacked and links running behind other stars' names).
## The overview shows the stars without names (hover one for its card); a
## focused path spreads out and names every star.
const LANE := 104.0
const ROW := 128.0
const COLUMN := 344.0
const FOCUSED_LANE := 270.0
const FOCUSED_ROW := 236.0
## Where a path's side branch stands, in lanes right of its spine.
const SPUR_LANE := 1.5
const MARGIN := Vector2(34.0, 130.0)
const NODE_SIZE := Vector2(200.0, 206.0)
const ORB := Vector2(96.0, 96.0)
const PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")
const GRAPH_ZOOM := 0.74
const FOCUSED_ZOOM := 0.92
## Star caption sizes on the canvas (before the graph zoom).
## Star names are set in the plain face, emboldened, not in Cinzel: the thin
## capitals at this size were what made players squint (Emanuel, 2026-10-15).
## Sized for 16 px on screen or more at the default zoom on a laptop window.
const NAME_SIZE := 29
const NAME_SIZE_COMPACT := 32
const COST_SIZE := 23
const COST_SIZE_COMPACT := 25
## A name may spill a little past its star on both sides (the gap between
## paths is wide enough), so long words are not shrunk or broken.
const NAME_SPILL := 18.0
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

const SkillIcons := preload("res://scripts/ui/skill_icons.gd")

## A star's click area is its orb and the text under it, not its whole
## box: with the paths winding and staggered, the empty corners of
## neighbouring boxes overlap and took each other's clicks.
class StarButton extends Button:
	func _has_point(point: Vector2) -> bool:
		var orb_c := Vector2(size.x * 0.5, ORB.y * 0.5)
		if point.distance_to(orb_c) <= ORB.x * 0.5 + 6.0:
			return true
		var text_h: float = get_meta("text_h") if has_meta("text_h") else size.y - ORB.y
		return absf(point.x - size.x * 0.5) <= size.x * 0.5 and point.y >= ORB.y - 4.0 and point.y <= ORB.y + text_h

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

	## The forged rim's two tones by state: iron when locked, bronze when it
	## waits for points, bright gold when it can be claimed, gilt when owned.
	func _rim_tones() -> Array:
		match state:
			"UNLOCKED":
				return [Color(0.50, 0.33, 0.12), Color(1.0, 0.90, 0.58)]
			"PURCHASABLE":
				return [Color(0.55, 0.38, 0.12), Color(1.0, 0.86, 0.50)]
			"INSUFFICIENT_POINTS":
				return [Color(0.30, 0.20, 0.11), Color(0.78, 0.56, 0.32)]
			_:
				return [Color(0.16, 0.17, 0.20), Color(0.52, 0.55, 0.60)]

	## A ring of worked metal, lit from the upper left.
	func _metal_ring(c: Vector2, radius: float, width: float, dark: Color, light: Color) -> void:
		var segs := 48
		for k in segs:
			var a0 := TAU * float(k) / float(segs)
			var a1 := TAU * float(k + 1) / float(segs) + 0.01
			var lit := 0.5 + 0.5 * cos((a0 + a1) * 0.5 + PI * 0.75)
			draw_arc(c, radius, a0, a1, 3, dark.lerp(light, lit * lit), width, true)
		draw_arc(c, radius + width * 0.5, 0.0, TAU, 64, Color(0, 0, 0, 0.75), 1.4, true)
		draw_arc(c, radius - width * 0.5, 0.0, TAU, 64, Color(0, 0, 0, 0.8), 1.4, true)
		draw_arc(c, radius + width * 0.22, PI * 1.05, PI * 1.7, 18, Color(1, 1, 1, 0.28), 1.2, true)

	## An eight-pointed star of metal behind a keystone's medallion.
	func _star_frame(c: Vector2, r_out: float, r_in: float, dark: Color, light: Color, spin: float) -> void:
		var pts := PackedVector2Array()
		var cols := PackedColorArray()
		for k in 16:
			var a := spin + TAU * float(k) / 16.0
			var rr := r_out if k % 2 == 0 else r_in
			pts.append(c + Vector2(cos(a), sin(a)) * rr)
			var lit := 0.5 + 0.5 * cos(a + PI * 0.75)
			cols.append(dark.lerp(light, lit * 0.9))
		draw_polygon(pts, cols)
		var edge := PackedVector2Array(pts)
		edge.append(pts[0])
		draw_polyline(edge, Color(0, 0, 0, 0.7), 1.4, true)

	func _draw() -> void:
		var c := size * 0.5
		var keystone := kind == "keystone"
		var r := minf(size.x, size.y) * (0.40 if keystone else 0.42)
		var sc := _state_color()
		var dim := locked or state == "PREREQUISITE_BLOCKED"
		var pulse := 0.5 + 0.5 * sin(_t * 3.2)
		var tones := _rim_tones()
		var dark: Color = tones[0]
		var light: Color = tones[1]
		if state == "PURCHASABLE":
			light = light.lerp(Color(1, 0.97, 0.8), 0.35 * pulse)
		if hovered:
			light = light.lightened(0.15)
		# Light behind the medallion for a star that is owned or ready.
		if not dim and state != "INSUFFICIENT_POINTS":
			var halo := 0.16 if state == "UNLOCKED" else 0.12 + 0.12 * pulse
			for k in 5:
				draw_circle(c, r * (1.12 + 0.11 * float(k + 1)), Color(sc, halo * (1.0 - float(k) / 5.0)))
		# Drop shadow.
		draw_circle(c + Vector2(0, r * 0.08), r * 1.12, Color(0, 0, 0, 0.55))
		if keystone:
			_star_frame(c, r * 1.42, r * 1.02, dark, light, PI * 0.125 if dim else PI * 0.125 + sin(_t * 0.6) * 0.04)
			_star_frame(c, r * 1.22, r * 0.98, dark.darkened(0.3), light.darkened(0.15), 0.0)
		# The well: deep ink at the rim, the path's colour glowing at its heart.
		var well := r * 0.80
		for k in 10:
			var f := 1.0 - float(k) / 10.0
			var col := INK.lerp(accent.darkened(0.45), 0.10 + 0.55 * (1.0 - f))
			if dim:
				col = col.lerp(Color(0.10, 0.11, 0.14), 0.6)
			draw_circle(c + Vector2(-well * 0.10, -well * 0.12) * (1.0 - f), well * f, col)
		# The skill's picture, with a shadow so it stands off the well.
		if texture:
			var tint := Color(0.74, 0.75, 0.80, 0.92) if dim else Color.WHITE
			var inner := well * 1.8
			var box := Rect2(c - Vector2(inner, inner) * 0.5, Vector2(inner, inner))
			draw_texture_rect(texture, Rect2(box.position + Vector2(0, 2.5), box.size), false, Color(0, 0, 0, 0.6))
			draw_texture_rect(texture, box, false, tint)
		else:
			var gc := Color(PAPER, 0.45) if dim else PAPER
			var s2 := well * 0.52
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s2), c + Vector2(s2 * 0.24, -s2 * 0.24), c + Vector2(s2, 0), c + Vector2(s2 * 0.24, s2 * 0.24),
				c + Vector2(0, s2), c + Vector2(-s2 * 0.24, s2 * 0.24), c + Vector2(-s2, 0), c + Vector2(-s2 * 0.24, -s2 * 0.24)]), gc)
		# Glass: a soft gleam over the top of the well.
		draw_arc(c, well * 0.78, PI * 1.12, PI * 1.62, 18, Color(1, 1, 1, 0.08 if dim else 0.18), well * 0.22, true)
		# The forged rim. An active power wears a second, inner ring.
		_metal_ring(c, r * 0.90, r * 0.20, dark, light)
		if kind == "active":
			draw_arc(c, r * 0.76, 0.0, TAU, 48, Color(light, 0.85 if not dim else 0.45), 1.6, true)
			for q in 4:
				var a2 := q * PI * 0.5 + PI * 0.25
				draw_circle(c + Vector2(cos(a2), sin(a2)) * r * 0.90, r * 0.07, light)
				draw_circle(c + Vector2(cos(a2), sin(a2)) * r * 0.90, r * 0.035, dark.darkened(0.4))
		else:
			for q in 4:
				var a3 := q * PI * 0.5
				draw_circle(c + Vector2(cos(a3), sin(a3)) * r * 0.90, r * 0.05, light.lerp(dark, 0.3))
		# Owned: a ring of the path's colour inside the rim.
		if state == "UNLOCKED":
			draw_arc(c, r * 0.79, 0.0, TAU, 48, Color(accent.lightened(0.35), 0.9), 2.2, true)
		elif state == "PURCHASABLE":
			# A turning ring of light: the star is ready to claim.
			var rr := r * 1.18
			for q in 8:
				var a4 := _t * 0.7 + q * TAU / 8.0
				draw_arc(c, rr, a4, a4 + TAU / 20.0, 6, Color(GOLD_BRIGHT, 0.55 + 0.4 * pulse), 2.4, true)
		if dim:
			# Padlock badge on the rim.
			var b := c + Vector2(r * 0.74, r * 0.74)
			draw_circle(b, r * 0.30, Color(0.05, 0.06, 0.08, 0.98))
			draw_arc(b, r * 0.30, 0.0, TAU, 20, Color(0.55, 0.58, 0.64, 0.95), 1.4, true)
			draw_rect(Rect2(b + Vector2(-r * 0.12, -r * 0.02), Vector2(r * 0.24, r * 0.18)), Color(0.62, 0.65, 0.7), true)
			draw_arc(b + Vector2(0, -r * 0.02), r * 0.085, PI, TAU, 10, Color(0.62, 0.65, 0.7), 1.6, true)

class ConstellationCanvas extends Control:
	var presenter: Object

	func _draw() -> void:
		if is_instance_valid(presenter):
			presenter._draw_constellation(self)

## A drawing pass over the constellation: "glow" (added light, under the
## stars), "plates" (the dark plates under star names) or "fx" (added light
## over everything, for claim moments).
class FxLayer extends Control:
	var presenter: Object
	var pass_name := ""

	func _init(p: Object, pass_id: String, additive: bool) -> void:
		presenter = p
		pass_name = pass_id
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		if additive:
			var m := CanvasItemMaterial.new()
			m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			material = m

	func _draw() -> void:
		if is_instance_valid(presenter):
			presenter._draw_layer(self, pass_name)

var _canvas: ConstellationCanvas
var _layers: Array = []
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

func _name_lines(text: String, size: int, width: float = NODE_SIZE.x) -> int:
	var para := TextParagraph.new()
	para.add_string(text, _name_font(), size)
	para.width = width
	para.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
	return mini(2, para.get_line_count())


func _title_font() -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font


static var _star_font: FontVariation = null

## The plain face, emboldened and slightly widened, for star names.
func _name_font() -> Font:
	if _star_font == null:
		_star_font = FontVariation.new()
		_star_font.base_font = ThemeDB.fallback_font
		_star_font.variation_embolden = 0.55
		_star_font.spacing_glyph = 1
	return _star_font

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
	_viewport.offset_top = 146.0
	_viewport.offset_right = -24.0
	_viewport.offset_bottom = -116.0
	_viewport.clip_contents = true
	_viewport.gui_input.connect(_on_viewport_input)
	add_child(_viewport)
	_canvas = ConstellationCanvas.new()
	_canvas.presenter = self
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_viewport.add_child(_canvas)
	_layers = [FxLayer.new(self, "glow", true), FxLayer.new(self, "plates", false)]
	for layer in _layers:
		_canvas.add_child(layer)

	_rebuild_layout()
	for n in _nodes:
		var race: String = str(n.get("race", ""))
		if race != "" and race != _hero_race():
			continue
		_add_node_button(n)
	_layers.append(FxLayer.new(self, "fx", true))
	_canvas.add_child(_layers[-1])
	_layers.append(FxLayer.new(self, "tag", false))
	_canvas.add_child(_layers[-1])
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
	footer.add_child(_tool_button("Back to Hero", func(): _goto("res://scenes/ui/hero_sheet.tscn")))
	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)
	var navigation_hint := _label("DRAG TO EXPLORE  ·  SCROLL TO ZOOM", 13, MUTED)
	navigation_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	navigation_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_child(navigation_hint)
	footer.add_child(_tool_button("− Zoom", func(): _set_zoom(_zoom - 0.08)))
	footer.add_child(_tool_button("+ Zoom", func(): _set_zoom(_zoom + 0.08)))
	footer.add_child(_tool_button("Recenter", _recenter_view))
	footer.add_child(_tool_button("Respec", _on_respec))
	_update_canvas_size()

func _add_node_button(n: Dictionary) -> void:
	var id := str(n.get("id", ""))
	var b := StarButton.new()
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
	b.pivot_offset = Vector2(NODE_SIZE.x * 0.5, ORB.y * 0.5)
	var glyph := Glyph.new()
	glyph.position = Vector2((NODE_SIZE.x - ORB.x) * 0.5, 0.0)
	glyph.size = ORB
	glyph.pivot_offset = ORB * 0.5
	glyph.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	glyph.kind = "active" if n.get("effect", {}).has("ability") else "passive"
	glyph.kind = "keystone" if n.get("keystone", false) else glyph.kind
	glyph.accent = _branch_color(str(n.get("branch", "")))
	glyph.texture = _skill_glyph_texture(n)
	b.add_child(glyph)
	# The whole graph is drawn at about three quarters size (two thirds on a
	# small screen), so the captions are set large enough to stay readable
	# after it: a name 16 px on screen, its cost line 12 px (they were 12.6
	# and 9 px, and players had to squint).
	var compact := get_window().size.y < 850 or get_window().size.x < 1700
	var name_size := NAME_SIZE_COMPACT if compact else NAME_SIZE
	# A single word too long for the star's width (Stonewarden) is set a
	# little smaller rather than broken in the middle.
	# Only such a name spills past the star; the rest wrap at its width.
	var name_w := NODE_SIZE.x
	for word in str(n.get("name", "")).split(" "):
		while name_size > 20 and _name_font().get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, name_size).x > NODE_SIZE.x + NAME_SPILL * 2.0 - 6.0:
			name_size -= 1
		name_w = maxf(name_w, minf(NODE_SIZE.x + NAME_SPILL * 2.0, _name_font().get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, name_size).x + 6.0))
	var name_label := _label(str(n.get("name", "")), name_size, PAPER)
	name_label.add_theme_font_override("font", _name_font())
	name_label.position = Vector2((NODE_SIZE.x - name_w) * 0.5, ORB.y - 2.0)
	# Lines are stacked by the face's real height (it is about 1.36 times its
	# size), drawn a little tighter.
	var line_h := _name_font().get_height(name_size) - 6.0
	name_label.size = Vector2(name_w, line_h * 2.0 + 6.0)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	name_label.max_lines_visible = 2
	name_label.add_theme_constant_override("line_spacing", -6)
	name_label.add_theme_color_override("font_outline_color", Color(0.01, 0.015, 0.03, 0.95))
	name_label.add_theme_constant_override("outline_size", 5)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(name_label)
	# White text, coloured by its state through modulate (a muted text colour
	# under a muted modulate was dimmed twice).
	var cost_label := _label("%d SP" % int(n.get("cost", 1)), COST_SIZE_COMPACT if compact else COST_SIZE, Color.WHITE)
	cost_label.add_theme_font_override("font", ThemeDB.fallback_font)
	# Wrapped the way the label wraps it: a name that only just fits must not leave a gap.
	var two_lines: bool = _name_lines(name_label.text, name_size, name_w) > 1
	# Kept for the name plate, which is drawn every frame.
	b.set_meta("name_lines", 2 if two_lines else 1)
	var cost_h := ThemeDB.fallback_font.get_height(COST_SIZE_COMPACT if compact else COST_SIZE)
	cost_label.position = Vector2(0.0, ORB.y - 4.0 + line_h * (2.0 if two_lines else 1.0))
	cost_label.size = Vector2(NODE_SIZE.x, cost_h)
	b.set_meta("text_full_h", line_h * (2.0 if two_lines else 1.0) + cost_h - 2.0)
	b.set_meta("text_h", b.get_meta("text_full_h"))
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
	# The layout holds each star's centre; the button's box hangs from it.
	var p: Vector2 = _layout_positions.get(str(n.get("id", "")), Vector2.ZERO)
	return MARGIN + p - Vector2(NODE_SIZE.x * 0.5, 0.0)

func _focused() -> bool:
	return _branch_filter != ""

## A star's depth in its path: the longest run of prerequisites above it.
func _depth_of(n: Dictionary, depths: Dictionary) -> int:
	var id := str(n.get("id", ""))
	if depths.has(id):
		return depths[id]
	var d := 0
	for req in n.get("req", []):
		var parent := _find_node(str(req))
		if not parent.is_empty() and str(parent.get("branch", "")) == str(n.get("branch", "")) and _is_visible_node(parent):
			d = maxi(d, _depth_of(parent, depths) + 1)
	depths[id] = d
	return d

## Where a star's parents already stand, on average (0 for a root).
func _parent_x(n: Dictionary) -> float:
	var total := 0.0
	var count := 0
	for req in n.get("req", []):
		if _layout_positions.has(str(req)):
			total += (_layout_positions[str(req)] as Vector2).x
			count += 1
	return total / float(count) if count > 0 else 0.0

func _rebuild_layout() -> void:
	_layout_positions.clear()
	var lane_w := FOCUSED_LANE if _focused() else LANE
	var row_h := FOCUSED_ROW if _focused() else ROW
	var branches: Array = []
	var by_branch := {}
	for n in _nodes:
		if not _is_visible_node(n):
			continue
		var br := str(n.get("branch", ""))
		if not by_branch.has(br):
			by_branch[br] = []
			branches.append(br)
		by_branch[br].append(n)
	branches.sort_custom(func(a, b): return BRANCH_COLORS.keys().find(a) < BRANCH_COLORS.keys().find(b))
	var depths := {}
	for bi in branches.size():
		var members: Array = by_branch[branches[bi]]
		var min_x := INF
		for n in members:
			min_x = minf(min_x, (n.get("pos", Vector2.ZERO) as Vector2).x)
		# Stars of one depth stand on one row: the spine's in the middle (two
		# of them, a fork, either side of it), the side branch to the right.
		var rows := {}
		for n in members:
			var d := _depth_of(n, depths)
			if not rows.has(d):
				rows[d] = []
			rows[d].append(n)
		var row_keys: Array = rows.keys()
		row_keys.sort()
		for d in row_keys:
			var spine: Array = []
			var side: Array = []
			for n in rows[d]:
				if (n.get("pos", Vector2.ZERO) as Vector2).x - min_x > 0.01:
					side.append(n)
				else:
					spine.append(n)
			# A fork's two stars stand under their own parents, so roads never cross.
			spine.sort_custom(func(a, b):
				var pa := _parent_x(a)
				var pb := _parent_x(b)
				if absf(pa - pb) > 0.5:
					return pa < pb
				return (a.get("pos", Vector2.ZERO) as Vector2).y < (b.get("pos", Vector2.ZERO) as Vector2).y)
			for k in spine.size():
				var lane := float(k) - float(spine.size() - 1) * 0.5
				_layout_positions[str(spine[k].get("id", ""))] = Vector2(float(bi) * COLUMN + lane * lane_w, float(d) * row_h)
			for k in side.size():
				_layout_positions[str(side[k].get("id", ""))] = Vector2(float(bi) * COLUMN + (SPUR_LANE + float(k)) * lane_w, float(d) * row_h)
	# The focused path is drawn alone, from the left edge.
	if _focused():
		var left := INF
		for id in _layout_positions:
			left = minf(left, (_layout_positions[id] as Vector2).x)
		for id in _layout_positions:
			_layout_positions[id] = _layout_positions[id] - Vector2(left - lane_w * 0.5, 0.0)
	else:
		for id in _layout_positions:
			_layout_positions[id] = _layout_positions[id] + Vector2(LANE, 0.0)

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
	for id in _layout_positions:
		max_x = maxf(max_x, (_layout_positions[id] as Vector2).x)
		max_y = maxf(max_y, (_layout_positions[id] as Vector2).y)
	_canvas.custom_minimum_size = MARGIN * 2.0 + Vector2(max_x + NODE_SIZE.x * 0.5, max_y + (NODE_SIZE.y if _focused() else ORB.y))
	_canvas.size = _canvas.custom_minimum_size
	_apply_transform()

func _fit_default_zoom() -> void:
	if not is_instance_valid(_viewport) or _viewport.size.x <= 0.0:
		return
	# Focused paths are taller than the view. Open on complete, readable stars
	# and let players drag down for the rest instead of cutting a card at the rail.
	var target := FOCUSED_ZOOM if _branch_filter != "" else GRAPH_ZOOM
	if _branch_filter == "":
		# The whole sky in view, as large as the window allows.
		var fit := minf((_viewport.size.x - 36.0) / maxf(1.0, _canvas.size.x), (_viewport.size.y - 24.0) / maxf(1.0, _canvas.size.y))
		target = clampf(fit, 0.45, 0.9)
	_zoom = clampf(target, 0.45, 1.16)
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
	_zoom = clampf(z, 0.45, 1.16)
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
## Light running from a claimed star to each star it opens: {from, to, t, col}.
var _comets: Array = []
const COMET_TIME := 0.8
## Shooting stars over the sky: {from, dir, speed, t}.
var _shooting: Array = []
var _next_shooting := 1.5
var _fx_rng := RandomNumberGenerator.new()
## The soft round light every glow is drawn with.
var _glow_tex: Texture2D = _make_glow_texture()

static func _make_glow_texture() -> Texture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.22, 0.55, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0.14), Color(1, 1, 1, 0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 128
	t.height = 128
	return t

## How much of a broad glow to show at a point: fades out toward the edges
## of the visible sky, so the clouds never end in a hard line at the frame.
func _edge_fade(at: Vector2) -> float:
	var z := maxf(0.1, _zoom)
	var view := Rect2(-_canvas.position / z, _viewport.size / z)
	var d := minf(minf(at.x - view.position.x, view.end.x - at.x), minf(at.y - view.position.y, view.end.y - at.y))
	return clampf(d / (260.0 / z), 0.0, 1.0)

func _glow(canvas: CanvasItem, at: Vector2, radius: float, col: Color) -> void:
	canvas.draw_texture_rect(_glow_tex, Rect2(at - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false, col)

## Owned share of each path, for how brightly its part of the sky burns.
func _branch_progress() -> Dictionary:
	var out := {}
	for n in _nodes:
		if not _is_visible_node(n):
			continue
		var br := str(n.get("branch", ""))
		var row: Array = out.get(br, [0, 0])
		row[1] += 1
		if _is_unlocked(str(n.get("id", ""))):
			row[0] += 1
		out[br] = row
	return out
var _sky_time := 0.0
## One shared style for the name plates (the sky redraws every frame).
var _name_plate_style: StyleBoxFlat = _make_name_plate_style()

static func _make_name_plate_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.02, 0.025, 0.05, 0.72)
	sb.set_corner_radius_all(8)
	return sb

func _process(delta: float) -> void:
	_sky_time += delta
	if is_instance_valid(_canvas) and is_visible_in_tree():
		_canvas.queue_redraw()
		for layer in _layers:
			layer.queue_redraw()
	if not _bursts.is_empty():
		_bursts = _bursts.filter(func(b): return _sky_time - float(b["t"]) < 1.2)
	if not _comets.is_empty():
		_comets = _comets.filter(func(c): return _sky_time - float(c["t"]) < COMET_TIME + 0.7)
	if not _shooting.is_empty():
		_shooting = _shooting.filter(func(st): return _sky_time - float(st["t"]) < 1.1)
	# Now and then a shooting star crosses the sky.
	if _sky_time >= _next_shooting and is_instance_valid(_canvas):
		_next_shooting = _sky_time + _fx_rng.randf_range(2.5, 6.0)
		var area := _canvas.size
		var dir := Vector2(_fx_rng.randf_range(0.55, 1.0) * (1.0 if _fx_rng.randf() < 0.5 else -1.0), _fx_rng.randf_range(0.35, 0.7)).normalized()
		_shooting.append({"from": Vector2(_fx_rng.randf() * area.x, _fx_rng.randf() * area.y * 0.6), "dir": dir,
			"speed": _fx_rng.randf_range(700.0, 1100.0), "t": _sky_time})

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
	# The sky drifts slower than the stars when dragged, so it reads as far away.
	var parallax := -_pan * 0.35 / maxf(0.1, _zoom)
	for st in _sky:
		var tw := 0.35 + 0.65 * (0.5 + 0.5 * sin(_sky_time * float(st["sp"]) + float(st["ph"])))
		var col := Color(0.85, 0.9, 1.0) if float(st["tint"]) < 0.8 else Color(1.0, 0.85, 0.6)
		canvas.draw_circle(Vector2(st["p"]) - Vector2(300, 300) + parallax, float(st["r"]), Color(col, 0.55 * tw))
	# Nebulae: soft clouds of each path's colour around its stars.
	var branch_pts := {}
	for n in _nodes:
		if _node_buttons.has(str(n.get("id", ""))) and _is_visible_node(n):
			var br := str(n.get("branch", ""))
			if not branch_pts.has(br):
				branch_pts[br] = []
			branch_pts[br].append(_orb_center(n))
	# The first stars drift a little off the grid; their names do not, so the
	# headings of all the paths stand on one line.
	var top_line := INF
	for br in branch_pts:
		for p3 in branch_pts[br]:
			top_line = minf(top_line, p3.y)
	var progress := _branch_progress()
	for br in branch_pts:
		var pts: Array = branch_pts[br]
		var bc: Color = _branch_color(br)
		# The constellation's name, large and faint above its first star.
		var top: Vector2 = pts[0]
		for p2 in pts:
			if p2.y < top.y:
				top = p2
		var title: String = String(br).to_upper()
		# Sized to reach the eye at about 18 px on a laptop window.
		# The overview is drawn smaller, so its headings are set larger.
		var big := 1.0 if _focused() else 1.45
		var tfs := roundi(34 * big)
		var tw2 := _title_font().get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, tfs).x
		# Readable over the night sky: a dark outline under a brighter name,
		# lifted clear of the first star's selection rings.
		# Centred over its path, with the count on its own line beneath (side
		# by side, the longer names ran into the next path's heading).
		var title_pos := Vector2(top.x - tw2 * 0.5, top_line - 100.0 * big)
		# A finished path wears its name in gold, haloed and breathing.
		var finished: bool = int(progress.get(br, [0, 1])[0]) >= int(progress.get(br, [0, 1])[1])
		if finished:
			var breath := 0.5 + 0.5 * sin(_sky_time * 1.6)
			canvas.draw_string_outline(_title_font(), title_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, tfs, 22, Color(GOLD_BRIGHT, 0.10 + 0.08 * breath))
			canvas.draw_string_outline(_title_font(), title_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, tfs, 12, Color(GOLD_BRIGHT, 0.16 + 0.10 * breath))
		canvas.draw_string_outline(_title_font(), title_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, tfs, 6, Color(0.01, 0.015, 0.03, 0.85))
		canvas.draw_string(_title_font(), title_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, tfs, GOLD_BRIGHT if finished else Color(bc.lightened(0.35), 0.97))
		# How far along the path is: a thin bar that fills, and a count.
		var pr: Array = progress.get(br, [0, 1])
		var frac := float(pr[0]) / maxf(1.0, float(pr[1]))
		var count := "%d / %d" % [pr[0], pr[1]]
		var body := ThemeDB.fallback_font
		var cfs := roundi(24 * big)
		var cw := body.get_string_size(count, HORIZONTAL_ALIGNMENT_LEFT, -1, cfs).x
		var count_pos := Vector2(top.x - cw * 0.5, top_line - 66.0 * big)
		canvas.draw_string_outline(body, count_pos, count, HORIZONTAL_ALIGNMENT_LEFT, -1.0, cfs, 6, Color(0.01, 0.015, 0.03, 0.9))
		canvas.draw_string(body, count_pos, count, HORIZONTAL_ALIGNMENT_LEFT, -1.0, cfs, Color(PAPER, 0.92))
		var bar_w := maxf(cw + 40.0, tw2 * 0.7)
		var bar := Rect2(top.x - bar_w * 0.5, top_line - 58.0 * big, bar_w, 4.0)
		canvas.draw_rect(bar, Color(0.01, 0.015, 0.03, 0.85))
		canvas.draw_rect(Rect2(bar.position, Vector2(bar_w * frac, 4.0)), Color(bc.lightened(0.3), 0.95))
	# Links: faint for locked, bright for open paths, with motes of light
	# flowing along the owned ones toward the next star.
	var label_rects := _label_rects()
	for n in _nodes:
		var id := str(n.get("id", ""))
		if not _node_buttons.has(id) or not _is_visible_node(n):
			continue
		var to := _orb_center(n)
		for req in n.get("req", []):
			var required := _find_node(str(req))
			if required.is_empty() or not _node_buttons.has(req) or not _is_visible_node(required):
				continue
			var complete := _is_unlocked(id) and _is_unlocked(req)
			var available := _prereqs_met(n) and not _is_unlocked(id)
			var col := MINT if complete else GOLD_BRIGHT if available else LOCKED
			var path := _link_path(required, n)
			# Broken where it passes behind a star's name, so no line runs
			# through the words.
			var pieces := _split_by_labels(path, label_rects)
			if not (complete or available):
				# A road not yet open: a thin line in the path's own colour, so
				# every path reads as one chain of stars from the start.
				var faint: Color = _branch_color(str(n.get("branch", ""))).lightened(0.15)
				for piece in pieces:
					canvas.draw_polyline(piece, Color(faint, 0.10), 6.0, true)
					canvas.draw_polyline(piece, Color(faint, 0.42), 1.6, true)
				continue
			var strength := 0.9 if complete else 0.75
			# Every star of the path owned: a gold wave runs down it, star to star.
			var path_done: bool = complete and int(progress.get(str(n.get("branch", "")), [0, 1])[0]) >= int(progress.get(str(n.get("branch", "")), [0, 1])[1])
			if path_done:
				var wave := 0.5 + 0.5 * sin(_sky_time * 2.4 - to.y * 0.012)
				for piece in pieces:
					canvas.draw_polyline(piece, Color(GOLD_BRIGHT, 0.10 + 0.14 * wave), 18.0, true)
					canvas.draw_polyline(piece, Color(GOLD_BRIGHT, 0.35 + 0.35 * wave), 4.0, true)
			for piece in pieces:
				canvas.draw_polyline(piece, Color(col, strength * 0.10), 12.0, true)
				canvas.draw_polyline(piece, Color(col, strength * 0.40), 3.4, true)
				canvas.draw_polyline(piece, Color(PAPER, strength * 0.55), 1.0, true)
			if complete or available:
				var motes := (6 if path_done else 3) if complete else 2
				for m in motes:
					var t := fmod(_sky_time * (0.28 if complete else 0.18) + float(m) / float(motes) + float(id.hash() % 97) / 97.0, 1.0)
					var idx := t * float(path.size() - 1)
					var i0 := int(idx)
					var p3: Vector2 = path[i0].lerp(path[mini(i0 + 1, path.size() - 1)], idx - float(i0))
					if _in_any_rect(p3, label_rects):
						continue
					canvas.draw_circle(p3, 5.0, Color(col, 0.18))
					canvas.draw_circle(p3, 2.4, Color(col.lightened(0.4), 0.9))

func _draw_layer(canvas: CanvasItem, pass_name: String) -> void:
	match pass_name:
		"glow":
			_draw_glow(canvas)
		"plates":
			_draw_plates(canvas)
		"fx":
			_draw_fx(canvas)
		"tag":
			_draw_name_tag(canvas)

## The overview names no stars, so the one under the pointer gets a card
## over it: its name and cost, sized to read about 18 px on a laptop.
func _draw_name_tag(canvas: CanvasItem) -> void:
	if _focused() or _hovered_id == "":
		return
	var n := _find_node(_hovered_id)
	if n.is_empty() or not _is_visible_node(n):
		return
	var z := maxf(0.3, _zoom)
	var fs := roundi(25.0 / z)
	var cs := roundi(19.0 / z)
	var font := _name_font()
	var title := str(n.get("name", ""))
	var state := _node_state(n)
	var sub := "OWNED" if state == "UNLOCKED" else "%d SP  ·  %s" % [int(n.get("cost", 1)), _node_tag(n)]
	var tw := maxf(font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x, ThemeDB.fallback_font.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, cs).x)
	var pad := 14.0 / z
	var h := font.get_height(fs) + ThemeDB.fallback_font.get_height(cs) + pad * 1.4
	var c := _orb_center(n)
	var box := Rect2(c.x - tw * 0.5 - pad, c.y - ORB.y * 0.62 - h - 8.0 / z, tw + pad * 2.0, h)
	# Kept inside the visible sky (a star at the edge had its card cut).
	var view := Rect2(-_canvas.position / z, _viewport.size / z).grow(-6.0 / z)
	box.position.x = clampf(box.position.x, view.position.x, maxf(view.position.x, view.end.x - box.size.x))
	if box.position.y < view.position.y:
		box.position.y = c.y + ORB.y * 0.62 + 8.0 / z
	var shift := box.get_center().x - c.x
	var bc := _branch_color(str(n.get("branch", "")))
	var plate := StyleBoxFlat.new()
	plate.bg_color = Color(0.03, 0.035, 0.06, 0.96)
	plate.border_color = Color(GOLD, 0.9)
	plate.set_border_width_all(maxi(1, roundi(2.0 / z)))
	plate.border_width_top = maxi(2, roundi(3.0 / z))
	plate.set_corner_radius_all(roundi(6.0 / z))
	plate.shadow_color = Color(0, 0, 0, 0.6)
	plate.shadow_size = roundi(10.0 / z)
	canvas.draw_style_box(plate, box)
	canvas.draw_line(Vector2(box.position.x + pad, box.position.y + plate.border_width_top + 1.0), Vector2(box.end.x - pad, box.position.y + plate.border_width_top + 1.0), Color(bc, 0.7), 2.0 / z)
	var ty := box.position.y + pad * 0.6 + font.get_ascent(fs)
	c.x += shift
	canvas.draw_string(font, Vector2(c.x - font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x * 0.5, ty), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, fs, PAPER)
	var sub_col := GOLD_BRIGHT if state == "PURCHASABLE" else MINT if state == "UNLOCKED" else MUTED
	canvas.draw_string(ThemeDB.fallback_font, Vector2(c.x - ThemeDB.fallback_font.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, cs).x * 0.5, ty + font.get_descent(fs) + ThemeDB.fallback_font.get_ascent(cs) + 2.0 / z), sub, HORIZONTAL_ALIGNMENT_LEFT, -1.0, cs, sub_col)

## Added light under the stars: each path's nebula burns brighter the more of
## it you own, owned stars bloom with a slow four-point flare, stars ready to
## claim breathe gold and shed sparks, and shooting stars cross the sky.
func _draw_glow(canvas: CanvasItem) -> void:
	var progress := _branch_progress()
	# A river of faint light across the whole sky, like the Milky Way, drifting
	# slower than the stars when the sky is dragged.
	var area := _canvas.size
	var parallax := -_pan * 0.35 / maxf(0.1, _zoom)
	for k in 26:
		var f := float(k) / 25.0
		var along := Vector2(-200.0, area.y * 0.95).lerp(Vector2(area.x + 200.0, area.y * 0.05), f)
		var bend := Vector2(0.0, sin(f * PI * 1.4) * area.y * 0.12)
		var hue := Color(0.42, 0.30, 0.78).lerp(Color(0.25, 0.45, 0.85), 0.5 + 0.5 * sin(f * 7.0))
		var shimmer := 0.8 + 0.2 * sin(_sky_time * 0.4 + f * 9.0)
		var at := along + bend + parallax + Vector2(sin(f * 31.0) * 60.0, cos(f * 17.0) * 50.0)
		_glow(canvas, at, 230.0 + 90.0 * sin(f * 13.0) ** 2, Color(hue, 0.34 * shimmer * _edge_fade(at)))
	var by_branch := {}
	for n in _nodes:
		if _node_buttons.has(str(n.get("id", ""))) and _is_visible_node(n):
			var br := str(n.get("branch", ""))
			if not by_branch.has(br):
				by_branch[br] = []
			by_branch[br].append(_orb_center(n))
	for br in by_branch:
		var pts: Array = by_branch[br]
		var bc: Color = _branch_color(br)
		var pr: Array = progress.get(br, [0, 1])
		var frac := float(pr[0]) / maxf(1.0, float(pr[1]))
		for k in pts.size():
			if k % 2 == 1:
				continue
			var p: Vector2 = pts[k]
			var breathe := 0.85 + 0.15 * sin(_sky_time * 0.5 + float(k) * 1.3 + float(br.hash() % 11))
			var drift := Vector2(sin(_sky_time * 0.11 + k) * 18.0, cos(_sky_time * 0.09 + k * 1.7) * 14.0)
			var at2 := p + drift + Vector2(sin(k * 1.7) * 40.0, cos(k * 2.3) * 30.0)
			_glow(canvas, at2, 250.0, Color(bc, (0.40 + 0.55 * frac) * breathe * _edge_fade(at2)))
	# Owned roads glow along their whole length (but not across a name).
	var glow_rects := _label_rects()
	for n in _nodes:
		var id := str(n.get("id", ""))
		if not _node_buttons.has(id) or not _is_visible_node(n) or not _is_unlocked(id):
			continue
		for req in n.get("req", []):
			var required := _find_node(str(req))
			if required.is_empty() or not _node_buttons.has(req) or not _is_visible_node(required) or not _is_unlocked(str(req)):
				continue
			for piece in _split_by_labels(_link_path(required, n), glow_rects):
				canvas.draw_polyline(piece, Color(_branch_color(str(n.get("branch", ""))), 0.22), 14.0, true)
	for n in _nodes:
		var id := str(n.get("id", ""))
		if not _node_buttons.has(id) or not _is_visible_node(n):
			continue
		var c := _orb_center(n)
		var bc: Color = _branch_color(str(n.get("branch", "")))
		var state := _node_state(n)
		var seed := float(id.hash() % 101)
		if state == "UNLOCKED":
			var keystone: bool = n.get("keystone", false)
			_glow(canvas, c, 120.0 if keystone else 92.0, Color(bc.lightened(0.25), 0.55))
			_glow(canvas, c, 40.0, Color(1, 1, 1, 0.35))
			# A slow four-point flare, like a bright star through a lens.
			var spin := _sky_time * 0.12 + seed
			var reach := (110.0 if keystone else 78.0) * (0.9 + 0.1 * sin(_sky_time * 1.3 + seed))
			for q in 4:
				var a := spin + q * PI * 0.5
				var tip := Vector2(cos(a), sin(a))
				var side := Vector2(-tip.y, tip.x) * 3.2
				canvas.draw_colored_polygon(PackedVector2Array([c + side, c + tip * reach, c - side]), Color(bc.lightened(0.5), 0.5))
		elif state == "PURCHASABLE":
			var pulse := 0.5 + 0.5 * sin(_sky_time * 3.2 + seed)
			_glow(canvas, c, 78.0 + 10.0 * pulse, Color(GOLD_BRIGHT, 0.20 + 0.20 * pulse))
			# Sparks rising off a star that is ready to claim.
			for m in 4:
				var t := fmod(_sky_time * 0.55 + float(m) / 4.0 + seed * 0.13, 1.0)
				var sp := c + Vector2(sin(seed + m * 2.1) * 30.0 + sin(t * 6.0 + m) * 6.0, -38.0 - t * 52.0)
				canvas.draw_circle(sp, 2.6 * (1.0 - t) + 0.6, Color(GOLD_BRIGHT, 0.9 * (1.0 - t)))
	for st in _shooting:
		var age := _sky_time - float(st["t"])
		var dir: Vector2 = st["dir"]
		var head: Vector2 = Vector2(st["from"]) + dir * float(st["speed"]) * age
		var fade := clampf(1.0 - age / 1.1, 0.0, 1.0) * clampf(age * 6.0, 0.0, 1.0)
		for k in 8:
			var a2 := head - dir * float(k) * 22.0
			var b2 := head - dir * float(k + 1) * 22.0
			canvas.draw_line(a2, b2, Color(0.85, 0.92, 1.0, fade * 0.8 * (1.0 - float(k) / 8.0)), 2.4 * (1.0 - float(k) / 9.0), true)
		_glow(canvas, head, 22.0, Color(0.85, 0.92, 1.0, fade * 0.8))

func _draw_plates(canvas: CanvasItem) -> void:
	# The selected star wears two counter-turning gilt rings,
	# drawn under the name plates so they never cross the star's name.
	var sel := _find_node(_selected_id)
	if not sel.is_empty() and _is_visible_node(sel):
		var sc2 := _orb_center(sel)
		var rr2 := ORB.x * 0.56
		for q in 3:
			var a4 := _sky_time * 0.9 + q * TAU / 3.0
			canvas.draw_arc(sc2, rr2, a4, a4 + 1.3, 20, Color(GOLD_BRIGHT, 0.85), 2.2, true)
			var a5 := -_sky_time * 0.6 + q * TAU / 3.0
			canvas.draw_arc(sc2, rr2 + 7.0, a5, a5 + 0.8, 14, Color(GOLD_BRIGHT, 0.45), 1.4, true)
	# A soft pool of shadow behind each name (it was a hard dark box, and the
	# whole sky read as a grid of them) keeps the nebulae from washing it out.
	if not _focused():
		return
	for n in _nodes:
		var nid := str(n.get("id", ""))
		if not _node_buttons.has(nid) or not _is_visible_node(n):
			continue
		var b: Button = _node_buttons[nid]
		var lab: Label = b.get_child(1) as Label
		var fs := lab.get_theme_font_size("font_size")
		var tw3 := minf(NODE_SIZE.x + NAME_SPILL * 2.0 + 8.0, _name_font().get_string_size(lab.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 22.0)
		var lines: int = b.get_meta("name_lines") if b.has_meta("name_lines") else 1
		var plate_h: float = (b.get_meta("text_h") if b.has_meta("text_h") else (fs + 1.0) * lines + fs) + 6.0
		var plate := Rect2(b.position + Vector2((NODE_SIZE.x - tw3) * 0.5, ORB.y - 4.0), Vector2(tw3, plate_h)).grow_individual(26.0, 14.0, 26.0, 18.0)
		canvas.draw_texture_rect(_glow_tex, plate, false, Color(0.0, 0.0, 0.02, 0.62))

## Added light over everything: the claim flash, its rings and sparks, and
## light running down each road the claimed star opens.
func _draw_fx(canvas: CanvasItem) -> void:
	for b in _bursts:
		var age0 := (_sky_time - float(b["t"])) / 0.6
		if age0 < 1.0:
			_glow(canvas, b["pos"], 140.0 + age0 * 260.0, Color(Color(b["col"]).lightened(0.3), 0.55 * (1.0 - age0)))
	for cm in _comets:
		var age := (_sky_time - float(cm["t"])) / COMET_TIME
		var path := _constellation_link(cm["from"], cm["to"])
		var col: Color = cm["col"]
		if age < 1.0:
			for k in 6:
				var t := clampf(age - float(k) * 0.035, 0.0, 1.0)
				var idx := t * float(path.size() - 1)
				var i0 := int(idx)
				var pt: Vector2 = path[i0].lerp(path[mini(i0 + 1, path.size() - 1)], idx - float(i0))
				_glow(canvas, pt, 26.0 - k * 3.0, Color(col.lightened(0.4), 0.9 - k * 0.14))
		else:
			# Arrival: the opened star flares once.
			var a2 := (age - 1.0) * COMET_TIME / 0.7
			_glow(canvas, cm["to"], 60.0 + a2 * 70.0, Color(GOLD_BRIGHT, 0.7 * (1.0 - a2)))
			canvas.draw_arc(cm["to"], 40.0 + a2 * 50.0, 0.0, TAU, 36, Color(GOLD_BRIGHT, 0.8 * (1.0 - a2)), 2.0, true)
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

## The road between two stars: out of the bottom of the upper star (below
## its name, when names are shown), then one smooth S down into the top of
## the lower star. Rows are level and forks stand side by side, so a road
## never passes behind another star or its name.
func _link_path(required: Dictionary, n: Dictionary) -> PackedVector2Array:
	var from := _orb_center(required)
	var to := _orb_center(n)
	from.y += ORB.y * 0.5 - 2.0
	if _focused():
		var b: Button = _node_buttons.get(str(required.get("id", "")))
		var text_h: float = float(b.get_meta("text_h")) if is_instance_valid(b) and b.has_meta("text_h") else 60.0
		from.y += text_h + 6.0
	to.y -= ORB.y * 0.5 - 2.0
	var points := PackedVector2Array()
	if absf(to.x - from.x) < 1.0:
		for step in range(9):
			points.append(from.lerp(to, float(step) / 8.0))
		return points
	var pull := (to.y - from.y) * 0.62
	var c1 := from + Vector2(0.0, pull)
	var c2 := to - Vector2(0.0, pull)
	for step in range(25):
		var t := float(step) / 24.0
		var u := 1.0 - t
		points.append(from * u * u * u + c1 * 3.0 * u * u * t + c2 * 3.0 * u * t * t + to * t * t * t)
	return points

## Where each visible star's name and cost are written, a little grown.
func _label_rects() -> Array:
	var rects: Array = []
	if not _focused():
		return rects
	for n in _nodes:
		var nid := str(n.get("id", ""))
		if not _node_buttons.has(nid) or not _is_visible_node(n):
			continue
		var b: Button = _node_buttons[nid]
		var lab: Label = b.get_child(1) as Label
		var fs := lab.get_theme_font_size("font_size")
		var lines: int = b.get_meta("name_lines") if b.has_meta("name_lines") else 1
		var name_w := 0.0
		for part in (lab.text.split("
") if "
" in lab.text else PackedStringArray([lab.text])):
			name_w = maxf(name_w, _name_font().get_string_size(part, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
		if lines > 1 and not "
" in lab.text:
			# Wrapped: as wide as the label's box.
			name_w = minf(name_w, lab.size.x if lab.size.x > 0.0 else name_w * 0.62)
		var tw := clampf(name_w, 90.0, NODE_SIZE.x + NAME_SPILL * 2.0) + 12.0
		var text_h: float = b.get_meta("text_h") if b.has_meta("text_h") else (fs + 1.0) * lines + fs
		rects.append(Rect2(b.position + Vector2((NODE_SIZE.x - tw) * 0.5, ORB.y - 6.0), Vector2(tw, text_h + 10.0)))
	return rects

func _in_any_rect(p: Vector2, rects: Array) -> bool:
	for r in rects:
		if (r as Rect2).has_point(p):
			return true
	return false

## A link cut into the pieces that lie outside every name: resampled every
## few pixels, so a gap ends close to the words.
func _split_by_labels(path: PackedVector2Array, rects: Array) -> Array:
	var pieces: Array = []
	var current := PackedVector2Array()
	for i in path.size():
		var a: Vector2 = path[i]
		var steps := 1
		if i + 1 < path.size():
			steps = maxi(1, int(a.distance_to(path[i + 1]) / 4.0))
		for s in steps:
			var p: Vector2 = a if i + 1 >= path.size() else a.lerp(path[i + 1], float(s) / float(steps))
			if _in_any_rect(p, rects):
				if current.size() >= 2:
					pieces.append(current)
				current = PackedVector2Array()
			else:
				current.append(p)
	if current.size() >= 2:
		pieces.append(current)
	return pieces

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
		# An owned star says so, as the legend does; its price no longer matters.
		cost_label.text = "OWNED" if _node_state(n) == "UNLOCKED" else "%d SP  ·  %s" % [int(n.get("cost", 1)), _node_tag(n)]
		cost_label.modulate = GOLD_BRIGHT if state == "PURCHASABLE" else MINT if state == "UNLOCKED" else MUTED
		var name_label: Label = b.get_child(1) as Label
		name_label.modulate = Color(1, 1, 1, 1) if state != "PREREQUISITE_BLOCKED" else Color(0.86, 0.88, 0.94, 0.96)
		# Names are written under the stars of a focused path; the overview
		# shows the stars alone and a card for the one under the pointer.
		name_label.visible = _focused()
		cost_label.visible = _focused()
		b.set_meta("text_h", float(b.get_meta("text_full_h")) if _focused() else 0.0)
		# In the overview a star is just its orb, so its middle is the orb.
		var box := NODE_SIZE if _focused() else Vector2(NODE_SIZE.x, ORB.y)
		b.custom_minimum_size = box
		b.size = box
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
			# Plan 358: only the orb swells. Scaling the whole 200 x 206
			# button (orb and the name space under it) grew its click area
			# over the stars below; the pointer then stayed on the hovered
			# star and the one beneath could not be reached.
			glyph.create_tween().tween_property(glyph, "scale", want, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
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
	var texture: Texture2D = SkillIcons.texture_for(id, 128)
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
			# Light runs down every road this star opens.
			for child in _nodes:
				if id in child.get("req", []) and _node_buttons.has(str(child.get("id", ""))) and _is_visible_node(child) and _prereqs_met(child):
					_comets.append({"from": _orb_center(n), "to": _orb_center(child), "t": _sky_time, "col": _branch_color(str(n.get("branch", "")))})
			var claimed: Button = _node_buttons[id]
			claimed.scale = Vector2.ONE * 1.35
			claimed.set_meta("scaling_to", Vector2.ONE)
			claimed.create_tween().tween_property(claimed, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			_status_label.text = "%s joined your constellation." % str(n.get("name", ""))
		else:
			Sfx.play("select")
	else:
		Sfx.play("select")
		_detail_action.text = "LOCKED  •  See what it requires above"
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
	_detail_meta.text = "COST  %d SKILL POINT%s\nSTATE  %s" % [int(n.get("cost", 1)), "" if int(n.get("cost", 1)) == 1 else "S", String({"UNLOCKED": "OWNED", "PURCHASABLE": "READY TO CLAIM", "INSUFFICIENT_POINTS": "NEED MORE POINTS", "PREREQUISITE_BLOCKED": "LOCKED"}.get(state, state.replace("_", " ")))]
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
		_detail_action.text = "OWNED  •  This power is active in your build"
	elif state == "PURCHASABLE":
		_detail_action.text = "READY TO CLAIM  •  Click to spend %d point%s" % [int(n.get("cost", 1)), "" if int(n.get("cost", 1)) == 1 else "s"]
	elif state == "INSUFFICIENT_POINTS":
		_detail_action.text = "NEED MORE POINTS  •  Your hero earns one with every level"
	else:
		_detail_action.text = "LOCKED  •  Claim the star before it first"

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
	# Plan 384: the main menu's forged faces and title lettering, as on the
	# other pages' footers (the theme's flat box looked unfinished here).
	FORGED_FACES.forge_button(b, false, 20)
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
	var dlg: Control = load("res://scripts/ui/gilt_confirm.gd").ask(self, "Respec Constellation", "Refund all unlocked skills? Your skill points will be returned.", "Refund Skills")
	dlg.confirmed.connect(func(): ProfileManager.respec_skills())

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)
