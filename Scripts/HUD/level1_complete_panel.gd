extends Panel

@export var label: Label = null 
@export var next_level_button: Button = null
@export var start_over_button: Button = null
var level_counter: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_panel(level_number: int):
	print("hello panel")
	visible = true
	label.text = "Level %d Complete" % level_number
	level_counter = level_number
	
	if level_counter > 2:
		next_level_button.visible = false
		start_over_button.visible = true
	else:
		next_level_button.visible = true
		start_over_button.visible = false

func _on_play_again_button_pressed() -> void:
	print("hello play again")
	get_tree().paused = false
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _on_next_level_button_pressed() -> void:
	if next_level_button.visible:
		get_tree().paused = false
		#print("hi pranto in next level")
		var next_level = level_counter + 1
		var scene_path = "res://Scenes/Levels/Level_%02d.tscn" % next_level
		print("Loading:", scene_path)
		get_tree().change_scene_to_file(scene_path)



func _on_start_over_button_pressed() -> void:
	if start_over_button.visible:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://Scenes/Levels/Level_01.tscn")
