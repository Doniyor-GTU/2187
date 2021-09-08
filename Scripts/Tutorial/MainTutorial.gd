extends Node

signal give_new_bricks

var game_over_screens = [
	preload("res://Scenes/game_over_screen.tscn"),
	preload("res://Scenes/game_over_screen_theme2.tscn")
	#preload("res://Scenes/game_over_screen_theme3.tscn")
]
var game_over_screen 
var passed_bricks = 0
var current_score = 0
var high_score = 0
var rnd = RandomNumberGenerator.new()
onready var go_back_timer = get_node("../GoBackTimer")
onready var game_node = get_node("../")

# Admob variables
var banner_load_tries = 0
var interstitial_load_tries = 0

func _ready():
#	$AdMob/StartLoadTimer.start()
	initialize_data()
	print(get_parent().name)
	set_game_over_screen()
	rnd.randomize()
	var left_bricks_count = GameDataManager.game_data["current_bricks"].size()
	if left_bricks_count != 0:
		passed_bricks = 3 - left_bricks_count
	set_score(GameDataManager.game_data["current_score"])
	set_high_score(GameDataManager.game_data["high_score"], false)

func initialize_data():
	GameDataManager.game_data["current_bricks"] = GameDataManager.initial_bricks
	GameDataManager.game_data["is_trash_button_active"] = true
	GameDataManager.game_data["is_hummer_button_active"] = true
	GameDataManager.game_data["save_array"] = []
	GameDataManager.game_data["current_score"] = 0
	GameDataManager.data["current_data"] = GameDataManager.game_data.duplicate()
	GameDataManager.data["back_step_data"] = {}
	GameDataManager.save_game()

func _on_back_step_called():
	var left_bricks_count = GameDataManager.game_data["current_bricks"].size()
	if left_bricks_count != 0:
		passed_bricks = 3 - left_bricks_count
	set_score(GameDataManager.game_data["current_score"])
	set_high_score(GameDataManager.game_data["high_score"], false)
	get_node("../Top_ui/TrashButton").button_state = GameDataManager.game_data["is_trash_button_active"]
	get_node("../Top_ui/HummerButton").button_state = GameDataManager.game_data["is_hummer_button_active"]

func set_game_over_screen():
	var theme = SettingsManager._settings["display"]["theme"]
	if theme == 1:
		game_over_screen = game_over_screens[0]
	elif theme == 2:
		game_over_screen = game_over_screens[1]
#	elif theme == 3:
#		game_over_screen = game_over_screens[2]

func increase_score(amount):
	# Adds amount to current_score
	var score_str = ""
	current_score += amount
	if current_score > high_score:
		set_high_score(current_score)
	if SettingsManager._settings["display"]["theme"] == 0:
		#get_node("../Top_ui").score_increase_effect(true)
		score_str = str(current_score)
	else:
		#get_node("../Top_ui").score_increase_effect(false)
		score_str = str(current_score)
	get_node("../Top_ui/Etap").text = score_str
	GameDataManager.game_data["current_score"] = current_score
	GameDataManager.save_game()

func set_score(amount):
	var score_str = ""
	current_score = amount
	if SettingsManager._settings["display"]["theme"] == 0:
		#get_node("../Top_ui").score_increase_effect(true)
		score_str = str(current_score)
	else:
		#get_node("../Top_ui").score_increase_effect(false)
		score_str = str(current_score)
	get_node("../Top_ui/Etap").text = score_str


func set_high_score(amount, need_save_data : bool = true):
	# Changes high_score with amount
	var high_score_str = ""
	high_score = amount
	if SettingsManager._settings["display"]["theme"] == 0:
		high_score_str = "BEST " + str(high_score)
	else:
		high_score_str = str(high_score)
	get_node("../Top_ui/High_Score").text = high_score_str
	if need_save_data:
		GameDataManager.game_data["high_score"] = high_score
		GameDataManager.save_game()


func _on_Grid_brick_passed():
	if passed_bricks == 2:
		passed_bricks = 0
		emit_signal("give_new_bricks")
		#return
	else:
		passed_bricks += 1


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and go_back_timer.is_stopped() and not get_tree().paused:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Scenes/MainScreen.tscn")


func Replay_the_game():
	GameDataManager.game_data["current_bricks"] = GameDataManager.initial_bricks
	GameDataManager.game_data["save_array"] = []
	GameDataManager.game_data["current_score"] = 0
	GameDataManager.game_data["is_trash_button_active"] = true
	GameDataManager.game_data["is_hummer_button_active"] = true
	GameDataManager.data["current_data"] = GameDataManager.game_data.duplicate()
	GameDataManager.data["back_step_data"] = {}
	GameDataManager.save_game()
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(LoadScreens.Theme_1)

func _on_Replay_Button_pressed():
	get_node("../Top_ui/CanvasLayer/YesNoPanel").screen_in()


func _on_Grid_game_stucked():
	var screen = game_over_screen.instance()
	get_parent().add_child(screen)
	screen.connect("back_step_pressed", self, "_on_Back_Step_Button_pressed")
	screen.connect("btn_pressed", self, "_on_btn_pressed")
	screen.screen_in()


func _on_btn_pressed():
#	if $AdMob.is_interstitial_loaded():
#		$AdMob.show_interstitial()
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(LoadScreens.Theme_1)

func _on_Home_Button_pressed():
#	if $AdMob.is_interstitial_loaded():
#		$AdMob.show_interstitial()
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(LoadScreens.MainScreen)

func _on_Grid_numbers_merged(sum):
	increase_score(sum)

func _on_Back_Step_Button_pressed():
	if GameDataManager.data["back_step_data"].size() > 0:
		GameDataManager.game_data = GameDataManager.data["back_step_data"].duplicate()
		GameDataManager.data["current_data"] = GameDataManager.data["back_step_data"].duplicate()
		GameDataManager.data["back_step_data"] = {}
		GameDataManager.save_game()
		_on_back_step_called()
		get_node("../Top_ui/Back_Step_Button").button_state = false
		get_node("../Grid")._on_back_step_called()
		get_node("../Bottom_ui")._on_back_step_called()
#		if $AdMob.is_interstitial_loaded():
#			yield(get_tree().create_timer(1), "timeout")
#			$AdMob.show_interstitial()


func _on_Grid_brick_removed():
	if passed_bricks == 2:
		passed_bricks = 0
		emit_signal("give_new_bricks")
		#return
	else:
		passed_bricks += 1
#	if $AdMob.is_interstitial_loaded():
#		yield(get_tree().create_timer(1), "timeout")
#		$AdMob.show_interstitial()



func _on_TrashButton_Trash_button_ready():
	GameDataManager.game_data["is_trash_button_active"] = true
	GameDataManager.data["current_data"]["is_trash_button_active"] = true
	GameDataManager.save_game()


func _on_YesButton_pressed():
#	if $AdMob.is_interstitial_loaded():
#			$AdMob.show_interstitial()
	Replay_the_game()


func _on_HummerButton_Hummer_button_ready():
	GameDataManager.game_data["is_hummer_button_active"] = true
	GameDataManager.data["current_data"]["is_hummer_button_active"] = true
	GameDataManager.data["back_step_data"]["is_hummer_button_active"] = true
	GameDataManager.save_game()


# ---------------- Add Loading ---------------------

#func _on_StartLoadTimer_timeout():
#	$AdMob.load_banner()
#	$AdMob.load_interstitial()
#
#
#func _on_BannerReloadTimer_timeout():
#	$AdMob.load_banner()
#
#
#func _on_AdMob_banner_failed_to_load(error_code):
#	if error_code == 3 and banner_load_tries <= 5:
#		print("Banner, The ad request was successful, but no ad was returned due to lack of ad inventory.")
#		$AdMob.load_banner()
#		banner_load_tries += 1
#	elif error_code == 3 and banner_load_tries > 5:
#		$BannerFailedTimer.start()
#	else:
#		$AdMob/BannerNoConnectionTimer.start()
#		if not get_node("../Top_ui/HummerButton").button_state:
#			get_node("../Top_ui/HummerButton").start_progress()
#			get_node("../Top_ui/HummerButton").play_no_connection_animation()
#		if not get_node("../Top_ui/TrashButton").button_state:
#			get_node("../Top_ui/TrashButton").start_progress()
#			get_node("../Top_ui/TrashButton").play_no_connection_animation()
#
#
#func _on_AdMob_banner_loaded():
#	$AdMob.hide_banner()
#	yield(get_tree().create_timer(1), "timeout")
#	$AdMob.show_banner()
#	$AdMob/BannerReloadTimer.start()
#	banner_load_tries = 0
#
#
#func _on_BannerNoConnectionTimer_timeout():
#	banner_load_tries = 0
#	$AdMob.load_banner()
#
#
#func _on_BannerFailedTimer_timeout():
#	banner_load_tries = 0
#	$AdMob.load_banner()
#
#
#func _on_AdMob_interstitial_closed():
#	$AdMob.load_interstitial()
#
#
#func _on_AdMob_interstitial_failed_to_load(error_code):
#	if error_code == 3 and interstitial_load_tries <= 5:
#		print("Interstitial, The ad request was successful, but no ad was returned due to lack of ad inventory.")
#		$AdMob.load_interstitial()
#		interstitial_load_tries += 1
#	elif error_code == 3 and interstitial_load_tries > 5:
#		$AdMob/InterstitialFailedTimerr.start()
#	else:
#		$AdMob/InterstitialNoConnectionTimer.start()
#
#
#func _on_InterstitialNoConnectionTimer_timeout():
#	interstitial_load_tries = 0
#	$AdMob.load_interstitial()
#
#
#func _on_InterstitialFailedTimerr_timeout():
#	interstitial_load_tries = 0
#	$AdMob.load_interstitial()
#
#
#func _on_Grid_hummer_removed_brick():
#	if $AdMob.is_interstitial_loaded():
#		yield(get_tree().create_timer(1), "timeout")
#		$AdMob.show_interstitial()
