extends Area2D


func coletar_vida(body: Node2D) -> void:
	if body.is_in_group("player"):
		ScriptGlobal.qtd_vidas += 1
		ScriptGlobal.tocar_som("res://Sons e m├║sicas/vida.mp3")
		queue_free()
		
