extends Node2D

@export var bubble_scene = preload("res://cena_bolha.tscn")
var score = 0
var keys = ["ui_left", "ui_up", "ui_right"]
var round=0
func _ready():
	$SpawnTimer.start()

func _on_spawn_timer_timeout():
	var bubble = bubble_scene.instantiate()
	
	# Posição aleatória na tela (evitando as bordas)
	var x = randf_range(100, 700)
	var y = randf_range(100, 500)
	bubble.position = Vector2(x, y)
	
	# Tecla aleatória
	bubble.key_idx = randi() % 3
	
	bubble.connect("bubble_clicked", _on_bubble_clicked)
	
	add_child(bubble)

func _on_bubble_clicked(success, key_idx, pos):
	if success:
		score += 1
		show_feedback("ACERTOU!", pos, Color.GREEN)
	else:
		score -= 1
		show_feedback("ERROU!", pos, Color.RED)
	round+=1
	
func show_feedback(text, pos, color):
	var label = Label.new()
	label.text = text
	label.position = pos
	label.modulate = color
	$UI.add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "position:y", pos.y - 50, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0, 0.5)
	tween.tween_callback(label.queue_free)

func _process(delta: float) -> void:
	if(round>=5):
		if(score>=3):
			ScriptGlobal.tem_cartao=true
			ScriptGlobal.recebeu_item("+1 Cartão de acesso")
			ScriptGlobal.mostrar_dica("Eu devia ter guardado melhor esse cartão na minha bolsa")
			get_tree().change_scene_to_file("res://cena_fase_1.tscn")
		else:
			ScriptGlobal.mostrar_dica("Não consegui achar nada")
			get_tree().change_scene_to_file("res://cena_fase_1.tscn")
