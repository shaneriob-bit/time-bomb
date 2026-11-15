extends Node3D



func _on_start_pressed() -> void:
	%buttonsound.play()
	%canvas1.visible = false
	%canvas2.visible = true
	
	%texttimer.start()
	while(%dialogue.visible_characters <= %dialogue.text.length()):
		await %texttimer.timeout
		%dialogue.visible_characters += 1
	
	%acknowledge.visible = true
	

func _on_acknowledge_pressed() -> void:
	%buttonsound.play()
	get_tree().change_scene_to_file("res://_scenes/main.tscn")
