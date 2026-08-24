class_name FondoCielo
extends Node2D

const BANDAS := [
	Color(0.58, 0.68, 0.82),
	Color(0.70, 0.74, 0.84),
	Color(0.82, 0.78, 0.80),
	Color(0.92, 0.80, 0.70),
	Color(0.96, 0.84, 0.64),
	Color(0.97, 0.88, 0.68),
]
const NUBE_LUZ := Color(1.0, 0.96, 0.90)
const NUBE := Color(0.97, 0.90, 0.80)
const NUBE_SOMBRA := Color(0.88, 0.74, 0.62)
const SOL := Color(0.99, 0.86, 0.52)
const SOL_ARO := Color(0.98, 0.78, 0.48)


func armar() -> void:
	z_index = -8
	var px: int = Paleta.PX_ARTE
	var w: int = (HormigueroMapa.ANCHO * HormigueroMapa.TILE + 800) / px
	var h: int = 1200 / px
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	_pintar_bandas(img, w, h)
	_pintar_sol(img, w, h)
	_pintar_nubes(img, w, h)
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(px, px)
	sprite.position = Vector2(-400, -900)
	add_child(sprite)


func _pintar_bandas(img: Image, w: int, h: int) -> void:
	var n: int = BANDAS.size()
	for y in h:
		for x in w:
			var onda: float = (_hash(Vector2(x / 10, y / 6)) - 0.5) * 0.045
			var t: float = clampf(float(y) / float(maxi(h - 1, 1)) + onda, 0.0, 0.999)
			var i: float = t * float(n - 1)
			var a: int = clampi(int(i), 0, n - 2)
			var local: float = i - float(a)
			var col: Color = BANDAS[a] if local < 0.62 else BANDAS[a + 1]
			img.set_pixel(x, y, col)


func _pintar_sol(img: Image, w: int, h: int) -> void:
	var cx := int(w * 0.76)
	var cy := int(h * 0.18)
	for y in range(cy - 18, cy + 19):
		for x in range(cx - 18, cx + 19):
			if not _dentro(img, x, y):
				continue
			var d := Vector2(x - cx, y - cy).length()
			if d <= 9.0:
				img.set_pixel(x, y, SOL if d < 7.2 else SOL_ARO)
			elif d <= 13.0 and _hash(Vector2(x, y)) > 0.55:
				img.set_pixel(x, y, SOL_ARO.lerp(img.get_pixel(x, y), 0.45))


func _pintar_nubes(img: Image, w: int, h: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var sitios := [
		Vector2(w * 0.16, h * 0.20),
		Vector2(w * 0.38, h * 0.13),
		Vector2(w * 0.55, h * 0.26),
		Vector2(w * 0.72, h * 0.16),
		Vector2(w * 0.90, h * 0.22),
	]
	for centro in sitios:
		_nube(img, centro, rng)


func _nube(img: Image, centro: Vector2, rng: RandomNumberGenerator) -> void:
	var blobs: Array[Vector3] = []
	for _i in 7:
		blobs.append(Vector3(
			centro.x + rng.randf_range(-22, 22),
			centro.y + rng.randf_range(-8, 8),
			rng.randf_range(14.0, 24.0)
		))
	var min_x := 9999
	var max_x := 0
	var min_y := 9999
	var max_y := 0
	for b in blobs:
		min_x = mini(min_x, int(b.x - b.z - 1))
		max_x = maxi(max_x, int(b.x + b.z + 1))
		min_y = mini(min_y, int(b.y - b.z * 0.7 - 1))
		max_y = maxi(max_y, int(b.y + b.z * 0.7 + 1))
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if not _dentro(img, x, y):
				continue
			var acc := 0.0
			for b in blobs:
				var d := Vector2((x - b.x) / b.z, (y - b.y) / (b.z * 0.58))
				acc += 1.0 - clampf(d.length(), 0.0, 1.0)
			if acc < 1.05:
				continue
			var col := NUBE
			if y < int(centro.y - 3.0) or acc > 1.85:
				col = NUBE_LUZ
			elif y > int(centro.y + 3.0):
				col = NUBE_SOMBRA
			img.set_pixel(x, y, col)


func _hash(p: Vector2) -> float:
	return fposmod(sin(p.dot(Vector2(127.1, 311.7))) * 43758.5453, 1.0)


func _dentro(img: Image, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height()
