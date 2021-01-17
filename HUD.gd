extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	show_message("WAZAAA")
	


func set_score(var score: int):
	$Score.text = str(score)

func show_message(var message):
	$Message.text = message

