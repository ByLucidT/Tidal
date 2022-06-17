extends Node

signal restart_water

func _input(event):
	if Input.is_action_just_pressed("Reset"):
		$Player.position = Vector2 (0,0)
		$"Rising Water".position = Vector2 (0,2800)
		emit_signal("restart_water")
		$StartWater.start()


