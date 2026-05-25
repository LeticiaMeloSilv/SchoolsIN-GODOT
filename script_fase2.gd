extends Node2D

@export var enemy_scene: PackedScene
@export var sprite_path: NodePath  
@export var step: int = 100
@export var edge_margin: int = 200
@export_range(0.0, 1.0) var spawn_chance: float = 0.4
const POSICAO_INICIAL = Vector2(2417.0, 366.0)
var ja_sumonou_debug = false
var rng := RandomNumberGenerator.new()
var primeira_vez_musica = true
var pode_tocar = false

func _ready():

	var cena_zumbi = get_node_or_null("/root/cena_zumbidesono")

	if cena_zumbi:
		var som = cena_zumbi.get_node_or_null("som_fase")

		if som:
			som.volume_db = -80
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
	# DESBLOQUEAR PERSONAGEM
	# =========================
	if not "res://cena_personagem_kaua.tscn" in ScriptGlobal.personagens_paths:
		ScriptGlobal.personagens_paths.append(
			"res://cena_personagem_kaua.tscn"
		)
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
		if path_personagem == "res://cena_personagem_kaua.tscn":
			pass #TODO: colocar cutscene dele matando zumbi pra ensinar a mecanica de trocar de personagem
		personagem.global_position = POSICAO_INICIAL

		ScriptGlobal.personagens.append(personagem)

	# =========================
	# DEFINE PERSONAGEM ATIVO
	# =========================
	if ScriptGlobal.personagem_atual >= ScriptGlobal.personagens.size():
		ScriptGlobal.personagem_atual = 0
	
	ScriptGlobal.trocar_de_personagem(
		ScriptGlobal.personagem_atual
	)
	rng.randomize()
	call_deferred("spawn_enemies")
	ScriptGlobal.esconder_dica()
	await interacao_novo_personagem()

func _process(delta: float) -> void:
	if pode_tocar:
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
			var final_y = sprite.global_position.y + y_offset

			possible_positions.append(Vector2(x, final_y))

		x += step

	possible_positions.shuffle()

	var enemy_count = rng.randi_range(5, 13)

	# impede tentar spawnar mais do que existe de posições
	enemy_count = min(enemy_count, possible_positions.size())

	for i in range(enemy_count):
		var enemy = enemy_scene.instantiate()
		add_child(enemy)

		enemy.global_position = possible_positions[i]
	
func interacao_novo_personagem():
	if ScriptGlobal.etapa_cena <= 2:
		for personagem in ScriptGlobal.personagens:
			if personagem.scene_file_path == "res://cena_personagem_kaua.tscn":
				personagem.global_position = Vector2(2195.0, 451.0)
		await ScriptGlobal.iniciar_dialogo([
				{"texto":"Mano, quando foi que voce chegou??", "personagem":"Leticia"},
				{"texto":"Que susto kkkkk", "personagem":"Kaua"},
				{"texto":"Agora pouco.", "personagem":"Kaua"},
				{"texto":"Eu vi que você estava lá comprando coisa, ai eu decidi subir.", "personagem":"Kaua"},
				{"texto":"Tendi.", "personagem":"Leticia"},
				{"texto":"Alguem mais chegou?", "personagem":"Kaua"},
				{"texto":"Até então, não.", "personagem":"Leticia"},
				{"texto":"Devem estar já chegando.", "personagem":"Kaua"},
				{"texto":"Sim.", "personagem":"Leticia"},
				{"texto":"...", "personagem":"Kaua"},
				{"texto":"...", "personagem":"Leticia"},
				{"texto":"MANO QUE PORRA É AQUELA?", "personagem":"Kaua"},
				{"texto":"PUTA QUE PARIU, EU NÃO ESTAVA DELIRANDO!", "personagem":"Leticia"}
			])
		pode_tocar=true
		ScriptGlobal.etapa_cena=4
		if !ScriptGlobal.is_debuging:
			ScriptGlobal.mostrar_dica("ATENÇÃO: Você está jogando uma versão antecipada. Nem todos os personagens poderão ser desbloqueados ao longo do jogo. Caso queira liberar todos eles, ative o modo debug na aba de configurações.")
			await get_tree().create_timer(9.0).timeout
		
		ScriptGlobal.mostrar_dica("Pressione R para trocar de personagem")
		await get_tree().create_timer(5.0).timeout
		ScriptGlobal.esconder_dica()
