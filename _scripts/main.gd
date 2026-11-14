extends Node

@onready var held_node = $SubViewportContainer/SubViewport/TimeBomb

@onready var player = $Player


func _ready() -> void:
	camera = player.get_node("Camera")

@export var throwable_scene: PackedScene
@export var throw_force: float = 20.0
@onready var camera: Camera3D = player.get_node("Camera")

const RAY_LENGTH = 10

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"): # Configure "throw" in Project Settings > Input Map
		throw_object()
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * RAY_LENGTH
		
		var space_state = $Level.get_world_3d().get_direct_space_state()
		
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if result:
			var collision_object = result.collider
			print(collision_object.name)

func throw_object() -> void:
	if not throwable_scene:
		return

	# Instance the rigid body object
	var instance: RigidBody3D = throwable_scene.instantiate() as RigidBody3D
	get_tree().current_scene.add_child(instance)

	# Position it slightly in front of the camera
	var spawn_distance = 0.010
	instance.global_position = camera.global_position - camera.global_transform.basis.z * spawn_distance

	# Get the camera's look direction (forward vector in Godot is -Z)
	var look_direction = -camera.global_transform.basis.z

	# Apply a central impulse along the look vector
	instance.apply_central_impulse(look_direction * throw_force)
