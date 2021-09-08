extends Node

var initial_bricks = {"1": "1", "2": "3", "3": "1"}

var default_game_data = {
	"save_array": [],
	"high_score": 0,
	"current_score": 0,
	"current_bricks": initial_bricks,
	"first_run" : true,
	"is_trash_button_active" : true,
	"is_hummer_button_active" : true,
	"is_tutorial_completed" : false
}

var game_data = default_game_data

#var back_step_data = {}
var data = {"current_data" : game_data,
			"back_step_data" : {}}

func _ready():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		# creates a new file
		var err = save_game.open("user://savegame.save", File.WRITE)
		if err != OK:
			print("something went wrong!")
			return
		var initial_data = {"current_data" : game_data, "back_step_data" : {}}
		save_game.store_line(to_json(initial_data))
		save_game.close()
		#save_game()
#	else:
#		var saved_data = load_game()
#		refresh_data(game_data, saved_data)
	data = load_game()
	game_data = data["current_data"].duplicate()
	#back_step_data = data["back_step_data"].duplicate()

func refresh_data(new_data, old_data):
	# if app is developed and in new version has new data
	# it will be updated
	var is_refreshed = false
	for key in new_data.keys():
		if not old_data.has(key):
			old_data[key] = new_data[key]
			is_refreshed = true
	if is_refreshed:
		print("refreshed and saved")
		save_game(old_data)

func save_game(data_to_save = game_data, change_previous_datas : bool = false):
	var save_game = File.new()
	var err = save_game.open("user://savegame.save", File.WRITE)
	if err != OK:
		print("something went wrong!")
		return
	if change_previous_datas:
		#print("change")
		change_previous_data()
#	else:
#		# Might create logic bug, be carefull
#		data["current_data"] = game_data.duplicate()
#		print("not change")
	save_game.store_line(to_json(data))
	save_game.close()

func change_previous_data():
	data["back_step_data"] = data["current_data"].duplicate()
	data["current_data"] = game_data.duplicate()

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		print("SaveGame file not found")
		return default_game_data
	save_game.open("user://savegame.save", File.READ)
	var data = parse_json(save_game.get_line())
	return data
