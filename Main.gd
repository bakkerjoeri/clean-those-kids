extends Node

export(PackedScene) var kid_scene
export var amount_of_kids: int = 2

const combo_cooldown_default = 5

var screen_size: Vector2
var score: int = 0
var multiplier: int = 1
var combo_cooldown: float = combo_cooldown_default

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screen_size = get_viewport().size
	for _k in range(amount_of_kids):
		add_kid()

func add_kid():
	var kid = kid_scene.instance()
	# Set kid to random position within screen
	kid.position = (screen_size - Vector2(48,48)) * rand_range(0,1) + Vector2(24,24)
	kid.connect("kid_cleaned", self, "_on_Kid_cleaned")
	kid.connect("dirt_cleaned", self, "_on_Dirt_cleaned")
	add_child(kid)

func _on_Kid_cleaned():
	add_kid()
	multiplier += 1

func _on_Dirt_cleaned():
	score += multiplier
	print("+" + str(multiplier) + " -> " + str(score))
