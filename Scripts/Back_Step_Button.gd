extends Button


var button_state = true setget set_state, get_state


# Called when the node enters the scene tree for the first time.
func _ready():
	if disabled:
		button_state = false
	else:
		button_state = true


func set_state(value : bool):
	if value:
		button_state = true
		disabled = false
	else:
		button_state = false
		disabled = true

func get_state():
	return button_state


