extends CharacterBody2D

@export var speed: float = 200.0
var agent: NavigationAgent2D
var last_player_position: Vector2

func _ready():
	add_to_group("Enemy")
	agent = $NavigationAgent2D  # Link the NavigationAgent2D node
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		last_player_position = player.global_position
		agent.target_position = player.global_position

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
	
	# Repath if player moved far enough
	if last_player_position.distance_to(player.global_position) > 20:
		agent.target_position = player.global_position
		last_player_position = player.global_position

	if not agent.is_navigation_finished():
		var next_path_point = agent.get_next_path_position()
		var direction_to_next_point = (next_path_point - global_position).normalized()
		velocity = direction_to_next_point * speed
		move_and_slide()
		
		look_at(next_path_point)
		rotation_degrees += 180  

func _on_area_2d_body_entered(body):
	if "bullet" in body.name:
		queue_free()
