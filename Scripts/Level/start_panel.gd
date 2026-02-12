extends Panel

@export var name_input: LineEdit = null
@export var start_btn: Button = null

var player_name: String = ""

func _ready():
	pass


func _on_start_button_pressed() -> void:
	player_name = name_input.text.strip_edges()

	if player_name == "":
		name_input.placeholder_text = "Please enter your name"
		return

	# Store name temporarily in SceneTree metadata
	get_tree().set_meta("player_name", player_name)

	# Go to Level 1
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_01.tscn")
