extends Label

# https://godotshaders.com/shader/spatial-starfield/

@onready var animation_player: AnimationPlayer = $"../ColorRect/AnimationPlayer"

func _ready():
	
	visible_characters = 0
	%Button.visible = false
	
	%AnimationPlayer.play("fade")
	$DeathTimer.start(2.0)
	await $DeathTimer.timeout
	
	while(visible_characters <= 9):
		$DeathTimer.start(0.1)
		await $DeathTimer.timeout
		visible_characters += 1
		
	$DeathTimer.start(1.0)
	await $DeathTimer.timeout
	
	while(visible_characters <= 20):
		$DeathTimer.start(0.1)
		await $DeathTimer.timeout
		visible_characters += 1

	$DeathTimer.start(1.0)
	await $DeathTimer.timeout
	
	%Button.visible = true
