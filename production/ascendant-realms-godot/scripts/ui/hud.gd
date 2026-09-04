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
const COMMAND_GLYPH_SCRIPT := "res://scripts/ui/command_glyph_view.gd"
const MAP_HALF := 140.0                # MapDefs.MAP_SIZE — world spans -140..140
const MINIMAP_SIZE := 232.0 # R3 preserves Emanuel's GOOD minimap-size verdict.
const MINIMAP_RASTER_SIZE := 160
const MINIMAP_GROUND_TEXTURE := "res://assets/textures/nature/highland_grass.png"
const MINIMAP_MEADOW_TEXTURE := "res://assets/textures/nature/highland_meadow_grass.png"
const MINIMAP_PANEL_HEIGHT := MINIMAP_SIZE + 48.0
const MINIMAP_GRID_DIVISIONS := 4
const MINIMAP_VIEW_FILL := Color(0.88, 0.93, 0.86, 0.025)
const MINIMAP_VIEW_EDGE := Color(0.96, 0.92, 0.68, 0.58)
const MINIMAP_WATER_SHORE := Color(0.64, 0.79, 0.72, 0.54)
const MINIMAP_WATER_BANK := Color(0.28, 0.43, 0.38, 0.42)
const COMMAND_PANEL_WIDTH := 430.0
const SELECTION_PANEL_WIDTH := 390.0
const SELECTION_PANEL_HEIGHT := 198.0
const FONT_COLOR := Color(0.95, 0.9, 0.8)
const COMMAND_INK := Color(0.035, 0.045, 0.06, 0.985)
const COMMAND_SURFACE := Color(0.075, 0.09, 0.11, 0.98)
const COMMAND_GOLD := Color(0.93, 0.72, 0.32)
const COMMAND_MINT := Color(0.42, 0.86, 0.67)
const COMMAND_SKY := Color(0.46, 0.76, 1.0)
const COMMAND_FLAME := Color(1.0, 0.5, 0.32)
const COMMAND_MUTED := Color(0.42, 0.44, 0.45)
const HUD_BRONZE := Color(0.62, 0.49, 0.28)
const HUD_SURFACE := Color(0.045, 0.055, 0.07, 0.965)
const HUD_SURFACE_INSET := Color(0.022, 0.029, 0.04, 0.78)
const HUD_TEXT_MUTED := Color(0.66, 0.69, 0.68)
const PORTRAIT_ASPECT_POLICY := "preserve source aspect"
const PORTRAIT_CROP_POLICY := "no crop; centered fit"
const PORTRAIT_FRAME_INSET := 5.0
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
var _opponent_count_label: Label = null
var _idle_worker_label: Label = null
var _idle_military_label: Label = null
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
var _command_tooltip: PanelContainer = null

# live-tracked selection widgets (refreshed in _process)
var _tracked_single = null             # currently shown single Unit/Building
var _inspection_target = null           # hostile read-only inspection target
var _single_read_only := false
var _single_hp_bar: ProgressBar = null
var _single_hp_text: Label = null
var _single_mana_bar: ProgressBar = null
var _single_mana_text: Label = null
var _single_stat_label: Label = null
var _single_stat_cards := []
var _single_activity_label: Label = null
var _single_target_label: Label = null
var _single_economy_label: Label = null
var _ability_widgets := []             # [{id, button, cd_overlay}]
var _multi_bars := []                  # [{unit, bar}]
var _queue_container: HBoxContainer = null
var _production_status_label: Label = null
var _watched_building = null           # building whose production we listen to
var _production_card_queue_key := ""
var _watched_construction_building = null # selected building whose construction can complete

# --- alerts ---
var _alert_box: VBoxContainer = null

# --- game over ---
var _gameover_layer: Control = null
var _command_feedback_box: PanelContainer = null

# This read-only hover tooltip reuses the RTS pointer raycast for public
# battlefield identity. It deliberately ignores mouse input so left-click
# selection and right-click commands remain owned by RTSController.
var _resource_tooltip: PanelContainer = null
var _resource_tooltip_label: Label = null
var _hovered_resource = null
var _resource_tooltip_accum := 0.0
const RESOURCE_TOOLTIP_POLL_INTERVAL := 0.08

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
	_build_resource_tooltip()
	_build_alert_feed()
	_fit_to_viewport()

	_connect_signals()
	# prime displays
	if _commander:
		_on_resources_changed(_commander.resources)
		_on_pop_changed(_commander.pop_used + _commander.reserved_pop, _commander.pop_cap)
		_on_tier_changed(_commander.tier)
		_refresh_opponent_count()
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
	var margin := 14.0
	var requested_selection_height := SELECTION_PANEL_HEIGHT
	if is_instance_valid(_sel_panel) and _sel_panel.has_meta("multi_selection_height"):
		requested_selection_height = float(_sel_panel.get_meta("multi_selection_height"))
	var selection_height := minf(requested_selection_height, maxf(184.0, viewport_size.y - margin * 2.0))
	var command_height := minf(220.0, maxf(184.0, viewport_size.y - margin * 2.0))
	if is_instance_valid(_minimap_panel):
		_minimap_panel.offset_left = margin
		_minimap_panel.offset_right = margin + MINIMAP_SIZE + 24.0
		_minimap_panel.offset_top = -margin - MINIMAP_PANEL_HEIGHT
		_minimap_panel.offset_bottom = -margin
	if is_instance_valid(_sel_panel):
		# Treat the selected entity and command deck as one interaction system:
		# keep a deliberate 12px seam between their shared bottom baseline at
		# every supported desktop width. This removes the disconnected floating
		# card feeling without stealing the tactical-map or battlefield region.
		var command_left := viewport_size.x - margin - COMMAND_PANEL_WIDTH
		var interaction_gap := 12.0
		var selection_right := command_left - interaction_gap
		var selection_left := selection_right - SELECTION_PANEL_WIDTH
		_sel_panel.offset_left = selection_left - viewport_size.x * 0.5
		_sel_panel.offset_right = selection_right - viewport_size.x * 0.5
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


func _build_resource_tooltip() -> void:
	_resource_tooltip = PanelContainer.new()
	_resource_tooltip.name = "ResourceHoverTooltip"
	_resource_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resource_tooltip.visible = false
	_resource_tooltip.custom_minimum_size = Vector2(188.0, 56.0)
	_resource_tooltip.add_theme_stylebox_override("panel", _resource_tooltip_stylebox())
	_resource_tooltip_label = _mk_label("", 15, Color(0.96, 0.91, 0.79))
	_resource_tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resource_tooltip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_resource_tooltip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_resource_tooltip_label.custom_minimum_size = Vector2(164.0, 44.0)
	_resource_tooltip_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	_resource_tooltip.add_child(_resource_tooltip_label)
	add_child(_resource_tooltip)


func _resource_tooltip_stylebox() -> StyleBoxFlat:
	var sb := _hud_stylebox()
	sb.bg_color = Color(0.05, 0.06, 0.075, 0.96)
	sb.border_color = Color(0.82, 0.65, 0.30, 0.98)
	sb.set_content_margin_all(10.0)
	return sb


func _update_resource_tooltip(pointer_override: Vector2 = Vector2(-1.0, -1.0)) -> void:
	if not is_instance_valid(_resource_tooltip) or not is_instance_valid(rts):
		return
	var hovered_control := get_viewport().gui_get_hovered_control()
	if is_instance_valid(hovered_control):
		_hovered_resource = null
		_resource_tooltip.visible = false
		return
	var pointer := get_viewport().get_mouse_position()
	if pointer_override.x >= 0.0 and pointer_override.y >= 0.0:
		pointer = pointer_override
	var hovered = rts.raycast_selection_at(pointer)
	if not is_instance_valid(hovered):
		_hovered_resource = null
		_resource_tooltip.visible = false
		return
	if hovered is ResourceNode:
		if bool(hovered.get("depleted")):
			_hovered_resource = null
			_resource_tooltip.visible = false
			return
		_hovered_resource = hovered
		var kind := String(hovered.get("resource_kind")).capitalize()
		var amount := maxi(0, int(hovered.get("amount")))
		_resource_tooltip_label.text = "%s\n%d remaining" % [kind, amount]
	elif hovered is Unit or hovered is Building:
		_hovered_resource = null
		var fallback_name := "Unit" if hovered is Unit else "Building"
		var public_name := String(hovered.def.get("name", fallback_name))
		var hostile: bool = "team" in hovered and int(hovered.team) != int(rts.player_team)
		_resource_tooltip_label.text = "%s\nHostile" % public_name if hostile else public_name
	else:
		_hovered_resource = null
		_resource_tooltip.visible = false
		return
	_resource_tooltip.reset_size()
	var viewport_size := get_viewport_rect().size
	var tooltip_size := _resource_tooltip.size
	var margin := Vector2(8.0, 8.0)
	var offset := Vector2(16.0, 18.0)
	var tooltip_pos := pointer + offset
	if tooltip_pos.x + tooltip_size.x > viewport_size.x - margin.x:
		tooltip_pos.x = pointer.x - tooltip_size.x - offset.x
	if tooltip_pos.y + tooltip_size.y > viewport_size.y - margin.y:
		tooltip_pos.y = pointer.y - tooltip_size.y - offset.y
	_resource_tooltip.position = Vector2(
		clampf(tooltip_pos.x, margin.x, maxf(margin.x, viewport_size.x - tooltip_size.x - margin.x)),
		clampf(tooltip_pos.y, margin.y, maxf(margin.y, viewport_size.y - tooltip_size.y - margin.y)))
	_resource_tooltip.visible = true


func _connect_signals() -> void:
	if _commander:
		_commander.resources_changed.connect(_on_resources_changed)
		_commander.pop_changed.connect(_on_pop_changed)
		_commander.tier_changed.connect(_on_tier_changed)
	if rts:
		rts.selection_changed.connect(_on_selection_changed)
		if rts.has_signal("inspection_changed"):
			rts.inspection_changed.connect(_on_inspection_changed)
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
	sb.bg_color = HUD_SURFACE
	sb.set_border_width_all(2)
	sb.border_color = Color(HUD_BRONZE.r, HUD_BRONZE.g, HUD_BRONZE.b, 0.92)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(10)
	sb.shadow_color = Color(0, 0, 0, 0.38)
	sb.shadow_size = 4
	return sb


func _hud_section_style(accent: Color = HUD_BRONZE) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = HUD_SURFACE_INSET
	sb.border_color = Color(accent.r, accent.g, accent.b, 0.58)
	sb.border_width_left = 2
	sb.set_corner_radius_all(5)
	sb.set_content_margin_all(7)
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


func _command_hotkey(title: String) -> String:
	var haystack := title.to_lower()
	if haystack.contains("attack"):
		return "J"
	if haystack.contains("stop"):
		return "K"
	if haystack.contains("hold"):
		return "H"
	if haystack.contains("patrol"):
		return "P"
	return ""


func _command_glyph(title: String) -> String:
	var haystack := title.to_lower()
	if haystack.contains("rally"):
		return "Q"
	if haystack.contains("slam"):
		return "W"
	if haystack.contains("attack"):
		return "A"
	if haystack.contains("stop"):
		return "S"
	if haystack.contains("hold"):
		return "H"
	if haystack.contains("patrol"):
		return "P"
	if haystack.contains("build") or haystack.contains("construction"):
		return "B"
	if haystack.contains("research") or haystack.contains("age"):
		return "R"
	if haystack.contains("train"):
		return "T"
	if haystack.contains("hero"):
		return "H"
	if haystack.contains("worker"):
		return "W"
	if haystack.contains("military"):
		return "M"
	if haystack.contains("building"):
		return "B"
	return "•"


func _command_kind(title: String, visible_effect_prefix: String, has_preview: bool, has_effect: bool) -> String:
	if visible_effect_prefix == "Effect" and has_effect:
		return "ABILITY"
	if visible_effect_prefix == "Purpose" or has_preview:
		return "BUILD"
	var haystack := title.to_lower()
	if haystack.contains("research") or haystack.contains("age"):
		return "RESEARCH"
	if haystack.contains("train"):
		return "TRAIN"
	return "ORDER"


func _command_accent(title: String, state: String) -> Color:
	if state == "LOCKED":
		return COMMAND_MUTED
	if state == "COOLDOWN":
		return Color(0.52, 0.7, 0.9)
	var haystack := title.to_lower()
	if haystack.contains("attack"):
		return COMMAND_FLAME
	if haystack.contains("build") or haystack.contains("construction"):
		return COMMAND_MINT
	if haystack.contains("research") or haystack.contains("age"):
		return COMMAND_SKY
	return COMMAND_GOLD


func _mk_command_badge(text: String, color: Color, min_width: float = 30.0) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.custom_minimum_size = Vector2(min_width, 20.0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(color.r, color.g, color.b, 0.16)
	sb.border_color = Color(color.r, color.g, color.b, 0.72)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(3)
	badge.add_theme_stylebox_override("panel", sb)
	var label := _mk_label(text, 9, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_child(label)
	return badge


func _mk_command_keycap(text: String, accent: Color) -> PanelContainer:
	var cap := PanelContainer.new()
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap.custom_minimum_size = Vector2(30, 25)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.035, 0.045, 0.06, 0.98)
	sb.border_color = Color(accent.r, accent.g, accent.b, 0.95)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(5)
	sb.set_content_margin_all(3)
	cap.add_theme_stylebox_override("panel", sb)
	var label := _mk_label(text, 11, Color(1.0, 0.96, 0.82))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cap.add_child(label)
	return cap


func _command_icon_kind(title: String, command_kind: String) -> String:
	if command_kind == "ABILITY":
		return "ability"
	var haystack := title.to_lower()
	if haystack.contains("attack"):
		return "attack"
	if haystack.contains("stop"):
		return "stop"
	if haystack.contains("hold"):
		return "hold"
	if haystack.contains("patrol"):
		return "patrol"
	if command_kind == "BUILD":
		return "build"
	if command_kind == "TRAIN":
		return "train"
	if command_kind == "RESEARCH":
		return "research"
	return "command"


func _mk_command_icon(kind: String, accent: Color, size_px: float) -> Control:
	if not ResourceLoader.exists(COMMAND_GLYPH_SCRIPT):
		return Control.new()
	var icon: Control = load(COMMAND_GLYPH_SCRIPT).new()
	icon.custom_minimum_size = Vector2(size_px, size_px)
	icon.size = Vector2(size_px, size_px)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.configure(kind, accent)
	return icon


func _command_icon_stylebox(accent: Color, ability_card: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(accent.r, accent.g, accent.b, 0.22 if ability_card else 0.14)
	sb.border_color = Color(accent.r, accent.g, accent.b, 0.96)
	sb.set_border_width_all(0)
	sb.border_width_left = 2
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(3)
	return sb


func _add_stat_chip(row: HBoxContainer, caption: String, value: String, kind: String, accent: Color) -> void:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(64, 34)
	chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.055, 0.07, 0.082, 0.98)
	sb.border_color = Color(accent.r, accent.g, accent.b, 0.58)
	sb.border_width_left = 2
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(3)
	sb.set_content_margin_all(4)
	chip.add_theme_stylebox_override("panel", sb)
	var label := _mk_label("%s  %s" % [caption, value], 10, FONT_COLOR)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.tooltip_text = "%s: %s" % [caption, value]
	chip.add_child(label)
	row.add_child(chip)
	_single_stat_cards.append({"kind": kind, "label": label, "caption": caption})


func _apply_ability_button_style(button: Button, accent: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.1, 0.13, 0.98)
	normal.border_color = Color(accent.r, accent.g, accent.b, 0.72)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(5)
	normal.set_content_margin_all(4)
	var hover := normal.duplicate()
	hover.bg_color = Color(accent.r, accent.g, accent.b, 0.2)
	hover.border_color = accent
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.045, 0.05, 0.06, 0.95)
	disabled.border_color = Color(0.28, 0.29, 0.3, 0.7)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color(0.96, 0.92, 0.8))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.9))
	button.add_theme_color_override("font_disabled_color", Color(0.52, 0.52, 0.5))


func _mk_command_button(title: String, detail: String, tooltip: String, disabled_reason: String = "", state: String = "READY", preview_definition: Dictionary = {}, visible_effect: String = "", visible_effect_prefix: String = "Effect", hotkey_override: String = "") -> Button:
	var state_text := "LOCKED · " if state == "LOCKED" else ("COOLDOWN · " if state == "COOLDOWN" else "")
	var has_preview := not preview_definition.is_empty()
	# Hero abilities provide their authored Q/W hotkey explicitly while ordinary
	# order cards derive their hotkeys from the title. That keeps the ability
	# treatment distinct without changing any command dispatch semantics.
	var ability_card := visible_effect_prefix == "Effect" and not hotkey_override.is_empty()
	var effect_text := visible_effect.strip_edges() if ability_card else ""
	var has_effect := not effect_text.is_empty()
	var command_kind := "ABILITY" if ability_card else _command_kind(title, visible_effect_prefix, has_preview, has_effect)
	var role_card := visible_effect_prefix == "Role"
	# The card is a scan surface. Full authored explanations stay in the
	# anchored tooltip so the grid no longer reads like a stack of debug forms.
	# Normal cards are scan surfaces. Full authored prose belongs in the
	# tooltip; only build costs/requirements and authored ability effects stay
	# visible because they are essential state, not explanations.
	var detail_text := _command_card_summary(detail) if has_preview or ability_card else ""
	if not disabled_reason.is_empty():
		detail_text += "\n" + disabled_reason
	if has_effect:
		detail_text += "\n" + visible_effect_prefix + ": " + _command_card_summary(effect_text)
	var accent := _command_accent(title, state)
	var hotkey := hotkey_override if not hotkey_override.is_empty() else _command_hotkey(title)
	var btn := _mk_button("", 11)
	# Build cards need one extra visual beat for the name/cost/state scan. Keep
	# the deck compact enough for five authored structures without changing the
	# command surface's existing two-column layout.
	var card_height := 88 if ability_card else (82 if has_preview else 72)
	if has_effect:
		card_height = 100 if role_card else (110 if ability_card else 94)
	btn.custom_minimum_size = Vector2(198, card_height)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.clip_text = false
	btn.focus_mode = Control.FOCUS_NONE
	if has_preview and ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
		var preview = load(ENTITY_PORTRAIT_SCRIPT).new()
		preview.name = "BuildingPreview"
		preview.position = Vector2(9, 9)
		preview.size = Vector2(64, 64)
		preview.custom_minimum_size = Vector2(64, 64)
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(preview)
		preview.configure_definition(preview_definition)
		# EntityPortraitView raises its own minimum to 112px for full-size cards;
		# defer the compact-card override until its _ready() has run so the preview
		# cannot expand back over the cost text column.
		preview.set_deferred("custom_minimum_size", Vector2(64, 64))
		preview.set_deferred("size", Vector2(64, 64))
		var text_col := VBoxContainer.new()
		text_col.position = Vector2(82, 8)
		var preview_text_height := card_height - 38 if has_effect else 66
		text_col.size = Vector2(108, preview_text_height)
		text_col.custom_minimum_size = Vector2(108, preview_text_height)
		text_col.add_theme_constant_override("separation", 1)
		text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var title_label := _mk_label(title, 14, FONT_COLOR)
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_col.add_child(title_label)
		var preview_detail_color := Color(0.82, 0.82, 0.76) if state == "LOCKED" else Color(0.9, 0.88, 0.8)
		var detail_label := _mk_label(state_text + detail_text, 12, preview_detail_color)
		detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		text_col.add_child(detail_label)
		btn.add_child(text_col)
	else:
		var glyph_plate := PanelContainer.new()
		glyph_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glyph_plate.position = Vector2(9, 9)
		glyph_plate.size = Vector2(58 if ability_card else 52, 58 if ability_card else 52)
		glyph_plate.custom_minimum_size = glyph_plate.size
		glyph_plate.add_theme_stylebox_override("panel", _command_icon_stylebox(accent, ability_card))
		glyph_plate.add_child(_mk_command_icon(_command_icon_kind(title, command_kind), accent, 42.0 if ability_card else 38.0))
		btn.add_child(glyph_plate)
		var text_col := VBoxContainer.new()
		text_col.position = Vector2(76 if ability_card else 68, 8)
		var text_height := (card_height - 32 if ability_card else 42) if has_effect else 42
		text_col.size = Vector2(118, text_height)
		text_col.custom_minimum_size = Vector2(118, text_height)
		text_col.add_theme_constant_override("separation", 1)
		text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var title_color := Color(0.52, 0.52, 0.5, 0.9) if state == "LOCKED" else FONT_COLOR
		var detail_color := Color(0.42, 0.42, 0.39, 0.9) if state == "LOCKED" else Color(0.86, 0.84, 0.76)
		var title_label := _mk_label(title, 15, title_color)
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_col.add_child(title_label)
		var detail_label := _mk_label(state_text + detail_text, 13, detail_color)
		detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		text_col.add_child(detail_label)
		btn.add_child(text_col)
	if not hotkey.is_empty():
		var key_badge := _mk_command_keycap(hotkey, accent)
		key_badge.position = Vector2(160, 8)
		key_badge.size = Vector2(27, 24)
		btn.add_child(key_badge)
	var kind_label := _mk_label(command_kind, 9, Color(accent.r, accent.g, accent.b, 0.82))
	kind_label.position = Vector2(9, card_height - 18)
	kind_label.size = Vector2(96, 17)
	kind_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(kind_label)
	if not has_preview:
		var status := state if state in ["READY", "ACTIVE", "TRAINING", "LOCKED", "COOLDOWN", "COMPLETED"] else ("UNAVAILABLE" if not disabled_reason.is_empty() else "READY")
		var status_label := _mk_label(status, 9, accent if status not in ["UNAVAILABLE", "LOCKED"] else COMMAND_MUTED)
		status_label.position = Vector2(124 if ability_card else 122, card_height - 18)
		status_label.size = Vector2(64, 16)
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(status_label)
		btn.set_meta("command_status_label", status_label)
	else:
		# The worker deck already labels the family as BUILD. Use the lower-right
		# slot for the actionable state so READY versus LOCKED is readable without
		# relying on a paragraph of disabled-reason text.
		var build_status := _mk_label(state, 9, accent if state == "READY" else COMMAND_MUTED)
		build_status.position = Vector2(122, card_height - 18)
		build_status.size = Vector2(64, 16)
		build_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		build_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(build_status)
		btn.set_meta("command_status_label", build_status)
	btn.set_meta("command_kind", command_kind)
	var tooltip_text := tooltip
	if not hotkey.is_empty():
		tooltip_text += "\nHotkey: " + hotkey
	var full_tooltip := tooltip_text if disabled_reason.is_empty() else "%s\nUnavailable: %s" % [tooltip_text, disabled_reason]
	# The default floating tooltip is intentionally replaced by the anchored
	# command tooltip panel so the information stays compact and deliberate.
	btn.tooltip_text = ""
	btn.set_meta("command_tooltip_text", full_tooltip)
	btn.mouse_entered.connect(func(): _show_command_tooltip(title, command_kind, hotkey, tooltip, disabled_reason, accent))
	btn.mouse_exited.connect(_hide_command_tooltip)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.055, 0.09, 0.145, 0.99) if ability_card else Color(0.065, 0.08, 0.095, 0.98)
	normal.border_color = Color(accent.r, accent.g, accent.b, 0.68)
	normal.set_border_width_all(0)
	normal.border_width_left = 4 if ability_card else 3
	normal.border_width_bottom = 1
	normal.set_corner_radius_all(5)
	normal.set_content_margin_all(5)
	var hover := normal.duplicate()
	hover.bg_color = Color(accent.r, accent.g, accent.b, 0.17)
	hover.border_color = accent
	hover.border_width_left = 3
	hover.border_width_bottom = 2
	var pressed := hover.duplicate()
	pressed.bg_color = Color(accent.r, accent.g, accent.b, 0.28)
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.045, 0.05, 0.06, 0.94) if not ability_card else Color(0.06, 0.065, 0.08, 0.98)
	disabled.border_color = Color(0.25, 0.26, 0.27, 0.7)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_disabled_color", Color(0.48, 0.47, 0.43, 0.9))
	return btn


func _command_card_summary(detail: String) -> String:
	var lines := detail.split("\n", false)
	if lines.is_empty():
		return ""
	var summary := String(lines[0]).strip_edges()
	if summary.length() > 44:
		summary = summary.left(41).rstrip(" .,:;") + "…"
	return summary


func _ability_glyph_stylebox(accent: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(accent.r, accent.g, accent.b, 0.20)
	sb.border_color = Color(accent.r, accent.g, accent.b, 0.95)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(3)
	return sb


func _mk_command_grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return grid


func _add_command_section(title: String, hint: String = "") -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 32)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(4, 22)
	rule.color = COMMAND_GOLD
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(rule)
	var title_label := _mk_label(title.to_upper(), 12, COMMAND_GOLD)
	title_label.custom_minimum_size = Vector2(88, 24)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(title_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	if not hint.is_empty():
		var hint_label := _mk_label(hint, 11, Color(0.68, 0.7, 0.68))
		hint_label.custom_minimum_size = Vector2(130, 24)
		hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(hint_label)
	_cmd_body.add_child(row)


# ---------------------------------------------------------------------------
# 1. TOP BAR
# ---------------------------------------------------------------------------
func _top_metric_surface(title: String, accent: Color, width: float, tooltip: String) -> Dictionary:
	# Metrics live inside a family ribbon rather than reading as independent
	# telemetry cards. The value row contract is retained so all authoritative
	# refresh handlers remain unchanged.
	var surface := VBoxContainer.new()
	surface.custom_minimum_size = Vector2(width, 52)
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	surface.tooltip_text = tooltip
	surface.add_theme_constant_override("separation", 0)
	var title_label := _mk_label(title.to_upper(), 9, accent.lerp(HUD_TEXT_MUTED, 0.16))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	surface.add_child(title_label)
	var value_row := HBoxContainer.new()
	value_row.add_theme_constant_override("separation", 5)
	value_row.alignment = BoxContainer.ALIGNMENT_CENTER
	value_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_row.custom_minimum_size = Vector2(0, 30)
	surface.add_child(value_row)
	return {"surface": surface, "value_row": value_row}


func _top_group(title: String, accent: Color, width: float) -> Dictionary:
	var group := VBoxContainer.new()
	group.custom_minimum_size = Vector2(width, 56)
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	group.add_theme_constant_override("separation", 1)
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var heading := _mk_label(title, 9, accent)
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.add_child(heading)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 1)
	rule.color = Color(accent.r, accent.g, accent.b, 0.66)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.add_child(rule)
	var metrics := HBoxContainer.new()
	metrics.add_theme_constant_override("separation", 5)
	metrics.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	metrics.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.add_child(metrics)
	return {"group": group, "metrics": metrics}


func _build_top_bar() -> void:
	var panel := _mk_hud_panel()
	_top_panel = panel
	_top_panel.name = "TopResourceBar"
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_bottom = 64.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(0, 64)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 112)  # keep clear of the Menu button
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_bottom", 3)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(row)

	var resource_accents := {
		"food": Color(0.96, 0.72, 0.32),
		"timber": Color(0.76, 0.54, 0.32),
		"stone": Color(0.63, 0.72, 0.78),
		"gold": Color(0.98, 0.86, 0.42),
	}
	var economy := _top_group("ECONOMY", COMMAND_GOLD, 370.0)
	var economy_metrics: HBoxContainer = economy["metrics"]
	for k in RES_ORDER:
		var metric := _top_metric_surface(k.capitalize(), resource_accents[k], 88.0, "%s resource" % k.capitalize())
		var cell: HBoxContainer = metric["value_row"]
		cell.add_child(_mk_icon(RES_ICONS[k], 25))
		var l := _mk_label("0", 30, FONT_COLOR)
		l.custom_minimum_size = Vector2(64, 0)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_res_labels[k] = l
		cell.add_child(l)
		economy_metrics.add_child(metric["surface"])
	row.add_child(economy["group"])

	var sep := VSeparator.new()
	sep.custom_minimum_size = Vector2(1, 46)
	sep.modulate = Color(0.75, 0.62, 0.36, 0.62)
	row.add_child(sep)

	var force := _top_group("ARMY / CONTROL", COMMAND_SKY, 410.0)
	var force_metrics: HBoxContainer = force["metrics"]
	# Population remains a force metric rather than another resource number.
	var pop_metric := _top_metric_surface("Population", COMMAND_GOLD, 98.0, "Population: current units / population cap")
	var pop_cell: HBoxContainer = pop_metric["value_row"]
	pop_cell.add_child(_mk_icon(RES_ICONS["food"], 21))
	_pop_label = _mk_label("0/0", 28)
	_pop_label.custom_minimum_size = Vector2(76, 0)
	_pop_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pop_cell.add_child(_pop_label)
	force_metrics.add_child(pop_metric["surface"])

	# Strategic opposition remains visible after transient defeat alerts expire.
	# This reads only the authoritative Commander roster and stays subordinate to
	# the existing resource/population status language.
	var opponent_metric := _top_metric_surface("Opponents", COMMAND_FLAME, 96.0, "Living opposing commanders")
	var opponent_cell: HBoxContainer = opponent_metric["value_row"]
	_opponent_count_label = _mk_label("0", 28, Color(0.92, 0.84, 0.74))
	_opponent_count_label.name = "OpponentCountLabel"
	_opponent_count_label.custom_minimum_size = Vector2(100, 0)
	_opponent_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	opponent_cell.add_child(_opponent_count_label)
	force_metrics.add_child(opponent_metric["surface"])

	# idle workers: persistent economy awareness in the existing player-status bar.
	# The count is refreshed at the same low rate as resources/population and does
	# not create a toast or world marker for every short worker transition.
	var worker_metric := _top_metric_surface("Idle Workers", COMMAND_MINT, 108.0, "Workers without an active order")
	var worker_cell: HBoxContainer = worker_metric["value_row"]
	worker_cell.add_child(_mk_icon(RES_ICONS["food"], 21))
	_idle_worker_label = _mk_label("0", 28, Color(0.82, 0.94, 0.78))
	_idle_worker_label.custom_minimum_size = Vector2(78, 0)
	_idle_worker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	worker_cell.add_child(_idle_worker_label)
	force_metrics.add_child(worker_metric["surface"])

	# Military awareness sits beside the existing worker awareness, but is kept
	# separate so "Idle 3" can never be mistaken for an idle army count.
	var army_metric := _top_metric_surface("Idle Army", COMMAND_SKY, 104.0, "Military units without an active order")
	var army_cell: HBoxContainer = army_metric["value_row"]
	army_cell.add_child(_mk_icon(RES_ICONS["stone"], 21))
	_idle_military_label = _mk_label("0", 28, Color(0.82, 0.9, 1.0))
	_idle_military_label.custom_minimum_size = Vector2(74, 0)
	_idle_military_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	army_cell.add_child(_idle_military_label)
	force_metrics.add_child(army_metric["surface"])
	row.add_child(force["group"])

	# age / tier
	var progression := _top_group("PROGRESSION", COMMAND_GOLD, 132.0)
	var progression_metrics: HBoxContainer = progression["metrics"]
	var tier_metric := _top_metric_surface("Age", COMMAND_GOLD, 122.0, "Current Age")
	var tier_cell: HBoxContainer = tier_metric["value_row"]
	_tier_label = _mk_label("Age I", 29, Color(0.98, 0.88, 0.55))
	_tier_label.custom_minimum_size = Vector2(122, 0)
	_tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier_cell.add_child(_tier_label)
	progression_metrics.add_child(tier_metric["surface"])
	row.add_child(progression["group"])

	# menu button (top-right corner)
	var menu_btn := _mk_button("Menu", 16)
	_menu_button = menu_btn
	_menu_button.name = "MenuButton"
	menu_btn.custom_minimum_size = Vector2(88, 36)
	menu_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	menu_btn.offset_left = -104.0
	menu_btn.offset_right = -14.0
	menu_btn.offset_top = 12.0
	menu_btn.offset_bottom = 48.0
	menu_btn.pressed.connect(func(): emit_signal("pause_requested"))
	add_child(menu_btn)

	# Compact persistent match identity: keeps the authoritative matchup and
	# victory rule visible without introducing a new panel or changing gameplay.
	var identity := Match.get_identity_snapshot() if Match else {}
	var player_race := str(identity.get("player_race", ""))
	var opponent_race := ""
	var opponents: Array = identity.get("opponents", [])
	if not opponents.is_empty():
		opponent_race = str(opponents[0].get("race", ""))
	var player_name := str(GameData.RACES.get(player_race, {}).get("name", player_race)).strip_edges()
	var opponent_name := str(GameData.RACES.get(opponent_race, {}).get("name", opponent_race)).strip_edges()
	var mode_name := str(identity.get("mode", "skirmish")).capitalize()
	var map_id := str(identity.get("map", "hollowspan"))
	var map_name := str(MapDefs.get_map(map_id).get("name", map_id)).strip_edges()
	var identity_label := _mk_label("%s  vs  %s  •  %s  •  %s" % [player_name, opponent_name, mode_name, map_name], 12, Color(0.88, 0.82, 0.7))
	identity_label.name = "MatchIdentityLabel"
	identity_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	identity_label.offset_left = -560.0
	identity_label.offset_right = -122.0
	identity_label.offset_top = 51.0
	identity_label.offset_bottom = 72.0
	identity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	identity_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	identity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(identity_label)
	var victory_kind := str(identity.get("victory", "conquest")).to_lower()
	var objective_text := "CONQUEST  •  ELIMINATE THE ENEMY'S REBUILD CAPABILITY" if victory_kind == "conquest" else victory_kind.capitalize()
	var objective_label := _mk_label(objective_text, 11, Color(0.62, 0.67, 0.7))
	objective_label.name = "MatchObjectiveLabel"
	objective_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	objective_label.offset_left = 830.0
	objective_label.offset_right = 1200.0
	objective_label.offset_top = 75.0
	objective_label.offset_bottom = 94.0
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	objective_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	objective_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(objective_label)


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


func _refresh_opponent_count() -> void:
	if not is_instance_valid(_opponent_count_label) or not is_instance_valid(world):
		return
	var count := 0
	for i in range(1, world.commanders.size()):
		var cmd = world.commanders[i]
		if is_instance_valid(cmd) and not cmd.defeated:
			count += 1
	_opponent_count_label.text = str(count)


# ---------------------------------------------------------------------------
# 2. MINIMAP
# ---------------------------------------------------------------------------
func _build_minimap() -> void:
	var panel := _mk_hud_panel()
	_minimap_panel = panel
	_minimap_panel.name = "MinimapPanel"
	# The map is a navigation instrument; its title carries the interaction hint
	# and marker shapes carry the legend, avoiding a tiny debug-like footer.
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
	var hint := _mk_label("NAVIGATION  /  CLICK TO FOCUS", 9, HUD_TEXT_MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(hint)
	_minimap = Control.new()
	_minimap.custom_minimum_size = Vector2(MINIMAP_SIZE, MINIMAP_SIZE)
	_minimap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_minimap.mouse_filter = Control.MOUSE_FILTER_STOP
	_minimap.draw.connect(_draw_minimap)
	_minimap.gui_input.connect(_on_minimap_input)
	column.add_child(_minimap)


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
		var building_def: Dictionary = b.def if b.def is Dictionary else {}
		var is_major := bool(building_def.get("is_hq", false)) or str(building_def.get("kind", "")) == "main"
		_draw_minimap_building(_world_to_map(b.global_position), GameData.TEAM_COLORS.get(b.team, Color.WHITE), is_major)

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
		# The footprint is a quiet navigation cue, not a competing selection box.
		_minimap.draw_polyline(corners, Color(0.04, 0.05, 0.05, 0.36), 1.8, false)
		_minimap.draw_polyline(corners, MINIMAP_VIEW_EDGE, 1.0, false)


func _draw_minimap_terrain(size: Vector2) -> void:
	# The cached image is the geographic base. Water and world shelves are read
	# from the same map/world that renders the battlefield; live markers are
	# layered separately below. Avoid synthetic camouflage blobs or a decorative
	# board-game overlay that has no spatial correspondence to the world.
	var edge := Color(0.86, 0.78, 0.58, 0.68)
	_minimap.draw_rect(Rect2(Vector2(6, 6), size - Vector2(12, 12)), edge, false, 2.0)
	var water: Dictionary = world.map.get("water", {})
	var overview: Dictionary = world.map.get("overview", {})
	if bool(water.get("enabled", false)):
		var axis := str(overview.get("water_axis", "north_bay"))
		var center_z := float(overview.get("water_center_z", 118.0))
		var half_width := float(overview.get("water_width", 34.0)) * 0.5
		if axis == "crossing":
			var crossing_top_y := _world_to_map(Vector3(0.0, 0.0, center_z - half_width)).y
			var crossing_bottom_y := _world_to_map(Vector3(0.0, 0.0, center_z + half_width)).y
			_minimap.draw_line(Vector2(7.0, crossing_top_y), Vector2(size.x - 7.0, crossing_top_y), MINIMAP_WATER_SHORE, 1.25, true)
			_minimap.draw_line(Vector2(7.0, crossing_bottom_y), Vector2(size.x - 7.0, crossing_bottom_y), MINIMAP_WATER_BANK, 0.9, true)
		else:
			var shore_y := _world_to_map(Vector3(0.0, 0.0, center_z - half_width)).y
			_minimap.draw_line(Vector2(7.0, shore_y), Vector2(size.x - 7.0, shore_y), MINIMAP_WATER_SHORE, 1.25, true)
	_draw_minimap_roads(size)

func _draw_minimap_frame(size: Vector2) -> void:
	_minimap.draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.04, 0.04, 0.96), false, 3.0)
	_minimap.draw_rect(Rect2(Vector2(4, 4), size - Vector2(8, 8)), Color(0.68, 0.55, 0.30, 0.92), false, 1.0)
	for corner in [Vector2(5, 5), Vector2(size.x - 5, 5), Vector2(size.x - 5, size.y - 5), Vector2(5, size.y - 5)]:
		_minimap.draw_circle(corner, 1.5, Color(0.95, 0.79, 0.38, 0.95))

func _draw_minimap_building(p: Vector2, col: Color, is_major: bool = false) -> void:
	var radius := 7.0 if is_major else 5.0
	_minimap.draw_circle(p, radius + 1.8, Color(0.02, 0.03, 0.03, 0.9))
	var points := PackedVector2Array([
		p + Vector2(0, -radius), p + Vector2(radius, 0),
		p + Vector2(0, radius), p + Vector2(-radius, 0)])
	_minimap.draw_colored_polygon(points, col.darkened(0.20 if is_major else 0.30))
	_minimap.draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), col.lightened(0.18), 1.4 if is_major else 0.9, true)
	if is_major:
		_minimap.draw_rect(Rect2(p - Vector2(2.2, 2.2), Vector2(4.4, 4.4)), col.lightened(0.30), true)
	else:
		_minimap.draw_line(p + Vector2(-2.0, 0), p + Vector2(2.0, 0), col.lightened(0.12), 0.8, true)

func _draw_minimap_unit(p: Vector2, col: Color) -> void:
	# Unit diamonds need to remain legible beside the larger building and
	# resource landmarks at the authored 232px tactical-map size.
	var r := 4.0
	_minimap.draw_circle(p, r + 1.25, Color(0.02, 0.03, 0.03, 0.86))
	_minimap.draw_colored_polygon(PackedVector2Array([
		p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r), p + Vector2(-r, 0)]), col)
	_minimap.draw_line(p + Vector2(-2.0, 0), p + Vector2(2.0, 0), Color(1, 1, 1, 0.76), 1.0, true)

func _draw_minimap_resource(p: Vector2, col: Color) -> void:
	_minimap.draw_circle(p, 3.3, Color(0.03, 0.04, 0.04, 0.82))
	_minimap.draw_circle(p, 2.05, col)
	_minimap.draw_line(p + Vector2(-1.0, -1.0), p + Vector2(1.0, 1.0), Color(1, 1, 1, 0.48), 0.8, true)


func _draw_minimap_roads(_size: Vector2) -> void:
	if not is_instance_valid(world):
		return
	# The ground shader burns these same start-to-centre segments into the
	# authored battlefield material. Mirror that source geometry as subdued
	# navigation tracks instead of consuming presentation-only overview roads.
	var route_color := Color(0.25, 0.19, 0.12, 0.24)
	for start in world.map.get("start_positions", []):
		if start is Vector3:
			_minimap.draw_line(_world_to_map(start), _world_to_map(Vector3.ZERO), route_color, 1.25, true)
	# This is the corresponding authored contested-middle link in
	# TerrainBuilder._make_ground_material(). Keep it subordinate to terrain.
	_minimap.draw_line(_world_to_map(Vector3(-30.0, 0.0, -20.0)), _world_to_map(Vector3(30.0, 0.0, 20.0)), Color(0.28, 0.23, 0.15, 0.18), 0.8, true)

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


func _minimap_world_landform_specs() -> Array:
	# Project the actual visual shelf nodes built by TerrainBuilder. These are
	# presentation-only scenery over the existing flat playable plane, so their
	# centre/extent is safe to read once into the cached raster and never during
	# the live marker refresh.
	if not is_instance_valid(world):
		return []
	var specs: Array = []
	for shelf in world.get_tree().get_nodes_in_group("world03_shelves"):
		if not is_instance_valid(shelf) or not shelf is MeshInstance3D or shelf.mesh == null:
			continue
		var aabb: AABB = shelf.mesh.get_aabb()
		var radius := Vector2(maxf(aabb.size.x * 0.44, 4.0), maxf(aabb.size.z * 0.44, 4.0))
		specs.append({
			"center": Vector2(shelf.global_position.x, shelf.global_position.z),
			"radius": radius,
			"rotation": -float(shelf.global_rotation.y),
		})
	return specs

func _ensure_minimap_background() -> void:
	if not is_instance_valid(world):
		return
	var map_id := str(world.map.get("id", ""))
	var theme_name := str(world.map.get("theme", "highland"))
	var shelf_count: int = world.get_tree().get_nodes_in_group("world03_shelves").size()
	var cache_key := map_id + ":" + theme_name + ":" + str(shelf_count)
	if cache_key == _minimap_background_key and is_instance_valid(_minimap_background):
		return
	var image := Image.create(MINIMAP_RASTER_SIZE, MINIMAP_RASTER_SIZE, false, Image.FORMAT_RGBA8)
	var water: Dictionary = world.map.get("water", {})
	var overview: Dictionary = world.map.get("overview", {})
	var base := _minimap_theme_color(theme_name, false)
	var water_enabled := bool(water.get("enabled", false))
	var axis := str(overview.get("water_axis", "north_bay"))
	var center_z := float(overview.get("water_center_z", 118.0))
	var half_width := float(overview.get("water_width", 34.0)) * 0.5
	var deep: Color = water.get("deep", Color(0.05, 0.22, 0.34))
	var shallow: Color = water.get("shallow", Color(0.16, 0.48, 0.58))
	var landforms: Array = _minimap_world_landform_specs()
	var ground_texture: Texture2D = load(MINIMAP_GROUND_TEXTURE) as Texture2D
	var meadow_texture: Texture2D = load(MINIMAP_MEADOW_TEXTURE) as Texture2D
	var has_ground_image: bool = is_instance_valid(ground_texture)
	var has_meadow_image: bool = is_instance_valid(meadow_texture)
	var ground_image: Image = ground_texture.get_image() if has_ground_image else Image.new()
	var meadow_image: Image = meadow_texture.get_image() if has_meadow_image else Image.new()
	for y in range(MINIMAP_RASTER_SIZE):
		for x in range(MINIMAP_RASTER_SIZE):
			var wp := Vector3(
				(float(x) / float(MINIMAP_RASTER_SIZE - 1) * MAP_HALF * 2.0) - MAP_HALF,
				0.0,
				(float(y) / float(MINIMAP_RASTER_SIZE - 1) * MAP_HALF * 2.0) - MAP_HALF)
			# A restrained north-to-south grade gives the miniature depth without
			# inventing random blobs that the player cannot find in the world.
			var latitude := float(y) / float(MINIMAP_RASTER_SIZE - 1)
			var col := base.lerp(base.lightened(0.10), 1.0 - absf(latitude - 0.5) * 1.45)
			# Reuse the same authored ground materials as TerrainBuilder. This is a
			# one-time cache build, not a live texture load or a second world render.
			if has_ground_image:
				var tx: int = posmod(int(floor(wp.x * 0.92)), ground_image.get_width())
				var tz: int = posmod(int(floor(wp.z * 0.92)), ground_image.get_height())
				var ground_sample: Color = ground_image.get_pixel(tx, tz)
				if has_meadow_image:
					var meadow_sample: Color = meadow_image.get_pixel(posmod(tx, meadow_image.get_width()), posmod(tz, meadow_image.get_height()))
					ground_sample = ground_sample.lerp(meadow_sample, 0.36)
				col = col.lerp(ground_sample, 0.42)
				# Keep authored texture variation readable at minimap scale while
				# avoiding any newly invented landform shapes.
				var texture_luma := (ground_sample.r + ground_sample.g + ground_sample.b) / 3.0
				col = col.lightened(clampf((texture_luma - 0.42) * 0.16, -0.05, 0.08))
			var edge := minf(minf(wp.x + MAP_HALF, MAP_HALF - wp.x), minf(wp.z + MAP_HALF, MAP_HALF - wp.z))
			if edge < 10.0:
				col = col.darkened(0.18)
			if water_enabled:
				var distance := _minimap_water_distance(wp, axis, center_z, half_width)
				if distance <= 0.0:
					# Tint the authored water toward the surrounding material so the
					# crossing reads as a world feature rather than a UI stripe.
					var water_tint := deep.lerp(shallow, 0.12 + clampf(absf(wp.x) / MAP_HALF, 0.0, 1.0) * 0.10)
					col = water_tint.lerp(base, 0.16)
				elif distance < 5.0:
					col = shallow.lerp(base, distance / 5.0).lerp(base, 0.08)
			for landform in landforms:
				var center: Vector2 = landform["center"]
				var radius: Vector2 = landform["radius"]
				var local := Vector2(wp.x - center.x, wp.z - center.y).rotated(float(landform.get("rotation", 0.0)))
				var dx := local.x / radius.x
				var dz := local.y / radius.y
				var landform_distance := dx * dx + dz * dz
				if landform_distance < 0.78:
					col = Color(0.26, 0.29, 0.25, 1.0)
				elif landform_distance < 1.0:
					col = Color(0.40, 0.42, 0.35, 1.0)
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

	_resource_tooltip_accum += delta
	if _resource_tooltip_accum >= RESOURCE_TOOLTIP_POLL_INTERVAL:
		_resource_tooltip_accum = 0.0
		_update_resource_tooltip()

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
	_on_idle_military_count(_count_meaningfully_idle_military())


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


func _count_meaningfully_idle_military() -> int:
	if not is_instance_valid(_commander):
		return 0
	var count := 0
	for unit in _commander.units:
		if not is_instance_valid(unit) or unit.is_dead or unit.is_worker:
			continue
		if int(unit.state) == Unit.State.IDLE:
			count += 1
	return count


func _on_idle_worker_count(count: int) -> void:
	if not is_instance_valid(_idle_worker_label):
		return
	_idle_worker_label.text = str(count)
	_idle_worker_label.add_theme_color_override("font_color",
		Color(0.98, 0.73, 0.36) if count > 0 else Color(0.72, 0.73, 0.68))


func _on_idle_military_count(count: int) -> void:
	if not is_instance_valid(_idle_military_label):
		return
	_idle_military_label.text = str(count)
	_idle_military_label.add_theme_color_override("font_color",
		Color(0.98, 0.73, 0.36) if count > 0 else Color(0.72, 0.73, 0.68))


# ---------------------------------------------------------------------------
# 3. SELECTION PANEL
# ---------------------------------------------------------------------------
func _build_selection_panel() -> void:
	_sel_panel = _mk_hud_panel()
	_sel_panel.name = "SelectionPanel"
	var selection_surface := _hud_stylebox()
	selection_surface.bg_color = Color(0.035, 0.048, 0.062, 0.985)
	selection_surface.border_color = Color(0.82, 0.65, 0.30, 0.96)
	selection_surface.set_corner_radius_all(8)
	selection_surface.set_content_margin_all(10)
	_sel_panel.add_theme_stylebox_override("panel", selection_surface)
	_sel_panel.custom_minimum_size = Vector2(SELECTION_PANEL_WIDTH, SELECTION_PANEL_HEIGHT)
	_sel_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_sel_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	# center it: anchor middle-bottom
	_sel_panel.anchor_left = 0.5
	_sel_panel.anchor_right = 0.5
	_sel_panel.anchor_top = 1.0
	_sel_panel.anchor_bottom = 1.0
	_sel_panel.offset_left = -SELECTION_PANEL_WIDTH * 0.5
	_sel_panel.offset_right = SELECTION_PANEL_WIDTH * 0.5
	_sel_panel.offset_top = -SELECTION_PANEL_HEIGHT - 12.0
	_sel_panel.offset_bottom = -12
	add_child(_sel_panel)

	# The entity module shares the command deck's visual rhythm: a compact
	# identity rail owns the header while the live body owns only the authored
	# portrait/vitals content. This removes the previous unlabelled black void
	# without adding filler data or changing selection semantics.
	var entity_stack := VBoxContainer.new()
	entity_stack.add_theme_constant_override("separation", 4)
	entity_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_panel.add_child(entity_stack)
	var entity_header := HBoxContainer.new()
	entity_header.custom_minimum_size = Vector2(0, 22)
	entity_header.add_theme_constant_override("separation", 7)
	entity_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var entity_rule := ColorRect.new()
	entity_rule.custom_minimum_size = Vector2(4, 18)
	entity_rule.color = COMMAND_GOLD
	entity_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entity_header.add_child(entity_rule)
	var entity_title := _mk_label("SELECTED ENTITY", 11, COMMAND_GOLD)
	entity_title.custom_minimum_size = Vector2(132, 20)
	entity_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	entity_header.add_child(entity_title)
	var entity_hint := _mk_label("IDENTITY · VITALS", 9, HUD_TEXT_MUTED)
	entity_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entity_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	entity_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	entity_header.add_child(entity_hint)
	entity_stack.add_child(entity_header)
	_sel_body = Control.new()
	_sel_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sel_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sel_body.custom_minimum_size = Vector2(0, 1)
	_sel_body.clip_contents = true
	entity_stack.add_child(_sel_body)
	_sel_panel.visible = false


func _clear_children(node: Node) -> void:
	if not is_instance_valid(node):
		return
	for c in node.get_children():
		c.queue_free()


func _reset_selection_widgets() -> void:
	_tracked_single = null
	_single_read_only = false
	_single_hp_bar = null
	_single_hp_text = null
	_single_mana_bar = null
	_single_mana_text = null
	_single_stat_label = null
	_single_stat_cards.clear()
	_single_activity_label = null
	_single_target_label = null
	_single_economy_label = null
	_ability_widgets.clear()
	_multi_bars.clear()
	_queue_container = null
	_production_status_label = null
	_production_card_queue_key = ""
	if is_instance_valid(_watched_building) and _watched_building.production_updated.is_connected(_on_production_updated):
		_watched_building.production_updated.disconnect(_on_production_updated)
	_watched_building = null
	if is_instance_valid(_watched_construction_building) and _watched_construction_building.construction_completed.is_connected(_on_tracked_building_construction_completed):
		_watched_construction_building.construction_completed.disconnect(_on_tracked_building_construction_completed)
	_watched_construction_building = null


func _on_selection_changed(units: Array) -> void:
	# Hostile inspection is a read-only presentation state. A late selection
	# refresh must not rebuild the player's actionable command card over it.
	if is_instance_valid(_inspection_target):
		return
	_rebuild_selection(units)


func _on_inspection_changed(target) -> void:
	_inspection_target = target
	if is_instance_valid(target):
		_rebuild_inspection(target)
	else:
		_rebuild_selection([])


func _on_tracked_building_construction_completed(building) -> void:
	# The building's model and world transaction complete before the next HUD
	# selection event. Refresh this selected card immediately so a completed
	# building cannot retain a stale construction panel or progress copy.
	if building != _tracked_single or _single_read_only or not is_instance_valid(rts):
		return
	_rebuild_selection(rts.selected)


func _rebuild_selection(sel: Array) -> void:
	_reset_selection_widgets()
	_clear_children(_sel_body)
	if is_instance_valid(_sel_panel):
		_sel_panel.remove_meta("multi_selection_height")

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
			_build_single_building(one, false)
		else:
			_build_single_unit(one, false)
		_rebuild_command_card(one, valid)
	else:
		# RTS selection can legitimately contain a mixed unit/building set while
		# the player switches context with additive selection. The formation
		# renderer is intentionally unit-only; normalize at this HUD boundary
		# instead of dereferencing unit fields on a Building or changing the
		# controller's authoritative selection semantics.
		var selected_units: Array = []
		var selected_buildings: Array = []
		for item in valid:
			if item is Unit:
				selected_units.append(item)
			elif item is Building:
				selected_buildings.append(item)
		if not selected_units.is_empty():
			_build_multi(selected_units)
		elif not selected_buildings.is_empty():
			_build_single_building(selected_buildings[0], false)
		_rebuild_command_card(null, valid)


func _rebuild_inspection(target) -> void:
	_reset_selection_widgets()
	_clear_children(_sel_body)
	if not is_instance_valid(target):
		_sel_panel.visible = false
		_rebuild_command_card(null, [])
		return
	_sel_panel.visible = true
	if target is Building:
		_build_single_building(target, true)
	else:
		_build_single_unit(target, true)
	# Inspected enemies are never passed to the player command-card builders.
	_rebuild_command_card(null, [])


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


func _build_single_unit(u, read_only: bool = false) -> void:
	_tracked_single = u
	_single_read_only = read_only
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.add_child(row)

	# Actual authored model preview, isolated from the live gameplay node.
	var portrait: Control
	if ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
		portrait = load(ENTITY_PORTRAIT_SCRIPT).new()
		portrait.custom_minimum_size = Vector2(116, 116)
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
	var identity_color := Color(1.0, 0.55, 0.45) if read_only else Color(0.95, 0.85, 0.55)
	var role_label := "HERO" if u.is_hero else ("WORKER" if u.is_worker else "MILITARY")
	var role_accent := Color(1.0, 0.55, 0.45) if read_only else (COMMAND_SKY if u.is_hero else (COMMAND_MINT if u.is_worker else COMMAND_FLAME))
	var identity_header := HBoxContainer.new()
	identity_header.add_theme_constant_override("separation", 6)
	identity_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var identity_name := _mk_label(("HOSTILE · " if read_only else "") + uname, 18, identity_color)
	identity_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity_header.add_child(identity_name)
	identity_header.add_child(_mk_command_badge(role_label, role_accent, 62.0))
	info.add_child(identity_header)
	info.add_child(_mk_label("VITALS", 9, Color(0.62, 0.67, 0.65)))

	# hp bar + text
	_single_hp_bar = _mk_bar(Color(0.35, 0.8, 0.35))
	info.add_child(_single_hp_bar)
	_single_hp_text = _mk_label("", 15)
	info.add_child(_single_hp_text)

	if not read_only and u.is_hero and u.max_mana > 0.0:
		var mana_header := HBoxContainer.new()
		mana_header.add_theme_constant_override("separation", 6)
		mana_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mana_header.add_child(_mk_label("MANA", 9, COMMAND_SKY))
		_single_mana_text = _mk_label("", 11, Color(0.78, 0.86, 1.0))
		_single_mana_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mana_header.add_child(_single_mana_text)
		info.add_child(mana_header)
		_single_mana_bar = _mk_bar(Color(0.35, 0.55, 0.95))
		info.add_child(_single_mana_bar)

	if not read_only and not u.is_worker and u.has_method("cur_dmg"):
		var stat_row := HBoxContainer.new()
		stat_row.add_theme_constant_override("separation", 4)
		stat_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_add_stat_chip(stat_row, "DMG", _compact_combat_stat(u.cur_dmg()), "dmg", role_accent)
		_add_stat_chip(stat_row, "ARM", _compact_combat_stat(u.cur_armor()), "armor", role_accent)
		_add_stat_chip(stat_row, "RNG", "%.1f" % u.cur_range(), "range", role_accent)
		info.add_child(stat_row)

	if not read_only and u.is_worker and u.has_method("get_economy_snapshot"):
		info.add_theme_constant_override("separation", 0)
		_single_economy_label = _mk_label("", 14, Color(0.78, 0.9, 0.72))
		_single_economy_label.custom_minimum_size = Vector2(0, 18)
		_single_economy_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		_single_economy_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_single_economy_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		_single_economy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(_single_economy_label)

	if read_only:
		_single_stat_label = _mk_label("", 12, Color(0.88, 0.85, 0.75))
		info.add_child(_single_stat_label)
	if not read_only:
		_single_activity_label = _mk_label("", 12, Color(0.82, 0.86, 0.78))
		info.add_child(_single_activity_label)
		_single_target_label = _mk_label("", 14, Color(1.0, 0.74, 0.38))
		_single_target_label.name = "CombatTargetLabel"
		_single_target_label.custom_minimum_size = Vector2(0, 18)
		_single_target_label.visible = false
		info.add_child(_single_target_label)
	if read_only:
		var public_role := String(u.def.get("role", "unit")).capitalize()
		_single_stat_label.text = "Hostile · %s" % public_role

	_refresh_single_live()


func _ability_key_label(id: String) -> String:
	var hotkeys := {"rally": "Q", "slam": "T", "charge": "E", "bolt": "R"}
	return String(hotkeys.get(id, ""))


func _hero_unavailable_reason(u) -> String:
	if not is_instance_valid(u):
		return "UNAVAILABLE"
	if bool(u.get("is_dead")):
		return "DEAD"
	if u.has_method("_is_defeated_remnant") and u._is_defeated_remnant():
		return "DEFEATED"
	var hero_commander = u.get("commander")
	if is_instance_valid(hero_commander) and bool(hero_commander.get("defeated")):
		return "DEFEATED"
	return ""


func _refresh_single_live() -> void:
	var u = _tracked_single
	if u == null:
		return
	if not is_instance_valid(u):
		_rebuild_selection([])
		return
	if (u is Building and u.is_dead) or (u is Unit and u.is_dead and (not u.is_hero or _single_read_only)):
		_rebuild_selection([])
		return
	if is_instance_valid(_single_activity_label) and u is Unit and not _single_read_only:
		_single_activity_label.text = "STATUS  ·  " + _unit_activity_label(u)
	var unavailable_reason := _hero_unavailable_reason(u) if u is Unit and u.is_hero else ""
	if not unavailable_reason.is_empty():
		for w in _ability_widgets:
			var unavailable_button: Button = w["button"]
			var unavailable_overlay: Label = w["overlay"]
			if is_instance_valid(unavailable_button):
				unavailable_button.disabled = true
			if is_instance_valid(unavailable_overlay):
				unavailable_overlay.text = unavailable_reason
		return
	if is_instance_valid(_single_hp_bar):
		_single_hp_bar.value = clamp(u.get_hp_ratio(), 0.0, 1.0)
	if is_instance_valid(_single_hp_text):
		_single_hp_text.text = "HP %d / %d" % [int(max(0.0, u.hp)), int(u.max_hp)]
	if is_instance_valid(_single_mana_bar) and "max_mana" in u and u.max_mana > 0.0:
		_single_mana_bar.value = clamp(u.mana / u.max_mana, 0.0, 1.0)
	if is_instance_valid(_single_mana_text) and "max_mana" in u:
		_single_mana_text.text = "%d / %d" % [int(maxf(0.0, u.mana)), int(maxf(0.0, u.max_mana))]
	if u is Unit and not _single_stat_cards.is_empty() and u.has_method("cur_dmg"):
		for stat in _single_stat_cards:
			var stat_label: Label = stat["label"]
			if not is_instance_valid(stat_label):
				continue
			var stat_value := ""
			match String(stat["kind"]):
				"dmg": stat_value = _compact_combat_stat(u.cur_dmg())
				"armor": stat_value = _compact_combat_stat(u.cur_armor())
				"range": stat_value = "%.1f" % u.cur_range()
			stat_label.text = "%s  %s" % [stat["caption"], stat_value]
			stat_label.tooltip_text = "%s: %s" % [stat["caption"], stat_value]
	if is_instance_valid(_single_stat_label):
		if _single_read_only:
			pass
		elif u is Building:
			pass
		elif u.has_method("cur_dmg"):
			var role: String = u.def.get("role", "")
			_single_stat_label.text = "DMG %s   ARM %s   RNG %.1f   %s" % [
				_compact_combat_stat(u.cur_dmg()), _compact_combat_stat(u.cur_armor()), u.cur_range(), role.capitalize()]
	if is_instance_valid(_single_target_label):
		var target = u.get("_target") if u is Unit else null
		var target_valid: bool = u is Unit and not _single_read_only and int(u.state) == Unit.State.ATTACKING \
			and is_instance_valid(target) and not target.is_dead and int(target.team) != int(u.team)
		_single_target_label.visible = target_valid
		_single_target_label.text = "Target: %s  ·  HP %d/%d" % [
			String(target.def.get("name", "Unit")), int(ceil(target.hp)), int(ceil(target.max_hp))] if target_valid else ""
	if is_instance_valid(_single_economy_label) and u.has_method("get_economy_snapshot"):
		_single_economy_label.text = _worker_cargo_text(u)
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
				overlay.text = "CD %d" % int(ceil(cd))
		else:
			btn.disabled = not mana_ok
			if is_instance_valid(overlay):
				overlay.text = "READY" if mana_ok else "MANA"


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
			label = label.trim_prefix("Stoneward ")
		if not counts.has(label):
			counts[label] = 0
			order.append(label)
		counts[label] = int(counts[label]) + 1
	var parts: Array[String] = []
	for label in order:
		parts.append("%s x%d" % [label, int(counts[label])])
	return " · ".join(parts)


func _compact_combat_stat(value: float) -> String:
	var rounded := round(value)
	return str(int(rounded)) if is_equal_approx(value, rounded) else "%.1f" % value


func _build_multi(units: Array) -> void:
	var displayed_count := mini(units.size(), 24)
	var row_count := ceili(float(displayed_count) / 6.0)
	# Keep the existing six-column card layout, but let dense selections grow
	# their anchored panel enough to show the complete 3–4 row composition.
	if is_instance_valid(_sel_panel) and row_count > 2:
		_sel_panel.set_meta("multi_selection_height", 52.0 + float(row_count) * 72.0)
		_fit_to_viewport()
	var formation_header := PanelContainer.new()
	formation_header.custom_minimum_size = Vector2(0, 42)
	formation_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var formation_style := StyleBoxFlat.new()
	formation_style.bg_color = Color(0.1, 0.075, 0.065, 0.98)
	formation_style.border_color = Color(COMMAND_FLAME.r, COMMAND_FLAME.g, COMMAND_FLAME.b, 0.72)
	formation_style.set_border_width_all(1)
	formation_style.set_corner_radius_all(6)
	formation_style.set_content_margin_all(6)
	formation_header.add_theme_stylebox_override("panel", formation_style)
	var formation_row := HBoxContainer.new()
	formation_row.add_theme_constant_override("separation", 7)
	formation_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	formation_row.add_child(_mk_command_badge("FORMATION", COMMAND_FLAME, 78.0))
	var formation_info := VBoxContainer.new()
	formation_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	formation_info.add_theme_constant_override("separation", 0)
	formation_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	formation_info.add_child(_mk_label("%d UNITS SELECTED" % units.size(), 13, FONT_COLOR))
	formation_info.add_child(_mk_label(_selection_type_summary(units), 9, Color(0.76, 0.79, 0.75)))
	formation_row.add_child(formation_info)
	formation_header.add_child(formation_row)
	_sel_body.add_child(formation_header)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 46
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
			# EntityPortraitView restores its full-card minimum during _ready();
			# defer the compact override so 8–20 member groups keep both rows
			# inside the fixed selection panel at narrow and wide viewports.
			portrait.set_deferred("custom_minimum_size", Vector2(54, 46))
			portrait.set_deferred("size", Vector2(54, 46))
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


func _build_single_building(b, read_only: bool = false) -> void:
	_tracked_single = b
	_single_read_only = read_only
	if not read_only and b.has_signal("construction_completed"):
		b.construction_completed.connect(_on_tracked_building_construction_completed)
		_watched_construction_building = b
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
		portrait.custom_minimum_size = Vector2(100, 100)
		identity.add_child(portrait)
		portrait.configure_entity(b)
	else:
		portrait = _mk_icon(FRAME_PORTRAIT, 76)
		identity.add_child(portrait)
	var identity_info := VBoxContainer.new()
	identity_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity.add_child(identity_info)
	var identity_color := Color(1.0, 0.55, 0.45) if read_only else Color(0.95, 0.85, 0.55)
	var identity_text := ("HOSTILE · " if read_only else "") + String(b.def.get("name", "Building"))
	var building_header := HBoxContainer.new()
	building_header.add_theme_constant_override("separation", 6)
	building_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var building_name := _mk_label(identity_text, 18, identity_color)
	building_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	building_header.add_child(building_name)
	building_header.add_child(_mk_command_badge("BUILDING", Color(0.93, 0.72, 0.32) if not read_only else Color(1.0, 0.55, 0.45), 70.0))
	identity_info.add_child(building_header)
	identity_info.add_child(_mk_label("VITALS", 9, Color(0.62, 0.67, 0.65)))
	_single_hp_bar = _mk_bar(Color(0.35, 0.8, 0.35))
	identity_info.add_child(_single_hp_bar)
	_single_hp_text = _mk_label("", 15)
	identity_info.add_child(_single_hp_text)
	if not read_only:
		_single_activity_label = _mk_label("STATUS  ·  " + ("Built" if b.is_built else "Under Construction"), 12, Color(0.82, 0.86, 0.78))
		identity_info.add_child(_single_activity_label)
	if read_only:
		_single_stat_label = _mk_label("Hostile · Built structure", 15, Color(0.88, 0.85, 0.75))
		identity_info.add_child(_single_stat_label)

	if not read_only and not b.is_built:
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
	if not read_only and (not b.def.get("produces", []).is_empty() or not b.def.get("research", []).is_empty() \
			or b.def.get("is_hq", false) or b.def.get("kind", "") == "main"):
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
		_production_status_label = _mk_label("Idle", 11, Color(0.95, 0.82, 0.42))
		_production_status_label.custom_minimum_size = Vector2(108, 20)
		_production_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		queue_row.add_child(_production_status_label)
		queue_row.add_child(_queue_container)
		identity_info.add_child(queue_row)
		# watch production updates
		if b.production_updated.is_connected(_on_production_updated):
			b.production_updated.disconnect(_on_production_updated)
		b.production_updated.connect(_on_production_updated)
		_watched_building = b
		_refresh_queue()

	_refresh_single_live()


func _unit_activity_label(u) -> String:
	if not is_instance_valid(u) or u.is_dead:
		return "Dead"
	if u.has_method("_is_defeated_remnant") and u._is_defeated_remnant():
		return "Defeated"
	match int(u.state):
		Unit.State.MOVING:
			return "Moving"
		Unit.State.ATTACK_MOVE:
			return "Attack-Moving"
		Unit.State.ATTACKING:
			return "Attacking"
		Unit.State.GATHERING:
			var resource_kind := String(u.get("_desired_gather_kind")).capitalize()
			return "Gathering %s" % resource_kind if not resource_kind.is_empty() else "Gathering"
		Unit.State.RETURNING:
			return "Returning Resources"
		Unit.State.BUILDING:
			return "Repairing" if bool(u.get("_repair_target")) else "Building"
		Unit.State.HOLD:
			return "Holding Position"
		Unit.State.PATROL:
			return "Patrolling"
		Unit.State.FOLLOW:
			return "Guarding"
		_:
			return "Idle"


func _worker_cargo_text(u) -> String:
	# Read the live Worker economy snapshot; HUD owns only the player-facing
	# wording and never maintains a parallel cargo value.
	if not is_instance_valid(u) or not u.has_method("get_economy_snapshot"):
		return "Cargo: Empty"
	var snapshot: Dictionary = u.get_economy_snapshot()
	var carried := int(snapshot.get("carry", 0))
	if carried <= 0:
		return "Cargo: Empty"
	var kind := String(snapshot.get("carry_kind", "")).strip_edges()
	if kind.is_empty() or kind == "None":
		return "Cargo: %d" % carried
	return "Cargo: %d %s" % [carried, kind]


func _on_production_updated() -> void:
	_refresh_queue()
	var queue_key := ""
	if is_instance_valid(_watched_building):
		for item in _watched_building.queue:
			queue_key += "%s:%s|" % [String(item.get("kind", "unit")), String(item.get("id", ""))]
	if queue_key != _production_card_queue_key:
		_production_card_queue_key = queue_key
		if is_instance_valid(_watched_building):
			_rebuild_command_card(_watched_building, [_watched_building])
		return
	# A completed research item changes the selected producer's command-card
	# truth even though the queue refresh above is sufficient for its status row.
	# Rebuild only on the terminal transition so the card exposes the completed
	# technology without changing research or production semantics.
	if is_instance_valid(_watched_building) and (not _watched_building.def.get("research", []).is_empty() or bool(_watched_building.def.get("is_hq", false))):
		_rebuild_command_card(_watched_building, [_watched_building])


func _queue_slot_label(display_name: String) -> String:
	# The full entity name remains in the tooltip; use the distinctive final
	# name token in the compact slot so players can recognize the queue at a
	# glance instead of decoding two ambiguous initials.
	var words := display_name.strip_edges().split(" ", false)
	if words.is_empty():
		return display_name
	return String(words[words.size() - 1])


func _refresh_queue() -> void:
	if not is_instance_valid(_queue_container) or not is_instance_valid(_production_status_label):
		return
	_clear_children(_queue_container)
	var b = _watched_building
	if not is_instance_valid(b):
		return
	if b.queue.is_empty():
		_production_status_label.text = "Idle"
		return
	var active = b.queue[0]
	var active_kind: String = active.get("kind", "unit")
	var active_id: String = active.get("id", "")
	var active_name := ""
	if active_kind == "unit":
		active_name = GameData.get_unit(active_id).get("name", active_id)
	else:
		active_name = GameData.get_tech(active_id).get("name", active_id)
	var active_display := _queue_slot_label(active_name)
	var active_total: float = float(active.get("total", 1.0))
	var active_left: float = float(active.get("time_left", 0.0))
	var active_prog := clampf(1.0 - active_left / maxf(0.01, active_total), 0.0, 1.0)
	var active_verb := "Training" if active_kind == "unit" else "Researching"
	_production_status_label.text = "%s: %s %d%%" % [active_verb, active_display, roundi(active_prog * 100.0)]
	var idx := 0
	for item in b.queue:
		var slot := _mk_button("", 12)
		slot.custom_minimum_size = Vector2(48, 28)
		slot.add_theme_font_size_override("font_size", 10)
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
		# Queue slots have an explicit compact size. Keep the progress bar on a
		# fixed top-left anchor so the authored offsets remain authoritative and
		# Godot does not repeatedly warn about conflicting opposite anchors while
		# production_updated rebuilds the queue row.
		pbar.set_anchors_preset(Control.PRESET_TOP_LEFT)
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
	var command_surface := _hud_stylebox()
	command_surface.bg_color = Color(0.035, 0.048, 0.062, 0.985)
	command_surface.border_color = Color(0.82, 0.65, 0.30, 0.96)
	command_surface.set_corner_radius_all(8)
	command_surface.set_content_margin_all(10)
	_cmd_panel.add_theme_stylebox_override("panel", command_surface)
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
	scroll.gui_input.connect(_consume_hud_wheel)

	_cmd_body = VBoxContainer.new()
	_cmd_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cmd_body.add_theme_constant_override("separation", 6)
	scroll.add_child(_cmd_body)
	_cmd_panel.visible = false

	_command_tooltip = PanelContainer.new()
	_command_tooltip.name = "CommandTooltip"
	_command_tooltip.visible = false
	_command_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_command_tooltip.custom_minimum_size = Vector2(270, 0)
	var tooltip_style := _hud_stylebox()
	tooltip_style.bg_color = Color(0.035, 0.045, 0.06, 0.985)
	tooltip_style.border_color = Color(0.88, 0.72, 0.36, 0.98)
	tooltip_style.set_border_width_all(2)
	tooltip_style.set_corner_radius_all(7)
	tooltip_style.set_content_margin_all(10)
	_command_tooltip.add_theme_stylebox_override("panel", tooltip_style)
	add_child(_command_tooltip)


func _consume_hud_wheel(event: InputEvent) -> void:
	# Scrollable HUD surfaces must terminate wheel input before the world
	# controller's _unhandled_input can interpret it as camera zoom. This is
	# event-driven and preserves the camera's existing behavior elsewhere.
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT, MOUSE_BUTTON_WHEEL_RIGHT]:
		get_viewport().set_input_as_handled()


func _show_command_tooltip(title: String, kind: String, hotkey: String, tooltip: String, disabled_reason: String, accent: Color) -> void:
	if not is_instance_valid(_command_tooltip) or not is_instance_valid(_cmd_panel):
		return
	_clear_children(_command_tooltip)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 5)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 7)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tooltip_title := _mk_label(title, 13, FONT_COLOR)
	tooltip_title.custom_minimum_size = Vector2(124, 20)
	tooltip_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(tooltip_title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	header.add_child(_mk_command_badge(kind, accent, 64.0))
	if not hotkey.is_empty():
		header.add_child(_mk_command_keycap(hotkey, accent))
	stack.add_child(header)
	var rule := HSeparator.new()
	rule.modulate = Color(accent.r, accent.g, accent.b, 0.72)
	stack.add_child(rule)
	var body_text := tooltip.strip_edges()
	if not disabled_reason.is_empty():
		body_text += "\nUnavailable: " + disabled_reason
	var body := _mk_label(body_text, 12, Color(0.88, 0.87, 0.8))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	body.custom_minimum_size = Vector2(244, 0)
	stack.add_child(body)
	_command_tooltip.add_child(stack)
	_command_tooltip.reset_size()
	var deck_rect := _cmd_panel.get_global_rect()
	var viewport_size := get_viewport_rect().size
	var tooltip_size := _command_tooltip.size
	var tooltip_pos := Vector2(deck_rect.position.x + 8.0, deck_rect.position.y - tooltip_size.y - 10.0)
	if tooltip_pos.y < 8.0:
		tooltip_pos.y = deck_rect.end.y + 8.0
	_command_tooltip.position = Vector2(
		clampf(tooltip_pos.x, 8.0, maxf(8.0, viewport_size.x - tooltip_size.x - 8.0)),
		clampf(tooltip_pos.y, 8.0, maxf(8.0, viewport_size.y - tooltip_size.y - 8.0)))
	_command_tooltip.visible = true


func _hide_command_tooltip() -> void:
	if is_instance_valid(_command_tooltip):
		_command_tooltip.visible = false


func _rebuild_command_card(single, selection: Array) -> void:
	_hide_command_tooltip()
	_clear_children(_cmd_body)
	if is_instance_valid(_inspection_target):
		_cmd_panel.visible = false
		return
	if not is_instance_valid(_commander):
		_cmd_panel.visible = false
		return
	_add_command_context(single, selection)

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

	# HERO -> abilities first, then the same combat orders used by military units.
	# Keeping this in the command deck makes the authored Q/W actions visible at
	# the moment the player selects the hero instead of burying them below the
	# selection portrait's fixed-height information surface.
	if single != null and single is Unit and single.is_hero:
		_build_hero_command_card(single)
		_cmd_panel.visible = _cmd_body.get_child_count() > 0
		return

	var has_military := false
	for item in selection:
		if item is Unit and not item.is_worker and not item.is_dead and not item._is_defeated_remnant():
			has_military = true
			break
	if has_military:
		_build_military_card()
		_cmd_panel.visible = _cmd_body.get_child_count() > 0
		return

	_cmd_panel.visible = false


func _add_command_context(single, selection: Array) -> void:
	var title := "COMMAND DECK"
	var subtitle := "Select a unit to issue orders."
	var role := "READY"
	var accent := COMMAND_GOLD
	if single != null and single is Unit:
		title = String(single.def.get("name", "Unit"))
		role = "HERO" if single.is_hero else ("WORKER" if single.is_worker else "MILITARY")
		subtitle = "Player orders · %s" % role.capitalize()
		accent = COMMAND_SKY if single.is_hero else (COMMAND_MINT if single.is_worker else COMMAND_FLAME)
	elif single != null and single is Building:
		title = String(single.def.get("name", "Building"))
		role = "BUILDING"
		subtitle = "Production and research"
		accent = COMMAND_GOLD
	elif not selection.is_empty():
		title = "%d UNITS SELECTED" % selection.size()
		role = "FORMATION"
		subtitle = "Shared combat orders"
		accent = COMMAND_FLAME
	var header := PanelContainer.new()
	header.name = "CommandDeckHeader"
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.custom_minimum_size = Vector2(0, 58)
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = Color(0.06, 0.078, 0.094, 0.98)
	header_style.border_color = Color(accent.r, accent.g, accent.b, 0.76)
	header_style.border_width_left = 3
	header_style.border_width_bottom = 1
	header_style.set_corner_radius_all(4)
	header_style.set_content_margin_all(8)
	header.add_theme_stylebox_override("panel", header_style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var marker := _mk_command_badge(_command_glyph(role), accent, 34.0)
	marker.custom_minimum_size = Vector2(34, 34)
	row.add_child(marker)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 0)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(_mk_label(title, 15, FONT_COLOR))
	info.add_child(_mk_label(subtitle, 10, Color(0.7, 0.73, 0.72)))
	row.add_child(info)
	var role_badge := _mk_command_badge(role, accent, 62.0)
	role_badge.custom_minimum_size = Vector2(62, 22)
	row.add_child(role_badge)
	header.add_child(row)
	_cmd_body.add_child(header)


func _add_context_hints(hints: Array[String]) -> void:
	var strip := PanelContainer.new()
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.custom_minimum_size = Vector2(0, 28)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.04, 0.05, 0.72)
	sb.border_color = Color(0.34, 0.4, 0.4, 0.46)
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(2)
	sb.set_content_margin_all(4)
	strip.add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for hint in hints:
		var label := _mk_label(hint, 9, Color(0.78, 0.84, 0.8))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(label)
	strip.add_child(row)
	_cmd_body.add_child(strip)


func _build_worker_card() -> void:
	_add_context_hints(["RMB  MOVE", "RMB  GATHER", "CLICK  BUILD", "ESC  CANCEL BUILD"])
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
		var build_detail := _cost_string(cost).trim_prefix("  (").trim_suffix(")")
		# Keep the scan line to the actionable cost only. Population benefit and
		# the full authored explanation remain available in the anchored tooltip;
		# this prevents the narrow two-column cards from truncating secondary text.
		var tooltip_detail := str(bdef.get("desc", ""))
		var grants_pop := int(bdef.get("grants_pop", 0))
		if grants_pop > 0:
			tooltip_detail += "\nProvides: +%d population" % grants_pop
		var btn := _mk_command_button(str(bdef.get("name", bid)), build_detail, tooltip_detail, reason, "LOCKED" if not affordable else "READY", bdef, tooltip_detail, "Purpose")
		btn.disabled = not affordable
		var cap_id := String(bid)
		btn.pressed.connect(func():
			if is_instance_valid(rts) and rts.has_method("enter_build_mode"):
				rts.enter_build_mode(cap_id))
		grid.add_child(btn)


func _build_hero_command_card(u) -> void:
	_add_context_hints(["RMB  MOVE", "Q / W  ABILITIES", "A  ATTACK-MOVE"])
	if not u.abilities.is_empty():
		_add_command_section("Abilities", "Cast when ready.")
		var ability_grid := _mk_command_grid()
		_cmd_body.add_child(ability_grid)
		var abilities: Dictionary = SkillDefs.get_abilities()
		for id in u.abilities:
			var cap_id := String(id)
			var ab: Dictionary = abilities.get(cap_id, {})
			if ab.is_empty():
				continue
			var key_label := _ability_key_label(cap_id)
			var mana_cost := int(ab.get("mana", 0))
			var cooldown := float(ab.get("cd", 0.0))
			var remaining := float(u.ability_cd.get(cap_id, 0.0)) if "ability_cd" in u else 0.0
			var mana_ready: bool = "mana" in u and u.mana >= mana_cost
			var ready: bool = remaining <= 0.05 and mana_ready
			var state := "READY" if ready else ("COOLDOWN" if remaining > 0.05 else "LOCKED")
			var reason := "Cooldown: %.1fs remaining" % remaining if remaining > 0.05 else ("Need %d mana" % mana_cost if not mana_ready else "")
			var detail := "%d mana  ·  %.0fs cooldown\n%s" % [mana_cost, cooldown, String(ab.get("desc", ""))]
			var btn := _mk_command_button(String(ab.get("name", cap_id)), detail, "%s\n%s\nMana: %d\nCooldown: %.1fs" % [ab.get("name", cap_id), ab.get("desc", ""), mana_cost, cooldown], reason, state, {}, "", "Effect", key_label)
			btn.disabled = not ready
			var cap_u = u
			btn.pressed.connect(func():
				if is_instance_valid(cap_u) and not cap_u.is_dead and cap_u.has_method("cast_ability"):
					cap_u.cast_ability(cap_id, cap_u.global_position))
			ability_grid.add_child(btn)
			var status_label: Label = btn.get_meta("command_status_label")
			_ability_widgets.append({"id": cap_id, "button": btn, "overlay": status_label})

	_add_command_section("Orders", "Shared combat commands.")
	var order_grid := _mk_command_grid()
	_cmd_body.add_child(order_grid)
	_add_military_command_button(order_grid, "Attack Move", "Move and engage enemies encountered.", "Attack Move: choose a destination and engage enemies encountered.", "attack_move")
	_add_military_command_button(order_grid, "Stop", "Stop current orders.", "Stop: clear the selected hero's current orders.", "stop")
	_add_military_command_button(order_grid, "Hold", "Hold this position.", "Hold: keep the selected hero here while retaining current combat behavior.", "hold")
	_add_military_command_button(order_grid, "Patrol", "Move between chosen points.", "Patrol: choose a destination to begin the existing patrol behavior.", "patrol")


func _build_military_card() -> void:
	_add_context_hints(["RMB  MOVE", "RMB  ATTACK", "A  ATTACK-MOVE"])
	_add_command_section("Commands", "Orders for selected combat units.")
	var grid := _mk_command_grid()
	_cmd_body.add_child(grid)
	_add_military_command_button(grid, "Attack Move", "Move and engage enemies encountered.", "Attack Move: choose a destination and engage enemies encountered.", "attack_move")
	_add_military_command_button(grid, "Stop", "Stop current orders.", "Stop: clear the selected units' current orders.", "stop")
	_add_military_command_button(grid, "Hold", "Hold this position.", "Hold: keep the selected units here while retaining their current combat behavior.", "hold")
	_add_military_command_button(grid, "Patrol", "Move between chosen points.", "Patrol: choose a destination to begin the existing patrol behavior.", "patrol")


func _add_military_command_button(grid: GridContainer, title: String, detail: String, tooltip: String, action: String) -> void:
	var state := "ACTIVE" if (action == "attack_move" and bool(rts.get("_attack_move_mode"))) or (action == "patrol" and bool(rts.get("_patrol_mode"))) else "READY"
	var btn := _mk_command_button(title, detail, tooltip, "", state)
	btn.pressed.connect(func(): _invoke_military_command(action))
	grid.add_child(btn)


func _invoke_military_command(action: String) -> void:
	if not is_instance_valid(rts):
		return
	match action:
		"attack_move":
			if rts.has_method("_begin_attack_move"):
				rts._begin_attack_move()
		"stop":
			if rts.has_method("issue_stop"):
				rts.issue_stop()
		"hold":
			if rts.has_method("issue_hold"):
				rts.issue_hold()
		"patrol":
			if rts.has_method("_cmd_patrol_prompt"):
				rts._cmd_patrol_prompt()


func _build_building_card(b) -> void:
	_add_context_hints(["RMB  RALLY", "CLICK  TRAIN / RESEARCH"])
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
			var queued_for_training := false
			for queued_item in b.queue:
				if queued_item.get("kind", "unit") == "unit" and String(queued_item.get("id", "")) == String(uid):
					queued_for_training = true
					break
			var cost: Dictionary = udef.get("cost", {})
			var tier := int(udef.get("tier", 1))
			var affordable: bool = _commander.can_afford(cost)
			var housed: bool = _commander.has_pop_for(udef)
			var reason: String = ""
			if queued_for_training:
				reason = "Already training"
			elif tier > _commander.tier:
				reason = "Requires Age %d" % tier
			elif not housed:
				reason = "Need more housing"
			elif not affordable:
				reason = _commander.missing_resource_summary(cost)
			var train_detail := "Tier %d | Population: %d | Cost: %s" % [tier, int(udef.get("pop", 1)), _cost_string(cost).trim_prefix("  (").trim_suffix(")")]
			var train_state := "TRAINING" if queued_for_training else ("LOCKED" if not reason.is_empty() else "READY")
			var btn := _mk_command_button(str(udef.get("name", uid)), train_detail, str(udef.get("desc", "")), reason, train_state, {}, str(udef.get("desc", "")), "Role")
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
			var reason := ""
			if not available:
				if _commander.completed_tech.has(tid):
					reason = "Completed"
				elif _commander.researching.has(tid):
					reason = "Researching"
				elif tdef.get("kind", "") == "tier":
					var required_tier := int(tdef.get("tier", 2)) - 1
					var required_age := GameData.get_tech("advance_tier_%d" % required_tier)
					var required_age_name := String(required_age.get("name", "Age %d" % required_tier))
					required_age_name = required_age_name.trim_prefix("Advance to ")
					reason = "Requires %s" % required_age_name
				else:
					reason = "Already researched or unavailable"
			elif not affordable:
				reason = _commander.missing_resource_summary(cost)
			var ready_to_research: bool = available and affordable
			var research_state := "COMPLETED" if _commander.completed_tech.has(tid) else ("LOCKED" if not ready_to_research else "READY")
			var btn := _mk_command_button(str(tdef.get("name", tid)), "Cost: " + _cost_string(cost).trim_prefix("  (").trim_suffix(")"), str(tdef.get("desc", "")), reason, research_state, {}, str(tdef.get("desc", "")))
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
		_rebuild_command_card(b, [b])
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
	if intent == "CONTROL_GROUP":
		var slot := int(feedback.get("group_slot", 0))
		var member_count := int(feedback.get("member_count", 0))
		var unit_word := "unit" if member_count == 1 else "units"
		var action := "set" if String(feedback.get("feedback_type", "")) == "SET" else "selected"
		_show_command_feedback("Group %d %s · %d %s" % [slot, action, member_count, unit_word], Color(0.65, 0.9, 1.0))
		return
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
	if intent == "BUILD_OR_REPAIR" and accepted and String(feedback.get("feedback_type", "")) == "BUILD PLACEMENT":
		message = "Build placement confirmed"
	if intent == "BUILD_OR_REPAIR" and String(feedback.get("feedback_type", "")) == "REPAIR":
		message = "Repair order"
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
	_command_feedback_box.custom_minimum_size = Vector2(292, 38)
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
	# Keep transient order feedback in the clear visual band above the bottom
	# interaction modules instead of covering the selected-entity card.
	_command_feedback_box.offset_top = -292
	_command_feedback_box.offset_bottom = -256
	add_child(_command_feedback_box)
	var label := _mk_label(message, 16, col)
	label.custom_minimum_size = Vector2(270, 20)
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
	_refresh_opponent_count()
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
	l.custom_minimum_size = Vector2(340, 24)
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
