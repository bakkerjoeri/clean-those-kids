extends Node2D

signal kid_cleaned
signal dirt_cleaned

export(PackedScene) var dirt_scene
export var number_of_dirt_spots: int = 4
export var dirt_per_spot: int = 16

export var min_speed: int = 30
export var max_speed: int = 50

var my_dirts = 0
var is_clean = false
var velocity: Vector2
var screen_size: Vector2

func _ready():
	# Choose a face!
	$AnimatedSprite.set_frame(randi() % $AnimatedSprite.frames.get_frame_count("default"))
	
	for p in range(number_of_dirt_spots):
		var dirt_group_position = Vector2(
			randi() % 45 - 22,
			randi() % 45 - 22
		)
		build_dirt(dirt_group_position)

	var direction = rand_range(-PI, PI)
	velocity = Vector2(rand_range(min_speed, max_speed), 0).rotated(direction)
	screen_size = get_viewport_rect().size

func is_unoccupied_position(all_dirts, new_pos):
	for dirt in all_dirts:
		if dirt.position == new_pos:
			return false
	return true

func build_dirt(start_pos:Vector2):
	var all_dirts = []
	
	while all_dirts.size() < dirt_per_spot:
		var dirt = dirt_scene.instance()
		if all_dirts.size() == 0:
			dirt.position = start_pos
		else:
			var xdir = randi() % 3 - 1
			var ydir = randi() % 3 - 1
			if xdir == 0 and ydir == 0:
				ydir = -1 if randi() % 2 == 0 else 1
			dirt.position = all_dirts[randi() % all_dirts.size()].position + Vector2(xdir, ydir)
			if not is_unoccupied_position(all_dirts, dirt.position):
				continue
			
		all_dirts.append(dirt)
		add_child(dirt)
		my_dirts += 1
		dirt.connect("cleaned", self, "_on_Dirt_cleaned")


func _process(delta):
	if my_dirts == 0 && !is_clean:
		is_clean = true
		print("PERFECT KID!")
		emit_signal("kid_cleaned")
	move_around(delta)

func move_around(delta):
	position += velocity * delta
	if position.x < 24 or position.x > screen_size.x - 24:
		velocity.x = -velocity.x
	if position.y < 24 or position.y > screen_size.y - 24:
		velocity.y = -velocity.y
	

func _on_Dirt_cleaned():
	my_dirts -= 1
	emit_signal("dirt_cleaned")
	
