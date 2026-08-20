class_name HormigaVista
extends CharacterBody2D

const GRAVEDAD := 980.0
const VEL_CAMINAR := 92.0
const VEL_CORRER := 148.0
const VEL_CARGAR := 52.0
const VEL_ARRASTRE := 28.0
const SALTO := 290.0

signal intento_saltar
signal intento_correr
signal cerca_de_comida(pieza: Node2D)

var _gasto_acum: float = 0.0
var _mandibulas: Node2D
var _cuerpo: Node2D
var _comida_vista: Node2D


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	_dibujar()
	_sensor()


func _dibujar() -> void:
	_cuerpo = Node2D.new()
	_cuerpo.name = "Cuerpo"
	add_child(_cuerpo)

	var abdomen := _ovalo(Vector2(-10, 1), Vector2(16, 11), Color(0.12, 0.07, 0.04))
	var torax := _ovalo(Vector2(2, 0), Vector2(12, 9), Color(0.16, 0.09, 0.05))
	var cabeza := _ovalo(Vector2(13, -1), Vector2(10, 8), Color(0.1, 0.05, 0.03))
	_cuerpo.add_child(abdomen)
	_cuerpo.add_child(torax)
	_cuerpo.add_child(cabeza)

	_mandibulas = Node2D.new()
	_mandibulas.position = Vector2(18, 1)
	_cuerpo.add_child(_mandibulas)
	var m1 := _ovalo(Vector2(4, -3), Vector2(6, 2), Color(0.08, 0.04, 0.02))
	var m2 := _ovalo(Vector2(4, 3), Vector2(6, 2), Color(0.08, 0.04, 0.02))
	m1.rotation = -0.25
	m2.rotation = 0.25
	_mandibulas.add_child(m1)
	_mandibulas.add_child(m2)

	var col := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 7
	shape.height = 28
	col.shape = shape
	col.rotation = PI / 2
	add_child(col)


func _ovalo(pos: Vector2, tam: Vector2, color: Color) -> Polygon2D:
	var p := Polygon2D.new()
	p.color = color
	p.position = pos
	var pts := PackedVector2Array()
	for i in 12:
		var a := TAU * i / 12.0
		pts.append(Vector2(cos(a) * tam.x * 0.5, sin(a) * tam.y * 0.5))
	p.polygon = pts
	return p


func _sensor() -> void:
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 4 | 8
	area.name = "Sensor"
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16
	col.shape = shape
	area.add_child(col)
	add_child(area)
	area.area_entered.connect(_on_area)


func _on_area(area: Area2D) -> void:
	if area.is_in_group("comida"):
		cerca_de_comida.emit(area)


func _physics_process(delta: float) -> void:
	if not Juego.partida or Juego.partida.resultado != Partida.Resultado.EN_CURSO:
		velocity.x = 0
		velocity.y += GRAVEDAD * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += GRAVEDAD * delta

	var dir := Input.get_axis("mover_izquierda", "mover_derecha")
	var quiere_correr := Input.is_action_pressed("correr") and dir != 0.0
	var vel := VEL_CAMINAR
	if Juego.partida.arrastrandose:
		vel = VEL_ARRASTRE
	elif Juego.partida.lleva_comida:
		vel = VEL_CARGAR
	elif quiere_correr:
		vel = VEL_CORRER

	velocity.x = dir * vel
	if dir != 0.0:
		_cuerpo.scale.x = signf(dir)

	if Input.is_action_just_pressed("saltar") and is_on_floor() and not Juego.partida.arrastrandose:
		velocity.y = -SALTO
		intento_saltar.emit()

	move_and_slide()

	if absf(dir) > 0.1:
		_gasto_acum += delta
		var ritmo := 0.34 if quiere_correr else 0.52
		if _gasto_acum >= ritmo:
			_gasto_acum = 0.0
			intento_correr.emit()
			if quiere_correr:
				Juego.partida.correr()
			else:
				Juego.partida.correr()

	_mandibulas.rotation = 0.35 if Juego.partida.lleva_comida or _comida_vista else 0.0
	var cansancio := 1.0 - (Juego.partida.energia / 100.0)
	if Juego.partida.arrastrandose:
		modulate = Color(0.55, 0.45, 0.4)
	else:
		modulate = Color(1, 1.0 - cansancio * 0.25, 1.0 - cansancio * 0.35)
	_cuerpo.position.y = sin(Time.get_ticks_msec() * 0.012) * (1.2 if absf(dir) > 0.1 else 0.2)

	if _comida_vista and is_instance_valid(_comida_vista):
		_comida_vista.global_position = global_position + Vector2(_cuerpo.scale.x * 18, -6)


func tiene_comida_vista() -> bool:
	return _comida_vista != null and is_instance_valid(_comida_vista)


func comida_vista() -> Node2D:
	return _comida_vista


func tomar(pieza: Node2D) -> void:
	_comida_vista = pieza
	pieza.reparent(self)


func soltar_vista() -> void:
	if _comida_vista and is_instance_valid(_comida_vista):
		var pos := _comida_vista.global_position
		_comida_vista.reparent(get_parent())
		_comida_vista.global_position = pos + Vector2(0, 8)
	_comida_vista = null
