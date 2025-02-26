extends Node

const PILOT_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
var screen_size : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	new_game() # Replace with function body.
	

func new_game():
	score = 0
	
	$Pilot.position = PILOT_START_POS
	$Pilot.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	#$Ground.position = Vector2i(0, 0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speed = START_SPEED
	
	$Pilot.position.x += speed
	$Camera2D.position.x += speed
	
	score += speed
	show_score()
	
	if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x += screen_size.x

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE" + str(score)
