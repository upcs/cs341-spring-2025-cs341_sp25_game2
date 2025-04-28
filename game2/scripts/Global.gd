extends Node

# global variables for the player
var spawn_position = Vector2(134, 356)
# building for arrow
var building
var buildings = ["res://scenes/insideDB.tscn","res://scenes/franz_interior.tscn","res://scenes/BC_interior.tscn","res://scenes/Library_interior.tscn"]

var markercount = 0 % 4
var markers = ["DB/Marker2D","franz_entrance/Marker2D","BC_entrance/BC_marker","Library_entrance/Library_marker"]



var score = 0
var username: String = ""

var spawn_scene = ""
var pause_position = Vector2.ZERO

# variables for Library
var difficulties = [1, 1, 1] # [easy, medium, hard] -> 1 == can play, 0 == can't play
var library_interior_spawn_position = Vector2(1080, 150)
var lib_easy_score = 0 # high score for easy difficulty
var lib_med_score = 0 # high score for medium difficulty
var lib_hard_score = 0 # high score for hard difficulty

# variables for Buckley Center
var first_maze_done = false
var scnd_maze_done = false
var third_maze_done = false
var fourth_maze_done = false

var first_maze_score = 0 #25
var scnd_maze_score = 0 #50
var third_maze_score = 0 #75
var fourth_maze_score = 0 #100

func update_score() -> void:
	score = lib_easy_score + lib_med_score + lib_hard_score # add in the scores for your minigame here
	
	# from maze game
	score = first_maze_score + scnd_maze_score + third_maze_score + fourth_maze_score
	# reset all scores back to 0
	first_maze_score = 0
	scnd_maze_score = 0
	third_maze_score = 0
	fourth_maze_score = 0
