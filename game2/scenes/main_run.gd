extends Node

#preload obstacles
var chair_scene = preload("res://chair.tscn")
var desk_scene = preload("res://desk.tscn")
var obstacle_types := [chair_scene, desk_scene]
var obstacles : Array

const PILOT_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER = 5000
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = Vector2i(1123, 711)
	var ground_sprite = $Ground/CollisionShape2D
	ground_height = ground_sprite.global_position.y
	$GameOver.get_node("Button").pressed.connect(new_game)
	$GameOver.get_node("Button2").pressed.connect(exit)
	new_game() 

func exit():
	# Update global score variable
	if (score / 100) > Global.pilot_run_score:
		Global.pilot_run_score = (score / 100)
	Global.update_score() # update global score
	get_tree().paused = false
	Global.spawn_position = Vector2(3712, 1856)
	Global.markercount += 1
	get_tree().change_scene_to_packed(load("res://scenes/campus.tscn"))

func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Pilot.global_position = PILOT_START_POS
	$Pilot.velocity = Vector2i(0,0)
	$Camera2D.global_position = CAM_START_POS
	$Ground.global_position = Vector2i(0, 0)
	
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()

func _process(delta):
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		generate_obs()
		
		$Pilot.global_position.x += speed
		$Camera2D.global_position.x += speed
		
		score += speed
		show_score()
		
		if $Camera2D.global_position.x - $Ground.global_position.x > screen_size.x * 1.0:
			$Ground.global_position.x += (screen_size.x / 2)
			
		for obs in obstacles:
			if obs.global_position.x < ($Camera2D.global_position.x - screen_size.x):
				remove_obs(obs)
				
	else:
		if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("Click"):
			$HUD.get_node("StartLabel").hide()
			$Pilot.process_mode = Node.PROCESS_MODE_DISABLED
			game_running = true
			await get_tree().create_timer(0.2).timeout
			$Pilot.process_mode = Node.PROCESS_MODE_INHERIT

func generate_obs():
	if obstacles.is_empty() or last_obs.global_position.x < score + randi_range(50, 100):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = max(1, difficulty)
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			
			# Get the obstacle's sprite and its height
			var obs_sprite = obs.get_node("Sprite2D")
			var obs_texture = obs_sprite.texture
			var obs_height = obs_texture.get_height() if obs_texture else 0
			var obs_scale = obs_sprite.global_scale
			
			# Calculate x position
			var obs_x : int = screen_size.x + score + 100 + (i * 150)
			
			# Decide if obstacle is on ground or in air (50% chance)
			var is_air_obstacle = randf() < 0.5
			var obs_y : int
			
			if is_air_obstacle:
				var air_height_range = randi_range(250, 400)
				obs_y = ground_height - (obs_height * obs_scale.y / 2) - air_height_range
			else:
				obs_y = ground_height - (obs_height * obs_scale.y / 2)
			
			last_obs = obs
			add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.global_position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "Pilot":
		game_over()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score/SCORE_MODIFIER)
	
func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
		
func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
