class_name Reina
extends StaticBody2D

var _abdomen: Node2D
var _aliento: float = 0.0


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	_dibujar()


func largo() -> float:
	return 78.0


func _dibujar() -> void:
	var cuerpo := Node2D.new()
	cuerpo.rotation = 0.35
	add_child(cuerpo)

	# alas caídas: estuvo alada, ya no vuela
	cuerpo.add_child(_ala(Vector2(-6, -16), -0.55))
	cuerpo.add_child(_ala(Vector2(-6, 16), 0.55))

	for i in 3:
		var y := -16.0 if i != 1 else 16.0
		cuerpo.add_child(_ovalo(Vector2(-10 + i * 8, y), Vector2(16, 3.2), Paleta.HORMIGA_OSCURA, 0.55 if y < 0.0 else -0.55))

	_abdomen = Node2D.new()
	cuerpo.add_child(_abdomen)
	_abdomen.add_child(_ovalo(Vector2(-28, 0), Vector2(46, 30), Color(0.42, 0.16, 0.08)))
	_abdomen.add_child(_ovalo(Vector2(-22, 0), Vector2(34, 24), Paleta.HORMIGA_OSCURA))
	_abdomen.add_child(_ovalo(Vector2(-18, -2), Vector2(8, 6), Color(0.62, 0.28, 0.12, 0.45)))

	cuerpo.add_child(_ovalo(Vector2(4, 0), Vector2(20, 15), Paleta.HORMIGA))
	cuerpo.add_child(_ovalo(Vector2(18, -1), Vector2(16, 13), Paleta.HORMIGA_PANZA))
	cuerpo.add_child(_ovalo(Vector2(22, -3), Vector2(4, 4), Paleta.OJO))
	cuerpo.add_child(_ovalo(Vector2(26, -8), Vector2(11, 2.2), Paleta.OJO, -0.7))
	cuerpo.add_child(_ovalo(Vector2(26, 4), Vector2(10, 2.0), Paleta.OJO, 0.4))

	var col := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 16
	shape.height = 52
	col.shape = shape
	col.rotation = 0.35
	add_child(col)


func _ala(pos: Vector2, rot: float) -> Polygon2D:
	var p := Polygon2D.new()
	p.color = Color(0.78, 0.72, 0.58, 0.35)
	p.position = pos
	p.rotation = rot
	p.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(22, -6), Vector2(28, 2), Vector2(8, 5)
	])
	return p


func _ovalo(pos: Vector2, tam: Vector2, color: Color, rot: float = 0.0) -> Polygon2D:
	var p := Polygon2D.new()
	p.color = color
	p.position = pos
	p.rotation = rot
	var pts := PackedVector2Array()
	for i in 12:
		var a := TAU * i / 12.0
		pts.append(Vector2(cos(a) * tam.x * 0.5, sin(a) * tam.y * 0.5))
	p.polygon = pts
	return p


func _process(delta: float) -> void:
	_aliento += delta
	if _abdomen:
		_abdomen.scale = Vector2(1.0 + sin(_aliento * 1.4) * 0.03, 1.0 + sin(_aliento * 1.4) * 0.02)
