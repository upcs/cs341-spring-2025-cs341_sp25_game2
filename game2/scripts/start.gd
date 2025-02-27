extends Node2D

@onready var start_button = $Button
@onready var username_input = $LineEdit
@onready var submit_button = $SubmitButton
@onready var username_label = $RichTextLabel2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preload('res://scenes/campus.tscn')
	start_button.visible = false  # Hide start button initially
	start_button.disabled = true
	if not username_input:
		print("Please add a LineEdit node named 'LineEdit' to the scene")
	if not submit_button:
		print("Please add a Button node named 'SubmitButton' to the scene")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/campus.tscn")

func _on_submit_button_pressed() -> void:
	var input_text = username_input.text.strip_edges()  # Remove leading/trailing whitespace
	if input_text.length() > 0 and input_text.length() <= 20 and not input_text.contains(" "):
		Global.username = input_text
		start_button.visible = true
		start_button.disabled = false
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
		
