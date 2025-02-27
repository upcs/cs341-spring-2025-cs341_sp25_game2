extends Node2D

@onready var library_text = $CanvasLayer/LibraryText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	library_text.visible = true
	library_text.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(library_text, "modulate:a", 0.9, 1.0)
	preload("res://scenes/campus.tscn")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_library_exit_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name)  # Print the name of the body entering the area
	if body.is_in_group("Player"):
		print("Player entered. Changing spawn and changing scene...")
		Global.spawn_position = Vector2(2400, 940)
		get_tree().change_scene_to_file("res://scenes/campus.tscn")
	else:
		print("This body is not in the Player group")
