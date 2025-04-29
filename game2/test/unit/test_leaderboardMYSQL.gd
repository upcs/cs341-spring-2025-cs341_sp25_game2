extends GutTest

@onready var http_request = HTTPRequest.new()

# School URL - works when on UP school wifi
const SERVER_URL = "http://10.12.116.30/leaderboard.php"

const MAX_ENTRIES = 10
const MAX_USERNAME_LENGTH = 20

var response = 429 # http response


func _ready():
	super._ready()
	add_child(http_request)
		
	# Connect HTTP request signal
	http_request.request_completed.connect(_on_request_completed)

# Fetch and display leaderboard
func test_fetch_and_display_leaderboard():
	http_request.request(SERVER_URL, [], HTTPClient.METHOD_GET)
	await http_request.request_completed
	assert_eq(response, 200, "Response code incorrect, database not reachable")
	# Response handling is in _on_request_completed
	http_request.queue_free()

# Handle HTTP responses
func _on_request_completed(result, response_code, headers, body) -> int:
	response = response_code
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
		elif json is Dictionary and json.get("success", false):  # Score submission response from POST
			print("Score submitted successfully")
			await test_fetch_and_display_leaderboard()  # Refresh leaderboard only on successful submission
	elif response_code == 429:  # Rate limit exceeded
		print("Rate limit exceeded: Try again later")
	else:
		print("Request failed with code: ", response_code)
		
	return response_code
