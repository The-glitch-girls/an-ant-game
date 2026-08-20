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
		print("ok  ", ruta)
		nodo.queue_free()
	print("SMOKE ", "ok" if fallos == 0 else "failed")
	quit(fallos)
