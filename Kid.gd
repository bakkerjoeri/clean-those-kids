extends Node2D

export(PackedScene) var dirt_scene

func _ready():
	for p in range(4):
		var dirt_group_position = Vector2(
			rand_range(position.x, position.x + 48),
			rand_range(position.y, position.y + 48)
		)

		for q in range(8):
			var dirt = dirt_scene.instance()
			dirt.position = dirt_group_position + Vector2(
				rand_range(-3, 3),
				rand_range(-3, 3)
			)
			add_child(dirt)
			
