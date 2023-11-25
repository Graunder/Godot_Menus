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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
