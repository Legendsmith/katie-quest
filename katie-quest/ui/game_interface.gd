extends Control
@onready var view_label = $ViewLabel
@onready var stamina_bar = $MarginContainer/VBoxContainer/StaminaBar

func _ready() -> void:
	get_tree().get_first_node_in_group("player").stamina_changed.connect(set_stamina_bar)

func _process(_delta):
	view_label.text = Global.view_label_string
	view_label.visible = Global.view_label_string != ""
	view_label.set_position(get_local_mouse_position())

func set_stamina_bar(value:float):
	stamina_bar.value=value
