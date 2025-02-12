extends GutTest

var http : HTTPRequest = HTTPRequest.new()

var firebase_script = load("res://static/firebase.gd")
var firebase_instance = firebase_script.new()

# still working on this
#func test_database_write():
	#var dict = {
		#"username": "uncle bob",
		#"score": 500
	#}
	#
	#firebase_instance.save_document("MinigameLeaderboard", )
