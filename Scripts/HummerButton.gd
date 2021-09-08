extends Button

signal Hummer_button_ready

export(int) var update_time = 15
export(Color) var progress_color

var button_state = true setget set_state, get_state

var current_progress_value = 0
var is_progressing = false

func _ready():
	$TextureProgress.modulate = progress_color
	$wifi_icon.modulate = progress_color
	if disabled:
		button_state = false
	else:
		button_state = true
		
func set_state(value : bool):
	if value:
		if is_progressing:
			stop_progress()
			is_progressing = false
		button_state = true
		disabled = false
	else:
		button_state = false
		disabled = true
		
func stop_progress():
	current_progress_value = 0
	$TextureProgress.value = 0
	$TextureProgress.visible = false
	is_progressing = false

func start_progress(time = 15):
	is_progressing = true
	time = update_time
	self.button_state = false
	$TextureProgress.visible = true
	$Tween.interpolate_property($TextureProgress, "value", 0, 100, time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	emit_signal("Hummer_button_ready")
	stop_progress()
	self.button_state = true

func get_state():
	return button_state

func play_no_connection_animation():
	$AnimationPlayer.play("noConnection")
