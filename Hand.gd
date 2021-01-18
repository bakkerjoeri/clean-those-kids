extends Node2D

var cleaning_timer_duration: float = 0.5
var cleaning_timer: float = 0

func _process(delta: float):
	position = get_global_mouse_position()

	if (cleaning_timer > 0):
		$DropsLeft.emitting = true
		$DropsRight.emitting = true
		cleaning_timer -= delta
	else:
		$DropsLeft.emitting = false
		$DropsRight.emitting = false

func _on_Hand_area_entered(area):
	cleaning_timer = cleaning_timer_duration
	
