extends Control
var next_scene = "res://scenes/campus.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResourceLoader.load_threaded_request(next_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(next_scene,progress)
	$ProgressBar.value = progress[0]*100
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)
