extends Control

const TIERRA := Color(0.12, 0.07, 0.05)
const HUESO := Color(0.86, 0.78, 0.68)


func _ready() -> void:
	var fondo := ColorRect.new()
	fondo.color = TIERRA
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_CENTER)
	caja.offset_left = -240
	caja.offset_right = 240
	caja.offset_top = -140
	caja.offset_bottom = 160
	caja.add_theme_constant_override("separation", 18)
	add_child(caja)

	var titulo := Label.new()
	titulo.text = "Configuración"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_color_override("font_color", HUESO)
	titulo.add_theme_font_size_override("font_size", 36)
	caja.add_child(titulo)

	var vol_label := Label.new()
	vol_label.text = "Volumen"
	vol_label.add_theme_color_override("font_color", HUESO)
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
	full.toggled.connect(_on_full)
	caja.add_child(full)

	var volver := Button.new()
	volver.text = "Volver"
	volver.pressed.connect(Juego.ir_menu)
	caja.add_child(volver)


func _on_full(on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED
	)
