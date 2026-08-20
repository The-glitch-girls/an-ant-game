extends Control

const TIERRA := Color(0.12, 0.07, 0.05)
const AMBAR := Color(0.83, 0.63, 0.22)
const HUESO := Color(0.86, 0.78, 0.68)


func _ready() -> void:
	_armar()


func _armar() -> void:
	var fondo := ColorRect.new()
	fondo.color = TIERRA
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var frio := ColorRect.new()
	frio.color = Color(0.45, 0.55, 0.62, 0.12)
	frio.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(frio)

	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_CENTER)
	caja.offset_left = -220
	caja.offset_right = 220
	caja.offset_top = -180
	caja.offset_bottom = 220
	caja.add_theme_constant_override("separation", 16)
	add_child(caja)

	var titulo := Label.new()
	titulo.text = "COLONIA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_color_override("font_color", HUESO)
	titulo.add_theme_font_size_override("font_size", 64)
	caja.add_child(titulo)

	var linea := ColorRect.new()
	linea.color = AMBAR
	linea.custom_minimum_size = Vector2(0, 2)
	caja.add_child(linea)

	var sub := Label.new()
	sub.text = "La Reina ha desaparecido.\nEl Hormiguero está fragmentado.\nEl Invierno se acerca."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", Color(0.7, 0.6, 0.5))
	sub.add_theme_font_size_override("font_size", 16)
	caja.add_child(sub)

	caja.add_child(_boton("Jugar", _on_jugar))
	caja.add_child(_boton("Configuración", _on_config))
	caja.add_child(_boton("Salir", _on_salir))


func _boton(texto: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(0, 44)
	b.add_theme_color_override("font_color", HUESO)
	b.add_theme_color_override("font_hover_color", AMBAR)
	b.add_theme_font_size_override("font_size", 22)
	b.pressed.connect(cb)
	return b


func _on_jugar() -> void:
	Juego.ir_mundo()


func _on_config() -> void:
	Juego.ir_configuracion()


func _on_salir() -> void:
	get_tree().quit()
