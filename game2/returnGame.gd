extends Button

func _on_pressed() -> void:
	# Instead of changing scene, just unpause the game
	get_tree().paused = false

	# Hide or disable the info menu if necessary
	# (assuming your info menu is a parent or child of this button)
	get_parent().visible = false
