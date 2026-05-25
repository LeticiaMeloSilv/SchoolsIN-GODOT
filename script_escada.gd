extends Node2D

@export var minigame_scene: PackedScene = preload("res://cena_minigame.tscn")

var cena_sucesso
var escadas = []
var index_selecionado = 0
var minigame_ativo = false
var timer = Timer.new()

@onready var borda = $Borda

func _ready():
	# pega o número do andar atual
	var numero_andar = int(
		ScriptGlobal.cena_atual
		.get_file()
		.trim_suffix(".tscn")
		.trim_prefix("fase")
	)

	# Inicializa as 4 escadas
	# Escada0 e Escada1 = Subir | Escada2 e Escada3 = Descer
	for i in range(4):
		var tipo = "subir" if i < 2 else "descer"

		# Define quem é a "outra" escada do mesmo tipo
		var parceiro = 1 if i == 0 else (0 if i == 1 else (3 if i == 2 else 2))

		var bloqueada_andar = false

		# andar 1 -> bloqueia descida
		if numero_andar == 1 and tipo == "descer":
			bloqueada_andar = true

		# andar 4 -> bloqueia subida
		if numero_andar == 4 and tipo == "subir":
			bloqueada_andar = true

		escadas.append({
			"node": get_node("Escada" + str(i)),
			"tipo": tipo,
			"chance": randi_range(10, 90),
			"parceiro": parceiro,
			"pula_minigame": false,
			"bloqueada": false,
			"indisponivel": bloqueada_andar
		})

	atualizar_selecao()

	timer.wait_time = 0.4
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)

	if !minigame_ativo:
		timer.timeout.connect(_piscar_borda)
func _piscar_borda():
	borda.visible = !borda.visible

func _process(delta):
	# Se o minigame estiver rodando, bloqueia os controles da escada
	if minigame_ativo:
		return
		
	if Input.is_action_just_pressed("ui_left"):
		index_selecionado -= 1
		if index_selecionado < 0:
			index_selecionado = escadas.size() - 1
		atualizar_selecao()
		
	elif Input.is_action_just_pressed("ui_right"):
		index_selecionado += 1
		if index_selecionado >= escadas.size():
			index_selecionado = 0
		atualizar_selecao()
		
	elif Input.is_action_just_pressed("ui_accept"): # Tecla Enter / Espaço
		tentar_escada()

func atualizar_selecao():
	# Move a borda amarela para a posição da escada selecionada
	var escada_atual = escadas[index_selecionado]
	borda.global_position = escada_atual["node"].global_position

func tentar_escada():
	print("tentou")
	var escada = escadas[index_selecionado]

	if escada["indisponivel"]:
		ScriptGlobal.mostrar_dica("Essa escada não pode ser usada neste andar.")
		return
	
	if ScriptGlobal.is_debuging:
		sucesso_na_escada()

	if escada["bloqueada"]:
		print("Você já falhou nesta escada. Tente a outra de ", escada["tipo"], "!")
		return
		
	else:
		iniciar_minigame()
		
func iniciar_minigame():
	minigame_ativo = true
	var minigame = minigame_scene.instantiate()
	timer.timeout.disconnect(_piscar_borda)

	# Conecta o sinal do minigame para saber quando ele terminar
	minigame.connect("minigame_finished", Callable(self, "_on_minigame_finished"))
	add_child(minigame)

func _on_minigame_finished(venceu_minigame: bool):
	minigame_ativo = false
	timer.timeout.connect(_piscar_borda)
	var escada = escadas[index_selecionado]
	
	if venceu_minigame:
		# Passou no minigame, agora testa a porcentagem da escada
		var sorte = randi_range(1, 100)
		if sorte <= escada["chance"]:
			print("Sucesso total! Passou no minigame e na porcentagem.")
			sucesso_na_escada()
		else:
			print("Falhou na porcentagem da escada (Tirou %d, precisava <= %d)" % [sorte, escada["chance"]])
			falha_na_escada()
	else:
		print("Falhou no minigame.")
		falha_na_escada()

func sucesso_na_escada():
	print("oi")
	# Lógica de sucesso (mudar de cena)
	var escada = escadas[index_selecionado]
	print(escada)
	var tipo_escada = escada["tipo"]
	print(tipo_escada)
	var numero = int(ScriptGlobal.cena_atual.get_file().trim_suffix(".tscn").trim_prefix("fase"))
	print(numero)
	if tipo_escada=="subir":
		numero = numero + 1
	else:
		numero = numero - 1
	print(numero)
	cena_sucesso = (
		ScriptGlobal.cena_atual.left(ScriptGlobal.cena_atual.length() - 6)
		+ str(numero)
		+ ".tscn"
	)
	print(cena_sucesso)
	
	get_tree().change_scene_to_file(cena_sucesso)

func falha_na_escada():
	var escada = escadas[index_selecionado]
	escada["bloqueada"] = true # Bloqueia a escada atual
	
	# A outra escada do mesmo tipo ganha 100% e pula o minigame
	var parceiro_idx = escada["parceiro"]
	escadas[parceiro_idx]["pula_minigame"] = true
	escadas[parceiro_idx]["chance"] = 100
	ScriptGlobal.mostrar_dica("Caramba, essas escadas estâo sempre desligadas! Deixa eu tentar na outra")
	await get_tree().create_timer(4.0).timeout
	ScriptGlobal.esconder_dica()
