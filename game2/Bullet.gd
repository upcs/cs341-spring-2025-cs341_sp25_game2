extends RigidBody2D

@export var speed: float = 1000.0
@onready var sprite: AnimatedSprite2D = $Shoot

func _ready() -> void:
	if sprite:
		sprite.stop()
		sprite.play("Shoot")
		print("Playing animation: shoot")
	else:
		print("AnimatedSprite2D not found!")

	gravity_scale = 0
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	linear_velocity = Vector2.RIGHT.rotated(rotation) * speed
	add_to_group("bullet")

	await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.queue_free()
		queue_free()
