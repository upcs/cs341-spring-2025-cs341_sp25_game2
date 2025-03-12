extends CharacterBody2D

class_name Player

var sprite
var target_position = Vector2.ZERO
var is_moving_to_target = false

func _ready() -> void:
	sprite = $AnimatedSprite2D
	add_to_group("Player")
	target_position = global_position

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		# convert screen coordinates to world coordinates
		var camera = get_viewport().get_camera_2d()
		if camera:
			target_position = camera.get_global_mouse_position()
		else:
			target_position = get_global_transform().affine_inverse() * event.position
		is_moving_to_target = true
		print("Tapped at (world): ", target_position)

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	# keyboard controls
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	
	var speed = 550.0
	
	# handle tap movement
	if is_moving_to_target:
		direction = (target_position - global_position).normalized()
		var distance = global_position.distance_to(target_position)
		
		if distance < 10:
			is_moving_to_target = false
			direction = Vector2.ZERO
	
	# apply movement
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		sprite.play("default")
	
	move_and_slide()

func takehit():
	return "hit taken"
