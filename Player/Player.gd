extends KinematicBody2D

export var MAXWALKSPEED = 400
export var BASEJUMP = 8000
export var GRAVITY = 1200
export var MAXFALLSPEED = 1600
export var ACCEL = 900
export var DEACCEL = 1000
const FRICTION = 1000
const DRAG = 400
var jump_magnitude = 700
var walking_magnitude = 3000
var velocity = Vector2.ZERO
var wall_jump = true
var weight = 1
var jumping = false


func _physics_process(delta):
	var net_force = get_net_forces(delta)
	
	velocity += (net_force/weight)*delta
	velocity += get_impulses()
	velocity = move_and_slide(velocity,Vector2.UP)
	get_walking_sounds()
	#jumping_physics()
	print (velocity)

func get_net_forces(delta):
	
	#gravity
	var gravity_force = Vector2.DOWN* GRAVITY* weight
	
	#friction
	var friction = get_friction_and_drag()
	if abs((friction.x/weight)*delta) > abs(velocity.x):
		friction.x = -velocity.x*weight/delta
	
	#lateral_force
	var walking_force = Vector2.ZERO
	if Input.is_action_pressed("move_right") and velocity.x < MAXWALKSPEED:
		walking_force += Vector2.RIGHT*walking_magnitude
	if Input.is_action_pressed("move_left") and -velocity.x < MAXWALKSPEED:
		walking_force += Vector2.LEFT*walking_magnitude
		
	return gravity_force + walking_force + friction
	
func get_friction_and_drag():
	var drag = Vector2.ZERO
	var friction = Vector2.ZERO
	if is_on_floor():
		friction += -velocity.normalized()*FRICTION
	else:
		if is_on_wall():
			friction += -velocity.normalized() *(FRICTION/3)
	drag += -velocity.normalized()*DRAG
	return friction+drag

func get_impulses():
	var jump_force = Vector2.ZERO
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_force += (Vector2.UP *jump_magnitude)/weight
	
	#wall_jump
	if wall_jump == false and is_on_floor():
		wall_jump = true
	if Input.is_action_just_pressed("jump") and is_on_wall() and wall_jump == true and !is_on_floor():
		velocity.y = 0
		jump_force += Vector2.UP *jump_magnitude /weight
		wall_jump = false
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		jump_force = (Vector2.UP *velocity.y*.5)/weight
	return jump_force

func get_walking_sounds():
	if velocity.x != 0 and is_on_floor():
		if !$WalkingSound.is_playing():
			$WalkingSound.play()
	else:
		$WalkingSound.stop()

