extends Control
@onready var view_label = $ViewLabel

func _process(_delta):
	view_label.text = Global.view_label_string
	view_label.visible = Global.view_label_string != ""
	view_label.set_position(get_local_mouse_position())