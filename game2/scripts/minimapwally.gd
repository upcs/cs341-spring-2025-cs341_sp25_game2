extends CharacterBody2D



func _physics_process(delta: float) -> void:
	velocity = Input.get_vector("left", "right", "up", "down").normalized()*200
	move_and_slide()
