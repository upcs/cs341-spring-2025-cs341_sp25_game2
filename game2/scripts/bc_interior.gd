extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preload("res://scenes/campus.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_buckley_entrance_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("Body entered:", body.name)  # Print the name of the body entering the area
	if body.is_in_group("Player"):
		print("Player entered. Changing spawn and changing scene...")
		#Global.spawn_position = Vector2(2400, 940)
		get_tree().change_scene_to_file("res://scenes/campus.tscn")
	else:
		print("This body is not in the Player group")
