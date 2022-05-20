extends KinematicBody2D

const UP = Vector2(0,-1)
export var BASESPEED = 400
export var BASEJUMP = 150
export var GRAVITY = 26
export var MAXFALLSPEED = 900
export var ACCEL = 20
export var DEACCEL = 50
var jump_force = -700
var velocity = Vector2()
var double_jump = 1
var facing = 0

func _physics_process(delta):
	
	motion_physics(delta)
	get_walking_sounds()
	jumping_physics()
	
	print (velocity)

func get_walking_sounds():
	if velocity.x != 0 and is_on_floor():
		if !$WalkingSound.is_playing():
			$WalkingSound.play()
	else:
		$WalkingSound.stop()

#this contains left to right inputs, acceleration, and deacceleration
func motion_physics(delta):
	if Input.is_action_pressed("move_right"):
		velocity.x += ACCEL
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("move_left"):
			velocity.x -= ACCEL
			$AnimatedSprite.flip_h = true
	#This is the motion deacceleration
	else:
		if abs(velocity.x) < 40:
			velocity.x= 0 
		#Air Deacceleration
		elif ! is_on_floor():
			if velocity.x > 0:
				velocity.x -= ACCEL
			elif velocity.x < 0:
				velocity.x += ACCEL
		#Ground Deacceleration
		elif is_on_floor():
			if velocity.x > 0:
				velocity.x -= DEACCEL
			elif velocity.x < 0:
				velocity.x += DEACCEL
	velocity.x = clamp(velocity.x,-BASESPEED,BASESPEED)
	
	#this fixes a bug where pivoting causes you to slide more when having both buttons pressed.
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_left") and is_on_floor():
		if velocity.x > 0:
			velocity.x -= DEACCEL
		elif velocity.x < 0:
			velocity.x += DEACCEL
	move_and_slide(velocity,Vector2(0,-1))

# This also contains the wall sliding physics which are currently broken
## To-do's: try and reimplement wall friction without breaking the jump
func jumping_physics():
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = BASEJUMP
			$JumpingSound.play()
			double_jump = 1
			if Input.is_action_pressed("jump"):
				velocity.y = jump_force
		if Input.is_action_just_pressed("jump") and is_on_wall() and double_jump == 1 and ! is_on_floor():
			get_facing_direction()
			velocity.x = 300*facing
			velocity.y = jump_force * .90
			$JumpingSound.play()
			double_jump = 0

func get_facing_direction():
	if velocity.x > 0:
		facing = -1
	if velocity.x < 0:
		facing = 1
