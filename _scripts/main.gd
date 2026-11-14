extends Node

@onready var held_node = $SubViewportContainer/SubViewport/TimeBomb

@onready var player = $Player
var camera

func _ready() -> void:
	camera = player.get_node("Camera")


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if $Player.mouse_captured:
			$Player.release_mouse()
		else:
			$Player.capture_mouse()
			
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("throw"):
		held_node.global_position = player.get_node("Camera").global_position
		held_node.set_deferred("freeze", false)
		held_node.reparent(self)
		held_node.apply_central_force()
