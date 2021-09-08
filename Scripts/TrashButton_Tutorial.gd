extends ColorRect

var is_dark_mode = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if is_dark_mode:
		set_dark_theme()
	else:
		set_day_theme()
	visible = false
	screen_in()
	$Panel/AnimationPlayer.play("Trash_Tutorial")

func set_dark_theme():
	color = "64000000"
	$Panel/trash/.modulate = "38abd7"
	$Panel.get("custom_styles/panel").bg_color = "363636"
	$Panel.get("custom_styles/panel").border_color = "38abd7"
	$Panel/ButtonDarkMode.visible = true
	$Panel/Button.visible = false

func set_day_theme():
	color = "4affffff"
	$Panel/trash/.modulate = "c9c7aa"
	$Panel.get("custom_styles/panel").bg_color = "fffef2"
	$Panel.get("custom_styles/panel").border_color = "e1ba1c"
	$Panel/ButtonDarkMode.visible = false
	$Panel/Button.visible = true

func screen_in(time = 0.2):
	modulate = Color(1,1,1,0)
	visible = true
	$Panel/Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Panel/Tween.start()

func screen_out(time = 0.2):
	$Panel/Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Panel/Tween.start()
	yield($Panel/Tween, "tween_all_completed")
	queue_free()


func _on_Button_pressed():
	screen_out()
