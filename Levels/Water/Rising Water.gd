extends Area2D
var movement_speed = 80
var moving
var velocity = Vector2.ZERO

func rising_tide():
	velocity = Vector2.UP * movement_speed

func reset_tide():
	velocity = Vector2.ZERO

func _physics_process(delta):
	position += velocity * delta

func _on_StartWater_timeout():
	rising_tide()

func _on_Test_Level_restart_water():
	reset_tide()
