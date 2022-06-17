extends KinematicBody2D

export var MAXWALKSPEED = 400
export var BASEJUMP = 8000
export var GRAVITY = 1200
export var MAXFALLSPEED = 1200
export var ACCEL = 900
export var DEACCEL = 1000
export var WALLJUMPPUSHBACK = 600
const FRICTION = 1200
const HORIZONTALDRAG = 900
const VERTICALDRAG = 400

export var jump_magnitude = 800
export var walking_magnitude = 3500
var velocity = Vector2.ZERO
var wall_jump = false
var jump = true
export var WEIGHT = 1
var touched_grass = false setget update_jump_indicator
var wall_direction = Vector2.ZERO

func _input(event):
	get_animations()

func update_jump_indicator(new_touched_grass):
	print ("touchedgrass")
	touched_grass = new_touched_grass

func _physics_process(delta):
	var net_force = get_net_forces(delta)
	
	velocity += (net_force/WEIGHT)*delta
	velocity += get_impulses()
	velocity = move_and_slide(velocity,Vector2.UP)
	get_sounds()
	get_animations()
	simulate_pickup()
	get_collisions()

func get_net_forces(delta):
	#gravity
	var gravity_force = Vector2.DOWN* GRAVITY* WEIGHT
	if gravity_force > Vector2.DOWN* GRAVITY* WEIGHT:
		gravity_force = Vector2.DOWN* GRAVITY* WEIGHT
	#friction
	var friction = get_friction_and_drag()
	if abs((friction.x/WEIGHT)*delta) > abs(velocity.x):
		friction.x = -velocity.x*WEIGHT/delta
	
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
	drag.x += -velocity.normalized().x*HORIZONTALDRAG
	drag.y += -velocity.normalized().y*VERTICALDRAG
	return friction+drag

func get_impulses():
	var jump_force = Vector2.ZERO
	# wall jump
	## Comes first so that jump and wall jump can't be true together
	touch_grass_reset()
	if Input.is_action_just_pressed("jump") and wall_jump == true and jump == false:
		velocity.y = 0
		jump_force += (Vector2.UP *jump_magnitude)/WEIGHT
		jump_force += walljump_pushback()
		wall_jump = false
		untouched_grass()
		
	# regular jump
	jump_checks()
	if Input.is_action_just_pressed("jump") and jump == true:
		jump_force += (Vector2.UP *jump_magnitude)/WEIGHT
		jump = false
		$JumpingSound.play()
	# variable jump
	if Input.is_action_just_released("jump") and velocity.y < 0:
		jump_force = (Vector2.UP *velocity.y*.5)/WEIGHT
	return jump_force

func get_sounds():
	if velocity.x != 0 and is_on_floor():
		if !$WalkingSound.is_playing():
			$WalkingSound.play()
	else:
		$WalkingSound.stop()

func get_animations():
	if velocity == Vector2.ZERO:
		$PlayerSprite.animation = "Standing"
	if velocity.x > 0:
		$PlayerSprite.flip_h = false
		if is_on_floor():
			$PlayerSprite.animation = "Walking"
	if velocity.x < 0:
		$PlayerSprite.flip_h = true
		if is_on_floor():
			$PlayerSprite.animation = "Walking"
	if velocity.y < 0:
		$PlayerSprite.animation = "Jumping"

var cyote_time = false 
func jump_checks():
	if is_on_floor():
		jump = true
	elif cyote_time == false:
		cyote_time = true
		$CyoteTimer.start()

func touch_grass_reset():
	if is_on_floor() and touched_grass == false:
		touched_grass = true
		cyote_time = false
		$JumpIndicator.frame = 2
		#this means the cyote timer can be reset
	
	#refreshes wall jump if grass is touched
	if is_on_wall() and ! is_on_floor() and touched_grass == true:
		wall_jump = true
		$WallJumpTimer.start()

func untouched_grass():
	touched_grass = false
	$JumpIndicator.frame = 0

func _on_CyoteTimer_timeout():
	jump = false

func _on_WallJumpTimer_timeout():
		wall_jump = false

func walljump_pushback():
	return (wall_direction * WALLJUMPPUSHBACK)/ WEIGHT

var items_held = 0
func simulate_pickup():
	if Input.is_action_just_pressed("Drop"):
		if items_held > 0:
			items_held -= 1
	if Input.is_action_just_pressed("Pickup"):
		items_held += 1
	WEIGHT = 1+ (.025 * items_held)
	print (items_held)

func get_collisions():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var last_collision_normal = collision.normal
		if abs(Vector2.LEFT.angle_to(last_collision_normal)) < 0.1 or abs(Vector2.RIGHT.angle_to(last_collision_normal)) < 0.1:
			wall_direction = last_collision_normal
