extends GutTest

# HTTPRequest node for testing
var http_request: HTTPRequest
var firebase: Node  # Firebase node for Firestore interactions

# Variable to store the response code
var response_code: int

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	self.response_code = response_code

func test_firestore_write_and_read():
	# Initialize HTTPRequest node
	http_request = HTTPRequest.new()
	add_child(http_request)

	# Load and instantiate the Firebase script
	var FirebaseClass = load("res://static/firebase.gd")
	firebase = FirebaseClass.new()
	add_child(firebase)
	
	# Connect signal for handling the request completion
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	
	var path = "testCollection/testDocument"
	var fields = {
		"username": { "stringValue": "test_user" },
		"score": { "integerValue": 100 }
	}

	# Save the document
	firebase.save_document(path, fields, http_request)
	await http_request.request_completed

	# Assert that the document was successfully written
	assert_eq(response_code, 200, "Document should be successfully written to Firestore")

	# Wait a few seconds to ensure the write is processed
	await get_tree().create_timer(3.0).timeout

	# Check if the document exists
	firebase.get_document(path, http_request)
	await http_request.request_completed

	# Assert that the document is found in the database
	assert_eq(response_code, 200, "Document should be found in Firestore")

	# Clean up by deleting the test document
	firebase.delete_document(path, http_request)
	await http_request.request_completed

	# Assert that the document was successfully deleted
	assert_eq(response_code, 200, "Document should be successfully deleted from Firestore")
