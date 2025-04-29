extends Control

@onready var library_game_node = get_parent()
@onready var play_button = $PlayButton
@onready var easy_button = $Easy
@onready var medium_button = $Medium
@onready var hard_button = $Hard
@onready var game_info = $GameInfo


var difficulties = Global.difficulties
var selection = -1 # 0 for easy, 1, for medium, 2 for hard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_info.visible = false
	play_button.hide()
	refresh_options()

# disable a difficulty if it's already been played
func refresh_options():
	if difficulties[0] == 0:
		easy_button.disabled = true
		easy_button.self_modulate = Color(1,0,0)
	if difficulties[1] == 0:
		medium_button.disabled = true
		medium_button.self_modulate = Color(1,0,0)
	if difficulties[2] == 0:
		hard_button.disabled = true
		hard_button.self_modulate = Color(1,0,0)
		
	if difficulties[0] == 0 and difficulties[1] == 0 and difficulties[2] == 0:
		difficulties[0] = 1
		difficulties[1] = 1
		difficulties[2] = 1
		easy_button.disabled = false
		medium_button.disabled = false
		hard_button.disabled = false
		easy_button.self_modulate = Color(1,1,1)
		medium_button.self_modulate = Color(1,1,1)
		hard_button.self_modulate = Color(1,1,1)
		
	Global.update_score()

func _process(delta: float) -> void:
	if selection >= 0:
		play_button.show()
	else:
		play_button.hide()
	

func _on_easy_pressed() -> void:
	selection = 0
	play_button.show()
	
func _on_medium_pressed() -> void:
	selection = 1
	play_button.show()

func _on_hard_pressed() -> void:
	selection = 2
	play_button.show()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/Library_interior.tscn"))

func _on_play_button_pressed() -> void:	
	#await library_game_node.remove_books()
	library_game_node.difficulty = selection # set difficulty in game
	library_game_node.start_game()
	# make sure difficulty not playable anymore
	difficulties[selection] = 0
	selection = -1

func _on_info_button_pressed() -> void:
	if !game_info.visible:
		easy_button.hide()
		medium_button.hide()
		hard_button.hide()
		game_info.visible = true
	else:
		game_info.visible = false
		easy_button.show()
		medium_button.show()
		hard_button.show()
	
