extends Node
## Sfx — named sound-effect registry so gameplay never hardcodes paths.

const B := "res://assets/audio/sfx/"
const M := "res://assets/audio/music/"
const A := "res://assets/audio/ambient/"

var lib := {
	"select": B + "ui/ui_unit_select_confirm.mp3",
	"ready": B + "ui/ui_unit_ready.mp3",
	"build_complete": B + "ui/ui_building_complete.mp3",
	"under_attack": B + "ui/ui_base_under_attack.mp3",
	"levelup": B + "pickup/pickup_hero_level_up.mp3",
	"sword": B + "combat/combat_sword_hit.mp3",
	"arrow": B + "combat/combat_arrow_shot.mp3",
	"projectile_impact": B + "combat/combat_projectile_impact.wav",
	"spell": B + "combat/combat_spell_cast.mp3",
	"death": B + "combat/combat_unit_death.mp3",
	# Procedural UI sounds (made by tools/synth_sfx.py).
	"hover": B + "ui/ui_hover_tick.wav",
	"coin": B + "ui/ui_coin_chime.wav",
	"stamp": B + "ui/ui_seal_stamp.wav",
	"page": B + "ui/ui_page_turn.wav",
	"horn": B + "ui/ui_war_horn.wav",
	"knock": B + "ui/ui_order_knock.wav",
	"collapse": B + "ui/ui_collapse.wav",
	# Plan 86 (tools/synth_sfx.py): hits by weapon, spells by what they do,
	# work sounds, research, a new Age and a refused order.
	"blunt": B + "combat/combat_blunt_hit.wav",
	"siege": B + "combat/combat_siege_launch.wav",
	"zap": B + "combat/combat_arcane_zap.wav",
	"sp_heal": B + "combat/spell_heal.wav",
	"sp_quake": B + "combat/spell_quake.wav",
	"sp_summon": B + "combat/spell_summon.wav",
	"sp_ward": B + "combat/spell_ward.wav",
	"sp_fury": B + "combat/spell_fury.wav",
	"sp_rain": B + "combat/spell_rain.wav",
	"sp_curse": B + "combat/spell_curse.wav",
	"chop": B + "combat/work_chop.wav",
	"pick": B + "combat/work_pick.wav",
	"harvest": B + "combat/work_harvest.wav",
	"research": B + "ui/ui_research_done.wav",
	"age_up": B + "ui/ui_age_up.wav",
	"refuse": B + "ui/ui_refuse.wav",
}

## The cast sound of each spell, by what it does. Spells not listed keep the
## general "spell" sound.
const SPELL_SOUNDS := {
	"heal": "sp_heal", "sig_spring": "sp_heal", "lio_bloom": "sp_heal", "bar_horn": "sp_heal",
	"slam": "sp_quake", "grim_quake": "sp_quake", "kar_avalanche": "sp_quake", "sig_bull": "sp_quake", "wyl_leap": "sp_quake",
	"bar_levy": "sp_summon", "syl_mirror": "sp_summon", "sig_pack": "sp_summon", "sig_candles": "sp_summon",
	"sig_stoneskin": "sp_ward", "kar_bastion": "sp_ward", "sun_testudo": "sp_ward",
	"rally": "sp_fury", "avatar": "sp_fury", "sig_chains": "sp_fury", "grim_rage": "sp_fury", "wyl_frenzy": "sp_fury", "fro_masks": "sp_fury", "sig_entrudo": "sp_fury",
	"sun_rain": "sp_rain", "sig_ashglass": "sp_rain", "lio_thorns": "sp_rain",
	"hol_curse": "sp_curse", "hol_drain": "sp_curse", "vor_chains": "sp_curse", "root": "sp_curse", "fro_breath": "sp_curse",
}

var _last_played_ms := {}

func spell_sound(spell_id: String) -> String:
	return String(SPELL_SOUNDS.get(spell_id, "spell"))

## Plays `key` unless it already sounded within `gap_ms`: twenty workers at
## one grove must not turn into twenty axes a second.
func play_limited(key: String, vol: float, gap_ms: int) -> void:
	var now := Time.get_ticks_msec()
	if now - int(_last_played_ms.get(key, -100000)) < gap_ms:
		return
	_last_played_ms[key] = now
	play(key, vol)

var music := {
	"menu": M + "music_menu_ascendant_main_theme.mp3",
	"battle": M + "music_combat_skirmish_battle_rise.mp3",
	"victory": M + "jingle_victory_victory_fanfare.mp3",
	"defeat": M + "jingle_defeat_defeat_dirge.mp3",
}

var ambient := A + "ambient_mountain_highland_with_distant_magical_a_highland_wind_lume.mp3"

var _last_hover_ms := 0

var _menu_theme: Theme

func _ready() -> void:
	# Dropdowns and their lists read in the body font: the menu theme's title
	# font is too thin to read at dropdown sizes. Held here so the cached
	# theme keeps the change for every page that loads it.
	if ResourceLoader.exists("res://assets/ui/theme.tres"):
		_menu_theme = load("res://assets/ui/theme.tres")
		for type in ["OptionButton", "PopupMenu"]:
			_menu_theme.set_font("font", type, ThemeDB.fallback_font)
		# A gilt chevron replaces the engine's small grey dropdown arrow.
		_menu_theme.set_icon("arrow", "OptionButton", _gilt_chevron())
		_menu_theme.set_constant("arrow_margin", "OptionButton", 10)
	# Every button in the game answers the pointer with a soft tick.
	get_tree().node_added.connect(_on_node_added)

# Drawn in code so no new imported image is needed: a gold chevron with a
# dark outline and a lighter upper edge, antialiased by distance.
static func _gilt_chevron() -> ImageTexture:
	var w := 22
	var h := 14
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var a := Vector2(3.0, 3.5)
	var m := Vector2(11.0, 10.5)
	var b := Vector2(19.0, 3.5)
	for y in h:
		for x in w:
			var p := Vector2(x + 0.5, y + 0.5)
			var d := minf(_seg_dist(p, a, m), _seg_dist(p, m, b))
			var core := clampf(2.1 - d, 0.0, 1.0)
			var rim := clampf(3.3 - d, 0.0, 1.0)
			var lift := clampf(1.0 - (p.y - 3.0) / 9.0, 0.0, 1.0)
			var gold := Color(0.78, 0.56, 0.24).lerp(Color(1.0, 0.86, 0.52), lift)
			var c := Color(0.06, 0.035, 0.015).lerp(gold, core)
			c.a = rim
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)

static func _seg_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var t := clampf((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
	return p.distance_to(a + ab * t)

func _on_node_added(node: Node) -> void:
	# The meta guard stops a button that leaves and re-enters the tree from
	# collecting a second connection.
	if node is BaseButton and not node.has_meta("silent_hover") and not node.has_meta("hover_sfx"):
		var b: BaseButton = node
		b.set_meta("hover_sfx", true)
		b.mouse_entered.connect(func():
			if b.disabled:
				return
			var now := Time.get_ticks_msec()
			if now - _last_hover_ms < 60:
				return
			_last_hover_ms = now
			play("hover", -16.0))

func play(key: String, vol: float = -4.0) -> void:
	if lib.has(key):
		AudioManager.play_sfx_path(lib[key], vol)

func music_key(key: String) -> String:
	return music.get(key, "")
