extends Node

const GameOverScreen = preload("res://GameOverScreen.tscn")
const Wave = preload("Wave.gd")
const KidType = preload("KidTypeEnum.gd").KidType
const KidCleanMessage = preload("KidCleanMessage.tscn")

enum GameState {
	START,
	PLAY,
	GAME_OVER
}

export(PackedScene) var kid_scene
export var amount_of_kids: int = 2
export var time_start = 8
export var time_per_kid = 2
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

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screen_size = get_viewport().size
	startPositions = $BorderStartPositions.get_children()
	waves = [Wave.new(1, [KidType.NORMIE], "CLEAN!  THOSE!  KIDS!"),
			Wave.new(2, [KidType.NORMIE, KidType.NORMIE], "WAVE 2 KIDS"),
			Wave.new(1, [KidType.NORMIE, KidType.NORMIE, KidType.INFECTIOUS], "WAVE 3 KIDS"),
			Wave.new(2, [KidType.NORMIE, KidType.EXTRA_DIRTY, KidType.INFECTIOUS, KidType.INFECTIOUS], "WAVE 4 GET READY"),
			Wave.new(2, [KidType.INFECTIOUS, KidType.EXTRA_DIRTY, KidType.INFECTIOUS, KidType.INFECTIOUS], "WAVE 5 BOSS KID")]
	
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
	var wave = Wave.new(kids_on_screen, kids, wave_intro)
	wave.connect("add_kid", self, "add_kid")
	waves.append(wave)
	
func _process(delta: float):
	update_time_left(delta)
	run_combo_cooldown(delta)
	update_hud()

	if (is_game_over() && current_state != GameState.GAME_OVER):
		current_state = GameState.GAME_OVER
		print("Joe, ge bende game over")
		var game_over_screen = GameOverScreen.instance()
		game_over_screen.set_score(score)
		self.add_child(game_over_screen)
		$HUD.hide()
		$Hand/CollisionShape2D.set_deferred("disabled", true)

func is_game_over() -> bool:
	return time_left <= 0

func add_kid(kid_type, spawn_in_center:bool):
	var kid = kid_scene.instance()
	kid.spawn_slowly = true if self.current_wave_index == 0 else false
	if spawn_in_center:
		kid.start_pos = $CenterStartPos.position
		kid.position = Vector2(350, kid.start_pos.y)
	else:
		kid.start_pos = startPositions[cur_start_pos_index].position
		cur_start_pos_index = (cur_start_pos_index + 1) % startPositions.size()
		
		kid.position = kid.start_pos - (screen_size/2 - kid.start_pos)*1.5
	kid.connect("kid_cleaned", self, "_on_Kid_cleaned")
	kid.connect("dirt_cleaned", self, "_on_Dirt_cleaned")
	kid.connect("dirt_clump_spawned", self, "_on_Dirt_spawned")
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

func start_wave(wave_index:int):
	remove_old_kids()
	advance_wave(wave_index)
	initialize_spawn_location_order()
	time_left += current_wave.total_kid_count * time_per_kid + time_per_wave
	$HUD.show_message(current_wave.wave_intro)
	yield(get_tree().create_timer(0.5), "timeout")
	current_wave.build_wave()

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

func all_kids_clean():
	for kid in current_kids:
		if not kid.is_clean:
			return false
	return true

func _on_Dirt_spawned():
	$ShakeCamera.shake(6)

func _on_Kid_cleaned(kid):
	# Add multiplier and reset its cooldown
	multiplier += 1
	combo_cooldown = combo_cooldown_default
	
	# Create the message that the kid was cleaned
	var kid_cleaned_message = KidCleanMessage.instance()
	kid_cleaned_message.position = kid.position - Vector2(0, 24)
	self.add_child(kid_cleaned_message)
	
	# Show screen flash of cleanliness
	do_kid_flash(kid.position)
	
	# Talk to the current wave
	current_wave.on_Kid_cleaned()
	if current_wave.is_wave_finished() and all_kids_clean():
		start_wave(current_wave_index+1) 
		
func do_kid_flash(position):
	print("flash")
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
	

func _on_Dirt_cleaned():
	score += multiplier


func _on_Tween2_tween_completed(object, key):
	var flash = $ScreenEffect/FLASH
	flash.hide()
