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
	var m := HormigueroMapa.new()
	m.generar()
	_ok("spawn esta mas abajo que la superficie", m.spawn.y > m.superficie_y)
	_ok("energia se gasta en superficie", m.esta_afuera(m.comidas[0]))
	_ok("energia no se gasta en el almacen", m.esta_afuera(m.almacen) == false)
	_ok("afuera tiene comida de tres tamanos", m.comida_tamanos.size() == m.comidas.size())
	_ok("la semilla grande esta en la boca", m.hay_comida_grande_en_la_boca())


func _geometry_derrumbada_no_bloquea_el_piso() -> void:
	var m := HormigueroMapa.new()
	m.generar()
	_ok("hay una derrumbada que tapa tunel", m.hay_derrumbada_en_tunel())


func _stress_bob_larvas_deriva() -> void:
	var y := 500.0
	for i in 20000:
		y += sin(i * 16.0 * 0.01) * 0.08
	_ok("el bob de larvas se queda cerca del sitio", absf(y - 500.0) <= 5.0)


func _contrato_comida_soltada_sigue_tomada() -> void:
	# soltar_vista llama ComidaPieza.liberar() para poder recoger otra vez.
	var pieza := ComidaPieza.new()
	pieza.tomada = true
	var p := Partida.new()
	p.cargar()
	while p.energia > 0:
		p.correr()
	pieza.liberar()
	_ok("partida suelta la comida al llegar a 0", p.lleva_comida == false)
	_ok("la pieza se puede volver a recoger despues de soltarla", pieza.tomada == false)
