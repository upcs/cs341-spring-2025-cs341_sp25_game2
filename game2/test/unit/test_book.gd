extends GutTest

@onready var LibraryGameScene = load("res://scenes/Library_game.tscn")
@onready var BookScene = load("res://scenes/Book.tscn")

func before_each():
	# Instantiate the actual LibraryGame.tscn scene
	var library_game = LibraryGameScene.instantiate()
	add_child(library_game)
	library_game._ready()
	
	# Instantiate the actual Book.tscn scene and add it to LibraryGame
	var book = BookScene.instantiate()
	library_game.add_child(book)
	book._ready()

func after_each():
	# Clean up by freeing the entire scene tree from the test root
	for child in get_children():
		child.queue_free()

func test_book_initialization_random_book_selection():
	var book = get_node("LibraryGame/Book")
	# Test that one book sprite is shown and others are hidden
	var visible_sprite_count = 0
	if book.get_node("BlueBook").visible: 
		visible_sprite_count += 1
		print("blue book visible")
	if book.get_node("BrownBook").visible: 
		visible_sprite_count += 1
		print("brown book visible")
	if book.get_node("GreenBook").visible: 
		visible_sprite_count += 1
		print("green book visible")
	if book.get_node("PinkBook").visible: 
		visible_sprite_count += 1
		print("pink book visible")
	if book.get_node("YellowBook").visible: 
		visible_sprite_count += 1
		print("yellow book visible")
	assert_eq(visible_sprite_count, 1, "Exactly one book sprite should be visible")

func test_random_scale_applies_to_all_sprites_and_collision():
	var book = get_node("LibraryGame/Book")
	book.random_scale()
	var blue_scale = book.get_node("BlueBook").scale
	var collision_scale = book.get_node("CollisionShape2D").scale
	assert_true(blue_scale.x > 0, "BlueBook scale X should be positive")
	assert_true(blue_scale.y > 0, "BlueBook scale Y should be positive")
	assert_eq(book.get_node("BrownBook").scale, blue_scale, "BrownBook scale should match BlueBook")
	assert_eq(book.get_node("GreenBook").scale, blue_scale, "GreenBook scale should match BlueBook")
	assert_eq(book.get_node("PinkBook").scale, blue_scale, "PinkBook scale should match BlueBook")
	assert_eq(book.get_node("YellowBook").scale, blue_scale, "YellowBook scale should match BlueBook")
	assert_eq(collision_scale, Vector2(book.random_x, book.random_y), "Collision shape scale should match random_x, random_y")

func test_set_random_range():
	var book = get_node("LibraryGame/Book")
	book.set_random_range(0.5, 1.0, 1.0, 2.0)
	assert_between(book.random_x, 0.5, 1.0, "random_x should be within specified range")
	assert_between(book.random_y, 1.0, 2.0, "random_y should be within specified range")

func test_on_body_entered_stacked_book():
	var library_game = get_node("LibraryGame")
	var book = get_node("LibraryGame/Book")
	library_game.stacked_books = 1
	book.add_to_group("active_book")
	var stacked_book = Node2D.new()
	stacked_book.add_to_group("stacked_book")
	book._on_body_entered(stacked_book)
	assert_false(book.is_in_group("active_book"), "Book should be removed from active_book group")
	assert_true(book.is_in_group("stacked_book"), "Book should be added to stacked_book group")
	assert_eq(book.linear_velocity, Vector2.ZERO, "Linear velocity should be zero")
	assert_eq(library_game.stacked_books, 2, "Stacked books count should increment")
	stacked_book.queue_free()

func test_on_body_entered_first_book():
	var library_game = get_node("LibraryGame")
	var book = get_node("LibraryGame/Book")
	library_game.stacked_books = 0
	book.add_to_group("active_book")
	var ground = Node2D.new()
	ground.add_to_group("ground")
	book._on_body_entered(ground)
	assert_false(book.is_in_group("active_book"), "Book should be removed from active_book group")
	assert_false(book.is_in_group("stacked_book"), "First book should not be in stacked_book group")
	assert_true(book.is_in_group("first_book"), "Book should be added to first_book group")
	assert_eq(book.linear_velocity, Vector2.ZERO, "Linear velocity should be zero")
	assert_eq(library_game.stacked_books, 1, "Stacked books count should increment")
	ground.queue_free()
