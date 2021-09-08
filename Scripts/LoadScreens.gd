extends Node

var MainScreen = preload("res://Scenes/MainScreen.tscn")
var Theme_1 = preload("res://Scenes/Game.tscn")
var Theme_2 = preload("res://Scenes/Game_theme2.tscn")
var Theme_1_Tutorial = preload("res://Scenes/GameTutorial.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameDataManager.game_data["is_tutorial_completed"] == false :
		get_tree().change_scene_to(Theme_1_Tutorial)


