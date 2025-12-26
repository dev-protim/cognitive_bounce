extends RigidBody3D

@export var speed: float = 10.0

func _ready():
	var dir = Vector3(-1, 1, 0).normalized()
	linear_velocity = dir * speed
	gravity_scale = 0

func _physics_process(delta):
	linear_velocity = linear_velocity.normalized() * speed
