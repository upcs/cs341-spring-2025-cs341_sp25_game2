extends Node

# global variables for the player
var spawn_position = Vector2(134, 356)
# building for arrow
var building
var buildings = ["res://scenes/insideDB.tscn","res://scenes/franz_interior.tscn","res://scenes/BC_interior.tscn","res://scenes/Library_interior.tscn"]

var markercount = 0
var markers = ["DB/Marker2D","franz_entrance/Marker2D","BC_entrance/BC_marker","Library_entrance/Library_marker"]

var library_interior_spawn_position = Vector2(1080, 150)
var score = 0
var username: String = ""

var spawn_scene = ""
var pause_position = Vector2.ZERO

# variables for library game
var difficulties = [1, 1, 1] # [easy, medium, hard] -> 1 == can play, 0 == can't play
