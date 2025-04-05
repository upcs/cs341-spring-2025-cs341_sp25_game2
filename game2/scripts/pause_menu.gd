extends Control

@onready var Player = get_parent().get_parent() # INTENTIONAL - don't change

func _on_resume_button_pressed() -> void:
	Player.remove_pause_menu()


func _on_quit_button_pressed() -> void:
	Global.pause_position = Player.global_position
	Global.spawn_scene = Player.get_parent().scene_file_path
	print(Global.spawn_scene)
	
	get_tree().change_scene_to_packed(load("res://start.tscn"))
