class_name HormigaVista
extends CharacterBody2D

const VEL_CAMINAR := 88.0
const VEL_CORRER := 140.0
const VEL_CARGAR := 48.0
const VEL_ARRASTRE := 26.0

signal intento_mover
signal cerca_de_comida(pieza: Node2D)

var gasta_energia: bool = false
var _gasto_acum: float = 0.0
var _mandibulas: Node2D
var _cuerpo: Node2D
var _patas: Array[Node2D] = []
var _comidas_vista: Array[Node2D] = []
var _sensor: Area2D
var _paso: float = 0.0
var energia: int = 100
var energia_maxima: int = 100


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	motion_mode = MOTION_MODE_FLOATING
	_dibujar()
	_armar_sensor()


func _dibujar() -> void:
	_cuerpo = Node2D.new()
	_cuerpo.name = "Cuerpo"
	add_child(_cuerpo)

	for i in 3:
		var pata_par := Node2D.new()
		_cuerpo.add_child(pata_par)
		_patas.append(pata_par)
		var y := -9 if i != 1 else 9
		pata_par.add_child(_segmento(Vector2(-8 + i * 7, y), Vector2(11, 2.2), Paleta.HORMIGA_OSCURA, 0.7 if y < 0 else -0.7))
		pata_par.add_child(_segmento(Vector2(-8 + i * 7, y), Vector2(8, 1.8), Paleta.OJO, 1.15 if y < 0 else -1.15))

	_cuerpo.add_child(_ovalo(Vector2(-11, 0), Vector2(16, 12), Paleta.HORMIGA_OSCURA))
	_cuerpo.add_child(_ovalo(Vector2(1, 0), Vector2(13, 10), Paleta.HORMIGA))
	_cuerpo.add_child(_ovalo(Vector2(13, -1), Vector2(11, 9), Paleta.HORMIGA_PANZA))
	_cuerpo.add_child(_ovalo(Vector2(16, -3), Vector2(3, 3), Paleta.OJO))

	var ant1 := _segmento(Vector2(18, -5), Vector2(9, 1.4), Paleta.OJO, -0.8)
	var ant2 := _segmento(Vector2(18, 2), Vector2(8, 1.4), Paleta.OJO, 0.35)
	_cuerpo.add_child(ant1)
	_cuerpo.add_child(ant2)

	_mandibulas = Node2D.new()
	_mandibulas.position = Vector2(18, 1)
	_cuerpo.add_child(_mandibulas)
	var m1 := _ovalo(Vector2(5, -3), Vector2(7, 2.4), Paleta.HORMIGA_OSCURA)
	var m2 := _ovalo(Vector2(5, 3), Vector2(7, 2.4), Paleta.HORMIGA_OSCURA)
	m1.rotation = -0.3
	m2.rotation = 0.3
	_mandibulas.add_child(m1)
	_mandibulas.add_child(m2)

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 9
	col.shape = shape
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


func _segmento(pos: Vector2, tam: Vector2, color: Color, rot: float) -> Polygon2D:
	var p := _ovalo(pos, tam, color)
	p.rotation = rot
	return p


func _armar_sensor() -> void:
	_sensor = Area2D.new()
	_sensor.collision_layer = 0
	_sensor.collision_mask = 4 | 8
	_sensor.name = "Sensor"
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16
	col.shape = shape
	_sensor.add_child(col)
	add_child(_sensor)
	_sensor.area_entered.connect(_on_area)


func _on_area(area: Area2D) -> void:
	if area.is_in_group("comida"):
		cerca_de_comida.emit(area)


func _physics_process(delta: float) -> void:
	var en_curso := Juego.partida != null and Juego.partida.resultado == Partida.Resultado.EN_CURSO
	var dir := Vector2(
		Input.get_axis("mover_izquierda", "mover_derecha"),
		Input.get_axis("mover_arriba", "mover_abajo")
	)
	if dir.length() > 1.0:
		dir = dir.normalized()

	var vel := VEL_CAMINAR
	var quiere_correr := Input.is_action_pressed("correr") and dir != Vector2.ZERO
	if not en_curso:
		dir = Vector2.ZERO
	elif Juego.partida.arrastrandose:
		vel = VEL_ARRASTRE
	elif Juego.partida.lleva_comida:
		vel = VEL_CARGAR
	elif quiere_correr:
		vel = VEL_CORRER

	velocity = dir * vel
	move_and_slide()

	if dir.length() > 0.15:
		rotation = dir.angle()
		_paso += delta * 14.0
		_gasto_acum += delta
		var ritmo := 0.34 if quiere_correr else 0.52
		if en_curso and _gasto_acum >= ritmo:
			_gasto_acum = 0.0
			intento_mover.emit()
			if gasta_energia:
				Juego.partida.correr()
	for i in _patas.size():
		_patas[i].rotation = sin(_paso + i) * 0.25 if dir.length() > 0.15 else 0.0

	_mandibulas.rotation = 0.35 if (Juego.partida and Juego.partida.lleva_comida) or not _comidas_vista.is_empty() else 0.0
	if Juego.partida:
		var cansancio := 1.0 - (Juego.partida.energia / 100.0)
		modulate = Color(0.55, 0.45, 0.4) if Juego.partida.arrastrandose else Color(1, 1.0 - cansancio * 0.2, 1.0 - cansancio * 0.3)

	for i in _comidas_vista.size():
		var pieza := _comidas_vista[i]
		if is_instance_valid(pieza):
			var lateral := Vector2(0, (i - 1) * 10.0).rotated(rotation)
			pieza.global_position = global_position + Vector2.RIGHT.rotated(rotation) * 18.0 + lateral

	_revisar_comida_solapada()


func _revisar_comida_solapada() -> void:
	if _sensor == null:
		return
	for area in _sensor.get_overlapping_areas():
		if area.is_in_group("comida"):
			cerca_de_comida.emit(area)


func tiene_comida_vista() -> bool:
	return not _comidas_vista.is_empty()


func tomar(pieza: Node2D) -> void:
	_comidas_vista.append(pieza)
	pieza.reparent(self)


func soltar_una_vista() -> Node2D:
	if _comidas_vista.is_empty():
		return null
	var pieza := _comidas_vista.pop_front() as Node2D
	if is_instance_valid(pieza):
		var pos := pieza.global_position
		pieza.reparent(get_parent())
		pieza.global_position = pos
	return pieza


func soltar_vista() -> void:
	while not _comidas_vista.is_empty():
		var pieza := soltar_una_vista()
		if pieza is ComidaPieza:
			(pieza as ComidaPieza).liberar()
