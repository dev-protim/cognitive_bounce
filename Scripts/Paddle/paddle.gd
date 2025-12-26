extends CharacterBody3D

@export var speed: float = 15.0
@export var arena_size_x: float = 10.0

func get_x_dir() -> float:
	return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

func _physics_process(delta: float) -> void:
	var dir_x = get_x_dir()
	velocity.x = dir_x * speed
	
	velocity.y = 0
	velocity.z = 0

	move_and_slide()

	# Clamp inside arena
	var half_x = 3.0 / 2
	position.x = clamp(position.x, -arena_size_x + half_x, arena_size_x - half_x)
	position.y = 1
	position.z = 0
