extends Label

var base_position: Vector2
var offset: Vector2 = Vector2(0, 0)

func _ready():
	base_position = rect_position

func _process(_delta):
	rect_position = base_position + offset

func _on_TextureButton_button_down():
	offset = Vector2(0, 1)

func _on_TextureButton_button_up():
	offset = Vector2(0, 0)
