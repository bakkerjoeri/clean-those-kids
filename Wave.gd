extends Object


signal add_kid

var initial_kid_count:int
var total_kid_count:int
var kids_cleaned:int
var kids_added:int
var wave_intro

func _init(var initial_kid_count, var total_kid_count, var wave_intro):
	self.initial_kid_count = initial_kid_count
	self.total_kid_count = total_kid_count
	self.kids_cleaned = 0
	self.kids_added = 0
	self.wave_intro = wave_intro
	
func on_Kid_cleaned():
	self.kids_cleaned += 1
	if self.kids_added < self.total_kid_count:
		add_kid()

func is_wave_finished():
	return self.kids_cleaned >= total_kid_count	
		
func add_kid():
	emit_signal("add_kid")
	kids_added += 1	

func build_wave():
	for _k in range(self.initial_kid_count):
		add_kid()

			
