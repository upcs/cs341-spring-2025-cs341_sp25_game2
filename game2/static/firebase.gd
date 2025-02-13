extends Node

const API_KEY := "AIzaSyCA5-YDrYOmpiS6KNq-dQDVCByr_Cnrtn0"
const PROJECT_ID := "upgame-f59f3"

const FIRESTORE_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % PROJECT_ID

func _get_request_headers() -> PackedStringArray:
	return PackedStringArray([
		"Content-Type: application/json"
	])


func save_document(path: String, fields: Dictionary, http: HTTPRequest) -> void:
	var document := { "fields": fields }
	var body := JSON.stringify(document)
	var url := FIRESTORE_URL + path
	http.request(url, _get_request_headers(), HTTPClient.METHOD_POST, body)

func get_document(path: String, http: HTTPRequest) -> void:
	var url := FIRESTORE_URL + path
	http.request(url, _get_request_headers(), HTTPClient.METHOD_GET)

func update_document(path: String, fields: Dictionary, http: HTTPRequest) -> void:
	var document := { "fields": fields }
	var body := JSON.stringify(document)
	var url := FIRESTORE_URL + path
	http.request(url, _get_request_headers(), HTTPClient.METHOD_PATCH, body)

# not going to use, but keeping for convenience
func delete_document(path: String, http: HTTPRequest) -> void:
	var url := FIRESTORE_URL + path
	http.request(url, _get_request_headers(), HTTPClient.METHOD_DELETE)
