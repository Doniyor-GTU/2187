extends Node

var sound_off_texture_1 = preload("res://Art/2_bb.png")
var sound_on_texture_1 = preload("res://Art/2_b.png")
var sound_off_texture_2 = preload("res://Art/3_bb.png")
var sound_on_texture_2 = preload("res://Art/3_b.png")

func _ready():
	set_theme()
	var high_score = GameDataManager.game_data["high_score"]
	var sound_on = SettingsManager._settings["audio"]["sounds_on"]
	set_high_score(high_score)
	set_sound_button_value(sound_on)

func set_high_score(val):
	$Theme_1/HighScore/HBoxContainer/VBoxContainer/Score.text = str(val)
	$Theme_2/HighScore/HBoxContainer/VBoxContainer/Score.text = str(val)
	
func set_sound_button_value(val):
	set_sound_btn_texture(sound_on_texture_1, sound_off_texture_1, $Theme_1/Buttons/SettingsButtons/Sound_button_1, val)
	set_sound_btn_texture(sound_on_texture_2, sound_off_texture_2, $Theme_2/Buttons/SettingsButtons/Sound_button_2, val)

func set_theme():
	var theme = SettingsManager._settings["display"]["theme"]
	if theme == 1:
		$Theme_1.visible = true
		$Theme_2.visible = false
	elif theme == 2:
		$Theme_1.visible = false
		$Theme_2.visible = true

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()


func set_sound_btn_texture(on_texture : Texture, of_texture : Texture, node, value : bool):
	if value != true:
		node.get("custom_styles/normal").set("texture", of_texture)
		node.get("custom_styles/hover").set("texture", of_texture)
		node.get("custom_styles/pressed").set("texture", of_texture)
	else:
		node.get("custom_styles/normal").set("texture", on_texture)
		node.get("custom_styles/hover").set("texture", on_texture)
		node.get("custom_styles/pressed").set("texture", on_texture)

	
func _on_Button_1_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(LoadScreens.Theme_1)


func _on_Theme_button_2_pressed():
# warning-ignore:return_value_discarded
	SettingsManager._settings["display"]["theme"] = 1
	SettingsManager.save_settings()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/MainScreen.tscn")


func _on_Theme_button_1_pressed():
# warning-ignore:return_value_discarded
	SettingsManager._settings["display"]["theme"] = 2
	SettingsManager.save_settings()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/MainScreen.tscn")


func _on_Sound_button_1_pressed():
	var sound_on = SettingsManager._settings["audio"]["sounds_on"]
	sound_on = not sound_on
	SettingsManager._settings["audio"]["sounds_on"] = sound_on
	SettingsManager.save_settings()
	set_sound_btn_texture(sound_on_texture_1, sound_off_texture_1, $Theme_1/Buttons/SettingsButtons/Sound_button_1, sound_on)
	

func _on_Sound_button_2_pressed():
	var sound_on = SettingsManager._settings["audio"]["sounds_on"]
	sound_on = not sound_on
	SettingsManager._settings["audio"]["sounds_on"] = sound_on
	SettingsManager.save_settings()
	set_sound_btn_texture(sound_on_texture_2, sound_off_texture_2, $Theme_2/Buttons/SettingsButtons/Sound_button_2, sound_on)


func _on_Star_button_1_pressed():
	OS.shell_open("https://play.google.com/store/apps/dev?id=7957242112767042750")


func _on_Star_button_2_pressed():
	OS.shell_open("https://play.google.com/store/apps/dev?id=7957242112767042750")


func _on_PlayButton_2_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(LoadScreens.Theme_2)

