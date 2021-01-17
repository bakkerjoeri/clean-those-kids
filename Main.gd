extends Node

const Wave = preload("Wave.gd")
export(PackedScene) var kid_scene
export var amount_of_kids: int = 2

const combo_cooldown_default = 5

var screen_size: Vector2
var score: int = 0
var multiplier: int = 1
var combo_cooldown: float = combo_cooldown_default

var waves = []
var current_wave
var current_wave_index = 0

var current_kids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screen_size = get_viewport().size
	for k in range(1,10):
		var wave_intro = "WAVE " + str(k) + " KIDS"		
		var kids_on_screen = max((k+1)/2,1)
		waves.append(Wave.new(kids_on_screen, k, wave_intro))
	for wave in waves:
		wave.connect("add_kid", self, "add_kid")
	start_wave(0)
	

func _process(delta: float):
	runComboCooldown(delta)
	updateHud()

func add_kid():
	var kid = kid_scene.instance()
	# Set kid to random position within screen
	kid.position = (screen_size - Vector2(48,48)) * rand_range(0,1) + Vector2(24,24)
	kid.connect("kid_cleaned", self, "_on_Kid_cleaned")
	kid.connect("dirt_cleaned", self, "_on_Dirt_cleaned")
	add_child(kid)
	current_kids.append(kid)
	
func remove_old_kids():
	for kid in current_kids:
		kid.queue_free()
	current_kids.clear()	

func start_wave(var wave_index):
	remove_old_kids()
	current_wave_index = wave_index
	current_wave = waves[current_wave_index]
	current_wave.build_wave()
	$HUD.show_message(current_wave.wave_intro)

func updateHud():
	$HUD.set_score(score)
	$HUD.set_multiplier(multiplier)
	
	if (multiplier > 1):
		$HUD.set_multiplier_cooldown(combo_cooldown / combo_cooldown_default)
	else:
		$HUD.set_multiplier_cooldown(0)

func runComboCooldown(delta: float):
	if (multiplier > 1):
		combo_cooldown -= delta
	
	if (combo_cooldown <= 0):
		multiplier = 1
		combo_cooldown = combo_cooldown_default

func _on_Kid_cleaned():
	multiplier += 1
	combo_cooldown = combo_cooldown_default
	$HUD.show_message("KID CLEANED")
	current_wave.on_Kid_cleaned()
	if current_wave.is_wave_finished():
		start_wave(current_wave_index+1) 

func _on_Dirt_cleaned():
	score += multiplier
	print("+" + str(multiplier) + " -> " + str(score))
