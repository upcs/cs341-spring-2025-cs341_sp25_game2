extends CharacterBody2D

@export var speed: float = 50.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	add_to_group("Enemy")
	nav_agent.path_desired_distance = 4.0
	nav_agent.avoidance_enabled = false

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return

	# Update path destination
	nav_agent.target_position = player.global_position

	# If no path or already reached destination, do nothing
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()

	velocity = direction * speed
	move_and_slide()

	# Optional: Face the movement direction
	look_at(next_point)
