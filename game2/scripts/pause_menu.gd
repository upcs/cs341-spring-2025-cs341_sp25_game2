extends Control

@onready var Player = get_parent().get_parent() # INTENTIONAL - don't change

func _ready() -> void:
	pass
	#preload("res://scenes/campus.tscn")

func _on_resume_button_pressed() -> void:
	Player.remove_pause_menu()


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://start.tscn")
