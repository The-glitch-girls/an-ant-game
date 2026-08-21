class_name HormigueroMapa
extends RefCounted

const TILE := 28
const ANCHO := 72
const ALTO := 100

const CIELO := 0
const TIERRA := 1
const TUNEL := 2
const DERRUMBADA := 3

var celdas: PackedByteArray = PackedByteArray()
var superficie_y: float = 0.0
var spawn: Vector2 = Vector2.ZERO
var reina: Vector2 = Vector2.ZERO
var larvas: Vector2 = Vector2.ZERO
var almacen: Vector2 = Vector2.ZERO
var descanso: Vector2 = Vector2.ZERO
var derrumbada: Rect2 = Rect2()
var comidas: Array[Vector2] = []
var rutas_obreras: Array = []


func generar() -> void:
	celdas.resize(ANCHO * ALTO)
	celdas.fill(CIELO)
	for y in ALTO:
		for x in ANCHO:
			if _en_monton(x, y):
				_poner(x, y, TIERRA)
	_franja_superficie()
	_cavar_tuneles()
	_colocar_puntos()


func mundo(x: int, y: int) -> Vector2:
	return Vector2((x + 0.5) * TILE, (y + 0.5) * TILE)


func get_celda(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= ANCHO or y >= ALTO:
		return TIERRA
	return celdas[y * ANCHO + x]


func es_caminable(x: int, y: int) -> bool:
	var c := get_celda(x, y)
	return c == TUNEL or c == CIELO


func esta_afuera(pos: Vector2) -> bool:
	var ty: int = int(pos.y / TILE)
	return ty <= 11


func _poner(x: int, y: int, v: int) -> void:
	if x < 0 or y < 0 or x >= ANCHO or y >= ALTO:
		return
	celdas[y * ANCHO + x] = v


func _en_monton(x: int, y: int) -> bool:
	if y < 10:
		return false
	var nx: float = (x - 36.0) / 31.0
	var ny: float = (y - 12.0) / 86.0
	return nx * nx + ny * ny * 0.42 < 1.0


func _franja_superficie() -> void:
	superficie_y = 9.5 * TILE
	for x in range(8, 64):
		if _en_monton(x, 12):
			_poner(x, 9, TUNEL)
			_poner(x, 10, TUNEL)
			_poner(x, 11, TUNEL)


func _cavar_tuneles() -> void:
	_camara(12, 38, 7, 6) # reina
	_camara(36, 48, 7, 5) # larvas
	_camara(54, 44, 7, 5) # almacen
	_camara(36, 72, 6, 5) # descanso
	_camara(22, 88, 5, 4)
	_camara(50, 90, 6, 4)
	_linea(36, 10, 36, 48, 2)
	_linea(36, 48, 12, 38, 2)
	_linea(36, 48, 54, 44, 2)
	_linea(36, 48, 36, 72, 2)
	_linea(36, 72, 22, 88, 2)
	_linea(36, 72, 50, 90, 2)
	_linea(12, 38, 22, 88, 1)
	_linea(54, 44, 50, 90, 1)
	_linea(8, 10, 36, 10, 1)
	_linea(36, 10, 62, 10, 1)
	# atajo izquierdo tapado
	_linea(20, 22, 12, 38, 2)
	for y in range(24, 32):
		for x in range(18, 24):
			if get_celda(x, y) == TUNEL:
				_poner(x, y, DERRUMBADA)


func _camara(cx: int, cy: int, rx: int, ry: int) -> void:
	for y in range(cy - ry, cy + ry + 1):
		for x in range(cx - rx, cx + rx + 1):
			var dx: float = float(x - cx) / float(rx)
			var dy: float = float(y - cy) / float(ry)
			if dx * dx + dy * dy <= 1.0 and _en_monton(x, y):
				_poner(x, y, TUNEL)


func _linea(x0: int, y0: int, x1: int, y1: int, grosor: int) -> void:
	var pasos: int = maxi(absi(x1 - x0), absi(y1 - y0))
	if pasos == 0:
		return
	for i in pasos + 1:
		var t: float = float(i) / float(pasos)
		var x: int = roundi(lerpf(x0, x1, t))
		var y: int = roundi(lerpf(y0, y1, t))
		for oy in range(-grosor, grosor + 1):
			for ox in range(-grosor, grosor + 1):
				if ox * ox + oy * oy <= grosor * grosor + 1:
					if _en_monton(x + ox, y + oy) or y + oy <= 11:
						_poner(x + ox, y + oy, TUNEL)


func _colocar_puntos() -> void:
	reina = mundo(12, 38)
	larvas = mundo(36, 48)
	almacen = mundo(54, 44)
	descanso = mundo(36, 72)
	spawn = mundo(54, 44)
	derrumbada = Rect2(mundo(18, 24) - Vector2(TILE, TILE), Vector2(TILE * 7, TILE * 9))
	comidas = [
		mundo(14, 10),
		mundo(24, 10),
		mundo(44, 10),
		mundo(52, 10),
		mundo(60, 10),
	]
	rutas_obreras = [
		[mundo(36, 16), mundo(36, 40), mundo(20, 38), mundo(36, 40)],
		[mundo(40, 48), mundo(54, 44), mundo(50, 70), mundo(54, 44)],
		[mundo(36, 72), mundo(22, 88), mundo(36, 72), mundo(50, 90)],
		[mundo(18, 10), mundo(40, 10), mundo(55, 10), mundo(30, 10)],
		[mundo(12, 38), mundo(16, 50), mundo(12, 38)],
		[mundo(50, 90), mundo(54, 70), mundo(50, 90)],
	]


func hay_derrumbada_en_tunel() -> bool:
	for y in ALTO:
		for x in ANCHO:
			if get_celda(x, y) == DERRUMBADA:
				return true
	return false
