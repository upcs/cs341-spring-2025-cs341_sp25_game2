extends LineEdit

func _ready():
	connect("gui_input", _on_gui_input)  # Corrected for Godot 4.x

func _on_gui_input(event):
	if event is InputEventScreenTouch and event.pressed:  # Use ScreenTouch for mobile
		grab_focus()  # Forces focus to trigger the keyboard
		print("LineEdit tapped!")  # Debug to confirm it’s working
