extends Control
## In-battle HUD for Ascendant Realms. Built entirely in code inside setup().
## Owns the resource top bar, minimap, selection panel, context command card,
## alert feed and the game-over screen. Reads from GameWorld / RTSController /
## Commander and connects to their signals; guards every handler against freed
## nodes because units and buildings free themselves on death.
const FACTION_SIGILS := preload("res://scripts/ui/faction_sigils.gd")
const CampaignDefs := preload("res://scripts/game/campaign_defs.gd")

signal pause_requested
signal return_to_menu
signal replay

const FONT_PATH := "res://assets/fonts/cinzel.ttf"
const THEME_PATH := "res://assets/ui/theme.tres"
const FRAME_PORTRAIT := "res://assets/ui/frame_portrait.png"
const ENTITY_PORTRAIT_SCRIPT := "res://scripts/ui/entity_portrait_view.gd"
const COMMAND_GLYPH_SCRIPT := "res://scripts/ui/command_glyph_view.gd"
const HUD_PLATE_SCRIPT := preload("res://scripts/ui/hud_plate.gd")
const HUD_TOP_METRIC_SCRIPT := preload("res://scripts/ui/hud_top_metric.gd")
const HUD_TOP_RIBBON_SCRIPT := preload("res://scripts/ui/hud_top_ribbon.gd")
## Plan 420: height of the iron band the top readings sit on.
const TOP_RIBBON_H := 58.0
const HUD_COMMAND_RACK_SCRIPT := preload("res://scripts/ui/hud_command_rack.gd")
const HUD_ALERT_DISPATCH_SCRIPT := preload("res://scripts/ui/hud_alert_dispatch.gd")
const HUD_COMMAND_TOOLTIP_SCRIPT := preload("res://scripts/ui/hud_command_tooltip.gd")
const HUD_FEEDBACK_LAYOUT := preload("res://scripts/ui/hud_feedback_layout.gd")
const HUD_CHASSIS_SCRIPT := preload("res://scripts/ui/hud_command_chassis.gd")
const HUD_ACTION_SCRIPT := preload("res://scripts/ui/hud_action_button.gd")
const HUD_CONSTRUCTION_SCRIPT := preload("res://scripts/ui/hud_construction_progress.gd")
const HUD_VITAL_BAR_SCRIPT := preload("res://scripts/ui/hud_vital_bar.gd")
const RESOURCE_OBJECT_ATLAS := preload("res://assets/ui/hud_instruments/astra_r1/resource_objects_atlas_r1.png")
const FORCE_OBJECT_ATLAS := preload("res://assets/ui/hud_instruments/astra_r1/force_objects_atlas_r2.png")
const BARROSAN_COMMAND_CREST := "res://assets/ui/barrosan_command_crest_i2.png"
const LIORAEN_COMMAND_CREST := "res://assets/ui/faction_crests/astra_r1/lioraen.png"
const VORTHAK_COMMAND_CREST := "res://assets/ui/faction_crests/astra_r1/vorthak.png"
const COMMAND_CRESTS := {
	"barrosan": BARROSAN_COMMAND_CREST,
	"lioraen": LIORAEN_COMMAND_CREST,
	"vorthak": VORTHAK_COMMAND_CREST,
}
var MAP_HALF := 140.0                  # half the battlefield; set from the map in setup()
const MINIMAP_SIZE := 252.0 # Readable survey at the compact supported resolution.
const MINIMAP_RASTER_SIZE := 160
const MINIMAP_BACKGROUND_RASTER_SIZE := 320
const MINIMAP_GROUND_TEXTURE := "res://assets/textures/nature/highland_grass.png"
const MINIMAP_MEADOW_TEXTURE := "res://assets/textures/nature/highland_meadow_grass.png"
const MINIMAP_SNOW_TEXTURE := "res://assets/textures/nature/frostmere_windswept_snow_r1.png"
const MINIMAP_PANEL_HEIGHT := MINIMAP_SIZE + 50.0
const MINIMAP_VIEW_FILL := Color(0.88, 0.93, 0.86, 0.025)
const MINIMAP_VIEW_EDGE := Color(0.96, 0.92, 0.68, 0.58)
const MINIMAP_WATER_SHORE := Color(0.64, 0.79, 0.72, 0.54)
const MINIMAP_WATER_BANK := Color(0.28, 0.43, 0.38, 0.42)
const COMMAND_PANEL_WIDTH := 430.0
const SELECTION_PANEL_WIDTH := 410.0
const SELECTION_PANEL_HEIGHT := 230.0
## The minimap, selection and command panels are drawn 1.2x at 1920 wide.
## The project lays out at 1920 and scales the whole canvas down on smaller
## windows, so at 1366x768 their 14-point text reached the eye at 11 px. On
## narrower windows the panels grow by the square root of the shrink (1.19x
## at 1366, 1.1x at 1600): text stays at 14 px or more while the panels take
## only a little more of the screen.
const PANEL_SCALE_BASE := 1.2
var _panel_scale := PANEL_SCALE_BASE
var _last_window_size := Vector2i.ZERO
## The top instruments cannot grow on a laptop window (they already span the
## screen), so their small captions grow inside them instead, by the same
## boost as the panels: [label, authored size] pairs, resized on refit.
var _top_small_text: Array = []

func _top_small(l: Label, size: int) -> Label:
	_top_small_text.append([l, size])
	return l

func _small_window_boost() -> float:
	var window_w := float(get_window().size.x) if get_window() else 1920.0
	var content_w := get_viewport_rect().size.x
	if window_w <= 0.0 or content_w <= 0.0:
		return 1.0
	return clampf(sqrt(content_w / window_w), 1.0, 1.2)
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
const GRANITBORN_BUILD_ART := {
	"karak_hold": "res://assets/ui/construction_illustrations/r54/castro_hold.png",
	"karak_longhouse": "res://assets/ui/construction_illustrations/r54/roundhouse.png",
	"karak_anvil": "res://assets/ui/construction_illustrations/r54/ledger_stone.png",
	"karak_gun_tower": "res://assets/ui/construction_illustrations/r54/castro_rampart.png",
	"karak_standing_stones": "res://assets/ui/construction_illustrations/r54/standing_stones.png",
	"karak_outpost": "res://assets/ui/construction_illustrations/r54/quarry_works.png",
	"karak_warforge": "res://assets/ui/construction_illustrations/r54/castro_forge.png",
}
const BARROSAN_BUILD_ART := {
	"barrosan_clanhold": "res://assets/ui/construction_art/astra_r1/clanhold.png",
	"barrosan_clan_croft": "res://assets/ui/construction_art/astra_r1/clan_croft.png",
	"barrosan_war_hall": "res://assets/ui/construction_art/astra_r1/war_hall.png",
	"barrosan_iron_forge": "res://assets/ui/construction_art/astra_r1/iron_forge.png",
	"barrosan_watchtower": "res://assets/ui/construction_art/astra_r1/watchtower.png",
	# Plan 461: Codex's paintings of the adopted Oven and Clan Mine models.
	"barrosan_village_oven": "res://assets/ui/construction_art/codex_fork_r1/village_oven_r2_fit.png",
	"barrosan_outpost": "res://assets/ui/construction_art/codex_fork_r1/clan_mine_r2_fit.png",
}
const LIORAEN_BUILD_ART := {
	"lioraen_groveheart": "res://assets/ui/construction_art/lioraen_r1/groveheart.png",
	"lioraen_lifewell": "res://assets/ui/construction_art/lioraen_r1/lifewell.png",
	"lioraen_thornhall": "res://assets/ui/construction_art/lioraen_r1/thornhall.png",
	"lioraen_lifewell_forge": "res://assets/ui/construction_art/lioraen_r1/grove_forge.png",
	"lioraen_spirit_glade": "res://assets/ui/construction_art/lioraen_r1/spirit_glade.png",
	"lioraen_bloom_spire": "res://assets/ui/construction_art/lioraen_r1/bloom_spire.png",
}
## The medallion reads AGE / I OF III / Bronze: the word "Age" once, the
## Age by its name, as the cards that ask for it name it.
const TIER_NAMES := {1: "Bronze", 2: "Iron", 3: "Lume"}
const TIER_COUNTS := {1: "I of III", 2: "II of III", 3: "III of III"}
const UNIT_ROLE_FOOTERS := {
	"caster": "CASTER",
	"flanker": "FLANKER",
	"ranged": "RANGED",
	"siege": "SIEGE",
}

# --- refs ---
var world = null
var rts = null
var _result_hold := 0.0
var _commander = null                  # player_commander shortcut
var _font: FontFile = null
var _body_font: Font = null

# --- top bar labels ---
var _res_labels := {}                  # kind -> Label
var _res_rate_labels := {}             # kind -> Label (income a minute)
var _pop_label: Label = null
var _opponent_count_label: Label = null
var _idle_worker_label: Label = null
var _idle_military_label: Label = null
var _tier_label: Label = null
var _tier_caption: Label = null
var _top_panel: PanelContainer = null
var _top_ribbon: Control = null
var _force_panel: PanelContainer = null
var _age_panel: PanelContainer = null
var _objective_panel: PanelContainer = null
var _menu_button: Button = null

# --- minimap ---
var _minimap: Control = null
var _minimap_background: ImageTexture = null
var _minimap_background_key := ""
var _minimap_fog: ImageTexture = null
var _minimap_fog_states := PackedByteArray()
var _minimap_fog_columns := 0
var _minimap_fog_rows := 0
var _minimap_panel: PanelContainer = null
var _faction_crest: TextureRect = null

# --- selection / command panels (rebuilt on selection change) ---
var _sel_panel: PanelContainer = null
var _sel_body: Control = null
var _sel_header_spacer: Control = null
var _selection_portrait: PanelContainer = null
var _cmd_panel: PanelContainer = null
var _cmd_fixed: VBoxContainer = null
var _cmd_scroll: ScrollContainer = null
# The command card is built once per selection, so a button locked for want of
# 20 gold stayed locked after the gold came in, until the player selected the
# worker or hall again. Every priced button is watched and the card is rebuilt
# the moment one of them changes state.
var _card_single = null
var _card_selection: Array = []
var _card_watch: Array = []        # [cost, was_available, pop_definition]
var _card_poll := 0.0
var _card_force_refresh := false
var _cmd_body: Control = null
# Presentation choices only, keyed by building definition and progression group.
# Retain booleans across native cost/queue rebuilds, never node references or saves.
var _research_expanded: Dictionary = {}
# Presentation-only HQ workspace, never persisted or holding Node references.
var _hq_workspace_choices: Dictionary = {}
var _command_chassis: Control = null
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
var _queue_slot_key := ""
var _queue_active_bar: ProgressBar = null
const QUEUE_SLOT := 31.0
var _production_status_label: Label = null
var _production_progress_bar: ProgressBar = null
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
var _resource_hover_title_id := 0
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
	add_to_group("battle_hud")
	var stage := _m20_begin("HUD_SETUP")
	world = p_world
	rts = p_rts
	if world and world.map is Dictionary:
		MAP_HALF = float(world.map.get("size", MAP_HALF))
	_commander = world.player_commander if world else null
	if is_instance_valid(_commander):
		var people := str(_commander.race)
		load("res://scripts/ui/hud_painted_rim.gd").set_people_color(people, GameData.RACES.get(people, {}).get("color", Color(0.72, 0.66, 0.52)))
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
	_build_command_chassis()
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
	call_deferred("_show_saga_title_card")


func _fit_to_viewport() -> void:
	# HUD controls are anchored to the live client viewport. Keep the authored
	# visual design at normal sizes, but derive the bottom inset from the actual
	# viewport so windowed/maximized launches cannot place controls below it.
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var margin := 14.0
	_panel_scale = PANEL_SCALE_BASE * _small_window_boost()
	var top_lift := _small_window_boost()
	for pair in _top_small_text:
		var tl: Label = pair[0]
		if is_instance_valid(tl):
			tl.add_theme_font_size_override("font_size", roundi(maxi(int(pair[1]), HUD_TEXT_MIN) * top_lift))
	# Plan 420: the readings sit on one continuous iron band hung from the
	# top edge (economy, an ornament, the army, then the age pendant), and the
	# objective banner and menu tab hang from the same edge at the right.
	var band_h := roundf(TOP_RIBBON_H * top_lift)
	var run_x := 12.0
	var group_x := -1.0
	if is_instance_valid(_top_panel):
		var economy_w := _top_panel.get_combined_minimum_size().x
		_top_panel.position = Vector2(run_x, 0)
		_top_panel.size = Vector2(economy_w, band_h)
		run_x += economy_w
		group_x = run_x + 17.0
		run_x += 34.0
	if is_instance_valid(_force_panel):
		var force_w := _force_panel.get_combined_minimum_size().x
		_force_panel.position = Vector2(run_x, 0)
		_force_panel.size = Vector2(force_w, band_h)
		run_x += force_w + 14.0
	if is_instance_valid(_age_panel):
		var age_w := maxf(150.0, _age_panel.get_combined_minimum_size().x)
		_age_panel.position = Vector2(run_x, 0)
		_age_panel.size = Vector2(age_w, maxf(band_h + 26.0, _age_panel.get_combined_minimum_size().y))
		run_x += age_w
	if is_instance_valid(_top_ribbon):
		_top_ribbon.position = Vector2.ZERO
		_top_ribbon.size = Vector2(run_x + 30.0, band_h + 14.0)
		_top_ribbon.set("band_height", band_h)
		_top_ribbon.set("ornaments", PackedFloat32Array([group_x]) if group_x > 0.0 else PackedFloat32Array())
		_top_ribbon.queue_redraw()
	if is_instance_valid(_objective_panel):
		# The banner's lines grow on a laptop window; it widens leftward.
		_objective_panel.offset_left = -526.0 - 150.0 * (top_lift - 1.0)
		_objective_panel.offset_right = -100.0
		# Where the band and the banner would meet (a 4:3 screen), the banner
		# drops below the age pendant instead of covering the readings.
		var objective_drop := viewport_size.x + _objective_panel.offset_left < run_x + 42.0
		_objective_panel.offset_top = band_h + 34.0 if objective_drop else 0.0
		# Content height keeps the full-width objective rows readable.
		_objective_panel.offset_bottom = _objective_panel.offset_top + 96.0
		call_deferred("_fit_objective_content")
	var requested_selection_height := SELECTION_PANEL_HEIGHT
	if is_instance_valid(_sel_panel) and _sel_panel.has_meta("multi_selection_height"):
		requested_selection_height = float(_sel_panel.get_meta("multi_selection_height"))
	if is_instance_valid(_tracked_single):
		if _tracked_single is Unit:
			# Two-line combat readouts need clear breathing room above the live
			# activity line; workers keep their more compact economy dossier.
			requested_selection_height = 244.0 if _tracked_single.is_hero else (210.0 if _tracked_single.is_worker else 224.0)
		elif _tracked_single is Building:
			requested_selection_height = 218.0 if not _tracked_single.is_built else 190.0
	# Give the selected entity and two-column command deck enough room to be read
	# at the game's native 1920x1080 layout size. Overflow remains scrollable.
	# Four simple orders need a shorter deck than a hero or builder. Size to the
	# actual context while retaining a ceiling for denser production surfaces.
	var fixed_height := _cmd_fixed.get_combined_minimum_size().y if is_instance_valid(_cmd_fixed) else 0.0
	# Tall screens give the hall's train, age and caravan rows room to show.
	var command_ceiling := clampf(viewport_size.y * 0.45, 430.0, 500.0)
	var command_height := minf(command_ceiling, _cmd_body.get_combined_minimum_size().y + fixed_height + 30.0)
	var selection_height := minf(requested_selection_height, maxf(228.0, floor(viewport_size.y * 0.27)))
	if is_instance_valid(_minimap_panel):
		var map_size := _minimap_panel.get_combined_minimum_size()
		_minimap_panel.scale = Vector2.ONE * _panel_scale
		_minimap_panel.offset_left = margin
		_minimap_panel.offset_right = margin + map_size.x
		_minimap_panel.offset_top = -margin - map_size.y * _panel_scale
		_minimap_panel.offset_bottom = _minimap_panel.offset_top + map_size.y
	var command_visual_left := viewport_size.x - margin - COMMAND_PANEL_WIDTH * _panel_scale
	if is_instance_valid(_sel_panel):
		# Reserve a narrow forged join between the live dossier and command deck.
		# The chassis rail occupies the left edge of the command deck; placing the
		# dossier directly against it covered the rightmost status and stat glyphs
		# at compact resolutions. The chassis still bridges the visual gap.
		selection_height = maxf(selection_height, _sel_panel.get_combined_minimum_size().y)
		_sel_panel.scale = Vector2.ONE * _panel_scale
		var selection_left := command_visual_left - 18.0 - SELECTION_PANEL_WIDTH * _panel_scale
		_sel_panel.offset_left = selection_left - viewport_size.x * 0.5
		_sel_panel.offset_right = _sel_panel.offset_left + SELECTION_PANEL_WIDTH
		_sel_panel.offset_top = -margin - selection_height * _panel_scale
		_sel_panel.offset_bottom = _sel_panel.offset_top + selection_height
	if is_instance_valid(_selection_portrait) and is_instance_valid(_sel_panel):
		_selection_portrait.scale = Vector2.ONE * _panel_scale
		_selection_portrait.position = Vector2(_sel_panel.get_global_rect().position.x + 4.0, _sel_panel.get_global_rect().position.y - 35.0)
	if is_instance_valid(_cmd_panel):
		_cmd_panel.scale = Vector2.ONE * _panel_scale
		_cmd_panel.offset_left = command_visual_left - viewport_size.x
		_cmd_panel.offset_right = _cmd_panel.offset_left + COMMAND_PANEL_WIDTH
		_cmd_panel.offset_top = -margin - command_height * _panel_scale
		_cmd_panel.offset_bottom = _cmd_panel.offset_top + command_height
	if is_instance_valid(_command_chassis) and is_instance_valid(_sel_panel) and is_instance_valid(_cmd_panel):
		var selected_rect := _sel_panel.get_global_rect()
		var command_rect := _cmd_panel.get_global_rect()
		var portrait_ready := is_instance_valid(_selection_portrait)
		var portrait_rect := _selection_portrait.get_global_rect() if portrait_ready else Rect2()
		_command_chassis.configure(selected_rect, command_rect, portrait_rect, portrait_ready)
		_command_chassis.visible = _sel_panel.visible and _cmd_panel.visible
		# The chassis is the backdrop of both panels and is drawn only when both
		# show. A selection without orders (a tower, an enemy) stood as bare
		# text over the ground: alone, the selection panel carries its own plate.
		var alone: bool = _sel_panel.visible and not _cmd_panel.visible
		var plate_kind: String = "" if not alone else ("unit" if _tracked_single is Unit else "other")
		if plate_kind != String(_sel_panel.get_meta("lone_plate", "")):
			_sel_panel.set_meta("lone_plate", plate_kind)
			# A lone building or enemy gets the forged plate the minimap wears
			# instead of a flat box; a lone unit keeps the box, whose raised top
			# holds the caption over its portrait.
			var shaped := plate_kind == "other"
			_sel_panel.set("embedded", not shaped)
			_sel_panel.queue_redraw()
			var plate := _hud_stylebox()
			# A lone unit's flat box has its rim outside the content (expand
			# margins), so only the forged plates need the wider right margin.
			if plate_kind != "unit":
				plate.content_margin_right = 18
			if alone and not shaped:
				# Room at the top for the caption that stands over a unit's portrait.
				plate.expand_margin_top = 26.0 if plate_kind == "unit" else 6.0
				plate.bg_color = Color(0.035, 0.045, 0.05, 0.94)
				plate.border_color = Color(0.64, 0.46, 0.26, 0.85)
				plate.set_border_width_all(2)
				plate.set_corner_radius_all(6)
				plate.expand_margin_left = 6.0
				plate.expand_margin_right = 6.0
				plate.expand_margin_bottom = 6.0
			_sel_panel.add_theme_stylebox_override("panel", plate)
	if is_instance_valid(_menu_button):
		_menu_button.offset_left = -94.0
		_menu_button.offset_right = 0.0
		_menu_button.offset_top = 0.0
		_menu_button.offset_bottom = band_h
	_layout_command_feedback()
	queue_redraw()


func _fit_command_panel_next_frame() -> void:
	# Selection rebuilds queue_free the previous cards. Measure once the old
	# controls have left the tree so short order decks do not inherit their size.
	await get_tree().process_frame
	if is_inside_tree():
		_fit_to_viewport()


func _fit_objective_content() -> void:
	if not is_instance_valid(_objective_panel):
		return
	var desired := maxf(96.0, _objective_panel.get_combined_minimum_size().y)
	if absf(_objective_panel.size.y - desired) > 0.5:
		_objective_panel.size.y = desired
	_place_objective_alert()


func _place_objective_alert() -> void:
	if not is_instance_valid(_objective_panel) or not is_instance_valid(_alert_box):
		return
	_alert_box.offset_left = _objective_panel.offset_left + 2.0 - _alert_shift
	_alert_box.offset_right = _objective_panel.offset_right - 2.0 - _alert_shift
	_alert_box.offset_top = _objective_panel.position.y + _objective_panel.size.y + 8.0


# Plan 394: on a small window a tall command deck reached up into the alert
# under the objective card and the two read as one jumble of text. The alert
# now steps left, clear of the deck, while they would meet, and returns under
# the card when they no longer do. Since plan 398 (Codex R60) order tooltips
# and notices place themselves around the alert instead.
var _alert_shift := 0.0

func _keep_alert_clear() -> void:
	if not is_instance_valid(_alert_box) or not is_instance_valid(_cmd_panel) or _alert_box.get_child_count() == 0:
		return
	var home := Rect2(_alert_box.global_position + Vector2(_alert_shift, 0.0), _alert_box.size)
	var blocked := Rect2()
	if _cmd_panel.is_visible_in_tree():
		blocked = _cmd_panel.get_global_rect()
	var shift := 0.0
	if blocked.size != Vector2.ZERO and home.grow(4.0).intersects(blocked):
		shift = maxf(0.0, home.end.x - blocked.position.x + 12.0)
		# Never off the left edge of the screen.
		shift = minf(shift, maxf(0.0, home.position.x - 8.0))
	if absf(shift - _alert_shift) > 0.5:
		_alert_shift = shift
		_place_objective_alert()
		_layout_command_feedback.call_deferred()


func _build_resource_tooltip() -> void:
	_resource_tooltip = PanelContainer.new()
	_resource_tooltip.name = "ResourceHoverTooltip"
	_resource_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resource_tooltip.visible = false
	# Sized to its text: a bare name such as "Clan Croft" sat in the corner
	# of a wide empty black box.
	_resource_tooltip.custom_minimum_size = Vector2(0.0, 0.0)
	_resource_tooltip.add_theme_stylebox_override("panel", _resource_tooltip_stylebox())
	_resource_tooltip_label = _top_small(_mk_label("", 18, Color(0.96, 0.91, 0.79)), 18)
	_resource_tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resource_tooltip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_resource_tooltip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_resource_tooltip_label.custom_minimum_size = Vector2(0.0, 0.0)
	_resource_tooltip_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	_resource_tooltip.add_child(_resource_tooltip_label)
	add_child(_resource_tooltip)
	_resource_tooltip.visibility_changed.connect(func():
		if not _resource_tooltip.visible:
			_restore_resource_hover_title())
	visibility_changed.connect(func():
		if not is_visible_in_tree():
			_resource_tooltip.hide()
			_restore_resource_hover_title())
	tree_exiting.connect(_restore_resource_hover_title)


func _resource_tooltip_stylebox() -> StyleBox:
	# Plan 454: the hover card over veins, resources and buildings in the
	# field uses the same forged frame as every other tooltip (plan 449).
	var theme_res = load("res://assets/ui/tooltip_theme.tres")
	if theme_res is Theme and theme_res.has_stylebox("panel", "TooltipPanel"):
		return theme_res.get_stylebox("panel", "TooltipPanel")
	var sb := _hud_stylebox()
	sb.bg_color = Color(0.05, 0.06, 0.075, 0.96)
	sb.border_color = Color(0.82, 0.65, 0.30, 0.98)
	# The border colour was set but no width, so the box drew as a plain
	# black slab; it now matches the game's other tooltips.
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_width_top = 2
	sb.set_corner_radius_all(3)
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size = 6
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 7.0
	sb.content_margin_bottom = 8.0
	return sb


var _hovered_vein = null

func _set_vein_hover(v) -> void:
	if is_instance_valid(_hovered_vein) and _hovered_vein != v:
		_hovered_vein.pointer_hover = false
	_hovered_vein = v
	if is_instance_valid(v):
		v.pointer_hover = true

func _set_resource_hover(on: bool) -> void:
	if is_instance_valid(_hovered_resource) and _hovered_resource.has_method("set_pointer_hover"):
		_hovered_resource.set_pointer_hover(on)

func _restore_resource_hover_title() -> void:
	var title_id := _resource_hover_title_id
	_resource_hover_title_id = 0
	if title_id == 0 or not is_instance_id_valid(title_id):
		return
	var title = instance_from_id(title_id)
	if is_instance_valid(title):
		title.show()


func _resource_hover_obstacles() -> Array[Rect2]:
	var boxes: Array[Rect2] = []
	for node in [_top_panel, _force_panel, _age_panel, _objective_panel,
		_menu_button, _minimap_panel, _sel_panel, _cmd_panel, _alert_box, _command_tooltip]:
		if is_instance_valid(node) and node.is_visible_in_tree():
			boxes.append(node.get_global_rect().grow(8.0))
	for child in get_children():
		if child is Control and child.has_meta("command_notice") and child.is_visible_in_tree():
			boxes.append(child.get_global_rect().grow(8.0))
	return boxes


func _resource_hover_position(pointer: Vector2, tooltip_size: Vector2) -> Vector2:
	var margin := Vector2(8.0, 8.0)
	var viewport_size := get_viewport_rect().size
	var offset := Vector2(16.0, 18.0)
	var candidates: Array[Vector2] = [pointer + offset,
		pointer + Vector2(-tooltip_size.x - offset.x, offset.y),
		pointer - tooltip_size - offset,
		pointer + Vector2(offset.x, -tooltip_size.y - offset.y)]
	var obstacles := _resource_hover_obstacles()
	# If the adjacent quadrants meet a panel, try its nearest outer edges.
	# This also handles a tooltip wider than the playable sliver beside a deck.
	for box in obstacles:
		candidates.append(Vector2(pointer.x + offset.x, box.position.y - tooltip_size.y))
		candidates.append(Vector2(pointer.x + offset.x, box.end.y))
		candidates.append(Vector2(box.position.x - tooltip_size.x, pointer.y + offset.y))
		candidates.append(Vector2(box.end.x, pointer.y + offset.y))
	var best := Vector2.ZERO
	var best_overlap := INF
	var best_distance := INF
	for position in candidates:
		var clamped := Vector2(
			clampf(position.x, margin.x, maxf(margin.x, viewport_size.x - tooltip_size.x - margin.x)),
			clampf(position.y, margin.y, maxf(margin.y, viewport_size.y - tooltip_size.y - margin.y)))
		var rect := Rect2(clamped, tooltip_size)
		var overlap := 0.0
		for box in obstacles:
			if rect.intersects(box):
				overlap += rect.intersection(box).get_area()
		# Keep the pointer itself unobscured; ties prefer the nearest clear slot.
		if rect.grow(6.0).has_point(pointer):
			overlap += tooltip_size.x * tooltip_size.y
		var distance := clamped.distance_squared_to(pointer + offset)
		if overlap < best_overlap or (is_equal_approx(overlap, best_overlap) and distance < best_distance):
			best = clamped
			best_overlap = overlap
			best_distance = distance
	return best


func _update_resource_tooltip(pointer_override: Vector2 = Vector2(-1.0, -1.0)) -> void:
	_restore_resource_hover_title()
	if not is_instance_valid(_resource_tooltip) or not is_instance_valid(rts):
		return
	# Plan 454: no field hover card over the pause screen or other overlays.
	if get_tree().paused:
		if _resource_tooltip.visible:
			_set_resource_hover(false)
			_hovered_resource = null
			_resource_tooltip.visible = false
		return
	var hovered_control := get_viewport().gui_get_hovered_control()
	if is_instance_valid(hovered_control):
		_set_resource_hover(false)
		_hovered_resource = null
		_resource_tooltip.visible = false
		return
	var pointer := get_viewport().get_mouse_position()
	if pointer_override.x >= 0.0 and pointer_override.y >= 0.0:
		pointer = pointer_override
	var hovered = rts.raycast_selection_at(pointer)
	_set_vein_hover(null)
	if not is_instance_valid(hovered):
		_set_resource_hover(false)
		_hovered_resource = null
		# Over a vein: say what it is and whether it can be claimed.
		var ground = rts._raycast_ground() if rts.has_method("_raycast_ground") and pointer_override.x < 0.0 else null
		var vein = world.vein_near(ground, 4.5) if ground != null and is_instance_valid(world) and world.has_method("vein_near") else null
		if vein != null and (not world.has_method("player_visibility_state_at") or world.player_visibility_state_at(vein.global_position) != 0):
			_set_vein_hover(vein)
			var owner_txt := "Free: right-click with workers to raise an outpost" if vein.is_free() else ("Your outpost" if int(vein.outpost.team) == int(rts.player_team) else "Held by the enemy")
			_resource_tooltip_label.text = "%s
%d left  ·  %s" % [vein.display_name(), int(vein.amount), owner_txt]
			_place_resource_tooltip(pointer)
			return
		_resource_tooltip.visible = false
		return
	if hovered is ResourceNode:
		if bool(hovered.get("depleted")):
			_set_resource_hover(false)
			_hovered_resource = null
			_resource_tooltip.visible = false
			return
		if _hovered_resource != hovered:
			_set_resource_hover(false)
		_hovered_resource = hovered
		_set_resource_hover(true)
		var kind := String(hovered.get("resource_kind")).capitalize()
		var amount := maxi(0, int(hovered.get("amount")))
		# How many of your own workers are on it, so a crowded pile is seen.
		var crew := 0
		if is_instance_valid(_commander):
			for u in _commander.units:
				if is_instance_valid(u) and u.is_worker and not u.is_dead and u.get("_gather_node") == hovered:
					crew += 1
		var crew_line := ("\n%d of your workers here" % crew) if crew > 1 else ("\n1 of your workers here" if crew == 1 else "")
		_resource_tooltip_label.text = "%s\n%d remaining%s" % [kind, amount, crew_line]
	elif hovered is Unit or hovered is Building:
		_set_resource_hover(false)
		_hovered_resource = null
		var fallback_name := "Unit" if hovered is Unit else "Building"
		var public_name := String(hovered.def.get("name", fallback_name))
		var hostile: bool = "team" in hovered and int(hovered.team) != int(rts.player_team)
		_resource_tooltip_label.text = "%s\nHostile" % public_name if hostile else public_name
		# Show one full identifier, not a title banner and a second bare name.
		# Do not hide an already-hidden title or change an enemy's information.
		var title := hovered.get_node_or_null("HeroTitle") as Label3D
		if not hostile and is_instance_valid(title) and title.is_visible_in_tree() and not title.text.strip_edges().is_empty():
			_resource_tooltip_label.text = title.text
			_resource_hover_title_id = title.get_instance_id()
			title.hide()
	else:
		_set_resource_hover(false)
		_hovered_resource = null
		_resource_tooltip.visible = false
		return
	_place_resource_tooltip(pointer)


## Plan 454: hide the field hover card (the pause screen calls this).
func hide_field_hover() -> void:
	if is_instance_valid(_resource_tooltip) and _resource_tooltip.visible:
		_set_resource_hover(false)
		_hovered_resource = null
		_resource_tooltip.visible = false
		_restore_resource_hover_title()


func _place_resource_tooltip(pointer: Vector2) -> void:
	# Plan 482: never over the result screen (it covered a loot name).
	if is_instance_valid(_gameover_layer):
		hide_field_hover()
		return
	_resource_tooltip.reset_size()
	_resource_tooltip.position = _resource_hover_position(pointer, _resource_tooltip.size)
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
const HUD_TEXT_MIN := 14

func _mk_label(text: String, size: int = 16, col: Color = FONT_COLOR) -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _body_font:
		l.add_theme_font_override("font", _body_font)
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	# Nothing smaller than 14: inside the 1.2x panels that draws at 17 px at
	# 1920. At 12 (14 px) the vitals, status and stat captions still made
	# players squint.
	l.add_theme_font_size_override("font_size", maxi(size, HUD_TEXT_MIN))
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


func _mk_menu_button(text: String, size: int) -> Button:
	var b := Button.new()
	b.text = text
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	var theme_res = load("res://assets/ui/theme.tres")
	if theme_res is Theme:
		b.theme = theme_res
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	b.add_theme_color_override("font_hover_color", Color(1, 1, 0.9))
	return b


func _mk_title_label(text: String, size: int, col: Color) -> Label:
	var l := _mk_label(text, size, col)
	if _font:
		l.add_theme_font_override("font", _font)
	return l


func _mk_hud_panel(kind: String = "selection", accent: Color = HUD_BRONZE) -> PanelContainer:
	var p: PanelContainer = HUD_PLATE_SCRIPT.new()
	p.plate_kind = kind
	p.accent = accent
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.add_theme_stylebox_override("panel", _hud_stylebox())
	return p


func _hud_stylebox() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	# The shaped plate script paints the material and silhouette. Theme margins
	# only reserve safe space for real controls inside the cut metal perimeter.
	sb.bg_color = Color.TRANSPARENT
	sb.set_content_margin_all(10)
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


func _mk_atlas_object_icon(texture: Texture2D, region: Rect2, px: float) -> TextureRect:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = region
	atlas.filter_clip = true
	var icon := TextureRect.new()
	icon.texture = atlas
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(px, px)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _mk_resource_object_icon(kind: String, px: float) -> TextureRect:
	# One authored atlas keeps the four resource silhouettes and lighting in the
	# same visual family while leaving the existing resource data untouched.
	# Crop transparent atlas gutters in the texture region, keeping each object
	# large enough to resolve at the live HUD's normal display scale.
	var region := Rect2(90, 45, 484, 532)
	match kind:
		"timber": region = Rect2(651, 82, 584, 511)
		"stone": region = Rect2(55, 691, 556, 515)
		"gold": region = Rect2(670, 721, 554, 464)
	return _mk_atlas_object_icon(RESOURCE_OBJECT_ATLAS, region, px)


func _mk_force_object_icon(kind: String, px: float) -> TextureRect:
	# The two upper illustrations cross the atlas's 627px midpoint. Split in
	# their actual transparent gutter instead, so neither silhouette is cut.
	var region := Rect2(0, 0, 685, 627)
	match kind:
		"opponent": region = Rect2(690, 0, 564, 627)
		"worker": region = Rect2(0, 627, 627, 627)
		"army": region = Rect2(627, 627, 627, 627)
	return _mk_atlas_object_icon(FORCE_OBJECT_ATLAS, region, px)


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


const KeyBinds := preload("res://scripts/game/key_binds.gd")

func _command_hotkey(title: String) -> String:
	var haystack := title.to_lower()
	if haystack.contains("attack"):
		return KeyBinds.label("cmd_attack")
	if haystack.contains("stop"):
		return KeyBinds.label("cmd_stop")
	if haystack.contains("hold"):
		return KeyBinds.label("cmd_hold")
	if haystack.contains("patrol"):
		return KeyBinds.label("cmd_patrol")
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


func _command_accent(title: String, state: String, kind: String = "ORDER") -> Color:
	var family := COMMAND_GOLD
	match kind:
		"ABILITY": family = Color(0.98, 0.75, 0.37)
		"BUILD": family = COMMAND_MINT
		"TRAIN": family = Color(0.89, 0.67, 0.43)
		"RESEARCH": family = COMMAND_SKY
	if kind != "ORDER":
		return family.lerp(COMMAND_MUTED, 0.74) if state in ["LOCKED", "COMPLETED"] else family
	if state == "LOCKED":
		return COMMAND_MUTED
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
	# Plan 451: an enamelled plaque, slanted like a pennant: dark enamel in
	# the tag's colour, a fine metal line above and below, and lit ends.
	sb.bg_color = Color(color.r * 0.16, color.g * 0.14, color.b * 0.12, 0.92)
	sb.border_color = Color(color.r, color.g, color.b, 0.62)
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.skew = Vector2(0.16, 0.0)
	# The slant leans the top past the right edge; draw it a little inside
	# the tag's box so a neighbor or a clipping column never cuts it.
	sb.expand_margin_left = -2.0
	sb.expand_margin_right = -2.0
	sb.set_corner_radius_all(0)
	sb.set_content_margin_all(3)
	sb.content_margin_left = 5
	sb.content_margin_right = 5
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 2
	sb.shadow_offset = Vector2(0, 1)
	badge.add_theme_stylebox_override("panel", sb)
	var label := _mk_label(text, 10, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# The badge grows to its word: a badge never shows a cut-off word.
	label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	badge.add_child(label)
	return badge


func _mk_command_keycap(text: String, accent: Color) -> PanelContainer:
	var cap := PanelContainer.new()
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap.custom_minimum_size = Vector2(29, 23)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.11, 0.12, 0.12, 0.91)
	sb.border_color = Color(accent.r, accent.g, accent.b, 0.67)
	sb.border_width_top = 1
	sb.border_width_left = 1
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(1)
	sb.set_content_margin_all(2)
	sb.shadow_color = Color(0, 0, 0, 0.53)
	sb.shadow_size = 2
	cap.add_theme_stylebox_override("panel", sb)
	var label := _mk_label(text, 14, Color(1.0, 0.96, 0.82))
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
	var visual_faction := str(_commander.race) if is_instance_valid(_commander) else "barrosan"
	icon.configure(kind, accent, visual_faction)
	return icon


func _command_icon_stylebox(accent: Color, ability_card: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(accent.r, accent.g, accent.b, 0.14 if ability_card else 0.07)
	sb.border_color = Color(accent.r, accent.g, accent.b, 0.58)
	sb.set_border_width_all(0)
	sb.border_width_left = 2
	sb.set_corner_radius_all(1)
	sb.set_content_margin_all(3)
	return sb


func _add_stat_chip(row: HBoxContainer, caption: String, value: String, kind: String, accent: Color) -> void:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(62, 42)
	chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	# Plan 477: bronze rules and gold captions like the top bar; the team
	# colour stays on the role badge and the portrait title.
	sb.bg_color = Color(0.0, 0.0, 0.0, 0.22)
	sb.border_color = Color(0.62, 0.47, 0.28, 0.55)
	sb.border_width_right = 0 if kind == "range" else 1
	sb.set_corner_radius_all(0)
	sb.content_margin_left = 2
	sb.content_margin_right = 2
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	chip.add_theme_stylebox_override("panel", sb)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", -3)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title_label := _mk_label(caption, 12, Color(0.86, 0.72, 0.46))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(title_label)
	var value_label := _mk_label(value, 18, FONT_COLOR)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.tooltip_text = "%s: %s" % [caption, value]
	stack.add_child(value_label)
	chip.add_child(stack)
	row.add_child(chip)
	_single_stat_cards.append({"kind": kind, "label": value_label, "caption": caption})


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


func _seat_crafted_build_preview(preview: Control, locked: bool) -> void:
	# The card supplies the bronze aperture; a second portrait frame crowds
	# the complete architectural silhouette at this compact scale.
	if preview.has_node("PortraitFrame"):
		preview.get_node("PortraitFrame").hide()
	preview.modulate = Color(0.64, 0.65, 0.63) if locked else Color.WHITE


func _fit_build_card(btn: Button, copy: Control) -> void:
	if not is_instance_valid(btn) or not is_instance_valid(copy):
		return
	# Before the card has its width the wrapped text reports one word a line:
	# nothing is taken from that. The height follows the text both ways and
	# never goes under the standard card.
	if copy.size.x < 60.0:
		return
	var need := maxf(100.0 if bool(btn.get("crafted_build")) else 96.0, ceilf(copy.get_combined_minimum_size().y + 5.0 + 21.0))
	if not is_equal_approx(need, btn.custom_minimum_size.y):
		btn.custom_minimum_size.y = need


func _mk_command_button(title: String, detail: String, tooltip: String, disabled_reason: String = "", state: String = "READY", preview_definition: Dictionary = {}, visible_effect: String = "", visible_effect_prefix: String = "Effect", hotkey_override: String = "", command_kind_override: String = "", emblem_id: String = "", unit_art_definition: Dictionary = {}) -> Button:
	var has_preview := not preview_definition.is_empty()
	var crafted_build := has_preview and String(preview_definition.get("command_art", "")).begins_with("res://assets/ui/construction_illustrations/r54/")
	# The card is intentionally a scan surface. Hero abilities provide their
	# authored hotkey explicitly; ordinary orders derive theirs from the title.
	var ability_card := visible_effect_prefix == "Effect" and not hotkey_override.is_empty()
	var command_kind := command_kind_override if not command_kind_override.is_empty() else ("ABILITY" if ability_card else _command_kind(title, visible_effect_prefix, has_preview, false))
	# Costs, tiers and population are actionable scan data. Long authored prose
	# stays in the anchored tooltip so the command grid reads like an RTS deck,
	# not a stack of debug forms.
	var scan_detail := has_preview or ability_card or command_kind in ["TRAIN", "RESEARCH"] or detail.to_lower().contains("cost") or detail.to_lower().contains("tier") or detail.to_lower().contains("population")
	var detail_text := _command_card_summary(detail) if scan_detail else ""
	# The status footer carries readiness; the full reason stays in the tooltip.
	var accent := _command_accent(title, state, command_kind)
	var hotkey := hotkey_override if not hotkey_override.is_empty() else (_command_hotkey(title) if command_kind == "ORDER" else "")
	var btn = HUD_ACTION_SCRIPT.new()
	btn.text = ""
	btn.accent = accent
	btn.command_kind = command_kind
	btn.crafted_build = crafted_build
	if crafted_build:
		btn.set_meta("construction_name", title)
	btn.command_state = state
	var card_height := (100 if crafted_build else 96) if has_preview else (86 if ability_card else 60)
	btn.custom_minimum_size = Vector2(0, card_height)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.clip_text = false
	btn.focus_mode = Control.FOCUS_NONE
	if has_preview and ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
		var preview = load(ENTITY_PORTRAIT_SCRIPT).new()
		preview.name = "BuildingPreview"
		var art_size := Vector2(88, 88) if crafted_build else Vector2(84, 84)
		preview.position = Vector2(6, 6) if crafted_build else Vector2(4, 4)
		preview.size = art_size
		preview.custom_minimum_size = art_size
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(preview)
		preview.configure_definition(preview_definition)
		preview.set_deferred("custom_minimum_size", art_size)
		preview.set_deferred("size", art_size)
		if crafted_build:
			preview.ready.connect(_seat_crafted_build_preview.bind(preview, state != "READY"), CONNECT_ONE_SHOT)
		var text_col := VBoxContainer.new()
		text_col.name = "BuildingCardCopy"
		text_col.anchor_right = 1.0
		text_col.offset_left = 100.0 if crafted_build else 95.0
		text_col.offset_top = 7.0
		text_col.offset_right = -7.0
		text_col.offset_bottom = -21.0
		text_col.add_theme_constant_override("separation", 2)
		text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Narrow two-column build cards can wrap both the name and cost. Reserve
		# the status footer by fitting those two scan lines inside the 96px card.
		var display_title := {"Castro Forge": "Forge", "Castro Rampart": "Rampart", "Castro Quarry-Works": "Quarry-Works", "The Standing Stones": "Standing Stones"}.get(title, title) if crafted_build else title
		var title_label := _mk_label(display_title, 14, Color(0.94, 0.87, 0.71) if crafted_build and state == "READY" else (Color(0.64, 0.64, 0.60) if crafted_build else FONT_COLOR))
		title_label.name = "ConstructionTitle"
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_col.add_child(title_label)
		var preview_detail_color := (Color(0.59, 0.61, 0.59) if state != "READY" else Color(0.84, 0.84, 0.77)) if crafted_build else (Color(0.82, 0.82, 0.76) if state == "LOCKED" else Color(0.9, 0.88, 0.8))
		var detail_label := _mk_label(detail_text.replace(", ", "\n"), 12, preview_detail_color)
		detail_label.name = "ConstructionCost"
		detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		text_col.add_child(detail_label)
		btn.add_child(text_col)
		# A name of two lines over two lines of cost ran into the state word at
		# the foot of the card: every build card sets its lines a little closer.
		title_label.add_theme_constant_override("line_spacing", -4)
		detail_label.add_theme_constant_override("line_spacing", -3)
		text_col.offset_top = 5.0
		# A name of three lines, or a price of three parts, needs more than the
		# 96 px: the card grows to its text so the cost never runs into the
		# READY or LOCKED word below it.
		text_col.minimum_size_changed.connect(_fit_build_card.bind(btn, text_col))
		text_col.resized.connect(_fit_build_card.bind(btn, text_col))
	else:
		var painted_emblem := not emblem_id.is_empty() or not unit_art_definition.is_empty()
		var featured_ability := command_kind == "ABILITY"
		var field_order_art := command_kind == "ORDER" and _command_icon_kind(title, command_kind) in ["attack", "stop", "hold", "patrol"]
		var glyph_plate := PanelContainer.new()
		glyph_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glyph_plate.position = Vector2(4, 4) if featured_ability else Vector2(6, 6 if not painted_emblem and not field_order_art else 4)
		glyph_plate.size = Vector2(68, 68) if featured_ability else (Vector2(52, 52) if painted_emblem else (Vector2(44, 44) if field_order_art else Vector2(38, 38)))
		glyph_plate.custom_minimum_size = glyph_plate.size
		# In a train or research list a row without painted art keeps its small
		# glyph, centred in the slot the painted rows use, so every title in the
		# list starts on the same line.
		var list_row_plain := command_kind in ["TRAIN", "RESEARCH"] and not painted_emblem
		if list_row_plain:
			glyph_plate.position = Vector2(11, 11)
		glyph_plate.add_theme_stylebox_override("panel", _command_icon_stylebox(accent, ability_card))
		if not unit_art_definition.is_empty() and ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
			var unit_art: Control = load(ENTITY_PORTRAIT_SCRIPT).new()
			unit_art.name = "UnitCommandPortrait"
			unit_art.custom_minimum_size = Vector2(44, 44)
			unit_art.size = Vector2(44, 44)
			if state in ["LOCKED", "COMPLETED"]:
				unit_art.modulate = Color(0.72, 0.77, 0.80, 0.76)
			glyph_plate.add_child(unit_art)
			unit_art.configure_definition(unit_art_definition, false)
		else:
			var glyph_size := 60.0 if featured_ability else (44.0 if painted_emblem or field_order_art else 28.0)
			var glyph := _mk_command_icon(emblem_id if painted_emblem else _command_icon_kind(title, command_kind), accent, glyph_size)
			glyph.name = "CommandEmblem" if painted_emblem or field_order_art else "CommandGlyph"
			if painted_emblem and state in ["LOCKED", "COMPLETED"]:
				glyph.modulate = Color(0.72, 0.77, 0.80, 0.76)
			if painted_emblem or field_order_art:
				glyph.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			glyph_plate.add_child(glyph)
		btn.add_child(glyph_plate)
		var text_col := VBoxContainer.new()
		text_col.position = Vector2(82, 8) if featured_ability else (Vector2(65, 6) if painted_emblem or list_row_plain else (Vector2(55, 6) if field_order_art else Vector2(50, 6)))
		var text_height := card_height - 10
		var text_width := 288 if command_kind in ["TRAIN", "RESEARCH"] else (230 if ability_card else 112)
		text_col.size = Vector2(text_width, text_height)
		text_col.custom_minimum_size = Vector2(text_width, text_height)
		text_col.add_theme_constant_override("separation", 1)
		text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var title_color := Color(0.79, 0.81, 0.79, 0.94) if state in ["LOCKED", "COMPLETED"] else FONT_COLOR
		var detail_color := Color(0.67, 0.71, 0.70, 0.94) if state in ["LOCKED", "COMPLETED"] else Color(0.86, 0.84, 0.76)
		var title_label := _mk_label(title, 20 if featured_ability else 18, title_color)
		title_label.autowrap_mode = TextServer.AUTOWRAP_OFF if command_kind in ["TRAIN", "RESEARCH"] else TextServer.AUTOWRAP_WORD_SMART
		title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS if command_kind in ["TRAIN", "RESEARCH"] else TextServer.OVERRUN_NO_TRIMMING
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_col.add_child(title_label)
		var detail_label := _mk_label(detail_text, 15 if featured_ability else 14, detail_color)
		detail_label.autowrap_mode = TextServer.AUTOWRAP_OFF if command_kind in ["TRAIN", "RESEARCH"] else TextServer.AUTOWRAP_WORD_SMART
		detail_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS if command_kind in ["TRAIN", "RESEARCH"] else TextServer.OVERRUN_NO_TRIMMING
		detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		text_col.add_child(detail_label)
		btn.add_child(text_col)
	if not hotkey.is_empty():
		var key_badge := _mk_command_keycap(hotkey, accent)
		key_badge.anchor_left = 1.0
		key_badge.anchor_right = 1.0
		key_badge.offset_left = -31.0
		key_badge.offset_right = -8.0
		key_badge.offset_top = 6.0
		key_badge.offset_bottom = 26.0
		btn.add_child(key_badge)
	if not has_preview:
		var status := state if state in ["READY", "ACTIVE", "TRAINING", "LOCKED", "COOLDOWN", "COMPLETED"] else ("UNAVAILABLE" if not disabled_reason.is_empty() else "READY")
		# "COMPLETED" was cut to "COMPLET..." in the 75 px slot: finished work reads DONE.
		var status_label := _mk_label("" if command_kind == "ORDER" and status == "READY" else ("DONE" if status == "COMPLETED" else status), 13, accent if status not in ["UNAVAILABLE", "LOCKED"] else Color(0.65, 0.69, 0.68))
		status_label.anchor_left = 1.0
		status_label.anchor_right = 1.0
		status_label.offset_left = -112.0
		status_label.offset_right = -8.0
		status_label.offset_top = card_height - 19
		status_label.offset_bottom = card_height - 2
		# On a train card the cost line runs the width of the card ("70 food,
		# 20 timber, 10 stone" ended under the word LOCKED). A soldier's name
		# is short, so the state sits beside it on the top line instead.
		if command_kind == "TRAIN":
			status_label.offset_top = 7.0
			status_label.offset_bottom = 24.0
			if not hotkey.is_empty():
				status_label.offset_left = -144.0
				status_label.offset_right = -38.0
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(status_label)
		btn.set_meta("command_status_label", status_label)
	else:
		# Keep readiness below the cost in the copy column so the structure art
		# can fill its bay without hiding the card's current state.
		var build_status := _mk_label(state, 11 if crafted_build else 13, Color(0.63, 0.79, 0.68) if crafted_build and state == "READY" else (Color(0.54, 0.57, 0.55) if crafted_build else (accent if state == "READY" else COMMAND_MUTED)))
		build_status.anchor_right = 1.0
		build_status.offset_left = 100.0 if crafted_build else 95.0
		build_status.offset_right = -8.0
		build_status.anchor_top = 1.0
		build_status.anchor_bottom = 1.0
		build_status.offset_top = -18.0
		build_status.offset_bottom = -2.0
		build_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		build_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(build_status)
		btn.set_meta("command_status_label", build_status)
	btn.set_meta("command_kind", command_kind)
	btn.set_meta("emblem_id", emblem_id)
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
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		btn.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	btn.add_theme_color_override("font_disabled_color", Color(0.48, 0.47, 0.43, 0.9))
	return btn


## Plan 427: a field order as a square forged tile: the painted emblem fills
## it, the hotkey sits in its corner and the name and help move to the
## anchored tooltip, the way a strategy game's command grid reads.
const COMMAND_TILE := 78.0

func _mk_command_tile(title: String, tooltip: String, state: String = "READY", hotkey_override: String = "", command_kind: String = "ORDER", disabled_reason: String = "") -> Button:
	var accent := _command_accent(title, state, command_kind)
	var hotkey := hotkey_override if not hotkey_override.is_empty() else (_command_hotkey(title) if command_kind == "ORDER" else "")
	var btn = HUD_ACTION_SCRIPT.new()
	btn.text = ""
	btn.accent = accent
	btn.command_kind = command_kind
	btn.command_state = state
	btn.set("tile", true)
	btn.custom_minimum_size = Vector2(COMMAND_TILE, COMMAND_TILE)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	btn.focus_mode = Control.FOCUS_NONE
	var glyph := _mk_command_icon(_command_icon_kind(title, command_kind), accent, COMMAND_TILE - 18.0)
	glyph.name = "CommandEmblem"
	glyph.position = Vector2(9, 9)
	glyph.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	btn.add_child(glyph)
	if not hotkey.is_empty():
		# Plan 472: the letter sits on a small dark keycap with a bronze edge,
		# so it reads over bright painted art.
		var cap := Panel.new()
		cap.name = "TileKeycap"
		var cap_style := StyleBoxFlat.new()
		cap_style.bg_color = Color(0.05, 0.04, 0.03, 0.88)
		cap_style.border_color = Color(0.62, 0.47, 0.28, 0.95)
		cap_style.set_border_width_all(1)
		cap_style.border_width_top = 2
		cap_style.border_color = Color(0.70, 0.54, 0.32, 0.95)
		cap_style.set_corner_radius_all(3)
		cap_style.shadow_color = Color(0, 0, 0, 0.55)
		cap_style.shadow_size = 2
		cap.add_theme_stylebox_override("panel", cap_style)
		cap.position = Vector2(COMMAND_TILE - 27.0, COMMAND_TILE - 27.0)
		cap.size = Vector2(19, 19)
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(cap)
		var key := _mk_label(hotkey, 14, Color(1.0, 0.92, 0.72))
		key.name = "TileHotkey"
		key.position = Vector2(COMMAND_TILE - 27.0, COMMAND_TILE - 27.5)
		key.size = Vector2(19, 19)
		key.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key.add_theme_constant_override("outline_size", 4)
		key.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(key)
	# Readiness word, shown only when it says something (cooldown, mana).
	var status := _mk_label("" if state == "READY" else ("CD" if state == "COOLDOWN" else state), 15, Color(1.0, 0.93, 0.78))
	status.name = "TileStatus"
	status.position = Vector2(0, COMMAND_TILE * 0.5 - 11.0)
	status.size = Vector2(COMMAND_TILE, 22)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_constant_override("outline_size", 5)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(status)
	btn.set_meta("command_status_label", status)
	btn.set_meta("command_kind", command_kind)
	btn.set_meta("emblem_id", "")
	var tooltip_text := tooltip + (("\n" + "Hotkey: " + hotkey) if not hotkey.is_empty() else "")
	btn.tooltip_text = ""
	btn.set_meta("command_tooltip_text", tooltip_text)
	btn.mouse_entered.connect(func(): _show_command_tooltip(title, command_kind, hotkey, tooltip, disabled_reason, accent))
	btn.mouse_exited.connect(_hide_command_tooltip)
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		btn.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	return btn


## Puts a picture in a command tile's art well in place of its emblem.
func _tile_set_art(btn: Button, art: Control) -> void:
	var old := btn.get_node_or_null("CommandEmblem")
	if old:
		btn.remove_child(old)
		old.queue_free()
	art.position = Vector2(9, 9)
	art.size = Vector2(COMMAND_TILE - 18.0, COMMAND_TILE - 18.0)
	art.custom_minimum_size = art.size
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(art)
	btn.move_child(art, 0)


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
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 3)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return grid


func _add_field_order_grid() -> GridContainer:
	var rack: PanelContainer = HUD_COMMAND_RACK_SCRIPT.new()
	rack.name = "FieldOrderRack"
	rack.mouse_filter = Control.MOUSE_FILTER_PASS
	var inset := StyleBoxFlat.new()
	inset.bg_color = Color.TRANSPARENT
	inset.set_content_margin_all(4)
	rack.add_theme_stylebox_override("panel", inset)
	_cmd_body.add_child(rack)
	var grid := _mk_command_grid()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	rack.add_child(grid)
	return grid


func _add_command_section(title: String, hint: String = "", pinned: bool = false) -> void:
	var row := HBoxContainer.new()
	if pinned:
		row.name = "PinnedCommandSection"
	row.custom_minimum_size = Vector2(0, 24)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(3, 14)
	rule.color = Color(COMMAND_GOLD.r, COMMAND_GOLD.g, COMMAND_GOLD.b, 0.55)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(rule)
	var title_label := _mk_label(title.to_upper(), 16, COMMAND_GOLD)
	title_label.custom_minimum_size = Vector2(132, 20)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(title_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	if not hint.is_empty() and hint not in ["Cast when ready.", "Move · attack"]:
		var hint_label := _mk_label(hint, 13, Color(0.75, 0.77, 0.74))
		hint_label.custom_minimum_size = Vector2(150, 20)
		hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spacer.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(hint_label)
		# Keep the hint off the deck's gilt edge.
		var pad := Control.new()
		pad.custom_minimum_size = Vector2(6, 0)
		pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(pad)
	if pinned:
		_cmd_fixed.add_child(row)
	else:
		_cmd_body.add_child(row)


# ---------------------------------------------------------------------------
# 1. TOP BAR
# ---------------------------------------------------------------------------
func _top_metric_surface(title: String, accent: Color, width: float, tooltip: String, instrument: bool = true) -> Dictionary:
	# The value row contract is retained so authoritative refresh handlers do
	# not change as the individual visual instruments replace the group slabs.
	if instrument:
		# Plan 420: one cell on the top band. Plan 433: a small name over the
		# icon and number (Codex composition R2); the meaning is in the tooltip.
		var cell: PanelContainer = HUD_TOP_METRIC_SCRIPT.new()
		cell.accent = accent
		cell.set("ribbon", true)
		cell.custom_minimum_size = Vector2(width, TOP_RIBBON_H)
		cell.tooltip_text = tooltip if tooltip.to_lower().begins_with(title.to_lower()) else "%s: %s" % [title, tooltip]
		cell.mouse_filter = Control.MOUSE_FILTER_STOP
		var cell_inset := StyleBoxFlat.new()
		cell_inset.bg_color = Color.TRANSPARENT
		cell_inset.content_margin_left = 8.0
		cell_inset.content_margin_right = 10.0
		cell_inset.content_margin_top = 2.0
		cell_inset.content_margin_bottom = 9.0
		cell.add_theme_stylebox_override("panel", cell_inset)
		var cell_stack := VBoxContainer.new()
		cell_stack.add_theme_constant_override("separation", -3)
		cell_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(cell_stack)
		var caption := _mk_label(String({"Opponents": "Rivals", "Idle Workers": "Idle Crew"}.get(title, title)).to_upper(), 12, accent.lerp(Color(0.94, 0.90, 0.79), 0.45))
		caption.name = "TopMetricCaption"
		# Plan 456: the captions grow with the rest of the top band on a small
		# window (at 1366 they were about 9 px tall).
		_top_small(caption, 13)
		caption.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.add_theme_constant_override("outline_size", 3)
		caption.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell_stack.add_child(caption)
		var cell_row := HBoxContainer.new()
		cell_row.add_theme_constant_override("separation", 6)
		cell_row.alignment = BoxContainer.ALIGNMENT_CENTER
		cell_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell_stack.add_child(cell_row)
		return {"surface": cell, "value_row": cell_row}
	var surface := VBoxContainer.new()
	surface.custom_minimum_size = Vector2(width - 10.0 if instrument else width, 46)
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	surface.tooltip_text = tooltip
	surface.add_theme_constant_override("separation", 0)
	var title_label := _mk_label(title.to_upper(), 16, accent.lerp(Color(0.94, 0.90, 0.79), 0.30))
	_top_small(title_label, 16)
	if instrument:
		title_label.name = "TopMetricTitle"
		# The compact forged corners need equal air on both sides of each name.
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	surface.add_child(title_label)
	var value_row := HBoxContainer.new()
	value_row.add_theme_constant_override("separation", 5)
	value_row.alignment = BoxContainer.ALIGNMENT_CENTER
	value_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_row.custom_minimum_size = Vector2(0, 34 if instrument else 26)
	surface.add_child(value_row)
	if not instrument:
		return {"surface": surface, "value_row": value_row}
	var plate: PanelContainer = HUD_TOP_METRIC_SCRIPT.new()
	plate.accent = accent
	# A common height keeps both ribbons' lower rails level after the resource
	# numerals and force numerals resolve to slightly different font metrics.
	plate.custom_minimum_size = Vector2(width, 104)
	plate.tooltip_text = tooltip
	plate.mouse_filter = Control.MOUSE_FILTER_STOP
	var inset := StyleBoxFlat.new()
	inset.bg_color = Color.TRANSPARENT
	inset.content_margin_left = 5.0
	inset.content_margin_right = 4.0
	inset.content_margin_top = 14.0
	inset.content_margin_bottom = 16.0
	plate.add_theme_stylebox_override("panel", inset)
	plate.add_child(surface)
	return {"surface": plate, "value_row": value_row}


func _top_group(title: String, accent: Color, width: float) -> Dictionary:
	var group := VBoxContainer.new()
	group.custom_minimum_size = Vector2(width, 48)
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	group.add_theme_constant_override("separation", 1)
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Captioned like the resource cards beside it (plain bold capitals,
	# centred): the title face here read dim and stood off to the left.
	var heading := _top_small(_mk_label(title.to_upper(), 16, accent.lerp(Color(0.94, 0.90, 0.79), 0.30)), 16)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.add_child(heading)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 2)
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
	# The top readings are independent instruments rather than one black ribbon.
	# Their spacing is resolved against the actual viewport in _fit_to_viewport.
	_top_ribbon = HUD_TOP_RIBBON_SCRIPT.new()
	_top_ribbon.name = "TopRibbon"
	add_child(_top_ribbon)
	var panel := _mk_hud_panel("economy", COMMAND_GOLD)
	_top_panel = panel
	_top_panel.name = "TopResourceBar"
	panel.embedded = true
	var rack_inset := StyleBoxFlat.new()
	rack_inset.bg_color = Color.TRANSPARENT
	rack_inset.set_content_margin_all(0)
	panel.add_theme_stylebox_override("panel", rack_inset)
	panel.custom_minimum_size = Vector2(0, TOP_RIBBON_H)
	add_child(panel)

	var resource_accents := {
		"food": Color(0.96, 0.72, 0.32),
		"timber": Color(0.76, 0.54, 0.32),
		"stone": Color(0.63, 0.72, 0.78),
		"gold": Color(0.98, 0.86, 0.42),
	}
	var economy_metrics := HBoxContainer.new()
	economy_metrics.add_theme_constant_override("separation", 3)
	economy_metrics.alignment = BoxContainer.ALIGNMENT_CENTER
	economy_metrics.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for k in RES_ORDER:
		var metric := _top_metric_surface(k.capitalize(), resource_accents[k], 132.0, "%s resource" % k.capitalize())
		if k == RES_ORDER[RES_ORDER.size() - 1]:
			metric["surface"].set("last", true)
		var cell: HBoxContainer = metric["value_row"]
		cell.add_child(_mk_resource_object_icon(k, 32))
		var l := _mk_label("0", 25, FONT_COLOR)
		l.custom_minimum_size = Vector2(54, 0)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_res_labels[k] = l
		cell.add_child(l)
		# Income over the last minute, small beside the stockpile.
		var rate := _top_small(_mk_label("", 12, Color(0.62, 0.92, 0.66)), 12)
		rate.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		_res_rate_labels[k] = rate
		cell.add_child(rate)
		economy_metrics.add_child(metric["surface"])
	panel.add_child(economy_metrics)

	_force_panel = _mk_hud_panel("force", COMMAND_SKY)
	_force_panel.name = "ForceInstrument"
	_force_panel.embedded = true
	_force_panel.add_theme_stylebox_override("panel", rack_inset)
	_force_panel.custom_minimum_size = Vector2(0, TOP_RIBBON_H)
	add_child(_force_panel)

	var force_metrics := HBoxContainer.new()
	force_metrics.add_theme_constant_override("separation", 3)
	force_metrics.alignment = BoxContainer.ALIGNMENT_CENTER
	force_metrics.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Population remains a force metric rather than another resource number.
	var pop_metric := _top_metric_surface("Population", COMMAND_GOLD, 140.0, "Population: current units / population cap")
	var pop_cell: HBoxContainer = pop_metric["value_row"]
	pop_cell.add_child(_mk_force_object_icon("population", 32))
	_pop_label = _mk_label("0/0", 25)
	_pop_label.custom_minimum_size = Vector2(70, 0)
	_pop_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pop_cell.add_child(_pop_label)
	force_metrics.add_child(pop_metric["surface"])

	# Strategic opposition remains visible after transient defeat alerts expire.
	# This reads only the authoritative Commander roster and stays subordinate to
	# the existing resource/population status language.
	var opponent_metric := _top_metric_surface("Opponents", COMMAND_FLAME, 98.0, "Living opposing commanders")
	var opponent_cell: HBoxContainer = opponent_metric["value_row"]
	opponent_cell.add_child(_mk_force_object_icon("opponent", 32))
	_opponent_count_label = _mk_label("0", 25, Color(0.92, 0.84, 0.74))
	_opponent_count_label.name = "OpponentCountLabel"
	_opponent_count_label.custom_minimum_size = Vector2(30, 0)
	_opponent_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	opponent_cell.add_child(_opponent_count_label)
	force_metrics.add_child(opponent_metric["surface"])

	# idle workers: persistent economy awareness in the existing player-status bar.
	# The count is refreshed at the same low rate as resources/population and does
	# not create a toast or world marker for every short worker transition.
	var worker_metric := _top_metric_surface("Idle Workers", COMMAND_MINT, 98.0, "Workers without an active order")
	var worker_cell: HBoxContainer = worker_metric["value_row"]
	worker_cell.add_child(_mk_force_object_icon("worker", 32))
	_idle_worker_label = _mk_label("0", 25, Color(0.82, 0.94, 0.78))
	_idle_worker_label.custom_minimum_size = Vector2(30, 0)
	_idle_worker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	worker_cell.add_child(_idle_worker_label)
	force_metrics.add_child(worker_metric["surface"])
	_make_metric_clickable(worker_metric["surface"], "_select_idle_worker", KeyBinds.fill("Workers without an active order. Click (or press {idle_worker}) to find the next one."))

	# Military awareness sits beside the existing worker awareness, but is kept
	# separate so "Idle 3" can never be mistaken for an idle army count.
	var army_metric := _top_metric_surface("Idle Army", COMMAND_SKY, 98.0, "Military units without an active order")
	army_metric["surface"].set("last", true)
	var army_cell: HBoxContainer = army_metric["value_row"]
	army_cell.add_child(_mk_force_object_icon("army", 32))
	_idle_military_label = _mk_label("0", 25, Color(0.82, 0.9, 1.0))
	_idle_military_label.custom_minimum_size = Vector2(30, 0)
	_idle_military_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	army_cell.add_child(_idle_military_label)
	force_metrics.add_child(army_metric["surface"])
	_make_metric_clickable(army_metric["surface"], "select_idle_army", "Military units without an active order. Click to select them all.")
	_force_panel.add_child(force_metrics)

	_age_panel = _mk_hud_panel("age", COMMAND_GOLD)
	_age_panel.name = "AgeMedallion"
	_age_panel.custom_minimum_size = Vector2(150, TOP_RIBBON_H + 26.0)
	var age_inset := StyleBoxFlat.new()
	age_inset.bg_color = Color.TRANSPARENT
	age_inset.content_margin_left = 12.0
	age_inset.content_margin_right = 12.0
	age_inset.content_margin_top = 6.0
	age_inset.content_margin_bottom = 22.0
	_age_panel.add_theme_stylebox_override("panel", age_inset)
	add_child(_age_panel)
	# Progression is a separate medallion rather than another telemetry column.
	# Plan 420: a pendant hung from the band; the age's name large, its
	# place in the three ages small above it.
	var age_stack := VBoxContainer.new()
	age_stack.add_theme_constant_override("separation", -3)
	age_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	age_stack.mouse_filter = Control.MOUSE_FILTER_STOP
	age_stack.tooltip_text = "The Age of Bronze, first of three. The next Age is opened at your hall."
	_tier_caption = _top_small(_mk_label("AGE  " + String(TIER_COUNTS[1]).to_upper(), 14, Color(0.86, 0.72, 0.46)), 14)
	_tier_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tier_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	age_stack.add_child(_tier_caption)
	# Plan 474: the age name is engraved in the title face, like the banner.
	_tier_label = _mk_title_label(TIER_NAMES[1], 28, Color(0.98, 0.88, 0.55))
	_tier_label.add_theme_color_override("font_outline_color", Color(0.10, 0.06, 0.02, 0.95))
	_tier_label.add_theme_constant_override("outline_size", 5)
	_tier_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	_tier_label.add_theme_constant_override("shadow_offset_y", 2)
	_tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tier_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	age_stack.add_child(_tier_label)
	_age_panel.add_child(age_stack)

	# menu button (top-right corner)
	var menu_btn: Button = HUD_ACTION_SCRIPT.new()
	menu_btn.text = ""
	menu_btn.accent = COMMAND_GOLD
	menu_btn.is_menu = true
	menu_btn.add_theme_font_size_override("font_size", 15)
	menu_btn.add_theme_color_override("font_color", Color(0.98, 0.91, 0.76))
	menu_btn.add_theme_color_override("font_hover_color", Color.WHITE)
	menu_btn.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	menu_btn.add_theme_constant_override("outline_size", 3)
	if _font:
		menu_btn.add_theme_font_override("font", _font)
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		menu_btn.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	_menu_button = menu_btn
	_menu_button.name = "MenuButton"
	menu_btn.custom_minimum_size = Vector2(86, 42)
	menu_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	menu_btn.offset_left = -94.0
	menu_btn.offset_right = 0.0
	menu_btn.offset_top = 0.0
	menu_btn.offset_bottom = TOP_RIBBON_H
	var menu_copy := _top_small(_mk_title_label("MENU", 16, Color(0.98, 0.91, 0.76)), 16)
	menu_copy.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_copy.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	menu_btn.add_child(menu_copy)
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
	# Against several opponents the header counts them and the full line
	# names each; it used to name only the first ("Barrosan vs Lioraen" in a
	# one-against-three stage).
	var short_opponent := _short_people_name(opponent_name)
	if opponents.size() > 1:
		var all_names: Array = []
		for o in opponents:
			var o_race := str(o.get("race", ""))
			all_names.append(str(GameData.RACES.get(o_race, {}).get("name", o_race)).strip_edges())
		opponent_name = ", ".join(all_names)
		short_opponent = "%d Hosts" % opponents.size()
	var full_identity := "%s  vs  %s  •  %s  •  %s" % [player_name, opponent_name, mode_name, map_name]
	var short_identity := "%s  vs  %s" % [_short_people_name(player_name), short_opponent]
	var objective_crest_path := String(COMMAND_CRESTS.get(player_race, ""))
	var objective_has_painted_crest := not objective_crest_path.is_empty() and ResourceLoader.exists(objective_crest_path)
	# Every faction shows a crest: painted art where it exists, a drawn
	# heraldic shield in the faction colour otherwise.
	var objective_has_crest := true
	_objective_panel = _mk_hud_panel("objective", COMMAND_GOLD)
	_objective_panel.name = "MatchObjectiveInstrument"
	_objective_panel.set("objective_has_crest", objective_has_crest)
	_objective_panel.custom_minimum_size = Vector2(360, 96)
	_objective_panel.set("objective_compact_crest", true)
	_objective_panel.minimum_size_changed.connect(_fit_objective_content)
	_objective_panel.resized.connect(_place_objective_alert)
	_objective_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	var objective_inset := StyleBoxFlat.new()
	objective_inset.bg_color = Color.TRANSPARENT
	# Plan 435: a little more air under the last line; the sides stay tight
	# because "Granitborn  vs  Granitborn" needs nearly the whole width.
	objective_inset.content_margin_left = 23.0
	objective_inset.content_margin_right = 20.0
	# A compact heraldic header sits above full-width, live objective/status rows.
	objective_inset.content_margin_top = 8.0
	objective_inset.content_margin_bottom = 13.0
	_objective_panel.add_theme_stylebox_override("panel", objective_inset)
	add_child(_objective_panel)
	var mission_row := HBoxContainer.new()
	mission_row.add_theme_constant_override("separation", 12)
	mission_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var objective_stack := VBoxContainer.new()
	objective_stack.add_theme_constant_override("separation", 2)
	objective_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_objective_panel.add_child(objective_stack)
	objective_stack.add_child(mission_row)
	if not objective_has_painted_crest:
		var drawn_crest := _drawn_faction_crest(player_race, Vector2(50, 52))
		drawn_crest.name = "MatchFactionCrest"
		mission_row.add_child(drawn_crest)
	else:
		var campaign_crest := TextureRect.new()
		campaign_crest.name = "MatchFactionCrest"
		campaign_crest.texture = load(objective_crest_path)
		campaign_crest.custom_minimum_size = Vector2(50, 52)
		campaign_crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		campaign_crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		campaign_crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mission_row.add_child(campaign_crest)
	var mission_stack := VBoxContainer.new()
	mission_stack.add_theme_constant_override("separation", 1)
	mission_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mission_row.add_child(mission_stack)
	# Campaign battles are titled by their chapter, not the map.
	var saga_chapter := CampaignDefs.find(String(Match.get_config().get("campaign_chapter", "")))
	var battlefield_label := _top_small(_mk_label((String(saga_chapter.get("title", "")) if not saga_chapter.is_empty() else map_name).to_upper(), 16, COMMAND_GOLD), 16)
	battlefield_label.name = "MatchBattlefieldLabel"
	battlefield_label.tooltip_text = battlefield_label.text
	battlefield_label.mouse_filter = Control.MOUSE_FILTER_STOP
	battlefield_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	mission_stack.add_child(battlefield_label)
	var identity_label := _mk_title_label(short_identity, 21, Color(0.97, 0.92, 0.80))
	identity_label.name = "MatchIdentityLabel"
	identity_label.tooltip_text = full_identity
	identity_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	identity_label.mouse_filter = Control.MOUSE_FILTER_STOP
	mission_stack.add_child(identity_label)
	var victory_kind := str(identity.get("victory", "conquest")).to_lower()
	var objective_text := "CONQUEST · Destroy buildings and workers" if victory_kind == "conquest" else ("DOMINATION · Hold every Lume site" if victory_kind == "domination" else victory_kind.capitalize())
	var objective_label := _top_small(_mk_label(objective_text, 15, Color(0.91, 0.84, 0.66)), 15)
	objective_label.name = "MatchObjectiveLabel"
	_survival_label = objective_label
	objective_label.tooltip_text = "Destroy every enemy building and worker to win." if victory_kind == "conquest" else ("Hold every Lume site at once for two and a half minutes (the count begins five minutes in), or destroy every enemy building and worker. The enemy can win the same way." if victory_kind == "domination" else objective_text)
	objective_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	objective_label.mouse_filter = Control.MOUSE_FILTER_STOP
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.max_lines_visible = 2
	objective_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Plan 437: each goal hangs from a small bronze ring (Codex composition R2).
	objective_stack.add_child(_objective_bullet_row(objective_label))
	# The bounty stays on the banner with how it stands, not just one alert.
	_bounty_label = _top_small(_mk_label("", 15, Color(0.95, 0.82, 0.5)), 15)
	_bounty_label.name = "MatchBountyLabel"
	_bounty_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_bounty_label.mouse_filter = Control.MOUSE_FILTER_STOP
	_bounty_label.tooltip_text = "Meet the bounty and win for extra spoils and +20% experience."
	_bounty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bounty_label.max_lines_visible = 2
	_bounty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	objective_stack.add_child(_objective_bullet_row(_bounty_label))


func _objective_bullet_row(label: Label) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ring := Control.new()
	ring.name = "ObjectiveRing"
	ring.custom_minimum_size = Vector2(12, 12)
	ring.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Plan 461: the plain rings read as form bullets. Each goal now hangs from
	# a small cut gem: hollow while open, lit and filled once it is done.
	ring.draw.connect(func():
		var c := Vector2(6, 11)
		var d := 5.6
		var gem := PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0), c + Vector2(0, -d)])
		var col: Color = label.get_theme_color("font_color")
		var done := label.text.ends_with("done")
		ring.draw_colored_polygon(gem.slice(0, 4), Color(0.05, 0.04, 0.03, 0.9))
		if done:
			ring.draw_colored_polygon(gem.slice(0, 4), col)
			ring.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d + 1.5), c + Vector2(d - 1.5, 0), c]), Color(1, 1, 0.9, 0.55))
		else:
			ring.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -2.0), c + Vector2(2.0, 0), c + Vector2(0, 2.0), c + Vector2(-2.0, 0)]), Color(col.r, col.g, col.b, 0.75))
		ring.draw_polyline(gem, Color(0.0, 0.0, 0.0, 0.75), 3.0, true)
		ring.draw_polyline(gem, col, 1.4, true))
	label.draw.connect(ring.queue_redraw)
	row.add_child(ring)
	row.add_child(label)
	return row


## First word of a people's name for the compact header, skipping a leading
## article: "The Compaña" read "The" ("Barrosan vs The").
func _short_people_name(full: String) -> String:
	var words := full.split(" ", false)
	if words.size() > 1 and String(words[0]).to_lower() == "the":
		return String(words[1])
	return String(words[0]) if words.size() > 0 else full


func _format_top_resource_amount(amount: int) -> String:
	# Keep ordinary build-order values exact. Very large stocks use a compact
	# reading while the hover surface retains the exact amount.
	if amount < 10000:
		return str(amount)
	if amount < 100000:
		return "%.1fK" % (floori(amount / 100.0) / 10.0)
	if amount < 1000000:
		return "%dK" % floori(amount / 1000.0)
	if amount < 100000000:
		return "%.1fM" % (floori(amount / 100000.0) / 10.0)
	return "%dM" % floori(amount / 1000000.0)


func _set_top_metric_text(label: Label, value: String, base_size: int) -> void:
	# A compact resource instrument must remain truthful once a late-match
	# value grows beyond the three digits visible in the opening capture.
	if label.text == value:
		return
	var font := label.get_theme_font("font")
	var available_width := label.custom_minimum_size.x - 2.0
	var chosen_size := base_size
	while chosen_size > 16 and font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, chosen_size).x > available_width:
		chosen_size -= 1
	if label.get_theme_font_size("font_size") != chosen_size:
		label.add_theme_font_size_override("font_size", chosen_size)
	label.text = value


## Last shown amount per resource, so a change can flash the number.
var _res_last := {}

func _on_resources_changed(res: Dictionary) -> void:
	for k in RES_ORDER:
		if _res_labels.has(k) and is_instance_valid(_res_labels[k]):
			var amount := int(res.get(k, 0))
			var label := _res_labels[k] as Label
			# A gain flashes the number green, a spend flashes it amber.
			if _res_last.has(k) and int(_res_last[k]) != amount:
				var flash := Color(0.6, 1.0, 0.6) if amount > int(_res_last[k]) else Color(1.0, 0.75, 0.45)
				label.self_modulate = flash
				label.create_tween().tween_property(label, "self_modulate", Color.WHITE, 0.45)
			_res_last[k] = amount
			_set_top_metric_text(label, _format_top_resource_amount(amount), 28)
			var metric_surface := label.get_parent().get_parent() as Control
			var per_min: int = _commander.income_per_minute(k) if is_instance_valid(_commander) and _commander.has_method("income_per_minute") else 0
			if _res_rate_labels.has(k) and is_instance_valid(_res_rate_labels[k]):
				(_res_rate_labels[k] as Label).text = ("+%d/m" % per_min) if per_min > 0 else ""
			var exact_readout := "%s: %d  ·  +%d in the last minute" % [k.capitalize(), amount, per_min]
			if metric_surface.tooltip_text != exact_readout:
				metric_surface.tooltip_text = exact_readout
				(metric_surface.get_parent() as Control).tooltip_text = exact_readout


func _on_pop_changed(used: int, cap: int) -> void:
	if is_instance_valid(_pop_label):
		_set_top_metric_text(_pop_label, "%d/%d" % [used, cap], 27)
		_pop_label.add_theme_color_override("font_color",
			Color(0.95, 0.5, 0.45) if used >= cap and cap > 0 else FONT_COLOR)


func _on_tier_changed(tier: int) -> void:
	_card_force_refresh = true   # a new Age unlocks buildings, soldiers and research
	if is_instance_valid(_tier_label):
		_tier_label.text = TIER_NAMES.get(tier, "Age %d" % tier)
	if is_instance_valid(_tier_caption):
		_tier_caption.text = "AGE  " + String(TIER_COUNTS.get(tier, "")).to_upper()
		(_tier_caption.get_parent() as Control).tooltip_text = "The Age of %s, %s of three.%s" % [TIER_NAMES.get(tier, "?"), ["first", "second", "third"][clampi(tier, 1, 3) - 1], " The next Age is opened at your hall." if tier < 3 else ""]


func _refresh_opponent_count() -> void:
	if not is_instance_valid(_opponent_count_label) or not is_instance_valid(world):
		return
	var count := 0
	for i in range(1, world.commanders.size()):
		var cmd = world.commanders[i]
		if is_instance_valid(cmd) and not cmd.defeated:
			count += 1
	_set_top_metric_text(_opponent_count_label, str(count), 27)


# ---------------------------------------------------------------------------
# 2. MINIMAP
# ---------------------------------------------------------------------------
func _build_minimap() -> void:
	var panel := _mk_hud_panel("minimap", Color(0.83, 0.65, 0.35))
	_minimap_panel = panel
	_minimap_panel.name = "MinimapPanel"
	# Give the surveyed place the emphasis; the map itself carries the markers.
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
	var map_name := str(world.map.get("name", "Battlefield")) if is_instance_valid(world) else "Battlefield"
	var title := _mk_label(map_name.to_upper(), 14, Color(0.95, 0.85, 0.55))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	title.add_theme_font_size_override("font_size", 15)
	title.custom_minimum_size = Vector2(0, 24)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	# Plan 421: the how-to line moved into the tooltip; the frame carries the name only.
	var frame_inset := StyleBoxFlat.new()
	frame_inset.bg_color = Color.TRANSPARENT
	frame_inset.content_margin_left = 12.0
	frame_inset.content_margin_right = 12.0
	frame_inset.content_margin_top = 7.0
	frame_inset.content_margin_bottom = 12.0
	panel.add_theme_stylebox_override("panel", frame_inset)
	column.add_theme_constant_override("separation", 7)
	_minimap = Control.new()
	# Plan 435: two short lines, so the tip stays over the map instead of
	# running across the selection portrait.
	_minimap.tooltip_text = "Click: look there\nRight-click: send the selected units"
	_minimap.custom_minimum_size = Vector2(MINIMAP_SIZE, MINIMAP_SIZE)
	_minimap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Camera-footprint sights can extend past the surveyed area near map edges.
	# Keep every map stroke inside the frame's opening.
	_minimap.clip_contents = true
	_minimap.mouse_filter = Control.MOUSE_FILTER_STOP
	_minimap.draw.connect(_draw_minimap)
	_minimap.gui_input.connect(_on_minimap_input)
	column.add_child(_minimap)


func _on_minimap_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_focus_from_minimap(event.position)
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		_focus_from_minimap(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		# Right-click orders the selection across the map, as in the field.
		var size := _minimap.size
		if is_instance_valid(rts) and rts.has_method("issue_minimap_order") and size.x > 0 and size.y > 0:
			var wx: float = (event.position.x / size.x) * (MAP_HALF * 2.0) - MAP_HALF
			var wz: float = (event.position.y / size.y) * (MAP_HALF * 2.0) - MAP_HALF
			rts.issue_minimap_order(Vector3(wx, 0.0, wz))
			_map_pings.append({"pos": Vector3(wx, 0.0, wz), "t": Time.get_ticks_msec(), "col": Color(0.55, 0.9, 1.0)})
			accept_event()


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
		var overview = world.get("overview_texture")
		if overview is Texture2D:
			# The real battlefield, rendered top-down at match start, dimmed a
			# touch so live markers stay the brightest thing on the map.
			_minimap.draw_texture_rect(overview, Rect2(Vector2.ZERO, size), false, Color(0.94, 0.94, 0.91))
		else:
			_ensure_minimap_background()
			if is_instance_valid(_minimap_background):
				_minimap.draw_texture_rect(_minimap_background, Rect2(Vector2.ZERO, size), false)
			else:
				_minimap.draw_rect(Rect2(Vector2.ZERO, size), _minimap_theme_color(str(world.map.get("theme", "highland")), false), true)
			_draw_minimap_terrain(size)
		_draw_minimap_visibility(size)
	var bridge_data = world.map.get("bridge", {})
	if bridge_data is Dictionary and bridge_data.get("pos") is Vector3:
		var bridge_p := _world_to_map(bridge_data["pos"])
		_minimap.draw_line(bridge_p - Vector2(12, 0), bridge_p + Vector2(12, 0), Color(0.04, 0.05, 0.05, 0.95), 10.0, true)
		_minimap.draw_line(bridge_p - Vector2(12, 0), bridge_p + Vector2(12, 0), Color(0.92, 0.72, 0.30, 1.0), 5.0, true)
		_minimap.draw_line(bridge_p - Vector2(9, -3), bridge_p + Vector2(9, -3), Color(0.30, 0.20, 0.10, 0.95), 1.0, true)
		_minimap.draw_line(bridge_p - Vector2(9, 3), bridge_p + Vector2(9, 3), Color(0.30, 0.20, 0.10, 0.95), 1.0, true)
	_draw_minimap_inset(size)
	_draw_minimap_frame(size)

	if not is_instance_valid(world):
		return

	# capture points as diamonds, using the live nodes so ownership remains true.
	for cp in world.get_tree().get_nodes_in_group("capture_points"):
		if not is_instance_valid(cp):
			continue
		var p := _world_to_map(cp.global_position)
		var team_owner := int(cp.owner_team) if "owner_team" in cp else -1
		var hidden_enemy_objective: bool = team_owner >= 0 and is_instance_valid(_commander) \
			and team_owner != _commander.team and world.has_method("is_player_visible") \
			and not world.is_player_visible(cp)
		if hidden_enemy_objective:
			continue
		var col: Color = GameData.TEAM_COLORS.get(team_owner, Color(0.85, 0.85, 0.85)) if team_owner >= 0 else Color(0.85, 0.85, 0.85)
		_minimap_cut_diamond(p, 6.5, col, Color(0.90, 0.72, 0.40))

	# Buildings use a footprint, wall face, and roof notch so structures read
	# differently from units at a glance.
	for b in world.all_buildings():
		if not is_instance_valid(b) or b.is_dead or (world.has_method("is_player_visible") and not world.is_player_visible(b)):
			continue
		var building_def: Dictionary = b.def if b.def is Dictionary else {}
		var is_major := bool(building_def.get("is_hq", false)) or str(building_def.get("kind", "")) == "main"
		var is_enemy: bool = is_instance_valid(_commander) and b.team != _commander.team
		_draw_minimap_building(_world_to_map(b.global_position), GameData.TEAM_COLORS.get(b.team, Color.WHITE), is_major, is_enemy)
		# Landmarks: a star in their people's colour; an enemy's is announced
		# the first time it is seen.
		if building_def.has("landmark") and b.is_built:
			var lp := _world_to_map(b.global_position)
			var lt: Color = b.LANDMARK_TINT.get(String(building_def["landmark"]), Color(1, 0.85, 0.4))
			var star := PackedVector2Array()
			for k in 10:
				var ang := -PI * 0.5 + k * TAU / 10.0
				star.append(lp + Vector2(cos(ang), sin(ang)) * (9.5 if k % 2 == 0 else 4.0))
			_minimap.draw_colored_polygon(star, lt)
			star.append(star[0])
			_minimap.draw_polyline(star, Color(0.02, 0.02, 0.03, 0.9), 1.0, true)
			if is_enemy and not b.has_meta("landmark_seen"):
				b.set_meta("landmark_seen", true)
				_push_alert("The enemy has raised %s." % String(building_def.get("name", "a landmark")), Color(1.0, 0.7, 0.5))
				last_alert_position = b.global_position

	# Live resource landmarks make the miniature useful without inventing a
	# second simulation. Depleted nodes remain absent, matching the world.
	for resource in world.get_tree().get_nodes_in_group("resources"):
		if not is_instance_valid(resource) or bool(resource.get("depleted")) or (world.has_method("is_player_visible") and not world.is_player_visible(resource)):
			continue
		_draw_minimap_resource(_world_to_map(resource.global_position), _minimap_resource_color(str(resource.resource_kind)), str(resource.resource_kind))

	# Veins: a ring in the resource's colour, filled when someone holds it,
	# pulsing gold during a Lume flare.
	for vein in world.get_tree().get_nodes_in_group("veins"):
		if not is_instance_valid(vein) or int(vein.amount) <= 0:
			continue
		var vp := _world_to_map(vein.global_position)
		var vcol := _minimap_resource_color(String(vein.kind))
		var flaring: bool = float(world.get("match_time")) < float(vein.rich_until)
		if flaring:
			var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 180.0)
			_minimap.draw_arc(vp, 8.0 + pulse * 3.0, 0.0, TAU, 20, Color(1.0, 0.85, 0.35, 0.9), 2.0, true)
		# A small pip, not a big ring: twelve rings crowded the whole field.
		# Plan 448: drawn in its store's shape (tree, block, nugget, sheaf).
		_draw_minimap_resource(vp, vcol, String(vein.kind))
		if not vein.is_free():
			_minimap.draw_arc(vp, 4.6, 0.0, TAU, 12, GameData.TEAM_COLORS.get(int(vein.outpost.team), Color.WHITE), 1.4, true)

	# Buried Lume jars: a pulsing violet diamond, always shown (the Lume glow
	# is seen from afar), with a ring filling as someone digs.
	for jar in world.get_tree().get_nodes_in_group("lume_jars"):
		if not is_instance_valid(jar):
			continue
		var jp := _world_to_map(jar.global_position)
		var js := 5.0 + (0.5 + 0.5 * sin(Time.get_ticks_msec() / 220.0)) * 1.5
		var jpts := PackedVector2Array([jp + Vector2(0, -js), jp + Vector2(js, 0), jp + Vector2(0, js), jp + Vector2(-js, 0)])
		_minimap.draw_colored_polygon(jpts, Color(0.1, 0.05, 0.15, 0.8))
		jpts.append(jpts[0])
		_minimap.draw_polyline(jpts, Color(0.8, 0.6, 1.0, 0.95), 1.6, true)
		if float(jar.progress) > 0.0:
			_minimap.draw_arc(jp, js + 3.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(float(jar.progress) / float(jar.OPEN_TIME), 0.0, 1.0), 20, GameData.TEAM_COLORS.get(int(jar.digging_team), Color.WHITE), 2.0, true)

	# Units use role hierarchy while retaining team color as the ownership channel.
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead or (world.has_method("is_player_visible") and not world.is_player_visible(u)):
			continue
		_draw_minimap_unit(
			_world_to_map(u.global_position),
			GameData.TEAM_COLORS.get(u.team, Color.WHITE),
			bool(u.is_worker),
			bool(u.is_hero))

	# Your own hero wears a slow gold pulse, so it is found at a glance.
	if is_instance_valid(_commander) and is_instance_valid(_commander.hero_ref) and not _commander.hero_ref.is_dead:
		var hp_map := _world_to_map(_commander.hero_ref.global_position)
		var beat := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 260.0)
		_minimap.draw_arc(hp_map, 10.0 + beat * 4.0, 0.0, TAU, 24, Color(1.0, 0.85, 0.4, 0.35 + 0.45 * (1.0 - beat)), 1.6, true)

	# While the player's hero is down, a gold ring pulses on the stronghold
	# where the Lume will raise them.
	if is_instance_valid(_commander) and not is_instance_valid(_commander.hero_ref):
		for b in _commander.buildings:
			if is_instance_valid(b) and not b.is_dead and bool(b.def.get("is_hq", false)):
				var hq_p := _world_to_map(b.global_position)
				var pulse := fmod(float(Time.get_ticks_msec()) / 1000.0, 1.4) / 1.4
				_minimap.draw_arc(hq_p, 5.0 + pulse * 9.0, 0.0, TAU, 28, Color(1.0, 0.8, 0.35, 1.0 - pulse), 2.0, true)
				_minimap.draw_circle(hq_p, 3.0, Color(1.0, 0.85, 0.4, 0.95))
				break

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
		_draw_minimap_pings()
		_minimap.draw_colored_polygon(corners, MINIMAP_VIEW_FILL)
		# The true footprint retains its quiet outline, while short corner sights
		# make the currently framed region visible over dark explored terrain.
		_minimap.draw_polyline(corners, Color(0.04, 0.05, 0.05, 0.36), 1.8, false)
		_minimap.draw_polyline(corners, MINIMAP_VIEW_EDGE, 1.5, false)
		for corner_index in 4:
			var corner: Vector2 = corners[corner_index]
			var toward_next: Vector2 = (corners[(corner_index + 1) % 4] - corner).normalized() * 11.0
			var toward_previous: Vector2 = (corners[(corner_index + 3) % 4] - corner).normalized() * 11.0
			for direction in [toward_next, toward_previous]:
				_minimap.draw_line(corner, corner + direction, Color(0.02, 0.03, 0.03, 0.88), 3.0, true)
				_minimap.draw_line(corner, corner + direction, Color(0.98, 0.91, 0.59, 0.90), 1.6, true)


func _draw_minimap_pings() -> void:
	var now := Time.get_ticks_msec()
	for ping in _map_pings.duplicate():
		var age := float(now - int(ping["t"])) / 1000.0
		if age > 6.0:
			_map_pings.erase(ping)
			continue
		var p := _world_to_map(ping["pos"])
		var col: Color = ping["col"]
		for k in 2:
			var phase := fmod(age * 1.3 + k * 0.5, 1.0)
			var c := Color(col.r, col.g, col.b, (1.0 - phase) * (1.0 - age / 6.0))
			_minimap.draw_arc(p, 4.0 + phase * 18.0, 0.0, TAU, 28, c, 2.0, true)
		_minimap.draw_circle(p, 3.0, Color(col.r, col.g, col.b, 1.0 - age / 6.0))

func _draw_minimap_visibility(size: Vector2) -> void:
	if not is_instance_valid(world) or not world.has_method("visibility_grid_contract"):
		return
	var grid: Dictionary = world.visibility_grid_contract()
	var columns := int(grid.get("columns", 0))
	var rows := int(grid.get("rows", 0))
	var states: PackedByteArray = grid.get("states", PackedByteArray())
	if columns <= 0 or rows <= 0 or states.size() != columns * rows:
		return
	# One raster removes the dark seams made by overlapping translucent cells.
	# It still samples the authoritative visibility grid, with no extra scouting.
	if _minimap_fog == null or columns != _minimap_fog_columns or rows != _minimap_fog_rows or states != _minimap_fog_states:
		var fog_image := Image.create(MINIMAP_RASTER_SIZE, MINIMAP_RASTER_SIZE, false, Image.FORMAT_RGBA8)
		for y in MINIMAP_RASTER_SIZE:
			var row := mini(rows - 1, int(float(y) / float(MINIMAP_RASTER_SIZE) * float(rows)))
			for x in MINIMAP_RASTER_SIZE:
				var column := mini(columns - 1, int(float(x) / float(MINIMAP_RASTER_SIZE) * float(columns)))
				var state := int(states[row * columns + column])
				var fog_color := Color.TRANSPARENT
				if state == 0:
					# Lighter than before: the minimap is a real picture of the map now,
					# so unexplored land stays readable as terrain under the shroud.
					fog_color = Color(0.023, 0.034, 0.043, 0.44)
				elif state == 1:
					fog_color = Color(0.038, 0.056, 0.067, 0.13)
				fog_image.set_pixel(x, y, fog_color)
		if _minimap_fog == null:
			_minimap_fog = ImageTexture.create_from_image(fog_image)
		else:
			_minimap_fog.update(fog_image)
		_minimap_fog_states = states
		_minimap_fog_columns = columns
		_minimap_fog_rows = rows
	_minimap.draw_texture_rect(_minimap_fog, Rect2(Vector2.ZERO, size), false)


func _draw_minimap_terrain(size: Vector2) -> void:
	# The cached image is the geographic base. Water and world shelves are read
	# from the same map/world that renders the battlefield; live markers are
	# layered separately below. Avoid synthetic camouflage blobs or a decorative
	# board-game overlay that has no spatial correspondence to the world.
	var water: Dictionary = world.map.get("water", {})
	var overview: Dictionary = world.map.get("overview", {})
	if bool(water.get("enabled", false)) and str(overview.get("water_axis", "north_bay")) != "none":
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
	# Roads are baked into the background at the terrain shader's actual width.

## Plan 448: the map sits recessed in its housing. A soft shade along the
## edges (deeper at the top, where the housing lip overhangs) and a thin lit
## line at the bottom give it depth instead of a flat picture pasted in.
func _draw_minimap_inset(size: Vector2) -> void:
	for i in 7:
		var t := float(i)
		var a := 0.20 * pow(1.0 - t / 7.0, 1.6)
		_minimap.draw_rect(Rect2(0.0, t * 1.5, size.x, 1.5), Color(0.0, 0.0, 0.0, a * 1.3), true)
		_minimap.draw_rect(Rect2(t * 1.5, 0.0, 1.5, size.y), Color(0.0, 0.0, 0.0, a), true)
		_minimap.draw_rect(Rect2(size.x - (t + 1.0) * 1.5, 0.0, 1.5, size.y), Color(0.0, 0.0, 0.0, a), true)
		_minimap.draw_rect(Rect2(0.0, size.y - (t + 1.0) * 1.5, size.x, 1.5), Color(0.0, 0.0, 0.0, a * 0.7), true)
	_minimap.draw_line(Vector2(2.0, size.y - 0.5), Vector2(size.x - 2.0, size.y - 0.5), Color(0.95, 0.80, 0.50, 0.22), 1.0)

func _draw_minimap_frame(size: Vector2) -> void:
	# The forged housing is the frame. A quiet compass mark gives orientation
	# without putting another bright rectangle over the terrain.
	var compass := Vector2(size.x - 19.0, 18.0)
	_minimap.draw_circle(compass, 12.0, Color(0.018, 0.028, 0.033, 0.74))
	_minimap.draw_arc(compass, 10.0, 0.0, TAU, 24, Color(0.88, 0.72, 0.43, 0.54), 1.0, true)
	_minimap.draw_colored_polygon(PackedVector2Array([
		compass + Vector2(0.0, -8.0), compass + Vector2(3.3, 4.0),
		compass, compass + Vector2(-3.3, 4.0)]), Color(0.97, 0.82, 0.52, 0.86))
	_minimap.draw_circle(compass, 1.3, Color(0.04, 0.06, 0.07))

func _draw_minimap_building(p: Vector2, col: Color, is_major: bool = false, is_enemy: bool = false) -> void:
	var radius := 8.0 if is_major else 5.7
	_minimap.draw_circle(p, radius + 1.8, Color(0.02, 0.03, 0.03, 0.9))
	var points: PackedVector2Array
	if is_enemy:
		points = PackedVector2Array([
			p + Vector2(0, -radius), p + Vector2(radius, radius),
			p + Vector2(-radius, radius)])
	else:
		points = PackedVector2Array([
			p + Vector2(0, -radius), p + Vector2(radius, 0),
			p + Vector2(0, radius), p + Vector2(-radius, 0)])
	if not is_enemy:
		_minimap_cut_diamond(p, radius, col.darkened(0.10), col.lightened(0.25))
		if is_major:
			_minimap.draw_rect(Rect2(p - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), col.lightened(0.45), true)
		return
	_minimap.draw_colored_polygon(points, col.darkened(0.20 if is_major else 0.30))
	var outline := PackedVector2Array(points)
	outline.append(points[0])
	_minimap.draw_polyline(outline, col.lightened(0.18), 1.4 if is_major else 0.9, true)
	if is_major and not is_enemy:
		_minimap.draw_rect(Rect2(p - Vector2(2.2, 2.2), Vector2(4.4, 4.4)), col.lightened(0.30), true)
	elif not is_major:
		_minimap.draw_line(p + Vector2(-2.0, 0), p + Vector2(2.0, 0), col.lightened(0.12), 0.8, true)

## Plan 471: a marker cut like a gem. Drop shadow, bezel, four facets lit
## from the top left and a glint, so markers read as objects on the map.
func _minimap_cut_diamond(p: Vector2, r: float, col: Color, rim: Color) -> void:
	var top := p + Vector2(0, -r)
	var right := p + Vector2(r, 0)
	var bottom := p + Vector2(0, r)
	var left := p + Vector2(-r, 0)
	var off := Vector2(1.0, 1.6)
	_minimap.draw_colored_polygon(PackedVector2Array([top + off, right + off, bottom + off, left + off]), Color(0, 0, 0, 0.55))
	var b := r + 1.7
	_minimap.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -b), p + Vector2(b, 0), p + Vector2(0, b), p + Vector2(-b, 0)]), Color(0.05, 0.04, 0.03, 0.95))
	_minimap.draw_colored_polygon(PackedVector2Array([p, left, top]), col.lightened(0.32))
	_minimap.draw_colored_polygon(PackedVector2Array([p, top, right]), col.lightened(0.08))
	_minimap.draw_colored_polygon(PackedVector2Array([p, right, bottom]), col.darkened(0.34))
	_minimap.draw_colored_polygon(PackedVector2Array([p, bottom, left]), col.darkened(0.14))
	_minimap.draw_polyline(PackedVector2Array([top, right, bottom, left, top]), rim, 1.2, true)
	_minimap.draw_circle(p + Vector2(-r * 0.32, -r * 0.30), maxf(0.9, r * 0.14), Color(1, 1, 1, 0.75))

func _draw_minimap_unit(p: Vector2, col: Color, is_worker: bool = false, is_hero: bool = false) -> void:
	# Role shapes make the minimap answer "what is there?" without changing the
	# existing team-color ownership channel or live-unit source.
	var r := 3.6 if is_worker else (7.2 if is_hero else 4.8)
	_minimap.draw_circle(p, r + 1.25, Color(0.02, 0.03, 0.03, 0.86))
	if is_worker:
		_minimap.draw_circle(p, r, col)
		_minimap.draw_arc(p, r, 0.0, TAU, 16, Color(1, 1, 1, 0.68), 0.9, true)
	elif is_hero:
		var hero_points := PackedVector2Array([
			p + Vector2(0, -r), p + Vector2(r * 0.45, -r * 0.45),
			p + Vector2(r, 0), p + Vector2(r * 0.45, r * 0.45),
			p + Vector2(0, r), p + Vector2(-r * 0.45, r * 0.45),
			p + Vector2(-r, 0), p + Vector2(-r * 0.45, -r * 0.45)])
		_minimap.draw_colored_polygon(hero_points, col)
		hero_points.append(hero_points[0])
		_minimap.draw_polyline(hero_points, Color(1, 1, 1, 0.9), 1.15, true)
	else:
		var army_points := PackedVector2Array([
			p + Vector2(0, -r), p + Vector2(r, 0),
			p + Vector2(0, r), p + Vector2(-r, 0)])
		_minimap.draw_colored_polygon(army_points, col)
		army_points.append(army_points[0])
		_minimap.draw_polyline(army_points, Color(1, 1, 1, 0.76), 1.0, true)

func _draw_minimap_resource(p: Vector2, col: Color, kind: String = "") -> void:
	# Plan 448: each store has its own little shape (a tree for timber, a
	# block for stone, a nugget for gold, a round sheaf for food), so a field
	# of resources reads without telling four yellows and greens apart.
	# Plan 462: Codex's painted glyphs (a pine, a grey stone, a gold nugget,
	# a wheat sheaf) replace the flat shapes where they exist.
	var glyph := _minimap_glyph(kind)
	if glyph:
		var gs := 12.0
		_minimap.draw_texture_rect(glyph, Rect2(p - Vector2(gs, gs) * 0.5, Vector2(gs, gs)), false)
		return
	var ink := Color(0.03, 0.04, 0.04, 0.85)
	match kind:
		"timber":
			var tree := PackedVector2Array([p + Vector2(0, -3.6), p + Vector2(3.2, 2.6), p + Vector2(-3.2, 2.6)])
			_minimap.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -5.4), p + Vector2(4.8, 3.8), p + Vector2(-4.8, 3.8)]), ink)
			_minimap.draw_colored_polygon(tree, col)
			_minimap.draw_line(p + Vector2(0, -2.0), p + Vector2(-1.4, 1.4), Color(1, 1, 1, 0.35), 0.8, true)
		"stone":
			_minimap.draw_rect(Rect2(p - Vector2(3.8, 3.4), Vector2(7.6, 6.8)), ink, true)
			_minimap.draw_rect(Rect2(p - Vector2(2.6, 2.2), Vector2(5.2, 4.4)), col, true)
			_minimap.draw_line(p + Vector2(-2.2, -1.8), p + Vector2(2.2, -1.8), Color(1, 1, 1, 0.45), 0.8)
		"gold":
			var d := PackedVector2Array([p + Vector2(0, -3.0), p + Vector2(3.0, 0), p + Vector2(0, 3.0), p + Vector2(-3.0, 0)])
			_minimap.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -4.6), p + Vector2(4.6, 0), p + Vector2(0, 4.6), p + Vector2(-4.6, 0)]), ink)
			_minimap.draw_colored_polygon(d, col)
			_minimap.draw_line(p + Vector2(-1.2, -1.0), p + Vector2(0.4, -2.0), Color(1, 1, 1, 0.7), 0.8, true)
		_:
			_minimap.draw_circle(p, 3.8, ink)
			_minimap.draw_circle(p, 2.5, col)
			_minimap.draw_line(p + Vector2(-1.0, -1.0), p + Vector2(1.0, 1.0), Color(1, 1, 1, 0.48), 0.8, true)


var _minimap_glyphs := {}

func _minimap_glyph(kind: String) -> Texture2D:
	if not _minimap_glyphs.has(kind):
		var path := "res://assets/ui/hud_kit/minimap_glyph_%s.png" % kind
		_minimap_glyphs[kind] = load(path) if kind != "" and ResourceLoader.exists(path) else null
	return _minimap_glyphs[kind]


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
		# The survey matches the sand and red earth of the field itself.
		"desert": return Color(0.56, 0.45, 0.29, 1.0) if not accent else Color(0.68, 0.55, 0.35, 1.0)
		"badlands": return Color(0.48, 0.30, 0.20, 1.0) if not accent else Color(0.60, 0.38, 0.24, 1.0)
		_: return Color(0.31, 0.39, 0.27, 1.0) if not accent else Color(0.39, 0.47, 0.31, 1.0)


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
	var image := Image.create(MINIMAP_BACKGROUND_RASTER_SIZE, MINIMAP_BACKGROUND_RASTER_SIZE, false, Image.FORMAT_RGBA8)
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
	# TerrainBuilder draws these exact start-to-centre paths and middle link.
	# Rasterizing their width makes the miniature read like the battlefield,
	# rather than an unrelated schematic with hairline routes.
	var paths: Array = []
	for start in world.map.get("start_positions", []):
		if start is Vector3:
			paths.append([start, Vector3.ZERO])
	paths.append([Vector3(-30.0, 0.0, -20.0), Vector3(30.0, 0.0, 20.0)])
	# A hand-built map has its own roads, rivers, woods and walls and none of
	# the generated maps' (GameWorld.paint_minimap_terrain paints them below).
	var authored_map := bool(world.map.get("authored", false))
	if authored_map:
		paths.clear()
		water_enabled = false
	var road_color := Color(0.70, 0.53, 0.33) if theme_name == "highland" else base.lightened(0.19)
	var ground_texture: Texture2D = load(MINIMAP_GROUND_TEXTURE) as Texture2D
	var meadow_texture: Texture2D = load(MINIMAP_MEADOW_TEXTURE) as Texture2D
	var snow_texture: Texture2D = load(MINIMAP_SNOW_TEXTURE) as Texture2D if theme_name == "snow" else null
	var has_ground_image: bool = is_instance_valid(ground_texture)
	var has_meadow_image: bool = is_instance_valid(meadow_texture)
	var has_snow_image: bool = is_instance_valid(snow_texture)
	var ground_image: Image = ground_texture.get_image() if has_ground_image else Image.new()
	var meadow_image: Image = meadow_texture.get_image() if has_meadow_image else Image.new()
	var snow_image: Image = snow_texture.get_image() if has_snow_image else Image.new()
	for y in range(MINIMAP_BACKGROUND_RASTER_SIZE):
		for x in range(MINIMAP_BACKGROUND_RASTER_SIZE):
			var wp := Vector3(
				(float(x) / float(MINIMAP_BACKGROUND_RASTER_SIZE - 1) * MAP_HALF * 2.0) - MAP_HALF,
				0.0,
				(float(y) / float(MINIMAP_BACKGROUND_RASTER_SIZE - 1) * MAP_HALF * 2.0) - MAP_HALF)
			# A restrained north-to-south grade gives the miniature depth without
			# inventing random blobs that the player cannot find in the world.
			var latitude := float(y) / float(MINIMAP_BACKGROUND_RASTER_SIZE - 1)
			var col := base.lerp(base.lightened(0.10), 1.0 - absf(latitude - 0.5) * 1.45)
			# Reuse the same authored ground materials as TerrainBuilder. This is a
			# one-time cache build, not a live texture load or a second world render.
			if has_ground_image:
				var tx: int = posmod(int(floor(wp.x * 0.92)), ground_image.get_width())
				var tz: int = posmod(int(floor(wp.z * 0.92)), ground_image.get_height())
				var ground_sample: Color = ground_image.get_pixel(tx, tz)
				if has_meadow_image:
					var meadow_sample: Color = meadow_image.get_pixel(posmod(tx, meadow_image.get_width()), posmod(tz, meadow_image.get_height()))
					ground_sample = ground_sample.lerp(meadow_sample, 0.52 if theme_name == "highland" else 0.36)
				var texture_luma := (ground_sample.r + ground_sample.g + ground_sample.b) / 3.0
				# The world shader grades this texture per biome. Keep its hue only
				# for the highlands; on snow, ash and desert it supplies detail, not
				# an unrelated green cast over the battlefield's actual palette.
				if theme_name == "highland":
					# The world reads as a living meadow at battle zoom. Keep that
					# authored color in its survey rather than flattening it to olive.
					col = col.lerp(ground_sample, 0.46)
				col = col.lightened(clampf((texture_luma - 0.42) * 0.18, -0.05, 0.08))
			if has_snow_image:
				var snow_sample := snow_image.get_pixel(
					posmod(int(floor(wp.x * 0.92)), snow_image.get_width()),
					posmod(int(floor(wp.z * 0.92)), snow_image.get_height()))
				col = col.lerp(snow_sample, 0.52)
			var nearest_path := 1000.0
			for path in paths:
				nearest_path = minf(nearest_path, _minimap_segment_distance(wp, path[0], path[1]))
			if theme_name == "highland" and nearest_path < 15.0:
				var road_shoulder := 1.0 - smoothstep(10.5, 15.0, nearest_path)
				col = col.lerp(Color(0.20, 0.25, 0.17), road_shoulder * 0.34)
			if nearest_path < 12.5:
				var road_weight := 1.0 - smoothstep(7.0, 12.5, nearest_path)
				col = col.lerp(road_color, road_weight * (0.90 if theme_name == "highland" else 0.70))
				if theme_name == "highland":
					var road_crown := 1.0 - smoothstep(3.5, 7.0, nearest_path)
					col = col.lerp(Color(0.83, 0.67, 0.44), road_crown * 0.35)
			var edge := minf(minf(wp.x + MAP_HALF, MAP_HALF - wp.x), minf(wp.z + MAP_HALF, MAP_HALF - wp.z))
			if edge < 10.0:
				col = col.darkened(0.18)
			if water_enabled:
				var distance := _minimap_water_distance(wp, axis, center_z, half_width)
				if distance <= 0.0:
					# Tint the authored water toward the surrounding material so the
					# crossing reads as a world feature rather than a UI stripe.
					var water_tint := deep.lerp(shallow, 0.12 + clampf(absf(wp.x) / MAP_HALF, 0.0, 1.0) * 0.10)
					col = water_tint.lerp(base, 0.06)
				elif distance < 5.0:
					col = shallow.lerp(base, distance / 5.0).lerp(base, 0.08)
			for landform in landforms:
				var center: Vector2 = landform["center"]
				var radius: Vector2 = landform["radius"]
				var local := Vector2(wp.x - center.x, wp.z - center.y).rotated(float(landform.get("rotation", 0.0)))
				var dx := local.x / radius.x
				var dz := local.y / radius.y
				var landform_distance := dx * dx + dz * dz
				if landform_distance < 1.0:
					var shelf_weight := 1.0 - smoothstep(0.70, 1.0, landform_distance)
					col = col.lerp(Color(0.28, 0.31, 0.26, 1.0), shelf_weight * 0.85)
			image.set_pixel(x, y, col)
	if authored_map and world.has_method("paint_minimap_terrain"):
		world.paint_minimap_terrain(image, MAP_HALF)
	_paint_minimap_decor(image, theme_name)
	_minimap_background = ImageTexture.create_from_image(image)
	_minimap_background_key = cache_key

func _paint_minimap_decor(image: Image, theme_name: String) -> void:
	# Scattered scenery already has stable, authored world positions. Its small
	# canopy/stone impressions give the survey geographic texture without
	# introducing invented forests or leaking live tactical entities.
	var decor: Node = world.get_node_or_null("Decor")
	if not is_instance_valid(decor):
		return
	var forest_color := Color(0.18, 0.34, 0.21) if theme_name == "highland" else _minimap_theme_color(theme_name, false).darkened(0.22)
	var stone_color := Color(0.55, 0.54, 0.44) if theme_name == "highland" else _minimap_theme_color(theme_name, true)
	for node in decor.get_children():
		if not node is Node3D:
			continue
		var scene_path: String = node.scene_file_path
		var is_tree := "/vegetation/" in scene_path
		if not is_tree and not "/rocks/" in scene_path:
			continue
		var position_3d: Vector3 = node.global_position
		if absf(position_3d.x) > MAP_HALF or absf(position_3d.z) > MAP_HALF:
			continue
		var center := Vector2(
			(position_3d.x + MAP_HALF) / (MAP_HALF * 2.0) * float(MINIMAP_BACKGROUND_RASTER_SIZE - 1),
			(position_3d.z + MAP_HALF) / (MAP_HALF * 2.0) * float(MINIMAP_BACKGROUND_RASTER_SIZE - 1))
		var decor_scale := float(MINIMAP_BACKGROUND_RASTER_SIZE) / 224.0
		var radius := ((4.1 if theme_name == "highland" else 3.6) if is_tree else 2.3) * decor_scale
		var mark_color: Color = forest_color if is_tree else stone_color
		var strength := (0.69 if theme_name == "highland" else 0.62) if is_tree else 0.43
		for py in range(maxi(0, int(floor(center.y - radius - 1.0))), mini(image.get_height(), int(ceil(center.y + radius + 1.0)))):
			for px in range(maxi(0, int(floor(center.x - radius - 1.0))), mini(image.get_width(), int(ceil(center.x + radius + 1.0)))):
				var distance := Vector2(float(px), float(py)).distance_to(center)
				var coverage := 1.0 - smoothstep(radius - 1.4, radius + 0.5, distance)
				if coverage > 0.0:
					image.set_pixel(px, py, image.get_pixel(px, py).lerp(mark_color, coverage * strength))

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
	# The window size too: resizing a 16:9 window keeps the 1920x1080 canvas
	# but changes how much the panels are boosted.
	var window_size := get_window().size if get_window() else Vector2i.ZERO
	if viewport_size != _last_viewport_size or window_size != _last_window_size:
		_fit_to_viewport()
		_last_viewport_size = viewport_size
		_last_window_size = window_size

	_update_survival_label()
	_update_bounty_label(delta)
	_keep_alert_clear()
	_map_accum += delta
	if _map_accum >= (0.04 if not _map_pings.is_empty() else 0.15):
		_map_accum = 0.0
		if is_instance_valid(_minimap):
			_minimap.queue_redraw()

	_card_poll += delta
	if _card_poll >= 0.3:
		_card_poll = 0.0
		_refresh_card_if_costs_changed()

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
	_set_top_metric_text(_idle_worker_label, str(count), 27)
	_idle_worker_label.add_theme_color_override("font_color",
		Color(0.98, 0.73, 0.36) if count > 0 else Color(0.72, 0.73, 0.68))


func _on_idle_military_count(count: int) -> void:
	if not is_instance_valid(_idle_military_label):
		return
	_set_top_metric_text(_idle_military_label, str(count), 27)
	_idle_military_label.add_theme_color_override("font_color",
		Color(0.98, 0.73, 0.36) if count > 0 else Color(0.72, 0.73, 0.68))


# ---------------------------------------------------------------------------
# 3. SELECTION PANEL
# ---------------------------------------------------------------------------
func _build_selection_panel() -> void:
	_sel_panel = _mk_hud_panel("selection", Color(0.76, 0.62, 0.37))
	_sel_panel.set("embedded", true)
	_sel_panel.name = "SelectionPanel"
	# The plate's cut metal rim is thicker on the right than the shared 10 px
	# margin, so labels and chips sat on the frame at laptop sizes.
	var sel_style := _hud_stylebox()
	sel_style.content_margin_right = 18
	_sel_panel.add_theme_stylebox_override("panel", sel_style)
	_sel_panel.custom_minimum_size = Vector2(SELECTION_PANEL_WIDTH, 200)
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
	_sel_header_spacer = Control.new()
	_sel_header_spacer.custom_minimum_size = Vector2(168, 0)
	_sel_header_spacer.visible = false
	entity_header.add_child(_sel_header_spacer)
	var entity_rule := ColorRect.new()
	entity_rule.custom_minimum_size = Vector2(4, 18)
	entity_rule.color = COMMAND_GOLD
	entity_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entity_header.add_child(entity_rule)
	var entity_title := _mk_label("SELECTED", 11, COMMAND_GOLD)
	entity_title.custom_minimum_size = Vector2(132, 20)
	entity_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	entity_header.add_child(entity_title)
	var entity_hint := _mk_label("", 9, HUD_TEXT_MUTED)
	entity_hint.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
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
	if is_instance_valid(_selection_portrait):
		_selection_portrait.queue_free()
	_selection_portrait = null
	if is_instance_valid(_sel_header_spacer):
		_sel_header_spacer.visible = false
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
	_production_progress_bar = null
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
	if is_instance_valid(_gameover_layer):
		return
	_reset_selection_widgets()
	_clear_children(_sel_body)
	if is_instance_valid(_sel_panel):
		_sel_panel.remove_meta("multi_selection_height")
		_sel_panel.custom_minimum_size.y = 200.0

	# filter to valid
	var valid := []
	for s in sel:
		if is_instance_valid(s) and not (("is_dead" in s) and s.is_dead):
			valid.append(s)

	# A new selection reads its command list from the top: the list kept the
	# place the last selection's list had been scrolled to.
	var was: Array = _card_selection.filter(func(x): return is_instance_valid(x))
	if is_instance_valid(_cmd_scroll) and was != valid:
		_cmd_scroll.scroll_vertical = 0
		_cmd_scroll.set_deferred("scroll_vertical", 0)

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
	if is_instance_valid(_gameover_layer):
		return
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
	var bar: ProgressBar = HUD_VITAL_BAR_SCRIPT.new()
	bar.fill_color = col
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.custom_minimum_size = Vector2(0, 16)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for style_name in ["background", "fill"]:
		bar.add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
	return bar


func _build_single_unit(u, read_only: bool = false) -> void:
	_tracked_single = u
	_single_read_only = read_only
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 13)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_body.add_child(row)

	# The portrait is its own raised instrument, overlapping the selection plate.
	# That breaks the old three-box silhouette without changing selection data.
	var portrait_space := Control.new()
	portrait_space.custom_minimum_size = Vector2(165, 1)
	portrait_space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(portrait_space)
	if is_instance_valid(_sel_header_spacer):
		_sel_header_spacer.visible = true
	var role_accent := Color(1.0, 0.55, 0.45) if read_only else (COMMAND_SKY if u.is_hero else (COMMAND_MINT if u.is_worker else COMMAND_FLAME))
	var portrait_plinth := _mk_hud_panel("portrait", role_accent)
	portrait_plinth.set("embedded", true)
	portrait_plinth.custom_minimum_size = Vector2(175, 232)
	portrait_plinth.size = Vector2(175, 232)
	portrait_plinth.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_selection_portrait = portrait_plinth
	add_child(portrait_plinth)
	var portrait_stack := VBoxContainer.new()
	portrait_stack.add_theme_constant_override("separation", 3)
	portrait_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_plinth.add_child(portrait_stack)
	var portrait_role := "ASCENDANT" if u.is_hero else ("WORKFORCE" if u.is_worker else "WAR HOST")
	# Plan 443: a soldier's or worker's overline names its people (the worker
	# card read WORKFORCE, WORKER and WORKER).
	if not u.is_hero:
		var people := String(GameData.get_race(String(u.def.get("race", ""))).get("name", ""))
		if people != "":
			portrait_role = people.to_upper()
	# Plan 436: the player's own hero wears its earned title here; over the
	# field it goes by its name alone.
	if u.is_hero and is_instance_valid(_commander) and u.commander == _commander and ProfileManager.has_hero():
		var earned := String(ProfileManager.hero().get("title", ""))
		if earned != "":
			portrait_role = earned.to_upper()
	var portrait_overline := _mk_title_label(portrait_role, 11, role_accent.lightened(0.14))
	portrait_overline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_stack.add_child(portrait_overline)
	# Authored UI portrait with an isolated 3D model fallback.
	var portrait: Control
	if ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
		portrait = load(ENTITY_PORTRAIT_SCRIPT).new()
		portrait.custom_minimum_size = Vector2(153, 153)
		portrait_stack.add_child(portrait)
		portrait.configure_entity(u)
	else:
		portrait = _mk_icon(FRAME_PORTRAIT, 150)
		portrait_stack.add_child(portrait)
	var role_word := "WORKER" if u.is_worker else String(UNIT_ROLE_FOOTERS.get(String(u.def.get("role", "")), "WARRIOR"))
	if String(u.unit_id) == "lioraen_thorn_ranger":
		role_word = "RANGER"
	if u.is_hero:
		var hero_race := String(u.def.get("race", ""))
		role_word = "THANE" if hero_race == "barrosan" else ("WARDEN" if hero_race == "lioraen" else ("BINDER" if hero_race == "vorthak" else "HERO"))
	var portrait_footer := _mk_title_label(role_word, 12, Color(0.96, 0.83, 0.58))
	portrait_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_stack.add_child(portrait_footer)
	# A hero's level in this battle (ten per cent health and eight per cent
	# damage a level, half kept if it falls) was told only in passing alerts.
	_single_battle_level_label = null
	if u.is_hero:
		_single_battle_level_label = _mk_label(_battle_level_text(u), 12, Color(1.0, 0.84, 0.42))
		_single_battle_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_single_battle_level_label.tooltip_text = "Battle level: your hero grows up to five levels in a battle from kills made near it, each worth a tenth more health and 8% more damage. A hero that falls comes back with half of that experience."
		portrait_stack.add_child(_single_battle_level_label)
	call_deferred("_fit_to_viewport")

	# info column
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(info)

	var uname: String = u.def.get("name", "Unit")
	var identity_color := Color(1.0, 0.55, 0.45) if read_only else Color(0.95, 0.85, 0.55)
	var role_label := "HERO" if u.is_hero else ("WORKER" if u.is_worker else "MILITARY")
	var identity_header := HBoxContainer.new()
	identity_header.add_theme_constant_override("separation", 6)
	identity_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Give short hero and unit names presence without sacrificing the full names
	# of workers and longer troops in the compact selected-entity column.
	# A hostile is told by the red name, the red badge and the line under the
	# health; a "HOSTILE" prefix cut every enemy's name to its first word.
	# A hero's long title ("O Velho, the Eldest Mask") ended in dots here: this
	# column shows the name before the comma; the command header has it whole.
	var shown_name := uname.get_slice(", ", 0) if uname.length() > 17 else uname
	var identity_font_size := 18 if shown_name.length() <= 13 else (16 if shown_name.length() <= 17 else 14)
	# Plan 475: names are engraved in the title face, like the banner.
	var identity_name := _mk_title_label(shown_name, identity_font_size + 5, identity_color.lightened(0.12))
	identity_name.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.02, 0.95))
	identity_name.add_theme_constant_override("outline_size", 4)
	identity_name.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	identity_name.add_theme_constant_override("shadow_offset_y", 2)
	identity_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity_name.tooltip_text = uname
	_shrink_label_to(identity_name, 126.0, 12)
	_engraved_or_plain(identity_name, identity_font_size, 126.0, 12)
	identity_header.add_child(identity_name)
	identity_header.add_child(_mk_command_badge(role_label, role_accent, 62.0))
	info.add_child(identity_header)
	# A veteran's rank and the name the army gave it, in gold stars.
	var rank := int(u.get("_veterancy")) if u.get("_veterancy") != null else 0
	if rank > 0 and not u.is_worker and not u.is_hero:
		var vet_name := String(u.get("veteran_name")) if u.get("veteran_name") != null else ""
		var stars := "★".repeat(mini(rank, 5)) + (" %d" % rank if rank > 5 else "")
		var vet := _mk_label(stars + ("   “%s”" % vet_name if vet_name != "" else "   Veteran"), 13, Color(1.0, 0.84, 0.42))
		vet.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		info.add_child(vet)
	# A hero carries a mana bar under its health: the heading would push the
	# status line out of the panel, and two bars read as vitals on their own.
	# Plan 426: no VITALS caption; the reading sits inside a taller gauge
	# (the label is kept, hidden, for anything that reads it).
	_single_hp_bar = _mk_bar(Color(0.35, 0.8, 0.35))
	_single_hp_bar.custom_minimum_size = Vector2(0, 22)
	info.add_child(_single_hp_bar)
	_single_hp_text = _mk_label("", 15)
	_single_hp_text.visible = false
	info.add_child(_single_hp_text)

	if not read_only and u.is_hero and u.max_mana > 0.0:
		_single_mana_text = _mk_label("", 13, Color(0.78, 0.86, 1.0))
		_single_mana_text.visible = false
		info.add_child(_single_mana_text)
		_single_mana_bar = _mk_bar(Color(0.35, 0.55, 0.95))
		_single_mana_bar.custom_minimum_size = Vector2(0, 20)
		info.add_child(_single_mana_bar)
	# Plan 442: the hero's battle experience as a slim gold gauge (it was a
	# number under the portrait only).
	_single_xp_bar = null
	if not read_only and u.is_hero:
		_single_xp_bar = _mk_bar(Color(0.93, 0.72, 0.32))
		_single_xp_bar.name = "BattleXpGauge"
		_single_xp_bar.custom_minimum_size = Vector2(0, 20)
		_single_xp_bar.tooltip_text = "Battle experience toward the next level"
		_single_xp_bar.mouse_filter = Control.MOUSE_FILTER_PASS
		info.add_child(_single_xp_bar)
		_single_xp_bar.value = _battle_xp_fraction(u)
		_single_xp_bar.set("caption", _battle_xp_caption(u))

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
		var public_role := _role_name(String(u.def.get("role", "unit")))
		_single_stat_label.text = "Hostile · %s" % public_role

	_refresh_single_live()


func _ability_key_label(id: String) -> String:
	var actions := {"rally": "ability_1", "slam": "ability_2", "charge": "ability_3", "bolt": "ability_4", "heal": "ability_5", "root": "ability_6", "avatar": "ability_7"}
	if id.begins_with("sig_"):
		return KeyBinds.label("ability_sig")
	var slot := int(SkillDefs.get_abilities().get(id, {}).get("slot", 0))
	if slot > 0:
		return KeyBinds.label("ability_p1" if slot == 1 else "ability_p2")
	return KeyBinds.label(String(actions[id])) if actions.has(id) else ""


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


var _single_battle_level_label: Label = null
var _single_xp_bar: ProgressBar = null


func _battle_xp_caption(u) -> String:
	var level := int(u.field_level)
	var steps: Array = u.FIELD_LEVEL_XP
	if level >= steps.size():
		return "Top battle level"
	return "%d / %d xp" % [int(u.field_xp), int(steps[level])]


## Share of the way to the next battle level (1.0 at the top level).
func _battle_xp_fraction(u) -> float:
	var level := int(u.field_level)
	var steps: Array = u.FIELD_LEVEL_XP
	if level >= steps.size():
		return 1.0
	var floor_xp := float(steps[level - 1]) if level >= 1 and level - 1 < steps.size() and float(steps[level - 1]) < float(steps[level]) else 0.0
	return clampf((float(u.field_xp) - floor_xp) / maxf(1.0, float(steps[level]) - floor_xp), 0.0, 1.0)

func _battle_level_text(u) -> String:
	var level := int(u.field_level)
	var steps: Array = u.FIELD_LEVEL_XP
	if level >= steps.size():
		return "Battle level %d" % level
	# One line: at 14 points a second line stood below the portrait plinth.
	# Plan 442: the numbers moved into the experience gauge.
	return "Battle level %d" % level

func _refresh_single_live() -> void:
	var u = _tracked_single
	if u == null:
		return
	if is_instance_valid(_single_battle_level_label) and is_instance_valid(u) and u is Unit and u.is_hero:
		_single_battle_level_label.text = _battle_level_text(u)
		if is_instance_valid(_single_xp_bar):
			_single_xp_bar.value = _battle_xp_fraction(u)
			_single_xp_bar.set("caption", _battle_xp_caption(u))
	if not is_instance_valid(u):
		_rebuild_selection([])
		return
	if (u is Building and u.is_dead) or (u is Unit and u.is_dead and (not u.is_hero or _single_read_only)):
		_rebuild_selection([])
		return
	if is_instance_valid(_single_activity_label) and u is Unit and not _single_read_only:
		_single_activity_label.text = _unit_activity_label(u)
	var unavailable_reason := _hero_unavailable_reason(u) if u is Unit and u.is_hero else ""
	if not unavailable_reason.is_empty():
		for w in _ability_widgets:
			if not is_instance_valid(w["button"]) or not is_instance_valid(w["overlay"]):
				continue
			var unavailable_button: Button = w["button"]
			var unavailable_overlay: Label = w["overlay"]
			if is_instance_valid(unavailable_button):
				unavailable_button.disabled = true
				unavailable_button.set_command_state("LOCKED")
			if is_instance_valid(unavailable_overlay):
				unavailable_overlay.text = unavailable_reason
		return
	if is_instance_valid(_single_hp_bar):
		_single_hp_bar.value = clamp(u.get_hp_ratio(), 0.0, 1.0)
		_single_hp_bar.set("caption", "%d / %d" % [int(max(0.0, u.hp)), int(u.max_hp)])
	if is_instance_valid(_single_hp_text):
		_single_hp_text.text = "HP %d / %d" % [int(max(0.0, u.hp)), int(u.max_hp)]
	if is_instance_valid(_single_mana_bar) and "max_mana" in u and u.max_mana > 0.0:
		_single_mana_bar.value = clamp(u.mana / u.max_mana, 0.0, 1.0)
		_single_mana_bar.set("caption", "%d / %d mana" % [int(maxf(0.0, u.mana)), int(maxf(0.0, u.max_mana))])
	if is_instance_valid(_single_mana_text) and "max_mana" in u:
		_single_mana_text.text = "MANA %d / %d" % [int(maxf(0.0, u.mana)), int(maxf(0.0, u.max_mana))]
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
			stat_label.text = stat_value
			stat_label.tooltip_text = "%s: %s" % [stat["caption"], stat_value]
	if is_instance_valid(_single_stat_label):
		if _single_read_only:
			pass
		elif u is Building:
			pass
		elif u.has_method("cur_dmg"):
			var role: String = u.def.get("role", "")
			_single_stat_label.text = "DMG %s   ARM %s   RNG %.1f   %s" % [
				_compact_combat_stat(u.cur_dmg()), _compact_combat_stat(u.cur_armor()), u.cur_range(), _role_name(role)]
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
		# Check before the typed assignment: putting a freed button into a
		# typed variable is itself a script error, which stopped every spell
		# button's cooldown from updating once the card had been rebuilt.
		if not is_instance_valid(w["button"]) or not is_instance_valid(w["overlay"]):
			continue
		var btn: Button = w["button"]
		var id: String = w["id"]
		var cd: float = float(u.ability_cd.get(id, 0.0)) if "ability_cd" in u else 0.0
		var ab: Dictionary = SkillDefs.get_abilities().get(id, {})
		var mana_ok: bool = ("mana" in u) and u.mana >= float(ab.get("mana", 0))
		var overlay: Label = w["overlay"]
		if cd > 0.05:
			btn.disabled = true
			btn.set_command_state("COOLDOWN")
			if is_instance_valid(overlay):
				overlay.text = "CD %d" % int(ceil(cd))
		else:
			btn.disabled = not mana_ok
			btn.set_command_state("READY" if mana_ok else "LOCKED")
			if is_instance_valid(overlay):
				overlay.text = "READY" if mana_ok else "MANA"
		# Plan 428: a spell tile shows only cooldown seconds or MANA.
		if bool(btn.get("tile")) and is_instance_valid(overlay):
			overlay.text = ("%d" % int(ceil(cd))) if cd > 0.05 else ("" if mana_ok else "MANA")
		# A people spell that is ready glows softly on its card.
		var emblem := btn.get_node_or_null("SpellEmblem") as Control
		if is_instance_valid(emblem):
			if cd <= 0.05 and mana_ok:
				var glow := 0.85 + 0.25 * (0.5 + 0.5 * sin(Time.get_ticks_msec() / 260.0))
				emblem.modulate = Color(glow, glow, glow)
			else:
				emblem.modulate = Color(0.55, 0.55, 0.6)


## Steps a one-line label's type down until its text fits `width`, so a long
## name is shown whole and smaller instead of ending in dots.
## An objective-banner line at its (window-lifted) size, set a little smaller
## when the text is wider than the banner rather than cut.
func _fit_top_line(label: Label, smallest: int) -> void:
	label.add_theme_font_size_override("font_size", roundi(15 * _small_window_boost()))
	if label.autowrap_mode == TextServer.AUTOWRAP_OFF and label.size.x > 40.0:
		_shrink_label_to(label, label.size.x - 4.0, smallest)


## Plan 475: the thin title face is never drawn under 18 px (readable_text.gd
## would swap it for the body face at the shrunken size). A name that only
## fits smaller goes back to the plain face at its old, readable size.
func _engraved_or_plain(label: Label, plain_size: int, width: float, smallest: int) -> void:
	if label.get_theme_font_size("font_size") >= 18:
		return
	if _body_font:
		label.add_theme_font_override("font", _body_font)
	label.add_theme_font_size_override("font_size", plain_size)
	label.add_theme_constant_override("outline_size", 0)
	_shrink_label_to(label, width, smallest)


func _shrink_label_to(label: Label, width: float, smallest: int) -> void:
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")
	var shown := label.text.to_upper() if label.uppercase else label.text
	while font_size > smallest and font.get_string_size(shown, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width:
		font_size -= 1
	label.add_theme_font_size_override("font_size", font_size)


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
	# Six kinds on one line ran off the panel: up to three kinds are named;
	# with more, the two most numerous are named and the rest counted (at the
	# line's readable size, three names and "+3 more" ended in dots).
	var named := 3 if order.size() <= 3 else 2
	if order.size() > 3:
		order.sort_custom(func(a: String, c: String) -> bool: return int(counts[a]) > int(counts[c]))
	var parts: Array[String] = []
	for label in order.slice(0, named):
		parts.append("%s x%d" % [label, int(counts[label])])
	if order.size() > named:
		var rest := 0
		for label in order.slice(named):
			rest += int(counts[label])
		parts.append("+%d more" % rest)
	return " · ".join(parts)


## A unit's role as shown to the player (the data key "antiarmor" read "Antiarmor").
func _role_name(role: String) -> String:
	return String({"antiarmor": "Anti-armor", "melee": "Infantry", "ranged": "Ranged", "defender": "Defender",
		"flanker": "Flanker", "healer": "Healer", "caster": "Caster", "siege": "Siege"}.get(role, role.capitalize()))

func _compact_combat_stat(value: float) -> String:
	var rounded := round(value)
	return str(int(rounded)) if is_equal_approx(value, rounded) else "%.1f" % value


func _build_multi(units: Array) -> void:
	var displayed_count := mini(units.size(), 24)
	# Plan 447: more than twelve faces go eight to a row on smaller cards, so a
	# big army fits the wing (at six a row the third row was cut off under the
	# panel and a bare scroll bar showed).
	var dense := displayed_count > 12
	var columns := 8 if dense else 6
	var row_count := ceili(float(displayed_count) / float(columns))
	# A small formation needs a short selection wing. Dense formations keep the
	# existing scrollable grid and gain height according to their row count.
	if is_instance_valid(_sel_panel):
		if row_count == 1:
			_sel_panel.custom_minimum_size.y = 180.0
			_sel_panel.set_meta("multi_selection_height", 188.0)
		elif row_count == 2:
			# Two rows in the standard height lost the second row's health bars.
			_sel_panel.set_meta("multi_selection_height", 248.0)
		elif row_count > 2:
			_sel_panel.set_meta("multi_selection_height", 52.0 + float(row_count) * 72.0)
		_fit_to_viewport()
	var formation_header := HBoxContainer.new()
	formation_header.custom_minimum_size = Vector2(0, 42)
	formation_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	formation_header.add_theme_constant_override("separation", 9)
	var formation_rule := ColorRect.new()
	formation_rule.custom_minimum_size = Vector2(3, 29)
	formation_rule.color = COMMAND_FLAME
	formation_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	formation_header.add_child(formation_rule)
	var formation_info := VBoxContainer.new()
	formation_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	formation_info.add_theme_constant_override("separation", 0)
	formation_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	formation_info.add_child(_mk_label("%d UNITS SELECTED" % units.size(), 15, FONT_COLOR))
	# The line of kinds ("3 Thornrunner · 2 Rootwarden") names the group, so it
	# is drawn at a readable size (it was 10, 12 px on screen).
	var kinds_label := _mk_label(_selection_type_summary(units), 13, Color(0.80, 0.83, 0.78))
	kinds_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	formation_info.add_child(kinds_label)
	formation_header.add_child(formation_info)
	_sel_body.add_child(formation_header)
	formation_header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 46
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	_sel_body.add_child(scroll)

	var grid := GridContainer.new()
	var expanded_pair := displayed_count <= 2
	grid.columns = 2 if expanded_pair else columns
	grid.add_theme_constant_override("h_separation", 3 if dense else 4)
	grid.add_theme_constant_override("v_separation", 4)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	var shown := 0
	for u in units:
		if shown >= 24:
			break
		if not is_instance_valid(u):
			continue
		var cell: BoxContainer = HBoxContainer.new() if expanded_pair else VBoxContainer.new()
		# On wide screens the six columns have room for whole names
		# ("Seedkeeper" was cut to "Seedkee..." in a 54 px cell).
		# ...but never wider than a sixth of the panel: at 74 the sixth column
		# stood outside it and every sixth soldier's portrait was cut away.
		# (22: with 14-point captions the sixth cell stood 9 px out at 10.)
		var room := floorf((_sel_body.size.x - 5.0 * 4.0 - 22.0) / 6.0)
		var cell_w := clampf(room, 54.0, 74.0) if get_viewport_rect().size.x >= 1800.0 else 54.0
		# One row of faces (up to six) gets taller cards so the wing is not half
		# empty below them (plan 438).
		var tall := row_count == 1 and not expanded_pair
		if dense:
			# The body is unsized while it is built; it is about 380 wide (the
			# selection panel is 410), so eight 44 px cards with 3 px gaps fit.
			cell_w = 44.0
		if tall:
			# The body can still be unsized while it is built; 440 is its width at 1366.
			var body_w := _sel_body.size.x if _sel_body.size.x > 100.0 else 440.0
			cell_w = clampf(floorf((body_w - 5.0 * 4.0 - 22.0) / 6.0), 54.0, 74.0)
		cell.custom_minimum_size = Vector2(157, 78) if expanded_pair else Vector2(cell_w, cell_w + 16.0 if tall else (56.0 if dense else 64.0))
		cell.add_theme_constant_override("separation", 5 if expanded_pair else 1)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# The six-column grid shows faces, not names: a name squeezed into a
		# 54-74 px cell was drawn at 10 to 12 px. The line of kinds above names
		# the group and each card's tooltip names the soldier; the portrait
		# takes the name's room.
		var portrait_size := Vector2(64, 64) if expanded_pair else (Vector2(cell_w, cell_w) if tall else (Vector2(cell_w, 42) if dense else Vector2(minf(cell_w, 62.0), 55)))
		if ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
			var portrait = load(ENTITY_PORTRAIT_SCRIPT).new()
			portrait.custom_minimum_size = portrait_size
			if not expanded_pair:
				portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			cell.add_child(portrait)
			portrait.configure_entity(u)
			# EntityPortraitView restores its full-card minimum during _ready();
			# defer the compact override so 8–20 member groups keep both rows
			# inside the fixed selection panel at narrow and wide viewports.
			portrait.set_deferred("custom_minimum_size", portrait_size)
			portrait.set_deferred("size", portrait_size)
		else:
			cell.add_child(_mk_icon(FRAME_PORTRAIT, 46))
		var details := VBoxContainer.new() if expanded_pair else cell
		if expanded_pair:
			details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			details.add_theme_constant_override("separation", 4)
			cell.add_child(details)
		# Small cards keep the name's last word ("Crag Archer" reads "Archer")
		# rather than cutting it off; the full name is on the tooltip.
		var full_name := str(u.def.get("name", "Unit"))
		var card_name := full_name if expanded_pair else full_name.split(" ")[-1]
		cell.tooltip_text = full_name
		if expanded_pair:
			var nm := _mk_label(("★ " if bool(u.is_hero) else "") + card_name, 13, Color(1.0, 0.85, 0.45) if bool(u.is_hero) else Color(0.9, 0.86, 0.72))
			nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			details.add_child(nm)
		var bar := _mk_bar(Color(0.35, 0.8, 0.35))
		bar.custom_minimum_size = Vector2(70, 10) if expanded_pair else Vector2((cell_w if tall or dense else minf(cell_w, 62.0)) - 4.0, 10)
		if not expanded_pair:
			bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		details.add_child(bar)
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
	# The building dossier is a compact partner to the action deck. Giving it a
	# hero-sized height leaves a large blank slab over the battlefield.
	if is_instance_valid(_sel_panel):
		# 190: the queue line under the status ("Idle") was cut by the frame at 176.
		# A site carries a progress line and its bar under the dossier.
		# A tower's damage, rate and range chips need one more row.
		_sel_panel.custom_minimum_size.y = 218.0 if not b.is_built else (238.0 if b.def.has("tower_dmg") else 190.0)
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
	# The selected structure is the visual anchor of its dossier. At 100 px the
	# authored roof and facade collapsed into a small seal beside empty space.
	identity.custom_minimum_size = Vector2(0, 128)
	identity.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(identity)
	var portrait: Control
	if ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
		portrait = load(ENTITY_PORTRAIT_SCRIPT).new()
		portrait.custom_minimum_size = Vector2(128, 128)
		identity.add_child(portrait)
		# Finished structures use the same authored identity as the construction
		# gallery; unfinished sites keep their live stage preview.
		if b.is_built:
			portrait.configure_definition(_building_portrait_definition(b.def, String(b.building_id)))
		else:
			portrait.configure_entity(b)
	else:
		portrait = _mk_icon(FRAME_PORTRAIT, 128)
		identity.add_child(portrait)
	var identity_info := VBoxContainer.new()
	identity_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity.add_child(identity_info)
	var identity_color := Color(1.0, 0.55, 0.45) if read_only else Color(0.95, 0.85, 0.55)
	var identity_text := String(b.def.get("name", "Building"))
	var building_header := HBoxContainer.new()
	building_header.add_theme_constant_override("separation", 6)
	building_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var building_name := _mk_title_label(identity_text, 23, identity_color.lightened(0.12))
	building_name.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.02, 0.95))
	building_name.add_theme_constant_override("outline_size", 4)
	building_name.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	building_name.add_theme_constant_override("shadow_offset_y", 2)
	building_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	building_header.add_child(building_name)
	# Plan 441: the tag names the building's job ("BUILDING" said nothing and
	# was repeated on the command deck beside it).
	var building_badge_text := _building_role_tag(b.def) if b.is_built else "BUILD SITE"
	var building_badge_color := Color(1.0, 0.55, 0.45) if read_only else Color(0.93, 0.72, 0.32)
	var building_badge_w := maxf(70.0, 9.0 * building_badge_text.length() + 12.0)
	# The name and the tag share one line (168 + 70 before the tags named jobs).
	_shrink_label_to(building_name, 238.0 - building_badge_w, 13)
	_engraved_or_plain(building_name, 18, 238.0 - building_badge_w, 13)
	building_header.add_child(_mk_command_badge(building_badge_text, building_badge_color, building_badge_w))
	identity_info.add_child(building_header)
	_single_hp_bar = _mk_bar(Color(0.35, 0.8, 0.35))
	_single_hp_bar.custom_minimum_size = Vector2(0, 22)
	identity_info.add_child(_single_hp_bar)
	_single_hp_text = _mk_label("", 15)
	_single_hp_text.visible = false
	identity_info.add_child(_single_hp_text)
	if not read_only:
		_single_activity_label = _mk_label(_building_purpose(b.def) if b.is_built else "Under construction", 13, Color(0.82, 0.86, 0.78))
		identity_info.add_child(_single_activity_label)
	if read_only:
		_single_stat_label = _mk_label("Hostile · Built structure", 15, Color(0.88, 0.85, 0.75))
		identity_info.add_child(_single_stat_label)
	# A tower shows what it hits for, how often and how far, like a soldier's
	# card: before, a selected tower showed only its health.
	if b.is_built and b.def.has("tower_dmg"):
		var tower_bonus := float(b.commander.build_flags.get("tower_dmg", 0.0)) if b.commander and "build_flags" in b.commander else 0.0
		var tower_row := HBoxContainer.new()
		tower_row.add_theme_constant_override("separation", 4)
		tower_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_add_stat_chip(tower_row, "DMG", _compact_combat_stat(float(b.def.get("tower_dmg", 20)) * (1.0 + tower_bonus)), "dmg", building_badge_color)
		_add_stat_chip(tower_row, "EVERY", "%.1fs" % float(b.def.get("tower_cd", 1.2)), "rate", building_badge_color)
		_add_stat_chip(tower_row, "RNG", "%d" % roundi(float(b.def.get("tower_range", 18.0))), "range", building_badge_color)
		identity_info.add_child(tower_row)

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
		var cap_b_id: int = cap_b.get_instance_id()
		t.timeout.connect(func():
			var cb = instance_from_id(cap_b_id)
			if is_instance_valid(cb) and is_instance_valid(cap_pb):
				cap_pb.value = clamp(cb.build_progress, 0.0, 1.0)
				if is_instance_valid(cap_label):
					cap_label.text = "Construction progress: %d%%" % roundi(clampf(cb.build_progress, 0.0, 1.0) * 100.0))

	# production queue row (only meaningful when it produces, and only once
	# built: a site's "Idle" queue pushed its progress bar out of the panel;
	# the card is rebuilt when construction completes)
	if not read_only and b.is_built and (not b.def.get("produces", []).is_empty() or not b.def.get("research", []).is_empty() \
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
		# Untrimmed: with the default ellipsis trim the expanding status label
		# squeezed this caption to nothing and a lone "Idle" was left.
		var queue_caption := _mk_label("Queue", 12, Color(0.66, 0.64, 0.58))
		queue_caption.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		queue_row.add_child(queue_caption)
		_production_status_label = _mk_label("Idle", 12, Color(0.95, 0.82, 0.42))
		_production_status_label.custom_minimum_size = Vector2(108, 20)
		_production_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		queue_row.add_child(_production_status_label)
		queue_row.add_child(_queue_container)
		identity_info.add_child(queue_row)
		# One full-width production rail makes active work legible at RTS scale;
		# the tiny per-slot bars remain useful for distinguishing queued orders.
		_production_progress_bar = _mk_bar(Color(0.9, 0.66, 0.28))
		_production_progress_bar.custom_minimum_size = Vector2(0, 16)
		_production_progress_bar.visible = false
		col.add_child(_production_progress_bar)
		# watch production updates
		if b.production_updated.is_connected(_on_production_updated):
			b.production_updated.disconnect(_on_production_updated)
		b.production_updated.connect(_on_production_updated)
		_watched_building = b
		_refresh_queue()

	_refresh_single_live()


## A built structure's job in one or two words, for its card tag.
func _building_role_tag(def: Dictionary) -> String:
	if bool(def.get("vein_outpost", false)):
		return "OUTPOST"
	if bool(def.get("is_hq", false)) or String(def.get("kind", "")) == "main":
		return "MAIN HALL"
	if def.has("tower_dmg"):
		return "DEFENSE"
	if String(def.get("kind", "")) == "house":
		return "HOUSING"
	if not def.get("produces", []).is_empty():
		return "TRAINING"
	if not def.get("research", []).is_empty():
		return "RESEARCH"
	return "STRUCTURE"


## What a built structure does for the player, one short line.
func _building_purpose(def: Dictionary) -> String:
	if bool(def.get("vein_outpost", false)):
		return "Workers inside gather in safety"
	var trains: bool = not def.get("produces", []).is_empty()
	var studies: bool = not def.get("research", []).is_empty() or bool(def.get("is_hq", false)) or String(def.get("kind", "")) == "main"
	if trains and studies:
		return "Trains workers and researches" if bool(def.get("is_hq", false)) or String(def.get("kind", "")) == "main" else "Trains soldiers and researches"
	if trains:
		return "Trains soldiers"
	if studies:
		return "Researches upgrades"
	if String(def.get("kind", "")) == "house":
		return "Houses your people"
	if def.has("tower_dmg"):
		return "Guards the ground around it"
	return "Ready"


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
	var b = _watched_building
	if not is_instance_valid(b):
		_clear_children(_queue_container)
		return
	# Queue slots need a taller dossier than the idle building. Resize only on a
	# state transition so frequent production ticks do not relayout the HUD.
	if is_instance_valid(_sel_panel):
		var queue_height := 220.0 if not b.queue.is_empty() else 190.0
		if not is_equal_approx(_sel_panel.custom_minimum_size.y, queue_height):
			_sel_panel.custom_minimum_size.y = queue_height
			call_deferred("_fit_to_viewport")
	if b.queue.is_empty():
		_clear_children(_queue_container)
		_queue_slot_key = ""
		_production_status_label.text = "Idle"
		if is_instance_valid(_production_progress_bar):
			_production_progress_bar.visible = false
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
	if is_instance_valid(_production_progress_bar):
		_production_progress_bar.value = active_prog
		_production_progress_bar.visible = true
	# "Researching: Weapons 30%" beside two queue slots ended in dots. The row
	# is headed "Queue" and has its bar: the name and the percentage are enough.
	var active_verb := "Training" if active_kind == "unit" else "Researching"
	_production_status_label.text = "%s %d%%" % [active_display, roundi(active_prog * 100.0)]
	_production_status_label.tooltip_text = "%s: %s" % [active_verb, active_name]
	_production_status_label.mouse_filter = Control.MOUSE_FILTER_STOP
	_production_status_label.add_theme_font_size_override("font_size", HUD_TEXT_MIN)
	_shrink_label_to(_production_status_label, 106.0, 9)
	# One slot per run of the same item, so a long queue fits the dossier: two
	# slots, then how many more wait. Each slot is the picture of what it
	# makes (the unit's portrait, a research's glyph) with its count: names
	# squeezed into these slots were drawn at 12 px. Clicking a slot cancels
	# the last item of its run (the one in training keeps its progress).
	# Production ticks only move the active slot's bar; the slots are rebuilt
	# when the queue itself changes (the portraits are small 3D views).
	var key_parts: PackedStringArray = []
	for item in b.queue:
		key_parts.append("%s:%s" % [String(item.get("kind", "unit")), String(item.get("id", ""))])
	var queue_key := "|".join(key_parts)
	if queue_key == _queue_slot_key and _queue_container.get_child_count() > 0:
		if is_instance_valid(_queue_active_bar):
			_queue_active_bar.value = active_prog
		return
	_clear_children(_queue_container)
	_queue_slot_key = queue_key
	_queue_active_bar = null
	var runs: Array = []
	for i in b.queue.size():
		var item: Dictionary = b.queue[i]
		var kind: String = item.get("kind", "unit")
		var iid: String = item.get("id", "")
		if not runs.is_empty() and runs[-1]["kind"] == kind and runs[-1]["id"] == iid:
			runs[-1]["count"] += 1
			runs[-1]["last"] = i
		else:
			runs.append({"kind": kind, "id": iid, "count": 1, "last": i})
	for r in mini(runs.size(), 2):
		var run: Dictionary = runs[r]
		var kind: String = run["kind"]
		var iid: String = run["id"]
		var disp_name: String = GameData.get_unit(iid).get("name", iid) if kind == "unit" else GameData.get_tech(iid).get("name", iid)
		var slot := _mk_button("", 12)
		slot.custom_minimum_size = Vector2(QUEUE_SLOT, QUEUE_SLOT)
		slot.tooltip_text = "%s%s\nClick to cancel one" % [disp_name, " ×%d" % int(run["count"]) if int(run["count"]) > 1 else ""]
		slot.set_meta("cancel_index", int(run["last"]))
		var picture: Control
		if kind == "unit" and iid != "barrosan_worker" and ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
			picture = load(ENTITY_PORTRAIT_SCRIPT).new()
			picture.custom_minimum_size = Vector2(QUEUE_SLOT - 6.0, QUEUE_SLOT - 6.0)
			slot.add_child(picture)
			picture.configure_definition(GameData.get_unit(iid), false)
			# EntityPortraitView restores its card minimum in _ready().
			picture.set_deferred("custom_minimum_size", Vector2(QUEUE_SLOT - 6.0, QUEUE_SLOT - 6.0))
			picture.set_deferred("size", Vector2(QUEUE_SLOT - 6.0, QUEUE_SLOT - 6.0))
		else:
			picture = _mk_command_icon(iid if kind == "unit" else load(COMMAND_GLYPH_SCRIPT).research_kind(iid, GameData.get_tech(iid)), COMMAND_GOLD, QUEUE_SLOT - 6.0)
			slot.add_child(picture)
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		picture.position = Vector2(3, 3)
		picture.size = Vector2(QUEUE_SLOT - 6.0, QUEUE_SLOT - 6.0)
		if int(run["count"]) > 1:
			var count := _mk_label("×%d" % int(run["count"]), HUD_TEXT_MIN, Color(1.0, 0.9, 0.62))
			count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			count.position = Vector2(0, QUEUE_SLOT - 24.0)
			count.size = Vector2(QUEUE_SLOT - 3.0, 18)
			slot.add_child(count)
		var cap_b = b
		var cap_slot := slot
		slot.pressed.connect(func():
			if is_instance_valid(cap_b) and cap_b.has_method("cancel_queue_item") and is_instance_valid(cap_slot):
				_issue_order({"type": "cancel", "target": cap_b, "index": int(cap_slot.get_meta("cancel_index", 0))}))
		# The slot in training carries its progress along the bottom.
		if r == 0:
			var pbar := _mk_bar(Color(0.85, 0.7, 0.3))
			# Fixed top-left anchor: the authored offsets stay authoritative and
			# Godot does not warn about conflicting opposite anchors.
			pbar.set_anchors_preset(Control.PRESET_TOP_LEFT)
			pbar.custom_minimum_size = Vector2(QUEUE_SLOT - 6.0, 5)
			pbar.value = active_prog
			pbar.position = Vector2(3, QUEUE_SLOT - 7.0)
			pbar.size = Vector2(QUEUE_SLOT - 6.0, 5)
			slot.add_child(pbar)
			_queue_active_bar = pbar
		_queue_container.add_child(slot)
	if runs.size() > 2:
		var waiting := 0
		for r in range(2, runs.size()):
			waiting += int(runs[r]["count"])
		_queue_container.add_child(_mk_label("+%d" % waiting, HUD_TEXT_MIN, COMMAND_GOLD))


# ---------------------------------------------------------------------------
# 4. COMMAND CARD (bottom-right)
# ---------------------------------------------------------------------------
func _build_command_chassis() -> void:
	_command_chassis = HUD_CHASSIS_SCRIPT.new()
	_command_chassis.name = "BarrosanCommandChassis"
	_command_chassis.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_command_chassis.visible = false
	add_child(_command_chassis)
	_command_chassis.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(_command_chassis, 0)


func _build_command_panel() -> void:
	_cmd_panel = _mk_hud_panel("command", Color(0.83, 0.62, 0.31))
	_cmd_panel.set("embedded", true)
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

	var deck_layout := VBoxContainer.new()
	deck_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	deck_layout.add_theme_constant_override("separation", 6)
	_cmd_panel.add_child(deck_layout)

	_cmd_fixed = VBoxContainer.new()
	_cmd_fixed.name = "CommandFixedHeader"
	_cmd_fixed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cmd_fixed.add_theme_constant_override("separation", 6)
	deck_layout.add_child(_cmd_fixed)

	var scroll := ScrollContainer.new()
	scroll.name = "CommandScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	deck_layout.add_child(scroll)
	scroll.gui_input.connect(_consume_hud_wheel)
	_cmd_scroll = scroll

	_cmd_body = VBoxContainer.new()
	_cmd_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cmd_body.add_theme_constant_override("separation", 6)
	scroll.add_child(_cmd_body)
	_cmd_panel.visible = false

	_command_tooltip = HUD_COMMAND_TOOLTIP_SCRIPT.new()
	_command_tooltip.name = "CommandTooltip"
	_command_tooltip.visible = false
	_command_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_command_tooltip.custom_minimum_size = Vector2(420, 0)
	var tooltip_style := StyleBoxFlat.new()
	tooltip_style.bg_color = Color.TRANSPARENT
	tooltip_style.content_margin_left = 20.0
	tooltip_style.content_margin_right = 20.0
	tooltip_style.content_margin_top = 13.0
	tooltip_style.content_margin_bottom = 12.0
	_command_tooltip.add_theme_stylebox_override("panel", tooltip_style)
	add_child(_command_tooltip)
	_command_tooltip.resized.connect(func(): _layout_command_feedback.call_deferred())


func _consume_hud_wheel(event: InputEvent) -> void:
	# Scrollable HUD surfaces must terminate wheel input before the world
	# controller's _unhandled_input can interpret it as camera zoom. This is
	# event-driven and preserves the camera's existing behavior elsewhere.
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT, MOUSE_BUTTON_WHEEL_RIGHT]:
		get_viewport().set_input_as_handled()


func _show_command_tooltip(title: String, kind: String, hotkey: String, tooltip: String, disabled_reason: String, accent: Color) -> void:
	if not is_instance_valid(_command_tooltip) or not is_instance_valid(_cmd_panel):
		return
	# Taken out at once, not only queued for freeing: a child still inside
	# keeps the plate at the height of the last, longer tooltip.
	for old_child in _command_tooltip.get_children():
		_command_tooltip.remove_child(old_child)
		old_child.queue_free()
	_command_tooltip.set("accent", accent)
	_command_tooltip.queue_redraw()
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 7)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tooltip_title := _mk_title_label(title, 20, FONT_COLOR)
	tooltip_title.custom_minimum_size = Vector2(144, 28)
	tooltip_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(tooltip_title)
	var kind_label := _mk_label(kind, 14, accent)
	kind_label.custom_minimum_size = Vector2(78, 25)
	kind_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	kind_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(kind_label)
	if not hotkey.is_empty():
		header.add_child(_mk_command_keycap(hotkey, accent))
	stack.add_child(header)
	var rule := HSeparator.new()
	rule.modulate = Color(accent.r, accent.g, accent.b, 0.72)
	stack.add_child(rule)
	var body_text := tooltip.strip_edges()
	var first_line := body_text.get_slice("\n", 0).strip_edges()
	if first_line.to_lower() == title.to_lower():
		body_text = body_text.substr(first_line.length()).strip_edges()
	# "Attack-move: march to..." under the heading ATTACK MOVE says it twice.
	var lead := body_text.get_slice(":", 0)
	if body_text.contains(":") and lead.replace("-", " ").to_lower() == title.to_lower():
		body_text = body_text.substr(lead.length() + 1).strip_edges()
		body_text = body_text.left(1).to_upper() + body_text.substr(1)
	var body := _mk_label(body_text, 17, Color(0.91, 0.90, 0.84))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	body.custom_minimum_size = Vector2(376, 0)
	body.add_theme_constant_override("line_spacing", 3)
	stack.add_child(body)
	if not disabled_reason.is_empty():
		# Why the card cannot be used, set apart in the colour of a warning.
		var blocked := _mk_label(disabled_reason, 16, Color(0.96, 0.60, 0.42))
		blocked.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		blocked.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		blocked.clip_text = false
		blocked.custom_minimum_size = Vector2(376, 0)
		stack.add_child(blocked)
	_command_tooltip.add_child(stack)
	_command_tooltip.visible = true
	_place_command_tooltip()
	# Once more when the wrapped lines have their real heights.
	_place_command_tooltip.call_deferred()


## The result plate is drawn at the HUD panels' scale (1.2, more on a
## laptop window), so its ledger is as readable as they are, but never
## taller or wider than the screen. Its ledger text was 14 px at 1920 and
## 10 px on a 1366x768 window.
func _fit_result_plate(plate: Control) -> void:
	if not is_instance_valid(plate):
		return
	await get_tree().process_frame
	if not is_instance_valid(plate) or plate.size.y <= 0.0:
		return
	var vp := get_viewport_rect().size
	var s := minf(_panel_scale, minf((vp.y - 40.0) / plate.size.y, (vp.x - 40.0) / plate.size.x))
	plate.pivot_offset = plate.size * 0.5
	plate.scale = Vector2.ONE * maxf(1.0, s)
	# The battle's instruments step aside for the result, so the plate can
	# use the whole height and no dimmed figure shows through around it.
	var hide_after := get_tree().create_timer(maxf(0.0, _result_hold + 0.25))
	hide_after.timeout.connect(_hide_battle_chrome)


func _hide_battle_chrome() -> void:
	for panel in [_top_ribbon, _top_panel, _force_panel, _age_panel, _objective_panel, _menu_button, _alert_box, _minimap_panel, _sel_panel, _cmd_panel, _command_chassis, _command_tooltip]:
		if is_instance_valid(panel):
			(panel as CanvasItem).visible = false


func _place_command_tooltip() -> void:
	_layout_command_feedback()


func _layout_command_feedback() -> void:
	var viewport_size := get_viewport_rect().size
	var occupied: Array[Rect2] = []
	var chassis_visible := is_instance_valid(_command_chassis) and _command_chassis.is_visible_in_tree()
	for panel in [_top_ribbon, _top_panel, _force_panel, _age_panel, _objective_panel,
		_menu_button, _alert_box, _minimap_panel, _sel_panel,
		_selection_portrait, _cmd_panel, _resource_tooltip]:
		if is_instance_valid(panel) and panel.is_visible_in_tree():
			var occupied_rect: Rect2 = panel.get_global_rect()
			if chassis_visible and panel in [_sel_panel, _selection_portrait, _cmd_panel]:
				# The forged body extends beyond its content controls: up to
				# 13 px at the command join and 11 px for the bottom shadow.
				# Reserve the painted housing before the layout helper adds
				# its 10 px gap, without reserving the full-screen chassis Control.
				occupied_rect = occupied_rect.grow(14.0)
			occupied.append(occupied_rect)
	var annotations: Array[Control] = []
	if is_instance_valid(_command_tooltip) and _command_tooltip.visible:
		annotations.append(_command_tooltip)
	for child in get_children():
		if child is Control and child.has_meta("command_notice") and child.visible and not child.is_queued_for_deletion():
			annotations.append(child)
	for annotation in annotations:
		annotation.reset_size()
		annotation.scale = Vector2.ONE * _panel_scale
		var measured := annotation.size * _panel_scale
		var preferred := Vector2((viewport_size.x - measured.x) * 0.5, viewport_size.y - measured.y - 24.0)
		if is_instance_valid(_cmd_panel) and _cmd_panel.visible:
			var deck := _cmd_panel.get_global_rect()
			preferred = Vector2(deck.position.x + 8.0, deck.position.y - measured.y - 12.0)
		annotation.position = HUD_FEEDBACK_LAYOUT.place(measured, preferred, viewport_size, occupied)
		occupied.append(annotation.get_global_rect())


## What a soldier is for, in two short lines under its description: what its
## blows are good and poor against (from the damage table, so it cannot drift
## from the rules), what it wears, its reach and how long it takes to train.
func _unit_tooltip(udef: Dictionary) -> String:
	var text := String(udef.get("desc", ""))
	var seconds := int(round(float(udef.get("build_time", 0))))
	var role := String(udef.get("role", ""))
	if role == "worker":
		return text + ("\nGathers and builds · trains in %d s" % seconds if seconds > 0 else "")
	var class_names := {"unarmored": "unarmoured troops", "light": "light armor", "medium": "medium armor", "heavy": "heavy armor", "fortified": "buildings"}
	var dmg_type := String(udef.get("dmg_type", ""))
	if GameData.DAMAGE_TABLE.has(dmg_type):
		var strong: Array = []
		var weak: Array = []
		for armor_class in GameData.ARMOR_CLASSES:
			var mult := float(GameData.DAMAGE_TABLE[dmg_type].get(armor_class, 1.0))
			if mult >= 1.15:
				strong.append(class_names[armor_class])
			elif mult <= 0.75:
				weak.append(class_names[armor_class])
		var line := "%s damage" % dmg_type.capitalize()
		if not strong.is_empty():
			line += ": strong against %s" % " and ".join(strong)
		if not weak.is_empty():
			line += ("; weak against %s" if not strong.is_empty() else ": weak against %s") % " and ".join(weak)
		text += "\n" + line.replace("medium armor and heavy armor", "medium and heavy armor") + "."
	var facts: Array = []
	if float(udef.get("heal", 0.0)) > 0.0:
		facts.append("Heals allies")
	var wears := "%s armor" % String(udef.get("armor_class", "light")).replace("unarmored", "no")
	facts.append(wears if not facts.is_empty() else wears.left(1).to_upper() + wears.substr(1))
	facts.append("reach %d" % int(round(float(udef.get("range", 0.0)))) if float(udef.get("range", 0.0)) > 3.0 else "melee")
	if seconds > 0:
		facts.append("trains in %d s" % seconds)
	return text + "\n" + " · ".join(facts)


func _hide_command_tooltip() -> void:
	if is_instance_valid(_command_tooltip):
		_command_tooltip.visible = false
		_layout_command_feedback()


func _watch_cost(cost: Dictionary, was_available: bool, pop_definition: Dictionary = {}) -> void:
	_card_watch.append([cost, was_available, pop_definition])

func _refresh_card_if_costs_changed() -> void:
	if not is_instance_valid(_commander) or not is_instance_valid(_cmd_panel) or not _cmd_panel.visible:
		return
	# Never swap the buttons out from under a click in progress.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	var changed := _card_force_refresh
	for w in _card_watch:
		var pop_def: Dictionary = w[2]
		var ok: bool = _commander.can_afford(w[0]) and (pop_def.is_empty() or _commander.has_pop_for(pop_def))
		if ok != bool(w[1]):
			changed = true
			break
	if not changed:
		return
	_card_force_refresh = false
	var keep_scroll := _cmd_scroll.scroll_vertical if is_instance_valid(_cmd_scroll) else 0
	var still_selected: Array = _card_selection.filter(func(x): return is_instance_valid(x))
	_rebuild_command_card(_card_single if is_instance_valid(_card_single) else null, still_selected)
	if is_instance_valid(_cmd_scroll):
		_cmd_scroll.set_deferred("scroll_vertical", keep_scroll)

func _rebuild_command_card(single, selection: Array) -> void:
	_card_single = single
	_card_selection = selection.duplicate()
	_card_watch.clear()
	# The hero's card lists its spell buttons afresh every time it is built.
	var kept_widgets := []
	for w in _ability_widgets:
		var wb = w["button"]
		if not is_instance_valid(wb):
			continue
		if (is_instance_valid(_cmd_body) and _cmd_body.is_ancestor_of(wb)) or (is_instance_valid(_cmd_fixed) and _cmd_fixed.is_ancestor_of(wb)):
			continue
		kept_widgets.append(w)
	_ability_widgets = kept_widgets
	_hide_command_tooltip()
	_clear_children(_cmd_fixed)
	_clear_children(_cmd_body)
	if is_instance_valid(_inspection_target):
		_cmd_panel.visible = false
		_fit_command_panel_next_frame()
		return
	if not is_instance_valid(_commander):
		_cmd_panel.visible = false
		_fit_command_panel_next_frame()
		return
	_add_command_context(single, selection)

	# WORKER -> build menu. A group of workers gets it too: selecting three
	# workers used to show no command card at all.
	var all_workers := not selection.is_empty()
	for item in selection:
		if not (item is Unit) or not item.is_worker or item.is_dead:
			all_workers = false
			break
	if (single != null and single is Unit and single.is_worker) or all_workers:
		_build_worker_card()
		_cmd_panel.visible = _cmd_body.get_child_count() > 0
		_fit_command_panel_next_frame()
		return

	# BUILDING -> production / research
	if single != null and single is Building:
		_build_building_card(single)
		_cmd_panel.visible = _cmd_body.get_child_count() > 0
		_fit_command_panel_next_frame()
		return

	# HERO -> abilities first, then the same combat orders used by military units.
	# Keeping this in the command deck makes the authored Q/T/E/R actions visible at
	# the moment the player selects the hero instead of burying them below the
	# selection portrait's fixed-height information surface.
	if single != null and single is Unit and single.is_hero:
		_build_hero_command_card(single)
		_cmd_panel.visible = _cmd_body.get_child_count() > 0
		_fit_command_panel_next_frame()
		return

	var has_military := false
	for item in selection:
		if item is Unit and not item.is_worker and not item.is_dead and not item._is_defeated_remnant():
			has_military = true
			break
	if has_military:
		_build_military_card()
		_cmd_panel.visible = _cmd_body.get_child_count() > 0
		_fit_command_panel_next_frame()
		return

	_cmd_panel.visible = false
	_fit_command_panel_next_frame()


func _add_command_context(single, selection: Array) -> void:
	var title := "COMMAND DECK"
	var subtitle := "Select a unit to issue orders."
	var role := "READY"
	var accent := COMMAND_GOLD
	if single != null and single is Unit:
		title = String(single.def.get("name", "Unit"))
		role = "HERO" if single.is_hero else ("WORKER" if single.is_worker else "MILITARY")
		subtitle = "RMB move/gather · click to build" if single.is_worker else "RMB move/attack · use commands below"
		accent = COMMAND_SKY if single.is_hero else (COMMAND_MINT if single.is_worker else COMMAND_FLAME)
	elif single != null and single is Building:
		title = String(single.def.get("name", "Building"))
		role = "BUILDING" if single.is_built else "BUILD SITE"
		var trains: bool = not single.def.get("produces", []).is_empty()
		var studies: bool = not single.def.get("research", []).is_empty() or bool(single.def.get("is_hq", false)) or String(single.def.get("kind", "")) == "main"
		var idle_work := "Houses your people" if String(single.def.get("kind", "")) == "house" else ("Guards the ground around it" if single.def.has("tower_dmg") else "Ready")
		var work := "Training and research" if trains and studies else ("Research" if studies else ("Training" if trains else idle_work))
		subtitle = ("Workers inside gather in safety" if bool(single.def.get("vein_outpost", false)) else work) if single.is_built else "Construction underway"
		accent = COMMAND_GOLD
	elif not selection.is_empty():
		title = "%d UNITS SELECTED" % selection.size()
		role = "SQUAD"
		subtitle = "RMB move/attack · shared orders"
		accent = COMMAND_FLAME
		if selection.all(func(x): return x is Unit and x.is_worker):
			role = "WORKFORCE"
			subtitle = "RMB move/gather · click to build"
			accent = COMMAND_MINT
	var header := PanelContainer.new()
	header.name = "CommandDeckHeader"
	header.mouse_filter = Control.MOUSE_FILTER_STOP
	header.tooltip_text = title + "\n" + subtitle
	header.custom_minimum_size = Vector2(0, 36)
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = Color(0.035, 0.05, 0.055, 0.31)
	header_style.border_color = Color(accent.r, accent.g, accent.b, 0.40)
	header_style.border_width_bottom = 1
	header_style.content_margin_left = 2
	header_style.content_margin_right = 3
	header_style.content_margin_top = 3
	header_style.content_margin_bottom = 3
	header.add_theme_stylebox_override("panel", header_style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var command_crest_path := String(COMMAND_CRESTS.get(str(_commander.race), "")) if is_instance_valid(_commander) else ""
	if not command_crest_path.is_empty() and ResourceLoader.exists(command_crest_path):
		var crest := TextureRect.new()
		crest.name = "CommandFactionCrest"
		crest.texture = load(command_crest_path)
		crest.custom_minimum_size = Vector2(26, 26)
		crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(crest)
	else:
		var marker := _mk_command_badge(_command_glyph(role), accent, 25.0)
		marker.custom_minimum_size = Vector2(25, 25)
		row.add_child(marker)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 0)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(_mk_title_label("FIELD COMMANDS" if role in ["HERO", "MILITARY", "SQUAD"] else ("BUILD & GATHER" if role in ["WORKER", "WORKFORCE"] else "SETTLEMENT"), 20, FONT_COLOR))
	row.add_child(info)
	# Plans 441-442: one selected unit or building is tagged on its card beside
	# this deck, so the deck does not repeat it.
	if single == null:
		var role_badge := _mk_command_badge(role, accent, 59.0)
		role_badge.custom_minimum_size = Vector2(59, 22)
		row.add_child(role_badge)
	header.add_child(row)
	_cmd_fixed.add_child(header)


## Plan 439: hints are "KEY|What it does" pairs drawn as a forged keycap and
## a plain sentence ("RMB  RALLY / CHOOSE WORKSPACE" read like a debug strip).
## A hint with no key is a quiet note.
func _add_context_hints(hints: Array[String]) -> void:
	var row := HBoxContainer.new()
	row.name = "ContextHints"
	row.custom_minimum_size = Vector2(0, 26)
	row.add_theme_constant_override("separation", 18)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for hint in hints:
		var parts := hint.split("|")
		var key := parts[0] if parts.size() > 1 else ""
		var words := parts[parts.size() - 1]
		var pair := HBoxContainer.new()
		pair.add_theme_constant_override("separation", 6)
		pair.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not key.is_empty():
			var cap := _mk_command_keycap(key, COMMAND_GOLD)
			cap.custom_minimum_size = Vector2(maxf(29.0, 10.0 + 9.0 * key.length()), 22)
			cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			pair.add_child(cap)
		var label := _mk_label(words, 14, Color(0.80, 0.82, 0.78))
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		# A trimming label asks for no width, so the box gave it none.
		label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		pair.add_child(label)
		row.add_child(pair)
	_cmd_fixed.add_child(row)


func _building_portrait_definition(bdef: Dictionary, building_id: String) -> Dictionary:
	var visual_definition := bdef.duplicate()
	if BARROSAN_BUILD_ART.has(building_id):
		visual_definition["command_art"] = BARROSAN_BUILD_ART[building_id]
	elif LIORAEN_BUILD_ART.has(building_id):
		visual_definition["command_art"] = LIORAEN_BUILD_ART[building_id]
	elif GRANITBORN_BUILD_ART.has(building_id):
		visual_definition["command_art"] = GRANITBORN_BUILD_ART[building_id]
	return visual_definition


func _build_worker_card() -> void:
	_add_command_section("Build", "Choose a structure.")
	var build_buttons: Array[Button] = []
	var build_definitions: Array[Dictionary] = []
	for bid in GameData.buildings_for_race(_commander.race):
		var bdef := GameData.get_building(bid)
		if bdef.is_empty():
			continue
		var cost: Dictionary = bdef.get("cost", {})
		var affordable: bool = _commander.can_afford(cost)
		_watch_cost(cost, affordable)
		var reason: String = ""
		if not affordable:
			reason = _commander.missing_resource_summary(cost)
		# Landmarks wait for their Age and stand once per player.
		if int(_commander.tier) < int(bdef.get("min_tier", 1)):
			reason = "Requires the Age of Iron" if int(bdef.get("min_tier", 1)) == 2 else "Requires the Age of Lume"
			affordable = false
		elif bool(bdef.get("unique", false)):
			for ob in _commander.buildings:
				if is_instance_valid(ob) and not ob.is_dead and String(ob.building_id) == String(bid):
					reason = "Already raised"
					affordable = false
		# The gallery shows the full structure, name, cost and readiness at once.
		var build_detail := _cost_string(cost).trim_prefix("  (").trim_suffix(")")
		# Keep the scan line actionable; secondary effects remain in the tooltip.
		var tooltip_detail := str(bdef.get("desc", ""))
		var grants_pop := int(bdef.get("grants_pop", 0))
		if grants_pop > 0:
			tooltip_detail += "\nProvides: +%d population" % grants_pop
		if float(bdef.get("tower_dmg", 0.0)) > 0.0:
			tooltip_detail += "\nShoots %s for %d, reach %d" % [String(bdef.get("tower_type", "pierce")), int(bdef.get("tower_dmg", 0)), int(round(float(bdef.get("tower_range", 0.0))))]
		if float(bdef.get("build_time", 0.0)) > 0.0:
			tooltip_detail += "\nOne worker raises it in %d s" % int(round(float(bdef.get("build_time", 0.0))))
		var preview_definition := _building_portrait_definition(bdef, String(bid))
		# Plan 432: a square tile like the train and order decks. The full
		# structure is the art; name, cost, purpose and lock reason are in
		# the anchored tooltip.
		var build_tip := "Cost: %s
%s" % [build_detail, tooltip_detail]
		var btn := _mk_command_tile(str(bdef.get("name", bid)), build_tip, "LOCKED" if not affordable else "READY", "", "BUILD", reason)
		btn.set_meta("build_detail", build_detail)
		btn.set_meta("construction_name", str(bdef.get("name", bid)))
		if ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
			var build_art = load(ENTITY_PORTRAIT_SCRIPT).new()
			build_art.name = "BuildingPreview"
			_tile_set_art(btn, build_art)
			build_art.configure_definition(preview_definition)
			build_art.ready.connect(_seat_crafted_build_preview.bind(build_art, not affordable), CONNECT_ONE_SHOT)
		(btn.get_meta("command_status_label") as Label).text = ""
		btn.disabled = not affordable
		var cap_id := String(bid)
		btn.pressed.connect(func():
			if is_instance_valid(rts) and rts.has_method("enter_build_mode"):
				rts.enter_build_mode(cap_id))
		build_buttons.append(btn)
		build_definitions.append(bdef)
	var gallery := _add_field_order_grid()
	gallery.name = "BuildGallery"
	gallery.columns = 5
	for build_button in build_buttons:
		gallery.add_child(build_button)


func _build_hero_command_card(u) -> void:
	if not u.abilities.is_empty():
		_add_command_section("Abilities", "Cast when ready.")
		# Plan 428: spells are square tiles in one row, like the field orders.
		var ability_grid := _add_field_order_grid()
		ability_grid.columns = 5
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
			var btn := _mk_command_tile(String(ab.get("name", cap_id)), "%s\n%s\nMana %d · cooldown %d s" % [ab.get("name", cap_id), ab.get("desc", ""), mana_cost, int(round(cooldown))], state, key_label, "ABILITY", reason)
			btn.disabled = not ready
			# People and signature spells wear their own emblem: the people's
			# sigil in the spell's colour, marked by what the spell does.
			if ab.has("tint") or bool(ab.get("sig", false)) or SIGNATURE_GLYPHS.has(cap_id):
				var old_glyph := btn.get_node_or_null("CommandEmblem")
				if old_glyph:
					btn.remove_child(old_glyph)
					old_glyph.queue_free()
				var spell_art := _spell_emblem(ab, String(u.commander.race) if u.commander else "", String(cap_id))
				spell_art.position = Vector2(9, 9)
				spell_art.size = Vector2(COMMAND_TILE - 18.0, COMMAND_TILE - 18.0)
				for art_child in spell_art.get_children():
					if art_child is Control:
						art_child.size = spell_art.size
				btn.add_child(spell_art)
				btn.move_child(spell_art, 0)
			var cap_u = u
			var aimed: bool = cap_id in ["root", "bolt", "charge"] or (float(ab.get("range", 0.0)) > 0.0 and String(ab.get("use", "enemy")) == "enemy" and (ab.has("fx") or bool(ab.get("sig", false))) and not cap_id in ["sig_chains", "sig_stoneskin", "sig_entrudo"])
			btn.pressed.connect(func():
				if is_instance_valid(cap_u) and not cap_u.is_dead and cap_u.has_method("cast_ability"):
					# Aimed spells cast from the button target the nearest enemy
					# instead of the hero's own feet.
					var aim: Vector3 = cap_u.global_position
					if aimed and world and world.has_method("_nearest_enemy_to"):
						var foe = world._nearest_enemy_to(cap_u.global_position, cap_u.team, [])
						if is_instance_valid(foe):
							aim = foe.global_position
					cap_u.cast_ability(cap_id, aim))
			ability_grid.add_child(btn)
			var status_label: Label = btn.get_meta("command_status_label")
			_ability_widgets.append({"id": cap_id, "button": btn, "overlay": status_label})

	_add_command_section("Orders", "Move · attack")
	var order_grid := _add_field_order_grid()
	_add_military_command_button(order_grid, "Attack Move", "Move and engage enemies encountered.", "Attack-move: march to a point and fight anything met on the way.", "attack_move")
	_add_military_command_button(order_grid, "Stop", "Stop current orders.", "Stop: drop every order and stand.", "stop")
	_add_military_command_button(order_grid, "Hold", "Hold this position.", "Hold: stand on this spot and fight what comes within reach, without giving chase.", "hold")
	_add_military_command_button(order_grid, "Patrol", "Move between chosen points.", "Patrol: walk back and forth between here and a chosen point, fighting what you meet.", "patrol")


func _build_military_card() -> void:
	_add_command_section("Commands", "Move · attack")
	var grid := _add_field_order_grid()
	_add_military_command_button(grid, "Attack Move", "Move and engage enemies encountered.", "Attack-move: march to a point and fight anything met on the way.", "attack_move")
	_add_military_command_button(grid, "Stop", "Stop current orders.", "Stop: drop every order and stand.", "stop")
	_add_military_command_button(grid, "Hold", "Hold this position.", "Hold: stand on this spot and fight what comes within reach, without giving chase.", "hold")
	_add_military_command_button(grid, "Patrol", "Move between chosen points.", "Patrol: walk back and forth between here and a chosen point, fighting what you meet.", "patrol")


func _add_military_command_button(grid: GridContainer, title: String, detail: String, tooltip: String, action: String) -> void:
	var state := "ACTIVE" if (action == "attack_move" and bool(rts.get("_attack_move_mode"))) or (action == "patrol" and bool(rts.get("_patrol_mode"))) else "READY"
	var btn := _mk_command_tile(title, tooltip, state)
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


func _construction_phase(value: float) -> String:
	if value < 0.25:
		return "Laying foundations"
	if value < 0.70:
		return "Raising the frame"
	return "Finishing the site"


func _research_queue_caption(building, tech_id: String) -> String:
	for index in building.queue.size():
		var item: Dictionary = building.queue[index]
		if String(item.get("kind", "unit")) == "tech" and String(item.get("id", "")) == tech_id:
			return "RESEARCHING" if index == 0 else "QUEUED"
	# The same global technology may be underway in another producer.
	return "RESEARCHING"


func _organize_research_catalog(grid: GridContainer, building_key: String) -> void:
	var stages := {"available": [], "progress": [], "future": [], "completed": []}
	# The stage groups stack; their tiles sit five to a row inside them.
	grid.columns = 1
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for card in grid.get_children():
		stages[String(card.get_meta("research_stage", "future"))].append(card)
		grid.remove_child(card)
	var groups: Array = []
	for stage in ["available", "progress", "future", "completed"]:
		var cards: Array = stages[stage]
		if cards.is_empty():
			continue
		var state_key: String = building_key + ":" + String(stage)
		var open: bool = bool(_research_expanded.get(state_key, stage in ["available", "progress"]))
		var group := VBoxContainer.new()
		group.name = "Research_" + stage
		group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		group.add_theme_constant_override("separation", 3)
		grid.add_child(group)
		var header := Button.new()
		header.name = "Disclosure"
		header.custom_minimum_size = Vector2(0, 40)
		header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.toggle_mode = true
		header.button_pressed = open
		header.focus_mode = Control.FOCUS_ALL
		header.alignment = HORIZONTAL_ALIGNMENT_LEFT
		header.add_theme_font_size_override("font_size", 16)
		header.add_theme_color_override("font_color", COMMAND_GOLD if stage == "available" else Color(0.81, 0.83, 0.80))
		var caption := String({"available": "UNLOCKED RESEARCH", "progress": "IN PROGRESS", "future": "FUTURE UPGRADES", "completed": "COMPLETED"}[stage])
		header.text = "%s  ·  %d" % [caption, cards.size()]
		header.tooltip_text = "Unlocked upgrades stay here even when resources are missing." if stage == "available" else ("Research already queued." if stage == "progress" else ("Inspect future upgrades, their costs and requirements." if stage == "future" else "Inspect completed upgrades."))
		for mode in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
			var style := StyleBoxFlat.new()
			style.bg_color = Color(0.065, 0.085, 0.089, 0.98) if mode not in ["hover", "hover_pressed"] else Color(0.12, 0.15, 0.15, 1.0)
			style.border_color = Color(0.52, 0.42, 0.25, 0.85) if mode != "focus" else COMMAND_GOLD
			style.set_border_width_all(1)
			style.border_width_left = 3 if stage in ["available", "progress"] else 1
			style.set_corner_radius_all(2)
			style.content_margin_left = 12
			style.content_margin_right = 86
			header.add_theme_stylebox_override(mode, style)
		group.add_child(header)
		# Plan 434: the stage header is a small forged bar like the rest of
		# the deck instead of a flat box.
		for mode in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
			header.add_theme_stylebox_override(mode, _research_header_inset(stage))
		var header_backing = load("res://scripts/ui/hud_forged_skin.gd").Backing.new()
		header_backing.name = "ForgedBacking"
		header.add_child(header_backing)
		header.resized.connect(func():
			if is_instance_valid(header_backing):
				var hw := header.size.x
				var hh := header.size.y
				header_backing.set_shape(PackedVector2Array([Vector2(0, 0), Vector2(hw, 0), Vector2(hw, hh), Vector2(0, hh)]), [], {"rim": 6.0, "groove": 1.2, "inlay": 0.0, "shadow": 5.0, "plate_top": 0.0, "plate_bottom": hh}))
		var cue := _mk_label("HIDE −" if open else "SHOW +", 13, COMMAND_GOLD)
		cue.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cue.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
		cue.offset_left = -78
		cue.offset_right = -10
		cue.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cue.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		header.add_child(cue)
		var content := GridContainer.new()
		content.name = "Entries"
		content.columns = 5
		content.add_theme_constant_override("h_separation", 8)
		content.add_theme_constant_override("v_separation", 6)
		content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content.visible = open
		group.add_child(content)
		for card in cards:
			content.add_child(card)
		header.toggled.connect(func(expanded: bool):
			_research_expanded[state_key] = expanded
			if is_instance_valid(content):
				content.visible = expanded
			if is_instance_valid(cue):
				cue.text = "HIDE −" if expanded else "SHOW +"
			_hide_command_tooltip()
			_fit_command_panel_next_frame())
		groups.append({"stage": stage, "header": header, "content": content, "count": cards.size()})
	grid.set_meta("research_groups", groups)


func _research_header_inset(stage: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.content_margin_left = 16 if stage in ["available", "progress"] else 14
	style.content_margin_right = 86
	return style


func _hq_action_count(node: Node) -> int:
	var count := 1 if node is Button and node.has_meta("command_kind") else 0
	for child in node.get_children():
		count += _hq_action_count(child)
	return count


func _style_hq_exchange_button(button: Button, buying: bool) -> void:
	button.custom_minimum_size = Vector2(0, 50)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", FONT_COLOR)
	button.add_theme_color_override("font_disabled_color", Color(0.50, 0.54, 0.53))
	button.set("accent", COMMAND_GOLD if buying else COMMAND_MINT)
	button.set("command_kind", "EXCHANGE")
	for mode in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(mode, StyleBoxEmpty.new())
	# The forged renderer draws after Button's native text. Keep native text
	# for accessibility and place its readable copy in the child drawing layer.
	var caption := _mk_label(button.text, 16, FONT_COLOR if not button.disabled else Color(0.50, 0.54, 0.53))
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	button.add_child(caption)


func _layout_hq_exchange(content: VBoxContainer, native_rows: Array) -> void:
	if native_rows.size() != 3 or native_rows[1].get_child_count() != 3 or native_rows[2].get_child_count() != 3:
		return
	var buys: Array = native_rows[1].get_children()
	var sells: Array = native_rows[2].get_children()
	native_rows[0].visible = false
	var heading := _mk_label("RESOURCE EXCHANGE", 16, COMMAND_GOLD)
	content.add_child(heading)
	var prices := HBoxContainer.new()
	prices.add_theme_constant_override("separation", 6)
	content.add_child(prices)
	var gutter := Control.new()
	gutter.custom_minimum_size = Vector2(36, 0)
	prices.add_child(gutter)
	for text in ["BUY · %d GOLD" % _commander.trade_price(), "SELL · %d GOLD" % _commander.SELL_GOLD]:
		var label := _mk_label(text, 14, Color(0.83, 0.79, 0.65))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prices.add_child(label)
	for i in 3:
		var row := HBoxContainer.new()
		row.name = "Exchange_" + String(["food", "timber", "stone"][i])
		row.add_theme_constant_override("separation", 6)
		content.add_child(row)
		var art := _mk_resource_object_icon(String(["food", "timber", "stone"][i]), 36)
		art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(art)
		for pair in [[buys[i], true], [sells[i], false]]:
			var button: Button = pair[0]
			button.get_parent().remove_child(button)
			row.add_child(button)
			_style_hq_exchange_button(button, bool(pair[1]))
	for i in [1, 2]:
		content.remove_child(native_rows[i])
		native_rows[i].queue_free()


func _organize_hq_workspaces(building, train_start: int, research_start: int, trade_start: int) -> void:
	var children := _cmd_body.get_children()
	var entries := {"train": children.slice(train_start, research_start), "research": children.slice(research_start, trade_start), "trade": children.slice(trade_start)}
	var keys: Array[String] = []
	for key in ["train", "research", "trade"]:
		if not entries[key].is_empty():
			keys.append(String(key))
	if keys.size() < 2:
		return
	var building_key := String(building.building_id)
	var selected := String(_hq_workspace_choices.get(building_key, "train"))
	if not keys.has(selected):
		selected = keys[0]
	var tabs := HBoxContainer.new()
	tabs.name = "HQWorkspaces"
	tabs.add_theme_constant_override("separation", 3)
	_cmd_fixed.add_child(tabs)
	var panes: Dictionary = {}
	var tab_buttons: Dictionary = {}
	var button_group := ButtonGroup.new()
	for key in keys:
		var pane := VBoxContainer.new()
		pane.name = "Workspace_" + key
		pane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pane.add_theme_constant_override("separation", 6)
		_cmd_body.add_child(pane)
		panes[key] = pane
		for node in entries[key]:
			node.reparent(pane)
		if key == "trade":
			_layout_hq_exchange(pane, entries[key])
		pane.visible = key == selected
		var tab := Button.new()
		tab.name = key.capitalize()
		tab.set_meta("workspace_key", key)
		tab.toggle_mode = true
		tab.button_group = button_group
		tab.button_pressed = key == selected
		tab.custom_minimum_size = Vector2(0, 44)
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.add_theme_font_size_override("font_size", 16)
		# Plan 480: always the plain face at this size. The readable-text pass
		# sometimes ran before the tab joined the tree, leaving thin capitals
		# on some peoples' halls.
		tab.add_theme_font_override("font", ThemeDB.fallback_font)
		tab.add_theme_color_override("font_color", Color(0.70, 0.73, 0.72))
		tab.add_theme_color_override("font_pressed_color", FONT_COLOR)
		var count: int = 6 if key == "trade" else _hq_action_count(pane)
		tab.text = "%s · %d" % [key.capitalize(), count]
		tab.tooltip_text = String({"train": "Train units. Shift-click queues five when possible.", "research": "Inspect and research technologies and the next Age.", "trade": "Buy supplies for gold or sell surplus to the caravan."}[key])
		for mode in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
			# Plan 421: engraved tabs, not boxes. The chosen one is lit from
			# below with a gilt bar; the others sit on a faint bronze rule.
			# Plan 450: the tab itself is forged metal (a Backing behind the
			# text); the style only lights a hover and keeps the gilt bar.
			var style := StyleBoxFlat.new()
			var chosen: bool = mode in ["pressed", "hover_pressed"]
			# The open tab glows warm over its metal; closed tabs sit in shade.
			style.bg_color = Color(1.0, 0.78, 0.42, 0.13 if mode == "hover_pressed" else 0.09) if chosen else (Color(1.0, 0.86, 0.55, 0.05) if mode == "hover" else Color(0.0, 0.0, 0.0, 0.30))
			style.set_corner_radius_all(0)
			style.corner_radius_top_left = 7
			style.corner_radius_top_right = 7
			style.content_margin_top = 6.0
			style.border_color = COMMAND_GOLD if chosen else Color(0, 0, 0, 0)
			style.border_width_bottom = 3 if chosen else 0
			style.expand_margin_bottom = 0.0
			style.set_content_margin_all(6)
			tab.add_theme_stylebox_override(mode, style)
		_forge_workspace_tab(tab)
		tabs.add_child(tab)
		tab_buttons[key] = tab
	for key in keys:
		var selected_key: String = key
		var tab: Button = tab_buttons[key]
		tab.pressed.connect(func():
			_hq_workspace_choices[building_key] = selected_key
			for other in panes:
				if is_instance_valid(panes[other]):
					panes[other].visible = other == selected_key
			if is_instance_valid(_cmd_scroll):
				_cmd_scroll.scroll_vertical = 0
			_hide_command_tooltip()
			_fit_command_panel_next_frame())
	tabs.set_meta("workspace_panes", panes)
	tabs.set_meta("workspace_buttons", tab_buttons)


## Plan 450: a workspace tab (Train, Research, Trade) as a forged metal tab
## with chamfered top corners. The open tab is the bright one with the painted
## rail and a gem; the others sit back, darker and slimmer.
func _forge_workspace_tab(tab: Button) -> void:
	var backing = load("res://scripts/ui/hud_forged_skin.gd").Backing.new()
	backing.name = "ForgedTab"
	backing.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tab.add_child(backing)
	var reshape := func():
		if not is_instance_valid(backing) or not is_instance_valid(tab):
			return
		var w := tab.size.x
		var h := tab.size.y
		if w < 20.0 or h < 10.0:
			return
		var chosen := tab.button_pressed
		var c := 8.0
		var pts := PackedVector2Array([Vector2(c, 0), Vector2(w - c, 0), Vector2(w, c), Vector2(w, h), Vector2(0, h), Vector2(0, c)])
		var studs: Array = [Vector4(w * 0.5, 4.5, 3.2, 1.0)] if chosen else []
		backing.set_shape(pts, studs, {"rim": 5.0 if chosen else 3.5, "groove": 1.2, "inlay": 0.0, "shadow": 4.0 if chosen else 2.0,
			"plate_top": 0.0, "plate_bottom": h * (1.0 if chosen else 1.6), "alpha": 0.97 if chosen else 0.72, "painted": chosen, "painted_rim": 7.0})
		tab.add_theme_color_override("font_color", Color(0.74, 0.74, 0.70) if not chosen else FONT_COLOR)
	tab.resized.connect(reshape)
	tab.toggled.connect(func(_on: bool): reshape.call())


func _build_building_card(b) -> void:
	if not b.is_built:
		_add_context_hints(["Workers raise it; more workers build faster"])
		_add_command_section("Construction", "SITE IN PROGRESS")
		var site = HUD_CONSTRUCTION_SCRIPT.new()
		site.name = "ConstructionProgress"
		site.custom_minimum_size = Vector2(0, 112)
		site.set_progress(float(b.build_progress))
		_cmd_body.add_child(site)
		var site_name := _mk_label(String(b.def.get("name", "Building")), 18, FONT_COLOR)
		site_name.position = Vector2(112, 14)
		site_name.size = Vector2(190, 27)
		site_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
		site.add_child(site_name)
		var stage_label := _mk_label(_construction_phase(float(b.build_progress)), 13, Color(0.90, 0.84, 0.70))
		stage_label.position = Vector2(112, 44)
		stage_label.size = Vector2(240, 21)
		stage_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		site.add_child(stage_label)
		var rail_caption := _mk_label("SITE PROGRESS", 10, Color(0.96, 0.74, 0.38))
		rail_caption.position = Vector2(112, 70)
		rail_caption.size = Vector2(140, 17)
		rail_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		site.add_child(rail_caption)
		var progress_label := _mk_label("%d%%" % roundi(clampf(b.build_progress, 0.0, 1.0) * 100.0), 22, FONT_COLOR)
		progress_label.anchor_left = 1.0
		progress_label.anchor_right = 1.0
		progress_label.offset_left = -82.0
		progress_label.offset_right = -12.0
		progress_label.offset_top = 17.0
		progress_label.offset_bottom = 46.0
		progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		progress_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		site.add_child(progress_label)
		var cap_b = b
		var cap_label := progress_label
		var cap_site = site
		var cap_stage := stage_label
		var t := Timer.new()
		t.wait_time = 0.2
		t.autostart = true
		site.add_child(t)
		var site_b_id: int = cap_b.get_instance_id()
		t.timeout.connect(func():
			var cb = instance_from_id(site_b_id)
			if is_instance_valid(cb) and is_instance_valid(cap_label) and is_instance_valid(cap_site):
				var pct := roundi(clampf(cb.build_progress, 0.0, 1.0) * 100.0)
				cap_label.text = "%d%%" % pct
				cap_site.set_progress(float(cb.build_progress))
				if is_instance_valid(cap_stage):
					cap_stage.text = _construction_phase(float(cb.build_progress))
		)
		return
	var def: Dictionary = b.def
	var produces: Array = def.get("produces", [])
	var research: Array = GameData.research_for(def, String(_commander.race)) if is_instance_valid(_commander) else def.get("research", [])
	# Say only what this building does: a research hall has no troops to rally.
	if bool(def.get("vein_outpost", false)):
		_add_context_hints(["RMB|Send workers in", "Expand it for more output"])
	elif produces.is_empty() and not research.is_empty():
		_add_context_hints(["Upgrades here help the whole army"])
	elif research.is_empty() and not produces.is_empty():
		_add_context_hints(["RMB|Set rally point", "SHIFT|Queue five"])
	else:
		_add_context_hints(["RMB|Set rally point", "SHIFT|Queue five"])
	var is_hq: bool = def.get("is_hq", false) or def.get("kind", "") == "main"

	# Vein outpost: who works inside, what it pays, and how to grow it.
	if bool(def.get("vein_outpost", false)):
		_add_command_section("Vein", "WHAT IT PAYS")
		var vein = b.get_meta("vein") if b.has_meta("vein") else null
		var info := _mk_label("", 15, FONT_COLOR)
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.custom_minimum_size = Vector2(380, 70)
		info.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		_cmd_body.add_child(info)
		var cap_ob = b
		var refresh := func():
			if not is_instance_valid(cap_ob) or not is_instance_valid(info):
				return
			var v = cap_ob.get_meta("vein") if cap_ob.has_meta("vein") else null
			info.text = "%s  ·  level %d
Workers inside %d / %d  ·  +%d %s a minute
%s left in the vein" % [
				v.display_name() if is_instance_valid(v) else "Vein", cap_ob.outpost_level, cap_ob.garrison.size(), cap_ob.outpost_slots(),
				int(round(cap_ob.outpost_rate_per_minute())), String(v.kind) if is_instance_valid(v) else "", str(int(v.amount)) if is_instance_valid(v) else "0"]
			var flare_left := (float(v.rich_until) - float(world.match_time)) if is_instance_valid(v) and is_instance_valid(world) else 0.0
			if flare_left > 0.0:
				info.text += "\nLume flare: double output for %d more seconds" % int(ceil(flare_left))
		refresh.call()
		var rt := Timer.new()
		rt.wait_time = 1.0
		rt.autostart = true
		info.add_child(rt)
		rt.timeout.connect(refresh)
		var og := _mk_command_grid()
		og.columns = 1
		_cmd_body.add_child(og)
		if b.outpost_level < b.OUTPOST_MAX_LEVEL:
			var ecost: Dictionary = b.outpost_expand_cost()
			var ereason: String = "" if _commander.can_afford(ecost) else _commander.missing_resource_summary(ecost)
			_watch_cost(ecost, ereason == "")
			var next_desc := "Level %d: %d worker slots, +%d%% output%s." % [b.outpost_level + 1, b.outpost_slots() + 2, int(25 * b.outpost_level), ", and a watch-fire that shoots raiders" if b.outpost_level + 1 >= b.OUTPOST_MAX_LEVEL else ""]
			var eb := _mk_command_button("Expand Outpost", _cost_string(ecost).trim_prefix("  (").trim_suffix(")"), next_desc, ereason, "LOCKED" if ereason != "" else "READY", {}, next_desc, "Next", "", "EXPAND")
			eb.disabled = ereason != ""
			eb.pressed.connect(func():
				var res = _issue_order({"type": "expand", "target": cap_ob})
				if res is Dictionary and not bool(res.get("ok", false)):
					_flash_notice(String(res.get("reason", "Cannot expand")))
				_rebuild_command_card(cap_ob, [cap_ob]))
			og.add_child(eb)
		var rb := _mk_command_button("Release", "Send everyone inside back out", "The workers step out beside the outpost.", "" if not b.garrison.is_empty() else "Nobody inside", "READY" if not b.garrison.is_empty() else "LOCKED", {}, "", "Effect", "", "ORDER")
		rb.disabled = b.garrison.is_empty()
		rb.pressed.connect(func():
			_issue_order({"type": "release", "target": cap_ob})
			_rebuild_command_card(cap_ob, [cap_ob]))
		og.add_child(rb)
		return

	var workspace_train_start := _cmd_body.get_child_count()
	# production units
	if not produces.is_empty():
		_add_command_section("Train", "SCROLL · %d UNITS" % produces.size() if produces.size() > 4 else "", produces.size() > 4 and research.is_empty() and not is_hq)
		# Plan 430: units to train are square tiles with the unit's picture;
		# cost, age, housing and role move to the tooltip.
		var train_grid := _add_field_order_grid()
		train_grid.columns = 5
		for uid in produces:
			var udef := GameData.get_unit(uid)
			if udef.is_empty():
				continue
			# A unit already in the queue can be queued again: the button used
			# to lock with "Already training", so a hall could hold only one
			# of each soldier at a time and had to be clicked again after
			# every one.
			var queued_count := 0
			for queued_item in b.queue:
				if queued_item.get("kind", "unit") == "unit" and String(queued_item.get("id", "")) == String(uid):
					queued_count += 1
			var queued_for_training := queued_count > 0
			var cost: Dictionary = udef.get("cost", {})
			var tier := int(udef.get("tier", 1))
			var affordable: bool = _commander.can_afford(cost)
			var housed: bool = _commander.has_pop_for(udef)
			_watch_cost(cost, affordable and housed, udef)
			var reason: String = ""
			if b.queue.size() >= int(b.get("MAX_QUEUE") if b.get("MAX_QUEUE") != null else 8):
				reason = "The queue is full"
			elif tier > _commander.tier:
				reason = "Requires the Age of Iron" if tier == 2 else "Requires the Age of Lume"
			elif not housed:
				reason = "Need more housing"
			elif not affordable:
				reason = _commander.missing_resource_summary(cost)
			var train_detail := "Age %d · %d pop · %s" % [tier, int(udef.get("pop", 1)), _cost_string(cost).trim_prefix("  (").trim_suffix(")")]
			if queued_count > 0:
				train_detail = "%d queued · %s" % [queued_count, train_detail]
			var train_state := "LOCKED" if not reason.is_empty() else ("TRAINING" if queued_for_training else "READY")
			var unit_emblem := String(uid) if String(uid) == "barrosan_worker" else ""
			var unit_card_art := {} if not unit_emblem.is_empty() else udef
			var train_tip := "Cost: %s  ·  %d pop  ·  Age %d\n%s" % [_cost_string(cost).trim_prefix("  (").trim_suffix(")"), int(udef.get("pop", 1)), tier, _unit_tooltip(udef)]
			var btn := _mk_command_tile(str(udef.get("name", uid)), train_tip, train_state, "", "TRAIN", reason)
			btn.set_meta("train_detail", train_detail)
			var unit_art: Control
			if not unit_card_art.is_empty() and ResourceLoader.exists(ENTITY_PORTRAIT_SCRIPT):
				unit_art = load(ENTITY_PORTRAIT_SCRIPT).new()
				unit_art.name = "UnitCommandPortrait"
			else:
				unit_art = _mk_command_icon(unit_emblem, btn.accent, COMMAND_TILE - 18.0)
				unit_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			_tile_set_art(btn, unit_art)
			if unit_art.has_method("configure_definition"):
				unit_art.configure_definition(unit_card_art, false)
			if train_state == "LOCKED":
				unit_art.modulate = Color(0.55, 0.57, 0.60, 0.85)
			var tile_status := btn.get_meta("command_status_label") as Label
			tile_status.text = ("%d" % queued_count) if queued_count > 0 else ""
			btn.disabled = not reason.is_empty()
			var cap_b = b
			var cap_uid := String(uid)
			btn.pressed.connect(func(): _try_queue_unit(cap_b, cap_uid))
			train_grid.add_child(btn)

	var workspace_research_start := _cmd_body.get_child_count()
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
		var research_heading := _cmd_body.get_child(_cmd_body.get_child_count() - 1)
		# Plan 432: research as square tiles, five to a row, like the
		# train and build decks. Dense catalogues still group by stage.
		var research_grid := _add_field_order_grid()
		research_grid.columns = 5
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
			_watch_cost(cost, affordable)
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
					reason = "Requires the %s" % required_age_name
				elif _commander.tier < int(tdef.get("min_tier", 1)):
					reason = "Requires the %s" % String(GameData.get_tech("advance_tier_%d" % int(tdef.get("min_tier", 1))).get("name", "Age that follows")).trim_prefix("Advance to ")
				else:
					var missing := ""
					for r in tdef.get("req", []):
						if not _commander.completed_tech.has(r):
							missing = String(GameData.get_tech(String(r)).get("name", r))
							break
					reason = ("Requires %s" % missing) if missing != "" else "Unavailable"
			elif not affordable:
				reason = _commander.missing_resource_summary(cost)
			var ready_to_research: bool = available and affordable
			var research_state := "COMPLETED" if _commander.completed_tech.has(tid) else ("LOCKED" if not ready_to_research else "READY")
			# Each research wears an emblem of what it does (sword, shield, pick...).
			var tech_emblem: String = load(COMMAND_GLYPH_SCRIPT).research_kind(String(tid), tdef)
			var research_tip := "Cost: %s\n%s" % [_cost_string(cost).trim_prefix("  (").trim_suffix(")"), str(tdef.get("desc", "")) + ("\nTakes %d s" % int(round(float(tdef.get("time", 0.0)))) if float(tdef.get("time", 0.0)) > 0.0 and not _commander.completed_tech.has(tid) else "")]
			var btn := _mk_command_tile(_tech_display_name(tid, str(tdef.get("name", tid))), research_tip, research_state, "", "RESEARCH", reason)
			var tech_art := _mk_command_icon(tech_emblem, btn.accent, COMMAND_TILE - 18.0)
			tech_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			_tile_set_art(btn, tech_art)
			var research_status := btn.get_meta("command_status_label") as Label
			research_status.text = "DONE" if research_state == "COMPLETED" else ""
			if research_state != "READY":
				tech_art.modulate = Color(0.55, 0.57, 0.60, 0.85)
			btn.disabled = not ready_to_research
			# Classify from the same native availability used above. A lack of
			# resources never hides an otherwise unlocked technology.
			btn.set_meta("research_stage", "completed" if _commander.completed_tech.has(tid) else ("progress" if _commander.researching.has(tid) else ("available" if available else "future")))
			if _commander.researching.has(tid):
				var queue_caption := btn.get_meta("command_status_label") as Label
				queue_caption.text = "NOW" if _research_queue_caption(b, String(tid)) == "RESEARCHING" else "NEXT"
				queue_caption.add_theme_color_override("font_color", COMMAND_SKY)
			var cap_b = b
			var cap_tid := String(tid)
			btn.pressed.connect(func(): _try_queue_tech(cap_b, cap_tid))
			research_grid.add_child(btn)
		# Short catalogues remain a simple list. Dense ones reveal progression
		# explicitly instead of giving every locked future rank a full row.
		if research_grid.get_child_count() > 4:
			research_heading.visible = false
			_organize_research_catalog(research_grid, String(b.building_id))

	var workspace_trade_start := _cmd_body.get_child_count()
	# Caravan trade: spend a gold hoard on what the nodes no longer give.
	if is_hq and _commander.has_method("trade_gold_for"):
		var price: int = _commander.trade_price()
		_add_command_section("Caravan", "%d GOLD PER %d" % [price, _commander.TRADE_BATCH])
		var trade_row := HBoxContainer.new()
		trade_row.add_theme_constant_override("separation", 6)
		_cmd_body.add_child(trade_row)
		for kind in ["food", "timber", "stone"]:
			var tb := HUD_ACTION_SCRIPT.new()
			tb.text = "+%d %s" % [_commander.TRADE_BATCH, String(kind).capitalize()]
			tb.custom_minimum_size = Vector2(0, 36)
			tb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			tb.focus_mode = Control.FOCUS_NONE
			tb.add_theme_font_size_override("font_size", 15)
			tb.disabled = int(_commander.resources.get("gold", 0)) < price
			_watch_cost({"gold": price}, not tb.disabled)
			tb.tooltip_text = "Trade %d gold for %d %s. Each trade raises the price by a few gold; it eases back over time." % [price, _commander.TRADE_BATCH, kind]
			var cap_hq = b
			var cap_kind := String(kind)
			tb.pressed.connect(func():
				var res = _issue_order({"type": "trade", "target": cap_hq, "id": cap_kind})
				if res is Dictionary and not bool(res.get("ok", false)):
					_flash_notice(String(res.get("reason", "Cannot trade")))
				else:
					Sfx.play("coin", -8.0)
				_rebuild_command_card(cap_hq, [cap_hq]))
			trade_row.add_child(tb)
		# Second row: sell a surplus for gold.
		var sell_row := HBoxContainer.new()
		sell_row.add_theme_constant_override("separation", 6)
		_cmd_body.add_child(sell_row)
		for kind in ["food", "timber", "stone"]:
			var sb := HUD_ACTION_SCRIPT.new()
			sb.text = "Sell %d %s" % [_commander.SELL_BATCH, String(kind).capitalize()]
			sb.custom_minimum_size = Vector2(0, 32)
			sb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			sb.focus_mode = Control.FOCUS_NONE
			sb.add_theme_font_size_override("font_size", HUD_TEXT_MIN)
			sb.disabled = int(_commander.resources.get(kind, 0)) < _commander.SELL_BATCH
			_watch_cost({kind: _commander.SELL_BATCH}, not sb.disabled)
			sb.tooltip_text = "Sell %d %s to the caravan for %d gold." % [_commander.SELL_BATCH, kind, _commander.SELL_GOLD]
			var cap_hq2 = b
			var cap_sell := "sell_" + String(kind)
			sb.pressed.connect(func():
				var res = _issue_order({"type": "trade", "target": cap_hq2, "id": cap_sell})
				if res is Dictionary and not bool(res.get("ok", false)):
					_flash_notice(String(res.get("reason", "Cannot sell")))
				else:
					Sfx.play("coin", -8.0)
				_rebuild_command_card(cap_hq2, [cap_hq2]))
			sell_row.add_child(sb)
	if is_hq:
		_organize_hq_workspaces(b, workspace_train_start, workspace_research_start, workspace_trade_start)


## The two army upgrades, named in each faction's own words.
const TECH_FLAVOR := {
	"tech_weapons": {"barrosan": "Smithed Sledges", "lioraen": "Thorn-Hardened Blades", "vorthak": "Ash-Glass Edges", "grimtusk": "Chain-Iron Blades",
		"sylvan": "Coal-Gold Edges", "karak": "Castro Steel", "sunspear": "Bronze Temper", "wyldkin": "Trap-Iron Claws", "hollow": "Candle-Iron Blades", "frostborn": "Bell-Iron Blades"},
	"tech_armor": {"barrosan": "Granite-Wool Coats", "lioraen": "Bark Mail", "vorthak": "Glass Plate", "grimtusk": "Overseer Plate",
		"sylvan": "Silver Mail", "karak": "Granite Plate", "sunspear": "Bronze Scale", "wyldkin": "Thick Pelts", "hollow": "Bone Mail", "frostborn": "Winter Fringes"},
}

## A heraldic shield in the faction's colour, gilt-rimmed, with its initial:
## the crest for factions that do not have painted crest art yet.
func _drawn_faction_crest(race_id: String, crest_size: Vector2) -> Control:
	var race: Dictionary = GameData.RACES.get(race_id, {})
	var col: Color = race.get("color", Color(0.6, 0.6, 0.6))
	var holder := Control.new()
	holder.custom_minimum_size = crest_size
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	holder.draw.connect(func():
		var w := holder.size.x
		var h := holder.size.y
		var m := 4.0
		var shield := PackedVector2Array([
			Vector2(m, m), Vector2(w - m, m), Vector2(w - m, h * 0.55),
			Vector2(w * 0.5, h - m), Vector2(m, h * 0.55)])
		holder.draw_colored_polygon(shield, Color(0.05, 0.04, 0.03, 0.9))
		var inner := PackedVector2Array()
		var c := Vector2(w * 0.5, h * 0.45)
		for p in shield:
			inner.append(c + (p - c) * 0.84)
		holder.draw_colored_polygon(inner, col.darkened(0.25))
		# A lighter chief across the top of the field.
		holder.draw_rect(Rect2(inner[0], Vector2(inner[1].x - inner[0].x, (h - m * 2.0) * 0.18)), Color(col.lightened(0.15), 0.55))
		shield.append(shield[0])
		holder.draw_polyline(shield, COMMAND_GOLD, 2.0, true)
		inner.append(inner[0])
		holder.draw_polyline(inner, Color(COMMAND_GOLD, 0.45), 1.0, true)
		FACTION_SIGILS.draw(holder, race_id, Vector2(w * 0.5, h * 0.47), w * 0.3, Color(0.98, 0.9, 0.7)))
	return holder

func _tech_display_name(tid: String, fallback: String) -> String:
	if _commander != null and TECH_FLAVOR.has(tid):
		return String(TECH_FLAVOR[tid].get(String(_commander.race), fallback))
	return fallback

## Production orders travel through the world's command bus (online seam).
func _issue_order(order: Dictionary):
	if world and world.get("command_bus") != null:
		return world.command_bus.issue(order)
	return load("res://scripts/world/command_bus.gd").new(world).execute(order)

func _try_queue_unit(b, uid: String) -> void:
	if not is_instance_valid(b) or not b.has_method("queue_unit"):
		return
	# Shift-click queues five at once, or as many as can be paid for and housed.
	var want := 5 if Input.is_key_pressed(KEY_SHIFT) else 1
	var queued := 0
	var res: Dictionary = {}
	for i in want:
		if i > 0:
			b.set("_last_queue_frame", -1)   # the one-per-frame guard is for double clicks
		res = _issue_order({"type": "train", "target": b, "id": uid})
		if not res.get("ok", false):
			break
		queued += 1
	if queued > 0:
		var nm: String = GameData.get_unit(uid).get("name", "Unit")
		_flash_notice(("Training %s..." % nm) if queued == 1 else ("Training %d × %s..." % [queued, nm]), Color(0.6, 0.95, 0.6))
		Sfx.play("select", -8.0)
		_rebuild_command_card(b, [b])
	else:
		_flash_notice(str(res.get("reason", "Cannot train")), Color(1, 0.55, 0.45))


func _try_queue_tech(b, tid: String) -> void:
	if not is_instance_valid(b) or not b.has_method("queue_tech"):
		return
	var res: Dictionary = _issue_order({"type": "research", "target": b, "id": tid})
	if res.get("ok", false):
		# tier advance / research done — refresh card so buttons grey out
		_rebuild_command_card(b, [b])
	else:
		_flash_notice(str(res.get("reason", "Cannot research")))


func _flash_notice(msg: String, col: Color = Color(1, 0.6, 0.5)) -> void:
	# A refusal (anything that is not the green "Training..." notice) also
	# sounds two low taps, so a click that did nothing is never silent.
	if col.g < 0.9 or col.r > 0.9:
		Sfx.play_limited("refuse", -10.0, 250)
	# This confirmation must have a real text measure: a trimming Label in a
	# zero-width anchored container collapsed the old message to its border.
	var box := PanelContainer.new()
	box.name = "CommandNotice"
	box.set_meta("command_notice", true)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.z_index = 60
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.04, 0.05, 0.96)
	sb.set_border_width_all(1)
	sb.border_width_left = 3
	sb.border_color = col
	sb.set_corner_radius_all(3)
	sb.set_content_margin_all(12)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 5
	box.add_theme_stylebox_override("panel", sb)
	add_child(box)
	var l := _mk_label(msg, 18, col)
	l.custom_minimum_size = Vector2(380, 0)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	box.add_child(l)
	box.resized.connect(func(): _place_command_notice.call_deferred(box))
	box.tree_exiting.connect(func(): _layout_command_feedback.call_deferred())
	_place_command_notice.call_deferred(box)
	var tw := box.create_tween()
	tw.tween_interval(1.4)
	tw.tween_property(box, "modulate:a", 0.0, 0.6)
	tw.tween_callback(box.queue_free)


func _place_command_notice(box: Control) -> void:
	if not is_instance_valid(box):
		return
	_layout_command_feedback()


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
		"GUARD": "Guard is not available yet",
	}
	var message := String(labels.get(intent, "Command"))
	if intent == "BUILD_OR_REPAIR" and accepted and String(feedback.get("feedback_type", "")) == "BUILD PLACEMENT":
		message = "Building started"
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
			message = "Guard is not available yet"
		elif intent == "BUILD_OR_REPAIR" and String(feedback.get("feedback_type", "")) == "REJECTED":
			message = "Cannot build there"
		else:
			message = "Nothing to do there"
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
	# Plan 492: a tall selection portrait (worker or soldier at compact
	# heights) reached into that band, and the notice covered its people
	# name. Lift the notice clear of the portrait when they share columns.
	if is_instance_valid(_selection_portrait) and _selection_portrait.is_visible_in_tree():
		var own := get_global_rect()
		var pr := _selection_portrait.get_global_rect()
		var mid := own.position.x + own.size.x * 0.5
		if pr.position.x < mid + 150.0 and pr.end.x > mid - 150.0:
			var lift := pr.position.y - 6.0 - (own.end.y - 256.0)
			if lift < 0.0:
				_command_feedback_box.offset_top += lift
				_command_feedback_box.offset_bottom += lift
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
	# As wide as the mission plate it hangs under: fewer lines break in two.
	_alert_box.offset_left = -528
	_alert_box.offset_right = -108
	_alert_box.offset_top = 128
	_alert_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_alert_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	_alert_box.add_theme_constant_override("separation", 4)
	_alert_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_alert_box)


var _map_pings: Array = []
var last_alert_position := Vector3.INF

var _survival_label: Label

## A campaign battle opens on a title card: the Act, the chapter, and the
## first line of its chronicle, fading out as the battle begins.
func _show_saga_title_card() -> void:
	var chapter := CampaignDefs.find(String(Match.get_config().get("campaign_chapter", "")))
	if chapter.is_empty():
		return
	# A soft dark band across the middle of the screen keeps the text legible.
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(holder)
	var band := TextureRect.new()
	var fade := Gradient.new()
	fade.set_color(0, Color(0, 0, 0, 0))
	fade.set_color(1, Color(0, 0, 0, 0))
	fade.add_point(0.5, Color(0, 0, 0, 0.62))
	var fade_tex := GradientTexture2D.new()
	fade_tex.gradient = fade
	fade_tex.fill_from = Vector2(0, 0)
	fade_tex.fill_to = Vector2(0, 1)
	band.texture = fade_tex
	band.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	band.stretch_mode = TextureRect.STRETCH_SCALE
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
	band.offset_top = -170.0
	band.offset_bottom = 170.0
	holder.add_child(band)
	var card := VBoxContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.alignment = BoxContainer.ALIGNMENT_CENTER
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	card.grow_vertical = Control.GROW_DIRECTION_BOTH
	card.custom_minimum_size = Vector2(900, 0)
	card.add_theme_constant_override("separation", 8)
	holder.add_child(card)
	var act := _mk_title_label(String(CampaignDefs.ACTS[int(chapter["act"])]["title"]).to_upper(), 18, Color(0.85, 0.76, 0.55))
	var title := _mk_title_label(String(chapter["title"]), 56, Color(0.99, 0.86, 0.48))
	var line := _mk_label(String(chapter["briefing"]).split("\n")[0], 19, Color(0.94, 0.90, 0.80))
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	line.custom_minimum_size = Vector2(900, 0)
	for l in [act, title, line]:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.add_theme_constant_override("outline_size", 8)
		card.add_child(l)
	holder.modulate.a = 0.0
	var t := holder.create_tween()
	t.tween_interval(1.0)
	t.tween_property(holder, "modulate:a", 1.0, 0.8)
	t.tween_interval(5.0)
	t.tween_property(holder, "modulate:a", 0.0, 1.2)
	t.tween_callback(holder.queue_free)

var _bounty_label: Label
var _bounty_accum := 1.0
var _bounty_announced := false

func _update_bounty_label(delta: float) -> void:
	_bounty_accum += delta
	if _bounty_accum < 0.5 or not is_instance_valid(_bounty_label) or not is_instance_valid(world) or not world.has_method("bounty_progress"):
		return
	_bounty_accum = 0.0
	var bp: Dictionary = world.bounty_progress()
	_bounty_label.visible = not bp.is_empty()
	# Its ring row (plan 437) goes with it.
	if _bounty_label.get_parent() is HBoxContainer:
		_bounty_label.get_parent().visible = _bounty_label.visible
	if bp.is_empty():
		return
	_bounty_label.text = String(bp["text"])
	_fit_top_line(_bounty_label, 13)
	# The moment a bounty is secured, a chime and an alert say so, once.
	if bool(bp["done"]) and not _bounty_announced:
		_bounty_announced = true
		Sfx.play("coin", -6.0)
		_push_alert("Bounty secured! Win the battle to claim extra spoils.", Color(0.72, 0.95, 0.66))
	elif not bool(bp["ok"]) and not _bounty_announced:
		_bounty_announced = true
		_push_alert("The bounty is lost. Win anyway.", Color(0.85, 0.66, 0.58))
	_bounty_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6) if bool(bp["done"]) else (Color(0.95, 0.82, 0.5) if bool(bp["ok"]) else Color(0.75, 0.6, 0.55)))

func _update_survival_label() -> void:
	if not is_instance_valid(_survival_label) or not is_instance_valid(world) or not world.has_method("survival_remaining"):
		return
	# Domination: the count of sites held, or the clock of whoever holds them all.
	if world.has_method("domination_status"):
		var dom: Dictionary = world.domination_status()
		if not dom.is_empty():
			var clock := "%d:%02d" % [int(dom["left"]) / 60, int(dom["left"]) % 60]
			if int(dom["team"]) < 0:
				# Short enough for the header: the tooltip carries the rule in full.
				_survival_label.text = "DOMINATION · %d of %d sites yours" % [int(dom["held"]), int(dom["total"])]
				if float(dom.get("opens_in", 0.0)) > 0.0:
					_survival_label.text += " · opens %d:%02d" % [int(dom["opens_in"]) / 60, int(dom["opens_in"]) % 60]
				# With ten or more sites and the opening clock the line is wider
				# than the header: it is set a little smaller, never cut.
				_fit_top_line(_survival_label, 11)
				_survival_label.add_theme_color_override("font_color", Color(0.91, 0.84, 0.66))
			elif int(dom["team"]) == int(world.player_team):
				_survival_label.text = "DOMINATION · You win in %s" % clock
				_survival_label.add_theme_color_override("font_color", Color(0.6, 0.95, 0.6))
			else:
				_survival_label.text = "DOMINATION · Enemy wins in %s" % clock
				_survival_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.42))
			return
	var left: float = world.survival_remaining()
	if left < 0.0:
		return
	_survival_label.text = "SURVIVE · Hold for %d:%02d" % [int(left) / 60, int(left) % 60]
	_survival_label.tooltip_text = "Keep your base standing until the timer runs out."

func _on_alert(message: String, _pos: Vector3) -> void:
	_refresh_opponent_count()
	# Alerts with a place (attacks, losses, captures) ping the minimap, and
	# Backspace jumps the camera there.
	if _pos != Vector3.ZERO:
		var lower := message.to_lower()
		var hostile := lower.contains("attack") or lower.contains("lost")
		_map_pings.append({"pos": _pos, "t": Time.get_ticks_msec(), "col": Color(1.0, 0.3, 0.22) if hostile else Color(1.0, 0.84, 0.4)})
		if _map_pings.size() > 6:
			_map_pings.pop_front()
		last_alert_position = _pos
	# A place with no words is a silent minimap ping.
	if message == "":
		return
	var low_msg := message.to_lower()
	_push_alert(message, _alert_colour(low_msg))


## Red for harm, green for gain, violet for the Lume's own events, parchment
## for the rest. Harm and gain are asked first: "Your hero has fallen. The
## Lume will raise them..." is a loss, and "Research complete: Lume-tempered
## Steel" a gain, whatever else the line mentions.
func _alert_colour(low_msg: String) -> Color:
	for bad in ["under attack", "lost", "destroyed", "your hero has fallen", "the enemy seized", "the enemy dug up", "the enemy has raised", "or lose", "no longer hold", "enemy wins"]:
		if low_msg.contains(bad):
			return Color(1.0, 0.55, 0.45)
	for good in ["complete", "ready", "dug up", "captured", "claimed", "defeated", "has fallen", " falls", "is slain", "is yours", "rises again", "expanded", "promoted", "reaches rank", "you win", "is broken"]:
		if low_msg.contains(good):
			return Color(0.72, 0.95, 0.66)
	for lume in ["jar", "flare", "lume"]:
		if low_msg.contains(lume):
			return Color(0.85, 0.72, 1.0)
	return Color(0.95, 0.9, 0.75)


func _on_hero_leveled(level: int) -> void:
	_push_alert("Your hero reached battle level %d." % level, Color(0.95, 0.85, 0.4))
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
	var dispatch: PanelContainer = HUD_ALERT_DISPATCH_SCRIPT.new()
	# The dispatch's rail takes the alert's own colour: red for attacks and
	# losses, gold for gains, and so on.
	dispatch.accent = col if col.v > 0.3 else COMMAND_GOLD
	# Plan 453: the sign at the left of the dispatch follows the alert colour.
	dispatch.kind = "harm" if col.r > 0.9 and col.g < 0.6 else ("gain" if col.g > 0.9 and col.r < 0.8 else ("lume" if col.b > col.g + 0.1 else "note"))
	dispatch.custom_minimum_size = Vector2(420, 60)
	dispatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var padding := StyleBoxFlat.new()
	padding.bg_color = Color.TRANSPARENT
	padding.content_margin_left = 44.0
	padding.content_margin_right = 11.0
	padding.content_margin_top = 8.0
	padding.content_margin_bottom = 9.0
	dispatch.add_theme_stylebox_override("panel", padding)
	# Wrapped, so it can simply grow on a laptop window.
	var l := _mk_label(message, roundi(18 * _small_window_boost()), col)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	l.custom_minimum_size = Vector2(354, 42)
	# One-line alerts sit in the middle of the dispatch, not at its top.
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_outline_color", Color(0.012, 0.020, 0.028, 1.0))
	l.add_theme_constant_override("outline_size", 2)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dispatch.add_child(l)
	_alert_box.add_child(dispatch)
	# Arrives with a short pop so it is noticed without a sound for every line.
	dispatch.modulate.a = 0.0
	dispatch.pivot_offset = Vector2(210, 30)
	dispatch.scale = Vector2(1.06, 1.06)
	var arrive := dispatch.create_tween().set_parallel(true)
	arrive.tween_property(dispatch, "modulate:a", 1.0, 0.18)
	arrive.tween_property(dispatch, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var tw := dispatch.create_tween()
	# A three-line message needs longer to read than "Unit ready".
	tw.tween_interval(3.2 + 0.035 * maxf(0.0, float(message.length()) - 40.0))
	tw.tween_property(dispatch, "modulate:a", 0.0, 0.8)
	tw.tween_callback(func():
		if is_instance_valid(dispatch):
			dispatch.queue_free())


# ---------------------------------------------------------------------------
# 7. GAME OVER
# ---------------------------------------------------------------------------
func _on_game_over(victory: bool) -> void:
	if is_instance_valid(_gameover_layer):
		return
	hide_field_hover()
	# Before the ledger, the camera glides to the last building that fell and
	# the field holds for a breath: the win or the loss is seen, not just read.
	_result_hold = 0.0
	var fallen: Vector3 = world.get("last_fallen_position") if world else Vector3.ZERO
	if rts and rts.has_method("glide_to") and fallen != Vector3.ZERO:
		rts.glide_to(fallen, 1.2)
		_result_hold = 1.6
		if victory and world.has_method("celebrate_at"):
			world.celebrate_at(fallen, Color(1.0, 0.85, 0.4))
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
	dim_tw.tween_property(dim, "color:a", 0.78, 0.6).set_delay(_result_hold)

	# Result ledger on the forged vellum plate used by the hero screens: a
	# crest title, the outcome line, a stat ledger and the two actions. The old
	# single summary line ellipsised at common resolutions.
	var accent := Color(0.98, 0.84, 0.46) if victory else Color(0.92, 0.36, 0.30)
	var plate: PanelContainer = load("res://scripts/ui/hero_sheet_plate.gd").new()
	var plate_style := StyleBoxFlat.new()
	plate_style.bg_color = Color.TRANSPARENT
	# Plan 424: near-opaque like the pause plate, so name plates in the field
	# do not show through the result ledger.
	plate.set("surface_alpha", 0.97)
	plate.set("surface_alpha_bottom", 0.97)
	plate.set("forged", true)
	for side in ["left", "right"]:
		plate_style.set("content_margin_" + side, 56.0)
	plate_style.content_margin_top = 34.0
	plate_style.content_margin_bottom = 34.0
	plate.add_theme_stylebox_override("panel", plate_style)
	plate.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	plate.grow_horizontal = Control.GROW_DIRECTION_BOTH
	plate.grow_vertical = Control.GROW_DIRECTION_BOTH
	plate.custom_minimum_size = Vector2(620, 0)
	plate.modulate.a = 0.0
	_gameover_layer.add_child(plate)
	plate.create_tween().tween_property(plate, "modulate:a", 1.0, 0.5).set_delay(_result_hold + 0.25)
	_fit_result_plate.call_deferred(plate)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	# Short screens (1366x768 laptops) get a tighter ledger so the buttons
	# always stay on screen, however rich the spoils.
	var compact: bool = get_viewport().get_visible_rect().size.y < 900.0
	box.add_theme_constant_override("separation", 6 if compact else 14)
	plate.add_child(box)
	if compact:
		plate_style.content_margin_top = 16.0
		plate_style.content_margin_bottom = 16.0

	var heading := _mk_title_label("VICTORY" if victory else "DEFEAT", 44 if compact else 64, accent)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	heading.add_theme_constant_override("shadow_offset_y", 3)
	box.add_child(heading)
	# Plan 346: a victory is crowned with laurel sprigs either side of the
	# title, and every result gets a gilt rule with a centre diamond under it
	# (the bare word on a black slab looked unfinished).
	if victory:
		heading.draw.connect(_draw_title_laurels.bind(heading, 44 if compact else 64, accent))
	box.add_child(_title_rule(accent))

	var result: Dictionary = Match.last_result if Match else {}
	var kills := int(result.get("kills", 0))
	var xp := int(result.get("xp", 0))
	var t := int(result.get("time", 0))
	var mins := int(t) / 60
	var secs := int(t) % 60
	var reason := String(result.get("reason", "Conquest"))
	# The result keeps machine reasons for tests; the ledger shows words.
	reason = String({"hq_destroyed": "Your stronghold was razed", "no_live_buildings": "Your last hall burned", "domination_lost": "The enemy held every Lume site"}.get(reason, reason))
	var outcome_text := "The field is yours" if victory else "Your host has fallen"
	# A bare "Victory" or "Defeat" reason only repeats the title above.
	if not reason.to_lower() in ["victory", "defeat", ""]:
		outcome_text += "  ·  " + reason
	var outcome := _mk_label(outcome_text, 20, Color(0.9, 0.86, 0.76))
	outcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outcome.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	box.add_child(outcome)
	# Campaign victories continue the saga on the ledger.
	var chapter_id := String(Match.get_config().get("campaign_chapter", "")) if Match else ""
	if chapter_id != "" and victory and String(CampaignDefs.find(chapter_id).get("victory", "")) == "ENDING":
		var ends := _mk_title_label("THE SAGA ENDS", 22, accent)
		ends.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(ends)
	if chapter_id != "":
		var story := CampaignDefs.victory_text(chapter_id, ProfileManager.saga()) if victory else "You fall at %s. The Lume does not let go of you so easily: it never has. Rise, Jardas, and try again." % String(CampaignDefs.find(chapter_id).get("title", "the field"))
		var chronicle := _mk_label(story, 17, Color(0.93, 0.88, 0.76))
		chronicle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		chronicle.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		chronicle.custom_minimum_size = Vector2(620, 0)
		chronicle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(chronicle)
		if victory and String(ProfileManager.saga().get("last_relic", "")) != "":
			var relic_line := _mk_label("Relic won: %s  ·  see the War Chest" % String(ProfileManager.saga()["last_relic"]), 17, Color(0.98, 0.78, 0.40))
			relic_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			relic_line.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
			relic_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			box.add_child(relic_line)
		if victory and bool(CampaignDefs.find(chapter_id).get("jar", false)):
			var jar_line := _mk_label("A jar of Wine of the Dead  ·  %d of %d found" % [ProfileManager.saga()["jars"].size(), CampaignDefs.JARS_TOTAL], 18, Color(0.86, 0.55, 0.95))
			jar_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			box.add_child(jar_line)
		var retinue_size: int = ProfileManager.saga().get("retinue", []).size()
		if retinue_size > 0 and String(CampaignDefs.find(chapter_id).get("victory", "")) != "ENDING":
			var named: Array = []
			for entry in ProfileManager.saga().get("retinue", []):
				if String(entry.get("name", "")) != "":
					named.append(String(entry["name"]))
			var retinue_line := _mk_label("Retinue: %d veteran%s will march with the Jardas into the next battle%s" % [retinue_size, "" if retinue_size == 1 else "s", ("  ·  " + ", ".join(named.slice(0, 3))) if not named.is_empty() else ""], 16, Color(0.78, 0.86, 0.66))
			retinue_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			box.add_child(retinue_line)
	if Match and String(Match.get_config().get("mode", "")) == "endless":
		# Plan 326: the result screen's sentence lines are in the body face.
		# In the thin capital face at 16 to 18 px they were about ten pixels
		# tall on a laptop; the headings above keep the capitals.
		var road_line := _mk_label(("Stage %d won  ·  the road goes on" if victory else "Stage %d holds  ·  the road waits") % int(Match.get_config().get("endless_depth", 1)), 18, Color(0.98, 0.84, 0.46))
		road_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(road_line)
		if victory and String(ProfileManager.saga().get("last_relic", "")) != "":
			var loot := _mk_label("Relic won: %s  ·  see the War Chest" % String(ProfileManager.saga()["last_relic"]), 17, Color(0.98, 0.78, 0.40))
			loot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			loot.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
			loot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			box.add_child(loot)
	if String(result.get("bounty", "")) != "":
		var b_line := _mk_label(("%s  Done: extra spoils and +20%% experience." if bool(result.get("bounty_won", false)) else "%s  Not met.") % String(result["bounty"]), 15, Color(0.95, 0.8, 0.45) if bool(result.get("bounty_won", false)) else Color(0.7, 0.66, 0.6))
		b_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b_line.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		box.add_child(b_line)
	for deed in result.get("deeds", []):
		var deed_line := _mk_label("Deed: %s  ·  now called %s  ·  +1 mastery" % [String(deed.get("track", "")), String(deed.get("title", ""))], 16, Color(1.0, 0.86, 0.5))
		deed_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		deed_line.set_meta("rare_pop", true)
		box.add_child(deed_line)
	if int(result.get("level_after", 0)) > int(result.get("level_before", 0)) and int(result.get("level_before", 0)) > 0:
		var gained := int(result["level_after"]) - int(result["level_before"])
		var lv_line := _mk_label("Level up! Your hero is now level %d%s" % [int(result["level_after"]), (" (+%d)" % gained) if gained > 1 else ""], 18, Color(1.0, 0.88, 0.45))
		lv_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(lv_line)
		Sfx.play("levelup", -6.0)
		# Crossing level 10 or 25 teaches the hero a new spell of their people.
		var race_now := String(ProfileManager.hero().get("race", "")) if ProfileManager.has_hero() else ""
		# The spells in play are those of the people led in this battle.
		if Match and String(Match.get_config().get("player_race", "")) != "":
			race_now = String(Match.get_config().get("player_race"))
		var before_sp: Dictionary = SkillDefs.people_spell_levels(race_now, int(result["level_before"]))
		var after_sp: Dictionary = SkillDefs.people_spell_levels(race_now, int(result["level_after"]))
		for new_id in after_sp:
			if not before_sp.has(new_id):
				var sdef: Dictionary = SkillDefs.get_abilities().get(String(new_id), {})
				var key := KeyBinds.label("ability_p1" if int(sdef.get("slot", 1)) == 1 else "ability_p2")
				var sp_line := _mk_label("New spell learned: %s  (key %s)" % [String(sdef.get("name", new_id)), key], 17, Color(0.75, 0.9, 1.0))
				sp_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				sp_line.set_meta("rare_pop", true)
				box.add_child(sp_line)
	# The hero's experience bar fills with this battle's reward.
	if ProfileManager.has_hero() and xp > 0:
		var hh: Dictionary = ProfileManager.hero()
		var need := maxf(1.0, ProfileManager.xp_for_level(int(hh.get("level", 1))))
		var now_xp := float(hh.get("xp", 0.0))
		var leveled := int(result.get("level_after", 0)) > int(result.get("level_before", 0)) and int(result.get("level_before", 0)) > 0
		var start_xp := 0.0 if leveled else maxf(0.0, now_xp - float(xp))
		var xp_row := VBoxContainer.new()
		xp_row.add_theme_constant_override("separation", 2)
		var xp_cap := _mk_label("Level %d  ·  %d / %d experience" % [int(hh.get("level", 1)), int(now_xp), int(need)], 15, Color(0.88, 0.82, 0.68))
		xp_cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		xp_row.add_child(xp_cap)
		# Plan 458: the same forged gold gauge as the hero's battle experience
		# on the HUD (it was a flat rounded bar).
		var xbar := _mk_bar(Color(0.95, 0.74, 0.3))
		xbar.custom_minimum_size = Vector2(440, 18)
		xbar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		xbar.max_value = need
		xbar.value = start_xp
		xp_row.add_child(xbar)
		box.add_child(xp_row)
		xbar.create_tween().tween_property(xbar, "value", now_xp, 1.4).set_delay(_result_hold + 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var recs: Dictionary = result.get("records", {})
	if bool(recs.get("new_fastest", false)) or bool(recs.get("new_race_best", false)):
		var parts: Array = []
		if bool(recs.get("new_race_best", false)):
			parts.append("deepest stage with this people")
		if bool(recs.get("new_fastest", false)):
			parts.append("fastest clear of this stage (%d:%02d)" % [int(result.get("time", 0)) / 60, int(result.get("time", 0)) % 60])
		var rec_line := _mk_title_label("New record: " + " and ".join(parts), 16, Color(0.98, 0.78, 0.40))
		rec_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rec_line.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		rec_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(rec_line)
	if int(result.get("talent_points", 0)) > 0:
		var tal_line := _mk_title_label("A talent choice awaits on the Hero sheet (%d to pick)" % int(result["talent_points"]), 16, Color(1.0, 0.86, 0.5))
		tal_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(tal_line)
	# Gear taken from the field, in rarity colour.
	var loot_colors := {"common": Color(0.8, 0.8, 0.8), "uncommon": Color(0.45, 0.9, 0.45), "rare": Color(0.45, 0.65, 1.0), "epic": Color(0.75, 0.5, 1.0), "legendary": Color(1.0, 0.75, 0.3)}
	# Best finds first, at most five lines: a rich Endless Road win dropped a
	# dozen items and pushed the buttons off a 1366x768 screen.
	var loot_order := ["legendary", "epic", "rare", "uncommon", "common"]
	var loot_sorted: Array = (result.get("loot", []) as Array).duplicate()
	loot_sorted.sort_custom(func(a, b): return loot_order.find(String(a.get("rarity", "common"))) < loot_order.find(String(b.get("rarity", "common"))))
	var loot_cap := 3 if compact else 5
	for it in loot_sorted.slice(0, loot_cap):
		var loot_line := _loot_row(it, loot_colors.get(String(it.get("rarity", "common")), Color.WHITE))
		if String(it.get("rarity", "")) in ["epic", "legendary"]:
			loot_line.set_meta("rare_pop", true)
		box.add_child(loot_line)
	if loot_sorted.size() > loot_cap:
		var more := _mk_label("...and %d more in the War Chest" % (loot_sorted.size() - loot_cap), 15, Color(0.8, 0.76, 0.66))
		more.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(more)
	# First loot ever: point the player at the War Chest once.
	if not result.get("loot", []).is_empty() and not bool(ProfileManager.settings().get("seen_loot_tip", false)):
		ProfileManager.update_setting("seen_loot_tip", true)
		var tip := _mk_label("Tip: open the War Chest from the hero sheet to equip gear or salvage it into experience.", 14, Color(0.8, 0.9, 1.0))
		tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tip.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		box.add_child(tip)
	var story_bits: Array = []
	if int(result.get("hero_kills", 0)) > 0:
		story_bits.append("Your hero slew %d" % int(result.get("hero_kills", 0)))
	if int(result.get("veterans_made", 0)) > 0:
		story_bits.append("%d veteran promotion%s" % [int(result.get("veterans_made", 0)), "" if int(result.get("veterans_made", 0)) == 1 else "s"])
	if int(result.get("spells_cast", 0)) > 0:
		story_bits.append("%d spell%s cast" % [int(result.get("spells_cast", 0)), "" if int(result.get("spells_cast", 0)) == 1 else "s"])
	if int(result.get("jars_dug", 0)) > 0:
		story_bits.append("%d Lume jar%s dug up" % [int(result.get("jars_dug", 0)), "" if int(result.get("jars_dug", 0)) == 1 else "s"])
	if int(result.get("veins_held", 0)) > 0:
		story_bits.append("%d vein%s held" % [int(result.get("veins_held", 0)), "" if int(result.get("veins_held", 0)) == 1 else "s"])
	if not story_bits.is_empty():
		var story_line := _mk_label("  ·  ".join(story_bits), 15, Color(0.86, 0.80, 0.62))
		story_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		story_line.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		box.add_child(story_line)
	# The battle at a glance: each side's soldiers over time, in team colours.
	var timeline: Array = result.get("army_timeline", [])
	if not compact and timeline.size() >= 3:
		box.add_child(_army_chart(timeline))
	var rule := ColorRect.new()
	rule.color = Color(accent, 0.45)
	rule.custom_minimum_size = Vector2(0, 2)
	box.add_child(rule)
	var ledger := GridContainer.new()
	ledger.columns = 5
	ledger.add_theme_constant_override("h_separation", 36)
	ledger.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(ledger)
	for stat in [["ENEMIES DEFEATED", str(kills)], ["BUILDINGS RAZED", str(int(result.get("building_kills", 0)))], ["UNITS LOST", str(int(result.get("units_lost", 0)))], ["EXPERIENCE", "+%d" % xp], ["BATTLE TIME", "%d:%02d" % [mins, secs]]]:
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 2)
		var value := _mk_title_label(String(stat[1]), 34, Color(0.96, 0.92, 0.82))
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		# The figure sets the cell's width, never the caption under it: a four
		# digit experience gain lost its last digit ("+1100" read "+110").
		value.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		value.clip_text = false
		cell.add_child(value)
		var caption := _mk_label(String(stat[0]), 14, Color(0.82, 0.78, 0.70))
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		cell.add_child(caption)
		ledger.add_child(cell)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	box.add_child(spacer)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 24)
	box.add_child(btn_row)

	# Plan 457: the result buttons are the game's menu buttons (title face,
	# forged frame), like the pause menu's, not the HUD's plain body text.
	var continue_btn := _mk_menu_button("Continue", 22)
	continue_btn.custom_minimum_size = Vector2(200, 56)
	continue_btn.pressed.connect(func(): emit_signal("return_to_menu"))
	btn_row.add_child(continue_btn)

	var replay_btn := _mk_menu_button("Play Again", 22)
	replay_btn.custom_minimum_size = Vector2(200, 56)
	replay_btn.pressed.connect(func(): emit_signal("replay"))
	btn_row.add_child(replay_btn)

	# --- Presentation: the moment of the result -------------------------------
	# Victory: slow golden rays behind the plate. Defeat: a cold red glow.
	var rays := Control.new()
	rays.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gameover_layer.add_child(rays)
	_gameover_layer.move_child(rays, 1)
	var ray_col := Color(1.0, 0.82, 0.42) if victory else Color(0.8, 0.18, 0.14)
	rays.draw.connect(func():
		var c := rays.size * 0.5
		var reach := rays.size.length() * 0.6
		var spin := float(rays.get_meta("spin")) if rays.has_meta("spin") else 0.0
		if victory:
			for k in 18:
				var a0 := spin + k * TAU / 18.0
				rays.draw_colored_polygon(PackedVector2Array([c, c + Vector2(cos(a0 - 0.05), sin(a0 - 0.05)) * reach, c + Vector2(cos(a0 + 0.05), sin(a0 + 0.05)) * reach]), Color(ray_col, 0.05))
		for q in 8:
			rays.draw_circle(c, 200.0 + q * 60.0, Color(ray_col, 0.025)))
	rays.modulate.a = 0.0
	rays.create_tween().tween_property(rays, "modulate:a", 1.0, 1.0).set_delay(_result_hold)
	var spin_tw := rays.create_tween().set_loops()
	spin_tw.tween_method(func(v: float):
		rays.set_meta("spin", v)
		rays.queue_redraw(), 0.0, TAU / 18.0, 6.0)
	# The title lands: it drops in large and settles.
	heading.pivot_offset = Vector2(310, 40)
	heading.scale = Vector2.ONE * 1.6
	heading.modulate.a = 0.0
	var h_tw := heading.create_tween().set_parallel(true)
	h_tw.tween_property(heading, "scale", Vector2.ONE, 0.55).set_delay(_result_hold + 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	h_tw.tween_property(heading, "modulate:a", 1.0, 0.3).set_delay(_result_hold + 0.35)
	# The ledger lines reveal one after another, then the numbers count up.
	# A long ledger (loot, deeds, talents) pushed the buttons past 4.5 s
	# after a defeat: the whole reveal now fits in 1.2 s whatever its length.
	var order := 0
	var reveal_step := minf(0.12, 1.2 / maxf(1.0, float(box.get_child_count() - 1)))
	for child in box.get_children():
		if child == heading:
			continue
		child.modulate.a = 0.0
		child.create_tween().tween_property(child, "modulate:a", 1.0, 0.3).set_delay(_result_hold + 0.8 + order * reveal_step)
		# Epic and legendary finds land with a pop and a chime.
		if child.has_meta("rare_pop") and child is Control:
			var rc: Control = child
			var pop := rc.create_tween()
			pop.tween_interval(_result_hold + 0.8 + order * reveal_step)
			pop.tween_callback(func():
				rc.pivot_offset = rc.size * 0.5
				rc.scale = Vector2(1.25, 1.25)
				Sfx.play("levelup", -8.0))
			pop.tween_property(rc, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		order += 1
	for cell in ledger.get_children():
		var value_label: Label = cell.get_child(0) as Label
		var final_text := value_label.text
		var digits := final_text.replace("+", "")
		if not digits.is_valid_int():
			continue
		var target := int(digits)
		var prefix := "+" if final_text.begins_with("+") else ""
		value_label.text = prefix + "0"
		value_label.create_tween().tween_method(func(v: float): value_label.text = prefix + str(int(v)), 0.0, float(target), 1.1).set_delay(_result_hold + 0.9 + order * reveal_step).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## One find on the result screen: a faceted gem in the rarity's colour, the
## item's name, and its rarity in small letters.
func _loot_row(it: Dictionary, col: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	var rarity := String(it.get("rarity", "common"))
	# Plan 346: each find shows its own picture in a rarity-framed tile (the
	# same art as the War Chest), not a small diamond.
	var gem := Control.new()
	gem.custom_minimum_size = Vector2(34, 34)
	gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var icon_name: String = load("res://scripts/ui/inventory.gd").gear_icon_name(String(it.get("slot", "")), String(it.get("name", "")))
	var pic: Texture2D = load("res://scripts/ui/skill_icons.gd").icon_texture(icon_name, 64)
	gem.draw.connect(func():
		var r := Rect2(Vector2.ZERO, gem.size)
		if rarity in ["epic", "legendary"]:
			gem.draw_rect(r.grow(3.0), Color(col, 0.18))
		gem.draw_rect(r, Color(0.03, 0.03, 0.04, 0.95))
		for k in 4:
			gem.draw_rect(r.grow(-2.0 - k * 2.0), Color(col, 0.10 - k * 0.02), false, 2.0)
		if pic:
			gem.draw_texture_rect(pic, r.grow(-2.5), false, col.lerp(Color(1, 0.96, 0.88), 0.55))
		gem.draw_rect(r, col.darkened(0.15), false, 2.0)
		gem.draw_rect(r.grow(-2.5), Color(0, 0, 0, 0.6), false, 1.0))
	row.add_child(gem)
	var name_lbl := _mk_label(String(it.get("name", "")), 16, col)
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	row.add_child(name_lbl)
	var tag := _mk_label(rarity.to_upper(), 14, Color(col, 0.9))
	tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tag.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	row.add_child(tag)
	return row


## Laurel sprigs either side of the result title: leaves along a rising
## arc, each a pointed oval with a darker midrib.
func _draw_title_laurels(lbl: Label, fs: int, col: Color) -> void:
	var font := lbl.get_theme_font("font")
	var tw := font.get_string_size(lbl.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var mid := lbl.size * 0.5
	var leaf_len := fs * 0.30
	for side in [-1.0, 1.0]:
		var base := mid + Vector2(float(side) * (tw * 0.5 + fs * 0.32), fs * 0.30)
		var stem := PackedVector2Array()
		for k in 8:
			var t := float(k) / 7.0
			stem.append(base + Vector2(float(side) * sin(t * 1.3) * fs * 0.42, -t * fs * 0.72))
		lbl.draw_polyline(stem, col.darkened(0.25), 2.0, true)
		for k in range(1, 8):
			var t := float(k) / 7.0
			var at := stem[k]
			var dir := (stem[k] - stem[k - 1]).normalized()
			for flank in [-1.0, 1.0]:
				var out := dir.rotated(float(flank) * 0.8)
				var tip := at + out * leaf_len * (1.0 - t * 0.35)
				var perp := Vector2(-out.y, out.x) * leaf_len * 0.22
				var midp := (at + tip) * 0.5
				var leaf := PackedVector2Array([at, midp + perp, tip, midp - perp])
				lbl.draw_colored_polygon(leaf, col.lerp(Color(1, 0.95, 0.75), 0.15 if flank > 0 else 0.0).darkened(0.05 * k))
				lbl.draw_line(at, tip, col.darkened(0.45), 1.0, true)
		lbl.draw_circle(base, 2.5, col.darkened(0.2))


## A gilt rule under the result title: two tapering lines and a centre diamond.
func _title_rule(col: Color) -> Control:
	var rule := Control.new()
	rule.custom_minimum_size = Vector2(0, 14)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.draw.connect(func():
		var c := rule.size * 0.5
		var span := minf(rule.size.x * 0.5 - 10.0, 230.0)
		for side in [-1.0, 1.0]:
			for k in 6:
				var a0 := 12.0 + span * float(k) / 6.0
				var a1 := 12.0 + span * float(k + 1) / 6.0
				rule.draw_line(c + Vector2(float(side) * a0, 0), c + Vector2(float(side) * a1, 0), Color(col, 0.85 * (1.0 - float(k) / 6.0)), 1.6, true)
			rule.draw_circle(c + Vector2(float(side) * 20.0, 0), 2.0, Color(col, 0.9))
		var d := 6.0
		rule.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), col)
		rule.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d * 0.45), c + Vector2(d * 0.45, 0), c + Vector2(0, d * 0.45), c + Vector2(-d * 0.45, 0)]), col.darkened(0.45)))
	return rule


## A small line chart of soldiers per side across the battle, your host in
## your colour and each rival in theirs, over faint minute ticks.
func _army_chart(timeline: Array) -> Control:
	var chart := Control.new()
	chart.custom_minimum_size = Vector2(460, 74)
	chart.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	chart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var peak := 1
	for row in timeline:
		for v in row:
			peak = maxi(peak, int(v))
	chart.draw.connect(func():
		var w := chart.size.x
		var h := chart.size.y - 14.0
		chart.draw_line(Vector2(0, h), Vector2(w, h), Color(0.8, 0.7, 0.5, 0.35), 1.0)
		var steps := timeline.size() - 1
		# Minute ticks (a sample every ten seconds).
		for k in range(0, timeline.size(), 6):
			var tx := w * float(k) / float(steps)
			chart.draw_line(Vector2(tx, h - 3.0), Vector2(tx, h + 3.0), Color(0.8, 0.7, 0.5, 0.35), 1.0)
		var sides := (timeline[0] as Array).size()
		for team in range(sides - 1, -1, -1):
			var pts := PackedVector2Array()
			for k in timeline.size():
				var row: Array = timeline[k]
				var v := int(row[team]) if team < row.size() else 0
				pts.append(Vector2(w * float(k) / float(steps), h - (h - 4.0) * float(v) / float(peak)))
			var col: Color = GameData.TEAM_COLORS.get(team, Color.WHITE)
			chart.draw_polyline(pts, Color(col, 0.25), 5.0 if team == 0 else 3.0, true)
			chart.draw_polyline(pts, col, 2.0 if team == 0 else 1.4, true)
		var font := _body_font if _body_font else ThemeDB.fallback_font
		chart.draw_string(font, Vector2(0, chart.size.y), "YOUR HOST AND THEIRS, SOLDIERS OVER THE BATTLE", HORIZONTAL_ALIGNMENT_CENTER, w, 11, Color(0.8, 0.74, 0.6, 0.8)))
	return chart


var _key_card: Control

## Every hotkey on one gilt card (F1), from the same field manual as Settings.
func toggle_key_card() -> void:
	if is_instance_valid(_key_card):
		_key_card.queue_free()
		_key_card = null
		return
	Sfx.play("page", -8.0)
	var plate: PanelContainer = load("res://scripts/ui/hero_sheet_plate.gd").new()
	plate.surface_alpha = 0.95
	plate.surface_alpha_bottom = 0.92
	plate.forged = true
	var pad := StyleBoxEmpty.new()
	pad.content_margin_left = 36.0
	pad.content_margin_right = 36.0
	pad.content_margin_top = 26.0
	pad.content_margin_bottom = 26.0
	plate.add_theme_stylebox_override("panel", pad)
	plate.mouse_filter = Control.MOUSE_FILTER_STOP
	plate.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	plate.grow_horizontal = Control.GROW_DIRECTION_BOTH
	plate.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(plate)
	_key_card = plate
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	plate.add_child(box)
	var head := _mk_title_label("FIELD MANUAL", 26, COMMAND_GOLD)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(head)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_theme_constant_override("v_separation", 7)
	box.add_child(grid)
	for row in load("res://scripts/ui/settings.gd").CONTROLS:
		var k := _mk_label(String(row[0]), 14, COMMAND_GOLD)
		k.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		grid.add_child(k)
		var d := _mk_label(KeyBinds.fill(String(row[1])), 15, Color(0.92, 0.9, 0.84))
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		# Wide lines: at 560 the manual's twenty entries stood taller than the screen.
		d.custom_minimum_size = Vector2(860, 0)
		grid.add_child(d)
	var foot := _mk_label("F1 closes this card  ·  Backspace jumps to the latest alert", 13, Color(0.72, 0.68, 0.58))
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(foot)
	plate.modulate.a = 0.0
	plate.create_tween().tween_property(plate, "modulate:a", 1.0, 0.15)


## A top-bar counter that acts when clicked (idle workers, idle army).
func _make_metric_clickable(surface: Control, method: String, tip: String) -> void:
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	surface.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	surface.tooltip_text = tip
	surface.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and is_instance_valid(rts) and rts.has_method(method):
			Sfx.play("select", -6.0)
			rts.call(method)
			accept_event())


## The emblem on a people or signature spell's card.
## Signature spells are written in code, so their emblem glyph is named here.
const SIGNATURE_GLYPHS := {"sig_bull": "line", "sig_spring": "heal", "sig_ashglass": "rain", "sig_chains": "fury",
	"sig_moura": "stun", "sig_stoneskin": "ward", "sig_sunfire": "strike", "sig_pack": "summon",
	"sig_candles": "summon", "sig_entrudo": "flee",
	# The hero's own skill-tree spells: one painted Rallying Cry beside drawn
	# people emblems read as two different games on one card.
	"rally": "heal", "slam": "quake", "charge": "dash", "bolt": "strike",
	"heal": "heal", "root": "root", "avatar": "fury"}

# Original painted ability illustrations. Stable IDs select art only; native spell rules remain in SkillDefs/Unit.
const ABILITY_PAINTINGS := {
	"bar_horn": "res://assets/ui/ability_illustrations/barrosan_candidate_r1/bar_horn_r1.png",
	"bar_levy": "res://assets/ui/ability_illustrations/barrosan_candidate_r1/bar_levy_r2.png",
	"sig_bull": "res://assets/ui/ability_illustrations/r44/sig_bull.png",
	"slam": "res://assets/ui/ability_illustrations/r44/slam.png",
	"rally": "res://assets/ui/ability_illustrations/r44/rally.png",
	"bolt": "res://assets/ui/ability_illustrations/r44/bolt.png",
	"heal": "res://assets/ui/ability_illustrations/r44/heal.png",
	"root": "res://assets/ui/ability_illustrations/r44/root.png",
	"charge": "res://assets/ui/ability_illustrations/r44/charge.png",
	"sig_stoneskin": "res://assets/ui/ability_illustrations/r44/sig_stoneskin.png",
	"avatar": "res://assets/ui/ability_illustrations/r44/avatar.png",
	"sig_spring": "res://assets/ui/ability_illustrations/r44/sig_spring.png",
	"sig_ashglass": "res://assets/ui/ability_illustrations/r44/sig_ashglass.png",
	"sig_chains": "res://assets/ui/ability_illustrations/r44/sig_chains.png",
	"sig_moura": "res://assets/ui/ability_illustrations/r44/sig_moura.png",
	"sig_pack": "res://assets/ui/ability_illustrations/r44/sig_pack.png",
	"sig_candles": "res://assets/ui/ability_illustrations/r44/sig_candles.png",
	"sig_entrudo": "res://assets/ui/ability_illustrations/r44/sig_entrudo.png",
	"sig_sunfire": "res://assets/ui/ability_illustrations/r44/sig_sunfire.png",
}

func _spell_emblem(ab: Dictionary, race: String, spell_id: String = "") -> Control:
	var e := Control.new()
	e.name = "SpellEmblem"
	e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	e.position = Vector2(4, 4)
	e.size = Vector2(68, 68)
	if ABILITY_PAINTINGS.has(spell_id) and ResourceLoader.exists(String(ABILITY_PAINTINGS[spell_id])):
		var painting := load(String(ABILITY_PAINTINGS[spell_id])) as Texture2D
		if painting:
			var picture := TextureRect.new()
			picture.name = "AbilityPainting"
			picture.texture = painting
			picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			picture.size = e.size
			picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
			picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			e.add_child(picture)
			e.set_meta("ability_painting_id", spell_id)
			return e
	var tint: Color = ab.get("tint", GameData.RACES.get(race, {}).get("color", Color(1, 0.8, 0.4)))
	# What the spell does decides its glyph, so no two spells of a people
	# share a picture (all three used to show the same sigil).
	var kind := "strike"
	for st in ab.get("fx", []):
		match String(st.get("op", "")):
			"summon": kind = "summon"
			"heal": kind = "heal"
			"flee": kind = "flee"
			"dash": kind = "dash"
			"repair": kind = "repair"
			"buff":
				if kind == "strike":
					kind = "ward" if float(st.get("armor", 0.0)) > 0.0 else "fury"
			"damage":
				if kind == "strike":
					if String(st.get("at", "")) == "line": kind = "line"
					elif bool(st.get("drain", false)): kind = "drain"
					elif int(st.get("waves", 1)) > 1 and not st.has("root"): kind = "rain"
					elif st.has("root"): kind = "root"
					elif st.has("stun") and String(st.get("at", "")) == "hero": kind = "quake"
					elif st.has("stun"): kind = "stun"
					elif String(st.get("at", "")) == "hero": kind = "nova"
	kind = String(SIGNATURE_GLYPHS.get(spell_id, kind))
	e.draw.connect(_draw_spell_emblem.bind(e, kind, tint, race, bool(ab.get("sig", false))))
	return e

func _draw_spell_emblem(e: Control, kind: String, tint: Color, race: String, is_sig: bool = false) -> void:
	var c := e.size * 0.5
	var ink := tint.lightened(0.45)
	e.draw_rect(Rect2(Vector2.ZERO, e.size), Color(0.03, 0.035, 0.05, 1.0))
	e.draw_circle(c, 30.0, Color(tint, 0.22))
	e.draw_arc(c, 29.0, 0.0, TAU, 40, Color(tint, 0.9), 2.0, true)
	if is_sig:
		e.draw_arc(c, 25.0, 0.0, TAU, 40, Color(1.0, 0.9, 0.6, 0.75), 1.2, true)
	var g := c + Vector2(-3, -3)
	match kind:
		"heal":
			e.draw_rect(Rect2(g + Vector2(-4, -14), Vector2(8, 28)), ink)
			e.draw_rect(Rect2(g + Vector2(-14, -4), Vector2(28, 8)), ink)
		"ward":
			e.draw_colored_polygon(PackedVector2Array([g + Vector2(-13, -14), g + Vector2(13, -14), g + Vector2(13, 2), g + Vector2(0, 16), g + Vector2(-13, 2)]), ink)
			e.draw_line(g + Vector2(0, -12), g + Vector2(0, 12), Color(0.03, 0.035, 0.05, 0.8), 2.0)
		"repair":
			for row in 3:
				var y := -13.0 + row * 9.0
				if row == 1:
					e.draw_rect(Rect2(g + Vector2(-14, y), Vector2(5, 7)), ink)
					e.draw_rect(Rect2(g + Vector2(-7, y), Vector2(12, 7)), ink)
					e.draw_rect(Rect2(g + Vector2(7, y), Vector2(6, 7)), ink)
				else:
					e.draw_rect(Rect2(g + Vector2(-14, y), Vector2(12, 7)), ink)
					e.draw_rect(Rect2(g + Vector2(1, y), Vector2(12, 7)), ink)
		"summon":
			for dx in [-9.0, 9.0]:
				e.draw_circle(g + Vector2(dx, -8), 5.0, ink)
				e.draw_colored_polygon(PackedVector2Array([g + Vector2(dx - 7, 14), g + Vector2(dx - 5, -1), g + Vector2(dx + 5, -1), g + Vector2(dx + 7, 14)]), ink)
		"fury":
			for k in 2:
				var top := g + Vector2(0, -15 + k * 12)
				e.draw_colored_polygon(PackedVector2Array([top, top + Vector2(14, 12), top + Vector2(8, 12), top + Vector2(0, 5), top + Vector2(-8, 12), top + Vector2(-14, 12)]), ink)
		"line":
			for k in 3:
				var tip := g + Vector2(-12 + k * 11, 0)
				e.draw_colored_polygon(PackedVector2Array([tip + Vector2(-5, -12), tip + Vector2(7, 0), tip + Vector2(-5, 12), tip + Vector2(-1, 0)]), Color(ink, 0.55 + 0.22 * k))
		"rain":
			for k in 3:
				var top2 := g + Vector2(-11 + k * 11, -14 + (4 if k == 1 else 0))
				e.draw_line(top2, top2 + Vector2(-4, 20), ink, 2.5, true)
				e.draw_colored_polygon(PackedVector2Array([top2 + Vector2(-8, 17), top2 + Vector2(0, 19), top2 + Vector2(-6, 26)]), ink)
		"root":
			e.draw_arc(g, 9.0, 0.0, TAU, 24, ink, 2.5, true)
			for k in 8:
				var a := TAU * float(k) / 8.0
				e.draw_line(g + Vector2(cos(a), sin(a)) * 9.0, g + Vector2(cos(a), sin(a)) * 16.0, ink, 2.5, true)
		"stun":
			for k in 3:
				e.draw_arc(g, 5.0 + k * 5.5, -0.6 + k * 1.3, 3.4 + k * 1.3, 18, ink, 2.5, true)
		"quake":
			e.draw_polyline(PackedVector2Array([g + Vector2(-15, 6), g + Vector2(-7, -8), g + Vector2(-2, 3), g + Vector2(4, -12), g + Vector2(9, 4), g + Vector2(15, -5)]), ink, 3.0, true)
			e.draw_line(g + Vector2(-15, 13), g + Vector2(15, 13), ink, 2.5, true)
		"nova":
			e.draw_circle(g, 5.0, ink)
			for k in 8:
				var a2 := TAU * float(k) / 8.0 + 0.2
				e.draw_colored_polygon(PackedVector2Array([g + Vector2(cos(a2 - 0.16), sin(a2 - 0.16)) * 8.0, g + Vector2(cos(a2), sin(a2)) * 17.0, g + Vector2(cos(a2 + 0.16), sin(a2 + 0.16)) * 8.0]), ink)
		"drain":
			e.draw_circle(g + Vector2(0, 5), 9.0, ink)
			e.draw_colored_polygon(PackedVector2Array([g + Vector2(-8, 1), g + Vector2(0, -15), g + Vector2(8, 1)]), ink)
		"dash":
			e.draw_arc(g + Vector2(4, 0), 13.0, 1.9, 4.4, 20, ink, 3.0, true)
			e.draw_colored_polygon(PackedVector2Array([g + Vector2(-2, -14), g + Vector2(14, -8), g + Vector2(1, -2)]), ink)
		"flee":
			e.draw_circle(g, 4.0, ink)
			for k in 4:
				var a3 := TAU * float(k) / 4.0 + PI * 0.25
				var dir := Vector2(cos(a3), sin(a3))
				e.draw_line(g + dir * 7.0, g + dir * 15.0, ink, 2.5, true)
				e.draw_colored_polygon(PackedVector2Array([g + dir * 18.0, g + dir * 12.0 + dir.orthogonal() * 4.5, g + dir * 12.0 - dir.orthogonal() * 4.5]), ink)
		_:
			e.draw_colored_polygon(PackedVector2Array([g + Vector2(2, -16), g + Vector2(-9, 2), g + Vector2(-1, 2), g + Vector2(-4, 16), g + Vector2(9, -3), g + Vector2(1, -3)]), ink)
	# The people's sigil sits small in the corner.
	var m := c + Vector2(19, 19)
	e.draw_circle(m, 9.0, Color(0.03, 0.03, 0.04, 0.95))
	FACTION_SIGILS.draw(e, race, m, 6.0, Color(tint.lightened(0.2), 0.95))
