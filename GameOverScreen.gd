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
	var new_scene = load("res://Main.tscn").instance()
	new_scene.set_name("Main")
	start_new_scene(new_scene)

func _on_MainMenuButton_pressed():
	start_screen_transition()
	yield(get_tree().create_timer(1), "timeout")
	var new_scene = load("res://StartScreen.tscn").instance()
	start_new_scene(new_scene)
	
func start_new_scene(scene):
	get_node("/root/MainNode").add_child(scene)
	get_node("/root/MainNode/").find_node("*Main*", false, false).queue_free()
	queue_free()
	
	
func start_screen_transition():
	$RetryButton.disabled = true
	$MainMenuButton.disabled = true
	$ButtonPressedSound.play()
	var main_node = get_node("/root/MainNode/").find_node("*Main*", false, false)
	for kid in main_node.get_node("KidHolder").get_children():
		kid.cleaning_timer = 100
		kid.leave_screen(0.4, 500)
