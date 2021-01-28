extends Node2D

export var upward_movement = 12

const base_message = ['kid clean!']
const messages = [
	'pristine kid!',
	'perfect kid!',
	'squeaky clean!',
	'spick and span!',
	'lavender scented!',
	'don limpio!',
	'shiny kid!',
	'soapy!',
	'wow!',
	'unstained!',
	'filth banished!',
	'deep scrub!',
	'cleansed kid!',
	'spotless!',
	'filth no more',
]

func _ready():
	if rand_range(0,1.0) < 0.25:
		$Message.text = base_message[randi() % base_message.size()]
	else:
		$Message.text = messages[randi() % messages.size()]
	$AnimationPlayer.play("Colors")

func _process(delta):
	self.position -= Vector2(0, upward_movement * delta)

func _on_Timer_timeout():
	queue_free()
