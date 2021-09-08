extends Node2D

signal mouse_released(pos)
signal dragged_brick(obj)
signal brick_rotated

export (Dictionary) var textures = {}

# this should be brick_type not grid_type
export (Array,Array) var grid_type
export (String) var brick_type
export (int) var degree = 0
var initial_pos = Vector2()
var is_matched = false setget set_glow_effect, get_is_matched
var is_movable = true
onready var icons_array = [[$icons/icon1,$icons/icon2,$icons/icon3],[$icons/icon4,$icons/icon5,$icons/icon6],[$icons/icon7,$icons/icon8,$icons/icon9]]
var brick_type_array = []
var is_just_dragged = true
var brick_size_dragged = Vector2(1.1, 1.1)
var brick_size_passed = Vector2(1.1, 1.1)
var brick_size_initial = Vector2(0.7, 0.7)
var brick_size_trash = Vector2(0.4, 0.4)


func _ready():
	brick_type_array = grid_type.duplicate(true)
	unvisible_all_icons()
	set_process(false)
	generate_brick(brick_type_array)
	yield(get_tree().create_timer(0.3),"timeout")
	initial_pos = global_position

func set_glow_effect(value):
	is_matched = value
	if value:
		$icons/icon5/Border.screen_in()
	else:
		$icons/icon5/Border.screen_out()

func get_is_matched():
	return is_matched

func generate_brick(arr):
	for elt in arr:
		if elt[1] != 0:
			var number = elt[1]
			var texture = textures[number]
			icons_array[elt[0].x][elt[0].y].texture = texture
			icons_array[elt[0].x][elt[0].y].visible = true


func unvisible_all_icons():
	for row in icons_array:
		for col in row:
			if col != null:
				col.visible = false

func increase_effect():
	var target_scale = brick_size_passed + Vector2(0.1,0.1)
	for icon in $icons.get_children():
		$ExpandTween.interpolate_property(icon, "rect_scale", Vector2(1,1), target_scale, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$ExpandTween.interpolate_property(icon, "rect_scale", target_scale, Vector2(1,1), 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.2)
		$ExpandTween.start()
	#$icons.modulate = Color(1,1,1,0.5)

func screen_in(time = 0.5):
	scale = Vector2(0,0)
	$Tween.interpolate_property(self, "scale", Vector2(0,0), brick_size_passed, time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func screen_in_from_down(time = 0.3):
	var current_pos = position
	position = current_pos + Vector2(0,300)
	$Tween.interpolate_property(self, "position", current_pos + Vector2(0,300), current_pos, time, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	initial_pos = global_position

func move(from, to, time = 0.2):
	$MoveTween.interpolate_property(self, "position", from, to, time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$MoveTween.start()
	yield($MoveTween,"tween_all_completed")
	queue_free()

func get_number():
	return grid_type[4][1]

# warning-ignore:function_conflicts_variable
func initial_pos():
	global_position = initial_pos
	scale = brick_size_initial

func get_center_position():
	return $icons/icon5.rect_global_position + $icons/icon5.rect_size/2

# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_pressed("ui_touch"):
		if  $Timer.is_stopped() and global_position != get_global_mouse_position() + Vector2(0,-120):
			if is_just_dragged:
				scale = brick_size_dragged
				is_just_dragged = false
			global_position = get_global_mouse_position() + Vector2(0,-120)
			emit_signal("dragged_brick", self)
	if Input.is_action_just_released("ui_touch"):
		is_just_dragged = true
		if not $Timer.is_stopped():
			rotate_brick()
			set_process(false)
			#initial_pos()
		else:
			set_process(false)
			emit_signal("mouse_released", global_position)
			#initial_pos()

func generate_array(row, col):
	var new_arr = []
# warning-ignore:unused_variable
	for i in range(row):
		var arr2 = []
# warning-ignore:unused_variable
		for j in range(col):
			arr2.append(null)
		new_arr.append(arr2)
	return new_arr

func rotate_matrix(arr):
	# arr should be 3x3
	var new_arr = generate_array(3, 3)
	new_arr[0][0] = arr[0][2]
	new_arr[0][1] = arr[1][2]
	new_arr[0][2] = arr[2][2]
	new_arr[1][0] = arr[0][1]
	new_arr[1][1] = arr[1][1]
	new_arr[1][2] = arr[2][1]
	new_arr[2][0] = arr[0][0]
	new_arr[2][1] = arr[1][0]
	new_arr[2][2] = arr[2][0]
	return new_arr

func exit_animation(time = 0.2):
	$ExitTween.interpolate_property(self, "scale", scale, Vector2(0,0), time, Tween.TRANS_BACK, Tween.EASE_IN)
	$ExitTween.start()
	yield($ExitTween, "tween_completed")
	queue_free()

func rotate_brick():
	if not brick_type.is_valid_integer() :
		unvisible_all_icons()
		#rotate_shapes(90)
		var new_arr = generate_array(3,3)
		var n = 0
		for i in range(3):
			for j in range(3):
				new_arr[i][j] = brick_type_array[n][1]
				n += 1
		var rot_arr = rotate_matrix(new_arr)
		var m = 0
		for i in range(3):
			for j in range(3):
				brick_type_array[m][1] = rot_arr[i][j] 
				m += 1
		generate_brick(brick_type_array)
		degree += 90
		emit_signal("brick_rotated")

func rotate_and_return_copy(arr = brick_type_array):
	var type_arr = arr.duplicate(true)
	var new_arr = generate_array(3,3)
	var n = 0
	for i in range(3):
		for j in range(3):
			new_arr[i][j] = type_arr[n][1]
			n += 1
	var rot_arr = rotate_matrix(new_arr)
	var m = 0
	for i in range(3):
		for j in range(3):
			type_arr[m][1] = rot_arr[i][j] 
			m += 1
	return type_arr

# warning-ignore:unused_argument
func pressed():
	if is_movable:
		$Timer.start()
		set_process(true)



func _on_icon1_gui_input(event):
	if event.is_action_pressed("ui_touch"):
		pressed()


func _on_icon2_gui_input(event):
	if event.is_action_pressed("ui_touch"):
		pressed()


func _on_icon3_gui_input(event):
	if event.is_action_pressed("ui_touch"):
		pressed()


func _on_icon4_gui_input(event):
	if event.is_action_pressed("ui_touch"):
		pressed()


func _on_icon5_gui_input(event):
	if event.is_action_pressed("ui_touch"):
		pressed()


func _on_icon6_gui_input(event):
	if event.is_action_pressed("ui_touch"):
		pressed()


func _on_icon7_gui_input(event):
	if event.is_action_pressed("ui_touch"):
		pressed()


func _on_icon8_gui_input(event):
	if event.is_action_pressed("ui_touch"):
		pressed()


func _on_icon9_gui_input(event):
	if event.is_action_pressed("ui_touch"):
		pressed()

