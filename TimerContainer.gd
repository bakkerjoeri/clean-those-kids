extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const low_on_time_threshold = 5

var start_pos
var is_shaking
var rounded_time
# Called when the node enters the scene tree for the first time.
func _ready():
	self.start_pos = self.position	
	rounded_time = 15

func set_time_left(time_left:float):
	rounded_time = ceil(time_left)
		
	if (rounded_time == 1):
		$Timer.text = str(rounded_time) + " second "
	else:
		$Timer.text = str(rounded_time) + " seconds"
	if rounded_time <= low_on_time_threshold and not self.is_shaking:
		play_low_time_sound()
		shake_start()
	if rounded_time > low_on_time_threshold and self.is_shaking:
		shake_stop()
		$LowOnTimeSound.stop()

func shake_start():
	$AnimationPlayer.play("Flash")
	$Timer2.start()
	is_shaking = true
	
func shake_stop():
	$AnimationPlayer.stop(true)
	$Timer.set("custom_colors/font_color", Color(0,0,0))
	$Timer2.stop()
	self.position = self.start_pos
	is_shaking = false
	
	

func play_low_time_sound():
	var added_pitch =0.4* (low_on_time_threshold-float(rounded_time))/low_on_time_threshold
	if added_pitch >= 0: #check whether we're still on low time before running
		$LowOnTimeSound.pitch_scale = 1 + added_pitch
		$LowOnTimeSound.play()

func _on_Timer2_timeout():
	self.position = self.start_pos + Vector2(randi() % 3 - 1, randi() % 3 - 1)


func _on_LowOnTimeSound_finished():
	if rounded_time > 0 and rounded_time <= 5:
		yield(get_tree().create_timer(0.5), "timeout")
		play_low_time_sound()
