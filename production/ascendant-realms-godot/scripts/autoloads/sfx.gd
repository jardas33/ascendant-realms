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

func _ready() -> void:
	# Every button in the game answers the pointer with a soft tick.
	get_tree().node_added.connect(_on_node_added)

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
