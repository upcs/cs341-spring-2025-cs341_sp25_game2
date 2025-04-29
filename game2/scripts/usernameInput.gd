extends LineEdit

func _ready():
	connect("gui_input", _on_gui_input)

func _on_gui_input(event):
	# use touchscreen for mobile
	if event is InputEventScreenTouch and event.pressed:
		grab_focus()
