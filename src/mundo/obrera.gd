class_name Obrera
extends CharacterBody2D

var ruta: Array = []
var _i: int = 0
var _cuerpo: Node2D
var _paso: float = 0.0
var _lleva_miga: bool = false
var vel: float = 42.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	motion_mode = MOTION_MODE_FLOATING
	_lleva_miga = randf() > 0.55
	vel = randf_range(34.0, 52.0)
	_dibujar()


func _dibujar() -> void:
	_cuerpo = Node2D.new()
	add_child(_cuerpo)
	_cuerpo.add_child(_ovalo(Vector2(-8, 0), Vector2(12, 9), Paleta.HORMIGA_OSCURA))
	_cuerpo.add_child(_ovalo(Vector2(2, 0), Vector2(10, 8), Paleta.HORMIGA))
	_cuerpo.add_child(_ovalo(Vector2(11, -1), Vector2(8, 7), Paleta.HORMIGA_PANZA))
	_cuerpo.add_child(_ovalo(Vector2(13, -2), Vector2(2.4, 2.4), Paleta.OJO))
	if _lleva_miga:
		var miga := Polygon2D.new()
		miga.color = Paleta.AMBAR
		miga.position = Vector2(16, 3)
		miga.polygon = PackedVector2Array([Vector2(-4, 0), Vector2(5, -3), Vector2(4, 3)])
		_cuerpo.add_child(miga)
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 7
	col.shape = shape
	add_child(col)


func _ovalo(pos: Vector2, tam: Vector2, color: Color) -> Polygon2D:
	var p := Polygon2D.new()
	p.color = color
	p.position = pos
	var pts := PackedVector2Array()
	for i in 10:
		var a := TAU * i / 10.0
		pts.append(Vector2(cos(a) * tam.x * 0.5, sin(a) * tam.y * 0.5))
	p.polygon = pts
	return p


func _physics_process(delta: float) -> void:
	if ruta.is_empty():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var objetivo: Vector2 = ruta[_i]
	var delta_pos := objetivo - global_position
	if delta_pos.length() < 10.0:
		_i = (_i + 1) % ruta.size()
		objetivo = ruta[_i]
		delta_pos = objetivo - global_position
	var dir := delta_pos.normalized()
	velocity = dir * vel
	rotation = dir.angle()
	_paso += delta * 12.0
	_cuerpo.position.y = sin(_paso) * 1.1
	move_and_slide()
