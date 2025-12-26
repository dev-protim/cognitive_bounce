extends CharacterBody3D

@export var speed: float = 15.0
@export var arena_size_x: float = 10.0

func _physics_process(delta: float) -> void:
	var input_dir = 0.0

	# Only left/right input
	if Input.is_action_pressed("move_right"):
		input_dir += 1
	if Input.is_action_pressed("move_left"):
		input_dir -= 1

	# Set X velocity, no Y or Z movement
	velocity.x = input_dir * speed
	velocity.y = 0
	velocity.z = 0

	move_and_slide()

	# Clamp inside arena
	var half_x = 3.0 / 2  # paddle half-width
	position.x = clamp(position.x, -arena_size_x + half_x, arena_size_x - half_x)
	position.y = 0.5      # fixed height
	position.z = 0        # fixed depth

#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5
#
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
