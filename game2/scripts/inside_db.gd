extends Node2D
var paper = preload("res://scenes/paper.tscn")
var can_paper
var instance
var min_value = 10
var max_value = 1000
var timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.spawn_position = Vector2(650, 356)
	can_paper = false
	timer = $GameTimer
	$RichTextLabel2.text = "Score: " + str(Global.score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	randomize()  # Seed the random number generator
	var random_range = randi_range(min_value, max_value)  # Generates a random integer	
	$RichTextLabel.text = "Pick up all the papers by clicking on them! Time Left: " + str(int(timer.get_time_left()))
	if can_paper:
		instance = paper.instantiate()
		instance.SPEED = instance.SPEED + 100*abs((int(timer.get_time_left())-60))
		instance.position.x = random_range
		instance.scoreChange.connect(score_change)
		add_child(instance)
		can_paper = false
func score_change() -> void:
	Global.score += 1
	$RichTextLabel2.text = "Score: " + str(Global.score)


func _on_timer_timeout() -> void:
	can_paper = true


func _on_game_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/campus.tscn")
	Global.spawn_position = Vector2(650, 356)
