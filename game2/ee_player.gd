extends CharacterBody2D

@export var move_speed := 600.0
@export var bullet_speed := 500.0
var bullet = preload("res://EE_Bullet.tscn")
func _ready():
	add_to_group("Player")

func _physics_process(delta):
	# Rotate to face mouse
	look_at(get_global_mouse_position())

	# Handle WASD or arrow movement
	var motion = Vector2()
	if Input.is_action_pressed("up"):
		motion.y -= 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("right"):
		motion.x += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1

	# Apply movement
	motion = motion.normalized() * move_speed
	velocity = motion
	move_and_slide()

	# Handle shooting
	if Input.is_action_just_pressed("Click"):
		fire()

func fire():
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = global_position + Vector2(20, 0).rotated(rotation)
	bullet_instance.rotation = rotation
	bullet_instance.linear_velocity = Vector2(bullet_speed, 0).rotated(rotation)
	bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().get_root().call_deferred("add_child", bullet_instance)


func kill():
	get_tree().reload_current_scene()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if "enemy" in body.name or "Enemy" in body.name:
		kill()
