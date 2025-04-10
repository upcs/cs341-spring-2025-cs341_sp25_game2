extends Node2D

@onready var game_over_message = $GameOverMessage
@onready var player_message = $PlayerMessage
@onready var game_timer = $GameTimer
@onready var timer_label = $TimerLabel
@onready var leave_button = $Leave
@onready var exit = $maze_exit/exit_here
@onready var player = $NewWally
@onready var maze_walls_1 = $First_maze_walls
@onready var maze_walls_2 = $Scnd_maze_walls

# For testing
@onready var my_current = "first"

# Get the collision boxes of each maze
@onready var first_maze_walls = [$First_maze_walls/first_perimeter, $First_maze_walls/first_middle_shape_1,
$First_maze_walls/first_middle_shape_2]
@onready var scnd_maze_walls = [$Scnd_maze_walls/scnd_perimeter, $Scnd_maze_walls/scnd_middle_shape1,
$Scnd_maze_walls/scnd_middle_shape2, $Scnd_maze_walls/scnd_middle_shape3, $Scnd_maze_walls/scnd_middle_shape4,
$Scnd_maze_walls/scnd_middle_shape5, $Scnd_maze_walls/scnd_middle_shape6, $Scnd_maze_walls/scnd_middle_shape7]
@onready var third_maze_walls = [$Third_maze_walls/third_perimeter, $Third_maze_walls/third_middle_shape]

# Amount to be added to the score after each maze is completed
var score_amount = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	leave_button.visible = false
	
	#Make sure we start with only the first maze
	$FirstLayer.enabled = true
	$ScndLayer.enabled = false
	$ThirdLayer.enabled = false
	
	# Only the collision boxes for the first maze should be enabled
	# at the start of the minigame.
	for box in first_maze_walls :
		box.disabled = false
	
	for box in scnd_maze_walls :
		box.disabled = true
	
	for box in third_maze_walls :
		box.disabled = true
	

#NEEDS TESTS
func change_layers(current: TileMapLayer, next: TileMapLayer) -> void:
	current.enabled = false
	next.enabled = true

#NEEDS TESTS
func change_collisions(current: Array, next: Array) -> void:
	print("changing collisions from ", current, " to ", next)
	for box in current : 
		box.set_deferred("disabled", true)
	
	for box in next :
		box.set_deferred("disabled", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	timer_label.text = "Time: " + str(int(game_timer.time_left))


# Maybe: change to on_maze_exit_body_entered
func _on_maze_exit_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return
	print("body exited: ", body)
	# Increase player score
	Global.score += score_amount
	#game_timer.stop()
	#game_over_message.text = "YOU DID IT! You gained 10 points!"
	#leave_button.visible = true #let the player leave
	
	#The following code has a bug that is still being worked out.
	 # Check if the game is over
	if $ThirdLayer.is_enabled() :
		game_timer.disabled = true
		game_over_message.text = "YOU DID IT! You completed all the mazes!"
		leave_button.visible = true #let the player leave
		
	# Else display the next maze to complete 
	elif $FirstLayer.is_enabled() :
		# Reset timer
		game_timer.stop()
		game_timer.wait_time = 60.0
		game_timer.start()
		# Change player position
		player.position = Vector2(0,0)
		# Change the position of the maze exit
		exit.position = Vector2(880,448)
		print("First layer changed to second layer")
		# Change the display to the next maze
		change_layers($FirstLayer, $ScndLayer)
		my_current = "scnd"
		change_collisions(first_maze_walls, scnd_maze_walls)
		# Change the player message
		player_message.text = "Find the invisible Exit! Hint: check the alcoves..."
	else:
		# Reset timer
		game_timer.stop()
		game_timer.wait_time = 60.0
		game_timer.start()
		# Change player position
		player.position = Vector2(0,0)
		# change the position of the maze exit
		exit.position = Vector2(152,424)
		# Change the display to the next maze
		change_layers($ScndLayer, $ThirdLayer)
		change_collisions(scnd_maze_walls, third_maze_walls)
		my_current = "third"
		
		print("second layer changed to third layer")
		# change the player message
		player_message.text = "Find the invisible Exit! No hints this time ;)"


func _on_game_timer_timeout() -> void:
	game_over_message.text = "GAME OVER...better luck next time..."
	leave_button.visible = true #let the player leave

func _on_leave_pressed() -> void:
	Global.markercount += 1
	get_tree().change_scene_to_packed(load("res://scenes/campus.tscn"))
	Global.spawn_position = Vector2(1600, 192)
