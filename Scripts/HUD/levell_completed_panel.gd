extends Panel

#func _ready():
	#visible = false
	#process_mode = Node.PROCESS_MODE_PAUSABLE
	#pause_mode = Node.PAUSE_MODE_PROCESS
	#pause_mode = Node.PAUSE_MODE_PROCESS

func show_panel():
	print("hello panel")
	visible = true
	#get_tree().paused = true

func _on_play_again_button_pressed() -> void:
	print("getting clicked")
	#get_tree().paused = false
	get_tree().reload_current_scene()

func _on_next_level_button_pressed() -> void:
	get_tree().paused = false
	print("next level open")
	#get_tree().change_scene_to_file("res://Scenes/Level_02.tscn")
