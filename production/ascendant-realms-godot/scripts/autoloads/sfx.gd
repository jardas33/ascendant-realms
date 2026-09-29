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
}

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
