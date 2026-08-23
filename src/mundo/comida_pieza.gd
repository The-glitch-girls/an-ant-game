class_name ComidaPieza
extends Area2D

enum Tamano { CHICA, MEDIA, GRANDE }

var tamano: Tamano = Tamano.MEDIA
var tomada: bool = false
var depositada: bool = false


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0
	add_to_group("comida")
	monitoring = true
	monitorable = true
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 14
	col.shape = shape
	add_child(col)
	_dibujar()
	var e := escala()
	scale = Vector2(e, e)


func escala() -> float:
	match tamano:
		Tamano.CHICA:
			return 0.58
		Tamano.GRANDE:
			return 1.75
		_:
			return 1.0


func costo_carga() -> int:
	match tamano:
		Tamano.CHICA:
			return 1
		Tamano.GRANDE:
			return 3
		_:
			return 2


func velocidad_carga() -> float:
	match tamano:
		Tamano.CHICA:
			return 64.0
		Tamano.GRANDE:
			return 32.0
		_:
			return 48.0


func distancia_mandibulas() -> float:
	return 12.0 + 8.0 * escala()


func _dibujar() -> void:
	var semilla := Polygon2D.new()
	semilla.color = _color_base()
	var rx := 16.0
	var ry := 10.0
	if tamano == Tamano.GRANDE:
		rx = 18.0
		ry = 11.0
	elif tamano == Tamano.CHICA:
		rx = 13.0
		ry = 11.0
	var pts := PackedVector2Array()
	for i in 10:
		var a := TAU * i / 10.0
		pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	semilla.polygon = pts
	add_child(semilla)
	var brillo := Polygon2D.new()
	brillo.color = Color(0.85, 0.68, 0.28, 0.7)
	brillo.polygon = PackedVector2Array([Vector2(-4, -4), Vector2(6, -2), Vector2(2, 3)])
	add_child(brillo)


func _color_base() -> Color:
	match tamano:
		Tamano.CHICA:
			return Color(0.78, 0.55, 0.22)
		Tamano.GRANDE:
			return Color(0.48, 0.30, 0.12)
		_:
			return Color(0.62, 0.42, 0.16)


func _process(_delta: float) -> void:
	if not tomada and not depositada:
		position.y += sin(Time.get_ticks_msec() * 0.004 + position.x) * 0.02


func liberar() -> void:
	if not depositada:
		tomada = false
