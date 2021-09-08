extends Node2D


func _ready():
	visible = false

func start_animation(initial_pos, target_pos, type):
	visible = true
	var animation = $AnimationPlayer.get_animation(type)
	if type == "swipeFinger":
		animation.track_set_key_value(1,0, initial_pos)
		animation.track_set_key_value(1,1, target_pos)
	$AnimationPlayer.play(type)
	z_index = 2



func stop_animation():
	visible = false
	$AnimationPlayer.stop()

#
#func play_animation(type = "swipeFinger"):
#	$AnimationPlayer.play(type)
#	visible = true
	
