extends Node

func _ready():
	Engine.time_scale = 1.0

func set_score(score: int):
	$Score.text = str(score) + " points"
	var old_high_score = get_high_score()
	if score > old_high_score:
		$Score.text += "\nNew high score!"
		save_high_score(score)
		
func get_high_score():
	var high_score = File.new()
	if not high_score.file_exists("user://highscore.save"):
		return 0
	high_score.open("user://highscore.save", File.READ)
	var score = high_score.get_line()
	return int(score)
	
func save_high_score(score: int):
	var high_score:File = File.new()
	high_score.open("user://highscore.save", File.WRITE)
	high_score.store_line(str(score))

func _on_RetryButton_pressed():
	get_tree().change_scene("res://Main.tscn")

func _on_MainMenuButton_pressed():
	get_tree().change_scene("res://StartScreen.tscn")
