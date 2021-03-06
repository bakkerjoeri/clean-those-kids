extends Node2D

const KidType = preload("KidTypeEnum.gd").KidType
const DirtParticles = preload("DirtParticles.tscn")

signal kid_cleaned(kid)
signal kid_cleaned_first_time
signal dirt_cleaned
signal dirt_clump_spawned
signal kid_start_moving

export(PackedScene) var dirt_scene
export var number_of_dirt_spots: int = 2
export var dirty_kid_number_of_dirt_spots: int = 4
export var dirt_per_spot: int = 16
export var min_speed: int = 30
export var max_speed: int = 50
export var min_speed_fast_kid: int = 70
export var max_speed_fast_kid: int = 90
export var max_dirts: int = 128
export var intro_kid = false

enum KidState {
	ENTERING,
	ACTIVE,
	LEAVING
}

var my_dirts = 0
var is_clean = false
var velocity: Vector2
var screen_size: Vector2
var kid_type
var wave_index = 0
var cur_state
var cleaning_timer_duration: float = 0.5
var cleaning_timer: float = 0

#Start-related variables
var start_pos:Vector2
var spawn_slowly:bool = false
var has_been_cleaned:bool = false

func _ready():
	# Choose a face!
	$Face.set_frame(randi() % $Face.frames.get_frame_count("default"))
	screen_size = get_viewport_rect().size
	
	cur_state = KidState.ENTERING
	var tween = $EnterTween
	if not intro_kid:
		var tween_duration = 1.0 if self.spawn_slowly else rand_range(0.3, 0.5)
		tween.interpolate_property(self, "position", self.position, 
								start_pos, tween_duration, 
								Tween.TRANS_LINEAR, Tween.EASE_IN_OUT) 
		tween.start()
	else:
		cur_state = KidState.ACTIVE
	
	# Set direction
	var direction = rand_range(-PI, PI)
	var wave_difficulty_ramp = 20
	var max_speed_mult = 1.0
	if wave_index > wave_difficulty_ramp:
		max_speed_mult += (wave_index-wave_difficulty_ramp)/10.0*0.5
		
	if kid_type == self.KidType.FAST or kid_type == self.KidType.INFECTIOUS_FAST:
		velocity = Vector2(rand_range(min_speed_fast_kid, max_speed_fast_kid*max_speed_mult), 0).rotated(direction)
	else:
		velocity = Vector2(rand_range(min_speed, max_speed*max_speed_mult), 0).rotated(direction)
	if kid_type == self.KidType.DIRT_TRANSCENDED:
		velocity = velocity * 0
		spawn_slowly = true

func leave_screen(leave_delay=1.0, leave_velocity=200):
	self.cur_state = KidState.LEAVING
	self.velocity = self.velocity*0
	yield(get_tree().create_timer(leave_delay), "timeout")
	
	#move away from center, plus/minus 45 degrees
	var direction = rand_range(-PI/4, PI/4)
	self.velocity = (self.position-self.screen_size/2).normalized().rotated(direction)*leave_velocity

func set_kid_type(type):
	self.kid_type = type

func is_unoccupied_position(all_dirts, new_pos):
	for dirt in all_dirts:
		if dirt.position == new_pos:
			return false
	return true
	
func add_dirt_clump(amount_of_dirt: int = dirt_per_spot):
	var dirt_dump_list = $DirtRegions.get_children()
	var selected_dump_pos = dirt_dump_list[randi() % dirt_dump_list.size()].position
	build_dirt(selected_dump_pos + Vector2(randi() % 5 - 2, randi() % 5 - 2), amount_of_dirt)

func build_dirt(start_pos:Vector2, amount_of_dirt: int):
	var all_dirts = []
	
	# Emit some dirt cloud particles
	var dirt_particle_emitter = $DirtParticles
	dirt_particle_emitter.position = start_pos
	dirt_particle_emitter.z_index = 1
	dirt_particle_emitter.restart()
	dirt_particle_emitter.emitting = true
	
	# Make some noise!
	$KidGetsDirtySound.pitch_scale = rand_range(0.8,1.2)
	$KidGetsDirtySound.play()
	
	emit_signal("dirt_clump_spawned")
	
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
			emit_signal("kid_cleaned", self)
			$CleanParticles.emitting = true
			if not intro_kid:
				$CleanBurst.emitting = true
				$KidCleanedSound.play()
			if not has_been_cleaned:
				emit_signal("kid_cleaned_first_time")
				has_been_cleaned = true
	if self.cur_state == KidState.ACTIVE or self.cur_state == KidState.LEAVING:
		move_around(delta)

	if (kid_type == KidType.INFECTIOUS or kid_type == KidType.INFECTIOUS_FAST) && my_dirts > 0:
		$StinkLines.visible = true
	else:
		$StinkLines.visible = false
	
	if (cleaning_timer > 0):
		$LeftEye.show()
		$RightEye.show()
	else:
		$LeftEye.hide()
		$RightEye.hide()

	cleaning_timer -= delta

func move_around(delta):
	if cleaning_timer > 0:
		position += velocity * delta * 0.75
	else:
		position += velocity * delta
	if self.cur_state == KidState.ACTIVE:
		if (position.x < 24 and velocity.x < 0) or \
		   (position.x > screen_size.x - 24 and velocity.x > 0):
			velocity.x = -velocity.x
		if (position.y < 48 and velocity.y < 0) or \
		(position.y > screen_size.y - 24 and velocity.y > 0):
			velocity.y = -velocity.y

func _on_Dirt_cleaned():
	my_dirts -= 1
	cleaning_timer = cleaning_timer_duration
	emit_signal("dirt_cleaned", self)
	
func _on_Kid_area_entered(other_kid: Area2D):
	if (self.cur_state == KidState.LEAVING):
		return
	
	self.velocity = self.velocity.bounce((other_kid.position - self.position).normalized())
	
	if (self.kid_type == KidType.INFECTIOUS or self.kid_type == KidType.INFECTIOUS_FAST) && !is_clean:
		other_kid.call_deferred("add_dirt_clump", 8)

func _on_EnterTween_tween_completed(_object, _key):
	var anim_mult = 1.0 if self.spawn_slowly else 0.1
	
	if self.spawn_slowly:
		yield(get_tree().create_timer(0.5*anim_mult), "timeout")
		$CleanParticles.emitting = false
		yield(get_tree().create_timer(0.5*anim_mult), "timeout")
	$CleanParticles.emitting = false
	var spawn_count = 0
	if self.kid_type == KidType.EXTRA_DIRTY || self.kid_type == KidType.INFECTIOUS_EXTRA_DIRTY:
		spawn_count = self.dirty_kid_number_of_dirt_spots
	else:
		spawn_count = self.number_of_dirt_spots

	# Spawn dirt
	cleaning_timer = 100 #Make eyes big as well with gross hack
	for _p in range(spawn_count):
		yield(get_tree().create_timer(0.5*anim_mult), "timeout")
		add_dirt_clump()
	yield(get_tree().create_timer(1*anim_mult), "timeout")
	cur_state = KidState.ACTIVE
	cleaning_timer = 0	#Make eyes small again
	emit_signal("kid_start_moving")
