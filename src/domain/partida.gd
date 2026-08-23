class_name Partida
extends RefCounted

enum Estacion { TARDE_HUMEDA, GRIS, PRIMER_HIELO, BLANCO }
enum Resultado { EN_CURSO, VICTORIA, DERROTA }
enum Destino { ALMACEN, CAMARA_REINA }

const ENERGIA_INICIAL := 100
const COMIDAS_PARA_VICTORIA := 5
const COSTO_CORRER := 2
const COSTO_SALTAR := 1
const COSTO_CARGAR := 2
const TIEMPO_POR_ESTACION := 100
const TIEMPO_DESCANSO := 10

var energia: int = ENERGIA_INICIAL
var comida_en_almacen: int = 0
var lleva_comida: bool = false
var costo_carga: int = 0
var arrastrandose: bool = false
var estacion: Estacion = Estacion.TARDE_HUMEDA
var tiempo: int = 0
var resultado: Resultado = Resultado.EN_CURSO


func correr() -> void:
	if resultado != Resultado.EN_CURSO:
		return
	_gastar(COSTO_CORRER + (costo_carga if lleva_comida else 0))


func saltar() -> void:
	if resultado != Resultado.EN_CURSO or arrastrandose:
		return
	_gastar(COSTO_SALTAR + (costo_carga if lleva_comida else 0))


func cargar(extra: int = COSTO_CARGAR) -> bool:
	if resultado != Resultado.EN_CURSO or lleva_comida or arrastrandose:
		return false
	lleva_comida = true
	costo_carga = extra
	return true


func soltar() -> void:
	lleva_comida = false
	costo_carga = 0


func depositar(destino: Destino) -> bool:
	if resultado != Resultado.EN_CURSO or not lleva_comida:
		return false
	if destino != Destino.ALMACEN:
		return false
	lleva_comida = false
	costo_carga = 0
	comida_en_almacen += 1
	if comida_en_almacen >= COMIDAS_PARA_VICTORIA:
		resultado = Resultado.VICTORIA
	return true


func descansar() -> void:
	if resultado != Resultado.EN_CURSO:
		return
	energia = ENERGIA_INICIAL
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
