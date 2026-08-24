class_name BarraEstado
extends Control

const CORAZONES := 5
const COMIDAS := 5

var _energia: float = 100.0
var _energia_max: float = 100.0
var _comida: int = 0
var _semillas: _Tira
var _corazones: _Tira


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	offset_left = 20
	offset_top = 14
	offset_right = 420
	offset_bottom = 130
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 8)
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(col)
	_semillas = _fila(col, "Almacén", false)
	_corazones = _fila(col, "Energía", true)
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
