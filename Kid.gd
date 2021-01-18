extends Node2D

const KidType = preload("KidTypeEnum.gd").KidType

signal kid_cleaned
signal dirt_cleaned

export(PackedScene) var dirt_scene
export var number_of_dirt_spots: int = 2
export var dirty_kid_number_of_dirt_spots: int = 4
export var dirt_per_spot: int = 16
export var min_speed: int = 30
export var max_speed: int = 50
export var max_dirts: int = 128

enum KidState {
	ENTERING,
	ACTIVE
}

var my_dirts = 0
var is_clean = false
var velocity: Vector2
var screen_size: Vector2
var kid_type
var cur_state

var start_pos:Vector2

func _ready():
	# Choose a face!
	$Face.set_frame(randi() % $Face.frames.get_frame_count("default"))
	screen_size = get_viewport_rect().size
	
	cur_state = KidState.ENTERING
	var tween = $EnterTween
	tween.interpolate_property(self, "position", self.position, 
							start_pos, 1, 
							Tween.TRANS_LINEAR, Tween.EASE_IN_OUT) 
	tween.start()
	
	# Set direction
	var direction = rand_range(-PI, PI)
	velocity = Vector2(rand_range(min_speed, max_speed), 0).rotated(direction)



func set_kid_type(type):
	self.kid_type = type

	if type == KidType.INFECTIOUS:
		$StinkLines.visible = true
	else:
		$StinkLines.visible = false
	



func is_unoccupied_position(all_dirts, new_pos):
	for dirt in all_dirts:
		if dirt.position == new_pos:
			return false
	return true
	
func add_dirt_clump(amount_of_dirt: int = dirt_per_spot):
	build_dirt(Vector2(randi() % 45 - 22, randi() % 45 - 22), amount_of_dirt)

func build_dirt(start_pos:Vector2, amount_of_dirt: int):
	var all_dirts = []
	
	while all_dirts.size() < amount_of_dirt:
		if (my_dirts > max_dirts):
			return
		
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
	if cur_state == KidState.ACTIVE:
		if (my_dirts > 0):
			is_clean = false
			$CleanParticles.emitting = false
		elif (!is_clean):
			is_clean = true
			print("PERFECT KID!")
			emit_signal("kid_cleaned")
			$CleanParticles.emitting = true
			
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
	
func _on_Kid_area_entered(other_kid: Area2D):
	self.velocity = self.velocity.bounce((other_kid.position - self.position).normalized())
	
	if (self.kid_type == KidType.INFECTIOUS && !is_clean):
		other_kid.call_deferred("add_dirt_clump", 8)


func _on_EnterTween_tween_completed(object, key):
	$CleanParticles.emitting = false
	yield(get_tree().create_timer(1), "timeout")
	var spawn_count = self.dirty_kid_number_of_dirt_spots if self.kid_type== KidType.EXTRA_DIRTY else self.number_of_dirt_spots
	# Spawn dirt
	for _p in range(spawn_count):
		yield(get_tree().create_timer(0.5), "timeout")
		add_dirt_clump()
	yield(get_tree().create_timer(1), "timeout")
	cur_state = KidState.ACTIVE
	
