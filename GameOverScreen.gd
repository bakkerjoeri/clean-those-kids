extends Node

func set_score(score: int):
	$Score.text = str(score) + " points"

func _on_TryAgainButton_pressed():
	get_tree().change_scene("res://Main.tscn")

func _on_MainMenuButton_pressed():
	get_tree().change_scene("res://StartScreen.tscn")
