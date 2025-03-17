extends Node2D

@onready var library_text = $CanvasLayer/LibraryText
var player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set spawn position
	player = get_node("Wally")
	player.position = Global.library_interior_spawn_position
	
	library_text.visible = true
	library_text.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(library_text, "modulate:a", 0.9, 1.0)
	
	preload("res://scenes/campus.tscn")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_library_exit_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name) 
	if body.is_in_group("Player"):
		print("Player entered. Changing spawn and changing scene...")
		
		# update spawn positions accordingly
		Global.spawn_position = Vector2(2400, 940)
		Global.library_interior_spawn_position = Vector2(1080, 52)
		get_tree().change_scene_to_file("res://scenes/campus.tscn")
	else:
		print("This body is not in the Player group")



func _on_lower_floor_entrance_body_entered(body: Node2D) -> void:
	print("Body entered: body.name")
	if body.is_in_group("Player"):
		print("Player entered. Changing spawn and changing scene...")
		Global.library_interior_spawn_position = Vector2(198, -22)
		get_tree().change_scene_to_file("res://scenes/Library_game.tscn")
