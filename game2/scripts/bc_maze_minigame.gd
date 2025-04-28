extends Node2D

@onready var panel = $Panel
@onready var game_over_message = $Panel/GameOverMessage
@onready var player_message = $PlayerMessage
@onready var game_timer = $GameTimer
@onready var timer_label = $TimerLabel
@onready var leave_button = $Leave
@onready var exit = $maze_exit/exit_here
@onready var player = $NewWally
@onready var first_layer = $FirstLayer
@onready var scnd_layer = $ScndLayer
@onready var third_layer = $ThirdLayer
@onready var fourth_layer = $FourthLayer

# For testing
@onready var my_current = "first"

# Get the collision boxes of each maze
@onready var first_maze_walls = [$First_maze_walls/first_perimeter, $First_maze_walls/first_middle_shape_1,
$First_maze_walls/first_middle_shape_2]
@onready var scnd_maze_walls = [$Scnd_maze_walls/scnd_perimeter, $Scnd_maze_walls/scnd_middle_shape1,
$Scnd_maze_walls/scnd_middle_shape2, $Scnd_maze_walls/scnd_middle_shape3, $Scnd_maze_walls/scnd_middle_shape4,
$Scnd_maze_walls/scnd_middle_shape5, $Scnd_maze_walls/scnd_middle_shape6, $Scnd_maze_walls/scnd_middle_shape7]
@onready var third_maze_walls = [$Third_maze_walls/third_perimeter, $Third_maze_walls/third_middle_shape]
@onready var fourth_maze_walls = [$Fourth_maze_walls/fourth_perimeter, $Fourth_maze_walls/fourth_middle_shape1,
$Fourth_maze_walls/fourth_middle_shape2, $Fourth_maze_walls/fourth_middle_rect, $Fourth_maze_walls/square1,
$Fourth_maze_walls/square2, $Fourth_maze_walls/square3, $Fourth_maze_walls/square4, $Fourth_maze_walls/square5,
$Fourth_maze_walls/square6, $Fourth_maze_walls/square7, $Fourth_maze_walls/square8, $Fourth_maze_walls/square9,
$Fourth_maze_walls/squareA, $Fourth_maze_walls/squareA1, $Fourth_maze_walls/squareA2, $Fourth_maze_walls/squareA3,
$Fourth_maze_walls/squareA4, $Fourth_maze_walls/squareA5, $Fourth_maze_walls/squareA6, $Fourth_maze_walls/squareA7,
$Fourth_maze_walls/squareA8, $Fourth_maze_walls/squareA9, $Fourth_maze_walls/squareB]

# Amount to be added to the score after each maze is completed
var total_score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.update_score()
	# This is here as well so that the "exit to campus" works properly
	Global.spawn_position = Vector2(1600, 192)
	# Get scores set up
	Global.first_maze_score = 25
	Global.scnd_maze_score = 50
	Global.third_maze_score = 75
	Global.fourth_maze_score = 100
	
	# Make sure we can't see the game over message
	leave_button.visible = false
	panel.visible = false
	
	# Make sure we start with only the first maze
	first_layer.enabled = true
	scnd_layer.enabled = false
	third_layer.enabled = false
	fourth_layer.enabled = false
	
	# Only the collision boxes for the first maze should be enabled
	# at the start of the minigame.
	for box in first_maze_walls :
		box.disabled = false
	
	for box in scnd_maze_walls :
		box.disabled = true
	
	for box in third_maze_walls :
		box.disabled = true
	
	for box in fourth_maze_walls :
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
	
	#The following code has a bug that is still being worked out.
	 # Check if the game is over
	if $FourthLayer.is_enabled() :
		# If this is the first time they've completed the maze,
		# Increase their score
		if !Global.fourth_maze_done :
			Global.fourth_maze_score = 100
		
		total_score = Global.first_maze_score + Global.scnd_maze_score + Global.third_maze_score + Global.fourth_maze_score
		Global.fourth_maze_done = true
		game_timer.stop()
				
		# update the player's score
		Global.update_score()
		
		# allow the player to leave
		panel.visible = true
		game_over_message.text = "YOU DID IT! You gained " + str(total_score) + " points total!"
		leave_button.visible = true #let the player leave
		
	# Else display the next maze to complete 
	elif $FirstLayer.is_enabled() :
		if !Global.first_maze_done :
			Global.first_maze_score = 25
		
		Global.first_maze_done = true
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
	elif $ScndLayer.is_enabled() :
		if !Global.scnd_maze_done :
			Global.scnd_maze_score = 50
		
		Global.scnd_maze_done = true
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
	else :
		if !Global.third_maze_done :
			Global.third_maze_score = 75
		
		Global.third_maze_done = true
		game_timer.stop()
		game_timer.wait_time = 60.0
		game_timer.start()
		# Change player position
		player.position = Vector2(0,0)
		# Change the position of the maze exit
		exit.position = Vector2(807,615)
		print("Third layer changed to fourth layer")
		# Change the display to the next maze
		change_layers($ThirdLayer, $FourthLayer)
		my_current = "fourth"
		change_collisions(third_maze_walls, fourth_maze_walls)
		# Change the player message
		player_message.text = "Find the invisible Exit! Oh my... try the ice cubes!"

func _on_game_timer_timeout() -> void:
	game_over_message.text = "GAME OVER...better luck next time..."
	leave_button.visible = true #let the player leave

func _on_leave_pressed() -> void:
	Global.update_score()
	Global.markercount += 1
	get_tree().change_scene_to_packed(load("res://scenes/campus.tscn"))
	Global.spawn_position = Vector2(1600, 192)
