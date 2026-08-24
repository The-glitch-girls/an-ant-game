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
	var _pala_label: Label
	var _rama_label: Label
	var _instrucciones: Label

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var v_box := VBoxContainer.new()
		v_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v_box.add_theme_constant_override("separation", 4)
		v_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(v_box)
		
		var h_box := HBoxContainer.new()
		h_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h_box.add_theme_constant_override("separation", 20)
		v_box.add_child(h_box)
		
		_pala_label = Label.new()
		_pala_label.text = "[1] Pala: ❌"
		_pala_label.add_theme_font_size_override("font_size", 13)
		_pala_label.add_theme_color_override("font_color", Color(0.42, 0.26, 0.14))
		h_box.add_child(_pala_label)
		
		_rama_label = Label.new()
		_rama_label.text = "[2] Rama: ❌"
		_rama_label.add_theme_font_size_override("font_size", 13)
		_rama_label.add_theme_color_override("font_color", Color(0.42, 0.26, 0.14))
		h_box.add_child(_rama_label)
		
		_instrucciones = Label.new()
		_instrucciones.text = "[ESPACIO] Usar herramienta"
		_instrucciones.add_theme_font_size_override("font_size", 11)
		_instrucciones.add_theme_color_override("font_color", Color(0.42, 0.26, 0.14))
		v_box.add_child(_instrucciones)

	func actualizar() -> void:
		var p: Partida = Juego.partida
		if p == null:
			return
		
		var pala_activa = p.herramienta_activa == Partida.Herramienta.PALA
		var rama_activa = p.herramienta_activa == Partida.Herramienta.RAMA
		
		if p.tiene_herramienta(Partida.Herramienta.PALA):
			_pala_label.text = "[1] Pala: ✅" if pala_activa else "[1] Pala: ✅"
			_pala_label.add_theme_color_override("font_color", Color.WHITE if pala_activa else Color(0.42, 0.26, 0.14))
		else:
			_pala_label.text = "[1] Pala: ❌"
			_pala_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
		
		if p.tiene_herramienta(Partida.Herramienta.RAMA):
			_rama_label.text = "[2] Rama: ✅" if rama_activa else "[2] Rama: ✅"
			_rama_label.add_theme_color_override("font_color", Color.WHITE if rama_activa else Color(0.42, 0.26, 0.14))
		else:
			_rama_label.text = "[2] Rama: ❌"
			_rama_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
