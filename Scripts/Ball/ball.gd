extends RigidBody3D

@export var speed: float = 10.0
var direction := Vector3(1, 1, 0).normalized()

func _ready():
	linear_velocity = direction * speed

func _physics_process(delta):
	linear_velocity = linear_velocity.normalized() * speed
