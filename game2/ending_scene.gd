extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Update score for level 4
		Global.shiley_lvl4_score = 225
		Global.update_score() # score update call
		get_tree().change_scene_to_file("res://you_Win_Shiley.tscn")
