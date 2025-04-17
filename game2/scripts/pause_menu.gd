extends CanvasLayer

@onready var background = $Background
@onready var resume_button = $ResumeButton
@onready var quit_button = $QuitButton
@onready var pause_button = $PauseButton

@onready var parent = null

func _ready() -> void:
	parent = get_parent()
	background.hide()
	resume_button.hide()
	quit_button.hide()
	pause_button.show()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		_on_pause_button_pressed()

func _on_resume_button_pressed() -> void:
	if parent.is_in_group("player"):
		parent._pause()
	background.hide()
	resume_button.hide()
	quit_button.hide()
	pause_button.show()
	get_tree().paused = false


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	
	if parent.is_in_group("player"):
		Global.spawn_scene = parent.get_parent().scene_file_path
		Global.pause_position = parent.global_position
	else:
		Global.spawn_scene = parent.scene_file_path
	
	print(Global.spawn_scene)
	
	get_tree().change_scene_to_packed(load("res://start.tscn"))


func _on_pause_button_pressed() -> void:
	if parent.is_in_group("player"):
		parent._pause()
	get_tree().paused = true
	background.show()
	resume_button.show()
	quit_button.show()
	pause_button.hide()
