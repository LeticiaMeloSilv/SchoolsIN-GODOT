extends Node2D

const POSICAO_INICIAL = Vector2(73.0, 528.0)
var primeira_vez_musica = true
var ja_sumonou_debug = false

func _ready() -> void:
	# =========================
	# PRIMEIRA VEZ
	# =========================
	if ScriptGlobal.personagens_paths.is_empty():

		ScriptGlobal.personagens_paths = [
			"res://cena_personagem_leticia.tscn"
		]

	# =========================
	# LIMPA INSTÂNCIAS ANTIGAS
	# =========================
	ScriptGlobal.personagens.clear()

	# =========================
	# INSTANCIA PERSONAGENS
	# =========================
	for path_personagem in ScriptGlobal.personagens_paths:

		var cena = load(path_personagem)

		if cena == null:
			push_error("Erro ao carregar: " + path_personagem)
			continue

		var personagem = cena.instantiate()

		add_child(personagem)

		personagem.global_position = POSICAO_INICIAL

		ScriptGlobal.personagens.append(personagem)

	# =========================
	# DEFINE PERSONAGEM ATIVO
	# =========================
	ScriptGlobal.trocar_de_personagem(
		ScriptGlobal.personagem_atual
	)
	ScriptGlobal.esconder_dica()

func _process(delta: float) -> void:
	if !$som_fase.playing:
		if primeira_vez_musica:
			primeira_vez_musica = false
			$som_fase.volume_db = -80
			$som_fase.play()

			var tween = create_tween()
			tween.tween_property($som_fase, "volume_db", 0, 5.0)
		else:
			$som_fase.play()
	if ScriptGlobal.is_debuging:

		if ja_sumonou_debug:
			return

		var cenas_personagens = [

			"res://cena_personagem_heitor.tscn",
			"res://cena_personagem_kaua.tscn",
			"res://cena_personagem_leticia.tscn",
			"res://cena_personagem_isabeli.tscn",
			"res://cena_personagem_thais.tscn",
			"res://cena_personagem_lucas.tscn",
			"res://cena_personagem_matheus.tscn",
			"res://cena_personagem_kelvin.tscn"

		]

		# =========================
		# INSTANCIA OS FALTANTES
		# =========================
		for path in cenas_personagens:

			if path in ScriptGlobal.personagens_paths:
				continue

			var cena = load(path)

			if cena == null:
				continue

			var novo_personagem = cena.instantiate()

			add_child(novo_personagem)

			# POSIÇÃO DO PERSONAGEM ATUAL
			var personagem_atual = ScriptGlobal.personagens[
				ScriptGlobal.personagem_atual
			]

			if is_instance_valid(personagem_atual):
				novo_personagem.global_position = personagem_atual.global_position
			else:
				novo_personagem.global_position = POSICAO_INICIAL

			# ADICIONA NOS ARRAYS
			ScriptGlobal.personagens.append(novo_personagem)
			ScriptGlobal.personagens_paths.append(path)

		ja_sumonou_debug = true
