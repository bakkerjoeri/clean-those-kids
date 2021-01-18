extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func hide():
	for child in self.get_children():
		child.hide()

func show():
	for child in self.get_children():
		child.show()

func set_score(var score: int):
	$Score.text = str(score)

func set_multiplier(var multiplier: int):
	$Multiplier.text = str(multiplier) + "x"

func set_time_left(var time_left: float):
	$TimerContainer.set_time_left(time_left)

func show_message(var message):
	$Message.text = message
	$Message/AnimationPlayer.play("ShowMessage")

func set_multiplier_cooldown(var cooldown_percentage: float):
	$ComboCooldown.rect_size = Vector2(
		cooldown_percentage * 120,
		$ComboCooldown.rect_size.y
	)
