class_name Sfx
extends Node

var _viento: AudioStreamPlayer


func _ready() -> void:
	_viento = _player("res://assets/sfx/viento.wav")
	_viento.volume_db = -18
	add_child(_viento)


func tocar(nombre: String) -> void:
	var ruta := "res://assets/sfx/%s.wav" % nombre
	if not ResourceLoader.exists(ruta):
		return
	var p := AudioStreamPlayer.new()
	p.stream = load(ruta)
	p.finished.connect(p.queue_free)
	add_child(p)
	p.play()


func viento(on: bool) -> void:
	if on and not _viento.playing:
		_viento.play()
	elif not on:
		_viento.stop()


func _player(ruta: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	if ResourceLoader.exists(ruta):
		var stream := load(ruta)
		if stream is AudioStreamWAV:
			(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
		p.stream = stream
	return p
