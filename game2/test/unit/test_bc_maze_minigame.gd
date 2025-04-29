extends GutTest

var MAZE_SCENE = load("res://scenes/BC_maze_minigame.tscn")
var scene_instance : Node
var script_holder : Node
var current_layer : TileMapLayer
var next_layer : TileMapLayer
var original_current_enabled : bool
var original_next_enabled : bool

func _ready() -> void:
	add_to_group("test_maze")

func before_each() -> void:
	#load scene
	scene_instance = MAZE_SCENE.instantiate()
	get_tree().get_root().add_child(scene_instance) # add to tree
	
	# Get the script
	script_holder = scene_instance.get_node("/bc_maze_minigame.gd")
	
	# Get the tilemaplayers
	current_layer = scene_instance.get_node("BcMazeMinigame/FirstLayer")
	next_layer = scene_instance.get_node("BcMazeMinigame/ScndLayer")
	
	# Store original state
	original_current_enabled = current_layer.enabled
	original_next_enabled = next_layer.enabled
	
	# Make sure they aren't null
	assert_not_null(current_layer, "Current layer should not be null.")
	assert_not_null(next_layer, "Next layer should not be null.")

func after_each() -> void:
	# Restore original state
	current_layer.enabled = original_current_enabled
	next_layer.enabled = original_next_enabled
	
	# Clean up the scene
	var test_scene = get_tree().get_first_node_in_group("test_maze")
	if test_scene:
		test_scene.gueue_free()

func test_change_layers():
	# Set the inital state
	current_layer.enabled = true
	next_layer.enabled = false
	
	
	script_holder.change_layers(current_layer, next_layer)
	assert_false(current_layer.enabled, "Current layer should be disabled.")
	assert_true(next_layer.enabled, "Next layer should be enabled.")

#func test_change_collisions():
	#var bc_game = maze_scene.instantiate()
	#bc_game._ready()
	
	#var this_current = [get_node("BcMazeMinigame/First_maze_walls/first_perimeter"), 
				#get_node("BcMazeMinigame/First_maze_walls/first_middle_shape_1"),
				#get_node("BcMazeMinigame/First_maze_walls/first_middle_shape_2")]
	#var this_next = [get_node("BcMazeMinigame/Third_maze_walls/third_perimeter"), 
				#get_node("BcMazeMinigame/Third_maze_walls/third_middle_shape")]
				#
	#
	#maze_scene.change_collisions(this_current, this_next)
	#assert_eq(this_current[0].disabled, true)
	#assert_eq(this_next[0].disabled, false)
	
#func change_collisions(current: Array, next: Array) -> void:
	#print("changing collisions from ", current, " to ", next)
	#for box in current : 
		#box.set_deferred("disabled", true)
	#
	#for box in next :
		#box.set_deferred("disabled", false)
