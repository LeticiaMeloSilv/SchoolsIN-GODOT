extends Area2D

var cena_zumbi   = preload("res://cena_zumbidesono.tscn")
var player_perto = false
var objeto_zumbi 
var porta1: Sprite2D
var porta2: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ScriptGlobal.esconder_dica()

	ScriptGlobal.cena_atual = get_tree().current_scene.scene_file_path
	print(ScriptGlobal.tem_chave)
	if !ScriptGlobal.tem_chave:
		porta1 = Sprite2D.new()
		porta1.texture = preload("res://Imagens/sprite_porta_fechada.png")
		porta1.global_position = Vector2(1981.104, 381.643)
		porta1.scale = Vector2(0.38,0.384)
		porta1.z_index = 1
		add_sibling.call_deferred(porta1)

		porta2 = Sprite2D.new()
		porta2.texture = preload("res://Imagens/sprite_porta_fechada.png")
		porta2.flip_h=true
		porta2.global_position = Vector2(2124.977, 382.0)
		porta2.scale = Vector2(0.38,0.384)
		porta2.z_index = 1
		add_sibling.call_deferred(porta2)
		
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
	if ScriptGlobal.etapa_cena==1:
		ScriptGlobal.mostrar_dica("Eu deveria pegar um café primeiro")
	elif !ScriptGlobal.tem_chave:
		ScriptGlobal.tocar_som("res://Sons e m├║sicas/porta_trancada.mp3")
		ScriptGlobal.mostrar_dica("Está trancado, quando será que eles abrem essa jossa, hein?")
	else:
		if is_instance_valid(porta1) && is_instance_valid(porta2):
			ScriptGlobal.tocar_som("res://Sons e m├║sicas/porta aberta.mp3")
			porta1.queue_free()
			porta2.queue_free()
			ScriptGlobal.esconder_dica()
			objeto_zumbi = cena_zumbi.instantiate()
			objeto_zumbi.global_position = Vector2(2100.977, 380)
			objeto_zumbi.morreu.connect(_on_zumbi_morreu)
			add_sibling(objeto_zumbi)
			get_parent().get_node("som_fase").volume_db = -80
			ScriptGlobal.tocar_som("res://Sons e m├║sicas/susto.mp3")
		else:
			get_tree().change_scene_to_file("res://cena_escada.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = true
		if is_instance_valid(objeto_zumbi):
			return
		if !is_instance_valid(porta1) && !is_instance_valid(porta2):
			ScriptGlobal.mostrar_dica("Pressione E para interagir", Color.WHITE_SMOKE)
		elif ScriptGlobal.tem_chave:
			ScriptGlobal.mostrar_dica("Inserir chave?")
		else:
			ScriptGlobal.mostrar_dica("Pressione E para interagir", Color.WHITE_SMOKE)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = false
		ScriptGlobal.esconder_dica()

func _on_zumbi_morreu():
	ScriptGlobal.esconder_dica()
	await ScriptGlobal.iniciar_dialogo([
		{"texto":"QUE MERDA FOI ESSA??", "personagem":"Leticia"},
		{"texto":"Susto do caralho", "personagem":"Leticia"},
		{"texto":"Devo estar chapada de sono, só pode...", "personagem":"Leticia"},
		{"texto":"Melhor comprar um cafézinho", "personagem":"Leticia"}
	])
	ScriptGlobal.etapa_cena=1
	var tween = create_tween()
	tween.tween_property(get_parent().get_node("som_fase"), "volume_db", 0, 5.0)

	
