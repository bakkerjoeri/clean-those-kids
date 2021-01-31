extends TextureButton

const bus_index = 1

func _process(delta: float):
	if (AudioServer.is_bus_mute(bus_index)):
		$Icon.frame = 1
	else:
		$Icon.frame = 0

func _on_ButtonSoundEffects_pressed():
	AudioServer.set_bus_mute(bus_index, !AudioServer.is_bus_mute(bus_index))
	$ToggleSound.play()
