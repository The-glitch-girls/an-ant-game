extends Control


func _ready() -> void:
	var fondo := ColorRect.new()
	fondo.color = Paleta.TIERRA
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var tarjeta := UiCozzy.tarjeta()
	tarjeta.set_anchors_preset(Control.PRESET_CENTER)
	tarjeta.offset_left = -240
	tarjeta.offset_right = 240
	tarjeta.offset_top = -170
	tarjeta.offset_bottom = 180
	add_child(tarjeta)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 16)
	tarjeta.add_child(caja)

	caja.add_child(UiCozzy.pastilla("Configuración"))

	var vol_label := Label.new()
	vol_label.text = "Volumen"
	UiCozzy.estilar_texto(vol_label, 18)
	caja.add_child(vol_label)

	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.05
	slider.value = Juego.volumen
	slider.value_changed.connect(Juego.set_volumen)
	caja.add_child(slider)

	var full := CheckButton.new()
	full.text = "Pantalla completa"
	full.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	full.add_theme_color_override("font_color", Paleta.TINTA)
	full.toggled.connect(_on_full)
	caja.add_child(full)

	var volver := Button.new()
	volver.text = "Volver"
	UiCozzy.estilar_boton(volver)
	volver.pressed.connect(Juego.ir_menu)
	caja.add_child(volver)


func _on_full(on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED
	)
