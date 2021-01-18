extends Camera2D

var decay = 1
var amplitude = 0

func _process(delta):
	if (amplitude > 0):
		do_shaking()
		amplitude = max(amplitude - decay, 0)
	else:
		offset = Vector2(0, 0)

func shake(amplitude: int):
	self.amplitude = amplitude

func do_shaking():
	offset = Vector2(
		(randi() % (amplitude * 2)) - amplitude,
		(randi() % (amplitude * 2)) - amplitude
	)
