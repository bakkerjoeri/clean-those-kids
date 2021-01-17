extends Node


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_StartGameButton_pressed():
	get_tree().change_scene("res://Main.tscn")
