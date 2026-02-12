extends CharacterBody3D

@export var speed: float = 20.0
@export var arena_size_x: float = 10.0
@export var paddle_mesh: MeshInstance3D = null
@export var paddle_mesh_col: CollisionShape3D = null

@export var base_height: float = 0.5
@export var base_box_y: float = 0.5
@export var base_box_z: float = 0.8

#func apply_width(width_x: float) -> void:
	## 1) Collision: BoxShape3D width on X
	#if paddle_mesh_col.shape is BoxShape3D:
		#var s := paddle_mesh_col.shape as BoxShape3D
		#s.size.x = width_x
		#s.size.y = base_box_y
		#s.size.z = base_box_z
#
	## 2) Visual: CapsuleMesh radius controls thickness/width
	## Capsule width ≈ 2 * radius, so radius = width/2
	#if paddle_mesh.mesh is CapsuleMesh:
		#var m := paddle_mesh.mesh as CapsuleMesh
		#m.radius = 2000
		#m.height = base_height  # keep height constant

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
