extends Control

@onready var menu_root: Control = $CenterContainer/VBoxContainer
@onready var ui_continue: Button = menu_root.get_node("Continue")
@onready var ui_newgame: Button = menu_root.get_node("NewGame")
@onready var ui_settings: Button = menu_root.get_node("Settings")
@onready var ui_exit: Button = menu_root.get_node("Exit")

func _on_ButtonContinue_pressed():
	SaveManager.load_saved_scene()

func _on_ButtonNewGame_pressed():
	Fade.change_scene("res://world/demo_level.tscn")

func _on_ButtonSettings_pressed():
	Fade.change_scene("res://ui/settings_menu.tscn")

func _on_ButtonExit_pressed():
	get_tree().quit()

func _ready():
	ui_continue.pressed.connect(_on_ButtonContinue_pressed)
	ui_newgame.pressed.connect(_on_ButtonNewGame_pressed)
	ui_settings.pressed.connect(_on_ButtonSettings_pressed)
	ui_exit.pressed.connect(_on_ButtonExit_pressed)

	check_save_file()

func check_save_file():
	if not ResourceLoader.exists("user://savegame.tres"):
		ui_continue.visible = false

	else:
		var save_data = ResourceLoader.load("user://savegame.tres") as SaveData

		if save_data and save_data.current_scene != "":
			ui_continue.visible = true

		else:
			ui_continue.visible = false
