extends Node2D

enum {HUMMER, CHOICE, SELECT, PLAY, GAME_OVER, WIN, PAUSE}
enum {TUTORIAL_PART1, TUTORIAL_PART2, TUTORIAL_FINISHED}

var state = PLAY
var tutorial_state = TUTORIAL_PART1

signal brick_passed
signal game_stucked
signal brick_wrong_place
signal find_matches_finished
signal numbers_merged(sum)
signal brick_removed
signal tutorial_finished
signal hummer_removed_brick
signal hummer_wrong_place(global_mouse_position)

export(int) var rows = 0
export (int) var columns = 0
export(int) var x_start
export(int) var y_start
export(int) var offset
export(Color) var border_color

onready var grid_container_node = get_node("../GridContainer")
onready var Bottom_ui_node = get_node("../Bottom_ui")
onready var TrashButton = get_node("../Top_ui/TrashButton")
var box_border_path = preload("res://Scenes/Components/BoxBorder.tscn")
var TrashButton_global_position = Vector2() 
var TrashButton_size = Vector2() 

var current_drawed_brick
var grid_array = []
var passed_positions = []

var is_pressed_into_board = false
var is_current_brick_changed = false
var is_on_trashButton = false
var is_box_border_exist = false


# Stores the selected 3 bricks on board
var selected_bricks = []
var selected_brick_grid_positions = []

var possible_bricks = {
	"1": preload("res://Scenes/Components/Bricks/1.tscn"),
	"3": preload("res://Scenes/Components/Bricks/3.tscn"),
	"9": preload("res://Scenes/Components/Bricks/9.tscn"),
	"27": preload("res://Scenes/Components/Bricks/27.tscn"),
	"81": preload("res://Scenes/Components/Bricks/81.tscn"),
	"243": preload("res://Scenes/Components/Bricks/243.tscn"),
	"729": preload("res://Scenes/Components/Bricks/729.tscn"),
	"2187": preload("res://Scenes/Components/Bricks/2187.tscn"),
	"6561": preload("res://Scenes/Components/Bricks/6561.tscn"),
	"19683": preload("res://Scenes/Components/Bricks/19683.tscn"),
	"59049": preload("res://Scenes/Components/Bricks/59049.tscn"),
	"z": preload("res://Scenes/Components/Bricks/z_brick.tscn"),
	"2_h": preload("res://Scenes/Components/Bricks/2_h.tscn"),
	"3_h": preload("res://Scenes/Components/Bricks/3_h.tscn"),
	"bottom_corner": preload("res://Scenes/Components/Bricks/bottom_corner.tscn"),
	"2x2": preload("res://Scenes/Components/Bricks/2x2.tscn"),
	"T": preload("res://Scenes/Components/Bricks/T.tscn"),
	"L_down": preload("res://Scenes/Components/Bricks/L_down.tscn"),
	"L_up": preload("res://Scenes/Components/Bricks/L_up.tscn"),
	"z_inverse": preload("res://Scenes/Components/Bricks/z_inverse.tscn"),
	"top_corner": preload("res://Scenes/Components/Bricks/top_corner.tscn")
	}

# --------- Tutorial variables start -----------------------

var is_tutorial_finished = false
var finger_pos = preload("res://Scenes/Components/fingerSwipe.tscn")
var finger
var finger_start_pos
var finger_end_pos
var grid_pos_to_past = [Vector2(2,3), Vector2(2,2), Vector2(3,3), Vector2(1,3),Vector2(6,2),Vector2(3,4)]
var merge_pos = [[Vector2(1,2), Vector2(3,2)], [Vector2(1,3), Vector2(3,3)], [Vector2(5,2), Vector2(3,2)], [Vector2(3,2), Vector2(3,4)]]
var merge_onto_pos = [Vector2(3,2), Vector2(3,3), Vector2(3,2), Vector2(3,3)]
var brick_panel_no = [5,4,6,4,6,5]
var brick_right_angles = [0,0,0,180,90,0]
var brick_types = ["3", "1", "2x2", "T", "bottom_corner", "9"]
var index_no = 0
var is_play_finger_animation = false
var is_rotate_animation = false
var current_hint_brick

# --------- Tutorial variables end -----------------------

var gap_between_boxes 

func _ready():
	tutorial_state = TUTORIAL_PART1
	TrashButton_global_position = TrashButton.rect_global_position
	TrashButton_size = TrashButton.rect_size
	gap_between_boxes = get_node("../GridContainer").get("custom_constants/vseparation")
	x_start = grid_container_node.rect_position.x
	y_start = grid_container_node.rect_position.y
	#var arr = GameDataManager.game_data["save_array"]
	grid_array = generate_2d_array()
	#spawn_bricks(arr)
	create_hint_brick(index_no)
	yield(get_tree().create_timer(0.1), "timeout")
	set_finger_pos(index_no)
	finger = finger_pos.instance()
	add_child(finger)
	play_finger_animation(finger_start_pos, finger_end_pos)
	set_process(false)
#	if not GameDataManager.game_data["is_trash_button_active"]:
#		TrashButton.start_progress()

func _on_back_step_called():
	state = PLAY
	clear_board()
	var arr = GameDataManager.game_data["save_array"]
	grid_array = generate_2d_array()
	spawn_bricks(arr, false)

func generate_2d_array():
	var arr = []
	for i in range(rows):
		arr.append([])
		for j in columns:
			arr[i].append(null)
	return arr

func spawn_bricks(saved_array, is_animation_on : bool = true):
	if not saved_array == []:
		for i in range(saved_array.size()):
			for j in range(saved_array[i].size()):
				if saved_array[i][j] != null:
					add_a_brick_to_grid(Vector2(i,j), saved_array[i][j], is_animation_on)

func grid_to_pixel(grid_pos):
	var row = grid_pos.x
	var column = grid_pos.y
	var new_x = x_start + 2*offset*column + offset + column*gap_between_boxes
	var new_y = y_start + 2*offset*row + offset + row*gap_between_boxes
	return Vector2(new_x, new_y)

func pixel_to_grid(pixel_pos):
	var pos_x = pixel_pos.x
	var pos_y = pixel_pos.y
	var column = (pos_x - x_start)
	var row = (pos_y - y_start)
	if row > 0 and column > 0:
		row = int(row) / (2*offset+gap_between_boxes)
		column = int(column) / (2*offset+gap_between_boxes)
		#row = int(pos_y-y_start-offset)/(2*offset+gap_between_boxes)
		#column = int(pos_x-x_start-offset)/(2*offset+gap_between_boxes)
	if (row <= rows - 1 and row >= 0) and (column <= columns - 1 and column >= 0):
		return Vector2(row, column)
	else:
		return null

func add_a_brick_to_grid(pos, type, is_animation_on : bool = true):
	var brick = possible_bricks[type].instance()
	add_child(brick)
	brick.position = grid_to_pixel(pos)
	brick.scale = brick.brick_size_passed
	brick.is_movable = false
	if is_animation_on:
		brick.screen_in(0.2)
	grid_array[pos.x][pos.y] = brick

func add_new_brick_to_grid(pos, type):
	var brick = possible_bricks[type].instance()
	add_child(brick)
	brick.position = grid_to_pixel(pos)
	brick.scale = brick.brick_size_passed
	brick.is_movable = false
	brick.increase_effect()
	grid_array[pos.x][pos.y] = brick

func add_brick_to_grid(pos,type_arr):
	var diff = pos - Vector2(1,1)
	passed_positions = []
	for elt in type_arr:
		if elt[1] != 0:
			var brick = possible_bricks[str(elt[1])].instance()
			add_child(brick)
			brick.position = grid_to_pixel(Vector2(elt[0].x + diff.x, elt[0].y + diff.y))
			brick.scale = brick.brick_size_passed
			brick.is_movable = false
			grid_array[elt[0].x + diff.x][elt[0].y + diff.y] = brick
			passed_positions.append(Vector2(elt[0].x + diff.x, elt[0].y + diff.y))


func generate_save_array(array_to_save):
	var arr = []
	for row in array_to_save:
		var arr2 = []
		for col in row:
			#if col != null:
			if is_instance_valid(col):
				arr2.append(col.brick_type)
			else:
				arr2.append(null)
		arr.append(arr2)
	return arr


func is_idx_in_grid(row,column):
	if (row >= 0 and row < rows) and (column >= 0 and column < columns):
		return true
	return false
	
	
func is_grid_available(grid_position, type_arr):
	if grid_position != null:
		var diff = grid_position - Vector2(1,1)
		for elt in type_arr:
			if elt[1] != 0:
				if is_idx_in_grid(elt[0].x + diff.x, elt[0].y + diff.y):
					#if grid_array[elt[0].x + diff.x][elt[0].y + diff.y] != null:
					if is_instance_valid(grid_array[elt[0].x + diff.x][elt[0].y + diff.y]):
						return false
				else:
					return false
		return true


func is_place_exists(type_arr):
	for i in range(rows):
		for j in range(columns):
			if is_grid_available(Vector2(i,j), type_arr):
				return true
	return false

func is_game_stuck(current_bricks):
	# checks that 's there exist a place on board for current panel bricks
	for brick in current_bricks:
		if is_place_exists(brick.brick_type_array):
			#print("place exists")
			return false
		var c = 0
		var rotated_brick_type_arr = brick.rotate_and_return_copy(brick.brick_type_array)
		while c<4:
			#print("rotated")
			if is_place_exists(rotated_brick_type_arr):
				print("rotate checked and place exists")
				return false
			c+=1
			rotated_brick_type_arr = brick.rotate_and_return_copy(rotated_brick_type_arr)
	#print("no place")
	if is_match_exist():
		#print("merge and continue")
		return false
	else:
		#print("stuckk")
		return true

func is_match_exist():
	for i in range(rows):
		for j in range(columns):
			#if grid_array[i][j] != null:
			if is_instance_valid(grid_array[i][j]):
				var current_type = grid_array[i][j].brick_type
				if i > 0  and i < rows-1:
					#if grid_array[i-1][j] != null and grid_array[i+1][j] != null:
					if is_instance_valid(grid_array[i-1][j]) and is_instance_valid(grid_array[i+1][j]):
						if grid_array[i-1][j].brick_type == current_type and grid_array[i+1][j].brick_type == current_type:
							return true
				if j > 0  and j < columns-1:
					if is_instance_valid(grid_array[i][j-1]) and is_instance_valid(grid_array[i][j+1]):
						if grid_array[i][j-1].brick_type == current_type and grid_array[i][j+1].brick_type == current_type:
							return true
	return false

func save_current_bricks():
	var current_bricks_dictionary = Bottom_ui_node.get_current_bricks_as_dict()
	GameDataManager.game_data["current_bricks"] = current_bricks_dictionary
	GameDataManager.save_game(GameDataManager.game_data, true)

func save_current_board(arr = grid_array, change_previous_data : bool = false):
	var save_array = generate_save_array(arr)
	GameDataManager.game_data["save_array"] = save_array
	if change_previous_data:
		GameDataManager.save_game(GameDataManager.game_data, true)
	else:
		GameDataManager.save_game()

func check_is_game_stuck():
	var current_bricks_arr = Bottom_ui_node.get_current_bricks()
# warning-ignore:shadowed_variable
	var is_stuck = is_game_stuck(current_bricks_arr)
	if is_stuck:
		yield(get_tree().create_timer(0.5),"timeout")
		print("game_stuck")
		state = GAME_OVER
		emit_signal("game_stucked")
	
func past_brick(grid_pos, current_brick):
	#if current_brick != null:
	if is_instance_valid(current_brick):
		is_current_brick_changed = false
		if tutorial_state == TUTORIAL_PART1:
			if is_grid_available(grid_pos, current_brick.brick_type_array) and grid_pos == grid_pos_to_past[index_no] and (current_brick.degree - brick_right_angles[index_no]) % 360 == 0 and current_brick.brick_type == brick_types[index_no]:
				print("Tutorial 1")
				get_node("../GoBackTimer").start()
				add_brick_to_grid(grid_pos, current_brick.brick_type_array)
				emit_signal("brick_passed")
				current_brick.queue_free()
				current_hint_brick.queue_free()
				save_current_board()
				yield(current_brick, "tree_exited")
				yield(get_tree().create_timer(0.2),"timeout")
				save_current_bricks()
				check_is_game_stuck()
				
				stop_finger_animation()
				#finger_start_pos = Bottom_ui_node.get_node("brick_panel4").rect_global_position + Bottom_ui_node.get_node("brick_panel4").rect_size/2
				if index_no < brick_types.size() - 1:
					index_no += 1
					create_hint_brick(index_no)
					set_finger_pos(index_no)
					check_right_degree(index_no)
					if is_rotate_animation == true:
						play_finger_animation(finger_start_pos, finger_end_pos, "oneTap")
					else:
						play_finger_animation(finger_start_pos, finger_end_pos)
				else:
					index_no = 0
					tutorial_state = TUTORIAL_PART2
					merge_animation_play()
			else:
				if is_rotate_animation == true:
					play_finger_animation(finger_start_pos, finger_end_pos, "oneTap")
				else:
					play_finger_animation(finger_start_pos, finger_end_pos)
				current_brick.z_index = 0
				current_brick.initial_pos()
				emit_signal("brick_wrong_place")
			current_drawed_brick = null
		elif tutorial_state == TUTORIAL_PART2:
			print("here")
			current_brick.z_index = 0
			current_brick.initial_pos()
			emit_signal("brick_wrong_place")
			current_drawed_brick = null
		else:
			if is_grid_available(grid_pos, current_brick.brick_type_array) :
				get_node("../GoBackTimer").start()
				add_brick_to_grid(grid_pos, current_brick.brick_type_array)
				emit_signal("brick_passed")
				current_brick.queue_free()
				save_current_board()
				yield(current_brick, "tree_exited")
				yield(get_tree().create_timer(0.2),"timeout")
				save_current_bricks()
				check_is_game_stuck()
			elif is_on_trashButton:
				current_brick.exit_animation()
				is_on_trashButton = false
				get_node("../GoBackTimer").start()
				emit_signal("brick_removed")
				TrashButton.play_removed_animation()
				yield(get_tree().create_timer(0.3),"timeout")
				GameDataManager.game_data["is_trash_button_active"] = false
				save_current_bricks()
			else:
				current_brick.z_index = 0
				current_brick.initial_pos()
				emit_signal("brick_wrong_place")
			current_drawed_brick = null

func print_arr(arr):
	for row in arr:
		print(row)

#func clear_board():
#	for row in grid_array:
#		for brick in row:
#			if brick != null:
#				brick.queue_free()

func clear_board():
	for i in range(grid_array.size()):
		for j in range(grid_array[i].size()):
			if is_instance_valid(grid_array[i][j]):
				grid_array[i][j].queue_free()
				grid_array[i][j] = null


func is_on_TrashButton(pos: Vector2):
	# top_corner_pos is TrashButton_global_position
	var bottom_corner_pos = TrashButton_global_position + TrashButton_size
	if (pos.x > TrashButton_global_position.x - 30 and pos.x < bottom_corner_pos.x + 30) and (pos.y > TrashButton_global_position.y and pos.y < bottom_corner_pos.y):
		print("inside")
		return true
	else:
		return false

func add_borders():
	if not is_box_border_exist:
		is_box_border_exist = true
		var childrens = get_node("../GridContainer").get_children()
		for box in childrens:
			var border = box_border_path.instance()
			border.set_color(border_color)
			box.add_child(border)
	
func clear_borders():
	is_box_border_exist = false
	var container = get_node("../GridContainer")
	for box in container.get_children():
		var border = box.get_children()
		if border.size() > 0:
			border[0].queue_free()

func merge_numbers(grid_position):
	# "grid_position" is a position that the bricks in "arr" will merge on
	# since it is called when state == CHOICE, the selected_bricks is not empty
	var number = selected_bricks[0].get_number()
	var new_number = 3 * number
#	for brick in selected_bricks:
#		brick.is_matched = false
#		brick.move(brick.position, grid_to_pixel(grid_position))
	for i in range(selected_bricks.size()):
		selected_bricks[i].is_matched = false
		selected_bricks[i].move(selected_bricks[i].position, grid_to_pixel(grid_position))
		var pos = selected_brick_grid_positions[i]
		grid_array[pos.x][pos.y] = null
	selected_bricks = []
	selected_brick_grid_positions = []
	add_new_brick_to_grid(grid_position, str(new_number))
	state = PLAY
	emit_signal("numbers_merged", new_number)

func _input(event):
	if event.is_action_pressed("ui_touch"):
		if state == PLAY:
			if tutorial_state == TUTORIAL_PART2:
				var pos = get_global_mouse_position()
				var grid_pos = pixel_to_grid(pos)
				if grid_pos != null:
					var min_x
					var max_x
					var min_y
					var max_y
					if merge_pos[index_no][0].x < merge_pos[index_no][1].x:
						min_x = merge_pos[index_no][0].x
						max_x = merge_pos[index_no][1].x
					else:
						min_x = merge_pos[index_no][1].x
						max_x = merge_pos[index_no][0].x
					if merge_pos[index_no][0].y < merge_pos[index_no][1].y:
						min_y = merge_pos[index_no][0].y
						max_y = merge_pos[index_no][1].y
					else:
						min_y = merge_pos[index_no][1].y
						max_y = merge_pos[index_no][0].y
					
					if (grid_pos.x >= min_x and grid_pos.x <= max_x) and (grid_pos.y >= min_y and grid_pos.y <= max_y):
						if is_idx_in_grid(grid_pos.x, grid_pos.y):
							#if grid_array[grid_pos.x][grid_pos.y] != null:
							if is_instance_valid(grid_array[grid_pos.x][grid_pos.y]):
								if not grid_array[grid_pos.x][grid_pos.y].is_matched:
									grid_array[grid_pos.x][grid_pos.y].is_matched = true
									selected_bricks.append(grid_array[grid_pos.x][grid_pos.y])
									selected_brick_grid_positions.append(grid_pos)
									state = SELECT
			elif tutorial_state == TUTORIAL_FINISHED:
				var pos = get_global_mouse_position()
				var grid_pos = pixel_to_grid(pos)
				if grid_pos != null:
					if is_idx_in_grid(grid_pos.x, grid_pos.y):
							if is_instance_valid(grid_array[grid_pos.x][grid_pos.y]):
								if not grid_array[grid_pos.x][grid_pos.y].is_matched:
									grid_array[grid_pos.x][grid_pos.y].is_matched = true
									selected_bricks.append(grid_array[grid_pos.x][grid_pos.y])
									selected_brick_grid_positions.append(grid_pos)
									state = SELECT
		elif state == CHOICE:
			var is_clicked_on_selected_brick = false
			var pos = get_global_mouse_position()
			var grid_pos = pixel_to_grid(pos)
			if tutorial_state == TUTORIAL_PART2:
				print("Tutorial 2 not finished")
				for brick in selected_bricks:
					#if pixel_to_grid(brick.position) == grid_pos:
					if merge_onto_pos[index_no] == grid_pos:
						is_clicked_on_selected_brick = true
				if not is_clicked_on_selected_brick:
					merge_animation_play()
					state = PLAY
					for brick in selected_bricks:
						brick.is_matched = false
						selected_bricks = []
						selected_brick_grid_positions = []
				else:
					index_no += 1
					if index_no == merge_pos.size():
						tutorial_state = TUTORIAL_FINISHED
						stop_finger_animation()
						emit_signal("tutorial_finished")
						GameDataManager.game_data["is_tutorial_completed"] = true
						GameDataManager.data["current_data"]["is_tutorial_completed"] = true
						GameDataManager.save_game()
						
					else:
						merge_animation_play()
					merge_numbers(grid_pos)
					yield(get_tree().create_timer(0.5),"timeout")
					save_current_board(grid_array, true)
					check_is_game_stuck()
			elif tutorial_state == TUTORIAL_FINISHED:
				print("Tutorial 2 finished")
				for brick in selected_bricks:
					if pixel_to_grid(brick.position) == grid_pos:
						is_clicked_on_selected_brick = true
				if not is_clicked_on_selected_brick:
					state = PLAY
					for brick in selected_bricks:
						brick.is_matched = false
						selected_bricks = []
						selected_brick_grid_positions = []
				else:
					merge_numbers(grid_pos)
					yield(get_tree().create_timer(0.5),"timeout")
					save_current_board(grid_array, true)
					check_is_game_stuck()
	if  state == SELECT and selected_bricks.size() > 0:
		if Input.is_action_pressed("ui_touch"):
			var pos = get_global_mouse_position()
			var grid_pos = pixel_to_grid(pos)
			if grid_pos != null:
				if is_idx_in_grid(grid_pos.x, grid_pos.y):
					#if grid_array[grid_pos.x][grid_pos.y] != null:
					if is_instance_valid(grid_array[grid_pos.x][grid_pos.y]):
						if not grid_array[grid_pos.x][grid_pos.y].is_matched:
							if selected_bricks.size() < 3 and selected_bricks[0].brick_type == grid_array[grid_pos.x][grid_pos.y].brick_type:
								var previous_brick_grid_pos = pixel_to_grid(selected_bricks[-1].position)
								var grid_pos_difference_x = abs(previous_brick_grid_pos.x - grid_pos.x)
								var grid_pos_difference_y = abs(previous_brick_grid_pos.y - grid_pos.y)
								if grid_pos_difference_x <= 1 and grid_pos_difference_y <= 1:
									if selected_bricks.size() == 1:
										var correct_grid_pos = pixel_to_grid(selected_bricks[0].position)
										if grid_pos.x == correct_grid_pos.x or grid_pos.y == correct_grid_pos.y:
											grid_array[grid_pos.x][grid_pos.y].is_matched = true
											selected_bricks.append(grid_array[grid_pos.x][grid_pos.y])
											selected_brick_grid_positions.append(grid_pos)
									elif selected_bricks.size() == 2:
										var first_brick_grid_pos = pixel_to_grid(selected_bricks[0].position)
										var second_brick_grid_pos = pixel_to_grid(selected_bricks[1].position)
										if first_brick_grid_pos.x == second_brick_grid_pos.x and second_brick_grid_pos.x == grid_pos.x:
											grid_array[grid_pos.x][grid_pos.y].is_matched = true
											selected_bricks.append(grid_array[grid_pos.x][grid_pos.y])
											selected_brick_grid_positions.append(grid_pos)
										elif first_brick_grid_pos.y == second_brick_grid_pos.y and second_brick_grid_pos.y == grid_pos.y:
											grid_array[grid_pos.x][grid_pos.y].is_matched = true
											selected_bricks.append(grid_array[grid_pos.x][grid_pos.y])
											selected_brick_grid_positions.append(grid_pos)
										if tutorial_state == TUTORIAL_PART2:
											var is_enpoints_same = (pixel_to_grid(selected_bricks[0].position) == merge_pos[index_no][0]) and (pixel_to_grid(selected_bricks[2].position) == merge_pos[index_no][1])
											var is_inverse_enpoints_same = (pixel_to_grid(selected_bricks[0].position) == merge_pos[index_no][1]) and (pixel_to_grid(selected_bricks[2].position) == merge_pos[index_no][0])
											if is_enpoints_same or is_inverse_enpoints_same:
												stop_finger_animation()
												var merge_pos = grid_to_pixel(merge_onto_pos[index_no])
												play_finger_animation(merge_pos, merge_pos, "oneTap")
						else:
							if selected_bricks.size() > 1 :
								if grid_array[grid_pos.x][grid_pos.y] == selected_bricks[-2]:
									if tutorial_state == TUTORIAL_PART2:
										if selected_bricks.size() == 3:
											merge_animation_play()
									selected_bricks[-1].is_matched = false
									selected_bricks.pop_back()
									selected_brick_grid_positions.pop_back()
		else:
			if selected_bricks.size() < 3:
				state = PLAY
				for brick in selected_bricks:
					brick.is_matched = false
					selected_bricks = []
					selected_brick_grid_positions = []
			elif selected_bricks.size() == 3:
				state = CHOICE
	if event.is_action_released("ui_touch"):
		if state == HUMMER:
			var pos = get_global_mouse_position()
			var grid_pos = pixel_to_grid(pos)
			if grid_pos != null:
				#if grid_array[grid_pos.x][grid_pos.y] != null:
				if is_instance_valid(grid_array[grid_pos.x][grid_pos.y]):
					grid_array[grid_pos.x][grid_pos.y].exit_animation()
					grid_array[grid_pos.x][grid_pos.y] = null
					emit_signal("hummer_removed_brick")
					clear_borders()
					GameDataManager.game_data["is_hummer_button_active"] = false
					save_current_board(grid_array, true)
				else:
					emit_signal("hummer_wrong_place", pos)
					clear_borders()
			else:
				emit_signal("hummer_wrong_place", pos)
				clear_borders()
			state = PLAY


func check_TrashButton():
	if TrashButton.button_state:
		if is_on_TrashButton(current_drawed_brick.global_position):
			current_drawed_brick.scale = current_drawed_brick.brick_size_trash
			TrashButton.rect_scale = Vector2(1.3,1.3)
			is_on_trashButton = true
			#current_drawed_brick.global_position = TrashButton_global_position + TrashButton_size/2
		else:
			is_on_trashButton = false
			current_drawed_brick.scale = current_drawed_brick.brick_size_dragged
			TrashButton.rect_scale = Vector2(1,1)

# -------------- Tutorial functions start -----------------

func merge_animation_play():
	if tutorial_state == TUTORIAL_PART2:
		print("Tutorial 2")
		stop_finger_animation()
		set_finger_pos_to_merge(index_no)
		play_finger_animation(finger_start_pos, finger_end_pos)
		



func create_hint_brick(idx : int):
	if idx < brick_types.size():
		current_hint_brick = possible_bricks[brick_types[idx]].instance()
		add_child(current_hint_brick)
		current_hint_brick.position = grid_to_pixel(grid_pos_to_past[idx])
		current_hint_brick.modulate = Color(1,1,1,0.4)
		current_hint_brick.is_movable = false
		current_hint_brick.scale = current_hint_brick.brick_size_passed + Vector2(0.1,0.1)
		while current_hint_brick.degree != brick_right_angles[idx]:
			current_hint_brick.rotate_brick()

func set_finger_pos_to_merge(pos_arr_idx):
	# pos_arr_idx is index of merge_pos array which contains grid indexes to be merged
	if pos_arr_idx < merge_pos.size():
		is_play_finger_animation = true
		finger_start_pos = grid_to_pixel(merge_pos[pos_arr_idx][0])
		finger_end_pos =  grid_to_pixel(merge_pos[pos_arr_idx][1])
	else:
		is_play_finger_animation = false

func set_finger_pos(idx):
	if idx < grid_pos_to_past.size():
		is_play_finger_animation = true
		var panel_name = "brick_panel" + str(brick_panel_no[idx])
		finger_start_pos = Bottom_ui_node.get_node(panel_name).rect_global_position + Bottom_ui_node.get_node(panel_name).rect_size/2
		finger_end_pos =  grid_to_pixel(grid_pos_to_past[idx])
	else:
		is_play_finger_animation = false
		#get_node("../Top_ui/Hammer_Button").disabled = false
		#get_tree().paused = true
		#finger.position = get_node("../Top_ui/Hammer_Button").rect_global_position + Vector2(30,30)
		#finger.start_animation(Vector2(0,0),Vector2(0,0), "oneTap")
		#emit_signal("tutorial_end")

func play_finger_animation(from, to, type = "swipeFinger"):
	if is_play_finger_animation:
		#finger = finger_pos.instance()
		#add_child(finger)
		finger.position = from
		finger.start_animation(from,to, type)

func stop_finger_animation():
	#if finger != null:
	if is_instance_valid(finger):
		finger.stop_animation()

func check_right_degree(idx):
	if idx < grid_pos_to_past.size():
		var panel_path = "../Bottom_ui/brick_panel" + str(brick_panel_no[idx])
		var childrens = get_node(panel_path).get_children()
		if childrens.size() > 1:
			if (childrens[1].degree - brick_right_angles[idx]) % 360 != 0:
				is_rotate_animation = true

# -------------- Tutorial functions end --------------------



func _on_GridContainer_resized():
	x_start = grid_container_node.rect_position.x
	y_start = grid_container_node.rect_position.y


func _on_brick_panel4_dragged_brickk(objectt):
	if not is_current_brick_changed:
		current_drawed_brick = objectt
		current_drawed_brick.z_index = 2
		is_current_brick_changed = true
	check_TrashButton()
	if state == HUMMER:
		state = PLAY
		clear_borders()
		emit_signal("hummer_wrong_place", get_global_mouse_position())
	if tutorial_state == TUTORIAL_PART1:
		stop_finger_animation()


func _on_brick_panel4_mouse_released(mouse_position):
	var grid_pos = pixel_to_grid(mouse_position)
	past_brick(grid_pos, current_drawed_brick)


func _on_brick_panel5_dragged_brickk(objectt):
	if not is_current_brick_changed:
		current_drawed_brick = objectt
		current_drawed_brick.z_index = 2
		is_current_brick_changed = true
	check_TrashButton()
	if state == HUMMER:
		state = PLAY
		clear_borders()
		emit_signal("hummer_wrong_place", get_global_mouse_position())
	if tutorial_state == TUTORIAL_PART1:
		stop_finger_animation()


func _on_brick_panel5_mouse_released(mouse_position):
	var grid_pos = pixel_to_grid(mouse_position)
	past_brick(grid_pos, current_drawed_brick)


func _on_brick_panel6_dragged_brickk(objectt):
	if not is_current_brick_changed:
		current_drawed_brick = objectt
		current_drawed_brick.z_index = 2
		is_current_brick_changed = true
	check_TrashButton()
	if state == HUMMER:
		state = PLAY
		clear_borders()
		emit_signal("hummer_wrong_place", get_global_mouse_position())
	if tutorial_state == TUTORIAL_PART1:
		stop_finger_animation()


func _on_brick_panel6_mouse_released(mouse_position):
	var grid_pos = pixel_to_grid(mouse_position)
	past_brick(grid_pos, current_drawed_brick)
	


func _on_brick_panel4_brick_rotated(this_brick, degree):
	if tutorial_state == TUTORIAL_PART1:
		if brick_panel_no[index_no] == 4:
			print("4")
			if (this_brick.degree - brick_right_angles[index_no]) % 360 == 0 :
				is_rotate_animation = false
				stop_finger_animation()
				past_brick(Vector2(7,7), this_brick)
			else:
				is_rotate_animation = true
				stop_finger_animation()
				past_brick(Vector2(7,7), this_brick)


func _on_brick_panel5_brick_rotated(this_brick, degree):
	if tutorial_state == TUTORIAL_PART1:
		if brick_panel_no[index_no] == 5:
			print("5")
			if (this_brick.degree - brick_right_angles[index_no]) % 360 == 0 :
				is_rotate_animation = false
				stop_finger_animation()
				past_brick(Vector2(7,7), this_brick)
			else:
				is_rotate_animation = true
				stop_finger_animation()
				past_brick(Vector2(7,7), this_brick)


func _on_brick_panel6_brick_rotated(this_brick, degree):
	if tutorial_state == TUTORIAL_PART1:
		if brick_panel_no[index_no] == 6:
			print("6")
			if (this_brick.degree - brick_right_angles[index_no]) % 360 == 0 :
				is_rotate_animation = false
				stop_finger_animation()
				past_brick(Vector2(7,7), this_brick)
			else:
				is_rotate_animation = true
				stop_finger_animation()
				past_brick(Vector2(7,7), this_brick)


func _on_NoButton_pressed():
	state = PLAY


func _on_Replay_Button_pressed():
	state = PAUSE


func _on_HummerButton_toggled(button_pressed):
	if button_pressed:
		state = HUMMER
		add_borders()
