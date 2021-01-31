extends Node2D

const FloatingMessage = preload("res://FloatingMessage.tscn")

const multiplier_colors = [
	Color("#ed7a42"),
	Color("#c68478"),
	Color("#8cbe65"),
	Color("#7b9ef0"),
]

var multiplier_previous_val = 0
var is_first_multiplier_update = true
var time_left_previous_value = 0
var is_first_time_update = true

var multiplier_true_val = 0
var multiplier_cur_val = 0

var timer_true_val = 0
var timer_cur_val = 0

var timer_max = 30
var play_letter_sound

var letters_showing
var screen_size: Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	reset_message_animation_stuff()
	
func _process(delta):
	var move_speed = 4 * (self.multiplier_true_val - self.multiplier_cur_val) * delta 
	self.multiplier_cur_val += move_speed
	set_cooldown($ComboCooldown, self.multiplier_cur_val)
	
	move_speed = 4 * (self.timer_true_val - self.timer_cur_val) * delta 
	self.timer_cur_val += move_speed

	set_cooldown($TimerCooldown, self.timer_cur_val/self.timer_max)
	
func set_cooldown(cooldown_rect, fill_percentage):
	cooldown_rect.rect_size = Vector2(
		min(100, fill_percentage * 100),
		cooldown_rect.rect_size.y
	)

	var color_selection_id = floor(fill_percentage * multiplier_colors.size())
	#if multiplier_cur_var would be exactly 1, this would end up on 1 too high
	color_selection_id = min(multiplier_colors.size()-1, color_selection_id)
	cooldown_rect.color = multiplier_colors[color_selection_id]
	
func hide():
	for child in self.get_children():
		child.hide()

func show():
	for child in self.get_children():
		child.show()

func set_score(var score: int):
	$Score.text = str(score)

func set_multiplier(var multiplier: int):
	$Multiplier.text = str(multiplier) + "x"
	
	if (multiplier - multiplier_previous_val > 0 && !is_first_multiplier_update):
		var multiplier_up_message = FloatingMessage.instance()
		multiplier_up_message.position = Vector2(88, 26)
		multiplier_up_message.set_message("+" + str(multiplier - multiplier_previous_val))
		multiplier_up_message.set_movement(8)
		self.add_child(multiplier_up_message)
	
	multiplier_previous_val = multiplier
	is_first_multiplier_update = false

func set_time_left(var time_left: float):
	$TimerContainer.set_time_left(time_left)
	
	var time_delta = ceil(time_left) - ceil(time_left_previous_value)
	if (time_delta > 0 && !is_first_time_update):		
		var time_up_message = FloatingMessage.instance()
		time_up_message.position = Vector2(226, 26)
		time_up_message.set_message("+" + str(time_delta))
		time_up_message.set_movement(8)
		self.add_child(time_up_message)
	
	self.timer_true_val = time_left
	time_left_previous_value = time_left
	is_first_time_update = false

func show_message(var message):
	var msg:Label = $MessageNode/Message
	#msg.visible_characters = 0
	msg.text = message

	var tween = $MessageNode/Message/LetterTween
	var tween_duration = get_message_anim_time(message)
	reset_message_animation_stuff()
	tween.interpolate_property($MessageNode/ColorRect, "rect_size:x", 0.0, 
							screen_size.x, 0.2, 
							Tween.TRANS_LINEAR, Tween.EASE_IN_OUT) 
	tween.interpolate_property(msg, "percent_visible", 0.0, 
							1, tween_duration, 
							Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.1)
	tween.interpolate_property($MessageNode/Message, "rect_position:x", 0.0, 
							-screen_size.x, 0.15, 
							Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.7+tween_duration) 
	tween.interpolate_property($MessageNode/ColorRect, "rect_position:x", 0.0, 
							screen_size.x, 0.15, 
							Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.8+tween_duration) 
	tween.start()
	letters_showing = true
	$MessageNode/RibbonSound.play()
	yield(get_tree().create_timer(0.1), "timeout")
	$MessageNode/LetterSound.play()
	yield(get_tree().create_timer(0.7+tween_duration), "timeout")
	$MessageNode/RibbonSound.play()

func get_message_anim_time(var message):
	return float(message.length()) / 20

func reset_message_animation_stuff():
	$MessageNode/ColorRect.rect_size.x = 0
	$MessageNode/ColorRect.rect_position.x = 0
	$MessageNode/Message.modulate.a = 1.0
	$MessageNode/Message.percent_visible = 0.0
	$MessageNode/Message.rect_position.x = 0
	$MessageNode.position.x = 0
	

func set_multiplier_cooldown(var cooldown_percentage: float):
	self.multiplier_true_val = cooldown_percentage

func _on_LetterTween_tween_completed(_object, key):
	if key == ":percent_visible":
		letters_showing = false
		

func _on_LetterSound_finished():
	if letters_showing:
		$MessageNode/LetterSound.play()
