extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func set_score(var score: int):
	$Score.text = str(score)

func set_multiplier(var multiplier: int):
	$Multiplier.text = str(multiplier) + "x"

func show_message(var message):
	$Message.text = message
	$Message/AnimationPlayer.play("ShowMessage")




