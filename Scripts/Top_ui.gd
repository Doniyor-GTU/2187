extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameDataManager.data["back_step_data"].size() > 0:
		$Back_Step_Button.button_state = true
	else:
		$Back_Step_Button.button_state = false
		

func play_animation(type = "Score_gained"):
	$AnimationPlayer.play(type)


func _on_Grid_numbers_merged(sum):
	play_animation()
	$Back_Step_Button.button_state = true


func _on_Grid_brick_passed():
	$Back_Step_Button.button_state = true




func _on_Grid_brick_removed():
	# wait for end of remove animation
	yield(get_tree().create_timer(1), "timeout")
	$Back_Step_Button.button_state = true



func _on_Grid_hummer_removed_brick():
	$HummerButton.pressed = false
	$Back_Step_Button.button_state = true
	$HummerButton.start_progress()


func _on_Grid_hummer_wrong_place(global_mouse_position):
	var button_pos = $HummerButton.rect_global_position
	var button_size = $HummerButton.rect_size
	if not (global_mouse_position.x > button_pos.x and global_mouse_position.x < button_pos.x + button_size.x) or not (global_mouse_position.y > button_pos.y and global_mouse_position.y < button_pos.y + button_size.y):
		$HummerButton.pressed = false
