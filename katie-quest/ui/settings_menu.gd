extends Control
## Sound stuff
@onready var ui_sound_container = $TabContainer/Sound/MarginContainer/GridContainer
@onready var ui_sound_master: Slider = ui_sound_container.get_node(^"SliderMaster")
@onready var ui_sound_music: Slider = ui_sound_container.get_node(^"SliderMusic")
@onready var ui_sound_effects: Slider = ui_sound_container.get_node(^"SliderEffects")
@onready var ui_sound_voices: Slider = ui_sound_container.get_node(^"SliderVoices")

func _ready():
	pass