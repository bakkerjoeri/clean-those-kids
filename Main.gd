extends Node

export(PackedScene) var kid_scene

var screen_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screen_size = get_viewport().size
	for _k in range(2):
		add_kid()
		
func add_kid():
	var kid = kid_scene.instance()
	# Set kid to random position within screen
	kid.position = (screen_size - Vector2(48,48)) * rand_range(0,1) + Vector2(24,24)
	kid.connect("kid_cleaned", self, "_on_Kid_cleaned")
	add_child(kid)
		
func _on_Kid_cleaned():
	add_kid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
