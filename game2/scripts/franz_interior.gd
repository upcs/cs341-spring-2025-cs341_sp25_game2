extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_minigame_entrance_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name)  # Print the name of the body entering the area
	if body.is_in_group("Player"):
		print("Player entered. Changing spawn and changing scene...")
		#Global.spawn_position = Vector2(2400, 940)
		get_tree().change_scene_to_file("res://scenes/mainRun.tscn")
	else:
		print("This body is not in the Player group")

func _on_franz_exit_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	print("Body entered:", body.name)  # Print the name of the body entering the area
	if body.is_in_group("Player"):
		print("Player entered. Changing spawn and changing scene...")
		Global.spawn_position = Vector2(3712, 1856)
		get_tree().change_scene_to_file("res://scenes/campus.tscn")
	else:
		print("This body is not in the Player group")
