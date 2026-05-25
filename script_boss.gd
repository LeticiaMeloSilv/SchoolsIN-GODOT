extends CharacterBody2D

# Configurações do Boss
@export var max_health: int = 10
@export var speed: float = 250
@export var jump_velocity: float = 900

var health: int = max_health
var player: Node2D = null
var is_dead: bool = false
var can_take_damage: bool = true
var state: String = "IDLE"
var attack_cooldown: float = 0.0
var fade: ColorRect

@onready var anim = $AnimatedSprite2D

var weapon_scene = preload("res://cena_arma_boss.tscn") 
var shockwave_scene = preload("res://cena_onda_boss.tscn") 

func _ready():
	add_to_group("enemy")
	health = max_health
	buscar_player()

func buscar_player():
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		var nodes = get_tree().root.find_children("Personagem", "CharacterBody2D", true, false)
		for node in nodes:
			if node.has_method("take_damage"):
				player = node
				break

func _physics_process(delta):
	if ScriptGlobal.is_dialogando == true:
		return
	if is_dead: return
	if player == null:
		buscar_player()
		return

	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	attack_cooldown -= delta
	
	if state == "JUMP_ATTACK":
		if is_on_floor():
			shake_screen()
			spawn_shockwaves()
			finish_attack(2.5)

	match state:
		"IDLE":
			handle_idle_state()
		"CHASE":
			handle_chase_state()
		"ATTACKING":
			velocity.x = move_toward(velocity.x, 0, 10)

	move_and_slide()

func handle_idle_state():
	anim.play("idle")
	velocity.x = 0
	if global_position.distance_to(player.global_position) < 600:
		state = "CHASE"

func handle_chase_state():
	var dist = global_position.distance_to(player.global_position)
	var dir = sign(player.global_position.x - global_position.x)
	
	velocity.x = dir * speed
	anim.flip_h = dir < 0
	anim.play("running")

	if attack_cooldown <= 0:
		decide_attack(dist)

func decide_attack(dist):
	var r = randf()
	if dist < 150:
		perform_melee_attack()
	elif dist < 400:
		if r < 0.5:
			perform_throw_attack()
		else:
			perform_jump_attack()
	else:
		perform_throw_attack()

# --- ATAQUE 1: MELEE (Perto) ---
func perform_melee_attack():
	state = "ATTACKING"
	anim.play("ataque")
	await get_tree().create_timer(0.4).timeout
	if global_position.distance_to(player.global_position) > 130:
		ScriptGlobal.qtd_vidas -= 1
	finish_attack(0.5)

# --- ATAQUE 2: ARREMESSO (Distância) ---
func perform_throw_attack():
	state = "ATTACKING"
	anim.play("ataque") 
	await get_tree().create_timer(0.3).timeout
	
	var weapon_container = weapon_scene.instantiate()

	get_parent().add_child(weapon_container)

	weapon_container.global_position = global_position + Vector2(0, -20)

	var weapon = weapon_container.get_node("Area2D")

	if player.global_position.x > global_position.x:
		weapon.direction = 1
	else:
		weapon.direction = -1
		
	finish_attack(2.0)

# --- ATAQUE 3: PULO E ONDA (Impacto) ---
func perform_jump_attack():
	state = "JUMP_ATTACK"
	velocity.y = -jump_velocity
	velocity.x = 0
	anim.play("jump")
	
func spawn_shockwaves():	
	var wave_container = shockwave_scene.instantiate()
	get_parent().add_child(wave_container)
	wave_container.global_position = global_position + Vector2(0, -20)

	var wave = wave_container.get_node("Area2D")
	
	wave.global_position = $Marker2D.global_position
	wave.direction = 0

func shake_screen():
	var camera = get_viewport().get_camera_2d()
	if camera:
		for i in 10:
			camera.offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
			await get_tree().create_timer(0.05).timeout
		camera.offset = Vector2.ZERO

func finish_attack(cooldown):
	attack_cooldown = cooldown
	state = "IDLE"

func take_damage():
	if is_dead or not can_take_damage: return
	
	health -= 1
	
	flash_red()
	
	if health <= 0:
		die()

	else:
		can_take_damage = false
		await get_tree().create_timer(0.2).timeout
		can_take_damage = true

func flash_red():
	anim.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1)

func die():
	is_dead = true
	anim.play("die")
	ScriptGlobal.is_dialogando = true

	await get_tree().create_timer(4.0).timeout

	var canvas = CanvasLayer.new()
	canvas.layer = 100

	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0

	fade.anchor_left = 0
	fade.anchor_top = 0
	fade.anchor_right = 1
	fade.anchor_bottom = 1

	canvas.add_child(fade)
	get_tree().root.add_child(canvas)

	# fade para preto
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 3.0)

	await tween.finished

	get_tree().change_scene_to_file("res://cena_creditos.tscn")

func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "ataque":
		if state == "ATTACKING": state = "IDLE"
