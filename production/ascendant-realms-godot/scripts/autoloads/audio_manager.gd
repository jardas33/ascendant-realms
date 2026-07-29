extends Node
## AudioManager — bus setup, music, pooled SFX, web autoplay handling.

const MAX_SFX: int = 12

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

var _unlocked: bool = false
var _pending_music: AudioStream = null
var _pending_music_vol: float = -6.0
var _current_music_path: String = ""

# Cached streams
var _cache := {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not OS.has_feature("web"):
		_unlocked = true
	_setup_buses()
	_create_players()

func _input(event: InputEvent) -> void:
	if _unlocked:
		return
	if event is InputEventMouseButton or event is InputEventKey or event is InputEventScreenTouch:
		_unlocked = true
		if _pending_music:
			_play_music_now(_pending_music, _pending_music_vol, 1.0)
			_pending_music = null

func _setup_buses() -> void:
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")

func _create_players() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	add_child(music_player)
	for i in MAX_SFX:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		p.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(p)
		sfx_players.append(p)

func _load(path: String) -> AudioStream:
	if _cache.has(path):
		return _cache[path]
	if not ResourceLoader.exists(path):
		return null
	var s := load(path) as AudioStream
	_cache[path] = s
	return s

func play_music_path(path: String, volume_db: float = -8.0, loop: bool = true) -> void:
	if path == _current_music_path and music_player.playing:
		return
	var stream := _load(path)
	if stream == null:
		return
	_current_music_path = path
	if stream is AudioStreamMP3:
		stream.loop = loop
	elif stream is AudioStreamOggVorbis:
		stream.loop = loop
	if not _unlocked:
		_pending_music = stream
		_pending_music_vol = volume_db
		return
	_play_music_now(stream, volume_db, 1.2)

func _play_music_now(stream: AudioStream, volume_db: float, fade_in: float = 0.0) -> void:
	music_player.stream = stream
	if fade_in > 0.0:
		music_player.volume_db = -40.0
		music_player.play()
		create_tween().tween_property(music_player, "volume_db", volume_db, fade_in)
	else:
		music_player.volume_db = volume_db
		music_player.play()

func stop_music(fade: float = 0.8) -> void:
	_current_music_path = ""
	if fade > 0.0 and music_player.playing:
		var t := create_tween()
		t.tween_property(music_player, "volume_db", -40.0, fade)
		t.tween_callback(music_player.stop)
	else:
		music_player.stop()

func play_sfx_path(path: String, volume_db: float = -4.0, pitch_var: float = 0.06) -> void:
	var stream := _load(path)
	if stream == null:
		return
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.pitch_scale = randf_range(1.0 - pitch_var, 1.0 + pitch_var) if pitch_var > 0.0 else 1.0
			p.play()
			return

func set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(clamp(linear, 0.0001, 1.0)))
