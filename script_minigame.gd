extends Node2D

# Sinal que avisa a cena principal se o jogador ganhou ou perdeu
signal minigame_finished(success)

@export var bubble_scene = preload("res://cena_bolha.tscn")
var score = 0
var round = 0

func _ready():
	print("entrou")
	# Garante que o SpawnTimer existe e inicia
	if has_node("SpawnTimer"):
		$SpawnTimer.start()
	else:
		var timer = Timer.new()
		timer.name = "SpawnTimer"
		timer.wait_time = 1.0
		timer.autostart = true
		timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
		add_child(timer)
		
	# Garante que o nó UI existe
	if not has_node("UI"):
		var ui = Control.new()
		ui.name = "UI"
		add_child(ui)

func _on_spawn_timer_timeout():
	if round >= 5:
		return
		
	var bubble = bubble_scene.instantiate()
	var x = randf_range(50, 300)
	var y = randf_range(100, 500)
	bubble.position = Vector2(x, y)
	
	# Tecla aleatória
	bubble.key_idx = randi() % 3
	
	# Conectar sinal de clique (Godot 4 usa Callable)
	bubble.connect("bubble_clicked", Callable(self, "_on_bubble_clicked"))
	
	add_child(bubble)

func _on_bubble_clicked(success, key_idx, pos):
	if success:
		score += 1
		show_feedback("ACERTOU!", pos, Color.GREEN)
	else:
		score -= 1
		show_feedback("ERROU!", pos, Color.RED)
	
	round += 1
	
	# Verifica se o minigame acabou
	if round >= 5:
		finalizar_minigame()

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

func finalizar_minigame():
	if has_node("SpawnTimer"):
		$SpawnTimer.stop()
		
	# Aguarda 1 segundo para o jogador ver o último feedback antes de fechar
	await get_tree().create_timer(1.0).timeout
	
	# Verifica se atingiu a pontuação necessária
	var venceu = score >= 3

	# Emite o sinal para a cena principal e deleta o minigame
	emit_signal("minigame_finished", venceu)
	queue_free()
