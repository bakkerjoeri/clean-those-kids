extends CPUParticles2D

func _ready():
	self.emitting = true

func _process(_delta):
	if !is_emitting():
		queue_free()
