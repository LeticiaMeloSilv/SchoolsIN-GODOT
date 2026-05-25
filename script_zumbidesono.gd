extends CharacterBody2D

@export var speed: float = 60
@export var follow_range: float = 800
@export var health: int = 3  

var player: Node2D
var is_attacking: bool = false
var can_take_damage: bool = true
var has_hit: bool = false
signal morreu

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
		player = get_tree().root.find_child("Personagem", true, false)

func _physics_process(delta):
	if ScriptGlobal.is_dialogando == true:
		return
	if player == null:
		buscar_player()
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, speed)
		move_and_slide()
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= 100:
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

	if is_attacking:
		return

	is_attacking = true

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
		morrer()
	else:
		await get_tree().create_timer(0.4).timeout
		can_take_damage = true

func flash_red():
	anim.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1)
	

func morrer():
	emit_signal("morreu")
	queue_free()

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "ataque":
		if $AnimatedSprite2D.frame == 16:
			var bodies = $AttackArea.get_overlapping_bodies()
			for body in bodies:
				if body.is_in_group("player"):
					ScriptGlobal.qtd_vidas -= 1
					ScriptGlobal.dano_player_flash()
		
func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "ataque":
		if hitbox: hitbox.monitoring = false
		is_attacking = false
		

		
