extends Label

# https://godotshaders.com/shader/spatial-starfield/

@onready var animation_player: AnimationPlayer = $"../ColorRect/AnimationPlayer"

func _ready():
	
	visible_characters = 0
	$DeathTimer.start(1.0)
	await $DeathTimer.timeout
	
	while(visible_characters <= 7):
		$DeathTimer.start(0.1)
		await $DeathTimer.timeout
		visible_characters += 1
