extends Node2D
class_name FragmentoPieza

var tipo: Partida.Fragmento
var tomada: bool = false
var texture: Texture2D

func _init(t: Partida.Fragmento, tex: Texture2D) -> void:
	tipo = t
	texture = tex

func _ready() -> void:
	add_to_group("fragmento")
	print("Fragmento creado en: ", global_position, " tipo: ", tipo)
	
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(0.15, 0.15)
	add_child(sprite)
	
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 2
	area.monitoring = true
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 20.0
	col.shape = shape
	area.add_child(col)
	area.body_entered.connect(_on_body_entered)
	add_child(area)
	
	print("Área de colisión configurada, capa: ", area.collision_layer, " máscara: ", area.collision_mask)

func _on_body_entered(body: Node) -> void:
	print("Cuerpo detectado: ", body.name, " tipo: ", body.get_class())
	if body is CharacterBody2D and not tomada:
		var p: Partida = Juego.partida
		if p != null:
			p.recolectar_fragmento(tipo)
			tomada = true
			visible = false
			print("Fragmento recolectado: ", tipo)


