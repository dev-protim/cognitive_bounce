extends Node3D

@export var ball: RigidBody3D = null
@onready var reaction_panel = $UI/HUD/ReactionPanel
@onready var level_complete_label = $UI/HUD/CompleteLabel

var score: int = 0
var score_before_panel: int = 0
var panel_active: bool = false

func _ready() -> void:
	reaction_panel.visible = false
	reaction_panel.finished.connect(_on_reaction_finished)
	level_complete_label.visible = false

	# Start the first Hick-Hyman cycle
	start_hick_hyman_cycle()

func start_hick_hyman_cycle() -> void:
	# Wait 10 seconds of gameplay
	await get_tree().create_timer(10.0).timeout

	# Pause game
	get_tree().paused = true

	# Capture current score from Ball
	score_before_panel = ball.score

	# Pick a random correct button
	var correct_button = ["RedButton", "BlueButton"][randi() % 2]
	reaction_panel.start(correct_button)

func print_full_telemetry() -> void:
	print("=== FULL LEVEL TELEMETRY ===")
	print("Level:", ball.telemetry.level_number)
	print("Buttons:", ball.telemetry.buttons_available)
	print("Ball touches:", ball.telemetry.ball_touch_count)
	print("Ball misses:", ball.telemetry.ball_miss_count)
	print("Ball drop times:", ball.telemetry.ball_drop_frequency)
	print("Reaction panel events:")
	for e in ball.telemetry.reaction_panel_events:
		print(e)
	print("Timestamps of all events:")
	for t in ball.telemetry.timestamps:
		print(t)

func _on_reaction_finished(success: bool, reaction_time: float) -> void:
	
	
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
	ball.telemetry["reaction_panel_events"].append({
		"success": success,
		"reaction_time": reaction_time,
		"score_before": score_before_panel,
		"score_after": ball.score,
		"score_change": points_change,
		"timestamp": Time.get_time_dict_from_system()
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
	level_complete_label.visible = true

	#print_full_telemetry()
	save_telemetry_html()
	get_tree().paused = true
	#start_hick_hyman_cycle()  # schedule next panel
	
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

	html_content += "<p><b>Level:</b> %s</p>" % ball.telemetry.level_number
	html_content += "<p><b>Buttons available:</b> %s</p>" % str(ball.telemetry.buttons_available)
	html_content += "<p><b>Ball touches:</b> %s</p>" % str(ball.telemetry.ball_touch_count)
	html_content += "<p><b>Ball misses:</b> %s</p>" % str(ball.telemetry.ball_miss_count)
	html_content += "<p><b>Ball drop times:</b> %s</p>" % str(ball.telemetry.ball_drop_frequency)

	html_content += "<h2>Reaction Panel Events</h2><ul>"
	for e in ball.telemetry.reaction_panel_events:
		html_content += "<li>Success: %s, Reaction Time: %.2f, Score Before: %d, Score After: %d, Change: %d, Timestamp: %s</li>" % [
			str(e.success), e.reaction_time, e.score_before, e.score_after, e.score_change, str(e.timestamp)
		]
	html_content += "</ul>"

	html_content += "<h2>Timestamps</h2><ul>"
	for t in ball.telemetry.timestamps:
		html_content += "<li>%s</li>" % str(t)
	html_content += "</ul>"

	html_content += "</body></html>"

	html_file.store_string(html_content)
	html_file.close()

	print("Telemetry saved to:", file_path)



func update_score_label() -> void:
	$UI/HUD/ScoreLabel.text = "Score: %d" % score
