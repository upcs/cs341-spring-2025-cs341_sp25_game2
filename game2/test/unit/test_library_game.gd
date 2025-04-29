extends GutTest

var library_game_scene = preload("res://scenes/Library_game.tscn")
var game_node # Instance variable to hold the game node for easier cleanup

# Use before_each to instantiate the scene and add it to the tree
func before_each():
	game_node = library_game_scene.instantiate()
	# Add the node to the scene tree so physics_process and groups work
	add_child(game_node)
	game_node.difficulty = 0 # Easy
	# Wait a frame to ensure _ready is potentially called if it did anything (it doesn't much now)
	await get_tree().process_frame

# Use after_each to clean up the node
func after_each():
	if game_node and is_instance_valid(game_node):
		game_node.queue_free()
	# Wait a few frames to ensure cleanup is processed
	await get_tree().process_frame
	await get_tree().process_frame
	# Clear any remaining books
	for book in get_tree().get_nodes_in_group("active_book"):
		book.queue_free()
	for book in get_tree().get_nodes_in_group("stacked_book"):
		book.queue_free()
	for book in get_tree().get_nodes_in_group("first_book"):
		book.queue_free()
	await get_tree().process_frame


# test that start_game() correctly adds the first book
func test_start_game_spawns_initial_book():
	# game_node is created in before_each
	# Call start_game() which handles initial setup and first spawn
	await game_node.start_game() # Await because start_game now has awaits inside

	# start_game calls _spawn_book, which uses call_deferred and awaits process_frame
	# The await in start_game should cover this, but an extra frame wait can ensure stability.
	await get_tree().process_frame

	# verify one active book exists initially from start_game -> _spawn_book
	var initial_books = get_tree().get_nodes_in_group("active_book")
	assert_eq(initial_books.size(), 1, "start_game() should ensure one active book exists")

	# verify game is active
	assert_true(game_node.game_active, "game_active should be true after start_game()")


# test that _spawn_book() correctly adds a new book with expected properties
func test_spawn_book_adds_book():
	# Start the game to get the initial state and first book
	await game_node.start_game()
	await get_tree().process_frame
	var initial_books = get_tree().get_nodes_in_group("active_book")
	assert_eq(initial_books.size(), 1, "Should have one active book after start_game")

	# Call _spawn_book() directly to add another book
	await game_node._spawn_book() # Await because _spawn_book now has awaits inside
	# Wait for the deferred add_child and internal awaits to complete
	await get_tree().process_frame

	# check that a second book was added
	var books_after = get_tree().get_nodes_in_group("active_book")
	assert_eq(books_after.size(), 2, "Should have two active books after spawning another")

	# verify the new book's position (assuming x is randomized between 212 and 812, y is -100)
	# Note: Indexing might be fragile if order changes. Checking properties is safer.
	# Let's find the book with y close to -100 as the newly spawned one.
	var new_book = null
	for book in books_after:
		if is_equal_approx(book.global_position.y, -100.0):
			new_book = book
			break
	
	assert_not_null(new_book, "Could not find the newly spawned book (y=-100)")
	if new_book: # Avoid errors if assert_not_null fails
		assert_true(new_book.global_position.x >= (512 - 300) and new_book.global_position.x <= (512 + 300),
					"Book x position (%f) should be between 212 and 812" % new_book.global_position.x)
		assert_eq(new_book.global_position.y, -100, "Book y position should be -100")


# test that an active book falling too far triggers game loss via _physics_process
func test_active_book_falls_too_far_triggers_loss_in_physics():
	# Start the game
	await game_node.start_game()
	await get_tree().process_frame # Ensure book is added

	# Ensure game is active for physics process check
	assert_true(game_node.game_active, "Game should be active")

	# get the initial active book
	var active_books = get_tree().get_nodes_in_group("active_book")
	assert_eq(active_books.size(), 1, "Should have one active book")
	var book = active_books[0]

	# Move the book below y=550
	book.global_position = Vector2(512, 600) # y > 550

	# Manually simulate a physics frame to trigger the check inside _physics_process
	await get_tree().physics_frame
	await get_tree().physics_frame # Yes, running twice


	# Verify game_lost is true and game_active is false (because game_over was called)
	assert_true(game_node.game_lost, "game_lost should be true when book falls too far")
	assert_false(game_node.game_active, "game_active should be false after game over")


# Test game over with a win condition (stacked_books >= WIN_COUNT)
func test_game_over_win():
	# Need game to be active for game_over to proceed
	game_node.game_active = true

	# Set win condition: 10 stacked books, WIN_COUNT=10 (constant), multiplier=4 (easy default)
	game_node.stacked_books = 10
	# game_node.multiplier is set to 4 in before_each

	game_node.game_over()
	await get_tree().process_frame # Allow UI updates etc.

	# verify game state and UI updates
	assert_false(game_node.game_active, "game_active should be false on win")
	# NOTE: Check actual text from your game_over function
	assert_eq(game_node.get_node("GameMessage").text,
			  "[center]You Win!", # Updated win message
			  "Win message should be shown")
	assert_eq(game_node.get_node("StackCounter").text, "BOOKS: 10/10",
			  "Stack counter should show 10/10")
	# Score is multiplier * stacked_books = 4 * 10 = 40
	assert_eq(game_node.get_node("GameScore").text, "SCORE: 40",
			  "Game score should be 40 (4 * 10)")
	assert_true(game_node.get_node("LibraryGameMenu").visible, "Game Menu should be visible on win")
	# Button checks likely remain the same assuming they are children of LibraryGameMenu
	var menu = game_node.get_node("LibraryGameMenu")
	assert_false(menu.get_node("BackButton").disabled, "Back button should be enabled")
	assert_false(menu.get_node("PlayButton").disabled, "Play button should be enabled")


# test game over with a lose condition (game_lost = true)
func test_game_over_lose():
	# Need game to be active for game_over to proceed
	game_node.game_active = true
	# Set some stacked books for score calculation
	game_node.stacked_books = 5
	# game_node.multiplier is set to 4 in before_each

	# Set lose condition
	game_node.game_lost = true
	game_node.game_over()
	await get_tree().process_frame # Allow UI updates etc.

	# verify game state and UI updates
	assert_false(game_node.game_active, "game_active should be false on loss")
	# NOTE: Check actual text from your game_over function
	assert_eq(game_node.get_node("GameMessage").text, "[center]You Lost - Points Halved", # Updated lose message
			  "Lose message should be shown")
	# Score is (multiplier / 2) * stacked_books = (4 / 2) * 5 = 10
	assert_eq(game_node.get_node("GameScore").text, "SCORE: 10",
			  "Game score should be 10 (halved)")
	assert_true(game_node.get_node("LibraryGameMenu").visible, "Game Menu should be visible on loss")
	# Button checks likely remain the same
	var menu = game_node.get_node("LibraryGameMenu")
	assert_false(menu.get_node("BackButton").disabled, "Back button should be enabled")
	assert_false(menu.get_node("PlayButton").disabled, "Play button should be enabled")


# test game over with continue condition (neither win nor lose)
func test_game_over_continue_spawns_book():
	# Start the game normally first
	await game_node.start_game()
	await get_tree().process_frame
	assert_true(game_node.game_active, "Game should be active initially")

	# Set continue condition: stacked_books < WIN_COUNT, not lost
	game_node.stacked_books = 5 # Less than WIN_COUNT (10)
	game_node.game_lost = false

	var initial_books_count = get_tree().get_nodes_in_group("active_book").size()
	assert_eq(initial_books_count, 1, "Should have 1 active book before game_over continue call")

	# Call game_over - in the continue case, it should call _spawn_book
	game_node.game_over()

	# Wait for the deferred add_child and awaits within _spawn_book
	await get_tree().process_frame
	await get_tree().process_frame # Extra frame intentional

	# verify a new book is spawned
	var books_after = get_tree().get_nodes_in_group("active_book")
	# The OLD active book is NOT removed by game_over in the continue case
	# So, we expect the count to INCREASE by 1
	assert_eq(books_after.size(), initial_books_count + 1, "Should spawn a new active book when continuing")

	# Verify game state remains active
	assert_true(game_node.game_active, "game_active should remain true when continuing")


# Test the mouse following behavior in _physics_process
func test_active_book_follows_mouse_offset_in_physics():
	# Start the game
	await game_node.start_game()
	await get_tree().process_frame # Ensure book is added
	assert_true(game_node.game_active, "Game should be active")

	var active_books = get_tree().get_nodes_in_group("active_book")
	assert_eq(active_books.size(), 1, "Should have one active book")
	var book = active_books[0]
	var initial_x = book.global_position.x

	var initial_offset = game_node.offset
	game_node.offset += 50 # Change the offset

	# Simulate a physics frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	# The book's X should have changed based on the new offset relative to wherever

	var expected_x = initial_x + 50 # Approximately, depends on mouse pos and exact timing
	assert_ne(book.global_position.x, initial_x, "Book X position should change when offset changes")


# Test keyboard controls affecting offset (Basic Check)
func test_keyboard_input_changes_offset_in_physics():
	# Start the game
	await game_node.start_game()
	await get_tree().process_frame
	assert_true(game_node.game_active, "Game should be active")

	var initial_offset = game_node.offset

	# Simulate pressing "right" action
	Input.action_press("right") # Assumes "right" is mapped in Input Map

	# Simulate a physics frame where input is checked
	await get_tree().physics_frame
	await get_tree().physics_frame

	# Check if offset increased (by 5 according to the code)
	assert_eq(game_node.offset, initial_offset + 5, "Offset should increase by 5 when 'right' is pressed")

	# Release the action to avoid affecting other tests
	Input.action_release("right")
	await get_tree().physics_frame # Process the release potentially

	# Simulate pressing "left" action
	initial_offset = game_node.offset # Get potentially updated offset
	Input.action_press("left")

	await get_tree().physics_frame

	# Check if offset decreased
	assert_eq(game_node.offset, initial_offset - 5, "Offset should decrease by 5 when 'left' is pressed")

	Input.action_release("left")
	await get_tree().physics_frame


	# Test that setting difficulty before start_game applies correct multiplier and offset range
func test_difficulty_effects_on_start():
	# Test Easy (0)
	game_node.difficulty = 0
	await game_node.start_game() # start_game applies multiplier and calls random_offset
	await get_tree().process_frame # Ensure awaits in start_game finish

	assert_eq(game_node.multiplier, 4, "Multiplier should be 4 for Easy difficulty (0)")
	var easy_offset = game_node.offset
	# Check offset range from random_offset() for difficulty 0: randi_range(-100, -50)
	assert_true(easy_offset >= -100 and easy_offset <= -50,
				"Offset (%d) should be between -100 and -50 for Easy" % easy_offset)

	# Test Medium (1)
	# We call start_game again, which will reset state based on the *new* difficulty
	game_node.difficulty = 1
	await game_node.start_game()
	await get_tree().process_frame

	assert_eq(game_node.multiplier, 10, "Multiplier should be 10 for Medium difficulty (1)")
	var medium_offset = game_node.offset
	# Check offset range from random_offset() for difficulty 1: randi_range(-200, 0)
	assert_true(medium_offset >= -200 and medium_offset <= 0,
				"Offset (%d) should be between -200 and 0 for Medium" % medium_offset)

	# Test Hard (2)
	# Call start_game again
	game_node.difficulty = 2
	await game_node.start_game()
	await get_tree().process_frame

	assert_eq(game_node.multiplier, 30, "Multiplier should be 30 for Hard difficulty (2)")
	var hard_offset = game_node.offset
	# Check offset range from random_offset() for difficulty 2: randi_range(-350, 150)
	assert_true(hard_offset >= -350 and hard_offset <= 150,
				"Offset (%d) should be between -350 and 150 for Hard" % hard_offset)
	pass # Indicate test completion
