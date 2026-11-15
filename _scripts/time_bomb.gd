extends RigidBody3D

@export var touch_interest_position = Vector3(0.3, -0.3, -0.6)
@export var touch_interest_rotation_degrees = Vector3(0, -120, 30)

@onready var reverse: int = 1 # changes to -1 if reversing
@onready var candie: bool = true

@onready var ticking= preload("uid://6v3r2cg7v4i3")
@onready var alarm = preload("uid://b8vgq1o3m1fdq")

var main

var on_screen : bool = false

var disappear_ready : bool = false

signal death(node)

func _ready():
	main = get_parent()
	
	$DisappearTimer.wait_time = randf_range(20.0, 30.0)
	$DisappearTimer.start()
	%alarming.stream_paused = true

func pickup(parent):
	position = touch_interest_position
	rotation_degrees = touch_interest_rotation_degrees
	reparent(parent)
	freeze = true
	return self

func _process(_delta):
	if %model.progress >= 0.8:
		if %model.progress >= 1 and candie:
			candie = false
			print("YOU JUST DIED")
			death.emit(self)
			%AnimationPlayer.play("die")
	
	if %model.progress <= 0.8:
		%ticking.stream_paused = false
		%alarming.stream_paused = true
	else:
		%ticking.stream_paused = true
		%alarming.stream_paused = false
	
	if freeze == false:
		%ticking.unit_size = 1
	else: 
		%ticking.unit_size = 3


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	on_screen = true
	print("entered screen")

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	on_screen = false
	print("left screen")

func _on_disappear_timer_timeout() -> void:
	disappear_ready = true
	disappear()

func disappear():
	# is it off screen, not being held and also not already moved?
	if get_parent() == main and not freeze == true:
		if main.request_disappear(self):
			freeze = true
	
	disappear_ready = false
	$DisappearTimer.wait_time = randf_range(1.5, 3.0)
	$DisappearTimer.start()
