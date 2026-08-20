extends SceneTree

var _failed: int = 0
var _passed: int = 0


func _init() -> void:
	_stress_correr_diez_mil_veces()
	_stress_depositar_de_mas_no_rompe_victoria()
	_stress_transcurrir_un_millon()
	_stress_cargar_mientras_se_arrastra()
	_stress_energia_exacta_con_carga()
	_stress_descansar_en_derrota_no_revive()
	_stress_saltar_cargando()
	_stress_transcurrir_cero_y_negativo()
	_stress_limite_blanco_en_300()
	_geometry_suelos_solapados()
	_geometry_derrumbada_no_bloquea_el_piso()
	_stress_bob_larvas_deriva()
	_contrato_comida_soltada_sigue_tomada()

	print("STRESS %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func _ok(nombre: String, cond: bool) -> void:
	if cond:
		_passed += 1
		print("  ok  ", nombre)
	else:
		_failed += 1
		print("  FAIL", nombre)


func _stress_correr_diez_mil_veces() -> void:
	var p := Partida.new()
	for _i in 10000:
		p.correr()
	_ok("diez mil correr no crashea", p.energia == 0)
	_ok("diez mil correr termina en arrastre", p.arrastrandose)
	_ok("diez mil correr no es derrota", p.resultado == Partida.Resultado.EN_CURSO)


func _stress_depositar_de_mas_no_rompe_victoria() -> void:
	var p := Partida.new()
	for _i in 5:
		p.cargar()
		p.depositar(Partida.Destino.ALMACEN)
	for _i in 50:
		p.cargar()
		p.depositar(Partida.Destino.ALMACEN)
	_ok("no deposita de mas despues de ganar", p.comida_en_almacen == 5)
	_ok("sigue siendo victoria", p.resultado == Partida.Resultado.VICTORIA)


func _stress_transcurrir_un_millon() -> void:
	var p := Partida.new()
	p.transcurrir(1000000)
	_ok("un millon de tiempo queda en blanco", p.estacion == Partida.Estacion.BLANCO)
	_ok("un millon de tiempo es derrota", p.resultado == Partida.Resultado.DERROTA)


func _stress_cargar_mientras_se_arrastra() -> void:
	var p := Partida.new()
	while p.energia > 0:
		p.correr()
	_ok("no carga mientras se arrastra", p.cargar() == false)
	p.descansar()
	_ok("despues de descansar puede cargar", p.cargar())


func _stress_energia_exacta_con_carga() -> void:
	var p := Partida.new()
	p.energia = 4
	p.cargar()
	p.correr()
	_ok("costo 4 deja energia en 0", p.energia == 0)
	_ok("costo 4 suelta comida", p.lleva_comida == false)
	_ok("costo 4 arrastra", p.arrastrandose)


func _stress_descansar_en_derrota_no_revive() -> void:
	var p := Partida.new()
	p.transcurrir(Partida.TIEMPO_POR_ESTACION * 4)
	p.energia = 1
	p.descansar()
	_ok("descansar en derrota no llena energia", p.energia == 1)
	_ok("descansar en derrota sigue derrota", p.resultado == Partida.Resultado.DERROTA)


func _stress_saltar_cargando() -> void:
	var p := Partida.new()
	p.cargar()
	p.saltar()
	_ok("saltar cargando gasta 3", p.energia == 97)


func _stress_transcurrir_cero_y_negativo() -> void:
	var p := Partida.new()
	p.transcurrir(0)
	p.transcurrir(-20)
	_ok("tiempo no baja con transcurrir invalido", p.tiempo == 0)
	_ok("estacion no cambia con transcurrir invalido", p.estacion == Partida.Estacion.TARDE_HUMEDA)


func _stress_limite_blanco_en_300() -> void:
	var p := Partida.new()
	p.transcurrir(299)
	_ok("299 aun no es blanco", p.estacion == Partida.Estacion.PRIMER_HIELO)
	_ok("299 aun en curso", p.resultado == Partida.Resultado.EN_CURSO)
	p.transcurrir(1)
	_ok("300 es blanco y derrota", p.estacion == Partida.Estacion.BLANCO and p.resultado == Partida.Resultado.DERROTA)


func _geometry_suelos_solapados() -> void:
	var nido := Rect2(-80, 520, 1960, 220)
	var afuera := Rect2(1760, 460, 2400, 280)
	var overlap := nido.intersection(afuera)
	var hormiga_en_nido := Vector2(1800, 510)
	_ok("hormiguero y afuera no se solapan", overlap.size.x <= 0.0)
	_ok("una hormiga sobre el nido no queda dentro del collider de afuera", not afuera.has_point(hormiga_en_nido))


func _geometry_derrumbada_no_bloquea_el_piso() -> void:
	var derrumbe := Rect2(300, 280, 90, 160)
	var piso_y := 510.0
	var cruza_piso := derrumbe.position.y + derrumbe.size.y > piso_y
	_ok("la derrumbada intercepta el piso caminable", cruza_piso)


func _stress_bob_larvas_deriva() -> void:
	var y := 500.0
	for i in 20000:
		y += sin(i * 16.0 * 0.01) * 0.08
	_ok("el bob de larvas se queda cerca del sitio", absf(y - 500.0) <= 5.0)


func _contrato_comida_soltada_sigue_tomada() -> void:
	# Replica el contrato roto de mundo.gd + comida_pieza.gd:
	# al arrastrarse se llama soltar() en Partida y soltar_vista() en la Hormiga,
	# pero ComidaPieza.tomada nunca vuelve a false.
	var tomada := true
	var lleva := true
	var p := Partida.new()
	p.cargar()
	while p.energia > 0:
		p.correr()
	lleva = p.lleva_comida
	# mundo no toca `tomada` al soltar
	var puede_recoger := not tomada
	_ok("partida suelta la comida al llegar a 0", lleva == false)
	_ok("la pieza se puede volver a recoger despues de soltarla", puede_recoger)
