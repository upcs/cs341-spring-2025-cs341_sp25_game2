extends GutTest

var book_scene = preload("res://scenes/Book.tscn")

# simulate library_game_node
class MockLibraryGame extends Node2D:
	var stacked_books = 0
	var game_lost = false
	var game_over_called = false
	func game_over():
		game_over_called = true

# test that _ready() correctly assigned a book sprite
func test_ready_shows_one_sprite():
	var book = book_scene.instantiate()
	add_child(book)
	var visible_count = 0
	for sprite in ["BlueBook", "BrownBook", "GreenBook", "PinkBook", "YellowBook"]:
		if book.get_node(sprite).visible:
			visible_count += 1
	assert_eq(visible_count, 1, "Exactly one book sprite should be visible")
	
	book.queue_free()

# test that random_scale() sets scales within expected ranges
func test_random_scale():
	var book = book_scene.instantiate()
	add_child(book)
	book.random_scale()
	var collision_scale = book.get_node("CollisionShape2D").scale
	assert_true(collision_scale.x >= 0.2 and collision_scale.x <= 2.1, "Collision scale.x should be between 0.2 and 2.1")
	assert_true(collision_scale.y >= 0.4 and collision_scale.y <= 2.1, "Collision scale.y should be between 0.4 and 2.1")
	for sprite in ["BlueBook", "BrownBook", "GreenBook", "PinkBook", "YellowBook"]:
		var sprite_scale = book.get_node(sprite).scale
		assert_true(sprite_scale.x > 0 and sprite_scale.y > 0, "%s scale should be positive" % sprite)
		
	book.queue_free()

# test _on_body_entered when active book hits ground with stacked books
func test_on_body_entered_active_hits_ground():
	var mock_parent = MockLibraryGame.new()
	mock_parent.stacked_books = 1
	add_child(mock_parent)
	var book = book_scene.instantiate()
	mock_parent.add_child(book)
	book.add_to_group("active_book")
	var mock_body = Node2D.new()
	mock_body.add_to_group("ground")
	book._on_body_entered(mock_body)
	assert_true(mock_parent.game_lost, "game_lost should be true")
	assert_true(mock_parent.game_over_called, "game_over should be called")
	assert_true(book.is_in_group("active_book"), "Book should remain in active_book group")
	
	mock_body.queue_free()
	book.queue_free()
	mock_parent.queue_free()

# test _on_body_entered when active book stacks on another book
func test_on_body_entered_stacks_book():
	var mock_parent = MockLibraryGame.new()
	mock_parent.stacked_books = 1
	add_child(mock_parent)
	var book = book_scene.instantiate()
	mock_parent.add_child(book)
	book.add_to_group("active_book")
	var mock_body = Node2D.new()
	mock_body.add_to_group("stacked_book")
	book._on_body_entered(mock_body)
	assert_false(book.is_in_group("active_book"), "Should not be in active_book group")
	assert_true(book.is_in_group("stacked_book"), "Should be in stacked_book group")
	assert_eq(book.linear_velocity, Vector2.ZERO, "Linear velocity should be zero")
	assert_eq(mock_parent.stacked_books, 2, "stacked_books should be incremented")
	assert_true(mock_parent.game_over_called, "game_over should be called")
	
	mock_body.queue_free()
	book.queue_free()
	mock_parent.queue_free()

# test _on_body_entered for first book placement
func test_on_body_entered_first_book():
	var mock_parent = MockLibraryGame.new()
	mock_parent.stacked_books = 0
	add_child(mock_parent)
	var book = book_scene.instantiate()
	mock_parent.add_child(book)
	book.add_to_group("active_book")
	var mock_body = Node2D.new()
	mock_body.add_to_group("ground")
	book._on_body_entered(mock_body)
	assert_false(book.is_in_group("active_book"), "Should not be in active_book group")
	assert_false(book.is_in_group("stacked_book"), "Should not be in stacked_book group")
	assert_true(book.is_in_group("first_book"), "Should be in first_book group")
	assert_eq(book.linear_velocity, Vector2.ZERO, "Linear velocity should be zero")
	assert_eq(mock_parent.stacked_books, 1, "stacked_books should be incremented")
	assert_true(mock_parent.game_over_called, "game_over should be called")
	
	mock_body.queue_free()
	book.queue_free()
	mock_parent.queue_free()
