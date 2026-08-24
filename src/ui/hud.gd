class_name Hud
extends Control

const CORAZONES := 5
const COMIDAS := 5

var _energia: float = 100.0
var _energia_max: float = 100.0
var _comida: int = 0


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tag := UiCozzy.pastilla("Almacén")
	tag.position = Vector2(36, 38)
	add_child(tag)


func pintar(energia_ahora: float, energia_tope: float, comida: int) -> void:
	if is_equal_approx(_energia, energia_ahora) and _comida == comida:
		return
	_energia = energia_ahora
	_energia_max = energia_tope
	_comida = comida
	queue_redraw()


func _draw() -> void:
	var n := CORAZONES
	var sep := 36.0
	var ancho: float = size.x if size.x > 8.0 else get_viewport_rect().size.x
	var x0: float = ancho * 0.5 - sep * (n - 1) * 0.5
	var llenos: int = clampi(roundi((_energia / maxf(_energia_max, 1.0)) * n), 0, n)
	for i in n:
		UiCozzy.dibujar_corazon(self, Vector2(x0 + sep * i, 34), 14.0, i < llenos, float(i + 2))

	var caja := Rect2(28, 52, 188, 46)
	draw_rect(caja, Paleta.CREMA)
	draw_polyline(UiCozzy._ronda(caja, 14, 4), Paleta.TRAZO, 1.8, true)
	for i in COMIDAS:
		UiCozzy.dibujar_semilla(self, Vector2(52 + i * 32, 76), 9.5, i < _comida, float(i + 4))
