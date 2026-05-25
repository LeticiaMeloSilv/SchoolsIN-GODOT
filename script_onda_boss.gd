extends Area2D

@export var speed: float = 600
@export var max_size: float = 6.0
@export var grow_speed: float = 6.0
@export var life_time: float = 0.6

var direction := 1
var current_scale := 1.0

func _ready():
	add_to_group("enemy_projectile")

	# começa pequena no impacto
	scale = Vector2(0.2, 1)

	await get_tree().create_timer(life_time).timeout
	queue_free()


func _physics_process(delta):
	# EXPANSÃO (efeito onda)
	current_scale += grow_speed * delta
	scale.x = current_scale

	# limita tamanho
	if current_scale >= max_size:
		queue_free()

	# move levemente para dar sensação de impacto
	position.x += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		ScriptGlobal.qtd_vidas -= 1
		ScriptGlobal.dano_player_flash()
		
