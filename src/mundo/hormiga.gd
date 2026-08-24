class_name HormigaVista
extends CharacterBody2D

const VEL_CAMINAR := 88.0
const VEL_CORRER := 140.0
const VEL_CARGAR := 48.0
const VEL_ARRASTRE := 26.0

const TEXTURA := preload("res://assets/mpandiarajan_ants.png")
const HFRAMES := 12
const VFRAMES := 8
const FRAMES_PASO := 3
const DIR_ABAJO := 0
const DIR_IZQUIERDA := 1
const DIR_DERECHA := 2
const DIR_ARRIBA := 3

signal intento_mover
signal cerca_de_comida(pieza: Node2D)

var gasta_energia: bool = false
var bloqueada: bool = false
var _gasto_acum: float = 0.0
var _sprite: Sprite2D
var _comida_vista: Node2D
var _sensor: Area2D
var _paso: float = 0.0
var _dir := DIR_DERECHA
var _mira := Vector2.RIGHT
var energia: int = 100
var energia_maxima: int = 100


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	motion_mode = MOTION_MODE_FLOATING
	_dibujar()
	_armar_sensor()


func _dibujar() -> void:
	_sprite = Sprite2D.new()
	_sprite.name = "Cuerpo"
	_sprite.texture = TEXTURA
	_sprite.hframes = HFRAMES
	_sprite.vframes = VFRAMES
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2(0.72, 0.72)
	# El recorte deja aire arriba; baja el dibujo al centro de colisión.
	_sprite.offset = Vector2(0, -20)
	add_child(_sprite)
	_poner_frame(1)

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 9
	col.shape = shape
	add_child(col)


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
	if not en_curso or bloqueada:
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
		_orientar(dir)
		_paso += delta * (18.0 if quiere_correr else 12.0)
		_gasto_acum += delta
		var ritmo := 0.34 if quiere_correr else 0.52
		if en_curso and _gasto_acum >= ritmo:
			_gasto_acum = 0.0
			intento_mover.emit()
			if gasta_energia:
				Juego.partida.correr()
		_poner_frame(int(_paso) % FRAMES_PASO)
	else:
		_poner_frame(1)

	if Juego.partida:
		var cansancio := 1.0 - (Juego.partida.energia / 100.0)
		modulate = Color(0.55, 0.45, 0.4) if Juego.partida.arrastrandose else Color(1, 1.0 - cansancio * 0.2, 1.0 - cansancio * 0.3)

	if _comida_vista and is_instance_valid(_comida_vista):
		_comida_vista.global_position = global_position + _mira * 16.0

	_revisar_comida_solapada()


func _orientar(dir: Vector2) -> void:
	if abs(dir.x) >= abs(dir.y):
		_dir = DIR_DERECHA if dir.x > 0.0 else DIR_IZQUIERDA
		_mira = Vector2.RIGHT if dir.x > 0.0 else Vector2.LEFT
	else:
		_dir = DIR_ABAJO if dir.y > 0.0 else DIR_ARRIBA
		_mira = Vector2.DOWN if dir.y > 0.0 else Vector2.UP


func _poner_frame(paso: int) -> void:
	if _sprite == null:
		return
	_sprite.frame = _dir * HFRAMES + clampi(paso, 0, FRAMES_PASO - 1)


func _revisar_comida_solapada() -> void:
	if _sensor == null:
		return
	for area in _sensor.get_overlapping_areas():
		if area.is_in_group("comida"):
			cerca_de_comida.emit(area)


func tiene_comida_vista() -> bool:
	return _comida_vista != null and is_instance_valid(_comida_vista)


func comida_vista() -> Node2D:
	return _comida_vista


func tomar(pieza: Node2D) -> void:
	_comida_vista = pieza
	pieza.reparent(self)


func soltar_vista() -> void:
	if _comida_vista and is_instance_valid(_comida_vista):
		if _comida_vista is ComidaPieza:
			(_comida_vista as ComidaPieza).liberar()
		var pos := _comida_vista.global_position
		_comida_vista.reparent(get_parent())
		_comida_vista.global_position = pos
	_comida_vista = null
