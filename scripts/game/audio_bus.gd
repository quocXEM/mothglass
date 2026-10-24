extends Node

var muted := false
var _players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	for i in 3:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)


func play_soft() -> void:
	_tone(520.0, 0.06, -20.0)


func play_solve() -> void:
	_tone(392.0, 0.12, -14.0)
	await get_tree().create_timer(0.1).timeout
	_tone(523.0, 0.18, -12.0)
	await get_tree().create_timer(0.12).timeout
	_tone(659.0, 0.28, -12.0)


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
		var s := int(sin(TAU * freq * t) * env * 0.28 * 32767.0)
		data.encode_s16(i * 2, s)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream
