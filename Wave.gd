extends Object


signal add_kid(kid_type)

var initial_kid_count:int
var kids_to_spawn:Array
var kids_cleaned:int
var total_kid_count
var kids_added:int
var wave_intro
var adds_per_time:int
var time_scale

func _init(
	var initial_kid_count: int,
	var kids_to_spawn: Array, 
	var adds_per_time: int,
	var wave_intro,
	var time_scale = 1.0
):
	self.initial_kid_count = initial_kid_count
	self.kids_to_spawn = kids_to_spawn
	self.total_kid_count = kids_to_spawn.size()
	self.kids_cleaned = 0
	self.kids_added = 0
	self.wave_intro = wave_intro
	self.adds_per_time = adds_per_time
	self.time_scale = time_scale
	
func on_Kid_cleaned():
	self.kids_cleaned += 1
	for _k in range(self.adds_per_time):
		if self.kids_to_spawn.size() > 0:
			add_kid(kids_to_spawn.pop_front())

func is_wave_finished():
	return self.kids_cleaned >= total_kid_count	
		
func add_kid(var kid_type):
	var spawn_in_center = kids_added == 0 and self.initial_kid_count == 1
	emit_signal("add_kid", kid_type, spawn_in_center)
	kids_added += 1	

func build_wave():
	for _k in range(self.initial_kid_count):
		add_kid(kids_to_spawn.pop_front())

			
