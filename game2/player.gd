extends CharacterBody2D
var sprite
func _ready() -> void:
	sprite = $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("up"): 
		sprite.play("new_animation")
		position.y -= 10
	elif Input.is_action_pressed("down"):
		sprite.play("new_animation")
		position.y += 10
	elif Input.is_action_pressed("right"):
		sprite.play("new_animation")
		position.x += 10
	elif Input.is_action_pressed("left"):
		sprite.play("new_animation")
		position.x -= 10
	else:
		sprite.play("default")
	move_and_slide()

func takehit():
	pass
