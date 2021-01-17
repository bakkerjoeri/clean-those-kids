extends Object


signal add_kid

var kid_count


func _init(var _kid_count):
	kid_count = _kid_count
	
func on_Kid_cleaned():
	kid_count -= 1

func is_wave_finished():
	return kid_count <= 0	
		
func build_wave():
	for _k in range(kid_count):
		emit_signal("add_kid")

			
