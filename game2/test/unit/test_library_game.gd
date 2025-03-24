extends GutTest

var library_game_scene = preload("res://scenes/Library_game.tscn")

# test that _spawn_book() correctly adds a new book with expected properties
func test_spawn_book():
	var game_node = library_game_scene.instantiate()
	add_child(game_node)
	# wait for the next frame to ensure _ready() completes (spawns initial book)
	await get_tree().process_frame
	
	# verify one active book exists initially from _ready()
	var initial_books = get_tree().get_nodes_in_group("active_book")
	assert_eq(initial_books.size(), 1, "Should have one active book initially")
	
	# Call _spawn_book() to add another book
	game_node._spawn_book()
	# Wait for the deferred add_child to complete
	await get_tree().process_frame
	
	# check that a second book was added
	var books_after = get_tree().get_nodes_in_group("active_book")
	assert_eq(books_after.size(), 2, "Should have two active books after spawning another")
	
	# verify the new book's position (assuming x is randomized between 212 and 812, y is -100)
	var new_book = books_after[1]
	assert_true(new_book.global_position.x >= 212 and new_book.global_position.x <= 812, 
				"Book x position should be between 212 and 812")
	assert_eq(new_book.global_position.y, -100, "Book y position should be -100")
	
	# clean up
	game_node.queue_free()

# test that _on_spawn_timer_timeout() spawns a new book when no active books exist
func test_spawn_timer_timeout_no_active_books():
	var game_node = library_game_scene.instantiate()
	add_child(game_node)
	await get_tree().process_frame
	
	# remove the initial active book
	var initial_books = get_tree().get_nodes_in_group("active_book")
	for book in initial_books:
		book.queue_free()
	await get_tree().process_frame
	
	# set game_active to true and trigger spawn timer timeout
	game_node.game_active = true
	game_node._on_spawn_timer_timeout()
	await get_tree().process_frame
	
	# verify a new book was spawned
	var books_after = get_tree().get_nodes_in_group("active_book")
	assert_eq(books_after.size(), 1, "Should spawn a new active book when none exist")
	
	game_node.queue_free()

# test that an active book falling too far triggers game loss
func test_active_book_falls_too_far():
	var game_node = library_game_scene.instantiate()
	add_child(game_node)
	await get_tree().process_frame
	
	# get the initial active book and move it below y=550
	var active_books = get_tree().get_nodes_in_group("active_book")
	assert_eq(active_books.size(), 1, "Should have one active book")
	var book = active_books[0]
	book.global_position = Vector2(512, 600)  # y > 550
	
	# Trigger spawn timer timeout to detect the fall
	game_node._on_spawn_timer_timeout()
	
	# Verify game_lost is true and game_active is false
	assert_true(game_node.game_lost, "game_lost should be true when book falls too far")
	assert_false(game_node.game_active, "game_active should be false after game over")
	
	game_node.queue_free()

## Test game over with a win condition (stacked_books >= WIN_COUNT)
func test_game_over_win():
	var game_node = library_game_scene.instantiate()
	add_child(game_node)
	await get_tree().process_frame
	
	# Set win condition: 10 stacked books, WIN_COUNT=10 (constant), multiplier=10
	game_node.stacked_books = 10
	game_node.multiplier = 10
	game_node.game_over()
	
	# verify game state and UI updates
	assert_false(game_node.game_active, "game_active should be false on win")
	assert_eq(game_node.get_node("GameMessage").text, 
			  "[center]You Win! Points added to total score!", 
			  "Win message should be shown")
	assert_eq(game_node.get_node("StackCounter").text, "BOOKS: 10/10", 
			  "Stack counter should show 10/10")
	assert_eq(game_node.get_node("GameScore").text, "SCORE: 100", 
			  "Game score should be 100 (10 * 10)")
	assert_false(game_node.get_node("BackButton").disabled, "Back button should be enabled")
	assert_false(game_node.get_node("RestartButton").disabled, "Restart button should be enabled")
	assert_true(game_node.get_node("BackButton").visible, "Back button should be visible")
	assert_true(game_node.get_node("RestartButton").visible, "Restart button should be visible")
	
	game_node.queue_free()

# test game over with a lose condition (game_lost = true)
func test_game_over_lose():
	var game_node = library_game_scene.instantiate()
	add_child(game_node)
	await get_tree().process_frame
	
	# set lose condition
	game_node.game_lost = true
	game_node.game_over()
	
	# verify game state and UI updates
	assert_false(game_node.game_active, "game_active should be false on loss")
	assert_eq(game_node.get_node("GameMessage").text, "[center]You Lost", 
			  "Lose message should be shown")
	assert_false(game_node.get_node("BackButton").disabled, "Back button should be enabled")
	assert_false(game_node.get_node("RestartButton").disabled, "Restart button should be enabled")
	assert_true(game_node.get_node("BackButton").visible, "Back button should be visible")
	assert_true(game_node.get_node("RestartButton").visible, "Restart button should be visible")
	
	game_node.queue_free()

# test game over with continue condition (neither win nor lose)
func test_game_over_continue():
	var game_node = library_game_scene.instantiate()
	add_child(game_node)
	await get_tree().process_frame
	
	# set continue condition: stacked_books < WIN_COUNT, not lost
	game_node.stacked_books = 5
	game_node.game_lost = false
	var initial_books = get_tree().get_nodes_in_group("active_book").size()
	
	game_node.game_over()
	await get_tree().process_frame
	
	# verify a new book is spawned
	var books_after = get_tree().get_nodes_in_group("active_book").size()
	assert_eq(books_after, initial_books + 1, "Should spawn a new book when continuing")
	
	game_node.queue_free()
