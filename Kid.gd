extends Node2D

export(PackedScene) var dirt_scene
export var number_of_dirt_spots: int = 4
export var dirt_per_spot: int = 8

export var min_speed: int = 10
export var max_speed: int = 30

var my_dirts = 0
var is_clean = false
var velocity: Vector2
var screen_size: Vector2

func _ready():
	for p in range(number_of_dirt_spots):
		var dirt_group_position = Vector2(
			rand_range(-22, 22),
			rand_range(-22, 22)
		)

		for q in range(dirt_per_spot):
			var dirt = dirt_scene.instance()
			dirt.position = dirt_group_position + Vector2(
				rand_range(-3, 3),
				rand_range(-3, 3)
			)
			add_child(dirt)
			my_dirts += 1
			dirt.connect("cleaned", self, "_on_Dirt_cleaned")
			
	var direction = rand_range(-PI, PI)
	velocity = Vector2(rand_range(min_speed, max_speed), 0).rotated(direction)
	screen_size = get_viewport_rect().size

func _process(delta):
	if my_dirts == 0 && !is_clean:
		is_clean = true
		print("PERFECT KID!")
	move_around(delta)

func move_around(delta):
	position += velocity * delta
	if position.x < 24 or position.x > screen_size.x - 48:
		velocity.x = -velocity.x
	if position.y < 24 or position.y > screen_size.y - 48:
		velocity.y = -velocity.y
	

func _on_Dirt_cleaned():
	my_dirts -= 1
	print("bye bye dirt, new dirt count is " + str(my_dirts))
	
