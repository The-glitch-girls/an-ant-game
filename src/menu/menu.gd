extends Control


func _ready() -> void:
	_armar()


func _armar() -> void:
	var fondo := ColorRect.new()
	fondo.color = Paleta.TIERRA
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var lavado := ColorRect.new()
	lavado.color = Color(1.0, 0.84, 0.56, 0.18)
	lavado.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(lavado)

	var tarjeta := UiCozzy.tarjeta()
	tarjeta.set_anchors_preset(Control.PRESET_CENTER)
	tarjeta.offset_left = -230
	tarjeta.offset_right = 230
	tarjeta.offset_top = -210
	tarjeta.offset_bottom = 230
	add_child(tarjeta)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 14)
	tarjeta.add_child(caja)

	var titulo := Label.new()
	titulo.text = "COLONIA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiCozzy.estilar_texto(titulo, 42)
	caja.add_child(titulo)

	caja.add_child(UiCozzy.pastilla("El Hormiguero"))

	var sub := Label.new()
	sub.text = "La Reina ha desaparecido.\nEl Hormiguero está fragmentado.\nEl Invierno se acerca."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiCozzy.estilar_texto(sub, 16, Paleta.TIERRA_OSCURA)
	caja.add_child(sub)

	caja.add_child(_boton("Jugar", _on_jugar))
	caja.add_child(_boton("Configuración", _on_config))
	caja.add_child(_boton("Salir", _on_salir))


func _boton(texto: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = texto
	UiCozzy.estilar_boton(b)
	b.pressed.connect(cb)
	return b


func _on_jugar() -> void:
	Juego.ir_mundo()


func _on_config() -> void:
	Juego.ir_configuracion()


func _on_salir() -> void:
	get_tree().quit()
