extends RigidBody3D

@export var touch_interest_position = Vector3(0.3, -0.3, -0.6)
@export var touch_interest_rotation_degrees = Vector3(0, -120, 30)

func pickup(parent):
	position = touch_interest_position
	rotation_degrees = touch_interest_rotation_degrees
	reparent(parent)
	freeze = true
	return self
