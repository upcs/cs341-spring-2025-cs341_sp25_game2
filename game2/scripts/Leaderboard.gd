extends Node

# reference to the Firestore collection
var leaderboard_collection: FirestoreCollection

@onready var leaderboard_label = $LeaderboardLabel
@onready var username_label = $UsernameLabel
@onready var score_input = $ScoreLabelContent
@onready var submit_button = $SubmitButton
@onready var info_label = $InfoLabel
@onready var _delta = 10.0

const COLLECTION_NAME = "leaderboard"
const MAX_ENTRIES = 10
const MAX_USERNAME_LENGTH = 20

func _ready():
	# initialize the Firestore collection
	leaderboard_collection = Firebase.Firestore.collection(COLLECTION_NAME)
	
	username_label.text = "Username: " + Global.username
	
	score_input.text = str(Global.score)
	
	# fetch and display the leaderboard initially
	await fetch_and_display_leaderboard()

# Fetch the top 5 scores from Firestore and display them
func fetch_and_display_leaderboard():
	# Create a query to get the top 5 scores, ordered by score descending
	var query = FirestoreQuery.new()
	query.from(COLLECTION_NAME, false)
	query.order_by("score", FirestoreQuery.DIRECTION.DESCENDING)
	query.limit(MAX_ENTRIES)
	
	# Execute the query
	var results = await Firebase.Firestore.query(query)
	
	# Process the results into a readable format
	var leaderboard_text = ""
	if results.is_empty():
		leaderboard_text += "No scores yet"
	else:
		var j = 0;
		for i in range(results.size()):
			var doc: FirestoreDocument = results[i]
			var username = doc.doc_name
			var score = doc.get_value("score")
			# only display score if it's over 0
			if (score > 0):
				leaderboard_text += "%d. %s - %d\n" % [j + 1, username, score]
				j += 1
		if j == 0:
			leaderboard_text += "No scores yet"
	
	# update the leaderboard
	leaderboard_label.text = leaderboard_text

# handle score submission when the button is pressed
func _on_submit_button_pressed():
	
	var username = Global.username
	if username == null:
		print('No username input')
		return
	
	# validate input
	if username == "":
		print("Username cannot be empty!")
		info_label.text = "Username cannot be empty"
		return
		
	# submit the score
	await submit_score(username, Global.score)
	
	info_label.text = "Successfully Submitted"
	
	# refresh the leaderboard after submission
	await fetch_and_display_leaderboard()
	

# submit a score to Firestore, updating only if higher than the existing score
func submit_score(username: String, score: int):
	# check if the username already exists
	var existing_doc = await leaderboard_collection.get_doc(username)
	
	if existing_doc != null:
		# document exists, check the current score
		var current_score = existing_doc.get_value("score")
		if current_score != null and score <= current_score:
			print("Submitted score (%d) is not higher than existing score (%d) for %s" % [score, current_score, username])
			return
		
		# update the existing document with the new higher score
		existing_doc.add_or_update_field("score", score)
		await leaderboard_collection.update(existing_doc)
		print("Updated score for %s to %d" % [username, score])
	else:
		# document doesn't exist, add a new one 	
		var new_data = {"score": score}
		var new_doc = await leaderboard_collection.add(username, new_data)
		print("Added new score for %s: %d" % [username, score])


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://start.tscn")
