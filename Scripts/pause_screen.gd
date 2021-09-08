extends Control

signal btn_pressed
signal back_step_pressed

var is_data_saved = false

func _ready():
	var score = GameDataManager.game_data["current_score"]
	var high_score = GameDataManager.game_data["high_score"]
	if score >= high_score:
		$GameOverPanel.visible = false
		$GameOverPanel_NewScore.visible = true
		$GameOverPanel_NewScore/HighScore.text = str(score)
	else:
		$GameOverPanel.visible = true
		$GameOverPanel_NewScore.visible = false
		$GameOverPanel/VBoxContainer/HighScore/HBoxContainer/VBoxContainer/Score.text = str(high_score)
		$GameOverPanel/VBoxContainer/CurrentScore.text = str(score)
	visible = false
	modulate = Color(1,1,1,0)
	yield(get_tree().create_timer(0.5),"timeout")
	SettingsManager._settings["game_data"]["state"] = false
	SettingsManager.save_settings()
	GameDataManager.game_data["current_bricks"] = GameDataManager.initial_bricks
	GameDataManager.game_data["save_array"] = []
	GameDataManager.game_data["current_score"] = 0
	GameDataManager.game_data["is_hummer_button_active"] = true
	GameDataManager.game_data["is_trash_button_active"] = true
	GameDataManager.data["current_data"] = GameDataManager.game_data.duplicate()
	GameDataManager.save_game()
	is_data_saved = true


func screen_in():
	visible = true
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func screen_out(time = 0.3):
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	queue_free()

func _on_ColorRect_gui_input(event):
	if event.is_action_pressed("ui_touch"):
		modulate = Color(1,1,1,0)
	elif event.is_action_released("ui_touch") and visible:
		modulate = Color(1,1,1,1)

func _on_ReplayButton_pressed():
	if is_data_saved:
		emit_signal("btn_pressed")
		SettingsManager._settings["game_data"]["state"] = true
		SettingsManager.save_settings()
		GameDataManager.data["back_step_data"] = {}
		GameDataManager.save_game()


func _on_BackStepButton_pressed():
	SettingsManager._settings["game_data"]["state"] = true
	SettingsManager.save_settings()
	screen_out()
	emit_signal("back_step_pressed")
	
