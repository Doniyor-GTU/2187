extends Node



func _on_pause_screen_ready():
	SoundManager.play_fixed_sound("game_over")


func _on_ReplayButton_pressed():
	SoundManager.play_fixed_sound("click")


func _on_BackStepButton_pressed():
	SoundManager.play_fixed_sound("click")
