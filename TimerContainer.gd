extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var start_pos
var is_shaking
# Called when the node enters the scene tree for the first time.
func _ready():
	self.start_pos = self.position	

func set_time_left(time_left:float):
	var rounded_time = ceil(time_left)
		
	if (rounded_time == 1):
		$Timer.text = str(rounded_time) + " second "
	else:
		$Timer.text = str(rounded_time) + " seconds"
	if rounded_time <= 5 and not self.is_shaking:
		shake_start()
	if rounded_time > 5 and self.is_shaking:
		shake_stop()

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
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer2_timeout():
	self.position = self.start_pos + Vector2(randi() % 3 - 1, randi() % 3 - 1)
