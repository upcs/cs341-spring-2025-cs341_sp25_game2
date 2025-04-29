extends Node2D

@onready var controls_scene = preload("res://controls.tscn")
var controls_instance : CanvasLayer = null  # Change the type to CanvasLayer
var helped = false

func _ready() -> void:
	Global.spawn_position = Vector2(4500, 550)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("help"):
		controls()

func controls():
	print("Controls button pressed.")
	
	if helped:
		# Hide the controls if they are currently displayed
		if controls_instance:
			print("Hiding controls...")
			controls_instance.queue_free()  # Free the controls CanvasLayer
		Engine.time_scale = 1
	else:
		# Instantiate the controls scene and add it to the current scene
		print("Instantiating controls...")
		controls_instance = controls_scene.instantiate() as CanvasLayer  # Cast to CanvasLayer
		add_child(controls_instance)  # Add the CanvasLayer as a child
		Engine.time_scale = 0

	helped = !helped
