extends CharacterBody2D
@export var speed: float = 200.0

func _ready():
	add_to_group("Enemy")

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
	
	var direction_to_player = (player.global_position - global_position).normalized()
	velocity = direction_to_player * speed
	look_at(player.global_position)
	rotation_degrees += 180  # to fix enemy position
	move_and_slide()

func _on_area_2d_body_entered(body):
	if "bullet" in body.name:
		get_tree().call_group("Player", "check_win_condition")
		queue_free()
