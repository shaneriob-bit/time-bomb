extends Node

@onready var player = $Player

@onready var timesincestart: float = 0
@onready var survival: Label = $HUD/survival
@export var office_environment: Node3D

var hiding_spots
var time_bombs : Array

var can_disappear : bool = false

var is_dead : bool = false
const BOMB_DISAPPEAR = preload("uid://1uqmppr5lo2b")

var raycast : RayCast3D

var disappear_count = 0

func _ready() -> void:
	camera = player.get_node("Camera")
	raycast = player.get_node("Camera/RayCast3D")
	hiding_spots = $office_environment/HidingSpots.get_children()
	
	for child in get_children():
		if child.name.contains("TimeBomb") and child is RigidBody3D:
			time_bombs.append(child)

	$HeldTickingPlayer.stream_paused = true
	
@export var throwable_scene: PackedScene
@export var throw_force: float = 20.0
@onready var camera: Camera3D = player.get_node("Camera")

var held_object = null

const RAY_LENGTH = 10

var timeleft:int = 300

func _process(delta):
	timesincestart += delta
	timeleft = 300 - timesincestart
	survival.text = ("0" if timeleft < 540 else "") + str(int(timeleft/60)) + ":" + ("0" if int(timeleft) % 60 < 10 else "") + str(int(timeleft) % 60)
	if timesincestart >= 300:
		player.release_mouse()
		get_tree().change_scene_to_file("res://_scenes/win.tscn")
		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"): # Configure "throw" in Project Settings > Input Map
		throw_object()
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		player.capture_mouse()
		
		if held_object == null:
			var result = raycast.is_colliding()
			if result:
				var collision_object = raycast.get_collider()
				print(collision_object.name)
				if collision_object is RigidBody3D and collision_object.name.contains("TimeBomb"):
					held_object = collision_object.pickup($SubViewportContainer.get_node("SubViewport"))
					%rewind.visible = true
					$HeldTickingPlayer.stream_paused = false
	
	if event.is_action_pressed("rewind"):
		if held_object:
			held_object.reverse = -5
	if event.is_action_released("rewind"):
		if held_object:
			held_object.reverse = 1
	
func throw_object(force: bool = true) -> void:
	if not throwable_scene:
		return
		
	if not held_object:
		return
	
	# just in case :p
	held_object.reverse = 1
	%rewind.visible = false
	
	# Instance the rigid body object
	var instance: RigidBody3D = held_object
	instance.reparent(get_tree().current_scene)
	instance.freeze = false
	
	# Position it slightly in front of the camera
	var spawn_distance = 0.010
	instance.global_position = camera.global_position - camera.global_transform.basis.z * spawn_distance
	instance.global_rotation_degrees = Vector3(randf_range(0, 360), randf_range(0, 360),randf_range(0, 360))

	await get_tree().physics_frame

	# Get the camera's look direction (forward vector in Godot is -Z)
	var look_direction = -camera.global_transform.basis.z

	if force:
		# Apply a central impulse along the look vector
		instance.apply_central_impulse(look_direction * throw_force)
	
	$HeldTickingPlayer.stream_paused = true
	held_object = null
	
func _on_child_entered_tree(node: Node) -> void:
	# stolen from above :E
	if node is RigidBody3D and node.name.contains("TimeBomb"):
		print("new bomb found")
		if !node.is_connected("death",office_environment._on_death):
			node.death.connect(office_environment._on_death)
		if !node.is_connected("death",_on_death):
			node.death.connect(_on_death)

func _on_death(node):
	if is_dead == false:
		is_dead = true
		await throw_object(false)
		set_process(false)
		player.release_mouse()
		player.queue_free() # lmao
		for child in get_children():
			if child.name.contains("TimeBomb") && child != node:
				# can't worry about overlapping bombs if overlapping bombs.... dont exist
				child.queue_free()

		await get_tree().physics_frame
		$HUD/ColorRect.visible = true
		%explosion.play()
		%AnimationPlayer.play("fade_white")
		await %AnimationPlayer.animation_finished
		Globals.finaltime = timesincestart
		get_tree().change_scene_to_file("res://_scenes/death.tscn")

func is_bomb_too_close(pos : Vector3) -> bool:
	var closest_distance = 999999
	
	for bomb in time_bombs:
		if bomb.position.distance_to(pos) < closest_distance:
			closest_distance = bomb.position.distance_to(pos)
			
	return closest_distance < 5
	
func request_disappear(bomb : Node3D):
	if can_disappear:
		if Globals.showhint:
			%somethinghappened.visible = true
			%somethinghappened.get_node("AnimationPlayer").play("fadetext")
			Globals.showhint = false
		print("disappearing")
		var found = false
		var spot
		var count = 0
		
		while not found:
			count += 1
			spot = hiding_spots[randi_range(0, hiding_spots.size() - 1)]
			if not is_bomb_too_close(spot.position):
				found = true
			
			if count > 30:
				printerr("Unable to find hiding spot")
				break
		
		var disappeareffect = BOMB_DISAPPEAR.instantiate()
		add_child(disappeareffect)
		disappeareffect.global_position = bomb.global_position
		
		bomb.global_position = spot.global_position
		bomb.global_rotation = spot.global_rotation
		
		bomb.freeze = true
		
		can_disappear = false
		var t = 45 - (7.5 * disappear_count)
		if t < 0:
			t = 20
		$DisappearTimer.wait_time = t
		$DisappearTimer.start()
		
		disappear_count += 1


func _on_disappear_timer_timeout() -> void:
	can_disappear = true
