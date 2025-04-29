extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Update score for level 3
		Global.shiley_lvl3_score = 125
		Global.update_score() # score update call
		get_tree().change_scene_to_file("res://s_mini_game.tscn")
