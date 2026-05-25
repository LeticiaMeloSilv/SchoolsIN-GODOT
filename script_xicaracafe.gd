extends CharacterBody2D

@export var speed: float = 100
@export var jump_speed: float = 800 # Velocidade do bote diagonal
@export var follow_range: float = 500
@export var health: int = 1

var player: Node2D
var is_attacking: bool = false
var can_take_damage: bool = true
var has_hit: bool = false
var attack_velocity: Vector2 = Vector2.ZERO # Armazena a direção do bote

@onready var anim = $AnimatedSprite2D
@onready var hitbox = $AttackArea

func _ready():
	add_to_group("enemy")
	buscar_player()
	if hitbox:
		hitbox.monitoring = false

func buscar_player():
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		var nodes = get_tree().root.find_children("Personagem", "CharacterBody2D", true, false)
		for node in nodes:
			if node.has_method("take_damage"):
				player = node
				player.add_to_group("player")
				break

func _physics_process(delta):
	if !$AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.play()
	if ScriptGlobal.is_dialogando == true:
		return
	if player == null:
		buscar_player()
		return

	if is_attacking:
		# FORÇA o movimento na direção do bote sem interferência
		velocity = attack_velocity
		move_and_slide()
		return

	# Gravidade normal fora do ataque
	if not is_on_floor():
		velocity += get_gravity() * delta

	var distance = global_position.distance_to(player.global_position)

	if distance <= 400: 
		attack()
	elif distance <= follow_range:
		follow_player()
	else:
		idle()

	move_and_slide()

func follow_player():
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * speed
	anim.flip_h = direction > 0
	anim.play("running")

func attack():
	if is_attacking: return
	is_attacking = true
	has_hit = false
	
	# Calcula a direção diagonal exata e trava ela
	var direction = (player.global_position - global_position).normalized()
	attack_velocity = direction * jump_speed
	
	anim.flip_h = direction.x > 0
	anim.play("ataque")
	
	if hitbox:
		hitbox.monitoring = true

func idle():
	velocity.x = move_toward(velocity.x, 0, speed)
	anim.play("idle")

func take_damage():
	if not can_take_damage: return
	can_take_damage = false
	health -= 1
	flash_red()
	if health <= 0:
		queue_free()
	else:
		await get_tree().create_timer(0.4).timeout
		can_take_damage = true

func flash_red():
	anim.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1)

func _on_attack_area_body_entered(body):
	anim.animation == "ataque" 
	if body.is_in_group("player"):
		ScriptGlobal.qtd_vidas -= 1
		ScriptGlobal.dano_player_flash()
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "ataque":
		# Se terminar o bote e não te atingir, ele volta ao normal
		is_attacking = false
		attack_velocity = Vector2.ZERO
		if hitbox:
			hitbox.monitoring = false
