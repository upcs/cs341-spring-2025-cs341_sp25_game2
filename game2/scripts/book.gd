extends RigidBody2D

@onready var library_game_node = get_parent()

var is_stacked = false
var is_being_dragged = false
var book_options = 5

var random_x = randf_range(0.2,2.1)
var random_y = randf_range(0.4,2.1)

func _ready():
	var random_pick = randi_range(1,book_options)
	
	if random_pick == 1:
		$BlueBook.show()
	elif random_pick == 2:
		$BrownBook.show()
	elif random_pick == 3:
		$GreenBook.show()
	elif random_pick == 4:
		$PinkBook.show()
	else:
		$YellowBook.show()

# convenience function to set random range
func set_random_range(x_low: float, x_high: float, y_low: float, y_high: float):
	random_x = randf_range(x_low, x_high)
	random_y = randf_range(y_low, y_high)
	

func _on_body_entered(body: Node) -> void:	
	if body.is_in_group("stacked_book") or body.is_in_group("ground") or body.is_in_group("first_book"):
		
		if is_in_group("first_book"):
			return
		
		if library_game_node.stacked_books > 0 and is_in_group("active_book") and body.is_in_group("ground"):
			library_game_node.game_lost = true
			library_game_node.game_over()
			print("active book hit ground")
			return
		
		if library_game_node.stacked_books > 0 and is_in_group("stacked_book") and body.is_in_group("ground"):
			library_game_node.game_lost = true
			library_game_node.game_over()
			print("stacked book hit ground")
			return
		
		if is_in_group("active_book") and library_game_node != null:
			library_game_node.stacked_books += 1
			library_game_node.game_over()
	
		
		remove_from_group("active_book")
		linear_velocity = Vector2.ZERO
		add_to_group("stacked_book")
		
		if library_game_node.stacked_books == 1:
			remove_from_group("stacked_book")
			add_to_group("first_book")
			linear_velocity = Vector2.ZERO
			print("First book not a stacked book")
			
			

func random_scale():
		var book_scale_x = $BlueBook.scale.x
		var book_scale_y = $BlueBook.scale.y
		
		$CollisionShape2D.scale = Vector2(random_x, random_y)
		$BlueBook.scale = Vector2(book_scale_x * random_x, book_scale_y * random_y)
		$BrownBook.scale = Vector2(book_scale_x * random_x, book_scale_y * random_y)
		$GreenBook.scale = Vector2(book_scale_x * random_x, book_scale_y * random_y)
		$PinkBook.scale = Vector2(book_scale_x * random_x, book_scale_y * random_y)
		$YellowBook.scale = Vector2(book_scale_x * random_x, book_scale_y * random_y)
