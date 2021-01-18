extends CPUParticles2D

func _ready():
	self.emitting = true

func _process(delta):
	if !is_emitting():
		queue_free()
