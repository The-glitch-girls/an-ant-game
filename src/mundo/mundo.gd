extends Node2D

const SEGUNDOS_POR_TIEMPO := 1.2

var _mapa: HormigueroMapa
var _hormiga: HormigaVista
var _sfx: Sfx
var _modulate: CanvasModulate
var _viento_nieve: GPUParticles2D
var _larvas: Array[Node2D] = []
var _almacen_area: Area2D
var _reina_area: Area2D
var _descanso_area: Area2D
var _en_descanso: bool = false
var _reloj: float = 0.0
var _final_mostrado: bool = false
var _mini_mapa: MiniMapa
var _capas_hielo: Array[ColorRect] = []
var _tiles: TileMapLayer
var _hud: Hud
var _camara: Camera2D
var _intro: bool = true
var energia_maxima := 100.0
var energia := 100.0

func _ready() -> void:
	_sfx = Sfx.new()
	add_child(_sfx)
	_mapa = HormigueroMapa.new()
	_mapa.generar()
	_pintar_cielo()
	_construir_fondo()
	_construir_tiles()
	_polvo_derrumbada()
	_etiquetar_camaras()
	_construir_zonas()
	_construir_hormiga()
	_construir_obreras()
	_construir_comidas()
	_construir_larvas()
	_construir_clima()
	_construir_ui()
	_bajar_al_nido()


func _pintar_cielo() -> void:
	var cielo := ColorRect.new()
	cielo.color = Paleta.CIELO
	cielo.position = Vector2(-400, -900)
	cielo.size = Vector2(HormigueroMapa.ANCHO * HormigueroMapa.TILE + 800, 1200)
	cielo.z_index = -8
	add_child(cielo)


func _construir_fondo() -> void:
	var fondo := FondoMadriguera.new()
	fondo.armar(_mapa)
	add_child(fondo)


func _construir_tiles() -> void:
	_tiles = TileMapLayer.new()
	_tiles.tile_set = _hacer_tileset()
	_tiles.collision_enabled = true
	_tiles.self_modulate = Color(1, 1, 1, 0)
	add_child(_tiles)
	for y in HormigueroMapa.ALTO:
		for x in HormigueroMapa.ANCHO:
			var c := _mapa.get_celda(x, y)
			var atlas := Vector2i(0, 0)
			if c == HormigueroMapa.CIELO:
				atlas = Vector2i(3, 0)
			elif c == HormigueroMapa.TUNEL:
				atlas = Vector2i(1, 0)
			elif c == HormigueroMapa.DERRUMBADA:
				atlas = Vector2i(2, 0)
			_tiles.set_cell(Vector2i(x, y), 0, atlas)


func _hacer_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(HormigueroMapa.TILE, HormigueroMapa.TILE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)
	var img := Image.create(HormigueroMapa.TILE * 4, HormigueroMapa.TILE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(img)
	source.texture_region_size = Vector2i(HormigueroMapa.TILE, HormigueroMapa.TILE)
	source.create_tile(Vector2i(0, 0))
	source.create_tile(Vector2i(1, 0))
	source.create_tile(Vector2i(2, 0))
	source.create_tile(Vector2i(3, 0))
	ts.add_source(source)
	var half := HormigueroMapa.TILE * 0.5
	var box := PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)
	])
	for coords in [Vector2i(0, 0), Vector2i(2, 0), Vector2i(3, 0)]:
		var td: TileData = source.get_tile_data(coords, 0)
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, 0, box)
	return ts


func _polvo_derrumbada() -> void:
	var polvo := GPUParticles2D.new()
	polvo.position = _mapa.derrumbada.get_center()
	polvo.amount = 16
	polvo.lifetime = 2.2
	polvo.texture = _pixel()
	var mat := ParticleProcessMaterial.new()
	mat.gravity = Vector3(0, 18, 0)
	mat.scale_min = 1.2
	mat.scale_max = 2.8
	mat.color = Paleta.TIERRA_MANCHA
	polvo.process_material = mat
	add_child(polvo)
	var zona := Area2D.new()
	zona.position = polvo.position
	zona.collision_layer = 0
	zona.collision_mask = 2
	zona.monitoring = true
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = _mapa.derrumbada.size
	col.shape = shape
	zona.add_child(col)
	zona.body_entered.connect(func(_b: Node) -> void:
		_sfx.tocar("soltar")
	)
	add_child(zona)


func _etiquetar_camaras() -> void:
	_label(_mapa.reina + Vector2(-48, -40), "Cámara de la reina")
	_label(_mapa.larvas + Vector2(-28, -36), "Larvas")
	_label(_mapa.almacen + Vector2(-32, -36), "Almacén")
	_label(_mapa.descanso + Vector2(-34, -36), "Descanso")


func _label(pos: Vector2, texto: String) -> void:
	var lab := Label.new()
	lab.text = texto
	lab.position = pos
	lab.add_theme_font_size_override("font_size", 13)
	lab.add_theme_color_override("font_color", Color(0.42, 0.26, 0.14, 0.62))
	add_child(lab)


func _construir_zonas() -> void:
	var t := HormigueroMapa.TILE * 5.0
	_reina_area = _zona(_mapa.reina, t, "reina")
	_almacen_area = _zona(_mapa.almacen, t, "almacen")
	_descanso_area = _zona(_mapa.descanso, t, "descanso")
	_zona(_mapa.larvas, t, "larvas")


func _zona(centro: Vector2, lado: float, nombre: String) -> Area2D:
	var a := Area2D.new()
	a.name = nombre
	a.position = centro
	a.collision_layer = 8
	a.collision_mask = 2
	a.monitoring = true
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(lado, lado)
	col.shape = shape
	a.add_child(col)
	add_child(a)
	return a


func _construir_hormiga() -> void:
	_hormiga = HormigaVista.new()
	_hormiga.position = _mapa.spawn
	add_child(_hormiga)
	_hormiga.cerca_de_comida.connect(_on_cerca_comida)
	_hormiga.intento_mover.connect(func() -> void:
		_sfx.tocar("paso")
	)
	_camara = Camera2D.new()
	_camara.position_smoothing_enabled = false
	_camara.zoom = Vector2(1.15, 1.15)
	_camara.limit_left = 0
	_camara.limit_top = -320
	_camara.limit_right = HormigueroMapa.ANCHO * HormigueroMapa.TILE
	_camara.limit_bottom = HormigueroMapa.ALTO * HormigueroMapa.TILE
	var mira := Vector2(HormigueroMapa.ANCHO * HormigueroMapa.TILE * 0.5, _mapa.superficie_y - 110)
	_camara.offset = mira - _hormiga.position
	_hormiga.add_child(_camara)
	_camara.make_current()
	_hormiga.bloqueada = true


func _construir_obreras() -> void:
	for ruta in _mapa.rutas_obreras:
		var o := Obrera.new()
		o.ruta = ruta
		if ruta.size() > 0:
			o.position = ruta[0]
		add_child(o)


func _construir_comidas() -> void:
	for p in _mapa.comidas:
		var c := ComidaPieza.new()
		c.position = p
		add_child(c)


func _construir_larvas() -> void:
	for i in 3:
		_larvas.append(_larva(_mapa.larvas + Vector2(-18 + i * 18, 8)))


func _construir_clima() -> void:
	_modulate = CanvasModulate.new()
	_modulate.color = Color(1.0, 0.97, 0.88)
	add_child(_modulate)
	_viento_nieve = GPUParticles2D.new()
	_viento_nieve.amount = 40
	_viento_nieve.lifetime = 3.5
	_viento_nieve.position = Vector2(HormigueroMapa.ANCHO * HormigueroMapa.TILE * 0.5, 20)
	_viento_nieve.texture = _pixel()
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(900, 20, 1)
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
	_hud = Hud.new()
	_hud.visible = false
	capa.add_child(_hud)

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
	_mini_mapa = MiniMapa.new()
	_mini_mapa.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_mini_mapa.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_mini_mapa.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_mini_mapa.offset_right = -22
	_mini_mapa.offset_bottom = -22
	_mini_mapa.offset_left = -22 - HormigueroMapa.ANCHO * MiniMapa.PX - MiniMapa.MARGEN * 2
	_mini_mapa.offset_top = -22 - HormigueroMapa.ALTO * MiniMapa.PX - MiniMapa.MARGEN * 2
	_mini_mapa.armar(_mapa)
	_mini_mapa.marcar(_hormiga.position)
	_mini_mapa.visible = false
	capa.add_child(_mini_mapa)


func _bajar_al_nido() -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(_camara, "offset", Vector2.ZERO, 3.4)
	tw.tween_property(_camara, "zoom", Vector2(1.75, 1.75), 3.4)
	tw.chain().tween_callback(_terminar_intro)


func _terminar_intro() -> void:
	_intro = false
	_hormiga.bloqueada = false
	_camara.position_smoothing_enabled = true
	_camara.position_smoothing_speed = 5.5
	if _hud:
		_hud.visible = true
	if _mini_mapa:
		_mini_mapa.visible = true


func _process(delta: float) -> void:
	var p: Partida = Juego.partida
	if p == null or _hormiga == null:
		return
	_hormiga.gasta_energia = _mapa.esta_afuera(_hormiga.global_position)
	p.actualizar_carga(delta)
	energia = p.energia
	if _hud:
		_hud.pintar(p.energia, p.ENERGIA_INICIAL, p.comida_en_almacen)
	if _intro:
		return

	_reloj += delta
	if p.resultado == Partida.Resultado.EN_CURSO and _reloj >= SEGUNDOS_POR_TIEMPO:
		_reloj = 0.0
		p.transcurrir(1)
	_actualizar_zonas(delta)
	_actualizar_larvas()
	_actualizar_estacion()
	
	if _mini_mapa:
		_mini_mapa.marcar(_hormiga.global_position)
	if p.resultado != Partida.Resultado.EN_CURSO:
		_mostrar_final()


func _actualizar_zonas(delta: float) -> void:
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
		p.actualizar_descanso(delta)
	else:
		_en_descanso = false


func _mostrar_comida_en_almacen(n: int) -> void:
	add_child(_ovalo(_mapa.almacen + Vector2(-20 + n * 12, 14), Vector2(16, 10), Paleta.TUNEL_OSCURO))


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
		l.modulate = Color.WHITE if viva else Color(0.6, 0.5, 0.4, 0.75)
		var base: float = _mapa.larvas.y + 8.0
		l.position.y = base + sin(Time.get_ticks_msec() * (0.008 + n * 0.002) + i) * (2.2 if viva else 0.3)


func _actualizar_estacion() -> void:
	var e: Partida.Estacion = Juego.partida.estacion
	var tint: Color
	var hielo := 0.0
	match e:
		Partida.Estacion.TARDE_HUMEDA:
			tint = Color(1.0, 0.97, 0.88)
			_sfx.viento(false)
			_viento_nieve.emitting = false
		Partida.Estacion.GRIS:
			tint = Color(0.82, 0.84, 0.88)
			_sfx.viento(true)
			_viento_nieve.emitting = true
			hielo = 0.08
		Partida.Estacion.PRIMER_HIELO:
			tint = Color(0.74, 0.82, 0.9)
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


func _mostrar_final() -> void:
	if _final_mostrado:
		return
	_final_mostrado = true
	if _mini_mapa:
		_mini_mapa.visible = false
	if _hud:
		_hud.visible = false
	var capa := CanvasLayer.new()
	add_child(capa)
	var velo := ColorRect.new()
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_STOP
	velo.color = Color(0.20, 0.12, 0.08, 0.42)
	capa.add_child(velo)
	var caja := UiCozzy.tarjeta()
	caja.set_anchors_preset(Control.PRESET_CENTER)
	caja.offset_left = -250
	caja.offset_right = 250
	caja.offset_top = -130
	caja.offset_bottom = 150
	capa.add_child(caja)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	caja.add_child(col)
	var victoria := Juego.partida.resultado == Partida.Resultado.VICTORIA
	col.add_child(UiCozzy.pastilla("Victoria" if victoria else "Invierno"))
	var texto := Label.new()
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiCozzy.estilar_texto(texto, 22)
	if victoria:
		texto.text = "El Almacén está lleno.\nLas Larvas se agitan.\nEl Hormiguero sigue fragmentado.\nLa Reina no vuelve."
	else:
		texto.text = "El Invierno llegó.\nLas Larvas no se mueven.\nAfuera quedó Comida que no alcanzó."
	col.add_child(texto)
	var volver := Button.new()
	volver.text = "Volver"
	UiCozzy.estilar_boton(volver)
	volver.pressed.connect(Juego.ir_menu)
	col.add_child(volver)


func _larva(pos: Vector2) -> Node2D:
	var n := _ovalo(pos, Vector2(16, 10), Paleta.AMBAR)
	add_child(n)
	return n


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
	
