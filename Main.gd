extends Node

const GameOverScreen = preload("res://GameOverScreen.tscn")
const Wave = preload("Wave.gd")
const KidType = preload("KidTypeEnum.gd").KidType

enum GameState {
	START,
	PLAY,
	GAME_OVER
}

export(PackedScene) var kid_scene
export var amount_of_kids: int = 2
export var time_start = 8
export var time_per_kid = 4

const combo_cooldown_default = 5

var current_state = GameState.START
var screen_size: Vector2
var score: int = 0
var multiplier: int = 1
var combo_cooldown: float = combo_cooldown_default
var time_left: float = time_start

var waves = []
var current_wave
var current_wave_index = 0

var current_kids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screen_size = get_viewport().size
	
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
		if rand_val < 0.9:
			kids.append(KidType.NORMIE)
		elif rand_val < 0.98:
			kids.append(KidType.INFECTIOUS)
		else:
			kids.append(KidType.EXTRA_DIRTTY)
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

func add_kid(kid_type):
	var kid = kid_scene.instance()
	# Set kid to random position within screen
	kid.position = (screen_size - Vector2(48,48)) * rand_range(0,1) + Vector2(24,24)
	kid.connect("kid_cleaned", self, "_on_Kid_cleaned")
	kid.connect("dirt_cleaned", self, "_on_Dirt_cleaned")
	kid.set_kid_type(kid_type)
	add_child(kid)
	current_kids.append(kid)
	
func remove_old_kids():
	for kid in current_kids:
		kid.queue_free()
	current_kids.clear()

func start_wave(var wave_index):
	remove_old_kids()
	current_wave_index = wave_index
	if current_wave_index >= waves.size():
		make_random_wave(wave_index)
	current_wave = waves[current_wave_index]
	current_wave.build_wave()
	time_left += current_wave.total_kid_count * time_per_kid
	$HUD.show_message(current_wave.wave_intro)

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

func _on_Kid_cleaned():
	multiplier += 1
	combo_cooldown = combo_cooldown_default
	$HUD.show_message("KID CLEANED")
	current_wave.on_Kid_cleaned()
	if current_wave.is_wave_finished() and all_kids_clean():
		start_wave(current_wave_index+1) 

func _on_Dirt_cleaned():
	score += multiplier
