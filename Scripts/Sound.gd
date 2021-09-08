extends Node

func _ready():
	#SoundManager.play_fixed_sound("start_game")
	pass

func _on_Grid_brick_passed():
	SoundManager.play_fixed_sound("placed")


func _on_Grid_brick_wrong_place():
	SoundManager.play_fixed_sound("wrong_place")


func _on_brick_panel4_brick_rotated():
	SoundManager.play_fixed_sound("placed")


func _on_brick_panel5_brick_rotated():
	SoundManager.play_fixed_sound("placed")


func _on_brick_panel6_brick_rotated():
	SoundManager.play_fixed_sound("placed")


func _on_Home_Button_pressed():
	SoundManager.play_fixed_sound("click")


func _on_Grid_numbers_merged(sum):
	SoundManager.play_fixed_sound("merge_numbers")


func _on_Grid_brick_removed():
	SoundManager.play_fixed_sound("remove_brick")


func _on_brick_panel4_bricks_added_from_down():
	SoundManager.play_fixed_sound("new_bricks", -10)


func _on_brick_panel5_bricks_added_from_down():
	SoundManager.play_fixed_sound("new_bricks", -10)


func _on_brick_panel6_bricks_added_from_down():
	SoundManager.play_fixed_sound("new_bricks", -10)


func _on_Replay_Button_pressed():
	SoundManager.play_fixed_sound("click")


func _on_Back_Step_Button_pressed():
	SoundManager.play_fixed_sound("click")


func _on_TrashButton_pressed():
	SoundManager.play_fixed_sound("click")




func _on_Grid_hummer_removed_brick():
	SoundManager.play_fixed_sound("click")
