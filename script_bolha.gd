extends Area2D

signal bubble_clicked(success, key_idx, pos)

var key_idx = 0
var keys = ["left", "up", "right"]
var key_labels = ["A", "W", "D"]
var lifetime = 1.0
var timer = 0.0

func _ready():
	$Label.text = key_labels[key_idx]

	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)

	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, 50, Color.DARK_ORANGE)

func _process(delta):
	timer += delta

	$ProgressBar.value = (1.0 - (timer / lifetime)) * 100

	if timer >= lifetime:
		emit_signal("bubble_clicked", false, key_idx, position)
		queue_free()

func _input(event):
	if event.is_action_pressed(keys[key_idx]):
		emit_signal("bubble_clicked", true, key_idx, position)
		queue_free()
