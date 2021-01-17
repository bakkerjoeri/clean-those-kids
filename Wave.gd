extends Object


signal add_kid

var kid_count:int
var wave_intro

func _init(var kid_count, var wave_intro):
	self.kid_count = kid_count
	self.wave_intro = wave_intro
	
	
func on_Kid_cleaned():
	self.kid_count -= 1

func is_wave_finished():
	return self.kid_count <= 0	
		
func build_wave():
	for _k in range(self.kid_count):
		emit_signal("add_kid")

			
