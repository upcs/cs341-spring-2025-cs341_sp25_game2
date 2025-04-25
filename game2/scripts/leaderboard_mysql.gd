extends Node

@onready var leaderboard_label = $LeaderboardLabel
@onready var username_label = $UsernameLabel
@onready var score_input = $ScoreLabelContent
@onready var submit_button = $SubmitButton
@onready var info_label = $InfoLabel
@onready var http_request = $HTTPRequest

# School URL - works when on UP school wifi
const SERVER_URL = "https://146.235.204.13/leaderboard.php"

const MAX_ENTRIES = 10
const MAX_USERNAME_LENGTH = 20


func _ready():
	username_label.text = "Username: " + Global.username
	score_input.text = str(Global.score)
	
	# Connect HTTP request signal
	http_request.request_completed.connect(_on_request_completed)
	await fetch_and_display_leaderboard()

# Fetch and display leaderboard
func fetch_and_display_leaderboard():
	http_request.request(SERVER_URL, [], HTTPClient.METHOD_GET)
	await http_request.request_completed
	# Response handling is in _on_request_completed

# Handle score submission
func _on_submit_button_pressed():
	var username = Global.username
	if username == null or username == "":
		print("Username cannot be empty!")
		info_label.text = "Username cannot be empty"
		return
	
	var data = {"username": username, "score": Global.score}
	var headers = ["Content-Type: application/json"]
	http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	await http_request.request_completed
	# Check response in _on_request_completed; only update info_label on success

# Handle HTTP responses
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:  # Success
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json is Array:  # Leaderboard data from GET
			var leaderboard_text = ""
			if json.is_empty():
				leaderboard_text += "No scores yet"
			else:
				for i in range(min(json.size(), MAX_ENTRIES)):
					var entry = json[i]
					if int(entry["score"]) > 0:
						leaderboard_text += "%d. %s - %s\n" % [i + 1, entry["username"], entry["score"]]
				if leaderboard_text == "":
					leaderboard_text += "No scores yet"
			leaderboard_label.text = leaderboard_text
		elif json is Dictionary and json.get("success", false):  # Score submission response from POST
			print("Score submitted successfully")
			info_label.text = "Successfully Submitted"
			await fetch_and_display_leaderboard()  # Refresh leaderboard only on successful submission
	elif response_code == 429:  # Rate limit exceeded
		print("Rate limit exceeded: Try again later")
		info_label.text = "Rate limit reached. Please wait and try again."
	else:
		print("Request failed with code: ", response_code)
		info_label.text = "Error connecting to server"

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://start.tscn"))
	
