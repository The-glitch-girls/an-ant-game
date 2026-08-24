class_name FondoMadriguera
extends Node2D

const RES := 2
const PASES_BLUR := 2


func armar(mapa: HormigueroMapa) -> void:
	z_index = -5
	_pintar_suelo(mapa)
	_esparcir_detalles(mapa)
	_pintar_pasto(mapa)


func _pintar_suelo(mapa: HormigueroMapa) -> void:
	var w: int = HormigueroMapa.ANCHO * RES
	var h: int = HormigueroMapa.ALTO * RES
	var hueco := _raster(mapa, w, h, func(c: int, _x: int, _y: int) -> bool:
		return c == HormigueroMapa.TUNEL or c == HormigueroMapa.CIELO
	)
	var aire := _raster(mapa, w, h, func(c: int, _x: int, _y: int) -> bool:
		return c == HormigueroMapa.CIELO
	)
	var tapado := _raster(mapa, w, h, func(c: int, _x: int, _y: int) -> bool:
		return c == HormigueroMapa.DERRUMBADA
	)
	var afuera := _raster(mapa, w, h, func(c: int, _x: int, y: int) -> bool:
		return c == HormigueroMapa.TUNEL and y / RES <= 11
	)
	for _i in PASES_BLUR:
		hueco = _blur(hueco, w, h)
		aire = _blur(aire, w, h)
		tapado = _blur(tapado, w, h)
		afuera = _blur(afuera, w, h)

	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var i: int = y * w + x
			img.set_pixel(x, y, Color(hueco[i], aire[i], tapado[i], afuera[i]))

	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.scale = Vector2(HormigueroMapa.TILE / float(RES), HormigueroMapa.TILE / float(RES))
	var mat := ShaderMaterial.new()
	mat.shader = load("res://src/mundo/fondo_madriguera.gdshader")
	mat.set_shader_parameter("tierra", Paleta.TIERRA)
	mat.set_shader_parameter("labio", Paleta.LABIO)
	mat.set_shader_parameter("arcilla", Paleta.TUNEL)
	mat.set_shader_parameter("arcilla_sombra", Paleta.TUNEL_OSCURO)
	mat.set_shader_parameter("cielo", Paleta.CIELO)
	mat.set_shader_parameter("derrumbe", Paleta.TIERRA_MANCHA)
	mat.set_shader_parameter("pasto", Paleta.PASTO)
	mat.set_shader_parameter("mapa_celdas", Vector2(HormigueroMapa.ANCHO, HormigueroMapa.ALTO))
	sprite.material = mat
	add_child(sprite)


func _esparcir_detalles(mapa: HormigueroMapa) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	for y in HormigueroMapa.ALTO:
		for x in HormigueroMapa.ANCHO:
			var c: int = mapa.get_celda(x, y)
			if c == HormigueroMapa.TIERRA and _toca_tunel(mapa, x, y) and rng.randf() < 0.018:
				_guijarro(mapa.mundo(x, y) + Vector2(rng.randf_range(-6, 6), rng.randf_range(-6, 6)), rng)


func _toca_tunel(mapa: HormigueroMapa, x: int, y: int) -> bool:
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			if mapa.get_celda(x + ox, y + oy) == HormigueroMapa.TUNEL:
				return true
	return false


func _guijarro(pos: Vector2, rng: RandomNumberGenerator) -> void:
	var p := Polygon2D.new()
	p.position = pos
	p.color = Paleta.GUIJARRO.lerp(Paleta.TIERRA, rng.randf() * 0.5)
	p.modulate.a = 0.7
	p.z_index = 1
	var rx := rng.randf_range(2.4, 4.2)
	var ry := rng.randf_range(1.8, 3.0)
	var pts := PackedVector2Array()
	for i in 7:
		var a := TAU * i / 7.0 + rng.randf() * 0.3
		pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	p.polygon = pts
	add_child(p)


func _pintar_pasto(mapa: HormigueroMapa) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	for x in range(8, 64):
		if mapa.get_celda(x, 10) != HormigueroMapa.TUNEL:
			continue
		if rng.randf() > 0.28:
			continue
		var mata := Polygon2D.new()
		mata.position = mapa.mundo(x, 9) + Vector2(rng.randf_range(-8, 8), rng.randf_range(-6, 2))
		mata.color = Paleta.PASTO.lerp(Color(0.30, 0.48, 0.20), rng.randf() * 0.4)
		mata.z_index = 1
		var w := rng.randf_range(5.0, 9.0)
		var h := rng.randf_range(4.0, 7.5)
		mata.polygon = PackedVector2Array([
			Vector2(-w * 0.5, 0),
			Vector2(-w * 0.15, -h),
			Vector2(0, -h * 0.55),
			Vector2(w * 0.2, -h * 0.9),
			Vector2(w * 0.5, 0),
		])
		add_child(mata)


func _raster(mapa: HormigueroMapa, w: int, h: int, pred: Callable) -> PackedFloat32Array:
	var g := PackedFloat32Array()
	g.resize(w * h)
	for y in h:
		for x in w:
			var c: int = mapa.get_celda(int(x / RES), int(y / RES))
			g[y * w + x] = 1.0 if pred.call(c, x, y) else 0.0
	return g


func _blur(src: PackedFloat32Array, w: int, h: int) -> PackedFloat32Array:
	var dst := PackedFloat32Array()
	dst.resize(w * h)
	for y in h:
		for x in w:
			var acc := 0.0
			for oy in range(-1, 2):
				for ox in range(-1, 2):
					var xx: int = clampi(x + ox, 0, w - 1)
					var yy: int = clampi(y + oy, 0, h - 1)
					acc += src[yy * w + xx]
			dst[y * w + x] = acc / 9.0
	return dst
