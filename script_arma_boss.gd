extends Area2D

@export var speed: float = 50
var direction = 1

func _ready():
	add_to_group("enemy_projectile")
	
func _process(delta: float) -> void:
	# gira o sprite
	rotation += 15 * delta
	if (direction==1): #vai para direita
		global_position.x += speed
		$Sprite2D.flip_v = false
	else:
		global_position.x -= speed
		$Sprite2D.flip_v = true
		
func _on_body_entered(body):
	if body.is_in_group("player"):
		ScriptGlobal.qtd_vidas -= 1
		ScriptGlobal.dano_player_flash()
		queue_free()
