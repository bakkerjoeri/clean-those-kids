extends Node2D

const multiplier_colors = [
	Color("#ed7a42"),
	Color("#c68478"),
	Color("#8cbe65"),
	Color("#7b9ef0"),
]

var multiplier_true_val = 0
var multiplier_cur_var = 0
var min_speed = 0.05;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var move_speed = 4 * (self.multiplier_true_val - self.multiplier_cur_var) * delta 
	self.multiplier_cur_var += move_speed
	
	$ComboCooldown.rect_size = Vector2(
	self.multiplier_cur_var * 120,
	$ComboCooldown.rect_size.y
	)
	var color_selection_id = floor(self.multiplier_cur_var * multiplier_colors.size())
	#if multiplier_cur_var would be exactly 1, this would end up on 1 too high
	color_selection_id = min(multiplier_colors.size()-1, color_selection_id)
	$ComboCooldown.color = multiplier_colors[color_selection_id]
	
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

func set_time_left(var time_left: float):
	$TimerContainer.set_time_left(time_left)

func show_message(var message):
	$MessageNode/Message.text = message
	$MessageNode/Message/AnimationPlayer.play("ShowMessage")

func set_multiplier_cooldown(var cooldown_percentage: float):
	self.multiplier_true_val = cooldown_percentage
