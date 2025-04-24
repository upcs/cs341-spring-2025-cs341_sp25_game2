extends Node2D
class_name Stopwatch
@onready var label = $TimeLabel
@export var start_time: float = 60.0  
var time_left = 0.0
var stopped = false
var game_over = false

func _ready():
	reset()
	start()

func _process(delta):
	if stopped:
		return
	
	time_left -= delta
	
	# Check if timer has reached zero
	if time_left <= 0:
		time_left = 0
		stopped = true
		label.text = "Timer: 00:00:000"
		game_over = true
	else:
		label.text = "Timer: " + format_time(time_left)
	
	# Separate if statement to handle game restart
	if game_over:
		get_tree().reload_current_scene()

func reset():
	time_left = start_time
	label.text = "Timer: " + format_time(time_left)
	game_over = false

func stop():
	stopped = true

func start():
	stopped = false

func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	var ms = int((seconds - int(seconds)) * 1000)  
	return "%02d:%02d:%03d" % [mins, secs, ms]
