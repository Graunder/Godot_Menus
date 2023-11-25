extends Control

@onready var main = $".."

func _on_play_pressed():
#	get_tree().change_scene_to_file("res://Assets/Scenes/Levels/DEV_Level.tscn")
	main.load_dev_scene()

func _on_quit_pressed():
	get_tree().quit()
