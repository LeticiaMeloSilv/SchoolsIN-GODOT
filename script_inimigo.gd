extends CharacterBody2D
var gravidade   = 30
var forcao_pulo = 600
var velocidade = 600
@export var comportamento = 1

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	
	if(comportamento==1):
		comportamento1()
	elif (comportamento==2):
		comportamento2()
	elif (comportamento==3):
		comportamento3()
	move_and_slide()
	
func comportamento1(): # Faz o inimigo simplesmente ir para cima e para baixo, ficar pulando
	velocity.y += gravidade
	if (is_on_floor()):
		velocity.y = -forcao_pulo
	
func comportamento2(): # Fazer o inimigo ir pular para frente e para trás
	velocity.y += gravidade
	if (is_on_floor()):
		velocity.y = -forcao_pulo
		velocidade = velocidade * -1
		velocity.x = velocidade
	
func comportamento3(): # fazer o inimigo perseguir o personagem 
	velocity.y += gravidade
	if (is_on_floor()):
		#get_tree().root.print_tree() # Mostra o caminho de todos os nós que estão ativos atualmente no jogo
		#get_tree().root.get_node("") # Permite acessar qualquer nó, bastar informar o caminho
		var personagem = get_tree().root.get_node("Fase1/Personagem/CharacterBody2D") # Permite acessar qualquer nó, bastar informar o caminho
		var posx_personagem = personagem.global_position.x
		var posx_inimigo    = global_position.x
		velocidade = 100
		if (posx_inimigo<posx_personagem):
			velocity.x = velocidade 
		elif (posx_inimigo>posx_personagem):
			velocity.x = -velocidade
		else:
			velocity.x = 0
	

func atacar_personagem(body: Node2D) -> void:
	if (body.name=="Personagem"):
		ScriptGlobal.qtd_vidas -= 1
	
	
	
	
	
	
