extends Node2D

export var upward_movement = 12

const messages = [
	'kid clean!',
	'pristine kid!',
	'perfect kid!',
	'squeaky clean!',
	'spick and span!',
	'lavender scented!',
	'don limpio!',
	'shiny kid!',
]

func _ready():
	$Message.text = messages[randi() % messages.size()]
	$AnimationPlayer.play("Colors")

func _process(delta):
	self.position -= Vector2(0, upward_movement * delta)

func _on_Timer_timeout():
	queue_free()
