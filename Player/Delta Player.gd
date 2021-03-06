extends KinematicBody2D

const UP = Vector2(0,-1)
export var BASESPEED = 400
export var BASEJUMP = 8000
export var GRAVITY = 1000
export var MAXFALLSPEED = 1600
export var ACCEL = 900
export var DEACCEL = 1000
var jump_force = -25000
var velocity = Vector2()
var double_jump = 1
var facing = 0

func _physics_process(delta):
	
	motion_physics(delta)
	get_walking_sounds()
	jumping_physics(delta)
	
	print (velocity)

func get_walking_sounds():
	if velocity.x != 0 and is_on_floor():
		if !$WalkingSound.is_playing():
			$WalkingSound.play()
	else:
		$WalkingSound.stop()

#this contains left to right inputs, acceleration, and deacceleration
func motion_physics(delta):
	move_and_slide(velocity,UP)
	
	if Input.is_action_pressed("move_right"):
		velocity.x += ACCEL * delta
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("move_left"):
			velocity.x -= ACCEL * delta
			$AnimatedSprite.flip_h = true
	#This is the motion deacceleration
	else:
		if abs(velocity.x) < 20:
			velocity.x= 0 
		#Air Deacceleration
		elif ! is_on_floor():
			if velocity.x > 0:
				velocity.x -= DEACCEL * delta
			elif velocity.x < 0:
				velocity.x += DEACCEL * delta
		#Ground Deacceleration
		elif is_on_floor():
			if velocity.x > 0:
				velocity.x -= DEACCEL * delta *2
			elif velocity.x < 0:
				velocity.x += DEACCEL * delta *2
	velocity.x = clamp(velocity.x,-BASESPEED,BASESPEED)
	
	#this fixes a bug where pivoting causes you to slide more when having both buttons pressed.
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_left") and is_on_floor():
		if velocity.x > 0:
			velocity.x -= DEACCEL 
		elif velocity.x < 0:
			velocity.x += DEACCEL
	
	#gravity
	velocity.y += GRAVITY * delta
	if ! is_on_floor() and velocity.y > MAXFALLSPEED:
		velocity.y = MAXFALLSPEED
	if is_on_floor() and velocity.y > MAXFALLSPEED/4:
		velocity.y = MAXFALLSPEED/8
			

# This also contains the wall sliding physics which are currently broken
## To-do's: try and reimplement wall friction without breaking the jump
func jumping_physics(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = BASEJUMP * delta
		$JumpingSound.play()
		double_jump = 1
		if Input.is_action_pressed("jump"):
			velocity.y = jump_force * delta
	if Input.is_action_just_pressed("jump") and is_on_wall() and double_jump == 1 and ! is_on_floor():
		get_facing_direction()
		velocity.x = 300*facing*delta
		velocity.y = jump_force * .90 * delta
		$JumpingSound.play()
		double_jump = 0
	# if event.

func get_facing_direction():
	if velocity.x > 0:
		facing = -1
	if velocity.x < 0:
		facing = 1
