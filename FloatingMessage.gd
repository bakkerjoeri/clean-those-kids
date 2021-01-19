extends Node2D

var vertical_movement = 12

func _ready():
	$AnimationPlayer.play("Colors")

func set_message(text: String):
	$Message.text = text
	
func set_movement(amount: int):
	vertical_movement = amount

func _process(delta):
	self.position += Vector2(0, vertical_movement * delta)

func _on_Timer_timeout():
	queue_free()
