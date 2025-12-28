extends Panel

signal finished(success: bool, reaction_time: float)

@export var instruction_label: Label = null
@export var countdown_label: Label = null
@export var button_container: HBoxContainer = null

var active := false
var correct_button := ""
var start_time := 0
var countdown := 10

func start(correct_name: String) -> void:
	visible = true
	active = true
	correct_button = correct_name
	countdown = 10
	start_time = Time.get_ticks_msec()

	instruction_label.text = "Please select %s:" % correct_button.replace("Button", "")
	countdown_label.text = str(countdown)

	_countdown_loop()

func _countdown_loop() -> void:
	while countdown > 0 and active:
		await get_tree().create_timer(1.0).timeout
		countdown -= 1
		countdown_label.text = str(countdown)

	if active:
		_finish(false, 10.0)


func _finish(success: bool, reaction_time: float) -> void:
	active = false
	visible = false
	emit_signal("finished", success, reaction_time)


func _on_red_button_pressed() -> void:
	_handle_button("RedButton")


func _on_blue_button_pressed() -> void:
	_handle_button("BlueButton")
	
func _handle_button(button_name: String):
	if not active:
		return
	active = false
	var rt = (Time.get_ticks_msec() - start_time) / 1000.0
	_finish(button_name == correct_button, rt)
