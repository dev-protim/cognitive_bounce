extends CharacterBody3D

@export var speed: float = 20.0
@export var arena_size_x: float = 10.0
@export var paddle_mesh: MeshInstance3D = null
@export var paddle_mesh_col: CollisionShape3D = null

@export var base_height: float = 0.5
@export var base_box_y: float = 0.5
@export var base_box_z: float = 0.8

@export var screen_to_world_scale := 0.02

var dragging := false
var target_x := 0.0

func _ready() -> void:
	target_x = global_position.x

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		dragging = event.pressed
		if dragging:
			# start target from current pos when finger touches
			target_x = global_position.x

	elif event is InputEventScreenDrag and dragging:
		target_x += event.relative.x * screen_to_world_scale

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
	# 1) Touch movement (phone)
	if dragging:
		var dx := target_x - global_position.x
		# move toward target with your speed (smooth + frame-rate independent)
		var step := speed * delta
		global_position.x += clamp(dx, -step, step)
	else:
		# 2) Keyboard movement (PC)
		var dir_x := get_x_dir()
		velocity = Vector3(dir_x * speed, 0, 0)
		move_and_slide()

	# Clamp inside arena
	var half_x := 3.0 / 2.0
	global_position.x = clamp(global_position.x, -arena_size_x + half_x, arena_size_x - half_x)

	# keep on plane
	global_position.y = 1.0
	global_position.z = 0.0
#func _physics_process(delta: float) -> void:
	#var dir_x = get_x_dir()
	#velocity.x = dir_x * speed
	#
	#velocity.y = 0
	#velocity.z = 0
#
	#move_and_slide()
#
	## Clamp inside arena
	#var half_x = 3.0 / 2
	#position.x = clamp(position.x, -arena_size_x + half_x, arena_size_x - half_x)
	#position.y = 1
	#position.z = 0
