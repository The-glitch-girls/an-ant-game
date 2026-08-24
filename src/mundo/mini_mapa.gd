class_name MiniMapa
extends Control

const PX := 2
const MARGEN := 5

var _mapa: HormigueroMapa
var _nido: ImageTexture
var _hormiga_mundo := Vector2.ZERO
var _recorte := Rect2(0, 0, HormigueroMapa.ANCHO, HormigueroMapa.ALTO)


func armar(mapa: HormigueroMapa) -> void:
	_mapa = mapa
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_LINEAR
	custom_minimum_size = Vector2(
		HormigueroMapa.ANCHO * PX + MARGEN * 2,
		HormigueroMapa.ALTO * PX + MARGEN * 2
	)
	_recorte = _bounds()
	_nido = ImageTexture.create_from_image(_pintar())
	queue_redraw()


func marcar(pos_mundo: Vector2) -> void:
	if _hormiga_mundo.is_equal_approx(pos_mundo):
		return
	_hormiga_mundo = pos_mundo
	queue_redraw()


func mundo_a_local(pos_mundo: Vector2) -> Vector2:
	var cx := pos_mundo.x / float(HormigueroMapa.TILE)
	var cy := pos_mundo.y / float(HormigueroMapa.TILE)
	var w: float = HormigueroMapa.ANCHO * PX
	var h: float = HormigueroMapa.ALTO * PX
	return Vector2(
		MARGEN + (cx - _recorte.position.x) / _recorte.size.x * w,
		MARGEN + (cy - _recorte.position.y) / _recorte.size.y * h
	)


func _bounds() -> Rect2:
	var minx := HormigueroMapa.ANCHO
	var miny := HormigueroMapa.ALTO
	var maxx := 0
	var maxy := 0
	for y in HormigueroMapa.ALTO:
		for x in HormigueroMapa.ANCHO:
			if _mapa.get_celda(x, y) == HormigueroMapa.CIELO:
				continue
			minx = mini(minx, x)
			miny = mini(miny, y)
			maxx = maxi(maxx, x)
			maxy = maxi(maxy, y)
	miny = maxi(0, miny - 5)
	if maxx <= minx or maxy <= miny:
		return Rect2(0, 0, HormigueroMapa.ANCHO, HormigueroMapa.ALTO)
	return Rect2(minx, miny, maxx - minx + 1, maxy - miny + 1)


func _pintar() -> Image:
	var w: int = HormigueroMapa.ANCHO * PX
	var h: int = HormigueroMapa.ALTO * PX
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for py in h:
		for px in w:
			var fx: float = _recorte.position.x + (float(px) + 0.5) / float(w) * _recorte.size.x
			var fy: float = _recorte.position.y + (float(py) + 0.5) / float(h) * _recorte.size.y
			img.set_pixel(px, py, _sample(fx, fy))
	return img


func _sample(fx: float, fy: float) -> Color:
	var x0 := floori(fx)
	var y0 := floori(fy)
	var tx := fx - float(x0)
	var ty := fy - float(y0)
	var c00 := _color_en(x0, y0)
	var c10 := _color_en(x0 + 1, y0)
	var c01 := _color_en(x0, y0 + 1)
	var c11 := _color_en(x0 + 1, y0 + 1)
	return c00.lerp(c10, tx).lerp(c01.lerp(c11, tx), ty)


func _color_en(x: int, y: int) -> Color:
	if y < 0:
		return Paleta.CIELO
	if x < 0 or x >= HormigueroMapa.ANCHO or y >= HormigueroMapa.ALTO:
		return Paleta.TIERRA_OSCURA
	var celda: int = _mapa.get_celda(x, y)
	if _es_pasto(x, y, celda):
		return Paleta.PASTO
	match celda:
		HormigueroMapa.TUNEL:
			return Paleta.TUNEL
		HormigueroMapa.DERRUMBADA:
			return Paleta.TIERRA_MANCHA
		HormigueroMapa.CIELO:
			return Paleta.CIELO
		_:
			return Paleta.TIERRA_OSCURA


func _es_pasto(x: int, y: int, celda: int) -> bool:
	if y <= 11 and celda == HormigueroMapa.TUNEL:
		return true
	if celda != HormigueroMapa.CIELO:
		return false
	var abajo: int = _mapa.get_celda(x, y + 1)
	return abajo == HormigueroMapa.TIERRA or abajo == HormigueroMapa.TUNEL


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
