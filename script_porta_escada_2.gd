extends Area2D

var cena_zumbi   = preload("res://cena_zumbidesono.tscn")
var existe_zumbi = false;
var player_perto = false
var objeto_zumbi 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ScriptGlobal.cena_atual = get_tree().current_scene.scene_file_path

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
	if !ScriptGlobal.tem_chave:
		ScriptGlobal.mostrar_dica("Está trancado, quando será que eles abrem essa jossa, hein?")
	else:
		get_tree().change_scene_to_file("res://cena_escada.tscn")

func _on_body_entered(body: Node2D) -> void:
	if ScriptGlobal.etapa_cena == 3:
		return
	if body.is_in_group("player"):
		player_perto = true
		ScriptGlobal.mostrar_dica("Pressione E para interagir", Color.WHITE_SMOKE)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = false
		ScriptGlobal.esconder_dica()
