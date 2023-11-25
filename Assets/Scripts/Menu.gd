extends Control

@onready var main = $".."
@onready var play = $MarginContainer/VBoxContainer/Play
@onready var resume = $MarginContainer/VBoxContainer/Resume
@onready var give_up = $MarginContainer/VBoxContainer/Give_Up
@onready var quit = $MarginContainer/VBoxContainer/Quit

func _on_play_pressed():
	main.load_dev_scene()

func _on_quit_pressed():
	get_tree().quit()
	
func _on_resume_pressed():
	main.game_pause(false)
	
func _on_give_up_pressed():
	pass # Replace with function body.

func switch_play_button(switch_buttons : bool):
	if switch_buttons:
		play.hide()
		resume.show()
		give_up.show()
	else:
		play.show()
		resume.hide()
		give_up.hide()




