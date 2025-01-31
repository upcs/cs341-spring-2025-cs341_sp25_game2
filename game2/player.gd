extends CharacterBody2D

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("up"): 
		position.y -= 10
	elif Input.is_action_pressed("down"):
		position.y += 10
	elif Input.is_action_pressed("right"):
		position.x += 10
	elif Input.is_action_pressed("left"):
		position.x -= 10
	move_and_slide()

func takehit():
	pass
