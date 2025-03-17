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
	game_active = true

func _input(event):
	if event is InputEventMouseMotion:
		var books = get_tree().get_nodes_in_group("active_book")
		if books.size() > 0:
			books[0].global_position.x = event.position.x

func _physics_process(delta):
	pass

func _on_spawn_timer_timeout():
	var active_count = get_tree().get_nodes_in_group("active_book").size()
	print("Active books: ", active_count)
	if game_active and active_count == 0:
		_spawn_book()

func _spawn_book():
	var book = book_scene.instantiate()
	book.global_position = spawn_point.global_position
	book.add_to_group("active_book")
	
	add_child(book)
	print("Spawned book at: ", book.global_position)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Library_interior.tscn")


func _on_ground_body_entered(book: Node2D) -> void:
	if book.is_in_group("ground"):
		return
	
	print("Book landed")
	if !game_active: return
	var velocity = book.linear_velocity.length()
	var noise_increase = clamp(velocity / 50.0, 0, 50)
	noise_level = clamp(noise_level + noise_increase, 0, MAX_NOISE)
	book.remove_from_group("active_book")
	book.freeze = true
	book.remove_from_group("active_book")
	book.freeze = true
	book.linear_velocity = Vector2.ZERO
	book.add_to_group("stacked_book")
	stacked_books += 1
	stack_counter.text = "Books: %d/%d" % [stacked_books, WIN_COUNT]
	if stacked_books >= WIN_COUNT:
		game_active = false
		game_message.text = "You Win!"
