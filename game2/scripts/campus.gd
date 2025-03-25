extends Node2D

var timer;
var label;
var scoreLabel;
var arrow;
var class_on_time;
var out_of_time;
var which_class;
var player
var building
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# preload so we only have to load it once
	preload("res://scenes/campus.tscn")
	
	# Get get spawn position from Global.gd. Done this way so changing scenes when leaving indoors
	# puts you in the correct area
	$Panel.visible = false
	player =  get_node("Wally")
	
	# Set player position
	if Global.spawn_scene == "res://scenes/campus.tscn":
		player.position = Global.pause_position
		Global.spawn_scene = ""
	else:
		player.position = Global.spawn_position
	
	scoreLabel = $Wally/Score
	label = $Wally/Objective
	timer = $ClassTimer
	arrow = $Wally/Arrow
	which_class = get_node("DB/Marker2D")
	building = "res://scenes/insideDB.tscn"
	class_on_time = false
	out_of_time = false
	scoreLabel.text = "Score: " + str(Global.score)
	#timer.wait_time = 30


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scoreLabel.text = "Score: " + str(Global.score)
	arrow.rotation = player.position.angle_to_point(which_class.position)
	if (class_on_time):
		get_tree().change_scene_to_file(building)
		#which_class = $Shiley2/Marker2D
		timer.wait_time = 30
		scoreLabel.text = "Score: " + str(Global.score)
		class_on_time = false
		player.position = Global.spawn_position
	#elif (out_of_time):
		#out_of_time = false
		#label.text = "You did not make it to class on time :("
	#else:
		#label.text = "Get to class in time, follow the arrow! Time Left: " + str(int(timer.get_time_left()))
	

func _on_db_body_entered(body: Node2D) -> void:
	if body.has_method("takehit"):
		if not out_of_time:
			class_on_time = true


func _on_class_timer_timeout() -> void:
	out_of_time = true


func _on_shiley_2_body_entered(body: Node2D) -> void:
	if body.has_method("takehit"):
		#print("here")
		if not out_of_time:
			class_on_time = true


func _on_library_entrance_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://scenes/Library_interior.tscn")


func _on_bc_entrance_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://scenes/BC_interior.tscn")

#func _on_franz_entrance_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#if body.is_in_group("Player"):
		#get_tree().change_scene_to_file("res://scenes/franz_interior.tscn")
		
# Touchscreen controls
func _on_gui_input(event):
	if event is InputEventScreenTouch and event.pressed:  # Use ScreenTouch for mobile
		player.position = event.position
		print("touched at" + event.position)
# Forces focus to trigger the keyboard


func _on_oak_pilot_house_body_entered(body: Node2D) -> void:
	if body.has_method("takehit"):
		$Panel.visible = true


func _on_oak_pilot_house_body_exited(body: Node2D) -> void:
	if body.has_method("takehit"):
		$Panel.visible = false


func _on_franz_entrance_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://scenes/franz_interior.tscn")
