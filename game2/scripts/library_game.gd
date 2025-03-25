extends Node2D

@onready var stack_counter = $StackCounter
@onready var game_message = $GameMessage
@onready var spawn_timer = $SpawnTimer
@onready var game_score = $GameScore
@onready var back_button = $BackButton
@onready var restart_button = $RestartButton


var book_scene = preload("res://scenes/Book.tscn")
var stacked_books = 0
const WIN_COUNT = 10
var game_active = false
var game_lost = false
var multiplier = 4

func _ready():
	#preload("res://scenes/Library_interior.tscn")
		
	back_button.disabled = true
	restart_button.disabled = true
	_spawn_book()
	await get_tree().create_timer(0.5).timeout
	game_active = true
	
	
func _on_spawn_timer_timeout():
	var active_count = get_tree().get_nodes_in_group("active_book").size()
	var active_books = get_tree().get_nodes_in_group("active_book")
	
	if game_active:
		if active_books.size() > 0:
			#print(books.size())
			var active_book = active_books[0]
			#print("active book exists")
			active_book.global_position.x = get_global_mouse_position().x
	
	
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
	
	#print("Active books: ", active_count)
	if game_active and active_count == 0:
		_spawn_book()

func _spawn_book():
	var book = book_scene.instantiate()
	call_deferred("add_child", book)
	await get_tree().process_frame
	await book.random_scale()
	var random_int = randi_range(-300, 300)
	var spawn = Vector2((512 + random_int), -100)
	book.global_position = spawn
	
	book.add_to_group("active_book")
	print("Spawned book at: ", book.global_position)
	

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Library_interior.tscn")
	
func game_over():
	stack_counter.text = "BOOKS: %d/%d" % [stacked_books, WIN_COUNT]
	game_score.text = "SCORE: %d" % [multiplier * stacked_books]
	
	if game_lost:
		game_active = false
		_view_buttons()
		game_message.text = "[center]You Lost"
	elif stacked_books >= WIN_COUNT:
		game_active = false
		_view_buttons()
		game_message.text = "[center]You Win! Points added to total score!"
		Global.score += multiplier * stacked_books
	else:
		_spawn_book()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
	

func _view_buttons():
	back_button.disabled = false
	restart_button.disabled = false
	back_button.show()
	restart_button.show()
