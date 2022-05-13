extends KinematicBody2D

const UP = Vector2(0,-1)
export var BASESPEED = 400
export var BASEJUMP = 150
export var GRAVITY = 26
export var MAXFALLSPEED = 900
export var ACCEL = 20
export var DEACCEL = 50
var jump_force = -700
var force = Vector2()
var double_jump = 1
var facing = 0

func _physics_process(delta):
	
	motion_physics()
	get_walking_sounds()
	jumping_physics()
	
	force.y += GRAVITY
	if force.y > MAXFALLSPEED:
		force.y = MAXFALLSPEED
	if Input.is_action_just_released("jump"):
		force.y += GRAVITY*7
	# end physics
	print (force)

func get_walking_sounds():
	if force.x != 0 and is_on_floor():
		if !$WalkingSound.is_playing():
			$WalkingSound.play()
	else:
		$WalkingSound.stop()

#this contains left to right inputs, acceleration, and deacceleration
func motion_physics():
	force.x = clamp(force.x,-BASESPEED,BASESPEED)
	if Input.is_action_pressed("move_right"):
		force.x += ACCEL
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("move_left"):
			force.x -= ACCEL
			$AnimatedSprite.flip_h = true
	#This is the motion deacceleration
	else:
		if abs(force.x) < 40:
			force.x= 0 
		#Air Deacceleration
		elif ! is_on_floor():
			if force.x > 0:
				force.x -= ACCEL
			elif force.x < 0:
				force.x += ACCEL
		#Ground Deacceleration
		elif is_on_floor():
			if force.x > 0:
				force.x -= DEACCEL
			elif force.x < 0:
				force.x += DEACCEL
		else:
			force.x= 0
	
	#this fixes a bug where pivoting causes you to slide more when having both buttons pressed.
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_left") and is_on_floor():
		if force.x > 0:
			force.x -= DEACCEL
		elif force.x < 0:
			force.x += DEACCEL
	move_and_slide(force,Vector2(0,-1))

# This also contains the wall sliding physics which are currently broken
## To-do's: try and reimplement wall friction without breaking the jump
func jumping_physics():
	if is_on_floor():
		force.y = 200
		if Input.is_action_just_pressed("jump"):
			force.y = BASEJUMP
			$JumpingSound.play()
			double_jump = 1
			if Input.is_action_pressed("jump"):
				force.y = jump_force
	if is_on_wall():
		
		# need to fix. Makes you jump too high:
		if !is_on_floor():
			force.y -= 10
		if Input.is_action_just_pressed("jump") and double_jump == 1 and ! is_on_floor():
			get_facing_direction()
			force.x = 300*facing
			force.y = jump_force * .90
			$JumpingSound.play()
			double_jump = 0

func get_facing_direction():
	if force.x > 0:
		facing = -1
	if force.x < 0:
		facing = 1
