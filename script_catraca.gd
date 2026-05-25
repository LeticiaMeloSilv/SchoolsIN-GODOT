extends Area2D

@onready var catraca: CollisionShape2D = $"../StaticBody2D/Catraca"

func _ready() -> void:
	pass # Replace with function body.

var player_perto = false

func _process(delta):
	if player_perto and Input.is_action_just_pressed("interact"):
		interagir()

func interagir():
	if ScriptGlobal.tem_cartao:
		catraca.queue_free()
		queue_free()
		var sprite_verde = Sprite2D.new()
		sprite_verde.texture = load("res://Imagens/permitido.png")
		sprite_verde.position = Vector2(234.875, 527.5)
		sprite_verde.scale = Vector2(0.152, 0.167)
		get_parent().add_child(sprite_verde)
		get_parent().move_child(sprite_verde, 1) 
	else:
		get_tree().change_scene_to_file("res://cena_bolsa.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = true
		if ScriptGlobal.tem_cartao:
			ScriptGlobal.mostrar_dica("Inserir cartão")
		else:
			ScriptGlobal.mostrar_dica("Aperte E para interagir")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = false
		ScriptGlobal.esconder_dica()
