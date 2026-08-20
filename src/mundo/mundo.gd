extends Node2D

const SEGUNDOS_POR_TIEMPO := 1.2

var _hormiga: HormigaVista
var _sfx: Sfx
var _modulate: CanvasModulate
var _viento_nieve: GPUParticles2D
var _larvas: Array[Node2D] = []
var _bichos: Array[Node2D] = []
var _almacen_area: Area2D
var _reina_area: Area2D
var _descanso_area: Area2D
var _en_descanso: bool = false
var _reloj: float = 0.0
var _final_mostrado: bool = false
var _ui_almacen: Label
var _capas_hielo: Array[ColorRect] = []


func _ready() -> void:
	_sfx = Sfx.new()
	add_child(_sfx)
	_construir_escenario()
	_construir_hormiga()
	_construir_comidas()
	_construir_clima()
	_construir_ui()
	_sfx.tocar("viento")


func _construir_escenario() -> void:
	var suelo_nido := _plataforma(Rect2(-80, 520, 1960, 220), Color(0.18, 0.1, 0.07))
	add_child(suelo_nido)
	var suelo_afuera := _plataforma(Rect2(1760, 460, 2400, 280), Color(0.22, 0.16, 0.08))
	add_child(suelo_afuera)
	add_child(_plataforma(Rect2(-120, 200, 80, 520), Color(0.14, 0.08, 0.05)))
	add_child(_plataforma(Rect2(4000, 80, 80, 700), Color(0.16, 0.12, 0.06)))

	_cueva(Vector2(180, 430), Vector2(280, 180), Color(0.1, 0.06, 0.05), "Cámara de la reina")
	_cueva(Vector2(560, 450), Vector2(240, 140), Color(0.16, 0.1, 0.06), "Larvas")
	_cueva(Vector2(880, 450), Vector2(240, 140), Color(0.2, 0.12, 0.05), "Almacén")
	_cueva(Vector2(1200, 450), Vector2(240, 140), Color(0.14, 0.12, 0.08), "Descanso")

	var derrumbe := _plataforma(Rect2(300, 280, 90, 160), Color(0.08, 0.05, 0.04))
	derrumbe.add_to_group("derrumbada")
	add_child(derrumbe)
	var polvo := GPUParticles2D.new()
	polvo.position = Vector2(345, 360)
	polvo.amount = 12
	polvo.lifetime = 2.4
	polvo.texture = _pixel()
	var mat := ParticleProcessMaterial.new()
	mat.gravity = Vector3(0, 12, 0)
	mat.scale_min = 1.5
	mat.scale_max = 3.0
	mat.color = Color(0.25, 0.16, 0.1, 0.5)
	polvo.process_material = mat
	add_child(polvo)

	add_child(_plataforma(Rect2(1480, 400, 200, 24), Color(0.2, 0.12, 0.07)))
	add_child(_plataforma(Rect2(1640, 360, 160, 24), Color(0.22, 0.14, 0.07)))

	_hoja(Vector2(2100, 420), 0.2)
	_hoja(Vector2(2680, 410), -0.3)
	_hoja(Vector2(3300, 400), 0.15)
	_rama(Vector2(2400, 448))
	_rama(Vector2(3100, 448))

	_reina_area = _zona(Rect2(40, 360, 280, 160), "reina")
	_almacen_area = _zona(Rect2(760, 380, 240, 140), "almacen")
	_descanso_area = _zona(Rect2(1080, 380, 240, 140), "descanso")
	_zona(Rect2(440, 380, 240, 140), "larvas")

	_larvas.append(_larva(Vector2(500, 500)))
	_larvas.append(_larva(Vector2(560, 505)))
	_larvas.append(_larva(Vector2(620, 498)))

	for i in 6:
		var bicho := _ovalo(Vector2(2000 + i * 280, 430), Vector2(8, 5), Color(0.2, 0.35, 0.18, 0.8))
		_bichos.append(bicho)
		add_child(bicho)


func _construir_hormiga() -> void:
	_hormiga = HormigaVista.new()
	_hormiga.position = Vector2(900, 480)
	add_child(_hormiga)
	_hormiga.cerca_de_comida.connect(_on_cerca_comida)
	_hormiga.intento_saltar.connect(func() -> void:
		Juego.partida.saltar()
		_sfx.tocar("paso")
	)
	_hormiga.intento_correr.connect(func() -> void:
		_sfx.tocar("paso")
	)
	var cam := Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 4.0
	cam.zoom = Vector2(1.35, 1.35)
	_hormiga.add_child(cam)
	cam.make_current()


func _construir_comidas() -> void:
	var sitios := [
		Vector2(1760, 430),
		Vector2(2220, 430),
		Vector2(2740, 420),
		Vector2(3220, 418),
		Vector2(3680, 418),
	]
	for p in sitios:
		var c := ComidaPieza.new()
		c.position = p
		add_child(c)


func _construir_clima() -> void:
	_modulate = CanvasModulate.new()
	_modulate.color = Color(1.0, 0.92, 0.82)
	add_child(_modulate)
	_viento_nieve = GPUParticles2D.new()
	_viento_nieve.amount = 40
	_viento_nieve.lifetime = 3.5
	_viento_nieve.position = Vector2(2800, 80)
	_viento_nieve.texture = _pixel()
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(1400, 20, 1)
	mat.direction = Vector3(-1, 0.4, 0)
	mat.spread = 20
	mat.initial_velocity_min = 30
	mat.initial_velocity_max = 70
	mat.gravity = Vector3(0, 8, 0)
	mat.color = Color(0.85, 0.9, 0.95, 0.0)
	_viento_nieve.process_material = mat
	_viento_nieve.emitting = false
	add_child(_viento_nieve)


func _construir_ui() -> void:
	var capa := CanvasLayer.new()
	add_child(capa)
	_ui_almacen = Label.new()
	_ui_almacen.position = Vector2(24, 20)
	_ui_almacen.add_theme_font_size_override("font_size", 18)
	_ui_almacen.add_theme_color_override("font_color", Color(0.86, 0.78, 0.68, 0.7))
	capa.add_child(_ui_almacen)
	for i in 4:
		var borde := ColorRect.new()
		borde.color = Color(0.75, 0.85, 0.95, 0.0)
		borde.mouse_filter = Control.MOUSE_FILTER_IGNORE
		match i:
			0:
				borde.set_anchors_preset(Control.PRESET_TOP_WIDE)
				borde.offset_bottom = 28
			1:
				borde.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
				borde.offset_top = -28
			2:
				borde.set_anchors_preset(Control.PRESET_LEFT_WIDE)
				borde.offset_right = 22
			3:
				borde.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
				borde.offset_left = -22
		capa.add_child(borde)
		_capas_hielo.append(borde)


func _process(delta: float) -> void:
	var p: Partida = Juego.partida
	if p == null:
		return
	_reloj += delta
	if p.resultado == Partida.Resultado.EN_CURSO and _reloj >= SEGUNDOS_POR_TIEMPO:
		_reloj = 0.0
		p.transcurrir(1)
	_actualizar_zonas()
	_actualizar_larvas()
	_actualizar_estacion()
	_ui_almacen.text = "Almacén  %d / 5" % p.comida_en_almacen
	if p.resultado != Partida.Resultado.EN_CURSO:
		_mostrar_final()


func _actualizar_zonas() -> void:
	var p: Partida = Juego.partida
	if p.arrastrandose and _hormiga.tiene_comida_vista():
		_hormiga.soltar_vista()
		_sfx.tocar("soltar")
	if _almacen_area.overlaps_body(_hormiga) and p.lleva_comida:
		if p.depositar(Partida.Destino.ALMACEN):
			var pieza := _hormiga.comida_vista()
			if pieza is ComidaPieza:
				(pieza as ComidaPieza).depositada = true
				pieza.visible = false
			_hormiga.soltar_vista()
			_sfx.tocar("depositar")
			_mostrar_comida_en_almacen(p.comida_en_almacen)
	if _reina_area.overlaps_body(_hormiga) and p.lleva_comida:
		p.depositar(Partida.Destino.CAMARA_REINA)
	if _descanso_area.overlaps_body(_hormiga):
		if not _en_descanso:
			_en_descanso = true
			p.descansar()
			_sfx.tocar("descanso")
	else:
		_en_descanso = false


func _mostrar_comida_en_almacen(n: int) -> void:
	var pila := _ovalo(Vector2(820 + n * 22, 500 - n * 3), Vector2(18, 12), Color(0.62, 0.42, 0.16))
	add_child(pila)


func _on_cerca_comida(pieza: Node2D) -> void:
	var p: Partida = Juego.partida
	if pieza is ComidaPieza and not (pieza as ComidaPieza).tomada and not (pieza as ComidaPieza).depositada:
		if p.cargar():
			(pieza as ComidaPieza).tomada = true
			_hormiga.tomar(pieza)
			_sfx.tocar("cargar")


func _actualizar_larvas() -> void:
	var n: int = Juego.partida.comida_en_almacen
	for i in _larvas.size():
		var l: Node2D = _larvas[i]
		var viva := n > i
		l.modulate = Color(1, 1, 1, 1) if viva else Color(0.5, 0.45, 0.4, 0.7)
		l.position.y += sin(Time.get_ticks_msec() * (0.01 + n * 0.003) + i) * (0.08 if viva else 0.01)


func _actualizar_estacion() -> void:
	var e: Partida.Estacion = Juego.partida.estacion
	var tint: Color
	var hielo := 0.0
	match e:
		Partida.Estacion.TARDE_HUMEDA:
			tint = Color(1.0, 0.92, 0.82)
			_sfx.viento(false)
			_viento_nieve.emitting = false
		Partida.Estacion.GRIS:
			tint = Color(0.78, 0.8, 0.84)
			_sfx.viento(true)
			_viento_nieve.emitting = true
			hielo = 0.08
		Partida.Estacion.PRIMER_HIELO:
			tint = Color(0.72, 0.8, 0.9)
			_sfx.viento(true)
			_viento_nieve.emitting = true
			hielo = 0.2
		Partida.Estacion.BLANCO:
			tint = Color(0.92, 0.95, 0.98)
			_sfx.viento(true)
			hielo = 0.45
	_modulate.color = _modulate.color.lerp(tint, 0.04)
	for c in _capas_hielo:
		c.color.a = lerp(c.color.a, hielo, 0.04)
	for i in _bichos.size():
		_bichos[i].visible = e == Partida.Estacion.TARDE_HUMEDA or (e == Partida.Estacion.GRIS and i < 2)


func _mostrar_final() -> void:
	if _final_mostrado:
		return
	_final_mostrado = true
	var capa := CanvasLayer.new()
	add_child(capa)
	var fondo := ColorRect.new()
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.color = Color(0.95, 0.97, 1.0, 0.0)
	capa.add_child(fondo)
	var texto := Label.new()
	texto.set_anchors_preset(Control.PRESET_CENTER)
	texto.offset_left = -280
	texto.offset_right = 280
	texto.offset_top = -80
	texto.offset_bottom = 80
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.add_theme_font_size_override("font_size", 28)
	texto.add_theme_color_override("font_color", Color(0.86, 0.78, 0.68))
	if Juego.partida.resultado == Partida.Resultado.VICTORIA:
		fondo.color = Color(0.12, 0.07, 0.05, 0.72)
		texto.text = "El Almacén está lleno.\nLas Larvas se agitan.\nEl Hormiguero sigue fragmentado.\nLa Reina no vuelve."
	else:
		fondo.color = Color(0.9, 0.93, 0.96, 0.82)
		texto.add_theme_color_override("font_color", Color(0.2, 0.24, 0.28))
		texto.text = "El Invierno llegó.\nLas Larvas no se mueven.\nAfuera quedó Comida que no alcanzó."
	capa.add_child(texto)
	var volver := Button.new()
	volver.text = "Volver"
	volver.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	volver.offset_left = -60
	volver.offset_right = 60
	volver.offset_top = -80
	volver.offset_bottom = -44
	volver.pressed.connect(Juego.ir_menu)
	capa.add_child(volver)


func _plataforma(rect: Rect2, color: Color) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = rect.position
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	col.position = rect.size * 0.5
	body.add_child(col)
	var vis := ColorRect.new()
	vis.size = rect.size
	vis.color = color
	body.add_child(vis)
	return body


func _zona(rect: Rect2, nombre: String) -> Area2D:
	var a := Area2D.new()
	a.name = nombre
	a.position = rect.position
	a.collision_layer = 8
	a.collision_mask = 2
	a.monitoring = true
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	col.position = rect.size * 0.5
	a.add_child(col)
	add_child(a)
	return a


func _cueva(centro: Vector2, tam: Vector2, color: Color, titulo: String) -> void:
	var p := Polygon2D.new()
	p.color = color
	p.polygon = PackedVector2Array([
		centro + Vector2(-tam.x * 0.5, tam.y * 0.4),
		centro + Vector2(-tam.x * 0.35, -tam.y * 0.5),
		centro + Vector2(tam.x * 0.4, -tam.y * 0.45),
		centro + Vector2(tam.x * 0.5, tam.y * 0.45),
	])
	add_child(p)
	var lab := Label.new()
	lab.text = titulo
	lab.position = centro + Vector2(-70, -tam.y * 0.55)
	lab.add_theme_font_size_override("font_size", 14)
	lab.add_theme_color_override("font_color", Color(0.7, 0.58, 0.45, 0.55))
	add_child(lab)


func _larva(pos: Vector2) -> Node2D:
	var n := _ovalo(pos, Vector2(18, 10), Color(0.78, 0.58, 0.18))
	add_child(n)
	return n


func _hoja(pos: Vector2, rot: float) -> void:
	var h := Polygon2D.new()
	h.color = Color(0.22, 0.38, 0.16)
	h.position = pos
	h.rotation = rot
	h.polygon = PackedVector2Array([
		Vector2(-80, 10), Vector2(-20, -30), Vector2(90, -10), Vector2(70, 24), Vector2(-40, 28)
	])
	add_child(h)


func _rama(pos: Vector2) -> void:
	add_child(_plataforma(Rect2(pos.x, pos.y, 180, 16), Color(0.28, 0.18, 0.1)))


func _ovalo(pos: Vector2, tam: Vector2, color: Color) -> Polygon2D:
	var p := Polygon2D.new()
	p.color = color
	p.position = pos
	var pts := PackedVector2Array()
	for i in 10:
		var a := TAU * i / 10.0
		pts.append(Vector2(cos(a) * tam.x * 0.5, sin(a) * tam.y * 0.5))
	p.polygon = pts
	return p


func _pixel() -> Texture2D:
	var img := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	return ImageTexture.create_from_image(img)
