extends CanvasLayer

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




func set_multiplier_cooldown(var cooldown_percentage: float):
	$ComboCooldown.rect_size = Vector2(
		cooldown_percentage * 235,
		$ComboCooldown.rect_size.y
	)
