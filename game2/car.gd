extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Update score for level 1
		Global.shiley_lvl1_score = 50
		Global.update_score() # score update call
		get_tree().change_scene_to_file("res://ME_LVL2.tscn")
