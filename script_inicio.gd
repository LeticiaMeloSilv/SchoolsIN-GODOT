extends Node2D

var esperando_confirmacao = false

func _ready() -> void:
	ScriptGlobal.cena_atual = "res://cena_inicio.tscn"
	
func _process(delta):
	if ScriptGlobal.cena_atual != "res://cena_inicio.tscn":
		return
	else:
		if !$AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()

func _input(event):

	# SE ESTIVER ESPERANDO CONFIRMAÇÃO
	if esperando_confirmacao:

		# ENTER
		if event.is_action_pressed("ui_accept"):
			esperando_confirmacao = false
			ScriptGlobal.esconder_dica()
			await ScriptGlobal.inicializar()
			ScriptGlobal.mostrar_dica(
				"Carregando..."
			)
			ScriptGlobal.tem_chave=true
			ScriptGlobal.personagens_paths = [
			"res://cena_personagem_leticia.tscn",
			"res://cena_personagem_heitor.tscn",
			"res://cena_personagem_kaua.tscn",
			"res://cena_personagem_isabeli.tscn",
			"res://cena_personagem_thais.tscn",
			"res://cena_personagem_lucas.tscn",
			"res://cena_personagem_matheus.tscn",
			"res://cena_personagem_kelvin.tscn"]
			get_tree().change_scene_to_file("res://cena_fase_4.tscn")

func iniciar_jogo() -> void:
	ScriptGlobal.inicializar()
	ScriptGlobal.mostrar_dica(
		"Carregando..."
	)
	get_tree().change_scene_to_file("res://cena_fase_1.tscn")

func continuar_sofrendo() -> void:

	# EVITA CLICAR VÁRIAS VEZES
	if esperando_confirmacao:
		return

	esperando_confirmacao = true

	ScriptGlobal.mostrar_dica(
		"ATENÇÃO: Nesta versão do jogo, a função de salvar jogo está indisponivel, esse botão o levará para a ultima fase. Pressione ENTER para confirmar sua ação."
	)

func configuracoes() -> void:
	esperando_confirmacao = false
	ScriptGlobal.mostrar_dica("Função indisponivel")

func creditos() -> void:
	ScriptGlobal.mostrar_dica(
		"Carregando..."
	)
	get_tree().change_scene_to_file("res://cena_creditos.tscn")

func desistir() -> void:
	get_tree().quit()
