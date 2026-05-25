extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ScriptGlobal.tem_chave:
		global_position = Vector2(2100.977, 380)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
