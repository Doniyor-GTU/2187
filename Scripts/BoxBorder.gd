extends Panel



# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	screen_in()

func set_color(clr : Color):
	get("custom_styles/panel").border_color = clr

func screen_in():
	var color = modulate
	var from = Color(color.r, color.g, color.b, 0)
	var to = Color(color.r, color.g, color.b, 1)
	visible = true
	$Tween.interpolate_property(self, "modulate", from, to, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
