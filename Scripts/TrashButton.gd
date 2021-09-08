extends Button

signal Trash_button_ready

export(int) var update_time = 15
export(Color) var progress_color

var button_state = true setget set_state, get_state

var tutorial_panel = preload("res://Scenes/Components/TutorialPanel.tscn")
var current_progress_value = 0
var is_progressing = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureProgress.modulate = progress_color
	$wifi_icon.modulate = progress_color
	if disabled:
		button_state = false
	else:
		button_state = true


func play_removed_animation():
	$AnimationPlayer.get_animation("removed").track_set_key_value(0,0,rect_scale)
	$AnimationPlayer.play("removed")
	yield($AnimationPlayer,"animation_finished")
	start_progress()

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
	emit_signal("Trash_button_ready")
	stop_progress()
	self.button_state = true

func get_state():
	return button_state

func _on_TrashButton_pressed():
	# press event while button enabled
	var panel = tutorial_panel.instance()
	var theme_no = SettingsManager._settings["display"]["theme"]
	if theme_no == 2:
		panel.is_dark_mode = true
	$CanvasLayer.add_child(panel)
	print("Show Tutorial panel")

func play_no_connection_animation():
	$AnimationPlayer.play("NoConnection")

#func _on_TrashButton_gui_input(event):
#	if button_state == false:
#		if event.is_action_pressed("ui_touch"):
#			rect_scale = Vector2(0.9,0.9)
#		if event.is_action_released("ui_touch"):
#			rect_scale = Vector2(1,1)
#			var mouse_pos = get_local_mouse_position()
#			var difference = rect_size - mouse_pos
#			if (difference.x > 0 and difference.x < rect_size.x) and (difference.y > 0 and difference.y < rect_size.y):
#				# press event while button disabled
#				print("show add")
#				emit_signal("show_reward_add")
#				self.button_state = true
