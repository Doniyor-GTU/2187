extends GridContainer

#export(Texture) var texture

func _ready():
	#set_texture(texture)
	pass

func set_texture(icon : Texture):
	for child in get_children():
		child.get("custom_styles/panel").set("texture", icon)

func glow_boxes():
	pass
