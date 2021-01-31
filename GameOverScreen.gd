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
	start_screen_transition()
	yield(get_tree().create_timer(1), "timeout")
	start_new_scene("res://Main.tscn")

func _on_MainMenuButton_pressed():
	start_screen_transition()
	yield(get_tree().create_timer(1), "timeout")
	start_new_scene("res://StartScreen.tscn")
	
func start_new_scene(scene_name):
	var mainScene = load(scene_name).instance()
	get_node("/root/MainNode").add_child(mainScene)
	get_node("/root/MainNode/Main").queue_free()
	queue_free()
	
	
func start_screen_transition():
	$RetryButton.disabled = true
	$MainMenuButton.disabled = true
	$ButtonPressedSound.play()
	for kid in get_node("/root/MainNode/Main/KidHolder").get_children():
		kid.cleaning_timer = 100
		kid.leave_screen(0.4, 500)
