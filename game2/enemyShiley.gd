extends CharacterBody2D

@export var speed: float = 200.0
@onready var agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	add_to_group("Enemy")
	agent.target_position = global_position  # Prevent warning until player is found

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return

	# Update target position to follow the player
	agent.target_position = player.global_position

	# Get direction to next path point
	var next_path_position = agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	look_at(next_path_position)
	rotation_degrees += 180  # optional fix for enemy facing

func _on_area_2d_body_entered(body):
	if "bullet" in body.name:
		queue_free()
