extends Label

# https://godotshaders.com/shader/spatial-starfield/

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready():
	
	visible_characters = 0
	%Button.visible = false
	
	var texttoshow: int = randi_range(0,6)
	
	match texttoshow:
		0:
			text += "You died."
		1:
			text += "You were sent back in time."
		2:
			text += "No one's around to help."
		3:
			text += "You had one job."
		4:
			text += "The clock factory exploded."
		5:
			text += "You didn't rewind fast enough."
		6:
			text += "You're in a better place now."
	
	%AnimationPlayer.play("fade")
	$DeathTimer.start(2.0)
	await $DeathTimer.timeout
	
	while(visible_characters <= text.length()):
		$DeathTimer.start(0.05)
		await $DeathTimer.timeout
		visible_characters += 1
	
	text += "\n\nYou lasted:"
	text += "\n" + ("0" if Globals.finaltime < 540 else "") + str(int(Globals.finaltime/60)) + ":" + ("0" if int(Globals.finaltime) % 60 < 10 else "") + str(int(Globals.finaltime) % 60)
		
	$DeathTimer.start(1.0)
	await $DeathTimer.timeout
	
	while(visible_characters <= text.length()):
		$DeathTimer.start(0.05)
		await $DeathTimer.timeout
		visible_characters += 1

	$DeathTimer.start(1.0)
	await $DeathTimer.timeout
	
	%Button.visible = true


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://_scenes/main.tscn")
