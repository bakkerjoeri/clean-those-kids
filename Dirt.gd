extends Area2D

signal cleaned

const colors = [
	Color("#1f2000"),
	Color("#123631"),
	Color("#321300"),
]

var dirt_strength: int

func _ready():
	dirt_strength = randi() % 3 + 1
	$ColorRect.color = colors[dirt_strength - 1]

func _on_Dirt_area_entered(_area):
	dirt_strength-=1
	if dirt_strength <= 0:
		emit_signal("cleaned")
		queue_free()
