extends GutTest

var maze_scene = load("res://scenes/BC_maze_minigame.tscn")

func test_change_layers():
	var bc_game = maze_scene.instantiate()
	bc_game._ready()
	
	var this_current : TileMapLayer = get_node("BcMazeMinigame/FirstLayer")
	var this_next : TileMapLayer = get_node("BcMazeMinigame/ScndLayer")
	
	this_current.enabled = true
	this_next.enabled = false
	
	maze_scene.change_layers(this_current, this_next)
	assert_eq(this_current.enabled, false)
	assert_eq(this_next.enabled, true)

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
