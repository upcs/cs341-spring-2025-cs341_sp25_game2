extends RigidBody2D

var is_stacked = false
var is_being_dragged = false

func _ready():
	pass

func _on_body_entered(body: Node) -> void:
	var library_game_node = get_parent()
	print("_on_body_entered from book.gd triggered")
	print(library_game_node)
	
	if body.is_in_group("stacked_book") or body.is_in_group("ground"):
		if library_game_node.stacked_books > 0 and self.is_in_group("active_book") and body.is_in_group("ground"):
				library_game_node.game_lost = true
				library_game_node.game_over()
				return;
		
		if self.is_in_group("active_book") and library_game_node != null:
			library_game_node.stacked_books += 1
			library_game_node.game_over()
	
		
		self.remove_from_group("active_book")
		self.freeze = true
		self.linear_velocity = Vector2.ZERO
		self.add_to_group("stacked_book")
