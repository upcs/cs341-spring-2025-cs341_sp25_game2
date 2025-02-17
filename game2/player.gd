extends CharacterBody2D

class_name Player

var sprite
func _ready() -> void:
	sprite = $AnimatedSprite2D
	add_to_group("Player")

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("up"): 
		position.y -= 10
	if Input.is_action_pressed("down"):
		position.y += 10
	if Input.is_action_pressed("right"):
		position.x += 10
	if Input.is_action_pressed("left"):
		position.x -= 10
	else:
		sprite.play("default")
	move_and_slide()

func takehit():
	return "hit taken"
