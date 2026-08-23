extends SceneTree


func _init() -> void:
	var fallos := 0
	for ruta in ["res://src/menu/menu.tscn", "res://src/menu/configuracion.tscn", "res://src/mundo/mundo.tscn"]:
		var packed := load(ruta)
		if packed == null:
			print("FAIL no carga ", ruta)
			fallos += 1
			continue
		var nodo: Node = packed.instantiate()
		root.add_child(nodo)
		await process_frame
		await process_frame
		if ruta.ends_with("mundo.tscn"):
			if _buscar_minimapa(nodo) == null:
				print("FAIL mundo no tiene MiniMapa")
				fallos += 1
			else:
				print("ok  minimapa en mundo")
		print("ok  ", ruta)
		nodo.queue_free()
	print("SMOKE ", "ok" if fallos == 0 else "failed")
	quit(fallos)


func _buscar_minimapa(nodo: Node) -> Node:
	if nodo is MiniMapa:
		return nodo
	for hijo in nodo.get_children():
		var hallado := _buscar_minimapa(hijo)
		if hallado:
			return hallado
	return null
