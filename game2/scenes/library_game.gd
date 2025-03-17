extends Node2D

@onready var spawn_point = $SpawnPoint
@onready var noise_meter = $NoiseMeter
@onready var stack_counter = $StackCounter
@onready var game_message = $GameMessage
@onready var spawn_timer = $SpawnTimer

var book_scene = preload("res://scenes/Book.tscn")
var stacked_books = 0
var noise_level = 0.0
const MAX_NOISE = 100.0
const WIN_COUNT = 10
var game_active = true

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	noise_meter.max_value = MAX_NOISE
	noise_meter.value = noise_level
	_spawn_book()

func _physics_process(delta):
	if game_active:
		noise_level = max(0, noise_level - 10 * delta)
		noise_meter.value = noise_level
		if noise_level >= MAX_NOISE:
			_end_game(false)

func _input(event):
	if game_active and event is InputEventMouseMotion:
		var books = get_tree().get_nodes_in_group("active_book")
		if books.size() > 0:
			books[0].global_position.x = event.position.x

func _on_spawn_timer_timeout():
	var active_count = get_tree().get_nodes_in_group("active_book").size()
	print("Active books: ", active_count)
	if game_active and active_count == 0:
		_spawn_book()

func _spawn_book():
	var book = book_scene.instantiate()
	book.global_position = spawn_point.global_position
	book.add_to_group("active_book")
	book.body_entered.connect(_on_book_landed.bind(book))
	add_child(book)
	print("Spawned book at: ", book.global_position)

func _on_book_landed(body, book):
	print("Book ", book.name, " landed on: ", body.name, " at position: ", book.global_position)
	if !game_active: return
	
	var velocity = book.linear_velocity.length()
	var noise_increase = clamp(velocity / 50.0, 0, 50)
	noise_level = clamp(noise_level + noise_increase, 0, MAX_NOISE)
	
	if body.is_in_group("ground") or body.is_in_group("stacked_book"):
		book.remove_from_group("active_book")
		book.freeze = true
		book.linear_velocity = Vector2.ZERO
		book.add_to_group("stacked_book")
		stacked_books += 1
		stack_counter.text = "Books: %d/%d" % [stacked_books, WIN_COUNT]
		if stacked_books >= WIN_COUNT:
			_end_game(true)

func _end_game(won: bool):
	game_active = false
	spawn_timer.stop()
	game_message.text = "You Win!" if won else "Too Noisy!"
	await get_tree().create_timer(2.0).timeout

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Library_interior.tscn")
