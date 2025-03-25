extends Node2D

@onready var game_over_message = $GameOverMessage
@onready var game_timer = $GameTimer
@onready var timer_label = $TimerLabel

var multiplier = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer_label.text = 	"Time: " + str(int(game_timer.time_left))


func _on_maze_exit_body_exited(body: Node2D) -> void:
	game_over_message.text = "YOU WON! Score: "
	#game_timer.get_time_left()
	
	print("Body entered:", body.name)  # Print the name of the body entering the area
	if body.is_in_group("Player"):
		print("Player entered. Changing spawn and changing scene...")
		Global.spawn_position = Vector2(1600, 192)
		get_tree().change_scene_to_file("res://scenes/campus.tscn")
	else:
		print("This body is not in the Player group")


func _on_game_timer_timeout() -> void:
	#game over
	game_over_message.text = "GAME OVER...better luck next time..."
	get_tree().change_scene_to_file("res://scenes/BC_interior.tscn")
