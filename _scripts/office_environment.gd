extends Node3D

func _on_death(_node):
	%_ceiling.visible = false
	%_ceiling2.visible = false
	%DEATHCAM.current = true
