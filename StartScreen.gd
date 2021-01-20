extends Node

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$ScoreLabel.text = "High score: " + get_high_score()
	$Background.play()
	
func _on_StartGameButton_pressed():
	get_tree().change_scene("res://Main.tscn")

func get_high_score():
	var high_score = File.new()
	if not high_score.file_exists("user://highscore.save"):
		return "0"
	high_score.open("user://highscore.save", File.READ)
	var score = high_score.get_line()
	return score
