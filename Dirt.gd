extends Area2D

const colors = [
	Color("#2f5753"),
	Color("#283540"),
	Color("#4f1d4c"),
	Color("#781d4f"),
	Color("#52333f"),
	Color("#7d3833"),
]

func _ready():
	$ColorRect.color = colors[randi() % colors.size()]

func _on_Dirt_area_entered(area):
	print("Dirt be scrubbed from area")
