class_name Hud
extends Control

const CORAZONES := 5
const COMIDAS := 5
const IZQUIERDA := 24.0

var _energia: float = 100.0
var _energia_max: float = 100.0
var _comida: int = 0


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tag_almacen := UiCozzy.pastilla("Almacén")
	tag_almacen.position = Vector2(IZQUIERDA, 16)
	add_child(tag_almacen)
	var tag_energia := UiCozzy.pastilla("Energía")
	tag_energia.position = Vector2(IZQUIERDA, 62)
	add_child(tag_energia)


func pintar(energia_ahora: float, energia_tope: float, comida: int) -> void:
	if is_equal_approx(_energia, energia_ahora) and _comida == comida:
		return
	_energia = energia_ahora
	_energia_max = energia_tope
	_comida = comida
	queue_redraw()


func _draw() -> void:
	var llenos: int = clampi(roundi((_energia / maxf(_energia_max, 1.0)) * CORAZONES), 0, CORAZONES)
	for i in COMIDAS:
		UiCozzy.dibujar_semilla(self, Vector2(128 + i * 30, 34), 9.5, i < _comida, float(i + 4))
	for i in CORAZONES:
		UiCozzy.dibujar_corazon(self, Vector2(128 + i * 30, 80), 13.0, i < llenos, float(i + 2))
