extends Node

func set_score(score: int):
	$Score.text = str(score) + " points"

func _on_TryAgainButton_pressed():
	print("try again")

func _on_MainMenuButton_pressed():
	print("to main menu, please")
