extends CharacterBody2D
const SPEED = 5000
var can_click = false
signal scoreChange
func _ready() -> void:
	$Timer.start()
func _physics_process(delta: float) -> void:
	# Add the gravity
	if can_click and Input.is_action_pressed("Click"):
		can_click = false
		scoreChange.emit()
		queue_free()
	velocity.y = SPEED*delta
	move_and_slide()
	


func _on_area_2d_mouse_entered() -> void:
	can_click = true


func _on_area_2d_mouse_exited() -> void:
	can_click = false


func _on_timer_timeout() -> void:
	queue_free()
