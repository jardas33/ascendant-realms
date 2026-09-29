extends Control
## Campaign Map: the Saga of the Seventy-Seventh Ascension (CampaignDefs).
## Five Acts, each a page of battles along a main road with optional side
## roads. Clicking a battle opens its chronicle briefing; "March to war"
## starts it. The jars of Wine of the Dead and the Rabagão Wall choice are
## shown in the header.
const CampaignDefs := preload("res://scripts/game/campaign_defs.gd")
const EndlessDefs := preload("res://scripts/game/endless_defs.gd")

const FONT := "res://assets/fonts/cinzel.ttf"
const BG   := "res://assets/textures/backgrounds/main_menu_bg.png"
const THEME_PATH := "res://assets/ui/theme.tres"
const REGION_BUTTON_SCRIPT := preload("res://scripts/ui/campaign_region_button.gd")
const PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")
const FACTION_SIGILS := preload("res://scripts/ui/faction_sigils.gd")

const NODE_SIZE := Vector2(236, 142)
const DIFF_COLORS := {
	"Easy":   Color(0.4, 0.85, 0.45),
	"Normal": Color(0.7, 0.85, 0.3),
	"Hard":   Color(0.95, 0.6, 0.2),
	"Brutal": Color(0.95, 0.25, 0.2),
}

var _canvas: Control
var _desc_label: Label
var _act := 0
var _act_layer: Control
var _act_title: Label
var _act_subtitle: Label
var _act_buttons: Array = []
var _positions := {}          # chapter id -> Vector2 centre
var _next_id := "1-1"
var _briefing: Control
var _mood: ColorRect
## Each Act tints the realm map: ember for the raid, drowned teal, grave
## blue-grey, Dominion bronze, and the violet of the Ascension.
const ACT_MOODS := [Color(0.55, 0.25, 0.05, 0.16), Color(0.05, 0.35, 0.40, 0.16), Color(0.25, 0.30, 0.45, 0.20), Color(0.55, 0.42, 0.12, 0.16), Color(0.40, 0.12, 0.55, 0.20)]

# --------------------------------------------------------------------------
func _ready() -> void:
	_next_id = _find_next_chapter()
	var next := CampaignDefs.find(_next_id)
	_act = int(next.get("act", 0))
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

## The first unlocked, uncleared main-road chapter (else the first side road).
func _find_next_chapter() -> String:
	var s := ProfileManager.saga()
	var fallback := ""
	for c in CampaignDefs.all():
		var id := String(c["id"])
		if not ProfileManager.chapter_available(id) or id in s["cleared"]:
			continue
		if not bool(c.get("side", false)):
			return id
		if fallback == "":
			fallback = id
	return fallback if fallback != "" else "5-7"

func _label(text: String, size: int, col: Color, title_font := false) -> Label:
	var l := Label.new()
	l.text = text
	# Story text reads in the plain body face; Cinzel small caps is for titles.
	l.add_theme_font_override("font", _title_font() if title_font else ThemeDB.fallback_font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 4 if title_font else 2)
	return l

# --------------------------------------------------------------------------
func _build() -> void:
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if ResourceLoader.exists(BG):
		bg.texture = load(BG)
	add_child(bg)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.07, 0.6)
	add_child(scrim)
	_mood = ColorRect.new()
	_mood.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mood.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_mood)

	var title := _label("The Seventy-Seventh Ascension", 38, Color(0.97, 0.92, 0.68), true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 10.0
	title.offset_bottom = 60.0
	add_child(title)

	# Hero, jars and choice.
	var s := ProfileManager.saga()
	var h: Dictionary = ProfileManager.hero()
	var hero_line := "No Jardas yet. Forge one from the main menu." if h.is_empty() else "%s, Jardas of the %s  ·  Level %d" % [str(h.get("name", "Hero")), str(GameData.get_race(_hero_race()).get("name", _hero_race())), int(h.get("level", 1))]
	var jars := "Wine of the Dead: %d / %d jars" % [s["jars"].size(), CampaignDefs.JARS_TOTAL]
	var choice := ""
	if String(s["choice"]) == "break":
		choice = "  ·  The Wall is broken"
	elif String(s["choice"]) == "seize":
		choice = "  ·  The Wall is yours"
	var banner := _label("%s  ·  %s%s" % [hero_line, jars, choice], 16, Color(0.85, 0.78, 0.5), true)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	banner.offset_top = 60.0
	banner.offset_bottom = 86.0
	add_child(banner)

	# Act tabs.
	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 10)
	tabs.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	tabs.offset_top = 92.0
	tabs.offset_bottom = 132.0
	add_child(tabs)
	# Act tabs are wax seals: the open Act glows, sealed Acts are dark iron.
	var act_group := ButtonGroup.new()
	for a in CampaignDefs.ACTS.size():
		var b := Button.new()
		b.text = ["I", "II", "III", "IV", "V"][a]
		b.custom_minimum_size = Vector2(46, 46)
		b.focus_mode = Control.FOCUS_NONE
		b.toggle_mode = true
		b.button_group = act_group
		b.add_theme_font_override("font", _title_font())
		b.add_theme_font_size_override("font_size", 18)
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			var sb := StyleBoxFlat.new()
			sb.set_corner_radius_all(23)
			sb.set_border_width_all(2)
			match state:
				"pressed", "hover_pressed":
					sb.bg_color = Color(0.62, 0.14, 0.1)
					sb.border_color = Color(1.0, 0.84, 0.46)
					sb.shadow_color = Color(1.0, 0.7, 0.3, 0.45)
					sb.shadow_size = 8
				"hover":
					sb.bg_color = Color(0.42, 0.1, 0.08)
					sb.border_color = Color(1.0, 0.84, 0.46)
				"disabled":
					sb.bg_color = Color(0.12, 0.13, 0.15)
					sb.border_color = Color(0.36, 0.4, 0.46)
				_:
					sb.bg_color = Color(0.34, 0.08, 0.06)
					sb.border_color = Color(0.82, 0.64, 0.34)
			b.add_theme_stylebox_override(state, sb)
		b.add_theme_color_override("font_color", Color(0.98, 0.9, 0.7))
		b.add_theme_color_override("font_pressed_color", Color(1, 0.96, 0.82))
		b.add_theme_color_override("font_hover_pressed_color", Color(1, 0.96, 0.82))
		b.add_theme_color_override("font_disabled_color", Color(0.5, 0.52, 0.56))
		b.disabled = not _act_reached(a)
		b.tooltip_text = String(CampaignDefs.ACTS[a]["title"]) if _act_reached(a) else "Sealed"
		b.pressed.connect(func(): _show_act(a))
		tabs.add_child(b)
		_act_buttons.append(b)

	_act_title = _label("", 26, Color(0.98, 0.84, 0.46), true)
	_act_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_act_title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_act_title.offset_top = 136.0
	_act_title.offset_bottom = 172.0
	add_child(_act_title)
	_act_subtitle = _label("", 16, Color(0.82, 0.78, 0.68))
	_act_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_act_subtitle.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_act_subtitle.offset_top = 170.0
	_act_subtitle.offset_bottom = 196.0
	add_child(_act_subtitle)

	_canvas = Control.new()
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_path)
	add_child(_canvas)
	_act_layer = Control.new()
	_act_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_act_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_act_layer)

	# The story strip under the map sits on the same gilt plate as every
	# other panel in the game.
	var desc_panel: PanelContainer = PLATE_SCRIPT.new()
	desc_panel.set("surface_alpha", 0.9)
	desc_panel.set("surface_alpha_bottom", 0.94)
	desc_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	desc_panel.offset_top = -168.0
	desc_panel.offset_bottom = -72.0
	desc_panel.offset_left = 240.0
	desc_panel.offset_right = -240.0
	var story_style := StyleBoxFlat.new()
	story_style.bg_color = Color.TRANSPARENT
	story_style.set_content_margin_all(12)
	desc_panel.add_theme_stylebox_override("panel", story_style)
	add_child(desc_panel)
	_desc_label = Label.new()
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.add_theme_font_override("font", ThemeDB.fallback_font)
	_desc_label.add_theme_font_size_override("font_size", 18)
	_desc_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.78))
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_desc_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_desc_label.offset_left = 12.0
	_desc_label.offset_right = -12.0
	desc_panel.add_child(_desc_label)

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

	# The Chronicle: every cleared chapter's story, to reread in order.
	var chronicle := Button.new()
	chronicle.text = "Chronicle"
	chronicle.custom_minimum_size = Vector2(190, 50)
	chronicle.focus_mode = Control.FOCUS_NONE
	if ResourceLoader.exists(THEME_PATH):
		chronicle.theme = load(THEME_PATH)
	chronicle.add_theme_font_override("font", _title_font())
	chronicle.add_theme_font_size_override("font_size", 20)
	chronicle.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	chronicle.offset_left = -226.0
	chronicle.offset_right = -36.0
	chronicle.offset_top = -66.0
	chronicle.offset_bottom = -16.0
	chronicle.disabled = ProfileManager.saga()["cleared"].is_empty()
	chronicle.pressed.connect(_open_chronicle)
	add_child(chronicle)

	# The Endless Road opens once the first chapter is won.
	var endless := Button.new()
	endless.text = "Endless Road"
	endless.custom_minimum_size = Vector2(210, 50)
	endless.focus_mode = Control.FOCUS_NONE
	if ResourceLoader.exists(THEME_PATH):
		endless.theme = load(THEME_PATH)
	endless.add_theme_font_override("font", _title_font())
	endless.add_theme_font_size_override("font_size", 20)
	endless.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	endless.offset_left = -456.0
	endless.offset_right = -246.0
	endless.offset_top = -66.0
	endless.offset_bottom = -16.0
	endless.disabled = ProfileManager.saga()["cleared"].is_empty()
	endless.tooltip_text = "Win your first chapter to open the Endless Road." if endless.disabled else "Stage after stage, deeper each time, with records to beat."
	chronicle.tooltip_text = "Win a chapter to begin the Chronicle." if chronicle.disabled else "Reread the story of every chapter you have won."
	endless.pressed.connect(_open_endless)
	add_child(endless)

	_show_act(_act)
	# Just won a chapter: its seal is stamped onto the map.
	if Match.has_meta("fresh_seal"):
		var fresh := String(Match.get_meta("fresh_seal"))
		Match.remove_meta("fresh_seal")
		_stamp_seal.call_deferred(fresh)
	# Arriving from the main menu's Endless Road button.
	if Match.has_meta("open_endless"):
		Match.remove_meta("open_endless")
		call_deferred("_open_endless")
		return
	# A new Act is announced once, the first time the map shows it; after a
	# victory the next chronicle opens by itself.
	var saga_state := ProfileManager.saga()
	if not saga_state.has("seen_acts"):
		saga_state["seen_acts"] = []
	var fresh_act: bool = not (_act in saga_state["seen_acts"])
	if fresh_act:
		saga_state["seen_acts"].append(_act)
		_show_act_card(_act)
	elif bool(saga_state.get("auto_brief", false)) and ProfileManager.chapter_available(_next_id):
		_open_briefing(_next_id)
	saga_state["auto_brief"] = false
	ProfileManager.save_game()

## A book of the saga so far: each cleared chapter's briefing and the
## chronicle of its victory, act by act, in road order.
## The Endless Road: the next stage's battle, with no last stage.
func _open_endless(chosen_depth: int = -1, weekly: bool = false) -> void:
	Sfx.play("select")
	# Any stage reached can be replayed (for loot and bounties); first clears
	# still pay the milestones only once.
	var depth := ProfileManager.endless_best() + 1 if chosen_depth < 1 else clampi(chosen_depth, 1, ProfileManager.endless_best() + 1)
	var st := EndlessDefs.stage(depth, _hero_race())
	if weekly:
		st = EndlessDefs.weekly(_hero_race())
		depth = int(st["depth"])
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var plate: PanelContainer = PLATE_SCRIPT.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color.TRANSPARENT
	ps.content_margin_left = 52.0
	ps.content_margin_right = 52.0
	ps.content_margin_top = 30.0
	ps.content_margin_bottom = 30.0
	plate.add_theme_stylebox_override("panel", ps)
	plate.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	plate.grow_horizontal = Control.GROW_DIRECTION_BOTH
	plate.grow_vertical = Control.GROW_DIRECTION_BOTH
	plate.custom_minimum_size = Vector2(760, 0)
	layer.add_child(plate)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	plate.add_child(box)
	var head := _label("THE ENDLESS ROAD  ·  STAGE %d" % depth, 16, Color(0.75, 0.68, 0.52), true)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(head)
	var t := _label(String(st["title"]), 34, Color(0.98, 0.84, 0.46), true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	var body := _label(String(st["festival"]) if String(st.get("festival", "")) != "" else "The saga ends, but the Lume does not. Every Ascension leaves roads that never close, and something always waits on them. Each stage is harder than the last, and pays more.", 17, Color(0.92, 0.89, 0.80))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(656, 0)
	box.add_child(body)
	var foes: Array = []
	for o in st["opponents"]:
		foes.append("%s (%s)" % [GameData.get_race(String(o["race"])).get("name", o["race"]), String(o["difficulty"]).capitalize()])
	var extra := "   ·   Enemy Lume swollen: +%d%% income" % int(float(st["might"]) * 100.0 / 3.0) if float(st["might"]) > 0.0 else ""
	var twist_lines: Array = []
	for tw_id in st.get("twists", []):
		twist_lines.append(String(EndlessDefs.TWIST_TEXT.get(tw_id, tw_id)))
	var muts: Dictionary = st.get("mutations", {})
	for mk in muts:
		twist_lines.append("%s (x%d)" % [String(EndlessDefs.MUTATIONS.get(mk, mk)), int(muts[mk])])
	var road_boss: Dictionary = EndlessDefs.boss(depth)
	if not road_boss.is_empty():
		twist_lines.append("Road Tyrant: %s. %s" % [String(road_boss["name"]), String(road_boss["text"])])
	elif depth % 5 == 0 and depth % 10 != 0:
		twist_lines.append("Champion stage: a giant guards the enemy stronghold (pays like three Elites)")
	if not twist_lines.is_empty():
		var tw := _label("Twists: " + "  ·  ".join(twist_lines), 15, Color(0.95, 0.62, 0.42))
		tw.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(tw)
	var race_now := String(ProfileManager.hero().get("race", "")) if ProfileManager.has_hero() else ""
	var fastest := ProfileManager.endless_fastest(depth)
	var records := "   ·   Best with %s: %d" % [GameData.get_race(race_now).get("name", race_now), ProfileManager.endless_best_for(race_now)] if race_now != "" else ""
	if fastest > 0.0:
		records += "   ·   Fastest clear: %d:%02d" % [int(fastest) / 60, int(fastest) % 60]
	# Know your foe: each enemy faction's way of war, from its race entry.
	var foe_lines: Array = []
	var seen_races: Array = []
	for o in st["opponents"]:
		var r := String(o["race"])
		if seen_races.has(r):
			continue
		seen_races.append(r)
		var mech := String(GameData.get_race(r).get("mechanic", ""))
		if mech != "":
			foe_lines.append("%s: %s" % [GameData.get_race(r).get("name", r), mech])
	if not foe_lines.is_empty():
		var foe := _label("Know your foe: " + "  ·  ".join(foe_lines), 14, Color(0.86, 0.66, 0.6))
		foe.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(foe)
	# The road ahead: the next milestones, so there is always something to reach for.
	var ahead: Array = []
	var best_now := ProfileManager.endless_best()
	var next_tyrant := (depth / 25 + 1) * 25 if depth % 25 != 0 else depth
	var next_fest := (depth / 10 + 1) * 10 if depth % 10 != 0 else depth
	var next_relic := maxi(depth, (best_now / 5 + 1) * 5)
	if next_relic % 5 != 0:
		next_relic = (next_relic / 5 + 1) * 5
	ahead.append("relic at stage %d" % next_relic)
	ahead.append("festival at %d (%s)" % [next_fest, String(EndlessDefs.FESTIVALS[(next_fest / 10 - 1) % EndlessDefs.FESTIVALS.size()]["title"])])
	ahead.append("Road Tyrant at %d (%s)" % [next_tyrant, String(EndlessDefs.boss(next_tyrant).get("name", "?"))])
	var next_mut := maxi(30, (depth / 30 + 1) * 30)
	ahead.append("new enemy mutation at %d" % next_mut)
	# The road drawn: this stage as your standard, the milestones ahead as
	# waypoints on a marching road (relic chest, festival bonfire, Tyrant skull,
	# mutation eye), spaced by how far away each one is.
	var track := Control.new()
	track.custom_minimum_size = Vector2(0, 86)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.visible = not weekly
	var marks: Array = [[next_relic, "relic", Color(0.98, 0.8, 0.36)], [next_fest, "festival", Color(1.0, 0.55, 0.25)], [next_tyrant, "tyrant", Color(0.92, 0.3, 0.26)], [next_mut, "mutation", Color(0.72, 0.52, 0.98)]]
	var far := float(maxi(next_mut, next_tyrant) - depth + 1)
	var font_t := _title_font()
	track.draw.connect(func():
		var x0 := 40.0
		var x1 := track.size.x - 40.0
		var y := 34.0
		track.draw_line(Vector2(x0, y), Vector2(x1, y), Color(0.02, 0.02, 0.03, 0.8), 7.0, true)
		var k := 0
		while x0 + k * 14.0 < x1:
			track.draw_line(Vector2(x0 + k * 14.0, y), Vector2(minf(x0 + k * 14.0 + 7.0, x1), y), Color(0.99, 0.82, 0.42, 0.85), 2.6, true)
			k += 1
		# You are here.
		track.draw_circle(Vector2(x0, y), 11.0, Color(0.55, 0.12, 0.1))
		track.draw_arc(Vector2(x0, y), 11.0, 0.0, TAU, 24, Color(0.99, 0.82, 0.42), 2.0, true)
		track.draw_string(font_t, Vector2(x0 - 30, y + 34), "STAGE %d" % depth, HORIZONTAL_ALIGNMENT_CENTER, 60, 12, Color(0.95, 0.86, 0.64))
		for m in marks:
			var fx := x0 + (x1 - x0) * clampf(float(int(m[0]) - depth) / far, 0.06, 1.0)
			var mc: Color = m[2]
			var p := Vector2(fx, y)
			track.draw_circle(p, 13.0, Color(0.04, 0.035, 0.03, 0.95))
			track.draw_arc(p, 13.0, 0.0, TAU, 24, mc, 2.0, true)
			match String(m[1]):
				"relic":
					track.draw_rect(Rect2(p + Vector2(-7, -3), Vector2(14, 9)), mc)
					track.draw_rect(Rect2(p + Vector2(-7, -7), Vector2(14, 4)), mc.lightened(0.2))
				"festival":
					track.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -9), p + Vector2(6, 5), p + Vector2(-6, 5)]), mc)
					track.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -3), p + Vector2(3, 5), p + Vector2(-3, 5)]), Color(1, 0.9, 0.5))
				"tyrant":
					track.draw_circle(p + Vector2(0, -2), 6.5, mc)
					track.draw_rect(Rect2(p + Vector2(-4, 3), Vector2(8, 5)), mc)
					track.draw_circle(p + Vector2(-2.5, -2), 1.8, Color(0.05, 0.03, 0.02))
					track.draw_circle(p + Vector2(2.5, -2), 1.8, Color(0.05, 0.03, 0.02))
				_:
					track.draw_arc(p, 7.0, PI * 0.1, PI * 0.9, 10, mc, 2.0, true)
					track.draw_arc(p, 7.0, PI * 1.1, PI * 1.9, 10, mc, 2.0, true)
					track.draw_circle(p, 3.0, mc)
			track.draw_string(font_t, Vector2(fx - 40, y + 34), str(int(m[0])), HORIZONTAL_ALIGNMENT_CENTER, 80, 13, mc.lightened(0.2)))
	box.add_child(track)
	var road := _label("The road ahead: " + "  ·  ".join(ahead), 14, Color(0.78, 0.74, 0.62))
	road.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	road.visible = not weekly
	box.add_child(road)
	var meta := _label("Enemies: %s%s\nExperience: x%.2f   ·   Deepest stage won: %d%s" % [", ".join(foes), extra, float(st["xp_mult"]), ProfileManager.endless_best(), records], 15, Color(0.85, 0.72, 0.45))
	meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(meta)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var picks: Array = [["Back", func(): layer.queue_free()]]
	if weekly:
		var wk := ProfileManager.endless_fastest_key("w%d" % int(st["weekly"]))
		var wl := _label("A new road every week, the same for every player. Your fastest clear this week: %s" % ("%d:%02d" % [int(wk) / 60, int(wk) % 60] if wk > 0.0 else "none yet"), 14, Color(0.95, 0.8, 0.5))
		wl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(wl)
		box.move_child(wl, row.get_index())
	else:
		if depth > 1:
			picks.append(["< Stage %d" % (depth - 1), func(): layer.queue_free(); _open_endless(depth - 1)])
		if depth <= ProfileManager.endless_best():
			picks.append(["Stage %d >" % (depth + 1), func(): layer.queue_free(); _open_endless(depth + 1)])
		picks.append(["Road of the Week", func(): layer.queue_free(); _open_endless(-1, true)])
	picks.append(["March On", func(): _launch_endless(st)])
	for spec in picks:
		var b := Button.new()
		b.text = String(spec[0])
		b.custom_minimum_size = Vector2(220, 54)
		b.focus_mode = Control.FOCUS_NONE
		if ResourceLoader.exists(THEME_PATH):
			b.theme = load(THEME_PATH)
		b.add_theme_font_override("font", _title_font())
		b.add_theme_font_size_override("font_size", 20)
		b.pressed.connect(spec[1])
		row.add_child(b)

func _launch_endless(st: Dictionary) -> void:
	Sfx.play("select")
	var cfg: Dictionary = Match.default_config()
	cfg["player_race"] = _hero_race()
	cfg["opponents"] = st["opponents"].duplicate(true)
	cfg["mode"] = "endless"
	cfg["victory"] = "conquest"
	cfg["map"] = String(st["map"])
	cfg["endless_depth"] = int(st["depth"])
	cfg["endless_title"] = String(st["title"])
	cfg["endless_might"] = float(st["might"])
	cfg["endless_xp_mult"] = float(st["xp_mult"])
	cfg["twists"] = st.get("twists", []).duplicate()
	cfg["mood"] = String(st.get("mood", ""))
	if st.has("weekly"):
		cfg["endless_weekly"] = int(st["weekly"])
	Match.set_config(cfg)
	LoadingScreen.preload_and_change_scene("res://scenes/game_world.tscn", 1.5)

func _open_chronicle() -> void:
	Sfx.play("select")
	var s := ProfileManager.saga()
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var plate: PanelContainer = PLATE_SCRIPT.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color.TRANSPARENT
	ps.content_margin_left = 52.0
	ps.content_margin_right = 40.0
	ps.content_margin_top = 28.0
	ps.content_margin_bottom = 24.0
	plate.add_theme_stylebox_override("panel", ps)
	# A book-width column: lines of story read best at around ninety
	# characters, not stretched across a wide screen.
	plate.set("surface_alpha", 0.96)
	plate.set("surface_alpha_bottom", 0.97)
	plate.anchor_left = 0.5
	plate.anchor_right = 0.5
	plate.anchor_top = 0.0
	plate.anchor_bottom = 1.0
	plate.offset_left = -600.0
	plate.offset_right = 600.0
	plate.offset_top = 40.0
	plate.offset_bottom = -40.0
	layer.add_child(plate)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	plate.add_child(outer)
	var head := _label("The Chronicle of the Seventy-Seventh Ascension", 30, Color(0.98, 0.84, 0.46), true)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(head)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var book := VBoxContainer.new()
	book.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	book.add_theme_constant_override("separation", 8)
	var book_gutter := MarginContainer.new()
	book_gutter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	book_gutter.add_theme_constant_override("margin_right", 22)
	scroll.add_child(book_gutter)
	book_gutter.add_child(book)
	for a in CampaignDefs.ACTS.size():
		var done: Array = CampaignDefs.chapters_in_act(a).filter(func(c): return String(c["id"]) in s["cleared"])
		if done.is_empty():
			continue
		var act_head := _label(String(CampaignDefs.ACTS[a]["title"]).to_upper(), 20, Color(0.85, 0.74, 0.5), true)
		act_head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		book.add_child(act_head)
		for c in done:
			var id := String(c["id"])
			var tag := "  ·  side road" if bool(c.get("side", false)) else ""
			if id in s.get("heroic", []):
				tag += "  ·  heroic laurel"
			# Chapter heading: its seal, then its name.
			var heading := HBoxContainer.new()
			heading.add_theme_constant_override("separation", 12)
			var seal := Control.new()
			seal.custom_minimum_size = Vector2(40, 40)
			var seal_num := id
			var heroic_seal: bool = id in s.get("heroic", [])
			seal.draw.connect(func():
				var cc := seal.size * 0.5
				seal.draw_circle(cc, 18.0, Color(0.52, 0.38, 0.12) if heroic_seal else Color(0.2, 0.34, 0.24))
				seal.draw_arc(cc, 18.0, 0.0, TAU, 28, Color(0.95, 0.78, 0.42), 1.6, true)
				var f := _title_font()
				var tw := f.get_string_size(seal_num, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
				seal.draw_string(f, cc + Vector2(-tw * 0.5, 4), seal_num, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.99, 0.93, 0.75)))
			heading.add_child(seal)
			var title_lbl := _label(String(c["title"]) + tag, 22, Color(0.99, 0.86, 0.48), true)
			title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			heading.add_child(title_lbl)
			book.add_child(heading)
			var brief := _label(CampaignDefs.briefing_for(id, _hero_race()), 16, Color(0.86, 0.84, 0.78))
			brief.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			brief.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			book.add_child(brief)
			var won := _label(CampaignDefs.victory_text(id, s), 16, Color(0.72, 0.88, 0.70))
			won.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			won.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			book.add_child(won)
			# An ornament between chapters.
			var orn := Control.new()
			orn.custom_minimum_size = Vector2(0, 26)
			orn.draw.connect(func():
				var cc := Vector2(orn.size.x * 0.5, orn.size.y * 0.5)
				orn.draw_line(cc + Vector2(-160, 0), cc + Vector2(-14, 0), Color(0.95, 0.78, 0.42, 0.45), 1.2, true)
				orn.draw_line(cc + Vector2(14, 0), cc + Vector2(160, 0), Color(0.95, 0.78, 0.42, 0.45), 1.2, true)
				orn.draw_colored_polygon(PackedVector2Array([cc + Vector2(0, -6), cc + Vector2(6, 0), cc + Vector2(0, 6), cc + Vector2(-6, 0)]), Color(0.95, 0.78, 0.42, 0.8)))
			book.add_child(orn)
	var close := Button.new()
	close.text = "Close"
	close.custom_minimum_size = Vector2(200, 50)
	close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close.focus_mode = Control.FOCUS_NONE
	if ResourceLoader.exists(THEME_PATH):
		close.theme = load(THEME_PATH)
	close.add_theme_font_override("font", _title_font())
	close.add_theme_font_size_override("font_size", 20)
	close.pressed.connect(func(): layer.queue_free())
	outer.add_child(close)
	layer.modulate.a = 0.0
	layer.create_tween().tween_property(layer, "modulate:a", 1.0, 0.3)

func _show_act_card(a: int) -> void:
	var layer := ColorRect.new()
	layer.color = Color(0, 0, 0, 0.82)
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation", 14)
	layer.add_child(box)
	var parts: PackedStringArray = String(CampaignDefs.ACTS[a]["title"]).split(": ")
	for spec in [[parts[0].to_upper(), 22, Color(0.85, 0.74, 0.5), true], [parts[1] if parts.size() > 1 else parts[0], 54, Color(0.99, 0.86, 0.48), true], [String(CampaignDefs.ACTS[a]["subtitle"]), 20, Color(0.92, 0.88, 0.78), false], ["Click to continue", 14, Color(0.7, 0.66, 0.58), false]]:
		var l := _label(String(spec[0]), int(spec[1]), spec[2], bool(spec[3]))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(l)
	layer.modulate.a = 0.0
	layer.create_tween().tween_property(layer, "modulate:a", 1.0, 0.8)
	layer.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			layer.queue_free())

func _act_reached(a: int) -> bool:
	for c in CampaignDefs.chapters_in_act(a):
		if ProfileManager.chapter_available(String(c["id"])):
			return true
	return false

# --------------------------------------------------------------------------
## "Cleared 3/9 · jars 1/2 · side roads 1/3" for an Act, from the saga state.
func _act_progress_text(a: int) -> String:
	var sg := ProfileManager.saga()
	var total := 0
	var cleared := 0
	var jars := 0
	var jars_found := 0
	var sides := 0
	var sides_done := 0
	for ch in CampaignDefs.CHAPTERS:
		if int(ch.get("act", -1)) != a:
			continue
		total += 1
		var done: bool = String(ch["id"]) in sg.get("cleared", [])
		if done:
			cleared += 1
		if bool(ch.get("jar", false)):
			jars += 1
			if String(ch["id"]) in sg.get("jars", []):
				jars_found += 1
		if bool(ch.get("side", false)):
			sides += 1
			if done:
				sides_done += 1
	if total == 0:
		return ""
	var bits: Array = ["cleared %d/%d" % [cleared, total]]
	if jars > 0:
		bits.append("jars %d/%d" % [jars_found, jars])
	if sides > 0:
		bits.append("side roads %d/%d" % [sides_done, sides])
	return "   ·   " + "  ·  ".join(bits)

func _show_act(a: int) -> void:
	_act = a
	if a < _act_buttons.size() and is_instance_valid(_act_buttons[a]):
		_act_buttons[a].button_pressed = true
	if is_instance_valid(_mood):
		_mood.color = ACT_MOODS[a]
	for child in _act_layer.get_children():
		child.queue_free()
	_positions.clear()
	_act_title.text = String(CampaignDefs.ACTS[a]["title"])
	_act_subtitle.text = String(CampaignDefs.ACTS[a]["subtitle"]) + _act_progress_text(a)
	var vp: Vector2 = get_viewport_rect().size
	if vp == Vector2.ZERO:
		vp = Vector2(1280, 720)
	# Main road winds left to right; side roads hang off the chapter before them.
	var chapters := CampaignDefs.chapters_in_act(a)
	var mains: Array = chapters.filter(func(c): return not bool(c.get("side", false)) and not c.has("branch"))
	var n := mains.size() + (1 if chapters.any(func(c): return c.has("branch")) else 0)
	var k := 0
	var last_main := Vector2.ZERO
	var side_flip := false
	for c in chapters:
		var id := String(c["id"])
		if c.has("branch"):
			var bx := vp.x * 0.9
			_positions[id] = Vector2(bx, vp.y * (0.36 if String(c["branch"]) == "break" else 0.66))
		elif bool(c.get("side", false)):
			_positions[id] = Vector2(last_main.x + vp.x * 0.05, vp.y * (0.30 if side_flip else 0.70))
			side_flip = not side_flip
		else:
			var x := vp.x * (0.1 + 0.8 * float(k) / float(maxi(1, n - 1)))
			var y := vp.y * (0.45 if k % 2 == 0 else 0.57)
			_positions[id] = Vector2(x, y)
			last_main = _positions[id]
			k += 1
	for c in chapters:
		_build_node(c)
	# The Act unrolls: waypoints rise into place one after another.
	var order := 0
	for child in _act_layer.get_children():
		if child.is_queued_for_deletion():
			continue
		var home: Vector2 = child.position
		var target_mod: Color = child.modulate
		child.position = home + Vector2(0, 24)
		child.modulate = Color(target_mod, 0.0)
		var tw := child.create_tween().set_parallel(true)
		tw.tween_property(child, "position", home, 0.35).set_delay(order * 0.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(child, "modulate", target_mod, 0.3).set_delay(order * 0.05)
		order += 1
	_canvas.queue_redraw()
	var next := CampaignDefs.find(_next_id)
	_show_desc(_next_id if int(next.get("act", -1)) == a else String(chapters[0]["id"]))

func _build_node(c: Dictionary) -> void:
	var id := String(c["id"])
	var s := ProfileManager.saga()
	var available := ProfileManager.chapter_available(id)
	var cleared: bool = id in s["cleared"]
	var sealed_by_choice: bool = c.has("branch") and String(s["choice"]) != "" and String(s["choice"]) != String(c["branch"])
	var btn: Button = REGION_BUTTON_SCRIPT.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = NODE_SIZE
	btn.size = NODE_SIZE
	btn.position = _positions[id] - NODE_SIZE * 0.5
	btn.configure(available, cleared)
	btn.disabled = not available
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		btn.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	var laurel: bool = id in s.get("heroic", [])
	btn.number = id
	btn.side_road = bool(c.get("side", false))
	btn.heroic = laurel
	btn.has_jar = bool(c.get("jar", false))
	btn.jar_found = id in s["jars"]
	btn.is_next = id == _next_id
	# The chapter's name rides the parchment ribbon under its seal.
	var name_lbl := _label(String(c["title"]), 17, Color(0.13, 0.07, 0.02) if (available or cleared) else Color(0.16, 0.17, 0.20), true)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.max_lines_visible = 2
	# Long names that need two lines drop a size so both fit the ribbon.
	if _title_font().get_string_size(String(c["title"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x > NODE_SIZE.x - 60.0:
		name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_constant_override("line_spacing", -4)
	# A hairline outline in the ink colour thickens the engraved letters so
	# they stay legible when the page is scaled down.
	name_lbl.add_theme_color_override("font_outline_color", Color(0.13, 0.07, 0.02, 0.85))
	name_lbl.add_theme_constant_override("outline_size", 1)
	name_lbl.position = Vector2(26.0, btn.RIBBON_Y)
	name_lbl.size = Vector2(NODE_SIZE.x - 52.0, btn.RIBBON_H)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(name_lbl)
	var kind := "Side road  ·  " if bool(c.get("side", false)) else ("The Choice  ·  " if c.has("branch") else "")
	var status := "Sealed by your choice" if sealed_by_choice else (("Heroic laurel" if laurel else "Cleared") if cleared else (String(c["difficulty"]) if available else "Sealed"))
	if bool(c.get("jar", false)):
		status += ("  ·  jar found" if id in s["jars"] else "  ·  a jar lies here") if available or cleared else ""
	var status_lbl := _label(kind + status, 15, Color(0.98, 0.80, 0.36) if laurel else Color(0.5, 0.9, 0.55) if cleared else DIFF_COLORS.get(String(c["difficulty"]), Color(0.8, 0.8, 0.8)) if available else Color(0.62, 0.66, 0.70))
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_lbl.position = Vector2(0.0, btn.RIBBON_Y + btn.RIBBON_H + 6.0)
	status_lbl.size = Vector2(NODE_SIZE.x, 18.0)
	status_lbl.add_theme_color_override("font_outline_color", Color(0.01, 0.015, 0.02, 0.95))
	status_lbl.add_theme_constant_override("outline_size", 5)
	status_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(status_lbl)
	btn.mouse_entered.connect(_show_desc.bind(id))
	# Hovering a waypoint lifts it toward you; leaving settles it back.
	btn.pivot_offset = NODE_SIZE * 0.5
	btn.mouse_entered.connect(func():
		if available or cleared:
			Sfx.play("select")
			btn.create_tween().tween_property(btn, "scale", Vector2.ONE * 1.1, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))
	btn.mouse_exited.connect(func():
		btn.create_tween().tween_property(btn, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_SINE))
	if available:
		btn.pressed.connect(_open_briefing.bind(id))
	else:
		btn.modulate = Color(0.88, 0.88, 0.9, 0.93)
	_act_layer.add_child(btn)
	# Both roads of the Rabagão choice pulse while the choice is still open.
	var choice_open: bool = c.has("branch") and String(s["choice"]) == "" and available and not cleared
	if choice_open:
		btn.is_next = true

func _show_desc(id: String) -> void:
	if not is_instance_valid(_desc_label):
		return
	var c := CampaignDefs.find(id)
	if c.is_empty():
		return
	if not ProfileManager.chapter_available(id) and not (id in ProfileManager.saga()["cleared"]):
		_desc_label.text = "%s\nThis road is still sealed." % String(c["title"])
		return
	var first := String(c["briefing"]).split("\n")[0]
	var hint := "   ·   Your next battle: click its seal to read the briefing" if id == _next_id else ""
	_desc_label.text = "%s  [%s]%s\n%s" % [String(c["title"]), String(c["difficulty"]), hint, first]

# --------------------------------------------------------------------------
func _open_briefing(id: String) -> void:
	Sfx.play("select")
	if is_instance_valid(_briefing):
		_briefing.queue_free()
	var c := CampaignDefs.find(id)
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	_briefing = layer
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var plate: PanelContainer = PLATE_SCRIPT.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color.TRANSPARENT
	ps.content_margin_left = 52.0
	ps.content_margin_right = 52.0
	ps.content_margin_top = 30.0
	ps.content_margin_bottom = 30.0
	plate.add_theme_stylebox_override("panel", ps)
	plate.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	plate.grow_horizontal = Control.GROW_DIRECTION_BOTH
	plate.grow_vertical = Control.GROW_DIRECTION_BOTH
	plate.custom_minimum_size = Vector2(820, 0)
	layer.add_child(plate)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	plate.add_child(box)
	var act_line := _label(String(CampaignDefs.ACTS[int(c["act"])]["title"]).to_upper(), 14, Color(0.75, 0.68, 0.52), true)
	act_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(act_line)
	var t := _label(String(c["title"]), 34, Color(0.98, 0.84, 0.46), true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	# The matchup: your shield facing the enemy's across crossed blades, and
	# the chapter's difficulty as skull pips.
	var foe_ids: Array = []
	for o in c["opponents"]:
		if not foe_ids.has(String(o["race"])):
			foe_ids.append(String(o["race"]))
	var matchup := Control.new()
	matchup.custom_minimum_size = Vector2(0, 96)
	matchup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var diff_steps := {"easy": 1, "normal": 2, "hard": 3, "brutal": 4}
	var pips: int = int(diff_steps.get(String(c["difficulty"]).to_lower(), 2))
	var me := _hero_race()
	matchup.draw.connect(func():
		var cx := matchup.size.x * 0.5
		var cy := 44.0
		_draw_shield(matchup, Vector2(cx - 120.0, cy), 30.0, me)
		for k in foe_ids.size():
			_draw_shield(matchup, Vector2(cx + 120.0 + k * 70.0 - (foe_ids.size() - 1) * 35.0, cy), 30.0, String(foe_ids[k]))
		# Crossed blades between the shields.
		var gold := Color(0.95, 0.78, 0.42)
		for side in [-1.0, 1.0]:
			var a0 := Vector2(cx - 26.0 * float(side), cy - 26.0)
			var b0 := Vector2(cx + 26.0 * float(side), cy + 26.0)
			matchup.draw_line(a0, b0, gold, 3.0, true)
			matchup.draw_line(b0 + Vector2(-7.0 * float(side), -1.0), b0 + Vector2(1.0 * float(side), -9.0), gold, 3.0, true)
		# Difficulty pips.
		for k in 4:
			var pc := Vector2(cx - 33.0 + k * 22.0, cy + 42.0)
			var on: bool = k < pips
			matchup.draw_circle(pc, 6.0, Color(0.92, 0.36, 0.28) if on else Color(0.3, 0.3, 0.32))
			matchup.draw_arc(pc, 6.0, 0.0, TAU, 16, Color(0.95, 0.78, 0.42, 0.8), 1.0, true))
	box.add_child(matchup)
	var rule := ColorRect.new()
	rule.color = Color(0.98, 0.84, 0.46, 0.4)
	rule.custom_minimum_size = Vector2(0, 2)
	box.add_child(rule)
	var body := _label(CampaignDefs.briefing_for(id, _hero_race()), 18, Color(0.92, 0.89, 0.80))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(716, 0)
	box.add_child(body)
	var foes: Array = []
	for o in c["opponents"]:
		foes.append(String(GameData.get_race(String(o["race"])).get("name", o["race"])))
	var suggested := 1 + int(round(CampaignDefs.index_of(id) * 1.2))
	var hero_level := int(ProfileManager.hero().get("level", 1))
	var meta := _label("Enemies: %s   ·   Difficulty: %s   ·   Suggested hero level %d%s%s" % [", ".join(foes), String(c["difficulty"]), suggested, " (yours: %d)" % hero_level, "   ·   A jar of Wine of the Dead lies here" if bool(c.get("jar", false)) else ""] + ("
Objective: hold out for %d minutes." % (int(c.get("survive", 0)) / 60) if int(c.get("survive", 0)) > 0 else "
Objective: destroy the enemy's ability to rebuild."), 15, Color(0.85, 0.72, 0.45))
	meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(meta)
	# The first chapter that fields a faction introduces it.
	var seen := {}
	for earlier in CampaignDefs.CHAPTERS:
		if String(earlier["id"]) == id:
			break
		for o in earlier["opponents"]:
			seen[String(o["race"])] = true
	for o in c["opponents"]:
		var race_id := String(o["race"])
		if seen.has(race_id):
			continue
		seen[race_id] = true
		var rd: Dictionary = GameData.get_race(race_id)
		var blurb := String(rd.get("blurb", "")).split(". ")[0].trim_suffix(".")
		var intro := _label("New enemy: %s. %s." % [rd.get("name", race_id), blurb], 15, Color(0.95, 0.62, 0.42))
		intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(intro)
	if c.has("branch"):
		var warn := _label("This is the choice. Marching here seals the other road forever.", 15, Color(0.95, 0.45, 0.35), true)
		warn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(warn)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var buttons: Array = [["Back", func(): layer.queue_free()], ["March to War", func(): _on_node_pressed(id)]]
	if id in ProfileManager.saga()["cleared"]:
		buttons.append(["Heroic Replay", func(): _on_node_pressed(id, true)])
		var heroic := _label("Cleared. A Heroic Replay raises every enemy one difficulty step and pays half again in experience.", 14, Color(0.80, 0.70, 0.95))
		heroic.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(heroic)
	for spec in buttons:
		var b := Button.new()
		b.text = String(spec[0])
		b.custom_minimum_size = Vector2(220, 54)
		b.focus_mode = Control.FOCUS_NONE
		if ResourceLoader.exists(THEME_PATH):
			b.theme = load(THEME_PATH)
		b.add_theme_font_override("font", _title_font())
		b.add_theme_font_size_override("font_size", 20)
		b.pressed.connect(spec[1])
		row.add_child(b)
	plate.modulate.a = 0.0
	plate.pivot_offset = plate.size * 0.5
	plate.scale = Vector2.ONE * 0.94
	var pop := plate.create_tween().set_parallel(true)
	pop.tween_property(plate, "modulate:a", 1.0, 0.25)
	pop.tween_property(plate, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	plate.resized.connect(func(): plate.pivot_offset = plate.size * 0.5)

## The seal of a chapter just won slams down: it drops from large, lands with
## a ring of dust and a flash, and the level-up chime plays.
func _stamp_seal(id: String) -> void:
	await get_tree().create_timer(0.7).timeout
	var btn: Button = null
	for child in _act_layer.get_children():
		if child.get("number") == id:
			btn = child
	if btn == null:
		return
	btn.pivot_offset = Vector2(NODE_SIZE.x * 0.5, REGION_BUTTON_SCRIPT.SEAL_TOP + REGION_BUTTON_SCRIPT.SEAL_R)
	btn.scale = Vector2.ONE * 2.2
	btn.modulate.a = 0.0
	var tw := btn.create_tween().set_parallel(true)
	tw.tween_property(btn, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(btn, "modulate:a", 1.0, 0.18)
	await tw.finished
	Sfx.play("levelup")
	var ring := Control.new()
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ring)
	var centre: Vector2 = btn.global_position + btn.pivot_offset
	var t0 := Time.get_ticks_msec()
	ring.draw.connect(func():
		var age := float(Time.get_ticks_msec() - t0) / 900.0
		if age >= 1.0:
			return
		ring.draw_arc(centre, 40.0 + age * 90.0, 0.0, TAU, 48, Color(1.0, 0.84, 0.46, 0.9 * (1.0 - age)), 4.0 * (1.0 - age) + 1.0, true)
		ring.draw_circle(centre, 36.0 * (1.0 - age), Color(1.0, 0.95, 0.8, 0.35 * (1.0 - age)))
		for k in 14:
			var a := k * TAU / 14.0
			ring.draw_circle(centre + Vector2(cos(a), sin(a)) * (34.0 + age * 120.0), 3.0 * (1.0 - age), Color(0.85, 0.72, 0.5, 1.0 - age)))
	var redraw := ring.create_tween()
	redraw.tween_method(func(_v: float): ring.queue_redraw(), 0.0, 1.0, 0.9)
	redraw.tween_callback(ring.queue_free)

func _draw_shield(ci: CanvasItem, c: Vector2, r: float, race_id: String) -> void:
	var col: Color = GameData.RACES.get(race_id, {}).get("color", Color(0.6, 0.6, 0.6))
	var w := r * 1.7
	var h := r * 2.0
	var o := c - Vector2(w * 0.5, h * 0.5)
	var shield := PackedVector2Array([o, o + Vector2(w, 0), o + Vector2(w, h * 0.55), o + Vector2(w * 0.5, h), o + Vector2(0, h * 0.55)])
	ci.draw_colored_polygon(shield, Color(0.05, 0.04, 0.03, 0.95))
	var inner := PackedVector2Array()
	for p in shield:
		inner.append(c + (p - c) * 0.86)
	ci.draw_colored_polygon(inner, col.darkened(0.2))
	shield.append(shield[0])
	ci.draw_polyline(shield, Color(0.95, 0.78, 0.42), 2.0, true)
	FACTION_SIGILS.draw(ci, race_id, c + Vector2(0, -r * 0.08), r * 0.6, Color(0.99, 0.93, 0.75))

func _on_node_pressed(id: String, heroic: bool = false) -> void:
	Sfx.play("select")
	var c := CampaignDefs.find(id)
	var cfg: Dictionary = Match.default_config()
	cfg["player_race"] = _hero_race()
	cfg["opponents"] = c["opponents"].duplicate(true)
	cfg["campaign_heroic"] = heroic
	if heroic:
		var up := {"easy": "normal", "normal": "hard", "hard": "brutal", "brutal": "brutal"}
		for o in cfg["opponents"]:
			o["difficulty"] = up.get(String(o["difficulty"]), "brutal")
	cfg["mode"] = "campaign"
	cfg["campaign_node"] = CampaignDefs.index_of(id)
	cfg["campaign_chapter"] = id
	cfg["victory"] = "conquest"
	cfg["map"] = String(c.get("map", "hollowspan"))
	Match.set_config(cfg)
	LoadingScreen.preload_and_change_scene("res://scenes/game_world.tscn", 1.5)

func _on_back_pressed() -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

# --------------------------------------------------------------------------
## Map ambience: time for the marching roads, drifting mist and embers.
var _anim_t := 0.0
var _embers: Array = []

func _process(delta: float) -> void:
	_anim_t += delta
	if is_instance_valid(_canvas):
		_canvas.queue_redraw()

func _seal_point(id: String) -> Vector2:
	# Roads meet the seal at the top of each waypoint, not its ribbon.
	return _positions[id] + Vector2(0.0, REGION_BUTTON_SCRIPT.SEAL_TOP + REGION_BUTTON_SCRIPT.SEAL_R - NODE_SIZE.y * 0.5)

func _draw_path() -> void:
	var s := ProfileManager.saga()
	var vp := _canvas.size
	# Lands still sealed sink into shadow; open and won chapters sit in light.
	for c in CampaignDefs.chapters_in_act(_act):
		var cid := String(c["id"])
		if not _positions.has(cid):
			continue
		var open: bool = ProfileManager.chapter_available(cid) or cid in s["cleared"]
		var p0 := _seal_point(cid)
		for k in 6:
			var rad := 70.0 + k * 26.0
			if open:
				_canvas.draw_circle(p0, rad, Color(1.0, 0.82, 0.45, 0.016))
			else:
				_canvas.draw_circle(p0, rad, Color(0.0, 0.0, 0.02, 0.05))
	# Drifting mist: long pale bands crossing slowly.
	for k in 5:
		var y := vp.y * (0.28 + 0.12 * k)
		var x := fmod(_anim_t * (14.0 + k * 5.0) + k * 420.0, vp.x + 900.0) - 450.0
		for q in 4:
			_canvas.draw_circle(Vector2(x + q * 110.0, y + sin(_anim_t * 0.3 + k + q) * 12.0), 80.0 + q * 10.0, Color(0.85, 0.88, 0.92, 0.018))
	for c in CampaignDefs.chapters_in_act(_act):
		var from_id := String(c["id"])
		if not _positions.has(from_id):
			continue
		for to in c.get("unlocks", []):
			var to_id := String(to)
			if not _positions.has(to_id):
				continue
			var lit: bool = ProfileManager.chapter_available(to_id) or to_id in s["cleared"]
			_draw_march_route(_seal_point(from_id), _seal_point(to_id), lit)
	# Embers and Lume motes rising over the map.
	if _embers.is_empty():
		var rng := RandomNumberGenerator.new()
		rng.seed = 7707
		for k in 70:
			_embers.append({"x": rng.randf(), "ph": rng.randf(), "sp": rng.randf_range(0.02, 0.06), "r": rng.randf_range(1.0, 2.6), "warm": rng.randf() < 0.7})
	for e in _embers:
		var f := fmod(float(e["ph"]) + _anim_t * float(e["sp"]), 1.0)
		var ep := Vector2(float(e["x"]) * vp.x + sin(_anim_t * 0.8 + float(e["ph"]) * 9.0) * 16.0, vp.y * (1.0 - f))
		var ec := Color(1.0, 0.66, 0.28) if bool(e["warm"]) else Color(0.78, 0.62, 1.0)
		var fade := sin(f * PI)
		_canvas.draw_circle(ep, float(e["r"]) * 2.4, Color(ec, 0.08 * fade))
		_canvas.draw_circle(ep, float(e["r"]), Color(ec, 0.65 * fade))
	# The hero's standard planted at the next chapter: "you are here".
	if _positions.has(_next_id) and int(CampaignDefs.find(_next_id).get("act", -1)) == _act:
		_draw_hero_standard(_seal_point(_next_id) + Vector2(REGION_BUTTON_SCRIPT.SEAL_R + 22.0, -12.0))

func _draw_hero_standard(base: Vector2) -> void:
	var col: Color = GameData.RACES.get(_hero_race(), {}).get("color", Color(0.8, 0.3, 0.2))
	var pole_top := base + Vector2(0, -70)
	_canvas.draw_line(base + Vector2(0, 26), pole_top, Color(0.25, 0.18, 0.1), 3.0, true)
	_canvas.draw_circle(pole_top, 3.5, Color(0.95, 0.78, 0.4))
	# A waving pennant.
	var pts := PackedVector2Array()
	var bottom := PackedVector2Array()
	for k in 11:
		var t := float(k) / 10.0
		var wave := sin(_anim_t * 3.0 - t * 4.0) * 5.0 * t
		pts.append(pole_top + Vector2(4.0 + t * 46.0, 4.0 + wave))
		bottom.append(pole_top + Vector2(4.0 + t * 46.0, 30.0 - t * 12.0 + wave))
	var poly := pts.duplicate()
	bottom.reverse()
	poly.append_array(bottom)
	_canvas.draw_colored_polygon(poly, col)
	poly.append(poly[0])
	_canvas.draw_polyline(poly, Color(0.95, 0.78, 0.4, 0.9), 1.4, true)
	var hero: Dictionary = ProfileManager.hero()
	var initial := String(GameData.RACES.get(_hero_race(), {}).get("name", "?")).trim_prefix("The ").substr(0, 1)
	_canvas.draw_string(_title_font(), pole_top + Vector2(18, 24 + sin(_anim_t * 3.0 - 1.6) * 2.5), initial, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 0.95, 0.8))
	# A ring of light at the foot of the standard.
	_canvas.draw_arc(base + Vector2(0, 26), 10.0 + 4.0 * sin(_anim_t * 2.0), 0.0, TAU, 20, Color(0.98, 0.8, 0.4, 0.5), 1.5, true)
	if hero.is_empty():
		return

func _draw_march_route(from: Vector2, to: Vector2, lit: bool) -> void:
	# A curved, inked march route: a dark under-stroke, then dashes that march
	# along the road (and glow gold) once the leg is open, faint slate while
	# it is sealed.
	var mid := (from + to) * 0.5
	var normal := Vector2(-(to - from).y, (to - from).x).normalized()
	var ctrl := mid + normal * (to - from).length() * 0.12
	var pts := PackedVector2Array()
	for k in 65:
		var t := float(k) / 64.0
		pts.append(from.lerp(ctrl, t).lerp(ctrl.lerp(to, t), t))
	_canvas.draw_polyline(pts, Color(0.02, 0.02, 0.03, 0.7), 8.0, true)
	if lit:
		_canvas.draw_polyline(pts, Color(0.98, 0.72, 0.30, 0.16), 14.0, true)
		var shift := int(_anim_t * 10.0) % 4
		for k in range(shift, 63, 4):
			_canvas.draw_line(pts[k], pts[mini(k + 2, 64)], Color(0.99, 0.82, 0.42, 0.95), 3.2, true)
	else:
		for k in range(0, 63, 4):
			_canvas.draw_circle(pts[k], 1.6, Color(0.58, 0.61, 0.67, 0.55))
