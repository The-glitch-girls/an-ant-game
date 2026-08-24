class_name Partida
extends RefCounted

enum Estacion { TARDE_HUMEDA, GRIS, PRIMER_HIELO, BLANCO }
enum Resultado { EN_CURSO, VICTORIA, DERROTA }
enum Destino { ALMACEN, CAMARA_REINA }
enum Herramienta { HOJA, PALA, RAMA }

const ENERGIA_INICIAL := 100
const COMIDAS_PARA_VICTORIA := 5
const COSTO_CORRER := 2
const COSTO_SALTAR := 1
const TIEMPO_POR_ESTACION := 100
const TIEMPO_DESCANSO := 10
const FRAGMENTOS_POR_HERRAMIENTA := 3
const COMIDAS_MAXIMAS_CARGADAS := 3

var comida_en_almacen: int = 0
var comidas_cargadas: int = 0
const COSTO_CARGA_LIGERA := 1
const COSTO_CARGA_PESADA := 3
const INTERVALO_DESGASTE_CARGA := 2.0
const VELOCIDAD_RECUPERACION := 10.0

var energia: int = ENERGIA_INICIAL
var lleva_comida: bool = false
var comida_pesada: bool = false
var tiempo_cargando: float = 0.0
var arrastrandose: bool = false
var estacion: Estacion = Estacion.TARDE_HUMEDA
var tiempo: int = 0
var tiempo_descanso: float = 0.0
var resultado: Resultado = Resultado.EN_CURSO
var fragmentos: Dictionary = {
	Herramienta.HOJA: [],
	Herramienta.PALA: [],
	Herramienta.RAMA: [],
}
var herramientas: Dictionary = {
	Herramienta.HOJA: false,
	Herramienta.PALA: false,
	Herramienta.RAMA: false,
}


var lleva_comida: bool:
	get:
		return comidas_cargadas > 0

func correr() -> void:
	if resultado != Resultado.EN_CURSO:
		return
	_gastar(COSTO_CORRER)

func saltar() -> void:
	if resultado != Resultado.EN_CURSO or arrastrandose:
		return
	_gastar(COSTO_SALTAR)
	
func cargar(pesada: bool = false) -> bool:
	if resultado != Resultado.EN_CURSO or lleva_comida or arrastrandose:
		return false
	lleva_comida = true
	comida_pesada = pesada
	tiempo_cargando = 0.0
	return true

func soltar() -> void:
	lleva_comida = false
	comida_pesada = false
	tiempo_cargando = 0.0


func recoger_fragmento(herramienta: Herramienta, id: String) -> bool:
	if resultado != Resultado.EN_CURSO or not fragmentos.has(herramienta):
		return false
	var piezas: Array = fragmentos[herramienta]
	if id.is_empty() or piezas.has(id):
		return false
	piezas.append(id)
	return true


func cantidad_fragmentos(herramienta: Herramienta) -> int:
	if not fragmentos.has(herramienta):
		return 0
	return (fragmentos[herramienta] as Array).size()


func puede_reconstruir(herramienta: Herramienta) -> bool:
	return resultado == Resultado.EN_CURSO and not tiene_herramienta(herramienta) and cantidad_fragmentos(herramienta) >= FRAGMENTOS_POR_HERRAMIENTA


func reconstruir(herramienta: Herramienta) -> bool:
	if not puede_reconstruir(herramienta):
		return false
	herramientas[herramienta] = true
	return true


func tiene_herramienta(herramienta: Herramienta) -> bool:
	return herramientas.get(herramienta, false) as bool
func depositar(destino: Destino) -> bool:
	if resultado != Resultado.EN_CURSO or not lleva_comida:
		return false
	if destino != Destino.ALMACEN:
		return false
	comidas_cargadas -= 1
	comida_en_almacen += 1
	if comida_en_almacen >= COMIDAS_PARA_VICTORIA:
		resultado = Resultado.VICTORIA
	return true


func descansar() -> void:
	if resultado != Resultado.EN_CURSO:
		return

	arrastrandose = false
	transcurrir(TIEMPO_DESCANSO)


func transcurrir(unidades: int) -> void:
	if unidades <= 0:
		return
	tiempo += unidades
	var indice: int = mini(Estacion.BLANCO, tiempo / TIEMPO_POR_ESTACION)
	estacion = indice as Estacion
	if resultado == Resultado.EN_CURSO and estacion == Estacion.BLANCO:
		resultado = Resultado.DERROTA


func _gastar(costo: int) -> void:
	if arrastrandose:
		return
	energia = maxi(0, energia - costo)
	if energia == 0:
		arrastrandose = true
		soltar()

# Comida normal: Cada 2 segundos → -1 energía
# Comida pesada: Cada 2 segundos → -3 energía
func actualizar_carga(delta: float) -> void:
	if not lleva_comida or arrastrandose:
		return

	tiempo_cargando += delta

	if tiempo_cargando >= INTERVALO_DESGASTE_CARGA:
		tiempo_cargando -= INTERVALO_DESGASTE_CARGA

		var costo: int = COSTO_CARGA_PESADA if comida_pesada else COSTO_CARGA_LIGERA
		_gastar(costo)
		

# +1 energía cada 0.1 segundos = +10 por segundo
func actualizar_descanso(delta: float) -> void:
	if resultado != Resultado.EN_CURSO:
		return

	if energia >= ENERGIA_INICIAL:
		energia = ENERGIA_INICIAL
		return

	tiempo_descanso += delta

	if tiempo_descanso >= 0.1:
		tiempo_descanso -= 0.1
		energia = mini(ENERGIA_INICIAL, energia + 1)
