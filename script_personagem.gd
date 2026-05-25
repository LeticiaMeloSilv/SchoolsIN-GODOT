extends CharacterBody2D

var velocidade = 500
var forca_pulo = 900
var gravidade  = 40

@export var animando = false

func _ready() -> void:
	z_index = 2

func _process(delta: float) -> void:
	velocity.x = 0
	velocity.y += gravidade

	if ScriptGlobal.qtd_vidas == 0:
		get_tree().change_scene_to_file("res://cena_game_over.tscn")

	# =========================
	# BLOQUEIA CONTROLES NO DIÁLOGO
	# =========================
	if ScriptGlobal.is_dialogando:
		velocity.x = 0

		if is_on_floor():
			$AnimationPlayer.play("parado")

	else:
		# =========================
		# MOVIMENTO
		# =========================
		if Input.is_action_pressed("ui_left"):
			velocity.x = -velocidade
			$Sprite2D.flip_h = true
			$Marker2D.position.x = -1 * abs($Marker2D.position.x)
			$Area2D.position.x = -1 * abs($Area2D.position.x)

		if Input.is_action_pressed("ui_right"):
			velocity.x = velocidade
			$Sprite2D.flip_h = false
			$Marker2D.position.x = abs($Marker2D.position.x)
			$Area2D.position.x = abs($Area2D.position.x)

		if Input.is_action_just_pressed("ui_up") and is_on_floor():
			velocity.y = -forca_pulo
			animando = false

		if Input.is_action_pressed("disparar") and is_on_floor():
			animando = true
			$AnimationPlayer.play("atirando")

		if Input.is_action_just_pressed("atacar") and is_on_floor():
			animando = true
			$AnimationPlayer.play("atacando")

	# =========================
	# TRAVA MOVIMENTO DURANTE ATAQUE
	# =========================
	var anim_atual = $AnimationPlayer.current_animation

	if anim_atual == "atirando" or anim_atual == "atacando":
		velocity.x = 0

	# =========================
	# ANIMAÇÕES
	# =========================
	if not animando and not ScriptGlobal.is_dialogando:
		if is_on_floor():
			if velocity.x == 0:
				$AnimationPlayer.play("parado")
			else:
				$AnimationPlayer.play("correndo")
		else:
			$AnimationPlayer.play("pulando")

	move_and_slide()

	# =========================
	# LIMITES DA CÂMERA
	# =========================
	$Camera2D.limit_left = 0
	$Camera2D.limit_top = 0
	$Camera2D.limit_right = 4500
	$Camera2D.limit_bottom = 670

func spawnar_faca():
	var cena_faca = preload("res://cena_faca.tscn")
	var objeto_faca = cena_faca.instantiate()

	if not $Sprite2D.flip_h:
		objeto_faca.get_node("Area2D").direcao = 1
	else:
		objeto_faca.get_node("Area2D").direcao = -1

	add_sibling(objeto_faca)
	objeto_faca.global_position = $Marker2D.global_position

func eliminar_inimigo(body: Node2D) -> void:
	if body.is_in_group("enemy") or body.has_method("take_damage"):
		if body.has_method("take_damage"):
			body.take_damage()
		else:
			body.queue_free()
