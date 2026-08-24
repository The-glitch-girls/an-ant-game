class_name MiniMapa
extends Control

const PX := 2
const MARGEN := 5

var _mapa: HormigueroMapa
var _nido: ImageTexture
var _hormiga_mundo := Vector2.ZERO


func armar(mapa: HormigueroMapa) -> void:
	_mapa = mapa
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(
		HormigueroMapa.ANCHO * PX + MARGEN * 2,
		HormigueroMapa.ALTO * PX + MARGEN * 2
	)
	_nido = ImageTexture.create_from_image(_pintar())
	queue_redraw()


func marcar(pos_mundo: Vector2) -> void:
	if _hormiga_mundo.is_equal_approx(pos_mundo):
		return
	_hormiga_mundo = pos_mundo
	queue_redraw()


func mundo_a_local(pos_mundo: Vector2) -> Vector2:
	var x := pos_mundo.x / float(HormigueroMapa.TILE)
	var y := pos_mundo.y / float(HormigueroMapa.TILE)
	return Vector2(MARGEN + x * PX, MARGEN + y * PX)


func _pintar() -> Image:
	var img := Image.create(HormigueroMapa.ANCHO * PX, HormigueroMapa.ALTO * PX, false, Image.FORMAT_RGBA8)
	for y in HormigueroMapa.ALTO:
		for x in HormigueroMapa.ANCHO:
			img.fill_rect(Rect2i(x * PX, y * PX, PX, PX), _color_celda(_mapa.get_celda(x, y)))
	return img


func _color_celda(celda: int) -> Color:
	match celda:
		HormigueroMapa.TUNEL:
			return Paleta.TUNEL
		HormigueroMapa.DERRUMBADA:
			return Paleta.TIERRA_MANCHA
		HormigueroMapa.CIELO:
			return Color(0.98, 0.88, 0.72, 0.5)
		_:
			return Paleta.TIERRA_OSCURA


func _draw() -> void:
	var marco := Rect2(Vector2.ZERO, custom_minimum_size)
	draw_rect(marco, Paleta.CREMA)
	if _nido:
		draw_texture(_nido, Vector2(MARGEN, MARGEN))
	draw_polyline(UiCozzy._ronda(marco, 12, 4), Paleta.TRAZO, 2.0, true)
	if _mapa == null:
		return
	var p := mundo_a_local(_hormiga_mundo)
	draw_circle(p, 3.4, Paleta.HORMIGA_OSCURA)
	draw_circle(p, 2.2, Paleta.HORMIGA)
	draw_circle(p, 0.9, Paleta.HUESO)
