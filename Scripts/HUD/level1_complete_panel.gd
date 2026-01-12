extends Panel

@export var label: Label = null 

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

func _on_play_again_button_pressed() -> void:
	print("hello play again")
	get_tree().paused = false
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _on_next_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_02.tscn")
	pass # Replace with function body.


func _on_play_again(isPlay: bool) -> void:
	pass # Replace with function body.
