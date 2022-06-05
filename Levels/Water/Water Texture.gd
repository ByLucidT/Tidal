extends Sprite
var base_y_movement_speed = 1
var base_x_movement_speed = 2
var time_elapsed = 0
var start_position = Vector2.ZERO

func _ready():
	start_position = position
func _physics_process(delta):
	time_elapsed += delta
	position.y = sin(base_y_movement_speed * time_elapsed) * 1 + start_position.y
	position.x = cos(base_x_movement_speed * time_elapsed) * 4 + start_position.x
