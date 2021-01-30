extends Node



func _ready():
	randomize()
	randomly_init_kids()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$ScoreLabel.text = "High score: " + get_high_score()
	$Background.play()
	OS.set_window_maximized(true)
	
func randomly_init_kids():
	var screen_size = get_viewport().size
	var face_indices = range(0,$Kids/Kid/Face.frames.get_frame_count("default")-1)
	face_indices.shuffle()
	var cur_index = 0
	for kid in $Kids.get_children():
		kid.get_node("Face").set_frame(face_indices[cur_index])
		cur_index += 1
		kid.position = Vector2(rand_range(24, screen_size.x-24), rand_range(24, screen_size.y-24))	

func _on_StartGameButton_pressed():
	get_tree().change_scene("res://Main.tscn")

func get_high_score():
	var high_score = File.new()
	if not high_score.file_exists("user://highscore.save"):
		return "0"
	high_score.open("user://highscore.save", File.READ)
	var score = high_score.get_line()
	return score


func _on_TextureButton_pressed():
	$TextureButton.disabled = true
	$TextureButton/ButtonPressedSound.play()
	for kid in $Kids.get_children():
		kid.cleaning_timer = 100
		kid.leave_screen(0.4, 500)
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://Main.tscn")
