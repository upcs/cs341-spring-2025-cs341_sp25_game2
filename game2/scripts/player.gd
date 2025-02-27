extends CharacterBody2D

class_name Player

var sprite
func _ready() -> void:
	sprite = $AnimatedSprite2D
	add_to_group("Player")

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	
	
	var speed = 550.0
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		sprite.play("default")
	
	# Move the character
	move_and_slide()

func takehit():
	return "hit taken"
