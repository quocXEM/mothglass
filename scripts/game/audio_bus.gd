extends Node
## Procedural SFX + ambient bed (no external audio deps).

var muted := false
var master := 0.85
var _players: Array[AudioStreamPlayer] = []
var _ambient: AudioStreamPlayer


func _ready() -> void:
	for i in 4:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)
	_ambient = AudioStreamPlayer.new()
	_ambient.bus = "Master"
	add_child(_ambient)
	_start_ambient()


func set_master(vol: float, is_muted: bool) -> void:
	master = clampf(vol, 0.0, 1.0)
	muted = is_muted
	AudioServer.set_bus_volume_db(0, linear_to_db(0.0001 if muted else maxf(master, 0.001)))
	if _ambient:
		_ambient.volume_db = -28.0 if not muted else -80.0


func play_soft() -> void:
	_tone(480.0, 0.05, -22.0)


func play_solve() -> void:
	_tone(330.0, 0.14, -16.0)
	await get_tree().create_timer(0.12).timeout
	_tone(415.0, 0.16, -14.0)
	await get_tree().create_timer(0.14).timeout
	_tone(554.0, 0.32, -12.0)


func play_ui() -> void:
	_tone(620.0, 0.04, -24.0)


func _start_ambient() -> void:
	_ambient.stream = _make_ambient(8.0)
	_ambient.volume_db = -28.0
	_ambient.play()


func _tone(freq: float, dur: float, db: float) -> void:
	if muted:
		return
	var p: AudioStreamPlayer = _players[0]
	for x in _players:
		if not x.playing:
			p = x
			break
	p.stream = _make(freq, dur)
	p.volume_db = db
	p.play()


func _make(freq: float, dur: float) -> AudioStreamWAV:
	var rate := 22050
	var n := int(dur * rate)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / rate
		var env := sin(PI * clampf(t / dur, 0.0, 1.0))
		var s := int(sin(TAU * freq * t) * env * 0.26 * 32767.0)
		data.encode_s16(i * 2, s)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream


func _make_ambient(dur: float) -> AudioStreamWAV:
	# Soft brown-noise pad + slow sine — dream hall hum
	var rate := 22050
	var n := int(dur * rate)
	var data := PackedByteArray()
	data.resize(n * 2)
	var brown := 0.0
	for i in n:
		var t := float(i) / rate
		var white := (randf() * 2.0 - 1.0)
		brown = clampf(brown + white * 0.02, -1.0, 1.0)
		var pad := sin(TAU * 55.0 * t) * 0.08 + sin(TAU * 82.5 * t) * 0.05
		var s := int((brown * 0.12 + pad) * 0.5 * 32767.0)
		data.encode_s16(i * 2, s)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = n
	return stream
