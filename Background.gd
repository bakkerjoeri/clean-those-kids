extends Node2D

func play():
	$Animation.play("Movement")

func stop():
	$Animation.stop(false)
