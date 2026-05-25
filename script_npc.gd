extends Area2D

var player_perto = false
var dialogando = false
var velocidade_horizontal = 280
var gravidade = 980.0 # Valor padrão para gravidade em Godot
var forca_pulo = 450.0 # Força do pulo para superar obstáculos
@onready var character_body: CharacterBody2D = $"../NPC" # Referência ao CharacterBody2D
@onready var sprite: Sprite2D
@onready var animation_player: AnimationPlayer

var velocity = Vector2.ZERO

func _ready():
	
	if is_instance_valid(character_body):
		sprite = character_body.get_node("Sprite2D")
		animation_player = character_body.get_node("AnimationPlayer")
		character_body.z_index=3
	else:
		# Se character_body não for válido no _ready, desabilitar o processamento de física
		set_physics_process(false)

func _physics_process(delta):
	# Verificar se o character_body ainda é válido antes de tentar acessá-lo
	if not is_instance_valid(character_body):
		set_physics_process(false) # Desabilitar o processamento de física para este script
		return

	# Aplicar gravidade se não estiver no chão
	if not character_body.is_on_floor():
		velocity.y += gravidade * delta

	character_body.velocity = velocity
	character_body.move_and_slide()

func _on_body_entered(body):
	if not is_instance_valid(character_body): return # Evitar erro se o NPC já foi removido

	if body.is_in_group("player") and not dialogando:
		if(ScriptGlobal.etapa_cena==0):

			player_perto = true
			dialogando = true

			# DIÁLOGO 1
			sprite.flip_h = false

			await ScriptGlobal.iniciar_dialogo([
				{"texto":"Opa! Tudo bem? Deixa eu te perguntar uma coisa...", "personagem":"Leticia"},
				{"texto":"Vi que a porta da escada rolante está fechada. Você sabe o porquê?", "personagem":"Leticia"},
				{"texto":"Oii! Tudo sim, e você?", "personagem":"Veronica"},
				{"texto":"Ah, é normal. Você chegou muito cedo hoje.", "personagem":"Veronica"},
				{"texto":"Como não teve turno de manhã por causa da Copa, eles deixaram fechado.", "personagem":"Veronica"},
				{"texto":"Entendi... Mas tem como abrir?", "personagem":"Leticia"},
				{"texto":"Tem sim! É só pedir para algum professor abrir.", "personagem":"Veronica"},
				{"texto":"As chaves reservas ficam na sala deles.", "personagem":"Veronica"},
				{"texto":"Nossa, sério? Pior que eu passei lá na frente e não vi ninguém...", "personagem":"Leticia"},
				{"texto":"Ah, mas deve estar aberto. Assim que você entra, tem um painel no canto da sala.", "personagem":"Veronica"},
				{"texto":"No canto da sala?", "personagem":"Leticia"},
				{"texto":"Isso, no canto.", "personagem":"Veronica"},
				{"texto":"Aqui, deixa que eu vou lá pegar para você.", "personagem":"Veronica"}
			])
			monitoring = false
		# ANDAR
			await mover_ate(Vector2(850.0, 518.0))
			await get_tree().create_timer(0.5).timeout

			$CollisionShape2D.disabled = true
			character_body.visible = false
			await get_tree().create_timer(3.0).timeout
			$CollisionShape2D.disabled = false
			character_body.visible = true
			# DIÁLOGO 2
			await ScriptGlobal.iniciar_dialogo([
				{"texto":"Aqui, meu anjo.", "personagem":"Veronica"},
				{"texto":"Perfeito! Muito obrigada!", "personagem":"Leticia"},
				{"texto":"Você pode, por favor, abrir as outras lá em cima e depois devolver a chave aqui embaixo?", "personagem":"Veronica"},
				{"texto":"Posso sim! Obrigada, viu?", "personagem":"Leticia"},
				{"texto":"De nada!", "personagem":"Veronica"}
			])
			ScriptGlobal.tem_chave=true
			ScriptGlobal.recebeu_item("+1 Molho de chaves")
			await mover_ate(Vector2(3969.0, 498.908))
			monitoring = true
			
		elif ScriptGlobal.etapa_cena == 1:
			sprite.flip_h = false

			await ScriptGlobal.iniciar_dialogo([
				{"texto":"Oi de novo, tudo bem?", "personagem":"Leticia"},
				{"texto":"Me ve um café por favor?", "personagem":"Leticia"},
				{"texto":"Claro, fica R$6,25, é débito ou crédito?", "personagem":"Veronica"},
				{"texto":"É pix", "personagem":"Leticia"},
				{"texto":"Só aproximar..", "personagem":"Veronica"},
				{"texto":"...", "personagem":"Veronica"},
				{"texto":"...", "personagem":"Leticia"},
				{"texto":"Ai, foi, quer sua via?", "personagem":"Veronica"},
				{"texto":"Não precisa, obrigada, viu?", "personagem":"Leticia"},
				{"texto":"Por nada!", "personagem":"Veronica"}
			])
			monitoring = false
			ScriptGlobal.recebeu_item("+1 Café")
			await get_tree().create_timer(3.0).timeout
			await ScriptGlobal.iniciar_dialogo([
				{"texto":"Ui, ta quente...vou eperar esfriar um pouco para beber", "personagem":"Leticia"},
			])
			ScriptGlobal.etapa_cena = 2
		# REMOVER NPC
		#character_body.queue_free()
		#set_physics_process(false) # Desabilitar o processamento de física para este script

func _on_body_exited(body):
	if not is_instance_valid(character_body): return # Evitar erro se o NPC já foi removido

	if body.is_in_group("player"):
		player_perto = false
		dialogando = false # Resetar o estado de diálogo quando o player sair

func mover_ate(destino: Vector2):

	# Verificar se o character_body ainda é válido antes de tentar acessá-lo
	if not is_instance_valid(character_body): return

	var ultima_posicao = character_body.global_position
	print(ultima_posicao)
	var frames_parado = 0
	var tolerancia_x = 5.0 # Tolerância para considerar que chegou ao destino X
	
	while is_instance_valid(character_body) and abs(character_body.global_position.x - destino.x) > tolerancia_x:

		animation_player.play("correndo")

		var direcao_x = sign(destino.x - character_body.global_position.x)
		velocity.x = direcao_x * velocidade_horizontal

		# Detecta travado (se a posição não mudar significativamente e estiver no chão)
		if character_body.is_on_floor() and character_body.global_position.distance_to(ultima_posicao) < 1.0:
			frames_parado += 1
		else:
			frames_parado = 0

		ultima_posicao = character_body.global_position

		if frames_parado > 10: # Se estiver parado por muitos frames no chão
			await pular_obstaculo()
			frames_parado = 0

		await get_tree().physics_frame # Esperar pelo próximo frame de física

	# Ao sair do loop, o NPC está próximo o suficiente do destino X
	if is_instance_valid(character_body):
		sprite.flip_h = true
		velocity.x = 0 # Parar o movimento horizontal ao chegar ao destino
		animation_player.play("parado")
		
func pular_obstaculo():
	# Verificar se o character_body ainda é válido antes de tentar acessá-lo
	if not is_instance_valid(character_body): return

	animation_player.play("pulando")

	# Aplica uma força vertical para o pulo
	if character_body.is_on_floor():
		velocity.y = -forca_pulo

	# Pequeno atraso para o pulo ser visível e permitir a física agir
	await get_tree().create_timer(0.3).timeout
