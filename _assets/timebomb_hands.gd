extends Node3D

@onready var parent = get_parent()
@onready var hour_hand: Node3D = $"hour hand_001"
@onready var second_hand: Node3D = $"second hand_001"

# how many seconds it takes for one "hour" to pass
@onready var sec_per_rotation: float = 4
@onready var progress: float = 0 # value from 0 to 1
@onready var reverse: int = 1 # changes to -1 if reversing

func _process(delta):
	if parent && "reverse" in parent:
		reverse = parent.reverse
	
	hour_hand.rotation.x -= ((PI/6)*delta)/sec_per_rotation*reverse
	if hour_hand.rotation.x > 0:
		hour_hand.rotation.x = 0
	progress = -1*(hour_hand.rotation_degrees.x / 360)
	
	second_hand.rotate(Vector3.LEFT,(2*PI*delta)/sec_per_rotation*reverse)
