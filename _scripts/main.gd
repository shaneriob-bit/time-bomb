extends Node

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if $Player.mouse_captured:
			$Player.release_mouse()
		else:
			$Player.capture_mouse()
