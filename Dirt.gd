extends Area2D

signal cleaned

const colors = [
	Color("#2f5753"),
	Color("#283540"),
	Color("#4f1d4c"),
	Color("#781d4f"),
	Color("#52333f"),
	Color("#7d3833"),
]

var dirt_strength: int

func _ready():
	$ColorRect.color = colors[randi() % colors.size()]
	dirt_strength = randi() % 2 + 1

func _on_Dirt_area_entered(area):
	dirt_strength-=1
	if dirt_strength <= 0:
		emit_signal("cleaned")
		queue_free()
