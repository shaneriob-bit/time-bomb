extends Node

@onready var player = $Player

@onready var timesincestart: float = 0
@onready var survival: Label = $HUD/survival
@export var office_environment: Node3D


func _ready() -> void:
	camera = player.get_node("Camera")

@export var throwable_scene: PackedScene
@export var throw_force: float = 20.0
@onready var camera: Camera3D = player.get_node("Camera")

var held_object = null

const RAY_LENGTH = 3

func _process(delta):
	timesincestart += delta
	survival.text = ("0" if timesincestart < 540 else "") + str(int(timesincestart/60)) + ":" + ("0" if int(timesincestart) % 60 < 10 else "") + str(int(timesincestart) % 60)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"): # Configure "throw" in Project Settings > Input Map
		throw_object()
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		player.capture_mouse()
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * RAY_LENGTH
		
		var space_state = $Level.get_world_3d().get_direct_space_state()
		
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if result:
			var collision_object = result.collider
			print(collision_object.name)
			if collision_object is RigidBody3D and collision_object.name == "TimeBomb":
				held_object = collision_object.pickup($SubViewportContainer.get_node("SubViewport"))
				%rewind.visible = true
	
	if event.is_action_pressed("rewind"):
		if held_object:
			held_object.reverse = -3
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
	
func _on_child_entered_tree(node: Node) -> void:
	# stolen from above :E
	if node is RigidBody3D and node.name == "TimeBomb":
		print("new bomb found")
		if !node.is_connected("death",office_environment._on_death):
			node.death.connect(office_environment._on_death)
		if !node.is_connected("death",_on_death):
			node.death.connect(_on_death)

func _on_death(node):
	await throw_object(false)
	set_process(false)
	player.release_mouse()
	player.queue_free() #lmao
	for child in get_children():
		if child.name == "TimeBomb" && child != node:
			# can't worry about overlapping bombs if overlapping bombs.... dont exist
			child.queue_free()
	$HUD/ColorRect.visible = true
	%AnimationPlayer.play("fade_white")
	await %AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://_scenes/death.tscn")
