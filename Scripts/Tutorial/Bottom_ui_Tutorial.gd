extends HBoxContainer

#signal game_stuck

var rnd = RandomNumberGenerator.new()
onready var grid_node = get_node("../Grid")

var is_brick_add_animation_on = true

func get_current_bricks():
	var current_bricks = []
	for brick_panel in get_node("../Bottom_ui").get_children():
		var childrens = brick_panel.get_children()
		childrens.pop_front()
		current_bricks = current_bricks + childrens
		
	for brick in current_bricks:
		#print(brick.brick_type)
		pass
	#print()
	return current_bricks

func get_current_bricks_as_dict():
	# returns names of current bricks with its panel no
	var current_bricks = {}
	for brick_panel in get_node("../Bottom_ui").get_children():
		var childrens = brick_panel.get_children()
		childrens.pop_front()
		if childrens != []:
			current_bricks[brick_panel.panel_no] = childrens[0].brick_type
	return current_bricks


func get_current_brick_names():
	# returns names of current bricks
	var current_bricks = []
	for brick_panel in get_node("../Bottom_ui").get_children():
		var childrens = brick_panel.get_children()
		childrens.pop_front()
		if childrens != []:
			current_bricks.append(childrens[0].brick_type)
	return current_bricks


func _on_back_step_called():
	is_brick_add_animation_on = false
	for child in get_children():
		child.clear_brick_panel()
	for child in get_children():
		child._ready()
	is_brick_add_animation_on = true
