extends Node2D

func _ready():
	randomize()
	$AnimatedSprite.set_frame(randi() % $AnimatedSprite.frames.get_frame_count("default"))
