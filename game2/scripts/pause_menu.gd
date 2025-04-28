extends CanvasLayer

@onready var background = $Background
@onready var resume_button = $ResumeButton
@onready var quit_button = $QuitButton
@onready var pause_button = $PauseButton
@onready var campus_button = $CampusButton

@onready var parent = null

# Sets up the default pause menu
func _ready() -> void:
	parent = get_parent()
	background.hide()
	resume_button.hide()
	quit_button.hide()
	pause_button.show()
	campus_button.hide()

# make escape key do it's thing
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		_on_pause_button_pressed()

# Handle resume button
func _on_resume_button_pressed() -> void:
	if parent.is_in_group("player"):
		parent._pause()
	background.hide()
	resume_button.hide()
	campus_button.hide()
	quit_button.hide()
	pause_button.show()
	
	get_tree().paused = false

# Handle quit button - back to main menu
func _on_quit_button_pressed() -> void:
	Global.update_score() # Why not
	get_tree().paused = false
	
	 # A player automatically has a pause menu attached - grab correct scene if pause menu is from a player
	if parent.is_in_group("player"):
		Global.spawn_scene = parent.get_parent().scene_file_path
		Global.pause_position = parent.global_position
	else: # If the pause menu is attached to a scene
		Global.spawn_scene = parent.scene_file_path
	
	# debug
	print(Global.spawn_scene)
	
	get_tree().change_scene_to_packed(load("res://start.tscn"))

# Handle pause button
func _on_pause_button_pressed() -> void:
	# Call "Pause" function in player script if scene is the child to a player
	if parent.is_in_group("player"):
		parent._pause()
	get_tree().paused = true
	background.show()
	resume_button.show()
	quit_button.show()
	campus_button.show()
	pause_button.hide()

# Handle campus transition
func _on_campus_button_pressed() -> void:
	Global.update_score() # Why not
	get_tree().paused = false
	if get_tree().current_scene.scene_file_path == "res://scenes/campus.tscn":
		_on_resume_button_pressed()
	else:
		Global.spawn_scene == "res://scenes/campus.tscn"
		get_tree().change_scene_to_packed(load("res://scenes/campus.tscn"))
