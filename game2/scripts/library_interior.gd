extends Node2D

@onready var library_text_panel = $CanvasLayer/LibraryTextPanel
@onready var library_text = $CanvasLayer/LibraryTextPanel/LibraryText
@onready var downstairs_text = $DownstairsText

var player
var tween = create_tween()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set spawn position
	player = get_node("Wally")
	
	# PROCEDURE FOR PAUSE: 
	# Basically copy the code below but for your scene
	if Global.spawn_scene == "res://scenes/Library_interior.tscn":
		player.position = Global.pause_position
		Global.spawn_scene = ""
	else:
		player.position = Global.library_interior_spawn_position
	Global.spawn_position = Vector2(2400, 940)
	
	library_text_panel.modulate.a = 0.0
	tween.tween_property(library_text_panel, "modulate:a", 0.9, 1.0)

func _on_library_exit_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name) 
	if body.is_in_group("Player"):
		print("Player entered. Changing spawn and changing scene...")
		
		# update spawn positions accordingly
		Global.spawn_position = Vector2(2400, 940)
		Global.library_interior_spawn_position = Vector2(1080, 52)
		#Global.markercount += 1
		get_tree().change_scene_to_packed(load("res://scenes/campus.tscn"))
	else:
		print("This body is not in the Player group")



func _on_lower_floor_entrance_body_entered(body: Node2D) -> void:
	print("Body entered: body.name")
	if body.is_in_group("Player"):
		print("Player entered. Changing spawn and changing scene...")
		Global.library_interior_spawn_position = Vector2(198, 20)
		get_tree().change_scene_to_packed(load("res://scenes/Library_game.tscn"))


func _on_downstairs_mark_body_entered(body: Node2D) -> void:
	print("Body entered: body.name")
	if body.is_in_group("Player"):
		downstairs_text.visible = true
