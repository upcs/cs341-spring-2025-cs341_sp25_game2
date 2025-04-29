extends GutTest

# reference to the Firestore collection
var leaderboard_collection: FirestoreCollection

@onready var _delta = 10.0
@onready var random_int = randi_range(-100, -1)

const COLLECTION_NAME = "leaderboard"
const MAX_ENTRIES = 2
const MAX_USERNAME_LENGTH = 20

func _ready():
	super._ready()
	randomize()

func test_leaderboard():
	# initialize the Firestore collection
	leaderboard_collection = Firebase.Firestore.collection(COLLECTION_NAME)
	
	# test leadderboard retrieval
	await submit_score("test_user", random_int)
	
	# fetch and display the leaderboard initially
	await fetch_leaderboard()

# Fetch the top 5 scores from Firestore and display them
func fetch_leaderboard():
	# Create a query to get the top 5 scores, ordered by score descending
	var query = FirestoreQuery.new()
	query.from(COLLECTION_NAME, false)
	 
	# test ascending order
	query.order_by("score", FirestoreQuery.DIRECTION.ASCENDING)
	query.limit(MAX_ENTRIES)
	
	# Execute the query
	var results = await Firebase.Firestore.query(query)
	
	# Process the results into a readable format
	var doc: FirestoreDocument = results[0]
	var username = doc.doc_name
	print(username)
	var score = doc.get_value("score")
	
	assert_eq(score, random_int, "Score for test player is innacurate")
	

# submit a score to Firestore, updating only if higher than the existing score
func submit_score(username: String, score: int):
	# check if the username already exists
	var existing_doc = await leaderboard_collection.get_doc(username)
	
	if existing_doc != null:
		# document exists, check the current score
		var current_score = existing_doc.get_value("score")
		
		# update the existing document with the new score
		existing_doc.add_or_update_field("score", score)
		await leaderboard_collection.update(existing_doc)
		print("Updated score for %s to %d" % [username, score])
	else:
		# document doesn't exist, add a new one 	
		var new_data = {"score": score}
		var new_doc = await leaderboard_collection.add(username, new_data)
		print("Added new score for %s: %d" % [username, score])
