extends Node
## Battlefield ambience. Matches used to have music and nothing else. This
## plays the authored highland wind recording where it fits and synthesises
## the rest (no downloaded audio): gusting wind on every map, birdsong on
## green maps, and fire crackle on volcanic ones. The sounds are rendered
## once into small looping samples when the match starts, so nothing is
## computed per frame. Levels sit well under the music and combat sounds,
## on the SFX bus so the Sound Effects slider controls them. Presentation only.

const RATE := 11025
const RECORDED := "res://assets/audio/ambient/ambient_mountain_highland_with_distant_magical_a_highland_wind_lume.mp3"

## Per theme: wind level 0..1, birds, crackle, use the recording.
const LOOKS := {
	"highland": [0.35, true, false, true], "verdant": [0.25, true, false, true],
	"tropical": [0.2, true, false, false], "wetland": [0.3, true, false, false],
	"autumn": [0.45, true, false, false], "desert": [0.7, false, false, false],
	"badlands": [0.65, false, false, false], "snow": [0.8, false, false, false],
	"volcanic": [0.4, false, true, false], "ashen": [0.5, false, true, false],
}

## Campaign moods override the map's sound: [wind level, birds, crackle,
## recording] as above, plus a mood extra (crickets, rain and thunder).
const MOOD_LOOKS := {
	"night": [0.25, false, false, false], "ember": [0.4, false, true, false],
	"storm": [0.75, false, false, false],
}

var _rng := RandomNumberGenerator.new()
var _thunder_player: AudioStreamPlayer
var _thunder_timer := 12.0
var _songs: Array[AudioStreamWAV] = []
var _bird_player: AudioStreamPlayer
var _bird_timer := 3.0


func build(theme_name: String, mood: String = "") -> void:
	var look: Array = MOOD_LOOKS.get(mood, LOOKS.get(theme_name, LOOKS["highland"]))
	_rng.seed = 90210
	if mood == "night":
		_loop_player(_cricket_loop(), -21.0)
	elif mood == "storm":
		_loop_player(_rain_loop(), -13.0)
		_thunder_player = AudioStreamPlayer.new()
		_thunder_player.bus = "SFX"
		_thunder_player.volume_db = -9.0
		_thunder_player.stream = _thunder()
		add_child(_thunder_player)
	if bool(look[3]) and ResourceLoader.exists(RECORDED):
		var stream = load(RECORDED)
		if stream is AudioStreamMP3:
			(stream as AudioStreamMP3).loop = true
		_loop_player(stream, -20.0)
	_loop_player(_wind_loop(float(look[0])), -12.0)
	if bool(look[2]):
		_loop_player(_crackle_loop(), -16.0)
	if bool(look[1]):
		for i in 3:
			_songs.append(_bird_song(i))
		_bird_player = AudioStreamPlayer.new()
		_bird_player.bus = "SFX"
		_bird_player.volume_db = -19.0
		add_child(_bird_player)
	set_process(bool(look[1]) or is_instance_valid(_thunder_player))


func _process(delta: float) -> void:
	if is_instance_valid(_thunder_player):
		_thunder_timer -= delta
		if _thunder_timer <= 0.0:
			_thunder_timer = _rng.randf_range(18.0, 40.0)
			_thunder_player.pitch_scale = _rng.randf_range(0.8, 1.15)
			_thunder_player.play()
	_bird_timer -= delta
	if _bird_timer <= 0.0 and is_instance_valid(_bird_player):
		_bird_timer = _rng.randf_range(3.0, 9.0)
		_bird_player.stream = _songs[_rng.randi() % _songs.size()]
		_bird_player.pitch_scale = _rng.randf_range(0.85, 1.2)
		_bird_player.play()


func _loop_player(stream: AudioStream, db: float) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = db
	p.bus = "SFX"
	add_child(p)
	p.play()


func _wav(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_end = samples.size()
	return w


func _wind_loop(level: float) -> AudioStreamWAV:
	# 12 s of doubly low-passed noise with two gust cycles; the last half
	# second crossfades into the start so the loop has no seam.
	var n := RATE * 12
	var out := PackedFloat32Array()
	out.resize(n)
	var lp := 0.0
	var lp2 := 0.0
	for i in n:
		var t := float(i) / float(n)
		var gust := 0.55 + 0.45 * sin(t * TAU * 2.0) * sin(t * TAU * 3.0 + 1.3)
		lp += (_rng.randf() * 2.0 - 1.0 - lp) * (0.04 + 0.06 * gust)
		lp2 += (lp - lp2) * 0.15
		out[i] = lp2 * 3.0 * level * gust
	var fade := RATE / 2
	for i in fade:
		var k := float(i) / float(fade)
		out[n - fade + i] = out[n - fade + i] * (1.0 - k) + out[i] * k
	return _wav(out, true)


## Steady rain: bright noise with a softer body, no gusting.
func _rain_loop() -> AudioStreamWAV:
	var n := RATE * 6
	var out := PackedFloat32Array()
	out.resize(n)
	var lp := 0.0
	for i in n:
		var w := _rng.randf() * 2.0 - 1.0
		lp += (w - lp) * 0.35
		var drop := (_rng.randf() * 2.0 - 1.0) * 0.8 if _rng.randf() < 0.004 else 0.0
		out[i] = lp * 0.28 + (w - lp) * 0.06 + drop * 0.12
	var fade := RATE / 2
	for i in fade:
		var k := float(i) / float(fade)
		out[n - fade + i] = out[n - fade + i] * (1.0 - k) + out[i] * k
	return _wav(out, true)


## Night insects: short pulsed chirps around 4.4 kHz from a few crickets.
func _cricket_loop() -> AudioStreamWAV:
	var n := RATE * 4
	var out := PackedFloat32Array()
	out.resize(n)
	for c in 3:
		var f := 4200.0 + c * 260.0
		var period := int(RATE * (0.42 + c * 0.11))
		var start := int(_rng.randf() * period)
		for i in n:
			var k := (i + start) % period
			var burst := int(RATE * 0.09)
			if k < burst:
				var env := sin(PI * float(k) / float(burst)) * (0.5 + 0.5 * sin(TAU * float(k) / (RATE * 0.012)))
				out[i] += sin(TAU * f * float(i) / RATE) * env * 0.12
	return _wav(out, true)


## A distant roll of thunder: low rumbling noise with a slow swell and decay.
func _thunder() -> AudioStreamWAV:
	var n := RATE * 5
	var out := PackedFloat32Array()
	out.resize(n)
	var lp := 0.0
	var lp2 := 0.0
	for i in n:
		var t := float(i) / float(n)
		var env := minf(1.0, t * 8.0) * pow(1.0 - t, 1.6) * (0.7 + 0.3 * sin(t * 37.0))
		lp += (_rng.randf() * 2.0 - 1.0 - lp) * 0.02
		lp2 += (lp - lp2) * 0.05
		out[i] = lp2 * 14.0 * env
	return _wav(out, false)


func _crackle_loop() -> AudioStreamWAV:
	var n := RATE * 3
	var out := PackedFloat32Array()
	out.resize(n)
	var env := 0.0
	for i in n:
		if _rng.randf() < 0.0018:
			env = _rng.randf_range(0.3, 0.9)
		out[i] = (_rng.randf() * 2.0 - 1.0) * env * 0.5
		env *= 0.985
	return _wav(out, true)


func _bird_song(variant: int) -> AudioStreamWAV:
	# A short phrase of rising chirps.
	var chirps := 3 + variant
	var f0 := 2600.0 + variant * 500.0
	var out := PackedFloat32Array()
	for c in chirps:
		var length := int(RATE * _rng.randf_range(0.05, 0.09))
		for i in length:
			var k := float(i) / float(length)
			var f := f0 * (1.0 + 0.4 * k)
			out.append(sin(TAU * f * float(i) / RATE) * sin(PI * k) * 0.6)
		for i in int(RATE * _rng.randf_range(0.04, 0.1)):
			out.append(0.0)
	return _wav(out, false)
