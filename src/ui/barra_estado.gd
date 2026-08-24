class_name BarraEstado
extends Control

const CORAZONES := 5
const COMIDAS := 5

var _energia: float = 100.0
var _energia_max: float = 100.0
var _comida: int = 0
var _semillas: _Tira
var _corazones: _Tira
var _herramientas: _HerramientasUI


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	offset_left = 20
	offset_top = 14
	offset_right = 420
	offset_bottom = 150
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 8)
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(col)
	_semillas = _fila(col, "Almacén", false)
	_corazones = _fila(col, "Energía", true)
	_herramientas = _HerramientasUI.new()
	_herramientas.custom_minimum_size = Vector2(380, 40)
	col.add_child(_herramientas)
	_semillas.pintar(0, COMIDAS)
	_corazones.pintar(CORAZONES, CORAZONES)


func pintar(energia_ahora: float, energia_tope: float, comida: int) -> void:
	_energia = energia_ahora
	_energia_max = energia_tope
	_comida = comida
	if _semillas == null:
		return
	var llenos: int = clampi(roundi((_energia / maxf(_energia_max, 1.0)) * CORAZONES), 0, CORAZONES)
	_semillas.pintar(_comida, COMIDAS)
	_corazones.pintar(llenos, CORAZONES)
	if _herramientas != null:
		_herramientas.actualizar()


func _fila(col: VBoxContainer, titulo: String, corazones: bool) -> _Tira:
	var fila := HBoxContainer.new()
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_theme_constant_override("separation", 10)
	col.add_child(fila)
	fila.add_child(UiCozzy.pastilla(titulo))
	var tira := _Tira.new()
	tira.corazones = corazones
	tira.custom_minimum_size = Vector2(170, 36)
	tira.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(tira)
	return tira


class _Tira extends Control:
	var corazones: bool = false
	var _llenos: int = 0
	var _total: int = 5

	func pintar(llenos: int, total: int) -> void:
		_llenos = llenos
		_total = total
		queue_redraw()

	func _draw() -> void:
		var y: float = size.y * 0.5
		for i in _total:
			var p := Vector2(16 + i * 30, y)
			if corazones:
				UiCozzy.dibujar_corazon(self, p, 13.0, i < _llenos, float(i + 2))
			else:
				UiCozzy.dibujar_semilla(self, p, 9.5, i < _llenos, float(i + 4))


class _HerramientasUI extends Control:
	var _pala_texture: Texture2D
	var _rama_texture: Texture2D
	var _pala_sprite: Sprite2D
	var _rama_sprite: Sprite2D

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pala_texture = load("res://assets/herramientas/pala_completa.png")
		_rama_texture = load("res://assets/herramientas/rama_completa.png")
		
		var h_box := HBoxContainer.new()
		h_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h_box.add_theme_constant_override("separation", 20)
		h_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(h_box)
		
		var pala_label := Label.new()
		pala_label.text = "Pala"
		pala_label.add_theme_font_size_override("font_size", 12)
		pala_label.add_theme_color_override("font_color", Color(0.42, 0.26, 0.14))
		h_box.add_child(pala_label)
		
		_pala_sprite = Sprite2D.new()
		_pala_sprite.texture = _pala_texture
		_pala_sprite.scale = Vector2(0.15, 0.15)
		_pala_sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)
		h_box.add_child(_pala_sprite)
		
		var rama_label := Label.new()
		rama_label.text = "Rama"
		rama_label.add_theme_font_size_override("font_size", 12)
		rama_label.add_theme_color_override("font_color", Color(0.42, 0.26, 0.14))
		h_box.add_child(rama_label)
		
		_rama_sprite = Sprite2D.new()
		_rama_sprite.texture = _rama_texture
		_rama_sprite.scale = Vector2(0.15, 0.15)
		_rama_sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)
		h_box.add_child(_rama_sprite)

	func actualizar() -> void:
		var p: Partida = Juego.partida
		if p == null:
			return
		
		if p.tiene_herramienta(Partida.Herramienta.PALA):
			_pala_sprite.modulate = Color.WHITE
		else:
			_pala_sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)
		
		if p.tiene_herramienta(Partida.Herramienta.RAMA):
			_rama_sprite.modulate = Color.WHITE
		else:
			_rama_sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)
