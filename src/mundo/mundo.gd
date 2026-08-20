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
var _ui_almacen: Label
var _capas_hielo: Array[ColorRect] = []
var _tiles: TileMapLayer


func _ready() -> void:
	_sfx = Sfx.new()
	add_child(_sfx)
	_mapa = HormigueroMapa.new()
	_mapa.generar()
	_pintar_cielo()
	_construir_tiles()
	_etiquetar_camaras()
	_construir_zonas()
	_construir_hormiga()
	_construir_obreras()
	_construir_comidas()
	_construir_larvas()
	_construir_clima()
	_construir_ui()


func _pintar_cielo() -> void:
	var cielo := ColorRect.new()
	cielo.color = Paleta.CIELO
	cielo.position = Vector2(-400, -600)
	cielo.size = Vector2(HormigueroMapa.ANCHO * HormigueroMapa.TILE + 800, 900)
	cielo.z_index = -8
	add_child(cielo)


func _construir_tiles() -> void:
	_tiles = TileMapLayer.new()
	_tiles.tile_set = _hacer_tileset()
	_tiles.collision_enabled = true
	add_child(_tiles)
	for y in HormigueroMapa.ALTO:
		for x in HormigueroMapa.ANCHO:
			var c := _mapa.get_celda(x, y)
			if c == HormigueroMapa.CIELO:
				continue
			var atlas := Vector2i(0, 0)
			if c == HormigueroMapa.TUNEL:
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
	var img := Image.create(HormigueroMapa.TILE * 3, HormigueroMapa.TILE, false, Image.FORMAT_RGBA8)
	_rellenar_tierra(img, Rect2i(0, 0, HormigueroMapa.TILE, HormigueroMapa.TILE), Paleta.TIERRA, Paleta.TIERRA_MANCHA)
	_rellenar_tierra(img, Rect2i(HormigueroMapa.TILE, 0, HormigueroMapa.TILE, HormigueroMapa.TILE), Paleta.TUNEL, Paleta.TUNEL_OSCURO)
	_rellenar_tierra(img, Rect2i(HormigueroMapa.TILE * 2, 0, HormigueroMapa.TILE, HormigueroMapa.TILE), Paleta.TIERRA_OSCURA, Paleta.TIERRA_MANCHA)
	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(img)
	source.texture_region_size = Vector2i(HormigueroMapa.TILE, HormigueroMapa.TILE)
	source.create_tile(Vector2i(0, 0))
	source.create_tile(Vector2i(1, 0))
	source.create_tile(Vector2i(2, 0))
	ts.add_source(source)
	var half := HormigueroMapa.TILE * 0.5
	var box := PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)
	])
	for coords in [Vector2i(0, 0), Vector2i(2, 0)]:
		var td: TileData = source.get_tile_data(coords, 0)
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, 0, box)
	return ts


func _rellenar_tierra(img: Image, rect: Rect2i, base: Color, mancha: Color) -> void:
	for y in rect.size.y:
		for x in rect.size.x:
			var c := base
			if (x * 13 + y * 7 + rect.position.x) % 11 == 0:
				c = mancha
			if (x + y * 3) % 17 == 0:
				c = c.darkened(0.08)
			img.set_pixel(rect.position.x + x, rect.position.y + y, c)


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
	lab.add_theme_color_override("font_color", Color(0.35, 0.2, 0.1, 0.55))
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
	var cam := Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 5.5
	cam.zoom = Vector2(2.45, 2.45)
	cam.limit_left = 0
	cam.limit_top = -80
	cam.limit_right = HormigueroMapa.ANCHO * HormigueroMapa.TILE
	cam.limit_bottom = HormigueroMapa.ALTO * HormigueroMapa.TILE
	_hormiga.add_child(cam)
	cam.make_current()


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
	_modulate.color = Color(1.0, 0.95, 0.88)
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
	_ui_almacen = Label.new()
	_ui_almacen.position = Vector2(24, 20)
	_ui_almacen.add_theme_font_size_override("font_size", 18)
	_ui_almacen.add_theme_color_override("font_color", Paleta.HORMIGA_OSCURA)
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
	if p == null or _hormiga == null:
		return
	_hormiga.gasta_energia = _mapa.esta_afuera(_hormiga.global_position)
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
			tint = Color(1.0, 0.95, 0.88)
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
	var capa := CanvasLayer.new()
	add_child(capa)
	var fondo := ColorRect.new()
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	capa.add_child(fondo)
	var texto := Label.new()
	texto.set_anchors_preset(Control.PRESET_CENTER)
	texto.offset_left = -280
	texto.offset_right = 280
	texto.offset_top = -80
	texto.offset_bottom = 80
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.add_theme_font_size_override("font_size", 28)
	if Juego.partida.resultado == Partida.Resultado.VICTORIA:
		fondo.color = Color(0.22, 0.12, 0.07, 0.72)
		texto.add_theme_color_override("font_color", Paleta.HUESO)
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
