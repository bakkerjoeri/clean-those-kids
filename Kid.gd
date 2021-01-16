extends Node2D

export(PackedScene) var dirt_scene

func _ready():
	position = Vector2(100, 100)
	
	for n in range(4):
		var dirt = dirt_scene.instance()
		add_child(dirt)
		dirt.position = Vector2(rand_range(-16, 2), rand_range(-24, 8))
