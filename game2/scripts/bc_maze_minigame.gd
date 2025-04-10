extends Node2D

@onready var game_over_message = $GameOverMessage
@onready var game_timer = $GameTimer
@onready var timer_label = $TimerLabel
@onready var leave_button = $Leave

var multiplier = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	leave_button.visible = false
	var camera = get_viewport().get_camera_2d()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer_label.text = 	"Time: " + str(int(game_timer.time_left))


func _on_maze_exit_body_exited(body: Node2D) -> void:
	Global.score += 10
	game_over_message.text = "YOU DID IT! You gained 10 points!"
	leave_button.visible = true #let the player leave


func _on_game_timer_timeout() -> void:
	game_over_message.text = "GAME OVER...better luck next time..."
	leave_button.visible = true #let the player leave

func _on_leave_pressed() -> void:
	Global.markercount += 1
	get_tree().change_scene_to_file("res://scenes/campus.tscn")
	Global.spawn_position = Vector2(1600, 192)
