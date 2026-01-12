extends Panel

signal finished(success: bool, reaction_time: float, selected_id: String)

@export var instruction_label: Label = null
@export var countdown_label: Label = null
@export var button_container: FlowContainer = null

var active := false
var correct_button := ""
var start_time := 0
var countdown := 10

var panel_shown_time_dict: Dictionary

func start(correct_name: String, choices: Array[Dictionary]) -> void:
	visible = true
	active = true
	correct_button = correct_name
	countdown = 10
	start_time = Time.get_ticks_msec()

	instruction_label.text = "Please select %s:" % correct_button.replace("Button", "")
	countdown_label.text = str(countdown)
	
	panel_shown_time_dict = Time.get_datetime_dict_from_system()

	_build_buttons(choices)
	_countdown_loop()

func _build_buttons(choices: Array[Dictionary]) -> void:
	# clear old
	for c in button_container.get_children():
		c.queue_free()

	for choice in choices:
		var id: String = choice.get("id", "")
		print(id, "id")
		var txt: String = choice.get("text", id)
		var col: Color = choice.get("color", Color.WHITE)
		print(col, " color from choice")

		var b := Button.new()
		b.name = id
		b.text = txt
		b.custom_minimum_size = Vector2(90, 33)

		# color styling
		b.add_theme_color_override("font_color", Color.WHITE)
		b.add_theme_color_override("font_pressed_color", Color.WHITE)
		b.add_theme_color_override("font_hover_color", Color.WHITE)
		b.add_theme_color_override("font_disabled_color", Color(1,1,1,0.6))

		# background colors
		var normal := StyleBoxFlat.new()
		print(col, " color")
		normal.bg_color = col
		normal.corner_radius_top_left = 5
		normal.corner_radius_top_right = 5
		normal.corner_radius_bottom_left = 5
		normal.corner_radius_bottom_right = 5

		var hover := normal.duplicate()
		hover.bg_color = col.lightened(0.15)

		var pressed := normal.duplicate()
		pressed.bg_color = col.darkened(0.15)

		b.add_theme_stylebox_override("normal", normal)
		b.add_theme_stylebox_override("hover", hover)
		b.add_theme_stylebox_override("pressed", pressed)
		b.add_theme_stylebox_override("focus", normal)

		b.pressed.connect(func(): _handle_button(id))
		button_container.add_child(b)

func _countdown_loop() -> void:
	while countdown > 0 and active:
		await get_tree().create_timer(1.0).timeout
		countdown -= 1
		countdown_label.text = str(countdown)

	if active:
		_finish(false, 10.0, "timeout")


func _finish(success: bool, reaction_time: float, selected_id: String) -> void:
	active = false
	visible = false
	emit_signal("finished", success, reaction_time, selected_id)


func _on_red_button_pressed() -> void:
	_handle_button("RedButton")


func _on_blue_button_pressed() -> void:
	_handle_button("BlueButton")
	
func _handle_button(button_id: String) -> void:
	print(correct_button, " " ,button_id, ", button clicked")
	if not active:
		return
	active = false
	var rt = (Time.get_ticks_msec() - start_time) / 1000.0
	_finish(button_id == correct_button, rt, button_id)
#func _handle_button(button_name: String):
	#if not active:
		#return
	#active = false
	#var rt = (Time.get_ticks_msec() - start_time) / 1000.0
	#_finish(button_name == correct_button, rt)
