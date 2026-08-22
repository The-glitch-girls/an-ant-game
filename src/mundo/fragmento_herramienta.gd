class_name FragmentoHerramienta
extends Area2D

signal tocado(herramienta: Partida.Herramienta, id: String, fragmento: FragmentoHerramienta)

var herramienta: Partida.Herramienta
var id: String
var recogido: bool = false

const RUTAS_FRAGMENTOS := {
	Partida.Herramienta.HOJA: {
		"tallo": "res://assets/items/leaf_tallo_cc0.png",
		"cuerpo": "res://assets/items/leaf_cuerpo_cc0.png",
		"borde": "res://assets/items/leaf_borde_cc0.png",
	},
	Partida.Herramienta.PALA: {
		"mango": "res://assets/items/shovel_mango_cc0.png",
		"cabezal": "res://assets/items/shovel_cabezal_cc0.png",
		"restante": "res://assets/items/shovel_restante_cc0.png",
	},
}


func configurar(nueva_herramienta: Partida.Herramienta, nuevo_id: String) -> void:
	herramienta = nueva_herramienta
	id = nuevo_id


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	monitoring = true
	monitorable = true
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 12
	col.shape = shape
	add_child(col)
	_dibujar()
	body_entered.connect(_on_body_entered)


func recoger() -> void:
	if recogido:
		return
	recogido = true
	set_deferred("monitoring", false)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not recogido and body is HormigaVista:
		tocado.emit(herramienta, id, self)


func _dibujar() -> void:
	var rutas: Dictionary = RUTAS_FRAGMENTOS.get(herramienta, {})
	var ruta: String = rutas.get(id, "")
	if ruta.is_empty():
		return
	var sprite := Sprite2D.new()
	sprite.texture = load(ruta)
	sprite.scale = Vector2(1.15, 1.15)
	add_child(sprite)
