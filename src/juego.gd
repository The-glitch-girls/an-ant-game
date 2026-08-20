extends Node

var partida: Partida
var volumen: float = 0.8


func _ready() -> void:
	_aplicar_volumen()
	nueva_partida()


func nueva_partida() -> void:
	partida = Partida.new()


func ir_menu() -> void:
	get_tree().change_scene_to_file("res://src/menu/menu.tscn")


func ir_mundo() -> void:
	nueva_partida()
	get_tree().change_scene_to_file("res://src/mundo/mundo.tscn")


func ir_configuracion() -> void:
	get_tree().change_scene_to_file("res://src/menu/configuracion.tscn")


func set_volumen(valor: float) -> void:
	volumen = clampf(valor, 0.0, 1.0)
	_aplicar_volumen()


func _aplicar_volumen() -> void:
	var db := linear_to_db(volumen) if volumen > 0.001 else -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
