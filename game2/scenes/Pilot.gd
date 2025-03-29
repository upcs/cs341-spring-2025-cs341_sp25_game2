extends CharacterBody2D


const GRAVITY = 4200
const JUMP_SPEED = -1800


func _physics_process(delta: float):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("Idle")
		else:
			$PilotRun.disabled = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("Walking") #duck
				$PilotDuck.disabled = true
			else:
				$AnimatedSprite2D.play("Right") #run
	else:
		$AnimatedSprite2D.play("Idle") #jump
	move_and_slide()

#func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	#move_and_slide()
