extends Control

@onready var main = $".."

#Menus
@onready var main_menu = $MainMenu
@onready var options_menu = $OptionsMenu

#Main menu buttons
@onready var play = $MainMenu/MainContainer/Play
@onready var resume = $MainMenu/MainContainer/Resume
@onready var give_up = $MainMenu/MainContainer/Give_Up
@onready var options = $MainMenu/MainContainer/Options
@onready var quit = $MainMenu/MainContainer/Quit

#Options menu buttons
@onready var back = $OptionsMenu/VBoxContainer/HBoxContainer/Back
@onready var apply = $OptionsMenu/VBoxContainer/HBoxContainer/Apply

func _on_play_pressed():
	main.load_dev_scene()

func _on_quit_pressed():
	get_tree().quit()

func _on_resume_pressed():
	main.game_pause(false)

func _on_give_up_pressed():
	main.unload_level()
	main.reset_pause()
	switch_play_button(false)

func _on_options_pressed():
	enable_options_menu(true)

func _on_back_pressed():
	enable_options_menu(false)

func _on_apply_pressed():
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

func enable_options_menu(enable_options : bool):
	if enable_options:
		main_menu.hide()
		options_menu.show()
	else:
		options_menu.hide()
		main_menu.show()
