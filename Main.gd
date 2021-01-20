extends Node

const GameOverScreen = preload("res://GameOverScreen.tscn")
const Wave = preload("Wave.gd")
const KidType = preload("KidTypeEnum.gd").KidType
const KidCleanMessage = preload("KidCleanMessage.tscn")
const ScoreIncreaseMessage = preload("ScoreIncreaseMessage.tscn")

enum GameState {
	START,
	PLAY,
	WAVE_TRANSITION,
	GAME_OVER
}

export(PackedScene) var kid_scene
export var amount_of_kids: int = 2
export var time_start = 15
export var time_per_kid = 3
export var time_per_wave = 5

const combo_cooldown_default = 5

var current_state = GameState.START
var screen_size: Vector2
var score: int = 0
var multiplier: int = 1
var combo_cooldown: float = combo_cooldown_default
var time_left: float = time_start

var waves = []
var current_wave:Wave
var current_wave_index = 0

var current_kids = []
var startPositions:Array
var cur_start_pos_index:int

var current_score_message
var score_message_timer: float = 0
var score_message_cooldown: float = 0.75

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screen_size = get_viewport().size
	startPositions = $BorderStartPositions.get_children()
	waves = [Wave.new(1, [KidType.NORMIE], 1, "CLEAN!  THOSE!  KIDS!"),
			Wave.new(2, [KidType.NORMIE, KidType.NORMIE], 1, "WAVE 2 KIDS"),
			Wave.new(1, [KidType.NORMIE, KidType.NORMIE, KidType.NORMIE], 2, "WAVE 3 KIDS"),
			Wave.new(2, [KidType.FAST, KidType.NORMIE, KidType.FAST], 1, "2 FAST 4 KIDS"),
			Wave.new(1, [KidType.NORMIE, KidType.NORMIE, KidType.NORMIE, KidType.INFECTIOUS], 2, "WATCH OUT: DIRTY KIDS"),
			Wave.new(2, [KidType.NORMIE, KidType.EXTRA_DIRTY, KidType.FAST, KidType.INFECTIOUS], 1, "MORE KIDS FOR WAVE 6"),
			Wave.new(3, [KidType.NORMIE, KidType.FAST, KidType.NORMIE, KidType.FAST, KidType.INFECTIOUS, KidType.FAST], 2, "6 KIDS: WAVE 7 KIDS"),
			Wave.new(2, [KidType.NORMIE, KidType.NORMIE, KidType.INFECTIOUS, KidType.INFECTIOUS], 2, "WAVE 8 KIDS: DOUBLE DIRTY"),
			Wave.new(1, [KidType.FAST, KidType.FAST, KidType.FAST], 1, "WAVE 9 KIDS: BOSS WAVE IMMINENT"),
			Wave.new(2, [KidType.INFECTIOUS, KidType.EXTRA_DIRTY, KidType.INFECTIOUS, KidType.INFECTIOUS_FAST], 2, "WAVE 10 BOSS KID"),
			Wave.new(3, [KidType.INFECTIOUS, KidType.INFECTIOUS, KidType.FAST, KidType.FAST], 2, "THIS WAVE: UP TO 11"),
			Wave.new(5, [KidType.NORMIE, KidType.NORMIE, KidType.NORMIE, KidType.NORMIE, KidType.NORMIE], 2, "WAVE 12: KIDS UNENDING"),
			Wave.new(2, [KidType.EXTRA_DIRTY, KidType.NORMIE, KidType.INFECTIOUS, KidType.INFECTIOUS], 2, "CONTROL THE DIRT"),
			Wave.new(2, [KidType.EXTRA_DIRTY, KidType.NORMIE, KidType.INFECTIOUS, KidType.INFECTIOUS], 2, "BECOME THE DIRT"),
			Wave.new(2, [KidType.EXTRA_DIRTY, KidType.NORMIE, KidType.INFECTIOUS, KidType.INFECTIOUS], 2, "OVERCOME THE DIRT"),
			Wave.new(1, [KidType.DIRT_TRANSCENDED], 1, "DIRT TRANSCENDED", 0.3),
			Wave.new(1, [KidType.NORMIE, KidType.INFECTIOUS_FAST], 2, "TRANCENDENCE... BROKEN?"),
			Wave.new(3, [KidType.FAST, KidType.FAST, KidType.FAST], 2, "HOW DO I CLEAN THESE KIDS?"),
			Wave.new(2, [KidType.FAST, KidType.FAST, KidType.FAST, KidType.INFECTIOUS_FAST], 2, "2 FAST 4 KIDS 2: WAVE 19 EDITION"),
			]
	
	for wave in waves:
		wave.connect("add_kid", self, "add_kid")

	start_wave(0)

func make_random_wave(var wave_number):
	var kids_on_screen = max(log(wave_number+1),2)
	var total_kids = max(wave_number/2+4,2)	
	var wave_intro = "WAVE " + str(wave_number+1) + " KIDS"
	var kids = []
	for k in range(0, total_kids):
		var rand_val = rand_range(0,1.0) 
		if rand_val < 0.6:
			kids.append(KidType.NORMIE)
		elif rand_val < 0.9:
			kids.append(KidType.INFECTIOUS)
		else:
			kids.append(KidType.EXTRA_DIRTY)
	var wave = Wave.new(kids_on_screen, kids, 2, wave_intro)
	wave.connect("add_kid", self, "add_kid")
	waves.append(wave)
	
func _process(delta: float):
	if current_state == GameState.PLAY:
		update_time_left(delta)
		run_combo_cooldown(delta)
		
	update_hud()
	update_score_message(delta)

	if (is_game_over() && current_state != GameState.GAME_OVER):
		current_state = GameState.GAME_OVER
		var game_over_screen = GameOverScreen.instance()
		game_over_screen.set_score(score)
		self.add_child(game_over_screen)
		$HUD.hide()
		$Hand/CollisionShape2D.set_deferred("disabled", true)
		$Background.stop()

func is_game_over() -> bool:
	return time_left <= 0

func add_kid(kid_type, spawn_in_center:bool):
	var kid = kid_scene.instance()
	if self.current_wave_index == 0:
		kid.spawn_slowly = true
	if spawn_in_center:
		kid.start_pos = $CenterStartPos.position
		kid.position = Vector2(350, kid.start_pos.y)
	else:
		kid.start_pos = startPositions[cur_start_pos_index].position
		cur_start_pos_index = (cur_start_pos_index + 1) % startPositions.size()
		
		kid.position = kid.start_pos - (screen_size/2 - kid.start_pos)*1.5
	kid.connect("kid_cleaned", self, "_on_Kid_cleaned")
	kid.connect("kid_cleaned_first_time", self, "_on_Kid_cleaned_first_time")
	kid.connect("dirt_cleaned", self, "_on_Dirt_cleaned")
	kid.connect("dirt_clump_spawned", self, "_on_Dirt_spawned")
	kid.connect("kid_start_moving", self, "_on_Kid_start_moving")
	kid.set_kid_type(kid_type)
	add_child(kid)
	current_kids.append(kid)
	
func remove_old_kids():
	for kid in current_kids:
		kid.queue_free()
	current_kids.clear()

func initialize_spawn_location_order():
	self.startPositions.shuffle()
	self.cur_start_pos_index = 0

func advance_wave(wave_index:int):
	self.current_wave_index = wave_index
	if self.current_wave_index >= waves.size():
		make_random_wave(wave_index)
	self.current_wave = self.waves[current_wave_index]

func move_kids_away():
	for kid in current_kids:
		kid.leave_screen()

func end_wave(wave_index: int):
	current_state = GameState.WAVE_TRANSITION
	
	move_kids_away()
	yield(get_tree().create_timer(2), "timeout")
	remove_old_kids()
	start_wave(wave_index+1)

func start_wave(wave_index:int):
	current_state = GameState.WAVE_TRANSITION
	advance_wave(wave_index)
	Engine.time_scale = current_wave.time_scale
	initialize_spawn_location_order()
	add_time(time_per_wave)
	$HUD.show_message(current_wave.wave_intro)
	yield(get_tree().create_timer(0.5), "timeout")
	current_wave.build_wave()

func add_time(added_time):
	self.time_left += added_time
	# you can never have more than 30 seconds on the clock
	if time_left > 30:
		time_left = 30

func update_time_left(delta):
	time_left -= delta

func run_combo_cooldown(delta: float):
	if (multiplier > 1):
		combo_cooldown -= delta
	
	if (combo_cooldown <= 0):
		multiplier = 1
		combo_cooldown = combo_cooldown_default

func update_hud():
	$HUD.set_score(score)
	$HUD.set_multiplier(multiplier)
	$HUD.set_time_left(time_left)
	
	if (multiplier > 1):
		$HUD.set_multiplier_cooldown(combo_cooldown / combo_cooldown_default)
	else:
		$HUD.set_multiplier_cooldown(0)

func update_score_message(delta: float):
	if (score_message_timer <= 0 && current_score_message):
		cash_in_score_message()
	
	score_message_timer -= delta

func cash_in_score_message():
	current_score_message.cash_in()
	current_score_message = null

func all_kids_clean():
	for kid in current_kids:
		if not kid.is_clean:
			return false
	return true

func _on_Dirt_spawned():
	$ShakeCamera.shake(6)

func _on_Kid_cleaned_first_time():
	add_time(time_per_kid)

func _on_Kid_cleaned(kid):
	# Add multiplier and reset its cooldown
	multiplier += 1
	combo_cooldown = combo_cooldown_default
	# Create the message that the kid was cleaned
	var kid_cleaned_message = KidCleanMessage.instance()
	kid_cleaned_message.position = kid.position - Vector2(0, 24)
	self.add_child(kid_cleaned_message)
	# Cash in the score message
	cash_in_score_message()
	
	# Show screen flash of cleanliness
	do_kid_flash(kid.position)
	
	# Talk to the current wave
	current_wave.on_Kid_cleaned()
	if current_wave.is_wave_finished() and all_kids_clean():
		end_wave(current_wave_index)
		
func do_kid_flash(position):
	var flash = $ScreenEffect/FLASH
	flash.show()
	var tween = $ScreenEffect/Tween
	var tween2 = $ScreenEffect/Tween2
	position = position/self.screen_size
	position.y = 1-position.y
	flash.get_material().set_shader_param("center_pos", position)
	tween.interpolate_property(flash.get_material(), 
						   "shader_param/size", 
						  0.1, 0.2, 0.4, 
						   Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween2.interpolate_property(flash.get_material(), 
						   "shader_param/strength", 
						  1.0, 0.0, 0.4, 
						   Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	tween2.start()
	

func _on_Dirt_cleaned(kid):
	score += multiplier
	
	# Show the score message
	if (!self.current_score_message):
		self.current_score_message = ScoreIncreaseMessage.instance()
		self.add_child(current_score_message)
	
	self.current_score_message.position = kid.position + Vector2(0, -30)
	self.current_score_message.score += 1
	self.current_score_message.multiplier = multiplier
	self.score_message_timer = self.score_message_cooldown

func _on_Tween2_tween_completed(object, key):
	var flash = $ScreenEffect/FLASH
	flash.hide()

func _on_Kid_start_moving():
	# Start animating the backgound if it didn't yet
	$Background.play()

	if current_state == GameState.WAVE_TRANSITION:
		current_state = GameState.PLAY
