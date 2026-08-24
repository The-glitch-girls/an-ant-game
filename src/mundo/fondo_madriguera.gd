class_name FondoMadriguera
extends Node2D

const BAJA := 2
const PASES_BLUR := 3


func armar(mapa: HormigueroMapa) -> void:
	z_index = -5
	_pintar_suelo(mapa)
	_esparcir_detalles(mapa)
	_pintar_pasto(mapa)


func _pintar_suelo(mapa: HormigueroMapa) -> void:
	var res: int = HormigueroMapa.TILE / Paleta.PX_ARTE
	var w: int = HormigueroMapa.ANCHO * res
	var h: int = HormigueroMapa.ALTO * res
	var wb: int = HormigueroMapa.ANCHO * BAJA
	var hb: int = HormigueroMapa.ALTO * BAJA
	var hueco := _raster(mapa, wb, hb, BAJA, func(c: int, _x: int, _y: int) -> bool:
		return c == HormigueroMapa.TUNEL or c == HormigueroMapa.CIELO
	)
	var aire := _raster(mapa, wb, hb, BAJA, func(c: int, _x: int, _y: int) -> bool:
		return c == HormigueroMapa.CIELO
	)
	var tapado := _raster(mapa, wb, hb, BAJA, func(c: int, _x: int, _y: int) -> bool:
		return c == HormigueroMapa.DERRUMBADA
	)
	var afuera := _raster(mapa, wb, hb, BAJA, func(c: int, _x: int, y: int) -> bool:
		return c == HormigueroMapa.TUNEL and y / BAJA <= 11
	)
	for _i in PASES_BLUR:
		hueco = _blur(hueco, wb, hb)
		aire = _blur(aire, wb, hb)
		tapado = _blur(tapado, wb, hb)
		afuera = _blur(afuera, wb, hb)

	var ochre := Color(0.78, 0.56, 0.34)
	var terracota := Paleta.TIERRA
	var terracota_sombra := Paleta.TIERRA_OSCURA
	var piso_luz := Color(0.90, 0.72, 0.50)
	var oliva := Paleta.PASTO
	var oliva_luz := Color(0.58, 0.66, 0.32)
	var oliva_sombra := Color(0.36, 0.46, 0.20)
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var fx: float = (float(x) + 0.5) / float(w) * float(wb)
			var fy: float = (float(y) + 0.5) / float(h) * float(hb)
			var v_aire := _sample(aire, wb, hb, fx, fy)
			if v_aire > 0.60:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var v_hueco := _sample(hueco, wb, hb, fx, fy)
			var v_tapado := _sample(tapado, wb, hb, fx, fy)
			var v_afuera := _sample(afuera, wb, hb, fx, fy)
			var n := _hash(Vector2(x / 5, y / 5).floor())
			var col: Color
			if v_afuera > 0.40:
				var g := _hash(Vector2(x / 3, y / 2).floor())
				col = oliva_sombra if g < 0.16 else (oliva_luz if g > 0.84 else oliva)
			elif v_tapado > 0.38:
				col = Paleta.TIERRA_MANCHA.lerp(terracota_sombra, 1.0 if n >= 0.5 else 0.0)
			elif v_hueco > 0.40:
				var centro: float = smoothstep(0.42, 0.90, v_hueco)
				col = Paleta.TUNEL_OSCURO.lerp(piso_luz, centro)
				if n > 0.93:
					col = col.lerp(ochre, 0.35)
			elif v_hueco > 0.20:
				col = Paleta.LABIO.lerp(terracota, 0.35)
			else:
				col = terracota
				if n > 0.90:
					col = ochre
				elif n < 0.08:
					col = terracota_sombra
			img.set_pixel(x, y, col)

	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(Paleta.PX_ARTE, Paleta.PX_ARTE)
	add_child(sprite)


func _hash(p: Vector2) -> float:
	return fposmod(sin(p.dot(Vector2(127.1, 311.7))) * 43758.5453, 1.0)


func _esparcir_detalles(mapa: HormigueroMapa) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	for y in HormigueroMapa.ALTO:
		for x in HormigueroMapa.ANCHO:
			var c: int = mapa.get_celda(x, y)
			if c == HormigueroMapa.TIERRA and _toca_tunel(mapa, x, y) and rng.randf() < 0.02:
				_guijarro(mapa.mundo(x, y) + Vector2(rng.randf_range(-6, 6), rng.randf_range(-6, 6)), rng)


func _toca_tunel(mapa: HormigueroMapa, x: int, y: int) -> bool:
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			if mapa.get_celda(x + ox, y + oy) == HormigueroMapa.TUNEL:
				return true
	return false


func _guijarro(pos: Vector2, rng: RandomNumberGenerator) -> void:
	var img := Image.create(5, 4, false, Image.FORMAT_RGBA8)
	var base := Color(0.72, 0.54, 0.38).lerp(Paleta.TIERRA, rng.randf() * 0.3)
	var luz := base.lightened(0.18)
	var sombra := base.darkened(0.16)
	var form := [
		Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1),
		Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
		Vector2i(2, 3),
	]
	for p in form:
		var col := luz if p.y == 0 else (sombra if p.y >= 2 else base)
		img.set_pixel(p.x, p.y, col)
	_sprite_pixel(img, pos, 1)


func _pintar_pasto(mapa: HormigueroMapa) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	for x in range(8, 64):
		if mapa.get_celda(x, 10) != HormigueroMapa.TUNEL:
			continue
		if rng.randf() > 0.34:
			continue
		var pos := mapa.mundo(x, 9) + Vector2(rng.randf_range(-8, 8), rng.randf_range(-3, 2))
		_mata(pos, rng)
		if rng.randf() < 0.28:
			_flor(pos + Vector2(rng.randf_range(-5, 5), -3), rng)


func _flor(pos: Vector2, rng: RandomNumberGenerator) -> void:
	var img := Image.create(3, 3, false, Image.FORMAT_RGBA8)
	var petal := Paleta.TERRACOTA if rng.randf() > 0.5 else Paleta.AMBAR
	img.set_pixel(1, 0, petal.lightened(0.12))
	img.set_pixel(0, 1, petal)
	img.set_pixel(2, 1, petal)
	img.set_pixel(1, 2, petal.darkened(0.08))
	img.set_pixel(1, 1, Paleta.AMBAR)
	_sprite_pixel(img, pos, 2)


func _mata(pos: Vector2, rng: RandomNumberGenerator) -> void:
	var img := Image.create(7, 5, false, Image.FORMAT_RGBA8)
	var base := Paleta.PASTO.lerp(Color(0.40, 0.52, 0.22), rng.randf() * 0.3)
	var luz := base.lerp(Color(0.62, 0.70, 0.34), 0.55)
	var sombra := base.darkened(0.14)
	var form := [
		Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0),
		Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1),
		Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2),
		Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3),
		Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4),
	]
	for p in form:
		var col := luz if p.y == 0 else (sombra if p.y >= 3 else base)
		img.set_pixel(p.x, p.y, col)
	_sprite_pixel(img, pos, 1)


func _sprite_pixel(img: Image, pos: Vector2, z: int) -> void:
	var s := Sprite2D.new()
	s.texture = ImageTexture.create_from_image(img)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2(Paleta.PX_ARTE, Paleta.PX_ARTE)
	s.position = pos
	s.z_index = z
	add_child(s)


func _raster(mapa: HormigueroMapa, w: int, h: int, res: int, pred: Callable) -> PackedFloat32Array:
	var g := PackedFloat32Array()
	g.resize(w * h)
	for y in h:
		for x in w:
			var c: int = mapa.get_celda(int(x / res), int(y / res))
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


func _sample(g: PackedFloat32Array, w: int, h: int, fx: float, fy: float) -> float:
	var x0 := clampi(int(fx), 0, w - 1)
	var y0 := clampi(int(fy), 0, h - 1)
	var x1 := clampi(x0 + 1, 0, w - 1)
	var y1 := clampi(y0 + 1, 0, h - 1)
	var tx := fx - float(x0)
	var ty := fy - float(y0)
	var a: float = lerpf(g[y0 * w + x0], g[y0 * w + x1], tx)
	var b: float = lerpf(g[y1 * w + x0], g[y1 * w + x1], tx)
	return lerpf(a, b, ty)
