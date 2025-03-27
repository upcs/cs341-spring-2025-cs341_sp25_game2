extends CharacterBody2D



func _physics_process(delta: float) -> void:
	velocity = Input.get_vector("up","right","down","left").normalized()*150
	move_and_slide()
