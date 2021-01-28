extends Node2D

enum MessageState {
	INCREMENTING,
	CASHED
}

enum SoundType {
	UP,
	DOWN
}

var state = MessageState.INCREMENTING
var upward_movement: int = 12
var multiplier: int = 1
var score: int = 0
var previous_score: int = 0
var previous_multiplier: int = 0
var times_incremented: int = 0
var current_sound = SoundType.UP

func _process(delta):
	if (state == MessageState.INCREMENTING):
		if (
			multiplier != previous_multiplier
			|| score != previous_score
		):
			update_label()
			play_score_sound()
			times_incremented += 1
		
		previous_multiplier = multiplier
		previous_score = score
	
	if (state == MessageState.CASHED):
		self.position -= Vector2(0, upward_movement * delta)

func play_score_sound():
	var pitch = 1 + (0.05 * times_incremented)
	
	if (current_sound == SoundType.UP):
		$ScoreUpSound2.stop()
		$ScoreUpSound1.pitch_scale = pitch
		$ScoreUpSound1.play()
		current_sound = SoundType.DOWN
	elif (current_sound == SoundType.DOWN):
		$ScoreUpSound1.stop()
		$ScoreUpSound2.pitch_scale = pitch
		$ScoreUpSound2.play()
		current_sound = SoundType.UP

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
