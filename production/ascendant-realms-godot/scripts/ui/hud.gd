extends Control
## In-battle HUD for Ascendant Realms. Built entirely in code inside setup().
## Owns the resource top bar, minimap, selection panel, context command card,
## alert feed and the game-over screen. Reads from GameWorld / RTSController /
## Commander and connects to their signals; guards every handler against freed
## nodes because units and buildings free themselves on death.

signal pause_requested
signal return_to_menu
signal replay

const FONT_PATH := "res://assets/fonts/cinzel.ttf"
const THEME_PATH := "res://assets/ui/theme.tres"
const FRAME_PORTRAIT := "res://assets/ui/frame_portrait.png"
const ENTITY_PORTRAIT_SCRIPT := "res://scripts/ui/entity_portrait_view.gd"
const MAP_HALF := 140.0                # MapDefs.MAP_SIZE — world spans -140..140
const MINIMAP_SIZE := 200.0
const MINIMAP_RASTER_SIZE := 128
const MINIMAP_PANEL_HEIGHT := MINIMAP_SIZE + 68.0
const MINIMAP_GRID_DIVISIONS := 4
const MINIMAP_VIEW_FILL := Color(0.88, 0.93, 0.86, 0.08)
const MINIMAP_VIEW_EDGE := Color(0.96, 0.92, 0.68, 0.96)
const COMMAND_PANEL_WIDTH := 390.0
const FONT_COLOR := Color(0.95, 0.9, 0.8)
const PLAYER_ALERT_LIMIT := 1
const DEBUG_REVIEW_ALERT_LIMIT := 4
const RES_ICONS := {
	"food": "res://assets/ui/icon_food.png",
	"timber": "res://assets/ui/icon_timber.png",
	"stone": "res://assets/ui/icon_stone.png",
	"gold": "res://assets/ui/icon_gold.png",
}
const RES_ORDER := ["food", "timber", "stone", "gold"]
const TIER_NAMES := {1: "Age I", 2: "Age II", 3: "Age III"}

# --- refs ---
var world = null
var rts = null
var _commander = null                  # player_commander shortcut
var _font: FontFile = null
var _body_font: Font = null

# --- top bar labels ---
var _res_labels := {}                  # kind -> Label
var _pop_label: Label = null
var _idle_worker_label: Label = null
var _tier_label: Label = null
var _top_panel: PanelContainer = null
var _menu_button: Button = null

# --- minimap ---
var _minimap: Control = null
var _minimap_background: ImageTexture = null
var _minimap_background_key := ""
var _minimap_panel: PanelContainer = null

# --- selection / command panels (rebuilt on selection change) ---
var _sel_panel: PanelContainer = null
var _sel_body: Control = null
var _cmd_panel: PanelContainer = null
var _cmd_body: Control = null

# live-tracked selection widgets (refreshed in _process)
var _tracked_single = null             # currently shown single Unit/Building
var _single_hp_bar: ProgressBar = null
var _single_hp_text: Label = null
var _single_mana_bar: ProgressBar = null
var _single_stat_label: Label = null
var _single_economy_label: Label = null
var _ability_widgets := []             # [{id, button, cd_overlay}]
var _multi_bars := []                  # [{unit, bar}]
var _queue_container: HBoxContainer = null
var _watched_building = null           # building whose production we listen to

# --- alerts ---
var _alert_box: VBoxContainer = null

# --- game over ---
var _gameover_layer: Control = null
var _command_feedback_box: PanelContainer = null

# --- refresh cadence ---
var _slow_accum := 0.0
var _map_accum := 0.0
var _last_viewport_size := Vector2.ZERO

func _debug_review_presentation() -> bool:
	# Keep the player-facing HUD quiet while allowing capture/diagnostic runs to
	# retain the full alert history for review evidence. This is presentation
	# only; the world alert signal and its authoritative state remain unchanged.
	return OS.get_environment("ASCENDANT_GOLDEN_BATTLE_DEBUG_REVIEW") == "1" or OS.get_environment("ASCENDANT_HP4_M20_DIAGNOSTICS") == "1"

func _m20_recorder():
	if OS.get_environment("ASCENDANT_HP4_M20_DIAGNOSTICS") != "1":
		return null
	var recorder = get_node_or_null("/root/HP4M20Startup")
	return recorder if is_instance_valid(recorder) else null

func _m20_begin(stage: String, parent_stage: String = "", depth: int = 0) -> Dictionary:
	var recorder = _m20_recorder()
	return recorder.begin_stage(stage, parent_stage, depth) if recorder else {}

func _m20_end(token: Dictionary) -> void:
	var recorder = _m20_recorder()
	if recorder:
		recorder.end_stage(token)


func setup(p_world, p_rts) -> void:
	var stage := _m20_begin("HUD_SETUP")
	world = p_world
	rts = p_rts
	_commander = world.player_commander if world else null
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var recorder = _m20_recorder()
	if ResourceLoader.exists(THEME_PATH):
		var theme_start := Time.get_ticks_usec()
		theme = load(THEME_PATH)
		if recorder:
			recorder.record_resource_load(THEME_PATH, "hud.setup", theme_start, Time.get_ticks_usec(), "load")
	if ResourceLoader.exists(FONT_PATH):
		var font_start := Time.get_ticks_usec()
		_font = load(FONT_PATH)
		if recorder:
			recorder.record_resource_load(FONT_PATH, "hud.setup", font_start, Time.get_ticks_usec(), "load")
	_body_font = ThemeDB.fallback_font

	_build_top_bar()
	_build_minimap()
	_build_selection_panel()
	_build_command_panel()
	_build_alert_feed()
	_fit_to_viewport()

	_connect_signals()
	# prime displays
	if _commander:
		_on_resources_changed(_commander.resources)
		_on_pop_changed(_commander.pop_used, _commander.pop_cap)
		_on_tier_changed(_commander.tier)
	_rebuild_selection([])
	_last_viewport_size = get_viewport_rect().size
	_m20_end(stage)


func _fit_to_viewport() -> void:
	# HUD controls are anchored to the live client viewport. Keep the authored
	# visual design at normal sizes, but derive the bottom inset from the actual
	# viewport so windowed/maximized launches cannot place controls below it.
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var margin := 12.0
	var selection_height := minf(156.0, maxf(128.0, viewport_size.y - margin * 2.0))
	var command_height := minf(360.0, maxf(220.0, viewport_size.y - margin * 2.0))
	if is_instance_valid(_minimap_panel):
		_minimap_panel.offset_left = margin
		_minimap_panel.offset_right = margin + MINIMAP_SIZE + 24.0
		_minimap_panel.offset_top = -margin - MINIMAP_PANEL_HEIGHT
		_minimap_panel.offset_bottom = -margin
	if is_instance_valid(_sel_panel):
		_sel_panel.offset_left = -240.0
		_sel_panel.offset_right = 240.0
		_sel_panel.offset_top = -margin - selection_height
		_sel_panel.offset_bottom = -margin
	if is_instance_valid(_cmd_panel):
		_cmd_panel.offset_left = -COMMAND_PANEL_WIDTH
		_cmd_panel.offset_right = -margin
		_cmd_panel.offset_top = -margin - command_height
		_cmd_panel.offset_bottom = -margin
	if is_instance_valid(_menu_button):
		_menu_button.offset_left = -104.0
		_menu_button.offset_right = -margin


func _connect_signals() -> void:
	if _commander:
		_commander.resources_changed.connect(_on_resources_changed)
		_commander.pop_changed.connect(_on_pop_changed)
		_commander.tier_changed.connect(_on_tier_changed)
	if rts:
		rts.selection_changed.connect(_on_selection_changed)
		if rts.has_signal("command_feedback_changed"):
			rts.command_feedback_changed.connect(_on_command_feedback_changed)
	if world:
		world.alert.connect(_on_alert)
		world.hero_leveled.connect(_on_hero_leveled)
		world.game_over.connect(_on_game_over)


# ---------------------------------------------------------------------------
# Small builder helpers
# ---------------------------------------------------------------------------
func _mk_label(text: String, size: int = 16, col: Color = FONT_COLOR) -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _body_font:
		l.add_theme_font_override("font", _body_font)
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 4)
	return l


func _mk_button(text: String, size: int = 15) -> Button:
	var b := Button.new()
	b.text = text
	b.clip_text = false
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	if _body_font:
		b.add_theme_font_override("font", _body_font)
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", FONT_COLOR)
	b.add_theme_color_override("font_hover_color", Color(1, 1, 0.9))
	b.add_theme_color_override("font_pressed_color", Color(1, 0.95, 0.8))
	b.add_theme_color_override("font_disabled_color", Color(0.6, 0.55, 0.5))
	b.add_theme_color_override("font_focus_color", FONT_COLOR)
	b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	b.add_theme_constant_override("outline_size", 3)
	return b


func _mk_title_label(text: String, size: int, col: Color) -> Label:
	var l := _mk_label(text, size, col)
	if _font:
		l.add_theme_font_override("font", _font)
	return l


func _mk_hud_panel() -> PanelContainer:
	# Clean, predictable HUD surface. The ornate 9-slice frame reserves 30px of
	# content margin on every side, which starved these dense panels and made
	# text overflow — a flat box with a thin border gives reliable interior space.
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.add_theme_stylebox_override("panel", _hud_stylebox())
	return p


func _hud_stylebox() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.06, 0.085, 0.94)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.62, 0.5, 0.28, 0.95)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(12)
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 5
	return sb


func _mk_icon(path: String, px: float) -> TextureRect:
	var t := TextureRect.new()
	if ResourceLoader.exists(path):
		t.texture = load(path)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(px, px)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


func _cost_string(cost: Dictionary) -> String:
	var parts := []
	for k in RES_ORDER:
		if cost.has(k):
			parts.append("%d %s" % [int(cost[k]), k])
	return "  (" + ", ".join(parts) + ")" if not parts.is_empty() else ""


func _command_icon_path(title: String, detail: String) -> String:
	var haystack := (title + " " + detail).to_lower()
	for kind in RES_ORDER:
		if haystack.contains(kind):
			return RES_ICONS[kind]
	# There is no separate command-card sprite atlas in the current authored kit;
	# use the existing portrait frame as a neutral entity affordance rather than
	# inventing a fake building thumbnail.
	return FRAME_PORTRAIT


func _mk_command_button(title: String, detail: String, tooltip: String, disabled_reason: String = "", state: String = "READY", preview_definition: Dictionary = {}) -> Button:
	var state_text := "LOCKED · " if state == "LOCKED" else ""
	var has_preview := not preview_definition.is_empty()
	var detail_text := detail + ("\n" + disabled_reason if not disabled_reason.is_empty() else "")
	# Production/research cards do not have a portrait column. Use the same
	# explicit text-column treatment as preview cards so the compact two-column
	# grid can wrap long names and cost lines instead of clipping them.
	var btn := _mk_button("" if has_preview else "", 12 if has_preview else 13)
	btn.custom_minimum_size = Vector2(174, 72 if has_preview else 74)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.clip_text = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if has_preview and ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
		var preview = load(ENTITY_PORTRAIT_SCRIPT).new()
		preview.name = "BuildingPreview"
		preview.position = Vector2(6, 7)
		preview.size = Vector2(46, 46)
		preview.custom_minimum_size = Vector2(46, 46)
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(preview)
		preview.configure_definition(preview_definition)
		# EntityPortraitView raises its own minimum to 112px for full-size cards;
		# defer the compact-card override until its _ready() has run so the preview
		# cannot expand back over the cost text column.
		preview.set_deferred("custom_minimum_size", Vector2(46, 46))
		preview.set_deferred("size", Vector2(46, 46))
		# Keep the preview clear of the text instead of relying on leading spaces
		# inside Button.text. The old overlay made the right side of the cost line
		# ellipsize even when the canonical resource names were short enough.
		var text_col := VBoxContainer.new()
		text_col.position = Vector2(58, 7)
		text_col.size = Vector2(108, 58)
		text_col.custom_minimum_size = Vector2(108, 58)
		text_col.add_theme_constant_override("separation", 1)
		text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var title_label := _mk_label(title, 12)
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_col.add_child(title_label)
		var detail_label := _mk_label(state_text + detail_text, 11, Color(0.86, 0.84, 0.76))
		detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		text_col.add_child(detail_label)
		btn.add_child(text_col)
	else:
		var text_col := VBoxContainer.new()
		text_col.position = Vector2(7, 7)
		text_col.size = Vector2(160, 60)
		text_col.custom_minimum_size = Vector2(160, 60)
		text_col.add_theme_constant_override("separation", 1)
		text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var title_color := Color(0.48, 0.47, 0.43, 0.9) if state == "LOCKED" else FONT_COLOR
		var detail_color := Color(0.42, 0.42, 0.39, 0.9) if state == "LOCKED" else Color(0.86, 0.84, 0.76)
		var title_label := _mk_label(title, 12, title_color)
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_col.add_child(title_label)
		var detail_label := _mk_label(state_text + detail_text, 11, detail_color)
		detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		text_col.add_child(detail_label)
		btn.add_child(text_col)
	btn.tooltip_text = tooltip if disabled_reason.is_empty() else "%s\nUnavailable: %s" % [tooltip, disabled_reason]
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.10, 0.12, 0.14, 0.96)
	normal.border_color = Color(0.34, 0.38, 0.38, 0.9)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)
	normal.set_content_margin_all(7)
	var hover := normal.duplicate()
	hover.bg_color = Color(0.18, 0.19, 0.16, 0.98)
	hover.border_color = Color(0.82, 0.68, 0.32, 1.0)
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.06, 0.07, 0.08, 0.9)
	disabled.border_color = Color(0.20, 0.22, 0.22, 0.75)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_disabled_color", Color(0.48, 0.47, 0.43, 0.9))
	return btn


func _mk_command_grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return grid


func _add_command_section(title: String, hint: String = "") -> void:
	_cmd_body.add_child(HSeparator.new())
	_cmd_body.add_child(_mk_label(title.to_upper(), 13, Color(0.95, 0.85, 0.55)))
	if not hint.is_empty():
		_cmd_body.add_child(_mk_label(hint, 11, Color(0.65, 0.66, 0.61)))


# ---------------------------------------------------------------------------
# 1. TOP BAR
# ---------------------------------------------------------------------------
func _build_top_bar() -> void:
	var panel := _mk_hud_panel()
	_top_panel = panel
	_top_panel.name = "TopResourceBar"
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_bottom = 66.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(0, 66)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 118)  # keep clear of the Menu button
	margin.add_theme_constant_override("margin_top", 0)
	margin.add_theme_constant_override("margin_bottom", 0)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 26)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(row)

	for k in RES_ORDER:
		var cell := HBoxContainer.new()
		cell.add_theme_constant_override("separation", 7)
		cell.add_child(_mk_icon(RES_ICONS[k], 30))
		var l := _mk_label("0", 22)
		l.custom_minimum_size = Vector2(58, 0)
		_res_labels[k] = l
		cell.add_child(l)
		row.add_child(cell)

	var sep := VSeparator.new()
	sep.custom_minimum_size = Vector2(2, 0)
	row.add_child(sep)

	# population
	var pop_cell := HBoxContainer.new()
	pop_cell.add_theme_constant_override("separation", 6)
	var pop_title := _mk_label("Pop", 17, Color(0.85, 0.83, 0.75))
	pop_title.custom_minimum_size = Vector2(34, 0)
	pop_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pop_cell.add_child(pop_title)
	_pop_label = _mk_label("0/0", 22)
	_pop_label.custom_minimum_size = Vector2(64, 0)
	_pop_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pop_cell.add_child(_pop_label)
	row.add_child(pop_cell)

	# idle workers: persistent economy awareness in the existing player-status bar.
	# The count is refreshed at the same low rate as resources/population and does
	# not create a toast or world marker for every short worker transition.
	_idle_worker_label = _mk_label("Idle 0", 16, Color(0.72, 0.73, 0.68))
	_idle_worker_label.custom_minimum_size = Vector2(70, 0)
	_idle_worker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(_idle_worker_label)

	# age / tier
	_tier_label = _mk_label("Age I", 22, Color(0.98, 0.88, 0.55))
	_tier_label.custom_minimum_size = Vector2(68, 0)
	_tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(_tier_label)

	# menu button (top-right corner)
	var menu_btn := _mk_button("Menu", 16)
	_menu_button = menu_btn
	_menu_button.name = "MenuButton"
	menu_btn.custom_minimum_size = Vector2(88, 36)
	menu_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	menu_btn.offset_left = -104.0
	menu_btn.offset_right = -14.0
	menu_btn.offset_top = 15.0
	menu_btn.offset_bottom = 51.0
	menu_btn.pressed.connect(func(): emit_signal("pause_requested"))
	add_child(menu_btn)


func _on_resources_changed(res: Dictionary) -> void:
	for k in RES_ORDER:
		if _res_labels.has(k) and is_instance_valid(_res_labels[k]):
			_res_labels[k].text = str(int(res.get(k, 0)))


func _on_pop_changed(used: int, cap: int) -> void:
	if is_instance_valid(_pop_label):
		_pop_label.text = "%d/%d" % [used, cap]
		_pop_label.add_theme_color_override("font_color",
			Color(0.95, 0.5, 0.45) if used >= cap and cap > 0 else FONT_COLOR)


func _on_tier_changed(tier: int) -> void:
	if is_instance_valid(_tier_label):
		_tier_label.text = TIER_NAMES.get(tier, "Age %d" % tier)


# ---------------------------------------------------------------------------
# 2. MINIMAP
# ---------------------------------------------------------------------------
func _build_minimap() -> void:
	var panel := _mk_hud_panel()
	_minimap_panel = panel
	_minimap_panel.name = "MinimapPanel"
	# panel = minimap (200) + framing/legend content and style margins
	var box := MINIMAP_SIZE + 24.0
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.grow_horizontal = Control.GROW_DIRECTION_END
	panel.offset_left = 12.0
	panel.offset_right = 12.0 + box
	panel.offset_top = -12.0 - MINIMAP_PANEL_HEIGHT
	panel.offset_bottom = -12.0
	panel.custom_minimum_size = Vector2(box, MINIMAP_PANEL_HEIGHT)
	add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(column)
	var title := _mk_label("TACTICAL MAP", 13, Color(0.95, 0.85, 0.55))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	_minimap = Control.new()
	_minimap.custom_minimum_size = Vector2(MINIMAP_SIZE, MINIMAP_SIZE)
	_minimap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_minimap.mouse_filter = Control.MOUSE_FILTER_STOP
	_minimap.draw.connect(_draw_minimap)
	_minimap.gui_input.connect(_on_minimap_input)
	column.add_child(_minimap)
	var legend := _mk_label("ALLY  •  ENEMY  •  STRUCTURE  •  VIEW", 9, Color(0.67, 0.68, 0.63))
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(legend)


func _on_minimap_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_focus_from_minimap(event.position)
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		_focus_from_minimap(event.position)


func _focus_from_minimap(local_pos: Vector2) -> void:
	if not is_instance_valid(rts):
		return
	var size := _minimap.size
	if size.x <= 0 or size.y <= 0:
		return
	var wx := (local_pos.x / size.x) * (MAP_HALF * 2.0) - MAP_HALF
	var wz := (local_pos.y / size.y) * (MAP_HALF * 2.0) - MAP_HALF
	if rts.has_method("focus_on"):
		rts.focus_on(Vector3(wx, 0.0, wz))


func _world_to_map(pos: Vector3) -> Vector2:
	var size := _minimap.size
	var mx := (pos.x + MAP_HALF) / (MAP_HALF * 2.0) * size.x
	var my := (pos.z + MAP_HALF) / (MAP_HALF * 2.0) * size.y
	return Vector2(mx, my)


func _draw_minimap() -> void:
	if not is_instance_valid(_minimap):
		return
	var size := _minimap.size
	if is_instance_valid(world):
		_ensure_minimap_background()
		if is_instance_valid(_minimap_background):
			_minimap.draw_texture_rect(_minimap_background, Rect2(Vector2.ZERO, size), false)
		else:
			_minimap.draw_rect(Rect2(Vector2.ZERO, size), _minimap_theme_color(str(world.map.get("theme", "highland")), false), true)
		_draw_minimap_terrain(size)
	_draw_minimap_roads(size)
	var bridge_data = world.map.get("bridge", {})
	if bridge_data is Dictionary and bridge_data.get("pos") is Vector3:
		var bridge_p := _world_to_map(bridge_data["pos"])
		_minimap.draw_line(bridge_p - Vector2(12, 0), bridge_p + Vector2(12, 0), Color(0.04, 0.05, 0.05, 0.95), 10.0, true)
		_minimap.draw_line(bridge_p - Vector2(12, 0), bridge_p + Vector2(12, 0), Color(0.92, 0.72, 0.30, 1.0), 5.0, true)
		_minimap.draw_line(bridge_p - Vector2(9, -3), bridge_p + Vector2(9, -3), Color(0.30, 0.20, 0.10, 0.95), 1.0, true)
		_minimap.draw_line(bridge_p - Vector2(9, 3), bridge_p + Vector2(9, 3), Color(0.30, 0.20, 0.10, 0.95), 1.0, true)
	_draw_minimap_frame(size)

	if not is_instance_valid(world):
		return

	# capture points as diamonds, using the live nodes so ownership remains true.
	for cp in world.get_tree().get_nodes_in_group("capture_points"):
		if not is_instance_valid(cp):
			continue
		var p := _world_to_map(cp.global_position)
		var team_owner := int(cp.owner_team) if "owner_team" in cp else -1
		var col: Color = GameData.TEAM_COLORS.get(team_owner, Color(0.85, 0.85, 0.85)) if team_owner >= 0 else Color(0.85, 0.85, 0.85)
		var r := 5.0
		var diamond := PackedVector2Array([
			p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r), p + Vector2(-r, 0)])
		_minimap.draw_colored_polygon(diamond, col.darkened(0.18))
		_minimap.draw_polyline(PackedVector2Array([
			p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r),
			p + Vector2(-r, 0), p + Vector2(0, -r)]), Color(0, 0, 0, 0.8), 1.0)

	# Buildings use a footprint, wall face, and roof notch so structures read
	# differently from units at a glance.
	for b in world.all_buildings():
		if not is_instance_valid(b) or b.is_dead:
			continue
		_draw_minimap_building(_world_to_map(b.global_position), GameData.TEAM_COLORS.get(b.team, Color.WHITE))

	# Live resource landmarks make the miniature useful without inventing a
	# second simulation. Depleted nodes remain absent, matching the world.
	for resource in world.get_tree().get_nodes_in_group("resources"):
		if not is_instance_valid(resource) or bool(resource.get("depleted")):
			continue
		_draw_minimap_resource(_world_to_map(resource.global_position), _minimap_resource_color(str(resource.resource_kind)))

	# units (small but readable diamonds)
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead:
			continue
		_draw_minimap_unit(_world_to_map(u.global_position), GameData.TEAM_COLORS.get(u.team, Color.WHITE))

	# camera view marker corresponds to the current RTS camera footprint, not a
	# fixed square that implied a false zoom level.
	if is_instance_valid(rts) and "cam_pivot" in rts and is_instance_valid(rts.cam_pivot):
		var cp := _world_to_map(rts.cam_pivot.global_position)
		var aspect := get_viewport_rect().size.x / maxf(get_viewport_rect().size.y, 1.0)
		var zoom := float(rts.get("_zoom")) if rts.get("_zoom") != null else 42.0
		var half_y := clampf(zoom * 0.72, 18.0, 78.0)
		var half_x := clampf(half_y * aspect, 24.0, 118.0)
		var corners := PackedVector2Array([
			_world_to_map(rts.cam_pivot.global_position + Vector3(-half_x, 0, -half_y)),
			_world_to_map(rts.cam_pivot.global_position + Vector3(half_x, 0, -half_y)),
			_world_to_map(rts.cam_pivot.global_position + Vector3(half_x, 0, half_y)),
			_world_to_map(rts.cam_pivot.global_position + Vector3(-half_x, 0, half_y)),
			_world_to_map(rts.cam_pivot.global_position + Vector3(-half_x, 0, -half_y))])
		_minimap.draw_colored_polygon(corners, MINIMAP_VIEW_FILL)
		_minimap.draw_polyline(corners, Color(0.04, 0.05, 0.05, 0.9), 3.5, true)
		_minimap.draw_polyline(corners, MINIMAP_VIEW_EDGE, 1.5, true)
		for corner in corners.slice(0, 4):
			_minimap.draw_circle(corner, 2.0, MINIMAP_VIEW_EDGE)


func _draw_minimap_terrain(size: Vector2) -> void:
	# Subtle grid and broad land shelves create tactical scale without adding
	# fake gameplay zones or a second map representation.
	var edge := Color(0.10, 0.13, 0.10, 0.62)
	for i in range(1, MINIMAP_GRID_DIVISIONS):
		var x := size.x * float(i) / float(MINIMAP_GRID_DIVISIONS)
		var y := size.y * float(i) / float(MINIMAP_GRID_DIVISIONS)
		_minimap.draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.86, 0.84, 0.68, 0.10), 1.0, true)
		_minimap.draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.86, 0.84, 0.68, 0.10), 1.0, true)
	_minimap.draw_rect(Rect2(Vector2(7, 7), size - Vector2(14, 14)), edge, false, 5.0)
	for start in world.map.get("start_positions", []):
		var p := _world_to_map(start)
		_draw_minimap_region(p, Vector2(19.0, 15.0), Color(0.75, 0.68, 0.42, 0.07), Color(0.78, 0.72, 0.48, 0.56))
	_draw_minimap_region(_world_to_map(Vector3.ZERO), Vector2(17.0, 14.0), Color(0.9, 0.78, 0.38, 0.06), Color(0.9, 0.78, 0.38, 0.38))

func _draw_minimap_frame(size: Vector2) -> void:
	_minimap.draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.04, 0.04, 0.96), false, 5.0)
	_minimap.draw_rect(Rect2(Vector2(3, 3), size - Vector2(6, 6)), Color(0.68, 0.55, 0.30, 0.92), false, 1.0)
	for corner in [Vector2(4, 4), Vector2(size.x - 4, 4), Vector2(size.x - 4, size.y - 4), Vector2(4, size.y - 4)]:
		_minimap.draw_circle(corner, 2.0, Color(0.95, 0.79, 0.38, 0.95))

func _draw_minimap_building(p: Vector2, col: Color) -> void:
	_minimap.draw_rect(Rect2(p - Vector2(5.5, 5.5), Vector2(11, 11)), Color(0.03, 0.04, 0.04, 0.95), true)
	_minimap.draw_rect(Rect2(p - Vector2(4.5, 4.5), Vector2(9, 9)), col.darkened(0.24), true)
	_minimap.draw_line(p + Vector2(-3.0, 3.0), p + Vector2(3.0, -3.0), col.lightened(0.25), 1.5, true)
	_minimap.draw_line(p + Vector2(-3.0, -3.0), p + Vector2(3.0, 3.0), col.lightened(0.10), 1.0, true)

func _draw_minimap_unit(p: Vector2, col: Color) -> void:
	var r := 4.0
	_minimap.draw_circle(p, r + 1.7, Color(0.02, 0.03, 0.03, 0.95))
	_minimap.draw_colored_polygon(PackedVector2Array([
		p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r), p + Vector2(-r, 0)]), col)
	_minimap.draw_line(p + Vector2(-2.0, 0), p + Vector2(2.0, 0), Color(1, 1, 1, 0.76), 1.0, true)

func _draw_minimap_resource(p: Vector2, col: Color) -> void:
	_minimap.draw_circle(p, 4.3, Color(0.03, 0.04, 0.04, 0.95))
	_minimap.draw_circle(p, 2.8, col)
	_minimap.draw_line(p + Vector2(-1.5, -1.5), p + Vector2(1.5, 1.5), Color(1, 1, 1, 0.55), 1.0, true)


func _draw_minimap_roads(size: Vector2) -> void:
	if not is_instance_valid(world):
		return
	var road_shadow := Color(0.12, 0.13, 0.1, 0.8)
	var road := Color(0.68, 0.55, 0.33, 0.92)
	var overview: Dictionary = world.map.get("overview", {})
	for route in overview.get("roads", []):
		if not route is Array or route.size() < 2:
			continue
		var points := PackedVector2Array()
		for world_point in route:
			points.append(_world_to_map(world_point))
		_minimap.draw_polyline(points, road_shadow, 9.0, true)
		_minimap.draw_polyline(points, road, 5.0, true)

func _draw_minimap_region(center: Vector2, radius: Vector2, fill: Color, edge: Color) -> void:
	var points := PackedVector2Array()
	for i in range(20):
		var angle := TAU * float(i) / 20.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	_minimap.draw_colored_polygon(points, fill)
	var outline := PackedVector2Array(points)
	outline.append(points[0])
	_minimap.draw_polyline(outline, edge, 1.2, true)

func _minimap_resource_color(kind: String) -> Color:
	match kind:
		"food": return Color(0.86, 0.70, 0.28, 1.0)
		"gold": return Color(0.96, 0.83, 0.32, 1.0)
		"stone": return Color(0.72, 0.76, 0.78, 1.0)
		"timber": return Color(0.52, 0.78, 0.34, 1.0)
		_: return Color(0.82, 0.82, 0.82, 1.0)

func _minimap_theme_color(theme_name: String, accent: bool) -> Color:
	match theme_name:
		"volcanic": return Color(0.42, 0.25, 0.18, 1.0) if not accent else Color(0.58, 0.32, 0.18, 1.0)
		"snow": return Color(0.37, 0.45, 0.48, 1.0) if not accent else Color(0.60, 0.68, 0.70, 1.0)
		"desert", "badlands": return Color(0.40, 0.29, 0.18, 1.0) if not accent else Color(0.58, 0.42, 0.24, 1.0)
		_: return Color(0.22, 0.30, 0.20, 1.0) if not accent else Color(0.30, 0.38, 0.24, 1.0)

func _ensure_minimap_background() -> void:
	if not is_instance_valid(world):
		return
	var map_id := str(world.map.get("id", ""))
	var theme_name := str(world.map.get("theme", "highland"))
	var cache_key := map_id + ":" + theme_name
	if cache_key == _minimap_background_key and is_instance_valid(_minimap_background):
		return
	var image := Image.create(MINIMAP_RASTER_SIZE, MINIMAP_RASTER_SIZE, false, Image.FORMAT_RGBA8)
	var water: Dictionary = world.map.get("water", {})
	var overview: Dictionary = world.map.get("overview", {})
	var base := _minimap_theme_color(theme_name, false)
	var accent := _minimap_theme_color(theme_name, true)
	var water_enabled := bool(water.get("enabled", false))
	var axis := str(overview.get("water_axis", "north_bay"))
	var center_z := float(overview.get("water_center_z", 118.0))
	var half_width := float(overview.get("water_width", 34.0)) * 0.5
	var deep: Color = water.get("deep", Color(0.05, 0.22, 0.34))
	var shallow: Color = water.get("shallow", Color(0.16, 0.48, 0.58))
	for y in range(MINIMAP_RASTER_SIZE):
		for x in range(MINIMAP_RASTER_SIZE):
			var wp := Vector3(
				(float(x) / float(MINIMAP_RASTER_SIZE - 1) * MAP_HALF * 2.0) - MAP_HALF,
				0.0,
				(float(y) / float(MINIMAP_RASTER_SIZE - 1) * MAP_HALF * 2.0) - MAP_HALF)
			var col := base
			var edge := minf(minf(wp.x + MAP_HALF, MAP_HALF - wp.x), minf(wp.z + MAP_HALF, MAP_HALF - wp.z))
			if edge < 10.0:
				col = col.darkened(0.10)
			if water_enabled:
				var distance := _minimap_water_distance(wp, axis, center_z, half_width)
				if distance <= 0.0:
					col = deep
				elif distance < 5.0:
					col = shallow.lerp(base, distance / 5.0)
			var road_distance := 9999.0
			for route in overview.get("roads", []):
				if not route is Array:
					continue
				for index in range(route.size() - 1):
					road_distance = minf(road_distance, _minimap_segment_distance(wp, route[index], route[index + 1]))
			if road_distance < 6.0:
				col = Color(0.16, 0.13, 0.09, 1.0) if road_distance < 2.3 else accent.darkened(0.12)
			image.set_pixel(x, y, col)
	_minimap_background = ImageTexture.create_from_image(image)
	_minimap_background_key = cache_key

func _minimap_segment_distance(point: Vector3, a: Vector3, b: Vector3) -> float:
	var ab := Vector2(b.x - a.x, b.z - a.z)
	var ap := Vector2(point.x - a.x, point.z - a.z)
	var t := clampf(ap.dot(ab) / maxf(ab.length_squared(), 0.0001), 0.0, 1.0)
	return Vector2(point.x, point.z).distance_to(Vector2(a.x, a.z) + ab * t)

func _minimap_water_distance(pos: Vector3, axis: String, center_z: float, half_width: float) -> float:
	if axis == "crossing":
		return absf(pos.z - center_z) - half_width
	return center_z - half_width - pos.z


# ---------------------------------------------------------------------------
# Process — low-rate polling + minimap redraw
# ---------------------------------------------------------------------------
func _process(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size != _last_viewport_size:
		_fit_to_viewport()
		_last_viewport_size = viewport_size

	_map_accum += delta
	if _map_accum >= 0.15:
		_map_accum = 0.0
		if is_instance_valid(_minimap):
			_minimap.queue_redraw()

	_slow_accum += delta
	if _slow_accum >= 0.25:
		_slow_accum = 0.0
		_poll_top_bar()
		_refresh_single_live()
		_refresh_multi_live()


func _poll_top_bar() -> void:
	if not is_instance_valid(_commander):
		return
	_on_resources_changed(_commander.resources)
	_on_pop_changed(_commander.pop_used + _commander.reserved_pop, _commander.pop_cap)
	_on_tier_changed(_commander.tier)
	_on_idle_worker_count(_count_meaningfully_idle_workers())


func _worker_is_meaningfully_idle(unit) -> bool:
	if not is_instance_valid(unit) or unit.is_dead or not unit.is_worker:
		return false
	if int(unit.state) != Unit.State.IDLE or int(unit.get("_carry")) > 0:
		return false
	return not is_instance_valid(unit.get("_gather_node")) \
		and not is_instance_valid(unit.get("_pending_gather_node")) \
		and not is_instance_valid(unit.get("_build_target"))


func _count_meaningfully_idle_workers() -> int:
	if not is_instance_valid(_commander):
		return 0
	var count := 0
	for unit in _commander.units:
		if _worker_is_meaningfully_idle(unit):
			count += 1
	return count


func _on_idle_worker_count(count: int) -> void:
	if not is_instance_valid(_idle_worker_label):
		return
	_idle_worker_label.text = "Idle %d" % count
	_idle_worker_label.add_theme_color_override("font_color",
		Color(0.98, 0.73, 0.36) if count > 0 else Color(0.72, 0.73, 0.68))


# ---------------------------------------------------------------------------
# 3. SELECTION PANEL
# ---------------------------------------------------------------------------
func _build_selection_panel() -> void:
	_sel_panel = _mk_hud_panel()
	_sel_panel.name = "SelectionPanel"
	_sel_panel.custom_minimum_size = Vector2(480, 156)
	_sel_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_sel_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	# center it: anchor middle-bottom
	_sel_panel.anchor_left = 0.5
	_sel_panel.anchor_right = 0.5
	_sel_panel.anchor_top = 1.0
	_sel_panel.anchor_bottom = 1.0
	_sel_panel.offset_left = -240
	_sel_panel.offset_right = 240
	_sel_panel.offset_top = -168
	_sel_panel.offset_bottom = -12
	add_child(_sel_panel)

	_sel_body = Control.new()
	_sel_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sel_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sel_panel.add_child(_sel_body)
	_sel_panel.visible = false


func _clear_children(node: Node) -> void:
	if not is_instance_valid(node):
		return
	for c in node.get_children():
		c.queue_free()


func _reset_selection_widgets() -> void:
	_tracked_single = null
	_single_hp_bar = null
	_single_hp_text = null
	_single_mana_bar = null
	_single_stat_label = null
	_single_economy_label = null
	_ability_widgets.clear()
	_multi_bars.clear()
	_queue_container = null
	if is_instance_valid(_watched_building) and _watched_building.production_updated.is_connected(_on_production_updated):
		_watched_building.production_updated.disconnect(_on_production_updated)
	_watched_building = null


func _on_selection_changed(units: Array) -> void:
	_rebuild_selection(units)


func _rebuild_selection(sel: Array) -> void:
	_reset_selection_widgets()
	_clear_children(_sel_body)

	# filter to valid
	var valid := []
	for s in sel:
		if is_instance_valid(s) and not (("is_dead" in s) and s.is_dead):
			valid.append(s)

	if valid.is_empty():
		_sel_panel.visible = false
		_rebuild_command_card(null, valid)
		return

	_sel_panel.visible = true

	if valid.size() == 1:
		var one = valid[0]
		if one is Building:
			_build_single_building(one)
		else:
			_build_single_unit(one)
		_rebuild_command_card(one, valid)
	else:
		_build_multi(valid)
		_rebuild_command_card(null, valid)


func _mk_bar(col: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.custom_minimum_size = Vector2(0, 16)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.08, 0.08, 0.08, 0.9)
	bg.set_corner_radius_all(3)
	var fg := StyleBoxFlat.new()
	fg.bg_color = col
	fg.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fg)
	return bar


func _build_single_unit(u) -> void:
	_tracked_single = u
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.add_child(row)

	# Actual authored model preview, isolated from the live gameplay node.
	var portrait: Control
	if ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
		portrait = load(ENTITY_PORTRAIT_SCRIPT).new()
		portrait.custom_minimum_size = Vector2(108, 108)
		row.add_child(portrait)
		portrait.configure_entity(u)
	else:
		portrait = _mk_icon(FRAME_PORTRAIT, 96)
		row.add_child(portrait)

	# info column
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(info)

	var uname: String = u.def.get("name", "Unit")
	info.add_child(_mk_label(uname, 18, Color(0.95, 0.85, 0.55)))

	# hp bar + text
	_single_hp_bar = _mk_bar(Color(0.35, 0.8, 0.35))
	info.add_child(_single_hp_bar)
	_single_hp_text = _mk_label("", 15)
	info.add_child(_single_hp_text)

	if u.is_hero and u.max_mana > 0.0:
		_single_mana_bar = _mk_bar(Color(0.35, 0.55, 0.95))
		info.add_child(_single_mana_bar)

	_single_stat_label = _mk_label("", 15, Color(0.88, 0.85, 0.75))
	info.add_child(_single_stat_label)
	if u.is_worker and u.has_method("get_economy_text"):
		_single_economy_label = _mk_label("", 14, Color(0.78, 0.9, 0.72))
		_single_economy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(_single_economy_label)

	# ability buttons for hero
	if u.is_hero and not u.abilities.is_empty():
		var ab_row := HBoxContainer.new()
		ab_row.add_theme_constant_override("separation", 6)
		info.add_child(ab_row)
		var abilities: Dictionary = SkillDefs.get_abilities()
		for id in u.abilities:
			var ab: Dictionary = abilities.get(id, {})
			var btn := _mk_button(str(ab.get("name", id)).left(1), 15)
			btn.custom_minimum_size = Vector2(34, 30)
			btn.tooltip_text = "%s\n%s\nMana: %d" % [ab.get("name", id), ab.get("desc", ""), int(ab.get("mana", 0))]
			var cap_id := String(id)
			var cap_u = u
			btn.pressed.connect(func():
				if is_instance_valid(cap_u) and not cap_u.is_dead and cap_u.has_method("cast_ability"):
					cap_u.cast_ability(cap_id, cap_u.global_position))
			ab_row.add_child(btn)
			# cooldown overlay label
			var cd_overlay := _mk_label("", 13, Color(1, 1, 1))
			cd_overlay.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			cd_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cd_overlay.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			btn.add_child(cd_overlay)
			_ability_widgets.append({"id": cap_id, "button": btn, "overlay": cd_overlay})

	_refresh_single_live()


func _refresh_single_live() -> void:
	var u = _tracked_single
	if not is_instance_valid(u) or (("is_dead" in u) and u.is_dead):
		return
	if is_instance_valid(_single_hp_bar):
		_single_hp_bar.value = clamp(u.get_hp_ratio(), 0.0, 1.0)
	if is_instance_valid(_single_hp_text):
		_single_hp_text.text = "HP %d / %d" % [int(max(0.0, u.hp)), int(u.max_hp)]
	if is_instance_valid(_single_mana_bar) and "max_mana" in u and u.max_mana > 0.0:
		_single_mana_bar.value = clamp(u.mana / u.max_mana, 0.0, 1.0)
	if is_instance_valid(_single_stat_label):
		if u is Building:
			pass
		elif u.has_method("cur_dmg"):
			var role: String = u.def.get("role", "")
			_single_stat_label.text = "DMG %d   ARM %d   %s" % [
				int(u.cur_dmg()), int(u.cur_armor()), role.capitalize()]
	if is_instance_valid(_single_economy_label) and u.has_method("get_economy_text"):
		_single_economy_label.text = u.get_economy_text()
	# ability cooldown / affordability visuals
	for w in _ability_widgets:
		var btn: Button = w["button"]
		if not is_instance_valid(btn):
			continue
		var id: String = w["id"]
		var cd: float = float(u.ability_cd.get(id, 0.0)) if "ability_cd" in u else 0.0
		var ab: Dictionary = SkillDefs.get_abilities().get(id, {})
		var mana_ok: bool = ("mana" in u) and u.mana >= float(ab.get("mana", 0))
		var overlay: Label = w["overlay"]
		if cd > 0.05:
			btn.disabled = true
			if is_instance_valid(overlay):
				overlay.text = str(int(ceil(cd)))
		else:
			btn.disabled = not mana_ok
			if is_instance_valid(overlay):
				overlay.text = ""


func _selection_type_summary(units: Array) -> String:
	var counts: Dictionary = {}
	var order: Array[String] = []
	for u in units:
		if not is_instance_valid(u):
			continue
		var label := String(u.def.get("name", "Unit"))
		if bool(u.is_worker):
			label = "Workers"
		else:
			label = label.trim_prefix("Highland ")
			label = label.trim_prefix("Clan ")
		if not counts.has(label):
			counts[label] = 0
			order.append(label)
		counts[label] = int(counts[label]) + 1
	var parts: Array[String] = []
	for label in order:
		parts.append("%s x%d" % [label, int(counts[label])])
	return " · ".join(parts)


func _build_multi(units: Array) -> void:
	var selected_label := _mk_label("Group · %d units  •  %s" % [units.size(), _selection_type_summary(units)], 12, Color(0.95, 0.85, 0.55))
	selected_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	selected_label.offset_left = 8
	selected_label.offset_right = -8
	selected_label.offset_top = 0
	selected_label.offset_bottom = 20
	_sel_body.add_child(selected_label)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 22
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	_sel_body.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	var shown := 0
	for u in units:
		if shown >= 24:
			break
		if not is_instance_valid(u):
			continue
		var cell := VBoxContainer.new()
		cell.custom_minimum_size = Vector2(54, 64)
		cell.add_theme_constant_override("separation", 1)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
			var portrait = load(ENTITY_PORTRAIT_SCRIPT).new()
			portrait.custom_minimum_size = Vector2(54, 46)
			cell.add_child(portrait)
			portrait.configure_entity(u)
		else:
			cell.add_child(_mk_icon(FRAME_PORTRAIT, 46))
		var nm := _mk_label(("★ " if bool(u.is_hero) else "") + str(u.def.get("name", "Unit")), 10, Color(1.0, 0.85, 0.45) if bool(u.is_hero) else Color(0.9, 0.86, 0.72))
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		cell.add_child(nm)
		var bar := _mk_bar(Color(0.35, 0.8, 0.35))
		bar.custom_minimum_size = Vector2(50, 8)
		cell.add_child(bar)
		grid.add_child(cell)
		_multi_bars.append({"unit": u, "bar": bar})
		shown += 1

	if units.size() > 24:
		_sel_body.add_child(_mk_label("+%d more" % (units.size() - 24), 12))


func _refresh_multi_live() -> void:
	for entry in _multi_bars:
		var u = entry["unit"]
		var bar: ProgressBar = entry["bar"]
		if not is_instance_valid(bar):
			continue
		if is_instance_valid(u) and not (("is_dead" in u) and u.is_dead) and u.has_method("get_hp_ratio"):
			bar.value = clamp(u.get_hp_ratio(), 0.0, 1.0)
		else:
			bar.value = 0.0


func _build_single_building(b) -> void:
	_tracked_single = b
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 3)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.add_child(col)

	var identity := HBoxContainer.new()
	identity.add_theme_constant_override("separation", 8)
	identity.custom_minimum_size = Vector2(0, 76)
	identity.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(identity)
	var portrait: Control
	if ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
		portrait = load(ENTITY_PORTRAIT_SCRIPT).new()
		portrait.custom_minimum_size = Vector2(92, 92)
		identity.add_child(portrait)
		portrait.configure_entity(b)
	else:
		portrait = _mk_icon(FRAME_PORTRAIT, 76)
		identity.add_child(portrait)
	var identity_info := VBoxContainer.new()
	identity_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity.add_child(identity_info)
	identity_info.add_child(_mk_label(b.def.get("name", "Building"), 18, Color(0.95, 0.85, 0.55)))
	_single_hp_bar = _mk_bar(Color(0.35, 0.8, 0.35))
	identity_info.add_child(_single_hp_bar)
	_single_hp_text = _mk_label("", 15)
	identity_info.add_child(_single_hp_text)

	if not b.is_built:
		var pb := _mk_bar(Color(0.85, 0.7, 0.3))
		pb.value = clamp(b.build_progress, 0.0, 1.0)
		var progress_label := _mk_label("Construction progress: %d%%" % roundi(clampf(b.build_progress, 0.0, 1.0) * 100.0), 12, Color(0.85, 0.8, 0.6))
		col.add_child(progress_label)
		col.add_child(pb)
		var cap_b = b
		var cap_pb = pb
		var cap_label = progress_label
		# tick construction bar off the slow poll via a lambda-friendly approach:
		# store it on the building bar reference reused each poll is overkill; use a timer.
		var t := Timer.new()
		t.wait_time = 0.2
		t.autostart = true
		cap_pb.add_child(t)
		t.timeout.connect(func():
			if is_instance_valid(cap_b) and is_instance_valid(cap_pb):
				cap_pb.value = clamp(cap_b.build_progress, 0.0, 1.0)
				if is_instance_valid(cap_label):
					cap_label.text = "Construction progress: %d%%" % roundi(clampf(cap_b.build_progress, 0.0, 1.0) * 100.0))

	# production queue row (only meaningful when it produces)
	if not b.def.get("produces", []).is_empty() or not b.def.get("research", []).is_empty() \
			or b.def.get("is_hq", false) or b.def.get("kind", "") == "main":
		_queue_container = HBoxContainer.new()
		_queue_container.add_theme_constant_override("separation", 4)
		_queue_container.mouse_filter = Control.MOUSE_FILTER_STOP
		# Keep the compact queue inside the building identity row so the fixed
		# selection panel can show the full slot and progress bar at the bottom
		# of the viewport instead of pushing it below the panel boundary.
		var queue_row := HBoxContainer.new()
		queue_row.add_theme_constant_override("separation", 4)
		queue_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_row.add_child(_mk_label("Queue", 11, Color(0.8, 0.78, 0.7)))
		queue_row.add_child(_queue_container)
		identity_info.add_child(queue_row)
		# watch production updates
		if b.production_updated.is_connected(_on_production_updated):
			b.production_updated.disconnect(_on_production_updated)
		b.production_updated.connect(_on_production_updated)
		_watched_building = b
		_refresh_queue()

	_refresh_single_live()


func _on_production_updated() -> void:
	_refresh_queue()


func _queue_slot_label(display_name: String) -> String:
	# The full entity name remains in the tooltip; use the distinctive final
	# name token in the compact slot so players can recognize the queue at a
	# glance instead of decoding two ambiguous initials.
	var words := display_name.strip_edges().split(" ", false)
	if words.is_empty():
		return display_name
	return String(words[words.size() - 1])


func _refresh_queue() -> void:
	if not is_instance_valid(_queue_container):
		return
	_clear_children(_queue_container)
	var b = _watched_building
	if not is_instance_valid(b):
		return
	var idx := 0
	for item in b.queue:
		var slot := _mk_button("", 12)
		slot.custom_minimum_size = Vector2(48, 28)
		slot.add_theme_font_size_override("font_size", 9)
		var kind: String = item.get("kind", "unit")
		var iid: String = item.get("id", "")
		var disp_name := ""
		if kind == "unit":
			disp_name = GameData.get_unit(iid).get("name", iid)
		else:
			disp_name = GameData.get_tech(iid).get("name", iid)
		slot.text = _queue_slot_label(disp_name)
		var total: float = float(item.get("total", 1.0))
		var left: float = float(item.get("time_left", 0.0))
		var prog: float = 1.0 - clampf(left / maxf(0.01, total), 0.0, 1.0)
		slot.tooltip_text = "%s\nClick to cancel (%d%%)" % [disp_name, int(prog * 100.0)]
		var cap_b = b
		var cap_idx := idx
		slot.pressed.connect(func():
			if is_instance_valid(cap_b) and cap_b.has_method("cancel_queue_item"):
				cap_b.cancel_queue_item(cap_idx))
		# progress mini-bar under text
		var pbar := _mk_bar(Color(0.85, 0.7, 0.3))
		pbar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		pbar.custom_minimum_size = Vector2(44, 5)
		pbar.value = prog
		pbar.position = Vector2(2, 20)
		pbar.size = Vector2(44, 5)
		slot.add_child(pbar)
		_queue_container.add_child(slot)
		idx += 1


# ---------------------------------------------------------------------------
# 4. COMMAND CARD (bottom-right)
# ---------------------------------------------------------------------------
func _build_command_panel() -> void:
	_cmd_panel = _mk_hud_panel()
	_cmd_panel.name = "CommandPanel"
	_cmd_panel.anchor_left = 1.0
	_cmd_panel.anchor_right = 1.0
	_cmd_panel.anchor_top = 1.0
	_cmd_panel.anchor_bottom = 1.0
	_cmd_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_cmd_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_cmd_panel.offset_left = -COMMAND_PANEL_WIDTH
	_cmd_panel.offset_right = -12
	_cmd_panel.offset_top = -372
	_cmd_panel.offset_bottom = -12
	add_child(_cmd_panel)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cmd_panel.add_child(scroll)

	_cmd_body = VBoxContainer.new()
	_cmd_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cmd_body.add_theme_constant_override("separation", 5)
	scroll.add_child(_cmd_body)
	_cmd_panel.visible = false


func _rebuild_command_card(single, selection: Array) -> void:
	_clear_children(_cmd_body)
	if not is_instance_valid(_commander):
		_cmd_panel.visible = false
		return

	# WORKER -> build menu
	if single != null and single is Unit and single.is_worker:
		_build_worker_card()
		_cmd_panel.visible = _cmd_body.get_child_count() > 0
		return

	# BUILDING -> production / research
	if single != null and single is Building:
		_build_building_card(single)
		_cmd_panel.visible = _cmd_body.get_child_count() > 0
		return

	_cmd_panel.visible = false


func _build_worker_card() -> void:
	_add_command_section("Build", "Choose a structure.")
	var grid := _mk_command_grid()
	_cmd_body.add_child(grid)
	for bid in GameData.buildings_for_race(_commander.race):
		var bdef := GameData.get_building(bid)
		if bdef.is_empty():
			continue
		var cost: Dictionary = bdef.get("cost", {})
		var affordable: bool = _commander.can_afford(cost)
		var reason: String = ""
		if not affordable:
			reason = _commander.missing_resource_summary(cost)
		# The Build section already establishes this as a cost line. Keeping the
		# canonical resource name/amount but dropping the redundant "Cost:" prefix
		# lets the existing 174px two-column card fit "50 timber" / "60 stone"
		# without changing resource definitions or the command-card geometry.
		var btn := _mk_command_button(str(bdef.get("name", bid)), _cost_string(cost).trim_prefix("  (").trim_suffix(")"), str(bdef.get("desc", "")), reason, "LOCKED" if not affordable else "READY", bdef)
		btn.disabled = not affordable
		var cap_id := String(bid)
		btn.pressed.connect(func():
			if is_instance_valid(rts) and rts.has_method("enter_build_mode"):
				rts.enter_build_mode(cap_id))
		grid.add_child(btn)


func _build_building_card(b) -> void:
	if not b.is_built:
		_add_command_section("Construction", "Under construction.")
		var progress_label := _mk_label("Build progress: %d%%" % roundi(clampf(b.build_progress, 0.0, 1.0) * 100.0), 12, Color(0.85, 0.8, 0.6))
		_cmd_body.add_child(progress_label)
		var progress_bar := _mk_bar(Color(0.85, 0.7, 0.3))
		progress_bar.value = clampf(b.build_progress, 0.0, 1.0)
		_cmd_body.add_child(progress_bar)
		var cap_b = b
		var cap_label := progress_label
		var cap_bar := progress_bar
		var t := Timer.new()
		t.wait_time = 0.2
		t.autostart = true
		_cmd_body.add_child(t)
		t.timeout.connect(func():
			if is_instance_valid(cap_b) and is_instance_valid(cap_label) and is_instance_valid(cap_bar):
				var pct := roundi(clampf(cap_b.build_progress, 0.0, 1.0) * 100.0)
				cap_label.text = "Build progress: %d%%" % pct
				cap_bar.value = clampf(cap_b.build_progress, 0.0, 1.0)
		)
		return
	var def: Dictionary = b.def
	var produces: Array = def.get("produces", [])
	var research: Array = def.get("research", [])
	var is_hq: bool = def.get("is_hq", false) or def.get("kind", "") == "main"

	# production units
	if not produces.is_empty():
		_add_command_section("Train", "Queue a unit.")
		var train_grid := _mk_command_grid()
		_cmd_body.add_child(train_grid)
		for uid in produces:
			var udef := GameData.get_unit(uid)
			if udef.is_empty():
				continue
			var cost: Dictionary = udef.get("cost", {})
			var tier := int(udef.get("tier", 1))
			var affordable: bool = _commander.can_afford(cost)
			var housed: bool = _commander.has_pop_for(udef)
			var reason: String = ""
			if tier > _commander.tier:
				reason = "Requires Age %d" % tier
			elif not housed:
				reason = "Need more housing"
			elif not affordable:
				reason = _commander.missing_resource_summary(cost)
			var btn := _mk_command_button(str(udef.get("name", uid)), "Tier %d | Cost: %s" % [tier, _cost_string(cost).trim_prefix("  (").trim_suffix(")")], str(udef.get("desc", "")), reason, "LOCKED" if not reason.is_empty() else "READY")
			btn.disabled = not reason.is_empty()
			var cap_b = b
			var cap_uid := String(uid)
			btn.pressed.connect(func(): _try_queue_unit(cap_b, cap_uid))
			train_grid.add_child(btn)

	# research + tier advance
	var tech_ids := []
	if is_hq:
		tech_ids.append("advance_tier_2")
		tech_ids.append("advance_tier_3")
	if not research.is_empty() or def.get("is_research", false):
		for tid in research:
			tech_ids.append(tid)

	if not tech_ids.is_empty():
		_add_command_section("Research", "Advance technology.")
		var research_grid := _mk_command_grid()
		_cmd_body.add_child(research_grid)
		for tid in tech_ids:
			var tdef := GameData.get_tech(tid)
			if tdef.is_empty():
				continue
			var cost: Dictionary = tdef.get("cost", {})
			# grey when unavailable (already done / wrong tier / researching)
			var available := true
			if _commander.has_method("can_research"):
				available = _commander.can_research(tid)
			var affordable: bool = _commander.can_afford(cost)
			var reason: String = "Already researched or unavailable" if not available else (_commander.missing_resource_summary(cost) if not affordable else "")
			var ready_to_research: bool = available and affordable
			var btn := _mk_command_button(str(tdef.get("name", tid)), "Cost: " + _cost_string(cost).trim_prefix("  (").trim_suffix(")"), str(tdef.get("desc", "")), reason, "LOCKED" if not ready_to_research else "READY")
			btn.disabled = not ready_to_research
			var cap_b = b
			var cap_tid := String(tid)
			btn.pressed.connect(func(): _try_queue_tech(cap_b, cap_tid))
			research_grid.add_child(btn)


func _try_queue_unit(b, uid: String) -> void:
	if not is_instance_valid(b) or not b.has_method("queue_unit"):
		return
	var res: Dictionary = b.queue_unit(uid)
	if res.get("ok", false):
		var nm: String = GameData.get_unit(uid).get("name", "Unit")
		_flash_notice("Training %s..." % nm, Color(0.6, 0.95, 0.6))
		Sfx.play("select", -8.0)
	else:
		_flash_notice(str(res.get("reason", "Cannot train")), Color(1, 0.55, 0.45))


func _try_queue_tech(b, tid: String) -> void:
	if not is_instance_valid(b) or not b.has_method("queue_tech"):
		return
	var res: Dictionary = b.queue_tech(tid)
	if res.get("ok", false):
		# tier advance / research done — refresh card so buttons grey out
		_rebuild_command_card(b, [b])
	else:
		_flash_notice(str(res.get("reason", "Cannot research")))


func _flash_notice(msg: String, col: Color = Color(1, 0.6, 0.5)) -> void:
	# Toast anchored just above the command card so the player always sees the
	# result of a train/build/research click.
	var box := PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.z_index = 60
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.04, 0.05, 0.92)
	sb.set_border_width_all(2)
	sb.border_color = col
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(12)
	box.add_theme_stylebox_override("panel", sb)
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 1.0
	box.anchor_bottom = 1.0
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.offset_top = -232
	box.offset_bottom = -190
	add_child(box)
	var l := _mk_label(msg, 20, col)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l)
	var tw := box.create_tween()
	tw.tween_interval(1.4)
	tw.tween_property(box, "modulate:a", 0.0, 0.6)
	tw.tween_callback(box.queue_free)


func _on_command_feedback_changed(feedback: Dictionary) -> void:
	var intent := String(feedback.get("intent", ""))
	var accepted := bool(feedback.get("accepted", false))
	var labels := {
		"MOVE": "Move order",
		"ATTACK": "Attack order",
		"GATHER": "Gather order",
		"BUILD_OR_REPAIR": "Construction order",
		"RALLY": "Rally point",
		"ATTACK_MOVE": "Attack-move order",
		"STOP": "Stop order",
		"HOLD": "Hold position",
		"PATROL": "Patrol order",
		"GUARD": "Guard unavailable",
	}
	var message := String(labels.get(intent, "Command"))
	var col := Color(0.45, 0.85, 1.0)
	if intent == "ATTACK" or intent == "ATTACK_MOVE":
		col = Color(1.0, 0.55, 0.35)
	elif intent == "GATHER":
		col = Color(1.0, 0.82, 0.35)
	elif intent == "BUILD_OR_REPAIR":
		col = Color(0.5, 0.95, 0.55)
	if not accepted:
		if intent == "GUARD" or String(feedback.get("feedback_type", "")) == "UNAVAILABLE":
			message = "Guard unavailable"
		elif intent == "BUILD_OR_REPAIR" and String(feedback.get("feedback_type", "")) == "REJECTED":
			message = "Build placement rejected"
		else:
			message = "No valid target"
		col = Color(1.0, 0.5, 0.42)
	_show_command_feedback(message, col)


func _show_command_feedback(message: String, col: Color) -> void:
	if is_instance_valid(_command_feedback_box):
		_command_feedback_box.queue_free()
	_command_feedback_box = PanelContainer.new()
	_command_feedback_box.custom_minimum_size = Vector2(220, 38)
	_command_feedback_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_command_feedback_box.z_index = 60
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.04, 0.05, 0.92)
	sb.set_border_width_all(2)
	sb.border_color = col
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(9)
	_command_feedback_box.add_theme_stylebox_override("panel", sb)
	_command_feedback_box.anchor_left = 0.5
	_command_feedback_box.anchor_right = 0.5
	_command_feedback_box.anchor_top = 1.0
	_command_feedback_box.anchor_bottom = 1.0
	_command_feedback_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_command_feedback_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_command_feedback_box.offset_top = -212
	_command_feedback_box.offset_bottom = -176
	add_child(_command_feedback_box)
	var label := _mk_label(message, 16, col)
	label.custom_minimum_size = Vector2(198, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_command_feedback_box.add_child(label)
	var tw := _command_feedback_box.create_tween()
	tw.tween_interval(0.9)
	tw.tween_property(_command_feedback_box, "modulate:a", 0.0, 0.35)
	tw.tween_callback(_command_feedback_box.queue_free)


# ---------------------------------------------------------------------------
# 5. ALERT / OBJECTIVE FEED (top-right)
# ---------------------------------------------------------------------------
func _build_alert_feed() -> void:
	_alert_box = VBoxContainer.new()
	_alert_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_alert_box.offset_left = -360
	_alert_box.offset_right = -14
	_alert_box.offset_top = 74
	_alert_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_alert_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	_alert_box.add_theme_constant_override("separation", 4)
	_alert_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_alert_box)


func _on_alert(message: String, _pos: Vector3) -> void:
	_push_alert(message, Color(0.95, 0.9, 0.75))


func _on_hero_leveled(level: int) -> void:
	_push_alert("Hero reached level %d!" % level, Color(0.95, 0.85, 0.4))
	Sfx.play("levelup", -4.0)


func _push_alert(message: String, col: Color) -> void:
	if not is_instance_valid(_alert_box):
		return
	# PLAYER mode shows only the latest meaningful alert so event history does
	# not compete with the selected card, command panel, or battlefield. The
	# explicit debug/review path keeps the prior four-entry feed intact.
	var alert_limit := DEBUG_REVIEW_ALERT_LIMIT if _debug_review_presentation() else PLAYER_ALERT_LIMIT
	while _alert_box.get_child_count() >= alert_limit:
		var oldest := _alert_box.get_child(0)
		_alert_box.remove_child(oldest)
		oldest.queue_free()
	var l := _mk_label(message, 15, col)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(340, 0)
	_alert_box.add_child(l)
	var tw := l.create_tween()
	tw.tween_interval(3.2)
	tw.tween_property(l, "modulate:a", 0.0, 0.8)
	tw.tween_callback(func():
		if is_instance_valid(l):
			l.queue_free())


# ---------------------------------------------------------------------------
# 7. GAME OVER
# ---------------------------------------------------------------------------
func _on_game_over(victory: bool) -> void:
	if is_instance_valid(_gameover_layer):
		return
	_gameover_layer = Control.new()
	_gameover_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gameover_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_gameover_layer)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.0)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_gameover_layer.add_child(dim)
	var dim_tw := dim.create_tween()
	dim_tw.tween_property(dim, "color:a", 0.78, 0.6)

	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	_gameover_layer.add_child(box)

	var heading := _mk_title_label("VICTORY" if victory else "DEFEAT", 64,
		Color(0.98, 0.85, 0.4) if victory else Color(0.9, 0.35, 0.3))
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(heading)

	var result: Dictionary = Match.last_result if Match else {}
	var kills := int(result.get("kills", 0))
	var xp := int(result.get("xp", 0))
	var t := int(result.get("time", 0))
	var mins := int(t) / 60
	var secs := int(t) % 60
	var reason := String(result.get("reason", "Conquest"))
	var summary := "%s   |   Enemies defeated: %d     Experience gained: %d     Time: %d:%02d" % [reason, kills, xp, mins, secs]
	var sum_label := _mk_label(summary, 20, Color(0.9, 0.87, 0.78))
	sum_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sum_label)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 24)
	box.add_child(btn_row)

	var continue_btn := _mk_button("Continue", 22)
	continue_btn.custom_minimum_size = Vector2(180, 56)
	continue_btn.pressed.connect(func(): emit_signal("return_to_menu"))
	btn_row.add_child(continue_btn)

	var replay_btn := _mk_button("Play Again", 22)
	replay_btn.custom_minimum_size = Vector2(180, 56)
	replay_btn.pressed.connect(func(): emit_signal("replay"))
	btn_row.add_child(replay_btn)
