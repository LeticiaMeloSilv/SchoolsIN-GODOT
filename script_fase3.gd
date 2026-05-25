extends Node2D

@export var enemy_scene: PackedScene
@export var xicara_scene: PackedScene
@export var vida_scene: PackedScene  

@export var sprite_path: NodePath  
const POSICAO_INICIAL = Vector2(2175.0, 431.0)
var ja_sumonou_debug = false
var primeira_vez_musica = true
@export var step: int = 100
@export var edge_margin: int = 200
@export_range(0.0, 1.0) var spawn_chance: float = 0.6

var rng := RandomNumberGenerator.new()

func _ready():
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
	rng.randomize()
	call_deferred("spawn_enemies")
func _process(delta: float) -> void:
	if !$som_fase.playing:
		if primeira_vez_musica:
			primeira_vez_musica = false
			$som_fase.volume_db = -80
			$som_fase.play()

			var tween = create_tween()
			tween.tween_property($som_fase, "volume_db", 0, 5.0)
		else:
			$som_fase.volume_db = 0
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

func spawn_enemies():
	var sprite := get_node(sprite_path) as Sprite2D
	if sprite == null:
		push_error("Sprite da fase não encontrado!")
		return

	var texture_width = sprite.texture.get_width() * sprite.global_scale.x

	var start_x = sprite.global_position.x - texture_width / 2 + edge_margin
	var end_x = sprite.global_position.x + texture_width / 2 - edge_margin

	# guarda posições válidas
	var possible_positions: Array[Vector2] = []

	var x = start_x
	while x < end_x:

		# evita a área proibida no eixo X
		if x < 1938.0 or x > 2926.0:

			# posição aleatória no eixo Y dentro da fase
			var y_offset = rng.randi_range(-200, 200)
			var final_y = 320

			possible_positions.append(Vector2(x, final_y))

		x += step

	possible_positions.shuffle()

	var enemy_count = rng.randi_range(10, 20)

	# impede tentar spawnar mais do que existe de posições
	enemy_count = min(enemy_count, possible_positions.size())

	for i in range(enemy_count):
		var spawn_roll = rng.randf()
		var spawned_node = null

		if spawn_roll <= 0.1: # 10% de chance para vida
			if vida_scene:
				spawned_node = vida_scene.instantiate()
		elif spawn_roll <= 0.4: # 20% de chance para xicara (total 30%)
			if xicara_scene:
				spawned_node = xicara_scene.instantiate()
		else: # O restante para inimigos
			if enemy_scene:
				spawned_node = enemy_scene.instantiate()

		if spawned_node:
			add_child(spawned_node)
			spawned_node.global_position = possible_positions[i]
