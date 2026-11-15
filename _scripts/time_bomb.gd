extends RigidBody3D

@export var touch_interest_position = Vector3(0.3, -0.3, -0.6)
@export var touch_interest_rotation_degrees = Vector3(0, -120, 30)

@onready var reverse: int = 1 # changes to -1 if reversing
@onready var candie: bool = true

signal death(node)

func pickup(parent):
	position = touch_interest_position
	rotation_degrees = touch_interest_rotation_degrees
	reparent(parent)
	freeze = true
	return self

func _process(_delta):
	if %model.progress >= 1 and candie:
		candie = false
		print("YOU JUST DIED")
		death.emit(self)
		%AnimationPlayer.play("die")
