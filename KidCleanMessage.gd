extends Node2D

export var upward_movement = 12

func _ready():
	$AnimationPlayer.play("Colors")

func _process(delta):
	self.position -= Vector2(0, upward_movement * delta)

func _on_Timer_timeout():
	queue_free()
