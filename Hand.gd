extends Node2D

func _process(delta: float):
	position = get_global_mouse_position()
	$CollisionShape2D.set_deferred("disabled", !Input.is_action_pressed("ui_clean"))
