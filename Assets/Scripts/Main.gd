extends Node

@onready var menu = $Menu
@onready var level = $Level

var level_instance

func unload_level():
	if (is_instance_valid(level_instance)):
		level_instance.queue_free()
	level_instance = null
	
func load_level(level_name : String):
	unload_level()
	var level_path := "res://Assets/Scenes/Levels/%s.tscn" % level_name
	var level_resource := load(level_path)
	if (level_resource):
		level_instance = level_resource.instantiate()
		level.add_child(level_instance)
		menu.hide()
		menu.set_process(false)

func load_dev_scene():
	load_level("DEV_Level")
	menu.switch_play_button(true)

func game_pause(should_pause : bool):
	level.get_tree().paused = should_pause
	if (should_pause):
		menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func reset_pause():
	level.get_tree().paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("esc"):
		if menu.is_visible_in_tree():
			game_pause(false)
		else:
			game_pause(true)

