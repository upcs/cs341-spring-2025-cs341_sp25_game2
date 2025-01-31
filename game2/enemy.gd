extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.x = 300
	position.y = 300


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func takehit():
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("hello")
	if body.has_method("takehit"):
		queue_free()
