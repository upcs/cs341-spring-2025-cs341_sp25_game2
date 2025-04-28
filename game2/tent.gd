extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Update score for level 2
		Global.shiley_lvl2_score = 75
		Global.update_score() # score update call
		get_tree().change_scene_to_file("res://EE_LVL3.tscn")
