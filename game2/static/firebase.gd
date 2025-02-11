extends Node
# Allows interaction with firebase/firestore

# Called when the node enters the scene tree for the first time
func _ready():
	print("Firebase Manager Ready")

# Function to add data to Firestore
func add_data_to_firestore():
	var js_code = """
	(async () => {
		const docRef = firestore.collection('players').doc();
		await docRef.set({
			name: 'Joshua',
			score: 1000
		});
		console.log('Document written with ID: ', docRef.id);
	})();
	"""
#	Don't worry about the error, it works in HTML5
	JavaScript.eval(js_code, true)  # Execute the JavaScript code

# Function to read data from Firestore
func get_data_from_firestore():
	var js_code = """
	(async () => {
		const docRef = firestore.collection('players').doc('your-document-id');
		const docSnap = await docRef.get();
		if (docSnap.exists()) {
			console.log('Document data:', docSnap.data());
		} else {
			console.log('No such document!');
		}
	})();
	"""
	#	Don't worry about the error, it works in HTML5
	JavaScript.eval(js_code, true)  # Execute the JavaScript code
