extends RigidBody3D

@export var speed: float = 10.0
@export var arena_top_y: float = 8.0
@export var respawn_delay: float = 1.0

var score_label: Label
var paddle: CharacterBody3D
var miss_detector: Area3D
var score: int = 0
var respawning: bool = false
var telemetry := {
	"level_number": 1,
	"buttons_available": 2,
	"ball_touch_count": 0,
	"ball_miss_count": 0,
	"ball_drop_frequency": [],
	"reaction_panel_events": [],
	"timestamps": [],
	"ball_score_events": []
}

func _ready():
	contact_monitor = true
	max_contacts_reported = 5
	
	await get_tree().process_frame

	var level = get_parent()
	score_label = level.get_node("UI/HUD/ScoreLabel") as Label
	paddle = level.get_node("Paddle") as CharacterBody3D
	miss_detector = level.get_node("Arena/MissDetector") as Area3D

	# Connect signals dynamically
	if miss_detector:
		miss_detector.body_entered.connect(_on_miss_detector_body_entered)
	else:
		push_error("Miss Detector not found!")
	self.body_entered.connect(_on_ball_body_entered)

	respawn_ball()
	gravity_scale = 0
	update_score_label()

func _physics_process(delta):
	linear_velocity = linear_velocity.normalized() * speed

func _on_ball_body_entered(body: Node) -> void:
	print(body, "body")
	if body == paddle:
		print("hit")
		
		var score_before = score
		
		score += 5
		update_score_label()
		
		telemetry["ball_score_events"].append({
			"type": "Paddle Hit",
			"score_before": score_before,
			"score_after": score,
			"score_change": 5,
			"miss_distance": 0,
			"miss_category": "NA",
			"timestamp": Time.get_time_dict_from_system()
		})
		telemetry["ball_touch_count"] += 1
		
	# Update telemetry
	#telemetry["ball_touch_count"] += 1
	#telemetry["timestamps"].append({
		#"event": "ball_touch",
		#"time": Time.get_time_dict_from_system()
	#})
		
func reset_ball_immediately():
	show_miss_message()
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = true
	
	await get_tree().create_timer(0.15).timeout

	# Teleport
	global_position = Vector3(0, arena_top_y, 0)

	#await get_tree().process_frame
	sleeping = false

	var dir_x = randf_range(-0.8, 0.8)
	var dir_y = -1.0
	linear_velocity = Vector3(dir_x, dir_y, 0).normalized() * speed

func classify_miss_distance(ball_x: float, paddle_x: float) -> Dictionary:
	var distance = abs(ball_x - paddle_x)

	var label := ""
	if distance < 0.5:
		label = "Very Close"
	elif distance < 1.5:
		label = "Close"
	elif distance < 2:
		label = "Far"
	else:
		label = "Very Far"

	return {
		"distance": distance,
		"category": label
	}

func _on_miss_detector_body_entered(body: Node) -> void:
	if body == self:
		var score_before = score
		var score_change = 0
		
		var miss_info = classify_miss_distance(
			global_position.x,
			paddle.global_position.x
		)
		
		telemetry["ball_score_events"].append({
			"type": "Paddle Miss",
			"score_before": score_before,
			"score_after": score,
			"score_change": score_change,
			"miss_distance": miss_info.distance,
			"miss_category": miss_info.category,
			"timestamp": Time.get_time_dict_from_system()
		})
		
		telemetry["ball_miss_count"] += 1
		#telemetry["ball_drop_frequency"].append(Time.get_time_dict_from_system())
		#telemetry["timestamps"].append({
			#"event": "ball_missed",
			#"time": Time.get_time_dict_from_system()
		#})
		reset_ball_immediately()

func respawn_ball():
	position = Vector3(0, arena_top_y, 0)
	var rand_x = randf_range(0.5, 1.0) * (1 if randi() % 2 == 0 else -1)
	var rand_y = randf_range(0.3, 1.0) * -1
	linear_velocity = Vector3(rand_x, rand_y, 0).normalized() * speed

func show_miss_message():
	score_label.text = "MISS!"
	await get_tree().create_timer(respawn_delay).timeout
	update_score_label()

func update_score_label():
	score_label.text = "Score: %d" % score
