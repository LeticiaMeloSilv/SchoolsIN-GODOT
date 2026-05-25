extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# =========================
# CONFIGURAÇÕES DO P1
# =========================
var velocidade = 500
var forca_pulo = -900
var gravidade = 2400.0

var ativo = false
var is_attacking := false
var current_anim := ""

func _ready() -> void:
	z_index = 2

func _physics_process(delta: float) -> void:

	# =========================
	# GRAVIDADE
	# =========================
	if not is_on_floor():
		velocity.y += gravidade * delta

	# =========================
	# GAME OVER
	# =========================
	if ScriptGlobal.qtd_vidas == 0:
		get_tree().change_scene_to_file("res://cena_game_over.tscn")

	# =========================
	# BLOQUEIA CONTROLES NO DIÁLOGO
	# =========================
	if ScriptGlobal.is_dialogando:

		velocity.x = 0

		is_attacking = false
		$Area2D/CollisionShape2D.disabled = true

		if is_on_floor():
			play_anim("idle")

	# =========================
	# CONTROLES
	# =========================
	elif ativo:

		var direction = Input.get_axis("ui_left", "ui_right")

		velocity.x = direction * velocidade

		# =========================
		# DIREÇÃO DO PERSONAGEM
		# =========================
		if direction < 0:
			anim.flip_h = false

		elif direction > 0:
			anim.flip_h = true

		# =========================
		# PULO
		# =========================
		if Input.is_action_just_pressed("ui_up") and is_on_floor():
			velocity.y = forca_pulo

		# =========================
		# ATAQUE
		# =========================
			
		if Input.is_action_just_pressed("atirar") and is_on_floor() and not is_attacking:
			is_attacking = true
			if anim.flip_h:
				$Area2D.position.x = abs($Area2D.position.x)
			else:
				$Area2D.position.x = -abs($Area2D.position.x)
			play_anim("atirando")
			$Area2D/CollisionShape2D.disabled = false
			if is_in_group("atiradores"):
				spawnar_livro()

		# =========================
		# TRAVA MOVIMENTO DURANTE ATAQUE
		# =========================
		if is_attacking:
			velocity.x = 0

		# =========================
		# ANIMAÇÕES
		# =========================
		if not is_attacking:

			if not is_on_floor():
				play_anim("pulando")

			elif abs(direction) > 0:
				play_anim("correndo")

			else:
				play_anim("idle")

	else:
		velocity.x = 0
		play_anim("idle")

	move_and_slide()

	# =========================
	# LIMITES DA CÂMERA
	# =========================
	# ALTERE OS VALORES SE NECESSÁRIO
	# =========================
	$Camera2D.limit_left = 0
	$Camera2D.limit_top = 0
	$Camera2D.limit_right = 4500
	$Camera2D.limit_bottom = 670

func _on_animated_sprite_2d_animation_finished():

	if current_anim == "atirando":

		is_attacking = false
		$Area2D/CollisionShape2D.disabled = true

		if abs(velocity.x) > 0:
			play_anim("correndo")
		else:
			play_anim("idle")
			
func spawnar_livro():

	var cena_livro = preload("res://cena_livro.tscn")
	var objeto_livro = cena_livro.instantiate()

	if anim.flip_h:
		objeto_livro.get_node("Area2D").direcao = 1
	else:
		objeto_livro.get_node("Area2D").direcao = -1

	# =========================
	# ADICIONA NA CENA
	# =========================
	get_parent().add_child(objeto_livro)

	# =========================
	# POSIÇÃO DA FACA
	# =========================
	objeto_livro.global_position =  $Marker2D.global_position

func play_anim(name: String):
	if current_anim == name:
		return

	current_anim = name

	match name:
		"idle":
			anim.scale = Vector2(0.372, 0.360)
		"correndo":
			anim.scale = Vector2(0.363, 0.348)
		"pulando":
			anim.scale = Vector2(0.408, 0.407)
		"atirando":
			anim.scale = Vector2(0.408, 0.407)
	anim.play(name)

func eliminar_inimigo(body: Node2D) -> void:
	if body.is_in_group("enemy") or body.has_method("take_damage"):
		if body.has_method("take_damage"):
			body.take_damage()
		else:
			body.queue_free()
