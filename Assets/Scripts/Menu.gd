extends Control

@onready var main = $".."
@onready var play = $MarginContainer/VBoxContainer/Play
@onready var resume = $MarginContainer/VBoxContainer/Resume

func _on_play_pressed():
	main.load_dev_scene()

func _on_quit_pressed():
	get_tree().quit()
	
func _on_resume_pressed():
	main.game_pause(false)
	
func switch_play_button(switch_buttons : bool):
	if switch_buttons:
		play.hide()
		resume.show()
	else:
		play.show()
		resume.hide()

