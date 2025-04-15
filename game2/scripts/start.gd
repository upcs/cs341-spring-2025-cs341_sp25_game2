extends Node2D

@onready var start_button = $Button
@onready var username_input = $LineEdit
@onready var submit_button = $SubmitButton
@onready var username_label = $RichTextLabel2
@onready var leaderboard_button = $LeaderboardButton
@onready var loading_screen = $LoadingScreen


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if Global.username == "":
		start_button.disabled = true
		leaderboard_button.disabled = true
	else:
		submit_button.disabled = true
		submit_button.visible = false
		username_input.editable = false
		username_input.visible = false
		username_label.visible = false
		start_button.visible = true
		leaderboard_button.visible = true
		

func _on_button_pressed() -> void:
	loading_screen.visible = true
	await get_tree().create_timer(0.1).timeout
	if Global.spawn_scene != "":
		get_tree().change_scene_to_packed(load(Global.spawn_scene))
	else:
		var packed_scene = load("res://scenes/campus.tscn")
		loading_screen.progress_bar = 100
		await get_tree().create_timer(0.1).timeout
		
		get_tree().change_scene_to_packed(packed_scene)
	
	#get_tree().change_scene_to_packed(load("res://scenes/LoadingScreen.tscn"))

func _on_submit_button_pressed() -> void:
	var input_text = username_input.text.strip_edges()  # Remove leading/trailing whitespace
	if input_text.length() > 0 and input_text.length() <= 20 and not input_text.contains(" "):
		Global.username = input_text
		# button changes
		start_button.visible = true
		start_button.disabled = false
		leaderboard_button.visible = true
		leaderboard_button.disabled = false
		username_input.editable = false
		username_input.visible = false
		submit_button.disabled = true
		submit_button.visible = false
		username_label.visible = false
		
		print(Global.username)
	else:
		if input_text.contains(" "):
			username_label.text = "[center]No spaces in the username"
		else:
			username_label.text = "[center]Username must be 1-20 characters"
		
func _on_leaderboard_button_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/LeaderboardMYSQL.tscn"))
