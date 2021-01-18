extends Node2D

enum MessageState {
	INCREMENTING,
	CASHED
}

var state = MessageState.INCREMENTING
var upward_movement: int = 12
var multiplier: int = 1
var score: int = 0
var previous_score: int = 0
var previous_multiplier: int = 0

func _process(delta):
	if (state == MessageState.INCREMENTING):
		if (
			multiplier != previous_multiplier
			|| score != previous_score
		):
			update_label()
		
		previous_multiplier = multiplier
		previous_score = score
	
	if (state == MessageState.CASHED):
		self.position -= Vector2(0, upward_movement * delta)

func update_label():
	if (score > 0 && multiplier > 1):
		$ScoreLabel.text = "+" + str(score) + " x " + str(multiplier)
	elif (score > 0):
		$ScoreLabel.text = "+" + str(score)

	$ScoreAnimation.play("Bump")

func cash_in():
	self.state = MessageState.CASHED
	self.position.y -= 5
	$DestroyTimer.start()
	$ScoreLabel.text = "+" + str(score * multiplier)
	$ScoreAnimation.stop()
	$ScoreAnimation.play("Cash")


func _on_DestroyTimer_timeout():
	queue_free()
