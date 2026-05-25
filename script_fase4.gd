extends Node2D

var primeira_vez_musica = true
var boss_no_combate = false
const POSICAO_INICIAL = Vector2(1003.0, 433.0)
var ja_sumonou_debug = false

@onready var boss = $Boss
@onready var musica_boss = $Boss/som_boss

func _ready() -> void:
	ScriptGlobal.esconder_dica()
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
func _process(delta):
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

	var estado_boss = (boss.state == "CHASE" ||
					   boss.state == "ATTACKING" ||
					   boss.state == "JUMP_ATTACK")

	# =========================
	# MÚSICA DA FASE
	# =========================
	if !$som_fase.playing:
		if !is_instance_valid(musica_boss) || is_instance_valid(musica_boss)  && !musica_boss.playing:
			if primeira_vez_musica:
				primeira_vez_musica = false
				$som_fase.volume_db = -80
				$som_fase.play()

				var tween = create_tween()
				tween.tween_property($som_fase, "volume_db", 0, 1.0)
			else:
				$som_fase.volume_db = 0
				$som_fase.play()
	# =========================
	# DETECÇÃO DE ENTRADA NO BOSS
	# =========================
	if estado_boss and !boss_no_combate:
		boss_no_combate = true

		# corta fase imediatamente
		$som_fase.volume_db = -80

		# inicia boss na hora (SEM delay)
		musica_boss.volume_db = -80
		musica_boss.play()

		var tween = create_tween()
		tween.tween_property(musica_boss, "volume_db", 0, 2.0)
	
	elif estado_boss && !musica_boss.playing:
		$som_fase.volume_db = -80
		musica_boss.play()
		
	elif !estado_boss and boss_no_combate:

		boss_no_combate = false

		# fade OUT boss
		var tween = create_tween()
		tween.tween_property(musica_boss, "volume_db", -80, 2.0)

		# volta fase
		$som_fase.volume_db = 0
