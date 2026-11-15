extends Node3D

func _ready():
	$"time bomb".queue_free()
