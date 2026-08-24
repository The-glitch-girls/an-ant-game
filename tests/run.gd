extends SceneTree

var _failed: int = 0
var _passed: int = 0


func _init() -> void:
	_test_partida_empieza_con_energia_llena()
	_test_cinco_comidas_en_almacen_son_victoria()
	_test_blanco_sin_cinco_comidas_es_derrota()
	_test_depositar_en_camara_de_la_reina_no_cuenta()
	_test_energia_cero_suelta_comida_y_no_es_derrota()
	_test_hoja_carga_hasta_tres_comidas()
	_test_correr_gasta_dos_y_cargar_gasta_mas()
	_test_saltar_gasta_uno()
	_test_descansar_restaura_energia_y_el_invierno_avanza()
	_test_victoria_no_se_vuelve_derrota_al_llegar_el_blanco()
	_test_reconstruir_hoja_con_tres_fragmentos()
	_test_reconstruir_pala_con_tres_fragmentos()
	_test_minimapa_cubre_el_hormiguero_y_marca_la_hormiga()

	print("PARTIDA %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func _ok(nombre: String, cond: bool) -> void:
	if cond:
		_passed += 1
		print("  ok  ", nombre)
	else:
		_failed += 1
		print("  FAIL", nombre)


func _test_partida_empieza_con_energia_llena() -> void:
	var p := Partida.new()
	_ok("energia inicial es 100", p.energia == 100)
	_ok("almacen vacio", p.comida_en_almacen == 0)
	_ok("estacion tarde humeda", p.estacion == Partida.Estacion.TARDE_HUMEDA)
	_ok("en curso", p.resultado == Partida.Resultado.EN_CURSO)


func _test_cinco_comidas_en_almacen_son_victoria() -> void:
	var p := Partida.new()
	for _i in 5:
		p.cargar()
		p.depositar(Partida.Destino.ALMACEN)
	_ok("cinco comidas ganan", p.resultado == Partida.Resultado.VICTORIA)
	_ok("almacen tiene 5", p.comida_en_almacen == 5)


func _test_blanco_sin_cinco_comidas_es_derrota() -> void:
	var p := Partida.new()
	p.transcurrir(Partida.TIEMPO_POR_ESTACION * 4)
	_ok("blanco sin comida es derrota", p.resultado == Partida.Resultado.DERROTA)
	_ok("estacion blanco", p.estacion == Partida.Estacion.BLANCO)


func _test_depositar_en_camara_de_la_reina_no_cuenta() -> void:
	var p := Partida.new()
	p.cargar()
	var acepto := p.depositar(Partida.Destino.CAMARA_REINA)
	_ok("camara rechaza", acepto == false)
	_ok("almacen sigue en 0", p.comida_en_almacen == 0)
	_ok("sigue cargando", p.lleva_comida)


func _test_energia_cero_suelta_comida_y_no_es_derrota() -> void:
	var p := Partida.new()
	p.cargar()
	while p.energia > 0:
		p.correr()
	_ok("suelta la comida", p.lleva_comida == false)
	_ok("se arrastra", p.arrastrandose)
	_ok("no es derrota", p.resultado == Partida.Resultado.EN_CURSO)


func _test_hoja_carga_hasta_tres_comidas() -> void:
	var p := Partida.new()
	_ok("primera carga", p.cargar())
	_ok("segunda carga", p.cargar())
	_ok("tercera carga", p.cargar())
	_ok("cuarta carga falla", p.cargar() == false)


func _test_correr_gasta_dos_y_cargar_gasta_mas() -> void:
	var p := Partida.new()
	p.correr()
	_ok("correr gasta 2", p.energia == 98)
	p.cargar()
	p.correr()
	_ok("correr cargando gasta 4", p.energia == 94)


func _test_saltar_gasta_uno() -> void:
	var p := Partida.new()
	p.saltar()
	_ok("saltar gasta 1", p.energia == 99)


func _test_descansar_restaura_energia_y_el_invierno_avanza() -> void:
	var p := Partida.new()
	p.correr()
	p.correr()
	var tiempo_antes := p.tiempo
	p.descansar()
	_ok("descanso llena energia", p.energia == 100)
	_ok("invierno no se pausa", p.tiempo > tiempo_antes)


func _test_minimapa_cubre_el_hormiguero_y_marca_la_hormiga() -> void:
	var m := HormigueroMapa.new()
	m.generar()
	var mini := MiniMapa.new()
	mini.armar(m)
	var tam := mini.custom_minimum_size
	_ok("minimapa cabe el nido entero", tam.x == HormigueroMapa.ANCHO * MiniMapa.PX + MiniMapa.MARGEN * 2)
	_ok("minimapa cabe el nido de alto", tam.y == HormigueroMapa.ALTO * MiniMapa.PX + MiniMapa.MARGEN * 2)
	var en_almacen := mini.mundo_a_local(m.almacen)
	var afuera := mini.mundo_a_local(m.comidas[0])
	var marco := Rect2(Vector2.ZERO, tam)
	_ok("el punto del almacen queda dentro", marco.has_point(en_almacen))
	_ok("el punto de afuera queda dentro", marco.has_point(afuera))
	_ok("afuera se lee arriba del hormiguero", afuera.y < en_almacen.y)
	mini.free()


func _test_victoria_no_se_vuelve_derrota_al_llegar_el_blanco() -> void:
	var p := Partida.new()
	for _i in 5:
		p.cargar()
		p.depositar(Partida.Destino.ALMACEN)
	p.transcurrir(Partida.TIEMPO_POR_ESTACION * 4)
	_ok("victoria se mantiene", p.resultado == Partida.Resultado.VICTORIA)


func _test_reconstruir_hoja_con_tres_fragmentos() -> void:
	var p := Partida.new()
	_ok("un fragmento nuevo se registra", p.recoger_fragmento(Partida.Herramienta.HOJA, "tallo"))
	_ok("un fragmento duplicado se rechaza", p.recoger_fragmento(Partida.Herramienta.HOJA, "tallo") == false)
	p.recoger_fragmento(Partida.Herramienta.HOJA, "cuerpo")
	p.recoger_fragmento(Partida.Herramienta.HOJA, "borde")
	_ok("tres fragmentos habilitan la hoja", p.puede_reconstruir(Partida.Herramienta.HOJA))
	_ok("reconstruir habilita la hoja", p.reconstruir(Partida.Herramienta.HOJA))
	_ok("la hoja queda disponible", p.tiene_herramienta(Partida.Herramienta.HOJA))


func _test_reconstruir_pala_con_tres_fragmentos() -> void:
	var p := Partida.new()
	for id in ["mango", "cabezal", "restante"]:
		p.recoger_fragmento(Partida.Herramienta.PALA, id)
	_ok("tres fragmentos habilitan la pala", p.puede_reconstruir(Partida.Herramienta.PALA))
	_ok("reconstruir habilita la pala", p.reconstruir(Partida.Herramienta.PALA))
	_ok("la pala queda disponible", p.tiene_herramienta(Partida.Herramienta.PALA))
