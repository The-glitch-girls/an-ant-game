class_name ComidaPieza
extends Area2D

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


func _dibujar() -> void:
	var semilla := Polygon2D.new()
	semilla.color = Color(0.62, 0.42, 0.16)
	var pts := PackedVector2Array()
	for i in 10:
		var a := TAU * i / 10.0
		pts.append(Vector2(cos(a) * 16, sin(a) * 10))
	semilla.polygon = pts
	add_child(semilla)
	var brillo := Polygon2D.new()
	brillo.color = Color(0.85, 0.68, 0.28, 0.7)
	brillo.polygon = PackedVector2Array([Vector2(-4, -4), Vector2(6, -2), Vector2(2, 3)])
	add_child(brillo)


func _process(_delta: float) -> void:
	if not tomada and not depositada:
		position.y += sin(Time.get_ticks_msec() * 0.004 + position.x) * 0.02
