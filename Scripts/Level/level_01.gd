extends Node3D

@export var config: GameConfig = null

@export var ball: RigidBody3D = null
@onready var reaction_panel = $UI/HUD/ReactionPanel
@onready var current_level = $UI/HUD/LabelName

@onready var level_complete_panel = $UI/HUD/LevelCompletePanel
var level_finished := false

var correct_button_id: String = ""

var score: int = 0
var score_before_panel: int = 0
var panel_active: bool = false

func _ready() -> void:
	if config == null:
		push_error("Config not assigned in Inspector!")
		return
	
	current_level.text = "Level %d" % config.level_number
	ball.speed = config.game_speed
	
	reaction_panel.visible = false
	level_complete_panel.visible = false
	reaction_panel.finished.connect(_on_reaction_finished)

	# Start the first Hick-Hyman cycle
	start_hick_hyman_cycle()

func start_hick_hyman_cycle() -> void:
	await get_tree().create_timer(config.game_duration).timeout

	# Pause game
	get_tree().paused = true

	# Capture current score from Ball
	score_before_panel = ball.score

	# Pick a random correct button
	#var correct_button = config.buttons[randi() % config.buttons.size()]
	#
	#reaction_panel.start(correct_button, config.buttons)
	correct_button_id = config.choices[randi() % config.choices.size()]["id"]

	reaction_panel.start(correct_button_id, config.choices)

func print_full_telemetry() -> void:
	print("=== FULL LEVEL TELEMETRY ===")
	print("Level:", ball.telemetry.level_number)
	print("Buttons:", ball.telemetry.buttons_available)
	print("Ball touches:", ball.telemetry.ball_touch_count)
	print("Ball misses:", ball.telemetry.ball_miss_count)
	#print("Ball drop times:", ball.telemetry.ball_drop_frequency)
	print("Reaction panel events:")
	for e in ball.telemetry.reaction_panel_events:
		print(e)
	print("Timestamps of all events:")
	for t in ball.telemetry.timestamps:
		print(t)

func _on_reaction_finished(success: bool, reaction_time: float, selected_id: String) -> void:
	print("working now")
	
	var points_change = 0

	#if success:
		#var points = max(0, 10 - int(reaction_time))
		#ball.score += points
	#else:
		#ball.score -= 10
	if success:
		points_change = int(10 - reaction_time)  # Points based on reaction
		ball.score += points_change
	else:
		points_change = -10
		ball.score = max(0, ball.score + points_change)
		
	ball.update_score_label()
		
	# Update telemetry
	#ball.telemetry["reaction_panel_events"].append({
		#"success": success,
		#"reaction_time": reaction_time,
		#"score_before": score_before_panel,
		#"score_after": ball.score,
		#"score_change": points_change,
		#"timestamp": Time.get_time_dict_from_system()
	#})
	ball.telemetry["reaction_panel_events"].append({
		"level_number": config.level_number,
		"num_buttons": config.choices.size(),
		"correct_button": correct_button_id,
		"selected_button": selected_id,
		"success": success,

		"reaction_time_sec": reaction_time,             # time taken to click
		"points_earned": points_change,                  # points achieved/lost

		"score_before": score_before_panel,
		"score_after": ball.score,
		"timestamp": Time.get_datetime_dict_from_system(),
		"panel_shown_time": reaction_panel.panel_shown_time_dict
	})

	#print("--- Panel Result ---")
	#print("Success:", success)
	#print("Reaction Time:", reaction_time)
	#print("Score before panel:", score_before_panel)
	#print("Score after panel:", ball.score)
	#print("Points gained/lost:", points_change)
	##print("Points gained/lost:", ball.score - score_before_panel)
	#print("------")
	
	panel_active = false

	#print_full_telemetry()
	save_telemetry_html()
	#get_tree().paused = true
	
	finish_level()
	#start_hick_hyman_cycle()  # schedule next panel
	
func finish_level() -> void:
	#get_tree().paused = false
	level_complete_panel.show_panel(
		config.level_number)
	
func format_time(t: Dictionary) -> String:
	return "%02d:%02d:%02d" % [t.hour, t.minute, t.second]
		
func save_telemetry_html():
	var project_dir = ProjectSettings.globalize_path("res://")
	var result_dir = project_dir + "/Result"

	# Create Result folder if it doesn't exist
	var dir = DirAccess.open(project_dir)
	if not dir.dir_exists("Result"):
		dir.make_dir("Result")

	var file_path = result_dir + "/telemetry.html"
	var html_file = FileAccess.open(file_path, FileAccess.WRITE)

	var html_content = "<html><head><title>Level Telemetry</title></head><body>"
	html_content += "<h1>Level Telemetry</h1>"

	html_content += "<p><b>Level:</b> %s</p>" % config.level_number
	html_content += "<p><b>Buttons available:</b> %s</p>" % str(config.buttons.size())
	html_content += "<p><b>Ball touches the paddle:</b> %s</p>" % str(ball.telemetry.ball_touch_count)
	html_content += "<p><b>Ball misses the paddle:</b> %s</p>" % str(ball.telemetry.ball_miss_count)
	#html_content += "<p><b>Ball drop times:</b> %s</p>" % str(ball.telemetry.ball_drop_frequency)

	html_content += "<h2>Reaction Panel Events</h2><ul>"
	for e in ball.telemetry.reaction_panel_events:
		html_content += "<li>Correct: %s | Selected: %s | Buttons: %d | Time Taken to React: %.2f s | Points Achieved From Selection: %d | Score Before React: %d | Score After React: %d</li>" % [
			e.correct_button,
			e.selected_button,
			e.num_buttons,
			e.reaction_time_sec,
			e.points_earned,
			e.score_before,
			e.score_after
		]
	html_content += "</ul>"

	html_content += "<h2>Timestamps</h2><ul>"
	
	html_content += "<h2>Ball Events</h2>"
	html_content += "<table border='1' cellpadding='6'>"
	html_content += "<tr>
		<th>Event</th>
		<th>Score Before</th>
		<th>Score After</th>
		<th>Score Change</th>
		<th>Miss Distance</th>
		<th>Miss Type</th>
		<th>Timestamp</th>
	</tr>"

	for e in ball.telemetry.ball_score_events:
		html_content += "<tr>"
		html_content += "<td>%s</td>" % e.type
		html_content += "<td>%d</td>" % e.score_before
		html_content += "<td>%d</td>" % e.score_after
		html_content += "<td>%d</td>" % e.score_change
		html_content += "<td>%.2f</td>" % e.miss_distance
		html_content += "<td>%s</td>" % e.miss_category
		html_content += "<td>%s</td>" % format_time(e.timestamp)
		html_content += "</tr>"

	html_content += "</table>"
	
	for t in ball.telemetry.timestamps:
		html_content += "<li>%s</li>" % str(t)
	html_content += "</ul>"

	html_content += "</body></html>"

	html_file.store_string(html_content)
	html_file.close()

	print("Telemetry saved to:", file_path)



func update_score_label() -> void:
	$UI/HUD/ScoreLabel.text = "Score: %d" % score
