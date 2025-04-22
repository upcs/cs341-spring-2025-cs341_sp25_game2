extends Node2D

@onready var stack_counter = $StackCounter
@onready var game_message = $GameMessage
@onready var game_score = $GameScore
@onready var game_menu = $LibraryGameMenu
@onready var game_scores = $HighScores


var book_scene = preload("res://scenes/Book.tscn")
var stacked_books = 0
const WIN_COUNT = 10
var game_active = false
var game_lost = false
var difficulty = 0 # 0 for easy, 1, for medium, 2 for hard
var offset = randi_range(-100,-50) # random range added on each book spawn so you can't hold your mouse in one spot
var multiplier = 4


func _ready():
	refresh_high_scores()
	game_active = false


# starts the game
func start_game():
	refresh_high_scores()
	await remove_books()
	game_message.text = ""
	random_offset()
	stacked_books = 0
	stack_counter.text = "BOOKS: %d/%d" % [stacked_books, WIN_COUNT]
	game_score.text = "SCORE: %d" % floor(multiplier * stacked_books)
	
	_spawn_book()
	stack_counter.show()
	game_score.show()
	game_menu.hide()
	await get_tree().create_timer(0.5).timeout
	game_active = true
	game_lost = false
	
	# set multiplier depending on difficulty - MAKE SURE IT'S DIVISIBLE BY 2
	if difficulty == 0:
		multiplier = 4
	elif difficulty == 1:
		multiplier = 10
	else:
		multiplier = 30


# randomizes offset based on difficulty
func random_offset():
	if difficulty == 0:
		offset = randi_range(-100, -50)
	elif difficulty == 1:
		offset = randi_range(-200, 0)
	else:
		offset = randi_range(-350, 150)


# Removes all the instantiated books
func remove_books():
	var books = get_tree().get_nodes_in_group("active_book")
	books += get_tree().get_nodes_in_group("stacked_book")
	books += get_tree().get_nodes_in_group("first_book")
	print(books)
	for book in books:
		book.queue_free()


# move books to mouse position
func _physics_process(delta: float) -> void:
	var active_count = get_tree().get_nodes_in_group("active_book").size()
	var active_books = get_tree().get_nodes_in_group("active_book")
	
	if game_active:
		if active_books.size() > 0:
			#print(books.size())
			var active_book = active_books[0]
			#print("active book exists")
			active_book.global_position.x = (get_global_mouse_position().x + offset)
			
			# keyboard controls
			if Input.is_action_pressed("right"):
				offset += 5
			if Input.is_action_pressed("left"):
				offset -= 5
	
	# check if a book has fallen too far
	active_books = get_tree().get_nodes_in_group("active_book")
	var stacked_books_arr = get_tree().get_nodes_in_group("stacked_book")
	if active_count > 0:
		var active_book = active_books[0]
		if active_book.global_position.y > 550:
			game_lost = true
			game_over()
			return
	if stacked_books_arr.size() > 0:
		for i in range(stacked_books_arr.size()):
			var stacked_book = stacked_books_arr[i]
			if stacked_book.global_position.y > 550:
				game_lost = true
				game_over()
				return


func _spawn_book():
	random_offset()
	var book = book_scene.instantiate()
	call_deferred("add_child", book)
	await get_tree().process_frame
	
	# adjust offset in accordance with difficulty
	if difficulty == 0:
		await book.set_random_range(1.0, 1.5, 1.0, 1.5)
	elif difficulty == 1:
		await book.set_random_range(0.2, 2.1, 0.3, 2.1)
	else:
		await book.set_random_range(0.05, 0.3, 0.5, 2.4)
	
	await book.random_scale()
	var random_int = randi_range(-300, 300)
	var spawn = Vector2((512 + random_int), -100)
	book.global_position = spawn
	
	book.add_to_group("active_book")
	print("Spawned book at: ", book.global_position)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/Library_interior.tscn"))


# Checks if game is over, handles game steps
func game_over():
	if !game_active:
		return
	
	stack_counter.text = "BOOKS: %d/%d" % [stacked_books, WIN_COUNT]
	game_score.text = "SCORE: %d" % floor(multiplier * stacked_books)
	
	if game_lost:
		game_active = false
		
		
		game_message.text = "[center]You Lost - Points Halved"
		var score = floor(multiplier / 2 * stacked_books)
		game_score.text = "SCORE: %d" % score
		
		# adjust score in accordance to difficulty
		if difficulty == 0:
			if score > Global.lib_easy_score:
				Global.lib_easy_score = score
		elif difficulty == 1:
			if score > Global.lib_med_score:
				Global.lib_med_score = score
		else:
			if score > Global.lib_hard_score:
				Global.lib_hard_score = score
		
		game_menu.show()
		game_menu.refresh_options()
		
		print("Global score: ", Global.score)
	
	elif stacked_books >= WIN_COUNT:
		game_active = false
		
		game_message.text = "[center]You Win!"
		
		var score = floor(multiplier * stacked_books)
		game_score.text = "SCORE: %d" % score
		
		
		# adjust score in accordance to difficulty only if current score is a high score
		if difficulty == 0:
			if score > Global.lib_easy_score:
				Global.lib_easy_score = score
		elif difficulty == 1:
			if score > Global.lib_med_score:
				Global.lib_med_score = score
		else:
			if score > Global.lib_hard_score:
				Global.lib_hard_score = score
		
		game_menu.show()
		game_menu.refresh_options()
		
		print("Global score: ", Global.score)
		
		if difficulty == 2:
			for i in range(70):
				await get_tree().create_timer(0.1).timeout
				_spawn_book()
		
	else:
		print("Global score: ", Global.score)
		_spawn_book()
		
	refresh_high_scores()


# Refresh the game high scores
func refresh_high_scores() -> void:
	game_scores.text = "HIGH SCORES: \nEASY: %d \nMEDIUM: %d \nHARD: %d" % [Global.lib_easy_score, Global.lib_med_score, Global.lib_hard_score]
