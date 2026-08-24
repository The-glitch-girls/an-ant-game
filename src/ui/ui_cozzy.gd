class_name UiCozzy
extends Object

const FUENTE := preload("res://fonts/Coiny-Regular.ttf")


static func panel_crema(radio: int = 22) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Paleta.CREMA
	sb.set_corner_radius_all(radio)
	sb.set_content_margin_all(22)
	sb.shadow_color = Color(0.22, 0.12, 0.08, 0.16)
	sb.shadow_size = 10
	sb.shadow_offset = Vector2(0, 3)
	return sb


static func panel_terracota(radio: int = 14) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Paleta.TERRACOTA
	sb.set_corner_radius_all(radio)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb


static func estilo_boton(hover: bool = false) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Paleta.TERRACOTA if hover else Paleta.CREMA
	sb.set_corner_radius_all(16)
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.border_color = Paleta.TRAZO
	sb.set_border_width_all(2)
	return sb


static func estilar_boton(b: Button) -> void:
	b.add_theme_stylebox_override("normal", estilo_boton(false))
	b.add_theme_stylebox_override("hover", estilo_boton(true))
	b.add_theme_stylebox_override("pressed", estilo_boton(true))
	b.add_theme_stylebox_override("focus", estilo_boton(false))
	b.add_theme_color_override("font_color", Paleta.TINTA)
	b.add_theme_color_override("font_hover_color", Paleta.CREMA)
	b.add_theme_color_override("font_pressed_color", Paleta.CREMA)
	b.add_theme_font_override("font", FUENTE)
	b.add_theme_font_size_override("font_size", 22)
	b.custom_minimum_size.y = 46


static func estilar_texto(lab: Label, tam: int, color: Color = Paleta.TINTA) -> void:
	lab.add_theme_font_override("font", FUENTE)
	lab.add_theme_color_override("font_color", color)
	lab.add_theme_font_size_override("font_size", tam)


static func pastilla(texto: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", panel_terracota())
	var lab := Label.new()
	lab.text = texto
	estilar_texto(lab, 15, Color(0.99, 0.96, 0.92))
	p.add_child(lab)
	return p


static func tarjeta() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", panel_crema())
	return p


static func corazon_pts(centro: Vector2, escala: float, semilla: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := 24
	for i in n:
		var t: float = TAU * float(i) / float(n)
		var x: float = 16.0 * pow(sin(t), 3.0)
		var y: float = -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
		var j: float = 1.0 + 0.07 * sin(t * 3.0 + semilla * 1.7)
		pts.append(centro + Vector2(x, y) * (escala / 16.0) * j)
	return pts


static func semilla_pts(centro: Vector2, escala: float, semilla: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := 14
	for i in n:
		var t: float = TAU * float(i) / float(n)
		var j: float = 1.0 + 0.08 * sin(t * 2.0 + semilla)
		pts.append(centro + Vector2(cos(t) * 0.62, sin(t) * 1.0 - 0.15) * escala * j)
	return pts


static func dibujar_icono(c: CanvasItem, pts: PackedVector2Array, relleno: Color) -> void:
	if pts.size() < 3:
		return
	c.draw_colored_polygon(pts, relleno)
	c.draw_polyline(pts + PackedVector2Array([pts[0]]), Paleta.TRAZO, 2.1, true)


static func dibujar_corazon(c: CanvasItem, centro: Vector2, escala: float, lleno: bool, semilla: float) -> void:
	var relleno := Paleta.CORAZON if lleno else Paleta.CORAZON_VACIO
	dibujar_icono(c, corazon_pts(centro, escala, semilla), relleno)


static func dibujar_semilla(c: CanvasItem, centro: Vector2, escala: float, llena: bool, semilla: float) -> void:
	var relleno := Paleta.AMBAR if llena else Paleta.CORAZON_VACIO
	dibujar_icono(c, semilla_pts(centro, escala, semilla), relleno)


static func dibujar_marco(c: CanvasItem, rect: Rect2, radio: float) -> void:
	c.draw_rect(rect, Paleta.CREMA)
	var pts := _ronda(rect, radio, 5)
	c.draw_polyline(pts, Paleta.TRAZO, 2.0, true)


static func _ronda(rect: Rect2, radio: float, por_esquina: int) -> PackedVector2Array:
	var r: float = minf(radio, minf(rect.size.x, rect.size.y) * 0.5)
	var centros := [
		Vector2(rect.end.x - r, rect.position.y + r),
		Vector2(rect.end.x - r, rect.end.y - r),
		Vector2(rect.position.x + r, rect.end.y - r),
		Vector2(rect.position.x + r, rect.position.y + r),
	]
	var pts := PackedVector2Array()
	for e in 4:
		var base: float = -PI * 0.5 + float(e) * PI * 0.5
		for i in por_esquina:
			var a: float = base + (PI * 0.5) * float(i) / float(por_esquina)
			var j: float = 1.0 + 0.035 * sin(a * 5.0 + float(e))
			pts.append(centros[e] + Vector2(cos(a), sin(a)) * r * j)
	if pts.size() > 0:
		pts.append(pts[0])
	return pts
