class_name Onboarding
extends CanvasLayer

signal termino

var _raiz: Control
var _hormiga: Sprite2D
var _frame := 12
var _cerrado: bool = false


func _ready() -> void:
	layer = 20
	_armar()


func _armar() -> void:
	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_raiz)

	var velo := ColorRect.new()
	velo.color = Color(0.16, 0.09, 0.05, 0.32)
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(velo)

	var card := UiCozzy.tarjeta()
	var panel: StyleBoxFlat = card.get_theme_stylebox("panel").duplicate()
	panel.set_content_margin_all(32)
	card.add_theme_stylebox_override("panel", panel)
	card.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	card.offset_left = 36
	card.offset_right = -36
	card.offset_top = -340
	card.offset_bottom = -20
	_raiz.add_child(card)

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 36)
	fila.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card.add_child(fila)

	var hueco := Control.new()
	hueco.custom_minimum_size = Vector2(200, 0)
	hueco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(hueco)
	_crear_hormiga(hueco)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 14)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_child(col)

	var titulo := Label.new()
	titulo.text = "La Reina ha desaparecido."
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiCozzy.estilar_texto(titulo, 40)
	col.add_child(titulo)

	var situacion := Label.new()
	situacion.text = "El hormiguero está fragmentado. El invierno se acerca."
	situacion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiCozzy.estilar_texto(situacion, 22, Paleta.TINTA.lightened(0.16))
	col.add_child(situacion)

	var mision := Label.new()
	mision.text = "Trae cinco Comidas al Almacén. Una a la vez."
	mision.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiCozzy.estilar_texto(mision, 24, Paleta.TERRACOTA)
	col.add_child(mision)

	var acciones := HBoxContainer.new()
	acciones.alignment = BoxContainer.ALIGNMENT_END
	acciones.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(acciones)
	var seguir := Button.new()
	seguir.text = "Continuar"
	seguir.custom_minimum_size = Vector2(220, 52)
	UiCozzy.estilar_boton(seguir)
	seguir.add_theme_font_size_override("font_size", 24)
	seguir.pressed.connect(_cerrar)
	acciones.add_child(seguir)


func _crear_hormiga(padre: Control) -> void:
	_hormiga = Sprite2D.new()
	_hormiga.texture = preload("res://assets/mpandiarajan_ants.png")
	_hormiga.hframes = 12
	_hormiga.vframes = 8
	_hormiga.frame = 12
	_hormiga.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_hormiga.scale = Vector2(3.4, 3.4)
	_hormiga.position = Vector2(100, 150)
	padre.add_child(_hormiga)
	var timer := Timer.new()
	timer.wait_time = 0.14
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_animar)


func _animar() -> void:
	if _hormiga == null:
		return
	_frame += 1
	if _frame > 14:
		_frame = 12
	_hormiga.frame = _frame


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("saltar"):
		_cerrar()
		get_viewport().set_input_as_handled()


func _cerrar() -> void:
	if _cerrado:
		return
	_cerrado = true
	var tw := create_tween()
	tw.tween_property(_raiz, "modulate:a", 0.0, 0.32).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(func() -> void:
		termino.emit()
		queue_free()
	)
