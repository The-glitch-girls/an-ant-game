extends Control

const TIERRA := Color(0.725, 0.478, 0.275)
const TIERRA_CLARA := Color(0.78, 0.55, 0.32, 0.18)
const AMBAR := Color(0.83, 0.58, 0.22)
const HUESO := Color(0.93, 0.86, 0.72)
const MARRON := Color(0.25, 0.16, 0.10)

const FUENTE_COINY = preload("res://fonts/Coiny-Regular.ttf")

func _ready() -> void:
	_armar()
	_crear_hormigas()

func _armar() -> void:
	# --------------------------------------------------
	# FONDO
	# --------------------------------------------------
	var fondo := ColorRect.new()
	fondo.color = TIERRA
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)

	var frio := ColorRect.new()
	frio.color = TIERRA_CLARA
	#frio.color = Color(0.78, 0.55, 0.32, 0.18)
	frio.set_anchors_preset(Control.PRESET_FULL_RECT)
	frio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frio)

	# --------------------------------------------------
	# CONTENIDO
	# --------------------------------------------------
	var centrador := CenterContainer.new()
	centrador.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centrador)

	var caja := VBoxContainer.new()
	caja.custom_minimum_size = Vector2(1000, 0)
	caja.add_theme_constant_override("separation", 14)
	centrador.add_child(caja)

	# Caja amplia para que el título pueda respirar
	caja.position = Vector2(190, 190)
	caja.size = Vector2(900, 400)
	caja.add_theme_constant_override("separation", 14)
	add_child(caja)

	# --------------------------------------------------
	# TITULO
	# --------------------------------------------------
	var titulo := Label.new()
	titulo.text = "HORMIGA EN CONSTRUCCIÓN"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_override("font", FUENTE_COINY)	
	titulo.add_theme_font_size_override("font_size", 64)
	titulo.add_theme_color_override("font_color", HUESO)
	titulo.add_theme_color_override("font_shadow_color", Color(0.25, 0.15, 0.08, 0.45))
	titulo.add_theme_constant_override("shadow_offset_x", 3)
	titulo.add_theme_constant_override("shadow_offset_y", 4)
	caja.add_child(titulo)
	
	# --------------------------------------------------
	# LINEA DECORATIVA
	# --------------------------------------------------
	var linea := ColorRect.new()
	linea.color = AMBAR
	linea.custom_minimum_size = Vector2(0, 2)
	caja.add_child(linea)
	
	# --------------------------------------------------
	# HISTORIA
	# --------------------------------------------------
	var historia := VBoxContainer.new()
	historia.add_theme_constant_override("separation", 2)
	caja.add_child(historia)
	
	# La Reina
	var reina := Label.new()
	reina.text = "La Reina ha desaparecido."
	reina.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reina.add_theme_font_override("font", FUENTE_COINY)
	reina.add_theme_font_size_override("font_size", 25)
	reina.add_theme_color_override("font_color", HUESO)
	historia.add_child(reina)
	
	# Hormiguero
	var hormiguero := Label.new()
	hormiguero.text = "El hormiguero está fragmentado."
	hormiguero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hormiguero.add_theme_font_override("font", FUENTE_COINY)
	hormiguero.add_theme_font_size_override("font_size", 21)
	hormiguero.add_theme_color_override("font_color", Color(0.94, 0.78, 0.50))
	historia.add_child(hormiguero)
	
	# Invierno
	var invierno := Label.new()
	invierno.text = "El invierno se acerca."
	invierno.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	invierno.add_theme_font_override("font", FUENTE_COINY)
	invierno.add_theme_font_size_override("font_size", 24)
	invierno.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78))
	historia.add_child(invierno)

	# --------------------------------------------------
	# ESPACIO
	# --------------------------------------------------
	var espacio := Control.new()
	espacio.custom_minimum_size = Vector2(0, 10)
	caja.add_child(espacio)

	# --------------------------------------------------
	# BOTONES
	# --------------------------------------------------
	caja.add_child(_boton("Jugar", _on_jugar))
	caja.add_child(_boton("Configuración", _on_config))
	caja.add_child(_boton("Salir", _on_salir))


func _boton(texto: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(440, 48)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_override("font", FUENTE_COINY)
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_color_override("font_color", HUESO)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", AMBAR)
	
	# Estilo normal
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.27, 0.17, 0.11, 0.90)
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	
	# Estilo hover
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.34, 0.22, 0.14, 1.0)
	hover.corner_radius_top_left = 8
	hover.corner_radius_top_right = 8
	hover.corner_radius_bottom_left = 8
	hover.corner_radius_bottom_right = 8
	hover.border_width_left = 2
	hover.border_width_right = 2
	hover.border_width_top = 2
	hover.border_width_bottom = 2
	hover.border_color = AMBAR

	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	
	b.pressed.connect(cb)
	return b


func _on_jugar() -> void:
	Juego.ir_mundo()

func _on_config() -> void:
	Juego.ir_configuracion()

func _on_salir() -> void:
	get_tree().quit()

func _crear_hormigas() -> void:
	var hormiga := TextureRect.new()
	#hormiga.texture = preload("res://assets/hormiga_temp.png")
	hormiga.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hormiga.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hormiga.size = Vector2(45, 45)
	hormiga.position = Vector2(-60, 120)
	hormiga.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hormiga)
	
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(
		hormiga,
		"position",
		Vector2(1360, 120),
		12.0
	)

	tween.tween_property(
		hormiga,
		"position",
		Vector2(-60, 120),
		0.0
	)
