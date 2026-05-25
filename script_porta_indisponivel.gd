extends Area2D

var player_perto = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta):
	if ScriptGlobal.is_dialogando:
		monitoring=false
		monitorable=false
	else:
		monitoring=true
		monitorable=true
		
	if player_perto and Input.is_action_just_pressed("interact"):
		interagir()
		
func interagir():
	if ScriptGlobal.cena_atual=="res://cena_fase_1.tscn":
		ScriptGlobal.tocar_som("res://Sons e m├║sicas/porta_trancada.mp3")
		ScriptGlobal.mostrar_dica("Eu não deveria entrar ai")
	if ScriptGlobal.cena_atual=="res://cena_fase_4.tscn":
		ScriptGlobal.mostrar_dica("Eu não consigo passar por aqui")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = true
		ScriptGlobal.mostrar_dica("Pressione E para interagir", Color.WHITE_SMOKE)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = false
		ScriptGlobal.esconder_dica()
