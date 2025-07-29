extends Control
@onready var menu_root: Control = $CenterContainer/VBoxContainer
@onready var ui_continue: Button = menu_root.get_node(^"ButtonContinue")
@onready var ui_newgame: Button = menu_root.get_node(^"ButtonNewGame")
@onready var ui_settings: Button = menu_root.get_node(^"ButtonSettings")
@onready var ui_exit: Button = menu_root.get_node("ButtonExit")